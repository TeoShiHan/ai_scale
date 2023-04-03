use smartscale;
DROP TABLE Produce;
CREATE TABLE Produce (
    produce_id int auto_increment,
    produce_name varchar(30),
    unit_price float,
    produce_type varchar(30),
    produce_image MEDIUMBLOB,
    primary key (produce_id)
);


drop table Sales;

CREATE TABLE Sales (
    user_id          varchar(30),
    transaction_date datetime,
    item_number      int,
    produce_id       int,
    sale_price       double,
    primary key (user_id, transaction_date),
    foreign key (produce_id) references produce(produce_id)
);