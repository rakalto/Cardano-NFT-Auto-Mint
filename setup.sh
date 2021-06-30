wget https://hydra.iohk.io/build/6797922/download/1/cardano-node-1.27.0-linux.tar.gz
tar xzvf cardano-node-1.27.0-linux.tar.gz
mkdir mainnetconfig && cd mainnetconfig
wget https://hydra.iohk.io/build/6782523/download/1/mainnet-config.json
wget https://hydra.iohk.io/build/6782523/download/1/mainnet-byron-genesis.json
wget https://hydra.iohk.io/build/6782523/download/1/mainnet-shelley-genesis.json
wget https://hydra.iohk.io/build/6782523/download/1/mainnet-alonzo-genesis.json
wget https://hydra.iohk.io/build/6782523/download/1/mainnet-topology.json
cd ..

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
