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

Run without arguments to launch the interactive menu:

```bash
openshift
```

### Controls

Every list in the wizard (the main menu, context pickers, the DEV/PROD
choice) is navigated the same way:

| Key(s)              | Action              |
|---------------------|---------------------|
| `↑` / `↓`            | Move the selection  |
| `→`, `Enter`, `Space`| Confirm / continue  |
| `←`, `q`, `Esc`      | Cancel / go back    |
| `Ctrl+C`             | Exit the wizard     |

### Menu options

1. **Switch Environment (Select Context)** — lists all `oc` contexts and
   switches to the one you pick.
2. **Login (Fetch new token & Setup)** — choose `DEV` or `PROD`, the
   wizard opens the corresponding token page in your browser, you paste
   the `oc login ...` command it gives you, and the wizard:
   - runs it,
   - removes any stale `dev`/`prod` context,
   - renames the freshly created context to `dev` or `prod`.
3. **Current Status** — shows the active context and the logged-in user.
4. **Rename Context** — pick a context and give it a new name.
5. **Disconnect / Clean up (Remove Context)** — pick a context and delete
   it. Warns you if you just deleted the active context.
6. **Exit** — quits the wizard.

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
