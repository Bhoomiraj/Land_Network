#!/bin/bash
# set -x

num_organizaions=3
orgNames=("org1" "org2" "orderer")
# orgNames=("Clients" "LandInspectors" "Orderers")
OrgPortNumbers=(7054 8054 9054)
peers_per_Org=(3 3 0)
Orderers_per_Org=(0 0 3)
IsOrdererOrg=(0 0 1)


# export PATH=${PWD}/../../../bin:$PATH;

create_DockerCompose_CA_ORG() {
    OrgName=$1
    PortNumber=$2

    echo "  ca_${OrgName}:
    image: hyperledger/fabric-ca
    environment:
      - FABRIC_CA_HOME=/etc/hyperledger/fabric-ca-server
      - FABRIC_CA_SERVER_CA_NAME=ca.${OrgName}.example.com
      - FABRIC_CA_SERVER_TLS_ENABLED=true
      - FABRIC_CA_SERVER_PORT=${PortNumber}
    ports:
      - \"${PortNumber}:${PortNumber}\"
    command: sh -c 'fabric-ca-server start -b admin:adminpw -d'
    volumes:
      - ./fabric-ca/${OrgName}:/etc/hyperledger/fabric-ca-server
    container_name: ca.${OrgName}.example.com
    hostname: ca.${OrgName}.example.com
    networks:
      - test
    " >>${PWD}/docker-compose.yaml
}

create_DockerCompose_CA_Orderer() {
    OrgName=$1
    PortNumber=$2

    echo "  ca_${OrgName}:
    image: hyperledger/fabric-ca
    environment:
      - FABRIC_CA_HOME=/etc/hyperledger/fabric-ca-server
      - FABRIC_CA_SERVER_CA_NAME=ca-${OrgName}
      - FABRIC_CA_SERVER_TLS_ENABLED=true
      - FABRIC_CA_SERVER_PORT=${PortNumber}
    ports:
      - \"${PortNumber}:${PortNumber}\"
    command: sh -c 'fabric-ca-server start -b admin:adminpw -d'
    volumes:
      - ./fabric-ca/${OrgName}Org:/etc/hyperledger/fabric-ca-server
    container_name: ca_${OrgName}
    networks:
      - test
    " >>${PWD}/docker-compose.yaml
}

create_DockerComposer_Yaml(){
echo "version: '2'

networks:
  test:

services:
" >${PWD}/docker-compose.yaml

    itr=0
    while [ $itr -lt $num_organizaions ]
    do
      if [ ${IsOrdererOrg[$itr]} -eq 0 ]; then
        create_DockerCompose_CA_ORG ${orgNames[$itr]} ${OrgPortNumbers[$itr]} 
      else 
        create_DockerCompose_CA_Orderer ${orgNames[$itr]} ${OrgPortNumbers[$itr]} 
      fi
        itr=`expr $itr + 1`
    done
}

echo2(){
  echo 
  echo $@
  echo 
}
echo3(){
  echo ------------------------------------------------------------------------------
  echo $@
  echo ------------------------------------------------------------------------------
}

