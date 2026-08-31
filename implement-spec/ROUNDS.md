# Rounds

A **round** is one detached, headless CLI process of the **invocation** in a ticket's worktree. This file is the shell for it. The judgment stays in [`SKILL.md`](SKILL.md).

## How a round runs

Spawn the invocation: a detached headless CLI process, launched from inside the worktree. The invocation is launcher and CLI; omitted, it is launcher `va` and CLI grok. In the worktree, the CLI discovers the project skills - `/implement`, `/code-review`, `/tdd` - so the prompt is a skill. Resume uses the invocation's continue so findings go back to the agent that has the context.

The scripts detach every round into a new session, so nothing in the orchestrator's tool timeouts can end it. A round appends to `worktrees/agent-logs/issue-<n>.log` and writes `<log>.exit` with the exit code when it ends. The `.exit` file is the completion signal a watch polls for. `.gitignore` lists `worktrees/`.

The implementer commits on the branch. It doesn't push, open a PR, or close the ticket unless the ticket includes those steps. Those are the orchestrator's.

## Scripts

All of them take the primary checkout as their root, found from the skill's own location, so they run from anywhere. They read the default branch rather than assume it: `git symbolic-ref --short refs/remotes/origin/HEAD` names it. If that ref is unset, `git remote set-head origin -a` sets it from the remote.

- `scripts/launch.sh [--dry-run] [--launcher <launcher>] [--cli <cli>] <issue> <worktree-name> [<ticket-ref>]`: refuses a dirty worktree, then runs `/implement <ticket-ref>` as the invocation. `<ticket-ref>` is the `/implement` argument (URL, number, or path). Default: the GitHub issue URL derived from `origin`. A pre-session Bitwarden 429 gets two bounded, jittered retries when the launcher is `va`; other exits are final.
- `scripts/resume.sh [--dry-run] [--launcher <launcher>] [--cli <cli>] <issue> <worktree-name> <prompt-file>`: continues the worktree's session with the file's text, such as review findings, a merge round, or a correction. A resume is a new round, so arm a new watch. The worktree is the session, so resume only when no suite and no round is already running in it.
- `scripts/review.sh [--dry-run] [--launcher <launcher>] [--cli <cli>] <issue> <worktree-name> <fixed-point>`: a fresh agent of the invocation runs `/code-review <fixed-point>` in the worktree, read-only, into `worktrees/agent-logs/review-<n>.log`. The fixed point is the merge-base of the ticket branch and its land base. Read from the `## Standards` heading.
- `scripts/suite-capture.sh <worktree-name> <label> -- <command>...`: runs `<command>` in the worktree with its exit code into `worktrees/agent-logs/suite-gate-<label>.log` and the code into `<log>.exit`, the marker a chained wait polls for. `<command>` is the suite command from the chart.
- `scripts/automerge.sh <worktree-name> [<base-ref>]`: for when the land base moved and the dry run is clean. It accepts `main` or `origin/main`, merges the remote base into a detached scratch worktree, `worktrees/<name>-merge`, at the branch tip, proves the tree equals what `git merge-tree` computes, and prints the commit hash. Exit 2 with the conflict list means a merge round. Capture the suite on `<name>-merge`, then `automerge.sh --adopt <worktree-name>` fast-forwards the branch worktree to it and removes the scratch.
- `scripts/land.sh [--wait-checks] <issue> <worktree-name> <title> <body-file> [<base-ref>]`: GitHub. `--wait-checks` holds the merge until the PR's checks pass and stops without merging when one fails - use it from the first ticket that gives the repo CI onward, and always when a merge triggers a deploy. Accepts `main` or `origin/main` and refuses a dirty worktree or a land base not yet merged into the tip. It pushes and opens the PR from the worktree, merges it from the primary checkout, deletes the remote branch, fast-forwards the local land-base ref, and prints the hash of the merge commit and the state of the issue. Run it with `--dry-run` first to print the commands.
- `scripts/watch.sh <issue>...`: prints `DONE issue-<n> exit=<code>` as each round's marker appears and exits when all have. Use it as a Monitor command. Pass `--review` to watch review logs instead. A disappearing `.exit` is a new round, so a resume on a still-armed watch prints `DONE` again. A first round on a large ticket runs past an hour, so re-arm a watch that has a one-hour limit, and give a resume its own.

