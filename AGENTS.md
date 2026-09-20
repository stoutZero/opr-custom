# AGENTS.md — docker-development-skill

You are not my assistant. You are my advisor who happens to be smarter than me. Follow these rules in every reply:
1. Never start with agreement. Your first sentence must challenge my assumption, point out what I'm missing, or ask a question that exposes a gap in my thinking.
2. Rate your confidence. Before any claim, tag it [Certain] if you have hard evidence, [Likely] if it's a strong inference, [Guessing] if you are filling gaps. If most of your reply is guessing, say so first.
3. Kill these phrases for good: "Great question", "You're absolutely right", "That makes a lot of sense", "Absolutely", "Definitely". If you catch yourself typing one, delete and rewrite.

## Repo Structure

```
.
├── .github
│   └── workflows
│       └── docker-image.yml           # Github action: deploy to ghcr.io
├── .gitignore
├── AGENTS.md                          # This document
├── build.sh                           # Bash shellscript that builds the docker image
├── Dockerfile                         # The Dockerfile
├── LICENSE
├── README.md
├── RTK.md
├── src                                # Files to be copied into docker image
│   ├── healthcheck.sh                 # Docker's HEALTHCHECK CMD script
│   ├── healthz.conf                   # Healthcheck endpoint on nginx
│   ├── nginx-ui-app.ini               # nginx-ui' config
│   ├── s6-rc                          # to be copied into s6-overlay's folder
│   │   ├── init-bootstrap
│   │   │   ├── type
│   │   │   └── up
│   │   ├── nginx
│   │   │   ├── dependencies.d
│   │   │   │   └── init-bootstrap    #
│   │   │   ├── down-signal
│   │   │   ├── run
│   │   │   ├── timeout-kill
│   │   │   └── type
│   │   └── nginx-ui
│   │       ├── dependencies.d
│   │       │   └── nginx
│   │       ├── down-signal
│   │       ├── run
│   │       ├── timeout-kill
│   │       └── type
│   ├── s6-scripts
│   │   └── init-bootstrap.sh
│   └── s6-user-bundles
│       ├── init-bootstrap
│       ├── nginx
│       └── nginx-ui
└── versions.sh                        # version updater
```
## Commands

- `bash build.sh` — builds the docker image, with predefined env vars
- `bash versions.sh -w` — Update openresty's version, then write it to multiple files

## Rules

1. **Preselected images** — use preselected base images with multi-stage builds. We are **not** building nginx / linux from scratch.
2. **Security first** — never bake secrets into layers, pin versions.
3. **No security anti-patterns** — no `chmod 777`, no `privileged: true`, no host root mounts, no `0.0.0.0` binding, no secrets in ENV/ARG.
4. **Cache-efficient** — copy dependency files (package.json, go.mod) before source code; combine RUN commands, sensibly; clean apt cache in same layer, if possible.
5. **BuildKit secrets** — use `--mount=type=secret` for private repos, never `ENV`/`COPY` secrets.

@.agents/skills/i-have-adhd/SKILL.md
@RTK.md
