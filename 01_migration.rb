require 'sequel/core'
Sequel.extension :migration, :core_extensions

Sequel.migration do
  change do
    execute <<-PSQL
      CREATE TABLE IF NOT EXISTS orders (
         id SERIAL PRIMARY KEY,
         email TEXT NOT NULL,
         total BIGINT NOT NULL
      );

      DROP TRIGGER IF EXISTS notify_order_event
         on orders;

      CREATE TRIGGER notify_order_event
         AFTER INSERT OR UPDATE OR DELETE
         ON orders
         FOR EACH ROW
         EXECUTE PROCEDURE notify_event();

      CREATE OR REPLACE FUNCTION notify_event()
      RETURNS TRIGGER AS $$
      DECLARE
         record RECORD;
         payload JSON;
      BEGIN
         IF (TG_OP = 'DELETE') THEN
            record = OLD;
         ELSE
            record = NEW;
         END IF;

         payload = json_build_object(
            'table', TG_TABLE_NAME,
            'action', TG_OP,
            'data', row_to_json(record)
         );

         PERFORM pg_notify('events', payload::text);

         RETURN NULL;
      END;
      $$ LANGUAGE plpgsql;
    PSQL
  end
end
