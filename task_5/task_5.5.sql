CREATE  TYPE department_t AS ENUM ('Производство', 'Поддержка пользователей', 'Бухгалтерия', 'Администрация');
CREATE TYPE state_t AS ENUM ('Новая', 'Переоткрыта', 'Выполняется', 'Закрыта');



create table users (
	name varchar(256) not null,
	login varchar(256) not null,
	email varchar(256) not null unique,
	department department_t not null,
	primary key(login)
);

create table projects (
	title varchar(256) not null,
	description text,
	beginning date not null,
	ending date,
	primary key(title)
);

create table tasks(
	id serial primary key,
	project varchar(256) not null,
	title varchar(256) not null,
	priority int not null,
	description text,
	state state_t not null,
	evaluation int,
	spent int,
	started_by varchar(256) not null,
	running_by varchar(256),
	created date,
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


drop table if exists cache;

create table cache (
    id serial,
    task_id int,
    task_changed timestamp not null,
    removed bool,
    project varchar(256) not null,
	title varchar(256) not null,
	priority int not null,
	description text,
	state state_t not null,
	evaluation int,
	spent int,
	started_by varchar(256) not null,
	running_by varchar(256),
	created date,
    foreign key (project) references projects(title),
	foreign key (started_by) references users(login),
	foreign key (running_by) references users(login),
	primary key (id)
);


create or replace function update_f()
returns trigger as
$$
begin
    if tg_op = 'INSERT' then
        insert into cache(task_id, task_changed, removed, project, title, priority,
                  description, state, evaluation, spent, started_by, running_by, created)
        values (new.id, now(), false, new.project, new.title, new.priority,
                  new.description, new.state,new. evaluation, new.spent, new.started_by, new.running_by, new.created);
    end if;

    if tg_op = 'UPDATE' then
        insert into cache(task_id, task_changed, removed, project, title, priority,
                  description, state, evaluation, spent, started_by, running_by, created)
        values (new.id, now(), false, new.project, new.title, new.priority,
                  new.description, new.state,new.evaluation, new.spent, new.started_by, new.running_by, new.created);
    end if;

    if tg_op = 'DELETE' then
        insert into cache(task_id, task_changed, removed, project, title, priority,
                  description, state, evaluation, spent, started_by, running_by, created)
        values (old.id, now(), true, old.project, old.title, old.priority,
                  old.description, old.state, old.evaluation, old.spent, old.started_by, old.running_by, old.created);
    end if;

    return new;
end;
$$
language plpgsql;

create trigger update_trigger
    after insert or update or delete
    on tasks
    for each row
    execute procedure update_f();



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
		('T_8', 8, 'T_8, started by drozdov, running by kasatkin, закрыта', 'Закрыта', 30, 10, 'МВД-Онлайн', 'drozdov', 'kasatkin', '2016-01-4'),
        ('cache', 10, 'will be cached', 'Закрыта', 30, 10, 'МВД-Онлайн', 'drozdov', 'kasatkin', '2015-01-4');

update tasks
set state = 'Переоткрыта' where title = 'cache';

delete
from tasks
where title = 'cache';

select *
from cache;






create or replace function history_f(prj varchar(256), ttl varchar(256))
returns setof cache as
$$
begin 
    return query 
    select * from cache
    where project = prj and title = ttl;
end;
$$
language plpgsql;

select *
from history_f('МВД-Онлайн', 'cache');






create or replace function rollback_f(restore_task_id int)
returns varchar(256) as
$$
declare
    new_row cache%rowtype;
    old_row cache%rowtype;
begin
    select *
    from cache
    where id = (select max(id) from cache where task_id = restore_task_id)
    into new_row;

    if new_row is null then
        return 'There are no such row';
    end if;

--     return new_row.title;

    select *
    from cache
    where project = new_row.project
        and title = new_row.title
        and id < new_row.id
        and task_changed <= new_row.task_changed
    order by id desc
    limit 1
    into old_row;

    if old_row.id is null then
        delete from tasks where id = new_row.task_id;
        return 'The raw was new. Deleted.';
    end if;

    if new_row.removed and not old_row.removed then
        insert into tasks( id, title, priority, description, state, evaluation, spent, project, started_by, running_by, created)
        values (old_row.task_id, old_row.title, old_row.priority, old_row.description, old_row.state, old_row.evaluation,
                old_row.spent, old_row.project, old_row.started_by, old_row.running_by, old_row.created);
    else
        if old_row.removed and not new_row.removed then
            delete from tasks where id = old_row.task_id;
        else
            if not old_row.removed and not new_row.removed then
               update tasks
                set id = old_row.task_id,
                    title = old_row.title,
                    priority = old_row.priority,
                    description = old_row.description,
                    state = old_row.state,
                    evaluation = old_row.evaluation,
                    spent = old_row.spent,
                    project = old_row.project,
                    started_by = old_row.started_by,
                    running_by = old_row.running_by,
                    created = old_row.created
                where id = new_row.task_id;
            else
                return 'Err';
            end if;
        end if;
    end if;

    return 'Done';
end;
$$
language plpgsql;


-- del. 'cache' already removed

select *
from tasks;

select *
from history_f('МВД-Онлайн', 'cache');

select *
from rollback_f(15);

select *
from tasks;

select *
from history_f('МВД-Онлайн', 'cache');



-- insert
insert into tasks(title, priority, description, state, evaluation, spent, project, started_by, running_by, created)
values  ('not cached', 100, 'T_100, started by kasatkin, running by null, новая', 'Новая', 100, 1000, 'РТК', 'kasatkin', null, '2015-01-1');

select *
from tasks;

select *
from history_f('РТК', 'not cached');

select *
from rollback_f(16);

select *
from tasks;

select *
from history_f('РТК', 'not cached');

-- upd

update tasks
set priority = '-10'
where title = 'not cached';

update tasks
set priority = '-100'
where title = 'not cached';

select *
from tasks;

select *
from history_f('РТК', 'not cached');

select *
from rollback_f(16);

select *
from tasks;

select *
from history_f('РТК', 'not cached');



