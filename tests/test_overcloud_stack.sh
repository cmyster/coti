# Test parameters.
NAME="heat stack status"
DESCRIPTION="Testing that the overcloud stack status is CREATE_COMPLETE."
TAG="overcloud"

# Exit on the first error.
set -e

# Source the environment and the project's configuration.
. /home/stack/stackrc
. /home/stack/tests/env

# Test starts here.
openstack stack list | grep -e overcloud.*CREATE_COMPLETE &> /dev/null
