change-scheduler:
 #!/usr/bin/env bash
 scxctl get
 scxctl switch --sched "$(gum choose $(scxctl list | grep -Po "\\[.*\\]" | jq -rc ".[]"))"
