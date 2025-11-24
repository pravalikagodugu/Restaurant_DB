--Creating database
CREATE DATABASE restaurant_db;
-- Creating Restaurants Data Tables
CREATE TABLE restaurant (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(150) NOT NULL,
  branch_code VARCHAR(30),
  address VARCHAR(300),
  phone VARCHAR(30),
  email VARCHAR(150),
  timezone VARCHAR(50) DEFAULT 'Asia/Kolkata',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE menu (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  restaurant_id INT UNSIGNED NOT NULL,
  name VARCHAR(100) NOT NULL,
  description VARCHAR(255),
  active BOOLEAN DEFAULT TRUE,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (restaurant_id) REFERENCES restaurant(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE category (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  menu_id INT UNSIGNED NOT NULL,
  name VARCHAR(100) NOT NULL,
  sort_order INT DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (menu_id) REFERENCES menu(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE menu_item (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  category_id INT UNSIGNED NOT NULL,
  name VARCHAR(150) NOT NULL,
  description TEXT,
  price DECIMAL(10,2) NOT NULL,
  prep_time_minutes INT DEFAULT 0,
  active BOOLEAN DEFAULT TRUE,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (category_id) REFERENCES category(id) ON DELETE CASCADE,
  INDEX idx_menu_item_name (name)
) ENGINE=InnoDB;

CREATE TABLE inventory_item (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  restaurant_id INT UNSIGNED NOT NULL,
  name VARCHAR(150) NOT NULL,
  unit VARCHAR(30) DEFAULT 'unit',
  quantity DECIMAL(10,3) DEFAULT 0,
  reorder_level DECIMAL(10,3) DEFAULT 0,
  last_updated DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (restaurant_id) REFERENCES restaurant(id) ON DELETE CASCADE,
  INDEX idx_inventory_name (name)
) ENGINE=InnoDB;

CREATE TABLE menu_item_ingredient (
  menu_item_id INT UNSIGNED NOT NULL,
  inventory_item_id INT UNSIGNED NOT NULL,
  quantity_needed DECIMAL(10,3) NOT NULL,
  PRIMARY KEY (menu_item_id, inventory_item_id),
  FOREIGN KEY (menu_item_id) REFERENCES menu_item(id) ON DELETE CASCADE,
  FOREIGN KEY (inventory_item_id) REFERENCES inventory_item(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE customer (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  first_name VARCHAR(80),
  last_name VARCHAR(80),
  email VARCHAR(150),
  phone VARCHAR(30),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_customer_email (email)
) ENGINE=InnoDB;

CREATE TABLE `order` (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  restaurant_id INT UNSIGNED NOT NULL,
  customer_id INT UNSIGNED,
  status ENUM('pending','confirmed','preparing','served','completed','cancelled') DEFAULT 'pending',
  total_amount DECIMAL(12,2) DEFAULT 0,
  payment_status ENUM('unpaid','paid','refunded') DEFAULT 'unpaid',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (restaurant_id) REFERENCES restaurant(id) ON DELETE CASCADE,
  FOREIGN KEY (customer_id) REFERENCES customer(id)
) ENGINE=InnoDB;

CREATE TABLE order_item (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  order_id BIGINT UNSIGNED NOT NULL,
  menu_item_id INT UNSIGNED NOT NULL,
  quantity INT UNSIGNED NOT NULL DEFAULT 1,
  unit_price DECIMAL(10,2) NOT NULL,
  total_price DECIMAL(12,2) GENERATED ALWAYS AS (unit_price * quantity) STORED,
  notes VARCHAR(255),
  FOREIGN KEY (order_id) REFERENCES `order`(id) ON DELETE CASCADE,
  FOREIGN KEY (menu_item_id) REFERENCES menu_item(id)
) ENGINE=InnoDB;

CREATE TABLE reservation (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  restaurant_id INT UNSIGNED NOT NULL,
  customer_id INT UNSIGNED,
  reserved_for DATETIME NOT NULL,
  party_size INT UNSIGNED DEFAULT 1,
  status ENUM('booked','arrived','cancelled','no_show') DEFAULT 'booked',
  notes TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (restaurant_id) REFERENCES restaurant(id) ON DELETE CASCADE,
  FOREIGN KEY (customer_id) REFERENCES customer(id)
) ENGINE=InnoDB;

CREATE TABLE employee (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  restaurant_id INT UNSIGNED NOT NULL,
  first_name VARCHAR(80),
  last_name VARCHAR(80),
  role VARCHAR(80),
  phone VARCHAR(30),
  email VARCHAR(150),
  active BOOLEAN DEFAULT TRUE,
  hired_date DATE,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (restaurant_id) REFERENCES restaurant(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE review (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  restaurant_id INT UNSIGNED NOT NULL,
  customer_id INT UNSIGNED,
  rating TINYINT UNSIGNED NOT NULL CHECK (rating BETWEEN 1 AND 5),
  title VARCHAR(150),
  body TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (restaurant_id) REFERENCES restaurant(id) ON DELETE CASCADE,
  FOREIGN KEY (customer_id) REFERENCES customer(id)
) ENGINE=InnoDB;

INSERT INTO restaurant (name, branch_code, address, phone, email)
VALUES ('SpiceWave Restaurant', 'SPW-GOA-01', '34 Sea Breeze Ln, Panaji, Goa, India', '+91-832-0000001', 'contact@spicewave.example');

-- Menus
INSERT INTO menu (restaurant_id, name, description) VALUES
(1, 'All Day Menu', 'Main full menu'),
(1, 'Weekend Specials', 'Limited time weekend menu');

-- Categories (4 categories per menu)
INSERT INTO category (menu_id, name, sort_order) VALUES
(1, 'Starters', 1),
(1, 'Mains', 2),
(1, 'Desserts', 3),
(1, 'Beverages', 4),
(2, 'Weekend Starters',1),
(2, 'Weekend Mains',2),
(2, 'Weekend Desserts',3),
(2, 'Weekend Beverages',4);

-- Menu items: ~25 rows
INSERT INTO menu_item (category_id, name, description, price, prep_time_minutes) VALUES
(1, 'Paneer Tikka', 'Chargrilled marinated paneer pieces', 220.00, 12),
(1, 'Fish Amritsari', 'Batter fried local fish', 260.00, 15),
(1, 'Veg Spring Rolls', 'Crispy rolls with veg filling', 140.00, 8),
(1, 'Chicken 65', 'Deep fried spicy chicken', 240.00, 10),
(1, 'Prawns Pepper Fry', 'Prawns with pepper masala', 320.00, 14),
(2, 'Butter Chicken', 'Classic butter chicken with naan', 310.00, 20),
(2, 'Goan Prawn Curry', 'Coconut based prawn curry', 360.00, 22),
(2, 'Masala Dosa', 'Crispy dosa with potato masala', 130.00, 12),
(2, 'Paneer Butter Masala', 'Creamy paneer curry', 290.00, 18),
(2, 'Lamb Rogan Josh', 'Slow cooked lamb curry', 420.00, 30),
(3, 'Gulab Jamun', 'Warm syrup soaked dumplings', 90.00, 6),
(3, 'Chocolate Brownie', 'Fudge brownie with ice cream', 160.00, 7),
(3, 'Rasmalai', 'Soft cheese discs in sweetened milk', 110.00, 6),
(4, 'Masala Chai', 'Spiced Indian tea', 40.00, 3),
(4, 'Mango Lassi', 'Yogurt drink with mango', 120.00, 3),
(4, 'Fresh Lime Soda', 'Sweet or salted', 60.00, 2),
(4, 'Coconut Water', 'Fresh local coconut', 70.00, 1),
(1, 'Hara Bhara Kebab', 'Spinach and potato kebab', 180.00, 10),
(2, 'Fish Curry Rice', 'Goan fish curry with steamed rice', 280.00, 19),
(2, 'Egg Biryani', 'Aromatic egg biryani served with raita', 200.00, 20),
(2, 'Veg Thali', 'Assorted veg curries, rice, roti', 249.00, 15),
(4, 'Cold Coffee', 'Iced coffee with milk and ice cream', 150.00, 4),
(3, 'Kulfi', 'Traditional Indian ice cream', 90.00, 5),
(1, 'Chicken Seekh Kebab', 'Minced chicken skewers', 230.00, 13),
(2, 'Paneer Tawa Masala', 'Spicy paneer on tawa', 275.00, 16);

-- Inventory items: ~25 rows
INSERT INTO inventory_item (restaurant_id, name, unit, quantity, reorder_level) VALUES
(1, 'Paneer', 'kg', 12.500, 2.000),
(1, 'Fish (Local)', 'kg', 20.000, 5.000),
(1, 'All-purpose Flour', 'kg', 30.000, 5.000),
(1, 'Rice (Basmati)', 'kg', 50.000, 8.000),
(1, 'Potatoes', 'kg', 40.000, 10.000),
(1, 'Tomatoes', 'kg', 30.000, 6.000),
(1, 'Onions', 'kg', 45.000, 8.000),
(1, 'Garlic', 'kg', 8.000, 2.000),
(1, 'Ginger', 'kg', 6.500, 1.000),
(1, 'Chilies (Green)', 'kg', 5.000, 1.000),
(1, 'Coconut (fresh)', 'no', 60.000, 10.000),
(1, 'Curd/Yogurt', 'kg', 15.000, 3.000),
(1, 'Butter', 'kg', 10.000, 2.000),
(1, 'Cream', 'litre', 8.000, 1.000),
(1, 'Sugar', 'kg', 25.000, 5.000),
(1, 'Salt', 'kg', 40.000, 5.000),
(1, 'Garam Masala', 'kg', 4.000, 1.000),
(1, 'Lemon', 'kg', 12.000, 2.000),
(1, 'Mango Pulp', 'litre', 10.000, 2.000),
(1, 'Tea Leaves', 'kg', 3.000, 1.000),
(1, 'Coffee Powder', 'kg', 2.000, 1.000),
(1, 'Oil (Cooking)', 'litre', 40.000, 5.000),
(1, 'Eggs', 'dozen', 80.000, 10.000),
(1, 'Brown Sugar', 'kg', 8.000, 2.000),
(1, 'Ice Cream (vanilla)', 'litre', 12.000, 2.000);


INSERT INTO menu_item_ingredient (menu_item_id, inventory_item_id, quantity_needed) VALUES
(1, 1, 0.200), 
(1, 17, 0.010), 
(2, 2, 0.200), 
(2, 3, 0.050), 
(3, 5, 0.150), 
(3, 16, 0.020), 
(4, 4, 0.150), 
(4, 11, 0.020),
(5, 2, 0.150),
(6, 13, 0.050),
(6, 12, 0.050),
(7, 10, 0.100),
(7, 11, 0.100),
(8, 3, 0.100),
(8, 5, 0.200),
(9, 1, 0.150),
(10, 2, 0.300),
(11, 15, 0.050),
(12, 24, 0.120),
(13, 12, 0.150),
(14, 20, 0.005),
(15, 19, 0.150),
(16, 20, 0.200),
(17, 11, 0.150),
(18, 2, 0.200),
(19, 4, 0.150),
(20, 4, 0.200),
(21, 24, 0.100),
(22, 24, 0.080),
(23, 24, 0.080),
(24, 1, 0.200),
(25, 1, 0.180);

-- Customers 
INSERT INTO customer (first_name, last_name, email, phone) VALUES
('Amit','Shah','amit.shah@example.com','+919600000001'),
('Neha','Rao','neha.rao@example.com','+919600000002'),
('Ravi','Desai','ravi.desai@example.com','+919600000003'),
('Pooja','Kumar','pooja.kumar@example.com','+919600000004'),
('Vikas','Patel','vikas.patel@example.com','+919600000005'),
('Sana','Ansari','sana.ansari@example.com','+919600000006'),
('Manish','Singh','manish.singh@example.com','+919600000007'),
('Priya','Sharma','priya.sharma@example.com','+919600000008'),
('Karan','Mehta','karan.mehta@example.com','+919600000009'),
('Richa','Gupta','richa.gupta@example.com','+919600000010'),
('Sourav','Roy','sourav.roy@example.com','+919600000011'),
('Leena','Iyer','leena.iyer@example.com','+919600000012'),
('Tarun','Joshi','tarun.joshi@example.com','+919600000013'),
('Meera','Nair','meera.nair@example.com','+919600000014'),
('Aditya','Verma','aditya.verma@example.com','+919600000015'),
('Simran','Batra','simran.batra@example.com','+919600000016'),
('Rohit','Khan','rohit.khan@example.com','+919600000017'),
('Anjali','Deshmukh','anjali.d@example.com','+919600000018'),
('Vivek','Malhotra','vivek.m@example.com','+919600000019'),
('Shreya','Ghosh','shreya.ghosh@example.com','+919600000020'),
('Ankur','Dutta','ankur.dutta@example.com','+919600000021'),
('Siddharth','Nair','siddharth.n@example.com','+919600000022'),
('Tanvi','Kulkarni','tanvi.k@example.com','+919600000023'),
('Bhavesh','Rao','bhavesh.rao@example.com','+919600000024'),
('Diksha','Shah','diksha.shah@example.com','+919600000025');

-- Orders 
INSERT INTO `order` (restaurant_id, customer_id, status, total_amount, payment_status, created_at) VALUES
(1,1,'completed',220.00,'paid','2025-01-05 12:10:00'),
(1,2,'completed',360.00,'paid','2025-01-06 13:00:00'),
(1,3,'completed',480.00,'paid','2025-01-07 19:30:00'),
(1,4,'completed',130.00,'paid','2025-01-07 20:00:00'),
(1,5,'cancelled',0.00,'unpaid','2025-01-08 18:00:00'),
(1,6,'completed',599.00,'paid','2025-01-09 21:15:00'),
(1,7,'completed',249.00,'paid','2025-02-01 13:20:00'),
(1,8,'completed',310.00,'paid','2025-02-02 14:00:00'),
(1,9,'completed',420.00,'paid','2025-02-05 20:30:00'),
(1,10,'completed',90.00,'paid','2025-02-09 19:00:00'),
(1,11,'completed',150.00,'paid','2025-02-11 16:20:00'),
(1,12,'completed',130.00,'paid','2025-02-13 13:50:00'),
(1,13,'confirmed',0.00,'unpaid','2025-03-01 12:00:00'),
(1,14,'preparing',0.00,'unpaid','2025-03-02 12:05:00'),
(1,15,'pending',0.00,'unpaid','2025-03-03 12:10:00'),
(1,16,'completed',280.00,'paid','2025-03-04 14:30:00'),
(1,17,'completed',200.00,'paid','2025-03-05 15:00:00'),
(1,18,'completed',360.00,'paid','2025-03-06 19:40:00'),
(1,19,'completed',249.00,'paid','2025-04-01 13:20:00'),
(1,20,'completed',420.00,'paid','2025-04-02 20:30:00'),
(1,21,'completed',310.00,'paid','2025-04-03 14:00:00'),
(1,22,'completed',160.00,'paid','2025-04-04 17:10:00'),
(1,23,'completed',90.00,'paid','2025-04-05 20:11:00'),
(1,24,'completed',220.00,'paid','2025-04-06 21:05:00'),
(1,25,'completed',275.00,'paid','2025-04-07 13:50:00');

-- Order items 
INSERT INTO order_item (order_id, menu_item_id, quantity, unit_price, notes) VALUES
(1,1,1,220.00,'no onion'),
(2,7,1,360.00,NULL),
(3,6,1,310.00,NULL),
(3,14,1,40.00,'extra ginger'),
(4,8,1,130.00,NULL),
(6,10,1,420.00,NULL),
(6,11,1,90.00,NULL),
(7,21,1,249.00,NULL),
(8,6,1,310.00,NULL),
(9,10,1,420.00,NULL),
(10,11,1,90.00,NULL),
(11,22,1,150.00,NULL),
(12,8,1,130.00,NULL),
(13,2,2,260.00,'spicy'),
(14,5,1,320.00,NULL),
(15,3,3,140.00,'extra sauce'),
(16,19,1,280.00,NULL),
(17,20,1,200.00,NULL),
(18,7,1,360.00,NULL),
(19,21,1,249.00,NULL),
(20,10,1,420.00,NULL),
(21,6,1,310.00,NULL),
(22,23,1,160.00,NULL),
(23,24,1,90.00,NULL),
(24,1,1,220.00,NULL),
(25,25,1,275.00,NULL),
-- extra items for variety
(2,14,2,40.00,NULL),
(4,16,1,60.00,NULL),
(7,4,2,240.00,'less spicy'),
(8,15,1,120.00,NULL),
(9,12,1,160.00,NULL),
(11,3,1,140.00,NULL),
(12,18,1,70.00,NULL),
(13,9,1,290.00,NULL),
(14,13,1,110.00,NULL),
(15,17,1,180.00,NULL),
(16,2,1,260.00,NULL),
(17,21,2,249.00,NULL),
(18,11,1,90.00,NULL),
(19,4,1,240.00,NULL),
(20,8,1,130.00,NULL),
(21,1,1,220.00,NULL);

-- Reservations 
INSERT INTO reservation (restaurant_id, customer_id, reserved_for, party_size, status, notes) VALUES
(1,2,'2025-05-01 19:30:00',2,'booked','Window table'),
(1,3,'2025-05-02 20:00:00',4,'booked','Birthday'),
(1,5,'2025-05-03 13:00:00',3,'cancelled','Cancelled by guest'),
(1,7,'2025-05-04 18:30:00',2,'booked',NULL),
(1,8,'2025-05-05 21:00:00',6,'booked','Large party'),
(1,10,'2025-05-06 12:30:00',1,'booked','Quick lunch'),
(1,11,'2025-05-07 19:00:00',3,'booked',NULL),
(1,12,'2025-05-08 20:15:00',2,'no_show','No show'),
(1,13,'2025-05-09 18:00:00',2,'arrived','Allergic to nuts'),
(1,14,'2025-05-10 19:30:00',4,'booked','Anniversary'),
(1,15,'2025-05-11 20:30:00',5,'booked',NULL),
(1,16,'2025-05-12 13:00:00',2,'booked',NULL),
(1,17,'2025-05-13 19:30:00',2,'booked',NULL),
(1,18,'2025-05-14 20:00:00',3,'booked',NULL),
(1,19,'2025-05-15 21:00:00',2,'booked',NULL),
(1,20,'2025-05-16 18:30:00',2,'cancelled','Guest cancelled'),
(1,21,'2025-05-17 19:00:00',3,'booked',NULL),
(1,22,'2025-05-18 20:30:00',4,'booked',NULL),
(1,23,'2025-05-19 13:00:00',2,'booked',NULL),
(1,24,'2025-05-20 12:00:00',2,'booked',NULL);

-- Employees (~20 rows)
INSERT INTO employee (restaurant_id, first_name, last_name, role, phone, email, hired_date) VALUES
(1,'Raj','Kohli','Manager','+919600001001','raj.kohli@spicewave.example','2020-01-10'),
(1,'Sunita','Patel','Chef','+919600001002','sunita.p@spicewave.example','2019-05-20'),
(1,'Manoj','Verma','Chef','+919600001003','manoj.v@spicewave.example','2021-03-12'),
(1,'Deepa','Iyer','Sous Chef','+919600001004','deepa.i@spicewave.example','2018-07-01'),
(1,'Anil','Sharma','Head Waiter','+919600001005','anil.s@spicewave.example','2019-10-21'),
(1,'Rina','Dutta','Waiter','+919600001006','rina.d@spicewave.example','2022-02-14'),
(1,'Kunal','Mehra','Waiter','+919600001007','kunal.m@spicewave.example','2022-08-09'),
(1,'Priti','Desai','Cashier','+919600001008','priti.d@spicewave.example','2020-11-01'),
(1,'Vivek','Kumar','Barista','+919600001009','vivek.k@spicewave.example','2021-06-23'),
(1,'Nisha','Rao','Cleaner','+919600001010','nisha.r@spicewave.example','2017-12-12'),
(1,'Sanjay','Kumar','Delivery','+919600001011','sanjay.k@spicewave.example','2023-01-01'),
(1,'Mehul','Joshi','Accountant','+919600001012','mehul.j@spicewave.example','2016-04-10'),
(1,'Trisha','Ghosh','Host','+919600001013','trisha.g@spicewave.example','2019-09-09'),
(1,'Arjun','Reddy','Chef','+919600001014','arjun.r@spicewave.example','2020-02-02'),
(1,'Sakshi','Bose','Waiter','+919600001015','sakshi.b@spicewave.example','2021-10-10'),
(1,'Naveen','Shah','Security','+919600001016','naveen.s@spicewave.example','2015-07-07'),
(1,'Ritu','Kapoor','Assistant Manager','+919600001017','ritu.k@spicewave.example','2018-03-03'),
(1,'Kiran','Angadi','Chef','+919600001018','kiran.a@spicewave.example','2022-05-05'),
(1,'Smita','Patel','Waiter','+919600001019','smita.p@spicewave.example','2023-07-07'),
(1,'Yash','Malhotra','Delivery','+919600001020','yash.m@spicewave.example','2024-01-15');

-- Reviews
INSERT INTO review (restaurant_id, customer_id, rating, title, body, created_at) VALUES
(1,1,5,'Excellent!','Loved the paneer tikka and service.'),
(1,2,4,'Great food','Good flavours but a bit pricey.'),
(1,3,5,'Amazing','The Goan prawn curry is top-notch.'),
(1,4,3,'Okay','Dosa was average today.'),
(1,5,2,'Bad experience','Order delayed and some items cold.'),
(1,6,5,'Fantastic','Butter chicken was perfect.'),
(1,7,4,'Nice place','Good for family dinners.'),
(1,8,5,'Highly recommend','Outstanding service.'),
(1,9,4,'Very good','Lamb was well cooked.'),
(1,10,3,'Average','Dessert was too sweet.'),
(1,11,4,'Good','Fast service and fresh food.'),
(1,12,5,'Loved it','The staff were friendly.'),
(1,13,5,'Exceptional','Birthday arrangements were great.'),
(1,14,4,'Pleasant','Ambience nice.'),
(1,15,5,'Yummy','Everything tasted fresh.'),
(1,16,4,'Good value','Portions are generous.'),
(1,17,3,'Not great','Rice slightly undercooked.'),
(1,18,5,'Perfect','Great cocktails and music.'),
(1,19,4,'Solid','Consistent quality.'),
(1,20,2,'Could improve','Long waiting time.'),
(1,21,5,'Fantastic!','Excellent service.'),
(1,22,4,'Nice food','Will come again.'),
(1,23,5,'Top notch','Dessert was amazing.'),
(1,24,3,'Average','Expected more from mains.'),
(1,25,4,'Good experience','Friendly staff.');


--Testing
-- Show menu
SELECT m.name AS menu_name, c.name AS category, mi.id, mi.name, mi.price
FROM menu m
JOIN category c ON c.menu_id = m.id
JOIN menu_item mi ON mi.category_id = c.id
WHERE m.restaurant_id = 1 AND mi.active = 1
ORDER BY c.sort_order, mi.name;

-- Recent orders
SELECT o.id, o.customer_id, c.first_name, o.total_amount, o.status, o.created_at
FROM `order` o
LEFT JOIN customer c ON c.id = o.customer_id
ORDER BY o.created_at DESC
LIMIT 20;

-- Inventory low-stock
SELECT * FROM inventory_item WHERE quantity <= reorder_level;

-- Customer order history
SELECT o.id, o.total_amount, o.status, o.created_at
FROM `order` o WHERE o.customer_id = 7 ORDER BY o.created_at DESC;

-- Top selling items (simple)
SELECT mi.name, SUM(oi.quantity) AS qty_sold
FROM order_item oi JOIN menu_item mi ON mi.id = oi.menu_item_id
GROUP BY mi.id ORDER BY qty_sold DESC LIMIT 10;






