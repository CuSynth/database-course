-- 3.1 table lvl

drop table if exists a, b;

create table a (
    id serial primary key,
    data varchar(256)
);

create table b (
    id serial primary key,
    data varchar(256),
    aid int,
    foreign key (aid) references a(id)
);

-- Insertion

insert into b(data, aid)
values ('person_1_b', 1),
       ('person_2_b', 2);
-- Err, there is no person with id = 1 and 2

insert into a(data)
values ('person_1_a'),
       ('person_2_a');

insert into b(data, aid)
values ('person_1_b', 1),
       ('person_2_b', 2),
       ('person_1_b_new', 1);
-- Ok

insert into b(data, aid)
values ('person_2_b_new', 2),
       ('person_3_b', 3);
-- Err, no id == 3


-- Removal
delete
from a
where data like 'person_1_a';


-- Update
update a
set id = 3
where id = 1;



-- 3.1 SQL lvl

drop table if exists a_2, b_2;

create table a_2 (
    id serial primary key,
    data varchar(256)
);

create table b_2 (
    id serial primary key,
    data varchar(256),
    aid int not null
);

insert into b_2(data, aid)
select 'person_1_b', (select id from a_2 where data like 'person_1%');
-- err, no person_1 in A

insert into b_2(data, aid)
select 'person_2_b',  (select id from a_2 where data like 'person_2%');

insert into a_2(data)
values ('person_1_a'),
       ('person_2_a');

insert into b_2(data, aid)
select 'person_1_b', (select id from a_2 where data like 'person_1%');

insert into b_2(data, aid)
select 'person_2_b',  (select id from a_2 where data like 'person_2%');


-- 3.2

-- One-to-one
create table users (
    id serial primary key,
    name varchar(256) not null
);

create table is_male (
    id serial primary key,
    male bool not null,
    uid int unique,
    foreign key(uid) references users(id)
);

insert into users(name)
values ('user_1'),
       ('user_2'),
       ('user_3');

insert into is_male(uid, male)
values (1, true),
       (2, false),
       (3, true);

insert into is_male(uid, male)
values (1, false);
-- Err 1->1 already exists

-- One-to-many

create table manufacturers (
    id serial,
    name varchar,
    primary key(id)
);

create table models (
    id serial,
    mid int,
    model varchar(256),
    primary key(id),
    foreign key(mid) references manufacturers(id)
);


-- Many-to-many

create table car_model (
    id serial,
    model varchar(256),
    primary key(id)
);

create table color (
    id serial,
    color varchar(256),
    primary key(id)
);

create table model_color (
    mid int,
    cid int,
    foreign key (mid) references car_model(id),
    foreign key (cid) references color(id),
    primary key (mid, cid)
);

--  3.3
drop table if exists formulas;

create table formulas (
    name varchar(16),
    dependsOn_values varchar(256),
    ret_val varchar(256),
    where_to_use varchar(256)
);


insert into formulas(name, dependsOn_values, ret_val, where_to_use)
values ('F', 'mass, acceleration, symmetry', 'float', 'as float value'),
       ('G', 'mass, force, symmetry', 'int', 'as integer value'),
       ('P', 'volume, count', 'int', 'as integer value'),
       ('A', 'mass, deceleration, symmetry', 'float', 'as float value'),
       ('invA', 'mass, acceleration, asymmetry', 'float', 'as float value'),
       ('depends on A', 'A, mass, symmetry', 'int', 'as integer value');

insert into formulas(name, dependsOn_values, ret_val, where_to_use)
values ('incorrect', 'value , dymetry', 'int', 'as integer value');
-- очепятки => проблемы, тк теперь для value два определения, как и для symmetry

delete from formulas
where dependsOn_values like '%symmetry%';
-- удалит и '%symmetry%', и '%asymmetry%'

update formulas
set dependsOn_values = replace(dependson_values, 'symmetry', 'new_kind_of_symmetry');
-- 'asymmetry' => 'anew_kind_of_symmetry'. Why not..

select name
from formulas
where dependsOn_values like '%symmetry%';
-- вернет и '%symmetry%', и '%asymmetry%'

-- 4.4

-- Есть неатомарные значения, разделяем

drop table if exists  nf_1;

create table nf_1 (
    name varchar(16),
    argument varchar(16),
    arg_pos int,
    ret_val varchar(256),
    where_to_use varchar(256)
);

