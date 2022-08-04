#!/bin/sh
echo "Starting server ..."
exec /usr/local/bin/python -m awslambdaric "$1"