Ideas to Research
===

Documenting decisions and intent across an Organization. Implementation methods may include 
- Adding Architecture Decision Records (ADRs) to Git for context
- [Spec-Driven Development](#spec-driven-development-sdd)

## Agentic

### Spec-Driven Development (SDD)

| Tool | Approach | Pros | Cons |
|------|----------|------|------|
| [BMAD-METHOD](https://github.com/bmad-code-org/BMAD-METHOD) | Simulated agile team of role agents (Analyst, PM, Architect, Scrum Master, Dev, QA) driving story files | Covers full lifecycle, ideation through QA<br>Story files carry full context to the dev agent<br>Works across IDEs/agents; expansion packs beyond software<br>Large, active community | Steep learning curve<br>Process/document heavy; overkill for solo or small projects<br>High token usage<br>Fast-moving, breaking changes between major versions |
| [Elephant-Goldfish Model](https://github.com/google/elephant-goldfish-model) | Plugin: the main agent with full context ("elephant") drafts the spec, fresh-context subagents ("goldfish") review it before any code. Brainstorm → draft → review → resolve → implement | Fresh reviewers catch unstated assumptions and blind spots<br>Lite mode for small changes; Bootstrap documents existing codebases; Drift report compares docs to code<br>Works in Claude Code, Codex, Antigravity<br>Apache-2.0 | New (Sep 2026), little community feedback yet<br>Covers design/review, not implementation discipline<br>Review requires an agent that can spawn fresh subagents<br>Hosted by Google but not an officially supported Google product |
| [Git Ship Done (GSD Core)](https://github.com/open-gsd/gsd-core) | Successor to "Get Shit Done" (archived Jun 2026). Each phase: discuss → plan → execute → verify → ship, with heavy work in fresh-context subagents and state kept in `STATE.md`/`CONTEXT.md` | Fights context rot by keeping the main session lean<br>Executes plans in parallel waves; resumes across sessions<br>`/gsd-onboard` for existing codebases<br>Supports many agents (Claude Code, Codex, OpenCode, Copilot, Cursor, etc.); MIT | HN users of the original reported ~10x the tokens of plan mode and much slower runs<br>Rigid, waterfall-like phases; generates many files and questions<br>Overkill for small tasks<br>Must be installed via its `npx` installer |
| [Github Spec-kit](https://github.com/github/spec-kit) | Spec-driven CLI (`specify`) + slash commands: constitution → specify → plan → tasks → implement | Open source, backed by GitHub<br>Agent-agnostic (Claude Code, Copilot, Gemini CLI, Cursor, etc.)<br>Specs/plans live in the repo as Markdown | Heavy ceremony for small changes<br>Verbose generated docs eat context/tokens<br>Geared toward greenfield; brownfield support weaker<br>Needs Python/`uv` |
| [Kiro](https://kiro.dev/) | AWS agentic IDE (Code OSS fork) with built-in specs (requirements → design → tasks), hooks, and steering files | Spec workflow built into the IDE, polished UX<br>Agent hooks automate tasks on file events (tests, docs)<br>Steering files give persistent project context<br>MCP support | Proprietary; ties you to Kiro's IDE/CLI instead of Claude Code<br>Paid tiers with usage limits/credits<br>Model choice limited to what Kiro offers<br>Requires account sign-in |
| [OpenSpec](https://github.com/Fission-AI/OpenSpec) | Lightweight spec-driven CLI + skills: each change gets a proposal, design, spec updates, and tasks before implementation | Works well on existing (brownfield) codebases<br>Shared artifacts standardize team sessions; reviewers can audit code against the spec<br>CLI validates spec structure without spending tokens<br>Agent-agnostic | Specs drift from the code over months<br>Each change produces several AI-sounding Markdown files to review<br>Overhead for small tasks; needs a CLI, not just skills |
| [context-engineering-intro](https://github.com/coleam00/context-engineering-intro) | Claude Code template: `CLAUDE.md` rules + `INITIAL.md` → `/generate-prp` → `/execute-prp` | Lightweight, easy to read and fork<br>Native to Claude Code<br>PRPs include validation gates (tests/lint) | A template, not a maintained tool<br>Claude Code-centric<br>Output quality depends on the examples you supply<br>Less structure for large multi-feature projects |

### Other
- Agent and sub-agent architecture and tasking
   - https://github.com/getpaseo/paseo
- Agentic Harness (likely microVM)
- Lemonade
   - add NPU monitoring
   - add wslc backend
   - fix gemma4-NPU model name
- Claude Skills
   - ponytail
- `draw.io` MCP or SKILL

## Workflow diagram
Example 

<table border="1" cellpadding="8" cellspacing="0" style="border-collapse: collapse; width: 100%;">
  <thead>
    <tr style="background-color: #484f4f;">
      <th>OKRs</th>
      <th>Initiatives</th>
      <th>Product Requirements Documents (PRDs)</th>
      <th>Product Specs</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td rowspan="3">
        <strong>Objective 1</strong><br>
        Improve customer experience
        <ul>
          <li>KR1: Increase retention 15%</li>
          <li>KR2: Reduce onboarding time 30%</li>
        </ul>
      </td>
      <td rowspan="2">
        <strong>Initiative A</strong><br>
        Modernize onboarding
      </td>
      <td>
        <strong>PRD 1</strong><br>
        Simplified onboarding flow
      </td>
      <td>
        <strong>Spec 1</strong><br>
        Account registration
      </td>
    </tr>
    <tr>
      <td rowspan="2">
        <strong>PRD 2</strong><br>
        Self-service account setup
      </td>
      <td>
        <strong>Spec 2</strong><br>
        Identity verification
      </td>
    </tr>
    <tr>
      <td>
        <strong>Initiative B</strong><br>
        Improve customer support
      </td>
      <td>
        <strong>Spec 3</strong><br>
        Account recovery
      </td>
    </tr>
    <tr>
      <td rowspan="3">
        <strong>Objective 2</strong><br>
        Increase platform reliability
        <ul>
          <li>KR1: Achieve 99.99% availability</li>
          <li>KR2: Reduce incidents 40%</li>
        </ul>
      </td>
      <td rowspan="2">
        <strong>Initiative C</strong><br>
        Resiliency engineering
      </td>
      <td rowspan="2">
        <strong>PRD 3</strong><br>
        Fault tolerance &amp; recovery
      </td>
      <td>
        <strong>Spec 4</strong><br>
        Automated failover
      </td>
    </tr>
    <tr>
      <td>
        <strong>Spec 5</strong><br>
        Disaster recovery
      </td>
    </tr>
    <tr>
      <td>
        <strong>Initiative D</strong><br>
        Observability
      </td>
      <td>
        <strong>PRD 4</strong><br>
        Monitoring &amp; alerting
      </td>
      <td>
        <strong>Spec 6</strong><br>
        Alerting rules and dashboards
      </td>
    </tr>
  </tbody>
</table>

## GPU
- [`nvtop`](https://github.com/Syllo/nvtop)
- [`amdsmi`](https://github.com/ROCm/rocm-systems/tree/develop/projects/amdsmi#python-library)

## Gaming
- Logitech G15 software LCD compatibility for modern games, audio bar, etc
