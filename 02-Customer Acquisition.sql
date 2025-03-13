use taobao;

-- 创建临时表 
create table temp_behavior like user_behavior;

-- 截取 
insert into temp_behavior
select * from user_behavior limit 100000;

select * from temp_behavior;

-- pv 
select dates, count(*) 'pv'
from temp_behavior
where behavior_type='pv'
GROUP BY dates;

-- uv 
select dates, count(distinct user_id) 'pv'
from temp_behavior
where behavior_type='pv' and dates is not null
GROUP BY dates;

-- 一条语句，这句直接替代了上面的uv和pv语句，直接计算出来浏览深度=pv/uv
select dates
,count(*) 'pv'
,count(distinct user_id) 'uv'
,round(count(*)/count(distinct user_id),1) 'pv/uv'
from temp_behavior
where behavior_type='pv'
GROUP BY dates;

-- 处理真实数据，目的是，创建一个新的表，来存储新的数据。
create table pv_uv_puv (dates char(10), pv int, uv int, puv decimal(10,1));

-- 将处理好的数据插入表格当中
insert into pv_uv_puv
select dates
,count(*) 'pv'
,count(distinct user_id) 'uv'
,round(count(*)/count(distinct user_id),1) 'pv/uv'
from user_behavior
where behavior_type='pv'
GROUP BY dates;

select * from pv_uv_puv;

delete from pv_uv_puv where dates is null;
