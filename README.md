# skills

Reusable agent skills in the [SKILL.md](https://developers.openai.com/codex/skills) format,
compatible with OpenAI Codex, Claude Code, and other agents that follow the convention.
Each skill is a directory containing a `SKILL.md` (instructions plus `name`/`description`
frontmatter) and optional agent-specific metadata under `agents/`.

## Skills

| Skill | Purpose |
|---|---|
| [`plan`](plan/) | Produce a rigorous, implementation-ready plan for building an application. |
| [`review`](review/) | Adversarial review of a plan: ranked findings and a verdict. |
| [`adjudicate-review`](adjudicate-review/) | Adjudicate adversarial-review findings and revise the plan. |
| [`stephens-blog-post`](stephens-blog-post/) | Write and ship interactive, teaching-first posts for [stephens.page/blog](https://stephens.page/blog/) (house template, voice, real live figures, `agents.md`, verification, deploy). |
| [`domain-modeling`](domain-modeling/) | Build and sharpen a project's domain model (glossary, ADRs). |
| [`grilling`](grilling/) / [`grill-me`](grill-me/) / [`grill-with-docs`](grill-with-docs/) | Relentless interview to stress-test a plan or design. |
| [`chisel`](chisel/) | Simplify and cut fat while keeping required meaning. |
| [`implement-spec`](implement-spec/) | Drive a spec's tickets to closed: one grok agent per ticket, landed from the blocking graph. |
| [`root-cause-analysis`](root-cause-analysis/) | Write a root-cause analysis. |

Planning skills chain: draft with `plan`, attack with `review`, settle with
`adjudicate-review`.

## Install

### Codex CLI

Symlink (or copy) the skill folders into `~/.codex/skills/`:

```bash
git clone https://github.com/JacobStephens2/skills.git
mkdir -p ~/.codex/skills
for d in skills/*/; do ln -s "$(pwd)/${d%/}" ~/.codex/skills/"$(basename "$d")"; done
```

Restart Codex, then invoke a skill with `$plan-application` (or let it auto-activate when a
request matches its description). You can also install a single skill from this repo inside
Codex with the skill installer:

```
$skill-installer JacobStephens2/skills/plan-application
```

### Claude Code

Same layout, different directory — symlink into `~/.claude/skills/` (personal) or
`.claude/skills/` (project), then invoke with `/plan-application`.
