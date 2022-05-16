#!/bin/bash

SCRIPT_DIR="$(dirname $0)"
TARGET_DIR="$SCRIPT_DIR/dist"

rm -rf "$TARGET_DIR"
mkdir "$TARGET_DIR"
pip3 install -r "$SCRIPT_DIR/requirements.txt" --target "$TARGET_DIR"
cp "$SCRIPT_DIR/neo4j_to_sentinel.py" "$TARGET_DIR"
cp "$SCRIPT_DIR/neo4j_connector.py" "$TARGET_DIR"
cp "$SCRIPT_DIR/queries.json" "$TARGET_DIR"
