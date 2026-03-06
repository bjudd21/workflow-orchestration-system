#!/usr/bin/env node

/**
 * Update Phase 2 workflow with enhanced interview UI HTML
 */

const fs = require('fs');
const path = require('path');

const workflowPath = path.join(__dirname, '../workflows/Phase 2 — PRD Interview.json');
const htmlPath = path.join(__dirname, '../frontend/interview-ui-enhanced.html');

// Read files
const workflow = JSON.parse(fs.readFileSync(workflowPath, 'utf8'));
const html = fs.readFileSync(htmlPath, 'utf8');

// Find the "Respond - Chat UI" node
const respondNode = workflow.nodes.find(n => n.name === 'Respond - Chat UI');

if (!respondNode) {
  console.error('Error: Could not find "Respond - Chat UI" node in workflow');
  process.exit(1);
}

// Update the responseBody parameter with new HTML
respondNode.parameters.responseBody = html;

// Write back to workflow file
fs.writeFileSync(workflowPath, JSON.stringify(workflow, null, 2), 'utf8');

console.log('✅ Updated Phase 2 workflow with enhanced UI');
console.log(`   Workflow: ${workflowPath}`);
console.log(`   HTML size: ${html.length} characters`);
