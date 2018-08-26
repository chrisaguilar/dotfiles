#!/usr/bin/env bash

. ./common.sh

# Install Redis
package_install redis

# Enable the Redis Service
enable_service redis.service
