Containerised version of Brad Hughes Meshtastic-MQTT-MySQL application. 

Saw an opportunity to Containerise and simplify the deployment process using Docker ❤️

The proceeding README is taken from Brad's readme, I've added a section detailing containerisation. Also checkout the ChangeLog for changes to Brad's original files, this was to make them docker-compose friendly.

Chur!


# meshtastic-mqtt-mysql
This PHP-CLI script, which is run as a shell script daemon, runs permanently in the background, subscribes to the Meshtastic JSON topic on your MQTT server, captures messages delivered from the mesh via MQTT, and imports them into MySQL tables.

Assumed infrastructure layout is: Your Meshtastic Node => Your local MQTT server => PHP-CLI MQTT subscriber => MySQL server

This script will capture JSON mesh messages of the following types:

nodeinfo

neighborinfo

text

telemetry

position

traceroute

# Requirements:
This PHP-CLI script is designed to be run as a shell script in a LMPM configuration (Linux, MQTT, PHP-CLI, MySQL).

Dependencies are as follows:

A meshtastic ESP32V3 based node, for example, a Heltec V3 (nRF nodes don't support MQTT => JSON currently).

php8.2-cli (see <a href='https://php.watch/articles/install-php82-ubuntu-debian'>here</a> for installation instructions) 

php8.2-mysql (use "sudo apt install php8.2-mysql" after installing php8.2-cli)

PhpMqtt (use "composer require php-mqtt/client")

Your own local MQTT server (I use Mosquitto), configured to allow anonymous access

Your own local mysql-server - the database schema is provided in meshtastic.sql

# Instructions:
1) Setup your MQTT server, and configure it to allow anonymous access
2) Configure your Meshtastic node to publish MQTT messages to the IP address of your MQTT server, using the topic "Meshtastic". Make sure that the JSON option is enabled and that you disable encryption under the MQTT settings. TLS should be disabled, the username and password should be cleared (unless you have configured mqtt authentication)
3) Create your MySQL database. Call the database 'meshtastic'. You can use the database schema found in file meshtastic.sql
4) Create a user on your MySQL server, and grant it the necessary permissions to read and write to the database.
5) Edit monitor_mesh.php, and add in the credential values for your MQTT and MYSQL servers, and your Meshtastic node ID.
6) Give monitor_mesh.php execute permissions, using "chmod +x monitor_mesh.php"
7) To run monitor_mesh.php:

If you want to run in background mode, detached from your shell: "nohup ./monitor_mesh.php &> /dev/null &disown"

If you want to run it and view what's happening, just run it like this: "./monitor_mesh.php"

# Caveats
Meshtastic JSON messages contain some fields/elements that are reserved keywords in MySQL (for example, 'from', 'timestamp', and 'to')

To get around any issues you have with interacting with these columns in MySQL, escape them with back ticks, like this:

"SELECT payload_text, \`from\` FROM text WHERE payload_text IS NOT NULL"

# Containers

This script can be run in a container. The Docker-Compose & Dockerfile are provided in the repository. To build the container, simply update the 'docker-compose.yml' file with your own MQTT and MySQL server details, and then run "docker-compose up -d" to build and run the container.

This will launch 3 containers, App, MySQL and MQTT. The App container will run the PHP-CLI script, and will connect to the MySQL and MQTT containers. All containers run in the same network, so they can communicate with each other using the container names as hostnames. Eg. "DB" and MQTT" resolve to their respective containers. 

Steps:

1. Clone Repo
2. Update docker-compose.yml with your MQTT and MySQL server details
3. Run "docker-compose up -d" to build and run the containers
4. To view the logs of the App container, run "docker logs -f meshtastic-mqtt-mysql_app_1"
5. To stop the containers, run "docker-compose down"

Allow about a minute for the containers to stabilise, they are eventually consistant, so give it a moment to get everything up and running :)

To gain a shell into the running container or check logs:

1. Run "docker ps" to get the container ID
2. Run "docker exec -it <container_id> /bin/bash" to gain a shell into the container
3. Run "docker logs -f <container_id>" to view the logs of the container

Consider changing the passwords in the docker-compose.yml file to something more secure or using secrets to store the credentials.

# Configuration files:

Dockerfile: Contains instructions for copying the PHP app into the container and installing the necessary dependencies

Docker-Compose.yml: Contains instructions for building and running the containers, and setting up the network. Also contains environment variables passed into the MySQL and MQTT containers. 

mosquitto.conf: Contains the configuration for the Mosquitto MQTT server. This file is mounted into the MQTT container when it is built in the exact location of where the Mosquitto server expects to find the config file. This file is configured to allow anonymous access to the server, you could however add authentication options here. 

init.sql: Contains the SQL commands to create the database and user, and grant the necessary permissions to the user. This file is mounted into the MySQL container when it is built, and the commands are run when the container is started. This is completed via a special process which the MySQL container runs when it is first booted, this is called an 'init' sequence which runs before the database is started. 

meshtastic.sql: Contains the meshtastic database schema for the MySQL database. This file is mounted into the MySQL container and the schema is imported into the database on first boot using the same process as the init.sql file.

entrypoint.sh - This script is run when the App container is started. It contains the commands to run the PHP-CLI script, and to keep it running in the background. It also contains the logic to check if the MySQL and MQTT servers are up before starting the PHP-CLI script.

monitor_mesh.php - This is the PHP-CLI script which subscribes to the MQTT server, captures the messages, and imports them into the MySQL database. This script is copied into the App container when it is built. Environment vairables are used in this script to connect to the MySQL and MQTT servers.

Volume persistance has been configured through Docker Volumes. This means that the data in the MySQL database will persist even if the container is stopped and removed. The data is stored in the 'mysql-data' volume, the same goes for the mqtt-data volume. 