insert into nf_1 (name, argument, arg_pos, ret_val, where_to_use)
values  ('F', 'mass', 1, 'float', 'as float value'),
        ('F', 'acceleration', 2, 'float', 'as float value'),
        ('F', 'symmetry', 3, 'float', 'as float value'),
        ('G', 'mass', 1, 'int', 'as integer value'),
        ('G', 'force', 2, 'int', 'as integer value'),
        ('G', 'symmetry', 'int', 'as integer value'),
        ('P', 'volume', 1, 'int', 'as integer value'),
        ('P', 'count', 2, 'int', 'as integer value'),
        ('A', 'mass',  1, 'float', 'as float value'),
        ('A', 'deceleration', 2, 'float', 'as float value'),
        ('A', 'symmetry', 3, 'float', 'as float value'),
        ('invA', 'mass', 1, 'float', 'as float value'),
        ('invA', 'acceleration', 2, 'float', 'as float value'),
        ('invA', 'asymmetry', 3, 'float', 'as float value'),
        ('depends on A', 'A', 1, 'int', 'as integer value'),
        ('depends on A', 'mass', 2, 'int', 'as integer value'),
        ('depends on A', 'symmetry', 3, 'int', 'as integer value');



-- аргументы множественно зависят от функции (одня ф-я = много арг) => правим

drop table if exists nf_2_funcs, nf_2_args, nf_2_fToA;

create table nf_2_funcs (
    id serial,
    name varchar (16),
    primary key(id),
    ret_val varchar(256),
    where_to_use varchar(256)
);

create table nf_2_args (
    id serial,
    name varchar(16),
    primary key(id)
);

create table nf_2_fToA (
    id serial,
    fid int,
    aid int,
    primary key(id),
    foreign key (fid) references nf_2_funcs(id),
    foreign key (aid) references nf_2_args(id)
);

insert into nf_2_funcs(name, ret_val, where_to_use)
values ('F', 'float', 'as float value'),
       ('G', 'int', 'as integer value'),
       ('P', 'int', 'as integer value'),
       ('A','float', 'as float value'),
       ('invA', 'float', 'as float value'),
       ('depends on A', 'int', 'as integer value');


insert into nf_2_args(name)
values  ('mass'),
        ('acceleration'),
        ('symmetry'),
        ('force'),
        ('volume'),
        ('count'),
        ('deceleration'),
        ('asymmetry'),
        ('A');

insert into nf_2_fToA(fid, aid)
    select f.id, a.id from nf_2_funcs as f, nf_2_args as a where f.name = 'F' and a.name = 'mass';

insert into nf_2_fToA(fid, aid)
values  ((select id from nf_2_funcs where name = 'F'), (select id from nf_2_args where name = 'acceleration')),
        ((select id from nf_2_funcs where name = 'F'), (select id from nf_2_args where name = 'symmetry')),
        ((select id from nf_2_funcs where name = 'G'), (select id from nf_2_args where name = 'mass')),
        ((select id from nf_2_funcs where name = 'G'), (select id from nf_2_args where name = 'force')),
        ((select id from nf_2_funcs where name = 'G'), (select id from nf_2_args where name = 'symmetry')),
        ((select id from nf_2_funcs where name = 'P'), (select id from nf_2_args where name = 'volume')),
        ((select id from nf_2_funcs where name = 'P'), (select id from nf_2_args where name = 'count')),
        ((select id from nf_2_funcs where name = 'A'), (select id from nf_2_args where name = 'mass')),
        ((select id from nf_2_funcs where name = 'A'), (select id from nf_2_args where name = 'deceleration')),
        ((select id from nf_2_funcs where name = 'A'), (select id from nf_2_args where name = 'symmetry')),
        ((select id from nf_2_funcs where name = 'invA'), (select id from nf_2_args where name = 'mass')),
        ((select id from nf_2_funcs where name = 'invA'), (select id from nf_2_args where name = 'acceleration')),
        ((select id from nf_2_funcs where name = 'invA'), (select id from nf_2_args where name = 'asymmetry')),
        ((select id from nf_2_funcs where name = 'depends on A'), (select id from nf_2_args where name = 'A')),
        ((select id from nf_2_funcs where name = 'depends on A'), (select id from nf_2_args where name = 'mass')),
        ((select id from nf_2_funcs where name = 'depends on A'), (select id from nf_2_args where name = 'symmetry'));

-- Есть транзитивная зависимость применение <- возвр. типа <- функции. Решаем.

drop table if exists nf_3_funcs, nf_3_args, nf_3_types, nf_3_full;

