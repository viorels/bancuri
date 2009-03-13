-- ================================================================================
--   postgres SQL DDL Script File
-- ================================================================================


-- ===============================================================================
-- 
--   Generated by:      tedia2sql -- v1.2.12
--                      See http://tedia2sql.tigris.org/AUTHORS.html for tedia2sql author information
-- 
--   Target Database:   postgres
--   Generated at:      Fri Mar 13 21:55:16 2009
--   Input Files:       db/dia/bancuri.dia
-- 
-- ================================================================================



-- Generated SQL Constraints Drop statements
-- --------------------------------------------------------------------

drop index idx_joke_link;
drop index idx_joke_for_day;
drop index idx_joke_version_rating;
drop index idx_users_email;
drop index idx_user_openid_user_id;
drop index idx_tag_tag;
drop index idx_session_cookie;
-- alter table joke_version drop constraint joke_version_fk_Joke_id-- (is implicitly done)
-- alter table user_openid drop constraint user_openid_fk_User_id-- (is implicitly done)
-- alter table tag drop constraint tag_fk_Joke_id-- (is implicitly done)
-- alter table vote drop constraint vote_fk_Joke_id-- (is implicitly done)
-- alter table browser drop constraint browser_fk_Useragent_id-- (is implicitly done)
-- alter table change drop constraint change_fk_User_id-- (is implicitly done)
-- alter table joke_version drop constraint joke_version_fk_User_id-- (is implicitly done)
-- alter table user_role drop constraint user_role_fk_User_id-- (is implicitly done)
-- alter table user_role drop constraint user_role_fk_Role_id-- (is implicitly done)


-- Generated Permissions Drops
-- --------------------------------------------------------------------




-- Generated SQL View Drop Statements
-- --------------------------------------------------------------------

drop view joke_current cascade ;


-- Generated SQL Schema Drop statements
-- --------------------------------------------------------------------

drop table joke cascade ;
drop table joke_version cascade ;
drop table redirect cascade ;
drop table useragent cascade ;
drop table users cascade ;
drop table browser cascade ;
drop table user_openid cascade ;
drop table vote cascade ;
drop table tag cascade ;
drop table change cascade ;
drop table change_vote cascade ;
drop table session cascade ;
drop table user_role cascade ;
drop table role cascade ;
drop table visit cascade ;
drop table search cascade ;
drop table profanity cascade ;


-- Generated SQL Schema
-- --------------------------------------------------------------------


-- joke
create table joke (
  id                        serial not null,
  version                   smallint default 1,
  link                      character varying(64),
  for_day                   date,
  changed                   timestamp default now(),
  deleted                   boolean default false,
  constraint pk_Joke primary key (id)
) ;

-- joke_version
create table joke_version (
  joke_id                   integer not null,
  version                   smallint default 1 not null,
  text                      text,
  title                     character varying(64),
  comment                   character varying(255),
  created                   timestamp default now(),
  parent_version            integer,
  user_id                   integer,
  browser_id                integer,
  rating                    real default 0 not null,
  voted                     integer default 0 not null,
  visited                   integer default 0 not null,
  old_rating                real,
  old_voted                 integer,
  old_visited               integer,
  last_visit                date,
  banned                    boolean default false,
  constraint pk_Joke_version primary key (joke_id,version)
) ;

-- redirect
create table redirect (
  old_link                  character varying(64) not null,
  new_link                  character varying(64) not null,
  created                   date default now(),
  last_used                 date,
  constraint pk_Redirect primary key (old_link)
) ;

-- useragent
create table useragent (
  id                        serial not null,
  name                      character varying(255),
  constraint pk_Useragent primary key (id)
) ;

-- users
create table users (
  id                        serial not null,
  name                      character varying(64),
  email                     character varying(255),
  password                  character varying(255),
  birth                     date,
  gender                    character varying(6),
  country                   character varying(64),
  karma                     real,
  deleted                   boolean default false,
  comment                   text default '',
  created                   timestamp default now(),
  last_login                date,
  constraint pk_Users primary key (id)
) ;

-- browser
create table browser (
  id                        serial not null,
  session_id                integer not null,
  ip                        inet,
  useragent_id              integer,
  constraint pk_Browser primary key (id)
) ;

-- user_openid
create table user_openid (
  identifier                varchar(255) not null,
  user_id                   integer not null,
  created                   timestamp default now(),
  constraint pk_User_openid primary key (identifier)
) ;

-- vote
-- Historic table, but keep jokes rated with 5 for a loger time so we
-- can show similar tastes
create table vote (
  joke_id                   integer not null,
  version                   smallint not null,
  user_id                   integer,
  browser_id                integer not null,
  date                      date default now(),
  rating                    smallint not null
) ;

