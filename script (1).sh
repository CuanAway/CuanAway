#!/bin/bash
echo #Installing dependencies
apt-get update
apt-get install curl wget git -y
apt-get install screen -y
apt-get install nano
echo #Installing nodejs v16
curl -sL https://deb.nodesource.com/setup_16.x -o /tmp/nodesource_setup.sh
bash /tmp/nodesource_setup.sh
apt-get install -y nodejs
echo #Installing 3DP 
cd ~
git clone https://github.com/3Dpass/3DP.git
cd 3DP
echo # Installing rust setup
curl https://sh.rustup.rs -sSf | sh -s -- -y --default-toolchain nightly
source $HOME/.cargo/env
rustup update nightly
rustup target add wasm32-unknown-unknown --toolchain nightly
apt-get install -y libclang-dev libssl-dev clang
cd ~/3DP
cargo build --bin poscan-consensus --release
echo #Installing miner
cd ~
git clone https://github.com/3Dpass/miner
cd miner
npm install
echo #Deploy minerkeys change your keys!!!
cd ~/3DP
./target/release/poscan-consensus import-mining-key 'MEMO_SEED' --base-path ~/3dp-chain/ --chain testnetSpecRaw.json
./target/release/poscan-consensus key insert --base-path ~/3dp-chain/ --chain testnetSpecRaw.json --scheme Ed25519 --suri URI_SEED --key-type gran
echo # Checking is both keys succsefull deployed you must see 2 hash id
ls ~/3dp-chain/chains/3dp/keystore
echo # Entering in screen and execute
screen -S miner -m -d bash -c "cd ~/miner && node miner.js"
cd ~/3DP && ./target/release/poscan-consensus --base-path ~/3dp-chain/ --chain testnetSpecRaw.json --name NODE_NAME --validator --telemetry-url "wss://telemetry.polkadot.io/submit/ 0" --author PUBLIC_ADDRESS