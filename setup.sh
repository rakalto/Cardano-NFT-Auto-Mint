wget https://hydra.iohk.io/build/6797922/download/1/cardano-node-1.27.0-linux.tar.gz
tar xzvf cardano-node-1.27.0-linux.tar.gz
rm cardano-node-1.27.0-linux.tar.gz

./cardano-node run --topology ./mainnetconfig/mainnet-topology.json --database-path ./state-mainnet --port 3001
--config ./mainnetconfig/mainnet-config.json --socket-path ~/cardano-mainnet.socket
export CARDANO_NODE_SOCKET_PATH=~/cardano-mainnet.socket

mkdir payment
cd payment/

cardano-cli address key-gen \
--verification-key-file payment.vkey \
--signing-key-file payment.skey

cardano-cli address build \
--payment-verification-key-file payment.vkey \
--out-file payment.addr \
--mainnet

echo $(cat ./payment.addr)

cd ..

mkdir policy

cardano-cli address key-gen \
--verification-key-file policy/policy.vkey \
--signing-key-file policy/policy.skey

touch policy/policy.script && echo "" > policy/policy.script

echo "{" >> policy/policy.script 
echo "  \"keyHash\": \"$(cardano-cli address key-hash --payment-verification-key-file policy/policy.vkey)\"," >> policy/policy.script 
echo "  \"type\": \"sig\"" >> policy/policy.script 
echo "}" >> policy/policy.script

cardano-cli transaction policyid --script-file ./policy/policy.script >> policy/policyID
echo $(cat policy/policyID)
