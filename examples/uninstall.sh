#!/usr/bin/bash
systemctl stop rock-mon
systemctl stop rock-engine
yum autoremove rock
rm -rfv /var/log/rock
rm -rfv /etc/rock
