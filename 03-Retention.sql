use taobao;

select * from user_behavior where dates is null;
set sql_safe_updates = 0;
delete from user_behavior where dates is null;

-- 首先计算用户活跃了哪些天。
select user_id,dates 
from temp_behavior
group by user_id,dates;

-- 根据两次活跃的日期相减，为了让统一用户的各种活跃日期能两两匹配，用Self Join的方法来实现。
select * from 
(select user_id,dates 
from temp_behavior
group by user_id,dates
) a
,(select user_id,dates 
from temp_behavior
group by user_id,dates
) b
where a.user_id=b.user_id;

-- 筛选，要让第二个date的日期比第一个要大，就是把相隔两天的日期互相匹配起来，例如把1号和2号匹配起来。
select * from 
(select user_id,dates 
from temp_behavior
group by user_id,dates
) a
,(select user_id,dates 
from temp_behavior
group by user_id,dates
) b
where a.user_id=b.user_id and a.dates<b.dates;

-- 留存数 ，下面这串代码当中，日期差为0是当天，为1是次日，3是三日。
select a.dates
,count(if(datediff(b.dates,a.dates)=0,b.user_id,null)) retention_0
,count(if(datediff(b.dates,a.dates)=1,b.user_id,null)) retention_1
,count(if(datediff(b.dates,a.dates)=3,b.user_id,null)) retention_3 from

(select user_id,dates 
from temp_behavior
group by user_id,dates
) a
,(select user_id,dates 
from temp_behavior
group by user_id,dates
) b
where a.user_id=b.user_id and a.dates<=b.dates
group by a.dates;

-- 留存率，这里没有上面的三日或者当天的，直接计算的是次日用户留存率。
select a.dates
,count(if(datediff(b.dates,a.dates)=1,b.user_id,null))/count(if(datediff(b.dates,a.dates)=0,b.user_id,null)) retention_1
from
(select user_id,dates 
from temp_behavior
group by user_id,dates
) a
,(select user_id,dates 
from temp_behavior
group by user_id,dates
) b
where a.user_id=b.user_id and a.dates<=b.dates
group by a.dates;

-- 上面的代码就已经做出来最终的用户留存率了，这一步只是创建一个新表来保存结果 
create table retention_rate (
dates char(10),
retention_1 float 
);

-- 这段SQL代码的作用是计算次日用户留存率，并将结果插入到 retention_rate 表中。
insert into retention_rate 
select a.dates
,count(if(datediff(b.dates,a.dates)=1,b.user_id,null))/count(if(datediff(b.dates,a.dates)=0,b.user_id,null)) retention_1
from
(select user_id,dates 
from user_behavior
group by user_id,dates
) a
,(select user_id,dates 
from user_behavior
group by user_id,dates
) b
where a.user_id=b.user_id and a.dates<=b.dates
group by a.dates;

select * from retention_rate;

-- 跳失的意思是，用户只是登录了一下，然后就杳无音讯了。
-- 跳失率=只点击一次用户的数量/总的用户浏览量
-- 下面这段代码用以计算跳失用户  -- 88
select count(*) 
from 
(
select user_id from user_behavior
group by user_id
having count(behavior_type)=1
) a;
-- 274607

select sum(pv) from pv_uv_puv;
-- 887220
-- 原先我以为这里搞错了，因为原up主的结果是：88/89660670，但是我突然想起来，我这个是从
-- 一亿数据当中提取了100万数据来跑的结果，所以肯定会有误差，所以我的跳失用户肯定是大于88的
-- 反正我主要是学一下思路，结果不重要。