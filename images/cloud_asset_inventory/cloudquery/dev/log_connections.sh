#!/bin/bash
tcpdump -nn -i any dst port not 22 and dst net not 127.0.0.0/8 >> /var/log/connection_logs.txt 2>&1 