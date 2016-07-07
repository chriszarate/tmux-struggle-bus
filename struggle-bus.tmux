#!/usr/bin/env bash

# Provide CPU and memory usage indicators. Don't bother with exact percentages
# and real-time updates -- just let the user know if her computer is on the
# struggle bus and let her take it from there.

# Presently, memory usage is only implemented on OS X (via sysctl).

usage_placeholder_cpu="\#{usage_cpu}"
usage_placeholder_mem="\#{usage_mem}"

set noglob

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
  status_value="${status_value/$usage_placeholder_cpu/$usage_output_cpu}"
  status_value="${status_value/$usage_placeholder_mem/$usage_output_mem}"

  tmux set-option "$1" "$status_value"
}

# Colors
usage_format_begin_warning=$(get_tmux_option "@usage_format_begin_warning" "#[fg=black,bg=yellow]")
usage_format_begin_danger=$(get_tmux_option "@usage_format_begin_danger" "#[fg=black,bg=red]")
usage_format_end=$(get_tmux_option "@usage_format_end" "#[fg=white,bg=black]")

# Icons
usage_icon_cpu=$(get_tmux_option "@usage_icon_cpu" " CPU ")
usage_icon_mem=$(get_tmux_option "@usage_icon_mem" " MEM ")

# Thresholds
usage_threshold_cpu_danger=$(get_tmux_option "@usage_threshold_cpu_danger" "9")
usage_threshold_cpu_warning=$(get_tmux_option "@usage_threshold_cpu_warning" "8")
usage_threshold_mem_danger=$(get_tmux_option "@usage_threshold_mem_danger" "5")
usage_threshold_mem_warning=$(get_tmux_option "@usage_threshold_mem_warning" "3")

# Default output
usage_output_mem="MEM? "

get_cpu_usage() {
  local load_average
  local output
  local physical_cpus
  local real_load_average

  output="$usage_format_begin_danger CPU? $usage_format_end"
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
    load_average=$(uptime | awk '{print $11}')

    # Calculate real load average from 1-10-ish.
    real_load_average=$(echo "$load_average * 10 / $physical_cpus" | bc)

    # Test against thresholds.
    if [ "$real_load_average" -ge "$usage_threshold_cpu_danger" ]; then
      output="$usage_format_begin_danger$usage_icon_cpu$usage_format_end "
    elif [ "$real_load_average" -ge "$usage_threshold_cpu_warning" ]; then
      output="$usage_format_begin_warning$usage_icon_cpu$usage_format_end "
    else
      output=""
    fi
  fi

  echo "$output"
}

get_mem_usage() {
  local memory_pressure
  local output
  local page_count
  local page_data
  local page_target

  output="$usage_format_begin_danger MEM? $usage_format_end"

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
      output="$usage_format_begin_danger$usage_icon_mem$usage_format_end "
    elif [ "$memory_pressure" -ge "$usage_threshold_mem_warning" ]; then
      output="$usage_format_begin_warning$usage_icon_mem$usage_format_end "
    else
      output=""
    fi
  fi

  echo "$output"
}

usage_output_cpu=$(get_cpu_usage)
usage_output_mem=$(get_mem_usage)
update_status "status-left"
update_status "status-right"
