# openshift-cli-wizard

Interactive CLI wizard for managing OpenShift (`oc`) authentications and
contexts. Built for QA Automation teams who need to log into corporate
OpenShift environments and switch contexts without memorizing long `oc`
commands.

Pure Bash + POSIX utilities only — no external UI dependencies (no `gum`,
no `fzf`). Works on both macOS and Linux out of the box.

## Prerequisites

- [`oc`](https://docs.openshift.com/container-platform/latest/cli_reference/openshift_cli/getting-started-cli.html) CLI installed and on your `PATH`.
- A browser-opening utility: `open` (macOS, built-in) or `xdg-open` (Linux, usually part of `xdg-utils`).

The wizard checks both at startup and exits with a clear error message if
either is missing.

- [`k9s`](https://k9scli.io/) (optional) — a terminal UI for Kubernetes/OpenShift clusters.
  If it's missing, the wizard does **not** exit; it just shows a warning at
  the top of the main menu recommending you install it (e.g.
  `brew install k9s`), and the "Launch k9s Dashboard" menu option will show
  an error if you select it without k9s installed.

## Installation

Two equivalent ways to install:

### Option A: run the installer script

```bash
./install.sh
```

### Option B: use the script's built-in flag

```bash
./openshift --install
```

Both approaches:
- Make `openshift` executable.
- Symlink it into `~/.local/bin/openshift` (preferred) or
  `/usr/local/bin/openshift` (fallback, may prompt for `sudo`).
- Warn you if the chosen directory isn't on your `PATH` yet, with the
  exact line to add to your shell profile.

After installing, restart your shell (or run `hash -r`) and confirm:

```bash
openshift --help
```

## Usage

Run without arguments to launch the interactive wizard:

```bash
openshift
```

The wizard takes over the full screen (like `vim`/`htop`/`less`) for the
whole session. Every menu and action result renders in place — nothing
stacks up or scrolls, and once you exit (via `Exit`, `q`, `Esc`, or
`Ctrl+C`) your terminal is restored to exactly what it looked like before,
with nothing from the session left in your scrollback.

On startup, it runs a quick preliminary check (`oc whoami`) against your
current context and warns you up front if your session token looks
invalid or expired, so you find out before hitting confusing failures
deeper in the wizard.

### Controls

Every list in the wizard (the main menu, context pickers, the DEV/PROD
choice) is navigated the same way:

| Key(s)              | Action              |
|---------------------|---------------------|
| `↑` / `↓`            | Move the selection  |
| `→`, `Enter`, `Space`| Confirm / continue  |
| `←`, `q`, `Esc`      | Cancel / go back    |
| `Ctrl+C`             | Exit the wizard     |

After an action runs, its result is shown and the wizard waits for
`Enter` ("Press Enter to continue...") before clearing the screen and
returning to the menu, so results stay readable.

### Menu options

1. **Switch Environment (Select Context)** — lists all `oc` contexts and
   switches to the one you pick.
2. **Switch Project (Select Namespace)** — lists all projects/namespaces
   you can access on the current context and switches to the one you pick,
   updating the current context's namespace in place
   (`oc config set-context --current --namespace=<name>`).
3. **Launch k9s Dashboard** — launches [`k9s`](https://k9scli.io/) against
   your current context (`k9s --context <current-context>`), taking over
   the terminal for a full cluster dashboard session. When you quit k9s
   (`:q`), you're dropped straight back into the wizard's main menu with
   no extra confirmation needed. If k9s isn't installed, shows an error
   with install instructions instead.
4. **Login (Fetch new token & Setup)** — choose `DEV` or `PROD`, the
   wizard opens the corresponding token page in your browser, you paste
   the `oc login ...` command it gives you, and the wizard:
   - runs it,
   - removes any stale `dev`/`prod` context,
   - renames the freshly created context to `dev` or `prod`.
5. **Current Status** — shows the active context and the logged-in user.
6. **Rename Context** — pick a context and give it a new name.
7. **Disconnect / Clean up (Remove Context)** — pick a context and delete
   it. Warns you if you just deleted the active context.
8. **Exit** — quits the wizard.

Press `Ctrl+C`, `q`, or `Esc` at any point to cancel the current prompt or
exit the wizard cleanly.

## Uninstall

Two equivalent ways to remove the wizard:

```bash
./uninstall.sh
```

or

```bash
openshift --uninstall
```

Both only remove the symlink(s) created by the installer (checked in both
`~/.local/bin/openshift` and `/usr/local/bin/openshift`), and only if the
symlink actually points back at this repo's `openshift` script. Nothing
else on your system is touched — no oc kubeconfig entries, no contexts,
no other files are modified or deleted.
