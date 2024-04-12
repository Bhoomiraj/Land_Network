echo "Removing all docker containers..."
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)
echo "Removed all containers..."
docker ps -a