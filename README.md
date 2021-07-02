# Cardano NFT Vending Machine

*Disclaimer: This software is provided as-is with no warranty. I take no responsibility for lost funds while using this system.*

*I HIGHLY recommend you point your "profit address" to a local wallet rather than another payment address storing funds on the node or an exchange, ideally on a hardware wallet e.g. Ledger.*

Forked from *ejane24*'s original project so I can mess about with it for my own needs. Feel free to use it. Any significant changes will be documented here if (or when) they happen.

The *setup-nft-vendor.sh* file is an addition created for this fork that will automate setup of this NFT "vending machine." It is still in development so may not work just yet.

To automate the setup of the Cardano node itself [this is an excellent resource.](https://cardano-community.github.io/guild-operators/#/basics) Note that while that set of scripts is aimed at people setting up a stake pool, you simply need to run a "relay node" to mint NFTs, which is the default behaviour when installing with that script. Additionally, you don't need to open the port used for the node in your firewall.

This fork has been modified to assume you have installed your Cardano node using the Guild Operators script. If this is not the case you may have to change the paths.

In the future I will add smart contract functionality to the main script once the Alonzo update comes to the mainnet. This will enable you to do cool stuff like collect a percentage royalty whenever your NFT is resold.

## What is this software?

This is an automated minting and distribution system for Cardano NFTs. It is designed to allow small creators to automate their sales with as little hassle as possible!

With this installed and set up, you just provide a Cardano address and a price you set (more on how to do this below) and people will be able to send the correct amount of ADA and have an NFT minted and sent right to their wallet automatically.

## Requirements

To use this software you will need:
* A fully synced Cardano node using version 1.27.0
* A Linux (tested on Ubuntu) system/VPS (if using a VPS use mid-range spec, a basic $5 one won't have the resources for a Cardano node)
* Basic knowledge of Cardano-CLI commands (although most commands will be explained)
* Pre-created policy script and signing key.
* A Blockfrost mainnet account and project ID (API key).

## Installation

### Step 1 - Download the script
To get started with the system it is first necessary to download the files.

First cd into the directory where your node is running (~/git if you used the Guild scripts) and run the following commands:
```
git clone https://github.com/ftpmorph/Cardano-NFT-Auto-Mint.git
cd Cardano-NFT-Auto-Mint
ls
```

You should now see 4 files listed, the important one is *process.sh*.

### Step 2 - Create the payment address

Now we need create a payment address where your buyers will send ada!
First make a folder to contain the keys:

```
mkdir payment
cd payment/
```

Now generate the address keys:

```
cardano-cli address key-gen \
--verification-key-file payment.vkey \
--signing-key-file payment.skey
```

Then we need to build an actual address:

```
cardano-cli address build \
--payment-verification-key-file payment.vkey \
--out-file payment.addr \
--mainnet
```

You can view the address by typing:

```
echo $(cat ./payment.addr)
```

You will need this later.

### Step 3 - Update the file

We need to update a few things in process.sh before we can set it running:

```
cd ..
nano process.sh
```

Firstly on lines 8-11 we need to add the payment address that we created earlier, as well as add the paths to the payment and policy skey files. If you follow this guide the default paths for the payment and policy keys and scripts should be correct.

For example:
```
paymentAddr=addr1.....
paymentSignKeyPath=./payment/payment.skey
policySignKeyPath=./policy/policy.skey
scriptPath=./policy/policy.script
```

On line 12 we need to add the address that profits will be sent to:

```
profitAddress=addr1....
```

Now we need to add the Blockfrost project ID on lines 41 and 44 where it currently says 'Insert here'.

Once you have done that, we need to change how much your NFTs cost. 

To do this, go to line 48 and change 15000000 to your price in **lovelace**. 1 ADA = 1,000,000 lovelace. [Here is a calculator](https://bluehares.com/cardano-ada-lovelace-calculator/) to double check your values are correct.

Next change the value of *amountToSendProfit* on line 90 to your price in lovelace minus 6700000. This accounts for the 1.7 ADA sent back to the user and a 5 ADA voluntary donation (more on that later).

#### Voluntary Donations
The script includes a voluntary donation on 5 ADA per sale. It is completely up to you whether you leave this in. To remove the donation, simply change line 8 to your own address. You can also increase or decrease this amount as you like but don't forget to update the profit amount. (although there needs to be at least 1 ADA for the transaction to work, hence changing the donation address is best).

### Step 4 - Add the metadata

Now we need to make a folder which will contain all the NFT metadata json files. Make sure this is is created in the same directory as *process.sh*.

```
mkdir metadata
```

Next, simply place all the metadata files (one for each NFT) in this folder as .json files. For example NFT01.json, NFT02.json...

### Step 5 - Create a systemctl process

In order for the system to run 24/7 we need to create a systemd service:

```
nano /etc/systemd/system/vendingmachine.service
```

Now paste the following into the text editor:

```
[Unit]
Description=NFT Vending Machine

[Service]
Environment="CARDANO_NODE_SOCKET_PATH=/opt/cardano/cnode/sockets/node0.socket"
ExecStart=/usr/bin/vendingmachine.sh
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
```

Save and exit the file and then type:

```
cp process.sh /usr/bin/vendingmachine.sh
```

Before this will work we need to make sure *cardano-cli* and *cardano-node* are in system directories. The Guild setup puts those programs in your home folder which won't work for a systemd service.

Thankfully this is easy to fix with two commands:

```
sudo cp ~/.cabal/bin/cardano-cli /usr/bin/cardano-cli
sudo cp ~/.cabal/bin/cardano-node /usr/bin/cardano-node
```

Next we need to start and enable the service:

```
sudo systemctl enable vendingmachine.service
sudo systemctl start vendingmachine.service
```

Check the service is working by typing:

```
sudo systemctl status vendingmachine.service
```

It should show no errors and you're all set.

You can also check the log file of the script itself which is still in your home folder:

```
cat ~/git/Cardano-NFT-Auto-Mint/log_file.txt
```

If all is working as it should, you should see logs of past transactions (if there are any) and logs showing the times the process started.

You are now set up to automatically mint and distribute your NFTs!
