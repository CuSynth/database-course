--2.1
select avg(tasks.priority) as avg
from tasks
-- group by tasks.running_by
order by avg
limit 3;

-- select users.name, avg(tasks.priority)
-- from
-- 	tasks
-- 	inner join users
-- 		on users.login = tasks.running_by
-- group by users.name
-- order by avg
-- limit 3;


--2.2
select concat(count(id), ' - ', extract(month from created), ' - ', running_by) as tasks
from tasks
where tasks.running_by is not null
  and created is not null
  and created between '2015-01-1' and '2015-12-31'
group by running_by, extract(month from created);


--2.3
select running_by,
       (sum(evaluation-spent) - sum(abs(evaluation-spent)))/2 as "-",
       (sum(abs(evaluation-spent)) + sum(evaluation-spent))/2 as "+"
from tasks
where running_by is not null
group by running_by
order by running_by;

select d.running_by,
       (sum(d.diff) - sum(abs(d.diff)))/2 as "-",
       (sum(abs(d.diff)) + sum(d.diff))/2 as "+"
from (select running_by, (evaluation - spent) as diff from tasks) as d
where d.running_by is not null
group by d.running_by
order by d.running_by;


--2.4
select least(started_by, running_by) as person_A, greatest(started_by, running_by) as person_B
from tasks
group by least(started_by, running_by), greatest(started_by, running_by)
order by least(started_by, running_by);


--2.5
select login, length(login) as len
from users
order by len desc
limit 1;


--2.6
drop table if exists char_names, varchar_names;

create table char_names (
    name char(512)
);

create table varchar_names (
    name varchar(512)
);

insert into char_names
values ('somename');
insert into varchar_names
values ('вввввввв');

select pg_column_size(char_names.name) as char_size, pg_column_size(varchar_names.name) as vchar_size
from char_names,
     varchar_names;


--2.7
select running_by, max(priority)
from tasks
-- where running_by is not null
group by running_by;
-- order by max(priority) desc;


--2.8
select running_by, sum(evaluation)
from tasks,
     (select avg(evaluation) from tasks) as mean
where tasks.evaluation >= mean.avg
group by running_by;

--2.9.a
drop view if exists task_counter;

create view task_counter as
select running_by,
       count(*),
       count(case
                 when spent <= evaluation and state = 'Закрыта'
                     then 1
                 else null
           end) as completed,
       count(case
                 when spent > evaluation
                     then 1
                 else null
            end) as delayed
from tasks
where running_by is not null
group by running_by
order by running_by;

select *
from task_counter;


--2.9.b
drop view if exists task_ocr;

create view task_ocr as
select running_by,
       count(case
                 when state <> 'Закрыта'
                     then 1
                 else null
           end) as opened,
       count(case
                 when state = 'Закрыта'
                     then 1
                 else null
           end) as closed,
      count(case
                 when state = 'Выполняется' or state = 'Переоткрыта'
                     then 1
                 else null
           end) as running
from tasks
where running_by is not null
group by running_by
order by running_by;

select *
from task_ocr;


--2.9.c
drop view if exists task_over_under;

create view task_over_under as
select running_by,
       sum(case
                 when spent <= evaluation
                     then evaluation - spent
                 else null
           end) as under,
       sum(case
                 when spent > evaluation
                     then spent - evaluation
                 else null
            end) as over
from tasks
where running_by is not null
group by running_by
order by running_by;

select *
from task_over_under;


--2.9.d
drop view if exists task_max_priority;

create view task_max_priority as
select running_by,
        max(priority) as max_priority
from tasks
where running_by is not null
group by running_by
order by running_by;

select *
from task_max_priority;




drop view if exists task_earliest;

create view task_earliest as
select running_by,
        min(created) as earliest
from tasks
where running_by is not null
group by running_by
order by running_by;

select *
from task_earliest;



drop view if exists task_summary_spent;

create view task_summary_spent as
select running_by,
        sum(spent) as earliest
from tasks
where running_by is not null
group by running_by
order by running_by;

select *
from task_summary_spent;



--2.10
select users.name, tasks.description
from users, tasks
where users.login = tasks.running_by;

select user_table.name, task_table.description
from (select description, running_by from tasks) as task_table,
     (select name, login from users) as user_table
WHERE user_table.login = task_table.running_by;

select (select name from users where login = tasks.running_by), tasks.description
from tasks
where tasks.running_by is not null;

-- select running_by, description from tasks
-- where running_by in (select login from users where login = tasks.running_by);

























