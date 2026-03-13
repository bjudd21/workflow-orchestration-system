#!/usr/bin/env node

/**
 * Fix Phase 4 SSE emission nodes to send proper JSON payloads (v3 - cleanup)
 *
 * Removes conflicting bodyParameters and ensures only jsonBody is used
 */

const fs = require('fs');

// Read the workflow JSON
const workflowPath = '/tmp/phase4-workflow-fixed.json';
const workflow = JSON.parse(fs.readFileSync(workflowPath, 'utf8'));

// Emission node names to fix
const emissionNodeNames = [
  'Emit Tech Reviewer Event',
  'Emit Security Reviewer Event',
  'Emit Executive Reviewer Event',
  'Emit User Reviewer Event',
  'Emit Council Complete Event'
];

// Update each emission node
let updatedCount = 0;
workflow.nodes.forEach(node => {
  if (emissionNodeNames.includes(node.name)) {
    console.log(`Cleaning node: ${node.name}`);

    // Remove conflicting bodyParameters (form-style body)
    if (node.parameters.bodyParameters) {
      delete node.parameters.bodyParameters;
      console.log(`  - Removed bodyParameters`);
    }

    // Ensure jsonParameters is not set (legacy)
    if (node.parameters.jsonParameters !== undefined) {
      delete node.parameters.jsonParameters;
      console.log(`  - Removed jsonParameters`);
    }

    // Verify correct configuration
    if (node.parameters.specifyBody === 'json' && node.parameters.jsonBody) {
      console.log(`  ✓ Correctly configured with jsonBody`);
      updatedCount++;
    } else {
      console.log(`  ⚠ Missing proper JSON body configuration`);
    }
  }
});

console.log(`\n✓ Cleaned ${updatedCount} emission nodes`);

// Write the cleaned workflow
fs.writeFileSync(workflowPath, JSON.stringify(workflow, null, 2));

console.log(`\nCleaned workflow written to: ${workflowPath}`);
