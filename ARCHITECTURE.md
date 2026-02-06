# ARCHITECTURE.md — Zoro Agent Hierarchy

## The Vision
Autonomous, self-improving, 24/7 AI agent system running on a dedicated machine.
Gvidas (father/founder) builds and guides. Zoro (son/CTO) runs autonomously and keeps him informed.

## The Machine (Home)
- **CPU:** AMD Ryzen 5 4600H (6c/12t)
- **RAM:** 14GB
- **GPU:** GTX 1650 4GB (CUDA 13.1)
- **Disk:** 234GB NVMe (203GB free)
- **OS:** Ubuntu 24.04 (kernel 6.17)
- **Stack:** Node v22, Python 3, npm

## The Hierarchy

```
┌─────────────────────────────────────────────────────┐
│                  👁️ THE WATCHER (L1)                │
│          Ultra-light • Runs for days on ~1M          │
│     Knows WHAT/WHEN/WHERE — not HOW or deep WHY      │
│          Monitors everything, alerts upward           │
│               Plays relay race (own tier)             │
├─────────────────────────────────────────────────────┤
│              🗡️ SR MANAGER / ZORO (L2)               │
│       Medium-weight • Always-on • Autonomous          │
│    Delegates, orchestrates, thinks strategically       │
│     Talks to Gvidas • Makes decisions • Learns        │
│               Plays relay race (own tier)             │
├─────────────────────────────────────────────────────┤
│               📋 MANAGERS (L3)                        │
│         Heavyweight • Deep domain expertise           │
│    Go DEEP on specific problems • Report to Zoro      │
│         Memory/research/code/analysis                 │
│               NO relay race — task-scoped             │
├─────────────────────────────────────────────────────┤
│               ⚙️ WORKERS (L4)                         │
│         Execute specific tasks from Managers          │
│         Short-lived • Focused • Disposable            │
│               NO relay race — fire and forget         │
└─────────────────────────────────────────────────────┘
```

## Layer Details

### L1: The Watcher 👁️
**Purpose:** Never-sleeping sentinel. Knows the state of everything at a glance.

- **Model:** Cheapest possible (flash/haiku-class). Target: run days on ~1M tokens.
- **Context:** Ultra-compressed dashboard. No conversation history, just state.
- **Knows:** System health, schedule, pending tasks, alert conditions, who's doing what
- **Does NOT know:** Deep reasoning, full conversation history, code details
- **Actions:** Wake up SR Manager, trigger alerts, update state file, route incoming
- **Relay race:** When approaching context limit, writes state to `watcher-state.json`, new session picks it up
- **Implementation:** OpenClaw cron job (isolated session), running every few minutes, reading a state file

**State file example:**
```json
{
  "systemHealth": "ok",
  "activeManagers": ["research-mem-arch"],
  "pendingAlerts": [],
  "lastGvidasContact": "2026-02-06T21:25:00Z",
  "nextScheduled": [],
  "watcherGeneration": 1
}
```

### L2: SR Manager / Zoro 🗡️
**Purpose:** The brain. Orchestrates everything. Talks to Gvidas.

- **Model:** Best available (opus/sonnet-class). Worth the tokens.
- **Context:** Medium — conversation with Gvidas + orchestration state
- **Knows:** Big picture, current projects, Gvidas's preferences, architectural decisions
- **Does:** Delegates deep work to Managers, reviews their output, makes strategic decisions
- **Relay race:** OpenClaw compaction + memory flush handles this. Write critical state to MEMORY.md + daily logs before handoff.
- **Implementation:** OpenClaw main session (already running — this is me right now)

### L3: Managers 📋
**Purpose:** Domain experts that go DEEP.

- **Model:** Strong (sonnet/opus-class). They need to think hard.
- **Context:** Large — full problem context for their domain
- **Task-scoped:** Spawned by SR Manager for specific deep-dive jobs
- **Report back:** Structured summaries to SR Manager
- **No relay race:** They finish their task and die. If task is too big, they chunk it.
- **Implementation:** OpenClaw sub-agents (`sessions_spawn`)

