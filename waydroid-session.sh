#!/bin/bash

# Start Waydroid inside a nested Wayland compositor on X11.
#
# Default compositor is Cage (more stable across suspend/resume than Weston
# for many setups). Override with:
#   WAYDROID_COMPOSITOR=weston waydroid-session.sh

cd "$(dirname "$0")" || exit 1

COMPOSITOR="${WAYDROID_COMPOSITOR:-cage}"
COMPOSITOR=$(printf '%s' "$COMPOSITOR" | tr '[:upper:]' '[:lower:]')

COMPOSITOR_PID=
WAYDROID_PID=

cleanup() {
  trap - EXIT INT TERM HUP

  waydroid session stop 2>/dev/null || true

  if [ -n "${WAYDROID_PID:-}" ]; then
    kill "$WAYDROID_PID" 2>/dev/null || true
    wait "$WAYDROID_PID" 2>/dev/null || true
  fi

  if [ -n "${COMPOSITOR_PID:-}" ]; then
    kill "$COMPOSITOR_PID" 2>/dev/null || true
    wait "$COMPOSITOR_PID" 2>/dev/null || true
  fi

  killall waydroid 2>/dev/null || true

  case "$COMPOSITOR" in
    weston) killall weston 2>/dev/null || true ;;
    cage)   killall cage 2>/dev/null || true ;;
  esac
}

trap cleanup EXIT INT TERM HUP

run_cage() {
  if ! command -v cage >/dev/null 2>&1; then
    echo "cage not found; install it (e.g. sudo apt install cage) or use WAYDROID_COMPOSITOR=weston" >&2
    exit 1
  fi
  # Foreground: do not exec, so EXIT trap still runs when Cage exits.
  cage -s -- waydroid show-full-ui
}

run_weston() {
  if ! command -v weston >/dev/null 2>&1; then
    echo "weston not found" >&2
    exit 1
  fi
  weston --xwayland &
  COMPOSITOR_PID=$!
  # First nested Weston on a typical X11 desktop uses wayland-0 (Waydroid default).
  export WAYLAND_DISPLAY=wayland-0
  sleep 2
  waydroid show-full-ui &
  WAYDROID_PID=$!
  wait "$COMPOSITOR_PID"
}

case "$COMPOSITOR" in
  cage)  run_cage ;;
  weston) run_weston ;;
  *)
    echo "Unknown WAYDROID_COMPOSITOR=$COMPOSITOR (use cage or weston)" >&2
    exit 1
    ;;
esac
