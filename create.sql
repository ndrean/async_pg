CREATE TABLE orders (
   id SERIAL PRIMARY KEY,
   email TEXT NOT NULL,
   total BIGINT NOT NULL
);