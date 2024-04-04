#!/bin/bash

TOOL=$1
DISTRIBUTION=$2

# Download the tool
curl -L https://github.com/cloudquery/cloudquery/releases/download/$TOOL/$DISTRIBUTION -o cloudquery

# Download checksums
curl -L https://github.com/cloudquery/cloudquery/releases/download/$TOOL/checksums.txt -o checksums.txt

# Extract the checksum for the package
while read -r checksum file; do
  if [[ $file == $DISTRIBUTION ]]; then
    EXPECTED_CHECKSUM=$checksum
    break
  fi
done < checksums.txt

# Print the expected checksum
echo "Expected checksum: $EXPECTED_CHECKSUM"

# Calculate the actual checksum of the cloudquery file
ACTUAL_CHECKSUM=$(sha256sum cloudquery | awk '{print $1}')

# Print the actual checksum
echo "Actual checksum: $ACTUAL_CHECKSUM"

# Check if the checksums match
if [ "$EXPECTED_CHECKSUM" != "$ACTUAL_CHECKSUM" ]; then
  echo "Checksums do not match!"
  exit 1
else
  echo "Checksums match!"
fi

# # Make cloudquery executable
# chmod a+x cloudquery

# # Move cloudquery to /usr/local/bin/
# mv cloudquery /usr/local/bin/

# Remove checksums.txt
rm checksums.txt

# # Remove the cloudquery binary
# rm cloudquery