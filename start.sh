# TODO: Add explorer and api flags...

export PATH=${PWD}/bin:$PATH;

./create-artifacts.sh

sleep 5
docker-compose -f ./artifacts/docker-compose.yaml up -d

# sleep 5
# ./createChannel.sh

# sleep 2
# ./deployChaincode.sh