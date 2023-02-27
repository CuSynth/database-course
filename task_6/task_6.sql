-- drop table users, rooms;

create table if not exists users
(
    name     VARCHAR(255) not null,
    login    VARCHAR(255) not null unique,
    password VARCHAR(255) not null,
    primary key (login)
);

create table if not exists rooms
(
    name     VARCHAR(255) not null,
    link    VARCHAR(255) not null,
    primary key (link)
);

-- drop table messages;

create table if not exists messages
(
    id serial,
    _from varchar(255) not null,
    user_to varchar(255),
    room_to varchar(255),
    text TEXT,
    time timestamp,
    primary key (id, _from),
    foreign key (_from) references users(login),
    foreign key (user_to) references users(login),
    foreign key (room_to) references rooms(link),
    check ( user_to is not null or room_to is not null )
);

create or replace function timeset() returns trigger
as $$
begin
    new.time = now();
    return new;
end;
$$
language 'plpgsql';

drop trigger if exists timetrig on messages;

create trigger timetrig
    before insert
    on messages
    for each row
    execute function timeset();

create table if not exists users_in_rooms
(
    user_login varchar(255) not null,
    room_link varchar(255) not null,
    primary key(user_login, room_link),
    foreign key (user_login) references users(login),
    foreign key (room_link) references rooms(link)
);

insert into users(name, login, password)
values ('Vasya', 'v', 'v'),
       ('Petya', 'p', 'p'),
       ('nonV', 'nv', 'nv'),
       ('nonP', 'np', 'np');

insert into users(name, login, password)
values ('1', '1', '1');

insert into rooms(name, link)
values ('Room', '@room'),
       ('Room_2', '@room_2');

insert into users_in_rooms(user_login, room_link)
values ('nv', '@room_2'),
       ('np', '@room_2'),
       ('1', '@room_2'),
       ('v', '@room_2');

insert into users_in_rooms(user_login, room_link)
values ('np', '@room');

create table if not exists admins (
    _login varchar(255) not null,
    _where varchar(255) not null,
    primary key (_login, _where),
    foreign key (_login) references users(login),
    foreign key (_where) references rooms(link)
);

create table if not exists bans
(
    who varchar(256) not null ,
    _where varchar(256) not null ,
    whom varchar(256) not null ,
    reason text,
    primary key (who, _where),
    foreign key (who) references users(login),
    foreign key (_where) references rooms(link) ,
    foreign key (whom) references users(login)
);

insert into admins (_login, _where)
values ('1', '@room'),
       ('1', '@room_2');

insert into bans (who, _where, whom, reason)
values ('v', '@room_2', '1', 'Just for fun');











select exists(select * from users_in_rooms where user_login = '1' and room_link = '@room');