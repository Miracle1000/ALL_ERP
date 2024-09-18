--<%response.end%>

if exists (select 1 from dbo.sysobjects where id = object_id(N'[dbo].[getTableConvertInfo]'))
drop proc [dbo].[getTableConvertInfo]

GO

create proc [dbo].[getTableConvertInfo]
(@tb1 varchar(300), @tb2 varchar(300))
as begin
	set nocount on
	--@tb1为新表, @tb2为旧表
	declare @sql1 nvarchar(max)
	declare @sql2 nvarchar(max)
	declare @bs int
	set @sql1 = ''
	set @sql2 = ''
	set @bs =0
	if not exists(select * from dbo.sysobjects where name=@tb2 and xtype='U')
	begin
		--不存在老表，直接返回
		select '' as newfields, '' as fieldconverts, '' as bs
		return
	end
	select
		@bs =  @bs + isnull(标识1,0),
		@sql1 = @sql1 + ',[' + 字段名1+']',
		@sql2 = @sql2 + ',' + (
			case isnull(字段名2,'')
			when '' then
				case len(isnull(默认值1,''))
				when 0 then 'NULL'
				else 'CONVERT(' + dbo.fun_getStrOfTypeNLength(类型1,长度1,小数位数1) + ',' + 默认值1 + ')'
				end
			else
				case
				when 类型1=类型2 and 长度1=长度2
				then 
					case len(isnull(默认值1,'')) 
					when 0 then '['+字段名2+']'
					else
					'isnull(['+字段名2+'],' + 默认值1 +') as ['+字段名2+']'
					end 
				else
				'CONVERT(' + dbo.fun_getStrOfTypeNLength(类型1,长度1,小数位数1) + ','+
					case len(isnull(默认值1,''))
					when 0 then '['+字段名2+']'
					else
						'IsNull([' + 字段名2 + '],CONVERT(' + dbo.fun_getStrOfTypeNLength(类型1,长度1,小数位数1) + ',' + 默认值1 + '))'
					end
				+')'
				end
			end
		)
	from (
		SELECT
		a.name as 字段名1,a.colid as 序号1,case when a.status=0x80 then 1 else 0 end as 标识1,
		Case When (Exists(select 1
			from sysindexes i
			join sysindexkeys k on i.id = k.id and i.indid = k.indid
			join sysobjects o on i.id = o.id
			join syscolumns c on i.id=c.id and k.colid = c.colid
			join systypes t on c.xusertype=t.xusertype
			where o.xtype = 'U' and o.name=d.name and c.name = a.name and exists(select 1 from sysobjects where xtype = 'PK' and parent_obj=i.id and name = i.name))) then 1
				else 0
				end as 主键1,
		b.name as 类型1,a.length as 占用字节数1,a.prec as 长度1,a.scale as 小数位数1,a.isnullable as 允许空1,isnull(e.text,'') as 默认值1 FROM syscolumns a
		left join systypes b on a.xtype=b.xusertype
		inner join sysobjects d on a.id=d.id and d.xtype='U' and d.name<>'dtproperties'
		left join syscomments e on a.cdefault=e.id
		where a.id=object_id(@tb1)
	) x left join (
		SELECT
		a.name as 字段名2,a.colid as 序号2,case when a.status=0x80 then 1 else 0 end as 标识2,
		Case When (Exists(select 1
			from sysindexes i
			join sysindexkeys k on i.id = k.id and i.indid = k.indid
			join sysobjects o on i.id = o.id
			join syscolumns c on i.id=c.id and k.colid = c.colid
			join systypes t on c.xusertype=t.xusertype
			where o.xtype = 'U' and o.name=d.name and c.name = a.name and exists(select 1 from sysobjects where xtype = 'PK' and parent_obj=i.id and name = i.name))) then 1
				else 0
				end as 主键2,
		b.name as 类型2,a.length as 占用字节数2,a.prec as 长度2,a.scale as 小数位数2,a.isnullable as 允许空2,isnull(e.text,'') as 默认值2 FROM syscolumns a
		left join systypes b on a.xtype=b.xusertype
		inner join sysobjects d on a.id=d.id and d.xtype='U' and d.name<>'dtproperties'
		left join syscomments e on a.cdefault=e.id
		where a.id=object_id(@tb2)
	) y on x.字段名1=y.字段名2
	where x.标识1=isnull(y.标识2,0) or isnull(y.标识2,0)=1
	if len(@sql1) > 0
	begin
		set @sql1 = right(@sql1,len(@sql1)-1)
		set @sql2 = right(@sql2,len(@sql2)-1)
		--这两句将导致text和ntext类型超出长度部分被截断，注释掉观察一下有没有其他问题 by cm
		--set @sql2 = replace(@sql2, 'CONVERT(ntext,', 'CONVERT(nvarchar(4000),')
		--set @sql2 = replace(@sql2, 'CONVERT(text,', 'CONVERT(varchar(8000),')
	end
	select @sql1 as newfields, @sql2 as fieldconverts, @bs as bs
	set nocount off
end

GO

if exists (select 1 from dbo.sysobjects where id = object_id(N'[dbo].[fun_getStrOfTypeNLength]'))
drop function [dbo].[fun_getStrOfTypeNLength]

GO

CREATE function [dbo].[fun_getStrOfTypeNLength](@strType varchar(20),@intLength int,@intPt int)returns varchar(100)
begin
	return
	case @strType
		when 'char' then 'char(' + cast(@intLength as varchar(10)) + ')'
		when 'nchar' then 'nchar(' + cast(@intLength as varchar(10)) + ')'
		when 'varchar' then (case @intLength when -1 then 'varchar(max)' else 'varchar(' + cast(@intLength as varchar(10)) + ')' end)
		when 'nvarchar' then (case @intLength when -1 then 'nvarchar(max)' else 'nvarchar(' + cast(@intLength as varchar(10)) + ')' end)
		when 'binary' then 'binary(' + cast(@intLength as varchar(10)) + ')'
		when 'varbinary' then 'varbinary(' + cast(@intLength as varchar(10)) + ')'
		when 'numeric' then 'numeric(' + cast(@intLength as varchar(10)) + ',' + cast(@intPt as varchar(10))  + ')'
		when 'decimal' then 'decimal(' + cast(@intLength as varchar(10)) + ',' + cast(@intPt as varchar(10))  + ')'
		else @strType
	end
end

GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TableIsDiffer]'))
drop function [dbo].[TableIsDiffer]

GO


