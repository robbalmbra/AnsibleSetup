#!/bin/bash

# Nodes indicate how many containers to launch
NODES=5
PORT=2222

# Build
docker build -t ansible-ssh . 1>/dev/null

for ((i=1; i <= $NODES; i++)); do

  # Stop and delete old containers
  docker stop ansible_$i 1>/dev/null;
  docker rm ansible_$i 1>/dev/null;

  # Launch
  echo "Launching node $i...";
  docker run -d -p $PORT:22 --name ansible_$i ansible-ssh 1>/dev/null;
  ((PORT++))
done
