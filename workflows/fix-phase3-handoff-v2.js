#!/usr/bin/env node
/**
 * Fix Issue #72: Add handoffs/003-prd-refined.md write to Phase 3 workflow
 *
 * Modifies "Code - Write Versioned PRD" node to also write the handoff file.
 * Handles both root nodes array and activeVersion nodes array.
 */

const fs = require('fs');
const path = require('path');

const workflowPath = path.join(__dirname, 'phase-3-prd-synthesis.json');
const workflow = JSON.parse(fs.readFileSync(workflowPath, 'utf8'));

// New code that writes both files
const newCode = `const fs = require('fs');
const path = require('path');
const data = $input.first().json;

// Write versioned PRD to tasks/
fs.mkdirSync(data.prdDir, { recursive: true });
fs.writeFileSync(data.prdPath, data.prdText, 'utf8');

// Also write to handoffs/003-prd-refined.md
const handoffDir = path.dirname(data.handoffPath);
fs.mkdirSync(handoffDir, { recursive: true });
fs.writeFileSync(data.handoffPath, data.prdText, 'utf8');

return [{
  json: {
    prd_text: data.prdText,
    version: data.version,
    project: data.project,
    prd_path: data.prdPath,
    handoff_path: data.handoffPath
  }
}];
`;

let updateCount = 0;

// Find and update in root nodes array
const writeNodeRoot = workflow.nodes?.find(n => n.name === 'Code - Write Versioned PRD');
if (writeNodeRoot) {
  console.log('✅ Found "Code - Write Versioned PRD" in root nodes');
  console.log('📝 Old code:\n', writeNodeRoot.parameters.jsCode);
  writeNodeRoot.parameters.jsCode = newCode;
  updateCount++;
}

// Find and update in activeVersion nodes array
const writeNodeActive = workflow.activeVersion?.nodes?.find(n => n.name === 'Code - Write Versioned PRD');
if (writeNodeActive) {
  console.log('\n✅ Found "Code - Write Versioned PRD" in activeVersion.nodes');
  console.log('📝 Old code:\n', writeNodeActive.parameters.jsCode);
  writeNodeActive.parameters.jsCode = newCode;
  updateCount++;
}

if (updateCount === 0) {
  console.error('❌ Could not find any "Code - Write Versioned PRD" nodes');
  process.exit(1);
}

// Write back to file
fs.writeFileSync(workflowPath, JSON.stringify(workflow, null, 2), 'utf8');

console.log(`\n✅ Updated ${updateCount} node(s) successfully!`);
console.log('📝 New code:\n');
console.log(newCode);
console.log('📂 Backup saved as: phase-3-prd-synthesis.json.backup');
