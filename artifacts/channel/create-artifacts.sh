
chmod -R 0755 ./crypto-config
# Delete existing artifacts
rm -rf ./crypto-config/*
rm genesis.block mychannel.tx
rm -r genesis.block
rm -rf ../../channel-artifacts/*
# export PATH=${PWD}/../../bin:$PATH;


# # Generate Crypto artifactes for organizations
# # cryptogen generate --config=./crypto-config.yaml --output=./crypto-config/

# Generate with CA
cd ./CreateCAAuto
echo ${PWD}
bash ./CreateCertificates.sh
cd ../
cp -r ./CreateCAAuto/crypto-config-ca/* crypto-config
sleep 3

# System channel
SYS_CHANNEL="sys-channel"

# channel name defaults to "mychannel"
CHANNEL_NAME="mychannel"

echo $CHANNEL_NAME


# TODO: Write config.tx

# Generate System Genesis block
configtxgen -profile OrdererGenesis -configPath . -channelID $SYS_CHANNEL  -outputBlock ./genesis.block


# Generate channel configuration block
configtxgen -profile BasicChannel -configPath . -outputCreateChannelTx ./mychannel.tx -channelID $CHANNEL_NAME

echo "#######    Generating anchor peer update for Dist1MSP  ##########"
configtxgen -profile BasicChannel -configPath . -outputAnchorPeersUpdate ./Dist1MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Dist1MSP

echo "#######    Generating anchor peer update for Dist2MSP  ##########"
configtxgen -profile BasicChannel -configPath . -outputAnchorPeersUpdate ./Dist2MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Dist2MSP

echo "#######    Generating anchor peer update for Dist3MSP  ##########"
configtxgen -profile BasicChannel -configPath . -outputAnchorPeersUpdate ./Dist3MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Dist3MSP

echo "#######    Generating anchor peer update for ClientsMSP  ##########"
configtxgen -profile BasicChannel -configPath . -outputAnchorPeersUpdate ./ClientsMSPanchors.tx -channelID $CHANNEL_NAME -asOrg ClientsMSP
