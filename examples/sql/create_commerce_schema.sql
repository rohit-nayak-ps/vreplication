use commerce;
drop table if exists product;
drop table if exists customer;
drop table if exists corder;
drop database if exists _vt;
create table product(
  sku varbinary(128),
  description varbinary(128),
  price bigint,
  primary key(sku)
) ENGINE=InnoDB;
create table customer(
  customer_id bigint not null auto_increment,
  email varbinary(128),
  primary key(customer_id)
) ENGINE=InnoDB;
create table corder(
  order_id bigint not null auto_increment,
  customer_id bigint,
  sku varbinary(128),
  price bigint,
  primary key(order_id)
) ENGINE=InnoDB;
