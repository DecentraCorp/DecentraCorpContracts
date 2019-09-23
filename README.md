# DecentraCorp

This project is in its Alpha Phase and is undergoing continual changes.
The Alpha Version can be visited at decentracorp.now.sh
A web3 enabled browser is required to use this dApp and it is currently NOT mobile optimized!

These steps will walk you through setting up DecentraCorps Proof of Authority Network and
deploying the contract backends to it

Install Dependencies(linux)

Dependencies:
node.js && npm:

sudo apt-get update
sudo apt install curl

curl -sL https://deb.nodesource.com/setup_10.x | sudo bash -

sudo apt install nodejs npm

yarn:

curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

sudo apt-get update && sudo apt-get install yarn


truffle:

npm install -g truffle <-----may require sudo depending on configuration




steps to set up a personal development environment (linux)

cd to directory you wish to work in and git clone the project:

git clone https://github.com/stan36/DecentraCorp.git


cd into DecentraCorp --> front

run command:
yarn Install

after install finishes run "yarn start" to start the development server. All React components are in the src file in front
