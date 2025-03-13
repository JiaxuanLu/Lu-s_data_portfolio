use taobao;

-- 特定商品转化率
select item_id
,count(if(behavior_type='pv',behavior_type,null)) 'pv'
,count(if(behavior_type='fav',behavior_type,null)) 'fav'
,count(if(behavior_type='cart',behavior_type,null)) 'cart'
,count(if(behavior_type='buy',behavior_type,null)) 'buy'
,count(distinct if(behavior_type='buy',user_id,null))/count(distinct user_id) 商品转化率
from temp_behavior
group by item_id
order by 商品转化率 desc;

-- 保存 
create table item_detail(
item_id int,
pv int,
fav int,
cart int,
buy int,
user_buy_rate float);

insert into item_detail
select item_id
,count(if(behavior_type='pv',behavior_type,null)) 'pv'
,count(if(behavior_type='fav',behavior_type,null)) 'fav'
,count(if(behavior_type='cart',behavior_type,null)) 'cart'
,count(if(behavior_type='buy',behavior_type,null)) 'buy'
,count(distinct if(behavior_type='buy',user_id,null))/count(distinct user_id) 商品转化率
from user_behavior
group by item_id
order by 商品转化率 desc;

select * from item_detail;

-- 品类转化率 

create table category_detail(
category_id int,
pv int,
fav int,
cart int,
buy int,
user_buy_rate float);

insert into category_detail
select category_id
,count(if(behavior_type='pv',behavior_type,null)) 'pv'
,count(if(behavior_type='fav',behavior_type,null)) 'fav'
,count(if(behavior_type='cart',behavior_type,null)) 'cart'
,count(if(behavior_type='buy',behavior_type,null)) 'buy'
,count(distinct if(behavior_type='buy',user_id,null))/count(distinct user_id) 品类转化率
from user_behavior
group by category_id
order by 品类转化率 desc;

select * from category_detail;
