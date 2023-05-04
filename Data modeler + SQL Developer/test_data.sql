---------------------------------------------------------------------------------------------------------------------------------------
/* TEST DATA */
---------------------------------------------------------------------------------------------------------------------------------------

/* 
    PRODUCTS
    insert new product
*/
declare 
    var_price number(3) := 99;
    var_type varchar2(10) := 'Men';
    var_id_category number(1) := 1;
    var_id_size number(1) := 3;
begin
    insert into products(price,id_category, id_size, type) values (var_price, var_id_category, var_id_size, var_type);
    commit;
end;
/

---------------------------------------------------------------------------------------------------------------------------------------

/*
    PRODUCTS 
    update the price of a product 
*/

select p.price, p.type, c.name
from products p, categories c
where type  = 'Women' and p.id_category = c.id_category;

accept p_price prompt 'How much the price will increase: ';

update products
set price = price + '&p_price'
where type  = 'Women'; 

select p.price, p.type, c.name
from products p, categories c
where type  = 'Women' and p.id_category = c.id_category; 

---------------------------------------------------------------------------------------------------------------------------------------

 /*
    ACCOUNTS + USERS_DETAILS
    the total number of orders placed in the store
 */
 
 select * from accounts;
 select 
    sum(total_orders) as "TOTAL NUMBER OF ORDERS"
 from accounts;
 
 ---------------------------------------------------------------------------------------------------------------------------------------
 
/*
    ACCOUNTS + USERS_DETAILS
    display customer name, number and amount of all orders made
*/

select
    u.first_name || ' ' || u.last_name as "CUSTOMER FULL NAME",
    a.total_orders,
    sum(o.payment) "TOTAL"
from
    accounts a, user_details u, orders o
where
    a.id_user = u.id_user 
    and a.id_user = o.id_user
group by
     u.first_name || ' ' || u.last_name,
     a.total_orders;
 
 ---------------------------------------------------------------------------------------------------------------------------------------
 
 /*
    ACCOUNTS & USER_DETAILS
    display contact details for the customer with the most orders
 */
 
 select 
    u.first_name || ' ' || u.last_name as "CUSTOMER FULL NAME",
    u.address, u.phone, a.total_orders
from 
    accounts a, user_details u
where a.id_user = u.id_user
    and a.total_orders = (select max(total_orders) from accounts);
  
---------------------------------------------------------------------------------------------------------------------------------------

/* 
    ACCOUNTS & USER_DETAILS
    display the administrator of the store
*/

select 
     u.first_name || ' ' || u.last_name as "SHOP ADMINISTRATOR"
from 
    accounts a, user_details u
where a.id_user = u.id_user
    and a.role = 'administrator';

---------------------------------------------------------------------------------------------------------------------------------------

/* 
    USER_DETAILS
    display the contact details and the city from address
*/

 select 
    first_name || ' ' || last_name as "USER FULL NAME",
    substr(address, instr(address,' ',-1)+1) as "CITY",
    email, phone
 from user_details;
 
---------------------------------------------------------------------------------------------------------------------------------------

/*
    SIZES + CATEGORIES + PRODUCTS + SUPPLIES
    display categories of items available in the store and the quantity supplied
*/
 
 select
    s.name as "SIZES",
    c.name as  "TYPES OF CLOTHES",
    p.type as "W/M",
    p.stock_quantity as "NUMBER OF ITEMS",
    sp.supply_quantity as "SUPPLY ITEMS",
    sp.supply_date as "SUPPLY DATE"
 from 
    sizes s, categories c, products p, supplies sp
 where 
    p.id_category = c.id_category
    and p.id_size = s.id_size
    and p.id_product = sp.id_product;
 
---------------------------------------------------------------------------------------------------------------------------------------

/*
    SIZES + CATEGORIES + PRODUCTS 
    displaying products with reduced available stock
*/

 select
    s.name as "SIZES",
    c.name as  "TYPES OF CLOTHES",
    p.type as "W/M",
    p.stock_quantity
 from 
    sizes s, categories c, products p
 where 
    p.id_category = c.id_category
    and p.id_size = s.id_size
    and p.stock_quantity < 15;
    
---------------------------------------------------------------------------------------------------------------------------------------

 /*
    ORDERS + ORDERS_DETAILS
    displaying the best-selling product
*/

 with bestseller as (
    select
        p.id_product,
        sum(orders_details.order_quantity) as sold_quantity
    from products p, orders_details
    where p.id_product = orders_details.products_id_product
    group by p.id_product
 )
 select 
    p.id_product,
    best.sold_quantity,
    best.sold_quantity * p.price as "AMOUNT SOLD"
from
    products p, bestseller best
where
    p.id_product = best.id_product
    and best.sold_quantity = (select max(sold_quantity) from bestseller);

--------------------------------------------------------------------------------------------------------------------------------------- 

---------------------------------------------------------------------------------------------------------------------------------------
 /* VIEW DATA */
---------------------------------------------------------------------------------------------------------------------------------------
 select * from accounts;
 select * from user_details;
 select * from products;
 select * from sizes;
 select * from categories;
 select * from supplies;
 select * from orders;
 select * from orders_details;
 
---------------------------------------------------------------------------------------------------------------------------------------
/* TEST CONSTRAINTS & TRIGGERS */
---------------------------------------------------------------------------------------------------------------------------------------

/* sizes_name_ck */
insert into sizes(id_size, name) VALUES (1, 'AXM');

/* accounts_password_ck */
insert into accounts(id_user, username, password, role) VALUES (7, 'abc', 'abcd1234', 'customer');

/* accounts_role_ck */
insert into accounts(id_user, username, password, role) VALUES (3, 'abc', 'Abcd1234', 'user');

/* categories_name_uk */
insert into categories(id_category, name) values (4, 'Shirts');

/* supplies_order_trg */
insert into supplies(id_product, supply_date, supply_quantity) values(10, '1-JAN-2020', 25);