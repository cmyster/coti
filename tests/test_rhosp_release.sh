# Test parameters.
NAME="Test rhosp release"
DESCRIPTION="Testing that the overcloud version is set correctly in /etc/rhosp-release"
TAG="overcloud"

# Source the environment and the project's configuration.
source /home/stack/stackrc 2> /dev/null
source /home/stack/tests/env 2> /dev/null

# Exit on the first error.
set -e

# Test starts here.
for ip in $(openstack server list -f value -c Name -c Networks | cut -d "=" -f 2)
do
    $SSH heat-admin@$ip "sudo grep $OS_VER /etc/rhosp-release &> /dev/null"
done
