# Installation of java on runner
apt-get update
apt-get install -y default-jre
java -version
sudo apt install openjdk-11-jdk-headless
apt-get install maven -y
mvn -version
mvn install
#mvn clean install license:aggregate-add-third-party
mvn clean install license:aggregate-add-third-party -DskipTests
mvn -B versions:display-dependency-updates > outdated.txt
