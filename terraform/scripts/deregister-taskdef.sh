#!/bin/bash

ids="$(aws ecs list-task-definitions --family-prefix $1 --query taskDefinitionArns[] --output text | tr '\t' ' ')"

found=
for id in $ids; do
  if [ -n "$id" ]; then
    aws ecs deregister-task-definition --task-definition $id >/dev/null
    found=1
  fi
done

# Yes, I'm being lazy here...
[ -n "$found" ] && sleep 5 || true
