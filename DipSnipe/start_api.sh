#!/bin/bash
# Start DipHunter API Server

cd "$(dirname "$0")"
source venv/bin/activate
python python/src/api_server.py
