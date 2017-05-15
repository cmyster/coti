# Test parameters.
NAME="Test example"
DESCRIPTION="This is just an example."
TAG="example"

# Source the environment and the project's configuration.                     
source /home/stack/stackrc 2> /dev/null                                       
source /home/stack/tests/env 2> /dev/null                                     
                                                                              
# Exit on the first error.                                                    
set -e

# Test starts here.
echo "Example!"
