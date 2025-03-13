use taobao;

-- 最近购买时间，
select user_id
,max(dates) '最近购买时间'
from temp_behavior
where behavior_type='buy'
group by user_id
order by 2 desc;

-- 购买次数 
select user_id
,count(user_id) '购买次数'
from temp_behavior
where behavior_type='buy'
group by user_id
order by 2 desc;

-- 统一
-- 就是把上面的两条写成一条
select user_id
,count(user_id) '购买次数'
,max(dates) '最近购买时间'
from user_behavior
where behavior_type='buy'
group by user_id
order by 2 desc,3 desc;

-- 存储
-- 创建一个新的表以备使用
drop table if exists rfm_model;
create table rfm_model(
user_id int,
frequency int,
recent char(10)
);

-- 将前面做出来的结果插入上面新创建出来的rfm_model表中
insert into rfm_model
select user_id
,count(user_id) '购买次数'
,max(dates) '最近购买时间'
from user_behavior
where behavior_type='buy'
group by user_id
order by 2 desc,3 desc;

-- 根据购买次数对用户进行分层
-- 这一块是根据购买次数对用户进行打分，也就是所谓的分层。下面这一步是先给rfm_model表增加一个名为fscore的列
alter table rfm_model add column fscore int;

-- 如果直接运行下面的update rfm_model代码的话，会出现我的老朋友1175报错，所以需要这行代码先运行一下，来避免这个报错。
SET SQL_SAFE_UPDATES = 0;

-- 这一步就是“根据购买次数对用户进行打分”的具体操作
-- F（Frequency，购买频率），这步是计算F值
update rfm_model
set fscore = case
when frequency between 100 and 262 then 5
when frequency between 50 and 99 then 4
when frequency between 20 and 49 then 3
when frequency between 5 and 20 then 2
else 1
end;

-- 根据最近购买时间对用户进行分层（打分）
-- R（Recency，最近一次购买时间），这步是计算R值
alter table rfm_model add column rscore int;

update rfm_model
set rscore = case
when recent = '2017-12-03' then 5
when recent in ('2017-12-01','2017-12-02') then 4
when recent in ('2017-11-29','2017-11-30') then 3
when recent in ('2017-11-27','2017-11-28') then 2
else 1
end;

-- 因为在这个case当中，我们只能计算R值和F值两个指标，所以上面就是完成了。下面就是把它俩合并一下
select * from rfm_model;

-- 分层
-- 计算 rfm_model 表中 fscore 和 rscore 字段的平均值，并将结果存储在变量 @f_avg 和 @r_avg 中。
set @f_avg=null;
set @r_avg=null;
select avg(fscore) into @f_avg from rfm_model;
select avg(rscore) into @r_avg from rfm_model;

-- 按照R值和F值可以把客户分为四种，所以这里就是给四种客户加上标签。
select *
,(case
when fscore>@f_avg and rscore>@r_avg then '价值用户'
when fscore>@f_avg and rscore<@r_avg then '保持用户'
when fscore<@f_avg and rscore>@r_avg then '发展用户'
when fscore<@f_avg and rscore<@r_avg then '挽留用户'
end) class
from rfm_model;

-- 插入
-- 将上面的结果插入表中。
alter table rfm_model add column class varchar(40);
update rfm_model
set class = case
when fscore>@f_avg and rscore>@r_avg then '价值用户'
when fscore>@f_avg and rscore<@r_avg then '保持用户'
when fscore<@f_avg and rscore>@r_avg then '发展用户'
when fscore<@f_avg and rscore<@r_avg then '挽留用户'
end;


-- 统计各分区用户数
select class,count(user_id) from rfm_model
group by class;