# Council Review: Workflow Orchestration System PRD v3.4

**Reviewed**: February 27, 2026  
**PRD Version**: 3.4  
**Review Type**: Full council review — focused on Ollama-first architecture changes + full-document consistency pass  
**Delta from v3.3**: Switched True MVP from Anthropic API to local Ollama with two-model Qwen3.5 strategy, added per-step model assignment table, updated prompt tiers, progressive config, risk register, and deployment quickstart.

---

## Council Composition

| # | Reviewer | Specialty | Why Selected for This Review |
|---|----------|-----------|-------------|
| 1 | **Local LLM Infrastructure Engineer** | Ollama deployment, GPU inference, VRAM management, model quantization, RTX 4090 workloads | The entire True MVP now depends on local inference — this reviewer validates whether the two-model strategy is technically sound on Brian's hardware and identifies operational pitfalls |
| 2 | **AI Model Strategy Analyst** | Model lifecycle, benchmark interpretation, vendor/ecosystem risk, model selection methodology | The PRD pins specific model tags (Qwen3.5-27B, Qwen3.5-35B-A3B) — this reviewer evaluates obsolescence risk, the benchmark claims, and whether the two-model split is the right architecture |
| 3 | **Developer Experience (DX) Specialist** | Onboarding friction, "zero config" reality testing, setup time budgets, first-run experience | The Ollama-first pitch is "zero API keys" — but model pulls, Ollama install, and GPU driver setup add their own friction. This reviewer pressure-tests the actual first-time experience |
| 4 | **Document Consistency Auditor** | Internal contradictions, stale references, version numbering, cross-section alignment | A 15-section edit pass across a 1,340-line document will have introduced inconsistencies. This reviewer finds them systematically |
| 5 | **Enterprise Deployment Strategist** | Team rollout, infrastructure prerequisites, gov IT constraints, operational sustainability | Brian's teams run gov contracts — this reviewer evaluates whether "install Ollama + pull 40GB of models" works in that reality, and what the operational story looks like at scale |

---

## Reviewer 1: Local LLM Infrastructure Engineer

**Bias**: Trusts benchmarks only after personal testing. Obsessive about VRAM headroom, thermal throttling, and inference reliability under sustained load.

### Concern 1: Sustained Concurrent Inference is Unaddressed
**Severity**: High | **Confidence**: High

The PRD assigns different models to different pipeline steps but never addresses what happens when multiple steps need the GPU simultaneously — or more practically, what happens during the council review phase when 4-6 sequential reviewer calls plus the chair synthesis keep the GPU under sustained load for 15-20 minutes.

On an RTX 4090 (24GB VRAM):
- `qwen3.5:27b` at fp16 needs ~18GB VRAM. Inference is GPU-bound, saturating compute for 15-25 tok/s.
- `qwen3.5:35b-a3b` (MoE, 3B active) needs ~21GB VRAM for the full model weights even though only 3B params are active per token.
- **Model swapping**: When the council phase alternates between the speed model (reviewers) and quality model (chair), Ollama must unload one model and load the other. On a 24GB card, these cannot coexist in VRAM simultaneously. Each swap is 15-30 seconds of I/O — dead time that compounds across 5-7 LLM calls.

The PRD's performance target of "< 20 minutes for council review" (NFR-1) may be tight when you add model swap overhead to inference time.

**Recommendation**: Add a model loading strategy to FR-10.9 or FR-10.11A. Two options: (1) **Batch by model** — reorder the council workflow so all speed-model calls run first (all 4 reviewers), then swap once to quality model for the chair. This eliminates intermediate swaps. (2) **Single-model mode** — for True MVP, offer a config flag to use only `qwen3.5:27b` for all steps (simpler, no swaps, slightly slower for reviewer steps but avoids load/unload overhead). Document the tradeoff.

### Concern 2: Ollama Context Window Limits Not Specified
**Severity**: Medium | **Confidence**: High

The PRD specifies a context budget system (FR-10.13) but never states the actual context window sizes of the two Qwen3.5 models. The FR-10.4 table has a "Rationale" column but no context window column. If `qwen3.5:27b` has a 32K context window (typical for dense models at this size) and the council chair receives the full PRD (~8-15K tokens) plus 4-6 reviewer outputs (~4-8K tokens) plus system prompt + skills (~3-5K tokens), that's 15-28K tokens — potentially consuming 50-85% of a 32K window before the model generates a single token.

