# Test parameters.
NAME="Test rhosp-version"
DESCRIPTION="Testing that the overcloud version is set correctly in /etc/rhosp-version"
TAG="overcloud"

# Source the environment and the project's configuration.
source /home/stack/stackrc 2> /dev/null
source /home/stack/tests/env 2> /dev/null

# Exit on the first error.
set -e

# Test starts here.
for ip in $(openstack server list -f value -c Name -c Networks | cut -d "=" -f 2)
do
    $SSH heat-admin@$ip "sudo grep $OC_VER /etc/rhosp-version &> /dev/null"
done
