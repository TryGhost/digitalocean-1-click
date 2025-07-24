##############################
## PART: install NodeJS:
##
## vi: syntax=sh expandtab ts=4

# Replace with the branch of Node.js or io.js you want to install: node_6.x, node_8.x, etc...
VERSION=${NODE_VERSION}

# Create a directory for the new repository's keyring, if it doesn't exist
mkdir -p /etc/apt/keyrings
# Download the new repository's GPG key and save it in the keyring directory
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
# Add the new repository's source list with its GPG key for package verification
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_${VERSION}.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list

# Yarn
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

apt-get -qqy update
apt-get -qqy install nodejs yarn