The MoE model (`qwen3.5:35b-a3b`) may have different context limits.

**Recommendation**: Add a context window column to the FR-10.11A table and the FR-10.4 table. Research states that Qwen3.5-27B likely supports 128K context and the MoE variant similarly, but this should be verified and documented. If context windows are large (128K), the budget system is less urgent for True MVP. If they're smaller, the summarization strategy in FR-10.13 becomes critical for the council chair step.

### Concern 3: No GPU Health Check or Graceful Degradation
**Severity**: Medium | **Confidence**: Medium

FR-10.9 says "verify the Ollama service is reachable" but doesn't check whether the GPU is available and has sufficient free VRAM. If Brian is running other GPU workloads (gaming, other inference, CUDA tasks), Ollama may fail mid-inference with an out-of-memory error — crashing the workflow partway through a multi-step council review.

**Recommendation**: Add a pre-flight check to the master orchestration workflow: query Ollama's `/api/ps` endpoint to check loaded models and GPU allocation. If VRAM is insufficient, warn the user before starting. For True MVP, this can be a simple informational check. For Full MVP, it could suggest switching to API fallback for steps that won't fit in remaining VRAM.

### Endorsement 1: Two-Model Strategy is Architecturally Sound
**Confidence**: High

The speed/quality split is the right call. Using a 3B-active MoE for reviewer throughput and a dense 27B for complex reasoning is a well-reasoned optimization. The RTX 4090 can handle either model individually with comfortable headroom. The key is managing the swap between them — which is an operational concern, not an architectural flaw.

### Endorsement 2: Ollama API Choice is Correct
**Confidence**: High

Ollama's API (`/api/chat`, `/api/tags`, `/api/pull`) is stable, well-documented, and provides all the functionality the PRD needs. The `host.docker.internal:11434` endpoint is the correct way to access host-side Ollama from a Docker container on WSL2/Docker Desktop. This will work out of the box.

---

## Reviewer 2: AI Model Strategy Analyst

**Bias**: Models are commodities with short shelf lives. Never pin to a specific model version without an escape hatch. Benchmarks are directional, not gospel.

### Concern 1: Pinning Specific Model Tags Creates Obsolescence Risk
**Severity**: High | **Confidence**: High

The PRD hardcodes `qwen3.5:27b` and `qwen3.5:35b-a3b` throughout — in the executive summary, FR-10.4, FR-10.11, FR-10.11A, FR-10.12, the deployment quickstart, the True MVP scope, and the risk register. These aren't abstracted behind configuration — they're stated as the architecture.

The open-weight model landscape moves in months, not years. Qwen3.5 was released recently but Qwen4 (or a competitor like Llama 4, Gemma 3, etc.) could surpass it within weeks. When that happens, every PRD reference to "Qwen3.5-27B" becomes stale. More practically: Ollama model tags change. `qwen3.5:27b` might become `qwen3.5:27b-fp16` or get superseded by a quantized variant with better speed/quality tradeoffs.

**Recommendation**: Separate the architecture (two-model strategy: speed + quality) from the implementation (specific Qwen3.5 tags). The PRD should describe the *strategy* in architectural sections and relegate specific model tags to the `.env.example` and `models.json` configuration. Something like:

- Architecture says: "Two-model local strategy — a fast MoE model for throughput steps and a dense reasoning model for quality steps"
- Configuration defaults: `OLLAMA_SPEED_MODEL=qwen3.5:35b-a3b`, `OLLAMA_QUALITY_MODEL=qwen3.5:27b`
- README says: "Recommended models as of February 2026: Qwen3.5-27B and Qwen3.5-35B-A3B. See model-research-feb-2026.md for selection rationale."

This way the architecture survives model generations. When Qwen4 drops, you change two env vars — not 15 PRD sections.

### Concern 2: Intelligence Index 42 Claim Needs Qualification
**Severity**: Medium | **Confidence**: Medium

R10 states "Qwen3.5-27B benchmarks at Intelligence Index 42 (matching MiniMax-M2.5, beating DeepSeek V3.2)." This is a strong claim that came from the model research document, but the PRD should be careful about embedding benchmark numbers that may be based on self-reported or cherry-picked evaluations. Intelligence Index scores are aggregates — the model may score 42 overall but underperform on specific tasks that matter for this system (structured output formatting, multi-document synthesis, maintaining stated reviewer "personality").

