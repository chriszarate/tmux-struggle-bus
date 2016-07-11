#!/usr/bin/env bash

set noglob

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$CURRENT_DIR/helpers.sh"

# Colors
usage_format_begin_danger=$(get_tmux_option "@usage_format_begin_danger" "#[fg=black,bg=red]")
usage_format_begin_warning=$(get_tmux_option "@usage_format_begin_warning" "#[fg=black,bg=yellow]")
usage_format_end=$(get_tmux_option "@usage_format_end" "#[fg=default,bg=default]")

# Icons
usage_icon_mem=$(get_tmux_option "@usage_icon_mem" " MEM ")

# Thresholds
usage_threshold_mem_danger=$(get_tmux_option "@usage_threshold_mem_danger" "5")
usage_threshold_mem_warning=$(get_tmux_option "@usage_threshold_mem_warning" "3")

main() {
  local memory_pressure
  local output
  local page_count
  local page_data
  local page_target

  output=" $usage_format_begin_danger MEM? "

  # Try to estimate memory pressure.
  if type sysctl >/dev/null 2>&1; then
    page_data=$(sysctl -a vm | grep page_free)
    page_target=$(echo "$page_data" | grep 'page_free_target' | awk '{print $2}')
    page_count=$(echo "$page_data" | grep 'page_free_count' | awk '{print $2}')
    memory_pressure=$(echo "(($page_target - $page_count) * 10) / $page_target" | bc)
  fi

  # Test against thresholds.
  if [ -n "$memory_pressure" ]; then
    if [ "$memory_pressure" -ge "$usage_threshold_mem_danger" ]; then
      output=" $usage_format_begin_danger$usage_icon_mem$usage_format_end"
    elif [ "$memory_pressure" -ge "$usage_threshold_mem_warning" ]; then
      output=" $usage_format_begin_warning$usage_icon_mem$usage_format_end"
    else
      output=""
    fi
  fi

  echo "$output"
}

main