create  function [dbo].[TableIsDiffer](@db1 varchar(300),@db2 varchar(300))
returns int
as begin
	declare @r int
	if exists(
		select  1 from (
			select name, [length], [xusertype], [isnullable],  [status],  [xprec], [xscale], [cdefault] from syscolumns a where a.id = object_id(@db1)
		) a full join (
			select *  from syscolumns a where a.id = object_id(@db2)
		) b on a.name = b.name  
		and a.xusertype=b.xusertype 
		and  a.length=b.length 
		and a.isnullable = b.isnullable 
		and a.status=b.status
        and a.xprec=b.xprec 
		and a.xscale =b.xscale  
		and sign(a.cdefault)=sign(b.cdefault) 
		where  sign(isnull(a.[xusertype],0)) <> sign( isnull(b.[xusertype],0))
	)
	begin
		set @r = 1
	end
	else
	begin
		if exists(
			--判断索引是否相同
			select 1 from (
			select column_name from information_schema.key_column_usage   
			where table_name=replace(replace(replace(@db1,'[',''),']',''),'dbo.','')
			) a 
			full join (
			select column_name from information_schema.key_column_usage   
			where table_name=replace(replace(replace(@db2,'[',''),']',''),'dbo.','')
			) b on a.column_name=b.column_name
			where isnull(a.column_name,'')<>ISNULL(b.column_name,'')
		)
		begin
			set @r = 1
		end
		else
		begin
			set @r = 0
		end
	end
	return @r
end

GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[updateTable]'))
drop proc [dbo].[updateTable]

GO

CREATE   proc [dbo].[updateTable](
	@tb1 nvarchar(80),--更新的对象表
	@tb2 nvarchar(80)  --参照对象表
)   as
begin
	set nocount on;
	declare  @name varchar(100), @type varchar(100), @lenth varchar(12);
	declare  @scale varchar(12), @isnullable int;
	declare  @deftext nvarchar(200);
	declare  @countdiff int, @i int, @curri int;
	declare  @sql nvarchar(1800);

	Select 
		a.name, 
		case when exists(SELECT 1 FROM sysobjects where xtype='PK' and parent_obj=a.id and name in (SELECT name FROM sysindexes WHERE indid in( SELECT indid FROM sysindexkeys WHERE id = a.id AND colid=a.colid))) then '√' else '' end as ins,
		b.name as type,COLUMNPROPERTY(a.id,a.name,'PRECISION') as lenth,
		a.scale, e.[text] as deftext, a.isnullable, ROW_NUMBER() over(order by a.id) as rowindex, 
		a.id as colid,  a.cdefault as defaultid
	into #tb2 
	FROM syscolumns a 
	left join systypes b on a.xusertype=b.xusertype 
	inner join sysobjects d on a.id=d.id  and d.xtype='U' and  d.name<>'dtproperties' 
	left join syscomments e on e.id = a.cdefault
	where d.name=@tb2;

	Select 
		a.name, 
		case when exists(SELECT 1 FROM sysobjects where xtype='PK' and parent_obj=a.id and name in (SELECT name FROM sysindexes WHERE indid in( SELECT indid FROM sysindexkeys WHERE id = a.id AND colid=a.colid))) then '√' else '' end as ins,
		b.name as type,COLUMNPROPERTY(a.id,a.name,'PRECISION') as lenth,
		a.scale, e.[text] as deftext, a.isnullable, ROW_NUMBER() over(order by a.id)  as rowindex,
		a.id as colid, a.cdefault as defaultid
	into #tb1 
	FROM syscolumns a 
	left join systypes b on a.xusertype=b.xusertype 
	inner join sysobjects d on a.id=d.id  and d.xtype='U' and  d.name<>'dtproperties' 
	left join syscomments e on e.id = a.cdefault
	where d.name=@tb1
	set @i=0
	select @countdiff=count(a.name) from #tb2 a where name not in (select b.name from #tb1 b)
	while @i<@countdiff
	begin
		set @i=@i+1
		select top 1 
			@name=a.name,
			@type=a.[type],
			@lenth=cast(a.lenth as varchar(12)), 
			@scale=cast(a.scale as varchar(12)),
			@deftext = a.deftext,
			@isnullable = a.isnullable,
			@curri = a.rowindex
		from #tb2 a 
		where name not in (select b.name from #tb1 b);
		if @type in ('varchar','varbinary','nvarchar','nchar','char','binary')
		begin 
			set @sql = ('ALTER TABLE ['+@tb1+'] add ['+@name + '] ' + @type+'('+@lenth+') ')
		end
		else if @type in ('decimal','numeric')
		begin
			set @sql = ('ALTER TABLE ['+@tb1+'] add ['+@name + '] ' + @type+'('+@lenth+','+@scale+')')
		end
		else
		begin
			set @sql = ('ALTER TABLE ['+@tb1+'] add ['+@name +'] ' +@type)
		end

		set @sql = @sql + (case @isnullable when 1 then ' NULL'  else ' Not NULL' end) 
		if len(isnull(@deftext,''))>0 
		begin
			set @sql = @sql + ' default' + @deftext;
		end
		exec(@sql);
		delete #tb2 where rowindex = @curri
	end

	set @i=0
	declare @defaultid bigint
	declare @defaultname nvarchar(100)
	select @countdiff=count(a.name) from #tb1 a inner join #tb2 b on b.name=a.name 
	where a.[type]<>b.[type] or a.lenth<>b.lenth or isnull(a.scale,0)<>isnull(b.scale,0) or a.isnullable <> b.isnullable 
	or isnull(a.deftext,'')<> isnull(b.deftext,'')
	while @i<@countdiff
	begin
		set @i=@i+1

		select top 1
			@name=b.name,
			@type= b.type,
			@lenth=cast(b.lenth as varchar(12)),
			@scale=cast(b.scale as varchar(12)),
			@deftext = (case  when  isnull(a.deftext,'')<> isnull(b.deftext,'') then  isnull(b.deftext,'') else '@@@' end),
			@isnullable = b.isnullable,
			@curri = b.rowindex,
			@defaultid = a.defaultid
		from #tb1 a 
		inner join #tb2 b on b.name=a.name 
		where  a.[type]<>b.[type] or a.lenth<>b.lenth or isnull(a.scale,0)<>isnull(b.scale,0) or a.isnullable <> b.isnullable 
		or isnull(a.deftext,'')<> isnull(b.deftext,'')

		if @type in ('varchar','varbinary','nvarchar','nchar','char','binary')
		begin
			set @sql = ('ALTER TABLE ['+@tb1+'] ALTER COLUMN ['+@name + '] ' + @type+'('+@lenth+')')
		end
		else if @type in ('decimal','numeric')
		begin
			set @sql = ('ALTER TABLE ['+@tb1+'] ALTER COLUMN ['+@name + '] ' + @type+'('+@lenth+','+@scale+')')
		end
		else
		begin
			set @sql = ('ALTER TABLE ['+@tb1+'] ALTER COLUMN ['+@name +'] ' +@type)
		end
	--	select @deftext
		if isnull(@deftext,'')<>'@@@'
		begin
			set @defaultname = '';
			select  @defaultname = name from sysobjects where id=@defaultid and xtype='D'
			if @defaultname<>''
			begin
				exec('alter table [' + @tb1 +'] drop constraint ['+@defaultname + ']');
			end
			if @deftext<>''
			begin
				exec('alter table [' + @tb1 + '] add default' +  @deftext + ' for [' + @name + ']');
			end
		end
		set @sql = @sql + (case @isnullable when 1 then ' NULL'  else ' Not NULL' end) 
		exec(@sql);
		delete #tb2 where rowindex = @curri
	end
	drop table #tb1
	drop table #tb2
	set nocount off;
end

GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_CompareTable]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop proc [dbo].[sp_CompareTable]