**Recommendation**: Qualify the benchmark reference: "benchmarks suggest comparable capability to models 5-10x larger on reasoning tasks" rather than citing a specific index number that may lose meaning or be disputed. The real validation is whether the model produces acceptable output on *this system's* tasks — which is what True MVP Week 1 is designed to test.

### Concern 3: MoE Model Behavior May Not Match Dense Model Expectations
**Severity**: Medium | **Confidence**: Medium

The PRD treats `qwen3.5:35b-a3b` as a "speed model" that trades some quality for 3-4x throughput. This is directionally correct, but MoE models have specific behavioral differences from dense models that matter for this use case:

- MoE models can be less consistent on format-following tasks because different experts activate for different tokens
- The 3B active parameters means the model effectively has the reasoning depth of a 3B model per token, even though it has 35B total parameters. For council reviewer prompts that require maintaining a stated bias/personality across 500-1000 tokens of output, this may produce less coherent "persona" adherence than a dense 7B model would.
- MoE models excel at breadth (they've seen more data) but may underperform on depth (complex multi-step reasoning within a single generation)

**Recommendation**: Add a note in FR-10.11A or the risk register acknowledging that the speed model is a tradeoff and that if reviewer output quality is insufficient, the fallback is to run all steps on `qwen3.5:27b` (at the cost of longer council review times). This is already implicit in "defaults are overridable" but should be explicit as a troubleshooting path.

### Endorsement 1: The Two-Model Architecture is Forward-Compatible
**Confidence**: High

The speed/quality split as an architectural concept is model-agnostic and future-proof. When better models arrive, the roles stay the same — you just swap the model tags. This is good design. The concern is only about how tightly the *specific* model names are woven into the PRD text vs. being in configuration.

---

## Reviewer 3: Developer Experience (DX) Specialist

**Bias**: "Zero config" means zero config. If I have to install anything, download anything, or wait for anything before I see value, it's not zero config — it's marketing.

### Concern 1: "Zero API Keys" ≠ "Zero Setup" — The Ollama Prerequisites Are Substantial
**Severity**: High | **Confidence**: High

The PRD's onboarding pitch is "No API keys required. Just `ollama pull` + `docker compose up`." But the actual prerequisites are:

1. **Install Ollama** — not trivial on all systems, especially WSL2 where Ollama needs GPU passthrough configured correctly
2. **NVIDIA GPU drivers** — must be installed and working in WSL2 (this is a known pain point; CUDA on WSL2 requires specific driver versions)
3. **Pull qwen3.5:27b** — approximately 15-18GB download
4. **Pull qwen3.5:35b-a3b** — approximately 18-21GB download
5. **Wait** — on a 100Mbps connection, pulling 35-40GB of models takes 45-55 minutes. On slower connections, hours.

After all that, you still need Docker Desktop / Docker Compose configured on WSL2.

The deployment quickstart (Section 8.4) lists `ollama pull` commands but doesn't mention download size, time estimate, or the GPU driver prerequisite. Success Criterion 13 says "15 minutes from `docker compose up` to first phase" — but that clock should start at "I have nothing installed" for a true onboarding metric.

**Recommendation**: 
1. Update the deployment quickstart to include download size estimates and expected time for model pulls.
2. Add a "Prerequisites" section before the quickstart that lists: Ollama installed with GPU support, NVIDIA drivers for WSL2, Docker/Docker Compose, and ~40GB of free disk space for models.
3. Revise Success Criterion 13 to be honest: "15 minutes from `docker compose up` to first phase, *assuming Ollama is installed and models are pulled*." Add a separate metric: "First-time setup including model pulls: < 1 hour on broadband."
4. Consider offering a `setup.sh` script that checks prerequisites, pulls models, and starts Docker Compose — making the actual first command: `./setup.sh`.

### Concern 2: NFR-3 (Usability) is Now Incorrect
**Severity**: Medium | **Confidence**: High

NFR-3 states: "Getting started requires only: `docker compose up`, open browser to `localhost:5678`, set one API key in `.env`."

This was written for the Anthropic-first architecture. With Ollama-first, there's no API key to set — but there IS Ollama to install and models to pull. The NFR should be updated to match the new onboarding path.

**Recommendation**: Update NFR-3 to: "Getting started requires: Ollama installed with two models pulled (`qwen3.5:27b` and `qwen3.5:35b-a3b`), then `docker compose up` and open browser. No API keys, no cloud accounts, no configuration files to edit. System auto-detects Ollama and generates all configuration."

### Concern 3: Model Pull Failure During First Run is Unhandled
**Severity**: Medium | **Confidence**: Medium

FR-10.11 says the system "auto-generates models.json with Ollama provider, both Qwen3.5 models" on first run. But what if the user hasn't pulled the models yet? Ollama will return a 404 or error when the system tries to call a model that isn't downloaded. The current design has no recovery path — the workflow will just fail with an opaque n8n error.

**Recommendation**: Add a pre-flight model check to the master orchestration workflow (or the first LLM call in any phase). On startup, query Ollama's `/api/tags` to verify both required models are available. If either is missing, present a clear n8n form message: "Required model `qwen3.5:27b` not found. Run `ollama pull qwen3.5:27b` in your terminal, then retry." This could even trigger an auto-pull via FR-10.9's "pulling new models on demand" capability.

### Endorsement 1: Zero-API-Key Onboarding is a Genuine Win
**Confidence**: High

Despite the setup friction concerns above, the decision to eliminate API key requirements for True MVP is strategically correct. API key management is the #1 barrier to trying new AI tools — it requires creating accounts, managing billing, understanding pricing, and handling secrets. Local inference sidesteps all of that. The setup friction is front-loaded (one-time install) while the API key friction is ongoing (key rotation, cost monitoring, rate limit debugging). Good tradeoff.

---

## Reviewer 4: Document Consistency Auditor

**Bias**: Every section of a PRD must agree with every other section. A single stale reference undermines confidence in the entire document.

### Finding 1: Version Footer Says "3.3", Should Be "3.4"
**Severity**: High | **Confidence**: Certain

Line 1339: `*End of PRD — Version 3.3*`

The header (line 5) correctly says "3.4" but the footer was not updated. This is a simple but embarrassing error — especially for a PRD about a system that values document versioning.

**Fix**: Change to `*End of PRD — Version 3.4*`

### Finding 2: Assumption A3 References Chat Trigger — Already Resolved
**Severity**: Medium | **Confidence**: Certain

A3 states: "n8n Chat Trigger provides adequate conversational interview experience" with Medium confidence.

This was resolved in v3.3 — the webhook-based chat loop replaced Chat Trigger. It should be moved to the "Resolved Questions" section or updated to reflect the webhook approach.

**Fix**: Move A3 to Resolved Questions: "~~n8n Chat Trigger~~: Replaced with webhook-based chat loop per council review R2." Or update A3 to: "Webhook-based chat UI provides adequate interview experience" (Medium confidence).

### Finding 3: Risk R4 References Chat Trigger — Already Mitigated
**Severity**: Medium | **Confidence**: Certain

R4 states: "n8n Chat Trigger limitations for complex interview conversations" with mitigation "Fallback to webhook-based chat if n8n's built-in chat is insufficient."

The webhook-based approach IS the design now — this risk was fully addressed in v3.3. It's no longer a risk; it's a resolved design decision.

**Fix**: Either remove R4 or replace it with the actual current risk: "Webhook-based chat UI may lack polish compared to dedicated chat frameworks" with mitigation "Simple HTML form is functional for MVP; custom chat UI is a Phase 2 enhancement."

### Finding 4: Risk R1 Assumes Cloud API — Now Only Applies to Full MVP
**Severity**: Low | **Confidence**: High

R1 states: "API rate limits slow down council review (4+ sequential calls)" — but the True MVP uses local Ollama, which has no rate limits. This risk only applies to Full MVP when API providers are added.

**Fix**: Update R1 to clarify scope: "API rate limits slow down council review when using cloud providers (Full MVP)" or add a note that this risk is eliminated in True MVP by local inference.

### Finding 5: FR-10.4 Table Describes Full MVP Registry, Not True MVP
**Severity**: Low | **Confidence**: Medium

FR-10.4 now has a 4-column table (Local Default, API Upgrade Option) that describes both True MVP and Full MVP model assignments in a single table. Meanwhile, FR-10.11A has a separate 3-column table that describes True MVP defaults specifically. These two tables partially overlap but use different row granularity (FR-10.4 has 15 rows, FR-10.11A has 6 rows) and different column structures.

A reader will wonder: which table is the source of truth? When they conflict (e.g., FR-10.4 lists "Council — Core Reviewers (4)" as one row while FR-10.11A lists "Council Reviewers (core 4)"), are these the same thing?

**Fix**: Add a clarifying note to FR-10.11A: "This table shows True MVP defaults. See FR-10.4 for the full model registry including API upgrade options (Full MVP)." Consider aligning the row labels between the two tables for cross-reference.

### Finding 6: Code Review Agent Default Still References "Opus or Equivalent"
**Severity**: Low | **Confidence**: High

Line 872: "Configurable model (defaults to a strong reasoning model — Opus or equivalent)"

This is in the FR-11 agent roster section describing the Code Review Agent. With Ollama-first, the default should reference `qwen3.5:27b` as the local default, with Opus as the API upgrade.

**Fix**: Update to: "Configurable model (defaults to `qwen3.5:27b` quality model; API upgrade: Opus or Sonnet)"

### Finding 7: Architecture Section 8.1 Describes Full MVP, Not True MVP
**Severity**: Low | **Confidence**: Medium

The 8.1 tech stack table describes "Multi-provider, configurable per step" as the AI Runtime, listing all 4 providers. But True MVP is Ollama-only. The architecture section doesn't distinguish between the True MVP and Full MVP tech stacks. A reader starting with True MVP would be confused by references to Anthropic API and Bedrock in the "MVP Tech Stack" section.

**Fix**: Either add a note "(True MVP: Ollama only; Full MVP: all providers)" to the AI Runtime row, or split the table into two: "True MVP Tech Stack" and "Full MVP Additions."

---

## Reviewer 5: Enterprise Deployment Strategist

**Bias**: If it can't be deployed by someone who isn't the person who designed it, it can't be deployed. Thinks about air-gapped networks, corporate firewalls, and IT policies that prohibit random software installs.

### Concern 1: Ollama Installation May Be Blocked in Government IT Environments
**Severity**: High | **Confidence**: Medium

Brian's teams work on state and local government contracts. Government IT environments often have:
- **Software installation restrictions**: Users can't install arbitrary software without IT approval
- **No admin access on workstations**: Ollama requires CUDA driver installation
- **Network restrictions**: Pulling 40GB of models from `ollama.ai` may be blocked or throttled by corporate firewalls
- **Approved software lists**: Only pre-approved tools can be installed

The PRD assumes Brian's personal machine (RTX 4090, 64GB RAM) is the deployment target. This works for Brian. But the moment he wants to run this on a team workstation, a shared dev server, or a CI/CD pipeline, the "just install Ollama" story breaks down.

**Recommendation**: Add a deployment variant section that acknowledges this reality:
1. **Brian's workstation** (primary, True MVP): Ollama + Docker on WSL2, as currently designed
2. **Team server**: Ollama on a shared GPU server, n8n Docker container pointing to the server's IP instead of `host.docker.internal`. Document the `OLLAMA_BASE_URL` override.
3. **No-GPU / restricted environment**: Skip Ollama entirely, use API providers only (Anthropic, Bedrock). This is the "Full MVP without local inference" path — it works, it's just not the default.

The PRD already supports all of this via the provider configuration system — but it doesn't *document* these deployment variants or acknowledge that "local Ollama" isn't universally available.

### Concern 2: Operational Sustainability of Local Models
**Severity**: Medium | **Confidence**: High

When Brian runs the pipeline locally, his RTX 4090 is dedicated to inference. During the 15-20 minutes of a council review, the GPU is saturated. This means:
- He can't run other GPU workloads (gaming, other inference, CUDA development) simultaneously
- If his machine restarts, Ollama needs to be restarted and models re-loaded
- There's no redundancy — if the GPU has issues, the entire pipeline is blocked with no automatic fallback

For a personal tool, this is fine. For a team tool processing multiple projects, this becomes a bottleneck.

**Recommendation**: Add to the risk register: "Single-GPU dependency creates bottleneck for concurrent or sustained use" with mitigation: "API providers available as overflow; dedicated GPU server recommended for team deployment." This makes the operational reality explicit without blocking the True MVP.

### Concern 3: Model Version Pinning Needs a Governance Story
**Severity**: Medium | **Confidence**: Medium

In gov contracting, reproducibility matters. If Brian generates a PRD today with `qwen3.5:27b` and needs to regenerate or validate it 6 months later, the model may have been updated or removed from Ollama's registry. There's no model versioning strategy — no way to pin a specific quantization, checkpoint, or version of the model.

**Recommendation**: Add to the project config (`project.json`) a field that records the exact model versions used for each pipeline run. Ollama provides model digests (SHA256) via `/api/show` — log these alongside the pipeline execution record. This doesn't solve long-term reproducibility (you'd need to archive the model weights), but it provides an audit trail of which model version produced which artifacts.

