echo "Stop container:"
docker stop quotas
echo "Remove container:"
docker container rm quotas
echo "Building container:"
docker build -t node8:yarn .
echo "Remove redundant images:"
docker rmi $(docker images -f "dangling=true" -q)
echo "Start running container:"
docker run -d -p 1337:1337 --name quotas -it node8:yarn