# Source

<https://citizen428.net/blog/asynchronous-notifications-in-postgres/>

<https://www.enterprisedb.com/postgres-tutorials/everything-you-need-know-about-postgresql-triggers>

> Note: <https://github.com/bensheldon/rails_postgres_websockets_chat/blob/master/app/lib/async_events.rb>
> Potential gem for ActiveRecord: <https://github.com/ezcater/activerecord-postgres_pub_sub>

- run `$ psql -U postgres` to connect to postgres

- create database and connect ot database

```bash
postgres=# CREATE DATABASE notify-_test;
postgres=# \c notify_test;
```

- create table (in psql)

```bash
postgres=# CREATE TABLE orders (...
```

- create the function and trigger event so Postgres will asynchronously send a message.

```bash
# Trigger function creation
postgres=# CREATE OR REPLACE FUNCTION notify_event() RETURNS TRIGGER...

# sets the trigger function in 'orders' table
postgres=# CREATE TRIGGER notify_order_event...

# check the trigger on the table 'orders'
postgres=# \dS orders
...
Triggers:
    notify_order_event AFTER INSERT OR DELETE OR UPDATE ON orders FOR EACH ROW EXECUTE FUNCTION notify_event()

```

> Note : to remove a trigger, do:

```bash
postgres=# drop trigger notify_order_event on "orders" ;
```

- create a lambda in `test2.rb` (so it responds to `lambada.call`) that:

  - uses `Sequel.listen` on the Postgres event,

  - creates a websocket with the `faye`gem to broadcast the payload

- create the `index.html` that contains a script to launch the native `WebSocket`.

- create `config.ru` that contains `run App` (so rackup can `call`)


Then run in a terminal (it will start the Puma webserver by default):

```bash
rackup --env production config.ru
```

Add a new row to the database by running in a psql session:

```bash
postgres=# INSERT into orders (email, total) VALUES ('test10@ex.com', 10);
```

And observe the result in several browsers (with logs)

## Run this in migration

<https://stackoverflow.com/questions/39755504/how-do-i-create-a-trigger-in-a-rails-migration>

<https://sequel.jeremyevans.net/rdoc/classes/Sequel/Migrator.html>


```bash
irb> require 'sequel'
irb> Sequel.extension :migration, :core_extensions

irb> Sequel.connect('postgres://postgres@localhost/notify_test') do |db
| Sequel::Migrator.run(db, '.')
```

```rb
class CreateTriggers < ActiveRecord::Migration
  def change
    execute <<-SQL

      CREATE TABLE IF NOT EXISTS orders (
         id SERIAL PRIMARY KEY,
         email TEXT NOT NULL,
         total BIGINT NOT NULL
      );


      CREATE OR REPLACE FUNCTION notify_event()
         RETURNS trigger AS $$
         DECLARE ...
         BEGIN
            ...
            PERFORM pg_notify('events', payload::text);
            RETURN NULL;
         END
        LANGUAGE plpgsql AS
        $$
        BEGIN
        ...
      END;$$;

      DROP TRIGGER IF EXISTS notify_order_event
         on orders;

      CREATE TRIGGER notify_order_event...

      CREATE TRIGGER yyy
    SQL
  end
end
```