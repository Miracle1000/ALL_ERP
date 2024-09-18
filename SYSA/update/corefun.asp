--<%response.end%>
--系统标量函数
GO

CREATE function [dbo].[IIf](
	@value int,@truev varchar(100),
	@falsev varchar(100)
)
returns varchar(100) as begin
	--条件函数
	declare @r varchar(100)
	set @r = case sign(abs(@value)) when 1 then  @truev else @falsev end
	return @r
end

GO

create function [dbo].[MinV](@v1 int ,@v2 int )
returns  int
as begin 
	return (case sign(@v1-@v2) when 1 then  @v2 else @v1 end)
end

GO

create function [dbo].[CValueByMin](@num float,  @minv float) returns float
as
begin
	return (case when @num<@minv then @minv else @num end)
end

GO

create function [dbo].[MaxMinValue](
	@v1  int, @v2  int, @type int
)
returns int as begin
	--@type==0 求min， 其它求max
	return 
	case @type 
	when 0 then (case when @v1>@v2 then @v2 else @v1 end)
	else  (case when @v1>@v2 then @v1 else @v2 end)
	end 
end

GO

create function [dbo].[mindatev](
	 @datex datetime, @datey datetime
)
returns datetime 
as
begin
	return case 
	when @datex is null then @datex 
	when @datey is null then @datey
	when @datex> @datey then @datey
	else @datex end
end

GO

create function [dbo].[maxdatev](
	 @datex datetime, @datey datetime
)
returns datetime 
as
begin
	return case 
	when @datex is null then @datey
	when @datey is null then @datex
	when @datex> @datey then @datex
	else @datey end
end

GO

create function [dbo].[maxv](
	 @datex datetime, @datey datetime
)
returns datetime 
as
begin
	return case 
	when @datex is null then isnull(@datey,'1900-1-1') 
	when @datey is null then isnull(@datex,'1900-1-1') 
	when @datex> @datey then @datex
	else @datey end
end

GO

create function [dbo].[IsNullStr](
	@text1 nvarchar(500),
	@text2 nvarchar(500)
 ) returns nvarchar(500) 
 as  begin
	if len(ISNULL(@text1,''))=0 begin return  @text2; end;
	return @text1
end

GO

CREATE function [dbo].[URLEncode]( -- 网址编码
	@URL varchar(1000)  --原始网址
) returns varchar(3000) --编码后结果
as
begin
	declare @URLEncode varchar(3000)
	declare @count int,
	@char varchar(2),
	@i int,
	@bytes binary(2),
	@low8 int,
	@high8 int

	set @count = LEN(@URL)
	set @i = 1
	set @URLEncode = ''
	while (@i <= @count)
	begin
		 set @char = substring(@URL,@i,1)
		 if @char LIKE '[-A-Za-z0-9()''*._!]' and datalength(@char) = 1
		  set @URLEncode = @URLEncode + @char
		 else
		 begin
			  if datalength(@char) = 1
			  begin
				   set @URLEncode = @URLEncode + '%' + substring('0123456789ABCDEF',(ascii(@char) / 16 + 1),1)
				   set @URLEncode = @URLEncode + substring('0123456789ABCDEF',(ascii(@char) % 16 + 1),1)
			  end
			  else
			  begin
				   set @bytes = CONVERT(binary,@char)
				   set @high8 = (0xFF00 & CAST(@bytes AS int))/256
				   set @low8 = 0x00FF & CAST(@bytes AS int)
				   set @URLEncode = @URLEncode + '%' + substring('0123456789ABCDEF',(@high8 / 16 + 1),1)
				   set @URLEncode = @URLEncode + substring('0123456789ABCDEF',(@high8 % 16 + 1),1)
				   set @URLEncode = @URLEncode + '%' + substring('0123456789ABCDEF',(@low8 / 16 + 1),1)
				   set @URLEncode = @URLEncode + substring('0123456789ABCDEF',(@low8 % 16 + 1),1)
			  end
		 end
		 set @i = @i + 1
	end
	return @URLEncode
end

GO

CREATE Function [dbo].[NumEnCode](@n nvarchar(30)) returns nvarchar(500) --将产品ID号编码
as begin
	declare @bin varbinary(500), @b64v nvarchar(500), @numv nvarchar(30);
	set @bin=Convert(varbinary(500), REVERSE(@n));
	set @b64v = cast(N'' as xml).value('xs:base64Binary(xs:hexBinary(sql:variable("@bin")))', 'varchar(1000)')
	return dbo.Urlencode( 'PW2_' + @b64v)
End

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

CREATE  function [dbo].[erp_comm_BillApproveInfo](
	@ApproveSort int
) returns table 
as
return 
	SELECT ai.PrimaryKeyID AS ord,sp.cateid,sp.date1,ai.SurplusApprover ,ai.ApprovalFlowStatus
	FROM dbo.sp_ApprovalInstance ai
	left JOIN (
		SELECT MAX(it.id) id,it.InstanceID FROM sp_intro it
		WHERE it.sort1 = @ApproveSort 
		GROUP BY it.InstanceID
	) t ON t.InstanceID = ai.InstanceID and ai.ApprovalFlowStatus in (0,1,2)--只有审批通过、否决、退回状态的单子才可以显示最后审批人
	LEFT JOIN sp_intro sp ON sp.id= t.id
	WHERE ai.gate2 = @ApproveSort

GO

CREATE  function [dbo].[OrmXmlPathValue](
	@xmltxt nvarchar(max),
	@splitchr nvarchar(100)
)  returns nvarchar(max)
as begin
	declare @c int;
	set @xmltxt = replace(@xmltxt, '<tlm>', '');
	set @xmltxt = replace(@xmltxt, '<tlm/>', '');
	set @xmltxt = replace(@xmltxt, '</tlm>', @splitchr);
	set @c =  len(@xmltxt) - len(@splitchr);
	if @c >0 
	begin
		set @xmltxt =  left(@xmltxt, @c)
	end
	return @xmltxt
end
