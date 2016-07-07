#!/usr/bin/env bash

set noglob

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$CURRENT_DIR/helpers.sh"

# Colors
usage_format_begin_danger=$(get_tmux_option "@usage_format_begin_danger" "#[fg=black,bg=red]")
usage_format_begin_warning=$(get_tmux_option "@usage_format_begin_warning" "#[fg=black,bg=yellow]")
usage_format_end=$(get_tmux_option "@usage_format_end" "#[fg=white,bg=black]")

# Icon
usage_icon_cpu=$(get_tmux_option "@usage_icon_cpu" " CPU ")

# Thresholds
usage_threshold_cpu_danger=$(get_tmux_option "@usage_threshold_cpu_danger" "9")
usage_threshold_cpu_warning=$(get_tmux_option "@usage_threshold_cpu_warning" "8")

main() {
  local load_average
  local output
  local physical_cpus
  local real_load_average

  output=" $usage_format_begin_danger CPU? "
  physical_cpus=1

  # Make sure uptime is available.
  if type uptime >/dev/null 2>&1; then

    # Try to find number of physical CPUs.
    if [ -f /proc/cpuinfo ]; then
      physical_cpus=$(cat /proc/cpuinfo | grep "physical id" | sort | uniq | wc -l)
    elif type sysctl >/dev/null 2>&1; then
      physical_cpus=$(sysctl -n hw.physicalcpu)
    fi

    # Get 1m load average.
    load_average=$(uptime | awk '{print $10}')

    # Calculate real load average from 1-10-ish.
    real_load_average=$(echo "$load_average * 10 / $physical_cpus" | bc)

    # Test against thresholds.
    if [ "$real_load_average" -ge "$usage_threshold_cpu_danger" ]; then
      output=" $usage_format_begin_danger$usage_icon_cpu$usage_format_end"
    elif [ "$real_load_average" -ge "$usage_threshold_cpu_warning" ]; then
      output=" $usage_format_begin_warning$usage_icon_cpu$usage_format_end"
    else
      output=""
    fi
  fi

  echo "$output"
}

main
