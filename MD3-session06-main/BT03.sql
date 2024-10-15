create database s06_bt3;
use s06_bt3;
create table users(
	id int primary key auto_increment,
    name varchar(100),
    my_money double,
    address varchar(255),
    phone varchar(11),
    dob date,
    status bit
);
create table transfer(
	sender_id int,
    receiver_id int,
    money double,
    transfer_date datetime,
    constraint fk_trans01 foreign key (sender_id) references users(id),
    constraint fk_trans02 foreign key (receiver_id) references users(id)
);
insert into users(name,my_money,address,phone,dob,status) values('Hai',24000,'Long Bien','1234','1990-05-12',1),('Son',10000,'Hung Yen','1231231','2001-10-21',1);
drop procedure transfer_money;
delimiter //
create procedure transfer_money(IN user_id_1 int, IN user_id_2 int, IN money_IN double)
begin
	declare money double;
    select my_money into money from users where id = user_id_1;
    start transaction;
    IF (money_IN > money) 
			then rollback;
             signal sqlstate '45000' set message_text = 'Not enough money available';
	else
		update users set my_money = my_money + money_IN where id = user_id_2;
        update users set my_money = my_money - money_IN where id = user_id_1;
        commit;
	end if;
end //
delimiter ;
call transfer_money(1,2,50000);
select * from users;