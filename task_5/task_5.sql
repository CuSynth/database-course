-- 5.1
drop table if exists A, B;

create table A (
    id int,
    data varchar(256)
);

create table B (
    id int,
    data varchar(256)
);

insert into A
values (1, '1'),
       (2, '2'),
       (3, '3'),
       (4, '44');

insert into B
values (1, '1'),
       (2, '2'),
       (3, '5');

begin;
update A set data = 't_1_4' where id = 4;
SELECT pg_sleep(10);
update B set data = 't_1_3' where id = 3;
commit;

select * from A;
select * from B;


-- 5.2 savepoint-commit-rollback
drop table if exists tmp;

create table tmp (
    a int
);

create or replace procedure somename()
as $$
begin
    insert into tmp
    values (123);
    commit;

    insert into tmp
    values (321321);

    rollback;

    insert into tmp
    values (321);

    commit;
end;
$$
language 'plpgsql';

call somename();

select *
from tmp;

begin;
    insert into tmp values (1);
    savepoint pt;
    insert into tmp values (2);
    rollback to pt;
    insert into tmp values (3);
--     rollback;
commit;







-- 5.2 cycle

drop table if exists cycle;

create table cycle (
    ID serial,
    data varchar(16)
);

drop function if exists upd();

create or replace function upd() returns trigger
as $$
begin
    new.data = 'no data here';
    return new;
end;
$$
language 'plpgsql';

drop trigger if exists set_data on cycle;

create trigger set_data
before insert or update
on cycle
for each row
execute function upd();

insert into cycle(data)
values ('data1'),
       ('data2');

select *
from cycle;

update cycle
set data = 'newdata'
where id = 1;

select *
from cycle;




-- recursion

drop table if exists factorial;

create table factorial (
    N int,
    step int,
    res int
);

create or replace function mult() returns trigger
as $$
begin
    if new.N = new.step then return new;
    end if;

    insert into factorial (N, step, res)
    values (new.N, new.step+1, new.res*(new.step+1));

    return new;
end;
$$
language 'plpgsql';

drop trigger if exists ftr on factorial;

create trigger ftr
    before insert
    on factorial
    for each row
    execute function mult();

insert into factorial (N, step, res)
values (4, 1, 1);

select *
from factorial;




create or replace function fact(N int)
returns int
as $$
begin
    if N = 1 then
        return 1;
    end if;

    return N * fact(N-1);
end;
$$
language 'plpgsql';

select *
from fact(4);



with recursive r as (
    select
        1 as i,
        1 as factorial
    union
    select
        i+1 as i,
        factorial * (i+1) as factorial
    from r
    where i < 4
)
select * from r;








-- 5.3

drop table if exists orders;

create table orders (
    item varchar(16),
    time timestamp
);

insert into orders(item, time)
values ('item_1', '2022-01-10 04:05:06'),
       ('item_2', '2022-01-30 10:15:50'),
       ('item_3', '2022-02-01'),
       ('item_4', '2022-03-17 15:22:59'),
       ('item_5', '2022-05-04');

select item, time::date
from orders
where time::date >= '2022-01-15'
  and time::date <= '2022-04-01';








