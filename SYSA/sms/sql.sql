USE [zbintelweb]
GO
/****** 对象:  Table [dbo].[sms_interface]    脚本日期: 12/26/2011 10:17:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[sms_interface](
	[ord] [int] IDENTITY(1,1) NOT NULL,
	[Suppliers] [varchar](100) COLLATE Chinese_PRC_CI_AS NOT NULL,
	[ChannelName] [varchar](50) COLLATE Chinese_PRC_CI_AS NOT NULL,
	[sendUrl] [varchar](200) COLLATE Chinese_PRC_CI_AS NOT NULL,
	[recURL] [varchar](200) COLLATE Chinese_PRC_CI_AS NOT NULL,
	[us] [varchar](50) COLLATE Chinese_PRC_CI_AS NOT NULL,
	[ps] [varchar](50) COLLATE Chinese_PRC_CI_AS NOT NULL,
	[CanLong] [int] NOT NULL,
	[MaxBits] [int] NOT NULL,
	[UnitBits] [int] NOT NULL,
	[SignBits] [int] NOT NULL,
	[longBits] [int] NOT NULL,
	[sendPrice] [money] NOT NULL,
	[recPrice] [money] NOT NULL,
	[canDocking] [int] NOT NULL,
	[CanallNet] [int] NOT NULL,
	[mmsMaxBit] [int] NOT NULL,
	[mmsPrice] [money] NOT NULL,
	[Canmms] [int] NOT NULL,
	[addtime] [datetime] NOT NULL,
	[del] [int] NOT NULL,
	[sendCount] [int] NOT NULL,
	[remark] [varchar](200) COLLATE Chinese_PRC_CI_AS NULL,
	[telnum] [varchar](20) COLLATE Chinese_PRC_CI_AS NULL,
	[mnc] [int] NOT NULL CONSTRAINT [DF_sms_interface_mnc]  DEFAULT (90),  --最大并发数
 CONSTRAINT [PK_sms_interface] PRIMARY KEY CLUSTERED 
(
	[ord] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC dbo.sp_addextendedproperty @name=N'MS_Description', @value=N'供应商名称' , @level0type=N'USER',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sms_interface', @level2type=N'COLUMN',@level2name=N'Suppliers'
GO
EXEC dbo.sp_addextendedproperty @name=N'MS_Description', @value=N'通道名称' , @level0type=N'USER',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sms_interface', @level2type=N'COLUMN',@level2name=N'ChannelName'
GO
EXEC dbo.sp_addextendedproperty @name=N'MS_Description', @value=N'发送网址' , @level0type=N'USER',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sms_interface', @level2type=N'COLUMN',@level2name=N'sendUrl'
GO
EXEC dbo.sp_addextendedproperty @name=N'MS_Description', @value=N'接收网址' , @level0type=N'USER',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sms_interface', @level2type=N'COLUMN',@level2name=N'recURL'
GO
EXEC dbo.sp_addextendedproperty @name=N'MS_Description', @value=N'账号' , @level0type=N'USER',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sms_interface', @level2type=N'COLUMN',@level2name=N'us'
GO
EXEC dbo.sp_addextendedproperty @name=N'MS_Description', @value=N'密码' , @level0type=N'USER',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sms_interface', @level2type=N'COLUMN',@level2name=N'ps'
GO
EXEC dbo.sp_addextendedproperty @name=N'MS_Description', @value=N'是否支持长短信' , @level0type=N'USER',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sms_interface', @level2type=N'COLUMN',@level2name=N'CanLong'
GO
EXEC dbo.sp_addextendedproperty @name=N'MS_Description', @value=N'单位字符数量' , @level0type=N'USER',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sms_interface', @level2type=N'COLUMN',@level2name=N'UnitBits'
GO
EXEC dbo.sp_addextendedproperty @name=N'MS_Description', @value=N'签名占位数' , @level0type=N'USER',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sms_interface', @level2type=N'COLUMN',@level2name=N'SignBits'
GO
EXEC dbo.sp_addextendedproperty @name=N'MS_Description', @value=N'长短信占位数' , @level0type=N'USER',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sms_interface', @level2type=N'COLUMN',@level2name=N'longBits'
GO
EXEC dbo.sp_addextendedproperty @name=N'MS_Description', @value=N'发送单价' , @level0type=N'USER',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sms_interface', @level2type=N'COLUMN',@level2name=N'sendPrice'
GO
EXEC dbo.sp_addextendedproperty @name=N'MS_Description', @value=N'接收单价' , @level0type=N'USER',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sms_interface', @level2type=N'COLUMN',@level2name=N'recPrice'
GO
EXEC dbo.sp_addextendedproperty @name=N'MS_Description', @value=N'是否支持对接' , @level0type=N'USER',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sms_interface', @level2type=N'COLUMN',@level2name=N'canDocking'
GO
EXEC dbo.sp_addextendedproperty @name=N'MS_Description', @value=N'是否是全网发送' , @level0type=N'USER',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sms_interface', @level2type=N'COLUMN',@level2name=N'CanallNet'
GO
EXEC dbo.sp_addextendedproperty @name=N'MS_Description', @value=N'彩信最大字数' , @level0type=N'USER',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sms_interface', @level2type=N'COLUMN',@level2name=N'mmsMaxBit'
GO
EXEC dbo.sp_addextendedproperty @name=N'MS_Description', @value=N'彩信单价' , @level0type=N'USER',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sms_interface', @level2type=N'COLUMN',@level2name=N'mmsPrice'
GO
EXEC dbo.sp_addextendedproperty @name=N'MS_Description', @value=N'是否支持彩信' , @level0type=N'USER',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sms_interface', @level2type=N'COLUMN',@level2name=N'Canmms'
GO
EXEC dbo.sp_addextendedproperty @name=N'MS_Description', @value=N'添加时间' , @level0type=N'USER',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sms_interface', @level2type=N'COLUMN',@level2name=N'addtime'
GO
EXEC dbo.sp_addextendedproperty @name=N'MS_Description', @value=N'是否删除' , @level0type=N'USER',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sms_interface', @level2type=N'COLUMN',@level2name=N'del'
GO
EXEC dbo.sp_addextendedproperty @name=N'MS_Description', @value=N'发送总量' , @level0type=N'USER',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sms_interface', @level2type=N'COLUMN',@level2name=N'sendCount'
GO
EXEC dbo.sp_addextendedproperty @name=N'MS_Description', @value=N'备注' , @level0type=N'USER',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sms_interface', @level2type=N'COLUMN',@level2name=N'remark'

ALTER TABLE dbo.logMessage ADD
	chancel int NULL,
	timerSend int NULL,
	sendtime datetime NULL,
	rsendtime datetime NULL,
	pc int null,
	longmode int NULL,
	needrec int NULL
GO

CREATE TABLE dbo.erp_sms_TimerTask
(
	id int NOT NULL IDENTITY (1, 1),
	addTime datetime NOT NULL,
	fireTime datetime NOT NULL,
	url varchar(100) NOT NULL,
	execTime datetime NOT NULL,
	execed int not null,
	uid int not null,
)  ON [PRIMARY]

GO

ALTER TABLE dbo.smsLog ADD		--zbintel.com
	delay int NULL,		'是否需要延时发送
	sendtime datetime NULL	'真实发送时间（即往供应商提交时间）
	smsLog varchar(2000)	'客户发送的log
	sendurl ntext		'发送网址
	resultdata ntext	'返回数据
	xlh  int		'序列号,批次相同
	smcount			'短信计费条数



ALTER proc [dbo].[erp_sms_savesendinfo](	--zbintel.com
	 @sms varchar(64), @phones varchar(3000),
	 @body varchar(8000), @moneys money , @delay int,
	 @stact varchar(40), @smslog varchar(2000),
	 @url ntext,@smcount int
) as begin
	set nocount on
	insert into smsLog (sms,name,company,phone,content,stact,addtime,del,money1,strlength,approval,smslog,delay,sendurl,smcount)
	select top 1 
	x.sms, z.name , z.ord ,@phones,@body, @stact ,getdate(),1,@moneys,len(@body),null,@smslog , @delay , @url,@smcount
	from	
	(select @sms as sms ) x left join sms y
	on x.sms = y.dxName 
	left join tel z on z.ord = y.company
	
	if exists(select * from	sms where dxname = @sms and balance >  @moneys)
	begin 
		select  max(ord) as o , '' as stat from smslog
		update 	sms set balance = balance - @moneys where dxname = @sms
	end
	else
	begin
		select  max(ord) as o , '余额不足' as stat from smslog
	end
	set nocount off
end



---短信请求处理----zbinte_erp
create table smsHttpControl	
(
	[id] [int] IDENTITY(1,1) NOT NULL,
	logmessage int,		---logmessage
	clientxlh bigint	---客户端批次号
	--serverxlh int		---服务端批次号,废除掉
)




--海量数据分批提交临时号码表 , www.zbintel.com
create table sms_tempsendphones(
	[ord] [int] IDENTITY(1,1) NOT NULL,
	phones varchar(30),
	addcate	int,
	pch		int,
	addtime datetime
) 


CREATE TABLE [dbo].[sms_xlhlist](  --- 用来存放已经发送的任务序列号
	[xlh] [int] NOT NULL,
 CONSTRAINT [PK_sms_xlhlist] PRIMARY KEY CLUSTERED 
(
	[xlh] ASC
) ON [PRIMARY]
) ON [PRIMARY]



--短信回复接收表 , www.zbintel.com
drop table smsRecvLogs
CREATE TABLE [dbo].[smsRecvLogs]( 
	[ord] [int] NOT NULL,
	[phone] [nvarchar](50) COLLATE Chinese_PRC_CI_AS NULL,
	[recvtime] [datetime] NULL,
	[content] [nvarchar](1000) COLLATE Chinese_PRC_CI_AS NULL,
	sendlog int,
	adopted int,
	adoptTime datetime,
	extnum int,
	sn varchar(50)
) ON [PRIMARY]


--短信回复对应关系建立
ALTER  proc  [dbo].[sms_handlerecInfo] 
as begin
	set nocount on
	select x.ord as ord1 ,x.smsLog ,x.sms, y.ord as  ord2
	into #eee
	from smslog  x inner join smsRecvLogs y 
	on datediff(d,x.sendtime,getdate()) < 15  --只处理15天内回复 
		  and ((x.ord-y.extnum)%100 = 0) 
		  and datediff(s,x.sendtime, y.recvtime) > 0
		  and charindex(',' + y.phone + ',', ',' + x.phone + ',') > 0

	update smsRecvLogs set sendlog = x.ord1 , cslog = x.smsLog , sn=x.sms from (
		select smsLog ,sms, ord1 from  #eee where ord1 in (select max(ord1) from  #eee group by ord2,sms,smsLog)
	) x
	set nocount off
end



create proc erp_sms_onRec(
	@oMaxRecLogID int -- @oMaxRecLogID表示已经处理过的短信接收记录最大id
) as begin
	-- select * from MessageRecv where ord >  @oMaxRecLogID  --获取新的接收记录
	return
end

-----客户服务器端接收回复表

CREATE TABLE [dbo].[MessageRecv](
	[ord] [int] IDENTITY(1,1) NOT NULL,
	[logmessage] [int] NULL,
	[phone] [varchar](20) COLLATE Chinese_PRC_CI_AS NULL,
	[content] [varchar](2000) COLLATE Chinese_PRC_CI_AS NULL,
	[rectime] [datetime] NULL
) ON [PRIMARY]