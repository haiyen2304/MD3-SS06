create database s06_bt2;
use s06_bt2;
create table users(
	id int primary key auto_increment,
    name varchar(100),
    address varchar(255),
    phone varchar(11),
    date_of_birth date,
    status bit
);
create table products(
	id int primary key auto_increment,
    name varchar(100),
    price double,
    stock int,
    status bit
);
create table shopping_cart(
	id int primary key auto_increment,
    user_id int,
    product_id int,
    quantity int,
    amount double,
    constraint fk_sc01 foreign key(user_id) references users(id),
    constraint fk_sc02 foreign key(product_id) references products(id)
);

insert into products(name,price,stock,status) value ('banh',1200,14,1);
insert into users (name,address,phone,date_of_birth,status) value ('Quang','Ha Noi',13213,'1990-5-21',1);
insert into shopping_cart(user_id,product_id,quantity,amount) value (1,1,3,3600);
drop procedure delete_shopping;
delimiter //
create procedure insert_shopping (IN user_id_IN int, IN product_id_IN int,IN quantity_IN int,IN amount_int int)
begin 
	#declare exit handler for sqlexception rollback;
    declare newQuantity INT;
    start transaction;
    select stock into newQuantity from products where id = product_id_IN;
    IF(newQuantity < quantity_IN) then 
    rollback;
    signal sqlstate '45000' set message_text = 'Not enough stock available';
	else
    insert shopping_cart(user_id,product_id,quantity,amount) values(user_id_IN,product_id_IN,quantity_IN,amount_int);
    commit;
     end if;
end//
delimiter ;
 call insert_shopping(1,1,15,3600);
 
 delimiter //
 create procedure delete_shopping(IN cart_id int)
 begin
	declare quantity_delete int;
	declare product_delete int;
    select quantity into quantity_delete from shopping_cart where id = cart_id;
    select product_id into product_delete from shopping_cart where id = cart_id;
	start transaction;
		delete from shopping_cart where id = cart_id;
		update products set stock = stock + quantity_delete where id = product_delete;
    commit;
end//
 select * from shopping_cart;
 select * from products;
 call delete_shopping(2);