# skills

Reusable agent skills in the [SKILL.md](https://developers.openai.com/codex/skills)
format, compatible with OpenAI Codex, Claude Code, and other agents that follow
that convention.

Skill source lives under `skills/`. Each skill contains a `SKILL.md` with its
name, description, and instructions, plus any supporting scripts or references.
`.agents/skills/` contains skills used while working on this repository;
`skills-lock.json` records vendored dependencies.

## Skills

| Skill | Purpose |
| --- | --- |
| [`granola-transcripts`](skills/granola-transcripts/) | Retrieve Granola meeting transcripts through the API with timestamps and source attribution. |
| [`implement-spec`](skills/implement-spec/) | Complete a specification's tickets in dependency order, using a subagent round per ticket with verification before landing. |

## Install

### Codex

Clone the repository and link its skill directories into your personal skills
folder:

```bash
git clone https://github.com/JacobStephens2/skills.git
cd skills
mkdir -p ~/.codex/skills
for skill in "$PWD"/skills/*/; do
  [ -f "${skill}SKILL.md" ] || continue
  ln -s "${skill%/}" "$HOME/.codex/skills/$(basename "$skill")"
done
```

Invoke a skill by name, for example `$granola-transcripts` or `$implement-spec`.
Granola transcript retrieval uses `GRANOLA_API_KEY` from the environment.

### Claude Code

Link the same source directories into `~/.claude/skills/` for personal use or
`.claude/skills/` within another project. Invoke them as `/granola-transcripts`
or `/implement-spec`.
