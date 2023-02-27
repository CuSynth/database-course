
drop table if exists nodes, files cascade ;

create table nodes (
    id serial primary key,
    path varchar(256) not null
);

create table files (
    id serial,
    name        varchar(256) not null,
    parent_id   int          not null,
    node_id     int          not null,
    size        int          not null,
    created     date         not null,
    written     date         not null,
    modified    date         not null,
    primary key (id, name, node_id),
    foreign key (node_id) references nodes(id)
);

insert into nodes (path)
values ('server_1'),
       ('server_2'),
       ('server_3');


insert into files (name, parent_id, node_id, size, created, written, modified)
values ('fld_1', 0, 1, 123, '2022-01-01', '2022-02-02', '2022-01-01'),
       ('fld_2', 0, 2, 123, '2022-01-01', '2022-02-02', '2022-01-01'),
       ('file_1', 1, 1, 123, '2022-01-01', '2022-02-02', '2022-01-01'),
       ('file_2', 1, 2, 123, '2022-01-01', '2022-02-02', '2022-01-01'),
       ('file_3', 1, 3, 123, '2022-01-01', '2022-02-02', '2022-01-01'),
       ('file_4', 2, 3, 123, '2022-01-01', '2022-02-02', '2022-01-01');



drop function if exists get_fid(path varchar, dir int);

-- search and get id of file located by 'path' in directory 'dir'
create or replace function get_fid(path varchar, dir int)
returns int as $$
declare
    slash_pos int;
    result_id int;
begin
    if path = '' then return dir; end if; -- searching current dir
    select position('/' in path) into slash_pos;
    if slash_pos = 0 then  -- there is no /, trying to search file in current dir
        select id
        from files
        where parent_id = dir and name = path
        limit 1
        into result_id;

        -- coalesce()
        if result_id is null then
            return -1;  -- no such file there
        else
            return result_id;
        end if;
    else    -- there is a /. So, we need to go into some subdir
        select id
        from files
        where parent_id = dir and name = (select substring(path, 1, slash_pos-1))
        limit 1
        into result_id;

        if result_id is null then
            return -1;  -- there is no such subdir here
        else
            return get_fid((select substring(path, slash_pos+1)), result_id);   -- search in subdirectory
        end if;
    end if;
end;
$$
language plpgsql;


-----------------------------------------------------------------------------------
drop function if exists touch(fname varchar, dir varchar, fnode int, fsize int, fcreated date, fchanged date);

-- create file fname in directory dir
create or replace function touch(fname varchar, dir varchar, fnode int, fsize int, fcreated date, fchanged date)
returns varchar(256) as
$$
declare 
    dir_id int;
begin
    if fname like '%/%' then
        return 'Name cannot contain / symbol';
    end if;

    select get_fid(dir, 0) into dir_id;
    if dir_id != 0 and not exists (select * from files where id = dir_id) then
        return  'No such dir';
    end if;

    if exists(select * from files where name = fname and parent_id = dir_id) then
        return 'Already exists';
    end if;

    insert into files (name, parent_id, node_id, size, created, written, modified)
    values (fname, dir_id, fnode, fsize, fcreated, now(), fchanged);
    return 'Touched!';
end;
$$
language plpgsql;


SELECT *
FROM touch('touch_test', 'fld_0', 1, 1024, now()::TIMESTAMP::date, now()::TIMESTAMP::date);

SELECT *
FROM files;

SELECT *
FROM touch('touch_test', 'fld_1', 1, 1024, now()::TIMESTAMP::date, now()::TIMESTAMP::date);

SELECT *
FROM touch('not_touch_test', 'fld_1/touch_test', 1, 1024, now()::TIMESTAMP::date, now()::TIMESTAMP::date);


-----------------------------------------------------------------------------------
drop function if exists remove(path varchar);


-- remove file located by path
create or replace function remove(path varchar)
returns varchar(256) as
$$
declare
    fid int;
begin
    select get_fid(path, 0) into fid;
    if fid = -1 then
        return 'There is no such file';
    end if;

    if exists(select * from files where parent_id = fid) then
        return 'Trying to remove not empty directory';
    end if;

    delete from files cascade where id = fid;
    return 'Removed';
