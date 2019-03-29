#!/bin/bash

/usr/bin/expect << EOF
set timeout 100
spawn rsync  -azvPe "ssh -p 43222" ip:/data/bak.log /root
expect "password"
send "***\r"
set timeout 100
expect eof
exit
EOF
