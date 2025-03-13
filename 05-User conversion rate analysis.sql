use taobao;

-- 统计各类行为用户数 
select behavior_type
,count(DISTINCT user_id) user_num
from temp_behavior
group by behavior_type
order by behavior_type desc;

-- 存储，这里包含两步，第一步是创建一个新的空表，包括behavior_type和user_num两列。
-- 第二步是把原表中的内容插进新表。
create table behavior_user_num(
behavior_type varchar(5),
user_num int);

insert into behavior_user_num
select behavior_type
,count(DISTINCT user_id) user_num
from user_behavior
group by behavior_type
order by behavior_type desc;

select * from behavior_user_num;

-- 然后对上面表格中的数据进行简单的分析，用购买的人数/浏览的人数
select 19292/490724;

-- 统计各类行为的数量 
-- 注意这一步与第一步的不同之处，这一步是计算各类行为的数量，但是第一步是计算各类行为的用户数
-- 所以这一步是没有去重，但是第一步去重了。
-- 在前面的时候，我一直困惑于为什么先用temp_behavior表运行代码，
-- 后面我想明白了，因为这是之前创建的包含十万条数据的一个demo，就是用来提前看一下数据。
select behavior_type
,count(*) user_num
from temp_behavior
group by behavior_type
order by behavior_type desc;

-- 存储 
create table behavior_num(
behavior_type varchar(5),
behavior_count_num int);

insert into behavior_num
select behavior_type
,count(*) behavior_count_num
from user_behavior
group by behavior_type
order by behavior_type desc;

select * from behavior_num;

select 19762/887220; -- 0.0223，这是购买率

select (28651+54909)/887220 -- 这是收藏加购率