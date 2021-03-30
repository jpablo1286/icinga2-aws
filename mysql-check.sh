#!/bin/bash
while ! mysql -u $3 -p$4 -h $1 $2 -e "DROP DATABASE IF EXISTS icinga;DROP DATABASE IF EXISTS icingaweb2;" ; do
       echo "Waiting DB to be ready"
       sleep 10s
done