use taobao;
desc user_behavior;
select * from user_behavior limit 5;

-- Rename column
alter table user_behavior change timestamp timestamps int(14);
desc user_behavior;

-- Check for missing values
select * from user_behavior where user_id is null;
select * from user_behavior where item_id is null;
select * from user_behavior where category_id is null;
select * from user_behavior where behavior_type is null;
select * from user_behavior where timestamps is null;

-- Check for duplicate values
select user_id,item_id,timestamps from user_behavior
group by user_id,item_id,timestamps
having count(*)>1;

-- Remove duplicates
alter table user_behavior add id int first;
select * from user_behavior limit 5;

alter table user_behavior modify id int primary key auto_increment;

SET SQL_SAFE_UPDATES = 0;

delete user_behavior from
user_behavior,
(
select user_id,item_id,timestamps,min(id) id from user_behavior
group by user_id,item_id,timestamps
having count(*)>1
) t2
where user_behavior.user_id=t2.user_id
and user_behavior.item_id=t2.item_id
and user_behavior.timestamps=t2.timestamps
and user_behavior.id>t2.id;

-- add date： date time hour
-- change buffer value
show VARIABLES like '%_buffer%';

SHOW VARIABLES LIKE 'innodb_buffer_pool_size';


SET GLOBAL innodb_buffer_pool_size = 4000000000;