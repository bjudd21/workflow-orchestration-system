#!/usr/bin/env python3
"""
Add auto-chaining between Phase 2 → 3 → 4 workflows.

This script modifies the n8n workflow JSON files to:
1. Phase 2: Auto-trigger Phase 3 after interview completion
2. Phase 3: Write handoff file + auto-trigger Phase 4
3. Phase 4: Include artifact links in response
"""

import json
import uuid
from pathlib import Path


def generate_node_id():
    """Generate a unique node ID in n8n format."""
    return str(uuid.uuid4())


def add_phase2_trigger(workflow_path: Path):
    """Add HTTP Request node to Phase 2 to trigger Phase 3."""
    print(f"📝 Modifying {workflow_path.name}...")

    with open(workflow_path, 'r') as f:
        workflow = json.load(f)

    # Find the "Write Binary File - Handoff" node
    handoff_node = None
    for node in workflow['nodes']:
        if node['name'] == 'Write Binary File - Handoff':
            handoff_node = node
            break

    if not handoff_node:
        print("❌ Could not find 'Write Binary File - Handoff' node")
        return False

    # Check if trigger node already exists
    trigger_exists = any(n['name'] == 'HTTP Request - Trigger Phase 3' for n in workflow['nodes'])
    if trigger_exists:
        print("⚠️  Trigger node already exists, skipping...")
        return True

    # Create new HTTP Request node to trigger Phase 3
    trigger_node_id = generate_node_id()
    trigger_node = {
        "id": trigger_node_id,
        "name": "HTTP Request - Trigger Phase 3",
        "type": "n8n-nodes-base.httpRequest",
        "typeVersion": 4.2,
        "position": [
            handoff_node['position'][0] + 400,  # Position to the right
            handoff_node['position'][1]
        ],
        "parameters": {
            "url": "http://localhost:5678/webhook/prd-synthesis-action",
            "method": "POST",
            "sendBody": True,
            "bodyParameters": {
                "parameters": [
                    {
                        "name": "project",
                        "value": "={{ $json.project }}"
                    },
                    {
                        "name": "action",
                        "value": "synthesize"
                    }
                ]
            },
            "options": {
                "timeout": 180000
            }
        }
    }

    workflow['nodes'].append(trigger_node)

    # Update connections: Handoff → Trigger Node
    if 'connections' not in workflow:
        workflow['connections'] = {}

    # Find current connections from handoff node
    handoff_node_name = handoff_node['name']
    if handoff_node_name not in workflow['connections']:
        workflow['connections'][handoff_node_name] = {"main": [[]]}

    # Add connection to trigger node
    workflow['connections'][handoff_node_name]['main'][0].append({
        "node": "HTTP Request - Trigger Phase 3",
        "type": "main",
        "index": 0
    })

    # Write back
    with open(workflow_path, 'w') as f:
        json.dump(workflow, f, indent=2)

    print(f"✅ Added Phase 3 trigger to {workflow_path.name}")
    return True


def add_phase3_handoff_and_trigger(workflow_path: Path):
    """Add handoff file write + Phase 4 trigger to Phase 3."""
    print(f"📝 Modifying {workflow_path.name}...")

    with open(workflow_path, 'r') as f:
        workflow = json.load(f)

    # Find the "Code - Write Versioned PRD" node
    write_prd_node = None
    for node in workflow['nodes']:
        if node['name'] == 'Code - Write Versioned PRD':
            write_prd_node = node
            break

    if not write_prd_node:
        print("❌ Could not find 'Code - Write Versioned PRD' node")
        return False

    # Check if nodes already exist
    handoff_exists = any(n['name'] == 'Code - Write Handoff Copy' for n in workflow['nodes'])
    trigger_exists = any(n['name'] == 'HTTP Request - Trigger Phase 4' for n in workflow['nodes'])

    if handoff_exists and trigger_exists:
        print("⚠️  Handoff and trigger nodes already exist, skipping...")
        return True

    # Create handoff write node
    handoff_node_id = generate_node_id()
    handoff_node = {
        "id": handoff_node_id,
        "name": "Code - Write Handoff Copy",
        "type": "n8n-nodes-base.code",
        "typeVersion": 2,
        "position": [
            write_prd_node['position'][0] + 300,
            write_prd_node['position'][1]
        ],
        "parameters": {
            "jsCode": """const fs = require('fs');
const path = require('path');
const data = $input.first().json;

// Build handoff path
const workspacePath = process.env.WORKSPACE_PATH || '/data/workspace';
const handoffDir = path.join(workspacePath, data.project, 'handoffs');
const handoffPath = path.join(handoffDir, '003-prd-refined.md');

// Ensure directory exists
fs.mkdirSync(handoffDir, { recursive: true });

// Write handoff file
fs.writeFileSync(handoffPath, data.prd_text, 'utf8');

return [{
  json: {
    ...data,
    handoff_path: handoffPath
  }
}];
"""
        }
    }

    # Create Phase 4 trigger node
    trigger_node_id = generate_node_id()
    trigger_node = {
        "id": trigger_node_id,
        "name": "HTTP Request - Trigger Phase 4",
        "type": "n8n-nodes-base.httpRequest",
        "typeVersion": 4.2,
        "position": [
            write_prd_node['position'][0] + 600,
            write_prd_node['position'][1]
        ],
        "parameters": {
            "url": "http://localhost:5678/webhook/council-review-action",
            "method": "POST",
            "sendBody": True,
            "bodyParameters": {
                "parameters": [
                    {
                        "name": "project",
                        "value": "={{ $json.project }}"
                    },
                    {
                        "name": "action",
                        "value": "review"
                    }
                ]
            },
            "options": {
                "timeout": 180000
            }
        }
    }

    if not handoff_exists:
        workflow['nodes'].append(handoff_node)
    if not trigger_exists:
        workflow['nodes'].append(trigger_node)

    # Update connections
    if 'connections' not in workflow:
        workflow['connections'] = {}

    # Write PRD → Handoff Copy
    write_prd_name = write_prd_node['name']
    if write_prd_name not in workflow['connections']:
        workflow['connections'][write_prd_name] = {"main": [[]]}

    # Add handoff connection if it doesn't exist
    if not handoff_exists:
        workflow['connections'][write_prd_name]['main'][0].append({
            "node": "Code - Write Handoff Copy",
            "type": "main",
            "index": 0
        })

    # Handoff Copy → Trigger Phase 4
    if not trigger_exists:
        workflow['connections']['Code - Write Handoff Copy'] = {
            "main": [[{
                "node": "HTTP Request - Trigger Phase 4",
                "type": "main",
                "index": 0
            }]]
        }

    # Write back
    with open(workflow_path, 'w') as f:
        json.dump(workflow, f, indent=2)

    print(f"✅ Added handoff copy and Phase 4 trigger to {workflow_path.name}")
    return True


