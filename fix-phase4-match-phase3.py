#!/usr/bin/env python3
"""
Fix Phase 4 to match Phase 3's EXACT working pattern

ROOT CAUSE: Code - Validate Inputs may not be outputting data correctly,
            causing downstream node references to fail

SOLUTION: Simplify Code - Validate Inputs to match Phase 3's exact approach
          - Remove `.body` nesting expectation
          - Expect data directly: {project, action, ...}
"""
import json

with open('workflows/phase-4-council-review.json', 'r') as f:
    workflow = json.load(f)

# Fix Code - Validate Inputs to NOT expect .body wrapper
# n8n webhook POST data comes as {body: {...}} but we'll handle both cases
new_validation_code = """const input = $input.first().json;
const body = input.body || input;  // Handle both wrapped and direct input

const project = (body.project || '').trim().toLowerCase().replace(/\\s+/g, '-');
const action = body.action || 'review';
const reviewNum = body.reviewNum || 1;

if (!project) throw new Error('project required');
if (!['review', 'decide', 'gate'].includes(action)) throw new Error('invalid action');

const wp = `/home/node/workspace/${project}`;
const councilHandoff = reviewNum === 1 ?
  `${wp}/handoffs/004-council-review.md` :
  `${wp}/handoffs/004-council-review-r${reviewNum}.md`;

return [{
  json: {
    project,
    action,
    decision: body.decision || '',
    gateDecision: body.gate_decision || '',
    revisions: body.revisions || '',
    reviewNum,
    wp,
    prdHandoff: `${wp}/handoffs/003-prd-refined.md`,
    councilHandoff,
    prdDir: `${wp}/tasks`,
    promptsDir: '/home/node/prompts',
    skillsDir: '/home/node/skills'
  }
}];"""

for node in workflow['nodes']:
    if node['name'] == 'Code - Validate Inputs':
        print("Updating Code - Validate Inputs to handle both input formats")
        node['parameters']['jsCode'] = new_validation_code

with open('workflows/phase-4-council-review.json', 'w') as f:
    json.dump(workflow, f, indent=2)

print("✅ Done! Code - Validate Inputs now handles both input formats")
print("   - Checks for input.body first (standard webhook)")
print("   - Falls back to input directly (for compatibility)")
