/**
 * SSE Broadcast Service
 *
 * Receives events from n8n workflows via HTTP POST and broadcasts them
 * to connected browsers via Server-Sent Events (SSE).
 */

const express = require('express');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 3001;

// Middleware
app.use(cors());
app.use(express.json());

// In-memory storage
const clients = new Map(); // project-id -> Set of response objects
const eventBuffers = new Map(); // project-id -> Array of recent events (last 100)
const BUFFER_SIZE = 100;

/**
 * SSE Endpoint: GET /events/:projectId
 *
 * Establishes a persistent SSE connection for a specific project.
 * Sends historical events if Last-Event-ID header is provided.
 */
app.get('/events/:projectId', (req, res) => {
  const projectId = req.params.projectId;
  const lastEventId = req.headers['last-event-id'];

  // Set SSE headers
  res.setHeader('Content-Type', 'text/event-stream');
  res.setHeader('Cache-Control', 'no-cache');
  res.setHeader('Connection', 'keep-alive');
  res.setHeader('X-Accel-Buffering', 'no'); // Disable nginx buffering
  res.flushHeaders();

  console.log(`[SSE] Client connected to project: ${projectId}`);

  // Add client to project's client set
  if (!clients.has(projectId)) {
    clients.set(projectId, new Set());
  }
  clients.get(projectId).add(res);

  // Send connection confirmation
  res.write(`event: connected\n`);
  res.write(`data: ${JSON.stringify({ message: 'Connected to SSE stream', project: projectId })}\n\n`);

  // Send buffered events if reconnecting
  if (lastEventId && eventBuffers.has(projectId)) {
    const buffer = eventBuffers.get(projectId);
    const lastId = parseInt(lastEventId, 10);

    // Send all events after lastEventId
    const missedEvents = buffer.filter(event => event.id > lastId);
    missedEvents.forEach(event => {
      res.write(`id: ${event.id}\n`);
      res.write(`event: ${event.type}\n`);
      res.write(`data: ${JSON.stringify(event.data)}\n\n`);
    });

    if (missedEvents.length > 0) {
      console.log(`[SSE] Sent ${missedEvents.length} buffered events to reconnected client (project: ${projectId})`);
    }
  }

  // Handle client disconnect
  req.on('close', () => {
    console.log(`[SSE] Client disconnected from project: ${projectId}`);
    const projectClients = clients.get(projectId);
    if (projectClients) {
      projectClients.delete(res);
      if (projectClients.size === 0) {
        clients.delete(projectId);
        console.log(`[SSE] No more clients for project: ${projectId}`);
      }
    }
  });

  // Send keep-alive comment every 30 seconds
  const keepAliveInterval = setInterval(() => {
    res.write(`: keep-alive\n\n`);
  }, 30000);

  req.on('close', () => clearInterval(keepAliveInterval));
});

/**
 * Event Ingestion Endpoints
 *
 * These endpoints receive events from n8n workflows and broadcast them
 * to all connected clients for the specified project.
 */

// Phase 3: PRD Synthesis Progress
app.post('/events/:projectId/phase3/progress', (req, res) => {
  const projectId = req.params.projectId;
  const { percent, message } = req.body;

  const event = {
    type: 'phase3.progress',
    project: projectId,
    timestamp: new Date().toISOString(),
    data: { percent, message }
  };

  broadcastEvent(projectId, event);
  res.status(200).json({ status: 'broadcasted', clients: clients.get(projectId)?.size || 0 });
});

// Phase 4: Council Reviewer Completion
app.post('/events/:projectId/phase4/reviewer', (req, res) => {
  const projectId = req.params.projectId;
  const { reviewer, review, verdict, concerns_count } = req.body;

  const event = {
    type: 'phase4.reviewer',
    project: projectId,
    timestamp: new Date().toISOString(),
    data: { reviewer, review, verdict, concerns_count }
  };

  broadcastEvent(projectId, event);
  res.status(200).json({ status: 'broadcasted', clients: clients.get(projectId)?.size || 0 });
});

// Phase 4: Council Review Complete
app.post('/events/:projectId/phase4/complete', (req, res) => {
  const projectId = req.params.projectId;
  const { verdict, summary, concerns, endorsements } = req.body;

  const event = {
    type: 'phase4.complete',
    project: projectId,
    timestamp: new Date().toISOString(),
    data: { verdict, summary, concerns, endorsements }
  };

  broadcastEvent(projectId, event);
  res.status(200).json({ status: 'broadcasted', clients: clients.get(projectId)?.size || 0 });
});

// Generic event endpoint (for future extensibility)
app.post('/events/:projectId/:eventType', (req, res) => {
  const projectId = req.params.projectId;
  const eventType = req.params.eventType;

  const event = {
    type: eventType,
    project: projectId,
    timestamp: new Date().toISOString(),
    data: req.body
  };

  broadcastEvent(projectId, event);
  res.status(200).json({ status: 'broadcasted', clients: clients.get(projectId)?.size || 0 });
});

/**
 * Broadcast an event to all connected clients for a project
 */
function broadcastEvent(projectId, event) {
  // Add event to buffer
  if (!eventBuffers.has(projectId)) {
    eventBuffers.set(projectId, []);
  }
  const buffer = eventBuffers.get(projectId);

  // Generate unique event ID
  const eventId = Date.now();
  const bufferedEvent = { id: eventId, ...event };

  buffer.push(bufferedEvent);

  // Trim buffer to max size
  if (buffer.length > BUFFER_SIZE) {
    buffer.shift();
  }

  // Broadcast to all connected clients
  const projectClients = clients.get(projectId);
  if (projectClients && projectClients.size > 0) {
    console.log(`[SSE] Broadcasting ${event.type} to ${projectClients.size} client(s) (project: ${projectId})`);

    projectClients.forEach(client => {
      try {
        client.write(`id: ${eventId}\n`);
        client.write(`event: ${event.type}\n`);
        client.write(`data: ${JSON.stringify(event.data)}\n\n`);
      } catch (err) {
        console.error(`[SSE] Error writing to client:`, err.message);
        projectClients.delete(client);
      }
    });
  } else {
    console.log(`[SSE] No clients connected for project: ${projectId} (event: ${event.type})`);
  }
}

/**
 * Health Check Endpoint
 */
app.get('/health', (req, res) => {
  const totalClients = Array.from(clients.values()).reduce((sum, set) => sum + set.size, 0);
  res.json({
    status: 'healthy',
    uptime: process.uptime(),
    projects: clients.size,
    connectedClients: totalClients,
    bufferedProjects: eventBuffers.size
  });
});

/**
 * Debug Endpoint: List connected clients
 */
app.get('/debug/clients', (req, res) => {
  const clientInfo = {};
  clients.forEach((clientSet, projectId) => {
    clientInfo[projectId] = {
      clients: clientSet.size,
      bufferedEvents: eventBuffers.get(projectId)?.length || 0
    };
  });
  res.json(clientInfo);
});

/**
 * Start Server
 */
app.listen(PORT, '0.0.0.0', () => {
  console.log(`[SSE] Server listening on http://0.0.0.0:${PORT}`);
  console.log(`[SSE] Health check: http://localhost:${PORT}/health`);
  console.log(`[SSE] Example SSE connection: http://localhost:${PORT}/events/test-project`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('[SSE] SIGTERM received, closing server...');
  // Send close message to all clients
  clients.forEach((clientSet) => {
    clientSet.forEach(client => {
      client.write(`event: close\n`);
      client.write(`data: ${JSON.stringify({ message: 'Server shutting down' })}\n\n`);
      client.end();
    });
  });
  process.exit(0);
});
