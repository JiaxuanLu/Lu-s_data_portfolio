use taobao;

-- 统计商品的热门品类、热门商品、热门品类热门商品
-- 求pv最大的品类，pv是浏览量，计算出品类浏览量
select category_id
,count(if(behavior_type='pv',behavior_type,null)) '品类浏览量'
from temp_behavior
GROUP BY category_id
order by 2 desc
limit 10;

-- 计算出商品浏览量
select item_id
,count(if(behavior_type='pv',behavior_type,null)) '商品浏览量'
from temp_behavior
GROUP BY item_id
order by 2 desc
limit 10;

-- 用窗口函数给各类别最热门商品按照浏览量进行排序。代码使用了窗口函数 RANK() 和条件过滤来完成这个任务。
-- 这段代码得到的是品类商品浏览量中浏览量前十的。
-- 这段代码不是很好理解，我是在chatGPT的辅助下才理解了。
select category_id,item_id,
品类商品浏览量 from
(
select category_id,item_id
,count(if(behavior_type='pv',behavior_type,null)) '品类商品浏览量'
-- ,rank()over(partition by category_id order by '品类商品浏览量' desc) r
-- 纠错，'品类商品浏览量'这里不能指代count(if(behavior_type='pv',behavior_type,null))因为还没返回
,rank()over(partition by category_id order by count(if(behavior_type='pv',behavior_type,null)) desc) r
from temp_behavior
GROUP BY category_id,item_id
order by 3 desc
) a
where a.r = 1
order by a.品类商品浏览量 desc
limit 10;

-- 为三个类别创建三个表，以备后面的存储。
create table popular_categories(
category_id int,
pv int);
create table popular_items(
item_id int,
pv int);
create table popular_cateitems(
category_id int,
item_id int,
pv int);

-- 下面三段代码分别是把品类浏览量、商品浏览量和品类商品浏览量分别存储到前面创建的三个表当中去。
insert into popular_categories
select category_id
,count(if(behavior_type='pv',behavior_type,null)) '品类浏览量'
from user_behavior
GROUP BY category_id
order by 2 desc
limit 10;


insert into popular_items
select item_id
,count(if(behavior_type='pv',behavior_type,null)) '商品浏览量'
from user_behavior
GROUP BY item_id
order by 2 desc
limit 10;

insert into popular_cateitems
select category_id,item_id,
品类商品浏览量 from
(
select category_id,item_id
,count(if(behavior_type='pv',behavior_type,null)) '品类商品浏览量'
,rank()over(partition by category_id order by '品类商品浏览量' desc) r
from user_behavior
GROUP BY category_id,item_id
order by 3 desc
) a
where a.r = 1
order by a.品类商品浏览量 desc
limit 10;

select * from popular_categories;
select * from popular_items;
select * from popular_cateitems;
