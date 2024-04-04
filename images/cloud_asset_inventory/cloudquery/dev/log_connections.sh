#!/bin/bash
tcpdump -nn -i any dst port not 22 and dst net not 127.0.0.0/8 | awk '{print $3}' | awk -F'.' '{print $1"."$2"."$3"."$4}' | sort -u