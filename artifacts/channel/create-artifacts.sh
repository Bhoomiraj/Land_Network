
chmod -R 0755 ./crypto-config
# Delete existing artifacts
rm -rf ./crypto-config/*
rm genesis.block mychannel.tx
rm -r genesis.block
rm -rf ../../channel-artifacts/*

echo Crypto_material = ${Crypto_material}
# Generate Crypto artifactes for organizations
if [ "$Crypto_material"  = "cryptogen" ]; then
    #TODO: Update crypto-config based on network config in env...
    cryptogen generate --config=./crypto-config.yaml --output=./crypto-config/
fi

# Generate with CA
cd ./CreateCAAuto
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

# echo "#######    Generating anchor peer update for Dist1MSP  ##########"
# configtxgen -profile BasicChannel -configPath . -outputAnchorPeersUpdate ./Dist1MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Dist1MSP

# echo "#######    Generating anchor peer update for Dist2MSP  ##########"
# configtxgen -profile BasicChannel -configPath . -outputAnchorPeersUpdate ./Dist2MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Dist2MSP

# echo "#######    Generating anchor peer update for Dist3MSP  ##########"
# configtxgen -profile BasicChannel -configPath . -outputAnchorPeersUpdate ./Dist3MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Dist3MSP

# echo "#######    Generating anchor peer update for ClientsMSP  ##########"
# configtxgen -profile BasicChannel -configPath . -outputAnchorPeersUpdate ./ClientsMSPanchors.tx -channelID $CHANNEL_NAME -asOrg ClientsMSP


echo "#######    Generating anchor peer update for Org1MSP  ##########"
configtxgen -profile BasicChannel -configPath . -outputAnchorPeersUpdate ./Org1MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org1MSP

echo "#######    Generating anchor peer update for Org2MSP  ##########"
configtxgen -profile BasicChannel -configPath . -outputAnchorPeersUpdate ./Org2MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org2MSP
