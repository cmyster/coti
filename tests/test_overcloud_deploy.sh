# Test parameters.
NAME="overcloud deploy status"
DESCRIPTION="Testing that the overcloud status is reporting success."
TAG="overcloud"

# Exit on the first error.
set -e

# Source the environment and the project's configuration.
. /home/stack/stackrc
. /home/stack/tests/env

# Test starts here.
openstack overcloud status | grep DEPLOY_SUCCESS &> /dev/null