Memory bounds concurrency, and every other session on the box shares that memory. Read available memory before a batch (`/proc/meminfo` or `vm_stat`) and count the agents already running with `pgrep -af 'grok --always-approve'`. Three or four agents plus their sub-agents fit beside a dozen resident sessions. Eleven don't.

A silent log isn't a stalled round. The round writes only its own text, and a suite or a review sub-agent runs for 20 minutes without a line. Before you stop a quiet round, look for a test process whose working directory is the worktree. When you do stop a round, stop it by process ID with `kill <pid>`: a `pkill -f <pattern>` whose pattern matches the orchestrator's own Bash command ends that shell with exit code 144.

## Traps

Each trap cost a round or a wrong reading once. They're grouped by the stage where each one hits.

### Launching and watching

- The Bash tool's working directory persists across calls. A background command that uses a relative path, launched in the same response as a `cd` elsewhere, runs in the wrong worktree. A `review.sh` launched by a relative path from a shell left inside a worktree doesn't start at all, while its watch waits on a marker that never comes. Use absolute paths, always.
- Review sub-agents share the session scratchpad and might write a file with your script's name. Name your files distinctively.
- A chained wait polls for a marker its target actually writes: `suite-capture.sh` writes one, and a bare suite command doesn't. Arm a chain keyed on the round marker's absence while the marker is present. Armed after a resume already removed it, the chain reads the running round as the next one's launch, and a capture chained on the marker's return runs beside whatever round launches next in the same worktree. Read the round's process and the marker together before arming. Stop a chain rather than let two things share a worktree.

### Reading a suite

- Piping the suite through `tail` reports the exit code of `tail` and hides the summary. Redirect to a file, echo `$?`, and read the log. `suite-capture.sh` does exactly this.
- Suites that name the same fixed port, simulator, emulator, or database in the chart run serially. Separate worktrees do not isolate process-level resources.
- The implementer's "N tests OK" isn't the gate. The orchestrator's captured run is, after every resume too.
- An install copied into a worktree, used as the interpreter without the repo's own test entrypoint, isn't that file. Run the charted command.

### Gating

- A spec's "production lacks X" sentence is a claim the Chart step probes on the base before the first launch. A mocked red proves only the mock.
- The ticket's own new tests are where "a rule weakened to keep a test green" shows up first. Read each new test's filters against the criterion's words.
- Put the checks a spec repeats at every gate into one script at the first gate, and diff against the merge-base: `git diff origin/<default>..HEAD` counts turn false the moment the base moves.
- A conflict-resolution script gates `git add` on its own success. A replacement that failed and a `git add` that ran anyway stages the conflict markers, and `rebase --continue` commits them.
- Repeated merge rounds that each weaken the same check are one rule. Post it on the tickets, under `Settle rules once`, rather than send three branches back.

### Merging and landing

- Every sibling landing that still builds the old shape in a fixture breaks a ticket that changes that shape. The branch's suite is green, but the merged tree's suite is the gate. Grep the merged tree's tests for the old shape before landing.
- Sibling specs on one land base move the default branch under you, and every move costs the next branch to land a suite run on the combined tree. Use `automerge.sh` for the clean case and a merge round for the rest, and merge only on a tip that has the land base as an ancestor. When several tickets edit one file, land in readiness order and draft the next merge prompts while you wait.
- Merging a PR from the ticket worktree tries to delete the branch that worktree is on. From the primary checkout, it stops at "used by worktree" and leaves the remote branch too. `land.sh` merges from the primary checkout and deletes the remote branch itself.