end;
$$
language plpgsql;

select *
from remove('fld_1/touch_test');

select *
from files;

select *
from remove('fld_1/touch_test/not_touch_test');

select *
from files;

-----------------------------------------------------------------------------------
drop function if exists rename(path_from varchar, name_to varchar);

-- rename file located by path_from to name name_to
create or replace function rename(path_from varchar, name_to varchar)
returns varchar(256) as
$$
declare
    fid int;
begin
    if name_to like '%/%' then
        return 'Name cannot contain / symbol';
    end if;

    select get_fid(path_from, 0) into fid;
    if fid = -1 then
        return 'There is no such file';
    end if;

    if exists(select * from files where name = name_to and parent_id = (select parent_id from files where id = fid)) then
        return 'Already exists';
    end if;

    update files set name = name_to, modified = now() where  id = fid;
    return 'Renamed';
end;
$$
language plpgsql;


select *
from files;

select *
from rename('fld_0/file_1', 'someneme');

select *
from rename('fld_1/file_1', 'file_2');

select *
from rename('fld_1/file_1', 'not_file_1');

select *
from files;


-----------------------------------------------------------------------------------
drop function if exists move(file_path varchar, dir_to varchar, save_original bool);

-- move file located by file_path to directory dir_to
create or replace function move(file_path varchar, dir_to varchar, save_original bool default false)
returns varchar(256) as
$$
declare
    fid int;
    did int;
    fname varchar(256);
    searchres varchar(256);
begin
    select get_fid(dir_to, 0) into did;
    if did = -1 then
        return 'There is no such directory';
    end if;

    select get_fid(file_path, 0) into fid;
    if fid = -1 then
        return 'There is no such file';
    end if;

    fname = substring(file_path, char_length(file_path) - (select position('/' in reverse(file_path))) + 2);

    if exists(select * from files where name = fname and parent_id = did) then
        return 'File already exists';
    end if;

    if save_original then
        select touch(name, dir_to, node_id, size, created, modified)
        from files
        where id = fid
        into searchres;

        if searchres not like('Touched') then
            return searchres;
        end if;

        return 'Copied';
    else
        update files set parent_id = did, modified = now() where id = fid;
        return 'Mooved';
    end if;

end;
$$
language plpgsql;


select *
from files;

select *
from move('fld_0/asd', '');

select *
from move('fld_1/file_2', 'fld_0');

select *
from move('fld_1/file_3', 'fld_1');

select *
from move('fld_1/file_2', '');

select *
from files;

-----------------------------------------------------------------------------------
drop function if exists copy(file_path varchar, dir_to varchar);


-- copy file located by file_path to directory dir_to
create or replace function copy(file_path varchar, dir_to varchar)
returns varchar(256) as
$$
declare
begin
    return move(file_path, dir_to, true);
end;
$$
language plpgsql;

select *
from files;

select *
from copy('fld_0/asd', '');

select *
from copy('file_2', 'fld_0');

select *
from copy('fld_1/file_3', 'fld_1');

select *
from copy('file_2', 'fld_1');

select *
from files;


-----------------------------------------------------------------------------------
drop function if exists full_path(fid int);


create or replace function full_path(fid int)
returns varchar(256) as
$$
declare
    row files%rowtype;
begin
    if not exists(select * from files where id = fid) then
        return 'There is no such file';
    end if;

    select * from files where id = fid into row;
    if row.parent_id = 0 then
        return row.name;
    end if;

    return concat(full_path(row.parent_id), '/', row.name);

end;
$$
language plpgsql;


drop function if exists find(mask varchar, depth int);

create or replace function find(mask varchar, depth int)
returns setof varchar(256) as
$$
begin
    return query
    select *
    from  (select full_path(id) as path from files) as p
    where p.path like mask
          and char_length(p.path) - char_length(replace(p.path, '/', '')) <= depth;

--     return query
--     select full_path(id) from files
--     where full_path(id) like mask
--           and char_length(full_path(id)) - char_length(replace(full_path(id), '/', '')) <= depth;
end;
$$
language plpgsql;

select *
from files;

select *
from find('%', 0);

select *
from find('%not%', 3);

select *
from find('%file_%', 1);

