--<%response.end%>
CREATE VIEW [dbo].[gate1]
as 
select ID, id as ord, Name as sort1, sort as gate1, openprice as num1, 0 as tj1, 0 as tj2, 0 as tj3, 0 as tj4 from orgs_parts where ispart = 1

GO

CREATE VIEW [dbo].[gate1_full] 
as 
select ID, id as ord, Name as sort1, sort as gate1, openprice as num1, 0 as tj1, 0 as tj2, 0 as tj3, 0 as tj4 from orgs_parts

GO

CREATE VIEW [dbo].[pricegate1]
as 
select ID, id as ord, Name as sort1, sort as gate1, openprice as num1, 0 as tj1, 0 as tj2, 0 as tj3, 0 as tj4 from orgs_parts where openprice = 1 and stoped=0

GO

create view [dbo].[gate2]
as 
select ID, id as ord, pid as sort1, Name as sort2, sort as gate2, 0 as tj1, 0 as tj2, 0 as tj3, 0 as tj4 from orgs_parts where isgroup = 1

GO

CREATE view [dbo].erp_GetWWNumOrHgNum_view
as
--获取委外单数量和质检合格数量的=已执行数量
select M2OOl.WFPAID, (case when SUM(ISNULL(M2OOl.num1,0)) >=SUM(ISNULL  (ebq.certNum,0))
                            then  SUM(ISNULL(M2OOl.num1,0)) else SUM(ISNULL(ebq.certNum,0)) end) as num                 
                                    from M2_OutOrderlists M2OOl
                                    INNER JOIN M2_OutOrder M2OO on M2OOl.outID = M2OO.ID and  
                                    isnull(M2OO.[status],-1)<>0 and m2ool.del = 1 and M2OO.del = 1 and M2OO.TempSave = 0 and M2OO.wwType = 1
                                    LEFT JOIN (
	                                    select PID,sum(certNum) certNum from erp_Bill_QualityTestLogic()
                                        where billType=54006
	                                    group by PID
                                    ) ebq ON ebq.PID = M2OOl.ID
                                    group by M2OOl.WFPAID 

GO

CREATE FUNCTION [dbo].[EqualsNumberBit]  
(  
 @v1 DECIMAL(25,12),  
 @v2 DECIMAL(25,12),  
 @numbit INT  
)   
RETURNS INT  
AS  
BEGIN  
 DECLARE @return INT, @difference DECIMAL(25,12)  
 SET @difference = POWER(CAST(0.1 AS decimal(25,12)),@numbit)  
 IF(@numbit = 0)  
 BEGIN  
  SET @difference = 0  
	set @return= (SELECT CASE WHEN ABS(@v1 - @v2) <= @difference THEN 1 ELSE 0 END)
 END  
 else
 begin
	 set @return= (SELECT CASE WHEN ABS(@v1 - @v2) < @difference THEN 1 ELSE 0 END) 
 end
 return @return
END 

