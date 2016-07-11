#!/usr/bin/env bash

set noglob

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$CURRENT_DIR/helpers.sh"

# Colors
usage_format_begin_danger=$(get_tmux_option "@usage_format_begin_danger" "#[fg=black,bg=red]")
usage_format_begin_warning=$(get_tmux_option "@usage_format_begin_warning" "#[fg=black,bg=yellow]")
usage_format_end=$(get_tmux_option "@usage_format_end" "#[fg=default,bg=default]")

# Icon
usage_icon_disk=$(get_tmux_option "@usage_icon_disk" "")

# Thresholds
usage_threshold_disk_danger=$(get_tmux_option "@usage_threshold_disk_danger" "95")
usage_threshold_disk_warning=$(get_tmux_option "@usage_threshold_disk_warning" "90")

main() {
  local output
  local disk_usage
  local disk_warning
  local disk_danger

  output=" $usage_format_begin_danger DISK? $usage_format_end"

  # Make sure df is available.
  if type df >/dev/null 2>&1; then
    output=""
    disk_usage=$(df -l)
    disk_warning="$(echo "$disk_usage" | awk -v warning="$usage_threshold_disk_warning" -v danger="$usage_threshold_disk_danger" '/^\/dev\// { if ($5 >= warning && $5 < danger) print $1; }' | sed 's/\/dev\///g')"
    disk_danger="$(echo "$disk_usage" | awk -v danger="$usage_threshold_disk_danger" '/^\/dev\// { if ($5 >= danger) print $1; }' | sed 's/\/dev\///g')"

    if [ -n "$disk_warning" ]; then
      for disk in $disk_warning; do
        output="$output $usage_format_begin_warning $usage_icon_disk$disk $usage_format_end"
      done
    fi

    if [ -n "$disk_danger" ]; then
      for disk in $disk_danger; do
        output="$output $usage_format_begin_danger $usage_icon_disk$disk $usage_format_end"
      done
    fi
  fi

  echo "$output"
}

main