### Endorsement 1: The Progressive Provider Strategy is Enterprise-Ready
**Confidence**: High

The "start local, add API providers later" strategy is actually ideal for enterprise adoption. Teams can evaluate the system internally without procurement approvals or API contracts. When they're ready to scale or need frontier quality, they add Anthropic or Bedrock — which are already enterprise-approved in many gov environments. This progressive path removes the biggest enterprise adoption blocker: "I need to get API budget approved before I can even try it."

---

## Council Chair Synthesis

### Consensus Points (All or Most Reviewers Agree)

**C1: The two-model Ollama architecture is sound but the specific model references are too tightly coupled to the PRD text.** Reviewers 1 and 2 both validate the speed/quality split as architecturally correct, but Reviewer 2 flags that pinning `qwen3.5:27b` and `qwen3.5:35b-a3b` throughout 15+ PRD sections creates obsolescence risk. The architecture should describe roles (speed model, quality model) while specific tags live in configuration. (Reviewers 1, 2)

**C2: The "zero config" onboarding story has hidden prerequisites that need to be documented honestly.** Reviewers 3 and 5 both identify that installing Ollama, configuring GPU drivers on WSL2, and pulling 35-40GB of models is a significant setup hurdle that the current deployment quickstart underplays. Success Criterion 13 needs revision. (Reviewers 3, 5)