GO
CREATE    function [dbo].[erp_CreateLink](
--根据参数生成链接
@StrTitle varchar(200),--链接文本
@LinkType int,--链接类型，1：单据，2：人，3：产品
@OrderType varchar(15),--如果链接类型是单据则代表单据配置号
@ID varchar(15), --单据ID
@Creator int, --创建人
@uid int,--当前用户
@sort1 int,--主权限号
@sort2 int --辅权限号
) returns varchar(4000)
begin
	declare @rValue varchar(4000),@url varchar(1000)
	declare @qx_type int,@qx_open int,@qx_intro varchar(4000),@hasPower bit
	if @LinkType=2
		--set @rValue='<a href="###" class=com onclick="Bill.LinksPeople('''+@ID+''')">'+@StrTitle+'</a>'
		set @rValue=@StrTitle
	else
	begin
		select @qx_type=sort from qxlblist where sort1=@sort1 and sort2=@sort2
		set @qx_type=isnull(@qx_type,-1)
		select @qx_open=qx_open,@qx_intro=cast(qx_intro as varchar(4000)) from power where ord=@uid and sort1=@sort1 and sort2=@sort2
		set @qx_open=isnull(@qx_open,0)
		set @qx_intro=isnull(@qx_intro,'')
		if @qx_open=@qx_type or (@qx_open=1 and charindex(','+cast(@Creator as varchar(15))+',',','+replace(@qx_intro,' ','')+',')>0)
		begin
			if @LinkType=1
				set @rValue='<span class=link title="查看单据详细资料" onmouseover=Bill.showunderline(this,"#ff0000") onclick=ck.SpShowList(' + @OrderType + ','
				 + cast(@ID as nvarchar(15)) + ',0,''detail'') onmouseout=Bill.hideunderline(this,"#0000ff")>'+@StrTitle+'</span>'
			else if @LinkType=3
				set @rValue='<a href="../../product/content.asp?ord=' + dbo.NumEnCode(cast(@ID as varchar(30))) + '" target=_blank class=com>' + @StrTitle + '</a>'
			else
				set @rValue=@StrTitle
		end
		else
		begin
			set @rValue=@StrTitle
		end
	end

	return @rValue
end

GO

CREATE   function [dbo].[erp_MaterialOrderComplete](@bill_ID as int) returns int
--判断生产订单成品入库状态
--返回值
--10 已核算
--0 无入库申请
--1 部分入库申请
--2 入库申请完毕,不完全入库
--3 入库完毕
begin
	declare @Complete as int,@num0 as decimal(25,12),@num1 as decimal(25,12),@num2 as decimal(25,12),@returnvalue as int
	select @Complete=Complete from M_ManuOrders where id=@bill_ID
	if @Complete=1 --已合算过成本
	begin
		set @returnvalue=10
	end
	else
	begin
		select @num0=b.NumDecide,@num1=isnull(sum(i.num1),0),@num2=isnull(sum(i.num2),0) from M_ManuOrders a
		inner join M_ManuOrderLists b on a.id=b.MOrderID
		inner join M_planBOMList c on c.id=b.BOMListID and c.ParentBomID=0
		inner join M_ManuOrderIssuedLists d on d.MOrderListID=b.id
		inner join M_WorkAssigns e on e.MOIListID=d.id
		inner join M_MaterialProgres f on f.WAID=e.id
		inner join M_MaterialProgresDetail g on g.MPID=f.id
		inner join M_QualityTestingLists h on h.MPDID=g.id
		inner join kuinlist i on i.QTLID=h.id
		where a.id=@bill_ID
		group by b.id,b.NumDecide,a.Complete
		if isnull(@num0,-1)=-1 and isnull(@num1,-1)=-1 and isnull(@num2,-1)=-1
		begin
			set @returnvalue=0
		end
		else if @num0>@num1
		begin
			set @returnvalue=1
		end
		else if @num0<=@num1 and @num0>@num2
		begin
			set @returnvalue=2
		end
		else if @num0<=@num1 and @num0<=@num2
		begin
			set @returnvalue=3
		end
	end
	return @returnvalue
end
go

CREATE VIEW [dbo].[erp_sys_currLink]
AS
SELECT @@CONNECTIONS AS curLinkID

Go

CREATE view [dbo].[testIDXview]
as
	select SCOPE_IDENTITY() a

GO

CREATE VIEW [dbo].[v_CaigouSaleMoney]
AS
select (case when s_a.num1=0 then 0 else cast(isnull(cast(s_b.num1/s_a.num1 as decimal(25,12))*s_a.money1,0) as decimal(25,12))*isnull(h.hl,1) end) sumsale,y.* from contractlist s_a
inner join kuoutlist2 s_b on s_b.del=1 and s_a.id=s_b.contractlist AND s_a.del=1
inner join caigoulist s_c on s_b.caigoulist=s_c.id and s_c.del=1
inner join caigou y on s_c.caigou=y.ord and y.del=1
left join hl h on s_a.date1=h.date1 and s_a.bz=h.bz
UNION ALL
SELECT (CASE WHEN s_a.num1=0 THEN 0 ELSE cast(ISNULL(cast(s_d.num1/s_a.num1 as decimal(25,12))*s_a.money1,0) as decimal(25,12))*ISNULL(h.hl,1) END) sumsale,y.* FROM contractlist s_a
INNER JOIN kuoutlist2 s_b on s_b.del=1 and s_a.id=s_b.contractlist AND s_a.del=1
INNER JOIN ku s_c ON s_b.ku=s_c.id
INNER JOIN kuhclist s_d ON s_d.kuid=s_c.id AND s_d.del=1
INNER JOIN kuinlist s_e ON s_e.id=s_d.kuinlist AND s_e.del=1
INNER JOIN caigoulist s_f ON s_f.id=s_e.caigoulist
INNER JOIN caigou y on s_f.caigou=y.ord and y.del=1
left join hl h on s_a.date1=h.date1 and s_a.bz=h.bz

Go

CREATE VIEW [dbo].[v_Gather_ProductGeneralView]
as
select
a.title as 产品名称,
isnull(cast(a.ord as varchar(10)),'')+'-'
+isnull(cast(c.id as varchar(10)),'')+'-'
+isnull(cast(g.id as varchar(10)),'')+'-'
+isnull(cast(d.id as varchar(10)),'')+'-'
+isnull(cast(b.id as varchar(10)),'')+'-'
+isnull(cast(e.id as varchar(10)),'') as 主键_ID,
a.ord as 产品_ID,
b.unit as 产品单位_ID,
o.sort1 as 产品单位,
a.addcate as 添加人_ID,
a.sort1 as 产品分类_ID,
a.date7 as 产品添加时间,
c.[DATEADD] as 入库时间,
g.[DATEADD] as 采购时间,
d.date1 as 出库时间,
e.date1 as 合同时间,
a.order1 as 产品编号,
a.type1 as 产品型号,
(case when isnull(c.del,0)=1 then b.num3 else 0 end)+isnull((select SUM(num1) from kuhclist where del=1 and kuid=b.id),0) as 入库数量_DONUM_DOSUM,
isnull(case when b.num1<=0 then 0 else b.money1/b.num1 end,0) as 入库单价_DONUM,
isnull(case when b.num1<=0 then 0 else b.money1 end,0) as 入库总价_DONUM_DOSUM,
isnull((d.num1),0) as 出库数量_DONUM_DOSUM,
isnull((select sort1 from sortbz s_a where s_a.id=e.bz),'人民币') as 出库币种,
isnull(e.price1,0) as 出库单价_DONUM,
isnull((case when e.num1=0 then 0 else cast(d.num1/e.num1 as decimal(25,12))*e.money1 end),0) as 出库总价_DONUM_DOSUM,
isnull((case when b.num1<=0 then 0 else cast(d.num1/b.num1 as decimal(25,12))*b.money1 end),0) as 出库成本总价_DONUM_DOSUM,
isnull((b.num2),0) as 剩余数量_DONUM_DOSUM,
isnull((case when b.num1<=0 then 0 else cast(b.num2/b.num1 as decimal(25,12))*b.money1 end),0) as 剩余成本_DONUM_DOSUM,
isnull((select sort1 from sortck where ord=b.ck),'未知') as 仓库,
isnull(b.ck,0) as 仓库_ID,
isnull(b.ph,'') as 批号,
isnull(b.xlh,'') as 序列号,
b.datesc as 生产日期,
b.dateyx as 有效日期,
l.sort1 as 包装,
b.bz as 包装_ID,
b.js as 件数,
c.sort1 as 入库类型_ID,
m.OpTypeName as 入库类型,
c.intro as 入库备注,
f.title as 入库主题,
f.ord as 入库单_ID,
f.cateid as 入库单添加人_ID,
h.title as 关联采购单,
h.ord as 采购单_ID,
h.cateid as 采购人员_ID,
isnull((select [name] from tel where ord=h.company),'') as 关联供应商,
h.company as 供应商_ID,
p.cateid as 供应商销售人员_ID,
d.sort1 as 出库类型_ID,
n.OpTypeName as 出库类型,
d.intro as 出库备注,
i.title as 出库主题,
i.ord as 出库单_ID,
i.cateid as 出库单添加人_ID,
j.title as 关联合同,
j.ord as 合同_ID,
j.cateid as 合同销售人员_ID,
k.name as 关联客户,
k.ord as 关联客户_ID,
k.cateid as 关联客户销售人员_ID
from product a
inner join ku b on a.ord=b.ord
left join kuinlist c on c.id=b.kuinlist and (c.del=1 or c.del=99)
left join kuin f on f.ord=c.kuin and f.del=1
left join caigoulist g on ((g.id=c.caigoulist AND c.sort1<>2) OR (g.id=c.caigoulist2 AND c.sort1=2)) and g.del=1
left join caigou h on h.ord=g.caigou and h.del=1
left join tel p on h.company =p.ord and p.del=1
left join kuoutlist2 d on d.ku=b.id and (d.del=1 or d.del=99)
left join kuout i on i.ord=d.kuout and i.del=1
left join contractlist e on ((d.sort1<>2 AND d.contractlist=e.id) OR (d.sort1=2 AND c.sort1=2 AND e.id IN (SELECT s_b.contractlist FROM contractthlist s_a INNER JOIN kuoutlist2 s_b ON s_a.kuoutlist2=s_b.id AND s_a.del=1 AND s_b.del=1 WHERE s_a.id=c.caigoulist ))) and e.del=1
left join contract j on j.ord=e.contract and j.del=1
left join tel k on k.ord=j.company and k.del=1
left join sortonehy l on l.ord=b.bz
left join Store_OpTypeDefine m on m.typeId=c.sort1+100
left join Store_OpTypeDefine n on n.typeId=d.sort1+200
left join sortonehy o on o.ord=b.unit

GO


CREATE function [dbo].[erp_getBOMParentTree](@BOMID int) returns varchar(4000)
begin
	declare @Rank as int,@tmp as int,@returnStr as varchar(4000),@ProductID as int,@ProductName as varchar(100),@tmpid as int
	select @Rank=abs(RankCode),@tmp=0,@returnStr='',@ProductID=ProductID from M_BOMList where ID=@BOMID
	set @tmpid=@BOMID
	while @tmp<=@Rank
	begin
		select @ProductName=b.title,@tmpid=a.ParentID from M_BOMList a inner join product b on a.ProductID=b.ord where a.ID=@tmpid
		if isnull(@returnStr,'')=''
		begin
			set @returnStr=@ProductName
		end
		else
		begin
			set @returnStr=@ProductName+'->'+@returnStr
		end
		set @tmp=@tmp+1
	end
	return @returnStr
end

GO

CREATE VIEW [dbo].[erp_caigou_procc]
AS
select
	订单ID,	产品ID,
	sum(需求总量) as 需求总量,
	max(需求期) as 需求期,
	sum(预购总量) as 预购总量,
	max(预购货期) as 预购货期,
	sum(采购总量) as 采购总量,
	max(采购货期) as 采购货期,
	sum(到货总量) as 到货总量,
	max(到货日期) as 到货日期
from (
	select y.ddno as 订单ID,x.productID as 产品ID, x.num as 需求总量 ,dat1 as 需求期,
	cast(NULL as decimal(25, 12)) as 预购总量, cast(NULL as datetime) as 预购货期,
	cast(NULL as decimal(25, 12)) as 采购总量, cast(NULL as datetime) as 采购货期,
	cast(NULL as decimal(25, 12)) as 到货总量, cast(NULL as datetime) as 到货日期
	from M_ManuOrderWLLists x inner join  M_ManuOrderWL y on x.MOWL=y.ID

	union all
	select a.MorderID,b.ord,null,null,b.num1,b.date2,null,null,null,null
	from caigou_yg a inner join caigoulist_yg b on a.id=b.caigou and  a.MorderID >0


	union all

	select x.MorderID,y.ord,null,null,null,null,  y.num1,y.date2,y.num2,z.[dateadd] from (
		select distinct a.MorderID,b.caigou2
		from caigou_yg a inner join caigoulist_yg b on a.id=b.caigou and a.MorderID >0
	) x
	inner join caigoulist y on y.caigou = x.caigou2
	left join kuinlist z on z.caigoulist = y.id and exists(select kuinlist from ku where kuinlist = z.id)

) ss group by 订单id,产品ID

Go

CREATE VIEW [dbo].[erp_tree_bom_menu]
AS
SELECT b.BOM, b.ParentID, ISNULL(a.title, '未知键' + CAST(b.ID AS varchar(10))) AS title,
      b.ID, '' AS imageUrl, ISNULL
          ((SELECT TOP 1 1
          FROM M_BOMList c
          WHERE c.ParentID = b.ID and c.RankCode>=0 and c.del=0), 0) AS children
FROM dbo.product a RIGHT OUTER JOIN
      dbo.M_BOMList b ON a.ord = b.ProductID
where b.RankCode >= 0

GO

CREATE VIEW [dbo].[M_BomList_list]
AS
SELECT *
FROM dbo.M_BOMList
WHERE (RankCode < 0)

Go

CREATE VIEW [dbo].[erp_list_bomnode]
AS
SELECT ID, BOM AS BOM表, ParentID AS 所属产品, ProductID AS 产品编号, unit AS 单位,
      Num AS 数量
FROM dbo.M_BOMList

Go

CREATE VIEW [dbo].[ordersplist]
AS
SELECT b.ID, a.PrefixCode, a.spName, a.intro, a.Rank, a.LinkType
FROM dbo.M_FlowSettings a INNER JOIN
      dbo.M_OrderSettings b ON a.PrefixCode = b.PrefixCode

GO

CREATE VIEW [dbo].[erp_getAllIDs]
AS
SELECT     a.Complete AS 状态, a.CostAccounting AS 成本, a.ID AS 生产订单, b.ID AS 生产订单L, c.MOIID AS 下达单, c.ID AS 下达单L, d.ID AS 派工单,
                      o.ID AS 派工单L, p.ID AS 申请单, n.ID AS 申请单L, e.ID AS 进度单, f.ID AS 进度单汇报L, g.ID AS 进度单用料L, i.ID AS 质检单, h.ID AS 质检单L,
                      k.ID AS 使用单, j.ID AS 使用单L, m.ID AS 返工单, l.ID AS 返工单L, q.ID AS 返工汇报, r.ID AS 返工汇报单汇报L, s.ID AS 返工汇报单用料L
FROM         dbo.M_ManuOrders AS a LEFT OUTER JOIN
                      dbo.M_ManuOrderLists AS b ON a.ID = b.MOrderID LEFT OUTER JOIN
                      dbo.M_ManuOrderIssuedLists AS c ON c.MOrderListID = b.ID LEFT OUTER JOIN
                      dbo.M_WorkAssigns AS d ON d.MOIListID = c.ID LEFT OUTER JOIN
                      dbo.M_MaterialProgres AS e ON e.WAID = d.ID LEFT OUTER JOIN
                      dbo.M_MaterialProgresDetail AS f ON f.MPID = e.ID LEFT OUTER JOIN
                      dbo.M_MaterialProgresLists AS g ON g.MPID = e.ID LEFT OUTER JOIN
                      dbo.M_QualityTestingLists AS h ON h.MPDID = f.ID LEFT OUTER JOIN
                      dbo.M_QualityTestings AS i ON i.ID = h.QTID LEFT OUTER JOIN
                      dbo.M_MaterialProgresRawLists AS j ON j.MPDID = f.ID LEFT OUTER JOIN
                      dbo.M_MaterialProgresRaws AS k ON k.ID = j.MPRID LEFT OUTER JOIN
                      dbo.M_ProgresReturnLists AS l ON l.QTLID = h.ID LEFT OUTER JOIN
                      dbo.M_ProgresReturns AS m ON m.ID = l.PRID LEFT OUTER JOIN
                      dbo.M_WorkAssignLists AS o ON o.WAID = d.ID LEFT OUTER JOIN
                      dbo.M_MaterialOrderLists AS n ON n.WAListID = o.ID LEFT OUTER JOIN
                      dbo.M_MaterialOrders AS p ON p.ID = n.MOID AND p.WAID = d.ID and p.potype=0 LEFT OUTER JOIN
                      dbo.M_MaterialProgresDetail AS r ON r.PRLID = l.ID LEFT OUTER JOIN
                      dbo.M_MaterialProgres AS q ON q.ID = r.MPID LEFT OUTER JOIN
                      dbo.M_MaterialProgresLists AS s ON s.MPID = q.ID

GO
CREATE view [dbo].[sys_gate_view]
as
--账号、档案合集表
select ord,name,sorce,sorce2, cateid, 1 as gType from gate where del= 1
union all
select userid,username,sorce,sorce2 ,sign(sorce) + 1+sign(sorce2)*2, 0  as gtype from hr_person y where del=0 and not exists(select * from gate x where x.ord= y.userid and x.del=1)


GO
CREATE VIEW [dbo].[erp_list_scdd]
AS
SELECT     ID, PrefixCode, MPSID, MOBH, title, Creator, indate, DateBegin, DateEnd, DateDelivery, DateAdvance, PRI, id_sp, cateid_sp, status, TempSave, del,
                      Complete, SingleCosts, TotalCosts, CostAccounting, intro
FROM         dbo.M_ManuOrders AS c

GO

--生产领料
CREATE VIEW [dbo].[erp_getMaterialCK]
AS 
		SELECT     a.ID AS MOID, a.OrderType, a.status, b.ID AS MOLID, b.ProductID, b.unit, b.num1 AS numtotal, ISNULL
		  ((SELECT     SUM(ISNULL(aa.num1, 0)) AS Expr1
			  FROM      dbo.kuoutlist AS aa INNER JOIN
						dbo.kuout AS bb ON bb.ord = aa.kuout AND bb.complete1 <> 3 and bb.del=1
			  WHERE     (aa.MOrderID IS NOT NULL) AND (aa.MOrderID = b.ID)), 0) AS outnum1, ISNULL
		  ((SELECT     SUM(ISNULL(num1, 0)) AS Expr1
			  FROM         dbo.kuoutlist2
			  WHERE     del=1 AND (MOrderID IS NOT NULL) AND (MOrderID = b.ID)), 0) AS outnum2, a.Creator
	FROM  dbo.M_MaterialOrders AS a 
	INNER JOIN  dbo.M_MaterialOrderLists AS b ON b.MOID = a.ID
	WHERE  (a.OrderType = 1 OR
	  a.OrderType = 2) AND (b.num1 - 0.00000001 >= ISNULL
		  ((SELECT     SUM(ISNULL(aa.num1, 0)) AS Expr1
			  FROM         dbo.kuoutlist AS aa INNER JOIN
									dbo.kuout AS bb ON bb.ord = aa.kuout AND bb.complete1 <> 3 and bb.del=1
			  WHERE     (aa.MOrderID IS NOT NULL) AND (aa.MOrderID = b.ID)), 0) + ISNULL
		  ((SELECT     SUM(ISNULL(num1, 0)) AS Expr1
			  FROM         dbo.kuoutlist2 AS kuoutlist2_1
			  WHERE     del=1 AND (MOrderID IS NOT NULL) AND (MOrderID = b.ID)), 0))
GO

CREATE VIEW [dbo].[erp_getMaterialRK]
AS
	SELECT     a.ID AS MOID, a.OrderType, a.status, b.ID AS MOLID, b.ProductID, b.unit, b.num1 AS numtotal, ISNULL
		  ((SELECT     SUM(ISNULL(aa.num2, 0)) AS Expr1
			  FROM         dbo.kuinlist AS aa INNER JOIN
									dbo.kuin AS bb ON aa.kuin = bb.ord and bb.del=1
			  WHERE     (bb.complete1 = 3) AND (aa.MOrderID IS NOT NULL) AND (aa.MOrderID = b.ID)), 0) AS innum1, ISNULL
		  ((SELECT     SUM(ISNULL(aa.num1, 0)) AS Expr1
			  FROM         dbo.kuinlist AS aa INNER JOIN
									dbo.kuin AS bb ON aa.kuin = bb.ord and bb.del=1
			  WHERE     (bb.complete1 = 1) AND (aa.MOrderID IS NOT NULL) AND (aa.MOrderID = b.ID)), 0) AS innum2, c.money1 / c.num1 AS price1,
	  a.Creator
	FROM         dbo.M_MaterialOrders AS a INNER JOIN
	  dbo.M_MaterialOrderLists AS b ON b.MOID = a.ID LEFT OUTER JOIN
	  dbo.kuoutlist2 AS c ON c.MOrderID = b.ID
	WHERE     (a.OrderType = 3) AND (b.num1 > ISNULL
		  ((SELECT     SUM(ISNULL(aa.num2, 0)) AS Expr1
			  FROM         dbo.kuinlist AS aa INNER JOIN
									dbo.kuin AS bb ON aa.kuin = bb.ord and bb.del=1
			  WHERE     (bb.complete1 = 3) AND (aa.MOrderID IS NOT NULL) AND (aa.MOrderID = b.ID)), 0) + ISNULL
		  ((SELECT     SUM(ISNULL(aa.num1, 0)) AS Expr1
			  FROM         dbo.kuinlist AS aa INNER JOIN
									dbo.kuin AS bb ON aa.kuin = bb.ord and bb.del=1
			  WHERE     (bb.complete1 = 1) AND (aa.MOrderID IS NOT NULL) AND (aa.MOrderID = b.ID)), 0))

GO

CREATE VIEW [dbo].[erp_M2_getMaterialCK]
AS
	SELECT  a.ID AS MOID, 0 as OrderType, a.status
	    , b.ID AS MOLID, b.ProductID, b.unit
	    ,b.num1 AS numtotal, 
		ISNULL(b.cknum,0)-ISNULL(b.cknum2, 0) AS outnum1, 
		ISNULL(b.cknum2,0) AS outnum2, 
		a.Creator
	FROM M2_MaterialOrders AS a with(nolock) 
	INNER JOIN M2_MaterialOrderLists AS b  with(nolock) ON b.MOID = a.ID and b.Mergeinx<=0
	WHERE a.del=1 
		and (b.num1 - 0.00000001>=ISNULL(b.cknum, 0))
GO


CREATE VIEW [dbo].[erp_M2_getMaterialRK]
AS
	SELECT a.ID AS MOID, a.OrderType, a.status, b.ID AS MOLID, b.ProductID, b.unit, b.num1 AS numtotal, 
		ISNULL((SELECT SUM(ISNULL(aa.num2, 0)) AS Expr1
				FROM dbo.kuinlist AS aa 
				INNER JOIN dbo.kuin AS bb ON aa.kuin = bb.ord and bb.del=1
				WHERE (bb.complete1 = 3) AND isnull(aa.M2_OrderID,0) = b.ID), 0) AS innum1, 
							
		ISNULL((SELECT SUM(ISNULL(aa.num1, 0)) AS Expr1
				FROM dbo.kuinlist AS aa 
				INNER JOIN dbo.kuin AS bb ON aa.kuin = bb.ord and bb.del=1
				WHERE (bb.complete1 = 1) and isnull(bb.status,-1)<>0 AND isnull(aa.M2_OrderID,0) = b.ID), 0) AS innum2,		
		c.money1 / c.num1 AS price1,a.Creator
	FROM dbo.M2_MaterialRegisters AS a
	INNER JOIN dbo.M2_MaterialRegisterLists AS b ON b.MRID = a.ID and isnull(b.Mergeinx,0)<=0
	LEFT OUTER JOIN dbo.kuoutlist2 AS c ON c.id = b.kuoutlist2
	WHERE (CASE WHEN ISNULL(a.status,-1) IN(-1,1) THEN 
			(CASE WHEN a.OrderType = 2 OR (a.OrderType = 3 AND ISNULL(a.canRk,0) = 1) THEN 1 ELSE 0 END)
			ELSE 0 END)=1

GO
CREATE view [dbo].[erp_telandperson] as
select distinct  a.name as 客户名称 , a.khid  as 客户编号, a.phone as 电话, isnull(b.mobile,'') as 手机 , isnull(b.name,'') as 主联系人,a.cateid as 销售人员,a.sort3
from tel a left join person b on a.person = b.ord and b.del in (1,2)
where a.del in (1,2)
GO

CREATE VIEW [dbo].[v_KuDistinctView]
AS
select distinct ord AS p_ord,unit AS p_unit,ck AS p_ck from ku s_a

GO

CREATE VIEW [dbo].[erp_del_list_bomnode]
AS
SELECT top 10000 a.ID,
isnull((select top 1 c.title from product c where a.productID = c.ord), '产品【' + cast(a.productID as nvarchar(10)) + '】(资料无效)') AS 产品名称,
(
	 select d.sort1 from sortonehy d
 where d.gate2 =61 and d.ord= a.unit
) AS 单位,
a.Num AS 数量,b.indate as 添加时间, (select top 1 [name] from gate e where e.ord=b.creator) as 添加人,
b.BOMBH AS 物料清单, dbo.erp_getBOMParentTree(a.ProductID) AS BOM关系
FROM M_BOMList a, M_BOM b
where a.BOM = b.ID and   a.del =1  order by a.ID desc

GO
CREATE   VIEW [dbo].[erp_del_list_bom]
AS
SELECT ID, BOMBH AS BOM编号, dbo.erp_CreateLink(a.title,1,5,a.id,a.Creator,b.uid,56,14) AS BOM主题,
dbo.erp_CreateLink(ISNULL((SELECT TOP 1 name FROM gate WHERE ord = a.creator), '用户' + CAST(Creator AS varchar(10)) + '【已删】'),2,0,a.Creator,0,0,0,0)
 AS 添加人, indate AS 添加时间, DateBegin AS 生效日期, DateEnd AS 作废日期,
intro AS 备注
FROM dbo.M_BOM a
full join (select top 1 uid from M_CurUser where ID=@@CONNECTIONS) b on 1=1
WHERE del=1

Go

CREATE    VIEW [dbo].[erp_list_bom]
AS
SELECT ID, BOMBH AS BOM编号, dbo.erp_CreateLink(a.title,1,5,a.id,a.Creator,b.uid,56,14) AS BOM主题,
dbo.erp_CreateLink(ISNULL((SELECT TOP 1 name FROM gate WHERE ord = a.creator), '用户' + CAST(Creator AS varchar(10)) + '【已删】'),2,0,a.Creator,0,0,0,0)
 AS 添加人, indate AS 添加时间, DateBegin AS 生效日期, DateEnd AS 作废日期,
intro AS 备注
FROM dbo.M_BOM a
full join (select top 1 uid from M_CurUser where ID=SCOPE_IDENTITY()) b on 1=1
WHERE (del = 0) AND (TempSave = 0)

Go

CREATE   VIEW [dbo].[erp_list_scjh]
AS
SELECT ID, MPSBH AS 生产单号,
dbo.erp_CreateLink(a.title,1,3,a.id,a.Creator,b.uid,50,14) AS 主题,
dbo.erp_CreateLink(ISNULL((SELECT TOP 1 name FROM gate WHERE ord = a.creator), '用户' + CAST(Creator AS varchar(10)) + '【已删】'),2,0,a.Creator,0,b.uid,0,0) AS 添加人,
inDate AS 添加时间,
dbo.IIf(SIGN(CreateFrom - 1), '预测单', '合同') AS 计划依据,
dbo.IIf(SIGN(CreateFrom - 1),(SELECT TOP 1 '预测单:' + b.PredictBH FROM M_PredictOrders b WHERE b.ID = a.fromid),(SELECT TOP 1 '合同号:' + b.htid FROM contract b WHERE b.ord = a.fromid)) AS 依据单号
FROM dbo.M_ManuPlans a
full join (select top 1 uid from M_CurUser where ID=@@CONNECTIONS) b on 1=1
WHERE (TempSave = 0) AND (del = 0)

Go

CREATE   VIEW [dbo].[erp_del_list_scjh]
AS
SELECT ID, MPSBH AS 生产单号,
dbo.erp_CreateLink(a.title,1,3,a.id,a.Creator,b.uid,50,14) AS 主题,
dbo.erp_CreateLink(ISNULL((SELECT TOP 1 name FROM gate WHERE ord = a.creator), '用户' + CAST(Creator AS varchar(10)) + '【已删】'),2,0,a.Creator,0,b.uid,0,0) AS 添加人,
inDate AS 添加时间,
dbo.IIf(SIGN(CreateFrom - 1), '预测单', '合同') AS 计划依据,
dbo.IIf(SIGN(CreateFrom - 1),(SELECT TOP 1 '预测单:' + b.PredictBH FROM M_PredictOrders b WHERE b.ID = a.fromid),(SELECT TOP 1 '合同号:' + b.htid FROM contract b WHERE b.ord = a.fromid)) AS 依据单号
FROM dbo.M_ManuPlans a
full join (select top 1 uid from M_CurUser where ID=@@CONNECTIONS) b on 1=1
WHERE (del = 1)

GO

CREATE     VIEW [dbo].[erp_list_pgd]
AS
SELECT a.ID,
a.WABH AS 派工单号,
dbo.erp_CreateLink(a.title,1,8,a.id,a.Creator,c.uid,54,14) AS 主题,
(SELECT TOP 1 title FROM M_ManuOrderIssueds b inner join M_ManuOrderIssuedLists c on C.MOIID=B.ID WHERE c.ID = a.MOIListID) AS 对应下达单,
b.order1 AS 产品编号,
dbo.erp_CreateLink(b.title,3,0,b.ord,0,c.uid,21,14) AS 产品名称,
b.type1 AS 型号,
(SELECT TOP 1 sort1 FROM sortonehy b WHERE gate2 = 61 AND b.ord = a.unit) AS 单位,
a.NumMake AS 数量,
dbo.erp_CreateLink(ISNULL((SELECT TOP 1 name FROM gate WHERE ord = a.Cateid_WA), '用户' + CAST(a.Cateid_WA AS varchar(10)) + '【已删】'),2,0,a.Cateid_WA,0,c.uid,0,0) AS 派工人员,
a.DateWA AS 派工时间,
dbo.erp_CreateLink(ISNULL((SELECT TOP 1 name FROM gate WHERE ord = a.creator), '用户' + CAST(a.Creator AS varchar(10)) + '【已删】'),2,0,a.Creator,0,c.uid,0,0) AS 添加人,
a.inDate AS 添加时间
FROM dbo.M_WorkAssigns a
LEFT OUTER JOIN dbo.product b ON a.ProductID = b.ord
full join (select top 1 uid from M_CurUser where ID=@@CONNECTIONS) c on 1=1
WHERE (a.del = 0)

GO

CREATE VIEW [dbo].[erp_del_list_pgd]
AS
SELECT a.ID,
a.WABH AS 派工单号,
dbo.erp_CreateLink(a.title,1,8,a.id,a.Creator,c.uid,54,14) AS 主题,
(SELECT TOP 1 title FROM M_ManuOrderIssueds b inner join M_ManuOrderIssuedLists c on C.MOIID=B.ID WHERE c.ID = a.MOIListID) AS 对应下达单,
b.order1 AS 产品编号,
dbo.erp_CreateLink(b.title,3,0,b.ord,0,c.uid,21,14) AS 产品名称,
b.type1 AS 型号,
(SELECT TOP 1 sort1 FROM sortonehy b WHERE gate2 = 61 AND b.ord = a.unit) AS 单位,
a.NumMake AS 数量,
dbo.erp_CreateLink(ISNULL((SELECT TOP 1 name FROM gate WHERE ord = a.Cateid_WA), '用户' + CAST(a.Cateid_WA AS varchar(10)) + '【已删】'),2,0,a.Cateid_WA,0,c.uid,0,0) AS 派工人员,
a.DateWA AS 派工时间,
dbo.erp_CreateLink(ISNULL((SELECT TOP 1 name FROM gate WHERE ord = a.creator), '用户' + CAST(a.Creator AS varchar(10)) + '【已删】'),2,0,a.Creator,0,c.uid,0,0) AS 添加人,
a.inDate AS 添加时间
FROM dbo.M_WorkAssigns a
LEFT OUTER JOIN dbo.product b ON a.ProductID = b.ord
full join (select top 1 uid from M_CurUser where ID=@@CONNECTIONS) c on 1=1
WHERE (a.del = 1)

Go

CREATE     VIEW [dbo].[erp_list_wlsq]
AS
SELECT a.ID, MOBH AS 单号,
dbo.erp_CreateLink(a.title,1,a.OrderType+11,a.id,a.Creator,c.uid,57,14) AS 主题,
dbo.erp_CreateLink(isnull(b.title,''),1,8,isnull(b.id,0),isnull(b.Creator,0),c.uid,54,14) AS 对应派工单,
dbo.erp_CreateLink(ISNULL((SELECT TOP 1 name FROM gate WHERE ord = a.creator), '用户' + CAST(a.Creator AS varchar(10)) + '【已删】'),2,0,a.Creator,0,c.uid,0,0) AS 添加人,
a.indate AS 添加时间,
a.intro AS 备注,
a.OrderType
FROM dbo.M_MaterialOrders a
left join M_WorkAssigns b on a.WAID=b.id
full join (select top 1 uid from M_CurUser where ID=@@CONNECTIONS) c on 1=1
WHERE (a.del = 0)

Go

CREATE   VIEW [dbo].[erp_list_scjd]
AS
SELECT a.ID,
a.MPBH AS 进度单号,
dbo.erp_CreateLink(a.title,1,11,a.id,a.Creator,c.uid,55,14) AS 主题,
dbo.erp_CreateLink(isnull(b.title,''),1,8,a.WAID,isnull(b.Creator,0),c.uid,54,14) AS 对应派工单,
a.MPDate AS 汇报日期,
dbo.erp_CreateLink(ISNULL((SELECT TOP 1 name FROM gate WHERE ord = a.creator), '用户' + CAST(a.Creator AS varchar(10)) + '【已删】'),2,0,a.Creator,0,c.uid,0,0) AS 添加人,
a.indate AS 添加时间
FROM dbo.M_MaterialProgres a
left join M_WorkAssigns b on a.WAID=b.id
full join (select top 1 uid from M_CurUser where ID=@@CONNECTIONS) c on 1=1
WHERE (a.del = 0) AND (a.TempSave = 0)

GO

CREATE      VIEW [dbo].[erp_list_gjsz]
AS
SELECT ID,
dbo.erp_CreateLink(title,1,16,a.id,a.Creator,b.uid,60,14) AS 定价主题,
DateBegin AS 生效日期,
DateEnd AS 作废日期,
dbo.erp_CreateLink(ISNULL((SELECT TOP 1 name FROM gate WHERE ord = a.creator), '用户' + CAST(Creator AS varchar(10)) + '【已删】'),2,0,a.Creator,0,b.uid,0,0) AS 添加人,
indate AS 添加时间,
intro AS 备注
FROM dbo.M_PieceRateMain a
full join (select top 1 uid from M_CurUser where ID=isnull(SCOPE_IDENTITY(),0)) b on 1=1
WHERE (del = 0)
GO

CREATE     VIEW [dbo].[erp_list_gylc]
AS
SELECT ID,
WFBH AS 工艺流程代号,
dbo.erp_CreateLink(WFName,1,10,a.id,a.Creator,b.uid,59,14) AS 工艺流程名称, Description AS 说明,
dbo.erp_CreateLink(ISNULL((SELECT TOP 1 name FROM gate WHERE ord = a.creator), '用户' + CAST(Creator AS varchar(10)) + '【已删】'),2,0,a.Creator,0,b.uid,0,0) AS 添加人,
(SELECT COUNT(WFID) FROM M_WFP WHERE WFID = a.id) AS 包含工序数,
intro AS 备注
FROM dbo.M_WorkingFlows a
full join (select top 1 uid from M_CurUser where ID=@@CONNECTIONS) b on 1=1
WHERE (del = 0)

GO

CREATE   VIEW [dbo].[erp_del_list_scjd]
AS
SELECT a.ID,
a.MPBH AS 进度单号,
dbo.erp_CreateLink(a.title,1,11,a.id,a.Creator,c.uid,55,14) AS 主题,
dbo.erp_CreateLink(isnull(b.title,''),1,8,a.WAID,isnull(b.Creator,0),c.uid,54,14) AS 对应派工单,
a.MPDate AS 汇报日期,
dbo.erp_CreateLink(ISNULL((SELECT TOP 1 name FROM gate WHERE ord = a.creator), '用户' + CAST(a.Creator AS varchar(10)) + '【已删】'),2,0,a.Creator,0,c.uid,0,0) AS 添加人,
a.indate AS 添加时间
FROM dbo.M_MaterialProgres a
left join M_WorkAssigns b on a.WAID=b.id
full join (select top 1 uid from M_CurUser where ID=@@CONNECTIONS) c on 1=1
WHERE (a.del = 1)

GO

CREATE     VIEW [dbo].[erp_del_list_scdd]
AS

SELECT a.ID,a.MOBH AS 生产订单,
dbo.erp_CreateLink(a.title,1,2,a.id,a.Creator,b.uid,51,14) AS 主题,
dbo.erp_CreateLink(isnull(c.MPSBH,''),1,3,c.id,c.Creator,b.uid,50,14) AS 生产计划单,
a.DateDelivery AS 需求日期,
a.DateAdvance AS [提前期(天)], DateBegin AS 起始日期, DateEnd AS 截止日期,
dbo.erp_CreateLink(ISNULL((SELECT TOP 1 name FROM gate WHERE ord = a.creator),'用户'+CAST(a.Creator AS varchar(10))+'【已删】'),2,0,a.Creator,0,b.uid,0,0) AS 添加人,
a.indate AS 添加时间,
a.intro AS 备注,
(
case dbo.erp_MaterialOrderComplete(a.id)
when 10 then '已完成（成本已算）'
when 0 then '无入库申请'
when 1 then '部分入库申请'
when 2 then '入库申请完毕,部分入库'
when 3 then '已完成，<a href="###" style="color:red" onclick="window.showdlg(''ProductCosts'',''请确认'',360,240,''a'',''b'','''+cast(a.id as varchar(50))+''')">可计算成本</a>'
end
) as [#Fixed_状态与操作]
FROM dbo.M_ManuOrders a
left join M_ManuPlans c on a.MPSID=c.id
full join (select top 1 uid from M_CurUser where ID=@@CONNECTIONS) b on 1=1
WHERE (a.del = 1)


GO
CREATE   VIEW [dbo].[erp_del_list_gylc]
AS
SELECT ID,
WFBH AS 工艺流程代号,
dbo.erp_CreateLink(WFName,1,10,a.id,a.Creator,b.uid,59,14) AS 工艺流程名称, Description AS 说明,
dbo.erp_CreateLink(ISNULL((SELECT TOP 1 name FROM gate WHERE ord = a.creator), '用户' + CAST(Creator AS varchar(10)) + '【已删】'),2,0,a.Creator,0,b.uid,0,0) AS 添加人,
(SELECT COUNT(WFID) FROM M_WFP WHERE WFID = a.id) AS 包含工序数,
intro AS 备注
FROM dbo.M_WorkingFlows a
full join (select top 1 uid from M_CurUser where ID=@@CONNECTIONS) b on 1=1
WHERE (del = 1)

Go

CREATE     VIEW [dbo].[erp_del_list_gjsz]
AS
SELECT ID,
dbo.erp_CreateLink(title,1,16,a.id,a.Creator,b.uid,60,14) AS 定价主题,
DateBegin AS 生效日期,
DateEnd AS 作废日期,
dbo.erp_CreateLink(ISNULL((SELECT TOP 1 name FROM gate WHERE ord = a.creator), '用户' + CAST(Creator AS varchar(10)) + '【已删】'),2,0,a.Creator,0,b.uid,0,0) AS 添加人,
indate AS 添加时间,
intro AS 备注
FROM dbo.M_PieceRateMain a
full join (select top 1 uid from M_CurUser where ID=@@CONNECTIONS) b on 1=1
WHERE (del = 1)
GO




CREATE   VIEW [dbo].[erp_list_ycd]
AS
SELECT ID, PredictBH AS 预测单号,
dbo.erp_CreateLink(a.title,1,1,a.id,a.Creator,c.uid,52,14) AS 主题,
dbo.IIf(MRP, '是', '否') AS 参与MRP,
dbo.erp_CreateLink(ISNULL((SELECT TOP 1 name FROM gate WHERE ord = a.creator), '用户' + CAST(Creator AS varchar(10)) + '【已删】'),2,0,a.Creator,0,c.uid,0,0) AS 添加人,
inDate AS 添加日期,
intro AS 备注
FROM dbo.M_PredictOrders a
full join (select top 1 uid from M_CurUser where ID=@@CONNECTIONS) c on 1=1
WHERE (del = 0) AND (TempSave = 0)

Go

CREATE    VIEW [dbo].[erp_list_xdd]
AS
SELECT a.ID,
MOIBH AS 下达单号,
dbo.erp_CreateLink(a.title,1,4,a.id,a.Creator,c.uid,53,14) AS 主题,
dbo.erp_CreateLink(isnull(b.title,''),1,2,isnull(b.id,0),isnull(b.Creator,0),c.uid,51,14) AS 生产订单,
dbo.erp_CreateLink(ISNULL((SELECT TOP 1 name FROM gate WHERE ord = a.creator), '用户' + CAST(a.Creator AS varchar(10)) + '【已删】'),2,0,a.Creator,0,c.uid,0,0) AS 添加人,
a.indate AS 添加时间,
a.intro AS 备注
FROM dbo.M_ManuOrderIssueds a
left join M_ManuOrders b on a.MOID=b.id
full join (select top 1 uid from M_CurUser where ID=@@CONNECTIONS) c on 1=1
WHERE (a.del = 0)

Go

CREATE   VIEW [dbo].[erp_del_list_xdd]
AS
SELECT a.ID,
MOIBH AS 下达单号,
dbo.erp_CreateLink(a.title,1,4,a.id,a.Creator,c.uid,53,14) AS 主题,
dbo.erp_CreateLink(isnull(b.title,''),1,2,isnull(b.id,0),isnull(b.Creator,0),c.uid,51,14) AS 生产订单,
dbo.erp_CreateLink(ISNULL((SELECT TOP 1 name FROM gate WHERE ord = a.creator), '用户' + CAST(a.Creator AS varchar(10)) + '【已删】'),2,0,a.Creator,0,c.uid,0,0) AS 添加人,
a.indate AS 添加时间,
a.intro AS 备注
FROM dbo.M_ManuOrderIssueds a
left join M_ManuOrders b on a.MOID=b.id
full join (select top 1 uid from M_CurUser where ID=@@CONNECTIONS) c on 1=1
WHERE (a.del = 1)

GO

CREATE   VIEW [dbo].[erp_del_list_wlsq]
AS
SELECT a.ID, MOBH AS 单号,
dbo.erp_CreateLink(a.title,1,a.OrderType+11,a.id,a.Creator,c.uid,57,14) AS 主题,
dbo.erp_CreateLink(isnull(b.title,''),1,8,isnull(b.id,0),isnull(b.Creator,0),c.uid,54,14) AS 对应派工单,
dbo.erp_CreateLink(ISNULL((SELECT TOP 1 name FROM gate WHERE ord = a.creator), '用户' + CAST(a.Creator AS varchar(10)) + '【已删】'),2,0,a.Creator,0,c.uid,0,0) AS 添加人,
a.indate AS 添加时间,
a.intro AS 备注,
a.OrderType
FROM dbo.M_MaterialOrders a
left join M_WorkAssigns b on a.WAID=b.id
full join (select top 1 uid from M_CurUser where ID=@@CONNECTIONS) c on 1=1
WHERE (a.del = 1)

GO

CREATE   VIEW [dbo].[erp_del_list_ycd]
AS
SELECT ID, PredictBH AS 预测单号,
dbo.erp_CreateLink(a.title,1,1,a.id,a.Creator,c.uid,52,14) AS 主题,
dbo.IIf(MRP, '是', '否') AS 参与MRP,
dbo.erp_CreateLink(ISNULL((SELECT TOP 1 name FROM gate WHERE ord = a.creator), '用户' + CAST(Creator AS varchar(10)) + '【已删】'),2,0,a.Creator,0,c.uid,0,0) AS 添加人,
inDate AS 添加日期,
intro AS 备注
FROM dbo.M_PredictOrders a
full join (select top 1 uid from M_CurUser where ID=@@CONNECTIONS) c on 1=1
WHERE del=1

GO

CREATE VIEW [dbo].[erp_del_list_gzzx]
AS
SELECT ID, WCBH AS 工作中心代号,
dbo.erp_CreateLink(WCName,1,7,a.id,a.Creator,b.uid,59,14) AS 工作中心名称,
      Department AS 所属部门, intro AS 备注
FROM dbo.M_WorkingCenters a
full join (select top 1 uid from M_CurUser where ID=@@CONNECTIONS) b on 1=1
WHERE del=1

GO

create view [dbo].[view_TaxClassifyCodes]
as
SELECT id as NodeId,GoodsName as NodeText,0 as NodeDeep,0 as pid FROM [TaxClassifyCodes]
WHERE P>0 AND L=0 
union all
SELECT a.ID as NodeId, a.GoodsName as NodeText,1 as NodeDeep, 
(SELECT TOP 1 ID FROM TaxClassifyCodes b WHERE a.P=b.P and b.L=0 and b.Z=0 and b.J=0 and b.T=0 and b.K=0 and b.X=0 and b.M=0 
and b.ZM=0 and b.XM=0)
as pid FROM [TaxClassifyCodes] a
WHERE a.P> 0 AND a.L>0 and a.Z=0
union all
SELECT a.ID as NodeId, a.GoodsName as NodeText,2 as NodeDeep, 
(SELECT TOP 1 ID FROM TaxClassifyCodes b WHERE a.P=b.P and a.L=B.L and b.Z=0 and b.J=0 and b.T=0 and b.K=0 and b.X=0 and b.M=0 
and b.ZM=0 and b.XM=0)
as pid FROM [TaxClassifyCodes] a
WHERE a.P> 0 AND a.L>0 and a.Z>0 and a.J=0 
union all
SELECT a.ID as NodeId, a.GoodsName as NodeText,3 as NodeDeep, 
(SELECT TOP 1 ID FROM TaxClassifyCodes b WHERE a.P=b.P and a.L=B.L and a.Z=b.Z and b.J=0 and b.T=0 and b.K=0 and b.X=0 and b.M=0 
and b.ZM=0 and b.XM=0)
as pid FROM [TaxClassifyCodes] a
WHERE a.P> 0 AND a.L>0 and a.Z>0 and a.J>0 and a.T=0
union all
SELECT a.ID as NodeId, a.GoodsName as NodeText,4 as NodeDeep, 
(SELECT TOP 1 ID FROM TaxClassifyCodes b WHERE a.P=b.P and a.L=B.L and a.Z=b.Z  and b.J=a.J and b.T=0 and b.K=0 and b.X=0 and b.M=0 
and b.ZM=0 and b.XM=0)
as pid FROM [TaxClassifyCodes] a
WHERE a.P> 0 AND a.L>0 and a.Z>0 and a.J>0 and a.T>0 AND A.K=0
union all
SELECT a.ID as NodeId, a.GoodsName as NodeText,5 as NodeDeep, 
(SELECT TOP 1 ID FROM TaxClassifyCodes b WHERE a.P=b.P and a.L=B.L and a.Z=b.Z and b.J=a.J and b.T=a.T and b.K=0 and b.X=0 and b.M=0 
and b.ZM=0 and b.XM=0)
as pid FROM [TaxClassifyCodes] a
WHERE a.P> 0 AND a.L>0 and a.Z>0 and a.J>0 and a.T>0 AND A.K>0 AND A.X=0
union all
SELECT a.ID as NodeId, a.GoodsName as NodeText,6 as NodeDeep, 
(SELECT TOP 1 ID FROM TaxClassifyCodes b WHERE a.P=b.P and a.L=B.L and a.Z=b.Z and b.J=a.J and b.T=a.T and b.K=a.K and b.X=0 and b.M=0 
and b.ZM=0 and b.XM=0)
as pid FROM [TaxClassifyCodes] a
WHERE a.P> 0 AND a.L>0 and a.Z>0 and a.J>0 and a.T>0 AND A.K>0 AND A.X>0 AND A.M=0
union all
SELECT a.ID as NodeId, a.GoodsName as NodeText,7 as NodeDeep, 
(SELECT TOP 1 ID FROM TaxClassifyCodes b WHERE a.P=b.P and a.L=B.L and a.Z=b.Z and a.J=b.J and b.T=a.T and b.K=a.K and b.X=a.X and b.M=0 
and b.ZM=0 and b.XM=0)
as pid FROM [TaxClassifyCodes] a
WHERE a.P> 0 AND a.L>0 and a.Z>0 and a.J>0 and a.T>0 AND A.K>0 AND A.X>0 AND A.M>0 AND A.ZM=0
union all
SELECT a.ID as NodeId, a.GoodsName as NodeText,8 as NodeDeep, 
(SELECT TOP 1 ID FROM TaxClassifyCodes b WHERE a.P=b.P and a.L=B.L and a.Z=b.Z and  a.J=b.J and b.T=a.T and b.K=a.K and b.X=a.X and b.M=a.M
and b.ZM=0 and b.XM=0)
as pid FROM [TaxClassifyCodes] a
WHERE a.P> 0 AND a.L>0 and a.Z>0 and a.J>0 and a.T>0 AND A.K>0 AND A.X>0 AND A.M>0 AND A.ZM>0 AND A.XM=0
union all
SELECT a.ID as NodeId, a.GoodsName as NodeText,9 as NodeDeep, 
(SELECT TOP 1 ID FROM TaxClassifyCodes b WHERE a.P=b.P and a.L=B.L and a.Z=b.Z and a.J=b.J and b.T=a.T and b.K=a.K and b.X=a.X and b.M=a.M
and b.ZM=a.ZM and b.XM=0)
as pid FROM [TaxClassifyCodes] a
WHERE a.P> 0 AND a.L>0 and a.Z>0 and a.J>0 and a.T>0 AND A.K>0 AND A.X>0 AND A.M>0 AND A.ZM>0 AND A.XM>0

GO

CREATE    VIEW [dbo].[erp_list_gzzx]
AS
SELECT ID, WCBH AS 工作中心代号,
dbo.erp_CreateLink(WCName,1,7,a.id,a.Creator,b.uid,59,14) AS 工作中心名称,
      Department AS 所属部门, intro AS 备注
FROM dbo.M_WorkingCenters a
full join (select top 1 uid from M_CurUser where ID=@@CONNECTIONS) b on 1=1
WHERE (del = 0) AND (TempSave = 0)

GO
CREATE   VIEW [dbo].[erp_del_list_gx]
AS
SELECT ID,
dbo.erp_CreateLink(WPName,1,9,a.id,a.Creator,b.uid,59,14)
AS 工序名称, Description AS 工序描述, WPOrder AS 次序,
      dbo.IIf(ABS(SIGN(TimeUnit - 1)), dbo.IIf(ABS(SIGN(TimeUnit - 2)), '分', '小时'), '天')
      AS 计时单位, TimeQueue AS 排队时间, TimeStandard AS 标准工时,
      TimePrepare AS 准备时间, MakeNum AS 制作批量, ManHour AS 搬运工时,
      dbo.IIf(ReplaceFlag, '能', '否') AS 能否替代, ReplaceID AS 可替代工序编号
FROM dbo.M_WorkingProcedures a
full join (select top 1 uid from M_CurUser where ID=@@CONNECTIONS) b on 1=1
where del=1

Go

CREATE  VIEW [dbo].[erp_list_gx]
AS
SELECT ID,
dbo.erp_CreateLink(WPName,1,9,a.id,a.Creator,b.uid,59,14)
AS 工序名称, Description AS 工序描述, WPOrder AS 次序,
      dbo.IIf(ABS(SIGN(TimeUnit - 1)), dbo.IIf(ABS(SIGN(TimeUnit - 2)), '分', '小时'), '天')
      AS 计时单位, TimeQueue AS 排队时间, TimeStandard AS 标准工时,
      TimePrepare AS 准备时间, MakeNum AS 制作批量, ManHour AS 搬运工时,
      dbo.IIf(ReplaceFlag, '能', '否') AS 能否替代, ReplaceID AS 可替代工序编号
FROM dbo.M_WorkingProcedures a
full join (select top 1 uid from M_CurUser where ID=@@CONNECTIONS) b on 1=1
where del = 0

GO

CREATE View [dbo].[home_leftMenu_view]
as
select * from home_leftMenu

GO

CREATE  view [dbo].[erp_rpt_kuinlist]
as
select ku as ck, a.id, convert(decimal(25,12),ROUND(REPLACE(a.price1,',',''),8))*(a.num1-isnull(b.num1,0)) as money1, a.[dateadd],a.del, a.unit, a.ord,(a.num1-isnull(b.num1,0)) as num1,a.kuin,a.sort1 from kuinlist a
left join (
	select sum(num1) as num1 ,kuinlist from kuhclist b group by kuinlist
) b on a.id = b.kuinlist
where a.del=1 or a.del=99
union all
select ku as ck, kuid, b.price1*a.num1 as money1, a.[indate] as [dateadd], a.del, b.unit, a.ord, a.num1,  kuin, -1 from kuhclist a inner join kuinlist b on a.kuinlist= b.id

GO

CREATE  view [dbo].[gate_person]
as
	select *,  0 as nowStatus,  
	cast(NULL as datetime ) as  contractstart , 
	cast(NULL as datetime ) as  contractend  
from gate

GO

CREATE view [dbo].PayCaigouProxy 
as 
select ord, title,cgid, company,bz, money1,date3, 0 as cls,cateid  from caigou where del=1
union all
select ID, title,sn, gys, 14 bz,(select sum(money1) from M_OutOrderlists where outID=M_outorder.id) money1,odate, 2,isnull(creator,0) from M_OutOrder where del=0
union all
select ID, title,sn, gys, bz,money1 ,odate, (CASE isnull(wwType,0) WHEN 0 then 5 ELSE 4 END),isnull(ourperson,creator) from M2_OutOrder where del=1

GO

CREATE view [dbo].[PayoutPayInv]
as
	select ord,tik, tikname, money1, IsUsePJLY , date3, date7 , 0 as addcate, cls, contract,cateid,del,date3 as date1,1 as t from payout 
	where complete2=3 and not exists (select 1 from dbo.payinvoicelist where zt=1 and del=1 and payout=payout.ord)
	union all
	select c.payout,a.tik, a.tikname, c.money1,a.IsUsePJLY , a.date3, a.date7 , a.addcate, c.cls, c.sourceID, b.cateid,1,c.date1, 2 as t
	from dbo.PayInvoiceList c 
	inner join dbo.PayInvoice a on a.ord=c.PayInvoice 
	inner join caigou b  on  c.sourceID = b.ord and c.cls = 0
	union all
	select c.payout,a.tik, a.tikname, c.money1,a.IsUsePJLY , a.date3, a.date7 , a.addcate, c.cls, c.sourceID, b.fzr,1,c.date1, 2 as t
	from dbo.PayInvoiceList c 
	inner join dbo.PayInvoice a on a.ord=c.PayInvoice 
	inner join M_outorder b  on  c.sourceID = b.ID and c.cls =2

GO

CREATE VIEW [dbo].[V_QrCodeTemplateData]
AS
SELECT  id AS 'Qr_Code_ID',  --ID
id AS 'Qr_url_Code'  --二维码标识
FROM    C2_CodeItems

GO

CREATE VIEW [dbo].[V_getcurrenttime]
AS
select GETDATE() as 'currentDate'

GO

CREATE VIEW [dbo].[V_HrKQ_GetComplaintData]
AS 
    SELECT  haa.ID ,
    haa.UserID,
    ugt.name AS UserName,
            haa.CreateDate ,
            CONVERT(VARCHAR(10), [Day], 120) AS Daytxt ,
            [Week] ,
            ShouldTime ,
            hat.Title AS Reason,
            haa.Reason AS ReasonID,
            haa.[Address] ,
            '电脑' AS Device,
            haa.Content ,
		    CASE WHEN (haa.FirstTime = '1900-01-01 0:00:00' OR haa.FirstTime IS NULL) THEN '未签到' ELSE CONVERT(VARCHAR(100),haa.FirstTime,20) END AS FirstTime,
            CASE WHEN (haa.LastTime = '1900-01-01 0:00:00' OR haa.FirstTime IS NULL) THEN '未签退' ELSE CONVERT(VARCHAR(100),haa.LastTime,20) END AS LastTime,
            hat2.Title AS Result,
            haa.Result AS ResultID,
            gt.name ,
            haa.TreatmentStatus,
            CASE haa.TreatmentStatus
              WHEN 1 THEN '已处理'
              ELSE '未处理'
            END AS StatusTxt,
            CASE haa.TreatmentStatus
              WHEN 1 THEN '修改'
              ELSE '处理'
            END AS btnValue,
            haa.DisposeUser,
            haa.DisposeRemark,
            haa.DisposeDate
    FROM    dbo.HrKQ_AttendanceAppeal haa
    LEFT JOIN dbo.HrKQ_AttendanceType hat ON haa.Reason = hat.OnlyID
    LEFT JOIN dbo.HrKQ_AttendanceType hat2 ON haa.Result = hat2.OnlyID
    LEFT JOIN dbo.gate ugt ON haa.UserID = ugt.ord
    LEFT JOIN dbo.gate gt ON haa.DisposeUser = gt.ord
    where haa.TreatmentStatus <> 2
GO

CREATE VIEW [dbo].[erp_v_bom_getbomlist]
AS
SELECT * FROM dbo.M2_BOMList WHERE ParentID > 0 OR ParentID = -1

GO

CREATE VIEW [dbo].[ErpUnits] 
as 
select 
a.ord, a.sort1, a.gate1, 
b.unitgp, b.main, b.bl ,  a.isStop as stoped
from sortonehy  a 
left join erp_comm_unitInfo b on 
a.ord=b.unitid 
where a.gate2=61 

GO


CREATE VIEW [dbo].[M2_CXProcedureView]
as  
select * from M2_WorkingPD where dataType = 0 

GO

CREATE VIEW [dbo].[M2_CXStationView]
as  
select * from M2_WorkingPD where dataType = 1 

GO

CREATE VIEW [dbo].[Nl_IndextbView]
as 
select --日历流水视图    
 AutoI,    
 yl as AutoT,     
 AutoT2    
from nldata 

GO

CREATE VIEW [dbo].[M2_MachineTainListView]
as    
select 
	t.MHLID,
	t.d1,
	(case Unit2 
		when 5 then DATEADD(S,num2, d1)
		when 0 then DATEADD(N,num2, d1)
		when 1 then DATEADD(HH,num2, d1)
		when 2 then DATEADD(D,num2, d1)
		when 3 then DATEADD(M,num2, d1)
		when 4 then DATEADD(YY,num2, d1)
		else  DATEADD(D,num2, d1) 
	end) as d2
from (
	select 
	b.MHLID,
	a.autoT +(b.date1 - CAST(b.date1 as int) + 1 ) as D1, 
	b.Unit2, 
	dbo.MinV(
		case Unit2
		when 4 then 100
		when 3 then 100*12
		when 2 then 100*365
		when 1 then 100*365*24
		else 100*365*24*60 end
	,num2)as num2
	from Nl_IndextbView a
	inner join M2_maintain b --on b.id=14
	on datediff(d, b.date1, a.AutoT)%b.num2=0 and datediff(d, b.date1, a.AutoT)>=0
) t

GO

CREATE VIEW [dbo].[erp_comm_unitRelation]
as
	select distinct p.ord  , isnull(s.ord,p.unitjb) as unit , isnull(j.bl,1) as bl , 
		(CASe when isnull(s.ord,p.unitjb) = p.unitjb then 1 else 0 end) as isDefault  , 
		(CASE ISNULL(c.nvalue,0) WHEN 0 THEN 0 else ISNULL(j2.cgMainUnit,0) END) as isBuyUnit , 
		ISNULL(j2.xlhManage,0) as isXlh
	from product p with(nolock) 
	inner join jiage j  with(nolock) on abs(j.product) = p.ord AND j.bm = 0 
	left join sortonehy s  with(nolock) on s.gate2 = 61 and j.unit = s.ord
	LEFT JOIN (
		SELECT abs(product) product, unit, MAX(ISNULL(cgMainUnit,0)) cgMainUnit, MAX(ISNULL(xlhManage,0)) xlhManage FROM jiage  with(nolock) WHERE bm=0 GROUP BY abs(product), unit
	) j2 ON j2.product = p.ord and j2.unit = s.ord
	LEFT JOIN home_usConfig c  with(nolock) ON c.name='CGMainUnitTactics' and isnull(c.uid, 0) =0

GO

CREATE VIEW [dbo].[V_RepairOrderList]
AS
(
	SELECT ro.id roid,sl.* FROM dbo.repair_sl_list sl
	INNER JOIN dbo.RepairOrder ro ON ro.repair_sl_list = sl.id
)

GO

CREATE view [dbo].[erp_M2_APSManOrderStatus]
as 
select 
	AASID ,   
	(case  when r2=0 then 0
	when r1>r2 then 1 
	when r1<=r2 then 2
	else 0 end ) as ManOrderStatus		
from (
	select 
			t1.AASID ,  COUNT(1) as r1 ,    isnull(SUM(sign(t2.ID)),0)  as r2
	 from (
		SELECT MIN(aal.ID) AsListID,aal.AASID 
		FROM dbo.M2_AbilityAnalysis aa
		INNER JOIN dbo.M2_AbilityAnalysisList aal ON aa.ID = aal.AASID AND aal.del = 1 AND aal.dataType <> 2
		INNER JOIN dbo.M2_MaterialAnalysisList mal ON mal.ID = aal.listID AND mal.RankCode = 0 AND mal.del = 1
		and (aal.FPID is not NULL OR NOT EXISTS(
			SELECT 1 FROM M2_AbilityAnalysisList x 
			WHERE x.AASID=aal.AASID 
			AND x.listID=aal.listID 
			AND x.FPID is not NULL 
		))
		WHERE aa.del = 1 AND aal.num1>0
		GROUP BY aal.listID,aal.AASID
	) t1 
	left join M2_ManuOrderLists t2  on t1.AsListID= t2.AASLID  and t2.del=1
	group by t1.AASID
) t

GO
Create VIEW [dbo].[ManuOrderListWaRkInfo]
AS
	select M2WA.MOrderID,M2WA.ddlistid
	,SUM(isnull(kuin.num2,0)) as kuinnum
	,(case when SUM(isnull(kuin.num2,0)) = 0 then 0  
		when SUM(isnull(kuin.num2,0))> 0 and SUM(isnull(kuin.num2,0)) < max(ISNULL(mol2.Num,0)) then  1  
		when SUM(isnull(kuin.num2,0)) = max(ISNULL(mol2.Num,0)) and SUM(isnull(kuin.num2,0)) > 0 then  2  
		when SUM(isnull(kuin.num2,0)) > max(ISNULL(mol2.Num,0)) then 3  end) rkstatus
	,MAX(k.date5) date5
	from kuinlist kuin
	INNER JOIN dbo.kuin k ON kuin.kuin = k.ord
	inner join dbo.M2_WorkAssigns M2WA on M2WA.ID=kuin.M2_WAID
	inner join dbo.M2_ManuOrderLists mol2 on M2WA.ddlistid=mol2.ID and M2WA.MOrderID=mol2.MOrderID
	where kuin.del = 1 and kuin.sort1 in (5,13,14,15) 
	group by M2WA.MOrderID,M2WA.ddlistid
GO
CREATE VIEW [dbo].[M2_ManuOrdersListExt]
AS
	SELECT mol.MOrderID as ID ,mol.id as ListID,isnull(mo.[Route],0) as [Route],
		sum(ISNULL(qtkuin.kuinnum,0)+ISNULL(qtkuin2.kuinnum,0)) as RkNum, 
		(CASE WHEN ISNULL(mol.IsMerge,0) = 0 THEN 1 ELSE 0 END) needRK,
		(CASE WHEN ISNULL(mol.IsMerge,0) = 1 THEN 0 ELSE (CASE WHEN sum(ISNULL(qtkuin.kuinnum,0)+ISNULL(qtkuin2.kuinnum,0)) = 0 and isnull(mol.Num,0)>0 THEN 1 else 0 end) END) as UnRK ,
		(CASE WHEN ISNULL(mol.IsMerge,0) = 1 THEN 0 ELSE (CASE WHEN isnull(mol.Num,0)-sum(ISNULL(qtkuin.kuinnum,0)+ISNULL(qtkuin2.kuinnum,0))> 0 and sum(ISNULL(qtkuin.kuinnum,0)+ISNULL(qtkuin2.kuinnum,0))>0 THEN 1 else 0 end) END) as PartRK ,
		(CASE WHEN ISNULL(mol.IsMerge,0) = 1 THEN 0 ELSE (CASE WHEN isnull(mol.Num,0)-sum(ISNULL(qtkuin.kuinnum,0)+ISNULL(qtkuin2.kuinnum,0))= 0 THEN 1 else 0 end) END) as CompleteRK ,
		(CASE WHEN ISNULL(mol.IsMerge,0) = 1 THEN 0 ELSE (CASE WHEN isnull(mol.Num,0)-sum(ISNULL(qtkuin.kuinnum,0)+ISNULL(qtkuin2.kuinnum,0))< 0 THEN 1 else 0 end) END) as PassRK
	FROM dbo.M2_ManuOrderLists mol
	inner join M2_ManuOrders mo	on mo.ID = 	mol.MOrderID 
	LEFT JOIN dbo.M2_OutOrderlists ool ON ool.molist = mol.ID AND ool.del = 1
	LEFT JOIN (
		 select M2QT.ddno , M2QT.poType , M2QTL.bid as listID,SUM(kuin.num2) as kuinnum
		 from kuinlist kuin
		 INNER JOIN M2_QualityTestingLists M2QTL on case when isnull(kuin.M2_QTLID,0)=0 then kuin.M2_BFID else kuin.M2_QTLID end= M2QTL.ID and kuin.del = 1     
		 INNER JOIN M2_QualityTestings M2QT on M2QTL.QTID = M2QT.ID and M2QT.del = 1    
		 WHERE kuin.del = 1 and M2QT.poType=1
		 group by M2QT.ddno,M2QT.poType , M2QTL.bid
	) qtkuin ON qtkuin.poType = 1  and qtkuin.listID =ool.id
	LEFT JOIN dbo.ManuOrderListWaRkInfo qtkuin2 ON mol.MOrderID = qtkuin2.MOrderID and qtkuin2.ddlistid =mol.ID
	where mol.del=1 AND mol.Num > 0
	GROUP BY mol.MOrderID,isnull(mo.[Route],0),mol.id, mol.Num,ISNULL(mol.IsMerge,0)
		
GO

CREATE VIEW [dbo].[M2_ManuOrdersExt]
as
    select  rklist.ID , rklist.[Route] ,
		(CASE WHEN SUM(rklist.needRK) = 0 THEN -1 --无需入库
			 when SUM(rklist.needRK)=sum(UnRK) then 0  --全部明显未入库（未入库）
			 when sum(UnRK) + sum(PartRK)>0 then 1 --存在未入库或部分入库 （部分入库）
			 when SUM(rklist.needRK)=sum(CompleteRK) then 2 --全部明显入库（入库完毕）
			 else 3 end ) kuinstatus,
			 SUM(rklist.RkNum) RkNum
	from (
		SELECT * FROM [dbo].[M2_ManuOrdersListExt]
	) as rklist
	group by rklist.ID , rklist.[Route]


GO

CREATE function [dbo].[erp_Bill_QualityTestLogic]()
returns table
AS
return
(        
		select  
				x.ID as QTID ,  y.PID,   x.QTDate, 
				y.SerialNumber,  y.certNum,  y.NumBF,  y.NumScrap,  
				x.QTResultAll as QTResult,  
				isnull(x.CkStatus,0) as CkStatus,    
				(case x.poType when 1 then 54003 when 2   
				then 54006 when 3  then 54002 when 4  then 54005 else 0 end  ) billType  
		from  M2_QualityTestings x
		inner join (
			select 
				mq.ID QTID,
				mqt.bid PID,
				isnull(sum(mqt.SerialNumber),0) SerialNumber,  
				isnull(sum(
					case 
					when mq.QTResultAll = 0 and (mq.poType not in(3,4) or isnull(mq.QTMode,0)=1) then mqt.SerialNumber
					else 
						case isnull(mq.CkStatus,0)
						when 0 then (mqt.SerialNumber -  isnull(mqt.NumBF,0) -  isnull(mqt.NumScrap,0) ) 
						when 1 then mqt.SerialNumber
						when 2 then  0
						when 3 then  0 
						else  (mqt.SerialNumber -  isnull(mqt.NumBF,0) -  isnull(mqt.NumScrap,0) )
						end
					end
				),0) certNum,                                                                                                                                       
				isnull(sum(
					case 
					when mq.QTResultAll = 0 and (mq.poType not in(3,4) or isnull(mq.QTMode,0)=1) then 0
					else 
						case isnull(mq.CkStatus,0)
						when 0 then mqt.NumBF 
						when 1 then 0
						when 2 then 0
						when 3 then mqt.SerialNumber
						when 4 then mqt.NumBF
						else mqt.NumBF
						end
					end
				),0)  NumBF,                                      
				isnull(sum(
					case 
					when mq.QTResultAll = 0 and (mq.poType not in(3,4) or isnull(mq.QTMode,0)=1) then 0
					else 
						case isnull(mq.CkStatus,0)
						when 0 then mqt.NumScrap 
						when 1 then 0
						when 2 then mqt.SerialNumber
						when 3 then 0
						when 4 then mqt.NumScrap
						else 0 end
					end
				),0)  NumScrap    
			from M2_QualityTestingLists mqt                                  
			inner join M2_QualityTestings mq on mq.ID = mqt.QTID                                                                                                
			where mqt.del=1 and mq.del=1                                                     
			group by mq.ID, mqt.bid
		) y on x.ID= y.QTID
		where x.QTResultAll=0  or x.CkStatus>0   --QTResultAll=1 and CkStatus=0 表示待审核， 这种数据不需要查询出来
    )

GO

CREATE VIEW [dbo].[erp_ProcedureProgresNums]
AS
select *,
		(case 
			when (pgsl-hgsl-bfsl) >= 0 
			then (pgsl-hgsl-bfsl)
			else 0 
		end) as sysl,--剩余数量
		case isOut
			when 1 
			then (--委外的状态
					case
						when hgsl > 0 and pgsl>hgsl
						then 1	--部分完成
						when hgsl >= pgsl 
						then 2	--委外完毕
						else 0	--未完成
					end)
			else (--未委外的执行状态
				case
					when hgsl+bfsl > 0 and pgsl>(hgsl+bfsl)
					then 1	--部分执行
					when hgsl > 0 and pgsl = (hgsl+bfsl) 
					then 2	--执行完毕
					when hgsl+bfsl>pgsl
					then 3	--超量执行(hgsl+bfsl>pgsl)
					else 0	--未执行
				end) 
		end as execStatus,
		case isOut
			when 1 
			then (--委外的状态
					case
						when hgsl > 0 and pgsl>hgsl
						then '部分完成'
						when hgsl >= pgsl 
						then '委外完毕'
						else '未完成'
					end)
			else (--未委外的执行状态
				case
					when hgsl+bfsl > 0 and pgsl>(hgsl+bfsl)
					then '部分执行'
					when hgsl > 0 and pgsl = (hgsl+bfsl) 
					then '执行完毕'
					when hgsl+bfsl>pgsl
					then '超量执行'
					else '未执行'
				end) 
		end as execStatus_tit
from(
	/*工序自制加工合格、返工、报废数量*/
	select 
		x.ID as WFPAID,																--M2_WFP_Assigns.ID
		isnull(x.isOut,0) as isOut,													--是否委外
		isnull(x.NumMake,0) as pgsl,												--派工数量
		isnull(sum((case when y.result IN (1) then isnull(num1,0) else 0 end)),0) as hgsl,	--合格数量
		isnull(sum((case when y.result IN (2) then isnull(num1,0) else 0 end)),0) as fgsl,		--返工数量
		isnull(sum((case when y.result IN (3) then isnull(num1,0) else 0 end)),0) as bfsl,		--报废数量
		isnull(MIN(inDate),'') startDate,														--实际开始时间
		isnull(MAX(inDate),'') endDate															--实际结束时间
	from dbo.M2_WFP_Assigns as x 
	left join dbo.M2_ProcedureProgres as y on y.WFPAID = x.ID
	where (x.del = 1) and (y.del = 1) and (isnull(CheckResult,0) <> 1) and isnull(x.isOut,0) = 0  AND (ISNULL(y.needCheck,0) = 0 OR y.CheckResult IN(0,2))
	group by x.ID,x.NumMake,x.isOut
	union all
	/*工序委外加工合格、返工、报废数量*/
	select 
		x.ID as WFPAID,
		isnull(x.isOut,0) as isOut,
		ISNULL(x.NumMake,0) as pgsl,
		SUM(ISNULL(certNum,0)) as hgsl,
		SUM(ISNULL(NumScrap,0)) as fgsl,
		SUM(ISNULL(NumBF,0)) as bfsl,
		convert(varchar(10),isnull(MIN(z.QTDate),''),120) startDate,														--实际开始时间
		convert(varchar(10),isnull(MAX(z.QTDate),''),120) endDate														--实际结束时间
	from M2_WFP_Assigns x
	inner join M2_OutOrderlists y on x.ID = y.WFPAID and y.del = 1
	left join erp_Bill_QualityTestLogic() z on z.billType = 54006 and z.PID = y.ID
	where isnull(x.isOut,1) = 1 and x.del = 1
	group by x.ID,x.NumMake,x.isOut) t
go

CREATE view  [dbo].[erp_WorkAssignsWFPWWNumInfoView]  
as  
 select * from (  
  select per.NodeID as WW_WFPAID, cast(SUM(per.ExecedNum + per.CanExecNum) as decimal)  PreHgNumByCheck     
         from dbo.M2_ProcessExecution_Result per with(nolock)   
         left join home_usConfig cf with(nolock)  on cf.name = 'ProcessOutStrategy' and cf.uid=0    
         where ISNULL(cf.nvalue,1)=2 and per.ProcIndex!=1 and per.NodeType=1     
         group by per.NodeID    
         union     
      select   distinct  per.NodeID,  
      (select top 1  M2WFPA.NumMake  NumMake from M2_WFP_Assigns M2WFPA    
   where   per.NodeID=M2WFPA.ID  and per.WAID=M2WFPA.WAID )  
   *(isnull((100+isnull(cfg.nvalue,0))/100,1))   
         from dbo.M2_ProcessExecution_Result per with(nolock)   
          left join  home_usConfig cfg  on cfg.name='GXHBOverReportingValue'    
         where per.ProcIndex=1 and per.NodeType=1     
  
)t  
  
go
     
--工序委外变更自制时 已加工数量取值工序委外数量 不取工序委外质检数量      
CREATE VIEW [dbo].[erp_ProcedureProgresNums2]      
AS      
select t.*,     
  (case       
   when (isnull(ww.PreHgNumByCheck,pgsl)-hgsl-bfsl-isnull(kdFgsl,0)) >= 0       
   then (isnull(ww.PreHgNumByCheck,pgsl)-hgsl-bfsl-isnull(kdFgsl,0))      
   else 0       
  end) as sysl,--剩余数量      
  case isOut      
   when 1       
   then (--委外的状态      
     case      
      when hgsl > 0 and isnull(ww.PreHgNumByCheck,pgsl)>hgsl      
      then 1 --部分完成      
      when  hgsl >= isnull(ww.PreHgNumByCheck,pgsl)       
      then 2 --委外完毕      
      else 0 --未完成      
     end)     
   else (--未委外的执行状态      
    case      
     when (hgsl+bfsl+isnull(kdFgsl,0)) > 0 and isnull(ww.PreHgNumByCheck,pgsl)>(hgsl+bfsl+isnull(kdFgsl,0)) and dbo.EqualsNumberBit((hgsl+bfsl+ISNULL(kdFgsl,0)),isnull(ww.PreHgNumByCheck,pgsl),(SELECT top 1 num1 FROM setjm3 WHERE ord=88))=0       
     then 1 --部分执行      
     when dbo.EqualsNumberBit((hgsl+bfsl+ISNULL(kdFgsl,0)),isnull(ww.PreHgNumByCheck,pgsl),(select top 1 num1 from setjm3 where ord=88))=1       
     then 2 --执行完毕      
     when (hgsl+bfsl+isnull(kdFgsl,0))>isnull(ww.PreHgNumByCheck,pgsl) and dbo.EqualsNumberBit((hgsl+bfsl+ISNULL(kdFgsl,0)),isnull(ww.PreHgNumByCheck,pgsl),(SELECT top 1 num1 FROM setjm3 WHERE ord=88))=0       
     then 3 --超量执行      
     else 0 --未执行      
    end)       
  end as execStatus,      
  case isOut      
   when 1       
   then (--委外的状态      
     case      
      when hgsl > 0 and (pgsl>hgsl or pgsl >isnull(ww.PreHgNumByCheck,pgsl))  
      then '部分完成'      
      when  hgsl=pgsl       
      then '委外完毕'     
      when  hgsl >=isnull(ww.PreHgNumByCheck,pgsl)    
      then '超量委外'    
      else '未完成'      
     end)      
   else (--未委外的执行状态      
    case      
     when (hgsl+bfsl+isnull(kdFgsl,0)) > 0 and isnull(ww.PreHgNumByCheck,pgsl)>(hgsl+bfsl+isnull(kdFgsl,0)) and dbo.EqualsNumberBit((hgsl+bfsl+ISNULL(kdFgsl,0)),isnull(ww.PreHgNumByCheck,pgsl),(SELECT top 1 num1 FROM setjm3 WHERE ord=88))=0       
     then '部分执行'      
     when dbo.EqualsNumberBit((hgsl+bfsl+ISNULL(kdFgsl,0)),isnull(ww.PreHgNumByCheck,pgsl),(select top 1 num1 from setjm3 where ord=88))=1      
     then '执行完毕'      
     when (hgsl+bfsl+isnull(kdFgsl,0))>isnull(ww.PreHgNumByCheck,pgsl) and dbo.EqualsNumberBit((hgsl+bfsl+ISNULL(kdFgsl,0)),isnull(ww.PreHgNumByCheck,pgsl),    
     (SELECT top 1 num1 FROM setjm3 WHERE ord=88))=0       
     then '超量执行'      
     else '未执行'      
    end)       
  end as execStatus_tit      
from(      
 /*工序自制加工合格、返工、报废数量*/      
 select       
  x.ID as WFPAID,                --M2_WFP_Assigns.ID      
  isnull(x.isOut,0) as isOut,             --是否委外      
  ISNULL(x.NumMake,0) as pgsl,            --派工数量      
  isnull(sum((case when y.result IN (1) then isnull(num1,0) WHEN y.result = 2 AND ISNULL(y.ReworkMode,1) = 1 THEN isnull(num1,0) else 0 end)),0) as hgsl, --合格数量      
  isnull(sum((case when y.result IN (2) then isnull(num1,0) else 0 end)),0) as fgsl,  --返工数量      
  isnull(sum((case when y.result IN (2) AND y.ReworkMode = 2 then isnull(num1,0) else 0 end)),0) as kdFgsl,  --返工数量      
  isnull(sum((case when y.result IN (3) then isnull(num1,0) else 0 end)),0) as bfsl,  --报废数量      
  isnull(MIN(inDate),'') startDate,              --实际开始时间      
  isnull(MAX(inDate),'') endDate               --实际结束时间      
 from dbo.M2_WFP_Assigns as x       
 left join dbo.M2_ProcedureProgres as y on y.WFPAID = x.ID      
 where (x.del = 1) and (y.del = 1) and (isnull(y.NeedCheck,0) = 0 or isnull(CheckResult,0) = 0 or isnull(CheckResult,0)=2) and isnull(x.isOut,0) = 0      
 group by x.ID,x.NumMake,x.isOut      
 union all      
 /*工序委外加工合格、返工、报废数量*/      
 select       
  x.ID as WFPAID,      
  isnull(x.isOut,0) as isOut,      
  ISNULL(x.NumMake,0) as pgsl,      
  SUM(y.num1) as hgsl,      
  0 as fgsl,      
  0 as kdFgsl,      
  0 as bfsl,      
  convert(varchar(10),isnull(MIN(z.MinQTDate),''),120) startDate,              --实际开始时间      
  convert(varchar(10),isnull(MAX(z.MaxQTDate),''),120) endDate              --实际结束时间      
 from M2_WFP_Assigns x      
 inner join M2_OutOrderlists y on x.ID = y.WFPAID and y.del = 1      
 left join (SELECT PID,MIN(QTDate) MinQTDate,MAX(QTDate) MaxQTDate FROM erp_Bill_QualityTestLogic() WHERE billType = 54006 GROUP BY PID) z ON z.PID = y.ID      
 where isnull(x.isOut,1) = 1 and x.del = 1      
 group by x.ID,x.NumMake,x.isOut)     
  t     
LEFT JOIN erp_WorkAssignsWFPWWNumInfoView ww ON  ww.WW_WFPAID=t.WFPAID    

GO

CREATE VIEW [dbo].[erp_Manu_QualityStatusList]  
AS  
---poType: 1.委外质检 2.工序委外质检,3.派工质检，4.返工质检; 默认值：必填  
---QTResult ： 0=合格 1=不合格 ; QTMode 0=全检 1=抽检  
---CkStatus: 0=无需审核或待审核 1=紧急放行，2全部返工，3 全部报废，4 按质检结果执行; 默认值：必填   
---QTModel  0=全 1=抽  
---合格数量 = 送检数量-报废数量-返工数量  
select   
 x.ID,  x.poType,  x.QTDate,  
 x.QTResultAll, y.bid,  x.CkStatus,  
 y.SerialNumber as AllNumber,  
 y.CanRKNum , y.CanBFNum, y.CanFGNum    
from M2_QualityTestings x   
inner join (  
 SELECT   
  a.ID,  
  max(b.bid) as bid,  
  sum(b.SerialNumber) as SerialNumber,  
  --可入库数量  
  SUM(  
  CASE a.QTResultAll  
  WHEN 0 THEN   
   CASE a.QTMode  
   WHEN 0 THEN  
    CASE when a.poType IN (3,4) then  
     (b.SerialNumber -ISNULL(b.NumBF,0)-ISNULL(b.NumScrap,0))  
       ELSE  
     b.SerialNumber  
       end  
   ELSE b.SerialNumber END  
  ELSE   
   CASE ISNULL(a.CkStatus,0)
      
   WHEN 0 THEN 0  
   WHEN 1 THEN b.SerialNumber   
   WHEN 2 THEN 0  
   WHEN 3 THEN 0  
   WHEN 4 THEN (b.SerialNumber -ISNULL(b.NumBF,0)-ISNULL(b.NumScrap,0))  
   ELSE 0 END   
  END) CanRKNum,  
  --可报废数量.只有派工使用  
  SUM(  
  CASE a.QTResultAll  
  WHEN 0 THEN   
   CASE a.QTMode  
   WHEN 0 THEN 
	CASE when a.poType IN (3,4) then  
	b.NumBF  
	ELSE 0 END
   ELSE 0 END  
  ELSE   
   CASE ISNULL(a.CkStatus,0)
   WHEN 0 THEN 0  
   WHEN 1 THEN 0  
   WHEN 2 THEN 0   
   WHEN 3 THEN b.SerialNumber  
   WHEN 4 THEN b.NumBF  
   ELSE 0 END   
  END) CanBFNum,  
  --可返工数量.只有派工使用  
  SUM(  
  CASE a.QTResultAll  
  WHEN 0 THEN   
   CASE a.QTMode  
   WHEN 0 THEN ISNULL(b.NumScrap,0)  
   ELSE 0 END  
  ELSE   
   CASE ISNULL(a.CkStatus,0)
   WHEN 0 THEN 0  
   WHEN 1 THEN 0  
   WHEN 2 THEN b.SerialNumber  
   WHEN 3 THEN 0  
   WHEN 4 THEN ISNULL(b.NumScrap,0)  
   ELSE 0 END   
  END) CanFGNum  
 FROM   
 dbo.M2_QualityTestings a    
 INNER JOIN dbo.M2_QualityTestingLists b ON a.ID = b.QTID and a.del = 1 and b.del = 1
 group by a.ID  
) y on x.ID = y.ID
GO

CREATE VIEW [dbo].[erp_Manu_QualityStatusListExt]
AS 
SELECT 
	a.*, 
	ISNULL(t01.HasBFNum,0) AS HasBFNum, 
	ISNULL(t01.HasRKNum,0) AS HasRKNum, 
	ISNULL(t02.HasFGNUM,0) AS HasFGNUM,
	CAST(SIGN(a.CanBFNum-ISNULL(t01.HasBFNum,0)) AS INT) AS NeedBF,
	CAST(SIGN(a.CanRKNum-ISNULL(t01.HasRKNum,0)) AS INT) AS NeedRK,
	CAST(SIGN(a.CanFGNum-ISNULL(t02.HasFGNum,0)) AS INT) AS NeedFG
FROM erp_Manu_QualityStatusList a 
LEFT JOIN (
	SELECT 
		b.fromid,
		--实际报废入库
		SUM(ISNULL((CASE  b.sort1 
		WHEN 14 THEN c.num1
		WHEN 15 THEN c.num1 
		ELSE 0 END),0)) AS HasBFNum,
		--实际质检入库 
		SUM(ISNULL((CASE  b.sort1 
		WHEN 5 THEN c.num1
		WHEN 13 THEN c.num1 
		ELSE 0 END),0)) AS HasRKNum
	FROM kuin b 
	INNER JOIN kuinlist c ON b.del=1
	AND b.sort1 IN (5,13, 14, 15)  AND c.kuin=b.ord 
	GROUP BY b.fromid
) t01 ON t01.fromid=a.id 
LEFT JOIN (
	SELECT a.QTID, SUM(b.NumMake) AS HasFGNUM FROM  M2_QualityTestingLists a 
	INNER JOIN dbo.M2_WorkAssigns b ON a.ID=b.QTListID 
	AND b.ptype=1 AND b.del=1
	GROUP BY a.QTID
) t02 ON t02.QTID = a.ID 

GO

CREATE VIEW [dbo].[erp_M2_WorkAssigns_status]
as
SELECT  M2WA.ID,del,creator,[status],tempSave,Cateid_WA,dateEnd,M2WA.DateStart,SPStatus
		,productid,ptype,title,M2WA.inDate,CASE when( ISNULL(M2PPtb.M2PPnum,0) > 0
		 or ISNULL(qtnumtb.sjnum,0) > 0
		)
	   and  M2WA.DateEnd>=CONVERT(varchar(10),GETDATE(),120)  and ISNULL(qtnumtb.sjnum,0)<ISNULL(M2WA.NumMake,0)
	  then '生产中'
	  when
	   M2WA.DateStart>=CONVERT(varchar(10),GETDATE(),120)
	   and
	   (ISNULL(M2PPtb.M2PPnum,0) = 0 and ISNULL(qtnumtb.sjnum,0) = 0)
	  then '未开始'
	  when
	   M2WA.DateStart < CONVERT(varchar(10),GETDATE(),120)
	   and
	   (ISNULL(M2PPtb.M2PPnum,0) = 0 and ISNULL(qtnumtb.sjnum,0) = 0)
	  then '滞期未开始'
	  when
	   (
		 ISNULL(M2PPtb.M2PPnum,0) > 0
		 or ISNULL(qtnumtb.sjnum,0) > 0
	   )
	   and ISNULL(qtnumtb.sjnum,0)>=ISNULL(M2WA.NumMake,0)
	  then '生产完毕'
	  when   M2WA.DateEnd<CONVERT(varchar(10),GETDATE(),120)
	   and
		(
		 ISNULL(M2PPtb.M2PPnum,0) > 0
		 or
		 ISNULL(qtnumtb.sjnum,0) >0
		)
	  then '超期生产中'
	  END AS wastatus
 FROM M2_WorkAssigns M2WA
left join
(
SELECT WAID,SUM(num1) as M2PPnum,ISNULL(MIN(inDate),'') as startdate,ISNULL(MAX(indate),'') as enddate 
FROM  M2_ProcedureProgres where del = 1
group by WAID
) as M2PPtb on M2PPtb.WAID = M2WA.ID    ---工序汇报数量
left join (select PID,SUM(SerialNumber) as sjnum,SUM(certNum) as certNum,SUM(NumBF) as bfnum,SUM(NumScrap) as fgnum
from [dbo].[erp_Bill_QualityTestLogic]() where billType = 54002 group by PID)
qtnumtb on M2WA.ID = qtnumtb.PID  --质检数量表

go

CREATE VIEW [dbo].[erp_Gxdqtx_status]
as
select  M2WA.ID,M2WA.title,M2WA.WABH,M2WA.inDate as adddate,M2WA.Cateid_WA as useperson,g.name as addcate,M2WA.QTListID,
		M2WA.del,M2WA.tempSave,M2WA.[Status],M2WA.SPStatus,M2WA.DateStart,M2WA.indate,M2WA.Cateid_WA
		,pro.type1 ptype,M2WA.dateEnd,pro.ord productid,
		(case when (ISNULL(M2PPtb.M2PPnum,0) > 0 or ISNULL(qtnumtb.sjnum,0) > 0 )
				and  M2WA.DateEnd>=GETDATE()
				and ISNULL(qtnumtb.sjnum,0)<ISNULL(M2WA.NumMake,0)
			then '生产中'
			when M2WA.DateStart>=CONVERT(varchar(10),GETDATE(),120)
				and (ISNULL(M2PPtb.M2PPnum,0) = 0 and ISNULL(qtnumtb.sjnum,0) = 0)
			then '未开始'
			when M2WA.DateStart < CONVERT(varchar(10),GETDATE(),120)
				and (ISNULL(M2PPtb.M2PPnum,0) = 0 and ISNULL(qtnumtb.sjnum,0) = 0)
			then '滞期未开始'
			when (ISNULL(M2PPtb.M2PPnum,0) > 0 or ISNULL(qtnumtb.sjnum,0) > 0 )
				and ISNULL(qtnumtb.sjnum,0)>=ISNULL(M2WA.NumMake,0)
			then '生产完毕'
			when (ISNULL(M2PPtb.M2PPnum,0) > 0 or ISNULL(qtnumtb.sjnum,0) >0            )
				and M2WA.DateEnd < GETDATE()
				and ISNULL(qtnumtb.sjnum,0)<ISNULL(M2WA.NumMake,0)
			then '超期生产中'
		end
		) as wastatus
	 from M2_WorkAssigns M2WA
	 left join M2_WorkingFlows_plan m2wfp on M2WA.WProID = m2wfp.ID and isnull(M2WA.fromtype,2) = 2
	 left join M2_WorkingFlows m2wf on M2WA.WProID = m2wf.ID and M2WA.fromtype = 1
	 left join sortonehy sort on M2WA.unit = sort.ord and sort.gate2 = 61 and sort.del = 1  
	 left join gate g on M2WA.Creator = g.ord and g.del = 1
	 left join (
		select WAID,SUM(num1) as M2PPnum,ISNULL(MIN(inDate),'') as startdate,ISNULL(MAX(indate),'') as enddate from  M2_ProcedureProgres where del = 1
		group by WAID
		 ) as M2PPtb on M2PPtb.WAID = M2WA.ID    ---工序汇报数量
	 left join (select PID,SUM(SerialNumber) as sjnum,SUM(certNum) as certNum,SUM(NumBF) as bfnum,SUM(NumScrap) as fgnum
					from [dbo].[erp_Bill_QualityTestLogic]() where billType in (54005,54002) group by PID
		 ) qtnumtb on M2WA.ID = qtnumtb.PID  --质检数量表
	 left join 
	 (
			select M2QTL.bid,SUM(kuin.num2) as kuinnum from kuinlist kuin
			join M2_QualityTestingLists M2QTL on kuin.M2_QTLID = M2QTL.ID and kuin.del = 1
			join M2_QualityTestings M2QT on M2QTL.QTID = M2QT.ID and M2QT.del = 1
			where kuin.del = 1 and M2QT.poType =4 group by M2QTL.bid
	  ) kuintb on M2WA.ID = kuintb.bid    ---入库数量 
	 left join erp_bill_extraBills erp on erp.oid = 54005 and erp.bid = m2wa.id
	 left join product pro on M2WA.ProductID = pro.ord and pro.del = 1
	 left join M2_QualityTestingLists M2QTList on M2QTList.ID = M2WA.QTListID
	 left join M2_WorkAssigns M2WA2 ON M2WA2.ID = M2WA.WAID
	 left join M2_QualityTestings M2QT on M2QT.ID = M2QTList.QTID

GO

CREATE VIEW [dbo].[erp_GXZJ_SL]
AS
	SELECT xlh,ISNULL(codebatch,0) as ph,zjid,waid,SUM(ISNULL(SerialNumber,0)) AS SJSL,SUM(ISNULL(WGSL,0)) AS WGSL,SUM(ISNULL(FGSL,0)) AS FGSL,SUM(ISNULL(BFSL,0)) AS BFSL FROM (
	--合格的完工数量 全检
	select xlh,ph codebatch,C.ID AS zjid,waid,SerialNumber,QTConform as WGSL,NumScrap as FGSL,NumBF AS BFSL from M2_GXQualityTesting A INNER JOIN M2_GXQualityTestingResult B ON A.ID=B.QTID
	INNER JOIN M2_WF_QCSchemeList C ON A.zjid=C.ID
	WHERE QTResult=0  and QTMode=0 AND C.isQC=1 AND A.del=1
	UNION ALL
	--不合格的完工数量 全检 待审
	select xlh,ph codebatch,C.ID AS zjid,waid,SerialNumber,0 as WGSL,0 as FGSL,0 AS BFSL from M2_GXQualityTesting A INNER JOIN M2_GXQualityTestingResult B ON A.ID=B.QTID
	INNER JOIN M2_WF_QCSchemeList C ON A.zjid=C.ID
	WHERE QTResult=1  and QTMode=0 and SPresult=-1 AND C.isQC=1 AND A.del=1
	UNION ALL
	--不合格的完工数量 全检 紧急放行
	select xlh,ph codebatch,C.ID AS zjid,waid,SerialNumber,SerialNumber as WGSL,0 as FGSL,0 AS BFSL from M2_GXQualityTesting A INNER JOIN M2_GXQualityTestingResult B ON A.ID=B.QTID
	INNER JOIN M2_WF_QCSchemeList C ON A.zjid=C.ID
	WHERE QTResult=1  and QTMode=0 and SPresult=1 AND C.isQC=1 AND A.del=1
	UNION ALL
	--不合格的完工数量 全检 全部返工
	select xlh,ph codebatch,C.ID AS zjid,waid,SerialNumber,0 as WGSL,SerialNumber as FGSL,0 AS BFSL from M2_GXQualityTesting A INNER JOIN M2_GXQualityTestingResult B ON A.ID=B.QTID
	INNER JOIN M2_WF_QCSchemeList C ON A.zjid=C.ID
	WHERE QTResult=1  and QTMode=0 and SPresult=2 AND C.isQC=1 AND A.del=1
	UNION ALL
	--不合格的完工数量 全检 全部报废
	select xlh,ph codebatch,C.ID AS zjid,waid,SerialNumber,0 as WGSL,0 as FGSL,SerialNumber AS BFSL from M2_GXQualityTesting A INNER JOIN M2_GXQualityTestingResult B ON A.ID=B.QTID
	INNER JOIN M2_WF_QCSchemeList C ON A.zjid=C.ID
	WHERE QTResult=1  and QTMode=0 and SPresult=3 AND C.isQC=1 AND A.del=1
	UNION ALL
	--不合格的完工数量 全检 按质检结果执行
	select xlh,ph codebatch,C.ID AS zjid,waid,SerialNumber,QTConform as WGSL,NumScrap as FGSL,NumBF AS BFSL from M2_GXQualityTesting A INNER JOIN M2_GXQualityTestingResult B ON A.ID=B.QTID
	INNER JOIN M2_WF_QCSchemeList C ON A.zjid=C.ID
	WHERE QTResult=1  and QTMode=0 and SPresult=4 AND C.isQC=1 AND A.del=1
	UNION ALL
	--合格的完工数量 抽检
	select xlh,ph codebatch,C.ID AS zjid,waid,SerialNumber,SerialNumber as WGSL,0 as FGSL,0 AS BFSL from M2_GXQualityTesting A INNER JOIN M2_GXQualityTestingResult B ON A.ID=B.QTID
	INNER JOIN M2_WF_QCSchemeList C ON A.zjid=C.ID
	WHERE QTResult=0  and QTMode=1 AND C.isQC=1 AND A.del=1
	UNION ALL
	--不合格的完工数量 抽检 待审
	select xlh,ph codebatch,C.ID AS zjid,waid,SerialNumber,0 as WGSL,0 as FGSL,0 AS BFSL from M2_GXQualityTesting A INNER JOIN M2_GXQualityTestingResult B ON A.ID=B.QTID
	INNER JOIN M2_WF_QCSchemeList C ON A.zjid=C.ID
	WHERE QTResult=1  and QTMode=1 and SPresult=-1 AND C.isQC=1 AND A.del=1
	UNION ALL
	--不合格的完工数量 抽检 紧急放行
	select xlh,ph codebatch,C.ID AS zjid,waid,SerialNumber,SerialNumber as WGSL,0 as FGSL,0 AS BFSL from M2_GXQualityTesting A INNER JOIN M2_GXQualityTestingResult B ON A.ID=B.QTID
	INNER JOIN M2_WF_QCSchemeList C ON A.zjid=C.ID
	WHERE QTResult=1  and QTMode=1 and SPresult=1 AND C.isQC=1 AND A.del=1
	UNION ALL
	--不合格的完工数量 抽检 全部返工
	select xlh,ph codebatch,C.ID AS zjid,waid,SerialNumber,0 as WGSL,SerialNumber as FGSL,0 AS BFSL from M2_GXQualityTesting A INNER JOIN M2_GXQualityTestingResult B ON A.ID=B.QTID
	INNER JOIN M2_WF_QCSchemeList C ON A.zjid=C.ID
	WHERE QTResult=1  and QTMode=1 and SPresult=2 AND C.isQC=1 AND A.del=1
	UNION ALL
	--不合格的完工数量 抽检 全部报废
	select xlh,ph codebatch,C.ID AS zjid,waid,SerialNumber,0 as WGSL,0 as FGSL,SerialNumber AS BFSL from M2_GXQualityTesting A INNER JOIN M2_GXQualityTestingResult B ON A.ID=B.QTID
	INNER JOIN M2_WF_QCSchemeList C ON A.zjid=C.ID
	WHERE QTResult=1  and QTMode=1 and SPresult=3 AND C.isQC=1 AND A.del=1
	) AS A GROUP BY zjid,waid,xlh,codebatch

GO

CREATE view  [dbo].[erp_m2wfpa_Nodes_Plan]    
as  
    --V31.98作废，Zml
	select t1.WAID,t1.ID,ISNULL(t1.oldID,t1.ID) BaseID, isnull(t1.isOut,0) as NodeType, t1.ord as ProcIndex , t1.Finished ,t1.NumMake as basePlanNum,0 PID,
	ISNULL(t1.ReportingExceptionStrategy,0) ReportingExceptionStrategy,
	(CASE WHEN ISNULL(t1.BatchNumberStart,0) = 1 THEN 1 ELSE 
			(CASE WHEN EXISTS(SELECT TOP 1 1 FROM dbo.M2_WFP_Assigns WHERE del = 1 AND WAID = t1.WAID AND ord = t1.ord AND BatchNumberStart = 1) THEN 1 ELSE 0 END) 
	END) BatchNumberStart,
	(CASE WHEN ISNULL(t1.SerialNumberStart,0) = 1 THEN 1 ELSE 
			(CASE WHEN ISNULL(t1.ReportingExceptionStrategy,0) = 0 AND EXISTS(SELECT TOP 1 1 FROM dbo.M2_WFP_Assigns WHERE del = 1 AND WAID = t1.WAID AND ord = t1.ord AND SerialNumberStart = 1) THEN 1 ELSE 0 END) 
	END) SerialNumberStart,
	ISNULL(t1.ConversionBL,1) ConversionBL,
	ISNULL(t1.ReportingRounding,0) ReportingRounding,
	ISNULL(t1.PreIndex,t1.ord - 1) PreIndex
	from M2_WFP_Assigns t1  
	INNER JOIN M2_WorkAssigns wa on t1.WAID=wa.ID 
	--where t1.del=1 and t1.NumMake>0   V31.98升级时，所有派工单都需要做老数据处理，转移到新表中，所以状态条件去除
	--AND ISNULL(wa.[Status],1)=1 
	union  all    
	SELECT basezj.*,0 ReportingExceptionStrategy,0 BatchNumberStart,0 SerialNumberStart,
	CAST((CASE WHEN maxzj.gxcount > 1 THEN 1 ELSE ISNULL(wfa.ConversionBL,1) END) AS DECIMAL(25,12)) ConversionBL,0 ReportingRounding,maxzj.Sort PreIndex
	FROM (
		select wa.ID WAID,wfSchemeL.ID, wfSchemeL.ID BaseID,2 as NodeType,wfSchemeL.Sort as ProcIndex , 0 Finished,wa.NumMake as basePlanNum,wfSchemeL.PID
		from  dbo.M2_WorkAssigns wa
		inner join M2_WF_QCScheme wfScheme on wa.del=1 and  wa.wfScheme = wfScheme.ID
		inner join M2_WF_QCSchemeList wfSchemeL on wfScheme.ID = wfSchemeL.PID AND isQC = 1
		WHERE ISNULL(wa.[Status],1)=1
	) basezj
	INNER JOIN (
		SELECT preID.ID,preID.PID,preID.preMaxID,COUNT(bxgx.Sort) gxcount,MAX(preID.Sort) Sort FROM (
			SELECT b.ID,b.PID,MAX(a.ID) preMaxID,MAX(a.Sort) Sort FROM M2_WF_QCSchemeList a
			INNER JOIN dbo.M2_WF_QCSchemeList b ON b.isQC = 1 AND a.PID = b.PID AND a.Sort = b.Sort - 1
			GROUP BY b.ID,b.PID
		) preID
		INNER JOIN dbo.M2_WF_QCSchemeList bxgx ON preID.PID = bxgx.PID AND preID.Sort = bxgx.Sort
		GROUP BY preID.ID,preID.PID,preID.preMaxID
	) maxzj ON basezj.BaseID = maxzj.ID AND basezj.PID = maxzj.PID
	LEFT JOIN dbo.M2_WFP_Assigns wfa ON basezj.WAID = wfa.WAID AND maxzj.preMaxID = wfa.WF_QCSchemeList
GO

CREATE view [dbo].[erp_m2wfpa_Nodes_log]
as
    --V31.98迭代作废，Zml                        
	--[type]: 0:自制;1委外;2工序质检
	 /*工序自制加工合格、返工、报废数量*/  
	 select 
		t2.WAID,  t2.WFPAID,
		t2.ProcIndex, t2.BaseID as BaseWFPAID, 
		t2.nodeType,  
		t2.basePlanNum as pgsl, --派工数量  
		t2.sjsl,	--送检数量(所有已占用数量)
		t2.hgsl, t2.fgsl,  t2.bfsl, 
		ISNULL(t2.codeBatch,0) AS codeBatch, 
		isnull( (select top 1  t3.SeriNum from M2_SerialNumberList  t3 where t3.id=t2.codeProductID) ,'') codeProduct ,
		isnull(t2.codeProductID,0) as codeProductID,
		SPresult,
		lastExecDate
	 from  (
		select 
			datatb.WAID,  datatb.WFPAID, ISNULL(plantb.oldID,plantb.ID) BaseID, 
			isnull(plantb.isOut,0) as NodeType, plantb.ord as ProcIndex,  
			plantb.NumMake as basePlanNum,   datatb.SPresult,  
			datatb.sjsl,  datatb.hgsl,  datatb.bfsl,  datatb.fgsl,
			datatb.codeBatch,  datatb.codeProductID,lastExecDate
		from M2_WFP_Assigns  plantb
		inner join (
			--1. 工序汇报
			 select
				y.WAID, y.WFPAID,    0 as [nodeType], 
				sum(case when y.result IN (1,2,3) then num1 else 0 end) sjsl,	--送检数量(所有已占用数量)
				sum(case when y.result IN (1,2) then num1 else 0 end) as hgsl, --合格数量  
				sum(case when y.result IN (2) then num1 else 0 end) as fgsl,  --返工数量  
				sum(case when y.result IN (3) then num1 else 0 end)  as bfsl,  --报废数量
				y.oriSeralNumber  as codeProductID,	--序列号
				y.codeBatch,	--批号
				1 as SPresult,
				MAX(y.inDate) lastExecDate
			from dbo.M2_ProcedureProgres y  where y.del = 1 
			group by y.WAID,  y.WFPAID , y.oriSeralNumber , y.codeBatch

			union all  
			  --2.工序委外
			 SELECT    
				c1.WAID,  c1.ID  , 1 as [type],
				sum(b.SerialNumber) as sjsl,    
				sum(    
					case 
					when a.QTResultAll =0 then
						case when a.poType IN (3,4)   and a.QTMode = 0
						then (b.SerialNumber -isnull(b.NumBF,0)-isnull(b.NumScrap,0)) 
						else b.SerialNumber
						end
					else     
						case 
						when a.CkStatus in (0, 2, 3) then 0    
						when a.CkStatus =1  then b.SerialNumber     
						when a.CkStatus in (4,5) then 
								(case  when a.poType IN (3,4) 
								then (b.SerialNumber -isnull(b.NumBF,0)-isnull(b.NumScrap,0))  
								else b.NumSPOK  end)  
						else 0 end     
				end) hgsl,    
				sum(    
					case 
					when a.QTResultAll =0 then
						case when a.poType IN (3,4) and a.QTMode = 0
						then isnull(b.NumScrap,0)
						else 0 end
					else     
						case 
						when a.CkStatus in (0, 1, 3 , 5) then 0    
						when a.CkStatus =2  then isnull(b.SerialNumber,0)      
						when a.CkStatus =4 then  isnull(b.NumScrap,0)  
						else 0  end     
					end
				)  as fgsl,
				sum(    
					case 
					when a.QTResultAll =0 then
						case when a.poType IN (3,4)  and a.QTMode = 0
						then isnull(b.NumBF,0)
						else 0 end
					else     
						case 
						when a.CkStatus in (0, 1, 2, 4) then 0    
						when a.CkStatus =3  then isnull(b.SerialNumber,0)    
						when a.CkStatus =5 then  isnull(b.NumBF,0)  
						else 0  end     
					end
				)  as bfsl,
				b.oriSeralNumber as codeProductID,
				b.codeBatch as codeBatch,
				1 as SPresult,
				MAX(a.indate) lastExecDate
			FROM  M2_WFP_Assigns c1 
			inner join (select id, WFPAID from M2_OutOrderlists where WFPAID>0) c on  c1.id=c.WFPAID
			inner join dbo.M2_QualityTestingLists b on c.id=b.bid and b.del=1 
			inner join M2_QualityTestings a on  a.ID = b.QTID and a.del = 1 and a.poType=2 
			where  isnull(a.CkStatus,0)<>2
			group by c1.WAID,  c1.ID,  b.oriSeralNumber ,  b.codeBatch
		)   datatb on 
			plantb.WAID= datatb.WAID 
			and plantb.ID=datatb.WFPAID 
			and isnull(plantb.isOut,0) =  datatb.nodeType

		union all

		 --3.工序质检
		select 
			waid,   WFPAID,  WFPAID as BaseID,
			2 as [type],	ProcIndex,
			NumMake,  SPresult,
			(sjsl +  isnull(prefgsl,0))   as  sjsl,     --
			(hgsl +  isnull(prefgsl,0) + fgsl) as  hgsl,    --prefgsl是负数， 表示上级自制工序已经返工的数量,   + fgsl 是因为prefgsl数量已经摊在了fgsl
			bfsl,  fgsl,
			codebatch,  oriSeralNumber,lastExecDate
		from (
			select 
					wa.ID as Waid ,  wfSchemeL.ID as WFPAID, 
					wfSchemeL.Sort  as ProcIndex,   wa.NumMake,
					sjsl,   hgsl,  fgsl,  bfsl,  
					(
						SELECT SUM(prefg.fgnum) FROM (
							select MAX(c.num1 * CAST(b.ConversionBL / a.ConversionBL AS DECIMAL(25,12))) as fgnum from  M2_WFP_Assigns a 
							INNER JOIN dbo.erp_m2wfpa_Nodes_Plan_tb b ON a.WAID = b.waid AND b.procindex = wfSchemeL.Sort AND a.ord = b.preindex
							inner join M2_ProcedureProgres c on a.WAID=c.WAID and a.ID=c.WFPAID and c.num1<0  and c.reworkFromID>0 AND c.del = 1  --reworkFromID>0表示是工序质检（非汇报返工）产生的返工
							INNER JOIN dbo.M2_WFP_Assigns d ON c.WAID = d.WAID AND c.[Procedure] = d.WPID AND d.del = 1
							AND isnull(c.codeBatch,0)=gxqsl.codebatch and  isnull(gxqsl.oriSeralNumber,0)=isnull(c.oriSeralNumber,0)
							WHERE a.WAID = gxqsl.waid AND a.del = 1 GROUP BY d.ord,c.reworkFromID
						) prefg
					) as prefgsl,
					oriSeralNumber,  codebatch,  SPresult,lastExecDate
			from M2_WorkAssigns wa
			inner join M2_WF_QCScheme wfScheme on wa.del=1 and wa.wfScheme = wfScheme.ID
			inner join M2_WF_QCSchemeList wfSchemeL on wfSchemeL.PID = wfScheme.ID and wfSchemeL.isQC = 1
			inner join (
				select  
						waid,  ID,  
						sum(sjsl) as sjsl,  sum(hgsl) as hgsl,   
						sum(fgsl) as fgsl,   sum(bfsl) as bfsl,
						oriSeralNumber,  codebatch, 
						SPresult,
						MAX(tx.indate) lastExecDate
				from (
					----SPresult:  -1= 待审   1: 紧急放行  2 : 全部返工 :  3:  全部报废 :  4:  按质检结果执行
					----QTMode :  0 = 全检   1=抽检
					----QTResult :  0 =合格   1=不合格
					select  a.waid , C.ID,  B.oriSeralNumber ,ph as codebatch,
						(SerialNumber) as sjsl,
						(
							case QTResult 
							when  0 then  (case QTMode when 0  then  QTConform else SerialNumber end)
							when 1  then  
								(case SPresult  when -1 then  0  when 1 then  SerialNumber
								when 2 then  0  when 3 then  0  when 4  then QTConform else 0 end)
							end
						)  as hgsl,
						(
							case QTResult 
							when  0 then  (case QTMode when 0  then  NumScrap else 0 end)
							when 1  then  
								(case SPresult  when -1 then NumScrap when 1 then  0
								when 2 then SerialNumber when 3 then  0  when 4 then  NumScrap  else 0 end)
							end	
						)   as fgsl,
						(
							case QTResult 
							when  0 then  (case QTMode when 0  then  NumBF else 0 end)
							when 1  then  
								(case SPresult when -1 then  NumBF when 1 then  0 when 2 then  0
								when 3 then  SerialNumber when 4 then  NumBF else 0 end)
							end	
						)   as bfsl,
						(case SPresult when -1 then 0 else 1 end)  as SPresult,
						A.indate 
					from M2_GXQualityTesting A 
					INNER JOIN M2_GXQualityTestingResult B ON A.ID=B.QTID
					INNER JOIN M2_WF_QCSchemeList C ON A.zjid=C.ID
					WHERE  C.isQC=1 AND A.del=1 
				)  tx  group by  waid , ID,  oriSeralNumber ,codebatch, SPresult
			) gxqsl  on  wa.ID= gxqsl.waid and wfSchemeL.ID= gxqsl.ID 
		)  t001
	) t2
	WHERE t2.sjsl <> 0 or t2.fgsl <> 0

GO

CREATE view [dbo].[erp_m2wfpa_Nodes_ProcIndexSum]
as  
--V31.98迭代作废，Zml
select  xx.*, yy.SeriNum as codeProduct  from ( 
	select WAID,ProcIndex,MIN(hgsl) hgsl,codeBatch ,codeProductID,y.ReportingExceptionStrategy
	from (
		select WAID,BaseID,ProcIndex,codeBatch,codeProductID,SUM(hgsl) hgsl,x.ReportingExceptionStrategy
		from (
			select t.WAID,t.ID,t.BaseID,t.ProcIndex,t.NodeType,t.codeBatch,t.codeProductID,CAST(ISNULL(hgsl,0) AS DECIMAL(25,12)) / t.ConversionBL hgsl,t.ReportingExceptionStrategy from (
				select distinct nPlan.WAID,nPlan.ID,nPlan.BaseID,nPlan.ProcIndex,nPlan.NodeType,codeBatch,codeProductID,nPlan.ConversionBL,
				(CASE WHEN EXISTS(SELECT 1 FROM dbo.[erp_m2wfpa_Nodes_Plan_tb] 
							WHERE WAID = nPlan.WAID AND ProcIndex = nPlan.ProcIndex 
							AND BaseID <> nPlan.BaseID 
							AND ISNULL(ReportingExceptionStrategy,0) <> ISNULL(nPlan.ReportingExceptionStrategy,0)) 
						THEN 1 ELSE 0 END) Parallel,nPlan.ReportingExceptionStrategy
				from [erp_m2wfpa_Nodes_Plan_tb] nPlan
				inner join (
					select distinct waid,procIndex,codeBatch,codeProductID 
					from erp_m2wfpa_Nodes_log_tb
					group by WAID,ProcIndex,BaseWFPAID,codeBatch,codeProductID
					) nLog on nPlan.WAID = nLog.WAID and nPlan.ProcIndex = nLog.ProcIndex)
				t
			left join erp_m2wfpa_Nodes_log_tb nLog2 on t.ID = nLog2.WFPAID and t.codeBatch = nLog2.codeBatch 
			and t.codeProductID = nLog2.codeProductID and t.WAID=nLog2.WAID 
			WHERE (t.Parallel = 0 OR (t.Parallel = 1 AND t.ReportingExceptionStrategy = 0 AND (t.codeBatch = 0 OR EXISTS(SELECT TOP 1 1 FROM dbo.erp_m2wfpa_Nodes_log_tb
															WHERE WAID = t.WAID AND ProcIndex = t.ProcIndex AND WFPAID <> t.BaseID --解决并行非例外和例外工序都有批号时取合格数量需参考例外工序是否有此批号合格数量
															AND t.Parallel = 1 AND codeBatch = t.codeBatch AND ISNULL(hgsl,0) > 0)) ))
		) x
		group by WAID,BaseID,ProcIndex,codeBatch,codeProductID,x.ReportingExceptionStrategy
	) y	
	group by WAID,ProcIndex,codeBatch,codeProductID,y.ReportingExceptionStrategy
) xx left join M2_SerialNumberList yy on xx.codeProductID=yy.ID

GO

CREATE view [dbo].[erp_m2wfpa_Nodes_ProcIndexSum_onlySpOK]
as   
--V31.98迭代作废，Zml
select 
	WAID,ProcIndex,MIN(hgsl) hgsl,codeBatch ,
	codeProductID,ReportingExceptionStrategy
from (
	--处理工序变更
	select 
			WAID,BaseID,ProcIndex,
			codeBatch,codeProductID,
			SUM(hgsl) hgsl,
			ReportingExceptionStrategy
	from (
		select 
				t.WAID,t.ID,t.BaseID,t.ProcIndex,t.NodeType,
				t.codeBatch,t.codeProductID,CAST(ISNULL(hgsl,0) AS DECIMAL(25,12)) / t.ConversionBL hgsl,t.ReportingExceptionStrategy
		from (
			select 
				distinct 
				nPlan.WAID,nPlan.ID,nPlan.BaseID,nPlan.ProcIndex,
				nPlan.NodeType,codeBatch,codeProductID,nPlan.ConversionBL,
				(CASE WHEN EXISTS(SELECT 1 FROM dbo.[erp_m2wfpa_Nodes_Plan_tb] 
							WHERE WAID = nPlan.WAID AND ProcIndex = nPlan.ProcIndex 
							AND BaseID <> nPlan.BaseID 
							AND ISNULL(ReportingExceptionStrategy,0) <> ISNULL(nPlan.ReportingExceptionStrategy,0)) 
						THEN 1 ELSE 0 END) Parallel,nPlan.ReportingExceptionStrategy
			from [erp_m2wfpa_Nodes_Plan_tb] nPlan
			inner join (
				select distinct waid,procIndex,codeBatch,codeProductID 
				from erp_m2wfpa_Nodes_log_tb
				group by WAID,ProcIndex,BaseWFPAID,codeBatch,codeProductID
			) nLog on nPlan.WAID = nLog.WAID and nPlan.ProcIndex = nLog.ProcIndex
		)  t left join erp_m2wfpa_Nodes_log_tb nLog2 ON t.ID = nLog2.WFPAID 
													AND t.codeBatch = nLog2.codeBatch and t.codeProductID = nLog2.codeProductID 
													AND t.WAID=nLog2.WAID  and nlog2.ProcIndex=t.ProcIndex
		and nLog2.SPresult=1
		WHERE (t.Parallel = 0 OR (t.Parallel = 1 AND t.ReportingExceptionStrategy = 0 AND (t.codeBatch = 0 OR EXISTS(SELECT TOP 1 1 FROM dbo.erp_m2wfpa_Nodes_log_tb
															WHERE WAID = t.WAID AND ProcIndex = t.ProcIndex AND WFPAID <> t.BaseID --解决并行非例外和例外工序都有批号时取合格数量需参考例外工序是否有此批号合格数量
															AND t.Parallel = 1 AND codeBatch = t.codeBatch AND ISNULL(hgsl,0) > 0)) ))
	) x
	group by WAID,BaseID,ProcIndex,codeBatch,codeProductID,ReportingExceptionStrategy
) y	
group by WAID,ProcIndex,codeBatch,codeProductID,ReportingExceptionStrategy

GO

CREATE view [dbo].[erp_m2wa_NoFinished]  
as  
    select t1.ID as WAID,t1.NumMake,isnull(t2.OKNum,0) as NumOk,t1.ptype 
    from M2_WorkAssigns t1  
    left join (  
     select PID,  sum(SerialNumber) as OKNum from   
     [dbo].[erp_Bill_QualityTestLogic]() qtl     
     where qtl.billType = 54002   
     group by  PID  
     )  t2 on t1.ID=t2.PID  
    --去掉这两个条件是因为V31.98版本升级需要处理老数据,此处会将已完成的派工单筛除,导致未正常处理老数据
    --where isnull(OKNum,0) < t1.NumMake   
    --AND ISNULL(T1.[Status],1)=1                                     

GO

CREATE function [dbo].[erp_m2wfpa_nodes_getPreExecedNum]
(
    --V31.98迭代作废，Zml
	@Finished  int,    
	@prenum  decimal(25, 12),  
	@preok  decimal(25, 12),  
	@ReplaceWFNum  decimal(25, 12), 
	@ExecedNum  decimal(25, 12),  
	@minCount  decimal(25, 12),  
	@NodeType int,  
	@outnum  decimal(25, 12), 
	@basePlanNum decimal(25, 12), 
	@prepc  decimal(25, 12), 
	@ProcIndex int ,
	@existsPhorXlh int,   --是否禁止超量
	@CanOutNumber INT,
	@ReportingExceptionStrategy INT,
	@chaifen INT, --是否为批号序列号拆分出来的数据，如果是，则不需要计算超量比例
	@ptype INT --0=派工 1=返工
) returns decimal(25, 12)
as BEGIN
	declare @num int
	select @num = num1 from setjm3 where ord=88
	DECLARE @cl decimal(25,12)
	SELECT TOP 1 @cl = ISNULL(nvalue,0) FROM dbo.home_usConfig WHERE name = 'GXHBOverReportingValue'
	IF(@cl IS NULL OR ISNULL(@chaifen,0) = 1 OR @ptype = 1)
		SET @cl = 0;
	IF(ISNULL(@chaifen,0) = 1)
		SET @basePlanNum = @preok

	declare @preok2 decimal(25, 12)
	set @preok2 =  case WHEN @ProcIndex = 1 OR @NodeType = 1
			then isnull( @preok , 0) * (1 + @cl / 100.00)
			--zzy:未分析明白为什么要减去替代数量和已执行数量的差,因处理 BUG:32169 改为下面逻辑
			--else isnull(  (@preok  -   (isnull(@ReplaceWFNum,0) -  isnull(@ExecedNum,0)))  ,0)  --考虑替代工序的情况
			else (case when ABS(ISNULL(@ReplaceWFNum,0))>0 
						then isnull(  (@preok  -   (isnull(@ReplaceWFNum,0) -  isnull(@ExecedNum,0)))  ,0)--考虑替代工序的情况
						else isnull(  (@preok  -   isnull(@ExecedNum,0))  ,0)   -- 不加此逻辑会与 erp_m2wfpa_Nodes_ExecStatus 中的"e"表冲突 详见:[BUG:33105] 和[BUG:31945]
					end)
	end;
	
	return case @Finished 
			when 1 then ROUND(isnull(@prenum,0),@num)
			else 
				CASE WHEN @ReportingExceptionStrategy = 1 AND @preok > 0 THEN 100000000
				ELSE
					case when (@ProcIndex = 1 and @existsPhorXlh = 0 and @CanOutNumber=1)
					then ROUND(@basePlanNum * (1 + @cl / 100.00),@num)
					else
						round(dbo.MinMin3Num(
							@preok2 , 
							@minCount, 
							(case  @NodeType when 1 
							then isnull(@outnum, @preok2)  
							else 
								case 
								when @ProcIndex = 1 OR @NodeType = 1 then @basePlanNum * (1 + @cl / 100.00) 
								else @preok2
								end
							end)
						),@num)
					end - (CASE WHEN @chaifen = 0 THEN ISNULL(@prepc,0)  ELSE 0 END)
				END
			end
end

GO

CREATE view [dbo].[erp_m2wfpa_Nodes_ExecStatus_BackV3198]  
as  
select  t001.WAID,WFPAID,BaseWFPAID,NodeType,ProcIndex,codeBatch,codeProductID,Finished, 
		PreExecedNum,ExecedNum,ExecedNumAll,
        CASE WHEN ISNULL(maxindex.maxProcIndex,0) >= (t001.ProcIndex - 1) THEN (PreExecedNum-(CASE WHEN ExecedNum < 0 OR preiscut = 1 THEN 0 ELSE ExecedNum END)) ELSE 0 END CanExecNum,
		CASE WHEN ISNULL(maxindex.maxProcIndex,0) >= (t001.ProcIndex - 1) THEN (PreExecedNumCanOut-(CASE WHEN ExecedNum < 0 OR preiscut = 1 THEN 0 ELSE ExecedNum END)) ELSE 0 END AS CanExecNumCheck,
		isnull(t002.BatchNumber,'') as PHText,isnull(t003.SeriNum,'') as codeProduct,
		ReportingExceptionStrategy,BatchNumberStart,SerialNumberStart,ConversionBL,PreIndex
from (
    SELECT
		a.WAID,b.ID as WFPAID,b.BaseID as BaseWFPAID,b.NodeType,b.ProcIndex,
		isnull(isnull(d.codeBatch,c.codeBatch),0) as codeBatch, 
		(CASE WHEN b.ReportingExceptionStrategy = 0 then ISNULL(isnull(d.codeProductID,c.codeProductID), 0) ELSE 0 END) as codeProductID,b.Finished,
		[dbo].[erp_m2wfpa_nodes_getPreExecedNum](b.Finished,d.prenum,(CASE WHEN b.ReportingExceptionStrategy = 1 THEN 100000000 ELSE CAST(c.preok AS DECIMAL(25,12)) * b.ConversionBL END),e.ReplaceWFNum,d.ExecedNum,
												(CASE WHEN c.ReportingExceptionStrategy = 1 OR b.PreIndex = 0 OR c.codeProductID = 0 THEN 100000000 ELSE n.minCount END),b.NodeType,
													o.outnum,b.basePlanNum,CAST(c.prepc AS DECIMAL(25,12)) * b.ConversionBL,(CASE WHEN b.PreIndex = 0 THEN 1 ELSE b.ProcIndex END),
													0,0,b.ReportingExceptionStrategy,c.chaifen, a.ptype) as PreExecedNum,--上级继承数量- 替代数量（注: 第一道算法特殊）
		[dbo].[erp_m2wfpa_nodes_getPreExecedNum](b.Finished,d.prenum,(CASE WHEN b.ReportingExceptionStrategy = 1 THEN 100000000 ELSE  CAST(c.preok AS DECIMAL(25,12)) * b.ConversionBL END),e.ReplaceWFNum,d.ExecedNum,
													(CASE WHEN c.ReportingExceptionStrategy = 1 OR b.PreIndex = 0 OR c.codeProductID = 0 THEN 100000000 ELSE n.minCount END),b.NodeType,
													o.outnum,b.basePlanNum,CAST(c.prepc AS DECIMAL(25,12)) * b.ConversionBL,(CASE WHEN b.PreIndex = 0 THEN 1 ELSE b.ProcIndex END),
													isnull(isnull(d.codeBatch,c.codeBatch),0) + ISNULL(isnull(d.codeProductID,c.codeProductID), 0),1,b.ReportingExceptionStrategy,c.chaifen, a.ptype) as PreExecedNumCanOut,
		--待审核状态的质检单当级需要占用返工数量
		isnull(d.ExecedNum,0) ExecedNum,isnull(d.ExecedNumAll,0) ExecedNumAll,b.ReportingExceptionStrategy,b.BatchNumberStart,b.SerialNumberStart,b.ConversionBL,b.PreIndex,c.preiscut
	from [erp_m2wa_NoFinished] a  --0.待完成派工单
	inner join [erp_m2wfpa_Nodes_Plan_tb] b on a.WAID=b.WAID	--1.加载初始工序计划
	left join (
		select count(1) minCount,BillID Waid from dbo.S2_SerialNumberRelation where BillType = 54002 group by BillID 
	) n on a.WAID=n.Waid	--2.引入序列号批号约束
	left join (
		select sum(num1) as outnum,wfpaid 
		FROM M2_OutOrderlists 
		WHERE wfpaid>0 and del=1 
		GROUP by wfpaid
	) o on b.NodeType=1 and b.ID=o.WFPAID	--3.引入委外约束
	left join (
		SELECT a.Waid,0 as Procindex,CAST(a.basePlanNum AS DECIMAL(25,12)) / a.ConversionBL as preok,CAST(isnull(b.hgsl,0) AS DECIMAL(25,12)) / a.ConversionBL as prepc, 
		0 as codebatch,0 as codeProductID,a.ID as firstWFID,a.ReportingExceptionStrategy,CAST(0 AS INT) chaifen,CAST(0 AS INT) preiscut
		from dbo.[erp_m2wfpa_Nodes_Plan_tb]  a 
		left join (
			select x.waid,sum(x.sjsl) as hgsl,x.WFPAID   
			from erp_m2wfpa_Nodes_log_tb x
			INNER JOIN dbo.[erp_m2wfpa_Nodes_Plan_tb] y ON x.WAID = y.WAID AND x.WFPAID = y.ID
			where x.SPresult=1 AND (x.codeBatch > 0 OR x.codeProductID > 0)
			group by x.waid,x.WFPAID
		) b on a.WAID=b.WAID and a.ID = b.WFPAID
		where PreIndex=0
		union all
		select lg.waid,np.PreIndex as Procindex,CAST(sum(lg.sjsl) AS DECIMAL(25,12)) / np.ConversionBL,CAST(0 AS DECIMAL(25,12)),
		lg.codeBatch,lg.codeProductID,lg.WFPAID,np.ReportingExceptionStrategy,CAST(1 AS INT) chaifen,CAST(0 AS INT) preiscut
		FROM erp_m2wfpa_Nodes_log_tb lg
		INNER JOIN dbo.[erp_m2wfpa_Nodes_Plan_tb] np ON lg.WAID = np.WAID AND lg.WFPAID = np.ID
		where lg.SPresult=1 AND (np.BatchNumberStart = 1 or np.SerialNumberStart = 1)
		group by lg.waid,lg.codeBatch,lg.codeProductID,lg.WFPAID,np.ReportingExceptionStrategy,np.PreIndex,np.ConversionBL
		UNION ALL
		SELECT x1.WAID,x1.PreIndex AS Procindex,
		CAST((CASE WHEN MAX(x2.codeProductID) = 0
			THEN x1.basePlanNum ELSE SUM(x3.sjsl) END) AS DECIMAL(25,12)) / x1.ConversionBL,
		CAST((CASE WHEN MAX(x2.codeProductID) > 0 THEN 0 else MAX(ISNULL(x1code.hgsl,0)) END) AS DECIMAL(25,12)),
		x2.codeBatch,0 codeProductID,x1.BaseID WFPAID,x1.ReportingExceptionStrategy,
		(CASE WHEN MAX(x2.codeProductID) = 0
			THEN 0 ELSE 1 END) chaifen,(CASE WHEN MAX(x2.codeProductID) = 0 THEN 1 ELSE 0 END) preiscut
		FROM dbo.erp_m2wfpa_Nodes_Plan_tb x1
		INNER JOIN dbo.erp_m2wfpa_Nodes_log_tb x2 ON x1.WAID = x2.WAID AND x1.ProcIndex - 1 = x2.ProcIndex AND x2.hgsl > 0 AND x2.codeBatch > 0
		LEFT JOIN dbo.erp_m2wfpa_Nodes_log_tb x3 ON x1.WAID = x3.WAID AND x1.BaseID = x3.WFPAID AND x2.codeBatch = x3.codeBatch
		LEFT JOIN (
			select x.waid,sum(x.sjsl) / y.ConversionBL as hgsl,x.WFPAID   
			from erp_m2wfpa_Nodes_log_tb x
			INNER JOIN dbo.[erp_m2wfpa_Nodes_Plan_tb] y ON x.WAID = y.WAID AND x.WFPAID = y.ID
			WHERE y.PreIndex = 0 AND x.SPresult=1 AND (x.codeBatch > 0 OR x.codeProductID > 0)
			group by x.waid,x.WFPAID,y.ConversionBL
		) x1code on x1.WAID = x1code.WAID and x1.ID = x1code.WFPAID
		WHERE x1.PreIndex = 0	--实际意义上的首道工序之前如果已经执行了批号，需要继承批号
		GROUP BY x1.WAID,x1.PreIndex,x1.ConversionBL,x2.codeBatch,x1.BaseID,x1.ReportingExceptionStrategy,x1.basePlanNum,x1.ConversionBL
		union all
		select DISTINCT ok.waid,ok.Procindex,hgsl
										- MAX(CASE WHEN (nonum.SerialNumberStart = 1 AND nonum.codeProductID > 0 AND ok.codeBatch = 0 AND nonum.codeBatch = 0) OR (nonum.codeProductID > 0 AND ok.codeProductID = nonum.codeProductID) THEN ISNULL(nonum.num,0)
										 WHEN (nonum.BatchNumberStart = 1 AND nonum.codeBatch > 0 AND ok.codeProductID = 0) OR (nonum.codeBatch > 0 AND ok.codeBatch = nonum.codeBatch) THEN ISNULL(nonum.codebatchnum,0) ELSE 0 END),CAST(0 AS DECIMAL(25,12)),
		ok.codeBatch,(CASE WHEN nonum.ReportingExceptionStrategy = 1 THEN 0 ELSE ok.codeProductID END)codeProductID,
		ISNULL(nonum.WFPAID,0),ok.ReportingExceptionStrategy,(CASE WHEN ISNULL(nonum.num,0) > 0 THEN 1 ELSE 0 end) chaifen,CAST(0 AS INT) preiscut
		FROM [erp_m2wfpa_Nodes_ProcIndexSum_onlySpOK] ok
		LEFT JOIN(
			SELECT mnum.WAID,mnum.PreIndex,mnum.WFPAID,SUM(num) num,mnum.ReportingExceptionStrategy,mnum.codeBatch,mnum.codeProductID,codebatchnum,mnum.BatchNumberStart,mnum.SerialNumberStart
			FROM ( --需减去上一步模拟出序列号批号起点的上道工序数量
				SELECT lg.waid,np.PreIndex,lg.WFPAID,(CAST(sum(lg.sjsl) AS DECIMAL(25,12)) / np.ConversionBL) num,np.ReportingExceptionStrategy,lg.codeBatch,lg.codeProductID,
				(SELECT CAST(sum(sjsl) AS DECIMAL(25,12)) / np.ConversionBL FROM dbo.erp_m2wfpa_Nodes_log_tb WHERE WAID = lg.WAID AND WFPAID = lg.WFPAID AND (np.BatchNumberStart = 1 OR codeBatch = lg.codeBatch)) codebatchnum,
				np.BatchNumberStart,np.SerialNumberStart
				FROM erp_m2wfpa_Nodes_log_tb lg
				INNER JOIN dbo.[erp_m2wfpa_Nodes_Plan_tb] np ON lg.WAID = np.WAID AND lg.WFPAID = np.ID
				where lg.SPresult=1 AND (lg.hgsl > 0 OR lg.bfsl > 0)  AND (np.BatchNumberStart = 1 or np.SerialNumberStart = 1) AND np.PreIndex > 0 AND lg.sjsl > 0
				group by lg.waid,lg.codeBatch,lg.codeProductID,lg.WFPAID,np.ReportingExceptionStrategy,np.PreIndex,np.ConversionBL,np.BatchNumberStart,np.SerialNumberStart
			) mnum GROUP BY mnum.WAID,mnum.PreIndex,mnum.WFPAID,mnum.ReportingExceptionStrategy,mnum.codeBatch,mnum.codeProductID,codebatchnum,mnum.BatchNumberStart,mnum.SerialNumberStart
			UNION ALL 
			SELECT DISTINCT nodepa.WAID,nodepa.PreIndex,nodepa.BaseID,0 num,nodepa.ReportingExceptionStrategy,0 codeBatch,0 codeProductID,0 codebatchnum,
			nodepa.BatchNumberStart,nodepa.SerialNumberStart FROM dbo.erp_m2wfpa_Nodes_Plan_tb nodepa
			INNER JOIN(
				select lg.waid,lg.WFPAID,lg.ProcIndex
				FROM erp_m2wfpa_Nodes_log_tb lg
				INNER JOIN dbo.[erp_m2wfpa_Nodes_Plan_tb] np ON lg.WAID = np.WAID AND lg.WFPAID = np.ID
				where lg.SPresult=1 AND (np.BatchNumberStart = 1 or np.SerialNumberStart = 1) AND np.PreIndex > 0 AND lg.sjsl > 0
			) xxx ON nodepa.WAID = xxx.WAID AND nodepa.ProcIndex = xxx.ProcIndex AND nodepa.BaseID <> xxx.WFPAID
			WHERE nodepa.BaseID NOT IN (select lg.WFPAID
				FROM erp_m2wfpa_Nodes_log_tb lg
				INNER JOIN dbo.[erp_m2wfpa_Nodes_Plan_tb] np ON lg.WAID = np.WAID AND lg.WFPAID = np.ID
				where lg.SPresult=1 AND (np.BatchNumberStart = 1 or np.SerialNumberStart = 1) AND np.PreIndex > 0 AND lg.sjsl > 0
				GROUP BY lg.WFPAID)
		) nonum ON ok.WAID = nonum.WAID AND ok.ProcIndex = nonum.PreIndex
					AND (ok.codeBatch > 0 OR nonum.BatchNumberStart = 1 OR nonum.num = 0 OR nonum.codeBatch = ok.codeBatch) 
					AND (ok.codeProductID > 0 OR nonum.SerialNumberStart = 1 OR nonum.num = 0 OR nonum.codeProductID = ok.codeProductID)
		where hgsl>0
		GROUP BY ok.waid,ok.Procindex,hgsl,ok.codeBatch,(CASE WHEN nonum.ReportingExceptionStrategy = 1 THEN 0 ELSE ok.codeProductID END),
		ISNULL(nonum.WFPAID,0),ok.ReportingExceptionStrategy,nonum.num
	) c on a.WAID=c.WAID AND c.ProcIndex = b.PreIndex AND (c.firstWFID=0 OR b.ID=c.firstWFID) --  4.引入上层条件约束
	left join (
		SELECT waid,WFPAID,BaseWFPAID,codeBatch,codeProductID, 
		sum((case when lg.SPresult=0 then ISNULL(lg.sjsl,0)
		else (case lg.nodeType when 0 then lg.hgsl+lg.bfsl
			when 1 then ISNULL(lg.sjsl-lg.fgsl,0) 
			when 2 then isnull(lg.sjsl,0) END)   --由于质检的sjsl中已经根据上级返工做了扣除，所以此处不能再减去返工了
		END)) as ExecedNum,
		sum(lg.sjsl) as ExecedNumAll,
		sum(isnull(lg.hgsl,0)+ isnull(lg.bfsl,0)) as prenum,nodeType
		from erp_m2wfpa_Nodes_log_tb lg
		group by waid,WFPAID,BaseWFPAID,codeBatch,codeProductID,nodeType
	) d	on a.WAID=d.WAID and b.ID=d.WFPAID and ISNULL(c.codeBatch,0)= d.codeBatch AND (b.ReportingExceptionStrategy = 1 or ISNULL(c.codeProductID,0) = d.codeProductID)	and b.NodeType=d.nodeType--5.加载实际执行数据		
	left join (  
		--- 考虑替代工序的情况, 先查出总数， 然后减去本道，等于替代 ( 注意： 减去x.fgsl是因为BUG31945) --zml不能减fgsl 因为sjsl在log中已经考虑了fgsl，已经被对冲过。
		select sum(x.sjsl) as ReplaceWFNum,x.WAID,x.BaseWFPAID,x.ProcIndex,x.codeBatch,x.codeProductID
		from erp_m2wfpa_Nodes_log_tb x 
		group by x.WAID,x.BaseWFPAID,x.ProcIndex,x.codeBatch,x.codeProductID
	) e on b.WAID=e.WAID and b.BaseID=e.BaseWFPAID  
			and e.ProcIndex = b.ProcIndex
			and isnull(e.codeBatch,0)=isnull(isnull(d.codeBatch, c.codeBatch),0) 
			and e.codeProductID= isnull(d.codeProductID,  c.codeProductID)
) t001 
left join M2_BatchNumberList t002 on t001.codeBatch=t002.ID
left join M2_SerialNumberList t003 on t001.codeProductID=t003.ID
LEFT JOIN (
	SELECT t.WAID,MAX(t.maxProcIndex) maxProcIndex FROM (
	SELECT xx.WAID,xx.ProcIndex maxProcIndex,MIN(ISNULL(yy.hgsl,-1)) hgsl FROM dbo.erp_m2wfpa_Nodes_Plan_tb xx
	LEFT JOIN dbo.erp_m2wfpa_Nodes_log_tb yy ON yy.hgsl > 0 AND xx.WAID = yy.WAID AND xx.BaseID = yy.BaseWFPAID
	GROUP BY xx.WAID,xx.ProcIndex) t WHERE t.hgsl > 0 GROUP BY t.WAID
) maxindex ON t001.WAID = maxindex.WAID

GO

CREATE VIEW [dbo].[M2_ProcedureProgres_codeProduct_effective]
AS
	--获取已被使用且有返工的工序汇报信息(合格+返工合计=0)
	select pp.WAID,nPlan.BaseNodeID BaseID,sn.SeriNum codeProduct,SUM(num1) num1 from M2_ProcedureProgres pp
	inner join dbo.M2_ProcessExecution_Plan nPlan on pp.WFPAID = nPlan.NodeID
	LEFT JOIN dbo.M2_SerialNumberList sn ON sn.ID = pp.oriSeralNumber
	where pp.del = 1 and ISNULL(result,1) = 2
	group by pp.WAID,nPlan.BaseNodeID,sn.SeriNum
	having SUM(num1)>0
	UNION ALL
	select pp.WAID,nPlan.BaseNodeID BaseID,sn.SeriNum codeProduct,SUM(num1) num1 from M2_ProcedureProgres pp
	inner join dbo.M2_ProcessExecution_Plan nPlan on pp.WFPAID = nPlan.NodeID
	LEFT JOIN dbo.M2_SerialNumberList sn ON sn.ID = pp.oriSeralNumber
	where pp.del = 1 and ISNULL(result,1) = 1 AND pp.num1 < 0
	group by pp.WAID,nPlan.BaseNodeID,sn.SeriNum
	having SUM(num1)<0
GO
                    
CREATE VIEW [dbo].[erp_WA_Num]
AS
	--通过视图查询最后一道工序的明细数据 带序列号 带批号

	SELECT A.ID,(ISNULL(A.Num,0)-ISNULL(C.num,0)) AS Num,A.codeBatch,A.codeProductID,  D.SeriNum as codeProduct 
	FROM (
		SELECT A.WAID AS ID,B.ExecedNum AS Num,B.codeBatch,B.codeProductID FROM (
			SELECT waid,MAX(ProcIndex) AS MaxProcIndex FROM dbo.M2_ProcessExecution_Plan group by waid
		) AS A INNER JOIN (
			select WAID,ProcIndex,MIN(HgNum) AS ExecedNum,codeBatch,codeProductID from 
			 dbo.M2_ProcessExecution_Result 
			 GROUP BY WAID,ProcIndex,codeBatch,codeProductID
		) B ON A.MaxProcIndex=B.ProcIndex AND A.WAID=B.WAID
	) AS A
	LEFT JOIN (
		 select  mq2.bid id,sum(isnull(mq2.SerialNumber,0)) as num,ISNULL(mq2.codeBatch,0) AS codeBatch,ISNULL(mq2.oriSeralNumber,0) AS codeProductID
			from M2_QualityTestings mq1
			inner join M2_QualityTestingLists mq2
			on mq1.ID=mq2.QTID
			where mq1.del=1 and mq2.del =1 and mq1.poType in (3,4)
		  group by mq2.bid,mq2.codeBatch,mq2.oriSeralNumber
	 ) C ON A.ID=C.id AND A.codeBatch=C.codeBatch AND A.codeProductID=C.codeProductID	
	 left join M2_SerialNumberList D on D.ID = A.codeProductID

	UNION	ALL

	--通过视图查询无工序明细数据 默认为无序列号 无批号
	SELECT A.ID,(ISNULL(A.Num,0)-ISNULL(C.num,0)) AS Num,A.codeBatch,A.codeProductID, '' FROM (
		SELECT A.ID,NumMake as NUM,BNL.ID AS codeBatch,0 AS codeProductID FROM M2_WorkAssigns A 
		LEFT JOIN M2_BatchNumberList BNL ON A.ID=BNL.BussinessID
		WHERE NOT EXISTS (SELECT WAID FROM M2_WFP_Assigns WHERE A.ID=WAID AND del=1) AND ISNULL(A.wfScheme,0)=0
		AND ISNULL(A.[Status],1)=1) AS A
		LEFT JOIN (
			select  mq2.bid id,sum(isnull(mq2.SerialNumber,0)) as num,0 codeBatch,0 codeProductID
			from M2_QualityTestings mq1
			inner join M2_QualityTestingLists mq2
			on mq1.ID=mq2.QTID
		where mq1.del=1 and mq2.del =1 and mq1.poType in (3,4)
	group by mq2.bid) C ON A.ID=C.id

GO

CREATE VIEW [dbo].[erp_WA_SumNumNew]
AS
    --查询每个派工单的待派工数量
	SELECT ID,SUM(Num) as Num  FROM [erp_WA_Num] GROUP BY ID             

go
                                        
Create view [dbo].[v_kuoutlist2_cknum]
as
    select M2_OrderID,kuoutlist,SUM(num1) num1 from kuoutlist2
    where del = 1 and sort1 in(3,5,12)
    group by M2_OrderID,kuoutlist

go

Create view [dbo].[v_kuoutlist_applynum]
as
    select k.M2_OrderID,SUM(k.num1) applynum,SUM(cknums.num1) cknum from kuoutlist k
	inner join kuout ko on ko.del = 1 and isnull(ko.status,1) <> 0 and ko.ord = k.kuout
	left join [dbo].[v_kuoutlist2_cknum] cknums on cknums.kuoutlist = k.id
	where k.del = 1 
	group by k.M2_OrderID

go

Create View [dbo].[v_kNum]
as
    select ListID,mol.potype,sum(isnull(k.applynum,0)) applynum,sum(isnull(k.cknum,0)) cknum 
    from dbo.M2_MaterialOrderLists mol 
    LEFT JOIN dbo.M2_MaterialOrders mo ON mol.MOID = mo.ID AND mo.del = 1 and mo.del = 1
    LEFT JOIN [dbo].[v_kuoutlist_applynum] k ON mol.ID = k.M2_OrderID 
    where mol.del = 1
    group by ListID,poType

go

Create view [dbo].[v_ProductionMaterials_Log]
as
	select 
		BillType = case wa.ptype when 0 then 54002 else 54005 end,			--当前单据类型
		BillType_Base = case waBase.ptype when 0 then 54002 else 54005 end,	--源单据类型
		BillID = wa.ID,														--当前单据ID
		BillID_Base = ISNULL(wa.WAID,wa.ID),								--源单据ID
		BillID_Parent = ISNULL((case when qt.potype in(3,4) then parent.bid else 0 end),0),						--当前单据的上一级(派工/返工)ID ISNULL(parent.BillID,0)
		BillListID = wal.ID,												--当前单据物料ID
		BillListID_Base = ISNULL(walBase.id,(case when wa.ptype = 0 then wal.id else 0 end)),								--源单据物料ID
		BillListID_Parent = 0,
		wal.ProductID,
		BomList = ISNULL(wal.BomList,0),
		NeedNum = wal.num1 													--所需数量
	from M2_WorkAssignLists wal
	inner join M2_WorkAssigns wa on wal.WAID = wa.ID and wa.del = 1 and wa.[Status] <> 0
	inner join m2_WorkAssigns waBase on waBase.ID = isnull(wa.waid,wa.ID) and waBase.del = 1 and waBase.[Status] <> 0
	left join dbo.M2_QualityTestingLists parent on parent.ID=wa.QTListID and parent.del=1 
	left join dbo.M2_QualityTestings qt on parent.QTID=qt.ID
	left join m2_workAssignLists walBase on (wa.ptype = 2 or wal.ID = walBase.ID) and walBase.waid = waBase.id and walBase.productID = wal.productID and isnull(walBase.BomList,0) = isnull(wal.BomList,0)
	union all
	select
		BillType = case oo.wwtype when 0 then 54003 else 54006 end,
		BillType_Base = case oo.wwtype when 0 then 54003 else 54002 end,
		BillID = oo.ID,
		BillID_Base = ISNULL(isnull(wa.waid,wa.id),oo.ID),
		BillID_Parent = isnull(wa.ID,0),
		ool.ID as BillListID,
		ISNULL(isnull(walBase.ID,wal.ID),case oo.wwtype when 0 then ool.ID else 0 end)as BillListID_Base,--工序委外此字段为0代表为工序委外直接添加的物料
		isnull(wal.ID,case oo.wwtype when 0 then ool.ID else 0 end) BillListID_Parent,
		ool.ProductID,
		ISNULL(ool.BomListID,0) BomList,
		ool.num as NeedNum
	from M2_OutOrderlists_wl ool
	inner join M2_OutOrder oo on ool.outID = oo.ID and oo.del = 1 and oo.[status] <> 0
	left join M2_WorkAssignLists wal on isnull(ool.walID,0) = wal.ID and wal.del = 1
	left join m2_WorkAssigns wa on wa.id = wal.waid and wa.del = 1 and wa.status <> 0
	left join m2_workAssignLists walBase on walBase.waid = wa.waid and walBase.productID = wal.productID and isnull(walBase.BomList,0) = isnull(wal.BomList,0)
    where isnull(ool.Mergeinx,0)<=0

go

Create view [dbo].[v_ProductionMaterials_LBNums]
as
	--领料数量/补料数量
	select
		BillType = case wa.ptype when 0 then 54002 else 54005 end,
		max(wa.ID) as ID,
		wal.ID ListID,
		SUM(case when (mo.MaterialType in(1,2)) then mol.num1 else 0 end) llnum,
		SUM(case when (mo.MaterialType in(3)) then mol.num1 else 0 end) blnum 
	from dbo.M2_WorkAssignLists wal
	inner join dbo.M2_WorkAssigns wa ON wal.WAID = wa.ID
	left join dbo.M2_MaterialOrderLists mol ON wal.ID = mol.ListID and mol.poType in (1,2) and mol.del = 1
	left join dbo.M2_MaterialOrders mo ON mol.MOID = mo.ID AND mo.del = 1 and mo.[status] <> 0
	group by wa.ptype,wal.ID,mol.poType
	union all
	select
		BillType = case o.wwType when 0 then 54003 else 54006 end,
		max(o.ID) as ID,
		oow.ID ListID,
		SUM(case when (mo.MaterialType in(1,2)) then mol.num1 else 0 end) llnum,
		SUM(case when (mo.MaterialType in(3)) then mol.num1 else 0 end) blnum 
	from dbo.M2_OutOrderlists_wl oow
	inner join dbo.M2_OutOrder o ON oow.outID = o.ID
	left join dbo.M2_MaterialOrderLists mol ON oow.ID = mol.ListID and mol.poType in (3,4) and mol.del = 1
	left join dbo.M2_MaterialOrders mo ON mol.MOID = mo.ID AND mo.del = 1 and mo.[status] <> 0
	group by o.wwType,oow.ID,mol.poType
	
go

Create view [dbo].[v_ProductionMaterials_DJNums] 
AS
SELECT x.BillType,x.ListID,SUM(x.djnum) djnum,SUM(y.totalnum) djtotalnum FROM(
	select 
		BillType = case wa.ptype when 0 then 54002 else 54005 end,
		wal.ID ListID,
		mr.ID,
		SUM(mrl.num1) as djnum
	from M2_MaterialRegisterLists mrl 
	inner join M2_MaterialRegisters mr on mrl.MRID = mr.ID and mr.del = 1 and ISNULL(mr.[status],0) <> 0 and mr.PoType in (1,2,4)
	inner join M2_WorkAssignLists wal on wal.ID = mrl.ListID
	inner join M2_WorkAssigns wa on wa.del = 1 and wa.ID = wal.WAID and ISNULL(wa.Status,0) <> 0 
	where mr.poType IN(1,4)
	group by wal.ID,wa.ptype,mr.ID
	union all
	select 
		BillType = 54003,
		outwllist.ID  as ListID,
		mr.ID,
		sum(mrl.num1) as djnum
	from M2_MaterialRegisterLists mrl 
	inner join M2_MaterialRegisters mr on mrl.MRID = mr.ID and mr.del = 1 and ISNULL(mr.[status],0) <> 0 and mr.PoType in (3)
	inner join M2_OutOrderlists_wl outwllist on outwllist.ID = mrl.ListID
	inner join M2_OutOrderlists outlist on outlist.del = 1 and outlist.ID = mr.bid 
	group by outwllist.ID,mr.ID
) x 
INNER JOIN dbo.M2_MaterialRegisters y ON x.ID = y.ID
GROUP BY x.BillType,x.ListID

go

Create view [dbo].[v_ProductionMaterials_TFNums]
as
	--退料数量/废料数量
	SELECT 
		BillType = (case w.ptype when 0 then 54002 else 54005 end),
	    max(w.ID) as ID,
		a.ID ListID,
		SUM((CASE WHEN d.OrderType = 2 THEN c.num1 ELSE 0 END)) tnum,
		SUM((CASE WHEN d.OrderType = 3 THEN c.num1 ELSE 0 END)) fnum,
		MaterialType = case MaterialType when 2 then 1 else 3 end		--1代表此为领料退废;3代表为补料退废
	FROM dbo.M2_WorkAssignLists a
	INNER JOIN dbo.M2_WorkAssigns w ON a.WAID = w.ID
	INNER JOIN dbo.M2_MaterialOrderLists b ON a.ID = b.ListID and b.poType in(1,2) and b.del = 1
	INNER JOIN dbo.M2_MaterialOrders bp on bp.ID = b.MOID
	INNER JOIN dbo.M2_MaterialRegisterLists c ON c.del = 1 AND c.MOLID = b.ID
	INNER JOIN dbo.M2_MaterialRegisters d ON c.MRID = d.ID AND d.status <> 0
	GROUP BY a.ID,w.ptype,(case MaterialType when 2 then 1 else 3 end)
	union all
	SELECT 
		BillType = (case o.wwType when 0 then 54003 else 54006 end),
		max(o.ID) as ID,
		oow.ID ListID,
		SUM(CASE WHEN mr.OrderType = 2 THEN mrl.num1 ELSE 0 END) tnum,
		SUM(CASE WHEN mr.OrderType = 3 THEN mrl.num1 ELSE 0 END) fnum,
		MaterialType = case MaterialType when 2 then 1 else 3 end		--1代表此为领料退废;3代表为补料退废
    FROM dbo.M2_OutOrderlists_wl oow
    INNER JOIN dbo.M2_OutOrder o ON oow.outID = o.ID
    INNER JOIN dbo.M2_MaterialOrderLists mol ON oow.ID = mol.ListID and mol.poType in(3,4) and mol.del = 1
	INNER JOIN dbo.M2_MaterialOrders bp on bp.ID = mol.MOID
    INNER JOIN dbo.kuoutlist2 kl ON mol.ID = kl.M2_OrderID AND kl.del = 1 AND kl.sort1 in (3,12)            
    INNER JOIN dbo.M2_MaterialRegisterLists mrl ON kl.id = mrl.kuoutlist2 and mrl.del = 1
    INNER JOIN dbo.M2_MaterialRegisters mr ON mrl.MRID = mr.ID and mr.del = 1 and mr.status <> 0
    GROUP BY oow.ID,o.wwType,(case MaterialType when 2 then 1 else 3 end)

go

Create View [dbo].[v_ProductionMaterials_AllNums]
as
	select 
		[log].*,
		ISNULL(lbNums.llnum,0) llnum,
		ISNULL(lbNums.blnum,0) blnum,
		ISNULL(knums.applynum,0) aknum,
		ISNULL(knums.cknum,0) cknum,
		ISNULL(tfNums1.tnum,0)+isnull(tfNums3.tnum,0) tnum,
		ISNULL(tfNums1.tnum,0) tnum_ll,		--领料退料
		ISNULL(tfNums3.tnum,0) tnum_bl,		--补料退料
		ISNULL(tfNums1.fnum,0)+isnull(tfNums3.fnum,0) fnum,
		ISNULL(tfNums1.fnum,0) fnum_ll,		--领料废料
		ISNULL(tfNums3.fnum,0) fnum_bl,		--补料废料
		ISNULL(djNums.djnum,0) djnum,
		ISNULL(djNums.djtotalnum,0) djtotalnum
	from [dbo].[v_ProductionMaterials_Log] [log]
	left join [dbo].[v_ProductionMaterials_LBNums] lbNums on [log].BillType = lbNums.BillType and [log].BillListID = lbNums.ListID
	left join [dbo].[v_kNum] knums on [log].BillListID = knums.ListID and knums.poType = (case [log].BillType when 54002 then 1 when 54005 then 2 when 54003 then 3 else 4 end) 
	left join [dbo].[v_ProductionMaterials_TFNums] tfNums1 on [log].BillType = tfNums1.BillType and [log].BillListID = tfNums1.ListID and tfNums1.MaterialType = 1	--领料退废
	left join [dbo].[v_ProductionMaterials_TFNums] tfNums3 on [log].BillType = tfNums3.BillType and [log].BillListID = tfNums3.ListID and tfNums3.MaterialType = 3	--补料退废
	left join [dbo].[v_ProductionMaterials_DJNums] djNums on [log].BillType = djNums.BillType and [log].BillListID = djNums.ListID

go
                                        
CREATE View [dbo].[v_ProductionMaterials_AllNums_HasChilds]
as
	--派工(包含工序委外)
	select 
		x.BillType_Base BillType,
		ISNULL(NULLIF(x.BillID_Parent,0),BillID) BillID,
		ISNULL(NULLIF(x.BillListID_Base,0),x.BillListID) BillListID,
		x.ProductID,
		x.BomList,
		SUM(case x.BillType when 54002 then x.NeedNum else 0 end) NeedNum,
		SUM(x.llnum) llnum,
		SUM(x.blnum) blnum,
		SUM(x.aknum) aknum,
		SUM(x.cknum) cknum,
		SUM(x.tnum) tnum,
		SUM(x.tnum_ll) tnum_ll,
		SUM(x.tnum_bl) tnum_bl,
		SUM(x.fnum) fnum,
		SUM(x.djnum) djnum,
		SUM(x.djtotalnum) djtotalnum
	from [dbo].[v_ProductionMaterials_AllNums] x
	where x.BillType_Base = 54002 and x.BillType in(54002,54006) and x.BillListID_Base > 0
	group by x.BillType_Base,ISNULL(NULLIF(x.BillID_Parent,0),BillID),ISNULL(NULLIF(x.BillListID_Base,0),x.BillListID),x.ProductID,x.BomList
	having SUM(case x.BillType when 54002 then x.NeedNum else 0 end)>0
	union all
	--返工(包含工序委外)
	select 
		54005 BillType,
		(case x.BillType when 54005 then x.BillID else x.BillID_Parent end) BillID,
		ISNULL(NULLIF(x.BillListID_Parent,0),x.BillListID) BillListID,
		x.ProductID,
		x.BomList,
		SUM(case x.BillType when 54005 then x.NeedNum else 0 end) NeedNum,
		SUM(x.llnum) llnum,
		SUM(x.blnum) blnum,
		SUM(x.aknum) aknum,
		SUM(x.cknum) cknum,
		SUM(x.tnum) tnum,
		SUM(x.tnum_ll) tnum_ll,
		SUM(x.tnum_bl) tnum_bl,
		SUM(x.fnum) fnum,
		SUM(x.djnum) djnum,
		SUM(x.djtotalnum) djtotalnum 
	from [dbo].[v_ProductionMaterials_AllNums] x
	where x.BillType in(54005,54006) and x.BillID_Parent > 0 --排除工序委外直接添加料(因为没有对应返工单物料,无汇总意义)
	group by (case x.BillType when 54005 then x.BillID else x.BillID_Parent end),ISNULL(NULLIF(x.BillListID_Parent,0),x.BillListID),x.ProductID,x.BomList
	having SUM(case x.BillType when 54005 then x.NeedNum else 0 end)>0
	union all
	--工序委外/整单委外
	select 
		x.BillType,
		x.BillID,
		x.BillListID,
		x.ProductID,
		x.BomList,
		SUM(x.NeedNum) NeedNum,
		SUM(x.llnum) llnum,
		SUM(x.blnum) blnum,
		SUM(x.aknum) aknum,
		SUM(x.cknum) cknum,
		SUM(x.tnum) tnum,
		SUM(x.tnum_ll) tnum_ll,
		SUM(x.tnum_bl) tnum_bl,
		SUM(x.fnum) fnum,
		SUM(x.djnum) djnum,
		SUM(x.djtotalnum) djtotalnum 
	from [dbo].[v_ProductionMaterials_AllNums] x
	where x.BillType in(54003,54006)
	group by x.BillType,x.BillID,x.BillListID,x.ProductID,x.BomList
	having SUM(x.NeedNum)>0
GO
CREATE VIEW  [dbo].[v_attendance_GetRemind]
AS
 select tt.userID as Id,tt.userName
		,tt.WorkLong
		,tt.RemindUnit 
		,tt.LogDate
		,tt.orgsid
		 from(
    select hp.userID,hp.userName
		,SUM(isnull(aa.HWhenlong,0)) as WorkLong
		,0 as RemindUnit 
		,max(aa.CreateDate) as LogDate
		,hp.orgsid
	from dbo.HrKQ_AttendanceApply aa 
	inner join dbo.HrKQ_AttendanceApplyRange ar on aa.ID=ar.ApplyID
	inner join dbo.HrKQ_AttendanceType ht on ht.OnlyID=aa.ApplyType
	inner join dbo.hr_person hp on hp.userID=ar.UserID 
	where hp.del=0
	and isnull(aa.status,-1) in(1,-1) 
	and aa.ApplyType=11
	AND ISNULL(DATEDIFF(DAY,GETDATE(),aa.CreateDate),0)=0
	and isnull(ht.DayWarning,0)>0
	group by hp.orgsid,hp.userID,hp.userName
	having SUM(isnull(aa.HWhenlong,0))>=min(isnull(ht.DayWarning,0))
	union all
	select hp.userID,hp.userName,SUM(isnull(aa.HWhenlong,0)) as WorkLong
		,1 as RemindUnit
		,max(aa.CreateDate) as LogDate
		,hp.orgsid
	from dbo.HrKQ_AttendanceApply aa 
	inner join dbo.HrKQ_AttendanceApplyRange ar on aa.ID=ar.ApplyID
	inner join dbo.HrKQ_AttendanceType ht on ht.OnlyID=aa.ApplyType
	inner join dbo.hr_person hp on hp.userID=ar.UserID
	where hp.del=0
	and isnull(aa.status,-1) in(1,-1) 
    and isnull(ht.WeekWarning,0)>0
	AND aa.ApplyType =11
	AND aa.CreateDate<= CONVERT(varchar(100),(GETDATE()-Datepart(weekday, GETDATE() + @@DateFirst - 1)),23)
	group by hp.orgsid,hp.userID,hp.userName 
	having SUM(isnull(aa.HWhenlong,0))>=min(isnull(ht.WeekWarning,0))
	union all
	select hp.userID,hp.userName,SUM(isnull(aa.HWhenlong,0)) as WorkLong
		,2 as RemindUnit
		,max(aa.CreateDate) as LogDate
		,hp.orgsid
	from dbo.HrKQ_AttendanceApply aa 
	inner join dbo.HrKQ_AttendanceApplyRange ar on aa.ID=ar.ApplyID
	inner join dbo.HrKQ_AttendanceType ht on ht.OnlyID=aa.ApplyType
	inner join dbo.hr_person hp on hp.userID=ar.UserID
	where hp.del=0 and isnull(ht.MonthWarning,0)>0
		AND aa.ApplyType =11
		AND MONTH(aa.CreateDate)=MONTH(GETDATE())
		AND Year(aa.CreateDate)=Year(GETDATE())
	group by hp.orgsid,hp.userID,hp.userName 
	having SUM(isnull(aa.HWhenlong,0))>=min(isnull(ht.MonthWarning,0))) tt
GO

CREATE VIEW [dbo].[erp_WorkAssignProduceStatus]
AS
    
	select wa.ID
	,(case when ISNULL(wa.ProduceStatus,0)=0 
	   and wa.DateStart < CONVERT(varchar(10),GETDATE(),120) then 1 when ISNULL(wa.ProduceStatus,0)=2 
	   and wa.DateEnd < CONVERT(varchar(10),GETDATE(),120) then 3  else ISNULL(wa.ProduceStatus,0) end) as ProduceStatus
	from dbo.M2_WorkAssigns wa

GO
CREATE VIEW [dbo].[erp_ProcedureProgresOrOutOrderExists]
AS
    select x.ID as WFPAID
    from dbo.M2_WFP_Assigns as x 
    left join dbo.M2_ProcedureProgres as y on y.WFPAID = x.ID
    where (x.del = 1) and (y.del = 1) and isnull(x.isOut,0) = 0 and ISNULL(y.num1,0)<>0
    union all
    select x.ID as WFPAID
    from M2_WFP_Assigns x
    inner join M2_OutOrderlists y on x.ID = y.WFPAID and y.del = 1
    where isnull(x.isOut,1) = 1 and x.del = 1

GO
Create function [dbo].[erp_fn_GetForSJWorkAssigns](@Ids nvarchar(4000),@uid int)
returns table
as
return
(   with workInfo as(
         select CAST(short_str as int) as ID from dbo.split(@Ids,',') where len(isnull(@Ids,''))>0
         union all
         select wa.ID from dbo.M2_WorkAssigns wa
	     where wa.del=1
	        and len(isnull(@Ids,''))=0
		    and isnull(wa.ExecQcCheck,1)=1 
		    and isnull(wa.SPStatus,-1) in(-1,1)
		    and wa.Status!=2
		    and isnull(wa.Sjstatus,0) in(0,1)
    ),
     WorkAssignInfo as(--派工待送检
		  select wa.ID from dbo.M2_WorkAssigns wa
		  inner join workInfo ids on ids.ID=wa.ID
	      where wa.del=1
		    and isnull(wa.ExecQcCheck,1)=1 
		    and isnull(wa.SPStatus,-1) in(-1,1)
		    and wa.Status!=2
		    and isnull(wa.Sjstatus,0) in(0,1)
		    and isnull(wa.ptype,0)=0
		    and exists(
		       SELECT 1 from dbo.gate gt 
		       inner join power sjpow ON sjpow.ord =@uid AND sjpow.sort1 = 54 and sjpow.sort2=1  
		       WHERE  (sjpow.qx_open = 3 OR CHARINDEX(','+CAST(gt.ord AS VARCHAR(20))+',',','+CAST(sjpow.qx_intro AS VARCHAR(8000))+',') > 0)  
		       and CHARINDEX(','+CAST(gt.ord AS VARCHAR(20))+',',','+ISNULL(wa.Cateid_WA,-1)+',') > 0)
		   union all
		   select wa.ID from dbo.M2_WorkAssigns wa
		   inner join workInfo ids on ids.ID=wa.ID
	       where wa.del=1
		    and isnull(wa.ExecQcCheck,1)=1 
		    and isnull(wa.SPStatus,-1) in(-1,1)
		    and wa.Status!=2
		    and wa.Sjstatus in(0,1)
		    and isnull(wa.ptype,0)=1
		    and exists(
		       SELECT 1 from dbo.gate gt 
		       inner join power sjpow ON sjpow.ord =@uid AND sjpow.sort1 = 62 and sjpow.sort2=1  
		       WHERE  (sjpow.qx_open = 3 OR CHARINDEX(','+CAST(gt.ord AS VARCHAR(20))+',',','+CAST(sjpow.qx_intro AS VARCHAR(8000))+',') > 0)  
		       and CHARINDEX(','+CAST(gt.ord AS VARCHAR(20))+',',','+ISNULL(wa.Cateid_WA,-1)+',') > 0) 
    
    )
     ,wfpaInfo as(
        select wfpa.WAID,1 as IsHaveGX 
        from dbo.M2_WFP_Assigns wfpa
        inner join workInfo ids on ids.ID=wfpa.WAID
        where wfpa.del=1
        group by wfpa.WAID
    
    )
    ,QualityTestingfo as(--已送检
        select wa.ID,sum(qtl.Num) as Num 
        from dbo.M2_WorkAssigns wa
        inner join workInfo ids on ids.ID=wa.ID
        inner join dbo.M2_OneSelfQualityTestingTask qt on wa.ID=qt.WAID
        inner join dbo.M2_OneSelfQualityTestingTaskList qtl on qt.ID=qtl.TaskID
        group by wa.ID 
    )
    ,QualityTestingfoOld as(--已送检老数据
        select qtl.bid as ID,SUM(isnull(qtl.SerialNumber,0)) Num 
        from M2_QualityTestings qt
        inner join M2_QualityTestingLists qtl on qt.ID=qtl.QTID
        inner join workInfo ids on ids.ID=qtl.bid
        where qt.poType in(3,4) and qt.del=1
        and isnull(qt.TaskId,0)=0 and isnull(qtl.TaskMXId,0)=0
        group by qtl.bid
    )
    ,ProcessMaxProcIndex as(--最后一道执行工序
        select pep.WAID,MAX(pep.ProcIndex) MaxProcIndex
	    from  dbo.M2_ProcessExecution_Plan pep
	          inner join workInfo ids on ids.ID=pep.WAID
	    group by pep.WAID
    )
    ,ProcessCountProcIndex as(--最后一道工序的执行工序数
       select pmp.WAID,pmp.MaxProcIndex,Count(per.BaseNodeID) as NodeCount 
       from ProcessMaxProcIndex pmp
       inner join (select per2.WAID,per2.ProcIndex,per2.BaseNodeID,per2.NodeID from M2_ProcessExecution_Plan per2 group by per2.WAID,per2.ProcIndex,per2.BaseNodeID,per2.NodeID) per on pmp.WAID=per.WAID and pmp.MaxProcIndex=per.ProcIndex
       left join dbo.M2_WFP_Assigns wfpa on per.NodeID=wfpa.ID
       where isnull(wfpa.oldID,isnull(wfpa.ID,0))=isnull(wfpa.ID,0)
       group by pmp.WAID,pmp.MaxProcIndex
    )
    ,ProcessMinNumProcIndex as(--最后执行工序的最新小合格数量
       select x.WAID,x.CodeBatch,x.CodeProductID,x.MaxProcIndex
       ,Count(x.BaseNodeID) NodeCount,Min(x.HgNumByCheck) HgNumByCheck 
       from(
		   select pmp.WAID,per.BaseNodeID,isnull(per.CodeBatch,0) CodeBatch
		   ,isnull(per.CodeProductID,0) CodeProductID,pmp.MaxProcIndex
		   ,SUM(per.HgNumByCheck + isnull(per.HgNumByRework,0)) HgNumByCheck
		   from ProcessMaxProcIndex pmp
		   inner join dbo.M2_ProcessExecution_Result per on per.WAID=pmp.WAID and per.ProcIndex=pmp.MaxProcIndex
		   group by  pmp.WAID,per.BaseNodeID,isnull(per.CodeBatch,0),isnull(per.CodeProductID,0),pmp.MaxProcIndex
		   ) x
       group by x.WAID,x.CodeBatch,x.CodeProductID,x.MaxProcIndex
    )
    ,ProcessExecutionInfo as(
       select pc.WAID,SUM(pm.HgNumByCheck) MinHgNumByCheck  
       from ProcessCountProcIndex pc
       inner join ProcessMinNumProcIndex pm on pc.WAID=pm.WAID and pc.MaxProcIndex=pm.MaxProcIndex and pc.NodeCount=pm.NodeCount
       where pm.HgNumByCheck>0
       group by pc.WAID
    )
    select wa.ID,wa.title,wa.inDate,wa.Cateid_WA,wa.Creator
    from WorkAssignInfo b
    inner join dbo.M2_WorkAssigns wa on wa.ID=b.ID
    left join wfpaInfo wfpa on b.ID=wfpa.WAID
	left join ProcessExecutionInfo pe on b.ID=pe.WAID
	left join QualityTestingfo qt on b.ID=qt.ID
	left join QualityTestingfoOld qtold on b.ID=qtold.ID
	where  ((case when isnull(wfpa.IsHaveGX,0)=1 then isnull(pe.MinHgNumByCheck,0) else wa.NumMake end)-isnull(qt.Num,0)-isnull(qtold.Num,0))>0
)
GO

CREATE view [dbo].[erp_m2wfpa_Nodes_ExecStatus]  
AS
SELECT pr.WAID,pr.NodeID WFPAID,pr.BaseNodeID BaseWFPAID,pr.NodeType,pr.ProcIndex,pr.codeBatch,pr.codeProductID,pp.Finished,
SUM(pr.PreHgNumByCheck) PreExecedNum,SUM(pr.ExecedNum) ExecedNum,SUM(pr.ExecedNum) ExecedNumAll,SUM(pr.CanExecNum) CanExecNum,SUM(pr.CanExecNum) CanExecNumCheck,
bnl.BatchNumber PHText,snl.SeriNum codeProduct,pp.ReportingExceptionStrategy,pp.BatchNumberStart,pp.SerialNumberStart,pp.ConversionBL,pp.PreIndex
FROM dbo.M2_ProcessExecution_Result pr
INNER JOIN dbo.M2_ProcessExecution_Plan pp ON pr.PlanID = pp.ID
LEFT JOIN dbo.M2_BatchNumberList bnl ON pr.codeBatch = bnl.ID
LEFT JOIN dbo.M2_SerialNumberList snl ON pr.codeProductID = snl.ID
GROUP BY pr.WAID,pr.NodeID,pr.BaseNodeID,pr.NodeType,pr.ProcIndex,pr.codeBatch,pr.codeProductID,pp.Finished,
bnl.BatchNumber,snl.SeriNum,pp.ReportingExceptionStrategy,pp.BatchNumberStart,pp.SerialNumberStart,pp.ConversionBL,pp.PreIndex

GO

CREATE view [dbo].[v_payout3]
as 
select a.*,b.ord as gysid,b.sort as gyssort,b.khid,b.name ,
case a.fromtype when 1 then c.title when 2 then d.title else e.title end as Btitle,
case a.fromtype when 1 then c.cgthid when 2 then d.cgid else e.sn end as Bsn,
case a.fromtype when 1 then c.thperson when 2 then d.cateid else e.ourperson end as Buid,
case a.fromtype when 1 then 0 when 2 then 0 else e.hl end as Bhl,
case a.fromtype when 1 then c.date3 when 2 then d.date3 else NULL end as BhlDate,
case a.fromtype when 1 then c.del when 2 then d.del else e.del end as BDel
from payout3 a 
left join tel b on A.company=b.ord
left join caigouth c on a.frombillid=c.ord and a.fromtype=1
left join caigou d on a.frombillid=d.ord and a.fromtype=2
left join M2_OutOrder e on a.frombillid=e.ID and a.fromtype in (3,4)
GO
CREATE VIEW [dbo].[M2_QualityTestings_MapView] 
as 
	select y.*,yy.ProductID from dbo.[M2_QualityTestings]  y 
	inner join dbo.M2_QualityTestingLists yl on y.ID = yl.QTID
	inner join dbo.M2_WorkAssigns yy on yy.ID = yl.bid

GO
CREATE VIEW [dbo].[M2_QualityTestingLists_MapView] 
as 
	select y.*,yy.ProductID
	from dbo.M2_QualityTestingLists y 
	inner join dbo.M2_WorkAssigns yy on yy.ID = y.bid
GO
CREATE VIEW [dbo].[M2_QualityTestingsOut_MapView] 
as 
	select y.*,yy.ProductID from dbo.[M2_QualityTestings]  y 
	inner join dbo.M2_QualityTestingLists yl on y.ID = yl.QTID
	inner join dbo.M2_OutOrderLists yy on yy.ID = yl.bid

GO
CREATE VIEW [dbo].[M2_QualityTestingListsOut_MapView] 
as 
	select y.*,yy.ProductID
	from dbo.M2_QualityTestingLists y 
	inner join dbo.M2_OutOrderLists yy on yy.ID = y.bid
GO
CREATE VIEW [dbo].[GetManuOrderRkStatus]
AS
    --入库状态 4：无需入库；0 未入库；1 部分入库；2 入库完毕；3 超量入库；
 SELECT MOrderID ,
        CASE WHEN MIN(rkstatus) = 4 THEN 4 --全是无需入库
             WHEN MAX(rkstatus) = 0 THEN 0 --全是未入库
             WHEN MIN(rkstatus) = 3 THEN 3 --超量入库+无需入库
             WHEN MIN(rkstatus) = 2 THEN 2 --入库完毕+超量入库+无需入库
             ELSE 1
        END rkstatus
 FROM   ( SELECT    mol.ID ,  
                    mol.MOrderID ,  
                    CASE WHEN mol.ExecStatus = 4 THEN 4  
                         WHEN mol.ExecStatus = 0 THEN 0  
                         WHEN mol.ExecStatus = 1  
                         THEN ( CASE WHEN MIN(ISNULL(wa.rkstatus,-1)) IN (-1,0)  
                                          AND MIN(ISNULL(ol.rkstatus,-1))IN (-1,0)   THEN 0  
                                     ELSE 1  
                                END )  
                         WHEN mol.ExecStatus = 2  
                         THEN ( CASE WHEN MIN(ISNULL(wa.rkstatus,-1)) IN (-1,0)  
                                          AND MIN(ISNULL(ol.rkstatus,-1)) IN (-1,0) THEN 0  
                                     WHEN MIN(ISNULL(wa.rkstatus,-1)) IN (-1,2 )
                                          AND MIN(ISNULL(ol.rkstatus,-1)) IN (-1,2 ) THEN 2  
                                     WHEN MIN(ISNULL(wa.rkstatus,-1)) IN (-1,3 ) 
                                          AND MIN(ISNULL(ol.rkstatus,-1)) IN (-1,3 ) THEN 3  
                                     ELSE 1  
                                END )  
                         WHEN mol.ExecStatus = 3  
                         THEN ( CASE WHEN MIN(ISNULL(wa.rkstatus,-1)) IN (-1,0) 
                                          AND MIN(ISNULL(ol.rkstatus,-1)) IN (-1,0) THEN 0  
                                     WHEN MIN(ISNULL(wa.rkstatus,999)) >= 2  
                                          AND MIN(ISNULL(ol.rkstatus,999)) >= 2 THEN 3  
                                     ELSE 1  
                                END )  
                    END rkstatus  
          FROM      dbo.M2_ManuOrderLists mol  
					left join dbo.ManuOrderListWaRkInfo wa on wa.ddlistid=mol.ID and wa.MOrderID=mol.MOrderID
                    LEFT JOIN dbo.M2_OutOrderlists ool ON ool.molist = mol.ID AND ool.del = 1  
                    LEFT JOIN dbo.M2_OutOrder ol ON ool.outID = ol.ID  
          WHERE     mol.del = 1 and isnull(mol.IsMerge,0)=0
GROUP BY            mol.ID ,
                    mol.MOrderID ,
                    mol.ExecStatus
        ) a
 GROUP BY MOrderID
GO

CREATE VIEW [dbo].[M2_BOM_mapView]
AS
SELECT x.*,y.ProductID FROM dbo.M2_BOM x
LEFT JOIN dbo.M2_BOMList y ON x.ID = y.BOM AND y.ParentID = 0 AND x.billType = 1

GO

CREATE VIEW [dbo].[Kuoutlist_MapView]
as 
select kl.ord, kl.ID,kl.kuout,k.Sort1,kl.Contractlist , kl.M2_OrderID , kl2.Kuinlist, kl.Num1
from kuoutlist kl
inner join kuout k on k.ord= kl.kuout
left join (
	select kuout,min(kuinlist) as kuinlist,kuoutlist from kuoutlist2 group by kuout,kuoutlist
) kl2 on kl2.kuoutlist = kl.id

GO

CREATE VIEW [dbo].[V_GetWasteCostMoney]
AS
(
	SELECT mrl.ID,ml.MthFinaMoney / mrl.num1 cbprice, ml.MthFinaMoney cbmoney
	FROM dbo.M2_MaterialRegisters mr
	INNER JOIN dbo.M2_MaterialRegisterLists mrl ON mr.ID = mrl.MRID
	INNER JOIN dbo.MCostLog ml ON ml.LogType = 43 AND mrl.ID = ml.JoinBillListId 
	WHERE mr.OrderType = 3 AND ISNULL(mr.canRk,0) = 0
	UNION ALL
	SELECT mrl.ID,SUM(kml.MthFinaMoney) / SUM(kml.LogNum) cbprice,SUM(kml.MthFinaMoney) cbmoney
	FROM dbo.M2_MaterialRegisters mr
	INNER JOIN dbo.M2_MaterialRegisterLists mrl ON mr.ID = mrl.MRID
	INNER JOIN dbo.kuinlist kl ON kl.sort1 = 16 AND mr.canRk = 1 AND kl.del = 1 AND mrl.ID = kl.M2_OrderID 
	INNER JOIN dbo.MCostLog kml ON kml.LogType = 11 AND kml.JoinBillListId = kl.id
	WHERE mr.OrderType = 3 AND ISNULL(mr.canRk,0) = 1
	GROUP BY mrl.ID
)