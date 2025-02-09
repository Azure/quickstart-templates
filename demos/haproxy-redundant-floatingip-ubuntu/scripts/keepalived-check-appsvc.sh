#!/bin/bash

URL="http://localhost"

if [[ `curl -s -o/dev/null --connect-timeout 0.5 $URL; echo $?` -ne 0 ]]; then
    exit 1
else
    exit 0
fi

