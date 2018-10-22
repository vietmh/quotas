isQuotasExists=$( docker ps -a | grep -P '(^|\s)\quotas(?=\s|$)')
isQuotasDatastoreExists=$( docker ps -a | grep -P '(^|\s)\quotas-datastore(?=\s|$)')

if ! { [ "$isQuotasExists" ] || [ "$isQuotasDatastoreExists" ]; }; then
  sh rebuild.sh
fi

docker-compose up -d