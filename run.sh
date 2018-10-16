exists=$( docker ps -a | grep quotas )
if [ "$exists" ]; then
  docker restart quotas
else
  sh rebuild.sh
fi