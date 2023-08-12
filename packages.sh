# Install all dependencies
apt-get -y update
apt-get -qq -y install $(cat ./scripts/tl/pkglist)
