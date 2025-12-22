# Five Crowns – Claude Agent Setup

This folder contains a finite project spec and a multi-agent prompt setup for Claude (or similar LLM tooling).

## What’s inside
- `PROJECT_SPEC.md` – the authoritative spec
- `PROTOCOL.md` – REST + WebSocket contract
- `ARCHITECTURE.md` – infra diagram and port checklist
- `infra/` – docker-compose + Caddy + LiveKit + coturn + Mailpit starter configs
- `agents/` – role prompts for planner/backend/frontend/infra/reviewer/tester
- `tasks/` – backlog & milestones
- `CLAUDE.md` – top-level instructions (useful for Claude Code)

## Suggested workflow
1. Give Claude `PROJECT_SPEC.md` + `PROTOCOL.md` first.
2. Ask it to produce a repo scaffold matching the structure in PROJECT_SPEC.md.
3. Use the agent prompts in `agents/` if you’re running a multi-agent workflow.
4. Keep the wire protocol stable; iterate UI freely.

## Running infra (dev)
Edit `infra/Caddyfile` domains or use localhost reverse-proxying.
Then:
- `cd infra`
- `docker compose up -d`

Mailpit UI: http://localhost:8025