create table nf_3_funcs (
    id serial,
    name varchar (16),
    primary key(id)
);

create table nf_3_args (
    id serial,
    name varchar(16),
    primary key(id)
);

create table nf_3_retvals (
    id serial,
    ret_val varchar(256),
    where_to_use varchar(256),
    primary key(id)
);

create table nf_3_full (
    id serial,
    fid int,
    aid int,
    tid int,
    primary key(id),
    foreign key (fid) references nf_3_funcs(id),
    foreign key (aid) references nf_3_args(id),
    foreign key (tid) references nf_3_retvals(id)
);

insert into nf_3_funcs(name)
values ('F'),
       ('G'),
       ('P'),
       ('A'),
       ('invA'),
       ('depends on A');

insert into nf_3_args(name)
values  ('mass'),
        ('acceleration'),
        ('symmetry'),
        ('force'),
        ('volume'),
        ('count'),
        ('deceleration'),
        ('asymmetry'),
        ('A');

insert into nf_3_retvals(ret_val, where_to_use)
values ('float', 'as float value'),
       ('int', 'as integer value');

insert into nf_3_full(fid, aid, tid)
values  (
         (select id from nf_3_funcs where name = 'F'),
         (select id from nf_3_args where name = 'mass'),
         (select id from nf_3_retvals where ret_val = 'float')
         ),
        (
         (select id from nf_3_funcs where name = 'F'),
         (select id from nf_3_args where name = 'acceleration'),
         (select id from nf_3_retvals where ret_val = 'float')
         ),
        (
         (select id from nf_3_funcs where name = 'F'),
         (select id from nf_3_args where name = 'symmetry'),
         (select id from nf_3_retvals where ret_val = 'float')
         ),
        (
         (select id from nf_3_funcs where name = 'G'),
         (select id from nf_3_args where name = 'mass'),
         (select id from nf_3_retvals where ret_val = 'int')
         ),
        (
         (select id from nf_3_funcs where name = 'G'),
         (select id from nf_3_args where name = 'force'),
         (select id from nf_3_retvals where ret_val = 'int')
         ),
        (
         (select id from nf_3_funcs where name = 'G'),
         (select id from nf_3_args where name = 'symmetry'),
         (select id from nf_3_retvals where ret_val = 'int')
         ),
        (
         (select id from nf_3_funcs where name = 'P'),
         (select id from nf_3_args where name = 'volume'),
         (select id from nf_3_retvals where ret_val = 'int')
         ),
        (
         (select id from nf_3_funcs where name = 'P'),
         (select id from nf_3_args where name = 'count'),
         (select id from nf_3_retvals where ret_val = 'int')
         ),
        (
         (select id from nf_3_funcs where name = 'A'),
         (select id from nf_3_args where name = 'mass'),
         (select id from nf_3_retvals where ret_val = 'float')
         ),
        (
         (select id from nf_3_funcs where name = 'A'),
         (select id from nf_3_args where name = 'deceleration'),
         (select id from nf_3_retvals where ret_val = 'float')
         ),
        (
         (select id from nf_3_funcs where name = 'A'),
         (select id from nf_3_args where name = 'symmetry'),
         (select id from nf_3_retvals where ret_val = 'float')
         ),
        (
         (select id from nf_3_funcs where name = 'invA'),
         (select id from nf_3_args where name = 'mass'),
         (select id from nf_3_retvals where ret_val = 'float')
         ),
        (
         (select id from nf_3_funcs where name = 'invA'),
         (select id from nf_3_args where name = 'acceleration'),
         (select id from nf_3_retvals where ret_val = 'float')
         ),
        (
         (select id from nf_3_funcs where name = 'invA'),
         (select id from nf_3_args where name = 'asymmetry'),
         (select id from nf_3_retvals where ret_val = 'float')
         ),
        (
         (select id from nf_3_funcs where name = 'depends on A'),
         (select id from nf_3_args where name = 'A'),
         (select id from nf_3_retvals where ret_val = 'int')
         ),
        (
         (select id from nf_3_funcs where name = 'depends on A'),
         (select id from nf_3_args where name = 'mass'),
         (select id from nf_3_retvals where ret_val = 'int')
         ),
        (
         (select id from nf_3_funcs where name = 'depends on A'),
         (select id from nf_3_args where name = 'symmetry'),
         (select id from nf_3_retvals where ret_val = 'int')
         );

-- Есть множественные зависимости ф-я -> возвр. значение, ф-я -> аргументы. Решаем.

