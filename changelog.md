# changelog

Changes to enable containerisation if pulling into master branch

### Added

Dockerfile
docker-compose.yml
init.sql
mosquitto.conf
entrypoint.sh
changelog.md

### Changed

meshtastic.sql:

Line 22 added "USE meshtastic;" to the top of the file to ensure that the database is created with meshtastic as the name

monitor_mesh.php:

Lines 13-20 added the ability to read in environment variables for the MQTT server details, as well as the Meshtastic node ID from the docker-compose. The containers use these as environment variables to allow for easy configuration of the script without needing to edit the file itself. 

Line 22-25 are the original lines, These have been hashed out as lines 13-20 now handle the configuration of the script.

Line 26 orgin hashed out and replaced by line 27 which takes the topic as a environment variable

Lines 27-30 are orginal and have been hashed out. 

Lines 31-34 replace the orginal variables with the new environment approach mentioned before.

Line 45 added "echo "MySQL Database Connected Successfully" to help with debugging sql connection issues via container logs

Line 114 hashed out the original line and replaced it with line 115, removed clientID to prevent connection timeouts