GO

--处理生产前期老数据
if exists(select 1 from syscolumns where id = object_Id('M_ManuOrderLists') and name='cklist' and length> 20)
begin
	exec('update M_ManuOrderLists set cklist =  0 where isnumeric(cklist) = 0')
end

GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[autoChangeIndexAndStatistics]'))
drop proc [dbo].[autoChangeIndexAndStatistics]

GO

create proc [dbo].[autoChangeIndexAndStatistics]
@mode varchar(30),
@clustered bit,
@name varchar(50),
@table varchar(100),
@fields varchar(2000),
@createSQL varchar(4000)
as
begin
	--自动维护索引和统计
	set nocount on
	declare @compareFields varchar(2000),@eName varchar(100),@eFields varchar(2000),@remark varchar(2000)
	set @compareFields = replace(replace(replace(replace(replace(@fields,'desc','(-)'),'asc',''),'[',''),']',''),' ','')

	if @mode = 'index'
	begin
		create table #indexInfo(name varchar(255),remark varchar(255),fields varchar(2000))
		insert into #indexInfo exec sp_helpindex @table
		update #indexInfo set fields = replace(fields,' ','')

		if @clustered=1 --聚集索引
		begin
			select @eName=name,@eFields=fields,@remark=remark from #indexInfo where left(remark,9) = 'clustered'
			if @@ROWCOUNT > 0
			begin
				--如果已存在聚集索引,判断字段是否完全相同，不完全相同则删除聚集索引后再创建，完全相同则不做处理
				if @eFields <> @compareFields 
				begin
					--如果该索引是由主键创建的，则删除其约束即可，只有不是由主键约束的才能直接删除索引，否则会报错
					if charindex('primary key',@remark) > 0
					begin
						create table #constraintinfo(cType varchar(1000),cName varchar(1000),f1 varchar(1000),f2 varchar(1000),f3 varchar(1000),f4 varchar(1000),cKeys varchar(1000))
						insert into #constraintinfo	exec sp_helpconstraint @table,'nomsg'
						declare @cName varchar(1000)
						select @cName = cName from #constraintinfo where cType = 'PRIMARY KEY (clustered)' and replace(cKeys,' ','') = @eFields
						if @@ROWCOUNT > 0
						begin
							exec('alter table ' + @table + ' drop constraint ' + @cName)
						end
					end
					else
					begin
						exec('drop index ' + @table + '.' + @eName)
					end
					exec(@createSQL)
				end
			end
			else
			begin
				--如果不存在聚集索引则直接创建
				exec(@createSQL)
			end
		end
		else --非聚集索引
		begin
			--先判断有无同名索引
			select @eName=name,@eFields=fields from #indexInfo where left(remark,12) = 'nonclustered' and name=@name
			if @@ROWCOUNT > 0
			begin
				--如果有同名索引，判断字段是否相同，相同则不做处理，不相同则删除同名索引再创建
				if @eFields <> @compareFields
				begin
					exec('DROP INDEX '+@table+'.' + @eName)
					exec(@createSQL)
				end
			end
			else
			begin
				--如果无同名索引，则判断有无字段相同的非聚集索引，如果有则不做处理，如果没有则创建该索引
				if not exists(select top 1 name from #indexInfo where left(remark,12) = 'nonclustered' and fields=@compareFields)
				begin
					exec(@createSQL)
				end
			end
		end

		truncate table #indexInfo
		drop table #indexInfo
	end
	else if @mode = 'statistics'
	begin
		set @compareFields = replace(@compareFields,'(-)','')
		create table #statInfo(name varchar(255),fields varchar(2000))
		insert into #statInfo exec sp_helpstats @table
		update #statInfo set fields = replace(fields,' ','')

		--先判断有无同名统计
		select @eFields=fields from #statInfo where name=@name
		if @@ROWCOUNT>0
		begin
			--有同名统计时，判断字段是否完全相同，相同则不做处理，不相同则删除同名统计再创建
			if @eFields <> @compareFields
			begin
				exec('DROP STATISTICS '+@table+'.' + @name)
				exec(@createSQL)
			end
		end
		else
		begin
			--无同名统计时，判断有无字段相同的统计，如果有则不做处理，如果没有则创建该统计
			if not exists(select top 1 name from #statInfo where fields=@compareFields)
			begin
				exec(@createSQL)
			end
		end

		truncate table #statInfo
		drop table #statInfo
	end
	else
	begin
		raiserror('非法的@mode参数,只支持"index"或"statistics"',16,1)
	end

	set nocount off
end

GO

if exists (select 1 from dbo.sysobjects where id = object_id(N'[dbo].[home_usConfig]'))
begin
	if not exists(select top 1 1 from dbo.syscolumns where id=object_id('product') and name='includeTax')
	begin
		insert into home_usConfig(name,nvalue,tvalue,uid) values('PRODUCT_INCLUDE_TAX_PROPERTY_SETTING',null,1,0)
	end 
end 

GO

if exists (select 1 from dbo.sysobjects where id = object_id(N'[dbo].[sys_update_gatehistorytable]'))
drop proc [dbo].[sys_update_gatehistorytable]

GO

create proc [dbo].[sys_update_gatehistorytable](@tbname nvarchar(500),  @sorce1key nvarchar(500),  @sorce2key nvarchar(500))
as  begin
	declare @sql nvarchar(2000)
	set @sorce1key = isnull(@sorce1key,'sorce');
	set @sorce2key = isnull(@sorce2key,'sorce2');
	if exists(select 1 from dbo.sysobjects where name=@tbname and type='U')
	begin
		set @sql = ''
		if len(@sorce1key)>0 
		begin
				set @sql = 'update x set x.' + @sorce1key + '=y.id from ' + @tbname + ' x inner join orgs_parts y on x.' + @sorce1key + '=y.Old_Gate1ID'
		end
		if len(@sorce2key)>0 
		begin
				set @sql = @sql +  '
				update x set x.' + @sorce2key + '=y.id from ' + @tbname + ' x inner join orgs_parts y on x.' + @sorce2key + '=y.Old_Gate2ID'
		end
		exec(@sql);
	end
end

GO

if exists (select 1 from dbo.sysobjects where id = object_id(N'[dbo].[HandleOldGateHistoryData]'))
drop proc [dbo].[HandleOldGateHistoryData]

GO

if exists (select 1 from dbo.sysobjects where id = object_id(N'[dbo].[power2]'))
begin
	if  not exists(select 1 from syscolumns where name='orgsids' and id = OBJECT_ID('[dbo].[power2]'))
	begin
		exec('alter table power2 add orgsids ntext null')
	end
end

GO

create proc [dbo].[HandleOldGateHistoryData]
as begin
	if exists(select 1 from dbo.sysobjects where name='gate1' and type='U')
	begin
		EXEC sp_rename 'gate1', 'gate1____old';
	
		exec('
		insert into orgs_parts(PID, Name, Sort, Old_Gate1ID, openprice, Stoped)
		select 0, sort1, gate1, ord,  num1, 0 from [gate1____old] x
		where  not exists (select 1 from orgs_parts y where y.Old_Gate1ID=x.ord)
		');
	end

	if exists(select 1 from dbo.sysobjects where name='gate2' and type='U')
	begin
		EXEC sp_rename 'gate2', 'gate2____old';
		
		exec('
		insert into orgs_parts(PID, Name, Sort, Old_Gate2ID, openprice, Stoped)
		select z.id , x.sort2, x.gate2, x.ord, 0, 0 from gate2____old x 
		inner join gate1____old y on x.sort1=y.ord
		inner join orgs_parts z on y.ord= z.Old_Gate1ID
		where not exists (select 1 from orgs_parts m where m.Old_Gate2ID=x.ord)
		');
		
		exec sys_update_gatehistorytable 'hr_reinstate', null, null;
		exec sys_update_gatehistorytable 'gate', null, null;
		exec sys_update_gatehistorytable 'hr_leave', null, null;
		exec sys_update_gatehistorytable 'hr_off_staff', null, null;
		exec sys_update_gatehistorytable 'f_pay', 'sorce', 'sorce1';
		exec sys_update_gatehistorytable 'payjk', 'sorce', 'sorce1';
		exec sys_update_gatehistorytable 'hr_plan_list', null, null;
		exec sys_update_gatehistorytable 'hr_person', null, null;
		exec sys_update_gatehistorytable 'hr_NeedPerson_list', null, null;
		exec sys_update_gatehistorytable 'salesTarget', null, null;
		exec sys_update_gatehistorytable 'hr_transfer', null, null;
		exec sys_update_gatehistorytable 'salesTarget_batch', null, null;
		exec sys_update_gatehistorytable 'hr_pub_postion', null, null;
		exec sys_update_gatehistorytable 'gate_his', null, null;
		exec sys_update_gatehistorytable 'tel', 'cateid2', 'cateid3';
		exec sys_update_gatehistorytable 'contractthlist', 'cateid2', 'cateid3';
		exec sys_update_gatehistorytable 'fuwu', 'cateid2', 'cateid3';
		exec sys_update_gatehistorytable 'his_kuin', 'cateid2', 'cateid3';
		exec sys_update_gatehistorytable 'his_kuout', 'cateid2', 'cateid3';
		exec sys_update_gatehistorytable 'teljf2', 'cateid2', 'cateid3';
		exec sys_update_gatehistorytable 'his_kuoutlist2', 'cateid2', 'cateid3';
		exec sys_update_gatehistorytable 'tousu', 'cateid2', 'cateid3';
		exec sys_update_gatehistorytable 'caigouth', 'cateid2', 'cateid3';
		exec sys_update_gatehistorytable 'price', 'cateid2', 'cateid3';
		exec sys_update_gatehistorytable 'caigouthlist', 'cateid2', 'cateid3';
		exec sys_update_gatehistorytable 'payout3', 'cateid2', 'cateid3';
		exec sys_update_gatehistorytable 'Store_KuAllinOne', 'cateid2', 'cateid3';
		exec sys_update_gatehistorytable 'reply', 'cateid2', 'cateid3';
		exec sys_update_gatehistorytable 'Store_KuListAllinOne', 'cateid2', 'cateid3';
		exec sys_update_gatehistorytable 'returned', 'cateid2', 'cateid3';
		exec sys_update_gatehistorytable 'returnlist', 'cateid2', 'cateid3';
		exec sys_update_gatehistorytable 'send', 'cateid2', 'cateid3';
		exec sys_update_gatehistorytable 'wageslist', 'cateid2', 'cateid3';
		exec sys_update_gatehistorytable 'jzds', 'cateid2', 'cateid3';
		exec sys_update_gatehistorytable 'xunjia', 'cateid2', 'cateid3';
		exec sys_update_gatehistorytable 'xunjialist', 'cateid2', 'cateid3';
		exec sys_update_gatehistorytable 'kuhh', 'cateid2', 'cateid3';
		exec sys_update_gatehistorytable 'kuin', 'cateid2', 'cateid3';
		exec sys_update_gatehistorytable 'kujh', 'cateid2', 'cateid3';
		exec sys_update_gatehistorytable 'kumove', 'cateid2', 'cateid3';
		exec sys_update_gatehistorytable 'logMessage', 'cateid2', 'cateid3';
		exec sys_update_gatehistorytable 'kuout', 'cateid2', 'cateid3';
		exec sys_update_gatehistorytable 'kuoutlist2', 'cateid2', 'cateid3';
		exec sys_update_gatehistorytable 'kupd', 'cateid2', 'cateid3';
		exec sys_update_gatehistorytable 'kuzz', 'cateid2', 'cateid3';
		exec sys_update_gatehistorytable 'tel_his', 'cateid2', 'cateid3';
		exec sys_update_gatehistorytable 'plan2', 'cateid2', 'cateid3';
		exec sys_update_gatehistorytable 'person_his', 'cateid2', 'cateid3';
		exec sys_update_gatehistorytable 'call', 'cateid2', 'cateid3';
		exec sys_update_gatehistorytable 'option1', 'cateid2', 'cateid3';
		exec sys_update_gatehistorytable 'email_log', 'cateid2', 'cateid3';
		exec sys_update_gatehistorytable 'email_Send_Queue', 'cateid2', 'cateid3';
		exec sys_update_gatehistorytable 'payoutInvoice', 'cateid2', 'cateid3';
		exec sys_update_gatehistorytable 'pay', 'cateid2', 'cateid3';
		exec sys_update_gatehistorytable 'payback', 'cateid2', 'cateid3';
		exec sys_update_gatehistorytable 'payout', 'cateid2', 'cateid3';
		exec sys_update_gatehistorytable 'payout2', 'cateid2', 'cateid3';
		exec sys_update_gatehistorytable 'payreturn', 'cateid2', 'cateid3';
		exec sys_update_gatehistorytable 'person', 'cateid2', 'cateid3';
		exec sys_update_gatehistorytable 'plan1', 'cateid2', 'cateid3';
		exec sys_update_gatehistorytable 'paybx', 'cateid2', 'cateid3';
		exec sys_update_gatehistorytable 'caigou', 'cateid2', 'cateid3';
		exec sys_update_gatehistorytable 'caigoulist', 'cateid2', 'cateid3';
		exec sys_update_gatehistorytable 'caigou_yg', 'cateid2', 'cateid3';
		exec sys_update_gatehistorytable 'caigoulist_yg', 'cateid2', 'cateid3';
		exec sys_update_gatehistorytable 'chance', 'cateid2', 'cateid3';
		exec sys_update_gatehistorytable 'chance_his', 'cateid2', 'cateid3';
		exec sys_update_gatehistorytable 'contractlist', 'cateid2', 'cateid3';
		exec sys_update_gatehistorytable 'contractth', 'cateid2', 'cateid3';
		exec sys_update_gatehistorytable 'tel_sort_change_log', 'cateid2', 'cateid3';
		exec sys_update_gatehistorytable 'paybackInvoice', 'cateid2', 'cateid3';
		exec sys_update_gatehistorytable 'M_PieceRate', 'bm', 'zb';
		exec sys_update_gatehistorytable 'sortbank', 'sorce', '';

		if exists (select 1 from dbo.sysobjects where id = object_id(N'[dbo].[budget]'))
		begin
			exec('update x set x.Obj_ord = y.id from  budget x inner join orgs_parts y on x.sort=1 and x.Obj_ord=y.Old_Gate1ID')
		end

		--updated power2
		if exists (select 1 from dbo.sysobjects where id = object_id(N'[dbo].[power2]'))
		begin
			exec('
			declare @i int, @oldid varchar(12), @newid varchar(12), @maxi int
			select distinct y.Old_Gate1ID, y.ID , IDENTITY(Int, 1, 1) as i into #w1r  from power2 x inner join orgs_parts y on 
			charindex('',''+ cast(y.Old_Gate1ID as varchar(12)) + '',''  ,'',''+cast(x.w1 as varchar(8000)) + '','')>0
			where orgsids is null
			select @maxi = MAX(i) from #w1r
			set @i = 1
			while @i <=@maxi
			begin
				select @oldid = cast(Old_Gate1ID as varchar(12)),  @newid =CAST(ID as varchar(12)) from #w1r where i=@i
				update power2 set 
				w1 = replace(
							replace(
								replace(
									replace(''@,'' + replace((CAST(w1 as varchar(8000))),'' '','''') + '',='','','' + @oldid + '','','',''+ @newid + '','')
								,'',,'','',''),
							''@,'',''''),
						'',='','''')
				where  orgsids is null and w1 like ''%'' + @oldid + ''%''
				
				set @i = @i+1
			end
			drop table #w1r
			select distinct y.Old_Gate2ID, y.ID, IDENTITY(Int, 1, 1) as i into #w2r  from power2 x inner join orgs_parts y on 
			charindex('',''+ cast(y.Old_Gate2ID as varchar(12)) + '',''  ,'',''+cast(x.w2 as varchar(8000)) + '','')>0
			where orgsids is null
			select @maxi = MAX(i) from #w2r
			set @i = 1
			while @i <=@maxi
			begin
				select @oldid = Old_Gate2ID,  @newid =ID from #w2r where i=@i
				update power2 set 
				w2 = replace(
							replace(
								replace(
									replace(''@,'' + replace(CAST(w2 as varchar(8000)),'' '','''') + '',='','','' + @oldid + '','','',''+ @newid + '','')
								,'',,'','',''),
							''@,'',''''),
						'',='','''')
				where  orgsids is null and w2 like ''%'' + @oldid + ''%''
				set @i = @i+1
			end
			drop table #w2r
			update power2 set orgsids = ltrim(CAST(w1 as varchar(8000)) + '','' + CAST(w2 as varchar(8000)))  where orgsids is null
			')
		end 
	end
end 

GO

if exists (select 1 from dbo.sysobjects where id = object_id(N'[dbo].[MinNumber]'))
drop function [dbo].[MinNumber]

GO

create function [dbo].[MinNumber](@num numeric(32,8),  @minnum numeric(32,8))
returns numeric(32,8)
as begin
	return case when (@num > @minnum) then @minnum else @num end
end 

GO

if exists (select 1 from dbo.sysobjects where id = object_id(N'[dbo].[MinMin3Num]'))
drop function [dbo].[MinMin3Num]

GO

create function [dbo].[MinMin3Num] (
	@n1  numeric(32, 8 ),  @n2 numeric(32, 8 ),  @n3  numeric(32, 8 )
) returns numeric(32, 8 )
as begin
	return dbo.minNumber(dbo.minNumber(@n1, @n2), @n3)
end

GO

--针对入库明细表中单价字段由nvarchar转换成decimal后产生的数据异常进行处理
--1、将原值为空字符串，转换为0
--2、将原值为科学计数法，转换为正常浮点数
if exists(select 1
				from sys.tables t 
				inner join sys.columns c on t.object_id=c.object_id 
				inner join sys.types t1 on c.system_type_id=t1.system_type_id and t1.user_type_id=c.user_type_id
				where t.name='kuinlist' and c.name='price1' and t1.name<>'decimal')
begin

	update kuinlist set price1='0' where price1=''
	
	if exists(select 1 from sys.columns where name='price2' and object_id=OBJECT_ID('kuinlist'))
	begin
		exec(N'update kuinlist set price2=''0'' where price2=''''')
	end

	update kuinlist 
	set 
	price1=(case when CHARINDEX('e',a.price1)>0 then 
					(
						case when charindex('-',SUBSTRING(CAST(a.price1 AS NVARCHAR(100)),charindex('e',a.price1)+1,LEN(a.price1)-charindex('e',a.price1)))>0 then
							cast(cast(SUBSTRING(CAST(a.price1 AS NVARCHAR(100)),1,charindex('e',a.price1)-1) as decimal(25,12))/cast(power(10,0-SUBSTRING(CAST(a.price1 AS NVARCHAR(100)),charindex('e',a.price1)+1,LEN(a.price1)-charindex('e',a.price1))) AS decimal(25,12)) AS nvarchar(100))
						else
							cast(cast(SUBSTRING(CAST(a.price1 AS NVARCHAR(100)),1,charindex('e',a.price1)-1) as decimal(25,12))*cast(power(10,SUBSTRING(CAST(a.price1 AS NVARCHAR(100)),charindex('e',a.price1)+1,LEN(a.price1)-charindex('e',a.price1))) as decimal(25,12)) AS nvarchar(100))
						end)
			else a.price1 end)
	from ( select id, replace(price1,',','')  price1 from kuinlist where charindex('e',price1)>0 or CHARINDEX(',',price1)>0 ) a
		where kuinlist.id=a.id

	if exists(select 1 from sys.columns where name='price2' and object_id=OBJECT_ID('kuinlist'))
	begin
		exec(N'
		update kuinlist 
		set 
		price2=(case when CHARINDEX(''e'',a.price2)>0 then 
						(
							case when charindex(''-'',SUBSTRING(CAST(a.price2 AS NVARCHAR(100)),charindex(''e'',a.price2)+1,LEN(a.price2)-charindex(''e'',a.price2)))>0 then
								cast(cast(SUBSTRING(CAST(a.price2 AS NVARCHAR(100)),1,charindex(''e'',a.price2)-1) as decimal(25,12))/cast(power(10,0-SUBSTRING(CAST(a.price2 AS NVARCHAR(100)),charindex(''e'',a.price2)+1,LEN(a.price2)-charindex(''e'',a.price2))) AS decimal(25,12)) AS nvarchar(100))
							else
								cast(cast(SUBSTRING(CAST(a.price2 AS NVARCHAR(100)),1,charindex(''e'',a.price2)-1) as decimal(25,12))*cast(power(10,SUBSTRING(CAST(a.price2 AS NVARCHAR(100)),charindex(''e'',a.price2)+1,LEN(a.price2)-charindex(''e'',a.price2))) as decimal(25,12)) AS nvarchar(100))
							end)
				else a.price2 end)
		from (select id,replace(price2,'','','''')  price2 from kuinlist where charindex(''e'',price2)>0 or CHARINDEX('','',price2)>0) a
		where kuinlist.id=a.id')
	end 
end

GO

if exists (select 1 from dbo.sysobjects where id = object_id(N'[dbo].[CreateAccumulAssistListData]'))
drop proc [dbo].[CreateAccumulAssistListData]

GO

create  proc [dbo].[CreateAccumulAssistListData](@saasCompany int,  @finaceID int,  @currYear int,   @preYear int)
as 
begin
		set nocount on;
		DECLARE @kyear int
		---1.此方法在主数据库中执行。
		if @currYear<=@preYear 
		begin  
			SET @kyear=@preYear-1  
		end 
		ELSE BEGIN
			SET @kyear=@preYear 
		END
		declare @currdate1 datetime
		declare @predate2 datetime
		declare @currDBName nvarchar(40)
		declare @preDBName nvarchar(40)
		declare @finaceIDstr Nvarchar(12)
		declare @tb  table(dsign nvarchar(50),  m1 int,  m2 int)
		set @finaceIDstr = cast(@finaceID as varchar(12));
		insert into @tb(dsign, m1, m2)
		exec('select [sign],  AccountMonth1,  AccountMonth2 from AccountSys where  ord=' + @finaceIDstr)
		select
				@currDBName = 'ZB_FinanDB' + (case @saasCompany when 0 then '' else cast(@saasCompany as varchar(12)) end) + '_1' 
				+right([dsign],3) + right(cast(@currYear as varchar(12)),2) + right('0000' + cast(@finaceID%9999 as varchar(12)), 4),
				@preDBName = 'ZB_FinanDB' + (case @saasCompany when 0 then '' else cast(@saasCompany as varchar(12)) end) + '_1' 
				+right([dsign],3) + right(cast(@kyear as varchar(12)),2) + right('0000' + cast(@finaceID%9999 as varchar(12)), 4),
				@currdate1 =  cast(cast(@currYear as varchar(12)) + '-' +  cast(x.m1 as varchar(12)) + '-1' as datetime),
				@predate2 =  cast(cast(@preYear as varchar(12)) + '-' +  cast(x.m2 as varchar(12)) + '-1' as datetime)
		from @tb x 
		
		--x.1 取上年数据计算辅助核算
		create table [#preYearAssistData] (
			[rowindex] [int] ,
			Fullcode varchar(200), balanceDirection int,  bz int,
			AssistSubject int,  AssistID int, 
			money4_b decimal(25, 12), money4_y decimal(25, 12), 
			nums decimal(25, 12),  unit INT,AssistMerge VARCHAR(50)
		);

		declare @sql varchar(MAX)
		set @sql = N'
				DECLARE @bwb int;
				select @bwb= bz from @@FinceDBName..f_Account;
				set @bwb = isnull(@bwb,14)
				--1.1 提取辅助核算年初始化数据流水
				select  a.id as PID,
						aa.Fullcode, a.balanceDirection,
						b.AssistSubject,  b.AssistID, 
						b.money4_b,  b.money4_y,
						b.[index], b.bz,ISNULL(b.Num4,0) nums,ISNULL(b.Unit,0) unit,c.AssistMerge
						into #initlistdata
					from  @@FinceDBName..f_accumulSubject a 
				inner join @@FinceDBName..f_accountsubject aa on aa.ord = a.AccountSubject
				inner join  @@FinceDBName..f_accumuAssistList  b  on a.ID=b.PID and  b.sort1=0
				INNER JOIN (SELECT pid,[index],(CAST(CAST(ISNULL(STDEV(BINARY_CHECKSUM(CAST(AssistSubject AS INT),CAST(AssistID AS INT))),0) as  bigint) AS VARCHAR(40)) 
				+ CAST(cast(checksum_agg(CAST(BINARY_CHECKSUM(CAST(AssistSubject AS INT),CAST(AssistID AS INT)) AS INT)) as bigint)AS VARCHAR(40)) 
				+CAST(MAX(BINARY_CHECKSUM(CAST(AssistSubject AS INT),CAST(AssistID AS INT))) AS VARCHAR(40)) 
				+CAST(MIN(BINARY_CHECKSUM(CAST(AssistSubject AS INT),CAST(AssistID AS INT))) AS VARCHAR(40))   
				+ cast(COUNT(1)  as VARCHAR(40)))  AS  AssistMerge 
				FROM @@FinceDBName..f_accumuAssistList
				WHERE sort1=0 GROUP BY pid,[index]) c ON c.PID=b.pid AND b.[index]=c.[index]

				--1.2 提取凭证辅助核算数据流水
				select  b.id as PID,
						bb.Fullcode,  b.balanceDirection,
						c.AssistSubject,  c.AssistID,
						(case b.balanceDirection when 1 then b.money_J else b.money_D end)  as money4_b,
						isnull(b.money1,(case b.balanceDirection when 1 then b.money_J else b.money_D end)) as money4_y,0 AS [index],
						(case isnull(b.isBWB,0) when 0 then b.bz else @bwb end)  as bz,ISNULL(b.Nums,0) nums,ISNULL(c.Unit,0) unit,d.AssistMerge
				into #voucherlistdata
				from @@FinceDBName..f_Voucher a
				inner join (
						select  	
							*, (case sign(isnull(money_J,0)) when 0 then 2 else 1 end)  as balanceDirection
						from	@@FinceDBName..f_VoucherList
				) b on a.del=1 and a.ord = b.Voucher and a.[Status]>1 and a.[Status]<>4
				inner join @@FinceDBName..f_AccountSubject bb on b.AccountSubject = bb.Ord
				inner join @@FinceDBName..f_VoucherAssistList c on b.id =c.VoucherList and c.del=1
				inner JOIN (SELECT a.id,(CAST(CAST(ISNULL(STDEV(BINARY_CHECKSUM(AssistSubject, AssistID)),0) as  bigint) AS VARCHAR(40)) 
				+ CAST(cast(checksum_agg(CAST(BINARY_CHECKSUM(AssistSubject, AssistID) AS INT)) as bigint)AS VARCHAR(40))  
				+CAST(MAX(BINARY_CHECKSUM(AssistSubject, AssistID)) AS VARCHAR(40)) 
				+CAST(MIN(BINARY_CHECKSUM(AssistSubject, AssistID))  AS VARCHAR(40))  
				+ cast(COUNT(1)  as VARCHAR(40)))  AS  AssistMerge  
				FROM @@FinceDBName..f_VoucherList a INNER JOIN @@FinceDBName..f_VoucherAssistList c ON a.id=c.VoucherList
				GROUP BY a.id) d ON b.id=d.id 
						
						
				--2.2 组合期初和发生数据
				select 
					Fullcode,  balanceDirection, bz, t.AssistSubject,t.AssistID, 
					sum(isnull(t.money4_b,0)*fx) money4_b,SUM(isnull(t.money4_y,0)*fx) money4_y,SUM(isnull(t.nums,0)*fx) nums,t.unit,AssistMerge
				from (
					--初始化辅助核算数据
					SELECT  a.PID ,
							a.fullcode ,
							a.bz ,
							a1.balanceDirection ,
							( CASE a.balanceDirection
								WHEN a1.balanceDirection THEN 1
								ELSE -1				                
							  END ) AS fx ,
							a.AssistSubject ,
							a.AssistID ,
							a.money4_b ,
							a.money4_y ,
							a.nums ,
							a.unit,
							a.AssistMerge
					FROM    #initlistdata a
							INNER JOIN @@FinceDBName..f_AccountSubject a1 ON a.fullcode = a1.fullcode	 
					union all
					--凭证辅助核算数据
					SELECT  a.PID ,
							a.fullcode ,
							a.bz ,
							a1.balanceDirection ,
							( CASE a.balanceDirection
								WHEN a1.balanceDirection THEN 1
								ELSE -1
							  END ) AS fx ,
							a.AssistSubject ,
							a.AssistID ,
							a.money4_b ,
							a.money4_y ,
							a.nums ,
							a.unit,
							a.AssistMerge
					FROM    #voucherlistdata a
							INNER JOIN @@FinceDBName..f_AccountSubject a1 ON a.fullcode = a1.fullcode
				)  t 
				where t.AssistID>0
				group by   Fullcode,  balanceDirection, bz, t.AssistSubject,t.AssistID, t.AssistMerge,t.unit
				order by t.AssistMerge
				drop table #initlistdata
				drop table #voucherlistdata'
		set @sql = replace(@sql, '@@FinceDBName', '[' + @preDBName + ']');
		 
		insert into [#preYearAssistData](
			Fullcode, balanceDirection,  bz ,
			AssistSubject ,  AssistID , 
			money4_b , money4_y , 
			nums ,  unit,AssistMerge )
		exec(@sql);
		
		UPDATE a SET a.rowindex=b.rindex FROM [#preYearAssistData] a INNER JOIN (
		SELECT fullcode,AssistMerge,ROW_NUMBER() OVER(PARTITION BY fullcode ORDER BY AssistMerge) rindex FROM [#preYearAssistData] GROUP BY fullcode,AssistMerge) b 
		ON a.Fullcode=b.Fullcode AND a.AssistMerge=b.AssistMerge
		 
		 
		--x.2 将上年辅助核算数据【#preYearAssistData】插入到本年
		--x.2.1 先维护初始化数据的index值
		set @sql = N'
		update a1 set a1.[index]=a2.rowindex  from @@FinceDBName..f_accumulSubject  a1 
		inner join (
			select ROW_NUMBER() over (order by  y.fullcode) as rowindex,  x.id  from  @@FinceDBName..f_accumulSubject x
            inner join @@FinceDBName..f_AccountSubject xx on xx.Ord = x.AccountSubject
			inner join  @@FinceDBName..f_AccountSubject y on xx.Fullcode=y.Fullcode
			where x.sort1=0 and x.[index] is null  
		) a2  on a1.id=a2.id
		--x.2.2 删除原有辅助核算数据
		delete  @@FinceDBName..f_accumuAssistList where sort1=0;
		declare @maxrowindex int;
		select @maxrowindex = max([index]) from @@FinceDBName..f_accumulSubject;
		--x.2.3  
		insert into  @@FinceDBName..f_accumuAssistList (
			sort1,  pid, AssistSubject,  AssistID, money1_b, money1_y, 
			money2_b, money2_y,  money3_b, money3_y, 
			money4_b, money4_y, [index], [pindex], bz, Num1,Num2,Num3,Num4,Unit,hl
		)
		select  
			0,  y.id,   x.AssistSubject,  x.AssistID,  x.money4_b,  x.money4_y,
			0,0,0,0,
			x.money4_b,  x.money4_y,  x.rowindex+@maxrowindex,  y.[index],  x.bz,x.nums,0,0,x.nums,x.unit, NULL
		from   [#preYearAssistData] x
        inner join @@FinceDBName..f_AccountSubject xx on xx.Fullcode = x.fullcode
		inner join @@FinceDBName..f_accumulSubject y on xx.Ord=y.AccountSubject and x.bz = y.bz 
		and ( abs(x.money4_b)>0 or  abs(x.money4_y)>0) 
		where  x.AssistID>0 and  y.sort1=0'
		set  @sql = REPLACE(@sql, '@@FinceDBName', '[' + @currDBName + ']');
		exec(@sql);
		 
		
		
		--创建一个空辅助核算项，承载无辅助核算的数据
		set @sql = N'
		declare @nullAssistsType int;
		declare @maxrowindex int;
		select @maxrowindex = max([index]) from @@FinceDBName..f_accumulSubject;
		insert into  @@FinceDBName..f_AssistSubject(title, isdef, del, [stop])
		select '''' as title,  1,  0, 1
		where not exists(  select 1 from @@FinceDBName..f_AssistSubject where len(isnull(title,''''))=0 and del=0 and [stop]=1 )
		select @nullAssistsType = id  from @@FinceDBName..f_AssistSubject where len(isnull(title,''''))=0 and del=0 and [stop]=1

		insert into  @@FinceDBName..f_accumuAssistList (
			sort1,  pid, AssistSubject,  AssistID, money1_b, money1_y, 
			money2_b, money2_y,  money3_b, money3_y, 
			money4_b, money4_y, [index], [pindex], bz,Num1,Num2,Num3,Num4,Unit,  hl
		)
		select  
			0, id,   @nullAssistsType,  0,  dt_money1_b,  dt_money1_y, 
			0, 0 , 0 , 0,  dt_money1_b,  dt_money1_y,  1000000+@maxrowindex,  pindex, bz,dt_nums,0,0,dt_nums,0, NULL
		from (
			 select
				 a1.id, a1.bz,
				(a1.money4_b-b1.money1_b) as dt_money1_b, 
				(a1.money4_y-b1.money1_y) as  dt_money1_y ,
				(a1.Num4-b1.nums) AS dt_nums,
				a1.[index] as pindex
			 from  @@FinceDBName..f_accumulSubject a1 
			 inner  join (
				select 
					sum(money1_b) money1_b , 
					sum(money1_y) money1_y ,SUM(x.Num1) nums,  pid 
				from @@FinceDBName..f_accumuAssistList x
				inner join (select min(id) as minID from  @@FinceDBName..f_accumuAssistList group by pid, [index]) y on x.id=y.minID
				 where sort1=0  
				 group by  pid
			) b1 on a1.id=b1.pid and a1.sort1=0
		) tt where abs(tt.dt_money1_b) > 0 and abs(tt.dt_money1_y) > 0';
		set  @sql = REPLACE(@sql, '@@FinceDBName', '[' + @currDBName + ']');
		exec(@sql);
		set nocount off;
end

GO

if exists (select 1 from dbo.sysobjects where id = object_id(N'[dbo].[power]'))
delete power where id in (
	select x.id  from power x
	left join ( select min(id) as mid  from power group by sort1, sort2, ord ) y on x.id=y.mid
	where y.mid is null
)

GO

if exists (select 1 from dbo.sysobjects where id = object_id(N'[dbo].[mcostlog]'))
begin
	update a  
		set a.JoinBillId = 0-year(a.Date1)*100 - month(a.Date1),
		a.JoinBillListId = 0
	from mcostlog a inner join mcostinfo b on  a.LogType=0 and  a.CostId=b.Id and b.CostType=2 and a.JoinBillId>=0

	update a  
		set a.JoinBillId = 0-year(a.Date1)*100 - month(a.Date1),
		a.JoinBillListId = -a.RootKuinListId
	from mcostlog a inner join mcostinfo b on  a.LogType=0 and  a.CostId=b.Id and b.CostType in (0,1) and (a.JoinBillId>=0 or a.JoinBillListId=0)

	update a  
		set a.JoinBillId = 0-year(a.Date1)*100 - month(a.Date1),
		a.JoinBillListId = -a.LogUnit
	from mcostlog a inner join mcostinfo b on  a.LogType=0 and  a.CostId=b.Id and b.CostType =3 and (a.JoinBillId>=0 or a.JoinBillListId=0)
end

GO

if exists (select 1 from dbo.sysobjects where id = object_id(N'sys_sdk_BillFieldInfo'))
begin
	update x set  x.DBName='newmain_' + cast(id as varchar(12))  from sys_sdk_BillFieldInfo x where DBName='' and ListType=0
end

GO

if exists (select 1 from dbo.sysobjects where id = object_id(N'sys_sdk_BillFieldValue'))
begin
	if not exists(	select 1 from sys.columns where name='InheritId' and object_id=OBJECT_ID('sys_sdk_BillFieldValue'))
	begin 
		exec('alter table sys_sdk_BillFieldValue add InheritId int not null default(0)')
	end
end

GO

if exists (select 1 from dbo.sysobjects where id = object_id(N'sys_sdk_BillFieldValue'))
begin
	update x set x.BillId=-1  from sys_sdk_BillFieldValue x  where x.billtype=11001 and x.billlisttype=1 and x.billid=0
	if not exists(select 1 from sys.objects where name='CK_BillID>0' and parent_object_id=OBJECT_ID('sys_sdk_BillFieldValue'))
	begin
		ALTER TABLE [dbo].[sys_sdk_BillFieldValue]  WITH CHECK ADD  CONSTRAINT [CK_BillID>0] CHECK  (([billid]<>(0)))
	end
    update x set x.InheritId=isnull((case when y.InheritId = 0 then y.id else y.InheritId end),x.FieldId) 
						from sys_sdk_BillFieldValue x 
                        left join sys_sdk_BillFieldInfo y on x.FieldId = y.id where x.InheritId=0
    if not exists(select 1 from sys.objects where name='CK_InheritId>0' and parent_object_id=OBJECT_ID('sys_sdk_BillFieldValue'))
	begin
		ALTER TABLE [dbo].[sys_sdk_BillFieldValue]  WITH CHECK ADD  CONSTRAINT [CK_InheritId>0] CHECK  (([InheritId]<>(0)))
	end
end

GO
--升级报mob_userloginlog存在重复键
if exists (select 1 from dbo.sysobjects where id = object_id(N'Mob_UserLoginLog'))
begin
    delete from Mob_UserLoginLog where id not in (
	    select max(id) id from Mob_UserLoginLog group by ord,MobileModel,AppVersion,macsn having count(*)>0
    )
end

GO
--升级报sys_sdk_BillFieldValue存在重复键
if exists (select 1 from dbo.sysobjects where id = object_id(N'sys_sdk_BillFieldValue'))
begin
    delete from sys_sdk_BillFieldValue where iord in (
	    select MIN(iord) id from sys_sdk_BillFieldValue group by BillType,BillListType,BillId,ListID,FieldId having COUNT(*)>1
    )
end