drop table if exists nf_4_funcs, nf_4_args, nf_4_types, nf_4_fToArg, nf_4_fToRet;

create table nf_4_funcs (
    id serial,
    name varchar (16),
    primary key(id)
);

create table nf_4_args (
    id serial,
    name varchar(16),
    primary key(id)
);

create table nf_4_retvals (
    id serial,
    ret_val varchar(256),
    where_to_use varchar(256),
    primary key(id)
);

create table nf_4_fToArg (
    id serial,
    fid int,
    aid int,
    primary key(id),
    foreign key (fid) references nf_4_funcs(id),
    foreign key (aid) references nf_4_args(id)
);

create table nf_4_fToRet (
    id serial,
    fid int,
    rid int,
    primary key(id),
    foreign key (fid) references nf_4_funcs(id),
    foreign key (rid) references nf_4_retvals(id)
);

insert into nf_4_funcs(name)
values ('F'),
       ('G'),
       ('P'),
       ('A'),
       ('invA'),
       ('depends on A');

insert into nf_4_args(name)
values  ('mass'),
        ('acceleration'),
        ('symmetry'),
        ('force'),
        ('volume'),
        ('count'),
        ('deceleration'),
        ('asymmetry'),
        ('A');

insert into nf_4_retvals(ret_val, where_to_use)
values ('float', 'as float value'),
       ('int', 'as integer value');

insert into nf_4_fToArg(fid, aid)
values  (
         (select id from nf_4_funcs where name = 'F'),
         (select id from nf_4_args where name = 'mass')
         ),
        (
         (select id from nf_4_funcs where name = 'F'),
         (select id from nf_4_args where name = 'acceleration')
         ),
        (
         (select id from nf_4_funcs where name = 'F'),
         (select id from nf_4_args where name = 'symmetry')
         ),
        (
         (select id from nf_4_funcs where name = 'G'),
         (select id from nf_4_args where name = 'mass')
         ),
        (
         (select id from nf_4_funcs where name = 'G'),
         (select id from nf_4_args where name = 'force')
         ),
        (
         (select id from nf_4_funcs where name = 'G'),
         (select id from nf_4_args where name = 'symmetry')
         ),
        (
         (select id from nf_4_funcs where name = 'P'),
         (select id from nf_4_args where name = 'volume')
         ),
        (
         (select id from nf_4_funcs where name = 'P'),
         (select id from nf_4_args where name = 'count')
         ),
        (
         (select id from nf_4_funcs where name = 'A'),
         (select id from nf_4_args where name = 'mass')
         ),
        (
         (select id from nf_4_funcs where name = 'A'),
         (select id from nf_4_args where name = 'deceleration')
         ),
        (
         (select id from nf_4_funcs where name = 'A'),
         (select id from nf_4_args where name = 'symmetry')
         ),
        (
         (select id from nf_4_funcs where name = 'invA'),
         (select id from nf_4_args where name = 'mass')
         ),
        (
         (select id from nf_4_funcs where name = 'invA'),
         (select id from nf_4_args where name = 'acceleration')
         ),
        (
         (select id from nf_4_funcs where name = 'invA'),
         (select id from nf_4_args where name = 'asymmetry')
         ),
        (
         (select id from nf_4_funcs where name = 'depends on A'),
         (select id from nf_4_args where name = 'A')
         ),
        (
         (select id from nf_4_funcs where name = 'depends on A'),
         (select id from nf_4_args where name = 'mass')
         ),
        (
         (select id from nf_4_funcs where name = 'depends on A'),
         (select id from nf_4_args where name = 'symmetry')
         );

insert into nf_4_fToRet(fid, rid)
values  (
         (select id from nf_4_funcs where name = 'F'),
         (select id from nf_4_retvals where ret_val = 'float')
         ),
        (
         (select id from nf_4_funcs where name = 'G'),
         (select id from nf_4_retvals where ret_val = 'int')
         ),
        (
         (select id from nf_4_funcs where name = 'P'),
         (select id from nf_4_retvals where ret_val = 'int')
         ),
        (
         (select id from nf_4_funcs where name = 'A'),
         (select id from nf_4_retvals where ret_val = 'float')
         ),
        (
         (select id from nf_4_funcs where name = 'invA'),
         (select id from nf_4_retvals where ret_val = 'float')
         ),
        (
         (select id from nf_4_funcs where name = 'depends on A'),
         (select id from nf_4_retvals where ret_val = 'int')
          );