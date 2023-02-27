-- 4.1

drop table if exists a, b;

create table a (
    id int,
    data varchar(256)
);

create table b (
    id int,
    data varchar(256)
);

insert into a
values (1, 'a_1'),
       (2, 'a_2'),
       (3, 'a_3'),
       (5, 'a_5');

insert into b
values (1, 'b_1'),
       (2, 'b_2'),
       (3, 'b_3'),
       (4, 'b_4');

select *
from a full outer join b on a.id = b.id
where a.id is null or b.id is null;

select *
from a full outer join b on a.id = b.id;

select *
from a inner join b on a.id = b.id;

select *
from a left join b on a.id = b.id;

select *
from a left join b on a.id = b.id
where b.id is null;

select *
from a right join b on a.id = b.id;

select *
from a right join b on a.id = b.id
where a.id is null;

-- 4.2

select id, title
from tasks as out
where priority = (select MAX(priority) from tasks as int
                   where int.started_by = out.started_by);

select t1.id, t1.title
from tasks as t1 full outer join tasks as t2 on t1.started_by = t2.started_by
group by t1.id, t2.started_by
having max(t2.priority) = t1.priority;



-- 4.3
select name
from users
where login in (select running_by from tasks where priority >= 10);

select u.name
from users as u,
     tasks as t
where (t.priority >= 10) and u.login = t.running_by
group by u.name;

select u.name
from users as u
    left join tasks t on u.login = t.running_by
where t.priority >= 10
group by u.name;

-- 4.4
select started_by, running_by
from tasks
where running_by is not null
union
select started_by, running_by
from tasks
where running_by is not null;

-- 4.5
select p.title, t.title
from tasks as t,
     projects as p;

select p.title, t.title
from tasks as t
     cross join projects as p;

