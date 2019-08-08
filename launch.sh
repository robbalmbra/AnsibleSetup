#!/bin/bash

# Nodes indicate how many containers to launch
NODES=5
PORT=2222

if [ $# -eq 1 ]; then
 if ! [[ "$1" =~ ^[0-9]+$ ]]; then
   echo "Error - Input isnt a whole number."
   exit 1;
 fi

 echo "Setting node count to $1";
 NODES=$1;
fi

if [ ! -x "$(command -v docker)" ]; then
  echo "Error - Docker isnt installed."
  exit 1;
fi

# Copy SSH key
if [ ! -f  ~/.ssh/id_rsa.pub ]; then
  ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa
fi
cp ~/.ssh/id_rsa.pub .

# Build
echo "Building docker image..."
docker build -t ansible-ssh . 1>/dev/null

# Flush inventory file and ssh.config
mkdir ansible 2>/dev/null
echo "[servers]" > ansible/inventory
echo -e "Host *\n    StrictHostKeyChecking no\n    UserKnownHostsFile /dev/null\n    HashKnownHosts yes\n    IdentityFile ~/.ssh/id_rsa" > ansible/ssh.config

echo "Stopping and starting containers..."
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
echo "Complete"
