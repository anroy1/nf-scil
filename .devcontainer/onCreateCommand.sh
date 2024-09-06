#!/usr/bin/env bash

# Setup for NF-CORE

npm install -g --save-dev --save-exact prettier
npm install -g editorconfig
npm install -g --save-dev editorconfig-checker

mkdir -p $XDG_CONFIG_HOME/nf-scil
touch $XDG_CONFIG_HOME/nf-scil/.env
echo "source $XDG_CONFIG_HOME/nf-scil/.env" >> ~/.bashrc

mkdir -p /nf-test/bin
cd /nf-test/bin/
curl -fsSL https://code.askimed.com/install/nf-test | bash -s ${NFTEST_VERSION}
echo "PATH=$PATH:/nf-test/bin" >> ~/.bashrc


# Setup for VSCODE Extensions Development

npm install -g typescript
npm install -g tslint
npm install -g yo generator-code
