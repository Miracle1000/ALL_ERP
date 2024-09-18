USE [zbintelweb]
GO
/****** ����:  Table [dbo].[sms_interface]    �ű�����: 12/26/2011 10:17:37 ******/
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
	[mnc] [int] NOT NULL CONSTRAINT [DF_sms_interface_mnc]  DEFAULT (90),  --��󲢷���
 CONSTRAINT [PK_sms_interface] PRIMARY KEY CLUSTERED 
(
	[ord] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC dbo.sp_addextendedproperty @name=N'MS_Description', @value=N'��Ӧ������' , @level0type=N'USER',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sms_interface', @level2type=N'COLUMN',@level2name=N'Suppliers'
GO
EXEC dbo.sp_addextendedproperty @name=N'MS_Description', @value=N'ͨ������' , @level0type=N'USER',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sms_interface', @level2type=N'COLUMN',@level2name=N'ChannelName'
GO
EXEC dbo.sp_addextendedproperty @name=N'MS_Description', @value=N'������ַ' , @level0type=N'USER',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sms_interface', @level2type=N'COLUMN',@level2name=N'sendUrl'
GO
EXEC dbo.sp_addextendedproperty @name=N'MS_Description', @value=N'������ַ' , @level0type=N'USER',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sms_interface', @level2type=N'COLUMN',@level2name=N'recURL'
GO
EXEC dbo.sp_addextendedproperty @name=N'MS_Description', @value=N'�˺�' , @level0type=N'USER',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sms_interface', @level2type=N'COLUMN',@level2name=N'us'
GO
EXEC dbo.sp_addextendedproperty @name=N'MS_Description', @value=N'����' , @level0type=N'USER',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sms_interface', @level2type=N'COLUMN',@level2name=N'ps'
GO
EXEC dbo.sp_addextendedproperty @name=N'MS_Description', @value=N'�Ƿ�֧�ֳ�����' , @level0type=N'USER',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sms_interface', @level2type=N'COLUMN',@level2name=N'CanLong'
GO
EXEC dbo.sp_addextendedproperty @name=N'MS_Description', @value=N'��λ�ַ�����' , @level0type=N'USER',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sms_interface', @level2type=N'COLUMN',@level2name=N'UnitBits'
GO
EXEC dbo.sp_addextendedproperty @name=N'MS_Description', @value=N'ǩ��ռλ��' , @level0type=N'USER',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sms_interface', @level2type=N'COLUMN',@level2name=N'SignBits'
GO
EXEC dbo.sp_addextendedproperty @name=N'MS_Description', @value=N'������ռλ��' , @level0type=N'USER',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sms_interface', @level2type=N'COLUMN',@level2name=N'longBits'
GO
EXEC dbo.sp_addextendedproperty @name=N'MS_Description', @value=N'���͵���' , @level0type=N'USER',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sms_interface', @level2type=N'COLUMN',@level2name=N'sendPrice'
GO
EXEC dbo.sp_addextendedproperty @name=N'MS_Description', @value=N'���յ���' , @level0type=N'USER',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sms_interface', @level2type=N'COLUMN',@level2name=N'recPrice'
GO
EXEC dbo.sp_addextendedproperty @name=N'MS_Description', @value=N'�Ƿ�֧�ֶԽ�' , @level0type=N'USER',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sms_interface', @level2type=N'COLUMN',@level2name=N'canDocking'
GO
EXEC dbo.sp_addextendedproperty @name=N'MS_Description', @value=N'�Ƿ���ȫ������' , @level0type=N'USER',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sms_interface', @level2type=N'COLUMN',@level2name=N'CanallNet'
GO
EXEC dbo.sp_addextendedproperty @name=N'MS_Description', @value=N'�����������' , @level0type=N'USER',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sms_interface', @level2type=N'COLUMN',@level2name=N'mmsMaxBit'
GO
EXEC dbo.sp_addextendedproperty @name=N'MS_Description', @value=N'���ŵ���' , @level0type=N'USER',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sms_interface', @level2type=N'COLUMN',@level2name=N'mmsPrice'
GO
EXEC dbo.sp_addextendedproperty @name=N'MS_Description', @value=N'�Ƿ�֧�ֲ���' , @level0type=N'USER',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sms_interface', @level2type=N'COLUMN',@level2name=N'Canmms'
GO
EXEC dbo.sp_addextendedproperty @name=N'MS_Description', @value=N'���ʱ��' , @level0type=N'USER',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sms_interface', @level2type=N'COLUMN',@level2name=N'addtime'
GO
EXEC dbo.sp_addextendedproperty @name=N'MS_Description', @value=N'�Ƿ�ɾ��' , @level0type=N'USER',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sms_interface', @level2type=N'COLUMN',@level2name=N'del'
GO
EXEC dbo.sp_addextendedproperty @name=N'MS_Description', @value=N'��������' , @level0type=N'USER',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sms_interface', @level2type=N'COLUMN',@level2name=N'sendCount'
GO
EXEC dbo.sp_addextendedproperty @name=N'MS_Description', @value=N'��ע' , @level0type=N'USER',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sms_interface', @level2type=N'COLUMN',@level2name=N'remark'

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
	delay int NULL,		'�Ƿ���Ҫ��ʱ����
	sendtime datetime NULL	'��ʵ����ʱ�䣨������Ӧ���ύʱ�䣩
	smsLog varchar(2000)	'�ͻ����͵�log
	sendurl ntext		'������ַ
	resultdata ntext	'��������
	xlh  int		'���к�,������ͬ
	smcount			'���żƷ�����



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
		select  max(ord) as o , '����' as stat from smslog
	end
	set nocount off
end



---����������----zbinte_erp
create table smsHttpControl	
(
	[id] [int] IDENTITY(1,1) NOT NULL,
	logmessage int,		---logmessage
	clientxlh bigint	---�ͻ������κ�
	--serverxlh int		---��������κ�,�ϳ���
)




--�������ݷ����ύ��ʱ����� , www.zbintel.com
create table sms_tempsendphones(
	[ord] [int] IDENTITY(1,1) NOT NULL,
	phones varchar(30),
	addcate	int,
	pch		int,
	addtime datetime
) 


CREATE TABLE [dbo].[sms_xlhlist](  --- ��������Ѿ����͵��������к�
	[xlh] [int] NOT NULL,
 CONSTRAINT [PK_sms_xlhlist] PRIMARY KEY CLUSTERED 
(
	[xlh] ASC
) ON [PRIMARY]
) ON [PRIMARY]



--���Żظ����ձ� , www.zbintel.com
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


--���Żظ���Ӧ��ϵ����
ALTER  proc  [dbo].[sms_handlerecInfo] 
as begin
	set nocount on
	select x.ord as ord1 ,x.smsLog ,x.sms, y.ord as  ord2
	into #eee
	from smslog  x inner join smsRecvLogs y 
	on datediff(d,x.sendtime,getdate()) < 15  --ֻ����15���ڻظ� 
		  and ((x.ord-y.extnum)%100 = 0) 
		  and datediff(s,x.sendtime, y.recvtime) > 0
		  and charindex(',' + y.phone + ',', ',' + x.phone + ',') > 0

	update smsRecvLogs set sendlog = x.ord1 , cslog = x.smsLog , sn=x.sms from (
		select smsLog ,sms, ord1 from  #eee where ord1 in (select max(ord1) from  #eee group by ord2,sms,smsLog)
	) x
	set nocount off
end



create proc erp_sms_onRec(
	@oMaxRecLogID int -- @oMaxRecLogID��ʾ�Ѿ�������Ķ��Ž��ռ�¼���id
) as begin
	-- select * from MessageRecv where ord >  @oMaxRecLogID  --��ȡ�µĽ��ռ�¼
	return
end

-----�ͻ��������˽��ջظ���

CREATE TABLE [dbo].[MessageRecv](
	[ord] [int] IDENTITY(1,1) NOT NULL,
	[logmessage] [int] NULL,
	[phone] [varchar](20) COLLATE Chinese_PRC_CI_AS NULL,
	[content] [varchar](2000) COLLATE Chinese_PRC_CI_AS NULL,
	[rectime] [datetime] NULL
) ON [PRIMARY]