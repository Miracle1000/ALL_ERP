 --<%response.end%>
CREATE TRIGGER UpdateContractGainOrLoss on pay
   AFTER  INSERT,DELETE,UPDATE
AS 
BEGIN
	set nocount on
	--判断与合同关联的费用数据是否发生了变化
	if exists(
		select 1 from (
			select [contract], -money1 as m, ord from deleted where [contract] >0 and complete=3 and del=1 and money1<>0
			union all
			select [contract], money1, ord from inserted where [contract] >0 and complete=3 and del=1 and money1<>0
		) x group by [contract], ord 
		having sum(m)<>0
	) begin
		declare @i int, @maxi int, @htid int, @srcid int, @nmoney decimal(25,12)
		declare @fylist table([contract] int, splitmoney decimal(25,12), srcid int, i int Identity(1,1))
		insert into @fylist([contract], splitmoney, srcid)
		select [contract], sum(m), ord from (
 			select [contract], 0 as m, ord from deleted where [contract] >0 and complete=3 and del=1 and money1<>0
			union all
			select [contract], money1,ord from inserted where [contract] >0 and complete=3 and del=1 and money1<>0
		) t group by [contract], ord
		set @i = 0
		select @maxi = max(i) from @fylist

		while @i < @maxi
		begin
			set @i = @i + 1
			select @htid = [contract], @srcid = srcid, @nmoney= isnull(splitmoney,0) from @fylist where i=@i
			exec erp_contract_OnSaveHandleItem @htid, @nmoney, 'fy', @srcid
		end
	end
	set nocount off
END
