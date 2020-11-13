#!/usr/bin/env bash
set -ex
/usr/local/bin/docker-compose down
/usr/local/bin/docker-compose build --parallel
/usr/local/bin/docker-compose up -d --force-recreate
