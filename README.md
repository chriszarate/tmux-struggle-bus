# Tmux Struggle Bus

Who needs real-time CPU percentages and sparklines and animations? I sure don’t.
Just tell me when my computer is on the struggle bus so I can go close some
tabs. That’s what this `tmux` plugin does.

![usage indicators](example.png)


## Usage

Add `#{usage_cpu}` and/or `#{usage_mem}` to your `status-left` and/or
`status-right`:

```
set -g status-right '#{usage_cpu}%a %Y-%m-%d %H:%M'
```

When your computer reaches a threshold of usage, an indicator will appear.
Otherwise, nothing is shown.

Currently, this plugin provides indicators for elevated CPU and memory usage.
Memory usage is only implemented on `Darwin` (via `sysctl`).


## Installation

1. Install [Tmux Plugin Manager][tpm].

2. Add this plugin to your `~/.tmux.conf`:

```
set -g @plugin 'chriszarate/tmux-struggle-bus'
```

3. Press [prefix] + `I` to install.


## Configuration

The following configuration variables can be set in your `~/.tmux.conf` (shown
here with their default values):

```
# Colors
set -g @usage_format_begin_warning '#[fg=black,bg=yellow]'
set -g @usage_format_begin_danger '#[fg=black,bg=red]'
set -g @usage_format_end '#[fg=white,bg=black]'

# Icons
set -g @usage_icon_cpu ' CPU '
set -g @usage_icon_mem ' MEM '

# Thresholds
set -g @usage_threshold_cpu_danger '9'
set -g @usage_threshold_cpu_warning '8'
set -g @usage_threshold_mem_danger '5'
set -g @usage_threshold_mem_warning '3'
```

[tpm]: https://github.com/tmux-plugins/tpm
