#!/usr/bin/env bash

sudo docker-compose down
sudo docker rm -f $(sudo docker ps -a -q)
sudo docker volume rm $(sudo docker volume ls -q)