##############################
## PART: install NodeJS:
##
## vi: syntax=sh expandtab ts=4

curl -sSL https://deb.nodesource.com/gpgkey/nodesource.gpg.key | sudo apt-key add -

# Replace with the branch of Node.js or io.js you want to install: node_6.x, node_8.x, etc...
VERSION=${NODE_VERSION}

# Add Node.js repository
curl -fsSL https://deb.nodesource.com/setup_$VERSION.x | bash -

# Yarn
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

apt-get -qqy update
apt-get -qqy install nodejs yarn
