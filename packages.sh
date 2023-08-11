
# Install all dependencies
echo "packegs 1"
apt-get -y update
apt-get -qq -y install $(cat ./scripts/tl/pkglist)
echo "packages 2"
