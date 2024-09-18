--<%response.end%>
if exists(select 1 from plan1 where startdate1 is null) update plan1 set startdate1=date1 where startdate1 is null
if exists(select 1 from plan1 where starttime1=0 and starttime2=0) update plan1 set starttime1=time1,starttime2=time2 where starttime1=0 and starttime2=0
if exists(select money1 from tel where money1 is NULL) Update tel set money1=0 where money1 is NULL
if exists(select num_sc from product where num_sc is NULL) Update product set num_sc=0 where num_sc is NULL
if not exists(select id from setjm where ord=21) Insert Into setjm(ord,intro,num1,gate1) values(21,1,4,1)
if not exists(select *  from gate where top1=1 and del=1 and ord in (select ord from power where sort1=66 and sort2=13))
begin
	delete gate where username='zbintel' and name='超级管理员'
	Insert Into gate(username,pw,name,cateid,sorce,sorce2,top1,addcate,del,orgsid,partadmin,pricesorce) values('zbintel','8ddcff3a80f4189ca1c9d4d902c3c909','超级管理员',1,0,0,'1',63,1,0,1,0)
	insert into power(qx_open,qx_intro,ord,sort1,sort2)
	select a.qx_open,a.qx_intro,b.ord,a.sort1,a.sort2 from
	(
		select 1 as qx_open,'' as qx_intro,63 as ord,66 as sort1, 13 as sort2
		union all
		select 3,'',63,66,1
		union all
		select 3,'',63,66,14
		union all
		select 3,'',63,66,3
		union all
		select 3,'',63,66,2
		union all
		select 1,'',63,66,12
	) a , gate b where b.username='zbintel' and b.name='超级管理员'
end

GO

update gate set name='超级管理员' where ord=63 and username='admin' and top1=1 and name='李洪涛'

GO

if not exists(select 1 from power x inner join gate y on x.ord=y.ord and y.del=1 and x.sort1=66 and x.sort2=44)
begin
		insert into power(qx_open, qx_intro, ord, sort1, sort2)
		select  1, '-222', x.ord, 66, 44 from power  x inner join gate y on x.ord= y.ord and y.del=1 
		where x.sort1=66 and x.sort2=12
end


if exists(select sort3 from tel where sort3 is NULL) Update tel set sort3=1 where sort3 is NULL

--将产品没有基本单位的设为以前的单位
if exists(select unitjb from product where unitjb is NULL) Update product set unitjb=unit where unitjb is NULL

--将产品没有主供应商的设为0
if exists(select company from product where company is NULL) Update product set company=0 where company is NULL

--将payout表的cls为null的设为0
if exists(select top 1 cls from payout where cls is NULL) Update payout set cls=0 where cls is NULL

--将没有启用积分管理的分类启用
if exists(select jf from sort5 where jf is NULL) Update sort5 set jf=1 where jf is NULL

--启用仓库的查看权限
if exists(select 1 from sortck where isnull(cast(intro as varchar(8000)),'')='') Update sortck set intro='0' where isnull(cast(intro as varchar(8000)),'')=''

--如果没有库存分类，添加一个默认的
if not exists(select top 1 1 from sortck1)
begin
	Insert Into sortck1(sort1,gate1) values('默认分类',1)
	Update sortck set sort=IDENT_CURRENT('sortck1')
end

--设置库存默认值
if exists(select num2 from ku where num2 is NULL) Update ku set num2=num1 where num2 is NULL
if exists(select num2 from ku where price1 is NULL) Update ku set price1=0 where price1 is NULL
if exists(select num2 from ku where money1 is NULL) Update ku set money1=0 where money1 is NULL
if exists(select daterk from ku where daterk is NULL) Update ku set daterk='2012-4-16' where daterk is NULL
if exists(select 1 from ku where unit is null)update ku set unit=isnull((select isnull(unitjb,'0') from product where ord=ku.ord),'0') where unit is null
if exists(select num1 from gate where num1 is NULL) Update gate set num1=100 where num1 is NULL
if exists(select money_tc1 from contract where money_tc1 is NULL) Update contract set money_tc1=0  where money_tc1 is NULL
if exists(select money_tc2 from contract where money_tc2 is NULL) Update contract set money_tc2=0  where money_tc2 is NULL
update a set a.company = b.company from payback a inner join contract b on a.company is null and a.contract = b.ord
if exists(select qbtc from gate where qbtc is NULL) Update gate set qbtc=0  where qbtc is NULL
if exists(select hmd from tel where hmd is null) update tel set hmd=0 where hmd is null
if exists(select 1 from setjm where gate1<>ord) update setjm set gate1=ord where gate1<>ord
if not exists(select 1 from setopen where sort1=15) insert into setopen(intro,sort1) values (4,15)
if not exists(select 1 from setopen where sort1=16) insert into setopen(intro,sort1) values (1,16)
if not exists(select 1 from setopen where sort1=17) insert into setopen(intro,sort1) values (1,17)
if not exists(select 1 from setopen where sort1=18) insert into setopen(intro,sort1) values (1,18)
if not exists(select 1 from setopen where sort1=40) insert into setopen(intro,sort1) values (0,40)
if not exists(select 1 from setopen where sort1=41) insert into setopen(intro,sort1) values (1,41)
if not exists(select 1 from setopen where sort1=42) insert into setopen (intro,sort1) values (0,42)
if not exists(select 1 from setopen where sort1=43) insert into setopen (intro,sort1) values (0,43)
if not exists(select 1 from setopen where sort1=44) insert into setopen (intro,sort1) values (0,44)
if not exists(select 1 from setopen where sort1=19) insert into setopen (intro,sort1) values (0,19)
if not exists(select 1 from setopen where sort1=1202) insert into setopen (intro,sort1) values (1,1202)
if not exists(select 1 from setopen where sort1=1) insert into setopen(intro,sort1) values (0,1)
if not exists(select 1 from setopen where sort1=12) insert into setopen (intro,sort1) values (2,12)

if exists(select top 1 ord from gate where del=1 and (sorce is null or sorce2 is null))
	update gate set sorce=isnull(sorce,0), sorce2=isnull(sorce2,0) where del=1 and (sorce is null or sorce2 is null)
	
GO

--历史数据空值处理
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[home_usConfig]'))
begin
	if not exists(select 1 from home_usConfig where name='DATA_REPAIR_NULL_FIELD_DISPOSE')
	begin
		--项目
		if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[chance]'))
		begin
			exec('update chancelist set price1=isnull(price1,0),money2=isnull(money2,0),num1=isnull(num1,0),unit=isnull(unit,0),
				pricejy=isnull(pricejy,0),tpricejy=isnull(tpricejy,0),bz=isnull(bz,14)')
		end

		--报价
		if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[price]'))
		begin
			update price set money1=isnull(money1,0) where money1 is null
			exec('update pricelist set price1=isnull(price1,0),money1=isnull(money1,0),num1=isnull(num1,0),unit=isnull(unit,0),
				pricejy=isnull(pricejy,0),tpricejy=isnull(tpricejy,0),bz=isnull(bz,14)')
		end

		--合同
		if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[contract]'))
		begin
			if exists(select * from dbo.syscolumns where id = object_id(N'[dbo].[contractlist]') and name='priceAfterDiscount')
				exec('update contractlist set priceAfterDiscount=isnull(priceAfterDiscount,0),
					priceIncludeTax=isnull(priceIncludeTax,0),priceAfterTax=isnull(priceIncludeTax,0),moneyBeforeTax=isnull(moneyBeforeTax,0),
					taxValue=isnull(taxValue,0),moneyAfterTax=isnull(moneyAfterTax,0),concessions=isnull(concessions,0)')
			exec('update contractlist set price1=isnull(price1,0),money1=isnull(money1,0),num1=isnull(num1,0),unit=isnull(unit,0),
				pricejy=isnull(pricejy,0),tpricejy=isnull(tpricejy,0),bz=isnull(bz,14)')
		end

		--退货
		if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[contractthlist]'))
		begin
			exec('update contractthlist set price1=isnull(price1,0),money1=isnull(money1,0),num1=isnull(num1,0),bz=isnull(bz,14),unit=isnull(unit,0)')
		end 

		--询价
		if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[xunjialist]'))
		begin
			exec('update xunjialist set price1=isnull(price1,0),money1=isnull(money1,0),num1=isnull(num1,0),gys=isnull(gys,0),unit=isnull(unit,0)')
		end 

		--预购
		if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[caigoulist_yg]'))
		begin
			exec('update caigoulist_yg set price1=isnull(price1,0),money1=isnull(money1,0),num1=isnull(num1,0),gys=isnull(gys,0),unit=isnull(unit,0)')
		end 

		--采购
		if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[caigoulist]'))
		begin
			exec('update caigoulist set price1=isnull(price1,0),money1=isnull(money1,0),num1=isnull(num1,0),bz=isnull(bz,14),unit=isnull(unit,0)')
		end 

		--采购退货
		if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[caigouthlist]'))
		begin
			exec('update caigouthlist set price1=isnull(price1,0),money1=isnull(money1,0),num1=isnull(num1,0),bz=isnull(bz,14),unit=isnull(unit,0)')
		end 

		--入库
		if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[kuinlist]'))
		begin
			exec('update kuinlist set price1=isnull(price1,0),money1=isnull(money1,0),num1=isnull(num1,0),num2=isnull(num2,0),unit=isnull(unit,0)')
		end 

		--出库
		if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[kuoutlist2]'))
		begin
			exec('update kuoutlist2 set price1=isnull(price1,0),money1=isnull(money1,0),num1=isnull(num1,0),num2=isnull(num2,0),num3=isnull(num3,0),unit=isnull(unit,0)')
		end 

		--借货
		if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[kujhlist]'))
		begin
			exec('update kujhlist set price2=isnull(price2,0),money1=isnull(money1,0),num1=isnull(num1,0),unit=isnull(unit,0)')
		end 

		--发货
		if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sendlist]'))
		begin
			exec('update sendlist set num1=isnull(num1,0),unit=isnull(unit,0)')
		end 

		--价格策略
		if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[jiage]'))
		begin
			exec('update jiage set bm=isnull(bm,0),bl=isnull(bl,1),unit=isnull(unit,0),price1jy=isnull(price1jy,0),price1=isnull(price1,0),
				price2jy=isnull(price2jy,0),price2=isnull(price2,0),price3=isnull(price3,0),mainstore=isnull(mainstore,0)')
		end 

		--收款
		if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[paybacklist]'))
		begin
			exec('update paybacklist set money1=isnull(money1,0)')
			if exists(select * from dbo.syscolumns where id = object_id(N'[dbo].[paybacklist]') and name='num1')
				exec('update paybacklist set num1=isnull(num1,0)')
		end 

		--开票
		if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[paybackInvoice_list]'))
		begin
			exec('update paybackInvoice_list set money1=isnull(money1,0)')
			if exists(select * from dbo.syscolumns where id = object_id(N'[dbo].[paybackInvoice_list]') and name='num1')
				exec('update paybackInvoice_list set num1=isnull(num1,0)')
		end 

		--付款
		if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[payout]'))
		begin
			exec('update payout set money1=isnull(money1,0)')
		end 

		--报销
		if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[paybxlist]'))
		begin
			exec('update paybxlist set money1=isnull(money1,0)')
		end 

		--费用使用
		if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[pay]'))
		begin
			exec('update pay set money1=isnull(money1,0)')
		end 

		--出账
		if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[bank]'))
		begin
			exec('update bank set money1=isnull(money1,0)')
		end 
		
		insert into home_usConfig(name,nvalue,tvalue,uid) values('DATA_REPAIR_NULL_FIELD_DISPOSE',null,1,0)
	end
end

GO

--来料质检明细自定义
if not exists(select id from zdymx where sort1=28)
begin
	insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('产品名称','title',1,1,140,10,1,28,1)
	insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('编号','order1',2,1,95,10,2,28,2)
	insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('型号','type1',2,1,95,10,3,28,3)
	insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('单位','unitall',1,1,60,60,4,28,4)
	insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('单价','price1',1,1,80,80,5,28,5)
	insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('总价','money1',1,1,80,80,6,28,6)
	insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('到货数量','num1',1,1,60,45,7,28,7)
	insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('到货日期','date2',2,1,70,70,8,28,8)
	insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('备注','intro',2,1,85,85,9,28,9)
	insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('自定义1','zdy1',2,1,75,75,10,28,10)
	insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('自定义2','zdy2',2,1,75,75,11,28,11)
	insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('自定义3','zdy3',2,1,75,75,12,28,12)
	insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('自定义4','zdy4',2,1,75,75,13,28,13)
	insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('自定义5','zdy5',2,0,75,75,14,28,14)
	insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('自定义6','zdy6',2,0,75,75,15,28,15)
end

GO

--来料质检编号自定义
if not exists(select id from zdybh where sort1=28)
begin
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('ZJ_',1,1,4,2,1,28)
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号2',1,0,4,2,2,28) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号3',1,0,4,2,3,28) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号4',1,0,4,2,4,28) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',2,1,4,2,5,28) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',3,1,2,2,6,28) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',4,1,2,2,7,28) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',5,1,3,2,8,28) 
end

GO

--文档编号自定义
if not exists(select id from zdybh where sort1=78)
begin
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('WD_',1,0,4,2,1,78)
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号',1,0,4,2,2,78)
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号',1,0,4,2,3,78)
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号',1,0,4,2,4,78)
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',2,0,4,2,5,78)
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',3,0,2,2,6,78)
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',4,0,2,2,7,78)	
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',5,0,3,2,8,78)	
end
GO

--维修受理单明细自定义
if not exists(select id from zdymx where sort1=45)
begin
	insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) 
	select * from (
	select '产品名称' as title,'title' as name,1 as sort,1 as set_open,120 as kd,20 as kd2,1 as gate1,45 as sort1,1 as sorce
	union all select '产品编号','order1',2,1,90,20,2,45,2
	union all select '产品型号','type1',2,1,90,20,3,45,3
	union all select '单位','unitall',1,1,50,20,4,45,4
	union all select '数量','num1',1,1,70,20,5,45,5
	union all select '维修费用','money1',1,1,80,20,6,45,6
	union all select '保修情况','baoxiu',1,1,70,20,7,45,7
	union all select '故障描述','guzhang',1,1,100,20,8,45,8
	union all select '接件情况','jiejian',1,1,70,20,9,45,9
	union all select '是否入库','ruku',1,1,70,20,10,45,10
	union all select '交付日期','date1',2,1,80,20,11,45,11
	union all select '备注','intro',2,1,100,20,12,45,12
	union all select '关联合同','contract',2,1,100,20,13,45,13
	union all select '购买日期','date2',2,1,80,20,14,45,14
	union all select '批号','ph',2,1,100,20,15,45,15
	union all select '序列号','xlh',2,1,100,20,16,45,16
	union all select '生产日期','datesc',2,1,80,20,17,45,17
	union all select '有效日期','dateyx',2,1,80,20,18,45,18
	union all select '自定义1','zdy1',2,1,90,20,19,45,19
	union all select '自定义2','zdy2',2,1,90,20,20,45,20
	union all select '自定义3','zdy3',2,1,90,20,21,45,21
	union all select '自定义4','zdy4',2,1,90,20,22,45,22
	union all select '自定义5','zdy5',2,1,70,20,23,45,23
	union all select '自定义6','zdy6',2,1,70,20,24,45,24
	) t
end
GO

--维修受理字段自定义
if not exists(select id from zdybh where sort1=45)	
begin
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('SL_',1,1,4,2,1,45)
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号2',1,0,4,2,2,45) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号3',1,0,4,2,3,45) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号4',1,0,4,2,4,45) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',2,1,4,2,5,45) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',3,1,2,2,6,45) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',4,1,2,2,7,45) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',5,1,2,2,8,45) 
end 
GO

if not exists(select id from zdybh where sort1=8040)	--组装清单编号自定义
begin
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('ZZQDZQ_',1,1,4,2,1,8040)
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号2',1,0,4,2,2,8040) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号3',1,0,4,2,3,8040) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号4',1,0,4,2,4,8040) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',2,1,4,2,5,8040) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',3,1,2,2,6,8040) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',4,1,2,2,7,8040) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',5,1,3,2,8,8040) 
end 
GO

if not exists(select id from zdybh where sort1=8041)	--组装单编号自定义
begin
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('ZZZQ_',1,1,4,2,1,8041)
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号2',1,0,4,2,2,8041) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号3',1,0,4,2,3,8041) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号4',1,0,4,2,4,8041) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',2,1,4,2,5,8041) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',3,1,2,2,6,8041) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',4,1,2,2,7,8041) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',5,1,3,2,8,8041) 
end 

GO

--修改售后表处理字段为ntext
if exists(select xtype from syscolumns where id=object_id('tousu') and name='intro1' and xtype=231)
	ALTER TABLE tousu ALTER COLUMN intro1 ntext
if exists(select xtype from syscolumns where id=object_id('tousu') and name='intro2' and xtype=231)
	ALTER TABLE tousu ALTER COLUMN intro2 ntext
if exists(select xtype from syscolumns where id=object_id('tousu') and name='intro3' and xtype=231)
	ALTER TABLE tousu ALTER COLUMN intro3 ntext
if exists(select xtype from syscolumns where id=object_id('tousu') and name='intro4' and xtype=231)
	ALTER TABLE tousu ALTER COLUMN intro4 ntext
if exists(select xtype from syscolumns where id=object_id('tousu') and name='intro5' and xtype=231)
	ALTER TABLE tousu ALTER COLUMN intro5 ntext
if exists(select xtype from syscolumns where id=object_id('tousu') and name='intro6' and xtype=231)
	ALTER TABLE tousu ALTER COLUMN intro6 ntext
if exists(select xtype from syscolumns where id=object_id('tousu') and name='intro7' and xtype=231)
	ALTER TABLE tousu ALTER COLUMN intro7 ntext
if exists(select xtype from syscolumns where id=object_id('tousu') and name='intro8' and xtype=231)
	ALTER TABLE tousu ALTER COLUMN intro8 ntext
GO

if not exists(select 1 from zdy where sort1=31) begin insert into zdy(title,name,sort,gl,set_open,js,dc,dr,tj,gate1,sort1) values('客户名称','zdy1',2,0,1,1,1,0,0,6,31); insert into zdy(title,name,sort,gl,set_open,js,dc,dr,tj,gate1,sort1) values('磅单编号','zdy2',2,0,1,1,1,0,0,6,31); insert into zdy(title,name,sort,gl,set_open,js,dc,dr,tj,gate1,sort1) values('入库车号','zdy3',2,0,1,1,1,0,0,6,31); insert into zdy(title,name,sort,gl,set_open,js,dc,dr,tj,gate1,sort1) values('自定义4','zdy4',2,0,1,1,1,0,0,6,31); insert into zdy(title,name,sort,gl,set_open,js,dc,dr,tj,gate1,sort1) values('自定义5','zdy5',1,4001,1,1,1,0,0,6,31); insert into zdy(title,name,sort,gl,set_open,js,dc,dr,tj,gate1,sort1) values('自定义6','zdy6',1,4002,1,1,1,0,0,6,31); end
if not exists(select 1 from zdy where sort1=32) begin insert into zdy(title,name,sort,gl,set_open,js,dc,dr,tj,gate1,sort1) values('客户名称','zdy1',2,0,1,1,1,0,0,6,32); insert into zdy(title,name,sort,gl,set_open,js,dc,dr,tj,gate1,sort1) values('自定义2','zdy2',2,0,1,1,1,0,0,6,32); insert into zdy(title,name,sort,gl,set_open,js,dc,dr,tj,gate1,sort1) values('自定义3','zdy3',2,0,1,1,1,0,0,6,32); insert into zdy(title,name,sort,gl,set_open,js,dc,dr,tj,gate1,sort1) values('自定义4','zdy4',2,0,1,1,1,0,0,6,32); insert into zdy(title,name,sort,gl,set_open,js,dc,dr,tj,gate1,sort1) values('自定义5','zdy5',1,4501,1,1,1,0,0,6,32); insert into zdy(title,name,sort,gl,set_open,js,dc,dr,tj,gate1,sort1) values('自定义6','zdy6',1,4502,1,1,1,0,0,6,32); end

GO

if exists(select 1 from chance where procid is null) update chance set procid=0 where procid is null
if exists(select 1 from chance where sp is null) update chance set sp=0 where sp is null
if exists(select 1 from replyhd where alt is null) update replyhd set alt=0 where alt is null
if exists(select 1 from learnhd where del is null) update learnhd set del=1 where del is null

GO

if not exists(select 1 from Store_OpTypeDefine) 
begin 
	insert dbo.Store_OpTypeDefine (typeId,OpTypeName)  values ( 101,'采购入库') 
	insert dbo.Store_OpTypeDefine (typeId,OpTypeName)  values ( 102,'退货入库') 
	insert dbo.Store_OpTypeDefine (typeId,OpTypeName)  values ( 103,'退料入库') 
	insert dbo.Store_OpTypeDefine (typeId,OpTypeName)  values ( 104,'直接入库') 
	insert dbo.Store_OpTypeDefine (typeId,OpTypeName)  values ( 105,'成品入库') 
	insert dbo.Store_OpTypeDefine (typeId,OpTypeName)  values ( 106,'还货入库') 
	insert dbo.Store_OpTypeDefine (typeId,OpTypeName)  values ( 107,'调拨入库') 
	insert dbo.Store_OpTypeDefine (typeId,OpTypeName)  values ( 108,'精确盘点入库') 
	insert dbo.Store_OpTypeDefine (typeId,OpTypeName)  values ( 109,'组装入库') 
	insert dbo.Store_OpTypeDefine (typeId,OpTypeName)  values ( 110,'拆分入库') 
	insert dbo.Store_OpTypeDefine (typeId,OpTypeName)  values ( 111,'汇总盘点入库') 
	insert dbo.Store_OpTypeDefine (typeId,OpTypeName)  values ( 112,'导入入库') 
	insert dbo.Store_OpTypeDefine (typeId,OpTypeName)  values ( 201,'销售出库') 
	insert dbo.Store_OpTypeDefine (typeId,OpTypeName)  values ( 202,'采购退货出库') 
	insert dbo.Store_OpTypeDefine (typeId,OpTypeName)  values ( 203,'领料出库') 
	insert dbo.Store_OpTypeDefine (typeId,OpTypeName)  values ( 204,'直接出库') 
	insert dbo.Store_OpTypeDefine (typeId,OpTypeName)  values ( 205,'成品出库') 
	insert dbo.Store_OpTypeDefine (typeId,OpTypeName)  values ( 206,'借货出库') 
	insert dbo.Store_OpTypeDefine (typeId,OpTypeName)  values ( 207,'调拨出库') 
	insert dbo.Store_OpTypeDefine (typeId,OpTypeName)  values ( 208,'精确盘点出库') 
	insert dbo.Store_OpTypeDefine (typeId,OpTypeName)  values ( 209,'组装出库') 
	insert dbo.Store_OpTypeDefine (typeId,OpTypeName)  values ( 210,'拆分出库') 
	insert dbo.Store_OpTypeDefine (typeId,OpTypeName)  values ( 211,'汇总盘点出库') 
	insert dbo.Store_OpTypeDefine (typeId,OpTypeName)  values ( 301,'入库单删除') 
	insert dbo.Store_OpTypeDefine (typeId,OpTypeName)  values ( 302,'出库单删除') 
	insert dbo.Store_OpTypeDefine (typeId,OpTypeName)  values ( 401,'入库单恢复') 
	insert dbo.Store_OpTypeDefine (typeId,OpTypeName)  values ( 402,'出库单恢复') 
end

GO

if exists(select 1 from Store_OpTypeDefine where OpTypeName='拆装入库') update Store_OpTypeDefine set OpTypeName='组装入库' where typeId=109
if exists(select 1 from Store_OpTypeDefine where OpTypeName='拆装出库') update Store_OpTypeDefine set OpTypeName='组装出库' where typeId=209

if not exists(select top 1 typeid from Store_OpTypeDefine where typeid=212) insert into Store_OpTypeDefine values(212,'补料出库')
if not exists(select top 1 typeid from Store_OpTypeDefine where typeid=113) insert into Store_OpTypeDefine values(113,'半成品入库')
if not exists(select 1 from Store_OpTypeDefine where OpTypeName='废料入库') insert dbo.Store_OpTypeDefine (typeId,OpTypeName)  values ( 116,'废料入库')
if not exists(select 1 from Store_OpTypeDefine where OpTypeName='半成品报废入库') insert dbo.Store_OpTypeDefine (typeId,OpTypeName)  values ( 115,'半成品报废入库')
if not exists(select 1 from Store_OpTypeDefine where OpTypeName='报废入库') insert dbo.Store_OpTypeDefine (typeId,OpTypeName)  values ( 114,'报废入库')
 
GO
if exists(select top 1 date1 from contractlist where date1 is null) update contractlist set date1=a.date1,area=a.area,trade=a.trade from contract a,contractlist b where a.ord=b.contract and b.date1 is null
if not exists(select top 1 sort1 from zdymx where sort1=41)begin insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('产品名称','title',1,1,140,10,1,41,1)insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('编号','order1',2,1,60,10,2,41,2)insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('型号','type1',2,1,60,10,3,41,3)insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('单位','unitall',1,1,60,60,4,41,4)insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('单价','price1',1,1,80,80,6,41,5)insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('数量','num1',1,1,45,45,5,41,6)insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('总价','money1',1,1,80,80,7,41,7)insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('到货日期','date2',2,1,70,70,12,41,8)insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('备注','intro',2,1,85,85,13,41,9)insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('自定义1','zdy1',2,1,75,75,14,41,10)insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('自定义2','zdy2',2,1,75,75,15,41,11)insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('自定义3','zdy3',2,1,75,75,16,41,12)insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('自定义4','zdy4',2,1,75,75,17,41,13)insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('自定义5','zdy5',2,1,75,75,18,41,14)insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('自定义6','zdy6',2,1,75,75,19,41,15)insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('批号','ph',2,1,80,10,8,41,16)insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('序列号','xlh',2,1,80,10,9,41,17)insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('生产日期','datesc',2,1,80,10,10,41,18)insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('有效日期','dateyx',2,1,80,10,11,41,19) end

if not exists(select top 1 sort1 from zdymx where sort1=41 and name='contract' ) 
begin
	insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('关联单据','contract',2,1,140,10,13,41,20)
	insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('销售人员','cateid',2,1,75,10,13,41,21)
	insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('购买日期','htdate',1,1,80,10,13,41,22)
end 

if not exists(select top 1 sort1 from zdy where sort1=75)begin insert into zdy(title,name,sort,gl,set_open,js,dc,dr,tj,gate1,sort1) values('自定义1','zdy1',2,0,1,0,1,1,1,1,75)insert into zdy(title,name,sort,gl,set_open,js,dc,dr,tj,gate1,sort1) values('自定义2','zdy2',2,0,1,0,1,1,1,2,75)insert into zdy(title,name,sort,gl,set_open,js,dc,dr,tj,gate1,sort1) values('自定义3','zdy3',2,0,1,0,1,1,1,3,75)insert into zdy(title,name,sort,gl,set_open,js,dc,dr,tj,gate1,sort1) values('自定义4','zdy4',2,0,1,0,1,1,1,4,75)insert into zdy(title,name,sort,gl,set_open,js,dc,dr,tj,gate1,sort1) values('自定义5','zdy5',1,7501,1,0,1,1,1,5,75)insert into zdy(title,name,sort,gl,set_open,js,dc,dr,tj,gate1,sort1) values('自定义6','zdy6',1,7502,1,0,1,1,1,6,75)end
if not exists(select top 1 sort1 from zdybh where sort1=75)
begin 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('CGTH_',1,1,4,2,1,75)
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('BJ_',1,0,4,2,2,75)
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('zbintel',1,0,4,2,3,75)
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('ZB/',1,0,4,2,4,75)
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',2,1,4,2,5,75)
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',3,1,2,2,6,75)
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',4,1,1,2,7,75)
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',5,1,1,2,8,75)
end
if not exists(select top 1 sort1 from zdymx where sort1=75)begin insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('产品名称','title',1,1,140,10,1,75,1)insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('编号','order1',2,1,60,10,2,75,2)insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('型号','type1',2,1,60,10,3,75,3)insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('单位','unitall',1,1,60,60,4,75,4)insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('单价','price1',1,1,80,80,5,75,5)insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('数量','num1',1,1,45,45,6,75,6)insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('总价','money1',1,1,80,80,7,75,7)insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('批号','ph',2,1,80,10,8,75,8)insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('序列号','xlh',2,1,80,10,9,75,9)insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('生产日期','datesc',2,1,80,10,10,75,10)insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('有效日期','dateyx',2,1,80,10,11,75,11)insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('交货日期','date2',2,1,70,70,12,75,12)insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('备注','intro',2,1,85,85,13,75,13)insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('自定义1','zdy1',2,1,75,75,14,75,14)insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('自定义2','zdy2',2,1,75,75,15,75,15)insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('自定义3','zdy3',2,1,75,75,16,75,16)insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('自定义4','zdy4',2,1,75,75,17,75,17)insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('自定义5','zdy5',2,1,75,75,18,75,18)insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('自定义6','zdy6',2,1,75,75,19,75,19) end

if exists(select 1 from sortonehy where sort1='不开票（默认公式）')
begin 
	update sortonehy set sort1='不开票' where sort1='不开票（默认公式）'
end

if not exists(select top 1 gate2 from sortonehy where gate2=75) and exists(select 1 from sortonehy)
begin 
	insert into sortonehy(sort1,gate1,gate2) values('产品质量',4,75)
	insert into sortonehy(sort1,gate1,gate2) values('服务质量',3,75)
	insert into sortonehy(sort1,gate1,gate2) values('客户原因',2,75)
	insert into sortonehy(sort1,gate1,gate2) values('其它',1,75)
end

if exists(select top 1 gate2 from sortonehy where gate2=75 and ord is null) update sortonehy set ord=id where gate2=75

if not exists(select top 1 1 from sortonehy where gate2=76) and exists(select 1 from sortonehy)
begin
	insert into sortonehy(sort1,gate1,gate2) values('协商中',4,76)
	insert into sortonehy(sort1,gate1,gate2) values('处理中',3,76)
	insert into sortonehy(sort1,gate1,gate2) values('未处理',2,76)
	insert into sortonehy(sort1,gate1,gate2) values('处理完毕',1,76)
end
if exists(select 1 gate2 from sortonehy where gate2=76 and ord is null) update sortonehy set ord=id where gate2=76
update reply set sort1=1 where ord=ord2 and sort1=0
if not exists(select 1 from callSet where Company='qpj' and Model='IA4')insert into callSet(Company,Object,Model,IncFileIndex,IncFileJsUrl,IncFileJsChannel,IncFileJsSerial,SubOffHook,SubCall,SubHangUp,AddTime) values('qpj','qnviccub','IA4','打开设备失败,请检查设备是否已经插入并安装了驱动,并且没有其它程序已经打开设备','','','','TV_OffHookCtrl','TV_StartDial','TV_HangUpCtrl','2012-4-16 17:24:51')
if not exists(select 1 from callSet where Company='sy' and Model='FR60')insert into callSet(Company,Object,Model,IncFileIndex,IncFileJsUrl,IncFileJsChannel,IncFileJsSerial,SubOffHook,SubCall,SubHangUp,AddTime) values('sy','YeahDone1','FR60','','../ocx/js/YeahDoneFR60.html','','','TV_OffHookCtrl','TV_StartDial','TV_HangUpCtrl','2012-4-16 17:24:51')
update ku set num3=(case when num1<=0 then num2 else num1 end) where num3 is null
if not exists(select 1 from zdy where sort1=94)begin insert into zdy(title,name,sort,gl,set_open,js,dc,dr,tj,gate1,sort1) values('自定义1','zdy1',2,0,1,0,1,1,1,1,94)insert into zdy(title,name,sort,gl,set_open,js,dc,dr,tj,gate1,sort1) values('自定义2','zdy2',2,0,1,0,1,1,1,2,94)insert into zdy(title,name,sort,gl,set_open,js,dc,dr,tj,gate1,sort1) values('自定义3','zdy3',2,0,1,0,1,1,1,3,94)insert into zdy(title,name,sort,gl,set_open,js,dc,dr,tj,gate1,sort1) values('自定义4','zdy4',2,0,1,0,1,1,1,4,94)insert into zdy(title,name,sort,gl,set_open,js,dc,dr,tj,gate1,sort1) values('自定义5','zdy5',2,0,1,0,1,1,1,5,94)insert into zdy(title,name,sort,gl,set_open,js,dc,dr,tj,gate1,sort1) values('自定义6','zdy6',2,0,1,0,1,1,1,6,94)insert into zdy(title,name,sort,gl,set_open,js,dc,dr,tj,gate1,sort1) values('自定义7','zdy7',1,95,1,0,1,1,1,7,94)insert into zdy(title,name,sort,gl,set_open,js,dc,dr,tj,gate1,sort1) values('自定义8','zdy8',1,96,1,0,1,1,1,8,94)insert into zdy(title,name,sort,gl,set_open,js,dc,dr,tj,gate1,sort1) values('自定义9','zdy9',3,0,1,0,1,1,1,9,94)end
if not exists (select 1 from power3)begin insert into power3(sort1,name,gate1) values(1,'检索',1) insert into power3(sort1,name,gate1) values(2,'共享',2) insert into power3(sort1,name,gate1) values(3,'统计',3) insert into power3(sort1,name,gate1) values(4,'指派',4) end
if not exists(select sort1 from zdy where sort1=41)begin insert into zdy(title,name,sort,gl,set_open,js,dc,dr,tj,gate1,sort1) values('自定义1','zdy1',2,0,1,0,1,1,1,1,41)insert into zdy(title,name,sort,gl,set_open,js,dc,dr,tj,gate1,sort1) values('自定义2','zdy2',2,0,1,0,1,1,1,2,41)insert into zdy(title,name,sort,gl,set_open,js,dc,dr,tj,gate1,sort1) values('自定义3','zdy3',2,0,1,0,1,1,1,3,41)insert into zdy(title,name,sort,gl,set_open,js,dc,dr,tj,gate1,sort1) values('自定义4','zdy4',2,0,1,0,1,1,1,4,41)insert into zdy(title,name,sort,gl,set_open,js,dc,dr,tj,gate1,sort1) values('自定义5','zdy5',1,4101,1,0,1,1,1,5,41)insert into zdy(title,name,sort,gl,set_open,js,dc,dr,tj,gate1,sort1) values('自定义6','zdy6',1,4102,1,0,1,1,1,6,41)end
if exists(select 1 from sortck where del is null)update sortck set del=1 where del is null
if exists(select 1 from sortck1 where del is null)update sortck1 set del=1 where del is null
if exists(select 1 from person where sort is null)update person set sort='' where sort is null
if exists(select 1 from person where sort=7 and company=0 and sort1 is null)update person set del=77 where sort=7 and company=0 and sort1 is null
if exists(select 1 from sortbank where del is null) update sortbank set del=1 where del is null
if exists(select 1 from tel where del=7) delete tel where del=7

if not exists(select 1 from zdymx where sort1=80)
begin
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('编号','bh','2','1','60','10','1','80','1')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('张数','num','1','1','60','10','2','80','2')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('金额','money1','1','1','60','10','3','80','3')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('备注','intro','2','1','60','60','4','80','4')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('关联客户','tel','2','1','80','80','5','80','5')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('关联联系人','person','2','1','80','80','6','80','6')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('关联合同','contract','2','1','80','80','7','80','7')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('关联项目','chance','2','1','80','80','8','80','8')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('关联采购','caigou','2','1','80','80','9','80','9')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('关联日程','richeng','2','1','80','80','10','80','10')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('关联售后','shouhou','2','1','80','80','11','80','11')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('关联发货','fahuo','2','1','80','80','12','80','12')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('关联供应商','iwork','2','1','80','80','13','80','13')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('关联借款单','jkid','2','1','80','80','14','80','14')
end

if not exists(select 1 from zdymx where sort1=81)
begin
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('编号','bh','2','1','60','10','1','81','1')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('张数','num','1','1','60','10','2','81','2')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('金额','money1','1','1','60','10','3','81','3')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('备注','intro','2','1','60','60','4','81','4')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('关联客户','tel','2','1','80','80','5','81','5')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('关联联系人','person','2','1','80','80','6','81','6')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('关联合同','contract','2','1','80','80','7','81','7')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('关联项目','chance','2','1','80','80','8','81','8')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('关联采购','caigou','2','1','80','80','9','81','9')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('关联日程','richeng','2','1','80','80','10','81','10')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('关联售后','shouhou','2','1','80','80','11','81','11')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('关联发货','fahuo','2','1','80','80','12','81','12')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('关联供应商','iwork','2','1','80','80','13','81','13')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('关联借款单','jkid','2','1','80','80','14','81','14')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('出发时间','startime','2','1','80','80','15','81','15')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('出发地点','smdd','2','1','80','80','15','81','15')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('到达时间','endtime','2','1','80','80','15','81','15')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('到达地点','mdd','2','1','80','80','20','81','16')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('里程','lic','2','1','80','80','17','81','17')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('交通工具','jtgj','2','1','80','80','18','81','18')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('返回时间','retime','2','1','80','80','19','81','19')
end

if not exists(select 1 from zdymx where sort1=82)
begin
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('编号','bh','2','1','60','10','1','82','1')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('张数','num','1','1','60','10','2','82','2')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('金额','money1','1','1','60','10','3','82','3')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('备注','intro','2','1','60','60','4','82','4')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('关联客户','tel','2','1','80','80','5','82','5')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('关联联系人','person','2','1','80','80','6','82','6')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('关联合同','contract','2','1','80','80','7','82','7')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('关联项目','chance','2','1','80','80','8','82','8')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('关联采购','caigou','2','1','80','80','9','82','9')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('关联日程','richeng','2','1','80','80','10','82','10')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('关联售后','shouhou','2','1','80','80','11','82','11')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('关联发货','fahuo','2','1','80','80','12','82','12')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('关联供应商','iwork','2','1','80','80','13','82','13')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('关联借款单','jkid','2','1','80','80','14','82','14')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('开始日期','startime','2','1','80','80','15','82','15')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('结束日期','endtime','2','1','80','80','16','82','16')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('所在城市','city','2','1','80','80','17','82','17')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('宾馆名称','hatol','2','1','80','80','18','82','18')
end

if not exists(select 1 from zdymx where sort1=83)
begin
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('编号','bh','2','1','60','10','1','83','1')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('张数','num','1','1','60','10','2','83','2')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('金额','money1','1','1','60','10','3','83','3')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('备注','intro','2','1','60','60','4','83','4')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('关联客户','tel','2','1','80','80','5','83','5')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('关联联系人','person','2','1','80','80','6','83','6')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('关联合同','contract','2','1','80','80','7','83','7')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('关联项目','chance','2','1','80','80','8','83','8')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('关联采购','caigou','2','1','80','80','9','83','9')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('关联日程','richeng','2','1','80','80','10','83','10')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('关联售后','shouhou','2','1','80','80','11','83','11')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('关联发货','fahuo','2','1','80','80','12','83','12')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('关联供应商','iwork','2','1','80','80','13','83','13')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('关联借款单','jkid','2','1','80','80','14','83','14')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('公关日期','ggdate','2','1','80','80','15','83','15')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('公关对象','ggdx','2','1','80','80','16','83','16')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('公关事由','ggsy','2','1','80','80','17','83','17')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('赠送礼品','lw','2','1','80','80','18','83','18')
end

if not exists(select 1 from zdymx where sort1=84)
begin
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('编号','bh','2','1','60','10','1','84','1')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('张数','num','1','1','60','10','2','84','2')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('金额','money1','1','1','60','10','3','84','3')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('备注','intro','2','1','60','60','4','84','4')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('关联客户','tel','2','1','80','80','5','84','5')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('关联联系人','person','2','1','80','80','6','84','6')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('关联合同','contract','2','1','80','80','7','84','7')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('关联项目','chance','2','1','80','80','8','84','8')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('关联采购','caigou','2','1','80','80','9','84','9')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('关联日程','richeng','2','1','80','80','10','84','10')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('关联售后','shouhou','2','1','80','80','11','84','11')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('关联发货','fahuo','2','1','80','80','12','84','12')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('关联供应商','iwork','2','1','80','80','13','84','13')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('关联借款单','jkid','2','1','80','80','14','84','14')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('需要日期','xytime','2','1','80','80','15','84','15')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('用途','yt','2','1','80','80','16','84','16')
end

GO

if not exists(select 1 from zdymx where sort1=9001)
begin	
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('产品名称','title','1','1','60','10','1','9001','1')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('编号','order1','2','1','60','10','2','9001','2')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('型号','type1','2','1','60','10','3','9001','3')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('单位','unitall','1','1','60','60','4','9001','4')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('数量','num1','1','1','80','80','5','9001','5')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('批号','ph','1','1','80','80','6','9001','6')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('序列号','xlh','1','1','80','80','7','9001','7')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('生产日期','datesc','2','1','80','80','8','9001','8')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('有效日期','dateyx','2','1','80','80','9','9001','9')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('养护人员','share','2','1','80','80','10','9001','10')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('养护周期','MaintainCyc','1','1','80','80','11','9001','11')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('质量状况','status','2','1','80','80','12','9001','12')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('处理结果','result','2','1','80','80','13','9001','13')
	Insert Into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('备注','intro','2','1','80','80','14','9001','14')
	insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('自定义1','zdy1',2,1,'80','80',15,9001,15)
	insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('自定义2','zdy2',2,1,'80','80',16,9001,16)
	insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('自定义3','zdy3',2,1,'80','80',17,9001,17)
	insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('自定义4','zdy4',2,1,'80','80',18,9001,18)
	insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('自定义5','zdy5',2,0,'80','80',19,9001,19)
	insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('自定义6','zdy6',2,0,'80','80',20,9001,20)
end

GO

if not exists(select 1 from setopen where sort1=60) insert into setopen (intro,sort1) values (1,60)
if not exists(select 1 from setopen where sort1=61) insert into setopen (intro,sort1) values (0,61)
if not exists(select 1 from setopen where sort1=62) insert into setopen (intro,sort1) values (0,62)
if not exists(select 1 from setopen where sort1=63) insert into setopen (intro,sort1) values (1,63)
if not exists(select 1 from setopen where sort1=64) insert into setopen (intro,sort1) values (0,64)
if not exists(select 1 from setopen where sort1=65) insert into setopen (intro,sort1) values (0,65)
if not exists(select 1 from setopen where sort1=66) insert into setopen (intro,sort1) values (1,66)
if not exists(select 1 from setopen where sort1 in (60,61,62,63,64,65,66) and intro=1) update setopen set intro=1 where sort1=60

if exists(select 1 from payback where company is null)update payback set company=(select top 1 company from contract where ord=payback.contract) where company is null
if not exists (select 1 from errMessage where message=1 and errNum=-100) insert into errMessage(message,errNum,errMgs) values(1,-100,'其它故障')
if not exists (select 1 from errMessage where message=1 and errNum=0) insert into errMessage(message,errNum,errMgs) values(1,0,'发送成功')
if not exists (select 1 from errMessage where message=1 and errNum=-1) insert into errMessage(message,errNum,errMgs) values(1,-1,'其它故障')
if not exists (select 1 from errMessage where message=1 and errNum=-2) insert into errMessage(message,errNum,errMgs) values(1,-2,'余额不足')
if not exists (select 1 from errMessage where message=1 and errNum=-3) insert into errMessage(message,errNum,errMgs) values(1,-3,'其它故障')
if not exists (select 1 from errMessage where message=1 and errNum=-4) insert into errMessage(message,errNum,errMgs) values(1,-4,'其它故障')
if not exists (select 1 from errMessage where message=1 and errNum=-5) insert into errMessage(message,errNum,errMgs) values(1,-5,'其它故障')
if not exists (select 1 from errMessage where message=1 and errNum=-6) insert into errMessage(message,errNum,errMgs) values(1,-6,'其它故障')
if not exists (select 1 from errMessage where message=1 and errNum=-8) insert into errMessage(message,errNum,errMgs) values(1,-8,'其它故障')
if not exists (select 1 from errMessage where message=1 and errNum=-13) insert into errMessage(message,errNum,errMgs) values(1,-13,'其它故障')
if not exists (select 1 from errMessage where message=1 and errNum=-17) insert into errMessage(message,errNum,errMgs) values(1,-17,'其它故障')
if not exists (select 1 from errMessage where message=1 and errNum=-19) insert into errMessage(message,errNum,errMgs) values(1,-19,'其它故障')
if not exists (select 1 from errMessage where message=1 and errNum=7) insert into errMessage(message,errNum,errMgs) values(1,7,'待发送')
if not exists (select 1 from errMessage where message=1 and errNum=-201) insert into errMessage(message,errNum,errMgs) values(1,-201,'其它故障')
if not exists (select 1 from errMessage where message=1 and errNum=-202) insert into errMessage(message,errNum,errMgs) values(1,-202,'其它故障')
if not exists (select 1 from errMessage where message=1 and errNum=-203) insert into errMessage(message,errNum,errMgs) values(1,-203,'其它故障')
if not exists (select 1 from errMessage where message=1 and errNum=-30) insert into errMessage(message,errNum,errMgs) values(1,-30,'敏感词')
if not exists (select 1 from errMessage where message=1 and errNum=908) insert into errMessage(message,errNum,errMgs) values(1,908,'发送中...')
if not exists (select 1 from errMessage where message=1 and errNum=909) insert into errMessage(message,errNum,errMgs) values(1,909,'发送扣费失败')
if not exists (select 1 from errMessage where message=1 and errNum=910) insert into errMessage(message,errNum,errMgs) values(1,910,'数据提交失败')
if not exists (select 1 from errMessage where message=1 and errNum=911) insert into errMessage(message,errNum,errMgs) values(1,911,'发送失败')
if exists(select 1 from learnhd where clicknum is null)update learnhd set clicknum=(select count(1) from replyhd where ord=learnhd.ord ) where clicknum is null
if exists(select 1 from bank where intro='预付款') update bank set intro='客户预收款' where intro='预付款'
if exists(select 1 from bank where intro='退客户预付款') update bank set intro='客户退预收款' where intro='退客户预付款'
if exists(select 1 from chance where addcate is null) update chance set addcate=cateid where addcate is null
if not exists(select 1 from sortonehy where gate2=5000) and exists(select 1 from sortonehy)
begin
	insert into sortonehy(sort1,gate1,gate2) values('#FF0000',24,5000);
	insert into sortonehy(sort1,gate1,gate2) values('#0000FF',48,5000);
	insert into sortonehy(sort1,gate1,gate2) values('#FF9900',72,5000);
end

update sortonehy set ord=id where gate2=5000 and isnull(ord,0)=0
if not exists(select 1 from sortonehy where gate2=5001) and exists(select 1 from sortonehy)
begin
	insert into sortonehy(sort1,gate1,gate2) values('开启',1,5001)
	insert into sortonehy(sort1,gate1,gate2) values('关闭',0,5001)
end
update sortonehy set ord=id where gate2=5001 if exists(select 1 from contract where fqhk is null) update contract set fqhk=0 where fqhk is null
if not exists(select 1 from zdymx where sort1=32)
begin
	insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('产品名称','title',1,1,140,10,1,32,1)
	insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('编号','order1',2,1,80,10,2,32,2)
	insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('型号','type1',2,1,80,10,3,32,3)
	insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('单位','unitall',1,1,60,60,4,32,4)
	insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('数量','num1',1,1,70,70,5,32,5)
	insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('到货日期','date2',2,1,85,85,6,32,6)
	insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('备注','intro',2,1,85,85,7,32,7)
	insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('自定义1','zdy1',2,1,75,75,8,32,8)
	insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('自定义2','zdy2',2,1,75,75,9,32,9)
	insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('自定义3','zdy3',2,1,75,75,10,32,10)
	insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('自定义4','zdy4',2,1,75,75,11,32,11)
	insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('自定义5','zdy5',2,1,75,75,12,32,12)
	insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('自定义6','zdy6',2,1,75,75,13,32,13)
end

GO

if not exists(select 1 from errMessage where message=1 and errNum=-13 and errMgs='定时时间错误') update errMessage set errMgs='定时时间错误' where message=1 and errNum=-13
if exists(select 1 from payback where paybacktype is null)update payback set paybacktype=0 where paybacktype is null
if exists(select 1 from contract_his where paybacktype is null)update contract_his set paybacktype=0 where paybacktype is null
if exists(select 1 from contract where paybacktype is null)update contract set paybacktype=0 where paybacktype is null
if exists(select 1 from contractlist where paybacktype is null)update contractlist set paybacktype=0 where paybacktype is null
update tel set sharecontact=0 where sharecontact is null
update tel_his set sharecontact=0 where sharecontact is null
if exists (select id from sortbz where intro='RNB') update sortbz set intro='RMB' where intro='RNB'
if exists(select 1 from sortonehy where id1 is null and gate2=51)update sortonehy set id1=0 where id1 is null and gate2=51
if exists(select 1 from sortonehy where deepth is null and gate2=51)update sortonehy set deepth=1 where deepth is null and gate2=51
if not exists(select 1 from zdymx where sort1=33)
begin
	insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('产品名称','title',1,1,140,10,1,33,1)
    insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('型号','type1',2,1,80,10,3,33,3)
	insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('单位','unitall',1,1,60,60,4,33,4)
	insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('数量','num1',1,1,70,70,5,33,5)
	insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('批号','ph',2,1,80,80,6,33,6)
	insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('序列号','xlh',2,1,80,80,7,33,7)
	insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('生产日期','datesc',2,1,80,80,8,33,8)
	insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('有效日期','dateyx',2,1,80,80,9,33,9)
	insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('备注','intro',2,1,85,85,10,33,10)
	insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('自定义1','zdy1',2,1,75,75,11,33,11)
	insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('自定义2','zdy2',2,1,75,75,12,33,12)
	insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('自定义3','zdy3',2,1,75,75,13,33,13)
	insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('自定义4','zdy4',2,1,75,75,14,33,14)
	insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('自定义5','zdy5',2,1,75,75,15,33,15)
	insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('自定义6','zdy6',2,1,75,75,16,33,16)
end

--报价明细自定义
if not exists(select 1 from zdymx where sort1=1003)
begin
	insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('产品名称','title',1,1,140,10,1,1003,1)
	insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('编号','order1',2,1,80,10,2,1003,2)
	insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('型号','type1',2,1,80,10,3,1003,3)
	insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('单位','unitall',1,1,60,60,4,1003,4)
	insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('数量','num1',1,1,70,70,5,1003,5)
	insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('备注','price1',2,1,85,85,6,1003,6)
	insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('自定义1','zdy1',2,0,75,75,7,1003,7)
	insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('自定义2','zdy2',2,0,75,75,8,1003,8)
	insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('自定义3','zdy3',2,0,75,75,9,1003,9)
	insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('自定义4','zdy4',2,0,75,75,10,1003,10)
	insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('自定义5','zdy5',2,0,75,75,11,1003,11)
	insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('自定义6','zdy6',2,0,75,75,12,1003,12)
end

if exists(select 1 from zdymx where sort1=31 and sorce=5) update zdymx set gate1=5 where sort1=31 and sorce=5
if exists(select 1 from zdymx where sort1=31 and sorce=6) update zdymx set gate1=6 where sort1=31 and sorce=6

GO

if exists(select 1 from zdymx where sort1=31 and sorce=7 and sort=2)update zdymx set sort=1 where sort1=31 and sorce=7 and sort=2
update person set birthdayType=1 where birthdayType is null
update person_his set birthdayType=1 where birthdayType is null

insert into power select qx_open,qx_intro,ord,7,20 from power where ord in (select ord from power where sort1=7 and sort2=13) and ord not in (select ord from power where sort1=7 and sort2=20) and sort1=7 and sort2=13
insert into power select qx_open,qx_intro,ord,1,21 from power where ord not in (select ord from power where sort1=1 and sort2=21) and sort1=1 and sort2=1
--if exists (select 1 from power where sort1>=50 and sort1<=60 and sort2=16 and qx_open=3) update power set qx_open=1 where sort1>=50 and sort1<=60 and sort2=16 and qx_open=3
if exists (select 1 from power where sort1=56 and sort2=16 and qx_open=1) update power set qx_open=3 where sort1=56 and sort2=16 and qx_open=1
if not exists (select 1 from Store_OpTypeDefine where typeId=124 ) insert Store_OpTypeDefine (typeId,OpTypeName)  values ( 124,'直接入库对冲')
if not exists (select 1 from Store_OpTypeDefine where typeId=121 ) insert Store_OpTypeDefine (typeId,OpTypeName)  values ( 121,'采购入库对冲')
if exists(select 1 from kuin where date5='1900-1-1' and del=99 and sort1=10) update kuin set date5=(select top 1 left(CONVERT(varchar(20), date7,120),charindex(' ',CONVERT(varchar(20), date7,120))) from kuinlist where kuin=kuin.ord) where sort1=10 and del=99 and date5='1900-1-1'
if exists(select 1 from kuout where date5='1900-1-1' and del=99 and sort1=10) update kuout set date5=(select top 1 left(CONVERT(varchar(20), date7,120),charindex(' ',CONVERT(varchar(20), date7,120))) from kuoutlist2 where kuout=kuout.ord) where sort1=10 and del=99 and date5='1900-1-1'
if not exists(select 1 from zdymx where sort1=32 and sorce=2)
INSERT INTO [zdymx] ([title],[name],[sort],[set_open],[kd],[kd2],[gate1],[sort1],[sorce]) values (N'编号',N'order1',2,1,60,10,2,32,2)
if not exists(select 1 from zdymx where sort1=32 and sorce=3) INSERT INTO [zdymx] ([title],[name],[sort],[set_open],[kd],[kd2],[gate1],[sort1],[sorce]) values (N'型号',N'type1',2,1,60,10,3,32,3)
if not exists(select 1 from zdymx where sort1=32 and sorce=4) INSERT INTO [zdymx] ([title],[name],[sort],[set_open],[kd],[kd2],[gate1],[sort1],[sorce]) values (N'单位',N'unitall',1,1,60,60,4,32,4)
if not exists(select 1 from zdymx where sort1=32 and sorce=9) INSERT INTO [zdymx] ([title],[name],[sort],[set_open],[kd],[kd2],[gate1],[sort1],[sorce]) values (N'备注',N'intro',2,1,85,85,9,32,9)
if not exists(select 1 from zdymx where sort1=32 and sorce=10) INSERT INTO [zdymx] ([title],[name],[sort],[set_open],[kd],[kd2],[gate1],[sort1],[sorce]) values (N'自定义1',N'zdy1',2,0,75,75,10,32,10)
if not exists(select 1 from zdymx where sort1=33 and sorce=13) INSERT INTO [zdymx] ([title],[name],[sort],[set_open],[kd],[kd2],[gate1],[sort1],[sorce]) values (N'自定义4',N'zdy4',2,0,75,75,13,33,13)
if not exists(select 1 from zdymx where sort1=33 and sorce=15) INSERT INTO [zdymx] ([title],[name],[sort],[set_open],[kd],[kd2],[gate1],[sort1],[sorce]) values (N'自定义6',N'zdy6',2,0,75,75,15,33,15)
if not exists(select 1 from zdymx where sort1=25 and sorce=2) INSERT INTO [zdymx] ([title],[name],[sort],[set_open],[kd],[kd2],[gate1],[sort1],[sorce]) values (N'编号',N'order1',2,1,60,10,2,25,2)
if not exists(select 1 from zdymx where sort1=25 and sorce=4) INSERT INTO [zdymx] ([title],[name],[sort],[set_open],[kd],[kd2],[gate1],[sort1],[sorce]) values (N'单位',N'unitall',1,1,60,60,4,25,4)
if not exists(select 1 from zdymx where sort1=25 and sorce=6) INSERT INTO [zdymx] ([title],[name],[sort],[set_open],[kd],[kd2],[gate1],[sort1],[sorce]) values (N'数量',N'num1',1,1,45,45,5,25,6)
if not exists(select 1 from zdymx where sort1=25 and sorce=7) INSERT INTO [zdymx] ([title],[name],[sort],[set_open],[kd],[kd2],[gate1],[sort1],[sorce]) values (N'总价',N'money1',2,1,80,80,7,25,7)
if not exists(select 1 from zdymx where sort1=25 and sorce=8) INSERT INTO [zdymx] ([title],[name],[sort],[set_open],[kd],[kd2],[gate1],[sort1],[sorce]) values (N'到货日期',N'date2',2,1,70,70,8,25,8)
if not exists(select 1 from zdymx where sort1=25 and sorce=11) INSERT INTO [zdymx] ([title],[name],[sort],[set_open],[kd],[kd2],[gate1],[sort1],[sorce]) values (N'自定义2',N'zdy2',2,0,75,75,11,25,11)
if not exists(select 1 from zdymx where sort1=25 and sorce=13) INSERT INTO [zdymx] ([title],[name],[sort],[set_open],[kd],[kd2],[gate1],[sort1],[sorce]) values (N'自定义4',N'zdy4',2,0,75,75,13,25,13)
if not exists(select 1 from zdymx where sort1=31 and sorce=1) INSERT INTO [zdymx] ([title],[name],[sort],[set_open],[kd],[kd2],[gate1],[sort1],[sorce]) values (N'产品名称',N'title',1,1,140,10,1,31,1)
if not exists(select 1 from zdymx where sort1=31 and sorce=2) INSERT INTO [zdymx] ([title],[name],[sort],[set_open],[kd],[kd2],[gate1],[sort1],[sorce]) values (N'编号',N'order1',2,1,60,10,2,31,2)
if not exists(select 1 from zdymx where sort1=31 and sorce=3) INSERT INTO [zdymx] ([title],[name],[sort],[set_open],[kd],[kd2],[gate1],[sort1],[sorce]) values (N'型号',N'type1',2,1,60,10,3,31,3)
if not exists(select 1 from zdymx where sort1=31 and sorce=4) INSERT INTO [zdymx] ([title],[name],[sort],[set_open],[kd],[kd2],[gate1],[sort1],[sorce]) values (N'单位',N'unitall',1,1,60,60,4,31,4)
if not exists(select 1 from zdymx where sort1=31 and sorce=5) INSERT INTO [zdymx] ([title],[name],[sort],[set_open],[kd],[kd2],[gate1],[sort1],[sorce]) values (N'单价',N'price1',1,1,80,80,5,31,5)
if not exists(select 1 from zdymx where sort1=31 and sorce=6) INSERT INTO [zdymx] ([title],[name],[sort],[set_open],[kd],[kd2],[gate1],[sort1],[sorce]) values (N'数量',N'num1',1,1,45,45,6,31,6)
if not exists(select 1 from zdymx where sort1=31 and sorce=7) INSERT INTO [zdymx] ([title],[name],[sort],[set_open],[kd],[kd2],[gate1],[sort1],[sorce]) values (N'总价',N'money1',1,1,80,80,7,31,7)
if not exists(select 1 from zdymx where sort1=31 and sorce=8) INSERT INTO [zdymx] ([title],[name],[sort],[set_open],[kd],[kd2],[gate1],[sort1],[sorce]) values (N'到货日期',N'date2',2,1,70,70,8,31,8)
if not exists(select 1 from zdymx where sort1=31 and sorce=9) INSERT INTO [zdymx] ([title],[name],[sort],[set_open],[kd],[kd2],[gate1],[sort1],[sorce]) values (N'备注',N'intro',2,1,85,85,9,31,9)
if not exists(select 1 from zdymx where sort1=31 and sorce=10) INSERT INTO [zdymx] ([title],[name],[sort],[set_open],[kd],[kd2],[gate1],[sort1],[sorce]) values (N'自定义1',N'zdy1',2,0,75,75,10,31,10)
if not exists(select 1 from zdymx where sort1=31 and sorce=11) INSERT INTO [zdymx] ([title],[name],[sort],[set_open],[kd],[kd2],[gate1],[sort1],[sorce]) values (N'自定义2',N'zdy2',2,0,75,75,11,31,11)
if not exists(select 1 from zdymx where sort1=31 and sorce=12) INSERT INTO [zdymx] ([title],[name],[sort],[set_open],[kd],[kd2],[gate1],[sort1],[sorce]) values (N'自定义3',N'zdy3',2,0,75,75,12,31,12)
if not exists(select 1 from zdymx where sort1=31 and sorce=13) INSERT INTO [zdymx] ([title],[name],[sort],[set_open],[kd],[kd2],[gate1],[sort1],[sorce]) values (N'自定义4',N'zdy4',2,0,75,75,13,31,13)
if not exists(select 1 from zdymx where sort1=31 and sorce=14) INSERT INTO [zdymx] ([title],[name],[sort],[set_open],[kd],[kd2],[gate1],[sort1],[sorce]) values (N'自定义5',N'zdy5',2,0,75,75,14,31,14)
if not exists(select 1 from zdymx where sort1=31 and sorce=15) INSERT INTO [zdymx] ([title],[name],[sort],[set_open],[kd],[kd2],[gate1],[sort1],[sorce]) values (N'自定义6',N'zdy6',2,0,75,75,15,31,15)
if not exists(select 1 from zdymx where sort1=32 and sorce=12) INSERT INTO [zdymx] ([title],[name],[sort],[set_open],[kd],[kd2],[gate1],[sort1],[sorce]) values (N'自定义3',N'zdy3',2,0,75,75,12,32,12)
if not exists(select 1 from zdymx where sort1=33 and sorce=1) INSERT INTO [zdymx] ([title],[name],[sort],[set_open],[kd],[kd2],[gate1],[sort1],[sorce]) values (N'产品名称',N'title',1,1,140,10,1,33,1)
if not exists(select 1 from zdymx where sort1=33 and sorce=7) INSERT INTO [zdymx] ([title],[name],[sort],[set_open],[kd],[kd2],[gate1],[sort1],[sorce]) values (N'总价',N'money1',2,1,80,80,7,33,7)
if not exists(select 1 from zdymx where sort1=33 and sorce=14) INSERT INTO [zdymx] ([title],[name],[sort],[set_open],[kd],[kd2],[gate1],[sort1],[sorce]) values (N'自定义5',N'zdy5',2,0,75,75,14,33,14)
if not exists(select 1 from zdymx where sort1=25 and sorce=12) INSERT INTO [zdymx] ([title],[name],[sort],[set_open],[kd],[kd2],[gate1],[sort1],[sorce]) values (N'自定义3',N'zdy3',2,0,75,75,12,25,12)
if not exists(select 1 from zdymx where sort1=32 and sorce=1) INSERT INTO [zdymx] ([title],[name],[sort],[set_open],[kd],[kd2],[gate1],[sort1],[sorce]) values (N'产品名称',N'title',1,1,140,10,1,32,1)
if not exists(select 1 from zdymx where sort1=32 and sorce=8) INSERT INTO [zdymx] ([title],[name],[sort],[set_open],[kd],[kd2],[gate1],[sort1],[sorce]) values (N'到货日期',N'date2',2,1,70,70,8,32,8)
if not exists(select 1 from zdymx where sort1=32 and sorce=11) INSERT INTO [zdymx] ([title],[name],[sort],[set_open],[kd],[kd2],[gate1],[sort1],[sorce]) values (N'自定义2',N'zdy2',2,0,75,75,11,32,11)
if not exists(select 1 from zdymx where sort1=32 and sorce=13) INSERT INTO [zdymx] ([title],[name],[sort],[set_open],[kd],[kd2],[gate1],[sort1],[sorce]) values (N'自定义4',N'zdy4',2,0,75,75,13,32,13)
if not exists(select 1 from zdymx where sort1=33 and sorce=8) INSERT INTO [zdymx] ([title],[name],[sort],[set_open],[kd],[kd2],[gate1],[sort1],[sorce]) values (N'到货日期',N'date2',2,1,70,70,8,33,8)
if not exists(select 1 from zdymx where sort1=33 and sorce=10) INSERT INTO [zdymx] ([title],[name],[sort],[set_open],[kd],[kd2],[gate1],[sort1],[sorce]) values (N'自定义1',N'zdy1',2,0,75,75,10,33,10)
if not exists(select 1 from zdymx where sort1=25 and sorce=9) INSERT INTO [zdymx] ([title],[name],[sort],[set_open],[kd],[kd2],[gate1],[sort1],[sorce]) values (N'备注',N'intro',2,1,85,85,9,25,9)
if not exists(select 1 from zdymx where sort1=25 and sorce=14) INSERT INTO [zdymx] ([title],[name],[sort],[set_open],[kd],[kd2],[gate1],[sort1],[sorce]) values (N'自定义5',N'zdy5',2,0,75,75,14,25,14)
if not exists(select 1 from zdymx where sort1=32 and sorce=6) INSERT INTO [zdymx] ([title],[name],[sort],[set_open],[kd],[kd2],[gate1],[sort1],[sorce]) values (N'数量',N'num1',1,1,45,45,5,32,6)
if not exists(select 1 from zdymx where sort1=33 and sorce=3) INSERT INTO [zdymx] ([title],[name],[sort],[set_open],[kd],[kd2],[gate1],[sort1],[sorce]) values (N'型号',N'type1',2,1,60,10,3,33,3)
if not exists(select 1 from zdymx where sort1=33 and sorce=4) INSERT INTO [zdymx] ([title],[name],[sort],[set_open],[kd],[kd2],[gate1],[sort1],[sorce]) values (N'单位',N'unitall',1,1,60,60,4,33,4)
if not exists(select 1 from zdymx where sort1=33 and sorce=5) INSERT INTO [zdymx] ([title],[name],[sort],[set_open],[kd],[kd2],[gate1],[sort1],[sorce]) values (N'单价',N'price1',1,1,80,80,6,33,5)
if not exists(select 1 from zdymx where sort1=33 and sorce=6) INSERT INTO [zdymx] ([title],[name],[sort],[set_open],[kd],[kd2],[gate1],[sort1],[sorce]) values (N'数量',N'num1',1,1,45,45,5,33,6)
if not exists(select 1 from zdymx where sort1=33 and sorce=9) INSERT INTO [zdymx] ([title],[name],[sort],[set_open],[kd],[kd2],[gate1],[sort1],[sorce]) values (N'备注',N'intro',2,1,85,85,9,33,9)
if not exists(select 1 from zdymx where sort1=33 and sorce=11) INSERT INTO [zdymx] ([title],[name],[sort],[set_open],[kd],[kd2],[gate1],[sort1],[sorce]) values (N'自定义2',N'zdy2',2,0,75,75,11,33,11)
if not exists(select 1 from zdymx where sort1=33 and sorce=12) INSERT INTO [zdymx] ([title],[name],[sort],[set_open],[kd],[kd2],[gate1],[sort1],[sorce]) values (N'自定义3',N'zdy3',2,0,75,75,12,33,12)
if not exists(select 1 from zdymx where sort1=25 and sorce=1) INSERT INTO [zdymx] ([title],[name],[sort],[set_open],[kd],[kd2],[gate1],[sort1],[sorce]) values (N'产品名称',N'title',1,1,140,10,1,25,1)
if not exists(select 1 from zdymx where sort1=25 and sorce=3) INSERT INTO [zdymx] ([title],[name],[sort],[set_open],[kd],[kd2],[gate1],[sort1],[sorce]) values (N'型号',N'type1',2,1,60,10,3,25,3)
if not exists(select 1 from zdymx where sort1=25 and sorce=5) INSERT INTO [zdymx] ([title],[name],[sort],[set_open],[kd],[kd2],[gate1],[sort1],[sorce]) values (N'单价',N'price1',1,1,80,80,6,25,5)
if not exists(select 1 from zdymx where sort1=25 and sorce=10) INSERT INTO [zdymx] ([title],[name],[sort],[set_open],[kd],[kd2],[gate1],[sort1],[sorce]) values (N'自定义1',N'zdy1',2,0,75,75,10,25,10)
if not exists(select 1 from zdymx where sort1=25 and sorce=15) INSERT INTO [zdymx] ([title],[name],[sort],[set_open],[kd],[kd2],[gate1],[sort1],[sorce]) values (N'自定义6',N'zdy6',2,0,75,75,15,25,15)

GO

--项目明细自定义字段，新增建议进价，建议总价
if not exists(select 1 from zdymx where sort1=3 and sorce=16) INSERT INTO [zdymx] ([title],[name],[sort],[set_open],[kd],[kd2],[gate1],[sort1],[sorce]) values (N'建议进价',N'pricejy',1,1,75,75,16,3,16)
if not exists(select 1 from zdymx where sort1=3 and sorce=17) INSERT INTO [zdymx] ([title],[name],[sort],[set_open],[kd],[kd2],[gate1],[sort1],[sorce]) values (N'建议总价',N'tpricejy',1,1,75,75,17,3,17)
update zdymx set title='交货日期' where title='到货日期' and sort1=3
--报价明细自定义字段，新增建议进价，建议总价
if not exists(select 1 from zdymx where sort1=4 and sorce=16) INSERT INTO [zdymx] ([title],[name],[sort],[set_open],[kd],[kd2],[gate1],[sort1],[sorce]) values (N'建议进价',N'pricejy',1,1,75,75,16,4,16)
if not exists(select 1 from zdymx where sort1=4 and sorce=17) INSERT INTO [zdymx] ([title],[name],[sort],[set_open],[kd],[kd2],[gate1],[sort1],[sorce]) values (N'建议总价',N'tpricejy',1,1,75,75,17,4,17)

--合同明细自定义字段，新增建议进价，建议总价
if not exists(select 1 from zdymx where sort1=5 and sorce=16) INSERT INTO [zdymx] ([title],[name],[sort],[set_open],[kd],[kd2],[gate1],[sort1],[sorce]) values (N'建议进价',N'pricejy',1,1,75,75,16,5,16)
if not exists(select 1 from zdymx where sort1=5 and sorce=17) INSERT INTO [zdymx] ([title],[name],[sort],[set_open],[kd],[kd2],[gate1],[sort1],[sorce]) values (N'建议总价',N'tpricejy',1,1,75,75,17,5,17)

GO

if exists(select 1 from plan1 where complete=7) begin
	insert into plan2(intro,gate,complete,sort1,date1,time1,time2,order1,intro2,cateid,cateid2,cateid3,company,person,option1,chance,lcb,contract,pay,date7,date4,date8,type)
	select intro,gate,complete,sort1,date1,time1,time2,order1,intro2,cateid,cateid2,cateid3,company,person,option1,chance,lcb,contract,pay,date7,date4,date8,1 from plan1 where complete=7
	delete from plan1 where complete=7
end
update zdymx set title='客户预收款' where title='客户预付款' and sort1=44
update zdymx set title='客户退预收款' where title='客户退预付款' and sort1=44
update bank set sort=2 where intro='采购付款' and sort=1
update gate set num_year=8,num_month=8,num_week=8 where num_year is null
if exists(select 1 from send where sh is null)UPDATE SEND SET sh=ISNULL((SELECT TOP 1 ord FROM person WHERE name=send.NAME AND company=SEND.company),0) WHERE sh IS null
if not exists(select 1 from email_status where softTime is not null)insert into email_status (softTime) values(getdate())
update paysq set ModifyStamp='' where ModifyStamp is null
update payjk set ModifyStamp='' where ModifyStamp is null
update paybx set ModifyStamp='' where ModifyStamp is null
update kuout set ModifyStamp='' where ModifyStamp is null
update contract set ModifyStamp='' where ModifyStamp is null
update contract_his set ModifyStamp='' where ModifyStamp is null
update tel set ModifyStamp='' where ModifyStamp is null
update tel_his set ModifyStamp='' where ModifyStamp is null
update caigou set ModifyStamp='' where ModifyStamp is null
if exists(select 1 from zdymx where name='money1' and sort=2)update zdymx set set_open=1,sort=1 where name='money1' and sort=2

GO

if exists(select 1 from zdybh where sort=2 and sort1=35 and set_open=0)update zdybh set set_open=1,intro1=4,intro2=2 where sort=2 and sort1=35
if exists(select 1 from zdybh where sort=3 and sort1=35 and set_open=0)update zdybh set set_open=1,intro1=2,intro2=2 where sort=3 and sort1=35
if exists(select 1 from zdybh where sort=4 and sort1=35 and set_open=0)update zdybh set set_open=1,intro1=2,intro2=2 where sort=4 and sort1=35
if exists(select 1 from zdybh where sort=5 and sort1=35 and set_open=0)update zdybh set set_open=1,intro1=3,intro2=2 where sort=5 and sort1=35
if exists(select 1 from zdybh where sort=2 and sort1=36 and set_open=0)update zdybh set set_open=1,intro1=4,intro2=2 where sort=2 and sort1=36
if exists(select 1 from zdybh where sort=3 and sort1=36 and set_open=0)update zdybh set set_open=1,intro1=2,intro2=2 where sort=3 and sort1=36
if exists(select 1 from zdybh where sort=4 and sort1=36 and set_open=0)update zdybh set set_open=1,intro1=2,intro2=2 where sort=4 and sort1=36
if exists(select 1 from zdybh where sort=5 and sort1=36 and set_open=0)update zdybh set set_open=1,intro1=3,intro2=2 where sort=5 and sort1=36
if not exists (select ord from sms_temp_sort where ord=1) insert into sms_temp_sort (ord,title,isopen,addTime,addcate,del) values(1,'销售合同待审批',0,'2012-4-16 17:24:54',63,1)
if not exists (select ord from sms_temp_sort where ord=2) insert into sms_temp_sort (ord,title,isopen,addTime,addcate,del) values(2,'合同转采购',0,'2012-4-16 17:24:54',63,1)
if not exists (select ord from sms_temp_sort where ord=3) insert into sms_temp_sort (ord,title,isopen,addTime,addcate,del) values(3,'入库',0,'2012-4-16 17:24:54',63,1)
if not exists (select ord from sms_temp_sort where ord=4) insert into sms_temp_sort (ord,title,isopen,addTime,addcate,del) values(4,'出库',0,'2012-4-16 17:24:54',63,1)
if not exists (select ord from sms_temp_sort where ord=5) insert into sms_temp_sort (ord,title,isopen,addTime,addcate,del) values(5,'发货',0,'2012-4-16 17:24:54',63,1)
if not exists (select ord from sms_temp_sort where ord=6) insert into sms_temp_sort (ord,title,isopen,addTime,addcate,del) values(6,'财务到账(客户)',0,'2012-4-16 17:24:54',63,1)
if not exists (select ord from sms_temp_sort where ord=7) insert into sms_temp_sort (ord,title,isopen,addTime,addcate,del) values(7,'销售合同审批通过',0,'2012-4-16 17:24:54',63,1)
if not exists (select ord from sms_temp_sort where ord=8) insert into sms_temp_sort (ord,title,isopen,addTime,addcate,del) values(8,'财务到账(业务)',0,'2012-4-16 17:24:54',63,1)
if not exists (select ord from sms_temp_sort where ord=9) insert into sms_temp_sort (ord,title,isopen,addTime,addcate,del) values(9,'身份验证（微信）',0,'2012-4-16 17:24:54',63,1)
if not exists (select ord from sms_temp_sort where ord=10) insert into sms_temp_sort (ord,title,isopen,addTime,addcate,del) values(10,'固定资产维护',0,'2017-8-16 17:24:54',63,1)
if not exists (select ord from sms_temp_sort where ord=11) insert into sms_temp_sort (ord,title,isopen,addTime,addcate,del) values(11,'发送电子发票',1,'2021-09-09 23:39:33.077',63,1)

if not exists (select ord from sms_replace_str where ord=1) insert into sms_replace_str (ord,title,replaceStr,sortID,addTime,addcate,del) values(1,'销售人员','$cateid',1,'2012-4-16 17:24:54',63,1)
if not exists (select ord from sms_replace_str where ord=2) insert into sms_replace_str (ord,title,replaceStr,sortID,addTime,addcate,del) values(2,'下级审批人','$sp',1,'2012-4-16 17:24:54',63,1)
if not exists (select ord from sms_replace_str where ord=3) insert into sms_replace_str (ord,title,replaceStr,sortID,addTime,addcate,del) values(3,'合同金额','$money',1,'2012-4-16 17:24:54',63,1)
if not exists (select ord from sms_replace_str where ord=4) insert into sms_replace_str (ord,title,replaceStr,sortID,addTime,addcate,del) values(4,'下级审批人ID','$sid',1,'2012-4-16 17:24:54',63,1)
if not exists (select ord from sms_replace_str where ord=5) insert into sms_replace_str (ord,title,replaceStr,sortID,addTime,addcate,del) values(5,'合同编号','$contract_bh',2,'2012-4-16 17:24:54',63,1)
if not exists (select ord from sms_replace_str where ord=6) insert into sms_replace_str (ord,title,replaceStr,sortID,addTime,addcate,del) values(6,'产品型号','$product_title',2,'2012-4-16 17:24:54',63,1)
if not exists (select ord from sms_replace_str where ord=7) insert into sms_replace_str (ord,title,replaceStr,sortID,addTime,addcate,del) values(7,'采购日期','$date',2,'2012-4-16 17:24:54',63,1)
if not exists (select ord from sms_replace_str where ord=8) insert into sms_replace_str (ord,title,replaceStr,sortID,addTime,addcate,del) values(8,'销售人员','$cateid',2,'2012-4-16 17:24:54',63,1)
if not exists (select ord from sms_replace_str where ord=9) insert into sms_replace_str (ord,title,replaceStr,sortID,addTime,addcate,del) values(9,'销售人员','$cateid',3,'2012-4-16 17:24:54',63,1)
if not exists (select ord from sms_replace_str where ord=10) insert into sms_replace_str (ord,title,replaceStr,sortID,addTime,addcate,del) values(10,'产品型号','$product_title',3,'2012-4-16 17:24:54',63,1)
if not exists (select ord from sms_replace_str where ord=11) insert into sms_replace_str (ord,title,replaceStr,sortID,addTime,addcate,del) values(11,'审批日期','$sp_date',3,'2012-4-16 17:24:54',63,1)
if not exists (select ord from sms_replace_str where ord=12) insert into sms_replace_str (ord,title,replaceStr,sortID,addTime,addcate,del) values(12,'下级审批人','$sp',3,'2012-4-16 17:24:54',63,1)
if not exists (select ord from sms_replace_str where ord=13) insert into sms_replace_str (ord,title,replaceStr,sortID,addTime,addcate,del) values(13,'出库主题','$title',4,'2012-4-16 17:24:54',63,1)
if not exists (select ord from sms_replace_str where ord=14) insert into sms_replace_str (ord,title,replaceStr,sortID,addTime,addcate,del) values(14,'型号','$product_title',4,'2012-4-16 17:24:54',63,1)
if not exists (select ord from sms_replace_str where ord=15) insert into sms_replace_str (ord,title,replaceStr,sortID,addTime,addcate,del) values(15,'审批人','$sp',4,'2012-4-16 17:24:54',63,1)
if not exists (select ord from sms_replace_str where ord=16) insert into sms_replace_str (ord,title,replaceStr,sortID,addTime,addcate,del) values(16,'发货人','$cateid',5,'2012-4-16 17:24:54',63,1)
if not exists (select ord from sms_replace_str where ord=17) insert into sms_replace_str (ord,title,replaceStr,sortID,addTime,addcate,del) values(17,'产品型号','$product_title',5,'2012-4-16 17:24:54',63,1)
if not exists (select ord from sms_replace_str where ord=18) insert into sms_replace_str (ord,title,replaceStr,sortID,addTime,addcate,del) values(18,'关联合同','$contract',5,'2012-4-16 17:24:54',63,1)
if not exists (select ord from sms_replace_str where ord=19) insert into sms_replace_str (ord,title,replaceStr,sortID,addTime,addcate,del) values(19,'关联合同','$contract',6,'2012-4-16 17:24:54',63,1)
if not exists (select ord from sms_replace_str where ord=20) insert into sms_replace_str (ord,title,replaceStr,sortID,addTime,addcate,del) values(20,'回款金额','$money',6,'2012-4-16 17:24:54',63,1)
if not exists (select ord from sms_replace_str where ord=21) insert into sms_replace_str (ord,title,replaceStr,sortID,addTime,addcate,del) values(21,'合同分类','$contract_type',6,'2012-4-16 17:24:54',63,1)
if not exists (select ord from sms_replace_str where ord=22) insert into sms_replace_str (ord,title,replaceStr,sortID,addTime,addcate,del) values(22,'合同编号','$contract_bh',1,'2012-4-16 17:24:54',63,1)
if not exists (select ord from sms_replace_str where ord=23) insert into sms_replace_str (ord,title,replaceStr,sortID,addTime,addcate,del) values(23,'关联客户','$company',2,'2012-4-16 17:24:54',63,1)
if not exists (select ord from sms_replace_str where ord=24) insert into sms_replace_str (ord,title,replaceStr,sortID,addTime,addcate,del) values(24,'关联客户','$company',3,'2012-4-16 17:24:54',63,1)
if not exists (select ord from sms_replace_str where ord=25) insert into sms_replace_str (ord,title,replaceStr,sortID,addTime,addcate,del) values(25,'当前日期','$now',0,'2012-4-16 17:24:54',63,1)
if not exists (select ord from sms_replace_str where ord=26) insert into sms_replace_str (ord,title,replaceStr,sortID,addTime,addcate,del) values(26,'当前用户','$creator',0,'2012-4-16 17:24:54',63,1)
if not exists (select ord from sms_replace_str where ord=27) insert into sms_replace_str (ord,title,replaceStr,sortID,addTime,addcate,del) values(27,'销售人员','$cateid',7,'2012-4-16 17:24:54',63,1)
if not exists (select ord from sms_replace_str where ord=28) insert into sms_replace_str (ord,title,replaceStr,sortID,addTime,addcate,del) values(28,'下级审批人','$sp',7,'2012-4-16 17:24:54',63,1)
if not exists (select ord from sms_replace_str where ord=29) insert into sms_replace_str (ord,title,replaceStr,sortID,addTime,addcate,del) values(29,'合同金额','$money',7,'2012-4-16 17:24:54',63,1)
if not exists (select ord from sms_replace_str where ord=30) insert into sms_replace_str (ord,title,replaceStr,sortID,addTime,addcate,del) values(30,'下级审批人ID','$sid',7,'2012-4-16 17:24:54',63,1)
if not exists (select ord from sms_replace_str where ord=31) insert into sms_replace_str (ord,title,replaceStr,sortID,addTime,addcate,del) values(31,'合同分类','$contract_type',8,'2012-4-16 17:24:54',63,1)
if not exists (select ord from sms_replace_str where ord=32) insert into sms_replace_str (ord,title,replaceStr,sortID,addTime,addcate,del) values(32,'关联合同','$contract',8,'2012-4-16 17:24:54',63,1)
if not exists (select ord from sms_replace_str where ord=33) insert into sms_replace_str (ord,title,replaceStr,sortID,addTime,addcate,del) values(33,'回款金额','$money',8,'2012-4-16 17:24:54',63,1)
if not exists (select ord from sms_replace_str where ord=34) insert into sms_replace_str (ord,title,replaceStr,sortID,addTime,addcate,del) values(34,'关联客户','$company',8,'2012-4-16 17:24:54',63,1)
if not exists (select ord from sms_replace_str where ord=35) insert into sms_replace_str (ord,title,replaceStr,sortID,addTime,addcate,del) values(35,'添加人','$addcate',8,'2012-4-16 17:24:54',63,1)
if not exists (select ord from sms_replace_str where ord=37) insert into sms_replace_str (ord,title,replaceStr,sortID,addTime,addcate,del) values(37,'销售人员','$cateid',4,'2012-4-16 17:24:54',63,1)
if not exists (select ord from sms_replace_str where ord=38) insert into sms_replace_str (ord,title,replaceStr,sortID,addTime,addcate,del) values(38,'合同分类','$contract_type',5,'2012-4-16 17:24:54',63,1)
if not exists (select ord from sms_replace_str where ord=39) insert into sms_replace_str (ord,title,replaceStr,sortID,addTime,addcate,del) values(39,'采购人员','$caigou',2,'2012-4-16 17:24:54',63,1)
if not exists (select ord from sms_replace_str where ord=40) insert into sms_replace_str (ord,title,replaceStr,sortID,addTime,addcate,del) values(40,'银行账户','$bank',6,'2012-4-16 17:24:54',63,1)
if not exists (select ord from sms_replace_str where ord=41) insert into sms_replace_str (ord,title,replaceStr,sortID,addTime,addcate,del) values(41,'审批结果','$result',7,'2012-4-16 17:24:54',63,1)
if not exists (select ord from sms_replace_str where ord=42) insert into sms_replace_str (ord,title,replaceStr,sortID,addTime,addcate,del) values(42,'产品名称','$product_Name',2,'2012-4-16 17:24:54',63,1)
if not exists (select ord from sms_replace_str where ord=43) insert into sms_replace_str (ord,title,replaceStr,sortID,addTime,addcate,del) values(43,'产品名称','$product_Name',3,'2012-4-16 17:24:54',63,1)
if not exists (select ord from sms_replace_str where ord=44) insert into sms_replace_str (ord,title,replaceStr,sortID,addTime,addcate,del) values(44,'产品名称','$product_Name',4,'2012-4-16 17:24:54',63,1)
if not exists (select ord from sms_replace_str where ord=45) insert into sms_replace_str (ord,title,replaceStr,sortID,addTime,addcate,del) values(45,'产品名称','$product_Name',5,'2012-4-16 17:24:54',63,1)
if not exists (select ord from sms_replace_str where ord=46) insert into sms_replace_str (ord,title,replaceStr,sortID,addTime,addcate,del) values(46,'公司','$company',1,'2012-4-16 17:24:54',63,1)
if not exists (select ord from sms_replace_str where ord=47) insert into sms_replace_str (ord,title,replaceStr,sortID,addTime,addcate,del) values(47,'回复提示','$msg',1,'2012-4-16 17:24:54',63,1)
if not exists (select ord from sms_replace_str where ord=48) insert into sms_replace_str (ord,title,replaceStr,sortID,addTime,addcate,del) values(48,'发货方式','$sendtype',5,'2013-10-29 17:24:54',63,1)
if not exists (select ord from sms_replace_str where ord=49) insert into sms_replace_str (ord,title,replaceStr,sortID,addTime,addcate,del) values(49,'微信用户','$wxuser',9,'2013-10-29 17:24:54',63,1)
if not exists (select ord from sms_replace_str where ord=50) insert into sms_replace_str (ord,title,replaceStr,sortID,addTime,addcate,del) values(50,'资产名称','$zcname',10,'2017-9-15 17:24:54',63,1)
if not exists (select ord from sms_replace_str where ord=51) insert into sms_replace_str (ord,title,replaceStr,sortID,addTime,addcate,del) values(51,'维护人员','$whcateid',10,'2017-9-15 17:24:54',63,1)
if not exists (select ord from sms_replace_str where ord=52) insert into sms_replace_str (ord,title,replaceStr,sortID,addTime,addcate,del) values(52,'维护时间','$whdate',10,'2017-9-15 17:24:54',63,1)
if not exists (select ord from sms_replace_str where ord=53) insert into sms_replace_str (ord,title,replaceStr,sortID,addTime,addcate,del) values(53,'维护内容','$whcontent',10,'2017-9-15 17:24:54',63,1)
if not exists (select ord from sms_replace_str where ord=54) insert into sms_replace_str (ord,title,replaceStr,sortID,addTime,addcate,del) values(54,'快递公司','$send_kdgs',5,'2018-9-17 19:15:00',63,1)
if not exists (select ord from sms_replace_str where ord=55) insert into sms_replace_str (ord,title,replaceStr,sortID,addTime,addcate,del) values(55,'快递单号','$send_kddh',5,'2018-9-17 19:15:00',63,1)
if not exists (select ord from sms_replace_str where ord=56) insert into sms_replace_str (ord,title,replaceStr,sortID,addTime,addcate,del) values(56,'快递费用','$send_kdfy',5,'2018-9-17 19:15:00',63,1)
if not exists (select ord from sms_replace_str where ord=57) insert into sms_replace_str (ord,title,replaceStr,sortID,addTime,addcate,del) values(57,'销售方名称','$XSF_MC',11,'2021-09-09 23:41:52.420',63,1)
if not exists (select ord from sms_replace_str where ord=58) insert into sms_replace_str (ord,title,replaceStr,sortID,addTime,addcate,del) values(58,'PDF文件地址','$PDF_URL',11,'2021-09-09 23:41:52.420',63,1)
if not exists (select ord from sms_replace_str where ord=59) insert into sms_replace_str (ord,title,replaceStr,sortID,addTime,addcate,del) values(59,'金额','$JSHJ',11,'2021-09-09 23:41:52.420',63,1)

if not exists (select ord from sms_temp where title='销售合同待审批') insert into sms_temp (title,content,sortID,isDefault,addTime,addcate,del) values('销售合同待审批','$contract_bh的销售合同需审批；公司：$company,金额:$money,签订日期:$contract_date,请回复$msg,$cateid',1,1,'2012-4-16 17:24:54',63,1)
if not exists (select ord from sms_temp where title='销售合同转采购') insert into sms_temp (title,content,sortID,isDefault,addTime,addcate,del) values('销售合同转采购','$contract_bh的产品已采购；$caigou',2,1,'2012-4-16 17:24:54',63,1)
if not exists (select ord from sms_temp where title='入库') insert into sms_temp (title,content,sortID,isDefault,addTime,addcate,del) values('入库','$company采购产品已到货；$cateid',3,1,'2012-4-16 17:24:54',63,1)
if not exists (select ord from sms_temp where title='出库') insert into sms_temp (title,content,sortID,isDefault,addTime,addcate,del) values('出库','$title已出库;$cateid',4,1,'2012-4-16 17:24:54',63,1)
if not exists (select ord from sms_temp where title='发货') insert into sms_temp (title,content,sortID,isDefault,addTime,addcate,del) values('发货','尊敬的客户：您从$contract_type订购的产品已发货;请联系物流部',5,1,'2012-4-16 17:24:54',63,1)
if not exists (select ord from sms_temp where title='财务到账(业务)') insert into sms_temp (title,content,sortID,isDefault,addTime,addcate,del) values('财务到账(客户)','尊敬的客户您好！已收到贵公司支付的货款$money;$contract_type财务',6,1,'2012-4-16 17:24:54',63,1)
if not exists (select ord from sms_temp where title='销售合同审批通过') insert into sms_temp (title,content,sortID,isDefault,addTime,addcate,del) values('销售合同审批通过','$cateid$money的销售合同已经$result;$sp',7,1,'2012-4-16 17:24:54',63,1)
if not exists (select ord from sms_temp where title='财务到账(业务)') insert into sms_temp (title,content,sortID,isDefault,addTime,addcate,del) values('财务到账(业务)','$company货款$money已到$account;$addcate',8,1,'2012-4-16 17:24:54',63,1)
if not exists (select ord from sms_temp where title='固定资产维护') insert into sms_temp (title,content,sortID,isDefault,addTime,addcate,del) values('固定资产维护','$whcateid于$whdate对固定资产[$zcname]，进行维护，维护内容如下：$whcontent',10,1,'2017-9-15 17:24:54',63,1)
if not exists (select ord from sms_temp where title='发送电子发票') insert into sms_temp (title,content,sortID,isDefault,addTime,addcate,del) values('发送电子发票','$now，$XSF_MC已为您开具了电子票，金额=$JSHJ元，请到$PDF_URL查看。',11,1,'2021-09-09 23:36:23.883',63,1)
if  exists (select ord from sms_temp where title='销售合同待审批' and content like '$contract_bh的销售合同需审批；$cateid') update sms_temp set content='$contract_bh的销售合同需审批；公司：$company,金额:$money,签订日期:$contract_date,请回复$msg,$cateid' where  title='销售合同待审批' and content like '$contract_bh的销售合同需审批；$cateid'
update a set a.gj1=b.sort, a.gj2=b.sort1  from reply a inner join tel b on a.sort1=1 and a.ord=b.ord and (isnull(a.gj1,0)<>b.sort or isnull(a.gj2,0)<>b.sort1)
if not exists (select ord from sms_temp where title='用户身份验证') insert into sms_temp (title,content,sortID,isDefault,addTime,addcate,del) values('用户身份验证','尊敬的客户: $wxuser您好，本次验证通过，感谢您光临本公司的微信商城，祝您购物愉快！',9,1,'2012-4-16 17:24:54',63,1)
if not exists(select 1 from zdy where sort1=802) begin insert into zdy(title,name,sort,gl,set_open,js,dc,dr,tj,gate1,sort1) values('自定义1','zdy1',2,0,0,1,1,0,0,1,802); insert into zdy(title,name,sort,gl,set_open,js,dc,dr,tj,gate1,sort1) values('自定义2','zdy2',2,0,0,1,1,0,0,2,802); insert into zdy(title,name,sort,gl,set_open,js,dc,dr,tj,gate1,sort1) values('自定义3','zdy3',2,0,0,1,1,0,0,3,802); insert into zdy(title,name,sort,gl,set_open,js,dc,dr,tj,gate1,sort1) values('自定义4','zdy4',2,0,0,1,1,0,0,4,802); insert into zdy(title,name,sort,gl,set_open,js,dc,dr,tj,gate1,sort1) values('自定义5','zdy5',1,4100,0,1,1,0,0,5,802); insert into zdy(title,name,sort,gl,set_open,js,dc,dr,tj,gate1,sort1) values('自定义6','zdy6',1,4101,0,1,1,0,0,6,802); end
if not exists(select 1 from zdy where sort1=804) begin insert into zdy(title,name,sort,gl,set_open,js,dc,dr,tj,gate1,sort1) values('自定义1','zdy1',2,0,1,1,1,0,0,1,804); insert into zdy(title,name,sort,gl,set_open,js,dc,dr,tj,gate1,sort1) values('自定义2','zdy2',2,0,1,1,1,0,0,2,804); insert into zdy(title,name,sort,gl,set_open,js,dc,dr,tj,gate1,sort1) values('自定义3','zdy3',2,0,1,1,1,0,0,3,804); insert into zdy(title,name,sort,gl,set_open,js,dc,dr,tj,gate1,sort1) values('自定义4','zdy4',2,0,1,1,1,0,0,4,804); insert into zdy(title,name,sort,gl,set_open,js,dc,dr,tj,gate1,sort1) values('自定义5','zdy5',1,4105,1,1,1,0,0,5,804); insert into zdy(title,name,sort,gl,set_open,js,dc,dr,tj,gate1,sort1) values('自定义6','zdy6',1,4106,1,1,1,0,0,6,804); end
if not exists(select 1 from zdy where sort1=803) begin insert into zdy(title,name,sort,gl,set_open,js,dc,dr,tj,gate1,sort1) values('自定义1','zdy1',2,0,1,1,1,0,0,1,803); insert into zdy(title,name,sort,gl,set_open,js,dc,dr,tj,gate1,sort1) values('自定义2','zdy2',2,0,1,1,1,0,0,2,803); insert into zdy(title,name,sort,gl,set_open,js,dc,dr,tj,gate1,sort1) values('自定义3','zdy3',2,0,1,1,1,0,0,3,803); insert into zdy(title,name,sort,gl,set_open,js,dc,dr,tj,gate1,sort1) values('自定义4','zdy4',2,0,1,1,1,0,0,4,803); insert into zdy(title,name,sort,gl,set_open,js,dc,dr,tj,gate1,sort1) values('自定义5','zdy5',2,0,1,1,1,0,0,5,803); insert into zdy(title,name,sort,gl,set_open,js,dc,dr,tj,gate1,sort1) values('自定义6','zdy6',2,0,1,1,1,0,0,6,803); insert into zdy(title,name,sort,gl,set_open,js,dc,dr,tj,gate1,sort1) values('自定义7','zdy7',1,4107,1,1,1,0,0,7,803); insert into zdy(title,name,sort,gl,set_open,js,dc,dr,tj,gate1,sort1) values('自定义8','zdy8',1,4103,1,1,1,0,0,8,803); insert into zdy(title,name,sort,gl,set_open,js,dc,dr,tj,gate1,sort1) values('自定义9','zdy9',3,0,1,1,1,0,0,9,803); end
if not exists(select 1 from O_assStateType where id=1)INSERT INTO O_assStateType(sort1,gate1,del,ParentID,StoreCode,Depth,isLeef,RootID) VALUES('使用中',1,1,0,'',0,1,1)
if not exists(select 1 from O_assStateType where id=2)INSERT INTO O_assStateType(sort1,gate1,del,ParentID,StoreCode,Depth,isLeef,RootID) VALUES('未使用',2,1,0,'',0,1,2)
if not exists(select 1 from O_assStatename where id=1)INSERT INTO O_assStatename(ord,sort1,intro,gate1,ls,sort,del,StoreCode,StoreComment) VALUES(1,'启用','',1,-1,1,1,'','')
if not exists(select 1 from O_assStatename where id=2)INSERT INTO O_assStatename(ord,sort1,intro,gate1,ls,sort,del,StoreCode,StoreComment) VALUES(2,'借出','',2,-1,1,1,'','')
if not exists(select 1 from O_assStatename where id=3)INSERT INTO O_assStatename(ord,sort1,intro,gate1,ls,sort,del,StoreCode,StoreComment) VALUES(3,'停用','',3,-1,2,0,'','')
if not exists(select 1 from O_assStatename where id=4)INSERT INTO O_assStatename(ord,sort1,intro,gate1,ls,sort,del,StoreCode,StoreComment) VALUES(4,'清理','',4,-1,2,0,'','')
if not exists(select 1 from O_assStatename where id=5)INSERT INTO O_assStatename(ord,sort1,intro,gate1,ls,sort,del,StoreCode,StoreComment) VALUES(5,'报废','',5,-1,2,0,'','')
if not exists (select id from hr_KQClass where id=1) insert into hr_KQClass (id,title,creator,sortID,del,isapp,isprice) values(1,'请假',63,0,0,0,0)
if not exists (select id from hr_KQClass where id=2) insert into hr_KQClass (id,title,creator,sortID,del,isapp,isprice) values(2,'加班',63,0,0,0,0)
if not exists (select id from hr_KQClass where id=3) insert into hr_KQClass (id,title,creator,sortID,del,isapp,isprice) values(3,'外勤',63,0,0,0,0)
if not exists (select id from hr_KQClass where id=4) insert into hr_KQClass (id,title,creator,sortID,del,isapp,isprice) values(4,'调休',63,0,0,0,0)
if not exists (select id from hr_KQClass where id=5) insert into hr_KQClass (id,title,creator,sortID,del,isapp,isprice) values(5,'考勤结果',63,0,0,0,0)
if not exists (select id from hr_KQClass where id=6) insert into hr_KQClass (id,title,creator,sortID,del,isapp,isprice,UnitType) values(6,'迟到',63,5,0,0,1,1)
if not exists (select id from hr_KQClass where id=7) insert into hr_KQClass (id,title,creator,sortID,del,isapp,isprice,UnitType) values(7,'早退',63,5,0,0,1,1)
if not exists (select id from hr_KQClass where id=8) insert into hr_KQClass (id,title,creator,sortID,del,isapp,isprice,UnitType) values(8,'缺勤',63,5,0,0,1,1)
if not exists (select id from hr_KQClass where id=14) insert into hr_KQClass (id,title,creator,sortID,del,isapp,isprice) values(14,'异常',63,5,0,0,0)
if not exists (select id from hr_KQClass where id=15) insert into hr_KQClass (id,title,creator,sortID,del,isapp,isprice) values(15,'正常',63,5,0,0,0)
if not exists (select id from hr_KQClass where id=16) insert into hr_KQClass (id,title,creator,sortID,del,isapp,isprice) values(16,'迟到 早退',63,5,0,0,0)
if not exists (select id from hr_KQClass where id=18) insert into hr_KQClass (id,title,creator,sortID,del,isapp,isprice) values(18,'休息',63,5,0,0,0)
if not exists (select id from hr_KQClass where id=19) insert into hr_KQClass (id,title,creator,sortID,del,isapp,isprice) values(19,'放假',63,5,0,0,0)
if not exists (select id from hr_KQClass where id=20) insert into hr_KQClass (id,title,creator,sortID,del,isapp,isprice) values(20,'节假日调班',63,5,0,0,0)
update hr_KQClass set del=1 where (id=4 or id=5) and del=0
delete from hr_KQClass where id in (9,10,11,12,13,17) and indate is null

GO

if exists(select 1 from reply2 where del<>33)INSERT INTO reply(ord,ord2,sort1,gj1,gj2,name,NAME2,intro,cateid,cateid2,cateid3,time1,date7,del,plan1,id1)SELECT isnull(c.ord,0),a.ord,8,isnull(c.gj1,0),isnull(c.gj2,0),a.name,isnull(d.name,''),a.intro,isnull(b.ord,0),isnull(b.sorce,0),isnull(b.sorce2,0),DATEPART(mi,a.date7),a.date7,a.del,isnull(a.plan1,0),isnull(a.ord2,0) FROM reply2 a LEFT JOIN gate b ON a.NAME=b.name AND b.del=1 LEFT JOIN reply c ON c.id=a.ord2 LEFT JOIN person d ON d.ord=a.ord where a.del<>33
if exists(select 1 from reply2 where del<>33)update reply2 set del=33 where del<>33
if exists(select 1 from reply where sort1=8 and ord=0 and ord2>0)update reply set ord=isnull((select isnull(company,0) from person where ord=reply.ord2),0) where sort1=8 and ord=0 and ord2>0
if exists(select 1 from kujhlist where date7<='2012-4-16 23:59:59' and alt=0)update kujhlist set alt=1 where date7<='2012-4-16 23:59:59' and alt=0
if exists(select 1 from contract where addshare is null)update contract set addshare=0 where addshare is null
if exists(select 1 from gate where num_1>9999)update gate set num_1=9999 where num_1>9999
if exists(select 1 from gate where num_2>9999)update gate set num_2=9999 where num_2>9999
if exists(select 1 from gate where num_3>9999)update gate set num_3=9999 where num_3>9999
if exists(select 1 from contractth where zt1 is null) update contractth set zt1=0 where zt1 is null

GO

update caigouth set ModifyStamp='' where ModifyStamp is null
update caigouth set thperson=addcate where thperson is null
update caigouth set PersonID=isnull((select top 1 ord from gate where name=caigouth.Person1),0) where PersonID is null
update caigouth set FromModel=0 where FromModel is null
update send set ModifyStamp='' where ModifyStamp is null
update kuhhlist set kuinlist=isnull((SELECT isnull(max(id),0) as id FROM kuinlist WHERE sort1=6 AND kuoutlist2 IN (SELECT isnull(max(id),0) AS id FROM kuoutlist2 WHERE sort1=6 AND contractlist IN (SELECT isnull(max(jhid),0) AS jhid FROM kuhhlist a where a.id=kuhhlist.id))),0) where kuinlist is null or kuinlist=0
update kuhhlist set ck=isnull((select isnull(ku,0) as ku from kuinlist where id=kuhhlist.kuinlist),0) where ck is null or ck=0

GO
--采购退货策略初始化
if not exists(select 1 from setopen where sort1=2020071601) begin insert into setopen(intro,sort1) values (1,2020071601) end
if not exists(select 1 from setopen where sort1=2020071602) begin insert into setopen(intro,sort1) values (1,2020071602) end
if not exists(select 1 from setopen where sort1=2020071603) begin insert into setopen(intro,sort1) values (1,2020071603) end
GO

if exists(select top 1 ord from product where del<>7 and (unit='' or unit is null)) update product set unit=unitjb where del<>7 and (unit='' or unit is null)

GO

if exists(select top 1 ord from product where del=1 and (title is null or title='')) update product set title='产品异常' where del=1 and (title is null or title='')

GO

delete jiage where not exists (select top 1 1 from product a where a.ord = abs(jiage.product))

GO

delete jiage where unit=0 or unit is null

GO

update jiage set price3=0 where price3 is null

GO

update jiage set bl=1 where isnull(bl,0) = 0

GO

if exists(
    select product
    from
    (
        select product, unit from jiage with(nolock) where cgmainunit=1 group by product,unit 
    ) a group by product having count(1)>1
)
begin 
    update a set a.cgMainUnit = 0
    from jiage a
    where a.product in (select product from (select product, unit from jiage with(nolock) where cgmainunit=1 group by product,unit) a group by product having count(1)>1)
     and not exists(
        select j.product, j.unit
        from (
	            select min(j.id) id
	            from  (
		            select product from (select product, unit from jiage with(nolock) where cgmainunit=1 group by product,unit) a group by product having count(1)>1
	            ) a 
	            inner join jiage j  with(nolock) on j.product = a.product and j.cgmainunit=1
        ) b 
        inner join jiage j  with(nolock) on j.id = b.id
        where j.product = a.product and j.unit = a.unit
    )
end 

GO

if not exists (select 1 from hr_process where cnID=1 and orderID=1021 and del=0)insert into [hr_process]( [cnID], [orderID], [title], [px], [sortID], [indate], [creator], [del], [content])values(1,1021,'招聘中',1,0,'2012-4-16 17:24:55',63,0,'')
if not exists (select 1 from hr_process where cnID=2 and orderID=1021 and del=0)insert into [hr_process]( [cnID], [orderID], [title], [px], [sortID], [indate], [creator], [del], [content])values(2,1021,'招聘结束',2,0,'2012-4-16 17:24:55',63,0,'')
if not exists (select 1 from hr_process where cnID=1 and orderID=1023 and del=0)insert into [hr_process]( [cnID], [orderID], [title], [px], [sortID], [indate], [creator], [del], [content])values(1,1023,'生效中',1,0,'2012-4-16 17:24:55',63,0,'')
if not exists (select 1 from hr_process where cnID=2 and orderID=1023 and del=0)insert into [hr_process]( [cnID], [orderID], [title], [px], [sortID], [indate], [creator], [del], [content])values(2,1023,'已废除',2,0,'2012-4-16 17:24:55',63,0,'')
if not exists(select 1 from O_BookField)--BUG.7372.ZYF.2015-3-11.增加图书分类信息
begin
	declare @O_BookField_name nvarchar(300), @O_BookField_setsort varchar(100), @O_BookField_setopen varchar(100), @O_BookField_sort1 varchar(100); 
	set @O_BookField_name = '书名,编号,分类,借阅周期,作者,出版时间,出版社,版次,页数,字数,印刷时间,开本,纸张,印次,ISBN,装帧,单价,可借阅数量,总价,存放位置,添加人员,添加时间,借阅数量,借阅时间,归还时间,图书备注'
	set @O_BookField_setsort = '2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,2,2,2'
	set @O_BookField_setopen = '3,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,3,3,3,3'
	set @O_BookField_sort1 = '1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26'
	insert into O_BookField (name,setopen,sort1,setsort)
		select 
			f_name.short_str name, f_Open.short_str setopen, f_sort1.short_str sort1, f_sort.short_str setsort
			from dbo.split(@O_BookField_name,',') f_name
			left join dbo.split(@O_BookField_setsort,',') f_sort on f_sort.ID = f_name.ID
			left join dbo.split(@O_BookField_setopen,',') f_Open on f_Open.ID = f_name.ID
			left join dbo.split(@O_BookField_sort1,',') f_sort1 on f_sort1.ID = f_name.ID
end
update O_BookField set name='可借阅数量' where name='借阅数量' and id<20
update O_BookField set name='借阅数量' where name='数量' and id>20
if exists(select 1 from reply where share is null)update reply set share='0' where share is null
update sortonehy set del=1 where gate2=41 and del is null
update paytype set del=1 where del is null
if exists(select top 1 id from kuoutlist2 where company is null and sort1=7)update kuoutlist2 set company=0 where company is null and sort1=7

GO

if exists(select top 1 id from kuoutlist2 where contractlist is null and sort1=7)update kuoutlist2 set contractlist=0 where contractlist is null and sort1=7
if exists(select top 1 id from kuoutlist2 where kuoutlist is null and sort1=7)update kuoutlist2 set kuoutlist=0 where kuoutlist is null and sort1=7
if exists(select top 1 ord from kuout where fh1 is null and del=1)update kuout set fh1=0 where fh1 is null and del=1
if exists(select top 1 ord from kuout where cateid2 is null and cateid>0 and del=1)update kuout set cateid2=isnull((select isnull(sorce,0) from gate where ord=kuout.cateid),0) where cateid2 is null and cateid>0 and del=1
if exists(select top 1 ord from kuout where cateid3 is null and cateid>0 and del=1)update kuout set cateid3=isnull((select isnull(sorce2,0) from gate where ord=kuout.cateid),0) where cateid3 is null and cateid>0 and del=1
if exists(select top 1 id from kuinlist where company is null and sort1=7)update kuinlist set company=0 where company is null and sort1=7
if exists(select top 1 id from kuinlist where sort is null and sort1=7)update kuinlist set sort=7 where company is null and sort1=7
if exists(select top 1 ord from kuin where ck is null and sort1=7 and del=1)update kuin set ck=0 where ck is null and del=1
if exists(select top 1 ord from kuin where sort is null and sort1=7 and del=1)update kuin set sort=7 where sort is null and sort1=7 and del=1
if exists(select top 1 ord from kuin where cateid2 is null and cateid>0 and del=1)update kuin set cateid2=isnull((select isnull(sorce,0) from gate where ord=kuin.cateid),0) where cateid2 is null and cateid>0 and del=1
if exists(select top 1 ord from kuin where cateid3 is null and cateid>0 and del=1)update kuin set cateid3=isnull((select isnull(sorce2,0) from gate where ord=kuin.cateid),0) where cateid3 is null and cateid>0 and del=1

GO

update kumove set ModifyStamp='' where ModifyStamp is null
update wages set ModifyStamp='' where ModifyStamp is null
update payback set ModifyStamp='' where ModifyStamp is null
update payout set ModifyStamp='' where ModifyStamp is null
update payout2 set ModifyStamp='' where ModifyStamp is null
update payout3 set ModifyStamp='' where ModifyStamp is null
update payback set op=0 where op is null
update payout set op=0 where op is null
update payout2 set op=0 where op is null
update payout3 set op=0 where op is null
Update price set date1=date7  where date1 is NULL  or date1=''

GO

if not exists(select top 1 SettingIndex from GatherRegistration where SettingIndex=87401) insert into GatherRegistration values(87401,'通话列表','call/event.asp')
if not exists(select top 1 SettingIndex from GatherRegistration where SettingIndex=80003) insert into GatherRegistration values(80003,'汇总表','hrm/appHolidayhz.asp')
if not exists(select top 1 SettingIndex from GatherRegistration where SettingIndex=80004) insert into GatherRegistration values(80004,'汇总表','hrm/appHolidayhz.asp')
if not exists(select top 1 SettingIndex from GatherRegistration where SettingIndex=80005) insert into GatherRegistration values(80005,'汇总表','hrm/appHolidayhz.asp')
if not exists(select top 1 SettingIndex from GatherRegistration where SettingIndex=80001) insert into GatherRegistration values(80001,'考勤汇总表','hrm/kqClasshz.asp')
if not exists(select top 1 SettingIndex from GatherRegistration where SettingIndex=80002) insert into GatherRegistration values(80002,'员工档案列表','hrm/personList.asp')
if not exists(select top 1 SettingIndex from GatherRegistration where SettingIndex=80006) insert into GatherRegistration values(80006,'工资表','HrWages/content.asp')
if not exists(select top 1 SettingIndex from GatherRegistration where SettingIndex=2301) insert into GatherRegistration values(2301,'产品库存列表','../../SYSN/view/store/inventory/InventorySummary.ashx')
if not exists(select top 1 SettingIndex from GatherRegistration where SettingIndex=2302) insert into GatherRegistration values(2302,'产品库存列表','../../SYSN/view/store/inventory/InventorySummary.ashx')
if not exists(select top 1 SettingIndex from GatherRegistration where SettingIndex=1001) insert into GatherRegistration values(1001,'采购供货汇总表','tongji/caigou_gather.asp')
if not exists(select top 1 SettingIndex from GatherRegistration where SettingIndex=1002) insert into GatherRegistration values(1002,'采购利润明细表','tongji/caigou_profits.asp')
if not exists(select top 1 SettingIndex from GatherRegistration where SettingIndex=1006) insert into GatherRegistration values(1006,'供应商供货汇总表','tongji/company_gather.asp')
if not exists(select top 1 SettingIndex from GatherRegistration where SettingIndex=1007) insert into GatherRegistration values(1007,'供应商利润表','tongji/company_profits.asp')
if not exists(select top 1 SettingIndex from GatherRegistration where SettingIndex=87701) insert into GatherRegistration values(87701,'邮件统计汇总','tongji/hzemail.asp')
if not exists(select top 1 SettingIndex from GatherRegistration where SettingIndex=2303) insert into GatherRegistration values(2303,'库存变动汇总表','tongji/hzkc3_hz.asp')
if not exists(select top 1 SettingIndex from GatherRegistration where SettingIndex=2304) insert into GatherRegistration values(2304,'库存变动明细表','tongji/hzkc3_hz.asp')
if not exists(select top 1 SettingIndex from GatherRegistration where SettingIndex=1101) insert into GatherRegistration values(1101,'客户利润总额排行','tongji/kh_jx7.asp')
if not exists(select top 1 SettingIndex from GatherRegistration where SettingIndex=1003) insert into GatherRegistration values(1003,'产品利润汇总表','tongji/product_gather.asp')
if not exists(select top 1 SettingIndex from GatherRegistration where SettingIndex=1005) insert into GatherRegistration values(1005,'产品采购销售一览表','tongji/product_GeneralView.asp')
if not exists(select top 1 SettingIndex from GatherRegistration where SettingIndex=1004) insert into GatherRegistration values(1004,'产品利润明细表','tongji/product_ProfitsList.asp')
if not exists(select top 1 SettingIndex from GatherRegistration where SettingIndex=1008) insert into GatherRegistration values(1008,'产品采购明细表','tongji/productPurchase.asp')
if not exists(select top 1 SettingIndex from GatherRegistration where SettingIndex=5001) insert into GatherRegistration values(5001,'库存台帐','tongji/yptong1.asp')
if not exists(select top 1 SettingIndex from GatherRegistration where SettingIndex=5002) insert into GatherRegistration values(5002,'库存预警','tongji/yptong2.asp')
if not exists(select top 1 SettingIndex from GatherRegistration where SettingIndex=5003) insert into GatherRegistration values(5003,'用品日志','tongji/yptong3.asp')
if not exists(select top 1 SettingIndex from GatherRegistration where SettingIndex=5004) insert into GatherRegistration values(5004,'车辆日志','car/List_BB2.asp')
if not exists(select top 1 SettingIndex from GatherRegistration where SettingIndex=5005) insert into GatherRegistration values(5005,'图书日志','book/List_BB2.asp')
if not exists(select top 1 SettingIndex from GatherRegistration where SettingIndex=5006) insert into GatherRegistration values(5006,'资产台账','asset/List_BB5.asp')
if not exists(select top 1 SettingIndex from GatherRegistration where SettingIndex=80007) insert into GatherRegistration values(80007,'招聘完成比例','hrm/hzResume.asp')
if not exists(select top 1 SettingIndex from GatherRegistration where SettingIndex=80008) insert into GatherRegistration values(80008,'岗位招聘完成比例','hrm/hzPostion.asp')
if not exists(select top 1 SettingIndex from GatherRegistration where SettingIndex=80009) insert into GatherRegistration values(80009,'公司离职比例','hrm/hzPersonLeave.asp')
if not exists(select top 1 SettingIndex from GatherRegistration where SettingIndex=80010) insert into GatherRegistration values(80010,'员工培训完成率','hrm/hzTrain.asp')
if not exists(select top 1 SettingIndex from GatherRegistration where SettingIndex=80011) insert into GatherRegistration values(80011,'即将转正列表','hrm/HzAltPos.asp')
if not exists(select top 1 SettingIndex from GatherRegistration where SettingIndex=80012) insert into GatherRegistration values(80012,'待体检档案列表','hrm/HzAltTj.asp')
if not exists(select top 1 SettingIndex from GatherRegistration where SettingIndex=80013) insert into GatherRegistration values(80013,'即将到期的员工合同','hrm/HzAltcontract.asp')
if not exists(select top 1 SettingIndex from GatherRegistration where SettingIndex=80014) insert into GatherRegistration values(80014,'客户产品出库对比表','tongji/CustomerSalesContrast.asp')
if not exists(select top 1 SettingIndex from GatherRegistration where SettingIndex=80015) insert into GatherRegistration values(80015,'客户产品出库明细表','tongji/CustomerSalesList.asp')
if not exists(select top 1 SettingIndex from GatherRegistration where SettingIndex=80016) insert into GatherRegistration values(80016,'数据备份','manager/db_bak.asp')

GO
delete from home_mainlink_config where id <= 80 and uid=0 and role=0
insert into home_mainlink_config(id,role,uid,title,url,otype,icodata,icosize,icotype,icoId,icourl,sort,gpname,del,intro,powerCode)
select 1,0,0,'日程','sys:../china/tophome2.asp',2,NULL,0,0,0,'../skin/default/images/child/office/Ico_rc_01.gif',1,'常用办公',0,'','{31000}+[71,19]+[71,1]'
union all select 2,0,0,'日程提醒','sys:../plan/option.asp?s=1',2,NULL,0,0,0,'../skin/default/images/child/office/Ico_rc_02.gif',2,'常用办公',0,'','{31000}+[71,19]+[71,1]'
union all select 5,0,0,'公司公告','sys:../learntz/edit.asp',2,NULL,0,0,0,'../skin/default/images/child/office/Ico_gg_02.gif',5,'常用办公',0,'','{30000}+[72,19]+[72,1]'
union all select 6,0,0,'工作互动','sys:../learnhd/edit.asp',2,NULL,0,0,0,'../skin/default/images/child/office/Ico_hd_02.gif',6,'常用办公',0,'','{29000}+[73,19]+[73,1]'
union all select 7,0,0,'备忘录','sys:../notebook/add.asp',2,NULL,0,0,0,'../skin/default/images/child/office/Ico_gj_02.gif',7,'常用办公',0,'','{28000}+{28003}'
union all select 8,0,0,'知识库','sys:../learn/all.asp',2,NULL,0,0,0,'../skin/default/images/child/office/Ico_gj_03.gif',8,'常用办公',0,'','{28000}+{28002}'
union all select 9,0,0,'通讯录','sys:../tongxl/tongxladd.asp',2,NULL,0,0,0,'../skin/default/images/child/office/Ico_gj_04.gif',9,'常用办公',0,'','{28000}'

union all select 10,0,0,'客户添加','sys:../work/add.asp',2,NULL,0,0,0,'../skin/default/images/child/sale/Ico_kh_01.gif',10,'常用栏目',0,'','{1001}+[1,13]+[1,19]'
union all select 11,0,0,'客户列表','sys:../work/telhy.asp',2,NULL,0,0,0,'../skin/default/images/child/sale/Ico_kh_04.gif',11,'常用栏目',0,'','{1001}+[1,1]+[1,19]'
union all select 12,0,0,'客户分布','sys:mReportSearch.asp?id=2',2,NULL,0,0,0,'../skin/default/images/child/sale/Ico_kh_05.gif',12,'常用栏目',0,'','{1000}+{1001}+[1,19]'
union all select 13,0,0,'合同添加','sys:../../SYSN/view/sales/contract/contract.ashx',2,NULL,0,0,0,'../skin/default/images/child/sale/Ico_ht_01.gif',13,'常用栏目',0,'','{7000}+[5,13]+[5,19]'
union all select 14,0,0,'销售开单','sys:../../SYSN/view/sales/contract/contractkd.ashx',2,NULL,0,0,0,'../skin/default/images/child/sale/Ico_ht_06.gif',14,'常用栏目',0,'','{6000}+[5,20]+[5,19]'
union all select 15,0,0,'合同列表','sys:../contract/planall.asp',2,NULL,0,0,0,'../skin/default/images/child/sale/Ico_ht_04.gif',15,'常用栏目',0,'','{7000}+[5,1]+[5,19]'
union all select 16,0,0,'项目添加','sys:../chance/add.asp',2,NULL,0,0,0,'../skin/default/images/child/sale/Ico_xm_01.gif',16,'常用栏目',0,'','{3000}+[3,13]+[3,19]'
union all select 17,0,0,'项目列表','sys:../chance/result.asp',2,NULL,0,0,0,'../skin/default/images/child/sale/Ico_xm_04.gif',17,'常用栏目',0,'','{3000}+[3,1]+[3,19]'
union all select 18,0,0,'采购添加','sys:../../SYSN/view/store/caigou/caigou.ashx',2,NULL,0,0,0,'../skin/default/images/child/store/Ico_cg_03.gif',18,'常用栏目',0,'','{15000}+[22,13]+[22,19]'
union all select 19,0,0,'待入库单','sys:../store/planall2.asp?a=1',2,NULL,0,0,0,'../skin/default/images/child/store/Ico_rk_01.gif',19,'常用栏目',0,'','{17000}+[31,16]+[31,19]'
union all select 20,0,0,'待出库单','sys:../../SYSN/view/store/kuout/List.ashx?ckzt=-1,1',2,NULL,0,0,0,'../skin/default/images/child/store/Ico_ck_01.gif',20,'常用栏目',0,'','{17000}+[32,16]+[32,19]'
union all select 21,0,0,'库存列表','sys:../../SYSN/view/store/inventory/InventorySummary.ashx',2,NULL,0,0,0,'../skin/default/images/child/store/Ico_ch_05.gif',21,'常用栏目',0,'','{17000}+[23,11]+[23,19]'
union all select 22,0,0,'库存预警','sys:../store/aleat.asp',2,NULL,0,0,0,'../skin/default/images/child/store/Ico_ch_06.gif',22,'常用栏目',0,'','{17000}+[23,13]+[23,19]'
union all select 23,0,0,'发货检索','sys:../sent/planall.asp',2,NULL,0,0,0,'../skin/default/images/child/store/Ico_fh_03.gif',23,'常用栏目',0,'','({17000}+{17008})+[33,1]+[33,19]'
union all select 24,0,0,'生产订单','sys:../manufacture/inc/Bill.asp?orderid=2',2,NULL,0,0,0,'../skin/default/images/child/Manufacture/Ico_dd_01.gif',24,'常用栏目',0,'','{18000}+[51,13]+[51,19]'
union all select 25,0,0,'生产派工','sys:../manufacture/inc/Bill.asp?orderid=8',2,NULL,0,0,0,'../skin/default/images/child/Manufacture/Ico_xd_03.gif',25,'常用栏目',0,'','{18000}+[54,13]+[54,19]'
union all select 26,0,0,'现金银行','sys:../bank/planall.asp',2,NULL,0,0,0,'../skin/default/images/child/bank/Ico_fy_05.gif',26,'常用栏目',0,'','{19000}+[11,1]+[11,19]'
union all select 27,0,0,'应收账款','sys:../money/planall2.asp?A=1',2,NULL,0,0,0,'../skin/default/images/child/bank/Ico_sk_01.gif',27,'常用栏目',0,'','{23000}+[7,1]+[7,19]'
union all select 28,0,0,'应付账款','sys:../money2/planall2.asp?A=1',2,NULL,0,0,0,'../skin/default/images/child/bank/Ico_fk_02.gif',28,'常用栏目',0,'','{24000}+[8,1]+[8,19]'
union all select 29,0,0,'费用报销','sys:../pay/add.asp',2,NULL,0,0,0,'../skin/default/images/child/bank/Ico_fy_03.gif',29,'常用栏目',0,'','{27000}+[6,13]+[6,19]'
union all select 30,0,0,'工资查询','sys:../wages/planall.asp?a=1',2,NULL,0,0,0,'../skin/default/images/child/bank/Ico_gz_03.gif',30,'常用栏目',0,'','{26000}+[10,1]+[10,19]'

union all select 31,0,0,'利润总额排行','sys:../tongji/kh_jx7.asp',2,NULL,0,0,0,'../skin/default/images/child/store/Ico_gys_04.gif',31,'数据分析',0,'','({10000}+{70000}+{270000}+{80000})+[1,11]'
union all select 32,0,0,'销售利润统计','sys:../../SYSN/view/statistics/sale/contract/SalesProfitDetails_Contract.ashx',2,NULL,0,0,0,'../skin/default/images/child/sale/Ico_xm_05.gif',32,'数据分析',0,'','({1000}+{7000}+{27000}+{8000})+[44,8]'
union all select 33,0,0,'产品库存列表','sys:../../SYSN/view/store/inventory/InventorySummary.ashx',2,NULL,0,0,0,'../skin/default/images/child/store/Ico_gys_05.gif',33,'数据分析',0,'','({13000}+{17000})+[23,11]'
union all select 34,0,0,'库存变动汇总表','sys:../../SYSN/view/statistics/store/InventoryChangeSummary.ashx',2,NULL,0,0,0,'../skin/default/images/child/sale/Ico_sh_04.gif',34,'数据分析',0,'','({13000}+{17000})+[23,11]'
union all select 35,0,0,'账号余额统计','sys:../tongji/bank1.asp',2,NULL,0,0,0,'../skin/default/images/child/bank/Ico_fy_06.gif',35,'数据分析',0,'','{19000}+[11,11]'
union all select 36,0,0,'收支明细表','sys:../tongji/cash_list.asp?B=0&t=3',2,NULL,0,0,0,'../skin/default/images/child/bank/Ico_sk_05.gif',36,'数据分析',0,'','({23000}+{24000})+[11,11]'
union all select 37,0,0,'费用汇总表','sys:../pay/fy1.asp',2,NULL,0,0,0,'../skin/default/images/child/bank/Ico_fk_05.gif',37,'数据分析',0,'','{27000}+[6,11]'

union all select 50,0,0,'分配客户','sys:../work/teltop.asp',2,NULL,0,0,0,'../skin/default/images/child/sale/Ico_kh_03.gif',50,'常用栏目',1,'','{1001}+[1,1]+[1,19]'
union all select 51,0,0,'分配项目','sys:../chance/chancetop.asp',2,NULL,0,0,0,'../skin/default/images/child/sale/Ico_xm_03.gif',51,'常用栏目',1,'','{3000}+[3,1]+[3,19]'
union all select 52,0,0,'报价添加','sys:../../SYSN/view/sales/price/price.ashx',2,NULL,0,0,0,'../skin/default/images/child/sale/Ico_bj_01.gif',52,'常用栏目',1,'','{4000}+[4,13]+[4,19]'
union all select 53,0,0,'报价检索','sys:../../SYSN/view/sales/price/pricelist.ashx',2,NULL,0,0,0,'../skin/default/images/child/sale/Ico_bj_03.gif',53,'常用栏目',1,'','{4000}+[4,1]+[4,19]'
union all select 54,0,0,'合同提醒','sys:../contract/planlist.asp',2,NULL,0,0,0,'../skin/default/images/child/sale/Ico_ht_03.gif',54,'常用栏目',1,'','{7000}+[5,1]+[5,19]'
union all select 55,0,0,'销售退货','sys:../contractth/addth.asp',2,NULL,0,0,0,'../skin/default/images/child/sale/Ico_ht_09.gif',55,'常用栏目',1,'','{8000}+[41,13]+[41,19]'
union all select 56,0,0,'售后添加','sys:../service/add.asp?h=1',2,NULL,0,0,0,'../skin/default/images/child/sale/Ico_sh_01.gif',56,'常用栏目',1,'','{9000}+[42,13]+[42,19]'
union all select 57,0,0,'售后检索','sys:../service/event.asp',2,NULL,0,0,0,'../skin/default/images/child/sale/Ico_sh_03.gif',57,'常用栏目',1,'','{9000}+[42,1]+[42,19]'
union all select 58,0,0,'短信','sys:../message/topadd.asp',2,NULL,0,0,0,'../skin/default/images/child/sale/Ico_dx_01.gif',58,'常用栏目',1,'','{100000}+[67,13]+[67,19]'
union all select 59,0,0,'邮件','sys:../email/index.asp',2,NULL,0,0,0,'../skin/default/images/child/sale/Ico_yj_01.gif',59,'常用栏目',1,'','{28004}+[77,13]+[77,19]'
union all select 60,0,0,'预购','sys:../../SYSN/view/store/yugou/YuGou.ashx?OpenType=1',2,NULL,0,0,0,'../skin/default/images/child/store/Ico_cg_02.gif',60,'常用栏目',1,'','{14000}+[25,13]+[25,19]'
union all select 61,0,0,'到货提醒','sys:../caigou/planlist.asp',2,NULL,0,0,0,'../skin/default/images/child/store/Ico_cg_05.gif',61,'常用栏目',1,'','{15000}+[22,1]+[22,19]'
union all select 62,0,0,'采购检索','sys:../../SYSN/view/store/caigou/caigoulist.ashx',2,NULL,0,0,0,'../skin/default/images/child/store/Ico_cg_09.gif',62,'常用栏目',1,'','{15000}+[22,1]+[22,19]'
union all select 63,0,0,'采购退货','sys:../../SYSN/view/store/caigouth/purchasereturn.ashx?fromModel=1',2,NULL,0,0,0,'../skin/default/images/child/store/Ico_cg_07.gif',63,'常用栏目',1,'','{16000}+[75,13]+[75,19]'
union all select 64,0,0,'直接入库','sys:../store/addrk.asp',2,NULL,0,0,0,'../skin/default/images/child/store/Ico_rk_02.gif',64,'常用栏目',1,'','{17000}+[31,13]+[31,19]'
union all select 65,0,0,'直接出库','sys:../store/addck.asp',2,NULL,0,0,0,'../skin/default/images/child/store/Ico_ck_02.gif',65,'常用栏目',1,'','{17000}+[32,18]+[32,19]'
union all select 66,0,0,'库间调拨','sys:../store/adddb.asp',2,NULL,0,0,0,'../skin/default/images/child/store/Ico_ch_01.gif',66,'常用栏目',1,'','{17000}+[36,13]+[36,19]'
union all select 67,0,0,'库存盘点','sys:../store/db/addpd.asp',2,NULL,0,0,0,'../skin/default/images/child/store/Ico_ch_02.gif',67,'常用栏目',1,'','{17000}+[35,13]+[35,19]'
union all select 68,0,0,'添加借货','sys:../store/addjh.asp',2,NULL,0,0,0,'../skin/default/images/child/store/Ico_ch_03.gif',68,'常用栏目',1,'','{17000}+[37,13]+[37,19]'
union all select 69,0,0,'组装拆装','sys:../store/planallzz.asp',2,NULL,0,0,0,'../skin/default/images/child/store/Ico_ch_04.gif',69,'常用栏目',1,'','{17000}+[34,1]+[34,19]'
union all select 70,0,0,'预测单添加','../manufacture/inc/Bill.asp?orderid=1',2,NULL,0,0,0,'../skin/default/images/child/Manufacture/Ico_yg_01.gif',70,'常用栏目',1,'','{18000}+[52,13]+[52,19]'
union all select 71,0,0,'物料清单','sys:../manufacture/inc/Bill.asp?orderid=5',2,NULL,0,0,0,'../skin/default/images/child/Manufacture/Ico_jh_01.gif',71,'常用栏目',1,'','{18000}+[56,13]+[56,19]'
union all select 72,0,0,'下达单添加','sys:../manufacture/inc/Bill.asp?orderid=4',2,NULL,0,0,0,'../skin/default/images/child/Manufacture/Ico_xd_01.gif',72,'常用栏目',1,'','{18000}+[53,13]+[53,19]'
union all select 73,0,0,'进度汇报','sys:../manufacture/inc/Bill.asp?orderid=11',2,NULL,0,0,0,'../skin/default/images/child/Manufacture/Ico_hb_01.gif',73,'常用栏目',1,'','{18000}+[55,13]+[55,19]'
union all select 74,0,0,'质检提交','sys:../manufacture/inc/Bill.asp?orderid=17',2,NULL,0,0,0,'../skin/default/images/child/Manufacture/Ico_zj_01.gif',74,'常用栏目',1,'','{18000}+[58,13]+[58,19]'
union all select 75,0,0,'收款检索','sys:../money/planall2.asp',2,NULL,0,0,0,'../skin/default/images/child/bank/Ico_sk_04.gif',75,'常用栏目',1,'','{23000}+[7,1]+[7,19]'
union all select 76,0,0,'付款检索','sys:../money2/planall2.asp',2,NULL,0,0,0,'../skin/default/images/child/bank/Ico_fk_04.gif',76,'常用栏目',1,'','{24000}+[8,1]+[8,19]'
union all select 77,0,0,'费用使用','sys:../pay/add2.asp',2,NULL,0,0,0,'../skin/default/images/child/bank/Ico_fy_02.gif',77,'常用栏目',1,'','{27000}+[6,13]+[6,19]'
union all select 78,0,0,'费用借款','sys:../pay/addgr.asp',2,NULL,0,0,0,'../skin/default/images/child/bank/Ico_fy_05.gif',78,'常用栏目',1,'','{27000}+[6,13]+[6,19]'
union all select 79,0,0,'费用返还','sys:../pay/addfh.asp',2,NULL,0,0,0,'../skin/default/images/child/bank/Ico_fy_04.gif',79,'常用栏目',1,'','{27000}+[6,13]+[6,19]'
union all select 80,0,0,'工资发放','sys:../wages/planall.asp?a=0',2,NULL,0,0,0,'../skin/default/images/child/bank/Ico_gz_02.gif',80,'常用栏目',1,'','{26000}+[10,1]+[10,19]'
update a set a.url = b.url, a.powerCode=b.powerCode from  home_mainlink_config a inner join home_mainlink_config b on a.role <> 0 and a.id=b.id and a.id < 10000

GO

--同步工资项历史记录
if not exists(select top 1 id from wageslist_jj where num2>0)
begin
	update l set l.sort5Name=s.sort2,l.num2=s.num1,l.sort4Name=s2.sort1 from wageslist_jj l inner join sort5jj s on s.ord=l.sort1 inner join sort4jj s2 on s2.ord=s.sort1
	update  wageslist_jj set sort5Name='工种已删除',num2=money1/num1,sort4Name='工序已删除' where sort1<>0
end

if not exists(select top 1 id from wageslist where gate1>0) update l set l.sortName=s.sort1,l.updown=s.intro,l.gate1=s.gate1 from wageslist l inner join sortwages s on l.sort1=s.id

GO

if not exists(select bz from setbz) insert into setbz (bz) values (1)

--GO

--添加默认权限
--insert into power (ord,sort1, sort2, qx_open, qx_intro)
--select c.ord,a.sort1,b.sort2,0,'' from qxlb a
--inner join qxlblist b on a.sort1= b.sort1
--inner join gate c  on  not exists(select 1 from power d where d.sort1=a.sort1 and d.sort2=b.sort2 and d.ord=c.ord)

GO
--处理人资档案姓名老数据
update hr_person set username = x.name from gate x where x.ord= hr_person.userID and len(isnull(hr_person.username,''))=0
update hr_person set sorce=x.sorce,sorce2=x.sorce2 from gate x where x.ord= hr_person.userID
GO
--仓库多级分类
update sortck1 set rootID = id where isnull(rootID,0)=0
--防止仓库有空格数据
update sortck set intro = replace(cast(intro as varchar(8000)),' ','')

GO

--更新报表的配置
--update home_maincards_us set title=a.title, sql = a.sql,sql2=a.sql2,model=a.model,powers=a.powers,attrs = a.attrs,fw=a.fw,setJM=a.setJM,canqt=a.canqt from home_maincards_def a where  a.ID=home_maincards_us.ID
GO

--设置sortonehy表的del字段设置为1  注：1为正常 --李彭波 2012-06-25
update sortonehy set del=1 where del is null
GO

--添加索引
IF NOT EXISTS (select 1 from dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[hr_Log]') AND name = N'IX_hr_Log_creator_del')
CREATE NONCLUSTERED INDEX [IX_hr_Log_creator_del] ON [dbo].[hr_Log]
(
	[creator] DESC,
	[result] DESC,
	[del] DESC,
	[inDate] DESC
) ON [PRIMARY]

GO

--添加索引
IF NOT EXISTS (select 1 from dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[Store_ChangeLog]') AND name = N'IX_Store_ChangeLog_opdate')
CREATE NONCLUSTERED INDEX [IX_Store_ChangeLog_opdate] ON [dbo].[Store_ChangeLog]
(
	[opdate] desc,
	[OperatorId] desc,
	[OpType] desc,
	[storeid] desc,
	[KuId] desc
) ON [PRIMARY]

GO

--同步model,visble
update b set b.model=a.model from home_maincards_def a inner join home_maincards_us b on a.id=b.id and a.model<>b.model
update b set b.powers=a.powers from home_maincards_def a inner join home_maincards_us b on a.id=b.id and a.powers<>b.powers
--考勤处理
update b set b.setjm=a.setjm ,b.fw=a.fw from home_maincards_def a inner join home_maincards_us b on a.id=b.id and b.setjm in (107,108)
delete from home_maincards_us where setjm = 109 and id = 10045

GO
IF NOT EXISTS (select 1 from dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[ERP_CustomValues]') AND name = N'IX_ERP_CustomValues')
CREATE NONCLUSTERED INDEX [IX_ERP_CustomValues] ON [dbo].[ERP_CustomValues]
(
	[ID] ASC
) ON [PRIMARY]

GO

IF NOT EXISTS (select 1 from dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[ERP_CustomValues]') AND name = N'IX_ERP_CustomValues_fieldsid')
CREATE NONCLUSTERED INDEX [IX_ERP_CustomValues_fieldsid] ON [dbo].[ERP_CustomValues]
(
	[FieldsID] ASC
) ON [PRIMARY]

GO

IF NOT EXISTS (select 1 from dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[ERP_CustomValues]') AND name = N'IX_ERP_CustomValues_orderid')
CREATE NONCLUSTERED INDEX [IX_ERP_CustomValues_orderid] ON [dbo].[ERP_CustomValues]
(
	[OrderID] ASC
) ON [PRIMARY]

GO

IF NOT EXISTS (select 1 from dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[sortonehy]') AND name = N'IX_sortonehy_ord')
CREATE NONCLUSTERED INDEX [IX_sortonehy_ord] ON [dbo].[sortonehy]
(
	[ord] ASC
) ON [PRIMARY]

GO

IF NOT EXISTS (select 1 from dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[reply]') AND name = N'IX_reply_sort1')
CREATE NONCLUSTERED INDEX [IX_reply_sort1] ON [dbo].[reply]
(
	[sort1] ASC
) ON [PRIMARY]

GO

IF NOT EXISTS (select 1 from dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[reply]') AND name = N'IX_reply_ord')
CREATE NONCLUSTERED INDEX [IX_reply_ord] ON [dbo].[reply]
(
	[ord] ASC
) ON [PRIMARY]

GO

IF NOT EXISTS (select 1 from dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[tel]') AND name = N'IX_tel_ord')
CREATE NONCLUSTERED INDEX [IX_tel_ord] ON [dbo].[tel]
(
	[ord] ASC
) ON [PRIMARY]

GO

IF NOT EXISTS (select 1 from dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[power]') AND name = N'IX_menu_Load')
CREATE NONCLUSTERED INDEX [IX_menu_Load] ON [dbo].[power]
(
	[ord] ASC,
	[sort1] ASC,
	[sort2] ASC
) ON [PRIMARY]

GO

IF NOT EXISTS (select 1 from dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[payback]') AND name = N'IX_payback')
CREATE NONCLUSTERED INDEX [IX_payback] ON [dbo].[payback]
(
	[date1] desc,
	[date7] desc,
	[ord] desc
) ON [PRIMARY]

GO

IF NOT EXISTS (select 1 from dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[payout]') AND name = N'IX_payout')
CREATE NONCLUSTERED INDEX [IX_payout] ON [dbo].[payout]
(
	[date1] desc,
	[date7] desc,
	[ord] desc
) ON [PRIMARY]

GO

--初始化旧数据付款单据审批记录
update payout set status_sp=0 where status_sp is null and sp is null and cateid_sp is null

--处理ku表中没有写入kuinlist供应商资料
if exists(select gys from ku where gys=0 or gys is NULL) Update ku set gys=(select case sort1 when 2 then (select isnull(company,0) from caigoulist where caigoulist.id=kuinlist.caigoulist2) else isnull(company,0) end as company from kuinlist where id=ku.kuinlist) where gys=0 or gys is NULL

GO

--为setjm3写入默认值
if not exists(select 1 from dbo.setjm3 where ord=88) insert into dbo.setjm3 (ord, num1) values (88,2)
if not exists(select 1 from dbo.setjm3 where ord=1) insert into dbo.setjm3 (ord, num1) values (1,2)
if not exists(select 1 from dbo.setjm3 where ord=2019042801) insert into dbo.setjm3 (ord, num1) select 2019042801,num1 from dbo.setjm3 where ord=1
if not exists(select 1 from dbo.setjm3 where ord=2019042802) insert into dbo.setjm3 (ord, num1) select 2019042802,num1 from dbo.setjm3 where ord=1
if not exists(select 1 from dbo.setjm3 where ord=2019042803) insert into dbo.setjm3 (ord, num1) select 2019042803,num1 from dbo.setjm3 where ord=1
if not exists(select 1 from dbo.setjm3 where ord=2019042804) insert into dbo.setjm3 (ord, num1) select 2019042804,num1 from dbo.setjm3 where ord=1
if not exists(select 1 from dbo.setjm3 where ord=87) insert into dbo.setjm3 (ord, num1) values (87,2)
if not exists(select 1 from dbo.setjm3 where ord=2) insert into dbo.setjm3 (ord, num1) values (2,120)
if not exists(select 1 from dbo.setjm3 where ord=3) insert into dbo.setjm3 (ord, num1) values (3,500)
if not exists(select 1 from dbo.setjm3 where ord=4) insert into dbo.setjm3 (ord, num1) values (4,30000)
if not exists(select 1 from dbo.setjm3 where ord='2015062301') Insert Into dbo.setjm3(ord,num1) values('2015062301','60000') --APP提醒间隔时间设置
if not exists(select 1 from dbo.setjm3 where ord='2015062401') Insert Into dbo.setjm3(ord,num1) values('2015062401','0') --APP录音上传开关
if not exists(select 1 from dbo.setjm3 where ord='20171221') Insert Into dbo.setjm3(ord,num1) values('20171221','2') --百分比小数位数
if not exists(select 1 from dbo.setjm3 where ord='20191225') Insert Into dbo.setjm3(ord,num1) values('20191225','0') --考勤机连接方式
if not exists(select 1 from dbo.setjm3 where ord='20200730') Insert Into dbo.setjm3(ord,intro) values('20200730','0.0.1') --客户端版本号
--更新客户端版本
update setjm3 set intro = '01.01.031' where ord='20200730'

go

--组装拆装明细字段
if not exists (SELECT 1 FROM zdymx WHERE sort1=1004)
begin
    insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('产品名称','title',1,1,140,140,1,1004,1)
    insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('编号','order1',2,1,60,60,2,1004,2)
    insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('型号','type1',2,1,60,60,3,1004,3)
    insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('单位','unitall',1,1,60,60,4,1004,4)
    insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('数量','num1',1,1,45,45,5,1004,5)
    insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('单价','price1',1,1,75,75,6,1004,6)
    insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('总价','total1',1,1,85,85,7,1004,7)
    insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('仓库','ck1',1,1,85,85,8,1004,8)
    insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('批号','ph1',1,1,75,75,9,1004,9)
    insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('序列号','xlh1',1,1,85,85,10,1004,10)
    insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('生产日期','scrq1',1,1,140,140,11,1004,11)
    insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('有效期至','yxrq1',1,1,140,140,12,1004,12)
    insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('包装','bz1',1,1,75,75,13,1004,13)
    insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('件数','js1',1,1,45,45,14,1004,14)
    insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('备注','intro',2,1,85,85,15,1004,15)
    insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('自定义1','zdy1',2,0,85,85,16,1004,16)
    insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('自定义2','zdy2',2,0,85,85,17,1004,17)
    insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('自定义3','zdy3',2,0,85,85,18,1004,18)
    insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('自定义4','zdy4',2,0,85,85,19,1004,19)
    insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('自定义5','zdy5',2,0,85,85,20,1004,20)
    insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('自定义6','zdy6',2,0,85,85,21,1004,21)
end
if not exists (SELECT 1 FROM zdymx WHERE sort1=1005)
begin
    insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('产品名称','title',1,1,140,140,1,1005,1)
    insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('编号','order1',2,1,60,60,2,1005,2)
    insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('型号','type1',2,1,60,60,3,1005,3)
    insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('单位','unitall',1,1,60,60,4,1005,4)
    insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('数量','num1',1,1,45,45,5,1005,5)
    insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('单价','price1',1,1,75,75,6,1005,6)
    insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('总价','total1',1,1,85,85,7,1005,7)
    insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('仓库','ck1',1,1,75,75,8,1005,8)
    insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('库存信息','kcxx1',1,1,140,140,9,1005,9)
    insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('出库方式','ckfs1',1,1,140,140,10,1005,10)
    insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('包装','bz1',1,1,75,75,11,1005,11)
    insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('件数','js1',1,1,45,45,12,1005,12)
    insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('备注','intro',2,1,85,85,13,1005,13)
    insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('自定义1','zdy1',2,0,85,85,14,1005,14)
    insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('自定义2','zdy2',2,0,85,85,15,1005,15)
    insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('自定义3','zdy3',2,0,85,85,16,1005,16)
    insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('自定义4','zdy4',2,0,85,85,17,1005,17)
    insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('自定义5','zdy5',2,0,85,85,18,1005,18)
    insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) values('自定义6','zdy6',2,0,85,85,19,1005,19)
end


GO

if not exists(select 1 from dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[sendlist]') AND name = N'rpt_sendlist_index')
CREATE NONCLUSTERED INDEX [rpt_sendlist_index]
ON [dbo].[sendlist] ([complete1],[del],[dateadd])

GO

--binary.2013.12.27.临后.优化生产订单慢的问题
if not exists(select 1 from dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[kuinlist]') AND name = N'kuinlistIndex')
CREATE NONCLUSTERED INDEX [kuinlistIndex]
ON [dbo].[kuinlist] ([id],[QTLID],[MOrderID])

GO

if not exists(select 1 from dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[kuoutlist2]') AND name = N'xlsout_kuout_kuoutlist2')
CREATE NONCLUSTERED INDEX [xlsout_kuout_kuoutlist2]
ON [dbo].[kuoutlist2] ([kuout])

GO

if not exists(select 1 from dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[product]') AND name = N'xlsout_kuout_product')
CREATE NONCLUSTERED INDEX [xlsout_kuout_product]
ON [dbo].[product] ([ord])


if exists(select * from zdymx where sort1=1003 and name='num1') update zdymx set title='申请数量' where sort1=1003 and name='num1'

if exists(select * from contract where title='期初应收' and sp is null) update contract set sp=0 where title='期初应收' and sp is null

if exists(select * from hr_ret_type where orderid=1021 and sortid>0) update hr_ret_type set sortid=0 where orderid=1021 and sortid>0

--处理之前可能存在相同字段
if exists(select top 1 * from sortonehy where gate2=33 and sort1='余额付款') update sortonehy set sort1='余额付款1' where gate2=33 and sort1='余额付款'

--对采购明细中money1为空,price1为空进行处理
if exists(select top 1 money1 from caigoulist where money1 is NULL) Update caigoulist set money1=0 where money1 is NULL
if exists(select top 1 price1 from caigoulist where price1 is NULL) Update caigoulist set price1=0 where price1 is NULL

--处理product.unit异常
if exists(select top 1 * from product where unit is null) update product set unit=isnull(unitjb,0) where unit is null

--纠正错误数据，非精确，date7可能有差异，kuin.caigou<>kuhh.when sort1=6，备份字段：Joinkuhh
if not exists(select top 1 * from kuin where sort1=6 and not Joinkuhh is null)
begin
update kuin set Joinkuhh=caigou where sort1=6
update kuin set caigou=(select top 1 isnull(ord,0) from kuhh where date1=kuin.date3 and cateid=kuin.cateid and date7=kuin.date7) where sort1=6 and caigou in(select kujh from kuhh)
end

GO

if not exists(select 1 from home_usConfig where name = 'AvailStorckType' and uid=0)
begin
	insert into  home_usConfig  (name, tvalue, uid) values ('AvailStorckType', 110, 0)
end

--应为5.1号,4月无30，5月有30
if exists(select top 1 * from nldata where yl='2013-06-08 00:00:00.000' and nm=4 and nd=30)
begin
	update nldata set nm=5,nd=1 where yl='2013-06-08 00:00:00.000' and nm=4 and nd=30   
	update nldata set nd=nd+1 where yl>'2013-06-08 00:00:00.000' and yl<='2013-07-07 00:00:00.000'
end

GO

--新增采购付款流程设置
if not exists(select 1 from setopen where sort1=70) insert into setopen (intro,sort1) values (1,70) 
if not exists(select 1 from setopen where sort1=71) insert into setopen (intro,sort1) values (0,71) 
if not exists(select 1 from setopen where sort1=72) insert into setopen (intro,sort1) values (0,72) 

--新增采购收票流程设置
if not exists(select 1 from setopen where sort1=2019923) insert into setopen (intro,sort1) values (1,2019923) 
if not exists(select 1 from setopen where sort1=2019924) insert into setopen (intro,sort1) values (1,2019924) 
if not exists(select 1 from setopen where sort1=2019925) insert into setopen (intro,sort1) values (1,2019925)


--修改出差审批 为 费用申请审批
UPDATE home_maincards_us SET title = '费用申请审批' where title = '出差审批'


GO

--修改ku_back数据中ku_id为空的情况  2013.07.02.Binary
if exists(select 1 from ku_back where ku_id is null)
begin
	delete ku_back where ku_id is null and  id in (
		select id from ku_back x inner join (
			select kuinlist, num3, daterk , backUpDate, ord, unit from ku_back 
			where ku_id is null
			group by kuinlist, num3, daterk , backUpDate  , ord, unit
			having COUNT(1) > 1 
		) y on 
		x.kuinlist = y.kuinlist  and x.num3 = y.num3 and x.daterk = y.daterk 
		and x.backUpDate = y.backUpDate and x.ord = y.ord and x.unit=y.unit 
		where x.ku_id is null
	) 


	update a set a.ku_id = b.id from ku_back a 
	inner join ku b on 
	a.ku_id is null and 
	a.kuinlist = b.kuinlist and a.num3 = b.num3 and a.daterk = b.daterk and a.ord = b.ord and a.unit = b.unit 

	delete ku_back where ku_id is null 
end

GO

--删除关联已删除出入库单的备份数据，主要是针对老数据处理。
delete ku_back where id in (
	select c.id from kuout a 
	inner join kuoutlist2 b on a.del=2 and a.ord = b.kuout
	inner join ku_back c on c.ku_id = b.ku and datediff(d, c.backupdate,a.deldate) >= 0 
	and datediff(d, a.date7, c.backupdate) >= 0
	union all
	select b.id from kuinlist a inner join ku_back b on a.del=2 and a.id = b.kuinlist
)

----初始化所有跟进回收策略表
if not exists(select top 1 1from sort5_gate) insert into sort5_gate(gateord,sort5) select gate.ord,sort5.ord from gate left join sort5 on 1=1

----客户回收策略1：领用未联系收回转移到具体分类下，条件：存在设置且分类中为空值
if exists(select top 1 * from setopen  where sort1=22 and isnull(intro,0)>0) and exists(select top 1 * from sort5 where unreplyback1 is null)
begin
	update sort5 set unreplyback1=(select top 1 intro from setopen  where sort1=22 and isnull(intro,0)>0) where unreplyback1 is null
	update sort5_gate set unback1day=(select num_1 from gate where ord=sort5_gate.gateord)
end

--客户回收策略2：间隔未联系收回
if exists(select top 1 * from setopen  where sort1=23 and isnull(intro,0)>0) and exists(select top 1 * from sort5 where unreplyback2 is null)
begin
	update sort5 set unreplyback2=(select top 1 intro from setopen  where sort1=23 and isnull(intro,0)>0) where unreplyback2 is null
	update sort5_gate set unback2day=(select num_2 from gate where ord=sort5_gate.gateord)
end

--客户回收策略3：跟进未成功收回
if exists(select top 1 * from setopen  where sort1=24 and isnull(intro,0)>0) and exists(select top 1 * from sort5 where unsalesback is null)
begin
	update sort5 set unsalesback=(select top 1 intro from setopen  where sort1=24 and isnull(intro,0)>0) where unsalesback is null
	update sort5_gate set salesbackday=(select num_3 from gate where ord=sort5_gate.gateord)
end

GO

if not exists (SELECT 1 FROM setfields WHERE sort=1)
begin
	update zdy set bt=isnull((select (case when charindex(',25,',','+replace(bt,' ','')+',')>0 then 1 else 0 end) from celue where sort1=1), 0),ts=isnull((select (case when charindex(',25,',','+replace(ts,' ','')+',')>0 then 1 else 0 end) from celue where sort1=1), 0),jz=isnull((select (case when charindex(',25,',','+replace(jz,' ','')+',')>0 then 1 else 0 end) from celue where sort1=1), 0) where sort1=1 and name='zdy1'
	update zdy set bt=isnull((select (case when charindex(',26,',','+replace(bt,' ','')+',')>0 then 1 else 0 end) from celue where sort1=1), 0),ts=isnull((select (case when charindex(',26,',','+replace(ts,' ','')+',')>0 then 1 else 0 end) from celue where sort1=1), 0),jz=isnull((select (case when charindex(',26,',','+replace(jz,' ','')+',')>0 then 1 else 0 end) from celue where sort1=1), 0) where sort1=1 and name='zdy2'
	update zdy set bt=isnull((select (case when charindex(',27,',','+replace(bt,' ','')+',')>0 then 1 else 0 end) from celue where sort1=1), 0),ts=isnull((select (case when charindex(',27,',','+replace(ts,' ','')+',')>0 then 1 else 0 end) from celue where sort1=1), 0),jz=isnull((select (case when charindex(',27,',','+replace(jz,' ','')+',')>0 then 1 else 0 end) from celue where sort1=1), 0) where sort1=1 and name='zdy3'
	update zdy set bt=isnull((select (case when charindex(',28,',','+replace(bt,' ','')+',')>0 then 1 else 0 end) from celue where sort1=1), 0),ts=isnull((select (case when charindex(',28,',','+replace(ts,' ','')+',')>0 then 1 else 0 end) from celue where sort1=1), 0),jz=isnull((select (case when charindex(',28,',','+replace(jz,' ','')+',')>0 then 1 else 0 end) from celue where sort1=1), 0) where sort1=1 and name='zdy4'
end

select top 0 oldName,name,[type],show,point,enter,[Required],format,sort2,sort,fieldName,gate1,extra,order1 into #t_setfields from setfields

insert into #t_setfields (oldName,name,type,show,point,enter,Required,format,sort2,sort,fieldName,gate1,order1,extra) 
select '客户名称','',2,2,isnull((select (case when charindex(',1,',','+replace(ts,' ','')+',')>0 then 1 else 0 end) from celue where sort1=1), 0),isnull((select (case when charindex(',1,',','+replace(jz,' ','')+',')>0 then 1 else 0 end) from celue where sort1=1), 0),isnull((select (case when charindex(',1,',','+replace(bt,' ','')+',')>0 then 1 else 0 end) from celue where sort1=1), 1),'',1,1,'name',1,1,'zlts='+isnull((select cast(intro as varchar(10)) from setopen where sort1=1101),'0')
union all select '拼 音 码','',2,2,-1,-1,-1,'',1,1,'pym',2,2,NULL
union all select '客户编号','',2,2,isnull((select (case when charindex(',2,',','+replace(ts,' ','')+',')>0 then 1 else 0 end) from celue where sort1=1), 0),isnull((select (case when charindex(',2,',','+replace(jz,' ','')+',')>0 then 1 else 0 end) from celue where sort1=1), 0),isnull((select (case when charindex(',2,',','+replace(bt,' ','')+',')>0 then 1 else 0 end) from celue where sort1=1), 1),'',1,1,'khid',3,3,NULL
union all select '客户分类','',1,2,-1,-1,2,'',1,1,'sort',4,4,NULL
union all select '跟进程度','',1,2,-1,-1,2,'',1,1,'sort1',5,5,NULL
union all select '客户来源','',1,2,-1,-1,isnull((select (case when charindex(',21,',','+replace(bt,' ','')+',')>0 then 1 else 0 end) from celue where sort1=1), 1),'',1,1,'ly',6,6,NULL
union all select '客户区域','',4,2,-1,-1,isnull((select (case when charindex(',20,',','+replace(bt,' ','')+',')>0 then 1 else 0 end) from celue where sort1=1), 1),'',1,1,'area',7,7,NULL
union all select '客户行业','',1,2,-1,-1,isnull((select (case when charindex(',22,',','+replace(bt,' ','')+',')>0 then 1 else 0 end) from celue where sort1=1), 1),'',1,1,'trade',8,8,NULL
union all select '客户价值','',1,2,-1,-1,isnull((select (case when charindex(',23,',','+replace(bt,' ','')+',')>0 then 1 else 0 end) from celue where sort1=1), 1),'',1,1,'jz',9,9,NULL
union all select '客户网址','',2,1,isnull((select (case when charindex(',11,',','+replace(ts,' ','')+',')>0 then 1 else 0 end) from celue where sort1=1), 0),isnull((select (case when charindex(',11,',','+replace(jz,' ','')+',')>0 then 1 else 0 end) from celue where sort1=1), 0),isnull((select (case when charindex(',24,',','+replace(bt,' ','')+',')>0 then 1 else 0 end) from celue where sort1=1), 1),'',1,1,'url',10,10,NULL
union all select '到款限制','',5,1,-1,-1,isnull((select (case when charindex(',1097,',','+replace(bt,' ','')+',')>0 then 1 else 0 end) from celue where sort1=1), 1),'',1,1,'hk_xz',11,11,NULL
union all select '客户地址','',2,1,-1,-1,isnull((select (case when charindex(',14,',','+replace(bt,' ','')+',')>0 then 1 else 0 end) from celue where sort1=1), 1),'',1,1,'address',12,12,NULL
union all select ' 邮  编 ','',2,1,isnull((select (case when charindex(',10,',','+replace(ts,' ','')+',')>0 then 1 else 0 end) from celue where sort1=1), 0),isnull((select (case when charindex(',10,',','+replace(jz,' ','')+',')>0 then 1 else 0 end) from celue where sort1=1), 0),isnull((select (case when charindex(',10,',','+replace(bt,' ','')+',')>0 then 1 else 0 end) from celue where sort1=1), 1),isnull((select (case when charindex(',10,',','+replace(ts,' ','')+',')>0 then '1' else '0' end) from celue where sort1=11),'1'),1,1,'zip',13,13,NULL
union all select '法人代表','',2,1,-1,-1,isnull((select (case when charindex(',15,',','+replace(bt,' ','')+',')>0 then 1 else 0 end) from celue where sort1=1), 1),'',1,1,'faren',14,14,NULL
union all select '注册资本','',5,1,-1,-1,isnull((select (case when charindex(',16,',','+replace(bt,' ','')+',')>0 then 1 else 0 end) from celue where sort1=1), 1),'',1,1,'zijin',15,15,NULL
union all select '人员数量','',6,1,-1,-1,-1,'',1,1,'pernum1',16,16,NULL
union all select '联系人姓名','',2,2,isnull((select (case when charindex(',3,',','+replace(ts,' ','')+',')>0 then 1 else 0 end) from celue where sort1=1), 0),isnull((select (case when charindex(',3,',','+replace(jz,' ','')+',')>0 then 1 else 0 end) from celue where sort1=1), 0),isnull((select (case when charindex(',3,',','+replace(bt,' ','')+',')>0 then 1 else 0 end) from celue where sort1=1), 1),'',2,1,'person_name',17,17,NULL
union all select '家庭电话','',2,1,-1,-1,isnull((select (case when charindex(',19,',','+replace(bt,' ','')+',')>0 then 1 else 0 end) from celue where sort1=1), 0),isnull((select (case when charindex(',16,',','+replace(ts,' ','')+',')>0 then '1' else '0' end) from celue where sort1=11),'1'),2,1,'phone2',18,27,NULL
union all select '办公电话','',2,1,isnull((select (case when charindex(',4,',','+replace(ts,' ','')+',')>0 then 1 else 0 end) from celue where sort1=1), 0),isnull((select (case when charindex(',4,',','+replace(jz,' ','')+',')>0 then 1 else 0 end) from celue where sort1=1), 0),isnull((select (case when charindex(',4,',','+replace(bt,' ','')+',')>0 then 1 else 0 end) from celue where sort1=1), 0),isnull((select (case when charindex(',4,',','+replace(ts,' ','')+',')>0 then '1' else '0' end) from celue where sort1=11),'1'),2,1,'phone',19,24,NULL
union all select ' 手  机 ','',2,1,isnull((select (case when charindex(',6,',','+replace(ts,' ','')+',')>0 then 1 else 0 end) from celue where sort1=1), 0),isnull((select (case when charindex(',6,',','+replace(jz,' ','')+',')>0 then 1 else 0 end) from celue where sort1=1), 0),isnull((select (case when charindex(',6,',','+replace(bt,' ','')+',')>0 then 1 else 0 end) from celue where sort1=1), 0),isnull((select (case when charindex(',6,',','+replace(ts,' ','')+',')>0 then '1' else '0' end) from celue where sort1=11),'1'),2,1,'mobile',20,26,NULL
union all select ' 传  真 ','',2,1,isnull((select (case when charindex(',5,',','+replace(ts,' ','')+',')>0 then 1 else 0 end) from celue where sort1=1), 0),isnull((select (case when charindex(',5,',','+replace(jz,' ','')+',')>0 then 1 else 0 end) from celue where sort1=1), 0),isnull((select (case when charindex(',5,',','+replace(bt,' ','')+',')>0 then 1 else 0 end) from celue where sort1=1), 0),isnull((select (case when charindex(',5,',','+replace(ts,' ','')+',')>0 then '1' else '0' end) from celue where sort1=11),'1'),2,1,'fax',21,25,NULL
union all select '电子邮件','',2,1,isnull((select (case when charindex(',9,',','+replace(ts,' ','')+',')>0 then 1 else 0 end) from celue where sort1=1), 0),isnull((select (case when charindex(',9,',','+replace(jz,' ','')+',')>0 then 1 else 0 end) from celue where sort1=1), 0),isnull((select (case when charindex(',9,',','+replace(bt,' ','')+',')>0 then 1 else 0 end) from celue where sort1=1), 0),isnull((select (case when charindex(',9,',','+replace(ts,' ','')+',')>0 then '1' else '0' end) from celue where sort1=11),'1'),2,1,'email',22,28,NULL
union all select '   QQ   ','',2,1,isnull((select (case when charindex(',7,',','+replace(ts,' ','')+',')>0 then 1 else 0 end) from celue where sort1=1), 0),isnull((select (case when charindex(',7,',','+replace(jz,' ','')+',')>0 then 1 else 0 end) from celue where sort1=1), 0),isnull((select (case when charindex(',7,',','+replace(bt,' ','')+',')>0 then 1 else 0 end) from celue where sort1=1), 0),isnull((select (case when charindex(',7,',','+replace(ts,' ','')+',')>0 then '1' else '0' end) from celue where sort1=11),'1'),2,1,'qq',23,29,NULL
union all select '   MSN  ','',2,1,isnull((select (case when charindex(',8,',','+replace(ts,' ','')+',')>0 then 1 else 0 end) from celue where sort1=1), 0),isnull((select (case when charindex(',8,',','+replace(jz,' ','')+',')>0 then 1 else 0 end) from celue where sort1=1), 0),isnull((select (case when charindex(',8,',','+replace(bt,' ','')+',')>0 then 1 else 0 end) from celue where sort1=1), 0),isnull((select (case when charindex(',8,',','+replace(ts,' ','')+',')>0 then '1' else '0' end) from celue where sort1=11),'1'),2,1,'msn',24,30,NULL
union all select ' 籍  贯 ','',2,1,-1,-1,isnull((select (case when charindex(',13,',','+replace(bt,' ','')+',')>0 then 1 else 0 end) from celue where sort1=1), 0),'',2,1,'jg',25,31,NULL
union all select '所在单位','',2,1,-1,-1,-1,'',2,1,'faren',26,32,NULL
union all select ' 部  门 ','',2,1,-1,-1,isnull((select (case when charindex(',11,',','+replace(bt,' ','')+',')>0 then 1 else 0 end) from celue where sort1=1), 0),'',2,1,'part1',27,21,NULL
union all select ' 职  务 ','',2,1,-1,-1,isnull((select (case when charindex(',12,',','+replace(bt,' ','')+',')>0 then 1 else 0 end) from celue where sort1=1), 0),'',2,1,'job',28,22,NULL
union all select ' 角  色 ','',1,2,-1,-1,0,'',2,1,'role',29,23,NULL
union all select ' 性  别 ','',3,1,-1,-1,-1,'',2,1,'sex',30,18,NULL
union all select ' 生  日 ','',2,1,-1,-1,-1,'',2,1,'year1',31,20,NULL
union all select ' 年  龄 ','',5,1,-1,-1,-1,'',2,1,'age',32,19,NULL
union all select '客户简介','',8,1,-1,-1,-1,'',3,1,'product',33,33,NULL
union all select '合作现状','',8,1,-1,-1,-1,'',3,1,'c2',34,34,NULL
union all select '合作前景','',8,1,-1,-1,-1,'',3,1,'c3',35,35,NULL
union all select '跟进策略','',8,1,-1,-1,-1,'',3,1,'c4',36,36,NULL
union all select ' 备  注 ','',7,1,-1,-1,-1,'',3,1,'intro',37,37,NULL
union all select '开户银行1','',2,1,-1,-1,-1,'',4,1,'bank_1',38,38,NULL
union all select '开户名称1','',2,1,-1,-1,-1,'',4,1,'bank_2',39,39,NULL
union all select '银行行号1','',2,1,-1,-1,-1,'',4,1,'bank_7',50,40,NULL
union all select '银行账号1','',2,1,-1,-1,-1,'',4,1,'bank_3',40,41,NULL
union all select '税号1','',2,1,-1,-1,-1,'',4,1,'bank_4',41,42,NULL
union all select '地址1','',2,1,-1,-1,-1,'',4,1,'bank_5',42,43,NULL
union all select '电话1','',2,1,-1,-1,-1,'',4,1,'bank_6',43,44,NULL
union all select '开户银行2','',2,1,-1,-1,-1,'',4,1,'bank2_1',44,45,NULL
union all select '开户名称2','',2,1,-1,-1,-1,'',4,1,'bank2_2',45,46,NULL
union all select '银行行号2','',2,1,-1,-1,-1,'',4,1,'bank2_7',51,47,NULL
union all select '银行账号2','',2,1,-1,-1,-1,'',4,1,'bank2_3',46,48,NULL
union all select '税号2','',2,1,-1,-1,-1,'',4,1,'bank2_4',47,49,NULL
union all select '地址2','',2,1,-1,-1,-1,'',4,1,'bank2_5',48,50,NULL
union all select '电话2','',2,1,-1,-1,-1,'',4,1,'bank2_6',49,51,NULL
union all select '信用等级','',1,2,-1,-1,0,'',1,1,'credit',52,9,NULL
union all select '微  信','',2,1,0,0,0,0,2,1,'weixinAcc',100,29,NULL

insert into setfields(
	oldName,name,[type],show,point,enter,
	[Required],format,sort2,sort,fieldName,
	gate1,extra,order1
)
select 
	oldName,name,[type],show,point,enter,
	[Required],format,sort2,sort,fieldName,
	gate1,extra,order1
from #t_setfields x where not exists(
	select 1 from setfields y where x.sort=y.sort and x.gate1 = y.gate1
)

drop table #t_setfields

GO
if exists(select top 1 1 from setfields where gate1=53 and fieldName='weixinAcc')
begin
	delete from setfields where gate1=53 and fieldName='weixinAcc'
end 
GO
--重新计算下客户分类及跟进程度的重要指数，更新sort4.gate1,sort5.gate2（内部带判断条件）
exec update_tel_sort_gate

--预占10个位置
if not exists(select 1 from sort10)
begin
	insert into sort10(ord,sort1,intro,gate2,del) values(1,'待查','',10,1)
	insert into sort10(ord,sort1,intro,gate2,del) values(2,'待邮','',9,1)
	insert into sort10(ord,sort1,intro,gate2,del) values(3,'待联','',8,1)
	insert into sort10(ord,sort1,intro,gate2,del) values(4,'','',8,3)
	insert into sort10(ord,sort1,intro,gate2,del) values(5,'','',8,3)
	insert into sort10(ord,sort1,intro,gate2,del) values(6,'','',8,3)
	insert into sort10(ord,sort1,intro,gate2,del) values(7,'','',8,3)
	insert into sort10(ord,sort1,intro,gate2,del) values(8,'','',8,3)
	insert into sort10(ord,sort1,intro,gate2,del) values(9,'','',8,3)
	insert into sort10(ord,sort1,intro,gate2,del) values(10,'','',8,3)
end

--转移以前的待查，待邮，待联信息
if not exists (SELECT 1 FROM importantMsg WHERE metype=1)
begin
insert into importantMsg(content,stime,metype,cateid,ecateid,t_ord,state,date7,del)
select '系统生成：待查客户',getdate(),1,cateid,cateid,ord,1,getdate(),1 from tel where x=2 and isnull(cateid,0)>0
end

if not exists (SELECT 1 FROM importantMsg WHERE metype=2)
begin
insert into importantMsg(content,stime,metype,cateid,ecateid,t_ord,state,date7,del)
select '系统生成：待邮客户',getdate(),2,cateid,cateid,ord,1,getdate(),1 from tel where h=2 and isnull(cateid,0)>0
end

if not exists (SELECT 1 FROM importantMsg WHERE metype=3)
begin
insert into importantMsg(content,stime,metype,cateid,ecateid,t_ord,state,date7,del)
select '系统生成：待联客户',datealt,3,cateid,cateid,ord,1,getdate(),1 from tel where dateadd(yyyy,-10,datealt)<=getdate() and dateadd(yyyy,10,datealt)>=getdate() and isnull(cateid,0)>0
end

GO
--领用含添加客户
if exists(select top 1 1 from setopen where sort1=25 and extra is null) update setopen set extra=1 where sort1=25
if exists(select top 1 1 from setopen where sort1=37 and extra is null) update setopen set extra=1 where sort1=37

if not exists(select top 1 1 from sort11)
begin
	insert into sort11(sort1,intro,gate2,del) values('3天未联系','系统生成',3,1)
	insert into sort11(sort1,intro,gate2,del) values('7天未联系','系统生成',7,1)
	insert into sort11(sort1,intro,gate2,del) values('15天未联系','系统生成',15,1)
	insert into sort11(sort1,intro,gate2,del) values('30天未联系','系统生成',30,1)
	insert into sort11(sort1,intro,gate2,del) values('60天未联系','系统生成',60,1)
	insert into sort11(sort1,intro,gate2,del) values('100天未联系','系统生成',100,1)
	insert into sort11(sort1,intro,gate2,del) values('180天未联系','系统生成',180,1)
end

GO
--处理power表中的“0”

if exists(
	select top 1 1 from power where qx_open=1 and (','+cast(qx_intro as varchar(8000)) + ',' like '%,0,%')
)
begin
	UPDATE power SET 
	qx_intro = replace(replace(replace('[,'+replace(CAST(qx_intro AS VARCHAR(8000)), ' ','')+',]'  ,   ',0,'  ,   ',-222,'), '[,',''), ',]', '')
	where  (','+cast(qx_intro as varchar(8000)) + ',' like '%,0,%')
end

if exists(
	select top 1 1 from power where qx_open in (1,3) and (qx_intro is null or replace(cast(qx_intro as varchar(8000)),' ','') = '')
)
begin
	update [power] set qx_intro = '-222' where qx_open in (1,3) and (qx_intro is null or replace(cast(qx_intro as varchar(8000)),' ','') = '')
end


--bug:2538 baiyong 原由：针对sortonehy中无客户行业，来源，价值，且tel表对应值大于0的解决方法
if exists(select top 1 1 from tel a left join sortonehy b on a.ly=b.ord where isnull(a.ly,0)>0 and b.ord is null) update a set a.ly=0 from tel a left join sortonehy b on a.ly=b.ord where isnull(a.ly,0)>0 and b.ord is null
if exists(select top 1 1 from tel a left join sortonehy b on a.jz=b.ord where isnull(a.jz,0)>0 and b.ord is null) update a set a.jz=0 from tel a left join sortonehy b on a.jz=b.ord where isnull(a.jz,0)>0 and b.ord is null
if exists(select top 1 1 from tel a left join sortonehy b on a.trade=b.ord where isnull(a.trade,0)>0 and b.ord is null) update a set a.trade=0 from tel a left join sortonehy b on a.trade=b.ord where isnull(a.trade,0)>0 and b.ord is null
if exists(select top 1 1 from tel a left join menuarea b on a.area=b.id where isnull(a.area,0)>0 and b.id is null) update a set a.area=0 from tel a left join menuarea b on a.area=b.id where isnull(a.area,0)>0 and b.id is null

if exists(select top 1 1 from sale_Complaints where isnull(status,0)=0 ) update a set a.status=5,a.prefixcode='TS',a.del=(case a.del when 1 then 0 when 2 then 1 end) from sale_Complaints a where isnull(a.status,0)=0

if exists(select top 1 1 from sale_proposal where isnull(status,0)=0 ) update a set a.status=5,a.prefixcode='JY',a.del=(case a.del when 1 then 0 when 2 then 1 end) from sale_proposal a where isnull(a.status,0)=0

if exists(select top 1 1 from paybx where isnull(cateid,0)=0 ) update a set a.cateid=d.cateid,a.cateid2=d.sorce,a.cateid3=d.sorce2 from paybx a inner join (select c.cateid,b.bxid,g.sorce,g.sorce2 from pay c inner join paybxlist b on c.ord=b.payid inner join gate g on g.ord=c.cateid) d on d.bxid=a.id where isnull(a.cateid,0)=0

if exists(select top 1 1 from hr_person where Piecework is null) update a set a.Piecework=isnull(b.jjgz,0) from hr_person a left join gate b on b.ord=a.userid

if not exists(select 1 from home_usConfig where name = 'PickingMaterialStrategy')
begin
	insert into home_usConfig(name,nvalue,tvalue,uid) values('PickingMaterialStrategy',1,null,0)
end

if not exists(select 1 from home_usConfig where name = 'PickingWorkRelationStrategy')
begin
	insert into home_usConfig(name,nvalue,tvalue,uid) values('PickingWorkRelationStrategy',0,null,0)
end

if not exists(select 1 from home_usConfig where name = 'PAYBACK_INVOICE_SEVER')
begin
	insert into power(qx_open,qx_intro,ord,sort1,sort2) select qx_open,qx_intro,ord,7,21
	from power where sort1=7 and sort2=20
	insert into home_usConfig(name,nvalue,tvalue,uid) values('PAYBACK_INVOICE_SEVER',null,1,0)
end

if not exists(select 1 from home_usConfig where name = 'PAYBACK_INVOICE_SEVER_INVOICE_CONFIG')
begin
	insert into invoiceConfig(typeId,maxCount,maxAmount,priceFormula,priceBeforeTaxFormula) select id,0,0,'{未税单价}*(1+{税率})','{含税单价}/(1+{税率})' from sortonehy where gate2 = 34
	insert into home_usConfig(name,nvalue,tvalue,uid) values('PAYBACK_INVOICE_SEVER_INVOICE_CONFIG',null,1,0)
end

if exists(select 1 from home_usConfig where name = 'PAYBACK_INVOICE_CONFIG_UPDATE_HISTORY')
begin
	delete from home_usConfig where name='PAYBACK_INVOICE_CONFIG_UPDATE_HISTORY'
end

if exists(select 1 from home_usConfig where name = 'PAYBACK_INVOICE_SEVER_INVOICE_CONFIG_UPDATE_HISTOR')
begin
	delete from home_usConfig where name='PAYBACK_INVOICE_SEVER_INVOICE_CONFIG_UPDATE_HISTOR'
end

if not exists(select 1 from home_usConfig where name = 'PAYBACK_INVOICE_SEVER_INVOICE_CONFIG_UPDATE_HISTORY')
begin
	update invoiceConfig set priceFormula=replace(isnull(priceFormula,''),'{折后单价}','{未税单价}') , priceBeforeTaxFormula=replace(isnull(priceBeforeTaxFormula,''),'{含税折后单价}','{含税单价}')
	insert into home_usConfig(name,nvalue,tvalue,uid) values('PAYBACK_INVOICE_SEVER_INVOICE_CONFIG_UPDATE_HISTORY',null,1,0)
end

if not exists(select 1 from home_usConfig where name = 'PAYBACK_INVOICE_SEVER_CONTRACT_MODE')
begin
	update contract set invoiceMode=1,paybackMode=1
	insert into home_usConfig(name,nvalue,tvalue,uid) values('PAYBACK_INVOICE_SEVER_CONTRACT_MODE',null,1,0)
end

if not exists(select 1 from home_usConfig where name = 'PAYBACK_INVOICE_SEVER_CONTRACT_DEFAULT_MODE')
begin
	insert into setopen(intro,sort1) values(2,97)
	insert into setopen(intro,sort1) values(210,98)
	insert into home_usConfig(name,nvalue,tvalue,uid) values('PAYBACK_INVOICE_SEVER_CONTRACT_DEFAULT_MODE',null,1,0)
end

if not exists(select 1 from home_usConfig where name = 'PAYBACK_INVOICE_SEVER_PRODUCT_DEFAULT_VALUES')
begin
	--产品票据类型、是否含税、是否能出库默认值
	declare @PAYBACK_INVOICE_SEVER_PRODUCT_DEFAULT_VALUES as varchar(2000)
	set @PAYBACK_INVOICE_SEVER_PRODUCT_DEFAULT_VALUES=''
	select @PAYBACK_INVOICE_SEVER_PRODUCT_DEFAULT_VALUES = @PAYBACK_INVOICE_SEVER_PRODUCT_DEFAULT_VALUES + (case when  len(@PAYBACK_INVOICE_SEVER_PRODUCT_DEFAULT_VALUES)=0 then '' else ',' end) + cast(id as varchar) from sortonehy where gate2=34 and isStop = 0
	update product set canOutStore = 1,includeTax = 0,invoiceTypes = @PAYBACK_INVOICE_SEVER_PRODUCT_DEFAULT_VALUES

	insert into home_usConfig(name,nvalue,tvalue,uid) values('PAYBACK_INVOICE_SEVER_PRODUCT_DEFAULT_VALUES',null,1,0)
end

if not exists(select 1 from home_usConfig where name = 'PAYBACK_INVOICE_SEVER_CONTRACTLIST_DEFAULT_VALUES')
begin
	--将合同明细的老数据进行处理，合同明细的价格默认为“未税价”，所以“单价”和“税后单价”相等，
	--票据类型默认为空；税率、税额、优惠金额、运杂费默认为0；税前总价、税后总价、优惠后总价和产品总价 都默认等于总价；
	update contractlist set discount=(case when price1=0 or num1=0 then 1 else money1/(cast(price1*num1 as decimal(25,12))) end)
	update contractlist set priceAfterDiscount = discount* price1,priceAfterTax=discount* price1,invoiceType=0,taxRate=0,taxValue=0,concessions=0,extras=0,moneyBeforeTax=money1,moneyAfterTax=money1,moneyAfterConcessions=money1
	insert into home_usConfig(name,nvalue,tvalue,uid) values('PAYBACK_INVOICE_SEVER_CONTRACTLIST_DEFAULT_VALUES',null,1,0)
end


if not exists(select 1 from home_usConfig where name = 'PAYBACK_INVOICE_SEVER_CONTRACTLIST_CUSTOM_FIELDS')
begin
	insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) 
	select * from (
	select '折扣' a ,'discount' b,1 c,1 d,70 e,70 f,18 g,5 h,18 i union all
	select '折后单价','priceAfterDiscount',1,1,70,70,19,5,19 union all
	select '票据类型','invoiceType',1,1,100,100,20,5,20 union all
	select '税率','taxRate',1,1,70,70,21,5,21 union all
	select '含税折后单价','priceAfterTax',1,1,70,70,22,5,22 union all
	select '税前总价','moneyBeforeTax',1,1,70,70,24,5,24 union all
	select '税后总价','moneyAfterTax',1,1,70,70,25,5,25 union all
	select '税额','taxValue',1,1,70,70,23,5,23 union all
	select '优惠金额','concessions',1,1,70,70,26,5,26 union all
	select '优惠后总价','moneyAfterConcessions',1,1,70,70,27,5,27 union all
	select '运杂费','extras',1,1,70,70,28,5,28
	) a

	update zdymx set gate1=1 where sort1=5 and sorce=1 --产品
	update zdymx set gate1=2 where sort1=5 and sorce=2 --编号
	update zdymx set gate1=3 where sort1=5 and sorce=3 --型号
	update zdymx set gate1=4 where sort1=5 and sorce=4 --单位
	update zdymx set gate1=5 where sort1=5 and sorce=6 --数量
	update zdymx set gate1=6,title='未税单价' where sort1=5 and sorce=5 --未税单价
	update zdymx set gate1=7 where sort1=5 and sorce=18 --折扣
	update zdymx set gate1=7 where sort1=5 and sorce=19 --折后单价
	update zdymx set gate1=8 where sort1=5 and sorce=20 --票据类型
	update zdymx set gate1=8 where sort1=5 and sorce=21 --税率
	update zdymx set gate1=8 where sort1=5 and sorce=22 --含税折后单价
	update zdymx set gate1=9 where sort1=5 and sorce=24 --税前总价
	update zdymx set gate1=10 where sort1=5 and sorce=25 --税后总价
	update zdymx set gate1=10 where sort1=5 and sorce=23 --税额
	update zdymx set gate1=11 where sort1=5 and sorce=26 --优惠金额
	update zdymx set gate1=11 where sort1=5 and sorce=27 --优惠后总价
	update zdymx set gate1=12 where sort1=5 and sorce=28 --运杂费
	update zdymx set gate1=13,title='产品总价' where sort1=5 and sorce=7 --产品总价
	update zdymx set gate1=14 where sort1=5 and sorce=16 --建议进价
	update zdymx set gate1=15 where sort1=5 and sorce=17 --建议总价
	update zdymx set gate1=16 where sort1=5 and sorce=8 --交货日期
	update zdymx set gate1=17 where sort1=5 and sorce=9 --备注
	update zdymx set gate1=18 where sort1=5 and sorce=10 --自定义1
	update zdymx set gate1=19 where sort1=5 and sorce=11 --自定义1
	update zdymx set gate1=20 where sort1=5 and sorce=12 --自定义1
	update zdymx set gate1=21 where sort1=5 and sorce=13 --自定义1
	update zdymx set gate1=22 where sort1=5 and sorce=14 --自定义1
	update zdymx set gate1=23 where sort1=5 and sorce=15 --自定义1

	insert into home_usConfig(name,nvalue,tvalue,uid) values('PAYBACK_INVOICE_SEVER_CONTRACTLIST_CUSTOM_FIELDS',null,1,0)
end


--销售退款转预收款旧数据处理
if not exists(select 1 from home_usConfig where name = 'PAYBACK_TO_PREMONEY')
begin
	insert into bankin2 (company,bz,bank,money1,intro,cateid,date3,date7,del,status_sp,sp,cateid_sp,invoiceMode,money_left,payout2)
	select h.company,isnull(c.bz,h.bz) as bz,0 as bank,y.money1,'销售退款转预收款' as intro,y.op as cateid,y.date2 as date3,y.opdate as date7,1 as del,0 as status_sp,0 as sp,0 as cateid_sp,0 as invoiceMode,y.money1 as money_left,y.ord as payout2 from payout2 y
	inner join contractth h on h.ord=y.contractth and h.del=1
	left join contract c on c.ord=h.contract and c.del=1
	where y.del=1 and y.complete=2 and isnull(y.bank,0)=0 
	and y.ord not in (select payout2 from bankin2 where isnull(payout2,0)>0)

	insert into home_usConfig(name,nvalue,tvalue,uid) values('PAYBACK_TO_PREMONEY',null,1,0)
end 

--分配预收款余额
if exists(select top 1 1 from bankin2 where bz is null)
begin
	update bankin2 set bz=(select bz from sortbank where id=bankin2.bank) where isnull(bz,0)=0  --必须
	declare @id int 
	select company,bz, money1-isnull((select sum(isnull(money_left,0)) from bankin2 where isnull(sp,0)=0 and isnull(status_sp,0) =0 and bz=telbank.bz and company=telbank.company),0) as money2 into #telbank from telbank
	while exists(select top 1 1 from #telbank where money2>0)
	begin
		set @id = 0
		select top 1 @id=id from bankin2 where money1>0 and del=1 and isnull(money_left,0)=0 and company in (select company from #telbank where money2>0) and isnull(sp,0)=0 and isnull(status_sp,0)=0 order by id desc 
		if @id>0
		begin 
			update bankin2 set money_left=(select case when money2-bankin2.money1>=0 then bankin2.money1 else money2 end from #telbank where bz=bankin2.bz and company=bankin2.company) where id=@id
			update a set money2=money2 - money_left from #telbank a ,bankin2 b where a.bz=b.bz and a.company=b.company and b.id=@id
		end
		else
		begin
			delete from #telbank
		end 
	end 
	drop table #telbank
	update bankin2 set money_left = 0 where isnull(money_left,0)=0 and isnull(sp,0)=0 and isnull(status_sp,0)=0
end
--历史开票记录处理
if not exists(select 1 from home_usConfig where name = 'PAYBACK_TO_INVOICE')
begin
	insert into paybackinvoice (company,fromtype,fromid,invoicetype,invoicemode
	,invoicenum, invoicely,date1,date7,money1,bz
	, invoicedate, invoicecate ,invoicedatetime,cateid , cateid2,cateid3,addcate,addcate2,addcate3
	,isinvoiced, del)
	select company,'CONTRACT' as fromtype, contract as fromid,isnull(tik,0) as invoicetype,1 as invoicemode
	, tikname as invoicenum, IsUsePJLY as invoicely,date1,date7,money1,(select bz from contract where ord=payback.contract) as bz
	, date3 as invoicedate, tik_person as invoicecate ,date3 as invoicedatetime,cateid , cateid2,cateid3,addcate,addcate2,addcate3
	,(case isnull(complete2,2) when 2 then 0 when 3 then 1 else 0 end ) as isinvoiced,1 as del
	from payback 
	where del=1

	insert into home_usConfig(name,nvalue,tvalue,uid) values('PAYBACK_TO_INVOICE',null,1,0)

	update payback set paybackType=3 where isnull(qc_bz,0)>0
end 

if not exists(select 1 from home_usConfig where name = 'CONTRACT_TH_DEFAULT_THTYPE_VALUE')
begin
	update contractth set thType='GOODS_MONEY'
	insert into home_usConfig(name,nvalue,tvalue,uid) values('CONTRACT_TH_DEFAULT_THTYPE_VALUE',null,1,0)
end

if not exists(select 1 from home_usConfig where name = 'CONTRACT_TERMINATED_STATUS_DEFAULT_VALUE')
begin
	update contract set isTerminated=0
	insert into home_usConfig(name,nvalue,tvalue,uid) values('CONTRACT_TERMINATED_STATUS_DEFAULT_VALUE',null,1,0)
end

GO


--更新Pay表老数据money1,money2,money3,money4,money5,money6为空更新为默认值为0
if exists(select money1 from pay where money1 is NULL) Update pay set money1=0 where money1 is NULL
if exists(select money2 from pay where money2 is NULL) Update pay set money2=0 where money2 is NULL
if exists(select money3 from pay where money3 is NULL) Update pay set money3=0 where money3 is NULL
if exists(select money4 from pay where money4 is NULL) Update pay set money4=0 where money4 is NULL
if exists(select money5 from pay where money5 is NULL) Update pay set money5=0 where money5 is NULL
if exists(select money6 from pay where money6 is NULL) Update pay set money6=0 where money6 is NULL

GO

--binary.2014.05.15.优化销售自动化回收、跟进性能
if not exists(select 1 from dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[tel]') AND name = N'tel_back')
CREATE NONCLUSTERED INDEX [tel_back] ON [dbo].[tel] 
(
	[ord] ASC,
	[sort] ASC,
	[sort1] ASC,
	[cateid] ASC,
	[del] DESC,
	[sort3] ASC,
	[sp] ASC,
	[date2] DESC
)

GO

--binary.2014.05.15.优化销售自动化回收性能
if not exists(select 1 from dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[sort5]') AND name = N'sort_backIndex')
CREATE NONCLUSTERED INDEX [sort_backIndex] ON [dbo].[sort5] 
(
	[ord] ASC,
	[unautoback] ASC,
	[unback] ASC,
	canremind ASC, reminddays asc
)

--binary.2014.05.15.优化销售自动化跟进性能
if not exists(select 1 from dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[reply]') AND name = N'reply_SaleBack')
CREATE NONCLUSTERED INDEX [reply_SaleBack] ON [dbo].[reply] 
(
	[ord] ASC,
	[cateid] ASC,
	[date7] ASC,
	[del] ASC
)

GO

--binary.2014.05.15.优化销售自动化回收性能
if not exists(select 1 from dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[contract]') AND name = N'back_contract')
CREATE NONCLUSTERED INDEX [back_contract]
ON [dbo].[contract] ([cateid],[del],[date7])

GO

--Sword.2014.05.26.客户回访权限 sort1=94 sort2=9 改为不带范围的权限
if exists(select 1 from power where sort1=94 and sort2=9 and qx_open=3) update power set qx_open = 1 where sort1=94 and sort2=9 and qx_open=3

--Sword.2014.05.26.客户回访状态 sale_callback
if exists(select 1 from sale_callback where isback is null ) 
begin
	update sale_callback set isback =1  where isback is null and statusid>0 and statusid in (select ord from sortonehy where sort1 like '%回访完毕%' or sort1 like '%已回访%')
	update sale_callback set isback =0  where isback is null
end

--Sword.2014-5-29.同步合同明细出库发货数据
if not exists(select 1 from home_usConfig where name = 'CONTRACTLIST_ZDY_TO_KUOUTLIST_SENDLIST_VALUE')
begin
	--更新已有的出库发货明细自定义
	update k set k.zdy1 = l.zdy1,k.zdy2 = l.zdy2,k.zdy3 = l.zdy3,k.zdy4 =l.zdy4,k.zdy5 = l.zdy5,k.zdy6 = l.zdy6 from kuoutlist k,kuout o , contractlist l where k.kuout=o.ord and o.sort1=1 and k.contractlist=l.id
	update k set k.zdy1 = l.zdy1,k.zdy2 = l.zdy2,k.zdy3 = l.zdy3,k.zdy4 =l.zdy4,k.zdy5 = l.zdy5,k.zdy6 = l.zdy6 from kuoutlist2 k,kuout o , contractlist l where k.kuout=o.ord and o.sort1=1 and k.contractlist=l.id
	update k set k.zdy1 = l.zdy1,k.zdy2 = l.zdy2,k.zdy3 = l.zdy3,k.zdy4 =l.zdy4,k.zdy5 = l.zdy5,k.zdy6 = l.zdy6 from sendlist k,kuout o , contractlist l where k.kuout=o.ord and o.sort1=1 and k.contractlist=l.id
	insert into home_usConfig(name,nvalue,tvalue,uid) values('CONTRACTLIST_ZDY_TO_KUOUTLIST_SENDLIST_VALUE',null,1,0)
end

GO
--合同基础设置调整
if not exists(select 1 from home_usConfig where name = 'CONTRACTLIST_CUSTOM_FIELDS_OPTIMIZE')
begin
	delete zdymx where sort1=5 and sorce in (27,28)


	insert into zdymx(title,name,sort,set_open,kd,kd2,gate1,sort1,sorce) 
	select '含税单价','priceIncludeTax',1,1,70,70,22,5,27

	update zdymx set gate1=1 where sort1=5 and sorce=1 --产品
	update zdymx set gate1=2 where sort1=5 and sorce=2 --编号
	update zdymx set gate1=3 where sort1=5 and sorce=3 --型号
	update zdymx set gate1=4 where sort1=5 and sorce=4 --单位
	update zdymx set gate1=5 where sort1=5 and sorce=6 --数量
	update zdymx set sort=2,gate1=6 where sort1=5 and sorce=5 --未税单价
	update zdymx set sort=2,gate1=7 where sort1=5 and sorce=18 --折扣
	update zdymx set sort=2,gate1=8,title='未税折后单价' where sort1=5 and sorce=19 --未税折后单价
	update zdymx set sort=2,gate1=9 where sort1=5 and sorce=27 --含税单价
	update zdymx set sort=2,gate1=10 where sort1=5 and sorce=22 --含税折后单价
	update zdymx set sort=2,gate1=11 where sort1=5 and sorce=20 --票据类型
	update zdymx set sort=2,gate1=12 where sort1=5 and sorce=21 --税率
	update zdymx set sort=2,gate1=13 where sort1=5 and sorce=24 --税前总价
	update zdymx set sort=2,gate1=14 where sort1=5 and sorce=23 --税额
	update zdymx set sort=2,gate1=15 where sort1=5 and sorce=25 --税后总价
	update zdymx set sort=2,gate1=16 where sort1=5 and sorce=26 --优惠金额
	update zdymx set gate1=17 where sort1=5 and sorce=7 --产品总价
	update zdymx set gate1=18 where sort1=5 and sorce=16 --建议进价
	update zdymx set gate1=19 where sort1=5 and sorce=17 --建议总价
	update zdymx set gate1=20 where sort1=5 and sorce=8 --交货日期
	update zdymx set gate1=21 where sort1=5 and sorce=9 --备注
	update zdymx set gate1=22 where sort1=5 and sorce=10 --自定义1
	update zdymx set gate1=23 where sort1=5 and sorce=11 --自定义1
	update zdymx set gate1=24 where sort1=5 and sorce=12 --自定义1
	update zdymx set gate1=25 where sort1=5 and sorce=13 --自定义1
	update zdymx set gate1=26 where sort1=5 and sorce=14 --自定义1
	update zdymx set gate1=27 where sort1=5 and sorce=15 --自定义1

	--处理合同运杂费字段历史数据
	update contract set extras = 0 where extras is null
	update contract set extras = b.money1 from (
		select sum(isnull(extras,0)) money1,contract cid from contractlist group by contract
	) b where b.cid=contract.ord

	--处理合同明细中新增的含税单价字段值(含税折后单价除以折扣)
	update contractlist set priceIncludeTax = (case when discount = 0 then 0 else priceAfterTax / discount end) where priceIncludeTax is null

	--增加设置项(开票方式)
	if not exists(select 1 from setopen where sort1=99) insert into setopen(sort1,intro) values(99,1)

	--增加设置项(折扣最大值)
	if not exists(select 1 from setjm3 where ord='2014053101') Insert Into setjm3(ord,intro) values('2014053101','1')
	--增加设置项(折扣小数位数)
	if not exists(select 1 from setjm3 where ord='2014053102') Insert Into setjm3(ord,num1) values('2014053102','2')

	insert into home_usConfig(name,nvalue,tvalue,uid) values('CONTRACTLIST_CUSTOM_FIELDS_OPTIMIZE',null,1,0)
end

GO
--sword 更新收款开票明细旧数据中的数量NUM1 
if not exists(select 1 from home_usConfig where name = 'PAYBACK_INVOICE_LIST_UPDATENUM')
begin
	--收款明细
	update l set l.num1=dbo.formatNumber((case when c.money1=0 then c.num1 else cast(l.money1/c.money1 as decimal(25,12)) * c.num1 end),isnull(s.num1,2) ,0)  
	from paybacklist l
	inner join contractlist c on c.id = l.contractlist
	left join (select num1 from setjm3  where ord=88) s on 1=1
	where l.num1 is null
	--开票明细
	update l set l.num1=dbo.formatNumber((case when c.money1=0 then c.num1 else  cast(l.money1/c.money1 as decimal(25,12)) * c.num1 end),isnull(s.num1,2) ,0)  
	from paybackinvoice_list l
	inner join contractlist c on c.id = l.contractlist
	left join (select num1 from setjm3  where ord=88) s on 1=1
	where l.num1 is null

	insert into home_usConfig(name,nvalue,tvalue,uid) values('PAYBACK_INVOICE_LIST_UPDATENUM',null,1,0)
end 

GO

--主单据折扣表示方式改变
if not exists(select 1 from home_usConfig where name = 'MAIN_ORDER_DISCOUNT_VALUE')
begin
	update contract set zk=case when zk=-1 then 1 else zk/10 end , yhtype=1  where isnull(yhtype,1)=1
	update chance set zk=case when zk=-1 then 1 else zk/10 end, yhtype=1 where isnull(yhtype,1)=1
	update price set zk=case when zk=-1 then 1 else zk/10 end, yhtype=1 where isnull(yhtype,1)=1
	insert into home_usConfig(name,nvalue,tvalue,uid) values('MAIN_ORDER_DISCOUNT_VALUE',null,1,0)
end
--销售价格控制(销售价格显示控制-添加)
if not exists(select 1 from home_usConfig where name = 'CONTRACT_PRICE_CONTROL_SETTING')
begin
	if not exists(select 1 from setopen where sort1=2014061301) insert into setopen(sort1,intro) values(2014061301,1)

	insert into home_usConfig(name,nvalue,tvalue,uid) values('CONTRACT_PRICE_CONTROL_SETTING',null,1,0)
end

GO

--销售退货关于退货类型旧数据处理 SWORD
if not exists(select 1 from home_usConfig where name = 'CONTRACTTH_DETAIL_THTYPE_VALUE')
begin
	insert into contractthListDetail (ord,num1,money1,unit,bz,money2,contractth,contractthList,contract,contractlist,thType,addcate,del)
	select l.ord,l.num1,l.money1,l.unit, c.bz ,
	(case when h2.hl=0 then l.money1 * isnull(h.hl,1) else cast(l.money1 * isnull(h.hl,1) as decimal(25,12))/isnull(h2.hl,1) end) as money2,
	c.ord as contractth,l.id as contractthList,l.contract,l.contractlist,isnull(c.thType,'GOODS_MONEY') as thType,c.addcate, c.del
	from contractthList l 
	inner join contractth c on c.ord=l.caigou and (c.del=1 or (c.del=2 and c.sp=0 )) and thType<>'NEW'
	left join contract ct on ct.ord = c.contract
	left join hl h on h.date1 = c.date3 and h.bz=c.bz 
	left join hl h2 on h2.date1 = ct.date3 and h2.bz=ct.bz
	insert into home_usConfig(name,nvalue,tvalue,uid) values('CONTRACTTH_DETAIL_THTYPE_VALUE',null,1,0)
end

GO

if not exists(select 1 from home_usConfig where name = 'PRODUCT_NAVIGATION_PAGE_CONDITION')
begin
	if not exists(select 1 from setjm3 where ord='2014062801') insert into setjm3(ord,num1) values(2014062801,100)
	if not exists(select 1 from setjm3 where ord='2014062802') insert into setjm3(ord,num1) values(2014062802,20)

	insert into home_usConfig(name,nvalue,tvalue,uid) values('PRODUCT_NAVIGATION_PAGE_CONDITION',null,1,0)
end

GO

delete zdymx where id not in (select MIN(id) from zdymx group by title, name, sort, set_open , kd, kd2,  sort1, sorce)

GO

if exists(select top 1 a.id from bank a inner join payout b on a.gl2=b.ord and a.sort=2 and b.cls=2)
begin
	update a set a.sort=15,a.intro=(case a.intro when '采购付款' then '委外付款' else a.intro end) from bank a inner join payout b on a.gl2=b.ord and a.sort=2 and b.cls=2
end

GO

--2018-6-10.ljh.'运费专用'简化为'运费'
if exists(SELECT 1 FROM sortonehy WHERE gate2 = 61 AND del = 1 AND id1 = 1000010 and sort1='运费专用')
begin
	update sortonehy set sort1='运费' where gate2 = 61 AND del = 1 AND id1 = 1000010 and sort1='运费专用'
end

GO

if not exists(select 1 from home_usConfig where name = 'REMIND_HISTORY_RECORD_DEAL') 
begin 
	--将待审批的单据加入提醒队列
	insert into reminderQueue(orderId,reminderConfig,subCfgId,reloadFlag,daysFromNow,orderStat)
	--客户资质审批
	select b.ord,149,0,0,0,0 from tel b 
	inner join sortFieldsContent c on c.ord = b.ord and c.del = 1 
	where b.del=1 and sort3=1 and status_sp_qualifications<>0 and status_sp_qualifications<>4
	and b.ord not in (select orderId from reminderQueue where reminderConfig=149)
	union all
	--项目审批
	SELECT b.ord,64,0,0,0,0 from chance b 
	where (b.del = 1 OR b.del = 3) and cateid_sp<>0 and sp>=0
	and b.ord not in (select orderId from reminderQueue where reminderConfig=64)
	union all
	--报价审批
	SELECT b.ord,13,0,0,0,0 from price b 
	where (b.del = 1 OR b.del = 3) and cateid_sp<>0 and id_sp>=0
	and b.ord not in (select orderId from reminderQueue where reminderConfig=13)
	union all
	--合同审批
	SELECT b.ord,14,0,0,0,0 from contract b 
	where (b.del = 1 OR b.del = 3) and cateid_sp<>0 and sp>=0
	and b.ord not in (select orderId from reminderQueue where reminderConfig=14)
	union all
	--销售退货审批
	SELECT b.ord,69,0,0,0,0 from contractth b 
	where (b.del = 1 OR b.del = 3) and cateid_sp<>0 and sp>=0
	and b.ord not in (select orderId from reminderQueue where reminderConfig=69)
	union all
	--供应商资质审批
	select b.ord,148,0,0,0,0 from tel b 
	inner join sortFieldsContent c on c.ord = b.ord and c.del = 1 
	where b.del=1 and sort3=2 and status_sp_qualifications<>0 and status_sp_qualifications<>4
	and b.ord not in (select orderId from reminderQueue where reminderConfig=148)
	union all
	--采购审批
	SELECT b.ord,16,0,0,0,0 from caigou b 
	where (b.del = 1 OR b.del = 3) and cateid_sp<>0 and sp>=0
	and b.ord not in (select orderId from reminderQueue where reminderConfig=16)
	union all
	--来料质检审批
	SELECT b.id,205,0,0,0,0 from caigouQC b 
	where b.del = 1 and cateid_sp <> 0 and complete >= 0 and complete <> 3
	and b.id not in (select orderId from reminderQueue where reminderConfig=205)
	union all
	--入库审批
	SELECT b.ord,60,0,0,0,0 from kuin b 
	where b.del = 1 and complete1<>2 and complete1<>3
	and b.ord not in (select orderId from reminderQueue where reminderConfig=60)
	union all
	--出库审批
	SELECT b.ord,61,0,0,0,0 from kuout b 
	where b.del = 1 and complete1<>2 and complete1<>3
	and b.ord not in (select orderId from reminderQueue where reminderConfig=61)
	union all
	--调拨申请审批
	select b.ord,153,0,0,0,0 from kumove b 
	where b.del=1 and complete1=1
	and b.ord not in (select orderId from reminderQueue where reminderConfig=153)
	union all
	--养护审批
	select b.ord,139,0,0,0,0 from maintain b 
	where b.del=1 and status<>0 and status<>4
	and b.ord not in (select orderId from reminderQueue where reminderConfig=139)
	union all
	--发货审批
	SELECT b.ord,62,0,0,0,0 from send b 
	where (b.del = 1 OR b.del = 3) and complete1<>0 and complete1<>1
	and b.ord not in (select orderId from reminderQueue where reminderConfig=62)
	union all
	--预收款审批
	SELECT b.id,65,0,0,0,0 from bankin2 b 
	where (b.del = 1 OR b.del = 3) and sp>0 and cateid_sp>0 
	and b.id not in (select orderId from reminderQueue where reminderConfig=65)
	union all
	--预付款审批
	SELECT b.id,206,0,0,0,0 from bankout2 b 
	where (b.del = 1 OR b.del = 3) and sp>0 and cateid_sp>0
	and b.id not in (select orderId from reminderQueue where reminderConfig=206)
	union all
	--付款审批
	SELECT b.ord,50,0,0,0,0 from payout b 
	where (b.del = 1 OR b.del = 3) and sp>0 and cateid_sp>0
	and b.ord not in (select orderId from reminderQueue where reminderConfig=50)
	union all
	--工资审批(财务)
	select b.id,111,0,0,0,0 from wages b 
	where b.del=1 and isnull(salaryClass,0)=0 and sp<>-1 and sp<>0
	and b.id not in (select orderId from reminderQueue where reminderConfig=111)
	union all
	--工资审批(人资)
	select b.id,110,0,0,0,0 from wages b 
	where b.del=1 and isnull(salaryClass,0)>0 and sp<>-1 and sp<>0
	and b.id not in (select orderId from reminderQueue where reminderConfig=110)
	union all
	--预算审批
	select b.ord,145,0,0,0,0 from budget b 
	where b.del=1 and status<>0 and status<>3
	and b.ord not in (select orderId from reminderQueue where reminderConfig=145)
	union all
	--费用申请审批
	SELECT b.id,40,0,0,0,0 from paysq b 
	where (b.del = 1 OR b.del = 3) and complete<>1 and complete<>3
	and b.id not in (select orderId from reminderQueue where reminderConfig=40)
	union all
	--费用报销审批
	SELECT b.id,41,0,0,0,0 from paybx b 
	where (b.del = 1 OR b.del = 3) and sp_id<>-1 and sp_id<>0
	and b.id not in (select orderId from reminderQueue where reminderConfig=41)
	union all
	--费用借款审批
	SELECT b.id,42,0,0,0,0 from payjk b 
	where (b.del = 1 OR b.del = 3) and sp_id<>-1 and sp_id<>0
	and b.id not in (select orderId from reminderQueue where reminderConfig=42)
	union all
	--费用返还审批
	SELECT b.ord,43,0,0,0,0 from pay b 
	where (b.del = 1 OR b.del = 3) and complete<>12 and complete<>8 and cateid_sp<>0
	and b.ord not in (select orderId from reminderQueue where reminderConfig=43)
	union all
	--文档审批
	select b.id,135,0,0,0,0 from document b 
	where b.del=1 and spFlag<>1 and spFlag<>-1
	and b.id not in (select orderId from reminderQueue where reminderConfig=135)
	union all
	--车辆申请审批
	select b.use_id,70,0,0,0,0 from O_carUse b 
	where b.use_del=1 and use_type=1 and use_complete<>3 and use_complete<>4
	and b.use_id not in (select orderId from reminderQueue where reminderConfig=70)
	union all
	--用品领用审批
	SELECT b.id,208,0,0,0,0 from O_productOut b 
	where b.get_del = 1 and get_storecateid<>0 and get_store<>2
	and b.id not in (select orderId from reminderQueue where reminderConfig=208)
	union all
	--用品返还审批
	SELECT b.id,207,0,0,0,0 from O_proReturn b 
	where b.ret_del = 1 and ret_bcateid<>0 and ret_state<>1
	and b.id not in (select orderId from reminderQueue where reminderConfig=207)
	union all
	--用人申请审批
	select b.id,71,0,0,0,0 from hr_NeedPerson b 
	where b.del=0 and status<>3 and status<>2
	and b.id not in (select orderId from reminderQueue where reminderConfig=71)
	union all
	--招聘计划审批
	select b.id,122,0,0,0,0 from hr_ret_plan b 
	where b.del=0 and status<>3 and status<>2
	and b.id not in (select orderId from reminderQueue where reminderConfig=122)
	union all
	--简历审批
	select b.id,123,0,0,0,0 from hr_Resume b 
	where b.del=0 and status<>3 and status<>2
	and b.id not in (select orderId from reminderQueue where reminderConfig=123)
	union all
	--面试审批
	select b.id,124,0,0,0,0 from hr_interview b 
	where b.del=0 and status<>3 and status<>2
	and b.id not in (select orderId from reminderQueue where reminderConfig=124)
	union all
	--培训计划审批
	select b.id,125,0,0,0,0 from hr_train_plan b 
	where b.del=0 and status<>3 and status<>2
	and b.id not in (select orderId from reminderQueue where reminderConfig=125)
	union all
	--试卷审批
	select b.id,126,0,0,0,0 from hr_expaper b 
	where b.del=0 and status<>3 and status<>2
	and b.id not in (select orderId from reminderQueue where reminderConfig=126)
	union all
	--申诉审批（申诉处理）
	select b.id,150,0,0,0,0 from hr_perform_ss b 
	where b.del=0 and status<>3 and status<>2
	and b.id not in (select orderId from reminderQueue where reminderConfig=150)
	union all
	--加班审批
	select b.id,108,0,0,0,0 from hr_AppHoliday b 
	where b.del=0 and (KQClass in (select id from hr_KQClass where sortID=2 and del=0) or KQClass=2) and status<>3 and status<>2
	and b.id not in (select orderId from reminderQueue where reminderConfig=108)
	union all
	--请假审批
	select b.id,107,0,0,0,0 from hr_AppHoliday b 
	where b.del=0 and (KQClass in (select id from hr_KQClass where sortID=1 and del=0) or KQClass=1) and status<>3 and status<>2
	and b.id not in (select orderId from reminderQueue where reminderConfig=107)
	union all
	--外勤审批
	select b.id,109,0,0,0,0 from hr_AppHoliday b 
	where b.del=0 and (KQClass in (select id from hr_KQClass where sortID=3 and del=0) or KQClass=3) and status<>3 and status<>2
	and b.id not in (select orderId from reminderQueue where reminderConfig=109)
	union all
	--员工调薪审批
	select b.id,127,0,0,0,0 from hr_person_salary b 
	where b.del=0 and status<>3 and status<>2
	and b.id not in (select orderId from reminderQueue where reminderConfig=127)
	union all
	--员工合同审批
	select b.id,128,0,0,0,0 from hr_person_contract b 
	where b.del=0 and status<>3 and status<>2
	and b.id not in (select orderId from reminderQueue where reminderConfig=128)
	union all
	--人事制度审批
	select b.id,129,0,0,0,0 from hr_regime b 
	where b.del=0 and status<>3 and status<>2
	and b.id not in (select orderId from reminderQueue where reminderConfig=129)
	union all
	--员工转正审批
	select b.id,130,0,0,0,0 from hr_positive b 
	where b.del=0 and status<>3 and status<>2
	and b.id not in (select orderId from reminderQueue where reminderConfig=130)
	union all
	--员工离职审批
	select b.id,131,0,0,0,0 from hr_leave b 
	where b.del=0 and status<>3 and status<>2
	and b.id not in (select orderId from reminderQueue where reminderConfig=131)
	union all
	--员工调动审批
	select b.id,132,0,0,0,0 from hr_Transfer b 
	where b.del=0 and status<>3 and status<>2
	and b.id not in (select orderId from reminderQueue where reminderConfig=132)
	union all
	--员工休职审批
	select b.id,133,0,0,0,0 from hr_off_staff b 
	where b.del=0 and status<>3 and status<>2
	and b.id not in (select orderId from reminderQueue where reminderConfig=133)
	union all
	--员工复职审批
	select b.id,134,0,0,0,0 from hr_reinstate b 
	where b.del=0 and status<>3 and status<>2
	and b.id not in (select orderId from reminderQueue where reminderConfig=134)

	insert into home_usConfig(name,nvalue,tvalue,uid) values('REMIND_HISTORY_RECORD_DEAL',null,1,0)
end

GO

if not exists(select 1 from home_usConfig where name = 'PRODUCT_REPLACE_BR') 
begin 
	--产品名称清除回车换行符
	update product set title = replace(replace(title,char(10),''),char(13),'') where charindex(char(10),title)>0 or charindex(char(13),title)>0
	insert into home_usConfig(name,nvalue,tvalue,uid) values('PRODUCT_REPLACE_BR',null,1,0)
end

GO

if not exists(select 1 from home_usConfig where name = 'REMIND_HISTORY_CANCEL_INVALID') 
begin 
	--将之前的产品有效期提醒取消信息清空
	update ku set unRemind = null where unRemind is not null
	insert into home_usConfig(name,nvalue,tvalue,uid) values('REMIND_HISTORY_CANCEL_INVALID',null,1,0)
end

GO

if exists(select 1 from C2_CodeTypes where fromSys = 2 and title = '名片自定义')
begin
	update C2_CodeTypes set title = '员工档案自定义' where fromSys = 2 and title = '名片自定义'
end

GO

if not exists(select 1 from home_usConfig where name = 'Code2_Default_Setting_Init') 
begin
	--二维码生成规则设置，默认值：网址模式、自动生成
	update C2_CodeTypes set isAuto = 1, entype = 1 where fromSys = 2
	insert into home_usConfig(name,nvalue,tvalue,uid) values('Code2_Default_Setting_Init',null,1,0)
end

GO

if not exists(select 1 from home_usConfig where name = 'Code2_Fields_Setting_Edit') 
begin
	--二维码生成规则字段UI
	update a set uType=10 from C2_CodeTypeFields a where fieldName = 'intro3'
	insert into home_usConfig(name,nvalue,tvalue,uid) values('Code2_Fields_Setting_Edit',null,1,0)
end

GO

if not exists(select 1 from home_usConfig where name = 'update_bomlist_xhl100') 
begin
	--2015.01.17.之前的BOMlist非叶子节点损耗率按X100模式存储的，处理其老数据
	insert into home_usConfig(name,nvalue,tvalue,uid) values('update_bomlist_xhl100',null,1,0)
	update M_BOMList set PCWastage=PCWastage/100 where PCWastage >0 and RankCode >=0
end

GO

if not exists(select 1 from home_usConfig where name = 'REMIND_HISTORY_RECORD_TEL_SP_DEAL') 
begin 
	--将待审批的单据加入提醒队列
	insert into reminderQueue(orderId,reminderConfig,subCfgId,reloadFlag,daysFromNow,orderStat)
	--客户审批
	select b.ord,216,0,0,0,0 from tel b 
	where b.del=1 and b.order1 = 3 and isnull(b.cateid4,0) <> 0
	and b.ord not in (select orderId from reminderQueue where reminderConfig=216)

	insert into home_usConfig(name,nvalue,tvalue,uid) values('REMIND_HISTORY_RECORD_TEL_SP_DEAL',null,1,0)
end

GO

if not exists(select 1 from home_usConfig where name = 'REMIND_HOME_OLD_CONFIG_DEAL') 
begin 
	--最新跟进
	update home_maincards_us  set setJm = 154 where id = 10006
	--最新项目
	update home_maincards_us  set setJm = 146 where id = 10007
	--最新报价
	update home_maincards_us  set setJm = 152 where id = 10008
	--最新合同
	update home_maincards_us  set setJm = 151 where id = 10009
	--最新售后
	update home_maincards_us  set setJm = 137 where id = 10011
	--最新采购
	update home_maincards_us  set setJm = 140 where id = 10013
	--最新进度汇报
	update home_maincards_us  set setJm = 117 where id = 10021
	--最新客户
	update home_maincards_us  set setJm = 147 where id = 10048
	--指派日程完成
	update home_maincards_us  set setJm = 57 where id = 10057
	--请假审批
	update home_maincards_us  set setJm = 107 where id = 10042
	--加班审批
	update home_maincards_us  set setJm = 108 where id = 10043
	--外勤审批
	update home_maincards_us  set setJm = 109 where id = 10045
	--申诉处理
	update home_maincards_us  set title = '申诉审批（申诉处理）',setJm = 150 where id = 10047
	--最新询价
	update home_maincards_us  set setJm = 136 where id = 10012
	--入库审批
	update home_maincards_us  set setJm = 60 where id = 10016
	--出库审批
	update home_maincards_us  set setJm = 61 where id = 10017
	--发货审批
	update home_maincards_us  set title = '发货审批',setJm = 62 where id = 10003
	--最新生产计划
	update home_maincards_us  set setJm = 114 where id = 10018
	--最新生产订单
	update home_maincards_us  set setJm = 115 where id = 10019
	--最新委外加工
	update home_maincards_us  set setJm = 116 where id = 10020
	--最新生产质检
	update home_maincards_us  set title = '最新生产质检',setJm = 118 where id = 10022
	--备忘录
	update home_maincards_us  set setJm = 100 where id = 10034
	--知识库
	update home_maincards_us  set setJm = 101 where id = 10035
	--用品领用审批
	update home_maincards_us  set setJm = 208 where id = 10036
	--个性网址
	delete home_maincards_us where id=10033
	delete home_maincards_def where id=10033
	--用品返还审批
	update home_maincards_us set  setJm = 207 where id = 10037
	--用品库存预警
	update home_maincards_us set  setJm = 105 where id = 10038
	--车辆申请审批
	update home_maincards_us set  setJm = 70 where id = 10039
	--车辆保险提醒
	update home_maincards_us set  setJm = 155 where id = 10040
	--最新预购
	update home_maincards_us set  setJm = 141 where id = 10054
	--项目共享
	update home_maincards_us set  setJm = 54 where id = 10055
	--进展领导点评
	update home_maincards_us set  setJm = 56 where id = 10056
	--日程领导点评
	update home_maincards_us set  setJm = 58 where id = 10058
	--项目审批
	update home_maincards_us set  setJm = 64 where id = 10059
	--预收款审批
	update home_maincards_us set  setJm = 65 where id = 10060
	--供应商资质到期
	update home_maincards_us set  setJm = 66 where id = 10061
	--客户资质到期
	update home_maincards_us set  setJm = 67 where id = 10062
	--养护到期
	update home_maincards_us set  setJm = 68 where id = 10063
	--用人申请审批
	update home_maincards_us set  setJm = 71 where id = 10064
	--最新考勤记录
	update home_maincards_us  set setJm = 0,visible = 0 where id = 10046
	--产品有效期
	update home_maincards_us  set title = '产品有效期' where id = 10052
	--申诉审批
	update home_maincards_us  set title = '申诉审批' where id = 10047

	--交流提醒
	update home_maincards_us set title='交流提醒' where id=10031

	insert into home_usConfig(name,nvalue,tvalue,uid) values('REMIND_HOME_OLD_CONFIG_DEAL',null,1,0)
end

GO

if not exists(select 1 from home_usConfig where name = 'REMIND_HOME_DEL_CONFIG_KAOQIN') 
begin 
	--最新考勤记录
	delete home_maincards_us where id = 10046
	delete home_maincards_def where id = 10046

	insert into home_usConfig(name,nvalue,tvalue,uid) values('REMIND_HOME_DEL_CONFIG_KAOQIN',null,1,0)
end

GO

if not exists(select 1 from home_usConfig where name = 'REPAIR_NODE_OLD_CONFIG_DEAL')	--维修单节点关系冗余，老数据处理
begin 
	--更新冗余节点所属维修单状态
	update o set Status = 2
		from 
		RepairOrder o
		left join 
		(select distinct(m.RepairOrder) as RepairOrder	--缩小处理范围，只处理有冗余节点的数据
			from Copy_NodesMap m
			left join Copy_ProcessNodeSet s1 on m.NodeID = s1.Id
			left join Copy_ProcessNodeSet s2 on m.NextNodeID = s2.Id
			where s1.Id is null or s2.Id is null
		) e on e.RepairOrder = o.id
		where o.Del = 1 and o.Status = 1
		and exists 
		(select 1 from RepairDeal rd 
			left join Copy_NodesMap mm on mm.NodeID = rd.NodeID
			left join Copy_ProcessNodeSet ss on ss.Id = mm.NextNodeID
			where rd.del = 1 and rd.RepairOrder = o.id and ss.Id is null
		)
	--更新冗余节点所属受理单状态
	update repair_sl set 
		complete1 = case when wxnum = 0 then 0 when mxnum = wxnum then 2 else 1 end,
		complete2 = case when mxnum = wx2 then 2 when (wx1=0 and wx2=0) then 0 else 1 end
		from repair_sl a
		inner join
		(
			select sl.id,mx.mxnum,wx.wxnum,zz.wx0,zz.wx1,zz.wx2
				from
				(select s.id from repair_sl s
					inner join RepairOrder r on r.repair_sl = s.id
					inner join
					(select distinct(m.RepairOrder) RepairOrder			--缩小处理范围，只处理有冗余节点的数据
						from Copy_NodesMap m
						left join Copy_ProcessNodeSet s1 on m.NodeID = s1.Id
						left join Copy_ProcessNodeSet s2 on m.NextNodeID = s2.Id
						where s1.Id is null or s2.Id is null
					) ro on ro.RepairOrder = r.id
				) sl 
				left join
				(select
					isnull(sum(l.num1),0) as mxnum ,l.repair_sl			--计算明细数量
					from repair_sl_list l 
					inner join repair_sl r on l.repair_sl=r.id and r.del=1 and l.del=1 
					group by l.repair_sl
				) mx on mx.repair_sl = sl.id
				left join
				(select 
					isnull(sum(w.NUM),0) as wxnum,l.repair_sl			--计算派工数量
					from RepairOrder w 
					left join repair_sl_list l on w.repair_sl_list = l.id where w.del=1 
					group by l.repair_sl
				) wx on wx.repair_sl = sl.id
				left join
				(select 
					isnull(sum((case when isnull(w.status,0)=0 then w.num else 0 end) ),0) as wx0,
					isnull(sum((case when isnull(w.status,0)=1 then w.num else 0 end) ),0) as wx1,
					isnull(sum((case when isnull(w.status,0)=2 then w.num else 0 end) ),0) as wx2,l.repair_sl 
					from repair_sl_list l 
					left join RepairOrder w on w.repair_sl = l.repair_sl  and w.repair_sl_list = l.id  and w.del=1 
					where l.del = 1 
					group by l.repair_sl
				) zz on zz.repair_sl = sl.id
		) xxx on xxx.id = a.id
	--删除冗余节点关系
	delete from Comm_NodesMap where Id in (
		select m.id
			from Comm_NodesMap m
			left join Comm_ProcessNodeSet s1 on m.NodeID = s1.Id
			left join Comm_ProcessNodeSet s2 on m.NextNodeID = s2.Id
			where s1.Id is null or s2.Id is null
		)
	--删除冗余节点关系备份
	delete from Copy_NodesMap where Id in (
		select m.id
			from Copy_NodesMap m
			left join Copy_ProcessNodeSet s1 on m.NodeID = s1.Id
			left join Copy_ProcessNodeSet s2 on m.NextNodeID = s2.Id
			where s1.Id is null or s2.Id is null
		)
	insert into home_usConfig(name,nvalue,tvalue,uid) values('REPAIR_NODE_OLD_CONFIG_DEAL',null,1,0)
end

GO

--生成仓库全路径
if exists(select 1 from sortck where fullpath is null)
begin
	exec erp_store_setCkFullPath 0	
end

GO

--维护产品分类深度字段值
declare @cnt int 
set @cnt = 1
update menu set gate2 = case when id1=0 then @cnt else null end
set @cnt = 2

while exists(select top 1 1 from menu where gate2 is null) and @cnt < 100
begin
	update menu set gate2=0 where id1 not in (select id from menu) and id1 <> 0
	update b set b.gate2 = a.gate2+1 from menu a ,menu b where a.id = b.id1 and a.gate2 > 0
	set @cnt = @cnt + 1
end

update menu set gate2 = 0 where gate2 is null

GO

if not exists (select top 1 1 from MMsg_AllocTactics)
begin
	insert into MMsg_AllocTactics(id,name,AllocRule,cycleUnit,canSetRule,curLoopNum,canSelectCate,cateid) values(1,'用户',1,2,1,0,0,0)
	insert into MMsg_AllocTactics(id,name,AllocRule,cycleUnit,canSetRule,curLoopNum,canSelectCate,cateid) values(2,'售后',1,2,0,0,1,0)
	insert into MMsg_AllocTactics(id,name,AllocRule,cycleUnit,canSetRule,curLoopNum,canSelectCate,cateid) values(3,'建议',1,2,0,0,1,0)
	insert into MMsg_AllocTactics(id,name,AllocRule,cycleUnit,canSetRule,curLoopNum,canSelectCate,cateid) values(4,'投诉',1,2,0,0,1,0)
end

GO

if not exists(select 1 from setjm where ord  = 802)
begin
	Insert Into setjm(ord,intro,num1,tq1,fw1,cateid,gate1) values('802','1','0','0','0','63','0')
end

GO

update menuarea set id1 = 0 where id1 is null

GO

update product set unit = cast(isnull(unitjb,0) as varchar(20)) where isnull(unit,'')='' 

GO

update plan1 set date1 = CONVERT(varchar(10),date1,120) where date1>CONVERT(varchar(10),date1,120)

GO

--处理工作互动发言人老数据问题
UPDATE a SET a.userID = ISNULL((SELECT TOP 1 ord FROM gate WHERE name = a.name ORDER BY ord ASC),0) FROM replyhd a WHERE a.userID IS NULL Or a.userID = 0


GO

if not exists(select 1 from home_usConfig where name = 'Gate_IsMobileLoginOn_Old_Data') 
begin
	update a set a.isMobileLoginOn = case when b.cnt > 0 and a.del=1 then 1 else 0 end
	from gate a 
	left join (
		select userid,count(*) cnt from Mob_UserMacMap where useBind = 1 group by userid
	) b on a.ord=b.userid
	where a.isMobileLoginOn is null

	update a set a.useBind = 0 
	from Mob_UserMacMap a
	inner join gate b on a.userid=b.ord
	where isnull(b.isMobileLoginOn,0) = 0

	insert into power(qx_open,qx_intro,ord,sort1,sort2)
	select 
	case when g.top1 = 1 then
		case when p.ord is null then 1 else 3 end
	else 0
	end,
	case when g.top1 = 1 then
		case when p.ord is null then cast(g.ord as varchar) else '-222' end
	else '-222'
	end
	,g.ord,66,20
	from gate g
	left join power p on g.ord=p.ord and p.sort1=66 and p.sort2=12 and p.qx_open = 1
	where g.del=1 and g.top1 = 1 and not exists(select top 1 1 from power where ord=g.ord and sort1=66 and sort2=20)

	insert into home_usConfig(name,nvalue,tvalue,uid) values('Gate_IsMobileLoginOn_Old_Data',null,1,0)
end 

GO

--老数据处理，处理 power表中qx_intro字段“数字-222” 形式的错误数据
if exists(
	select top 1 1 from power where qx_open=1 and (','+cast(qx_intro as varchar(8000)) + ',' like '%0-222%')
)
begin
	UPDATE power SET 
	qx_intro = replace(CAST(qx_intro AS VARCHAR(8000)), '0-222','00')
	where qx_open=1 and (','+cast(qx_intro as varchar(8000)) + ',' like '%0-222%')
end
if exists(
	select top 1 1 from power where qx_open=1 and (','+cast(qx_intro as varchar(8000)) + ',' like '%1-222%')
)
begin
	UPDATE power SET 
	qx_intro = replace(CAST(qx_intro AS VARCHAR(8000)), '1-222','10')
	where qx_open=1 and (','+cast(qx_intro as varchar(8000)) + ',' like '%1-222%')
end
if exists(
	select top 1 1 from power where qx_open=1 and (','+cast(qx_intro as varchar(8000)) + ',' like '%2-222%')
)
begin
	UPDATE power SET 
	qx_intro = replace(CAST(qx_intro AS VARCHAR(8000)), '2-222','20')
	where qx_open=1 and (','+cast(qx_intro as varchar(8000)) + ',' like '%2-222%')
end
if exists(
	select top 1 1 from power where qx_open=1 and (','+cast(qx_intro as varchar(8000)) + ',' like '%3-222%')
)
begin
	UPDATE power SET 
	qx_intro = replace(CAST(qx_intro AS VARCHAR(8000)), '3-222','30')
	where qx_open=1 and (','+cast(qx_intro as varchar(8000)) + ',' like '%3-222%')
end
if exists(
	select top 1 1 from power where qx_open=1 and (','+cast(qx_intro as varchar(8000)) + ',' like '%4-222%')
)
begin
	UPDATE power SET 
	qx_intro = replace(CAST(qx_intro AS VARCHAR(8000)), '4-222','40')
	where qx_open=1 and (','+cast(qx_intro as varchar(8000)) + ',' like '%4-222%')
end
if exists(
	select top 1 1 from power where qx_open=1 and (','+cast(qx_intro as varchar(8000)) + ',' like '%5-222%')
)
begin
	UPDATE power SET 
	qx_intro = replace(CAST(qx_intro AS VARCHAR(8000)), '5-222','50')
	where qx_open=1 and (','+cast(qx_intro as varchar(8000)) + ',' like '%5-222%')
end
if exists(
	select top 1 1 from power where qx_open=1 and (','+cast(qx_intro as varchar(8000)) + ',' like '%6-222%')
)
begin
	UPDATE power SET 
	qx_intro = replace(CAST(qx_intro AS VARCHAR(8000)), '6-222','60')
	where qx_open=1 and (','+cast(qx_intro as varchar(8000)) + ',' like '%6-222%')
end
if exists(
	select top 1 1 from power where qx_open=1 and (','+cast(qx_intro as varchar(8000)) + ',' like '%7-222%')
)
begin
	UPDATE power SET 
	qx_intro = replace(CAST(qx_intro AS VARCHAR(8000)), '7-222','70')
	where qx_open=1 and (','+cast(qx_intro as varchar(8000)) + ',' like '%7-222%')
end
if exists(
	select top 1 1 from power where qx_open=1 and (','+cast(qx_intro as varchar(8000)) + ',' like '%8-222%')
)
begin
	UPDATE power SET 
	qx_intro = replace(CAST(qx_intro AS VARCHAR(8000)), '8-222','80')
	where qx_open=1 and (','+cast(qx_intro as varchar(8000)) + ',' like '%8-222%')
end
if exists(
	select top 1 1 from power where qx_open=1 and (','+cast(qx_intro as varchar(8000)) + ',' like '%9-222%')
)
begin
	UPDATE power SET 
	qx_intro = replace(CAST(qx_intro AS VARCHAR(8000)), '9-222','90')
	where qx_open=1 and (','+cast(qx_intro as varchar(8000)) + ',' like '%9-222%')
end

GO

update a set a.area = b.area from person a inner join tel b on a.company = b.ord and a.area<>b.area
update a set a.trade = b.trade from person a inner join tel b on a.company = b.ord and a.trade<>b.trade

GO

--更新根节点id字段信息
update menu set RootId = case when id1=0 then id else 0 end 
update menu set RootId = id where id1<>0 and id1 not in (select id from menu) 
declare @cnt as int 
set @cnt = 1 
while @cnt < 100 and exists(select 1 from menu where rootId = 0) 
begin 
	update a set a.rootId = b.rootId 
	from menu a 
	inner join menu b on a.id1 = b.id and a.rootId = 0 
	set @cnt = @cnt + 1 
end 

GO

If Not Exists(SELECT 1 FROM home_usConfig WHERE name = 'wx_Invoice')
Begin
	INSERT INTO home_usConfig (name,nvalue,tvalue,uid) values ('wx_Invoice',null,null,0)
End

If Not Exists(SELECT 1 FROM home_usConfig WHERE name = 'wx_OrderTerm_Incomplete')
Begin
	INSERT INTO home_usConfig (name,nvalue,tvalue,uid) values ('wx_OrderTerm_Incomplete',30,'minute',0)
End

If Not Exists(SELECT 1 FROM home_usConfig WHERE name = 'wx_OrderTerm_Complete')
Begin
	INSERT INTO home_usConfig (name,nvalue,tvalue,uid) values ('wx_OrderTerm_Complete',1,'yyyy',0)
End

If Not Exists(SELECT 1 FROM home_usConfig WHERE name = 'wx_Freight')
Begin
	INSERT INTO home_usConfig (name,nvalue,tvalue,uid) values ('wx_freight',null,'0|0',0)
End

If Not Exists(SELECT 1 FROM home_usConfig WHERE name = 'wx_SaleRule_Number')
Begin
	INSERT INTO home_usConfig (name,nvalue,tvalue,uid) values ('wx_SaleRule_Number',1,'',0)
End

If Not Exists(SELECT 1 FROM home_usConfig WHERE name = 'wx_SaleRule_Price')
Begin
	INSERT INTO home_usConfig (name,nvalue,tvalue,uid) values ('wx_SaleRule_Price',1,'',0)
End

If Not Exists(SELECT 1 FROM Shop_HomeGroups WHERE [type] = 'BANNER' AND sort = 99999)
Begin
	INSERT INTO Shop_HomeGroups ([type],name,sort) values ('BANNER','首页Banner',99999)
End

If Exists(SELECT 1 FROM documentlist WHERE l_validity is null)
Begin
	 update a set a.l_validity=b.validity,a.l_date3=b.date3,a.l_date4=b.date4 
	 from documentlist a 
	 inner join document b on b.id = a.document 
	 where a.l_validity is null
End

if not exists(select top 1 1 from home_usconfig where name = 'wx_MMsgOrderAutoCreateTelCreator')
begin
	insert into home_usconfig(name,tvalue,nvalue,uid) values('wx_MMsgOrderAutoCreateTelCreator',0,'',0)
end

if not exists(select top 1 1 from home_usconfig where name = 'wx_MMsgOrderAutoCreateTelCate')
begin
	insert into home_usconfig(name,tvalue,nvalue,uid) values('wx_MMsgOrderAutoCreateTelCate',0,'',0)
end

if not exists(select top 1 1 from home_usconfig where name = 'wx_MMsgOrderAutoCreateTelSort1')
begin
	insert into home_usconfig(name,tvalue,nvalue,uid) values('wx_MMsgOrderAutoCreateTelSort1',0,'',0)
end

if not exists(select top 1 1 from home_usconfig where name = 'wx_MMsgOrderAutoCreateTelSort2')
begin
	insert into home_usconfig(name,tvalue,nvalue,uid) values('wx_MMsgOrderAutoCreateTelSort2',0,'',0)
end

GO

update invoiceConfig set 
priceFormula = replace(replace(priceFormula,'{含税折后单价}','{含税单价}'),'{折后单价}','{未税单价}'),
priceBeforeTaxFormula = replace(replace(priceBeforeTaxFormula,'{含税折后单价}','{含税单价}'),'{折后单价}','{未税单价}')

GO

if exists(select top 1 1 from M_WorkAssigns where isnull(ddlistid,0) = 0)
begin
	update x set x.ddlistid = y.MOrderListID  from M_WorkAssigns x inner join M_ManuOrderIssuedLists y on x.MOIListID = y.ID where isnull(x.ddlistid,0) = 0
end

GO

if not exists(select id from zdybh where sort1=9031)	--工序汇报编号自定义
begin
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('GX_',1,1,4,2,1,9031)
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号2',1,0,4,2,2,9031) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号3',1,0,4,2,3,9031) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号4',1,0,4,2,4,9031) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',2,1,4,2,5,9031) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',3,1,2,2,6,9031) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',4,1,2,2,7,9031) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',5,1,3,2,8,9031) 
end

GO

if exists(select 1 from M_WorkAssigns a where isnull(a.WProID,0)>0 and not exists(select 1 from M_WorkingFlows_Assigns where WAID = a.id))
begin 
	--复制工序
	insert into M_WFP_Assigns(WPID ,WAID ,num ,ord ,del ,ProgresNum ,result ,remark ,rptime ,wtime ,mtime)
	select z.WPID , a.id,z.num ,z.ord ,z.del ,z.ProgresNum ,z.result ,z.remark ,z.rptime ,z.wtime ,z.mtime 
	from M_WorkAssigns a 
	inner join M_WFP_plan z on z.WFID = a.WProID
	where  not exists(select 1 from M_WorkingFlows_Assigns where WAID = a.id)
	--复制工艺流程
	insert into M_WorkingFlows_Assigns(oldID,PrefixCode,WFName,WFBH,Creator,indate,id_sp,cateid_sp,status,IsUsing,del,tempsave,Description,intro,WAID,sumTimes)
	select z.oldid,z.PrefixCode,z.WFName,z.WFBH,z.Creator,z.indate,z.id_sp,z.cateid_sp,z.status,z.IsUsing,z.del,z.tempsave,z.Description,z.intro , a.id ,z.sumTimes
	from M_WorkAssigns a  
	inner join M_WorkingFlows_plan z on z.id= a.WProID 
	where  not exists(select 1 from M_WorkingFlows_Assigns where WAID = a.id)
	--更新派工单关联工艺流程备份
	update a set a.WProID=f.id from M_WorkAssigns a inner join M_WorkingFlows_Assigns f on f.WAID = a.id
	--更新派工工序和派工工艺流程关联关系
	update p set P.WFID = f.ID from M_WFP_Assigns p inner join M_WorkingFlows_Assigns f on f.WAID = p.WAID where isnull(p.WFID,0) =0
end

GO
--历史打印记录 和次数统计
if exists(select 1 from PrinterInfo p where not exists(select 1 from PrintTimes where datatype = p.[sort] and ord = p.formID))
begin
	insert into printtimes (datatype , ord ,times)
	select p.[sort] , p.formID ,count(1) 
	from PrinterInfo p where not exists(select 1 from PrintTimes where datatype = p.[sort] and ord = p.formID)
	group by  p.[sort] , p.formID
end 

GO

if not exists(select 1 from sortonehy where gate2=83)
begin 
	insert into sortonehy(sort1,gate1,gate2 ,color) 
	select '全一快递',1,83 , 'UAPEX'
	union all
	select '顺丰速运',2,83 , 'SF'
	union all
	select '龙邦速递',3,83 , 'LB'
	union all
	select '快捷速递',4,83 , 'FAST'
	union all
	select '港中能达',5,83 , 'NEAD'--
	union all
	select '申通快递',7,83 , 'STO'
	union all
	select '中通速递',7,83 , 'ZTO'
	union all
	select '国通快递',8,83 , 'GTO'
	union all
	select '全峰快递',9,83 , 'QFKD'
	union all
	select '宅急送',10,83 , 'ZJS'
	union all
	select '德邦物流',11,83 , 'DBL'
	union all
	select '圆通速递',12,83 , 'YTO'
	union all
	select '汇通快运',13,83 , 'HTKY'--
	union all
	select '天地华宇',14,83 , 'HOAU'
	union all
	select '优速快递',15,83 , 'UC'

	update sortonehy set ord = id where  gate2=83
end 

GO

if not exists(select top 1 1 from sortonehy where gate2=83 having count(1)>16)
begin 
	insert into sortonehy(sort1,gate1,gate2 ,color) 
	select '亚马逊',16,83 , 'AMAZON'
	union ALL
	select '安能物流',17,83 , 'ANE'
	union ALL
	select '百世快运',18,83 , 'BTWL'
	union ALL
	select '城市100',19,83 , 'CITY100'
	union ALL
	select 'D速物流',20,83 , 'DSWL'
	union ALL
	select '大田物流',21,83 , 'DTWL'
	union ALL
	select 'EMS',22,83 , 'EMS'
	union ALL
	select 'FEDEX联邦(国内件）',23,83 , 'FEDEX'
	union ALL
	select 'FEDEX联邦(国际件）',24,83 , 'FEDEX_GJ'
	union ALL
	select '高铁速递',25,83 , 'GTSD'
	union ALL
	select '天天快递',26,83 , 'HHTT'
	union ALL
	select '京东',27,83 , 'JD'
	union ALL
	select '韵达快递',28,83 , 'YD'
	union ALL
	select '运通快递',29,83 , 'YTKD'
	union ALL
	select '邮政平邮/小包',30,83 , 'YZPY'
	union ALL
	select '增益快递',31,83 , 'ZENY'
	union ALL
	select '众通快递',32,83 , 'ZTE'
	union ALL
	select '中铁快运',33,83 , 'ZTKY'
	union ALL
	select '中铁物流',34,83 , 'ZTWL'
	union ALL
	select '中邮物流',35,83 , 'ZYWL'
	union ALL
	select '汇强快递',36,83 , 'ZHQKD'
	union ALL
	select '百世快递',37,83 , 'HTKY'

	update sortonehy set ord = id where  gate2=83 AND ord is null
end 

Go

if not exists(select top 1 1 from sortonehy where gate2=83 having count(1)>38)
begin 
	insert into sortonehy(sort1,gate1,gate2 ,color) 
	select '安捷快递',38,83 ,'AJ'
	 union all
	select '亚马逊物流',39,83 ,'AMAZON'
	 union all
	select '安信达快递',40,83 ,'AXD'
	 union all
	select '澳邮专线',41,83 ,'AYCA'
	 union all
	select '北青小红帽',42,83 ,'BQXHM'
	 union all
	select '百福东方',43,83 ,'BFDF'
	 union all
	select 'CCES快递',44,83 ,'CCES'
	 union all
	select '城际快递',45,83 ,'CJKD'
	 union all
	select 'CNPEX中邮快递',46,83 ,'CNPEX'
	 union all
	select 'COE东方快递',47,83 ,'COE'
	 union all
	select '长沙创一',48,83 ,'CSCY'
	 union all
	select '成都善途速运',49,83 ,'CDSTKY'
	 union all
	select '联合运通',50,83 ,'CTG'
	 union all
	select '德邦',51,83 ,'DBL'
	 union all
	select '飞康达',52,83 ,'FKD'
	 union all
	select '广东邮政',53,83 ,'GDEMS'
	 union all
	select '共速达',54,83 ,'GSD'
	 union all
	select '汇丰物流',55,83 ,'HFWL'
	 union all
	select '恒路物流',56,83 ,'HLWL'
	 union all
	select '鸿桥供应链',57,83 ,'HOTSCM'
	 union all
	select '海派通物流公司',58,83 ,'HPTEX'
	 union all
	select '华强物流',59,83 ,'hq568'
	 union all
	select '华夏龙物流',60,83 ,'HXLWL'
	 union all
	select '好来运快递',61,83 ,'HYLSD'
	 union all
	select '京广速递',62,83 ,'JGSD'
	 union all
	select '九曳供应链',63,83 ,'JIUYE'
	 union all
	select '佳吉快运',64,83 ,'JJKY'
	 union all
	select '嘉里物流',65,83 ,'JLDT'
	 union all
	select '捷特快递',66,83 ,'JTKD'
	 union all
	select '急先达',67,83 ,'JXD'
	 union all
	select '晋越快递',68,83 ,'JYKD'
	 union all
	select '加运美',69,83 ,'JYM'
	 union all
	select '佳怡物流',70,83 ,'JYWL'
	 union all
	select '跨越速运',71,83 ,'KYSY'
	 union all
	select '联昊通速递',72,83 ,'LHT'
	 union all
	select '民邦快递',73,83 ,'MB'
	 union all
	select '民航快递',74,83 ,'MHKD'
	 union all
	select '明亮物流',75,83 ,'MLWL'
	 union all
	select '南方',76,83 ,'NF'
	 union all
	select '能达速递',77,83 ,'NEDA'
	 union all
	select '平安达腾飞快递',78,83 ,'PADTF'
	 union all
	select '泛捷快递',79,83 ,'PANEX'
	 union all
	select '品骏',80,83 ,'PJ'
	 union all
	select 'PCA Express',81,83 ,'PCA'
	 union all
	select '全晨快递',82,83 ,'QCKD'
	 union all
	select '全日通快递',83,83 ,'QRT'
	 union all
	select '全信通',84,83 ,'QXT'
	 union all
	select '瑞丰速递',85,83 ,'RFEX'
	 union all
	select '如风达',86,83 ,'RFD'
	 union all
	select '瑞丰速递',87,83 ,'RFEX'
	 union all
	select '赛澳递',88,83 ,'SAD'
	 union all
	select '圣安物流',89,83 ,'SAWL'
	 union all
	select '盛邦物流',90,83 ,'SBWL'
	 union all
	select '上大物流',91,83 ,'SDWL'
	 union all
	select '盛丰物流',92,83 ,'SFWL'
	 union all
	select '盛辉物流',93,83 ,'SHWL'
	 union all
	select '速通物流',94,83 ,'ST'
	 union all
	select '速腾快递',95,83 ,'STWL'
	 union all
	select '速必达物流',96,83 ,'SUBIDA'
	 union all
	select '速尔快递',97,83 ,'SURE'
	 union all
	select '天天',98,83 ,'HHTT'
	 union all
	select 'UEQ Express',99,83 ,'UEQ'
	 union all
	select '万家物流',100,83 ,'WJWL'
	 union all
	select '万象物流',101,83 ,'WXWL'
	 union all
	select '新邦物流',102,83 ,'XBWL'
	 union all
	select '信丰快递',103,83 ,'XFEX'
	 union all
	select '希优特',104,83 ,'XYT'
	 union all
	select '新杰物流',105,83 ,'XJ'
	 union all
	select '源安达快递',106,83 ,'YADEX'
	 union all
	select '远成物流',107,83 ,'YCWL'
	 union all
	select '义达国际物流',108,83 ,'YDH'
	 union all
	select '越丰物流',109,83 ,'YFEX'
	 union all
	select '原飞航物流',110,83 ,'YFHEX'
	 union all
	select '亚风快递',111,83 ,'YFSD'
	 union all
	select '亿翔快递',112,83 ,'YXKD'
	 union all
	select '运东西',113,83 ,'YUNDX'
	 union all
	select 'AAE全球专递',114,83 ,'AAE'
	 union all
	select 'ACS雅仕快递',115,83 ,'ACS'
	 union all
	select 'ADP Express Tracking',116,83 ,'ADP'
	 union all
	select '安圭拉邮政',117,83 ,'ANGUILAYOU'
	 union all
	select '澳门邮政',118,83 ,'AOMENYZ'
	 union all
	select 'APAC',119,83 ,'APAC'
	 union all
	select 'Aramex',120,83 ,'ARAMEX'
	 union all
	select '奥地利邮政',121,83 ,'AT'
	 union all
	select 'Australia Post Tracking',122,83 ,'AUSTRALIA'
	 union all
	select '比利时邮政',123,83 ,'BEL'
	 union all
	select 'BHT快递',124,83 ,'BHT'
	 union all
	select '秘鲁邮政',125,83 ,'BILUYOUZHE'
	 union all
	select '巴西邮政',126,83 ,'BR'
	 union all
	select '不丹邮政',127,83 ,'BUDANYOUZH'
	 union all
	select '加拿大邮政',128,83 ,'CA'
	 union all
	select '递四方速递',129,83 ,'D4PX'
	 union all
	select 'DHL',130,83 ,'DHL'
	 union all
	select 'DHL(英文版)',131,83 ,'DHL_EN'
	 union all
	select 'DHL全球',132,83 ,'DHL_GLB'
	 union all
	select 'DHL Global Mail',133,83 ,'DHLGM'
	 union all
	select '丹麦邮政',134,83 ,'DK'
	 union all
	select 'DPD',135,83 ,'DPD'
	 union all
	select 'DPEX',136,83 ,'DPEX'
	 union all
	select 'EMS国际',137,83 ,'EMSGJ'
	 union all
	select 'EShipper',138,83 ,'ESHIPPER'
	 union all
	select '国际e邮宝',139,83 ,'GJEYB'
	 union all
	select '国际邮政包裹',140,83 ,'GJYZ'
	 union all
	select 'GLS',141,83 ,'GLS'
	 union all
	select '安的列斯群岛邮政',142,83 ,'IADLSQDYZ'
	 union all
	select '澳大利亚邮政',143,83 ,'IADLYYZ'
	 union all
	select '阿尔巴尼亚邮政',144,83 ,'IAEBNYYZ'
	 union all
	select '阿尔及利亚邮政',145,83 ,'IAEJLYYZ'
	 union all
	select '阿富汗邮政',146,83 ,'IAFHYZ'
	 union all
	select '安哥拉邮政',147,83 ,'IAGLYZ'
	 union all
	select '阿根廷邮政',148,83 ,'IAGTYZ'
	 union all
	select '埃及邮政',149,83 ,'IAJYZ'
	 union all
	select '阿鲁巴邮政',150,83 ,'IALBYZ'
	 union all
	select '奥兰群岛邮政',151,83 ,'IALQDYZ'
	 union all
	select '阿联酋邮政',152,83 ,'IALYYZ'
	 union all
	select '阿曼邮政',153,83 ,'IAMYZ'
	 union all
	select '阿塞拜疆邮政',154,83 ,'IASBJYZ'
	 union all
	select '埃塞俄比亚邮政',155,83 ,'IASEBYYZ'
	 union all
	select '爱沙尼亚邮政',156,83 ,'IASNYYZ'
	 union all
	select '阿森松岛邮政',157,83 ,'IASSDYZ'
	 union all
	select '博茨瓦纳邮政',158,83 ,'IBCWNYZ'
	 union all
	select '波多黎各邮政',159,83 ,'IBDLGYZ'
	 union all
	select '冰岛邮政',160,83 ,'IBDYZ'
	 union all
	select '白俄罗斯邮政',161,83 ,'IBELSYZ'
	 union all
	select '波黑邮政',162,83 ,'IBHYZ'
	 union all
	select '保加利亚邮政',163,83 ,'IBJLYYZ'
	 union all
	select '巴基斯坦邮政',164,83 ,'IBJSTYZ'
	 union all
	select '黎巴嫩邮政',165,83 ,'IBLNYZ'
	 union all
	select '便利速递',166,83 ,'IBLSD'
	 union all
	select '玻利维亚邮政',167,83 ,'IBLWYYZ'
	 union all
	select '巴林邮政',168,83 ,'IBLYZ'
	 union all
	select '百慕达邮政',169,83 ,'IBMDYZ'
	 union all
	select '波兰邮政',170,83 ,'IBOLYZ'
	 union all
	select '宝通达',171,83 ,'IBTD'
	 union all
	select '贝邮宝',172,83 ,'IBYB'
	 union all
	select '出口易',173,83 ,'ICKY'
	 union all
	select '达方物流',174,83 ,'IDFWL'
	 union all
	select '德国邮政',175,83 ,'IDGYZ'
	 union all
	select '爱尔兰邮政',176,83 ,'IE'
	 union all
	select '厄瓜多尔邮政',177,83 ,'IEGDEYZ'
	 union all
	select '俄罗斯邮政',178,83 ,'IELSYZ'
	 union all
	select '厄立特里亚邮政',179,83 ,'IELTLYYZ'
	 union all
	select '飞特物流',180,83 ,'IFTWL'
	 union all
	select '瓜德罗普岛EMS',181,83 ,'IGDLPDEMS'
	 union all
	select '瓜德罗普岛邮政',182,83 ,'IGDLPDYZ'
	 union all
	select '俄速递',183,83 ,'IGJESD'
	 union all
	select '哥伦比亚邮政',184,83 ,'IGLBYYZ'
	 union all
	select '格陵兰邮政',185,83 ,'IGLLYZ'
	 union all
	select '哥斯达黎加邮政',186,83 ,'IGSDLJYZ'
	 union all
	select '韩国邮政',187,83 ,'IHGYZ'
	 union all
	select '华翰物流',188,83 ,'IHHWL'
	 union all
	select '互联易',189,83 ,'IHLY'
	 union all
	select '哈萨克斯坦邮政',190,83 ,'IHSKSTYZ'
	 union all
	select '黑山邮政',191,83 ,'IHSYZ'
	 union all
	select '津巴布韦邮政',192,83 ,'IJBBWYZ'
	 union all
	select '吉尔吉斯斯坦邮政',193,83 ,'IJEJSSTYZ'
	 union all
	select '捷克邮政',194,83 ,'IJKYZ'
	 union all
	select '加纳邮政',195,83 ,'IJNYZ'
	 union all
	select '柬埔寨邮政',196,83 ,'IJPZYZ'
	 union all
	select '克罗地亚邮政',197,83 ,'IKNDYYZ'
	 union all
	select '肯尼亚邮政',198,83 ,'IKNYYZ'
	 union all
	select '科特迪瓦EMS',199,83 ,'IKTDWEMS'
	 union all
	select '科特迪瓦邮政',200,83 ,'IKTDWYZ'
	 union all
	select '卡塔尔邮政',201,83 ,'IKTEYZ'
	 union all
	select '利比亚邮政',202,83 ,'ILBYYZ'
	 union all
	select '林克快递',203,83 ,'ILKKD'
	 union all
	select '罗马尼亚邮政',204,83 ,'ILMNYYZ'
	 union all
	select '卢森堡邮政',205,83 ,'ILSBYZ'
	 union all
	select '拉脱维亚邮政',206,83 ,'ILTWYYZ'
	 union all
	select '立陶宛邮政',207,83 ,'ILTWYZ'
	 union all
	select '列支敦士登邮政',208,83 ,'ILZDSDYZ'
	 union all
	select '马尔代夫邮政',209,83 ,'IMEDFYZ'
	 union all
	select '摩尔多瓦邮政',210,83 ,'IMEDWYZ'
	 union all
	select '马耳他邮政',211,83 ,'IMETYZ'
	 union all
	select '孟加拉国EMS',212,83 ,'IMJLGEMS'
	 union all
	select '摩洛哥邮政',213,83 ,'IMLGYZ'
	 union all
	select '毛里求斯邮政',214,83 ,'IMLQSYZ'
	 union all
	select '马来西亚EMS',215,83 ,'IMLXYEMS'
	 union all
	select '马来西亚邮政',216,83 ,'IMLXYYZ'
	 union all
	select '马其顿邮政',217,83 ,'IMQDYZ'
	 union all
	select '马提尼克EMS',218,83 ,'IMTNKEMS'
	 union all
	select '马提尼克邮政',219,83 ,'IMTNKYZ'
	 union all
	select '墨西哥邮政',220,83 ,'IMXGYZ'
	 union all
	select '南非邮政',221,83 ,'INFYZ'
	 union all
	select '尼日利亚邮政',222,83 ,'INRLYYZ'
	 union all
	select '挪威邮政',223,83 ,'INWYZ'
	 union all
	select '葡萄牙邮政',224,83 ,'IPTYYZ'
	 union all
	select '全球快递',225,83 ,'IQQKD'
	 union all
	select '全通物流',226,83 ,'IQTWL'
	 union all
	select '苏丹邮政',227,83 ,'ISDYZ'
	 union all
	select '萨尔瓦多邮政',228,83 ,'ISEWDYZ'
	 union all
	select '塞尔维亚邮政',229,83 ,'ISEWYYZ'
	 union all
	select '斯洛伐克邮政',230,83 ,'ISLFKYZ'
	 union all
	select '斯洛文尼亚邮政',231,83 ,'ISLWNYYZ'
	 union all
	select '塞内加尔邮政',232,83 ,'ISNJEYZ'
	 union all
	select '塞浦路斯邮政',233,83 ,'ISPLSYZ'
	 union all
	select '沙特阿拉伯邮政',234,83 ,'ISTALBYZ'
	 union all
	select '土耳其邮政',235,83 ,'ITEQYZ'
	 union all
	select '泰国邮政',236,83 ,'ITGYZ'
	 union all
	select '特立尼达和多巴哥EMS',237,83 ,'ITLNDHDBGE'
	 union all
	select '突尼斯邮政',238,83 ,'ITNSYZ'
	 union all
	select '坦桑尼亚邮政',239,83 ,'ITSNYYZ'
	 union all
	select '危地马拉邮政',240,83 ,'IWDMLYZ'
	 union all
	select '乌干达邮政',241,83 ,'IWGDYZ'
	 union all
	select '乌克兰EMS',242,83 ,'IWKLEMS'
	 union all
	select '乌克兰邮政',243,83 ,'IWKLYZ'
	 union all
	select '乌拉圭邮政',244,83 ,'IWLGYZ'
	 union all
	select '文莱邮政',245,83 ,'IWLYZ'
	 union all
	select '乌兹别克斯坦EMS',246,83 ,'IWZBKSTEMS'
	 union all
	select '乌兹别克斯坦邮政',247,83 ,'IWZBKSTYZ'
	 union all
	select '西班牙邮政',248,83 ,'IXBYYZ'
	 union all
	select '小飞龙物流',249,83 ,'IXFLWL'
	 union all
	select '新喀里多尼亚邮政',250,83 ,'IXGLDNYYZ'
	 union all
	select '新加坡EMS',251,83 ,'IXJPEMS'
	 union all
	select '新加坡邮政',252,83 ,'IXJPYZ'
	 union all
	select '叙利亚邮政',253,83 ,'IXLYYZ'
	 union all
	select '希腊邮政',254,83 ,'IXLYZ'
	 union all
	select '夏浦世纪',255,83 ,'IXPSJ'
	 union all
	select '夏浦物流',256,83 ,'IXPWL'
	 union all
	select '新西兰邮政',257,83 ,'IXXLYZ'
	 union all
	select '匈牙利邮政',258,83 ,'IXYLYZ'
	 union all
	select '意大利邮政',259,83 ,'IYDLYZ'
	 union all
	select '印度尼西亚邮政',260,83 ,'IYDNXYYZ'
	 union all
	select '印度邮政',261,83 ,'IYDYZ'
	 union all
	select '英国邮政',262,83 ,'IYGYZ'
	 union all
	select '伊朗邮政',263,83 ,'IYLYZ'
	 union all
	select '亚美尼亚邮政',264,83 ,'IYMNYYZ'
	 union all
	select '也门邮政',265,83 ,'IYMYZ'
	 union all
	select '越南邮政',266,83 ,'IYNYZ'
	 union all
	select '以色列邮政',267,83 ,'IYSLYZ'
	 union all
	select '易通关',268,83 ,'IYTG'
	 union all
	select '燕文物流',269,83 ,'IYWWL'
	 union all
	select '直布罗陀邮政',270,83 ,'IZBLTYZ'
	 union all
	select '智利邮政',271,83 ,'IZLYZ'
	 union all
	select '日本邮政',272,83 ,'JP'
	 union all
	select '荷兰邮政',273,83 ,'NL'
	 union all
	select 'ONTRAC',274,83 ,'ONTRAC'
	 union all
	select '全球邮政',275,83 ,'QQYZ'
	 union all
	select '瑞典邮政',276,83 ,'RDSE'
	 union all
	select '瑞士邮政',277,83 ,'SWCH'
	 union all
	select '台湾邮政',278,83 ,'TAIWANYZ'
	 union all
	select 'TNT快递',279,83 ,'TNT'
	 union all
	select 'UPS',280,83 ,'UPS'
	 union all
	select 'USPS美国邮政',281,83 ,'USPS'
	 union all
	select '日本大和运输(Yamato)',282,83 ,'YAMA'
	 union all
	select 'YODEL',283,83 ,'YODEL'
	 union all
	select '约旦邮政',284,83 ,'YUEDANYOUZ'
	 union all
	select '笨鸟国际',285,83 ,'BN'
	 union all
	select '爱购转运',286,83 ,'ZY_AG'
	 union all
	select '爱欧洲',287,83 ,'ZY_AOZ'
	 union all
	select '澳世速递',288,83 ,'ZY_AUSE'
	 union all
	select 'AXO',289,83 ,'ZY_AXO'
	 union all
	select '澳转运',290,83 ,'ZY_AZY'
	 union all
	select '八达网',291,83 ,'ZY_BDA'
	 union all
	select '蜜蜂速递',292,83 ,'ZY_BEE'
	 union all
	select '贝海速递',293,83 ,'ZY_BH'
	 union all
	select '百利快递',294,83 ,'ZY_BL'
	 union all
	select '斑马物流',295,83 ,'ZY_BM'
	 union all
	select '败欧洲',296,83 ,'ZY_BOZ'
	 union all
	select '百通物流',297,83 ,'ZY_BT'
	 union all
	select '贝易购',298,83 ,'ZY_BYECO'
	 union all
	select '策马转运',299,83 ,'ZY_CM'
	 union all
	select '赤兔马转运',300,83 ,'ZY_CTM'
	 union all
	select 'CUL中美速递',301,83 ,'ZY_CUL'
	 union all
	select '德国海淘之家',302,83 ,'ZY_DGHT'
	 union all
	select '德运网',303,83 ,'ZY_DYW'
	 union all
	select 'EFS POST',304,83 ,'ZY_EFS'
	 union all
	select '宜送转运',305,83 ,'ZY_ESONG'
	 union all
	select 'ETD',306,83 ,'ZY_ETD'
	 union all
	select '飞碟快递',307,83 ,'ZY_FD'
	 union all
	select '飞鸽快递',308,83 ,'ZY_FG'
	 union all
	select '风雷速递',309,83 ,'ZY_FLSD'
	 union all
	select '风行快递',310,83 ,'ZY_FX'
	 union all
	select '风行速递',311,83 ,'ZY_FXSD'
	 union all
	select '飞洋快递',312,83 ,'ZY_FY'
	 union all
	select '皓晨快递',313,83 ,'ZY_HC'
	 union all
	select '皓晨优递',314,83 ,'ZY_HCYD'
	 union all
	select '海带宝',315,83 ,'ZY_HDB'
	 union all
	select '汇丰美中速递',316,83 ,'ZY_HFMZ'
	 union all
	select '豪杰速递',317,83 ,'ZY_HJSD'
	 union all
	select '360hitao转运',318,83 ,'ZY_HTAO'
	 union all
	select '海淘村',319,83 ,'ZY_HTCUN'
	 union all
	select '365海淘客',320,83 ,'ZY_HTKE'
	 union all
	select '华通快运',321,83 ,'ZY_HTONG'
	 union all
	select '海星桥快递',322,83 ,'ZY_HXKD'
	 union all
	select '华兴速运',323,83 ,'ZY_HXSY'
	 union all
	select '海悦速递',324,83 ,'ZY_HYSD'
	 union all
	select 'LogisticsY',325,83 ,'ZY_IHERB'
	 union all
	select '君安快递',326,83 ,'ZY_JA'
	 union all
	select '时代转运',327,83 ,'ZY_JD'
	 union all
	select '骏达快递',328,83 ,'ZY_JDKD'
	 union all
	select '骏达转运',329,83 ,'ZY_JDZY'
	 union all
	select '久禾快递',330,83 ,'ZY_JH'
	 union all
	select '金海淘',331,83 ,'ZY_JHT'
	 union all
	select '联邦转运FedRoad',332,83 ,'ZY_LBZY'
	 union all
	select '领跑者快递',333,83 ,'ZY_LPZ'
	 union all
	select '龙象快递',334,83 ,'ZY_LX'
	 union all
	select '量子物流',335,83 ,'ZY_LZWL'
	 union all
	select '明邦转运',336,83 ,'ZY_MBZY'
	 union all
	select '美国转运',337,83 ,'ZY_MGZY'
	 union all
	select '美嘉快递',338,83 ,'ZY_MJ'
	 union all
	select '美速通',339,83 ,'ZY_MST'
	 union all
	select '美西转运',340,83 ,'ZY_MXZY'
	 union all
	select '168 美中快递',341,83 ,'ZY_MZ'
	 union all
	select '欧e捷',342,83 ,'ZY_OEJ'
	 union all
	select '欧洲疯',343,83 ,'ZY_OZF'
	 union all
	select '欧洲GO',344,83 ,'ZY_OZGO'
	 union all
	select '全美通',345,83 ,'ZY_QMT'
	 union all
	select 'QQ-EX',346,83 ,'ZY_QQEX'
	 union all
	select '润东国际快线',347,83 ,'ZY_RDGJ'
	 union all
	select '瑞天快递',348,83 ,'ZY_RT'
	 union all
	select '瑞天速递',349,83 ,'ZY_RTSD'
	 union all
	select 'SCS国际物流',350,83 ,'ZY_SCS'
	 union all
	select '速达快递',351,83 ,'ZY_SDKD'
	 union all
	select '四方转运',352,83 ,'ZY_SFZY'
	 union all
	select 'SOHO苏豪国际',353,83 ,'ZY_SOHO'
	 union all
	select 'Sonic-Ex速递',354,83 ,'ZY_SONIC'
	 union all
	select '上腾快递',355,83 ,'ZY_ST'
	 union all
	select '通诚美中快递',356,83 ,'ZY_TCM'
	 union all
	select '天际快递',357,83 ,'ZY_TJ'
	 union all
	select '天马转运',358,83 ,'ZY_TM'
	 union all
	select '滕牛快递',359,83 ,'ZY_TN'
	 union all
	select 'TrakPak',360,83 ,'ZY_TPAK'
	 union all
	select '太平洋快递',361,83 ,'ZY_TPY'
	 union all
	select '唐三藏转运',362,83 ,'ZY_TSZ'
	 union all
	select '天天海淘',363,83 ,'ZY_TTHT'
	 union all
	select 'TWC转运世界',364,83 ,'ZY_TWC'
	 union all
	select '同心快递',365,83 ,'ZY_TX'
	 union all
	select '天翼快递',366,83 ,'ZY_TY'
	 union all
	select '同舟快递',367,83 ,'ZY_TZH'
	 union all
	select 'UCS合众快递',368,83 ,'ZY_UCS'
	 union all
	select '文达国际DCS',369,83 ,'ZY_WDCS'
	 union all
	select '星辰快递',370,83 ,'ZY_XC'
	 union all
	select '迅达快递',371,83 ,'ZY_XDKD'
	 union all
	select '信达速运',372,83 ,'ZY_XDSY'
	 union all
	select '先锋快递',373,83 ,'ZY_XF'
	 union all
	select '新干线快递',374,83 ,'ZY_XGX'
	 union all
	select '西邮寄',375,83 ,'ZY_XIYJ'
	 union all
	select '信捷转运',376,83 ,'ZY_XJ'
	 union all
	select '优购快递',377,83 ,'ZY_YGKD'
	 union all
	select '友家速递(UCS)',378,83 ,'ZY_YJSD'
	 union all
	select '云畔网',379,83 ,'ZY_YPW'
	 union all
	select '云骑快递',380,83 ,'ZY_YQ'
	 union all
	select '一柒物流',381,83 ,'ZY_YQWL'
	 union all
	select '优晟速递',382,83 ,'ZY_YSSD'
	 union all
	select '易送网',383,83 ,'ZY_YSW'
	 union all
	select '运淘美国',384,83 ,'ZY_YTUSA'
	 union all
	select '至诚速递',385,83 ,'ZY_ZCSD'

	update sortonehy set isStop = 1,ord = id where  gate2=83 AND ord is null
end 

GO

IF EXISTS (SELECT * FROM    dbo.contract_out WHERE   PrintID = 17)
Begin
	update contract_out set sort=43003,PrintID=43003 where PrintID = 17
End

GO

IF EXISTS (SELECT * FROM    dbo.contract_out WHERE  sort = 17)
Begin
	update contract_out set sort=43003 where sort = 17
End

GO

--预购明细-到货日期改为交货日期
if not exists(select 1 from home_usConfig where name = 'Caigou_YG_Old_Data') 
begin
	update zdymx set title='交货日期' where sort1=25 and name='date2'
	
	update a set a.sort1=0 , a.sp=0 , a.status=0 , a.cateid_sp=0 , a.needxj = 0, a.bz = 14 ,
	a.money1 =(SELECT sum(money1) FROM caigoulist_yg WHERE caigou = a.id),
	fromtype=(case when isnull(price,0)>0 then 5
		when isnull(morderid,0)>0 then 4 
		when isnull(xunjia,0)>0 then 3
		when isnull(contract,0)>0 then 2
		when isnull(chance,0)>0 then 1
		else 0 end)
	from caigou_yg a
	where a.sort1 is null 

	insert into home_usConfig(name,nvalue,tvalue,uid) values('Caigou_YG_Old_Data',null,1,0)
end

GO
--预购默认分类
if not exists(select 1 from home_usConfig where name = 'Caigou_YG_Old_Sort_Data') 
begin
	if not exists(SELECT 1 FROM sortonehy WHERE gate2=25 and sort1='默认分类')
	begin
		insert into sortonehy(sort1,gate1,gate2,del,isstop ,color)
		select '默认分类',1,25,1,0 , ''

		declare @sid int
		select top 1 @sid = id from sortonehy where gate2=25 and sort1='默认分类'
		set @sid = isnull(@sid,0)
		update sortonehy set ord=@sid where id = @sid
		
		update caigou_yg set sort1 = @sid where  isnull(sort1,0) =0
	end 
	insert into home_usConfig(name,nvalue,tvalue,uid) values('Caigou_YG_Old_Sort_Data',null,1,0)
end

GO

--考勤类型固定类型添加
IF NOT EXISTS(SELECT 1 FROM HrKQ_AttendanceType WHERE isUpdate = 0) 
BEGIN
	INSERT INTO dbo.HrKQ_AttendanceType(OnlyID,Title ,Unit ,isContainHoliday ,isRelatedWage ,isAlloweRest ,isAllowApply, TermofValidity ,  [Status] ,isUpdate ,CreateId ,CreateDate,isClock,AttTypeCls) VALUES   (1,'正常',0 ,0 , 1 , 0 , 0 ,0 , 1 ,0 ,0,GETDATE(),1,0);
	INSERT INTO dbo.HrKQ_AttendanceType(OnlyID,Title ,Unit ,isContainHoliday ,isRelatedWage ,isAlloweRest ,isAllowApply, TermofValidity ,  [Status] ,isUpdate ,CreateId ,CreateDate,isClock,AttTypeCls) VALUES   (2,'异常',1 ,0 , 0 , 0 , 0 ,0 , 1 ,0 ,0,GETDATE(),1,0);
	INSERT INTO dbo.HrKQ_AttendanceType(OnlyID,Title ,Unit ,isContainHoliday ,isRelatedWage ,isAlloweRest ,isAllowApply, TermofValidity ,  [Status] ,isUpdate ,CreateId ,CreateDate,isClock,AttTypeCls) VALUES   (3,'迟到',1 ,0 , 1 , 0 , 0 ,0 , 1 ,0 ,0,GETDATE(),1,0);
	INSERT INTO dbo.HrKQ_AttendanceType(OnlyID,Title ,Unit ,isContainHoliday ,isRelatedWage ,isAlloweRest ,isAllowApply, TermofValidity ,  [Status] ,isUpdate ,CreateId ,CreateDate,isClock,AttTypeCls) VALUES   (4,'早退',1 ,0 , 1 , 0 , 0 ,0 , 1 ,0 ,0,GETDATE(),1,0);
	INSERT INTO dbo.HrKQ_AttendanceType(OnlyID,Title ,Unit ,isContainHoliday ,isRelatedWage ,isAlloweRest ,isAllowApply, TermofValidity ,  [Status] ,isUpdate ,CreateId ,CreateDate,isClock,AttTypeCls) VALUES   (5,'迟到、早退',1 ,0 , 1 , 0 , 0 ,0 , 1 ,0 ,0,GETDATE(),1,0);
	INSERT INTO dbo.HrKQ_AttendanceType(OnlyID,Title ,Unit ,isContainHoliday ,isRelatedWage ,isAlloweRest ,isAllowApply, TermofValidity ,  [Status] ,isUpdate ,CreateId ,CreateDate,isClock,AttTypeCls) VALUES   (6,'旷工',2 ,0 , 1 , 0 , 0 ,0 , 1 ,0 ,0,GETDATE(),1,0);
	INSERT INTO dbo.HrKQ_AttendanceType(OnlyID,Title ,Unit ,isContainHoliday ,isRelatedWage ,isAlloweRest ,isAllowApply, TermofValidity ,  [Status] ,isUpdate ,CreateId ,CreateDate,isClock,AttTypeCls) VALUES   (7,'早退、旷工',1 ,0 , 1 , 0 , 0 ,0 , 1 ,0 ,0,GETDATE(),1,0);
	INSERT INTO dbo.HrKQ_AttendanceType(OnlyID,Title ,Unit ,isContainHoliday ,isRelatedWage ,isAlloweRest ,isAllowApply, TermofValidity ,  [Status] ,isUpdate ,CreateId ,CreateDate,isClock,AttTypeCls) VALUES   (8,'迟到、旷工',1 ,0 , 1 , 0 , 0 ,0 , 1 ,0 ,0,GETDATE(),1,0);
	INSERT INTO dbo.HrKQ_AttendanceType(OnlyID,Title ,Unit ,isContainHoliday ,isRelatedWage ,isAlloweRest ,isAllowApply, TermofValidity ,  [Status] ,isUpdate ,CreateId ,CreateDate,isClock,AttTypeCls) VALUES   (9,'休息',1 ,0 , 0 , 0 , 0 ,0 , 1 ,0 ,0,GETDATE(),0,4);
	INSERT INTO dbo.HrKQ_AttendanceType(OnlyID,Title ,Unit ,isContainHoliday ,isRelatedWage ,isAlloweRest ,isAllowApply, TermofValidity ,  [Status] ,isUpdate ,CreateId ,CreateDate,isClock,AttTypeCls) VALUES   (10,'调休',0 ,0 , 0 , 0 , 1 ,0 , 1 ,0 ,0,GETDATE(),0,1);
	INSERT INTO dbo.HrKQ_AttendanceType(OnlyID,Title ,Unit ,isContainHoliday ,isRelatedWage ,isAlloweRest ,isAllowApply, TermofValidity ,  [Status] ,isUpdate ,CreateId ,CreateDate,isClock,AttTypeCls) VALUES   (11,'加班',3 ,1 , 1 , 1 , 0 ,30 , 1 ,0 ,0,GETDATE(),1,2);
	INSERT INTO dbo.HrKQ_AttendanceType(OnlyID,Title ,Unit ,isContainHoliday ,isRelatedWage ,isAlloweRest ,isAllowApply, TermofValidity ,  [Status] ,isUpdate ,CreateId ,CreateDate,isClock,AttTypeCls) VALUES   (12,'年假',0 ,1 , 1 , 0 , 1 ,0 , 1 ,0 ,0,GETDATE(),0,1);
END


GO

if exists(select 1 from HrKQ_AttendanceType where onlyid<10 and onlyid>0 and isAllowApply=1)
begin 
	update HrKQ_AttendanceType set isAllowApply = 0 where onlyid<10 and onlyid>0 and isAllowApply=1
end  

GO

if exists(SELECT 1 from (
		SELECT syl.ord,syl.bx,sum(case when ((syl.bx=1 or syl.bx=3) and syl.jid=0) then 1 else 0 end) num3, 
			SUM(case when (((syl.bx=1 or syl.bx=3) and jid<>0)) then 1 else 0 end) num1, sum(1) num2
		from f_pay sy INNER join pay syl on sy.id = syl.fid AND isnull(syl.del,1) = 1 and sy.del = 1 AND ISNULL(syl.bx,0)<>3
		INNER join paybxlist bxl on bxl.payid = syl.ord and bxl.del = 1 
		INNER join paybx bx on bx.id = bxl.bxid and bx.del = 1 group by syl.ord,syl.bx
	) x  where (x.num3+x.num1)<>x.num2 )
begin 
	update pay set bx = 3 where ord in (
		SELECT ord from (
			SELECT syl.ord,syl.bx,sum(case when ((syl.bx=1 or syl.bx=3) and syl.jid=0) then 1 else 0 end) num3, 
				SUM(case when (((syl.bx=1 or syl.bx=3) and jid<>0)) then 1 else 0 end) num1, sum(1) num2
			from f_pay sy INNER join pay syl on sy.id = syl.fid AND isnull(syl.del,1) = 1 and sy.del = 1 AND ISNULL(syl.bx,0)<>3
			INNER join paybxlist bxl on bxl.payid = syl.ord and bxl.del = 1 
			INNER join paybx bx on bx.id = bxl.bxid and bx.del = 1 group by syl.ord,syl.bx
		) x  where (x.num3+x.num1)<>x.num2
	)
end  

GO

if not exists (select top 1 1 from Shop_PayKinds) 
begin 
	insert into Shop_PayKinds(id,name,gate1) values(1,'在线支付',9000) 
	insert into Shop_PayKinds(id,name,gate1) values(2,'货到付款',10000) 
end 

if not exists (select top 1 1 from Shop_Payments) 
begin 
	insert into Shop_Payments(id,payKind,name,merchant,mKey,bank,state,gate1,tag) 
	select top 1 2,1,'微信支付','','',id,1,10000,'wxPay' from sortbank where del=1 and bz = 14 order by gate1 desc,id desc 

	insert into Shop_Payments(id,payKind,name,merchant,mKey,bank,state,gate1,tag) 
	select top 1 1,2,'货到付款','','',id,1,9900,'goodsPay' from sortbank where del=1 and bz = 14 order by gate1 desc,id desc 
end

GO

--分配预付款余额
exec [update_gys_bankout2]

--采购基础设置调整
if not exists(select 1 from home_usConfig where name = 'CAIGOULIST_CAIGOU_FIELDS_OPTIMIZE')
begin

	update caigou set premoney = money1,yhtype=0,zk=1,inverse=0,yhmoney=0,invoiceplan=(case when isnull(fyhk,0)=1 then 1 else 0 end)

	--转移收票数据到新表
	insert into payoutInvoice(
	company,fromType,fromId,invoiceType,invoiceMode,invoiceNum,invoicely,date1,date7,money1,bz,
	cateid,cateid2,cateid3,addcate,isInvoiced,invoiceDate,invoiceDatetime,invoiceCate,del)
	SELECT 
		(CASE WHEN a.cls<>2 THEN c.company ELSE m.gys END ) AS company , 
		(CASE WHEN a.cls<>2 THEN 'CAIGOU' ELSE 'WWFK' END ) AS fromType, 
		a.contract AS fromId ,ISNULL(a.tik,0) as invoiceType,
		(CASE WHEN a.cls<>2 THEN 2 ELSE 1 END ) AS invoiceMode,a.tikname AS invoiceNum , IsUsePJLY ,a.date3 AS date1 ,a.date7,
		a.money1 , (CASE WHEN a.cls<>2 THEN ISNULL(c.bz,14) ELSE 14 END ) AS bz,
		a.cateid , g.sorce ,g.sorce2 ,a.addcate, 1 ,a.date3 AS invoiceDate, a.date7,a.addcate,1
	FROM (
		select cls, contract ,ord,tik, tikname, isnull(money1,0) as money1, IsUsePJLY , date3, date7 ,addcate, 
			cateid,date3 as date1,1 as zt,0 as paypro
		from payout 
		where complete2 = 3 and del=1 and ord not in (select payout from payinvoicelist where zt=1 and del=1) 
		union all 
		select l.cls,l.sourceID ,l.ord,p.tik,p.tikname,isnull(l.money1,0) as money1,p.IsUsePJLY , p.date3, p.date7 ,p.addcate,
			o.cateid,p.date1,l.zt,1 as paypro
		from PayInvoiceList l
		inner JOIN payout o ON o.ord = l.payout AND o.del=1
		LEFT JOIN PayInvoice p ON p.ord=l.PayInvoice
	) a 
	LEFT JOIN caigou c ON a.cls <>2 AND a.contract = c.ord
	LEFT JOIN M_OutOrder m ON a.cls=2 AND a.contract = m.id
	LEFT JOIN gate g ON g.ord=a.cateid
	WHERE NOT EXISTS(SELECT 1 FROM payoutInvoice WHERE fromType='CAIGOU' AND fromId = a.contract AND a.cls<>2)
	AND NOT EXISTS(SELECT 1 FROM payoutInvoice WHERE fromType='WWFK' AND fromId = a.contract AND a.cls=2)
	ORDER BY  a.date7 ASC , a.ord ASC

	--处理采购单关联的收票信息
	exec [update_caigou_payoutinvoice] 0, 0 ,0,'CAIGOU'

	--处理采购明细中新增的字段值
	update caigoulist set invoiceType=0,taxRate=0,
		Discount=(case when ISNULL(num1,0)<>0 and ISNULL(price1,0)<>0 then ISNULL(money1,0)/ISNULL(num1,0)/
				 ISNULL(price1,0) else 0 end) ,
		priceAfterDiscount = (case when ISNULL(num1,0)<>0 then ISNULL(money1,0)/ISNULL(num1,0) else 0 end) ,
		priceAfterTax = price1,
		priceAfterDiscountTax = (case when ISNULL(num1,0)<>0 then ISNULL(money1,0)/ISNULL(num1,0) else 0 end),
		moneyAfterDiscount= money1,taxValue=0
	--批量更新采购单明细的票据类型(采购单只开一种票据的情况下)
	SELECT DISTINCT c.ord , p.invoiceType INTO #invoice
	FROM caigou c
	INNER JOIN dbo.payoutInvoice p ON p.fromType = 'CAIGOU' AND p.fromId = c.ord

	UPDATE b SET b.invoiceType=i.invoiceType ,
	b.taxRate = isnull(f.taxRate,0) ,
	b.priceAfterTax =  (case when Discount<>0 then priceAfterDiscountTax / Discount  else 0 end), 
	b.priceAfterDiscount = priceAfterDiscountTax /(1+isnull(f.taxRate,0)/100 ) ,
	b.price1 = (case when Discount<>0 then priceAfterDiscountTax / Discount  else 0 end)/(1+isnull(f.taxRate,0)/100 ),
	b.moneyAfterDiscount= priceAfterDiscountTax /(1+isnull(f.taxRate,0)/100 ) *b.num1,
	b.taxValue = b.money1 - priceAfterDiscountTax /(1+isnull(f.taxRate,0)/100 ) *b.num1
	FROM caigou a 
	INNER JOIN caigoulist b ON b.caigou = a.ord
	INNER JOIN #invoice i ON i.ord =a.ord
	LEFT JOIN invoiceConfig f ON f.typeId = i.invoiceType
	WHERE (SELECT COUNT(1) FROM #invoice WHERE ord = a.ord)=1

	--历史多种票据类型的单据 开票状态为4
	--update p set p.isinvoiced = 4
	--from payoutInvoice p
	--inner join #invoice a on p.fromType = 'CAIGOU' AND p.fromId = a.ord
	--where (SELECT COUNT(1) FROM #invoice WHERE ord = a.ord)>1

	DROP TABLE #invoice
	--升级时间点
	insert into home_usConfig(name,nvalue,tvalue,uid) values('CAIGOULIST_CAIGOU_UPDATETIME',null,CONVERT(VARCHAR(20), GETDATE(),120),0)

	insert into home_usConfig(name,nvalue,tvalue,uid) values('CAIGOULIST_CAIGOU_FIELDS_OPTIMIZE',null,1,0)
end

GO

if not exists(select 1 from home_usConfig where name = 'KUINLIST_KUIN_FIELDS_OPTIMIZE')
begin 
	update kuinlist set price2=isnull(price1,'0'),money2=isnull(money1,0) where isnull(price2,'0')='0'
	insert into home_usConfig(name,nvalue,tvalue,uid) values('KUINLIST_KUIN_FIELDS_OPTIMIZE',null,1,0)
end

GO

--询价老数据处理
if exists(select top 1 1 from xunjia where status is null)
begin
	--直接添加的询价的状态为：暂存
	update xunjia set status=0 where status is null and isnull(price,0)=0 and complete=0
	if exists(select top 1 1 from xunjia where status is null and price>0)
	begin	--报价生成的询价的状态，如果都定价了，则为询价完毕；如果部分，则询价中，部分定价；否则为询价中，待定价
		update a set a.status = (case when c.djNum=0 then 1 
			when c.bjNum>c.djNum and c.djNum>0 then 2 
			when c.bjNum=c.djNum then 3 else 1 end)
		from xunjia a
		inner join price b on a.price=b.ord and a.price>0 and a.status is null
		inner join (
			select price,COUNT(1) bjNum,SUM(xunjiastatus) djNum from pricelist where del=3 group by price
		) c on c.price=b.ord
	end	
	--直接添加的询价单如果生成了预购，则状态为：询价完毕
	update xunjia set status=3 where status is null and complete=1 and isnull(price,0)=0
end
GO
if exists(select top 1 1 from xunjia where complete=0)
begin
	update xunjia set complete=null where complete=0
end
GO
if exists(select top 1 1 from xunjia where bz is null)
begin
	update xunjia set bz=14 where bz is null 
end
GO
if exists(select top 1 1 from xunjialist where priceIncludeTax is null)
begin
	update xunjialist set taxRate=0,invoiceType=0,discount=1,
		priceAfterDiscount=price1,priceIncludeTax=price1,priceAfterTax=price1,
		taxValue=0, moneyAfterTax=price1*num1 where priceIncludeTax is null 
end

GO

if exists(select 1 from orgs_parts where fullpath is null or fullsort is null or fullids is null)
begin
	exec erp_orgs_updateOrgsStatus
end
update gate set orgsid=(case sign(sorce2) when 1 then sorce2 else sorce end) where isnull(orgsid,-100)=-100
update hr_person set orgsid=(case sign(sorce2) when 1 then sorce2 else sorce end) where isnull(orgsid,-100)=-100
update gate set partadmin=(case when cateid <4 then 1 else 0 end) where partadmin is null
update gate set pricesorce=sorce where pricesorce is null
exec erp_orgs_createDefaultCompanyInfo

GO

--存货核算版本升级时间
if not exists(select 1 from home_usConfig where name = 'INVENTORY_COSTACCOUNT_UPDATETIME')
begin 
	update kl set pricemonth=cast(price1 as decimal(25,12))
	FROM kuinlist kl
	INNER JOIN kuin ki ON ki.ord = kl.kuin and ki.sort1=9 
	inner join kuzz kz on kz.ord=ki.caigou AND kz.zztype = 0

	insert into home_usConfig(name,nvalue,tvalue,uid) values('INVENTORY_COSTACCOUNT_UPDATETIME',null,CONVERT(VARCHAR(23),GETDATE(),120),0)

	delete from reminderQueue where reminderConfig in (212,214)
end

GO

--销售毛利计算方法设置
if not exists(select 1 from home_usConfig where name = 'SALES_MAOLI_EXECWAY')
begin 
	if exists(select top 1 1 from setopen where sort1=2015011201)
	begin
		update setopen set intro=(case isnull(intro,'1') when '1' then '2' when '2' then '4' end) where  sort1=2015011201
	end 
	else
	begin
		insert into setopen(sort1,intro) values(2015011201,2)
	end
	insert into home_usConfig(name,nvalue,tvalue,uid) values('SALES_MAOLI_EXECWAY',null,CONVERT(VARCHAR(23),GETDATE(),120),0)
end

GO

if exists(select top 1 1 from caigouQC where QC_id is null)
begin 
	update caigouQC set QC_id=0 where QC_id is null
end

GO

if not exists(SELECT TOP 1 1 FROM dbo.HrKQ_CardSetting)
begin
	INSERT INTO dbo.HrKQ_CardSetting(Title,Device,RangeType,CreateID,CreateDate)VALUES('考勤打卡设置','0,1',2,0,GETDATE())
end

GO

IF NOT EXISTS(SELECT 1 FROM dbo.home_usConfig WHERE name='OldDataCaigouQC')
BEGIN
	--更新质检老数据
	exec Erp_OldCaigouQc_Update
end

GO

IF EXISTS(SELECT top 1 1 FROM product WHERE unit like '% %' and unit not like '%, %')
BEGIN
	update product set unit = dbo.CNumberList(unit) WHERE unit like '% %' and unit not like '%, %'
end
update product set   Roles = dbo.CNumberList(Roles)  where charindex(' ', roles)>0 or  charindex(',', ltrim(roles))=1 or  charindex(',,', roles)>0

GO
IF EXISTS(SELECT top 1 1 FROM mobile_home_item_us WHERE itemid=12)
BEGIN
	delete FROM mobile_home_item_us WHERE itemid=12	--Bug.16647.2017-05-23.ljh.移动端 售后维修 导航，31.79迭代中并入售后管理中了，从导航这里删除
end

GO

if not exists(select 1 from erp_comm_UnitGroup where SysBind=1)
begin
	insert into  erp_comm_UnitGroup (name, formual,  stoped, stype, sort1, SysBind)
	select '数量组', '', 0, 0,40,1  union all
	select '面积组', '', 0, 1,30,1  union all
	select '体积组', '', 0, 1,20,1;
end

GO

if not exists(select 1 from erp_comm_unitInfo)
begin
	insert into erp_comm_unitInfo(unitid, unitgp, main, bl)
	select ord, b.id, 0, 1 from ErpUnits a
	inner join erp_comm_UnitGroup b on b.name='数量组' and b.SysBind=1 
	where ISNULL(unitgp,-1) = -1
end

GO

--增加产品单位属性
if not exists(select 1 from erp_comm_UnitGroupAttr)
begin
	insert into erp_comm_UnitGroupAttr( unitgp, name, formula ,stoped ,gate1)
	select cast(id as int) as id, '长方体','V=a*b*c',0 , 40 from erp_comm_UnitGroup where name='体积组' and SysBind=1
	union all
	select cast(id as int) as id, '圆柱','V=π*r*r*h',0 , 35 from erp_comm_UnitGroup where name='体积组' and SysBind=1
	union all
	select cast(id as int) as id, '棱柱','V=s*h',0 , 30 from erp_comm_UnitGroup where name='体积组' and SysBind=1
	union all
	select cast(id as int) as id, '椎体','V=s*h/3',0 , 25 from erp_comm_UnitGroup where name='体积组' and SysBind=1
	union all
	select cast(id as int) as id, '长方形','S=a*b',0 , 20 from erp_comm_UnitGroup where name='面积组' and SysBind=1
	union all
	select cast(id as int) as id, '三角形','S=a*h/2',0 , 15 from erp_comm_UnitGroup where name='面积组' and SysBind=1
	union all
	select cast(id as int) as id, '圆','S=π*r*r',0 , 10 from erp_comm_UnitGroup where name='面积组' and SysBind=1

	
	insert into erp_comm_UnitGroupFormulaAttr( GroupAttrID, name, formulaAttr ,defvalue ,hided)
	select cast(id as int) as id, 'a','长', null , 0 from erp_comm_UnitGroupAttr where  name = '长方体'
	union all
	select cast(id as int) as id, 'b','宽', null , 0 from erp_comm_UnitGroupAttr where  name = '长方体'
	union all
	select cast(id as int) as id, 'c','高', null , 0 from erp_comm_UnitGroupAttr where  name = '长方体'

	insert into erp_comm_UnitGroupFormulaAttr( GroupAttrID, name, formulaAttr ,defvalue ,hided)
	select cast(id as int) as id, 'r','半径', null , 0 from erp_comm_UnitGroupAttr where  name = '圆柱'
	union all
	select cast(id as int) as id, 'h','高', null , 0 from erp_comm_UnitGroupAttr where  name = '圆柱'

	insert into erp_comm_UnitGroupFormulaAttr( GroupAttrID, name, formulaAttr ,defvalue ,hided)
	select cast(id as int) as id, 's','底面积', null , 0 from erp_comm_UnitGroupAttr where  name = '棱柱'
	union all
	select cast(id as int) as id, 'h','高', null , 0 from erp_comm_UnitGroupAttr where  name = '棱柱'

	insert into erp_comm_UnitGroupFormulaAttr( GroupAttrID, name, formulaAttr ,defvalue ,hided)
	select cast(id as int) as id, 's','底面积', null , 0 from erp_comm_UnitGroupAttr where  name = '椎体'
	union all
	select cast(id as int) as id, 'h','高', null , 0 from erp_comm_UnitGroupAttr where  name = '椎体'

	insert into erp_comm_UnitGroupFormulaAttr( GroupAttrID, name, formulaAttr ,defvalue ,hided)
	select cast(id as int) as id, 'a','长', null , 0 from erp_comm_UnitGroupAttr where  name = '长方形'
	union all
	select cast(id as int) as id, 'b','宽', null , 0 from erp_comm_UnitGroupAttr where  name = '长方形'

	insert into erp_comm_UnitGroupFormulaAttr( GroupAttrID, name, formulaAttr ,defvalue ,hided)
	select cast(id as int) as id, 'a','底边长', null , 0 from erp_comm_UnitGroupAttr where  name = '三角形'
	union all
	select cast(id as int) as id, 'h','高', null , 0 from erp_comm_UnitGroupAttr where  name = '三角形'

	insert into erp_comm_UnitGroupFormulaAttr( GroupAttrID, name, formulaAttr ,defvalue ,hided)
	select cast(id as int) as id, 'r','半径', null , 0 from erp_comm_UnitGroupAttr where  name = '圆'
	union all
	select 0, 'π','Pi', 3.14 , 1

end

GO

--预计划编号自定义
if not exists(select id from zdybh where sort1=52001)
begin
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('YJ_',1,1,4,2,1,52001)
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号2',1,0,4,2,2,52001) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号3',1,0,4,2,3,52001) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号4',1,0,4,2,4,52001) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',2,1,4,2,5,52001) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',3,1,2,2,6,52001) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',4,1,2,2,7,52001) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',5,1,3,2,8,52001) 
end

GO

--生产计划编号自定义
if not exists(select id from zdybh where sort1=52002)
begin
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('JH_',1,1,4,2,1,52002)
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号2',1,0,4,2,2,52002) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号3',1,0,4,2,3,52002) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号4',1,0,4,2,4,52002) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',2,1,4,2,5,52002) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',3,1,2,2,6,52002) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',4,1,2,2,7,52002) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',5,1,3,2,8,52002) 
end

GO

--生产订单编号自定义
if not exists(select id from zdybh where sort1=54001)
begin
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('DD_',1,1,4,2,1,54001)
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号2',1,0,4,2,2,54001) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号3',1,0,4,2,3,54001) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号4',1,0,4,2,4,54001) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',2,1,4,2,5,54001) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',3,1,2,2,6,54001) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',4,1,2,2,7,54001) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',5,1,3,2,8,54001) 
end

GO

--物料分析编号自定义
if not exists(select id from zdybh where sort1=53001)
begin
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('WLFX_',1,1,4,2,1,53001)
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号2',1,0,4,2,2,53001) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号3',1,0,4,2,3,53001) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号4',1,0,4,2,4,53001) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',2,1,4,2,5,53001) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',3,1,2,2,6,53001) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',4,1,2,2,7,53001) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',5,1,3,2,8,53001) 
end

GO

--生产排产编号自定义
if not exists(select id from zdybh where sort1=53002)
begin
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('CRP_',1,1,4,2,1,53002)
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号2',1,0,4,2,2,53002) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号3',1,0,4,2,3,53002) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号4',1,0,4,2,4,53002) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',2,1,4,2,5,53002) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',3,1,2,2,6,53002) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',4,1,2,2,7,53002) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',5,1,3,2,8,53002) 
end

GO

--生产派工编号自定义
if not exists(select id from zdybh where sort1=54002)
begin
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('PG_',1,1,4,2,1,54002)
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号2',1,0,4,2,2,54002) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号3',1,0,4,2,3,54002) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号4',1,0,4,2,4,54002) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',2,1,4,2,5,54002) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',3,1,2,2,6,54002) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',4,1,2,2,7,54002) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',5,1,3,2,8,54002) 
end

GO

--生产返工编号自定义
if not exists(select id from zdybh where sort1=54005)
begin
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('FG_',1,1,4,2,1,54005)
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号2',1,0,4,2,2,54005) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号3',1,0,4,2,3,54005) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号4',1,0,4,2,4,54005) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',2,1,4,2,5,54005) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',3,1,2,2,6,54005) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',4,1,2,2,7,54005) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',5,1,3,2,8,54005) 
end

GO

--工序编号自定义
if not exists(select id from zdybh where sort1=51002)
begin
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('GX_',1,1,4,2,1,51002)
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号2',1,0,4,2,2,51002) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号3',1,0,4,2,3,51002) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号4',1,0,4,2,4,51002) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',2,1,4,2,5,51002) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',3,1,2,2,6,51002) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',4,1,2,2,7,51002) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',5,1,3,2,8,51002) 
end

--产线编号自定义
if not exists(select id from zdybh where sort1=51006)
begin
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('CX_',1,1,4,2,1,51006)
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号2',1,0,4,2,2,51006) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号3',1,0,4,2,3,51006) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号4',1,0,4,2,4,51006) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',2,1,4,2,5,51006) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',3,1,2,2,6,51006) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',4,1,2,2,7,51006) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',5,1,3,2,8,51006) 
end

GO

--工价编号自定义
if not exists(select id from zdybh where sort1=56001)
begin
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('GJ_',1,1,4,2,1,56001)
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号2',1,0,4,2,2,56001) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号3',1,0,4,2,3,56001) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号4',1,0,4,2,4,56001) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',2,1,4,2,5,56001) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',3,1,2,2,6,56001) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',4,1,2,2,7,56001) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',5,1,3,2,8,56001) 
end

GO

--工艺流程编号自定义
if not exists(select id from zdybh where sort1=51003)
begin
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('GYLC_',1,1,4,2,1,51003)
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号2',1,0,4,2,2,51003) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号3',1,0,4,2,3,51003) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号4',1,0,4,2,4,51003) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',2,1,4,2,5,51003) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',3,1,2,2,6,51003) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',4,1,2,2,7,51003) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',5,1,3,2,8,51003) 
end

GO

--车间编号自定义
if not exists(select id from zdybh where sort1=51004)
begin
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('CJ_',1,1,4,2,1,51004)
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号2',1,0,4,2,2,51004) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号3',1,0,4,2,3,51004) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号4',1,0,4,2,4,51004) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',2,1,4,2,5,51004) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',3,1,2,2,6,51004) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',4,1,2,2,7,51004) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',5,1,3,2,8,51004) 
end

GO

--计件工资编号自定义
if not exists(select id from zdybh where sort1=56004)
begin
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('JJGZ_',1,1,4,2,1,56004)
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号2',1,0,4,2,2,56004) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号3',1,0,4,2,3,56004) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号4',1,0,4,2,4,56004) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',2,1,4,2,5,56004) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',3,1,2,2,6,56004) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',4,1,2,2,7,56004) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',5,1,3,2,8,56004) 
end

GO
--计时工资编号自定义
if not exists(select id from zdybh where sort1=56008)
begin
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('JSGZ_',1,1,4,2,1,56008)
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号2',1,0,4,2,2,56008) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号3',1,0,4,2,3,56008) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号4',1,0,4,2,4,56008) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',2,1,4,2,5,56008) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',3,1,2,2,6,56008) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',4,1,2,2,7,56008) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',5,1,3,2,8,56008) 
end

GO

if not exists(select id from M2_QualityTestingsConfig where proType=1)
begin
	insert into M2_QualityTestingsConfig(isMaxNum,autoKuin,autoBlankChuin,proType,isRegist) values(0,0,0,1,1)
end


GO

if not exists(select id from M2_QualityTestingsConfig where proType=2)
begin
	insert into M2_QualityTestingsConfig(isMaxNum,autoKuin,autoBlankChuin,proType,isRegist) values(0,0,0,2,1)
end

if exists(select id from M2_QualityTestingsConfig where isRegist=0)
begin
	update M2_QualityTestingsConfig set isRegist=1 where isRegist=0
end

GO

--生产领料编号自定义
if not exists(select id from zdybh where sort1=55001)
begin
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('SCLL_',1,1,4,2,1,55001)
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号2',1,0,4,2,2,55001) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号3',1,0,4,2,3,55001) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号4',1,0,4,2,4,55001) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',2,1,4,2,5,55001) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',3,1,2,2,6,55001) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',4,1,2,2,7,55001) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',5,1,3,2,8,55001) 
end

GO

--生产退料编号自定义
if not exists(select id from zdybh where sort1=55002)
begin
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('SCTL_',1,1,4,2,1,55002)
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号2',1,0,4,2,2,55002) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号3',1,0,4,2,3,55002) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号4',1,0,4,2,4,55002) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',2,1,4,2,5,55002) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',3,1,2,2,6,55002) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',4,1,2,2,7,55002) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',5,1,3,2,8,55002) 
end

GO

--生产废料编号自定义
if not exists(select id from zdybh where sort1=55003)
begin
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('SCFL_',1,1,4,2,1,55003)
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号2',1,0,4,2,2,55003) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号3',1,0,4,2,3,55003) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号4',1,0,4,2,4,55003) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',2,1,4,2,5,55003) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',3,1,2,2,6,55003) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',4,1,2,2,7,55003) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',5,1,3,2,8,55003) 
end

GO

if not exists(select 1 from sys_sdk_BillFieldInfo where BillType=16001  and dbname like 'zdy%')
begin
	begin Tran ZdyConfigCopy
	insert into sys_sdk_BillFieldInfo(ModuleType, BillType, ListType, InheritId, Title, DBName, UiType, DbType, Unit, Remark, 
	ShowIndex, Colspan, Rowspan, Display,SourceTag, IsUsed, cansearch,candc, candr, cantj,
	mustfillin)

	select 0, 16001,0,0,title, name, (case sort when 2 then 0 else 5 end) as UiType,
	(case sort when 2 then 5 else 0 end) as DbType, '', '', gate1, -1, -1, -1, 0 as SourceTag,
	set_open, js, dc, dr, tj, bt 
	from zdy where sort1=21
	union all
	select 0, 16001,0,0,FName, 'ext' + cast(id as varchar(12)), 
	(case ftype 
	when 1 then 0 
	when 2 then 10
	when 3 then 1 
	when 4 then 2 
	when 5 then 13 
	when 6 then 4 
	when 7 then 5 
	else 0 end) as UiType,
	5, '','', FOrder, -1, -1, -1, 0 as SourceTag,
	IsUsing, CanSearch, CanExport, CanInport, CanStat, MustFillin
	 from ERP_CustomFields where TName = 21

	insert into sys_sdk_BillFieldOptionsSource(FieldId, [text], ShowIndex)
	select b.Id as fieldid, c.sort1, c.gate1 from zdy a inner join sys_sdk_BillFieldInfo b 
	on a.name=b.DBName and a.sort1=21 and b.BillType=16001
	and a.gl>0
	inner join sortonehy c on a.gl = c.gate2 
	
	
	insert into sys_sdk_BillFieldOptionsSource(FieldId, [text], ShowIndex)
	select y.Id, z.CValue, 1 from ERP_CustomFields x 
	inner join sys_sdk_BillFieldInfo y on x.TName=21 and y.BillType=16001 and y.DBName = ('ext' + CAST(x.ID as varchar(12)))
	inner join ERP_CustomOptions z on x.OptionID=z.CFID
	order by z.ID

	declare @minid int 
	select @minid = MIN(id) from sys_sdk_BillFieldInfo where BillType=16001
	update sys_sdk_BillFieldInfo set ShowIndex=Id-@minid+1 where BillType=16001
	commit Tran ZdyConfigCopy
end

GO

if exists(select 1 from sortwages where salaryClass like '{计件工资}')
begin 
	update sortwages set salaryClass = replace(salaryClass ,'{计件工资}' , '{生产计件工资}')  where salaryClass like '{计件工资}'
end

GO

if exists(select 1 from zdymx where sort1=80 and name='sssb')
begin 
	delete from zdymx where sort1=80 and name='sssb'
end

GO

if exists(select 1 from zdymx where sort1=80 and sorce=23 and title='关联生产设备')
begin 
	delete from zdymx where sort1=80 and sorce=23 and title='关联生产设备'
end

GO

--派工质检编号自定义
if not exists(select id from zdybh where sort1=54004)
begin
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('QC_',1,1,4,2,1,54004)
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号2',1,0,4,2,2,54004) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号3',1,0,4,2,3,54004) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号4',1,0,4,2,4,54004) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',2,1,4,2,5,54004) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',3,1,2,2,6,54004) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',4,1,2,2,7,54004) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',5,1,3,2,8,54004) 
end

GO
--派工送检任务编号自定义
if not exists(select id from zdybh where sort1=54013)
begin
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('QCSJ_',1,1,4,2,1,54013)
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号2',1,0,4,2,2,54013) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号3',1,0,4,2,3,54013) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号4',1,0,4,2,4,54013) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',2,1,4,2,5,54013) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',3,1,2,2,6,54013) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',4,1,2,2,7,54013) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',5,1,3,2,8,54013) 
end

GO

--委外质检编号自定义
if not exists(select id from zdybh where sort1=54009)
begin
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('WYZJ_',1,1,4,2,1,54009)
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号2',1,0,4,2,2,54009) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号3',1,0,4,2,3,54009) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号4',1,0,4,2,4,54009) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',2,1,4,2,5,54009) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',3,1,2,2,6,54009) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',4,1,2,2,7,54009) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',5,1,3,2,8,54009) 
end

GO

if exists(select id from zdymx where sort1=44 and sort=15 and title='委外付款' )
begin
	update zdymx set title='整单委外' where sort1=44 and sort=15 and title='委外付款' 
end

GO

if exists(select id from zdymx where sort1=44 and sort=15 and name='in15' )
begin
	update zdymx set name='out15' where sort1=44 and sort=15 and name='in15' 
end

GO

--整单委外编号自定义
if not exists(select id from zdybh where sort1=54003)
begin
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('ZDWW_',1,1,4,2,1,54003)
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号2',1,0,4,2,2,54003) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号3',1,0,4,2,3,54003) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号4',1,0,4,2,4,54003) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',2,1,4,2,5,54003) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',3,1,2,2,6,54003) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',4,1,2,2,7,54003) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',5,1,3,2,8,54003) 
end

GO

--增加生产成本的部门间费用分类
if exists(select id from sortonehy where gate2=41 and sort1='部门间费用' and isnull(id1,0)=0)
begin
	update sortonehy set id1=5 where gate2=41 and sort1='部门间费用'
end
if not exists(select id from sortonehy where gate2=41 and id1=5)
begin
	insert into sortonehy(sort1,gate1,gate2,id1,del,isStop) values('部门间费用',1,41,5,1,0)
	update sortonehy set ord=id where gate2=41 and id1=5
end
if not exists(select 1 from home_usConfig where name = 'produceV2_chargeshare_paysy_sort2')
begin
	if not exists(select 1 from paytype where sort1 = '水费' and sid=80 and sort2 in(select top 1 ord from sortonehy where gate2=41 and id1=5))
	begin
		insert into paytype(sort1,sort2,gate2,sid,del) 
		select top 1 '水费', ord, 1, 80, 1 from sortonehy where gate2=41 and id1=5
	end 
	if not exists(select 1 from paytype where sort1 = '电费' and sid=80 and sort2 in(select top 1 ord from sortonehy where gate2=41 and id1=5))
	begin
		insert into paytype(sort1,sort2,gate2,sid,del) 
		select top 1 '电费', ord, 1, 80, 1 from sortonehy where gate2=41 and id1=5
	end 
	insert into home_usConfig(name,nvalue,tvalue,uid) values('produceV2_chargeshare_paysy_sort2',null,CONVERT(VARCHAR(23),GETDATE(),120),0)
end

GO

--增加生产成本的部门内费用分类
if exists(select id from sortonehy where gate2=41 and sort1='部门内费用' and isnull(id1,0)=0)
begin
	update sortonehy set id1=6 where gate2=41 and sort1='部门内费用'
end
if not exists(select id from sortonehy where gate2=41 and id1=6)
begin
	insert into sortonehy(sort1,gate1,gate2,id1,del,isStop) values('部门内费用',1,41,6,1,0)
	update sortonehy set ord=id where gate2=41 and id1=6
end
if not exists(select 1 from home_usConfig where name = 'produceV2_inchargeshare_paysy_sort2')
begin
	if not exists(select 1 from paytype where sort1 = '设备维修' and sid=80 and sort2 in(select top 1 ord from sortonehy where gate2=41 and id1=6))
	begin
		insert into paytype(sort1,sort2,gate2,sid,del) 
		select top 1 '设备维修', ord, 1, 80, 1 from sortonehy where gate2=41 and id1=6
	end 
	insert into home_usConfig(name,nvalue,tvalue,uid) values('produceV2_inchargeshare_paysy_sort2',null,CONVERT(VARCHAR(23),GETDATE(),120),0)
end

GO

--增加生产成本的生产订单费用分类
if exists(select id from sortonehy where gate2=41 and sort1='生产订单费用' and isnull(id1,0)=0)
begin
	update sortonehy set id1=7 where gate2=41 and sort1='生产订单费用'
end
if not exists(select id from sortonehy where gate2=41 and id1=7)
begin
	insert into sortonehy(sort1,gate1,gate2,id1,del,isStop) values('生产订单费用',1,41,7,1,0)
	update sortonehy set ord=id where gate2=41 and id1=7
end
if exists(select id from sortonehy where gate2=41 and id1=7 and del=1 and isStop=0 and sort1='生产订单内费用')
begin
	update sortonehy set sort1='生产订单费用' where gate2=41 and id1=7 and del=1 and isStop=0 and sort1='生产订单内费用'
end 
if not exists(select 1 from home_usConfig where name = 'produceV2_scddchargeshare_paysy_sort2')
begin
	if not exists(select 1 from paytype where sort1 = '水费' and sid=80 and sort2 in(select top 1 ord from sortonehy where gate2=41 and id1=7))
	begin
		insert into paytype(sort1,sort2,gate2,sid,del) 
		select top 1 '水费', ord, 1, 80, 1 from sortonehy where gate2=41 and id1=7
	end 
	if not exists(select 1 from paytype where sort1 = '电费' and sid=80 and sort2 in(select top 1 ord from sortonehy where gate2=41 and id1=7))
	begin
		insert into paytype(sort1,sort2,gate2,sid,del) 
		select top 1 '电费', ord, 1, 80, 1 from sortonehy where gate2=41 and id1=7
	end 
	insert into home_usConfig(name,nvalue,tvalue,uid) values('produceV2_scddchargeshare_paysy_sort2',null,CONVERT(VARCHAR(23),GETDATE(),120),0)
end

GO

--增加生产成本的整单委外费用分类，算入直接材料
if exists(select id from sortonehy where gate2=41 and sort1='整单委外费用' and isnull(id1,0)=0)
begin
	update sortonehy set id1=8 where gate2=41 and sort1='整单委外费用'
end
if not exists(select id from sortonehy where gate2=41 and id1=8)
begin
	insert into sortonehy(sort1,gate1,gate2,id1,del,isStop) values('整单委外费用',1,41,8,1,0)
	update sortonehy set ord=id where gate2=41 and id1=8
end
if not exists(select 1 from home_usConfig where name = 'produceV2_zdwwchargeshare_paysy_sort2')
begin
	if not exists(select 1 from paytype where sort1 = '委外费用' and sid=80 and sort2 in(select top 1 ord from sortonehy where gate2=41 and id1=8))
	begin
		insert into paytype(sort1,sort2,gate2,sid,del) 
		select top 1 '委外费用', ord, 1, 80, 1 from sortonehy where gate2=41 and id1=8
	end 
	insert into home_usConfig(name,nvalue,tvalue,uid) values('produceV2_zdwwchargeshare_paysy_sort2',null,CONVERT(VARCHAR(23),GETDATE(),120),0)
end

GO

--增加生产成本的工序委外费用分类，算入直接材料
if exists(select id from sortonehy where gate2=41 and sort1='工序委外费用' and isnull(id1,0)=0)
begin
	update sortonehy set id1=9 where gate2=41 and sort1='工序委外费用'
end
if not exists(select id from sortonehy where gate2=41 and id1=9)
begin
	insert into sortonehy(sort1,gate1,gate2,id1,del,isStop) values('工序委外费用',1,41,9,1,0)
	update sortonehy set ord=id where gate2=41 and id1=9
end
if not exists(select 1 from home_usConfig where name = 'produceV2_gxwwchargeshare_paysy_sort2')
begin
	if not exists(select 1 from paytype where sort1 = '委外费用' and sid=80 and sort2 in(select top 1 ord from sortonehy where gate2=41 and id1=9))
	begin
		insert into paytype(sort1,sort2,gate2,sid,del) 
		select top 1 '委外费用', ord, 1, 80, 1 from sortonehy where gate2=41 and id1=9
	end 
	insert into home_usConfig(name,nvalue,tvalue,uid) values('produceV2_gxwwchargeshare_paysy_sort2',null,CONVERT(VARCHAR(23),GETDATE(),120),0)
end

GO

if not exists(select id from zdybh where sort1=6030)
begin
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('SJ_',1,1,4,2,1,6030)
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号2',1,0,4,2,2,6030) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号3',1,0,4,2,3,6030) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号4',1,0,4,2,4,6030) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',2,1,4,2,5,6030) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',3,1,2,2,6,6030) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',4,1,2,2,7,6030) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',5,1,3,2,8,6030) 
end
else if exists(select id from zdybh where sort1=6030 and gate1=1 and title='SY_')
begin 
	update zdybh set title = 'SJ_'  where sort1=6030 and gate1=1 and title='SY_'
end

GO

--物料清单编号自定义
if not exists(select id from zdybh where sort1=51005)
begin
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('WLQD_',1,1,4,2,1,51005)
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号2',1,0,4,2,2,51005) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号3',1,0,4,2,3,51005) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号4',1,0,4,2,4,51005) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',2,1,4,2,5,51005) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',3,1,2,2,6,51005) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',4,1,2,2,7,51005) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',5,1,3,2,8,51005) 
end

--物料登记编号自定义
if not exists(select id from zdybh where sort1=55004)
begin
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('WLDJ_',1,1,4,2,1,55004)
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号2',1,0,4,2,2,55004) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号3',1,0,4,2,3,55004) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号4',1,0,4,2,4,55004) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',2,1,4,2,5,55004) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',3,1,2,2,6,55004) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',4,1,2,2,7,55004) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',5,1,3,2,8,55004) 
end

GO

--工序委外编号自定义
if not exists(select id from zdybh where sort1=54006)
begin
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('GXWW_',1,1,4,2,1,54006)
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号2',1,0,4,2,2,54006) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号3',1,0,4,2,3,54006) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号4',1,0,4,2,4,54006) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',2,1,4,2,5,54006) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',3,1,2,2,6,54006) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',4,1,2,2,7,54006) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',5,1,3,2,8,54006) 
end

GO

if exists(select 1 from nldata where AutoI is null) 
begin
	update nldata set AutoI = DATEDIFF(DD,'1900-1-1', yl),
	AutoT2 = DATEADD(s,3600*24-1,yl)
end

GO

declare @minautoI int , @minautoI1 int, @minautoI2 int
select  @minautoI = min(autoI),   @minautoI1=min(datediff(d,'1900-1-1',yl)),  @minautoI2=min(datediff(d,'1900-1-1',autot2)) from nlData
if @minautoI>0 or @minautoI1>0 or @minautoI2>0
begin
	update nlData set yl= dateadd(d, 0-@minautoI1, yl), autot2= dateadd(d,0-@minautoI2, autot2),  autoI=autoI-@minautoI
end 

GO

if not exists(select 1 from M2_CostSet)
begin 
	insert into M2_CostSet ([Date1],[CostType],[Creator],[indate]) 
	select convert(varchar(10),dateadd(dd, 1-day(GETDATE()), GETDATE()),120) as Date1 , 2 as CostType , 0 as Creator , getdate()
end 

go

UPDATE dbo.HrKQ_AttendanceType SET AttTypeCls = (CASE WHEN Title LIKE '%班%' THEN 2
WHEN Title LIKE '%假%' THEN 1 WHEN Title LIKE '%出%' OR Title LIKE '%差%' THEN 3 ELSE 0 end)
WHERE AttTypeCls IS NULL

GO

update product set roles='3' where isnull(canOutStore,1)=1 and isnull(roles,'')='' 

GO

if exists(select 1 from product where WastAge is null)
begin 
	update p  set p.WastAge = isnull(MRP.AttritionRate,0) , p.safeNum = isnull(MRP.SaveNum,0)
	from  product p
	left join (select MAX(ID) ID, ProductID from M_ProductMRP group by ProductID) MP on MP.ProductID = p.ord
	LEFT JOIN M_ProductMRP MRP on MRP.ID = Mp.ID
	where p.WastAge is null
end 

GO

if exists(select 1 from dk where dkdate is null)
begin
	update d set d.dkdate = (select top 1 date1 from bank where [sort]=40 and gl =d.bxid) from dk d where d.dkdate is null
end 

if exists(select 1 from dk where dkdate is null)
begin
	update d set d.dkdate = (select top 1 date1 from sp_intro where sort1=4 and ord = d.bxid order by date1 desc) from dk d where d.dkdate is null
end 

if exists(select 1 from dk where dkdate is null)
begin
	update d set d.dkdate = (select top 1 bxdate from paybx where id= d.bxid) from dk d where d.dkdate is null
end

GO
--费用分摊自定义
if not exists(select id from zdybh where sort1=74001)
begin
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('FT_',1,1,4,2,1,74001)
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号2',1,0,4,2,2,74001) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号3',1,0,4,2,3,74001) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号4',1,0,4,2,4,74001) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',2,1,4,2,5,74001) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',3,1,2,2,6,74001) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',4,1,2,2,7,74001) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',5,1,3,2,8,74001) 
end

GO

if exists(select 1 from menu  where  id1=0 and Deep  is null)
begin
	exec [erp_product_updateNodeStatus]
end

GO

if not exists(select top 1 intro from setopen where sort1=2018042901)
begin
	INSERT INTO setopen(intro,sort1) VALUES(0,2018042901)
end

if not exists(select top 1 title from externalArgs where name='openid')
begin
	INSERT INTO externalArgs(title, name, fval) VALUES('微信号ID','openid','{openid}')
end

if not exists(select top 1 title from externalArgs where name='contract_id')
begin
	INSERT INTO externalArgs(title, name, fval) VALUES('合同ID','contract_id','{contract_id}')
end

if not exists(select top 1 title from externalArgs where name='payid')
begin
	INSERT INTO externalArgs(title, name, fval) VALUES('收款ID','payid','{payid}')
end

GO

if exists(select 1 from contract where del<>2 and invoiceMode = 1 and isnull(taxRate,0)=0)
begin 
    update a set a.taxRate = b.taxRate
    from contract a 
    inner join invoiceConfig b on b.typeid = a.invoicePlanType
    where a.del<>2 and a.invoiceMode=1 and isnull(a.taxRate,0)=0
end 

GO

if exists(select 1 from paybackInvoice where isnull(taxRate,0)=0)
begin 
    update a set a.taxRate = b.taxRate
    from paybackInvoice a 
    inner join invoiceConfig b on b.typeid = a.invoiceType
    where isnull(a.taxRate,0)=0
end

GO

if exists(select 1 from payoutInvoice where isnull(taxRate,0)=0)
begin 
    update a set a.taxRate = b.taxRate
    from payoutInvoice a 
    inner join invoiceConfig b on b.typeid = a.invoiceType
    where isnull(a.taxRate,0)=0
end

GO
 
if exists(select 1  from  contract_out where sort=10)
begin
    --出库打印模板更新
    update contract_out  set  sort=62001,PrintID=62001   where sort=10 and isnull(PrintID,0)>0  and  del=1
    update contract_out  set  sort=62001   where sort=10 and isnull(PrintID,0)=0  and  del=1
end

GO

if exists(select 1  from  contract_out where sort=62001)
begin
    update PrintTemplate_Type set oldurl='../contract/planall_out.asp?sort=62001&main=1',ord=62001 where ord=10
end

GO

if exists(select 1  from  PrinterInfo where sort=10)
begin
    update PrinterInfo  set  sort=62001 where sort=10
end

GO
if not exists(select 1 from home_usConfig where name = '62001config')
begin
	update  power set sort2=17 where sort1=32 and sort2=16
	insert into home_usConfig(name,nvalue,tvalue,uid) values('62001config',null,1,0)
end


GO

if not exists(select 1 from zdybh where sort1=61001)
begin 
    --入库自定义编号
    insert into zdybh( title,sort,set_open,intro1,intro2,gate1, sort1)
    select title,sort,set_open,intro1,intro2,gate1,61001 as sort1 from zdybh where sort1=31 order by gate1
    --入库库管权限
    update power set sort2=17  where sort1=31 and sort2=16
end

GO

if not exists(select 1 from zdybh where sort1=16001)
begin 
    --产品自定义编号
    insert into zdybh( title,sort,set_open,intro1,intro2,gate1, sort1)
    select title,sort,set_open,intro1,intro2,gate1,16001 as sort1 from zdybh where sort1=21 order by gate1
    UPDATE a SET a.fieldID = b.inx FROM dbo.zdybh a
	INNER JOIN (
		SELECT ROW_NUMBER() OVER(ORDER BY gate1) inx,id FROM dbo.zdybh WHERE sort1 = 16001 AND sort = 1
	) b ON a.id = b.id
    UPDATE dbo.zdybh SET fieldID = sort + 3 WHERE sort1 = 16001 AND sort > 1
	UPDATE dbo.zdybh SET sort = 6 WHERE sort1 = 16001 AND sort = 1
END

GO

if not exists (select 1 from zdymx where sort1=33 and title = '交货日期' and name = 'date2')
    begin
        delete from zdymx where sort1 = 33 and name = 'date2' and title = '到货日期'
        insert into zdymx (title,name,sort,kd,kd2,set_open,gate1,sorce,sort1) values('交货日期','date2',2,80,80,1,10,10,33);
        update zdymx set gate1 = 11 ,sorce = 11 where sort1 = 33 and name = 'intro';
        update zdymx set gate1 = 12 ,sorce = 12 where sort1 = 33 and name = 'zdy1';
        update zdymx set gate1 = 13 ,sorce = 13 where sort1 = 33 and name = 'zdy2';
        update zdymx set gate1 = 14 ,sorce = 14 where sort1 = 33 and name = 'zdy3';
        update zdymx set gate1 = 15 ,sorce = 15 where sort1 = 33 and name = 'zdy4';
        update zdymx set gate1 = 16 ,sorce = 16 where sort1 = 33 and name = 'zdy5';
        update zdymx set gate1 = 17 ,sorce = 17 where sort1 = 33 and name = 'zdy6';
end
--将采购退货明细老版自定义字段 单价 改成 含税单价
if exists(select 1 from zdymx where sort1=75 and sorce=5 and title='单价')
begin
	update zdymx set title='含税单价' where sort1=75 and sorce=5 and title='单价'
end

GO

--原始库垃圾产品分类数据清理
DELETE FROM dbo.menu WHERE id1 IN(24,442) AND menuname IN('苹果','江民') AND RootId IN(430,451)


GO

delete mxpx where datepx>=getdate() 

GO

if not exists(select 1 from sys_sdk_BillFieldInfo  b  where  b.billtype=11001 and b.ListType='1')
begin 
	INSERT INTO [dbo].[sys_sdk_BillFieldInfo]([ModuleType],[BillType],[ListType],[InheritId], 
		[Title],[DBName],[UiType],[DbType],[Unit],[Remark],
		[ShowIndex],[Colspan],[Rowspan],[Display],[IsUsed],
		[SourceTag] ,[cansearch],[candc],[candr],[mustfillin],[cantj])
	
	select 0 as [ModuleType],11001 as [BillType],1 as [ListType], t.id as [InheritId],
		isnull(b.title, t.title) as title,t.dbname , isnull(t.UiType,0) as uitype, 5 as [DbType],'' as [Unit],'' as [Remark],
		isnull(b.gate1, t.ShowIndex) as showindex , -1 as [Colspan], -1 [Rowspan],-1 [Display] , isnull(t.defIsUsed,0) as IsUsed, 
		'' as [SourceTag], 0 as [cansearch] , 0 as [candc] , t.[candr], t.mustfillin , 0 as [cantj]
	from (
		select Title,  'InheritId_id_' + cast(id as varchar(12)) as dbname,  id, (showindex + 21) as showindex, uitype, 
			0 as mustshow,isUsed as defIsUsed, candr,mustfillin ,dbname as FieldName
		from sys_sdk_BillFieldInfo 
		where ListType=0 and BillType =16001 and BillType>0 
		union all select '产品名称', 'InheritId_self_title',  0, 1,0,1,1,1,0 , 'title'
		union all select '编号', 'InheritId_self_order1',  0, 2,0,0,1,1,0, 'order1'
		union all select '型号', 'InheritId_self_type1',  0, 3,0,0,1,1,0, 'type1'
		union all select '单位', 'InheritId_self_unit',  0, 4,0,1,1,1,0, 'unitall'
		union all select '数量', 'InheritId_self_num1',  0, 5,0,1,1,1,0, 'num1'
		union all select '未税单价', 'InheritId_self_price1',  0, 6,0,0,1,1,0, 'price1'
		union all select '折扣', 'InheritId_self_discount',  0, 7,0,0,1,1,0, 'discount'
		union all select '折后单价', 'InheritId_self_priceAfterDiscount',  0, 8,0,0,1,1,0, 'priceAfterDiscount'
		union all select '含税单价', 'InheritId_self_priceIncludeTax',  0, 9,0,0,1,1,0, 'priceIncludeTax'
		union all select '含税折后单价', 'InheritId_self_priceAfterTaxPre',  0, 10,0,0,1,1,0, 'priceAfterTaxPre'
		union all select '票据类型', 'InheritId_self_invoiceType',  0, 11,0,0,1,1,0, 'invoiceType'
		union all select '税率', 'InheritId_self_taxRate',  0, 12,0,0,1,1,0, 'taxRate'
		union all select '税后总价', 'InheritId_self_moneyAfterTax',  0, 13,0,0,1,1,0, 'moneyAfterTax'
        union all select '明细优惠', 'InheritId_self_concessions',  0, 14,0,0,1,1,0, 'concessions'
        union all select '优惠后单价', 'InheritId_self_priceAfterTax',  0, 15,0,0,1,1,0, 'priceAfterTax'
        union all select '金额', 'InheritId_self_moneyAfterConcessions',  0, 16,0,0,1,1,0, 'moneyAfterConcessions'
		union all select '税额', 'InheritId_self_taxValue',  0, 17,0,0,1,1,0, 'taxValue'
		union all select '优惠后总价', 'InheritId_self_money1',  0, 18,0,1,1,1,0, 'money1'
		union all select '建议进价', 'InheritId_self_pricejy',  0, 19,0,1,1,1,0, 'pricejy'
		union all select '建议总价', 'InheritId_self_tpricejy',  0, 20,0,1,1,1,0, 'tpricejy'
		union all select '交货日期', 'InheritId_self_date2',  0, 21,0,0,1,1,0, 'date2'
		union all select '备注', 'InheritId_self_intro',  0, 22,0,0,1,1,0, 'intro'
	) t 
	left join zdymx b on t.FieldName=b.name and b.sort1=5
	order by t.showindex

    INSERT INTO [dbo].[sys_sdk_BillFieldValue]([BillType],[BillListType],[BillId],[ListID],[FieldId],[Value],[BigValue])
	select 11001,  1,  cl.contract,cl.id, a.id as [FieldId], cl.zdy1 ,null
	from sys_sdk_BillFieldInfo a
	inner join contractlist cl on (len(isnull(cl.zdy1,''))>0 and a.dbname ='zdy1' ) 
	where a.ListType=0 and a.BillType =16001 and a.BillType>0 and a.dbname ='zdy1'
	union all
	select 11001,  1,  cl.contract,cl.id, a.id as [FieldId], cl.zdy2 ,null
	from sys_sdk_BillFieldInfo a
	inner join contractlist cl on (len(isnull(cl.zdy2,''))>0 and a.dbname ='zdy2' )
	where a.ListType=0 and a.BillType =16001 and a.BillType>0 and a.dbname ='zdy2'
	union all
	select 11001,  1,  cl.contract,cl.id, a.id as [FieldId], cl.zdy3 ,null
	from sys_sdk_BillFieldInfo a
	inner join contractlist cl on (len(isnull(cl.zdy3,''))>0 and a.dbname ='zdy3' )
	where a.ListType=0 and a.BillType =16001 and a.BillType>0 and a.dbname ='zdy3' 
	union all
	select 11001,  1,  cl.contract,cl.id, a.id as [FieldId], cl.zdy4 ,null
	from sys_sdk_BillFieldInfo a
	inner join contractlist cl on (len(isnull(cl.zdy4,''))>0 and a.dbname ='zdy4' )
	where a.ListType=0 and a.BillType =16001 and a.BillType>0 and a.dbname='zdy4'
	union all
	select 11001,  1,  cl.contract,cl.id, a.id as [FieldId], s.sort1 ,null
	from sys_sdk_BillFieldInfo a
	inner join contractlist cl on (isnull(cl.zdy5,0)>0 and a.dbname ='zdy5' )
	inner join sortonehy s on s.ord= cl.zdy5
	where a.ListType=0 and a.BillType =16001 and a.BillType>0 and a.dbname ='zdy5'
	union all
	select 11001,  1,  cl.contract,cl.id, a.id as [FieldId], s.sort1 ,null
	from sys_sdk_BillFieldInfo a
	inner join contractlist cl on (isnull(cl.zdy6,0)>0 and a.dbname ='zdy6' )
	inner join sortonehy s on s.ord= cl.zdy6
	where a.ListType=0 and a.BillType =16001 and a.BillType>0 and a.dbname ='zdy6'
end 

GO

    update contract_out  set  sort=11001   where sort=1  and  del=1

GO
    update contract_out set PrintID=11001 where PrintID=1 and  del=1 AND (isStop = 0 OR isStop IS NULL)

go


if exists(select 1 from home_usConfig where name='update_sign_m2wfp_remark')
begin
    ---处理老数据迁移过来的工艺流程详情，加工路线的备注与老版工艺流程的加工路线备注显示一致
    UPDATE m2wfp SET remark=mwfp.remark FROM M2_WFP  m2wfp
    LEFT JOIN M2_WorkingProcedures m2wp ON m2wfp.WPID = m2wp.ID
    INNER JOIN M_WorkingProcedures  mwp ON m2wp.oldverId=mwp.ID
    LEFT JOIN M_WFP mwfp ON mwfp.WPID=mwp.ID AND mwfp.ID =m2wfp.id 
    where  isnull(datalength(m2wfp.remark),0) = 0
    insert into home_usConfig ( name, nvalue) values ('update_sign_m2wfp_remark', '1')
end

GO
    if exists(select 1  from  PrinterInfo where sort=1)
    begin
        update PrinterInfo  set  sort=11001 where sort=1
    end
GO

 if exists(select 1  from  contract_out where sort=5)
    begin
         update contract_out  set  sort=18001   where sort=5  and  del=1
    end

GO

if not exists(select 1 from sys.databases where name='ZBTransactionCache')
begin
	create database ZBTransactionCache
end

GO

if not exists(select 1 from ZBTransactionCache.sys.tables  where name='WxPayTransData')
begin
	create table ZBTransactionCache.dbo.WxPayTransData(
		[id] [int] IDENTITY(1,1) NOT NULL,
		[db] [nvarchar](100) NULL,
		[data] [nvarchar](max) NULL,
		[addtime] [datetime] NULL,
		[querydata] [nvarchar](100) NULL,
		[uid] [int] NULL
	)
end

GO

UPDATE x SET x.QTResultAll = y.QTResultAll
FROM M2_QualityTestings x INNER JOIN (
	SELECT a.ID, MAX(b.QTResult) AS QTResultAll
	FROM M2_QualityTestings a
	INNER JOIN M2_QualityTestingLists b ON a.ID=b.QTID
	WHERE a.QTResultAll IS NULL
	GROUP BY a.ID 
) y ON x.ID=y.ID
WHERE x.QTResultAll IS NULL

GO

--派工增加审批处理历史数据
UPDATE dbo.M2_WorkAssigns SET SPStatus = -1 WHERE SPStatus IS NULL

GO

if not exists(select top 1 1 from home_usconfig where name = 'store_KuoutCanSendSet')
begin
	insert into home_usconfig(name,tvalue,nvalue,uid) values('store_KuoutCanSendSet',0,'',0)
	insert into home_usconfig(name,tvalue,nvalue,uid) values('KuoutCanSend','5,4,6,7,9,12','',0)
end

GO

--新的打卡设置优化为各个分组单独设置，所以将历史没有绑定分组的打卡设置清除
DELETE FROM dbo.HrKQ_CardSetting WHERE ISNULL(GroupID,0) = 0
go

--app派工审批和提醒,工序到期提醒设置默认值关闭
UPDATE  reminderInterface SET [stop]=1 WHERE ord IN(224,54002,54007)
GO
---分类中预置默认分类
if not exists (select 1 from sortonehy where gate2=45001 AND sort1='默认分类')
BEGIN
 INSERT INTO sortonehy (sort1,gate1,gate2,del,isstop) VALUES ('默认分类',40,45001,1,0)
 INSERT INTO sortonehy (sort1,gate1,gate2,del,isstop) VALUES ('默认分类',40,45002,1,0)
 END
GO
 UPDATE sortonehy SET ord=id WHERE gate2=45001 AND sort1='默认分类' and ord is null
 UPDATE sortonehy SET ord=id WHERE gate2=45002 AND sort1='默认分类' and ord is null
GO
---处理bankin bankout老数据

UPDATE a SET a.bz =e.sort1 FROM bankin a INNER JOIN sortbank c ON c.id=a.ck  INNER JOIN sortbz  e ON c.bz=e.id  WHERE a.bz IS null

UPDATE a SET a.bz =e.sort1 FROM bankout a INNER JOIN sortbank c ON c.id=a.ck  INNER JOIN sortbz  e ON c.bz=e.id WHERE a.bz IS null

UPDATE bankin SET typeord = (SELECT id FROM  sortonehy where sort1='默认分类'  and gate2=45001) where typeord is null

UPDATE bankout SET typeord = (SELECT id FROM  sortonehy where sort1='默认分类'  and gate2=45002) where typeord is null

GO

--将不存在的BOM的关系数据清除
DELETE a FROM M2_BomProParents a LEFT JOIN dbo.M2_BOM b ON a.BomID = b.ID WHERE b.ID IS NULL
--维护bom嵌套关系表del字段值
UPDATE a SET a.del = (CASE WHEN b.ID IS NULL OR b.del = 2 THEN 0 ELSE 1 END) FROM M2_BomProParents a LEFT JOIN dbo.M2_BOM b ON a.BomID = b.ID
GO

if not exists(select title from finance_AgingOfAccountTimeDefine)
begin
insert into finance_AgingOfAccountTimeDefine(title,day1,day2) values ('30天',30,-1)
insert into finance_AgingOfAccountTimeDefine(title,day1,day2) values ('60天',60,30)
insert into finance_AgingOfAccountTimeDefine(title,day1,day2) values ('90天',90,60)
insert into finance_AgingOfAccountTimeDefine(title,day1,day2) values ('120天',120,90)
end

GO

--质检方案编号自定义
if not exists(select id from zdybh where sort1=57002)
begin
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('ZJ_',1,1,4,2,1,57002)
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号2',1,0,4,2,2,57002) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号3',1,0,4,2,3,57002) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号4',1,0,4,2,4,57002) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',2,1,4,2,5,57002) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',3,1,2,2,6,57002) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',4,1,2,2,7,57002) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',5,1,3,2,8,57002) 
end

GO

--流程方案编号自定义
if not exists(select id from zdybh where sort1=57003)
begin
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('LCZJ_',1,1,4,2,1,57003)
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号2',1,0,4,2,2,57003) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号3',1,0,4,2,3,57003) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号4',1,0,4,2,4,57003) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',2,1,4,2,5,57003) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',3,1,2,2,6,57003) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',4,1,2,2,7,57003) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',5,1,3,2,8,57003) 
end

GO

--工序质检编号自定义
if not exists(select id from zdybh where sort1=57004)
begin
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('GXZJ_',1,1,4,2,1,57004)
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号2',1,0,4,2,2,57004) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号3',1,0,4,2,3,57004) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号4',1,0,4,2,4,57004) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',2,1,4,2,5,57004) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',3,1,2,2,6,57004) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',4,1,2,2,7,57004) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',5,1,3,2,8,57004) 
END

GO

if not exists(select 1 from hr_PersonTaxSort  where del=0 and isnull(IsEnabled,0)=1)
begin
		insert into hr_PersonTaxSort(title, startTime, endTime, inDate, creator,del,taxbase,IsEnabled)
		values('2019年税率表','2019-01-01 00:00:00.000','2019-12-31 00:00:00.000',getdate(),63,0,5000,1)
end

GO
if not exists(select 1 from hr_PersonTax  where del=0 and isnull(IsEnabled,0)=1)
begin
		insert into hr_PersonTax(creator, inDate, lv, limit, lower,taxRate,cut,del,sortid,IsEnabled)
        select top 1 63,getdate(),1,36000,0,3,0,0, id,1 from hr_PersonTaxSort where isnull(IsEnabled,0)=1

        insert into hr_PersonTax(creator, inDate, lv, limit, lower,taxRate,cut,del,sortid,IsEnabled)
        select top 1 63,getdate(),2,144000,36000,10,2520,0, id,1 from hr_PersonTaxSort where isnull(IsEnabled,0)=1

        insert into hr_PersonTax(creator, inDate, lv, limit, lower,taxRate,cut,del,sortid,IsEnabled)
        select top 1 63,getdate(),3,300000,144000,20,16920,0,id,1 from hr_PersonTaxSort where isnull(IsEnabled,0)=1

        insert into hr_PersonTax(creator, inDate, lv, limit, lower,taxRate,cut,del,sortid,IsEnabled)
        select top 1 63,getdate(),4,420000,300000,25,31920,0,id,1 from hr_PersonTaxSort where isnull(IsEnabled,0)=1

        insert into hr_PersonTax(creator, inDate, lv, limit, lower,taxRate,cut,del,sortid,IsEnabled)
        select top 1 63,getdate(),5,660000,420000,30,52920,0,id,1 from hr_PersonTaxSort where isnull(IsEnabled,0)=1

        insert into hr_PersonTax(creator, inDate, lv, limit, lower,taxRate,cut,del,sortid,IsEnabled)
        select top 1 63,getdate(),6,960000,660000,35,85920,0,id,1 from hr_PersonTaxSort where isnull(IsEnabled,0)=1
        
        insert into hr_PersonTax(creator, inDate, lv, limit, lower,taxRate,cut,del,sortid,IsEnabled)
        select top 1 63,getdate(),7,0,960000,45,181920,0,id,1 from hr_PersonTaxSort where isnull(IsEnabled,0)=1
end

GO

if not exists(select top 1 1 from home_usconfig where name = 'hrm_sortwages')
begin
    update sortwages set deductible=1 where intro=-1
	insert into home_usConfig(name,nvalue,tvalue,uid) values('hrm_sortwages',null,1,0)
end

GO

--修复客户关怀中的关怀方式与关怀类型存反的问题
if exists(select top 1 1
	from sale_care a
	inner join sortonehy b on b.gate2 = 58 and a.sortid = b.ord
	inner join sortonehy c on c.gate2 = 59 and a.modeid = c.ord
	where a.del = 0)
begin
    update x set x.sortid = y.sortid,x.modeid = y.modeid
    from sale_care x
    inner join (
	    select a.id,a.sortid as modeid,a.modeid as sortid
	    from sale_care a
	    inner join sortonehy b on b.gate2 = 58 and a.sortid = b.ord
	    inner join sortonehy c on c.gate2 = 59 and a.modeid = c.ord
	    where a.del = 0
    ) y on x.id = y.id
end

GO

--委外返工编号自定义
if not exists(select id from zdybh where sort1=58001)
begin
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('WWFG_',1,1,4,2,1,58001)
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号2',1,0,4,2,2,58001) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号3',1,0,4,2,3,58001) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号4',1,0,4,2,4,58001) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',2,1,4,2,5,58001) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',3,1,2,2,6,58001) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',4,1,2,2,7,58001) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',5,1,3,2,8,58001) 
end

--收货编号自定义
if not exists(select id from zdybh where sort1=58002)
begin
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('SH_',1,1,4,2,1,58002)
    insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号2',1,0,4,2,2,58002) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号3',1,0,4,2,3,58002) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号4',1,0,4,2,4,58002) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',2,1,4,2,5,58002) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',3,1,2,2,6,58002) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',4,1,2,2,7,58002) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',5,1,3,2,8,58002) 
end

GO

--工资设置
if not exists(select 1 from setopen  where sort1=20190308)
begin
    insert into setopen(intro,sort1)values(1,20190308)
end

GO

--委外送检编号自定义
if not exists(select id from zdybh where sort1=58003)
begin
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('SJ_',1,1,4,2,1,58003)
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号2',1,0,4,2,2,58003) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号3',1,0,4,2,3,58003) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号4',1,0,4,2,4,58003) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',2,1,4,2,5,58003) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',3,1,2,2,6,58003) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',4,1,2,2,7,58003) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',5,1,3,2,8,58003) 
end

GO

IF EXISTS(SELECT TOP 1 1 FROM payoutInvoice WHERE taxValue IS NULL )
BEGIN
	update pl SET pl.taxRate = (CASE p.isInvoiced WHEN 0 THEN c.taxRate ELSE ISNULL(p.taxRate,c.taxRate) END) , 
		pl.taxValue = (CASE p.isInvoiced WHEN 0 THEN (c.money1/(1+(c.taxRate/100.0))*(c.taxRate/100.0)) 
			ELSE (c.money1/(1+(ISNULL(p.taxRate,c.taxRate)/100.0))*(ISNULL(p.taxRate,c.taxRate)/100.0)) END) 
	FROM payoutInvoice_list pl 
	INNER JOIN payoutInvoice p ON pl.payoutInvoice=p.id AND pl.taxValue IS NULL AND p.fromType IN('CAIGOU','ZDWW','GXWW') 
	INNER JOIN (
		SELECT 'CAIGOU' fromType, id,num1,money1,taxRate FROM caigoulist WHERE invoiceType>0
		UNION ALL 
		SELECT (case o.wwType when 0 then 'ZDWW' else 'GXWW' end) fromType,ol.id,ol.num1,ol.moneyAfterTax money1,ol.taxRate 
		FROM M2_OutOrderlists ol 
		INNER JOIN M2_OutOrder o ON ol.outID=o.ID AND ol.invoiceType>0
	) c ON c.fromType=p.fromType AND pl.caigoulist=c.id
	
	update a set a.taxRate=ISNULL(a.taxRate,b.taxRate),a.taxValue=b.taxValue from payoutInvoice a 
	INNER join (
		SELECT payoutinvoice,max(taxRate) taxRate,sum(taxValue) taxValue from payoutInvoice_list group by payoutinvoice
	) b on b.payoutInvoice=a.id AND a.taxValue IS NULL AND a.fromType IN('CAIGOU','ZDWW','GXWW')
	
	update payoutinvoice set taxValue=ISNULL((money1/(1+(taxRate/100.0))*(taxRate/100.0)),0)  WHERE fromType NOT IN('CAIGOU','ZDWW','GXWW') AND taxValue IS NULL
END

GO

update contract_out set sort=44009   where sort=18 or sort=41001 
update contract_out set PrintID = 44009   where sort=44009 and ISNULL(PrintID,0)<>0

GO

--整单委外策略默认值
if not exists(select 1 from home_usConfig where name='ZDWWInvoicePlayType')
begin
   insert dbo.home_usConfig(tvalue,name,uid) values ('1,2,3', 'ZDWWInvoicePlayType',0)
end
if not exists(select 1 from home_usConfig where name='ZDWWPayPlayType')
begin
   insert dbo.home_usConfig(tvalue,name,uid) values ('1,2,3', 'ZDWWPayPlayType',0)
end
if not exists(select 1 from home_usConfig where name='ZDWWPayPlayQT')
begin
   insert dbo.home_usConfig(nvalue,name,uid) values ('1', 'ZDWWPayPlayQT',0)
end
if not exists(select 1 from home_usConfig where name='ZDWWInvoicePlayQT')
begin
   insert dbo.home_usConfig(nvalue,name,uid) values ('1', 'ZDWWInvoicePlayQT',0)
end
if not exists(select 1 from home_usConfig where name='ZDWWReceivingType')
begin
   insert dbo.home_usConfig(nvalue,name,uid) values ('0', 'ZDWWReceivingType',0)
end
if not exists(select 1 from home_usConfig where name='ZDWWOutsourcingInspection')
begin
   insert dbo.home_usConfig(nvalue,name,uid) values ('0', 'ZDWWOutsourcingInspection',0)
end

GO
--处理委外历史数据（89迭代之前）
if not exists(SELECT 1 FROM dbo.home_usConfig WHERE name='OldDataOutOrder' and nvalue=1)
begin
   --处理委外质检老数据
   update   M2_QualityTestingLists  set TaskMXId=0, NumSPOK=SerialNumber-(NumScrap+NumBF), OkNum=SerialNumber-(NumScrap+NumBF),  FailNum=(NumScrap+NumBF)   where TaskMXId is null
   update   M2_QualityTestings set  TaskId = 0 where TaskId is null
   update dbo.M2_OutOrder set InspectionStatus=1 where InspectionStatus is null
   update dbo.M2_OutOrder set ReceivingStatus=1 where ReceivingStatus is null
   exec dbo.erp_updateSJStatusForOutItemIds @OutItemIds='-999'--更新委外送检数量及送检状态
   exec dbo.erp_updateReceivingNumForOutItemIds @OutItemIds='-999'--更新委外收货数量及收货状态
   exec dbo.erp_updateReworkNumForOutItemId @OutItemIds='-999'--更新委外返工数量及收货状态
   insert into dbo.home_usConfig(name,nvalue,tvalue,uid)values('OldDataOutOrder',1,'',0)
end
GO

--更新为空的工序汇报序列号ID
UPDATE m2pp SET m2pp.oriSeralNumber = ISNULL(snl.ID,0) FROM dbo.M2_ProcedureProgres m2pp
LEFT JOIN dbo.M2_SerialNumberList snl ON m2pp.codeProduct = snl.SeriNum AND snl.del = 1 AND BussinessType = 54002
WHERE m2pp.del = 1 AND LEN(ISNULL(m2pp.codeProduct,'')) > 0 AND ISNULL(m2pp.oriSeralNumber,0) = 0
--更新为空的工序质检序列号ID
UPDATE qtr SET qtr.oriSeralNumber = ISNULL(snl.ID,0) FROM dbo.M2_GXQualityTestingResult qtr
LEFT JOIN dbo.M2_SerialNumberList snl ON qtr.xlh = snl.SeriNum AND snl.del = 1 AND BussinessType = 54002
WHERE LEN(ISNULL(qtr.xlh,'')) > 0 AND ISNULL(qtr.oriSeralNumber,0) = 0

GO

if not exists(select 1 from home_usConfig where name='SerialNumberDefaiultRule')
begin
    update setjm3 set num1=0 where ord=5434

    select sort , set_open , intro1, row_number() over(order by gate1) px into #zdybhYM from zdybh where sort1=2101 and sort in (2,3,4)

    insert into S2_SerialNumberRule(Title,SortType,SortID,IsMain,IsTemplete, YearType,YearInx,YearOpen, MonthInx,MonthOpen, DayInx,DayOpen, Creator,InDate ,Del) 
    select   '默认规则',0,0,1,0, sum(YearType),sum(YearInx),sum(YearOpen),sum(MonthInx),sum(MonthOpen),sum(DayInx),sum(DayOpen) ,0 , getdate(), 1 Del
    from (
        select intro1 YearType ,px YearInx ,set_open YearOpen, 0 MonthInx,0 MonthOpen, 0 DayInx,0 DayOpen from #zdybhYM where sort=2
        union all
        select 0,0,0,px,set_open, 0,0 from #zdybhYM where sort=3
        union all 
        select 0,0,0, 0,0, px,set_open from #zdybhYM where sort=4
    ) a

    drop table #zdybhYM

    declare @maxID int
    select @maxID = max(id) from  S2_SerialNumberRule

    insert into S2_SerialNumberRuleList(RuleID , PartType ,SType, NValue, UNumber, UType ,BType,BValue,SortInx ,Del)
    select @maxID RuleID , PartType , SType ,NValue ,UNumber , 0 UType, 0 BType,'' BValue , row_number() over(order by gate1) SortInx , 1 Del
    from (
        select 1 PartType , 0 SType ,title NValue ,0 UNumber  , gate1
        from zdybh where sort1=2101 and sort=1  and set_open=1
        union all
        select 3 PartType, 1 SType ,'' NValue,1 UNumber ,min(gate1) as gate1
        from zdybh where sort1=2101 and sort in (2,3,4) and set_open=1
        union all
        select 2 PartType, 0 SType ,'1' NValue,3 UNumber,gate1
        from zdybh 
        where sort1=2101 and sort=5 and set_open=1
    ) a

    --序列号原数据关系维护
    insert into S2_SerialNumberRelation(SerialID , BillType , BillID, BillListType , ListID,Del)
    SELECT ID ,BussinessType ,ToMake, 0 , 0 ,del
    from M2_SerialNumberList 
    where isnull(BussinessType,0)>0

    insert into dbo.home_usConfig(nvalue,name,uid) values ('0', 'SerialNumberDefaiultRule',0)
end
 
GO

if not exists(select 1 from home_usConfig where name='odzdytonewzdy')
begin
    exec [dbo].[UpdateKuoutZdy] ''   
    insert into dbo.home_usConfig(nvalue,name,uid) values ('0', 'odzdytonewzdy',0)
end

GO

--处理财务对接老数据没有年份的问题
update x 
	set x.accountYear = year(x.date1) -( case when month(x.date1)>=isnull(y.AccountMonth1,1) then  0 else  1 end)
from collocation x 
inner join AccountSys  y on x.account=y.ord
where x.accountYear is null

GO

update product set roles=dbo.CNumberList((case when charindex('1',roles)>0 then '1,' else '' end) +(case when charindex('2',roles)>0 then '2,' else '' end)+(case when charindex('3',roles)>0 then '3,' else '' end)) where charindex(',',roles)=0

GO
UPDATE action_list SET type_login=2 WHERE action1 = '采购产品清单' AND page1 LIKE '%/SYSA/caigou/priceModify.asp%' AND  type_login=1

	--二维码分类表添加入库明细自定义分类
	IF  not exists(select 1 from C2_CodeTypes where title='入库明细自定义' AND fromSys =2)
	BEGIN
		INSERT INTO C2_CodeTypes(title,gate1,fromSys,entype,addcate,addtime,del,isAuto,stop) SELECT '入库明细自定义',2,2,0,63,GETDATE(),1,1,0
	END

	--处理老数据排序
	IF not exists(select 1 from home_usConfig where name='C2_CodeTypeFieldsOrder')
	BEGIN 
		UPDATE C2_CodeTypeFields SET C2_CodeTypeFields.gate1 = t.inx FROM (SELECT  ROW_NUMBER()over(order by ctf.gate1 desc) as inx,ctf.id FROM C2_CodeTypeFields ctf LEFT JOIN C2_CodeTypes ct ON ctf.cTypeId=ct.id 
		WHERE ct.title='产品自定义' ) t WHERE  C2_CodeTypeFields.id=t.id 

		UPDATE C2_CodeTypeFields SET C2_CodeTypeFields.gate1 = t.inx FROM (SELECT  ROW_NUMBER()over(order by ctf.gate1 desc) as inx,ctf.id FROM C2_CodeTypeFields ctf LEFT JOIN C2_CodeTypes ct ON ctf.cTypeId=ct.id 
		WHERE ct.title='员工档案自定义' ) t WHERE  C2_CodeTypeFields.id=t.id 

		UPDATE C2_CodeTypeFields SET C2_CodeTypeFields.gate1 = t.inx FROM (SELECT  ROW_NUMBER()over(order by ctf.gate1 desc) as inx,ctf.id FROM C2_CodeTypeFields ctf LEFT JOIN C2_CodeTypes ct ON ctf.cTypeId=ct.id 
		WHERE ct.title='通讯录自定义' ) t WHERE  C2_CodeTypeFields.id=t.id 

		UPDATE C2_CodeTypeFields SET C2_CodeTypeFields.gate1 = t.inx FROM (SELECT  ROW_NUMBER()over(order by ctf.gate1 desc) as inx,ctf.id FROM C2_CodeTypeFields ctf LEFT JOIN C2_CodeTypes ct ON ctf.cTypeId=ct.id 
		WHERE ct.title='商品自定义' ) t WHERE  C2_CodeTypeFields.id=t.id 

		UPDATE C2_CodeTypeFields SET C2_CodeTypeFields.gate1 = t.inx FROM (SELECT  ROW_NUMBER()over(order by ctf.gate1 desc) as inx,ctf.id FROM C2_CodeTypeFields ctf LEFT JOIN C2_CodeTypes ct ON ctf.cTypeId=ct.id 
		WHERE ct.title='入库明细自定义' ) t WHERE  C2_CodeTypeFields.id=t.id 
		--流水号排第一位
		UPDATE ctf SET ctf.gate1 =0 FROM C2_CodeTypeFields ctf LEFT JOIN C2_CodeTypes ct ON ctf.cTypeId=ct.id WHERE ctf.oldName='流水号' and  ct.fromSys=2
		UPDATE ctf SET ctf.gate1 =0 FROM C2_CodeTypeFields ctf LEFT JOIN C2_CodeTypes ct ON ctf.cTypeId=ct.id WHERE ctf.oldName='商品号' and  ct.fromSys=2 and ct.title ='商品自定义'
		--更新生成二维码的排序
		UPDATE cif SET cif.gate1 =ctf.gate1 FROM  C2_CodeItemsFields cif LEFT JOIN C2_CodeTypeFields ctf ON cif.ftypeID=ctf.id

		INSERT into dbo.home_usConfig(nvalue,name,uid) values ('0', 'C2_CodeTypeFieldsOrder',0)
	END 

	--删除不显示的二维码分类字段表的字段
    IF not exists (select 1 from home_usConfig where name='deleteOldCodeTypeFields')
    BEGIN
    	DELETE C2_CodeTypeFields FROM C2_CodeTypeFields ctf LEFT JOIN C2_CodeTypes ct ON ctf.cTypeid = ct.id WHERE ct.fromSys=2 AND ctf.stop=1 
        INSERT into dbo.home_usConfig(nvalue,name,uid) values ('0', 'deleteOldCodeTypeFields',0)
    END

	--新客户第一次用功能的情况下，展示所有字段
		IF not exists (select 1 from C2_CodeTypeFields ctf LEFT JOIN C2_CodeTypes ct ON ctf.cTypeId=ct.id WHERE ct.fromSys=2 and ct.title!='入库明细自定义')
		BEGIN
            IF not exists (SELECT 1 FROM dbo.C2_CodeTypes WHERE fromSys=2 and title!='入库明细自定义')
		    BEGIN
               INSERT INTO C2_CodeTypes(title,gate1,stop,fromsys,entype,addcate,addtime,isAuto)
               SELECT '产品自定义',1,0,2,0,63, GETDATE(),1 
               UNION ALL SELECT '员工档案自定义',3,0,2,0,63, GETDATE(),1
               UNION ALL SELECT '通讯录自定义',6,0,2,0,63, GETDATE(),1
               UNION ALL SELECT '商品自定义',7,0,2,0,63, GETDATE(),1
            END  
            
			INSERT INTO C2_CodeTypeFields(cTypeId,uName,uType,gate1,fieldName,oldName) 
                SELECT  id,'流水号',0,0,'ord','流水号' FROM C2_CodeTypes  WHERE title ='产品自定义' AND fromSys =2
                UNION ALL SELECT id,'产品名称',0,2,'title','产品名称' FROM C2_CodeTypes  WHERE title ='产品自定义' AND fromSys =2
                UNION ALL SELECT id,'产品编码',0,4,'order1','产品编码' FROM C2_CodeTypes  WHERE title ='产品自定义' AND fromSys =2
                UNION ALL SELECT id,'产品型号',0,5,'type1','产品型号' FROM C2_CodeTypes  WHERE title ='产品自定义' AND fromSys =2
                UNION ALL SELECT id,'产品分类',0,6,'sort1','产品分类' FROM C2_CodeTypes  WHERE title ='产品自定义' AND fromSys =2
                UNION ALL SELECT id,'基本单位',0,13,'unitjb','基本单位' FROM C2_CodeTypes  WHERE title ='产品自定义' AND fromSys =2
                   
                UNION ALL SELECT id,'流水号',0,0,'id','流水号' FROM C2_CodeTypes  WHERE title ='员工档案自定义' AND fromSys =2
                UNION ALL SELECT id,'姓名',0,1,'userName','姓名' FROM C2_CodeTypes  WHERE title ='员工档案自定义' AND fromSys =2
                UNION ALL SELECT id,'单位',0,2,'comName','单位' FROM C2_CodeTypes  WHERE title ='员工档案自定义' AND fromSys =2
                UNION ALL SELECT id,'职位',0,3,'PostionID','职位' FROM C2_CodeTypes  WHERE title ='员工档案自定义' AND fromSys =2
                UNION ALL SELECT id,'员工编号',0,4,'userbh','员工编号' FROM C2_CodeTypes  WHERE title ='员工档案自定义' AND fromSys =2
                UNION ALL SELECT id,'办公电话',0,5,'telOffice','办公电话' FROM C2_CodeTypes  WHERE title ='员工档案自定义' AND fromSys =2
                UNION ALL SELECT id,'手机1',0,6,'mobile','手机1' FROM C2_CodeTypes  WHERE title ='员工档案自定义' AND fromSys =2
                UNION ALL SELECT id,'传真',0,7,'fax','传真' FROM C2_CodeTypes  WHERE title ='员工档案自定义' AND fromSys =2
                UNION ALL SELECT id,'电子邮箱',0,8,'email','电子邮箱' FROM C2_CodeTypes  WHERE title ='员工档案自定义' AND fromSys =2
                UNION ALL SELECT id,'公司地址',0,9,'comAddr','公司地址' FROM C2_CodeTypes  WHERE title ='员工档案自定义' AND fromSys =2

				UNION ALL SELECT id,'流水号',0,0,'ord','流水号' FROM C2_CodeTypes  WHERE title ='通讯录自定义' AND fromSys =2
				UNION ALL SELECT id,'姓名',0,1,'name','姓名' FROM C2_CodeTypes  WHERE title ='通讯录自定义' AND fromSys =2
				UNION ALL SELECT id,'办公电话',0,2,'phone1','办公电话' FROM C2_CodeTypes  WHERE title ='通讯录自定义' AND fromSys =2
				UNION ALL SELECT id,'手机',0,3,'mobile','手机' FROM C2_CodeTypes  WHERE title ='通讯录自定义' AND fromSys =2
				UNION ALL SELECT id,'电子邮件',0,4,'email','电子邮件' FROM C2_CodeTypes  WHERE title ='通讯录自定义' AND fromSys =2
				UNION ALL SELECT id,'职位名称',0,5,'title','职位名称' FROM C2_CodeTypes  WHERE title ='通讯录自定义' AND fromSys =2
				UNION ALL SELECT id,'公司名称',0,6,'comName','公司名称' FROM C2_CodeTypes  WHERE title ='通讯录自定义' AND fromSys =2
				UNION ALL SELECT id,'公司地址',0,7,'comAddr','公司地址' FROM C2_CodeTypes  WHERE title ='通讯录自定义' AND fromSys =2
				UNION ALL SELECT id,'网址',0,8,'comUrl','网址' FROM C2_CodeTypes  WHERE title ='通讯录自定义' AND fromSys =2
		
				UNION ALL SELECT id,'商品号',0,0,'id','商品号' FROM C2_CodeTypes  WHERE title ='商品自定义' AND fromSys =2
				UNION ALL SELECT id,'商品名称',0,1,'name','商品名称' FROM C2_CodeTypes  WHERE title ='商品自定义' AND fromSys =2
				UNION ALL SELECT id,'商品编号',0,2,'bh','商品编号' FROM C2_CodeTypes  WHERE title ='商品自定义' AND fromSys =2
				UNION ALL SELECT id,'商品分类',0,3,'sortonehy','商品分类' FROM C2_CodeTypes  WHERE title ='商品自定义' AND fromSys =2
				UNION ALL SELECT id,'商品单位',0,4,'unit','商品单位' FROM C2_CodeTypes  WHERE title ='商品自定义' AND fromSys =2
				UNION ALL SELECT id,'商品属性',0,5,'attr','商品属性' FROM C2_CodeTypes  WHERE title ='商品自定义' AND fromSys =2
				UNION ALL SELECT id,'商品价格',5,6,'price1','商品价格' FROM C2_CodeTypes  WHERE title ='商品自定义' AND fromSys =2

		END


	IF not exists(select 1 from home_usConfig where name='AddCodeTypeFieldsKuinList')
	BEGIN
		INSERT INTO C2_CodeTypeFields(cTypeId,uName,uType,gate1,fieldName,oldName) 
		SELECT id,'流水号',0,0,'id','流水号' FROM C2_CodeTypes  WHERE title ='入库明细自定义' AND fromSys =2
		UNION ALL SELECT id,'产品名称',0,10,'title','产品名称' FROM C2_CodeTypes  WHERE title ='入库明细自定义' AND fromSys =2
		UNION ALL SELECT id,'产品编号',0,20,'order1','产品编号' FROM C2_CodeTypes  WHERE title ='入库明细自定义' AND fromSys =2
		UNION ALL SELECT id,'产品型号',0,30,'type1','产品型号' FROM C2_CodeTypes  WHERE title ='入库明细自定义' AND fromSys =2
		UNION ALL SELECT id,'单位',0,40,'unit','单位' FROM C2_CodeTypes  WHERE title ='入库明细自定义' AND fromSys =2
		UNION ALL SELECT id,'数量',5,70,'num1','数量' FROM C2_CodeTypes  WHERE title ='入库明细自定义' AND fromSys =2
		UNION ALL SELECT id,'批号',0,90,'ph','批号' FROM C2_CodeTypes  WHERE title ='入库明细自定义' AND fromSys =2
		UNION ALL SELECT id,'序列号',0,100,'xlh','序列号' FROM C2_CodeTypes  WHERE title ='入库明细自定义' AND fromSys =2
		UNION ALL SELECT id,'生产日期',7,110,'datesc','生产日期' FROM C2_CodeTypes  WHERE title ='入库明细自定义' AND fromSys =2
		UNION ALL SELECT id,'有效日期',7,120,'dateyx','有效日期' FROM C2_CodeTypes  WHERE title ='入库明细自定义' AND fromSys =2
		UNION ALL SELECT id,'仓库',0,130,'ku','仓库' FROM C2_CodeTypes  WHERE title ='入库明细自定义' AND fromSys =2
		UNION ALL SELECT id,'包装',0,150,'bz','包装' FROM C2_CodeTypes  WHERE title ='入库明细自定义' AND fromSys =2
		UNION ALL SELECT id,'件数',5,160,'js','件数' FROM C2_CodeTypes  WHERE title ='入库明细自定义' AND fromSys =2

		INSERT into dbo.home_usConfig(nvalue,name,uid) values ('0', 'AddCodeTypeFieldsKuinList',0)
	END

GO
--二维码识别规则预设模板
if not exists(select 1 from home_usConfig where name='RecognitionRuleTemplate')
    begin
        declare @ord int
        INSERT INTO C2_RecognitionRule(title,billtype,KeyInterval,KeyValueInterval,Creator,indate,del) VALUES
        ('简易通用模板','61001','semicolon','colon',63,GETDATE(),1)
        SELECT @ord = SCOPE_IDENTITY()
        
        INSERT INTO C2_RecognitionRuleList(RRID,DBName,QRKeyName,IsRuleKey,IsSearchKey,Rowindex,Del)
        SELECT @ord RRID,'title' DBName,'产品名称' QRKeyName,1 IsRuleKey,1 IsSearchKey,1 Rowindex,1 Del
        UNION ALL
        SELECT @ord,'order1','编号',0,0,2,1
        UNION ALL
        SELECT @ord,'type1','规格型号',1,1,3,1
        UNION ALL
        SELECT @ord,'unit','基本单位',1,1,4,1      
        
        INSERT INTO C2_RecognitionRule(title,billtype,KeyInterval,KeyValueInterval,Creator,indate,del) VALUES
        ('简易通用模板','62001','semicolon','colon',63,GETDATE(),1)
        SELECT @ord = SCOPE_IDENTITY()
        
        INSERT INTO C2_RecognitionRuleList(RRID,DBName,QRKeyName,IsRuleKey,IsSearchKey,Rowindex,Del)
        SELECT @ord RRID,'title' DBName,'产品名称' QRKeyName,1 IsRuleKey,1 IsSearchKey,1 Rowindex,1 Del
        UNION ALL
        SELECT @ord,'order1','编号',0,0,2,1
        UNION ALL
        SELECT @ord,'type1','规格型号',1,1,3,1
        UNION ALL
        SELECT @ord,'unit','基本单位',1,1,4,1
        
        INSERT INTO C2_RecognitionRule(title,billtype,KeyInterval,KeyValueInterval,Creator,indate,del) VALUES
        ('料号','61001','none','none',63,GETDATE(),1)
        SELECT @ord = SCOPE_IDENTITY()
        
        INSERT INTO C2_RecognitionRuleList(RRID,DBName,QRKeyName,IsRuleKey,IsSearchKey,Rowindex,Del)VALUES
        (@ord,'order1','料号',1,1,1,1)
        
        INSERT INTO C2_RecognitionRule(title,billtype,KeyInterval,KeyValueInterval,Creator,indate,del) VALUES
        ('料号','62001','none','none',63,GETDATE(),1)
        SELECT @ord = SCOPE_IDENTITY()
        
        INSERT INTO C2_RecognitionRuleList(RRID,DBName,QRKeyName,IsRuleKey,IsSearchKey,Rowindex,Del)VALUES
        (@ord,'order1','料号',1,1,1,1)
        
        
        INSERT INTO C2_RecognitionRule(title,billtype,KeyInterval,KeyValueInterval,Creator,indate,del) VALUES
        ('料号与SN','61001','semicolon','colon',63,GETDATE(),1)
        SELECT @ord = SCOPE_IDENTITY()
        
        INSERT INTO C2_RecognitionRuleList(RRID,DBName,QRKeyName,IsRuleKey,IsSearchKey,Rowindex,Del)
        SELECT @ord RRID,'order1' DBName,'料号' QRKeyName,1 IsRuleKey,1 IsSearchKey,1 Rowindex,1 Del
        UNION ALL
        SELECT @ord,'zdymx_xlh','SN',1,1,2,1
        
        INSERT INTO C2_RecognitionRule(title,billtype,KeyInterval,KeyValueInterval,Creator,indate,del) VALUES
        ('料号与SN','62001','semicolon','colon',63,GETDATE(),1)
        SELECT @ord = SCOPE_IDENTITY()
        
        INSERT INTO C2_RecognitionRuleList(RRID,DBName,QRKeyName,IsRuleKey,IsSearchKey,Rowindex,Del)
        SELECT @ord RRID,'order1' DBName,'料号' QRKeyName,1 IsRuleKey,1 IsSearchKey,1 Rowindex,1 Del
        UNION ALL
        SELECT @ord,'InheritId_self_xlh','SN',1,1,2,1     
        
        INSERT INTO C2_RecognitionRule(title,billtype,KeyInterval,KeyValueInterval,Creator,indate,del) VALUES
        ('医疗器械行业——GS1（物料长条码）','61001','none','none',63,GETDATE(),1)
        SELECT @ord = SCOPE_IDENTITY()
        
        INSERT INTO C2_RecognitionRuleList(RRID,DBName,QRKeyName,IsRuleKey,IsSearchKey,Rowindex,Del,FixedLength)
        SELECT @ord RRID,'txm' DBName,'01' QRKeyName,1 IsRuleKey,1 IsSearchKey,1 Rowindex,1 Del, 14 FixedLength
        UNION ALL
        SELECT @ord,'zdymx_yxdate','17',0,0,2,1,6 
        UNION ALL
        SELECT @ord,'zdymx_scdate','11',0,0,3,1,6        
        
        INSERT INTO C2_RecognitionRule(title,billtype,KeyInterval,KeyValueInterval,Creator,indate,del) VALUES
        ('医疗器械行业——GS1（批号长条码）','61001','none','none',63,GETDATE(),1)
        SELECT @ord = SCOPE_IDENTITY()
        
        INSERT INTO C2_RecognitionRuleList(RRID,DBName,QRKeyName,IsRuleKey,IsSearchKey,Rowindex,Del,FixedLength)
        SELECT @ord RRID,'txm' DBName,'01' QRKeyName,1 IsRuleKey,1 IsSearchKey,1 Rowindex,1 Del, 14 FixedLength
        UNION ALL
        SELECT @ord,'zdymx_yxdate','17',0,0,2,1,6
        UNION ALL
        SELECT @ord,'zdymx_scdate','11',0,0,3,1,6  
        UNION ALL
        SELECT @ord,'zdymx_ph','10',1,0,4,1,null

        INSERT INTO C2_RecognitionRule(title,billtype,KeyInterval,KeyValueInterval,Creator,indate,del) VALUES
        ('医疗器械行业——GS1（批号长条码）','62001','none','none',63,GETDATE(),1)
        SELECT @ord = SCOPE_IDENTITY()
        
        INSERT INTO C2_RecognitionRuleList(RRID,DBName,QRKeyName,IsRuleKey,IsSearchKey,Rowindex,Del,FixedLength)
        SELECT @ord RRID,'txm' DBName,'01' QRKeyName,1 IsRuleKey,1 IsSearchKey,1 Rowindex,1 Del, 14 FixedLength
        UNION ALL
        SELECT @ord,'dateyx','17',0,0,2,1,6
        UNION ALL
        SELECT @ord,'datesc','11',0,0,3,1,6 
        UNION ALL
        SELECT @ord,'InheritId_self_ph','10',1,1,4,1,null
        
        INSERT INTO C2_RecognitionRule(title,billtype,KeyInterval,KeyValueInterval,Creator,indate,del) VALUES
        ('医疗器械行业——GS1（序列号长条码）','61001','none','none',63,GETDATE(),1)
        SELECT @ord = SCOPE_IDENTITY()
        
        INSERT INTO C2_RecognitionRuleList(RRID,DBName,QRKeyName,IsRuleKey,IsSearchKey,Rowindex,Del,FixedLength)
        SELECT @ord RRID,'txm' DBName,'01' QRKeyName,1 IsRuleKey,1 IsSearchKey,1 Rowindex,1 Del, 14 FixedLength
        UNION ALL
        SELECT @ord,'zdymx_yxdate','17',0,0,2,1,6
        UNION ALL
        SELECT @ord,'zdymx_scdate','11',0,0,3,1,6
        UNION ALL
        SELECT @ord,'zdymx_xlh','21',1,0,4,1,null

        INSERT INTO C2_RecognitionRule(title,billtype,KeyInterval,KeyValueInterval,Creator,indate,del) VALUES
        ('医疗器械行业——GS1（序列号长条码）','62001','none','none',63,GETDATE(),1)
        SELECT @ord = SCOPE_IDENTITY()
        
        INSERT INTO C2_RecognitionRuleList(RRID,DBName,QRKeyName,IsRuleKey,IsSearchKey,Rowindex,Del,FixedLength)
        SELECT @ord RRID,'txm' DBName,'01' QRKeyName,1 IsRuleKey,1 IsSearchKey,1 Rowindex,1 Del, 14 FixedLength
        UNION ALL
        SELECT @ord,'dateyx','17',0,0,2,1,6
        UNION ALL
        SELECT @ord,'datesc','11',0,0,3,1,6
        UNION ALL
        SELECT @ord,'InheritId_self_xlh','21',1,1,4,1,null 
        
        INSERT INTO C2_RecognitionRule(title,billtype,KeyInterval,KeyValueInterval,Creator,indate,del) VALUES
        ('医疗器械行业——GS1（物料主条形码）','61001','none','none',63,GETDATE(),1)
        SELECT @ord = SCOPE_IDENTITY()
        
        INSERT INTO C2_RecognitionRuleList(RRID,DBName,QRKeyName,IsRuleKey,IsSearchKey,Rowindex,Del,FixedLength)VALUES
        (@ord,'txm','01',1,1,1,1,14)
        
        INSERT INTO C2_RecognitionRule(title,billtype,KeyInterval,KeyValueInterval,Creator,indate,del) VALUES
        ('医疗器械行业——GS1（物料主条形码）','62001','none','none',63,GETDATE(),1)
        SELECT @ord = SCOPE_IDENTITY()
        
        INSERT INTO C2_RecognitionRuleList(RRID,DBName,QRKeyName,IsRuleKey,IsSearchKey,Rowindex,Del,FixedLength)VALUES
        (@ord,'txm','01',1,1,1,1,14)
        
        
        INSERT INTO C2_RecognitionRule(title,billtype,KeyInterval,KeyValueInterval,Creator,indate,del) VALUES
        ('医疗器械行业——HIBC（物料主条形码）','61001','none','none',63,GETDATE(),1)
        SELECT @ord = SCOPE_IDENTITY()
        
        INSERT INTO C2_RecognitionRuleList(RRID,DBName,QRKeyName,IsRuleKey,IsSearchKey,Rowindex,Del)VALUES
        (@ord,'order1','+H',1,1,1,1)

		INSERT into dbo.home_usConfig(nvalue,name,uid) values ('0', 'RecognitionRuleTemplate',0)
        
    end

GO
--二维码识别规则预设模板定长为0的改为null
if not exists(select 1 from home_usConfig where name='RecognitionRuleTemplateFixedLengthNull')
    begin
        UPDATE C2_RecognitionRuleList SET FixedLength=null WHERE FixedLength=0
        INSERT into dbo.home_usConfig(nvalue,name,uid) values ('0', 'RecognitionRuleTemplateFixedLengthNull',0)
    end


GO

--序列号关系转移
if not exists(select 1 from home_usConfig where name='S2_SerialNumberRelation')
begin
    exec [erp_store_KuXlhConvertToRelation] 0
    INSERT into dbo.home_usConfig(nvalue,name,uid) values ('0', 'S2_SerialNumberRelation',0)
end 

GO
--物料分析策略数据处理91迭代
--判断第一次执行
if not exists(SELECT 1 FROM dbo.home_usConfig WHERE name='OldDataOrAnalysisSet' and nvalue=1)
begin
    --老数据处理
	update dbo.M2_CelueSet_Analysis 
	set IsParentException=1,--父件例外策略
	EnableStockModel=2,--可用库存
	JoinMuilsUnit=1,--是否考虑其它单位库存
	ReplaceModel=0, --是否考虑替代物料
    cks=(case when CHARINDEX(',0,',','+ISNULL(cks,'')+',')>0 then '0' else cks end)

    update dbo.M2_MaterialAnalysis 
    set IsParentException=1,
    EnableStockModel=2,
    JoinMuilsUnit=1,
    ReplaceModel=0
    
	insert into dbo.M2_CelueSet_Analysis
	(title,Gate1,IsParentException,Wastage,EnableStockModel,JoinMuilsUnit,SafeStock,ReplaceModel,cks,intro,isStop,creator,inDate,del)
	values('简易策略',30,1,0,0,0,0,0,'','',0,0,GETDATE(),1)
	--要求：全部仓库，后期新增查看范围内仓库也自动包含在里面；
	insert into dbo.M2_CelueSet_Analysis
	(title,Gate1,IsParentException,Wastage,EnableStockModel,JoinMuilsUnit,SafeStock,ReplaceModel,cks,intro,isStop,creator,inDate,del)
	values('标准策略',20,1,1,1,0,1,0,0,'',0,0,GETDATE(),1)
	insert into dbo.M2_CelueSet_Analysis
	(title,Gate1,IsParentException,Wastage,EnableStockModel,JoinMuilsUnit,SafeStock,ReplaceModel,cks,intro,isStop,creator,inDate,del)
	values('精确策略',10,1,1,2,1,1,0,0,'',0,0,GETDATE(),1)

	insert into dbo.home_usConfig(name,nvalue,tvalue,uid)values('OldDataOrAnalysisSet',1,'',0)
end

GO

--出库策略默认值
if not exists(select 1 from home_usConfig where name = 'KuoutOrderType' and uid=0)
begin
	insert into  home_usConfig  (name, nvalue, uid) values ('KuoutOrderType', 1, 0)
end

GO

--删除库存入库删除负库存
if not exists(select 1 from home_usConfig where name = 'DeleteKuByID' and uid=0)
begin
    delete from ku where id in(
	select id from ku  
	WHERE NOT EXISTS(select 1 from kuoutlist2 where ku=ku.id) 
	and NOT EXISTS(select 1 from kuhclist where kuinlist=ku.kuinlist)
	and isnull(ku.status,0)=2 and ku.num1<0
    )
    insert into  home_usConfig  (name, tvalue, uid) values ('DeleteKuByID', 1, 0)
end

GO

--处理生产物料分析升级老数据（V2019.07.24）
if exists(select 1 from M2_MaterialAnalysisList where currenableKunum is null )
begin
	update  M2_MaterialAnalysisList 
	set 
		currenableKunum = isnull(cknum,0)
		+isnull(CGNum,0)
		+isnull(SCNum,0) 
		- isnull(HTNum,0) 
		- isnull(DemandNum,0)
		- isnull(AssignNum,0) 
	where currenableKunum is null;
end

GO
--二维码类型更新billType
if not exists(select 1 from home_usConfig where name = 'C2CodeTypesBillType')
begin
    UPDATE C2_CodeTypes SET billType =16001 WHERE title='产品自定义' AND fromSys=2    
    UPDATE C2_CodeTypes SET billType =61001 WHERE title='入库明细自定义' AND fromSys=2 
    insert into  home_usConfig  (name, tvalue, uid) values ('C2CodeTypesBillType', 0, 0)
end

GO
--物料明细数据NodeDataType更新
if exists(select 1 from dbo.M2_MaterialAnalysisList mal where mal.NodeDataType is null)	
begin
	update dbo.M2_MaterialAnalysisList set NodeDataType=0 where NodeDataType is null
end 
GO
--扫描出入库声音提示
if not exists(select 1 from home_usConfig where name = 'KuinKuoutScanfSuccessRemindSound')
begin
    insert into home_usConfig(name, nvalue, uid) values ('KuinKuoutScanfSuccessRemindSound', 1, 0)
    insert into home_usConfig(name, nvalue, uid) values ('KuinKuoutScanfFailRemindSound', 1, 0)
end
GO
--付款自动进入审批流程
if not exists(select intro from setopen where sort1=74)
begin
    insert into setopen(intro,sort1)values(1,74)
end

--初始化领料策略
if not exists(select 1 from dbo.M2_MaterialConfig)
begin
   insert into dbo.M2_MaterialConfig(isExcess,NoBillPaking,IsMaterialForAdd,IsMaterialAutoOutKuApply)
   values(0,1,1,1)
end

if exists(select 1 from dbo.M2_MaterialConfig where IsMaterialForAdd is null and IsMaterialAutoOutKuApply is null)
begin
   update dbo.M2_MaterialConfig set isExcess=0,NoBillPaking=1,IsMaterialForAdd=1,IsMaterialAutoOutKuApply=1
end
--处理历史数据领料单类型
update a set a.MaterialType=(case when isnull(m.MOID,0)>0 then 2 else 1 end)
from dbo.M2_MaterialOrders a
left join(
    select b.MOID from dbo.M2_MaterialOrderLists b 
    where isnull(b.ListID,0)>0 group by b.MOID
) m on a.ID=m.MOID
where a.MaterialType is null

GO
--报价主表自定义字段老数据升级
if not exists(select 1 from sys_sdk_BillFieldInfo where BillType=13001  and  ListType=0)
begin
    select ord,zdy1,zdy2,zdy3,zdy4,zdy5,zdy6 into #tempMainTable from price;
    exec [MainZdyToBillFieldInfo] 13001,4;
end

GO
--报价明细自定义字段老数据升级
IF not exists(select 1 from sys_sdk_BillFieldInfo  b  where  b.billtype=13001 and b.ListType='1')
begin
    declare  @UniallAllV varchar(max)
    set @UniallAllV ='	union all select ''折扣'', ''InheritId_self_discount'',  0, @index,0,0,1,1,0, ''discount'' 
	                    union all select ''未税折后单价'', ''InheritId_self_priceAfterDiscount'',  0, @index+1,0,0,1,1,0, ''priceAfterDiscount''  
	                    union all select ''含税单价'', ''InheritId_self_priceIncludeTax'',  0, @index+2,0,0,1,1,0, ''priceIncludeTax'' 
	                    union all select ''含税折后单价'', ''InheritId_self_priceAfterTax'',  0, @index+3,0,0,1,1,0, ''priceAfterTax''
	                    union all select ''票据类型'', ''InheritId_self_invoiceType'',  0, @index+4,0,0,1,1,0, ''invoiceType''
	                    union all select ''税率'', ''InheritId_self_taxRate'',  0, @index+5,0,0,1,1,0, ''taxRate'' 
	                    union all select ''税额'', ''InheritId_self_taxValue'',  0, @index+6,0,0,1,1,0, ''taxValue'' 
	                    union all select ''税前总价'', ''InheritId_self_moneyBeforeTax'',  0, @index+7,0,0,1,1,0, ''moneyBeforeTax'''
    
    select id,price AS mainId,zdy1,zdy2,zdy3,zdy4,zdy5,zdy6 into #tempListTable from pricelist;
    exec [ListZdyToBillFieldInfo]13001, 4 , @UniallAllV;

    update sys_sdk_BillFieldInfo 
	    set title =case when dbname='InheritId_id_price1' then '未税单价' when dbname='InheritId_id_money1' then '税后总价'  else title END,
	    dbname = CASE WHEN dbname='InheritId_self_unitall' THEN 'InheritId_self_unit' ELSE dbname END 
    where  billtype =13001 and ListType = 1 
    UPDATE sys_sdk_BillFieldInfo SET ShowIndex=null WHERE  BillType=13001 AND DBName IN('InheritId_self_pricejy','InheritId_self_tpricejy') AND ListType=1 
end

GO

--更新生产补料自动出库策略
if not exists(select 1 from home_usConfig where name = 'IsSupplementsAutoOutKuApply')
begin
    insert into  home_usConfig  (name, nvalue, uid) values ('IsSupplementsAutoOutKuApply', 1, 0)
end
 
GO

--生产补料编号自定义
if not exists(select id from zdybh where sort1=55006)
begin
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('SCBL_',1,1,4,2,1,55006)
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号2',1,0,4,2,2,55006) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号3',1,0,4,2,3,55006) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号4',1,0,4,2,4,55006) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',2,1,4,2,5,55006) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',3,1,2,2,6,55006) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',4,1,2,2,7,55006) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',5,1,3,2,8,55006) 
end

GO

update x  set x.hasChild =  isnull( sign(z.sort1),0)*10 +  Isnull(sign(y.id1),0)  from menu  x
left join (select distinct  id1  from menu)  y on x.id=y.id1 
left join (select distinct  sort1 from product)  z on x.id=z.sort1 
where isnull(x.hasChild,-2) <>   isnull( sign(z.sort1),0)*10 +  Isnull(sign(y.id1),0)

GO

--修复派工单所需物料为半成品的数据BOM错误数据
update  x set  x.BomList= child.id 
from  M2_WorkAssignLists x 
inner join M2_WorkAssigns y on x.WAID=y.ID and x.BomList=y.BomList  and y.BomList>0
inner join M2_PlanBomList z on y.BomList=z.id
inner join M2_PlanBomList child on child.PID=z.id and child.productID=x.ProductID and child.unit=x.unit
and  x.BomList= child.PID

GO

--修复派工单fromtype
UPDATE M2_WorkAssigns SET fromtype=4 WHERE ID IN (select C.ID from M2_ManuOrders A INNER JOIN M2_ManuOrderLists B ON A.ID=B.MOrderID 
INNER JOIN M2_WorkAssigns C ON B.ID=C.ddlistid
where ISNULL(MAID,0)>0 and isnull(c.ptype,0)=0 AND C.fromtype NOT IN(3,5,6,7)) 

GO
--处理报价审批和分类老数据
if not exists(select 1 from home_usConfig where name='updateOldPriceAndApproveDate')
begin
	DECLARE @sortId INT
	--添加默认分类
	INSERT INTO sortonehy(sort1,gate1,gate2,del,isStop) VALUES ('默认分类','1','13001',1,0)
	SELECT @sortId= @@identity
	UPDATE sortonehy SET ord=id WHERE id= @sortId
    
	UPDATE sp SET sptype=-1 WHERE gate2=1
	EXEC dbo.erp_ApproveList 63,13001, -1, 1
    
    --更新单据审批状态
	UPDATE price SET status = CASE complete WHEN -1 THEN 0 WHEN 0 THEN 1 WHEN 3 THEN 4 END,sort1=@sortId
    --更新历史审批实例
	insert into sp_ApprovalInstance(
                    ApprovalRulesId,ApprovalProcessId,gate2, sptype,PrimaryKeyID,BillRight,
                    ApprovalFlowStatus,Approver,BillPattern,CreateTime,UserID,Bounds , SurplusApprover ,  ApprovalType , ApprovalRelation,Gate1)
	select sr.ApprovalRulesID, p.id_sp , sr.gate2 ,-1 , p.ord , '报价权限' , p.status , p.cateid_sp,0 , getdate(), 63, 1 , p.cateid_sp ,  0 ,  3 ,s.gate1
	from price p 
	inner join sp_ApprovalRules sr on sr.gate2= 13001 and sr.sptype=-1 --升级时 仅当前记录
	left join sp s on s.id = p.id_sp
	where exists(select 1 from sp_intro where sort1=13001 and ord = p.ord) or p.complete in (3)
		and not exists(select 1 from sp_ApprovalInstance where gate2=13001 and PrimaryKeyID = p.ord)
	--更新历史审批记录关系
	update so set so.InstanceID=st.InstanceID ,so.ApproverName = g.name,so.ApproverDept='',so.ApprovalResult=1, so.IsAutoPass=0,
		so.ApprovalType = '单审', so.gate3=3 , so.Operator =  g.name, so.CreateTime = so.date1 , so.OperationTime = so.date1 ,
		so.ApprovalLevel = sp.gate1, so.nextSpID = 0 , so.currNodeApprover = so.cateid
	from sp_intro so
	inner join sp_ApprovalInstance st on st.gate2 = 13001 and st.PrimaryKeyID = so.ord
	left join gate g on g.ord= so.cateid
	left join sp on sp.id = so.sp_id
	where so.sort1 = 13001
	--自动获取编号回收站判定
    UPDATE BHConfigs SET exCondition='' WHERE id=4
    
    --编号老数据
	UPDATE zdybh SET sort1=13001 WHERE sort1=4
	insert into  home_usConfig  (name, tvalue, uid) values ('updateOldPriceAndApproveDate', 0, 0)
END


GO
--处理报价明细新加字段老数据
if not exists(select 1 from home_usConfig where name='updateOldPriceNewFieldsDate')
begin
	--更新单据审批状态
	UPDATE pricelist SET discount=1 ,priceAfterDiscount=price1,invoiceType=0,taxRate=0,priceIncludeTax=price1,priceAfterTax=price1,moneyBeforeTax=money1,taxValue=0;
	insert into  home_usConfig  (name, tvalue, uid) values ('updateOldPriceNewFieldsDate', 0, 0)
END

GO

--2019.09.16 31.92处理物料登记老数据
declare @dat datetime 
select @dat = cast(max(date1) as datetime) from (
	select max(dateadd(mm,1,date1))  as date1 from M2_CostComputation where complete1 >= 1
	union all
	select min(date1) from M2_CostSet
)  t where not date1 is null
set @dat = isnull(@dat,  convert(varchar(10), (getdate() - day(getdate())) + 1,120))
if exists(select 1 from M2_MaterialRegisters where potype =2 or poType=4 and date1>@dat)
begin
	--返工
	select id into #regtmp00x from  M2_MaterialRegisters x where  x.potype =2  and  x.date1>@dat 
	update x set
			x.bid = y.waid,
			x.potype = 1
	from #regtmp00x  tm
	inner join M2_MaterialRegisters x  on x.id = tm.id
	inner join M2_WorkAssigns y on  x.bid=y.id 
	
	update y 
		set y.ListID = z.id 
	from #regtmp00x tm
	inner join M2_MaterialRegisters x  on x.id = tm.id
	inner join M2_MaterialRegisterLists y on x.ID=y.MRID
	inner join M2_WorkAssignlists z on z.ProductID = y.ProductID  and z.BomList=y.BomList  and z.waid=x.bid


	--工序返工
	select id into #regtmp01x from  M2_MaterialRegisters x where  x.potype =4  and  x.date1>@dat 
	update x set
			x.bid = z1.WAID,
			x.potype = 1
	from #regtmp01x  tm
	inner join M2_MaterialRegisters x  on x.id = tm.id
	inner join M2_OutOrder  y on  x.bid=y.id 
	inner join M2_OutOrderlists  z on y.id=z.outID 
	inner join M2_WFP_Assigns  z1 on z.WFPAID =z1.id
	
	update y 
		set y.ListID = z.id 
	from #regtmp01x tm
	inner join M2_MaterialRegisters x  on x.id = tm.id
	inner join M2_MaterialRegisterLists y on x.ID=y.MRID
	inner join M2_WorkAssignlists z on z.ProductID = y.ProductID  
	and z.waid=x.bid  and z.waid=x.bid
end

GO

--2019.10.24 31.93处理工序流程字段信息
if exists(select 1 from dbo.M2_WFP where ConversionBL is null 
and ReportingExceptionStrategy is null 
and BatchNumberStart is null
and SerialNumberStart is null
and ReportingRounding is null
)
begin
    update dbo.M2_WFP set ConversionBL=1 where ConversionBL is null
    update dbo.M2_WFP set ReportingExceptionStrategy=0 where ReportingExceptionStrategy is null
    update dbo.M2_WFP set BatchNumberStart=0 where BatchNumberStart is null
    update dbo.M2_WFP set SerialNumberStart=0 where SerialNumberStart is null
    update dbo.M2_WFP set ReportingRounding=0 where ReportingRounding is null
end
GO
if exists(select 1 from dbo.M2_WFP_Assigns where ConversionBL is null 
and ReportingExceptionStrategy is null 
and BatchNumberStart is null
and SerialNumberStart is null
and ReportingRounding is null
)
begin
    ---备份工序数据处理
    update dbo.M2_WFP_plan set ConversionBL=1 where ConversionBL is null
    update dbo.M2_WFP_plan set ReportingExceptionStrategy=0 where ReportingExceptionStrategy is null
    update dbo.M2_WFP_plan set BatchNumberStart=0 where BatchNumberStart is null
    update dbo.M2_WFP_plan set SerialNumberStart=0 where SerialNumberStart is null
    update dbo.M2_WFP_plan set ReportingRounding=0 where ReportingRounding is null

    update dbo.M2_WFP_Assigns set ConversionBL=1 where ConversionBL is null
    update dbo.M2_WFP_Assigns set ReportingExceptionStrategy=0 where ReportingExceptionStrategy is null
    update dbo.M2_WFP_Assigns set BatchNumberStart=0 where BatchNumberStart is null
    update dbo.M2_WFP_Assigns set SerialNumberStart=0 where SerialNumberStart is null
    update dbo.M2_WFP_Assigns set ReportingRounding=0 where ReportingRounding is null

    --所有老数据的批号，如果“派工产品”处勾选，则默认手动工序勾选；如果“派工产品”未勾选，则默认工序也未勾选
    update wfpa set wfpa.BatchNumberStart=1
    from dbo.M2_WFP_Assigns wfpa
    inner join dbo.M2_WorkAssigns wa on wa.ID=wfpa.WAID
    where isnull(wa.isHasPH,0)=1 
    and not exists(
    select 1 from dbo.M2_WFP_Assigns wfpa2 where isnull(wfpa2.BatchNumberStart,0)=1 and wfpa2.WAID=wfpa.WAID 
    )
    and wfpa.ord=(select MIN(m.ord) from dbo.M2_WFP_Assigns m where m.WAID=wa.ID)
    and wfpa.ID=(select MIN(m.ID) from dbo.M2_WFP_Assigns m where m.WAID=wa.ID and wfpa.ord=m.ord)
    --所有老数据的序列号，如果“派工产品”处勾选，则默认手动工序勾选；如果“派工产品”未勾选，则默认工序也未勾选
    update wfpa set wfpa.SerialNumberStart=1
    from dbo.M2_WFP_Assigns wfpa
    inner join dbo.M2_WorkAssigns wa on wa.ID=wfpa.WAID
    where isnull(wa.isHasXLH,0)=1 
    and not exists(
    select 1 from dbo.M2_WFP_Assigns wfpa2 where isnull(wfpa2.SerialNumberStart,0)=1 and wfpa2.WAID=wfpa.WAID
    )
    and wfpa.ord=(select MIN(m.ord) from dbo.M2_WFP_Assigns m where m.WAID=wa.ID)
    and wfpa.ID=(select MIN(m.ID) from dbo.M2_WFP_Assigns m where m.WAID=wa.ID and wfpa.ord=m.ord)
    
    --汇报取整数据处理
    update wfpa set wfpa.ReportingRounding=1
    from dbo.M2_WFP_Assigns wfpa 
    where exists(
      select 1 from dbo.M2_WFP_Assigns wfpa2
      where wfpa2.WAID=wfpa.WAID and wfpa2.SerialNumberStart=1
    )

end
--所有老数据，汇报单位默认“产品单位”;
update wfpa set wfpa.ReportingUnit=wa.unit
from dbo.M2_WFP_Assigns wfpa
inner join dbo.M2_WorkAssigns wa on wa.ID=wfpa.WAID
where isnull(wfpa.ReportingUnit,0)=0
GO

--修复物料分析和物料分析生成的生产订单的工艺流程存储，应存储备份，错误数据存储的原工艺流程ID
UPDATE MAL SET MAL.WPROC=MPBL.WProc from M2_MaterialAnalysisList MAL inner join M2_PlanBomList MPBL ON MAL.BomListID=MPBL.id
WHERE MAL.WPROC<>MPBL.WProc

UPDATE MOL SET MOL.WPROC=MPBL.WProc from M2_ManuOrderLists MOL inner join M2_PlanBomList MPBL ON MOL.BomListID=MPBL.id
WHERE  MOL.WPROC<>MPBL.WProc AND ISNULL(MOL.MASLID,0)>0

--更新报价票据类型，将不开票的票据类型数据更新为0
if not exists(select 1 from home_usConfig where name = 'priceInvoiceTypeNoInvoicUpdate')
begin
    UPDATE dbo.pricelist SET invoiceType=0 WHERE invoiceType = ISNULL((SELECT TOP 1 id FROM sortonehy s  WHERE s.gate2=34 and s.id1='-65535'),0)
    insert into  home_usConfig  (name, nvalue, uid) values ('priceInvoiceTypeNoInvoicUpdate', 1, 0)
end

GO

--处理派工单质检 无物料登记允许入库策略 ，此策略在92版本已清除，但是老数据有可能会开启无物料登记不允许入库
if exists(select 1 from M2_QualityTestingsConfig where proType=2 and ISNULL(isRegist,0)=0)
begin
    update M2_QualityTestingsConfig set isRegist=1 where proType=2
end

GO

--V31.93迭代增加执行工序例外策略，执行顺序取上道合格规则有变，此处处理历史工序的上道执行顺序
UPDATE dbo.M2_WFP_Assigns SET PreIndex = ord - 1 WHERE PreIndex IS NULL

GO

--更新资产折旧历史领用人员
if not exists(select 1 from home_usConfig where name = 'assDeprectUpdate')
begin
    UPDATE dbo.O_assDeprect SET D_lycateid=(select ass_lycateid from O_asset where ass_id=O_assDeprect.d_assid) WHERE D_del=2
    insert into  home_usConfig  (name, nvalue, uid) values ('assDeprectUpdate', 1, 0)
end

GO

--更新payout表company字段没有值的问题
update x set x.company = y.company from  Payout x inner join caigou y on x.company is null and x.cls=0 and x.[contract]=y.ord
update x set x.company = y.gys from  Payout x inner join M2_OutOrder y on x.company is null and x.cls in (4,5) and x.[contract]=y.id

--性能优化历史数据处理
IF NOT EXISTS(SELECT 1 FROM dbo.home_usConfig WHERE name='OldDataMaterialTask6248')
BEGIN
    -- [Task:6248] 【优化】生产派工和物料相关性能优化 历史数据处理
    --1、更新派工/返工单的质检状态 54002:派工,54005：返工
      exec dbo.erp_UpdateZJStatusByWaids '',54002
      exec dbo.erp_UpdateZJStatusByWaids '',54005
    --2、更新派工单,返工，整单委外，工序委外的领料状态billtype 54002=派工 54005=返工 54003=整单委外 54006=工序委外
      exec dbo.erp_UpdateLLStatusByOutidsOrWaids '',54002
      exec dbo.erp_UpdateLLStatusByOutidsOrWaids '',54005
      exec dbo.erp_UpdateLLStatusByOutidsOrWaids '',54003
      exec dbo.erp_UpdateLLStatusByOutidsOrWaids '',54006
    --3、更新整单委外，派工的登记状态billtype 54002=派工 54003=整单委外
      exec dbo.erp_UpdateDJStatusByOutidsOrWaids '',54002
      exec dbo.erp_UpdateDJStatusByOutidsOrWaids '',54003
    --4、更新整单委外，派工或返工的的入库状态billtype 54002=派工 54003=整单委外  54005=返工
      exec dbo.erp_UpdateRKStatusByOutidsOrWaids '',54002
      exec dbo.erp_UpdateRKStatusByOutidsOrWaids '',54003
      exec dbo.erp_UpdateRKStatusByOutidsOrWaids '',54005
  
    --5、更新领/补料单的出库状态及申请出库数量，确认出库数量 MaterialType 1,2=领料（输入非3） 3=补料 
      exec dbo.erp_UpdateMaterialOrderOutKuInfo '',3
      exec dbo.erp_UpdateMaterialOrderOutKuInfo '',0
    --插入是执行过数据标记（测试期间注释）
    insert into dbo.home_usConfig(name,nvalue,uid)values('OldDataMaterialTask6248',1,0)
end 

--性能优化历史数据处理(因94迭代处理整单委外入库状态有误,96迭代修复,再次维护整单委外入库状态)
IF EXISTS(SELECT 1 FROM dbo.home_usConfig WHERE name='OldDataMaterialTask6248') AND NOT EXISTS(SELECT 1 FROM dbo.home_usConfig WHERE name='OldDataMaterialTask6249')
BEGIN
    exec dbo.erp_UpdateRKStatusByOutidsOrWaids '',54003
    --插入是执行过数据标记（测试期间注释）
    insert into dbo.home_usConfig(name,nvalue,uid)values('OldDataMaterialTask6249',1,0)
end 

if not exists(select 1 from zdybh where sort1=11001)
begin 
    --合同自定义编号
	insert into zdybh( title,sort,set_open,intro1,intro2,gate1, sort1)
	select title,sort,set_open,intro1,intro2,gate1,11001 as sort1 from zdybh where sort1=5 order by gate1
    UPDATE a SET a.fieldID = b.inx FROM dbo.zdybh a
	INNER JOIN (
		SELECT ROW_NUMBER() OVER(ORDER BY gate1) inx,id FROM dbo.zdybh WHERE sort1 = 11001 AND sort = 1
	) b ON a.id = b.id
    UPDATE dbo.zdybh SET fieldID = sort + 3 WHERE sort1 = 11001 AND sort > 1
	UPDATE dbo.zdybh SET sort = 6 WHERE sort1 = 11001 AND sort = 1
END

GO

--92版本以后默认入库自动登记 现添加策略控制是否自动登记，默认维护为1 自动登记
if not exists(select 1 from home_usConfig where name = 'CanAutoRegister' and uid=0)
begin
	insert into  home_usConfig  (name, nvalue, uid) values ('CanAutoRegister', 1, 0)
end

GO

--初始化生产看板方案-默认方案
declare @cnt int
select @cnt = COUNT(1) from [dbo].[M2_ActualBoardScheme]

if(@cnt = 0)
begin
	
	--插入看板方案
	truncate table [dbo].[M2_ActualBoardScheme]
	insert into 
	[dbo].[M2_ActualBoardScheme] (Title,Sort,Multiple,Skins,ShowType,PageSize,[TimeOut],TimeOutUnit,RollSpeed,Dimension,IsDefault,IsStop,InDate,Creator,UpDateTime,UpUser,Del)
	select '默认派工方案',1,1.000000000000,1,	0,5,1.000000000000,1,80,0,1,0,GETDATE(),0,GETDATE(),0,1
	union all
	select '默认产线方案',1,1.000000000000,1,	0,5,1.000000000000,1,80,1,1,0,GETDATE(),0,GETDATE(),0,1
	
	--插入生产看板方案_明细自定义字段
	truncate table [dbo].[M2_ActualBoardCustomFields]
	insert into
	[dbo].[M2_ActualBoardCustomFields](Title,Sort,SortMin,SortMax,MustShow,IsShow,AutoWidth)
	select '产线'		,1	,1	,4	,0	,0	,10.000000000000
	union all
	select '派工单'		,2	,1	,4	,1	,1	,15.000000000000
	union all
	select '加工产品'	,3	,1	,4	,1	,1	,20.000000000000
	union all
	select '加工工序'	,4	,1	,4	,1	,1	,17.000000000000
	union all
	select '生产设备'	,5	,5	,13	,0	,0	,10.000000000000
	union all
	select '生产人员'	,6	,5	,13	,0	,1	,8.000000000000
	union all
	select '被派人员'	,7	,5	,13	,0	,0	,10.000000000000
	union all
	select '完工期'		,8	,5	,13	,0	,1	,10.000000000000
	union all
	select '加工数量'	,9	,5	,13	,0	,1	,8.000000000000
	union all
	select '合格数量'	,10	,5	,13	,0	,1	,8.000000000000
	union all
	select '报废数量'	,11	,5	,13	,0	,1	,8.000000000000
	union all
	select '返工数量'	,12	,5	,13	,0	,0	,8.000000000000
	union all
	select '达成率'		,13	,5	,13	,0	,1	,8.000000000000
	
	--插入生产看板方案_明细自定义应用
	truncate table [dbo].[M2_ActualBoardCustomList]
	insert into
	[dbo].[M2_ActualBoardCustomList](ActualBoardSchemeId,FieldId,Sort,IsShow,AutoWidth)
	select 1	,1	,1	,0	,10.000000000000
	union all
	select 1	,2	,2	,1	,15.000000000000
	union all
	select 1	,3	,3	,1	,20.000000000000
	union all
	select 1	,4	,4	,1	,17.000000000000
	union all
	select 1	,5	,5	,0	,10.000000000000
	union all
	select 1	,6	,6	,1	,8.000000000000
	union all
	select 1	,7	,7	,0	,8.000000000000
	union all
	select 1	,8	,8	,1	,8.000000000000
	union all
	select 1	,9	,9	,1	,8.000000000000
	union all
	select 1	,10	,10	,1	,8.000000000000
	union all
	select 1	,11	,11	,1	,8.000000000000
	union all
	select 1	,12	,12	,0	,8.000000000000
	union all
	select 1	,13	,13	,1	,8.000000000000
	union all
	select 2	,1	,1	,1	,13.000000000000
	union all
	select 2	,2	,3	,1	,15.000000000000
	union all
	select 2	,3	,4	,1	,15.000000000000
	union all
	select 2	,4	,2	,1	,17.000000000000
	union all
	select 2	,5	,5	,0	,10.000000000000
	union all
	select 2	,6	,6	,1	,8.000000000000
	union all
	select 2	,7	,7	,0	,8.000000000000
	union all
	select 2	,8	,8	,1	,8.000000000000
	union all
	select 2	,9	,9	,1	,8.000000000000
	union all
	select 2	,10	,10	,1	,8.000000000000
	union all
	select 2	,11	,11	,1	,8.000000000000
	union all
	select 2	,12	,12	,0	,8.000000000000
	union all
	select 2	,13	,13	,1	,8.000000000000
end

GO

if not exists(select 1 from home_usConfig where name = 'ConversionUnitTactics' and uid=0)
begin
	insert into  home_usConfig  (name, nvalue, uid) values ('ConversionUnitTactics', 1, 0)
end

GO

if not exists( select 1 from  home_usConfig where name='__update_deleted_oldMobileMacBindData')
begin
	insert into  home_usConfig (name,  nvalue, [uid]) values ('__update_deleted_oldMobileMacBindData', 1,  0 )
	delete Mob_UserMacMap
end

GO

--94版本合同提成分配方式变更，需执行数据更新操作，且只执行一次
if not exists(select 1 from home_usConfig where name = 'ContractRoyalty' and uid=0 and nvalue=1)
begin
	insert into  home_usConfig  (name, nvalue, uid) values ('ContractRoyalty', 1, 0)
    insert into ContractRoyalty(contract,RoyaltyCateID,RoyaltyBL,RoyaltyMoney,Intro,del)
    select ct.ord,ct.cateid,'100',isnull(ct.money_tc2,0),'',1
    from contract ct 
    inner join gate g on g.ord=ct.cateid 
    where ct.tc in (2,3) 
    and not exists(select 1 from ContractRoyalty where contract=ct.ord and RoyaltyCateID=ct.cateid)
    and ct.del=1 
end   

GO

IF EXISTS(SELECT 1 FROM dbo.M2_WageList_JJ WHERE ReportMonth IS NULL)
BEGIN
	UPDATE jl SET jl.ReportMonth = CONVERT(VARCHAR(7),j.Countdate,120), jl.Countdate = j.Countdate FROM dbo.M2_WageList_JJ jl
	INNER JOIN dbo.M2_Wage_JJ j ON j.id = jl.WJID
	WHERE jl.ReportMonth IS NULL
END

GO

IF EXISTS(SELECT 1 FROM dbo.M2_WageList_JS WHERE ReportMonth IS NULL)
BEGIN
	UPDATE jl SET jl.ReportMonth = CONVERT(VARCHAR(7),j.Jsdate,120), jl.Jsdate = j.Jsdate FROM dbo.M2_WageList_JS jl
	INNER JOIN dbo.M2_Wage_JS j ON j.id = jl.JSID
	WHERE jl.ReportMonth IS NULL
END

GO

if not exists(
	select top 1 1 from dbo.[home_usConfig]
	where name = 'hasQx51/54_Qxlist44')
begin
	--插入生产看板权限
	delete dbo.[power] where sort1 = 54 and sort2 = 44
	insert into dbo.[power] (qx_open,qx_intro,ord,sort1,sort2)
	select distinct 1,'-222',ord,54,44 from dbo.[power] where (sort1 = 54 or sort1 = 5031) and sort2 = 1 and (qx_open = 1 or qx_open = 3)
	
	--插入生产工作台权限
	delete dbo.[power] where sort1 = 51 and sort2 = 44
	insert into dbo.[power] (qx_open,qx_intro,ord,sort1,sort2)
	select distinct 1,'-222',ord,51,44 from dbo.[power] x
	inner join (
		select sort1 from dbo.[qxlb] where sort1 between 50 and 59 or sort1 between 5000 and 5999 or sort1 in(60,61,62,63,64)
	) y on x.sort1 = y.sort1
	where x.sort2 != 19 and (x.qx_open = 1 or x.qx_open = 3)
	
	--记录已处理过生产工作台和生产看板权限
	insert into dbo.[home_usConfig](name,tvalue,uid)
	select 'hasQx51/54_Qxlist44',1,63
end

GO

if not exists( select 1 from  home_usConfig where name='__update_Shop_GoodsAttr')
begin
    select ROW_NUMBER()over(order by proCategory, sort desc , id desc) inx , id , proCategory , isTiled into #Attrs
    from Shop_GoodsAttr 
    where pid = 0 and isStop=0

    delete from #Attrs where proCategory in (select proCategory from #Attrs where isnull(isTiled,0)=1)

    update s set s.isTiled = 1
    from #Attrs a
    inner join (
	    select min(inx) inx ,proCategory from #Attrs group by proCategory
    ) m on m.inx = a.inx
    inner join Shop_GoodsAttr s on s.id = a.id

    update s set s.isStop = 1
    from #Attrs a
    inner join (
	    select min(inx) inx ,proCategory from #Attrs group by proCategory
    ) m on m.proCategory = a.proCategory and a.inx > m.inx+1
    inner join Shop_GoodsAttr s on s.id = a.id

    drop table #Attrs
	insert into  home_usConfig (name,  nvalue, [uid]) values ('__update_Shop_GoodsAttr', 1,  0 )
end

GO

if not exists( select 1 from  home_usConfig where name='Updatecontract_outPrintID')
begin
    update contract_out set PrintID=0 where LEN(ISNULL(cast(A1 as nvarchar(max)),''))>0 AND isnumeric(cast(A1 as nvarchar(500)))=0 and sort=62001
	insert into  home_usConfig (name,  nvalue, [uid]) values ('Updatecontract_outPrintID', 1,  0 )
end

GO

IF EXISTS(SELECT 1 FROM PrinterInfo WHERE sort=150 and AccountYear is null)
Begin
	update PrinterInfo set AccountYear=YEAR(addDate) WHERE sort=150
End

GO

if not exists(
	select top 1 1 from dbo.[home_usConfig]
	where name = 'hasQxlist_13_40')
begin
	--插入日记账统计权限
	delete dbo.[power] where sort1 = 13 and sort2 = 40
	insert into dbo.[power] (qx_open,qx_intro,ord,sort1,sort2)
	select distinct 1,'-222',ord,13,40 from dbo.[power] where sort1 = 13 and sort2 = 24 and (qx_open = 1 or qx_open = 3)
	
	--记录已处理过日记账统计权限
	insert into dbo.[home_usConfig](name,tvalue,uid)
	select 'hasQxlist_13_40',1,63
end
GO

--考勤类型历史数据处理
IF NOT EXISTS(SELECT 1 FROM dbo.home_usConfig WHERE name='OldDataAttendanceTypeTask6248')
BEGIN
    --年假处理
    IF EXISTS(SELECT 1 FROM dbo.HrKQ_AttendanceType WHERE OnlyID=12) 
    BEGIN
        update dbo.HrKQ_AttendanceType set Personalization='{"PayOffTime":0,"CountRule":0,"WorkYearCounts":{},"ContractYearCounts":{"0":5,"1":6,"2":7,"3":8,"4":9,"5":10},"FixedYearCount":0,"InvalidYears":1}'
          ,AttTypeCls=1,Unit=0,IsAlloweRest=0,isClock=0,isUpdate=0,showIndex=1,Status=1
        where OnlyID=12
    End else
    begin
        INSERT INTO dbo.HrKQ_AttendanceType(OnlyID,Title,Unit,isContainHoliday,isRelatedWage,isAlloweRest,isAllowApply,TermofValidity ,[Status],isUpdate,CreateId ,CreateDate,isClock,AttTypeCls,Personalization,showIndex) 
        VALUES (12,'年假',0 ,1 , 1 , 0 , 1 ,0 , 1 ,0 ,0,GETDATE(),0,1,'{"PayOffTime":0,"CountRule":0,"WorkYearCounts":{},"ContractYearCounts":{"0":5,"1":6,"2":7,"3":8,"4":9,"5":10},"FixedYearCount":0,"InvalidYears":1}',1);
    end
    
    --婚假处理
    IF EXISTS(SELECT 1 FROM dbo.HrKQ_AttendanceType WHERE Title='婚假' and AttTypeCls=1) 
    BEGIN
        --修复审批流程
        update aa set aa.sptype=-14 
        from dbo.sp aa
        where exists(
           SELECT 1 FROM dbo.HrKQ_AttendanceType at 
           WHERE at.Title='婚假' and at.AttTypeCls=1 and aa.sptype=at.OnlyID
        ) and aa.gate2=8 and aa.sptype<>-1

        update aa set aa.sptype=-14 
        from dbo.sp_ApprovalRules aa
        where exists(
           SELECT 1 FROM dbo.HrKQ_AttendanceType at 
           WHERE at.Title='婚假' and at.AttTypeCls=1 and aa.sptype=at.OnlyID
        ) and aa.gate2=8 and aa.sptype<>-1

        update aa set aa.ApplyType=-14 
        from dbo.HrKQ_AttendanceApply aa
        where exists(
           SELECT 1 FROM dbo.HrKQ_AttendanceType at 
           WHERE at.Title='婚假' and at.AttTypeCls=1 and aa.ApplyType=at.OnlyID
        )
 
        update dbo.HrKQ_AttendanceType set Personalization='{"RuleType":1,"FixedDays":0,"DynamicDays":[{"Key":"23","Value":"3"},{"Key":"","Value":""}],"InvalidMonths":3}'
        ,OnlyID=-14,isUpdate=0,Unit=0,IsAlloweRest=0,isClock=0,showIndex=2,Status=1
        where Title='婚假' and AttTypeCls=1
    End else
    BEGIN
        INSERT INTO dbo.HrKQ_AttendanceType(OnlyID,Title,Unit,isContainHoliday,isRelatedWage,isAlloweRest,isAllowApply,TermofValidity
        ,[Status],isUpdate,CreateId ,CreateDate,isClock,AttTypeCls,Personalization,showIndex) 
        VALUES (-14,'婚假',0 ,1 , 1 , 0 , 1 ,0 , 1 ,0 ,0,GETDATE(),0,1,'{"RuleType":1,"FixedDays":0,"DynamicDays":[{"Key":"23","Value":"3"},{"Key":"","Value":""}],"InvalidMonths":3}',2);
    end
    --产假处理
    IF EXISTS(SELECT 1 FROM dbo.HrKQ_AttendanceType WHERE Title='产假' and AttTypeCls=1) 
    BEGIN

        --修复审批流程
        update aa set aa.sptype=-16 
        from dbo.sp aa
        where exists(
           SELECT 1 FROM dbo.HrKQ_AttendanceType at 
           WHERE at.Title='产假' and at.AttTypeCls=1 and aa.sptype=at.OnlyID
        ) and aa.gate2=8 and aa.sptype<>-1

        update aa set aa.sptype=-16 
        from dbo.sp_ApprovalRules aa
        where exists(
           SELECT 1 FROM dbo.HrKQ_AttendanceType at 
           WHERE at.Title='产假' and at.AttTypeCls=1 and aa.sptype=at.OnlyID
        ) and aa.gate2=8 and aa.sptype<>-1

        update aa set aa.ApplyType=-16 
        from dbo.HrKQ_AttendanceApply aa
        where exists(
           SELECT 1 FROM dbo.HrKQ_AttendanceType at 
           WHERE at.Title='产假' and at.AttTypeCls=1 and aa.ApplyType=at.OnlyID
        )
        update dbo.HrKQ_AttendanceType set OnlyID=-16,isUpdate=0,Unit=0,IsAlloweRest=0,isClock=0
        ,Personalization='{"SplitMonth":4,"SplitLessThenDay":15,"SplitEqualDay":42,"SplitGreaterThanDay":98,"AddForDystocia":15,"AddForTwins":15,"AddForTriplets":15,"AddForOldAge":0}'
        ,showIndex=4,Status=1
        where Title='产假' and AttTypeCls=1
    End else
    BEGIN
        INSERT INTO dbo.HrKQ_AttendanceType(OnlyID,Title,Unit,isContainHoliday,isRelatedWage,isAlloweRest,isAllowApply,TermofValidity ,[Status]
        ,isUpdate,CreateId ,CreateDate,isClock,AttTypeCls,Personalization,showIndex) 
        VALUES (-16,'产假',0 ,1 , 1 , 0 , 1 ,0 , 1 ,0 ,0,GETDATE(),0,1,'{"SplitMonth":4,"SplitLessThenDay":15,"SplitEqualDay":42,"SplitGreaterThanDay":98,"AddForDystocia":15,"AddForTwins":15,"AddForTriplets":15,"AddForOldAge":0}',4);
    end
    --产检假
    IF EXISTS(SELECT 1 FROM dbo.HrKQ_AttendanceType WHERE Title='产检假' and AttTypeCls=1) 
    BEGIN

        --修复审批流程
        update aa set aa.sptype=-19 
        from dbo.sp aa
        where exists(
           SELECT 1 FROM dbo.HrKQ_AttendanceType at 
           WHERE at.Title='产检假' and at.AttTypeCls=1 and aa.sptype=at.OnlyID
        ) and aa.gate2=8 and aa.sptype<>-1

        update aa set aa.sptype=-19 
        from dbo.sp_ApprovalRules aa
        where exists(
           SELECT 1 FROM dbo.HrKQ_AttendanceType at 
           WHERE at.Title='产检假' and at.AttTypeCls=1 and aa.sptype=at.OnlyID
        ) and aa.gate2=8 and aa.sptype<>-1

        update aa set aa.ApplyType=-19 
        from dbo.HrKQ_AttendanceApply aa
        where exists(
           SELECT 1 FROM dbo.HrKQ_AttendanceType at 
           WHERE at.Title='产检假' and at.AttTypeCls=1 and aa.ApplyType=at.OnlyID
        )
        update dbo.HrKQ_AttendanceType set OnlyID=-19,isUpdate=0,Unit=0,IsAlloweRest=0,isClock=0
        ,Personalization='{"StepDays":[{"Key":"24","Value":"1"},{"Key":"24","Value":"1"},{"Key":"32","Value":"1"},{"Key":"36","Value":"2"},{"Key":"40","Value":"4"}]}'
        ,showIndex=7,Status=1
        where Title='产检假' and AttTypeCls=1
    End else
    BEGIN
        INSERT INTO dbo.HrKQ_AttendanceType(OnlyID,Title,Unit,isContainHoliday,isRelatedWage,isAlloweRest,isAllowApply,TermofValidity ,[Status],isUpdate,CreateId ,CreateDate,isClock,AttTypeCls,Personalization,showIndex) 
        VALUES (-19,'产检假',0 ,1 , 1 , 0 , 1 ,0 , 1 ,0 ,0,GETDATE(),0,1,'{"StepDays":[{"Key":"24","Value":"1"},{"Key":"24","Value":"1"},{"Key":"32","Value":"1"},{"Key":"36","Value":"2"},{"Key":"40","Value":"4"}]}',7);
    end
    --陪产假
    IF EXISTS(SELECT 1 FROM dbo.HrKQ_AttendanceType WHERE Title='陪产假' and AttTypeCls=1) 
    BEGIN
        --修复审批流程
        update aa set aa.sptype=-18 
        from dbo.sp aa
        where exists(
           SELECT 1 FROM dbo.HrKQ_AttendanceType at 
           WHERE at.Title='陪产假' and at.AttTypeCls=1 and aa.sptype=at.OnlyID
        ) and aa.gate2=8 and aa.sptype<>-1

        update aa set aa.sptype=-18 
        from dbo.sp_ApprovalRules aa
        where exists(
           SELECT 1 FROM dbo.HrKQ_AttendanceType at 
           WHERE at.Title='陪产假' and at.AttTypeCls=1 and aa.sptype=at.OnlyID
        ) and aa.gate2=8 and aa.sptype<>-1

        update aa set aa.ApplyType=-18 
        from dbo.HrKQ_AttendanceApply aa
        where exists(
           SELECT 1 FROM dbo.HrKQ_AttendanceType at 
           WHERE at.Title='陪产假' and at.AttTypeCls=1 and aa.ApplyType=at.OnlyID
        )
        update dbo.HrKQ_AttendanceType set OnlyID=-18,isUpdate=0,Unit=0,IsAlloweRest=0,isClock=0,Personalization='{"FixedLimitDay":15}',showIndex=6,Status=1
        where Title='陪产假' and AttTypeCls=1
    End else
    BEGIN
        INSERT INTO dbo.HrKQ_AttendanceType(OnlyID,Title,Unit,isContainHoliday,isRelatedWage,isAlloweRest,isAllowApply,TermofValidity ,[Status],isUpdate,CreateId ,CreateDate,isClock,AttTypeCls,Personalization,showIndex) 
        VALUES (-18,'陪产假',0 ,1 , 1 , 0 , 1 ,0 , 1 ,0 ,0,GETDATE(),0,1,'{"FixedLimitDay":15}',6);
    end
    --哺乳假
    IF EXISTS(SELECT 1 FROM dbo.HrKQ_AttendanceType WHERE Title='哺乳假' and AttTypeCls=1) 
    BEGIN

        --修复审批流程
        update aa set aa.sptype=-17 
        from dbo.sp aa
        where exists(
           SELECT 1 FROM dbo.HrKQ_AttendanceType at 
           WHERE at.Title='哺乳假' and at.AttTypeCls=1 and aa.sptype=at.OnlyID
        ) and aa.gate2=8 and aa.sptype<>-1

        update aa set aa.sptype=-17 
        from dbo.sp_ApprovalRules aa
        where exists(
           SELECT 1 FROM dbo.HrKQ_AttendanceType at 
           WHERE at.Title='哺乳假' and at.AttTypeCls=1 and aa.sptype=at.OnlyID
        ) and aa.gate2=8 and aa.sptype<>-1

        update aa set aa.ApplyType=-17 
        from dbo.HrKQ_AttendanceApply aa
        where exists(
           SELECT 1 FROM dbo.HrKQ_AttendanceType at 
           WHERE at.Title='哺乳假' and at.AttTypeCls=1 and aa.ApplyType=at.OnlyID
        )
        update dbo.HrKQ_AttendanceType set OnlyID=-17,isUpdate=0,Unit=2,IsAlloweRest=0,isClock=0,showIndex=5,Status=1
        where Title='哺乳假' and AttTypeCls=1
    End else
    BEGIN
        INSERT INTO dbo.HrKQ_AttendanceType(OnlyID,Title,Unit,isContainHoliday,isRelatedWage,isAlloweRest,isAllowApply,TermofValidity ,[Status],isUpdate,CreateId ,CreateDate,isClock,AttTypeCls,showIndex) 
        VALUES (-17,'哺乳假',2 ,1 , 1 , 0 , 1 ,0 , 1 ,0 ,0,GETDATE(),0,1,5);
    end
    --丧假
    IF EXISTS(SELECT 1 FROM dbo.HrKQ_AttendanceType WHERE Title='丧假' and AttTypeCls=1) 
    BEGIN

        --修复审批流程
        update aa set aa.sptype=-15 
        from dbo.sp aa
        where exists(
           SELECT 1 FROM dbo.HrKQ_AttendanceType at 
           WHERE at.Title='丧假' and at.AttTypeCls=1 and aa.sptype=at.OnlyID
        ) and aa.gate2=8 and aa.sptype<>-1

        update aa set aa.sptype=-15 
        from dbo.sp_ApprovalRules aa
        where exists(
           SELECT 1 FROM dbo.HrKQ_AttendanceType at 
           WHERE at.Title='丧假' and at.AttTypeCls=1 and aa.sptype=at.OnlyID
        ) and aa.gate2=8 and aa.sptype<>-1

        update aa set aa.ApplyType=-15 
        from dbo.HrKQ_AttendanceApply aa
        where exists(
           SELECT 1 FROM dbo.HrKQ_AttendanceType at 
           WHERE at.Title='丧假' and at.AttTypeCls=1 and aa.ApplyType=at.OnlyID
        )
        update dbo.HrKQ_AttendanceType set OnlyID=-15,isUpdate=0,Unit=0,IsAlloweRest=0,isClock=0,Personalization='{"FixedLimitDay":3}',showIndex=3,Status=1
        where Title='丧假' and AttTypeCls=1
    End else
    BEGIN
        INSERT INTO dbo.HrKQ_AttendanceType(OnlyID,Title,Unit,isContainHoliday,isRelatedWage,isAlloweRest,isAllowApply,TermofValidity ,[Status],isUpdate,CreateId ,CreateDate,isClock,AttTypeCls,Personalization,showIndex) 
        VALUES (-15,'丧假',0 ,1 , 1 , 0 , 1 ,0 , 1 ,0 ,0,GETDATE(),0,1,'{"FixedLimitDay":3}',3);
    end
    --事假
    IF EXISTS(SELECT 1 FROM dbo.HrKQ_AttendanceType WHERE Title='事假' and AttTypeCls=1) 
    BEGIN
        --修复审批流程
        update aa set aa.sptype=-13 
        from dbo.sp aa
        where exists(
           SELECT 1 FROM dbo.HrKQ_AttendanceType at 
           WHERE at.Title='事假' and at.AttTypeCls=1 and aa.sptype=at.OnlyID
        ) and aa.gate2=8 and aa.sptype<>-1

        update aa set aa.sptype=-13 
        from dbo.sp_ApprovalRules aa
        where exists(
           SELECT 1 FROM dbo.HrKQ_AttendanceType at 
           WHERE at.Title='事假' and at.AttTypeCls=1 and aa.sptype=at.OnlyID
        ) and aa.gate2=8 and aa.sptype<>-1

        update aa set aa.ApplyType=-13 
        from dbo.HrKQ_AttendanceApply aa
        where exists(
           SELECT 1 FROM dbo.HrKQ_AttendanceType at 
           WHERE at.Title='事假' and at.AttTypeCls=1 and aa.ApplyType=at.OnlyID
        )
        update dbo.HrKQ_AttendanceType set OnlyID=-13,isUpdate=0,Unit=(case when Unit=1 then 0 else Unit end),IsAlloweRest=0,isClock=0,isContainHoliday=0,showIndex=8,Status=1
        where Title='事假' and AttTypeCls=1
    End else
    BEGIN
        INSERT INTO dbo.HrKQ_AttendanceType(OnlyID,Title,Unit,isContainHoliday,isRelatedWage,isAlloweRest,isAllowApply,TermofValidity ,[Status],isUpdate,CreateId ,CreateDate,isClock,AttTypeCls,showIndex) 
        VALUES (-13,'事假',0 ,0 , 1 , 0 , 1 ,0 , 1 ,0 ,0,GETDATE(),0,1,8);
    end
    
     --病假
    IF EXISTS(SELECT 1 FROM dbo.HrKQ_AttendanceType WHERE Title='病假' and AttTypeCls=1) 
    BEGIN

        --修复审批流程
        update aa set aa.sptype=-20 
        from dbo.sp aa
        where exists(
           SELECT 1 FROM dbo.HrKQ_AttendanceType at 
           WHERE at.Title='病假' and at.AttTypeCls=1 and aa.sptype=at.OnlyID
        ) and aa.gate2=8 and aa.sptype<>-1

        update aa set aa.sptype=-20 
        from dbo.sp_ApprovalRules aa
        where exists(
           SELECT 1 FROM dbo.HrKQ_AttendanceType at 
           WHERE at.Title='病假' and at.AttTypeCls=1 and aa.sptype=at.OnlyID
        ) and aa.gate2=8 and aa.sptype<>-1

        update aa set aa.ApplyType=-20 
        from dbo.HrKQ_AttendanceApply aa
        where exists(
           SELECT 1 FROM dbo.HrKQ_AttendanceType at 
           WHERE at.Title='病假' and at.AttTypeCls=1 and aa.ApplyType=at.OnlyID
        )
        update dbo.HrKQ_AttendanceType set OnlyID=-20,isUpdate=0,Unit=(case when Unit=1 then 0 else Unit end),IsAlloweRest=0,isClock=0,isContainHoliday=0,showIndex=9,Status=1
        where Title='病假' and AttTypeCls=1
    End else
    BEGIN
        INSERT INTO dbo.HrKQ_AttendanceType(OnlyID,Title,Unit,isContainHoliday,isRelatedWage,isAlloweRest,isAllowApply,TermofValidity ,[Status],isUpdate,CreateId ,CreateDate,isClock,AttTypeCls,showIndex) 
        VALUES (-20,'病假',0 ,0 , 1 , 0 , 1 ,0 , 1 ,0 ,0,GETDATE(),0,1,9);
    end
    
    --加班
    IF EXISTS(SELECT 1 FROM dbo.HrKQ_AttendanceType WHERE OnlyID=11) 
    BEGIN
        update dbo.HrKQ_AttendanceType set AttTypeCls=2,isUpdate=0,isClock=0,Unit= (case when Unit=1 then 0 else Unit end)
        ,Personalization='{"MinWorkUnit":2,"DayToHours":8,"ValidRule":0,"ClockInRange":0,"RestRule":0,"RestTimeRanges":[{"RowIndexNum":0,"StartTime":"12:00:00","EndTime":"13:00:00"}],"RestEachHour":0,"RestOffsetHour":0,"ExchangeOpen":true,"ExchangeBL":1,"ExchangeInvalidType":0,"ExchangeInvalidYearDate":{"Month":12,"Day":31},"ExchangeInvalidMonthDay":31,"ExchangeInvalidOffsetDay":0,"OverTimeReminds":[{"RowIndexNum":0,"RemindUnit":2,"RemindLimit":36}]}'
        ,showIndex=12,Status=1
        where OnlyID=11
    End else
    BEGIN
        INSERT INTO dbo.HrKQ_AttendanceType(OnlyID,Title,Unit,isContainHoliday,isRelatedWage,isAlloweRest,isAllowApply,TermofValidity ,[Status],isUpdate,CreateId ,CreateDate,isClock,AttTypeCls,Personalization,showIndex) 
        VALUES (11,'加班',0 ,1 , 1 , 1 , 1 ,0 , 1 ,0 ,0,GETDATE(),0,2,'{"MinWorkUnit":2,"DayToHours":8,"ValidRule":0,"ClockInRange":0,"RestRule":0,"RestTimeRanges":[{"RowIndexNum":0,"StartTime":"12:00:00","EndTime":"13:00:00"}],"RestEachHour":0,"RestOffsetHour":0,"ExchangeOpen":true,"ExchangeBL":1,"ExchangeInvalidType":0,"ExchangeInvalidYearDate":{"Month":12,"Day":31},"ExchangeInvalidMonthDay":31,"ExchangeInvalidOffsetDay":0,"OverTimeReminds":[{"RowIndexNum":0,"RemindUnit":2,"RemindLimit":36}]}',12);
    end
    
    --调休
    IF EXISTS(SELECT 1 FROM dbo.HrKQ_AttendanceType WHERE OnlyID=10) 
    BEGIN
        update dbo.HrKQ_AttendanceType set AttTypeCls=1,isUpdate=0,Unit=(case when Unit=1 then 0 else Unit end),IsAlloweRest=0,isClock=0,isContainHoliday=0,isRelatedWage=0,showIndex=10,Status=1
        where OnlyID=10
    End else
    BEGIN
        INSERT INTO dbo.HrKQ_AttendanceType(OnlyID,Title,Unit,isContainHoliday,isRelatedWage,isAlloweRest,isAllowApply,TermofValidity ,[Status],isUpdate,CreateId ,CreateDate,isClock,AttTypeCls,showIndex) 
        VALUES (10,'调休',0 ,0 , 0 , 0 , 1 ,0 , 1 ,0 ,0,GETDATE(),0,1,10);
    end
    --外勤
    IF EXISTS(SELECT 1 FROM dbo.HrKQ_AttendanceType WHERE Title='外勤' and AttTypeCls=3) 
    BEGIN
        
        --修复审批流程
        update aa set aa.sptype=-21
        from dbo.sp aa
        where exists(
           SELECT 1 FROM dbo.HrKQ_AttendanceType at 
           WHERE at.Title='外勤' and at.AttTypeCls=1 and aa.sptype=at.OnlyID
        ) and aa.gate2=8 and aa.sptype<>-1

        update aa set aa.sptype=-21
        from dbo.sp_ApprovalRules aa
        where exists(
           SELECT 1 FROM dbo.HrKQ_AttendanceType at 
           WHERE at.Title='外勤' and at.AttTypeCls=1 and aa.sptype=at.OnlyID
        ) and aa.gate2=8 and aa.sptype<>-1

        update aa set aa.ApplyType=-21 
        from dbo.HrKQ_AttendanceApply aa
        where exists(
           SELECT 1 FROM dbo.HrKQ_AttendanceType at 
           WHERE at.Title='外勤' and at.AttTypeCls=3 and aa.ApplyType=at.OnlyID
        )
        update dbo.HrKQ_AttendanceType set OnlyID=-21,isUpdate=0,Unit=(case when Unit=1 then 0 else Unit end)
        ,IsAlloweRest=0,isContainHoliday=0,showIndex=11,Status=1
        where Title='外勤' and AttTypeCls=3
    End else
    BEGIN
        INSERT INTO dbo.HrKQ_AttendanceType(OnlyID,Title,Unit,isContainHoliday,isRelatedWage,isAlloweRest,isAllowApply,TermofValidity ,[Status],isUpdate,CreateId ,CreateDate,isClock,AttTypeCls,showIndex) 
        VALUES (-21,'外勤',0 ,0 ,1, 0 , 1 ,0 , 1 ,0 ,0,GETDATE(),0,3,11);
    end
     --自动加班
    IF EXISTS(SELECT 1 FROM dbo.HrKQ_AttendanceType WHERE Title='自动加班' and AttTypeCls=2) 
    BEGIN
        --修复审批流程
        update aa set aa.sptype=-29
        from dbo.sp aa
        where exists(
           SELECT 1 FROM dbo.HrKQ_AttendanceType at 
           WHERE at.Title='自动加班' and at.AttTypeCls=1 and aa.sptype=at.OnlyID
        ) and aa.gate2=8 and aa.sptype<>-1

        update aa set aa.sptype=-29
        from dbo.sp_ApprovalRules aa
        where exists(
           SELECT 1 FROM dbo.HrKQ_AttendanceType at 
           WHERE at.Title='自动加班' and at.AttTypeCls=1 and aa.sptype=at.OnlyID
        ) and aa.gate2=8 and aa.sptype<>-1
 
        update aa set aa.ApplyType=-29 
        from dbo.HrKQ_AttendanceApply aa
        where exists(
           SELECT 1 FROM dbo.HrKQ_AttendanceType at 
           WHERE at.Title='自动加班' and at.AttTypeCls=2 and aa.ApplyType=at.OnlyID
        )
        update dbo.HrKQ_AttendanceType set OnlyID=-29,isUpdate=0,Unit=(case when Unit=1 then 2 else Unit end)
        ,IsAlloweRest=0,isContainHoliday=0,isRelatedWage=1,isAllowApply=0,showIndex=999999,Status=1
        where Title='自动加班' and AttTypeCls=2
    End else
    BEGIN
        INSERT INTO dbo.HrKQ_AttendanceType(OnlyID,Title,Unit,isContainHoliday,isRelatedWage,isAlloweRest,isAllowApply,TermofValidity ,[Status],isUpdate,CreateId ,CreateDate,isClock,AttTypeCls,showIndex) 
        VALUES (-29,'自动加班',2 ,0 ,1, 0 , 0 ,0 , 1 ,0 ,0,GETDATE(),0,2,9999999);
    end
    
    --处理排序字段
    update att set att.showIndex=tt.rowindx
    from dbo.HrKQ_AttendanceType att
    inner join (select at.ID,(12+(ROW_NUMBER() OVER (ORDER BY at.IsUpdate asc,at.CreateDate desc))) as rowindx
               from dbo.HrKQ_AttendanceType at
               where isnull(at.showIndex,999999)>12) tt on tt.ID=att.ID

    --处理考勤时段
     update aa set aa.AppealBeginDate=(CONVERT(varchar(100),aa.[Day], 23)+' '+SUBSTRING(aa.ShouldTime,0,9))
                                        ,aa.AppealEndDate=(CONVERT(varchar(100),aa.[Day], 23)+' '+SUBSTRING(aa.ShouldTime,10,20))
                                        from dbo.HrKQ_AttendanceAppeal aa
                                        where len(isnull(aa.ShouldTime,''))=17
                                        and SUBSTRING(aa.ShouldTime,9,1)='-' 
                                        and aa.AppealBeginDate is not null
     --处理加班(含自定义加班)调休有效期处理
      update dbo.HrKQ_AttendanceType 
      set Personalization='{"MinWorkUnit":2,"DayToHours":8,"ValidRule":0,"ClockInRange":0,"RestRule":0,"RestTimeRanges":[{"RowIndexNum":0,"StartTime":"12:00:00","EndTime":"13:00:00"}],"RestEachHour":0,"RestOffsetHour":0,"ExchangeOpen":true,"ExchangeBL":1,"ExchangeInvalidType":2,"ExchangeInvalidYearDate":{"Month":12,"Day":31},"ExchangeInvalidMonthDay":31,"ExchangeInvalidOffsetDay":'+ cast(TermofValidity as nvarchar(20))+',"OverTimeReminds":[{"RowIndexNum":0,"RemindUnit":2,"RemindLimit":36}]}' 
      where IsAlloweRest=1 and AttTypeCls=2
     --插入是执行过数据标记
    insert into dbo.home_usConfig(name,nvalue,uid)values('OldDataAttendanceTypeTask6248',1,0)
END

--处理正常类型
update dbo.HrKQ_AttendanceType set Unit=0 where OnlyID=1 and Unit!=0
--处理旷工类型
update dbo.HrKQ_AttendanceType set Unit=2 where OnlyID=6 and Unit!=2

GO
 --加班员工关怀消息提醒
if(not exists(select 1 from dbo.setjm where ord=225))
begin
	insert into dbo.setjm(ord,intro,num1,tq1,fw1,cateid,subCfgId)
	select 225,1,4,0,0,ord,0 from dbo.gate
end
GO
--考勤策略默认设置
if not exists(select top 1 1 from dbo.home_usConfig where name='AttendanceAppealNum')
begin
	insert into home_usConfig (name, nvalue, uid) values ('AttendanceAppealNum', 5, 0)
    insert into home_usConfig (name, nvalue, uid) values ('AttendanceAppealValidity', 30, 0)
end
GO
--隐藏不存在的试用数据库账套
declare @DBName NVarchar(100)
set @DBName =  replace(replace('[@@SQLDBName]','[',''), ']', '')
if  charindex('DB', @DBName)=1 and  charindex('I', @DBName)=11 and   isnumeric(replace(replace(@DBName,'DB',''),'I',''))  =1
begin
	set @DBName  =  replace(left(@DBName,10),'DB000','')
	set @DBName  =  replace(@DBName,'DB00','')
	set @DBName  =  replace(@DBName,'DB0','')
	set @DBName  =  replace(@DBName,'DB','')
	if isnumeric(@DBName)=1   and len(@DBName)>4
	begin  
		update  x set x.del=2 from AccountSys  x
		where x.del=1 
		and  not exists (
			select 1 from sys.databases where name like 'ZB_FinanDB' + @DBName + '_%' + right( '0000' + cast(x.ord as varchar(12)),4)
		)
	end
end

GO
--考勤分组(处理老数据),有人员分组且没有入组/出组时间
if exists(select top 1 1 from HrKQ_PersonGroup) and not exists(select top 1 1 from HrKQ_PersonGroupDate)
begin
	--有人员分组为全部人员
	if exists(select top 1 1 from HrKQ_PersonGroup where RangeType = 0)
	begin
		--人员分组为所有人员的情况下记录全部人员入组时间为入职时间
		insert into HrKQ_PersonGroupDate(GroupID,UserID,BeginDate)
		select x.ID,y.userID,isnull(y.Entrydate,indate) from HrKQ_PersonGroup x
		inner join hr_person y on x.RangeType = 0 and y.del = 0
	end
	else 
		--人员分组为部分人员的情况下记录人员入组时间为入职时间
		insert into HrKQ_PersonGroupDate(GroupID,UserID,BeginDate)
		select x.ID,y.userID,isnull(y.Entrydate,indate) from HrKQ_PersonGroup x
		inner join hr_person y on x.RangeType = 1 and dbo.existsPower2(cast(x.Range as varchar(max)),cast(y.UserID as varchar(20)),',') = 1
end 

GO

--考勤升级31.95处理打卡时段(老数据)最早签到打卡及最晚签退打卡默认必打卡
if not exists(select top 1 1 from dbo.home_usConfig where name='SetClockDetailListNeedClockDefaultValue')
begin
	select * into #tempDetailList from (
		select 
			x.ID,
			DateAdd(dd,x.StartInterDay,CAST(x.SignTime as datetime)) SignTime,
			DateAdd(dd,x.EndInterDay,CAST(x.SignOutTime as datetime)) SignOutTime,
			DetailID,
			z.CreateDate
		from HrKQ_ClockDetailList x
		inner join HrKQ_TimeArrangeDetail y on x.DetailID = y.ID
		inner join HrKQ_TimeArrangeSetting z on z.ID = y.SettingID
	) t
	order by t.CreateDate,SignTime

	declare @detailID int
	declare @detailListIDMin int
	declare @detailListIDMax int
	while (exists(select top 1 1 from #tempDetailList))
	begin
		select top 1 
			@detailID = DetailID,
			@detailListIDMin = ID 
		from #tempDetailList
		
		select top 1 
			@detailListIDMax = ID
		from #tempDetailList
		where DetailID = @detailID
		order by SignTime desc
		
		update HrKQ_ClockDetailList set StartNeedClock = 1 where ID = @detailListIDMin
		update HrKQ_ClockDetailList set EndNeedClock = 1 where ID = @detailListIDMax
		
		delete #tempDetailList where DetailID = @detailID
	end

	drop table #tempDetailList
	
	insert into home_usConfig (name, nvalue, uid) values ('SetClockDetailListNeedClockDefaultValue', 1, 0)
end

GO

--考勤升级31.95处理打卡时段(老数据)中间免打卡设置中间时段前后打卡默认值
if not exists(select top 1 1 from dbo.home_usConfig where name='SetClockDetailListNoClockDefaultValue')
begin
	select * into #tempDetailList from (
		select 
			x.ID,
			DateAdd(dd,x.StartInterDay,CAST(x.SignTime as datetime)) SignTime,
			DateAdd(dd,x.EndInterDay,CAST(x.SignOutTime as datetime)) SignOutTime,
			DetailID,
			y.SettingID,
			z.CreateDate
		from HrKQ_ClockDetailList x
		inner join HrKQ_TimeArrangeDetail y on x.DetailID = y.ID
		inner join HrKQ_TimeArrangeSetting z on z.ID = y.SettingID
		where y.NoClock = 0
	) t
	order by t.CreateDate,SignTime

	declare @detailID int
	declare @detailListIDMin int
	declare @detailListIDMax int
	declare @settingID int
	while (exists(select top 1 1 from #tempDetailList))
	begin
		select top 1 
			@detailID = DetailID,
			@detailListIDMin = ID,
			@settingID = SettingID 
		from #tempDetailList
		
		select top 1 
			@detailListIDMax = ID
		from #tempDetailList
		where DetailID = @detailID
		order by SignTime desc
		
		update HrKQ_ClockDetailList set EndNeedClock = 1 where ID = @detailListIDMin
		update HrKQ_ClockDetailList set StartNeedClock = 1 where ID = @detailListIDMax
		update HrKQ_ClockDetailList set EndNeedClock = 1,StartNeedClock = 1 where ID not in(@detailListIDMax,@detailListIDMax) and SettingID = @settingID
		
		delete #tempDetailList where SettingID = @settingID
	end

	drop table #tempDetailList
	
	insert into home_usConfig (name, nvalue, uid) values ('SetClockDetailListNoClockDefaultValue', 1, 0)
end

GO

if not exists(select 1 from home_usConfig where name='CGMainUnitTactics' and isnull(uid,0)=0) Insert Into home_usConfig(nvalue,name,uid) values(1,'CGMainUnitTactics',0)

GO

if not exists(select intro from setopen where sort1=2018030701) insert into setopen(intro,sort1)values(2,2018030701)

GO

--转采购历史数据关系维护处理3196
if not exists(select top 1 1 from dbo.home_usConfig where name='ToCaiGouHistoryDataRelationHandle')
begin
	--修复caigoulist_mx中fromunit是空值的记录
	UPDATE mx SET mx.fromUnit=ISNULL((
		CASE mx.fromType 
			WHEN 1 THEN (CASE WHEN chl.unit=mx.unit THEN mx.unit ELSE chl.unit END)
			WHEN 2 THEN (CASE WHEN ctl.unit=mx.unit THEN mx.unit ELSE ctl.unit END)
			WHEN 3 THEN (CASE WHEN xjl.unit=mx.unit THEN mx.unit ELSE xjl.unit END)
			WHEN 4 THEN (CASE WHEN ygl.unit=mx.unit THEN mx.unit ELSE ygl.unit END)
		END),0),  mx.fromNum=ISNULL((
		CASE mx.fromType 
			WHEN 1 THEN (CASE WHEN mx.unit=chl.unit AND mx.num1<=chl.num1 THEN mx.num1 ELSE ISNULL(chl.num1,mx.num1) END)
			WHEN 2 THEN (CASE WHEN mx.unit=ctl.unit AND mx.num1<=ctl.num1 THEN mx.num1 ELSE ISNULL(ctl.num1,mx.num1) END)
			WHEN 3 THEN (CASE WHEN mx.unit=xjl.unit AND mx.num1<=xjl.num1 THEN mx.num1 ELSE ISNULL(xjl.num1,mx.num1) END) 
			WHEN 4 THEN (CASE WHEN mx.unit=ygl.unit AND mx.num1<=ygl.num1 THEN mx.num1 ELSE ISNULL(ygl.num1,mx.num1) END)
		END),0)
	FROM caigoulist_mx mx
	LEFT JOIN chancelist chl ON mx.fromType=1 AND chl.id=mx.fromid
	LEFT JOIN contractlist ctl ON mx.fromType=2 AND ctl.id=mx.fromid
	LEFT JOIN xunjialist xjl ON mx.fromType=3 AND xjl.id=mx.fromid
	LEFT JOIN caigoulist_yg ygl ON mx.fromType=5 AND ygl.id=mx.fromid
	WHERE ISNULL(mx.fromUnit,0)=0 AND (
		(mx.fromType=1 AND chl.id=mx.fromid)
		OR (mx.fromType=2 AND ctl.id=mx.fromid AND ctl.unit=mx.unit)
		OR (mx.fromType=3 AND xjl.id=mx.fromid AND xjl.unit=mx.unit)
		OR (mx.fromType=5 AND ygl.id=mx.fromid AND ygl.unit=mx.unit)
	)

    --比例维护
    update cgl set cgl.bl=case when r1.bl=0 then 0 else r2.bl/r1.bl end
    from caigoulist_mx cgl
    inner join erp_comm_unitRelation r1 on r1.ord = cgl.ord and r1.unit = cgl.unit
    inner join erp_comm_unitRelation r2 on r2.ord = cgl.ord and r2.unit = cgl.fromUnit 
    where cgl.bl is null

    --采购来源关系维护
    update cgl set cgl.fromunit = case when cgl.chancelist>0 then chl.unit 
				WHEN cgl.contractlist>0 then  ctl.unit 
				WHEN cgl.xunjialist>0 then xjl.unit 
				WHEN cgl.caigoulist_yg>0 then cyl.unit else 0 end, 
        cgl.fromnum = (CASE 
			WHEN cgl.chancelist>0 then (CASE WHEN cgl.unit=chl.unit AND cgl.num1<=chl.num1 THEN cgl.num1 ELSE ISNULL(chl.num1,cgl.num1) END) 
			WHEN cgl.contractlist>0 then  (CASE WHEN cgl.unit=ctl.unit AND cgl.num1<=ctl.num1 THEN cgl.num1 ELSE ISNULL(ctl.num1,cgl.num1) END)
			WHEN cgl.xunjialist>0 then (CASE WHEN cgl.unit=xjl.unit AND cgl.num1<=xjl.num1 THEN cgl.num1 ELSE ISNULL(xjl.num1,cgl.num1) END) 
			WHEN cgl.caigoulist_yg>0 then (CASE WHEN cgl.unit=cyl.unit AND cgl.num1<=cyl.num1 THEN cgl.num1 ELSE ISNULL(cyl.num1,cgl.num1) END) 
			ELSE 0 END)
    from caigoulist cgl WITH(NOLOCK)
	INNER JOIN caigou cg WITH(NOLOCK) ON cgl.caigou=cg.ord AND cg.del IN(1,2,3) AND ISNULL(cg.sp,0)>=0
    left join chancelist chl WITH(NOLOCK) on chl.id = cgl.chancelist
    left join contractlist ctl WITH(NOLOCK) on ctl.id = cgl.contractlist
    left join xunjialist xjl WITH(NOLOCK) on xjl.id = cgl.xunjialist
    left join caigoulist_yg cyl WITH(NOLOCK) on cyl.id = cgl.caigoulist_yg
    where isnull(cgl.fromUnit,0)=0 and (cgl.chancelist>0 OR cgl.contractlist>0 OR cgl.xunjialist>0 OR cgl.caigoulist_yg>0)
		AND NOT EXISTS(
			SELECT caigoulist FROM caigoulist_mx WITH(NOLOCK) 
			WHERE fromtype=(CASE WHEN cgl.chancelist>0 THEN 1 
							WHEN cgl.contractlist>0 THEN 2 
							WHEN cgl.xunjialist>0 THEN 3 
							WHEN cgl.caigoulist_yg>0 THEN 5 END) 
				AND del=(CASE WHEN cgl.del IN(1,3) THEN 1 WHEN cgl.del=2 THEN 2 END) and caigoulist=cgl.id
		)
		
    --转采购历史关系
    INSERT INTO caigoulist_mx(ord,fromType,fromBillId,fromid,caigou,caigoulist,unit,num1,bl,fromUnit,fromNum,addcate,date7,del)
    SELECT cgl.ord,1 fromType ,ygl.chance fromBillId ,cgl.chancelist fromid ,cgl.caigou,cgl.id caigoulist,cgl.unit,cgl.num1, 
        case when r1.bl=0 then  0 else r2.bl/r1.bl end bl,cgl.fromUnit,cgl.fromNum, cg.addcate , cg.date7 ,
        (CASE WHEN cgl.del IN(1,3) THEN 1 WHEN cgl.del=2 THEN 2 END) del
    FROM caigoulist cgl WITH(NOLOCK) 
    INNER JOIN caigou cg WITH(NOLOCK) ON cgl.caigou=cg.ord AND cg.del IN(1,2,3) AND  ISNULL(cg.sp,0)>=0 AND cgl.chancelist>0
	    AND NOT EXISTS(SELECT caigoulist FROM caigoulist_mx WITH(NOLOCK) where fromtype=1 and del=(CASE WHEN cgl.del IN(1,3) THEN 1 WHEN cgl.del=2 THEN 2 END) and caigoulist=cgl.id)
    inner join chancelist ygl WITH(NOLOCK) on ygl.id = cgl.chancelist
    inner join erp_comm_unitRelation r1 on r1.ord = cgl.ord and r1.unit = cgl.unit
    inner join erp_comm_unitRelation r2 on r2.ord = cgl.ord and r2.unit = cgl.fromUnit
    union all
    SELECT cgl.ord,2 fromType ,ygl.contract fromBillId ,cgl.contractlist fromid ,cgl.caigou,cgl.id caigoulist,cgl.unit,cgl.num1, 
        case when r1.bl=0 then  0 else r2.bl/r1.bl end bl,cgl.fromUnit,cgl.fromNum, cg.addcate , cg.date7 ,
        (CASE WHEN cgl.del IN(1,3) THEN 1 WHEN cgl.del=2 THEN 2 END) del
    FROM caigoulist cgl WITH(NOLOCK) 
    INNER JOIN caigou cg WITH(NOLOCK) ON cgl.caigou=cg.ord AND cg.del IN(1,2,3) AND  ISNULL(cg.sp,0)>=0 AND cgl.contractlist>0
	    AND NOT EXISTS(SELECT caigoulist FROM caigoulist_mx WITH(NOLOCK) where fromtype=2 and del=(CASE WHEN cgl.del IN(1,3) THEN 1 WHEN cgl.del=2 THEN 2 END) and caigoulist=cgl.id)
    inner join contractlist ygl WITH(NOLOCK) on ygl.id = cgl.contractlist
    inner join erp_comm_unitRelation r1 on r1.ord = cgl.ord and r1.unit = cgl.unit
    inner join erp_comm_unitRelation r2 on r2.ord = cgl.ord and r2.unit = cgl.fromUnit
    union all
    SELECT cgl.ord,3 fromType ,ygl.xunjia fromBillId ,cgl.xunjialist fromid ,cgl.caigou,cgl.id caigoulist,cgl.unit,cgl.num1, 
        case when r1.bl=0 then  0 else r2.bl/r1.bl end bl,cgl.fromUnit,cgl.fromNum, cg.addcate , cg.date7 ,
        (CASE WHEN cgl.del IN(1,3) THEN 1 WHEN cgl.del=2 THEN 2 END) del
    FROM caigoulist cgl WITH(NOLOCK) 
    INNER JOIN caigou cg WITH(NOLOCK) ON cgl.caigou=cg.ord AND cg.del IN(1,2,3) AND  ISNULL(cg.sp,0)>=0 AND cgl.xunjialist>0
	    AND NOT EXISTS(SELECT caigoulist FROM caigoulist_mx WITH(NOLOCK) where fromtype=3 and del=(CASE WHEN cgl.del IN(1,3) THEN 1 WHEN cgl.del=2 THEN 2 END) and caigoulist=cgl.id)
    inner join xunjialist ygl WITH(NOLOCK) on ygl.id = cgl.xunjialist
    inner join erp_comm_unitRelation r1 on r1.ord = cgl.ord and r1.unit = cgl.unit
    inner join erp_comm_unitRelation r2 on r2.ord = cgl.ord and r2.unit = cgl.fromUnit
    union all 
    SELECT cgl.ord,5 fromType ,ygl.caigou fromBillId ,cgl.caigoulist_yg fromid ,cgl.caigou,cgl.id caigoulist,cgl.unit,cgl.num1, 
        case when r1.bl=0 then  0 else r2.bl/r1.bl end bl,cgl.fromUnit,cgl.fromNum, cg.addcate , cg.date7 ,
        (CASE WHEN cgl.del IN(1,3) THEN 1 WHEN cgl.del=2 THEN 2 END) del
    FROM caigoulist cgl WITH(NOLOCK) 
    INNER JOIN caigou cg WITH(NOLOCK) ON cgl.caigou=cg.ord AND cg.del IN(1,2,3) AND  ISNULL(cg.sp,0)>=0 AND cgl.caigoulist_yg>0
	    AND NOT EXISTS(SELECT caigoulist FROM caigoulist_mx WITH(NOLOCK) where fromtype=5 and del=(CASE WHEN cgl.del IN(1,3) THEN 1 WHEN cgl.del=2 THEN 2 END) and caigoulist=cgl.id)
    inner join caigoulist_yg ygl WITH(NOLOCK) on ygl.id = cgl.caigoulist_yg
    inner join erp_comm_unitRelation r1 on r1.ord = cgl.ord and r1.unit = cgl.unit
    inner join erp_comm_unitRelation r2 on r2.ord = cgl.ord and r2.unit = cgl.fromUnit
    --合并更新明细的来源单位和数量
    update a set a.fromunit = b.fromunit , a.fromnum = b.fromnum
    from caigoulist a
    inner join (select caigoulist, fromunit , sum(fromnum) fromnum from  caigoulist_mx group by caigoulist, fromunit ) b on b.caigoulist = a.id
    where a.fromunit is null

    insert into home_usConfig (name, nvalue, uid) values ('ToCaiGouHistoryDataRelationHandle', 1, 0)
end

GO

--物料清单草稿箱处理分类数据
UPDATE dbo.sys_sdk_BillTempSaveDatas SET ClassIden = (CASE WHEN CHARINDEX('ParentProID',BillData) > 0 THEN 2 ELSE 1 END) WHERE BillType = 51005 AND ISNULL(ClassIden,0) = 0

GO


--修复考勤申请的审批记录变更 
if exists(SELECT TOP 1 1 from HrKQ_AttendanceApply AA inner join sp_ApprovalInstance AI ON AA.ID=AI.PrimaryKeyID WHERE AI.gate2=8 AND AI.sptype<>AA.ApplyType)
begin
	UPDATE AI SET AI.sptype=AA.ApplyType
    from HrKQ_AttendanceApply AA inner join sp_ApprovalInstance AI ON AA.ID=AI.PrimaryKeyID
    WHERE AI.gate2=8 AND AI.sptype<>AA.ApplyType
end

GO

if not exists(select top 1 1 from dbo.home_usConfig where name='UpdateRepeatExpressCompany')
begin
    --1.整理打通的快递公司，如果内置的快递公司中不存在，则加入到内置的快递公司中
    select * into #tempExpressCompanyData 
    from (
        select '百世快递' as [sort1],1000 as [gate1] ,83 as gate2 ,1 as del,0 as [isStop] ,'HTKY' as [color]
        union 
        select '申通快递',1002 ,83,1,0,'STO'
        union
        select '中通速递',1003,83,1 ,0,'ZTO'
        union
        select '顺丰速运',1004,83,1 ,0,'SF'
        union
        select '德邦物流',1005,83,1 ,0,'DBL'
        union
        select '圆通速递',1006,83,1 ,0,'YTO'
        union
        select '跨越速运',1007,83,1 ,0,'KYSY'
    ) t
    INSERT INTO [dbo].[sortonehy]   ([sort1]   ,[gate1]   ,[gate2]  ,[del]   ,[isStop]  ,[color],  [TagData]) 
    select [sort1]    ,[gate1]  ,[gate2]  ,[del]   ,[isStop]  ,[color], 1 
    from #tempExpressCompanyData a where  not exists(select 1 from dbo.sortonehy t where t.gate2=83  and t.color=a.color and t.del=1 )	  
    update [dbo].[sortonehy] set ord=id where gate2=83 and ord is null
    --2.把内置快递公司中，编码为此7种编码的公司是否打通标志修改为打通
    update x set x.TagData = 1 from  [dbo].[sortonehy]   x inner join  #tempExpressCompanyData y on x.[color]=y.color  and x.gate2=83 and x.TagData is null 

    drop table #tempExpressCompanyData
    --3.内置快递公司中，排除7种编码的公司是否打通标志修改为 否
    update [dbo].[sortonehy] set TagData = 0 where gate2=83 and isnull(color,'')!='' and TagData is null 
    --4.放开内置公司
    if  exists(select 1 from dbo.sortonehy where gate2=83 and del=2 and color not in  ('HTKY','STO','ZTO','SF','DBL','YTO','KYSY') and isnull(color,'')!='')
    begin
      update dbo.sortonehy set del=1 where gate2=83 and del=2 and color not in  ('HTKY','STO','ZTO','SF','DBL','YTO','KYSY') and isnull(color,'')!=''
    end
    --4.内置快递公司会有编码重复，这里都保留最大ID的数据，其余数据逻辑删除
    update b set b.del=2 from (
	    select max(x.id) as maxid ,  x.color from  [dbo].[sortonehy] x where x.gate2=83 and not x.TagData is null and x.del=1
	    group by x.color
    )  a inner join  [dbo].[sortonehy] b on a.color = b.color and b.gate2=83 and a.maxid<>b.id and b.del=1

     --6.按照产品要求把编码重复快递公司名称定制
    update dbo.sortonehy set sort1=sort1+'1' where gate2=83  and isnull(color,'')!='' and del=2
    insert into home_usConfig (name, nvalue, uid) values ('UpdateRepeatExpressCompany', 1, 0)
 end

GO

--3197历史数据处理
if not exists(select top 1 1 from dbo.home_usConfig where name='ToHistoryDataHandle3197')
begin
    --合同明细自定义更新
    if exists(select 1 from sys_sdk_BillFieldInfo where billtype = 11001 and DBName='InheritId_self_moneyBeforeTax')
    begin 
	    update sys_sdk_BillFieldInfo set DBName='InheritId_self_priceAfterTaxPre' where billtype = 11001 and DBName='InheritId_self_priceAfterTax' 
	    update sys_sdk_BillFieldInfo set ShowIndex = 13 where billtype = 11001 and DBName='InheritId_self_moneyAfterTax' 
	    update sys_sdk_BillFieldInfo set Title='明细优惠',ShowIndex = 14 where billtype = 11001 and DBName='InheritId_self_concessions'
	    --新增含税折后单价
	    insert into sys_sdk_BillFieldInfo(ModuleType, BillType,ListType,InheritId,title,dbname,UiType,DbType,ShowIndex,colspan,rowspan,display,IsUsed,cansearch,candc,candr,mustfillin,cantj,defwidth) 
	    select  ModuleType,BillType,ListType,InheritId,'优惠后单价' title,'InheritId_self_priceAfterTax' dbname,UiType,DbType,15 ShowIndex,colspan,rowspan,display,IsUsed,cansearch,candc,candr,mustfillin,cantj,defwidth
	    from sys_sdk_BillFieldInfo where billtype = 11001 and  DBName='InheritId_self_priceAfterTaxPre'

	    update sys_sdk_BillFieldInfo set Title='金额',DBName='InheritId_self_moneyAfterConcessions',ShowIndex = 16 where billtype = 11001 and DBName='InheritId_self_moneyBeforeTax'	
	    update sys_sdk_BillFieldInfo set ShowIndex = 17 where billtype = 11001 and DBName='InheritId_self_taxValue'
	    update sys_sdk_BillFieldInfo set Title='优惠后总价',ShowIndex = 17 where billtype = 11001 and DBName='InheritId_self_money1'
    end 
    --合同数据处理 税前总额 , 含税折后单价
	update contractlist set moneyAfterConcessions = moneyBeforeTax ,PriceAfterTaxPre = priceAfterTax
    --合同修改记录数据处理 税前总额 , 含税折后单价
	update contractlist_his set moneyAfterConcessions = moneyBeforeTax ,PriceAfterTaxPre = priceAfterTax
    --给payback表增加币种同步合同
    update p set p.bz = isnull(isnull(c.bz,p.Qc_bz),14)
    from payback p 
    left join contract c on c.ord = p.contract
    --更新实收提醒
    update reminderQueue set orderId=-orderId where reminderConfig = 18
    --历史开票计划方式 由3种变4种 
	update setopen set intro = case intro when 3 then 12 when 5 then 14 when 6 then 24 when 7 then 124 else intro end  where sort1=99
    
    insert into home_usConfig (name, nvalue, uid) values ('ToHistoryDataHandle3197', 1, 0)
end

if not exists(select top 1 1 from dbo.home_usConfig where name='synchronizationDataTocaigouthlist')
begin
	--处理采购退货明细自定义顺序
	update zdymx set gate1=1 where sort1=75 and sorce=1 --产品名称
	update zdymx set gate1=2 where sort1=75 and sorce=2 --编号
	update zdymx set gate1=3 where sort1=75 and sorce=3 --型号
	update zdymx set gate1=4 where sort1=75 and sorce=4 --单位
	update zdymx set gate1=5 where sort1=75 and sorce=6 --数量
	update zdymx set gate1=6 where sort1=75 and sorce=22 --单价
	update zdymx set gate1=7 where sort1=75 and sorce=20 --票据类型
	update zdymx set gate1=8 where sort1=75 and sorce=21 --税率
	update zdymx set gate1=9 where sort1=75 and sorce=5 --含税单价
	update zdymx set gate1=10 where sort1=75 and sorce=23 --金额
	update zdymx set gate1=11 where sort1=75 and sorce=24 --税额
	update zdymx set gate1=12 where sort1=75 and sorce=7 --总价
	update zdymx set gate1=13,title='到货日期' where sort1=75 and sorce=12 --交货日期
	update zdymx set gate1=14 where sort1=75 and sorce=8 --批号
	update zdymx set gate1=15 where sort1=75 and sorce=9 --序列号
	update zdymx set gate1=16 where sort1=75 and sorce=11 --有效日期
	update zdymx set gate1=17 where sort1=75 and sorce=10 --生产日期
	update zdymx set gate1=18 where sort1=75 and sorce=25 --关联采购
	update zdymx set gate1=19 where sort1=75 and sorce=26 --采购人员
	update zdymx set gate1=20 where sort1=75 and sorce=27 --采购日期
	update zdymx set gate1=21 where sort1=75 and sorce=13 --备注
	update zdymx set gate1=22 where sort1=75 and sorce=14 --自定义1
	update zdymx set gate1=23 where sort1=75 and sorce=15 --自定义2
	update zdymx set gate1=24 where sort1=75 and sorce=16 --自定义3
	update zdymx set gate1=25 where sort1=75 and sorce=17 --自定义4
	update zdymx set gate1=26 where sort1=75 and sorce=18 --自定义5
	update zdymx set gate1=27 where sort1=75 and sorce=19 --自定义6  

	--处理首页工作台老地址
	UPDATE home_mainlink_config SET url='sys:../../SYSN/view/store/caigouth/purchasereturnlist.ashx' WHERE url='sys:../caigouth/planlist.asp';

	--更新开票打印怀旧版打印字段
	UPDATE contract_out SET A1=REPLACE(REPLACE(REPLACE(REPLACE(CAST(A1 AS nvarchar(MAX)),'kp_actual_money','kp_plan_money'),'kp_actual_cnmoney','kp_plan_cnmoney'),'金额合计（大写）','计划开票金额（大写）'),'金额合计（小写）','计划开票金额（小写）')
	WHERE sort=16 AND main in (1,7);

    insert into home_usConfig (name, nvalue, uid) values ('synchronizationDataTocaigouthlist', 1, 0)
end

GO

update p set p.completetype = (case when p.complete = 3 then (case when p.bank>0 then 1 when isnull(p.outSureId,0)>0 then 8 else 2 end) else 0 end)
from payback p where p.CompleteType is null

GO

--凭证约束策略默认
if not exists(select 1 from home_usConfig where name = 'AcceptanceBill_Voucher_Constraint')
begin
    insert into home_usConfig(name, nvalue, uid) values ('AcceptanceBill_Voucher_Constraint', 1, 0)
end

GO
if not exists(select 1 from home_usConfig where name = 'Payback_Invoice_Voucher_Constraint')
begin
    insert into home_usConfig(name, nvalue, uid) values ('Payback_Invoice_Voucher_Constraint', 1, 0)
    insert into home_usConfig(name, nvalue, uid) values ('Payout_Invoice_Voucher_Constraint', 1, 0)
end

GO
if not exists(select 1 from home_usConfig where name = 'Payout2_ContractTH_Voucher_Constraint')
begin
    insert into home_usConfig(name, nvalue, uid) values ('Payout2_ContractTH_Voucher_Constraint', 1, 0)
    insert into home_usConfig(name, nvalue, uid) values ('Payout3_CaigouTH_Voucher_Constraint', 1, 0)
end

GO

--添加打印模板中菜单的链接
if not exists(select top 1 1 from PrintTemplate_Type where ord=74)
	insert into PrintTemplate_Type (id,ord,title,oldurl) values (74,74,'客户对账','../contract/planall_out.asp?sort=74&main=1')
if not exists(select top 1 1 from PrintTemplate_Type where ord=75)
	insert into PrintTemplate_Type (id,ord,title,oldurl) values (75,75,'供应商对账','../contract/planall_out.asp?sort=75&main=1')
if not exists(select top 1 1 from PrintTemplate_Type where ord=76)
	insert into PrintTemplate_Type (id,ord,title,oldurl) values (76,76,'总账','../contract/planall_out.asp?sort=76&main=1')
if not exists(select top 1 1 from PrintTemplate_Type where ord=77)
	insert into PrintTemplate_Type (id,ord,title,oldurl) values (77,77,'明细账','../contract/planall_out.asp?sort=77&main=1')

GO

--添加打印模板的预留数据
if not exists(select top 1 1 from PrintTemplateReserve where Ord=11001)
	INSERT PrintTemplateReserve (Ord, Title, VersionStr, ReData, UserId, UpDateTime) VALUES (11001, '合同预选字段', '202004171643', 'Report_11001', 63, CAST('2020-04-17T16:58:59.670' AS DateTime))
if not exists(select top 1 1 from PrintTemplateReserve where Ord=102)
	INSERT PrintTemplateReserve (Ord, Title, VersionStr, ReData, UserId, UpDateTime) VALUES (102, '设置询价打印模板', '202005121034', 'Report_102', 63, CAST('2020-05-12T10:36:17.487' AS DateTime))
if not exists(select top 1 1 from PrintTemplateReserve where Ord=11)
	INSERT PrintTemplateReserve (Ord, Title, VersionStr, ReData, UserId, UpDateTime) VALUES (11, '二维码打印模板', '202005121034', 'Report_11', 63, CAST('2020-05-12T10:37:34.957' AS DateTime))
if not exists(select top 1 1 from PrintTemplateReserve where Ord=16)
	INSERT PrintTemplateReserve (Ord, Title, VersionStr, ReData, UserId, UpDateTime) VALUES (16, '开票打印模板', '202005121034', 'Report_16', 63, CAST('2020-05-12T10:38:30.887' AS DateTime))
if not exists(select top 1 1 from PrintTemplateReserve where Ord=2)
	INSERT PrintTemplateReserve (Ord, Title, VersionStr, ReData, UserId, UpDateTime) VALUES (2, '报价打印模板', '202005121034', 'Report_2', 63, CAST('2020-05-12T10:39:37.340' AS DateTime))
if not exists(select top 1 1 from PrintTemplateReserve where Ord=2003)
	INSERT PrintTemplateReserve (Ord, Title, VersionStr, ReData, UserId, UpDateTime) VALUES (2003, '产品打印模板', '202005121034', 'Report_2003', 63, CAST('2020-05-12T10:40:41.950' AS DateTime))
if not exists(select top 1 1 from PrintTemplateReserve where Ord=28)
	INSERT PrintTemplateReserve (Ord, Title, VersionStr, ReData, UserId, UpDateTime) VALUES (28, '设置质检打印模板', '202005121034', 'Report_28', 63, CAST('2020-05-12T10:41:50.917' AS DateTime))
if not exists(select top 1 1 from PrintTemplateReserve where Ord=3)
	INSERT PrintTemplateReserve (Ord, Title, VersionStr, ReData, UserId, UpDateTime) VALUES (3, '采购打印模板', '202005121034', 'Report_3', 63, CAST('2020-05-12T10:43:20.693' AS DateTime))
if not exists(select top 1 1 from PrintTemplateReserve where Ord=4)
	INSERT PrintTemplateReserve (Ord, Title, VersionStr, ReData, UserId, UpDateTime) VALUES (4, '发货打印模板', '202005121034', 'Report_4', 63, CAST('2020-05-12T10:44:24.247' AS DateTime))
if not exists(select top 1 1 from PrintTemplateReserve where Ord=44009)
	INSERT PrintTemplateReserve (Ord, Title, VersionStr, ReData, UserId, UpDateTime) VALUES (44009, '付款计划打印模板', '202005121034', 'Report_44009', 63, CAST('2020-05-12T10:45:15.847' AS DateTime))
if not exists(select top 1 1 from PrintTemplateReserve where Ord=43003)
	INSERT PrintTemplateReserve (Ord, Title, VersionStr, ReData, UserId, UpDateTime) VALUES (43003, '收款打印模板', '202005121034', 'Report_43003', 63, CAST('2020-05-12T10:46:22.047' AS DateTime))
if not exists(select top 1 1 from PrintTemplateReserve where Ord=102)
	INSERT PrintTemplateReserve (Ord, Title, VersionStr, ReData, UserId, UpDateTime) VALUES (72001, '设置预购打印模板', '202005121034', 'Report_72001', 63, CAST('2020-05-12T10:47:29.933' AS DateTime))
if not exists(select top 1 1 from PrintTemplateReserve where Ord=74)
	INSERT PrintTemplateReserve (Ord, Title, VersionStr, ReData, UserId, UpDateTime) VALUES (74, '客户对账表打印模板', '202005121034', 'Report_74', 63, CAST('2020-05-12T10:48:28.133' AS DateTime))
if not exists(select top 1 1 from PrintTemplateReserve where Ord=75)
	INSERT PrintTemplateReserve (Ord, Title, VersionStr, ReData, UserId, UpDateTime) VALUES (75, '供应商对账表打印模板', '202005121034', 'Report_75', 63, CAST('2020-05-12T10:49:20.673' AS DateTime))
if not exists(select top 1 1 from PrintTemplateReserve where Ord=80)
	INSERT PrintTemplateReserve (Ord, Title, VersionStr, ReData, UserId, UpDateTime) VALUES (80, '设置考勤打印模板', '202005121034', 'Report_80', 63, CAST('2020-05-12T10:50:00.860' AS DateTime))
if not exists(select top 1 1 from PrintTemplateReserve where Ord=76)
	INSERT PrintTemplateReserve (Ord, Title, VersionStr, ReData, UserId, UpDateTime) VALUES (76, '总账打印模板', '202005121034', 'Report_76', 63, CAST('2020-07-24T19:04:41.880' AS DateTime))
if not exists(select top 1 1 from PrintTemplateReserve where Ord=77)
	INSERT PrintTemplateReserve (Ord, Title, VersionStr, ReData, UserId, UpDateTime) VALUES (77, '明细账打印模板', '202005121034', 'Report_77', 63, CAST('2020-07-24T19:05:58.713' AS DateTime))
if not exists(select top 1 1 from PrintTemplateReserve where Ord=150)
	INSERT PrintTemplateReserve (Ord, Title, VersionStr, ReData, UserId, UpDateTime) VALUES (150, '凭证打印模板', '202005121034', 'Report_150', 63, CAST('2020-07-24T19:07:00.150' AS DateTime))
if not exists(select top 1 1 from PrintTemplateReserve where Ord=23)
	INSERT PrintTemplateReserve (Ord, Title, VersionStr, ReData, UserId, UpDateTime) VALUES (23, '费用申请打印模板', '202005121034', 'Report_23', 63, CAST('2020-05-12T10:46:22.047' AS DateTime))
if not exists(select top 1 1 from PrintTemplateReserve where Ord=19)
	INSERT PrintTemplateReserve (Ord, Title, VersionStr, ReData, UserId, UpDateTime) VALUES (19, '费用使用打印模板', '202005121034', 'Report_19', 63, CAST('2020-05-12T10:46:22.047' AS DateTime))
if not exists(select top 1 1 from PrintTemplateReserve where Ord=21)
	INSERT PrintTemplateReserve (Ord, Title, VersionStr, ReData, UserId, UpDateTime) VALUES (21, '费用报销打印模板', '202005121034', 'Report_21', 63, CAST('2020-05-12T10:46:22.047' AS DateTime))
if not exists(select top 1 1 from PrintTemplateReserve where Ord=22)
	INSERT PrintTemplateReserve (Ord, Title, VersionStr, ReData, UserId, UpDateTime) VALUES (22, '费用借款打印模板', '202005121034', 'Report_22', 63, CAST('2020-05-12T10:46:22.047' AS DateTime))
if not exists(select top 1 1 from PrintTemplateReserve where Ord=20)
	INSERT PrintTemplateReserve (Ord, Title, VersionStr, ReData, UserId, UpDateTime) VALUES (20, '费用返还打印模板', '202005121034', 'Report_20', 63, CAST('2020-05-12T10:46:22.047' AS DateTime))

Go



--增加实付分类 系统默认值
if not exists(select top 1 1 from dbo.home_usConfig where name='payouttypydefault')
    begin
		INSERT INTO [dbo].[sortonehy]([sort1],[gate1],[gate2],[del] ,[isStop],[TagData]) 
		values('预设分类',20,44011,1,0,1);
        update [dbo].[sortonehy] set ord=id where gate2=44011 and ord is null
		insert into home_usConfig (name, nvalue, uid) values ('payouttypydefault', 1, 0)
    end

Go
--付款策略默认值
if not exists(select 1 from dbo.setopen where sort1=4401101)
  begin
	 --默认开启自动提交
    insert into dbo.setopen(sort1 , intro) values(4401101,1)
	 --如果采购和委外都是自动提交则也是自动提交，否则修改为非自动提交
	if not (exists(select 1 from dbo.home_usConfig where name='zdsp' and isnull(uid, 0) =0 and nvalue=1)
	   and exists(select intro from setopen where sort1=74 and intro=1))
	  begin
	   update dbo.setopen set intro=0 where sort1 =4401101
	  end
  end

GO

--V31.97采购/付款计划升级老数据处理
update caigoulist set TaxDstMoney=money1 , Concessions = isnull(Concessions, 0) where TaxDstMoney is null  and not money1 is null
update caigoulist set PriceAfterDiscountTaxPre = PriceAfterDiscountTax where  PriceAfterDiscountTaxPre is null and not PriceAfterDiscountTax is null
update x set x.PayBz= y.bz  from payout x inner join caigou y on x.PayBz is null and x.contract=y.ord and isnull(x.cls,0) =0
update x set x.PayBz= y.bz  from payout x inner join M2_OutOrder y on x.PayBz is null and x.contract=y.id  and isnull(x.cls,0) in (4,5)
update x set x.PayBz= 14 from payout x where  x.PayBz is null and isnull(x.cls,0) =2
update x set x.CompleteType=1  from payout x inner join bankout4_list y on x.CompleteType is null and x.complete=3 and  x.ord=y.payout 
update x set x.CompleteType=0  from payout x where x.complete=3 and x.CompleteType is null
update x set x.company= y.company from payout x inner join caigou y on isnull(x.cls,0) = 0 and isnull(x.company,0) =0 and x.contract= y.ord 
update x set x.company= y.gys from payout x inner join M2_OutOrder y on isnull(x.cls,0) in(4,5) and isnull(x.company,0) =0  and x.contract= y.ID 
update x set x.company= y.gys from payout x inner join M_OutOrder y on isnull(x.cls,0) = 2 and isnull(x.company,0) =0  and x.contract= y.ID 
update x set x.fyhk=0, x.sp=0 from caigou x where x.title='期初应付' and x.fyhk is null and x.sp is null
update x set plandate = cast(convert(varchar(10), date7 ,120) as datetime) from payout3 x where plandate is null
update x set plandate = cast(convert(varchar(10), date7 ,120) as datetime) from payout x where plandate is null
update zdymx set name='MoneyAfterDiscount'  from zdymx where name='MoneyAfterDiscount' and sort1=22  --防止大小写问题
--更新numqcth为null的问题
Update cl set cl.numqcth = ISNULL(curr.thCount,0)
from caigoulist cl
left join (
	select 
		sum((case isnull(d.SpResult,0) when 7 then isnull(c.Num1,0) when 8 then isnull(c.FailNum,0) else 0 end)) thCount,
		c.caigoulist
	from (select * from caigoulist where numqcth is null) b 
	inner join  caigouQClist c on b.id= c.caigouList
	inner join caigouQC  d on d.id=c.caigouQC and d.del=1
	group by c.caigoulist
) curr on cl.id = curr.caigoulist 
where cl.numqcth is null

GO

--V31.97生产委外老数据处理
UPDATE dbo.M2_OutOrderlists SET Concessions = 0, TaxDstYhPrice = ISNULL(priceAfterTax,0), TaxDstYhMoney = ISNULL(moneyAfterTax,0) WHERE ISNULL(Concessions,0) = 0 AND ISNULL(TaxDstYhPrice,0) = 0 AND ISNULL(TaxDstYhMoney,0) = 0

GO

--开票计划自定义
if not exists(select id from zdybh where sort1=43005)
begin
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('KP',1,1,4,2,1,43005)
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号2',1,0,4,2,2,43005) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号3',1,0,4,2,3,43005) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号4',1,0,4,2,4,43005) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',2,1,4,2,5,43005) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',3,1,2,2,6,43005) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',4,1,2,2,7,43005) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',5,1,3,2,8,43005) 
end

GO

--开票实开自定义
if not exists(select id from zdybh where sort1=43012)
begin
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('SK',1,1,4,2,1,43012)
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号2',1,0,4,2,2,43012) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号3',1,0,4,2,3,43012) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号4',1,0,4,2,4,43012) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',2,1,4,2,5,43012) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',3,1,2,2,6,43012) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',4,1,2,2,7,43012) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',5,1,3,2,8,43012) 
end

GO

--V31.97 同步客户表的开票信息至开票信息关系表
if not exists(select top 1 1 from InvoiceTitleInfo)
begin
	insert into InvoiceTitleInfo(
	    Creator,
	    InDate,
	    InvoiceTitle,
	    InvoiceTaxno,
	    InvoicePhone,
	    InvoiceAddr,
	    InvoiceBank,
	    InvoiceBankAcc,
	    Company,
	    Del
    )
    select distinct
	    0 Creator,date7 date1,title,taxno,phone,addr,bank,account,company,1 Del
    from paybackInvoice
    where len(ISNULL(title,'')) > 0
    order by date7 desc
end

GO
--3197历史数据处理
if not exists(select top 1 1 from dbo.home_usConfig where name='synchronizationDataTocontractthlist')
begin
    --给contractth表同步付款计划类型
    update contractth set BKPayModel=1 where isnull(BKPayModel,0)=0
    
    --更新退货明细新增字段数据   
    update ct set ct.InvoiceType= case when ct.contractlist>0 then c.InvoiceType else 0 end,
    ct.InitPrice=case when ct.contractlist>0 then ct.price1/(1+c.taxRate*0.01) else ct.price1 end,
    ct.TaxRate=case when ct.contractlist>0 then c.taxRate else 0 end,
    ct.InitMoney=case when ct.contractlist>0 then ct.price1/(1+c.taxRate*0.01)*ct.num1 else ct.money1 end,
    ct.TaxValue=case when ct.contractlist>0 then ct.money1-(ct.price1/(1+c.taxRate*0.01)*ct.num1) else 0 end,
    ct.NoNeedInKu=case when isnull(ct.contractlist,0)>0 and isnull(ct.kuoutlist2,0)>0  and p.CanOutStore=1  then 1  else 0 end
    from contractthlist ct
    left join contractlist c on c.id=ct.contractlist
    left join product p on p.ord=ct.ord
    
    insert into home_usConfig (name, nvalue, uid) values ('synchronizationDataTocontractthlist', 1, 0)
end

GO
if not exists(select id from zdybh where sort1=43010)
begin
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('TKJH_',1,1,4,2,1,43010)
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号2',1,0,4,2,2,43010) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号3',1,0,4,2,3,43010) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号4',1,0,4,2,4,43010) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',2,1,4,2,5,43010) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',3,1,2,2,6,43010) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',4,1,2,2,7,43010) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',5,1,3,2,8,43010) 
end

GO

if not exists(select 1 from setopen where sort1=202072414) insert into setopen(intro,sort1) values (1,202072414)
if not exists(select 1 from setopen where sort1=202072413) insert into setopen(intro,sort1) values (1,202072413)
if not exists(select 1 from setopen where sort1=202072412) insert into setopen(intro,sort1) values (1,202072412)

GO

if not exists(select top 1 1 from dbo.home_usConfig where name='Updatesortbank ')
begin
    update sortbank set AccountType=0,IsOpenCharge=0
    insert into home_usConfig (name, nvalue, uid) values ('Updatesortbank', 1, 0)
end

GO
--实际收款编号自定义
if not exists(select id from zdybh where sort1=43011)
begin
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('SK_'  ,1,1,4,2,1,43011)
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号2',1,0,4,2,2,43011) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号3',1,0,4,2,3,43011) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号4',1,0,4,2,4,43011) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values(''     ,2,1,4,2,5,43011) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values(''     ,3,1,2,2,6,43011) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values(''     ,4,1,2,2,7,43011) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values(''     ,5,1,3,2,8,43011) 
end

GO
--同步开票收票权限
if not exists(select top 1 1 from dbo.home_usConfig where name='Synchronization_Invoice_QX_Power')
begin
    insert into power(qx_open , qx_intro, ord,sort1, sort2)
    select qx_open , qx_intro, ord,7001 sort1, sort2 
    from power where sort1=7 and sort2 in (1,2,3,6,7,8,10,11,12,13,14,19,21,22,35)

    insert into power(qx_open , qx_intro, ord,sort1, sort2)
    select qx_open , qx_intro, ord,8001 sort1, sort2 
    from power where sort1=8 and sort2 in (1,2,3,7,8,10,11,12,13,14,19,21,35)

    insert into home_usConfig (name, nvalue, uid) values ('Synchronization_Invoice_QX_Power', 1, 0)
end

GO
--收款计划编号自定义
if not exists(select id from zdybh where sort1=43009)
begin
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('SKJH_'  ,1,1,4,2,1,43009)
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号2',1,0,4,2,2,43009) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号3',1,0,4,2,3,43009) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号4',1,0,4,2,4,43009) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values(''     ,2,1,4,2,5,43009) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values(''     ,3,1,2,2,6,43009) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values(''     ,4,1,2,2,7,43009) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values(''     ,5,1,3,2,8,43009) 
end

update p set p.PayBz =isnull(t.bz,14) , p.completetype = (case when p.complete = 2 then (case when p.bank>0 then 1 when p.SureId>0 then 8 else 2 end) else 0 end)
from payout2 p
left join contractth t on t.ord = p.contractth
where p.PayBz is null

GO
--预收款来源类型更新
if exists(select 1 from bankin2 where payout2>0 and isnull(FromType,0)=0)
begin 
    update bankin2 set FromType=3 where payout2>0 and isnull(FromType,0)=0
end

GO

--收票计划自定义编号
if not exists(select id from zdybh where sort1=41002)
begin
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('SP',1,1,4,2,1,41002)
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号2',1,0,4,2,2,41002) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号3',1,0,4,2,3,41002) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号4',1,0,4,2,4,41002) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',2,1,4,2,5,41002) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',3,1,2,2,6,41002) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',4,1,2,2,7,41002) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',5,1,3,2,8,41002) 
end

GO

--收票实收自定义编号
if not exists(select id from zdybh where sort1=44012)
begin
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('SS',1,1,4,2,1,44012)
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号2',1,0,4,2,2,44012) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号3',1,0,4,2,3,44012) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号4',1,0,4,2,4,44012) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',2,1,4,2,5,44012) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',3,1,2,2,6,44012) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',4,1,2,2,7,44012) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',5,1,3,2,8,44012) 
end

GO

--Begin修复申诉老数据
if exists(select top 1 1 from HrKQ_AttendanceAppeal where AppealBeginDate is null and len(ShouldTime)=17)
Begin
    update HrKQ_AttendanceAppeal 
    set AppealBeginDate=convert(varchar(50),[DAY],23)+' '+SUBSTRING(ShouldTime,0,9)
    where AppealBeginDate is null and len(ShouldTime)=17
End

if exists(select top 1 1 from HrKQ_AttendanceAppeal where AppealEndDate is null and len(ShouldTime)=17)
Begin
    update HrKQ_AttendanceAppeal 
    set AppealEndDate=convert(varchar(50),[DAY],23)+' '+SUBSTRING(ShouldTime,10,len(ShouldTime)-1)
    where AppealEndDate is null and len(ShouldTime)=17
End
--End修复申诉老数据

GO

--Begin修复年假误差1天数据
if not exists(select top 1 1 from dbo.home_usConfig where name='YearVacationOneDay')
Begin
    update HrKQ_AnnualLeavePlan set EndDate=DATEADD( SECOND,-1 ,CONVERT(datetime,(DATEADD( DAY,1 ,CONVERT(datetime,EndDate,120))),120)),
    EffectiveDate=DATEADD( SECOND,-1 ,CONVERT(datetime,(DATEADD( DAY,1 ,CONVERT(datetime,EffectiveDate,120))),120)) 

    insert into home_usConfig (name, nvalue, uid) values ('YearVacationOneDay', 1, 0)
End
--End修复年假误差1天数据

GO

if not exists(select 1 from home_usConfig where name = 'PAYBACK_INVOICE_SEVER_CONTRACT_INVOICEMODE')
begin
    IF exists(select 1 from setopen where sort1=98)
        update setopen set intro=210 where sort1=98
    else 
	    insert into setopen(intro,sort1) values(210,98)

	insert into home_usConfig(name,nvalue,tvalue,uid) values('PAYBACK_INVOICE_SEVER_CONTRACT_INVOICEMODE',null,1,0)
end

GO
--付款计划编号自定义
if not exists(select id from zdybh where sort1=44009)
begin
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('FKJH_'  ,1,1,4,2,1,44009)
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号2',1,0,4,2,2,44009) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号3',1,0,4,2,3,44009) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号4',1,0,4,2,4,44009) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values(''     ,2,1,4,2,5,44009) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values(''     ,3,1,2,2,6,44009) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values(''     ,4,1,2,2,7,44009) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values(''     ,5,1,3,2,8,44009) 
end

GO
--实际付款编号自定义
if not exists(select id from zdybh where sort1=44011)
begin
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('FK_'  ,1,1,4,2,1,44011)
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号2',1,0,4,2,2,44011) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号3',1,0,4,2,3,44011) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号4',1,0,4,2,4,44011) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values(''     ,2,1,4,2,5,44011) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values(''     ,3,1,2,2,6,44011) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values(''     ,4,1,2,2,7,44011) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values(''     ,5,1,3,2,8,44011) 
end

GO
--采购退款编号自定义
if not exists(select id from zdybh where sort1=44010)
begin
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('CGTK_'  ,1,1,4,2,1,44010)
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号2',1,0,4,2,2,44010) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号3',1,0,4,2,3,44010) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号4',1,0,4,2,4,44010) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values(''     ,2,1,4,2,5,44010) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values(''     ,3,1,2,2,6,44010) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values(''     ,4,1,2,2,7,44010) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values(''     ,5,1,3,2,8,44010) 
end

GO
--更新PayBackSure的MoneyforPay和MoneyforOuter数据
if not exists(select 1 from home_usConfig where name = 'PayBackSureUpdateMoneyforPayAndMoneyforOuter')
begin
    update  p  set MoneyforPay = case when  p.BackType = 6 then 0 else p.Money1 end from PayBackSureList p 
    update  p  set MoneyforPay = p.Money1 -ISNULL(b.money1,0) ,MoneyforOuter = b.Money1 from PayBackSureList p inner join Bankin2 b on p.ID=b.SureListID and (p.BackType = 3 or p.BackType = 1)  inner join PayBackSure s on s.ID = p.SureID  where s.InDate >'2020/9/12 15:21:40'
    update  p  set MoneyforPay = p.Money1 ,MoneyforOuter = b.Money1 from PayBackSureList p inner join Bankin2 b on p.ID=b.SureListID and (p.BackType = 3 or p.BackType = 1)  inner join PayBackSure s on s.ID = p.SureID  where s.InDate <'2020/9/12 15:21:40'

	insert into home_usConfig(name,nvalue,tvalue,uid) values('PayBackSureUpdateMoneyforPayAndMoneyforOuter',null,1,0)
end
GO


--实开状态更新
if exists(select 1 from paybackinvoicesure where company is null)
begin 
    update a set a.company = b.company , a.IsInvoiced = b.IsInvoiced , a.InvoiceCate = b.InvoiceCate ,a.InvoiceDatetime = b.InvoiceDatetime
    from paybackinvoicesure a
    inner join (
        select x.id, max(y.company) as company ,max(y.IsInvoiced ) IsInvoiced  , max(y.InvoiceCate) as InvoiceCate, max(y.InvoiceDatetime) InvoiceDatetime
        from paybackinvoicesure x
        inner join paybackinvoice y on y.InvoiceSureId = x.id
        where x.company is null
        group by x.id
    ) b on b.id = a.id
end 

GO
if not exists(select top 1 1 from dbo.home_usConfig where name='UpdateRepeatExpressCompany98')
begin
    --1.整理98迭代打通的快递公司，如果内置的快递公司中不存在，则加入到内置的快递公司中
    select * into #tempExpressCompanyData 
    from (
        select '安能物流' as [sort1],10000 as [gate1] ,83 as gate2 ,1 as del,0 as [isStop] ,'ANE' as [color]
        union 
        select '速尔快递',10002 ,83,1,0,'SURE'
       
    ) t
    INSERT INTO [dbo].[sortonehy]   ([sort1]   ,[gate1]   ,[gate2]  ,[del]   ,[isStop]  ,[color],  [TagData]) 
    select [sort1]    ,[gate1]  ,[gate2]  ,[del]   ,[isStop]  ,[color], 1 
    from #tempExpressCompanyData a where  not exists(select 1 from dbo.sortonehy t where t.gate2=83  and t.color=a.color and t.del=1 )	  
    update [dbo].[sortonehy] set ord=id where gate2=83 and ord is null
    --2.把内置快递公司中，编码为此2种编码的有效公司是否打通标志修改为打通，之前已经把可能重复的一波改为删除状态，所以这里只修改有效的公司
    update x set x.TagData = 1 from  [dbo].[sortonehy]   x inner join  #tempExpressCompanyData y on x.[color]=y.color  and x.gate2=83 and x.del=1 

    drop table #tempExpressCompanyData
  
    insert into home_usConfig (name, nvalue, uid) values ('UpdateRepeatExpressCompany98', 1, 0)
 end


GO

if not exists(select top 1 1 from dbo.home_usConfig where name='UpdateContractSortType_98')
begin
	--销售合同
	update a set SortType =  1 from Contract a  where  
	(paybacktype=0 or paybacktype is null) AND (sort1 is null or sort1=0) and isnull(repairOrderId,0)=0  and ISNULL(Kujh,0)=0 
	and not exists(select top 1 1 from contractlist where contract = a.ord and isnull(treeord,0)>0) and  isnull(sort1,0) not in (1,7)
	update Contract set SortType =  2 where paybacktype=1 AND (sort1 is null or sort1=0)--直接出库合同
	update Contract set SortType =  3  where sort1 = 1 --销售开单
	update Contract set SortType =  4  where isnull(repairOrderId,0)>0 --维修合同
	update Contract set SortType =  5  where wxUserId is not null --微信合同
	update a set SortType =  6 from Contract a  where  isnull(repairOrderId,0)=0   AND exists(select top 1 1 from contractlist where contract = a.ord and isnull(treeord,0)>0)--组装合同
	update Contract set SortType =  7  where  sort1=7--导入合同
	update Contract set SortType =  8  where  ISNULL(Kujh,0)> 0 --借货合同
	update Contract set SortType =1 where ISNULL(SortType,0)=0 --把不属于以上类型的数据更新为销售合同

    insert into home_usConfig (name, nvalue, uid) values ('UpdateContractSortType_98', 1, 0)
end 

GO
--添加合同标记，3198之前是否有合同
if not exists(select top 1 1 from dbo.home_usConfig where name='UpdateHasContract_98')
begin
	--销售合同
    if exists(select 1 from contract)
    begin
        insert into home_usConfig (name, nvalue, uid) values ('UpdateHasContract_98', 1, 0)
    end
    else
    begin
        insert into home_usConfig (name, nvalue, uid) values ('UpdateHasContract_98', 0, 0)
    end    
end

GO

--处理报价审批和分类老数据
if not exists(select 1 from home_usConfig where name='updateOldBankIn2AndApproveDate')
begin

    --历史主题默认值
    update b2 set b2.title=ISNULL(t.name,'')+CONVERT(VARCHAR(10), b2.Date3, 120),
    b2.Creator=case when b2.Status_sp=0 then b2.cateid end,EntryDate=case when b2.Status_sp=0 then b2.date3 end
    from bankin2 b2
    left join  tel t on t.ord=b2.company
    where len(isnull(Title,''))=0

	--新增审批规则
    EXEC dbo.erp_ApproveList 63,43001, -1, 52
    
    --更新单据审批状态
     UPDATE bankin2 SET 
     Status_sp = CASE Status_sp WHEN 0 THEN 1 WHEN 1 THEN 3 WHEN 2 THEN 4 when 3 then 5 when 4 then 0 else -1 END,
     BankinStatus=CASE when ISNULL(FromType,0)=0 and Status_sp=0 and exists(select 1 from bank where sort=9 and gl=bankin2.id) then 2 else case when isnull(bankin2.status_sp,0)=0 then 3 end  end 

    --更新历史审批实例
    insert into sp_ApprovalInstance(
                ApprovalRulesId,ApprovalProcessId,gate2, sptype,PrimaryKeyID,BillRight,
                ApprovalFlowStatus,Approver,BillPattern,CreateTime,UserID,Bounds , SurplusApprover ,  ApprovalType , ApprovalRelation,Gate1)
    select sr.ApprovalRulesID, b2.sp , sr.gate2 ,-1 , b2.id , '收款权限' , b2.status_sp , b2.cateid_sp,0 , getdate(), 63, 1 , b2.cateid_sp ,  0 ,  3 ,s.gate1
    from bankin2 b2 
    --审批规则
    inner join sp_ApprovalRules sr on sr.gate2= 43001 and sr.sptype=-1 --升级时 仅当前记录
    --审批阶段
    left join sp s on s.id = b2.sp
    where exists(select 1 from sp_intro where sort1=43001 and ord = b2.id) or b2.Status_sp in (3,4,5)	
    --审批进度
    and not exists(select 1 from sp_ApprovalInstance where gate2=43001 and PrimaryKeyID = b2.id)

    --更新历史审批记录关系
    update so set so.InstanceID=st.InstanceID ,so.ApproverName = g.name,so.ApproverDept='',so.ApprovalResult=1, so.IsAutoPass=0,
    so.ApprovalType = '单审', so.gate3=3 , so.Operator =  g.name, so.CreateTime = so.date1 , so.OperationTime = so.date1 ,
    so.ApprovalLevel = sp.gate1, so.nextSpID = 0 , so.currNodeApprover = so.cateid,
    jg=case when so.jg=2 then 0 else so.jg end 
    from sp_intro so
    inner join sp_ApprovalInstance st on st.gate2 = 43001 and st.PrimaryKeyID = so.ord
    left join gate g on g.ord= so.cateid
    left join sp on sp.id = so.sp_id
    where so.sort1 = 43001
    
    update sp set bt=2,intro=replace(intro,' ','') where gate2=43001
	insert into  home_usConfig  (name, tvalue, uid) values ('updateOldBankIn2AndApproveDate', 0, 0)
END
GO
--处理供应商预付款老数据（流程）
if not exists(select 1 from home_usConfig where name='updateOldBankOut2Datas')
begin

	--1.添加人处理
	UPDATE bankout2 SET Creator=cateid WHERE Creator IS NULL;
	
	--2.标题处理
	UPDATE bo2 SET title=t.name
	FROM bankout2 bo2
	INNER JOIN tel t on bo2.company=t.ord
	WHERE title IS NULL
	
	--3.出账日期处理
	UPDATE bankout2 SET EntryDate=date3 WHERE EntryDate IS NULL AND isnull(Status_sp,0)=0;
	--3.1出账人员处理
	UPDATE bankout2 SET cateid=0 where isnull(Status_sp,0)!=0;
	--3.2预付款状态处理
	update bankout2 set FromType=(case when cast(intro as nvarchar(max))='承兑汇票转预付款' then 1 when cast(intro as nvarchar(max))='直接付款转预付款' then 2 when cast(intro as nvarchar(max))='采购退款转预付款' then 3 else 0 end)
	
	--4.新增审批规则
	EXEC dbo.erp_ApproveList 63,44001, -1, 51
	    
	--5.更新单据审批状态
	UPDATE bankout2 SET Status_sp = CASE isnull(Status_sp,0) WHEN 0 THEN 1 WHEN 1 THEN 3 WHEN 2 THEN 4 when 3 then 5 when 4 then 0 else -1 END,
	BankinStatus=(CASE when ISNULL(FromType,0)=0 and isnull(Status_sp,0)=0 and exists(select 1 from bank where sort=11 and gl=bankout2.id) then 2 else (case when isnull(bankout2.status_sp,0)=0 then 3 else 0 end) end )

    --6.更新历史审批实例
    insert into sp_ApprovalInstance(
                ApprovalRulesId,ApprovalProcessId,gate2, sptype,PrimaryKeyID,BillRight,
                ApprovalFlowStatus,Approver,BillPattern,CreateTime,UserID,Bounds , SurplusApprover ,  ApprovalType , ApprovalRelation,Gate1)
    select sr.ApprovalRulesID, b2.sp , sr.gate2 ,-1 , b2.id , '付款权限' , b2.status_sp , b2.cateid_sp,0 , getdate(), 63, 1 , b2.cateid_sp ,  0 ,  3 ,s.gate1
    from bankout2 b2 
    --审批规则
    inner join sp_ApprovalRules sr on sr.gate2= 44001 and sr.sptype=-1 --升级时 仅当前记录
    --审批阶段
    left join sp s on s.id = b2.sp
    where exists(select 1 from sp_intro where sort1=44001 and ord = b2.id) or b2.Status_sp in (4,5)	
    --审批进度
    and not exists(select 1 from sp_ApprovalInstance where gate2=44001 and PrimaryKeyID = b2.id)

	--7.更新历史审批记录关系
	update so set so.InstanceID=st.InstanceID ,so.ApproverName = g.name,so.ApproverDept='',so.ApprovalResult=1, so.IsAutoPass=0,
	so.ApprovalType = '单审', so.gate3=3 , so.Operator =  g.name, so.CreateTime = so.date1 , so.OperationTime = so.date1 ,
	so.ApprovalLevel = sp.gate1, so.nextSpID = 0 , so.currNodeApprover = so.cateid,
	so.jg=case when so.jg=2 then 0 else so.jg end 
	from sp_intro so
	inner join sp_ApprovalInstance st on st.gate2 = 44001 and st.PrimaryKeyID = so.ord
	left join gate g on g.ord= so.cateid
	left join sp on sp.id = so.sp_id
	where so.sort1 = 44001

	--修改流程，是否必经和审批人
    update sp set bt=2,intro=replace(intro,' ','') where gate2=44001
	--8.插入更新标识
	insert into  home_usConfig  (name, tvalue, uid) values ('updateOldBankOut2Datas', 0, 0)
END
GO
--处理费用表UNICODE编码转中文
IF EXISTS(SELECT 1 FROM f_pay WHERE title LIKE '%&#%')
	BEGIN
		UPDATE f_pay SET title=CAST(CONVERT(xml,case when right(title,1)<>';' then  reverse(substring(reverse(title) ,charindex('#&;',reverse(title))+2 , len(title) )) else title end ) AS nvarchar(200)) WHERE title LIKE '%&#%'
	END
GO
--V31.98生产执行优化--生产派工优化
IF NOT EXISTS(SELECT 1 FROM dbo.home_usConfig WHERE name='OldDataWorkAssignTask6638')
BEGIN
    
    update dbo.M2_WorkAssigns set ExecQcCheck=1
    where ExecQcCheck is null
   
    update dbo.M2_WorkAssigns set Sjstatus=zjstatus     
    where Sjstatus is null

    update kuin set kuin.M2_WAID=M2QTL.bid
    from kuinlist kuin   
      inner	join M2_QualityTestingLists M2QTL on (kuin.M2_QTLID = M2QTL.ID or  kuin.M2_BFID = M2QTL.ID ) and kuin.del = 1   
      inner join M2_QualityTestings M2QT on M2QTL.QTID = M2QT.ID and M2QT.del = 1  
      inner join dbo.M2_WorkAssigns wa ON M2QTL.bid = wa.ID
    where kuin.del = 1 
    and M2QT.poType in(3,4)
    and kuin.sort1 in (5,13,14,15)
    and isnull(kuin.M2_WAID,0)=0
    --合并订单处理工艺流程
    SELECT A.WProc,
    MergeListIDs=substring(convert(varchar(4000),MergeListIDs), b.number, charindex(',', convert(varchar(4000),MergeListIDs)+',',b.number)-b.number)
	INTO #A from 
    m2_manuorderlists a join master..spt_values  b 
    ON b.type='p' AND b.number BETWEEN 1 AND LEN(a.MergeListIDs)
	where ISNULL(wproc,0)<>0 AND MergeListIDs IS NOT NULL AND
     substring(','+a.MergeListIDs,b.number,1)=',' 
    group by WProc,substring(convert(varchar(4000),MergeListIDs), b.number, charindex(',', convert(varchar(4000),MergeListIDs)+',',b.number)-b.number)        
    UPDATE A SET A.WPROC=B.WPROC FROM m2_manuorderlists A INNER JOIN #A B ON A.ID=B.MergeListIDs
    drop table #A

   insert into dbo.home_usConfig(name,nvalue,uid)values('OldDataWorkAssignTask6638',1,0)
END
GO
--V31.99生产派工送检状态历史数据处理
IF NOT EXISTS(SELECT 1 FROM dbo.home_usConfig WHERE name='OldDataWorkAssignSJStatus')
BEGIN
    
   exec dbo.erp_UpdateSJStatusByWaidsOrTaskID '',0 --更新生产派工送检状态
   insert into dbo.home_usConfig(name,nvalue,uid)values('OldDataWorkAssignSJStatus',1,0)
END
GO

IF NOT EXISTS(SELECT TOP 1 1 FROM dbo.M2_ProcessExecution_Plan)
BEGIN
	INSERT INTO dbo.M2_ProcessExecution_Plan(WAID,ProcIndex,PreIndex,NodeID,BaseNodeID,NodeType,TaskID,PlanNum,ReportingExceptionStrategy,BatchNumberStart,SerialNumberStart,ConversionBL,ReportingRounding,ExecCheck)
	SELECT WAID,ProcIndex,PreIndex,ID,BaseID,NodeType,0,basePlanNum,ReportingExceptionStrategy,BatchNumberStart,SerialNumberStart,ConversionBL,ReportingRounding,0 FROM dbo.erp_m2wfpa_Nodes_Plan
END

GO

IF NOT EXISTS(SELECT TOP 1 1 FROM dbo.M2_ProcessExecution_Result)
BEGIN
	INSERT INTO dbo.M2_ProcessExecution_Result(PlanID,WAID,ProcIndex,NodeID,BaseNodeID,NodeType,TaskID,codeBatch,codeProductID,
    HgNum,HgNumByCheck,HgNumByRework,FgNum,FgNumByCheck,BfNum,BfNumByCheck,PreHgNumByCheck,ExecedNum,CanExecNum,LastExecTime)
    SELECT pp.ID,pp.WAID,pp.ProcIndex,pp.NodeID,pp.BaseNodeID,pp.NodeType,0,bk.codeBatch,bk.codeProductID,
    ISNULL(lb.hgsl,0),ISNULL(lb.hgsl,0),0,ISNULL(lb.fgsl,0),ISNULL(lb.fgsl,0),ISNULL(lb.bfsl,0),ISNULL(lb.bfsl,0),
    bk.PreExecedNum,bk.ExecedNum,bk.CanExecNum,lb.lastExecDate FROM dbo.M2_ProcessExecution_Plan pp
    INNER JOIN dbo.erp_m2wfpa_Nodes_ExecStatus_BackV3198 bk ON pp.WAID = bk.WAID AND pp.NodeID = bk.WFPAID AND pp.NodeID = bk.WFPAID AND pp.BaseNodeID = bk.BaseWFPAID
    LEFT JOIN dbo.erp_m2wfpa_Nodes_log_tb lb ON bk.WAID = lb.WAID AND bk.WFPAID = lb.WFPAID AND bk.BaseWFPAID = lb.BaseWFPAID AND bk.codeBatch = lb.codeBatch AND bk.codeProductID = lb.codeProductID
END

GO

--工序送检编号自定义
if not exists(select id from zdybh where sort1=54014)
begin
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('GXSJ_',1,1,4,2,1,54014)
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号2',1,0,4,2,2,54014) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号3',1,0,4,2,3,54014) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号4',1,0,4,2,4,54014) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',2,1,4,2,5,54014) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',3,1,2,2,6,54014) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',4,1,2,2,7,54014) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',5,1,3,2,8,54014) 
end

GO

if not exists(select 1 from home_usConfig where name = 'OutPickingExecuteStrategy' and uid=0)
begin
	insert into  home_usConfig  (name, nvalue, uid) values ('OutPickingExecuteStrategy', 0, 0)
END
GO

if not exists(select 1 from home_usConfig where name = 'PickingExecuteStrategy' and uid=0)
begin
	insert into  home_usConfig  (name, nvalue, uid) values ('PickingExecuteStrategy', 0, 0)
END
GO

if not exists(select 1 from home_usConfig where name = 'ProcessAuditStrategy' and uid=0)
begin
	insert into  home_usConfig  (name, nvalue, uid) values ('ProcessAuditStrategy', 2, 0)
END
GO

if not exists(select 1 from home_usConfig where name = 'ProcessOutStrategy' and uid=0)
begin
	insert into  home_usConfig  (name, nvalue, uid) values ('ProcessOutStrategy', 1, 0)
END
GO

if not exists(select 1 from home_usConfig where name = 'ProcessSendInspectionStrategy' and uid=0)
begin
	insert into  home_usConfig  (name, nvalue, uid) values ('ProcessSendInspectionStrategy', 1, 0)
END
GO

if not exists(select 1 from home_usConfig where name = 'ProcessStartStrategy' and uid=0)
begin
	insert into  home_usConfig  (name, nvalue, uid) values ('ProcessStartStrategy', 0, 0)
END
GO

if not exists(select 1 from home_usConfig where name = 'ProduceExecQCStrategy' and uid=0)
begin
	insert into  home_usConfig  (name, nvalue, uid) values ('ProduceExecQCStrategy', 1, 0)
END
GO

if not exists(select 1 from home_usConfig where name = 'ProduceSendInspectionStrategy' and uid=0)
begin
	insert into  home_usConfig  (name, nvalue, uid) values ('ProduceSendInspectionStrategy', 1, 0)
end

GO
--V31.98暂估--退款计划
IF NOT EXISTS(SELECT 1 FROM dbo.home_usConfig WHERE name='payout3198forupdate')
BEGIN
--把历史数据的 fromtype,company,bz,frombillid 都修改为采购退货单的数据
update a set  a.company=b.company,a.fromtype=1 from payout3 a inner join caigouth B on a.caigouth=b.ord where isnull(fromtype,0)=0 or isnull(a.company,0)=0
update a set  a.frombillid=a.caigouth from payout3 a where isnull(frombillid,0)=0 
--如果有币种为空的再次做处理
update a set  a.bz=b.bz from payout3 a inner join caigouth B on a.caigouth=b.ord where a.bz is null
--垃圾数据币种直接为14
update a set  a.bz=14 from payout3 a where a.bz is null
insert into dbo.home_usConfig(name,nvalue,uid)values('payout3198forupdate',1,0)

END
GO
--V31.98暂估--实际收票计划
IF NOT EXISTS(SELECT 1 FROM dbo.home_usConfig WHERE name='payoutinvoice_taxprice_3198')
BEGIN

DECLARE @DOT INT=1
SELECT @DOT=num1 FROM setjm3 where ord=2019042804--财务单价
UPDATE payoutInvoice_list SET TaxPrice=round(money1/(case when ISNULL(num1,0)=0 then 1 else num1 end),@DOT)

insert into  home_usConfig  (name, nvalue, uid) values ('payoutinvoice_taxprice_3198', 1, 0)
END
GO
--V31.98采购优化-新增原优化单价，原优惠总价老数据处理
IF NOT EXISTS(SELECT 1 FROM dbo.home_usConfig WHERE name='caigoulist_Y_AfterDiscountTaxPrice_Y_Money')
BEGIN

UPDATE caigoulist SET Y_AfterDiscountTaxPrice=priceAfterDiscountTax,Y_Money=money1

insert into  home_usConfig  (name, nvalue, uid) values ('caigoulist_Y_AfterDiscountTaxPrice_Y_Money', 1, 0)
END
GO
if not exists(select id from zdybh where sort1=48002)
begin
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('ZG_',1,1,4,2,1,48002)
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号2',1,0,4,2,2,48002) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号3',1,0,4,2,3,48002) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号4',1,0,4,2,4,48002) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',2,1,4,2,5,48002) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',3,1,2,2,6,48002) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',4,1,2,2,7,48002) 
	insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',5,1,3,2,8,48002) 
end


GO
--V31.98产品历史数据 分类兼容处理
IF NOT EXISTS(SELECT 1 FROM dbo.home_usConfig WHERE name='product3198sortupdate')
BEGIN

update product set sort1=0 where not exists(select '1' from menu m where m.id=isnull(sort1,-100))

insert into dbo.home_usConfig(name,nvalue,uid)values('product3198sortupdate',1,0)

END

--V31.98处理直接出库时拆分单位可能存在的关联关系不正确的问题
update x set x.kuoutlist2=z.id   from kuinlist x 
inner join kuoutlist2 y on x.kuoutlist2=y.id  and x.sort1=10 and y.sort1<>10
inner join kuoutlist2 z on z.sort1=10 and x.ord=z.ord and x.ku=z.ck and  datediff(s, z.date7, x.date7)<1
GO

IF NOT EXISTS(SELECT id FROM [M2_ProcessConfiguration] WHERE TemplateType=1)
BEGIN 
INSERT [M2_ProcessConfiguration] ([GroupFlag], [GroupIndex], [TemplateType], [BillType], [Module], [OpenState], [Must], [ExistsData], [ParentBillTypes]) VALUES (1, 10, 1, 52001, 18100, 1, 0, 0, N'')
INSERT [M2_ProcessConfiguration] ([GroupFlag], [GroupIndex], [TemplateType], [BillType], [Module], [OpenState], [Must], [ExistsData], [ParentBillTypes]) VALUES (1, 20, 1, 52002, 18110, 1, 1, 0, N'')
INSERT [M2_ProcessConfiguration] ([GroupFlag], [GroupIndex], [TemplateType], [BillType], [Module], [OpenState], [Must], [ExistsData], [ParentBillTypes]) VALUES (1, 30, 1, 53001, 18400, 0, 0, 0, N'')
INSERT [M2_ProcessConfiguration] ([GroupFlag], [GroupIndex], [TemplateType], [BillType], [Module], [OpenState], [Must], [ExistsData], [ParentBillTypes]) VALUES (1, 40, 1, 53002, 18410, 0, 0, 0, N'53001')
INSERT [M2_ProcessConfiguration] ([GroupFlag], [GroupIndex], [TemplateType], [BillType], [Module], [OpenState], [Must], [ExistsData], [ParentBillTypes]) VALUES (1, 50, 1, 54001, 18500, 1, 1, 0, N'')
INSERT [M2_ProcessConfiguration] ([GroupFlag], [GroupIndex], [TemplateType], [BillType], [Module], [OpenState], [Must], [ExistsData], [ParentBillTypes]) VALUES (2, 60, 1, 54002, 18600, 1, 1, 0, N'')
INSERT [M2_ProcessConfiguration] ([GroupFlag], [GroupIndex], [TemplateType], [BillType], [Module], [OpenState], [Must], [ExistsData], [ParentBillTypes]) VALUES (2, 70, 1, 55000, 18620, 1, 1, 0, N'')
INSERT [M2_ProcessConfiguration] ([GroupFlag], [GroupIndex], [TemplateType], [BillType], [Module], [OpenState], [Must], [ExistsData], [ParentBillTypes]) VALUES (2, 80, 1, 54067, 18610, 0, 0, 0, N'')
INSERT [M2_ProcessConfiguration] ([GroupFlag], [GroupIndex], [TemplateType], [BillType], [Module], [OpenState], [Must], [ExistsData], [ParentBillTypes]) VALUES (2, 90, 1, 54004, 18600, 1, 1, 0, N'')
INSERT [M2_ProcessConfiguration] ([GroupFlag], [GroupIndex], [TemplateType], [BillType], [Module], [OpenState], [Must], [ExistsData], [ParentBillTypes]) VALUES (2, 95, 1, 54005, 18800, 0, 0, 0, N'')
INSERT [M2_ProcessConfiguration] ([GroupFlag], [GroupIndex], [TemplateType], [BillType], [Module], [OpenState], [Must], [ExistsData], [ParentBillTypes]) VALUES (2, 100, 1, 61001, 17002, 1, 1, 0, N'')
INSERT [M2_ProcessConfiguration] ([GroupFlag], [GroupIndex], [TemplateType], [BillType], [Module], [OpenState], [Must], [ExistsData], [ParentBillTypes]) VALUES (3, 110, 1, 54003, 18700, 0, 0, 0, N'')
INSERT [M2_ProcessConfiguration] ([GroupFlag], [GroupIndex], [TemplateType], [BillType], [Module], [OpenState], [Must], [ExistsData], [ParentBillTypes]) VALUES (3, 120, 1, 55000, 18620, 0, 1, 0, N'54003')
INSERT [M2_ProcessConfiguration] ([GroupFlag], [GroupIndex], [TemplateType], [BillType], [Module], [OpenState], [Must], [ExistsData], [ParentBillTypes]) VALUES (3, 130, 1, 58002, 18700, 0, 1, 0, N'54003')
INSERT [M2_ProcessConfiguration] ([GroupFlag], [GroupIndex], [TemplateType], [BillType], [Module], [OpenState], [Must], [ExistsData], [ParentBillTypes]) VALUES (3, 140, 1, 58003, 18700, 0, 1, 0, N'54003')
INSERT [M2_ProcessConfiguration] ([GroupFlag], [GroupIndex], [TemplateType], [BillType], [Module], [OpenState], [Must], [ExistsData], [ParentBillTypes]) VALUES (3, 150, 1, 54009, 18700, 0, 1, 0, N'54003')
INSERT [M2_ProcessConfiguration] ([GroupFlag], [GroupIndex], [TemplateType], [BillType], [Module], [OpenState], [Must], [ExistsData], [ParentBillTypes]) VALUES (3, 155, 1, 58001, 18700, 0, 1, 0, N'54003')
INSERT [M2_ProcessConfiguration] ([GroupFlag], [GroupIndex], [TemplateType], [BillType], [Module], [OpenState], [Must], [ExistsData], [ParentBillTypes]) VALUES (3, 160, 1, 61001, 17002, 0, 1, 0, N'54003')
INSERT [M2_ProcessConfiguration] ([GroupFlag], [GroupIndex], [TemplateType], [BillType], [Module], [OpenState], [Must], [ExistsData], [ParentBillTypes]) VALUES (4, 170, 1, 55004, 18620, 1, 1, 0, N'')
INSERT [M2_ProcessConfiguration] ([GroupFlag], [GroupIndex], [TemplateType], [BillType], [Module], [OpenState], [Must], [ExistsData], [ParentBillTypes]) VALUES (4, 180, 1, 56004, 218910, 0, 0, 0, N'')
INSERT [M2_ProcessConfiguration] ([GroupFlag], [GroupIndex], [TemplateType], [BillType], [Module], [OpenState], [Must], [ExistsData], [ParentBillTypes]) VALUES (4, 200, 1, 48001, 18500, 1, 1, 0, N'')
END
GO

IF NOT EXISTS(SELECT id FROM [M2_ProcessConfiguration] WHERE TemplateType=2)
BEGIN 
INSERT [M2_ProcessConfiguration] ([GroupFlag], [GroupIndex], [TemplateType], [BillType], [Module], [OpenState], [Must], [ExistsData], [ParentBillTypes]) VALUES (1, 210, 2, 52001, 18100, 1, 0, 0, N'')
INSERT [M2_ProcessConfiguration] ([GroupFlag], [GroupIndex], [TemplateType], [BillType], [Module], [OpenState], [Must], [ExistsData], [ParentBillTypes]) VALUES (1, 220, 2, 52002, 18110, 1, 1, 0, N'')
INSERT [M2_ProcessConfiguration] ([GroupFlag], [GroupIndex], [TemplateType], [BillType], [Module], [OpenState], [Must], [ExistsData], [ParentBillTypes]) VALUES (1, 230, 2, 53001, 18400, 1, 0, 0, N'')
INSERT [M2_ProcessConfiguration] ([GroupFlag], [GroupIndex], [TemplateType], [BillType], [Module], [OpenState], [Must], [ExistsData], [ParentBillTypes]) VALUES (1, 240, 2, 53002, 18410, 0, 0, 0, N'53001')
INSERT [M2_ProcessConfiguration] ([GroupFlag], [GroupIndex], [TemplateType], [BillType], [Module], [OpenState], [Must], [ExistsData], [ParentBillTypes]) VALUES (1, 250, 2, 54001, 18500, 1, 1, 0, N'')
INSERT [M2_ProcessConfiguration] ([GroupFlag], [GroupIndex], [TemplateType], [BillType], [Module], [OpenState], [Must], [ExistsData], [ParentBillTypes]) VALUES (2, 260, 2, 54002, 18600, 1, 1, 0, N'')
INSERT [M2_ProcessConfiguration] ([GroupFlag], [GroupIndex], [TemplateType], [BillType], [Module], [OpenState], [Must], [ExistsData], [ParentBillTypes]) VALUES (2, 270, 2, 55000, 18620, 1, 1, 0, N'')
INSERT [M2_ProcessConfiguration] ([GroupFlag], [GroupIndex], [TemplateType], [BillType], [Module], [OpenState], [Must], [ExistsData], [ParentBillTypes]) VALUES (2, 280, 2, 54067, 18610, 1, 0, 0, N'')
INSERT [M2_ProcessConfiguration] ([GroupFlag], [GroupIndex], [TemplateType], [BillType], [Module], [OpenState], [Must], [ExistsData], [ParentBillTypes]) VALUES (2, 290, 2, 54004, 18600, 1, 1, 0, N'')
INSERT [M2_ProcessConfiguration] ([GroupFlag], [GroupIndex], [TemplateType], [BillType], [Module], [OpenState], [Must], [ExistsData], [ParentBillTypes]) VALUES (2, 295, 2, 54005, 18800, 1, 0, 0, N'')
INSERT [M2_ProcessConfiguration] ([GroupFlag], [GroupIndex], [TemplateType], [BillType], [Module], [OpenState], [Must], [ExistsData], [ParentBillTypes]) VALUES (2, 300, 2, 61001, 17002, 1, 1, 0, N'')
INSERT [M2_ProcessConfiguration] ([GroupFlag], [GroupIndex], [TemplateType], [BillType], [Module], [OpenState], [Must], [ExistsData], [ParentBillTypes]) VALUES (3, 310, 2, 54003, 18700, 0, 0, 0, N'')
INSERT [M2_ProcessConfiguration] ([GroupFlag], [GroupIndex], [TemplateType], [BillType], [Module], [OpenState], [Must], [ExistsData], [ParentBillTypes]) VALUES (3, 320, 2, 55000, 18620, 0, 1, 0, N'54003')
INSERT [M2_ProcessConfiguration] ([GroupFlag], [GroupIndex], [TemplateType], [BillType], [Module], [OpenState], [Must], [ExistsData], [ParentBillTypes]) VALUES (3, 330, 2, 58002, 18700, 0, 1, 0, N'54003')
INSERT [M2_ProcessConfiguration] ([GroupFlag], [GroupIndex], [TemplateType], [BillType], [Module], [OpenState], [Must], [ExistsData], [ParentBillTypes]) VALUES (3, 340, 2, 58003, 18700, 0, 1, 0, N'54003')
INSERT [M2_ProcessConfiguration] ([GroupFlag], [GroupIndex], [TemplateType], [BillType], [Module], [OpenState], [Must], [ExistsData], [ParentBillTypes]) VALUES (3, 350, 2, 54009, 18700, 0, 1, 0, N'54003')
INSERT [M2_ProcessConfiguration] ([GroupFlag], [GroupIndex], [TemplateType], [BillType], [Module], [OpenState], [Must], [ExistsData], [ParentBillTypes]) VALUES (3, 355, 2, 58001, 18700, 0, 1, 0, N'54003')
INSERT [M2_ProcessConfiguration] ([GroupFlag], [GroupIndex], [TemplateType], [BillType], [Module], [OpenState], [Must], [ExistsData], [ParentBillTypes]) VALUES (3, 360, 2, 61001, 17002, 0, 1, 0, N'54003')
INSERT [M2_ProcessConfiguration] ([GroupFlag], [GroupIndex], [TemplateType], [BillType], [Module], [OpenState], [Must], [ExistsData], [ParentBillTypes]) VALUES (4, 370, 2, 55004, 18620, 1, 1, 0, N'')
INSERT [M2_ProcessConfiguration] ([GroupFlag], [GroupIndex], [TemplateType], [BillType], [Module], [OpenState], [Must], [ExistsData], [ParentBillTypes]) VALUES (4, 380, 2, 56004, 218910, 1, 0, 0, N'')
INSERT [M2_ProcessConfiguration] ([GroupFlag], [GroupIndex], [TemplateType], [BillType], [Module], [OpenState], [Must], [ExistsData], [ParentBillTypes]) VALUES (4, 400, 2, 48001, 18500, 1, 1, 0, N'')
END
GO

IF NOT EXISTS(SELECT id FROM [M2_ProcessConfiguration] WHERE TemplateType=3)
BEGIN 
INSERT [M2_ProcessConfiguration] ([GroupFlag], [GroupIndex], [TemplateType], [BillType], [Module], [OpenState], [Must], [ExistsData], [ParentBillTypes]) VALUES (1, 410, 3, 52001, 18100, 1, 0, 0, N'')
INSERT [M2_ProcessConfiguration] ([GroupFlag], [GroupIndex], [TemplateType], [BillType], [Module], [OpenState], [Must], [ExistsData], [ParentBillTypes]) VALUES (1, 420, 3, 52002, 18110, 1, 1, 0, N'')
INSERT [M2_ProcessConfiguration] ([GroupFlag], [GroupIndex], [TemplateType], [BillType], [Module], [OpenState], [Must], [ExistsData], [ParentBillTypes]) VALUES (1, 430, 3, 53001, 18400, 1, 0, 0, N'')
INSERT [M2_ProcessConfiguration] ([GroupFlag], [GroupIndex], [TemplateType], [BillType], [Module], [OpenState], [Must], [ExistsData], [ParentBillTypes]) VALUES (1, 440, 3, 53002, 18410, 1, 0, 0, N'53001')
INSERT [M2_ProcessConfiguration] ([GroupFlag], [GroupIndex], [TemplateType], [BillType], [Module], [OpenState], [Must], [ExistsData], [ParentBillTypes]) VALUES (1, 450, 3, 54001, 18500, 1, 1, 0, N'')
INSERT [M2_ProcessConfiguration] ([GroupFlag], [GroupIndex], [TemplateType], [BillType], [Module], [OpenState], [Must], [ExistsData], [ParentBillTypes]) VALUES (2, 460, 3, 54002, 18600, 1, 1, 0, N'')
INSERT [M2_ProcessConfiguration] ([GroupFlag], [GroupIndex], [TemplateType], [BillType], [Module], [OpenState], [Must], [ExistsData], [ParentBillTypes]) VALUES (2, 470, 3, 55000, 18620, 1, 1, 0, N'')
INSERT [M2_ProcessConfiguration] ([GroupFlag], [GroupIndex], [TemplateType], [BillType], [Module], [OpenState], [Must], [ExistsData], [ParentBillTypes]) VALUES (2, 480, 3, 54067, 18610, 1, 0, 0, N'')
INSERT [M2_ProcessConfiguration] ([GroupFlag], [GroupIndex], [TemplateType], [BillType], [Module], [OpenState], [Must], [ExistsData], [ParentBillTypes]) VALUES (2, 490, 3, 54004, 18600, 1, 1, 0, N'')
INSERT [M2_ProcessConfiguration] ([GroupFlag], [GroupIndex], [TemplateType], [BillType], [Module], [OpenState], [Must], [ExistsData], [ParentBillTypes]) VALUES (2, 495, 3, 54005, 18800, 1, 0, 0, N'')
INSERT [M2_ProcessConfiguration] ([GroupFlag], [GroupIndex], [TemplateType], [BillType], [Module], [OpenState], [Must], [ExistsData], [ParentBillTypes]) VALUES (2, 500, 3, 61001, 17002, 1, 1, 0, N'')
INSERT [M2_ProcessConfiguration] ([GroupFlag], [GroupIndex], [TemplateType], [BillType], [Module], [OpenState], [Must], [ExistsData], [ParentBillTypes]) VALUES (3, 510, 3, 54003, 18700, 1, 0, 0, N'')
INSERT [M2_ProcessConfiguration] ([GroupFlag], [GroupIndex], [TemplateType], [BillType], [Module], [OpenState], [Must], [ExistsData], [ParentBillTypes]) VALUES (3, 520, 3, 55000, 18620, 1, 1, 0, N'54003')
INSERT [M2_ProcessConfiguration] ([GroupFlag], [GroupIndex], [TemplateType], [BillType], [Module], [OpenState], [Must], [ExistsData], [ParentBillTypes]) VALUES (3, 530, 3, 58002, 18700, 1, 1, 0, N'54003')
INSERT [M2_ProcessConfiguration] ([GroupFlag], [GroupIndex], [TemplateType], [BillType], [Module], [OpenState], [Must], [ExistsData], [ParentBillTypes]) VALUES (3, 540, 3, 58003, 18700, 1, 1, 0, N'54003')
INSERT [M2_ProcessConfiguration] ([GroupFlag], [GroupIndex], [TemplateType], [BillType], [Module], [OpenState], [Must], [ExistsData], [ParentBillTypes]) VALUES (3, 550, 3, 54009, 18700, 1, 1, 0, N'54003')
INSERT [M2_ProcessConfiguration] ([GroupFlag], [GroupIndex], [TemplateType], [BillType], [Module], [OpenState], [Must], [ExistsData], [ParentBillTypes]) VALUES (3, 555, 3, 58001, 18700, 1, 1, 0, N'54003')
INSERT [M2_ProcessConfiguration] ([GroupFlag], [GroupIndex], [TemplateType], [BillType], [Module], [OpenState], [Must], [ExistsData], [ParentBillTypes]) VALUES (3, 560, 3, 61001, 17002, 1, 1, 0, N'54003')
INSERT [M2_ProcessConfiguration] ([GroupFlag], [GroupIndex], [TemplateType], [BillType], [Module], [OpenState], [Must], [ExistsData], [ParentBillTypes]) VALUES (4, 570, 3, 55004, 18620, 1, 1, 0, N'')
INSERT [M2_ProcessConfiguration] ([GroupFlag], [GroupIndex], [TemplateType], [BillType], [Module], [OpenState], [Must], [ExistsData], [ParentBillTypes]) VALUES (4, 580, 3, 56004, 218910, 1, 0, 0, N'')
INSERT [M2_ProcessConfiguration] ([GroupFlag], [GroupIndex], [TemplateType], [BillType], [Module], [OpenState], [Must], [ExistsData], [ParentBillTypes]) VALUES (4, 600, 3, 48001, 18500, 1, 1, 0, N'')
END
GO

IF NOT EXISTS(SELECT id FROM [M2_ProcessConfiguration] WHERE TemplateType=4)
BEGIN 
INSERT [M2_ProcessConfiguration] ([GroupFlag], [GroupIndex], [TemplateType], [BillType], [Module], [OpenState], [Must], [ExistsData], [ParentBillTypes]) VALUES (1, 610, 4, 52001, 18100, 1, 0, 0, N'')
INSERT [M2_ProcessConfiguration] ([GroupFlag], [GroupIndex], [TemplateType], [BillType], [Module], [OpenState], [Must], [ExistsData], [ParentBillTypes]) VALUES (1, 620, 4, 52002, 18110, 1, 1, 0, N'')
INSERT [M2_ProcessConfiguration] ([GroupFlag], [GroupIndex], [TemplateType], [BillType], [Module], [OpenState], [Must], [ExistsData], [ParentBillTypes]) VALUES (1, 630, 4, 53001, 18400, 1, 0, 0, N'')
INSERT [M2_ProcessConfiguration] ([GroupFlag], [GroupIndex], [TemplateType], [BillType], [Module], [OpenState], [Must], [ExistsData], [ParentBillTypes]) VALUES (1, 640, 4, 53002, 18410, 1, 0, 0, N'53001')
INSERT [M2_ProcessConfiguration] ([GroupFlag], [GroupIndex], [TemplateType], [BillType], [Module], [OpenState], [Must], [ExistsData], [ParentBillTypes]) VALUES (1, 650, 4, 54001, 18500, 1, 1, 0, N'')
INSERT [M2_ProcessConfiguration] ([GroupFlag], [GroupIndex], [TemplateType], [BillType], [Module], [OpenState], [Must], [ExistsData], [ParentBillTypes]) VALUES (2, 660, 4, 54002, 18600, 1, 1, 0, N'')
INSERT [M2_ProcessConfiguration] ([GroupFlag], [GroupIndex], [TemplateType], [BillType], [Module], [OpenState], [Must], [ExistsData], [ParentBillTypes]) VALUES (2, 670, 4, 55000, 18620, 1, 1, 0, N'')
INSERT [M2_ProcessConfiguration] ([GroupFlag], [GroupIndex], [TemplateType], [BillType], [Module], [OpenState], [Must], [ExistsData], [ParentBillTypes]) VALUES (2, 680, 4, 54067, 18610, 1, 0, 0, N'')
INSERT [M2_ProcessConfiguration] ([GroupFlag], [GroupIndex], [TemplateType], [BillType], [Module], [OpenState], [Must], [ExistsData], [ParentBillTypes]) VALUES (2, 690, 4, 54004, 18600, 1, 1, 0, N'')
INSERT [M2_ProcessConfiguration] ([GroupFlag], [GroupIndex], [TemplateType], [BillType], [Module], [OpenState], [Must], [ExistsData], [ParentBillTypes]) VALUES (2, 695, 4, 54005, 18800, 1, 0, 0, N'')
INSERT [M2_ProcessConfiguration] ([GroupFlag], [GroupIndex], [TemplateType], [BillType], [Module], [OpenState], [Must], [ExistsData], [ParentBillTypes]) VALUES (2, 700, 4, 61001, 17002, 1, 1, 0, N'')
INSERT [M2_ProcessConfiguration] ([GroupFlag], [GroupIndex], [TemplateType], [BillType], [Module], [OpenState], [Must], [ExistsData], [ParentBillTypes]) VALUES (3, 710, 4, 54003, 18700, 1, 0, 0, N'')
INSERT [M2_ProcessConfiguration] ([GroupFlag], [GroupIndex], [TemplateType], [BillType], [Module], [OpenState], [Must], [ExistsData], [ParentBillTypes]) VALUES (3, 720, 4, 55000, 18620, 1, 1, 0, N'54003')
INSERT [M2_ProcessConfiguration] ([GroupFlag], [GroupIndex], [TemplateType], [BillType], [Module], [OpenState], [Must], [ExistsData], [ParentBillTypes]) VALUES (3, 730, 4, 58002, 18700, 1, 1, 0, N'54003')
INSERT [M2_ProcessConfiguration] ([GroupFlag], [GroupIndex], [TemplateType], [BillType], [Module], [OpenState], [Must], [ExistsData], [ParentBillTypes]) VALUES (3, 740, 4, 58003, 18700, 1, 1, 0, N'54003')
INSERT [M2_ProcessConfiguration] ([GroupFlag], [GroupIndex], [TemplateType], [BillType], [Module], [OpenState], [Must], [ExistsData], [ParentBillTypes]) VALUES (3, 750, 4, 54009, 18700, 1, 1, 0, N'54003')
INSERT [M2_ProcessConfiguration] ([GroupFlag], [GroupIndex], [TemplateType], [BillType], [Module], [OpenState], [Must], [ExistsData], [ParentBillTypes]) VALUES (3, 755, 4, 58001, 18700, 1, 1, 0, N'54003')
INSERT [M2_ProcessConfiguration] ([GroupFlag], [GroupIndex], [TemplateType], [BillType], [Module], [OpenState], [Must], [ExistsData], [ParentBillTypes]) VALUES (3, 760, 4, 61001, 17002, 1, 1, 0, N'54003')
INSERT [M2_ProcessConfiguration] ([GroupFlag], [GroupIndex], [TemplateType], [BillType], [Module], [OpenState], [Must], [ExistsData], [ParentBillTypes]) VALUES (4, 770, 4, 55004, 18620, 1, 1, 0, N'')
INSERT [M2_ProcessConfiguration] ([GroupFlag], [GroupIndex], [TemplateType], [BillType], [Module], [OpenState], [Must], [ExistsData], [ParentBillTypes]) VALUES (4, 780, 4, 56004, 218910, 1, 0, 0, N'')
INSERT [M2_ProcessConfiguration] ([GroupFlag], [GroupIndex], [TemplateType], [BillType], [Module], [OpenState], [Must], [ExistsData], [ParentBillTypes]) VALUES (4, 800, 4, 48001, 18500, 1, 1, 0, N'')
END
GO

IF NOT EXISTS(SELECT id FROM [M2_ProcessConfiguration] WHERE Module=218930)
BEGIN 
INSERT [M2_ProcessConfiguration] ([GroupFlag], [GroupIndex], [TemplateType], [BillType], [Module], [OpenState], [Must], [ExistsData], [ParentBillTypes]) VALUES (4, 190, 1, 56002, 218930, 0, 0, 0, N'')
INSERT [M2_ProcessConfiguration] ([GroupFlag], [GroupIndex], [TemplateType], [BillType], [Module], [OpenState], [Must], [ExistsData], [ParentBillTypes]) VALUES (4, 390, 2, 56002, 218930, 1, 0, 0, N'')
INSERT [M2_ProcessConfiguration] ([GroupFlag], [GroupIndex], [TemplateType], [BillType], [Module], [OpenState], [Must], [ExistsData], [ParentBillTypes]) VALUES (4, 590, 3, 56002, 218930, 1, 0, 0, N'')
INSERT [M2_ProcessConfiguration] ([GroupFlag], [GroupIndex], [TemplateType], [BillType], [Module], [OpenState], [Must], [ExistsData], [ParentBillTypes]) VALUES (4, 790, 4, 56002, 218930, 1, 0, 0, N'')
END
GO

--V31.98【优化】暂估—委外优化 历史数据处理
IF NOT EXISTS(SELECT 1 FROM dbo.home_usConfig WHERE name='OldDataTask6739')
BEGIN
   update dbo.M2_OutOrderlists set Y_TaxDstYhPrice=TaxDstYhPrice,Y_TaxDstYhMoney=TaxDstYhMoney where isnull(Y_TaxDstYhMoney,0)=0
   insert into dbo.home_usConfig(name,nvalue,uid)values('OldDataTask6739',1,0)
END
GO
IF NOT EXISTS (select id from zdybh where sort1=48003)
BEGIN
	    insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('CY_',1,1,4,2,1,48003)
	    insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号2',1,0,4,2,2,48003) 
	    insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号3',1,0,4,2,3,48003) 
	    insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('编号4',1,0,4,2,4,48003) 
	    insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',2,1,4,2,5,48003) 
	    insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',3,1,2,2,6,48003) 
	    insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',4,1,2,2,7,48003) 
	    insert into zdybh(title,sort,set_open,intro1,intro2,gate1,sort1) values('',5,1,3,2,8,48003) 
END

GO

if exists(select 1 from contractlist_his where ord is null)
begin 
    update a set a.ord = isnull(b.ord,0)
    from contractlist_his a
    left join contractlist b on b.id = a.listid
    where a.ord is null
end 
GO

--出入库单凭证约束
if not exists(select 1 from home_usConfig where name = 'Payback_InOutOrder_Voucher_Constraint' and uid=0)
begin
	insert into  home_usConfig  (name, nvalue, uid) values ('Payback_InOutOrder_Voucher_Constraint', 1, 0)
END
GO
--销售出库单凭证约束
if not exists(select 1 from home_usConfig where name = 'Payback_SaleOut_Voucher_Constraint' and uid=0)
begin
	insert into  home_usConfig  (name, nvalue, uid) values ('Payback_SaleOut_Voucher_Constraint', 1, 0)
END
GO
--采购入库单凭证约束
if not exists(select 1 from home_usConfig where name = 'Payback_Purchase_Voucher_Constraint' and uid=0)
begin
	insert into  home_usConfig  (name, nvalue, uid) values ('Payback_Purchase_Voucher_Constraint', 1, 0)
END
GO
--生产废料单凭证约束
if not exists(select 1 from home_usConfig where name = 'Payback_MaterialWaste_Voucher_Constraint' and uid=0)
begin
	insert into  home_usConfig  (name, nvalue, uid) values ('Payback_MaterialWaste_Voucher_Constraint', 1, 0)
END
GO
--费用归集凭证约束
if not exists(select 1 from home_usConfig where name = 'Payback_OrderCostsShare_Voucher_Constraint' and uid=0)
begin
	insert into  home_usConfig  (name, nvalue, uid) values ('Payback_OrderCostsShare_Voucher_Constraint', 1, 0)
END
GO
--初始化暂估自定义明细
if not exists(select 1 from sys_sdk_BillFieldInfo where BillType=48002  and ListType=1)
begin
insert into sys_sdk_BillFieldInfo(ModuleType, BillType, ListType, InheritId, Title, DBName, UiType, DbType, Unit, Remark,ShowIndex,
									 Colspan, Rowspan, Display,IsUsed, SourceTag, cansearch,candc, candr, cantj,mustfillin,DefWidth)
SELECT 0,48002,1,0,'产品名称','InheritId_self_title',0,5,'','',1,-1,-1,-1,1,'',0,0,1,0,0,0
UNION ALL SELECT 0,48002,1,0,'产品编号'    ,'InheritId_self_order1',0,5,'','',2,-1,-1,-1,1,'',0,0,1,0,0,0
UNION ALL SELECT 0,48002,1,0,'产品型号'    ,'InheritId_self_type1',0,5,'','',3,-1,-1,-1,1,'',0,0,1,0,0,0
UNION ALL SELECT 0,48002,1,0,'单位'        ,'InheritId_self_UnitName',0,5,'','',4,-1,-1,-1,1,'',0,0,1,0,0,0
UNION ALL SELECT 0,48002,1,0,'数量'        ,'InheritId_self_chgNum',0,5,'','',5,-1,-1,-1,1,'',0,0,1,0,0,0
UNION ALL SELECT 0,48002,1,0,'暂估成本单价','InheritId_self_oldPrice',0,5,'','',6,-1,-1,-1,1,'',0,0,1,0,0,0
UNION ALL SELECT 0,48002,1,0,'成本单价'    ,'InheritId_self_newPrice',0,5,'','',7,-1,-1,-1,1,'',0,0,1,0,0,0
UNION ALL SELECT 0,48002,1,0,'暂估成本总价','InheritId_self_oldMoney',0,5,'','',8,-1,-1,-1,1,'',0,0,1,0,0,0
UNION ALL SELECT 0,48002,1,0,'成本总价'    ,'InheritId_self_newMoney',0,5,'','',9,-1,-1,-1,1,'',0,0,1,0,0,0
UNION ALL SELECT 0,48002,1,0,'差异成本'    ,'InheritId_self_cymoney1',0,5,'','',10,-1,-1,-1,1,'',0,0,1,0,0,0
UNION ALL SELECT 0,48002,1,0,'备注'        ,'InheritId_self_Intro',0,5,'','',11,-1,-1,-1,1,'',0,0,1,0,0,0
UNION ALL SELECT 0,48002,1,0,'自定义1'     ,'InheritId_self_Zdy1',0,5,'','',12,-1,-1,-1,1,'',0,0,1,0,0,0
UNION ALL SELECT 0,48002,1,0,'自定义2'     ,'InheritId_self_Zdy2',0,5,'','',13,-1,-1,-1,1,'',0,0,1,0,0,0
UNION ALL SELECT 0,48002,1,0,'自定义3'     ,'InheritId_self_Zdy4',0,5,'','',14,-1,-1,-1,1,'',0,0,1,0,0,0
UNION ALL SELECT 0,48002,1,0,'自定义4'     ,'InheritId_self_Zdy3',0,5,'','',15,-1,-1,-1,1,'',0,0,1,0,0,0
UNION ALL SELECT 0,48002,1,0,'自定义5'     ,'InheritId_self_Zdy5',0,5,'','',16,-1,-1,-1,1,'',0,0,1,0,0,0
UNION ALL SELECT 0,48002,1,0,'自定义6'     ,'InheritId_self_Zdy6',0,5,'','',17,-1,-1,-1,1,'',0,0,1,0,0,0
END
GO
--出库明细自定义字段
if not exists(select 1 from sys_sdk_BillFieldInfo where BillType=62001 and ListType=1)
begin
insert into sys_sdk_BillFieldInfo(ModuleType, BillType, ListType, InheritId, Title, DBName, UiType, DbType, Unit, Remark,ShowIndex,
									 Colspan, Rowspan, Display,IsUsed, SourceTag, cansearch,candc, candr, cantj,mustfillin,DefWidth)
		  SELECT 0,62001,1,0,'产品名称'    ,'InheritId_self_title',0,5,'','',1,-1,-1,-1,1,'',0,0,1,0,0,0
UNION ALL SELECT 0,62001,1,0,'产品编号'    ,'InheritId_self_order1',0,5,'','',2,-1,-1,-1,1,'',0,0,1,0,0,0
UNION ALL SELECT 0,62001,1,0,'产品型号'    ,'InheritId_self_type1',0,5,'','',3,-1,-1,-1,1,'',0,0,1,0,0,0
UNION ALL SELECT 0,62001,1,0,'单位'        ,'InheritId_self_unit',0,5,'','',4,-1,-1,-1,1,'',0,0,1,0,0,0
UNION ALL SELECT 0,62001,1,0,'数量'        ,'InheritId_self_num1',0,5,'','',5,-1,-1,-1,1,'',0,0,1,0,0,0
UNION ALL SELECT 0,62001,1,0,'到货日期'    ,'InheritId_self_date2',0,5,'','',6,-1,-1,-1,1,'',0,0,1,0,0,0
UNION ALL SELECT 0,62001,1,0,'备注'        ,'InheritId_self_intro',0,5,'','',7,-1,-1,-1,1,'',0,0,1,0,0,0
UNION ALL 
  select 0,62001,1,Id,title,'InheritId_id_' + cast(id as varchar(10)),UiType,DbType,Unit,Remark,7+ShowIndex,Colspan,Rowspan,Display,IsUsed,SourceTag,cansearch,candc,candr,cantj,mustfillin,DefWidth
  from  sys_sdk_BillFieldInfo
  where  billtype = 16001
END
GO
if not exists(select 1 from setopen where sort1='202072415')
begin
    insert into setopen(intro,sort1) values('1',202072415)
END

GO

IF NOT EXISTS(SELECT 1 FROM dbo.home_usConfig WHERE name ='V3198Powerby5035-18')
BEGIN
	UPDATE b SET b.qx_open = a.qx_open FROM dbo.power a
	INNER JOIN dbo.power b ON a.ord = b.ord AND a.sort1 = b.sort1 AND b.sort2 = 18
	WHERE a.sort1 = 5035 AND a.sort2 = 17 AND a.qx_open = 1
	INSERT INTO dbo.home_usConfig(name,nvalue,tvalue,[uid])VALUES('V3198Powerby5035-18',1,N'',0)
END

GO

IF NOT EXISTS(SELECT 1 FROM dbo.home_usConfig WHERE name ='V3198CostsNotionalPooling')
BEGIN
    update M2_OrderCostsShare set sharemode=1,feetype=1,isold=1 where isnull(sharemode,0)=0
    update M2_OrderCostsSharelist set isold=1 where isnull(isold,0)=0
	update M2_OrderCostsNotionalPoolingList set FromType=1,FeeType=1,NotionalPoolingMode=1 where isnull(FromType,0)=0
    update A set A.iscostcollect=1  from paybxlist A inner join M2_ChargeNotionalPooling B on A.id=B.payid where B.del=1
    update A set A.iscostcollect=1  from paybxlist A inner join M2_OrderCostsNotionalPoolingList B on A.id=B.PaybxlId where B.del=1 and b.FromType=1
	INSERT INTO dbo.home_usConfig(name,nvalue,tvalue,[uid])VALUES('V3198CostsNotionalPooling',1,N'',0)
END


GO

if not exists(select top 1 1 from dbo.home_usConfig where name='synchronizationDataTocaigouthlistForZdymx')
begin
	--处理采购退货明细自定义顺序
	update zdymx set sort=1 where sort1=75 and sorce=12 --交货日期
	update zdymx set sort=1 where sort1=75 and sorce=8 --批号
	update zdymx set sort=1 where sort1=75 and sorce=9 --序列号
	update zdymx set sort=1 where sort1=75 and sorce=11 --有效日期
	update zdymx set sort=1 where sort1=75 and sorce=10 --生产日期

    insert into home_usConfig (name, nvalue, uid) values ('synchronizationDataTocaigouthlistForZdymx', 1, 0)
end

GO
--V31.98成本核算主表老数据处理
update [M2_CostComputation] set  complete1=2 where complete1=1 and dataversion is  NULL;
update [InventoryCost] set  complete1=2 where complete1=1 and dataversion is  NULL;
update kuin set kuin.M2_outlistId = M2QTL.bid
	from kuinlist kuin   
	inner	join M2_QualityTestingLists M2QTL on (kuin.M2_QTLID = M2QTL.ID or  kuin.M2_BFID = M2QTL.ID ) and kuin.del = 1   
	inner join M2_QualityTestings M2QT on M2QTL.QTID = M2QT.ID and M2QT.del = 1  
where kuin.del = 1 
and M2QT.poType=1
and kuin.sort1 in (5,13,14,15)
and isnull(kuin.M2_outlistId,0)=0

GO

--V31.98产品分类库存变动表用户列设置数据处理
if not exists(select top 1 1 from dbo.home_usConfig where name='497788e999b16d93')
begin
	select id , '金额' dbname , 1 step INTO #lvws from erp_sys_LvwConfig where lvwid='497788e999b16d93'
	IF exists(select 1 from #lvws)
	BEGIN 
		--删除【产品分类库存变动表】用户自定义列设置中的金额字段
		delete from erp_sys_LvwColConfig where exists(select id from #lvws a where a.id = erp_sys_LvwColConfig.cfgid and erp_sys_LvwColConfig.dbname like '%' + a.dbname )
		 --重新分配newdbindex的值，否则会出现下标越界报错
		update a set a.newdbindex=c.ninx + b.step
		from [erp_sys_LvwColConfig] a 
		inner join #lvws b on a.cfgid=b.id
		inner join (
			select ROW_NUMBER()over(partition by a.cfgid order by a.newdbindex) ninx, a.cfgid, a.newdbindex
			from [erp_sys_LvwColConfig] a 
			inner join #lvws b on a.cfgid=b.id
		)c on c.cfgid=a.cfgid and c.newdbindex=a.newdbindex
	END 
	drop table #lvws
	insert into home_usConfig (name, nvalue, uid) values ('497788e999b16d93', 1, 0)
end

GO

IF NOT EXISTS(SELECT 1 FROM dbo.home_usConfig WHERE name = 'V3198MaterialRegisterCBPrice')
BEGIN
	UPDATE mro SET mro.cbprice = isnull((case when  isnull(p.pricemode,0) =2 and k.sort1 not in (2,8) then k2.pricemonth else k2.price1 end)* isnull(mro.num1,0)/nullif(mro.num,0),0),
	mro.cbmoney = ISNULL((case when  isnull(p.pricemode,0) =2 and k.sort1 not in (2,8) then k2.pricemonth else k2.price1 end) * isnull(mro.num1,0),0)
	FROM dbo.M2_RegisterOccupy mro
	INNER JOIN dbo.M2_MaterialRegisterLists mrl ON mrl.ID = mro.MRLID
	LEFT JOIN dbo.product p ON mrl.ProductID = p.ord
	LEFT JOIN dbo.kuoutlist2 k2 ON mro.kuoutlist2 = k2.id
	LEFT JOIN dbo.kuout k on k.ord = k2.kuout
	WHERE mro.num > 0 AND mro.cbprice = 0 AND mro.cbmoney = 0
	INSERT INTO dbo.home_usConfig(name,nvalue,uid)VALUES('V3198MaterialRegisterCBPrice',1,0)
END

GO

IF EXISTS ( SELECT 1 FROM dbo.M2_WorkAssigns WHERE del=1 and Status = 2 AND TerminationTime IS NULL )
BEGIN
    UPDATE  wa
    SET     wa.TerminationTime = tr.TerminationTime
    FROM    dbo.M2_WorkAssigns wa
            JOIN ( SELECT   a.ID , MAX(ISNULL(b.inDate, a.inDate)) TerminationTime
                   FROM     dbo.M2_WorkAssigns a
                            LEFT JOIN dbo.M2_ProcedureProgres b ON a.ID = b.WAID
                   WHERE    ISNULL(a.Status, 0) = 2 AND a.TerminationTime IS NULL AND a.del = 1 AND ISNULL(b.del, 1) = 1
                   GROUP BY a.ID
                 ) tr ON wa.ID = tr.ID;
END

GO

IF EXISTS ( SELECT 1 FROM dbo.M2_WFP_Assigns WHERE del=1 AND  Finished = 1 AND TerminationTime IS NULL )
BEGIN
    SELECT  a.ID , MAX(ISNULL(c.inDate, b.inDate)) TerminationTime
    INTO    #tmpTerTime
    FROM    dbo.M2_WFP_Assigns a
            JOIN dbo.M2_WorkAssigns b ON a.WAID = b.ID
            LEFT JOIN dbo.M2_ProcedureProgres c ON a.ID = c.WFPAID
    WHERE   ISNULL(a.Finished, 0) = 1 AND a.TerminationTime IS NULL AND a.del = 1 AND ISNULL(c.del, 1) = 1
    GROUP BY a.ID;
    
    UPDATE  was SET was.TerminationTime = tr.TerminationTime
    FROM    dbo.M2_WFP_Assigns was
            JOIN #tmpTerTime tr ON was.ID = tr.ID;
        
    UPDATE  a SET a.TerminationTime = b.TerminationTime
    FROM    dbo.M2_ProcessExecution_Plan a
            JOIN #tmpTerTime b ON a.NodeID = b.ID
    WHERE   a.TerminationTime IS NULL AND ISNULL(a.Finished, 0) = 1;
    Drop table #tmpTerTime;
END

GO

--处理质检、生产订单历史数据（99迭代之前）
if not exists(SELECT 1 FROM dbo.home_usConfig WHERE name='OldDataManuOrderListsExecStatus5' and nvalue=1)
begin
   --处理生产订单明细的执行状态老数据
   exec erp_UpdateManuOrderListsExecStatusByIdOrWaidsOrOutIds '',0
   --处理质检单的入库状态
   exec erp_UpdateQCRKStatusByKuinIDOrQCId '',0
   --处理质检单的返工状态
   exec erp_UpdateQCFGStatusByFGIDOrQCId '',0
   --处理委外质检入库，报废入库，返工状态
   exec erp_UpdateOutQCRKStatusByKuinIDOrQCId '',0
   insert into dbo.home_usConfig(name,nvalue,tvalue,uid)values('OldDataManuOrderListsExecStatus5',1,'',0)
end
GO

--历史数据（3202迭代之前）
if not exists(SELECT 1 FROM dbo.home_usConfig WHERE name='OldData3202AndTask7113history4' and nvalue=1)
begin
    --处理工序委外明细增加字段WAID
    update a set a.WAID=b.WAID 
    from dbo.M2_OutOrderlists a
    inner join dbo.M2_WFP_Assigns b on a.WFPAID=b.ID
    where b.isOut=1
    --登记明细与出库关系表增加登记单ID
    update a set a.MRID=b.MRID from dbo.M2_RegisterOccupy a
    inner join dbo.M2_MaterialRegisterLists b on a.MRLID=b.ID
    where isnull(a.MRID,0)=0

   --退料，废料明细增加出库申请ID
    update a set a.kuoutlist=b.kuoutlist 
    from dbo.M2_MaterialRegisterLists a
    inner join dbo.kuoutlist2 b on a.kuoutlist2=b.id
    --处理物料分析明细的预购终止数量
    exec dbo.erp_UpdateMaterialAnalysisStopNumByYGID ''
    insert into dbo.home_usConfig(name,nvalue,tvalue,uid)values('OldData3202AndTask7113history4',1,'',0)
end
GO

IF EXISTS(SELECT 1 FROM dbo.M2_OutOrder WHERE del=1 AND Stopstatus=1 AND TerminationTime IS NULL)
BEGIN
	UPDATE oor SET oor.TerminationTime=tr.TerminationTime FROM dbo.M2_OutOrder oor JOIN (
	SELECT oo.ID,MAX(ISNULL(qt.indate,oo.indate)) TerminationTime 
	FROM dbo.M2_OutOrder oo JOIN dbo.M2_OutOrderlists ool ON oo.ID=ool.outID
	LEFT JOIN dbo.M2_QualityTestingLists qtl ON ool.ID=qtl.bid
	LEFT JOIN dbo.M2_QualityTestings qt ON qt.ID=qtl.QTID
	WHERE oo.Stopstatus=1 AND oo.terminationTime IS NULL AND ISNULL(qt.poType ,1) IN (1,2) AND ISNULL(qt.del,1)=1
	GROUP BY oo.ID) tr ON oor.ID=tr.ID
END 

GO

if not exists(select top 1 1 from  ProductPriceMode_log )
begin
	--处理计价方式修改老数据
	insert into  ProductPriceMode_log(productid, oldpricemode,  newpricemode,  modifytime,  modifyuser)
	select 
		m.ord as productid, 
		n.priceMode as oldPriceModel ,
		m.priceMode as newPrice,
		m.xgTime,
		m.xgOrd 
	from (
		select  
			ord,  x.priceMode,  ( select max(id) from product_log m where m.id<x.id and x.ord=m.ord and m.mark=0)  as preid,
			xgTime , xgOrd
		from  (
				select  id,  ord,  	priceMode,  xgTime , xgOrd from product_log  x1 where mark=0
				union all
				select 2000000000,  ord, priceMode,  date7,  addcate  from product
		) x 
	) m inner join product_log n on m.preid = n.id 
	where m.priceMode! = n.priceMode
end

GO

IF NOT EXISTS(SELECT 1 FROM dbo.home_usConfig WHERE name = 'productsortdeal')
BEGIN
	update menu set fullsort=isnull(fullsort,0),deep=isnull(deep,1) where ProToSame=1000000
	INSERT INTO dbo.home_usConfig(name,nvalue,uid)VALUES('productsortdeal',1,0)
END

GO

declare @n nvarchar(400)
select @n=name  from sys.indexes  where  OBJECT_ID=OBJECT_ID(N'UniqueLogin')
if isnull(@n, '')<>'' 
begin
	set @n = N'ALTER TABLE dbo.UniqueLogin DROP CONSTRAINT ' + @n;
	exec(@n);
end

GO
if exists (select name from sysobjects where NAME = 'ERP_dboption' and type='P')
begin
    exec ERP_dboption [@@SQLDBName],'ARITHABORT','true'
end

GO

--删除权限记录重复的问题
delete power where id in (
	select t2.id  from (
		select  sort1, sort2, ord,  max(id) as minid  from [power] 
		group by sort1, sort2, ord
		having  count(1)>1 
	)  t1 inner join  [power]  t2 on t1.ord=t2.ord and t1.sort1=t2.sort1 and t1.sort2=t2.sort2
	and t2.id<t1.minid
)

GO

--删除权限分类重复的问题
delete from  qxlblist where id in (select max(id) id from qxlblist  group by sort1,sort2 having count(1)>1)
GO
--添加发货列表索引
IF NOT EXISTS (select 1 from dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[send]') AND name = N'_dta_index_send_list')
CREATE NONCLUSTERED INDEX [_dta_index_send_list] ON [dbo].[send]
(
	[del] ASC,
	[date1] ASC,
	[company] ASC,
	[order1] ASC,
	[ord] ASC,
	[date7] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]

GO
--添加发货明细表索引
IF NOT EXISTS (select 1 from dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[send]') AND name = N'_dta_index_send_list')
CREATE NONCLUSTERED INDEX [_dta_index_send_list] ON [dbo].[sendlist]
(
	[complete1] ASC,
	[del] ASC,
	[kuoutlist] ASC,
	[ord] ASC,
	[unit] ASC,
	[send] ASC,
	[contractlist] ASC
)
INCLUDE ( 	[num1]) WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO
--添加发货详情索引
IF NOT EXISTS (select 1 from dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[MCostLog]') AND name = N'_dta_index_MCostLog_RootBillListid')
CREATE NONCLUSTERED INDEX [_dta_index_MCostLog_RootBillListid]
ON [dbo].[MCostLog] ([RootBillListid])
INCLUDE ([RootKuinListId])

GO
--考勤处理权限优化
IF NOT EXISTS(SELECT 1 FROM dbo.home_usConfig WHERE name = 'KQdeal3199')
BEGIN
     update power set qx_open=3,qx_intro='0' where sort1=80 and sort2=17
	 INSERT INTO dbo.home_usConfig(name,nvalue,uid)VALUES('KQdeal3199',1,0)
END

GO
--库存预警公式插入
IF NOT EXISTS(SELECT 1 FROM dbo.home_usConfig WHERE name = 'YJLimitPercentage')
BEGIN
	 INSERT INTO dbo.home_usConfig(name,nvalue,tvalue,uid)VALUES('YJLimitPercentage',100,1,0)
END

GO

--周转码历史数据新增列数据填充
SELECT WAID,CodeText,Creator,InDate,
CASE WHEN dbo.SplitItem(CodeText,'@',0)='54002' THEN '0' ELSE '1' END AS Ptype, 
dbo.SplitItem(CodeText,'@',1) AS WABH,
dbo.SplitItem(CodeText,'@',2) AS Num,
dbo.SplitItem(CodeText,'@',3) AS SeriNum,
dbo.SplitItem(CodeText,'@',4) AS ScanBH
INTO #tmpScanCode
FROM dbo.M2_WorkAssignScanCode
WHERE Ptype IS NULL AND WABH IS NULL AND Num IS NULL AND SeriNum IS NULL AND ScanBH IS NULL

UPDATE dbo.M2_WorkAssignScanCode 
SET Ptype=wa.Ptype,WABH=wa.WABH,Num=wa.Num,SeriNum=wa.SeriNum,ScanBH=wa.ScanBH
FROM #tmpScanCode wa
WHERE wa.WAID=dbo.M2_WorkAssignScanCode.WAID
AND wa.CodeText=dbo.M2_WorkAssignScanCode.CodeText
AND wa.Creator=dbo.M2_WorkAssignScanCode.Creator
AND wa.InDate=dbo.M2_WorkAssignScanCode.InDate

DROP TABLE #tmpScanCode

GO

--处理成本核算老数据升级出库单仓库字段异常数据
IF NOT EXISTS(SELECT 1 FROM dbo.home_usConfig WHERE name = 'MCostLogKuoutCKID')
BEGIN
    IF EXISTS(select TOP 1 1 from MCostLog a inner join kuoutlist2 b on a.JoinBillListId=b.id where a.LogType=101 and a.CkId<>b.ck)
    BEGIN
        update a set a.ckid=b.ck from MCostLog a inner join kuoutlist2 b on a.JoinBillListId=b.id where a.LogType=101 and a.CkId<>b.ck
    END
    INSERT INTO dbo.home_usConfig(name,nvalue,tvalue,uid)VALUES('MCostLogKuoutCKID',100,1,0)
END
GO
--给入库主单status字段赋正确值
IF NOT EXISTS(SELECT 1 FROM dbo.home_usConfig WHERE name = 'KuinStatusHandle')
BEGIN
    update a set a.status=-1 from kuin a where (sort1=10 and status=0) or status is null
    INSERT INTO dbo.home_usConfig(name,nvalue,tvalue,uid)VALUES('KuinStatusHandle',100,1,0)
END
GO
--给采购明细Y_Num1字段赋值
IF NOT EXISTS(SELECT 1 FROM dbo.home_usConfig WHERE name = 'CaigoulistY_Num1Handle')
BEGIN
    update caigoulist set Y_Num1=num1 where Y_Num1=0
    INSERT INTO dbo.home_usConfig(name,nvalue,tvalue,uid)VALUES('CaigoulistY_Num1Handle',100,1,0)
END
GO
--入库主单自定义字段升级
if not exists(select top 1 1 from sys_sdk_BillFieldInfo where BillType=61001 and ListType=0)
begin
    select ord,zdy1,zdy2,zdy3,zdy4,zdy5,zdy6 into #tempMainTable from kuin;
    exec [MainZdyToBillFieldInfo] 61001,31;
end
--入库明细自定义字段升级
if not exists(select top 1 1 from sys_sdk_BillFieldInfo where BillType=61001 and ListType=1)
begin
    select id,kuin AS mainId,zdy1,zdy2,zdy3,zdy4,zdy5,zdy6 into #tempListTable from kuinlist;
    exec [ListZdyToBillFieldInfoByOldBill] 61001, 31 , '';
end
--入库明细自定义字段升级
if exists(select 1 from sys_sdk_BillFieldInfo where BillType=61001 and ListType=1 and dbname = 'InheritId_self_unitall')
begin
	update a set a.DBName='InheritId_self_unit' from sys_sdk_BillFieldInfo a where BillType=61001 and ListType=1 and a.DBName='InheritId_self_unitall'
end

if exists(select 1 from sys_sdk_BillFieldInfo where BillType=61001 and ListType=1 and dbname = 'InheritId_self_price1')
begin
	update a set a.DBName='InheritId_self_price2' from sys_sdk_BillFieldInfo a where BillType=61001 and ListType=1 and a.DBName='InheritId_self_price1'
	update a set a.DBName='InheritId_self_money2' from sys_sdk_BillFieldInfo a where BillType=61001 and ListType=1 and a.DBName='InheritId_self_money1'
end


GO
--发货老数据升级
if not exists(select 1 from sys_sdk_BillFieldInfo where BillType=68001 and ListType=0 )
begin
    select ord,zdy1,zdy2,zdy3,zdy4,zdy5,zdy6 into #tempMainTable from Send;
    exec [MainZdyToBillFieldInfo] 68001,33;
end

GO

if not exists(select 1 from home_usConfig where name='DetailHb')
begin
    insert dbo.home_usConfig(tvalue,name,uid) values ('1', 'DetailHb',0)

    insert into S2_SerialNumberRelation(SerialID,BillType,BillID,BillListType,ListID,Del)
    select S2_SerialNumberRelation.SerialID,68001,sendlist.send,1,sendlist.id,2 from sendlist 
    inner join kuoutlist2 k2 on k2.id= sendlist.kuoutlist
    inner join S2_SerialNumberRelation on S2_SerialNumberRelation.ListID=k2.id and S2_SerialNumberRelation.BillType=62001 and S2_SerialNumberRelation.BillListType=1
    and NOT EXISTS(select top 1 1 from S2_SerialNumberRelation where BillType=68001 and BillID=sendlist.send and sendlist.id=ListID)
    and sendlist.del=1
end
GO
--发货明细自定义字段老数据升级
IF not exists(select 1 from sys_sdk_BillFieldInfo  b  where  b.billtype=68001 and b.ListType='1')
begin
    update zdymx set name='porder1' where sort1=33 and name='order1'
    update zdymx set name='price1' where sort1=33 and name='intro'
    select id,send AS mainId,zdy1,zdy2,zdy3,zdy4,zdy5,zdy6 into #tempListTable from sendlist;
    exec [ListZdyToBillFieldInfoByOldBill]68001, 33 , '';
end
GO
if exists(select 1 from contract_out  where sort=4)
begin
    update PrintTimes set Datatype=68001 where Datatype=4
    update  PrintTemplate_Type set ord=68001,oldurl='../contract/planall_out.asp?sort=68001&main=1' where ord=4
    update  contract_out set sort=68001,PrintID=(case when PrintID=4 then 68001 else PrintID end) where sort=4
    update  sys_upload_res set id1=68001 where id1=4
end
GO
--V3201-预购升级-老数据处理
if not exists(select 1 from Erp_Sys_UpdateSign where SignName='V3201YuGouUpdateOldData' )
begin
	--1.预购通知替换新地址
		update ReminderConfigs set moreLinkUrl='../../SYSN/view/store/yugou/Yugoulist.ashx?remind=@cfgId',detailLinkUrl='../../SYSN/view/store/yugou/YuGou.ashx?ord=@encodeId&view=details' where setjmId=141;
		update ReminderConfigs set moreLinkUrl='../../SYSN/view/store/yugou/Yugoulist.ashx?remind=@cfgId',detailLinkUrl='../../SYSN/view/store/yugou/YuGou.ashx?ord=@encodeId&view=details' where setjmId=220;
	--1.1首页-工作台-用户自定义常用栏目替换新地址
		update home_mainlink_config set url='sys:../../SYSN/view/store/yugou/YuGou.ashx?OpenType=1' where url like '%caigou/add3_yg.asp%';
		update home_mainlink_config set url='sys:../../SYSN/view/store/yugou/Yugoulist.ashx' where url like '%caigou/planall13.asp%';
		update home_mainlink_config set url='sys:../../SYSN/view/store/yugou/YuGouScheduleList.ashx' where url like '%tongji/ygmxlist.asp%';
	--2.预购权限处理
		--删除 修改明细
		delete a 
		from power a 
		inner join qxlblist b on a.sort1=b.sort1 and a.sort2=b.sort2
		where b.sort1=25 and b.sort2=23
		delete from qxlblist where sort1=25 and sort2=23
	--3.新增策略
		--预购明细供应商默认值控制
		if not exists(select intro from setopen where sort1=2021070501)
		begin
			insert into setopen(intro,sort1,extra)
			values(1,2021070501,NULL);
		end
		--预购单审批通过后的修改控制
		if not exists(select intro from setopen where sort1=2021070511)
		begin
			insert into setopen(intro,sort1,extra)
			values(0,2021070511,NULL);
		end
		--预购&采购产品角色范围控制
		if not exists(select intro from setopen where sort1=2021070521)
		begin
			insert into setopen(intro,sort1,extra)
			values(1,2021070521,NULL);
		end
		--预购生成询价策略控制
		if not exists(select intro from setopen where sort1=2016091801)
		begin
			insert into setopen(intro,sort1,extra)
			values(1,2016091801,NULL);
		end
		--预购生成采购价格策略控制
		if not exists(select intro from setopen where sort1=2016092001)
		begin
			insert into setopen(intro,sort1,extra)
			values(1,2016092001,NULL);
		end
		--预购价格策略
		if not exists(select intro from setopen where sort1=40)
		begin
			insert into setopen(intro,sort1,extra)
			values(0,40,NULL);
		end
		if not exists(select intro from setopen where sort1=2016091803)
		begin
			insert into setopen(intro,sort1,extra)
			values(0,2016091803,NULL);
		end
		if not exists(select intro from setopen where sort1=2016091804)
		begin
			insert into setopen(intro,sort1,extra)
			values(0,2016091804,NULL);
		end
		if not exists(select intro from setopen where sort1=2016091805)
		begin
			insert into setopen(intro,sort1,extra)
			values(0,2016091805,NULL);
		end
		--重复预购策略
		if not exists(select intro from setopen where sort1=2016091807)
		begin
			insert into setopen(intro,sort1,extra)
			values(0,2016091807,NULL);
		end
		if not exists(select intro from setopen where sort1=2016091808)
		begin
			insert into setopen(intro,sort1,extra)
			values(0,2016091808,NULL);
		end
		if not exists(select intro from setopen where sort1=2016091806)
		begin
			insert into setopen(intro,sort1,extra)
			values(0,2016091806,NULL);
		end
	    --4.预购扩展字段自定义
		if not exists(select 1 from sys_sdk_BillFieldInfo where BillType=72001 and ListType = 0)
		begin
			--同步字段
			exec [MainZdyToBillFieldInfo] 72001,25;
			--同步值
			INSERT INTO sys_sdk_BillFieldValue(BillType,BillListType,BillId,ListID,FieldId,Value , InheritId)
			SELECT 72001,0,cv.OrderID,0,bfi.Id,cv.FValue, bfi.id
			FROM sys_sdk_BillFieldInfo bfi
			inner join ERP_CustomFields cf on cf.TName=25 AND Replace(bfi.DBName,'Netext','')=cf.ID
			inner join erp_customValues cv on cv.FieldsID=cf.ID
			WHERE BFI.BILLTYPE=72001 AND bfi.DBName LIKE '%Netext%'
		end
	--5.预购明细自定义		
		if not exists(select 1 from sys_sdk_BillFieldInfo where BillType=72001 and ListType='1')
		begin
			select id,caigou AS mainId,zdy1,zdy2,zdy3,zdy4,zdy5,zdy6 into #tempListTable from caigoulist_yg;
			exec [ListZdyToBillFieldInfoByOldBill] 72001,25,NULL	
		end
	--7.预购流程处理
		--7.1新增审批规则
			EXEC dbo.erp_ApproveList 63,72001,-1,26
	    --7.2更新预购单据审批状态，旧：0:审批通过，1:待审批，2:审批中，-1:审批未通过，新：0:审批否决，1:审批通过，2:审批退回，3:待提交，4待审批，5:审批中
			update caigou_yg set status=case isnull(status,-99) when -1 then 0 when 0 then 1 when 1 then 4 when 2 then 5 when 3 then 4 else -1 end
		--7.3更新历史审批实例
			insert into sp_ApprovalInstance(
			                ApprovalRulesId,ApprovalProcessId,gate2, sptype,PrimaryKeyID,BillRight,
			                ApprovalFlowStatus,Approver,BillPattern,CreateTime,UserID,Bounds , SurplusApprover ,  ApprovalType , ApprovalRelation,Gate1)
			select sr.ApprovalRulesID, p.sp , sr.gate2 ,-1 , p.id , '预购权限' , p.status , p.cateid_sp,0 , getdate(), 63, 1 , p.cateid_sp ,  0 ,  3 ,s.gate1
			from caigou_yg p 
			inner join sp s on s.id = p.sp
			inner join sp_ApprovalRules sr on sr.gate2= 72001 and sr.sptype=isnull(s.Sptype,-1)
			where exists(select 1 from sp_intro where sort1=72001 and ord = p.id) or p.status in (3,4,5)
				and not exists(select 1 from sp_ApprovalInstance where gate2=72001 and PrimaryKeyID = p.id)
		--7.3更新历史审批实例（处理审批通过数据）
			insert into sp_ApprovalInstance(
			                ApprovalRulesId,ApprovalProcessId,gate2, sptype,PrimaryKeyID,BillRight,
			                ApprovalFlowStatus,Approver,BillPattern,CreateTime,UserID,Bounds , SurplusApprover ,  ApprovalType , ApprovalRelation,Gate1)
			select sr.ApprovalRulesID, p.sp , sr.gate2 ,-1 , p.id , '预购权限' , p.status , spi.cateid,0 , getdate(), 63, 1 , '' ,  0 ,  s.gate3 ,s.gate1
			from caigou_yg p 
			inner join (SELECT MAX(it.id) id,it.ord FROM sp_intro it WHERE it.sort1 = 72001 GROUP BY it.ord)t on p.id=t.ord
			inner join sp_intro spi ON spi.id= t.id  
			inner join sp s on s.id = spi.sp_id
			inner join sp_ApprovalRules sr on sr.gate2= 72001 and sr.sptype=isnull(s.Sptype,-1)
			where exists(select 1 from sp_intro where sort1=72001 and ord = p.id) and p.status in (1)
				and not exists(select 1 from sp_ApprovalInstance where gate2=72001 and PrimaryKeyID = p.id)
		--7.4更新历史审批记录关系
			update so set so.InstanceID=st.InstanceID ,so.ApproverName = g.name,so.ApproverDept='',so.ApprovalResult=1, so.IsAutoPass=0,
				so.ApprovalType = '单审', so.gate3=3 , so.Operator =  g.name, so.CreateTime = so.date1 , so.OperationTime = so.date1 ,
				so.ApprovalLevel = sp.gate1, so.nextSpID = 0 , so.currNodeApprover = so.cateid,jg=case when so.jg=2 then 0 else so.jg end
			from sp_intro so
			inner join sp_ApprovalInstance st on st.gate2 = 72001 and st.PrimaryKeyID = so.ord
			left join gate g on g.ord= so.cateid
			left join sp on sp.id = so.sp_id
			where so.sort1 = 72001
		--7.5更新新流程审批人员
		update sp set intro=replace(intro,' ','') where gate2=72001
	--end.增加升级标识
	insert into Erp_Sys_UpdateSign(SignName,SignValue) values('V3201YuGouUpdateOldData',1)
end
GO
--V3201-采购升级-老数据处理
if not exists(select 1 from Erp_Sys_UpdateSign where SignName='V3201CaiGouUpdateOldData' )
begin
--1.采购通知替换新地址
	update ReminderConfigs set moreLinkUrl='../../SYSN/view/store/caigou/CaigouList.ashx?remind=@cfgId' where setjmId=16;
	update ReminderConfigs set moreLinkUrl='../../SYSN/view/store/caigou/CaigouList.ashx?remind=@cfgId' where setjmId=140;
--1.1首页-工作台-用户自定义常用栏目替换新地址
	update home_mainlink_config set url='sys:../../SYSN/view/store/caigou/caigou.ashx?OpenType=1' where url like '%caigou/add3.asp%';
	update home_mainlink_config set url='sys:../../SYSN/view/store/caigou/CaigouList.ashx' where url like '%caigou/planall.asp%';
--2.新增策略
	--当勾选“录入采购单时选择是否需要来料质检”出现设置置默认值内容：(默认勾选“不需要质检”)
	if not exists(select intro from setopen where sort1=320173101)
	begin
		insert into setopen(intro,sort1,extra)
		values(0,320173101,NULL);
	end
	--采购主题策略（来源上级单据）(默认勾选“转自xxx：上级单据主题”)
	if not exists(select intro from setopen where sort1=320173102)
	begin
		insert into setopen(intro,sort1,extra)
		values(1,320173102,NULL);
	end
	--采购流程设置(默认为未勾选状态)
	if not exists(select intro from setopen where sort1=320173103)
	begin
		insert into setopen(intro,sort1,extra)
		values(0,320173103,NULL);
	end
	--采购单审批通过后的修改控制(默认无需审批)
	if not exists(select intro from setopen where sort1=320173104)
	begin
		insert into setopen(intro,sort1,extra)
		values(0,320173104,NULL);
	end
	--采购删除策略(默认为未勾选状态)
	if not exists(select intro from setopen where sort1=320173105)
	begin
		insert into setopen(intro,sort1,extra)
		values(0,320173105,NULL);
	end
--3.采购分类简称处理
	update sortonehy set color=dbo.getPinYin(sort1) where gate2=71
--4.采购扩展字段自定义
	if not exists(select 1 from sys_sdk_BillFieldInfo where BillType=73001)
	begin
		--同步字段
		select ord,zdy1,zdy2,zdy3,zdy4,zdy5,zdy6 into #tempMainTable from caigou
		exec [MainZdyToBillFieldInfo] 73001,22;
		--同步值
		INSERT INTO sys_sdk_BillFieldValue(BillType,BillListType,BillId,ListID,FieldId,Value,InheritId)
		SELECT 73001,0,cv.OrderID,0,bfi.Id,cv.FValue, bfi.id
		FROM sys_sdk_BillFieldInfo bfi
		inner join ERP_CustomFields cf on cf.TName=22 AND Replace(bfi.DBName,'Netext','')=cf.ID
		inner join erp_customValues cv on cv.FieldsID=cf.ID
		WHERE BFI.BILLTYPE=73001 AND bfi.DBName LIKE '%Netext%'
	end
--5.采购明细自定义		
	if not exists(select 1 from sys_sdk_BillFieldInfo where BillType=73001 and ListType='1')
	begin
		update zdymx set name='unit' where sort1=22 and name='unitall';
		select id,caigou AS mainId,zdy1,zdy2,zdy3,zdy4,zdy5,zdy6 into #tempListTable from caigoulist;
		exec [ListZdyToBillFieldInfoByOldBill] 73001,22,NULL	
	end
--6.采购流程处理
	--6.1新增审批规则
		EXEC dbo.erp_ApproveList 63,73001,-1,3
    --6.2更新采购单据审批状态，旧：0:审批通过，1:待审批，2:审批中，-1:审批未通过，新：0:审批否决，1:审批通过，2:审批退回，3:待提交，4待审批，5:审批中
		update cg set status=case when isnull(cg.sp,-99)=-1 then 0 
								  when isnull(cg.sp,-99)=0 then 1 
								  when isnull(cg.sp,-99)>0 and isnull(si.ord,-1)=-1 then 4 
								  when isnull(cg.sp,-99)>0 and isnull(si.ord,-1)!=-1 then 5
								  else -1 end
		from caigou cg
		left join sp_intro si on cg.ord=si.ord and si.sort1=73001
	--6.3更新历史审批实例
		insert into sp_ApprovalInstance(
		                ApprovalRulesId,ApprovalProcessId,gate2, sptype,PrimaryKeyID,BillRight,
		                ApprovalFlowStatus,Approver,BillPattern,CreateTime,UserID,Bounds , SurplusApprover ,  ApprovalType , ApprovalRelation,Gate1)
		select sr.ApprovalRulesID, p.sp , sr.gate2 ,isnull(s.Sptype,-1) as sptype , p.ord , '采购权限' , p.status , p.cateid_sp,0 , getdate(), 63, 1 , p.cateid_sp ,  0 ,  3 ,s.gate1
		from caigou p 
		inner join sp s on s.id = p.sp
		inner join sp_ApprovalRules sr on sr.gate2= 73001 and sr.sptype=isnull(s.Sptype,-1)
		where  p.status in (3,4,5) and not exists(select 1 from sp_ApprovalInstance where gate2=73001 and PrimaryKeyID = p.ord)
	--6.3更新历史审批实例（处理审批通过的数据）
		insert into sp_ApprovalInstance(
		                ApprovalRulesId,ApprovalProcessId,gate2, sptype,PrimaryKeyID,BillRight,
		                ApprovalFlowStatus,Approver,BillPattern,CreateTime,UserID,Bounds , SurplusApprover ,  ApprovalType , ApprovalRelation,Gate1)
		select sr.ApprovalRulesID, p.sp , sr.gate2 ,isnull(s.Sptype,-1) as sptype , p.ord , '采购权限' , p.status , spi.cateid,0 , getdate(), 63, 1 , '' ,  0 ,  s.gate3 ,s.gate1
		from caigou p 
		inner join (SELECT MAX(it.id) id,it.ord FROM sp_intro it WHERE it.sort1 = 73001 GROUP BY it.ord)t on p.ord=t.ord
		inner join sp_intro spi ON spi.id= t.id  
		inner join sp s on s.id = spi.sp_id
		inner join sp_ApprovalRules sr on sr.gate2= 73001 and sr.sptype=isnull(s.Sptype,-1)
		where  p.status in (1) and not exists(select 1 from sp_ApprovalInstance where gate2=73001 and PrimaryKeyID = p.ord)
	--6.4更新历史审批记录关系
		update so set so.InstanceID=st.InstanceID ,so.ApproverName = g.name,so.ApproverDept='',so.ApprovalResult=1, so.IsAutoPass=0,
			so.ApprovalType = '单审', so.gate3=3 , so.Operator =  g.name, so.CreateTime = so.date1 , so.OperationTime = so.date1 ,
			so.ApprovalLevel = sp.gate1, so.nextSpID = 0 , so.currNodeApprover = so.cateid,jg=case when so.jg=2 then 0 else so.jg end
		from sp_intro so
		inner join sp_ApprovalInstance st on st.gate2 = 73001 and st.PrimaryKeyID = so.ord
		left join gate g on g.ord= so.cateid
		left join sp on sp.id = so.sp_id
		where so.sort1 = 73001
	--6.5更新新流程审批人员
		update sp set bt=2,intro=replace(intro,' ','') where gate2=73001
    --7.采购自定义编号处理
    if not exists(select 1 from zdybh where sort1=73001)
    begin 
	    insert into zdybh( title,sort,set_open,intro1,intro2,gate1, sort1)
	    select title,sort,set_open,intro1,intro2,gate1,73001 as sort1 from zdybh where sort1=22 order by gate1
        UPDATE a SET a.fieldID = b.inx FROM dbo.zdybh a
	    INNER JOIN (
		    SELECT ROW_NUMBER() OVER(ORDER BY gate1,id) inx,id FROM dbo.zdybh WHERE sort1 = 73001
	    ) b ON a.id = b.id
	    UPDATE dbo.zdybh SET sort = 6 WHERE sort1 = 73001 AND sort = 1
    end
--8.采购del标识更新（老版本del=3是待审批，现在统一改成1）
		update caigou set del=1 where del=3;
        update caigoulist set del=1 where del=3
		delete from caigou where del=7;
        delete from caigoulist where del=7
        delete from caigoulist_mx where del in (7,10)
--end.增加升级标识
	insert into Erp_Sys_UpdateSign(SignName,SignValue) values('V3201CaiGouUpdateOldData',1)
end

GO

--暂估明细自定义		
	if exists(select 1 from sys_sdk_BillFieldInfo where BillType=48002 and ListType='1' and DBName like 'InheritId_self_Zdy%')
	begin
		delete sys_sdk_BillFieldInfo where BillType=48002 and ListType=1 and DBName like 'InheritId_self_Zdy%'	
	end

 --差异成本明细自定义		
	if exists(select 1 from sys_sdk_BillFieldInfo where BillType=48003 and ListType='1' and DBName like 'InheritId_self_Zdy%')
	begin
		delete sys_sdk_BillFieldInfo where BillType=48003 and ListType=1 and DBName like 'InheritId_self_Zdy%'	
	end

--修复升级采购主单自定义没有同步数据问题
if not exists(select top 1 1 from dbo.home_usConfig where name='V3201RepairCaiGouMainZdy')
begin
    select ord,zdy1,zdy2,zdy3,zdy4,zdy5,zdy6 into #tempMainTable from caigou
    INSERT INTO [dbo].[sys_sdk_BillFieldValue]([BillType],[BillListType],[BillId],[ListID],[FieldId],[Value],[BigValue])
    SELECT 73001,  0,  cl.ord,0, a.id as [FieldId], cl.zdy1 ,null
    from sys_sdk_BillFieldInfo a
    inner join #tempMainTable cl on (len(isnull(cl.zdy1,''))>0 and a.dbname ='zdy1' ) 
    where a.ListType=0 and a.BillType =73001 and a.BillType>0 and a.dbname ='zdy1'
    and not exists(select 1 from sys_sdk_BillFieldValue where BillType=73001 and BillListType=0 and BillId=cl.ord and ListID=0 and FieldId=a.id)
    union all
    select 73001,  0,  cl.ord,0, a.id as [FieldId], cl.zdy2 ,null
    from sys_sdk_BillFieldInfo a
    inner join #tempMainTable cl on (len(isnull(cl.zdy2,''))>0 and a.dbname ='zdy2' )
    where a.ListType=0 and a.BillType =73001 and a.BillType>0 and a.dbname ='zdy2'
    and not exists(select 1 from sys_sdk_BillFieldValue where BillType=73001 and BillListType=0 and BillId=cl.ord and ListID=0 and FieldId=a.id)
    union all
    select 73001,  0,  cl.ord,0, a.id as [FieldId], cl.zdy3 ,null
    from sys_sdk_BillFieldInfo a
    inner join #tempMainTable cl on (len(isnull(cl.zdy3,''))>0 and a.dbname ='zdy3' )
    where a.ListType=0 and a.BillType =73001 and a.BillType>0 and a.dbname ='zdy3' 
    and not exists(select 1 from sys_sdk_BillFieldValue where BillType=73001 and BillListType=0 and BillId=cl.ord and ListID=0 and FieldId=a.id)
    union all
    select 73001,  0,  cl.ord,0, a.id as [FieldId], cl.zdy4 ,null
    from sys_sdk_BillFieldInfo a
    inner join #tempMainTable cl on (len(isnull(cl.zdy4,''))>0 and a.dbname ='zdy4' )
    where a.ListType=0 and a.BillType =73001 and a.BillType>0 and a.dbname='zdy4'
    and not exists(select 1 from sys_sdk_BillFieldValue where BillType=73001 and BillListType=0 and BillId=cl.ord and ListID=0 and FieldId=a.id)
    union all
    select 73001,  0,  cl.ord,0, a.id as [FieldId], s.sort1 ,null
    from sys_sdk_BillFieldInfo a
    inner join #tempMainTable cl on (isnull(cl.zdy5,0)>0 and a.dbname ='zdy5' )
    inner join sortonehy s on s.ord= cl.zdy5
    where a.ListType=0 and a.BillType =73001 and a.BillType>0 and a.dbname ='zdy5'
    and not exists(select 1 from sys_sdk_BillFieldValue where BillType=73001 and BillListType=0 and BillId=cl.ord and ListID=0 and FieldId=a.id)
    union all
    select 73001,  0,  cl.ord,0, a.id as [FieldId], s.sort1 ,null
    from sys_sdk_BillFieldInfo a
    inner join #tempMainTable cl on (isnull(cl.zdy6,0)>0 and a.dbname ='zdy6' )
    inner join sortonehy s on s.ord= cl.zdy6
    where a.ListType=0 and a.BillType =73001 and a.BillType>0 and a.dbname ='zdy6'
    and not exists(select 1 from sys_sdk_BillFieldValue where BillType=73001 and BillListType=0 and BillId=cl.ord and ListID=0 and FieldId=a.id)
    DROP TABLE #tempMainTable
    insert into home_usConfig (name, nvalue, uid) values ('V3201RepairCaiGouMainZdy', 1, 0)
end
GO
--维护二维码分类状态
IF EXISTS(SELECT 1 FROM C2_CodeTypes where del is null)
BEGIN
	 update C2_CodeTypes set del=1 where del is null
END

GO
--每次系统升级清空左侧导航动态编译DLL的值
update home_usConfig set tvalue='' where uid=0 and name='ExpressionCalculate'

GO

IF EXISTS(SELECT TOP 1 * FROM sys_upload_res WHERE id1=2 AND fname='总账.doc' AND fpath='~/SYSA/out/PrintUploadFiles/PriceTemplate/PriceTempate.doc')
BEGIN
	UPDATE dbo.sys_upload_res SET fname='报价打印模板.doc' WHERE id1=2 AND fname='总账.doc' AND fpath='~/SYSA/out/PrintUploadFiles/PriceTemplate/PriceTempate.doc'
END

GO
if not exists(select 1 from home_usConfig where name='3201updateDbback')
begin
   insert dbo.home_usConfig(tvalue,name,uid) values (CONVERT(varchar(100),GETDATE(),25), '3201updateDbback',0)
end
Go
if exists(select 1 from product where LimitBuyNum is null) update product set LimitBuyNum = 0 where LimitBuyNum is null
GO
if exists(select 1 from product where LimitProduceNum is null) update product set LimitProduceNum = 0 where LimitProduceNum is null
GO
--顶部导航配置表不应该存在ID为0的数据
if exists(select 1 from home_topmenu_item_def where  id=0) delete from home_topmenu_item_def where id=0
GO
if exists(select 1 from Home_topmenu_cls_def where  id=0) delete from Home_topmenu_cls_def where id=0
GO
if exists(select 1 from home_topmenu_cls_us where  id=0) delete from home_topmenu_cls_us where id=0

GO
if exists(select top 1 1 from kuhclist where del=3199)
begin
	insert into kuhclist_V3199(kuinlist,mxid,ord,kuid,num1,del,cateid,indate)
	select kuinlist,mxid,ord,kuid,num1,del,cateid,indate from kuhclist with(nolock) where del=3199

    delete from kuhclist where del=3199
end
GO
delete home_usConfig where name like 'ExpressionCalculate%' 
GO
if not exists(select num1 from setjm3 where ord=2017121601)
begin
	insert into setjm3(ord,num1) values(2017121601,0)
end

GO

if not exists(select 1 from home_usConfig where name='initalarmsetting')
begin
   INSERT INTO [dbo].[AlarmSetting]([ord],[TargetName],[TargetValue],[UnitBase],[UnitName],[LongUnitName] ,[UpperValue] ,[UpperTip],[LowerValue],[LowerTip],[Gate])
   VALUES(1,'销售目标预警',7200,10000,'万元','年',50,'超额完成目标',20,'未完成目标',1);
   INSERT INTO [dbo].[AlarmSetting]([ord],[TargetName],[TargetValue],[UnitBase],[UnitName],[LongUnitName] ,[UpperValue] ,[UpperTip],[LowerValue],[LowerTip],[Gate])
   VALUES(2,'人效预警',30,10000,'万元','年',50,'人效增长',20,'人效过低',2);
   INSERT INTO [dbo].[AlarmSetting]([ord],[TargetName],[TargetValue],[UnitBase],[UnitName],[LongUnitName] ,[UpperValue] ,[UpperTip],[LowerValue],[LowerTip],[Gate])
   VALUES(3,'现金预警',500,10000,'万元','月',24,'现金流过高',6,'有资金断裂风险',3);
   INSERT INTO [dbo].[AlarmSetting]([ord],[TargetName],[TargetValue],[UnitBase],[UnitName],[LongUnitName] ,[UpperValue] ,[UpperTip],[LowerValue],[LowerTip],[Gate])
   VALUES(4,'坏账预警',10,10000,'万元','年',50,'坏账严重',20,'应收正常',4);
   INSERT INTO [dbo].[AlarmSetting]([ord],[TargetName],[TargetValue],[UnitBase],[UnitName],[LongUnitName] ,[UpperValue] ,[UpperTip],[LowerValue],[LowerTip],[Gate])
   VALUES(5,'利润预警',3000,10000,'万元','年',50,'利润高',20,'利润下滑',5);
   INSERT INTO [dbo].[AlarmSetting]([ord],[TargetName],[TargetValue],[UnitBase],[UnitName],[LongUnitName] ,[UpperValue] ,[UpperTip],[LowerValue],[LowerTip],[Gate])
   VALUES(6,'库龄预警',1000,10000,'万元','年',10,'库存积压严重',0,'库存运转良好',6);
   INSERT INTO [dbo].[AlarmSetting]([ord],[TargetName],[TargetValue],[UnitBase],[UnitName],[LongUnitName] ,[UpperValue] ,[UpperTip],[LowerValue],[LowerTip],[Gate])
   VALUES(7,'库存周转率预警',6,1,'次','年',100,'运转良好',10,'周转缓慢',7);
   INSERT INTO [dbo].[AlarmSetting]([ord],[TargetName],[TargetValue],[UnitBase],[UnitName],[LongUnitName] ,[UpperValue] ,[UpperTip],[LowerValue],[LowerTip],[Gate])
   VALUES(8,'生产逾期预警',1,1,'个','月',10,'延误严重',0,'交付准时',8);

   insert dbo.home_usConfig(tvalue,name,uid) values (CONVERT(varchar(100),GETDATE(),25), 'initalarmsetting',0)
end

GO

--3201历史物料分析核定数量数据处理
if not exists(select top 1 1 from dbo.home_usConfig where name='MaterialAnalysis3201')
begin    
    UPDATE dbo.M2_MaterialAnalysisList SET HD_CurrNum=CurrNum WHERE ISNULL(HD_CurrNum,0)=0
    UPDATE dbo.M2_MaterialAnalysisList SET HD_NeedNum=NeedNum WHERE ISNULL(HD_NeedNum,0)=0
    insert into home_usConfig (name, nvalue, uid) values ('MaterialAnalysis3201', 1, 0)
end
GO
--对于历史生产领料打印模板，打印规则默认为汇总打印
if not exists(select top 1 1 from dbo.home_usConfig where name='PrintTemplateRule3202')
begin    
    UPDATE Contract_out SET printtype=1 WHERE sort=55001
    insert into home_usConfig (name, nvalue, uid) values ('PrintTemplateRule3202', 1, 0)
end
GO
--合同策略设置
if not exists(select 1 from home_usConfig where name='HtSet3202')
begin
    insert into setopen(intro,sort1) values (1,202101020)
    insert into setopen(intro,sort1) values (0,202101021)
    insert into setopen(intro,sort1) values (1,202101022)
    INSERT into dbo.home_usConfig(nvalue,name,uid) values ('0', 'HtSet3202',0)
end 

GO

--修复收票税收优惠政策类型默认值
if exists(SELECT TOP 1 1 FROM paybackinvoice WHERE TaxPreferenceType IS null)
begin    
    UPDATE paybackinvoice SET TaxPreferenceType=0 WHERE TaxPreferenceType IS null
end

GO
--合同策略设置
if not exists(select 1 from home_usConfig where name='HtYNum3202')
begin
    update contractlist set Y_num1 = num1
    INSERT into dbo.home_usConfig(nvalue,name,uid) values ('0', 'HtYNum3202',0)
end 

GO

--修复99版本新增表数据导致统计表查询异常
if exists(SELECT TOP 1 1 FROM dbo.MCostLogForKuBalance WHERE ISNULL(RevisedRemark,'')='')
begin    
    DELETE FROM dbo.MCostLogForKuBalance WHERE ISNULL(RevisedRemark,'')=''
end


GO
--Begin修复老版本字段不能为空--
if exists (select top 1 1sqlcc from information_schema.columns where table_name = 'M2_CostAnalysisBusinessResult' and column_name = 'CurrPrice')
Begin
	alter table M2_CostAnalysisBusinessResult 
	alter column CurrPrice decimal(25, 12) null
end

GO

if exists (select top 1 1sqlcc from information_schema.columns where table_name = 'M2_CostAnalysisBusinessResult' and column_name = 'CurrMoney')
Begin
	alter table M2_CostAnalysisBusinessResult 
	alter column CurrMoney decimal(25, 12) null
end

GO

if exists (select top 1 1sqlcc from information_schema.columns where table_name = 'M2_CostAnalysisBusinessResult' and column_name = 'CurrShareMoney')
Begin
	alter table M2_CostAnalysisBusinessResult 
	alter column CurrShareMoney decimal(25, 12) null
end

GO

if exists (select top 1 1sqlcc from information_schema.columns where table_name = 'M2_CostAnalysisBusinessResult' and column_name = 'CurrAllMoney')
Begin
	alter table M2_CostAnalysisBusinessResult 
	alter column CurrAllMoney decimal(25, 12) null
end

GO

if exists (select top 1 1sqlcc from information_schema.columns where table_name = 'M2_CostAnalysisBusinessResult' and column_name = 'CurrCostMoney')
Begin
	alter table M2_CostAnalysisBusinessResult 
	alter column CurrCostMoney decimal(25, 12) null
end
--End修复老版本字段不能为空--
GO
--V3202-合同升级-老数据处理
if not exists(select 1 from Erp_Sys_UpdateSign where SignName='V3202HtUpdateOldData' )
begin
    --4.合同扩展字段自定义
    if not exists(select 1 from sys_sdk_BillFieldInfo where BillType=11001 and ListType=0 )
    begin
	    --同步字段
	    select ord,zdy1,zdy2,zdy3,zdy4,zdy5,zdy6 into #tempMainTable from contract
	    exec [MainZdyToBillFieldInfo] 11001,5;
	    --同步值
	    INSERT INTO sys_sdk_BillFieldValue(BillType,BillListType,BillId,ListID,FieldId,Value,InheritId)
	    SELECT 11001,0,cv.OrderID,0,bfi.Id,cv.FValue,bfi.Id
	    FROM sys_sdk_BillFieldInfo bfi
	    inner join ERP_CustomFields cf on cf.TName=5 AND Replace(bfi.DBName,'Netext','')=cf.ID
	    inner join erp_customValues cv on cv.FieldsID=cf.ID
	    WHERE BFI.BILLTYPE=11001 AND bfi.DBName LIKE '%Netext%'
    end
    --6.合同流程处理
    --6.1新增审批规则
    EXEC dbo.erp_ApproveList 63,11001,-1,2
    --6.2更新合同单据审批状态，旧：0:审批通过，1:待审批，2:审批中，-1:审批未通过，新：0:审批否决，1:审批通过，2:审批退回，3:待提交，4待审批，5:审批中
    update cg set status=case   when isnull(cg.SortType,1) in (2,5,8) then -1
                                when isnull(cg.Sort1,0) in (1,7) then -1
                                when isnull(cg.sp,-99)=-1 then 0 
							    when isnull(cg.sp,-99)=0 and isnull(si.ord,-1)<>-1  then 1 
								when isnull(cg.sp,-99)=999999 then 2 
							    when isnull(cg.sp,-99)>0 and isnull(si.ord,-1)=-1 then 4 
							    when isnull(cg.sp,-99)>0 and isnull(si.ord,-1)!=-1 then 5
							    else -1 end,
                                del=case when del=2 or del=5 then del else 1 end
    from contract cg
    left join sp_intro si on cg.ord=si.ord and si.sort1=11001

    update contractlist set del=case when del=2 then del else 1 end

    --6.3更新历史审批实例
    insert into sp_ApprovalInstance(
		            ApprovalRulesId,ApprovalProcessId,gate2, sptype,PrimaryKeyID,BillRight,
		            ApprovalFlowStatus,Approver,BillPattern,CreateTime,UserID,Bounds , SurplusApprover ,  ApprovalType , ApprovalRelation,Gate1)
    select sr.ApprovalRulesID, p.sp , sr.gate2 ,isnull(s.Sptype,-1) as sptype , p.ord , '合同权限' , p.status , p.cateid_sp,0 , getdate(), 63, 1 , p.cateid_sp ,  0 ,  3 ,s.gate1
    from contract p 
    inner join sp s on s.id = p.sp
    inner join sp_ApprovalRules sr on sr.gate2= 11001 and sr.sptype=isnull(s.Sptype,-1)
    where  p.status in (3,4,5) and not exists(select 1 from sp_ApprovalInstance where gate2=11001 and PrimaryKeyID = p.ord)
    --6.4更新历史审批记录关系
    update so set so.InstanceID=st.InstanceID ,so.ApproverName = g.name,so.ApproverDept='',so.ApprovalResult=1, so.IsAutoPass=0,
	    so.ApprovalType = '单审', so.gate3=3 , so.Operator =  g.name, so.CreateTime = so.date1 , so.OperationTime = so.date1 ,
	    so.ApprovalLevel = sp.gate1, so.nextSpID = 0 , so.currNodeApprover = so.cateid,jg=case when so.jg=2 then 0 else so.jg end
    from sp_intro so
    inner join sp_ApprovalInstance st on st.gate2 = 11001 and st.PrimaryKeyID = so.ord
    left join gate g on g.ord= so.cateid
    left join sp on sp.id = so.sp_id
    where so.sort1 = 11001
    --6.5更新新流程审批人员
    update sp set bt=2,intro=replace(intro,' ','') where gate2=11001

    --7.合同del标识更新（老版本del=3是待审批，现在统一改成1）
    update contract set del=1 where del=3
    delete from contract where del=7
    --8.合同del标识更新（老版本del=3是待审批，现在统一改成1）
    update contract set SortType=9 where title='期初应收' and SortType=1
    --增加升级标识
    insert into Erp_Sys_UpdateSign(SignName,SignValue) values('V3202HtUpdateOldData',1)
end

GO

if not exists(select top 1 1 from sortonehy where gate2=63 and tagData='1')
begin
	insert into sortonehy (ord , sort1, gate1, gate2 , del, isstop, tagData)
	values (0, '默认', 40, 63,1,0, '1')
    update sortonehy set ord = id where gate2 = 63 and ord=0
end

GO

if exists(select top 1 1 from kuinlist where isnull(M2_WAID,0)>0 and isnull(FromType,0)=0)
begin 
    update kl set kl.FromType = case when isnull(w.ptype,0)=0 then  54002 else 54005 end 
    from M2_WorkAssigns w
    inner join kuinlist kl on isnull(kl.M2_WAID,0)>0 and isnull(kl.FromType,0)=0 and w.id = kl.M2_WAID
end

GO

IF EXISTS(SELECT TOP 1 1 FROM dbo.paybackInvoice_list WHERE del=1 AND KuoutListId>0 AND ISNULL(KuoutListId1,0)=0)
BEGIN
	UPDATE pl SET pl.KuoutListId1=kl.kuoutlist FROM dbo.paybackInvoice_list pl INNER JOIN dbo.kuoutlist2 kl ON pl.KuoutListId=kl.id
	WHERE pl.del=1
END

GO

if not exists(select 1 from sys_sdk_BillFieldInfo where BillType=62001 and listtype = 0)
begin 
    --同步字段
    select ord,zdy1,zdy2,zdy3,zdy4,zdy5,zdy6 into #tempMainTable from kuout
    exec [MainZdyToBillFieldInfo] 62001,32;
end 
GO
--V3202-预购明细老数据处理
if not exists(select 1 from Erp_Sys_UpdateSign where SignName='V3202YuGouUpdateOldZdyMxData')
begin
	if exists(select id from sys_sdk_BillFieldInfo where BillType=72001 and DBName='InheritId_self_title')
	begin
		update sys_sdk_BillFieldInfo set DBName='InheritId_self_Title' where BillType=72001 and DBName='InheritId_self_title';
	end
	if exists(select id from sys_sdk_BillFieldInfo where BillType=72001 and DBName='InheritId_self_order1')
	begin
		update sys_sdk_BillFieldInfo set DBName='InheritId_self_Order1' where BillType=72001 and DBName='InheritId_self_order1';
	end
	if exists(select id from sys_sdk_BillFieldInfo where BillType=72001 and DBName='InheritId_self_type1')
	begin
		update sys_sdk_BillFieldInfo set DBName='InheritId_self_Type1' where BillType=72001 and DBName='InheritId_self_type1';
	end
	if exists(select id from sys_sdk_BillFieldInfo where BillType=72001 and DBName='InheritId_self_unitall')
	begin
		update sys_sdk_BillFieldInfo set DBName='InheritId_self_Unit' where BillType=72001 and DBName='InheritId_self_unitall';
	end
	if exists(select id from sys_sdk_BillFieldInfo where BillType=72001 and DBName='InheritId_self_num1')
	begin
		update sys_sdk_BillFieldInfo set DBName='InheritId_self_Num1' where BillType=72001 and DBName='InheritId_self_num1';
	end
	if exists(select id from sys_sdk_BillFieldInfo where BillType=72001 and DBName='InheritId_self_price1')
	begin
		update sys_sdk_BillFieldInfo set DBName='InheritId_self_Price1' where BillType=72001 and DBName='InheritId_self_price1';
	end
	if exists(select id from sys_sdk_BillFieldInfo where BillType=72001 and DBName='InheritId_self_money1')
	begin
		update sys_sdk_BillFieldInfo set DBName='InheritId_self_Money1' where BillType=72001 and DBName='InheritId_self_money1';
	end
	if exists(select id from sys_sdk_BillFieldInfo where BillType=72001 and DBName='InheritId_self_date2')
	begin
		update sys_sdk_BillFieldInfo set DBName='InheritId_self_Date2' where BillType=72001 and DBName='InheritId_self_date2';
	end
	if exists(select id from sys_sdk_BillFieldInfo where BillType=72001 and DBName='InheritId_self_intro')
	begin
		update sys_sdk_BillFieldInfo set DBName='InheritId_self_Intro1' where BillType=72001 and DBName='InheritId_self_intro';
	end
	if not exists(select id from sys_sdk_BillFieldInfo where BillType=72001 and DBName='InheritId_self_Cgperson')
	begin
		INSERT INTO [dbo].[sys_sdk_BillFieldInfo]([ModuleType],[BillType],[ListType],[InheritId],[Title],[DBName],[UiType],[DbType],[Unit],[Remark],[ShowIndex],[Colspan],[Rowspan],[Display],[IsUsed],[SourceTag] ,[cansearch],[candc],[candr],[mustfillin],[cantj])
		values(0,72001,1,0,'采购人员','InheritId_self_Cgperson',0,5,'','',9,-1,-1,-1,1,'',0,0,1,0,0)
	end
	if not exists(select id from sys_sdk_BillFieldInfo where BillType=72001 and DBName='InheritId_self_Sort1')
	begin
		INSERT INTO [dbo].[sys_sdk_BillFieldInfo]([ModuleType],[BillType],[ListType],[InheritId],[Title],[DBName],[UiType],[DbType],[Unit],[Remark],[ShowIndex],[Colspan],[Rowspan],[Display],[IsUsed],[SourceTag] ,[cansearch],[candc],[candr],[mustfillin],[cantj])
		values(0,72001,1,0,'产品分类','InheritId_self_Sort1',0,5,'','',4,-1,-1,-1,1,'',0,0,1,0,0)
	end
	--end.增加升级标识
	insert into Erp_Sys_UpdateSign(SignName,SignValue) values('V3202YuGouUpdateOldZdyMxData',1)
end
GO
if not exists(select 1 from setopen where sort1=1201) insert into setopen (intro,sort1) values (2,1201)
GO
if not exists(select 1 from Erp_Sys_UpdateSign where SignName='V3202OldZdy1-6UpdateNewZdyData')
begin
	--报价主单自定义升级
	update sys_sdk_BillFieldInfo set DBName ='newmain_'+ cast(id as varchar(20))  where billtype = 13001 and ListType=0 and (DBName like 'Netext%' or DBName like 'zdy%')
	--入库主单自定义升级
	update sys_sdk_BillFieldInfo set DBName ='newmain_'+ cast(id as varchar(20))  where billtype = 61001 and ListType=0 and (DBName like 'Netext%' or DBName like 'zdy%')
	--发货主单自定义升级
    update sys_sdk_BillFieldInfo set DBName ='newmain_'+ cast(id as varchar(20))  where billtype = 68001 and ListType=0 and (DBName like 'Netext%' or DBName like 'zdy%')
	--预购主单自定义升级
    update sys_sdk_BillFieldInfo set DBName ='newmain_'+ cast(id as varchar(20))  where billtype = 72001 and ListType=0 and (DBName like 'Netext%' or DBName like 'zdy%')
	--采购主单自定义升级
    update sys_sdk_BillFieldInfo set DBName ='newmain_'+ cast(id as varchar(20))  where billtype = 73001 and ListType=0 and (DBName like 'Netext%' or DBName like 'zdy%')
	--合同主单自定义升级
    update sys_sdk_BillFieldInfo set DBName ='newmain_'+ cast(id as varchar(20))  where billtype = 11001 and ListType=0 and (DBName like 'Netext%' or DBName like 'zdy%')
	--出库主单自定义升级
	update sys_sdk_BillFieldInfo set DBName ='newmain_'+ cast(id as varchar(20))  where billtype = 62001 and ListType=0 and (DBName like 'Netext%' or DBName like 'zdy%')
	--end.增加升级标识
	insert into Erp_Sys_UpdateSign(SignName,SignValue) values('V3202OldZdy1-6UpdateNewZdyData',1)
end

GO

if exists(select 1 from setjm3 where ord = 88 having count(1)>1)
begin 
	delete from setjm3 where ord = 88 and id not in (
		select min(id) from setjm3 where ord = 88
	)
end

GO
		
-------------------------Begin修复全月平均对冲数据 入库日期与出库日期不符数据-------------------------
--先修复kuinlist明细数据
UPDATE e SET e.date5=DATEadd(mi,-1,f.date5),e.date3=DATEadd(mi,-1,f.date5),e.date7=DATEadd(mi,-1,f.date5)
FROM kuoutlist2 a INNER JOIN ku b ON a.ku=b.id AND a.kuinlist=0
INNER JOIN kuhclist c ON b.id=c.kuid
INNER JOIN kuinlist d ON c.kuinlist=d.id
INNER JOIN kuin e ON d.kuin=e.ord
INNER JOIN kuout f ON a.kuout=f.ord
WHERE e.date5>f.date5 

--再修复ku数据
UPDATE b SET b.daterk=DATEadd(mi,-1,f.date5)
FROM kuoutlist2 a INNER JOIN ku b ON a.ku=b.id AND a.kuinlist=0
INNER JOIN kuhclist c ON b.id=c.kuid
INNER JOIN kuinlist d ON c.kuinlist=d.id
INNER JOIN kuin e ON d.kuin=e.ord
INNER JOIN kuout f ON a.kuout=f.ord
WHERE e.date5>f.date5 

--再修复kuin数据
UPDATE d SET d.[dateadd]=DATEadd(mi,-1,f.date5),d.date7=DATEadd(mi,-1,f.date5)
FROM kuoutlist2 a INNER JOIN ku b ON a.ku=b.id AND a.kuinlist=0
INNER JOIN kuhclist c ON b.id=c.kuid
INNER JOIN kuinlist d ON c.kuinlist=d.id
INNER JOIN kuin e ON d.kuin=e.ord
INNER JOIN kuout f ON a.kuout=f.ord
WHERE e.date5>f.date5 
-------------------------End修复全月平均对冲数据 入库日期与出库日期不符数据-------------------------

GO

update product set TaxPreferenceType =1 where isnull(TaxPreference,0)=0 and isnull(TaxPreferenceType,0)=0
GO

--V3202-凭证对接升级-整单委外出入库类型老数据处理
IF NOT EXISTS(SELECT 1 FROM Erp_Sys_UpdateSign WHERE SignName='V3202VoucherUpdateForZZWWType' )
BEGIN
--整单委外成品入库、整单委外成品报废入库
UPDATE  cl
SET     cl.clstype = ( CASE cl.clstype WHEN 11005 THEN 11023 WHEN 11011 THEN 11024 END )
FROM    dbo.collocation cl
        INNER JOIN dbo.kuin k ON cl.erpOrd = k.ord
WHERE   clstype IN ( 11005, 11011 )
        AND k.sort1 IN ( 5, 14 )
        AND EXISTS ( SELECT TOP 1 1
                     FROM   M2_QualityTestings mqt
                     WHERE  mqt.ID = k.fromid AND ISNULL(mqt.poType, 0) = 1 );
                            
--整单委外退料入库、整单委外废料入库                            
UPDATE  cl
SET     cl.clstype = ( CASE cl.clstype WHEN 11003 THEN 11021 WHEN 11013 THEN 11022 END )
FROM    dbo.collocation cl
        INNER JOIN dbo.kuin k ON cl.erpOrd = k.ord
WHERE   clstype IN ( 11003, 11013 )
        AND k.sort1 IN ( 3, 16 )
        AND EXISTS ( SELECT TOP 1 1
                     FROM   dbo.M2_MaterialRegisterLists b
                            LEFT JOIN dbo.M2_MaterialOrderLists c ON b.MOLID = c.ID
                     WHERE  k.fromid = b.MRID AND ISNULL(c.poType, 0) = 3 );
                     
--整单委外补料出库、整单委外领料出库                     
UPDATE  cl
SET     cl.clstype = ( CASE cl.clstype WHEN 12003 THEN 12011 WHEN 12010 THEN 12012 END )
FROM    dbo.collocation cl
        INNER JOIN dbo.kuout k ON cl.erpOrd = k.ord
WHERE   clstype IN ( 12003, 12010 )
        AND k.sort1 IN ( 3, 12 )
        AND EXISTS ( SELECT TOP 1 1
                     FROM   kuoutlist2 kl
                            INNER JOIN dbo.M2_MaterialOrderLists mol ON kl.M2_OrderID = mol.ID
                     WHERE  kl.kuout = k.ord AND ISNULL(mol.poType, 0) = 3 );
                     

INSERT INTO Erp_Sys_UpdateSign(SignName,SignValue,SignTime) VALUES('V3202VoucherUpdateForZZWWType',1,GETDATE())                     
END
GO

--V3204-凭证对接升级-整单委半成品入库类型老数据处理
IF NOT EXISTS(SELECT 1 FROM Erp_Sys_UpdateSign WHERE SignName='V3204VoucherUpdateForZZWWType' )
BEGIN
--整单委外半成品入库、整单委外半成品报废入库
UPDATE  cl
SET     cl.clstype = ( CASE cl.clstype WHEN 11012 THEN 11026 WHEN 11014 THEN 11027 END )
FROM    dbo.collocation cl
        INNER JOIN dbo.kuin k ON cl.erpOrd = k.ord
WHERE   clstype IN ( 11012, 11014 )
        AND k.sort1 IN ( 13, 15 )
        AND EXISTS ( SELECT TOP 1 1
                     FROM   kuinlist kl
                     WHERE  kl.kuin = k.ord AND ISNULL(kl.M2_OutListId, 0) >0 );
INSERT INTO Erp_Sys_UpdateSign(SignName,SignValue,SignTime) VALUES('V3204VoucherUpdateForZZWWType',1,GETDATE())                     
END
GO

--V3204-处理项目老版本打印客户信息相关字段
IF NOT EXISTS(SELECT 1 FROM Erp_Sys_UpdateSign WHERE SignName='V3204UpdateChanceTemp' )
BEGIN
	update contract_out set A1=replace(replace(
		replace(
				replace(
					replace(
						replace(
							replace(
								REPLACE(cast(A1 as nvarchar(max)),'zbintel_company','zbintel_cmtel_company'),'zbintel_code','zbintel_cmtel_code'
							) ,'zbintel_person','zbintel_cmtel_person'
						),'zbintel_address','zbintel_cmtel_address'
					),'zbintel_kphone','zbintel_cmtel_kphone'
				),'zbintel_phone','zbintel_cmtel_kphone'
		),'zbintel_email','zbintel_cmtel_zip'
),'zbintel_zip','zbintel_cmtel_kemail')
where sort=9and del=1
INSERT INTO Erp_Sys_UpdateSign(SignName,SignValue,SignTime) VALUES('V3204UpdateChanceTemp',1,GETDATE())              
END
GO

--V3204处理收款开票计划设置中，当选择合同对账生成收款计划时对应的默认对账方式
IF NOT EXISTS ( SELECT * FROM    dbo.setopen WHERE sort1 = 6606 )
BEGIN
    DECLARE @businessCheckType INT;
    SELECT  @businessCheckType = CAST(SUBSTRING(tvalue, 1, 1) AS INT) FROM dbo.home_usConfig WHERE name = 'BusinessCheckFromType';
    IF ( @businessCheckType IS NULL )
    BEGIN
        SET @businessCheckType = 1;
    END;
    INSERT  INTO dbo.setopen ( intro, sort1 ) VALUES ( @businessCheckType, 6606 );
END;
GO

--处理付款审批流程遗留老数据
IF EXISTS ( SELECT TOP 1 1
            FROM    dbo.sp_ApprovalInstance a
                    LEFT JOIN dbo.PaybackInvoiceSure pis ON a.PrimaryKeyID = pis.ID
            WHERE   gate2 = 43012
                    AND a.del = 1
                    AND ISNULL(pis.Del, 2) = 2 )
    BEGIN
        DELETE a
        FROM    dbo.sp_ApprovalInstance a
                LEFT JOIN dbo.PaybackInvoiceSure pis ON a.PrimaryKeyID = pis.ID
        WHERE   gate2 = 43012
                AND a.del = 1
                AND ISNULL(pis.Del, 2) = 2;
    END;
GO

--处理开票审批流程遗留老数据
IF EXISTS ( SELECT TOP 1 1
            FROM    dbo.sp_ApprovalInstance a
                    LEFT JOIN dbo.PayOutSure pos ON a.PrimaryKeyID = pos.ID
            WHERE   gate2 = 44011
                    AND a.del = 1
                    AND ISNULL(pos.Del, 2) = 2 )
    BEGIN
        DELETE  a
        FROM    dbo.sp_ApprovalInstance a
                LEFT JOIN dbo.PayOutSure pos ON a.PrimaryKeyID = pos.ID
        WHERE   gate2 = 44011
                AND a.del = 1
                AND ISNULL(pos.Del, 2) = 2;
    END
GO
--处理实际收款审批流程遗留老数据
 IF EXISTS ( SELECT TOP 1 1
        FROM    dbo.sp_ApprovalInstance a
                LEFT JOIN dbo.PayoutInvoiceSure pis ON a.PrimaryKeyID = pis.ID
        WHERE   gate2 = 44012
                AND a.del = 1
                AND ISNULL(pis.Del, 2) = 2 )
 BEGIN
    DELETE  a
    FROM    dbo.sp_ApprovalInstance a
            LEFT JOIN dbo.PayoutInvoiceSure pis ON a.PrimaryKeyID = pis.ID
    WHERE   gate2 = 44012
            AND a.del = 1
            AND ISNULL(pis.Del, 2) = 2;
 END
GO
--V3204-处理项目老版本打印客户信息相关字段
IF NOT EXISTS(SELECT 1 FROM Erp_Sys_UpdateSign WHERE SignName='AddCodeTypeFieldsKuoutList' )
BEGIN
	IF  not exists(select 1 from C2_CodeTypes where title='出库明细自定义' AND fromSys =2)
	BEGIN
		INSERT INTO C2_CodeTypes(title,gate1,fromSys,entype,addcate,addtime,del,isAuto,stop,billType,color,bgcolor,	Picsize,errhandle) SELECT '出库明细自定义',2,2,0,63,GETDATE(),1,1,0,62001,'#000000','#ffffff',300,3
	END

	INSERT INTO C2_CodeTypeFields(cTypeId,uName,uType,gate1,fieldName,oldName) 
	SELECT id,'流水号',0,0,'id','流水号' FROM C2_CodeTypes  WHERE title ='出库明细自定义' AND fromSys =2
	UNION ALL SELECT id,'产品名称',0,10,'title','产品名称' FROM C2_CodeTypes  WHERE title ='出库明细自定义' AND fromSys =2
	UNION ALL SELECT id,'产品编号',0,20,'order1','产品编号' FROM C2_CodeTypes  WHERE title ='出库明细自定义' AND fromSys =2
	UNION ALL SELECT id,'产品型号',0,30,'type1','产品型号' FROM C2_CodeTypes  WHERE title ='出库明细自定义' AND fromSys =2
	UNION ALL SELECT id,'单位',0,40,'unit','单位' FROM C2_CodeTypes  WHERE title ='出库明细自定义' AND fromSys =2
	UNION ALL SELECT id,'数量',5,50,'num1','数量' FROM C2_CodeTypes  WHERE title ='出库明细自定义' AND fromSys =2
	UNION ALL SELECT id,'单位属性',0,60,'commUnitAttr','单位属性' FROM C2_CodeTypes  WHERE title ='出库明细自定义' AND fromSys =2
	UNION ALL SELECT id,'单价',5,70,'price2','单价' FROM C2_CodeTypes  WHERE title ='出库明细自定义' AND fromSys =2
	UNION ALL SELECT id,'总价',5,80,'money2','总价' FROM C2_CodeTypes  WHERE title ='出库明细自定义' AND fromSys =2
	UNION ALL SELECT id,'批号',0,90,'ph','批号' FROM C2_CodeTypes  WHERE title ='出库明细自定义' AND fromSys =2
	UNION ALL SELECT id,'序列号',0,100,'xlh','序列号' FROM C2_CodeTypes  WHERE title ='出库明细自定义' AND fromSys =2
	UNION ALL SELECT id,'生产日期',7,110,'datesc','生产日期' FROM C2_CodeTypes  WHERE title ='出库明细自定义' AND fromSys =2
	UNION ALL SELECT id,'有效日期',7,120,'dateyx','有效日期' FROM C2_CodeTypes  WHERE title ='出库明细自定义' AND fromSys =2
	UNION ALL SELECT id,'仓库',0,130,'ku','仓库' FROM C2_CodeTypes  WHERE title ='出库明细自定义' AND fromSys =2
	UNION ALL SELECT id,'包装',0,140,'bz','包装' FROM C2_CodeTypes  WHERE title ='出库明细自定义' AND fromSys =2
	UNION ALL SELECT id,'备注',0,150,'intro','备注' FROM C2_CodeTypes  WHERE title ='出库明细自定义' AND fromSys =2
INSERT INTO Erp_Sys_UpdateSign(SignName,SignValue,SignTime) VALUES('AddCodeTypeFieldsKuoutList',1,GETDATE())              
END
GO

--收票字段自定义老数据升级        
if not exists(select 1 from sys_sdk_BillFieldInfo where BillType=41002 and ListType=0)
begin
    exec [MainZdyToBillFieldInfo] 41002,81;

    INSERT INTO sys_sdk_BillFieldValue(BillType,BillListType,BillId,ListID,FieldId,Value , InheritId)
    SELECT 41002,0,cv.OrderID,0,bfi.Id,cv.FValue, bfi.id
    FROM sys_sdk_BillFieldInfo bfi
    inner join ERP_CustomFields cf on cf.TName=81 AND Replace(bfi.DBName,'Netext','')=cf.ID
    inner join erp_customValues cv on cv.FieldsID=cf.ID
    WHERE BFI.BILLTYPE=41002 AND bfi.DBName LIKE '%Netext%'

    update sys_sdk_BillFieldInfo set dbname='newmain_'+cast(id as varchar(20)) where billtype=41002 and listtype=0
end
GO
--开票字段自定义老数据升级
if not exists(select 1 from Erp_Sys_UpdateSign where SignName='V3205PaybackInvoiceOldZdyUpdate' )
begin
	update sys_sdk_BillFieldInfo set BillType=-43005 where BillType=43005 and ListType=0

    exec [MainZdyToBillFieldInfo] 43005,96;

    INSERT INTO sys_sdk_BillFieldValue(BillType,BillListType,BillId,ListID,FieldId,Value,InheritId)
    SELECT 43005,0,cv.OrderID,0,bfi.Id,cv.FValue, bfi.id
    FROM sys_sdk_BillFieldInfo bfi
    inner join ERP_CustomFields cf on cf.TName=96 AND Replace(bfi.DBName,'Netext','')=cf.ID
    inner join erp_customValues cv on cv.FieldsID=cf.ID
    WHERE BFI.BILLTYPE=43005 AND bfi.DBName LIKE '%Netext%'

    update sys_sdk_BillFieldInfo set dbname='newmain_'+cast(id as varchar(20)) where billtype=43005 and listtype=0

	update sys_sdk_BillFieldInfo set BillType=43005 where BillType=-43005 and ListType=0

	insert into Erp_Sys_UpdateSign(SignName,SignValue) values('V3205PaybackInvoiceOldZdyUpdate',1)
end
GO
--处理老版本生产订单/老版生产订单转预购fromtype都是等于4的问题
if not exists(select 1 from Erp_Sys_UpdateSign where SignName='V3205YuGouUpdateFromType' )
begin
	update caigou_yg set fromtype=11 where fromtype=4 and isnull(M2_OrderID,0)>0 and isnull(MOrderID,0)=0;
	insert into Erp_Sys_UpdateSign(SignName,SignValue) values('V3205YuGouUpdateFromType',1)
end

GO

--账间转账汇率历史数据处理
IF NOT EXISTS(SELECT 1 FROM dbo.home_usConfig WHERE name='BankMove_HL')
BEGIN
   UPDATE dbo.bankmove SET hl=1 WHERE ISNULL(hl,0)=0
   insert into dbo.home_usConfig(name,nvalue,uid)values('BankMove_HL',1,0)
END
GO
--更新产品采购明细表我的导航地址为.NET版本地址
IF NOT EXISTS(SELECT 1 FROM dbo.home_usConfig WHERE name='3205UPdateProductPurchaseUrl')
BEGIN
   update wddh set url='SYSN/view/sales/product/productPurchase.ashx?sort=0' where url like '%SYSA/tongji/productPurchase.asp%';
   update Home_mainlink_config set url='sys:../../SYSN/view/sales/product/productPurchase.ashx?sort=0' where url like '%SYSA/tongji/productPurchase.asp%'
   insert into dbo.home_usConfig(name,nvalue,uid)values('3205UPdateProductPurchaseUrl',1,0)
END

GO

--生产领料合并明细策略控制-合并相同明细默认勾选
IF NOT EXISTS(SELECT TOP 1 1 FROM dbo.home_usConfig WHERE name = 'MergeMX55001')
BEGIN
	INSERT INTO dbo.home_usConfig(name,nvalue,[uid])
	VALUES  ('MergeMX55001',1,0)
END
GO
--处理收票明细自定义继承来源单据明细自定义老数据
if not exists(select 1 from Erp_Sys_UpdateSign where SignName='V3205PayoutInvoiceInheritZdymx' )
begin
	insert into sys_sdk_BillFieldValue(BillType,BillListType,BillId,ListID,FieldId,InheritId,Value,BigValue)
	select t.BillType,t.BillListType,t.BillId,t.ListID,t.FieldId,t.InheritId,t.Value,t.BigValue
	from (
	--1.补充采购明细自定义数据到收票计划明细自定义
	select 41002 as BillType,2 as BillListType,pi.id as BillId,pil.id as ListID,bfv.FieldId,bfv.InheritId,bfv.Value,null as BigValue
	from payoutInvoice_list pil
	inner join payoutInvoice pi on pil.payoutInvoice=pi.id
	inner join sys_sdk_BillFieldValue bfv on bfv.BillType=73001 and bfv.BillListType=1 and bfv.BillId=pi.fromId and bfv.ListID=pil.caigoulist
	where pi.fromType='CAIGOU' and isnull(pi.KuinId,0)=0
	union
	--2.补充入库明细自定义数据到收票计划明细自定义
	select 41002 as BillType,2 as BillListType,pi.id as BillId,pil.id as ListID,bfv.FieldId,bfv.InheritId,bfv.Value,null as BigValue
	from payoutInvoice_list pil
	inner join payoutInvoice pi on pil.payoutInvoice=pi.id
	inner join sys_sdk_BillFieldValue bfv on bfv.BillType=61001 and bfv.BillListType=1 and bfv.BillId=pi.KuinId and bfv.ListID=pil.kuinlistid
	where isnull(pi.KuinId,0)>0
	union
	--3.补充整单委外明细自定义数据到收票计划明细自定义
	select 41002 as BillType,2 as BillListType,pi.id as BillId,pil.id as ListID,bfv.FieldId,bfv.InheritId,bfv.Value,null as BigValue
	from payoutInvoice_list pil
	inner join payoutInvoice pi on pil.payoutInvoice=pi.id
	inner join sys_sdk_BillFieldValue bfv on bfv.BillType=54003 and bfv.BillListType=1 and bfv.BillId=pi.fromId and bfv.ListID=pil.M2_OutOrderlists
	where pi.fromType='ZDWW' and isnull(pi.KuinId,0)=0
	union
	--4.补充生产工序委外单明细自定义数据到收票计划明细自定义
	select 41002 as BillType,2 as BillListType,pi.id as BillId,pil.id as ListID,bfv.FieldId,bfv.InheritId,bfv.Value,null as BigValue
	from payoutInvoice_list pil
	inner join payoutInvoice pi on pil.payoutInvoice=pi.id
	inner join sys_sdk_BillFieldValue bfv on bfv.BillType=54006 and bfv.BillListType=1 and bfv.BillId=pi.fromId and bfv.ListID=pil.M2_OutOrderlists
	where pi.fromType='GXWW' and isnull(pi.KuinId,0)=0 and isnull(pil.QCListId,0)=0
	union
	--5.补充生产委外质检单明细自定义数据到收票计划明细自定义
	select 41002 as BillType,2 as BillListType,pi.id as BillId,pil.id as ListID,bfv.FieldId,bfv.InheritId,bfv.Value,null as BigValue
	from payoutInvoice_list pil
	inner join payoutInvoice pi on pil.payoutInvoice=pi.id
	inner join sys_sdk_BillFieldValue bfv on bfv.BillType=54009 and bfv.BillListType=1 and bfv.BillId=pi.fromId and bfv.ListID=pil.QCListId
	where pi.fromType='GXWW' and isnull(pi.KuinId,0)=0 and isnull(pil.QCListId,0)>0
	) t
	where not exists (select 1 from sys_sdk_BillFieldValue where BillType=t.BillType and BillListType=t.BillListType and BillId=t.BillId and ListID=t.ListID and InheritId=t.InheritId);
	insert into Erp_Sys_UpdateSign(SignName,SignValue) values('V3205PayoutInvoiceInheritZdymx',1)
end
GO
--处理开票明细自定义继承来源单据明细自定义老数据
if not exists(select 1 from Erp_Sys_UpdateSign where SignName='V3205PaybackInvoiceInheritZdymx' )
begin
	insert into sys_sdk_BillFieldValue(BillType,BillListType,BillId,ListID,FieldId,InheritId,Value,BigValue)
	select t.BillType,t.BillListType,t.BillId,t.ListID,t.FieldId,t.InheritId,t.Value,t.BigValue
	from (
	--1.补充合同明细自定义数据到开票计划明细自定义
	select 43005 as BillType,2 as BillListType,pi.id as BillId,pil.id as ListID,bfv.FieldId,bfv.InheritId,bfv.Value,null as BigValue
	from paybackInvoice_list pil
	inner join paybackInvoice pi on pil.paybackInvoice=pi.id
	inner join sys_sdk_BillFieldValue bfv on bfv.BillType=11001 and bfv.BillListType=1 and bfv.BillId=pi.fromId and bfv.ListID=pil.contractlist
	where pi.fromType='CONTRACT' and isnull(pi.FromChildType,0)=0
	union
	--2.补充出库明细自定义数据到开票计划明细自定义
	select 43005 as BillType,2 as BillListType,pi.id as BillId,pil.id as ListID,bfv.FieldId,bfv.InheritId,bfv.Value,null as BigValue
	from paybackInvoice_list pil
	inner join paybackInvoice pi on pil.paybackInvoice=pi.id
	inner join sys_sdk_BillFieldValue bfv on bfv.BillType=62001 and bfv.BillListType=1 and bfv.BillId=pi.fromId and bfv.ListID=pil.KuoutListId1
	where pi.FromChildType=1
	union
	--3.补充发货明细自定义数据到开票计划明细自定义
	select 43005 as BillType,2 as BillListType,pi.id as BillId,pil.id as ListID,bfv.FieldId,bfv.InheritId,bfv.Value,null as BigValue
	from paybackInvoice_list pil
	inner join paybackInvoice pi on pil.paybackInvoice=pi.id
	inner join sys_sdk_BillFieldValue bfv on bfv.BillType=68001 and bfv.BillListType=1 and bfv.BillId=pi.fromId and bfv.ListID=pil.SendListId
	where pi.FromChildType=2
	) t
	where not exists (select 1 from sys_sdk_BillFieldValue where BillType=t.BillType and BillListType=t.BillListType and BillId=t.BillId and ListID=t.ListID and InheritId=t.InheritId);
	insert into Erp_Sys_UpdateSign(SignName,SignValue) values('V3205PaybackInvoiceInheritZdymx',1)
end
GO
--处理对账单明细自定义继承来源单据明细自定义老数据
if not exists(select 1 from Erp_Sys_UpdateSign where SignName='V3205BusinessCheckInheritZdymx' )
begin
	insert into sys_sdk_BillFieldValue(BillType,BillListType,BillId,ListID,FieldId,InheritId,Value,BigValue)
	select t.BillType,t.BillListType,t.BillId,t.ListID,t.FieldId,t.InheritId,t.Value,t.BigValue
	from (
	--1.补充合同明细自定义数据到对账单明细自定义
	select 47001 as BillType,1 as BillListType,bc.ID as BillId,bcl.ID as ListID,bfv.FieldId,bfv.InheritId,bfv.Value,null as BigValue
	from BusinessCheckLists bcl
	inner join BusinessCheck bc on bcl.CheckId=bc.ID
	inner join sys_sdk_BillFieldValue bfv on bfv.BillType=11001 and bfv.BillListType=1 and bfv.BillId=bcl.FromId and bfv.ListID=bcl.FromListId
	where bc.FromType=1
	union
	--2.补充出库明细自定义数据到对账单明细自定义
	select 47001 as BillType,1 as BillListType,bc.ID as BillId,bcl.ID as ListID,bfv.FieldId,bfv.InheritId,bfv.Value,null as BigValue
	from BusinessCheckLists bcl
	inner join BusinessCheck bc on bcl.CheckId=bc.ID
	inner join sys_sdk_BillFieldValue bfv on bfv.BillType=62001 and bfv.BillListType=1 and bfv.BillId=bcl.FromId and bfv.ListID=bcl.FromListId
	where bc.FromType=2
	union
	--3.补充发货明细自定义数据到对账单明细自定义
	select 47001 as BillType,1 as BillListType,bc.ID as BillId,bcl.ID as ListID,bfv.FieldId,bfv.InheritId,bfv.Value,null as BigValue
	from BusinessCheckLists bcl
	inner join BusinessCheck bc on bcl.CheckId=bc.ID
	inner join sys_sdk_BillFieldValue bfv on bfv.BillType=68001 and bfv.BillListType=1 and bfv.BillId=bcl.FromId and bfv.ListID=bcl.FromListId
	where bc.FromType=3
	union
	--4.补充开票明细自定义数据到对账单明细自定义
	select 47001 as BillType,1 as BillListType,bc.ID as BillId,bcl.ID as ListID,bfv.FieldId,bfv.InheritId,bfv.Value,null as BigValue
	from BusinessCheckLists bcl
	inner join BusinessCheck bc on bcl.CheckId=bc.ID
	inner join sys_sdk_BillFieldValue bfv on bfv.BillType=43005 and bfv.BillListType=2 and bfv.BillId=bcl.FromId and bfv.ListID=bcl.FromListId
	where bc.FromType=4
	) t
	where not exists (select 1 from sys_sdk_BillFieldValue where BillType=t.BillType and BillListType=t.BillListType and BillId=t.BillId and ListID=t.ListID and InheritId=t.InheritId);
	insert into Erp_Sys_UpdateSign(SignName,SignValue) values('V3205BusinessCheckInheritZdymx',1)
end
GO
--处理发货明细自定义继承来源单据明细自定义老数据
if not exists(select 1 from Erp_Sys_UpdateSign where SignName='V3205SendInheritZdymx' )
begin
	insert into sys_sdk_BillFieldValue(BillType,BillListType,BillId,ListID,FieldId,InheritId,Value,BigValue)
	select t.BillType,t.BillListType,t.BillId,t.ListID,t.FieldId,t.InheritId,t.Value,t.BigValue
	from (
	--1.补充出库明细自定义数据到发货明细自定义
	select 68001 as BillType,1 as BillListType,sl.Send as BillId,sl.id as ListID,bfv.FieldId,bfv.InheritId,bfv.Value,null as BigValue
	from sendlist sl
	inner join kuoutlist2 kol2 on sl.kuoutlist=kol2.id
	inner join sys_sdk_BillFieldValue bfv on bfv.BillType=62001 and bfv.BillListType=1 and bfv.BillId=kol2.kuout and bfv.ListID=kol2.kuoutlist
	) t
	where not exists (select 1 from sys_sdk_BillFieldValue where BillType=t.BillType and BillListType=t.BillListType and BillId=t.BillId and ListID=t.ListID and InheritId=t.InheritId);
	insert into Erp_Sys_UpdateSign(SignName,SignValue) values('V3205SendInheritZdymx',1)
end
GO

--格式化资产购价、资产已提金额、资产净残值，每期折旧金额字段
IF NOT EXISTS ( SELECT 1 FROM erp_sys_updatesign WHERE SignName = 'V3205AssetMoneyFormatUpdate' )
BEGIN
    DECLARE @assetmoneybit INT;
    SELECT @assetmoneybit = num1 FROM dbo.setjm3 WHERE ord = 1

    UPDATE  dbo.O_asset
    SET     ass_jcz = ROUND(ass_jcz, @assetmoneybit) ,
            ass_money = ROUND(ass_money, @assetmoneybit) ,
            ass_money2 = ROUND(ass_money2, @assetmoneybit);
    UPDATE  dbo.O_assDeprect
    SET     D_money = ROUND(D_money, @assetmoneybit) ,
            D_ymoney = ROUND(D_ymoney, @assetmoneybit)        
        
	update b set b.d_del=3 from dbo.O_asset a inner join O_assDeprect  b on a.ass_id=b.D_assID 
	where  b.d_del=1 and ass_cycle=ass_ycycle

	update b set b.D_money=round(a.ass_money,@assetmoneybit)-round(a.ass_money2,@assetmoneybit)-round(a.ass_jcz,@assetmoneybit),
	b.D_ymoney=round(a.ass_money,@assetmoneybit)-round(a.ass_money2,@assetmoneybit)-round(a.ass_jcz,@assetmoneybit)
	from dbo.O_asset a inner join O_assDeprect  b on a.ass_id=b.D_assID 
	where  b.d_del=1 and round(a.ass_money,@assetmoneybit)-round(a.ass_money2,@assetmoneybit)-round(a.ass_jcz,@assetmoneybit) < round(b.D_money,@assetmoneybit)   
                
    INSERT  INTO erp_sys_updatesign ( SignName, SignValue ) VALUES  ( 'V3205AssetMoneyFormatUpdate', 1 )
         
END
GO
--修复采购明细添加日期和添加人错误数据
if not exists(select 1 from Erp_Sys_UpdateSign where SignName='UpdateCaiGoulistDateadd_AddcateError' )
begin
	update caigoulist set dateadd=CONVERT(varchar(11),date7,120) where dateadd is null or dateadd=date7

	update caigoulist set addcate=cateid where addcate is null or addcate=0

	insert into Erp_Sys_UpdateSign(SignName,SignValue) values('UpdateCaiGoulistDateadd_AddcateError',1)
end
GO
--修复采购分期付款计划和付款计划关联不对的老数据
if not exists(select 1 from Erp_Sys_UpdateSign where SignName='UpdateCaiGouPlanFKError' )
begin
	update po set planfkid=fk.ord
	from payout po
	inner join plan_fk fk on po.contract=fk.caigou and fk.money1=po.money1 and po.cls=0 and fk.del=1 and po.del=1
	inner join caigou cg on po.contract=cg.ord and cg.fyhk=5
	where po.planfkid=11

	insert into Erp_Sys_UpdateSign(SignName,SignValue) values('UpdateCaiGouPlanFKError',1)
end
GO
--修复因出库回收站批量清空导致的遗漏kuoutlist2表DEL=2的没有清除的问题
if exists(select top 1 1 from kuoutlist2 with(nolock) where del=2 and kuout not in (select ord from kuout with(nolock)))
begin
	delete from kuoutlist2 where del=2 and kuout not in (select ord from kuout with(nolock))
end
GO
--修复生产派工和领料明细的工序异常数据
if not exists(select 1 from Erp_Sys_UpdateSign where SignName='UpdateWFPAIDErrorV3205' )
begin
	update M2_WorkAssignLists SET WFPAID=0 WHERE WFPAID=-1
	update M2_MaterialOrderlists SET WFPAID=0 WHERE WFPAID=-1
	insert into Erp_Sys_UpdateSign(SignName,SignValue) values('UpdateWFPAIDErrorV3205',1)
end
GO

if not exists(select 1 from home_usConfig where name = 'KUOUTLIST2_FIELDS_Price2')
begin 
    --修复历史出库明细没有销售价格的数据
    update a set a.price2 = b.PriceAfterTax, a.money2 = round(b.money1 * a.num1 / b.num1,d.num1)
    from kuoutlist2 a
    inner join contractlist b with(nolock) on a.contractlist = b.id and a.contract = b.contract
    inner join kuout c with(nolock) on c.ord = a.kuout and c.sort1 in (1,4)
    inner join setjm3 d with(nolock) on d.ord = 1
    where b.money1>0 and a.price2 = 0

    --修复出库销售总价远远大于单价*数量的数据
    update a set a.money2 = round(b.money1 * a.num1 / b.num1,d.num1)
    from kuoutlist2 a
    inner join contractlist b with(nolock) on a.contractlist = b.id and a.contract = b.contract
    inner join kuout c with(nolock) on c.ord = a.kuout and c.sort1 in (1,4)
    inner join setjm3 d with(nolock) on d.ord = 1
    where a.money2>0 and abs(a.money2-round(b.money1 * a.num1 / b.num1,d.num1))>1

	insert into home_usConfig(name,nvalue,tvalue,uid) values('KUOUTLIST2_FIELDS_Price2',null,1,0)
end
GO
--删除派工单产品自定义无效数据
if not exists(select 1 from home_usConfig where name = 'DeleteBillFieldInfoForBUG68518')
begin
	if not exists(select 1 from sys_sdk_BillFieldValue where BillType=54002 and BillListType=1)
	begin
		delete from dbo.sys_sdk_BillFieldInfo where BillType=54002 and ListType=1
	end
	insert into home_usConfig(name,nvalue,tvalue,uid) values('DeleteBillFieldInfoForBUG68518',null,1,0)
end
GO
--新增税收编码40.0：税控技术维护服务
if not exists(select 1 from Erp_Sys_UpdateSign where SignName='InsertTaxClassifyCode40')
begin
	if not exists(select 1 from TaxClassifyCodes where MergeCoding = '3040201050000000000')
	begin
		insert into TaxClassifyCodes(P, L, Z, J, T, K, X, M, ZM, XM, MergeCoding, GoodsName, ClassifyShorterForm, Explain, TaxRate, SpecialManagement, PolicyBasis, SpecialContentCode, ExciseTax, ExciseTaxPolicyBasis, ExciseTaxCode, KeyWord, SummaryItem, BureauOfStatisticsCode, ImportAndExportItems, EnableTime, DeadlineOfTransitionPeriod, Version,UpTime) values (3,04,02,01,05,00,00,00,00,00,'3040201050000000000','税控技术维护服务','税控技术维护服务','服务单位为使用金税盘、税控盘等税控专用设备的纳税人提供的增值税税控系统技术维护服务，不包括增值服务。','6%','','','','','','','税控服务','否','','','2022-03-01 00:00:00','2022-03-01 00:00:00','40.0','2022-10-11 14:17:14')
	end
	insert into Erp_Sys_UpdateSign(SignName,SignValue,SignTime) values ('InsertTaxClassifyCode40',1,GetDate())	
end
GO
--92版本以后登记中间表需要清除isold=1数据，否则会出现成本重复
if not exists(select 1 from home_usConfig where name = 'MaterialRegistreIsOld' and uid=0)
begin
	delete from M2_RegisterOccupy where IsOld=1
	insert into  home_usConfig  (name, nvalue, uid) values ('MaterialRegistreIsOld', 1, 0)
end
GO

--处理预付款审批流程遗留老数据
IF EXISTS ( SELECT TOP 1 1
            FROM    dbo.sp_ApprovalInstance a
                    LEFT JOIN dbo.bankin2 bk ON a.PrimaryKeyID = bk.ID
            WHERE   gate2 = 43001
                    AND a.del = 1
                    AND ISNULL(bk.Del, 2) = 2 )
    BEGIN
        DELETE  a
        FROM    dbo.sp_ApprovalInstance a
                LEFT JOIN dbo.bankin2 bk ON a.PrimaryKeyID = bk.ID
        WHERE   gate2 = 43001
                AND a.del = 1
                AND ISNULL(bk.Del, 2) = 2;
    END
GO
--3206版本及之前版本返工入库登记potype存储为返工类型错误数据修复
if(exists(select top 1 1 from M2_MaterialRegisters where poType=2))
begin
  update mr set mr.poType=1
  from dbo.M2_MaterialRegisters mr
  where mr.poType=2
end
--处理预收款审批流程遗留老数据
IF EXISTS ( SELECT TOP 1 1
            FROM    dbo.sp_ApprovalInstance a
                    LEFT JOIN dbo.bankout2 bk ON a.PrimaryKeyID = bk.ID
            WHERE   gate2 = 44001
                    AND a.del = 1
                    AND ISNULL(bk.Del, 2) = 2 )
    BEGIN
        DELETE  a
        FROM    dbo.sp_ApprovalInstance a
                LEFT JOIN dbo.bankout2 bk ON a.PrimaryKeyID = bk.ID
        WHERE   gate2 = 44001
                AND a.del = 1
                AND ISNULL(bk.Del, 2) = 2;
    END

GO

if not exists(select * from home_usConfig where name='ExistsUpdatedPrintTemplates')
begin
insert into home_usConfig(name,tvalue,uid)
values ('ExistsUpdatedPrintTemplates',',30E917ABFD14A54C8149242DA5766F17,60BF1BF4794C0A8F367E3B9429F0DB73,'
+ '0D9DA3877F2A49EA8DD361BE5FADBB15,4516D1FD2A62011DA3C9EAF5A53F8AF1,280779C6D1CC2D7BF5C5B8FAE4932738,517077FCD7D2B27D3D182C64BF81DF96,BA25223070609D9DA6CCB8DDE00132D9,C3427FB123499EA19923CAB7A772033A,51FA54CE5DE3D6F20DD26EA93385624F,8B0A2238BCACB1DC04E031C9C864570A,7DDDFF8245D85E937B53866176CF0EB0,0AB628276F0A37F21820963D60A531E8,1BC9376961C2E9CE083B6EB63AE9C0FC,B955CEF8AC5A2AF83A1AF59ABE850B4B,54C1464DD9B9CC3C2C9F2B784B8CD228,C0EF5316097F5650605344817A187E55,53F095C45B03E623778AF1ABB87EF43F,F474633288DD2C1667C0A5864E9F260F,B177ED0A25FF3C8D814140049B81B2E8,82C8F282C01D2089C7F6412D4D00FE69,8CCC4F27D67BC195F8B02216EB0E975B,DB18F73604AC588E307D290563F583D4,ADF5AAB5F52225BDB6852B050C9FD566,7C19C8D0D3DC5CA029DAB3142CBE7A74,54FC9282D53C40B65D7297281FF8D410,A08196E030AB9F94D3294D0F7600E942,4BF11CF64B4B590C086C6EA598BF1B08,B42DB625730CE35B337BE2A8695CABC8,2F743460F61BE10625C6680E1A6A0E0A,9ACE766DFA6CFBDE1AC685BF3FF27296,4A747AAEC5A53EAE730A53628BD50C17,E21D6ACB8F8FFBA9164AB5F888FECE40,1D4C8EABF37C99DF12A7AAFDD840D61C,68A229AFBC26607F12AD797BB0FD728B,29A30A2DC896BB6097EA9CB4D83F047F,'
+'BA90701B7DA5A20C7AD86FDF589D0933,516D8F63B975E9C890FA414DE89D1C3E,8F15EDA42FF26839D3E7DD3D8030C7B5,2B60801245DF970385AE5EB1C30D9073,39E96819363BA1455F72F8C52CD525BE,CF9DDE637411E30365C5695AF546898C,A36F690344DDDC4830786AEEA82CA3DF,AE99F13F0B84D664A97F2E4B910133C1,16C31648021D9DC6BADB0EB7BB586693,6F596C90CAEAFDC0BE48901D4F0A2433,B9FFF9878850557D0654B5875D71B18B,6B68C8D101F417D20101878DF7065867,3744B4CE58E9E8CA76335599316B84E3,6802967A2E363B7980981786F3EF9DB4,4DB1F49D73C41108631496E5A3B192F8,D30DA41B823B1F0496A4D3D1D5809948,17CE0CA7D5913FDD1848B2870DBFFCCE,F66F8F647EA1D66A549E7BCC1C0A78CC,1591D5EC53B107F61F6C170B66BFB7CA,192F0F20A352797578E679DC713BAF82,A4D2B7BBF98C0E13CFCEE3374F958E63,A473B57F308B2C918B48CADE4EB123D9,57BF93B8E0703AD679CD07D8469FA924,2833C9588649D91AC9DC07EB28877D08,D090E325F33A6102FCE058D9AF52F9FB,FDB5609D6BCB9A5216F1A2D96F08B353,EF134336DB1BF4D148361DC7EB8D252D,D816DFF19C6BB3FA39CEA60C7F88B1DB,'
+ 'BA69E1B2664573CC46589C2A4DAE4972,83EEFE9BB5667179ED5EEA413B86417B,B658B3071246DDCBE705463A8EFDEFFA,B29BE513B5F1AF0BE6B541AC3DC4A6C4,C1A1FE9685CD462D14A3F0DC7946DB34,AF68700337588303AD210B6CAD6D1354,5DFC3B9502CB782D2154F8C9CDC4AE37,C4D6CA69687A8377CB9B7D10E0C12A37,52680351836C241F7975FD640CDE3380,757721E8549B3727A6BCDF577A1CF851,4DB27187ED6A2AAF7FE1B85B408AB6A7,EC825D7CC491615E0DB975D1D495DADF,739189E5DC901F29C9FCE2D42C0EE413,7D1B0A29348F441EF086E89570FAF6B8,2EED4D499E381A989F26C12812C67AF6,3B6E6A6277EB01D90BBB26903A2CB3EC,45BC3194D14B22BFF68F0227C0C1F880,27D8CD64D270424C8748E54898912E4C,B3BF89CEE37FDBCFC5DC5D70173B2EBA,9D9BBC14B0ABEBEA003E899FA00A71CE,885ED397F412230DE0F3D8773EA331C1,2D878702BCC4C9F9574CE1131E45B633,A4B7F0EE7A68B7A49AD1E2F935E2E278,D93444DDBBD6A4EFCFD5A77280CAEA65,AB2CD8B74DFC096402408E101DE83F0E,7F465101E37BAC74BCE8E07D7DBFFDDE,4774BE235779146E1AD7712D39DE5A64,D21B88E7ADCE8A5072E12DBD88F4759A,1178E5A0044E43D8207F4609407527D2,9F0F4AFDACD2686504380E05E6668485,BC872302D149100E67D49178C73220B5,1A66802EE256B0F82BD30BB6A48E1B16,9E561554BE41B614F8A971EF842965B4,'
+'282CBEDB0A23A9F352840B62A749AB41,200B31B8B717E7DC2ED1DCA82AC25D70,FD67EC5B09D40EF6E1CA5891044F62C1,E3CBC9E3D08B219B018EBDED37176284,77B4018F6355055BA4DE82F62EC043A6,E0AE7EE4EC4D549706A76CCEF82FF44F,A53D41A73F75E3B1767108D9F1E08734,7540FC33A60C83EFF594FB8442828A28,F3910B75C1AD3B2A358BCA48F3C072E0,35E4095F95A3D89D0A51895B9F650E72,6378EB9C1723956C59BDD0B2D44F3972,96731BF0AD3CD8225F494B1AD11B58EE,2D5D6BF176D60E92F53FA7C956966D60,7047489548E19874D102157FCCC867D0,1A28DEAB19E8C7136E446CD9E7EC41AD,A89D04BE6D8702F2A6783E2D8AA5AA3F,E6B7940718655F2604A442E272126A82,F04AB196738A00F2F98A9A2E87C768D1,9257BABE81A526850DDEC1E12E6217F8,86161D01694564752C2577918315915B,6AAF278F2AA0AAD40236E8F46C3DFD31,D948F4BE643E29A03FB61CE12DE1F516,D3EF9D54FA6EB6560DA352451DB7A660'
, 0);
end 

GO
--[BUG:70850]临后Bug：产品自定义提示已用删除不了
if not exists(select 1 from home_usConfig where name = 'HistoryBUG70850BillFieldValue3208V')
begin
	--删除物料清单备份历史遗自定义
    delete from Sys_sdk_BillFieldValue 
	where BillType=51007
	and not exists(
		select top 1 1 
		from dbo.M2_PlanBomList a 
		inner join dbo.M2_ManuPlanLists b on a.MPLID=b.ID
		where a.MPLID=BillId and a.id=ListID
	)
	--删除补料历史遗自定义
	delete Sys_sdk_BillFieldValue 
	where BillType=55006
	and exists(
		select top 1 1 
		from Sys_sdk_BillFieldValue a 
		left join dbo.M2_MaterialOrders b on a.BillType=55006 and a.BillId=b.ID
		where a.BillType=55006 and a.iord=iord and b.ID is null
	)

	insert into home_usConfig (name, nvalue, uid) values ('HistoryBUG70850BillFieldValue3208V', 0, 0)
end
GO
--[BUG:71179] 临后Bug：发货时候显示的快递公司，在设置里不显示（恢复已删除但未停用的快递公司）
if not exists(select 1 from home_usConfig where name = 'logisticsStatement')
begin
	update sortonehy set del=1 where gate2=83 and del=2 and isStop=0
    insert into home_usConfig (name, nvalue, uid) values ('logisticsStatement', 0, 0)
end
GO
--批量清理无效的入库扩展自定义数据
if exists(select top 1 1 from sys_sdk_BillFieldValue a with(nolock) left join kuinlist b with(nolock) on a.BillId = b.kuin and a.ListID = b.id where a.BillType = 61001 and a.BillListType=1 and b.id is null)
begin
		delete a from sys_sdk_BillFieldValue a left join kuinlist b on a.BillId = b.kuin and a.ListID = b.id where a.BillType = 61001 and a.BillListType=1 and b.id is null
end
GO
--清理历史重复的总金额小数位数配置信息
if exists(select top 1 1 from setjm3 where ord=1 group by ord having count(1)>1)
begin
	delete a from setjm3 a
	left join (
		select min(id) id from setjm3 where ord=1 group by ord 
	) b on a.id = b.id
	where a.ord=1 and b.id is null
end
GO
--清理历史重复的数量小数位数配置信息
if exists(select top 1 1 from setjm3 where ord=88 group by ord having count(1)>1)
begin
	delete a from setjm3 a
	left join (
		select min(id) id from setjm3 where ord=88 group by ord 
	) b on a.id = b.id
	where a.ord=88 and b.id is null
end
GO
--修正序列号关系表61001和62001类型的数据BillListType=0的问题数据
if exists(select top 1 1 from S2_SerialNumberRelation where BillType in (61001,62001) and BillListType = 0)
begin
	update S2_SerialNumberRelation set BillListType = 1 where BillType in (61001,62001) and BillListType = 0
end
GO
--修复产品曾经使用的单位在价格策略表中不存在的数据
if exists(select top 1 1 from ku a with(nolock)
	inner join product b with(nolock) on a.ord = b.ord 
	inner join sortonehy s with(nolock) on s.ord = a.unit
	where not exists (select top 1 1 from jiage with(nolock) where product =b.ord and unit = a.unit )
	and not exists (select top 1 1 from jiage with(nolock) where -product =b.ord and unit = a.unit ))
begin
	--查询需要补的单位
	select distinct s.ord as punit,b.ord 
		into #needInsertUnits
	from ku a with(nolock)
	inner join product b with(nolock) on a.ord = b.ord
	inner join sortonehy s with(nolock) on s.ord = a.unit
	where  not exists (select top 1 1 from jiage with(nolock) where product =b.ord and unit = a.unit )
		and not exists (select top 1 1 from jiage with(nolock) where -product =b.ord and unit = a.unit )

	--插入jiage表数据
	insert into jiage(bm,bl,unit,cgMainUnit,txm,price1jy,price1,price2jy,price2,price3,sort,product,MainStore,StoreCapacity,xlhManage)
	select 0,1,punit,0,'',0,0,0,0,0,0,ord,0,0,0 
	from #needInsertUnits

	--更新product表unit字段
	update a set a.unit = (select stuff((select ','+cast(jiage.unit as varchar(10)) from jiage with(nolock) where product=a.ord and bm=0 group by jiage.unit  for xml path('')),1,1,''))
	from product a
	inner join #needInsertUnits t on t.ord = a.ord

	drop table #needInsertUnits
end

GO
--修复历史版本拆分入库明细的num2=0
if exists(select top 1 1 from kuinlist a with(nolock) inner join kuin b with(nolock) on a.kuin = b.ord and b.sort1=10 and b.complete1=3 and b.del=99 inner join ku c with(nolock) on c.kuinlist = a.id and c.ord = a.ord and c.unit = a.unit and a.num1 = a.num1 where a.num1<>a.num2)
begin
	update a set a.num2 = a.num1
	from kuinlist a
	inner join kuin b with(nolock) on a.kuin = b.ord and b.sort1=10 and b.complete1=3
	inner join ku c with(nolock) on c.kuinlist = a.id and c.ord = a.ord and c.unit = a.unit and a.num1 = a.num1
	where a.num1<>a.num2
end

GO

--修复对接模板默认值异常问题
if not exists(select 1 from home_usConfig where name = 'F_voucherDefErr')
BEGIN
	if NOT exists( SELECT 1 FROM  sys.tables t INNER  JOIN  sys.columns c  ON  t.object_id = c.object_id INNER JOIN  sys.default_constraints dc  
	ON  c.default_object_id = dc.object_id WHERE t.name = 'F_VoucherTemp' AND c.name = 'Currency' )
	BEGIN
		 alter table F_VoucherTemp
		 add default 1 for Currency
	END

	if exists (select 1 from f_VoucherTemp where Currency is null)
	begin 
		update f_VoucherTemp set Currency=1 where Currency is null
	end

	if NOT exists( SELECT 1 FROM  sys.tables t INNER  JOIN  sys.columns c  ON  t.object_id = c.object_id INNER JOIN  sys.default_constraints dc  
	ON  c.default_object_id = dc.object_id WHERE t.name = 'F_VoucherTemp' AND c.name = 'OriginalID' )
	BEGIN
		 alter table F_VoucherTemp
		 add default 0 for OriginalID
	END

	if exists (select 1 from f_VoucherTemp where OriginalID is null)
	begin 
		update f_VoucherTemp set OriginalID=0 where OriginalID is null
	end

	if NOT exists( SELECT 1 FROM  sys.tables t INNER  JOIN  sys.columns c  ON  t.object_id = c.object_id INNER JOIN  sys.default_constraints dc  
	ON  c.default_object_id = dc.object_id WHERE t.name = 'F_VoucherTemp' AND c.name = 'EntryEnhance' )
	BEGIN
		 alter table F_VoucherTemp
		 add default 0 for EntryEnhance
	END

	if exists (select 1 from f_VoucherTemp where EntryEnhance is null)
	begin 
		update f_VoucherTemp set EntryEnhance=0 where EntryEnhance is null
	end

	if NOT exists( SELECT 1 FROM  sys.tables t INNER  JOIN  sys.columns c  ON  t.object_id = c.object_id INNER JOIN  sys.default_constraints dc  
	ON  c.default_object_id = dc.object_id WHERE t.name = 'F_VoucherListTemp' AND c.name = 'Currency' )
	BEGIN
		 alter table F_VoucherListTemp
		 add default 1 for Currency
	END

	if exists (select 1 from F_VoucherListTemp where Currency is null)
	begin 
		update F_VoucherListTemp set Currency=1 where Currency is null
	end

	if NOT exists( SELECT 1 FROM  sys.tables t INNER  JOIN  sys.columns c  ON  t.object_id = c.object_id INNER JOIN  sys.default_constraints dc  
	ON  c.default_object_id = dc.object_id WHERE t.name = 'F_VoucherListTemp' AND c.name = 'OriginalMxID' )
	BEGIN
		 alter table F_VoucherListTemp
		 add default 0 for OriginalMxID
	END

	if exists (select 1 from F_VoucherListTemp where OriginalMxID is null)
	begin 
		update F_VoucherListTemp set OriginalMxID=0 where OriginalMxID is null
	end
	insert into home_usConfig (name, nvalue, uid) values ('F_voucherDefErr', 0, 0)
end
GO
--清理入库出库发货无效的序列号关系
if not exists(select 1 from Erp_Sys_UpdateSign where SignName = 'xlh_S2_SerialNumberRelation_clear')
BEGIN
	delete from S2_SerialNumberRelation where BillType=61001 and not exists(select  top 1 1 from kuinlist where id= abs(ListID))
	delete from S2_SerialNumberRelation where BillType=62001 and not exists(select  top 1 1 from kuoutlist2 where id= abs(ListID))
	delete from S2_SerialNumberRelation where BillType=68001 and not exists(select  top 1 1 from sendlist where id= abs(ListID))
	update M2_SerialNumberList set status = 0 where status = 1 and not exists(select top 1 1 from S2_SerialNumberRelation where SerialID =M2_SerialNumberList.ID)

	insert into Erp_Sys_UpdateSign(SignName,SignValue) values('xlh_S2_SerialNumberRelation_clear',1)
END
GO
--3208修复产品主采购单位重复的数据
if not exists(select 1 from Erp_Sys_UpdateSign where SignName='V3208_product_cgmainunit' )
begin
	select product,count(1) n into #temp_jiage from (
		select distinct product,unit from jiage with(nolock) where cgMainUnit=1
	) t group by product having count(1)>1

	if exists(select 1 from #temp_jiage)
	begin
		update b set b.cgMainUnit=0
		from jiage a with(nolock)
		inner join #temp_jiage t on t.product = a.product
		inner join jiage b on t.product=b.product and a.unit <>b.unit
		inner join product c with(nolock) on c.ord = t.product and a.unit = c.unitjb

		update a set a.cgMainUnit = 0
		from jiage a
		inner join #temp_jiage t on t.product = a.product
		inner join product p with(nolock) on p.ord =t.product and a.unit!=p.unitjb
		inner join (
			select a.product,min(a.unit) minunit 
			from jiage a with(nolock)
			inner join #temp_jiage t on t.product = a.product
			inner join product p with(nolock) on a.product = p.ord and a.unit<>p.unitjb
			group by a.product
		) b on a.product = b.product and a.unit!=b.minunit
	end
	drop table #temp_jiage
	insert into Erp_Sys_UpdateSign(SignName,SignValue) values('V3208_product_cgmainunit',1)
end
GO
--V32.08清理产品无效单位的成本日志记录
if exists(
	select top 1 1 from MCostlog a where not exists(
		select 1 from kuinlist b with(nolock) where b.ord = a.ProductId and a.LogUnit = b.unit
		union
		select 1 from ku c with(nolock) where c.ord = a.ProductId and a.LogUnit = c.unit
		union
		select 1 from kuoutlist2 d with(nolock) where d.ord = a.ProductId and a.LogUnit = d.unit
		union
		select 1 from jiage e with(nolock) where e.product = a.ProductId and a.LogUnit = e.unit
	)
)
begin
	delete a from MCostlog a where not exists(
		select 1 from kuinlist b with(nolock) where b.ord = a.ProductId and a.LogUnit = b.unit
		union
		select 1 from ku c with(nolock) where c.ord = a.ProductId and a.LogUnit = c.unit
		union
		select 1 from kuoutlist2 d with(nolock) where d.ord = a.ProductId and a.LogUnit = d.unit
		union
		select 1 from jiage e with(nolock) where e.product = a.ProductId and a.LogUnit = e.unit
	)
end
GO
--修复仓库分类深度不正确的数据
if exists(select top 1 1 from sortck1 where Depth>10)
begin
	declare @maxdeep int
	set @maxdeep = 0
	update sortck1 set Depth=0 where ParentID=0 and Depth>0
	while exists(select top 1 1 from sortck1 where Depth= @maxdeep)
	begin
		set @maxdeep = @maxdeep + 1
		update y set y.Depth=x.Depth+1 from sortck1 x inner join sortck1 y on x.ID=y.ParentID and x.Depth = (@maxdeep-1) and y.Depth>0 
	end
end