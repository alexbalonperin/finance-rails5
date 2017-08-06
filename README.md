# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version: 2.3.3
* Rails version: 5.0.0

* System dependencies

* Configuration

* Run the application
- start: `docker-compose up -d`
- stop: `docker-compose down`

* Database creation
- Delete all docker volumes: `docker volume rm $(docker volume ls)`
- Create a new docker volume: `docker volume create --name finance-postgres`
- Start the postgres container: `docker-compose --file docker/docker-compose.dev.yml up -d`

* Database initialization
- Copy last backup into the container: `docker cp /path/to/backup.sql finance_postgres:/tmp/backup.sql`
- Connect to the container: `docker exec -it finance_postgres bash`
- Restore the backup: `psql -U postgres < /tmp/backup.sql`
- Run the migrations: `docker exec -it finance_web rails db:migrate`

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
