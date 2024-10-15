create database s06_bt1;
use s06_bt1;
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


# Tạo triggle khi thay đổi giá của sản phẩm thì amount của shopping_cart cũng phải cập nhật lại
delimiter //
CREATE trigger update_amount 
	after update 
    on products
    for each row
    begin
		update shopping_cart as sc join products as p on sc.product_id = old.id set sc.amount = new.price * sc.quantity;
    end//
insert into products(name,price,stock,status) value ('banh',1200,14,1);
insert into users (name,address,phone,date_of_birth,status) value ('Quang','Ha Noi',13213,'1990-5-21',1);
insert into shopping_cart(user_id,product_id,quantity,amount) value (1,1,3,3600);
update products set price = 1300 where id = 1;
select * from shopping_cart;

# khi xoá product thì những dữ liệu ở bảng shopping_cart có chứa product bị xoá cũng phải xoá theo
delimiter //
create trigger delete_product
	after delete on products
    for each row
    begin
		delete from shopping_cart where product_id = old.id;
    end//
    delete from products where id = 1;
    alter table shopping_cart DROP foreign key fk_sc02;
    
    drop trigger before_update;
	
# Khi thêm 1 sản phẩm vào shopping_cart với số lượng n thì bên product cũng sẽ bị trừ đi n số lượng

delimiter //

create trigger before_update
before update on shopping_cart
for each row
begin
    -- Declare a variable to hold the stock quantity
    declare current_stock int;

    -- Get the current stock quantity for the product
    select stock into current_stock
    from products
    where id = old.product_id;

    -- Check if the updated quantity exceeds available stock
    if (new.quantity > old.quantity) and (current_stock - (new.quantity - old.quantity) < 0) then
        signal sqlstate '45000' set message_text = 'Vượt quá số lượng kho';
    end if;
end//
delimiter ;

delimiter //

create trigger after_update
after update on shopping_cart
for each row
begin
  if(new.quantity < old.quantity)
  then update products set stock = stock + (old.quantity - new.quantity);
  elseif(new.quantity > old.quantity)
  then update products set stock = stock - (new.quantity-old.quantity);
  end if;
end//
delimiter ;

