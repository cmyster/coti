# Test parameters.
NAME="Example test"
DESCRIPTION="This is just an example."
TAG="example"

# Exit on the first error.
set -e

# Source the environment and the project's configuration.
. /home/stack/stackrc
. /home/stack/tests/env

# Test starts here.
echo "Example!"
