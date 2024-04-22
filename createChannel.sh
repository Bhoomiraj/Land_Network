export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/artifacts/channel/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
export PEER0_ORG1_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export PEER0_ORG2_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
export PEER0_DIST1_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/Dist1.example.com/peers/peer0.Dist1.example.com/tls/ca.crt
export PEER0_DIST2_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/Dist2.example.com/peers/peer0.Dist2.example.com/tls/ca.crt
export PEER0_DIST3_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/Dist3.example.com/peers/peer0.Dist3.example.com/tls/ca.crt
export PEER0_CLIENTS_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/Clients.example.com/peers/peer0.Clients.example.com/tls/ca.crt
export FABRIC_CFG_PATH=${PWD}/artifacts/channel/config/

export CHANNEL_NAME=mychannel

# setGlobalsForOrderer(){
#     export CORE_PEER_LOCALMSPID="OrdererMSP"
#     export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/artifacts/channel/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
#     export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/ordererOrganizations/example.com/users/Admin@example.com/msp
    
# }

setGlobalsForPeer0Org1(){
    export CORE_PEER_LOCALMSPID="Org1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG1_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
    export CORE_PEER_ADDRESS=localhost:8051
}

setGlobalsForPeer1Org1(){
    export CORE_PEER_LOCALMSPID="Org1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG1_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
    export CORE_PEER_ADDRESS=localhost:8151
    
}

setGlobalsForPeer0Org2(){
    export CORE_PEER_LOCALMSPID="Org2MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG2_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
    export CORE_PEER_ADDRESS=localhost:12051
    
}

setGlobalsForPeer1Org2(){
    export CORE_PEER_LOCALMSPID="Org2MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG2_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
    export CORE_PEER_ADDRESS=localhost:12151
    
}


setGlobalsForPeer0Dist1(){
    export CORE_PEER_LOCALMSPID="Dist1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_DIST1_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/Dist1.example.com/users/Admin@Dist1.example.com/msp
    export CORE_PEER_ADDRESS=localhost:7051
}

setGlobalsForPeer1Dist1(){
    export CORE_PEER_LOCALMSPID="Dist1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_DIST1_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/Dist1.example.com/users/Admin@Dist1.example.com/msp
    export CORE_PEER_ADDRESS=localhost:7151
    
}

setGlobalsForPeer0Dist2(){
    export CORE_PEER_LOCALMSPID="Dist2MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_DIST2_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/Dist2.example.com/users/Admin@Dist2.example.com/msp
    export CORE_PEER_ADDRESS=localhost:8051
    
}

setGlobalsForPeer1Dist2(){
    export CORE_PEER_LOCALMSPID="Dist2MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_DIST2_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/Dist2.example.com/users/Admin@Dist2.example.com/msp
    export CORE_PEER_ADDRESS=localhost:8151
    
}

setGlobalsForPeer0Dist3(){
    export CORE_PEER_LOCALMSPID="Dist3MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_DIST3_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/Dist3.example.com/users/Admin@Dist3.example.com/msp
    export CORE_PEER_ADDRESS=localhost:10051
}

setGlobalsForPeer1Dist3(){
    export CORE_PEER_LOCALMSPID="Dist3MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_DIST3_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/Dist3.example.com/users/Admin@Dist3.example.com/msp
    export CORE_PEER_ADDRESS=localhost10151
    
}

setGlobalsForPeer0Clients(){
    export CORE_PEER_LOCALMSPID="ClientsMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_Clients_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/Clients.example.com/users/Admin@Clients.example.com/msp
    export CORE_PEER_ADDRESS=localhost:11051
    
}

setGlobalsForPeer1Clients(){
    export CORE_PEER_LOCALMSPID="ClientsMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_Clients_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/Clients.example.com/users/Admin@Clients.example.com/msp
    export CORE_PEER_ADDRESS=localhost:11151
    
}

createChannel(){
    rm -rf ./channel-artifacts/*
    setGlobalsForPeer0Org1
    
    echo $CORE_PEER_ADDRESS
    set -x
    peer channel create -o localhost:7050 -c $CHANNEL_NAME \
    --ordererTLSHostnameOverride orderer.example.com \
    -f ./artifacts/channel/${CHANNEL_NAME}.tx --outputBlock ./channel-artifacts/${CHANNEL_NAME}.block \
    --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA
}

removeOldCrypto(){
    rm -rf ./api-1.4/crypto/*
    rm -rf ./api-1.4/fabric-client-kv-org1/*
    rm -rf ./api-2.0/org1-wallet/*
    rm -rf ./api-2.0/org2-wallet/*
}


joinChannel(){
    setGlobalsForPeer0Org1
    peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block
    
    setGlobalsForPeer1Org1
    peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block
    
    setGlobalsForPeer0Org2
    peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block
    
    setGlobalsForPeer1Org2
    peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block
    
}

updateAnchorPeers(){
    setGlobalsForPeer0Org1
    peer channel update -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com -c $CHANNEL_NAME -f ./artifacts/channel/${CORE_PEER_LOCALMSPID}anchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA
    
    setGlobalsForPeer0Org2
    peer channel update -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com -c $CHANNEL_NAME -f ./artifacts/channel/${CORE_PEER_LOCALMSPID}anchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA

}

removeOldCrypto

echo "creating channel..."
createChannel
# echo "joining channel..."
# joinChannel
# updateAnchorPeers