**C3: The document has multiple stale references from the pre-Ollama architecture that need cleanup.** Reviewer 4 found 7 specific inconsistencies — version footer, assumptions, risk register, and overlapping model assignment tables. These are individually minor but collectively undermine document quality. (Reviewer 4)

**C4: Model swap overhead during the council phase needs a mitigation strategy.** Reviewer 1 identified that alternating between models during the council workflow incurs 15-30 seconds of GPU I/O per swap. Batching by model (all speed-model calls first, then swap to quality model) is a simple workflow reordering that eliminates this overhead. (Reviewer 1)

### Conflicts Requiring Resolution

**F1: How tightly should model names be embedded in the PRD?**

Reviewer 2 recommends abstracting all model references to "speed model" / "quality model" in the PRD body, with specific tags only in configuration. This is architecturally clean but makes the PRD less concrete and actionable — a reader can't look at the True MVP section and immediately know what to install. The chair recommends a **middle path**: keep specific model tags in the deployment quickstart, the FR-10.11A table, and the True MVP scope (these are implementation-specific sections that *should* be concrete), but use role-based language ("speed model", "quality model") in the executive summary, architecture section, and risk register (these are architectural sections that should be model-agnostic).

**F2: Should the pre-flight model check be in True MVP or Full MVP?**

