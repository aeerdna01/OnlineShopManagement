drop table accounts cascade constraints;

drop table user_details cascade constraints;

drop table categories cascade constraints;

drop table orders cascade constraints;

drop table orders_details cascade constraints;

drop table products cascade constraints;

drop table sizes cascade constraints;

drop table supplies cascade constraints;

drop sequence accounts_id_user_seq;

drop sequence orders_id_order_seq;

drop sequence products_id_product_seq;

drop sequence supplies_id_supply_seq;

drop function get_id_size;

drop function get_id_username;