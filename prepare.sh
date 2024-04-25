sudo mkdir /var/log/nodemonitor
sudo chown sol:sol /var/log/nodemonitor
chmod 755 /var/log/nodemonitor
sudo cp ./nodemonitor.service /etc/systemd/system/nodemonitor.service
cp ./nodemonitor.sh ~/
echo "CHECK THE RPC IN ~/nodemonitor.sh"