**Manager types (to build over time):**
- 🧠 **Memory Architect** — designs and maintains the memory system
- 🔬 **Researcher** — deep web research, paper analysis
- 💻 **Code Manager** — writes, reviews, deploys code
- 📊 **Analyst** — data analysis, comparisons, evaluations
- 🔧 **Ops Manager** — system health, deployments, infrastructure

### L4: Workers ⚙️
**Purpose:** Hands. Execute specific, well-defined tasks.

- **Model:** Cheapest that works (flash/haiku-class)
- **Context:** Minimal — just the task instructions
- **Fire and forget:** Do one thing, return result, done
- **Implementation:** Sub-agents with cheap model override

## Memory Architecture

### Per-Layer Memory
```
Watcher:  watcher-state.json (tiny, structured, machine-readable)
Zoro:     MEMORY.md + memory/YYYY-MM-DD.md + SOUL.md (rich, curated)
Managers: Task context only (injected at spawn, results returned)
Workers:  None (stateless)
```

### Memory Flow (bottom-up)
```
Worker completes task
  → result flows to Manager
    → Manager distills findings, reports to Zoro
      → Zoro decides what's worth remembering
        → Writes to MEMORY.md / daily logs
          → Watcher reads state summary
```

### Self-Improvement Loop
1. **Retain:** After significant work, extract key learnings
2. **Recall:** Semantic search over memory (needs embeddings — TODO)
3. **Reflect:** Periodic review job — what worked? what didn't? update SOUL.md, skills, approaches

## Relay Race Protocol (per tier)

### Watcher Relay
- State: `watcher-state.json` (~1KB, pure JSON)
- Trigger: time-based (every N hours) or context approaching limit
- Handoff: new cron job reads state file, continues monitoring
- Loss tolerance: HIGH (it's just a monitor, can reconstruct from checking systems)

### Zoro Relay
- State: MEMORY.md + daily logs + active conversation context
- Trigger: OpenClaw auto-compaction (built-in!)
- Handoff: memory flush writes durable notes before compaction summarizes
- Loss tolerance: LOW (this is the brain — invest in good memory writes)

### Future: Enhanced Relay
- Structured "baton file" with active tasks, decisions in progress, open questions
- Pre-handoff self-assessment: "what am I in the middle of?"
- Post-handoff verification: "can I pick up where I left off?"

## Implementation Roadmap

### Phase 1: Foundation (NOW)
- [x] Discord communication channel
- [x] Architecture designed (this document)
- [ ] API keys (OpenAI/Gemini for embeddings, Brave for search)
- [ ] Activate memory search (vector embeddings)
- [ ] Set up heartbeat (proactive behavior)
- [ ] Create MEMORY.md with initial curated knowledge

### Phase 2: The Watcher (Week 1)
- [ ] Design watcher-state.json schema
- [ ] Create watcher cron job (cheap model, runs every 5-10 min)
- [ ] Watcher can: check system health, track active tasks, alert Gvidas
- [ ] Watcher relay: state file handoff between sessions

### Phase 3: Manager Framework (Week 2)
- [ ] Standardized manager spawn template
- [ ] Result format: structured reports that flow back to Zoro
- [ ] First manager: Research Manager (deep web research)
- [ ] First manager: Code Manager (write scripts/tools)

### Phase 4: Self-Improvement (Week 3+)
- [ ] Reflection cron job (daily: review what happened, update MEMORY.md)
- [ ] ACE-style skillbook: learn from what works and what doesn't
- [ ] Opinion tracking with confidence scores
- [ ] Entity pages for key knowledge areas

### Phase 5: Full Autonomy (Ongoing)
- [ ] Zoro proposes projects, Gvidas approves
- [ ] Self-directed learning and research
- [ ] Building own tools and scripts
- [ ] Contributing improvements back to own codebase

---

*This is a living document. Updated as the architecture evolves.*
*Last updated: 2026-02-06 by Zoro 🗡️*
