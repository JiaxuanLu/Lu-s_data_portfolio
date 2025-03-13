use taobao;
desc user_behavior;
select * from user_behavior limit 5;

-- The following code are used to randomly delete data and keep the following 1000000 data
-- Step 1: Create a temporary table to keep the data
CREATE TEMPORARY TABLE keep_data AS
SELECT id
FROM user_behavior
ORDER BY RAND()
LIMIT 1000000;

-- In step 2, I always receive the error called 1175, so I use the following code to forbid safe mode
SET SQL_SAFE_UPDATES = 0;

-- Step 2: Delete records from the original table that are not in the temporary table
DELETE FROM user_behavior
WHERE id NOT IN (SELECT id FROM keep_data);

-- use this code to check the number of my keeped data
SELECT COUNT(*) FROM keep_data;

-- Step 3: Drop the temporary table
DROP TEMPORARY TABLE keep_data;

-- the Rename column step has been done, so this is Check for missing values
-- Check for missing values
select * from user_behavior where user_id is null;
select * from user_behavior where item_id is null;
select * from user_behavior where category_id is null;
select * from user_behavior where behavior_type is null;
select * from user_behavior where timestamps is null;

-- Check for duplicate values. This step has done in previous code, so the result will show nothing.
-- so there's no need to write the code which is used to remove duplicates
select user_id,item_id,timestamps from user_behavior
group by user_id,item_id,timestamps
having count(*)>1;

-- add date： date time hour
-- change buffer value
show VARIABLES like '%_buffer%';
SHOW VARIABLES LIKE 'innodb_buffer_pool_size';
SET GLOBAL innodb_buffer_pool_size = 805306368;

-- datetime
alter table user_behavior add datetimes TIMESTAMP(0);
update user_behavior set datetimes=FROM_UNIXTIME(timestamps);
select * from user_behavior limit 5;
-- date
alter table user_behavior add dates char(10);
alter table user_behavior add times char(8);
alter table user_behavior add hours char(2);
-- update user_behavior set dates=substring(datetimes,1,10),times=substring(datetimes,12,8),hours=substring(datetimes,12,2);
update user_behavior set dates=substring(datetimes,1,10);
update user_behavior set times=substring(datetimes,12,8);
update user_behavior set hours=substring(datetimes,12,2);
select * from user_behavior limit 5;

-- 去异常 
select max(datetimes),min(datetimes) from user_behavior;
delete from user_behavior
where datetimes < '2017-11-25 00:00:00'
or datetimes > '2017-12-03 23:59:59';

-- 数据概览 
desc user_behavior;
select * from user_behavior limit 5;
SELECT count(1) from user_behavior; -- 990544条记录