def add_phase4_artifact_links(workflow_path: Path):
    """Modify Phase 4 final response to include artifact links."""
    print(f"📝 Modifying {workflow_path.name}...")

    with open(workflow_path, 'r') as f:
        workflow = json.load(f)

    # Find the "Respond - Review Done" node
    respond_node = None
    for node in workflow['nodes']:
        if node['name'] == 'Respond - Review Done':
            respond_node = node
            break

    if not respond_node:
        print("❌ Could not find 'Respond - Review Done' node")
        return False

    # Check if already modified
    current_body = respond_node['parameters'].get('responseBody', '')
    if 'artifacts' in current_body:
        print("⚠️  Response already includes artifacts, skipping...")
        return True

    # Update response body to include artifact information
    new_response = """={{ JSON.stringify({
  success: true,
  status: "complete",
  verdict: $json.verdict,
  review_number: $json.reviewNum,
  project: $json.project,
  review_text: $json.reviewText,
  artifacts: {
    interview: `workspace/${$json.project}/handoffs/002-prd-interview.md`,
    prd: `workspace/${$json.project}/handoffs/003-prd-refined.md`,
    council_review: `workspace/${$json.project}/handoffs/004-council-review.md`
  },
  note: "Artifacts are available in the workspace directory"
}) }}"""

    respond_node['parameters']['responseBody'] = new_response

    # Write back
    with open(workflow_path, 'w') as f:
        json.dump(workflow, f, indent=2)

    print(f"✅ Updated Phase 4 response to include artifact links")
    return True


def main():
    """Main execution."""
    workflows_dir = Path(__file__).parent.parent / 'workflows'

    print("🚀 Adding auto-chaining to PRD workflow system\n")

    # Phase 2: Add trigger to Phase 3
    phase2_path = workflows_dir / 'phase-2-interview-refactored.json'
    if phase2_path.exists():
        success = add_phase2_trigger(phase2_path)
        if not success:
            print("❌ Failed to modify Phase 2")
            return 1
    else:
        print(f"⚠️  {phase2_path} not found")

    print()

    # Phase 3: Add handoff write + trigger to Phase 4
    phase3_path = workflows_dir / 'phase-3-prd-synthesis.json'
    if phase3_path.exists():
        success = add_phase3_handoff_and_trigger(phase3_path)
        if not success:
            print("❌ Failed to modify Phase 3")
            return 1
    else:
        print(f"⚠️  {phase3_path} not found")

    print()

    # Phase 4: Add artifact links to response
    phase4_path = workflows_dir / 'phase-4-council-review-fixed.json'
    if phase4_path.exists():
        success = add_phase4_artifact_links(phase4_path)
        if not success:
            print("❌ Failed to modify Phase 4")
            return 1
    else:
        print(f"⚠️  {phase4_path} not found")

    print("\n✅ Auto-chaining setup complete!")
    print("\n📋 Next steps:")
    print("1. Import updated workflows to n8n")
    print("2. Activate all workflows")
    print("3. Test end-to-end: Interview → PRD → Council Review")
    print("4. Verify handoff files in workspace/{project}/handoffs/")

    return 0


if __name__ == '__main__':
    exit(main())
