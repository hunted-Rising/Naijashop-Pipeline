



-- Naijashop Data Pipeline - Core Schema

DROP TABLE IF EXISTS payments CASCADE;
DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS customers CASCADE;

CREATE TABLE customers (
	customer_id	SERIAL PRIMARY KEY,
	full_name		VARCHAR(120) NOT NULL,
	email			VARCHAR(150) UNIQUE,
	city			VARCHAR(80),
	state			VARCHAR(80),
	signup_date		DATE NOT NULL
);

SELECT *
FROM customers;

CREATE TABLE products (
	product_id		SERIAL PRIMARY KEY,
	product_name	VARCHAR(150) NOT NULL,
	category		VARCHAR(80) NOT NULL,
	price			NUMERIC(10, 2) NOT NULL CHECK (price >= 0),
	stock_qty		INTEGER NOT NULL DEFAULT 0 CHECK (stock_qty >= 0)
);

SELECT *
FROM products;

CREATE TABLE orders (
	order_id		SERIAL PRIMARY KEY,
	customer_id	INTEGER NOT NULL REFERENCES customers(customer_id),
	order_date		TIMESTAMP NOT NULL,
	status			VARCHAR(20) NOT NULL CHECK (status IN ('pending', 'paid', 'shipped', 'delivered', 'cancelled'))
);

CREATE TABLE order_items (
	order_item_id	SERIAL PRIMARY KEY,
	order_id		INTEGER NOT NULL REFERENCES orders(order_id),
	product_id		INTEGER NOT NULL REFERENCES products(product_id),
	quantity		INTEGER NOT NULL CHECK (quantity > 0),
	unit_price		NUMERIC(10,2) NOT NULL CHECK (unit_price >= 0)	-- price captured at the time of order
);

CREATE TABLE payments (
	payment_id		SERIAL PRIMARY KEY,
	order_id		INTEGER NOT NULL REFERENCES orders(order_id),
	method			VARCHAR(30) NOT NULL CHECK (method IN ('card', 'bank_transfer', 'ussd', 'cash-on_delivery')),
	amount			NUMERIC(10, 2) NOT NULL CHECK (amount >= 0),
	status			VARCHAR(20) NOT NULL CHECK (status IN ('pending', 'successful', 'failed', 'refunded')),
	paid_at			TIMESTAMP
);

-- Indexes for common query patterns
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_orders_date ON orders(order_date);
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_product_id ON order_items(product_id);
CREATE INDEX idx_payments_order_id ON payments(order_id);

-- Confirm our tables in the naijashop_db
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;

SELECT COUNT(*) FROM customers;




-- which customer bought which product
SELECT 
	c.full_name, p.product_name, oi.quantity, oi.unit_price
FROM
	customers c
JOIN orders o ON o.customer_id = c.customer_id
JOIN order_items oi ON OI.order_id = o.order_id
JOIN products p ON p.product_id = oi.product_id
LIMIT 5;


SELECT category, SUM(quantity * unit_price) AS total_revenue
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
GROUP BY category
ORDER BY total_revenue DESC;

-- security check 
-- read only analyst role 
--CREATE ROLE our_naijashop_analyst WITH LOGIN PASSWORD 'analyst_readonly';
-- GRANT CONNECT ON DATABASE naijashop TO naijashop- 
--SELECT count(*) FROM marketing_spends;
--
-- confirm if ingested marketing ad happened 
--SELECT campaign_name 
--FROM marketing_spends_with_private_data
--LIMIT 6;
--
--
-- assignment aspect 


