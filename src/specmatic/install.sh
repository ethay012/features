#!/bin/sh
set -e

export DEBIAN_FRONTEND=noninteractive

echo "Installing Java"

# Install OpenJDK 17, git, and curl
apt-get update 
apt-get install -y --no-install-recommends openjdk-17-jre git curl 
apt-get clean 

echo "Installing Specmatic"

mkdir /opt/specmatic
curl -L https://github.com/znsio/specmatic/releases/download/2.0.15/specmatic.jar --output /opt/specmatic/specmatic.jar

echo "#!/bin/bash" >> /opt/specmatic/specmatic.sh
echo 'java -jar /opt/specmatic/specmatic.jar "$@"' >> /opt/specmatic/specmatic.sh
chmod +x /opt/specmatic/specmatic.sh
ln -s /opt/specmatic/specmatic.sh /usr/bin/specmatic
