#!/bin/bash

# Script to find all AWS permissions that were denied in a log file

# Usage: ./find_denied_permissions.sh <log_file>
# Output: denied_permissions.txt

# Permissions denied appear after the string pattern "not authorized to perform:" in the log file
grep "not authorized to perform:" "$1" | grep -E -io "([A-z0-9]+:[A-z]+) " | sort | uniq > denied_permissions.txt
