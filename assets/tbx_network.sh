#!/bin/bash

# Waiting for destination host on port number
# WaitForHost [ip/hostname](default:localhost) [port](default:80/http) [protocol](default:tcp)
WaitForHost() {
    HOST="${1:-localhost}"
    PORT="${2:-80}"
    PROTO="${3:-tcp}"
    while ! echo -n > /dev/$PROTO/$HOST/$PORT; do
        sleep 10
    done
} 2>/dev/null