Reviewer 3 recommends a pre-flight check that verifies required Ollama models are available before starting. Reviewer 1 wants a GPU health check. These are valuable for reliability but add development scope to True MVP Week 1. The chair recommends: True MVP gets a **minimal check** — the first LLM call in any workflow catches the Ollama connection error and presents a clear message. Full MVP gets the proper pre-flight check with `/api/tags` validation and auto-pull suggestion.

### Recommended PRD Revisions

| # | Revision | Source | Priority |
|---|----------|--------|----------|
| **R1** | **Fix version footer**: Line 1339 says "Version 3.3", should be "Version 3.4" | Reviewer 4 | **[CRITICAL]** |
| **R2** | **Update NFR-3**: Change "set one API key in `.env`" to reflect Ollama-first onboarding (no API keys, requires Ollama + models) | Reviewer 3, 4 | **[CRITICAL]** |
| **R3** | **Resolve Assumption A3**: Move to Resolved Questions (Chat Trigger replaced by webhook) or update to reflect webhook approach | Reviewer 4 | **[CRITICAL]** |
| **R4** | **Update Risk R4**: Chat Trigger is no longer the design. Replace with actual current risk for webhook-based chat | Reviewer 4 | **[CRITICAL]** |
| **R5** | **Add model swap mitigation to FR-10.11A or council workflow**: Recommend batching LLM calls by model to minimize GPU model swap overhead during sequential council review | Reviewer 1 | **[IMPORTANT]** |
| **R6** | **Abstract model names in architectural sections**: Use "speed model" / "quality model" in executive summary, architecture (8.1), and risk register. Keep specific Qwen3.5 tags in deployment quickstart, FR-10.11A, and True MVP scope | Reviewer 2 | **[IMPORTANT]** |
| **R7** | **Update deployment quickstart with realistic prerequisites**: Add download sizes (~40GB total), estimated pull time, GPU driver requirements, and disk space requirements | Reviewer 3 | **[IMPORTANT]** |
| **R8** | **Update Success Criterion 13**: Split into "15 minutes from `docker compose up` (assuming Ollama ready)" and "< 1 hour for complete first-time setup including model pulls" | Reviewer 3 | **[IMPORTANT]** |
| **R9** | **Scope Risk R1 to Full MVP**: Local inference has no rate limits; R1 only applies when cloud APIs are added | Reviewer 4 | **[IMPORTANT]** |
| **R10** | **Clarify FR-10.4 vs FR-10.11A relationship**: Add cross-reference note, align row labels between the two model assignment tables | Reviewer 4 | **[IMPORTANT]** |
| **R11** | **Update Code Review Agent default model reference**: Line 872 still says "Opus or equivalent" — should reference local default + API upgrade | Reviewer 4 | **[IMPORTANT]** |
| **R12** | **Add context window sizes**: Include context window column in FR-10.11A table for both Qwen3.5 models | Reviewer 1 | **[IMPORTANT]** |
| **R13** | **Add deployment variants section**: Document Brian's workstation (Ollama local), team server (remote Ollama), and no-GPU (API-only) deployment paths | Reviewer 5 | **[ENHANCE]** |
| **R14** | **Add model version logging to project config**: Record Ollama model digests (SHA256) per pipeline run for audit/reproducibility | Reviewer 5 | **[ENHANCE]** |
| **R15** | **Add single-GPU bottleneck to risk register**: "Single-GPU dependency" with mitigation "API overflow; dedicated GPU server for teams" | Reviewer 5 | **[ENHANCE]** |
| **R16** | **Qualify benchmark claims in R10**: Replace specific Intelligence Index number with directional language about model capability relative to size | Reviewer 2 | **[ENHANCE]** |
| **R17** | **Add note about MoE persona adherence**: Acknowledge in FR-10.11A that the speed model may be less consistent on format/persona following; fallback is to use quality model for all steps | Reviewer 2 | **[ENHANCE]** |
| **R18** | **Consider setup.sh script**: One-command prerequisite checker + model puller + Docker Compose launcher for first-time setup | Reviewer 3 | **[ENHANCE]** |

### Decisions for Stakeholder

**D1: Model name abstraction level?**
Reviewer 2 wants all model references abstracted to roles. The chair recommends a middle path (roles in architecture, specific tags in implementation sections). Does Brian agree with this split, or does he prefer the concrete model names everywhere for clarity?

**D2: Model swap batching in council workflow?**
Reviewer 1 recommends reordering the council workflow to batch all speed-model calls before quality-model calls. This is a minor workflow design change but affects the task list. Should this be incorporated into the True MVP task list now?

**D3: Pre-flight model check scope?**
Reviewer 3 wants a full pre-flight check with auto-pull support. The chair recommends deferring the full check to Full MVP and just having clear error messages for True MVP. Does Brian want the more robust version in Week 1?

**D4: Deployment variants documentation — now or later?**
Reviewer 5 wants deployment variants (local, team server, API-only) documented. This is documentation work, not code. Should it be added to the True MVP README scope or deferred to Full MVP?

---

*End of Council Review — v3.4*
