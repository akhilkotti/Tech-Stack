------------------------------------------
--Below query is grouped by time and order
------------------------------------------
select convert(varchar,dateadd(minute,(datediff(minute,0,dCurrentTime)/30)*30,0),108) "Time",
nTradedOrderNumber "Order Number",
avg(cast(nQuantityTraded as money)) "Avg fills",
count(nQuantityTraded) "Cum fills"
from tbl_LogTrades 
where convert(varchar,dCurrentTime,112) between '20080623' and '20080623' 
group by convert(varchar,dateadd(minute,(datediff(minute,0,dCurrentTime)/30)*30,0),108),nTradedOrderNumber
order by convert(varchar,dateadd(minute,(datediff(minute,0,dCurrentTime)/30)*30,0),108)

------------------------------------------
--Below query is grouped by time and stock
------------------------------------------
select convert(varchar,dateadd(minute,(datediff(minute,0,dCurrentTime)/30)*30,0),108) "Time",
sSymbol "Stock",
avg(cast(nQuantityTraded as money)) "Avg fills",
count(nQuantityTraded) "Cum fills"
from tbl_LogTrades 
where convert(varchar,dCurrentTime,112) between '20080623' and '20080623' 
group by convert(varchar,dateadd(minute,(datediff(minute,0,dCurrentTime)/30)*30,0),108),sSymbol
order by convert(varchar,dateadd(minute,(datediff(minute,0,dCurrentTime)/30)*30,0),108)