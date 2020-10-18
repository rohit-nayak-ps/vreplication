mysql -h 127.0.0.1 -P 19327 -u msandbox --password=msandbox commerce < sql/create_commerce_schema.sql
mysql -h 127.0.0.1 -P 19327 -u msandbox --password=msandbox commerce < sql/insert_commerce_data.sql
