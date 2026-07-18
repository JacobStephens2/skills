# skills

Reusable agent skills in the [SKILL.md](https://developers.openai.com/codex/skills) format,
compatible with OpenAI Codex, Claude Code, and other agents that follow the convention.
Each skill is a directory containing a `SKILL.md` (instructions plus `name`/`description`
frontmatter) and optional agent-specific metadata under `agents/`.

## Skills

| Skill | Purpose |
|---|---|
| [`plan-application`](plan-application/) | Produce a rigorous, implementation-ready plan for building an application, with measurable requirements, verification gates, and rollback paths. |
| [`adversarial-review`](adversarial-review/) | Skeptically stress-test a plan: attack it across correctness, security, feasibility, operations, and more, then deliver ranked findings and a verdict. |
| [`adjudicate-adversarial-review`](adjudicate-adversarial-review/) | Adjudicate the findings of an adversarial review and decide what actually blocks implementation. |

The skills are designed to chain: draft with `plan-application`, attack the draft with
`adversarial-review`, then settle disputed findings with `adjudicate-adversarial-review`.

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
