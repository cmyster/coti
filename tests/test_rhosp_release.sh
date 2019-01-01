# Test parameters.
NAME="Version in rhosp-release"
DESCRIPTION="Testing that the overcloud version is set correctly in /etc/rhosp-release"
TAG="overcloud"

# Exit on the first error.
set -e

# Source the environment and the project's configuration.
. /home/stack/stackrc
. /home/stack/tests/env

# Test starts here.
for ip in $(openstack server list -f value -c Name -c Networks | cut -d "=" -f 2)
do
    ssh heat-admin@$ip "sudo grep $OS_VER /etc/rhosp-release &> /dev/null"
done
