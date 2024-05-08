#!/bin/bash

# Start Apache in the background
#apache2-foreground &

# Run the PHP script every 1 second
while true; do
    php /var/www/html/monitor_mesh.php
    sleep 1
done