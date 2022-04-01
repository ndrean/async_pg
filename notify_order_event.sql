CREATE TRIGGER notify_order_event
  AFTER INSERT OR UPDATE OR DELETE
  ON orders
  FOR EACH ROW
  EXECUTE PROCEDURE notify_event();