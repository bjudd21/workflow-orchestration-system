# Phase 2 Interview Workflow

This workflow orchestrates the requirements gathering process for PRD development. It guides the PRD Interviewer agent through a structured conversation to collect all necessary requirements from stakeholders.

## Workflow Steps

1. **Interview Start** - Begin the structured requirements interview
2. **Interview Progress** - Continue the conversation, asking targeted questions
3. **Coverage Check** - Verify all requirements coverage areas are addressed
4. **Interview Complete** - Finalize the interview and signal completion
5. **Transition to Synthesis** - Move to the PRD Synthesis phase

## Requirements

- PRD Interviewer agent with stakeholder-interview and requirements-engineering skills
- Integration with Phase 1 Analysis workflow (dependency)
- Completion signal `INTERVIEW_COMPLETE` to indicate interview completion

## Outputs

- Structured interview data covering all 8 coverage areas
- Coverage status indicating completeness
- Completion signal for workflow transition