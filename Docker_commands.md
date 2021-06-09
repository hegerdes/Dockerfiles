# Docker commands

## MySQL

docker run --name mysql_dev -p 3306:3306 -v /d/data/mySQL:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=my_pw -d mysql:latest

## PostGres

docker run --name postgres_dev -p 5432:5432 -e POSTGRES_PASSWORD=my_pw -e PGDATA=/var/lib/postgresql/data/pgdata -v /d/data/postgres:/var/lib/postgresql/data postgres