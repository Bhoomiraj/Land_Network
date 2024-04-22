
export num_organizaions=3
orgNames=("org1"  "org2" "orderer")
OrgPortNumbers=(8054  12054 10054)
peers_per_Org=(15  15 0)
Orderers_per_Org=(0 0 3)
IsOrdererOrg=(0 0 1)
users_per_org=(30 30 1)


# cryptogen or CA
export Crypto_material="cryptogen";


cd artifacts/channel
./create-artifacts.sh
cd ../..