#!/bin/bash

# Nodes indicate how many containers to launch
NODES=5
PORT=2222

# Build
docker build -t ansible-ssh . 1>/dev/null

# Flush inventory file and ssh.config
echo "[servers]" > ansible/inventory
echo -e "Host *\n    StrictHostKeyChecking no\n    UserKnownHostsFile /dev/null\n    HashKnownHosts yes\n    IdentityFile ~/.ssh/id_rsa" > ansible/ssh.config

for ((i=1; i <= $NODES; i++)); do

  # Stop and delete old containers
  docker stop ansible_$i >/dev/null 2>&1;
  docker rm ansible_$i >/dev/null 2>&1;

  # Launch
  echo "Launching node $i...";
  docker run -d -p $PORT:22 --name ansible_$i ansible-ssh 1>/dev/null;

  # Write to ssh.config
  echo "" >> ansible/ssh.config
  echo "Host ansible$i.test" >> ansible/ssh.config
  echo "    HostName localhost" >> ansible/ssh.config
  echo "    User root" >> ansible/ssh.config
  echo "    Port $PORT" >> ansible/ssh.config
  echo "ansible$i.test" >> ansible/inventory

  ((PORT++))
done