createcertificatesForOrg() {
  OrgName=$1
  PeerCount=$2
  PortNo=$3 

  echo3 "Creating Certificates for Organization : ${OrgName}  PeerCount= $2 PortNo= $3"

  echo2 "Enroll the CA admin For ${OrgName}"
  mkdir -p crypto-config-ca/peerOrganizations/${OrgName}.example.com/
  export FABRIC_CA_CLIENT_HOME=${PWD}/crypto-config-ca/peerOrganizations/${OrgName}.example.com/
  
  fabric-ca-client enroll -u https://admin:adminpw@localhost:${PortNo} --caname ca.${OrgName}.example.com --tls.certfiles ${PWD}/fabric-ca/${OrgName}/tls-cert.pem

  echo "NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-${PortNo}-ca-${OrgName}-example-com.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-${PortNo}-ca-${OrgName}-example-com.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-${PortNo}-ca-${OrgName}-example-com.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-${PortNo}-ca-${OrgName}-example-com.pem
    OrganizationalUnitIdentifier: orderer" >${PWD}/crypto-config-ca/peerOrganizations/${OrgName}.example.com/msp/config.yaml

  echo2 Registering Peers

  peerItr=0
  while [ $peerItr -lt $PeerCount ]
  do
    echo2 "Registering Peer${peerItr}"
    fabric-ca-client register --caname "ca.${OrgName}.example.com" --id.name "peer${peerItr}" --id.secret "peer${peerItr}pw" --id.type peer --tls.certfiles ${PWD}/fabric-ca/${OrgName}/tls-cert.pem
    peerItr=`expr $peerItr + 1`
  done

  echo2 "Register the org admin"
  fabric-ca-client register --caname ca.${OrgName}.example.com --id.name ${OrgName}admin --id.secret ${OrgName}adminpw --id.type admin --tls.certfiles ${PWD}/fabric-ca/${OrgName}/tls-cert.pem

  echo2 "Register user"
  fabric-ca-client register --caname ca.${OrgName}.example.com --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/fabric-ca/${OrgName}/tls-cert.pem

  mkdir -p crypto-config-ca/peerOrganizations/${OrgName}.example.com/peers

  # -----------------------------------------------------------------------------------
  #  Peer i
  peerItr=0
  while [ $peerItr -lt 1 ]
  do
    echo3 Registering Peer${peerItr}
    
    mkdir -p crypto-config-ca/peerOrganizations/${OrgName}.example.com/peers/peer${peerItr}.${OrgName}.example.com

    echo2 "## Generate the peer${peerItr} msp"
    fabric-ca-client enroll -u https://peer${peerItr}:peer${peerItr}pw@localhost:${PortNo} --caname ca.${OrgName}.example.com -M ${PWD}/crypto-config-ca/peerOrganizations/${OrgName}.example.com/peers/peer${peerItr}.${OrgName}.example.com/msp --csr.hosts peer${peerItr}.${OrgName}.example.com --tls.certfiles ${PWD}/fabric-ca/${OrgName}/tls-cert.pem
 
    cp ${PWD}/crypto-config-ca/peerOrganizations/${OrgName}.example.com/msp/config.yaml ${PWD}/crypto-config-ca/peerOrganizations/${OrgName}.example.com/peers/peer${peerItr}.${OrgName}.example.com/msp/config.yaml

    echo2 "## Generate the peer${peerItr}-tls certificates"
    fabric-ca-client enroll -u https://peer${peerItr}:peer${peerItr}pw@localhost:${PortNo} --caname ca.${OrgName}.example.com -M ${PWD}/crypto-config-ca/peerOrganizations/${OrgName}.example.com/peers/peer${peerItr}.${OrgName}.example.com/tls --enrollment.profile tls --csr.hosts peer${peerItr}.${OrgName}.example.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/${OrgName}/tls-cert.pem

    cp ${PWD}/crypto-config-ca/peerOrganizations/${OrgName}.example.com/peers/peer${peerItr}.${OrgName}.example.com/tls/tlscacerts/* ${PWD}/crypto-config-ca/peerOrganizations/${OrgName}.example.com/peers/peer${peerItr}.${OrgName}.example.com/tls/ca.crt
    cp ${PWD}/crypto-config-ca/peerOrganizations/${OrgName}.example.com/peers/peer${peerItr}.${OrgName}.example.com/tls/signcerts/* ${PWD}/crypto-config-ca/peerOrganizations/${OrgName}.example.com/peers/peer${peerItr}.${OrgName}.example.com/tls/server.crt
    cp ${PWD}/crypto-config-ca/peerOrganizations/${OrgName}.example.com/peers/peer${peerItr}.${OrgName}.example.com/tls/keystore/* ${PWD}/crypto-config-ca/peerOrganizations/${OrgName}.example.com/peers/peer${peerItr}.${OrgName}.example.com/tls/server.key

    mkdir ${PWD}/crypto-config-ca/peerOrganizations/${OrgName}.example.com/msp/tlscacerts
    cp ${PWD}/crypto-config-ca/peerOrganizations/${OrgName}.example.com/peers/peer${peerItr}.${OrgName}.example.com/tls/tlscacerts/* ${PWD}/crypto-config-ca/peerOrganizations/${OrgName}.example.com/msp/tlscacerts/ca.crt

    mkdir ${PWD}/crypto-config-ca/peerOrganizations/${OrgName}.example.com/tlsca
    cp ${PWD}/crypto-config-ca/peerOrganizations/${OrgName}.example.com/peers/peer${peerItr}.${OrgName}.example.com/tls/tlscacerts/* ${PWD}/crypto-config-ca/peerOrganizations/${OrgName}.example.com/tlsca/tlsca.${OrgName}.example.com-cert.pem

    mkdir ${PWD}/crypto-config-ca/peerOrganizations/${OrgName}.example.com/ca
    cp ${PWD}/crypto-config-ca/peerOrganizations/${OrgName}.example.com/peers/peer${peerItr}.${OrgName}.example.com/msp/cacerts/* ${PWD}/crypto-config-ca/peerOrganizations/${OrgName}.example.com/ca/ca.${OrgName}.example.com-cert.pem


    peerItr=`expr $peerItr + 1`
  done


  # --------------------------------------------------------------------------------------------------

  mkdir -p crypto-config-ca/peerOrganizations/${OrgName}.example.com/users
  mkdir -p crypto-config-ca/peerOrganizations/${OrgName}.example.com/users/User1@${OrgName}.example.com

  echo2 "## Generate the user msp"
  fabric-ca-client enroll -u https://user1:user1pw@localhost:${PortNo} --caname ca.${OrgName}.example.com -M ${PWD}/crypto-config-ca/peerOrganizations/${OrgName}.example.com/users/User1@${OrgName}.example.com/msp --tls.certfiles ${PWD}/fabric-ca/${OrgName}/tls-cert.pem

  mkdir -p crypto-config-ca/peerOrganizations/${OrgName}.example.com/users/Admin@${OrgName}.example.com

  echo
  echo "## Generate the org admin msp"
  echo
  fabric-ca-client enroll -u https://${OrgName}admin:${OrgName}adminpw@localhost:${PortNo} --caname ca.${OrgName}.example.com -M ${PWD}/crypto-config-ca/peerOrganizations/${OrgName}.example.com/users/Admin@${OrgName}.example.com/msp --tls.certfiles ${PWD}/fabric-ca/${OrgName}/tls-cert.pem

  cp ${PWD}/crypto-config-ca/peerOrganizations/${OrgName}.example.com/msp/config.yaml ${PWD}/crypto-config-ca/peerOrganizations/${OrgName}.example.com/users/Admin@${OrgName}.example.com/msp/config.yaml


}
  

createCertificatesForOrderer(){
  # TODO: Change Orderer Certificates (Generate from Above Config)

  echo3 Orederer CA
  echo
  echo "Enroll the CA admin"
  echo
  mkdir -p crypto-config-ca/ordererOrganizations/example.com

  export FABRIC_CA_CLIENT_HOME=${PWD}/crypto-config-ca/ordererOrganizations/example.com

   
  fabric-ca-client enroll -u https://admin:adminpw@localhost:9054 --caname ca-orderer --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/crypto-config-ca/ordererOrganizations/example.com/msp/config.yaml

  echo
  echo "Register orderer"
  echo
   
  fabric-ca-client register --caname ca-orderer --id.name orderer --id.secret ordererpw --id.type orderer --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  echo
  echo "Register orderer2"
  echo
   
  fabric-ca-client register --caname ca-orderer --id.name orderer2 --id.secret ordererpw --id.type orderer --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  echo
  echo "Register orderer3"
  echo
   
  fabric-ca-client register --caname ca-orderer --id.name orderer3 --id.secret ordererpw --id.type orderer --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  echo
  echo "Register the orderer admin"
  echo
   
  fabric-ca-client register --caname ca-orderer --id.name ordererAdmin --id.secret ordererAdminpw --id.type admin --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  mkdir -p crypto-config-ca/ordererOrganizations/example.com/orderers
  # mkdir -p crypto-config-ca/ordererOrganizations/example.com/orderers/example.com

  # ---------------------------------------------------------------------------
  #  Orderer

  mkdir -p crypto-config-ca/ordererOrganizations/example.com/orderers/orderer.example.com

  echo
  echo "## Generate the orderer msp"
  echo
   
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9054 --caname ca-orderer -M ${PWD}/crypto-config-ca/ordererOrganizations/example.com/orderers/orderer.example.com/msp --csr.hosts orderer.example.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  cp ${PWD}/crypto-config-ca/ordererOrganizations/example.com/msp/config.yaml ${PWD}/crypto-config-ca/ordererOrganizations/example.com/orderers/orderer.example.com/msp/config.yaml

  echo
  echo "## Generate the orderer-tls certificates"
  echo
   
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9054 --caname ca-orderer -M ${PWD}/crypto-config-ca/ordererOrganizations/example.com/orderers/orderer.example.com/tls --enrollment.profile tls --csr.hosts orderer.example.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  cp ${PWD}/crypto-config-ca/ordererOrganizations/example.com/orderers/orderer.example.com/tls/tlscacerts/* ${PWD}/crypto-config-ca/ordererOrganizations/example.com/orderers/orderer.example.com/tls/ca.crt
  cp ${PWD}/crypto-config-ca/ordererOrganizations/example.com/orderers/orderer.example.com/tls/signcerts/* ${PWD}/crypto-config-ca/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.crt
  cp ${PWD}/crypto-config-ca/ordererOrganizations/example.com/orderers/orderer.example.com/tls/keystore/* ${PWD}/crypto-config-ca/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.key

  mkdir ${PWD}/crypto-config-ca/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts
  cp ${PWD}/crypto-config-ca/ordererOrganizations/example.com/orderers/orderer.example.com/tls/tlscacerts/* ${PWD}/crypto-config-ca/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

  mkdir ${PWD}/crypto-config-ca/ordererOrganizations/example.com/msp/tlscacerts
  cp ${PWD}/crypto-config-ca/ordererOrganizations/example.com/orderers/orderer.example.com/tls/tlscacerts/* ${PWD}/crypto-config-ca/ordererOrganizations/example.com/msp/tlscacerts/tlsca.example.com-cert.pem

  # -----------------------------------------------------------------------
  #  Orderer 2

  mkdir -p crypto-config-ca/ordererOrganizations/example.com/orderers/orderer2.example.com

  echo
  echo "## Generate the orderer msp"
  echo
   
  fabric-ca-client enroll -u https://orderer2:ordererpw@localhost:9054 --caname ca-orderer -M ${PWD}/crypto-config-ca/ordererOrganizations/example.com/orderers/orderer2.example.com/msp --csr.hosts orderer2.example.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  cp ${PWD}/crypto-config-ca/ordererOrganizations/example.com/msp/config.yaml ${PWD}/crypto-config-ca/ordererOrganizations/example.com/orderers/orderer2.example.com/msp/config.yaml

  echo
  echo "## Generate the orderer-tls certificates"
  echo
   
  fabric-ca-client enroll -u https://orderer2:ordererpw@localhost:9054 --caname ca-orderer -M ${PWD}/crypto-config-ca/ordererOrganizations/example.com/orderers/orderer2.example.com/tls --enrollment.profile tls --csr.hosts orderer2.example.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  cp ${PWD}/crypto-config-ca/ordererOrganizations/example.com/orderers/orderer2.example.com/tls/tlscacerts/* ${PWD}/crypto-config-ca/ordererOrganizations/example.com/orderers/orderer2.example.com/tls/ca.crt
  cp ${PWD}/crypto-config-ca/ordererOrganizations/example.com/orderers/orderer2.example.com/tls/signcerts/* ${PWD}/crypto-config-ca/ordererOrganizations/example.com/orderers/orderer2.example.com/tls/server.crt
  cp ${PWD}/crypto-config-ca/ordererOrganizations/example.com/orderers/orderer2.example.com/tls/keystore/* ${PWD}/crypto-config-ca/ordererOrganizations/example.com/orderers/orderer2.example.com/tls/server.key

  mkdir ${PWD}/crypto-config-ca/ordererOrganizations/example.com/orderers/orderer2.example.com/msp/tlscacerts
  cp ${PWD}/crypto-config-ca/ordererOrganizations/example.com/orderers/orderer2.example.com/tls/tlscacerts/* ${PWD}/crypto-config-ca/ordererOrganizations/example.com/orderers/orderer2.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

  # mkdir ${PWD}/crypto-config-ca/ordererOrganizations/example.com/msp/tlscacerts
  # cp ${PWD}/crypto-config-ca/ordererOrganizations/example.com/orderers/orderer2.example.com/tls/tlscacerts/* ${PWD}/crypto-config-ca/ordererOrganizations/example.com/msp/tlscacerts/tlsca.example.com-cert.pem

  # ---------------------------------------------------------------------------
  #  Orderer 3
  mkdir -p crypto-config-ca/ordererOrganizations/example.com/orderers/orderer3.example.com

  echo
  echo "## Generate the orderer msp"
  echo
   
  fabric-ca-client enroll -u https://orderer3:ordererpw@localhost:9054 --caname ca-orderer -M ${PWD}/crypto-config-ca/ordererOrganizations/example.com/orderers/orderer3.example.com/msp --csr.hosts orderer3.example.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  cp ${PWD}/crypto-config-ca/ordererOrganizations/example.com/msp/config.yaml ${PWD}/crypto-config-ca/ordererOrganizations/example.com/orderers/orderer3.example.com/msp/config.yaml

  echo
  echo "## Generate the orderer-tls certificates"
  echo
   
  fabric-ca-client enroll -u https://orderer3:ordererpw@localhost:9054 --caname ca-orderer -M ${PWD}/crypto-config-ca/ordererOrganizations/example.com/orderers/orderer3.example.com/tls --enrollment.profile tls --csr.hosts orderer3.example.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  cp ${PWD}/crypto-config-ca/ordererOrganizations/example.com/orderers/orderer3.example.com/tls/tlscacerts/* ${PWD}/crypto-config-ca/ordererOrganizations/example.com/orderers/orderer3.example.com/tls/ca.crt
  cp ${PWD}/crypto-config-ca/ordererOrganizations/example.com/orderers/orderer3.example.com/tls/signcerts/* ${PWD}/crypto-config-ca/ordererOrganizations/example.com/orderers/orderer3.example.com/tls/server.crt
  cp ${PWD}/crypto-config-ca/ordererOrganizations/example.com/orderers/orderer3.example.com/tls/keystore/* ${PWD}/crypto-config-ca/ordererOrganizations/example.com/orderers/orderer3.example.com/tls/server.key

  mkdir ${PWD}/crypto-config-ca/ordererOrganizations/example.com/orderers/orderer3.example.com/msp/tlscacerts
  cp ${PWD}/crypto-config-ca/ordererOrganizations/example.com/orderers/orderer3.example.com/tls/tlscacerts/* ${PWD}/crypto-config-ca/ordererOrganizations/example.com/orderers/orderer3.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

  # mkdir ${PWD}/crypto-config-ca/ordererOrganizations/example.com/msp/tlscacerts
  # cp ${PWD}/crypto-config-ca/ordererOrganizations/example.com/orderers/orderer3.example.com/tls/tlscacerts/* ${PWD}/crypto-config-ca/ordererOrganizations/example.com/msp/tlscacerts/tlsca.example.com-cert.pem

  # ---------------------------------------------------------------------------

  mkdir -p crypto-config-ca/ordererOrganizations/example.com/users
  mkdir -p crypto-config-ca/ordererOrganizations/example.com/users/Admin@example.com

  echo
  echo "## Generate the admin msp"
  echo
   
  fabric-ca-client enroll -u https://ordererAdmin:ordererAdminpw@localhost:9054 --caname ca-orderer -M ${PWD}/crypto-config-ca/ordererOrganizations/example.com/users/Admin@example.com/msp --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  cp ${PWD}/crypto-config-ca/ordererOrganizations/example.com/msp/config.yaml ${PWD}/crypto-config-ca/ordererOrganizations/example.com/users/Admin@example.com/msp/config.yaml

}


echo3 Starting CA containers...

create_DockerComposer_Yaml
sudo rm -rf fabric-ca/*
docker-compose -f ./docker-compose.yaml up -d
docker ps

sleep 5

sudo rm -rf crypto-config-ca/*

itr=0
while [ $itr -lt $num_organizaions ]
do
  if [ ${IsOrdererOrg[$itr]} -eq 0 ]; then
    createcertificatesForOrg ${orgNames[$itr]} ${peers_per_Org[$itr]} ${OrgPortNumbers[$itr]} 
  else 
    createCertificatesForOrderer 
  fi
  itr=`expr $itr + 1`
done

echo3 All certificates are generated...