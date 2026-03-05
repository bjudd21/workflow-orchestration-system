# SSE Broadcast Service

Server-Sent Events (SSE) service that enables real-time updates from n8n workflows to browser clients.

## Architecture

```
Browser Client                n8n Workflow
     ↓                              ↓
GET /events/:projectId    POST /events/:projectId/:eventType
     ↓                              ↓
     └────────→ SSE Service ←───────┘
                    ↓
            Broadcast to all
            connected clients
```

## Running the Service

### Development (Local)
```bash
cd services/sse-broadcast
npm install
npm run dev  # Uses nodemon for auto-reload
```

### Production (Docker)
```bash
docker compose up sse-broadcast
```

The service runs on port **3001** by default.

## API Endpoints

### SSE Connection

**`GET /events/:projectId`**

Establishes a persistent Server-Sent Events connection for a specific project.

**Parameters:**
- `projectId` (path): Unique project identifier (e.g., `federal-grant-portal-test`)

**Headers:**
- `Last-Event-ID` (optional): Resume from a specific event ID on reconnection

**Response:**
- Content-Type: `text/event-stream`
- Sends events in SSE format as they arrive

**Example:**
```javascript
const eventSource = new EventSource('/events/federal-grant-portal-test');

eventSource.addEventListener('phase3.progress', (e) => {
  const data = JSON.parse(e.data);
  console.log(`Progress: ${data.percent}%`);
});

eventSource.addEventListener('phase4.reviewer', (e) => {
  const data = JSON.parse(e.data);
  console.log(`${data.reviewer} completed review`);
});
```

---

### Event Ingestion Endpoints

These endpoints are called by n8n workflows to broadcast events.

#### Phase 3: PRD Synthesis Progress

**`POST /events/:projectId/phase3/progress`**

Broadcast PRD synthesis progress updates.

**Request Body:**
```json
{
  "percent": 45,
  "message": "Synthesizing Section 4: User Stories..."
}
```

**Response:**
```json
{
  "status": "broadcasted",
  "clients": 2
}
```

---

#### Phase 4: Council Reviewer Completion

**`POST /events/:projectId/phase4/reviewer`**

Broadcast when a council reviewer completes their review.

**Request Body:**
```json
{
  "reviewer": "Tech Reviewer",
  "review": "## Technical Architecture Review\n\n...",
  "verdict": "REVISE",
  "concerns_count": 3
}
```

**Response:**
```json
{
  "status": "broadcasted",
  "clients": 2
}
```

---

#### Phase 4: Council Review Complete

**`POST /events/:projectId/phase4/complete`**

Broadcast when the full council review is complete.

**Request Body:**
```json
{
  "verdict": "REVISE AND RESUBMIT",
  "summary": "The council identified 7 concerns...",
  "concerns": 7,
  "endorsements": 12
}
```

**Response:**
```json
{
  "status": "broadcasted",
  "clients": 2
}
```

---

#### Generic Event Endpoint

**`POST /events/:projectId/:eventType`**

Broadcast any custom event type.

**Request Body:**
```json
{
  "custom_field": "value"
}
```

The event type is determined by the `:eventType` path parameter.

---

### Health Check

**`GET /health`**

Returns service health status.

**Response:**
```json
{
  "status": "healthy",
  "uptime": 3600.5,
  "projects": 2,
  "connectedClients": 3,
  "bufferedProjects": 2
}
```

---

### Debug Endpoint

**`GET /debug/clients`**

Lists all connected clients by project (development only).

**Response:**
```json
{
  "federal-grant-portal-test": {
    "clients": 2,
    "bufferedEvents": 15
  },
  "another-project": {
    "clients": 1,
    "bufferedEvents": 8
  }
}
```

## Event Format

All SSE events follow this structure:

```
id: 1709673015000
event: phase3.progress
data: {"percent":45,"message":"Synthesizing Section 4..."}

```

**Fields:**
- `id`: Unique event ID (Unix timestamp in milliseconds)
- `event`: Event type (e.g., `phase3.progress`, `phase4.reviewer`)
- `data`: JSON payload with event-specific data

## Reconnection Handling

The service buffers the **last 100 events per project** to handle client reconnections.

When a client reconnects with the `Last-Event-ID` header, the service replays all missed events since that ID.

**Example (Browser):**
```javascript
const eventSource = new EventSource('/events/federal-grant-portal-test');

// Browser automatically includes Last-Event-ID on reconnection
eventSource.onerror = () => {
  console.log('Connection lost, reconnecting...');
  // Browser will automatically reconnect with Last-Event-ID header
};
```

## Testing

### Test SSE Connection
```bash
# Terminal 1: Connect to SSE endpoint
curl -N http://localhost:3001/events/test-project

# Terminal 2: Send a test event
curl -X POST http://localhost:3001/events/test-project/phase3/progress \
  -H "Content-Type: application/json" \
  -d '{"percent": 50, "message": "Testing..."}'
```

You should see the event appear in Terminal 1.

### Test from Browser
Open browser console on any page and run:
```javascript
const es = new EventSource('http://localhost:3001/events/test-project');
es.onmessage = (e) => console.log('Event:', e);
es.addEventListener('phase3.progress', (e) => console.log('Progress:', JSON.parse(e.data)));
```

Then POST an event from your terminal (see above) and watch it appear in the browser console.

## Configuration

Environment variables:

| Variable | Default | Description |
|----------|---------|-------------|
| `PORT` | `3001` | Port to listen on |

## Implementation Notes

- **No Authentication**: This service is designed for internal Docker network use only. Do NOT expose to public internet.
- **In-Memory Storage**: Event buffers are stored in memory and cleared on restart.
- **Buffer Size**: Last 100 events per project are retained.
- **Keep-Alive**: Sends a comment every 30 seconds to keep connections alive.
- **CORS**: Enabled for all origins (internal network only).

## Troubleshooting

**Issue**: Events not appearing in browser
- Check that the SSE connection is established: look for `event: connected` message
- Verify the project ID matches between SSE connection and event POST
- Check browser Network tab for the SSE connection (should show "pending")

**Issue**: Connection closes immediately
- Check for nginx/proxy buffering (set `X-Accel-Buffering: no` header)
- Verify firewall/proxy allows long-lived HTTP connections

**Issue**: Browser doesn't reconnect automatically
- Browser EventSource API automatically reconnects on disconnect
- Check browser console for errors
- Verify the service is still running (`GET /health`)
