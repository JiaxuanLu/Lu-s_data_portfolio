use taobao;

create view user_behavior_view as
select user_id,item_id
,count(if(behavior_type='pv',behavior_type,null)) 'pv'
,count(if(behavior_type='fav',behavior_type,null)) 'fav'
,count(if(behavior_type='cart',behavior_type,null)) 'cart'
,count(if(behavior_type='buy',behavior_type,null)) 'buy'
from temp_behavior
group by user_id,item_id;

-- 用户行为标准化  
create view user_behavior_standard as
select user_id
,item_id
,(case when pv>0 then 1 else 0 end) 浏览了
,(case when fav>0 then 1 else 0 end) 收藏了
,(case when cart>0 then 1 else 0 end) 加购了
,(case when buy>0 then 1 else 0 end) 购买了
from user_behavior_view;

-- 路径类型 
create view user_behavior_path as
select *,
concat(浏览了,收藏了,加购了,购买了) 购买路径类型
from user_behavior_standard as a
where a.购买了>0;

-- 统计各类购买行为数量 
create view path_count as
select 购买路径类型
,count(*) 数量
from user_behavior_path
group by 购买路径类型
order by 数量 desc;

-- 给不同路径加上描述
create table renhua(
path_type char(4),
description varchar(40));

insert into renhua 
values('0001','直接购买了'),
('1001','浏览后购买了'),
('0011','加购后购买了'),
('1011','浏览加购后购买了'),
('0101','收藏后购买了'),
('1101','浏览收藏后购买了'),
('0111','收藏加购后购买了'),
('1111','浏览收藏加购后购买了');

select * from renhua;

select * from path_count p 
join renhua r 
on p.购买路径类型=r.path_type 
order by 数量 desc;

-- 存储 
create table path_result(
path_type char(4),
description varchar(40),
num int);

-- 把前面创建的view全部删掉。
drop view user_behavior_view;
drop view user_behavior_standard;
drop view user_behavior_path;
drop view path_count;

-- 从这里开始的后面都是和前面一模一样的，但是用的表不同，前面用的都是temp_behavior
-- 里面的数据，但是从下面开始，用的都是user_behavior里面的数据。
create view user_behavior_view as
select user_id,item_id
,count(if(behavior_type='pv',behavior_type,null)) 'pv'
,count(if(behavior_type='fav',behavior_type,null)) 'fav'
,count(if(behavior_type='cart',behavior_type,null)) 'cart'
,count(if(behavior_type='buy',behavior_type,null)) 'buy'
from user_behavior
group by user_id,item_id;



-- 用户行为标准化  
create view user_behavior_standard as
select user_id
,item_id
,(case when pv>0 then 1 else 0 end) 浏览了
,(case when fav>0 then 1 else 0 end) 收藏了
,(case when cart>0 then 1 else 0 end) 加购了
,(case when buy>0 then 1 else 0 end) 购买了
from user_behavior_view;

-- 路径类型 

create view user_behavior_path as
select *,
concat(浏览了,收藏了,加购了,购买了) 购买路径类型
from user_behavior_standard as a
where a.购买了>0;


-- 统计各类购买行为数量 
create view path_count as
select 购买路径类型
,count(*) 数量
from user_behavior_path
group by 购买路径类型
order by 数量 desc;

insert into path_result
select path_type,description,数量 from
path_count p 
join renhua r 
on p.购买路径类型=r.path_type 
order by 数量 desc;

select * from path_result;

-- 首先我们先计算浏览后直接购买的人数，我算出的结果是19712
select sum(buy)
from user_behavior_view
where buy>0 and fav=0 and cart=0;

-- 在上一个代码里面，我们算出来了总购买量，用总购买量减掉前面这个直接浏览后就购买的量之后，
-- 就是收藏加购之后的购买量了。也就是：19762-19712 = 50
-- 之前计算的收藏加购率是：(28651+54909)/887220
-- 所以现在的收藏加购率是：50/(28651+54909)