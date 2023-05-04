/* FIRST METHOD TO INSERT DATA INTO ACCOUNTS & USER_DETAILS (TOTAL_ORDERS IS 0 BY DEFAULT)*/
 -- INSERT DATA INTO ACCOUNTS
 insert into accounts(username, password, role, total_orders) values ('aeerdna01', 'Mitzu@2021', 'administrator', default);
 insert into accounts(username, password, role, total_orders) values ('stefana17', 'jjk@Hkf01f', 'customer', default);
 insert into accounts(username, password, role, total_orders) values ('ana2001', 'mnSDFJ@#4', 'customer', default);
 insert into accounts(username, password, role, total_orders) values ('bianca01', '2022Fsmmd@', 'customer', default);
 insert into accounts(username, password, role, total_orders) values ('jojo2001', 'fdmbgT@75', 'customer', default);

 --INSERT DATA INTO USER_DETAILS
 insert into user_details(id_user, first_name, last_name, address, email, phone) values (get_id_username('aeerdna01'), 'Andreea', 'Pislariu', 'Strada Crinului Nr. 12 Iasi', 'a_pislariu@gmail.com', '0739246917');
 insert into user_details(id_user, first_name, last_name, address, email, phone) values (get_id_username('stefana17'), 'Stefana', 'Hriscu', 'Strada Principala Nr. 15 Iasi', 'stefana.h@gmail.com', '0737246421');
 insert into user_details(id_user, first_name, last_name, address, email, phone) values (get_id_username('ana2001'), 'Ana', 'Rosca', 'Strada Mihai Eminescu Iasi', 'ana.rosca01@gmail.com', '0739556984');
 insert into user_details(id_user, first_name, last_name, address, email, phone) values (get_id_username('bianca01'), 'Bianca', 'Barbaliu', 'Strada Primaverii Nr. 7 Iasi', 'b_bianca@gmail.com', '0742246217');
 insert into user_details(id_user, first_name, last_name, address, email, phone) values (get_id_username('jojo2001'), 'Georgiana', 'Aluchienesei', 'Strada Trandafirului Nr. 11 Iasi', 'al_georgiana@gmail.com', '0717842587');

/* SECOND METHOD TO INSERT DATA INTO ACCOUNTS & USER_DETAILS */
/
declare
  v_id_user accounts.username%type;
begin
  insert into accounts(username, password, role, total_orders)
  values ('larisa22', 'Iris@2021', 'customer', default)
  returning id_user into v_id_user;
 insert into user_details(id_user, first_name, last_name, address, email, phone) 
 values (v_id_user, 'Larisa', 'Pasa', 'Strada Soarelui Nr. 12 Botosani', 'larisa_pasa@gmail.com', '0769346969');
commit;
end;
/

 --INSERT DATA INTO CATEGORIES
 insert into categories(id_category, name) values (1, 'Jeans');
 insert into categories(id_category, name) values (2, 'Shirts');
 insert into categories(id_category, name) values (3, 'Jackets');

 
 --INSERT DATA INTO SIZES
 insert into sizes(id_size, name) values (1, 'S');
 insert into sizes(id_size, name) values (2, 'M');
 insert into sizes(id_size, name) values (3, 'L');

 
 --INSERT DATA INTO PRODUCTS (STOCK_QUANTITY IS 0 BY DEFAULT)
insert into products(price, id_category, id_size, type) values (110, 1, get_id_size('S'), 'Women');
insert into products(price, id_category, id_size, type) values (110, 1, get_id_size('M'), 'Women');
insert into products(price, id_category, id_size, type) values (140, 1, get_id_size('L'), 'Men');
insert into products(price, id_category, id_size, type) values (140, 2, get_id_size('L'), 'Women');
insert into products(price, id_category, id_size, type) values (89, 2, get_id_size('M'), 'Women');
insert into products(price, id_category, id_size, type) values (89, 2, get_id_size('S'), 'Women');
insert into products(price, id_category, id_size, type) values (189, 3, get_id_size('S'), 'Women');
insert into products(price, id_category, id_size, type) values (189, 3, get_id_size('M'), 'Women');
insert into products(price, id_category, id_size, type) values (189, 3, get_id_size('M'), 'Men');
insert into products(price, id_category, id_size, type) values (210, 3, get_id_size('L'), 'Men');

 --INSERT DATA INTO SUPPLIES
