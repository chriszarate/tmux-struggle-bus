#!/usr/bin/env bash

# Provide CPU, disk, and memory usage indicators. Don't bother with exact
# percentages and real-time updates -- just let the user know if her computer
# is on the struggle bus and let her take it from there.

# Presently, memory usage is only implemented on OS X (via sysctl).

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

get_tmux_option() {
  local option_value
  option_value=$(tmux show-option -gqv "$1")

  if [ -z "$option_value" ]; then
    echo "$2"
  else
    echo "$option_value"
  fi
}

update_status() {
  local status_value
  status_value="$(get_tmux_option "$1")"
  status_value="${status_value/$usage_placeholder_cpu/$usage_script_cpu}"
  status_value="${status_value/$usage_placeholder_disk/$usage_script_disk}"
  status_value="${status_value/$usage_placeholder_mem/$usage_script_mem}"

  tmux set-option -gq "$1" "$status_value"
}

# Commands
usage_script_cpu="#($CURRENT_DIR/scripts/cpu.sh)"
usage_script_disk="#($CURRENT_DIR/scripts/disk.sh)"
usage_script_mem="#($CURRENT_DIR/scripts/memory.sh)"

# Substitution
usage_placeholder_cpu="\#{usage_cpu}"
usage_placeholder_disk="\#{usage_disk}"
usage_placeholder_mem="\#{usage_mem}"

update_status "status-left"
update_status "status-right"
