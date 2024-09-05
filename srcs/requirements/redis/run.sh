#!/bin/sh

set -eux

echo "requirepass ${REDIS_PASS}" >> /etc/redis.conf

redis-server /etc/redis.conf
