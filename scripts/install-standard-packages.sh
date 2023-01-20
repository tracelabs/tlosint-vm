#!/bin/sh

# Mimic tasksel definition of "standard packages" by excluding libraries.
# Additionally, exclude standard packages that are not present in the Kali
# images created by the Kali installer (the reason why they're not present
# is unknown).

set -eu

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y '?priority(standard) !?section(lib) !(~napt-listchanges|~ndebian-faq|~ndoc-debian|~npython3-reportbug|~nreportbug|~nwamerican)'
apt-get clean