insert into supplies(id_product, supply_date, supply_quantity) values(1,  TRUNC( SYSDATE ), 20);
insert into supplies(id_product, supply_date, supply_quantity) values(2,  TRUNC( SYSDATE ), 45);
insert into supplies(id_product, supply_date, supply_quantity) values(3,  TRUNC( SYSDATE ), 101);
insert into supplies(id_product, supply_date, supply_quantity) values(4,  TRUNC( SYSDATE ), 25);
insert into supplies(id_product, supply_date, supply_quantity) values(5,  TRUNC( SYSDATE ), 60);
insert into supplies(id_product, supply_date, supply_quantity) values(6,  TRUNC( SYSDATE ), 70);
insert into supplies(id_product, supply_date, supply_quantity) values(7,  TRUNC( SYSDATE ), 86);
insert into supplies(id_product, supply_date, supply_quantity) values(8,  TRUNC( SYSDATE ), 90);
insert into supplies(id_product, supply_date, supply_quantity) values(9,  TRUNC( SYSDATE ), 25);
insert into supplies(id_product, supply_date, supply_quantity) values(10,  TRUNC( SYSDATE ), 25);
 
 --INSERT DATA INTO ORDERS & ORDERS_DETAILS (TRANZACTIONS)
 begin
 insert into orders(id_user, order_date) values (get_id_username('aeerdna01'),  TRUNC( SYSDATE )); 
 insert into orders_details(orders_id_order, products_id_product, order_quantity) values (orders_id_order_seq.currval, 1, 2);
 insert into orders_details(orders_id_order, products_id_product, order_quantity) values (orders_id_order_seq.currval, 7, 3);
 insert into orders_details(orders_id_order, products_id_product, order_quantity) values (orders_id_order_seq.currval, 8, 3);
 commit;
 end;
 /
 begin
 insert into orders(id_user, order_date) values (get_id_username('aeerdna01'),  TRUNC( SYSDATE )); 
 insert into orders_details(orders_id_order, products_id_product, order_quantity) values (orders_id_order_seq.currval, 1, 2);
 insert into orders_details(orders_id_order, products_id_product, order_quantity) values (orders_id_order_seq.currval, 7, 3);
 insert into orders_details(orders_id_order, products_id_product, order_quantity) values (orders_id_order_seq.currval, 8, 3);
 commit;
 end;
 /
 begin
 insert into orders(id_user, order_date) values (get_id_username('aeerdna01'), TRUNC( SYSDATE )); 
 insert into orders_details(orders_id_order, products_id_product, order_quantity) values (orders_id_order_seq.currval, 1, 2);
 insert into orders_details(orders_id_order, products_id_product, order_quantity) values (orders_id_order_seq.currval, 5, 4);
 commit;
 end;
 /
  begin
 insert into orders(id_user, order_date) values (get_id_username('ana2001'), TRUNC( SYSDATE )); 
 insert into orders_details(orders_id_order, products_id_product, order_quantity) values (orders_id_order_seq.currval, 2, 5);
 insert into orders_details(orders_id_order, products_id_product, order_quantity) values (orders_id_order_seq.currval, 4, 3);
 commit;
 end;
/
 begin
 insert into orders(id_user, order_date) values (get_id_username('bianca01'),  TRUNC( SYSDATE )); 
 insert into orders_details(orders_id_order, products_id_product, order_quantity) values (orders_id_order_seq.currval, 8, 2);
 commit;
 end;
/ 
begin
 insert into orders(id_user, order_date) values (get_id_username('jojo2001'), TRUNC( SYSDATE )); 
 insert into orders_details(orders_id_order, products_id_product, order_quantity) values (orders_id_order_seq.currval, 10, 5);
 insert into orders_details(orders_id_order, products_id_product, order_quantity) values (orders_id_order_seq.currval, 3, 10);
 insert into orders_details(orders_id_order, products_id_product, order_quantity) values (orders_id_order_seq.currval, 6, 1);
 commit;
 end;
 /
 begin
 insert into orders(id_user, order_date) values (get_id_username('jojo2001'), TRUNC( SYSDATE )); 
 insert into orders_details(orders_id_order, products_id_product, order_quantity) values (orders_id_order_seq.currval, 1, 1);
 commit;
 end;
