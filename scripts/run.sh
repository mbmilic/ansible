#!/usr/bin/env bash
set -Eeuo pipefail


# Wrapper to run the starter playbook with an optional single tag.
# Usage:
# ./scripts/run.sh # run everything
# ./scripts/run.sh brave # run only tasks tagged 'brave' (+ always)
#
# Env flags:
# DRY=1 -> --check (no changes)
# VERBOSE=1 -> -vv
# ASK_BECOME=1-> -K (ask sudo password)
#
# Notes:
# - If a tag is provided, tasks with tag 'always' still run.
# - Exits non-zero on failure.


ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"
cd "$ROOT_DIR"


# Basic sanity checks
command -v ansible-playbook >/dev/null 2>&1 || {
echo "ansible-playbook not found. Install Ansible first (see README)." >&2
exit 127
}


[[ -f start.yml ]] || { echo "start.yml not found at repo root." >&2; exit 2; }
[[ -f inventory/hosts.ini ]] || { echo "inventory/hosts.ini not found." >&2; exit 2; }


PLAYBOOK=start.yml
INVENTORY=inventory/hosts.ini


ARGS=( -i "$INVENTORY" "$PLAYBOOK" )


# Env-driven toggles
[[ "${DRY:-0}" != 0 ]] && ARGS=( --check "${ARGS[@]}" )
[[ "${VERBOSE:-0}" != 0 ]] && ARGS=( -vv "${ARGS[@]}" )
[[ "${ASK_BECOME:-0}" != 0 ]] && ARGS=( -K "${ARGS[@]}" )


# Optional single tag from first positional arg
if [[ ${1:-} != "" ]]; then
ARGS+=( --tags "$1" )
fi


# Execute
exec ansible-playbook "${ARGS[@]}"
```bash
#!/usr/bin/env bash
set -euo pipefail


# Wrapper to run the starter playbook with an optional tag.
# Usage:
# ./scripts/run.sh # run everything
# ./scripts/run.sh brave # run only tasks tagged 'brave' (+ always)
# ./scripts/run.sh dotfiles # run only tasks tagged 'dotfiles' (+ always)
#
# Environment variables:
# DRY=1 → enable check mode (dry-run)
# VERBOSE=1 → increase verbosity (-vv)


ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"
cd "$ROOT_DIR"


ARGS=( -i inventory/hosts.ini start.yml )


# Add dry-run if requested
if [[ "${DRY:-}" == "1" ]]; then
ARGS+=( --check )
fi


# Add verbosity if requested
if [[ "${VERBOSE:-}" == "1" ]]; then
ARGS+=( -vv )
fi


# Add tag if provided
if [[ $# -ge 1 ]]; then
ARGS+=( --tags "$1" )
fi


exec ansible-playbook "${ARGS[@]}"