-- tag
create table tag (
  joke_id                   integer not null,
  user_id                   integer,
  tag                       varchar(32) not null
) ;

-- change
create table change (
  joke_id                   integer not null,
  type                      varchar(8),
  to_version                smallint,
  from_version              smallint,
  from_joke_id              integer,
  user_id                   integer not null,
  browser_id                integer,
  rating                    smallint default 0 not null,
  proposed                  timestamp default now(),
  approved                  timestamp,
  rejected                  timestamp,
  verified                  timestamp,
  constraint pk_Change primary key (joke_id,user_id)
) ;

-- change_vote
create table change_vote (
  change_id                 integer not null,
  user_id                   integer not null,
  vote                      smallint,
  time                      timestamp default now(),
  constraint pk_Change_vote primary key (change_id,user_id)
) ;

-- session
create table session (
  id                        serial not null,
  cookie                    character(72) not null,
  data                      text,
  expires                   integer,
  constraint pk_Session primary key (id)
) ;

-- user_role
create table user_role (
  user_id                   integer not null,
  role_id                   integer not null,
  constraint pk_User_role primary key (user_id,role_id)
) ;

-- role
create table role (
  id                        integer not null,
  role                      character varying(16) not null,
  constraint pk_Role primary key (id)
) ;

-- visit
create table visit (
  joke_id                   integer not null,
  user_id                   integer not null,
  date                      date default now(),
  constraint pk_Visit primary key (joke_id,user_id)
) ;

-- search
create table search (
  keywords                  character varying(255) not null,
  times                     integer default 1,
  last                      date,
  constraint pk_Search primary key (keywords)
) ;

-- profanity
create table profanity (
  word                      varchar(255) not null,
  created                   timestamp default now(),
  constraint pk_Profanity primary key (word)
) ;







comment on table vote is 'Historic table, but keep jokes rated with 5 for a loger time so we can show similar tastes';












-- Generated SQL Views
-- --------------------------------------------------------------------


-- joke_current
create view joke_current as
  select joke.*, version.text, version.title, version.comment, version.created, version.parent_version, version.user_id, version.browser_id, version.rating, version.voted, version.visited, version.last_visit, version.banned
  from joke,
    joke_version version
  where (joke.id = version.joke_id and joke.version = version.version)
    and (not joke.deleted)
    and (not version.banned)
;



-- Generated Permissions
-- --------------------------------------------------------------------



-- Generated SQL Insert statements
-- --------------------------------------------------------------------


-- inserts for users (id, name, email, password, birth, karma, comment)
insert into users (id, name, email, password, birth, karma, comment) values ( 1, 'Bula', 'bula@bancuri.com', 'killME', '19810514', 666, 'adica eu ...' ) ;

-- inserts for role (id, role)
insert into role (id, role) values ( 1, 'admin' ) ;
insert into role (id, role) values ( 2, 'moderator' ) ;

-- inserts for user_role (user_id, role_id)
insert into user_role (user_id, role_id) values ( 1, 1 ) ;
insert into user_role (user_id, role_id) values ( 1, 2 ) ;

-- inserts for user_openid (user_id, identifier)
insert into user_openid (user_id, identifier) values ( 1, 'http://stirbu.name/' ) ;


-- Generated SQL Constraints
-- --------------------------------------------------------------------

create unique index idx_joke_link on joke  (link) ;
create unique index idx_joke_for_day on joke  (for_day) ;
create index idx_joke_version_rating on joke_version  (rating) ;
create unique index idx_users_email on users  (email) ;
create index idx_user_openid_user_id on user_openid  (user_id) ;
create index idx_tag_tag on tag  (tag) ;
create unique index idx_session_cookie on session  (cookie) ;
alter table joke_version add constraint joke_version_fk_Joke_id
  foreign key (joke_id)
  references joke (id)  ;
alter table user_openid add constraint user_openid_fk_User_id
  foreign key (user_id)
  references users (id)  ;
alter table tag add constraint tag_fk_Joke_id
  foreign key (joke_id)
  references joke (id)  ;
alter table vote add constraint vote_fk_Joke_id
  foreign key (joke_id,version)
  references joke_version (joke_id,version)  ;
alter table browser add constraint browser_fk_Useragent_id
  foreign key (useragent_id)
  references useragent (id)  ;
alter table change add constraint change_fk_User_id
  foreign key (user_id)
  references users (id)  ;
alter table joke_version add constraint joke_version_fk_User_id
  foreign key (user_id)
  references users (id)  ;
alter table user_role add constraint user_role_fk_User_id
  foreign key (user_id)
  references users (id)  ;
alter table user_role add constraint user_role_fk_Role_id
  foreign key (role_id)
  references role (id)  ;

