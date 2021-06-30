wget https://hydra.iohk.io/build/6797922/download/1/cardano-node-1.27.0-linux.tar.gz
tar xzvf cardano-node-1.27.0-linux.tar.gz
rm cardano-node-1.27.0-linux.tar.gz

./cardano-node run \
--topology mainnet-topology.json \
--database-path /db \
--socket-path /db/node.socket \
--host-addr $(ip -4 addr show ens3 | grep -oP '(?<=inet\s)\d+(\.\d+){3}') \
--port 3001 \
--config configuration/cardano/mainnet-config.json

mkdir nft-payment
cd nft-payment

cardano-cli address key-gen \
--verification-key-file nftpayment.vkey \
--signing-key-file nftpayment.skey

cardano-cli address build \
--payment-verification-key-file nftpayment.vkey \
--out-file nftpayment.addr \
--mainnet

echo $(cat ./nftpayment.addr)

cd ..

mkdir nft-policy

cardano-cli address key-gen \
--verification-key-file nft-policy/nftpolicy.vkey \
--signing-key-file nft-policy/nftpolicy.skey

touch nft-policy/nftpolicy.script && echo "" > nft-policy/nftpolicy.script

echo "{" >> nft-policy/nftpolicy.script 
echo "  \"keyHash\": \"$(cardano-cli address key-hash --payment-verification-key-file nft-policy/nftpolicy.vkey)\"," >> nft-policy/nftpolicy.script 
echo "  \"type\": \"sig\"" >> nft-policy/nftpolicy.script 
echo "}" >> nft-policy/nftpolicy.script

cardano-cli transaction policyid --script-file ./nft-policy/nftpolicy.script >> nft-policy/nftpolicyID
echo $(cat nft-policy/nftpolicyID)
