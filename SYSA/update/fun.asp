--<%response.end%>

create function [dbo].[CBillSNValue](
	@billType int,   @billID int
)
returns varchar(50)
as begin
	declare @r  varchar(50);
	declare @v varchar(8);
	declare @lastbit int, @i int,  @vi int,  @z int, @ii int;
	set @r  = cast(@billType as varchar(20))
	set @v = right( ('00000000' + cast(@billID as varchar(20))), 8 )
	set @lastbit =cast( right(@v,1) as int)
	set @i = 1;  set @z=3;
	while @i<=8
	begin
		set @vi = cast(substring(@v, @i, 1) as int);
		set @ii  = ((@lastbit +@i-1)%@z)+1;
		set @r = @r + (
			case @vi
				when 0 then substring('7AL', @ii  , 1)
				when 1 then substring('9DN', @ii , 1)
				when 2 then substring('5EM', @ii , 1)
				when 3 then substring('0BP', @ii , 1)
				when 4 then substring('6HK', @ii , 1)
				when 5 then substring('2FO', @ii , 1)
				when 6 then substring('3CQ', @ii , 1)
				when 7 then substring('8GS', @ii , 1)
				when 8 then substring('1JR', @ii , 1)
				when 9 then substring('4IT', @ii , 1)
			end
		) 
		set @i = @i +1;
	end
	return @r;
end
GO
Create function [dbo].[f_kNum](
  @Ids nvarchar(4000)='',
  @billType int 
)
returns table
AS
return
(  
	select mol.ListID,@billType as BillType
	,sum(isnull(mol.cknum,0)) applynum
	,sum(isnull(mol.cknum2,0)) cknum
	from dbo.M2_MaterialOrderLists mol
	inner join dbo.M2_WorkAssignLists wal on wal.ID=mol.ListID
	INNER JOIN dbo.m2_WorkAssigns wa on wa.id = wal.waid and wa.del = 1 and wa.status <> 0
	where @billType in(54002,54005)
	and ((mol.poType=1 and @billType=54002) or (mol.poType=2 and @billType=54005)) 
	and ((@billType=54002 and wa.ptype=0) or (@billType=54005 and wa.ptype=1))
	and mol.del = 1
	and (LEN(@Ids)=0 or CHARINDEX(','+CAST(wal.WAID AS nvarchar(20))+',',','+@Ids+',') > 0)
	group by mol.ListID
	union all
	select mol.ListID,@billType as BillType
	,sum(isnull(mol.cknum,0)) applynum
	,sum(isnull(mol.cknum2,0)) cknum
	from dbo.M2_MaterialOrderLists mol
	inner join M2_OutOrderlists_wl ool on ool.ID=mol.ListID
	inner join dbo.M2_OutOrder o ON ool.outID = o.ID
	where @billType in(54003,54006)
	and ((mol.poType=3 and @billType=54003) or (mol.poType=4 and @billType=54006))
	and ((@billType=54003 and o.wwtype=0) or (@billType=54006 and o.wwtype=1)) 
	and mol.del = 1
	and (LEN(@Ids)=0 or CHARINDEX(','+CAST(ool.outId AS nvarchar(20))+',',','+@Ids+',') > 0)
	group by mol.ListID
	union all--�ɹ�������������Ӧ�Ĺ���ί��
	select mol.ListID,@billType as BillType
	,sum(isnull(mol.cknum,0)) applynum
	,sum(isnull(mol.cknum2,0)) cknum
	from dbo.M2_MaterialOrderLists mol
	inner join M2_OutOrderlists_wl ool on ool.ID=mol.ListID
	INNER JOIN dbo.M2_WorkAssignLists wal on isnull(ool.walID,0) = wal.ID and wal.del = 1
	INNER JOIN dbo.m2_WorkAssigns wa on wa.id = wal.waid and wa.del = 1 and wa.status <> 0
	where @billType in(54002,54005)
	and mol.poType=4
	and mol.del = 1
	and ((@billType=54002 and wa.ptype=0) or (@billType=54005 and wa.ptype=1))
	and (LEN(@Ids)=0 or CHARINDEX(','+CAST(wal.WAID AS nvarchar(20))+',',','+@Ids+',') > 0)
	group by mol.ListID
)
GO

--�������͵�λ����
create function [dbo].[HrKQClassName](@id int) returns varchar(200)
as
begin
declare @ClassName varchar(200)
	if isnumeric(@id)=1
	begin
	 set @ClassName= (select title from hr_KQClass where id=@id and del=0)
	end
	else
	begin
	set @ClassName=''
	end
return @ClassName
end
GO

CREATE FUNCTION  [dbo].[FUN_GetFkdate](@fkdays int,@fkdate int)  
returns datetime
AS  
BEGIN  
    declare @date1 datetime 
	--��������˽�������
	set @date1 = GETDATE()
	if @fkdate>0
	begin 
		--�ؿ����ڴ��ڵ���������� 31��>6�µ��������30
		if @fkdate>day(dateadd(DD , -DAY(dateadd(MM , 1 ,getdate())) ,dateadd(MM , 1 ,getdate()))) 
		begin
			--�������һ��
			set @date1 = dateadd(DD , -DAY(dateadd(MM , 1 ,getdate())) ,dateadd(MM , 1 ,getdate()))
		end 
		else
			--���¸�����
			set @date1 = dateadd(DD ,@fkdate -day(getdate()) , getdate())
		--���¸�����С�ڵ�ǰ����
		if datediff(DD , @date1 , getdate())>0
		begin 
			--�ؿ����ڴ��������������
			if @fkdate> day(dateadd(DD , -DAY(dateadd(MM , 2 ,getdate())) ,dateadd(MM , 2 ,getdate())))
			begin 
				--�������һ��
				set @date1 =dateadd(DD , -DAY(dateadd(MM , 2 ,getdate())) ,dateadd(MM , 2 ,getdate()))
			end 
			else
				--���»ؿ�
				set @date1 = dateadd(DD ,@fkdate - day(dateadd(MM , 1 ,getdate())) , dateadd(MM , 1 ,getdate()))
		end
	end 
	--�������������
	else if @fkdays>0
	begin 
		set @date1 = dateadd(dd,@fkdays,getdate())
	end
	RETURN @date1
end 
GO
create function  [dbo].[erp_finace_willpayoutList_batchPlan](@showcomplete int,@uid int,@caigouids nvarchar(300),
@oldoutids nvarchar(300),@newoutids nvarchar(300))
returns table as return (
	select 
	         t1.cls,
			 t1.ord,
			 t1.cateid,
			 t1.bz,
			 t1.fyhk,
			 t1.company ,--�ͻ���Ӧ��ID
			 case  when t2.sort3=2 then (case when
		  (pw_list.qx_open= 3 OR CHARINDEX(','+CAST(t2.cateid AS VARCHAR(20))+',',','+CAST(pw_list.qx_intro AS VARCHAR(8000))+',') > 0) then t2.name else '' end)
		  when t2.sort3=1 then( case when
		  (pw_list1.qx_open= 3 OR 
		  CHARINDEX(','+CAST(t2.cateid AS VARCHAR(20))+',',','+CAST(pw_list1.qx_intro AS VARCHAR(8000))+',') > 0
		  or CHARINDEX(','+cast(@uid as varchar(50))+',',','+CAST(t2.share as varchar(8000))+',')>0) 
		   then  t2.name else '' end) else '' end as CompanyName,
		  
			 case when t2.sort3=2 then 0 else 1 end as telType,
			case t1.cls when 0 then '�ɹ�'
			   when 2 then '�ϰ�ί��'
			   when 4 then '����ί��'
			   when 5 then  '����ί��' else '' end as FromType,
			   case when t1.ordlist=1 then t1.title else '' end title,--��������
			    t1.cgid,
			     (t1.Money1-PayPlanMoney) as PayAlsoMoney,
			     (t1.Money1-PayPlanMoney) as LeftMoney,
			  getdate() as PlanDate,
			  case when isnull(t2.fkdate,0)>0
			  then  dbo.FUN_GetFkdate(isnull(t2.fkdays,0),isnull(t2.fkdate,0)) 
			  when ISNULL(t2.fkdate,0)=0 and isnull(t2.fkdays,0)>0
			  then DATEADD(DD,t2.fkdays,GETDATE())
			  when ISNULL(t2.fkdate,0)=0 and isnull(t2.fkdays,0)=0
			  then GETDATE() end
			  as PayableDate, 
			 '' as Intro,
	       case  when t2.sort3=2 then (case when
		  (pw_detail.qx_open= 3 OR CHARINDEX(','+CAST(t2.cateid AS VARCHAR(20))+',',','+CAST(pw_detail.qx_intro AS VARCHAR(8000))+',') > 0) then 1 else 0 end)
		  when t2.sort3=1 then( case when
		  (pw_detail1.qx_open= 3 
		  OR CHARINDEX(','+CAST(t2.cateid AS VARCHAR(20))+',',','+CAST(pw_detail1.qx_intro AS VARCHAR(8000))+',') > 0 
		  or CHARINDEX(','+cast(@uid as varchar(50))+',',','+CAST(t2.share as varchar(8000))+',')>0)  then 1
		  else 0 end) else 0 end as detailpower,
		t1.orddetail,
			 isnull(t2.del,-100) as CompanyDel, 
			 bz.intro as BzIntro,
			 isnull(t2.fkdays,0) as fkdays ,
			 isnull(t2.fkdate,0) as fkdate
			 
	from	(
		--�ɹ�
		select  0 cls, a.ord,b.cateid,title,cgid,b.company
		,b.money1,b.bz,b.del,date7,date3,  PayPlanMoney, PaySureMoney, 
		 isnull(c.hl,1) as hl,b.fyhk,
	      case when (pw_list.qx_open= 3 OR CHARINDEX(','+CAST(b.cateid AS VARCHAR(20))+',',','+CAST(pw_list.qx_intro AS VARCHAR(8000))+',') > 0) then 1 else 0 end as ordlist,
	  	  case when (pw_detail.qx_open= 3 OR CHARINDEX(','+CAST(b.cateid AS VARCHAR(20))+',',','+CAST(pw_detail.qx_intro AS VARCHAR(8000))+',') > 0) then 1 else 0 end as orddetail
		 from (
			select  x.ord, isnull(sum(y.money1),0)  as PayPlanMoney ,  ISNULL( sum(case y.Complete when 3 then y.money1 else 0 end) , 0) as PaySureMoney
			from caigou  x with(nolock) 
			left  join payout y with(nolock)  on  
			x.ord= y.contract and y.cls=0 and y.del=1
			where x.del=1  and isnull(x.status,-1) in (-1,1)  and isnull(x.sp,0)=0 
			group by x.ord,  x.money1 having x.money1>  isnull(sum(y.money1),0)  or @showcomplete=10 --��Ҫ��@showcomplete
		)  a 
		inner join caigou b with(nolock)  on a.ord= b.ord
		left join hl c on b.bz=c.bz and datediff(d, b.date3, c.date1)=0
		left join tel t on t.ord=b.company--��Ӧ��
		left join power pw_list on  pw_list.ord=@uid and pw_list.sort1=22 and pw_list.sort2=1 --�����б�鿴Ȩ��
		left join power pw_detail on  pw_detail.ord=@uid and pw_detail.sort1=22 and pw_detail.sort2=14 --��������鿴Ȩ��
		where 
		LEN(@caigouids)>0 
		and  CHARINDEX(','+cast( a.ord as varchar(10))+',',','+@caigouids +',')>0  
		
		union all

		--�ϰ�ί��
		select  2 cls, id,creator,title,sn,gys, a.money1 ,  14 bz,1 del,indate,odate,  PayPlanMoney, PaySureMoney,  1 as hl,0 as fyhk,1 as ordlist,
		1 as orddetail   from (
			select x.*,  isnull(sum(y.money1),0)  as PayPlanMoney , ISNULL( sum(case y.Complete when 3 then y.money1 else 0 end) , 0) as PaySureMoney from (
				select y.ID as ord,  sum(x.money1) as money1 
				from M_OutOrderlists  x 
				inner join M_OutOrder y on x.outID=y.ID 
				and y.del=0 and y.status=3
				group by y.Id
			) x left  join payout y with(nolock)  on  x.ord= y.contract and y.cls=2 and y.del=1
			group by x.ord,  x.money1 
			having x.money1>  isnull(sum(y.money1),0)  or @showcomplete=10
		) a inner join M_OutOrder b with(nolock)  on a.ord= b.ID and del=0 
		where LEN(@oldoutids)>0 and  CHARINDEX(','+cast( id as varchar(10))+',',','+@oldoutids +',')>0 
		union all
		
		
		--�°�ί��.�ǻ�������
		select  (5 - isnull(wwType,0))  cls, b.id,ourperson,title,sn,gys,money1,b.bz,del,indate,odate ,  PayPlanMoney, PaySureMoney , 
		isnull(c.hl,1) as hl,0 as fyhk,
		 case  when isnull(wwType,0)=0 then (case when
		  (pw_outlist.qx_open= 3 OR CHARINDEX(','+CAST(b.ourperson AS VARCHAR(20))+',',','+CAST(pw_outlist.qx_intro AS VARCHAR(8000))+',') > 0) then 1 else 0 end)
		  when isnull(wwType,0)=1 then( case when
		  (pw_gxoutlist.qx_open= 3 OR CHARINDEX(','+CAST(b.ourperson AS VARCHAR(20))+',',','+CAST(pw_gxoutlist.qx_intro AS VARCHAR(8000))+',') > 0) then 1 else 0 end) else 0 end as ordlist,
		   	 case  when isnull(wwType,0)=0 then (case when
		  (pw_outdetail.qx_open= 3 OR CHARINDEX(','+CAST(b.ourperson AS VARCHAR(20))+',',','+CAST(pw_outdetail.qx_intro AS VARCHAR(8000))+',') > 0) then 1 else 0 end)
		  when isnull(wwType,0)=1 then( case when
		  (pw_gxoutdetail.qx_open= 3 OR CHARINDEX(','+CAST(b.ourperson AS VARCHAR(20))+',',','+CAST(pw_gxoutdetail.qx_intro AS VARCHAR(8000))+',') > 0) then 1 else 0 end) else 0 end as orddetail 
		  from (
			select  x.id as ord, isnull(sum(y.money1),0)  as PayPlanMoney  , ISNULL( sum(case y.Complete when 3 then y.money1 else 0 end) , 0) as PaySureMoney
			from M2_OutOrder  x with(nolock) 
			left  join payout y with(nolock)  on  x.ID= y.contract and y.cls in (4,5) and y.del=1
			where x.del=1 
			and isnull(x.Stopstatus,0)=0  and  isnull(x.payPlan,0)<>2  and x.status in (-1,1)
			group by x.id ,  x.money1 having x.money1>  isnull(sum(y.money1),0)  or @showcomplete=10
		)  a inner join M2_OutOrder b with(nolock)  on a.ord= b.ID
		left join hl c on b.bz=c.bz and datediff(d, b.odate, c.date1)=0
	    left join power pw_outlist on  pw_outlist.ord=@uid and pw_outlist.sort1=5025 and pw_outlist.sort2=1 --�����б�鿴Ȩ�� ����ί��
		left join power pw_outdetail on  pw_outdetail.ord=@uid and pw_outdetail.sort1=5025 and pw_outdetail.sort2=14 --��������鿴Ȩ�� ����ί��
		left join power pw_gxoutlist on  pw_gxoutlist.ord=@uid and pw_gxoutlist.sort1=5026 and pw_gxoutlist.sort2=1 --�����б�鿴Ȩ�� ����ί��
		left join power pw_gxoutdetail on  pw_gxoutdetail.ord=@uid and pw_gxoutdetail.sort1=5026 and pw_gxoutdetail.sort2=14 --��������鿴Ȩ�� ����ί��
		
		where LEN(@newoutids)>0 and 
		CHARINDEX(','+cast( b.id as varchar(10))+',',','+@newoutids +',')>0 
		
		union all 
	 
		select (5 - isnull(wwType,0))  cls,b.id,ourperson,title,sn,gys,a.money1,b.bz,del,indate,odate,  PayPlanMoney, PaySureMoney , 
		isnull(c.hl,1) as hl,0 as fyhk,
	    case  when isnull(wwType,0)=0 then (case when
		  (pw_outlist.qx_open= 3 OR CHARINDEX(','+CAST(b.ourperson AS VARCHAR(20))+',',','+CAST(pw_outlist.qx_intro AS VARCHAR(8000))+',') > 0) then 1 else 0 end)
		  when isnull(wwType,0)=1 then( case when
		  (pw_gxoutlist.qx_open= 3 OR CHARINDEX(','+CAST(b.ourperson AS VARCHAR(20))+',',','+CAST(pw_gxoutlist.qx_intro AS VARCHAR(8000))+',') > 0) then 1 else 0 end) else 0 end as ordlist,
		   	 case  when isnull(wwType,0)=0 then (case when
		  (pw_outdetail.qx_open= 3 OR CHARINDEX(','+CAST(b.ourperson AS VARCHAR(20))+',',','+CAST(pw_outdetail.qx_intro AS VARCHAR(8000))+',') > 0) then 1 else 0 end)
		  when isnull(wwType,0)=1 then( case when
		  (pw_gxoutdetail.qx_open= 3 OR CHARINDEX(','+CAST(b.ourperson AS VARCHAR(20))+',',','+CAST(pw_gxoutdetail.qx_intro AS VARCHAR(8000))+',') > 0) then 1 else 0 end) else 0 end as orddetail 
		 
		 from (
			select   
				x.id as ord, 
				x.money1-isnull(x.yhmoney,0) as money1,
				isnull(sum(y.money1),0)  as PayPlanMoney, 
				ISNULL( sum(case y.Complete when 3 then y.money1 else 0 end) , 0) as PaySureMoney   
			from (
				--�°湤��ί��.��������
				select x.id as ID,  4 cls,  sum( y.TaxDstYhPrice*( z.NumSPOK +  (x.PayPlanInStockType-1)*z.NumBF)  ) as money1,max(x.yhmoney) yhmoney  
				from M2_OutOrder x 
				inner join  M2_OutOrderlists y on x.ID=y.outID  and  x.del=1 and isnull(x.Stopstatus,0)=0  and  isnull(x.payPlan,0)=2  and x.status in (-1,1)
				inner join M2_QualityTestingLists z on y.ID=z.bid  and z.del=1
				inner join M2_QualityTestings  q on z.QTID=q.ID  and q.poType = 2 
				group by  x.id 
				union all
				--�°�����ί��.��������
				select  x.id as outid,  5 cls, sum( y.TaxDstYhPrice* k.num2) as money1,max(x.yhmoney) yhmoney     from M2_OutOrder x 
				inner join  M2_OutOrderlists y on x.ID=y.outID  and  x.del=1 and isnull(x.Stopstatus,0)=0  and  isnull(x.payPlan,0)=2  and x.status in (-1,1)
				inner join M2_QualityTestingLists z on y.ID=z.bid  and z.del=1
				inner join M2_QualityTestings  q on z.QTID=q.ID  and q.poType = 1
				inner join (
					select  num2,   
					(case isnull(M2_QTLID,0) 
					when 0 then M2_BFID
					else M2_QTLID
					end) as M2QTLID,
					(case isnull(M2_QTLID,0) 
					when 0 then 2
					else 1
					end) as qctype
					from kuinlist  
					where num2 >0 and del=1  and (M2_QTLID>0 or M2_BFID>0)
				)  k on   k.M2QTLID = z.id   and (x.PayPlanInStockType=2 or x.PayPlanInStockType=k.qctype)
				group by  x.id 
			) x left  join payout y with(nolock)  on  x.ID= y.contract  and  y.cls=x.cls and y.del=1
			group by x.id ,  x.money1,yhmoney
			having x.money1>  isnull(sum(y.money1),0)   or 1=10
		) a inner join M2_OutOrder b with(nolock)  on a.ord= b.ID
	 	 left join hl c on b.bz=c.bz and datediff(d, b.odate, c.date1)=0
	    left join power pw_outlist on  pw_outlist.ord=@uid and pw_outlist.sort1=5025 and pw_outlist.sort2=1 --�����б�鿴Ȩ�� ����ί��
		left join power pw_outdetail on  pw_outdetail.ord=@uid and pw_outdetail.sort1=5025 and pw_outdetail.sort2=14 --��������鿴Ȩ�� ����ί��
		left join power pw_gxoutlist on  pw_gxoutlist.ord=@uid and pw_gxoutlist.sort1=5026 and pw_gxoutlist.sort2=1 --�����б�鿴Ȩ�� ����ί��
		left join power pw_gxoutdetail on  pw_gxoutdetail.ord=@uid and pw_gxoutdetail.sort1=5026 and pw_gxoutdetail.sort2=14 --��������鿴Ȩ�� ����ί��
		
		where LEN(@newoutids)>0 and  
			CHARINDEX(','+cast( b.ID  as varchar(10))+',',','+@newoutids +',')>0 	
	) t1 
	inner join gate t15 on t1.cateid=t15.ord 
	left join tel t2 on t1.company = t2.ord
	left join sortbz bz on bz.id=t1.bz
    left join power pw_list on  pw_list.ord=@uid and pw_list.sort1=26 and pw_list.sort2=1 --��Ӧ���б�鿴Ȩ��
	left join power pw_detail on  pw_detail.ord=@uid and pw_detail.sort1=26 and pw_detail.sort2=14 --��Ӧ������鿴Ȩ��
	left join power pw_list1 on  pw_list1.ord=@uid and pw_list1.sort1=1 and pw_list1.sort2=1 --�ͻ��б�鿴Ȩ��
	left join power pw_detail1 on  pw_detail1.ord=@uid and pw_detail1.sort1=1 and pw_detail1.sort2=14 --�ͻ�����鿴Ȩ��
    where (t1.Money1-PayPlanMoney)>0  or @showcomplete=10
)

GO

CREATE FUNCTION [dbo].[erp_CharNum](@inputStr VARCHAR(1000),@findChar VARCHAR(1000)) RETURNS INT
AS
BEGIN
	--����ĳ�ַ������ж�������Ŀ���ַ����д���
	DECLARE @strlen AS INT,@i AS INT,@findCount AS INT,@tmpchar AS VARCHAR(2)
	SET @strlen=LEN(@findChar)
	SET @i=1
	SET @findCount=0
	WHILE @i<=@strlen
	BEGIN
		SET @tmpchar=SUBSTRING(@findChar,@i,1)
		IF CHARINDEX(@tmpchar,@inputStr)>0
		BEGIN
			SET @findCount=@findCount+1
		END
		SET @i=@i+1
	END
	RETURN @findCount
END

GO

CREATE function [dbo].[erp_comm_db_IsField](  --�жϱ����Ƿ����ָ�����ֶ� �� �Ƿ���1 �� ���򷵻�0
	@tbname nvarchar(100),  -- ���ݱ�
	@fldname nvarchar(50)   -- �ֶ�����
) returns int as
begin
	declare  @r int
	set @r = 0
	if exists(
		select 1 from dbo.syscolumns a , dbo.sysobjects  b
		where
		a.id = b.id
		and b.id = object_id(N'[dbo].' + @tbname)
		and a.name = @fldname
	)
	begin
		set @r = 1
	end
	return @r
end

GO

CREATE function [dbo].[erp_CreateLink](
	--���ݲ�����������
	@StrTitle varchar(200),--�����ı�
	@LinkType int,--�������ͣ�1�����ݣ�2���ˣ�3����Ʒ
	@OrderType varchar(15),--������������ǵ�������������ú�
	@ID varchar(15), --����ID
	@Creator int, --������
	@uid int,--��ǰ�û�
	@sort1 int,--��Ȩ�޺�
	@sort2 int --��Ȩ�޺�
)
returns varchar(4000)
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
				if @OrderType = 31 
				begin
					set @rValue='<a href="../../design/content.asp?ord=' + dbo.NumEnCode(cast(@ID as varchar(30))) + '" target=_blank class=com>' + @StrTitle + '</a>'
				end 
				else
				begin 
					set @rValue='<span class=link title="�鿴������ϸ����" onmouseover=Bill.showunderline(this,"#ff0000") onclick=ck.SpShowList(' 
					+ @OrderType + ',' + cast(@ID as nvarchar(15)) + ',0,''detail'') onmouseout=Bill.hideunderline(this,"#0000ff")>'+@StrTitle+'</span>'
				end
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

CREATE function [dbo].[erp_createcplink](@pname varchar(200) ,@pid int) returns varchar(1000) as begin
	return '<a href=../../product/content.asp?ord=' + dbo.NumEnCode(@pid) + ' target=_blank>' + @pname + '</a>'
end

GO

Create FUNCTION [dbo].[SplitItem]
 (@str nvarchar(1000),@code varchar(4),@no int )
RETURNS varchar(200)
AS
BEGIN

declare @intLen int
declare @count int
declare @indexb  int
declare @indexe  int
set @intLen=len(@code)
set @count=0
set @indexb=1


if @no=0
  if charindex(@code,@str collate Chinese_PRC_CS_AI_KS_WS,@indexb)<>0
     return left(@str,charindex(@code,@str collate Chinese_PRC_CS_AI_KS_WS,@indexb)-1)
  else
     return @str

while charindex(@code,@str collate Chinese_PRC_CS_AI_KS_WS,@indexb)<>0
  begin
       set @count=@count+1
       if @count=@no
         break
       set @indexb=@intLen+charindex(@code,@str collate Chinese_PRC_CS_AI_KS_WS ,@indexb)
  end


if @count=@no
  begin

      set @indexe=@intLen+charindex(@code,@str collate Chinese_PRC_CS_AI_KS_WS,@indexb)
          if charindex(@code,@str collate Chinese_PRC_CS_AI_KS_WS,@indexe)<>0
             return substring(@str,charindex(@code,@str collate Chinese_PRC_CS_AI_KS_WS,@indexb)+len(@code),charindex(@code,@str collate Chinese_PRC_CS_AI_KS_WS,@indexe)-charindex(@code,@str collate Chinese_PRC_CS_AI_KS_WS,@indexb)-len(@code))
          else
             return right(@str,len(@str)-charindex(@code,@str collate Chinese_PRC_CS_AI_KS_WS,@indexb)-len(@code)+1)

  end

return ''

END

GO

CREATE function [dbo].[erp_deleteDate](
	@dat datetime,
	@delCount int
) returns datetime as begin
	--�����ڰ������������������
	return
		case sign(@delCount - datediff(d,'1901-1-1',@dat))
		when 1 then
			case sign(datediff(d,@dat,'1901')) when 1 then @dat else '1901' end
		else dateadd(d,-@delcount,@dat) end
end

GO

CREATE function  [dbo].[erp_getParentFieldByConfig](
	@configtext varchar(7000)
) returns varchar(100) as begin
	return 'a'
end
GO


CREATE function [dbo].[fun_getPY2](@str nvarchar(4000))
      returns nvarchar(4000)
      as
      begin
      declare @word nchar(1)
	  declare @PY nvarchar(4000)
      set @PY=''
      while len(@str)>0
      begin
		  set @word=left(@str,1)
		  --����Ǻ����ַ�������ԭ�ַ�
		  set @PY=@PY+(case when unicode(@word) between 19968 and 19968+20901
		  then (
			  case
				when N'�' >=@word then 'A'
				when N'��' >=@word then 'B'
				when N'�e' >=@word then 'C'
				when N'�z' >=@word then 'D'
				when N'��' >=@word then 'E'
				when N'�v' >=@word then 'F'
				when N'�B' >=@word then 'G'
				when N'��' >=@word then 'H'
				when N'�h' >=@word then 'G'
				when N'�i' >=@word then 'K'
				when N'�w' >=@word then 'L'
				when N'��' >=@word then 'M'
				when N'��' >=@word then 'N'
				when N'�a' >=@word then 'O'
				when N'��' >=@word then 'P'
				when N'��' >=@word then 'Q'
				when N'�U' >=@word then 'R'
				when N'�R' >=@word then 'S'
				when N'�X' >=@word then 'T'
				when N'�F' >=@word then 'W'
				when N'�R' >=@word then 'X'
				when N'�' >=@word then 'Y'
				else 'Z' end
		  )
		  else @word
		  end)
		  set @str=right(@str,len(@str)-1)
      end
      return @PY
end

GO

CREATE function [dbo].[GetBFB](@procv  decimal(25, 12) ,@maxv decimal(25, 12) )
returns varchar(14)
as begin
	declare @r  varchar(14)
	set @r = case @maxv when 0 then '0%' else  dbo.formatNumber((@procv/@maxv)*100,2,0) + '%' end
	return  @r
end
GO



CREATE FUNCTION [dbo].[getBirthDay](@dateStr VARCHAR(30))  RETURNS varchar(20)
AS
BEGIN
	Declare @a varchar(20)
	Declare @dayStr varchar(10)
	Declare @mdStr varchar(20)
	Declare @k int
	if len(@dateStr)<8
	RETURN 0
	set @mdStr=subString(@dateStr,6,5)
	set @k=charIndex('-',@mdStr)
	set @dayStr=Rtrim(subString(@mdStr,@k+1,2))
	if len(@dayStr)=1
	set @dayStr='0'+ @dayStr
	set @a=@dayStr
	if @a is null
	set @a=0
	RETURN @a
END

GO

CREATE FUNCTION [dbo].[getBirthDayIntStr](@dateStr VARCHAR(30))  RETURNS varchar(20)
AS
BEGIN
	Declare @a varchar(20)
	Declare @yearStr varchar(20)
	Declare @monthStr varchar(10)
	Declare @dayStr varchar(10)
	Declare @mdStr varchar(20)
	Declare @k int
	if len(@dateStr)<8
	RETURN 0
	set @yearStr=left(@dateStr,4)
	set @mdStr=subString(@dateStr,6,5)
	set @k=charIndex('-',@mdStr)
	set @monthStr=left(@mdStr,@k-1)
	if len(@monthStr)=1
	set @monthStr='0'+ @monthStr
	set @dayStr=Rtrim(subString(@mdStr,@k+1,2))
	if len(@dayStr)=1
	set @dayStr='0'+ @dayStr
	set @a=@yearStr+@monthStr+@dayStr
	if @a is null
	set @a=0
	RETURN @a
END
GO




CREATE FUNCTION [dbo].[getBirthMonth](@dateStr VARCHAR(30))  RETURNS varchar(20)
AS
BEGIN
	Declare @a varchar(20)
	Declare @monthStr varchar(10)
	Declare @mdStr varchar(20)
	Declare @k int
	if len(@dateStr)<8
	RETURN 0
	set @mdStr=subString(@dateStr,6,5)
	set @k=charIndex('-',@mdStr)
	set @monthStr=left(@mdStr,@k-1)
	if len(@monthStr)=1
	set @monthStr='0'+ @monthStr
	set @a=@monthStr
	if @a is null
	set @a=0
	RETURN @a
END
GO



CREATE FUNCTION [dbo].[getBirthYear](@dateStr VARCHAR(30))  RETURNS varchar(20)
AS
BEGIN
	Declare @a varchar(20)
	Declare @yearStr varchar(20)
	if len(@dateStr)<8
	RETURN 0
	set @yearStr=left(@dateStr,4)
	set @a=@yearStr
	if @a is null
	set @a=0
	RETURN @a
END
GO


create function [dbo].[GetIntNumber](@num money)
returns int as begin
--��ȡ����,����С����һλ
	declare @r int
	set @r = cast(@num as int)
	set @r = @r + sign(@num-@r)
	return @r
end
GO


CREATE FUNCTION [dbo].[getPinYin] (@str varchar(500) = '')
RETURNS varchar(500) AS
/*-------------------���ڻ�ȡ�������Ƶ�����ĸ---------------------------------*/
BEGIN
Declare @strlen int,
@return varchar(500),
@ii int,
@c char(1),
@chn nchar(1)
Declare @pytable table(
chn char(2) COLLATE Chinese_PRC_CS_AS NOT NULL,
py char(1) COLLATE Chinese_PRC_CS_AS NULL,
PRIMARY KEY (chn)
)
insert into @pytable values('߹', 'A')
insert into @pytable values('��', 'B')
insert into @pytable values('��', 'C')
insert into @pytable values('��', 'D')
insert into @pytable values('��', 'E')
insert into @pytable values('��', 'F')
insert into @pytable values('�', 'G')
insert into @pytable values('��', 'H')
insert into @pytable values('آ', 'J')
insert into @pytable values('��', 'K')
insert into @pytable values('��', 'L')
insert into @pytable values('�`', 'M')
insert into @pytable values('��', 'N')
insert into @pytable values('��', 'O')
insert into @pytable values('�r', 'P')
insert into @pytable values('��', 'Q')
insert into @pytable values('��', 'R')
insert into @pytable values('��', 'S')
insert into @pytable values('��', 'T')
insert into @pytable values('��', 'W')
insert into @pytable values('Ϧ', 'X')
insert into @pytable values('Ѿ', 'Y')
insert into @pytable values('��', 'Z')
select @strlen = len(@str), @return = '', @ii = 0
while @ii < @strlen
begin
select @ii = @ii + 1, @chn = substring(@str, @ii, 1)
if @chn > 'z' --//����������ַ������������ַ�
SELECT @c = max(py)
FROM @pytable
where chn <= @chn
else
set @c=@chn
set @return=@return+@c
end
return @return
END

GO

create function [dbo].[hr_get_test_type](@id int)
returns varchar(50)
as
begin
declare @str varchar(50)
set @str=(
select	case @id when 1 then
'��ѡ��'
	when 2 then
'��ѡ��'
	when 3 then
'�����'
	when 4 then
'�����'
	else
'�޷���'
	end )
return @str
end

GO

CREATE  function [dbo].[HrGetCompanyTypeName](@id int)
returns varchar(100)
as
begin
declare @thisName varchar(100)
if isnumeric(@id)=1
begin

if @id=1
begin
set @thisName='���ڹ���2'
end

else if @id=2
begin
set @thisName='���ڹ���1'
end

end

return @thisName

end

GO

--����id��ѯ��������
create function [dbo].[HrGetWelfare](@id int) returns varchar(100)
as
begin
declare @thisStr varchar(100)
set @id=dbo.HrNullNum(@id)
set @thisStr=case @id
when 1 then '���ϱ���'
when 2 then 'ҽ�Ʊ���'
when 3 then 'ʧҵ����'
when 4 then '���˱���'
when 5 then '��������'
when 6 then 'ס��������'
else '��' end

return @thisStr
end

GO

--��ѯָ���·ݵĹ涨�ϰ�����,cwDateΪĳ�µĵ�һ�죬gateidΪԱ��ID
CREATE  function [dbo].[HrGetMonthWorkDay](@startDate datetime,@endDate datetime,@uid int) returns int
as
begin

declare @Days int--����������
set @Days=0

if datediff(d,@endDate,@startDate)>0
begin
return 0
end

declare @iBetween as int,@i as int,@today datetime,@dayResult int
set @iBetween=datediff(d,@startDate,@endDate)
set @i=0

while @i<=@iBetween


begin
	set @today=dateadd(d,@i,@startDate)
	set @dayResult=dbo.HrTodayNeedWork(@today,@uid)

	if @dayResult=1 or @dayResult=4
	begin
	set @Days=@Days+1
	end

	set @i=@i+1
end


return @Days
end

GO
SET QUOTED_IDENTIFIER ON
GO


--Attrs:�����¿���
CREATE FUNCTION [dbo].[split](@Long_str Nvarchar(MAX),@split_str varchar(100))
RETURNS  @tmp TABLE(
    ID int IDENTITY PRIMARY KEY,
    short_str varchar(8000)
)
AS
BEGIN
    DECLARE @long_str_Tmp Nvarchar(MAX),
   @short_str varchar(8000),
   @split_str_length int

	if charindex(@split_str,@long_str collate Chinese_PRC_CS_AI_KS_WS) > 0
	begin
			SET @split_str_length = LEN(@split_str)

			IF CHARINDEX(@split_str,@Long_str collate Chinese_PRC_CS_AI_KS_WS)=1
				 SET @long_str_Tmp=SUBSTRING(@Long_str,
			 @split_str_length+1,
			 LEN(@Long_str)-@split_str_length)

			ELSE
				 SET @long_str_Tmp=@Long_str

			IF CHARINDEX(REVERSE(@split_str),REVERSE(@long_str_Tmp) collate Chinese_PRC_CS_AI_KS_WS)>1
				SET @long_str_Tmp=@long_str_Tmp+@split_str
			ELSE
				SET @long_str_Tmp=@long_str_Tmp

			WHILE CHARINDEX(@split_str,@long_str_Tmp collate Chinese_PRC_CS_AI_KS_WS)>0
				BEGIN
					SET @short_str=SUBSTRING(@long_str_Tmp,1,
			 CHARINDEX(@split_str,@long_str_Tmp collate Chinese_PRC_CS_AI_KS_WS)-1)
					DECLARE @long_str_Tmp_LEN INT,@split_str_Position_END int
					SET @long_str_Tmp_LEN = LEN(@long_str_Tmp)
					SET @split_str_Position_END = LEN(@short_str)+@split_str_length
					SET @long_str_Tmp=REVERSE(SUBSTRING(REVERSE(@long_str_Tmp),1,
			 @long_str_Tmp_LEN-@split_str_Position_END))
					IF @short_str<>'' INSERT INTO @tmp SELECT @short_str
				END
    end
	else
	begin
		insert into  @tmp  select @Long_str
	end
	RETURN
END

GO

--��������ݣ�����int����
create function [dbo].[HrNullNum](@num int) returns int
as
begin

declare @thisNum int
if @num='' or isnumeric(@num)=0 or @num is null
begin
set @thisNum=0
end

else
begin
set @thisNum=@num
end

return @thisNum

end

GO

--��������ݣ�����decimal����
Create function [dbo].[HrNullNum2](@num decimal(25,12)) returns decimal(25,12)
as
begin
	declare @thisNum decimal(25,12)
	if len(@num)=0 or isnumeric(@num)=0 or @num is null
	begin
		set @thisNum=0
	end
	else
	begin
		set @thisNum=@num
	end
	
	return @thisNum
end

GO

--����id��ѯ���ռ��㷽ʽ
create function [dbo].[HrWelfareActin](@id int) returns varchar(100)
as
begin
declare @thisStr varchar(100)

if @id<>'' and @id is not null and isnumeric(@id)=1
begin
set @thisStr=case @id when 1 then  'һ�¼���' when 2 then  'ʵ������' when 3 then  '���Բ���'else '��' end
end

else
begin
		set @thisStr=''
end
return @thisStr
end

GO

create function [dbo].[CallGetStatus](@id int)
returns varchar(50)
begin

declare @status varchar(50)
if isnumeric(@id)=1 and @id is not null
begin
 set @status=(case @id when 1 then '����' when 2 then '����' when 3 then '������' else 'δ��' end)
end

else
begin
return 'δ֪'
end

return @status
end

GO

create function [dbo].[CallGetTimeLenth](@times int)
returns varchar(100)
begin

declare @data varchar(100),@H int,@N int,@M int,@HO varchar(50),@NO varchar(50),@MO varchar(50)

	if isnumeric(@times)=1
	begin
		set @N=cast(@times/60 as int)
		set @M=@times%60

		if @M<10
		begin
			set @MO='0'+cast(@M as varchar)
		end

		else
		begin
			set @MO=cast(@M as varchar)
		end

		if @N<10
		begin
			set @NO='0'+cast(@N as varchar)
			set @HO='00'
		end

		else if @N>=10 and @N<60
		begin
			set @NO=cast(@N as varchar)
			set @HO='00'
		end

		else if @N>=60
		begin
			set @HO=cast(@N/60 as int)
			set @N=@N%60

			if @N<10
			begin
				set @NO='0'+cast(@N as varchar)
			end

			else
			begin
				set @NO=cast(@N as varchar)
			end

		end

	end

	else
	begin
		return '00:00:00'
	end

	set @data=@HO+':'+@NO+':'+@MO

	return isnull(@data,'00:00:00')

end

GO

CREATE function [dbo].[ProcBarHTML](@procv decimal(25, 12) ,@maxv decimal(25, 12) ) returns varchar(1000)
as begin
	declare @v decimal(25, 12) 
	declare @r varchar(1000)
	set @v  = (case  @maxv when 0 then 0  else  @procv/@maxv end)*100
	set @r = '<div class=rpt_proc style="width:98%"><div class=rpt_procbar style="width:' + cast(cast(@v as int) as varchar(10)) + '%"></div><div class=rpt_procv>' + cast(@v as varchar(10)) + '%</div></div>'
	return @r
end
GO


CREATE function [dbo].[deletechar0](@c nvarchar(4000))
returns nvarchar(4000)
as begin
	declare @I int
	declare @le int
	declare @nv nvarchar(4000)
	set @le = len(@c)
	set @I = 1
	set @nv = ''
	while(@I<=@le)
	begin
		if ascii(substring(@c,@I,1)) > 0
		begin
			set @nv= @nv + substring(@c,@I,1)
		end
		set @I=@I+1
	end
	return @nv
end
GO



CREATE FUNCTION [dbo].[RenewMember](@source AS VARCHAR(8000),@member AS VARCHAR(20),@char AS VARCHAR(10),@flg AS INT) RETURNS VARCHAR(8000)
BEGIN
	DECLARE @rtn AS VARCHAR(8000)
	IF @flg=1
	BEGIN
		SET @rtn=REPLACE(@char+@source+@char,@char+@member+@char,@char)
		IF left(@rtn,len(@char))=@char
		BEGIN
			SET @rtn=RIGHT(@rtn,LEN(@rtn)-LEN(@char))
		END
		IF RIGHT(@rtn,LEN(@char))=@char
		BEGIN
			SET @rtn=LEFT(@rtn,LEN(@rtn)-LEN(@char))
		END
	END
	ELSE
	BEGIN
		IF ISNULL(@source,'')<>''
		BEGIN
			IF CHARINDEX(@member,@source)<=0
			BEGIN
				SET @rtn=@source+@char+@member
			END
			ELSE
			BEGIN
				SET @rtn=@source
			END
		END
		ELSE
		BEGIN
			SET @rtn=@member
		END
	END
	RETURN @rtn
END

GO

CREATE FUNCTION [dbo].[erp_HasIntersection](@inputStr VARCHAR(8000),@findChar VARCHAR(8000)) RETURNS INT
AS
BEGIN
	DECLARE @rvalue AS BIT
	SET @rvalue=0
	IF EXISTS (SELECT TOP 1 * FROM dbo.[split](@findChar,',') a WHERE charindex(','+a.short_str+',',','+@inputStr+',')>0)
	BEGIN
		SET @rvalue=1
	END
	RETURN @rvalue
END

GO

CREATE function [dbo].[erp_manu_getmakenumber](
	@mnum decimal(25, 12),	 --��������
	@safenum decimal(25, 12),  --��ȫ���
	@BatRole int,    --��������
	@BatNum decimal(25, 12),   --��������
	@storeNum decimal(25, 12), --���п��
	@ARate decimal(25, 12)	 --�����
) returns decimal(25, 12)
as begin
	--- ����mrp�������ü����Ʒ������������
	declare @n decimal(25, 12)
	if @ARate >=1
	begin
		set @ARate = @ARate/100
	end
	set @mnum = (@mnum - @storeNum + @safenum)  --Ӧ������ʡ���桢��ȫ���
	set @mnum = case sign(@mnum) when 1 then  @mnum  else 0 end  --@mnumΪ����ʾ��������
	if ( @BatRole  = 2 and @BatNum > 0)
	begin
		--�̶�������
		set @n = cast(cast(@mnum/@BatNum as int) as decimal(25, 12))
		if @mnum/@BatNum - @n > 0
		begin
			set @n = @BatNum * (@n+1)
		end
		else
		begin
			set @n = @mnum
		end
	end
	else
	begin
		--ֱ��������
		set @n = @mnum
	end
	set @n = @n/(1 - @ARate)
	return @n
end

GO

CREATE function [dbo].[erp_manu_getxhkcnumber](
	@mnum decimal(25, 12),	 --��������
	@ARate decimal(25, 12),	 --�����
	@decNum decimal(25, 12),   --ʵ����������
	@safeNum  decimal(25, 12)  --��ȫ���
)  returns decimal(25, 12)
begin
	declare @r decimal(25, 12)
	if @ARate >=1
	begin
		set @ARate = @ARate/100
	end
	set @decNum = @decNum*(1-@ARate) --������ĺ󣬵õ���Ч������
	set @r = @mnum-@decNum + @safeNum  --��������Ϊ ʵ�ʼ�ȥ�ƻ� �� ������ռ�ÿ�����Ϊ��
	return @r
end
GO


CREATE function [dbo].[erp_sms_GetSmsCount](
	@body varchar(4000),--��������
	@canlong int,		--�Ƿ�Ϊ������
	@unitbits int,		--�������Ŷ��С
	@longbits int,		--������ռλ
	@signbits int		--��ͨ����ռλ
) returns int
as begin
	--�����������ų���
	declare @GetSmsCount int
	declare @lenbody int
	declare @sbit int
	set @lenbody = len(@body)
	if abs(@canlong)=1
	begin
		set @sbit = @unitbits - @longbits
	end
	else
	begin
		set @sbit = @unitbits - @signbits
	end
	set @GetSmsCount = cast(@lenbody / @sbit as int) + sign(@lenbody%@sbit)
	return @GetSmsCount
end
GO



CREATE function [dbo].[erp_qxlb_inlist](@list varchar(7000),@cate int) returns int
as begin
	--Ȩ���б��Ƿ����Ԫ���ж�
	return  case when len(@list) = 0 or charindex(','+cast(@cate as varchar(12)) + ',',@list)>0  then 1 else 0 end
end

GO

CREATE  function [dbo].[erp_ReplaceChr0](@instr as nvarchar(4000)) returns nvarchar(4000)
as
begin
	declare @len as int,@tmpchr as nvarchar(1),@pos as int,@returnValue nvarchar(4000)
	set @len=datalength(@instr)
	set @pos=1
	set @returnValue=''
	while(@len>0 and @pos<=@len)
	begin
		set @tmpchr = substring(@instr,@pos,1)
		if @tmpchr<> char(0)
		begin
			set @returnValue=@returnValue+@tmpchr
		end
		set @pos=@pos+1
	end
	return @returnValue
end

GO

create function [dbo].[erp_sms_getsurname](@name varchar(24),@sex varchar(12),@job varchar(100),@type int) returns varchar(100)
as begin
	declare @nm varchar(2)
	declare @r varchar(50)  --1=�Ա� 2=ְλ 3 = ���� 4=����+ְ��
	set @nm = substring(isnull(@name,'') + ' ',1,1)  --��ȡ��
	set @r = case @type
			 when 1 then  @nm + (case @sex when '��' then '����' else 'С��' end)
			 when 2 then  @nm + @job
			 when 3 then  @name
			 when 4 then  @name + @job
			 else ''
			 end
	return @r
end
GO





CREATE function [dbo].[erp_sp_getSpTypeText](@spType bit)
returns varchar(200)
as begin  --�����������͵ı�ʶ������ȡ��Ӧhtml��ʾ��
	declare @html varchar(200)
	if abs(@spType) = 1  or @spType > =3
		begin
		set @html = '<span class=c_g>����ͨ��</span>'
		end
	else
		begin
		set @html = '<span class=c_r>����δͨ��</span>'
		end


	return @html
end

GO

CREATE function [dbo].[eval](
	@sql varchar(4000)
) returns money
as begin
	declare @maxI int
	declare @i int
	declare @ii int
	declare @endindex int
	declare @childSql varchar(4000)
	declare @tm varchar(1)
	declare @r money
	declare @tb table(ord int, v varchar(20))
	declare @si int
	declare @ei int
	declare @tmpv decimal(25, 12)
	set @maxI = 1000
	set @sql = replace(@sql,' ','')
	if charindex('e',@sql)>0 
	begin
		return 0;
	end
	while(charindex('(',@sql)>0 and  @maxI >0)
	begin
		set @si = len(@sql) - charindex('(',reverse(@sql))  --4+(((1+3)/2+(5+6)*8)+10*9)-6
		set @ei = charindex(')',right(@sql,len(@sql)- @si))
		set @childSql = substring(@sql, @si+1, @ei)
		set @sql  = replace(@sql,@childSql,cast(dbo.eval(substring(@childSql,2,len(@childSql)-2)) as decimal(25, 12)))
		set @maxI =  @maxI - 1
	end

	--������ʽ
	if(isnumeric(@sql)=1)
	begin
		set @r = cast(@sql as decimal(25, 12))
	end
	else
	begin
		set @r = 0
		set @maxI = len(@sql)
		set @i = 1
		set @ii = 0
		while(@I<@maxI)
		begin
			set @tm = substring(@sql,@i,1)
			if @tm = '+' or  @tm = '-' or @tm = '*' or  @tm = '/'
			begin
				set @ii = @ii + 1
				insert into @tb(ord,v) values ( @ii , ltrim(substring(@sql,1,@i-1)))
				set @ii = @ii + 1
				insert into @tb(ord,v) values ( @ii , ltrim(substring(@sql,@i,1)))
				set @sql = left(cast('' as char(1000)),@i) + right(@sql,@maxI-@i)
			end
			set @i = @i + 1
		end
		if isnumeric(ltrim(@sql)) = 1
		begin
			insert into @tb(ord,v) values ( @ii+1 ,ltrim(@sql))
		end

		---���������ű��ʽ
		select @maxI = max(ord) from @tb
		set @i = 1
		while(@i < @maxI)
		begin
			update @tb set v = '0' where v=''
			if(exists(select ord from @tb where v='*' and ord=@i))
			begin
				update @tb set v = 
					cast(
							cast(
									(select top 1 (case isnumeric(v) when 0 then cast(0 as  decimal(25, 12)) else cast(v as decimal(25, 12)) end)  from @tb where ord=@i-1)
									*(select top 1 (case isnumeric(v) when 0 then cast(0 as  decimal(25, 12)) else cast(v as decimal(25, 12)) end)  from @tb where ord=@i+1)
								as varchar(50) ) 
						as varchar(20))
				where ord = @i+1

				delete @tb  where ord =@i or ord = @i-1
			end
			if(exists(select ord from @tb where v='/' and ord=@i))
			begin
				set @tmpv = (select top 1 (case isnumeric(v) when 0 then cast(0 as  decimal(25, 12)) else cast(v as decimal(25, 12)) end) from @tb where ord=@i+1);
				if @tmpv= 0
				begin
					return 0;
				end
				update @tb set v =
					cast(
							cast(
									(select top 1 (case isnumeric(v) when 0 then cast(0 as  decimal(25, 12)) else cast(v as decimal(25, 12)) end) from @tb where ord=(@i-1))
									/@tmpv 
								as varchar(50))
						as varchar(20)) 
				where ord = @i+1

				delete @tb  where ord =@i or ord = @i-1
			end
			set @i = @i+1
		end

		update @tb set v = '-' + v from(
				select b.ord as o, min(a.ord-b.ord) as m from @tb a ,@tb b where a.ord>b.ord and a.v <> '-' and b.v='-' group by b.ord
			) x where ord = x.o+x.m
		select @r = sum(cast((case isnumeric(v) when 0 then cast(0 as  decimal(25, 12)) else cast(v as decimal(25, 12)) end) as decimal(25, 12))) from @tb where v <> 'NULL' and v<>'-' and v<> '+' and  v <> '-NULL'
	end
	return @r
end

GO

create FUNCTION [dbo].[fnEncode]
(
@Input varchar(1000)
)
Returns varchar(8000)
AS
Begin
Declare @BASE64 char(64)
Set @BASE64 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
  Declare @cCode varchar(8000) --���ص�ֵ
Declare @nByte1 smallint,@nByte2 smallint,@nByte3 smallint
Declare @nBit1 smallint,@nBit2 smallint
Declare @cChar1 char(1),@cChar2 char(1),@cChar3 char(1),@cChar4 char(1)
  Declare @nLen smallint --�����ִ����L��
  Declare @cItem nvarchar(4000) --��ԃ�����ĳ���~
Declare @cTmp nvarchar(4000) --�R�r�惦�Ĕ���

--������aһλ�����ǲ�̎��
If Len(@Input) % 3 > 0 Set @Input = @Input + Right(' ?',(3-(Len(@Input) % 3))+1)
Set @cCode = ''
Set @cTmp = @Input
Set @cItem = @Input
Set @nLen = Len(@cTmp)

  While @nLen > 2
Begin
--�õ�һ��item����
Set @cItem = SubString(@cTmp,1,3)
Set @cTmp = SubString(@cTmp,4,@nLen)
Set @nLen = Len(@cTmp)
Set @nByte1 = ASCII(SubString(@cItem,1,1))
Set @nByte2 = ASCII(SubString(@cItem,2,1))
Set @nByte3 = ASCII(SubString(@cItem,3,1))
Set @nBit1 = @nByte1 & 3
Set @nBit2 = @nByte2 & 15

Set @cChar1 = SubString(@BASE64,(@nByte1 & 252)/4+1,1)
Set @cChar2 = SubString(@BASE64,(((@nByte2 & 240)/16) | (@nBit1 * 16) & 255) + 1 ,1)
Set @cChar3 = SubString(@BASE64,(((@nByte3 & 192)/64) | (@nBit2 * 4) & 255) + 1 ,1)
Set @cChar4 = SubString(@BASE64,(@nByte3 & 63)+1,1)
Set @cCode = @cCode + @cChar1 + @cChar2 + @cChar3 + @cChar4
End
--��������Ĕ���
Return @cCode
End
GO


create function [dbo].[eval_canzero](@sql varchar(4000)) returns money
as begin
declare @maxI int
declare @i int
declare @ii int
declare @endindex int
declare @childSql varchar(4000)
declare @tm varchar(1)
declare @r decimal(25, 12)
declare @tb table(ord int, v varchar(25))
declare @si int
declare @ei int
set @maxI = 1000
set @sql = replace(@sql,' ','')
while(charindex('(',@sql)>0 and  @maxI >0)
begin
set @si = len(@sql) - charindex('(',reverse(@sql))  --4+(((1+3)/2+(5+6)*8)+10*9)-6
set @ei = charindex(')',right(@sql,len(@sql)- @si))
set @childSql = substring(@sql, @si+1, @ei)
set @sql  = replace(@sql,@childSql,cast(dbo.eval(substring(@childSql,2,len(@childSql)-2)) as varchar(4000)))
set @maxI =  @maxI - 1
end
--������ʽ
if(isnumeric(@sql)=1)
begin
set @r = cast(@sql as decimal(25, 12))
end
else
begin
set @r = 0
set @maxI = len(@sql)
set @i = 1
set @ii = 0
while(@I<@maxI)
begin
set @tm = substring(@sql,@i,1)
if @tm = '+' or  @tm = '-' or @tm = '*' or  @tm = '/'
begin
set @ii = @ii + 1
insert into @tb(ord,v) values ( @ii , ltrim(substring(@sql,1,@i-1)))
set @ii = @ii + 1
insert into @tb(ord,v) values ( @ii , ltrim(substring(@sql,@i,1)))
set @sql = left(cast('' as char(1000)),@i) + right(@sql,@maxI-@i)
end
set @i = @i + 1
end
if isnumeric(ltrim(@sql)) = 1
begin
insert into @tb(ord,v) values ( @ii+1 ,ltrim(@sql))
end
---���������ű��ʽ
select @maxI = max(ord) from @tb
set @i = 1
while(@i < @maxI)
begin
if(exists(select ord from @tb where v='*' and ord=@i))
begin
update @tb set v = cast((select top 1 cast(v as decimal(25, 12)) from @tb where ord=@i-1)*(select top 1 cast(v as decimal(25, 12)) from @tb where ord=@i+1)  as varchar(25)) where ord = @i+1
delete @tb  where ord =@i or ord = @i-1
end
if(exists(select ord from @tb where v='/' and ord=@i))
begin
update @tb set v = CASE WHEN (select top 1 cast(v as decimal(25, 12)) from @tb where ord=@i+1)=0 THEN '0' ELSE cast((select top 1 cast(v as decimal(25, 12)) from @tb where ord=(@i-1))/(select top 1 cast(v as decimal(25, 12)) from @tb where ord=@i+1)  as varchar(25)) end where ord = @i+1
delete @tb  where ord =@i or ord = @i-1
end
set @i = @i+1
end
update @tb set v = '-' + v from(
select b.ord as o, min(a.ord-b.ord) as m from @tb a ,@tb b where a.ord>b.ord and a.v <> '-' and b.v='-'
group by b.ord
) x where ord = x.o+x.m
select @r = sum(cast(v as decimal(25, 12))) from @tb where v <> 'NULL' and v<>'-' and v<> '+' and  v <> '-NULL'
end
return @r
end
GO


create function [dbo].[formatNum](@v int,@wCount int)
returns varchar(20)  --@vҪ��ʽ����ֵ��Ҫ��ʽ����λ��
as begin
	declare @r varchar(20)
	set @r = cast(@v as varchar(12))
	set @r = left('0000000000000000',@wCount - len(@r)) + @r
	return @r
end
GO

CREATE FUNCTION [dbo].[erp_XLong_GetAllAreaNameByMinAreaId]
(
	@MinAreaId int,
	@UnStr varchar(10)
)
RETURNS varchar(5000)
AS
BEGIN
	declare @myid int,@mymenuname varchar(5000)
	Select @myid = id1 from menuarea where id = @MinAreaId
	Select @mymenuname = menuname from menuarea where id = @MinAreaId
	while @myid > 0
		Select @myid = id1,
		@mymenuname = menuname + @UnStr + @mymenuname
		from menuarea where id = @myid
	RETURN @mymenuname
END

GO

create FUNCTION [dbo].[erp_XLong_GetAllChildnodesAreaIdByMaxAreaId]
(
	@MaxAreaIdList varchar(5000)
)
RETURNS varchar(5000)
AS
BEGIN
declare @AllChildnodesArreaId varchar(5000),@thisTempId int
declare cur_1 cursor for Select id from menuarea
where charindex(',' + convert(varchar(50),id) + ',',','+@MaxAreaIdList+',')>0
and id not in (Select id1 from menuarea
where charindex(',' + convert(varchar(50),id) + ',',','+@MaxAreaIdList+',')>0)
open cur_1
fetch next from cur_1 into @thisTempId
If(@@fetch_status=0)
	Set @AllChildnodesArreaId =  convert(varchar(50),@thisTempId)
Else
	RETURN '0'
fetch next from cur_1 into @thisTempId
while @@fetch_status=0
begin
	Set @AllChildnodesArreaId = @AllChildnodesArreaId + ',' + convert(varchar(50),@thisTempId)
	fetch next from cur_1 into @thisTempId
end
close cur_1
deallocate cur_1
If Exists(Select a.id from menuarea as a left join menuarea as b on b.id1 = a.id
	Where b.id Is Not Null and charindex(',' + convert(varchar(50),a.id) + ',',','+
	@AllChildnodesArreaId+',')>0) Begin
	Declare @ChildnodesIDTempList varchar(5000)
	declare cur_2 cursor for Select a.id from menuarea as a left join menuarea as b on b.id1 = a.id
		Where b.id Is Not Null and charindex(',' + convert(varchar(50),a.id) + ',',','+
		@AllChildnodesArreaId+',')>0
	open cur_2
	fetch next from cur_2 into @thisTempId
	If(@@fetch_status=0)
		Set @ChildnodesIDTempList =  convert(varchar(50),@thisTempId)
	fetch next from cur_2 into @thisTempId
	while @@fetch_status=0
	begin
		Set @ChildnodesIDTempList = @ChildnodesIDTempList + ',' + convert(varchar(50),@thisTempId)
		fetch next from cur_2 into @thisTempId
	end
	close cur_2
	deallocate cur_2
	declare cur_1 cursor for Select id from menuarea
	where charindex(',' + convert(varchar(50),id1) + ',',','+@ChildnodesIDTempList+',')>0
	open cur_1
	fetch next from cur_1 into @thisTempId
	while @@fetch_status=0
	begin
		Set @AllChildnodesArreaId = @AllChildnodesArreaId + ',' + convert(varchar(50),@thisTempId)
		fetch next from cur_1 into @thisTempId
	End
	close cur_1
	deallocate cur_1
	Set @AllChildnodesArreaId = dbo.[erp_XLong_GetAllChildnodesAreaIdByMaxAreaId](@AllChildnodesArreaId)
End
RETURN @AllChildnodesArreaId
END

Go

CREATE  function [dbo].[formatNumber](@v decimal(25, 12), @wCount int, @ty int)
returns varchar(40)  --@v=Ҫ��ʽ����С���� @wCount=Ҫ��ʽ����λ��, @ty=��ʽ����ʽ,0 ��ʾ����, 1��ʾ����0
as
begin
	declare @r varchar(30)
	set @r = cast(cast(round(@v,@wCount) as decimal(25, 12)) as varchar(40))
	if  @ty  = 0
	begin
		If @wCount <= 0
			Set @wCount = -1
		set @r = left(@r, len(@r)-(12-@wCount))
	end
	else
	begin
		set @r = replace(rtrim(replace(@r,'0',' ')),' ','0')
		IF RIGHT(@r,1)='.'
			set @r = replace(rtrim(replace(@r,'.',' ')),' ','.')
	end
	return @r
end

GO

CREATE FUNCTION [dbo].[erp_XLong_GetAllChildnodesMenuIdByMaxMenuId](@MaxMenuIdList varchar(5000))RETURNS varchar(5000)
AS
BEGIN
declare @AllChildnodesMenuId varchar(5000),@thisTempId int
declare cur_1 cursor for Select id from menu
where charindex(',' + convert(varchar(50),id) + ',',','+@MaxMenuIdList+',')>0
and id not in (Select id1 from menu
where charindex(',' + convert(varchar(50),id) + ',',','+@MaxMenuIdList+',')>0)
open cur_1
fetch next from cur_1 into @thisTempId
If(@@fetch_status=0)
	Set @AllChildnodesMenuId =  convert(varchar(50),@thisTempId)
Else
	RETURN '0'
fetch next from cur_1 into @thisTempId
while @@fetch_status=0
begin
	Set @AllChildnodesMenuId = @AllChildnodesMenuId + ',' + convert(varchar(50),@thisTempId)
	fetch next from cur_1 into @thisTempId
end
close cur_1
deallocate cur_1
If Exists(Select a.id from menu as a left join menu as b on b.id1 = a.id
	Where b.id Is Not Null and charindex(',' + convert(varchar(50),a.id) + ',',','+
	@AllChildnodesMenuId+',')>0) Begin
	Declare @ChildnodesIDTempList varchar(5000)
	declare cur_2 cursor for Select a.id from menu as a left join menu as b on b.id1 = a.id
		Where b.id Is Not Null and charindex(',' + convert(varchar(50),a.id) + ',',','+
		@AllChildnodesMenuId+',')>0
	open cur_2
	fetch next from cur_2 into @thisTempId
	If(@@fetch_status=0)
		Set @ChildnodesIDTempList =  convert(varchar(50),@thisTempId)
	fetch next from cur_2 into @thisTempId
	while @@fetch_status=0
	begin
		Set @ChildnodesIDTempList = @ChildnodesIDTempList + ',' + convert(varchar(50),@thisTempId)
		fetch next from cur_2 into @thisTempId
	end
	close cur_2
	deallocate cur_2
	declare cur_1 cursor for Select id from menu
	where charindex(',' + convert(varchar(50),id1) + ',',','+@ChildnodesIDTempList+',')>0
	open cur_1
	fetch next from cur_1 into @thisTempId
	while @@fetch_status=0
	begin
		Set @AllChildnodesMenuId = @AllChildnodesMenuId + ',' + convert(varchar(50),@thisTempId)
		fetch next from cur_1 into @thisTempId
	End
	close cur_1
	deallocate cur_1
	Set @AllChildnodesMenuId = dbo.[erp_XLong_GetAllChildnodesMenuIdByMaxMenuId](@AllChildnodesMenuId)
End
RETURN @AllChildnodesMenuId
END

GO

CREATE function [dbo].[fun_getPY](@str nvarchar(3000))
      returns nvarchar(3000)
      as
      begin
      declare @word nchar(1)
	  declare @PY nvarchar(3000)
      set @PY=''
      while len(@str)>0
      begin
		  set @word=left(@str,1)
		  --����Ǻ����ַ�������ԭ�ַ�
		  set @PY=@PY+(case when unicode(@word) between 19968 and 19968+20901
		  then (
		  select top 1 PY
		  from
		  (
			  select 'A' as PY,N'�' as word
			  union all select 'B',N'��'
			  union all select 'C',N'�e'
			  union all select 'D',N'�z'
			  union all select 'E',N'��'
			  union all select 'F',N'�v'
			  union all select 'G',N'�B'
			  union all select 'H',N'��'
			  union all select 'J',N'�h'
			  union all select 'K',N'�i'
			  union all select 'L',N'�w'
			  union all select 'M',N'��'
			  union all select 'N',N'��'
			  union all select 'O',N'�a'
			  union all select 'P',N'��'
			  union all select 'Q',N'��'
			  union all select 'R',N'�U'
			  union all select 'S',N'�R'
			  union all select 'T',N'�X'
			  union all select 'W',N'�F'
			  union all select 'X',N'�R'
			  union all select 'Y',N'�'
			  union all select 'Z',N'��'
		  ) T
		  where word>=@word collate Chinese_PRC_CS_AS_KS_WS
		  order by PY ASC
		  )
		  else @word
		  end)
		  set @str=right(@str,len(@str)-1)
      end
      return @PY
end

GO

CREATE function [dbo].[erp_report_getcpProccText](@p money,@p1 money)
returns varchar(100)
as begin
	declare @l  money
	set @l = case @p1 when 0 then 0 else @p/@p1 end  --��ɱ��� /ʱ������
	declare @r varchar(100)
	set @r = case
				when @p>0 and @p1<=0 then '<span style="color:#00bb00">���ȳ�ǰ</span>'
				when @p1 > 1 then
					case
						when @l<1 and @l > 0.9 then '<span style="color:#fB7CAE">����</span>'
						when @l<=0.9 and @l > 0.6 then '<span style="color:#fB3C5E">�жȳ���</span>'
						when @l<=0.6 and @l>=0 then '<span style="color:#ff0000">���س���</span>'
						else ''
					end
				when @p1 <=1 and @p1>0 then
					case
						when @l >2 then '<span style="color:#00aa00">�ǳ���</span>'
						when @l<=2 and @l>1.6 then '<span style="color:#009900">�ܿ�</span>'
						when @l<=1.6 and @l>1.2 then '<span style="color:#008800">��</span>'
						when @l<=1.2 and @l >1 then '<span style="color:#007700">�Ͽ�</span>'
						when @l<=1 and @l > 0.9 then '<span style="color:#006600">����'
						when @l<=0.9 and @l > 0.6 then '<span style="color:#8888cc">����</span>'
						when @l<=0.6 and @l>0.2 then '<span style="color:#6666dd">��</span>'
						when @l<=0.2 and @l >= 0 then '<span style="color:#4444ff">�ǳ���</span>'
						else ''
					end
				else ''
			  end
	set @r = @r --+ '|' + cast(@l as varchar(10))
	return @r
end

GO

CREATE function [dbo].[erp_getProductPrice](
	@ProductID int,
	@unit int,
	@uid int
) returns money
begin
	--��ȡ��Ʒ�ɹ���
	--����Ϊ��ƷID���û�ID
	set @ProductID = abs(@ProductID)
	set @unit=isnull(@unit,0)
	declare @Price as money
		
	declare @openset int
	select @openset = intro from setopen  where sort1=1202 --BUG.2678.binary.2013.10.20 �øú���ȡֵӦ�ü۸��������
	set @openset = isnull(@openset,1) --1 ��ʾĬ��ȡ��ʷ, 2 ��ʾĬ��ȡ����۸�
	 
	--��ȡ�ɹ��۸���� ���òɹ���ʷ�����ܲɹ���Ա����
	DECLARE @sort320173106 INT
	SET @sort320173106=1
	select @sort320173106=isnull(intro,1) from setopen where sort1=320173106

	if (@openset = 1)
	begin
		select top 1 @Price=a.Price1 
		from (
			select cl.Price1,cl.date7 , 1 as priceType 
			from caigoulist cl
			inner join caigou cg on cl.caigou=cg.ord and cg.del=1
			inner join product p on p.ord = cl.ord AND (ISNULL(p.company,0)=0 OR cl.company=p.company)
			where cl.ord=@ProductID and cl.unit=@unit and cl.del=1 and (@sort320173106<>1 or cg.cateid=@uid) 
		) a
		order by a.priceType asc, a.date7 desc
	end
	
	if isnull(@Price,-1)=-1
	begin
		declare @sorce_user as int
		select @sorce_user=ISNULL(pricesorce,0) from gate where ord=@uid
		set @sorce_user=isnull(@sorce_user,0)	
		select @Price=price1jy from jiage where product=@ProductID and unit=@unit and bm=@sorce_user 
		if isnull(@Price,-1)=-1
		begin
			select @Price=price1jy from jiage where product=@ProductID and unit=@unit and bm=0
		end
	end
	return isnull(@Price,0)
end
GO

CREATE FUNCTION [dbo].[Check_Product](@Pro_id INT)
RETURNS VARCHAR(200)
AS
BEGIN
	DECLARE @ReBool INT,@Retext VARCHAR(200)
	SET @Retext=''
	--��Ŀ���
	if exists(SELECT * FROM chancelist WHERE ord=@Pro_id  AND DEL<>7)
	BEGIN
	set @Retext=@Retext+'1,'
	END
	--����
	if exists(SELECT * FROM pricelist WHERE ord=@Pro_id  AND DEL<>7)
	BEGIN
		set @Retext=@Retext+'2,'
	END
	--��ͬ
	if exists(SELECT * FROM CONTRACTlist WHERE ord=@Pro_id  AND DEL<>7)
	BEGIN
		set @Retext=@Retext+'3,'
	END
	----�����˻�
	if exists(SELECT * FROM contractthlist WHERE ord=@Pro_id  AND DEL<>7)
	BEGIN
		set @Retext=@Retext+'4,'
	END
	----Ԥ��
	if exists(SELECT * FROM caigoulist_yg WHERE ord=@Pro_id  AND DEL<>7)
	BEGIN
		set @Retext=@Retext+'5,'
	END
	----ѯ��
	if exists(SELECT * FROM xunjialist WHERE ord=@Pro_id  AND DEL<>7)
	BEGIN
		set @Retext=@Retext+'6,'
	END
	----�ɹ�
	if exists(SELECT * FROM caigoulist WHERE ord=@Pro_id  AND DEL<>7)
	BEGIN
		set @Retext=@Retext+'7,'
	END
	----�ɹ��˻�
	if exists(SELECT * FROM caigouthlist WHERE ord=@Pro_id  AND DEL<>7)
	BEGIN
		set @Retext=@Retext+'8,'
	END
	----���--
	if exists(SELECT * FROM kuinlist WHERE ord=@Pro_id  AND DEL<>7)
	BEGIN
		set @Retext=@Retext+'9,'
	END
	--����--
	if exists(SELECT * FROM kuoutlist WHERE ord=@Pro_id  AND DEL<>7)
	BEGIN
		set @Retext=@Retext+'10,'
	END
	--����--
	if exists(SELECT * FROM kumovelist WHERE ord=@Pro_id  AND DEL<>7)
	BEGIN
		set @Retext=@Retext+'11,'
	END
	--�̵�--
	if exists(SELECT * FROM kupdlist WHERE ord=@Pro_id  AND DEL<>7)
	BEGIN
		set @Retext=@Retext+'12,'
	END
	--���--
	if exists(SELECT * FROM kujhlist WHERE ord=@Pro_id  AND DEL<>7)
	BEGIN
		set @Retext=@Retext+'13,'
	END
	--��װ--
	if exists(SELECT * FROM kuoutlist2 WHERE ord=@Pro_id  AND DEL<>7)
	BEGIN
		set @Retext=@Retext+'14,'
	END
	--��װ�嵥
	if exists(SELECT * FROM bomlist WHERE ord=@Pro_id  AND DEL<>7)
	BEGIN
		set @Retext=@Retext+'15,'
	END
	--����
	if exists(SELECT * FROM sendlist WHERE ord=@Pro_id  AND DEL<>7)
	BEGIN
		set @Retext=@Retext+'16,'
	END
	--Ԥ�ⵥ
	if exists(SELECT * FROM M_PredictOrderLists WHERE ProductID=@Pro_id  AND DEL<>7)
	BEGIN
		set @Retext=@Retext+'17,'
	END
	----�����ƻ�
	if exists(SELECT * FROM M_ManuPlanLists WHERE ProductID=@Pro_id  AND DEL<>7)
	BEGIN
		set @Retext=@Retext+'18,'
	END
	----��������
	if exists(SELECT * FROM M_ManuOrderLists WHERE ProductID=@Pro_id  AND DEL<>7)
	BEGIN
		set @Retext=@Retext+'19,'
	END
	----�����嵥
	if exists(SELECT * FROM M_PlanBomList WHERE ProductID=@Pro_id) 
	BEGIN
		set @Retext=@Retext+'20,'
	END
	----�´�
	if exists(SELECT * FROM M_ManuOrderIssuedLists WHERE ProductID=@Pro_id  AND DEL<>7)
	BEGIN
		set @Retext=@Retext+'21,'
	END
	----�ɹ�
	if exists(SELECT * FROM M_WorkAssignLists WHERE ProductID=@Pro_id  AND DEL<>7)
	BEGIN
		set @Retext=@Retext+'22,'
	END
	----����-����-����-����
	if exists(SELECT * FROM M_MaterialOrderLists WHERE ProductID=@Pro_id  AND DEL<>7)
	BEGIN
		set @Retext=@Retext+'23,'
	END
	----���ϵ���
	if exists(SELECT * FROM M_MaterialMoveLists WHERE ProductID=@Pro_id)
	BEGIN
		set @Retext=@Retext+'24,'
	END
	----ί����ϸ
	if exists(SELECT * FROM M_OutOrderlists WHERE ProductID=@Pro_id  AND DEL<>7)
	BEGIN
		set @Retext=@Retext+'25,'
	END
	if exists(SELECT * FROM M_OutOrderlists_wl WHERE ProductID=@Pro_id  AND DEL<>7)
	BEGIN
		set @Retext=@Retext+'26,'
	END
	--�����嵥
	if exists(SELECT * FROM M_BOMList WHERE ProductID=@Pro_id  AND DEL<>7)
	   or exists(select 1 from dbo.M2_BOMList bl
	   INNER JOIN dbo.M2_BOM b ON bl.BOM = b.ID
	    WHERE b.billType = 1 AND bl.ProductID=@Pro_id)
	BEGIN
		set @Retext=@Retext+'27,'
	END
	--�����嵥���
	if exists(select 1 from dbo.M2_BOMList bl
	   INNER JOIN dbo.M2_BOM b ON bl.BOM = b.ID
	    WHERE b.billType = 0 AND bl.ProductID=@Pro_id)
	BEGIN
		set @Retext=@Retext+'57,'
	END
	--���ò�Ʒ
	if exists(SELECT * FROM M_WFProduct WHERE POrd=@Pro_id  AND DEL<>7)
	BEGIN
		set @Retext=@Retext+'28,'
	END
	--�����嵥
	if exists(SELECT * FROM M_PieceRate WHERE ProductID=@Pro_id  AND DEL<>7)
	BEGIN
		set @Retext=@Retext+'29,'
	END
	--��װ�嵥����ǿ��
	if exists(select top 1 ord from BOM_Structure_List where ProType = 1 and ProOrd =@Pro_id)
	BEGIN
		set @Retext=@Retext+'30,'
	END
	
	--Ԥ�����ƻ���ϸ
	if exists(select 1 from dbo.M2_ManuPlanListsPre where ProductID=@Pro_id)
	BEGIN
		set @Retext=@Retext+'31,'
	END
	--�����ƻ���ϸ
	 if exists(select 1 from dbo.M2_ManuPlanLists where ProductID=@Pro_id)  
      or exists(select 1 from dbo.M2_PlanBomList a
      inner join M2_ManuPlanLists b on a.MPLID=b.ID where a.ProductID=@Pro_id)  
      BEGIN  
        set @Retext=@Retext+'32,'  
      END  
	 --���Ϸ�����ϸ��  
 if exists(select 1 from dbo.M2_MaterialAnalysisList a
 inner join M2_MaterialAnalysis b on a.MASID=b.ID  where a.ProductID=@Pro_id and a.del=1 and b.del=1)  
 BEGIN  
  set @Retext=@Retext+'33,'  
 END  
	--�����Ų���ϸ��
	if exists(select 1 from dbo.M2_AbilityAnalysisList where ProductID=@Pro_id)
	BEGIN
		set @Retext=@Retext+'34,'
	END
	--����������ϸ��
	if exists(select 1 from dbo.M2_ManuOrderLists where ProductID=@Pro_id)
	BEGIN
		set @Retext=@Retext+'35,'
	END

	--�����ɹ��������ϡ������ɹ�
	if exists(select 1 from dbo.M2_WorkAssigns wa
				left join dbo.M2_WorkAssignLists wal on wal.WAID=wa.ID
			   where (wal.ProductID=@Pro_id or wa.ProductID=@Pro_id) and wa.ptype=0)
	BEGIN
		set @Retext=@Retext+'36,'
	END

	--����㱨
	if exists(select 1 from dbo.M2_ProcedureProgres pp
	inner join dbo.M2_WFP_Assigns wfa on pp.WFPAID = wfa.id
	inner join M2_WorkAssigns wa on wfa.WAID = wa.ID 
	where wa.ProductID=@Pro_id)
	BEGIN
		set @Retext=@Retext+'37,'
	END
	
	--��������,����������ϸ
	if exists(select 1 from dbo.M2_WorkAssigns wa
				left join dbo.M2_WorkAssignLists wal on wal.WAID=wa.ID
			   where (wal.ProductID=@Pro_id or wa.ProductID=@Pro_id) and wa.ptype=1)
	BEGIN
		set @Retext=@Retext+'38,'
	END
	
    --����������ϸ��
    if exists(select 1 from dbo.M2_MaterialOrderLists mol where mol.ProductID=@Pro_id)
    BEGIN
		set @Retext=@Retext+'39,'
	END

	--��������
	if exists(select 1 from dbo.M2_MaterialRegisterLists mrl
	inner join dbo.M2_MaterialRegisters mr on mrl.MRID=mr.ID
	where mr.OrderType=2 and mrl.ProductID=@Pro_id)
	BEGIN
		set @Retext=@Retext+'40,'
	END
	--��������
	if exists(select 1 from dbo.M2_MaterialRegisterLists mrl
	inner join dbo.M2_MaterialRegisters mr on mrl.MRID=mr.ID
	where mr.OrderType=3 and mrl.ProductID=@Pro_id)
	BEGIN
		set @Retext=@Retext+'41,'
	END
	--���ϵǼ�
	if exists(select 1 from dbo.M2_MaterialRegisterLists mrl
	inner join dbo.M2_MaterialRegisters mr on mrl.MRID=mr.ID
	where mr.OrderType=1 and mrl.ProductID=@Pro_id)
	BEGIN
		set @Retext=@Retext+'42,'
	END
	--����ί��
	if exists(select 1 from dbo.M2_OutOrderlists ool
	inner join dbo.M2_OutOrder oo on ool.outID=oo.ID 
	where ool.productid=@Pro_id and oo.wwType=0)
	or exists(select 1 from dbo.M2_OutOrderlists_wl oolw
	inner join dbo.M2_OutOrder oo on oolw.outID=oo.ID
	where oolw.productid=@Pro_id and oo.wwType=0)
	BEGIN
		set @Retext=@Retext+'43,'
	END
	
	--����ί��
	if exists(select 1 from dbo.M2_OutOrderlists ool
	inner join dbo.M2_OutOrder oo on ool.outID=oo.ID 
	where ool.productid=@Pro_id and oo.wwType=1)
	or exists(select 1 from dbo.M2_OutOrderlists_wl oolw
	inner join dbo.M2_OutOrder oo on oolw.outID=oo.ID
	where oolw.productid=@Pro_id and oo.wwType=1)
	BEGIN
		set @Retext=@Retext+'44,'
	END
	
	--ί���ջ���ϸ
	if exists(select 1 from dbo.M2_ReceivingGoodList rgl where rgl.ProductId=@Pro_id)
	BEGIN
		set @Retext=@Retext+'45,'
	END
	
	--ί���ͼ���ϸ
	if exists(select 1 from dbo.M2_OutsourceInspectionList oil where oil.ProductId=@Pro_id)
	BEGIN
		set @Retext=@Retext+'46,'
	END
	
	--ί�ⷵ����ϸ
	if exists(select 1 from dbo.M2_OutsourcingReworkList where ProductID=@Pro_id)
	BEGIN
		set @Retext=@Retext+'47,'
	END

    --�����ʼ�
	if exists(select 1 from dbo.erp_m2wfpa_Nodes_ExecStatus emne
	INNER JOIN dbo.M2_WorkAssigns wa ON wa.ptype = 0 AND emne.WAID = wa.ID AND wa.del = 1 AND ISNULL(wa.[Status],1) in(1,-1)
	where wa.ProductID=@Pro_id)
	BEGIN
		set @Retext=@Retext+'56,'
	END

	--�ɹ��ʼ�
	if exists(select 1 from dbo.M2_QualityTestingLists qtl 
	inner join dbo.M2_QualityTestings qt on qtl.QTID=qt.ID
	inner join dbo.M2_WorkAssigns wa on qtl.bid=wa.ID
	where qt.poType in(3,4) and wa.ProductID=@Pro_id)
	BEGIN
		set @Retext=@Retext+'48,'
	END

	--ί���ʼ�
	if exists(select 1 from dbo.M2_QualityTestingLists qtl 
	inner join dbo.M2_QualityTestings qt on qtl.QTID=qt.ID
	inner join M2_OutOrderlists mol on qtl.bid = mol.ID
	where qt.poType in(1,2) and mol.ProductID=@Pro_id)
	BEGIN
		set @Retext=@Retext+'49,'
	END
	
	--�ɱ�����
	if exists(select 1 from dbo.M2_CostComputationList ccl where ccl.ProductID=@Pro_id)
	BEGIN
		set @Retext=@Retext+'50,'
	END

	--�Ƽ�����
	if exists(select 1 from dbo.M2_WageList_JJ wlj where wlj.productID=@Pro_id)
	BEGIN
		set @Retext=@Retext+'51,'
	END

	--�Ƽ�����
	if exists(select 1 from dbo.M2_PriceRateList prl where del = 1 and prl.productID=@Pro_id)
	BEGIN
		set @Retext=@Retext+'52,'
	END

	--��������
	if exists(select 1 from dbo.M2_WFProduct wfp where wfp.POrd=@Pro_id)
	BEGIN
		set @Retext=@Retext+'53,'
	END

	--�������
	if exists(select 1 from dbo.M2_BOMRelation br where br.productID=@Pro_id)
	BEGIN
		set @Retext=@Retext+'54,'
	END
	--���к�
	if exists(select 1 from dbo.M2_SerialNumberMain snm where snm.ProductID=@Pro_id)
	BEGIN
		set @Retext=@Retext+'55,'
	END

    --��װ�嵥��???�����������
    
	IF @Retext!=''
	BEGIN
		SET @Retext=','+@Retext
	END
	RETURN @Retext
END

GO

CREATE function [dbo].[erp_WAMListStatus](@WAID int,@poType int)
returns table as return(
	--��ȡ�ɹ���������ʹ�����
	--�졢�� + �ˡ��� + �� + ��
	--@WAID  �ɹ������߷��ⵥ��
	--@poType ���ɹ�= 0   ����=1
	select
		f.ord as ��ƷID,f.unit as ��λ,
		e.num1 as ����,
		case d.ordertype
		when 1 then '��'
		when 2 then '��'
		when 3 then '��'
		when 4  then '��'
		else '?' end as ��������,
		1 as t,
		a.MorderID as ddno,
		a.ID as �ɹ�ID, b.ID as �ɹ���ϸID,c.ID as ����������ϸID,
		d.id as ��������ID,e.id as kuoutlist2,f.kuinlist as kuinlist , f.id as  ku, d.ordertype as oType,
		c.num1 as ��������
	from  M_WorkAssigns a
	inner join  M_WorkAssignlists b on a.ID=b.WAID and (a.ID=@WAID or @WAID=0)
	inner join  M_MaterialOrderLists c on b.ID = c.WAListID
	inner join  M_MaterialOrders d on c.MOID = d.ID and d.poType=@poType
	inner join  kuoutlist2 e on c.id = e.MorderID
	inner join  ku f on f.id = e.ku

	union all

	select
		c.productid as ��ƷID,c.unit as ��λ,
		isnull(e.num1,c.num1) as ����,
		case d.ordertype
		when 1 then '��'
		when 2 then '��'
		when 3 then '��'
		when 4  then '��'
		else '?' end as ��������,
		-1 as t,
		a.MorderID as ddno,
		a.ID as �ɹ�ID, b.ID as �ɹ���ϸID,c.ID as ����������ϸID,
		d.id as ��������ID,c.kuoutlist2,e.id as kuinlist , f.id as  ku , d.ordertype as oType ,0
	from M_WorkAssigns a
	inner join  M_WorkAssignlists b on a.ID=b.WAID and (a.ID=@WAID or @WAID=0)
	inner join  M_MaterialOrderLists c on b.ID = c.WAListID
	inner join  M_MaterialOrders d on c.MOID = d.ID and d.poType=@poType and d.del=0 and d.ordertype>2
	left join  kuinlist e on c.id = e.MorderID
	left join  ku f on f.kuinlist = e.id

	union all

	select
		e.productID,e.unit,c.num1,'��',-1,a.ddno, a.WAID,0,
		c.ID as ����������ϸID,d.ID,c.kuoutlist2,0,0, 5 as oType ,0
	from M_MaterialProgres a
	inner join M_MaterialProgresDetail b on b.MPID = a.ID and a.WAID=@WAID
	inner join M_MaterialProgresRawLists c on c.MPDID = b.ID
	inner join M_MaterialProgresRaws d on d.ID = c.MPRID and d.del=0
	inner join M_planbomlist e on c.bomlist = e.id

	union all

	select b.productID,b.unit,b.num,'��',-1,a.ddno,a.WAID,0,b.ID,a.ID,b.kuoutlist2,0,0,6,0
	from M_MaterialMove a
	inner join M_MaterialMovelists b on a.ID = b.MMID and a.WAID=@WAID
	where  a.del=0

	union all

	select b.productID,b.unit,b.num,'��',1,a.newddno,a.newWAID,0,b.ID,a.ID,b.kuoutlist2,0,0,7,0
	from M_MaterialMove a
	inner join M_MaterialMovelists b on a.ID = b.MMID and a.newWAID=@WAID
	where a.status > 2 and a.del=0 and a.tempsave=0

	Union all

	select
		f.ord as ��ƷID,f.unit as ��λ,
		e.num1 as ����,
		case d.ordertype
		when 1 then '��'
		when 2 then '��'
		when 3 then '��'
		when 4  then '��'
		else '?' end as ��������,
		1 as t,
		a.Morder as ddno,
		a.ID as �ɹ�ID, b.ID as �ɹ���ϸID,c.ID as ����������ϸID,
		d.id as ��������ID,e.id as kuoutlist,f.kuinlist as kuinlist , f.id as  ku, d.ordertype+100 as oType ,0
	from   M_OutOrder   a
	inner join  M_OutOrderLists_WL  b on a.ID=b.outID and (a.ID=@WAID or @WAID=0)
	inner join  M_MaterialOrderLists c on b.ID = c.WAListID  and c.poType=@poType
	inner join  M_MaterialOrders d on c.MOID = d.ID and d.poType=@poType
	inner join  kuoutlist2 e on c.id = e.MorderID
	inner join  ku f on f.id = e.ku

	union all

	select
		c.productID as ��ƷID,c.unit as ��λ,
		isnull(e.num1,c.num1) as ����,
		case d.ordertype
		when 1 then '��'
		when 2 then '��'
		when 3 then '��'
		when 4  then '��'
		else '?' end as ��������,
		-1 as t,
		a.Morder as ddno,
		a.ID as �ɹ�ID, b.ID as �ɹ���ϸID,c.ID as ����������ϸID,
		d.id as ��������ID,c.kuoutlist2,e.id as kuinlist , f.id as  ku , d.ordertype+100 as oType ,0
	from  M_OutOrder  a
	inner join  M_OutOrderLists_WL b on a.ID=b.outID and (a.ID=@WAID or @WAID=0)
	inner join  M_MaterialOrderLists c on b.ID = c.WAListID and c.poType=@poType
	inner join  M_MaterialOrders d on c.MOID = d.ID and d.poType=@poType and d.del = 0 and d.ordertype>2
	left join  kuinlist e on c.id = e.MorderID
	left join  ku f on f.kuinlist = e.id
)
GO


CREATE function [dbo].[erp_list_MaterialListStatus](@WAID int,@sptType int , @sptId int)
returns table as return
(
	select
		WAID,��ƷID,sum(��) as ��,sum(��) as ��,sum(��) as ��,sum(��) as ��,sum(��) as ��,kuoutlist2
	from (
		select c.ord as ��ƷID, c.num1 as ��,0 as ��,0 as ��, 0 as ��, 0 as �� ,0 as ��,c.id as kuoutlist2, a.WAID
		 from M_MaterialOrders a
		inner join M_MaterialOrderlists b on b.MOID=a.ID and a.Ordertype=1 and  (a.WAID=@WAID or @WAID  = 0) and (@sptType<>1 or a.ID<> @sptId)
		inner join kuoutlist2 c on c.MorderId = b.id
		union all
		select c.ord,0,c.num1,0,0,0,0,c.id as kuoutlist2,  a.WAID from M_MaterialOrders a
		inner join M_MaterialOrderlists b on b.MOID=a.ID and a.Ordertype=2 and  (a.WAID=@WAID or @WAID  = 0) and (@sptType<>2 or a.ID<> @sptId)
		inner join kuoutlist2 c on c.MorderId = b.id
		union all	--��ȥ����
		select productid ,0,0,b.num1,0,0,0,b.kuoutlist2,a.WAID    from M_MaterialOrders a
		inner join M_MaterialOrderlists b on b.MOID=a.ID and a.Ordertype=3 and  a.del = 0 and  (a.WAID=@WAID or @WAID  = 0)  and (@sptType<>3 or a.ID<> @sptId)
		union all  --��ȥ����
		select productID,0,0,0,0,0,num,kuoutlist2,a.WAID  from M_MaterialMove a
		inner join M_MaterialMoveLists b on  b.MMID =a.ID and a.del = 0 and  (a.WAID=@WAID or @WAID  = 0) and (@sptType<>1 or a.ID<> @sptId)
		union all	--��ȥ����
		select d.ord,0,0,0,0,a.num1,0,kuoutlist2 , c.WAID from M_MaterialProgresRawLists a
		inner join M_MaterialProgresDetail b on a.MPDID= b.ID and a.del = 0 and (@sptType<>1 or a.MPRID<> @sptId)
		inner join M_MaterialProgres c on b.MPID = c.ID and (c.WAID=@WAID or @WAID  = 0)
		inner join kuoutlist2 d on d.id = a.kuoutlist2
	) t group by ��ƷID,WAID,kuoutlist2
)

GO

--�жϽ����Ƿ������뵥
CREATE    function [dbo].[HrTodayAppDay](@today datetime,@uid int) returns int
as
begin
declare @HasApp int
set @HasApp=(select top 1 KQClass  from hr_AppHoliday where creator=@uid and del=0 and status=3 and (datediff(d,startTime,@today)>=0 and datediff(d,endTime,@today)<=0) )

if @HasApp is null
begin
set @HasApp=0
end

return @HasApp
end

GO

--�ж����뵥ʱ����Ƿ񽻲�
CREATE   function [dbo].[HrAppDayID]()
returns int
as
begin

declare @startTime datetime,@endTime datetime,@id int,@thisID int,@uid int
select top 1 @id=id,@startTime=startTime,@endTime=endTime,@uid=creator from hr_AppHoliday where del=0 order by id desc


if datediff(d,@startTime,@endTime)<0
begin
return  @id
end

else
begin

select @thisID=id from hr_AppHoliday where del=0 and id<>@id and creator=@uid and
(
(datediff(n,startTime,@startTime)>=0 and datediff(n,endTime,@startTime)<=0) or
(datediff(n,startTime,@endTime)>=0 and datediff(n,endTime,@endTime)<=0)  or
(datediff(n,startTime,@startTime)<0 and datediff(n,endTime,@endTime)>0)
)

end

return @thisID
end

GO

CREATE    function [dbo].[erp_getWorkTimes](@num as decimal(25, 12),@BOMID as int,@WorkTimePerDay as decimal(25, 12),@InputDate as datetime,@RunFlag as int) returns datetime
as
begin
--���������Ʒ����ʱ��
--��ʽ��
--��ʱ�䵥λ=1ʱ��ʱ��ϵ��=1*24��1��ʾ�죬����24����ΪСʱ��
--��ʱ�䵥λ=2ʱ��ʱ��ϵ��=1��2��ʾСʱ��
--��ʱ�䵥λ=3ʱ��ʱ��ϵ��=1/60��3��ʾ���ӣ���Ҫ����60�����Сʱ��
--�ܹ�ʱ=ʱ�䵥λ*���Ŷ�ʱ��+��׼��ʱ*��������+���˹�ʱ��
--�ܹ���Ҫ����=�ܹ�ʱ/ÿ�칤ʱ(ȫ��ȡ��,�磺5.1ȫ��ȡ����6��
  declare @returnNum as money
	select @returnNum=(case when TimeUnit=1 then 24 when TimeUnit=2 then 1.0 when TimeUnit=3 then 1.0/60 end)*(b.TimeQueue+b.TimeStandard*@num+ManHour) from M_BOMList a
	inner join M_WorkingProcedures b on b.ID=a.WPID
	where a.ID=@BOMID
  return dateadd(d,CEILING(@returnNum/@WorkTimePerDay)*@RunFlag,@InputDate)
return @returnNum
end

GO

CREATE  function [dbo].[erp_getBOMChild](@BOMID int) returns varchar(4000)
begin
	declare @returnStr as varchar(4000),@ProductName as varchar(100),@BOM int
	set @returnStr=''
	select @BOM=BOM from M_BOMList where id=@BOMID

	declare Cur_BOM cursor for select b.title from M_BOMList a left join product b on a.ProductID=b.ord where a.ParentID=@BOMID and BOM=@BOM
	open Cur_BOM
	fetch next from Cur_BOM into @ProductName
	while @@fetch_status=0
	begin
		if @returnStr=''
			set @returnStr=isnull(@ProductName,'��Ʒ��ɾ��')
		else
			set @returnStr=@returnStr+'+'+isnull(@ProductName,'��Ʒ��ɾ��')
		fetch next from Cur_BOM into @ProductName
	end
	close Cur_BOM
	deallocate Cur_BOM
	select @ProductName=b.title from M_BOMList a left join product b on a.ProductID=b.ord where a.ID=@BOMID
	if @returnStr=''
	begin
		set @returnStr=isnull(@ProductName,'��Ʒ��ɾ��')+'=��'+isnull(@ProductName,'��Ʒ��ɾ��')+'��'
	end
	else
	begin
		set @returnStr=isnull(@ProductName,'��Ʒ��ɾ��')+'=��'+@returnStr+'��'
	end
	return @returnStr
end




GO
SET QUOTED_IDENTIFIER ON
GO




CREATE function [dbo].[erp_list_bomnode_fun]
( @uid int , @typ int )
 returns  @list table ( [ID]  [int],
[BOM��]  [int],
[������Ʒ]  [int],
[��Ʒ���]  [int],
[��λ]  [int],
[����]  [money] )  as begin
 insert into @list

SELECT ID, BOM AS BOM��, ParentID AS ������Ʒ, ProductID AS ��Ʒ���, unit AS ��λ,
      Num AS ����
FROM dbo.M_BOMList

return
 end

GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================

create function [dbo].[erp_comm_GetBomList](
	--����BOm�ڵ��ȡBOM����ز���
	@NodeId int,		--BOM�Ľڵ�ID
	@showLeaf int,		--�Ƿ���ʾҶ��
	@MultChild bit		--�Ƿ�����༶�ӽڵ�
) returns
@tmp table (
	NodeID int,		--�ڵ���
	PNodeID int,	--���ڵ���
	ProductID int,	--��Ʒ���
	unit Int,		--��λ���
	unitNum money,	--��λ����
	MultiNum Money,	--�˻�����
	rank int,
	depth int,		--���
	path nvarchar(500) --·��
)
as begin
	set @showLeaf = isnull(@showLeaf,1)		--�Ƿ���ʾҶ��
	set @MultChild = isnull(@MultChild,1)	--�Ƿ�����༶�ӽڵ�
	insert into @tmp
	select ID,ParentID,ProductID,unit,Num,Num,rankcode,0,cast(ID as nvarchar(10))
	from M_BOMList
	where ID=@NodeId and del=0 and (@showLeaf=1 or (@showLeaf=0 and RankCode>=0))

	while exists(
		select ParentID,ID from M_BOMList
		where ParentID in (select NodeID from @tmp)
		and	ID not in (select NodeID from @tmp)
		and (@showLeaf=1 or (@showLeaf=0 and RankCode>0))
	)
	begin
		insert into @tmp
		select a.ID,a.ParentID,a.ProductID,a.unit,a.num,a.num*b.MultiNum,a.rankcode,
		b.depth+1,b.path + '\' + cast(a.ID as nvarchar(10))
		from M_BOMList a join @tmp b on a.ParentID=b.NodeID
		where a.ID not in (select NodeID from @tmp)
		and (@showLeaf=1 or (@showLeaf=0 and RankCode>=0))
	end

	if(@MultChild = 0)
	begin
		delete from @tmp where depth > 1
	end
	return
end

GO

--��ѯ������ĳ�����ϰ���°�
CREATE  function [dbo].[HrFcIsWork](@Today datetime,@uid int) returns int
as
begin
declare @num int
	set @num=(select workClass from hr_Fc_time where personClass=(select id from hr_PersonClass where del=0  and (isall=1 or (isall=0 and CHARINDEX(','+cast(@uid as varchar(50))+',',','+cast(user_list as varchar(4000))+',')>0)) ) and del=0 and DATEDIFF(d,d1,@Today)>=0 and DATEDIFF(d,d2,@Today)<=0 )
if @num>=1
begin
set @num=1
end

else if @num=0
begin
set @num=2
end

else
begin
set @num=0
end

return @num
end

GO

--�жϽ����Ƿ�����ϰ�
CREATE  function [dbo].[HrisKT](@today datetime,@uid int)
returns int
as
begin
declare @kt int
--���Ʋ���
declare @HR_login_M int,@HR_leave_M int ,@HR_overtime_M int,@HR_work_H int,@HR_login_Pat int,@HR_overtime_to_int int,@HR_hoDay_Ref int,@HR_comType int,@HR_Test int
select @HR_login_M=login_M*60,@HR_leave_M=leave_M*60,@HR_overtime_M=overtime_M*60,@HR_work_H=work_H,@HR_login_Pat=login_Pat,@HR_overtime_to_int=overtime_to_int,@HR_hoDay_Ref=hoDay_Ref*60,@HR_comType=companyType,@HR_Test=publicTest from hr_KQ_config where del=0 and datediff(d,startTime,@Today)>=0 and datediff(d,endTime,@Today)<=0

if @HR_comType=2
begin

select top 1 @kt=kt from hr_dayWorkTime where id in(select workclass from hr_Fc_time where datediff(d,d1,@today)>=0 and datediff(d,d2,@today)<=0 and del=0 and personClass in(select id from hr_PersonClass where ((isall=1 or (isall=0 and charindex(','+cast(@uid as varchar)+',',','+cast(user_list as varchar(4000))+',')>0))) and del=0))

end

else
begin
return 0
end

if @kt is null
begin
set @kt=0
end

return @kt
end

GO

--����id��,num��1������ƣ�2Ϊ��ɫ��3Ϊ�����ַ���3Ϊ�����ַ�
create function [dbo].[HrWorKClassLi](@personSort int,@tday datetime) returns varchar(100)
as
begin
declare @workClass int
declare @thisClassLi varchar(100)

if @personSort<>'' and isnumeric(@personSort)=1  and isdate(@tday)=1 and @tday<>''
begin
set  @workClass=(select workclass from hr_fc_time where personclass=@personSort and datediff(d,d1,@tday)>=0 and datediff
(d,d2,@tday)<=0)
	if @workClass=0
	begin
	set @thisClassLi='��Ϣ'
	end

	else
	begin
	set @thisClassLi=(select title from hr_dayWorkTime where del=0 and id=@workClass)
	end
end

else
begin
set @thisClassLi=''
end

return @thisClassLi
end

GO

--��ѯĳһ������°�ʱ��

CREATE   function [dbo].[HrDayWorkTime](@Today datetime,@uid int,@Login_out int) returns datetime
as
begin
	declare @thisTime datetime,@StatrStr varchar(100),@endStr varchar(100),@dayWorkId int
	--���Ʋ���
	declare @HR_login_M int,@HR_leave_M int ,@HR_overtime_M int,@HR_work_H int,@HR_login_Pat int,@HR_overtime_to_int int,@HR_hoDay_Ref int,@HR_comType int,@HR_Test int
	select @HR_login_M=login_M*60,@HR_leave_M=leave_M*60,@HR_overtime_M=overtime_M*60,@HR_work_H=work_H,@HR_login_Pat=login_Pat,@HR_overtime_to_int=overtime_to_int,@HR_hoDay_Ref=hoDay_Ref*60,@HR_comType=companyType,@HR_Test=publicTest from hr_KQ_config where del=0 and datediff(d,startTime,@Today)>=0 and datediff(d,endTime,@Today)<=0
	-- declare @thisTime datetime,@StatrStr varchar(100),@endStr varchar(100),@Login_out int,@HR_comType int
	-- declare @Today datetime,@uid int
	-- set @uid=63
	-- set @Today='2011-06-05'
	-- set @Login_out=2
	-- set @HR_comType=1
	-- Task 2393 Sword 2015-1-27 ���ڼ�¼�����ˣ���ʾ�������� 
	declare @kt int
	set @kt = 0
	if @HR_comType=1--��˾����ҵ
	begin



		if @Login_out=1--�ϰ�ʱ��
		begin
		set @StatrStr= (select (select case datepart(weekday,@Today) when 1 then stime7  when 2 then stime1 when 3 then stime2 when 4 then stime3 when 5 then stime4 when 6 then stime5 when 7 then stime6 end) from hr_com_time where del=0 and (@Today between startTime and endTime)  and  ((isall=0 and charindex((','+cast(@uid as varchar(50))+','),(','+cast(user_list as varchar(4000))+','))>0) or isall=1))
		end

		else if @Login_out=2--�°�ʱ��
		begin
		set @StatrStr= (select (select case datepart(weekday,@Today) when 1 then etime7  when 2 then etime1 when 3 then etime2 when 4 then etime3 when 5 then etime4 when 6 then etime5 when 7 then etime6 end) from hr_com_time where del=0 and (@Today between startTime and endTime)  and  ((isall=0 and charindex((','+cast(@uid as varchar(50))+','),(','+cast(user_list as varchar(4000))+','))>0) or isall=1))
		end

	end

	else if @HR_comType=2 --��������ҵ
	begin
		set @dayWorkId=(select  workClass from hr_Fc_time where personClass=(select id from hr_PersonClass where workClass<>0 and del=0 and (isall=1 or (isall=0 and charindex(','+cast(@uid as varchar(50))+',',','+cast(user_list as varchar(4000))+',')>0)) ) and del=0 and datediff(d,d1,@Today)>=0 and datediff(d,d2,@Today)<=0 )

		if @dayWorkId is null
		begin
		return cast('2000-1-1 00:00:00.000' as datetime)
		end

		if @Login_out=1--�ϰ�ʱ��
		begin
			select @kt = 0 ,@StatrStr =dateStart from hr_dayWorkTime where id=@dayWorkId
		end

		else if @Login_out=2--�°�ʱ��
		begin
			select @kt = isnull(kt,0) , @StatrStr=dateEnd from hr_dayWorkTime where id=@dayWorkId	
		end

	end

	else
	begin
		return cast('2000-1-1 00:00:00.000' as datetime)
	end


	if @StatrStr='' or @StatrStr is null or charindex('-',@StatrStr)>0
	begin
	return cast('2000-1-1 00:00:00.000' as datetime)
	end
    --BUG:1393 ������ڼ�¼�����ˣ����ﱨ�����й��̳��ִ��� xieyanhui2014.3.6
	set @thisTime=cast((cast(convert(varchar(10),dateadd(d,@kt,@Today),120) as varchar)+' '+replace(@StatrStr,'��',':')) as datetime)

	return @thisTime


end

GO

--�����Ʒ������������ƻ�����ó���������������������������
CREATE   Function [dbo].[erp_getNumDecide](@MRPID int,@num1 money,@unit int) returns money
--@MRPID MRP���õ�ID
--@num1 ����
--@unit ��λ
AS
begin
  declare @DecideNum as decimal(25, 12),@Tactics as int,@BatchRules as int,@BatNum as decimal(25, 12),@TimeInAdvance as decimal(25, 12),@DayProvide as decimal(25, 12),@ReorderPoint as decimal(25, 12),@ProductID as int
  declare @NumRequest as decimal(25, 12),@SaveNum as decimal(25, 12),@AttritionRate as decimal(25, 12),@Costs as decimal(25, 12),@NumNow as decimal(25, 12),@NumKuout as decimal(25, 12),@NumAssign as money
  declare @Property_Sale as bit,@Property_Buy as bit,@Property_Consume as bit,@Property_Homemade as bit,@Property_Making as bit
  declare @GrossNum as decimal(25, 12) --ë����
  declare @NetNum as decimal(25, 12) --������
  declare @AllocationsNum as decimal(25, 12) --�ѷ�����
  declare @OnHandNum as decimal(25, 12) --���п����
  declare @AvailableNum as decimal(25, 12) --���ÿ����
  declare @ReceiptsNum as decimal(25, 12) --�ƻ�������
  select @ProductID=b.ord,@Tactics=Tactics,@BatchRules=BatchRules,@BatNum=BatNum,@TimeInAdvance=TimeInAdvance,@DayProvide=DayProvide,
  @ReorderPoint=ReorderPoint,@NumRequest=NumRequest,@SaveNum=SaveNum,@NumRequest=NumRequest,@AttritionRate=AttritionRate,
  @Property_Sale=Property_Sale,@Property_Buy=Property_Buy,@Property_Consume=Property_Consume,
  @Property_Homemade=Property_Homemade,@Property_Making=Property_Making from M_ProductMRP a inner join product b on a.ProductID=b.ord where ID=@MRPID
  set @Tactics=isnull(@Tactics,0) --�ƻ�����
  set @BatchRules=isnull(@BatchRules,0) --��������
  set @BatNum=isnull(@BatNum,0) --�̶�����
  set @TimeInAdvance=isnull(@TimeInAdvance,-1) --��ǰ��
  set @DayProvide=isnull(@DayProvide,0) --��֤��Ӧ����
  set @ReorderPoint=isnull(@ReorderPoint,0) --����������
  set @NumRequest=isnull(@NumRequest,0) --��������
  set @SaveNum=isnull(@SaveNum,-1) --��ȫ���
  set @AttritionRate=isnull(@AttritionRate,0) --��Ʒ�����
  set @Costs=isnull(@Costs,0) --��λ�ɱ�
  if @Tactics=0
  begin
    return cast(@num1/(1-@AttritionRate/100.0) as decimal(25, 12))
  end
  else if @Tactics=1 --MRP�ƻ�
  begin
    if @BatchRules=0 or @TimeInAdvance=-1 or @SaveNum=-1 or @AttritionRate=-1
    begin
      return cast(@num1/(1-@AttritionRate/100.0) as decimal(25, 12))
    end
    else
    begin
      if @Property_Sale=1 and @Property_Buy=0 and @Property_Consume=0 and @Property_Homemade=0 and @Property_Making=0
      begin
	--�����ۼ�������MRP����
        return cast(@num1/(1-@AttritionRate/100.0) as decimal(25, 12))
      end
      else
      begin
        /*
          ��������=ë������+�Ѿ�������-�ƻ�������-���п����
          ���ÿ����=���п����-��ȫ���-�Ѿ�������
          �������п����=���ÿ����+��ȫ���+�Ѿ�������
          ��������=ë������-�ƻ�������-���ÿ����-��ȫ���
        */
        --����ӹ�����
        set @GrossNum=@num1
        --�������п����
        select @NumNow=isnull(sum(num2),0) from ku where ord=@ProductID
        --�����������͵ĳ�������
        select @NumKuout=isnull(sum(isnull(num2,0)-isnull(num3,0)),0) from contractlist where ord=@ProductID and unit=@unit and del=1
				--isnull(sum(case when sort1=1 or sort1=2 then num1-num2 else 0 end),0) from kuoutlist2 where ord=@ProductID and MOrderID not in (select ID from M_MaterialOrderLists)
        --�����������뵥����������
        select @NumAssign=isnull(sum(case when OrderType=1 or OrderType=2 then num1 when OrderType=3 then -num1 else 0 end),0) from M_MaterialOrders a
              inner join M_MaterialOrderLists b on a.id=b.MOID where ProductID=@ProductID and Unit=@unit and status=1
        --����ƻ�������
        set @ReceiptsNum=0

        --��������
				set @DecideNum=@num1
        set @NetNum=@GrossNum+@NumKuout+@NumAssign-@NumNow
				if @NetNum<0 --���ÿ����㣬����Ҫ����
				begin
					set @DecideNum=0
				end
				else
				begin
					--���������������������
					if @BatchRules=1 --ֱ�����������˶�������=������
					begin
						set @DecideNum=@NetNum
					end
					else if @BatchRules=2 --�̶������������ �˶�������=����*N������*N>=������
					begin
						set @DecideNum=@NetNum
						set @DecideNum=@BatNum*(ceiling(@NetNum/@BatNum)/10)*10
					end
					else if @BatchRules=3 --�̶����ڷ���δ����,ֱ�ӷ��ظ�����
					begin
						set @DecideNum=-999999999
					end
				end
        return cast(@DecideNum/(1-@AttritionRate/100.0) as decimal(25, 12))
      end
    end
  end
  else if @Tactics=2  --ROP�ƻ�
  begin
    if @Property_Sale=1 and @Property_Buy=0 and @Property_Consume=0 and @Property_Homemade=0 and @Property_Making=0
    begin
      --�����ۼ�������MRP����
      return cast(@num1/(1-@AttritionRate/100.0) as decimal(25, 12))
    end
    else
    begin
/*
1��ROP��Ҫ�Ĳ���
��Ҫ�Ĳ���������������50����������ǰ�ڣ�7�죩����֤����������15�죩����ȫ���������������������������*������ǰ��+��ȫ�������
����������=��50*15��+100=850  ��ǰ�������׼��
����������ﵽ�������ʱ�򣬾ͷ���������Ҳ���ǵ����С��850��ʱ�򣬾�Ҫ���д˲�Ʒ������������Ҫ��ǰ��7�����Ͷ����
*/
      --�������п����
      select @NumNow=isnull(sum(num2),0) from ku where ord=@ProductID
      --�����������͵ĳ�������
      select @NumKuout=isnull(sum(isnull(num2,0)-isnull(num3,0)),0) from contractlist where ord=@ProductID and unit=@unit and del=1
			--isnull(sum(case when sort1=1 or sort1=2 then num1-num2 else 0 end),0) from kuoutlist2 where ord=@ProductID and MOrderID not in (select ID from M_MaterialOrderLists)
      --�����������뵥����������
      select @NumAssign=isnull(sum(case when OrderType=1 or OrderType=2 then num1 when OrderType=3 then -num1 else 0 end),0) from M_MaterialOrders a
            inner join M_MaterialOrderLists b on a.id=b.MOID where ProductID=@ProductID and Unit=@unit and status=1
      --����ƻ�������
      set @ReceiptsNum=0
      --������ÿ��
      set @DecideNum=@NumNow-@NumKuout-@NumAssign-@num1
      --���㶩����
      set @ReorderPoint=@NumRequest*@DayProvide+@SaveNum
      if @DecideNum<=@ReorderPoint
      begin
        return cast(@ReorderPoint/(1-@AttritionRate/100) as decimal(25, 12))
      end
      else
      begin
        return 0
      end
    end
  end
  else
  begin
    return cast(@num1/(1-@AttritionRate/100.0) as decimal(25, 12))
  end
  return 0
end

GO

--�жϿ��ڲ���ʱ����Ƿ񽻲�
CREATE function [dbo].[HrConfigDoubID]()
returns int
as
begin

declare @startTime datetime,@endTime datetime,@id int,@thisID int
select top 1 @id=id,@startTime=startTime,@endTime=endTime from hr_kq_config where del=0 order by id desc


if datediff(d,@startTime,@endTime)<0
begin
return  @id
end

else
begin

select @thisID=id from hr_kq_config where del=0 and id<>@id and
(
(datediff(d,startTime,@startTime)>=0 and datediff(d,endTime,@startTime)<=0) or
(datediff(d,startTime,@endTime)>=0 and datediff(d,endTime,@endTime)<=0)  or
(datediff(d,startTime,@startTime)<0 and datediff(d,endTime,@endTime)>0)
)

end

return @thisID
end

GO

CREATE function [dbo].[erp_getstartDateByEndDate](
	@endDate datetime,
	@WorkHour money
) returns datetime as begin
	--�����깤���ڻ�ȡ��������
	declare @DayWorkHour money --ÿ�չ���Сʱ
	declare @r datetime
	declare @d1 datetime
	declare @d2 datetime
	declare @h money
	declare @d money
	set @r = @endDate
	while(@WorkHour > 0)
	begin
		set @h=-1
		select  @d1=a.d1,@d2=a.d2,@h=cast(sum(datediff(minute,b.t1,b.t2)/60.00+b.kt*24) as decimal(25, 12) ),@d=abs(datediff(d, @r,d1))+1  from
		M_FcDateList a inner join M_FcTimeList b
		on  a.fcdate = b.fcdate and a.id in (
						select max(x.id) from M_FcDateList x inner join M_FcDate y
						on y.ID = x.fcdate and y.status>2 and y.wobjtype = 1 and y.wobj=0 and y.del=0
						and x.wtype<=3  --wtype<=3��ʾ�ϰ�
						where  @r between x.d1 and x.d2
		) group by d1,d2
		if @h > 0
		begin
			if @d*@h > @WorkHour
			begin
				set @r = dbo.erp_deleteDate(@r,@WorkHour/ @h)
				set  @WorkHour = 0
			end
			else
			begin
				set @r = dbo.erp_deleteDate(@r,@d)
				set @WorkHour =  @WorkHour-@d*@h
			end
		end
		else
		begin
			if exists(select top 1 x.id from M_FcDateList x ,  M_FcDate y
			where d2< @r and y.ID = x.fcdate and y.status>2 and y.wobjtype = 1 and y.wobj=0 and y.del=0
						and x.wtype<=3)
			begin
				select  @r = max(x.d2) from M_FcDateList x ,  M_FcDate y
				where d2< @r and y.ID = x.fcdate and y.status>2  and y.del=0 and
						y.wobjtype = 1 and y.wobj=0 and x.wtype<=3
			end
			else
			begin
				select @DayWorkHour=cast(intro as decimal(25, 12)) from setopen where sort1=18002
				set @r = dbo.erp_deleteDate(@r,@WorkHour/@DayWorkHour)
				set @WorkHour = 0
			end

		end
	end
	return @r
end

GO

--�����е�¼����
CREATE function [dbo].[HrHasLogin](@today datetime,@uid int,@Login_out int) returns int
as
begin
declare @HasLogin int

if @Login_out=1
begin
set @HasLogin=(select count(*) from hr_Log where del=0 and result=1 and creator=@uid and datediff(d,inDate,@today)=0)
end

else if @Login_out=2
begin
set @HasLogin=(select count(*) from hr_Log where del=0 and result=2 and creator=@uid and datediff(d,inDate,@today)=0)
end

else
begin
set @HasLogin=(select count(*) from hr_Log where del=0 and creator=@uid and datediff(d,inDate,@today)=0)
end

return @HasLogin
end

GO

create     function [dbo].[Hr_kqclassname_fun](@ord int,@typ int)	returns varchar(100)
as
begin
--���ؿ��ڽ��
declare @title varchar(100)
	SELECT @title=a.title
	FROM dbo.hr_KQClass a
	WHERE  (@typ = 1  and a.id=@ord) or (@typ = 0  and a.id=@ord)
return @title
end

GO

--�������ͷ���
create  function [dbo].[HrKQClassID](@id int) returns int
as
begin
declare @ClassID int
	if isnumeric(@id)=1
	begin
	 set @ClassID= (select sortid from hr_KQClass where id=@id and del=0)
	end
	else
	begin
	set @ClassID=null
	end
return @ClassID
end

GO

--��ȡ�������ͱ����Id
create function [dbo].[HrGetKQMaxID]()
returns int
as
begin
return (select max(id)+1 from hr_kqclass)
end

GO

CREATE  function [dbo].[erp_MaterialOrderComplete](@bill_ID as int) returns int
--�ж�����������Ʒ���״̬
--����ֵ
--10 �Ѻ���
--0 ���������
--1 �����������
--2 ����������,����ȫ���
--3 ������
begin
	declare @Complete as int,@num0 as decimal(25, 12),@num1 as decimal(25, 12),@num2 as decimal(25, 12),@returnvalue as int
	declare @maxv int
	select @Complete=Complete from M_ManuOrders where id=@bill_ID
	if @Complete=1 or @Complete=2 --�Ѻ�����ɱ�
	begin
		set @returnvalue=10
	end
	else
	begin
		set @returnvalue=0
		select 
			@returnvalue = min(n),
			@maxv = max(n)
		from (
			select (case
			when isnull(sum(num1),0)=0 then 0
			when  NumDecide>isnull(sum(num1),0) then 1
			when  NumDecide<=isnull(sum(num1),0) and NumDecide>isnull(sum(num2),0) then 2
			when  NumDecide<=isnull(sum(num1),0) and NumDecide<=isnull(sum(num2),0) then 3
			else 1 end) as n
			from (
				select b.id, b.NumDecide, 0 as num1, 0 as num2 from M_ManuOrderLists b where b.MOrderID = @bill_ID 
				union all
				select b.ID,  b.NumDecide as n, i.num1, i.num2 from M_ManuOrders a
				inner join M_ManuOrderLists b on a.id=b.MOrderID and a.id=@bill_ID --and b.lvw_treenodedeep = 0
				inner join M_ManuOrderIssuedLists d on d.MOrderListID=b.id
				inner join M_WorkAssigns e on e.MOIListID=d.id
				inner join M_MaterialProgres f on f.WAID=e.id
				inner join M_MaterialProgresDetail g on g.MPID=f.id
				inner join M_QualityTestingLists h on h.MPDID=g.id
				inner join kuinlist i on i.QTLID=h.id and i.del=1
				union all
				select a.ID, a.NumDecide as n ,d.num1, d.num2  from M_ManuOrderLists a
				inner join M_OutOrderlists b on a.ID = b.molist and a.MOrderID = @bill_ID
				inner join M_WWQCList c on  b.ID = c.wwlistid
				inner join kuinlist d on -d.QTLID = c.ID
			) t where NumDecide > 0 group by id,NumDecide
		) tt
	end
	return (case @returnvalue when 0 then sign(@maxv) else  @returnvalue end);
end


GO

 CREATE FUNCTION [dbo].[getM_ManuOrderIssued]()
 RETURNS VARCHAR(4000)
 AS
 BEGIN
 DECLARE @xid INT,@fid INT,@xproid INT,@NumDecide FLOAT,@NumDecide1 FLOAT,@idlist VARCHAR(4000)
 DECLARE mycur CURSOR FOR select id,moiid,ProductID,NumDecide from M_ManuOrderIssuedLists where MOIID in
 (
 	SELECT id from M_ManuOrderIssueds where moid in
 	(
 		SELECT id FROM M_ManuOrders where Complete=0
 	)
 )
 SET @idlist=''
 OPEN mycur
 FETCH mycur INTO @xid,@fid, @xproid, @NumDecide
 WHILE @@fetch_status=0
 BEGIN
 	SET @NumDecide1=0
 	SELECT @NumDecide1=isnull(sum(NumMake),0) FROM M_WorkAssigns where moilistid=@xid AND M_WorkAssigns.ProductID=@xproid
 	IF (@NumDecide>@NumDecide1)
 	BEGIN
 		IF (@idlist='')
 		BEGIN
 			set @idlist=@fid
 		END
 		ELSE
 		BEGIN
 			set @idlist=@idlist+','+cast(@fid AS VARCHAR(100))
 		END
 	END
 	FETCH mycur INTO @xid,@fid,@xproid, @NumDecide
 END
 CLOSE mycur
 DEALLOCATE mycur
 RETURN @idlist
 END
GO






CREATE           function [dbo].[HrAlt](@uid int,@taday datetime, @noAlt int)
returns int
begin
--Ա������-����-�������
declare @IsOpen int,@fw int,@days int,@qx_open int,@qx_intro varchar(4000)

	declare @count int

	--����
	select @IsOpen=isnull(intro,0),@fw=isnull(fw1,1),@days=isnull(tq1,0) from setjm  where cateid=@uid and ord=101
	If @IsOpen=1
	Begin
		If @fw=1
		begin
			select  @count=count(*) from
			(select
			(case a.unit when 1 then dateadd(yyyy,a.zhouqi,a.lastdate)
			when 2 then dateadd(qq,a.zhouqi,a.lastdate)
			when 3 then dateadd(m,a.zhouqi,a.lastdate)
			when 4 then dateadd(ww,a.zhouqi,a.lastdate)
			when 5 then dateadd(d,a.zhouqi,a.lastdate)
			else null end)as addDate,b.del,b.userid
			from hr_person_health a left join hr_person b on b.userID=a.personID where a.personID=@uid ) c
			where c.del=0 and c.userid=@uid  and datediff(d,c.addDate,@taday)<=@days  and @noAlt=0
		end

		Else
		Begin
		--Ȩ��
			select @qx_open=qx_open,@qx_intro=cast(qx_intro as varchar(4000)) from power  where ord=@uid and sort1=82 and sort2=1
			If @qx_open=3
			Begin

				select  @count=count(*) from
				(select
				(case a.unit when 1 then dateadd(yyyy,a.zhouqi,a.lastdate)
				when 2 then dateadd(qq,a.zhouqi,a.lastdate)
				when 3 then dateadd(m,a.zhouqi,a.lastdate)
				when 4 then dateadd(ww,a.zhouqi,a.lastdate)
				when 5 then dateadd(d,a.zhouqi,a.lastdate)
				else null end)as addDate,b.del,b.userid
				from hr_person_health a left join hr_person b on b.userID=a.personID where 1=1 ) c
				where c.del=0   and datediff(d,c.addDate,@taday)<=@days  and @noAlt=0
			End
			Else
			Begin


				select  @count=count(*) from
				(select
				(case a.unit when 1 then dateadd(yyyy,a.zhouqi,a.lastdate)
				when 2 then dateadd(qq,a.zhouqi,a.lastdate)
				when 3 then dateadd(m,a.zhouqi,a.lastdate)
				when 4 then dateadd(ww,a.zhouqi,a.lastdate)
				when 5 then dateadd(d,a.zhouqi,a.lastdate)
				else null end)as addDate,b.del,b.userid
				from hr_person_health a left join hr_person b on b.userID=a.personID where 1=1 ) c
				where c.del=0  And charindex(','+cast(c.userid as varchar(50))+',',','+@qx_intro+',')>0   and datediff(d,c.addDate,@taday)<=@days  and @noAlt=0
			End
		End
	End

	--Ա����ͬ����
	--����
	select @IsOpen=isnull(intro,0),@fw=isnull(fw1,1),@days=isnull(tq1,0) from setjm  where cateid=@uid and ord=17
	If @IsOpen=1
	Begin
		If @fw=1
		begin
			select  @count=@count+count(*) from hr_person a left join gate b on a.userid=b.ord  where dbo.hrNeedAltPerson_contract(a.userid,@taday,@days)=0 and a.userid=@uid  and datediff(d,@taday,a.contractEnd)<=@days  and a.del=0 and @noAlt=0
		end

		Else
		Begin
		--Ȩ��
			select @qx_open=qx_open,@qx_intro=cast(qx_intro as varchar(4000)) from power  where ord=@uid and sort1=82 and sort2=1
			If @qx_open=3
			Begin
				select  @count=@count+count(*) from hr_person a left join gate b on a.userid=b.ord  where dbo.hrNeedAltPerson_contract(a.userid,@taday,@days)=0   and datediff(d,@taday,a.contractEnd)<=@days  and a.del=0 and @noAlt=0
			End
			Else
			Begin
				select  @count=@count+count(*) from hr_person a left join gate b on a.userid=b.ord  where dbo.hrNeedAltPerson_contract(a.userid,@taday,@days)=0  And charindex(','+cast(a.userid as varchar(50))+',',','+@qx_intro+',')>0 and datediff(d,@taday,a.contractEnd)<=@days  and a.del=0 and @noAlt=0
			End
		End
	End

--Ա��ת������

	select @IsOpen=isnull(intro,0),@fw=isnull(fw1,1),@days=isnull(tq1,0) from setjm  where cateid=@uid and ord=100
	If @IsOpen=1
	Begin
		If @fw=1
		begin
			select  @count=@count+count(*) from hr_person a  where  a.userid=@uid  and datediff(d,@taday,a.Reguldate)<=@days and  a.nowStatus=5  and a.del=0 and @noAlt=0
		end

		Else
		Begin
		--Ȩ��
			select @qx_open=qx_open,@qx_intro=cast(qx_intro as varchar(4000)) from power  where ord=@uid and sort1=87 and sort2=1
			If @qx_open=3
			Begin
				select  @count=@count+count(*) from hr_person a  where  datediff(d,@taday,a.Reguldate)<=@days and  a.nowStatus=5  and a.del=0 and @noAlt=0
			End
			Else
			Begin
			select  @count=@count+count(*) from hr_person a  where  charindex(','+cast(a.userid as varchar(50))+',',','+@qx_intro+',')>0  and datediff(d,@taday,a.Reguldate)<=@days and  a.nowStatus=5  and a.del=0 and @noAlt=0
			End
		End
	End

-- -- �������������
-- -- 	select @count=@count+count(*) from hr_needperson where @noAlt=0 and  cateid_sp=@uid  and (status=1 or status=0) and del=0
return isnull(@count,0)
end


GO

CREATE function [dbo].[GetAvlRelPersons](@reltype int, @reluser int, @ranges varchar(8000), @userid int)
returns table
as return 
(
	--@reltype��1=����ֱ���ϼ�  2=���������ϼ� 3=������
	select ord , name from (
		select y.ord, y.name from gate x inner join gate y on @reltype=1 and x.ord=@reluser and x.orgsid=y.orgsid and x.partadmin=0 and y.partadmin=1 and y.del=1 and y.ord<>@userid
		union all
		select y.ord, y.name from gate x
		inner join orgs_parts z on x.orgsid=z.id
		inner join gate y on @reltype=1 and x.ord=@reluser and z.pid=y.orgsid and x.partadmin=1 and y.partadmin=1 and y.del=1
	) x where @reltype=1 and (@ranges='' or charindex(','+cast(ord as varchar(12)) + ',', ','+replace(@ranges,' ','')+',')>0)
	union all
	select ord , name from (
		select y.ord , y.name from gate x inner join gate y on @reltype=2 and x.ord=@reluser and x.orgsid=y.orgsid and x.partadmin=0 and y.partadmin=1 and y.del =1 and y.ord<>@userid
		union all
		select z.ord, z.name from gate x
		inner join orgs_parts y on  @reltype=2 and x.ord=@reluser and x.orgsid=y.id
		inner join gate z on z.orgsid <> x.orgsid and CHARINDEX(',' + cast(z.orgsid as varchar(12)) + ',', ','+y.fullids) >0 and z.partadmin=1 and z.del=1
	) x where @reltype=2 and (@ranges='' or charindex(','+cast(ord as varchar(12)) + ',', ','+replace(@ranges,' ','')+',')>0)
	union all
	select ord, name from gate where @reltype=3 and del=1 and (@ranges='' or charindex(','+cast(ord as varchar(12)) + ',', ','+replace(@ranges,' ','')+',')>0)
)

GO

create       function [dbo].[HrGetGatePostion](@uid int)
returns varchar(50)
AS
begin
	declare @str varchar(50)
	select @str=isnull(title,'') from gate where ord=@uid
	return @str
end

GO

CREATE function [dbo].[erp_bill_GetSpLinkMan](@Creator int,@parents varchar(2000), @ltype int) returns varchar(6000)
as begin
	declare @r varchar(6000)
	set @r = ''
	select @r = @r + '|' +  cast(ord as varchar(12)) + '=' + cast(name as varchar(100)) from dbo.GetAvlRelPersons(@ltype, @Creator , @parents, @Creator) t;
	if charindex('|' + cast(@Creator as varchar(12)) + '=',@r) = 0
	begin
		if charindex(',' +cast(@Creator as varchar(12))  +',',',' + @parents + ',') > 0
		begin
			select @r = @r + '|' +  cast(ord as varchar(12)) + '=' + cast(name as varchar(100))  from gate where ord=@Creator
		end
	end
	return @r
end

GO

create   function [dbo].[SNGetScoreName](@id int)
returns varchar(100)
begin
declare @name varchar(100),@score1 varchar(100),@score2 varchar(100)

if isnumeric(@id)=1 and @id is not null
begin
select @score1=isnull(sort1,'') from gate1 where ord=isnull((select sorce from gate where ord=@id),0)
select @score2=isnull(sort2,'') from gate2 where ord=isnull((select sorce2 from gate where ord=@id),0)

if @score1<>''
begin
set @name=@score1
end

if @score2<>''
begin
set @name=@name+'-'+@score2
end

end

else
begin
return ''
end

return @name

end

GO

CREATE function [dbo].[GetFcObjName]
(
   @woType int,  --��������
   @woObjID int  --����ID
) returns varchar(1000)
as begin
	declare @r varchar(2000)
   --��ȡ��������Ӧ�õĶ���
	if @woType = 1  --��֯�ܹ������ı�ʾ����
	begin
		select top 1 @r=sort1 from (
			select -ord as ord ,sort1 from gate1
			union
			select a.ord,b.sort1 + '>>'+ a.sort2  from gate2 a , gate1 b  where  a.sort1 = b.ord
		) t where ord = @woObjID
	end
	else if @woType = 2 --Ա��
	begin
		select  top 1 @r= name + '(' + username + ')'  from gate where ord = @woObjID
	end
	else if @woType = 3
	begin
		select top 1 @r = WCName from M_WorkingCenters where ID=@woObjID
	end
	else
	begin
		select top 1 @r = r from (
			select  b.WCName + '>>' + c.name as r , a.id
			from M_WCMacList a,M_WorkingCenters b , M_MachineInfo c
			where a.WCID = b.ID and c.id=a.MCID and a.id = @woObjID
		) t
	end
	set @r = isnull(@r,'')
	return @r
end

GO

--�жϸ��˺��Ƿ���ʾ,0Ϊ����ʾ��1Ϊ��ʾ
CREATE  function [dbo].[HrIsShowGate](@today datetime,@uid int)
returns int
begin
	declare @isShow int,@count int
	if isdate(@today)=1 and isnumeric(@uid)=1
	begin
		if exists(
			select top 1 userID from hr_person where nowStatus not in (4, 2) and
			del=0 and userID=@uid and datediff(d,Entrydate,@today)>=0 and
				(
				datediff(d,contractEnd,@today)<=0 or
				(datediff(d,contractEnd,@today)>0 and (nowStatus=3 or nowStatus=5) and nowStatus is not null)
				)
			and userID = @uid
		)
		begin
			set @isShow=1
		end
		else
		begin
			set @isShow=0
		end
	end
	else
	begin
		set @isShow=0
	end
	return @isShow
end

GO
--���¼�����������
CREATE function [dbo].[HrIsShowGate2](@today datetime,@uid int)
returns int
begin
	declare @isShow int,@count int
	if isdate(@today)=1 and isnumeric(@uid)=1
	begin
		if exists(
			select top 1 userID from hr_person where nowStatus not in (4, 2) and
			del=0 and userID=@uid and datediff(m,Entrydate,@today)>=0 and
				(
				datediff(m,contractEnd,@today)<=0 or
				(datediff(m,contractEnd,@today)>0 and (nowStatus=3 or nowStatus=5) and nowStatus is not null)
				)
			and userID = @uid
		)
		begin
			set @isShow=1
		end
		else
		begin
			set @isShow=0
		end
	end
	else
	begin
		set @isShow=0
	end
	return @isShow
end

GO

CREATE  function [dbo].[HrGetSorceNameFun](@id int ,@type int)
returns varchar(50)
as
begin

	declare @str varchar(50)
	if @type=1
	begin
	 (select @str=isnull(sort1,'*') from gate1 a left join gate b on b.sorce=a.ord where b.ord=@id)
	end

	else if @type=2
	begin
	(select @str=isnull(sort2,'*') from gate2 a left join gate b on b.sorce2=a.ord where b.ord=@id)
	end

	else
	begin
		return '*'
	end

	return @str

end

GO

create  function [dbo].[SNGetGateName](@id int)
returns varchar(100)
begin
declare @name varchar(100)

if isnumeric(@id)=1 and @id is not null
begin
select @name=username from hr_person where del=0 and userid=@id
end

else
begin
return ''
end

return @name

end

GO

CREATE  function [dbo].[HrGetCateName](@id int)returns varchar(200)
as
begin

	declare @thisName varchar(200)
	if isnumeric(@id)=1
	begin
	set @thisName=(select [name] from gate where ord=@id)
	end

	else
	begin
	return null
	end

return @thisName
end

GO

--ajax���ø�������˰--��ȡ��������˰
create function [dbo].[HrTaxAjax](
	@uid int,
	@ToalMoney money,
	@startDate datetime,
	@endDate datetime,
	@IsOpen int,
	@ismode nvarchar(100),
	@ord int,
	@oldChildrenseDucation money,
	@oldContinuingEducationxl money,
	@oldContinuingEducationjn  money,
	@oldmedical money,
	@oldHousingloans  money,
	@oldpayment money,
	@oldSupportOldPeople money,
	@TaxSumType INT,
	@oldInfantCare money
)returns money
as
begin 

	declare @Entrydate datetime
	select @Entrydate=Entrydate from hr_person where  userID=@uid and del=0
	declare @counts int--�ѷ���������
	--����˰��
	declare @TaxBase money,@sortid int,@SUMTaxBase MONEY 
	select @TaxBase=taxbase,@sortid=id from hr_PersonTaxSort where del=0 and isnull(IsEnabled,0)=@IsOpen and datediff(d,startTime,@startDate)>=0 and datediff(d,endTime,@endDate)<=0	
	--δ���ø�������˰
	if @TaxBase is null
	begin
		return 0.0
	end

	 declare @thisMoney  money ,@TallMoney  money,@needMoney money,@ChildrenseDucation money,  
	 @ContinuingEducationxl money,@ContinuingEducationjn money,@medical money,@Housingloans money,@payment money,  
	 @SupportOldPeople money
	 
	 -- select @ChildrenseDucation=isnull(ChildrenseDucation,0),   
	 --@ContinuingEducationxl=isnull(ContinuingEducationxl,0),  
	 --@ContinuingEducationjn=isnull(ContinuingEducationjn,0),  
	 --@medical=isnull(medical,0),  
	 --@Housingloans=isnull(Housingloans,0),  
	 --@payment=isnull(payment,0),  
	 --@SupportOldPeople=isnull(SupportOldPeople,0)  
	 --from dbo.hr_person where userID=@uid  
	 
	
	if(@IsOpen=0)
	begin

		set @TallMoney=@ToalMoney-@TaxBase-@oldChildrenseDucation-@oldContinuingEducationxl-@oldContinuingEducationjn-@oldmedical-@oldHousingloans-@oldpayment-@oldSupportOldPeople-@oldInfantCare  
		--δ�ﵽ��˰����
		if @TallMoney<=0
		begin
			return 0.0
		end		
		--taxRate ˰�� ,cut ����۳���
		select @thisMoney=(@TallMoney*0.01*taxRate-cut) from hr_PersonTax where  isnull(IsEnabled,0)=@IsOpen and sortid=@sortid and @TallMoney>[lower] and @TallMoney<=limit
	end
	else
	begin	
            declare @lastyearTotalMoney Money,@lastyearCount int
            declare @cutMoney Money
			select @counts=count(1)+1 from (select wageslist.wages 
			from wages inner join wageslist on wages.id=wageslist.wages 
			where complete1=1 and YEAR((case when @TaxSumType=1 then date3 else date1 end))=YEAR(case when @TaxSumType=1 then @startDate else dateadd(m,1,@startDate) end) 
			and case when @TaxSumType=1 then date3 else date1 end>= @Entrydate
			and  wages.del=1 and isnull(IsEnabled,0)=1 and (wages.id<@ord or @ord=0) and wageslist.cateid=@uid group by wageslist.wages)W
            --���ս��ڿ�˰�Ĺ�ʽ���ȿ۳�����Ϊ���ս�������˰�ˣ��Ժ��˰���߸ı����Ż�
			select @TallMoney=isnull(sum(case when CHARINDEX('˰',isnull(s.salaryClass,''))=0 and CHARINDEX('���ս�',isnull(s.salaryClass,''))=0 then w.money1*updown else 0 end),0)  
				+isnull(@ToalMoney,0),
				@cutMoney=isnull(sum(case when w.sort1<0 then w.money1 else 0 end),0)+(@counts*@TaxBase)
				+(@oldChildrenseDucation+@oldContinuingEducationxl+@oldContinuingEducationjn+@oldmedical+@oldHousingloans+@oldpayment+@oldSupportOldPeople+@oldInfantCare) 
				from   wageslist w
				inner join wages ww on ww.id=w.wages and isnull(IsEnabled,0)=1
				left join sortwages s on s.id=w.sort1
				where complete1=1 and YEAR((case when @TaxSumType=1 then date3 else date1 end))=YEAR(case when @TaxSumType=1 then @startDate else dateadd(m,1,@startDate) end) 
				and case when @TaxSumType=1 then date3 else date1 end>=@Entrydate
				and w.del=1 and (w.wages<@ord or @ord=0) and w.cateid=@uid
            select @lastyearTotalMoney=isnull(sum(case when CHARINDEX('˰',isnull(s.salaryClass,''))=0 and CHARINDEX('���ս�',isnull(s.salaryClass,''))=0 then w.money1*updown else 0 end),0)-isnull(sum(case when w.sort1<0 then w.money1 else 0 end),0), 
				   @lastyearCount=count(distinct month(case when @TaxSumType=1 then date3 else date1 end))
				from   wageslist w
				inner join wages ww on ww.id=w.wages and isnull(IsEnabled,0)=1
				left join sortwages s on s.id=w.sort1
				where complete1=1 and YEAR((case when @TaxSumType=1 then date3 else date1 end))=YEAR(case when @TaxSumType=1 then @startDate else dateadd(m,1,@startDate) end)-1 
				and case when @TaxSumType=1 then date3 else date1 end>=@Entrydate
				and w.del=1 and (w.wages<@ord or @ord=0) and w.cateid=@uid
			   --1.��һ��û�н���12���£�ֱ�Ӱ���ԭ�����㹫ʽ�߼�����
               -- 2.��һ�꽻��12���£����ҷ����ܶ����60000��ֱ�Ӱ���ԭ�����㹫ʽ�߼�����
               -- 3.��һ�꽻��12���£����ҷ����ܶ�С��60000��������ۼ�С��6���˰0������6�򣬰���ԭ�����㹫ʽ�߼�����
			if (@lastyearCount=12 and @lastyearTotalMoney<60000)
		    begin
			   if @TallMoney<=60000
				begin
					return 0.0
				end
		    end
			set @TallMoney=@TallMoney-@cutMoney
			--δ�ﵽ��˰����
			if @TallMoney<=0
			begin
				return 0.0
			end
			
			select @SUMTaxBase=sum(case when CHARINDEX('˰',isnull(s.salaryClass,''))>0 THEN w.money1 ELSE 0 END)
				from   wageslist w
				inner join wages ww on ww.id=w.wages and isnull(IsEnabled,0)=1
				left join sortwages s on s.id=w.sort1
				where complete1=1 and YEAR((case when @TaxSumType=1 then date3 else date1 end))=YEAR(case when @TaxSumType=1 then @startDate else dateadd(m,1,@startDate) end) 
				and case when @TaxSumType=1 then date3 else date1 end>=@Entrydate
				and w.del=1	and (w.wages<@ord or @ord=0) and w.cateid=@uid
						
			select @thisMoney=(@TallMoney*0.01*taxRate-cut-isnull(@SUMTaxBase,0)) from hr_PersonTax where  isnull(IsEnabled,0)=@IsOpen and sortid=@sortid and @TallMoney>[lower] and @TallMoney<=limit
	end
	if @thisMoney is null or @thisMoney<=0
	begin
		set @thisMoney=0.0
	end
	return @thisMoney
end

GO

--��ȡ��˰����۳���
create function [dbo].[HrTaxQuick](@sortid int,@lv int,@taxRate int)
returns money
as
begin
	declare @out money

	if isnumeric(@sortid)=1 and isnumeric(@lv)=1 and isnumeric(@taxRate)=1
	begin
		select @out=(limit*(@taxRate-taxRate)*0.01+cut) from hr_PersonTax  where sortid=@sortid and lv=(@lv-1)
	end

	else
	begin
		return 0
	end

	if @out is null
	begin
		return 0
	end

	return @out
end

GO

create function  [dbo].[hrGetPostionID](@sorce varchar(50),@sorce2 varchar(50),@postion varchar(50))
returns int
begin

	declare @id int,@gate1 int ,@gate2 int

if @postion<>''
begin

		select @gate1=isnull(id,0) from gate1 where sort1=@sorce
		select @gate2=isnull(id,0) from gate2 where sort2=@sorce2 and sort1=@gate1
		select @id=isnull(id,0) from hr_pub_postion where sorce=@gate1 and sorce2=@gate2 and title=@postion and del=0

end

else
begin
	set @id=0
end

return @id

end

GO

create  function [dbo].[hrGetPostion_SorceName](@id int)
returns varchar(50)
begin
declare @name varchar(50)
select @name=(case isnull(b.sort1,'') when '' then '' else b.sort1+'-' end)+(case isnull(c.sort2,'') when '' then '' else c.sort2+'-' end)+a.title  from hr_pub_postion a left join gate1 b on a.sorce=b.ord left join gate2 c on a.sorce2=c.ord where a.del=0 and a.id=@id
return @name
end

GO

create Function [dbo].[SnGetSorceNameFun](@id int ,@type int)
returns varchar(50)
begin

	declare @str varchar(50)
	If @type=1
	begin
		select @str=isnull(sort1,'*') from gate1 where ord=@id
	end

	else if @type=2
	begin
		select @str=isnull(sort2,'*') from gate2 where ord=@id
	end

	Else
	begin
		set @str=''
	end
return @str
end

GO

create function [dbo].[HrGetSorceName](@uid int)
returns varchar(200)
as
begin
declare @thisName varchar(200)

if isnumeric(@uid)=1
begin
	select @thisName=sort1 from gate1 where ord=@uid
end

else
begin
	return null
end

return @thisName
end

GO

create function [dbo].[hrGetResumeItem](@id int)
returns varchar(50)
begin
	declare @str varchar(50)
	select @str=isnull(title,'') from hr_resume_item  where id=@id and del=0
	return @str
end

GO

--��ѯн�ʹ���������
create function [dbo].[HrGetSalaryClassName](@id int)returns varchar(100)
as
begin
declare @thisName varchar(100)

if @id<>'' and isnumeric(@id)=1
begin
set @thisName=(select title from hr_SalaryClass where del=0 and id=@id)
end

else
begin
set @thisName=''
end

return @thisName
end

GO

--����ĳ�˵ı��տ۷�
CREATE     function [dbo].[HrMakeWelfare](@sdate datetime,@edate datetime,@uid int,@id int) returns money
as
begin


if @id<>'' and isnumeric(@id)=1 and @uid<>'' and isnumeric(@uid)=1
begin


declare @thisMoney money

declare @base money,@baseStr varchar(100),@PersonBase money
--�ϱ�����
declare @limit money
--����
declare @lower money
--����
declare @Propm_person float
--����
declare @Propm_personJia money
--����


select @baseStr=isnull(base,'0'),@limit=dbo.HrNullNum(limit),@lower=dbo.HrNullNum(lower),@Propm_person=Propm_person,@Propm_personJia=isnull(Propm_personJia,0) from hr_Welfare where del=0 and classid=@id and ((isall=0 and  charindex(','+cast(@uid as varchar(100))+',',','+cast(user_list as varchar(4000))+',')>0) or isall=1) order by id desc
	if @baseStr='0'
	begin
		return cast(0 as decimal(25, 12))
	end


if charindex('{��������}',@baseStr)>0
begin

select @PersonBase=(case @id when 1 then Pension when 2 then Health when 3 then Unployment when 4 then Injury when 5 then Maternity when 6 then Housing else 0 end) from hr_person where userID=@uid and del=0

set @baseStr=replace(@baseStr,'{��������}',cast(@PersonBase as varchar(100)))
end


set @base=dbo.eval(@baseStr)

	if @limit>0
	begin
		if @base>@limit
		begin
		--���շѸ�������
		set @base=@limit
		end
	end

	if @lower>0
	begin
		--���շѵ�������
		if @base<@lower
		begin
		set @base=@lower
		end
	end

	set @thisMoney=@base*(@Propm_person*0.01)+@Propm_personJia
	--���ռ��㹫ʽ

end

else
begin

set @thisMoney=cast(0 as decimal(25, 12))
end
if @thisMoney is null
begin
set @thisMoney=cast(0 as decimal(25, 12))
end

return @thisMoney


end

GO

--��ѯ�����Ƽ���������
CREATE  function [dbo].[HrjjMoney](@StratDate datetime,@EndDate datetime,@uid int)returns money
as
begin

declare @thisMoney  money
declare @Money  money

set @Money=isnull((select sum(isnull(money1,0)+isnull(Premium,0)) from M_MaterialProgresDetail a,M_MaterialProgres b where a.MPID = b.ID and b.del=0 and b.TempSave=0 and a.Maker=@uid and datediff(d,@StratDate,MPDate)>=0 and isnull(a.wageStatus,'NOT_PAiD') = 'NOT_PAiD' and datediff(d,@EndDate,MPDate)<=0),0)

return @Money
end

GO

create  function [dbo].[SNGetCompanyName](@id int)
returns varchar(100)
begin
declare @name varchar(100)

if isnumeric(@id)=1 and @id is not null
begin
select @name=name from tel where del=1 and ord=@id
end

else
begin
return ''
end

return @name

end

GO

--����Ƽ�����
CREATE function [dbo].[CWjjMoney](@StratDate datetime,@EndDate datetime,@uid int,@salaryClassid int)returns money
as
begin

declare @thisMoney  money
declare @Money  money

set @Money=isnull((select isnull(sum(money1),0) as money1  from wageslist_jj where  date1>=@StratDate and date1<=@EndDate and cateid=@uid and complete1=0 and isnull(salaryClass,0)=@salaryClassid),0)
return @Money
end

GO
--�ʼ��Ƿ������
CREATE function [dbo].[erp_QTCanRK](
	@QTID INT
) 
returns bit
BEGIN	
	if exists(
			select a.id 
			from M_QualityTestingLists a with(nolock) 	--�ʼ���ϸ
			inner join  M_QualityTestings f  with(nolock) on a.QTID=f.ID and a.QTID=@QTID --�ʼ쵥
			inner join M_MaterialProgresDetail b  with(nolock) on a.MPDID=b.id --���Ȼ㱨��ϸ
			where (case f.QTModel when 0 then 
						 b.NumQualified-a.NumScrap -isnull(a.NumBF,0) 
					else a.NumTesting-a.NumScrap-isnull(a.NumBF,0) END
				)>isnull((
					select isnull(sum(num1),0) 
					from kuinlist  with(nolock) 
					where del<>2 and QTLID=a.id),0) 
				)
		return 1
	ELSE IF 
		exists(
			select a.id 
			from M_QualityTestingLists a with(nolock) 	--�ʼ���ϸ
			inner join  M_QualityTestings f  with(nolock) on a.QTID=f.ID and a.QTID=@QTID --�ʼ쵥
			inner join M_MaterialProgresDetail b  with(nolock) on a.MPDID=b.id --���Ȼ㱨��ϸ
			where (case f.QTModel when 0 then 
						 b.NumQualified-a.NumScrap -isnull(a.NumBF,0) 
					else a.NumTesting-a.NumScrap-isnull(a.NumBF,0) END
				)<isnull((
					select isnull(sum(num1),0) 
					from kuinlist  with(nolock) 
					where del<>2 and QTLID=a.id),0) 
				)
		return 2
	else if exists(
			select a.id from M_wwQCList a  with(nolock) where a.QCID=@QTID and a.numok1>isnull((select isnull(sum(num1),0) 
			from kuinlist  with(nolock) where -QTLID=a.id and del=1),0) )
		return 1
	else if exists(
			select a.id from M_wwQCList a  with(nolock) where a.QCID=@QTID and a.numok1<isnull((select isnull(sum(num1),0) 
			from kuinlist  with(nolock) where -QTLID=a.id and del=1),0) )
		return 3
	else
		return 0
	return 0
end

GO

--�ʼ��Ƿ��ܱ������
CREATE function [dbo].[erp_QTCanBFRK](
	@QTID INT
) 
returns bit
BEGIN
	if exists(
			select a.id 
			from M_QualityTestingLists a with(nolock) 	--�ʼ���ϸ
			inner join  M_QualityTestings f  with(nolock) on a.QTID=f.ID and a.QTID=@QTID --�ʼ쵥
			inner join M_MaterialProgresDetail b  with(nolock) on a.MPDID=b.id --���Ȼ㱨��ϸ
			where isnull(a.NumBF,0)>isnull((
					select isnull(sum(num1),0)
					from kuinlist  with(nolock) 
					where del<>2 and BFID=a.id),0) 
				)
		return 1
	ELSE IF 
		exists(
			select a.id 
			from M_QualityTestingLists a with(nolock) 	--�ʼ���ϸ
			inner join  M_QualityTestings f  with(nolock) on a.QTID=f.ID and a.QTID=@QTID --�ʼ쵥
			inner join M_MaterialProgresDetail b  with(nolock) on a.MPDID=b.id --���Ȼ㱨��ϸ
			WHERE isnull(a.NumBF,0)<isnull((
					select isnull(sum(num1),0) 
					from kuinlist  with(nolock) 
					where del<>2 and BFID=a.id),0) 
				)
		return 2
	else
		return 0
	return 0
end

GO

--��ѯ��˾��ĳ�����ϰ���°�
CREATE  function [dbo].[HrComIsWork](@Today datetime,@uid int) returns int
as
begin
declare @num int
	set @num=(select (select case datepart(weekday,@Today) when 1 then open7  when 2 then open1 when 3 then open2 when 4 then open3 when 5 then open4 when 6 then open5 when 7 then open6 end) from hr_com_time where del=0 and (@Today between startTime and endTime)  and  ((isall=0 and charindex((','+cast(@uid as varchar(50))+','),(','+cast(user_list as varchar(4000))+','))>0) or isall=1))

	if @num is null
	begin
	set @num=0
	end

return @num
end

GO

--����id��,num��1������ƣ�2Ϊ��ɫ��3Ϊ�����ַ���3Ϊ�����ַ�
create function [dbo].[HrGetWorKClassName](@id int,@num int) returns varchar(200)
as
begin
declare @thisName varchar(200)

if @id<>'' and isnumeric(@id)=1 and isnumeric(@num)=1
begin

 set @thisName=  case @num when 1 then  (select title from hr_dayWorkTime where del=0 and id=@id) when 2 then (select
color from hr_dayWorkTime where del=0 and id=@id) when 3 then (select prefixCode from hr_dayWorkTime where del=0 and
id=@id) else '' end
end

else
begin
set @thisName=''
end
return @thisName
end

GO

create function [dbo].[hrGetResumeWebSite](@id int)
returns varchar(50)
begin
	declare @str varchar(50)
	select @str=isnull(title,'') from hr_resume_website  where id=@id and del=0
	return @str
end

GO

CREATE  function [dbo].[HrWageList](@wages int,@uid int,@wageSort int)
returns money
begin
declare @money money

if isnumeric(@uid)=1 and isnumeric(@wageSort)=1
begin
select @money=money1 from wageslist where wages=@wages and cateid=@uid and sort1=@wageSort
end

else
begin
return cast(0 as decimal(25, 12))
end

return isnull(@money,0)

end

GO

create function [dbo].[hrGetContractTime](@uid int)
returns datetime
begin
	declare @str datetime
	select @str=contractEnd from hr_person where userID=@uid and del=0
	return @str
end

GO

create function [dbo].[hrGetGateBH](@uid int)
returns varchar(50)
begin
	declare @str varchar(50)
	select @str=userbh from hr_person where userID=@uid and del=0
	return @str
end

GO

CREATE  function [dbo].[hrGetGateSalary](@uid int)
returns money
begin
	declare @sxTime datetime
	declare @mon money
	select @sxTime=max(startdate) from hr_person_salary where cateid=@uid and status=3 and del=0
	if @sxTime is not null
	begin
		select @mon=baseMoney from hr_person_salary where cateid=@uid and status=3 and startdate=@sxTime and del=0
	end
	else
	begin
		select @mon=BasicSalary from hr_person where userID=@uid and del=0
	end
	return @mon
end

GO

CREATE function [dbo].[HrGetBaseSalary]
(
	@StratDate datetime,
	@EndDate datetime,
	@uid INT
) returns money
as
begin
	declare @pubWorkDays money--ʵ�ʳ�������
	declare @pubNeedWorkDays money --Ӧ��������
	declare @count int --�ж��ǰ��µĵ�н�ƶ�
	declare @needSplit int --�����Ƿ�Ҫ�ֶ�
	declare @sxTime datetime-- ��Чʱ��
	declare @tempBasicWage money
	--�������� /ת������ /�����ڹ��� /��ְ���� / Ա��״̬��1Ϊ������2Ϊ��ʱ����3Ϊ��ְ
	declare @pubBasicWage MONEY , @pubReguldate DATETIME , @pubProbSalary MONEY , @pubEntrydate DATETIME,@nowStatus int
	select @pubBasicWage=BasicSalary,@pubReguldate=Reguldate,
		@pubProbSalary=ProbSalary,@pubEntrydate=Entrydate, @nowStatus=nowStatus 
	from hr_person where del=0 and userID=@uid  and datediff(d,Entrydate,@EndDate)>=0
	
	set @tempBasicWage=isnull(@pubBasicWage,0)
	if @pubBasicWage is null or @pubProbSalary is null or @pubEntrydate is null
	begin
		return cast(0 as decimal(25, 12))
	end
	else
	begin
		select @count=count(*) from hr_person_salary where cateid=@uid and datediff(d,startdate,@EndDate)>0 and status=3 and del=0
		if @count>0
		begin
			select @needSplit=count(*) from hr_person_salary where cateid=@uid  and datediff(d,startdate,@StratDate)<0 and datediff(d,startdate,@EndDate)>0 and status=3 and  del=0
			if @needSplit>0
			begin
				select @sxTime=max(startdate) from hr_person_salary where cateid=@uid  and datediff(d,startdate,@EndDate)>0 and status=3 and  del=0
				select @pubBasicWage=isnull(baseMoney,0) from hr_person_salary where cateid=@uid  and startdate=@sxTime and status=3 and  del=0
				set @pubNeedWorkDays=cast(dbo.HrGetMonthWorkDay(@StratDate,@EndDate,@uid) as decimal(25, 12))--Ӧ��������
				set @pubBasicWage=0
				declare @curTime datetime,@temMoney money,@temDateNum int,@temEndDate datetime,@setp int
				set @setp=0
				declare cur_1 cursor for select startdate from hr_person_salary where cateid=@uid  and datediff(d,startdate,@StratDate)<0 and datediff(d,startdate,@EndDate)>0 and status=3 and  del=0 group by startdate order by startdate desc
				open cur_1
				fetch next from cur_1 into @curTime
				while @@fetch_status=0
				begin
					select @temMoney=isnull(baseMoney,0) from hr_person_salary where cateid=@uid  and startdate=@curTime and status=3 and  del=0
					if @setp=0
					begin
						set @temDateNum=dbo.HrGetMonthWorkDay(@curTime,@EndDate,@uid)--������ʳ����˶�����
					end
					else
					begin
						set @temDateNum=dbo.HrGetMonthWorkDay(@curTime,@temEndDate,@uid)--������ʳ����˶�����
					end
					if @pubNeedWorkDays<>0 and @temDateNum>0
					begin
						set @pubBasicWage=@pubBasicWage+(@temMoney/@pubNeedWorkDays)*@temDateNum
					end
					set @setp=@setp+1
					set @temEndDate=dateadd(d,-1,@curTime)

					fetch next from cur_1 into @curTime
				end
				close cur_1                   --�ر��α�
				deallocate cur_1

				select @sxTime=max(startdate) from hr_person_salary where cateid=@uid  and datediff(d,startdate,@StratDate)>=0 and status=3 and  del=0
				set @temDateNum=dbo.HrGetMonthWorkDay(@StratDate,@temEndDate,@uid)--������ʳ����˶�����
				if isdate(@sxTime)=1
				begin
					select @temMoney=isnull(baseMoney,0) from hr_person_salary where cateid=@uid  and startdate=@sxTime and status=3 and  del=0
					if @pubNeedWorkDays<>0 and @temDateNum>0
					begin
						set @pubBasicWage=@pubBasicWage+(@temMoney/@pubNeedWorkDays)*@temDateNum
					end
				end
				else
				begin
					if @pubNeedWorkDays<>0 and @temDateNum>0
					begin
						set @pubBasicWage=@pubBasicWage+(@tempBasicWage/@pubNeedWorkDays)*@temDateNum
					end
				end
			end
			else
			begin
				select @sxTime=max(startdate) from hr_person_salary where cateid=@uid  and datediff(d,startdate,@EndDate)>0 and status=3 and  del=0
				select @pubBasicWage=isnull(baseMoney,0) from hr_person_salary where cateid=@uid  and startdate=@sxTime and status=3 and  del=0
			end
		end
		else
		begin
			/*���������㷨*/
			--��Ա������ʽԱ��
			if datediff(d,@pubReguldate,@StratDate)>=0 and  (@nowStatus=1 or @nowStatus=5 or  @nowStatus=3)
			begin
				set @pubBasicWage=@pubBasicWage
			end
			--ȫ��Ϊ������
			else if datediff(d,@pubReguldate,@StratDate)<0 and datediff(d,@pubReguldate,@EndDate)<=0  and   (@nowStatus=1 or @nowStatus=5 or @nowStatus=3) --Ա��״̬��1Ϊ������2Ϊ��ʱ����3Ϊ��ְ
			begin
				set @pubBasicWage=@pubProbSalary
			end
			--һ����Ϊ�����ڣ�һ������ת��
			else if  datediff(d,@pubReguldate,@StratDate)<0 and datediff(d,@pubReguldate,@EndDate)>=0  and  (@nowStatus=1 or @nowStatus=5 or @nowStatus=3)
			begin
				set @pubNeedWorkDays=cast(dbo.HrGetMonthWorkDay(@StratDate,@EndDate,@uid) as decimal(25, 12))--Ӧ��������
				if @pubNeedWorkDays>0
				begin
					--�����ڹ���*��������������+ת������*������Ӧ���������������ڹ����죩
					declare @ProWorkDayMoth int
					set @ProWorkDayMoth=dbo.HrGetMonthWorkDay(@StratDate,@pubReguldate,@uid)--���������ڹ�������
					set @pubBasicWage=(@pubProbSalary*(@ProWorkDayMoth/@pubNeedWorkDays))+@pubBasicWage*(1-(@ProWorkDayMoth/@pubNeedWorkDays))
				end
				else
				begin
					set @pubBasicWage=0
				end
			end
			else
			begin
				set @pubBasicWage=0
			end
		end
	end
	return @pubBasicWage
end

GO

CREATE function [dbo].[erp_getProductZDYFields](
	@tname as varchar(100)
)
returns varchar(4000)
as begin
	return dbo.[erp_getProductZDYFields_core](@tname,0)
end

GO

CREATE function [dbo].[erp_getProductZDYFields_core](
	@tname as varchar(100),
	@all int
) returns varchar(4000)
--���ݲ�Ʒ�Զ����ֶ��������ɲ�ѯ���ֶ�
--�����������.�������Ϊb�������ֵΪ'b.'������ޱ�����Ϊ''
as
begin
	declare @tmpstr as varchar(1000),@tmpfields as varchar(1000),@tmpname as varchar(1000),@title as varchar(50),@name as varchar(50),@sort as int
	set @tmpfields=''
	set @tmpname=''
	declare Cur_fname cursor for select title,name,sort from zdy where sort1=21 and (set_open=1 or @all=1) order by gate1, id
	open Cur_fname
	fetch next from Cur_fname into @title,@name,@sort
	while @@fetch_status=0
	begin
		if @sort=1
		begin
			set @tmpstr='cast(isnull((select top 1 sort1 from sortonehy where ord='+@tname+@name+') + ''^tag~''+cast('+@tname+@name+' as varchar(12)),'''') as nvarchar(100)) as ' + '[{us999999}'+@title+']'
		end
		else
		begin
			set @tmpstr= @tname+@name + ' as ' + '[{us999999}'+@title+']'
		end

		set @tmpfields=@tmpfields+','+@tmpstr
		fetch next from Cur_fname into @title,@name,@sort
	end
	close Cur_fname
	deallocate Cur_fname
	return @tmpfields
end

GO

create function [dbo].[erp_GetCPZdyFields](
	@cptb as varchar(100),
	@dbtb as varchar(100),
	@all int
) returns varchar(4000)
as
begin
	declare @result varchar(4000)
	set @cptb = case charindex('.',@cptb) when 0 then @cptb + '.' else @cptb end;
	set @dbtb = case charindex('.',@dbtb) when 0 then @dbtb + '.' else @dbtb end;
	set @result = ''
	select 
		@result = @result + ','+ 'isnull('+@dbtb+name + ','+@cptb+name + ') as ' + '[{us999999}'+title+']'
	from zdy  where sort1=21 and (set_open=1 or @all=1)
	order by gate1, id
	return @result
end

GO

create function [dbo].[fn_GetLunar](@solarday datetime)
returns nvarchar(30)
as
begin
  declare @soldata int
  declare @offset int
  declare @ilunar int
  declare @i int
  declare @j int
  declare @ydays int
  declare @mdays int
  declare @mleap int
  declare @mleap1 int
  declare @mleapnum int
  declare @bleap smallint
  declare @temp int
  declare @year nvarchar(10)
  declare @month nvarchar(10)
  declare @day nvarchar(10)
  declare @chinesenum nvarchar(10)
  declare @outputdate nvarchar(30)
  set @offset=datediff(day,'1900-01-30',@solarday)
  --ȷ��ũ���꿪ʼ
  set @i=1900
  --set @offset=@soldata
  while @i<2050 and @offset>0
  begin
    set @ydays=348
    set @mleapnum=0
    select @ilunar=dataint from M_SolarData where yearid=@i

    --����ũ�����������
    set @j=32768
    while @j>8
    begin
      if @ilunar & @j >0
        set @ydays=@ydays+1
      set @j=@j/2
    end
    --����ũ�������ĸ��� 1-12 , û�򴫻� 0
    set @mleap = @ilunar & 15
    --����ũ�������µ����� ,���������������
    if @mleap > 0
    begin
      if @ilunar & 65536 > 0
        set @mleapnum=30
      else
        set @mleapnum=29
      set @ydays=@ydays+@mleapnum
    end
    set @offset=@offset-@ydays
    set @i=@i+1
  end
  if @offset <= 0
  begin
    set @offset=@offset+@ydays
    set @i=@i-1
  end
  --ȷ��ũ�������
  set @year=@i
  --ȷ��ũ���¿�ʼ
  set @i = 1
  select @ilunar=dataint from M_SolarData where yearid=@year
  --�ж��Ǹ���������
  set @mleap = @ilunar & 15
  set @bleap = 0
  while @i < 13 and @offset > 0
  begin
    --�ж�����
    set @mdays=0
    if (@mleap > 0 and @i = (@mleap+1) and @bleap=0)
    begin--������
      set @i=@i-1
      set @bleap=1
      set @mleap1= @mleap
      --����ũ�������µ�����
      if @ilunar & 65536 > 0
        set @mdays = 30
      else
        set @mdays = 29
    end
    else
    --��������
    begin
      set @j=1
      set @temp = 65536
      while @j<=@i
      begin
        set @temp=@temp/2
        set @j=@j+1
      end

      if @ilunar & @temp > 0
        set @mdays = 30
      else
        set @mdays = 29
    end

    --�������
    if @bleap=1 and @i= (@mleap+1)
      set @bleap=0

    set @offset=@offset-@mdays
    set @i=@i+1
  end

  if @offset <= 0
  begin
    set @offset=@offset+@mdays
    set @i=@i-1
  end

  --ȷ��ũ���½���
  set @month=@i

  --ȷ��ũ���ս���
  set @day=ltrim(@offset)
  --�������
  set @chinesenum=N'��һ�����������߰˾�ʮ'
  while len(@year)>0
  select @outputdate=isnull(@outputdate,'')
         + substring(@chinesenum,left(@year,1)+1,1)
         , @year=stuff(@year,1,1,'')
  set @outputdate=@outputdate+N'��'
         + case @mleap1 when @month then N'��' else '' end
  if cast(@month as int)<10
    set @outputdate=@outputdate
         + case @month when 1 then N'��'
             else substring(@chinesenum,left(@month,1)+1,1)
           end
  else if cast(@month as int)>=10
    set @outputdate=@outputdate
         + case @month when '10' then N'ʮ' when 11 then N'ʮһ'
           else N'ʮ��' end
  set @outputdate=@outputdate + N'��'
  if cast(@day as int)<10
    set @outputdate=@outputdate + N'��'
         + substring(@chinesenum,left(@day,1)+1,1)
  else if @day between '10' and '19'
    set @outputdate=@outputdate
         + case @day when '10' then N'��ʮ' else N'ʮ'+
           substring(@chinesenum,right(@day,1)+1,1) end
  else if @day between '20' and '29'
    set @outputdate=@outputdate
         + case @day when '20' then N'��ʮ' else N'إ' end
         + case @day when '20' then N'' else
           substring(@chinesenum,right(@day,1)+1,1) end
  else
    set @outputdate=@outputdate+N'��ʮ'
  return @outputdate
end

GO

CREATE function [dbo].[hr_get_test_class](@id int)
returns varchar(50)
as
begin
declare @str varchar(50)
select @str=title from hr_sort where del=0 and cnID=@id
if @str is null
begin
	return '�޷���'
end
return @str
end

GO

CREATE  function [dbo].[hrGetSortName](@id int)
returns varchar(50)
begin
	declare @str varchar(50)
	select @str=title from hr_sort where cnID=@id
	return @str
end

GO

create  function [dbo].[HrGetPerformContent](@id int,@spid int,@cateid int,@typeid int)
returns varchar(4000)
as
begin

-- declare @id int,@spid int,@cateid int,@typeid int
--
-- set @id=1
-- set @spid=63
-- set @cateid=63
-- set @typeid=1

declare @str varchar(4000)
if isnumeric(@id)=1 and isnumeric(@typeid)=1 and isnumeric(@spid)=1 and isnumeric(@cateid)=1
begin
if @typeid=1
begin
select @str=content from hr_perform_Comments where del=0 and typeid=1 and perform=@id and cateid=@cateid and sp_id=@spid

end

else
begin
select @str=content from hr_perform_Comments where del=0 and typeid=0 and perform=@id and sp_id=@spid
end

end

else
begin
set @str=''
end

-- select @str

return @str
end

GO

CREATE function [dbo].[HrPerformTDNum](@id int) returns int
as
begin
declare @thisNum int

declare @project_list varchar(2000),@user_list varchar(2000),@isall int,@sortid int,@lv int,@projectNum int,@spNum int

select @project_list=project_list,@user_list=user_list,@isall=isall,@sortid=sortid,@lv=sp_lv from hr_perform_sort where del=0 and id=@id

select @projectNum=count(*) from  hr_perform_project where del=0 and charindex(','+cast(id as varchar)+',',','+@project_list+',')>0
select @spNum=count(*) from hr_perform_sp_list where sortid=@sortid and lv>0 and lv<=@lv

set @thisNum=@projectNum*@spNum+2
if @thisNum is null or isnumeric(@thisNum)=0 or @thisNum<0
begin
set @thisNum=0
end
return @thisNum


end

GO

create function [dbo].[hrGetTrainForm](@id int)
returns varchar(50)
begin
	declare @str varchar(50)
	select @str=title from hr_train_type where id=@id
	return @str
end

GO

CREATE function [dbo].[getHrNum](@id int,@spid int)
returns int
begin
	declare @num int

	if isnumeric(@id)=1 and isnumeric(@spid)=1
	begin
		select @num=count(*) from hr_perform_score where perform=@id and sp_id=@spid and del=0
	end

	else
	begin
		set @num=0
	end

	return @num
end

GO

CREATE   function [dbo].[HrGetPerformScore](@id int,@project int,@spid int,@cateid int,@typeid int)
returns float
as
begin
declare @Num float
if isnumeric(@id)=1 and isnumeric(@project)=1 and isnumeric(@spid)=1 and isnumeric(@cateid)=1
begin
if @typeid=1
begin
select @Num=score from hr_perform_score where del=0 and typeid=1 and perform=@id and cateid=@cateid and sp_id=@spid and project=@project
end

else
begin
select @Num=score from hr_perform_score where del=0 and typeid=0 and perform=@id and cateid=@cateid and sp_id=@spid and project=@project
end

end

else
begin
return cast(0 as decimal(25, 12) )
end

if @Num is null
begin
return cast(0 as decimal(25, 12) )
end

return @Num
end

GO

CREATE  function [dbo].[hrGetProcessName](@id int,@oid int)
returns varchar(100)
begin
	declare @str varchar(100)
	select @str=title from hr_process where orderID=@oid and cnID=@id and del=0
	return @str
end

GO

create function [dbo].[hrISMaxProcess](@id int)
returns int
begin
	declare @num int,@orderid int,@sortid int,@px1 int,@px2 int
	select @orderid=orderid,@sortid=sortid,@px1=px from hr_process where cnid=@id and del=0
	select @px2=max(px) from hr_process where orderid=@orderid and sortid=@sortid
	if @px2=@px1
	begin
		set @num=1
	end
	else
	begin
		set @num=0
	end
return @num
end

GO

CREATE     function [dbo].[hrTrainPlanHz](@startDate datetime,@endDate datetime,@uid int)
returns table
AS
return
(
select @startDate as ��ʼʱ��,@endDate as ��ֹʱ��, tB.�ƻ���ѵ���� as �ƻ���ѵ����_DOSUM,tB.ʵ����ɴ��� as ʵ����ɴ���_DOSUM,tB.��ѵ����� from
(
	select tA.�ƻ���ѵ����,tA.ʵ����ɴ���,case tA.�ƻ���ѵ���� when 0 then 0 else (cast(tA.ʵ����ɴ��� as decimal(25, 12) )/cast(tA.�ƻ���ѵ���� as decimal(25, 12) ))*100 end as ��ѵ����� from
	(
		select
		(
			select count(*) from hr_train_plan  where  status=3 and del=0 and
			(
				(datediff(d,@startDate,startTime)>=0 and datediff(d,@endDate,startTime)<=0)
				or (datediff(d,@startDate,endTime)>=0 and datediff(d,@endDate,endTime)<=0)
				or (datediff(d,@startDate,startTime)<0 and datediff(d,@endDate,endTime)>0)
			)
		)
		as �ƻ���ѵ����,
		(
			select count(*) from hr_train_plan a inner join hr_process b on a.statusID=b.cnID and b.orderid=1027 where b.px=(select max(px) from hr_process where orderid=1027) and a.status=3 and a.del=0 and
			(
				(datediff(d,@startDate,a.startTime)>=0 and datediff(d,@endDate,a.startTime)<=0)
				or (datediff(d,@startDate,a.endTime)>=0 and datediff(d,@endDate,a.endTime)<=0)
				or (datediff(d,@startDate,a.startTime)<0 and datediff(d,@endDate,a.endTime)>0)
			)
		)
		as ʵ����ɴ���
	) as tA
) as tB
)

GO

create function [dbo].[HrGetList_BillID](@id int)
returns int
begin
	declare @num int
	select @num=NeedPerson from hr_needperson_list where cnid=@id and del=0
	return @num
end

GO

create function [dbo].[HrNeadPersonStatusID](@id int)
returns int
begin
	declare @num int
	select  @num=count(*) from hr_NeedPerson_list where NeedPerson=@id and statusid=0 and del=0
	return @num
end

GO

create function [dbo].[HrGetPerformSortName](@id int)
returns varchar(200)
as
begin
declare @thisName varchar(200)
if isnumeric(@id)=1
begin
select @thisName=title from hr_perform_sort where  id=@id
end

else
begin
return null
end

return @thisName
end

GO

create function [dbo].[HrDateTimeBJ]()
returns int
begin
	declare @id int
	select top 1 @id=id from hr_train_plan where startTime>endTime and del=0
	return @id
end

GO

CREATE  function [dbo].[hrNeedAltPerson_contract](@uid int,@date datetime,@days int)
returns int
begin
	declare @num int
	select @num=count(*) from hr_person_contract where partB=@uid and  datediff(d,@date,endDate)>@days and del=0 and status=3
	return @num
end

GO

CREATE function [dbo].[erp_getBOMChild2](@BOMID int) returns varchar(4000)
begin
	declare @returnStr as varchar(4000),@ProductName as varchar(100),@BOM int , @Node int , @PNode int
	set @returnStr=''
	select @BOM=planlistid , @Node =BomID from M_planBOMList where id=@BOMID

	declare Cur_BOM cursor for
	select b.title from M_PlanBOMList a left join product b on a.ProductID=b.ord where a.ParentBomID=@Node and planlistid = @BOM
	open Cur_BOM
	fetch next from Cur_BOM into @ProductName
	while @@fetch_status=0
	begin
		if @returnStr=''
			set @returnStr=isnull(@ProductName,'��Ʒ��ɾ��')
		else
			set @returnStr=@returnStr+'+'+isnull(@ProductName,'��Ʒ��ɾ��')
		fetch next from Cur_BOM into @ProductName
	end
	close Cur_BOM
	deallocate Cur_BOM
	select @ProductName=b.title from M_PlanBOMList a left join product b on a.ProductID=b.ord where a.BomId=@Node and planlistid = @Bom
	if @returnStr=''
	begin
		set @returnStr=isnull(@ProductName,'��Ʒ��ɾ��')+'=��'+isnull(@ProductName,'��Ʒ��ɾ��')+'��'
	end
	else
	begin
		set @returnStr=isnull(@ProductName,'��Ʒ��ɾ��')+'=��'+@returnStr+'��'
	end
	return @returnStr
end

GO

create  function [dbo].[hrGetResumePostionNum](@id int)
returns int
begin
	declare @num int
		select @num=count(*) from hr_interview a left join hr_Resume b on b.id=a.resumeID   where b.postion=@id and a.status=3 and a.del=0
	return @num
end

GO

create function [dbo].[HrGetResumeName](@id int)
returns varchar(50)
as
begin
	declare @str varchar(50)
	select @str=userName from hr_Resume where id=@id
	return @str
end

GO

create function [dbo].[hrGetResumePersonNum](@id int)
returns int
begin
	declare @num int
		select @num=count(*) from hr_interview a left join hr_Resume b on b.id=a.resumeID   where b.planID=@id and a.status=3 and a.del=0
	return @num
end

GO

CREATE  function [dbo].[hrisTestAnswer](@uid int,@expaperID int)
returns int
begin
	declare @num int
	select @num=count(*) from hr_answer where expaperID=@expaperID and statusID in(1,2,3) and creator=@uid and del=0
	return @num
end

GO

CREATE function [dbo].[getCPClassPath](@currcls int)
returns varchar(6000) as begin
	declare @path varchar(6000)
	while exists(select * from menu where id=@currcls)
	begin
		select @path  = menuname + '$|$' + isnull(@path,'') ,@currcls=id1 from menu where id=@currcls
	end
	return  @path
end
GO

CREATE function [dbo].[getparentarea](@id int) returns  varchar(1000)
as begin
	declare @r varchar(1000)
	declare @p int
	if exists(select [id] from menuarea where [id]=@id)
	begin
		select @r = menuname , @p=id1  from menuarea where [id]=@id

		if len(dbo.getparentarea(@p))>0
			set @r = dbo.getparentarea(@p) + ',' + @r
	end
	else
	begin
		set @r= ''
	end
	return @r
end

GO

--�жϵ�нʱ���Ƿ�������
CREATE    function [dbo].[HrPersonSalaryID]()
returns int
as
begin

declare @startTime datetime,@cmpTime datetime,@thisID int,@uid int
select top 1 @thisID=id, @startTime=startdate,@uid=cateid from hr_person_salary where del=0 order by id desc
select @cmpTime=max(startdate) from hr_person_salary where cateid=@uid and del=0
if @startTime=@cmpTime
begin
set @thisID=null
end


return @thisID
end

GO

CREATE function [dbo].[erp_getstartDateByEndDate_2](
	@endDate datetime,
	@WorkHour money
) returns datetime as
begin
	--�����깤���ڻ�ȡ��������
	declare @DayWorkHour money --ÿ�չ���Сʱ
	declare @r datetime
	select @DayWorkHour=cast(intro as decimal(25, 12)) from setopen where sort1=18002
	set @r = dbo.erp_deleteDate(@endDate ,@WorkHour/@DayWorkHour)
	return @r
end

GO

create function [dbo].[P_GetPerson](@id int)
returns varchar(50)
begin
	declare @Str varchar(50)
	select @Str=name from person where ord=@id
	return @Str
end

GO

create function [dbo].[SNGetPersonName](@id int)
returns varchar(100)
begin
declare @name varchar(100)

if isnumeric(@id)=1 and @id is not null
begin
select @name=name from person where del=1 and ord=@id
end

else
begin
return ''
end

return @name

end

GO

create function [dbo].[erp_CheckUserPower](@uid int,@sort1 int,@sort2 int,@Creator int) returns bit
begin
	declare @qx_open as int,@qx_intro as varchar(4000),@returnValue bit
	select @qx_open=qx_open,@qx_intro=cast(qx_intro as varchar(4000)) from [power] where ord=@uid and sort1=@sort1 and sort2=@sort2
	set @qx_open=isnull(@qx_open,0)
	set @qx_intro=isnull(@qx_intro,'0')
	if @qx_open=3 or (@qx_open=1 and charindex(','+cast(@Creator as varchar(15))+',',','+replace(@qx_intro,' ','')+',')>0)
		set @returnValue=1
	else
		set @returnValue=0
	return @returnValue
end

GO

CREATE function [dbo].[erp_CreateLink_billmx](
--���ݲ�����������,�����erp_CreateLink�ļ��� ,ֻ���ڴ�����������
@StrTitle varchar(200),--�����ı�
@oid varchar(15),--������������ǵ�������������ú�
@ID varchar(15), --����ID
@Creator int, --������
@uid int,--��ǰ�û�
@qxlb int --��Ȩ�޺�
) returns varchar(4000)
begin
	declare @rValue varchar(4000),@url varchar(1000)
	if exists(
			select
				qx_open
			from [power] a,(
				select sort from qxlblist where sort1=@qxlb and sort2=14
			)  b
			where (a.ord=@uid and sort1=@qxlb and sort2=14)
				  and (
					qx_open=sort or
					(qx_open=1 and charindex(',' + cast(@creator as varchar(12)) + ',', ','+replace(cast(qx_intro as varchar(4000)),' ','')+',') > 0)
				)
	)
		set @rValue='<span class=link title="�鿴������ϸ����" onmouseover=Bill.showunderline(this,"#ff0000") onclick=ck.SpShowList(' + cast(@oid as varchar(12)) + ','
				 + cast(@ID as nvarchar(15)) + ',0,''detail'') onmouseout=Bill.hideunderline(this,"#0000ff")>'+@StrTitle+'</span>'
   else
		set @rValue=@StrTitle

	return @rValue
end


GO


CREATE function [dbo].[erp_CreateLink_smp](
--���ݲ�����������,�����erp_CreateLink�ļ���
@StrTitle varchar(200),--�����ı�
@LinkType int,--�������ͣ�1�����ݣ�2���ˣ�3����Ʒ
@OrderType varchar(15),--������������ǵ�������������ú�
@ID varchar(15), --����ID
@Creator int, --������
@uid int,--��ǰ�û�
@sort1 int --��Ȩ�޺�
) returns varchar(4000)
begin
	declare @sort2 int --��Ȩ�޺�
	declare @rValue varchar(4000),@url varchar(1000)
	declare @qx_type int,@qx_open int,@qx_intro varchar(4000),@hasPower bit
	set @sort2 = 14  ---14��ʾ��ϸ�鿴Ȩ��
	if @LinkType=2
		--set @rValue='<a href="###" class=com onclick="Bill.LinksPeople('''+@ID+''')">'+@StrTitle+'</a>'
		set @rValue=@StrTitle
	else
	begin
		select @qx_type=sort from qxlblist where sort1=@sort1 and sort2=@sort2
		set @qx_type=isnull(@qx_type,-1)
		select top 1 @qx_open=qx_open,@qx_intro=cast(qx_intro as varchar(4000)) from power where ord=@uid and sort1=@sort1 and sort2=@sort2
		set @qx_open=isnull(@qx_open,0)
		set @qx_intro=isnull(@qx_intro,'')
		if @qx_open=@qx_type or (@qx_open=1 and charindex(','+cast(@Creator as varchar(15))+',',','+replace(@qx_intro,' ','')+',')>0)
		begin
			if @LinkType=1
				set @rValue='<span class=link title="�鿴������ϸ����" onmouseover=Bill.showunderline(this,"#ff0000") onclick=ck.SpShowList(' + @OrderType + ','
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

create function [dbo].[erp_canreadcplist](@uid int) returns int as  begin
	declare @r int
	--�Ƿ���Ȩ�޲鿴��Ʒ��ϸ
	if exists(select isnull(qx_open,0) from power where ord=@uid and sort1=21 and sort2=14)
	begin
		set @r = 1
	end
	else
	begin
		set @r = 0
	end
	return @r
end

GO

CREATE function [dbo].[erp_qxlb_xqqxList](@qxlb int,@uid int) returns varchar(7000) as begin
	declare @qxlist varchar(7000)
	--��ȡ����鿴Ȩ���б�
	select @qxlist = (case qx_open when 1 then ',' + replace(cast(qx_intro as varchar(7000)) + ',',' ','') when 3 then '' else '0' end)
	from [power] where sort1=@qxlb and sort2=14 and ord=@uid
	set  @qxlist = isnull(@qxlist,'')
	return @qxlist
end
GO




CREATE    function [dbo].[HrCreatPerformLink]( @StrTitle varchar(500),@ord varchar(15),@Creator int, @uid int,
@sp int,@qxlb int ) returns varchar(4000)begin	declare @rValue varchar(4000),@url varchar(1000)	if exists(			select 				qx_open			from [POWER] a,(				select sort from qxlblist where sort1=@qxlb and sort2=1			)  b 			where (a.ord=@uid and sort1=@qxlb and sort2=1 and @sp=@uid) 				  and (					qx_open=sort or 					(qx_open=1 and CHARINDEX(',' + cast(@creator as varchar(12)) + ',', ','+REPLACE(cast(qx_intro as varchar(4000)),' ','')+',') > 0)				)	)
if @StrTitle='�޸ļ�Ч'
begin		set @rValue='<BUTTON onclick="window.open(''../../hrm/perform_ss.asp?ssid='+cast(@ord as varchar(1000))+''')" class="button">'+@StrTitle+'</BUTTON>'end

else
begin
set @rValue=@StrTitle
end

else
begin
set @rValue=@StrTitle
end

return @rValue
end

GO

create  function [dbo].[hrSumPostionHadNum](@planID int,@postionID int)
returns int
begin
declare @num int
	select @num=sum(HadNum) from hr_plan_list where postion=@postionID and planID=@planID and del=0
	return @num
end

GO

CREATE  function [dbo].[hrSumPostionNum](@planID int,@postionID int)
returns int
begin
declare @num int
	select @num=sum(num) from hr_plan_list where postion=@postionID and planID=@planID  and del=0
	return @num
end

GO

CREATE function [dbo].[hrGetRetPlanNum](@id int)
returns int
begin
	declare @num int
	select @num=sum(isnull(num,0)) from hr_plan_list where planID=@id
	return @num
end

GO

create  function [dbo].[hrGetRetPlanHadNum](@id int)
returns int
begin
	declare @num int
	select @num=sum(isnull(HadNum,0)) from hr_plan_list where planID=@id
	return @num
end

GO

CREATE function [dbo].[hrGetPostionName](@id int)
returns varchar(50)
begin
declare @name varchar(50)
select @name=title from hr_pub_postion where id=@id
return @name
end

GO

CREATE       function [dbo].[HrListReinstate](@uid int,@typ int)
returns table
AS
return
(

select
a.ID,
dbo.erp_CreateLink(a.gateName,1,1041,a.id,a.Creator,@uid,90,12) as ��Ա,
a.sorceName as ����,
a.sorce2Name as С��,
a.postion as ְλ,
a.indate as ��������
from hr_reinstate a  where (a.del = 0 and @typ =1 ) or (@typ = 0 and a.del=1)

)

GO

--�жϽ����Ƿ�Ҫ�ϰ����Ϣ1Ϊ�ϰ࣬2Ϊ��Ϣ��3Ϊ�ż٣�4Ϊ�ڼٵ��ݣ�0Ϊ��ʼ�����쳣
CREATE      function [dbo].[HrTodayNeedWork](@today datetime,@uid int) returns int
as
begin


declare @todayNeedWork int
	--���Ʋ���
	declare @HR_login_M int,@HR_leave_M int ,@HR_overtime_M int,@HR_work_H int,@HR_login_Pat int,@HR_overtime_to_int int,@HR_hoDay_Ref int,@HR_comType int,@HR_Test int
	select @HR_login_M=login_M*60,@HR_leave_M=leave_M*60,@HR_overtime_M=overtime_M*60,@HR_work_H=work_H,@HR_login_Pat=login_Pat,@HR_overtime_to_int=overtime_to_int,@HR_hoDay_Ref=hoDay_Ref*60,@HR_comType=companyType,@HR_Test=publicTest from hr_KQ_config where del=0 and datediff(d,startTime,@Today)>=0 and datediff(d,endTime,@Today)<=0
--���ڼƻ�
if @HR_comType=1
begin
set @todayNeedWork=dbo.HrComIsWork(@today,@uid)
end

else if @HR_comType=2
begin
set @todayNeedWork=dbo.HrFcIsWork(@today,@uid)
end

else
begin
return 0
end

--�ж��Ƿ��ǽڼ���
--��Ϣ
if @HR_Test=1
begin

if @todayNeedWork=1
begin
declare @holidayNum int
set @holidayNum=(select count(*) from hr_holiday where del=0 and charindex('|'+replace(cast(convert(varchar(10),@today,120) as varchar(2000)),'-0','-')+'|','|'+replace(noNeedWork,'-0','-')+'|')>0)
if @holidayNum>0
begin
set @todayNeedWork=3
end

end

else if @todayNeedWork=2
begin

declare @holidayNum1 int
set @holidayNum1=(select count(*) from hr_holiday where del=0 and charindex('|'+replace(cast(convert(varchar(10),@today,120) as varchar(2000)),'-0','-')+'|','|'+replace(NeedWork,'-0','-')+'|')>0)

if @holidayNum1>0
begin
set @todayNeedWork=4
end

else
begin
	return 2
end

end

end

--�����ϰ�
else if @HR_Test=2
begin
set @todayNeedWork=@todayNeedWork
end

else
begin
return 0
end

if @todayNeedWork is null
begin
return 0
end

return @todayNeedWork
end

GO

CREATE  function [dbo].[HrGetPerformSalary](
@StratDate datetime,
@EndDate datetime,
@uid int
)
returns money
as
begin
	declare @salaryClass int,@ord int,@flag varchar(2000)
	declare @tallScore float,@thisMoney money,@baseSalary money
	if isdate(@StratDate)=1 and isdate(@EndDate)=1 and isnumeric(@uid)=1
		begin
			set @thisMoney=cast(0 as decimal(25, 12) )
			declare @Score float,@unittype int,@title varchar(50)
			declare cur_4 cursor for select salaryClass,id from hr_perform_sort where del=0 and (charindex(','+cast(@uid as varchar(50))+',',','+cast(user_list as varchar(4000))+',')>0 or isall=1) and datediff(d,@StratDate,salary_time)>=0 and datediff(d,@EndDate,salary_time)<=0
			open cur_4
			fetch next from cur_4 into @salaryClass,@ord
			while @@fetch_status=0
				begin
					set @tallScore=dbo.HrGetPerformScore(@ord,0,0,@uid,0)--�õ���Ч�ܷ�
					select @flag=salaryClass from hr_perform_result_list where sortid=@salaryClass and del=0 and [lower]<=@tallScore and limit>=@tallScore
					if @flag is not null and len(@flag)>0
						begin
							set @flag=replace(@flag,'{����ʵ�ʵ÷�}',@tallScore)
							if charindex('{��������}',@flag)>0
							begin
								set @baseSalary=dbo.HrGetBaseSalary(@StratDate,@EndDate,@uid)
								set @flag=replace(@flag,'{��������}',cast(@baseSalary as varchar(4000)))
							end
							set @thisMoney=@thisMoney+dbo.eval(@flag)
						end
					
					fetch next from cur_4 into @salaryClass,@ord
				end
			close cur_4                   --�ر��α�
			deallocate cur_4
		end
	else
		begin
			return cast(0 as decimal(25, 12))
		end
	return @thisMoney
end

GO

CREATE    function [dbo].[HrGetPerformContentList](@id int,@spid int,@cateid int,@typeid int)
returns varchar(4000)
as
begin

declare @str varchar(4000),@con varchar(4000),@check_con varchar(4000)
if isnumeric(@id)=1 and isnumeric(@typeid)=1 and isnumeric(@spid)=1 and isnumeric(@cateid)=1
begin
if @typeid=1
begin


set @str=''
			declare cur_3 cursor for select dbo.HrGetCateName(sp_id)+':'+cast(content as varchar(2000)) as list, cast(content as varchar(2000)) as list1  from hr_perform_Comments where del=0 and typeid=1 and perform=@id and cateid=@cateid
			open cur_3
			fetch next from cur_3 into @con,@check_con
			while @@fetch_status=0
				begin
					if @check_con<>'' and @check_con is not null
					begin
						set @str=''+@con+'<br/>'+''+@str
					end

				fetch next from cur_3 into @con,@check_con
				end
			close cur_3                   --�ر��α�
			deallocate cur_3
end

else
begin

set @str=''
			declare cur_3 cursor for select dbo.HrGetCateName(sp_id)+':'+cast(content as varchar(2000)) as list, cast(content as varchar(2000)) as list1  from hr_perform_Comments where del=0 and typeid=0 and perform=@id
			open cur_3
			fetch next from cur_3 into @con,@check_con
			while @@fetch_status=0
				begin
					if @check_con<>'' and @check_con is not null
					begin
						set @str=''+@con+'<br/>'+''+@str
					end
				fetch next from cur_3 into @con,@check_con
				end
			close cur_3                   --�ر��α�
			deallocate cur_3
end

end

else
begin
set @str=''
end


return @str
end

GO

CREATE      function [dbo].[HrConfigList]
(
	@uid int ,@typ int
)	returns  table
AS
return
(
	SELECT ID,
	dbo.HrGetCompanyTypeName(companyType) as ��������,
	startTime AS ��ʼʱ��,
	endTime as ��ֹʱ��,
	dbo.HrGetCateName(creator) as �����,
	inDate AS �������
	FROM dbo.hr_KQ_config a
	WHERE (a.del = 0 and @typ =1 ) or (@typ = 0 and a.del=1)
)

GO

CREATE     function [dbo].[HrJxSSList]
(
	@uid int ,@typ int
)	returns  table
AS
return
(
	SELECT ID,
	dbo.HrGetPerformSortName(perform_sortid) as ��������,
	dbo.erp_CreateLink_billmx(a.title,1015,a.id,a.Creator,@uid,81) AS ��������,
	content as ��������,
	dbo.HrGetCateName(creator) as ������,
	inDate AS ��������,
dbo.HrCreatPerformLink(''+case changePerform when 1 then '���޸�' when 0 then '�޸ļ�Ч' else 'δ�޸�' end+'',id,creator,@uid,cateid_sp,81) as �޸ļ�Ч,cateid_sp as #hide_spid,status as #hide_status
	FROM dbo.hr_perform_ss  a
	WHERE (a.del = 0 and @typ =1 ) or (@typ = 0 and a.del=1)
)

GO

CREATE    function [dbo].[HrGetLoginContent](@taday datetime,@uid int)returns varchar(5000)
as
begin


declare @result varchar(5000),@gateName varchar(200),@content varchar(5000),@addcate int,@editcate int,@adddate datetime,@editdate datetime
if isdate(@taday)=1 and isnumeric(@uid)=1
begin
select @content=content,@addcate=creator,@editcate=editCate, @adddate=inDate,@editdate=editTime from hr_login_con where datediff(d,today,@taday)=0 and cateid=@uid
if @editcate is not null
begin
set @addcate=@editcate
set @adddate=@editdate
end

if @addcate is not null
begin
set @gateName='('+dbo.HrGetCateName(@addcate)+' ʱ��:'+cast(convert(varchar(100),@adddate,120) as varchar(100))+')'
end

set @result=@content+@gateName
end

else
begin
return null
end


return @result
end

GO

CREATE    function [dbo].[HrPerformProList]
(
	@uid int ,@typ int
)	returns  table
AS
return
(

select ID,
dbo.erp_CreateLink(a.title,1,1014,a.id,a.Creator,@uid,81,12) as ��Ŀ����,
base as ��׼��,prop as Ȩ��,( case isnull(isopen,0) when 0 then '����' else 'ͣ��' end ) as �Ƿ�����,dbo.HrGetCateName(creator) as �����,indate as ���ʱ�� from hr_perform_project a where  (a.del = 0 and @typ =1 ) or (@typ = 0 and a.del=1)
)

GO

CREATE   function [dbo].[HrListPersonSalary](@uid int,@typ int)
returns table
AS
return
(

select
a.ID,
dbo.erp_CreateLink(ISNULL((SELECT TOP 1 name FROM gate WHERE ord = a.cateid), '�û�' + CAST(a.cateid AS varchar(10)) + '����ɾ��'),1,1018,a.id,a.Creator,@uid,91,12) as ��Ա,
a.oldMoney as ԭнˮ,
a.baseMoney as ��нˮ,
a.startdate as ��Чʱ��,
dbo.hrGetCateName(a.creator) as �����,
a.indate as ʱ��
from hr_person_salary a  where (a.del = 0 and @typ =1 ) or (@typ = 0 and a.del=1)

)

GO

CREATE   function [dbo].[HrListPositiveTime](@uid int,@typ int,@now datetime)
returns table
AS
return
(
select a.ID,
dbo.HrGetCateName(a.UserID) as Ա������,
a.userbh as Ա�����,
dbo.hrGetPostion_sorceName(a.PostionID) as ְλ,
a.Entrydate as ��ְ����,
a.Reguldate as ת������,
case sign(datediff(d,@now,a.Reguldate))
when 1 then cast(datediff(d,@now,a.Reguldate) as varchar(50))+'��'
else '�ѳ�' + cast(abs(datediff(d,@now,a.Reguldate)) as varchar(50)) + '��'
end
  as ����ת��
from hr_person a left join setjm b on @uid=b.cateid left join power P on b.cateid = P.ord and P.sort1=87 and P.sort2=1 where datediff(d,@now,a.Reguldate)<=isnull(b.tq1,0) and a.nowStatus=5 and b.ord=59 and a.del=0 and (P.qx_open=3 or (P.qx_open=1 and charindex(','+cast(a.UserID as varchar(10))+',',','+cast(P.qx_intro as varchar(2000))+',')>0)) 
)

GO

create  function [dbo].[HrListPerson](@uid int,@typ int)
returns table
AS
return
(

select
a.ID,
dbo.HrGetCateName(a.userid) as ��Ա,
a.userbh as Ա�����,
dbo.hrGetPostion_sorceName(a.postionid) as ְλ,
(case a.sex when 0 then 'Ů'when 1 then '��' else '' end) as �Ա�,
a.mobile as �ֻ�,
a.email as ����,
a.indate as �������
from hr_person a  where (a.del = 0 and @typ =1 ) or (@typ = 0 and a.del=1)

)

GO

CREATE function [dbo].[erp_list_wldb_fun](@uid int,@dtype int)
returns table as return
(
	select
		a.ID,
		a.sn as ��������,
		dbo.erp_CreateLink_billmx(a.title,28,a.id,a.creator,@uid,5028) as ����,
		dbo.erp_CreateLink_billmx(b.title,8,b.id,b.creator,@uid,54) as �����ɹ���,
		dbo.erp_CreateLink_billmx(d.MOBH,2,d.id,d.creator,@uid,51) as ��������,
		dbo.erp_CreateLink_billmx(c.title,8,c.id,c.creator,@uid,54) as �����ɹ���,
		dbo.erp_CreateLink_billmx(e.MOBH,2,e.id,e.creator,@uid,51) as ���붩��,
		a.mvDate as ��������,
		(select top 1 name from gate x where x.ord=a.rMan) as ������,
		a.indate as �������,
		(select top 1 name from gate x where x.ord=a.creator) as �����,
		a.remark as ��ע
	from M_MaterialMove a
	left join M_WorkAssigns b on a.WAID = b.ID
	left join M_WorkAssigns c on a.newWAID = c.ID
	left join M_ManuOrders d on a.DDNO = d.ID
	left join M_ManuOrders e on a.newDDno = e.ID
	where a.del=1-@dtype  and a.tempsave=0
)

GO

CREATE  function [dbo].[erp_list_design_fun]
( @uid int , @typ int )
 returns  table  as return(
	SELECT top 100000 ID, DesignBH AS ��Ʊ��, dbo.erp_CreateLink(a.title,1,31,a.id,a.designer,@uid,5029,14) AS �������,
	dbo.erp_CreateLink(ISNULL((SELECT TOP 1 name FROM gate WHERE ord = a.creator), '�û�' + CAST(Creator AS varchar(10)) + '����ɾ��'),2,0,a.Creator,0,0,0,0)
	 AS �����, indate AS ���ʱ��,(select name from gate where ord=a.delcate) AS ɾ����Ա, deltime AS ɾ��ʱ��,
	intro AS ��ע
	FROM dbo.design a
	WHERE (del = 1 and TempSave = 0 and @typ = 1 ) or (@typ = 0 and del=2)
)

GO

CREATE  function [dbo].[erp_list_bom_fun]( 
	@uid int , 
	@typ int ,
	@indate_1 varchar(20),
	@indate_2 varchar(20),
	@title varchar(4000),
	@BOMBH varchar(4000),
	@cptitle varchar(4000),
	@cpbh varchar(4000),
	@cpxh varchar(4000)
) returns  table  
as 
return(
	SELECT top 100000 ID, BOMBH AS BOM���, dbo.erp_CreateLink(a.title,1,5,a.id,a.Creator,@uid,56,14) AS BOM����,
	dbo.erp_CreateLink(ISNULL((SELECT TOP 1 name FROM gate WHERE ord = a.creator), '�û�' + CAST(Creator AS varchar(10)) + '����ɾ��'),2,0,a.Creator,0,0,0,0)
	 AS �����, convert(varchar(10),indate,120) AS ���ʱ��, DateBegin AS ��Ч����, DateEnd AS ��������,
	intro AS ��ע
	FROM dbo.M_BOM a
	full join (select top 1 uid from M_CurUser where ID=SCOPE_IDENTITY()) b on 1=1
	WHERE 
		((del = 0 and TempSave = 0 and @typ = 1 ) or (@typ = 0 and del=1))
		and (len(@indate_1)=0 or convert(varchar(10),indate,120)>=@indate_1+'')
		and (len(@indate_2)=0 or convert(varchar(10),indate,120)<=@indate_2+'')
		and (len(@title)=0 or a.title like '%'+@title+'%')
		and (len(@BOMBH)=0 or BOMBH like '%'+@BOMBH+'%')
		and (len(@cptitle)=0 or EXISTS(SELECT 1 FROM M_BOMlist m 
										INNER JOIN product p ON m.BOM=a.id and p.ord=m.ProductID AND p.del=1 
																AND p.title LIKE '%'+ @cptitle +'%' ))
		and (len(@cpbh)=0 or EXISTS(SELECT 1 FROM M_BOMlist m 
										INNER JOIN product p ON m.BOM=a.id and p.ord=m.ProductID AND p.del=1 
																AND p.order1 LIKE '%'+ @cpbh +'%' ))
		and (len(@cpxh)=0 or EXISTS(SELECT 1 FROM M_BOMlist m 
										INNER JOIN product p ON m.BOM=a.id and p.ord=m.ProductID AND p.del=1 
																AND p.type1 LIKE '%'+ @cpxh +'%' ))
	
)

GO
--�����б�
create function [dbo].[HrListAppholiday3](
	@uid int ,@typ int
)	returns  table
AS
return
(
	SELECT ID,
	dbo.erp_CreateLink(a.title,1,1003,a.id,a.Creator,@uid,80,12) AS ����,
	startTime as ��ʼʱ��,
	endTime as ����ʱ��,
	dbo.HrKQClassName(a.KQClass) as ��������,
	inDate AS �������,
	dbo.erp_CreateLink(ISNULL((SELECT TOP 1 name FROM gate WHERE ord = a.creator), '�û�' + CAST(Creator AS varchar(10)) + '����ɾ��'),2,0,a.Creator,0,@uid,0,0) AS ������,
	content AS ��ע,cateid_sp as #hide_spid,status as #hide_status
	FROM dbo.hr_AppHoliday  a
	WHERE (KQClass in(select id from hr_KQClass where sortID=3 and del=0) or KQClass=3) and ((@typ = 1 and del = 0  and tempsave=0 ) or (@typ = 0 and del = 1 ))
)

GO
--�Ӱ��б�
CREATE function [dbo].[HrListAppholiday2](
	@uid int ,@typ int
)	returns  table
AS
return
(
	SELECT ID,
	dbo.erp_CreateLink(a.title,1,1002,a.id,a.Creator,@uid,80,12) AS ����,
	startTime as ��ʼʱ��,
	endTime as ����ʱ��,
	dbo.HrKQClassName(a.KQClass) as ��������,
	inDate AS �������,
	dbo.erp_CreateLink(ISNULL((SELECT TOP 1 name FROM gate WHERE ord = a.creator), '�û�' + CAST(Creator AS varchar(10)) + '����ɾ��'),2,0,a.Creator,0,@uid,0,0) AS ������,
	content AS ��ע,cateid_sp as #hide_spid,status as #hide_status
	FROM dbo.hr_AppHoliday  a
	WHERE (KQClass in(select id from hr_KQClass where sortID=2 and del=0) or KQClass=2) and ((@typ = 1 and del = 0  and tempsave=0 ) or (@typ = 0 and del = 1 ))
)

GO
--����б�
create  function [dbo].[HrListAppholiday1](
	@uid int ,@typ int
)	returns  table
AS
return
( --���ڷ����б�
	SELECT ID,
	dbo.erp_CreateLink(a.title,1,1001,a.id,a.Creator,@uid,80,12) AS ����,
	startTime as ��ʼʱ��,
	endTime as ����ʱ��,
	dbo.HrKQClassName(a.KQClass) as ��������,
	inDate AS �������,
	dbo.erp_CreateLink(ISNULL((SELECT TOP 1 name FROM gate WHERE ord = a.creator), '�û�' + CAST(Creator AS varchar(10)) + '����ɾ��'),2,0,a.Creator,0,@uid,0,0) AS ������,
	content AS ��ע,cateid_sp as #hide_spid,status as #hide_status
	FROM dbo.hr_AppHoliday  a
	WHERE (KQClass in(select id from hr_KQClass where sortID=1 and del=0) or KQClass=1) and ( (@typ = 1 and del = 0 and tempsave=0) or (@typ = 0 and del = 1 ))
)

GO

CREATE    function [dbo].[HrListAppholiday]
(
	@uid int ,@kdclass int,@typ int
)	returns  table
AS
return
( --���ڷ����б�
	SELECT ID,
	dbo.erp_CreateLink(a.title,1,1009,a.id,a.Creator,@uid,80,12) AS ����,
startTime as ��ʼʱ��,
endTime as ����ʱ��,
dbo.HrKQClassName(a.KQClass) as ��������,
inDate AS �������,
dbo.erp_CreateLink(ISNULL((SELECT TOP 1 name FROM gate WHERE ord = a.creator), '�û�' + CAST(Creator AS varchar(10)) + '����ɾ��'),2,0,a.Creator,0,@uid,0,0) AS ������,
	content AS ��ע
	FROM dbo.hr_AppHoliday  a
	WHERE (KQClass in(select id from hr_KQClass where sortID=@kdclass and del=0) or KQClass=@kdclass) and ((@typ = 1 and del = 0 ) or (@typ = 0 and del = 1 ))
	and appType=1
)

GO

CREATE function [dbo].[HrListTransfer](@uid int,@typ int)
returns table
AS
return
(
	select
		a.ID,
		dbo.erp_CreateLink(a.title,1,1038,a.id,a.Creator,@uid,88,12) as ��������,
        a.bh as �������,
		dbo.erp_CreateLink(dbo.erp_CreateLink(ISNULL((SELECT TOP 1 name FROM gate WHERE ord = a.cateid), '�û�' + CAST(a.cateid AS varchar(10)) + '����ɾ��'),2,0,a.cateid,0,@uid,0,0),1,1038,a.id,a.cateid,@uid,88,12) as Ա������,
		dbo.hrGetGateBH(a.cateid) as Ա�����,
		dbo.hrGetPostion_sorceName(a.postionid) as ��ְλ,
		a.ysorceName as ԭ����,
		a.ysorce2Name as ԭС��,
		a.ypostion as ԭְλ,
		dbo.hrGetSortName(a.sortID) as ��������,
		a.indate as �������
	from hr_Transfer a
	where TempSave = 0 and isnull(a.cateid,0)>0 and ((a.del = 0 and @typ =1 ) or (@typ = 0 and a.del=1))
) 

GO

CREATE function [dbo].[HrListPositive](@uid int,@typ int)
returns table
AS
return
(
	select
		a.ID,
		dbo.erp_CreateLink(a.title,1,1037,a.id,a.cateid,@uid,87,12) as �������,
		a.bh as ������,
		dbo.erp_CreateLink(ISNULL((SELECT TOP 1 name FROM gate WHERE ord = a.cateid), '�û�' + CAST(a.cateid AS varchar(10)) + '����ɾ��'),2,0,a.cateid,0,@uid,0,0) as ��Ա,
		dbo.HrGetSorceNameFun(a.cateid,1) as ����,
		dbo.HrGetGatePostion(a.cateid) as ְλ,
		a.indate as ����ʱ��
	from hr_positive a
	where TempSave = 0 and ((a.del = 0 and @typ =1 ) or (@typ = 0 and a.del=1))
)

GO

CREATE function [dbo].[erp_list_scjh_fun]
( @uid int , @typ int )
returns table
as return
(
	--TASK.1121.binary
	SELECT ID, (MPSBH+ (case  a.del when 7 then '<span style=color:red>(�Զ�����)</span>' else '' end)) AS �ƻ�����,
	dbo.erp_CreateLink(a.title,1,3,a.id,a.Creator,@uid,50,14) AS ����,
	(CASE WHEN CreateFrom = 1 THEN '��ͬ' WHEN CreateFrom = 2 THEN 'Ԥ�ⵥ' WHEN CreateFrom = 3 THEN '��Ŀ' END) AS �ƻ���Դ,
	(case when isnull(c.MPSID,0) = 0 or c.zeroCnt = c.totalCnt then 'δ����' when eqCnt = totalCnt then 'ȫ������' else '��������' end) as ����״̬,
	(CASE 
		WHEN CreateFrom = 1 THEN (SELECT TOP 1 '��ͬ��:' + b.htid FROM contract b WHERE b.ord = a.fromid)
		WHEN CreateFrom = 2 THEN (SELECT TOP 1 'Ԥ�ⵥ:' + b.PredictBH FROM M_PredictOrders b WHERE b.ID = a.fromid)
		WHEN CreateFrom = 3 THEN (SELECT TOP 1 '��Ŀ��:' + b.xmid FROM chance b WHERE b.ord = a.fromid)
	END) AS ��Դ����,
	dbo.erp_CreateLink(ISNULL((SELECT TOP 1 name FROM gate WHERE ord = a.creator), '�û�' + CAST(Creator AS varchar(10)) + '����ɾ��'),2,0,a.Creator,0,@uid,0,0) AS �����,
	T1 as ��������,
	T2 as �깤����,
	T3 as ��������,
	inDate AS ���ʱ��,
	a.status as [#hide_status],
	a.creator as [#hide_fzr],
	a.FromID as [#hide_FromID]
	FROM dbo.M_ManuPlans a
	left join (
		select min(dateBegin) as T1 ,
		max(dateEnd) as T2,
		max(dateDelivery) as T3,MPSID
		from 
		dbo.M_ManuPlanlists group by MPSID
	) b on a.ID=b.MPSID
	left join (
		select ab.MPSID,sum(case when numOrdered=0 then 1 else 0 end) as zeroCnt,count(*) as totalCnt,sum(case when numOrdered=numDecide then 1 else 0 end) as eqCnt from (
		select aaa.id,aaa.MPSID,aaa.NumDecide,sum(isnull(bbb.numPlan,0)) as numOrdered 
		from M_ManuPlanLists aaa 
		left join M_ManuOrderLists bbb on aaa.id = bbb.planlistId and bbb.lvw_treenodedeep = 0 and bbb.del=0 
		inner join M_ManuOrders ccc on ccc.id = bbb.MOrderId and ccc.status<>2 and ccc.complete<>3 and ccc.del=0
		group by aaa.id,aaa.MPSID,aaa.numDecide 
		) ab group by ab.MPSID
	) c on c.MPSID = a.id
	WHERE ( (del = 0 or del=7) and @typ =1 and TempSave = 0) or (@typ = 0 and del=1 )
)

GO

CREATE   function [dbo].[HrGetLoginTime](@today datetime,@uid int,@sortid int)
returns datetime
as
begin
declare @thisTime datetime
--���Ʋ���
declare @HR_login_M int,@HR_leave_M int ,@HR_overtime_M int,@HR_work_H int,@HR_login_Pat int,@HR_overtime_to_int int,@HR_hoDay_Ref int,@HR_comType int,@HR_Test int
select @HR_login_M=login_M*60,@HR_leave_M=leave_M*60,@HR_overtime_M=overtime_M*60,@HR_work_H=work_H,@HR_login_Pat=login_Pat,@HR_overtime_to_int=overtime_to_int,@HR_hoDay_Ref=hoDay_Ref*60,@HR_comType=companyType,@HR_Test=publicTest from hr_KQ_config where del=0 and datediff(d,startTime,@Today)>=0 and datediff(d,endTime,@Today)<=0
if @HR_comType=1--��˾��
begin

if @sortid=1--�ϰ�ʱ��
begin
select @thisTime=min(indate) from hr_log where creator=@uid and datediff(d,indate,@today)=0 and del=0 and result=1
end

else--�°�ʱ��
begin
select @thisTime=max(indate) from hr_log where creator=@uid and datediff(d,indate,@today)=0 and del=0 and result=2
end

end

else if @HR_comType=2--������
begin

if @sortid=1--�ϰ�ʱ��
begin

declare @loginTime datetime

set @loginTime=dbo.HrDayWorkTime(@today,@uid,1)
if isdate(@loginTime)=1
begin
select @thisTime=min(indate) from hr_log where creator=@uid  and abs(datediff(n,@loginTime,indate))<=@HR_hoDay_Ref and del=0 and result=1
end

else
begin
select @thisTime=min(indate) from hr_log where creator=@uid and datediff(d,indate,@today)=0  and del=0 and result=1
end

end

else--�°�ʱ��

begin

declare @outTime datetime
set @outTime=dbo.HrDayWorkTime(@today,@uid,2)
if isdate(@outTime)=1
begin
select @thisTime=max(indate) from hr_log where creator=@uid  and abs(datediff(n,@outTime,indate))<=@HR_hoDay_Ref and del=0 and result=2
end

else
begin
select @thisTime=max(indate) from hr_log where creator=@uid and datediff(d,indate,@today)=0  and del=0 and result=2
end

end


end

return @thisTime

end

GO

CREATE  function [dbo].[HrGetKQResult](@today datetime,@uid int) returns int
as
begin

-- declare @today datetime,@uid int
-- set @today='2011-07-01'
-- set @uid=84

		declare @thisStr int
		declare @TodayNeedWork int
		declare @TodayAPPHoliDay int,@workTimeLogin datetime,@workTimeOut datetime
		declare @loginTimes int
		declare @LateTimes int
		declare @LeveTimes int
		declare @kt int--�Ƿ�
		--�жϽ����Ƿ�Ҫ�ϰ�
		set @TodayNeedWork=dbo.HrTodayNeedWork(@today,@uid )
		--���Ʋ���
		declare @HR_login_M int,@HR_leave_M int ,@HR_overtime_M int,@HR_work_H int,@HR_login_Pat int,@HR_overtime_to_int int,@HR_hoDay_Ref int,@HR_comType int,@HR_Test int
		select @HR_login_M=login_M,@HR_leave_M=leave_M,@HR_overtime_M=overtime_M*60,@HR_work_H=work_H,@HR_login_Pat=login_Pat,@HR_overtime_to_int=overtime_to_int,@HR_hoDay_Ref=hoDay_Ref*60,@HR_comType=companyType,@HR_Test=publicTest from hr_KQ_config where del=0 and datediff(d,startTime,@Today)>=0 and datediff(d,endTime,@Today)<=0
		if @HR_hoDay_Ref is null --����Чʱ��Ĭ��ֵ
		begin
		set @HR_hoDay_Ref=2*60
		end

		if @HR_login_M is null --������С������Ĭ��ֵ0
		begin
		set @HR_login_M=0
		end

		if @HR_leave_M is null --������С������Ĭ��ֵ0
		begin
		set @HR_leave_M=0
		end

		--��ѯ�����Ƿ������뵥
		set @TodayAPPHoliDay=dbo.HrTodayAppDay(@today,@uid)
		set @workTimeLogin=dbo.HrDayWorkTime(@today,@uid,1)
		set @workTimeOut=dbo.HrDayWorkTime(@today,@uid,2)

		if @TodayNeedWork=1--�ϰ�
		begin

				if @TodayAPPHoliDay>0 --�����뵥
				begin
				--set @thisStr=dbo.HrKQClassID(@TodayAPPHoliDay)
				set @thisStr=@TodayAPPHoliDay
				end

				else
				begin
							if datediff(d,@workTimeLogin,'2000-1-1 00:00:00.000')=0
								begin
									return 0
								end

							set @loginTimes=(select count(*) from hr_Log where del=0 and abs(datediff(yyyy,inDate,@workTimeLogin))<10 and abs(datediff(n,inDate,@workTimeLogin))<=@HR_hoDay_Ref and  creator=@uid and datediff(d,inDate,@today)=0)

							if @loginTimes>0
							begin

										set @LateTimes=(select count(*) from hr_Log where del=0 and abs(datediff(yyyy,inDate,@workTimeLogin))<10 and datediff(n,@workTimeLogin,inDate)<=@HR_login_M and abs(datediff(n,inDate,@workTimeLogin))<=@HR_hoDay_Ref and  creator=@uid and datediff(d,inDate,@today)=0)


										if @LateTimes=0
										begin
										set @thisStr=6--�ٵ�
										end


										set @LeveTimes=(select count(*) from hr_Log where del=0 and abs(datediff(yyyy,inDate,@workTimeLogin))<10 and (datediff(n,@workTimeOut,inDate)>=@HR_leave_M*(-1)) and abs(datediff(n,inDate,@workTimeOut))<=@HR_hoDay_Ref and  creator=@uid   )

										if @LeveTimes=0
										begin

											 if isnumeric(@thisStr)=0 or @thisStr is null
											begin
											set @thisStr=7--����
											end

											else
											begin
											set @thisStr=16 --�ٵ� ����
											end

										end

									   if isnumeric(@thisStr)=0 or @thisStr is null
									  begin
										set @thisStr=15--����
										end
										--����ϰ�ʱ�������°�ʱ��
										if dbo.HrGetLoginTime(@today,@uid,1)>dbo.HrGetLoginTime(@today,@uid,2)
										begin
											set @thisStr=14--�쳣
										end

							end

							else
							begin
							return 8 --ȱ��
--select 8 --ȱ��
							end
				end

		end



		else if @TodayNeedWork=2--��Ϣ
		begin

					if @TodayAPPHoliDay>0--�����뵥
					begin
						set @thisStr=@TodayAPPHoliDay
						set @thisStr=@TodayAPPHoliDay
						declare @HrKQClassID int
						set @HrKQClassID=isnull(dbo.HrKQClassID(isnull(@thisStr,0)),0)
						if @HrKQClassID=1
						begin
						return 18--��Ϣ
						end
					end

					else
					begin
					return 18--��Ϣ
					end

		end

		else if @TodayNeedWork=3--�ż�
					begin
					if @TodayAPPHoliDay>0
					begin
					set @thisStr=@TodayAPPHoliDay
					end

					else
					begin
					return 19--�ż�
					end
		end

		else if @TodayNeedWork=4--�ڼٵ���
					begin

					if @TodayAPPHoliDay>0 --�����뵥
				begin
				set @thisStr=@TodayAPPHoliDay
				end

				else
				begin
							if datediff(d,@workTimeLogin,'2000-1-1 00:00:00.000')=0
								begin
									return 0
								end
							set @loginTimes=(select count(*) from hr_Log where del=0 and abs(datediff(yyyy,inDate,@workTimeLogin))<10 and abs(datediff(n,inDate,@workTimeLogin))<=@HR_hoDay_Ref and  creator=@uid and datediff(d,inDate,@today)=0)

							if @loginTimes>0
							begin

										set @LateTimes=(select count(*) from hr_Log where del=0 and abs(datediff(yyyy,inDate,@workTimeLogin))<10 and datediff(n,@workTimeLogin,inDate)<=@HR_login_M and abs(datediff(n,inDate,@workTimeLogin))<=@HR_hoDay_Ref and  creator=@uid and datediff(d,inDate,@today)=0)


										if @LateTimes=0
										begin
										set @thisStr=6--�ٵ�
										end

										set @LeveTimes=(select count(*) from hr_Log where del=0 and abs(datediff(yyyy,inDate,@workTimeLogin))<10 and (datediff(n,@workTimeOut,inDate)>=@HR_leave_M*(-1) ) and abs(datediff(n,inDate,@workTimeOut))<=@HR_hoDay_Ref and  creator=@uid    )
										if @LeveTimes=0
										begin

											 if isnumeric(@thisStr)=0 or @thisStr is null
											begin
											set @thisStr=7--����
											end

											else
											begin
											set @thisStr=16 --�ٵ� ����
											end

										end

									  if isnumeric(@thisStr)=0 or @thisStr is null
									  begin
										set @thisStr=20--�ڼ��յ���
										end
										--����ϰ�ʱ�������°�ʱ��
										if dbo.HrGetLoginTime(@today,@uid,1)>dbo.HrGetLoginTime(@today,@uid,2)
										begin
											set @thisStr=14--�쳣
										end

							end

							else
							begin
							return 8--ȱ��'
							end
				end

		end

		else --δ��ʼ�����쳣

		begin
		return 14--�쳣'
		end



return @thisStr
end

GO

create       function [dbo].[Hrlist_kqclass_fun]
(
	@uid int , @typ int,@ordID int
)	returns  table
AS
return
( --���ڷ����б�
	SELECT ID,
	dbo.erp_CreateLink(a.title,1,@ordID,a.id,a.Creator,@uid,80,12) AS ����,
	dbo.Hr_kqclassname_fun(a.sortID,1) as ��������,

	PrefixCode as ��־��,
dbo.erp_CreateLink(ISNULL((SELECT TOP 1 name FROM gate WHERE ord = a.creator), '�û�' + CAST(Creator AS varchar(10)) + '����ɾ��'),2,0,a.Creator,0,@uid,0,0) AS �����,
inDate AS �������,
	remark AS ��ע
	FROM dbo.hr_KQClass a
	WHERE sortID<>0 and ((@typ = 1 and del = 0 ) or (@typ = 0 and del = 1))
)

GO

CREATE  function [dbo].[erp_list_pgd_fun]( 
	@uid int , @typ int ,@date1 varchar(23)
)
returns table
as return (
	SELECT a.ID,
		a.WABH AS �ɹ�����,
		dbo.erp_CreateLink(a.title,1,8,a.id,a.Creator,@uid,54,14) AS �ɹ�����,
		b.order1 AS ��Ʒ���,
		dbo.erp_CreateLink(b.title,3,0,b.ord,0,@uid,21,14) AS ��Ʒ����,
		b.type1 AS �ͺ�,
		(SELECT TOP 1 sort1 FROM sortonehy b WHERE gate2 = 61 AND b.ord = a.unit) AS ��λ,
		a.NumMake AS ����,
		(
		case when isnull(s.allnum,0)=0 and isnull(c.qnum,0)=0  then
			case when datediff(d , @date1,a.DateWA)>=0 then 'δ��ʼ' else '����δ��ʼ' end
		else --���������Ĺ���㱨��
			case when (isnull(d.pnum,-1)=-1 or isnull(d.pnum,-1)>=a.NumMake ) and isnull(c.qnum,0)>=a.NumMake then  --����ɹ���㱨 --ȡ���Ĺ���㱨����
				case when (isnull(s.newInDate,'') = '' or (isnull(s.newInDate,'')<>'' and datediff(d , isnull(s.newInDate,''),a.DateEnd)>0 ) )
						and datediff(d , isnull(c.newInDate,''),a.DateEnd)>0
				then
					'��ǰ���'
				when (isnull(s.newInDate,'')<>'' and datediff(d , isnull(s.newInDate,''),a.DateEnd)<0 ) or datediff(d , isnull(c.newInDate,''),a.DateEnd)<0 then
					'�������'
				else 
					'�������' 
				end 
			else
				case when datediff(d , @date1,a.DateEnd)>=0 then '������' else '����δ���' end 
			end
		end	
		) as ״̬,
		(
		case when isnull(s.allnum,0)=0 and isnull(c.qnum,0)=0  then
			case when datediff(d , @date1,a.DateWA)>=0 then 1 else 2 end
		else --���������Ĺ���㱨��
			case when (isnull(d.pnum,-1)=-1 or isnull(d.pnum,-1)>=a.NumMake ) and isnull(c.qnum,0)>=a.NumMake then  --����ɹ���㱨 --ȡ���Ĺ���㱨����
				case when (isnull(s.newInDate,'') = '' or (isnull(s.newInDate,'')<>'' and datediff(d , isnull(s.newInDate,''),a.DateEnd)>0 ) )
						and datediff(d , isnull(c.newInDate,''),a.DateEnd)>0
				then
					5
				when (isnull(s.newInDate,'')<>'' and datediff(d , isnull(s.newInDate,''),a.DateEnd)<0 ) or datediff(d , isnull(c.newInDate,''),a.DateEnd)<0 then
					7
				else 
					6
				end 
			else
				case when datediff(d , @date1,a.DateEnd)>=0 then 3 else 4 end 
			end
		end	
		) as #hide_Status_WA,
		a.Cateid_WA #hide_Cateid_WA,
		dbo.erp_CreateLink(ISNULL((SELECT TOP 1 name FROM gate WHERE ord = a.Cateid_WA), '�û�' + CAST(a.Cateid_WA AS varchar(10)) + '����ɾ��'),2,0,a.Cateid_WA,0,@uid,0,0) AS �ɹ���Ա,
		a.DateWA AS �ɹ�ʱ��,
		dbo.erp_CreateLink(ISNULL((SELECT TOP 1 name FROM gate WHERE ord = a.creator), '�û�' + CAST(a.Creator AS varchar(10)) + '����ɾ��'),2,0,a.Creator,0,@uid,0,0) AS �����,
		a.inDate AS ���ʱ��
	FROM dbo.M_WorkAssigns a
	LEFT JOIN dbo.product b ON a.ProductID = b.ord
	left join (
		select M_WorkAssigns , SUM(num1) as allnum , max(indate) as newInDate 
		from M_ProcedureProgres where del=0 group by M_WorkAssigns 
	) s on s.M_WorkAssigns = a.id
	left join (
		--��Ҫ�ʼ�Ĺ�����-�ʼ�ͨ���������ٵ�����ֵ
		select M_WorkAssigns , min(pnum) as pnum
		from 
		(
			select n.id as M_WorkAssigns, w.id ,sum(r.num1) as pnum 
			from M_WorkAssigns n
			inner join M_WFP_Assigns w on w.WFid = n.WProID and w.result=1 --������������Ҫ�ʼ�Ĺ���
			left join M_ProcedureProgres r on r.[Procedure]=w.id and r.del=0 and r.result = 1 --�ʼ�ͨ��
			group by n.id , w.id
		) s group by M_WorkAssigns
	) d on d.M_WorkAssigns = a.id
	left join (
		select m.WAID , sum(NumQualified) as qnum ,max(m.MPDate) as newInDate
		from M_MaterialProgres m 
		inner join M_MaterialProgresDetail t on t.MPID = m.id and m.del=0 and t.del=0
		--where m.FromType = 1 --�������ȵ� (0 �������ȵ�)
		group by m.WAID
	) c on c.WAID = a.id
	
	left join (
		--��һ�����ͨ���������ٵ�����ֵ (�ж��Ƿ������ɻ㱨��)
		select M_WorkAssigns , min(pnum) as pnum
		from (
			select n.id as M_WorkAssigns, w.id ,sum(isnull(r.num1,0)) as pnum 
			from M_WorkAssigns n
			inner join M_WFP_Assigns w on w.WFid = n.WProID
			left join M_ProcedureProgres r on r.[Procedure]=w.id and r.del=0 and r.result in (0,1) --�ʼ�ͨ��
			group by n.id , w.id
		) s group by M_WorkAssigns
	) p on p.M_WorkAssigns = a.id
	left join power x on x.sort1=54 and x.sort2=1 and x.ord = @uid
	WHERE ((a.del = 0 and @typ =1 ) or (@typ = 0 and a.del=1) or (@typ = 2 and a.del = 0  and isnull(p.pnum,0)< a.NumMake))
          and (x.qx_open = 3 or (x.qx_open=1 and charindex(','+cast(a.Creator as varchar(15))+',',','+replace(cast(x.qx_intro as varchar(8000)),' ','')+',')>0))
)

GO

create  function [dbo].[erp_list_jqsb_fun]
(
	@uid int , @typ int
)	returns  table
AS
return
( --Ԥ�ⵥ�б�
	SELECT ID, sn AS �豸���,
	dbo.erp_CreateLink(a.name,1,21,a.id,a.Creator,@uid,59,14) AS �豸����,
	type as �豸�ͺ�,cls as �豸����,
	dbo.erp_CreateLink(ISNULL((SELECT TOP 1 name FROM gate WHERE ord = a.creator), '�û�' + CAST(Creator AS varchar(10)) + '����ɾ��'),2,0,a.Creator,0,@uid,0,0) AS �����,
	inDate AS �������,
	remark AS ��ע
	FROM dbo.M_Machineinfo a
	WHERE  (@typ = 1 and del = 0) or (@typ = 0 and del = 1)
)

GO

CREATE   function [dbo].[erp_list_gcrl_fun]
( @uid int , @typ int )
 returns table
as
return
(

	SELECT ID,
	dbo.erp_CreateLink(title,1,22,a.id,a.Creator,@uid,59,14) AS ��������,
	case wobjtype
	when 1 then '��֯�ܹ�'
	when 2 then 'ָ��Ա��'
	when 3 then '��������'
	else '�����豸'
	end as Ӧ������,

	case wobjtype
	when 1 then
		(select top 1 sort1 from (
			select sort1 from gate1 where -ord=a.wobj
			union all
			select y.sort1 + '��'+ x.sort2  from gate2 x , gate1 y  where  x.sort1 = y.ord and x.ord=a.wobj
			union all
			select 'ȫ��' where a.wobj= 0
		) xx)
	when 2 then
		(select top 1 name from gate where ord=a.wobj)
	when 3 then
		(select top 1 WCName from M_WorkingCenters c where c.ID=a.wobj)
	else
		(
		   select  top 1 y.WCName + '��' + z.name
			from M_WCMacList x,M_WorkingCenters y , M_MachineInfo z
			where x.WCID = y.ID and z.id=x.MCID and x.ID=a.wobj
		)
	end as Ӧ�ö���,

	date1 as ��ʼ����,date2 as ��ֹ����,
	dbo.erp_CreateLink(ISNULL((SELECT TOP 1 name FROM gate WHERE ord = a.creator), '�û�' + CAST(Creator AS varchar(10)) + '����ɾ��'),2,0,a.Creator,0,@uid,0,0) AS �����,
	remark AS ��ע
	FROM m_fcdate a

	WHERE (del = 0 and @typ =1 and tempsave = 0 ) or (@typ = 0 and del=1)
)

GO

CREATE function [dbo].[HrListNeedPerson]
(
	@uid int,@typ int
)	returns  table
AS
return
(
	--���ڷ����б�
	SELECT ID,
	dbo.erp_CreateLink(a.title,1,1019,a.id,a.Creator,@uid,85,12) AS ��������,
	bh as ������,
	inDate AS �������,
	dbo.erp_CreateLink(ISNULL((SELECT TOP 1 name FROM gate WHERE ord = a.creator), '�û�' + CAST(Creator AS varchar(10)) + '����ɾ��'),2,0,a.Creator,0,@uid,0,0) AS ������,
	(select sum(isnull(b.num,0)) as �������� from hr_NeedPerson_list b where b.NeedPerson=a.ID and b.del=0) as ��������,
	(select sum(isnull(b.HadNum,0)) from hr_NeedPerson_list b where b.NeedPerson=a.ID and b.del=0)  as ����Ƹ����,
	a.content AS ��ע,isnull(a.status,3) as [#hide_status],a.creator as [#hide_creator],
	a.cateid_sp as [#hide_cateid_sp],isnull(a.alt,0) as [#hide_alt]
	FROM dbo.hr_NeedPerson a
	WHERE a.TempSave = 0 and ((@typ = 1 and del = 0 ) or (@typ = 0 and del = 1 ))
)

GO

CREATE function [dbo].[HrListInterview]
(
	@uid int ,@typ int
)	returns  table
AS
return
(
	SELECT ID, dbo.erp_CreateLink(isnull(dbo.HrGetResumeName(a.resumeID),a.username +'<font color=red>(�޼���)</font>'),1,1034,a.id,a.Creator,@uid,85,12) as ����,case a.isInto when 0 then '��' else '��' end as �Ƿ�ת�ɵ���,  a.indate as  ���ʱ��,dbo.erp_CreateLink(ISNULL((SELECT TOP 1 name FROM gate WHERE ord =a.creator), '�û�' + CAST(Creator AS varchar(10)) + '����ɾ��'),2,0,Creator,0,@uid,0,0) as �����
	from hr_interview a
	where a.TempSave = 0 and ((@typ = 1 and del = 0 ) or (@typ = 0 and del = 1 ))
)

GO

CREATE function [dbo].[HrListExpaper]
(
	@uid int ,@typ int
)	returns  table
AS
return
(
	SELECT ID,a.bh as ���,  dbo.erp_CreateLink(a.title,1,1030,a.id,a.Creator,@uid,84,12) as ����,a.indate as  ���ʱ��,dbo.erp_CreateLink(ISNULL((SELECT TOP 1 name FROM gate WHERE ord =a.creator), '�û�' + CAST(Creator AS varchar(10)) + '����ɾ��'),2,0,Creator,0,@uid,0,0) as �����
	from hr_expaper a
	where a.TempSave = 0 and ((@typ = 1 and del = 0 ) or (@typ = 0 and del = 1 ))
)


GO

CREATE function [dbo].[erp_list_scjd_fun]
( @uid int , @typ int ,@FromType int)
 returns table 
 as return(
	SELECT a.ID,
	a.MPBH + (case  a.del when 7 then '<span style=color:red>(�Զ�����)</span>' else '' end) AS ���Ȼ㱨����,
	dbo.erp_CreateLink(a.title,1,(case when a.FromType=1 then 11 else 19 end),a.id,a.Creator,@uid,55,14) AS ����,
	dbo.erp_CreateLink(isnull(b.title,''),1,8,a.WAID,isnull(b.Creator,0),@uid,54,14) AS ��Ӧ�ɹ���,
	a.MPDate AS �㱨����,
	dbo.erp_CreateLink(ISNULL((SELECT TOP 1 name FROM gate WHERE ord = a.creator), '�û�' + CAST(a.Creator AS varchar(10)) + '����ɾ��'),2,0,a.Creator,0,@uid,0,0) AS �����,
	a.indate AS ���ʱ��,
	a.creator as [#hide_fzr]
	FROM dbo.M_MaterialProgres a
	left join M_WorkAssigns b on a.WAID=b.id
	WHERE ((a.del = 0 or a.del=7) and @typ =1 and a.TempSave = 0 and FromType=@FromType) or (@typ = 0 and a.del=1 and FromType=@FromType)
)

GO

create function [dbo].[erp_list_fgd_fun](@uid int,@typ int) returns @list
table(
[ID] [int],
[��������] [nVarChar](50),
[����������] [VarChar](1000),
[�����ʼ쵥] [VarChar](1000),
[�����] [VarChar](1000),
[���ʱ��] [dateTime]
)
as
begin
	insert into @list
	select
	a.id,
	a.PRBH ��������,
	dbo.erp_CreateLink(a.title,1,20,a.id,a.Creator,@uid,62,14) ����������,
	dbo.erp_CreateLink(isnull(c.title,'�����ݱ�ɾ����'),1,17,a.QTID,c.Creator,@uid,58,14) �����ʼ쵥,
	dbo.erp_CreateLink(isnull(b.name,'�û�' + CAST(a.Creator AS varchar(10)) + '����ɾ��'),2,0,a.Creator,0,@uid,0,0)  �����,
	a.indate ���ʱ��
	from M_ProgresReturns a
	left join gate b on a.Creator=b.ord
	left join M_QualityTestings c on c.id=a.QTID
	WHERE (a.del = 0 and @typ =1 ) or (@typ = 0 and a.del=1)
	return
end


GO

create  function [dbo].[erp_list_gylc_fun]
( @uid int , @typ int )
 returns   table   
 as return
 (
	select id,
	wfbh as �������̴���,
	dbo.erp_createlink(wfname,1,10,a.id,a.creator,@uid,59,14) as ������������, 
	description as ˵��,
	dbo.erp_createlink(isnull((select top 1 name from gate where ord = a.creator), '�û�' + cast(creator as varchar(10)) + '����ɾ��'),2,0,a.creator,0,@uid,0,0) as �����,
	(select count(wfid) from m_wfp where wfid = a.id) as ����������,
	intro as ��ע
	from dbo.m_workingflows a

	where (del = 0 and @typ =1 ) or (@typ = 0 and del=1)
)
 
GO


CREATE  function [dbo].[erp_list_gjsz_fun]
( @uid int , @typ int )
 returns  @list table ( [ID]  [int],
[��������]  [VarChar](1000),
[��Ч����]  [dateTime],
[��������]  [dateTime],
[�����]  [VarChar](1000),
[���ʱ��]  [dateTime],
[��ע]  [nVarChar](1000) )  as begin
 insert into @list

SELECT ID,
dbo.erp_CreateLink(title,1,16,a.id,a.Creator,@uid,60,14) AS ��������,
DateBegin AS ��Ч����,
DateEnd AS ��������,
dbo.erp_CreateLink(ISNULL((SELECT TOP 1 name FROM gate WHERE ord = a.creator), '�û�' + CAST(Creator AS varchar(10)) + '����ɾ��'),2,0,a.Creator,0,@uid,0,0) AS �����,
indate AS ���ʱ��,
intro AS ��ע
FROM dbo.M_PieceRateMain a
WHERE (del =   abs(@typ -1) )


return
 end

GO

CREATE        function [dbo].[HrListTestSP](@uid int,@typ int)
returns table
AS
return
(

select
a.ID,
b.title as �Ծ�,
dbo.erp_CreateLink(ISNULL((SELECT TOP 1 name FROM gate WHERE ord = a.creator), '�û�' + CAST(a.Creator AS varchar(10)) + '����ɾ��'),2,0,a.Creator,0,@uid,0,0) as ������Ա,
a.ObjPoint as �͹���÷�,
a.subjPoint as ������÷�,
a.totalPoint as �ܷ�,
case a.statusID when 1 then '������' when 2 then '������' else 'δ�ύ' end as ״̬,
a.indate as ʱ��
from hr_answer a left join hr_expaper b on a.expaperID=b.id where charindex(','+cast(@uid as varchar(20))+',',','+cast(b.sp_list as varchar(2000))+',')>0 and   ( (a.del = 0 and @typ =1 and a.statusID=1 ) or (@typ = 0 and a.del=1))

)

GO

CREATE  function [dbo].[HrPerformList](@uid int,@typ int)
returns table
AS
return
(
select id,
title as ����,
dbo.erp_CreateLink(ISNULL((SELECT TOP 1 name FROM gate WHERE ord = a.creator), '�û�' + CAST(Creator AS varchar(10)) + '����ɾ��'),2,0,a.Creator,0,@uid,0,0) AS �����,
indate as ���ʱ��
from hr_perform_result a where (a.del = 0 and @typ =1 ) or (@typ = 0 and a.del=1)
)

GO

CREATE       function [dbo].[HrListResume1](@uid int,@typ int)
returns table
AS
return
(

select
a.ID,
dbo.erp_CreateLink(a.keyword,1,1036,a.id,a.Creator,@uid,85,12) as ����,
a.indate as  ���ʱ��,dbo.erp_CreateLink(ISNULL((SELECT TOP 1 name FROM gate WHERE ord =a.creator), '�û�' + CAST(Creator AS varchar(10)) + '����ɾ��'),2,0,Creator,0,@uid,0,0) as �����
from hr_Resume a where ((a.del = 0 and @typ =1) or (@typ = 0 and a.del=1) ) and a.tempsave=0 

)

GO

CREATE  function [dbo].[HrListResumeItem]
(
	@uid int ,@typ int
)	returns  table
AS
return
(
	SELECT ID,dbo.hrGetResumeWebSite(a.sortID) as ��Ƹ��վ,dbo.hrGetResumeItem(a.itemID) as ��Ŀ,
 a.isReg as �Ƿ�ƥ������,dbo.erp_CreateLink(a.regStr,1,1035,a.id,a.Creator,@uid,85,12) as ������ʽ,
  replace(replace(a.startStr,'>','&#62'),'<','&#60') as ��ʼ���,
  replace(replace(a.endStr,'>','&#62'),'<','&#60') as �������, a.indate as  ���ʱ��,dbo.erp_CreateLink(ISNULL((SELECT TOP 1 name FROM gate WHERE ord =a.creator), '�û�' + CAST(Creator AS varchar(10)) + '����ɾ��'),2,0,Creator,0,@uid,0,0) as ����� from hr_resume_reg a where  ((@typ = 1 and del = 0 ) or (@typ = 0 and del = 1 ))

)

GO

CREATE             function [dbo].[HrListAddTest]
(
	@uid int ,@typ int
)	returns  table
AS
return
(

	SELECT a.ID,a.bh as ���,  a.title as ����,a.indate as  ���ʱ��,dbo.erp_CreateLink(ISNULL((SELECT TOP 1 name FROM gate WHERE ord =a.creator), '�û�' + CAST(a.Creator AS varchar(10)) + '����ɾ��'),2,0,a.Creator,0,@uid,0,0) as �����
from hr_expaper a
 where  a.status=3 and charindex(','+cast(@uid as varchar(50))+',',','+a.user_list+',')>0
 and ((@typ = 1 and a.del = 0 ) or (@typ = 0 and a.del = 1 ))
 and  dbo.hrisTestAnswer(@uid,a.ID)=0
)

GO

CREATE    function [dbo].[Hrlist_perform_fun](@uid int,@typ int)
returns  table
AS
return
(
select ID,
title as ����,
dbo.erp_CreateLink(ISNULL((SELECT TOP 1 name FROM gate WHERE ord = a.creator), '�û�' + CAST(Creator AS varchar(10)) + '����ɾ��'),2,0,a.Creator,0,@uid,0,0) AS �����,
indate as ���ʱ��
from hr_perform_result a where (a.del = 0 and @typ =1 ) or (@typ = 0 and a.del=1)
)

GO

CREATE   function [dbo].[HrAnswerList](@uid int,@typ int)
returns table
AS
return
(

select
a.id,
b.title as �Ծ�,
dbo.erp_CreateLink(ISNULL((SELECT TOP 1 name FROM gate WHERE ord = a.creator), '�û�' + CAST(a.Creator AS varchar(10)) + '����ɾ��'),2,0,a.Creator,0,@uid,0,0) as ������Ա,
a.ObjPoint as �͹���÷�,
a.subjPoint as ������÷�,
a.totalPoint as �ܷ�,
a.statusID as ״̬,
a.indate as ʱ��
from hr_answer a left join hr_expaper b on a.expaperID=b.id where (a.del = 0 and @typ =1 ) or (@typ = 0 and a.del=1)

)

GO

CREATE function [dbo].[erp_list_wlsq_fun]
( @uid int , @typ int )
 returns  table as
return(
	SELECT a.ID, a.MOBH AS ����,
	dbo.erp_CreateLink_billmx(a.title,a.OrderType+11,a.id,a.Creator,@uid,57) AS ����,
	dbo.erp_CreateLink_billmx(isnull(case a.potype
		when 0 then b.title else d.title end ,''),case a.potype
		when 0 then 8 else 25 end,isnull(case a.potype
		when 0 then b.id else d.id end,0),isnull(case a.potype
		when 0 then b.Creator else d.Creator end,0),@uid,54) AS ��Ӧ�ɹ���,
	ISNULL((SELECT TOP 1 name FROM gate WHERE ord = a.creator) , '�û�' + CAST(a.Creator AS varchar(10)) + '����ɾ��') AS �����,
	a.indate AS ���ʱ��,
	a.intro AS ��ע,
	a.OrderType,
	(
		case a.potype
		when 0 then '����'
		when 1 then 'ί��'
		else '����'
		end
	) as ����,
	dbo.erp_CreateLink_billmx(c.MOBH,2,isnull(c.id,0),c.creator,@uid,51)
	+ (case c.Complete when 1 then ' <img src="../../images/smico/ok.gif" title="�����Ѿ����">'
	when 2 then '<span style="color:red;font-weight:bold;font-family:Webdings;cursor:default" title="�����Ѿ�����ֹ">x<span>'
	else '' end)
	as �������
	FROM dbo.M_MaterialOrders a
	left join M_OutOrder d on a.WAID=d.id
	left join M_WorkAssigns b on a.WAID=b.id
	left join M_manuorders c on c.id = a.ddno
	WHERE (a.del = 0 and @typ =1 ) or (@typ = 0 and a.del=1) and a.tempsave = 0
)

GO

CREATE function [dbo].[erp_list_scjhhtlist_fun] (@uid int,@htId int)
returns table
as return
(
	SELECT  MPSBH AS ��������,
	dbo.erp_CreateLink(a.title,1,3,a.id,a.Creator,@uid,50,14) AS ����,
	ISNULL((SELECT TOP 1 name FROM gate WHERE ord = a.creator), '�û�' + CAST(a.Creator AS varchar(10)) + '����ɾ��')  AS �����,
	convert(varchar(16),indate,120) as ���ʱ��,
    --BUG.3308.KILLER.2013.12.31 ̩�������豸������ͬ���������ƻ� ������ ������ֹ
	case status when 3 then '����ͨ��' when 2 then '������ֹ' else '������' end as ����״̬
	FROM dbo.M_ManuPlans a WHERE  del=0 and createfrom =1 and fromID=@htId and tempSave = 0
)

GO

CREATE function [dbo].[erp_list_scjhxmlist_fun] (@uid int,@htId int)
returns table
as return
(
	SELECT  MPSBH AS ��������,
	dbo.erp_CreateLink(a.title,1,3,a.id,a.Creator,@uid,50,14) AS ����,
	ISNULL((SELECT TOP 1 name FROM gate WHERE ord = a.creator), '�û�' + CAST(a.Creator AS varchar(10)) + '����ɾ��')  AS �����,
	convert(varchar(16),indate,120) as ���ʱ��,
    --BUG.3308.KILLER.2013.12.31 ̩�������豸������ͬ���������ƻ� ������ ������ֹ
	case status when 3 then '����ͨ��' when 2 then '������ֹ' else '������' end as ����״̬
	FROM dbo.M_ManuPlans a WHERE  del=0 and createfrom =3 and fromID=@htId and tempSave = 0
)

GO

CREATE function [dbo].[erp_list_scddhtlist_fun] (@uid int,@htId int)
returns table
as return
(
	SELECT  b.MOBH AS �������,
	dbo.erp_CreateLink(b.title,1,2,b.id,b.Creator,@uid,51,14) AS ����,
	ISNULL((SELECT TOP 1 name FROM gate WHERE ord = b.creator), '�û�' + CAST(b.Creator AS varchar(10)) + '����ɾ��')  AS �����,
	convert(varchar(16),b.indate,120) as ���ʱ��,
    --BUG.3308.KILLER.2013.12.31 ̩�������豸������ͬ���������ƻ� ������ ������ֹ
	case b.status when 3 then '����ͨ��' when 2 then '������ֹ' else '������' end as ����״̬
	FROM dbo.M_ManuPlans a 
	inner join M_ManuOrders b on a.ID=b.MPSID
	WHERE  (a.del=0 or a.del=7) and a.createfrom =1 and a.fromID=@htId and a.tempSave = 0 and  b.del=0
)

GO

CREATE function [dbo].[erp_list_scddxmlist_fun] (@uid int,@htId int)
returns table
as return
(
	SELECT  b.MOBH AS ��������,
	dbo.erp_CreateLink(b.title,1,2,b.id,b.Creator,@uid,51,14) AS ����,
	ISNULL((SELECT TOP 1 name FROM gate WHERE ord = b.creator), '�û�' + CAST(b.Creator AS varchar(10)) + '����ɾ��')  AS �����,
	convert(varchar(16),b.indate,120) as ���ʱ��,
    --BUG.3308.KILLER.2013.12.31 ̩�������豸������ͬ���������ƻ� ������ ������ֹ
	case b.status when 3 then '����ͨ��' when 2 then '������ֹ' else '������' end as ����״̬
	FROM dbo.M_ManuPlans a 
	inner join M_ManuOrders b on a.ID=b.MPSID
	WHERE  (a.del=0 or a.del=7) and a.createfrom =3 and a.fromID=@htId and a.tempSave = 0 and  b.del=0
)

GO

CREATE function [dbo].[erp_list_wwjg_fun]
(
	@uid int, @typ int ,@oid int, @qxlb int
)	returns  table
AS
return
( --Ԥ�ⵥ�б�
	select a.ID,sn as ί�ⵥ��,
	dbo.erp_CreateLink_billmx(a.title,@oid,a.id,a.Creator,@uid,@qxlb) AS ί������,
	ISNULL((SELECT TOP 1 name FROM tel WHERE ord = a.gys), '��Ӧ��' + CAST(gys AS varchar(10))) AS ���ճ���,
	ISNULL((SELECT TOP 1 name FROM gate WHERE ord = a.fzr), '�û�' + CAST(a.fzr AS varchar(10))) AS �а���,
	b.MOBH  AS �������,
	ISNULL((SELECT TOP 1 name FROM gate WHERE ord = a.creator), '�û�' + CAST(a.Creator AS varchar(10))) AS �����,
	a.inDate AS �������,
	a.remark AS ��ע,
	a.status as [#hide_status],
	a.fzr as [#hide_fzr]
	FROM M_OutOrder a left join M_ManuOrders b on a.MOrder = b.ID
	WHERE  (@typ = 1 and a.del = 0 and a.TempSave = 0) or (@typ = 0 and a.del = 1)
)


GO

create function [dbo].[erp_list_xdd_fun]
( @uid int , @typ int )
returns table
as
return
(
	SELECT a.ID,
	(MOIBH +  (case  a.del when 7 then '<span style=color:red>(�Զ�����)</span>' else '' end)) AS �´ﵥ��,
	dbo.erp_CreateLink(a.title,1,4,a.id,a.Creator,@uid,53,14) AS ����,
	dbo.erp_CreateLink(isnull(b.MOBH,''),1,2,isnull(b.id,0),isnull(b.Creator,0),@uid,51,14) AS ��������,
	ISNULL((SELECT TOP 1 name FROM gate WHERE ord = a.Cateid_MOI), '�û�' + CAST(a.Cateid_MOI AS varchar(10)) + '����ɾ��') AS �´���Ա,
	ISNULL((SELECT TOP 1 name FROM gate WHERE ord = a.creator), '�û�' + CAST(a.Creator AS varchar(10)) + '����ɾ��') AS �����,
	a.indate AS ���ʱ��,
	a.intro AS ��ע
	FROM dbo.M_ManuOrderIssueds a
	left join M_ManuOrders b on a.MOID=b.ID
	WHERE ((a.del = 0 or a.del=7) and @typ =1 ) or (@typ = 0 and a.del=1)
)

GO

CREATE  function [dbo].[erp_list_wwzljc_fun]
( @uid int , @typ int )
 returns  table
as return (
--ί�����յ�
select a.ID,
dbo.erp_CreateLink(a.title,1,27,a.id,a.Creator,@uid,58,14) ����,
QTBH �ʼ쵥���,
QTDate �ʼ�ʱ��,
isnull(b.sort1,'���ѱ�ɾ����') �ʼ첿��,
dbo.erp_CreateLink(isnull(c.name,'���ѱ�ɾ����'),2,0,a.Inspector,0,@uid,0,0) �ʼ�Ա,
dbo.erp_CreateLink(isnull(d.name,'���ѱ�ɾ����'),2,0,a.Creator,0,@uid,0,0) �����,
indate ���ʱ��,
a.intro ��ע,
(select sort1 from sortonehy where ord=a.QTType) as �ʼ�����
 from M_QualityTestings a
left join gate1 b on a.QTDep=b.ord
left join gate c on c.ord=a.Inspector
left join gate d on d.ord=a.Creator
where a.qtype=1 and ((a.del = 0 and @typ =1 ) or (@typ = 0 and a.del=1))
)

GO

--�ʼ��б�
CREATE function [dbo].[erp_list_zljc_fun]( 
	@uid int ,
	@typ int 
)
returns  table
as 
return (
	select a.ID,
	dbo.erp_CreateLink(a.title,1,17,a.id,a.Creator,@uid,58,14) ����,
	QTBH �ʼ쵥���, QTDate �ʼ�ʱ��,
	isnull(b.sort1,'���ѱ�ɾ����') �ʼ첿��,
	dbo.erp_CreateLink(isnull(c.name,'���ѱ�ɾ����'),2,0,a.Inspector,0,@uid,0,0) �ʼ�Ա,
	dbo.erp_CreateLink(isnull(d.name,'���ѱ�ɾ����'),2,0,a.Creator,0,@uid,0,0) �����,
	indate ���ʱ��, a.intro ��ע,
	(select sort1 from sortonehy where ord=a.QTType) as �ʼ�����, a.creator as [#hide_fzr]
	 from M_QualityTestings a
	left join gate1 b on a.QTDep=b.ord
	left join gate c on c.ord=a.Inspector
	left join gate d on d.ord=a.Creator
	where a.qtype<> 1 and ((a.del = 0 and @typ =1 ) or (@typ = 0 and a.del=1)) and a.tempSave=0
)

GO

CREATE  function [dbo].[erp_list_ycd_fun]
(
	@uid int ,  @typ int
)	returns  table
AS
return
( --Ԥ�ⵥ�б�
	SELECT ID, PredictBH AS Ԥ�ⵥ��,
	dbo.erp_CreateLink(a.title,1,1,a.id,a.Creator,@uid,52,14) AS ����,
	dbo.IIf(MRP, '��', '��') AS ����MRP,
	dbo.erp_CreateLink(ISNULL((SELECT TOP 1 name FROM gate WHERE ord = a.creator), '�û�' + CAST(Creator AS varchar(10)) + '����ɾ��'),2,0,a.Creator,0,@uid,0,0) AS �����,
	inDate AS �������,
	intro AS ��ע
	FROM dbo.M_PredictOrders a
	WHERE  (@typ = 1 and del = 0 and TempSave = 0) or (@typ = 0 and del = 1)
)

GO

CREATE function [dbo].[erp_list_scdd_fun]
( @uid int , @typ int )
 returns table
as
return
(
	SELECT a.ID,a.MOBH AS ��������,
	dbo.erp_CreateLink(a.title,1,2,a.id,a.Creator,@uid,51,14) AS ����,
	dbo.erp_CreateLink(isnull(c.MPSBH,''),1,3,c.id,c.Creator,@uid,50,14) AS �����ƻ���,
	a.DateDelivery AS [#hide_��������] ,
	a.DateAdvance AS [#hide_��ǰ��(��)], DateBegin AS [#hide_��ʼ����],
	DateEnd AS [#hide_��ֹ����],
	dbo.erp_CreateLink(ISNULL((SELECT TOP 1 name FROM gate WHERE ord = a.creator),'�û�'+CAST(a.Creator AS varchar(10))+'����ɾ��'),2,0,a.Creator,0,@uid,0,0) AS �����,
	convert(varchar(16),a.indate,120) AS ���ʱ��,
	a.intro AS ��ע,
	--SingleCosts as [#Fixed_��λ�ɱ�] ,
	TotalCosts as [#Fixed_�ܳɱ�],
	(
	case dbo.erp_MaterialOrderComplete(a.id)
	when 10 then '�����'+(case when isnull(cost_open,0)=1 then '' else '���ɱ����㣩' end)
	when 0 then '���������'
	when 1 then '�����������'
	when 2 then '����������,�������'
	when 3 then '�����'+(case when isnull(cost_open,0)=1 then (case @typ when 0 then '' else ',<a href="javascript:void(0)" style="color:red" onclick="window.showdlg(''ProductCosts'',''��ȷ��'',360,240,''a'',''b'','''+cast(a.id as varchar(50))+''')"><img src="../../images/smico/r1.gif" style="border:0;width:12px;height:12px;margin-top:2px">����ɱ�</a>' end) else '' end)
	end
	) +
	(case when (a.complete = 2 and isnull(a.CostAccounting,1)=0 and isnull(cost_open,0)=1) then (case @typ when 0 then '' else ',<a href="javascript:void(0)" style="color:red" onclick="window.showdlg(''MOrderAbortCosts'',''��ȷ��'',360,240,''a'',''b'','''+cast(a.id as varchar(50))+''')"><img src="../../images/smico/r1.gif" style="border:0;width:12px;height:12px;margin-top:2px">����ɱ�</a>' end) 
	else '' end)
	 as [#Fixed_���״̬],
	(
		case
		when dbo.erp_MaterialOrderComplete(a.id)=3 then ''
		--����ɵ�
		when a.complete=1 then '�����'
		--δ��ɵ�
		when (a.complete=0 and isnull(abort_open,0)=1) then (case @typ when 0 then '' else '<a href="javascript:void(0)" style="color:red" onclick="window.showdlg(''MOrderAbort'',''ȷ��Ҫ��ǰ����������'',360,240,''a'',''b'','''+cast(a.id as varchar(50))+''')"><img src="../../images/icon_quit_t2.gif" style="border:0;width:12px;height:12px;margin-top:1px">��ǰ����</a>' end) 
		when a.complete=0 and isnull(abort_open,0)=0 then ''
		--����ֹδ�����
		when a.complete=2 and isnull(a.CostAccounting,1)=0 then (case when isnull(cost_open,0)=1 then '����ֹ' else '����ֹ,�ɱ�δ��' end)
		--����ֹ�Ѻ����
		when a.complete=2 and isnull(a.CostAccounting,1)=1 then '����ֹ,�ɱ�����'
		end
	)
		as  [#Fixed_��ֹ����],
	a.status as [#hide_status],
	a.creator as [#hide_fzr],
	c.FromID as [#hide_FromID],
	c.CreateFrom as [#hide_CreateFrom]
	FROM dbo.M_ManuOrders a
	left join M_ManuPlans c on a.MPSID=c.id
	left join (select cost_open=qx_open from power where ord=@uid and sort1=51 and sort2=18) d on 1=1
	left join (select abort_open=qx_open from power where ord=@uid and sort1=51 and sort2=17)  e on 1 =1
	WHERE (a.del = 0 and @typ =1 and a.TempSave = 0) or (@typ = 0 and a.del=1 )
)



GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[erp_list_wlsyd_fun](@uid int,@typ int) returns @list
table(
[ID] [int],
[ʹ�õ���] [nVarChar](50),
[����] [VarChar](1000),
[�����] [VarChar](1000),
[���ʱ��] [dateTime],
[��ע] [nVarChar](2000) ) as begin

insert into @list
SELECT a.ID,
MPRBH AS �´ﵥ��,
dbo.erp_CreateLink(a.title,1,18,a.id,a.Creator,@uid,61,14) AS ����,
dbo.erp_CreateLink(ISNULL((SELECT TOP 1 name FROM gate WHERE ord = a.creator), '�û�' + CAST(a.Creator AS varchar(10)) + '����ɾ��'),2,0,a.Creator,0,@uid,0,0) AS �����,
a.indate AS ���ʱ��,
cast(a.intro as varchar(2000)) AS ��ע
FROM dbo.M_MaterialProgresRaws a
WHERE (a.del = 0 and @typ =1 ) or (@typ = 0 and a.del=1)

return
 end

GO

CREATE      function [dbo].[HrListTestResult](@uid int,@typ int)
returns table
AS
return
(

select
a.ID,
dbo.erp_CreateLink(b.title,1,1030,b.id,b.Creator,@uid,84,12) as �Ծ�,
dbo.erp_CreateLink(ISNULL((SELECT TOP 1 name FROM gate WHERE ord = a.creator), '�û�' + CAST(a.Creator AS varchar(10)) + '����ɾ��'),2,0,a.Creator,0,@uid,0,0) as ������Ա,
a.ObjPoint as �͹���÷�,
a.subjPoint as ������÷�,
a.totalPoint as �ܷ�,
case a.statusID when 1 then '������' when 2 then '������' else 'δ�ύ' end as ״̬,
a.indate as ʱ��
from hr_answer a left join hr_expaper b on a.expaperID=b.id where (a.del = 0 and @typ =1 and a.statusID=2 ) or (@typ = 0 and a.del=1)

)

GO

CREATE function [dbo].[HrListTest](@uid int,@typ int)
returns table
AS
return
(
	select
	a.ID,
	dbo.erp_CreateLink(a.title,1,1029,a.id,a.Creator,@uid,84,12) as ����,
	case a.testtype when 1 then '��ѡ��' when 2 then '��ѡ��' when 3 then '�����' else 'δ����' end as ����,
	dbo.erp_CreateLink(ISNULL((SELECT TOP 1 name FROM gate WHERE ord = a.creator), '�û�' + CAST(a.Creator AS varchar(10)) + '����ɾ��'),2,0,a.Creator,0,@uid,0,0) as �����,
	a.indate as ʱ��
	from hr_test a
	where a.TempSave = 0 and ((a.del = 0 and @typ =1 ) or (@typ = 0 and a.del=1))
)




GO
SET QUOTED_IDENTIFIER ON
GO


CREATE     function [dbo].[erp_list_gzzx_fun]
( @uid int , @typ int )
 returns  @list table ( [ID]  [int],
[�������Ĵ���]  [nVarChar](50),
[������������]  [VarChar](4000),
[��������]  nvarchar(30),
[��ע]  [varchar](1000) )  as begin
 insert into @list

SELECT a.ID, WCBH AS �������Ĵ���,
dbo.erp_CreateLink(WCName,1,7,a.id,a.Creator,@uid,59,14) AS ������������,
isnull(b.sort1,'���ѱ�ɾ����') AS ��������, cast(intro as varchar(1000)) AS ��ע
FROM dbo.M_WorkingCenters a
left join gate1 b on a.Department=b.ord

WHERE (del = 0 and @typ =1 and TempSave = 0) or (@typ = 0 and del=1 )

return
 end

GO

CREATE          function [dbo].[HrListRegime](@uid int,@typ int)
returns table
AS
return
(
select
a.ID,
dbo.erp_CreateLink(a.title,1,1023,a.id,a.Creator,@uid,86,12) as ����,
bh as ���,
dbo.hrGetSortName(sortID) as ����,
dbo.hrGetSortName(lv) as �ȼ�,
dbo.hrGetProcessName(statusID,1023) as ִ��״̬,
note as ˵��,
indate as ���ʱ��
from hr_regime a  where   ((a.del = 0 and @typ =1) or (@typ = 0 and a.del=1)) and a.tempsave=0 

)

GO

CREATE       function [dbo].[HrListTrainPlan](@uid int,@typ int)
returns table
AS
return
(
select
a.ID,
dbo.erp_CreateLink(a.title,1,1027,a.id,a.Creator,@uid,84,12) as �ƻ�����,
bh as ���,
dbo.hrGetSortName(a.sortid) as ��ѵ����,
dbo.hrGetTrainForm(form) as ��ѵ��ʽ,
startTime as ��ʼʱ��,
endTime as ����ʱ��,
trainer as ��ѵ��ʦ,
dbo.hrGetProcessName(statusID,1027) as ִ��״̬,
cost as Ԥ�Ʒ���,
address as ��ѵ��ַ
from hr_train_plan a  where ((a.del = 0 and @typ =1) or (@typ = 0 and a.del=1) ) and a.tempsave=0

)

GO

CREATE         function [dbo].[HrListRetPlan](@uid int,@typ int)
returns table
AS
return
(

select
a.ID,
dbo.erp_CreateLink(a.title,1,1021,a.id,a.Creator,@uid,85,12) as �ƻ�����,
bh as �ƻ����,
b.title as ��Ƹ��ʽ,
(select sum(isnull(num,0)) from hr_plan_list where planID=a.id and del=0) as ��Ƹ����,
startdate as ��ʼʱ��,
enddate as ��ֹʱ��,
 dbo.hrGetProcessName(isnull(a.statusid,0),1021) as ִ��״̬
from hr_ret_plan a left join hr_ret_type b on a.retType=b.id where ((a.del = 0 and @typ =1) or (@typ = 0 and a.del=1)) and a.tempsave=0
)

GO

create      function [dbo].[HrListPersonContractTime](@uid int,@typ int,@now datetime)
returns table
AS
return
(
select
a.ID,
a.bh as ��ͬ���,
dbo.erp_CreateLink(a.title,1,1042,a.id,a.Creator,@uid,82,12) as ��ͬ����,
dbo.hrGetSortName(a.sortID) as ��ͬ����,
dbo.SNGetGateName(a.partB) as �ҷ�,
a.startDate as ��ʼ����,
a.endDate as ��������,
datediff(d,@now,a.endDate) as �����ͬ����
from hr_person_contract a inner join hr_person b
on a.partB=b.userid
where
datediff(d,@now,a.endDate)<=(select isnull(tq1,0) from setjm where cateid=@uid and ord=17) and a.status=3  and b.del=0  and  ((a.del = 0 and @typ =1) or (@typ = 0 and a.del=1)) and a.tempsave=0

)

GO

CREATE        function [dbo].[HrListPersonContract](@uid int,@typ int)
returns table
AS
return
(
select
a.ID,
a.bh as ��ͬ���,
dbo.erp_CreateLink(a.title,1,1042,a.id,a.Creator,@uid,82,12) as ��ͬ����,
dbo.hrGetSortName(a.sortID) as ��ͬ����,
dbo.SNGetGateName(a.partB) as �ҷ�,
a.startDate as ��ʼ����,
a.endDate as ��������,
indate as ���ʱ��
from hr_person_contract a  where ((a.del = 0 and @typ =1) or (@typ = 0 and a.del=1)) and a.tempsave=0 

)

GO

CREATE function [dbo].[HrListleave](@uid int,@typ int)
returns table
AS
return
(
	select
		a.ID,
		dbo.erp_CreateLink(a.gateName,1,1039,a.id,a.cateid,@uid,89,12) as ��Ա,
		a.bh as ������,
		dbo.erp_CreateLink(a.title,1,1039,a.id,a.cateid,@uid,89,12) as ��������,
		dbo.hrGetSortName(a.sortID) as ��ְ����,
		case when a.sorceName='*' OR LEN(a.sorceName)=0 THEN  ISNULL(B.NAME,'') ELSE a.sorceName END as ����,
		' ' as С��,
		a.postion as ְλ,
		a.indate as ��������
	from hr_leave a
	inner join gate g on g.ord = a.cateid
	left join orgs_parts b on b.ID = g.orgsid
	where TempSave = 0 and ((a.del = 0 and @typ =1 ) or (@typ = 0 and a.del=1))
)

GO

CREATE function [dbo].[erp_list_gx_fun]
( @uid int , @typ int )
 returns table as return (
	select ID,
		dbo.erp_CreateLink(WPName,1,9,a.id,a.Creator,@uid,59,14) as ��������,
		WClass as �������,
		--WPOrder as ����,
		--TimeQueue as [�Ŷ�ʱ��(h)],
		TimePrepare as [׼��ʱ��(h)],
		cast(cast(TimeStandard as decimal(20, 4)) as varchar(12))
		+ (case TimeUnit when 1 then '��' when 2 then 'ʱ' when 3 then '��' else '��' end)
		as [�ӹ�ʱ��],
	    ManHour as [����ʱ��(h)],
	   	Description as �������� ,
		--MakeNum as ��������,
		(select top 1 WPName from M_WorkingProcedures x  where x.ID=a.ReplaceID) as �������
	    --dbo.IIf(ReplaceFlag, '��', '��') as �ܷ����, ReplaceID as �����������
	from dbo.M_WorkingProcedures a
	where  (@typ = 1 and  del = 0) or (@typ= 0 and del =1)
)

GO

CREATE        function [dbo].[HrListResume](@uid int,@typ int)
returns table
AS
return
(

select
a.ID,
dbo.erp_CreateLink(a.keyword,1,1024,a.id,a.Creator,@uid,85,12) as ����,
dbo.erp_CreateLink(a.userName,1,1024,a.id,a.Creator,@uid,85,12) as ����,
bh as ���,
sex as �Ա�,
birthday as ��������,
workyear    as ��������,
case cardType when 1 then '���֤' when 2 then '����' when 3 then '����֤' when 4 then '������֤' else  '����' end as  ֤������,
cardID as ֤����,
email,
 AnnualSalary    as Ŀǰ��н,
mobile as �ֻ�����,
hometel as ��ͥ�绰,
officetel as ��˾�绰,
 jobstatus   as ��ְ״̬,
Account as ����,
height as ���,
 Maryy  as ����״��,
QQ,
address as ��ס��ַ,
 isfulltime  as ��������,
Workarea as ����,
 Industries as ��ҵ,
funts as ְ��,
 needSalary  as ����нˮ,
Dutytime as ����ʱ��
from hr_Resume a where ((a.del = 0 and @typ =1) or (@typ = 0 and a.del=1)) and a.tempsave=0 

)

GO

CREATE function [dbo].[HrListCompany]
(
	@uid int ,@typ int
)	returns  table
AS
return
(

	SELECT a.ID,
	dbo.erp_CreateLink( a.title,1,1043,a.id,a.Creator,@uid,82,12) as ��˾����,
	a.tel as  ��˾�ܻ�,a.fax as ��˾����,
	a.startdate as ����ʱ��,a.corporate as ��˾����,cast(dbo.formatNumber(a.capital,(SELECT num1 FROM dbo.setjm3 WHERE ord = 1),0) as varchar(100))+'��Ԫ' as ע���ʱ�,a.zipcode as �ʱ�,
	a.address as ��˾��ַ,dbo.SNGetGateName(a.creator) as �����,a.indate as ���ʱ��
	from hr_company a
	where a.TempSave = 0 and ((@typ = 1 and a.del = 0 ) or (@typ = 0 and a.del = 1 ))
)

GO

CREATE      function [dbo].[HrListPostion](@uid int,@typ int)
returns table
AS
return
(
select
a.ID,
dbo.erp_CreateLink(a.title,1,1020,a.id,a.Creator,@uid,85,12) as ְλ,
dbo.SnGetSorceNameFun(sorce,1) as ����,
dbo.SnGetSorceNameFun(sorce2,2) as С��,
indate as ���ʱ��
from hr_pub_postion a  where ((a.del = 0 and @typ =1) or (@typ = 0 and a.del=1)) and a.tempsave=0 

)

GO

CREATE     function [dbo].[HrListPartner](@uid int,@typ int)
returns table
AS
return
(
select
a.ID,
dbo.erp_CreateLink(a.title,1,1022,a.id,a.Creator,@uid,85,12) as ��˾����,
person as ������,
tel as �绰,
mobile as �ֻ�,
fax as ����,
email as �ʼ�,
QQ,
MSN,
address as ��ַ,
website as ��˾��ַ,
weburl as ��¼��ַ,
uid as �û���,
pwd as ����
from hr_pub_partner a  where ((a.del = 0 and @typ =1) or (@typ = 0 and a.del=1)) and a.tempsave=0 

)

GO

CREATE      function [dbo].[HrListOffStaff](@uid int,@typ int)
returns table
AS
return
(

select
a.ID,
dbo.erp_CreateLink(a.gateName,1,1040,a.id,a.cateid,@uid,90,12) as ��Ա,
a.sorceName as ����,
a.sorce2Name as С��,
a.postion as ְλ,
a.startTime as ��ʼʱ��,
a.endTime as ����ʱ��,
a.indate as ��������
from hr_off_staff a  where (a.del = 0 and @typ =1 ) or (@typ = 0 and a.del=1)

)

GO

----��ѯĳϣʱ����ĳ���ˣ�ĳ���������͵�����
--@startDate����ʼʱ�䣬@endDate������ʱ��,@uid���û�id,resultid����������
CREATE    function [dbo].[HrGetResultCount](@startDate datetime,@endDate datetime,@uid int,@resultid int) returns money
as
begin

declare @Num money
set @Num=0.0

if datediff(d,@endDate,@startDate)>0
begin
return 0.0
end

if isdate(@startDate)=1 and isdate(@endDate)=1 and isnumeric(@uid)=1 and isnumeric(@resultid)=1
begin

	if @resultid<=20
	begin

			declare @iBetween as int,@i as int,@today datetime,@dayResult int
			set @iBetween=datediff(d,@startDate,@endDate)
			set @i=0

			while @i<=@iBetween


			begin
				set @today=dateadd(d,@i,@startDate)
				set @dayResult=dbo.HrGetKQResult(@today,@uid)

				if @dayResult=@resultid or (@dayResult=16 and (@resultid=6 or @resultid=7))
				begin
				set @Num=@Num+1
				end

				set @i=@i+1
			end
	end

	else
	begin
	declare @UnitType int
	select @UnitType=UnitType from hr_KQClass  where del=0 and id=@resultid
	set @Num=dbo.HrPriceAppDay(@startDate,@endDate,@uid,@resultid,@UnitType)
	end

end

else
begin
return 0.0
end

return isnull(@Num,0)
end

GO

--��ѯʵ�ʳ�������
CREATE   function [dbo].[HrgetRealWorkDay](@startDate datetime,@endDate datetime,@uid int) returns float
as
begin

declare @Num money, @sortid int,@enterDate datetime,@contractEnd datetime
set @Num=cast(0 as decimal(25, 12) )

if datediff(d,@endDate,@startDate)>0
begin
return cast(0 as decimal(25, 12) )
end

if isdate(@startDate)=1 and isdate(@endDate)=1 and isnumeric(@uid)=1
begin

select @enterDate=Entrydate,@contractEnd=contractEnd from hr_person where del=0 and userID=@uid

if isnull(datediff(d,@enterDate,@contractEnd),0)>0
begin

if isnull(datediff(d,@startDate,@enterDate),0)>0
begin
set @startDate=@enterDate
end

if isnull(datediff(d,@contractEnd,@endDate),0)>0
begin
set @endDate=@contractEnd
end

end

else
begin
return cast(0 as decimal(25, 12) )
end

		declare @iBetween as int,@i as int,@today datetime,@dayResult int
		set @iBetween=datediff(d,@startDate,@endDate)
		set @i=0

		while @i<=@iBetween


		begin
			set @today=dateadd(d,@i,@startDate)
			set @dayResult=dbo.HrGetKQResult(@today,@uid)

			if @dayResult=6 or @dayResult=7 or @dayResult=15  or @dayResult=16 or @dayResult=20 --�ٵ������ˡ��ٵ������ˡ�����
			begin
			set @Num=@Num+1
			end

			else if @dayResult>20
			begin

			set @sortid=dbo.HrKQClassID(@dayResult)
			if @sortid=2
			begin
			set @Num=@Num+1
			end

			end


			set @i=@i+1
		end
end

else
begin
return cast(0 as decimal(25, 12) )
end

return cast(@Num as decimal(25, 12) )


end

GO

CREATE function [dbo].[HrGetRealHour](@startTime datetime,@endTime datetime,@uid int)
returns int
as
begin


	if isdate(@startTime)=0 or isdate(@endTime)=0 or isnumeric(@uid)=0
	begin
	return 0
	end

	declare @iBetween  int,@i int,@hours int,@todayHour int,@loginTime datetime,@outTime datetime,@today datetime
	declare @HR_login_M int,@HR_leave_M int ,@HR_overtime_M int,@HR_work_H int,@HR_login_Pat int,@HR_overtime_to_int int,@HR_hoDay_Ref int,@HR_comType int,@HR_Test int,@workHour int
	set @hours=0
	set @iBetween=datediff(d,@startTime,@endTime)


	if @iBetween>=0
	begin

		set @i=0
		while @i<=@iBetween
		begin
			set @today=dateadd(d,@i,@startTime)

			if @i=0
			begin

				set @todayHour=isnull(datediff(hh,@startTime,case when dbo.HrDayWorkTime(@startTime,@uid,2)>@endTime then  @endTime else dbo.HrDayWorkTime(@startTime,@uid,2) end),0)
				if @todayHour<0--�쳣������ٿ�ʼʱ���ڵ�һ����
				begin
				set @todayHour=0
				end
				else
				begin

				select @HR_login_M=login_M*60,@HR_leave_M=leave_M*60,@HR_overtime_M=overtime_M*60,@HR_work_H=work_H,@HR_login_Pat=login_Pat,@HR_overtime_to_int=overtime_to_int,@HR_hoDay_Ref=hoDay_Ref*60,@HR_comType=companyType,@HR_Test=publicTest,@workHour=isnull(workHour,0) from hr_KQ_config where del=0 and datediff(d,startTime,@startTime)>=0 and datediff(d,endTime,@startTime)<=0

				if @todayHour>@workHour
				begin
				set @todayHour=@workHour
				end

				end

				set @hours=@hours+@todayHour
			end

			else if @i=@iBetween
			begin
				set @todayHour=isnull(datediff(hh,(case when datediff(d,@endTime,dbo.HrDayWorkTime(@endTime,@uid,1))<0 then dateadd(hh,1,@endTime) else dbo.HrDayWorkTime(@endTime,@uid,1) end),@endTime),0)
				if @todayHour<0--�쳣������ٽ���ʱ�������һ���ǰ
				begin
				set @todayHour=0
				end

				else
				begin

					select @HR_login_M=login_M*60,@HR_leave_M=leave_M*60,@HR_overtime_M=overtime_M*60,@HR_work_H=work_H,@HR_login_Pat=login_Pat,@HR_overtime_to_int=overtime_to_int,@HR_hoDay_Ref=hoDay_Ref*60,@HR_comType=companyType,@HR_Test=publicTest,@workHour=isnull(workHour,0) from hr_KQ_config where del=0 and datediff(d,startTime,@endTime)>=0 and datediff(d,endTime,@endTime)<=0

					if @todayHour>@workHour
					begin
					set @todayHour=@workHour
					end

				end

				set @hours=@hours+@todayHour

			end


			else
			begin

				set @todayHour=isnull(datediff(hh,dbo.HrDayWorkTime(@today,@uid,1),dbo.HrDayWorkTime(@today,@uid,2)),0)
				if @todayHour<0--�쳣���Ű������д��ϰ�ʱ������°�ʱ��
				begin
				set @todayHour=0
				end

				else
				begin

					select @HR_login_M=login_M*60,@HR_leave_M=leave_M*60,@HR_overtime_M=overtime_M*60,@HR_work_H=work_H,@HR_login_Pat=login_Pat,@HR_overtime_to_int=overtime_to_int,@HR_hoDay_Ref=hoDay_Ref*60,@HR_comType=companyType,@HR_Test=publicTest,@workHour=isnull(workHour,0) from hr_KQ_config where del=0 and datediff(d,startTime,@today)>=0 and datediff(d,endTime,@today)<=0

					if @todayHour>@workHour
					begin
					set @todayHour=@workHour
					end

				end

				set @hours=@hours+@todayHour
			end

			set @i=@i+1

		end

	end

	else
	begin

		return datediff(hh,@startTime,@endTime)
	end


return isnull(@hours,0)

end

GO

CREATE FUNCTION [dbo].[erp_scflsplist](@uid int,@dype int)
RETURNS TABLE
AS
RETURN
(
	SELECT ID,���� as ���ϵ���,����,���� + '����' as ��������,��Ӧ�ɹ��� as �ϼ�������,�����,���ʱ��,��ע FROM (select * from dbo.erp_list_wlsq_fun(@uid,@dype)) aaa where orderType = 4

)

GO

CREATE FUNCTION [dbo].[erp_scblsplist](@uid int,@dype int)
RETURNS TABLE
AS
RETURN
(
	SELECT ID,���� as ���ϵ���,����,���� + '����' as ��������,�������,��Ӧ�ɹ��� as �ϼ�������,�����,���ʱ��,��ע
	FROM (select * from dbo.erp_list_wlsq_fun(@uid,@dype)) aaa where orderType = 2
)

GO

CREATE FUNCTION [dbo].[erp_scllsplist](@uid int,@dype int)
RETURNS TABLE
AS
RETURN
(
	SELECT ID,���� as ���ϵ���,����,���� + '����' as ��������,�������,��Ӧ�ɹ��� as �ϼ�������,�����,���ʱ��,��ע FROM (select * from dbo.erp_list_wlsq_fun(@uid,@dype)) aaa where orderType = 1

)

GO

CREATE FUNCTION [dbo].[erp_sctlsplist](@uid int,@dype int)
RETURNS TABLE
AS
RETURN
(
	SELECT ID,���� as ���ϵ���,����,���� + '����' as ��������,��Ӧ�ɹ��� as �ϼ�������,�����,���ʱ��,��ע FROM (select * from dbo.erp_list_wlsq_fun(@uid,@dype)) aaa where orderType = 3

)

GO

--�������͵�λ����
CREATE function [dbo].[HrUnitTypeName](@id int) returns varchar(100)
as
begin
	declare @UnitTypeName varchar(100)
		if isnumeric(@id)=1
		begin
		 set @UnitTypeName=  case @id when 1 then  '����' when 2 then 'Сʱ' when 3 then '����' else '��' end
		end
		else
		begin
		set @UnitTypeName=''
		end
	return @UnitTypeName
end

GO

--���¿������͵�λ����
CREATE function [dbo].[HrUnitName](@id int) returns varchar(100)
as
begin
	declare @UnitName varchar(100)
	if isnumeric(@id)=1
	begin
		set @UnitName=  case @id when 1 then  '����' when 2 then 'Сʱ' when 3 then '����' else '����' end
	end
	else
	begin
		set @UnitName=''
	end
	return @UnitName
end

GO

--��ѯ��������
CREATE          function [dbo].[HrGetTallMoney](@StratDate datetime,@EndDate datetime,@uid int) returns money
as
begin
declare @thisMoney  varchar(2000)
declare @NumMoney money

-- set @thisMoney='{��������}+{ʵ�ʳ�������}+{ʵ�ʳ�������}+{Ӧ��������}+{�ٵ�����}+{���˴���}+{���ϱ���}+{ҽ�Ʊ���}+{ʧҵ����}+{ס��������}'
--���Ʋ���
-- declare @HR_login_M int,@HR_leave_M int ,@HR_overtime_M int,@HR_work_H int,@HR_login_Pat int,@HR_overtime_to_int int,@HR_hoDay_Ref int,@HR_comType int,@HR_Test int
-- select @HR_login_M=login_M*60,@HR_leave_M=leave_M*60,@HR_overtime_M=overtime_M*60,@HR_work_H=work_H,@HR_login_Pat=login_Pat,@HR_overtime_to_int=overtime_to_int,@HR_hoDay_Ref=hoDay_Ref*60,@HR_comType=companyType,@HR_Test=publicTest from hr_KQ_config

declare @pubBasicWage money--��������
declare @pubReguldate datetime--ת������
declare @pubProbSalary money--�����ڹ���
declare @pubEntrydate datetime--��ְ����
declare @nowStatus int----Ա��״̬��1Ϊ������2Ϊ��ʱ����3Ϊ��ְ
declare @pubWordDays money--ʵ�ʳ�������
declare @pubNeedWorkDays money --Ӧ��������
declare @pubLateTimes money --�ٵ�����
declare @pubLeaveTimes  money--���˴���

declare @pubPersion money --���ϱ���
declare @pubHealth money --ҽ�Ʊ���
declare @pubUnplo money --ʧҵ����
declare @pubInjury money --���˱���
declare @pubMater money --��������
declare @pubHouse money --ס��������
declare @pubTax money --��������˰
declare @pubAbsTimes money --ȱ�ڴ���
declare @pubPerform money--��Ч����
declare @pubJJGZ money--�Ƽ�����

select @pubBasicWage=BasicSalary,@pubReguldate=Reguldate,@pubProbSalary=ProbSalary,@pubEntrydate=Entrydate,@nowStatus=nowStatus from hr_person where del=0 and userID=@uid  and datediff(d,Entrydate,@EndDate)>=0
set @pubWordDays=cast(dbo.HrGetRealWorkDay(@StratDate,@EndDate,@uid) as decimal(25, 12))--ʵ�ʳ�������
set @pubNeedWorkDays=cast(dbo.HrGetMonthWorkDay(@StratDate,@EndDate,@uid) as decimal(25, 12))--Ӧ��������
declare @str varchar(500)
select @str=gongzi from hr_gongziclass where isall=1 or (isall=0 and charindex(','+cast(@uid as varchar)+',',','+cast(user_list as varchar)+',')>0)


set @thisMoney=''
	declare @id int,@curStr varchar(2000)
			declare cur_3 cursor for select  id, (cast(intro as varchar)+'*('+salaryClass+')') as flag from sortwages where salaryClass<>''and charindex('{��������˰}',salaryClass)=0 and salaryClass is not null and id in (select short_str from dbo.split(@str,',')) order by gate1 desc
			open cur_3
			fetch next from cur_3 into @id,@curStr
			while @@fetch_status=0
				begin




set @thisMoney=@thisMoney+'('+@curStr+')+'
				fetch next from cur_3 into @id,@curStr
				end
			close cur_3                   --�ر��α�
			deallocate cur_3


if right(@thisMoney,1)='+'
begin
set @thisMoney=left(@thisMoney,(len(@thisMoney)-1))
end

if @pubBasicWage is null or @pubProbSalary is null or @pubEntrydate is null or @pubWordDays<=0
begin
return cast(0 as decimal(25, 12))
end

if charindex('{��������}',@thisMoney)>0
		begin

-- 				/*���������㷨*/
--
-- 				--��Ա������ʽԱ��
-- 				if datediff(d,@pubReguldate,@StratDate)>=0 and @nowStatus=1
-- 				begin
-- 				set @pubBasicWage=@pubBasicWage
-- 				end
--
-- 				--ȫ��Ϊ������
-- 				else if datediff(d,@pubReguldate,@StratDate)<0 and datediff(d,@pubReguldate,@EndDate)<0 and @nowStatus=2 --Ա��״̬��1Ϊ������2Ϊ��ʱ����3Ϊ��ְ
-- 				begin
-- 				set @pubBasicWage=@pubProbSalary
-- 				end
--
-- 				--һ����Ϊ�����ڣ�һ������ת��
-- 				else if  datediff(d,@pubReguldate,@StratDate)<0 and datediff(d,@pubReguldate,@EndDate)>=0  and @nowStatus=2
-- 				begin
--
-- 					if @pubNeedWorkDays>0
-- 					begin
-- 					--�����ڹ���*��������������+ת������*������Ӧ���������������ڹ����죩
-- 					declare @ProWorkDayMoth int
-- 					set @ProWorkDayMoth=dbo.HrGetMonthWorkDay(@StratDate,@pubReguldate,@uid)--���������ڹ�������
-- 					set @pubNeedWorkDays=dbo.HrGetMonthWorkDay(@StratDate,@EndDate,@uid)--Ӧ��������
-- 					set @pubBasicWage=(@pubProbSalary*(@ProWorkDayMoth/@pubNeedWorkDays))+@pubBasicWage*(1-(@ProWorkDayMoth/@pubNeedWorkDays))
-- 					end
--
-- 					else
-- 					begin
-- 					set @pubBasicWage=0
-- 					end
-- 			  end
--
-- 				else
-- 				begin
-- 				set @pubBasicWage=0
-- 				end
			set @pubBasicWage=dbo.HrGetBaseSalary(@StratDate,@EndDate,@uid)

		set @thisMoney=replace(@thisMoney,'{��������}',cast(@pubBasicWage as varchar))

		end


		if charindex('{ʵ�ʳ�������}',@thisMoney)>0
		begin

		set @thisMoney=replace(@thisMoney,'{ʵ�ʳ�������}',cast(@pubWordDays as varchar))

		end



		if charindex('{Ӧ��������}',@thisMoney)>0
		begin
		set @thisMoney=replace(@thisMoney,'{Ӧ��������}',cast(@pubNeedWorkDays as varchar))

		end


		if charindex('{�ٵ�����}',@thisMoney)>0
		begin
		set @pubLateTimes=cast(dbo.HrGetResultCount(@StratDate,@EndDate,@uid,6) as decimal(25, 12))--�ٵ�����
		set @thisMoney=replace(@thisMoney,'{�ٵ�����}',cast(@pubLateTimes as varchar))

		end


		if charindex('{���˴���}',@thisMoney)>0
		begin
		set @pubLeaveTimes=cast(dbo.HrGetResultCount(@StratDate,@EndDate,@uid,7) as decimal(25, 12))--���˴���
		set @thisMoney=replace(@thisMoney,'{���˴���}',cast(@pubLeaveTimes as varchar))

		end

		if charindex('{ȱ�ڴ���}',@thisMoney)>0
		begin
		set @pubAbsTimes=cast(dbo.HrGetResultCount(@StratDate,@EndDate,@uid,8)as decimal(25, 12))--ȱ�ڴ���
		set @thisMoney=replace(@thisMoney,'{ȱ�ڴ���}',cast(@pubAbsTimes as varchar))

		end

		if charindex('{���ϱ���}',@thisMoney)>0
		begin
		set @pubPersion=dbo.HrMakeWelfare(@StratDate,@EndDate,@uid,1)  --���ϱ���
		set @thisMoney=replace(@thisMoney,'{���ϱ���}',cast(@pubPersion as varchar))

		end



		if charindex('{ҽ�Ʊ���}',@thisMoney)>0
		begin
		set @pubHealth=dbo.HrMakeWelfare(@StratDate,@EndDate,@uid,2) --ҽ�Ʊ���
		set @thisMoney=replace(@thisMoney,'{ҽ�Ʊ���}',cast(@pubHealth as varchar))

		end


		if charindex('{ʧҵ����}',@thisMoney)>0
		begin
		set @pubUnplo=dbo.HrMakeWelfare(@StratDate,@EndDate,@uid,3) --ʧҵ����
		set @thisMoney=replace(@thisMoney,'{ʧҵ����}',cast(@pubUnplo as varchar))

		end



		if charindex('{���˱���}',@thisMoney)>0
		begin
		set @pubInjury=dbo.HrMakeWelfare(@StratDate,@EndDate,@uid,4) --���˱���
		set @thisMoney=replace(@thisMoney,'{���˱���}',cast(@pubInjury as varchar))

		end


		if charindex('{��������}',@thisMoney)>0
		begin
		set @pubMater=dbo.HrMakeWelfare(@StratDate,@EndDate,@uid,5) --��������
		set @thisMoney=replace(@thisMoney,'{��������}',cast(@pubMater as varchar))

		end


		if charindex('{ס��������}',@thisMoney)>0
		begin
		set @pubHouse=dbo.HrMakeWelfare(@StratDate,@EndDate,@uid,6) --ס��������
		set @thisMoney=replace(@thisMoney,'{ס��������}',cast(@pubHouse as varchar))
		end

		if charindex('{ȫ�ڽ�}',@thisMoney)>0--ȫ�ڽ�(ȫ��,���ٵ�,������-)
		begin
			if @pubWordDays>=@pubNeedWorkDays and cast(dbo.HrGetResultCount(@StratDate,@EndDate,@uid,6) as decimal(25, 12))=0 and cast(dbo.HrGetResultCount(@StratDate,@EndDate,@uid,7) as decimal(25, 12))=0
			begin
			set @thisMoney=replace(@thisMoney,'{ȫ�ڽ�}',cast(1 as varchar))
			end

			else
			begin
			set @thisMoney=replace(@thisMoney,'{ȫ�ڽ�}',cast(0 as varchar))
			end

		end

		if charindex('{�Ƽ�����}',@thisMoney)>0
		begin
		set @pubJJGZ=dbo.HrjjMoney(@StratDate,@EndDate,@uid) --�Ƽ�����
		set @thisMoney=replace(@thisMoney,'{�Ƽ�����}',cast(@pubJJGZ as varchar))

		end

		if charindex('{��Ч����}',@thisMoney)>0
		begin
		set @pubPerform=dbo.HrGetPerformSalary(@StratDate,@EndDate,@uid) --��Ч����
		set @thisMoney=replace(@thisMoney,'{��Ч����}',cast(@pubPerform as varchar))

		end
		if charindex('{��Ч����}',@thisMoney)>0
		begin
		set @pubPerform=dbo.HrGetPerformSalary(@StratDate,@EndDate,@uid) --��Ч����
		set @thisMoney=replace(@thisMoney,'{��Ч����}',cast(@pubPerform as varchar))

		end
		--bug 3364 Sword 2014-1-6 �����˰ʱ ��Ҫ����˾��.
		if charindex('{˾��}',@thisMoney)>0
		begin
			declare @workdays int,@workmoney money
			set @workdays=datediff(d,@pubEntrydate,@StratDate)  --��������
			if @workdays>0
			begin
				set @workdays=@workdays/365
				if @workdays>0
					set @workmoney=@workdays  --60:���乤��
				else
					set @workmoney=0
			end
			else
				set @workmoney=0	
			set @thisMoney=replace(@thisMoney,'{˾��}',cast(@workmoney as varchar(100)))
		end

		if charindex('{',@thisMoney)>0 and charindex('}',@thisMoney)>0
		begin

			declare @cid int,@unittype int,@title varchar(50)
			declare cur_4 cursor for select id,UnitType,title from hr_KQClass where del=0 and isprice=1 and sortid in(1,2,3,4,5) and UnitType is not null
			open cur_4
			fetch next from cur_4 into @cid,@unittype,@title
			while @@fetch_status=0
			begin

			if charindex('{'+@title+''+dbo.HrUnitTypeName(@unittype)+'}',@thisMoney)>0
			begin
			set @thisMoney=replace(@thisMoney,'{'+@title+''+dbo.HrUnitTypeName(@unittype)+'}',cast(dbo.HrPriceAppDay(@StratDate,@EndDate,@uid,@cid,@unittype) as varchar))
			end
			fetch next from cur_4 into @cid,@unittype,@title
			end
			close cur_4                   --�ر��α�
			deallocate cur_4

		end
set @NumMoney=dbo.eval(@thisMoney)

--exec('select '+@thisMoney)
return @NumMoney
end

GO
--��ȡ���ʹ�����Ŀ���
CREATE function [dbo].[HrGetSalary](
	@StratDate datetime,
	@EndDate datetime,
	@uid int,
	@flag varchar(2000),
	@salaryClassid int
) returns money
as
begin
	declare @thisMoney  money
	--idΪ1Ϊʵ�ʵ�н��gateidΪԱ�����,tsdateΪ��ʼʱ��:һ��Ҫÿ�µ�1��
	if @flag<>'' and @uid<>'' and isnumeric(@uid)=1 
		and isdate(@StratDate)=1 and isdate(@EndDate)=1 and datediff(d,@StratDate,@EndDate)>=0
	begin
		--��������
		declare @pubBasicWage money--��������
		declare @pubReguldate datetime--ת������
		declare @pubProbSalary money--�����ڹ���
		declare @pubEntrydate datetime--��ְ����
		declare @nowStatus int----Ա��״̬��1Ϊ������2Ϊ��ʱ����3Ϊ��ְ
		declare @pubWordDays money--ʵ�ʳ�������
		declare @pubNeedWorkDays money --Ӧ��������
		declare @pubLateTimes money --�ٵ�����
		declare @pubLeaveTimes money --���˴���
		declare @pubPersion money --���ϱ���
		declare @pubHealth money --ҽ�Ʊ���
		declare @pubUnplo money --ʧҵ����
		declare @pubInjury money --���˱���
		declare @pubMater money --��������
		declare @pubHouse money --ס��������
		declare @pubTax money --��������˰
		declare @pubAbsTimes money --ȱ�ڴ���
		declare @pubPerform money --��Ч����
		declare @pubJJGZ money --�Ƽ�����
		declare @pubJJCW money --����Ƽ�����

		select @pubBasicWage=BasicSalary,@pubReguldate=Reguldate,@pubProbSalary=ProbSalary,
			@pubEntrydate=Entrydate,@nowStatus=nowStatus 
		from hr_person 
		where del=0 and userID=@uid  and datediff(d,Entrydate,@EndDate)>=0
		--ʵ�ʳ�������
		set @pubWordDays=cast(dbo.HrGetRealWorkDay(@StratDate,@EndDate,@uid) as decimal(25, 12))
		--Ӧ��������
		set @pubNeedWorkDays=cast(dbo.HrGetMonthWorkDay(@StratDate,@EndDate,@uid) as decimal(25, 12))
		--��������Ϊ�� �� �����ڹ���Ϊ�� �� ��ְ���� Ϊ�� �� ʵ�ʳ�������Ϊ0 ���ع���0
		if @pubBasicWage is null or @pubProbSalary is null or @pubEntrydate is null or @pubWordDays<=0
		begin
			return cast(0 as decimal(25, 12))
		end
		else
		begin
			if charindex('{��������}',@flag)>0
			begin
				set @pubBasicWage=dbo.HrGetBaseSalary(@StratDate,@EndDate,@uid)
				set @flag=replace(@flag,'{��������}',cast(@pubBasicWage as varchar(100)))
			end

			if charindex('{ʵ�ʳ�������}',@flag)>0
			begin
				set @flag=replace(@flag,'{ʵ�ʳ�������}',cast(@pubWordDays as varchar(100)))
			end

			if charindex('{Ӧ��������}',@flag)>0
			begin
				set @flag=replace(@flag,'{Ӧ��������}',cast(@pubNeedWorkDays as varchar(100)))
			end
			--�ٵ�����
			if charindex('{�ٵ�����}',@flag)>0
			begin
				set @pubLateTimes=cast(dbo.HrGetResultCount(@StratDate,@EndDate,@uid,6) as decimal(25, 12))
				set @flag=replace(@flag,'{�ٵ�����}',cast(@pubLateTimes as varchar(100)))
			end
			--���˴���
			if charindex('{���˴���}',@flag)>0
			begin
				set @pubLeaveTimes=cast(dbo.HrGetResultCount(@StratDate,@EndDate,@uid,7) as decimal(25, 12))
				set @flag=replace(@flag,'{���˴���}',cast(@pubLeaveTimes as varchar(100)))
			end
			--ȱ�ڴ���
			if charindex('{ȱ�ڴ���}',@flag)>0
			begin	
				set @pubAbsTimes=cast(dbo.HrGetResultCount(@StratDate,@EndDate,@uid,8)as decimal(25, 12))
				set @flag=replace(@flag,'{ȱ�ڴ���}',cast(@pubAbsTimes as varchar(100)))
			end
			--���ϱ���
			if charindex('{���ϱ���}',@flag)>0
			begin
				set @pubPersion=dbo.HrMakeWelfare(@StratDate,@EndDate,@uid,1)  
				set @flag=replace(@flag,'{���ϱ���}',cast(@pubPersion as varchar(100)))
			end
			--ҽ�Ʊ���
			if charindex('{ҽ�Ʊ���}',@flag)>0
			begin
				set @pubHealth=dbo.HrMakeWelfare(@StratDate,@EndDate,@uid,2)
				set @flag=replace(@flag,'{ҽ�Ʊ���}',cast(@pubHealth as varchar(100)))
			end
			--ʧҵ����
			if charindex('{ʧҵ����}',@flag)>0
			begin
				set @pubUnplo=dbo.HrMakeWelfare(@StratDate,@EndDate,@uid,3) 
				set @flag=replace(@flag,'{ʧҵ����}',cast(@pubUnplo as varchar(100)))
			end
			--���˱���
			if charindex('{���˱���}',@flag)>0
			begin
				set @pubInjury=dbo.HrMakeWelfare(@StratDate,@EndDate,@uid,4) 
				set @flag=replace(@flag,'{���˱���}',cast(@pubInjury as varchar(100)))
			end
			--��������
			if charindex('{��������}',@flag)>0
			begin
				set @pubMater=dbo.HrMakeWelfare(@StratDate,@EndDate,@uid,5) 
				set @flag=replace(@flag,'{��������}',cast(@pubMater as varchar(100)))
			end
			--ס��������
			if charindex('{ס��������}',@flag)>0
			begin
				set @pubHouse=dbo.HrMakeWelfare(@StratDate,@EndDate,@uid,6) 
				set @flag=replace(@flag,'{ס��������}',cast(@pubHouse as varchar(100)))
			end
			--��������˰
			if charindex('{��������˰}',@flag)>0
			begin
				set @pubTax=dbo.HrTaxMoney(@StratDate,@EndDate,@uid) 
				set @flag=replace(@flag,'{��������˰}',cast(@pubTax as varchar(100)))
			end
			--ȫ�ڽ�
			if charindex('{ȫ�ڽ�}',@flag)>0
			begin
				if @pubWordDays>=@pubNeedWorkDays and cast(dbo.HrGetResultCount(@StratDate,@EndDate,@uid,6) as decimal(25, 12))=0 
					and cast(dbo.HrGetResultCount(@StratDate,@EndDate,@uid,7) as decimal(25, 12))=0
				begin
					set @flag=replace(@flag,'{ȫ�ڽ�}',1)
				end
				else
				begin
					set @flag=replace(@flag,'{ȫ�ڽ�}',0)
				end
			end
			--�Ƽ�����
			if charindex('{�Ƽ�����}',@flag)>0
			begin
				set @pubJJGZ=dbo.HrjjMoney(@StratDate,@EndDate,@uid)
				set @flag=replace(@flag,'{�Ƽ�����}',cast(@pubJJGZ as varchar(100)))
			end
			--����Ƽ�����
			if charindex('{����Ƽ�����}',@flag)>0
			begin
				set @pubJJCW=dbo.CWjjMoney(@StratDate,@EndDate,@uid,@salaryClassid) 
				set @flag=replace(@flag,'{����Ƽ�����}',cast(@pubJJCW as varchar(100)))
			end
			--��Ч����
			if charindex('{��Ч����}',@flag)>0
			begin
				set @pubPerform=dbo.HrGetPerformSalary(@StratDate,@EndDate,@uid) 
				set @flag=replace(@flag,'{��Ч����}',cast(@pubPerform as varchar(100)))
			end

			if charindex('{˾��}',@flag)>0
			begin
				declare @workdays int,@workmoney money
				set @workmoney=0
				set @workdays=datediff(d,@pubEntrydate,@StratDate)  --��������
				if @workdays>0 and @workdays/365 > 0
				begin
					set @workmoney=@workdays/365  --60:���乤��
				end
				set @flag=replace(@flag,'{˾��}',cast(@workmoney as varchar(100)))
			end

			if charindex('{',@flag)>0 and charindex('}',@flag)>0
			begin
				declare @cid int,@unittype int,@title varchar(50)
				declare cur_1 cursor for select id,UnitType,title from hr_KQClass where del=0 and isprice=1 
					and sortid in(1,2,3,4,5) and UnitType is not null and sortID<>0
				open cur_1
				fetch next from cur_1 into @cid,@unittype,@title
				while @@fetch_status=0
					begin
						set @flag=replace(@flag,'{'+@title+''+dbo.HrUnitTypeName(@unittype)+'}',
							cast(dbo.HrPriceAppDay(@StratDate,@EndDate,@uid,@cid,@unittype) as varchar(100)))
						fetch next from cur_1 into @cid,@unittype,@title
					end
				close cur_1                   --�ر��α�
				deallocate cur_1
			end
			set @thisMoney=dbo.eval(@flag)
		end
	end
	else
	begin
		return cast(0 as decimal(25, 12))
	end
	return isnull(@thisMoney,0)
end

GO

--����ĳ��ʱ����ĳ���˵�ĳ��������������(н��)
CREATE  function [dbo].[HrPriceAppDay]
(
	@startDate datetime,
	@endDate datetime,
	@uid int,
	@sortid int,
	@unit int
) returns int
as
begin

	declare @appNum int
	if @startDate<>'' and isdate(@startDate)=1 and @endDate<>'' and isdate(@endDate)=1 and @uid<>''  and isnumeric(@uid)=1 and @sortid<>'' and isnumeric(@sortid)=1
	begin
		declare @D_StartDate datetime,@D_endDate datetime,@kqSortid int
		select @kqSortid=sortID from  hr_KQClass where del=0 and id=@sortid
		if @kqSortid=2
		begin
			if @unit=2--Сʱ
			begin
				set @appNum=(select sum(DATEDIFF(hh,(case when DATEDIFF(d,startTime,@startDate)>0 then @startDate+' 00:00:00' else startTime end),(case when DATEDIFF(d,@endDate,endTime)>0 then @endDate+' 23:59:59' else endTime end)))  from hr_AppHoliday where status=3 and del=0 and KQClass =@sortid  and creator=@uid and ((DATEDIFF(d,@startDate,endTime)>=0 and DATEDIFF(d,@endDate,endTime)<=0)  or (DATEDIFF(d,@startDate,startTime)>=0 and DATEDIFF(d,@endDate,startTime)<=0)))
			end
			else if @unit=3--ʵ������
			begin
				set @appNum=(select sum(DATEDIFF(d,(case when DATEDIFF(d,startTime,@startDate)>0 then @startDate else startTime end),(case when DATEDIFF(d,@endDate,endTime)>0 then @endDate else endTime end))+1)  from hr_AppHoliday where status=3 and del=0 and KQClass =@sortid  and creator=@uid and ((DATEDIFF(d,@startDate,endTime)>=0 and DATEDIFF(d,@endDate,endTime)<=0)  or (DATEDIFF(d,@startDate,startTime)>=0 and DATEDIFF(d,@endDate,startTime)<=0) or (DATEDIFF(d,@startDate,startTime)<=0 and DATEDIFF(d,@endDate,endTime)>=0)))
			end
			else
			begin
				set @appNum=(select count(*)  from hr_AppHoliday where status=3 and del=0 and KQClass =@sortid  and creator=@uid and ((DATEDIFF(d,@startDate,endTime)>=0 and DATEDIFF(d,@endDate,endTime)<=0)  or (DATEDIFF(d,@startDate,startTime)>=0 and DATEDIFF(d,@endDate,startTime)<=0) or (DATEDIFF(d,@startDate,startTime)<=0 and DATEDIFF(d,@endDate,endTime)>=0) ))
			end
		end
		else
		begin
			if @unit=2--Сʱ
			begin
				set @appNum=(select sum(dbo.HrGetRealHour((case when DATEDIFF(d,startTime,@startDate)>0 then @startDate+' 00:00:00' else startTime end),(case when DATEDIFF(d,@endDate,endTime)>0 then @endDate+' 23:59:59' else endTime end),@uid))  from hr_AppHoliday where status=3 and del=0 and KQClass =@sortid  and creator=@uid and ((DATEDIFF(d,@startDate,endTime)>=0 and DATEDIFF(d,@endDate,endTime)<=0)  or (DATEDIFF(d,@startDate,startTime)>=0 and DATEDIFF(d,@endDate,startTime)<=0)))
			end
			else if @unit=3--ʵ������
			begin
				set @appNum=(select sum(dbo.HrGetMonthWorkDay((case when DATEDIFF(d,startTime,@startDate)>0 then @startDate else startTime end),(case when DATEDIFF(d,@endDate,endTime)>0 then @endDate else endTime end),@uid))  from hr_AppHoliday where status=3 and del=0 and KQClass =@sortid  and creator=@uid and ((DATEDIFF(d,@startDate,endTime)>=0 and DATEDIFF(d,@endDate,endTime)<=0)  or (DATEDIFF(d,@startDate,startTime)>=0 and DATEDIFF(d,@endDate,startTime)<=0) or (DATEDIFF(d,@startDate,startTime)<=0 and DATEDIFF(d,@endDate,endTime)>=0)))
			end
			else
			begin
				set @appNum=(select count(*)  from hr_AppHoliday where status=3 and del=0 and KQClass =@sortid  and creator=@uid and ((DATEDIFF(d,@startDate,endTime)>=0 and DATEDIFF(d,@endDate,endTime)<=0)  or (DATEDIFF(d,@startDate,startTime)>=0 and DATEDIFF(d,@endDate,startTime)<=0) or (DATEDIFF(d,@startDate,startTime)<=0 and DATEDIFF(d,@endDate,endTime)>=0) ))
			end
		end
		if isnumeric(@appNum)=0
		begin
			set @appNum=0
		end
	end
	else
	begin
		set @appNum=0
	end
	return isnull(@appNum,0)
end

GO

--��ѯ��������˰
CREATE function [dbo].[HrTaxMoney]
(
	@StratDate datetime,
	@EndDate datetime,
	@uid int
)returns money
as
begin
	--���Ʋ���
	declare @TaxBase money,@sortid int
	select @TaxBase=taxbase,@sortid=id from hr_PersonTaxSort where del=0 and datediff(d,startTime,@StratDate)>=0 and datediff(d,endTime,@EndDate)<=0
	--δ���ø�������˰
	if @TaxBase is null
	begin
		return 0.0
	end
	declare @thisMoney  money
	declare @TallMoney  money,@needMoney money
	set @TallMoney=(dbo.HrGetTallMoney(@StratDate,@EndDate,@uid))-@TaxBase
	--δ�ﵽ��˰����
	if @TallMoney<=0
	begin
		return 0.0
	end
	select @thisMoney=(@TallMoney*0.01*taxRate-cut) from hr_PersonTax where sortid=@sortid and @TallMoney>[lower] and @TallMoney<=limit
	if @thisMoney is null
	begin
		set @thisMoney=0.0
	end
	return @thisMoney
end

GO

--Attrs:�����¿���
CREATE function [dbo].[GetHTMLInnerText]
(
    @input    VARCHAR(8000)--2000�ڸ�ΪVARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
    --��html������ȡ�����ֲ���
    declare
    @Result varchar(8000),
    @start int,
    @end int,
    @len int

    set @input = @input+'<>'
    set @Result = ''
    set @len=len(@input)
    set @start = charindex('<',@input,1)
    set @end = charindex('>',@input,@start)
    while(@start<@end)
        begin
            if(@start<>1)
            set @Result = @Result + substring(@input,1,@start-1)
            set @len = @len - @end
            set @input = substring(@input,@end+1,@len)
            set @start = charindex('<',@input,1)
            set @end = charindex('>',@input,@start)
        end

    RETURN replace(@Result,'&nbsp;','')
END

GO

CREATE function [dbo].[GetHTMLAttrText]
(
    @input    VARCHAR(8000)--2000�ڸ�ΪVARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
    --��html�����������ת��
    RETURN replace(replace(replace(replace(@input,'<','&lt;'),'>','&gt;'),'"','&quot;'),'''','&#39;')
END

GO

Create function [dbo].[check_mail] (@str nvarchar(100)) returns  int
as
BEGIN
	declare @i int
	declare @len int
	declare @val int
	declare @res int
	if @str is null or @str=''
		return 0
	if charindex('@',@str)=0 or charindex('.',@str)=0
		return 0

	if not(unicode(left(@str,1)) between 65 and 90 or unicode(left(@str,1)) between 97 and 122 or unicode(left(@str,1)) between 48 and 57)
	return 0
	set @i=2
	set @len=charindex('@',@str)
	while @i<@len
	begin
		set @val=unicode(right(left(@str,@i),1))
		if not (@val between 65 and 90 or @val between 97 and 122 or @val=95 or @val between 48 and 57)
			return 0
		set @i=@i+1
	end
	Set @i=@i+1
	while @i<len(@str)
	begin
		set @val=unicode(right(left(@str,@i),1))
		if not (@val between 65 and 90 or @val between 97 and 122 or @val=46  or @val=45 or @val between 48 and 57)
			return 0
		set @i=@i+1
	end
	RETURN 1
END

GO

create function [dbo].[HrGetPerformContentBySp](@id int,@spid int,@cateid int,@typeid int)
returns varchar(4000)
as
begin
    -- ���ں��� HrGetPerformContent�ĸĽ��档������������ID����ȡ��Ч����
    declare @str varchar(4000)
    if isnumeric(@id)=1 and isnumeric(@typeid)=1 and isnumeric(@spid)=1 and isnumeric(@cateid)=1
    begin
    if @typeid=1
    begin
    select @str=content from hr_perform_Comments where del=0 and typeid=1 and perform=@id and cateid=@cateid and sp=@spid

    end

    else
    begin
    select @str=content from hr_perform_Comments where del=0 and typeid=0 and perform=@id and sp=@spid
    end

    end

    else
    begin
    set @str=''
    end
    return @str
end

GO

create   function [dbo].[HrGetPerformScoreBySp](@id int,@project int,@spid int,@cateid int,@typeid int)
returns float
as
begin
    -- ���ں��� HrGetPerformScore �ĸĽ��档��������ID����ȡ��Ч����
    declare @Num float
    if isnumeric(@id)=1 and isnumeric(@project)=1 and isnumeric(@spid)=1 and isnumeric(@cateid)=1
    begin
    if @typeid=1
    begin
    select @Num=score from hr_perform_score where del=0 and typeid=1 and perform=@id and cateid=@cateid and sp=@spid and project=@project
    end

    else
    begin
    select @Num=score from hr_perform_score where del=0 and typeid=0 and perform=@id and cateid=@cateid and sp=@spid and project=@project
    end

    end

    else
    begin
    return cast(0 as decimal(25, 12) )
    end

    if @Num is null
    begin
    return cast(0 as decimal(25, 12) )
    end

    return @Num
end

GO

--��Ʒ������䶯���ڳ����
create function [dbo].[proQCKCHZ](@t1 datetime)
returns @tab table(ord int,unit int,ck int,qc_kc decimal(25, 12),qc_money money)
as
begin

insert @tab
select ord,unit,ck,isnull((isnull(t.num_in_before_begin,0)-isnull(num_out_before_begin,0)),0) as qc_kc,
		isnull((isnull(t.money_rk1,0)+isnull(money_rk3,0)-isnull(money_ck1,0)),0) as qc_money
from
(
	select ord,unit,ck,sum(num_in_before_begin) as num_in_before_begin,sum(num_out_before_begin) as num_out_before_begin,
				sum(money_rk1) as money_rk1,sum(money_rk3) as money_rk3,sum(money_ck1) as money_ck1
	from
	(
		--��ʼʱ��֮ǰ�ĳ�ʼ���
		select ord,unit,ck,sum(num1) as num_in_before_begin,0 as num_out_before_begin,0 as money_rk1,0 as money_rk3,0 as money_ck1 from
		(
			select s_b.ord,s_b.unit,s_b.ck,isnull(sum(s_b.num3),0) as num1 from kuinlist s_a
			inner join ku s_b on s_a.id=s_b.kuinlist
			where s_a.[dateadd] < convert(varchar(20),@t1,23) and (s_a.del=1 or s_a.del=99)
			group by s_b.ord,s_b.unit,s_b.ck
			union all
			select s_c.ord,s_c.unit,s_c.ck,isnull(sum(s_b.num1),0) as num1 from kuinlist s_a
			inner join kuhclist s_b on s_a.id=s_b.kuinlist and s_b.del=1
			inner join ku s_c on s_c.id=s_b.kuid
			where s_a.dateadd < ''+convert(varchar(20),@t1,23)+'' and (s_a.del=1 or s_a.del=99)
			group by s_c.ord,s_c.unit,s_c.ck
		) ab group by ord,unit,ck
		union all
		--��ʼʱ��֮ǰ�ĳ�������
		select ord,unit,ck,0,isnull(sum(num1),0) as num_out_before_begin,0,0,0 from kuoutlist2
		where date1 < ''+convert(varchar(20),@t1,23)+'' and (del=1 or del=99)
		group by ord,unit,ck
		union all
		--��ʼʱ��֮ǰ��ⵥ�ǶԳ岿�ֵ��ܳɱ�
		select x.ord,x.unit,x.ck,0,0,isnull(sum(case when x.num1>0 then cast(x.money1/x.num1 as decimal(25,12))*x.num3 else 0 end),0) as money_rk1,0,0 from ku as x
		inner join kuinlist as y on x.num1<>0 and x.kuinlist=y.id
		where (y.del=1 or y.del=99) and y.[dateadd] < ''+convert(varchar(20),@t1,23)+''
		group by x.ord,x.unit,x.ck
		union all
		--��ʼʱ��֮ǰ��ⵥ�жԳ岿�ֵ��ܳɱ�
		select x.ord,x.unit,x.ck,0,0,0,isnull(sum(isnull(case when x.num1>0 then cast(x.money1/x.num3 as decimal(25,12))*y.num1 when x.num1<=0 and x.num2>0 then cast(x.money1/abs(x.num3) as decimal(25,12))*y.num1 else 0 end,0)),0) as money_rk3,0 from ku x
		inner join kuhclist as y on x.num1<>0 and x.id=y.kuid
		inner join kuinlist z on z.id=y.kuinlist
		where y.del=1 and z.dateadd < ''+convert(varchar(20),@t1,23)+' 23:59:59'
		group by x.ord,x.unit,x.ck
		union all
		--��ʼʱ��֮ǰ�ĳ���ɱ�
		select y.ord,y.unit,y.ck,0,0,0,0,isnull(sum(y.money1),0) as money_ck1 from ku as x
		inner join kuoutlist2 as y on x.num1<>0 and x.id=y.ku
		where y.date1 < ''+convert(varchar(20),@t1,23)+'' and (y.del=1 or y.del=99) and x.num1>=0
		group by y.ord,y.unit,y.ck
	) t group by ord,unit,ck
) as t
return
end

GO

create function [dbo].[ExistsModel](@currModels varchar(7700),@mv int)
returns int as begin
	return sign(charindex(',' + cast(@mv as varchar(12)) + ',', ','+@currModels + ','))
end

GO

create function [dbo].[EvalModel](@currModels varchar(5000),@modelcode varchar(1000))
returns int as begin
	--ǩ������Ϊ�գ�����ǩ��Ȩ��
	--Ŀǰ��֧������
	declare @r int
	declare @tb1 table(Id int, code varchar(1000))
	declare @tb2 table(Id int, code varchar(1000))
	declare @i int, @ii int, @c1 int, @c2 int, @cv varchar(1000), @v int, @v2 int
	declare @sql nvarchar(1000)
	
	if len(isnull(@modelcode,'')) = 0
	begin
		set @r = 1
	end
	else
	begin		
		if isnumeric(@modelcode)=1
		begin
			set @r=sign(charindex(','+@modelcode + ',',','+@currModels + ','))
		end
		else
		begin
				set @modelcode = replace(replace(@modelcode,'CML(@models,',''),')=1','')  --����������ʽ
				set @v = 0
				insert into @tb1 (id, code)
				select id, short_str from dbo.split(@modelcode,' or ')
				set @i = 1
				select @c1 = max(id) from @tb1
				while @i <= @c1
				begin
					select @cv = code from @tb1 where id = @i
					if isnumeric(@cv) = 1
					begin
						set @v = @v + dbo.EvalModel(@currModels , @cv)
					end
					else
					begin
						set @v2 = NULL
						select @v2 =  isnull(@v2,1)*(case isnumeric(short_str) when 1 then dbo.EvalModel(@currModels , short_str) else 0 end)
						from dbo.split(@cv,' and ')
						set @v = @v + isnull(@v2,0)
					end
					set @i = @i+1
				end
				set @r = sign(@v)
		end
	end
	return @r
end

GO

--����html ��ǩ�����������ָ�ʽ �� ����ǰ �����˲��ֱ����ת��
--Bob 2012-8-1 �� xls ���� ������
Create FUNCTION [dbo].[TrimHTML](@input NVARCHAR(4000))
returns NVARCHAR(4000)
AS
BEGIN
DECLARE @Result NVARCHAR(4000),
	@start int,
    @end int,
    @len INT

SET @input=REPLACE(@input,'&nbsp;',' ')
SET @input=REPLACE(@input,'<P>',CHAR(13)+Char(10))
SET @input=REPLACE(@input,'</P>',CHAR(13)+Char(10))
SET @input=REPLACE(@input,'<br>',CHAR(13)+Char(10))
SET @input=REPLACE(@input,'<br />',CHAR(13)+Char(10))
SET @input=REPLACE(@input,'<br/>',CHAR(13)+Char(10))
SET @input=REPLACE(@input,'</div><div>',CHAR(13)+Char(10))
SET @input=REPLACE(@input,'<div>',CHAR(13)+Char(10))
SET @input=REPLACE(@input,'</div>','</div>'+CHAR(13)+Char(10))

SET @input = @input+'<>'
    SET @Result = ''
    SET @len=len(@input)
    SET @start = charindex('<',@input,1)
    SET @end = charindex('>',@input,@start)
    WHILE(@start<@end)
        BEGIN
            IF(@start<>1)
              SET @Result = @Result + substring(@input,1,@start-1)
            SET @len = @len - @end
            SET @input = substring(@input,@end+1,@len)
            SET @start = charindex('<',@input,1)
            SET @end = charindex('>',@input,@start)
        END
	RETURN @Result
END

GO

create function [dbo].[getBillLinkHTML](
	 @title varchar(2000), @baseurl varchar(500), @bid int, @creator int, @uid int, @qxlb int
) returns varchar(2000) as begin
	--����HTML����
	if @qxlb=0 or exists(
		select 1
		from [power] a where sort1=@qxlb and sort2=14 and a.ord=@uid
		and
			(
				qx_open = 3
				or
				(qx_open=1 and @qxlb=21) --21��ƷȨ�ޣ�������Χ
				or
				(qx_open=1 and charindex(',' + cast(@creator as varchar(12)) + ',', ','+replace(cast(qx_intro as varchar(8000)),' ','')+',') > 0)
			)
	)
	begin
		set @title='<a href="' + replace(replace(@baseurl,'@Id',cast(@bid as varchar(12))),'@ord',  dbo.NumEnCode(@bid)) + '" target="blank" class="rptlink">' + @title + '</a>'
	end
	else
		begin
			set @title='<a class="power" style="cursor:hand">' + @title + '</a>'
		end
	return @title
end

GO

--2014-3-29.ljh.������ԭ�����Ļ����϶������������
create function [dbo].[getBillLinkHTML2](
	 @title varchar(2000), @baseurl varchar(500), @bid int, @creator int, @uid int, @qxlb int,@unit int,@ck int
) returns varchar(2000) as begin
	--����HTML����
	if @qxlb=0 or exists(
		select 1
		from [power] a where sort1=@qxlb and sort2=14 and a.ord=@uid
		and
			(
				qx_open = 3
				or
				(qx_open=1 and @qxlb=21) --21��ƷȨ�ޣ�������Χ
				or
				(qx_open=1 and charindex(',' + cast(@creator as varchar(12)) + ',', ','+replace(cast(qx_intro as varchar(8000)),' ','')+',') > 0)
			)
	)
	begin		
		set @title='<a href="' + replace(replace(replace(replace(@baseurl,'@Id',cast(@bid as varchar(12))),'@unit',cast(@unit as varchar(10))),'@ck',cast(@ck as varchar(10))),'@ord',  dbo.NumEnCode(@bid)) + '" target="blank" class="rptlink">' + @title + '</a>'
	end
	else
		begin
			set @title='<a class="power" style="cursor:hand">' + @title + '</a>'
		end
	return @title
end

GO

Create function [dbo].[dateDiffByDay](@date1 datetime,@unit int,@days decimal(25, 12),@tq int,@nowDate datetime) returns int
as
begin
declare @ClassName varchar(200)
	declare @diff int
	set @diff = (case @unit 
	when 1 then		--��λΪ��Сʱ
		DATEDIFF(dd,@date1,dateadd(dd,(@days/24+@tq),@nowDate))		
	when 2 then 	--��λΪ����
		DATEDIFF(dd,@date1,dateadd(dd,(@days+@tq),@nowDate))
	when 3 then		--��λΪ����
		DATEDIFF(dd,@date1,dateadd(dd,(@days*7+@tq),@nowDate))		
	when 4 then		--��λΪ����
		DATEDIFF(dd,@date1,dateadd(dd,(@days*30+@tq),@nowDate))		
	when 5 then		--��λΪ����
		DATEDIFF(dd,@date1,dateadd(dd,(@days*365+@tq),@nowDate))
	end)
	return @diff
end

GO

Create function [dbo].[dateAddByDay](@date1 datetime,@unit int,@days decimal(25, 12)) returns datetime
as
begin
declare @ClassName varchar(200)
	declare @date datetime
	set @date = (case @unit 
	when 1 then		--��λΪ��Сʱ	
		DATEADD(dd,(@days/24),@date1)		
	when 2 then 	--��λΪ����
		DATEADD(dd,@days,@date1)
	when 3 then		--��λΪ����
		DATEADD(dd,(@days*7),@date1)		
	when 4 then		--��λΪ����
		DATEADD(dd,(@days*30),@date1)		
	when 5 then		--��λΪ����
		DATEADD(dd,(@days*365),@date1)
	end)
	return @date
end

GO

Create  function [dbo].[HrWagesIntro](@wages int,@uid int,@wageSort int)
returns nvarchar(4000)
begin
declare @intro nvarchar(4000)

if isnumeric(@uid)=1 and isnumeric(@wageSort)=1
begin
select @intro=intro from wageslist where wages=@wages and cateid=@uid and sort1=@wageSort
end

else
begin
return ''
end

return isnull(@intro,'')

end

GO

create function [dbo].[getPowerIntro](@ord int, @sort1 int, @sort2 int)
returns varchar(8000)
as begin
	declare @r varchar(8000)
	select top 1 @r =
	case b.sort
	when 3 then
		case a.qx_open
		when 3 then ''
		when 1 then replace('-1,' + replace(cast(qx_intro as varchar(7000)),' ','') + ',-1',',,',',')
		else '0'
		end
	else
		case a.qx_open
		when 1 then ''
		else '0'
		end
	end
	from power a inner join qxlblist b
	on a.sort1=b.sort1 and a.sort2=b.sort2 and a.sort1=@sort1 and b.sort2=@sort2 and a.ord=@ord
	set @r = isnull(@r,'0')
	return @r
end

GO

-------------------------------------------------------------------------------------
--�������ص��˵���Ŀ��ڽ��:
--�ѵ�: ���ݿ��ڲ���,���ڹ���,���ڼ�¼,���������,��������״̬
--examp:
--		select dbo.[HrGet_oneday_Result] ('2012-11-30',63)
--
--------------------------------------------------------------2012-11-6 lilinzhi-----
--
CREATE function [dbo].[HrGet_oneday_Result](@today datetime,@uid int) returns int
as
begin
declare @num int
set @num=(select
			top 1 (case TodayNeedWork
				when 2 then --��Ϣ
					case when TodayAPPHoliDay>0then --�����뵥
						case when isnull((select top 1 sortid from hr_KQClass where del=0 and id=TodayAPPHoliDay),0)=1 then 18--��Ϣ
							else TodayAPPHoliDay
							end
					else 18--��Ϣ
					end
				when 3 then --�ż�
						case when TodayAPPHoliDay>0 then TodayAPPHoliDay
							else 19--�ż�
							end
				when 1 then
					case when TodayAPPHoliDay>0 then TodayAPPHoliDay--�����뵥
						else
							case when (select count(*) from hr_Log where del=0 and abs(datediff(yyyy,inDate,workTimeLogin))<10 and abs(datediff(n,inDate,workTimeLogin))<=hoDay_Ref and  creator=@uid and datediff(d,inDate,@today)=0)>0 then
								case when workTimelogin>workTimeOut then 14 --�쳣
									--���ݿ��ڼ�¼,����3��״̬֮1
									when (select count(*) from hr_Log where del=0 and abs(datediff(yyyy,inDate,workTimeLogin))<10 and datediff(n,workTimeLogin,inDate)<=login_M and abs(datediff(n,inDate,workTimeLogin))<=hoDay_Ref and  creator=@uid and datediff(d,inDate,@today)=0)<>0 and  (select count(*) from hr_Log where del=0 and abs(datediff(yyyy,inDate,workTimeLogin))<10 and (datediff(n,workTimeOut,inDate)>=leave_M*(-1)) and abs(datediff(n,inDate,workTimeOut))<=hoDay_Ref and  creator=@uid)<>0  then 15 --����
									when (select count(*) from hr_Log where del=0 and abs(datediff(yyyy,inDate,workTimeLogin))<10 and datediff(n,workTimeLogin,inDate)<=login_M and abs(datediff(n,inDate,workTimeLogin))<=hoDay_Ref and  creator=@uid and datediff(d,inDate,@today)=0)=0 and  (select count(*) from hr_Log where del=0 and abs(datediff(yyyy,inDate,workTimeLogin))<10 and (datediff(n,workTimeOut,inDate)>=leave_M*(-1)) and abs(datediff(n,inDate,workTimeOut))<=hoDay_Ref and  creator=@uid)=0 then 16 --�ٵ� ����
									when (select count(*) from hr_Log where del=0 and abs(datediff(yyyy,inDate,workTimeLogin))<10 and (datediff(n,workTimeOut,inDate)>=leave_M*(-1)) and abs(datediff(n,inDate,workTimeOut))<=hoDay_Ref and  creator=@uid)=0 then 7--����
									when (select count(*) from hr_Log where del=0 and abs(datediff(yyyy,inDate,workTimeLogin))<10 and datediff(n,workTimeLogin,inDate)<=login_M and abs(datediff(n,inDate,workTimeLogin))<=hoDay_Ref and  creator=@uid and datediff(d,inDate,@today)=0)=0 then 6--�ٵ�
									end
							else 8 --ȱ��
							end
						end
				when 4 then
					case when TodayAPPHoliDay>0 then TodayAPPHoliDay--�����뵥
						else
							case when (select count(*) from hr_Log where del=0 and abs(datediff(yyyy,inDate,workTimeLogin))<10 and abs(datediff(n,inDate,workTimeLogin))<=hoDay_Ref and  creator=@uid and datediff(d,inDate,@today)=0)>0 then
								case when workTimelogin>workTimeOut then 14 --�쳣
									--���ݿ��ڼ�¼,����3��״̬֮1
									when (select count(*) from hr_Log where del=0 and abs(datediff(yyyy,inDate,workTimeLogin))<10 and datediff(n,workTimeLogin,inDate)<=login_M and abs(datediff(n,inDate,workTimeLogin))<=hoDay_Ref and  creator=@uid and datediff(d,inDate,@today)=0)<>0 and  (select count(*) from hr_Log where del=0 and abs(datediff(yyyy,inDate,workTimeLogin))<10 and (datediff(n,workTimeOut,inDate)>=leave_M*(-1)) and abs(datediff(n,inDate,workTimeOut))<=hoDay_Ref and  creator=@uid)<>0  then 20--�ڼ��յ���
									when (select count(*) from hr_Log where del=0 and abs(datediff(yyyy,inDate,workTimeLogin))<10 and datediff(n,workTimeLogin,inDate)<=login_M and abs(datediff(n,inDate,workTimeLogin))<=hoDay_Ref and  creator=@uid and datediff(d,inDate,@today)=0)=0 and  (select count(*) from hr_Log where del=0 and abs(datediff(yyyy,inDate,workTimeLogin))<10 and (datediff(n,workTimeOut,inDate)>=leave_M*(-1)) and abs(datediff(n,inDate,workTimeOut))<=hoDay_Ref and  creator=@uid)=0 then 16 --�ٵ� ����
									when (select count(*) from hr_Log where del=0 and abs(datediff(yyyy,inDate,workTimeLogin))<10 and (datediff(n,workTimeOut,inDate)>=leave_M*(-1)) and abs(datediff(n,inDate,workTimeOut))<=hoDay_Ref and  creator=@uid)=0 then 7--����
									when (select count(*) from hr_Log where del=0 and abs(datediff(yyyy,inDate,workTimeLogin))<10 and datediff(n,workTimeLogin,inDate)<=login_M and abs(datediff(n,inDate,workTimeLogin))<=hoDay_Ref and  creator=@uid and datediff(d,inDate,@today)=0)=0 then 6--�ٵ�
									end
							else 8 --ȱ��
							end
						end
				else 14
				end) as s
			--���ݿ��ڲ�����
			from (
				select isnull(login_M,0)*60 as login_M,isnull(leave_M,0)*60 as leave_M,overtime_M*60 as overtime_M,work_H,login_Pat,overtime_to_int,isnull(hoDay_Ref,2)*60 as hoDay_Ref,k.companyType,publicTest,
				--�Ƿ���Ҫ�ϰ�
				(case publicTest
					when 1 then
						case todayNeedWork
							when 1 then
								case when (select count(*) from hr_holiday where del=0 and charindex('|'+replace(cast(convert(varchar(10),@today,120) as varchar(2000)),'-0','-')+'|','|'+replace(noNeedWork,'-0','-')+'|')>0)>0 then 3 end
							when 2 then
								case when (select count(*) from hr_holiday where del=0 and charindex('|'+replace(cast(convert(varchar(10),@today,120) as varchar(2000)),'-0','-')+'|','|'+replace(NeedWork,'-0','-')+'|')>0)>0 then 4 else 2 end
						end
					when 2 then todayNeedWork
					else 0
					end
				) as todayNeedWork,
				--������
				isnull((select top 1 KQClass  from hr_AppHoliday where creator=@uid and del=0 and status=3 and (datediff(d,startTime,@today)>=0 and datediff(d,endTime,@today)<=0)),0) as TodayAPPHoliDay,
				--�ϰ�ʱ��
				(case k.companyType
					when 1 then
							cast(cast(convert(varchar(10),@today,120) as varchar)+' '+isnull(
									(select (select case datepart(weekday,@today)
													when 1 then stime7
													when 2 then stime1
													when 3 then stime2
													when 4 then stime3
													when 5 then stime4
													when 6 then stime5
													when 7 then stime6 end)
												from hr_com_time
												where del=0 and (@today between startTime and endTime) and ((isall=0 and charindex((','+cast(@uid as varchar(50))+','),(','+cast(user_list as varchar(4000))+','))>0) or isall=1)),'00:00:00.000') as datetime)
					when 2 then
							cast(cast(convert(varchar(10),@today,120) as varchar)+' '+isnull(
									(select dateStart from hr_dayWorkTime where id=isnull(
											(select workClass from hr_Fc_time
											 where personClass=(select id from hr_PersonClass
																where workClass<>0 and del=0 and (isall=1 or (isall=0 and charindex(','+cast(@uid as varchar(50))+',',','+cast(user_list as varchar(4000))+',')>0))) and del=0 and datediff(d,d1,@today)>=0 and datediff(d,d2,@today)<=0 ),'0')),'00:00:00.000') as datetime)
					end) as workTimeLogin,
				--�°�ʱ��
				(case k.companyType
					when 1 then
							cast(cast(convert(varchar(10),@today,120) as varchar)+' '+isnull(
									(select (select case datepart(weekday,@today)
													when 1 then etime7
													when 2 then etime1
													when 3 then etime2
													when 4 then etime3
													when 5 then etime4
													when 6 then etime5
													when 7 then etime6 end)
												from hr_com_time
												where del=0 and (@today between startTime and endTime) and ((isall=0 and charindex((','+cast(@uid as varchar(50))+','),(','+cast(user_list as varchar(4000))+','))>0) or isall=1)),'00:00:00.000') as datetime)
					when 2 then
							cast(cast(convert(varchar(10),@today,120) as varchar)+' '+isnull(
									(select dateEnd from hr_dayWorkTime where id=isnull(
										(select workClass from hr_Fc_time where personClass=(select id from hr_PersonClass where workClass<>0 and del=0 and (isall=1 or (isall=0 and charindex(','+cast(@uid as varchar(50))+',',','+cast(user_list as varchar(4000))+',')>0)) ) and del=0 and datediff(d,d1,@today)>=0 and datediff(d,d2,@today)<=0 ),'0')),'00:00:00.000') as datetime)
					end ) as workTimeOut
				from hr_KQ_config k
				inner join (
					select (select case datepart(weekday,@today)
							when 1 then open7
							when 2 then open1
							when 3 then open2
							when 4 then open3
							when 5 then open4
							when 6 then open5
							when 7 then open6 end) as todayNeedWork,1 as companyType
					from hr_com_time where del=0 and (@today between startTime and endTime) and ((isall=0 and charindex((','+cast(@uid as varchar(50))+','),(','+cast(user_list as varchar(4000))+','))>0) or isall=1)  --opens
					union all
					select (select case when isnull(workClass,0)>=1 then 1
										when isnull(workClass,0)=0 then 2
										else 0 end) as todayNeedWork,2 as companyType
					from hr_Fc_time where personClass=(select id from hr_PersonClass where del=0  and (isall=1 or (isall=0 and CHARINDEX(','+cast(@uid as varchar(50))+',',','+cast(user_list as varchar(4000))+',')>0)) ) and del=0 and (@today between d1 and d2)
				) c on c.companyType=k.companyType
				where del=0 and (@today between startTime and endTime)
		) G)
return isnull(@num,0)
end

GO

create function [dbo].[home_mainlink_config_fun] (@uid int)
returns table as return
(
	--��ȡ������ɫ�������������ñ�
	select a.* from  home_mainlink_config a
	inner join
	(
		select max(role) as r, id from home_mainlink_config where (uid= @uid or role < 2)
		group by id
	) b on a.id= b.id and a.role = b.r and (a.role<3 or uid= @uid)
)

GO

create function [dbo].[GetHl] (@bz int, @d datetime, @now datetime)
returns money
as begin
	declare @r float
	select @r=hl from hl where bz=@bz and datediff(d,date1,@d)=0
	select @r=hl from hl where bz=@bz and isnull(@r,0)=0 and datediff(d,date1,@now)=0
	set @r = isnull(@r,1)
	return @r
end

GO

--������С���ڣ���ֹdetediff���
create function [dbo].[MinDate](@currT datetime) 
returns datetime
as begin
	return (case when year(ISNULL(@currT, '1979-1-1')) < 1980 then  '1980-1-1'  else  @currT end)
end 

GO

create function [dbo].[HasPower](@intro varchar(8000),@creator int) 
returns int
as begin
	return 
		case @intro
		when '' then 1
		when '0' then 0
		else 
			sign(charIndex(',' + cast(@creator as varchar(12)) + ',',',' + @intro + ','))
		end
end

GO

create function [dbo].[showBirthDTText](@t int)
returns varchar(100)
as
begin
 return case @t when 0 then '����' else '����' + cast(@t as varchar(12)) + '��' end 
end

GO

create function [dbo].[ShowNlDateFormat](@date1 varchar(10), @isnl int)
returns nvarchar(50)
as begin
	--��ʾũ����ʽ
	if(@isnl = 0) return @date1
	declare @year nvarchar(4), @month int, @day int;
	declare @m nvarchar(10), @d nvarchar(10);
	declare @lr varchar(6);
	declare @i int, @ii int;
	set @year = left(@date1,4);
	set @lr = right(@date1, len(@date1)-5);
	set @i = charindex('-',@lr);
	set @month = cast(left( @lr, @i-1) as int);
	set @day  = cast(right( @lr, len(@lr) - @i) as int);
	set @m = case @month 
			when 1 then '����'
			when 2 then '����'
			when 3 then '����'
			when 4 then '����'
			when 5 then '����'
			when 6 then '����'
			when 7 then '����'
			when 8 then '����'
			when 9 then '����'
			when 10 then 'ʮ��'
			when 11 then '����'
			when 12 then '����'
			else '?��'
	end
	set @d = case @day
			when 1 then '��һ'
			when 2 then '����'
			when 3 then '����'
			when 4 then '����'
			when 5 then '����'
			when 6 then '����'
			when 7 then '����'
			when 8 then '����'
			when 9 then '����'
			when 10 then '��ʮ'
			when 11 then 'ʮһ'
			when 12 then 'ʮ��'
			when 13 then 'ʮ��'
			when 14 then 'ʮ��'
			when 15 then 'ʮ��'
			when 16 then 'ʮ��'
			when 17 then 'ʮ��'
			when 18 then 'ʮ��'
			when 19 then 'ʮ��'
			when 20 then 'إʮ'
			when 21 then 'إһ'
			when 22 then 'إ��'
			when 23 then 'إ��'
			when 24 then 'إ��'
			when 25 then 'إ��'
			when 26 then 'إ��'
			when 27 then 'إ��'
			when 28 then 'إ��'
			when 29 then 'إ��'
			when 30 then '��ʮ'
			when 31 then '��һ'
			else '?��'
	end
	return  @year + '��' + @m + @d;
end

GO

create function [dbo].[CharLen](@v nvarchar(4000))
returns int
as begin
	return len(isnull(@v,''))
end
GO

--��ȡ������Ʒ������Ӽ�
create FUNCTION [dbo].[GetMenuArea](@Menus VARCHAR(8000),@table VARCHAR(50))  RETURNS VARCHAR(8000)
AS
BEGIN
	DECLARE @menuStr VARCHAR(8000)
	set @menuStr = ''
	if len(@Menus)>0
	begin		
		DECLARE @T Table (id int NULL)
		insert into @T(id) 
		select cast(short_str as int) as id from dbo.split(@Menus,',')
		if(@table='menuarea')	--����Ϊ�����ʱ
		begin
			while exists(
				select 1 from @T a inner join menuarea b on a.id=b.id1
				where  b.id1 > 0 and not exists (
					select 1 from @T x where x.id=b.id1
				)			
			)
			begin
				delete from @T where id in (
					select a.id from @T a inner join menuarea b on a.id=b.id1
					where  b.id1 > 0 and not exists (
						select 1 from @T x where x.id=b.id1
					)				
				) 
			end	
			while exists( 			
				select 1 from @T a inner join menuarea b on a.id=b.id1 
				where not exists (
					select 1 from @T x inner join menuarea y on x.id=y.id and y.id1=a.id
				)
			)
			begin
				insert into @T (id)
				select b.id from @T a inner join menuarea b on a.id=b.id1 
				where not exists (
					select 1 from @T x inner join menuarea y on x.id=y.id and y.id1=a.id
				)
			end	
		end
		if(@table='menu') 	--����Ϊ��Ʒ�����ʱ
		begin
			while exists(
				select 1 from @T a inner join menu b on a.id=b.id
				where  b.id1 > 0 and not exists (
					select 1 from @T x where x.id=b.id1
				)			
			)
			begin
				delete from @T where id in (
					select a.id from @T a inner join menu b on a.id=b.id
					where  b.id1 > 0 and not exists (
						select 1 from @T x where x.id=b.id1
					)				
				) 
			end	
			while exists( 			
				select 1 from @T a inner join menu b on a.id=b.id1 
				where not exists (
					select 1 from @T x inner join menu y on x.id=y.id and y.id1=a.id
				)
			)
			begin
				insert into @T (id)
				select b.id from @T a inner join menu b on a.id=b.id1 
				where not exists (
					select 1 from @T x inner join menu y on x.id=y.id and y.id1=a.id
				)
			end	
		end

		if(@table='email_Person_class') 	--����Ϊ�ʼ������ʱ
		begin
			while exists(
				select 1 from @T a inner join email_Person_class b on a.id=b.id
				where  b.parent > 0 and not exists (
					select 1 from @T x where x.id=b.parent
				)			
			)
			begin
				delete from @T where id in (
					select a.id from @T a inner join email_Person_class b on a.id=b.id
					where  b.parent > 0 and not exists (
						select 1 from @T x where x.id=b.parent
					)				
				) 
			end	
			while exists( 			
				select 1 from @T a inner join email_Person_class b on a.id=b.parent 
				where not exists (
					select 1 from @T x inner join email_Person_class y on x.id=y.id and y.parent=a.id
				)
			)
			begin
				insert into @T (id)
				select b.id from @T a inner join email_Person_class b on a.id=b.parent 
				where not exists (
					select 1 from @T x inner join email_Person_class y on x.id=y.id and y.parent=a.id
				)
			end	
		end		

		if(@table='MessagePersonClass') 	--����Ϊ���ŷ����ʱ
		begin
			while exists(
				select 1 from @T a inner join MessagePersonClass b on a.id=b.id
				where  b.parent > 0 and not exists (
					select 1 from @T x where x.id=b.parent
				)			
			)
			begin
				delete from @T where id in (
					select a.id from @T a inner join MessagePersonClass b on a.id=b.id
					where  b.parent > 0 and not exists (
						select 1 from @T x where x.id=b.parent
					)				
				) 
			end	
			while exists( 			
				select 1 from @T a inner join MessagePersonClass b on a.id=b.parent 
				where not exists (
					select 1 from @T x inner join MessagePersonClass y on x.id=y.id and y.parent=a.id
				)
			)
			begin
				insert into @T (id)
				select b.id from @T a inner join MessagePersonClass b on a.id=b.parent 
				where not exists (
					select 1 from @T x inner join MessagePersonClass y on x.id=y.id and y.parent=a.id
				)
			end	
		end		

		if(@table='orgs_parts')	--����Ϊ���ű�ʱ,���������Ӽ�
		begin
/*			while exists(
				select 1 from @T a inner join orgs_parts b on a.id=b.id
				where  b.pid > 0 and not exists (
					select 1 from @T x where x.id=b.pid
				)			
			)
			begin
				delete from @T where id in (
					select a.id from @T a inner join orgs_parts b on a.id=b.id
					where  b.pid > 0 and not exists (
						select 1 from @T x where x.id=b.pid
					)				
				) 
			end	
			while exists( 			
				select 1 from @T a inner join orgs_parts b on a.id=b.pid 
				where not exists (
					select 1 from @T x inner join orgs_parts y on x.id=y.id and y.pid=a.id
				)
			)
			begin
*/				insert into @T (id)
				select b.id from @T a inner join orgs_parts b on a.id=b.pid 
				where not exists (
					select 1 from @T x inner join orgs_parts y on x.id=y.id and y.pid=a.id
				)
--			end	
		end

	end	
	select @menuStr = isnull(@menuStr + ' ','')+isnull(cast(id as varchar(50)),'') from @T
	set @menuStr = Ltrim(@menuStr)
	set @menuStr = replace(@menuStr,' ',',')				
	RETURN @menuStr
END

GO

--��ȡ�ֿ��ֿ������Ӽ�
create FUNCTION [dbo].GetMenuSorkCk(@ckcls VARCHAR(8000),@cks VARCHAR(8000))  RETURNS VARCHAR(8000)
AS
BEGIN
	DECLARE @menuStr VARCHAR(8000)
	set @menuStr = ''
	if len(@ckcls)>0
	begin		
		DECLARE @T Table (id int NULL)
		insert into @T(id) 
		select cast(short_str as int) as id from dbo.split(@ckcls,',')
			
		while exists(select * from @T a inner join sortck1 b on b.ParentID = a.id  and b.id not in (select id from @T))
		begin 
			insert into @T(id) 
			select b.id from @T a inner join sortck1 b on b.ParentID = a.id  and b.id not in (select id from @T)
		end 
		select @menuStr = isnull(@menuStr + ' ','')+isnull(cast(s.ord as varchar(50)),'') from @T a inner join sortck s on a.id=s.sort
		set @menuStr = Ltrim(@menuStr)
		set @menuStr = replace(@menuStr,' ',',')
	end	
	else
	begin
		set @menuStr = @cks
	end		
	RETURN @menuStr
ENd

GO
--�ۺ�Ͷ��
CREATE function [dbo].[erp_list_shts_fun]
( @uid int , @fromType int, @typ int )
returns table as return(
SELECT a.ID,
	dbo.erp_CreateLink(a.title,1,2001,a.id,a.Creator,@uid,95,14) AS Ͷ������,
	a.bh as Ͷ�߱��,
	(select '<div align=center>'+title+'</div>' from page_sort where ord=a.modeid and del=1) as Ͷ����ʽ,
	(select '<div align=center>'+title+'</div>' from page_sort where ord=a.sortid and del=1) as Ͷ�����,
	'<div align=center>'+(case a.status when 3 then '������' when 4 then '������' else '�������' end )+'</div>' as Ͷ��״̬,
	'<div align=center>'+g.name+'</div>' as �����Ա,
	a.lasttime as �������
	FROM sale_Complaints a
	inner join gate g on g.ord=a.creator
	WHERE (a.del = 0 and @typ =1 AND (@fromType = 0 OR (@fromType = 1 AND a.NextOperator = @uid AND ISNULL(a.alt,0) = 0))) or (@typ = 0 and a.del=1) 
)

GO
--�ۺ���
CREATE function [dbo].[erp_list_shjy_fun]
( @uid int , @typ int,@indate_1 varchar(20),@indate_2 varchar(20),@status varchar(4000),@title varchar(4000),@bh varchar(4000),@content varchar(4000),@creator varchar(4000),@fromType int)
returns  table 
as
return (
	SELECT a.ID,dbo.erp_CreateLink(a.title,1,2002,a.id,a.Creator,@uid,96,14) AS ��������,
	a.bh as ������,
	case when t.del<>1 then '<span style="color:red">���ͻ��ѱ�ɾ����</span>'
	else 
		dbo.erp_CreateLink(
		case when pr.qx_open = 3 or (pr.qx_open=1 and charindex(',' + cast(t.cateid as varchar) + ',',',' + cast(pr.qx_intro as varchar(8000)) + ',') > 0) 
		or t.share='1' or charindex(','+cast(t.cateid as varchar)+',',','+cast(t.share as varchar(8000))+',')>0 
		then t.name 
		else '' 
		end,1,-9,t.ord,t.cateid,@uid,1,14)
	end as �����ͻ�,
	'<div align=center>'+(case a.status when 3 then '������' when 4 then '������' when 5 then '������ϣ��Ѳ��ɣ�' when 6 then '������ϣ������ɣ�' else '�������' end )+'</div>' as ����״̬,
	'<div align=center>'+g.name+'</div>' as ��ǰ������,
	h.name as �����Ա,
	a.indate as ���ʱ��
	FROM sale_proposal a
	left join gate g on g.ord=a.cateid
	inner join gate h on h.ord=a.creator
	left join tel t on t.ord=a.company
	left join (
		select top 1 qx_intro,qx_open from power where ord=@uid and sort1=1 and sort2=1
	) pr on 1=1
	WHERE (
		(
			a.del = 0 and @typ =1 
			AND (
					@fromType = 0 OR (
						@fromType = 1 AND a.cateid = @uid and (a.status=3 or a.status=4) AND ISNULL(a.alt,0) = 0)
					)
			) or (@typ = 0 and a.del=1)
		)
		and (len(@indate_1)=0 or indate>=@indate_1+'')
		and (len(@indate_2)=0 or indate<=@indate_2+'')
		and (len(@status)=0 or charindex(','+cast(status as varchar(10))+',',','+@status+',' )>0)
		and (len(@title)=0 or a.title like '%'+@title+'%')
		and (len(@bh)=0 or bh like '%'+@bh+'%')
		and (len(@content)=0 or content like '%'+@content+'%')
		and (len(@creator)=0 or charindex(','+cast(creator as varchar(10))+',',','+@creator+',' )>0)

)

GO

--��Ч���ͼ�����
create function [dbo].[QCBHNum](@State int, @RecNum decimal(25, 12), @FailNum decimal(25, 12))
returns decimal(25, 12)
as begin
	--��Ч���ͼ�����
	return  @RecNum - (case @State
			when 3 then  @RecNum
			when 4 then  @FailNum
			else 0 end)
end 

GO

--��Ч���ͼ�����
create function [dbo].[QCBHNum2](@State int, @RecNum decimal(25, 12), @FailNum decimal(25, 12),@Result int)
returns decimal(25, 12)
as begin
	--��Ч���ͼ�����
	return  @RecNum - (case @State
			when 3 then  @RecNum
			when 4 then  @FailNum
			when 5 then  @RecNum
			when 6 then  @FailNum
			when 0 then (1-@Result) * @RecNum	
			else 0 end)
end 

GO

--��ȡ���������
create function [dbo].[QCRKNum](
    @State int, 
    @RecNum decimal(25, 12), 
    @FailNum decimal(25, 12),
    @Result int
) returns decimal(25, 12)
as 
begin
    --if @Result = 1 return @RecNum
	--��ȡ���������
	return  @RecNum - (case @State 
			            when 3 then  @RecNum
			            when 4 then  @FailNum
			            when 5 then  @RecNum
			            when 6 then  @FailNum
						when 7 then  @RecNum
			            when 8 then  @FailNum
			            --when 0 then sign(@failNum)*@RecNum
			            else 0 end)
end  

GO

--��ȡ������ID����--�ĵ�����
Create function [dbo].[Fn_XQgenfenlei](@id int)
Returns int
Begin
	declare @num int
	While (select id1 from sortonehy where ord=@id  and id1<>id and id > 0) >0
	Begin
		select @id=id1 from sortonehy where ord=@id  and id1<>id and id > 0
	End
	set @num=@id
	Return @num
end

GO

--�����ƻ���ϸ��������������״̬
create function [dbo].[erp_ManuPlanListStatus](
	@NumDecide money,
	@NumOrdered money
) returns varchar(10)
as
begin
	declare @r as varchar(10)
	if @NumOrdered = 0
	begin
		set @r = 'δ����'
	end
	else
	begin
		if @NumDecide > @NumOrdered
		begin
			set @r = '��������'
		end
		else if @NumDecide = @NumOrdered
		begin
			set @r = 'ȫ������'
		end
		else
		begin
			set @r = '���󣬳�������'
		end
	end
	return @r
end

GO

--��ȡ�����ƻ�������״̬
create function [dbo].[erp_ManuPlanStatus](
	@bill_id int
) returns varchar(20)
as
begin
	declare @r as varchar(30)
	declare @tb table(numDecide decimal(25, 12),numOrdered decimal(25, 12))

	insert into @tb select a.NumDecide,sum(isnull(b.numPlan,0))
	from M_ManuPlanLists a 
	left join M_ManuOrderLists b on a.id = b.planlistId and b.lvw_treenodedeep = 0  and b.del=0
	inner join M_ManuOrders c on c.id = b.MOrderID and c.status<>2 and c.complete<>2 and c.del=0
	where a.MPSID = @bill_ID group by a.id,a.numDecide 

	declare @zeroCnt as int,@totalCnt as int,@cntEq as int
	select @zeroCnt = count(*) from @tb where numOrdered = 0
	select @totalCnt = count(*) from @tb
	select @cntEq = count(*) from @tb where numDecide = numOrdered
	
	set @r = (case when @zeroCnt = @totalCnt then 'δ����'
		when @cntEq = @totalCnt then 'ȫ������'
		else '��������'
		end)

	return @r
end

GO

Create function [dbo].[erp_report_qclistTableFun](
    @open_22_1 INT,
    @intro_22_1  varchar(8000),
    @open_26_1 INT,
    @intro_26_1 varchar(8000),
    @ret varchar(20),
    @ret2 varchar(20),
    @E varchar(2),
    @B varchar(1),
    @C nvarchar(500),
	@qx_open int, @qx_intro varchar(8000)
) returns table as
return
(
	select 
		 (case when @open_22_1=3 
			  or (
				  @open_22_1=1 
				  and CHARINDEX(',' + CAST(c.cateid as varchar(12)) + ',', ',' +cast(@intro_22_1 as varchar(max))+',' )>0 
			  ) 
	    then (case when isnull(c.del,0)=2 then c.title+'<font color=red>����ɾ����</font>' else c.title end) 
        else '' end) as �����ɹ� 
		, isnull(c.ord,0) ord,
		e.title ��Ʒ����, e.order1 ��Ʒ���, e.type1 ��Ʒ�ͺ�, k.sort1 ��λ,
		isnull(d.priceAfterDiscountTax,0) ����, (isnull(d.priceAfterDiscountTax,0)*isnull(a.recnum,0)) �ܼ�,
		(case a.Complete when 0 then '���ʼ�' when 1 then '�ʼ���' when 2 then '������' when 3 then '�ʼ����' end) �ʼ�״̬,
		(case when a.Complete=3 then (case isnull(a.qcResult,'') when '0' then '���ϸ�' when '1' then '�ϸ�' end) else '' end) �ʼ���,
		a.recnum ��������, isnull(a.NumQC,0) �ʼ�����,
		(case isnull(h.num2,0) when 0 then isnull(h.num1,0) else isnull(h.num2,0) end) �������,
		isnull(a.OKNum,0) �ϸ�����, 
		isnull(a.FailNum,0) ���ϸ�����,
		(case when isnull(a.NumQC,0)>0 then isnull(a.OKNum,0)/a.NumQC*100 else 0 end) as �ϸ���,
		(case a.SpResult when 3 then a.recnum when 4 then isnull(a.FailNum,0) when 5 then a.recnum when 6 then isnull(a.FailNum,0) else 0 end) ����,
		n.sort1 as �ʼ췽��,
		a.ph ����,a.xlh ���к�,a.datesc ��������,a.dateyx ��Ч����,a.datedh ��������,a.intro2 ��ע,
		a.zdy1 as p_zdy1,a.zdy2 as p_zdy2,a.zdy3 as p_zdy3,a.zdy4 as p_zdy4,isnull(l.sort1,'') as p_zdy5,isnull(m.sort1,'') as p_zdy6,
		isnull(j.sort1,'') ��װ,
		f.name �ʼ���Ա, a.QCTime �ʼ�ʱ��,
		a.title �����ʼ쵥, a.qcid �ʼ쵥���, 
        (case when @open_26_1=3 
	          or (
		          @open_26_1=1 
		          and CHARINDEX(',' + CAST(g.cateid as varchar(12)) + ',', ',' +cast(@intro_26_1 as varchar(max))+',' )>0 
		        )
        then (case when isnull(g.del,0)=2 then g.name+'<font color=red>����ɾ����</font>' else g.name end)
         else '' end  
        ) ������Ӧ��,
		isnull(e.ord,0) as cpord,
		isnull(a.id,0) as qcord,
		isnull(a.company,0) as company,
		isnull(a.addcate,0) as addcate,
		isnull(c.cateid,0) as cgcate,isnull(g.cateid,0) as telcate,isnull(e.addcate,0) as procate
		,a.date7
		from caigouQC a WITH(NOLOCK) 
		--inner join caigouQClist b WITH(NOLOCK) on b.caigouQC=a.id and 
			left join caigou c WITH(NOLOCK) on a.caigou=c.ord and c.del<>7
			left join caigoulist d WITH(NOLOCK) on a.caigoulist=d.id 
			left join product e WITH(NOLOCK) on a.productid=e.ord 
			left join gate f WITH(NOLOCK) on a.Inspector=f.ord 
			left join tel g WITH(NOLOCK) on a.company=g.ord 
			left join (
				select sum(num1) as num1,sum(num2) as num2,ord,unit,caigouqc from (
					select a.ord,a.unit,d.num1,d.num3 as num2,isnull(isnull(c.id,a.CaigouQC),0) as caigouqc
					from kuinlist a WITH(NOLOCK)
					inner join kuin b on a.kuin = b.ord and b.complete1=3
					left join ku d on d.kuinlist = a.id and a.ord = d.ord and a.unit = d.unit
					left join caigouQClist c on isnull(a.CaigouQCList,0) = c.id
					where a.del=1
					union all
					select a.ord,a.unit,d.num1,d.num1,isnull(isnull(c.id,a.CaigouQC),0) as caigouqc
					from kuinlist a
					inner join kuhclist d WITH(NOLOCK) on d.kuinlist = a.id
					inner join kuin b on a.kuin = b.ord and b.complete1=3
					left join caigouQClist c on isnull(a.CaigouQCList,0) = c.id
				) x group by ord,unit,caigouqc
			) h on h.CaigouQC=a.id and h.ord = a.productid and h.unit = a.unit
			left join sortonehy j WITH(NOLOCK) on j.ord=isnull(a.bz,0)
			left join sortonehy k WITH(NOLOCK) on k.ord=a.unit 
			left join sortonehy l WITH(NOLOCK) on l.ord=a.zdy5 
			left join sortonehy m WITH(NOLOCK) on m.ord=a.zdy6 
			left join sortonehy n WITH(NOLOCK) on n.ord=isnull(a.qc_id,0)
		where a.del=1 and (@qx_open=3 or (@qx_open=1 and CHARINDEX(','+cast(a.addcate as varchar(10))+',',',' + cast(@qx_intro as varchar(2000)) +',')>0)) 
		and (LEN(@ret)=0 or (LEN(@ret)>0 and datediff(dd,a.date1,@ret)<=0)) 
		and (LEN(@ret2)=0 or (LEN(@ret2)>0 and datediff(dd,a.date1,@ret2)>=0))
		and (len(@E)=0 or (len(@E)>0 and ((@E='4' and a.Complete=3 and a.cateid_sp>0) or (@E<>'4' and a.Complete=@E))))
		and (LEN(@C)=0 or (LEN(@C)>0 and ((@B='0' and e.title like '%'+@C+'%') 		--��Ʒ����
									  or ((@B='1' and e.order1 like '%'+@C+'%'))	--��Ʒ���
									  or ((@B='2' and e.type1 like '%'+@C+'%'))		--��Ʒ�ͺ�
									  or ((@B='3' and c.title like '%'+@C+'%'))		--�����ɹ�
									  or ((@B='4' and g.name like '%'+@C+'%'))		--������Ӧ��
									  or ((@B='5' and a.title like '%'+@C+'%'))		--�ʼ�����
									  or ((@B='6' and a.qcid like '%'+@C+'%'))		--�ʼ���
									  or ((@B='7' and a.intro2 like '%'+@C+'%'))	--�ʼ챸ע 
		)))	
)

GO

Create function [dbo].[erp_report_wxslListTableFun](
	@qx_open int, @qx_intro varchar(4000),@sd1 datetime,@sd2 datetime,@jinji int,@jiedai int,@zt1 int,@zt2 int,@searchType int,@searckKey nvarchar(500),@uid int, @open_1_1 int, @intro_1_1 varchar(4000), @open_2_1 int, @intro_2_1 varchar(4000)
	
) returns table as
return
(	
	select a.id,a.title ��������,a.slid �������,		
		ISNULL(t.name,'') �����ͻ�,isnull(p.name,'') ������ϵ��,
		ISNULL(s1.sort1,'') �����̶�, ISNULL(s2.sort1,'') �Ӵ���ʽ,
		(case a.complete2 when 0 then 'δά��' when 1 then 'ά����' when 2 then 'ά�����' end) ά��״̬,
		ISNULL(g.name,'') ������Ա, a.date1 ����ʱ��, 'a' ����,
		ISNULL(t.ord,isnull(t2.ord,0)) khord, a.addcate, 
		ISNULL(s1.color,'') jinji, ISNULL(t.cateid,0) khCateid, 
		ISNULL(p.ord,isnull(p2.ord,0)) lxrOrd, ISNULL(p.cateid,0) lxrCateid, a.date7 ���ʱ��,
		(case when ISNULL(p.ord,0)>0 then a.phone else '' end) �̶��绰, 
		(case when ISNULL(p.ord,0)>0 then a.mobile else '' end) �ֻ�, 
		(case a.complete1 when 0 then 'δ�ɹ�' 
		when 1 then '�����ɹ�' when 2 then '�ɹ����' end) �ɹ�״̬, 
		(case when ISNULL(t.ord,0)>0 then a.address else '' end) �ͻ���ַ, a.intro �����Ҫ,
		z.sort1 ����
	from repair_sl a WITH(NOLOCK)		
		left join tel t WITH(NOLOCK) on a.company=t.ord and t.del=1 and ((@open_1_1 = 3 or (@open_1_1=1 and (charindex(','+cast(t.cateid as varchar(10))+',',','+@intro_1_1+',')>0))) or t.share='1' or (t.share<>'0' and charindex(','+cast(@uid as varchar(10))+',',','+replace(t.share,' ','')+',')>0))
		left join tel t2 WITH(NOLOCK) on a.company=t2.ord and t2.del=1 
		left join person p WITH(NOLOCK) on a.person = p.ord and p.del=1 and ((@open_2_1 = 3 or (@open_2_1=1 and (charindex(','+cast(p.cateid as varchar(10))+',',','+@intro_2_1+',')>0))) or (t.sharecontact=1 and (t.share='1' or (t.share<>'0' and charindex(','+cast(@uid as varchar(10))+',',','+replace(t.share,' ','')+',')>0))))
		left join person p2 WITH(NOLOCK) on a.person = p2.ord and p2.del=1
		left join sortonehy s1 WITH(NOLOCK) on a.jinji=s1.ord and s1.gate2=46
		left join sortonehy s2 WITH(NOLOCK) on a.jiedai=s2.ord and s2.gate2=45
		left join gate g WITH(NOLOCK) on a.cateid = g.ord
		left join sortbz z WITH(NOLOCK) on a.bz = z.id 
	where a.del=1 and (@qx_open=3 or 
		(@qx_open=1 and CHARINDEX(','+cast(a.addcate as varchar(10))+',', ','+ @qx_intro +',')>0))
		and (LEN(@sd1)=0 or (LEN(@sd1)>0 and a.date1>=@sd1))
		and (LEN(@sd2)=0 or (LEN(@sd2)>0 and a.date1<=@sd2))
		and (@jinji=0 or (@jinji>0 and a.jinji=@jinji))
		and (@jiedai=0 or (@jiedai>0 and a.jiedai=@jiedai))
		and (@zt1=0 or (@zt1>0 and a.complete1=(@zt1-1)))
		and (@zt2=0 or (@zt2>0 and a.complete2=(@zt2-1)))
		and (LEN(@searckKey)=0 or (LEN(@searckKey)>0 and (
			(@searchType=0 and a.title like '%'+@searckKey+'%')
			or (@searchType=2 and a.slid like '%'+@searckKey+'%')
			or (@searchType=3 and cast(a.intro as nvarchar(4000)) like '%'+@searckKey+'%')
			or (@searchType=4 and t.name like '%'+@searckKey+'%')
			or (@searchType=5 and p.name like '%'+@searckKey+'%')
			or (@searchType=6 and a.phone like '%'+@searckKey+'%')
			or (@searchType=7 and a.mobile like '%'+@searckKey+'%')
			or (@searchType=8 and a.address like '%'+@searckKey+'%')
			OR (@searchType=20 AND a.id IN (SELECT repair_sl FROM repair_sl_list a LEFT JOIN product b ON b.ord = a.ord WHERE b.title LIKE '%'+@searckKey+'%' ))
			OR (@searchType=21 AND a.id IN (SELECT repair_sl FROM repair_sl_list a LEFT JOIN product b ON b.ord = a.ord WHERE b.order1 LIKE '%'+@searckKey+'%' ))
			OR (@searchType=22 AND a.id IN (SELECT repair_sl FROM repair_sl_list a LEFT JOIN product b ON b.ord = a.ord WHERE b.type1 LIKE '%'+@searckKey+'%' ))
			OR (@searchType=30 AND a.id IN (SELECT repair_sl FROM repair_sl_list a LEFT JOIN product b ON b.ord = a.ord WHERE a.ph LIKE '%'+@searckKey+'%' ))
			OR (@searchType=31 AND a.id IN (SELECT repair_sl FROM repair_sl_list a LEFT JOIN product b ON b.ord = a.ord WHERE a.xlh LIKE '%'+@searckKey+'%' ))
            --OR (@searchType=20 AND a.id IN (SELECT repair_sl FROM repair_sl_list a LEFT JOIN product b ON b.ord = a.ord WHERE b.title LIKE '%'+@searckKey+'%' ))
			OR (@searchType=23 AND a.id IN (SELECT repair_sl FROM repair_sl_list a  WHERE a.guzhang LIKE '%'+@searckKey+'%' ))  
			--or @searchType>=20
		)))
)

GO

Create function [dbo].[erp_CPTitleShow](@ST int, @cpord int, @cptitle nvarchar(50), @cpOrder1 nvarchar(50), @cpType1 nvarchar(50), @zdy1 nvarchar(50), @zdy2 nvarchar(50), @zdy3 nvarchar(50), @zdy4 nvarchar(50), @zdy5 int, @zdy6 int) returns nvarchar(200)
begin	
	--@STΪ������ʾ��Ĳ��������ڸ���������ʾ��Ӧ��ʽ�Ĳ�Ʒ��������
	declare @st2 int
	declare @zdyid int
	
	declare @zdyValue nvarchar(50)
	declare @cpShowStr nvarchar(200)	
	set @cpShowStr = ''
	set @zdyValue = ''
	if @cpord = 0
		set @cpShowStr = '<span style=''color:#ff0000''>��Ʒ�ѱ�ɾ��</span>'
	else if @cpord>0 
	begin 
		if @ST>10 
		begin
			set @zdyid = @ST % 10	
			set @st2 = @ST / 10
		end 
			
		if @zdyid=1
			set @zdyValue = @zdy1
		else if @zdyid=2
			set @zdyValue = @zdy2
		else if @zdyid=3
			set @zdyValue = @zdy3
		else if @zdyid=4
			set @zdyValue = @zdy4
		else if @zdyid=5
			select @zdyValue = sort1 from sortonehy where ord=@zdy5
		else if @zdyid=6
			select @zdyValue = sort1 from sortonehy where ord=@zdy6
		
		if @ST = 1
			set @cpShowStr = @cptitle
		else if @ST = 2
			set @cpShowStr = @cpOrder1
		else if @ST = 3
			set @cpShowStr = @cpType1
		else if @ST = 4
			set @cpShowStr = @cptitle +'('+ isnull(@cpOrder1,'') +')' 
		else if @ST = 5
			set @cpShowStr = @cptitle +'('+ isnull(@cpType1,'') +')' 
		else if @ST = 6
			set @cpShowStr = @cpOrder1+'('+ isnull(@cpType1,'') +')'
		else if @ST > 10
		begin
			if @st2 = 1 		
				set @cpShowStr = @cptitle +'('+ isnull(@zdyValue,'') +')' 	
			if @st2 = 3 		
				set @cpShowStr = @cpOrder1 +'('+ isnull(@zdyValue,'') +')' 	
			if @st2 = 5 		
				set @cpShowStr = @cptitle + '(' + isnull(@cpOrder1,'') + ') , ' +'('+ isnull(@zdyValue,'') +')' 	
			if @st2 = 7 		
				set @cpShowStr = @cptitle + '(' + isnull(@cpType1,'') + ') , ' + '(' + isnull(@zdyValue,'') +')' 	
		end
	end
	return @cpShowStr
end

Go

create function [dbo].[checkPower]
(
@cateid int,
@qx_open int,
@qx_intro ntext
)
returns int
as
begin
	if isnull(@qx_open,0) = 3 or (isnull(@qx_open,0) = 1 and charindex(','+cast(isnull(@cateid,0) as varchar(20))+',',','+replace(isnull(cast(@qx_intro as varchar(8000)),''),' ','')+',') > 0)
		return 1
	return 0
end

GO

create function [dbo].[import_isPersonNamesExists](
	@names as varchar(8000)
) returns int
as
begin
	if @names = '�����û�'
		return 1
	--���������ַ��������ŷָ������������˶����ڣ�����1�����򷵻�0
	if exists(
		select top 1 a.id from dbo.split(@names,',') a 
		left join gate b on a.short_str = b.[name]
		where b.ord is null)
	begin
		return 0
	end
	return 1
end


GO


create function [dbo].[import_getPersonIdsFromNames](
	@names as varchar(8000)
) returns varchar(8000)
as
begin
	declare @r as varchar(8000)
	set @r = ''
	select @r=@r+
	(case when charindex(','+cast(b.ord as varchar)+',',','+@r+',')>0 then
		''
	else
		(case when len(@r)>0 then ',' else '' end) +	cast(b.ord as varchar)
	end)
	 from 
	dbo.split(@names,',') a
	inner join (
		select ord,name from gate 
		union all
		select 0,'�����û�'
	) b on a.short_str = b.name
	return @r
end

GO

create function [dbo].[import_isPersonsAllInPower](
	@ogStr as varchar(8000),
	@tgStr as varchar(8000)
) returns int
as 
begin
	--�ж��ַ���@ogStr�����ŷָ������Ԫ���Ƿ�ȫ��������@tgStr�����ŷָ�����(0Ϊ�������壬�����Ա��ж�)
	if isnull(@tgStr,'-255.355') = '-255.355' --���Ȩ��ֵΪnull����Ϊ����ֵ��ֱ�ӷ���1������Ȩ�޷�Χ��ȫ���������
	begin
		return 1
	end
	
	if exists(
		select * from dbo.split(@ogStr,',') a 
		left join dbo.split(@tgStr,',') b 
		on a.short_str = b.short_str and b.short_str<>'0'
		where b.short_str is null)
	begin
		return 0
	end

	return 1
end

GO

create function [dbo].[import_getInvoiceTypeIdsFromNames](
	@names as varchar(8000)
) returns varchar(8000)
as
begin
	--��Ʊ�����������б�ת��Ϊid�б�
	declare @r as varchar(8000)
	set @r = ''
	set @names = replace(isnull(@names,''),'��',',')
	select @r=@r+
	(case when charindex(','+cast(b.ord as varchar)+',',','+@r+',')>0 then
		''
	else
		(case when len(@r)>0 then ',' else '' end) +	cast(b.ord as varchar)
	end)
	 from 
	dbo.split(@names,',') a
	inner join (
		select ord,sort1 from sortonehy where gate2=34 and isStop=0 and isnull(id1,'-32768')<>'-65535'
	) b on replace(a.short_str,' ','') = replace(b.sort1,' ','')
	return @r
end

GO

create function [dbo].[import_getInvoiceTypeNamesFromids](
	@ids as varchar(8000)
) returns varchar(8000)
as
begin
	--��Ʊ������id�б�ת��Ϊ�����б�
	declare @r as varchar(8000)
	set @r = ''
	select @r=@r+
	(case when charindex(','+b.sort1+',',','+@r+',')>0 then
		''
	else
		(case when len(@r)>0 then ',' else '' end) + b.sort1
	end)
	 from 
	dbo.split(@ids,',') a
	inner join (
		select ord,sort1 from sortonehy where gate2=34 and isStop=0 and isnull(id1,'-32768')<>'-65535'
	) b on a.short_str = b.ord
	return @r
end

GO

create  function [dbo].[import_isInvoiceTypeExists](
	@names as varchar(8000)
) returns int
as
begin
	--����Ʊ�����������ַ��������ŷָ�����������Ʊ�����Ͷ����ڣ�����1�����򷵻�0
	set @names = replace(isnull(@names,''),'��',',')
	if (len(@names)>0 and exists(
		select top 1 a.id from dbo.split(@names,',') a 
		left join sortonehy b on replace(a.short_str,' ','') = replace(b.sort1,' ','') and b.gate2=34 and b.isStop=0 and isnull(b.id1,0)<>-65535
		where b.ord is null)) or (PATINDEX('%,,%',replace(isnull(@names,''),' ',''))>0)
	begin
		return 0
	end
	return 1
end

GO

--Attrs:�����¿���
--��ȡ���ڵ� id or bh or title
create function [dbo].[getTopName](@id int ,@stype int , @rtype int) returns  varchar(4000)
as begin
	--@stype = 0 ���� menu �� @stype=1 ���� menuarea �� @stype=2 ���� [f_AccountSubject] ��
	--@rtype = 0 ֻ�Ǹ��ڵ� @rtype=1 ���и��ڵ� �� '->' ����
	declare @r varchar(4000)
	declare @p int
	if @stype = 0 
	begin
		if exists(select [id] from menu where [id]=@id)
		begin
			select @r = menuname , @p=id1  from menu where [id]=@id
			if @p>0 
			begin
				if @rtype=1  
					set @r = replace(dbo.[getTopName](@p, @stype, @rtype),' ','') + '->' + @r
				else 
					set @r = dbo.[getTopName](@p, @stype, @rtype)
			end 
		end
		else
		begin
			set @r = ''
		end
	end 
	else if @stype = 1
	begin
		if exists(select [id] from menuarea where [id]=@id)
		begin
			select @r = menuname , @p=id1  from menuarea where [id]=@id
			if @p>0 
			begin 
				if @rtype=1  
					set @r = replace(dbo.[getTopName](@p, @stype, @rtype),' ','') + '->' + @r
				else 
					set @r = dbo.[getTopName](@p, @stype, @rtype)
			end 
		end
		else
		begin
			set @r = ''
		end
	end
	else if @stype = 6
	begin
		if exists(select [id] from menuarea where [id]=@id)
		begin
			select @r = id , @p=id1  from menuarea where [id]=@id
			if @p>0 
			begin 
				if @rtype=1  
					set @r = replace(dbo.[getTopName](@p, @stype, @rtype),' ','') + ',' + @r
				else
					set @r = dbo.[getTopName](@p, @stype, @rtype)
			end 
		end
		else
		begin
			set @r = ''
		end
	end	
	else if @stype = 2
	begin 
		if exists(select [ord] from [f_AccountSubject] where [ord]=@id and parentid>0)
		begin
			select @r = bh , @p=parentid  from [f_AccountSubject] where ord=@id
			if @p>0 and exists(select [ord] from [f_AccountSubject] where [ord]=@p and parentid>0)
			begin 
				if @rtype=1  
					set @r = replace(dbo.[getTopName](@p, @stype, @rtype),' ','') + '.' + @r
				else 
					set @r = dbo.[getTopName](@p, @stype, @rtype)
			end 
		end
		else
		begin
			set @r = ''
		end		
	end 
	else if @stype = 3
	begin 
		if exists(select [ord] from [f_AccountSubject] where [ord]=@id and parentid>0)
		begin
			select @r = title , @p=parentid  from [f_AccountSubject] where ord=@id
			if @p>0 and exists(select [ord] from [f_AccountSubject] where [ord]=@p and parentid>0)
			begin 
				if @rtype=1  
					set @r = replace(dbo.[getTopName](@p, @stype, @rtype),' ','') + '-' + @r
				else 
					set @r = dbo.[getTopName](@p, @stype, @rtype)	
			end 
		end
		else
		begin
			set @r = ''
		end		
	end 
	else if @stype = 4
	begin 
		if exists(select [ord] from [f_AccountSubject] where [ord]=@id and parentid>0)
		begin
			select @r = cast(parentid as varchar(300)) , @p=parentid  from [f_AccountSubject] where ord=@id
			if @p>0 and exists(select [ord] from [f_AccountSubject] where [ord]=@p and parentid>0)
			begin 
				if @rtype=1  
					set @r = replace(dbo.[getTopName](@p, @stype, @rtype),' ','') + ',' + @r
				else 
					set @r = dbo.[getTopName](@p, @stype, @rtype)	
			end 
		end
		else
		begin
			set @r = ''
		end		
	end 
	else if @stype = 5
	begin 
		if exists(select [ord] from [f_AccountSubject] where [ord]=@id )
		begin
			select @r = bh , @p=parentid  from [f_AccountSubject] where ord=@id
			if @p>0 and exists(select [ord] from [f_AccountSubject] where [ord]=@p )
			begin 
				if @rtype=1  
					set @r = replace(dbo.[getTopName](@p, @stype, @rtype),' ','') + '.' + @r
				else 
					set @r = dbo.[getTopName](@p, @stype, @rtype)
			end 
		end
		else
		begin
			set @r = ''
		end		
	end
    else if @stype = 7
	begin
		if exists(select [id] from sortonehy where [id]=@id)
		begin
			select @r = sort1 , @p=id1  from sortonehy where [id]=@id
			if @p>0 
			begin 
				if @rtype=1  
					set @r = replace(dbo.[getTopName](@p, @stype, @rtype),' ','') + '->' + @r
				else 
					set @r = dbo.[getTopName](@p, @stype, @rtype)
			end 
		end
		else
		begin
			set @r = ''
		end
	end
	return @r
end

GO

create function [dbo].[getTopOrd](@id int ,@stype int ) returns  int
as begin
	--@stype = 0 ���� menu �� @stype=1 ���� menuarea ��
	declare @r int
	declare @p int
	if @stype = 0 
	begin
		if exists(select [id] from menu where [id]=@id)
		begin
			select @r = id , @p=id1  from menu where [id]=@id
			if @p>0 
			begin
				set @r = dbo.[getTopOrd](@p, @stype)
			end 
		end
		else
		begin
			set @r = @id
		end
	end 
	else if @stype = 1
	begin
		if exists(select [id] from menuarea where [id]=@id)
		begin
			select @r = id , @p=id1  from menuarea where [id]=@id
			if @p>0 
			begin
				set @r = dbo.[getTopOrd](@p, @stype)
			end 
		end
		else
		begin
			set @r = @id
		end
	end
	return @r
end

GO

create function [dbo].[erp_sale_getBackList](
	 @datev datetime, @tel int
)  
returns table 
as return
(	

		--��ȡҪ���յĿͻ���Ϣ
		--������@datev ��ʾ����ʱ��, @tel=��ʾָ���Ŀͻ�
		--�����ֶΣ�ord , backdays, type1, remind, reminddays
		--����ֵ���壺ord=�ͻ�ID, backdays=�൱ǰʱ��Ӧ��������(Ϊ�����ͱ�ʾӦ����)�� type1=��������
		--δ�����Զ����յ�����
		--unautoback: 1=���ܻ��ղ��Կ���, 0=�ܻ��ղ��Կ���  
		--    unback: 1=����״̬�²��ܻ��ղ��Կ���, 0=����״̬���ܻ��ղ��Կ���

		--A.���ܻ��ղ��Կ��ƣ�����Ĭ�ϴ���������Ϊ999999
		select a.ord, 999999 as backdays, 111 as type1, b.canremind, b.reminddays, a.cateid  from tel a  WITH(NOLOCK) inner join sort5 b WITH(NOLOCK) on a.sort1=b.ord and a.del=1 and a.sort3=1 and b.unautoback = 1
		and (@tel=0 or a.ord=@tel)  and isnull(a.sp,0)=0
		--B.�����Զ����գ����ǣ�����״̬�²��ܻ��ղ��Կ��ƣ�ȡ��������Ϊ��ֹ��������
		union all
		select a.ord, datediff(d,@datev,dateadd(d,isnull(c.num2,0),a.datepro)) as backdays, 112 as type1, b.canremind, b.reminddays, a.cateid
		from tel a WITH(NOLOCK) inner join sort5 b WITH(NOLOCK) on a.profect1=1 and a.del=1 and a.sort3=1 and a.sort1=b.ord 
		and (@tel=0 or a.ord=@tel)  and isnull(a.sp,0)=0
		left join num_bh c WITH(NOLOCK) on c.kh=a.sort1 and c.cateid=a.cateid
		--C.δ�����������
		union all
		
		
		----C.1.����δ��ϵ
		select 
			 a.ord, datediff(d,@datev,dateadd(d,d.unback1day,dbo.maxv(e.date7,a.date2))), 1 as  type1, b.canremind, b.reminddays, a.cateid
		 from tel a WITH(NOLOCK)
		 inner join (
			select
				ord,
				isnull(unback,0) as unback,
				isnull(unautoback,0) as unautoback,
				ISNULL(unreplyback1,0) as unreplyback1, 
				canremind, reminddays
			from sort5 WITH(NOLOCK)
		 ) b on a.sort1=b.ord and a.del=1 and a.sort3=1 and  b.unautoback = 0 and (b.unback=0 or isnull(a.profect1,0)=0)
		 and (@tel=0 or a.ord=@tel)  and isnull(a.sp,0)=0
		 and b.unreplyback1>=2
		 inner join (
			select 
			min(isnull(unback1day,999999)) as unback1day,
			sort5, gateord from sort5_gate WITH(NOLOCK)
			group by sort5, gateord 
		 )  d on d.gateord=a.cateid and d.sort5=a.sort1
		 left join (
			--�ο��׶�
			select 
				isnull(max(x.date7),0) as date7,
				x.newSort1,
				x.cateid,
				x.tord
			 from tel_sort_change_log x WITH(NOLOCK) where x.presort1<>x.newSort1 
			 group by x.tord, x.newSort1, x.tord , x.cateid
		 ) e on  e.tord=a.ord and e.newSort1 = a.sort1 and e.cateid= a.cateid
		where  (a.datelast is null or datediff(d,a.datelast,'1900-1-1')=0 or a.datelast<dbo.maxv(e.date7,a.date2)) 
		
		----C.2.���δ��ϵ
		union all
		select 
			a.ord,datediff(d,@datev,dateadd(d,d.unback2day,dbo.maxv(f.date7,dbo.maxv(e.date7,a.date2))))
			, 2 as  type1, b.canremind, b.reminddays, a.cateid
		 from tel a WITH(NOLOCK)
		 inner join (
			select
				ord,
				isnull(unback,0) as unback,
				isnull(unautoback,0) as unautoback,
				ISNULL(unreplyback2, 0) as unreplyback2,
				canremind, reminddays
			from sort5 WITH(NOLOCK)
		 ) b on a.sort1=b.ord and a.del=1 and a.sort3=1  and  b.unautoback = 0 and (b.unback=0 or isnull(a.profect1,0)=0)
		  and (@tel=0 or a.ord=@tel)  and isnull(a.sp,0)=0
		 and b.unreplyback2>=2
		 inner join (
			select 
			min(isnull(unback2day,999999)) as unback2day,
			sort5, gateord from sort5_gate WITH(NOLOCK)
			group by sort5, gateord 
		 )  d on d.gateord=a.cateid and d.sort5=a.sort1
		 left join (
			select isnull(max(date7),0) as date7,gj2 as newSort1,cateid,ord as tord from reply WITH(NOLOCK) group by gj2,cateid,ord
		 ) f on  f.tord=a.ord and f.newSort1 = a.sort1 and f.cateid= a.cateid and f.date7>a.date2
		  left join (
			--�ο��׶�
			select 
				isnull(max(x.date7),0) as date7,
				x.newSort1,
				x.cateid,
				x.tord
			 from tel_sort_change_log x WITH(NOLOCK)
			 where x.reason=5 
			 group by x.tord, x.newSort1, x.tord , x.cateid
		 ) e on  e.tord=a.ord and e.newSort1 = a.sort1 and e.cateid= a.cateid and e.date7>a.date2
		 and not exists(select 1 from tel_sort_change_log tm where tm.tord=e.tord and tm.presort1<>tm.newSort1 and tm.date7>e.date7)
		
		
		----C.3.����δ�ɹ�, ע������������ֻ����sort5_gate�У�������sort5��
		union all
		select 
			a.ord,datediff(d,@datev,dateadd(d,d.salesbackday,isnull(c.date3, case when datediff(d,a.date2,isnull(e.date7,a.date2))>=0 then isnull(e.date7,a.date2) else a.date2 end))), 3 as  type1, b.canremind, b.reminddays, a.cateid
		 from tel a WITH(NOLOCK)
		 inner join (
			select
				ord,
				isnull(unback,0) as unback,
				isnull(unautoback,0) as unautoback,
				ISNULL(unsalesback,0) as unsalesback,
				canremind, reminddays
			from sort5 WITH(NOLOCK)
		 ) b on a.sort1=b.ord and a.del=1 and a.sort3=1  and  b.unautoback = 0 and (b.unback=0 or isnull(a.profect1,0)=0)
		 and (@tel=0 or a.ord=@tel)  and isnull(a.sp,0)=0
		 and unsalesback>=2
		 inner join (
			select 
			min(isnull(salesbackday,999999)) as salesbackday,
			sort5, gateord from sort5_gate WITH(NOLOCK)
			group by sort5, gateord 
		 )  d on d.gateord=a.cateid and d.sort5=a.sort1
		 left join (
			select company,cateid,MAX(date3) date3
			from contract
			where del=1 and (sp=0 or sp is null)
			group by company,cateid
		 ) c on c.company = a.ord and a.cateid = c.cateid and datediff(d,a.date2,c.date3)>=0
		 left join (
		    --�ο��׶�
			select top 1
				isnull(max(x.date7),0) as date7,
				x.newSort1,
				x.cateid,
				x.tord
			 from tel_sort_change_log x WITH(NOLOCK) where x.presort1<>x.newSort1 
			 group by x.tord, x.newSort1, x.tord , x.cateid
			 order by date7 desc
		 ) e on  e.tord=a.ord and e.newSort1 = a.sort1 and e.cateid= a.cateid
	     where c.date3 is null or datediff(d,@datev,dateadd(d,d.salesbackday,isnull(c.date3, case when datediff(d,a.date2,isnull(e.date7,a.date2))>=0 then isnull(e.date7,a.date2) else a.date2 end)))<0
	     
		
		--C.4.���������ջ� 
		union all
		select	
			 a.ord, 
				datediff(d,@datev,
				dateadd(d,(case b.stayback when 2 then b.staydays when 3 then f.staydays else 0 end),
				dbo.maxv(e.date7,a.date2))) --�׶�ͣ������
			, 4 as  type1, b.canremind, b.reminddays, a.cateid
		from tel a WITH(NOLOCK)
		inner join (
		select
			ord,
			isnull(unback,0) as unback,
			isnull(unautoback,0) as unautoback,
			ISNULL(stayback,0) as stayback,
			ISNULL(staydays, 0) as staydays,
			canremind, reminddays
			from sort5 WITH(NOLOCK)
		) b on a.sort1=b.ord and a.del=1 and a.sort3=1  and  b.unautoback = 0 and (b.unback=0 or isnull(a.profect1,0)=0)
		and (@tel=0 or a.ord=@tel)  and isnull(a.sp,0)=0
		and stayback>=2 and isnull(a.cateid,0)>0
		left join (
			--�ο��׶�
			select 
				isnull(max(x.date7),0) as date7,
				x.newSort1,
				x.cateid,
				x.tord
			 from tel_sort_change_log x WITH(NOLOCK) where x.presort1<>x.newSort1 
			 group by x.tord, x.newSort1, x.tord , x.cateid
		 ) e on  e.tord=a.ord and e.newSort1 = a.sort1 and e.cateid= a.cateid
		 left join (
			select 
			min(isnull(staydays,999999)) as staydays,
			sort5, gateord from sort5_gate WITH(NOLOCK)
			group by sort5, gateord 
		 ) f
		 on f.gateord = a.cateid and f.sort5 = b.ord
		 where  not (b.stayback = 3 and f.staydays is null)
		 
		
		--C.5.���ó����ջ� 
		union all
		select 
			a.ord,
			(case when maxback>=2 then
			datediff(d,@datev,dateadd(d,(case b.maxback when 2 then b.maxbackdays when 3 then c.maxbackdays else 0 end),a.date2))
			else 999999
			end), 5 as  [type1], b.canremind, b.reminddays, a.cateid
	
		from tel a WITH(NOLOCK)
		inner join (
			select
				ord,
				isnull(unback,0) as unback,
				isnull(unautoback,0) as unautoback,
				ISNULL(maxback, 0) as maxback,
				ISNULL(maxbackdays,0) as maxbackdays,
				canremind, reminddays
			from sort5 WITH(NOLOCK)
		) b 
		on  a.sort1=b.ord and a.del=1 and a.sort3=1  
			and  b.unautoback = 0 and (b.unback=0 or isnull(a.profect1,0)=0)
			and (@tel=0 or a.ord=@tel)  and isnull(a.sp,0)=0 and isnull(a.cateid,0)>0
		left join (
			select 
			min(isnull(maxbackdays,999999)) as maxbackdays,
			sort5, gateord from sort5_gate WITH(NOLOCK)
			group by sort5, gateord 
		) c 
		on c.gateord = a.cateid and c.sort5 = b.ord
		where  not (b.maxback = 3 and c.maxbackdays is null)
) 
 

GO

create function [dbo].[erp_sale_getBackList_core](
	@datev datetime, @tel int
)
returns table 
as return
(		
	--��coreֻ����Ҫ���յ�
	select ord, cateid,canremind, reminddays , min(backdays) as backdays from dbo.[erp_sale_getBackList](@datev,@tel) a  
	where backdays <> 999999
	group by a.ord, a.cateid, canremind, reminddays	
)

GO

create function [dbo].[erp_sale_getWillReplyList](
	 @datev datetime, @tel int
)  
returns table 
as return
(	
	----��ȡҪ�������Ŀͻ���Ϣ
	----@datev ����ʱ��, @tel ָ���Ŀͻ�id
	--BUG 6839 Sword 2015-1-8 ���۹���̨�е��Ƽ���ϵ��������and b.date7>=a.date2
	select 
		n1.ord,
		n1.cateid,
		n1.sort1,
		n1.ReplyCount,
		n1.lastReply,
		(
			case 
			when DATEADD(d, isnull(n2.[days],n3.days), isnull(n1.lastreply,dayinit)) <  DATEADD(d, n4.[days],n1.dayinit) then   
			DATEADD(d, isnull(n2.[days],n3.days), isnull(n1.lastreply,dayinit))
			else null end
		) as nextReply,
		isnull(n2.[days],n3.days) as nextDays,
		DATEADD(d, n4.[days],n1.dayinit) as EndReplyDate,
		n1.dayinit
	from (
		select x.ord, x.cateid , x.sort1,  isnull(sum(y.del),0) as replycount, (case when MAX(y.date7) is null then x.dayinit else MAX(y.date7) end) as lastreply, x.dayinit from (
			select a.ord, a.cateid, a.sort1, isnull(min(b.date7), a.date2) as dayinit 
			from tel a WITH(NOLOCK)
			inner join sort5 c WITH(NOLOCK) on c.ord=a.sort1 and c.isProtect>0 and c.sort1=a.sort
			left join tel_sort_change_log b WITH(NOLOCK) on  a.ord=b.tord and a.cateid=b.cateid and a.sort = b.newSort and b.preSort<>a.sort1 and b.date7>=a.date2
			where a.del=1 and a.sort3=1 and isnull(a.sp,0)=0 and a.cateid>0 and (@tel=0 or a.ord=@tel)  
			group by a.ord, a.date2, a.cateid, a.sort1
		) x left join reply y WITH(NOLOCK) on x.ord = y.ord and y.sort1<>8 and x.cateid = y.cateid and y.del=1 and datediff(s, dayinit, y.date7)>=0 
		where (@datev is null or datediff(d, dayinit, @datev )>=0)
		group by x.ord,  x.cateid , x.sort1, x.dayinit
	) n1 
	left join sort5list n2 WITH(NOLOCK) on n1.sort1= n2.sort5 and n2.del=1 and n2.gate2=(n1.replycount+1)
	left join sort5list n3 WITH(NOLOCK) on n1.sort1= n3.sort5 and n3.del=1 and n3.gate2=9998
	left join sort5list n4 WITH(NOLOCK) on n1.sort1= n4.sort5 and n4.del=1 and n4.gate2=9999
	where (@datev is null or (DATEADD(d, n4.[days],n1.dayinit) > @datev and DATEADD(D,n3.days,lastreply)<@datev))
)

GO

create  function [dbo].[import_getUnitNamesFromIds](
	@ids as varchar(8000)
) returns varchar(8000)
as
begin
	--����λid�б�ת��Ϊ�����б�
	declare @r as varchar(8000)
	set @r = ''
	select @r=@r+
	(case when charindex(','+b.sort1+',',','+@r+',')>0 then
		''
	else
		(case when len(@r)>0 then ',' else '' end) + b.sort1
	end)
	 from 
	dbo.split(@ids,',') a
	inner join sortonehy b on a.short_str = b.ord
	return @r
end

GO

create  function [dbo].[EvalPower](
	@uid int,
	@powers varchar(1000)
) returns int 
as 
begin
	--Ŀǰ��֧������
	--Ŀǰ��֧������
	declare @r int
	declare @tb1 table(Id int, code varchar(1000))
	declare @tb2 table(Id int, code varchar(1000))
	declare @i int, @ii int, @c1 int, @c2 int, @cv varchar(1000),@cv2 varchar(1000), @v int, @v2 int
	declare @sql nvarchar(1000)
	declare @csstr  nvarchar(1000)
	
	declare @s  nvarchar(1000)
	declare @s1 nvarchar(1000)
	declare @s2 nvarchar(1000)
	declare @a1 int
	declare @a2 int
	
	if len(isnull(@powers,'')) = 0
	begin
		set @r = 1
	end
	else
	begin		
		if isnumeric(@powers)=1
		begin
			set @r=isnull((select 1 from [M_SCTable] where substring(maxv,13,cast(substring(maxv,12,1) as integer))=@powers),0)
		end
		else
		begin
			set @powers = replace(replace(@powers,'Cpower(,',''),')=1','')  --����������ʽ
			set @v = 0
			insert into @tb1 (id, code)
			select id, short_str from dbo.split(@powers,' or ')	
			set @i = 1
			select @c1 = max(id) from @tb1
			while @i <= @c1
			begin
			
				select @cv = code from @tb1 where id = @i
				if isnumeric(@cv) = 1
				begin
					set @v = @v + dbo.EvalPower(@uid,@cv)
				end
				else
				begin

					if charindex(' and ',@cv)=0
					begin
						set @powers = replace(replace(replace(@cv,'Cpower(',''),')=1',''),')','')

						insert into @tb2 (id, code)
						select id, short_str from dbo.split(@powers,',')
						select @a1=cast(code as int) from @tb2 where id=1
						select @a2=cast(code as int) from @tb2 where id=2				
						set @v = @v + [dbo].[existsPower](@uid,@a1,@a2)
					end 
					else
					begin 
			
						insert into @tb2 (id, code)
						select id, short_str from dbo.split(@cv,' and ')	

						set @ii = 1
						select @c2 = max(id) from @tb2
						while @ii <= @c2
						begin
							select @cv2 = code from @tb2 where id = @ii
							if isnumeric(@cv2) = 1
							begin
								set @v = @v * dbo.EvalPower(@uid,@cv2)
							end
							else 
							begin 
								
								if CHARINDEX('(',@cv2)=1 
								begin 
									set @cv2=left(right(@cv2,len(@cv2)-1),LEN(right(@cv2,len(@cv2)-1))-1)
								end
								set @v = @v * dbo.EvalPower(@uid,@cv2) 
							end 
							set @ii = @ii+ 1							
						end 			
					end 
				end
				set @i = @i+1
			end
			set @r = sign(@v)
		end
	end
	return  @r
end

GO

Create function [dbo].[existsPower](@uid int,@sort1 int,@sort2 int)
returns int
as
begin 
	--���ͻ��Ƿ����ĳȨ��, ���ڹر�Ȩ�ޣ����ûѡ���򷵻�1�����򷵻�0
	declare @ret int
	select @ret = isnull((case sort2 when 19 then (case qx_open when 1 then 0 else 1 end) else qx_open end),0) from power where ord=@uid and sort1=@sort1 and sort2=@sort2
	set @ret = isnull(@ret,0)	
	return @ret
end

GO

CREATE function [dbo].[erp_list_shgh_fun]
( @uid int , @ServerTime_1 varchar(20),@ServerTime_2 varchar(20),@modeID varchar(40),@SortID varchar(20),@title varchar(4000),@bh VARCHAR(200),@content varchar(4000),
@feedback varchar(4000),@company varchar(4000),@contract varchar(4000),@person varchar(4000),@cateid varchar(4000))
returns  table 
as
return (
	SELECT a.ID,dbo.erp_CreateLink(a.title,1,2004,a.id,a.Creator,@uid,93,14) AS �ػ�����,
	a.bh as �ػ����,
	case when t.del<>1 then '<span style="color:red">���ͻ��ѱ�ɾ����</span>'
	else 
		dbo.erp_CreateLink(
		case when pr.qx_open = 3 or (pr.qx_open=1 and charindex(',' + cast(t.cateid as varchar) + ',',',' + cast(pr.qx_intro as varchar(8000)) + ',') > 0) 
		or t.share='1' or charindex(','+cast(@uid as varchar)+',',','+cast(t.share as varchar(8000))+',')>0
		then t.name 
		else '' 
		end,1,-9,t.ord,t.cateid,@uid,1,14)
	end �ػ��ͻ�,
	(select sort1 from sortonehy WHERE gate2=59 and ord IN (a.sortid)) as �ػ�����,	
	(select sort1 from sortonehy WHERE gate2=58 and ord IN (a.modeid)) as �ػ���ʽ,
	'<div align=center>'+g.name+'</div>' as ִ����Ա,
	a.ServerTime as �ػ�ʱ��
	FROM sale_care a
	left join gate g on g.ord=a.cateid
	inner join gate h on h.ord=a.creator
	left join tel t on t.ord=a.company
	left join (
		select top 1 qx_intro,qx_open from power where ord=@uid and sort1=1 and sort2=1
	) pr on 1=1
	WHERE (a.del =0 ) 
		and (len(@ServerTime_1)=0 or ServerTime>=@ServerTime_1+'')
		and (len(@ServerTime_2)=0 or ServerTime<=@ServerTime_2+'')
		and (len(@company)=0 or a.company IN (select ord from tel where name LIKE '%'+@company+'%'))
		and (len(@modeID)=0 or charindex(','+cast(modeID as varchar(10))+',',','+@modeID+',' )>0)
		and (len(@SortID)=0 or charindex(','+cast(SortID as varchar(10))+',',','+@SortID+',' )>0)
		and (len(@title)=0 or a.title like '%'+@title+'%')
		and (len(@bh)=0 or bh LIKE '%'+@bh+'%')	
		and (len(@content)=0 or a.content like '%'+@content+'%')
		and (len(@contract)=0 or a.contract in (select ord from [contract] where title LIKE '%'+@contract+'%'))
		and (len(@feedback)=0 or feedback like '%'+@feedback+'%')
		and (len(@cateid)=0 or charindex(','+cast(a.cateid as varchar(10))+',',','+@cateid+',' )>0)
		and (len(@person)=0 or a.person IN (select ord from person where name LIKE '%'+@person+'%'))
)

GO


create function [dbo].[erp_chance_callbackList](@today datetime)
RETURNS @tm TABLE (
	chanceID int,
	cateid int,
	backType int,
	backText nvarchar(20),
	backDays int
)
AS
BEGIN
	declare @existsCls varchar(8000)
	--1����ȡ�����������Ŀ����
	select top 1 @existsCls=replace(cast(setintro as varchar(8000)),' ','') from sortxm_celue with(nolock) where setid=1
	set @existsCls = ',' + ISNULL(@existsCls, '') + ','


	declare  @v1 int, @v2 int, @v3 int
	declare  @o1 int, @o2 int, @o3 int
	--2����ȡ���ò��Բ���, 
	select @o1=cast(intro as int) from setopen  with(nolock) where sort1=3001		--����δ��ϵ0=��������2=��һ��3=���˺�����
	select @o2=cast(intro as int) from setopen  with(nolock) where sort1=3002		
	select @o3=cast(intro as int) from setopen  with(nolock) where sort1=3003

	select top 1 @v1=num1_xm from gate  with(nolock) where del=1 and num1_xm is not null   --��һ����.����δ��ϵ�ջ�����
	select top 1 @v2=num2_xm from gate  with(nolock) where del=1 and num2_xm is not null   --��һ����.���δ��ϵ�ջ�����
	select top 1 @v3=num3_xm from gate  with(nolock) where del=1 and num3_xm is not null   --��һ����.����δ�ɹ��ջ�����
	
	--3����ѯ����
	insert into @tm
	select
	 ord, cateid,
	 cast((abs(����������)-ABS( cast(���������� as int)))*10 as int)  as ��������, 
	 (
		case cast((abs(����������)-ABS( cast(���������� as int)))*10 as int)
		when 1 then '����δ��ϵ'
		when 2 then '���δ��ϵ'
		when 3 then '����δ�ɹ�'
		else '' end
	 ) as ����ԭ��,
	 cast(���������� as int)  as ����������
	from (
		select ord, cateid,  min(����������)  as ���������� from (
			--��ȡ����δ��ϵ
			select 
				a.ord, a.cateid,
				cast(cast(
					datediff(d,@today,isnull(max(c.date7), date5) + (case @o1 when 2 then  @v1 else b.num1_xm end))
					as varchar(12)
				) + '.1' as decimal(25, 12) ) as ���������� 
			from chance a  with(nolock) 
			inner join gate b  with(nolock) on @o1<> 0 and a.cateid>0  and a.del=1 and a.cateid = b.ord
			left join reply c  with(nolock) on a.del=1 and c.ord2 =a.ord and c.sort1=2 and c.del=1
			where c.id is null and CHARINDEX(',' + CAST(complete2 as varchar(12)) + ',', @existsCls) = 0
			group by a.ord, a.date5,  b.num1_xm , a.cateid
			--���δ��ϵ
			union all
			select 
				a.ord, a.cateid,
				cast(
					datediff(d,@today,isnull(max(c.date7), date5) + (case @o2 when 2 then  @v2 else b.num2_xm end))
					as varchar(12)
				) + '.2' as ���������� 
			from chance a  with(nolock) 
			inner join gate b  with(nolock) on @o2<> 0 and a.cateid>0  and a.del=1 and a.cateid = b.ord
			left join reply c  with(nolock) on a.del=1 and c.ord2 =a.ord and c.sort1=2 and c.del=1
			where isnull(c.id,0) >0 and CHARINDEX(',' + CAST(complete2 as varchar(12)) + ',', @existsCls) = 0
			group by a.ord, a.date5,  b.num2_xm , a.cateid
			--����δ�ɹ�
			union all
			select 
				a.ord, a.cateid,
				cast(
					datediff(d,@today,a.date5 + (case @o3 when 2 then  @v3 else b.num3_xm end))
					as varchar(12)
				) + '.3' as ���������� 
			from chance a  with(nolock) 
            inner join gate b with(nolock)  
			on @o3<> 0 and a.cateid>0  and a.del=1 and a.cateid = b.ord and
			not exists(select 1 from contract x  with(nolock) where (x.del=1 or x.del=3) and x.chance=a.ord)
			where  CHARINDEX(',' + CAST(complete2 as varchar(12)) + ',', @existsCls) = 0
			group by a.ord, a.date5,  b.num3_xm , a.cateid
		) t1 group by  ord, cateid
	) t2

	RETURN 
END

GO
--Attrs:�����¿���
create function [dbo].[erp_subjbalance_fun](
	@uid  int,
	@date1 datetime,
	@typ int,
	@subject int,
	@cell int,
	@direction int
)  returns money
as
begin
	declare @date_y varchar(20) --�����һ��
	declare @accountdate1 datetime --��ʼ����
	declare @month1 datetime --�����ڼ� - ��
	select @accountdate1=accountdate1 ,@month1=accountMonth1 from f_account
	if @date1<@accountdate1
	begin 
		set @date1 = @accountdate1 --�����������ڼ��������׳�ʼ����Ĭ���ǳ�ʼ����
	end 
	if @month1<month(@date1) --��������ڼ��� ���ڼ����� �������һ�� = ���� + ����ڼ�����
	begin 
		set @date_y = cast(year(@date1) as varchar(4)) + '-' + cast(@month1 as varchar(2)) + '-1'
	end 
	else --��������ڼ��� ���ڼ����� �������һ�� = ǰһ�� + ����ڼ�����
	begin 
		set @date_y = cast((year(@date1)-1) as varchar(4)) + '-' + cast(@month1 as varchar(2)) + '-1'
	end 

	if cast(@date_y as datetime)< @accountdate1 --����������ڼ�ȡ�� ���< ���׳�ʼ���� �� ������һ�� = ���׳�ʼ����
	begin
		set  @date_y = @accountdate1
	end 
	
	declare @i int 
	set @i = 0 
	--@t �����
	declare @t Table(ord int NOT NULL,parentID int,title nvarchar(200),sk varchar(7000),bh varchar(60),deep int,ChildCount int,balanceDirection int)
	insert into @t
	select ord,parentID,title, 
		cast((case parentID when 0 then cast(right('0000000' + cast(bh as varchar(12)),7) as varchar(8000)) else '' end) as varchar(8000)) as sk,
		cast(bh as varchar(60)) as bh, 0 deep,
		isnull((select count(1) from [f_AccountSubject] where parentID=mm.ord),0) as ChildCount ,balanceDirection
	from [f_AccountSubject] mm 
	--ѭ��
	while exists(select 1 from @t where len(sk)=0 ) and @i < 10 
	begin 
		update y set y.sk = x.sk + ',' + right('0000000' + cast(y.ord as varchar(12)),7), 
					y.deep = x.deep + 1 ,
					y.bh = x.bh + right('0000000' + cast(y.bh as varchar(12)),3) 
			from @t x 
			inner join @t y on x.ord = y.parentID and len(x.sk) > 0 and y.sk = '' 
		set @i = @i + 1 
	end
	--@m �����
	declare @m Table(ord int NOT NULL,sk varchar(7000),b1 int,m1 money,b2 int,m2 money,m3_j money,m3_d money,m4_j money,m4_d money,b5 int,m5 money)

	insert into @m
	select t.ord, t.sk,
			(case when isnull(m3.id,0)>0 then m3.balanceDirection when isnull(m2.id,0)>0 then m2.balanceDirection else 0 end ) as b1,
			(case when isnull(m3.id,0)>0 then m3.money4_b when isnull(m2.id,0)>0 then m2.money4_b else 0 end) as m1 , --������
			(case when isnull(m1.id,0)>0 then m1.balanceDirection when isnull(m2.id,0)>0 then m2.balanceDirection else 0 end ) as b2,
			(case when isnull(m1.id,0)>0 then m1.money4_b when isnull(m2.id,0)>0 then m2.money4_b else 0 end) as m2 , --�ڳ����
			l.money2 as m3_j, l.money3 as m3_d, --���ڷ�����
			j.money2 as m4_j, j.money3 as m4_d, --�����ۼƷ�����
			t.balanceDirection as b5,
			(
			case when t.balanceDirection=(case when isnull(m1.id,0)>0 then m1.balanceDirection 
												when isnull(m2.id,0)>0 then m2.balanceDirection 
												else 0 end )
				then 
					(case when t.balanceDirection=2
						then 
							isnull(l.money3,0)+(case when isnull(m1.id,0)>0 then m1.money4_b when isnull(m2.id,0)>0 then m2.money4_b else 0 end) - isnull(l.money2,0)
						else
							isnull(l.money2,0)+(case when isnull(m1.id,0)>0 then m1.money4_b when isnull(m2.id,0)>0 then m2.money4_b else 0 end) - isnull(l.money3,0)
						end
					)
				else
					(case when t.balanceDirection=2
						then
							isnull(l.money3,0)-(case when isnull(m1.id,0)>0 then m1.money4_b when isnull(m2.id,0)>0 then m2.money4_b else 0 end) - isnull(l.money2,0)
						else 
							isnull(l.money2,0)-(case when isnull(m1.id,0)>0 then m1.money4_b when isnull(m2.id,0)>0 then m2.money4_b else 0 end) - isnull(l.money3,0)
						end
					)	
				end				
			) as m5	--��ĩ���
			from @t t
			left join f_accumulSubject m3 on m3.sort1=1 and m3.accountSubject = t.ord and m3.date1=dateadd(m,-1,@date_y) --���
			left join f_accumulSubject m2 on m2.sort1=0 and m2.accountSubject = t.ord
			left join f_accumulSubject m1 on m1.sort1=1 and m1.accountSubject = t.ord and m1.date1=dateadd(m,-1,@date1)	--�ڳ�
			left join ( 
					select b.[AccountSubject], isnull(sum([money_J]),0) as money2,isnull(sum([money_D]),0) as money3 
					from [f_Voucher] a 
					inner join [f_VoucherList] b on a.[voucherHSmonth]=@date1 and a.del=1 and a.[status]>1 and a.[status]<>4 and b.[Voucher] = a.ord 
					group by  b.[AccountSubject]) l on l.AccountSubject = t.ord --����
			left join ( 
					select b.[AccountSubject], isnull(sum([money_J]),0) as money2,isnull(sum([money_D]),0) as money3 
					from [f_Voucher] a 
					inner join [f_VoucherList] b on a.del=1 and a.[status]>1 and a.[status]<>4 and b.[Voucher] = a.ord 
															and a.[voucherHSmonth]>=@date_y and a.[voucherHSmonth]<=@date1 
					group by  b.[AccountSubject]) j on j.AccountSubject = t.ord --����
			where childcount=0 and deep>0
	--�����
	declare @bMoney Table(ord int NOT NULL,bh varchar(1000),title varchar(2000),b1 varchar(10),m1 money,b2 varchar(10),m2 money,m3_j money,m3_d money,m4_j money,m4_d money,b5 varchar(10),m5 money)
	insert into @bMoney
	select ord,bh,title, 
	b1, (case when len(b1)>0 then isnull(m1,0) else 0 end ) as m1,
	b2, (case when len(b2)>0 then isnull(m2,0) else 0 end ) as m2,
	m3_j,m3_d,m4_j,m4_d,
	(case when b5 ='' then (case when isnull(m5,0)<0 then '��' else '��' end ) else b5 end) as b5, (case when len(b5)>0 then isnull(m5,0) else abs(isnull(m5,0)) end ) as m5
	from 
	(
	select x.ord,dbo.[getTopName](x.ord,2,1) as bh ,x.title, 
		--(case y.b1 when 1 then '��' when 2 then '��' else '' end ) b1,
		(case 
			(case ChildCount 
				when 0 then 
					sum(y.b1) 
				else
					(case sign(isnull(sum((case y.b1 when 1 then 1 when 2 then -1 else 0 end ) * y.m1),0))
					 when 1 then 1 when -1 then 2 else 1 end)
				end )
		when 1 then '��' when 2 then '��' else '' end ) as  b1,
		(case ChildCount 
		when 0 then
			sum(y.m1)
		else 
			abs(isnull(sum((case y.b1 when 1 then 1 when 2 then -1 else 0 end ) * y.m1),0))
		end) as m1,

		--case when y.b1 in (1,2) then isnull(sum(y.m1),0) else null end as m1,
		
		--(case y.b2 when 1 then '��' when 2 then '��' else '' end ) b2,
		(case 
			(case ChildCount 
				when 0 then 
					sum(y.b2) 
				else
					(case sign(isnull(sum((case y.b2 when 1 then 1 when 2 then -1 else 0 end ) * y.m2),0))
					 when 1 then 1 when -1 then 2 else 1 end)
				end )
		when 1 then '��' when 2 then '��' else '' end ) as  b2,
		(case ChildCount 
		when 0 then
			sum(y.m2)
		else 
			abs(isnull(sum((case y.b2 when 1 then 1 when 2 then -1 else 0 end ) * y.m2),0))
		end) as m2,
		--case when y.b2 in (1,2) then isnull(sum(y.m2),0) else null end as m2,
		isnull(sum(y.m3_j),0) as m3_j,
		isnull(sum(y.m3_d),0) as m3_d,
		isnull(sum(y.m4_j),0) as m4_j,
		isnull(sum(y.m4_d),0) as m4_d,
		--(case y.b5 when 1 then '��' when 2 then '��' else '' end ) b5,
		(case 
			(case ChildCount 
				when 0 then 
					sum(y.b5) 
				else
					(case sign(isnull(sum((case y.b5 when 1 then 1 when 2 then -1 else 0 end ) * y.m5),0))
					 when 1 then 1 when -1 then 2 else 1 end)
				end )
		when 1 then '��' when 2 then '��' else '' end ) as  b5,
		(case ChildCount 
		when 0 then
			sum(y.m5)
		else 
			abs(isnull(sum((case y.b5 when 1 then 1 when 2 then -1 else 1 end ) * y.m5),0))
		end) as m5
		--case when y.b5 in (1,2) then isnull(sum(y.m5),0) else null end as m5
	from @t x 
	left join  @m y on  y.sk + ',' like x.sk + ',%'
	where deep>0 and (@typ = 2 or deep=@typ) and (@subject = 0 or x.ord=@subject)
	group  by x.title ,x.sk,x.ord,x.ChildCount --y.b1,y.b2,y.b5
	) k 

	declare @money1 money,@directionStr int
	set @money1 = 0
	if @cell=5 --��ĩ���
	begin 
		select @money1=m5,@directionStr=(case b5 when '��' then 2 else 1 end) from @bMoney	
		if @directionStr<>@direction
		begin  
			set @money1 = @money1*(-1)
		end
	end
	else if @cell=4 --�����ۼƽ��
	begin
		if @direction = 1 
		begin
			select @money1=m4_j from @bMoney	
		end
		else
		begin
			select @money1=m4_d from @bMoney	
		end
	end
	else if @cell=3 --���½��
	begin
		if @direction = 1 
		begin
			select @money1=m3_j from @bMoney	
		end
		else
		begin
			select @money1=m3_d from @bMoney
		end
	end  
	else if @cell=1 --������
	begin
		select @money1=m1,@directionStr=(case b1 when '��' then 2 else 1 end) from @bMoney	
		if @directionStr<>@direction
		begin  
			set @money1 = @money1*(-1)
		end
	end
	else
	begin 
		set @money1 = 0
	end 
	return @money1
end

GO

Create function [dbo].[getShareIntro]
(
	@type int,
	@share varchar(4000)
)
returns nvarchar(4000)
as
begin
	declare @ret nvarchar(4000)
	set @ret = ''
	if @type = 5 --�ۺ���Ա
	begin
		if @share = '0' 
			set @ret = '������Ա'
		else
		begin
			select @ret = @ret +' '+ a.name from gate a 
			inner join (select cast(short_str as int) ord from dbo.split(@share,',')) b
			on a.ord = b.ord
		end
	end
	
	return @ret
end

GO

--ajax�������ս�����˰
Create function [dbo].[HrTaxNzjAjax](@ToalMoney money,@moneyNzj money,@startDate datetime,@endDate datetime)returns money
as
begin
	if @moneyNzj<=0	--δ�ﵽ��˰����
		return 0.0	

	declare @thisMoney  money, @money2 money, @taxRate int, @cut money

	set @money2 = @moneyNzj / 12
	select @taxRate=taxRate, @cut=cut from hr_PersonTax 
	where del=0 and sortid=0 and @money2 between [lower] and [limit]
	--BUG 6533 Sword 2014-12-05 ���ս���˰���㣬������Ϊ��ʱ�����ս���˰��������� 
	set @thisMoney = @moneyNzj  * @taxRate / 100 - @cut
	
	if @thisMoney is null
	begin
	set @thisMoney=0.0
	end

	return @thisMoney

end

GO

Create function [dbo].[erp_chance_proc_models_imgNodes]
(	
	@pmord int
)
RETURNS TABLE 
AS
RETURN 
(
	--�ӽڵ�
	SELECT distinct top 10000 
		a.nextid as id, 
		(case b.mustat when 1 then '�� ' else '' end) + b.name as txt, 
		(case b.mustat when 1 then '�� ' else '' end) + b.name as html,
		cast(b.mustat as varchar(12)) + ',' + cast(b.jdtype as varchar(12)) as  tag, 
		a.nodeid as id1,b.execorder,cast('' as varchar(10)) as color,
		'#e6e6f6' as bgcolor,
		(case b.jdtype when 0 then 'rhomb' else '' end) as gtype 
		FROM ProcNextNodes a inner join dbo.ProcModelsNodes b on a.nextid = b.id and b.chancePMid=@pmord
	
	union all
	
	--���ڵ�	
	SELECT distinct a.nodeid as id, 
		(case b.mustat when 1 then '�� ' else '' end) + b.name as txt,
		(case b.mustat when 1 then '�� ' else '' end) + b.name as html,
		cast(b.mustat as varchar(12)) + ',' + cast(b.jdtype as varchar(12)) as tag ,
		0 as id1,0,
		cast('' as varchar(10)) as color,'#e6e6f6' as bgcolor,
		(case b.jdtype when 0 then 'rhomb' else '' end) as gtype 
	FROM ProcNextNodes a inner join dbo.ProcModelsNodes b 
	on a.nodeid = b.id
	where b.chancePMid=@pmord and a.nodeid not in (select nextid from ProcNextNodes) 
	
	union all
	
	--�޹����ڵ�
	SELECT distinct b.id as id, 
		(case b.mustat when 1 then '�� ' else '' end) + b.name as txt,
		(case b.mustat when 1 then '�� ' else '' end) + b.name as html,
		cast(b.mustat as varchar(12)) + ',' + cast(b.jdtype as varchar(12)) as tag ,
		0 as id1,0,
		cast('' as varchar(10)) as color,'#e6e6f6' as bgcolor,
		(case b.jdtype when 0 then 'rhomb' else '' end) as gtype 
	FROM dbo.ProcModelsNodes b 
	where b.chancePMid=@pmord 
	and b.id not in (select nodeid from ProcNextNodes)
	and b.id not in (select nextid from ProcNextNodes)
)

GO

Create function [dbo].[GetMenuChildrens]
(	
	@id int
)
RETURNS 
@Tmt_Menu TABLE 
(
	----��ȡmenu��ĳһ���ڵ�������ӽڵ�ID
	ord int identity(1,1) not null,
	id int,
	id1 int
)
AS
BEGIN
	insert into @Tmt_Menu (id,id1) select id,id1 from menu where id = @id or id1 = @id
	while exists(select 1 from menu where id1 in (select id from @Tmt_Menu) and id not in (select id from @Tmt_Menu))
	begin
		insert into @Tmt_Menu (id,id1) select id,id1 from menu where id1 in (select id from @Tmt_Menu) and id not in (select id from @Tmt_Menu)
	end
	RETURN 
END

GO

CREATE function [dbo].[Fun_WFPOrderBy]
(@ord int)
RETURNS 
@WFPOrder TABLE 
(
	 
	ord int ,
	oldID int,
	ID int,
	fullids varchar(8000)
)
AS
BEGIN
    declare  @i int=0 
   declare  @count int=0  
   select @count=COUNT(1) from M2_WFP_Assigns where WAID=@ord  
      insert into @WFPOrder (ord,oldID,ID,fullids)  
   select ord,ISNULL(oldID,ID),ID,  
    (case when ID = isnull(oldID,ID) then cast(ID as varchar(20)) 
    else cast(ISNULL(oldID,ID) as varchar(20))+','+cast(ID as varchar(20)) end) fullids  
   from M2_WFP_Assigns   
   where WAID = @ord order by ord  
   while @i <@count 
   and exists(select top 1 1 from @WFPOrder x inner join @WFPOrder y on x.oldID = y.ID and y.ID <> y.oldID 
   and CHARINDEX(y.fullids,x.fullids) <= 0)  
   begin  
    update x set x.fullids = y.fullids+','+cast(x.ID as varchar(20))
    from @WFPOrder x inner join  @WFPOrder y on x.oldID = y.ID and y.ID <> y.oldID   
    and CHARINDEX(y.fullids,x.fullids) <= 0  
    set @i = @i + 1  
   end
	RETURN 
END

GO

Create function [dbo].[GetMenuDeepTh]
(
	@id1 int
)
RETURNS int
AS
BEGIN
	--��ȡmenu��ĳһ�ڵ����ȣ�������ظ�ֵ����Ϊ�������ڵ�����
	declare @deep int
	set @deep = 1
	while exists(select 1 from menu where id = (select id1 from menu where id = @id1)) and @deep < 30
	begin
		select @id1 = id1 from menu where id = @id1
		set @deep = @deep + 1
	end
	if @id1 <> 0
	begin
		set @deep = cast('-' + @deep as int)
	end
	return @deep
END

GO

CREATE FUNCTION [dbo].[GetGoodsAttrVal]
(
	@id INT
)
RETURNS VARCHAR(8000)
AS
BEGIN
	DECLARE @s VARCHAR(8000)
	SET @s= ''
	SELECT @s = @s + '/' + attrVal FROM Shop_GoodsAttrValue WHERE LEN(attrVal) > 0 AND goodsID = @id ;
	RETURN @s
END

GO

CREATE FUNCTION [dbo].[GetGoodsStatus]
(
	@gid INT,
	@t DATETIME
)
RETURNS INT
AS
BEGIN
	DECLARE @result INT
	SELECT @result = (
	CASE 
		WHEN onSale = 2 AND DATEDIFF(s,ISNULL(onSaleAfter,'1970-01-01'),@t) >= 0
		THEN 1
		ELSE
		onSale	
	END	
	) FROM Shop_Goods WHERE ID = @gid

	RETURN @result

END

GO

Create function [dbo].[erp_store_kulist_fun]
(	
	@ydType int,
	@ztType int,
	@showzore int
)
returns @store_kulist table(
	ord int,
	unit int,
	bl decimal(38,12),
	ck int,
	num2 decimal(38,12),
	locknum1 decimal(38,12),
	money1 decimal(38,12),
	AssistNum decimal(38,12),
	AssistUnit int,
	ProductAttr1 int,  
	ProductAttr2 int,
	ydnum decimal(38,12),
	ztnum decimal(38,12)
) 
as
begin
	--�Ƿ���������λ 
	declare @money_dot int   
	select @money_dot = num1 from setjm3 where ord=1

	declare @storelistNow table(rowindex int identity(1,1) ,ord int,unit int,ck int,ProductAttr1 int,ProductAttr2 int,num2 decimal(38,12),locknum1 decimal(38,12),money1 decimal(38,12),AssistNum decimal(38,12),AssistUnit int)

	declare @isOpenAssistUnit int  
	select @isOpenAssistUnit=isnull(nvalue,0) from home_usConfig where name='AssistUnitTactics' and isnull(uid,0)=0  
	if @isOpenAssistUnit=1   
	begin  
		insert into @storelistNow(ord , unit , ck , ProductAttr1, ProductAttr2, num2, locknum1, money1,AssistNum,AssistUnit)
		select ax.ord, ax.unit,isnull(ax.ck,0) as ck, isnull(ax.ProductAttr1,0) as ProductAttr1,isnull(ax.ProductAttr2,0) as ProductAttr2,
				sum(num2 + isnull(locknum,0)) as num2,sum((num2 + isnull(locknum,0))*isnull(locked,0)) as locknum1,
				sum(round(case num1 when 0 then 0 else price1*(num2+isnull(locknum,0)) end,@money_dot)) as money1, 
				sum(case isNull(ax.AssistUnit,0) when 0 then 0 else (isnull(AssistNum,0)/(case when num3=0 then 1 else num3 end) * (num2 + isnull(locknum,0)))end) as AssistNum,isnull(ax.AssistUnit,0) AssistUnit
		from ku ax group by ax.ord, ax.unit, isnull(ax.ck,0),isnull(ax.ProductAttr1,0),isnull(ax.ProductAttr2,0),isnull(ax.AssistUnit,0)
	end  
	else  
	begin  
		insert into @storelistNow(ord , unit , ck , ProductAttr1, ProductAttr2, num2, locknum1, money1,AssistNum,AssistUnit)
		select ax.ord, ax.unit,isnull(ax.ck,0) as ck, isnull(ax.ProductAttr1,0) as ProductAttr1,isnull(ax.ProductAttr2,0) as ProductAttr2,
				sum(num2 + isnull(locknum,0)) as num2,sum((num2 + isnull(locknum,0))*isnull(locked,0)) as locknum1,
				sum(round(case num1 when 0 then 0 else price1*(num2+isnull(locknum,0)) end,@money_dot)) as money1, 
				0 as AssistNum, 0 as AssistUnit
		from ku ax group by ax.ord, ax.unit, isnull(ax.ck,0),isnull(ax.ProductAttr1,0),isnull(ax.ProductAttr2,0)
	end    
	
	--Ԥ��.����δ�����ĳ���
	declare @YD_ZT_TABLE table(ord int,unit int, ProductAttr1 int,ProductAttr2 int,y1 decimal(38,12),y2 decimal(38,12),y3 decimal(38,12),
		z1 decimal(38,12),z2 decimal(38,12),z3 decimal(38,12),
		num2 decimal(38,12),
		locknum1 decimal(38,12),money1 decimal(38,12),AssistNum decimal(38,12),AssistUnit int,ck int)

	insert into @YD_ZT_TABLE
	select  b.ord , b.unit, isnull(b.ProductAttr1,0) ProductAttr1, isnull(b.ProductAttr2,0) ProductAttr2, 
		isnull(SUM(isnull(b.num1,0)),0) as y1, cast(0 as decimal(25,12)) y2 , cast(0 as decimal(25,12)) y3,
		cast(0 as decimal(25,12)) as z1,cast(0 as decimal(25,12)) as z2,cast(0 as decimal(25,12)) as z3,
		cast(0 as decimal(25,12)) num2,cast(0 as decimal(25,12)) locknum1,cast(0 as decimal(25,12)) money1,cast(0 as decimal(25,12)) AssistNum,cast(0 as int) AssistUnit , cast(0 as int) ck
	from kuout a 
	inner join kuoutlist b on  a.del = 1 and a.complete1=1 and (isnull(a.status,-1)=-1 or isnull(a.status,-1)=1) and a.ord = b.kuout and b.del=1 and b.num1 >0
	where @ydType = 1
	group by b.ord , b.unit ,isnull(b.ProductAttr1,0) , isnull(b.ProductAttr2,0)
	union all 	
	--Ԥ��.��ͬδ����
	select a.ord,a.unit,isnull(a.ProductAttr1,0) ProductAttr1,isnull(a.ProductAttr2,0) ProductAttr2, 0 as y1, 
		isnull(sum(isnull(a.num1,0)-isnull(a.num3,0) - ( isnull(a.numth,0)- isnull(a.Kuout_Numth,0))),0) as y2 ,0 y3,0 as z1,0 as z2,0 as z3,
		cast(0 as decimal(25,12)) num2,cast(0 as decimal(25,12)) locknum1,cast(0 as decimal(25,12)) money1,cast(0 as decimal(25,12)) AssistNum,cast(0 as int) AssistUnit , cast(0 as int) ck
	from contractlist a
	inner join contract ht on ht.del=1 and a.contract=ht.ord and isnull(ht.isTerminated,0) = 0 and ISNULL(ht.importKuout,0)=0
	where a.del=1 and isnull(ht.ImportKuout,0)=0 and (@ydType = 2 or @ydType = 4)
	group by a.ord , a.unit ,isnull(a.ProductAttr1,0) , isnull(a.ProductAttr2,0)
	union all
	--Ԥ��.����Ԥ��
	select  xxx.ord, xxx.unit , 0 as ProductAttr1, 0 as ProductAttr2, 0 y1,0 y2, isnull(SUM(isnull(����Ԥ����,0)),0) as y3 ,0 as z1,0 as z2,0 as z3,
		cast(0 as decimal(25,12)) num2,cast(0 as decimal(25,12)) locknum1,cast(0 as decimal(25,12)) money1,cast(0 as decimal(25,12)) AssistNum,cast(0 as int) AssistUnit , cast(0 as int) ck
	from (
		select (a.NumDecide*b.num - isnull(SUM(isnull(i.num1,0)),0)) as ����Ԥ����, b.productID as ord, b.unit
		from  M_ManuOrderlists a
		inner join M_ManuOrders e on e.ID =  a.MOrderID and e.del = 0 and e.[status] =3 and e.Complete=0 and a.role <> 2
		inner join M_PlanBomList c on a.BomListID = c.id
		inner join M_PlanBomList b on  c.planlistID= b.planListId and c.BOMID= b.parentBOMID and b.RankCode < 0
		left join M_WorkAssigns f on f.MOrderID = e.ID
		left join M_WorkAssignLists g on g.BomList = b.ID and g.WAID = f.ID
		left join M_MaterialOrderLists h on h.WAListID = g.ID and h.poType = 0
		left join kuoutlist2 i on i.MOrderID = h.ID  and i.del = 1 and i.sort1 = 3  --(sort1=3,ֻ�������ϳ���)
					and i.ord = b.productID and i.unit = b.unit
		group by a.NumDecide, b. num, b.id , b.productID, b.unit
		union all
		select (a.NumDecide*b.num - isnull(SUM(isnull(i.num1,0)),0)) as ����Ԥ����, b.productID as ord, b.unit
		from  M_ManuOrderlists a
		inner join M_ManuOrders e on e.ID =  a.MOrderID and e.del = 0 and e.[status] =3 and e.Complete=0 and a.role = 2
		inner join M_PlanBomList c on a.BomListID = c.id
		inner join M_PlanBomList b on  c.planlistID= b.planListId and c.BOMID= b.parentBOMID and b.RankCode < 0
		left join M_OutOrder f on f.MOrder = e.ID and f.TempSave = 0
		left join M_OutOrderlists_wl g on g.molist = a.ID and g.outID = f.ID
		left join M_MaterialOrderLists h on h.WAListID = g.ID and h.poType = 1
		left join kuoutlist2 i on i.MOrderID = h.ID  and i.del = 1 and i.sort1 = 3  --(sort1=3,ֻ�������ϳ���)
					and i.ord = b.productID and i.unit = b.unit
		group by a.NumDecide, b. num, b.id , b.productID, b.unit
	) xxx 
	where (@ydType = 3 or @ydType = 4)
	group by  xxx.ord,  xxx.unit
	union all
	--��;.����δ���������
	select b.ord, b.unit,isnull(b.ProductAttr1,0) ProductAttr1,isnull(b.ProductAttr2,0) ProductAttr2, 0 y1,0 y2, 0 y3, isnull(sum(isnull(b.num1,0)-isnull(b.num2,0)),0) as z1 ,0 as z2,0 as z3,
		cast(0 as decimal(25,12)) num2,cast(0 as decimal(25,12)) locknum1,cast(0 as decimal(25,12)) money1,cast(0 as decimal(25,12)) AssistNum,cast(0 as int) AssistUnit , cast(0 as int) ck
	from kuin a
	inner join kuinlist b on a.del=1 and a.ord = b.kuin and b.del=1 and b.num1 > isnull(b.num2,0) and a.complete1 = 1 and isnull(a.status,-1) in (-1,1)
	where  @ztType = 1 
	group by b.ord, b.unit,isnull(b.ProductAttr1,0) , isnull(b.ProductAttr2,0)
	union all 
	--��;.�ɹ�δ���
	select a.ord, a.unit,isnull(a.ProductAttr1,0) ProductAttr1,isnull(a.ProductAttr2,0) ProductAttr2, 0 y1,0 y2, 0 y3, 0 as z1,isnull(sum(isnull(a.num1,0)-isnull(a.num3,0)),0) as z2 ,0 as z3,
		cast(0 as decimal(25,12)) num2,cast(0 as decimal(25,12)) locknum1,cast(0 as decimal(25,12)) money1,cast(0 as decimal(25,12)) AssistNum,cast(0 as int) AssistUnit , cast(0 as int) ck
	from caigoulist a 
	inner join caigou b on a.caigou = b.ord and isnull(b.isstop,0) = 0 and b.del=1
	where a.del=1 and a.num1>a.num3 and ( @ztType =2 or  @ztType = 4)
	group by a.ord, a.unit, isnull(a.ProductAttr1,0) , isnull(a.ProductAttr2,0)
	union all
	--��;.��������
	select t.ord, t.unit,0 ProductAttr1,0 ProductAttr2, 0 y1,0 y2, 0 y3, 0 as z1, 0 as z2, isnull(SUM(isnull(r,0)),0) z3 ,
		cast(0 as decimal(25,12)) num2,cast(0 as decimal(25,12)) locknum1,cast(0 as decimal(25,12)) money1,cast(0 as decimal(25,12)) AssistNum,cast(0 as int) AssistUnit , cast(0 as int) ck
	from (
		select b.ID, b.NumDecide- isnull(SUM(isnull(e.num2,0)),0) as r, b.productID as ord, b.unit  
		from M_ManuOrders a
		inner join M_ManuOrderLists b on a.ID =  b.MOrderID and a.del = 0 and a.Complete = 0 and a.[status] = 3
		left join M_QualityTestings c on a.ID = c.ddno
		left join M_QualityTestingLists d on d.QTID=c.id 
		left join kuinlist e on abs(e.QTLID) = d.ID and e.del=1 and (e.sort1 = 5 or e.sort1 = 13) and e.ord = b.ProductID and e.unit = b.unit and e.num2 > 0
		group by b.ID , b.NumDecide, b.productID, b.unit 
	) t  
	where ( @ztType =3 or  @ztType = 4)
	group by t.ord, t.unit

	declare @ztyd table(RowIndex int , ord int,unit int, ProductAttr1 int,ProductAttr2 int,y1 decimal(38,12),y2 decimal(38,12),y3 decimal(38,12),
		z1 decimal(38,12),z2 decimal(38,12),z3 decimal(38,12)) 

	insert into @ztyd
	select x.RowIndex,y.ord,y.unit,y.ProductAttr1,y.ProductAttr2,
		sum(isnull(y1,0)) y1, 
		sum(isnull(y2,0)) y2, 
		sum(isnull(y3,0)) y3,
		sum(isnull(z1,0)) z1, 
		sum(isnull(z2,0)) z2, 
		sum(isnull(z3,0)) z3
	from @YD_ZT_TABLE y
	left join (
		select ord,unit,ProductAttr1,ProductAttr2 ,min(RowIndex) RowIndex  
		from @storelistNow 
		group by ord,unit,ProductAttr1,ProductAttr2 
	) x on x.ord = y.ord and x.unit = y.unit and x.ProductAttr1 = y.ProductAttr1 and x.ProductAttr2 = y.ProductAttr2
	group by y.ord,y.unit,y.ProductAttr1,y.ProductAttr2, x.RowIndex

	--���������ر��������
	insert into @store_kulist
	select  
		a.ord,
		b.unit,
		b.bl,
		c.ck,
		c.num2 ,
		c.locknum1,
		c.money1,
		c.AssistNum,
		c.AssistUnit,
        c.ProductAttr1,  
        c.ProductAttr2,
		--Ԥ�����
		isnull((case @ydType
		when 1	then y1
		when 2	then y2
		when 3	then y3
		when 4	then isnull(y3,0)+isnull(y2,0)
		else 0 end),0) as ydnum,
		isnull((case @ztType
		when 1	then z1
		when 2	then z2
		when 3	then z3
		when 4	then isnull(z3,0)+isnull(z2,0)
		else 0 end),0) as ztnum
	from product a
	inner join [erp_comm_unitRelation] b on a.ord=b.ord
	left join (
		select x.ord,x.unit,
			x.ProductAttr1, 
			x.ProductAttr2, 
			isnull(y1,0) y1, 
			isnull(y2,0) y2, 
			isnull(y3,0) y3 ,
			isnull(z1,0) z1, 
			isnull(z2,0) z2, 
			isnull(z3,0) z3,
			x.num2,  
			x.locknum1, 
			x.money1, x.AssistNum, x.AssistUnit, x.ck
		from @storelistNow x
		left join @ztyd y  on x.RowIndex = y.RowIndex
		union all

		select ord , unit , ProductAttr1 , ProductAttr2, 
			isnull(y1,0) y1, 
			isnull(y2,0) y2, 
			isnull(y3,0) y3 ,
			isnull(z1,0) z1, 
			isnull(z2,0) z2, 
			isnull(z3,0) z3, 0 num2 ,0 locknum1 , 0 money1,0 AssistNum ,0 AssistUnit , 0 ck
		from @ztyd a
		where RowIndex is null
	) c on a.ord=c.ord and b.unit = c.unit
	where 
	abs(case @showzore 
	when 0 then 
		sign(abs(sign(c.num2))+isnull(abs(sign(c.locknum1)),0) + abs(sign(c.money1))+
		 isnull(abs(sign(case @ydType
			when 1	then y1
			when 2	then y2
			when 3	then y3
			when 4	then isnull(y3,0)+isnull(y2,0)
			else 0 end)),0) +
		isnull(abs(sign(case @ztType
			when 1	then z1
			when 2	then z2
			when 3	then z3
			when 4	then isnull(z3,0)+isnull(z2,0)
			else 0 end)),0)
		)
	when 1 then sign(c.num2)
	when 2 then sign(c.ord)
	else 1 end) =1
	return
end 

GO

create function  [dbo].[KuNumListForAllUnits] 
(	
	@ydType int,
	@ztType int,
	@showzore int
)
returns table 
as  return
(
	select 
		a.ord,
		a.unit as KuUnit,  a.ck, b.unit as baseUnit, d.unit as Unit,
		a.kunum, a.locknum, a.ztnum, a.ydnum,
		b.bl/c.bl as baseUnitbl, (b.bl/c.bl)/d.bl as UnitBl
	from (
		select ord, unit,ck, 
		sum(num2) as kunum, 
		sum(locknum1) as locknum,
		sum(ztnum) as ztnum,
		sum(ydnum) as ydnum
		 from  dbo.[erp_store_kulist_fun](@ydType,@ztType,@showzore)
		group by ord, unit, ck
	) a 
	inner join dbo.erp_comm_unitRelation b on a.ord = b.ord and a.unit = b.unit 
	inner join dbo.erp_comm_unitRelation c on a.ord = c.ord and c.isDefault = 1 
	inner join dbo.erp_comm_unitRelation d on a.ord = d.ord 
) 


GO

CREATE function [dbo].[existsManu]
(
	@orderid int
) 
returns int 
as begin
	return case when exists(select 1 from M_OrderSettings_flows where used = 1 
	and charindex(
		',' + cast(@orderid as varchar) + ',',
		','+MustNodes + ',' + seletedNodes + ',' + (case canyldj when 1 then ',18' else ',0' end) + ','
	)>0) then 1 else 0 end
end

GO

CREATE function [dbo].[existsManuByModels]
(
	@orderid int,
	@models varchar(8000)
) 
returns int 
as begin
	return case when exists(select 1 from M_OrderSettings_flows where used = 1 
	and charindex(
		',' + cast(@orderid as varchar) + ',',
		','+MustNodes + ',' + seletedNodes + ',' + (case canyldj when 1 then ',18' else ',0' end) + ','
	)>0) then 
		case when  
			exists(select 1 from M_ordersettings where id=@orderid and dbo.EvalModel(@models, replace(replace(Modules,'+',' and '),'|',' or '))=1)
		 then 1 
		 else 0
		 end	
	 else 0 
	end
end

GO

CREATE FUNCTION [dbo].[convertGMT](@timestamp VARCHAR(20)) 
RETURNS DATETIME 
AS BEGIN
	DECLARE @newDate DATETIME
	SELECT @newDate = DATEADD(S,@timestamp + 8 * 3600,'1970-01-01 00:00:00') 
	RETURN @newDate
END

GO

create function [dbo].[getAreaFullPath](@areaId as int) returns varchar(8000)
begin
	if isnull(@areaId,0) = 0 return ''
	declare @cnt int,@pid int,@fullPath varchar(8000)
	set @cnt = 0
	set @fullPath = ''
	set @pid = @areaId
	select @cnt = 0,@fullPath = menuname,@pid=id1 from menuarea where id=@areaId
	if @@ROWCOUNT = 0 return ''

	while exists(select top 1 1 from menuarea where id=@pid) and @cnt < 100
	begin
		select @pid = id1,@fullPath = menuname + ' ' + @fullPath from menuarea where id = @pid
	end 

	return @fullPath	
end

GO
create function [dbo].[IsHrAppholiday_recovery]
(
	@billID int
)	returns int
AS
begin
	declare @recovery int
	set @recovery = 1
	if exists(
		select 1 from hr_AppHoliday a 
		inner join hr_AppHoliday b on a.id=@billID
		and b.id <> @billID and  a.creator = b.creator 
		and (a.startTime between b.startTime and b.endTime
		or a.endTime between b.startTime and a.startTime
		or b.startTime between a.startTime and a.endTime
		or b.endTime between a.startTime and a.endTime)
		and (b.status<>2 and b.del=0)
	)
	begin
		set @recovery = 1
	end
	else
	begin
		set @recovery = 0
	end

	return @recovery
end

GO

Create function [dbo].[repair_GetCurrentNodeIsFinish](
	 @repID int, @PID int, @NID int, @BeforeWhere int, @cnt int
)
returns int
as
begin
	declare @IsFinish int, @j int, @count int, @result int
	declare @curID int, @curBeforeWhere int, @IsMust int
	declare @IsDeal int, @DealStatus int
	DECLARE @T2 Table (NodeID int NULL, CurrentNodeType int, BeforeNodeType int, inx int IDENTITY(1,1))
	
	set @j = 0
	set @IsFinish = 0
	set @cnt = @cnt + 1
	
	insert into @T2(NodeID, CurrentNodeType, BeforeNodeType)
	SELECT a.NodeID,b.CurrentNodeType,b.BeforeNodeType FROM Copy_NodesMap a 
	LEFT JOIN Copy_ProcessNodeSet b ON a.NodeID = b.ID AND b.del=1 AND b.RepairOrder=@repID AND b.ProcessSet=@PID 
	WHERE a.del=1 AND a.RepairOrder=@repID AND a.ProcessSet=@PID AND a.NextNodeID =@NID
	
	select @count=max(inx) from @T2
	set @count = isnull(@count,0)
	if @count = 0 
	begin
		set @IsFinish = 1
		return @IsFinish
	end
	else
	begin
		while @j<=@count
		begin
			set @j = @j + 1
			
			select @curID=NodeID,@curBeforeWhere=BeforeNodeType,@IsMust=CurrentNodeType from @T2 where inx=@j
			select @IsDeal=isnull((SELECT top 1 1 FROM RepairDeal WHERE del=1 AND RepairOrder=@repID AND ProcessID=@PID AND NodeID=@curID),0), @DealStatus=isnull((SELECT top 1 CurrentStatus FROM RepairDeal WHERE del=1 AND RepairOrder=@repID AND ProcessID=@PID AND NodeID=@curID),0)
			
			--���д�����ϵ�ǰ�ýڵ� ��ǰ�������ǵ�һ����
			if @DealStatus=1 and @BeforeWhere=2
			begin
				set @IsFinish = 1
				return @IsFinish
			end
			
			--�д����¼ δ������� ��ǰ��������ȫ������
			if @IsDeal=1 and @DealStatus=0 and @BeforeWhere=1
			begin
				set @IsFinish = 0
				return @IsFinish
			end
			
			--û�д����¼
			if @IsDeal = 0
			begin
				set @IsFinish = 0
				If @IsMust = 1
				begin
					set @IsFinish = 0
					return @IsFinish
				end 
				else
				begin				
					if @cnt > 10 
					begin
						set @IsFinish = 0
						return @IsFinish
					end
					else
					begin
						select @result = dbo.repair_GetCurrentNodeIsFinish(@repID,@PID,@curID,@curBeforeWhere,@cnt)
						set @result = isnull(@result,0)
						if @result = 0
						begin
							set @IsFinish = 0
							return @IsFinish
						end
						else
						begin
							if @curBeforeWhere = 2 
							begin
								set @IsFinish = 1
								return @IsFinish
							end
						end	
					end
				end
			end			
		end
		set @IsFinish = 1
		return @IsFinish
	end
	
	delete from @T2
	return @IsFinish
end

GO

Create function [dbo].[repair_GetCurrentNodeList](
	 @uid int, @repID int, @PID int
)
returns varchar(4000) 
as
begin
	declare @str varchar(4000)
	declare @hasData int
	declare @NodeID int, @DealPerson int, @BeforeWhere int
	declare @i int, @count int
	set @str = ''
	set @i = 0
	
	if @PID<=0
		return @str
	
	set @hasData = isnull((SELECT TOP 1 1 FROM RepairDeal WHERE del=1 AND RepairOrder=@repID AND ProcessID=@PID),0)
	if @hasData = 0		--û��ά�޼�¼ ��ȡ���ڵ�  
	begin
		SELECT TOP 1 @NodeID=ID,@DealPerson=(SELECT TOP 1 DealPerson FROM RepairOrder WHERE ID=@repID) 
		FROM Copy_ProcessNodeSet WHERE del=1 AND ProcessSet=@PID AND RepairOrder=@repID
			AND Id NOT IN(SELECT NextNodeID FROM Copy_NodesMap WHERE del=1 AND ProcessSet=@PID AND RepairOrder=@repID)
		if @NodeID>0 and @DealPerson>0
		begin
			if @DealPerson=@uid
			begin
				if charindex(',' + @str + ',' , ','+cast(@NodeID as varchar(12)) + ',') =0
				begin
					set @str = @str + cast(@NodeID as varchar(10))
				end
			end
		end
	end 
	else		--��ά�޼�¼�� �Ҵ���״̬�� ��������
	begin
		declare @IsFinish int
		DECLARE @T Table (NodeID int NULL, Title nvarchar(200), dName nvarchar(200),
			DealPerson int, BeforeNodeType int, inx int IDENTITY(1,1))
			
		insert into @T(NodeID,Title,dName,DealPerson,BeforeNodeType)
		SELECT  a.NodeID,b.Title,c.name dName,a.DealPerson,b.BeforeNodeType FROM RepairDeal a 
		LEFT JOIN Copy_ProcessNodeSet b ON b.ID=a.NodeID AND b.del=1 AND b.ProcessSet=@PID AND b.RepairOrder=@repID	
		LEFT JOIN gate c ON c.ord=a.DealPerson 
		WHERE a.del=1 AND a.CurrentStatus=0 AND a.RepairOrder=@repID AND a.ProcessID=@PID 
		AND CHARINDEX(','+cast(@uid as varchar(10))+',' , ','+CAST(a.DealPerson AS VARCHAR(8000))+',') > 0 
		
		select @count=max(inx) from @T
		set @count = isnull(@count,0)
		while @i<@count
		begin
			set @i = @i + 1
			select @NodeID=NodeID,@BeforeWhere=BeforeNodeType from @T where inx=@i
			select @IsFinish = dbo.repair_GetCurrentNodeIsFinish(@repID,@PID,@NodeID,@BeforeWhere,0)
			set @IsFinish = isnull(@IsFinish,0)
			if @IsFinish = 1 
			begin
				if charindex(',' + @str + ',' , ','+cast(@NodeID as varchar(12)) + ',') =0
				begin
					if len(@str) > 0 
						set @str = @str + ','
					set @str = @str + cast(@NodeID as varchar(10))
				end
			end			
		end
		delete from @T
	end
	return @str
end

GO

Create function [dbo].[repair_GetDealPerson](
	 @stype varchar(10), @repID int
)
returns nvarchar(2000) 
as
begin
	declare @str nvarchar(2000)
	declare @PID int, @hasData int, @count int, @i int
	declare @DealPerson int, @DealPersonName nvarchar(50)
	
	set @str = ''
	
	select @PID=a.ProcessID, @DealPerson=a.DealPerson, @DealPersonName=g.name 
	from RepairOrder a  
	LEFT JOIN gate g ON g.ord = a.DealPerson
	where a.id=@repID
	
	select @PID=isnull(@PID,0), @DealPerson=isnull(@DealPerson,0), @DealPersonName=isnull(@DealPersonName,'')
	
	select @hasData = isnull((SELECT TOP 1 1 FROM RepairDeal WHERE del=1 AND RepairOrder=@repID AND ProcessID=@PID),0)
	
	if @hasData = 0 --û��ά�޼�¼ ��ȡ���ڵ�
	begin
		if @stype = 'id'
			set @str = cast(@DealPerson as varchar(10))
		else
			set @str = @DealPersonName
	end
	else	--��ά�޼�¼�� �Ҵ���״̬�� ��������
	begin
		DECLARE @T Table (DealPerson int NULL, DealPersonName nvarchar(50), inx int IDENTITY(1,1))
		set @i = 0
		
		insert into @T(DealPerson, DealPersonName)
		SELECT c.ord, c.name FROM RepairDeal a 
		LEFT JOIN Copy_ProcessNodeSet b ON b.ID = a.NodeID AND b.del = 1 	
		LEFT JOIN gate c ON c.ord = a.DealPerson 
		WHERE a.del=1 AND a.CurrentStatus=0 AND a.RepairOrder=@repID AND a.ProcessID=@PID		
		GROUP BY c.ord,c.name
		
		select @count=max(inx) from @T
		while @i<@count
		begin
			set @i = @i + 1
			select @DealPerson=DealPerson, @DealPersonName=DealPersonName from @T where inx=@i
			select @DealPerson=isnull(@DealPerson,0), @DealPersonName=isnull(@DealPersonName,'')
			if @stype = 'id'
			begin
				if len(@str) > 0 
					set @str = @str + ','
				set @str = @str + cast(@DealPerson as varchar(10))
			end
			else
			begin
				if len(@str) > 0 
					set @str = @str + ', '
				set @str = @str + @DealPersonName
			end
			
		end
	end
	
	return @str
end 

GO

Create function [dbo].[repair_GetNextNodeList](
	 @repID int, @PID int, @NID int, @str varchar(4000)
)
returns varchar(4000) 
as
begin
	declare @NodeID int, @CurrentNodeType int, @NodeType int
	declare @i int, @count int
	
	set @i = 0
	
	if @PID<=0
		return @str
	
	DECLARE @T Table (NodeID int NULL, CurrentNodeType int, NodeType int, inx int IDENTITY(1,1))
	
	insert into @T(NodeID,CurrentNodeType,NodeType)
	SELECT ID, CurrentNodeType,NodeType FROM Copy_ProcessNodeSet 
	WHERE del = 1 AND RepairOrder=@repID AND ProcessSet=@PID 
	AND Id IN (SELECT NextNodeID FROM Copy_NodesMap WHERE del=1 AND RepairOrder=@repID AND ProcessSet=@PID AND NodeID=@NID) 
		
	select @count=max(inx) from @T
	set @count = isnull(@count,0)
	if @count>0
	begin
		while @i<@count
		begin
			set @i = @i + 1
			select @NodeID=NodeID,@CurrentNodeType=CurrentNodeType,@NodeType=NodeType from @T where inx=@i

			if len(@str) > 0 
				set @str = @str + ','
			set @str = @str + cast(@NodeID as varchar(10))
			
			if @CurrentNodeType = 0 
			begin
				set @str = dbo.repair_GetNextNodeList(@repID,@PID,@NodeID,@str)
			end			
		end
	end
	else
	begin	--û���¼��ڵ�
		delete from @T
		return @str
	end
	return @str
end

GO

Create function [dbo].[repair_GetBeforeNodeList](
	 @repID int, @PID int, @NID int, @str varchar(4000)
)
returns varchar(4000) 
as
begin
	declare @NodeID int, @CurrentNodeType int
	declare @i int, @count int
	
	set @i = 0
	
	if @PID<=0
		return @str
	
	DECLARE @T Table (NodeID int NULL, CurrentNodeType int, inx int IDENTITY(1,1))
	
	insert into @T(NodeID,CurrentNodeType)
	SELECT ID, CurrentNodeType FROM Copy_ProcessNodeSet 
	WHERE del = 1 AND RepairOrder=@repID AND ProcessSet=@PID 
	AND Id IN (SELECT NodeID FROM Copy_NodesMap WHERE del=1 AND RepairOrder=@repID AND ProcessSet=@PID AND NextNodeID=@NID) 
	AND Id IN (SELECT NodeID FROM RepairDeal WHERE del=1 AND CurrentStatus=1 AND RepairOrder=@repID AND ProcessSet=@PID) 
		
	select @count=max(inx) from @T
	set @count = isnull(@count,0)
	if @count>0
	begin
		while @i<@count
		begin
			set @i = @i + 1
			select @NodeID=NodeID,@CurrentNodeType=CurrentNodeType from @T where inx=@i
			if len(@str) > 0 
				set @str = @str + ','
			set @str = @str + cast(@NodeID as varchar(10))
			
			if @CurrentNodeType = 1 
			begin
				delete from @T
				return @str
			end			
		end
		return dbo.repair_GetBeforeNodeList(@repID,@PID,@NodeID,@str)
	end
	else
	begin
		delete from @T
		return @str
	end
	return @str
end


Go

CREATE FUNCTION [dbo].[FUN_SendTempLateData]
(
	@sendord int
)
RETURNS TABLE 
AS
RETURN 
(
    SELECT  st.ord AS ord ,
            st.title AS 'send_zt' , --��������
            st.code AS 'send_dh' , --��������'
            st.date1 AS 'send_yf' ,  --Ӧ��ʱ��
            st.date2 AS 'send_sf' ,  --ʵ��ʱ��
            convert(varchar(10),st.date1,120) AS 'send_yfdate' ,  --Ӧ������
            convert(varchar(10),st.date2,120) AS 'send_sfdate' ,  --ʵ������
            st.date7 AS 'zb_datetj' ,  --���ʱ��
            sth.sort1 AS 'send_fs' ,  --������ʽ
            CASE WHEN st.complete1 = 1 THEN '�ѷ���'
                 ELSE 'δ����'
            END AS 'send_zhaungtai' ,  --����״̬
            st.intro AS 'send_gy' ,  --������Ҫ
            gt.name AS 'send_name' ,  --����������
            gt.ord AS 'send_name_id' ,  --����������ID
            ISNULL(st.date1, st.date7) AS 'signimage_date' ,  --ӡ��ҵ������
            gt.phone1 AS 'send_phone' ,  --�����˵绰
            gt.fax AS 'send_fax' ,  --�����˴���
            gt.mobile AS 'send_mobie' ,  --�������ֻ�
            gt.email AS 'send_email' ,  --�������ʼ�
            gt1.sort1 AS 'send_branch' ,  --�����˲���
            gt2.sort2 AS 'send_team' ,  --������С��
            replace(dbo.TrimHTML(st.intro3),CHAR(13) + CHAR(10),'<br>') AS 'send_method' ,  --���ʽ
            replace(dbo.TrimHTML(st.intro4),CHAR(13) + CHAR(10),'<br>') AS 'send_address' ,  --������ַ
            replace(dbo.TrimHTML(st.intro5),CHAR(13) + CHAR(10),'<br>') AS 'send_type' ,  --������ʽ
            replace(dbo.TrimHTML(st.intro6),CHAR(13) + CHAR(10),'<br>') AS 'send_time' ,  --����ʱ��
            replace(dbo.TrimHTML(st.intro1),CHAR(13) + CHAR(10),'<br>') AS 'send_parts' ,  --���
            replace(dbo.TrimHTML(st.intro2),CHAR(13) + CHAR(10),'<br>') AS 'send_note' ,  --��ע
            st.zdy1 AS 'send_zdy1' ,  --�����Զ���1
            st.zdy2 AS 'send_zdy2' ,  --�����Զ���2
            st.zdy3 AS 'send_zdy3' ,  --�����Զ���3
            st.zdy4 AS 'send_zdy4' ,  --�����Զ���4
            sth1.sort1 AS 'send_zdy5' ,  --�����Զ���5
            sth2.sort1 AS 'send_zdy6' ,  --�����Զ���6
            sth3.sort1 AS 'send_kdgs' ,  --��ݹ�˾
            st.WaybillNumber AS 'send_kddh' ,  --��ݵ���
            st.WayMoney AS 'send_kdfy' ,  --��ݷ���
            contb.title AS 'zb_ht_title' ,  --��ͬ����
            contb.htid AS 'zb_order1' ,  --��ͬ���
            sth4.sort1 AS 'zb_contract_sort' ,  --��ͬ����
            contb.date3 AS 'zb_date1' ,  --ǩ������
			ISNULL(contb.money1,0) AS 'pro_allmoney1',   --�Żݺ��ܶ�
			contb.money1 AS 'pro_cnallmoney1',   --�Żݺ��ܶ��д
            replace(dbo.TrimHTML(contb.intro),CHAR(13) + CHAR(10),'<br>') AS 'zb_intro' ,  --��ͬ��Ҫ
            sth5.sort1 AS 'Invoice_type' ,  --��Ʊ����
            tel.name  AS 'zb_company' ,  --�ͻ�����
            tel.khid  AS 'zb_code' ,  --�ͻ����
            tel.address AS 'zb_address' ,  --�ͻ���ַ
            tel.zip AS 'zb_zip' ,  --�ͻ��ʱ�
            tel.phone AS 'zb_kphone' ,  --�ͻ��绰
            tel.fax AS 'zb_kfax' ,  --�ͻ�����
			tel.email AS 'zb_kemail' ,  --�����ʼ�
            tel.faren AS 'zb_faren' ,  --���˴���
            tel.bank_1 AS 'zb_bank_1' ,  --��������1
            tel.bank_2 AS 'zb_bank_2' ,  --��������1
            tel.bank_3 AS 'zb_bank_3' ,  --�����˺�1
            tel.bank_4 AS 'zb_bank_4' ,  --˰��1
            tel.bank_5 AS 'zb_bank_5' ,  --��ַ1
            tel.bank_6 AS 'zb_bank_6' ,  --�绰1
            tel.bank_7 AS 'zb_bank_7' ,  --�����к�1
            tel.bank2_1 AS 'zb_bank_8' ,  --��������2
            tel.bank2_2 AS 'zb_bank_9' ,  --��������2
            tel.bank2_3 AS 'zb_bank_10' ,  --�����˺�2
            tel.bank2_4 AS 'zb_bank_11' ,  --˰��2
            tel.bank2_5 AS 'zb_bank_12' ,  --��ַ2
            tel.bank2_6 AS 'zb_bank_13' ,  --�绰2
            tel.bank2_7 AS 'zb_bank_14' ,  --�����к�2
            tel.zdy1 AS 'zb_kh_zdy1' ,  --�ͻ��Զ���1
            tel.zdy2 AS 'zb_kh_zdy2' ,  --�ͻ��Զ���2
            tel.zdy3 AS 'zb_kh_zdy3' ,  --�ͻ��Զ���3
            tel.zdy4 AS 'zb_kh_zdy4' ,  --�ͻ��Զ���4
            kh_sth1.sort1 AS 'zb_kh_zdy5' ,  --�ͻ��Զ���5
            kh_sth2.sort1 AS 'zb_kh_zdy6' ,  --�ͻ��Զ���6
            CASE WHEN st.sh = 0 THEN replace(dbo.TrimHTML(zhuyaoperson.name),CHAR(13) + CHAR(10),'')
                 ELSE replace(dbo.TrimHTML(person.name),CHAR(13) + CHAR(10),'')
            END AS 'consignee_name' ,  --�ջ�������
            CASE WHEN st.sh = 0 THEN zhuyaoperson.address
                 ELSE person.address
            END AS 'consignee_address' ,  --�ջ��˵�ַ
            CASE WHEN st.sh = 0 THEN zhuyaoperson.phone
                 ELSE person.phone
            END AS 'consignee_phone' ,  --�ջ��˵绰
            CASE WHEN st.sh = 0 THEN zhuyaoperson.mobile
                 ELSE person.mobile
            END AS 'consignee_mobie' ,  --�ջ����ֻ�
            st.receiver AS 'consignee_name1' ,  --��Ϣ�ջ�������
            st.mobile AS 'consignee_mobie1' ,  --��Ϣ�ջ����ֻ�
            st.phone AS 'consignee_phone1' ,  --��Ϣ�ջ��˵绰
			dbo.getAreaFullPath(st.areaId) AS 'send_area',
            st.address2 AS 'consignee_address1' ,  --��Ϣ�ջ��˵�ַ
            st.zip AS 'consignee_code' ,  --��Ϣ�ջ����ʱ�
            gtxs.name AS 'sales_name' ,  --����������
            gtxs.ord AS 'sales_name_id' ,  --����������ID
            gtxs.phone1 AS 'sales_phone' ,  --�����˵绰
            gtxs.fax AS 'sales_fax' ,  --�����˴���
            gtxs.mobile AS 'sales_mobile' ,  --�������ֻ�
            gtxs.email AS 'sales_email' ,  --�������ʼ�
            gtxs1.sort1 AS 'sales_branch' ,  --�����˲���
            gtxs2.sort2 AS 'sales_team' ,  --������С��
            gtzh.name AS 'person_name' ,  --�˺�������
            gtzh.ord AS 'person_name_id' ,  --�˺�������ID
            gtzh.phone1 AS 'person_phone' ,  --�˺��˵绰
            gtzh.fax AS 'person_fax' ,  --�˺��˴���
            gtzh.mobile AS 'person_mobile' ,  --�˺����ֻ�
            gtzh.email AS 'person_email' ,  --�˺����ʼ�
            gtzh1.sort1 AS 'person_branch' ,  --�˺��˲���
            gtzh2.sort2 AS 'person_team',  --�˺���С��
			contb.ord FromID
    FROM    dbo.send st WITH (NOLOCK)
            LEFT JOIN kuout kout WITH (NOLOCK) ON kout.ord = st.kuout
            LEFT JOIN dbo.gate gt WITH (NOLOCK) ON st.addcate = gt.ord
            LEFT JOIN dbo.sortonehy sth ON st.sort = sth.ord
            LEFT JOIN dbo.sortonehy sth1 ON st.zdy5 = sth1.ord
            LEFT JOIN dbo.sortonehy sth2 ON st.zdy6 = sth2.ord
            LEFT JOIN dbo.sortonehy sth3 ON sth3.gate2 = 83 AND st.ECID = sth3.id
            LEFT JOIN dbo.gate1 gt1 ON gt.sorce = gt1.ord
            LEFT JOIN dbo.gate2 gt2 ON gt.sorce2 = gt2.ord
			left join (
				select order1,send from sendlist 
				where send=@sendord
				group by order1,send
			)sd on sd.send=st.ord
            LEFT JOIN dbo.contract contb ON isnull(sd.order1,st.order1) = contb.ord 
            LEFT JOIN dbo.sortonehy ht_sth1 ON contb.zdy5 = ht_sth1.ord
            LEFT JOIN dbo.sortonehy ht_sth2 ON contb.zdy6 = ht_sth2.ord
            LEFT JOIN dbo.sortonehy sth4 ON sth4.gate2 = 31
                                            AND contb.sort = sth4.ord
            LEFT JOIN dbo.sortonehy sth5 ON sth5.gate2 = 34
                                            AND contb.invoicePlanType = sth5.ord
            LEFT JOIN dbo.gate gtxs ON contb.cateid = gtxs.ord
            LEFT JOIN dbo.gate1 gtxs1 ON gtxs.sorce = gtxs1.ord
            LEFT JOIN dbo.gate2 gtxs2 ON gtxs.sorce2 = gtxs2.ord
            LEFT JOIN dbo.person person ON st.sh = person.ord
            LEFT JOIN dbo.tel tel ON case when st.company = 0 then person.company else st.company end = tel.ord
            LEFT JOIN dbo.sortonehy kh_sth1 ON tel.zdy5 = kh_sth1.ord
            LEFT JOIN dbo.sortonehy kh_sth2 ON tel.zdy6 = kh_sth2.ord
            LEFT JOIN dbo.person zhuyaoperson ON tel.person = zhuyaoperson.ord
            LEFT JOIN gate gtzh ON st.cateid = gtzh.ord
            LEFT JOIN dbo.gate1 gtzh1 ON gtzh.sorce = gtzh1.ord
            LEFT JOIN dbo.gate2 gtzh2 ON gtzh.sorce2 = gtzh2.ord
    WHERE   st.del = 1 AND st.ord=@sendord
)

Go

CREATE FUNCTION [dbo].[FUN_SendTemplateDetailData](@sendord int)
RETURNS TABLE 
AS
RETURN 
(
    SELECT TOP 10000
            sl.id as id ,
			null '#SendToProductDetails#',    
            0 AS 'sortnum' ,
            s.ord ,
            p.ord AS 'productID' ,  --��ƷID
            sur.fpath AS 'pro_img_100' ,  --��ƷͼƬ100px
            sur.fpath AS 'pro_img_200' ,  --��ƷͼƬ200px
            sur.fpath AS 'pro_img_300' ,  --��ƷͼƬ300px
			sur.fpath AS 'pro_img_size' ,  --��ƷͼƬ�Զ���
            p.title AS 'pro_name' ,  --��Ʒ����
            p.order1 AS 'pro_order1' ,  --��Ʒ���
            p.type1 AS 'pro_type' ,  --��Ʒ�ͺ�
            sth1.sort1 AS 'pro_unit' ,  --��Ʒ��λ
            jg1.price1jy AS 'pro_advice' ,  --�������
            jg1.price1 AS 'pro_highest' ,  --��߽���
            sl.ph AS 'pro_ph' ,  --��Ʒ����
            m2.SeriNum AS 'pro_xlh' ,  --��Ʒ���к�
            sl.datesc AS 'pro_datesc' ,  --��������
            sl.dateyx AS 'pro_dateyx' ,  --��Ч����
            p.zdy1 AS 'zb_cp_zdy1' ,  --��Ʒ�Զ���1
            p.zdy2 AS 'zb_cp_zdy2' ,  --��Ʒ�Զ���2
            p.zdy3 AS 'zb_cp_zdy3' ,  --��Ʒ�Զ���3
            p.zdy4 AS 'zb_cp_zdy4' ,  --��Ʒ�Զ���4
            p_sth1.sort1 AS 'zb_cp_zdy5' ,  --��Ʒ�Զ���5
            p_sth2.sort1 AS 'zb_cp_zdy6' ,  --��Ʒ�Զ���6
            p.intro1 AS 'pro_instructions' ,  --��Ʒ˵��
            p.intro2 AS 'pro_parameter' ,  --��Ʒ����
            p.intro3 AS 'pro_accessoryfj' ,  --ͼƬ�븽��
            kot2.zdy1 AS 'zb_xs_zdy1' ,  --��Ʒ��ϸ�Զ���1
            kot2.zdy2 AS 'zb_xs_zdy2' ,  --��Ʒ��ϸ�Զ���2
            kot2.zdy3 AS 'zb_xs_zdy3' ,  --��Ʒ��ϸ�Զ���3
            kot2.zdy4 AS 'zb_xs_zdy4' ,  --��Ʒ��ϸ�Զ���4
            sl_sth1.sort1 AS 'zb_xs_zdy5' ,  --��Ʒ��ϸ�Զ���5
            sl_sth2.sort1 AS 'zb_xs_zdy6' ,  --��Ʒ��ϸ�Զ���6
            sl.price1 AS 'pro_allintro' ,  --��ע
            kot2.date2 AS 'pro_aog' ,  --��������
            cast((case when isnull(sl.js,'')='' then '0' else  sl.js end) as decimal(25,12)) AS 'pro_js' ,  --����
            case when s2.id is null then sl.num1 else 1 end AS 'send_sl' ,  --��������
            skck.sort1 AS 'send_ck' ,  --�ֿ�
            bz_sth.sort1 AS 'pro_bz' , --��װ
            sth.sort1 AS 'Invoice_type' , --��Ʊ����
            ctl.num1 AS 'contract_tno' , --��ͬ����
            ctl.num4 AS 'contract_tno_fsnum' , --��ͬ�ѷ�������
            ctl.num1-ctl.num4-isnull(thl.num1,0) AS 'contract_tno_synum' , --��ͬʣ�෢������
            case when s2.id is null then kot2.num3 else 1 end AS 'send_tno_fs' ,  --�ѷ�������
            case when s2.id is null then kot2.num1 else 1 end AS 'send_tno_ck' , --�ѳ�������
            sl.num1 AS 'send_tno_bc' , --���η�������
            ( kot2.num1 - kot2.num3 ) AS 'send_tno_sy' , --ʣ�෢������
            ctl.discount AS 'pro_zk' , --�ۿ�
            isnull(ctl.price1,0) AS 'pro_price_ws' , --δ˰����
            isnull(ctl.priceAfterDiscount,0) AS 'pro_price_zh' , --δ˰�ۺ󵥼�
            isnull(ctl.priceIncludeTax,0) AS 'pro_price_hs' , --��˰����
			isnull(ctl.PriceAfterTaxPre,0) as 'pro_price_hszh',--��˰�ۺ󵥼�
            (case when (s.order1 = 0 and kt.sort1 = 4) then isnull(kot2.price2,0)
													   else isnull(ctl.priceAfterTax,0) end ) as 'pro_price_newhszh',--�Żݺ󵥼�
            isnull(( ctl.taxRate / 100 ),0) AS 'pro_sl' , --˰��
            case when isnull(ctl.num1,0)>0 then isnull(cast(( ctl.concessions + isnull(( SELECT    smoney
                                  FROM      erp_contract_MnyGainOrLoss
                                  WHERE     contractlist = ctl.id
                                            AND stype = 'yh'
                                ),0) ) * sl.num1 as decimal(25,12)) / ctl.num1,0) else 0 end AS 'pro_favorable' , --�Żݽ��  (ע�� �� ��ͬ����ܶ��ۿۺ��Żݽ�� ��Ҫ���շ�̯���ý��з�̯)
            case when isnull(ctl.num1,0)>0 then isnull(cast(ctl.taxValue * sl.num1 as decimal(25,12)) / ctl.num1,0) else 0 end AS 'pro_tax' , --˰��
            case when isnull(kot2.Num1,0)=0 then 0 else isnull(kot2.FinaMoney,0)/ kot2.Num1 end AS 'pro_price_cb' , --�ɱ�����
            case when isnull(ctl.num1,0)>0 then isnull(ctl.money1 * (case when s2.id is null then sl.num1 else 1 end) / ctl.num1,0) else 0 end AS 'pro_price_zj' , --��Ʒ�ܼ�
            isnull(ctl.price1 * (case when s2.id is null then sl.num1 else 1 end),0) AS 'pro_price_ws1' , --δ˰�ܼ�
            isnull(ctl.priceAfterDiscount * (case when s2.id is null then sl.num1 else 1 end),0) AS 'pro_price_zh1' , --δ˰�ۺ��ܼ�
            isnull(ctl.priceIncludeTax* (case when s2.id is null then sl.num1 else 1 end),0) AS 'pro_price_hs1' , --��˰�ܼ�
            (case when (s.order1 = 0 and kt.sort1 = 4) then isnull(kot2.money2,0)
			else isnull(ctl.money1 * (case when s2.id is null then sl.num1 else 1 end) / ctl.num1,0) end ) as 'pro_price_hszh1',--��˰�ۺ��ܼ�
            case when isnull(kot2.Num1,0)=0 then 0 else (case when s2.id is null then sl.num1 else 1 end) * isnull(kot2.FinaMoney,0)/ kot2.Num1 end   AS 'pro_price_cb1', --    �ɱ��ܼ� 
            cast(isnull(sl.productAttr1,0) as varchar(10)) + '_' + cast(isnull(sl.productAttr2,0) as varchar(10)) productAttr,
            sl.productAttr1,
			sl.productAttr2,
			sl.ProductAttrBatchId,
			isnull(i.title,isnull(ch.title,isnull(jh.title,isnull(ms.title,isnull(ke.title,zz.title)))))	AS 'zb_htmx_title',--��������
			isnull(i.htid,isnull(ch.cgthid,isnull(jh.jhbh,isnull(ms.MOBH,isnull(ke.dbbh,zz.zzid))))) AS 'zb_mx_order',--�������ݱ��
			kt.title  AS 'zb_ck_title',--������������
			kt.ckbh  AS 'zb_ck_order'--����������
    FROM    send s WITH(NOLOCK)
            INNER JOIN dbo.sendlist sl WITH(NOLOCK) ON s.ord = sl.send
            left join S2_SerialNumberRelation s2 with(nolock) on s2.BillType = 68001 and s2.billid = s.ord and s2.ListID = sl.id
			left join M2_SerialNumberList m2 with(nolock) on m2.id = s2.SerialID
            LEFT JOIN dbo.sortck skck WITH(NOLOCK) ON sl.ck = skck.ord            
            LEFT JOIN dbo.sortonehy bz_sth ON sl.bz = bz_sth.ord
            LEFT JOIN dbo.kuoutlist2 kot2 WITH(NOLOCK) ON kot2.id = sl.kuoutlist
            LEFT JOIN dbo.kuout kt with(nolock) on kt.ord = kot2.kuout
            LEFT JOIN dbo.sortonehy sl_sth1 ON kot2.zdy5 = sl_sth1.ord
            LEFT JOIN dbo.sortonehy sl_sth2 ON kot2.zdy6 = sl_sth2.ord
            LEFT JOIN dbo.product p WITH(NOLOCK) ON sl.ord = p.ord
            LEFT JOIN dbo.sortonehy p_sth1 ON p.zdy5 = p_sth1.ord
            LEFT JOIN dbo.sortonehy p_sth2 ON p.zdy6 = p_sth2.ord
            LEFT JOIN gate g ON g.ord = s.cateid
            LEFT JOIN gate1 g1 ON g1.ord = g.sorce
            LEFT JOIN ( SELECT  product ,
                                unit ,
                                bm ,
                                MAX(id) AS jid
                        FROM    jiage
                        GROUP BY product ,
                                unit ,
                                bm
                      ) jg ON jg.product = sl.ord
                              AND jg.unit = sl.unit
                              AND jg.bm = ( CASE ISNULL(g1.num1, 0)
                                              WHEN 1 THEN g.sorce
                                              ELSE 0
                                            END )
            LEFT JOIN dbo.jiage jg1 ON jg1.id = jg.jid
            LEFT JOIN dbo.sys_upload_res sur ON p.ord = sur.id1
                                                AND sur.source = 'productPic'
                                                AND sur.id = ( SELECT TOP 1
                                                              id
                                                              FROM
                                                              sys_upload_res
                                                              WHERE
                                                              p.ord = id1
                                                              AND source = 'productPic'
                                                              ORDER BY id3 ASC
                                                             )
            LEFT JOIN dbo.contractlist ctl WITH(NOLOCK) ON sl.contractlist = ctl.id and ctl.del=1 and ctl.id = kot2.contractlist and kt.sort1 in (1,4)
            LEFT JOIN (
				select contractlist,contract,SUM(num1) num1 
                from contractthlist 
                where del=1 and isnull(contractlist,0)>0 
                group by contractlist,contract
            ) thl on thl.contractlist = ctl.id and ctl.contract = thl.contract
            left join caigouthlist ctlth WITH(NOLOCK) on kot2.sort1=2 and kot2.contractlist = ctlth.id
            left join caigouth ch on ch.ord=ctlth.caigouth--�ɹ��˻�
            LEFT JOIN contract i WITH(NOLOCK) ON i.ord = ctl.contract
            left join Kujh jh on jh.ord=kt.order1 and kt.sort1=6
            left join M2_MaterialOrders ms on ms.ID=KT.Fromid AND kt.sort1=3
            left join Kumove ke on ke.ord=kt.order1 AND kt.sort1=7
            left join Kuzz zz on zz.ord=kt.order1 AND kt.sort1=9
            LEFT JOIN dbo.sortonehy sth ON ctl.invoiceType = sth.ord
                                           AND sth.gate2 = 34
            LEFT JOIN dbo.sortonehy sth1 ON sl.unit = sth1.ord
                                            AND sth1.gate2 = 61
                                         WHERE s.ord= @sendord
    ORDER BY sl.contractlist asc,sl.date7 ASC , 
            sl.id ASC
)

GO

CREATE FUNCTION [dbo].[Erp_comm_JoinUserNames]
    (
      @IDs VARCHAR(8000) ,
      @isName INT
    )
RETURNS VARCHAR(8000)
AS
BEGIN
    DECLARE @returns VARCHAR(8000);
    SET @returns = '';
    IF ( @isName = 1 )
        BEGIN
            SELECT  @returns = @returns + ',' + CONVERT(VARCHAR(500), name)
            FROM    gate
            WHERE   CHARINDEX(',' + CONVERT(VARCHAR(50), ord) + ',',
                                ',' + @IDs + ',', 0) > 0;
        END; 
    ELSE
        BEGIN
            SELECT  @returns = @returns + ',' + CONVERT(VARCHAR(10), ord)
            FROM    gate
            WHERE   CHARINDEX(',' + CONVERT(VARCHAR(50), ord) + ',',
                                ',' + @IDs + ',', 0) > 0;
        END;
    RETURN STUFF(@returns, 1, 1, '');
END

GO

CREATE FUNCTION [dbo].[F_HrKQ_ApplyJoinApprover]
    (
      @Approver VARCHAR(8000) ,
      @isName INT
    )
RETURNS VARCHAR(8000)
AS
BEGIN
    RETURN dbo.[Erp_comm_JoinUserNames](@Approver,@isName)
END

GO

CREATE FUNCTION [dbo].[FUN_KuoutTemplateData](@kuord int)
RETURNS TABLE 
AS
RETURN 
(
    SELECT  kt.ord ,
            kt.title AS 'zb_ck_title' ,   --��������
            kt.ckbh AS 'zb_ckbh' ,   --������
            gtkg.name AS 'zb_kgperson' ,   --������
            gtkg.name AS 'zb_kgperson_signet' ,   --������(ǩ��)
            gtkg.ord AS 'zb_kgperson_signet_SignImageUserId' ,   --������ID
            kt.date5 AS 'zb_kgperson_signet_SignImageDate' ,   --������ҵ������
            convert(varchar(10),kt.date3,120) AS 'zb_apdate',--��������
            kt.date3 AS 'zb_sqdate' ,   --����ʱ��
            gtcate.name AS 'zb_sqperson' ,   --������
            gtcate.name AS 'zb_sqperson_signet' ,   --������(ǩ��)
            gtcate.ord AS 'zb_sqperson_signet_SignImageUserId' ,   --������ID
            kt.date3 AS 'zb_sqperson_signet_SignImageDate' ,
            (case when kt.complete1=3 then  '�ѳ���' when kt.complete1=2 then  '�������' when kt.status=1 then '����ͨ��' when  kt.status=3 then '���ύ����' when kt.status=2 then '�����˻�'  when kt.status=4 then '������' when kt.status=5 then '������' when kt.status=2 then '�����˻�'  when kt.status=4 then '������' when kt.status=0 then '����δͨ�� ' else '��������' end) AS 'zb_state' ,   --����״̬
            CASE kt.sort1
				WHEN 1 THEN '���۳���'
				WHEN 2 THEN '�ɹ��˻�����'
				WHEN 3 THEN '���ϳ���'
				WHEN 4 THEN 'ֱ�ӳ���'
				WHEN 5 THEN '���ϳ���'
				WHEN 12 THEN '���ϳ���'
				WHEN 6 THEN '�������'
				WHEN 7 THEN '��������'
				WHEN 8 THEN '�̵����'
				WHEN 9 THEN '��װ����'
				WHEN 10 THEN '��ֳ���'
				ELSE NULL
            END AS 'zb_outcategory' ,   --�������
			Convert(varchar(10), kt.date5,120) as zb_qrdate, -- ȷ������
            kt.date5 AS 'zb_spdate' ,   --ȷ��ʱ��
            gtcateout.name AS 'zb_spperson' ,   --������
            gtcateout.ord AS 'zb_spperson_id' ,   --������ID
			dbo.F_HrKQ_ApplyJoinApprover(ap.SurplusApprover,1) cur_person,--��ǰ������
			spgt.name AS last_person, --���������
			spgt.ord AS last_person_id, --���������id
            kt.intro2 AS 'zb_spintro' ,   --�������
            kt.intro AS 'zb_ck_intro' ,   --�����Ҫ
            kt.zdy1 AS 'zb_zdy1' ,   --�����Զ���1
            kt.zdy2 AS 'zb_zdy2' ,   --�����Զ���2
            kt.zdy3 AS 'zb_zdy3' ,   --�����Զ���3
            kt.zdy4 AS 'zb_zdy4' ,   --�����Զ���4
            sth.sort1 AS 'zb_zdy5' ,   --�����Զ���5
            sth1.sort1 AS 'zb_zdy6' ,   --�����Զ���6
            ct.title AS 'zb_ht_title' ,   --��ͬ����
            ct.htid AS 'zb_order1' ,   --��ͬ���
            ct.htid AS 'Bar_code_zb_order1' ,   --��ͬ���һά����
            sth2.sort1 AS 'zb_contract_sort' ,   --��ͬ����
            ct.date3 AS 'zb_date1' ,   --ǩ������
            ct.date1 AS 'zb_contract_stardate' ,   --��ʼ����
            ct.date2 AS 'zb_contract_enddate' ,   --��ֹ����
            ct.person2 AS 'zb_dfperson' ,   --�Է�����
            ct.intro AS 'zb_ht_intro' ,   --��ͬ��Ҫ
            ct.zdy1 AS 'zb_ht_zdy1' ,   --��ͬ�Զ���1
            ct.zdy2 AS 'zb_ht_zdy2' ,   --��ͬ�Զ���2
            ct.zdy3 AS 'zb_ht_zdy3' ,   --��ͬ�Զ���3
            ct.zdy4 AS 'zb_ht_zdy4' ,   --��ͬ�Զ���4
            ct_sth1.sort1 AS 'zb_ht_zdy5' ,   --��ͬ�Զ���5
            ct_sth2.sort1 AS 'zb_ht_zdy6' ,  --��ͬ�Զ���6
            CASE WHEN kt.sort1 = 2 THEN supplier.name
                 ELSE tel.name
            END AS 'zb_company' ,   --�ͻ�����
            CASE WHEN kt.sort1 = 2 THEN supplier.khid
                 ELSE tel.khid
            END AS 'zb_code' ,   --�ͻ����
            CASE WHEN kt.sort1 = 2 THEN supplier.address
                 ELSE tel.address
            END AS 'zb_address' ,   --�ͻ���ַ
            CASE WHEN kt.sort1 = 2 THEN supplier.phone
                 ELSE tel.phone
            END AS 'zb_kphone' ,   --�ͻ��绰
            CASE WHEN kt.sort1 = 2 THEN stel.mobile
                 ELSE ptel.mobile
            END AS 'zb_sjphone' ,   --�ͻ��ֻ�
            gtxs.name AS 'sales_name' ,  --����������
            gtxs.name AS 'sales_name_signet' ,  --����������
            gtxs.ord AS 'sales_name_signet_SignImageUserId' ,  --����������ID
            kt.date3 AS 'sales_name_signet_SignImageDate' ,
            gtxs.phone1 AS 'sales_phone' ,  --�����˵绰
            gtxs.fax AS 'sales_fax' ,  --�����˴���
            gtxs.mobile AS 'sales_mobile' ,  --�������ֻ�
            gtxs.email AS 'sales_email' ,  --�������ʼ�
            gtxs2.Name AS 'sales_branch' ,  --�����˲���  
            gtxs1.Name AS 'sales_team' ,  --������С��  
			case when mmo.OrderType = 1 or mmo2.MaterialType = 1 or mmo2.MaterialType = 2 
				then ISNULL(mmo.title,mmo2.title)
				else '' end  'picking_title' ,   --���ϵ�����
			case when mmo.OrderType = 1 or mmo2.MaterialType = 1 or mmo2.MaterialType = 2 
				then ISNULL(mmo.MOBH,mmo2.MOBH)
				else '' end  'picking_order' ,   --���ϵ���
			case when mmo.OrderType = 1 or mmo2.MaterialType = 1 or mmo2.MaterialType = 2 
				then ISNULL(mwa.title, MM.waTITLE ) 
				else '' end 'tasking_title_ll' ,   --���������ɹ���
			case when mmo.OrderType = 1 or mmo2.MaterialType = 1 or mmo2.MaterialType = 2 
				then ISNULL(pro.title, MM.PTITLE) 
				else '' end 'tasking_pro_ll' ,   --�����ɹ���Ʒ
			case when mmo.OrderType = 1 or mmo2.MaterialType = 1 or mmo2.MaterialType = 2 
				then ISNULL(sth3.sort1, MM.unit) 
				else '' end 'tasking_unit_ll' ,   --���ϲ�Ʒ��λ
			case when mmo.OrderType = 1 or mmo2.MaterialType = 1 or mmo2.MaterialType = 2 
				then ISNULL(mmorder.MOBH, MM.MOBH) 
				else '' end 'indent_order_ll' ,   --���϶������    
            case when (mmo.OrderType = 1 or mmo2.MaterialType = 1 or mmo2.MaterialType = 2) then
				(CASE WHEN isnull(kt.fromid,0)=0 THEN   
					(CASE WHEN  mmo.OrderType= 1 
					THEN ( 
						CASE mmo.poType 
						WHEN 0 THEN '�����ɹ�'
						WHEN 1 THEN 'ί��ӹ�'
						ELSE NULL 
					END )  ELSE ''  END )
				WHEN isnull(kt.fromid,0)>1 
					THEN '�����ɹ�' 
				ELSE '' END) 
			else '' end AS 'picking_type' ,   --��������
			case when mmo.OrderType = 1 or mmo2.MaterialType = 1 or mmo2.MaterialType = 2 
				then isnull(mmolist.number, MM.num)
				else NULL end 'picking_amount' ,   --��������
			case when mmo.OrderType = 1 or mmo2.MaterialType = 1 or mmo2.MaterialType = 2 
				then ISNULL(mmo.intro, mmo2.intro)
				else '' end 'picking_note' ,   --���ϵ���ע 
            CASE WHEN mmo.OrderType = 2 or mmo2.MaterialType = 3 THEN
				ISNULL(mmo.title,mmo2.title)
				ELSE ''
				END AS 'feeding_title' ,  --���ϵ�����
            CASE WHEN mmo.OrderType = 2 or mmo2.MaterialType = 3 THEN
				ISNULL(mmo.MOBH,mmo2.MOBH)
				ELSE ''
				END AS 'feeding_order' ,  --���ϵ���
            CASE WHEN mmo.OrderType = 2 or mmo2.MaterialType = 3 THEN
				ISNULL(mwa.title, MM.waTITLE ) 
				ELSE ''
				END AS 'tasking_title_bl' ,  --���������ɹ���
            CASE WHEN mmo.OrderType = 2 or mmo2.MaterialType = 3 THEN
				ISNULL(pro.title, MM.PTITLE) 
				ELSE ''
				END AS 'tasking_pro_bl' ,  --�����ɹ���Ʒ
            CASE WHEN mmo.OrderType = 2 or mmo2.MaterialType = 3 THEN
				ISNULL(sth3.sort1, MM.unit)
				ELSE ''
				END AS 'tasking_unit_bl' ,  --���ϲ�Ʒ��λ
            CASE WHEN mmo.OrderType = 2 or mmo2.MaterialType = 3 THEN
				ISNULL(mmorder.MOBH, MM.MOBH) 
				ELSE ''
				END AS 'indent_order_bl' ,  --���϶������
            CASE WHEN mmo.OrderType = 2 or mmo2.MaterialType = 3 THEN
				(CASE WHEN isnull(kt.fromid,0)=0 THEN   
					(CASE WHEN  mmo.OrderType= 1 
					THEN ( 
						CASE mmo.poType 
						WHEN 0 THEN '�����ɹ�'
						WHEN 1 THEN 'ί��ӹ�'
						ELSE NULL 
					END )  ELSE ''  END )
				WHEN isnull(kt.fromid,0)>1 
					THEN '�����ɹ�' 
				ELSE '' END) 
			ELSE '' END AS 'feeding_type' ,  --��������
            CASE WHEN mmo.OrderType = 2 or mmo2.MaterialType = 3 THEN
				ISNULL(mmolist.number, MM.num)
				ELSE NULL
				END AS 'feeding_amount' ,  --��������
            CASE WHEN mmo.OrderType = 2 or mmo2.MaterialType = 3 THEN
				ISNULL(mmo.intro, mmo2.intro)
				ELSE ''
				END AS 'feeding_note' ,  --���ϵ���ע
            cgt.title AS 'zb_cg_title' ,  --�˻�����
            cgt.cgthid AS 'zb_cg_bh' ,  --�˻����
            cgt.date7 AS 'zb_cg_date7' ,  --����ʱ��
            cgt.money1 AS 'zb_cg_money' ,  --�˻����
            cgt.date3 AS 'zb_cg_date1',  --�˻�����
            CASE WHEN kt.sort1 in (1,4) THEN kt.receiver ELSE '' END AS 'consignee_name1',  --�ջ���
            CASE WHEN kt.sort1 in (1,4) THEN kt.phone ELSE '' END AS 'consignee_phone1',  --�̶��绰
            CASE WHEN kt.sort1 in (1,4) THEN kt.mobile ELSE '' END AS 'consignee_mobie1',  --�ֻ�
            CASE WHEN kt.sort1 in (1,4) THEN dbo.getAreaFullPath(kt.areaId) ELSE '' END AS 'consignee_area',  --��������
            CASE WHEN kt.sort1 in (1,4) THEN kt.address ELSE '' END AS 'consignee_address1',  --��ϸ��ַ
            CASE WHEN kt.sort1 in (1,4) THEN kt.zip ELSE '' END AS 'consignee_code',  --�ʱ�
            (case kt.sort1 when 1 then co.intro3 when 4 then co.intro3  when 2 then ca.intro3 end)AS 'pro_fkfs',--���ʽ  
            (case kt.sort1 when 1 then co.intro4 when 4 then co.intro4  when 2 then ca.intro4 end)AS 'pro_jhdz',--������ַ  
            (case kt.sort1 when 1 then co.intro5 when 4 then co.intro5	when 2 then ca.intro5 end)AS 'pro_jhfs',--������ʽ  
            (case kt.sort1 when 1 then co.intro6 when 4 then co.intro6  when 2 then ca.intro6 end)AS 'pro_jhsj',--����ʱ��  
            (case kt.sort1 when 1 then co.intro1 when 4 then co.intro1	when 2 then ca.intro1 end)AS 'pro_pj',--���  
            (case kt.sort1 when 1 then co.intro2 when 4 then co.intro2	when 2 then ca.intro2 end)AS 'pro_beizhu'--��ע  
    FROM   (select * from kuout where ord =@kuord) kt
			LEFT JOIN (select * from dbo.[erp_comm_BillApproveInfo](62001) where ord=@kuord) ap ON kt.ord = ap.ord
			LEFT JOIN dbo.gate spgt ON ap.cateid = spgt.ord
            LEFT JOIN contractbz co ON co.contract=kt.order1  
			LEFT JOIN caigouthbz ca ON ca.caigouth=kt.order1  
            LEFT JOIN dbo.gate gtkg ON kt.kg = gtkg.ord
            LEFT JOIN dbo.gate gtcate ON kt.cateid = gtcate.ord
            LEFT JOIN dbo.gate gtcateout ON kt.cateout = gtcateout.ord
            LEFT JOIN dbo.sortonehy sth ON kt.zdy5 = sth.ord
                                           AND sth.gate2 = 4501
            LEFT JOIN dbo.sortonehy sth1 ON kt.zdy6 = sth1.ord
                                            AND sth1.gate2 = 4502
            LEFT JOIN dbo.contract ct ON  kt.sort1 IN(1,4) AND kt.order1 = ct.ord
            LEFT JOIN dbo.sortonehy ct_sth1 ON ct.zdy5 = ct_sth1.ord
            LEFT JOIN dbo.sortonehy ct_sth2 ON ct.zdy6 = ct_sth2.ord
            LEFT JOIN dbo.sortonehy sth2 ON ct.sort = sth2.ord
                                            AND sth2.gate2 = 31
            LEFT JOIN tel tel ON ISNULL(ct.company,(SELECT TOP 1 ISNULL(ko.company,ko2.company) company FROM kuoutlist ko LEFT join kuoutlist2 ko2 ON  ko2.kuoutlist = ko.id and ko2.kuout = kt.ord WHERE ko.kuout = kt.ord and ko.kuout=@kuord) )  = tel.ord
                                 --AND tel.sort3 = 1
            LEFT JOIN dbo.person ptel ON tel.person = ptel.ord
            LEFT JOIN caigouth cgt ON kt.sort1=2 AND kt.order1 = cgt.ord
            LEFT JOIN tel supplier ON cgt.company = supplier.ord
            LEFT JOIN dbo.person stel ON supplier.person = stel.ord
            LEFT JOIN dbo.gate gtxs ON ct.cateid = gtxs.ord
            LEFT JOIN dbo.orgs_parts gtxs1 ON gtxs1.ID = gtxs.orgsid  
            LEFT JOIN dbo.orgs_parts gtxs2 ON gtxs1.PID = gtxs2.ID  
            LEFT JOIN M_MaterialOrders mmo ON  kt.sort1 IN (3,12) AND kt.[source]= mmo.ID --AND mmo.OrderType = 1 ���� 2 ����
            LEFT JOIN M2_MaterialOrders mmo2 ON  kt.sort1 IN (3,12) AND   isnull(kt.fromid,0)=mmo2.ID  --AND mmo.OrderType = 1 ���� 2 ����
            LEFT JOIN   
            (  
                SELECT K.*, s.sort1 as unit,wa.TITLE waTITLE, mo.MOBH , P.TITLE PTITLE   
                FROM (  
                    SELECT mmo2.ID, sum(a.num1) as num  ,  MAX(a.ListID ) AS ListID  
                    FROM M2_MaterialOrderLists A  
                    inner JOIN M2_MaterialOrders mmo2 ON mmo2.ID=A.MOID 
                    group by mmo2.ID,mmo2.title, mmo2.MOBH   
                )K  
                LEFT JOIN M2_WorkAssignLists wal  ON wal.ID=K.ListID   
                left join M2_WorkAssigns wa on wa.ID=wal.WAID  
                LEFT JOIN M2_ManuOrders mo ON mo.ID=wa.MOrderID  
                LEFT JOIN Product P ON P.ORD=wa.ProductID  
                left join sortonehy s  on s.ord=wa.unit   
            ) MM on MM.ID=mmo2.ID  
            LEFT JOIN M_WorkAssigns mwa ON mmo.WAID = mwa.ID
            LEFT JOIN dbo.product pro ON mwa.ProductID = pro.ord
            LEFT JOIN dbo.sortonehy sth3 ON mwa.unit = sth3.ord
            LEFT JOIN M_ManuOrders mmorder ON mmo.ddno = mmorder.ID
            LEFT JOIN ( SELECT  MOID ,
                                SUM(num1) AS number
                        FROM    M_MaterialOrderLists
                        GROUP BY MOID
                      ) mmolist ON mmo.ID = mmolist.MOID
)


GO

create FUNCTION [dbo].[FUN_KuoutTemplateDetailData](@kuord int)  
RETURNS TABLE   
AS  
RETURN   
(  
    SELECT TOP 10000
        0 AS 'sortnum' ,
        null '#KuoutToProductDetails#',  
        isnull(kotl.id,kot2.kuoutlist) as id ,  
        p.ord AS 'productID' ,  --��ƷID  
        sur.fpath AS 'pro_img_100' ,  --��ƷͼƬ100px  
        sur.fpath AS 'pro_img_200' ,  --��ƷͼƬ200px  
        sur.fpath AS 'pro_img_300' ,  --��ƷͼƬ300px
		sur.fpath AS 'pro_img_size' ,  --��ƷͼƬ�Զ���
        (case when p.del=2 then '��Ʒ�ѱ�ɾ��' else p.title end) AS 'pro_name' ,  --��Ʒ����  
        p.order1 AS 'pro_order1' ,  --��Ʒ���  
        p.type1 AS 'pro_type' ,  --��Ʒ�ͺ�  
        sth1.sort1 AS 'pro_unit' ,  --��Ʒ��λ  
        jg1.price1jy AS 'pro_advice' ,  --�������  
        jg1.price1 AS 'pro_highest' ,  --��߽���  
        ISNULL(kot2.ph, kotl.ph) AS 'pro_ph' ,  --��Ʒ����  
        ISNULL(kot2.xlh, kotl.xlh) AS 'pro_xlh' ,  --��Ʒ���кţ����֣�  
        ISNULL(kot2.xlh, kotl.xlh) AS 'Bar_code_pro_xlh' ,  --��Ʒ���кţ�ͼ�ģ�
        jg1.txm AS 'peo_bar' ,  --��Ʒ�����루���֣�  
        jg1.txm AS 'Bar_code_pro_bars' ,  --��Ʒ�����루ͼ�ģ�
        kot2.datesc AS 'pro_datesc' ,  --��������  
        kot2.dateyx AS 'pro_dateyx' ,  --��Ч����  
        p.zdy1 AS 'zb_cp_zdy1' ,  --��Ʒ�Զ���1  
        p.zdy2 AS 'zb_cp_zdy2' ,  --��Ʒ�Զ���2  
        p.zdy3 AS 'zb_cp_zdy3' ,  --��Ʒ�Զ���3  
        p.zdy4 AS 'zb_cp_zdy4' ,  --��Ʒ�Զ���4  
        p_sth1.sort1 AS 'zb_cp_zdy5' ,  --��Ʒ�Զ���5  
        p_sth2.sort1 AS 'zb_cp_zdy6' ,  --��Ʒ�Զ���6  
        p.intro1 AS 'pro_instructions' ,  --��Ʒ˵��  
        p.intro2 AS 'pro_parameter' ,  --��Ʒ����  
        m.menuname as pro_sort1,--��Ʒ����
		m.fullpath as pro_sort2,--��Ʒ����ȫ·��
        p.intro3 AS 'pro_accessoryfj' ,  --ͼƬ�븽��  
        ISNULL(kot2.zdy1, kotl.zdy1) AS 'zb_xs_zdy1' ,  --��Ʒ��ϸ�Զ���1  
        ISNULL(kot2.zdy2, kotl.zdy2) AS 'zb_xs_zdy2' ,  --��Ʒ��ϸ�Զ���2  
        ISNULL(kot2.zdy3, kotl.zdy3) AS 'zb_xs_zdy3' ,  --��Ʒ��ϸ�Զ���3  
        ISNULL(kot2.zdy4, kotl.zdy4) AS 'zb_xs_zdy4' ,  --��Ʒ��ϸ�Զ���4  
        kot2_sth1.sort1 AS 'zb_xs_zdy5' ,  --��Ʒ��ϸ�Զ���5  
        kot2_sth1.sort1 AS 'zb_xs_zdy6' ,  --��Ʒ��ϸ�Զ���6  
        ISNULL(kot2.intro, kotl.price1) AS 'pro_allintro' ,  --��ע  
        ISNULL(kot2.date2, kotl.date2) AS 'pro_aog' ,  --��������  
        (case when kot.complete1 = 3 then kot2.num1 else isnull(kotl.num1,0) end) AS 'send_tno_ck' ,  --�����������  
        ISNULL(kot2.num2, 0) AS 'send_tno_sq' ,  --���뷢������  
        ISNULL(kot2.num3, 0) AS 'send_tno_sj' ,  --ʵ�ʷ�������  
        ss.sort1 AS 'warehouse', --�ֿ�
        REPLACE(ss.FullPath,CHAR(1),'-')  AS 'zb_kpbh', --�ֿ�--��·��
        round(ISNULL(kot2.js, isnull(kotl.js,0)),2) AS 'pro_js' ,  --����
        ISNULL(kot2.num1,0) AS 'pro_cksl' ,  --��������
        shy.sort1 AS 'pro_unit2',  --������λ
        round(isnull(kot2.AssistNum,kotl.AssistNum),(select num1 from setjm3 where ord=88)) AS 'num_unit2',  --�������� 
        bz_sth.sort1 AS 'pro_bz' , --��װ  
        sth.sort1 AS 'Invoice_type' , --��Ʊ����  
        ctl.num1 AS 'contract_tno' , --��ͬ����  
        ctl.discount AS 'pro_zk' , --�ۿ�  
        ctl.price1 AS 'pro_price_ws' , --δ˰����  
        ctl.priceAfterDiscount AS 'pro_price_zh' , --δ˰�ۺ󵥼�
        ctl.priceIncludeTax AS 'pro_price_hs' , --��˰����
        ISNULL(ctl.priceAfterTaxPre,ISNULL(cast(kotl.intro as decimal(25, 12)),isnull(kot2.price2,cast(kotl.intro as decimal(25, 12))))) AS 'pro_price_hszh' , --��˰�ۺ󵥼�
        ( ctl.taxRate / 100 ) AS 'pro_sl' , --˰��
        cast((ctl.concessions + ISNULL((SELECT smoney FROM erp_contract_MnyGainOrLoss WHERE contractlist = ctl.id AND stype = 'yh'),0)) * isnull(kot2.num1,kotl.num1) as decimal(25,12)) /ctl.num1 AS 'pro_favorable' , --�Żݽ��
        ctl.taxValue * isnull(kot2.num1,kotl.num1) /ctl.num1 AS 'pro_tax' , --˰��
        (case when kot.complete1 = 3 then kot2.FinaMoney/kot2.num1 else 0 end) AS 'pro_price_cb' , --�ɱ�����
        round(ctl.money1 * isnull(kot2.num1,kotl.num1) /ctl.num1,isnull(jm.num1,2)) AS 'pro_price_zj' , --��Ʒ�ܼ�
        round(ctl.price1 * isnull(kot2.num1,kotl.num1),isnull(jm.num1,2)) AS 'pro_price_ws1' , --δ˰�ܼ�
        round(ctl.moneyBeforeTax *  isnull(kot2.num1,kotl.num1)/ctl.num1,isnull(jm.num1,2)) AS 'pro_price_zh1' , --δ˰�ۺ��ܼ�( 1 - ISNULL(discount, 0) )
        round(ctl.moneyAfterTax/ctl.num1 * isnull(kot2.num1,kotl.num1),isnull(jm.num1,2))  AS 'pro_price_hs1' , --��˰�ܼ�
        round((case when kot.sort1=1 then cast((ctl.moneyAfterTax * isnull(kot2.num1,kotl.num1) /ctl.num1) as decimal(25,12)) else  ISNULL(kotl.money1,kot2.money2)   end),isnull(jm.num1,2))  AS 'pro_price_hszh1' , --��˰�ۺ��ܼ� ( 1 - ISNULL(discount, 0) )       
		round((case when kot.complete1 = 3 then kot2.FinaMoney else 0 end),isnull(jm.num1,2)) AS 'pro_price_cb1', --    �ɱ��ܼ�           
		ctl.id AS 'contractlistId',--��ͬ��ϸid
        cast(isnull(ISNULL(kot2.ProductAttr1, kotl.ProductAttr1),0) as varchar(10)) +'_' +cast(isnull(ISNULL(kot2.ProductAttr2, kotl.ProductAttr2),0) as varchar(10)) ProductAttr,
        ISNULL(kot2.ProductAttr1, kotl.ProductAttr1) AS ProductAttr1 ,  --��Ʒ����1  
        ISNULL(kot2.ProductAttr2, kotl.ProductAttr2) AS ProductAttr2 ,  --��Ʒ����2  
        ISNULL(kot2.ProductAttrBatchId, kotl.ProductAttrBatchId) AS 'ProductAttrBatchId'
    FROM  dbo.kuout kot  
    LEFT JOIN dbo.kuoutlist kotl ON kotl.kuout = kot.ord AND kot.complete1!= 3    
    LEFT JOIN dbo.kuoutlist2 kot2 ON kot2.kuout = kot.ord AND kot.complete1 = 3  
    LEFT JOIN dbo.sortonehy kot2_sth1 ON ISNULL(kot2.zdy5, kotl.zdy5) = kot2_sth1.ord  
    LEFT JOIN dbo.sortonehy kot2_sth2 ON ISNULL(kot2.zdy6, kotl.zdy6) = kot2_sth2.ord  
    LEFT JOIN dbo.sortonehy bz_sth ON ISNULL(kot2.bz, kotl.bz) = bz_sth.ord  
    LEFT JOIN sortck ss ON ISNULL(kot2.ck, 0) = ss.ord  
    LEFT JOIN dbo.product p ON ISNULL(kot2.ord, kotl.ord) = p.ord  
    LEFT JOIN Menu m on m.id=p.sort1
    LEFT JOIN dbo.sortonehy p_sth1 ON p.zdy5 = p_sth1.ord  
    LEFT JOIN dbo.sortonehy p_sth2 ON p.zdy6 = p_sth2.ord  
    LEFT JOIN gate g ON g.ord = kot.cateid  
    LEFT JOIN gate1 g1 ON g1.ord = g.sorce 
    left join setjm3 jm on jm.ord = 1 
    LEFT JOIN (
		select distinct a.product,a.unit,a.price1jy,a.price1,case when isnull(a.txm,'')='' then b.txm else a.txm end txm
		from jiage a with(nolock)
		inner join (select product,  unit , min(sort) sort from jiage group by product,  unit) c on a.product = c.product and a.unit = c.unit  and c.sort = a.sort
		left join jiage b with(nolock) on a.product = b.product and a.unit = b.unit and ISNULL(a.txm,'')='' and isnull(b.txm,'')<>'' and b.bm=0 
		where a.bm = 0
    ) jg1 ON ISNULL(kot2.ord, kotl.ord) = jg1.product AND jg1.unit = ISNULL(kot2.unit, kotl.unit)
    LEFT JOIN dbo.sys_upload_res sur ON p.ord = sur.id1 AND sur.source = 'productPic'  
                                        AND sur.id = ( SELECT TOP 1 id FROM sys_upload_res WHERE p.ord = id1  AND source = 'productPic' ORDER BY id3 ASC )  
    LEFT JOIN dbo.contractlist ctl ON kot.sort1 IN (1,4) AND ISNULL(kot2.contractlist, kotl.contractlist) = ctl.id  
    LEFT JOIN dbo.sortonehy sth ON ctl.invoiceType = sth.ord  AND sth.gate2 = 34  
    LEFT JOIN dbo.sortonehy sth1 ON ISNULL(kot2.unit, kotl.unit) = sth1.ord AND sth1.gate2 = 61 
    LEFT JOIN dbo.sortonehy shy ON ISNULL(kot2.AssistUnit, kotl.AssistUnit) = shy.ord AND shy.gate2 = 61   
    WHERE ISNULL(kot2.num1 , kotl.num1)>0 AND kot.ord= @kuord  
    ORDER BY
			isnull(ctl.id,0),
			--kot2.contractlist ASC ,  
            case when kot.complete1=3 then kot2.date7 else kotl.date7 end ASC ,  
            case when kot.complete1=3 then kot2.id else kotl.id end  ASC  
			-- kotl.contractlist ASC ,  
			--kotl.date7 ASC ,  
            --isnull(kotl.id,isnull(kot2.kuoutlist,0)) ASC
           
)
         
GO

CREATE  FUNCTION  [dbo].[FUN_ProductTemplateData](@proid int)
RETURNS TABLE 
AS
RETURN 
(
    SELECT  pro.ord ,
            sur.fpath AS 'pro_img_100' ,  --��ƷͼƬ100px
            sur.fpath AS 'pro_img_200' ,  --��ƷͼƬ200px
            sur.fpath AS 'pro_img_300' ,  --��ƷͼƬ300px
            pro.title AS 'pro_name' ,  --��Ʒ����
            pro.order1 AS 'pro_order1' ,  --��Ʒ���
            pro.type1 AS 'pro_type' ,  --��Ʒ�ͺ�
            m.menuname AS 'pro_classify' ,  --��Ʒ����
            pro.num_sc AS 'pro_cycle_sc' ,  --��������
            pro.pym AS 'pro_pym' ,  --ƴ����
            pro.aleat2 AS 'pro_inventory_sx' ,  --�������
            pro.aleat1 AS 'pro_inventory_xx' ,  --�������
            tel.name AS 'pro_supplier' ,  --����Ӧ��
            pro.zdy1 AS 'zb_cp_zdy1' ,  --�Զ���1
            pro.zdy2 AS 'zb_cp_zdy2' ,  --�Զ���2
            pro.zdy3 AS 'zb_cp_zdy3' ,  --�Զ���3
            pro.zdy4 AS 'zb_cp_zdy4' ,  --�Զ���4
            pro_sth1.sort1 AS 'zb_cp_zdy5' ,  --�Զ���5
            pro_sth2.sort1 AS 'zb_cp_zdy6' ,  --�Զ���6
            CONVERT(VARCHAR(20), pro.MaintainNum) + CASE pro.MaintainUnit
                                                      WHEN '1' THEN 'Сʱ'
                                                      WHEN '2' THEN '��'
                                                      WHEN '3' THEN '��'
                                                      WHEN '4' THEN '��'
                                                      WHEN '5' THEN '��'
                                                    END AS 'pro_cycle_yh' ,  --��������
            sth.sort1 AS 'pro_unit' ,  --������λ
            pro.unit AS 'pro_unit_fz' ,  --������λ
            CASE pro.canOutStore
              WHEN 0 THEN '����'
              ELSE 'ʵ��'
            END AS 'pro_attribute' ,  --��Ʒ����
            pro.intro2 AS 'pro_parameter' ,  --��Ʒ����
            pro.intro1 AS 'pro_instructions' ,  --��Ʒ˵��
            pro.intro3 AS 'pro_accessoryfj' ,  --ͼƬ����
            dja.txm AS 'Bar_code' ,  --������
            c2c.id AS 'Qr_url_code' ,  --��ά��
            dja.price1jy AS 'pro_advice' ,  --�������
            dja.price1 AS 'pro_highest' ,  --��߽���
            dja.price2jy AS 'pro_advice_sj' ,  --�����ۼ�
            dja.price2 AS 'pro_highest-sj'  --����ۼ�
    FROM    dbo.product pro
            LEFT JOIN dbo.sortonehy pro_sth1 ON pro.zdy5 = pro_sth1.ord
            LEFT JOIN dbo.sortonehy pro_sth2 ON pro.zdy6 = pro_sth2.ord
            LEFT JOIN dbo.menu m ON pro.sort1 = m.id
            LEFT JOIN dbo.tel tel ON pro.company = tel.ord
            LEFT JOIN dbo.sortonehy sth ON pro.unitjb = sth.ord
                                           AND sth.gate2 = 61
            LEFT JOIN ( SELECT DISTINCT
                                product ,
                                unit ,
                                price1jy ,
                                price1 ,
                                price2jy ,
                                price2 ,
                                txm
                        FROM    dbo.jiage
                        WHERE   bm = 0
                      ) dja ON pro.ord = dja.product
                               AND pro.unitjb = dja.unit
            LEFT JOIN dbo.sys_upload_res sur ON pro.ord = sur.id1
                                                AND source = 'productPic'
                                                AND sur.id = ( SELECT TOP 1
                                                              id
                                                              FROM
                                                              sys_upload_res
                                                              WHERE
                                                              pro.ord = id1
                                                              AND source = 'productPic'
                                                              ORDER BY id3 ASC
                                                             )
            LEFT JOIN C2_CodeItems c2c ON pro.ord = c2c.sourceID
            WHERE pro.ord = @proid
)

GO

CREATE FUNCTION [dbo].[FUN_HrKQ_GetRestTime]
(
    @applyTime DATETIME ,
    @startTime as DATETIME,--��Ч�ؿ�ʼ��
    @UserIDs VARCHAR(5000)
)
RETURNS TABLE
AS
RETURN
    ( SELECT    ISNULL(MIN(mindata.shengyu), 0) AS shengyu
      FROM      ( SELECT    ISNULL(SUM(data.shengyu), 0) AS shengyu
                  FROM      ( SELECT    short_str ,
                                        bb.*
                              FROM      dbo.split(@UserIDs, ',') aa
                                        LEFT JOIN ( SELECT  haa.ID ,
                                                            haa.Title ,
                                                            haa.StartDate AS startDate ,
                                                            DATEADD(DAY,
                                                              hat.TermofValidity,
                                                              haa.StartDate) AS endDate ,
                                                            haa.HWhenlong zongji ,
                                                            SUM(ISNULL(har.Whenlong,
                                                              0)) AS yiyong ,
                                                            (ISNULL(haa.HWhenlong,
                                                              0)*isnull(haa.ExchangeBL,1)
                                                              - SUM(ISNULL(har.Whenlong,
                                                              0)) ) AS shengyu ,
                                                            haar.UserID
                                                    FROM    dbo.HrKQ_AttendanceApply haa
                                                            INNER JOIN dbo.HrKQ_AttendanceApplyRange haar ON haa.ID = haar.ApplyID
                                                            INNER JOIN dbo.HrKQ_AttendanceType hat ON haa.ApplyType = hat.OnlyID
                                                            LEFT JOIN sp_ApprovalInstance wai ON haa.ID = wai.PrimaryKeyID
                                                              AND wai.BillPattern IN (0, 1 )  AND wai.gate2 = '8' 
                                                            LEFT JOIN (select har.Whenlong,har.OverTimeID,har.UserID 
																		from dbo.HrKQ_AttendanceApply haa 
																		inner join HrKQ_AdjustmentRest har on haa.ID = har.RestID AND har.isCalcul = 1 
																		INNER JOIN sp_ApprovalInstance wai ON haa.ID = wai.PrimaryKeyID
																		  AND wai.BillPattern IN (
																		  0, 1 )  AND wai.gate2 = '8' 
																		  where ISNULL(wai.ApprovalFlowStatus,-1) in(1,-1)
																	) har ON haa.ID = har.OverTimeID
                                                            AND haar.UserID = har.UserID
                                                    WHERE   haa.isDel = 0 
                                                            and hat.AttTypeCls=2
                                                            AND ISNULL(wai.ApprovalFlowStatus,-1) in(1,-1)
                                                            AND @applyTime >= haa.EndDate
                                                            AND haa.StartDate >= @startTime
                                                    GROUP BY haa.ID ,
                                                            haar.UserID ,
                                                            haa.Title ,
                                                            haa.ExchangeBL,
                                                            haa.Whenlong ,
                                                            haa.HWhenlong ,
                                                            haa.StartDate ,
                                                            hat.TermofValidity ,
                                                            haar.ApplyID
                                                  ) bb ON aa.short_str = bb.UserID
                            ) data
                  GROUP BY  data.short_str
                ) mindata
    )

GO

CREATE FUNCTION [dbo].[FUN_HrKQ_GetDateList]
    (
      @StartDate DATETIME ,
      @EndDate DATETIME ,
      @USERID VARCHAR(8000)
    )
RETURNS TABLE
AS
RETURN
    ( SELECT    gt.ord AS UserID,
				gt.name AS UserName,
				CONVERT(VARCHAR(10), hct.Date, 120) AS 'DateText' ,
                hsd.TimeArrangeID ,
                CASE WHEN hsd.TimeArrangeID IS NULL THEN 'δ���ð��'
                     WHEN hsd.TimeArrangeID = 999999 THEN '��Ϣ'
                     WHEN hsd.TimeArrangeID = 888888 THEN '�ڼ���'
                     ELSE htd.Title
                END AS 'Title' ,
                CASE hct.Week
                  WHEN 1 THEN '����һ'
                  WHEN 2 THEN '���ڶ�'
                  WHEN 3 THEN '������'
                  WHEN 4 THEN '������'
                  WHEN 5 THEN '������'
                  WHEN 6 THEN '������'
                  WHEN 7 THEN '������'
                  ELSE '�쳣'
                END AS 'WeekName' ,
                hcdl.SignTime ,
                hcdl.SignOutTime ,
                hcdl.StartInterDay ,
                hcdl.EndInterDay ,
				ISNULL(hcdl.StartEffectiveTime,hcdl.EffectiveTime) as StartEffectiveTime,
                hcdl.EffectiveTime ,
                htd.ID AS htdid ,
                hcdl.ID AS hcdlid ,
                CONVERT(VARCHAR(10), hct.Date, 120) AS 'LoginDetails' ,
                hcdl.Whenlong AS 'Worklong' ,
                htd.RuleLateMinute ,
                htd.RuleLeaveEarlyMinute ,
                htd.RuleMinerMinute ,
                ElasticTimeMinute,
                hsdl.StartDate,
                hsdl.EndDate
      FROM      dbo.HrKQ_CalendarTable hct (nolock) 
				LEFT JOIN (SELECT * FROM dbo.split(@USERID,',')) users ON 1 =1 
                LEFT JOIN HrKQ_PersonGroup hpg ON CHARINDEX(CONVERT(VARCHAR(50), ','+users.short_str+','),','+CONVERT(VARCHAR(8000),hpg.[Range])+',', 0) > 0 OR hpg.RangeType = 0
                LEFT JOIN dbo.gate gt ON gt.ord = USERs.short_str
                INNER JOIN dbo.HrKQ_Scheduling hsdl ON CHARINDEX(','+CONVERT(VARCHAR(50),hpg.ID)+',',','+CONVERT(VARCHAR(8000),hsdl.PersonGroupIDs)+',',0) > 0
                INNER JOIN HrKQ_SchedulingDetail hsd ON hsdl.ID = hsd.ParentID
                                                       AND hct.[Date] = hsd.[Date] and hsd.PersonGroupID = hpg.ID
                LEFT JOIN HrKQ_TimeArrangeDetail htd ON hsd.TimeArrangeID = htd.ID
                LEFT JOIN HrKQ_ClockDetailList hcdl ON htd.ID = hcdl.DetailID
      WHERE     hct.[Date] >= CONVERT(VARCHAR(10),@StartDate,120)
				AND hct.[Date] < @EndDate
				AND hsdl.StartDate IS NOT NULL
				AND gt.ord IS NOT NULL
    )

GO

CREATE FUNCTION [dbo].[F_HrKQ_ApplyUserRange]
    (
      @ID INT ,
      @isUserName INT
    )
RETURNS VARCHAR(8000)
AS
    BEGIN
        DECLARE @Result VARCHAR(8000);
        SET @Result = '';
        IF @isUserName = 1
            BEGIN               
                SELECT  @Result = @Result + ',' + gt.name
                FROM    dbo.HrKQ_AttendanceApply haa
                        LEFT JOIN dbo.HrKQ_AttendanceApplyRange haar ON haa.ID = haar.ApplyID
                        JOIN gate_person gt ON haar.UserID = gt.ord
                WHERE   haa.ID = @ID;
            END;
        ELSE
            BEGIN
                SELECT  @Result = @Result + ',' + CONVERT(VARCHAR(50), gt.ord)
                FROM    dbo.HrKQ_AttendanceApply haa
                        LEFT JOIN dbo.HrKQ_AttendanceApplyRange haar ON haa.ID = haar.ApplyID
                        JOIN gate_person gt ON haar.UserID = gt.ord
                WHERE   haa.ID = @ID;
            END;
        RETURN STUFF(@Result, 1, 1, '');
    END
GO

CREATE FUNCTION [dbo].[FUN_HrKQ_GetPrintData] ( @ID INT )
RETURNS TABLE
AS
RETURN
    ( SELECT    haa.ApplyType ,
                haa.Title AS 'taf_theme' , --��������
                dbo.F_HrKQ_ApplyUserRange(haa.ID, 1) AS 'taf_people' , --������
                StartDate AS 'start_time' , --��ʼʱ��
                EndDate AS 'as_of_time' , --����ʱ��	
                haa.CreateDate AS 'add_the_time' , --���ʱ��
                gt.name AS 'add_people' , --�����
                hat.Title AS 'taf_type' , --��������
                CONVERT(VARCHAR(20),dbo.formatNumber(haa.Whenlong,(select ISNULL(num1,2) num1 from setjm3 where ord=88),0)) + ISNULL(haa.Unit,'Сʱ') AS 'total_of_time' , --�ܼ� 
                haa.Remarks AS 'taf_note', --��ע
                dbo.F_HrKQ_ApplyJoinApprover(wai.Approver,1) AS 'current_auditor',   --��ǰ������
                CASE wai.ApprovalFlowStatus
            	  WHEN 0 THEN 'δͨ��'
            	  WHEN 1 THEN '����ͨ��'
            	  WHEN 2 THEN '�����˻�'
            	  WHEN 3 THEN '���ύ'
            	  WHEN 4 THEN '������'
            	  WHEN 5 THEN '������'
            	  ELSE '����ͨ��'
            	END AS 'sp_status'   --����״̬
      FROM      dbo.HrKQ_AttendanceApply haa
                LEFT JOIN dbo.gate gt ON haa.CreateID = gt.ord
                LEFT JOIN dbo.HrKQ_AttendanceType hat ON haa.ApplyType = hat.OnlyID
                LEFT JOIN sp_ApprovalInstance wai ON haa.ID = wai.PrimaryKeyID AND wai.BillPattern IN(0,1) AND wai.gate2 = '8'
      WHERE     haa.ID = @ID
    )
GO

CREATE FUNCTION [dbo].[FUN_HrKQ_GetPrintApprovalData] ( @ID INT )
RETURNS TABLE
AS
RETURN
    ( SELECT    ISNULL(CONVERT(VARCHAR(20), date1, 120), '') AS approve_date ,   --'����ʱ��' 
                sp AS approve_stage ,   --'�����׶�' 
                ApprovalType AS approve_mode ,   ---'������ʽ' 
                ApproverName AS approver ,   --'������' 
                ( CASE WHEN ApprovalResult = 0 THEN '���'
                    WHEN ApprovalResult = 1 THEN 'ͨ��'
                    WHEN ApproverDept = '�˻�' THEN '�˻�'
                    ELSE ''
                  END ) AS approve_result , ---'�������' 
                intro AS approve_opinion   --'�������'
      FROM      sp_intro
      WHERE     InstanceID = ( SELECT TOP 1
                                        wai.InstanceID
                               FROM     dbo.HrKQ_AttendanceApply haa
                                        JOIN sp_ApprovalInstance wai ON haa.ID = wai.PrimaryKeyID
                               WHERE    haa.ID = @ID
                                        AND BillPattern IN ( 0, 1 )
                                        AND wai.gate2 = '8'
                             )
                AND ( OperationType = ''
                  OR OperationType IS NULL
                  OR CHARINDEX('ԭ', ISNULL(OperationType, ''), 0) = 1
                  OR CHARINDEX('��', ISNULL(OperationType, ''), 0) = 1
                )
    )

GO

CREATE FUNCTION [dbo].[F_HrKQ_CardSettingRange]
    (
      @RangeID INT , --ID
      @isUserName INT , --����ֵ�Ƿ�Ϊ������1Ϊ����  0Ϊ����ID
      @isCut INT  -- �Ƿ�15����ƴ�ӣ�ʣ����ʡ�Ժ���ʾ
    )
RETURNS VARCHAR(8000)
AS
    BEGIN
        DECLARE @ids VARCHAR(8000);
        DECLARE @Count INT;
        SET @ids = '';
        SET @Count = 0;
        IF @isUserName = 1
            BEGIN
                IF @isCut > 0
                    BEGIN
                        SELECT TOP 15
                                @ids = @ids + ','
                                + CONVERT(VARCHAR(20), CASE hc.RangeType WHEN 0 THEN sh.sort1 ELSE gt.name END)
                        FROM    dbo.HrKQ_CardSetting hc
								INNER JOIN HrKQ_CardSettingRange hcr ON hc.RangeID = hcr.RangeID
                                LEFT JOIN dbo.gate gt ON hcr.UserID = gt.ord
                                LEFT JOIN dbo.sortonehy sh ON hcr.UserID = sh.ord
                        WHERE   hc.RangeID = @RangeID;
                        SET @Count = (SELECT  COUNT(*)
                        FROM    dbo.HrKQ_CardSetting hc
								INNER JOIN HrKQ_CardSettingRange hcr ON hc.RangeID = hcr.RangeID
                                LEFT JOIN dbo.gate gt ON hcr.UserID = gt.ord
                                LEFT JOIN dbo.sortonehy sh ON hcr.UserID = sh.ord
                        WHERE   hc.RangeID = @RangeID);
                        IF ( @Count > 15 )
                            BEGIN
                                SET @ids = @ids + ',����';
                            END; 
                    END;
                ELSE
                    BEGIN
                        SELECT  @ids = @ids + ','
                                + CONVERT(VARCHAR(20), CASE hc.RangeType WHEN 0 THEN sh.sort1 ELSE gt.name END)
                        FROM    dbo.HrKQ_CardSetting hc
								INNER JOIN HrKQ_CardSettingRange hcr ON hc.RangeID = hcr.RangeID
                                LEFT JOIN dbo.gate gt ON hcr.UserID = gt.ord
                                LEFT JOIN dbo.sortonehy sh ON hcr.UserID = sh.ord
                        WHERE   hc.RangeID = @RangeID;
                    END; 
            END;
        ELSE
            BEGIN
                SELECT  @ids = @ids + ',' + CONVERT(VARCHAR(20), UserID)
                FROM    HrKQ_CardSettingRange
                WHERE   RangeID = @RangeID;
            END;
        RETURN STUFF(@ids, 1, 1, '');
    END

GO

CREATE FUNCTION [dbo].[F_HrKQ_GetUserNameForGroup]
    (
      @ID INT ,
      @isCount INT ,
      @isCut INT ,
      @RangeType INT --0Ϊ������Ա��1Ϊ��ȡ��Ա
    )
RETURNS VARCHAR(8000)
AS
    BEGIN
        DECLARE @Result VARCHAR(8000);
        DECLARE @Count INT;
        SET @Result = '';
        SET @Count = 0;
        IF ( @RangeType = 0 )
            BEGIN
                SELECT  @Result = COUNT(1)
                FROM    dbo.hr_person
                WHERE   del = 0;
            END; 
        ELSE
            BEGIN 
        --isCountΪ1�򷵻ؾ�����Ա����
                IF ( @isCount > 0 )
                    BEGIN
                        SELECT  @Result = COUNT(1)
                        FROM    dbo.gate_person
                        WHERE   CHARINDEX(',' + CONVERT(VARCHAR(80), ord)
                                          + ',',
                                          ( SELECT  ','
                                                    + CONVERT(VARCHAR(8000), [Range])
                                                    + ','
                                            FROM    dbo.HrKQ_PersonGroup
                                            WHERE   ID = @ID
                                          ), 0) > 0;
                    END;
                ELSE
                    BEGIN 
                        IF ( @isCut > 0 )
                            BEGIN
                                SELECT TOP 15
                                        @Result = @Result + ','
                                        + CONVERT(NVARCHAR(50), gt.name)
                                FROM    dbo.gate_person gt
                                WHERE   CHARINDEX(','
                                                  + CONVERT(VARCHAR(80), gt.ord)
                                                  + ',',
                                                  ( SELECT  ','
                                                            + CONVERT(VARCHAR(8000), [Range])
                                                            + ','
                                                    FROM    dbo.HrKQ_PersonGroup
                                                    WHERE   ID = @ID
                                                  ), 0) > 0;
                                SET @Result = STUFF(@Result, 1, 1, ''); 
                                SET @Count = ( SELECT   COUNT(1)
                                               FROM     dbo.gate_person 
                                               WHERE    CHARINDEX(','
                                                              + CONVERT(VARCHAR(80), ord)
                                                              + ',',
                                                              ( SELECT
                                                              ','
                                                              + CONVERT(VARCHAR(8000), [Range])
                                                              + ','
                                                              FROM
                                                              dbo.HrKQ_PersonGroup
                                                              WHERE
                                                              ID = @ID
                                                              ), 0) > 0
                                             );
                                IF ( @Count > 15 )
                                    BEGIN
                                        SET @Result = @Result + ',����';
                                    END; 
                            END;
                        ELSE
                            BEGIN 
                                SELECT  @Result = @Result + ','
                                        + CONVERT(NVARCHAR(50), gt.name)
                                FROM    dbo.gate_person gt
                                WHERE   CHARINDEX(','
                                                  + CONVERT(VARCHAR(80), gt.ord)
                                                  + ',',
                                                  ( SELECT  ','
                                                            + CONVERT(VARCHAR(8000), [Range])
                                                            + ','
                                                    FROM    dbo.HrKQ_PersonGroup
                                                    WHERE   ID = @ID
                                                  ), 0) > 0;
                                SET @Result = STUFF(@Result, 1, 1, ''); 
                            END;  
                    END;
            END;
        RETURN @Result;
    END

GO

CREATE FUNCTION [dbo].[F_HrKQ_SchedulingGroupNames] ( @ID INT )
RETURNS VARCHAR(8000)
AS
    BEGIN
        DECLARE @groupNames VARCHAR(8000);
        SET @groupNames = '';
        SELECT  @groupNames = @groupNames + ','
                + CONVERT(VARCHAR(100), hp.GroupName)
        FROM    HrKQ_Scheduling hs
                JOIN HrKQ_PersonGroup hp ON CHARINDEX(','
                                                      + CONVERT(VARCHAR(50), hp.ID)
                                                      + ',',
                                                      ',' + CONVERT(VARCHAR(8000),hs.PersonGroupIDs)
                                                      + ',', 0) > 0
        WHERE   hs.ID = @ID;
        RETURN STUFF(@groupNames, 1, 1, '');
    END

GO


CREATE FUNCTION [dbo].[F_HrKQ_TimeArrangeClock] ( @DetailID INT )
RETURNS VARCHAR(8000)
AS
    BEGIN
        DECLARE @times VARCHAR(8000);
        SET @times = '';
        SELECT  @times = @times + ',' + CONVERT(VARCHAR(20), SignTime) + '(��'
                + CONVERT(VARCHAR(20), StartInterDay) + '��)--'
                + CONVERT(VARCHAR(20), SignOutTime) + '(��'
                + CONVERT(VARCHAR(20), EndInterDay) + '��)'
        FROM    HrKQ_ClockDetailList
        WHERE   DetailID = @DetailID ORDER BY StartInterDay,EndInterDay,SignTime;
        RETURN STUFF(@times, 1, 1, '');
    END

GO

CREATE  FUNCTION [dbo].[erp_list_AttendanceApply_fun] ( @uid INT, @typ INT )
RETURNS TABLE
AS RETURN
    ( SELECT TOP 100000
                a.ID ,
                dbo.erp_CreateLink(a.title,1,1004,a.id,a.CreateID,@uid,80,14) AS ���� ,
                a.StartDate AS ��ʼʱ��,
                a.EndDate AS ����ʱ��,
                ISNULL(hat.Title,'') AS ��������,
                a.CreateDate AS �������,
                dbo.F_HrKQ_ApplyUserRange(a.ID, 1) AS ������
                
      FROM      dbo.HrKQ_AttendanceApply a
      LEFT JOIN dbo.HrKQ_AttendanceType hat ON a.ApplyType = hat.OnlyID
      LEFT JOIN gate gt ON a.CreateID = gt.ord
      WHERE   ( isDel = 0
                  AND @typ = 1
                )
                OR ( @typ = 0
                     AND isDel = 1
                   )
    )

GO

create function [dbo].[wf_approvers](@id varchar(8000)) returns varchar(8000)  
as  
begin  
  declare @s varchar(8000)  
  set @s = ''
  select @s=@s+name+',' from gate where CHARINDEX(','+CONVERT(varchar(50),ord)+',',','+@id+',',0)>0
  set @s = stuff(@s,len(@s),1,'')
  return @s
end  

GO

create function [dbo].[wf_positionrange](@billtype varchar(100),@billcategory varchar(100)) returns varchar(8000)  
as  
begin  
  declare @s varchar(8000)  
  set @s = ''
  select @s=@s+positionrange+',' from sp_ApprovalRules where PositionRange is not null and PositionRange!='' and PositionRange!='*' and gate2=@billtype and sptype=@billcategory
  set @s = stuff(@s,len(@s),1,'')
  return @s
end  

GO
  
CREATE FUNCTION [dbo].[F_HrKQ_CheckPower]
    (
      @Users VARCHAR(8000) ,
      @qx_intro VARCHAR(8000)
    )
RETURNS INT
AS
    BEGIN  
        DECLARE @count INT;  
        SET @count = 0;  
        SELECT  @count = COUNT(1)
        FROM    dbo.split(@Users, ',') a
                INNER JOIN ( SELECT short_str
                             FROM   dbo.split(@qx_intro, ',')
                           ) b ON a.short_str = b.short_str
        WHERE   a.short_str <> ''
                AND b.short_str <> '';
        RETURN @count;  
    END

GO

CREATE FUNCTION [dbo].[F_HrKQ_GetApplyDataList] ( @UserID INT )
RETURNS TABLE
AS
RETURN
    (SELECT haa.ID ,
            haa.Title ,
            dbo.F_HrKQ_ApplyUserRange(haa.ID, 1) AS ApplyUser ,
            dbo.F_HrKQ_ApplyUserRange(haa.ID, 0) AS ApplyUserIDs ,
            haa.ApplyType AS ApplyTypeID,
            hat.Title AS ApplyType ,
            CONVERT(varchar(16),haa.StartDate,120) AS StartDate,
            CONVERT(varchar(16),haa.EndDate,120) AS EndDate,
            Convert(varchar(50),haa.Whenlong) + ISNULL(haa.Unit,'Сʱ') as Whenlong,
            haa.CreateDate ,
            haa.CreateID ,
            wai.InstanceID ,
            ISNULL(wai.ApprovalFlowStatus,-1) AS ApprovalFlowStatus,
            CASE ISNULL(wai.ApprovalFlowStatus,-1)
              WHEN -1 THEN '��������'
              WHEN 0 THEN 'δͨ��'
              WHEN 1 THEN '����ͨ��'
              WHEN 2 THEN '�����˻�'
              WHEN 3 THEN '���ύ'
              WHEN 4 THEN '������'
              WHEN 5 THEN '������'
              ELSE '����ͨ��'
            END AS 'ApprovalStatus' ,
            dbo.F_HrKQ_ApplyJoinApprover(wai.Approver,0) AS ApproverID ,
            ISNULL(dbo.F_HrKQ_ApplyJoinApprover(wai.Approver,1),'') AS Approver ,
            CASE WHEN (wai.ApprovalFlowStatus IN (0,2,3,4)
            AND (powupdate.qx_open = 3 OR CHARINDEX(','+CONVERT(VARCHAR(50),haa.CreateID)+',',','+CONVERT(VARCHAR(8000),powupdate.qx_intro)+',',0) > 0)) THEN 'true' ELSE 'false' END AS updateBtn ,
            CASE WHEN (CHARINDEX(','+CONVERT(VARCHAR(100),@UserID)+',',','+isnull(wai.SurplusApprover,wai.Approver)+',',0) > 0 AND wai.ApprovalFlowStatus IN(4,5)
            AND ((SELECT 1 FROM dbo.power WHERE ord = @UserID AND sort1 = 80 AND sort2  = 16
			AND (qx_open = 3 OR CHARINDEX(','+CONVERT(VARCHAR(50),haa.CreateID)+',',','+CONVERT(VARCHAR(8000),qx_intro)+',',0) > 0)) <> '') or CHARINDEX(','+CONVERT(VARCHAR(100),wad.Consigner)+',',','+isnull(wai.SurplusApprover,wai.Approver)+',',0) > 0 AND wai.ApprovalFlowStatus IN(4,5)) THEN 'true'
                 ELSE 'false'
            END AS ApproverBtn ,
            CASE WHEN ( wai.ApprovalFlowStatus = 1
                        OR ISNULL(wai.ApprovalFlowStatus,-1) = -1
                      ) THEN 'true'
                 ELSE 'false'
            END AS isFileBtn ,
            isFile ,
            CASE isFile
              WHEN 1 THEN 'ȡ���鵵'
              ELSE '�鵵'
            END AS FileBtnTxt ,
            CASE WHEN isFile = 1 OR wai.ApprovalFlowStatus = 5 
            or exists(select top 1 1
                            from dbo.HrKQ_AttendanceLog al
                            inner join dbo.HrKQ_AttendanceType at on al.CurrAttdType=at.OnlyID
                            inner join dbo.HrKQ_OverTimeUsedList ol on al.LogDate=ol.KqLogDate and al.CurrAttdType=ol.KqLogType and ol.KqUserId=al.UserId
                            where at.AttTypeCls=2 
                            and al.DataFrom=2
                            and al.DataFromID = haa.ID) THEN 'false'
			WHEN (powdelete.qx_open = 3 OR CHARINDEX(','+CONVERT(VARCHAR(50),haa.CreateID)+',',','+CONVERT(VARCHAR(8000),powdelete.qx_intro)+',',0) > 0) THEN 'true'
            ELSE 'false' END AS deleteBtn,
            haa.Remarks,
            CASE WHEN wai.ApprovalFlowStatus=3 AND haa.CreateID = @UserID THEN 'true' ELSE 'false' END AS postBtn,
            CASE WHEN wai.ApprovalFlowStatus IN(2,4,5) AND (SELECT 1 FROM dbo.power WHERE ord = @UserID AND sort1 = 80 AND sort2  = 22
			AND (qx_open = 3 OR CHARINDEX(','+CONVERT(VARCHAR(50),haa.CreateID)+',',','+CONVERT(VARCHAR(8000),qx_intro)+',',0) > 0)) <> '' THEN 'true' ELSE 'false' END AS updateAppBtn,
			pow.qx_open,
			CONVERT(VARCHAR(8000),pow.qx_intro) AS qx_intro,
			CASE WHEN powdetail.qx_open = 3 OR (powdetail.qx_open = 1 AND dbo.[F_HrKQ_CheckPower](dbo.F_HrKQ_ApplyUserRange(haa.ID, 0),CONVERT(VARCHAR(8000),powdetail.qx_intro)) > 0) THEN 'true' ELSE 'false' END AS showupdateBtn,
            wad.Mandatary
    FROM    dbo.HrKQ_AttendanceApply haa
            left JOIN dbo.HrKQ_AttendanceType hat ON haa.ApplyType = hat.OnlyID
            LEFT JOIN sp_ApprovalInstance wai ON haa.ID = wai.PrimaryKeyID AND wai.BillPattern IN(0,1) AND wai.gate2 = '8'
	    LEFT JOIN [power] pow ON pow.ord=@UserID AND pow.sort1=80 AND pow.sort2=1
	    LEFT JOIN [power] powdetail ON powdetail.ord=@UserID AND powdetail.sort1=80 AND powdetail.sort2=14
	    LEFT JOIN [power] powupdate ON powupdate.ord=@UserID AND powupdate.sort1=80 AND powupdate.sort2=2
	    LEFT JOIN [power] powdelete ON powdelete.ord=@UserID AND powdelete.sort1=80 AND powdelete.sort2=3
            LEFT JOIN WF_ApprovalDelegateRecord wad on wad.Mandatary=@UserID and wad.BillType='attendance' and wad.IsEffect='1' and (((select currentDate from V_getcurrenttime) >= convert(varchar(50),wad.BeginTime,120) and (select currentDate from V_getcurrenttime) <= convert(varchar(50),DATEADD(DAY,1,wad.EndTime),120)) or wad.Forever='1')
    WHERE   haa.isDel = 0)

GO

--������������ID����
CREATE function [dbo].[getRemindList](
	@uid int,
	@configId INT
) returns table 
as 
return(
	select a.orderId
	from reminderQueue a 
	left JOIN reminderPersons __rp on __rp.reminderId=a.id AND __rp.cateid = @uid
	where a.reminderConfig=@configId AND __rp.cateid is NULL
)

GO

CREATE FUNCTION [dbo].[F_XunJiaPrintPJ]
    (
      @xunjiaID INT, --ѯ��ID
      @PJtype INT --1ΪԤ����2Ϊ�ɹ�
    )
RETURNS VARCHAR(8000)
AS
BEGIN
	DECLARE @Result VARCHAR(8000);
	SET @Result = ''
	IF(@PJtype = 1)
	BEGIN
		SELECT @Result = @Result + ',' + ISNULL(ISNULL(yg.title,yg2.title),'') FROM xunjia xj 
		LEFT JOIN caigou_yg yg ON yg.xunjia=xj.id AND yg.del=1	--ѯ�����ɵ�Ԥ��
		LEFT JOIN caigou_yg yg2 ON xj.caigou_yg=yg2.id AND yg2.del=1	--Ԥ�����ɵ�ѯ��
		WHERE xj.id = @xunjiaID	
	END
	ELSE
	BEGIN
		SELECT @Result = @Result + ',' + ISNULL(cg.title,'') FROM xunjia xj 
		LEFT JOIN caigou cg ON cg.xunjia=xj.id AND cg.del=1	--ѯ�����ɵĲɹ�
		WHERE xj.id = @xunjiaID	
	END
	SET @Result = STUFF(@Result, 1, 1, ''); 
	RETURN @Result       
END

GO

CREATE FUNCTION [dbo].[FUN_XunJiaTemplateData] ( @ord INT )
RETURNS TABLE
AS
 RETURN
    ( SELECT xj.id,
			xj.title AS RFQ_title,   --ѯ������
			xj.xjid AS RFQ_bh,   --ѯ�۱��
			CONVERT(VARCHAR(10),xj.date1,120) AS RFQ_date,   --ѯ������
			gt1.name AS RFQ_fixer,   --������Ա
			gt.name AS RFQ_person,   --ѯ����Ա
			xj.date7 AS RFQ_time,   --�������
			CASE xj.[status] WHEN 0 THEN '�ݴ�' WHEN 1 THEN 'ѯ���У�������' WHEN 2 THEN 'ѯ���У����ֶ���'
			 WHEN 3 THEN 'ѯ�����' WHEN 4 THEN '����ֹ' END AS RFQ_state,   --ѯ��״̬
		   CASE ISNULL(xj.complete,(case isnull(xj.caigou_yg,0) when 0 then (case when s.ygNum>0 then (case when s.ygNum>=s.xjNum then 1 else 2 end) else 0 end) else 1 end)) 
		   WHEN 0 THEN 'δԤ��' WHEN 1 THEN 'Ԥ�����' WHEN 2 THEN '����Ԥ��' END AS pre_state,   --Ԥ��״̬
			CASE (case when s.cgNum>0 then (case when s.cgNum>=s.xjNum then 1 else 2 end) else 0 end)
			WHEN 0 THEN 'δ�ɹ�' WHEN 1 THEN '�ɹ����' WHEN 2 THEN '���ֲɹ�' END AS po_state,   --�ɹ�״̬
			xj.remark AS RFQ_intro,   --ѯ�۸�Ҫ
			ISNULL(bj.title,'') AS quote_title,   --��������
			dbo.F_XunJiaPrintPJ(xj.id,1) AS pre_title,   --Ԥ������
			dbo.F_XunJiaPrintPJ(xj.id,2) AS po_title,   --�ɹ�����
			xj.zdy1 AS zb_zdy1,   --�Զ���1
			xj.zdy2 AS zb_zdy2,   --�Զ���2
			xj.zdy3 AS zb_zdy3,   --�Զ���3
			xj.zdy4 AS zb_zdy4,   --�Զ���4
			ISNULL(zdy5.sort1,'') AS zb_zdy5,   --�Զ���5
			ISNULL(zdy6.sort1,'') AS zb_zdy6   --�Զ���6
      FROM    xunjia xj
      LEFT JOIN gate gt ON xj.cateid = gt.ord
      LEFT JOIN gate gt1 ON xj.cateid_dj = gt1.ord
      LEFT JOIN sortonehy zdy5 ON zdy5.ord = xj.zdy5
	  LEFT JOIN sortonehy zdy6 ON zdy6.ord = xj.zdy6
      LEFT JOIN price bj ON xj.price=bj.ord AND bj.del=1	--�������ɵ�ѯ��
      LEFT JOIN ( 
	  		SELECT X.xunjia, SUM(X.xjNum) AS xjNum, SUM(X.ygNum) AS ygNum, SUM(X.cgNum) AS cgNum
		FROM (
				select a.xunjia,SUM(a.num1) xjNum,SUM(b.num1) ygNum, 
                CASE WHEN isnull(SUM(c.num1), 0) > SUM(a.num1) THEN SUM(a.num1) ELSE SUM(c.num1) END AS cgNum
				from ( 
					select id, xunjia, num1 from xunjialist where del=1 and xunjia=@ord and toUse=1 
					union all  
					Select id, xunjia, num1 From xunjialist a
					left join (
						select DISTINCT pricelist from xunjialist where del=1 and toUse=2 and xunjia=@ord
					) b on a.id=b.pricelist and a.del=1 and xunjia=@ord
						and a.id not in(select pricelist from xunjialist where del=1 and toUse=1 and xunjia=@ord)
					where a.Xunjiastatus=1 or b.pricelist>0 
					union all 
					Select c.id, a.id xunjia, c.num1 from xunjia a WITH(NOLOCK) 
					inner join price b WITH(NOLOCK) on b.ord=a.price and a.del=1 and b.del=1 and a.id=@ord 
					inner join pricelist c WITH(NOLOCK) on c.del=3 and c.price=b.ord 
					left join ( 
						select distinct pricelist from xunjialist where del=1 and isnull(toUse,0)=2 and xunjia=@ord 
					) d on c.id=d.pricelist and c.id not in(select pricelist from xunjialist where del=1 and toUse=1 and xunjia=@ord) 
					where c.xunjiastatus=1 or d.pricelist>0 
				)  a 
				left join (  
				select xunjialist,SUM(num1) num1 from caigoulist_yg WITH(NOLOCK) where del=1 group by xunjialist  
				) b  on b.xunjialist=a.id 
				left join (  
					select cgl.xunjialist ,sum(cgl.num1) as num1 
	 				from ( 
	 					SELECT mx.caigou,mx.fromid xunjialist,mx.fromNum num1 FROM caigoulist cl WITH(NOLOCK)  
	 					INNER JOIN caigoulist_mx mx WITH(NOLOCK) ON mx.fromType=3 AND cl.id=mx.caigoulist 
	 				) cgl   
	                left join caigou on caigou.ord=cgl.caigou 
	 				where isnull(cgl.xunjialist,0)>0 and caigou.del not in (2,7) and caigou.sp not in (-1) 
	 				group by cgl.xunjialist
				) c on c.xunjialist=a.id 
				group by a.xunjia,a.id 
				)x 
				GROUP BY x.xunjia
		) s  on s.xunjia=xj.id
      WHERE     xj.id = @ord
    )

GO
--��Ʊ�ƻ���ӡģ��-������Ϣ
CREATE FUNCTION [dbo].[FUN_InvoiceTemplateData] ( @ord INT )
RETURNS TABLE
AS
 RETURN
    ( 
		SELECT 
		--������Ϣ
		p.BH AS 'po_order1',--��Ʊ�ƻ����
		s.sort1 AS 'zb_invoice',   --Ʊ������
		P.date7 AS 'zb_tjdate',--���ʱ��
		(case pis.Status 
			when -1 then '��������'
			when 0 then '����δͨ��'   
			when 1 then '����ͨ��' 
			when 2 then '�����˻�_����ֹ'   
			when 3 then '���ύ����'
			when 4 then '������'
			when 5 then '������' end ) AS 'zb_kpsqstatus',--��Ʊ����״̬
		p.invoiceNum AS 'Invoice number',   --Ʊ�ݵ���
		sb.sort1 AS 'zb_bz',--����		
		sqperson.name AS 'zb_sqperson',--������Ա
		p.date1 AS 'zb_ykdate',   --Ӧ������
		p.money1 AS 'zb_ykmoney',--Ӧ�����				
		kpgt.name AS 'zb_hkperson',   --��Ʊ��Ա
		p.invoiceDate AS 'zb_skdate',   --ʵ������
		isnull(pis.Money1,0) AS 'zb_skmoney',--ʵ�����
		(CASE ISNULL(ct.invoiceMode,0) WHEN 2 THEN '' ELSE CONVERT(VARCHAR(50),dbo.formatNumber(ISNULL(p.taxRate,0) ,sj3.num1,0)) + '%' END) AS 'zb_tax_rate',   --˰��
		(CASE p.invoiceMode WHEN 1 THEN  p.money1 - p.money1/(1 + ISNULL(ic.taxRate,0)/100) * ISNULL(ic.taxRate,0)/100 
		ELSE  pl.taxMoney1 END)  AS 'zb_Amount',   --���
		(CASE p.invoiceMode WHEN 1 THEN p.money1/(1 + ISNULL(ic.taxRate,0)/100) * ISNULL(ic.taxRate,0)/100 
		ELSE  pl.taxMoney2 END) AS 'zb_Taxes',   --˰��
		p.intro AS 'zb_intro',   --��ע
		--��Ʊ��Ϣ
		p.title AS 'zb_firm',   --��˾����
		p.taxno AS 'zb_Tax',   --˰��
		p.addr AS 'zb_firm_adress',   --��˾��ַ
		p.phone AS 'zb_firm_phone',   --��˾�绰
		p.bank AS 'zb_firm_bank',   --������
		p.account AS 'zb_bank_account',   --�������˺�
		--�����ͻ�
		t.name AS 'zb_company',   --�ͻ�����
		t.khid AS 'zb_code',   --�ͻ����
		t.faren AS 'zb_faren',   --���˴���
		t.phone AS 'zb_kphone',   --�ͻ��칫�绰
		t.fax AS 'zb_kfax',   --�ͻ�����
		t.email AS 'zb_kemail',   --�ͻ�����
		t.address AS 'zb_address',   --�ͻ���ַ
		t.zip AS 'zb_zip',   --�ͻ��ʱ� 
		--������ͬ
		ct.title AS 'zb_ht_title',   --��ͬ����
		ct.htid AS 'zb_order1',   --��ͬ���
		sth.sort1 AS 'zb_ht_sort',   --��ͬ����
		sth1.sort1 AS 'zb_zxstatus',   --ִ��״̬
		ISNULL(ct.money1,0) AS 'pro_allmoney1',   --��ͬ�ܶ�
		ISNULL(kp.money1,0) AS 'zb_ht_realmoney',   --ʵ�����
		--������Ա
		sale.name AS 'sales_name',   --����������
		sale.phone1 AS 'sales_phone',   --�����˵绰
		sale.fax AS 'sales_tax',   --�����˴���
		sale.mobile AS 'sales_mobile',   --�������ֻ�
		sale.email AS 'sales_email',   --�������ʼ�
		sale1.Name AS 'sales_branch',   --�����˲���
		--�������Ϣ
		addcate.name AS 'person_name',   --���������
		addcate.phone1 AS 'person_phone',   --����˵绰
		addcate.fax AS 'person_tax',   --����˴���
		addcate.mobile AS 'person_mobile',   --������ֻ�
		addcate.email AS 'person_email',   --������ʼ�
		addcate1.Name AS 'person_branch'   --����˲���
		 FROM dbo.paybackInvoice p
		 LEFT JOIN PaybackInvoiceSure pis on p.InvoiceSureId=pis.ID and pis.Del=1
		 LEFT JOIN gate sqperson on pis.Creator=sqperson.ord
		 LEFT JOIN sortonehy s on s.ord=p.invoicetype
		 LEFT JOIN tel t ON t.ord = p.company AND t.sort3 = 1
		 LEFT JOIN dbo.contract ct ON p.fromType = 'CONTRACT' AND p.fromId = ct.ord
		 LEFT JOIN (SELECT fromId AS contract , SUM(money1) AS money1  FROM paybackInvoice 
					WHERE fromType = 'CONTRACT' AND del=1 AND isInvoiced IN (1,2) GROUP BY fromId
				) kp ON kp.contract = ct.ord 
		 LEFT JOIN gate sale ON p.cateid = sale.ord
		 LEFT JOIN gate addcate ON p.addcate = addcate.ord
		 LEFT JOIN dbo.sortonehy sth ON ct.sort = sth.ord AND sth.gate2=31
		 LEFT JOIN dbo.sortonehy sth1 ON ct.complete1 = sth1.ord AND sth1.gate2=32
		 LEFT JOIN sortbz sb ON sb.id=p.bz
		 LEFT JOIN dbo.orgs_parts sale1 ON sale.orgsid = sale1.ID
		 LEFT JOIN dbo.orgs_parts addcate1 ON addcate.orgsid = addcate1.ID
		 LEFT JOIN invoiceConfig ic ON p.invoiceType = ic.typeId
		 LEFT JOIN (
				SELECT l.paybackInvoice ,ISNULL(sum(isnull(cl.taxRate,0)),0) as taxRate,
				ISNULL(sum((l.money1/(1+cl.taxRate/100))),0) taxMoney1,
				ISNULL(sum((l.money1-((l.money1)/(1+cl.taxRate/100)))),0)  taxMoney2 
				FROM paybackInvoice_list l
				left join contractlist cl on cl.id=l.contractlist and l.contractlist>0 and isnull(cl.invoicetype,0)>0 
				WHERE l.contractlist<>0 and isnull(l.money1,0)<>0 
				GROUP BY l.paybackInvoice
			) pl ON pl.paybackInvoice = p.id
		LEFT JOIN gate kpgt ON p.invoiceCate = kpgt.ord
		LEFT JOIN setjm3 sj3 ON sj3.ord = 1
		 WHERE p.id = @ord
    )

GO
--��Ʊ�ƻ���ӡģ��-��ϸ
CREATE FUNCTION [dbo].[FUN_InvoiceDetailTemplateData] ( @ord INT )
RETURNS TABLE
AS
 RETURN
    ( 
		select top 1000000000 * from( 
			SELECT 
			NULL as '#ProductList#',
			0 AS 'sortnum',--���
			p.title AS 'pro_name',   --��Ʒ����
			p.order1 AS 'pro_order1',   --��Ʒ���
			p.type1 AS 'pro_type',   --��Ʒ�ͺ�
			sth.sort1 AS 'pro_unit',   --��Ʒ��λ
			ISNULL(pl.num1,0) AS 'kp_num',   --����
			pl.Price1 AS 'pro_price_ws',--δ˰����
			CONVERT(VARCHAR(50),dbo.formatNumber(ISNULL(cl.taxRate,0) ,sj3.num1,0)) + '%' AS 'zb_tax_rate1',	--˰��
			isnull((pl.money1-((pl.money1)/(1+(cl.taxRate/100)))),0) AS 'zb_mx_Taxes',   --˰��
			isnull((pl.money1/(1+(cl.taxRate/100))),0) AS 'zb_mx_Amount',   --���
			ISNULL(pl.money1,0) AS 'zb_plan_fpmoney',   --�ƻ���Ʊ���
			CASE WHEN pv.isInvoiced IN(0,3) THEN 0 WHEN pv.isInvoiced IN(1,2) THEN ISNULL(pl.money1,0) ELSE 0 END AS 'zb_real_fpmoney',   --ʵ�ʿ�Ʊ���
			cl.intro,--��ϸ��ע
			cl.id,cl.date7
		FROM dbo.paybackInvoice_list pl
		INNER JOIN dbo.paybackInvoice pv ON pl.paybackInvoice = pv.id
		LEFT JOIN contractlist cl on cl.id=pl.contractlist and pl.contractlist>0 
		LEFT JOIN product p on p.ord=pl.product and p.del=1 
		LEFT JOIN dbo.sortonehy sth ON p.unitjb = sth.ord AND sth.gate2 = 61
		LEFT JOIN setjm3 sj3 ON sj3.ord = 1
		where pl.contractlist<>0 and pl.paybackInvoice=@ord and pl.money1>0)t
		order by t.id,t.date7
    )

GO

CREATE FUNCTION [dbo].[FUN_PayBackTemplateData](@ord INT)
RETURNS TABLE
AS 
RETURN(
	SELECT 
		1 AS 'sortnum',   --���
		sb.sort1 AS 'zb_bz',   --����
		p.date1 AS 'zb_hkdate',   --Ӧ������
		p.money1 AS 'zb_hkmoney',   --�ؿ���
		(CASE p.complete WHEN 1 THEN 'δ�տ�'
		WHEN 2 THEN '�׵�����'
		WHEN 3 THEN '���տ�' END) AS 'zb_hkstatus',   --�տ�״̬
		p.date2 AS 'zb_dddate',   --�׵�����
		(CASE p.complete WHEN 3 THEN ISNULL(p.money1,0) ELSE 0 END) AS 'zb_cnhkmoney',   --ʵ�ս���д
		gtop.name AS 'zb_hkperson',   --�տ���Ա
		gtop.name AS 'zb_hkperson_signet',   --�տ���Աǩ��
		p.op AS 'zb_hkperson_signet_SignImageUserId',
		p.date5 AS 'zb_hkperson_signet_SignImageDate', 
		p.date5 AS 'zb_shdate',   --ʵ������
		sth2.sort1 AS 'zb_hktype',   --�տʽ
		sbk.sort1 AS 'zb_Bank',   --�տ��˻�
		sbk.intro AS 'zb_Account',   --�տ��˺�
		p.intro AS 'zb_intro',   --��ע
		pl.money1 AS 'zb_yhmoney',	--�Żݽ��
		t.name AS 'zb_company',   --�ͻ�����
		t.khid AS 'zb_code',   --�ͻ����
		t.faren AS 'zb_faren',   --���˴���
		t.phone AS 'zb_kphone',   --�ͻ��칫�绰
		t.fax AS 'zb_kfax',   --�ͻ�����
		t.email AS 'zb_kemail',   --�ͻ�����
		t.address AS 'zb_address',   --�ͻ���ַ
		t.zip AS 'zb_zip',   --�ͻ��ʱ�
		ISNULL(ct.ord,0) AS contract,
		ct.title AS 'zb_ht_title',   --��ͬ����
		ct.htid AS 'zb_order1',   --��ͬ���
		sth.sort1 AS 'zb_ht_sort',   --��ͬ����
		sth1.sort1 AS 'zb_zxstatus',   --ִ��״̬
		ISNULL(ct.money1,0) AS 'pro_allmoney1',   --��ͬ�ܶ�
		ISNULL(ss.money1,0) AS 'zb_ht_realmoney',   --ʵ�ս��
		ISNULL(ct.money1,0)- ISNULL(th.thmoney,0) - ISNULL(ss.money1,0) AS 'pro_symoney',   --ʣ��Ӧ��
		CASE WHEN ISNULL(ss.money2,0) =0 THEN 'δ�ؿ�' 
			WHEN ISNULL(ss.money2,0)<ISNULL(ct.money1,0)- ISNULL(th.thmoney,0) THEN '�ؿ���'
			WHEN ISNULL(ss.money2,0)>ISNULL(ct.money1,0)- ISNULL(th.thmoney,0) THEN '�ƻ��ؿ���ͬ��'
			WHEN ISNULL(ss.money1,0)<ISNULL(ct.money1,0)- ISNULL(th.thmoney,0) THEN '�ؿ���'
			WHEN ISNULL(ss.money1,0)>ISNULL(ct.money1,0)- ISNULL(th.thmoney,0) THEN 'ʵ�ʻؿ���ͬ��'
			WHEN ISNULL(ss.money1,0)=ISNULL(ct.money1,0)- ISNULL(th.thmoney,0) THEN '�ؿ����'
		end AS 'zb_skstatus',   --�տ�״̬
		sale.name AS 'sales_name',   --����������
		sale.ord AS 'sales_name_id',
		sale.phone1 AS 'sales_phone',   --�����˵绰
		sale.fax AS 'sales_tax',   --�����˴���
		sale.mobile AS 'sales_mobile',   --�������ֻ�
		sale.email AS 'sales_email',   --�������ʼ�
		sale1.Name AS 'sales_branch',   --�����˲���
		addcate.name AS 'person_name',   --���������
		addcate.ord AS 'person_name_id',
		ISNULL(p.date1,p.date7) AS 'signimage_date',
		addcate.phone1 AS 'person_phone',   --����˵绰
		addcate.fax AS 'person_tax',   --����˴���
		addcate.mobile AS 'person_mobile',   --������ֻ�
		addcate.email AS 'person_email',   --������ʱ�
		addcate1.Name AS 'person_branch'   --����˲���
	 FROM dbo.payback p WITH(NOLOCK)
	 LEFT JOIN tel t WITH(NOLOCK) ON p.company = t.ord
	 LEFT JOIN dbo.contract ct WITH(NOLOCK) ON p.contract = ct.ord
	 LEFT JOIN (SELECT [contract] , SUM(CASE complete WHEN 3 THEN money1 ELSE 0 end) AS money1, SUM(money1) AS money2
				 FROM payback WITH(NOLOCK) WHERE del=1 GROUP BY [contract]
				) ss ON ss.contract = ct.ord 
	 LEFT JOIN (select l.contract ,ISNULL(sum(d.money2),0) as thmoney 
					FROM contractthListDetail d  WITH(NOLOCK)
					INNER join contractlist l WITH(NOLOCK) on l.id=d.contractlist 
					INNER join contractthlist tl WITH(NOLOCK) on tl.id=d.contractthlist 
					INNER join contractth ct WITH(NOLOCK) on ct.ord=tl.caigou and ct.del=1 and ct.sp=0 
					WHERE d.del=1 and d.thtype = 'GOODS' GROUP by l.contract
				) th ON th.contract = ct.ord
	 LEFT JOIN dbo.sortonehy sth WITH(NOLOCK) ON ct.sort = sth.ord AND sth.gate2=31
	 LEFT JOIN dbo.sortonehy sth1 WITH(NOLOCK) ON ct.complete1 = sth1.ord AND sth1.gate2=32
	 LEFT JOIN dbo.sortonehy sth2 WITH(NOLOCK) ON p.pay = sth2.ord AND sth2.gate2=33
	 LEFT JOIN gate sale WITH(NOLOCK) ON p.cateid = sale.ord
	 LEFT JOIN gate addcate WITH(NOLOCK) ON p.addcate = addcate.ord
	 LEFT JOIN dbo.orgs_parts sale1 WITH(NOLOCK) ON sale.orgsid = sale1.ID
	 LEFT JOIN dbo.orgs_parts addcate1 WITH(NOLOCK) ON addcate.orgsid = addcate1.ID
	 LEFT JOIN dbo.sortbz sb WITH(NOLOCK) ON ct.bz = sb.id
	 LEFT JOIN dbo.sortbank sbk WITH(NOLOCK) ON p.bank = sbk.id
	 LEFT JOIN dbo.gate gtop WITH(NOLOCK) ON p.op = gtop.ord
	 LEFT JOIN (SELECT payback,SUM(money1) money1 FROM paybackList WITH(NOLOCK) 
		WHERE del=1 AND ISNULL(contractlist,0)=0 GROUP BY payback) pl ON pl.payback=p.ord
	 WHERE p.ord = @ord
)

GO

CREATE FUNCTION [dbo].[F_GetSupplierArea]
    (
      @areaid INT,
      @type INT --1����id��2������������
    )
RETURNS VARCHAR(50)
AS
BEGIN
DECLARE @result VARCHAR(50),@count INT
SET @count = 1
WHILE(@areaid > 0 AND @count <= 10000)
BEGIN
	SELECT @result = id,@areaid = id1 FROM menuarea WHERE id = @areaid
	SET @count = @count + 1
END
IF(@type = 2)
BEGIN
	SELECT @result = menuname FROM  menuarea WHERE id = @result
END
RETURN @result
END

GO

CREATE FUNCTION [dbo].[F_HrKQ_JoinImagePath]
    (
      @RecordID INT
    )
RETURNS VARCHAR(8000)
AS
BEGIN
   DECLARE @returns VARCHAR(8000);
   SET @returns = '';
	BEGIN
           SELECT  @returns = @returns + '*#*' + ImagePath
           FROM    HrKQ_AttendanceImage
           WHERE  RecordID = @RecordID
    END
    RETURN STUFF(@returns, 1, 3, '');
END

GO
--��ֹ�ظ�������ϣ����ڲ�ѯ����״̬
create function [dbo].[erp_list_MMOl_repeat](
	@billID int
)
returns table as return
(
	select ID as WAListID,productID,unit,sum(n) as ������,sum(n2) as �ƻ��� from (
		select	a.ID, a.productID,a.unit,	isnull(x.num1,0) as n,	a.num1 as n2
		from M_WorkAssignLists a
		inner join M_WorkAssigns b on a.WAID=b.ID and b.status=3
		left join (
			select abs(c.WAID) waid,d.WAListID,sum(d.num1) num1 
			from
			M_MaterialOrders c 
			inner join M_MaterialOrderlists d on c.poType = 0 and c.del=0 and c.id = d.MOID and d.del=0
			where c.id <> @billID
			group by waid,d.WAListID
		) x on x.waid = a.WAID and x.WAListID = a.ID
		where a.WAID = (select abs(WAID) from M_MaterialOrders where id =@billID)
		and (select abs(poType) from M_MaterialOrders where id =@billID) = 0 
		union all
		select a.ID, a.productID, a.unit,	0 as n,	a.num as n2
		from M_OutOrderLists_WL a 
		inner join M_OutOrder b on a.outID=b.ID and b.status=3
		where a.outID = (select abs(WAID) from M_MaterialOrders where id =@billID and poType=1)
		union all
		select WAListID,productid,	unit,
		num1*(case zz.OrderType when 1 then 1 when 2 then -1 when 3 then -1 when 4 then -1 end) as num1 ,
		0 as n2
		from M_MaterialOrderLists xx
		left join (
				select id,sum(num1) n from (
					select a.id ,b.num1 from M_MaterialOrderLists a
					inner join kuinlist b on a.ID = b.MOrderID
					inner join kuin c on c.ord = b.kuin and c.complete1 = 3 and c.del=1
					union all
					select a.id, b.num1 from M_MaterialOrderLists a
					inner join kuoutlist2 b on a.ID = b.MOrderID
					inner join kuout c on c.ord = b.kuout and c.complete1 = 3 and c.del = 1
				) tt group by id

		) yy on xx.id = yy.id
		inner join M_MaterialOrders zz on zz.ID = xx.MOID and zz.ID<>@billID and zz.del=0 and zz.OrderType <> 1
			and zz.WAID = (select abs(WAID) from M_MaterialOrders where id =@billID) 
		where zz.poType = (select abs(poType) from M_MaterialOrders where id =@billID)
	) x group by ID,productID ,unit having sum(n2)-sum(n) > 0
)

GO

--������㵱������
Create function [dbo].[erp_inventory_DataByMonth](
	@uid INT,
	@date1 VARCHAR(20),
	@ctype INT --�Ƿ���Ҫ���ղ�Ʒ�Ƽ۷�ʽ��ʾ����
) returns TABLE
AS RETURN ( 
	--�ڳ���� = ������ĩ���
	SELECT DATEADD(mm,1,ic.date1) AS date1 ,DATEADD(mm,1,ic.date1) AS date2,
		cl.num4 AS num1,	 
		CASE WHEN (p1.priceMode=2 AND @ctype=1) OR @ctype=0 THEN cl.price4 ELSE ku.price1 END AS price1,
		CASE WHEN (p1.priceMode=2 AND @ctype=1) OR @ctype=0 THEN cl.money4 ELSE ku.price1*cl.num4 END AS money1,
		ISNULL(kt.num2,0) AS num2,
		ISNULL(kt.price2,0) AS price2,
		ISNULL(kt.money2,0) AS money2,
		cl.ord,cl.unit ,cl.ck , cl.kuid ,cl.dataType , 0 AS currDataType
	FROM inventoryCostList cl
	INNER JOIN inventoryCost ic ON ic.id = cl.Costid and ic.complete1 >= 1
	INNER JOIN ku ON ku.id = cl.kuid AND (cl.num4<>0 OR cl.dataType=100)
	INNER JOIN product p1 ON p1.ord = ku.ord
	LEFT JOIN (
		--���ڶԳ�����
		SELECT kh.kuid , 
		SUM(ISNULL(kh.num1,0)) AS num2, 
		CASE WHEN SUM(ISNULL(kh.num1,0)) = 0 THEN 0 ELSE cast(ISNULL(SUM(kh.num1*convert(decimal(25, 12),ROUND(REPLACE(kl.price1,',',''),12))),0) as decimal(25,12))/SUM(ISNULL(kh.num1,0)) END AS price2,
		ISNULL(SUM(kh.num1*convert(decimal(25, 12),ROUND(REPLACE(kl.price1,',',''),12))),0) money2
		FROM kuhclist kh 
		inner join kuinlist kl on kh.kuinlist=kl.id
		inner join kuin ki on ki.ord=kl.kuin AND ki.del=1
		WHERE kh.del=1 AND DATEDIFF(mm,ki.[date5],@date1)=0 
		GROUP BY kh.kuid
	) kt ON kt.kuid = cl.kuid
	WHERE DATEDIFF(mm,ic.date1,@date1)=1
	UNION ALL
	--������ 
	--1.�ɹ���⣬2.�˻���⣬3.������⣬4.ֱ����⣬5.��Ʒ��� ��6.������� ��7.������� ��8.�̵���� ��
	--9.��װ��� �����⣬11.������� ��13.���Ʒ���
	SELECT ku.daterk,CONVERT(VARCHAR(10),DATEADD(dd,1-DAY(ku.daterk),ku.daterk),120) AS date2,
		0,0,0,
		isnull((CASE WHEN kl.id>0 THEN ku.num3 ELSE dc.num1 END),0) AS num2,
		isnull((CASE WHEN kl.id>0 THEN 
			(CASE WHEN ((p1.priceMode=2 AND @ctype=1) OR @ctype=0) AND ki.sort1 IN (3,6,7,13,15,16)
				THEN kl.priceMonth else convert(decimal(25, 12),ROUND(REPLACE(kl.price1,',',''),8)) END)
		 ELSE dc.price1 
		 END),0) AS price2,
		isnull((CASE WHEN kl.id>0 THEN 
			(CASE WHEN ((p1.priceMode=2 AND @ctype=1) OR @ctype=0) AND ki.sort1 IN (3,6,7,13,15,16)
				THEN kl.priceMonth else convert(decimal(25, 12),ROUND(REPLACE(kl.price1,',',''),8)) END)*ku.num3 
		ELSE dc.money1 
		END),0) AS money2,
		ku.ord,ku.unit,ku.ck,ku.id ,ISNULL(ki.sort1,100) AS dataType ,1 AS currDataType
	FROM ku
	INNER JOIN product p1 ON p1.ord = ku.ord
	left JOIN kuinlist kl ON kl.id = ku.kuinlist AND (kl.del=1 OR kl.del=99)
	left JOIN kuin ki ON ki.ord = kl.kuin      --AND ki.sort1 IN (1,4,5,8,9,11,13,14,15) ���ٿ��ǲ����������
	LEFT JOIN (--�Գ��¼(������)(���ڶԳ�)	
		select kh.kuid,SUM(kh.num1) AS num1 , 
		CASE WHEN SUM(ISNULL(kh.num1,0)) = 0 THEN 0 ELSE cast(ISNULL(SUM(kh.num1*convert(decimal(25, 12),ROUND(REPLACE(kl.price1,',',''),12))),0) as decimal(25,12))/SUM(ISNULL(kh.num1,0)) END AS price1,
		SUM(ISNULL(kh.num1,0)*isnull(convert(decimal(25, 12),ROUND(REPLACE(kl.price1,',',''),12)),0)) AS money1
		FROM kuhclist kh
		inner join kuinlist kl on kh.del=1 AND kh.kuinlist=kl.id AND DATEDIFF(mm,kl.[dateadd],@date1)=0
		inner join kuin ki on ki.ord=kl.kuin
		GROUP BY kh.kuid
	) dc ON dc.kuid = ku.id
	WHERE DATEDIFF(mm,ku.daterk,@date1)=0
)

GO

Create function [dbo].[erp_topmenudatas](
	@uid int, @sn varchar(40)
) RETURNS TABLE 
AS RETURN (
	select ID,clsName as title,'''' as url , 0 as mtype , sort , 0 as otype, pid,'''' as ModelExpress from home_topmenu_cls_us
	where uid = @uid and stop = 0
	union all
	select ID,clsName,'''' as url , 0 as mtype, sort,0, pid,'''' as ModelExpress  from home_topmenu_cls_us a
	where uid = -100 and stop = 0 and  not exists(select 1 from  home_topmenu_cls_us b where b.uid=@uid and b.ID=a.ID)
	union all
	select ID,clsName,'''' as url , 0 as mtype, sort,0, pid,'''' as ModelExpress from home_topmenu_cls_def a
	where a.usign = @sn and not exists(select 1 from  home_topmenu_cls_us b where  b.ID=a.ID and (b.uid=@uid or b.uid=-100))
	union all
	select  x.ID , title, isnull(url,'''') as url, 1 as mtype, x.sort,otype,cls,ModelExpress
	from (
		SELECT ID,title,url,ID as sysID,qxlb,qxlist,otype , 0 as stop,sort,a.cls,a.ModelExpress 
		FROM home_topmenu_item_def a where a.usign = @sn and not exists
			(select sysId from home_topmenu_item_us b  where b.id=a.id and (b.uid=@uid or b.uid=-100) )
		union all
		SELECT a.ID,a.title,a.url,a.sysID,0 as qxlb,0 as qxlist,a.otype,0 as stop, a.sort,a.cls,a.ModelExpress
		FROM home_topmenu_item_us a where ID>10000 and a.stop=0 and uid=@uid
		union all
		SELECT a.ID,a.title,a.url,a.sysID,b.qxlb,b.qxlist,a.otype,0 as stop,a.sort,a.cls,a.ModelExpress FROM home_topmenu_item_us a
		inner join home_topmenu_item_def b on a.ID=b.ID and a.ID<10000 where a.stop=0 and uid=@uid and b.usign = @sn
		union all
		SELECT a.ID,a.title,a.url,a.sysID,b.qxlb,b.qxlist,a.otype,0 as stop,a.sort,a.cls,a.ModelExpress FROM home_topmenu_item_us a
		inner join home_topmenu_item_def b on a.ID=b.ID and a.ID<10000 where  a.stop=0 and uid=-100 and b.usign = @sn and
		not exists(select 1 from home_topmenu_item_us c where c.id=a.ID and uid=@uid)
	) x where isnull(x.qxlb,0)=0  or  (
		exists(
			select top 1 1 as r from power y
			where x.qxlb = y.sort1 and x.qxlist = y.sort2 and y.sort2<>19 and (y.qx_open=1 or y.qx_open=3) and y.ord=@uid
		)
		and not exists(
			select top 1 1 as r from power y
			where x.qxlb = y.sort1 and y.sort2 = 19 and y.qx_open=1 and y.ord=@uid
		)
	)
)

GO

create function [dbo].[GetGates](
 @ords varchar(8000)
) returns varchar(8000)
as
begin
	declare @ret varchar(8000)
	if ISNULL(@ords,'')=''
		set @ret = ''
	else
	begin
		if CHARINDEX('|',@ords)>0
		begin
			select top 1 @ret=short_str from dbo.split(@ords,'|') order by ID desc
		end
	end
	return @ret
end
GO

Create function [dbo].[Get_ZXGXInfo] (@id int) 
returns table            
as            
return            
( 
  select M2WFPA.WAID,M2WA.Creator CreatorID,g.name as creator,
	(case 
		when isnull(M2WFPA.oldNumMake,0)>0 
		then M2WP.WPName+ isnull(CASE WHEN ISNULL(M2WFPA.isOut,0) = 0 THEN ' (' +(M2MD.Name+'--'+M2WC.WCName) + ')' ELSE '' END,'')
		else M2WP.WPName+ isnull(CASE WHEN ISNULL(M2WFPA.isOut,0) = 0 THEN ' (' +(M2MD.Name+'--'+M2WC.WCName) + ')' ELSE '' END,'')
	end)
	WPName,M2WA.inDate,M2WA.Cateid_WA as properson,M2WFPA.cateid zpcateid,(CASE ISNULL(pro.del,99) WHEN 1 THEN pro.title WHEN 2 THEN pro.title+'<font color=red>(��ɾ��)</font>' WHEN 99 THEN '<font color=red>��Ʒ�ѳ���ɾ��</font>' END) as proname, pro.order1,pro.type1,           
    isnull(Nums.execStatus_tit,case M2WFPA.isOut when 0 then 'δִ��' else 'δ���' end) as WPprostatus,
	(case isnull(M2WFPA.isOut,0) 
		when 1 then 'ί��' 
		when 0 then '����' 
	end) as protype, 
	isnull(M2WFPA.NumMake,0) NumMake,
	isnull(M2WFPA.wtime,0) wtime,
	(case isnull(M2WFPA.unit,0) 
		when 0 then '��' 
		when 1 then '����' 
		else 'Сʱ' 
	end) unit,          
    isnull(Nums.hgsl,0) as hgnum,            
    isnull(Nums.fgsl,0) as fgnum,            
    isnull(Nums.bfsl,0) as bfnum,            
    convert(varchar(50),M2WFPA.DateStart,23) DateStart,
    convert(varchar(50),M2WFPA.DateEnd,23) DateEnd,            
    case isnull(Nums.isOut,0) when 0  THEN CASE WHEN   CONVERT(varchar(50),Nums.startDate,23)='1900-01-01'THEN NULL else  convert(varchar(50),Nums.startDate,20) end ELSE CASE WHEN   CONVERT(varchar(50),Nums.startDate,23)='1900-01-01'THEN NULL else  CONVERT(varchar(50),Nums.startDate,23) end END as trueDateStart,            
    case isnull(Nums.isOut,0) when 0  THEN CASE WHEN   CONVERT(varchar(50),Nums.endDate,23)='1900-01-01'THEN NULL else convert(varchar(50),Nums.endDate,20) end ELSE CASE WHEN  convert(varchar(50),Nums.endDate,23)='1900-01-01' THEN NULL ELSE convert(varchar(50),Nums.endDate,23) end  end as trueDateEnd,                       
	M2WFPA.remark,M2WA.title,M2WFPA.ID as BarCode,isnull(M2WA.ptype,0) ptype ,M2WFPA.Finished
    ,M2WFPA.IntermediateProduct                      
	from M2_WFP_Assigns M2WFPA with(nolock)            
	left join M2_WorkAssigns M2WA with(nolock) on M2WFPA.WAID = M2WA.ID and M2WA.del = 1 and M2WA.tempSave = 0                                      
	left join M2_WorkingCenters M2WC with(nolock) on M2WC.ID = M2WFPA.WCenter and M2WC.del = 1 
	left join M2_MenuDepartment M2MD with(nolock) on M2WC.Department = M2MD.ID                   
	left join M2_WorkingProcedures M2WP with(nolock) on M2WFPA.WPID = M2WP.ID and M2WP.del =1            
	left join [erp_ProcedureProgresNums] Nums with(nolock) on M2WFPA.ID = Nums.WFPAID          
	left join gate g with(nolock) on g.ord = M2WA.Creator and g.del = 1            
	left join product pro with(nolock) on M2WA.ProductID = pro.ord  where M2WFPA.ID = @id
	and M2WFPA.del=1       
)  

GO

--��ȡ���п���Ѿ�ת���������λ������
Create function [dbo].[erp_store_StockData](
	@uid int,			-- ��ǰ������ 	
	@ord int,			-- ��ƷOrd
	@unit int,			-- ��λID
	@cks varchar(8000), -- �ֿ�IDs
	@ext varchar(4000) -- ��չ����(����,��ǰ׺ʹ��)
) RETURNS table
as return (
	--���п��(��Ʒ���е�λ)
	select p.ord , r.unit , r.Bl , --��λת������(���������λ)
		c.currnum , 
		r.[isDefault] ,isnull(rn.Bl,1) as DefBl,
		(case when isnull(rn.Bl,1) = 0 then 0 else cast(isnull(c.currnum,0)*r.Bl as decimal(25,12))/isnull(rn.Bl,1) end) as CvtNum --ת������λ����
	from product p
	inner join erp_comm_unitRelation r on r.ord = p.ord
	inner join erp_comm_unitRelation rn on rn.ord = p.ord and rn.[isDefault] =1 
	left join (
			select k.ord , k.unit , SUM(k.num2) as currnum 
			from ku k 
			inner join sortck s on s.ord = k.ck
			where (LEN(isnull(@cks,''))=0 
						and (cast(s.intro as varchar(1))='0' 
								or charindex(',' + cast(@uid as varchar(20)) + ',',',' + cast(s.intro as varchar(7990)) + ',') > 0)
				)		
				or charindex(','+cast(k.ck as varchar(10)) + ',' , ','+ replace(CAST(@cks as varchar(8000)) ,' ','') +',' )>0
			group by k.ord , k.unit 
		) c on c.ord = p.ord and c.unit = r.unit
	where p.del=1 and (@ord = 0 or p.ord =@ord ) and (@unit = 0 or r.unit = @unit) 
)

GO

create function [dbo].[PadLeft](@num varchar(16),@paddingChar char(1),@totalWidth int)  
returns varchar(16) as  
begin  
declare @curStr varchar(16)  
select @curStr = isnull(replicate(@paddingChar,@totalWidth - len(isnull(@num ,0))), '') + @num  
return @curStr  
end  

GO

CREATE FUNCTION [dbo].[GetKHName]
(@str nvarchar(max), --�ַ���
@spliter nvarchar(10))
returns nvarchar(max)--���ع���õ�KHname
AS 
BEGIN 
DECLARE @Result nvarchar(max)
DECLARE @KHName nvarchar(64)
DECLARE @Num int
DECLARE @Pos int
DECLARE @NextPos int
SET @Num = 0 
SET @Pos = 1 
SET @Result=''
 WHILE(@Pos <= LEN(@str)) 
 BEGIN 
  SELECT @NextPos = CHARINDEX(@spliter, @str, @Pos)
  IF (@NextPos = 0 OR @NextPos IS NULL) 
  SELECT @NextPos = LEN(@str) + 1
SELECT @KHName=[NAME] FROM dbo.tel WHERE [ord]=RTRIM(LTRIM(SUBSTRING(@str, @Pos, @NextPos - @Pos)))
  
  SET @Result = @Result + @KHName +','
  SELECT @Pos = @NextPos+1 
 END
 IF(LEN(@Result)>0)
 BEGIN
 SET @Result = SUBSTRING(@Result,0,LEN(@Result))
 END
RETURN @Result
END

GO



CREATE FUNCTION [dbo].[GetMYQXKH]
(  
@str nvarchar(max), --�ַ���  
@spliter nvarchar(10),  
@createID int,  
@uid int  
)  
returns nvarchar(max)--���ع���õ�KHname  
AS   
BEGIN   
DECLARE @ResultID nvarchar(max)  
DECLARE @Num int  
DECLARE @Pos int  
DECLARE @NextPos int  
declare @DDDetail int  
declare @isshare int  
declare @myord varchar(100)  
SET @Num = 0   
SET @Pos = 1   
SET @ResultID=''  
 WHILE(@Pos <= LEN(@str))   
 BEGIN   
  SELECT @NextPos = CHARINDEX(@spliter, @str, @Pos)  
  IF (@NextPos = 0 OR @NextPos IS NULL)   
  SELECT @NextPos = LEN(@str) + 1  
  select @DDDetail = (case when plist1.qx_open=3 or (plist1.qx_open = 1 and CHARINDEX(',' + cast(tel.cateid as varchar(10))+ ',', ',' + cast(plist1.qx_intro as varchar(8000)) + ',')>0 )   
  then 1 else 0 end)   
  from M2_ManuOrders O 
  LEFT join power per on per.ord = @uid and per.sort1=1 and per.sort2=14 
  left join dbo.power plist1 ON plist1.ord = @uid AND plist1.sort1 = 1 AND plist1.sort2 = 1
  LEFT JOIN tel ON tel.del=1 AND tel.ord=RTRIM(LTRIM(SUBSTRING(@str, @Pos, @NextPos - @Pos)))  
  WHERE O.CREATOR = @createID  
      
   select @isshare = (case when CAST(tel.share AS VARCHAR(10))='1' or CHARINDEX(','+ cast(@uid as varchar(10))+',',','+ cast(tel.share as varchar(8000))+',')> 0   
   then 1 else 0 end)   
   from  tel 
   WHERE  tel.del=1 AND tel.ord=RTRIM(LTRIM(SUBSTRING(@str, @Pos, @NextPos - @Pos)))  
     
  SET @myord = RTRIM(LTRIM(SUBSTRING(@str, @Pos, @NextPos - @Pos)))  
 
  if(@DDDetail = 1 or @isshare = 1)  
  begin   
   set @ResultID = @ResultID + @myord+ ','  
  end  
  SELECT @Pos = @NextPos+1   
 END  
 IF(LEN(@ResultID)>0)  
 BEGIN  
 SET @ResultID = SUBSTRING(@ResultID,0,LEN(@ResultID))  
 END  
RETURN @ResultID  
END 

GO


create function [dbo].[GetOnWorkPerNum]
 (
		@userids varchar(4000),
		@Type int --�������(1:ʵ���ڣ�2��δ����)
) 
 returns int
 begin
	 declare @i int,
		 @p int,
		 @end int, --ѭ����ֹ����
		 @Number int  --ʵ�ʳ�������
     
     set @Number = 0
	 select @end = (case 
							when (select MAX(ord) from gate)>(select MAX(userID) from hr_person) then (select MAX(ord) from gate)
							else (select MAX(userID) from hr_person)
					end)
	 set @p = 1
	 
	 if(@Type = 1)
	 begin
			 while(@p<@end)
			 begin
				 if(exists(select 1 from ( select top 1 * from HrKQ_AttendanceRecord where UserID = @p and YEAR(Date) = YEAR(GETDATE()) and MONTH(Date) = MONTH(GETDATE()) and DAY(Date) = DAY(GETDATE())
				 order by ClockTime desc) tb where tb.ClockTime<GETDATE()) and CHARINDEX(','+CONVERT(varchar(4000),@p)+',',','+@userids+',')>0)
				 begin
					set @Number = @Number + 1
				 end
				 set @p = @p + 1	 
			 end
	 end
	 else
	 begin
			 while(@p<@end)
			 begin
				 if(not exists(select 1 from ( select top 1 * from HrKQ_AttendanceRecord where UserID = @p and YEAR(Date) = YEAR(GETDATE()) and MONTH(Date) = MONTH(GETDATE()) and DAY(Date) = DAY(GETDATE())
				 order by ClockTime desc) tb where tb.ClockTime<GETDATE()) and CHARINDEX(','+CONVERT(varchar(4000),@p)+',',','+@userids+',')>0)
				 begin
					set @Number = @Number + 1
				 end
				 set @p = @p + 1	 
			 end
	 end
	 return Isnull(@Number,0)
 end

GO

create function [dbo].[erp_APS_KQDetails_fun](
	@cx varchar(8000),
	@d1 datetime, 
	@d2 datetime
)
returns table  as return (
with     
 --3.1 ��ѯ�豸Ϊ���������ϸ�� 
 bcdistinct as (
	select distinct x.ParentID,x.PersonGroupID, x.TimeArrangeID     
	from HrKQ_SchedulingDetail x where x.Date>=GETDATE()  
 )
 select     
   t03.����ID,    
   t03.���߹���ID,    
   t03.��λID, t03.��ԱID,    
   t03.d1, t03.d2, t03.��λID,    
   t04.StartDate, t04.EndDate,    
   t03.�����,     
   t03.����ʱ��,    
   (     
    case     
    when t04.AttTypeCls <> 2 and isWork=1 then     
    datediff(s,dbo.maxdatev(t04.StartDate,t03.d1),dbo.mindatev(t04.EndDate,t03.d2))    
    else 0 end    
   )  as ���ʱ��,    
   (     
    case     
    when t04.AttTypeCls = 2 and isWork=0 then     
    datediff(s,dbo.maxdatev(t04.StartDate,t03.d1),dbo.mindatev(t04.EndDate,t03.d2))    
    else 0 end    
   ) as ��Ϣ�ռӰ�,    
   (     
    case     
    when t04.AttTypeCls = 2 and isWork=1 then     
     (    
    (case when d2> t04.EndDate then 0     
      else datediff(s,dbo.maxdatev(t04.StartDate,t03.d2), dbo.mindatev(convert(varchar(10),t03.d2,120)+' 23:59:59',t04.EndDate))    
      end)    
     +        (case when d1<t04.StartDate then 0    
       else datediff(s,dbo.maxdatev(convert(varchar(10),t03.d1,120),t04.StartDate) ,dbo.mindatev(t03.d1,t04.EndDate))    
      end)    
    )    
    else 0 end    
   ) as �����ռӰ�,    
   t04.AttTypeCls, t03.isWork,    
   t03.autoI    
  from (    
   select     
    t02.����ID,    
    t02.���߹���ID,    
    t02.��λID, t02.��ԱID,    
    t02.�����, t02.��λID,    
    datediff(s,dbo.maxv(t01.autoT, t02.d1),dbo.mindatev(t01.autoT2,t02.d2)) as ����ʱ��,    
    t02.isWork,    
    dbo.maxdatev(t01.autoT, t02.d1) as d1,    
    dbo.mindatev(t01.autoT2,t02.d2) as d2,    
    t01.autoI    
   from (
		select yl as AutoT, AutoT2, (autoI-datediff(d, '1900-1-1',@d1) + 1)  as AutoI   
		from nldata where yl>=@d1 and yl<=@d2
   ) t01    
   inner join (    
    select x.ID as ����ID, y.ID as  ���߹���ID , z.ID as ��λID, g.workPosition as ��λID,    
    g.ord as ��ԱID, s.NowMoney*w.Capacity as �����,  --��λ�����*����ϵ��    
    --h.ID as ���ID,     
    --hrg.Date as ����,    
    DATEADD(d, hrc.StartInterDay, hrg.Date) + hrc.SignTime as d1,    
    DATEADD(d, hrc.EndInterDay, hrg.Date) + hrc.SignOutTime as d2,    
    hrg.isWork,    
    mainCapacity as ��������    
    from M2_WorkingProcedures x   --�����������    
    inner join M2_CXProcedureView y on x.ID= y.PID and x.mainCapacity=1 and x.del=1     --���߹�����ͼ    
    inner join M2_CXStationView z on z.PID = y.ID --���߹�λ��ͼ    
    inner join M2_PersonList_WP w on w.StationID = z.ID  --���߹�λ��Ա��    
      and (@cx='-1' or CHARINDEX(','+CAST(w.WCenter as varchar(12)) + ',', ','+@cx+',')>0)     
    inner join gate g on w.ProducePerson = g.ord and (g.del=1 or g.del=3)    
    inner join sortonehy s on g.workPosition = s.ord  --��λ��     
    inner join dbo.HrKQ_PersonGroup h on isnull(h.Disable,0)=0 --������Ա�����    
     and (h.RangeType=0 or CHARINDEX(',' + CAST(g.ord as varchar(12)) + ',', ','+cast(h.Range as varchar(max))+',')>0)    
    inner join (    
     --�Ű���ϸ�������⴦������TimeArrangeID=999999�����    
     select ParentID, PersonGroupID, TimeArrangeID, [Date], 1 as isWork from  HrKQ_SchedulingDetail where Date>=GETDATE() and TimeArrangeID<>999999    
     union all    
     select x001.*,x002.[Date],0 as isWork from (    
      select     
       x1.ParentID,     
       x1.PersonGroupID,     
       y1.TimeArrangeID    
      from bcdistinct x1     
      inner join bcdistinct y1     
      on x1.parentID=y1.parentID     
      and x1.personGroupID=y1.personGroupID    
      and x1.timeArrangeID=999999 and y1.TimeArrangeID<>999999    
     ) x001 inner join HrKQ_SchedulingDetail x002    
     on x001.ParentID = x002.ParentID and x001.PersonGroupID = x002.PersonGroupID    
     and x002.TimeArrangeID=999999    
    ) hrg on  --�Ű���ϸ��    
     charindex(','+cast(h.ID as varchar(12)) +',', ','+ cast(hrg.PersonGroupID as varchar(8000)) + ',')>0    
    inner join HrKQ_Scheduling hrs on hrs.ID =hrg.ParentID  --�Ű�����    
    inner join HrKQ_TimeArrangeDetail hrd on hrd.ID = hrg.TimeArrangeID  --�����ϸ��    
    inner join HrKQ_ClockDetailList hrc on hrc.DetailID = hrd.ID --��ʱ���    
   ) t02 on  (t01.autoT <= t02.d2 and t01.autoT2 >=t02.d1)    
  ) t03     
  left join (    
   select x.ID, z.UserID, x.StartDate, x.EndDate , y.AttTypeCls    
   from HrKQ_AttendanceApply x --���������     
   inner join HrKQ_AttendanceType y on  x.ApplyType=y.ID --���ڹ���    
    and x.StartDate>GETDATE() and y.AttTypeCls>0  --���˴��������Ӱ࣬�Ӱ൥�����㣩    
    and x.isDel = 0 and ISNULL(x.status,1)=1    
   inner join HrKQ_AttendanceApplyRange z on z.ApplyID = x.ID  --����������Ա    
  ) t04 on t03.��ԱID = t04.UserID and      
   (     
   (t04.AttTypeCls<>2 and (t03.d1 <= t04.EndDate and t03.d2 >=t04.StartDate))    
   or    
   (t04.AttTypeCls=2 and ( convert(varchar(10),t03.d1,120) <= t04.EndDate and convert(varchar(10),t03.d1,120)+' 23:59:59' >=t04.StartDate))    
   )    
 ) 

GO

CREATE function [dbo].[CXFreePowerList]
(
	@Crash int,
	@cx varchar(8000),
	@d1 datetime,
	@d2 datetime,
	@uid int
)
returns table as
return (
with     
 --3.1 ��ѯ�豸Ϊ���������ϸ�� 
 indextb as (
	select yl as AutoT, AutoT2, (autoI-datediff(d, '1900-1-1',@d1) + 1)  as AutoI   
	from nldata where yl>=@d1 and yl<=@d2
 ),
 �豸Ϊ���������ϸ�� as (    
  select     
   x.ID as ����ID, p.ID as ���߹���ID,  n.ID as ��λID,    
   z.ID as �豸ʵ��ID,     
   t01.autoT, y.MachileID as �豸����ID,    
   z.RatedCapacity as �����,    
   z.LoadCapacity as ���ز���,    
   z.isCrash,    
   t01.mStatus as �豸��Ϣ,    
   datediff(s,    
   (case  abs(sign(datediff(d,t02.d1, t01.autoT))) when 0 then  t02.d1 when 1 then  t01.autoT else NULL end),    
   (case  abs(sign(datediff(d,t02.d2, t01.autoT))) when 0 then  t02.d2 when 1 then  t01.autoT2 else NULL end)    
   )/3600.00 as ά��ʱ��,    
   mainCapacity as ��������,    
   t01.autoI    
  from M2_WorkingProcedures x   --�����������    
  inner join M2_Procedures_MH y on x.mainCapacity=0 and y.WPID = x.ID and x.del=1 and y.del=1   --�����豸��Ϣ    
  inner join M2_MachineList z on y.MachileID = z.MFID and z.del=1 --�豸��ϸ��Ϣ    
   and (z.isCrash=0 or @Crash=1) --����崻����Ƿ����    
  inner join M2_MachineList_WP m on z.ID = m.MachineLID  --�豸��λ��     
  inner join M2_CXStationView n on m.StationID=n.ID and (@cx='-1' or CHARINDEX(','+CAST(n.WCenter as varchar(12)) + ',', ','+@cx+',')>0)   --���߹�λ�� �� �豸�빤λ��    
  inner join M2_CXProcedureView p on p.ID = n.PID and p.pid=x.ID and p.isstop=0 and p.del=1  --���߹����    
  inner join (    
   select c.MachineID, a.autoT, a.autoT2, d.mStatus ,a.autoI  from indextb a     
   inner join M2_MachineCalendar b on a.autoT>=b.begindate and a.autoT<=b.enddate --�豸��������    
   inner join M2_MachineClist c on b.ID=c.MCID       --�豸�����¶�Ӧ���豸    
   inner join M2_MachineCdate d on b.ID=d.MCID and a.autoT = d.mDay  --�豸������ϸ����    
  ) t01 on z.ID = t01.MachineID   --�豸��������    
  left join 
  dbo.M2_MachineTainListView t02 on 1=0 and t02.d1<=@d2   --�豸ά���Ǹ��������ܴ�ӣ�1=0 ��ʾ��ֱ��ȥ��
  and t02.MHLID = z.ID and   (t02.d2>=t01.autoT and  t02.d1<= t01.autoT2 )     
 ),    
 --3.2 ��ѯ��Ա������ܱ�    
 ��Ա���������ϸ�� as     
 (    
  --3.2.1 ����ԱΪ���壬������ϸ��    
  select    
   autoI,����ID,���߹���ID,��λID,��ԱID,��λID,�����,    
   --t05.d1, t05.d2, t05.StartDate, t05.EndDate,  AttTypeCls 2=�Ӱ�����    
   (cast((sum(����ʱ��*isWork)+sum(���ʱ��)+sum(�����ռӰ�)+sum(��Ϣ�ռӰ�)) as decimal(25, 12) )    
   /sum(����ʱ��))*����� as ʵ������    
  from [erp_APS_KQDetails_fun](@cx, @d1, @d2) t05     
  group by ����ID, ���߹���ID,��λID,��ԱID,�����, ��λID, autoI    
  ) ,    
  --3.3 ��Աȡ���ϰ���֮�ͣ��豸ͬ���豸�Ӻͣ���ͬ�豸ȡmin    
 ����ÿ�տ��в��ܱ� as (    
  select     
   AutoI, ����ID, ���߹���ID,     
   MIN(���������)  as ���������,
   MIN(���������)  as ���������,
   0 as ��������    
  from (    
   select AutoI, ����ID, ���߹���ID,     
    SUM(�����) as ���������,
    SUM(���ز���) as ��������� 
   from �豸Ϊ���������ϸ��     
   where �豸��Ϣ=0 and (isCrash=0  or @Crash=1)    
   group by AutoI, ����ID, ���߹���ID    
  ) t002 group by AutoI, ����ID, ���߹���ID    
  union all    
  select      
   autoI, ����ID, ���߹���ID ,    
    SUM(ʵ������) as ���������,
    SUM(ʵ������) as ���������,
     1    
  from ��Ա���������ϸ�� a    
  group by autoI, ����ID, ���߹���ID     
 )    
 --3.5 ��ȡ���߿��б�    
 select     
  autoI,����ID, ���߹���ID, ���������, ���������  
 from ����ÿ�տ��в��ܱ�
)

GO
         
CREATE function [dbo].[erp_comm_BillGXZX](      
	@WFPAID VARCHAR(2000)
) returns table       
as      
return       
	--�ж��ϼ������Ƿ�ϸ�num>0��ʾ��ť��������ʾ    
	select  WFPAtab.ID WFPAID,isnull(WFPAtab.isOut,0)isOut,WCenter,WPID,
		WFPAtab.NumMake,isnull(WFPAtab.result,1) result,
		(case isnull(WFPAtab.isOut,0) when 1 then (isnull(wwtb.wwqulsumnum,0)) when 0 then isnull(zztb.zzsumnum,0) end) num,   
		(case when (case isnull(WFPAtab.isOut,0) 
					when 1 then (isnull(wwtb.wwqulsumnum,0)) 
					when 0 then isnull(zztb.zzsumnum,0) end)>0
			then 1 
		else 0 
		end) sfxs  --����ü���1����Ĭ����ʾ���������ж��ϼ��Ƿ�ϸ���ʾ       
	from (
		select  mwa.* 
		from  M2_WFP_Assigns mwa
		inner join M2_WFP_Assigns twa on CHARINDEX(','+CAST(twa.ID AS VARCHAR(10))+',',','+@WFPAID+',') > 0 and twa.waid = mwa.waid
		where ISNULL(mwa.NumMake,0) > 0 AND mwa.ord = twa.ord-1
	) WFPAtab    
	left join (	
		select M2OOl.WFPAID,SUM(ISNULL(wwqttb.certNum,0)) as wwqulsumnum,
		SUM(ISNULL(wwqttb.fgnum,0)) as wwqtfgnum,
		SUM(ISNULL(wwqttb.bfnum,0)) as wwqtbfnum              
		from M2_OutOrderlists M2OOl            
		inner join M2_OutOrder M2OO on M2OOl.outID = M2OO.ID and M2OO.del = 1 and M2OO.wwType = 1    
		left join (
			select wwtb.PID,SUM(ISNULL(wwtb.certNum,0)) as certnum,
				SUM(ISNULL(wwtb.NumScrap,0)) as fgnum,
				SUM(ISNULL(wwtb.NumBF,0)) as bfnum 
			from [erp_Bill_QualityTestLogic]() wwtb 
			where wwtb.billType = 54006
			group by wwtb.PID
		)wwqttb  on  wwqttb.PID= M2OOl.ID     
		group by M2OOl.WFPAID
	)wwtb on wwtb.WFPAID = WFPAtab.ID     -----����ί��ϸ񡢷�������������	   
	left join (                      
		select WFPAID,ISNULL(SUM(num1),0) as zzsumnum,MAX(inDate) as indate 
		from M2_ProcedureProgres 
		where del=1 and result in(1,2) 
		group by WFPAID      
	) zztb on zztb.WFPAID = WFPAtab.ID   ----�������Ƽӹ��ϸ�����      

GO

CREATE FUNCTION [dbo].[IsStrIntersect](  
@str1 varchar(8000),  
@str2 varchar(8000),  
@spliter varchar(50)  
)  
returns INT  
AS  
begin  
DECLARE @Result int  
DECLARE @Num int    
DECLARE @Pos int    
DECLARE @NextPos int    
DECLARE @StrValue varchar(20)  
SET @Num = 0     
SET @Pos = 2     
SET @Result=0   
SET @StrValue = '' 
  IF SUBSTRING(@str1,1,1) != @spliter
	SET @str1= @spliter + @str1
  IF SUBSTRING(@str2,1,1) != @spliter
	SET @str2= @spliter + @str2
  IF SUBSTRING(@str1,LEN(@str1),1) != @spliter
	SET @str1= @str1 +@spliter 
  IF SUBSTRING(@str2,LEN(@str2),1) != @spliter
	SET @str2= @str2 +@spliter 
  IF LEN(@str2) = 0 OR LEN(@STR1) = 0
	RETURN 0
  IF CHARINDEX(@str2,@str1)>0 or CHARINDEX(@str1,@str2)>0  
  BEGIN  
	 set @Result = 1  
	 RETURN @Result  
  END   
  ELSE  
  BEGIN  
	WHILE(@Pos <= LEN(@str2))  
	BEGIN  
		SELECT @NextPos = CHARINDEX(@spliter, @str2, @Pos)
		SET @StrValue = @spliter+RTRIM(LTRIM(SUBSTRING(@str2, @Pos, @NextPos - @Pos)))+@spliter  
		IF(CHARINDEX(@StrValue,@str1)>0)  
		BEGIN  
			set @Result = 1  
			RETURN @Result  
		END  
		SELECT @Pos = @NextPos+1  
	END  
  END  
  RETURN @Result    
end
GO

create function [dbo].[erp_SelStaPerInfo](@hasMoudle int)  
returns table  
as return  
 select x.ID as ����ID, y.ID as  ���߹���ID , z.ID as ��λID, g.workPosition as ��λID,      
    g.userID as ��ԱID,  
    s.NowMoney*w.Capacity as �����,  --��λ�����*����ϵ��      
    --h.ID as ���ID,       
    --hrg.Date as ����,      
    DATEADD(d, hrc.StartInterDay, hrg.Date) + hrc.SignTime as d1,      
    DATEADD(d, hrc.EndInterDay, hrg.Date) + hrc.SignOutTime as d2,      
    hrg.isWork,      
    mainCapacity as ��������      
    from M2_WorkingProcedures x   --�����������      
    inner join M2_CXProcedureView y on x.ID= y.PID and x.del=1     --���߹�����ͼ      
    inner join M2_CXStationView z on z.PID = y.ID --���߹�λ��ͼ      
    inner join M2_PersonList_WP w on w.StationID = z.ID  --���߹�λ��Ա��  
    inner join hr_person g on g.userID = w.ProducePerson       
    left join sortonehy s on g.workPosition = s.ord  --��λ��       
    inner join dbo.HrKQ_PersonGroup h on isnull(h.Disable,0)=0 --������Ա�����      
    and (h.RangeType=0 or CHARINDEX(',' + CAST(g.userID as varchar(12)) + ',', ','+cast(h.Range as varchar(max))+',')>0)     
    inner join (      
       --�Ű���ϸ�������⴦������TimeArrangeID=999999�����      
            select ParentID, PersonGroupID, TimeArrangeID, [Date], 1 as isWork from  HrKQ_SchedulingDetail where Date>=convert(varchar(10),GETDATE(),120) and TimeArrangeID<>999999      
            union all      
            select x001.*,x002.[Date],0 as isWork from (      
             select       
              x1.ParentID,       
              x1.PersonGroupID,       
              y1.TimeArrangeID      
             from (select distinct x.ParentID,x.PersonGroupID, x.TimeArrangeID       
     from HrKQ_SchedulingDetail x where x.Date>=convert(varchar(10),GETDATE(),120)) x1       
             inner join (select distinct x.ParentID,x.PersonGroupID, x.TimeArrangeID       
     from HrKQ_SchedulingDetail x where x.Date>=convert(varchar(10),GETDATE(),120)) y1       
             on x1.parentID=y1.parentID       
             and x1.personGroupID=y1.personGroupID      
             and x1.timeArrangeID=999999 and y1.TimeArrangeID<>999999      
            ) x001 inner join HrKQ_SchedulingDetail x002      
            on x001.ParentID = x002.ParentID and x001.PersonGroupID = x002.PersonGroupID      
            and x002.TimeArrangeID=999999      
    ) hrg on  --�Ű���ϸ��      
     charindex(','+cast(h.ID as varchar(12)) +',', ','+ cast(hrg.PersonGroupID as varchar(8000)) + ',')>0      
    inner join HrKQ_Scheduling hrs on hrs.ID =hrg.ParentID  --�Ű�����      
    inner join HrKQ_TimeArrangeDetail hrd on hrd.ID = hrg.TimeArrangeID  --�����ϸ��      
    inner join HrKQ_ClockDetailList hrc on hrc.DetailID = hrd.ID --��ʱ���  
    where isnull(@hasMoudle,0) = 1  
      
    union all  
      
    select x.ID as ����ID, y.ID as  ���߹���ID , z.ID as ��λID, g.workPosition as ��λID,        
    g.ord as ��ԱID,  
    s.NowMoney*w.Capacity as �����,  --��λ�����*����ϵ��                
    DATEADD(d, hrc.StartInterDay, hrg.Date) + hrc.SignTime as d1,      
    DATEADD(d, hrc.EndInterDay, hrg.Date) + hrc.SignOutTime as d2,      
    hrg.isWork,      
    mainCapacity as ��������      
    from M2_WorkingProcedures x   --�����������      
    inner join M2_CXProcedureView y on x.ID= y.PID and x.del=1     --���߹�����ͼ      
    inner join M2_CXStationView z on z.PID = y.ID --���߹�λ��ͼ      
    inner join M2_PersonList_WP w on w.StationID = z.ID  --���߹�λ��Ա��  
    inner join gate g on w.ProducePerson = g.ord and (g.del=1 or g.del=3)      
    left join sortonehy s on g.workPosition = s.ord  --��λ��       
    inner join dbo.HrKQ_PersonGroup h on isnull(h.Disable,0)=0 --������Ա�����      
    and (h.RangeType=0 or CHARINDEX(',' + CAST(g.ord as varchar(12)) + ',', ','+cast(h.[Range] as varchar(max))+',')>0)  
    inner join (      
       --�Ű���ϸ�������⴦������TimeArrangeID=999999�����      
            select ParentID, PersonGroupID, TimeArrangeID, [Date], 1 as isWork from  HrKQ_SchedulingDetail where Date>=convert(varchar(10),GETDATE(),120) and TimeArrangeID<>999999      
            union all      
            select x001.*,x002.[Date],0 as isWork from (      
             select       
              x1.ParentID,       
              x1.PersonGroupID,       
              y1.TimeArrangeID      
             from (select distinct x.ParentID,x.PersonGroupID, x.TimeArrangeID       
     from HrKQ_SchedulingDetail x where x.Date>=convert(varchar(10),GETDATE(),120)) x1       
             inner join (select distinct x.ParentID,x.PersonGroupID, x.TimeArrangeID       
     from HrKQ_SchedulingDetail x where x.Date>=convert(varchar(10),GETDATE(),120)) y1       
             on x1.parentID=y1.parentID       
             and x1.personGroupID=y1.personGroupID      
             and x1.timeArrangeID=999999 and y1.TimeArrangeID<>999999      
            ) x001 inner join HrKQ_SchedulingDetail x002      
            on x001.ParentID = x002.ParentID and x001.PersonGroupID = x002.PersonGroupID      
            and x002.TimeArrangeID=999999      
    ) hrg on  --�Ű���ϸ��      
     charindex(','+cast(h.ID as varchar(12)) +',', ','+ cast(hrg.PersonGroupID as varchar(8000)) + ',')>0      
    inner join HrKQ_Scheduling hrs on hrs.ID =hrg.ParentID  --�Ű�����      
    inner join HrKQ_TimeArrangeDetail hrd on hrd.ID = hrg.TimeArrangeID  --�����ϸ��      
    inner join HrKQ_ClockDetailList hrc on hrc.DetailID = hrd.ID --��ʱ���     
    where isnull(@hasMoudle,0) <> 1  
GO

create  function [dbo].[erp_Bill_QualityListTestLogic]() 
returns table  
AS  
return  
(         
		select mq.ID QTID,mqt.ID as QTLID,mqt.bid PID,mq.QTDate, isnull(mqt.SerialNumber,0) SerialNumber,                                                                   
               case when mq.QTMode=0 and (isnull(mqt.QTResult,0)=0 or isnull(mq.CkStatus,0) =4)  
			  and mq.poType in (1,2)        
               then isnull(mqt.NumTesting,0)-isnull(NumBF,0)-isnull(NumScrap,0)                                           
               when mq.QTMode=0 and isnull(mqt.QTResult,0)=0 and mq.poType in (1,2)     
               then isnull(mqt.SerialNumber,0)  

               when mq.QTMode=1 and isnull(mqt.QTResult,0)=0 then isnull(mqt.SerialNumber,0)                                         
               when isnull(mq.CkStatus,0) =1 then isnull(mqt.SerialNumber,0)                                        
               else 0 end certNum,                                                                                                         
               case when  mq.QTMode=0 and (isnull(mqt.QTResult,0)=0 or isnull(mq.CkStatus,0) =4) then isnull(NumBF,0)                  
               when ((isnull(mq.CkStatus,0) =3 and  mq.poType in (3,4)) or (isnull(mq.CkStatus,0) =2 and mq.poType in (1,2)))   
               then isnull(mqt.SerialNumber,0)                          
               else 0 end NumBF,                                        
               case when  (isnull(mq.CkStatus,0) =2 and  mq.poType in (3,4))  then  isnull(mqt.SerialNumber,0)
               when mq.QTMode=0 and (isnull(mqt.QTResult,0)=0 or isnull(mq.CkStatus,0) =4) then isnull(NumScrap,0)                              
               else 0 end NumScrap,                                                                 
               case when isnull(mqt.QTResult,0)=0 then 0 else 1  end  QTResult,    
               isnull(mq.CkStatus,0) CkStatus,      
              (case mq.poType when 1 then 54003 when 2     
               then 54006 when 3  then 54002 when 4  then 54005 else 0 end  ) billType    
			  from M2_QualityTestingLists mqt                                    
			  inner join M2_QualityTestings mq on mq.ID = mqt.QTID                                                                                                  
			  where mqt.del=1 and mq.del=1                                                               
) 
GO

Create function [dbo].[joinFiledAsStr](
	@str varchar(8000),
	@sign varchar(10)
) returns varchar(200)
as
begin
	declare @ret varchar(8000), @max int
	DECLARE @T Table (id int NULL, short_str varchar(8000) null)
	insert into @T(id, short_str) select ID, short_str from dbo.split(@str,@sign)
	select @max = max(id) from @T
	delete from @T where id=@max
	
	set @ret = ''
	select @ret = isnull(@ret + ' ','')+isnull(short_str,'') from @T
	select @ret = ltrim(@ret)
	IF @sign<>' ' 
	begin
		select @ret = replace(@ret,' ',@sign)
	end 

	return @ret
end

GO

create function [dbo].[M2_MachineStatusList] (
	@WCenter int,    @now datetime
) returns table as return (
	select 
		x.ID ,  y.WCenter,  y.StationID,   x.isCrash,  
		isnull(z.mStatus,0) as  mStatus,  isnull(wflist.wf,0) as wf
	from M2_MachineList x
	inner join M2_MachineList_WP y  on x.ID = y.MachineLID and (y.WCenter = @WCenter  or @WCenter=0)
	left join (
			select distinct b.MachineID ,  c.mStatus
			from M2_MachineCalendar a 
			inner join M2_MachineClist b on a.ID=b.MCID	
			inner join M2_MachineCdate c on a.ID = c.MCID 
			where DATEDIFF(DAY, c.mDay, @now)=0
	) z  on z.MachineID = x.ID 
	left join (
		select distinct s.MHLID, 1 as wf from dbo.M2_MachineTainListView s  where  @now>=d1 and @now<=d2
	)  wflist on wflist.MHLID=x.ID 
	where x.del=1 
)

GO

create function [dbo].[GetJoinRange](
	@shortRangeList1 varchar(max),
	@fullRangeList2 varchar(max)
)
returns varchar(max)
as begin
	if(@shortRangeList1 is NULL  or @fullRangeList2 is NULL) return NULL;
	declare @r varchar(max), @sr varchar(50)
	declare @i1 int,  @i2 int;
	set @r = '';  set @i1 = 0;  set @i2 = charindex(',',  @shortRangeList1);  set @fullRangeList2  = ',' + @fullRangeList2 + ',';
	set @i2 = case @i2 when 0 then len(@shortRangeList1)+1 else @i2 end;
	while @i2 > @i1
	begin
		set @sr = substring(@shortRangeList1+',',   @i1+1 ,  @i2-@i1-1)
		if len(@sr)>0 
		begin
			if  charindex(',' + @sr +',',   @fullRangeList2)>0
			begin
					if len(@r)>0  begin set @r = @r + ',' end
					set @r = @r +@sr 
			end
		end
		set @shortRangeList1 = substring(@shortRangeList1, @i2+1, len(@shortRangeList1+',') - @i2);
		set @i2 = charindex(',',  @shortRangeList1); 
	end
	return @r;
end

GO

--Attrs:�����¿���
create function [dbo].[erp_fina_GetAccountMonth]()
returns table as return  (
		select 
				convert(varchar(20), currd1, 120) as [��ǰ������],
				convert(varchar(20), cast((cast(CurrInitYear as varchar(4)) + '-' + cast(startM as varchar(12)) + '-1') as datetime),120) [��ǰ��������ʼ����],
			     (cast((case startM when 1 then  CurrInitYear else CurrInitYear+1 end) as varchar(4)) + '-' + cast(endM as varchar(12)) + '-' + 
			    (cast(  (case when endM in (1,3,5,7,8,10,12) then 31
					when  endM in (4,6,9,11) then 30
					else (
							case when (CurrInitYear+1)%4=0 and (CurrInitYear+1)%100<>0  then 29 else 28 end
					) end  )  as varchar(12) )
			     ) + ' 23:59:59') as [��ǰ�������ֹ����],
				 cast(initd1  as datetime) as [������������]
		from (
			 select 
					(currYear -  (case  when currMonth < startM then 1 else 0 end)) as  CurrInitYear, *
			 from (
					select
						isnull(s.AccountInitDate,'2010-1-1') as initd1,
						ISNULL(s.AccountCurrDate, isnull(accountdate1,'2010-1-1')) as currd1,
						YEAR(ISNULL(s.AccountCurrDate, isnull(accountdate1,'2010-1-1')) ) as currYear,
						MONTH(ISNULL(s.AccountCurrDate, isnull(accountdate1,'2010-1-1')) ) as  currMonth,
						s.AccountMonth1 as startM, 
						s.AccountMonth2 as endM
					from f_account xx
                    left join [@@SQLDBName]..accountsys s on xx.sign = s.sign
			  )  t 
		)  t1
)

GO

--Attrs:�����¿���
create function [dbo].[erp_fina_AccountSubjectCurrYearApplyUsedList]() 
returns table 
as  return (
	select bbb.* from dbo.erp_fina_GetAccountMonth() aaa
	inner join (
		select v.AccountSubject,  v.id,   1 as type1,  v2.voucherHSmonth as d1  from f_VoucherList v 
		inner join f_Voucher v2 on v2.ord=v.Voucher  
		union all
		select AccountSubject,  id,  2, '2100-1-1' from  f_VoucherListTemp
		union all
		select AccountSubject, id,  3,  date1 from f_temp_accumulSubject
		union all
		select AccountSubject, id,  4,  date1 from f_accumulSubject
	) bbb on  bbb.d1>=aaa.[��ǰ��������ʼ����]
)

GO

--Attrs:�����¿���
create function [dbo].[Get_fina_AssistHZReport] (
 @AccountMonth1 varchar(100),                       
 @uid INT,                          
 @pageindex INT,                          
 @pagesize INT,              
 @KJdate_0 varchar(100),              
 @KJdate_1 varchar(100),               
 @KJKeMu  varchar(100),              
 @BZstatus   varchar(100),              
 @PZstatus varchar(100),              
 @serchkey varchar(100),              
 @serchkeyTxt varchar(100) 
)            
returns table            
as            
return            
(          
   select distinct f_VAL.AssistID,f_VAL.AssistSubject,f_VL.bz,f_VL.hl,
  (case when f_ASubject.balanceDirection=1 
    then ((case when DateDiff(DAY,@AccountMonth1,@KJdate_0)=0 then isnull(QCJE_J_0.money1_b,0) else isnull(QCJE_J_0.money4_b,0)end)+VoucherListTabs.money2-VoucherListTabs.money3) else ((case when DateDiff(DAY,@AccountMonth1,@KJdate_0)=0 then isnull(QCJE_J_0.money1_b,0) else isnull(QCJE_J_0.money4_b,0) end)-VoucherListTabs.money2+VoucherListTabs.money3) end) J_QMYE_b, 
   (case when f_ASubject.balanceDirection=1 then ((case when DateDiff(DAY,@AccountMonth1,@KJdate_0)=0 then QCJE_D_0.money1_b else (case when isnull(QCJE_D_1.money4_b,0)>0 then QCJE_D_1.money4_b else 0 end) end)+VoucherListTabs.money2-VoucherListTabs.money3) else  ((case when DateDiff(DAY,@AccountMonth1,@KJdate_0)=0 then QCJE_D_0.money1_b else (case when isnull(QCJE_D_1.money4_b,0)>0 then QCJE_D_1.money4_b else 0 end) end)-VoucherListTabs.money2+VoucherListTabs.money3) end) D_QMYE_b,          --m2����-m3����-m5ԭ��-�� m6ԭ��-��
(case when f_ASubject.balanceDirection=1 then ((case when DateDiff(DAY,@AccountMonth1,@KJdate_0)=0 then QCJE_J_0.money1_y else (case when isnull(QCJE_J_1.money4_y,0)>0 then QCJE_J_1.money4_y else 0 end) end)+VoucherListTabs.money5-VoucherListTabs.money6) else ((case when DateDiff(DAY,@AccountMonth1,@KJdate_0)=0 then QCJE_J_0.money1_y else (case when isnull(QCJE_J_1.money4_y,0)>0 then QCJE_J_1.money4_y else 0 end) end)-VoucherListTabs.money5+VoucherListTabs.money6) end) J_QMYE_y,          
 (case when f_ASubject.balanceDirection=1 then ((case when DateDiff(DAY,@AccountMonth1,@KJdate_0)=0 then QCJE_D_0.money1_y else (case when isnull(QCJE_D_1.money4_y,0)>0 then QCJE_D_1.money4_y else 0 end) end)+VoucherListTabs.money5-VoucherListTabs.money6) else ((case when DateDiff(DAY,@AccountMonth1,@KJdate_0)=0 then QCJE_D_0.money1_y else (case when isnull(QCJE_D_1.money4_y,0)>0 then QCJE_D_1.money4_y else 0 end) end)-VoucherListTabs.money5+VoucherListTabs.money6) end ) D_QMYE_y                         
 from 
 f_VoucherAssistList f_VAL    
 left join  f_VoucherList f_VL on   f_VAL.VoucherList=f_VL.id                 
 left  join    f_Voucher f_V   on f_VL.id=f_VAL.VoucherList and f_VL.Voucher=f_VAL.Voucher              
 left  join f_AccountSubject f_ASubject on f_VL.AccountSubject=f_ASubject.ord ---��ƿ�Ŀ                           
 left join f_AssistSubject f_AS on f_VAL.AssistSubject=f_AS.id and f_AS.del=1 and isnull(f_AS.stop,0)=0 --������Ŀ                   
 left join  [@@SQLDBName]..tel t1 on  f_AS.isDef=1 and t1.sort3=1 and t1.ord=f_VAL.AssistID  --�ͻ�          
 left join  [@@SQLDBName]..tel tel2 on  f_AS.isDef=2 and tel2.sort3=2 and tel2.ord=f_VAL.AssistID  --��Ӧ��          
 left join  [@@SQLDBName]..orgs_parts g2 on  f_AS.isDef=3  and g2.ID=f_VAL.AssistID  --����          
 left join  [@@SQLDBName]..gate g on  f_AS.isDef=4  and g.ord=f_VAL.AssistID  --��Ա          
 left join  [@@SQLDBName]..chance ch on  f_AS.isDef=5  and ch.ord=f_VAL.AssistID  --��Ŀ          
 left join  [@@SQLDBName]..product p on  f_AS.isDef=6  and p.ord=f_VAL.AssistID  --��Ʒ           
 left join  [@@SQLDBName]..sortbank bank on  f_AS.isDef=7  and bank.id=f_VAL.AssistID  --�����˺�    
 left join f_AssistList f_ASL on  f_AS.isDef=0  and f_ASL.id=f_VAL.AssistID  --�Զ���        
 inner join ( select  b.bz,b.hl,b.[AccountSubject],a.AssistID,isnull(sum([money_J]),0) as money2,isnull(sum([money_D]),0) as money3,isnull(sum(case when [money_J]<>0 then money1 else 0 end),0) as money5,isnull(sum(case when [money_D]<>0 then money1 else 0 end),0) as 
 money6      
 from f_VoucherAssistList a  
  inner join f_VoucherList b on a.VoucherList= b.id   
  inner join f_Voucher c on b.Voucher = c.ord
  where  1=1                          
    AND        -----------����ڼ�         dateadd(dd,-1,dateadd(m,1,@KJdate_1))       
   (                
   (LEN(ISNULL(@KJdate_0,''))=0 and LEN(ISNULL(dateadd(dd,-1,dateadd(m,1,@KJdate_1)),''))=0) or                
   (LEN(ISNULL(@KJdate_0,''))>0 and LEN(ISNULL(dateadd(dd,-1,dateadd(m,1,@KJdate_1)),''))=0 and c.date1>=convert(varchar(50),@KJdate_0,120)) or                
   (LEN(ISNULL(@KJdate_0,''))=0 and LEN(ISNULL(dateadd(dd,-1,dateadd(m,1,@KJdate_1)),''))>0 and c.date1<=convert(varchar(50),dateadd(dd,-1,dateadd(m,1,@KJdate_1)),120)) or                
   (LEN(ISNULL(@KJdate_0,''))>0 and LEN(ISNULL(dateadd(dd,-1,dateadd(m,1,@KJdate_1)),''))>0 and c.date1<=convert(varchar(50),dateadd(dd,-1,dateadd(m,1,@KJdate_1)),120) and             
    c.date1>=convert(varchar(50),@KJdate_0,120))                
     )    
  group by  b.[AccountSubject],a.AssistID,b.bz,b.hl)    
  VoucherListTabs on f_ASubject.ord=VoucherListTabs.AccountSubject and VoucherListTabs.AssistID=f_VAL.AssistID 
  and f_VL.bz=VoucherListTabs.bz and  f_VL.hl=VoucherListTabs.hl         --**���ڷ�����**--  
   left join (  
   select a.AccountSubject,a.balanceDirection,b.*
   from f_accumulSubject a   
   inner  join f_accumuAssistList b on a.id=b.PID
   where  b.sort1=0 
   ) QCJE_J_0 on  QCJE_J_0.AccountSubject=f_ASubject.ord and QCJE_J_0.AssistSubject=f_AS.isDef  and QCJE_J_0.AssistID=f_VAL.AssistID and QCJE_J_0.balanceDirection=1              --�ڳ����-��-��ʼ�� 
 left join (  
   select a.AccountSubject,a.balanceDirection,b.*
   from f_accumulSubject a   
   inner  join f_accumuAssistList b on a.id=b.PID  
   where  b.sort1=1 and datediff(M,CONVERT(varchar(10), CONVERT(varchar(10),DATEADD(m,-1 ,dateadd(dd,-day(@KJdate_0)+1,@KJdate_0)) ,120)),a.date1) = 0
   ) QCJE_J_1 on  QCJE_J_1.AccountSubject=f_ASubject.ord and QCJE_J_1.AssistSubject=f_AS.isDef  and QCJE_J_1.AssistID=f_VAL.AssistID and QCJE_J_1.balanceDirection=1              --�ڳ����-��-����   
 left join (  
 select a.AccountSubject,a.balanceDirection,b.* from f_accumulSubject a   
  inner  join f_accumuAssistList b on a.id=b.PID  
  where  b.sort1=0 
  ) QCJE_D_0 on  QCJE_D_0.AccountSubject=f_ASubject.ord and QCJE_D_0.AssistSubject=f_AS.isDef  and QCJE_D_0.AssistID=f_VAL.AssistID and QCJE_D_0.balanceDirection=2   --�ڳ����-��-��ʼ��       
  left join (  
 select a.AccountSubject,a.balanceDirection,b.* from f_accumulSubject a   
  inner  join f_accumuAssistList b on a.id=b.PID  
  where  b.sort1=1 and datediff(M,CONVERT(varchar(10), CONVERT(varchar(10),DATEADD(m,-1 ,dateadd(dd,-day(@KJdate_0)+1,@KJdate_0)) ,120)),a.date1) = 0
  ) QCJE_D_1 on  QCJE_D_1.AccountSubject=f_ASubject.ord and QCJE_D_1.AssistSubject=f_AS.isDef  and QCJE_D_1.AssistID=f_VAL.AssistID and QCJE_D_1.balanceDirection=2   --�ڳ����-��-���� 
 where  f_VAL.del=1              
   AND (                
          LEN(ISNULL(@serchkeyTxt,''))=0    
         or (@serchkey='KH' and t1.name  like '%'+ @serchkeyTxt +'%')
         or (@serchkey='GYS' and tel2.name  like '%'+ @serchkeyTxt +'%')   
         or (@serchkey='BM' and g2.name  like '%'+ @serchkeyTxt +'%')   
         or (@serchkey='YG' and g.name  like '%'+ @serchkeyTxt +'%')   
         or (@serchkey='XM' and ch.title  like '%'+ @serchkeyTxt +'%')   
         or (@serchkey='ProName' and p.title   like '%'+ @serchkeyTxt +'%')   
         or (@serchkey='Bank' and bank.sort1   like '%'+ @serchkeyTxt +'%')  
         or (@serchkey not in ('KH','GYS','BM','YG','XM','ProName','Bank') and f_ASL.title  like '%'+ @serchkeyTxt +'%')            
     )           
  and f_AS.isDef=(case when @serchkey='KH' then 1 when @serchkey='GYS' then 2 when @serchkey='BM' then 3 when @serchkey='YG' then 4 when @serchkey='XM' then 5 when @serchkey='ProName' then 6  when @serchkey='Bank' then 7 else 0 end)            
   AND (     
   (f_ASubject.ord=@KJKeMu ) or (f_ASubject.parentID=@KJKeMu)   
   )    
                    
   AND (               
   LEN(ISNULL(@BZstatus,''))=0                
   or( CASE @BZstatus                  
    WHEN '-2' THEN 0 WHEN '0' THEN 0 else  f_VL.bz  end)             
     =(case when @BZstatus=-2 then 0 when @BZstatus=0 then 0 else @BZstatus end)              
    )                  
   AND        -----------����ڼ�              
   (                
   (LEN(ISNULL(@KJdate_0,''))=0 and LEN(ISNULL(dateadd(dd,-1,dateadd(m,1,@KJdate_1)),''))=0) or                
   (LEN(ISNULL(@KJdate_0,''))>0 and LEN(ISNULL(dateadd(dd,-1,dateadd(m,1,@KJdate_1)),''))=0 and f_V.date1>=convert(varchar(50),@KJdate_0,120)) or                
   (LEN(ISNULL(@KJdate_0,''))=0 and LEN(ISNULL(dateadd(dd,-1,dateadd(m,1,@KJdate_1)),''))>0 and f_V.date1<=convert(varchar(50),dateadd(dd,-1,dateadd(m,1,@KJdate_1)),120)) or                
   (LEN(ISNULL(@KJdate_0,''))>0 and LEN(ISNULL(dateadd(dd,-1,dateadd(m,1,@KJdate_1)),''))>0 and f_V.date1<=convert(varchar(50),dateadd(dd,-1,dateadd(m,1,@KJdate_1)),120) and             
    f_V.date1>=convert(varchar(50),@KJdate_0,120))                
     )               
  AND(                   
    LEN(ISNULL(@PZstatus,''))= 0                
    or(                
     (ISNULL(f_V.status,2) in(select short_str from [dbo].split(@PZstatus,','))) ---ƾ֤״̬                
   )                   
    )               
 --order by f_VAL.AssistID,f_VAL.AssistSubject,f_VL.bz,f_VL.hl          
)


GO

--Attrs:�����¿���
CREATE FUNCTION [dbo].[erp_evt_finance_GetBillType]
(
  @clstype INT,
  @extra VARCHAR(200)
)
RETURNS INT
AS
BEGIN
    DECLARE @returns INT;
    SELECT @returns = (CASE @clstype 
    WHEN 8001 THEN 41003 --���ù���-���ñ���-Ĭ�Ϸ���
    WHEN 8002 THEN 41003 --���ù���-���ñ���-���ż����
    WHEN 8003 THEN 41003 --���ù���-���ñ���-�����ڷ���
    WHEN 8004 THEN 41003 --���ù���-���ñ���-������������
    WHEN 8005 THEN 41003 --���ù���-���ñ���-����ί�����
    WHEN 8006 THEN 41003 --���ù���-���ñ���-����ί�����
    WHEN 8007 THEN 41004 --���ù���-����ֱ�ӳ��˱���
    WHEN 8008 THEN 41005 --���ù���-���ý��ֿ۱���
    WHEN 8009 THEN 41006 --���ù���-���ý��
    WHEN 8010 THEN 41007 --���ù���-���ý���
    
	WHEN 6001 THEN 43001 --�տƱ-Ԥ�տ�
    WHEN 6002 THEN 43002 --�տƱ-��Ԥ�տ�
    WHEN 6003 THEN 43003 --�տƱ-ֱ���տ�
    WHEN 6004 THEN 43004 --�տƱ-ֱ���˿�
    WHEN 6005 THEN 43012 --�տƱ-���뿪Ʊ
    WHEN 6006 THEN 43006 --�տƱ-Ԥ�տ�ֿ�
    WHEN 6007 THEN 43007 --�տƱ-Ԥ�տƱ�ֿ�
    WHEN 6008 THEN 43008 --�տƱ-�˿�תԤ�տ�
    WHEN 6009 THEN 43009 --�տƱ-�տ�ƻ�
    WHEN 6010 THEN 43010 --�տƱ-�����˿�ƻ�
    WHEN 6011 THEN 43012 --�տƱ-�ɱ���Ʊ
    WHEN 6101 THEN 43011 --�տƱ-ʵ���տ�

	WHEN 10001 THEN 44001 --������Ʊ-Ԥ����
    WHEN 10002 THEN 44002 --������Ʊ-��Ԥ����
    WHEN 10003 THEN 44003 --������Ʊ-ֱ�Ӹ���
    WHEN 10007 THEN 44004 --������Ʊ-ֱ���˿�
    WHEN 10005 THEN 44012 --������Ʊ-ֱ����Ʊ
    WHEN 10004 THEN 44006 --������Ʊ-Ԥ����ֿ�
    WHEN 10006 THEN 44007 --������Ʊ-Ԥ���Ʊ�ֿ�
    WHEN 10008 THEN 44008 --������Ʊ-�˿�תԤ����
    WHEN 10009 THEN 44009 --������Ʊ-����ƻ�
    WHEN 100091 THEN 44009 --������Ʊ-����ƻ�
    WHEN 100092 THEN 44009 --������Ʊ-����ƻ�
    WHEN 10010 THEN 44010 --������Ʊ-�ɹ��˿�ƻ�
    WHEN 10101 THEN 44011 --������Ʊ-ʵ�ʸ���

    WHEN 11001 THEN 61001 --������-���-�ɹ����
    WHEN 11002 THEN 61001 --������-���-�˻����
    WHEN 11003 THEN 61001 --������-���-�������
    WHEN 11004 THEN 61001 --������-���-ֱ�����
    WHEN 11005 THEN 61001 --������-���-��Ʒ���
    WHEN 11006 THEN 61001 --������-���-�������
    WHEN 11007 THEN 61001 --������-���-�̵����
    WHEN 11008 THEN 61001 --������-���-��װ���
    WHEN 11009 THEN 61001 --������-���-������
    WHEN 11010 THEN 61001 --������-���-�������
    WHEN 11011 THEN 61001 --������-���-��Ʒ�������
    WHEN 11012 THEN 61001 --������-���-���Ʒ���
	WHEN 11026 THEN 61001 --������-���-���Ʒ���
    WHEN 11027 THEN 61001 --������-���-���Ʒ���
    WHEN 11013 THEN 61001 --������-���-�������
    WHEN 11014 THEN 61001 --������-���-���Ʒ�������
    WHEN 11015 THEN 61001 --������-���-�������
    WHEN 11016 THEN 48002 --������-���-�ɹ��ݹ�����
    WHEN 11017 THEN 48002 --������-���-�ɹ��ݹ�����
    WHEN 11018 THEN 48003 --������-���-���������ת�����Ʒ��
    WHEN 11019 THEN 48003 --������-���-���������ת������ã�
    WHEN 11020 THEN 48003 --������-���-���������תӪҵ�ɱ���
    WHEN 11021 THEN 61001 --������-���-����ί���������  
    WHEN 11022 THEN 61001 --������-���-����ί��������  
    WHEN 11023 THEN 61001 --������-���-����ί���Ʒ���  
    WHEN 11024 THEN 61001 --������-���-����ί���Ʒ�������   
    WHEN 11025 THEN 48003 --������-���-���ɱ�����
    
    WHEN 12001 THEN 62001 --������-����-���۳���
    WHEN 12002 THEN 62001 --������-����-�ɹ��˻�
    WHEN 12003 THEN 62001 --������-����-���ϳ���
    WHEN 12004 THEN 62001 --������-����-ֱ�ӳ���
    WHEN 12005 THEN 62001 --������-����-�������
    WHEN 12006 THEN 62001 --������-����-��������
    WHEN 12007 THEN 62001 --������-����-�̵����
    WHEN 12008 THEN 62001 --������-����-��װ����
    WHEN 12009 THEN 62001 --������-����-��ֳ���
    WHEN 12010 THEN 62001 --������-����-���ϳ���
    WHEN 12011 THEN 62001 --������-����-����ί�����ϳ���  
    WHEN 12012 THEN 62001 --������-����-����ί�ⲹ�ϳ���  

    WHEN 5001 THEN 45001 --�ֽ�����-ֱ������
    WHEN 5002 THEN 45002 --�ֽ�����-ֱ�ӳ���
    WHEN 5003 THEN 45003 --�ֽ�����-�˼�ת��
    WHEN 5004 THEN 47003 --�ֽ�����-�˼�ת��
    WHEN 5005 THEN 47003 --�ֽ�����-�˼�ת��

	when 13001 then 48001 --�����ɱ�--���ż����
    when 13002 then 48001 --�����ɱ�--�����ڷ���
    when 13003 then 48001 --�����ɱ�--��������
    when 13004 then 48001 --�����ɱ�--ֱ�Ӳ���
    when 13005 then 48001 --�����ɱ�--ֱ���˹�
    when 13006 then 48001 --�����ɱ�--ί�����
    WHEN 13010 THEN 55003 --�����ɱ�--�����⳥
    when 14001 then 49002 --�̶��ʲ�--�����۾�
    WHEN 13008 THEN 48004 --�����ɱ�--�����ʲ��۾�  
    WHEN 13009 THEN 48004 --�����ɱ�--���ʷ���
    WHEN 13011 THEN 48004 --�����ɱ�--���ż���ã��£�
    WHEN 13012 THEN 48004 --�����ɱ�--�����ڷ��ã��£�
    WHEN 13013 THEN 48004 --�����ɱ�--�����������ã��£� 
    WHEN 14002 THEN 48004 --�̶��ʲ�--�۾�ת�������  

    WHEN 7001 THEN CASE CAST(@extra AS INT) WHEN '0' THEN 46001 ELSE 26001 END --���ʹ���-���ʼ���  
    WHEN 7002 THEN CASE CAST(@extra AS INT) WHEN '1' THEN 46001 ELSE 26001 END --���ʹ���-���ʷ���
    END)
    RETURN @returns;
END

GO

CREATE FUNCTION [dbo].[NumToChinese](@Number int)
RETURNS VarChar(100) AS   
BEGIN 
	DECLARE @String1 CHAR(20)
	Declare @String2 CHAR(30)
	Declare @String4 VARCHAR(100)
	Declare @String3 VARCHAR(100) --��ԭAֵ��ȡ����ֵ
	Declare @i int --ѭ������
	Declare @J INT --A��ֵ����100���ַ�������
	Declare @Ch1 VARCHAR(100) --���ֵĺ������
	Declare @Ch2 Varchar(100) --����λ�ĺ��ֶ���
	Declare @Zero INT --�������������м�����
	Declare @Returnvalue VARCHAR(100)

	Select @Returnvalue = ''
	Select @String1 = '��һ�����������߰˾�'
	Select @String2 = '��ǧ��ʮ��ǧ��ʮ��ǧ��ʮ������'

	Select @String4 = Cast(@Number*100 as int)    
	select @J=len(cast((@Number*100) as int))
	Select @String2=Right(@String2,@J)
	Select @i = 1 
	while @i<= @j 
	BEGIN
		Select @String3 = Substring(@String4,@i,1)
		if @String3<>'0' Begin
		Select     @Ch1 = Substring(@String1, Cast(@String3 as Int) + 1, 1)
		Select    @Ch2 = Substring(@String2, @i, 1)
		Select    @Zero = 0                    --��ʾ��λ��Ϊ��
		end
		else 
		BEGIN
			IF (@Zero = 0) Or (@i = @J - 9) Or (@i = @J - 5) Or (@i = @J - 1)
			Select @Ch1 = '��' 
			Else
			Select @Ch1 = ''
			Select @Zero = @Zero + 1             --��ʾ��λΪ0        
			--���ת������ֵ��Ҫ������ô��Ķ����±��ʽ I ��ֵ��
			Select @Ch2 = ''

			If @i = @J - 10  
			BEGIN
				SELECT @Ch2 = '��'
				Select @Zero = 0
			end

			If @i = @J - 6 
			BEGIN
				SELECT @Ch2 = '��'
				Select @Zero = 0
			end            
		end    
		Select @Returnvalue = @Returnvalue + @Ch1 + @Ch2
		select @i = @i+1
	END
	--��󽫶������ȥ��
	If CharIndex('ǧǧ',@Returnvalue) <> 0 
	Select @Returnvalue = Replace(@Returnvalue, 'ǧǧ', 'ǧ')
	If CharIndex('�۰�',@Returnvalue) <> 0 
	Select @Returnvalue = Replace(@Returnvalue, '�۰�', '��')
	If CharIndex('��Ԫ',@Returnvalue) <> 0 
	Select @Returnvalue = Replace(@Returnvalue, '��Ԫ', 'Ԫ')
	If CharIndex('����',@Returnvalue) <> 0 
	Select @Returnvalue = Replace(@Returnvalue, '����', '��')
	If CharIndex('����',@Returnvalue) <> 0
	Select @Returnvalue = Replace(@Returnvalue, '����', '��')
	If CharIndex('����',@Returnvalue) <> 0 
	Select @Returnvalue = Replace(@Returnvalue, '����', '��')
	If CharIndex('���',@Returnvalue) <> 0 
	Select @Returnvalue = Replace(@Returnvalue, '���', '��')

	If CharIndex('��Ǫ',@Returnvalue) <> 0 
	Select @Returnvalue = Replace(@Returnvalue, '��Ǫ', '��')

	set @Returnvalue=substring(@Returnvalue,1,len(@Returnvalue)-2)
	return @Returnvalue
END

GO
Create function [dbo].[existsPower2]
(
	@orginSplit varchar(max),--ԭʼֵ(���ַ���)
	@newSplit varchar(max),--��Ҫ�Д��ֵ(���ַ���)
	@speaterString varchar(20)--�ָ���
)
returns smallint
as
begin
	declare @val smallint,@i int,@helpSplit varchar(max)
	set @val=0
	set @newSplit=rtrim(ltrim(@newSplit))
	set @speaterString=rtrim(ltrim(@speaterString))
	set @orginSplit=rtrim(ltrim(@orginSplit))
	if left(@orginSplit,len(@speaterString))<>@speaterString
		set @orginSplit=@speaterString+@orginSplit
	if right(@orginSplit,len(@speaterString))<>@speaterString
		set @orginSplit=@orginSplit+@speaterString
	if @newSplit=''
		return @val
	if charindex(@speaterString,@newSplit)=0  
	begin
		--���߸ĳ�set  @helpSplit=replace(@orginSplit,@speaterString+@newSplit+@speaterString,'')
		-- if len(@speaterString+@newSplit+@speaterString)+len(@helpSplit)=len(@orginSplit)
		set @helpSplit=@speaterString+@newSplit+@speaterString
		if patindex('%'+@helpSplit+'%',@orginSplit)>0
			set @val=1
	end
 else
    begin
	    if right(@newSplit,len(@speaterString))<>@speaterString
		   set @newSplit=@newSplit+@speaterString
		set @i=charindex(@speaterString,@newSplit)
		while @i>0
		begin
			if rtrim(ltrim(left(@newSplit,@i-1)))=''
			begin
				set  @newSplit=SUBSTRING(@newSplit,@i+1,LEN(@newSplit)-@i)
				set @i=CHARINDEX(@speaterString,@newSplit)
				continue
			end
			set @helpSplit=@speaterString+rtrim(ltrim(left(@newSplit,@i-1)))+@speaterString
			--���߸ĳ�  len(@helpSplit)+len(replace(@orginSplit,@helpSplit,''))=len(@orginSplit)
			if patindex('%'+@helpSplit+'%',@orginSplit)>0
			begin
				set @val=1
				break
			end
			set  @newSplit=SUBSTRING(@newSplit,@i+1,LEN(@newSplit)-@i)
			set @i=CHARINDEX(@speaterString,@newSplit)
		end
    end	
	return @val
end
GO

create  FUNCTION [dbo].[GetTelName]
(@str nvarchar(max), --�ַ���
@spliter nvarchar(10))
returns nvarchar(max)--���ع���õ�KHname
AS 
BEGIN 
DECLARE @Result nvarchar(max)
DECLARE @KHName nvarchar(64)
DECLARE @Num int
DECLARE @Pos int
DECLARE @NextPos int
SET @Num = 0 
SET @Pos = 1 
SET @Result=''
 WHILE(@Pos <= LEN(@str)) 
 BEGIN 
  SELECT @NextPos = CHARINDEX(@spliter, @str, @Pos)
  IF (@NextPos = 0 OR @NextPos IS NULL) 
  SELECT @NextPos = LEN(@str) + 1
SELECT @KHName=[NAME] FROM dbo.gate WHERE [ord]=RTRIM(LTRIM(SUBSTRING(@str, @Pos, @NextPos - @Pos)))
  
  SET @Result = @Result + @KHName +','
  SELECT @Pos = @NextPos+1 
 END
 IF(LEN(@Result)>0)
 BEGIN
 SET @Result = SUBSTRING(@Result,0,LEN(@Result))
 END
RETURN @Result
END

GO
--���ݵ�λ����ʶ��λID����
--�����Զ��ŷָ��ĵ�λID�ַ���
create function [dbo].[pro_unit_union](
	@unit varchar(100)
) returns varchar(4000) as
begin
	declare @r varchar(400), @a varchar(10)
	set @r = ''
	set @unit = replace(replace(replace(replace(@unit,' ',','),';',','),'��',','),'��',',')
	select @r = stuff( (select ','+ cast(ord as varchar(10)) from sortonehy  where ','+@unit+',' like '%,'+ sort1+',%' and gate2=61 and isNull(isStop,0)=0 for xml path('') ),1,1,'')
	return @r
end

GO

Create function [dbo].[FUN_CaigouQCRknum](@cgord int,@tagID INT,@ords VARCHAR(MAX)) 
RETURNS TABLE 
AS
RETURN 
(
	SELECT cgord,cglid,qcord,QCRK.okNum,QCRK.krkNum,yrknum 
    from (
		select cgord,cglid,qcord,okNum,ISNULL(SUM(rkNum),0) as krkNum,ISNULL(SUM(yrknum),0) yrknum 
		from (
				select cgord,cglid,qcord,okNum,sum(rkNum) rkNum,SUM(yrknum) yrknum
				from (
				    select b.caigou cgord,b.caigoulist  as cglid, b.id as qcord,
					    case when b.complete<>3 then 0 
						    else  isnull(dbo.QCRKNum(b.SpResult,(case when b.del=1 and isnull(b.NumQC,0)>0 then b.recnum else 0 end),b.failnum,b.QCResult),0)
					    end as okNum,
					    case when isnull(c.status,0)=0 then 0 when sign(isnull(c.num2,0))=0 then isnull(c.num1,0) else isnull(c.num2,0) end as rkNum,
					    ISNULL(c.num2,0) yrknum
				    from caigouqc b WITH(NOLOCK) 
				    left join (
					    select kl.num1,(isnull(hc.num1,0)+isnull(k.num3,0)) num2,isnull(kl.caigouqc,0) as caigouqc,
						    ISNULL(kl.caigouqclist,0) caigouqclist,kl.caigou,kl.caigoulist,isnull(ki.status,-1) as status
					    from kuinlist kl WITH(NOLOCK) 
					    inner join kuin ki WITH(NOLOCK) on ki.ord= kl.kuin and (@cgord=0 OR kl.caigou = @cgord) and kl.del=1
					    LEFT JOIN ku k WITH(NOLOCK) on kl.id=k.kuinlist
					    LEFT JOIN (
                            select kuinlist,ISNULL(sum(num1),0) num1 from kuhclist WITH(NOLOCK) where del=1 GROUP BY kuinlist
                        ) hc ON hc.kuinlist=kl.id  
					    where ki.del = 1
                    ) c on isnull(c.caigou,0)=b.caigou and b.id = c.caigouqclist
				    where (@cgord=0 OR b.caigou = @cgord) and b.del=1  
					    AND (@tagID=0 OR (@tagID=2 AND (@ords='0' OR CHARINDEX(','+CAST(b.id AS VARCHAR(10))+',',','+@ords+',')>0)))
			    ) t0 
			    group by cgord,cglid,qcord,okNum,rkNum
        ) t1 
        group by cgord,cglid,qcord,okNum,qcord
	) QCRK 
	inner join caigouQC qc on qc.id = QCRK.qcord 
)

GO
--Attrs:�����¿���
Create function [dbo].[IsSame]
(@v1 nvarchar(30),  @v2  nvarchar(30))
returns float
as begin
	return case @v1 when @v2 then 1 else -1 end;
end

GO
--Attrs:�����¿���	 
CREATE FUNCTION [dbo].[IsSameList] (
	@str1 varchar(8000),  
	@str2 varchar(8000)
) returns int
as begin
	declare @leftstr varchar(500)
	declare @i int ,  @findi int,  @lenstr1 int;
	set @str2 =  ',' +  @str2 + ','
	while len(@str1)>0 
	begin 
		set @lenstr1 =  len(@str1);
		set @i = CHARINDEX(',' , @str1)
		set @i =  case @i when 0 then @lenstr1 else @i -1 end;
		set @leftstr =   left(@str1, @i)
		if @i>0 and @leftstr<>'0'
		begin
			set  @findi =  charindex(',' + @leftstr + ',', @str2)
			if @findi>0 begin return 1 end
		end
		set @str1 = substring(@str1,  @i+2,  @lenstr1-@i);
	end
	return 0;
end

GO
--Attrs:�����¿���
CREATE function [dbo].[getNbitValue]  
(  
	/*
		���ظ���С��λ��Ϊv1��v2�д�ֵ��ȥС������Ľ��
		�������С��λ���жϲ�����С������򷵻�isnull(v1,0)
		Author:zzy
		Date:2018-08-14
	*/
	@v1 decimal(25, 12),
	@v2 decimal(25, 12),
	@nbit int
)  
returns decimal(25, 12)  
as  
begin  
	if isnull(@nbit,0) = 0
	begin
		select @nbit=num1 from [@@SQLDBName]..setjm3 where ord=88
		set @nbit = ISNULL(@nbit,2)
	end
	
	declare @tempv decimal(25, 12)
	declare @nbitv decimal(25, 12)
	declare @minv decimal(25, 12)
	declare @maxv decimal(25, 12)
	declare @roundv decimal(25, 12)
	
	select @minv = (case when isnull(@v1,0) > isnull(@v2,0) then isnull(@v2,0)
						 else isnull(@v1,0)
					end),
		   @maxv = (case when isnull(@v2,0) > isnull(@v1,0) then isnull(@v2,0)
						 else isnull(@v1,0)
					end)
					
	set @tempv = @maxv-@minv
	if @tempv = 0
		return @v1
	set @roundv = abs(@maxv-ROUND(@maxv,@nbit))
	
	if @roundv = 0
		return @v1
	
	--ȡС��λ������Сֵ ��: λ��2 @nbitv = 0.01; λ��3 @nbitv = 0.001
	set @nbitv = @roundv*10/(@roundv*power(10,@nbit+1))
	
	if(@tempv<@nbitv)
		return @maxv-@tempv 
	return isnull(@v1,0)
end

GO

CREATE function [dbo].[CNumberList](@listtext varchar(8000))
returns varchar(8000)
as begin
	declare @result varchar(8000),  @iResult varchar(50)
	declare @i1 int,  @len int, @i int;
	set @i1 = 1;  set @i=1; set @result = '';
	set @len = len(@listtext);
	while @i <= @len
	begin
		if substring(@listtext, @i, 1) = ',' 
		begin
			set @iResult = replace(substring(@listtext, @i1,  @i-@i1),' ','')
			if len(@iResult)>0 and isnumeric(@iResult)=1 
			begin
				set @result = @result + (case sign(len(@result)) when 1 then  ',' else '' end)  + @iResult;
			end
			set @i1 = @i+1
		end
		set @i = @i +1;
	end
	if @i>@i1
	begin
		set @iResult = replace(substring(@listtext, @i1,  @i-@i1+1),' ','')
		if len(@iResult)>0 and isnumeric(@iResult)=1 
		begin
			set @result = @result + (case sign(len(@result)) when 1 then  ',' else '' end)  + @iResult;
		end
	end
	return @result;
end

GO

CREATE  function [dbo].[erp_comm_BillApproveInfo_Bank](
	@ApproveSort int
) returns table 
as
return 
	SELECT ai.PrimaryKeyID AS ord,sp.cateid,sp.date1,ai.SurplusApprover ,ai.ApprovalFlowStatus
	FROM dbo.sp_ApprovalInstance ai
	left JOIN (
		SELECT MAX(it.id) id,it.InstanceID FROM sp_intro it
		WHERE it.sort1 = @ApproveSort AND it.IsAutoPass!=1
		GROUP BY it.InstanceID
	) t ON t.InstanceID = ai.InstanceID
	LEFT JOIN sp_intro sp ON sp.id= t.id
	WHERE ai.gate2 = @ApproveSort

GO

CREATE FUNCTION [dbo].[erp_GetContractlistIds]
(
	@int int
)
RETURNS VARCHAR(4000)
AS
BEGIN
	DECLARE @returnIds VARCHAR(4000)
	select @returnIds= STUFF((SELECT ','+CAST(Id AS VARCHAR(20))  from [dbo].[erp_GetContractlistIdsTable](1) FOR xml path('')),1,1,'') 
   	RETURN @returnIds
END

GO

CREATE FUNCTION [dbo].[erp_GetContractlistIdsTable] 
(  
 @int int 
) returns @listId table(Id int)
as  
begin
 IF EXISTS(SELECT 1 FROM home_usConfig WHERE  uid = 0 and name = 'ManuPlanuNumControl' AND nvalue = 1)  
  BEGIN  
    insert into @listId(Id)
    SELECT distinct tab.id   
    FROM(  SELECT  cl.id,(isnull(cx.Num,0)-ISNULL(t.NumPlan,0)) num FROM dbo.contractlist cl   
                             inner join ( SELECT c.id , c.num1-c.num2- isnull(sum(isNull(t.num1 * cast((isnull(cc.bl,1) / isnull(dd.bl,1)) as decimal(25,12)),0)),0) as Num   
                             from contractlist c  
                             LEFT JOIN dbo.contract ht ON ht.ord = c.contract  
                             inner join product p on p.ord = c.ord and isnull(p.canoutstore, 1)= 1 and(p.roles like '%1%' or p.roles like '%2%')  
                             left join contractthlist t on t.contractlist = c.id and t.del <> 2 and t.caigou in (select ord from contractth where del <> 2 and sp<> -1)   
                             left join (select distinct unit, product, bl from jiage where bm = 0) cc on cc.product = c.ord and cc.unit = t.unit  
                             left join (select distinct unit, product, bl from jiage where bm = 0) dd on dd.product = c.ord and dd.unit = c.unit  
                             where c.del = 1 AND ISNULL(ht.isTerminated,0) = 0 
                             AND NOT EXISTS(SELECT TOP 1 1 FROM dbo.M2_WorkAssigns wa WHERE wa.del = 1 AND wa.fromtype = 3 AND wa.MOrderID = c.contract) 
                             group by c.id ,c.num1,c.num2  
                             having (c.num1 - c.num2) > isnull(sum(isNull(t.num1 * cast((isnull(cc.bl,1) / isnull(dd.bl,1)) as decimal(25,12)), 0)), 0)) cx on cx.id = cl.id    
                             LEFT JOIN (   
                             SELECT mpl.FromID,SUM(NumPlan) NumPlan   
                             FROM dbo.M2_ManuPlanListsPre mpl  
                             INNER JOIN dbo.M2_ManuPlansPre mp on mp.id = mpl.mpsid and mp.del=1 and isnull(mp.status,-1)<>0   
                             INNER JOIN dbo.contractlist cl ON  mpl.FromID = cl.id and mpl.del=1   
                             WHERE mpl.CreateFrom = 1 GROUP BY mpl.FromID    
                             ) t ON cl.id = t.FromID   
                             WHERE  isnull(cx.Num,0) > ISNULL(t.NumPlan,0)) tab
                               
  END ELSE  
  BEGIN  
         insert into @listId(Id)
         SELECT distinct tab.id
         FROM( SELECT c.id , (c.num1-c.num2- isnull(sum(isNull(t.num1 * cast((isnull(cc.bl,1) / isnull(dd.bl,1)) as decimal(25,12)),0)),0)) as Num   
                         from contractlist c  
                         LEFT JOIN dbo.contract ht ON ht.ord = c.contract  
                         inner join product p on p.ord = c.ord and isnull(p.canoutstore, 1)= 1 and(p.roles like '%1%' or p.roles like '%2%')  
                         left join contractthlist t on t.contractlist = c.id and t.del <> 2 and t.caigou in (select ord from contractth where del <> 2 and sp<> -1)   
                         left join (select distinct unit, product, bl from jiage where bm = 0) cc on cc.product = c.ord and cc.unit = t.unit  
                         left join (select distinct unit, product, bl from jiage where bm = 0) dd on dd.product = c.ord and dd.unit = c.unit  
                         where c.del = 1 AND ISNULL(ht.isTerminated,0) = 0 
                         AND NOT EXISTS(SELECT TOP 1 1 FROM dbo.M2_WorkAssigns wa WHERE wa.del = 1 AND wa.fromtype = 3 AND wa.MOrderID = c.contract) 
                         group by c.id ,c.num1,c.num2  
                         having (c.num1 - c.num2) > isnull(sum(isNull(t.num1 * cast((isnull(cc.bl,1) / isnull(dd.bl,1)) as decimal(25,12)), 0)), 0))tab
  END
  return
END  

GO

CREATE FUNCTION [dbo].[f_trimstr] ( @str NVARCHAR(MAX) )  
RETURNS NVARCHAR(MAX)  
AS  
  BEGIN  
    WHILE CHARINDEX('<', @str) > 0  
    SET @str = STUFF(@str, CHARINDEX('<', @str),CHARINDEX('>', @str) - CHARINDEX('<', @str) + 1,'')  
    RETURN @str;  
  END  

GO

CREATE function [dbo].[ReturnCkBum]      
(    
	@uid int,    
	@ord int      
)      
returns nvarchar(max)      
as begin      
	DECLARE @STR VARCHAR(max)      
	set @STR=''      
	SELECT @STR=isnull(@STR,'')+s.RootPath+'->'+s.sort1+' '+so.sort1+' '+cast((select [dbo].[formatNumber](sum(b.num2),3,0)) as nvarchar(100))+'<br>'      
	from         
	ku  b WITH(NOLOCK)        
	inner join sortck s on s.id=b.ck        
	inner join sortonehy so  on so.ord=b.unit         
	where b.ord=@ord and b.num2>0 
	and (
		CHARINDEX(',' + CAST(63 as varchar(12)) + ',', ',' +cast(s.intro as varchar(max))+',' )>0 
		or cast(s.intro as nvarchar(max))='0'
	)       
	group by b.ck,s.RootPath,s.sort1,so.sort1       
	
	if @STR=''     
	begin    
	set @STR='û�п��!'    
	end    
	return @STR       
end

GO
Create function [dbo].[erp_comm_UnitConvert](
	@ProductId int,	-- ��ƷOrd
	@OldUnit int,	-- �ɵ�λID
	@OldNum decimal(25, 12),--������
	@NewUnit int--�µ�λ
)RETURNS decimal(25, 12)
as 
  begin
	  declare @NewNum decimal(25, 12)
	  if(@OldUnit=@NewUnit)
	  begin
		 set @NewNum=@OldNum
	  end else
	  begin
			select @NewNum=(cast(@OldNum * cast(a.bl as decimal(25, 12)) as decimal(25,12))/cast(b.bl as decimal(25, 12)))
			from erp_comm_unitRelation a  
			inner join erp_comm_unitRelation b on a.ord=b.ord and b.unit = @NewUnit
			where a.ord =@ProductId and a.unit = @OldUnit
	  end
	  return @NewNum
  end
GO

Create function  [dbo].[ClearEndChar](@txt nvarchar(1000),  @nendChar  nvarchar(10))
returns  nvarchar(1000)
as begin
	if(@txt is null) 
	begin  
		return null
	end
	return replace(replace(@txt + '?*!',  @nendChar+'?*!', ''), '?*!','')
end

GO

create function [dbo].[GetQCStatusName](@QTResult int,  @QTCkStatus int, @showspresult int) 
returns nvarchar(100)
as begin
	return  (case  ISNULL(@QTResult,1)
		when 0 then '�ϸ�'
		when 1 then 
			(case @showspresult when 1 then  '���ϸ�(' else  '' end) 
			+ 
			(case isnull(@QTCkStatus ,0)  
			when 0  then '�����'
			when 1 then  '�ò�����'
			when 2 then  'ȫ������'
			when 3 then  'ȫ������'
			when 4 then  '���ϸ񷵹�'
			when 5 then  '���ϸ񱨷�'
			else ''
			end)
			+ (case @showspresult when 1 then  ') ' else  '' end) 
		else '' end
	)
end

GO

CREATE function [dbo].[erp_OutOrderHistoryHandle](
  @outItemIds nvarchar(4000)='' --''�� ȫ�� ,�ǿ��ַ��� ��������ѯ
)  
returns table  
AS  
return  
(          
   select tb.bid,SUM(tb.fgnum) as fgnum,SUM(tb.sjnum) as sjnum from (
		select qtl.bid,SUM(isnull(qtl.SerialNumber,0)) as sjnum,0 fgnum  
		from dbo.M2_QualityTestingLists qtl
			inner join dbo.M2_QualityTestings qt on qtl.QTID=qt.ID
		where qtl.TaskMXId=0 and qtl.del=1 and qt.poType in(1,2) 
		and (len(@outItemIds)=0 or CHARINDEX(','+CAST(qtl.bid AS VARCHAR(20))+',',','+@OutItemIds+',')>0)
		and isnull(qtl.bid,0)>0
		group by qtl.bid 
		union all
		select qtl.bid,0 as sjnum,SUM(isnull(qtl.SerialNumber,0)) as fgnum   
		from dbo.M2_QualityTestingLists qtl
			inner join dbo.M2_QualityTestings qt on qtl.QTID=qt.ID
		where qtl.TaskMXId=0 and qtl.del=1 and qt.poType in(1,2) and qt.CkStatus=2 
		and (len(@outItemIds)=0 or CHARINDEX(','+CAST(qtl.bid AS VARCHAR(20))+',',','+@OutItemIds+',')>0)
		and isnull(qtl.bid,0)>0
		group by qtl.bid 
   ) tb group by tb.bid
)
GO

CREATE   function  [dbo].[erp_qc_qckuinstatus] (@QCID int)
returns table as
return ( 
	select  
		cc2.QTID,
		(
			case 
				when cc3.poType =2 then -1
				when cc3.CkStatus in (2, 3) then -1
				else
				(	--��״̬=-1�� δ���=0 ; �������룬δ��� = 1 ; �������룬������� = 2;  ȫ�����룬δ��� = 3;  ȫ�����룬������� = 4 ;  ������ = 5�� �������=6
					case 
					when HasOKNum= 0 then 6
					when CanRKSureNum<=0 then 5
					when CanRKSureNum>0 and CanRKSureNum<HasOKNum and CanRKSQNum<=0 then 4
					when CanRKSureNum>=HasOKNum and CanRKSQNum<=0  then 3
					when (CanRKSureNum>0 and CanRKSureNum<HasOKNum)  and (CanRKSQNum>0  and CanRKSQNum<HasOKNum) then 2
					when CanRKSureNum>=HasOKNum  and CanRKSQNum>0 and  CanRKSQNum<HasOKNum then 1
					when  CanRKSQNum>=HasOKNum then 0
					end
				)
			end
		) Kuinstatus,
		(
			case 
				when cc3.poType =2 then -1
				when cc3.CkStatus in (0,1,2,4) then -1
				else
				(	--��״̬=-1�� δ���=0 ; �������룬δ��� = 1 ; �������룬������� = 2;  ȫ�����룬δ��� = 3;  ȫ�����룬������� = 4 ;  ������ = 5 �� ���豨�����=6
					case 
					when HasBFNum= 0 then 6
					when CanBFRKSureNum<=0 then 5
					when CanBFRKSureNum>0 and CanBFRKSureNum<HasOKNum and CanBFRKSQNum<=0 then 4
					when CanBFRKSureNum>=HasBFNum and CanBFRKSQNum<=0  then 3
					when (CanBFRKSureNum>0 and CanBFRKSureNum<HasBFNum)  and (CanBFRKSQNum>0  and CanBFRKSQNum<HasBFNum) then 2
					when CanBFRKSureNum>=HasBFNum  and CanBFRKSQNum>0 and  CanBFRKSQNum<HasBFNum then 1
					when  CanBFRKSQNum>=HasBFNum then 0
					end
				)
			end
		) BFKuinstatus,  
		(case 
			 when cc3.CkStatus in (0,1, 3, 5) then -1
			 else
				(case  --��״̬=-1�� δ����=0 ; ���ַ��� = 1 ; ������� =2�� ���践��=3
					when isnull(HasFGNum,0) = 0 then 3
					when CanFGOutNum>=HasFGNum then 0
					when CanFGOutNum >0  and  CanFGOutNum<=HasFGNum then 1
					when CanFGOutNum<=0 then 2
				 end)
		end)  as FGOutStatus,
		(case cc3.poType when 2 then 0 else  CanBFRKSQNum end) as CanBFNUM,   --���Ա�������
		CanFGOutNum as  CanFGOut,    --���Է�������
		(case cc3.poType when 2 then 0 else   CanRKSQNum end) as CanRKNUM	--�����������
	from  (
		select  
			QTID,
			sum(HasOKNum) as HasOKNum,
			sum(HasBFNum) as HasBFNum,
			sum(HasFGNum) as HasFGNum,
			sum(CanRKSQNum) as CanRKSQNum,
			sum(CanRKSureNum) as CanRKSureNum,
			sum(CanBFRKSQNum) as CanBFRKSQNum,
			sum(CanBFRKSureNum) as CanBFRKSureNum,
			sum(CanFGOutNum) as CanFGOutNum
		from (
			select 
				x.QTID,
				x.NumSPOK as HasOKNum,
				x.NumBF as HasBFNum,
				x.NumScrap as HasFGNum, 
				(x.NumSPOK-  ISNULL(x.NumOKKuin,0))  as CanRKSQNum,
				(x.NumSPOK-isnull(sum(y.num1),0)) as CanRKSureNum,
				(x.NumBF- x.NumBFKuin )  as CanBFRKSQNum,
				(x.NumBF- isnull(sum(y.num2),0) )  as CanBFRKSureNum,
				(x.NumScrap - x.NumFGOut )  CanFGOutNum
			from  M2_QualityTestingLists  x
			inner join M2_QualityTestings  z on 
				(@QCID =0 or x.QTID = @QCID)  and x.QTID=z.ID  ----ֻ��������������Ҫ��ѯʱ�Ž���
				and (z.QTResultAll=0 or z.CkStatus>0) 
			left join ( 
				select  
					n1.M2_QTLID,   n1.M2_BFID,   
					(case n1.sort1  when 5 then n1.num1  when 13 then n1.num1 else 0 end) as num1,
					(case n1.sort1  when 14 then n1.num1   when 15 then n1.num1 else 0 end) as num2
				from kuinlist n1 
				inner join  kuin n2 on n1.kuin=n2.ord and n2.del=1
				and n1.sort1 in (5,13, 14, 15) and n2.complete1 = 3
			) y  on  (y.M2_QTLID = x.ID or y.M2_BFID=x.ID)
			group  by 
			x.ID,  x.QTID,  x.NumSPOK,  
			x.NumOKKuin,  x.NumBF , 
			x.NumBFKuin ,  x.NumScrap, 
			x.NumFGOut
		)  cc1  group by  QTID
	)  cc2  
	inner join M2_QualityTestings 
	cc3 on cc2.QTID=cc3.ID  and 	(@QCID =0 or cc3.ID = @QCID) 
) 
                        
go

create function [dbo].[erp_f_GetFinaceDBName]
(
	@finaceId int,	--��������ID
	@year int,		--���������
	@saasCompany int --Sassģʽ��Ӧ�Ŀͻ�ID
)
returns varchar(50)
as
begin
	declare @sign varchar(10);
	declare @surrdbname varchar(100);
	if @saasCompany = 0 
	begin
		set @surrdbname = '[@@SQLDBName]'
		if CHARINDEX('DB',  @surrdbname) = 2 and (LEN(@surrdbname)=18 or LEN(@surrdbname)=17) and CHARINDEX('I', @surrdbname)=12
		begin
			set @saasCompany = cast(substring(@surrdbname, 4, 8) as int)
		end
	end
	select @sign = '1' + right('00000' + [sign], 3) + right('00' + cast(@year-2000 as varchar(12)), 2) + right('00000' + cast(ord %9999 as varchar(12)),4) 
	from [@@SQLDBName]..AccountSys where ord=@finaceID
	
	return 'ZB_FinanDB'+ case @saasCompany when 0 then '' else cast(@saasCompany as varchar(10)) end+'_'+@sign
end
go

Create function [dbo].[erp_comm_unitRelation_BL](  
 @ProductId int,
 @UnitId int 
) returns decimal(25,12)   
as  
begin
    declare @relust decimal(25,12) 
	select top 1 @relust=isnull(ja.bl,1) from dbo.jiage ja
	where ja.bm=0 and ja.product=@ProductId and ja.unit=@UnitId
	return isnull(@relust,1)
end

GO

Create  function [dbo].[M2_MaterialAnalysisEnableStockCacheProxy](
	@MaterialItemID  int
 ) returns table as return(
     select   mac.ID
			,mac.ParentID
			,mac.BillInDate
			,mac.BillType 
			,mac.BillID
			,mac.NodeType
			,(case when mal.Unit=mac.BillUinit then 1 else 0 end) as IsThisUnit
			,mac.BillTitle
			,ut.sort1 as BillUinit 
            ,mac.BillNum
			,mau.bl
			,mac.EnableKuNum
			,gt.name as BillCreator
		    ,mac.BillNature
	from dbo.M2_MaterialAnalysisEnableStockCache mac
	    inner join dbo.M2_MaterialAnalysisList mal on mal.ID=@MaterialItemID and mal.MASID=mac.MaterialID and mal.ProductID=mac.ProductID
		inner join dbo.M2_MaterialAnalysis  ma on ma.ID = mal.MASID and (ma.JoinMuilsUnit=1 or  mal.Unit=mac.BillUinit or mac.BillNature=1)
		left join dbo.M2_MaterialAnalysisUnitsCache mau on mau.UnitID=mac.BillUinit and mau.AnalysisListID=mal.ID
		left join dbo.sortonehy ut on mac.BillUinit=ut.id and ut.gate2=61
		left join dbo.gate gt on mac.BillCreator=gt.ord 
	where mac.ParentID = 0 or mac.ParentID in (
		select   mac.ID   from dbo.M2_MaterialAnalysisEnableStockCache mac
		 inner join dbo.M2_MaterialAnalysisList mal on mal.ID=@MaterialItemID and mal.MASID=mac.MaterialID and mal.ProductID=mac.ProductID
		inner join dbo.M2_MaterialAnalysis  ma on ma.ID = mal.MASID and (ma.JoinMuilsUnit=1 or  mal.Unit=mac.BillUinit or mac.BillNature=1)
	)
    union all
	select 0 as ID
	,0 as ParentID
	,ma.inDate as BillInDate
	,53001 as BillType
	,mal.MASID as BillID
	,2 as NodeType
	,(case when mal2.Unit=mal.Unit then 1 else 0 end) as IsThisUnit
	,'���η���ռ��' as BillTitle
	,(select top 1 sort1 from sortonehy x where x.ord= mal.Unit) as BillUinit
	,mal.CurrAssignNum as BillNum
	,mau.bl
	,mal.CurrAssignNum as EnableKuNum
	,(select top 1 name from gate x where x.ord=ma.creator) as BillCreator--�����
	,0 as BillNature  
	from dbo.M2_MaterialAnalysisList mal
	inner join dbo.M2_MaterialAnalysisList mal2 on mal.ID<mal2.ID and mal.ProductID=mal2.ProductID and mal2.ID=@MaterialItemID and mal2.MASID=mal.MASID
	inner join dbo.M2_MaterialAnalysis ma on mal.MASID=ma.ID and (ma.JoinMuilsUnit=1 or  mal.Unit=mal2.Unit)
	left join dbo.M2_MaterialAnalysisUnitsCache mau on mau.UnitID=mal.Unit and mau.AnalysisListID=mal2.ID
)

GO

create function [dbo].[MaxNumber](@num numeric(25,12), @minnum numeric(25,12))
returns numeric(25,12)
as begin
	declare @v  numeric(25,12)
	if (@num < @minnum)
	begin
		set @v  = @minnum
	end
	else
	begin
		set @v  = @num
	end
	return @v
end

GO

Create function [dbo].[erp_comm_GetNowKuCun](
	@ProductId int,	-- ��ƷOrd
	@UnitId int,--��λ
	@UserID int	-- ������
)RETURNS decimal(25, 12)
as 
  begin
	 declare @NowKuCun decimal(25, 12)
	 select
		@NowKuCun=sum(dbo.erp_comm_UnitConvert(ax.ord,ax.unit,isnull(ax.num2,0),@UnitId))
		from dbo.ku ax
		inner join sortck y on ax.ck =y.ord
		where ax.ord=@ProductId
        and y.del=1 
        and  (CHARINDEX(',' + CAST(@UserID as varchar(12)) + ',', ',' +cast(y.intro as varchar(max))+',' )>0 or cast(y.intro as nvarchar(max))='0')
	  return isnull(@NowKuCun,0)
  end
GO


CREATE FUNCTION [dbo].[GetCompleteQuantityInfo] ( @uid INT )
RETURNS TABLE
      AS
RETURN
      (
        SELECT  t1.BomID, t1.MOrderID, t1.Num, t1.ID, t1.productID, t1.PID,
        ( CASE WHEN t1.bl IS NULL OR t1.bl <= 0 THEN 1 ELSE t1.bl END ) bl, t1.PCWastage, t1.unit, ISNULL(t2.num2_unit,0) num2_unit,
        t1.Num * ( CASE WHEN t1.bl IS NULL OR t1.bl <= 0 THEN 1 ELSE t1.bl END ) * ( 100 + t1.PCWastage ) / 100 needNum,
        CASE WHEN t1.BomID IS NULL THEN 99999999999999999999
        WHEN t1.BomID IS NOT NULL THEN ISNULL(t2.num2_unit / ( CASE WHEN t1.bl IS NULL OR t1.bl <= 0 THEN 1 ELSE t1.bl END ), 0) / (1 + t1.PCWastage / 100) END num_f
        FROM    
        (
            SELECT pbl.BomID, mol.MOrderID, /*mol.Num*/ tjTab2.precount Num, 
            mol.ID, pbl.productID, pbl.PID, pbl.bl, pbl.PCWastage, pbl.unit
            FROM  dbo.M2_ManuOrderLists mol
            LEFT JOIN dbo.M2_PlanBomList pbl  ON (mol.BomListID > 0 AND mol.BomListID = pbl.PID )
            LEFT JOIN (
                 SELECT tjTab1.wanum nummake, tjTab1.ID, tjTab1.PID, ( tjTab1.wanum + tjTab1.oonum ) / tjTab1.Ocount AS mpercent,
                 tjTab1.Ocount - ( tjTab1.wanum + tjTab1.oonum ) AS precount
                 FROM (
                      SELECT    SUM(ISNULL(WA.num1, 0)) AS wanum, SUM(ISNULL(OO.num1, 0)) AS oonum, M2L.ID AS ID, M2L.ProductID AS PID,
                                M2L.Num AS Ocount
                      FROM      dbo.M2_ManuOrderLists M2L
                      LEFT JOIN (
                          SELECT    OOL.molist, SUM(ISNULL(OOL.num1, 0)) AS num1
                          FROM      dbo.M2_OutOrderlists OOL
                          INNER JOIN dbo.M2_OutOrder OO
                                    ON OO.ID = OOL.outID
                                       AND OOL.del = 1
                                       AND OO.wwType = 0
                          WHERE     OO.del = 1
                          GROUP BY  OOL.molist
                      ) OO ON ( OO.molist = M2L.ID )
                      LEFT JOIN (
                          SELECT    WA.ddlistid, SUM(WA.NumMake - ISNULL(qt.NumBF, 0)) num1
                          FROM      dbo.M2_WorkAssigns WA
                          LEFT JOIN 
                          (select PID,SUM(ISNULL(qt.NumBF, 0)) AS NumBF from dbo.erp_Bill_QualityTestLogic() qt
                                    where qt.billType IN ( 54002, 54005 ) GROUP BY PID)  qt
                                       on qt.PID = WA.ID
                          WHERE WA.del = 1 AND WA.ptype = 0
                          GROUP BY  WA.ddlistid
                      ) WA ON WA.ddlistid = M2L.ID
                      WHERE     M2L.Num > 0
                      GROUP BY  M2L.ID, M2L.ProductID, M2L.Num
                 ) AS tjTab1
            ) tjTab2 ON (mol.ID = tjTab2.ID AND mol.ProductID = tjTab2.PID)
        ) t1
        LEFT JOIN (
            SELECT  mol.MOrderID, mol.ID, pbl.productID, SUM(ku.num2 * ur2.bl / ur1.bl) num2_unit
            FROM    dbo.M2_ManuOrderLists mol
            LEFT JOIN dbo.M2_PlanBomList pbl
                    ON ( mol.BomListID = pbl.PID )
            LEFT JOIN dbo.erp_comm_unitRelation ur1
                    ON (
                         pbl.unit = ur1.unit
                         AND pbl.productID = ur1.ord
                       )
            LEFT JOIN dbo.sortonehy so
                    ON ( ur1.unit = so.ord )
            LEFT JOIN dbo.ku ku
                    ON ( ku.ord = pbl.productID )
            LEFT JOIN dbo.erp_comm_unitRelation ur2
                    ON (
                         ku.unit = ur2.unit
                         AND ku.ord = ur2.ord
                       )
            LEFT JOIN dbo.sortck sc
                    ON ( sc.ord = ku.ck )
            WHERE   (
                      CAST(sc.intro AS VARCHAR(MAX)) = '0'
                      OR ',' + CAST(sc.intro AS VARCHAR(MAX)) + ',' LIKE '%,' + CAST(@uid AS VARCHAR(20)) + ',%'
                    )
            GROUP BY mol.MOrderID, mol.ID, pbl.productID
          ) t2 ON (t1.MOrderID = t2.MOrderID AND t1.ID = t2.ID AND t1.productID = t2.productID)
      );
	  
GO

CREATE FUNCTION [dbo].[erp_f_GetMadeMaterialNums](
    @billtype INT,
    @billid VARCHAR(4000)
)  
RETURNS TABLE  
AS  
RETURN(
	select BillType,BillID,BillListID ID,ProductID,BomList,NeedNum,llnum,blnum,aknum,cknum knum,tnum,tnum_ll,tnum_bl,fnum,djnum,djtotalnum
	from [v_ProductionMaterials_AllNums_HasChilds] where billtype = @billtype and (isnull(@billid,'') = '' or dbo.existsPower2(billid,@billid,',')>0)
)

GO


Create FUNCTION [dbo].[erp_f_GetMadeMaterialStatus](
  @billtype INT,
  @billid VARCHAR(4000)
)  
RETURNS TABLE
AS  
RETURN(
	SELECT wa.ID,(CASE WHEN MAX(ISNULL(mx.llst,4)) = 0 THEN 0
				WHEN MIN(ISNULL(mx.llst,4)) < 2 THEN 1
				WHEN MIN(ISNULL(mx.llst,4)) = 2 THEN 2
				WHEN MIN(ISNULL(mx.llst,4)) = 3 THEN 3
				ELSE 4 END) llstatus,
				(CASE WHEN MAX(mx.djtotalnum) IS NULL THEN 4
				WHEN MAX(ISNULL(mx.djtotalnum,0)) = 0 THEN 0 
				WHEN MAX(wa.NumMake) > MAX(ISNULL(mx.djtotalnum,0)) THEN 1
				WHEN MAX(wa.NumMake) = MAX(ISNULL(mx.djtotalnum,0)) THEN 2
				WHEN MAX(wa.NumMake) < MAX(ISNULL(mx.djtotalnum,0)) THEN 3 END) djstatus
	FROM dbo.M2_WorkAssigns wa
	LEFT JOIN (
		SELECT wal.WAID,(CASE WHEN (wlmt.llnum - wlmt.tnum_ll) = 0 THEN 0 
				WHEN wal.num1 > (wlmt.llnum - wlmt.tnum_ll) THEN 1
				WHEN wal.num1 = (wlmt.llnum - wlmt.tnum_ll) THEN 2
				WHEN wal.num1 < (wlmt.llnum - wlmt.tnum_ll) THEN 3 END) llst,
				wlmt.djtotalnum
		FROM dbo.M2_WorkAssignLists wal
		INNER JOIN dbo.M2_WorkAssigns w ON wal.WAID = w.ID
		LEFT JOIN dbo.erp_f_GetMadeMaterialNums(@billtype,@billid) wlmt ON wal.ID = wlmt.ID
		WHERE ((@billtype = 54002 AND w.ptype = 0) OR (@billtype = 54005 AND w.ptype = 1))
		AND (LEN(@billid) = 0 OR CHARINDEX(','+CAST(wal.WAID AS VARCHAR(20))+',',','+@billid+',') > 0)
	) mx ON wa.ID = mx.WAID 
	WHERE ((@billtype = 54002 AND wa.ptype = 0) OR (@billtype = 54005 AND wa.ptype = 1)) 
	AND (LEN(@billid) = 0 OR CHARINDEX(','+CAST(wa.ID AS VARCHAR(20))+',',','+@billid+',') > 0)
	GROUP BY wa.ID
)

GO

--�ַ�������ȥ���ظ�
Create function [dbo].[GetDistinct](@str nvarchar(max),@s varchar(4))  
returns nvarchar(max)  
as  
begin
	declare @ret varchar(max) 
	select @str = dbo.CNumberList(@str)
	select @ret =(STUFF((SELECT @s + short_str
		FROM (
			select distinct short_str from dbo.split(@str,@s)
		) t order by short_str FOR xml path('')),1,len(@s),''))
	return @ret
end

GO

Create FUNCTION [dbo].[M2_WorkAssigns_Nums](@waid int)
returns table
as
return
(
	--��ѯ[�ɹ���/������]�� �ͼ��������ϸ�������������������������
	--ע:(���кϸ�������������������������)�������䷵����������(�����ǰ��ѯ���ݴ��ڷ������Ļ�)
	with with_waInfo
	as
	(
		select x.ID,x.WAID,x.ptype,x.ID BaseID from M2_WorkAssigns x
		where x.ID = @waid and x.del = 1 and x.Status <> 0
		union all
		select y.ID,z.ID,y.ptype,y.WAID BaseID from M2_WorkAssigns y
		inner join with_waInfo z on z.ID = y.WAID
		where y.del = 1 and y.Status <> 0 and y.ptype = 1
	)

	select 
		x.BaseID WAID,
		SUM(case x.ID when @waid then isnull(y.SerialNumber,0) else 0 end) sjnum,--�ͼ�����ֻ��ѯ��ǰ���ݵ�sumֵ
		SUM(isnull(certNum,0)) certNum,
		SUM(isnull(NumBF,0)) bfnum,
		SUM(isnull(NumScrap,0)) fgnum
	from with_waInfo x
	left join [erp_Bill_QualityTestLogic]() y on x.ID = y.PID and y.billType in(54002,54005)
	group by x.BaseID
	
)

GO

Create FUNCTION [dbo].[GetFirstIntValue](
		@arrayStr varchar(8000)
) 
returns int 
as  begin
	declare @i1 int;
	declare @itemstr varchar(12)
	while len(@arrayStr)>0
	begin
		set @i1 = charindex(',', @arrayStr)
		set @i1 = case when  @i1 = 0 then  len(@arrayStr)+1 else @i1 end
		set @itemstr = left(@arrayStr, @i1-1)
		if ISNUMERIC(@itemstr) =1 
		begin
			if cast(@itemstr as int)>0 
			begin
				return cast(@itemstr as int);
			end
		end
		set @arrayStr = SUBSTRING(@arrayStr, @i1+1, len(@arrayStr)-@i1)
	end
	return 0;
end

GO

Create FUNCTION [dbo].[YearMonth](
		@datefield datetime
)
returns int
	as begin 
	return  year(@datefield)*100 + month(@datefield)
end 

GO

CREATE function [dbo].[GetParentoRgs_partsId](@id int, @mode int)
returns varchar(1000)
as begin
	--@mode=1���ظ�ID
	--@mode=2��������·��ID
	--@mode=3��������·������
	declare @r varchar(1000)
	declare @p int
	set @r = ''
	if exists(select 1 from orgs_parts where [id]=@id)
	begin
		select @r = case when @mode=3 then name else cast(id as varchar(10)) end,@p=pid  from orgs_parts where [id]=@id
		if @mode = 1
		begin
			if dbo.GetParentoRgs_partsId(@p,@mode)>0
				set @r = dbo.GetParentoRgs_partsId(@p,@mode)
		end
		else if @mode = 2
		begin
			if len(dbo.GetParentoRgs_partsId(@p,@mode))>0 and dbo.GetParentoRgs_partsId(@p,@mode)<>'0'
				set @r = dbo.GetParentoRgs_partsId(@p,@mode) + ','+ @r
		end
		else if @mode = 3
		begin
			if len(dbo.GetParentoRgs_partsId(@p,@mode))>0 and dbo.GetParentoRgs_partsId(@p,@mode)<>'0'
				set @r = dbo.GetParentoRgs_partsId(@p,@mode) + ' '+ @r
		end
	end
	else
	begin
		set @r= '0'
	end
	return @r
end


GO
Create FUNCTION [dbo].[erp_Bill_GetWorkAssigns_NumInfo](
   @Ids nvarchar(4000)=''--�ɹ����򷵹���ID
)
returns table
as
return
(
	--��ѯ[�ɹ���/������]�� �ͼ��������ϸ�������������������������
	--ע:(���кϸ�������������������������)�������䷵����������(�����ǰ��ѯ���ݴ��ڷ������Ļ�)
	with tempIds as(
	   select cast(short_str as int) ID from dbo.split(@Ids,',') where len(isnull(@Ids,''))>0
	)
	,with_waInfo as
	(
		select x.ID,x.WAID as PID,x.ptype,x.ID BaseID 
		from tempIds t 
		inner join M2_WorkAssigns x on x.ID=t.ID
		where x.del = 1 and x.Status <> 0 
		union all
		select y.ID,z.ID as PID,y.ptype,y.WAID BaseID 
		from M2_WorkAssigns y
		inner join tempIds z on z.ID = y.WAID
		where y.del = 1 and y.Status <> 0 and y.ptype = 1 
	),Tempqcinfo as(
	  select 
				mq.ID QTID,
				mqt.bid PID,
				isnull(sum(case when isnull(mqt.TaskMXId,0)=0 then mqt.SerialNumber else 0 end),0) SerialNumber,  
				isnull(sum(
					case 
					when mq.QTResultAll = 0 and isnull(mq.QTMode,0)=1 and mq.poType in(3,4) then mqt.SerialNumber
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
					when (mq.QTResultAll = 0 and isnull(mq.QTMode,0)=1) and mq.poType in(3,4) then 0
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
					when mq.poType in (3,4) and isnull(mq.QTMode,0)=1 and mq.QTResultAll = 0 then 0
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
			from dbo.M2_QualityTestingLists mqt                                  
			inner join dbo.M2_QualityTestings mq on mq.ID = mqt.QTID 
			inner join with_waInfo z on z.ID=mqt.bid                                                                                              
			where mqt.del=1 and mq.del=1 
			and mq.poType in (3,4)                                           
			group by mq.ID, mqt.bid
	)
	,with_qtinfo as(
	   select  y.PID
	   ,sum(isnull(y.SerialNumber,0)) as SerialNumber
	   ,sum(isnull(y.certNum,0)) certNum
	   ,sum(isnull(y.NumBF,0)) NumBF
	   ,sum(isnull(y.NumScrap,0)) NumScrap
		from  M2_QualityTestings x
		inner join Tempqcinfo y on x.ID= y.QTID
		where (x.QTResultAll=0 or x.CkStatus>0)   --QTResultAll=1 and CkStatus=0 ��ʾ����ˣ� �������ݲ���Ҫ��ѯ����
		and x.poType in (3,4)
		group by y.PID
	)
	,with_gxinfo as(
	    select a.WAID,sum(isnull(a.BfNumByCheck,0)/isnull(b.ConversionBL,1)) as GXNumBF
        from dbo.M2_ProcessExecution_Result a
		inner join dbo.M2_ProcessExecution_Plan b on a.PlanID=b.ID
        inner join with_waInfo wa on a.WAID=wa.ID
        where a.BfNum>0
        group by a.WAID
	),with_sjinfo as(
	    select tt.WAID,SUM(ttl.Num) as sjnum from dbo.M2_OneSelfQualityTestingTask tt
		inner join dbo.M2_OneSelfQualityTestingTaskList ttl on tt.ID=ttl.TaskID
		inner join with_waInfo wa on tt.WAID=wa.ID
		group by tt.WAID
	)
	select 
		x.BaseID WAID,
		SUM(case when x.BaseID=x.ID then (isnull(sj.sjnum,0)+isnull(y.SerialNumber,0)) else 0 end) sjnum,--�ͼ�����ֻ��ѯ��ǰ���ݵ�sumֵ
		SUM(isnull(certNum,0)) certNum,
		SUM(isnull(NumBF,0)+isnull(gx.GXNumBF,0)) bfnum,
		SUM(isnull(NumScrap,0)) fgnum
	from with_waInfo x
	left join with_qtinfo y on x.ID = y.PID
	left join with_gxinfo gx on gx.WAID=x.ID
	left join with_sjinfo sj on x.ID=sj.WAID
	group by x.BaseID
	
)
GO
Create FUNCTION [dbo].[erp_Bill_GetOneSelfQualityTestingTask_NumInfo](
   @Ids nvarchar(4000)=''--�ɹ��ʼ�����ID
)
returns table
as
return
(
	with with_waInfo
	as
	(
		select x.ID from M2_OneSelfQualityTestingTask x
		where CHARINDEX(','+CAST(x.ID AS nvarchar(20))+',',','+@Ids+',') > 0
	)
	,with_qtinfo as(
			select
			mq.TaskId,
			mqt.codeBatch,
			isnull(sum(isnull(mqt.SerialNumber,0)),0) SerialNumber,  
			isnull(sum(
				case 
				when mq.QTResultAll = 0 and isnull(mq.QTMode,0)=1 then mqt.SerialNumber
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
				when (mq.QTResultAll = 0 and isnull(mq.QTMode,0)=1) then 0
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
				when mq.QTResultAll = 0 and isnull(mq.QTMode,0)=1 then 0
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
		from dbo.M2_QualityTestingLists mqt                                  
		inner join dbo.M2_QualityTestings mq on mq.ID = mqt.QTID 
		inner join with_waInfo tk on tk.ID=mq.TaskId                                                                                         
		where mqt.del=1 and mq.del=1 
		and mq.poType in (3,4)  and isnull(mq.TaskId,0)>0 
		and (mq.QTResultAll=0 or mq.CkStatus>0)                                         
		group by mq.ID,mq.TaskId,mqt.codeBatch
	)
	select 
		x.ID,
		isnull(y.codeBatch,0) codeBatch,
		SUM(isnull(y.SerialNumber,0)) QCNum,--�ͼ�����ֻ��ѯ��ǰ���ݵ�sumֵ
		SUM(isnull(y.certNum,0)) HGNum,
		SUM(isnull(y.NumBF,0)) BFNum,
		SUM(isnull(y.NumScrap,0)) FGNum
	from with_waInfo x
	left join with_qtinfo y on x.ID = y.TaskId
	group by x.ID,isnull(y.codeBatch,0)
)
GO
Create function [dbo].[erp_Bill_QualityTestLogicNew](
  @Ids nvarchar(4000)='',
  @billType int 
)
returns table
AS
return
(        
		with with_Info
		as
		(
			select x.ID from dbo.M2_WorkAssigns x
			where @billType=54002
			and x.ptype=0
			and (LEN(@Ids)=0 or CHARINDEX(','+CAST(x.ID AS nvarchar(20))+',',','+@Ids+',') > 0)
			union all
			select x.ID from dbo.M2_WorkAssigns x
			where @billType=54005
			and x.ptype=1
			and (LEN(@Ids)=0 or CHARINDEX(','+CAST(x.ID AS nvarchar(20))+',',','+@Ids+',') > 0)
			union all
			select ool.ID from dbo.M2_OutOrderlists ool
			inner join dbo.M2_OutOrder oo on ool.outID=oo.ID
			where @billType=54003
			and oo.wwType=0
			and (LEN(@Ids)=0 or CHARINDEX(','+CAST(oo.ID AS nvarchar(20))+',',','+@Ids+',') > 0)
			union all
			select ool.ID from dbo.M2_OutOrderlists ool
			inner join dbo.M2_OutOrder oo on ool.outID=oo.ID
			where @billType=54006
			and oo.wwType=1
			and (LEN(@Ids)=0 or CHARINDEX(','+CAST(oo.ID AS nvarchar(20))+',',','+@Ids+',') > 0)
			union all
			select tt.ID from (
				select y.ID as ID
				from M2_WFP_Assigns x
				inner join M2_OutOrderlists y on x.ID = y.WFPAID and y.del = 1
				where @billType=5400256 --��ѯ�ɹ��򷵹���ع���ί�ⵥ��ϸID
				and CHARINDEX(','+CAST(x.WAID AS nvarchar(20))+',',','+@Ids+',') > 0
			    group by y.ID)tt
		) 
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
			and (LEN(@Ids)=0 or 
			    exists(
			      select 1 from with_Info info where info.ID=mqt.bid
			    )
			)                                                   
			group by mq.ID, mqt.bid
		) y on x.ID= y.QTID
		where x.QTResultAll=0  or x.CkStatus>0   --QTResultAll=1 and CkStatus=0 ��ʾ����ˣ� �������ݲ���Ҫ��ѯ����
		and (LEN(@Ids)=0 or 
			    exists(
			      select 1 from with_Info info where info.ID=y.PID
			    )
			)   
    )

GO
Create function [dbo].[erp_WorkAssignsWFPNumInfo](
    @Ids nvarchar(4000)=''--�ɹ���ID�򷵹���ID
)
returns table
AS
return
( 
    with workInfo as(
         select  CAST(wa.short_str as int) as ID
         from dbo.split(@Ids,',') wa
         where len(isnull(@Ids,''))>0
         union all
         select wa.ID 
         from dbo.M2_WorkAssigns wa 
         where len(isnull(@Ids,''))=0 and wa.del=1
    )
	select t.*,
		(case 
			when isnull(t.CanExecNum,0) >= 0 
			then isnull(t.CanExecNum,0)
			else 0 
		end) as sysl,--ʣ������
		isnull(Nums.execStatus_tit,case Nums.isOut when 0 then 'δִ��' else 'δ���' end) as execStatus_tit
	from(
	select wfpa.ID as WFPAID,
	isnull(wfpa.isOut,0) as isOut, 
	wfpa.NumMake as pgsl,
	SUM(isnull(per.HgNum,0)+isnull(per.HgNumByRework,0)) as hgsl,
	SUM(isnull(per.FgNum,0)) as fgsl,
	SUM(isnull(per.BfNum,0)) as bfsl,
    SUM(isnull(per.CanExecNum,0)) as CanExecNum,
	(case wfpa.isOut when 0 then
	(select MIN(y.execDate) from dbo.M2_ProcedureProgres y where y.WFPAID=wfpa.ID and y.del=1)
	else (select min(oo.odate) 
			from dbo.M2_OutOrderlists ool
			inner join dbo.M2_OutOrder oo on ool.outID=oo.ID
			where oo.del=1 and ool.WFPAID=wfpa.ID) end)
	as startDate,--ʵ�ʿ�ʼʱ��
	(case wfpa.isOut when 0 then
    (select Max(y.execDate) from dbo.M2_ProcedureProgres y where y.WFPAID=wfpa.ID and y.del=1)  
     else (select max(qt.QTDate) 
			from dbo.M2_OutOrderlists ool
			inner join dbo.M2_OutOrder oo on ool.outID=oo.ID
			inner join dbo.M2_QualityTestingLists qtl on qtl.bid=ool.ID
			inner join dbo.M2_QualityTestings qt on qt.poType=2 and qtl.QTID=qt.ID
			where oo.del=1 and qt.del=1 and ool.WFPAID=wfpa.id) end) 
    as endDate --ʵ�ʽ���ʱ��
	from workInfo wa 
	inner join M2_ProcessExecution_Result per on wa.ID=per.WAID
	inner join dbo.M2_WFP_Assigns wfpa on wfpa.ID=per.NodeID
	where per.NodeType in(0,1)
	group by wfpa.ID,wfpa.NumMake,wfpa.isOut
	) t 
	left join [erp_ProcedureProgresNums2] Nums on t.WFPAID = Nums.WFPAID          
	WHERE (isnull(t.hgsl,0)+isnull(t.bfsl,0)+isnull(t.fgsl,0))>0
 )
GO
Create function [dbo].[f_ProductionMaterials_Log](
  @Ids nvarchar(max)='',
  @billType int 
)
returns table
AS
return
(   
    with Idlists as(
       select CAST(isnull(short_str,0) as int) as ID from dbo.split(@Ids,',') where LEN(isnull(@Ids,''))>0
    )   
	select 
		BillType = case wa.ptype when 0 then 54002 else 54005 end,			--��ǰ��������
		BillType_Base = case waBase.ptype when 0 then 54002 else 54005 end,	--Դ��������
		BillID = wa.ID,														--��ǰ����ID
		BillID_Base = ISNULL(wa.WAID,wa.ID),								--Դ����ID
		BillID_Parent = (case when wa.fromtype in(6,7) then ISNULL(wa.WAID,wa.ID) else ISNULL((case when qt.potype in(3,4) then parent.bid else 0 end),0) end),						--��ǰ���ݵ���һ��(�ɹ�/����)ID ISNULL(parent.BillID,0)
		BillListID = wal.ID,												--��ǰ��������ID
		BillListID_Base = ISNULL(walBase.id,(case when wa.ptype = 0 then wal.id else 0 end)),								--Դ��������ID
		BillListID_Parent = 0,
		wal.ProductID,
		BomList = ISNULL(wal.BomList,0),
		NeedNum = wal.num1 													--��������
	from M2_WorkAssignLists wal
	inner join M2_WorkAssigns wa on wal.WAID = wa.ID and wa.del = 1 and wa.[Status] <> 0
	inner join m2_WorkAssigns waBase on waBase.ID = isnull(wa.waid,wa.ID) and waBase.del = 1 and waBase.[Status] <> 0
	left join dbo.M2_QualityTestingLists parent on parent.ID=wa.QTListID and parent.del=1 
	left join dbo.M2_QualityTestings qt on parent.QTID=qt.ID
	left join m2_workAssignLists walBase on (wa.ptype = 2 or wal.ID = walBase.ID) and walBase.waid = waBase.id 
	and walBase.productID = wal.productID and isnull(walBase.BomList,0) = isnull(wal.BomList,0)
	where @billType in(54002,54005)
	and (LEN(@Ids)=0 or exists(select 1 from Idlists ids where ids.ID=wa.ID))
	and ((@billType=54002 and wa.ptype=0) or (@billType=54005 and wa.ptype=1))
	union all
	select
		BillType = case oo.wwtype when 0 then 54003 else 54006 end,
		BillType_Base = case oo.wwtype when 0 then 54003 else 54002 end,
		BillID = oo.ID,
		BillID_Base = ISNULL(isnull(wa.waid,wa.id),oo.ID),
		BillID_Parent = isnull(wa.ID,0),
		ool.ID as BillListID,
		ISNULL(wal.ID,case oo.wwtype when 0 then ool.ID else 0 end)as BillListID_Base,--����ί����ֶ�Ϊ0����Ϊ����ί��ֱ����ӵ�����
		isnull(wal.ID,case oo.wwtype when 0 then ool.ID else 0 end) BillListID_Parent,
		ool.ProductID,
		ISNULL(ool.BomListID,0) BomList,
		ool.num as NeedNum
	from M2_OutOrderlists_wl ool
	inner join M2_OutOrder oo on ool.outID = oo.ID and oo.del = 1 and oo.[status] <> 0
	left join M2_WorkAssignLists wal on isnull(ool.walID,0) = wal.ID and wal.del = 1
	left join m2_WorkAssigns wa on wa.id = wal.waid and wa.del = 1 and wa.status <> 0
    where isnull(ool.Mergeinx,0)<=0 
    and @billType in(54003,54006)
    and (LEN(@Ids)=0 or exists(select 1 from Idlists ids where ids.ID=oo.ID))
    and ((@billType=54003 and oo.wwtype=0) or (@billType=54006 and oo.wwtype=1))
    union all --�ɹ���������Ӧ�Ĺ���ί��
	select
		BillType =54006,
		BillType_Base = case wa.ptype when 0 then 54002 else 54005 end,
		BillID = oo.ID,
		BillID_Base = ISNULL(isnull(wa.waid,wa.id),oo.ID),
		BillID_Parent = isnull(wa.ID,0),
		ool.ID as BillListID,
		ISNULL(isnull(walBase.ID,wal.ID),0)as BillListID_Base,--����ί����ֶ�Ϊ0����Ϊ����ί��ֱ����ӵ�����
		isnull(wal.ID,0) BillListID_Parent,
		ool.ProductID,
		ISNULL(ool.BomListID,0) BomList,
		ool.num as NeedNum
	from M2_OutOrderlists_wl ool
	inner join M2_OutOrder oo on ool.outID = oo.ID and oo.del = 1 and oo.[status] <> 0
	left join M2_WorkAssignLists wal on isnull(ool.walID,0) = wal.ID and wal.del = 1
	left join m2_WorkAssigns wa on wa.id = wal.waid and wa.del = 1 and wa.status <> 0
	left join m2_workAssignLists walBase on walBase.waid = wa.waid and walBase.productID = wal.productID and isnull(walBase.BomList,0) = isnull(wal.BomList,0)
    where @billType in(54002,54005)
    and oo.wwtype=1
    and ((@billType=54002 and wa.ptype=0) or (@billType=54005 and wa.ptype=1))
    and isnull(ool.Mergeinx,0)<=0 
    and (LEN(@Ids)=0 or exists(select 1 from Idlists ids where ids.ID=wa.ID))
 )
GO
Create function [dbo].[f_ProductionMaterials_TFNums](
  @Ids nvarchar(max)='',
  @billType int,
  @MaterialType int=0--0���������У������첹�ϣ� 2�����Ϊ�����˷�;3����Ϊ�����˷�  
)
returns table
AS
return
( 
   with Idlists as(
       select CAST(isnull(short_str,0) as int) as ID from dbo.split(@Ids,',') where LEN(isnull(@Ids,''))>0
   )
   
	--��������/��������
	SELECT 
		BillType = (case w.ptype when 0 then 54002 else 54005 end),
	    max(w.ID) as ID,
		a.ID ListID,
		SUM((CASE WHEN d.OrderType = 2 THEN c.num1 ELSE 0 END)) tnum,
		SUM((CASE WHEN d.OrderType = 3 THEN c.num1 ELSE 0 END)) fnum,
		bp.MaterialType		--2�����Ϊ�����˷�;3����Ϊ�����˷�
	FROM dbo.M2_WorkAssignLists a
	INNER JOIN dbo.M2_WorkAssigns w ON a.WAID = w.ID
	INNER JOIN dbo.M2_MaterialOrderLists b ON a.ID = b.ListID and b.poType in(1,2) and b.del = 1  and isnull(b.Mergeinx,0)<=0  
	INNER JOIN dbo.M2_MaterialOrders bp on bp.ID = b.MOID
	INNER JOIN dbo.M2_MaterialRegisterLists c ON c.del = 1 AND c.MOLID = b.ID and isnull(c.Mergeinx,0)<=0
	INNER JOIN dbo.M2_MaterialRegisters d ON c.MRID = d.ID AND d.status <> 0
	where @billType in(54002,54005)
	and (@MaterialType=0 or bp.MaterialType=@MaterialType)  
	and (LEN(@Ids)=0 or exists(select 1 from Idlists ids where ids.ID=w.ID))
	and ((@billType=54002 and w.ptype=0) or (@billType=54005 and w.ptype=1))
	GROUP BY a.ID,w.ptype,bp.MaterialType
	union all
	SELECT 
		BillType = (case o.wwType when 0 then 54003 else 54006 end),
		max(o.ID) as ID,
		oow.ID ListID,
		SUM(CASE WHEN mr.OrderType = 2 THEN mrl.num1 ELSE 0 END) tnum,
		SUM(CASE WHEN mr.OrderType = 3 THEN mrl.num1 ELSE 0 END) fnum,
		bp.MaterialType		--2�����Ϊ�����˷�;3����Ϊ�����˷�
    FROM dbo.M2_OutOrderlists_wl oow
    INNER JOIN dbo.M2_OutOrder o ON oow.outID = o.ID
    INNER JOIN dbo.M2_MaterialOrderLists mol ON oow.ID = mol.ListID and mol.poType in(3,4) and mol.del = 1 and isnull(mol.Mergeinx,0)<=0 
	INNER JOIN dbo.M2_MaterialOrders bp on bp.ID = mol.MOID
    --INNER JOIN dbo.kuoutlist2 kl ON mol.ID = kl.M2_OrderID AND kl.del = 1 AND kl.sort1 in (3,5,12)            
    INNER JOIN dbo.M2_MaterialRegisterLists mrl ON mol.id = mrl.MOLID and mrl.del = 1 and isnull(mrl.Mergeinx,0)<=0
    INNER JOIN dbo.M2_MaterialRegisters mr ON mrl.MRID = mr.ID and mr.del = 1 and mr.status <> 0
    where @billType in(54003,54006)
    and (@MaterialType=0 or bp.MaterialType=@MaterialType)  
    and (LEN(@Ids)=0 or exists(select 1 from Idlists ids where ids.ID=o.ID))
    and ((@billType=54003 and o.wwtype=0) or (@billType=54006 and o.wwtype=1))
    GROUP BY oow.ID,o.wwType,bp.MaterialType
    union all--�ɹ�������������Ӧ�Ĺ���ί��
	SELECT 
		BillType = 54006,
		max(o.ID) as ID,
		oow.ID ListID,
		SUM(CASE WHEN mr.OrderType = 2 THEN mrl.num1 ELSE 0 END) tnum,
		SUM(CASE WHEN mr.OrderType = 3 THEN mrl.num1 ELSE 0 END) fnum,
		bp.MaterialType		--2�����Ϊ�����˷�;3����Ϊ�����˷�
    FROM dbo.M2_OutOrderlists_wl oow
    INNER JOIN dbo.M2_OutOrder o ON oow.outID = o.ID
    INNER JOIN dbo.M2_WorkAssignLists wal on isnull(oow.walID,0) = wal.ID and wal.del = 1
	INNER JOIN dbo.m2_WorkAssigns wa on wa.id = wal.waid and wa.del = 1 and wa.status <> 0
    INNER JOIN dbo.M2_MaterialOrderLists mol ON oow.ID = mol.ListID and mol.poType=4 and mol.del = 1 and isnull(mol.Mergeinx,0)<=0
	INNER JOIN dbo.M2_MaterialOrders bp on bp.ID = mol.MOID
    --INNER JOIN dbo.kuoutlist2 kl ON mol.ID = kl.M2_OrderID AND kl.del = 1 AND kl.sort1 in (3,5,12)            
    INNER JOIN dbo.M2_MaterialRegisterLists mrl ON mol.id = mrl.MOLID and mrl.del = 1 and isnull(mrl.Mergeinx,0)<=0
    INNER JOIN dbo.M2_MaterialRegisters mr ON mrl.MRID = mr.ID and mr.del = 1 and mr.status <> 0
    where @billType in(54002,54005)
    and (@MaterialType=0 or bp.MaterialType=@MaterialType)  
    and o.wwtype=1
    and (LEN(@Ids)=0 or exists(select 1 from Idlists ids where ids.ID=wa.ID))
    and ((@billType=54002 and wa.ptype=0) or (@billType=54005 and wa.ptype=1))
    GROUP BY oow.ID,o.wwType,bp.MaterialType
 )
GO

Create function [dbo].[f_ProductionMaterials_LBNums](
  @Ids nvarchar(4000)='',
  @billType int 
)
returns table
AS
return
( 
	--��������/��������
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
	where @billType in(54002,54005)
	and (LEN(@Ids)=0 or CHARINDEX(','+CAST(wa.ID AS nvarchar(20))+',',','+@Ids+',') > 0)
	and ((@billType=54002 and wa.ptype=0) or (@billType=54005 and wa.ptype=1))
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
	where @billType in(54003,54006)
    and (LEN(@Ids)=0 or CHARINDEX(','+CAST(o.ID AS nvarchar(20))+',',','+@Ids+',') > 0)
    and ((@billType=54003 and o.wwtype=0) or (@billType=54006 and o.wwtype=1))
	group by o.wwType,oow.ID,mol.poType 
	union all--�ɹ�������������Ӧ�Ĺ���ί��
	select
		BillType = 54006,
		max(o.ID) as ID,
		oow.ID ListID,
		SUM(case when (mo.MaterialType in(1,2)) then mol.num1 else 0 end) llnum,
		SUM(case when (mo.MaterialType in(3)) then mol.num1 else 0 end) blnum 
	from dbo.M2_OutOrderlists_wl oow
	inner join dbo.M2_OutOrder o ON oow.outID = o.ID
	INNER JOIN dbo.M2_WorkAssignLists wal on isnull(oow.walID,0) = wal.ID and wal.del = 1
	INNER JOIN dbo.m2_WorkAssigns wa on wa.id = wal.waid and wa.del = 1 and wa.status <> 0
	left join dbo.M2_MaterialOrderLists mol ON oow.ID = mol.ListID and mol.poType in (3,4) and mol.del = 1
	left join dbo.M2_MaterialOrders mo ON mol.MOID = mo.ID AND mo.del = 1 and mo.[status] <> 0
	where @billType in(54002,54005)
    and o.wwtype=1
    and (LEN(@Ids)=0 or CHARINDEX(','+CAST(wa.ID AS nvarchar(20))+',',','+@Ids+',') > 0)
    and ((@billType=54002 and wa.ptype=0) or (@billType=54005 and wa.ptype=1))
	group by o.wwType,oow.ID,mol.poType 
  )
go
Create function [dbo].[f_ProductionMaterials_LBACKNums](
  @Ids nvarchar(max)='',
  @billType int 
)
returns table
AS
return
( 
     with Idlists as(
       select CAST(isnull(short_str,0) as int) as ID from dbo.split(@Ids,',') where LEN(isnull(@Ids,''))>0
    )
	--��������/��������
	select
		BillType = case wa.ptype when 0 then 54002 else 54005 end,
		max(wa.ID) as ID,
		wal.ID ListID,
		SUM(case when (mo.MaterialType in(1,2)) then mol.num1 else 0 end) llnum,
		SUM(case when (mo.MaterialType in(3)) then mol.num1 else 0 end) blnum,
		SUM(isnull(mol.cknum,0)) applynum,
		SUM(isnull(mol.cknum2,0)) cknum
	from dbo.M2_WorkAssignLists wal
	inner join dbo.M2_WorkAssigns wa ON wal.WAID = wa.ID
	left join dbo.M2_MaterialOrderLists mol ON wal.ID = mol.ListID and mol.poType in (1,2) and mol.del = 1 AND ISNULL(mol.Mergeinx,0) <= 0
	left join dbo.M2_MaterialOrders mo ON mol.MOID = mo.ID AND mo.del = 1 and mo.[status] <> 0
	where @billType in(54002,54005)
	and (LEN(@Ids)=0 or exists(select 1 from Idlists ids where ids.ID=wa.ID))
	and ((@billType=54002 and wa.ptype=0) or (@billType=54005 and wa.ptype=1))
	group by wa.ptype,wal.ID,mol.poType
	union all
	select
		BillType = case o.wwType when 0 then 54003 else 54006 end,
		max(o.ID) as ID,
		oow.ID ListID,
		SUM(case when (mo.MaterialType in(1,2)) then mol.num1 else 0 end) llnum,
		SUM(case when (mo.MaterialType in(3)) then mol.num1 else 0 end) blnum,
		SUM(isnull(mol.cknum,0)) applynum,
		SUM(isnull(mol.cknum2,0)) cknum
	from dbo.M2_OutOrderlists_wl oow
	inner join dbo.M2_OutOrder o ON oow.outID = o.ID
	left join dbo.M2_MaterialOrderLists mol ON oow.ID = mol.ListID and mol.poType in (3,4) and mol.del = 1 AND ISNULL(mol.Mergeinx,0) <= 0
	left join dbo.M2_MaterialOrders mo ON mol.MOID = mo.ID AND mo.del = 1 and mo.[status] <> 0
	where @billType in(54003,54006) AND ISNULL(oow.Mergeinx,0) <= 0
    and (LEN(@Ids)=0 or exists(select 1 from Idlists ids where ids.ID=o.ID))
    and ((@billType=54003 and o.wwtype=0) or (@billType=54006 and o.wwtype=1))
	group by o.wwType,oow.ID,mol.poType 
	union all--�ɹ�������������Ӧ�Ĺ���ί��
	select
		BillType = 54006,
		max(o.ID) as ID,
		oow.ID ListID,
		SUM(case when (mo.MaterialType in(1,2)) then mol.num1 else 0 end) llnum,
		SUM(case when (mo.MaterialType in(3)) then mol.num1 else 0 end) blnum, 
		SUM(isnull(mol.cknum,0)) applynum,
		SUM(isnull(mol.cknum2,0)) cknum
	from dbo.M2_OutOrderlists_wl oow
	inner join dbo.M2_OutOrder o ON oow.outID = o.ID
	INNER JOIN dbo.M2_WorkAssignLists wal on isnull(oow.walID,0) = wal.ID and wal.del = 1
	INNER JOIN dbo.m2_WorkAssigns wa on wa.id = wal.waid and wa.del = 1 and wa.status <> 0
	left join dbo.M2_MaterialOrderLists mol ON oow.ID = mol.ListID and mol.poType in (3,4) and mol.del = 1 AND ISNULL(mol.Mergeinx,0) <= 0
	left join dbo.M2_MaterialOrders mo ON mol.MOID = mo.ID AND mo.del = 1 and mo.[status] <> 0
	where @billType in(54002,54005) AND ISNULL(oow.Mergeinx,0) <= 0
    and o.wwtype=1
    and (LEN(@Ids)=0 or exists(select 1 from Idlists ids where ids.ID=wa.ID))
    and ((@billType=54002 and wa.ptype=0) or (@billType=54005 and wa.ptype=1))
	group by o.wwType,oow.ID,mol.poType 
  )
GO
Create function [dbo].[f_ProductionMaterials_DJNums](
  @Ids nvarchar(max)='',
  @billType int 
)
returns table
AS
return
(  
   with Idlists as(
       select CAST(isnull(short_str,0) as int) as ID from dbo.split(@Ids,',') where LEN(isnull(@Ids,''))>0
    )
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
		where @billType in(54002,54005)
		and mr.poType IN(1,4)
	    and (LEN(@Ids)=0 or exists(select 1 from Idlists ids where ids.ID=wa.ID))
	    and ((@billType=54002 and wa.ptype=0) or (@billType=54005 and wa.ptype=1))
		group by wal.ID,wa.ptype,mr.ID
		union all
		select 
			BillType = 54003,
			outwllist.ID  as ListID,
			mr.ID,
			sum(mrl.num1) as djnum
		from M2_MaterialRegisterLists mrl 
		inner join M2_MaterialRegisters mr on mrl.MRID = mr.ID and mr.del = 1 and ISNULL(mr.[status],0) <> 0 and mr.PoType=3
		inner join M2_OutOrderlists_wl outwllist on outwllist.ID = mrl.ListID
		inner join M2_OutOrderlists outlist on outlist.del = 1 and outlist.ID = mr.bid
		where @billType=54003
		 and (LEN(@Ids)=0 or exists(select 1 from Idlists ids where ids.ID=outlist.outId))
		group by outwllist.ID,mr.ID
	) x 
	INNER JOIN dbo.M2_MaterialRegisters y ON x.ID = y.ID
	GROUP BY x.BillType,x.ListID
)
go

Create function [dbo].[f_ProductionMaterials_AllNums](
  @Ids nvarchar(max)='',
  @billType int 
)
returns table
AS
return
(  
     
    with tfnumlist as(
       select ListID,BillType,MaterialType,tnum,fnum from [dbo].[f_ProductionMaterials_TFNums](@Ids,@billType,2) tfNums1
       union all
       select ListID,BillType,MaterialType,tnum,fnum from [dbo].[f_ProductionMaterials_TFNums](@Ids,@billType,3) tfNums1
    ),
    LBACKNumlist as(
       select ListID,BillType,llnum,blnum,applynum,cknum from [dbo].[f_ProductionMaterials_LBACKNums](@Ids,@billType)
    ),
    DJNumlist as (
        select ListID,BillType,djnum,djtotalnum from [dbo].[f_ProductionMaterials_DJNums](@Ids,@billType)
    )
	select 
		[log].*,
		ISNULL(lbNums.llnum,0) llnum,
		ISNULL(lbNums.blnum,0) blnum,
		ISNULL(lbNums.applynum,0) aknum,
		ISNULL(lbNums.cknum,0) cknum,
		ISNULL(tfNums1.tnum,0)+isnull(tfNums3.tnum,0) tnum,
		ISNULL(tfNums1.tnum,0) tnum_ll,		--��������
		ISNULL(tfNums3.tnum,0) tnum_bl,		--��������
		ISNULL(tfNums1.fnum,0)+isnull(tfNums3.fnum,0) fnum,
		ISNULL(tfNums1.fnum,0) fnum_ll,		--���Ϸ���
		ISNULL(tfNums3.fnum,0) fnum_bl,		--���Ϸ���
		ISNULL(djNums.djnum,0) djnum,
		ISNULL(djNums.djtotalnum,0) djtotalnum
	from [dbo].[f_ProductionMaterials_Log](@Ids,@billType) [log]
	left join LBACKNumlist lbNums on [log].BillType = lbNums.BillType and [log].BillListID = lbNums.ListID
	left join tfnumlist tfNums1 on [log].BillType = tfNums1.BillType and [log].BillListID = tfNums1.ListID and tfNums1.MaterialType = 2	--�����˷�
	left join tfnumlist tfNums3 on [log].BillType = tfNums3.BillType and [log].BillListID = tfNums3.ListID and tfNums3.MaterialType = 3	--�����˷�
	left join DJNumlist djNums on [log].BillType = djNums.BillType and [log].BillListID = djNums.ListID
 )
GO
Create function [dbo].[f_ProductionMaterials_AllNums_HasChilds](
  @Ids nvarchar(max)='',
  @billType int 
)
returns table
AS
return
(  
	--�ɹ�(��������ί��)
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
	from [dbo].[f_ProductionMaterials_AllNums](@Ids,@billType) x
	where @billType=54002
	and x.BillType_Base = 54002 and x.BillType in(54002,54006) and x.BillListID_Base > 0
	group by x.BillType_Base,ISNULL(NULLIF(x.BillID_Parent,0),BillID),ISNULL(NULLIF(x.BillListID_Base,0),x.BillListID),x.ProductID,x.BomList
	having SUM(case x.BillType when 54002 then x.NeedNum else 0 end)>0
	union all
	--����(��������ί��)
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
	from [dbo].[f_ProductionMaterials_AllNums](@Ids,@billType) x
	where @billType=54005
	and x.BillType in(54005,54006) and x.BillID_Parent > 0 --�ų�����ί��ֱ�������(��Ϊû�ж�Ӧ����������,�޻�������)
	group by (case x.BillType when 54005 then x.BillID else x.BillID_Parent end),ISNULL(NULLIF(x.BillListID_Parent,0),x.BillListID),x.ProductID,x.BomList
	having SUM(case x.BillType when 54005 then x.NeedNum else 0 end)>0
	union all
	--����ί��/����ί��
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
	from [dbo].[f_ProductionMaterials_AllNums](@Ids,@billType) x
	where @billType in(54003,54006)
	and x.BillType in(54003,54006)
	group by x.BillType,x.BillID,x.BillListID,x.ProductID,x.BomList
	having SUM(x.NeedNum)>0
  )

GO

create function [dbo].[HtmlConvert](@Text nvarchar(4000),@ConvertType int)
--@Text �����ַ�    
--@ConvertType=0 �ӽ�����html���룬 ת��      
--@ConvertType=1 �ӽ���ת���Ĵ��룬 ��ԭhtml����
returns nvarchar(4000)
begin

declare @ZY_Text nvarchar(4000)
if @ConvertType=0
begin
	set @ZY_Text=REPLACE((REPLACE((REPLACE(@Text,'&','&amp;')),'>','&gt;')),'<','&lt;')
end

else
begin
	set @ZY_Text=REPLACE((REPLACE((REPLACE(@Text,'&amp;','&')),'&gt;','>')),'&lt;','<')
	
end

return @ZY_Text
end
GO
Create FUNCTION [dbo].[erp_f_GetOutMaterialNums](
  @billtype INT,
  @billid VARCHAR(4000),
  @isDetail INT
)  
RETURNS TABLE  
AS  
RETURN(
	select 
		(CASE WHEN @isDetail = 1 THEN (CASE WHEN ISNULL(t.Mergeinx,0) < 0 THEN ABS(t.Mergeinx) ELSE t.ID END) ELSE t.ID END) ID,
		max(t.haveBill) haveBill,
		BillType,BillID,ProductID,max(BomList) BomList,
		sum(NeedNum) NeedNum,
		sum(llnum) llnum,
		sum(blnum) blnum,
		sum(aknum) aknum,
		sum(cknum) cknum,
		sum(tnum) tnum,
		sum(tnum_ll) tnum_ll,
		sum(tnum_bl) tnum_bl,
		sum(fnum) fnum,
		sum(djnum) rnum,
		max(djtotalnum) djtotalnum
	from(
		SELECT 
		oow.ID ID,
		oow.Mergeinx,
		(CASE WHEN COUNT(kl.ListID) > 0 OR COUNT(mrl.ListID) > 0 THEN 1 ELSE 0 END) haveBill
		FROM dbo.M2_OutOrderlists_wl oow
		INNER JOIN dbo.M2_OutOrder oo ON oow.outID = oo.ID
		LEFT JOIN(
			SELECT knums.ListID
			FROM dbo.M2_OutOrderlists_wl oow
			INNER JOIN dbo.M2_OutOrder o ON oow.outID = o.ID
			left join [dbo].[f_kNum](@billid,@billtype) knums on oow.id = knums.ListID 
			WHERE ((@billtype = 54003 AND o.wwType = 0) OR (@billtype = 54006 AND o.wwType = 1))
			AND (LEN(ISNULL(@billid,'')) = 0 OR CHARINDEX(','+CAST(oow.outID AS VARCHAR(20))+',',','+@billid+',') > 0) 
		) kl ON oow.ID = kl.ListID                                          
		LEFT JOIN (
			SELECT mrl.ListID, SUM(CASE WHEN mr.OrderType = 1 THEN (ISNULL(mro.num1,0)) ELSE 0 END) rnum
			FROM M2_OutOrderlists_wl oow
			INNER join dbo.M2_OutOrder o ON oow.outID = o.ID
			INNER JOIN dbo.M2_MaterialRegisterLists mrl ON oow.ID = mrl.ListID and mrl.del = 1
			INNER JOIN dbo.M2_MaterialRegisters mr ON mrl.MRID = mr.ID AND mr.poType = (CASE WHEN @billtype = 54003 THEN 3 ELSE 4 END) AND mr.del = 1 and mr.status <> 0
			LEFT JOIN dbo.M2_RegisterOccupy mro ON mrl.ID = mro.MRLID AND mro.isOld = 0
			WHERE ((@billtype = 54003 AND o.wwType = 0) OR (@billtype = 54006 AND o.wwType = 1))
			AND (LEN(ISNULL(@billid,'')) = 0 OR CHARINDEX(','+CAST(oow.outID AS VARCHAR(20))+',',','+@billid+',') > 0) GROUP BY mrl.ListID
		) mrl ON oow.ID = mrl.ListID
		WHERE ((@billtype = 54003 AND oo.wwType = 0) OR (@billtype = 54006 AND oo.wwType = 1))
		AND (LEN(ISNULL(@billid,'')) = 0 OR CHARINDEX(','+CAST(oow.outID AS VARCHAR(20))+',',','+@billid+',') > 0) 
		GROUP BY oow.ID,oow.Mergeinx
    ) t
    inner join [dbo].[f_ProductionMaterials_AllNums](@billid,@billtype) on billtype in(54003,54006) and billListID = t.id 
    group by (CASE WHEN @isDetail = 1 THEN (CASE WHEN ISNULL(t.Mergeinx,0) < 0 THEN ABS(t.Mergeinx) ELSE t.ID END) ELSE t.ID END),BillType,BillID,ProductID
)
GO
Create FUNCTION [dbo].[erp_f_GetOutMaterialStatus](
  @billtype INT,
  @billid VARCHAR(4000)
)  
RETURNS TABLE  
AS  
RETURN(
	SELECT oo.ID,(CASE WHEN MAX(mx.llst) = 0 THEN 0
				WHEN MIN(ISNULL(mx.llst,4)) < 2 THEN 1
				WHEN MIN(ISNULL(mx.llst,4)) = 2 THEN 2
				WHEN MIN(ISNULL(mx.llst,4)) = 3 THEN 3
				ELSE 4 END) llstatus,
				(CASE WHEN MAX(mx.djst) = 0 THEN 0
				WHEN MIN(ISNULL(mx.djst,4)) < 2 THEN 1
				WHEN MIN(ISNULL(mx.djst,4)) = 2 THEN 2
				WHEN MIN(ISNULL(mx.djst,4)) = 3 THEN 3
				ELSE 4 END) djstatus
	FROM dbo.M2_OutOrder oo
	LEFT JOIN (
		SELECT oow.outID,(CASE WHEN (wlmt.llnum - wlmt.tnum_ll) = 0 THEN 0 
				WHEN oow.num > (wlmt.llnum - wlmt.tnum_ll) THEN 1
				WHEN oow.num = (wlmt.llnum - wlmt.tnum_ll) THEN 2
				WHEN oow.num < (wlmt.llnum - wlmt.tnum_ll) THEN 3 END) llst,
				(CASE WHEN wlmt.djtotalnum = 0 THEN 0 
				WHEN ool.num1 > wlmt.djtotalnum THEN 1
				WHEN ool.num1 = wlmt.djtotalnum THEN 2
				WHEN ool.num1 < wlmt.djtotalnum THEN 3 END) djst
		FROM dbo.M2_OutOrderlists_wl oow
		INNER JOIN dbo.M2_OutOrder o ON oow.outID = o.ID
		INNER JOIN dbo.M2_OutOrderlists ool ON o.ID = ool.outID
		LEFT JOIN dbo.erp_f_GetOutMaterialNums(@billtype,@billid,0) wlmt ON oow.ID = wlmt.ID
		WHERE ISNULL(oow.Mergeinx,0) <= 0 
		AND ((@billtype = 54003 AND o.wwType = 0) OR (@billtype = 54006 AND o.wwType = 1))
		AND (LEN(@billid) = 0 OR CHARINDEX(','+CAST(oow.outID AS VARCHAR(20))+',',','+@billid+',') > 0)
	) mx ON oo.ID = mx.outID 
	WHERE ((@billtype = 54003 AND oo.wwType = 0) OR (@billtype = 54006 AND oo.wwType = 1))
	AND (LEN(@billid) = 0 OR CHARINDEX(','+CAST(oo.ID AS VARCHAR(20))+',',','+@billid+',') > 0)
	GROUP BY oo.ID
)
GO
Create function [dbo].[erp_Bill_QualityTestInfo](
  @Ids nvarchar(4000)='',
  @billType int 
)
returns table
AS
return
(  
    with with_waInfo
	as
	(
		select x.ID,x.ID BaseID from M2_WorkAssigns x
		where @billType=54002 
		and (LEN(@Ids)=0 or CHARINDEX(','+CAST(x.ID AS nvarchar(20))+',',','+@Ids+',') > 0)
		and x.del = 1 and x.Status <> 0 
		union all
		select y.ID,y.WAID BaseID from M2_WorkAssigns y
		inner join with_waInfo z on z.ID = y.WAID
		where y.del = 1 and y.Status <> 0 and y.ptype = 1 
	)
	,with_Info as
		(
			select x.ID,x.BaseID from with_waInfo x
			union all
			select x.ID,x.ID BaseID from dbo.M2_WorkAssigns x
			where @billType=54005
			and x.ptype=1
			and (LEN(@Ids)=0 or CHARINDEX(','+CAST(x.ID AS nvarchar(20))+',',','+@Ids+',') > 0)
			union all
			select ool.ID,ool.ID BaseID from dbo.M2_OutOrderlists ool
			inner join dbo.M2_OutOrder oo on ool.outID=oo.ID
			where @billType=54003
			and oo.wwType=0
			and (LEN(@Ids)=0 or CHARINDEX(','+CAST(oo.ID AS nvarchar(20))+',',','+@Ids+',') > 0)
			union all
			select ool.ID,ool.ID BaseID from dbo.M2_OutOrderlists ool
			inner join dbo.M2_OutOrder oo on ool.outID=oo.ID
			where @billType=54006
			and oo.wwType=1
			and (LEN(@Ids)=0 or CHARINDEX(','+CAST(oo.ID AS nvarchar(20))+',',','+@Ids+',') > 0)
			union all
			select tt.ID,tt.ID BaseID from (
				select y.ID as ID
				from M2_WFP_Assigns x
				inner join M2_OutOrderlists y on x.ID = y.WFPAID and y.del = 1
				where @billType=5400256 --��ѯ�ɹ��򷵹���ع���ί�ⵥ��ϸID
				and CHARINDEX(','+CAST(x.WAID AS nvarchar(20))+',',','+@Ids+',') > 0
			    group by y.ID)tt
		)
		,with_qtinfo as( 
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
					when mq.QTResultAll = 0 and mq.poType not in(3,4) then mqt.SerialNumber
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
					when mq.QTResultAll = 0 and mq.poType not in(3,4) then 0
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
					when mq.poType not in (3,4) and mq.QTResultAll = 0 then 0
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
			and (LEN(@Ids)=0 or 
			    exists(
			      select 1 from with_Info info where info.ID=mqt.bid
			    )
			)                                                   
			group by mq.ID, mqt.bid
		) y on x.ID= y.QTID
		where x.QTResultAll=0  or x.CkStatus>0   --QTResultAll=1 and CkStatus=0 ��ʾ����ˣ� �������ݲ���Ҫ��ѯ����
		and (LEN(@Ids)=0 or 
			    exists(
			      select 1 from with_Info info where info.ID=y.PID
			    )
			) 
		) 
		select 
		x.BaseID WAID,
		SUM(case when x.BaseID=x.ID then isnull(y.SerialNumber,0) else 0 end) sjnum,--�ͼ�����ֻ��ѯ��ǰ���ݵ�sumֵ
		SUM(isnull(certNum,0)) certNum,
		SUM(isnull(NumBF,0)) bfnum,
		SUM(isnull(NumScrap,0)) fgnum
		from with_Info x
		left join with_qtinfo y on x.ID = y.PID
		WHERE Y.billType=@billType
		group by x.BaseID 
    )
GO
create function [dbo].[f_GetProductPriceInfo](
  @ProdcutId int,
  @UnitId int,
  @InvoiceType int,
  @UserId int,
  @IsTax int  
)
returns decimal(25,12)
AS
begin
        declare @Price decimal(25,12)
        if(@InvoiceType=-1)
        begin
           select TOP 1 @InvoiceType=b.ord from product a inner join sortonehy b on b.isStop = 0 and a.ord=@ProdcutId and charindex(','+ cast(b.ord as varchar(12)) + ',',','+a.invoiceTypes+',')>0 ORDER BY b.gate1 DESC
        end
		select top 1  @Price=(case when @IsTax=1 then
		(case when pp.includeTax=1 then jg.price1jy else  jg.price1jy * 1 + jg.price1jy * (isnull(ta.taxRate,0) / 100) end) 
		 else(case when pp.includeTax=1 then jg.price1jy / (1 + (isnull(ta.taxRate,0) / 100)) else jg.price1jy end) end)
		from dbo.jiage jg 
		inner join dbo.product pp on jg.product=pp.ord
		left join (SELECT TOP 1 taxRate FROM dbo.invoiceConfig WHERE typeId=@InvoiceType) ta on 1=1
		where jg.product=@ProdcutId and jg.unit=@UnitId 
		and (jg.bm=0 or exists(select 1 from dbo.gate g where g.ord=@UserId and g.Orgsid=jg.bm))
		order by jg.bm desc                       
		return @Price
 end
GO
Create FUNCTION [dbo].[GetPY]    
(     
	@str NVARCHAR(4000)     
)      
RETURNS NVARCHAR(4000)       
AS     
BEGIN     
	DECLARE @WORD NCHAR(1),@PY NVARCHAR(4000)      
	SET @PY=''      
	WHILE LEN(@STR)>0     
	BEGIN     
		SET @WORD=LEFT(@STR,1)      
		--����Ǻ����ַ��o����ԭ�ַ�     
		SET @PY=@PY+(CASE WHEN UNICODE(@WORD) BETWEEN 19968 AND 19968+20901     
		THEN (     
		SELECT TOP 1 PY     
		FROM     
		(     
		SELECT 'A' AS PY,N'�' AS WORD     
		UNION ALL SELECT 'B',N'��'     
		UNION ALL SELECT 'C',N'�e'     
		UNION ALL SELECT 'D',N'�z'     
		UNION ALL SELECT 'E',N'��'     
		UNION ALL SELECT 'F',N'�v'     
		UNION ALL SELECT 'G',N'�B'     
		UNION ALL SELECT 'H',N'��'     
		UNION ALL SELECT 'J',N'�h'     
		UNION ALL SELECT 'K',N'�i'     
		UNION ALL SELECT 'L',N'�w'     
		UNION ALL SELECT 'M',N'��'     
		UNION ALL SELECT 'N',N'��'     
		UNION ALL SELECT 'O',N'�a'     
		UNION ALL SELECT 'P',N'��'     
		UNION ALL SELECT 'Q',N'��'     
		UNION ALL SELECT 'R',N'�U'     
		UNION ALL SELECT 'S',N'�R'     
		UNION ALL SELECT 'T',N'�X'     
		UNION ALL SELECT 'W',N'�F'     
		UNION ALL SELECT 'X',N'�R'     
		UNION ALL SELECT 'Y',N'�'     
		UNION ALL SELECT 'Z',N'��'     
		) T     
		WHERE WORD>=@WORD COLLATE CHINESE_PRC_CS_AS_KS_WS     
		ORDER BY PY ASC)     
		ELSE @WORD     
		END)     
		SET @STR=RIGHT(@STR,LEN(@STR)-1)     
	END      
RETURN @PY      
END
GO
create function [dbo].[import_getPersonIdsFromNamesNew](  
	@names as varchar(8000)  
) returns varchar(8000)  
as  
begin  
	declare @r as varchar(8000)  
	set @r = ''  
	select @r=@r+  
	(case when charindex(','+cast(b.ord as varchar)+',',','+@r+',')>0 then  
	''  
	else  
	(case when len(@r)>0 then ',' else '' end) + cast(b.ord as varchar)  
	end)  
	from   
	dbo.split(@names,',') a  
	inner join (  
		select ord,name from gate where del in (1,2)
		union all  
		select 0,'�����û�'  
	) b on a.short_str = b.name  
	return @r  
end   

GO

Create Function [dbo].[GetInvoiceTypeList](
	@BillType Int,
	@BillID Int,
	@ids varchar(max)
)
RETURNS @returntable TABLE
(
    rowIndex INT,id INT, invoiceType INT, taxRate DECIMAL(25,12)
)
AS
BEGIN
	declare @returntabletemp table( rowIndex INT,id INT, invoiceType INT, taxRate DECIMAL(25,12))
	--��Ŀ
	if @BillType = 12001
	begin 
		insert into @returntabletemp
		SELECT row_number() over(order by l.id , bb.gate1 desc , bb.id ) as rowIndex , l.id , bb.id as invoiceType ,isnull(bb.taxRate,0) as taxRate
		from chancelist l 
		INNER JOIN product p ON p.ord = l.ord 
		left join ( 
			select a.id ,b.taxRate,a.gate1 from sortonehy a inner join invoiceConfig b on a.id=b.typeid where gate2 = 34 and isStop=0 and isnull(id1,0)<>-65535 
			union all
			select 0, taxRate ,-9999999 from sortonehy a,invoiceConfig b where a.id=b.typeid and isnull(a.id1,0)=-65535
		) bb on charindex(','+cast(bb.id as varchar(10))+',',','+isnull(p.invoiceTypes,'')+',')>0 OR (ISNULL(p.invoiceTypes,'')='' AND bb.id=0)
		where l.chance=@BillID
	end 
	--��ͬ
	else if @BillType = 11001
	begin 
		insert into @returntabletemp
		SELECT row_number() over(order by l.id , bb.gate1 desc , bb.id ) as rowIndex , l.id , bb.id as invoiceType ,isnull(bb.taxRate,0) as taxRate
		from contractlist l 
		INNER JOIN product p ON p.ord = l.ord 
		left join ( 
			select a.id ,b.taxRate,a.gate1 from sortonehy a inner join invoiceConfig b on a.id=b.typeid where gate2 = 34 and isStop=0 and isnull(id1,0)<>-65535 
			union all
			select 0, taxRate ,-9999999 from sortonehy a,invoiceConfig b where a.id=b.typeid and isnull(a.id1,0)=-65535
		) bb on charindex(','+cast(bb.id as varchar(10))+',',','+isnull(p.invoiceTypes,'')+',')>0 OR (ISNULL(p.invoiceTypes,'')='' AND bb.id=0)
		where l.contract=@BillID
	end 
	--ѯ��
	else if @BillType =71001
	begin 
		--Ʊ������ ˰��
		insert into @returntabletemp
		SELECT row_number() over(order by l.id , bb.gate1 desc , bb.id ) as rowIndex , l.id , bb.id as invoiceType ,isnull(bb.taxRate,0) as taxRate
		from xunjialist l 
		INNER JOIN product p ON p.ord = l.ord 
		left join ( 
			select a.id ,b.taxRate,a.gate1 from sortonehy a inner join invoiceConfig b on a.id=b.typeid where gate2 = 34 and isStop=0 and isnull(id1,0)<>-65535 
			union all
			select 0, taxRate ,-9999999 from sortonehy a,invoiceConfig b where a.id=b.typeid and isnull(a.id1,0)=-65535
		) bb on charindex(','+cast(bb.id as varchar(10))+',',','+isnull(p.invoiceTypes,'')+',')>0 OR (ISNULL(p.invoiceTypes,'')='' AND bb.id=0)
		where l.xunjia=@BillID
	end 
	--Ԥ��
	else if @BillType =72001
	begin 
		insert into @returntabletemp
		SELECT row_number() over(order by l.id , bb.gate1 desc , bb.id ) as rowIndex , l.id , bb.id as invoiceType ,isnull(bb.taxRate,0) as taxRate
		from caigoulist_yg l 
		INNER JOIN product p ON p.ord = l.ord 
		left join ( 
			select a.id ,b.taxRate,a.gate1 from sortonehy a inner join invoiceConfig b on a.id=b.typeid where gate2 = 34 and isStop=0 and isnull(id1,0)<>-65535 
			union all
			select 0, taxRate ,-9999999 from sortonehy a,invoiceConfig b where a.id=b.typeid and isnull(a.id1,0)=-65535
		) bb on charindex(','+cast(bb.id as varchar(10))+',',','+isnull(p.invoiceTypes,'')+',')>0 OR (ISNULL(p.invoiceTypes,'')='' AND bb.id=0)
		where l.caigou=@BillID or charindex(','+cast(l.caigou as varchar(10))+',' , ','+ isnull(@ids,'') +',')>0
	end
	
	insert into @returntable(rowIndex ,id , invoiceType , taxRate)
	select 
		rowIndex ,id , invoiceType , taxRate
	from @returntabletemp a
	inner join (select min(rowIndex) inx from @returntabletemp group by id) b on b.inx = a.rowIndex
	--delete from @returntable where rowindex not in (select min(rowIndex) from @returntable group by id)
	RETURN
END

GO

Create Function [dbo].[GetJiaGeRuleList](
	@uid int,
	@BillType Int,
	@BillID Int,
	@ids varchar(max)
)
RETURNS @returntable TABLE
(
    ord INT, 
	unit INT, price1jy DECIMAL(25,12) NULL, bl DECIMAL(25,12) NULL,
	unitcg INT NULL,pricejycg DECIMAL(25,12) NULL,  blcg DECIMAL(25,12) NULL
)
AS
BEGIN
	--�ɹ�����λ����
	declare @CGMainUnitTactics int , @bm1 int
	SELECT @CGMainUnitTactics = ISNULL((SELECT isnull(nvalue,0) nvalue from home_usConfig where name='CGMainUnitTactics' and isnull(uid,0)=0),0)
	--���ż۸����
	SET @bm1 = 0
	select @bm1=ISNULL(pricesorce,0) from gate where ord=@uid
	IF NOT EXISTS(select top 1 ord from pricegate1 where ord=@bm1 and num1=1)
	BEGIN
		SET @bm1 = 0
	END

	insert into @returntable
	select l.ord , l.unit, MIN(j.price1jy) AS price1jy , MIN(j.bl) bl,
		ISNULL(ISNULL(ISNULL(MIN(jg2.unit),MIN(jg5.unit)),MIN(jg6.unit)),l.unit) unitcg, 
		ISNULL(ISNULL(ISNULL(MIN(jg2.price1jy),MIN(jg5.price1jy)),MIN(jg6.price1jy)),MIN(j.price1jy)) pricejycg,
		ISNULL(ISNULL(ISNULL(MIN(jg2.bl),MIN(jg5.bl)),MIN(jg6.bl)),MIN(j.bl)) blcg
	from jiage j
	INNER JOIN (
		--��Ŀ
		select ord ,unit from chancelist where @BillType=12001 and (chance=@BillID OR CHARINDEX(','+CAST(chance AS VARCHAR(10))+',',','+@ids+',')>0)
		union all
		--��ͬ
		select ord ,unit from contractlist where @BillType=11001 and (contract=@BillID OR CHARINDEX(','+CAST(contract AS VARCHAR(10))+',',','+@ids+',')>0)
		union all
		--ѯ��
		select ord ,unit 
		from (
			select c.ord,c.unit
			from xunjia a
			inner join price b on b.ord=a.price and a.del=1 and b.del=1 and a.id=@BillID
			inner join pricelist c on c.del=3 and c.price=b.ord 
			left join (
				select distinct pricelist from xunjialist where del=1 and isnull(toUse,0)=2 and xunjia=@BillID				
			) d on c.id=d.pricelist and c.id not in(select pricelist from xunjialist where del=1 and toUse=1 and xunjia=@BillID)
			where c.xunjiastatus=1 or d.pricelist>0
			union all
			select ord,unit from xunjialist l where del=1 and (isnull(toUse,0)=1 or ISNULL(gysstatus,0)=1) and xunjia=@BillID
			union all
			select a.ord,a.unit
			from xunjialist a
			left join (
				select distinct pricelist from xunjialist where del=1 and toUse=2 and xunjia=@BillID
			) b on a.id=b.pricelist and a.del=1 and xunjia=@BillID
				and a.id not in(select pricelist from xunjialist where del=1 and toUse=1 and xunjia=@BillID)
			where a.Xunjiastatus=1 or b.pricelist>0
		) a 
		where @BillType=71001
		union all
		--Ԥ��
		select ord,unit from caigoulist_yg where @BillType=72001 and (caigou=@BillID OR CHARINDEX(','+CAST(caigou AS VARCHAR(10))+',',','+@ids+',')>0)
	) l ON l.ord=j.product AND l.unit=j.unit AND j.bm = @bm1
	LEFT JOIN (
		SELECT product,MIN(unit) unit,MIN(price1jy) price1jy, MIN(bl) bl
		FROM jiage jg3 
		WHERE @CGMainUnitTactics=1 AND (cgMainUnit=1 AND bm=@bm1) 
		GROUP BY product				
	) jg2 ON jg2.product=l.ord
	LEFT JOIN (			
		SELECT product,MIN(unit) unit,MIN(price1jy) price1jy, MIN(bl) bl 
		FROM jiage jg3 
		WHERE @CGMainUnitTactics=1 AND ISNULL(cgMainUnit,0)=0 AND EXISTS(SELECT TOP 1 1 FROM jiage WHERE product=jg3.product AND unit=jg3.unit AND bm=0 AND cgMainUnit=1)
		GROUP BY product
	) jg5 ON jg5.product=l.ord
	LEFT JOIN (
		SELECT product,MIN(unit) unit,MIN(price1jy) price1jy, MIN(bl) bl 
		FROM jiage 
		WHERE @CGMainUnitTactics=1 AND bm=0 AND cgMainUnit=1 
		GROUP BY product
	) jg6 ON jg6.product=l.ord
	GROUP BY l.ord , l.unit
	RETURN
END

GO

Create Function [dbo].[GetHistoryIDList](
	@uid int,
	@BillType Int,
	@BillID Int,
	@ids varchar(max)
)
RETURNS @returntable TABLE
(
    ord INT, unit INT, hisID int
)
AS
BEGIN
	declare @jgcl int
	declare @jgcl_320173106 int
	SET @jgcl = 1
	select @jgcl = ISNULL(intro,1) from setopen  where sort1=1202
	select @jgcl_320173106 = ISNULL(intro,1) from setopen  where sort1=320173106
	if @jgcl = 1
	begin 
		--ʹ�òɹ���λȡ��ʷ��
		insert into @returntable
		select l.ord , l.unitcg as unit ,
			ISNULL(MAX(c.id),MAX(c1.id)) AS hisID
		from dbo.[GetJiaGeRuleList](@uid,@BillType ,@BillID ,@ids) l
		INNER JOIN product p ON p.ord = l.ord
		LEFT JOIN caigoulist c1 ON c1.ord = l.ord AND c1.unit = l.unitcg and c1.del=1 and ((@jgcl_320173106=0 and c1.addcate=@uid) or (@jgcl_320173106=1 and c1.cateid=@uid))
		LEFT JOIN caigoulist c ON c.ord = l.ord AND c.unit = l.unitcg and c.del=1 and ((c.addcate=@uid and @jgcl_320173106=0) or (@jgcl_320173106=1 and c.cateid=@uid)) AND (ISNULL(p.company,0)=0 OR c.company=p.company) AND c1.id = c.id
		GROUP BY l.ord , l.unitcg
	end 
	return
end


GO

CREATE FUNCTION [dbo].[GetStartDateByWaid](
	@waid int
)
RETURNS TABLE
AS
RETURN(
	select 
		WAID,MIN(startDate) startDate
	from(
		--����㱨
		select WFPA.WAID,MIN(execDate) as startDate
		from M2_WFP_Assigns WFPA
		inner join M2_ProcedureProgres p on WFPA.ID = p.WFPAID and WFPA.isOut = 0 and p.del = 1  
		where WFPA.del = 1 and WFPA.WAID = @waid
		group by WFPA.WAID
		union all
		--����ί��
		select WFPA.WAID, MIN(oo.odate) startDate
		from M2_OutOrderlists ool 
		inner join M2_OutOrder oo on oo.wwType = 1 and oo.ID = ool.outID and oo.del=1 and oo.status in (-1,1) and isnull(oo.Stopstatus,0) = 0
		inner join M2_WFP_Assigns WFPA on WFPA.ID = ool.WFPAID
		where WFPA.WAID=@waid and oo.[Status] in(-1,1)
		group by WFPA.WAID
		union all
		--�ɹ��ʼ�
		select M2QTL.bid WAID,MIN(M2QT.QTDate) as startDate
		from M2_QualityTestingLists M2QTL   
		inner join M2_QualityTestings M2QT on M2QTL.QTID = M2QT.ID and M2QT.del = 1 and M2QT.poType = 3
		where M2QTL.del = 1 and M2QTL.bid=@waid
		group by M2QTL.bid 
		union all
		--���ϳ���ȷ��
		select wal.WAID,MIN(ko.date5) startDate
		from M2_WorkAssignLists wal
		inner join M2_MaterialOrderLists mol on wal.ID = mol.ListID and mol.poType in (1,2)
		inner join M2_MaterialOrders mo on mol.MOID = mo.ID and mol.del = 1
		inner join kuoutlist2 kl2 on kl2.sort1 = 3 and kl2.M2_OrderID = mol.ID and kl2.del = 1
		inner join kuout ko on ko.ord = kl2.kuout and ko.del = 1
		where wal.WAID = @waid
		group by wal.WAID
	) t
	group by t.WAID
)

GO
        
create function [dbo].[ConvertUtf8ToGBK](
	@data nvarchar(2000)
) returns nvarchar(2000)
as 
begin
	declare @r nvarchar(2000), @a nvarchar(1), @a2 varchar(1);
	declare @len int,  @curri int, @u1 int, @u2 int;
	set @len = len(@data)
	set @curri = 1
	set @r = '';
	while @curri<=@len 
	begin
		set @a = SUBSTRING(@data, @curri, 1) 
		set @a2 =  cast(@a as varchar(1));
		set @u1 = Unicode(@a) ;
		set @u2 = Unicode(@a2) ;
		if @u1<>@u2
		begin
			set @r = @r + '&#' + cast(@u1 as varchar(12)) +';'
		end
		else
		begin
			set @r = @r  + @a
		end
		set @curri = @curri+1
	end
	set @r = replace(@r,'��','&#934;')
	set @r = REPLACE(@r,'��','&#176;')
	return @r;
end

GO

create  function [dbo].[P_HrKQ_AttendanceRecordDevice](@UserID int,@NowDate datetime,@Device int) returns int  
as  
begin  
  
declare @IsDevice int--����������  
set @IsDevice=0  
  
IF EXISTS (SELECT 1 FROM dbo.HrKQ_CardSetting cs  
 INNER JOIN dbo.HrKQ_Scheduling hs   
 ON CHARINDEX(','+CAST(cs.GroupID AS VARCHAR(20))+',',','+CAST(hs.PersonGroupIDs AS VARCHAR(8000))+',') > 0   
  AND @NowDate BETWEEN hs.StartDate AND hs.EndDate  
 inner JOIN dbo.HrKQ_PersonGroup cr ON cs.GroupID = cr.id   
 inner join dbo.HrKQ_PersonGroupDate crd on cr.id=crd.GroupID  
    AND @NowDate BETWEEN ISNULL(CONVERT(varchar(10),crd.BeginDate,121),'1900-01-01') AND 
    ISNULL(convert(varchar(10),crd.EndDate-1,121),'9999-12-31')   
 WHERE CHARINDEX(','+CAST(@UserID AS VARCHAR(20))+',',','+CAST(crd.UserID AS VARCHAR(8000))+',') > 0  
 AND CHARINDEX(CONVERT(VARCHAR(50), @Device),cs.Device, 0) > 0)  
 BEGIN  
  SET @IsDevice = 1;  
 END  
  
return @IsDevice  
end  

Go
create function [dbo].[ClearHtml] (@input_str varchar(max))
returns varchar(max)
as
begin
    set @input_str = isnull(@input_str,'')
    declare @randchar_one nvarchar(200)
    declare @randchar_two nvarchar(200)
    --��Ǳ�����ǿ�ʼ
    set @input_str = replace(@input_str,'<img','&lt;img')
    set @input_str = replace(@input_str,'<br/>','&lt;br/&gt;')  
	set @input_str = replace(@input_str,'<br>','&lt;br&gt;')  
    --��Ǳ�����ǽ���
	if(charindex('<<',@input_str)>0)
	   begin
		  set @randchar_one='D4678B36-B958-4274-B81E-BBA636CFB427'
		  set @randchar_two='49E374CC-9E1A-4850-897C-27074DE32E7F'
		  set @input_str=replace(@input_str,'<<',@randchar_one)
		  set @input_str=replace(@input_str,'>>',@randchar_two)
	   end
    declare @i int
    while 1 = 1
    begin
       set @i=len(@input_str)
       if charindex('>',@input_str)-charindex('<',@input_str)>-1
            set @input_str=replace(@input_str, substring(@input_str,charindex('<',@input_str),
                charindex('>',@input_str)-charindex('<',@input_str)+1),space(0))
       if @i=len(@input_str)
       break
    end
    --set @input_str=replace(@input_str,' ','')
    --set @input_str=replace(@input_str,' ','')
    set @input_str=ltrim(rtrim(@input_str))
    set @input_str=replace(@input_str,char(9),'')
    set @input_str=replace(@input_str,char(10),'')
    set @input_str=replace(@input_str,char(13),'')
    if(charindex(@randchar_one,@input_str)>0)
    begin
       set @input_str=replace(@input_str,'D4678B36-B958-4274-B81E-BBA636CFB427','<<')
       set @input_str=replace(@input_str,'49E374CC-9E1A-4850-897C-27074DE32E7F','>>')
    end
    --��ԭ������ǿ�ʼ
    set @input_str = replace(@input_str,'&lt;img','<img ')
    set @input_str = replace(@input_str,'&lt;br/&gt;','<br/>')  
	set @input_str = replace(@input_str,'&lt;br&gt;','<br>')  
    --��ԭ������ǽ���
    return @input_str
end

GO

create function  [dbo].[erp_finace_willpayoutList](@showcomplete int)
returns table as return (
	select 
			 t1.*,  
			 t2.name as CompanyName,  
			 isnull(t2.del,-100) as CompanyDel, 
			 t2.cateid as CompanyCateid, 
			 (t1.Money1-PayPlanMoney) as PayAlsoMoney,
			 (case 
			 when t1.PayPlanMoney =0 then 'δ����'
			 when t1.PayPlanMoney>0 and t1.PayPlanMoney < t1.money1 then '��������'
			 when t1.PayPlanMoney = t1.money1  then 'ȫ������'
			 else '��������' end) as PlanStatus,
			 t15.name  as billUserName
	from	(

		--�ɹ�
		select  0 cls, a.ord,cateid,title,cgid,company,money1,b.bz,del,date7,date3,  PayPlanMoney, PaySureMoney,  isnull(c.hl,1) as hl   from (
			select  x.ord, isnull(sum(y.money1),0)  as PayPlanMoney ,  ISNULL( sum(case y.Complete when 3 then y.money1 else 0 end) , 0) as PaySureMoney
			from caigou  x with(nolock) 
			left  join payout y with(nolock)  on  x.ord= y.contract and y.cls=0 and y.del=1
			where x.del=1 and isnull(x.status,-1) in (-1,1) and isnull(x.isstop,0)=0  and (isnull(x.import,0)=0 or (isnull(x.import,0) >0 and isnull(x.importPayout,0)=0))
			group by x.ord,  x.money1 having x.money1>  isnull(sum(y.money1),0)  or @showcomplete=10
		)  a inner join caigou b with(nolock)  on a.ord= b.ord
		left join hl c on b.bz=c.bz and datediff(d, b.date3, c.date1)=0

		union all

		--�ϰ�ί��
		select  2 cls, id,creator,title,sn,gys, a.money1 ,  14 bz,1 del,indate,odate,  PayPlanMoney, PaySureMoney,  1 as hl   from (
			select x.*,  isnull(sum(y.money1),0)  as PayPlanMoney , ISNULL( sum(case y.Complete when 3 then y.money1 else 0 end) , 0) as PaySureMoney from (
				select y.ID as ord,  sum(x.money1) as money1 from M_OutOrderlists  x 
				inner join M_OutOrder y on x.outID=y.ID and y.del=0 and y.status=3
				group by y.Id
			) x left  join payout y with(nolock)  on  x.ord= y.contract and y.cls=2 and y.del=1
			group by x.ord,  x.money1 
			having x.money1>  isnull(sum(y.money1),0)  or @showcomplete=10
		) a inner join M_OutOrder b with(nolock)  on a.ord= b.ID
		union all

		--�°�ί��.�ǻ�������
		select  (5 - isnull(wwType,0))  cls, b.id,ourperson,title,sn,gys,money1,b.bz,del,indate,odate ,  PayPlanMoney, PaySureMoney , isnull(c.hl,1) as hl  from (
			select  x.id as ord, isnull(sum(y.money1),0)  as PayPlanMoney  , ISNULL( sum(case y.Complete when 3 then y.money1 else 0 end) , 0) as PaySureMoney
			from M2_OutOrder  x with(nolock) 
			left  join payout y with(nolock)  on  x.ID= y.contract and y.cls in (4,5) and y.del=1
			where x.del=1 and isnull(x.Stopstatus,0)=0  and  isnull(x.payPlan,0)<>2  and x.status in (-1,1)
			group by x.id ,  x.money1 having x.money1>  isnull(sum(y.money1),0)  or @showcomplete=10
		)  a inner join M2_OutOrder b with(nolock)  on a.ord= b.ID
		left join hl c on b.bz=c.bz and datediff(d, b.odate, c.date1)=0
		union all 

		select (5 - isnull(wwType,0))  cls,b.id,ourperson,title,sn,gys,a.money1,b.bz,del,indate,odate,  PayPlanMoney, PaySureMoney , isnull(c.hl,1) as hl from (
			select   
				x.id as ord, 
				x.money1-isnull(x.yhmoney,0) as money1,
				isnull(sum(y.money1),0)  as PayPlanMoney, 
				ISNULL( sum(case y.Complete when 3 then y.money1 else 0 end) , 0) as PaySureMoney   
			from (
				--�°湤��ί��.��������
				select x.id as ID,  4 cls,  sum( y.TaxDstYhPrice*( z.NumSPOK +  (x.PayPlanInStockType-1)*z.NumBF)  ) as money1,max(x.yhmoney) yhmoney  
				from M2_OutOrder x 
				inner join  M2_OutOrderlists y on x.ID=y.outID  and  x.del=1 and isnull(x.Stopstatus,0)=0  and  isnull(x.payPlan,0)=2  and x.status in (-1,1)
				inner join M2_QualityTestingLists z on y.ID=z.bid  and z.del=1
				inner join M2_QualityTestings  q on z.QTID=q.ID  and q.poType = 2 
				group by  x.id 
				union all
				--�°�����ί��.��������
				select  x.id as outid,  5 cls, sum( y.TaxDstYhPrice* k.num2) as money1,max(x.yhmoney) yhmoney     from M2_OutOrder x 
				inner join  M2_OutOrderlists y on x.ID=y.outID  and  x.del=1 and isnull(x.Stopstatus,0)=0  and  isnull(x.payPlan,0)=2  and x.status in (-1,1)
				inner join M2_QualityTestingLists z on y.ID=z.bid  and z.del=1
				inner join M2_QualityTestings  q on z.QTID=q.ID  and q.poType = 1
				inner join (
					select  num2,   
					(case isnull(M2_QTLID,0) 
					when 0 then M2_BFID
					else M2_QTLID
					end) as M2QTLID,
					(case isnull(M2_QTLID,0) 
					when 0 then 2
					else 1
					end) as qctype
					from kuinlist  
					where num2 >0 and del=1  and (M2_QTLID>0 or M2_BFID>0)
				)  k on   k.M2QTLID = z.id   and (x.PayPlanInStockType=2 or x.PayPlanInStockType=k.qctype)
				group by  x.id 
			) x left  join payout y with(nolock)  on  x.ID= y.contract  and  y.cls=x.cls and y.del=1
			group by x.id ,  x.money1,yhmoney
			having x.money1>  isnull(sum(y.money1),0)   or @showcomplete=10
		) a inner join M2_OutOrder b with(nolock)  on a.ord= b.ID
		left join hl c on b.bz=c.bz and datediff(d, b.odate, c.date1)=0
	) t1 
	inner join gate t15 on t1.cateid=t15.ord 
	left join tel t2 on t1.company = t2.ord
    where (t1.Money1-PayPlanMoney)>0  or @showcomplete=10
)


GO

Create function [dbo].[IsExistsStr]
(
	@orginSplit nvarchar(max),--ԭʼֵ(���ַ���)  
    @newSplit nvarchar(max),--��Ҫ�Д��ֵ(���ַ���)  
	@speaterString varchar(20)--�ָ���
)
returns smallint
as
begin
	declare @val smallint
    select @val = dbo.existsPower2(@orginSplit,@newSplit,@speaterString)
	return @val
end

GO

CREATE FUNCTION [dbo].[erp_bill_GetWWPayOutInfoByChange]
(
	@BillID INT,
	@cls INT,
	@fromType VARCHAR(20),
	@complete INT --0=δִ�еļƻ�1=������ִ�й���
)
RETURNS TABLE
AS
RETURN(
	SELECT bill.ID,SUM(bill.pbcount) pbcount, SUM(CASE WHEN ISNULL(cf.nvalue,0) = 1 THEN bill.pvcount ELSE 0 END) pvcount,
	SUM(bill.ibcount) ibcount, SUM(CASE WHEN ISNULL(cf.nvalue,0) = 1 THEN bill.ivcount ELSE 0 END) ivcount 
	FROM (
		SELECT ool.ID,COUNT(p.ord) pbcount,COUNT(co.id) pvcount, 0 ibcount, 0 ivcount FROM dbo.M2_OutOrderlists ool
		LEFT JOIN dbo.payout p ON ool.outID = p.contract AND p.cls = @cls AND p.del = 1 AND ((@complete = 0 AND p.complete = 1) OR (@complete = 1 AND p.complete <> 1))
		LEFT JOIN dbo.collocation co ON p.ord = co.erpOrd AND co.del = 1 AND co.voucher > 0 AND co.sort1 = 10 AND co.clstype = 10009
		WHERE ool.outID = @BillID
		GROUP BY ool.ID
		UNION ALL
		SELECT ool.ID,0 pbcount, 0 pvcount, COUNT(pl.id) ibcount,COUNT(co.id) ivcount FROM dbo.M2_OutOrderlists ool
		LEFT JOIN dbo.payoutInvoice p ON ool.outID = p.fromId AND p.fromType = @fromType AND ((@complete = 0 AND p.isInvoiced = 0) OR (@complete = 1 AND p.isInvoiced <> 0))
		LEFT JOIN dbo.payoutInvoice_list pl ON ool.ID = pl.M2_OutOrderlists AND p.id = pl.payoutInvoice AND pl.del = 1
		LEFT JOIN dbo.collocation co ON p.id = co.erpOrd AND co.del = 1 AND co.voucher > 0 AND co.sort1 = 10 AND co.clstype = 10005
		WHERE ool.outID = @BillID
		GROUP BY ool.ID
	) bill
	LEFT JOIN dbo.home_usConfig cf ON cf.name ='Payout_Invoice_Voucher_Constraint'
	GROUP BY bill.ID
)

GO

CREATE Function [dbo].[erp_vocat_CollList_fun](
	@AccountID int,
	@clstype  nvarchar(200)
) 
returns  @temp Table (ord int , erpord int)
as
Begin
	if @clstype = '6009' or @clstype='6003,6006'
	begin 
		--�տ�ƻ�
		insert into @temp(ord , erpord)
		select  pb.ord ,max(c.erpord) as erpord 
		from (
			select id,indate, erpord
			from collocation 
			where  (account=@AccountID or @AccountID = 0) and sort1=6 and del=1 
			and CHARINDEX(','+cast(clstype as varchar(20))+',',','+@clstype+',')>0--and clstype in (6009)
		) c
		inner join (
			select a.ord, a.date7, b.ord as erpord,REPLACE(','+A.payback, ISNULL(B.PAYBACK ,'')+ ','+CAST(B.ord AS VARCHAR(20)),'') AS paybackL
			from payback A
			inner join payback b on datalength(a.payback)>0 
				and A.contract=b.contract 
				and charindex(','+ cast(b.ord as varchar(20))+',',a.payback+',')>0
		) pb on c.indate<=pb.date7 and  c.erpord=pb.erpord
		AND NOT EXISTS(SELECT 1 FROM PAYBACK WHERE charindex(','+ cast(ord as varchar(20))+',',ISNULL(PB.paybackL,0)+',')>0 AND date7<C.indate) 
		group by pb.ord
	end 
	else if @clstype = '6010'
	begin 
		--�����˿�ƻ�
		insert into @temp(ord , erpord)
		select  pb.ord ,max(c.erpord) as erpord 
		from (
			select id,indate, erpord
			from collocation 
			where (account=@AccountID or @AccountID = 0) and sort1=6 and del=1 
			and CHARINDEX(','+cast(clstype as varchar(20))+',',','+@clstype+',')>0--and clstype in (6010)
		) c
		inner join (
			select a.ord, a.date7, b.ord as erpord,REPLACE(','+A.payout2, ISNULL(B.payout2 ,'')+ ','+CAST(B.ord AS VARCHAR(20)),'') AS payout2L
			from payout2 A
			inner join payout2 b on datalength(a.payout2)>0 
				and A.contractth=b.contractth 
				and charindex(','+ cast(b.ord as varchar(20))+',',a.payout2+',')>0
		) pb on c.indate<=pb.date7 and  c.erpord=pb.erpord
		AND NOT EXISTS(SELECT 1 FROM payout2 WHERE charindex(','+ cast(ord as varchar(20))+',',ISNULL(PB.payout2L,0)+',')>0 AND date7<C.indate)  
		group by pb.ord
	end 
	else if @clstype IN('10009','100091','100092')
	begin 
		--����ƻ�
		insert into @temp(ord , erpord)
		select  pb.ord ,max(c.erpord) as erpord 
		from (
			select id,indate, erpord
			from collocation 
			where (account=@AccountID or @AccountID = 0) and sort1=10 and del=1 
			and CHARINDEX(','+cast(clstype as varchar(20))+',',','+@clstype+',')>0--and clstype in (10009)
		) c
		inner join (
			select a.ord, a.date7, b.ord as erpord,REPLACE(','+A.payout, ISNULL(B.payout ,'')+ ','+CAST(B.ord AS VARCHAR(20)),'') AS payoutL
			from payout A
			inner join payout b on datalength(a.payout)>0 
				and A.contract=b.contract 
				and charindex(','+ cast(b.ord as varchar(20))+',',a.payout+',')>0
		) pb on c.indate<=pb.date7 and  c.erpord=pb.erpord 
		AND NOT EXISTS(SELECT 1 FROM payout WHERE charindex(','+ cast(ord as varchar(20))+',',ISNULL(PB.payoutL,0)+',')>0 AND date7<C.indate) 
		group by pb.ord
	end 
	else if @clstype='10010'
	begin 
		--�ɹ��˿�ƻ�
		insert into @temp(ord , erpord)
		select  pb.ord ,max(c.erpord) as erpord 
		from (
			select id,indate, erpord
			from collocation 
			where (account=@AccountID or @AccountID = 0) and sort1=10 and del=1 
			and CHARINDEX(','+cast(clstype as varchar(20))+',',','+@clstype+',')>0--and clstype in (10010)
		) c
		inner join (
			select a.ord, a.date7, b.ord as erpord,REPLACE(','+A.payout3, ISNULL(B.payout3 ,'')+ ','+CAST(B.ord AS VARCHAR(20)),'') AS payout3L
			from payout3 A
			inner join payout3 b on datalength(a.payout3)>0 
				and A.caigouth=b.caigouth 
				and charindex(','+ cast(b.ord as varchar(20))+',',a.payout3+',')>0
		) pb on c.indate<=pb.date7 and  c.erpord=pb.erpord 
		AND NOT EXISTS(SELECT 1 FROM payout3 WHERE charindex(','+ cast(ord as varchar(20))+',',ISNULL(PB.payout3L,0)+',')>0 AND date7<C.indate) 
		group by pb.ord
	end 
	return
end

GO
Create  Function [dbo].[ProduceV2_Kuin_fun] 
(  
	@company int  
) 
returns TABLE  
as 
RETURN
(
  select  k.ord,kt.id,kt.num1 ,c.company company,k.date5
  from kuin k 
  inner join kuinlist kt on k.ord=kt.kuin
  inner join M2_QualityTestingLists M2QTL --�ʼ�
			  on  (case when isnull(kt.M2_QTLID,0)=0 then kt.M2_BFID else kt.M2_QTLID end)= M2QTL.ID 
				and k.del = 1   
  inner join M2_QualityTestings M2QT on  M2QT.id=M2QTL.QTID and M2QT.poType in (3,4)
  inner join M2_WorkAssigns m2 on m2.id=M2QTL.Bid and m2.fromtype=3 
  inner join contract c on c.ord=m2.MOrderID
  where (c.company=@company or isnull(@company,0)=0)
  union all
  select distinct a.ord , a.id ,a.num1 ,  t.ord as company,a.date5
  from (
	  select   k.ord,kt.id,kt.num1 , m2.MOrderID,k.date5
	  from kuin k 
	  inner join kuinlist kt on k.ord=kt.kuin
	  inner join M2_QualityTestingLists M2QTL --�ʼ�
				  on  (case when isnull(kt.M2_QTLID,0)=0 then kt.M2_BFID else kt.M2_QTLID end)= M2QTL.ID 
					and k.del = 1   
	  inner join M2_QualityTestings M2QT on  M2QT.id=M2QTL.QTID and M2QT.poType in (3,4)
	  inner join M2_WorkAssigns m2 on m2.id=M2QTL.Bid and m2.fromtype in (2,4) 
	  union all
	  select   k.ord,kt.id,kt.num1 , mol.MOrderID,k.date5
	  from kuin k 
	  inner join kuinlist kt on k.ord=kt.kuin
	  inner join M2_QualityTestingLists M2QTL --�ʼ�
				  on  (case when isnull(kt.M2_QTLID,0)=0 then kt.M2_BFID else kt.M2_QTLID end)= M2QTL.ID 
					and k.del = 1   
	  inner join M2_QualityTestings M2QT on  M2QT.id=M2QTL.QTID and M2QT.poType in (1,2)
	  inner JOIN dbo.M2_OutOrderlists ool ON ool.del = 1 AND  ool.id=M2QTL.Bid
	  inner JOIN dbo.M2_ManuOrderLists mol on ool.molist = mol.ID 
  ) a 
  inner join (
		select m2.ID m2ID,mp.ID msID,ts.ID tsid
		FROM M2_ManuOrders m2
		INNER JOIN M2_MaterialAnalysis ms on m2.MAID=ms.ID and m2.MAID>0--���Ϸ���
		inner join M2_MaterialAnalysisList mt on mt.MASID=ms.ID--���Ϸ���
		inner join M2_ManuPlanLists ts on ts.ID=mt.ListID--�����ƻ���ϸ
		INNER JOIN M2_ManuPlans mp on mp.ID=ts.MPSID--�����ƻ�����
		where m2.del=1
		UNION ALL 
		select S.ID m2ID,MS.ID msID,ts.id tsid
		FROM M2_ManuOrders S
		INNER JOIN M2_ManuPlans MS ON MS.ID=S.MPSID
		inner join M2_ManuPlanLists ts on ts.MPSID=MS.ID
		where S.del=1
  ) b on b.m2ID = a.MOrderID
  inner join M2_ManuPlanLists mls on mls.id = b.tsid --�ƻ���ϸid
  inner join M2_ManuPlanListsPre mlsp on mlsp.id = mls.PreID --Ԥ�ƻ���ϸid
  inner join M2_ManuPlansPre msp on msp.id = mlsp.MPSID --Ԥ�ƻ�id
  left join contract c on msp.CreateFrom =1 and c.ord = msp.FromID
  left join (
	select x.ID ord,z.Company  FROM RepairOrder x
	inner join Repair_SL_List y on x.Repair_sl_list=y.id
	inner join Repair_SL z on z.id=y.Repair_sl
	group by x.ID,z.Company
  )  r on msp.CreateFrom =2 and r.ord = msp.FromID
  left join chance n on msp.CreateFrom =3 and n.ord = msp.FromID
  left join tel t on charindex(','+cast(t.ord as varchar(500))+',',','+isnull(isnull(isnull(CAST(c.company AS NVARCHAR(500)) ,CAST(r.company AS NVARCHAR(500))), CAST(n.company AS NVARCHAR(500))) ,'')+',')>0
  where t.ord=@company or isnull(@company,0)=0
)
GO
CREATE FUNCTION [dbo].[Check_ProductAll](@Pro_id INT)
RETURNS table
AS
return
(
	select distinct ord
	from (
		SELECT ord,1 billtype FROM chancelist WHERE DEL<>7 --��Ŀ���
		union all
		SELECT ord,2 FROM pricelist WHERE DEL<>7 	--����
		union all
		SELECT ord,3 FROM CONTRACTlist WHERE DEL<>7 --��ͬ
		union all
		SELECT ord,4 FROM contractthlist WHERE DEL<>7 ----�����˻�
		union all
		SELECT ord,5 FROM caigoulist_yg WHERE DEL<>7 ----Ԥ��
		union all
		SELECT ord,6 FROM xunjialist WHERE DEL<>7 ----ѯ��
		union all
		SELECT ord,7 FROM caigoulist WHERE DEL<>7 ----�ɹ�
		union all
		SELECT ord,8 FROM caigouthlist WHERE DEL<>7 ----�ɹ��˻�
		union all
		SELECT ord,9 FROM kuinlist WHERE DEL<>7 ----���
		union all
		SELECT ord,10 FROM kuoutlist WHERE DEL<>7 --����
		union all
		SELECT ord,11 FROM kumovelist WHERE DEL<>7 --����
		union all
		SELECT ord,12 FROM kupdlist WHERE DEL<>7 --�̵�
		union all
		SELECT ord,13 FROM kujhlist WHERE DEL<>7 --���
		union all
		SELECT ord,14 FROM kuoutlist2 WHERE DEL<>7 --��װ
		union all
		SELECT ord,15 FROM bomlist WHERE DEL<>7 --��װ�嵥
		union all
		SELECT ord,16 FROM sendlist WHERE DEL<>7 --����
		union all
		SELECT ProductID,17 FROM M_PredictOrderLists WHERE DEL<>7 --Ԥ�ⵥ
		union all
		SELECT ProductID,18 FROM M_ManuPlanLists WHERE DEL<>7 ----�����ƻ�
		union all
		SELECT ProductID,19 FROM M_ManuOrderLists WHERE DEL<>7 ----��������
		union all
		SELECT ProductID,20 FROM M_PlanBomList  ----�����嵥
		union all
		SELECT ProductID,21 FROM M_ManuOrderIssuedLists WHERE DEL<>7 ----�´�
		union all
		SELECT ProductID,22 FROM M_WorkAssignLists WHERE DEL<>7 ----�ɹ�
		union all
		SELECT ProductID,23 FROM M_MaterialOrderLists WHERE DEL<>7 ----����-����-����-����
		union all
		SELECT ProductID,24 FROM M_MaterialMoveLists  ----���ϵ���
		union all
		SELECT ProductID,25 FROM M_OutOrderlists WHERE DEL<>7 ----ί����ϸ
		union all
		SELECT ProductID,26 FROM M_OutOrderlists_wl WHERE DEL<>7 --ί������
		union all
		SELECT ProductID,27 FROM M_BOMList WHERE DEL<>7 --�����嵥
		union all
		select bl.ProductID,57 from dbo.M2_BOMList bl INNER JOIN dbo.M2_BOM b ON bl.BOM = b.ID WHERE b.billType in (0,1) --�����嵥���
		union all
		SELECT POrd,28 FROM M_WFProduct WHERE DEL<>7 --���ò�Ʒ
		union all
		SELECT ProductID,29 FROM M_PieceRate WHERE DEL<>7  --�����嵥
		union all
		select ProOrd,30 from BOM_Structure_List where ProType = 1 --��װ�嵥����ǿ��
		union all	
		select ProductID,31 from dbo.M2_ManuPlanListsPre --Ԥ�����ƻ���ϸ
		union all
		select ProductID,32 from dbo.M2_ManuPlanLists
		union all
		select ProductID,32 from dbo.M2_PlanBomList  --�����ƻ���ϸ
		union all
		select ProductID,33 from dbo.M2_MaterialAnalysisList --���Ϸ�����ϸ��
		union all
		select ProductID,34 from dbo.M2_AbilityAnalysisList --�����Ų���ϸ��
		union all
		select ProductID,35 from dbo.M2_ManuOrderLists  --����������ϸ��
		union all
		select wa.ProductID,36 from dbo.M2_WorkAssigns wa where wa.ptype in (0,1) --�����ɹ��������ϡ������ɹ�--��������,����������ϸ
		union all
		select wal.ProductID,36 from dbo.M2_WorkAssigns wa left join dbo.M2_WorkAssignLists wal on wal.WAID=wa.ID where wa.ptype in (0,1) --�����ɹ��������ϡ������ɹ�
		union all
		select wa.ProductID,37 from dbo.M2_ProcedureProgres pp inner join dbo.M2_WFP_Assigns wfa on pp.WFPAID = wfa.id inner join M2_WorkAssigns wa on wfa.WAID = wa.ID --����㱨
		union all
		select mol.ProductID,39 from dbo.M2_MaterialOrderLists mol  --����������ϸ��
		union all
		select mrl.ProductID,40 from dbo.M2_MaterialRegisterLists mrl inner join dbo.M2_MaterialRegisters mr on mrl.MRID=mr.ID where mr.OrderType in (1,2,3)   --��������--��������
		union all
		select ool.productid,43 from dbo.M2_OutOrderlists ool inner join dbo.M2_OutOrder oo on ool.outID=oo.ID  where oo.wwType in (0,1)
		union all
		select oolw.productid,43 from dbo.M2_OutOrderlists_wl oolw inner join dbo.M2_OutOrder oo on oolw.outID=oo.ID where oo.wwType in (0,1)--����ί�� --����ί��
		union all
		select rgl.ProductId,45 from dbo.M2_ReceivingGoodList rgl --ί���ջ���ϸ
		union all
		select oil.ProductId,46 from dbo.M2_OutsourceInspectionList oil  --ί���ͼ���ϸ
		union all
		select ProductID,47 from dbo.M2_OutsourcingReworkList --ί�ⷵ����ϸ
		union all
		select wa.ProductID,56 from dbo.erp_m2wfpa_Nodes_ExecStatus emne INNER JOIN dbo.M2_WorkAssigns wa ON wa.ptype = 0 AND emne.WAID = wa.ID AND wa.del = 1 AND ISNULL(wa.[Status],1) in(1,-1) --�����ʼ�
		union all
		select wa.ProductID,48 from dbo.M2_QualityTestingLists qtl 	inner join dbo.M2_QualityTestings qt on qtl.QTID=qt.ID	inner join dbo.M2_WorkAssigns wa on qtl.bid=wa.ID	where qt.poType in(3,4) --�ɹ��ʼ�
		union all
		select mol.ProductID,49 from dbo.M2_QualityTestingLists qtl 	inner join dbo.M2_QualityTestings qt on qtl.QTID=qt.ID	inner join M2_OutOrderlists mol on qtl.bid = mol.ID	where qt.poType in(1,2) --ί���ʼ�
		union all
		select ccl.ProductID,50 from dbo.M2_CostComputationList ccl --�ɱ�����
		union all
		select wlj.productID,51 from dbo.M2_WageList_JJ wlj--�Ƽ�����
		union all
		select prl.productID,52 from dbo.M2_PriceRateList prl where del = 1  --�Ƽ�����
		union all
		select wfp.POrd,53 from dbo.M2_WFProduct wfp  --��������
		union all
		select br.productID,54 from dbo.M2_BOMRelation br  --�������
		union all
		select snm.ProductID,55 from dbo.M2_SerialNumberMain snm --���к�
	) t
)
go


CREATE FUNCTION [dbo].[erp_process_existmodule] ( @module INT )
RETURNS TABLE
    RETURN(
        SELECT openstate FROM dbo.M2_ProcessConfiguration WHERE TemplateType=4 AND Module=@module AND openstate=1	
        )

GO
CREATE function [dbo].[product_bl](
	 @ord int, --��ƷORD
	 @unit1 int, -- ��ƷС��λ
	 @unit2 int  -- ��Ʒ��λ
)
returns decimal(25,12)
as
begin
	declare @r decimal(25,12)
	select @r = a.bl*b.bl
	from (
		select distinct bl from jiage where product = @ord and bm=0 and unit=@unit2
	) a, (
		select distinct bl from jiage where product = @ord and bm=0 and unit=@unit1
	) b
	
	if @r is null set @r = 1
	return @r
end
GO

CREATE FUNCTION [dbo].[erp_GetOrderCostsShareType](@clstype int)
RETURNS @shareTypeList TABLE
(
    sharemode INT,feetype INT
)
AS 
BEGIN  
	--sharemode����̯ģʽ��--
	--������=1��������=2�����ż�Ʒ�ַ�=3�����ż�ֲ���=4�������ڷֲ���=5--
	--feetype(���÷���)--
	--������������=1�����ż����=2�������ڷ���=3���ʲ��۾�=4������=5���Ĳ�=6������=7���Ƽ�����=8����ʱ����=9�������=10--

IF @clstype=13008 OR @clstype=14002 --�����ʲ��۾�  or �۾�ת�������
 INSERT INTO @shareTypeList  
         ( sharemode, feetype )  
 SELECT a.short_str,b.short_str FROM dbo.split('1,3,5',',') a CROSS JOIN dbo.split('4',',') b  
   
 IF @clstype=13009 --���ʷ���  
 INSERT INTO @shareTypeList  
         ( sharemode, feetype )  
 SELECT a.short_str,b.short_str FROM dbo.split('1,3,5',',') a CROSS JOIN dbo.split('5',',') b  
   
 IF @clstype=13012 --�����ڷ���  
 INSERT INTO @shareTypeList  
         ( sharemode, feetype )  
 SELECT a.short_str,b.short_str FROM dbo.split('5',',') a CROSS JOIN dbo.split('2,3,10',',') b  
   
 IF @clstype=13011 --���ż����  
 INSERT INTO @shareTypeList  
         ( sharemode, feetype )  
 SELECT a.short_str,b.short_str FROM dbo.split('3',',') a CROSS JOIN dbo.split('2,10',',') b  
   
 IF @clstype=13013 --������������  
 INSERT INTO @shareTypeList  
         ( sharemode, feetype )  
 SELECT a.short_str,b.short_str FROM dbo.split('1,2',',') a CROSS JOIN dbo.split('1,10',',') b  
 RETURN;  
END

GO

CREATE FUNCTION [dbo].[GetCurrCostMonth]()
returns datetime
as begin
	declare @dt datetime;
	select @dt=cast(max(date1) as datetime)  from (
		select max(dateadd(mm,1,date1))  as date1 from M2_CostComputation where complete1 = 2
		union all
		select max(dateadd(mm,1,date1))  as date1 from inventoryCost where complete1 = 2
	)  t where not date1 is null;
	if @dt is null
	begin
		select @dt = min(date1) from (
			select  min(Date1) as date1  from MCostInfo
			union all
			select  min(Date5) as date1 from kuin where del=1
			union all
			select min(DateStart) from M2_WorkAssigns where del=1
			union all
			select min(odate) from M2_OutOrder where del=1
            union all
			select max(date1) from M2_CostComputation where complete1 != 2
		) t
	end
	if @dt is null
	begin
		set  @dt=  cast( dateadd(dd, 1-day(getdate()), GETDATE())  as date)
	end
	return @dt;
end

GO

CREATE FUNCTION [dbo].[GetQCCompleteNum]
(
	 @poType int, @QTResult int ,  
	 @spstatus int, 
	 @allnum  decimal(25,12) , 	  
	 @failnum  decimal(25,12), 
	 -------����
	 @bfnum decimal(25,12),
	 @NumBFKuin decimal(25,12),

	 -------����
	 @NumScrap  decimal(25,12),
	 @NumFGOut decimal(25,12),
	 @ValueType int
)   
returns  decimal(25,12)  as 
begin 
	declare @r decimal(25,12) 
	if @poType = 1 or @poType = 2 
	begin 
		--ί��ȡ��
		set @failnum = isnull(@failnum,0)
		set @r =  
			case @ValueType    
			--�ϸ�����
			when  1 then
				case @QTResult 
				when 0 then @allnum
				else 
					case  @spstatus 
					when 0 then 0 
					when 1 then @allnum
					when 2 then 0 
					when 3 then 0
					when 4 then @allnum - @failnum
					when 5 then @allnum - @failnum
					else @allnum end
				end
			--��������
			when  2  then  
				case @QTResult 
				when 0 then 0
				else 
					case  @spstatus 
					when 0 then 0 
					when 1 then 0
					when 2 then 0 
					when 3 then @allnum
					when 4 then 0
					when 5 then @failnum
					else 0 end
				end
			--��������
			when  3  then  
				case @QTResult 
				when 0 then 0
				else 
					case  @spstatus 
					when 0 then 0 
					when 1 then 0
					when 2 then @allnum
					when 3 then 0
					when 4 then @failnum
					when 5 then 0
					else 0 end
				end
			else 0 end;
	end
	else
	begin 
		if @QTResult = 1  and @spstatus = 1
		begin
				set @r =    	
				case @ValueType 
				when 1  then  @allnum
				when 2  then 0
				when 3 then 0
				 else 0 end;
		end 
		else
		begin
			--�ɹ�ȡ��
			set @bfnum = isnull(@bfnum,0) 
			set @NumBFKuin = isnull(@NumBFKuin,0) 
			set @bfnum = case when  @bfnum> @NumBFKuin then @bfnum else  @NumBFKuin end;

			set @NumScrap = isnull(@NumScrap,0) 
			set @NumFGOut = isnull(@NumFGOut,0)
			set @NumScrap = case when  @NumScrap> @NumFGOut then @NumScrap else  @NumFGOut end;

			set @r =    	
			case @ValueType 
			when 1  then  @allnum - @bfnum - @NumScrap
			when 2  then @bfnum 
			when 3 then @NumScrap
			 else 0 end;
		end
	end
	return @r;
end

GO

CREATE FUNCTION  [dbo].[SafeSqlValue](@varname nvarchar(1000)) 
returns nvarchar(1000)
as begin 
	return  replace(@varname, '''','''''')
end

GO

CREATE FUNCTION  [dbo].[SafeSqlValueNum](@varname varchar(50)) 
returns nvarchar(50)
as begin
	return  case ISNUMERIC(@varname) 
	when 1 then cast(cast(replace(@varname,',','') as numeric(32,8)) as nvarchar(50))
	else N'0'
	end 
end

GO

create FUNCTION  [dbo].[SafeSqlNumList](@listvar varchar(8000)) 
returns varchar(8000)
as begin 
	return  replace(replace(replace(replace(replace( replace(replace(replace(@listvar,  '-',  ''),' ',''), '=', ''), 'e', ''),'''', ''),'+',''),'>',''),'<','')
end
GO

Create FUNCTION [dbo].[GetWorkAssignDateInfo] ( @Ids NVARCHAR(max) )
RETURNS @Table TABLE
    (
      ID INT ,
      MinDate varchar(10),
      MaxDate varchar(10)
    )
AS
    BEGIN  
        DECLARE @IdLists TABLE ( ID INT );  
        INSERT  INTO @IdLists
                ( ID  
                )
                SELECT  CAST(short_str AS INT) AS ID
                FROM    dbo.split(@Ids, ',')
                WHERE   LEN(ISNULL(@Ids, '')) > 0;  
        WITH    kuinInfo
                  AS (--�������    
                       SELECT   wa.ID AS WAID ,
                                MIN(ki.date3) MinDate ,
                                MAX(ki.date5) MaxDate
                       FROM     @IdLists wa
                                INNER JOIN dbo.kuinlist kl ON wa.ID = kl.M2_WAID
                                INNER JOIN dbo.kuin ki ON kl.kuin = ki.ord
                       WHERE    kl.del = 1
                                AND ISNULL(kl.M2_WAID, 0) > 0
                       GROUP BY wa.ID
                     ),
                ppinfo
                  AS ( SELECT   wa.ID AS WAID ,
                                MAX(per.LastExecTime) AS MaxDate
                       FROM     @IdLists wa
                                INNER JOIN dbo.M2_WorkAssigns wa2 ON wa.ID = wa2.ID
                                INNER JOIN dbo.M2_ProcessExecution_Result per ON wa.ID = per.WAID
                       WHERE    ISNULL(wa2.ReturnProcess, 0) = 1
                       GROUP BY wa.ID
                     ),
                GXWWSJPPKInfo
                  AS (--�������    
                       SELECT   WAID ,
                                MinDate
                       FROM     kuinInfo
                       UNION ALL--����㱨    
                       SELECT   wa.ID WAID ,
                                MIN(ISNULL(execDateBegin, execDate)) AS MinDate
                       FROM     @IdLists wa
                                INNER JOIN dbo.M2_ProcedureProgres pp ON wa.ID = pp.WAID
                       WHERE    pp.del = 1
                       GROUP BY wa.ID
                       UNION ALL--�ͼ�    
                       SELECT   wa.ID AS WAID ,
                                MIN(tt.TaskDate) MinDate
                       FROM     @IdLists wa
                                INNER JOIN dbo.M2_OneSelfQualityTestingTask tt ON wa.ID = tt.WAID
                       GROUP BY wa.ID
                       UNION ALL--����ί��    
                       SELECT   wa.ID ,
                                MIN(oo.odate) MinDate
                       FROM     @IdLists wa
                                INNER JOIN M2_WFP_Assigns wfpa ON wa.ID = wfpa.WAID
                                INNER JOIN M2_OutOrderlists ool ON ool.WFPAID = wfpa.ID
                                INNER JOIN M2_OutOrder oo ON oo.wwType = 1
                                                             AND oo.ID = ool.outID
                                                             AND oo.del = 1
                       GROUP BY wa.ID
                       UNION ALL--�ɹ��ʼ�(��ǰ���ɹ�����ֱ���ɹ��ʼ쿼����ʷ����)    
                       SELECT   wa.ID WAID ,
                                MIN(M2QT.QTDate) AS MinDate
                       FROM     @IdLists wa
                                INNER JOIN M2_QualityTestingLists M2QTL ON wa.ID = M2QTL.bid
                                INNER JOIN M2_QualityTestings M2QT ON M2QTL.QTID = M2QT.ID
                                                              AND M2QT.del = 1
                                                              AND M2QT.poType IN (
                                                              3, 4 )
                       WHERE    M2QTL.del = 1
                                AND ISNULL(M2QT.TaskId, 0) = 0
                       GROUP BY wa.ID
                       UNION ALL--���ϳ���    
                       SELECT   wa.ID WAID ,
                                MIN(ko.date5) AS MinDate
                       FROM     @IdLists wa
                                INNER JOIN M2_WorkAssignLists wal ON wa.ID = wal.WAID
                                INNER JOIN M2_MaterialOrderLists mol ON wal.ID = mol.ListID
                                                              AND poType IN (
                                                              1, 2 )
                                INNER JOIN kuoutlist2 kl2 ON kl2.M2_OrderID = mol.ID
                                                             AND kl2.sort1 = 3
                                INNER JOIN kuout ko ON kl2.kuout = ko.ord
                       WHERE    ko.del = 1
                       GROUP BY wa.ID
                     )
            INSERT  INTO @Table
                    ( ID ,
                      MinDate ,
                      MaxDate  
                    )
                    SELECT  wa.ID ,
                            CONVERT(VARCHAR(10),MIN(gf.MinDate),120) MinDate,
                            CONVERT(VARCHAR(10),MAX(CASE WHEN ISNULL(wa2.ReturnProcess, 0) = 1
                                     THEN pp.MaxDate
                                     ELSE ki.MaxDate
                                END),120) MaxDate
                    FROM    @IdLists wa
                            INNER JOIN dbo.M2_WorkAssigns wa2 ON wa2.ID = wa.ID
                            LEFT JOIN GXWWSJPPKInfo gf ON wa.ID = gf.WAID
                            LEFT JOIN kuinInfo ki ON ki.WAID = wa.ID
                            LEFT JOIN ppinfo pp ON pp.WAID = wa.ID
                    GROUP BY wa.ID;    
        RETURN;  
    END;

GO

Create function [dbo].[GetMenuAreaChildrens]
(   
 @id int  
)  
RETURNS   
@Tmt_Menu TABLE   
(  
 ----��ȡmenu��ĳһ���ڵ�������ӽڵ�ID  
 ord int identity(1,1) not null,  
 id int,  
 id1 int  
)  
AS  
BEGIN  
	insert into @Tmt_Menu (id,id1) select id,id1 from MenuArea where id = @id or id1 = @id  
	while exists(select 1 from MenuArea where id1 in (select id from @Tmt_Menu) and id not in (select id from @Tmt_Menu))  
	begin  
		insert into @Tmt_Menu (id,id1) select id,id1 from MenuArea where id1 in (select id from @Tmt_Menu) and id not in (select id from @Tmt_Menu)  
	end  
	RETURN   
END  

GO

Create FUNCTION [dbo].[IsSameListCheck] 
(
	@checkvals nvarchar(4000),  
	@optionvals nvarchar(4000)
) returns nvarchar(1000)
as begin
	declare @leftstr varchar(500)
	declare @i int ,  @findi int,  @lenstr1 int;
	set @optionvals =  ',' +  @optionvals + ','
	while len(@checkvals)>0 
	begin 
		set @lenstr1 =  len(@checkvals);
		set @i = CHARINDEX(',' , @checkvals)
		set @i =  case @i when 0 then @lenstr1 else @i -1 end;
		set @leftstr =   left(@checkvals, @i)
		if @i>0 
		begin
			set  @findi =  charindex(',' + @leftstr + ',', @optionvals)
			if @findi=0 begin
				return @leftstr +'--' + @optionvals
			end
		end
		set @checkvals = substring(@checkvals,  @i+2,  @lenstr1-@i);
	end
	return '';
end