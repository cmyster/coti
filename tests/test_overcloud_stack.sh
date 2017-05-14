NAME="Test overcloud stack status"
DESCRIPTION="Testing that the overcloud stack status is CREATE_COMPLETE."
TAG="overcloud"
set -e
source /home/stack/stackrc
openstack stack list | grep -e overcloud.*CREATE_COMPLETE &> /dev/null
