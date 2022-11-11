#!/usr/bin/env bash

cd /multipass/hmis-warehouse/docker/nginx-proxy
docker-compose up -d
cd /multipass/hmis-warehouse
docker-compose up -d
cd /multipass/boston-cas
docker-compose up -d
# cd openstack
# docker-compose up -d
