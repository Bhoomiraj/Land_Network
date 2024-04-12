# TODO: Add explorer and api flags...

export PATH=${PWD}/bin:$PATH;

./create-artifacts.sh

docker-compose -f ./artifacts/docker-compose.yaml up -d

sleep 5
./createChannel.sh

sleep 2
./deployChaincode.sh