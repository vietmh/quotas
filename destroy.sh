#!/bin/bash

read -p "This bash will destroy all containers as well as their volumes. Are you sure to delete them? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]];
then
  docker-compose down -v
fi


