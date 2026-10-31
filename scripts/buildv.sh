#!/bin/bash
cd /mnt/c/Users/MR/Projects/v
./v_linux -o ./v_linux2 self > /tmp/self.log 2>&1
echo "EXIT=$?" >> /tmp/self.log
