CREATE TYPE department_t AS ENUM ('Производство', 'Поддержка пользователей', 'Бухгалтерия', 'Администрация');
CREATE TYPE state_t AS ENUM ('Новая', 'Переоткрыта', 'Выполняется', 'Закрыта');

create table users (
	"name" varchar(256) not null,
	"login" varchar(256) not null primary key,
	"email" varchar(256) not null unique,
	"department" department_t not null
);

create table projects (
	"title" varchar(256) not null primary key,
	"description" text,
	beginning date not null,
	"ending" date
);

create table tasks(
	"id" serial primary key,
	"project" varchar(256) not null,
	"title" varchar(256) not null,
	"priority" int not null,
	"description" text,
	"state" state_t not null,
	"evaluation" int,
	"spent" int,
	"started_by" varchar(256) not null,
	"running_by" varchar(256),
	"created" date,
	foreign key (project) references projects(title), --on delete restrict on update cascade,
	foreign key (started_by) references users(login), --on delete restrict on update cascade,
	foreign key (running_by) references users(login) --on delete restrict on update cascade
);


insert into users(name, login, email, department)
values('Касаткин Артем', 'kasatkin', 'kasatkin@gmail.com', 'Администрация'),
	  ('Петорва София', 'petrova', 'petrova@gmail.com', 'Бухгалтерия'),
	  ('Дроздов Федр', 'drozdov', 'drozdov@gmail.com', 'Администрация'),
	  ('Иванова Василина', 'ivanova', 'ivanova@gmail.com', 'Бухгалтерия'),
	  ('Беркут Алексей', 'berkut', 'berkut@gmail.com', 'Поддержка пользователей'),
	  ('Белова Вера', 'belova', 'belova@gmail.com', 'Производство'),
	  ('Макенрой Алексей', 'makenroy', 'makenroy@gmail.com', 'Производство');

insert into projects(title, beginning, ending)
values('РТК', '2016-01-31', null),
	  ('СС.Коннект', '2015-02-23', '2016-12-31'),
	  ('Демо-Сибирь', '2015-05-11', '2015-01-31'),
	  ('МВД-Онлайн', '2015-05-22', '2016-01-31'),
	  ('Поддержка', '2016-06-07', null);


insert into tasks(title, priority, description, state, evaluation, spent, project, started_by, running_by, created)
values  ('T_100', 100, 'T_100, started by kasatkin, running by null, новая', 'Новая', 100, 1000, 'РТК', 'kasatkin', null, '2015-01-1'),
		('T_20', 20, 'T_20, started by belova, running by petrova, выполняется', 'Выполняется', 200, 2000, 'СС.Коннект', 'belova', 'petrova', '2015-02-2'),
		('T_300', 300, 'T_300, started by drozdov, running by petrova, выполняется', 'Выполняется', 300, 3000, 'СС.Коннект', 'drozdov', 'petrova', '2015-01-5'),
		('T_10', 10, 'T_10, started by petrova, running by ivanova, переоткрыта', 'Переоткрыта', 400, 4000, 'СС.Коннект', 'petrova', 'ivanova', '2015-01-17'),
		('T_15', 15, 'T_15, started by ivanova, running by petrova, закрыта', 'Закрыта', 5000, 500, 'Поддержка', 'ivanova', 'petrova', '2015-05-12'),
		('T_55', 55, 'T_55, started by kasatkin, running by drozdov, закрыта', 'Закрыта', 4000, 400, 'СС.Коннект', 'kasatkin', 'drozdov', '2015-01-13'),
		('T_1', 1, 'T_1, started by drozdov, running by drozdov, выполняется', 'Выполняется', 100, 1000, 'Поддержка', 'drozdov', 'drozdov', '2015-10-1'),
		('T_2', 2, 'T_2, started by kasatkin, running by ivanova, переоткрыта', 'Переоткрыта', 30, 10, 'МВД-Онлайн', 'kasatkin', 'ivanova', '2015-09-15'),
		('T_3', 3, 'T_3, started by kasatkin, running by makenroy, закрыта', 'Закрыта', 30, 10, 'МВД-Онлайн', 'kasatkin', 'makenroy', '2015-01-28'),
		('T_4', 4, 'T_4, started by kasatkin, running by berkut, закрыта', 'Закрыта', 30, 10, 'МВД-Онлайн', 'kasatkin', 'berkut', '2015-01-15'),
		('T_5', 5, 'T_5, started by drozdov, running by kasatkin, закрыта', 'Закрыта', 30, 10, 'МВД-Онлайн', 'drozdov', 'kasatkin', '2016-01-1'),
		('T_6', 6, 'T_6, started by drozdov, running by kasatkin, закрыта', 'Закрыта', 30, 10, 'МВД-Онлайн', 'drozdov', 'kasatkin', '2016-01-2'),
		('T_7', 7, 'T_7, started by drozdov, running by kasatkin, закрыта', 'Закрыта', 30, 10, 'МВД-Онлайн', 'drozdov', 'kasatkin', '2016-01-3'),
		('T_8', 8, 'T_8, started by drozdov, running by kasatkin, закрыта', 'Закрыта', 30, 10, 'МВД-Онлайн', 'drozdov', 'kasatkin', '2016-01-4');

