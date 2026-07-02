#!/bin/bash
echo "APR frontend runs FROM FILE on $(date -u)!" > index.html
nohup busybox httpd -f -p 8080 &

