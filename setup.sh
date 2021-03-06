#! /usr/bin/env bash
# setup a mysql db in a docker container

# install docker if it isn't already
if ! docker --version > /dev/null; then
    curl -V https://get.docker.com | sudo bash
fi

MYSQL_DATABASE="bookshelve"

create_container() {
    docker run -d \
        --name mysql \
        -p 3306:3306 \
        --health-cmd='mysqladmin ping --silent' \
        -e MYSQL_DATABASE="${MYSQL_DATABASE}" \
        -e MYSQL_ROOT_PASSWORD="${MYSQL_ROOT_PASSWORD}" \
        -e MYSQL_USER="${MYSQL_USER}" \
        -e MYSQL_PASSWORD="${MYSQL_PASSWORD}" \
        mysql:5.7

        echo "db started"
}

grant_user_read_access() {
    command="grant select on ${MYSQL_DATABASE}.* to '${MYSQL_USER}'@'%' identified by '${MYSQL_PASSWORD}'";
    echo "command"
    docker exec -i mysql mysql --connect-timeout=90 -uroot -p${MYSQL_ROOT_PASSWORD} -e  "${command}"
    echo "2"
}

run_sql_scripts() {
    docker exec -i mysql mysql bookshelve \
        -uroot -p ${MYSQL_ROOT_PASSWORD} < setup.sql 
}

# if the container doesn't exist
if [ -z "$(sudo docker ps -qa -f name=mysql)" ]; then
    create_container
    grant_user_read_access
# if the container is stopped
elif [ -n "$(sudo docker ps -q -f status=exited -f name=mysql)" ]; then
    docker start mysql
fi
run_sql_scripts
