#!/bin/bash
echo "Validating application..."

curl -f http://localhost || exit 1
