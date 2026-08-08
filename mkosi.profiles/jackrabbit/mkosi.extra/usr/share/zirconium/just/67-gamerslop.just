change-scheduler:
 #!/usr/bin/env bash
 if scxctl get | grep ^running &>/dev/null; then
   ACTION=switch
 else
   ACTION=start
 fi

 scxctl get
 scxctl ${ACTION} --sched "$(gum choose $(scxctl list | grep -Po "\\[.*\\]" | jq -rc ".[]"))"
