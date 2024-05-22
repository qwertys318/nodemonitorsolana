#!/bin/bash

set -e

sudo mkdir /var/log/nodemonitor
sudo chown sol:sol /var/log/nodemonitor
chmod 755 /var/log/nodemonitor
sudo cp ./nodemonitor.service /etc/systemd/system/nodemonitor.service
sudo systemctl daemon-reload
sudo systemctl enable --now nodemonitor
echo "CHECK THE RPC IN .service"