drop table tasks;



insert into tasks(title, priority, description, state, evaluation, spent, project, started_by, running_by)
values  ('T_8', 8, 'T_8, started by drozdov, running by kasatkin, переоткрыта', 'Переоткрыта', 30, 10, 'МВД-Онлайн', 'drozdov', 'kasatkin', '2016-01-4');

select *
from users;

select *
from projects;


--3a
select *
from tasks;


select title, priority, description, state, evaluation, spent, project, ut.name as started_by, running_by
from users ut, tasks tt
where ut.login = tt.started_by;

--select title, priority, description, state, evaluation, cost, project, users(tt.started_by)login as started_by, running_by
--from tasks tt


--1.3b, c, d..
select name, department
from users;

select login, email
from users;

select *
from tasks;
--where priority > 50

select distinct running_by
from tasks
where running_by is not null;

select started_by
from tasks where started_by is not null
union
select running_by
from tasks where running_by is not null;

select title, started_by, running_by
from tasks
where started_by != 'petrova'
	and running_by in ('ivanova', 'makenroy', 'berkut');

--1.4
select  title, created
from tasks
where running_by = 'kasatkin'
--   and created in ('2016-01-01', '2016-01-02', '2016-01-03')
	and created between '2016-01-01' and '2016-01-03';

--1.5
select tt.description , ut.department as given_by
from tasks tt,
     users ut
where tt.running_by = 'petrova'
  and tt.started_by = ut.login
  and ut.department in ('Производство', 'Бухгалтерия', 'Администрация');

--1.6
delete
from tasks
where title like 'T_null%';


insert into tasks(title, priority, description, state, evaluation, spent, project, started_by, running_by, created)
values  ('T_null1', 161, 'T_161, started by kasatkin, running by null, переоткрыта', 'Переоткрыта', 30, 10, 'МВД-Онлайн', 'kasatkin', null, null),
		('T_null2', 162, 'T_162, started by drozdov, running by null, переоткрыта', 'Переоткрыта', 30, 10, 'МВД-Онлайн', 'drozdov', null, null),
		('T_null3', 163, 'T_163, started by berkut, running by null, переоткрыта', 'Переоткрыта', 30, 10, 'МВД-Онлайн', 'berkut', null, null);

select *
from tasks
where running_by is null;

update tasks
set running_by = 'kasatkin'
where running_by is null;

select *
from tasks
where title like 'T_null%';


--1.7
drop table if exists tasks2;

create table tasks2 as
select *
from tasks;

select *
from tasks
order by id;

select *
from tasks2
order by id;

--1.8a
insert into users(name, login, email, department)
values  ('Петров Артем', 'petrov1', 'petrov1@gmail.com', 'Администрация'),
		('Петров Федр', 'petrov2', 'petrov2@gmail.com', 'Администрация'),
		('Петрова Вера', 'petrova2', 'petrova2@gmail.com', 'Администрация');

select *
from users
where name not like  '%а'
	and login like 'p%r%%';


delete
from users
where login in ('petrov1', 'petrov2', 'petrova2');
