curl -L https://nixos.org/nix/install > install-nix.sh
chmod +x install-nix.sh
./install-nix.sh
. /home/$(whoami)/.nix-profile/etc/profile.d/nix.sh
sudo mkdir -p /etc/nix

cat <<EOF | sudo tee /etc/nix/nix.conf \
substituters = https://cache.nixos.org https://hydra.iohk.io \
trusted-public-keys = iohk.cachix.org-1:DpRUyj7h7V830dp/i6Nti+NEO2/nhblbov/8MW7Rqoo= hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ= cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= \
EOF

git clone https://github.com/input-output-hk/cardano-node
cd cardano-node
nix-build -A scripts.mainnet.node -o mainnet-node-local

./mainnet-node-local/bin/cardano-node-mainnet
