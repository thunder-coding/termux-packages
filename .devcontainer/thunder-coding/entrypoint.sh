#!/bin/sh
sudo service docker start
sudo docker run --rm --privileged aptman/qus -s -- -p aarch64 arm
sudo /etc/init.d/ssh start 2>&1 | sudo tee /tmp/sshd.log > /dev/null
