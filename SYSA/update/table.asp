--<%response.end%>
--请不要重复添加表，添加之前请检查表是否存在配置中!!!
CREATE TABLE [dbo].[hr_reinstate](
	[id] [int] NOT NULL, 
	[gateName] [varchar](50) NULL,
	[sorce] [int] NULL,
	[sorce2] [int] NULL,
	[sorceName] [varchar](50) NULL,
	[sorce2Name] [varchar](50) NULL,
	[postion] [varchar](50) NULL, 
	[content] [text] NULL,
	[addcate] [int] NULL,
	[creator] [int] NULL,
	[status] [int] NULL,
	[indate] [datetime] NULL,
	[id_sp] [int] NULL,
	[cateid_sp] [int] NULL,
	[TempSave] [bit] NULL,
	[del] [int] NULL,
	[cateid] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[sort5jj](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NULL,
	[sort1] [int] NULL,
	[sort2] [nvarchar](50) NULL,
	[gate2] [int] NULL,
	[num1] [decimal](25, 12) NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[O_kuCheList_his](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[mx_id] [int] NULL,
	[che_fid] [int] NULL,
	[prod_id] [int] NULL,
	[che_zmnum] [decimal](25, 12) NULL,
	[che_sjnum] [decimal](25, 12) NULL,
	[che_yknum] [decimal](25, 12) NULL,
	[che_intro] [text] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]
 TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[sms_tempsendphones](
	[ord] [int] IDENTITY(1,1) NOT NULL,
	[phones] [varchar](30) NULL,
	[addcate] [int] NULL,
	[pch] [int] NULL,
	[addtime] [datetime] NULL,
    PRIMARY KEY CLUSTERED
    (
        [ord] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[sort7](
	[ord] [int] IDENTITY(1,1) NOT NULL,
	[sort1] [nvarchar](500) NULL,
    PRIMARY KEY CLUSTERED
    (
        [ord] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[O_kulog](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[cztime] [datetime] NULL,
	[cateid] [int] NULL DEFAULT (0),
	[djtype] [nvarchar](200) NULL,
	[djtypeid] [int] NULL DEFAULT (0),
	[mxid] [int] NULL DEFAULT (0),
	[prod_name] [nvarchar](500) NULL,
	[prod_bh] [nvarchar](500) NULL,
	[prod_xh] [nvarchar](500) NULL,
	[unit] [nvarchar](500) NULL,
	[unitid] [int] NULL DEFAULT (0),
	[store] [nvarchar](200) NULL,
	[storeid] [int] NULL DEFAULT (0),
	[ph] [nvarchar](500) NULL,
	[xlh] [nvarchar](500) NULL,
	[ystime] [datetime] NULL,
	[sctime] [datetime] NULL,
	[ynum] [decimal](25, 12) NULL DEFAULT (0),
	[bnum] [decimal](25, 12) NULL DEFAULT (0),
	[xnum] [decimal](25, 12) NULL DEFAULT (0),
	[addcateid] [int] NULL,
	[addtime] [datetime] NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[O_SummarySend](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[send_type] [int] NULL,
	[send_cateid] [int] NULL,
	[send_content] [ntext] NULL,
	[send_meetingid] [int] NULL,
	[send_issucceed] [int] NULL DEFAULT (1),
	[ModifyStamp] [varchar](200) NULL DEFAULT (1),
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[sorthttp](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NULL,
	[sort1] [nvarchar](50) NULL,
	[name] [nvarchar](10) NULL,
	[gate1] [int] NULL,
	[cateid] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[M_FcDateList](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[fcdate] [int] NOT NULL,
	[wtype] [smallint] NOT NULL,
	[d1] [datetime] NOT NULL,
	[d2] [datetime] NOT NULL,
	[remark] [nvarchar](200) NULL,
	[del] [int] NOT NULL,
PRIMARY KEY CLUSTERED
(
	[fcdate] ASC,
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

--@##mode:index;clustered:false;fields:d1
--@##mode:index;clustered:false;fields:d2

GO
CREATE TABLE [dbo].[contractthbz](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[intro1] [ntext] NULL,
	[intro2] [ntext] NULL,
	[intro3] [ntext] NULL,
	[intro4] [ntext] NULL,
	[intro5] [ntext] NULL,
	[intro6] [ntext] NULL,
	[contractth] [int] NULL,
	[date7] [datetime] NULL,
	[del] [int] NULL,
	[addcate] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]
 TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[hr_Log](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[creator] [int] NULL,
	[inDate] [datetime] NULL,
	[result] [int] NULL,
	[ip] [nvarchar](50) NULL,
	[del] [int] NULL,
	[isLoad] [int] NULL,
	[address] [nvarchar](500) NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[hr_resume_Work_exp](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Resume] [int] NULL,
	[startDate] [datetime] NULL,
	[endDate] [datetime] NULL,
	[companyName] [nvarchar](50) NULL,
	[typeID] [nvarchar](50) NULL,
	[size] [nvarchar](50) NULL,
	[Industries] [nvarchar](50) NULL,
	[Department] [nvarchar](50) NULL,
	[Position] [nvarchar](50) NULL,
	[jobDes] [nvarchar](4000) NULL,
	[workAbroad] [nvarchar](50) NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[sortimg1](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NULL,
	[sort1] [nvarchar](20) NULL,
	[gate1] [int] NULL,
	[cateid] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[contractthlist](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NULL,
	[price1] [decimal](25, 12) NOT NULL DEFAULT (0),
	[num1] [decimal](25, 12) NOT NULL DEFAULT (0),
	[money1] [decimal](25, 12) NOT NULL DEFAULT (0),
	[num2] [decimal](25, 12) NULL DEFAULT (0),
	[num3] [decimal](25, 12) NULL DEFAULT (0),
	[area] [int] NULL,
	[trade] [int] NULL,
	[date1] [datetime] NULL,
	[date7] [datetime] NULL,
	[company] [int] NULL,
	[contract] [int] NULL,
	[caigou] [int] NULL,
	[cateid] [int] NULL,
	[cateid2] [int] NULL,
	[cateid3] [int] NULL,
	[addcate] [int] NULL,
	[del2] [int] NULL,
	[del] [int] NULL,
	[delcate] [int] NULL,
	[deldate] [datetime] NULL,
	[bz] [int] NOT NULL DEFAULT (14),
	[unit] [int] NULL,
	[intro] [nvarchar](200) NULL,
	[zdy1] [nvarchar](200) NULL,
	[zdy2] [nvarchar](200) NULL,
	[zdy3] [nvarchar](200) NULL,
	[zdy4] [nvarchar](200) NULL,
	[zdy5] [int] NULL,
	[zdy6] [int] NULL,
	[date2] [datetime] NULL,
	[htdate] [datetime] NULL,
	[jf] [decimal](25, 12) NULL,
	[ph] [nvarchar](50) NULL,
	[xlh] [nvarchar](100) NULL,
	[datesc] [datetime] NULL,
	[dateyx] [datetime] NULL,
	[kuoutlist2] [int] NULL,
	[contractlist] [int] NULL,
	[ProductAttr1] int null,
	[ProductAttr2] int null,
	[ProductAttrBatchId] int null,
	[InitPrice] [decimal](25, 12) null,
	[InitMoney] [decimal](25, 12) null,
	[InvoiceType] [int] null,
	[TaxRate] [decimal](25, 12) null,
	[TaxValue] [decimal](25, 12) null,
	[NoNeedInKu] [int] not null default(0),
    [CKAccStatus] [int] NULL,
    [SerialID] [int] Null,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


--@##mode:index;clustered:true;fields:caigou,del,contractlist
--@##mode:index;clustered:false;fields:contractlist,del
--@##mode:index;clustered:false;fields:del;include:id,money1,contract
--@##mode:index;clustered:false;fields:contract,caigou

GO
CREATE TABLE [dbo].[ProductStoreBinding](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ProductID] [int] NOT NULL,
	[Unit] [int] NOT NULL,
	[StoreID] [int] NOT NULL,
	[StoreCapacity] [decimal](25, 12) NOT NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[home_topmenu_item_us](
	[ID] [int] NOT NULL,
	[title] [varchar](50) NULL,
	[sort] [int] NULL,
	[cls] [int] NULL,
	[remark] [varchar](100) NULL,
	[url] [varchar](200) NULL,
	[otype] [int] NULL,
	[sysID] [int] NOT NULL,
	[uid] [int] NOT NULL,
	[stop] [int] NOT NULL DEFAULT (0),
	[ModelExpress] [VARCHAR](100) NOT NULL DEFAULT('')
PRIMARY KEY CLUSTERED
(
	[ID] ASC,
	[uid] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[M_FlowSettings](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[PrefixCode] [nvarchar](2) NOT NULL,
	[spName] [nvarchar](100) NULL,
	[Rank] [int] NOT NULL,
	[LinkType] [int] NOT NULL,
	[orderId] [int] NULL DEFAULT (0),
	[intro] [varchar](4000) NULL,
PRIMARY KEY CLUSTERED
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]

--@##mode:index;clustered:false;fields:Rank
--@##mode:index;clustered:false;fields:orderId

GO
CREATE TABLE [dbo].[sortimg2](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NULL,
	[sort1] [int] NULL,
	[sort2] [nvarchar](20) NULL,
	[gate2] [int] NULL,
	[cateid] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[dianping](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NULL,
	[intro] [nvarchar](500) NULL,
	[name] [nvarchar](50) NULL,
	[sort] [int] NULL,
	[cateid] [int] NULL,
	[date7] [datetime] NULL,
	[alt] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


--@##mode:index;clustered:true;fields:ord,sort,date7 desc

GO
CREATE TABLE [dbo].[hr_KQClass](
	[id] [int] NOT NULL,
	[title] [nvarchar](50) NULL,
	[creator] [int] NULL,
	[orderID] [int] NULL,
	[inDate] [datetime] NULL,
	[remark] [ntext] NULL,
	[isApp] [int] NULL,
	[sortID] [int] NULL,
	[PrefixCode] [nvarchar](50) NULL,
	[isprice] [int] NULL,
	[isAction] [int] NULL,
	[calAction] [int] NULL,
	[UnitType] [int] NULL,
	[moneyNum] [decimal](25, 12) NULL,
	[del] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[M_ListViewConfig](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[UniqueStr] [nvarchar](50) NOT NULL,
	[ColNames] [varchar](4000) NOT NULL,
PRIMARY KEY CLUSTERED
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]

--@##mode:index;clustered:false;fields:ID
--@##mode:index;clustered:false;fields:UniqueStr

GO
CREATE TABLE [dbo].[hr_LoginList](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[creator] [int] NULL,
	[today] [datetime] NULL,
	[loginTime] [datetime] NULL,
	[outTime] [datetime] NULL,
	[workClass] [int] NULL,
	[content] [text] NULL,
	[result] [nvarchar](1000) NULL,
	[del] [int] NULL,
	[kt] [int] NULL,
	[c_loginTime] [datetime] NULL,
	[c_outTime] [datetime] NULL,
	[success] [int] NULL,
	[week] [nvarchar](50) NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]
 TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[O_assChange](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[H_assID] [int] NULL,
	[H_cateid] [int] NULL,
	[H_title] [varchar](200) NULL,
	[H_time] [datetime] NULL,
	[H_type] [int] NULL,
	[H_complete] [int] NULL DEFAULT (1),
	[H_cateid_sp] [int] NULL,
	[H_id_sp] [int] NULL,
	[H_addcateid] [int] NULL,
	[H_addtime] [datetime] NULL,
	[H_del] [int] NULL DEFAULT (1),
	[H_delcateid] [int] NULL,
	[H_deltime] [datetime] NULL,
	[ModifyStamp] [varchar](4000) NULL DEFAULT ('1'),
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[home_toolbar_user](
	[id] [int] NOT NULL,
	[commid] [int] NULL,
	[title] [varchar](50) NOT NULL,
	[url] [varchar](200) NOT NULL,
	[target] [varchar](50) NOT NULL,
	[img] [varchar](50) NOT NULL,
	[qxlb] [int] NOT NULL,
	[qxlblist] [int] NOT NULL,
	[uid] [int] NOT NULL,
	[hide] [int] NOT NULL,
	[sortnum] [int] NOT NULL,
	[tag] [varchar](100) NULL,
	[msgNumUrl] [varchar](200) NULL,
    [models] [bigint] NULL,
    [imgBinData] [text] NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC,
	[uid] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[sortjh2](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NULL,
	[sort1] [nvarchar](50) NULL,
	[may] [real] NULL,
	[gate1] [int] NULL,
	[color] [nvarchar](50) NULL,
	[id1] [int] NULL DEFAULT (0),
	[Flag] [int] NULL DEFAULT (1),
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


--@##mode:index;clustered:true;fields:ord,sort1,gate1,color,id1

GO
CREATE TABLE [dbo].[paysqlist](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[fid] [int] NOT NULL DEFAULT (0),
	[sort1] [int] NOT NULL DEFAULT (0),
	[sp] [int] NOT NULL DEFAULT (0),
	[cateid_sp] [int] NOT NULL DEFAULT (0),
	[company] [int] NOT NULL DEFAULT (0),
	[person] [int] NOT NULL DEFAULT (0),
	[chance] [int] NOT NULL DEFAULT (0),
	[contract] [int] NOT NULL DEFAULT (0),
	[contractth] [int] NOT NULL DEFAULT (0),
	[shouhou] [int] NOT NULL DEFAULT (0),
	[richeng] [int] NOT NULL DEFAULT (0),
	[fahuo] [int] NOT NULL DEFAULT (0),
	[caigou] [int] NOT NULL DEFAULT (0),
	[caigouth] [int] NOT NULL DEFAULT (0),
	[iwork] [int] NOT NULL DEFAULT (0),
	[jkid] [int] NOT NULL DEFAULT (0),
	[bh] [nvarchar](100) NULL,
	[num] [int] NOT NULL DEFAULT (0),
	[money1] [decimal](25, 12) NOT NULL DEFAULT (0),
	[spmoney] [decimal](25, 12) NOT NULL DEFAULT (0),
	[note] [nvarchar](200) NULL,
	[startime] [datetime] NULL,
	[staraddr] [nvarchar](200) NULL,
	[endtime] [datetime] NULL,
	[endaddr] [nvarchar](200) NULL,
	[lc] [nvarchar](20) NULL,
	[bus] [nvarchar](20) NULL,
	[retime] [datetime] NULL,
	[startime1] [datetime] NULL,
	[endtime1] [datetime] NULL,
	[city] [nvarchar](200) NULL,
	[hotel] [nvarchar](100) NULL,
	[ggtime] [datetime] NULL,
	[ggcate] [nvarchar](200) NULL,
	[ggintro] [nvarchar](300) NULL,
	[gglw] [nvarchar](200) NULL,
	[xytime] [datetime] NULL,
	[yt] [nvarchar](200) NULL,
	[addcateid] [int] NOT NULL DEFAULT (0),
	[adddate] [datetime] NULL,
	[delcateid] [int] NOT NULL DEFAULT (0),
	[deldate] [datetime] NULL,
	[del] [int] NOT NULL DEFAULT (0),
	[del2] [int] NOT NULL DEFAULT (0),
	[ManuOrder] [int] NULL,
	[office] [int] NULL DEFAULT (0),
	[repair] [int] NULL DEFAULT (0),
	[insure] [int] NULL DEFAULT (0),
	[book] [int] NULL DEFAULT (0),
	[scdd] [int] NULL DEFAULT (0),
	[zdww] [int] NULL DEFAULT (0),
	[gxww] [int] NULL DEFAULT (0),
	[scsb] [int] NULL DEFAULT (0)
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[temp_paysqlist](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[fid] [int] NOT NULL DEFAULT (0),
	[sort1] [int] NOT NULL DEFAULT (0),
	[sp] [int] NOT NULL DEFAULT (0),
	[cateid_sp] [int] NOT NULL DEFAULT (0),
	[company] [int] NOT NULL DEFAULT (0),
	[person] [int] NOT NULL DEFAULT (0),
	[chance] [int] NOT NULL DEFAULT (0),
	[contract] [int] NOT NULL DEFAULT (0),
	[contractth] [int] NOT NULL DEFAULT (0),
	[shouhou] [int] NOT NULL DEFAULT (0),
	[richeng] [int] NOT NULL DEFAULT (0),
	[fahuo] [int] NOT NULL DEFAULT (0),
	[caigou] [int] NOT NULL DEFAULT (0),
	[caigouth] [int] NOT NULL DEFAULT (0),
	[iwork] [int] NOT NULL DEFAULT (0),
	[jkid] [int] NOT NULL DEFAULT (0),
	[bh] [nvarchar](100) NULL,
	[num] [int] NOT NULL DEFAULT (0),
	[money1] [decimal](25, 12) NOT NULL DEFAULT (0),
	[spmoney] [decimal](25, 12) NOT NULL DEFAULT (0),
	[note] [nvarchar](200) NULL,
	[startime] [datetime] NULL,
	[staraddr] [nvarchar](200) NULL,
	[endtime] [datetime] NULL,
	[endaddr] [nvarchar](200) NULL,
	[lc] [nvarchar](20) NULL,
	[bus] [nvarchar](20) NULL,
	[retime] [datetime] NULL,
	[startime1] [datetime] NULL,
	[endtime1] [datetime] NULL,
	[city] [nvarchar](200) NULL,
	[hotel] [nvarchar](100) NULL,
	[ggtime] [datetime] NULL,
	[ggcate] [nvarchar](200) NULL,
	[ggintro] [nvarchar](300) NULL,
	[gglw] [nvarchar](200) NULL,
	[xytime] [datetime] NULL,
	[yt] [nvarchar](200) NULL,
	[addcateid] [int] NOT NULL DEFAULT (0),
	[adddate] [datetime] NULL,
	[delcateid] [int] NOT NULL DEFAULT (0),
	[deldate] [datetime] NULL,
	[del] [int] NOT NULL DEFAULT (0),
	[del2] [int] NOT NULL DEFAULT (0),
	[ManuOrder] [int] NULL,
	[office] [int] NULL DEFAULT (0),
	[repair] [int] NULL DEFAULT (0),
	[insure] [int] NULL DEFAULT (0),
	[book] [int] NULL DEFAULT (0),
	[datatype] [varchar](50) NULL,
	[checked] [int] NOT NULL DEFAULT (1),
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[email](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NULL,
	[name] [nvarchar](30) NULL,
	[email] [nvarchar](50) NULL,
	[company] [int] NULL,
	[person] [int] NULL,
	[complete] [int] NULL,
	[cateid] [int] NULL,
	[cateid2] [int] NULL,
	[date1] [smalldatetime] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[UserStoreBinding](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ProductID] [int] NOT NULL,
	[Unit] [int] NOT NULL,
	[StoreID] [int] NOT NULL,
	[UserID] [int] NOT NULL,
	[Sort] [int] NOT NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[M_MRPReport](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[MRPID] [int] NOT NULL,
	[NumNow] [decimal](25, 12) NULL,
	[NumAssign] [decimal](25, 12) NULL,
PRIMARY KEY CLUSTERED
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]

--@##mode:index;clustered:false;fields:MRPID

GO
CREATE TABLE [dbo].[sortone](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NULL,
	[sort1] [nvarchar](50) NULL,
	[name] [nvarchar](10) NULL,
	[gate1] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[files](
	[Id] [int] NOT NULL,
	[UserName] [nvarchar](20) NULL,
	[FileTitle] [nvarchar](80) NULL,
	[FileUrl] [nvarchar](50) NULL,
	[FileUpTime] [smalldatetime] NULL,
	[FileAbout] [ntext] NULL,
	[FileDowns] [int] NULL,
	[FileSize] [int] NULL,
	[GroupID] [nvarchar](250) NULL,
	[ToUserName] [ntext] NULL,
	[DelUserName] [ntext] NULL,
	[IP] [nvarchar](20) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[M_MRPReportList](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ReportType] [nvarchar](50) NULL,
	[ReportID] [int] NOT NULL,
	[Num1] [decimal](25, 12) NULL,
	[sort] [int] NOT NULL,
PRIMARY KEY CLUSTERED
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]

--@##mode:index;clustered:false;fields:ReportID
--@##mode:index;clustered:false;fields:sort

GO
CREATE TABLE [dbo].[hr_PersonClass](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[title] [nvarchar](50) NULL,
	[PrefixCode] [nvarchar](50) NULL,
	[user_list] [nvarchar](4000) NULL,
	[dayWorkTime] [nvarchar](2000) NULL,
	[creator] [int] NULL,
	[isall] [int] NULL,
	[EditTime] [datetime] NULL,
	[content] [ntext] NULL,
	[startTime] [datetime] NULL,
	[endTime] [datetime] NULL,
	[weekList] [nvarchar](200) NULL,
	[needHoliday] [int] NULL,
	[needWorkClass] [int] NULL,
	[inDate] [datetime] NULL,
	[del] [int] NULL,
	[testNum] [int] NULL,
	[ComType] [int] NULL,
	[zhouqi] [nvarchar](1000) NULL,
	[workDayList] [text] NULL,
	[bancihtml] [text] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]
 TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[hr_resume_edu](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Resume] [int] NULL,
	[startDate] [datetime] NULL,
	[endDate] [datetime] NULL,
	[school] [nvarchar](50) NULL,
	[Professional] [nvarchar](50) NULL,
	[Education] [nvarchar](50) NULL,
	[ProsCon] [nvarchar](500) NULL,
	[StudyAbroad] [nvarchar](50) NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[sortonehy](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NULL,
	[sort1] [nvarchar](100) NULL,
	[gate1] [int] NULL,
	[gate2] [int] NULL,
	[id1] [int] NULL,
	[deepth] [int] NULL,
	[del] [int] NULL DEFAULT (1),
    [NowMoney] [decimal](25, 12),
	[isStop] [int] NULL DEFAULT (0),
	[color] [nvarchar](50) NULL,
	[tagData] [nvarchar](500) NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


--@##mode:index;clustered:false;fields:Gate2,Gate1

GO
CREATE TABLE [dbo].[M_MaterialProgresRawLists](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[MPRID] [int] NOT NULL,
	[MPDID] [int] NOT NULL,
	[BomList] [int] NOT NULL,
	[num1] [decimal](25, 12) NULL,
	[kuoutlist2] [int] NOT NULL,
	[del] [int] NOT NULL,
	[fromChild] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[MPDID] ASC,
	[BomList] ASC,
	[kuoutlist2] ASC
) ON [PRIMARY]
) ON [PRIMARY]

--@##mode:index;clustered:false;fields:ID
--@##mode:index;clustered:false;fields:MPRID

GO
CREATE TABLE [dbo].[fuwu](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NULL,
	[title] [nvarchar](50) NULL,
	[member1] [int] NULL,
	[sort1] [int] NULL,
	[way1] [int] NULL,
	[date1] [datetime] NULL,
	[time1] [nvarchar](50) NULL,
	[time2] [nvarchar](50) NULL,
	[product] [real] NULL,
	[introts] [ntext] NULL,
	[great1] [int] NULL,
	[introyj] [ntext] NULL,
	[result1] [int] NULL,
	[time3] [nvarchar](50) NULL,
	[introhf] [ntext] NULL,
	[introyy] [ntext] NULL,
	[introdc] [ntext] NULL,
	[intro] [ntext] NULL,
	[share] [nvarchar](500) NULL,
	[cateid] [int] NULL,
	[cateid2] [int] NULL,
	[cateid3] [int] NULL,
	[company] [nvarchar](50) NULL,
	[person] [nvarchar](50) NULL,
	[chance] [nvarchar](50) NULL,
	[date7] [datetime] NULL,
	[del] [int] NULL,
	[delcate] [int] NULL,
	[deldate] [datetime] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]
 TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[hr_schedu_set](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[scheduID] [int] NULL,
	[testNum] [int] NULL,
	[workDayList] [text] NULL,
	[banHtml] [text] NULL,
	[personClass] [int] NULL,
	[creator] [int] NULL,
	[inDate] [datetime] NULL,
	[del] [int] NULL,
	[numTal] [int] NULL,
	[numTest] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[M_ManuOrderIssuedLists](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[MOIID] [int] NOT NULL,
	[MOrderListID] [int] NOT NULL,
	[ProductID] [int] NOT NULL,
	[BOMListID] [int] NULL,
	[unit] [nvarchar](100) NOT NULL,
	[DateAdvance] [int] NOT NULL,
	[DateBegin] [datetime] NOT NULL,
	[DateEnd] [datetime] NOT NULL,
	[DateDelivery] [datetime] NOT NULL,
	[NumPlan] [decimal](25, 12) NULL,
	[NumDecide] [decimal](25, 12) NULL,
	[Costs] [decimal](25, 12) NOT NULL,
	[del] [int] NOT NULL,
	[WFlowsID] [int] NOT NULL DEFAULT (0),
PRIMARY KEY CLUSTERED
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]

--@##mode:index;clustered:false;fields:MOIID
--@##mode:index;clustered:false;fields:MOrderListID
--@##mode:index;clustered:false;fields:ProductID
--@##mode:index;clustered:false;fields:BOMListID
--@##mode:index;clustered:false;fields:DateBegin
--@##mode:index;clustered:false;fields:DateEnd
--@##mode:index;clustered:false;fields:DateDelivery
--@##mode:index;clustered:false;fields:WFlowsID

GO
CREATE TABLE [dbo].[sortqb1](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NULL,
	[sort1] [nvarchar](4000) NULL,
	[gate1] [int] NULL,
	[cateid] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[M_MaterialMoveLists](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[MMID] [int] NOT NULL,
	[productID] [int] NOT NULL,
	[numable] [decimal](25, 12) NOT NULL DEFAULT (0),
	[num] [decimal](25, 12) NOT NULL,
	[unit] [int] NOT NULL,
	[remark] [nchar](10) NULL,
	[kuoutlist2] [int] NOT NULL DEFAULT (0),
PRIMARY KEY CLUSTERED
(
	[ID] ASC,
	[MMID] ASC
) ON [PRIMARY]
) ON [PRIMARY]

--@##mode:index;clustered:false;fields:productID
--@##mode:index;clustered:false;fields:unit
--@##mode:index;clustered:false;fields:kuoutlist2

GO
CREATE TABLE [dbo].[gate](
	[ord] [int] IDENTITY(1,1) NOT NULL,
	[username] [nvarchar](50) NULL,
	[pw] [nvarchar](50) NULL,
	[name] [nvarchar](50) NULL,
	[title] [nvarchar](50) NULL,
	[cateid] [int] NULL,
	[sorce] [int] NULL,
	[sorce2] [int] NULL,
	[see1] [nvarchar](4) NULL,
	[cor] [nvarchar](4) NULL,
	[del1] [nvarchar](4) NULL,
	[share] [nvarchar](4) NULL,
	[order1] [nvarchar](4) NULL,
	[agree1] [nvarchar](4) NULL,
	[top1] [nvarchar](4) NULL,
	[con1] [nvarchar](4) NULL,
	[hk1] [nvarchar](4) NULL,
	[pro1] [nvarchar](4) NULL,
	[sh1] [nvarchar](4) NULL,
	[cg1] [nvarchar](4) NULL,
	[rk1] [nvarchar](4) NULL,
	[ck1] [nvarchar](4) NULL,
	[fh1] [nvarchar](4) NULL,
	[dy1] [nvarchar](4) NULL,
	[dc1] [nvarchar](4) NULL,
	[del] [int] NULL DEFAULT (1),
	[numy] [decimal](25, 12) NULL,
	[numm] [decimal](25, 12) NULL,
	[ygid] [nvarchar](50) NULL,
	[cardid] [nvarchar](50) NULL,
	[sex] [nvarchar](10) NULL,
	[jg] [nvarchar](50) NULL,
	[mz] [nvarchar](50) NULL,
	[date1] [datetime] NULL,
	[date2] [datetime] NULL,
	[date3] [datetime] NULL,
	[xl] [nvarchar](10) NULL,
	[zy] [nvarchar](50) NULL,
	[xx] [nvarchar](50) NULL,
	[phone1] [nvarchar](50) NULL,
	[phone2] [nvarchar](50) NULL,
	[mobile] [nvarchar](50) NULL,
	[tc] [nvarchar](100) NULL,
	[ah] [nvarchar](100) NULL,
	[intro] [ntext] NULL,
	[alt] [int] NULL DEFAULT (0),
	[datealt] [datetime] NULL,
	[date7] [datetime] NULL,
	[fax] [nvarchar](50) NULL,
	[email] [nvarchar](50) NULL,
	[address] [nvarchar](500) NULL,
	[num1] [int] NULL,
	[mac] [nvarchar](50) NULL DEFAULT (1),
	[jjgz] [int] NULL DEFAULT (1),
	[time_login] [datetime] NULL,
	[on_line] [int] NULL DEFAULT (0),
	[num_1] [int] NULL,
	[num_2] [int] NULL,
	[num_3] [int] NULL,
	[num_4] [int] NULL,
	[num_5] [int] NULL,
	[num_6] [int] NULL,
	[num_7] [int] NULL,
	[addcate] [int] NULL,
	[tj1] [int] NULL,
	[tj2] [int] NULL,
	[tj3] [int] NULL,
	[tj4] [int] NULL,
	[num_ly] [int] NULL,
	[Serial] [nvarchar](50) NULL,
	[qbtc] [int] NULL DEFAULT (0),
	[Channel] [int] NULL,
	[num_code] [nvarchar](50) NULL,
	[num2] [int] NULL,
	[num3] [int] NULL,
	[callModel] [int] NULL,
	[callPreNum] [nvarchar](50) NULL,
	[job] [int] NULL,
	[num_week] [int] NULL DEFAULT (0),
	[num_month] [int] NULL DEFAULT (0),
	[num_year] [int] NULL DEFAULT (0),
	[num1_xm] [int] NULL,
	[num2_xm] [int] NULL,
	[num3_xm] [int] NULL,
	[mobile_kq] [int] NULL DEFAULT (0),	
	[jmgou] [int] NULL,	
	[salaryClass] [int] NULL,
	[num_gj_1] [int] NULL DEFAULT(24),
	[num_gj_2] [int] NULL DEFAULT(24), 
	[GPS_Open] [int] NULL DEFAULT(0),
	[workPosition] [int] NULL,
	[isMobileLoginOn] [int] NULL,
	[orgsid] [int] NULL,
	[partadmin] [int] Not NULL DEFAULT (0),
	[pricesorce] [int] Not NULL DEFAULT (0),
	[import] [int] NULL,
    [MobVisitToken] varchar(100) NULL,
	[sessionData] ntext NULL,
	[weixin]  [nvarchar](50) NULL,
	[photourl]  [varchar](100) NULL,
    [zxbflag] int NULL
PRIMARY KEY CLUSTERED
(
	[ord] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

--@##mode:index;clustered:false;fields:del,ord,name
--@##mode:index;clustered:false;fields:sorce DESC,cateid,ord,del,sorce2,name
--@##mode:index;clustered:false;fields:sorce,cateid,sorce2,del,ord,name
--@##mode:index;clustered:false;fields:sorce2 DESC,ord,cateid,del,sorce,name
--@##mode:index;clustered:false;fields:del,ord,cateid,sorce,name,top1,addcate
--@##mode:index;clustered:false;fields:del,cateid,ord,sorce2, name,top1,addcate
--@##mode:statistics;fields:sorce2,cateid
--@##mode:statistics;fields:cateid,jjgz
--@##mode:statistics;fields:del,sorce
--@##mode:statistics;fields:ord,sorce2
--@##mode:statistics;fields:del,top1
--@##mode:statistics;fields:del,username
--@##mode:statistics;fields:name,ord
--@##mode:statistics;fields:cateid,ord
--@##mode:statistics;fields:del,sorce2,cateid
--@##mode:statistics;fields:ord,del,cateid
--@##mode:statistics;fields:jjgz,ord,cateid
--@##mode:statistics;fields:ord,del,top1
--@##mode:statistics;fields:sorce,sorce2,cateid
--@##mode:statistics;fields:ord,cateid,sorce
--@##mode:statistics;fields:del,cateid,sorce
--@##mode:statistics;fields:ord,del,sorce2
--@##mode:statistics;fields:del,ord,sorce2,cateid
--@##mode:statistics;fields:ord,sorce,sorce2,cateid
--@##mode:statistics;fields:ord,del,sorce,cateid
--@##mode:statistics;fields:ord,del,sorce,sorce2
--@##mode:statistics;fields:del,ord,hk1,cateid

GO

CREATE TABLE [dbo].[M_ManuOrderIssueds](
	[ID] [int] NOT NULL,
	[PrefixCode] [nvarchar](2) NULL,
	[title] [nvarchar](100) NULL,
	[intro] [nvarchar](1000) NULL,
	[MOID] [int] NOT NULL,
	[MOIBH] [nvarchar](50) NULL,
	[Creator] [int] NOT NULL,
	[indate] [datetime] NULL,
	[del] [int] NULL,
	[TempSave] [int] NULL,
	[Cateid_MOI] [int] NULL,
	[fromchild] [int] null
PRIMARY KEY CLUSTERED
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]

--@##mode:index;clustered:false;fields:MOID
--@##mode:index;clustered:false;fields:Creator
--@##mode:index;clustered:false;fields:indate desc
--@##mode:index;clustered:false;fields:Cateid_MOI

GO
CREATE TABLE [dbo].[hr_PersonTax](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[creator] [int] NULL,
	[inDate] [datetime] NULL,
	[lv] [int] NULL,
    [IsEnabled] [int] NULL,
	[limit] [decimal](25, 12) NULL,
	[lower] [decimal](25, 12) NULL,
	[taxRate] [int] NULL,
	[cut] [decimal](25, 12) NULL,
	[del] [int] NULL,
	[editTime] [datetime] NULL,
	[sortid] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[smsRecvLog](
	[Ord] [int] IDENTITY(1,1) NOT NULL,
	[sortID] [int] NULL,
	[bllId] [int] NULL,
	[Phone] [varchar](500) NULL,
	[StrReturn] [varchar](500) NULL,
	[intro] [text] NULL,
	[SpReturn] [text] NULL,
	[AddTime] [datetime] NULL,
	[Del] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[Ord] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[sortts5](
	[id] [int] NOT NULL,
	[ord] [int] NULL,
	[sort1] [nvarchar](20) NULL,
	[gate1] [int] NULL
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[M_ManuOrderLists](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[MOrderID] [int] NOT NULL,
	[PrefixCode] [nvarchar](2) NOT NULL,
	[BOMListID] [int] NULL,
	[ProductID] [int] NOT NULL,
	[unit] [nvarchar](100) NOT NULL,
	[NumPlan] [decimal](25, 12) NULL,
	[NumDecide] [decimal](25, 12) NULL,
	[DateBegin] [datetime] NULL,
	[DateEnd] [datetime] NULL,
	[Costs] [decimal](25, 12) NOT NULL,
	[del] [int] NOT NULL,
	[remark] [ntext] NULL,
	[fsProduct] [int] NULL DEFAULT (0),
	[planlistID] [int] NULL DEFAULT (0),
	[lvw_treenodedeep] [int] NULL,
	[ordfield] [varchar](2000) NULL,
	[currkcnum] [decimal](25, 12) NULL,
	[safeNum] [decimal](25, 12) NULL,
	[cklist] [int] NULL,
	[role] [int] NOT NULL DEFAULT (0),
	[WProc] [int] NOT NULL DEFAULT (0),
	[disRefku] [int] NOT NULL DEFAULT (0),
	[ckdelnum] [decimal](25, 12) NOT NULL DEFAULT (0),
	[ckkallnum] [decimal](25, 12) NOT NULL DEFAULT (0),
	[relscknum] [decimal](25, 12) NOT NULL DEFAULT (0),
	[realneed] [decimal](25, 12) NOT NULL DEFAULT (0),
	[xhl] [decimal](25, 12) NULL DEFAULT (0),
	[shl] [decimal](25, 12) NOT NULL DEFAULT (0),
    [ContractList] [int] NULL,
	[StoreMethod] [int] NOT NULL DEFAULT (0),
	[cankcgnum] [decimal](25, 12) NOT NULL DEFAULT (0),
	[cankrknum] [decimal](25, 12) NOT NULL DEFAULT (0),
	[cankhtnum] [decimal](25, 12) NOT NULL DEFAULT (0),
	[cankcknum] [decimal](25, 12) NOT NULL DEFAULT (0),
	[zdy1] [nvarchar](200) NULL,
	[zdy2] [nvarchar](200) NULL,
	[zdy3] [nvarchar](200) NULL,
	[zdy4] [nvarchar](200) NULL,
	[zdy5] [int] NULL,
	[zdy6] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]

--@##mode:index;clustered:false;fields:MOrderID
--@##mode:index;clustered:false;fields:BOMListID
--@##mode:index;clustered:false;fields:ProductID
--@##mode:index;clustered:false;fields:DateBegin
--@##mode:index;clustered:false;fields:DateEnd
--@##mode:index;clustered:false;fields:fsProduct
--@##mode:index;clustered:false;fields:planlistID
--@##mode:index;clustered:false;fields:lvw_treenodedeep
--@##mode:index;clustered:false;fields:cklist
--@##mode:index;clustered:false;fields:WProc
--@##mode:index;clustered:false;fields:disRefku
--@##mode:index;clustered:false;fields:ContractList
--@##mode:index;clustered:false;fields:StoreMethod
--@##mode:index;clustered:false;fields:role

GO
CREATE TABLE [dbo].[O_assRepair](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[R_assID] [int] NULL,
	[R_type] [int] NULL,
	[R_time] [datetime] NULL,
	[R_content] [varchar](4000) NULL,
	[R_cateid] [int] NULL,
	[R_complete] [int] NULL DEFAULT (1),
	[R_cateid_sp] [int] NULL,
	[R_id_sp] [int] NULL,
	[R_sms] [int] NULL,
	[R_alt] [datetime] NULL,
	[R_alt1] [int] NULL DEFAULT (1),
	[R_state] [int] NULL,
	[R_result] [varchar](4000) NULL,
	[R_money] [decimal](25, 12) NULL,
	[R_addcateid] [int] NULL,
	[R_addtime] [datetime] NULL,
	[R_del] [int] NULL DEFAULT (1),
	[R_delcateid] [int] NULL,
	[R_deltime] [datetime] NULL,
	[ModifyStamp] [varchar](4000) NULL DEFAULT ('1'),
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[sortwages](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[sort1] [nvarchar](50) NULL,
	[intro] [int] NULL,

    [deductible] [int] NULL,
	[gate1] [int] NULL,
	[salaryClass] [nvarchar](1000) NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[M_ManuOrders](
	[ID] [int] NOT NULL,
	[PrefixCode] [nvarchar](2) NULL,
	[MPSID] [int] NOT NULL,
	[MOBH] [nvarchar](50) NULL,
	[title] [nvarchar](100) NULL,
	[Creator] [int] NOT NULL,
	[indate] [datetime] NULL,
	[DateBegin] [datetime] NOT NULL,
	[DateEnd] [datetime] NOT NULL,
	[DateDelivery] [datetime] NOT NULL,
	[DateAdvance] [int] NOT NULL,
	[PRI] [int] NULL,
	[id_sp] [int] NULL,
	[cateid_sp] [int] NULL,
	[status] [int] NOT NULL,
	[TempSave] [bit] NOT NULL,
	[del] [int] NULL,
	[Complete] [int] NOT NULL DEFAULT (0),
	[SingleCosts] [decimal](25, 12) NULL,
	[TotalCosts] [decimal](25, 12) NULL,
	[CostAccounting] [int] NULL,
	[dbCosts] [decimal](25, 12) NULL,
	[intro] [ntext] NULL,
PRIMARY KEY CLUSTERED
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]

--@##mode:index;clustered:false;fields:MPSID
--@##mode:index;clustered:false;fields:Creator
--@##mode:index;clustered:false;fields:indate desc
--@##mode:index;clustered:false;fields:DateBegin
--@##mode:index;clustered:false;fields:DateEnd
--@##mode:index;clustered:false;fields:DateDelivery
--@##mode:index;clustered:false;fields:DateAdvance
--@##mode:index;clustered:false;fields:PRI
--@##mode:index;clustered:false;fields:id_sp
--@##mode:index;clustered:false;fields:Complete
--@##mode:index;clustered:false;fields:CostAccounting
--@##mode:index;clustered:false;fields:del
--@##mode:index;clustered:false;fields:status

GO
CREATE TABLE [dbo].[hr_PersonTaxSort](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[title] [nvarchar](200) NULL,
	[startTime] [datetime] NULL,
	[endTime] [datetime] NULL,
	[inDate] [datetime] NULL,
	[creator] [int] NULL,
    [IsEnabled] [int] NULL,
	[editTime] [datetime] NULL,
	[editCate] [int] NULL,
	[del] [int] NULL,
	[taxbase] [decimal](25, 12) NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[hr_resume_item](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[title] [varchar](50) NULL,
	[del] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[sortxm1](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NULL,
	[sort1] [nvarchar](20) NULL,
	[gate1] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[home_runtmpMenuList](
	[ID] [int] NOT NULL,
	[ParentID] [int] NULL,
	[title] [varchar](1500) NULL,
	[url] [varchar](2000) NULL,
	[imgurl] [varchar](200) NULL,
	[openType] [varchar](100) NULL,
	[kz] [varchar](200) NULL,
	[leef] [int] NULL,
	[uid] [int] NOT NULL,
	[ItemSort] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[ID] ASC,
	[uid] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[groups](
	[GroupID] [int] NULL,
	[GroupName] [nvarchar](50) NULL,
	[UpFileType] [nvarchar](200) NULL,
	[UpFilesize] [int] NULL
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[sortxm_celue](
	[setid] [int] NOT NULL,
	[setopen] [int] NOT NULL,
	[setintro] [ntext] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[M_ManuPlanLists](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[MPSID] [int] NOT NULL,
	[ProductID] [int] NOT NULL,
	[unit] [int] NOT NULL,
	[BOMID] [int] NOT NULL,
	[MPSType] [bit] NOT NULL,
	[DateBegin] [datetime] NOT NULL,
	[DateEnd] [datetime] NOT NULL,
	[DateDelivery] [datetime] NOT NULL,
	[DateAdvance] [int] NOT NULL,
	[NumPlan] [decimal](25, 12) NULL,
	[NumDecide] [decimal](25, 12) NULL,
	[Costs] [decimal](25, 12) NOT NULL,
	[del] [int] NOT NULL,
	[intro] [ntext] NULL,
    [contractlist][int] NULL,
	[chancelist] INT NULL,
	[zdy1] [nvarchar](200) NULL,
	[zdy2] [nvarchar](200) NULL,
	[zdy3] [nvarchar](200) NULL,
	[zdy4] [nvarchar](200) NULL,
	[zdy5] [int] NULL,
	[zdy6] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]

--@##mode:index;clustered:false;fields:MPSID
--@##mode:index;clustered:false;fields:ProductID
--@##mode:index;clustered:false;fields:unit
--@##mode:index;clustered:false;fields:BOMID
--@##mode:index;clustered:false;fields:MPSType
--@##mode:index;clustered:false;fields:DateBegin
--@##mode:index;clustered:false;fields:DateEnd
--@##mode:index;clustered:false;fields:DateDelivery
--@##mode:index;clustered:false;fields:DateAdvance
--@##mode:index;clustered:false;fields:contractlist
--@##mode:index;clustered:false;fields:chancelist

GO
CREATE TABLE [dbo].[sortxm2](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NULL,
	[sort1] [nvarchar](20) NULL,
	[gate1] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[help](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[id1] [int] NULL,
	[menuname] [nvarchar](50) NULL,
	[menuname2] [nvarchar](50) NULL,
	[intro] [ntext] NULL,
	[ip1] [nvarchar](50) NULL,
	[gate1] [int] NULL,
	[sort1] [nvarchar](50) NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]
 TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[M_ManuPlans](
	[ID] [int] NOT NULL,
	[PrefixCode] [nvarchar](2) NOT NULL,
	[title] [nvarchar](100) NOT NULL,
	[MPSBH] [nvarchar](50) NOT NULL,
	[Creator] [int] NOT NULL,
	[inDate] [datetime] NOT NULL,
	[id_sp] [int] NOT NULL,
	[cateid_sp] [int] NOT NULL,
	[status] [int] NOT NULL,
	[CreateFrom] [int] NOT NULL,
	[FromID] [int] NOT NULL,
	[del] [int] NOT NULL,
	[TempSave] [int] NOT NULL DEFAULT (0),
	[fromChild] int NULL,
PRIMARY KEY CLUSTERED
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]

--@##mode:index;clustered:false;fields:Creator
--@##mode:index;clustered:false;fields:inDate desc
--@##mode:index;clustered:false;fields:CreateFrom
--@##mode:index;clustered:false;fields:FromID

GO
CREATE TABLE [dbo].[hr_SalaryClass](
	[id] [int] NOT NULL,
	[title] [nvarchar](100) NULL,
	[del] [int] NULL,
	[indate] [datetime] NULL,
	[creator] [int] NULL,
	[flag] [nvarchar](1000) NULL
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[smsRecvList](
	[Ord] [int] IDENTITY(1,1) NOT NULL,
	[Content] [text] NULL,
	[AddTime] [datetime] NULL,
	[Del] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[Ord] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[sp](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NULL,
	[sort1] [nvarchar](50) NULL,
	[gate1] [int] NULL,
	[gate2] [int] NULL,
	[gate3] [int] NULL,
	[intro] [nvarchar](2000) NULL,
	[money1] [decimal](25, 12) NULL,
	[money2] [decimal](25, 12) NULL,
	[bt] [int] NOT NULL DEFAULT (0),
	[sptype] [int] NULL,
	[ApprovalRulesId] [int] NULL,
	[ApprovalType] [int] NULL,
	[PassLimit] [int] NULL,
	[CreateTime] [datetime] NULL,
	[UserID] [int] NULL,
    [oldid] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


--@##mode:index;clustered:true;fields:gate2,gate1

GO
CREATE TABLE [dbo].[M_MaterialProgresRaws](
	[ID] [int] NOT NULL,
	[PrefixCode] [nvarchar](2) NULL,
	[title] [nvarchar](300) NOT NULL,
	[MPRBH] [nvarchar](50) NOT NULL,
	[Creator] [int] NOT NULL,
	[inDate] [datetime] NOT NULL,
	[del] [int] NOT NULL,
	[id_sp] [int] NULL,
	[Cateid_sp] [int] NULL,
	[status] [int] NULL,
	[TempSave] [int] NOT NULL,
	[intro] [ntext] NULL,
PRIMARY KEY CLUSTERED
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]

--@##mode:index;clustered:false;fields:Creator
--@##mode:index;clustered:false;fields:inDate desc

GO
CREATE TABLE [dbo].[help2](
	[id] [int] NOT NULL,
	[id1] [int] NULL,
	[menuname] [nvarchar](50) NULL,
	[intro] [ntext] NULL,
	[ip1] [nvarchar](50) NULL,
	[gate1] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[M_MaterialOrderLists](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[MOID] [int] NOT NULL,
	[WAListID] [int] NOT NULL,
	[ProductID] [int] NOT NULL,
	[unit] [int] NOT NULL,
	[num1] [decimal](25, 12) NULL,
	[del] [int] NOT NULL,
	[kuoutlist2] [int] NULL,
	[numable] [decimal](25, 12) NULL,
	[poType] [int] NOT NULL DEFAULT (0),
	[remark] [nvarchar](200) NULL,
	[kunum] [decimal](25, 12) NULL,
PRIMARY KEY CLUSTERED
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]

--@##mode:index;clustered:false;fields:MOID
--@##mode:index;clustered:false;fields:WAListID
--@##mode:index;clustered:false;fields:ProductID
--@##mode:index;clustered:false;fields:unit
--@##mode:index;clustered:false;fields:kuoutlist2
--@##mode:index;clustered:false;fields:poType

GO
CREATE TABLE [dbo].[sp_intro](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[jg] [int] NULL,
	[intro] [nvarchar](500) NULL,
	[date1] [datetime] NULL,
	[ord] [int] NULL,
	[sp] [nvarchar](50) NULL,
	[cateid] [int] NULL,
	[sort1] [int] NULL,
	[money1] [decimal](25, 12) NOT NULL DEFAULT (0),
	[sp_id] [int] NULL,
    [InstanceID] [int] NULL,
	[ApprovalProcessId] [int] NULL,
	[ApproverName] [nvarchar](200) NULL,
	[ApproverDept] [nvarchar](200) NULL,
	[ApprovalResult] [bit] NULL,
	[IsAutoPass] [bit] NULL,
	[ApprovalType] [nvarchar](50) NULL,
	[currNodeApprover] [varchar](max) NULL, 
	[gate3] [int] NULL,
	[Operator] [nvarchar](200) NULL,
	[OperationType] [nvarchar](500) NULL,
	[CreateTime] [datetime] NULL,
	[OperationTime] [datetime] NULL,
    [ApprovalLevel] [int] NULL,
    [NextSpID] [int] NULL DEFAULT (0),
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


--@##mode:index;clustered:true;fields:ord,sort1,date1
--@##mode:index;clustered:false;fields:sort1,InstanceID
--@##mode:index;clustered:false;fields:id;include:date1,cateid

GO

CREATE TABLE [dbo].[his_ku](
	[BatchNum] [int] NOT NULL,
	[id] [int] NOT NULL,
	[ord] [int] NULL,
	[num1] [decimal](25, 12) NULL,
	[ck] [int] NULL,
	[price1] [decimal](25, 12) NULL,
	[money1] [decimal](25, 12) NULL,
	[unit] [int] NULL,
	[ph] [nvarchar](50) NULL,
	[xlh] [nvarchar](100) NULL,
	[datesc] [datetime] NULL,
	[dateyx] [datetime] NULL,
	[bz] [int] NULL,
	[js] [decimal](25, 12) NULL,
	[intro] [nvarchar](100) NULL,
	[caigoulist] [int] NULL,
	[gys] [int] NULL,
	[kuinlist] [int] NULL,
	[num2] [decimal](25, 12) NULL,
	[daterk] [datetime] NULL,
	[Status] [int] NULL,
	[num3] [decimal](25, 12) NULL
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[M_MaterialOrders](
	[ID] [int] NOT NULL,
	[PrefixCode] [nvarchar](2) NOT NULL,
	[WAID] [int] NOT NULL,
	[title] [nvarchar](100) NULL,
	[MOBH] [nvarchar](50) NOT NULL,
	[Creator] [int] NOT NULL,
	[indate] [datetime] NOT NULL,
	[cateid_sp] [int] NOT NULL,
	[id_sp] [int] NULL,
	[status] [int] NOT NULL,
	[OrderType] [int] NOT NULL,
	[del] [int] NOT NULL,
	[tempsave] [int] NOT NULL DEFAULT (0),
	[ddno] [int] NOT NULL DEFAULT (0),
	[poType] [int] NOT NULL DEFAULT (0),
	[intro] [ntext] NULL,
PRIMARY KEY CLUSTERED
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]

--@##mode:index;clustered:false;fields:WAID
--@##mode:index;clustered:false;fields:Creator
--@##mode:index;clustered:false;fields:indate desc
--@##mode:index;clustered:false;fields:ddno

GO
CREATE TABLE [dbo].[hr_Welfare](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[creator] [int] NULL,
	[inDate] [datetime] NULL,
	[datetime] [datetime] NULL,
	[base] [varchar](50) NULL,
	[Limit] [money] NULL,
	[Lower] [money] NULL,
	[Propm_com] [int] NULL,
	[Propm_person] [float] NULL,
	[Propm_personJia] [float] NULL,
	[Refer] [money] NULL,
	[user_list] [text] NULL,
	[isall] [int] NULL,
	[classid] [int] NULL,
	[del] [int] NULL,
	[editTime] [datetime] NULL,
	[endTime] [datetime] NULL,
	[startTime] [datetime] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]
 TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[hr_resume_reg](
	[id] [int] NOT NULL,
	[sortID] [int] NULL,
	[itemID] [int] NULL,
	[isReg] [int] NULL,
	[regStr] [varchar](500) NULL,
	[regStr2] [varchar](500) NULL,
	[regSplit] [bit] NULL,
	[splitNum] [int] NULL,
	[isMark] [bit] NULL,
	[isMarkList] [int] NULL,
	[startStr] [varchar](500) NULL,
	[endStr] [varchar](500) NULL,
	[startStr1] [varchar](500) NULL,
	[endStr1] [varchar](500) NULL,
	[isReplace] [int] NULL,
	[replaceStr] [varchar](500) NULL,
	[replaceStr2] [varchar](500) NULL,
	[replaceStr3] [varchar](500) NULL,
	[replaceHmtl] [bit] NULL,
	[creator] [int] NULL,
	[id_sp] [int] NULL,
	[cateid_sp] [int] NULL,
	[status] [int] NULL,
	[indate] [datetime] NULL,
	[del] [int] NULL,
	[TempSave] [bit] NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[tcbl](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NULL,
	[money1] [decimal](25, 12) NULL,
	[money2] [decimal](25, 12) NULL,
	[tc_formula1] [nvarchar](200) NULL,
	[tc_formula2] [nvarchar](200) NULL,
	[num1] [decimal](25, 12) NULL,
	[gate1] [int] NULL,
	[sort1] [int] NULL	,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[his_kuin](
	[BatchNum] [int] NULL,
	[ord] [int] NOT NULL,
	[title] [nvarchar](100) NULL,
    [rkbh] [nvarchar](100) NULL,
	[ck] [int] NULL,
	[complete1] [int] NULL,
	[date3] [datetime] NULL,
	[date5] [datetime] NULL,
	[catein] [int] NULL,
	[intro] [nvarchar](200) NULL,
	[intro2] [nvarchar](100) NULL,
	[caigou] [int] NULL,
	[sort] [int] NULL,
	[cateid] [int] NULL,
	[cateid2] [int] NULL,
	[cateid3] [int] NULL,
	[del] [int] NULL,
	[delcate] [int] NULL,
	[deldate] [datetime] NULL,
	[date7] [datetime] NULL,
	[kg] [int] NULL,
	[sort1] [int] NULL,
	[zdy1] [nvarchar](50) NULL,
	[zdy2] [nvarchar](50) NULL,
	[zdy3] [nvarchar](50) NULL,
	[zdy4] [nvarchar](50) NULL,
	[zdy5] [int] NULL,
	[zdy6] [int] NULL,
	[QTID] [int] NULL,
	[source] [int] NULL
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[M_MaterialProgres](
	[ID] [int] NOT NULL,
	[PrefixCode] [nvarchar](2) NOT NULL,
	[WAID] [int] NOT NULL,
	[title] [nvarchar](100) NULL,
	[MPBH] [nvarchar](50) NOT NULL,
	[MPDate] [datetime] NOT NULL,
	[Creator] [int] NOT NULL,
	[indate] [datetime] NOT NULL,
	[TempSave] [int] NULL,
	[del] [int] NOT NULL,
	[FromType] [int] NOT NULL DEFAULT (1),
	[PRID] [int] NULL,
	[ddno] [int] NOT NULL DEFAULT (0),
	[WProcID] [int] NOT NULL DEFAULT (0),
	[intro] [ntext] NULL,
PRIMARY KEY CLUSTERED
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]

--@##mode:index;clustered:false;fields:WAID
--@##mode:index;clustered:false;fields:MPDate
--@##mode:index;clustered:false;fields:Creator
--@##mode:index;clustered:false;fields:indate desc
--@##mode:index;clustered:false;fields:FromType
--@##mode:index;clustered:false;fields:PRID
--@##mode:index;clustered:false;fields:ddno
--@##mode:index;clustered:false;fields:WProcID

GO
CREATE TABLE [dbo].[O_assCardType](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[C_name] [varchar](200) NULL,
	[C_assState] [int] NULL,
	[C_assMethod] [int] NULL,
	[C_jczl] [money] NULL,
	[C_cycle] [int] NULL,
	[C_cycle1] [int] NULL,
	[C_addtime] [datetime] NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[tel](
	[ord] [int] IDENTITY(1,1) NOT NULL,
	[sort] [nvarchar](10) NULL,
	[name] [nvarchar](100) NULL,
	[khid] [nvarchar](50) NULL,
	[area] [int] NULL,
	[trade] [int] NULL,
	[sort1] [int] NULL,
	[sort2] [int] NULL DEFAULT (1),
	[ly] [int] NULL DEFAULT (0),
	[jz] [int] NULL DEFAULT (0),
	[person] [int] NULL,
	[phone] [nvarchar](50) NULL,
	[fax] [nvarchar](50) NULL,
	[email] [nvarchar](50) NULL,
	[faren] [nvarchar](50) NULL,
	[zijin] [decimal](25, 12) NULL DEFAULT (0),
	[pernum1] [int] NULL DEFAULT (0),
	[pernum2] [int] NULL DEFAULT (0),
	[url] [nvarchar](200) NULL,
	[zip] [nvarchar](10) NULL,
	[address] [nvarchar](500) NULL,
	[gate] [nvarchar](10) NULL,
	[product] [ntext] NULL,
	[intro] [ntext] NULL,
	[c2] [ntext] NULL,
	[c3] [ntext] NULL,
	[c4] [ntext] NULL,
	[x] [nvarchar](4) NULL,
	[h] [nvarchar](4) NULL,
	[f] [nvarchar](20) NULL DEFAULT (0),
	[num1] [decimal](25, 12) NULL,
	[num2] [decimal](25, 12) NULL,
	[share] [nvarchar](1000) NULL,
	[order1] [int] NULL,
	[cateadd] [int] NULL,
	[cateorder1] [int] NULL,
	[cateid] [int] NULL,
	[cateid2] [int] NULL,
	[cateid3] [int] NULL,
	[cateid4] [int] NULL,
	[cateidgq] [int] NULL,
	[date2] [datetime] NULL,
	[date1] [datetime] NULL,
	[datepro] [datetime] NULL,
	[dategq] [datetime] NULL,
	[profect1] [int] NULL DEFAULT (0),
	[del] [int] NULL,
	[delcate] [int] NULL,
	[deldate] [datetime] NULL,
	[date8] [datetime] NULL,
	[datealt] [datetime] NULL,
	[bank_1] [nvarchar](100) NULL,
	[bank_2] [nvarchar](50) NULL,
	[bank_7] [nvarchar](50) NULL,
	[bank_3] [nvarchar](50) NULL,
	[bank_4] [nvarchar](50) NULL,
	[bank_5] [nvarchar](100) NULL,
	[bank_6] [nvarchar](50) NULL,
	[bank2_1] [nvarchar](100) NULL,
	[bank2_2] [nvarchar](50) NULL,
	[bank2_7] [nvarchar](50) NULL,
	[bank2_3] [nvarchar](50) NULL,
	[bank2_4] [nvarchar](50) NULL,
	[bank2_5] [nvarchar](100) NULL,
	[bank2_6] [nvarchar](50) NULL,
	[fkdays] [int] NULL DEFAULT (0),
	[fkdate] [int] NULL DEFAULT (0),
	[jf] [decimal](25, 12) NULL DEFAULT (0),
	[jf2] [decimal](25, 12) NULL DEFAULT (0),
	[company] [int] NULL,
	[pym] [nvarchar](100) NULL,
	[sort3] [int] NULL DEFAULT (1),
	[datelast] [datetime] NULL,
	[sortfq] [int] NULL,
	[zdy1] [nvarchar](400) NULL,
	[zdy2] [nvarchar](400) NULL,
	[zdy3] [nvarchar](400) NULL,
	[zdy4] [nvarchar](400) NULL,
	[zdy5] [int] NULL,
	[zdy6] [int] NULL,
	[hk_xz] [decimal](25, 12) NULL,
	[money1] [decimal](25, 12) NULL DEFAULT (0),
	[hmd] [int] NULL DEFAULT (0),
	[sharecontact] [int] NULL DEFAULT (0),
	[replyShare] [int] NULL DEFAULT (0),
	[ModifyStamp] [varchar](30) NULL,
	[tel_excel_drSign] [bigint] NULL,
	[tel_excel_drUser] [int] NULL,
	[sp] [int] NULL,
	[cateid_sp] [int] NULL,
	[status_sp] [int] NULL,
	[date_sp] [datetime] NULL,
	[intro_sp_cateid] [int] NULL,
	[credit] [int] NULL,
	[isNeedQuali] [int] NULL,--是否需要资质
	[qualifications] [int] NULL,--资质分类
	[sp_qualifications] [int] NULL,-- 资质审批阶段
	[cateid_sp_qualifications] [int] NULL,--资质审批人
	[status_sp_qualifications] [int] NULL,--资质审批状态
	[lat] [decimal](25, 12) NULL, --纬度
	[lng] [decimal](25, 12) NULL, --经度
	[hascoord] [int] NULL --1 已设置坐标 ,
    PRIMARY KEY CLUSTERED
    (
        [ord] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


--@##mode:index;clustered:false;fields:name
--@##mode:index;clustered:false;fields:sort1,del,sort3;include:sp,profect1
--@##mode:index;clustered:false;fields:date1 DESC,ord,cateid,del,sort3,profect1,sort1,order1,cateorder1,sort,jz
--@##mode:index;clustered:false;fields:ord,del,sort3,order1,date1
--@##mode:index;clustered:false;fields:del,ord
--@##mode:index;clustered:false;fields:date1 DESC,ord,del,sort3
--@##mode:index;clustered:false;fields:del,sort3,cateorder1,cateid,sort,jz
--@##mode:index;clustered:false;fields:del,sort3,order1
--@##mode:index;clustered:false;fields:company
--@##mode:index;clustered:false;fields:phone
--@##mode:statistics;fields:cateorder1,cateid
--@##mode:statistics;fields:sort3,cateid3
--@##mode:statistics;fields:cateid2,del
--@##mode:statistics;fields:sort3,cateid
--@##mode:statistics;fields:profect1,del
--@##mode:statistics;fields:name,ord
--@##mode:statistics;fields:cateid,cateid3,del
--@##mode:statistics;fields:del,sort3,khid
--@##mode:statistics;fields:del,cateorder1,cateid
--@##mode:statistics;fields:ord,sort1,del
--@##mode:statistics;fields:sort3,del,date1
--@##mode:statistics;fields:cateid3,del,sort3
--@##mode:statistics;fields:ord,sort3,name
--@##mode:statistics;fields:cateid,cateid2,del
--@##mode:statistics;fields:sort3,cateid2,del
--@##mode:statistics;fields:sort3,del,order1
--@##mode:statistics;fields:sort,cateid,del
--@##mode:statistics;fields:del,sort3,name
--@##mode:statistics;fields:cateid,del,sort3,cateid2
--@##mode:statistics;fields:cateid,del,sort3,cateid3
--@##mode:statistics;fields:ord,cateid,sort,del
--@##mode:statistics;fields:sort3,cateorder1,cateid,del,sort
--@##mode:statistics;fields:cateid,sort1,del,sort3,ord
--@##mode:statistics;fields:date1,ord,profect1,del,sort3
--@##mode:statistics;fields:cateid,sort3,del,sort,jz
--@##mode:statistics;fields:date1,ord,sort1,del,sort3
--@##mode:statistics;fields:del,sort3,cateid,order1,cateorder1
--@##mode:statistics;fields:del,sort3,ord,order1,date1
--@##mode:statistics;fields:sort3,del,profect1,name,sort1
--@##mode:statistics;fields:sort1,del,sort3,ord,profect1,name
--@##mode:statistics;fields:date1,ord,cateorder1,order1,cateid,del
--@##mode:statistics;fields:del,sort3,profect1,order1,ord,date1
--@##mode:statistics;fields:ord,cateid,del,sort3,profect1,name
--@##mode:statistics;fields:del,sort3,profect1,sort1,ord,date1
--@##mode:statistics;fields:cateorder1,sort,cateid,jz,del,sort3
--@##mode:statistics;fields:sort1,del,sort3,ord,profect1,cateid,date1
--@##mode:statistics;fields:cateid,del,sort3,ord,order1,cateorder1,date1
--@##mode:statistics;fields:del,sort3,ord,cateid,sort,jz,order1
--@##mode:statistics;fields:ord,del,sort3,profect1,name,sort1,date1
--@##mode:statistics;fields:date1,ord,order1,cateorder1,cateid,sort,jz,del
--@##mode:statistics;fields:sort1,del,sort3,ord,cateid,profect1,name,date1
--@##mode:statistics;fields:sort3,del,cateid,sort,jz,order1,cateorder1,ord,date1

GO

CREATE TABLE [dbo].[his_kuinlist](
	[BatchNum] [int] NULL,
	[id] [int] NOT NULL,
	[ord] [int] NULL,
	[price1] [nvarchar](200) NULL,
	[num1] [decimal](25, 12) NULL,
	[num2] [decimal](25, 12) NULL,
	[kuin] [int] NULL,
	[ku] [int] NULL,
	[caigou] [int] NULL,
	[sort] [int] NULL,
	[dateadd] [datetime] NULL,
	[date7] [datetime] NULL,
	[del] [int] NULL,
	[addcate] [int] NULL,
	[bz] [int] NULL,
	[js] [nvarchar](50) NULL,
	[unit] [int] NULL,
	[intro] [nvarchar](100) NULL,
	[ph] [nvarchar](50) NULL,
	[xlh] [nvarchar](100) NULL,
	[datesc] [datetime] NULL,
	[dateyx] [datetime] NULL,
	[money1] [decimal](25, 12) NULL,
	[company] [int] NULL,
	[caigoulist] [int] NULL,
	[sort1] [int] NULL,
	[mxpx] [int] NULL,
	[zdy1] [nvarchar](200) NULL,
	[zdy2] [nvarchar](200) NULL,
	[zdy3] [nvarchar](200) NULL,
	[zdy4] [nvarchar](200) NULL,
	[zdy5] [int] NULL,
	[zdy6] [int] NULL,
	[QTLID] [int] NULL,
	[date2] [datetime] NULL,
	[MOrderID] [int] NULL,
    [MobileFromId] [int] NULL
) ON [PRIMARY]

GO
--进度汇报明细
CREATE TABLE [dbo].[M_MaterialProgresDetail](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[MPID] [int] NOT NULL DEFAULT (0),
	[NumQualified] [decimal](25, 12) NULL,
	[NumScrap] [decimal](25, 12) NULL,
	[SerialNumber] [nvarchar](100) NOT NULL,
	[ph] [nvarchar](100) NULL,
	[datesc] [datetime] NULL,
	[dateyx] [datetime] NULL,
	[intro] [nvarchar](100) NULL,
	[MRID] [int] NOT NULL DEFAULT (0),
	[Maker] [int] NOT NULL,
	[Premium] [decimal](25, 12) NULL,
	[del] [int] NOT NULL,
	[PRLID] [int] NOT NULL DEFAULT (0),
	[WPID] [int] NOT NULL,
	[price1] [decimal](25, 12) NULL,
	[money1] [decimal](25, 12) NULL,
	[wageStatus] [varchar](10) NOT NULL DEFAULT 'NOT_PAID'
PRIMARY KEY CLUSTERED
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]

--@##mode:index;clustered:false;fields:MPID
--@##mode:index;clustered:false;fields:MRID
--@##mode:index;clustered:false;fields:Maker
--@##mode:index;clustered:false;fields:PRLID
--@##mode:index;clustered:false;fields:WPID

GO
CREATE TABLE [dbo].[hr_com_time](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[title] [nvarchar](50) NULL,
	[open1] [int] NULL,
	[open2] [int] NULL,
	[open3] [int] NULL,
	[open4] [int] NULL,
	[open5] [int] NULL,
	[open6] [int] NULL,
	[open7] [int] NULL,
	[stime1] [nvarchar](50) NULL,
	[stime2] [nvarchar](50) NULL,
	[stime3] [nvarchar](50) NULL,
	[stime4] [nvarchar](50) NULL,
	[stime5] [nvarchar](50) NULL,
	[stime6] [nvarchar](50) NULL,
	[stime7] [nvarchar](50) NULL,
	[etime1] [nvarchar](50) NULL,
	[etime2] [nvarchar](50) NULL,
	[etime3] [nvarchar](50) NULL,
	[etime4] [nvarchar](50) NULL,
	[etime5] [nvarchar](50) NULL,
	[etime6] [nvarchar](50) NULL,
	[etime7] [nvarchar](50) NULL,
	[startTime] [datetime] NULL,
	[endTime] [datetime] NULL,
	[inDate] [datetime] NULL,
	[editDate] [datetime] NULL,
	[creator] [int] NULL,
	[holiday] [int] NULL,
	[isall] [int] NULL,
	[user_list] [text] NULL,
	[del] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]
 TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[telalt](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[company] [int] NULL,
	[date1] [datetime] NULL,
	[fh1] [int] NULL,
	[del] [int] NULL DEFAULT (1),
	[date7] [datetime] NULL,
	[cateid] [int] NULL,
	[intro] [nvarchar](2000) NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[his_kuout](
	[BatchNum] [int] NULL,
	[ord] [int] NOT NULL,
	[title] [nvarchar](100) NULL,
	[ckbh] [nvarchar](100) NULL,
	[ck] [int] NULL,
	[date3] [datetime] NULL,
	[date5] [datetime] NULL,
	[intro] [ntext] NULL,
	[complete1] [int] NULL,
	[fh1] [int] NULL,
	[order1] [int] NULL,
	[intro2] [nvarchar](100) NULL,
	[cateid] [int] NULL,
	[cateid2] [int] NULL,
	[cateid3] [int] NULL,
	[del] [int] NULL,
	[cateout] [int] NULL,
	[delcate] [int] NULL,
	[deldate] [datetime] NULL,
	[date7] [datetime] NULL,
	[kg] [int] NULL,
	[sort1] [int] NULL,
	[zdy1] [nvarchar](50) NULL,
	[zdy2] [nvarchar](50) NULL,
	[zdy3] [nvarchar](50) NULL,
	[zdy4] [nvarchar](50) NULL,
	[zdy5] [int] NULL,
	[zdy6] [int] NULL,
	[source] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[M_MaterialProgresLists](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[MPID] [int] NOT NULL,
	[BomList] [int] NOT NULL,
	[num1] [decimal](25, 12) NULL,
	[del] [int] NOT NULL,
PRIMARY KEY CLUSTERED
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]

--@##mode:index;clustered:false;fields:MPID
--@##mode:index;clustered:false;fields:BomList

GO
CREATE TABLE [dbo].[O_assChangeWay](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[W_name] [varchar](200) NULL,
	[W_code] [varchar](200) NULL,
	[W_method] [int] NULL,
	[W_note] [varchar](2000) NULL,
	[W_pz] [int] NULL,
	[W_zy] [varchar](2000) NULL,
	[W_km] [int] NULL,
	[W_hsxm] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO

--Attrs:帐套下可用
CREATE TABLE [dbo].[erp_sys_fileInsertReport](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[us] [int] NOT NULL,
	[intime] [datetime] NOT NULL,
	[filename] [varchar](200) NOT NULL,
	[savename] [varchar](200) NOT NULL,
	[savepath] [varchar](300) NOT NULL,
	[model] [varchar](200) NOT NULL,
	[cls] [varchar](50) NOT NULL,
	[ftype] [varchar](30) NOT NULL,
	[fSize] [bigint] NOT NULL,
	[clientIp] [varchar](30) NULL,
	[description] [varchar](500) NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[teljf](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[jf] [decimal](25, 12) NULL DEFAULT (0),
	[contract] [int] NULL,
	[company] [int] NULL,
	[date1] [datetime] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[his_kuoutlist](
	[BatchNum] [int] NULL,
	[id] [int] NOT NULL,
	[ord] [int] NULL,
	[price1] [nvarchar](200) NULL,
	[num1] [decimal](25, 12) NULL,
	[num2] [decimal](25, 12) NULL,
	[num3] [decimal](25, 12) NULL,
	[num4] [decimal](25, 12) NULL,
	[kuout] [int] NULL,
	[ku] [int] NULL,
	[order1] [int] NULL,
	[dateadd] [datetime] NULL,
	[date7] [datetime] NULL,
	[del] [int] NULL,
	[addcate] [int] NULL,
	[bz] [int] NULL,
	[js] [nvarchar](50) NULL,
	[money1] [decimal](25, 12) NULL,
	[company] [int] NULL,
	[unit] [int] NULL,
	[contractlist] [int] NULL,
	[intro] [decimal](25, 12) NULL,
	[zdy1] [nvarchar](200) NULL,
	[zdy2] [nvarchar](200) NULL,
	[zdy3] [nvarchar](200) NULL,
	[zdy4] [nvarchar](200) NULL,
	[zdy5] [int] NULL,
	[zdy6] [int] NULL,
	[date2] [datetime] NULL,
	[MOrderID] [int] NULL,
	[ph] [varchar](50) NULL,
	[xlh] [varchar](100) NULL,
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[M_OrderListSettings](
	[ID] [int] NOT NULL,
	[OrderID] [int] NOT NULL,
	[PKColumnName] [nvarchar](30) NOT NULL,
	[SubKeyName] [nvarchar](30) NOT NULL,
	[SubTable] [nvarchar](30) NOT NULL,
	[AutoComplete] [nvarchar](1000) NOT NULL,
	[SQLString] [nvarchar](500) NOT NULL,
	[SaveSetting] [nvarchar](1000) NOT NULL,
	[Macros] [nvarchar](1000) NOT NULL,
	[ColAttrs] [nvarchar](1000) NULL,
	[allowadd] [bit] NOT NULL DEFAULT (1),
	[allowdel] [bit] NOT NULL DEFAULT (1),
	[title] [nvarchar](100) NULL,
	[Formula] [nvarchar](500) NULL,
	[DisUserdef] [bit] NULL DEFAULT (0),
	[candr] [bit] NOT NULL DEFAULT (0),
PRIMARY KEY CLUSTERED
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]

--@##mode:index;clustered:false;fields:OrderID

GO
CREATE TABLE [dbo].[hr_dayWorkTime](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[title] [nvarchar](50) NULL,
	[creator] [int] NULL,
	[inDate] [datetime] NULL,
	[EditTime] [datetime] NULL,
	[dateStart] [nvarchar](50) NULL,
	[dateEnd] [nvarchar](50) NULL,
	[remark] [ntext] NULL,
	[PrefixCode] [nvarchar](50) NULL,
	[color] [nvarchar](50) NULL,
	[testNum] [int] NULL,
	[kt] [int] NULL,
	[CycleNum] [int] NULL,
	[del] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]
 TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[hr_resume_website](
	[id] [int] NOT NULL,
	[title] [varchar](50) NULL,
	[del] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[teljf2](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[num1] [decimal](25, 12) NULL DEFAULT (0),
	[intro] [nvarchar](500) NULL,
	[date1] [datetime] NULL,
	[company] [int] NULL,
	[cateid] [int] NULL,
	[cateid2] [int] NULL,
	[cateid3] [int] NULL,
	[del] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[his_kuoutlist2](
	[BatchNum] [int] NULL,
	[id] [int] NOT NULL,
	[ord] [int] NULL,
	[num1] [decimal](25, 12) NULL,
	[num2] [decimal](25, 12) NULL,
	[num3] [decimal](25, 12) NULL,
	[price1] [decimal](25, 12) NULL,
	[money1] [decimal](25, 12) NULL,
	[company] [int] NULL,
	[contract] [int] NULL,
	[contractlist] [int] NULL,
	[kuout] [int] NULL,
	[kuoutlist] [int] NULL,
	[area] [int] NULL,
	[trade] [int] NULL,
	[unit] [int] NULL,
	[ck] [int] NULL,
	[ph] [nvarchar](50) NULL,
	[xlh] [nvarchar](100) NULL,
	[datesc] [datetime] NULL,
	[dateyx] [datetime] NULL,
	[bz] [int] NULL,
	[js] [decimal](25, 12) NULL,
	[intro] [nvarchar](200) NULL,
	[caigoulist] [int] NULL,
	[kuinlist] [int] NULL,
	[ku] [int] NULL,
	[gys] [int] NULL,
	[date1] [datetime] NULL,
	[date7] [datetime] NULL,
	[del] [int] NULL,
	[cateid] [int] NULL,
	[cateid2] [int] NULL,
	[cateid3] [int] NULL,
	[addcate] [int] NULL,
	[mxid] [int] NULL,
	[sort1] [int] NULL,
	[isMinus] [int] NULL,
	[HCStatus] [int] NULL,
	[zdy1] [nvarchar](200) NULL,
	[zdy2] [nvarchar](200) NULL,
	[zdy3] [nvarchar](200) NULL,
	[zdy4] [nvarchar](200) NULL,
	[zdy5] [int] NULL,
	[zdy6] [int] NULL,
	[MOrderID] [int] NULL,
	[date2] [datetime] NULL,
	[price2] [decimal](25, 12) NULL DEFAULT (0),
	[money2] [decimal](25, 12) NULL DEFAULT (0)
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[M_OrderSettings_flows](
	[id] [int] NOT NULL,
	[title] [nvarchar](50) NULL,
	[remark] [nvarchar](100) NULL,
	[MustNodes] [varchar](2000) NULL,
	[seletedNodes] [varchar](2000) NULL,
	[mustllhb] [bit] NULL,
	[canyldj] [bit] NULL,
	[dismorehb] [bit] NULL,
	[used] [bit] NULL,
	[sort1] [int] NULL,
	PRIMARY KEY CLUSTERED 
	(
		[id] ASC
	)
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[M_OrderSettings](
	[ID] [int] NOT NULL,
	[OrderType] [nvarchar](20) NOT NULL,
	[qxlb] [int] NULL,
	[PrefixCode] [nvarchar](2) NOT NULL,
	[LeftGroup] [nvarchar](100) NOT NULL,
	[LeftGroupSQL] [nvarchar](500) NOT NULL,
	[PKColumn] [nvarchar](30) NOT NULL,
	[isGroup] [bit] NOT NULL,
	[OrderName] [nvarchar](50) NOT NULL,
	[MainTable] [nvarchar](30) NOT NULL,
	[SQLString] [nvarchar](500) NOT NULL,
	[ColumnSetting] [nvarchar](4000) NOT NULL,
	[SearchSetting] [nvarchar](4000) NULL,
	[Macros] [nvarchar](1000) NOT NULL,
	[HasSP] [bit] NOT NULL,
	[ParentNode] [nvarchar](50) NULL,
	[ManuShow] [bit] NOT NULL DEFAULT (1),
	[ManuSort] [int] NOT NULL DEFAULT (1),
	[ManuPower] [bit] NOT NULL DEFAULT (1),
	[SpSql] [nvarchar](1000) NULL,
	[AutoBH] [int] NOT NULL DEFAULT (0),
	[BHMenuName] [nvarchar](50) NULL,
	[BHFieldsName] [nvarchar](50) NULL,
	[Rules] [nvarchar](1000) NULL,
	[defJSFile] [nvarchar](500) NULL,
	[CanReturn] [bit] NULL DEFAULT (0),
	[SpLinkCreator] [int] NOT NULL DEFAULT (0),
	[ParentID] [int] NULL,
	[LinkSetting] [nvarchar](4000) NULL,
	[Role] [int] NOT NULL DEFAULT (0),
	[PasteAlert] [varchar](100) NULL,
	[canCopy] [bit] NOT NULL DEFAULT (0),
	[DisUserdef] [bit] NULL DEFAULT (0),
	[xlsout] [bit] NOT NULL DEFAULT (0),
	[Reply] [bit] NOT NULL DEFAULT (0),
	[Modules] varchar(200) null,
PRIMARY KEY CLUSTERED
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[Sys_ExtField](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[F_name] [varchar](200) NULL,
	[F_style] [int] NULL,
	[F_isUse] [int] NULL,
	[F_sort] [int] NULL,
	[F_search] [int] NULL,
	[F_dr] [int] NULL,
	[F_dc] [int] NULL,
	[F_bt] [int] NULL,
	[F_ftype] [int] NULL,
	[F_type] [int] NULL,
	[F_del] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[tousu](
	[ord] [int] IDENTITY(1,1) NOT NULL,
	[title] [nvarchar](300) NULL,
	[shid] [nvarchar](50) NULL,
    [moduleID] [int] NULL,
	[main] [int] NULL DEFAULT (0),
	[member1] [int] NULL,
	[sort1] [int] NULL,
	[way1] [int] NULL,
	[date1] [datetime] NULL,
	[time1] [nvarchar](50) NULL,
	[time2] [nvarchar](50) NULL,
	[product] [int] NULL,
	[introts] [ntext] NULL,
	[great1] [int] NULL,
	[intro1] [ntext]NULL,
	[result1] [int] NULL,
	[time3] [nvarchar](50) NULL,
	[intro2] [ntext] NULL,
	[intro3] [ntext] NULL,
	[intro4] [ntext] NULL,
	[intro5] [ntext] NULL,
	[intro6] [ntext] NULL,
	[intro7] [ntext] NULL,
	[intro8] [ntext] NULL,
	[name1] [nvarchar](50) NULL,
	[name2] [nvarchar](50) NULL,
	[name3] [nvarchar](50) NULL,
	[name4] [nvarchar](50) NULL,
	[name5] [nvarchar](50) NULL,
	[name6] [nvarchar](50) NULL,
	[name7] [nvarchar](50) NULL,
	[name8] [nvarchar](50) NULL,
	[intro] [ntext] NULL,
	[share] [varchar](6000) NULL,
	[area] [int] NULL,
	[trade] [int] NULL,
	[cateid] [int] NULL,
	[cateid2] [int] NULL,
	[cateid3] [int] NULL,
	[addcate] [int] NULL,
	[addcate2] [int] NULL,
	[addcate3] [int] NULL,
	[cate1] [int] NULL DEFAULT (0),
	[cate2] [int] NULL DEFAULT (0),
	[cate3] [int] NULL DEFAULT (0),
	[cate4] [int] NULL DEFAULT (0),
	[cate5] [int] NULL DEFAULT (0),
	[cate6] [int] NULL DEFAULT (0),
	[cate7] [int] NULL DEFAULT (0),
	[cate8] [int] NULL,
	[catelead] [int] NULL,
	[catemain] [int] NULL,
	[company] [nvarchar](50) NULL,
	[person] [nvarchar](50) NULL,
	[date11] [datetime] NULL,
	[date12] [datetime] NULL,
	[date13] [datetime] NULL,
	[date14] [datetime] NULL,
	[date15] [datetime] NULL,
	[date16] [datetime] NULL,
	[date17] [datetime] NULL,
	[date18] [datetime] NULL,
	[date7] [datetime] NULL,
	[del] [int] NULL,
	[delcate] [int] NULL,
	[deldate] [datetime] NULL,
	[contract] [int] NULL,
	[chance] [int] NULL DEFAULT (0),
	[phone] [nvarchar](50) NULL,
	[mobile] [nvarchar](50) NULL,
	[wxUserID] [int] NULL,
	[wxFlag] [int] NULL,
    [IsOpen1] [int] NULL,
	[IsOpen2] [int] NULL,
	[IsOpen3] [int] NULL,
	[IsOpen4] [int] NULL,
	[IsOpen5] [int] NULL,
	[IsOpen6] [int] NULL,
	[IsOpen7] [int] NULL,
	[IsOpen8] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [ord] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]
 TEXTIMAGE_ON [PRIMARY]

--@##mode:index;clustered:true;fields:contract,del,date1
--@##mode:statistics;fields:contract,del
--@##mode:statistics;fields:del,company
--@##mode:statistics;fields:date1,contract,del
--@##mode:statistics;fields:date1,company,del

GO

CREATE TABLE [dbo].[his_StoreInit_Log](
	[BatchNum] [int] IDENTITY(1,1) NOT NULL,
	[OperatorID] [int] NOT NULL,
	[OperatorIP] [nvarchar](20) NOT NULL,
	[OperatDate] [datetime] NOT NULL,
    PRIMARY KEY CLUSTERED
    (
        [BatchNum] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[M_PieceRate](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[MRID] [int] NOT NULL,
	[ProductID] [int] NOT NULL,
	[WPID] [int] NOT NULL,
	[Price] [decimal](25, 12) NULL,
	[Rate] [decimal](25, 12) NULL,
	[intro] [nvarchar](500) NULL,
	[del] [int] NOT NULL DEFAULT (0),
	[sn] [nvarchar](50) NULL,
	[bm] [int] NOT NULL DEFAULT (0),
	[zb] [int] NOT NULL DEFAULT (0),
    [remark] [nvarchar](100) null,
	[WProc] [int] NOT NULL DEFAULT (0),
    PRIMARY KEY CLUSTERED
    (
        [ID] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


--@##mode:index;clustered:true;fields:MRID
--@##mode:index;clustered:false;fields:ProductID
--@##mode:index;clustered:false;fields:WPID
--@##mode:index;clustered:false;fields:bm
--@##mode:index;clustered:false;fields:WProc

GO
CREATE TABLE [dbo].[hr_fc](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[title] [nvarchar](100) NULL,
	[del] [int] NULL,
	[creator] [int] NULL,
	[indate] [datetime] NULL,
	[d1] [datetime] NULL,
	[d2] [datetime] NULL,
	[testDays] [int] NULL,
	[schedulHtml] [text] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]
 TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[wages](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[title] [nvarchar](50) NULL,
	[money1] [decimal](25, 12) NULL DEFAULT (0),
	[bank] [int] NULL,
    [IsEnabled] [int] NULL,
	[complete1] [int] NULL DEFAULT (0),
	[cateid] [int] NULL,
	[del] [int] NULL DEFAULT (1),
	[delcate] [int] NULL,
	[deldate] [datetime] NULL,
	[date1] [datetime] NULL,
	[date2] [datetime] NULL,
	[date3] [datetime] NULL,
	[date7] [datetime] NULL,
	[bz] [int] NULL,
	[salaryClass] [int] NULL,
	[ModifyStamp] [varchar](30) NULL,
	[sp] [int] NULL,
	[cateid_sp] [int] NULL,
	[complete2] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


--@##mode:index;clustered:true;fields:id

GO
CREATE TABLE [dbo].[hl](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[bz] [int] NULL,
	[hl] [decimal](25, 12) NULL,
	[date1] [datetime] NULL,
	[gettime] [datetime] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


--@##mode:index;clustered:true;fields:date1,bz
--@##mode:index;clustered:false;fields:id

GO
CREATE TABLE [dbo].[M_PieceRateMain](
	[ID] [int] NOT NULL,
	[PrefixCode] [nvarchar](2) NULL,
	[Creator] [int] NOT NULL,
	[indate] [datetime] NOT NULL,
	[title] [nvarchar](100) NULL,
	[intro] [nvarchar](1000) NULL,
	[DateBegin] [datetime] NULL,
	[DateEnd] [datetime] NULL,
	[id_sp] [int] NULL,
	[cateid_sp] [int] NULL,
	[status] [int] NULL,
	[del] [int] NULL,
	[tempsave] [int] NOT NULL DEFAULT (0),
	[WProc] [int] NOT NULL DEFAULT (0)
PRIMARY KEY CLUSTERED
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]

--@##mode:index;clustered:false;fields:Creator
--@##mode:index;clustered:false;fields:indate desc
--@##mode:index;clustered:false;fields:DateBegin
--@##mode:index;clustered:false;fields:DateEnd
--@##mode:index;clustered:false;fields:WProc

GO
--Attrs:帐套下可用
CREATE TABLE [dbo].[Sys_ExtFieldValue](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[V_fid] [int] NULL,
	[V_name] [varchar](200) NULL,
	[V_value] [ntext] NULL,
	[V_pid] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[wages_jj](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[date1] [datetime] NULL,
	[money1] [decimal](25, 12) NULL,
	[complete1] [int] NULL DEFAULT (0),
	[addcate] [int] NULL,
	[date3] [datetime] NULL,
	[date7] [datetime] NULL,
	[wages2] [int] NULL,
	[salaryClass] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[power](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[qx_open] [int] NULL,
	[qx_intro] [ntext] NOT NULL DEFAULT(''),
	[ord] [int] NOT NULL,
	[sort1] [int]  NOT NULL,
	[sort2] [int] NOT NULL,
PRIMARY KEY CLUSTERED
(
	[ord] ASC,
	[sort1] ASC,
	[sort2] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

--@##mode:index;clustered:false;fields:id

GO

if exists(select * from sysobjects where name='ClearTempLeftMenu2')
DROP TRIGGER [dbo].[ClearTempLeftMenu2]

GO
CREATE TABLE [dbo].[huifu](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NULL,
	[intro] [nvarchar](500) NULL,
	[name] [nvarchar](50) NULL,
	[sort] [int] NULL,
	[cateid] [int] NULL,
	[date7] [datetime] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[power1](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NULL,
	[sort1] [nvarchar](50) NULL,
	[gate1] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[caigouth](
	[ord] [int] IDENTITY(1,1) NOT NULL,
	[title] [nvarchar](100) NULL,
	[cgthid] [nvarchar](50) NULL,
	[money1] [decimal](25, 12) NULL,
	[bz] [int] NULL,
	[sort] [int] NULL,
	[complete1] [int] NULL,
	[date3] [datetime] NULL,
    [thperson] [int] NULL,
	[area] [int] NULL,
	[trade] [int] NULL,
	[intro] [ntext] NULL,
	[company] [int] NULL,
    [PersonID] [int] NULL,
	[person1] [nvarchar](50) NULL,
	[person2] [int] NULL,
	[caigou] [int] NULL,
	[cateid] [int] NULL,
	[cateid2] [int] NULL,
	[cateid3] [int] NULL,
	[addcate] [int] NULL,
	[addcate2] [int] NULL,
	[addcate3] [int] NULL,
	[date7] [datetime] NULL,
	[del] [int] NULL,
	[delcate] [int] NULL,
	[deldate] [datetime] NULL,
	[zt1] [int] NULL,
	[zt2] [int] NULL,
	[zdy1] [nvarchar](50) NULL,
	[zdy2] [nvarchar](50) NULL,
	[zdy3] [nvarchar](50) NULL,
	[zdy4] [nvarchar](50) NULL,
	[zdy5] [int] NULL,
	[zdy6] [int] NULL,
	[money2] [decimal](25, 12) NULL,
	[ModifyStamp] [varchar](30) NULL,
	[FromModel]  int null default('0'),
	[QcId]  int null,
PRIMARY KEY CLUSTERED
(
	[ord] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[sms_replace_str](
	[ord] [int] NOT NULL,
	[title] [nvarchar](100) NULL,
	[replaceStr] [nvarchar](100) NULL,
	[sortID] [int] NULL,
	[addTime] [datetime] NULL,
	[addcate] [int] NULL,
	[del] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[ord] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[hf_CusReply](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[mainID] [int] NULL,
	[typeID] [int] NULL,
	[QuestionID] [int] NULL,
	[radioID] [int] NULL,
	[checkIDStr] [varchar](4000) NULL,
	[content] [varchar](4000) NULL,
	[creator] [int] NULL,
	[indate] [datetime] NULL,
	[del] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[O_RegBook_his](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[bk_fid] [int] NULL,
	[bk_name] [varchar](2000) NULL,
	[bk_type] [int] NULL,
	[bk_bh] [varchar](1000) NULL,
	[bk_auther] [varchar](1000) NULL,
	[bk_publishing] [varchar](1000) NULL,
	[bk_ISBN] [varchar](1000) NULL,
	[bk_pubtime] [datetime] NULL,
	[bk_pagesize] [int] NULL,
	[bk_pagenum] [int] NULL,
	[bk_pubnum] [varchar](1000) NULL,
	[bk_printtime] [datetime] NULL,
	[bk_returnnum] [int] NULL,
	[bk_paper] [varchar](50) NULL,
	[bk_printnum] [varchar](1000) NULL,
	[bk_binding] [varchar](2000) NULL,
	[bk_format] [varchar](1000) NULL,
	[bk_num] [int] NULL,
	[bk_price] [decimal](25, 12) NULL,
	[bk_allnum] [int] NULL,
	[bk_allmoney] [decimal](25, 12) NULL,
	[bk_postion] [varchar](2000) NULL,
	[bk_note] [ntext] NULL,
	[bk_addcateid] [int] NULL,
	[bk_addtime] [datetime] NULL,
	[bk_del] [int] NULL DEFAULT (1),
	[bk_updateid] [int] NULL,
	[bk_updatetime] [datetime] NULL,
	[bk_updateIP] [varchar](200) NULL,
	[sign] [varchar](2000) NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[hr_interview](
	[id] [int] NOT NULL,
	[userName] [varchar](50) NULL,
	[resumeID] [int] NULL,
	[viewTime] [datetime] NULL,
	[intro] [text] NULL,
	[creator] [int] NULL,
	[id_sp] [int] NULL,
	[cateid_sp] [int] NULL,
	[status] [int] NULL,
	[TempSave] [bit] NULL,
	[indate] [datetime] NULL,
	[isInto] [int] NULL,
	[del] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[home_sysStopList](
	[sysID] [int] NOT NULL,
	[clsType] [int] NOT NULL
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[power2](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[cateid] [int] NULL,
	[sort1] [int] NULL,
	[name] [nvarchar](50) NULL,
	[qx_open] [int] NULL,
	[w1] [ntext] NULL,
	[w2] [ntext] NULL,
	[w3] [ntext] NULL,
	[orgsids] [ntext] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]
 TEXTIMAGE_ON [PRIMARY]

--@##mode:statistics;fields:cateid,sort1

GO

CREATE TABLE [dbo].[linshi1](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[num1] [decimal](25, 12) NULL,
	[num2] [decimal](25, 12) NULL,
	[num3] [decimal](25, 12) NULL,
	[num4] [decimal](25, 12) NULL,
	[num5] [decimal](25, 12) NULL,
	[num6] [decimal](25, 12) NULL,
	[num7] [decimal](25, 12) NULL,
	[num8] [decimal](25, 12) NULL,
	[num9] [decimal](25, 12) NULL,
	[num10] [decimal](25, 12) NULL,
	[num11] [decimal](25, 12) NULL,
	[num12] [decimal](25, 12) NULL,
	[money1] [decimal](25, 12) NULL,
	[money2] [decimal](25, 12) NULL,
	[money3] [decimal](25, 12) NULL,
	[money4] [decimal](25, 12) NULL,
	[money5] [decimal](25, 12) NULL,
	[money6] [decimal](25, 12) NULL,
	[money7] [decimal](25, 12) NULL,
	[money8] [decimal](25, 12) NULL,
	[money9] [decimal](25, 12) NULL,
	[money10] [decimal](25, 12) NULL,
	[money11] [decimal](25, 12) NULL,
	[money12] [decimal](25, 12) NULL,
	[sum1] [decimal](25, 12) NULL,
	[sum2] [decimal](25, 12) NULL,
	[sum3] [decimal](25, 12) NULL,
	[sum4] [decimal](25, 12) NULL,
	[sum5] [decimal](25, 12) NULL,
	[sum6] [decimal](25, 12) NULL,
	[sum7] [decimal](25, 12) NULL,
	[sum8] [decimal](25, 12) NULL,
	[sum9] [decimal](25, 12) NULL,
	[sum10] [decimal](25, 12) NULL,
	[sum11] [decimal](25, 12) NULL,
	[sum12] [decimal](25, 12) NULL,
	[summ1] [decimal](25, 12) NULL,
	[summ2] [decimal](25, 12) NULL,
	[summ3] [decimal](25, 12) NULL,
	[summ4] [decimal](25, 12) NULL,
	[summ5] [decimal](25, 12) NULL,
	[summ6] [decimal](25, 12) NULL,
	[summ7] [decimal](25, 12) NULL,
	[summ8] [decimal](25, 12) NULL,
	[summ9] [decimal](25, 12) NULL,
	[summ10] [decimal](25, 12) NULL,
	[summ11] [decimal](25, 12) NULL,
	[summ12] [decimal](25, 12) NULL,
	[ord] [int] NULL,
	[cateid] [int] NULL,
	[date7] [datetime] NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[telbank](
	[autoid] [int] IDENTITY(1,1) NOT NULL,
	[company] [varchar](20) NULL,
	[bz] [int] NULL,
	[money1] [decimal](25, 12) NULL,
	[intro] [varchar](100) NULL,
	[cateid] [int] NULL,
	[date3] [datetime] NULL,
	[date7] [datetime] NULL,
	[del] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[autoid] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[power3](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[sort1] [int] NULL,
	[name] [nvarchar](50) NULL,
	[gate1] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[caigouthbz](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[intro1] [nvarchar](2000) NULL,
	[intro2] [nvarchar](2000) NULL,
	[intro3] [nvarchar](2000) NULL,
	[intro4] [nvarchar](2000) NULL,
	[intro5] [nvarchar](2000) NULL,
	[intro6] [nvarchar](2000) NULL,
	[caigouth] [int] NULL,
	[date7] [datetime] NULL,
	[del] [int] NULL,
	[addcate] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[sms_temp](
	[ord] [int] IDENTITY(1,1) NOT NULL,
	[title] [nvarchar](100) NULL,
	[content] [text] NULL,
	[sortID] [int] NULL,
	[isDefault] [int] NULL,
	[addTime] [datetime] NULL,
	[addcate] [int] NULL,
	[del] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[ord] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

CREATE TABLE [dbo].[price](
	[ord] [int] IDENTITY(1,1) NOT NULL,
	[order1] [nvarchar](50) NULL,
	[title] [nvarchar](100) NULL,
    [sort1] [int] NULL,
	[intro] [ntext] NULL,
	[premoney] [decimal](25, 12) NULL,			--原报价总额
	[yhtype] [int] NULL,				--优惠方式
	[zk] [decimal](25, 12) NOT NULL DEFAULT(-1),			--折扣,默认是10折
	[Inverse] [int] NULL,				--反算标志 0/ 1 折扣是否被反算.
	[yhmoney] [decimal](25, 12) NULL, --优惠金额
	[money1] [decimal](25, 12) NOT NULL DEFAULT (0),
	[money2] [decimal](25, 12) NULL,
	[bz] [int] NOT NULL DEFAULT (14),
	[complete] [int] NULL DEFAULT (0),
    [status] [int] NULL,
	[lead1] [int] NULL,
	[lead2] [int] NULL,
	[cateid] [int] NULL,
	[cateid2] [int] NULL,
	[cateid3] [int] NULL,
	[company] [int] NULL,
	[person] [int] NULL,
	[chance] [int] NULL,
	[date7] [datetime] NULL,
	[date2] [datetime] NULL,
	[date3] [datetime] NULL,
	[del] [int] NULL,
	[delcate] [int] NULL,
	[deldate] [datetime] NULL,
	[cateid_sp] [int] NULL,
	[del2] [int] NULL,
	[alt] [int] NULL DEFAULT (0),
	[zdy1] [nvarchar](500) NULL,
	[zdy2] [nvarchar](500) NULL,
	[zdy3] [nvarchar](500) NULL,
	[zdy4] [nvarchar](500) NULL,
	[zdy5] [int] NULL,
	[zdy6] [int] NULL,
	[xj] [int] NULL,
	[id_sp] [int] NULL,
	[addcate] [int] NULL,
	[date1] [datetime] NULL,
	[shareor] [int] NULL,
	[shareTime] [datetime] NULL,
	[share] [nvarchar](max) NULL,
    PRIMARY KEY CLUSTERED
    (
        [ord] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]
 TEXTIMAGE_ON [PRIMARY]

--/*聚集留给最需要的查询*/
--@##mode:index;clustered:false;fields:ord,del,date7 desc
--@##mode:statistics;fields:ord,company
--@##mode:statistics;fields:ord,del,date7
--@##mode:statistics;fields:company,del,date7
--@##mode:statistics;fields:date1,ord,complete
--@##mode:statistics;fields:date7,ord,company,del
--@##mode:statistics;fields:complete,del,date1,ord

GO

CREATE TABLE [dbo].[M_CurUser](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[UID] [int] NOT NULL,
	[indate] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[UniqueLogin](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[uid] [int] NOT NULL,
	[LastActiveTime] [datetime] NOT NULL,
	[LastLoginIP] [varchar](30) NOT NULL,
	[LastLoginMac] [varchar](50) NOT NULL,
	[loginType] [int] NULL,
	[loginAccount] [int] NULL , --当前用户登录的财务总账账套
	[status]  varchar(50)  NULL,
	[SessionID] varchar(100) NULL,
	[machinetype] varchar(50) NULL,
	[machineToken] varchar(80) NULL,
	[homeurl] varchar(200) NULL,
	[attrsData] nvarchar(1000) NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[O_LendBook](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[free1] [int] NULL,
	[free2] [varchar](3000) NULL,
	[addcateid] [int] NULL,
	[addtime] [datetime] NULL,
	[del] [int] NULL,
	[ModifyStamp] [varchar](200) NULL DEFAULT (1),
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO

--Attrs:帐套下可用
CREATE TABLE [dbo].[erp_sys_temp_attr](
	[key] [varchar](50) NULL,
	[txtv] [varchar](50) NULL,
	[numv] [int] NULL
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[pricebz](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[intro1] [ntext] NULL,
	[intro2] [ntext] NULL,
	[intro3] [ntext] NULL,
	[intro4] [ntext] NULL,
	[intro5] [ntext] NULL,
	[intro6] [ntext] NULL,
	[price] [nvarchar](50) NULL,
	[date7] [datetime] NULL,
	[del] [int] NULL,
	[addcate] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]
 TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[caigouthlist](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NULL,
	[price1] [decimal](25, 12) NOT NULL DEFAULT(0),
	[num1] [decimal](25, 12) NOT NULL DEFAULT(0),
	[money1] [decimal](25, 12) NOT NULL DEFAULT(0),
	[num2] [decimal](25, 12) NULL,
	[num3] [decimal](25, 12) NULL,
	[num4] [decimal](25, 12) NULL,
	[area] [int] NULL,
	[trade] [int] NULL,
	[date1] [datetime] NULL,
	[date7] [datetime] NULL,
	[company] [int] NULL,
	[caigou] [int] NULL,
	[caigouth] [int] NULL,
	[cateid] [int] NULL,
	[cateid2] [int] NULL,
	[cateid3] [int] NULL,
	[addcate] [int] NULL,
	[del] [int] NULL,
	[delcate] [int] NULL,
	[deldate] [datetime] NULL,
	[bz] [int] NOT NULL DEFAULT(14),
	[unit] [int] NOT NULL DEFAULT(0),
    [commUnitAttr] [nvarchar](200) NULL,
	[intro] [nvarchar](200) NULL,
	[ph] [nvarchar](50) NULL,
	[xlh] [nvarchar](100) NULL,
	[datesc] [datetime] NULL,
	[dateyx] [datetime] NULL,
	[zdy1] [nvarchar](200) NULL,
	[zdy2] [nvarchar](200) NULL,
	[zdy3] [nvarchar](200) NULL,
	[zdy4] [nvarchar](200) NULL,
	[zdy5] [int] NULL,
	[zdy6] [int] NULL,
	[date2] [datetime] NULL,
	[jf] [decimal](25, 12) NULL,
	[kuinlist] [int] NULL,
	[caigoulist] [int] NULL,
	[ProductAttr1] int null,
	[ProductAttr2] int null,
	[ProductAttrBatchId] int null,
	[MoneyBeforeTax] [decimal](25,12) not null DEFAULT(0),
	[InvoiceType] [int] not null DEFAULT(0),
	[TaxRate] [decimal](25,12) not null DEFAULT(0),
	[TaxValue] [decimal](25,12) not null DEFAULT(0),
	[QClistId] [int] null,
	[NoNeedOutKu] [int] not null DEFAULT(0),
    [SerialID] [int] Null,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[hf_Question](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[QCls] [int] NULL,
	[title] [varchar](500) NULL,
	[Gate1] [int] NULL,
	[Qtype] [int] NULL,
	[List] [varchar](50) NULL,
	[Creator] [int] NULL,
	[Indate] [datetime] NULL,
	[Del] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[hr_leave](
	[id] [int] NOT NULL,
	[title] [varchar](200) NULL,
	[bh] [varchar](100) NULL,
	[gateName] [varchar](50) NULL,
	[sorce] [int] NULL,
	[sorce2] [int] NULL,
	[sorceName] [varchar](50) NULL,
	[sorce2Name] [varchar](50) NULL,
	[postion] [varchar](50) NULL,
	[sortID] [int] NULL,
	[contractTime] [datetime] NULL,
	[laveTime] [datetime] NULL,
	[content] [text] NULL,
	[status] [int] NULL,
	[creator] [int] NULL,
	[indate] [datetime] NULL,
	[id_sp] [int] NULL,
	[cateid_sp] [int] NULL,
	[addcate] [int] NULL,
	[TempSave] [bit] NULL,
	[del] [int] NULL,
	[cateid] [int] NULL,
	[statusID] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[pricelist](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NULL,
	[price1] [decimal](25, 12) NOT NULL DEFAULT (0),
	[num1] [decimal](25, 12) NOT NULL DEFAULT (0),
	[price] [int] NULL,
	[date7] [datetime] NULL,
	[del] [int] NULL,
	[addcate] [int] NULL,
	[intro] [nvarchar](200) NULL,
	[bz] [int] NOT NULL DEFAULT (14),
    [discount] [decimal](25, 12) NULL,
	[priceAfterDiscount] [decimal](25, 12) NULL,
	[invoiceType] [int] NULL,
	[taxRate] [decimal](25, 12) NULL,
	[priceIncludeTax] [decimal](25, 12) NULL,
	[priceAfterTax] [decimal](25, 12) NULL,
	[moneyBeforeTax] [decimal](25, 12) NOT NULL default(0),
	[taxValue] [decimal](25, 12) NULL,
	[money1] [decimal](25, 12) NOT NULL DEFAULT(0),
	[date2] [datetime] NULL,
	[unit] [int] NOT null default (0),
	[commUnitAttr] [nvarchar](200) NULL,
	[zdy1] [nvarchar](200) NULL,
	[zdy2] [nvarchar](200) NULL,
	[zdy3] [nvarchar](200) NULL,
	[zdy4] [nvarchar](200) NULL,
	[zdy5] [int] NULL,
	[zdy6] [int] NULL,
	[xunjiastatus] [int] NULL DEFAULT (0),
	[pid] [int] NULL DEFAULT (0),
    [pricejy] [decimal](25, 12) NOT null default (0),
    [tpricejy] [decimal](25, 12) NOT null default (0),
	[del2] [int] NULL,
	[treeOrd] [int] NULL,
	[listorder] [int] NOT NULL DEFAULT(2147483647),
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


--@##mode:index;clustered:true;fields:listorder,date7,id,price,del
--@##mode:statistics;fields:price,del
--@##mode:statistics;fields:price,xunjiastatus
--@##mode:statistics;fields:date7,id
--@##mode:statistics;fields:price,date7,id
--@##mode:statistics;fields:id,price,del,listorder
--@##mode:statistics;fields:id,price,xunjiastatus,listorder,date7
--@##mode:statistics;fields:listorder,date7,id,price,del

GO
CREATE TABLE [dbo].[Mobile_Pricelist](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NULL,
	[price1] [decimal](25, 12) NOT NULL DEFAULT (0),
	[num1] [decimal](25, 12) NOT NULL DEFAULT (0),
	[price] [int] NULL,
	[date7] [datetime] NULL,
	[del] [int] NULL,
	[addcate] [int] NULL,
	[intro] [nvarchar](200) NULL,
	[bz] [int] NOT NULL DEFAULT (14),
    [discount] [decimal](25, 12) NULL,
	[priceAfterDiscount] [decimal](25, 12) NULL,
	[invoiceType] [int] NULL,
	[taxRate] [decimal](25, 12) NULL,
	[priceIncludeTax] [decimal](25, 12) NULL,
	[priceAfterTax] [decimal](25, 12) NULL,
	[moneyBeforeTax] [decimal](25, 12) NOT NULL default(0),
	[taxValue] [decimal](25, 12) NULL,
	[money1] [decimal](25, 12) NOT NULL DEFAULT(0),
	[date2] [datetime] NULL,
	[unit] [int] NOT null default (0),
	[commUnitAttr] [nvarchar](200) NULL,
	[zdy1] [nvarchar](200) NULL,
	[zdy2] [nvarchar](200) NULL,
	[zdy3] [nvarchar](200) NULL,
	[zdy4] [nvarchar](200) NULL,
	[zdy5] [int] NULL,
	[zdy6] [int] NULL,
	[xunjiastatus] [int] NULL DEFAULT (0),
	[pid] [int] NULL DEFAULT (0),
    [pricejy] [decimal](25, 12) NOT null default (0),
    [tpricejy] [decimal](25, 12) NOT null default (0),
	[del2] [int] NULL,
	[treeOrd] [int] NULL,
	[listorder] [int] NOT NULL DEFAULT(2147483647),
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[UniqueLoginPermitIP](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[uid] [int] NOT NULL,
	[IPpara1] [bigint] NOT NULL,
	[IPpara2] [bigint] NOT NULL,
	[datebegin] [datetime] NULL,
	[dateend] [datetime] NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[product](
	[ord] [int] IDENTITY(1,1) NOT NULL,
	[title] [nvarchar](500) NULL,
	[type1] [nvarchar](500) NULL,
	[sort1] [int] NULL,
	[unit] [nvarchar](500) NULL,
	[order1] [nvarchar](500) NULL,
	[priceMode] [int] NULL DEFAULT (0),
	[price1] [decimal](25, 12) NULL DEFAULT (0),
	[price2] [decimal](25, 12) NULL DEFAULT (0),
	[aleat1] [decimal](25, 12) NULL DEFAULT (0),
	[aleat2] [decimal](25, 12) NULL DEFAULT (0),
	[per1] [decimal](25, 12) NULL DEFAULT (0),
	[intro1] [ntext] NULL,
	[intro2] [ntext] NULL,
	[intro3] [ntext] NULL,
	[date7] [datetime] NULL,
	[del] [int] NULL,
	[delcate] [int] NULL,
	[deldate] [datetime] NULL,
	[jf] [decimal](25, 12) NULL,
	[yxq] [int] NULL,
	[unit_yxq] [int] NULL,
	[num_tc] [decimal](25, 12) NULL,
	[pym] [nvarchar](500) NULL,
	[addcate] [int] NULL,
	[company] [int] NULL DEFAULT (0),
	[unitjb] [int] NULL,
	[zdy1] [nvarchar](200) NULL,
	[zdy2] [nvarchar](200) NULL,
	[zdy3] [nvarchar](200) NULL,
	[zdy4] [nvarchar](200) NULL,
	[zdy5] [int] NULL,
	[zdy6] [int] NULL,
	[num_sc] [decimal](25, 12) NULL DEFAULT (0),
	[User_List] [varchar](max) NULL,
    [period] [decimal](25, 12) NULL,
	[QC_id] [int] NULL,
	[invoiceTypes] varchar(2000) NULL,
	[includeTax] int not null default 0, 
	[canOutStore] int not null default 1, 
	[Roles] [varchar](20) NULL,			
	[PurchaleadDays] [int] NULL,
    [KuoutLimitExcess] [decimal](25, 12) NULL,	
    [LimitProduceNum] [decimal](25, 12) NULL,	
    [LimitBuyNum] [decimal](25, 12) NULL,	
    [LimitExcess] [decimal](25, 12) NULL,	
	[WastAge] [decimal](25, 12) NULL,	
	[SafeNum] [decimal](25, 12) NULL,	
	[ProduceleadDays] [int] NULL,		
	[extleadDays] [int] NULL,			
	[extleadNum] [decimal](25, 12) NULL,	
	[QualityType] [int] NULL,	
	[tcsort1] [int] NULL,		
	[tcsort2] [int] NULL,		
	[RemindNum] [decimal](25, 12) NULL, 
	[RemindUnit] [int] NULL DEFAULT (2), 
    [RemindPerson] [varchar](2000) NULL, 
    [MaintainNum] [decimal](25, 12),  
    [MaintainUnit] [int] NULL DEFAULT (2), 
	[phManage] [int] NULL,	
	[cpyxqNum] [FLOAT] NULL, 
	[cpyxqUnit] [int] NULL DEFAULT (2), 
    [uptime] [datetime] NULL,
    [upuser] [int] NULL,
    [import] [int] NULL,
    [InvoiceTitle] [nvarchar](100) NULL,
    [TaxPreference] [int] NULL DEFAULT (0),
    [TaxPreferenceType] [int] NULL,
    [TaxClassify] [int] NULL,
	[zdygroupid] int not null DEFAULT (0),
    PRIMARY KEY CLUSTERED
    (
        [ord] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]
 TEXTIMAGE_ON [PRIMARY]

--@##mode:index;clustered:false;fields:del,canOutStore
--@##mode:index;clustered:false;fields:ord,canOutStore
--@##mode:index;clustered:false;fields:Roles,canOutStore
--@##mode:index;clustered:false;fields:del,RemindNum;include:ord,RemindUnit
--@##mode:statistics;fields:del,canOutStore
--@##mode:statistics;fields:canOutStore,ord
--@##mode:statistics;fields:ord,del
--@##mode:statistics;fields:zdy5,zdy6,sort1
--@##mode:statistics;fields:date7,sort1,del
--@##mode:statistics;fields:canOutStore,sort1,del
--@##mode:statistics;fields:date7,del,canOutStore
--@##mode:statistics;fields:zdy5,zdy6,del,canOutStore
--@##mode:statistics;fields:del,sort1,zdy5,zdy6,date7

GO

--产品更新日志
CREATE TABLE [dbo].[product_log](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] null,
	[title] [nvarchar](500) NULL,
	[type1] [nvarchar](500) NULL,
	[sort1] [int] NULL,
	[unit] [nvarchar](500) NULL,
	[order1] [nvarchar](500) NULL,
	[priceMode] [int] NULL DEFAULT (0),
	[price1] [decimal](25, 12) NULL DEFAULT (0),
	[price2] [decimal](25, 12) NULL DEFAULT (0),
	[aleat1] [decimal](25, 12) NULL DEFAULT (0),
	[aleat2] [decimal](25, 12) NULL DEFAULT (0),
	[per1] [decimal](25, 12) NULL DEFAULT (0),
	[intro1] [ntext] NULL,
	[intro2] [ntext] NULL,
	[intro3] [ntext] NULL,
	[date7] [datetime] NULL,
	[del] [int] NULL,
	[delcate] [int] NULL,
	[deldate] [datetime] NULL,
	[jf] [decimal](25, 12) NULL,
	[yxq] [int] NULL,
	[unit_yxq] [int] NULL,
	[num_tc] [decimal](25, 12) NULL,
	[pym] [nvarchar](500) NULL,
	[addcate] [int] NULL,
	[company] [int] NULL DEFAULT (0),
	[unitjb] [int] NULL DEFAULT (0),
	[zdy1] [nvarchar](200) NULL,
	[zdy2] [nvarchar](200) NULL,
	[zdy3] [nvarchar](200) NULL,
	[zdy4] [nvarchar](200) NULL,
	[zdy5] [int] NULL,
	[zdy6] [int] NULL,
	[num_sc] [decimal](25, 12) NULL DEFAULT (0),
	[User_List] [varchar](max) NULL,
    [period] [decimal](25, 12) NULL,
	[QC_id] [int] NULL,
	[xgTime] [datetime] NULL,
	[xgOrd] [int] null,
	[ex_pid] [int] null,
	[mark] [int] NULL,
	[rememberlog] [nvarchar](2000) NULL,
	[invoiceTypes] varchar(2000) NULL,
	[includeTax] int not null default 0, 
	[canOutStore] int not null default 1, 
	[Roles] [varchar](20) NULL,			
	[PurchaleadDays] [int] NULL,
    [KuoutLimitExcess] [decimal](25, 12) NULL,	
    [LimitProduceNum] [decimal](25, 12) NULL,	
    [LimitBuyNum] [decimal](25, 12) NULL,	
    [LimitExcess] [decimal](25, 12) NULL,	
	[WastAge] [decimal](25, 12) NULL,	
	[SafeNum] [decimal](25, 12) NULL,	
	[ProduceleadDays] [int] NULL,		
	[extleadDays] [int] NULL,			
	[extleadNum] [decimal](25, 12) NULL,	
	[QualityType] [int] NULL,	
	[tcsort1] [int] NULL,		
	[tcsort2] [int] NULL,		
	[RemindNum] [decimal](25, 12) NULL, 
	[RemindUnit] [int] NULL DEFAULT (2), 
    [RemindPerson] [ntext] NULL, 
    [MaintainNum] [decimal](25, 12),  
    [MaintainUnit] [int] NULL DEFAULT (2),
    [phManage] [int] NULL,
    [cpyxqNum] [decimal](25, 12) NULL,
    [cpyxqUnit] [int] NULL,
    [InvoiceTitle] [nvarchar](100) NULL,
    [TaxPreference] [int] NULL DEFAULT (0),
    [TaxPreferenceType] [int] NULL,
    [TaxClassify] [int] NULL,
	[zdygroupid] int not null DEFAULT (0),
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]
 TEXTIMAGE_ON [PRIMARY]

GO

CREATE TABLE [dbo].[jiage_log](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[jgid] [int] null,
	[product] [int] NULL,
	[bm] [int] NULL,
	[unit] [int] NULL,
	[cgMainUnit] [int] NULL,
	[sort] [int] NULL,
	[bl] [decimal](25, 12) NULL,
	[txm] [nvarchar](50) NULL,
	[price1jy] [decimal](25, 12) NULL,
	[price1] [decimal](25, 12) NULL,
	[price2jy] [decimal](25, 12) NULL,
	[price2] [decimal](25, 12) NULL,
	[price3] [decimal](25, 12) NULL,
	[bl_old] [decimal](25, 12) NULL,
	[cgMainUnit_old] [int] NULL,
	[txm_old] [nvarchar](50) NULL,
	[price1jy_old] [decimal](25, 12) NULL,
	[price1_old] [decimal](25, 12) NULL,
	[price2jy_old] [decimal](25, 12) NULL,
	[price2_old] [decimal](25, 12) NULL,
	[price3_old] [decimal](25, 12) NULL,
	[xgTime] [datetime] NULL,
	[xgOrd] [int] null,
	[ex_pid] [int] null,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[O_officeType](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[pro_name] [varchar](200) NULL,
	[pro_type] [int] NULL DEFAULT (1),
	[pro_note] [text] NULL,
	[pro_gate2] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[O_LendBookmx](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Ld_fid] [int] NULL,
	[Ld_bkid] [int] NULL,
	[Ld_num] [int] NULL,
	[Ld_time] [datetime] NULL,
	[Ld_rettime] [datetime] NULL,
	[Ld_note] [ntext] NULL,
	[Ld_state] [int] NULL,
	[ModifyStamp] [varchar](200) NULL DEFAULT (1),
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[progress](
	[id] [int] NOT NULL,
	[ord] [int] NULL,
	[intro] [ntext] NULL,
	[gate] [int] NULL,
	[complete] [nvarchar](10) NULL,
	[date] [smalldatetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[payout3](
	[ord] [int] IDENTITY(1,1) NOT NULL,
	[money1] [decimal](25, 12) NOT NULL DEFAULT(0),
    [company] [int] NULL,
	[BH] [nvarchar](100) NULL,
	[Bz] int  NULL,
	[PlanDate] [datetime] NULL,
	[date1] [datetime] NULL,
	[date2] [datetime] NULL,
	[complete] [int] NULL,
	[CompleteType] [int] NOT NULL DEFAULT(1) ,
	[area] [int] NULL,
	[trade] [int] NULL,
	[pay] [int] NULL,
    [fromtype] [int] NULL,
    [frombillid] [int] NULL,
	[caigouth] [int] NULL,
	[cateid] [int] NULL,
	[cateid2] [int] NULL,
	[cateid3] [int] NULL,
	[addcate] [int] NULL,
	[addcate2] [int] NULL,
	[addcate3] [int] NULL,
	[bank] [int] NULL,
	[intro] [nvarchar](200) NULL,
	[del] [int] NULL,
	[delcate] [int] NULL,
	[deldate] [datetime] NULL,
	[date7] [datetime] NULL,
	[ModifyStamp] [varchar](30) NULL,
	[op] [int] NULL DEFAULT (0),
	[opdate] [datetime] NULL,
	[payout3] [varchar](2000) NULL,
	[SureId]  int null,
	[SureListId]  int null,
    PRIMARY KEY CLUSTERED
    (
        [ord] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[UniqueLoginPermitMAC](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[uid] [int] NOT NULL,
	[MAC] [varchar](50) NOT NULL,
	[datebegin] [datetime] NULL,
	[dateend] [datetime] NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[qxlb](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](50) NULL,
	[sort1] [int] NULL,
	[gate1] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[MobileAreaInfo](
	[shortno] [int] Not NULL,
	[areacode] [int] Not NULL,
	[addr]	[nvarchar](50) Not NULL,
	PRIMARY KEY CLUSTERED
	(
		[shortno] ASC
	) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[hf_QuestionLists](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[FiledID] [int] NULL,
	[MainID] [int] NULL,
	[answer] [varchar](500) NULL,
	[point] [decimal](25, 12) NULL,
	[Creator] [int] NULL,
	[Indate] [datetime] NULL,
	[Del] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[hr_off_staff](
	[id] [int] NOT NULL,
	[gateName] [varchar](50) NULL,
	[sorce] [int] NULL,
	[sorce2] [int] NULL,
	[sorceName] [varchar](50) NULL,
	[sorce2Name] [varchar](50) NULL,
	[postion] [varchar](50) NULL,
	[startTime] [datetime] NULL,
	[endTime] [datetime] NULL,
	[content] [text] NULL,
	[addcate] [int] NULL,
	[creator] [int] NULL,
	[status] [int] NULL,
	[indate] [datetime] NULL,
	[id_sp] [int] NULL,
	[cateid_sp] [int] NULL,
	[TempSave] [bit] NULL,
	[del] [int] NULL,
	[cateid] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[qxlblist](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](50) NULL,
	[sort] [int] NULL,
	[sort1] [int] NULL,
	[sort2] [int] NULL,
	[gate2] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[company](
	[ord] [int] IDENTITY(1,1) NOT NULL,
	[com_name] [nvarchar](100) NULL,
	[legal_per] [nvarchar](50) NULL,
	[set_time] [datetime] NULL,
	[capital] [nvarchar](50) NULL,
	[phone_Z] [nvarchar](50) NULL,
	[fax] [nvarchar](50) NULL,
	[address] [nvarchar](500) NULL,
	[intro] [ntext] NULL,
	[course] [ntext] NULL,
	[other] [ntext] NULL,
	[zip] [nvarchar](50) NULL,
	[email] [nvarchar](50) NULL,
    PRIMARY KEY CLUSTERED
    (
        [ord] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]
 TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[O_product](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[prod_name] [nvarchar](500) NULL,
	[prod_bh] [nvarchar](500) NULL,
	[prod_xh] [nvarchar](500) NULL,
	[prod_type] [int] NULL,
	[prod_unit] [nvarchar](30) NULL,
	[prod_price] [decimal](25, 12) NULL,
	[prod_gys] [nvarchar](200) NULL,
	[prod_more] [decimal](25, 12) NULL,
	[prod_less] [decimal](25, 12) NULL,
	[prod_note] [text] NULL,
	[zdy1] [nvarchar](200) NULL,
	[zdy2] [nvarchar](200) NULL,
	[zdy3] [nvarchar](200) NULL,
	[zdy4] [nvarchar](200) NULL,
	[zdy5] [int] NULL,
	[zdy6] [int] NULL,
	[prod_addtime] [datetime] NULL,
	[prod_addcateid] [int] NULL,
	[prod_del] [int] NULL DEFAULT (1),
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[Store_KuAllinOne](
	[recID] [int] IDENTITY(1,1) NOT NULL,
	[recTable] [varchar](50) NOT NULL,
	[recDate] [datetime] NOT NULL,
	[id] [int] NULL,
	[ord] [int] NULL,
	[title] [nvarchar](50) NULL,
	[order1] [int] NULL,
	[xlh] [nvarchar](100) NULL,
	[ck] [int] NULL,
	[ck1] [int] NULL,
	[ck2] [int] NULL,
	[unit] [int] NULL,
	[bz] [int] NULL,
	[num1] [decimal](25, 12) NULL,
	[num2] [decimal](25, 12) NULL,
	[price1] [decimal](25, 12) NULL,
	[money1] [decimal](25, 12) NULL,
	[ckbh] [nvarchar](50) NULL,
	[dbbh] [nvarchar](50) NULL,
	[jhbh] [nvarchar](50) NULL,
	[rkbh] [nvarchar](50) NULL,
	[pdbh] [nvarchar](50) NULL,
	[sort] [int] NULL,
	[sort1] [int] NULL,
	[caigou] [int] NULL,
	[caigoulist] [int] NULL,
	[kuinlist] [int] NULL,
	[zzid] [nvarchar](50) NULL,
	[cateid] [int] NULL,
	[cateid2] [int] NULL,
	[cateid3] [int] NULL,
	[catein] [int] NULL,
	[cateout] [nvarchar](50) NULL,
	[complete1] [int] NULL,
	[complete2] [int] NULL,
	[complete3] [int] NULL,
	[date3] [datetime] NULL,
	[date5] [datetime] NULL,
	[date7] [datetime] NULL,
	[datein] [datetime] NULL,
	[dateout] [datetime] NULL,
	[daterk] [datetime] NULL,
	[datesc] [datetime] NULL,
	[dateyx] [datetime] NULL,
	[deldate] [datetime] NULL,
	[del] [int] NULL,
	[delcate] [int] NULL,
	[fh1] [int] NULL,
	[gys] [int] NULL,
	[intro] [ntext] NULL,
	[intro1] [nvarchar](50) NULL,
	[intro2] [nvarchar](50) NULL,
	[js] [decimal](18, 0) NULL,
	[kg] [int] NULL,
	[ph] [nvarchar](50) NULL,
	[zdy1] [nvarchar](200) NULL,
	[zdy2] [nvarchar](200) NULL,
	[zdy3] [nvarchar](200) NULL,
	[zdy4] [nvarchar](200) NULL,
	[zdy5] [int] NULL,
	[zdy6] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[recID] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[O_RetBook](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[free1] [int] NULL,
	[free2] [varchar](3000) NULL,
	[addcateid] [int] NULL,
	[addtime] [datetime] NULL,
	[del] [int] NULL,
	[ModifyStamp] [varchar](200) NULL DEFAULT (1),
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[reply](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NULL,
	[ord2] [int] NULL,
	[sort1] [int] NULL,
	[sort98] [int] NULL, --跟进分类,sortonehy.gate2=98
	[gj1] [int] NULL,
	[gj2] [int] NULL,
	[name] [nvarchar](50) NULL,
	[name2] [nvarchar](50) NULL,
	[intro] [ntext] NULL,
	[plan1] [int] NULL,
	[cateid] [int] NULL,
	[cateid2] [int] NULL,
	[cateid3] [int] NULL,
	[time1] [int] NULL,
	[date7] [datetime] NULL,
	[del] [int] NULL DEFAULT (1),
	[delcate] [int] NULL,
	[deldate] [datetime] NULL,
	[id1] [int] NULL,
	[chance] [int] NULL,
	[company] [nvarchar](100) NULL,
	[share] [nvarchar](1000) NULL,
	[uploadfile] [nvarchar](500) Null, --上传附件地址
	[title] [nvarchar](200) NULL,
	[reminders] [varchar](8000) NULL ,
    [alt] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


--@##mode:index;clustered:false;fields:ord,sort1,ord2,cateid,del,date7 desc
--@##mode:index;clustered:false;fields:plan1 desc
--@##mode:statistics;fields:ord,del
--@##mode:statistics;fields:sort1,del
--@##mode:statistics;fields:date7,ord,del
--@##mode:statistics;fields:id,ord,cateid
--@##mode:statistics;fields:cateid2,del,sort1
--@##mode:statistics;fields:id,sort1,ord
--@##mode:statistics;fields:ord,cateid,del
--@##mode:statistics;fields:id,sort1,del
--@##mode:statistics;fields:ord2,sort1,del
--@##mode:statistics;fields:ord,cateid,sort1
--@##mode:statistics;fields:ord,cateid2,sort1
--@##mode:statistics;fields:id,ord,del,date7
--@##mode:statistics;fields:ord,cateid2,del,sort1
--@##mode:statistics;fields:date7,ord2,sort1,del
--@##mode:statistics;fields:cateid,sort1,del,ord
--@##mode:statistics;fields:cateid,del,id,ord
--@##mode:statistics;fields:date7,sort1,ord,del
--@##mode:statistics;fields:sort1,ord,del,id,date7
--@##mode:statistics;fields:cateid,del,sort1,id,ord

GO
CREATE TABLE [dbo].[jobType](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[jobName] [nvarchar](100) NULL,
	[priority] [char](10) NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[M_MachineInfo](
	[ID] [int] NOT NULL,
	[PrefixCode] [nvarchar](2) NULL,
	[sn] [varchar](50) NULL,
	[name] [varchar](100) NULL,
	[cls] [varchar](50) NULL,
	[type] [varchar](50) NULL,
	[wTime] [decimal](25, 12) NULL,
	[mec] [decimal](25, 12) NULL,
	[Period] [decimal](25, 12) NULL,
	[remark] [ntext] NULL,
	[del] [int] NOT NULL,
	[Creator] [int] NOT NULL,
	[indate] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]

--@##mode:index;clustered:false;fields:Creator
--@##mode:index;clustered:false;fields:indate desc

GO
CREATE TABLE [dbo].[reply2](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NULL,
	[name] [nvarchar](50) NULL,
	[intro] [nvarchar](1000) NULL,
	[plan1] [int] NULL,
	[date7] [datetime] NULL,
	[del] [int] NULL DEFAULT (1),
	[ord2] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[M_WFProduct](
	[xid] [int] IDENTITY(1,1) NOT NULL,
	[WFID] [int] NOT NULL,
	[POrd] [int] NOT NULL,
	[unit] [int] NOT NULL,
	[remark] [varchar](200) NULL,
	[del] [int] NOT NULL,
PRIMARY KEY CLUSTERED
(
	[POrd] ASC,
	[unit] ASC,
	[WFID] ASC
) ON [PRIMARY]
) ON [PRIMARY]

--@##mode:index;clustered:true;fields:xid
--@##mode:index;clustered:false;fields:WFID
--@##mode:index;clustered:false;fields:POrd
--@##mode:index;clustered:false;fields:unit

GO
CREATE TABLE [dbo].[job](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NULL,
	[jobName] [nvarchar](100) NULL,
	[priority] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[Store_KuListAllinOne](
	[recID] [int] IDENTITY(1,1) NOT NULL,
	[recTable] [varchar](50) NOT NULL,
	[recDate] [datetime] NOT NULL,
	[order1] [int] NULL,
	[price1] [nvarchar](100) NULL,
	[price2] [decimal](25, 12) NULL,
	[money1] [decimal](25, 12) NULL,
	[unit] [int] NULL,
	[num1] [decimal](25, 12) NULL,
	[num2] [decimal](25, 12) NULL,
	[num3] [decimal](25, 12) NULL,
	[num4] [decimal](25, 12) NULL,
	[addcate] [int] NULL,
	[alt] [int] NULL,
	[area] [int] NULL,
	[bz] [int] NULL,
	[caigou] [int] NULL,
	[caigoulist] [int] NULL,
	[cateid] [int] NULL,
	[cateid2] [int] NULL,
	[cateid3] [int] NULL,
	[ck] [int] NULL,
	[ck1] [int] NULL,
	[ck2] [int] NULL,
	[ckid] [int] NULL,
	[company] [int] NULL,
	[contract] [int] NULL,
	[contractlist] [int] NULL,
	[date1] [datetime] NULL,
	[date2] [datetime] NULL,
	[date3] [datetime] NULL,
	[date7] [datetime] NULL,
	[dateadd] [datetime] NULL,
	[datesc] [datetime] NULL,
	[dateyx] [datetime] NULL,
	[gys] [int] NULL,
	[id] [int] NULL,
	[intro] [nvarchar](100) NULL,
	[jhid] [int] NULL,
	[js] [nvarchar](50) NULL,
	[ku] [int] NULL,
	[ku2] [int] NULL,
	[kuhh] [int] NULL,
	[kuin] [int] NULL,
	[kuinlist] [int] NULL,
	[kujh] [int] NULL,
	[kumove] [int] NULL,
	[kuout] [int] NULL,
	[kuoutlist] [int] NULL,
	[kuzz] [int] NULL,
	[mxid] [int] NULL,
	[pd] [int] NULL,
	[ph] [nvarchar](50) NULL,
	[sort] [int] NULL,
	[sort1] [int] NULL,
	[trade] [int] NULL,
	[xlh] [nvarchar](100) NULL,
	[del] [int] NULL,
	[isMinus] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[recID] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[erp_sys_temp_cptree](
	[自动编号] [int] IDENTITY(1,1) NOT NULL,
	[仓库分类排序] [int] NULL,
	[仓库名称排序] [int] NULL,
	[仓库分类] [nvarchar](50) NULL,
	[仓库] [nvarchar](50) NULL,
	[路径] [varchar](3) NOT NULL,
	[产品子分类Id] [int] NOT NULL,
	[产品子分类名称] [varchar](2) NOT NULL,
	[产品名称] [nvarchar](100) NULL,
	[产品编号] [nvarchar](50) NULL,
	[产品型号] [nvarchar](50) NULL,
	[拼音码] [nvarchar](100) NULL,
	[产品ID] [int] NOT NULL,
	[仓库ID] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [自动编号] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[replybj](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NULL,
	[name] [nvarchar](50) NULL,
	[intro] [nvarchar](500) NULL,
	[date7] [datetime] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[O_store](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[sto_name] [varchar](200) NULL,
	[sto_state] [int] NULL,
	[sto_note] [text] NULL,
	[sto_intro] [varchar](5000) NULL,
	[sto_gate2] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]
 TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[hf_Template](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Title] [varchar](100) NULL,
	[Used] [bit] NULL,
	[InDate] [datetime] NULL,
	[Creator] [int] NULL,
	[Del] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[O_RetBookmx](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Ret_fid] [char](10) NULL,
	[Ret_bkid] [int] NULL,
	[Ret_num] [int] NULL,
	[Ret_time] [datetime] NULL,
	[Ret_isBreak] [int] NULL,
	[Ret_note] [ntext] NULL,
	[ModifyStamp] [varchar](200) NULL DEFAULT (1),
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[O_assSetRepair](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[set_name] [varchar](200) NULL,
	[set_sort] [int] NULL,
	[set_note] [varchar](2000) NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[hr_person_edu](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[personID] [int] NULL,
	[eduName] [varchar](100) NULL,
	[prof] [varchar](100) NULL,
	[college] [varchar](100) NULL,
	[del] [int] NULL,
	[startdate] [datetime] NULL,
	[enddate] [datetime] NULL,
	[remark] [text] NULL,
	[indate] [datetime] NULL,
	[creator] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[replyds](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NULL,
	[intro] [nvarchar](2000) NULL,
	[name] [nvarchar](50) NULL,
	[date7] [datetime] NULL,
	[cateid] [int] NULL,
	[del] [int] NULL,
	[delcate] [int] NULL,
	[deldate] [datetime] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[O_kuIn](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[reg_name] [nvarchar](500) NULL,
	[reg_userid] [int] NULL,
	[reg_time] [datetime] NULL,
	[reg_note] [text] NULL,
	[reg_addtime] [datetime] NULL,
	[reg_addcateid] [int] NULL,
	[reg_del] [int] NULL DEFAULT (1),
	[ModifyStamp] [varchar](200) NULL DEFAULT (1),
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[Store_ChangeLog](
	[LogID] [int] IDENTITY(1,1) NOT NULL,
	[OpType] [int] NOT NULL,
	[TableName] [nvarchar](50) NOT NULL,
	[OrderID] [int] NOT NULL,
	[ProductID] [int] NOT NULL,
	[ProductName] [nvarchar](500) NOT NULL,
	[ProductOrder] [nvarchar](500) NULL,
	[ProductType] [nvarchar](500) NOT NULL,
	[ProductUnit] [nvarchar](500) NOT NULL,
	[ProductUnitName] [nvarchar](10) NOT NULL,
	[KuID] [int] NULL,
	[StoreID] [int] NOT NULL,
	[StoreInOrOut] [int] NOT NULL,
	[StoreNumNow] [decimal](25, 12) NULL,
	[StoreNumChange] [decimal](25, 12) NULL,
	[StoreNumNew] [decimal](25, 12) NULL,
	[StoreMoneyNow] [decimal](25, 12) NOT NULL,
	[StoreMoneyChange] [decimal](25, 12) NULL,
	[StoreMoneyNew] [decimal](25, 12) NULL,
	[OperatorID] [int] NOT NULL,
	[OperatorIP] [nvarchar](30) NOT NULL,
	[OpDate] [datetime] NOT NULL,
    [listID] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[LogID] ASC
) ON [PRIMARY]
) ON [PRIMARY]

--@##mode:index;clustered:false;fields:listID
--@##mode:index;clustered:false;fields:OpType;include:ProductName,ProductOrder,ProductType,ProductUnit,KuID,StoreID,OperatorID,OpDate

GO
CREATE TABLE [dbo].[zbsvr_tempHttpRequest](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[url] [varchar](80) NULL,
	[postdata] [varchar](2000) NULL,
	[result] [text] NULL,
	[sendtime] [datetime] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]
 TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[replyfw](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NULL,
	[name] [nvarchar](50) NULL,
	[intro] [nvarchar](500) NULL,
	[date7] [datetime] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[M_MRequest](
	[ID] [int] NOT NULL,
	[prefixCode] [varchar](2) NOT NULL,
	[creator] [int] NOT NULL,
	[indate] [datetime] NOT NULL,
	[RefCaigou] [bit] NULL,
	[remark] [ntext] NOT NULL,
	[del] [int] NULL,
	[status] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]

--@##mode:index;clustered:false;fields:creator
--@##mode:index;clustered:false;fields:indate desc
--@##mode:index;clustered:false;fields:RefCaigou

GO
CREATE TABLE [dbo].[O_assSetFont](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[set_name] [varchar](200) NULL,
	[set_sort] [int] NULL,
	[set_note] [varchar](2000) NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[replyhd](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NULL,
	[userID] [int] NULL,
	[name] [nvarchar](50) NULL,
	[intro] [ntext] NULL,
	[date7] [datetime] NULL,
	[alt] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]
 TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[f_pay](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[title] [nvarchar](200) NULL,
	[datejk] [datetime] NULL,
	[sorce] [varchar](50) NULL,
	[sorce1] [varchar](50) NULL,
	[sorce2] [int] NULL,
	[bz] [int] NULL DEFAULT (14),
	[date7] [datetime] NULL,
	[bx] [int] NULL DEFAULT (0),
	[sp] [int] NULL,
	[cateid_sp] [int] NULL,
	[deldate] [datetime] NULL,
	[addcate] [varchar](20) NULL,
	[del] [int] NULL,
	[sqid] [int] NOT NULL DEFAULT (0),
	[intro] [ntext] NULL,
	[money1] [decimal](25, 12) NOT NULL DEFAULT (0),
	[num] [int] NOT NULL DEFAULT (0),
	[delcate] [int] NOT NULL DEFAULT (0),
	[yid] [int] NULL,
	[qttype] [varchar](20) NULL
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

--@##mode:statistics;fields:date7,del
--@##mode:statistics;fields:id,date7,del

GO
CREATE TABLE [dbo].[his_scl](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[LogID] [int] NOT NULL,
	[OpType] [int] NOT NULL,
	[TableName] [nvarchar](50) NOT NULL,
	[OrderID] [int] NOT NULL,
	[ProductID] [int] NOT NULL,
	[ProductName] [nvarchar](100) NOT NULL,
	[ProductOrder] [nvarchar](100) NULL,
	[ProductType] [nvarchar](100) NOT NULL,
	[ProductUnit] [nvarchar](10) NOT NULL,
	[ProductUnitName] [nvarchar](10) NOT NULL,
	[KuID] [int] NULL,
	[StoreID] [int] NOT NULL,
	[StoreInOrOut] [int] NOT NULL,
	[StoreNumNow] [decimal](25, 12) NOT NULL,
	[StoreNumChange] [decimal](25, 12) NOT NULL,
	[StoreNumNew] [decimal](25, 12) NOT NULL,
	[StoreMoneyNow] [decimal](25, 12) NOT NULL,
	[StoreMoneyChange] [decimal](25, 12) NULL,
	[StoreMoneyNew] [decimal](25, 12) NULL,
	[OperatorID] [int] NOT NULL,
	[OperatorIP] [nvarchar](30) NOT NULL,
	[OpDate] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[O_ChkBook](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[chk_title] [varchar](500) NULL,
	[chk_time] [datetime] NULL,
	[chk_cateid] [int] NULL,
	[chk_note] [ntext] NULL,
	[chk_addcateid] [int] NULL,
	[chk_addtime] [datetime] NULL,
	[chk_del] [int] NULL,
	[ModifyStamp] [varchar](200) NULL DEFAULT (1),
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[replyht](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NULL,
	[name] [nvarchar](50) NULL,
	[intro] [nvarchar](500) NULL,
	[plan1] [int] NULL,
	[date7] [datetime] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[hf_TemplateList](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[MainID] [int] NULL,
	[QuestionID] [int] NULL,
	[InDate] [datetime] NULL,
	[Creator] [int] NULL,
	[Del] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[O_assSetMethod](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[set_name] [varchar](200) NULL,
	[set_sort] [int] NULL,
	[set_note] [varchar](4000) NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[hr_person_language](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[personID] [int] NULL,
	[flanguage] [varchar](100) NULL,
	[lv] [varchar](50) NULL,
	[content] [varchar](500) NULL,
	[del] [int] NULL,
	[zhengshu] [varchar](100) NULL,
	[bfdate] [datetime] NULL,
	[jigou] [varchar](100) NULL,
	[indate] [datetime] NULL,
	[creator] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[replyjh](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NULL,
	[name] [nvarchar](50) NULL,
	[intro] [nvarchar](4000) NULL,
	[plan1] [int] NULL,
	[date7] [datetime] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[O_kuInList](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[reg_fid] [int] NULL,
	[prod_id] [int] NULL,
	[prod_unit] [varchar](200) NULL,
	[prod_price] [decimal](25, 12) NULL,
	[prod_num] [decimal](25, 12) NULL,
	[prod_allnum] [decimal](25, 12) NULL,
	[prod_allmoney] [decimal](25, 12) NULL,
	[sto_id] [int] NULL,
	[reg_gztime] [datetime] NULL,
	[prod_gys] [varchar](200) NULL,
	[prod_ph] [varchar](200) NULL,
	[prod_xlh] [varchar](200) NULL,
	[prod_sctime] [datetime] NULL,
	[prod_ystime] [datetime] NULL,
	[reg_intro] [text] NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[Store_OpTypeDefine](
	[typeId] [int] NOT NULL,
	[OpTypeName] [nvarchar](20) NOT NULL,
PRIMARY KEY CLUSTERED
(
	[typeId] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[replyre](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NULL,
	[name] [nvarchar](50) NULL,
	[intro] [nvarchar](500) NULL,
	[date7] [datetime] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[O_ChkBookmx](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Chk_fid] [int] NULL,
	[Chk_bkid] [int] NULL,
	[Chk_sjnum] [int] NULL,
	[Chk_pdnum] [int] NULL,
	[Chk_yknum] [int] NULL,
	[Chk_note1] [ntext] NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[O_assSetname](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NULL,
	[sort1] [nvarchar](50) NULL,
	[intro] [varchar](2000) NULL,
	[gate1] [int] NULL,
	[ls] [int] NULL DEFAULT (0),
	[sort] [int] NULL,
	[del] [int] NULL DEFAULT (1),
	[StoreCode] [varchar](50) NULL,
	[StoreComment] [varchar](500) NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[replyts](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NULL,
	[name] [nvarchar](50) NULL,
	[intro] [nvarchar](500) NULL,
	[date7] [datetime] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[paywipe](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[typeid] [int] NULL,
	[deptid] [varchar](50) NULL,
	[money1] [decimal](25, 12) NULL,
	[rate] [varchar](20) NULL,
	[bz] [int] NULL DEFAULT (0),
	[cycle] [varchar](20) NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[O_productOut](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[get_title] [varchar](500) NULL,
	[get_bh] [varchar](500) NULL,
	[get_lycateid] [int] NULL,
	[get_type] [int] NULL,
	[get_store] [int] NULL,
	[get_storecateid] [int] NULL,
	[get_storetime] [datetime] NULL,
	[get_Chnote] [varchar](500) NULL,
	[get_time] [datetime] NULL,
	[get_note] [text] NULL,
	[get_addcateid] [int] NULL,
	[get_addtime] [datetime] NULL,
	[get_del] [int] NULL DEFAULT (1),
	[ModifyStamp] [varchar](200) NULL DEFAULT (1),
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[replyxm](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NULL,
	[name] [nvarchar](50) NULL,
	[intro] [nvarchar](500) NULL,
	[date7] [datetime] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[hf_config](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Title] [varchar](100) NULL,
	[SQLTemplate] [int] NULL,
	[Used] [bit] NULL,
	[EffectiveTime] [datetime] NULL,
	[Indate] [datetime] NULL,
	[creator] [int] NULL,
	[del] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[O_BookLog](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[bookname] [varchar](2000) NULL,
	[bookid] [int] NULL,
	[booktype] [varchar](2000) NULL,
	[auther] [varchar](500) NULL,
	[ISBN] [varchar](2000) NULL,
	[publishingtime] [datetime] NULL,
	[djtytpe] [int] NULL,
	[djtime] [datetime] NULL,
	[cztime] [datetime] NULL,
	[sjnum] [int] NULL,
	[dbnum] [int] NULL,
	[xynum] [int] NULL,
	[djid] [int] NULL,
	[addcateid] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[returnbz](
	[intro1] [ntext] NULL,
	[intro2] [ntext] NULL,
	[intro3] [ntext] NULL,
	[intro4] [ntext] NULL,
	[intro5] [ntext] NULL,
	[intro6] [ntext] NULL,
	[returned] [int] NULL,
	[date7] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[M_OutOrderlists](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[outID] [int] NOT NULL,
	[productid] [int] NOT NULL,
	[unit1] [int] NOT NULL,
	[num1] [decimal](25, 12) NOT NULL DEFAULT (0),
	[unit2] [int] NULL,
	[num2] [decimal](25, 12) NULL,
	[hcdate] [datetime] NOT NULL,
	[price] [decimal](25, 12) NOT NULL DEFAULT (0),
	[money1] [decimal](25, 12) NOT NULL DEFAULT (0),
	[molist] [int] NOT NULL,
	[remark] [varchar](200) NULL,
	[del] [int] NOT NULL DEFAULT (0),
PRIMARY KEY CLUSTERED
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]

--@##mode:index;clustered:false;fields:outID
--@##mode:index;clustered:false;fields:productid
--@##mode:index;clustered:false;fields:unit1
--@##mode:index;clustered:false;fields:unit2
--@##mode:index;clustered:false;fields:hcdate
--@##mode:index;clustered:false;fields:molist

GO
CREATE TABLE [dbo].[home_TopMenus](
	[ord] [int] NOT NULL,
	[MenuID] [int] NOT NULL,
	[title] [varchar](200) NOT NULL,
	[sort] [int] NOT NULL,
	[url] [varchar](300) NOT NULL,
	[uid] [int] NOT NULL,
	[addtime] [datetime] NOT NULL,
	[hide] [int] NOT NULL,
	[remark] [varchar](200) NOT NULL,
PRIMARY KEY CLUSTERED
(
	[ord] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[returned](
	[ord] [int] IDENTITY(1,1) NOT NULL,
	[title] [nvarchar](50) NULL,
	[sort] [int] NULL,
	[complete1] [int] NULL,
	[money1] [decimal](25, 12) NULL,
	[date1] [datetime] NULL,
	[person1] [nvarchar](50) NULL,
	[person2] [nvarchar](50) NULL,
	[intro] [ntext] NULL,
	[area] [int] NULL,
	[trade] [int] NULL,
	[cateid] [int] NULL,
	[cateid2] [int] NULL,
	[cateid3] [int] NULL,
	[addcate] [int] NULL,
	[addcate2] [int] NULL,
	[addcate3] [int] NULL,
	[company] [int] NULL,
	[person] [int] NULL,
	[del] [int] NULL,
	[delcate] [int] NULL,
	[deldate] [datetime] NULL,
	[zt1] [int] NULL DEFAULT (0),
	[date7] [datetime] NULL,
    PRIMARY KEY CLUSTERED
    (
        [ord] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]
 TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[payjk](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[title] [varchar](200) NULL,
	[bh] [varchar](100) NULL,
	[datejk] [datetime] NULL,
	[sorce] [int] NULL,
	[sorce1] [int] NULL,
	[sorce2] [int] NULL,
	[allmoney] [decimal](25, 12) NULL,
	[note] [ntext] NULL,
	[payid] [int] NULL,
	[money1] [decimal](25, 12) NULL,
	[note1] [nvarchar](500) NULL,
	[jktype] [int] NULL,
	[bz] [int] NULL DEFAULT (14),
	[tel] [varchar](20) NULL,
	[person] [varchar](20) NULL,
	[chance] [varchar](20) NULL,
	[contract] [varchar](20) NULL,
	[shouhou] [varchar](20) NULL,
	[richeng] [varchar](20) NULL,
	[fahuo] [varchar](20) NULL,
	[caigou] [varchar](20) NULL,
	[iwork] [varchar](20) NULL,
	[date7] [datetime] NULL,
	[deldate] [datetime] NULL,
	[addcate] [int] NULL,
	[delcate] [int] NULL,
	[sp] [int] NULL,
	[del] [int] NULL,
	[spmoney] [decimal](25, 12) NULL,
	[spstate] [varchar](50) NULL,
	[sp_id] [int] NULL,
	[gate_sp] [varchar](50) NULL,
	[date1] [datetime] NULL,
	[sqid] [int] NOT NULL DEFAULT (80),
	[ModifyStamp] [varchar](30) NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]
 TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[O_BookField](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](200) NULL,
	[setopen] [int] NULL DEFAULT (1),
	[sort1] [int] NULL DEFAULT (1),
	[setsort] [int] NULL DEFAULT (1),
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[M_WCMacList](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[WCID] [int] NOT NULL,
	[MCID] [int] NOT NULL,
	[num] [decimal](25, 12) NULL,
	[remark] [varchar](200) NULL,
PRIMARY KEY CLUSTERED
(
	[WCID] ASC,
	[MCID] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[O_assSetType](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[sort1] [nvarchar](50) NULL,
	[gate1] [int] NULL,
	[del] [int] NULL DEFAULT (1),
	[ParentID] [int] NOT NULL DEFAULT (0),
	[StoreCode] [varchar](50) NULL,
	[Depth] [int] NOT NULL DEFAULT (0),
	[isLeef] [bit] NOT NULL DEFAULT (1),
	[RootID] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[returnlist](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NULL,
	[price1] [nvarchar](50) NULL,
	[num1] [decimal](25, 12) NULL,
	[money1] [nvarchar](50) NULL,
	[num2] [decimal](25, 12) NULL,
	[num3] [decimal](25, 12) NULL,
	[returned] [int] NULL,
	[area] [int] NULL,
	[trade] [int] NULL,
	[cateid] [int] NULL,
	[cateid2] [int] NULL,
	[cateid3] [int] NULL,
	[date1] [datetime] NULL,
	[date7] [datetime] NULL,
	[del] [int] NULL,
	[delcate] [int] NULL,
	[deldate] [datetime] NULL,
	[company] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[M_Identity](
	[id] [int] NOT NULL
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[O_proOutList](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[get_fid] [int] NULL,
	[prod_id] [int] NULL,
	[get_num] [decimal](25, 12) NULL,
	[sto_id] [int] NULL,
	[ret_state] [int] NOT NULL DEFAULT (1),
	[sto_type] [int] NULL,
	[get_intro] [varchar](2000) NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[M_WWQCList](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[QCID] [int] NOT NULL,
	[productID] [int] NULL,
	[unit1] [int] NULL,
	[unit2] [int] NULL,
	[num1] [decimal](25, 12) NULL,
	[num2] [decimal](25, 12) NULL,
	[numOK1] [decimal](25, 12) NULL,
	[numOk2] [decimal](25, 12) NULL,
	[remark] [varchar](200) NULL,
	[wwlistid] [int] NOT NULL,
PRIMARY KEY CLUSTERED
(
	[ID] ASC,
	[QCID] ASC
) ON [PRIMARY]
) ON [PRIMARY]

--@##mode:index;clustered:false;fields:QCID
--@##mode:index;clustered:false;fields:productID
--@##mode:index;clustered:false;fields:unit1
--@##mode:index;clustered:false;fields:unit2
--@##mode:index;clustered:false;fields:wwlistid

GO
CREATE TABLE [dbo].[hr_plan_list](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[planID] [int] NULL,
	[sorce] [int] NULL,
	[sorce2] [int] NULL,
	[postion] [int] NULL,
	[num] [int] NULL,
	[needDate] [datetime] NULL,
	[content] [text] NULL,
	[belongID] [int] NULL,
	[status] [int] NULL,
	[source] [int] NULL,
	[creator] [int] NULL,
	[id_sp] [int] NULL,
	[cateid_sp] [int] NULL,
	[TempSave] [bit] NULL,
	[indate] [datetime] NULL,
	[del] [int] NOT NULL,
	[appid] [int] NULL,
	[HadNum] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

CREATE TABLE [dbo].[send](
	[ord] [int] IDENTITY(1,1) NOT NULL,
	[title] [nvarchar](100) NULL,
	[code] [nvarchar](50) NULL,
	[name] [nvarchar](50) NULL,
	[sort] [nvarchar](50) NULL,
	[address] [nvarchar](500) NULL,
	[date1] [datetime] NULL,
	[date2] [datetime] NULL,
	[complete1] [nvarchar](50) NULL DEFAULT (0),
	[intro] [nvarchar](500) NULL,
	[company] [int] NULL DEFAULT (0),
	[order1] [int] NULL DEFAULT (0),
	[kuout] [int] NULL,
	[area] [int] NULL,
	[trade] [int] NULL,
	[cateid] [int] NULL,
	[cateid2] [int] NULL,
	[cateid3] [int] NULL,
	[addcate] [int] NULL,
	[del] [int] NULL,
	[delcate] [int] NULL,
	[deldate] [datetime] NULL,
	[date7] [datetime] NULL,
	[zdy1] [nvarchar](50) NULL,
	[zdy2] [nvarchar](50) NULL,
	[zdy3] [nvarchar](50) NULL,
	[zdy4] [nvarchar](50) NULL,
	[zdy5] [int] NULL,
	[zdy6] [int] NULL,
	[intro1] [ntext] NULL,
	[intro2] [ntext] NULL,
	[intro3] [ntext] NULL,
	[intro4] [ntext] NULL,
	[intro5] [ntext] NULL,
	[intro6] [ntext] NULL,
	[sh] [int] NULL DEFAULT (0),
	[ModifyStamp] [varchar](30) NULL,
	[alt] [int] NULL,
	[address2] [nvarchar](200) NULL,
	[receiver] nvarchar(50),--收货人
	[phone] nvarchar(50),--固话
	[mobile] nvarchar(50),--手机
	[zip] nvarchar(50),--邮编
	[areaId][int],--地址，关联manuarea.id
	[ECID] [int], --快递公司ID
	[ExpressCompany] VARCHAR(50), --快递公司CODE
	[WaybillNumber] VARCHAR(50),  --快递单号
	[WayMoney] [decimal](25, 12) NULL,	--快递费用
	[LogisticsFailReason] NVARCHAR(50), --查询物流失败原因
	[WayTime] [datetime] NULL,	--物流信息获取时间,
    PRIMARY KEY CLUSTERED
    (
        [ord] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


--@##mode:index;clustered:true;fields:date2
--@##mode:index;clustered:false;fields:ord
--@##mode:index;clustered:false;fields:kuout
--@##mode:index;clustered:false;fields:cateid
--@##mode:index;clustered:false;fields:addcate
--@##mode:index;clustered:false;fields:company
--@##mode:index;clustered:false;fields:order1
--@##mode:statistics;fields:date7,company
--@##mode:statistics;fields:order1,del
--@##mode:statistics;fields:date7,order1,del
--@##mode:statistics;fields:company,del,date7

GO

CREATE TABLE [dbo].[ku_back](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NULL,
	[num1] [decimal](25, 12) NULL DEFAULT (0),
	[ck] [int] NULL,
	[price1] [decimal](25, 12) NULL,
	[money1] [decimal](25, 12) NULL,
	[unit] [int] NULL,
	[ph] [nvarchar](50) NULL,
	[xlh] [nvarchar](100) NULL,
	[datesc] [datetime] NULL,
	[dateyx] [datetime] NULL,
	[bz] [int] NULL,
	[js] [decimal](25, 12) NULL,
	[intro] [nvarchar](500) NULL,
	[caigoulist] [int] NULL,
	[gys] [int] NULL,
	[kuinlist] [int] NULL,
	[num2] [decimal](25, 12) NULL,
	[daterk] [datetime] NULL,
	[Status] [int] NULL,
	[num3] [decimal](25, 12) NULL,
	[date2] [datetime] NULL,
	[caigoulist2] [int] NULL,
	[alt] [int] NULL,
	[locked] [int] NULL,
	[locknum] [int] NULL,
	[unRemind] [varchar](2000) NULL,
	[backUpDate] [datetime] NULL,
	[ku_id] [int] NULL,
	[b_ip] [varchar](50) NULL,
	[b_cateid] [int] NULL,
	[b_model] [int] NULL,
	[ProductAttr1] int null,
	[ProductAttr2] int null,
	[ProductAttrBatchId] int null,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


--@##mode:index;clustered:false;fields:id;include:[ord],[ck],[money1],[unit],[num2],[num3],[locknum]
GO
CREATE TABLE [dbo].[hf_configList](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Title] [varchar](100) NULL,
	[IsBase] [bit] NULL,
	[MainID] [int] NULL,
	[datenum] [int] NULL,
	[unit] [int] NULL,
	[Template] [int] NULL,
	[user_list] [varchar](4000) NULL,
	[Indate] [datetime] NULL,
	[Creator] [int] NULL,
	[Del] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[sendlist](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NULL,
	[price1] [nvarchar](200) NULL DEFAULT (''),--实为备注字段
	[num1] [decimal](25, 12) NOT NULL DEFAULT (0),
	[send] [int] NULL,
	[order1] [int] NULL,
	[kuout] [int] NULL,
	[complete1] [int] NULL,
	[del] [int] NULL,
	[dateadd] [datetime] NULL,
	[date7] [datetime] NULL,
	[bz] [int] NULL,
	[js] [nvarchar](50) NULL,
	[ph] [nvarchar](50) NULL,
	[xlh] [nvarchar](100) NULL,
	[datesc] [datetime] NULL,
	[dateyx] [datetime] NULL,
	[unit] [int] NOT NULL DEFAULT (0),
	[company] [int] NULL,
	[ck] [int] NULL,
	[contractlist] [int] NULL,
    [KuoutApplyID] [int] NULL,
	[kuoutlist] [int] NULL,
	[zdy1] [nvarchar](200) NULL,
	[zdy2] [nvarchar](200) NULL,
	[zdy3] [nvarchar](200) NULL,
	[zdy4] [nvarchar](200) NULL,
	[zdy5] [int] NULL,
	[zdy6] [int] NULL,
	[ProductAttr1] int null,
	[ProductAttr2] int null,
	[ProductAttrBatchId] int null,
    [CKAccStatus] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


--@##mode:index;clustered:true;fields:complete1,del,dateadd
--@##mode:index;clustered:false;fields:contractlist
--@##mode:index;clustered:false;fields:id

GO
CREATE TABLE [dbo].[paytype](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[sort1] [nvarchar](50) NULL,
	[sort2] [int] NULL,
	[gate2] [int] NULL,
	[sid] [int] NOT NULL DEFAULT (80),
	[del] [int] NULL DEFAULT (1),
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[home_usConfig](
	[name] [varchar](500) NOT NULL,
	[nvalue] [float] NULL,
	[tvalue] [nvarchar](max) NULL,
	[uid] [int] NOT NULL,
PRIMARY KEY CLUSTERED
(
	[name] ASC,
	[uid] ASC
) ON [PRIMARY]
) ON [PRIMARY]

--@##mode:index;clustered:false;fields:name
--@##mode:index;clustered:false;fields:name,uid;include:tvalue


GO
CREATE TABLE [dbo].[http](
	[ord] [int] IDENTITY(1,1) NOT NULL,
	[sort1] [int] NULL,
	[sort1c] [nvarchar](50) NULL,
	[title] [nvarchar](50) NULL,
	[intro] [nvarchar](200) NULL,
	[gate] [int] NULL,
	[cateid] [int] NULL,
	[date7] [datetime] NULL,
    PRIMARY KEY CLUSTERED
    (
        [ord] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[M_PredictOrderLists](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[PrefixCode] [nvarchar](2) NOT NULL,
	[POrderID] [int] NOT NULL,
	[ProductID] [int] NOT NULL,
	[unit] [int] NOT NULL,
	[num1] [decimal](25, 12) NULL,
	[DateBegin] [datetime] NOT NULL,
	[DateEnd] [datetime] NOT NULL,
	[del] [int] NOT NULL,
	[intro] [ntext] NULL,
	[zdy1] [nvarchar](200) NULL,
	[zdy2] [nvarchar](200) NULL,
	[zdy3] [nvarchar](200) NULL,
	[zdy4] [nvarchar](200) NULL,
	[zdy5] [int] NULL,
	[zdy6] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]

--@##mode:index;clustered:false;fields:POrderID
--@##mode:index;clustered:false;fields:ProductID
--@##mode:index;clustered:false;fields:unit
--@##mode:index;clustered:false;fields:DateBegin
--@##mode:index;clustered:false;fields:DateEnd

GO
CREATE TABLE [dbo].[hr_gongziClass](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[title] [nvarchar](50) NULL,
	[creator] [int] NULL,
	[inDate] [datetime] NULL,
	[gongzi] [text] NULL,
	[isall] [int] NULL,
	[user_list] [text] NULL,
	[del] [int] NULL,
	[editTime] [datetime] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]
 TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[hr_ret_plan](
	[id] [int] NOT NULL,
	[title] [varchar](500) NULL,
	[bh] [varchar](100) NULL,
	[retType] [int] NULL,
	[num] [int] NULL,
	[startDate] [datetime] NULL,
	[endDate] [datetime] NULL,
	[partner] [int] NULL,
	[cost] [decimal](25, 12) NULL,
	[weburl] [varchar](500) NULL,
	[uid] [varchar](100) NULL,
	[pwd] [varchar](100) NULL,
	[content] [text] NULL,
	[creator] [int] NULL,
	[TempSave] [bit] NULL,
	[indate] [datetime] NULL,
	[del] [int] NOT NULL,
	[id_sp] [int] NULL,
	[cateid_sp] [int] NULL,
	[status] [int] NULL,
	[CreateFrom] [int] NULL,
	[statusID] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[wageslist](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[money1] [decimal](25, 12) NULL DEFAULT (0),
	[sort1] [int] NULL,
	[cateid] [int] NULL,
	[cateid2] [int] NULL,
	[cateid3] [int] NULL,
	[wages] [int] NULL,
    [iscostcollect] [int] NOT NULL DEFAULT (0),
	[addcate] [int] NULL,
	[del] [int] NULL DEFAULT (1),
	[date7] [datetime] NULL,
	[intro] [ntext] NULL,
    [sortName] [nvarchar](50) NULL,
    [updown] [int] NULL,
    [gate1] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]
 TEXTIMAGE_ON [PRIMARY]

--@##mode:index;clustered:true;fields:id
--@##mode:statistics;fields:cateid,wages
--@##mode:statistics;fields:money1,wages

GO

CREATE TABLE [dbo].[jf](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[jf] [decimal](25, 12) NULL DEFAULT (0),
	[product1] [int] NULL,
	[sort1] [int] NULL,
	[unit] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


--@##mode:statistics;fields:product1,sort1,unit

GO
CREATE TABLE [dbo].[hr_person](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[userID] [int] NULL,
	[userName] [nvarchar](50) NULL,
	[sorce] [int] NULL,
	[sorce2] [int] NULL,
	[cuserName] [nvarchar](50) NULL,
	[euserName] [nvarchar](50) NULL,
	[userbh] [nvarchar](50) NULL,
	[idcard] [nvarchar](100) NULL,
	[fkAddress] [nvarchar](100) NULL,
	[daAddress] [nvarchar](100) NULL,
	[sex] [int] NULL,
	[jgAddress] [nvarchar](100) NULL,
	[minzu] [nvarchar](50) NULL,
	[zhenzhi] [nvarchar](50) NULL,
	[marry] [int] NULL,
	[birthType] [int] NULL,
	[birthday] [datetime] NULL,
	[age] [int] NULL,
	[edu1] [nvarchar](50) NULL,
	[prof1] [nvarchar](50) NULL,
	[college1] [nvarchar](50) NULL,
	[edu2] [nvarchar](50) NULL,
	[prof2] [nvarchar](50) NULL,
	[college2] [nvarchar](50) NULL,
	[Degree] [nvarchar](50) NULL,
	[FLanguage1] [nvarchar](50) NULL,
	[FLanguageLv1] [nvarchar](50) NULL,
	[FLanguage2] [nvarchar](50) NULL,
	[FLanguageLv2] [nvarchar](50) NULL,
	[FLanguage3] [nvarchar](50) NULL,
	[FLanguageLv3] [nvarchar](50) NULL,
	[telOffice] [nvarchar](50) NULL,
	[telHome] [nvarchar](50) NULL,
	[mobile] [nvarchar](50) NULL,
	[mobile1] [nvarchar](50) NULL,
	[fax] [nvarchar](50) NULL,
	[email] [nvarchar](50) NULL,
	[addressHome] [nvarchar](50) NULL,
	[addressNow] [nvarchar](50) NULL,
	[zipcode] [nvarchar](50) NULL,
	[Specialty] [text] NULL,
	[contractStart] [datetime] NULL,
	[contractEnd] [datetime] NULL,
	[contractDay] [int] NULL,
	[contractAlarm] [int] NULL,
	[contractAlarmDay] [int] NULL,
	[content] [text] NULL,
	[photos] [nvarchar](500) NULL,
	[ResumeUrl] [nvarchar](200) NULL,
	[Reguldate] [datetime] NULL,
	[Entrydate] [datetime] NULL,
	[nowStatus] [int] NULL,
	[Piecework] [int] NULL,
	[HourlyWages] [int] NULL,
	[BasicSalary] [decimal](25, 12) NULL,
	[ProbSalary] [decimal](25, 12) NULL,
	[Probation] [int] NULL,
	[indate] [datetime] NULL,
	[creator] [int] NULL,
	[del] [int] NULL,
	[HousingFund] [int] NULL,
	[editDate] [datetime] NULL,
	[editCate] [int] NULL,
	[salarySend] [int] NULL,
	[ModifyStamp] [varchar](50) NULL,
	[Pension] [decimal](25, 12) NULL,
	[Health] [decimal](25, 12) NULL,
	[Unployment] [decimal](25, 12) NULL,
	[Injury] [decimal](25, 12) NULL,
	[Maternity] [decimal](25, 12) NULL,
	[Housing] [decimal](25, 12) NULL,
    [ChildrenseDucation] [decimal](25, 12) NULL,
    [ContinuingEducationxl] [decimal](25, 12) NULL,
    [ContinuingEducationjn] [decimal](25, 12) NULL,
    [medical] [decimal](25, 12) NULL,
    [Housingloans] [decimal](25, 12) NULL,
    [payment] [decimal](25, 12) NULL,
    [SupportOldPeople] [decimal](25, 12) NULL,
	[delcate] [int] NULL,
	[delDate] [datetime] NULL,
	[PostionID] [int] NULL,
	[workPosition] [int] NULL,
	[depositBank] [nvarchar](100) NULL,
	[cardnumBank] [nvarchar](100) NULL,
	[salaryClass] [int] NULL,
	[interviewID] [int] NULL,
	[interest] [text] NULL,
	[orgsid] int null,
    [DateForStartedWork] datetime null,
    [WeddingDay] datetime null,
	[InfantCare] [decimal](25, 12) NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]
 TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[M_PredictOrders](
	[ID] [int] NOT NULL,
	[PrefixCode] [nvarchar](2) NOT NULL,
	[title] [nvarchar](100) NOT NULL,
	[PredictBH] [nvarchar](50) NOT NULL,
	[inDate] [datetime] NOT NULL,
	[Creator] [int] NOT NULL,
	[MRP] [bit] NOT NULL,
	[status] [int] NOT NULL,
	[id_sp] [int] NOT NULL,
	[cateid_sp] [int] NOT NULL,
	[del] [int] NOT NULL,
	[TempSave] [int] NOT NULL DEFAULT (0),
	[intro] [ntext] NULL,
PRIMARY KEY NONCLUSTERED
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

--@##mode:index;clustered:false;fields:inDate desc
--@##mode:index;clustered:false;fields:Creator
--@##mode:index;clustered:false;fields:MRP

GO
--Attrs:帐套下可用
CREATE TABLE [dbo].[Sys_ExtFieldMenu](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[M_fid] [int] NULL,
	[M_name] [varchar](200) NULL,
	[M_del] [int] NULL DEFAULT (1),
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[wageslist_jj](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[money1] [decimal](25, 12) NULL,
	[num1] [decimal](25, 12) NULL,
	[sort1] [int] NULL,
	[cateid] [int] NULL,
	[cateid2] [int] NULL,
	[cateid3] [int] NULL,
	[wages] [int] NULL,
	[addcate] [int] NULL,
	[sort2] [int] NULL,
	[complete1] [int] NULL DEFAULT (0),
	[date1] [datetime] NULL,
	[date7] [datetime] NULL,
	[wages2] [int] NULL,
	[del] [int] NOT NULL DEFAULT (1),
	[sort5Name] [nvarchar](50) NULL,
	[sort4Name] [nvarchar](50) NULL,
	[num2] [decimal](25, 12) NULL,
	[salaryClass] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[jiage](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[bm] [int] NOT NULL DEFAULT(0),
	[bl] [decimal](25, 12) NOT NULL DEFAULT(1),
	[unit] [int] NOT NULL DEFAULT (0),
	[cgMainUnit] [int] NULL,
	[txm] [nvarchar](50) NULL,
	[price1jy] [decimal](25, 12) NOT NULL DEFAULT (0),
	[price1] [decimal](25, 12) NOT NULL DEFAULT(0),
	[price2jy] [decimal](25, 12) NOT NULL DEFAULT(0),
	[price2] [decimal](25, 12) NOT NULL DEFAULT(0),
	[price3] [decimal](25, 12) NOT NULL DEFAULT(0),
	[sort] [int] NULL,
	[product] [int] NULL,
	[MainStore] [int] NULL DEFAULT(0),
	[StoreCapacity] [decimal](25, 12) NULL,
	[xlhManage] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


--@##mode:index;clustered:true;fields:unit,product,bm
--@##mode:index;clustered:false;fields:product,unit,bm,bl
--@##mode:index;clustered:false;fields:txm
--@##mode:statistics;fields:bm,product
--@##mode:statistics;fields:bl,bm,product
--@##mode:statistics;fields:unit,bm,product,bl

GO

CREATE TABLE [dbo].[M_ProductMRP](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ProductID] [int] NOT NULL,
	[MRPTitle] [nvarchar](100) NULL,
	[Property_Sale] [bit] NULL DEFAULT (0),
	[Property_Buy] [bit] NULL,
	[Property_Consume] [bit] NULL,
	[Property_Homemade] [bit] NULL,
	[Property_Making] [bit] NULL,
	[Tactics] [int] NULL,
	[BatchRules] [int] NULL,
	[BatNum] [decimal](25, 12) NULL,
	[TimeInAdvance] [decimal](25, 12) NULL,
	[DayProvide] [decimal](25, 12) NULL,
	[ReorderPoint] [decimal](25, 12) NULL,
	[NumRequest] [decimal](25, 12) NULL,
	[SaveNum] [decimal](25, 12) NULL,
	[AttritionRate] [decimal](25, 12) NOT NULL DEFAULT (0),
	[Costs] [decimal](25, 12) NULL,
	[DateStart] [datetime] NULL,
	[DateStop] [datetime] NULL,
	[UnitWeight] [decimal](25, 12) NULL,
	[UnitVolume] [decimal](25, 12) NULL,
	[del] [int] NOT NULL,
	[Property_Virtul] [bit] NULL,
	[Property_OutHair] [bit] NULL,
PRIMARY KEY CLUSTERED
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[hr_holiday](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[title] [nvarchar](50) NULL,
	[startTime] [datetime] NULL,
	[endTime] [datetime] NULL,
	[HdTime] [datetime] NULL,
	[isChineseDate] [int] NULL,
	[dayNum] [int] NULL,
	[content] [text] NULL,
	[creator] [int] NULL,
	[IsEffect] [int] NULL,
	[EffectStartTime] [datetime] NULL,
	[EffectStartEnd] [datetime] NULL,
	[id_sp] [int] NULL,
	[cateid_sp] [int] NULL,
	[HdYear] [int] NULL,
	[HdMoth] [int] NULL,
	[HdDay] [int] NULL,
	[addTime] [datetime] NULL,
	[editTime] [datetime] NULL,
	[noNeedWork] [nvarchar](1000) NULL,
	[NeedWork] [nvarchar](1000) NULL,
	[needChang] [int] NULL,
	[ChangTime] [int] NULL,
	[del] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]
 TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[M_OutOrderlists_wl](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[outID] [int] NOT NULL,
	[productID] [int] NOT NULL,
	[unit] [int] NOT NULL,
	[llnum] [decimal](25, 12) NOT NULL,
	[num] [decimal](25, 12) NOT NULL,
	[molist] [int] NOT NULL,
	[remark] [varchar](200) NULL,
	[del] [int] NOT NULL,
	[numone] [decimal](25, 12) NULL,
PRIMARY KEY CLUSTERED
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]

--@##mode:index;clustered:false;fields:outID
--@##mode:index;clustered:false;fields:productID
--@##mode:index;clustered:false;fields:unit
--@##mode:index;clustered:false;fields:molist

GO
CREATE TABLE [dbo].[wddh](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [nvarchar](50) NULL,
	[title1] [nvarchar](150) NULL,
	[title2] [nvarchar](150) NULL,
	[url] [nvarchar](500) NULL,
	[sort] [int] NULL,
	[sort1] [int] NULL,
	[sort2] [int] NULL,
	[cateid] [int] NULL,
	[gate1] [int] NULL,
	[date7] [datetime] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[jzds](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](50) NULL,
	[dsid] [nvarchar](50) NULL,
	[wxjb] [int] NOT NULL,
	[area] [int] NULL,
	[sort] [int] NULL,
	[date1] [datetime] NULL,
	[faren] [nvarchar](50) NULL,
	[ziben] [decimal](25, 12) NULL,
	[num1] [int] NULL,
	[zichan] [decimal](25, 12) NULL,
	[money1] [decimal](25, 12) NULL,
	[money2] [decimal](25, 12) NULL,
	[num2] [decimal](25, 12) NULL,
	[phone] [nvarchar](50) NULL,
	[fax] [nvarchar](50) NULL,
	[url] [nvarchar](50) NULL,
	[email] [nvarchar](50) NULL,
	[address] [nvarchar](500) NULL,
	[zip] [nvarchar](50) NULL,
	[c1] [ntext] NULL,
	[c2] [ntext] NULL,
	[c3] [ntext] NULL,
	[c4] [ntext] NULL,
	[c5] [ntext] NULL,
	[c6] [ntext] NULL,
	[c7] [ntext] NULL,
	[date7] [datetime] NULL,
	[share] [nvarchar](2000) NULL,
	[cateid] [int] NULL,
	[cateid2] [int] NULL,
	[cateid3] [int] NULL,
	[del] [int] NULL,
	[delcate] [int] NULL,
	[deldate] [datetime] NULL,
	[remark] [ntext] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
--质检明细
CREATE TABLE [dbo].[M_QualityTestingLists](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[QTID] [int] NOT NULL,
	[MPDID] [int] NOT NULL,
	[NumTesting] [decimal](25, 12) NULL,
	[NumScrap] [decimal](25, 12) NULL,
	[NumBF] [decimal](25, 12) NULL,
	[QualityLevel] [int] NOT NULL,
	[del] [int] NOT NULL,
	[SerialNumber] [nvarchar](100) NULL,  --Task.1232.binary.2013.12.20
	[ph] [nvarchar](100) NULL,
	[datesc] [datetime] NULL,
	[dateyx] [datetime] NULL
PRIMARY KEY CLUSTERED
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]

--@##mode:index;clustered:false;fields:QTID
--@##mode:index;clustered:false;fields:MPDID

GO
CREATE TABLE [dbo].[xunjia](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[fromtype] [int] NULL,
	[title] [nvarchar](100) NULL,
	[xjid] [nvarchar](50) NULL,
	[date1] [datetime] NULL,
	[cateid] [int] NULL,
	[cateid2] [int] NULL,
	[cateid3] [int] NULL,
	[date7] [datetime] NULL,
	[price] [int] NULL,
	[company] [int] NULL,
	[zdy1] [nvarchar](50) NULL,
	[zdy2] [nvarchar](50) NULL,
	[zdy3] [nvarchar](50) NULL,
	[zdy4] [nvarchar](50) NULL,
	[zdy5] [int] NULL,
	[zdy6] [int] NULL,
	[del] [int] NULL,
	[del2] [int] NULL,
	[delcate] [int] NULL,
	[deldate] [datetime] NULL,
	[complete] [int] NULL,
	[complete2] [int] NULL,
	[remark] [NTEXT] NULL,
	[cateid_dj] [int] NULL,
	[bz] [int] NULL,
	[status] [int] NULL,
	[ystatus] [int] NULL,
	[cateorder1] [int] NULL,
	[caigou] [int] NULL,
	[caigou_yg] [int] NULL,
	[date2] [datetime] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[xunjialist](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NULL,
	[unit] [int] NOT NULL DEFAULT(0),
	[num1] [decimal](25, 12) NOT NULL DEFAULT(0),
	[price1] [decimal](25, 12) NOT NULL DEFAULT(0),
	[money1] [decimal](25, 12) NOT NULL DEFAULT(0),
	[taxRate] [decimal](25, 12) NULL,
	[invoiceType] [int] NULL,
	[discount] [decimal](25, 12) NULL,
	[priceAfterDiscount] [decimal](25, 12) NULL,
	[priceIncludeTax] [decimal](25, 12) NULL,
	[priceAfterTax] [decimal](25, 12) NULL,
	[taxValue] [decimal](25, 12) NULL,
	[moneyAfterTax] [decimal](25, 12) NULL,
	[company] [int] NULL,
	[pricelist] [int] NULL,
	[xunjia] [int] NULL,
	[date1] [datetime] NULL,
	[date2] [datetime] NULL,
	[cateid] [int] NULL,
	[cateid2] [int] NULL,
	[cateid3] [int] NULL,
	[date7] [datetime] NULL,
	[intro] [nvarchar](200) NULL,
	[zdy1] [nvarchar](200) NULL,
	[zdy2] [nvarchar](200) NULL,
	[zdy3] [nvarchar](200) NULL,
	[zdy4] [nvarchar](200) NULL,
	[zdy5] [int] NULL,
	[zdy6] [int] NULL,
	[del] [int] NULL,
	[complete] [int] NULL,
	[caigoulist] [int] NULL,
	[caigoulist_yg] [int] NULL,
	[gys] [int] NOT NULL DEFAULT(0),
	[gysstatus] [int] NULL DEFAULT (0),
	[mxpxid] [int] NULL DEFAULT (0),
	[djzt] [int] NULL , --单行定价状态
	[toUse] [int] NULL,
	[bydate] [datetime] NULL,
	[djdate] [datetime] NULL,
	[Xunjiastatus] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[ku](
	[id] [int] IDENTITY(1,1) NOT NULL,
    [pid] [int] NULL,
	[ord] [int] NULL,
    [unit] [int] NULL,
    [commUnitAttr] [nvarchar](200) NULL,
	[num1] [decimal](25, 12) NULL DEFAULT (0),
    [num2] [decimal](25, 12) NULL,
    [num3] [decimal](25, 12) NULL,
	[price1] [decimal](25, 12) NULL,
	[money1]  [decimal](25, 12) NULL,
    [FinaMoney]  [decimal](25, 12) NULL,
	[pricemonth]  [decimal](25, 12) NULL,
    [AssistUnit] [int] NULL,
    [AssistNum] [decimal](25, 12) NULL,
	[ph] [nvarchar](50) NULL,
	[xlh] [nvarchar](100) NULL,
	[datesc] [datetime] NULL,
	[dateyx] [datetime] NULL,
	[date2] [datetime] NULL,
	[bz] [int] NULL,
	[js] [decimal](25, 12) NULL,
	[intro] [nvarchar](500) NULL,
    [ck] [int] NULL,
    [daterk] [datetime] NOT NULL,
	[caigoulist] [int] NULL,
    [caigoulist2] [int] NULL,
	[kuinlist] [int] NULL,
    [gys] [int] NULL,
	[Status] [int] NULL,
	[alt] [int] NULL,
	[locked] [int] NULL,
	[locknum] [decimal](25, 12) NULL,
	[lockCate] [int] NULL,
	[lockDate] [datetime] NULL,
	[lockIntro] [nvarchar](20) NULL,
	[unRemind] [varchar](2000) NULL,
	[alt2] [varchar](2000) NULL,
	[ProductAttr1] int null,
	[ProductAttr2] int null,
	[ProductAttrBatchId] int null,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


--@##mode:index;clustered:true;fields:id
--@##mode:index;clustered:false;fields:kuinlist
--@##mode:index;clustered:false;fields:ord
--@##mode:index;clustered:false;fields:ord,unit
--@##mode:index;clustered:false;fields:ord,ck,unit;include:num1,money1,num2
--@##mode:index;clustered:false;fields:num2;include:id,ord,ck,unit,ph,xlh,daterk
--@##mode:index;clustered:false;fields:num2;include:ord,num1,ck,price1,money1,unit
--@##mode:index;clustered:false;fields:ord,ck,unit,num2;include:id,ph,xlh,daterk
--@##mode:index;clustered:false;fields:ck,dateyx,num2;include:id,ord,locked
--@##mode:index;clustered:false;fields:dateyx,num2;include:id,ord,ck,locked
--@##mode:index;clustered:false;fields:daterk;include:[id],[num1],[ck],[kuinlist],[num3]
--@##mode:statistics;fields:ord,num2
--@##mode:index;clustered:false;fields:ck;include:money1,kuinlist,num3,AssistUnit,AssistNum

GO
--存货核算表
CREATE TABLE [dbo].[inventoryCost](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[date1] [datetime] NULL,
	[complete1] [int] NULL,
	[cateid] [int] NULL, 
	[date7] [datetime] NULL,
	[DataVersion] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]

--@##mode:statistics;fields:date1

GO
--存货核算明细表
CREATE TABLE [dbo].[inventoryCostList](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NULL,
	[unit] [int] NULL,
	[ck] [int] NULL,

	[num1] [decimal](25, 12) NULL DEFAULT (0),
	[price1] [decimal](25, 12) NULL,
	[money1] [decimal](25, 12) NULL,

	[num2] [decimal](25, 12) NULL,
	[price2] [decimal](25, 12) NULL,
	[money2] [decimal](25, 12) NULL,

	[num3] [decimal](25, 12) NULL,
	[price3] [decimal](25, 12) NULL,
	[money3] [decimal](25, 12) NULL,

	[num4] [decimal](25, 12) NULL,
	[price4] [decimal](25, 12) NULL,
	[money4] [decimal](25, 12) NULL,

	[date1] [datetime] NULL,
	[Costid] [int] NULL,
	[kuid] [int] NULL,
	[dataType] [int] NULL --入库类型(主要是报废类型核算处理),
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]

--@##mode:index;clustered:true;fields:Costid,date1,ord,unit,ck,id
--@##mode:index;clustered:false;fields:Costid,kuid

GO
--存货核算明细表
CREATE TABLE [dbo].[inventoryCostList_temp](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[kuid] [int] NULL,
	[ord] [int] NULL,
	[unit] [int] NULL,
	[ck] [int] NULL,

	[num1] [decimal](25, 12) NULL DEFAULT (0),
	[price1] [decimal](25, 12) NULL,
	[money1] [decimal](25, 12) NULL,

	[num2] [decimal](25, 12) NULL,
	[price2] [decimal](25, 12) NULL,
	[money2] [decimal](25, 12) NULL,

	[num3] [decimal](25, 12) NULL,
	[price3] [decimal](25, 12) NULL,
	[money3] [decimal](25, 12) NULL,

	[num4] [decimal](25, 12) NULL,
	[price4] [decimal](25, 12) NULL,
	[money4] [decimal](25, 12) NULL,

	[date1] [datetime] NULL,
	[Costid] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]

--@##mode:statistics;fields:date1

GO

if exists(select * from sysobjects where name='TRI_KuNum3Insert')
DROP TRIGGER [dbo].[TRI_KuNum3Insert]

GO

CREATE TRIGGER [dbo].[TRI_KuNum3Insert] ON [dbo].[ku] AFTER INSERT AS DECLARE @KUID AS INT SELECT @KUID=ID FROM INSERTED UPDATE KU SET NUM3=NUM1 WHERE ID=@KUID

GO
CREATE TABLE [dbo].[M_QualityTestings](
	[ID] [int] NOT NULL,
	[PrefixCode] [nvarchar](2) NOT NULL,
	[MPID] [int] NOT NULL,
	[title] [nvarchar](100) NULL,
	[QTBH] [nvarchar](50) NOT NULL,
	[QTDate] [datetime] NOT NULL,
	[QTDep] [int] NOT NULL,
	[Inspector] [int] NOT NULL,
	[Creator] [int] NOT NULL,
	[indate] [datetime] NOT NULL,
	[QTType] [int] NOT NULL,
	[del] [int] NOT NULL,
	[MID] [int] NOT NULL DEFAULT (0),
	[ddno] [int] NULL,
	[qtype] [int] NOT NULL DEFAULT (0),
	[intro] [ntext] NULL,
	[QTModel] [int] NOT NULL DEFAULT (0),   --Task.1232.binary.2013.12.20
	[qtMxSplit] [decimal](25, 12) NULL,		--Task.1232.binary.2013.12.28
	[tempSave] [int] NOT NULL DEFAULT (0),
	[WAID] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]

--@##mode:index;clustered:false;fields:MPID
--@##mode:index;clustered:false;fields:QTDate
--@##mode:index;clustered:false;fields:QTDep
--@##mode:index;clustered:false;fields:Inspector
--@##mode:index;clustered:false;fields:Creator
--@##mode:index;clustered:false;fields:indate desc
--@##mode:index;clustered:false;fields:MID
--@##mode:index;clustered:false;fields:ddno
--@##mode:index;clustered:false;fields:QTModel

GO
CREATE TABLE [dbo].[hr_holidayChang](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ChangTime] [datetime] NULL,
	[creator] [int] NULL,
	[holiday] [int] NULL,
	[addTime] [datetime] NULL,
	[del] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[O_assWork](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[wr_assID] [int] NULL,
	[wr_working] [int] NULL,
	[zdy1] [varchar](200) NULL,
	[zdy2] [varchar](4000) NULL,
	[zdy3] [int] NULL,
	[zdy4] [decimal](25, 12) NULL,
	[zdy5] [datetime] NULL,
	[addcateid] [int] NULL,
	[addtime] [datetime] NULL,
	[del] [int] NULL DEFAULT (1),
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[hr_ret_type](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[orderid] [int] NULL,
	[cnID] [int] NULL,
	[sortID] [int] NULL,
	[title] [varchar](500) NULL,
	[content] [text] NULL,
	[creator] [int] NULL,
	[del] [int] NULL,
	[px] [int] NULL,
	[typeID] [int] NULL,
	[indate] [datetime] NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[kuhh](
	[ord] [int] IDENTITY(1,1) NOT NULL,
	[title] [nvarchar](100) NOT NULL,
	[name] [nvarchar](50) NULL,
	[date1] [datetime] NULL,
	[intro] [ntext] NULL,
	[kujh] [int] NULL,
	[cateid] [int] NULL,
	[cateid2] [int] NULL,
	[cateid3] [int] NULL,
	[del] [int] NULL DEFAULT (1),
	[date7] [datetime] NULL,
	[contract] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [ord] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]
 TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[Page_ItemList](
	[Ord] [int] IDENTITY(1,1) NOT NULL,
	[MainID] [int] NULL,
	[NameUI] [varchar](50) NULL,
	[NameTable] [varchar](50) NULL,
	[PropertyUI] [varchar](50) NULL,
	[Indate] [datetime] NULL,
	[Creator] [int] NULL,
	[Del] [int] NULL,
	[Display] [bit] NULL,
	[DefaultValue] [varchar](100) NULL,
	[Px] [int] NULL,
	[RegType] [varchar](50) NULL,
	[Msg] [varchar](50) NULL,
	[Required] [bit] NULL,
	[LengthMin] [int] NULL,
	[LengthMax] [int] NULL,
	[ShowSize] [int] NULL,
	[IsKey] [bit] NULL,
	[isMainID] [bit] NULL,
PRIMARY KEY CLUSTERED
(
	[Ord] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[M_WCP](
	[WCID] [int] NOT NULL,
	[WPID] [int] NOT NULL,
	[del] [int] NOT NULL DEFAULT (0),
PRIMARY KEY CLUSTERED
(
	[WCID] ASC,
	[WPID] ASC,
	[del] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[zbintel](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[num1] [decimal](25, 12) NULL DEFAULT (0),
	[num2] [decimal](25, 12) NULL DEFAULT (0),
	[money1] [decimal](25, 12) NULL DEFAULT (0),
	[money2] [decimal](25, 12) NULL DEFAULT (0),
	[year1] [int] NULL,
	[month1] [int] NULL,
	[day1] [int] NULL,
	[ret] [datetime] NULL,
	[ret2] [datetime] NULL,
	[cateid] [int] NULL,
	[date7] [datetime] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[kuhhlist](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NULL,
	[price1] [nvarchar](200) NULL,
	[num1] [decimal](25, 12) NULL DEFAULT (0),
	[kuhh] [int] NULL,
	[kujh] [int] NULL,
	[del] [int] NULL DEFAULT (1),
	[dateadd] [datetime] NULL,
	[date7] [datetime] NULL,
	[addcate] [int] NULL,
	[jhid] [int] NULL,
	[ck] [int] NULL DEFAULT (0),
	[kuinlist] [int] NULL DEFAULT (0),
	[contractlist] [int] NULL,
    [ProductAttr1] [int] NULL,
    [ProductAttr2] [int] NULL,
    [ProductAttrBatchId] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
--
CREATE TABLE [dbo].[hr_holiday_set](
	[id] [int] NOT NULL,
	[baseDay] [int] NULL,
	[baseLimit] [int] NULL,
	[baseLow] [int] NULL,
	[everyYear] [int] NULL,
	[addDay] [int] NULL,
	[yearLimit] [int] NULL,
	[YearTestDay] [int] NULL,
	[BusLimit] [int] NULL,
	[sickLimit] [int] NULL,
	[MarryLimit] [int] NULL,
	[MateLimit] [int] NULL,
	[MateManLimit] [int] NULL,
	[zWomAge] [int] NULL,
	[zManAge] [int] NULL,
	[zMarryDay] [int] NULL,
	[wWomAge] [int] NULL,
	[wManAge] [int] NULL,
	[wMarryDay] [int] NULL,
	[MarryTestDay] [int] NULL,
	[inDate] [datetime] NULL,
	[editTime] [datetime] NULL,
	[editCate] [int] NULL,
	[del] [int] NULL,
	[PrefixCode] [nvarchar](50) NULL,
	[id_sp] [int] NULL,
	[cateid_sp] [int] NULL,
	[creator] [int] NULL,
	[startTime] [datetime] NULL,
	[endTime] [datetime] NULL
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[zdy](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[title] [nvarchar](50) NULL,
	[name] [nvarchar](50) NULL,
	[sort] [int] NULL,
	[gl] [int] NULL,
	[set_open] [int] NULL,
	[js] [int] NULL,
	[dc] [int] NULL,
	[dr] [int] NULL,
	[tj] [int] NULL,
	[bt] [int] NULL,
	[ts] [int] NULL,
	[jz] [int] NULL,
	[gate1] [int] NULL,
	[sort1] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[kuin](
	[ord] [int] IDENTITY(1,1) NOT NULL,
	[title] [nvarchar](200) NULL,
    [rkbh] [nvarchar](100) NULL,
	[ck] [int] NULL,
	[complete1] [int] NULL,
    [status] [int] NULL,
	[date3] [datetime] NULL,
	[date5] [datetime] NULL,
	[catein] [int] NULL,
	[intro] [ntext] NULL,
	[intro2] [nvarchar](100) NULL,
    [company] [int] NULL,
	[caigou] [int] NULL,
	[Joinkuhh] [int] NULL,
	[sort] [int] NULL,
	[cateid] [int] NULL,
	[cateid2] [int] NULL,
	[cateid3] [int] NULL,
	[del] [int] NULL,
	[delcate] [int] NULL,
	[deldate] [datetime] NULL,
	[date7] [datetime] NULL,
	[kg] [int] NULL DEFAULT (0),
	[sort1] [int] NULL,
	[zdy1] [nvarchar](200) NULL,
	[zdy2] [nvarchar](200) NULL,
	[zdy3] [nvarchar](200) NULL,
	[zdy4] [nvarchar](200) NULL,
	[zdy5] [int] NULL,
	[zdy6] [int] NULL,
	[QTID] [int] NULL,
	[source] [int] NULL,
	[fromid] [int] NULL,
    [kuin] [int] NULL,
    [UpTime] [datetime] NULL,
    [UpUser] [int] NULL,
    [import] [BIGINT] NULL,
	[ModifyStamp] [varchar](30) NULL,
	[alt] [int] NULL,
	[IsHC] [int] NULL DEFAULT (0),
    PRIMARY KEY CLUSTERED
    (
        [ord] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


--@##mode:statistics;fields:date3,del
--@##mode:index;clustered:false;fields:del,complete1;include:ord,status,fromid
--@##mode:index;clustered:false;fields:ord,del;include:ord,title,complete1,status,fromid,date5,caigou,cateid,delcate,deldate,sort1
--@##mode:index;clustered:true;fields:ord
--@##mode:index;clustered:true;fields:fromid,complete1
--@##mode:index;clustered:false;fields:date5;include:ord,sort1
--@##mode:index;clustered:false;fields:del;include:ord,date5

GO
CREATE TABLE [dbo].[M_WorkAssignLists](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[WAID] [int] NOT NULL,
	[ProductID] [int] NOT NULL,
	[unit] [int] NOT NULL,
	[BomList] [int] NOT NULL,
	[num1] [decimal](25, 12) NULL,
	[DateBegin] [datetime] NULL,
	[DateEnd] [datetime] NULL,
	[del] [int] NOT NULL,
	[mtype] [int] NOT NULL DEFAULT (0),
	[intro] [ntext] NULL,
PRIMARY KEY CLUSTERED
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]

--@##mode:index;clustered:false;fields:WAID
--@##mode:index;clustered:false;fields:ProductID
--@##mode:index;clustered:false;fields:unit
--@##mode:index;clustered:false;fields:BomList
--@##mode:index;clustered:false;fields:DateBegin
--@##mode:index;clustered:false;fields:DateEnd
GO

CREATE TABLE [dbo].[O_AssDpt](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[date1] [datetime] NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[O_assDeprect](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[D_assID] [int] NULL,
	[D_time] [datetime] NULL,
	[D_num] [int] NULL,
	[D_money] [decimal](25, 12) NULL,
	[D_ymoney] [decimal](25, 12) NULL,
	[D_cateid] [int] NULL,
	[D_addtime] [datetime] NULL,
    [D_lycateid] [varchar](max) NULL,
    [iscostcollect] [int]  NOT NULL DEFAULT(0),
	[D_zdy1] [varchar](200) NULL,
	[D_zdy2] [varchar](4000) NULL,
	[D_zdy3] [int] NULL,
	[D_zdy4] [decimal](25, 12) NULL,
	[D_zdy5] [datetime] NULL,
	[D_delcateid] [int] NULL,
	[D_deltime] [datetime] NULL,
	[D_del] [int] NULL DEFAULT (1),
	[ass_jttime] [datetime] NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[zdybh](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[title] [nvarchar](50) NULL,
	[sort] [int] NULL,
	[set_open] [int] NULL,
	[intro1] [int] NULL,
	[intro2] [int] NULL,
	[gate1] [int] NULL,
	[sort1] [int] NULL,
	[fieldID] [INT] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


--@##mode:index;clustered:true;fields:sort1,set_open,gate1 desc

GO
CREATE TABLE [dbo].[M_SolarData](
	[yearid] [int] NOT NULL,
	[data] [char](7) NOT NULL,
	[dataint] [int] NOT NULL
) ON [PRIMARY]

--@##mode:index;clustered:true;fields:yearid,dataint

GO
CREATE TABLE [dbo].[plan_hk](
	[ord] [int] IDENTITY(1,1) NOT NULL,
	[money1] [decimal](25, 12) NULL,
	[money2] [decimal](25, 12) NULL,
	[date1] [datetime] NULL,
	[pay] [int] NULL,
	[contract] [int] NULL,
	[addcate] [int] NULL,
	[intro] [nvarchar](200) NULL,
	[del] [int] NULL,
	[delcate] [int] NULL,
	[deldate] [datetime] NULL,
	[date7] [datetime] NULL,
PRIMARY KEY CLUSTERED
(
	[ord] ASC
) ON [PRIMARY]
) ON [PRIMARY]

--@##mode:index;clustered:false;fields:contract,del,ord

GO
CREATE TABLE [dbo].[kuinlist](
	[id] [int] IDENTITY(1,1) NOT NULL,
    [kuin] [int] NULL,
	[ord] [int] NULL,
    [unit] [int] NOT NULL DEFAULT (0),
	[commUnitAttr] [nvarchar](200) NULL,
	[price1] [decimal](25, 12) NOT NULL DEFAULT(0),
	[price2] [decimal](25, 12) NULL,
	[num1] [decimal](25, 12) NOT NULL DEFAULT (0),
	[num2] [decimal](25, 12) NOT NULL DEFAULT (0),
	[money1] [decimal](25, 12) NULL DEFAULT (0),
	[money2] [decimal](25, 12) NULL,
	[basePrice] [decimal](25, 12) NULL,
	[baseMoney] [decimal](25, 12) NULL,
    [priceMonth] [decimal](25, 12) NULL,
    [AssistUnit] [int] NULL,
    [AssistNum] [decimal](25, 12) NULL,
    [bz] [int] NULL,
	[js] [nvarchar](50) NULL,
	[intro] [nvarchar](500) NULL,
	[ph] [nvarchar](50) NULL,
	[xlh] [ntext] NULL,
	[datesc] [datetime] NULL,
	[dateyx] [datetime] NULL,
    [date2] [datetime] NULL,
    [zdy1] [nvarchar](200) NULL,
	[zdy2] [nvarchar](200) NULL,
	[zdy3] [nvarchar](200) NULL,
	[zdy4] [nvarchar](200) NULL,
	[zdy5] [int] NULL,
	[zdy6] [int] NULL,
	[ku] [int] NULL,
    [company] [int] NULL,
	[caigou] [int] NULL,
	[caigoulist] [int] NULL,
	[sort] [int] NULL,
	[dateadd] [datetime] NULL,
	[date7] [datetime] NULL,
	[del] [int] NULL,
	[addcate] [int] NULL,	
	[sort1] [int] NULL,
	[mxpx] [int] NULL,
	[QTLID] [int] NULL,
	[BFID] [int] NULL,
	[MOrderID] [int] NULL,
	[M2_QTLID] [int] NULL,
	[M2_BFID] [int] NULL,
	[M2_OrderID] [int] NULL,
	[JoinDBListID] [int] NULL,
	[kuoutlist2] [int] NULL,
	[caigoulist2] [int] NULL,
	[StoreCode] [varchar](max) NULL,
	[CaigouQCList] [int] NULL,
	[CaigouQC] [int] NULL,
    [kuinlist] [int] NULL,
    [row_Index] [int] NULL,
	[ProductAttr1] int null,
	[ProductAttr2] int null,
	[ProductAttrBatchId] int null,
    [FromType] [int] NULL, 
    [M2_WAID] [int] NULL DEFAULT ((0)),
    [M2_OutListId] [int] NULL DEFAULT ((0)),
    [CostNum][decimal](25, 12) NOT NULL DEFAULT (0),
    [CostMoney][decimal](25, 12) NOT NULL DEFAULT (0),
    [CostStatus] int  NULL,
    [SubCost_ForMaterial][decimal](25, 12) NOT NULL DEFAULT (0),
    [SubCost_Labor][decimal](25, 12) NOT NULL DEFAULT (0),
    [SubCost_Outlay][decimal](25, 12) NOT NULL DEFAULT (0),
    [FinaMoney][decimal](25, 12) NOT NULL DEFAULT (0),
    [MobileFromId] [int] Null,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


--@##mode:index;clustered:true;fields:kuin
--@##mode:index;clustered:false;fields:caigoulist ASC,ord asc,sort1 asc,del asc
--@##mode:index;clustered:false;fields:ord,unit;include:ProductAttr1,ProductAttr2,num1,num2
--@##mode:index;clustered:false;fields:del,M2_QTLID;include:num2
--@##mode:index;clustered:false;fields:M2_QTLID;include:id,kuin,num1
--@##mode:index;clustered:false;fields:del,sort1;include:num1,kuin,id
--@##mode:index;clustered:false;fields:del;include:id,num1,kuin
--@##mode:index;clustered:false;fields:del;include:id,kuin,ord,unit
--@##mode:index;clustered:false;fields:del;include:id,unit,addcate
--@##mode:index;clustered:false;fields:del;include:[num2],[M2_QTLID],[M2_BFID]
--@##mode:index;clustered:false;fields:del,num2;include:[M2_BFID],[id],[ord],[unit],[FinaMoney]
--@##mode:index;clustered:false;fields:del,num1;include:[id],[ord],[unit],[sort1],[FinaMoney]
--@##mode:index;clustered:false;fields:sort1;include:[num2],[M2_QTLID]
--@##mode:index;clustered:false;fields:M2_WAID;include:[kuin]
--@##mode:index;clustered:false;fields:del,kuin,date5;include:[id],[kuin],[ord],[unit],[price1],[price2],[num1],[money2],[priceMonth],[AssistUnit],[bz],[intro],[zdy2],[ku],[caigou],[caigoulist],[date7],[addcate],[sort1],[ProductAttr1],[ProductAttr2],[FinaMoney]
--@##mode:index;clustered:false;fields:del,sort1;include:M2_QTLID,M2_BFID
GO

CREATE TABLE [dbo].[kuinxlhlist](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[num1] [decimal](25, 12) NULL DEFAULT (0),
    [xlh] [nvarchar](500) NULL,
    [ph] [nvarchar](50) NULL,
    [kuinlist] [int] NULL,
    [kuin] [int] NULL,
    [creator] [int] NULL,
	[indate] [datetime] NULL,
	[del] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
--派工单
CREATE TABLE [dbo].[M_WorkAssigns](
	[ID] [int] NOT NULL,
	[PrefixCode] [nvarchar](2) NOT NULL,
	[MOIListID] [int] NOT NULL,
	[WABH] [nvarchar](50) NOT NULL,
	[title] [nvarchar](100) NULL,
	[ProductID] [int] NOT NULL,
	[unit] [int] NOT NULL,
	[BomList] [int] NOT NULL,
	[NumMake] [decimal](25, 12) NULL,
	[Creator] [int] NOT NULL,
	[inDate] [datetime] NOT NULL,
	[Cateid_WA] [int] NOT NULL,
	[DateWA] [datetime] NULL,
	[DateEnd] [datetime] NULL, --计划完工日期
	[Status] [int] NOT NULL,
	[del] [int] NOT NULL,
	[MOrderID] [int] NOT NULL DEFAULT (0),
	[WProID] [int] NULL DEFAULT (0),
	[tempSave] [int] NOT NULL DEFAULT (0),
	[intro] [ntext] NULL,
	[ddlistid] [int]  null
PRIMARY KEY CLUSTERED
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]

--@##mode:index;clustered:false;fields:MOIListID
--@##mode:index;clustered:false;fields:ProductID
--@##mode:index;clustered:false;fields:unit
--@##mode:index;clustered:false;fields:BomList
--@##mode:index;clustered:false;fields:Creator
--@##mode:index;clustered:false;fields:inDate desc
--@##mode:index;clustered:false;fields:Cateid_WA
--@##mode:index;clustered:false;fields:DateWA
--@##mode:index;clustered:false;fields:MOrderID
--@##mode:index;clustered:false;fields:WProID

GO
CREATE TABLE [dbo].[hr_jx](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[title] [nvarchar](50) NULL,
	[del] [int] NULL,
	[d1] [datetime] NULL,
	[d2] [datetime] NULL,
	[indate] [datetime] NULL,
	[creator] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[hr_sort](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[orderid] [int] NULL,
	[cnID] [int] NULL,
	[sortID] [int] NULL,
	[title] [varchar](500) NULL,
	[content] [text] NULL,
	[creator] [int] NULL,
	[del] [int] NULL,
	[px] [int] NULL,
	[typeID] [int] NULL,
	[indate] [datetime] NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[zdymx](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[title] [nvarchar](50) NULL,
	[name] [nvarchar](50) NULL,
	[sort] [int] NULL,
	[set_open] [int] NULL,
	[kd] [int] NULL,
	[kd2] [int] NULL,
	[gate1] [int] NULL,
	[sort1] [int] NULL,
	[sorce] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


--@##mode:index;clustered:false;fields:sort1,set_open,gate1,id
--@##mode:statistics;fields:id,sort1
--@##mode:statistics;fields:sort1,set_open,gate1
--@##mode:statistics;fields:gate1,sort1,sort,set_open
--@##mode:statistics;fields:sort1,set_open,sorce,gate1
--@##mode:statistics;fields:gate1,id,sort1,set_open
--@##mode:statistics;fields:sort1,name,sort,set_open,gate1

GO
CREATE TABLE [dbo].[kujh](
	[ord] [int] IDENTITY(1,1) NOT NULL,
	[title] [nvarchar](100) NULL,
	[ck] [int] NULL,
	[intro] [ntext] NULL,
	[date3] [datetime] NULL,
	[fh1] [int] NULL DEFAULT (0),
	[cateid] [int] NULL,
	[cateid2] [int] NULL,
	[cateid3] [int] NULL,
	[cateout] [nvarchar](50) NULL,
	[del] [int] NULL,
	[delcate] [int] NULL,
	[deldate] [datetime] NULL,
	[date7] [datetime] NULL,
	[jhbh] [nvarchar](50) NULL,
    PRIMARY KEY CLUSTERED
    (
        [ord] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]
 TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[Page_List](
	[Ord] [int] IDENTITY(1,1) NOT NULL,
	[TableID] [int] NULL,
	[FiledID] [int] NULL,
	[SortID] [int] NULL,
	[MainID] [int] NULL,
	[Indate] [datetime] NULL,
	[Creator] [int] NULL,
	[Del] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[Ord] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[M_WorkingCenters](
	[ID] [int] NOT NULL,
	[PrefixCode] [nvarchar](2) NOT NULL,
	[WCName] [nvarchar](100) NOT NULL,
	[WCBH] [nvarchar](50) NOT NULL,
	[Department] [int] NOT NULL,
	[TempSave] [bit] NOT NULL,
	[inDate] [datetime] NULL,
	[del] [int] NOT NULL,
	[Creator] [int] NULL,
	[workers] [int] NULL,
	[intro] [ntext] NULL,
PRIMARY KEY CLUSTERED
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]

--@##mode:index;clustered:false;fields:Department
--@##mode:index;clustered:false;fields:inDate desc
--@##mode:index;clustered:false;fields:Creator
--@##mode:index;clustered:false;fields:workers

GO
CREATE TABLE [dbo].[kujhlist](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NULL,
	[price1] [nvarchar](200) NULL,--实为备注字段
	[num1] [decimal](25, 12) NOT NULL DEFAULT (0),
	[num2] [decimal](25, 12) NULL DEFAULT (0),
	[kujh] [int] NULL,
	[ku] [int] NULL,
	[dateadd] [datetime] NULL,
	[date2] [datetime] NULL,
	[date3] [datetime] NULL,
	[date7] [datetime] NULL,
	[del] [int] NULL,
	[alt] [int] NULL DEFAULT (0),
	[cateid] [int] NULL,
	[addcate] [int] NULL,
	[unit] [int] NOT NULL DEFAULT(0),
	[bz] [int] NULL,
	[js] [decimal](25, 12) NULL,
	[mxid] [int] NULL,
	[ku2] [int] NULL,
	[ph] [nvarchar](50) NULL,
	[xlh] [nvarchar](100) NULL,
	[datesc] [datetime] NULL,
	[dateyx] [datetime] NULL,
	[gys] [int] NULL,
	[caigoulist] [int] NULL,
	[price2] [decimal](25, 12) NOT NULL DEFAULT(0),
	[money1] [decimal](25, 12) NOT NULL DEFAULT(0),
    [ProductAttr1] [int] NULL,
    [ProductAttr2] [int] NULL,
    [ProductAttrBatchId] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
--
CREATE TABLE [dbo].[M_WorkingFlows](
	[ID] [int] NOT NULL,
	[PrefixCode] [nvarchar](2) NOT NULL,
	[WFName] [nvarchar](100) NULL,
	[WFBH] [nvarchar](50) NULL,
	[Creator] [int] NOT NULL,
	[indate] [datetime] NOT NULL DEFAULT (getdate()),
	[id_sp] [int] NULL,
	[cateid_sp] [int] NULL,
	[status] [int] NOT NULL,
	[IsUsing] [bit] NULL,
	[del] [int] NOT NULL,
	[tempsave] [int] NOT NULL DEFAULT (0),
	[Description] [ntext] NULL,
	[sumTimes] [decimal](25, 12) NOT NULL DEFAULT (0),
	[intro] [ntext] NULL,
PRIMARY KEY CLUSTERED
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]

--@##mode:index;clustered:false;fields:Creator
--@##mode:index;clustered:false;fields:indate desc
GO

--工艺流程--工序清单
CREATE TABLE [dbo].[M_WFP](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[WFID] [int] NOT NULL DEFAULT (0),
	[WPID] [int] NOT NULL DEFAULT (0),
	[BOMList] [int] NOT NULL DEFAULT (0),
	[WCID] [int] NOT NULL DEFAULT (0),
	[del] [int] NOT NULL DEFAULT (0),
	[ProgresNum] [int] NULL, --汇报基数
	[result] [bit] NULL , --汇报质检是否启用 0 null 不启用 ,1 启用
	[num] [int] NOT NULL DEFAULT (0),
	[ord] [int] NOT NULL DEFAULT (0),
	[remark] [ntext] NULL,
	[rptime] [decimal](25, 12) NULL,
	[wtime] [varchar](20) NULL,
	[mtime] [decimal](25, 12) NULL,
    PRIMARY KEY CLUSTERED
    (
        [ID] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


--@##mode:index;clustered:false;fields:WFID,WPID
--@##mode:index;clustered:false;fields:BOMList
--@##mode:index;clustered:false;fields:WCID
--@##mode:index;clustered:false;fields:ord

GO

--生产计划工艺流程备份
CREATE TABLE [dbo].[M_WorkingFlows_plan](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[oldID] [int] NULL,
	[PrefixCode] [nvarchar](2) NOT NULL,
	[WFName] [nvarchar](100) NULL,
	[WFBH] [nvarchar](50) NULL,
	[Creator] [int] NOT NULL,
	[indate] [datetime] NOT NULL,
	[id_sp] [int] NULL,
	[cateid_sp] [int] NULL,
	[status] [int] NOT NULL,
	[IsUsing] [bit] NULL,
	[del] [int] NOT NULL,
	[tempsave] [int] NOT NULL,
	[Description] [ntext] NULL,
	[planlistID] [int] NOT NULL,
	[sumTimes] [decimal](25, 12) NULL,
	[intro] [text] NULL,
PRIMARY KEY CLUSTERED
(
	[ID] ASC,
	[planlistID] ASC
) ON [PRIMARY]
) ON [PRIMARY]

--@##mode:index;clustered:false;fields:oldID
--@##mode:index;clustered:false;fields:Creator
--@##mode:index;clustered:false;fields:indate desc
--@##mode:index;clustered:false;fields:planlistID

GO

--生产计划工艺流程工序备份
CREATE TABLE [dbo].[M_WFP_plan](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[WFID] [int] NULL,
	[oldWFID] [int] NULL,
	[WPID] [int] NULL,
	[num] [int] NULL,
	[ord] [int] NULL,
	[del] [int] NULL,
	[ProgresNum] [int] NULL, --汇报基数
	[result] [bit] NULL , --汇报质检是否启用 0 null 不启用 ,1 启用
	[remark] [ntext] NULL,
	[planlistid] [int] NULL,
	[rptime] [decimal](25, 12) NULL,
	[wtime] [varchar](20) NULL,
	[mtime] [decimal](25, 12) NULL,
    PRIMARY KEY CLUSTERED
    (
        [ID] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


--@##mode:index;clustered:false;fields:planlistid,WPID
--@##mode:index;clustered:false;fields:oldWFID
--@##mode:index;clustered:false;fields:WPID
--@##mode:index;clustered:false;fields:planlistid
--@##mode:index;clustered:false;fields:WFID
--@##mode:index;clustered:false;fields:ord
GO

--生产派工--工艺流程备份
CREATE TABLE [dbo].[M_WorkingFlows_Assigns](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[oldID] [int] NULL,	--原工艺流程 M_WorkingFlows.id
	[PrefixCode] [nvarchar](2) NOT NULL,
	[WFName] [nvarchar](100) NULL,
	[WFBH] [nvarchar](50) NULL,
	[Creator] [int] NOT NULL,
	[indate] [datetime] NOT NULL,
	[id_sp] [int] NULL,
	[cateid_sp] [int] NULL,
	[status] [int] NOT NULL,
	[IsUsing] [bit] NULL,
	[del] [int] NOT NULL,
	[tempsave] [int] NOT NULL,
	[Description] [nvarchar](4000) NULL,
	[WAID] [int] NOT NULL,	--派工单id
	[sumTimes] [decimal](25, 12) NULL,
	[intro] [text] NULL,
PRIMARY KEY CLUSTERED
(
	[ID] ASC,
	[WAID] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO

--生产派工--工艺流程工序备份
CREATE TABLE [dbo].[M_WFP_Assigns](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[WFID] [int] NULL, --工艺流程M_WorkingFlows_Assigns.ID
	[WPID] [int] NULL, --工序M_WorkingProcedures.ID
	[WAID] [int] NOT NULL,	--派工单id
	[num] [int] NULL,
	[ord] [int] NULL,
	[del] [int] NULL DEFAULT (0),
	[ProgresNum] [int] NULL, --汇报基数
	[result] [bit] NULL , --汇报质检是否启用 0 null 不启用 ,1 启用
	[remark] [ntext] NULL,
	[rptime] [decimal](25, 12) NULL,
	[wtime] [varchar](20) NULL,
	[mtime] [decimal](25, 12) NULL,
    PRIMARY KEY CLUSTERED
    (
        [ID] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[hr_kqResult](
	[id] [int] NULL,
	[title] [nvarchar](50) NULL,
	[sortID] [int] NULL,
	[color] [nvarchar](50) NULL,
	[operator] [int] NULL,
	[moneyStr] [nvarchar](50) NULL,
	[PrefixCode] [nvarchar](50) NULL,
	[isRecvAPP] [int] NULL,
	[creator] [int] NULL,
	[del] [int] NULL
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[setMessage](
	[ord] [int] IDENTITY(1,1) NOT NULL,
	[DXuserName] [nvarchar](50) NULL,
	[DXpassWord] [nvarchar](50) NULL,
	[lastCon] [nvarchar](100) NULL,
	[openLastCon] [int] NULL,
	[urlBalance] [nvarchar](200) NULL,
	[urlSend] [nvarchar](200) NULL,
	[urlUser] [nvarchar](50) NULL,
	[urlPwd] [nvarchar](50) NULL,
	[urlMobil] [nvarchar](50) NULL,
	[urlStrBalance] [nvarchar](200) NULL,
	[urlStrSend] [nvarchar](200) NULL,
	[urlContent] [nvarchar](50) NULL,
	[urlRecv] [nvarchar](500) NULL,
	[openRecv] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [ord] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[kumove](
	[ord] [int] IDENTITY(1,1) NOT NULL,
	[title] [nvarchar](100) NULL,
	[ck1] [int] NULL,
	[ck2] [int] NULL,
	[intro] [ntext] NULL,
	[complete1] [int] NULL DEFAULT (0),
	[complete2] [int] NULL DEFAULT (0),
	[complete3] [int] NULL DEFAULT (0),
	[intro1] [nvarchar](100) NULL,
	[intro2] [nvarchar](100) NULL,
	[cateid] [int] NULL,
	[cateid2] [int] NULL,
	[cateid3] [int] NULL,
	[date3] [datetime] NULL,
	[date7] [datetime] NULL,
	[del] [int] NULL,
	[delcate] [int] NULL,
	[deldate] [datetime] NULL,
	[dbbh] [nvarchar](50) NULL,
	[catein] [int] NULL,
	[datein] [datetime] NULL,
	[kg] [int] NULL,
	[date5] [datetime] NULL,
	[cateout] [int] NULL,
	[dateout] [datetime] NULL,
	[ModifyStamp] [varchar](30) NULL,
    PRIMARY KEY CLUSTERED
    (
        [ord] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]
 TEXTIMAGE_ON [PRIMARY]
--@##mode:index;clustered:false;fields:Complete1

GO

--工序
CREATE TABLE [dbo].[M_WorkingProcedures](
	[ID] [int] NOT NULL,
	[PrefixCode] [nvarchar](2) NOT NULL,
	[WPOrder] [int] NOT NULL,
	[WPName] [nvarchar](100) NULL,
	[TimeUnit] [int] NULL,
	[TimeQueue] [decimal](25, 12) NULL,
	[TimeStandard] [decimal](25, 12) NULL,
	[TimePrepare] [decimal](25, 12) NULL,
	[MakeNum] [decimal](25, 12) NULL,
	[ManHour] [decimal](25, 12) NULL,
	[ReplaceFlag] [bit] NOT NULL,
	[ReplaceID] [int] NULL,
	[del] [int] NOT NULL,
	[Creator] [int] NULL DEFAULT (0),
	[Status] [int] NULL,
	[Description] [ntext] NULL,
	[WCenter] [int] NULL,
	[WClass] [nvarchar](100) NULL,
PRIMARY KEY CLUSTERED
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]

--@##mode:index;clustered:false;fields:WPOrder
--@##mode:index;clustered:false;fields:Creator
--@##mode:index;clustered:false;fields:WCenter

GO

--工序汇报单
CREATE TABLE [dbo].[M_ProcedureProgres](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[PrefixCode] [nvarchar](2) NOT NULL, --PP
	[M_WorkAssigns] [int] NULL, --来源派工单
	[Procedure] [int] NULL, --工序
	[bh] [nvarchar](200) NULL, --汇报编号
	[title] [nvarchar](200) NULL, --汇报主题
	[codeProduct] [nvarchar](200) NULL, --产品标识
	[cateid] [int] NULL , --生产人员
	[num1] [decimal](25, 12) NOT NULL DEFAULT (0), --本次汇报数量
	[result] [int] NULL, --0 不质检 1 通过 2 返工 3 作废
	[intro]  [nvarchar](4000) NULL, --备注
	[creator] [int] NULL, --添加人员
	[inDate] [datetime] NULL, --添加时间
	[del] [int] NOT NULL,
PRIMARY KEY CLUSTERED
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[M_ManuOrderWLLists](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[MOWL] [int] NOT NULL,
	[productid] [int] NOT NULL,
	[unit] [int] NOT NULL,
	[num] [decimal](25, 12) NOT NULL,
	[ck] [int] NOT NULL,
	[cklist] [int] NOT NULL,
	[remark] [varchar](200) NULL,
	[plbomlistid] [int] NOT NULL DEFAULT (0),
	[del] [int] NOT NULL,
	[safenum] [decimal](25, 12) NULL,
	[numone] [decimal](25, 12) NULL,
	[kcnum] [decimal](25, 12) NULL,
	[dat1] [datetime] NULL,
	[MRequestID] [int] NULL,
	[delcknum] [decimal](25, 12) NOT NULL DEFAULT (0),
	[relscknum] [decimal](25, 12) NOT NULL DEFAULT (0),
	[yg_num] [decimal](25, 12) NOT NULL DEFAULT (0),
	[cankcgnum] [decimal](25, 12) NOT NULL DEFAULT (0),
	[cankrknum] [decimal](25, 12) NOT NULL DEFAULT (0),
	[cankhtnum] [decimal](25, 12) NOT NULL DEFAULT (0),
	[cankcknum] [decimal](25, 12) NOT NULL DEFAULT (0),
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

--@##mode:index;clustered:false;fields:MOWL
--@##mode:index;clustered:false;fields:productid
--@##mode:index;clustered:false;fields:unit
--@##mode:index;clustered:false;fields:ck
--@##mode:index;clustered:false;fields:cklist
--@##mode:index;clustered:false;fields:plbomlistid
--@##mode:index;clustered:false;fields:MRequestID

GO
CREATE TABLE [dbo].[logMessage](
	[ord] [int] IDENTITY(1,1) NOT NULL,
	[phone] [text] NULL,
	[stact] [nvarchar](2000) NULL,
	[addtime] [datetime] NULL,
	[addcate] [int] NULL,
	[num1] [int] NULL,
	[del] [int] NULL,
	[cateid2] [int] NULL,
	[cateid3] [int] NULL,
	[person] [int] NULL,
	[stact1] [int] NULL,
	[cateid] [int] NULL DEFAULT (0),
	[chancel] [int] NULL,
	[timerSend] [int] NULL,
	[sendtime] [datetime] NULL,
	[rsendtime] [datetime] NULL,
	[pc] [int] NULL,
	[longmode] [int] NULL,
	[needrec] [int] NULL,
	[content] [varchar](4000) NULL,
	[sp_contract_Ord] [int] NULL,
	[sendmoney] [decimal](25, 12) NULL,
	[sendnum] [int] NULL,
	[zunchcontent] [text] NULL,
    PRIMARY KEY CLUSTERED
    (
        [ord] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[kumovelist](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NULL,
	[price1] [nvarchar](500) NULL,--此字段是备注，作用与intro字段对换
	[num1] [decimal](25, 12) NULL DEFAULT (0),
	[num2] [decimal](25, 12) NULL,
	[kumove] [int] NULL,
    [AssistUnit] [int] NULL,
    [AssistNum] [decimal](25, 12) NULL,
	[ck1] [int] NULL,
	[ck2] [int] NULL,
	[del] [int] NULL,
	[dateadd] [datetime] NULL,
	[date7] [datetime] NULL,
	[addcate] [int] NULL,
	[unit] [int] NULL,
	[money1] [decimal](25, 12) NULL,
	[ph] [nvarchar](50) NULL,
	[xlh] [nvarchar](100) NULL,
	[datesc] [datetime] NULL,
	[dateyx] [datetime] NULL,
	[bz] [int] NULL,
	[js] [decimal](25, 12) NULL,
	[intro] [decimal](25, 12) NULL,
	[zdy1] [nvarchar](200) NULL,
	[zdy2] [nvarchar](200) NULL,
	[zdy3] [nvarchar](200) NULL,
	[zdy4] [nvarchar](200) NULL,
	[zdy5] [int] NULL,
	[zdy6] [int] NULL,
	[caigoulist] [int] NULL,
	[kuinlist] [int] NULL,
	[gys] [int] NULL,
	[ku] [int] NULL,
	[mxid] [int] NULL,
    [ProductAttr1] int null,
	[ProductAttr2] int null,
    [ProductAttrBatchId] int null,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]

--@##mode:index;clustered:false;fields:kumove
--@##mode:index;clustered:false;fields:kuinlist
--@##mode:index;clustered:false;fields:caigoulist
--@##mode:index;clustered:false;fields:gys
--@##mode:index;clustered:false;fields:ku
--@##mode:index;clustered:false;fields:ord
--@##mode:index;clustered:false;fields:unit
--@##mode:index;clustered:false;fields:del;include:id,kumove

GO
CREATE TABLE [dbo].[MessagePerson](
	[ord] [int] IDENTITY(1,1) NOT NULL,
	[clictName] [nvarchar](50) NULL,
	[clictPhone] [nvarchar](50) NULL,
	[clictSex] [nvarchar](50) NULL,
	[clictJob] [nvarchar](50) NULL,
	[complete] [int] NULL,
	[sort] [int] NULL,
	[del] [int] NULL,
	[addtime] [datetime] NULL,
	[cateid] [int] NULL,
	[company] [int] NULL,
	[sort1] [nvarchar](50) NULL,
	[sort2] [nvarchar](50) NULL,
	[addcate] [int] NULL,
	[person] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [ord] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[hr_login_con](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[today] [datetime] NULL,
	[cateid] [int] NULL,
	[creator] [int] NULL,
	[inDate] [datetime] NULL,
	[editTime] [datetime] NULL,
	[editCate] [int] NULL,
	[del] [int] NULL,
	[content] [text] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]
 TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[hr_test](
	[id] [int] NOT NULL,
	[title] [varchar](500) NULL,
	[sortid] [int] NULL,
	[testtype] [int] NULL,
	[content] [text] NULL,
	[creator] [int] NULL,
	[id_sp] [int] NULL,
	[cateid_sp] [int] NULL,
	[TempSave] [bit] NULL,
	[indate] [datetime] NULL,
	[del] [int] NOT NULL,
	[point] [decimal](25, 12) NULL,
	[status] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[sortMessage](
	[ord] [int] IDENTITY(1,1) NOT NULL,
	[sortName] [nvarchar](100) NULL,
	[sortClass] [int] NULL,
	[addtime] [datetime] NULL,
	[editTime] [datetime] NULL,
	[addcate] [int] NULL,
	[editcate] [int] NULL,
	[share] [int] NULL,
	[order1] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [ord] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[kuout](
	[ord] [int] IDENTITY(1,1) NOT NULL,
	[title] [nvarchar](200) NULL,
    [ckbh] [nvarchar](100) NULL,
	[ck] [int] NULL,
	[date3] [datetime] NULL,
	[date5] [datetime] NULL,
	[intro] [ntext] NULL,
	[complete1] [int] NULL DEFAULT (1),
	[fh1] [int] NULL,
	[order1] [int] NULL,
	[intro2] [nvarchar](200) NULL,
	[cateid] [int] NULL,
	[cateid2] [int] NULL,
	[cateid3] [int] NULL,
	[del] [int] NULL,
	[cateout] [int] NULL,
	[delcate] [int] NULL,
	[deldate] [datetime] NULL,
	[date7] [datetime] NULL,
	[kg] [int] NULL,
	[sort1] [int] NULL,
    [IsMinusKuout] [int] NULL,
	[zdy1] [nvarchar](200) NULL,
	[zdy2] [nvarchar](200) NULL,
	[zdy3] [nvarchar](200) NULL,
	[zdy4] [nvarchar](200) NULL,
	[zdy5] [int] NULL,
	[zdy6] [int] NULL,
	[source] [int] NULL,
	[fromid] [int] NULL,
    [status] [int] NULL DEFAULT(-1),
	[ModifyStamp] [varchar](50) NULL,
	[alt] [int] NULL,
	[receiver] nvarchar(50),--收货人
	[phone] nvarchar(50),--固话
	[mobile] nvarchar(50),--手机
	[address] nvarchar(500),--地址
	[zip] nvarchar(50),--邮编
	[areaId][int] null,--地址，关联manuarea.id
    [kuout] [int] null,
	[IsHC] [int] NULL DEFAULT (0),
    PRIMARY KEY CLUSTERED
    (
        [ord] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]
 TEXTIMAGE_ON [PRIMARY]

--@##mode:index;clustered:false;fields:order1,sort1,del,date7
--@##mode:index;clustered:false;fields:ord
--@##mode:index;clustered:false;fields:status,complete1,sort1,fh1,del
--@##mode:index;clustered:false;fields:date7
--@##mode:index;clustered:false;fields:date5;include:ord
--@##mode:index;clustered:false;fields:ckbh
--@##mode:index;clustered:false;fields:sort1,fromid
--@##mode:statistics;fields:date7,order1,sort1
--@##mode:statistics;fields:order1,del,sort1,date7

GO
CREATE TABLE [dbo].[Page_sort](
	[Ord] [int] IDENTITY(1,1) NOT NULL,
	[TableID] [int] NULL,
	[TypeID] [int] NULL,
	[SortID] [int] NULL,
	[Title] [varchar](500) NULL,
	[Px] [int] NULL,
	[Creator] [int] NULL,
	[Indate] [datetime] NULL,
	[Del] [int] NULL,
	[flag] [int] NULL
PRIMARY KEY CLUSTERED
(
	[Ord] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[MessagePersonClass](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[title] [nvarchar](30) NOT NULL,
	[depth] [int] NOT NULL,
	[parent] [int] NOT NULL,
	[sort] [int] NOT NULL,
	[User_List] [nvarchar](2000) NULL,
	[del] [int] NULL,
	[addcate] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[mobanMessage](
	[ord] [int] IDENTITY(1,1) NOT NULL,
	[sort] [int] NULL,
	[content] [nvarchar](500) NULL,
	[del] [int] NULL,
	[share] [int] NULL,
	[addtime] [datetime] NULL,
	[editTime] [datetime] NULL,
	[deltime] [datetime] NULL,
	[addcate] [int] NULL,
	[editcate] [int] NULL,
	[clikNum] [int] NULL,
	[shareInfo] [nvarchar](1000) NULL,
    PRIMARY KEY CLUSTERED
    (
        [ord] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[kuoutlist](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NULL,
    [unit] [int] NULL,
    [commUnitAttr] [nvarchar](200) NULL,
	[price1] [nvarchar](200) NULL,
    [num1] [decimal](25, 12) NULL DEFAULT (0),
	[num2] [decimal](25, 12) NULL DEFAULT (0),
	[num3] [decimal](25, 12) NULL DEFAULT (0),
	[num4] [decimal](25, 12) NULL DEFAULT (0),
    [money1] [decimal](25, 12) NULL,
    [pricemonth] [decimal](25, 12) NULL,
    [AssistUnit] [int] NULL,
    [AssistNum] [decimal](25, 12) NULL,
	[bz] [int] NULL,
	[js] [nvarchar](50) NULL,
	[intro] [decimal](25, 12) NULL,
    [ph] [nvarchar](50) NULL,
	[xlh] [nvarchar](100) NULL,
    [date2] [datetime] NULL,
    [zdy1] [nvarchar](200) NULL,
	[zdy2] [nvarchar](200) NULL,
	[zdy3] [nvarchar](200) NULL,
	[zdy4] [nvarchar](200) NULL,
	[zdy5] [int] NULL,
	[zdy6] [int] NULL,
	[kuout] [int] NULL,
	[ku] [int] NULL,
    [Kuinlist] [int] NULL,
	[order1] [int] NULL,
	[dateadd] [datetime] NULL,
	[date7] [datetime] NULL,
	[del] [int] NULL,
	[addcate] [int] NULL,
	[company] [int] NULL,	
	[contractlist] [int] NULL,
	[MOrderID] [int] NULL,
    [FromID] [int] NULL,
	[M2_OrderID] [int] NULL,
	[JoinDBListID] [int] NULL,
    [kuoutlist] [int],
	[ProductAttr1] int null,
	[ProductAttr2] int null,
	[ProductAttrBatchId] int null,
    [CKAccStatus] [int] NULL,
    [rowindex] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


--@##mode:index;clustered:false;fields:kuout
--@##mode:index;clustered:false;fields:id,kuout;include:num1
--@##mode:index;clustered:false;fields:addcate,id desc,date7 desc
--@##mode:index;clustered:false;fields:ord,unit;include:ProductAttr1,ProductAttr2,num1
--@##mode:index;clustered:false;fields:ku
--@##mode:index;clustered:false;fields:kuoutlist
--@##mode:index;clustered:false;fields:company
--@##mode:index;clustered:false;fields:contractlist
--@##mode:index;clustered:false;fields:kuout,contractlist,date7,id
--@##mode:index;clustered:false;fields:id
--@##mode:index;clustered:false;fields:M2_OrderID

GO

CREATE TABLE [dbo].[kuoutxlhlist](
	[id] [int] IDENTITY(1,1) NOT NULL,
    [kuid] [int] NULL,
    [CK] [int] NULL,
	[num1] [decimal](25, 12) NULL DEFAULT (0),
    [kuoutlist] [int] NULL,
    [kuout] [int] NULL,
    [SerialID] [int] NULL,
    [creator] [int] NULL,
	[indate] [datetime] NULL,
	[del] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[hr_perform_Comments](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[perform] [int] NULL,
	[cateid] [int] NULL,
	[sp_id] [int] NULL,
	[project] [int] NULL,
	[content] [text] NULL,
	[creator] [int] NULL,
	[typeid] [int] NULL,
	[inDate] [datetime] NULL,
	[del] [int] NULL,
    [sp] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]
 TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[action_list1](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[username] [int] NULL,
	[name] [nvarchar](50) NULL,
	[page1] [varchar](max) NULL,
	[time_login] [datetime] NULL,
	[action1] [nvarchar](500) NULL,
	[type_login] [int] NULL DEFAULT (1),
	[type_sys] [varchar](1000) NULL,
	[type_brower] [varchar](1000) NULL,
	[ip][varchar](30),
	[keyValue][varchar](2000),
	[wxUserId][int] NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[kuoutlist2](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NULL,
    [unit] [int] NOT NULL DEFAULT(0),
    [commUnitAttr] [nvarchar](200) NULL,
    [price1] [decimal](25, 12) NOT NULL DEFAULT(0),
    [price2] [decimal](25, 12) NULL DEFAULT (0),
	[num1] [decimal](25, 12) NOT NULL DEFAULT(0),
	[num2] [decimal](25, 12) NOT NULL DEFAULT(0),
	[num3] [decimal](25, 12) NOT NULL DEFAULT(0),
    [ThNum] [decimal](25, 12) NOT NULL DEFAULT(0),	
	[money1] [decimal](25, 12) NOT NULL DEFAULT(0),
    [money2] [decimal](25, 12) NULL DEFAULT (0),
    [pricemonth] [decimal](25, 12) NULL,
    [AssistUnit] [int] NULL,
    [AssistNum] [decimal](25, 12) NULL,
	[bz] [int] NULL,
	[js] [decimal](25, 12) NULL,
	[intro] [nvarchar](200) NULL,
    [ph] [nvarchar](50) NULL,
	[xlh] [nvarchar](100) NULL,
	[datesc] [datetime] NULL,
	[dateyx] [datetime] NULL,
    [date2] [datetime] NULL,
    [zdy1] [nvarchar](200) NULL,
	[zdy2] [nvarchar](200) NULL,
	[zdy3] [nvarchar](200) NULL,
	[zdy4] [nvarchar](200) NULL,
	[zdy5] [int] NULL,
	[zdy6] [int] NULL,
	[company] [int] NULL,
	[contract] [int] NULL,
	[contractlist] [int] NULL,
	[kuout] [int] NULL,
	[kuoutlist] [int] NULL,
	[area] [int] NULL,
	[trade] [int] NULL,
    [ku] [int] NOT NULL DEFAULT(0),
	[ck] [int] NOT NULL DEFAULT(0),
	[caigoulist] [int] NULL,
	[kuinlist] [int] NULL,	
	[gys] [int] NULL,
	[date1] [datetime] NULL,
	[date7] [datetime] NULL,
	[del] [int] NULL,
	[cateid] [int] NULL,
	[cateid2] [int] NULL,
	[cateid3] [int] NULL,
	[addcate] [int] NULL,
	[mxid] [int] NULL,
	[sort1] [int] NULL,
	[isMinus] [int] NOT NULL DEFAULT (0),
	[HCStatus] [int] NULL,
	[MOrderID] [int] NULL,
    [FromID] [int] NULL,
	[M2_OrderID] [int] NULL,	
	[JoinDBListID] [int] NULL,
	[StoreCode] [varchar](200) NULL,
	[zzyckData] [varchar](500) Null,
	[numleft] [decimal](25, 12) NULL,
	[Numleft_frCost] [decimal](25, 12) NULL ,
	[Numleft_frCost_ut] [DateTime] NULL,
	[Moneyleft_frCost] [decimal](25, 12) NULL DEFAULT (0),
    [CostNum][decimal](25, 12) NOT NULL DEFAULT (0),
    [CostMoney][decimal](25, 12) NOT NULL DEFAULT (0),
    [CostStatus] int  NULL,
	[ProductAttr1] int null,
	[ProductAttr2] int null,
	[ProductAttrBatchId] int null,
    [FinaMoney][decimal](25, 12) NOT NULL DEFAULT (0),
    [rowindex] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]

--@##mode:index;clustered:false;fields:contract,sort1,del
--@##mode:index;clustered:false;fields:del,company
--@##mode:index;clustered:false;fields:JoinDBListID
--@##mode:index;clustered:false;fields:addcate,id desc,date7 desc
--@##mode:index;clustered:false;fields:ord
--@##mode:index;clustered:false;fields:unit
--@##mode:index;clustered:false;fields:ku;include:FinaMoney
--@##mode:index;clustered:false;fields:company
--@##mode:index;clustered:false;fields:contractlist
--@##mode:index;clustered:false;fields:sort1,contractlist
--@##mode:index;clustered:false;fields:kuout
--@##mode:index;clustered:false;fields:date1
--@##mode:index;clustered:false;fields:xlh
--@##mode:index;clustered:false;fields:del,sort1
--@##mode:index;clustered:false;fields:del;include:ord,num1,money1,kuout,ku,sort1,unit,price1,ck,money2,contractlist,ku,FinaMoney
--@##mode:index;clustered:false;fields:M2_OrderID;include:id
--@##mode:index;clustered:false;fields:ord,del,numleft;include:id,unit,num1,kuout,M2_OrderID
--@##mode:index;clustered:false;fields:kuinlist;include:num1,kuout,del
--@##mode:index;clustered:false;fields:sort1;include:id,M2_OrderID,[kuout],[ku],[del],[FinaMoney]
--@##mode:statistics;fields:sort1,del,contract
--@##mode:statistics;fields:ku,sort1,del,contract
--@##mode:statistics;fields:num1,contract,contractlist


GO

CREATE TABLE [dbo].[M_ProgamVersion](
	[version] [decimal](25, 12) NOT NULL,
	[upTime] [datetime] NOT NULL,
	[remark] [ntext] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[errMessage](
	[ord] [int] IDENTITY(1,1) NOT NULL,
	[message] [int] NULL,
	[errNum] [int] NULL,
	[errMgs] [nvarchar](50) NULL,
    PRIMARY KEY CLUSTERED
    (
        [ord] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[kupd](
	[ord] [int] IDENTITY(1,1) NOT NULL,
	[title] [nvarchar](100) NULL,
	[ck] [int] NULL,
	[complete1] [int] NULL,
	[date3] [datetime] NULL,
	[intro] [ntext] NULL,
	[cateid] [int] NULL,
	[cateid2] [int] NULL,
	[cateid3] [int] NULL,
	[del] [int] NULL,
	[delcate] [int] NULL,
	[deldate] [datetime] NULL,
	[date7] [datetime] NULL,
	[pdbh] [nvarchar](50) NULL,
	[sort1] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [ord] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]
 TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[hr_perform_project](
	[id] [int] NOT NULL,
	[title] [nvarchar](200) NULL,
	[creator] [int] NULL,
	[inDate] [datetime] NULL,
	[editTime] [datetime] NULL,
	[del] [int] NULL,
	[prop] [int] NULL,
	[base] [int] NULL,
	[px] [int] NULL,
	[content] [text] NULL,
	[isopen] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[M_fctimelist](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[fcdate] [int] NOT NULL,
	[t1] [datetime] NOT NULL,
	[kt] [int] NOT NULL DEFAULT (0),
	[t2] [datetime] NOT NULL,
	[del] [smallint] NOT NULL DEFAULT (0),
	[remark] [varchar](100) NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC,
	[fcdate] ASC
) ON [PRIMARY]
) ON [PRIMARY]

--@##mode:index;clustered:false;fields:fcdate
--@##mode:index;clustered:false;fields:t1
--@##mode:index;clustered:false;fields:t2

GO
CREATE TABLE [dbo].[hr_test_list](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[testID] [int] NULL,
	[title] [varchar](500) NULL,
	[isanswer] [int] NULL,
	[creator] [int] NULL,
	[indate] [datetime] NULL,
	[del] [int] NOT NULL,
	[cnID] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[kupdlist](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NULL,
	[price1] [nvarchar](200) NULL,--实为备注字段
	[num1] [decimal](25, 12) NULL DEFAULT (0),
    [AssistUnit] [int] NULL,
    [AssistNum] [decimal](25, 12) NULL,
	[pd] [int] NULL,
	[ku] [int] NULL,
	[del] [int] NULL,
	[dateadd] [datetime] NULL,
	[date7] [datetime] NULL,
	[addcate] [int] NULL,
	[num2] [decimal](25, 12) NULL,
	[num3] [decimal](25, 12) NULL,
	[intro] [decimal](25, 12) NULL,
	[money1] [decimal](25, 12) NULL,
	[unit] [int] NULL,
	[ph] [nvarchar](50) NULL,
	[xlh] [nvarchar](100) NULL,
	[datesc] [datetime] NULL,
	[dateyx] [datetime] NULL,
	[bz] [int] NULL,
	[sort1] [int] NULL,
	[ckid] [int] NULL,
	[IsNoKu] [int] NULL,
    [ProductAttr1] int null,
	[ProductAttr2] int null,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[M_ReportColAttr_userdef](
	[ID] [int] NOT NULL,
	[ReportID] [int] NOT NULL,
	[ywname] [varchar](50) NOT NULL,
	[width] [varchar](20) NULL,
	[height] [varchar](20) NULL,
	[color] [varchar](20) NULL,
	[backcolor] [varchar](20) NULL,
	[align] [varchar](20) NULL,
	[display] [varchar](20) NULL,
	[uid] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[ID] ASC,
	[ReportID] ASC,
	[ywname] ASC
) ON [PRIMARY]
) ON [PRIMARY]

--@##mode:index;clustered:false;fields:ReportID
--@##mode:index;clustered:false;fields:uid

GO
CREATE TABLE [dbo].[ftpRecord](
	[ord] [int] IDENTITY(1,1) NOT NULL,
	[openRecord] [int] NULL,
	[ftpIP] [nvarchar](50) NULL,
	[ftpUser] [nvarchar](50) NULL,
	[ftpPass] [nvarchar](50) NULL,
	[addTime] [datetime] NULL,
	[cateid] [int] NULL,
	[ftpIP1] [nvarchar](100) NULL,
	[ftpUser1] [nvarchar](100) NULL,
	[ftpPass1] [nvarchar](100) NULL,
    PRIMARY KEY CLUSTERED
    (
        [ord] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[page_item](
	[Ord] [int] IDENTITY(1,1) NOT NULL,
	[TableID] [int] NULL,
	[NameUI] [varchar](50) NULL,
	[NameTable] [varchar](50) NULL,
	[PropertyUI] [varchar](50) NULL,
	[PropertyTable] [varchar](50) NULL,
	[GroupName] [varchar](50) NULL,
	[Colspan] [int] NULL,
	[Rowspan] [int] NULL,
	[Required] [bit] NULL,
	[RegType] [varchar](50) NULL,
	[Msg] [varchar](50) NULL,
	[Px] [int] NULL,
	[Display] [bit] NULL,
	[LengthMin] [int] NULL,
	[LengthMax] [int] NULL,
	[LengthShow] [int] NULL,
	[DefaultValue] [varchar](100) NULL,
	[ShowSize] [int] NULL,
	[ReadOnly] [bit] NULL,
	[GetSQLFun] [bit] NULL,
	[SQLFun] [varchar](2000) NULL,
	[Indate] [datetime] NULL,
	[Del] [int] NULL,
	[LinkNumBit] [bit] NULL,
	[LinkTable] [varchar](50) NULL,
	[LinkFiled] [varchar](50) NULL,
	[LinkFiledList] [varchar](500) NULL,
	[LinkWhereStr] [varchar](500) NULL,
	[LinkPxStr] [varchar](500) NULL,
	[LinkFileName] [varchar](50) NULL,
	[LinkBit] [bit] NULL,
	[LinkUrl] [varchar](500) NULL,
	[LinkEnCodeBit] [bit] NULL,
	[LinkType] [int] NULL,
	[LinkOpenUrl] [varchar](500) NULL,
	[AutoCodeOrd] [int] NULL,
	[AutoCodeDate] [varchar](50) NULL,
	[ListShowBit] [bit] NULL,
	[KeyBit] [bit] NULL,
	[SumPageBit] [bit] NULL,
	[TableLength] [int] NULL,
	[CreatorBit] [bit] NULL,
	[SearchBit] [bit] NULL,
	[SearchType] [int] NULL,
	[RadioStr] [varchar](500) NULL,
	[RadioVal] [varchar](500) NULL,
	[ListTable] [varchar](50) NULL,
	[UrlFiledBit] [bit] NULL,
PRIMARY KEY CLUSTERED
(
	[Ord] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[action_list2](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[cateid] [int] NULL,
	[catetime] [datetime] NULL,
	[startime] [datetime] NULL,
	[endtime] [datetime] NULL,
	[bakname] [varchar](500) NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[kuzz](
	[ord] [int] IDENTITY(1,1) NOT NULL,
	[title] [nvarchar](100) NULL,
	[ck1] [int] NULL,
	[ck2] [int] NULL,
	[complete1] [int] NULL DEFAULT (1),
	[intro] [ntext] NULL,
	[date3] [datetime] NULL,
	[cateid] [int] NULL,
	[cateid2] [int] NULL,
	[cateid3] [int] NULL,
	[date7] [datetime] NULL,
	[del] [int] NULL DEFAULT (1),
	[delcate] [int] NULL,
	[deldate] [datetime] NULL,
	[zzid] [nvarchar](50) NULL,
    [zztype] [int] NULL,
	[isnew] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [ord] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]
 TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[tel_his](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NULL,
	[sort] [nvarchar](10) NULL,
	[name] [nvarchar](100) NULL,
	[khid] [nvarchar](50) NULL,
	[area] [int] NULL,
	[trade] [int] NULL,
	[sort1] [int] NULL,
	[sort2] [int] NULL DEFAULT (1),
	[ly] [int] NULL DEFAULT (0),
	[jz] [int] NULL DEFAULT (0),
	[person] [int] NULL,
	[phone] [nvarchar](50) NULL,
	[fax] [nvarchar](50) NULL,
	[email] [nvarchar](50) NULL,
	[faren] [nvarchar](50) NULL,
	[zijin] [decimal](25, 12) NULL DEFAULT (0),
	[pernum1] [int] NULL DEFAULT (0),
	[pernum2] [int] NULL DEFAULT (0),
	[url] [nvarchar](200) NULL,
	[zip] [nvarchar](10) NULL,
	[address] [nvarchar](500) NULL,
	[gate] [nvarchar](10) NULL,
	[product] [ntext] NULL,
	[intro] [ntext] NULL,
	[c2] [ntext] NULL,
	[c3] [ntext] NULL,
	[c4] [ntext] NULL,
	[x] [nvarchar](4) NULL,
	[h] [nvarchar](4) NULL,
	[f] [nvarchar](20) NULL DEFAULT (0),
	[num1] [decimal](25, 12) NULL,
	[num2] [decimal](25, 12) NULL,
	[share] [nvarchar](1000) NULL,
	[order1] [int] NULL,
	[cateadd] [int] NULL,
	[cateorder1] [int] NULL,
	[cateid] [int] NULL,
	[cateid2] [int] NULL,
	[cateid3] [int] NULL,
	[cateid4] [int] NULL,
	[cateidgq] [int] NULL,
	[date2] [datetime] NULL,
	[date1] [datetime] NULL,
	[datepro] [datetime] NULL,
	[dategq] [datetime] NULL,
	[profect1] [int] NULL DEFAULT (0),
	[del] [int] NULL,
	[delcate] [int] NULL,
	[deldate] [datetime] NULL,
	[date8] [datetime] NULL,
	[datealt] [datetime] NULL,
	[bank_1] [nvarchar](50) NULL,
	[bank_2] [nvarchar](50) NULL,
	[bank_3] [nvarchar](50) NULL,
	[bank_4] [nvarchar](50) NULL,
	[bank_5] [nvarchar](50) NULL,
	[bank_6] [nvarchar](50) NULL,
	[bank_7] [nvarchar](50) NULL,
	[bank2_1] [nvarchar](50) NULL,
	[bank2_2] [nvarchar](50) NULL,
	[bank2_3] [nvarchar](50) NULL,
	[bank2_4] [nvarchar](50) NULL,
	[bank2_5] [nvarchar](50) NULL,
	[bank2_6] [nvarchar](50) NULL,
	[bank2_7] [nvarchar](50) NULL,
	[fkdays] [int] NULL DEFAULT (0),
	[fkdate] [int] NULL DEFAULT (0),
	[jf] [decimal](25, 12) NULL DEFAULT (0),
	[jf2] [decimal](25, 12) NULL DEFAULT (0),
	[company] [int] NULL,
	[pym] [nvarchar](100) NULL,
	[sort3] [int] NULL DEFAULT (1),
	[datelast] [datetime] NULL,
	[sortfq] [int] NULL,
	[zdy1] [nvarchar](400) NULL,
	[zdy2] [nvarchar](400) NULL,
	[zdy3] [nvarchar](400) NULL,
	[zdy4] [nvarchar](400) NULL,
	[zdy5] [int] NULL,
	[zdy6] [int] NULL,
	[hk_xz] [decimal](25, 12) NULL,
	[money1] [decimal](25, 12) NULL DEFAULT (0),
	[hmd] [int] NULL DEFAULT (0),
	[op] [varchar](20) NULL,
	[ip] [varchar](30) NULL,
	[opdate] [datetime] NOT NULL DEFAULT (getdate()),
	[sharecontact] [int] NULL DEFAULT (0),
	[ModifyStamp] [varchar](30) NULL,
	[tel_excel_drSign] [bigint] NULL,
	[tel_excel_drUser] [int] NULL,
	[sp] [int] NULL,
	[cateid_sp] [int] NULL,
	[status_sp] [int] NULL,
	[date_sp] [datetime] NULL,
	[intro_sp_cateid] [int] NULL,
	[credit] [int] NULL,
	[lat] [decimal](25, 12) NULL, --纬度
	[lng] [decimal](25, 12) NULL, --经度
	[hascoord] [int] NULL --1 已设置坐标 
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[hr_perform_result](
	[id] [int] NOT NULL,
	[title] [nvarchar](200) NULL,
	[complete] [int] NULL,
	[creator] [int] NULL,
	[inDate] [datetime] NULL,
	[editTime] [datetime] NULL,
	[del] [int] NULL
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[M_ReportColAttr](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ReportID] [int] NOT NULL,
	[ywname] [varchar](50) NOT NULL,
	[width] [varchar](20) NULL,
	[height] [varchar](20) NULL,
	[color] [varchar](20) NULL,
	[backcolor] [varchar](20) NULL,
	[align] [varchar](20) NULL,
	[display] [varchar](20) NULL,
	PRIMARY KEY CLUSTERED
	(
		[ID] ASC,
		[ReportID] ASC,
		[ywname] ASC
	) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[kuzzlist](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NULL,
	[unit] [int] NULL,
	[price1] [decimal](25,12) NULL,
	[money1] [decimal](25,12) NULL,
	[num1] [decimal](25,12) NULL DEFAULT (0),
	[kuzz] [int] NULL,
	[ck1] [int] NULL,
	[ck2] [int] NULL,
	[sort1] [int] NULL,
	[JoinDBListID] [int] NULL,
	[del] [int] NULL,
	[dateadd] [datetime] NULL,
	[date7] [datetime] NULL,
	[addcate] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[AccountMove](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[typename] [varchar](500) NULL,
	[modules] [int] NULL,
	[note] [varchar](4000) NULL,
	[sort1] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[hr_NeedPerson](
	[id] [int] NOT NULL,
	[title] [varchar](500) NULL,
	[bh] [varchar](100) NULL,
	[creator] [int] NULL,
	[id_sp] [int] NULL,
	[cateid_sp] [int] NULL,
	[TempSave] [bit] NULL,
	[indate] [datetime] NULL,
	[del] [int] NOT NULL,
	[content] [text] NULL,
	[PrefixCode] [varchar](50) NULL,
	[status] [int] NULL,
	[alt] [int] NULL
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[M_ProcessChart](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[NodeId] [int] NOT NULL,
	[PNodeId] [int] NOT NULL,
	[NodeName] [nvarchar](100) NULL,
	[PNodeName] [nvarchar](100) NULL,
	[posX] [decimal](25, 12) NULL DEFAULT (0),
	[posY] [decimal](25, 12) NULL DEFAULT (0),
	[NodeId2] [int] NULL,
	[NodeName2] [nvarchar](100) NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


--@##mode:index;clustered:false;fields:NodeId
--@##mode:index;clustered:false;fields:id
--@##mode:index;clustered:false;fields:PNodeId
--@##mode:index;clustered:false;fields:NodeId2

GO
CREATE TABLE [dbo].[learn](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NULL,
	[sort2] [int] NULL,
	[title] [nvarchar](50) NULL,
	[intro] [ntext] NULL,
	[cateid] [int] NULL,
	[date7] [datetime] NULL,
	[share] [varchar](2000) NULL,
	[alt] [varchar](3000) not null default(''),
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]
 TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[hr_perform_result_list](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[sortID] [int] NULL,
	[lower] [int] NULL,
	[limit] [int] NULL,
	[lv] [int] NULL,
	[salaryClass] [nvarchar](1000) NULL,
	[creator] [int] NULL,
	[inDate] [datetime] NULL,
	[del] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[hr_train_type](
	[id] [int] NOT NULL,
	[title] [varchar](50) NULL,
	[del] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[learn2](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NULL,
	[sort2] [int] NULL,
	[title] [nvarchar](50) NULL,
	[intro] [ntext] NULL,
	[cateid] [int] NULL,
	[date7] [datetime] NULL,
	[share] [varchar](2000) NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]
 TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[page_process](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[title] [varchar](100) NULL,
	[px] [int] NULL,
	[sortID] [int] NULL,
	[indate] [datetime] NULL,
	[creator] [int] NULL,
	[del] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[learn4](
	[id] [int] NOT NULL,
	[ord] [int] NULL,
	[sort1] [int] NULL,
	[sort1c] [nvarchar](10) NULL,
	[title] [nvarchar](50) NULL,
	[intro] [nvarchar](200) NULL,
	[gate] [int] NULL,
	[date] [smalldatetime] NULL
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[hr_perform_score](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[score] [decimal](25, 12) NULL,
	[perform] [int] NULL,
	[cateid] [int] NULL,
	[sp_id] [int] NULL,
	[project] [int] NULL,
	[typeid] [int] NULL,
	[creator] [int] NULL,
	[inDate] [datetime] NULL,
	[del] [int] NULL,
    [sp] [int] Null,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[learnhd](
	[ord] [int] IDENTITY(1,1) NOT NULL,
	[title] [nvarchar](50) NULL,
	[intro] [ntext] NULL,
	[share] [varchar](max) NULL,
	[cateid] [int] NULL,
	[date7] [datetime] NULL,
	[alt] [varchar](4000) NULL DEFAULT (0),
	[sort2] [int] NULL,
	[del] [int] NULL,
	[delcate] [int] NULL,
	[deldate] [datetime] NULL,
	[clicknum] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [ord] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]
 TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[hr_process](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[cnID] [int] NULL,
	[orderID] [int] NULL,
	[title] [varchar](100) NULL,
	[px] [int] NULL,
	[sortID] [int] NULL,
	[indate] [datetime] NULL,
	[creator] [int] NULL,
	[del] [int] NULL,
	[content] [text] NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[hr_NeedPerson_list](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[NeedPerson] [int] NULL,
	[sorce] [int] NULL,
	[sorce2] [int] NULL,
	[postion] [int] NULL,
	[num] [int] NULL,
	[needDate] [datetime] NULL,
	[content] [text] NULL,
	[belongID] [int] NULL,
	[source] [int] NULL,
	[creator] [int] NULL,
	[indate] [datetime] NULL,
	[del] [int] NULL,
	[isplan] [int] NULL,
	[HadNum] [int] NULL,
	[cnID] [int] NULL,
	[statusID] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[learnimg](
	[id] [int] NOT NULL,
	[ord] [int] NULL,
	[sort2] [int] NULL,
	[title] [nvarchar](50) NULL,
	[intro] [nvarchar](100) NULL,
	[name] [ntext] NULL,
	[cateid] [int] NULL,
	[date] [smalldatetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[M_OutOrderLists_yfk](
	[ID] [int] NOT NULL,
	[outID] [int] NOT NULL,
	[money1] [decimal](25, 12) NOT NULL,
	[date1] [datetime] NOT NULL,
	[remark] [nvarchar](200) NULL,
	[del] [int] NULL,
	[id_proxy] [int] IDENTITY(1,1) NOT NULL,
    PRIMARY KEY CLUSTERED
    (
        [id_proxy] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]

--@##mode:index;clustered:false;fields:date1
--@##mode:index;clustered:false;fields:ID
--@##mode:index;clustered:false;fields:outID
--@##mode:index;clustered:false;fields:date1

GO
CREATE TABLE [dbo].[M_billThreadControl](
	[oid] [int] NOT NULL,
	[bid] [int] NOT NULL,
	[sctype] [int] NOT NULL,
	[uid] [int] NOT NULL,
	[date] [datetime] NOT NULL
) ON [PRIMARY]

--@##mode:index;clustered:true;fields:bid
--@##mode:index;clustered:false;fields:date
--@##mode:index;clustered:false;fields:oid
--@##mode:index;clustered:false;fields:bid
--@##mode:index;clustered:false;fields:uid
--@##mode:index;clustered:false;fields:date

GO
CREATE TABLE [dbo].[hr_perform_sort](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[title] [nvarchar](200) NULL,
	[project_list] [text] NULL,
	[user_list] [text] NULL,
	[startTime] [datetime] NULL,
	[endTime] [datetime] NULL,
	[sortid] [int] NULL,
	[sp_complete] [int] NULL,
	[Appeal] [int] NULL,
	[isall] [int] NULL,
	[creator] [int] NULL,
	[inDate] [datetime] NULL,
	[editTime] [datetime] NULL,
	[del] [int] NULL,
	[salary_time] [datetime] NULL,
	[sp_Time1] [datetime] NULL,
	[sp_Time2] [datetime] NULL,
	[sp_lv] [int] NULL,
	[salaryClass] [int] NULL,
	[ss_Time1] [datetime] NULL,
	[ss_Time2] [datetime] NULL,
	[ss_person] [int] NULL,
	[project_string] [ntext] NULL,
	[sp_list_string] [ntext] NULL,
	[khzt] int DEFAULT (0),
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]
 TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[O_carSet](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[setType] [int] NULL,
	[setName] [varchar](200) NULL,
	[setSort] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[hr_train_plan](
	[id] [int] NOT NULL,
	[PrefixCode] [varchar](4) NULL,
	[title] [varchar](100) NULL,
	[sortid] [int] NULL,
	[bh] [varchar](100) NULL,
	[form] [int] NULL,
	[startTime] [datetime] NULL,
	[endTime] [datetime] NULL,
	[Trainer] [varchar](100) NULL,
	[cost] [decimal](25, 12) NULL,
	[address] [varchar](500) NULL,
	[content] [text] NULL,
	[user_list] [nvarchar](3000) NULL,
	[creator] [int] NULL,
	[id_sp] [int] NULL,
	[cateid_sp] [int] NULL,
	[TempSave] [bit] NULL,
	[indate] [datetime] NULL,
	[del] [int] NOT NULL,
	[status] [int] NULL,
	[statusID] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[learnqb](
	[id] [int] NOT NULL,
	[ord] [int] NULL,
	[sort1] [int] NULL,
	[sort1c] [nvarchar](10) NULL,
	[sort2] [int] NULL,
	[sort2c] [nvarchar](10) NULL,
	[title] [nvarchar](50) NULL,
	[intro] [ntext] NULL,
	[cateid] [int] NULL,
	[date] [smalldatetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[page_table](
	[Ord] [int] IDENTITY(1,1) NOT NULL,
	[NameUI] [varchar](50) NULL,
	[NameTable] [varchar](50) NULL,
	[QxSort1] [int] NULL,
	[ShowRow] [int] NULL,
	[Key] [varchar](50) NULL,
	[DelList] [bit] NULL,
	[Indate] [datetime] NULL,
	[Px] [int] NULL,
	[Del] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[Ord] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[O_carDriver](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[phone] [varchar](200) NULL,
	[drivername] [varchar](200) NULL,
	[mobile] [varchar](200) NULL,
	[mobile2] [varchar](200) NULL,
	[addr] [varchar](3000) NULL,
	[addcateid] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[learnqb2](
	[id] [int] NOT NULL,
	[ord] [int] NULL,
	[sort1] [int] NULL,
	[sort1c] [nvarchar](10) NULL,
	[sort2] [int] NULL,
	[sort2c] [nvarchar](10) NULL,
	[title] [nvarchar](50) NULL,
	[intro] [ntext] NULL,
	[cateid] [int] NULL,
	[date] [smalldatetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[hr_perform_sp](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[title] [nvarchar](200) NULL,
	[creator] [int] NULL,
	[inDate] [datetime] NULL,
	[del] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[hr_person_contract](
	[id] [int] NOT NULL,
	[title] [varchar](200) NULL,
	[bh] [varchar](100) NULL,
	[sortID] [int] NULL,
	[partA] [int] NULL,
	[partB] [int] NULL,
	[startDate] [datetime] NULL,
	[endDate] [datetime] NULL,
	[content] [text] NULL,
	[creator] [int] NULL,
	[id_sp] [int] NULL,
	[status] [int] NULL,
	[cateid_sp] [int] NULL,
	[TempSave] [bit] NULL,
	[indate] [datetime] NULL,
	[del] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[O_carData](
	[car_id] [int] IDENTITY(1,1) NOT NULL,
	[car_code] [varchar](200) NULL,
	[car_type] [int] NULL,
	[car_name] [varchar](200) NULL,
	[car_xh] [varchar](200) NULL,
	[car_fdjh] [varchar](200) NULL,
	[car_dph] [varchar](200) NULL,
	[car_pl] [varchar](200) NULL,
	[car_maxnum] [int] NULL,
	[car_color] [int] NULL,
	[car_buytime] [datetime] NULL,
	[car_buymoney] [decimal](25, 12) NULL,
	[car_buycompany] [varchar](2000) NULL,
	[car_state] [int] NULL DEFAULT (1),
	[car_other] [varchar](2000) NULL,
	[car_photo] [varchar](200) NULL,
	[car_driver] [int] NULL,
	[car_phone] [varchar](30) NULL,
	[car_mobile] [varchar](30) NULL,
	[car_mobile2] [varchar](30) NULL,
	[car_dirveradd] [varchar](2000) NULL,
	[car_zdy1] [varchar](200) NULL,
	[car_zdy2] [varchar](200) NULL,
	[car_zdy3] [varchar](200) NULL,
	[car_zdy4] [varchar](200) NULL,
	[car_zdy5] [varchar](200) NULL,
	[car_zdy6] [varchar](200) NULL,
	[car_zdy7] [int] NULL,
	[car_zdy8] [int] NULL,
	[car_zdy9] [datetime] NULL,
	[car_note] [text] NULL,
	[car_addtime] [datetime] NULL,
	[car_addcateid] [int] NULL,
	[car_del] [int] NULL DEFAULT (1),
	[del] [int] not null default(1),
	[delcate][int],
	[deldate][datetime],
    PRIMARY KEY CLUSTERED
    (
        [car_id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]
 TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[home_maincards_def](
	[ID] [int] NOT NULL,
	[cardClass] [varchar](50) NOT NULL,
	[title] [varchar](100) NOT NULL,
	[ranking] [int] NULL,
	[sql] [varchar](250) NOT NULL,
	[sql2] [varchar](250) NOT NULL,
	[colspan] [int] NOT NULL,
	[maxspan] [int] NOT NULL,
	[sort] [int] NOT NULL,
	[qxlb] [int] NOT NULL,
	[qxlblist] [int] NOT NULL,
	[model] [varchar](500) null,
	[powers] [varchar](500) null,
	[mustadmin] [int] NOT NULL,
	[canadd] [int] NOT NULL,
	[canset] [int] NOT NULL,
	[canmore] [int] NOT NULL,
	[canclose] [int] NOT NULL,
	[visible] [int] NOT NULL,
	[monthjs] [int] NOT NULL DEFAULT ('0'),
	[defjs] [varchar](300) NOT NULL DEFAULT ('0'),
	[gjjs] [int] NOT NULL DEFAULT ('0'),
	[attrs] [varchar](1000) not null DEFAULT (''),
	[setJM]	[int] NOT NULL DEFAULT ('0'),
	[fw] [varchar](100) NOT NULL DEFAULT (''),
	[defRows] [int] NOT NULL DEFAULT ('0'),
	[canqt] [int] NOT NULL DEFAULT ('0'),
    [addUrl] [varchar](50) Null,
	[addqxlb] [int] null
PRIMARY KEY CLUSTERED
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[learntz](
	[ord] [int] IDENTITY(1,1) NOT NULL,
	[sort2] [int] NULL,
	[title] [nvarchar](50) NULL,
	[intro] [ntext] NULL,
	[cateid] [int] NULL,
	[date7] [datetime] NULL,
	[del] [int] NULL,
	[delcate] [int] NULL,
	[deldate] [datetime] NULL,
	[alt] [nvarchar](4000) NULL DEFAULT (0),
    PRIMARY KEY CLUSTERED
    (
        [ord] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]
 TEXTIMAGE_ON [PRIMARY]

--@##mode:index;clustered:false;fields:ord,del;include:title,cateid,date7,alt
--@##mode:index;clustered:false;fields:del;include:ord,title,cateid,date7,alt

GO
CREATE TABLE [dbo].[M_PlanBomList](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[planlistID] [int] NOT NULL,
	[parentBomID] [int] NOT NULL,
	[BomID] [int] NOT NULL,
	[productID] [int] NOT NULL,
	[MRPID] [int] NULL,
	[RankCode] [smallint] NULL,
	[unit] [int] NULL,
	[num] [decimal](25, 12) NULL,
	[StoreID] [int] NULL,
	[WProc] [int] NULL,
	[PCWastage] float Not NULL default (0),
	[SourceBomNode] [int] NULL,
	[Role] [smallint] NULL,
	[OrdCode] [varchar](500) NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

--@##mode:index;clustered:false;fields:planlistID
--@##mode:index;clustered:false;fields:BomID
--@##mode:index;clustered:false;fields:parentBomID
--@##mode:index;clustered:false;fields:productID
--@##mode:index;clustered:false;fields:MRPID
--@##mode:index;clustered:false;fields:unit
--@##mode:index;clustered:false;fields:StoreID
--@##mode:index;clustered:false;fields:WProc
--@##mode:index;clustered:false;fields:SourceBomNode

GO
CREATE TABLE [dbo].[salesTarget](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[charTitle] [nvarchar](100) NULL,
	[charDesc] [ntext] NULL,
	[intStatus] [smallint] NULL,
	[addcate] [int] NULL DEFAULT (0),
	[adddate] [datetime] NULL DEFAULT (getdate()),
	[intYear] [int] NULL,
	[fromDate] [datetime] NULL,
	[toDate] [datetime] NULL,
	[sp] [int] NULL DEFAULT (0),
	[spid] [int] NULL,
	[del] [smallint] NULL,
	[fromId] [int] NULL DEFAULT (0),
	[sorce] [int] NULL DEFAULT (0),
	[sorce2] [int] NULL DEFAULT (0),
	[cateid] [int] NULL DEFAULT (0),
	[sort] [smallint] NULL DEFAULT (0),
	[receiverId] [int] NULL DEFAULT (0),
	[receiverDate] [datetime] NULL,
	[targetValue] [decimal](25, 12) NULL,
	[periodId] [int] NULL,
	[periodRoleId] [int] NULL,
	[fromId2] [int] NULL DEFAULT (0),
	[isDep] [int] NULL,
	[ModifyStamp] [varchar](50) NULL,
PRIMARY KEY CLUSTERED
(
	[Id] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[hr_Resume](
	[id] [int] NOT NULL,
	[userName] [nvarchar](50) NULL,
	[bh] [nvarchar](100) NULL,
	[postion] [int] NULL,
	[postionName] [nvarchar](50) NULL,
	[sex] [nvarchar](50) NULL,
	[chineseBirth] [int] NULL,
	[birthday] [datetime] NULL,
	[cardType] [int] NULL,
	[cardID] [nvarchar](50) NULL,
	[workyear] [nvarchar](50) NULL,
	[email] [nvarchar](50) NULL,
	[AnnualSalary] [nvarchar](50) NULL,
	[mobile] [nvarchar](50) NULL,
	[hometel] [nvarchar](50) NULL,
	[officetel] [nvarchar](50) NULL,
	[jobstatus] [nvarchar](50) NULL,
	[Account] [nvarchar](100) NULL,
	[keyword] [nvarchar](500) NULL,
	[height] [nvarchar](50) NULL,
	[Maryy] [nvarchar](50) NULL,
	[QQ] [nvarchar](50) NULL,
	[edu] [nvarchar](50) NULL,
	[nowAddress] [nvarchar](500) NULL,
	[address] [nvarchar](500) NULL,
	[zipcode] [nvarchar](50) NULL,
	[isfulltime] [nvarchar](50) NULL,
	[Workarea] [nvarchar](50) NULL,
	[Industries] [nvarchar](50) NULL,
	[funts] [nvarchar](500) NULL,
	[needSalary] [nvarchar](50) NULL,
	[Dutytime] [nvarchar](50) NULL,
	[about] [nvarchar](500) NULL,
	[indate] [datetime] NULL,
	[creator] [int] NULL,
	[id_sp] [int] NULL,
	[cateid_sp] [int] NULL,
	[status] [int] NULL,
	[TempSave] [bit] NULL,
	[content] [text] NULL,
	[planID] [int] NULL,
	[del] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[M_ProgresReturnLists](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[PRID] [int] NOT NULL,
	[QTLID] [int] NOT NULL,
	[num1] [decimal](25, 12) NULL,
	[del] [int] NOT NULL,
    PRIMARY KEY CLUSTERED
    (
        [ID] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


--@##mode:index;clustered:false;fields:PRID
--@##mode:index;clustered:false;fields:QTLID
--@##mode:index;clustered:false;fields:id

GO
CREATE TABLE [dbo].[leftlist](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[sort1] [int] NULL DEFAULT (1),
	[cateid] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[hr_perform_sp_list](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[title] [varchar](200) NULL,
	[sortID] [int] NULL,
	[lv] [int] NULL,
	[base] [int] NULL,
	[prop] [int] NULL,
	[creator] [int] NULL,
	[inDate] [datetime] NULL,
	[del] [int] NULL,
	[user_list] [text] NULL,
	[sp_id] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]
 TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[hr_transfer](
	[id] [int] NOT NULL,
	[title] [varchar](200) NULL,
	[bh] [varchar](100) NULL,
	[cateName] [varchar](50) NULL,
	[cateBh] [varchar](100) NULL,
	[content] [text] NULL,
	[sortID] [int] NULL,
	[ysorceName] [varchar](50) NULL,
	[ysorce2Name] [varchar](50) NULL,
	[ysorce] [int] NULL,
	[ysorce2] [int] NULL,
	[ypostion] [varchar](50) NULL,
	[sorce] [int] NULL,
	[sorce2] [int] NULL,
	[startTime] [datetime] NULL,
	[postion] [varchar](50) NULL,
	[status] [int] NULL,
	[creator] [int] NULL,
	[indate] [datetime] NULL,
	[id_sp] [int] NULL,
	[cateid_sp] [int] NULL,
	[addcate] [int] NULL,
	[TempSave] [bit] NULL,
	[del] [int] NULL,
	[cateid] [int] NULL,
	[postionID] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[linshi](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[num1] [decimal](25, 12) NULL DEFAULT (0),
	[num2] [decimal](25, 12) NULL DEFAULT (0),
	[num3] [decimal](25, 12) NULL DEFAULT (0),
	[num4] [decimal](25, 12) NULL DEFAULT (0),
	[num5] [decimal](25, 12) NULL DEFAULT (0),
	[num6] [decimal](25, 12) NULL DEFAULT (0),
	[num7] [decimal](25, 12) NULL DEFAULT (0),
	[num8] [decimal](25, 12) NULL DEFAULT (0),
	[num9] [decimal](25, 12) NULL DEFAULT (0),
	[num10] [decimal](25, 12) NULL DEFAULT (0),
	[num11] [decimal](25, 12) NULL DEFAULT (0),
	[num12] [decimal](25, 12) NULL DEFAULT (0),
	[money1] [decimal](25, 12) NULL DEFAULT (0),
	[money2] [decimal](25, 12) NULL DEFAULT (0),
	[money3] [decimal](25, 12) NULL DEFAULT (0),
	[money4] [decimal](25, 12) NULL DEFAULT (0),
	[money5] [decimal](25, 12) NULL DEFAULT (0),
	[money6] [decimal](25, 12) NULL DEFAULT (0),
	[money7] [decimal](25, 12) NULL DEFAULT (0),
	[money8] [decimal](25, 12) NULL DEFAULT (0),
	[money9] [decimal](25, 12) NULL DEFAULT (0),
	[money10] [decimal](25, 12) NULL DEFAULT (0),
	[money11] [decimal](25, 12) NULL DEFAULT (0),
	[money12] [decimal](25, 12) NULL DEFAULT (0),
	[sum1] [decimal](25, 12) NULL DEFAULT (0),
	[sum2] [decimal](25, 12) NULL DEFAULT (0),
	[sum3] [decimal](25, 12) NULL DEFAULT (0),
	[sum4] [decimal](25, 12) NULL DEFAULT (0),
	[sum5] [decimal](25, 12) NULL DEFAULT (0),
	[sum6] [decimal](25, 12) NULL DEFAULT (0),
	[sum7] [decimal](25, 12) NULL DEFAULT (0),
	[sum8] [decimal](25, 12) NULL DEFAULT (0),
	[sum9] [decimal](25, 12) NULL DEFAULT (0),
	[sum10] [decimal](25, 12) NULL DEFAULT (0),
	[sum11] [decimal](25, 12) NULL DEFAULT (0),
	[sum12] [decimal](25, 12) NULL DEFAULT (0),
	[summ1] [decimal](25, 12) NULL DEFAULT (0),
	[summ2] [decimal](25, 12) NULL DEFAULT (0),
	[summ3] [decimal](25, 12) NULL DEFAULT (0),
	[summ4] [decimal](25, 12) NULL DEFAULT (0),
	[summ5] [decimal](25, 12) NULL DEFAULT (0),
	[summ6] [decimal](25, 12) NULL DEFAULT (0),
	[summ7] [decimal](25, 12) NULL DEFAULT (0),
	[summ8] [decimal](25, 12) NULL DEFAULT (0),
	[summ9] [decimal](25, 12) NULL DEFAULT (0),
	[summ10] [decimal](25, 12) NULL DEFAULT (0),
	[summ11] [decimal](25, 12) NULL DEFAULT (0),
	[summ12] [decimal](25, 12) NULL,
	[ord] [int] NULL,
	[cateid] [int] NULL,
	[date7] [datetime] NULL,
	[sumn2] [decimal](25, 12) NULL,
	[sumn3] [decimal](25, 12) NULL,
	[sumn4] [decimal](25, 12) NULL,
	[sumn5] [decimal](25, 12) NULL,
	[sumn6] [decimal](25, 12) NULL,
	[sumn7] [decimal](25, 12) NULL,
	[sumn8] [decimal](25, 12) NULL,
	[sumn9] [decimal](25, 12) NULL,
	[sumn10] [decimal](25, 12) NULL,
	[sumn11] [decimal](25, 12) NULL,
	[sumn12] [decimal](25, 12) NULL,
	[sumn1] [decimal](25, 12) NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[sp_schedule](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[charName] [varchar](50) NULL,
	[intLevel] [int] NULL,
	[charSpId] [varchar](2000) NULL,
	[charBySpId] [varchar](1000) NULL,
	[dtCreate] [datetime] NULL DEFAULT (getdate()),
	[time1] [decimal](25, 12) NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[Sale_CallBack](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[title] [varchar](200) NULL,
	[company] [int] NULL,
	[person] [int] NULL,
	[StatusID] [int] NULL,
	[typeID] [int] NULL,
	[ybackTime] [datetime] NULL,
	[ServerTime] [datetime] NULL,
	[cateid] [int] NULL,
	[IsNextBack] [bit] NULL,
	[content] [text] NULL,
	[remark] [text] NULL,
	[hfID] [int] NULL,
	[Creator] [int] NULL,
	[Indate] [datetime] NULL,
	[Del] [int] NULL,
	[procsID] [int] NULL,
	[projdID] [int] NULL,
	[person_kh] [int] NULL,
	[manyi] [decimal](25, 12) NULL,
	[setalt] [int] NULL,
	[Itype]	[int] NULL,
	[tb_id] [int] NULL,
	[isback] [int] NULL,  --回访状态 0 未回访 1 已回访
	[endtype] [int] NULL, --回访结束方式
	[endIntro] [nvarchar](100) NULL,--终止原因
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

--@##mode:statistics;fields:Indate,company,ybackTime,id,Del
--@##mode:statistics;fields:cateid,person_kh,typeID,projdID,procsID,company
--@##mode:statistics;fields:Del,cateid,person_kh,typeID,projdID,procsID,company,Indate,ybackTime,id

GO

CREATE TABLE [dbo].[O_carUse](
	[use_id] [int] IDENTITY(1,1) NOT NULL,
	[use_source] [int] NULL,
	[use_cateid] [int] NULL,
	[use_type] [int] NULL,
	[use_complete] [int] NULL DEFAULT (1),
	[use_id_sp] [int] NULL,
	[use_cateid_sp] [int] NULL,
	[use_sms_sp] [int] NULL DEFAULT (1),
	[use_sms_driver] [int] NULL DEFAULT (1),
	[use_sms_cateid] [int] NULL DEFAULT (1),
	[use_zdy1] [varchar](200) NULL,
	[use_zdy2] [varchar](200) NULL,
	[use_zdy3] [varchar](200) NULL,
	[use_zdy4] [varchar](200) NULL,
	[use_zdy5] [int] NULL,
	[use_zdy6] [int] NULL,
	[use_note] [text] NULL,
	[use_addtime] [datetime] NULL,
	[use_addcateid] [int] NULL,
	[use_del] [int] NULL DEFAULT (1),
	[ModifyStamp] [varchar](200) NULL DEFAULT (1),
	[alt] [int] NULL,
	[del] [int] not null default(1),
	[delcate][int],
	[deldate][datetime],
    PRIMARY KEY CLUSTERED
    (
        [use_id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]
 TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[callSet](
	[ord] [int] IDENTITY(1,1) NOT NULL,
	[Company] [nvarchar](50) NULL,
	[Object] [nvarchar](50) NULL,
	[Model] [nvarchar](50) NULL,
	[IncFileIndex] [text] NULL,
	[IncFileJsUrl] [text] NULL,
	[IncFileJsChannel] [text] NULL,
	[IncFileJsSerial] [text] NULL,
	[SubOffHook] [nvarchar](50) NULL,
	[SubCall] [nvarchar](50) NULL,
	[SubHangUp] [nvarchar](50) NULL,
	[AddTime] [datetime] NULL,
	[Del] [int] NULL,
	[Cateid] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [ord] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]
 TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[load](
	[id] [int] NOT NULL,
	[ext] [nvarchar](10) NULL,
	[name] [nvarchar](100) NULL,
	[title] [nvarchar](50) NULL,
	[path] [nvarchar](100) NULL,
	[size] [int] NULL,
	[sumtime] [smalldatetime] NULL,
	[sort] [int] NULL,
	[cateid] [int] NULL
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[hr_perform_ss](
	[id] [int] NOT NULL,
	[title] [nvarchar](200) NULL,
	[perform_sortid] [int] NULL,
	[PrefixCode] [nvarchar](200) NULL,
	[content] [text] NULL,
	[result] [text] NULL,
	[creator] [int] NULL,
	[inDate] [datetime] NULL,
	[status] [int] NULL,
	[id_sp] [int] NULL,
	[cateid_sp] [int] NULL,
	[spdate] [datetime] NULL,
	[del] [int] NULL,
	[ModifyStamp] [int] NULL,
	[changePerform] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[home_maincards_us](
	[ID] [int] NOT NULL,
	[cardClass] [varchar](50) NOT NULL,
	[title] [varchar](100) NOT NULL,
	[sql] [varchar](250) NOT NULL,
	[sql2] [varchar](250) NOT NULL,
	[colspan] [int] NOT NULL,
	[maxspan] [int] NOT NULL,
	[sort] [int] NOT NULL,
	[qxlb] [int] NOT NULL,
	[qxlblist] [int] NOT NULL,
	[model] [varchar](500) null,
	[powers] [varchar](500) null,
	[mustadmin] [int] NOT NULL,
	[canadd] [int] NOT NULL,
	[canset] [int] NOT NULL,
	[canmore] [int] NOT NULL,
	[canclose] [int] NOT NULL,
	[uid] [int] NOT NULL,
	[visible] [int] NOT NULL,
	[monthjs] [int] NOT NULL DEFAULT ('0'),
	[defjs] [varchar](300) NOT NULL DEFAULT ('0'),
	[gjjs] [int] NOT NULL DEFAULT ('0'),
	[attrs] [varchar](1000) NOT NULL DEFAULT (''),
	[setJM]	[int] NOT NULL DEFAULT ('0'),
	[fw] [varchar](100) NOT NULL DEFAULT (''),
	[defRows] [int] NOT NULL DEFAULT ('0'),
	[canqt] [int] NOT NULL DEFAULT ('0'),
    [nClsPosId] [int],
PRIMARY KEY CLUSTERED
(
	[ID] ASC,
	[uid] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[loadxm](
	[id] [int] NOT NULL,
	[ord] [int] NULL,
	[title] [nvarchar](50) NULL,
	[intro] [nvarchar](100) NULL,
	[name] [ntext] NULL,
	[event1] [int] NULL,
	[cateid] [int] NULL,
	[cateid2] [nvarchar](50) NULL,
	[date] [smalldatetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[zbintelsafestate](
	[state] [datetime] NOT NULL
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[updateattrs](
	[dat] [varchar](100) NULL
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[hr_Work_exp](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Resume] [int] NULL,
	[startDate] [datetime] NULL,
	[endDate] [datetime] NULL,
	[typeID] [varchar](50) NULL,
	[size] [varchar](50) NULL,
	[Industries] [varchar](50) NULL,
	[Department] [varchar](50) NULL,
	[Position] [varchar](50) NULL,
	[jobDes] [nvarchar](4000) NULL,
	[workAbroad] [varchar](50) NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[M_ProgresReturns](
	[ID] [int] NOT NULL,
	[PrefixCode] [nvarchar](2) NOT NULL,
	[QTID] [int] NOT NULL,
	[PRBH] [nvarchar](50) NOT NULL,
	[title] [nvarchar](100) NULL,
	[Creator] [int] NULL,
	[indate] [datetime] NULL,
	[status] [int] NULL,
	[CateID_sp] [int] NULL,
	[id_sp] [int] NULL,
	[TempSave] [int] NULL,
	[del] [int] NOT NULL,
	[ddno] [int] NOT NULL DEFAULT (0),
PRIMARY KEY CLUSTERED
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]

--@##mode:index;clustered:false;fields:PrefixCode
--@##mode:index;clustered:false;fields:QTID
--@##mode:index;clustered:false;fields:Creator
--@##mode:index;clustered:false;fields:ddno
--@##mode:index;clustered:false;fields:indate desc

GO
CREATE TABLE [dbo].[make_gx](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[title] [nvarchar](50) NULL,
	[cateid] [int] NULL,
	[date7] [datetime] NULL,
	[del] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[plan2](
	[ord] [int] IDENTITY(1,1) NOT NULL,
	[intro] [ntext] NULL,
	[gate] [int] NULL,
	[complete] [nvarchar](10) NULL,
	[sort1] [int] NULL,
	[date1] [datetime] NULL,
	[time1] [nvarchar](50) NULL,
	[time2] [nvarchar](50) NULL,
	[order1] [nvarchar](20) NULL,
	[intro2] [ntext] NULL,
	[cateid] [int] NULL,
	[cateid2] [int] NULL,
	[cateid3] [int] NULL,
	[company] [int] NULL,
	[person] [int] NULL,
	[option1] [int] NULL,
	[chance] [int] NULL,
	[lcb] [int] NULL,
	[contract] [int] NULL,
	[pay] [nvarchar](50) NULL,
	[date7] [datetime] NULL,
	[date4] [datetime] NULL,
	[date8] [datetime] NULL,
	[type] [smallint] NULL,
	[addcatename] [nvarchar](100) NULL,
	[spid] [int] NULL,
	[spname] [nvarchar](100) NULL,
	[alt] [int] NULL,
PRIMARY KEY NONCLUSTERED
(
	[ord] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[M_ManuOrderWL](
	[ID] [bigint] NOT NULL,
	[bomlistID] [int] NOT NULL,
	[productID] [int] NOT NULL,
	[ddno] [int] NOT NULL,
	[ddlistid] [int] NOT NULL,
	[inDate] [datetime] NOT NULL,
	[creator] [int] NOT NULL,
	[num] [decimal](25, 12) NOT NULL,
	[remark] [nvarchar](200) NULL,
	[del] [int] NOT NULL DEFAULT (0),
	[userdef] [int] NOT NULL DEFAULT (0),
	[StoreMethod] [int] NOT NULL DEFAULT (0),
PRIMARY KEY CLUSTERED
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[make_gxlist](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[gx] [int] NULL,
	[gxord] [int] NULL,
	[gate1] [int] NULL,
	[del] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[sale_Complaints](
	[id] [int] NOT NULL,
	[PrefixCode] [varchar](20) NULL,
	[title] [varchar](200) NULL,
	[bh] [varchar](200) NULL,
	[company] [int] NULL,
	[person] [int] NULL,
	[ServerTime] [datetime] NULL,
	[cateid] [int] NULL,
	[modeID] [int] NULL,
	[sortID] [int] NULL,
	[lastTime] [datetime] NULL,
	[content] [text] NULL,
	[product] [int] NULL,
	[remark] [text] NULL,
	[Respondent] [int] NULL,
	[NextOperator] [int] NULL,
	[IsSendMail] [bit] NULL,
	[IsSendSMS] [bit] NULL,
	[status] [int] NULL,
	[indate] [datetime] NULL,
	[creator] [int] NULL,
	[alt] [int] NULL,
	[del] [int] NULL,
	[wxUserID] [int] NULL
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

--处理结果
create TABLE [dbo].[sale_Complaints_result](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NULL,
	[typeID] [int] NULL, --1 投诉 2.
	[result] [int] NULL,
	[content] [nvarchar](max) NULL,
	[indate] [datetime] NULL,
	[creator] [int] NULL,
	[del] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

CREATE TABLE [dbo].[make_jd](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[gx] [int] NULL,
	[date1] [datetime] NULL,
	[date2] [datetime] NULL,
	[jh] [int] NULL,
	[date7] [datetime] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[person_his](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NULL,
	[name] [nvarchar](50) NULL,
	[sex] [nvarchar](10) NULL,
	[age] [nvarchar](10) NULL,
	[jg] [nvarchar](50) NULL,
	[part1] [nvarchar](30) NULL,
	[job] [nvarchar](30) NULL,
	[phone] [nvarchar](50) NULL,
	[phone2] [nvarchar](50) NULL,
	[fax] [nvarchar](50) NULL,
	[mobile] [nvarchar](50) NULL,
	[email] [nvarchar](50) NULL,
	[msn] [nvarchar](50) NULL,
	[qq] [nvarchar](20) NULL,
	[zip] [nvarchar](10) NULL,
	[address] [nvarchar](500) NULL,
	[photos] [nvarchar](500) NULL,
	[gate] [nvarchar](10) NULL,
	[year1] [varchar](20) NULL,
	[joy] [ntext] NULL,
	[company] [int] NULL,
	[area] [nvarchar](20) NULL,
	[sort] [nvarchar](20) NULL,
	[sort1] [nvarchar](20) NULL,
	[trade] [nvarchar](20) NULL,
	[intro] [ntext] NULL,
	[event] [int] NULL,
	[chance] [int] NULL,
	[plan1] [int] NULL,
	[numc1] [int] NULL,
	[order1] [int] NULL,
	[xl] [nvarchar](50) NULL,
	[xw] [nvarchar](50) NULL,
	[zy] [nvarchar](50) NULL,
	[yx] [nvarchar](50) NULL,
	[mz] [nvarchar](50) NULL,
	[mobile2] [nvarchar](50) NULL,
	[sg] [nvarchar](50) NULL,
	[tz] [nvarchar](50) NULL,
	[tx] [nvarchar](50) NULL,
	[xm] [nvarchar](50) NULL,
	[xy] [nvarchar](10) NULL,
	[xyname] [nvarchar](50) NULL,
	[yj] [nvarchar](10) NULL,
	[yjsort] [nvarchar](50) NULL,
	[yjname] [nvarchar](50) NULL,
	[yjsize] [nvarchar](50) NULL,
	[hc] [nvarchar](10) NULL,
	[hcsort] [nvarchar](50) NULL,
	[jk] [nvarchar](50) NULL,
	[jb] [nvarchar](50) NULL,
	[jz] [nvarchar](10) NULL,
	[sc] [nvarchar](10) NULL,
	[scsort] [nvarchar](50) NULL,
	[scys] [nvarchar](50) NULL,
	[scpz] [nvarchar](50) NULL,
	[tezheng] [nvarchar](50) NULL,
	[person] [int] NULL,
	[gx] [nvarchar](50) NULL,
	[cateid] [int] NULL,
	[cateid2] [int] NULL,
	[cateid3] [int] NULL,
	[date7] [datetime] NULL,
	[date4] [datetime] NULL,
	[date5] [datetime] NULL,
	[del] [int] NULL,
	[delcate] [int] NULL,
	[deldate] [datetime] NULL,
	[date8] [datetime] NULL,
	[pym] [nvarchar](50) NULL,
	[sort3] [int] NULL DEFAULT (1),
	[tezhen] [nvarchar](50) NULL,
	[alt] [varchar](4) NOT NULL DEFAULT (0),
	[op] [varchar](20) NULL,
	[ip] [varchar](30) NULL,
	[opdate] [datetime] NOT NULL DEFAULT (getdate()),
	[birthdayType] [int] NULL DEFAULT (0),
	[person_excel_drSign] [bigint] NULL,
	[person_excel_drUser] [int] NULL,
	[role] [int] NULL,
	[weixinAcc] [nvarchar](100),
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

--@##mode:statistics;fields:opdate,del
--@##mode:statistics;fields:company,del,opdate

GO
CREATE TABLE [dbo].[hr_person_work](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[cateid] [int] NULL,
	[startdate] [datetime] NULL,
	[enddate] [datetime] NULL,
	[companyName] [nvarchar](200) NULL,
	[position] [varchar](200) NULL,
	[content] [text] NULL,
	[retults] [text] NULL,
	[Reason] [text] NULL,
	[provePerson] [nvarchar](200) NULL,
	[tel] [varchar](200) NULL,
	[creator] [int] NULL,
	[indate] [datetime] NULL,
	[del] [int] NULL,
	[editCate] [int] NULL,
	[editTime] [datetime] NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[hr_person_relation](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[personID] [int] NULL,
	[name] [varchar](100) NULL,
	[relations] [varchar](100) NULL,
	[birthday] [datetime] NULL,
	[Political] [varchar](100) NULL,
	[workCompany] [varchar](200) NULL,
	[tel] [varchar](200) NULL,
	[creator] [int] NULL,
	[indate] [datetime] NULL,
	[del] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[make_jh](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[title] [nvarchar](50) NULL,
	[jhbh] [nvarchar](50) NULL,
	[gx] [int] NULL,
	[gxname] [int] NULL,
	[date1] [datetime] NULL,
	[date2] [datetime] NULL,
	[date3] [datetime] NULL,
	[date4] [datetime] NULL,
	[intro2] [nvarchar](100) NULL,
	[complete] [int] NULL,
	[cateid] [int] NULL,
	[catesp] [int] NULL,
	[date7] [datetime] NULL,
	[del] [int] NULL,
	[delcate] [int] NULL,
	[deldate] [datetime] NULL,
	[person] [varchar](4000) NULL,
	[intro] [varchar](4000) NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[hr_answer](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[expaperID] [int] NULL,
	[title] [varchar](500) NULL,
	[ObjPoint] [decimal](25, 12) NULL,
	[subjPoint] [decimal](25, 12) NULL,
	[totalPoint] [decimal](25, 12) NULL,
	[creator] [int] NULL,
	[indate] [datetime] NULL,
	[del] [int] NOT NULL,
	[statusID] [int] NULL,
	[id_sp] [int] NULL,
	[cateid_sp] [int] NULL,
	[status] [int] NULL,
	[TempSave] [bit] NULL,
	[sp_time] [datetime] NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[make_jhlist](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[product] [int] NULL,
	[ord] [int] NULL,
	[unit] [int] NULL,
	[num1] [decimal](25, 12) NULL,
	[price1] [decimal](25, 12) NULL,
	[money1] [decimal](25, 12) NULL,
	[intro] [nvarchar](100) NULL,
	[bom] [int] NULL,
	[cateid] [int] NULL,
	[date7] [datetime] NULL,
	[del] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[call](
	[ord] [int] IDENTITY(1,1) NOT NULL,
	[phone] [nvarchar](50) NULL,
	[adddate] [datetime] NULL,
	[status] [int] NULL,
	[company] [int] NULL,
	[person] [int] NULL,
	[addcate] [int] NULL,
	[vbegin] [datetime] NULL,
	[vend] [datetime] NULL,
	[del] [int] NULL,
	[delcate] [int] NULL,
	[deldate] [datetime] NULL,
	[gj1] [int] NULL,
	[gj2] [int] NULL,
	[cateid2] [int] NULL,
	[cateid3] [int] NULL,
	[talktime] [int] NULL,
	[recordUrl] [nvarchar](500) NULL,
	[statusData] [int] NULL,
	[fsize] [bigint] NULL,
	[mac] [varchar](50) NULL,
	[currsize] [bigint] NULL,
	[wavnetpath] [varchar](100) NULL,
	[mobileCall] [bit] NOT NULL default(0),
    PRIMARY KEY CLUSTERED
    (
        [ord] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]

--@##mode:index;clustered:false;fields:vbegin
--@##mode:index;clustered:false;fields:mac,recordUrl

GO
CREATE TABLE [dbo].[O_carUsemx](
	[use_id] [int] IDENTITY(1,1) NOT NULL,
	[use_fid] [int] NOT NULL,
	[use_carid] [int] NULL,
	[use_driver] [int] NULL,
	[use_type] [int] NULL,
	[use_pctime] [datetime] NULL,
	[use_startime] [datetime] NULL,
	[use_endtime] [datetime] NULL,
	[use_catetype] [varchar](20) NULL,
	[use_mdd] [varchar](2000) NULL,
	[use_lc] [varchar](2000) NULL,
	[use_thing] [varchar](2000) NULL,
	[use_complete] [int] NULL DEFAULT (1),
	[use_rettime] [datetime] NULL,
	[use_retcateid] [int] NULL,
	[use_retnote] [text] NULL,
	[ModifyStamp] [varchar](200) NULL DEFAULT (1),
	[use_notes] [varchar](1000) NULL,
	[del] [int] not null default(1),
	[delcate][int],
	[deldate][datetime],
    PRIMARY KEY CLUSTERED
    (
        [use_id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]
 TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[makelist](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NULL,
	[unit] [int] NULL,
	[num1] [decimal](25, 12) NULL,
	[num2] [decimal](25, 12) NULL,
	[price1] [decimal](25, 12) NULL,
	[money1] [decimal](25, 12) NULL,
	[intro] [nvarchar](100) NULL,
	[jh] [int] NULL,
	[gx] [int] NULL,
	[sort1] [int] NULL,
	[cateid] [int] NULL,
	[date7] [datetime] NULL,
	[del] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[sale_Questions](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Title] [varchar](100) NULL,
	[template] [int] NULL,
	[TypeID] [int] NULL,
	[InDate] [datetime] NULL,
	[Creator] [int] NULL,
	[Del] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[menu](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[id1] [int] NULL,
	[menuname] [nvarchar](50) NULL,
	[gate1] [int] NULL DEFAULT (0),
	[gate2] [int] NULL,
	[priceMode] [int] NULL DEFAULT (0) ,--计价方式
	[toproduct] [int] NULL DEFAULT (0) ,--同步修改下级分类和产品：0=否，1=是
	[User_List] [nvarchar](2000) NULL,
	[hasChild] [int] NULL,
	[ProToSame] [int] NULL  DEFAULT (0),	--影响已存在产品：0=否，1=是
	[User_List1] [varchar](max) NULL,		--可调用范围
	[fullids] [varchar](200) NULL,
	[fullpath] [nvarchar](500) NULL,
	[fullsort] [int] NULL,
	[deep] int NULL,
	[RootId] [int] default(0),
	[jcname] [NVARCHAR](50) NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


--@##mode:index;clustered:true;fields:id
--@##mode:index;clustered:false;fields:id1

GO
CREATE TABLE [dbo].[M_selTempProduct](
	[ord] [int] NOT NULL,
	[uid] [int] NOT NULL,
	[selid] [int] NOT NULL,
PRIMARY KEY CLUSTERED
(
	[ord] ASC,
	[selid] ASC,
	[uid] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[hr_person_health](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[personID] [int] NULL,
	[State] [varchar](100) NULL,
	[isDisease] [int] NULL,
	[serious] [int] NULL,
	[lastdate] [datetime] NULL,
	[cycle] [varchar](200) NULL,
	[content] [text] NULL,
	[creator] [int] NULL,
	[indate] [datetime] NULL,
	[del] [int] NULL,
	[unit] [int] NULL,
	[zhouqi] [int] NULL,
	[alt] [int] NULL DEFAULT (1)  --体检提醒字段,默认为 1 需要提醒
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

CREATE TABLE [dbo].[menu_gx](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[id1] [int] NULL,
	[menuname] [nvarchar](50) NULL,
	[intro] [nvarchar](200) NULL,
	[gate1] [int] NULL DEFAULT (0),
	[gate2] [int] NULL,
	[person] [varchar](4000) NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[contract_his](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NULL,
	[title] [nvarchar](100) NULL,
	[htid] [nvarchar](50) NULL,
	[sort] [int] NULL,
	[complete1] [int] NULL,
	[area] [int] NULL,
	[trade] [int] NULL,
	[premoney] [decimal](25, 12) NULL,			--原合同总额
	[yhtype] [int] NULL,				--优惠方式
	[zk] [decimal](25, 12) NULL,			--折扣,默认是10折
	[Inverse] [int] NULL,				--反算标志 0/ 1 折扣是否被反算.
	[yhmoney] [decimal](25, 12) NULL, --优惠金额
	[money1] [decimal](25, 12) NULL DEFAULT (0),
	[money2] [decimal](25, 12) NULL,
	[bz] [int] NULL DEFAULT (0),
	[date3] [datetime] NULL,
	[date1] [datetime] NULL,
	[date2] [datetime] NULL,
	[person1] [nvarchar](50) NULL,
	[person2] [nvarchar](50) NULL,
	[pay] [nvarchar](100) NULL,
	[intro] [ntext] NULL,
	[addcate] [int] NULL,
	[addcate2] [char](10) NULL,
	[addcate3] [char](10) NULL,
	[cateid] [int] NULL,
	[cateid2] [int] NULL,
	[cateid3] [char](10) NULL,
	[company] [int] NULL,
	[person] [int] NULL,
	[event1] [int] NULL,
	[option1] [int] NULL,
	[chance] [int] NULL,
	[date7] [datetime] NULL,
	[del] [int] NULL,
	[delcate] [int] NULL,
	[deldate] [datetime] NULL,
	[zt1] [int] NULL DEFAULT (1),
	[zt2] [int] NULL DEFAULT (0),
	[contract] [int] NULL,
	[cateid_sp] [int] NULL,
	[sp] [int] NULL,
	[del2] [int] NULL,
	[alt] [int] NULL DEFAULT (0),
	[money_tc1] [decimal](25, 12) NULL DEFAULT (0),
	[money_tc2] [decimal](25, 12) NULL DEFAULT (0),
	[tc] [int] NULL DEFAULT (0),
	[price] [int] NULL,
	[zdy1] [nvarchar](200) NULL,
	[zdy2] [nvarchar](200) NULL,
	[zdy3] [nvarchar](200) NULL,
	[zdy4] [nvarchar](200) NULL,
	[zdy5] [int] NULL,
	[zdy6] [int] NULL,
	[alt2] [int] NULL,
	[person2id] [int] NULL,
	[fqhk] [int] NULL DEFAULT (0),
	[paybacktype] [int] NULL DEFAULT (0),
	[share] [nvarchar](1000) NULL,
	[addshare] [int] NULL DEFAULT (0),
	[ModifyStamp] [varchar](500) NULL,
	[kujh] [int] NULL,
	[sort1] [INT] NULL,
	[customerArr] VARCHAR(4000) NULL,
	[isTerminated] int null,
    [stopOp] [int] NULL,
    [stopdate] [datetime] NULL,
	[paybackMode] int not null default 1, --收款类型，1汇总模式，2明细模式
	[invoiceMode] int not null default 1, --开票类型，0不开票，1汇总模式，2明细模式
	[repairOrderId] int null, -- repairOrder.id 维修单id
	[extras] [decimal](25, 12), --运杂费
	[invoicePlan] int not null default 2, --开票计划方式,1自动，2手动
	[invoicePlanType] int not null default 0, --开票计划票据类型
    [taxRate] [decimal](25, 12) NULL default 0, --税率，数值来自票据类型设置表
	[cpCostChanged] bit not null default 0, --产品成本是否已变动（合同出库产品对应的采购单被修改价格时，此字段值为1）
	[op] [varchar](20) NULL,
	[ip] [varchar](30) NULL,
	[opdate] [datetime] NOT NULL DEFAULT (getdate()),
	[payStatus] [int],--微信商城生成的合同的支付状态，非微信商城的合同这个字段应该为null值
	[payKind] [int],--微信商城生成的合同的支付方式，非微信商城的合同这个字段应该为null值，1为在线支付，2为货到付款
	[wxUserId] [int],--订单所属微信用户的id，记录这个是为了在微信用户被关联上别的客户时依旧能够看到自己的订单
	[receiver] nvarchar(50),--收货人
	[phone] nvarchar(50),--固话
	[mobile] nvarchar(50),--手机
	[address] nvarchar(500),--地址
	[zip] nvarchar(50),--邮编
	[areaId][int],--地址，关联manuarea.id
	[showOnWXShop] int,--是否在微信商城显示
	[isReceived] int,--是否已收货
	[receiveTime] datetime,--收货时间
	[ChangeLog] int , -- 单据变动日志erp_bill_ChangeLog.id
	[import] [BIGINT] NULL,
	[importPayback] [INT] NULL,
	[importInvoice] [INT] NULL,
	[importKuout] [INT] NULL,
	[importSend] [INT] NULL,
    [AutoCreateType] [INT] NULL,--生产执行   空为=手动 1=自动生成预生产计划
	[DataVersion] int null,
	[TaxValue] [decimal](25,12) null,
	[CKAccModel] [int] null,
    [SortType] [INT] NULL,
    [status][int]null
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[callRefuse](
	[ord] [int] IDENTITY(1,1) NOT NULL,
	[RefuseTel] [nvarchar](50) NOT NULL,
	[RefuseName] [nvarchar](50) NULL,
	[RefuseContent] [text] NULL,
	[adddate] [datetime] NULL,
	[author] [int] NULL,
	[del] [int] NULL,
	[addcate] [int] NULL,
	[hmd] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [ord] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]
 TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[salesTarget_batch](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[intSalesTargetId] [int] NULL,
	[intFromId] [int] NULL,
	[intRoleId] [int] NULL,
	[receiverId] [int] NULL,
	[intStatus] [int] NULL,
	[targetValue] [decimal](25, 12) NULL,
	[addCate] [int] NULL,
	[addDate] [datetime] NULL,
	[sorce] [int] NULL,
	[sorce2] [int] NULL,
	[cateid] [int] NULL,
PRIMARY KEY NONCLUSTERED
(
	[Id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[O_insure](
	[iss_id] [int] IDENTITY(1,1) NOT NULL,
	[iss_carid] [int] NULL,
	[iss_type] [varchar](2000) NULL,
	[iss_cateid] [int] NULL,
	[iss_company] [varchar](200) NULL,
	[iss_phone] [varchar](50) NULL,
	[iss_money] [decimal](25, 12) NULL,
	[iss_startime] [datetime] NULL,
	[iss_endtime] [datetime] NULL,
	[iss_warn] [int] NULL DEFAULT (1),
	[iss_note] [text] NULL,
	[iss_addtime] [datetime] NULL,
	[iss_addcateid] [int] NULL,
	[iss_del] [int] NULL DEFAULT (1),
	[del] [int] not null default(1),
	[delcate][int],
	[deldate][datetime],
    PRIMARY KEY CLUSTERED
    (
        [iss_id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]
 TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[hr_answer_list](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[answerID] [int] NULL,
	[testID] [int] NULL,
	[answerNum] [int] NULL,
	[testType] [int] NULL,
	[answerStr] [text] NULL,
	[creator] [int] NULL,
	[indate] [datetime] NULL,
	[del] [int] NOT NULL,
	[point] [decimal](25, 12) NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[menuarea](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[id1] [int] NULL,
	[menuname] [nvarchar](50) NULL,
	[gate1] [int] NULL DEFAULT (0),
	[gate2] [int] NULL,
	[fulpath] nvarchar(200) null,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[erp_tmp_billtreelist](
	[i] [int] IDENTITY(1,1) NOT NULL,
	[oid] [int] NOT NULL,
	[bid] [int] NOT NULL,
	[title] [varchar](200) NULL,
	[bname] [varchar](200) NULL,
	[Creator] [int] NOT NULL,
	[CanOpen] [int] NOT NULL,
	[deep] [int] NOT NULL,
	[del] [int] NOT NULL,
    PRIMARY KEY CLUSTERED
    (
        [i] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[salesTarget_batch_date](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[intBatchId] [int] NULL,
	[dtFromDate] [datetime] NULL,
	[dtToDate] [datetime] NULL,
	[targetValue] [decimal](25, 12) NULL,
	[intType] [int] NULL,
PRIMARY KEY NONCLUSTERED
(
	[Id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[mxpx](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NULL,
	[cateid] [int] NULL,
	[datepx] [datetime] NULL,
	[topid] [int] NULL,
	[sort1] [int] NULL,
	[pricelistid] [int] NULL DEFAULT (0),
	[del] [int] NULL,
	[unit] [int] NULL,
	[num1] [decimal](25, 12) NULL,  --BUG.2678.binary.2013.10.20 原来num1为int类型，导致重新编辑小数位数丢失
	[listorder] [int] NULL,
	[treeOrd] [int] NULL,
	[date2]	datetime NULL,
	[intro]	nvarchar(2000) NULL,
    [ProductAttr1] [int] NULL,
    [ProductAttr2] [int] NULL,
    [PID] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


--@##mode:index;clustered:false;fields:cateid,sort1,datepx,id
--@##mode:index;clustered:false;fields:cateid,id

GO
CREATE TABLE [dbo].[email_Person](
	[ord] [int] IDENTITY(1,1) NOT NULL,
	[clictName] [nvarchar](50) NULL,
	[clictEmail] [nvarchar](2000) NULL,
	[clictSex] [nvarchar](50) NULL,
	[clictJob] [nvarchar](50) NULL,
	[complete] [int] NULL,
	[sort] [int] NULL,
	[sort1] [nvarchar](50) NULL,
	[sort2] [nvarchar](50) NULL,
	[del] [int] NULL,
	[addtime] [datetime] NULL,
	[cateid] [nvarchar](50) NULL,
	[company] [int] NULL,
	[addcate] [int] NULL,
	[person] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [ord] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[sale_Questions_List](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Title] [varchar](100) NULL,
	[MainID] [int] NULL,
	[InDate] [datetime] NULL,
	[Creator] [int] NULL,
	[Del] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[salesTarget_batch_month](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[intBatchId] [int] NULL,
	[intFromDay] [int] NULL,
	[intToDay] [int] NULL,
	[targetValue] [decimal](25, 12) NULL,
	[intType] [int] NULL,
PRIMARY KEY NONCLUSTERED
(
	[Id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[M_ReportConfig](
	[ID] [int] NOT NULL,
	[title] [varchar](100) NULL,
	[remark] [varchar](500) NULL,
	[sqltext] [varchar](4000) NULL,
	[class] [varchar](50) NULL,
	[datefield] [varchar](50) NULL,
	[header] [ntext] NULL,
	[Footer] [ntext] NULL,
	[conditions] [varchar](2000) NULL,
	[isGroup] [bit] NULL DEFAULT (0),
	[Parent] [int] NULL,
	[GroupCreator] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]

--@##mode:index;clustered:false;fields:Parent
--@##mode:index;clustered:false;fields:GroupCreator
--@##mode:index;clustered:false;fields:isGroup

GO
CREATE TABLE [dbo].[mxpxcp](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NULL,
	[cateid] [int] NULL,
	[datepx] [datetime] NULL,
	[topid] [int] NULL,
	[sort1] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[email_Person_class](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[title] [nvarchar](100) NULL,
	[depth] [int] NULL,
	[parent] [int] NULL,
	[sort] [int] NULL,
	[User_List] [nvarchar](2000) NULL,
	[del] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[hr_person_salary](
	[id] [int] NOT NULL,
	[baseMoney] [decimal](25, 12) NULL,
	[startdate] [datetime] NULL,
	[cateid] [int] NULL,
	[creator] [int] NULL,
	[inDate] [datetime] NULL,
	[del] [int] NULL,
	[oldMoney] [decimal](25, 12) NULL,
	[cateidName] [text] NULL,
	[id_sp] [int] NULL,
	[cateid_sp] [int] NULL,
	[TempSave] [bit] NULL,
	[status] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[salesTarget_batch_week](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[charWeeks] [varchar](50) NULL,
	[targetValue] [decimal](25, 12) NULL,
	[intType] [int] NULL,
	[intBatchId] [int] NULL,
PRIMARY KEY NONCLUSTERED
(
	[Id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[O_repair](
	[rep_id] [int] IDENTITY(1,1) NOT NULL,
	[rep_carid] [int] NULL,
	[rep_time] [datetime] NULL,
	[rep_type] [varchar](200) NULL,
	[rep_reason] [varchar](2000) NULL,
	[rep_cateid] [int] NULL,
	[rep_money] [decimal](25, 12) NULL,
	[rep_note] [text] NULL,
	[rep_addcateid] [int] NULL,
	[rep_addtime] [datetime] NULL,
	[rep_del] [int] NULL DEFAULT (1),
	[del] [int] not null default(1),
	[delcate][int],
	[deldate][datetime],
    PRIMARY KEY CLUSTERED
    (
        [rep_id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]
 TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[home_leftMenu](
	[ID] [int] NOT NULL,
	[ParentID] [int] NULL,
	[ItemName] [varchar](500) NULL,
	[ItemSort] [int] NULL,
	[Deep] [int] NULL,
	[url] [varchar](1000) NULL,
	[imgurl] [varchar](100) NULL,
	[qxlb] [int] NULL,
	[qxlblist] [int] NULL,
	[ModelExpress] [varchar](5200) NULL,
	[remark] [varchar](100) NULL,
	[tag1] [varchar](200) NULL,
	[tag2] [varchar](1000) NULL,
	[code] [varchar](1000) null,
	[leef] int null,
PRIMARY KEY CLUSTERED
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO

if exists(select * from sysobjects where name='ClearTempLeftMenu')
DROP TRIGGER [dbo].[ClearTempLeftMenu]

GO

CREATE TRIGGER ClearTempLeftMenu
   ON dbo.home_leftMenu
   AFTER INSERT,DELETE,UPDATE
AS
BEGIN
	--清除左侧导航临时表
	truncate table home_leftMenu_TmpForUser
END

GO
CREATE TABLE [dbo].[notebook](
	[ord] [int] IDENTITY(1,1) NOT NULL,
	[intro] [ntext] NULL,
	[gate] [int] NULL,
	[complete] [int] NULL,
	[cateid] [int] NULL,
	[date7] [datetime] NULL,
	[del] [int] NULL DEFAULT (1),
	[delcateid] [int] NULL DEFAULT (0),
	[deldate] [datetime] NULL,
	[alt] bit not null default(0),
    PRIMARY KEY CLUSTERED
    (
        [ord] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]
 TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[email_sender](
	[ord] [int] IDENTITY(1,1) NOT NULL,
	[EmailName] [nvarchar](100) NULL,
	[EmailPasswd] [nvarchar](200) NULL,
	[EmailSmtp] [nvarchar](100) NULL,
	[EmailPop3] [nvarchar](100) NULL,
	[EmailUrl] [nvarchar](100) NULL,
	[addTime] [datetime] NULL,
	[EmailDefault] [int] NULL,
	[SmtpObj] [nvarchar](100) NULL,
	[pop3Obj] [nvarchar](100) NULL,
	[gate] [int] NULL,
	[del] [int] NULL,
	[delMail] [int] NULL,
	[ssl] [int] NULL,
	[port] [int] NULL,
	[spost] [int] NULL,
	[smtpUser] [nvarchar](100) NULL,
	[smtpPass] [nvarchar](100) NULL,
    [ReceiveTotal] int null,
    PRIMARY KEY CLUSTERED
    (
        [ord] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[salesTarget_batch_weeks](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[intBatchId] [int] NULL,
	[intFromWeek] [int] NULL,
	[intToWeek] [int] NULL,
	[targetValue] [decimal](25, 12) NULL,
	[intType] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[Id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[hr_company](
	[ord] [int] NULL,
	[title] [varchar](200) NULL,
	[tel] [varchar](100) NULL,
	[fax] [varchar](100) NULL,
	[foundDate] [datetime] NULL,
	[corporater] [varchar](50) NULL,
	[capital] [decimal](25, 12) NULL,
	[zipcode] [varchar](100) NULL,
	[address] [varchar](500) NULL,
	[about] [text] NULL,
	[culture] [text] NULL,
	[content] [text] NULL,
	[creator] [int] NULL,
	[TempSave] [bit] NULL,
	[indate] [datetime] NULL,
	[del] [int] NULL,
	[id] [int] NOT NULL,
	[startDate] [datetime] NULL,
	[corporate] [varchar](100) NULL,
	[id_sp] [int] NULL,
	[cateid_sp] [int] NULL,
	[status] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[num_bh](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[num1] [int] NULL,
	[num2] [int] NULL,
	[num3] [int] NULL,
	[kh] [int] NULL,
	[cateid] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[email_Signature](
	[ord] [int] IDENTITY(1,1) NOT NULL,
	[SignatureName] [nvarchar](100) NULL,
	[SignatureCon] [ntext] NULL,
	[addTime] [datetime] NULL,
	[addcate] [int] NULL,
	[SignatureDefault] [int] NULL,
	[del] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [ord] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]
 TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[salesTarget_examItems](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[charName] [nvarchar](50) NULL,
	[sort] [int] NULL DEFAULT (0),
	[intro] [ntext] NULL,
	[gate] [int] NULL DEFAULT (0),
	[periodList] [varchar](100) NULL,
	[intStatus] [smallint] NULL DEFAULT (0),
PRIMARY KEY CLUSTERED
(
	[Id] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[O_carLog](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[carcode] [varchar](400) NULL,
	[cztype] [varchar](400) NULL,
	[cztime] [datetime] NULL,
	[czname] [int] NULL,
	[cartype] [varchar](400) NULL,
	[carname] [varchar](400) NULL,
	[carxh] [varchar](500) NULL,
	[carfdjh] [varchar](500) NULL,
	[cardph] [varchar](500) NULL,
	[free1] [int] NULL,
	[free2] [int] NULL,
	[free3] [varchar](400) NULL,
	[free4] [varchar](400) NULL,
	[addcateid] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[option1](
	[ord] [int] IDENTITY(1,1) NOT NULL,
	[sort1] [int] NULL,
	[num1] [decimal](25, 12) NULL,
	[year1] [int] NULL,
	[month1] [int] NULL,
	[intro] [ntext] NULL,
	[cateid] [int] NULL,
	[cateid2] [int] NULL,
	[cateid3] [int] NULL,
	[cate] [int] NULL,
	[order1] [int] NULL,
	[sorce] [int] NULL,
	[date7] [datetime] NULL,
    PRIMARY KEY CLUSTERED
    (
        [ord] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]
 TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[email_maoban_sort](
	[ord] [int] IDENTITY(1,1) NOT NULL,
	[sortName] [nvarchar](100) NULL,
	[sortClass] [int] NULL,
	[addtime] [datetime] NULL,
	[editTime] [datetime] NULL,
	[addcate] [int] NULL,
	[editcate] [int] NULL,
	[order1] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [ord] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[sale_care](
	[id] [int] NOT NULL,
	[PrefixCode] [varchar](20) NULL, 
	[title] [varchar](200) NULL,
	[bh] [varchar](200) NULL,
	[company] [int] NULL,
	[person] [int] NULL,
	[ServerTime] [datetime] NULL,
	[cateid] [int] NULL,
	[contract] [int] NULL,
	[modeID] [int] NULL,
	[sortID] [int] NULL,
	[content] [text] NULL,
	[feedback] [text] NULL,
	[remark] [text] NULL,
	[indate] [datetime] NULL,
	[creator] [int] NULL,
	[del] [int] NULL,
	[status] [int] NULL,
	[id_sp] [int] NULL,
	[cateid_sp] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[salesTarget_period](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[charName] [nvarchar](50) NULL,
	[intYear] [int] NULL,
	[dtFromDate] [datetime] NULL DEFAULT (0),
	[dtToDate] [datetime] NULL DEFAULT (0),
	[intParentId] [int] NULL DEFAULT (0),
	[intRoleId] [int] NULL DEFAULT (0),
PRIMARY KEY CLUSTERED
(
	[Id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
--Attrs:帐套下可用
CREATE TABLE [dbo].[sys_all_ThreathControl](
	[rdata] [varchar](1000) NULL,
	[uid] [int] NULL,
	[dat] [datetime] NULL
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[order1](
	[ord] [int] IDENTITY(1,1) NOT NULL,
	[title] [nvarchar](50) NULL,
	[sort] [int] NULL,
	[complete] [int] NULL,
	[area] [char](10) NULL,
	[trade] [int] NULL,
	[money1] [decimal](25, 12) NULL DEFAULT (0),
	[date3] [datetime] NULL,
	[date2] [datetime] NULL,
	[person3] [int] NULL,
	[intro] [ntext] NULL,
	[addcate] [int] NULL,
	[cateid] [int] NULL,
	[cateid2] [int] NULL,
	[company] [int] NULL,
	[del] [int] NULL,
	[delcate] [int] NULL,
	[deldate] [datetime] NULL,
	[date7] [datetime] NULL,
    PRIMARY KEY CLUSTERED
    (
        [ord] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]
 TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[email_maoban](
	[ord] [int] IDENTITY(1,1) NOT NULL,
	[sort] [int] NULL,
	[title] [nvarchar](100) NULL,
	[content] [ntext] NULL,
	[del] [int] NULL,
	[addtime] [datetime] NULL,
	[editTime] [datetime] NULL,
	[deltime] [datetime] NULL,
	[addcate] [int] NULL,
	[editcate] [int] NULL,
	[clikNum] [int] NULL,
	[share] [int] NULL,
	[shareinfo] [nvarchar](1000) NULL,
    PRIMARY KEY CLUSTERED
    (
        [ord] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]
 TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[salesTarget_period_role](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[charName] [nvarchar](50) NULL,
	[intStatus] [int] NULL,
	[sort] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[Id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[M_ReportGroups](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ReportID] [int] NULL,
	[Title] [varchar](200) NULL,
	[sqltext] [varchar](2000) NULL,
	[header] [ntext] NULL,
	[footer] [ntext] NULL,
	[Description] [varchar](200) NULL,
	[creator] [int] NOT NULL DEFAULT (0),
	[groupItems] [varchar](1000) NULL,
	[SumItems] [varchar](1000) NULL,
PRIMARY KEY CLUSTERED
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[order2](
	[id] [int] NOT NULL,
	[ord] [int] NULL,
	[intro] [nvarchar](50) NULL,
	[gate] [int] NULL,
	[name] [nvarchar](50) NULL
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[email_log](
	[ord] [int] IDENTITY(1,1) NOT NULL,
	[recv_email] [nvarchar](4000) NULL,
	[title] [nvarchar](200) NULL,
	[content] [ntext] NULL,
	[stact] [int] NULL,
	[addtime] [datetime] NULL,
	[addcate] [int] NULL,
	[cateid2] [int] NULL,
	[cateid3] [int] NULL,
	[person] [int] NULL,
	[isAccess] [int] NULL,
	[msEmail] [nvarchar](2000) NULL,
	[csEmail] [nvarchar](2000) NULL,
	[send_email] [int] NULL,
	[sendNum] [int] NULL,
	[all_send_ord] [int] NULL,
	[isAllSend] [int] NULL,
	[del] [int] NULL,
	[ord_action] [int] NULL,
	[sort_action] [int] NULL,
	[SendException] [ntext] NULL,
    PRIMARY KEY CLUSTERED
    (
        [ord] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]
 TEXTIMAGE_ON [PRIMARY]

--@##mode:index;clustered:false;fields:ord_action,sort_action,ord desc
--@##mode:statistics;fields:ord,sort_action
--@##mode:statistics;fields:ord,ord_action
--@##mode:statistics;fields:sort_action,ord_action,ord
--@##mode:statistics;fields:ord_action,person,sort_action,ord

GO

CREATE TABLE [dbo].[roles](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[sort] [int] NULL,
	[charName] [nvarchar](50) NULL,
	[intType] [smallint] NULL,
	[qxlbSort1] [varchar](2000) NULL,
	[intStatus] [smallint] NULL,
	[gate1] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[Id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[learnhdview](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[cateid] [int] NULL,
	[hdid] [int] NULL,
	[viewdate] [datetime] NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[hr_expaper](
	[id] [int] NOT NULL,
	[title] [varchar](500) NULL,
	[bh] [varchar](100) NULL,
	[id_sp] [int] NULL,
	[cateid_sp] [int] NULL,
	[status] [int] NULL,
	[TempSave] [bit] NULL,
	[creator] [int] NULL,
	[indate] [datetime] NULL,
	[del] [int] NOT NULL,
	[user_list] [nvarchar](3000) NULL,
	[sp_list] [nvarchar](3000) NULL,
	[startTime] [datetime] NULL,
	[endTime] [datetime] NULL,
	[trainID] [int] NULL,
	[remark] [text] NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[orderbz](
	[intro1] [ntext] NULL,
	[intro2] [ntext] NULL,
	[intro3] [ntext] NULL,
	[intro4] [ntext] NULL,
	[intro5] [ntext] NULL,
	[intro6] [ntext] NULL,
	[order1] [int] NULL,
	[date7] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[email_recv_list](
	[ord] [int] IDENTITY(1,1) NOT NULL,
	[sendMail] [nvarchar](50) NULL,
	[sendName] [nvarchar](50) NULL,
	[recvMail] [nvarchar](2000) NULL,
	[title] [nvarchar](200) NULL,
	[content] [ntext] NULL,
	[sendtime] [datetime] NULL,
	[addtime] [datetime] NULL,
	[addcate] [int] NULL,
	[isAccess] [int] NULL,
	[isDownAccess] [int] NULL,
	[csEmail] [nvarchar](2000) NULL,
	[recvord] [int] NULL,
	[isRead] [int] NULL,
	[email_Id] [varchar](100) NULL,
	[del] [int] NULL,
    [ReceiveTotal] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [ord] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]
 TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[bankout](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[title] [varchar](200) NULL,
	[ck] [int] NULL,
	[money1] [decimal](25, 12) NULL,
	[intro] [ntext] NULL,
	[cateid] [int] NULL,
	[date3] [datetime] NULL,
	[date7] [datetime] NULL,
	[del] [int] NULL,
	[delcate] [int] NULL,
	[deldate] [datetime] NULL,
    [bz] nvarchar(10) null,
    [typeord] INT null,
    [company] int null,
    [status] int  null,    
	[relatedCate] [INT] NULL,
	[chargeMoney] [DECIMAL](25, 12) NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[home_search_config_def](
	[ID] [int] NOT NULL,
	[cls] [varchar](50) NULL,
	[fields] [varchar](1000) NULL,
	[qxlb] [int] NULL,
	[qxlblist] [int] NULL,
	[usign] [varchar](40) not null default('')
PRIMARY KEY CLUSTERED
(
	[ID] ASC,
	[usign] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[orderlist](
	[ord] [int] NULL,
	[price1] [decimal](25, 12) NULL DEFAULT (0),
	[num1] [decimal](25, 12) NULL DEFAULT (0),
	[num2] [decimal](25, 12) NULL DEFAULT (0),
	[num3] [decimal](25, 12) NULL DEFAULT (0),
	[num4] [decimal](25, 12) NULL DEFAULT (0),
	[order1] [int] NULL,
	[date7] [datetime] NULL
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[email_Drafts](
	[ord] [int] IDENTITY(1,1) NOT NULL,
	[title] [nvarchar](50) NULL,
	[content] [ntext] NULL,
	[addtime] [datetime] NULL,
	[addcate] [int] NULL,
	[stract] [int] NULL,
	[del] [int] NULL,
	[recvMail] [nvarchar](2000) NULL,
	[msEmail] [nvarchar](2000) NULL,
	[csEmail] [nvarchar](2000) NULL,
	[isAccess] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [ord] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]
 TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[ERP_CustomFields](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[TName] [int] NOT NULL,
	[IsMaster] [bit] NULL,
	[FOrder] [int] NOT NULL,
	[FName] [nvarchar](500) NOT NULL,
	[FType] [int] NOT NULL,
	[MustFillin] [bit] NOT NULL,
	[OptionID] [int] NULL,
	[FStyle] [nvarchar](500) NULL,
	[IsUsing] [bit] NULL,
	[CanExport] [bit] NULL,
	[CanInport] [bit] NULL,
	[CanSearch] [bit] NULL,
	[CanStat] [bit] NULL,
	[del] [int] NOT NULL,
	[LastModify] [datetime] NULL,
	[Creator] int NULL,
PRIMARY KEY CLUSTERED
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[sale_knowledge](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[title] [nvarchar](200) NULL,
	[bh] [nvarchar](200) NULL,
	[modeID] [int] NULL,
	[sortID] [int] NULL,
	[user_list] [varchar](4000) NULL,
	[content] [text] NULL,
	[solution] [text] NULL,
	[remark] [text] NULL,
	[indate] [datetime] NULL,
	[creator] [int] NULL,
	[del] [int] NULL,
	[EditDate] [datetime] NULL,
	[EditCate] [int] NULL,
	[KeyWord] [nvarchar](1000) NULL,
	[Company] [int] NULL,
	[ServiceID] [int] NULL,
	[zdy1] [nvarchar](50) NULL,
	[zdy2] [nvarchar](50) NULL,
	[zdy3] [nvarchar](50) NULL,
	[zdy4] [nvarchar](50) NULL,
	[zdy5] [int] NULL,
	[zdy6] [int] NULL,
	[url1] [nvarchar](200) NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[part1](
	[ord] [int] NOT NULL,
	[part1] [int] NULL
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[email_Send_Queue](
	[ord] [int] IDENTITY(1,1) NOT NULL,
	[recv_email] [nvarchar](4000) NULL,
	[title] [nvarchar](200) NULL,
	[content] [ntext] NULL,
	[addtime] [datetime] NULL,
	[sendtime] [datetime] NULL,
	[addcate] [int] NULL,
	[isAccess] [int] NULL,
	[msEmail] [nvarchar](2000) NULL,
	[csEmail] [nvarchar](2000) NULL,
	[openAutoSend] [int] NULL,
	[threedLine] [int] NULL,
	[threedTime] [datetime] NULL,
	[status] [int] NULL,
	[send_email] [nvarchar](50) NULL,
	[send_pwd] [nvarchar](200) NULL,
	[send_stmp] [nvarchar](50) NULL,
	[send_ord] [int] NULL,
	[del] [int] NULL,
	[cateid2] [int] NULL,
	[cateid3] [int] NULL,
	[ord_action] [int] NULL,
	[sort_action] [int] NULL,
	[ssl] [int] NULL,
	[port] [int] NULL,
	[spost] [int] NULL,
	[smtpUser] [nvarchar](100) NULL,
	[smtpPass] [nvarchar](100) NULL,
	[Ecount] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [ord] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]
 TEXTIMAGE_ON [PRIMARY]

GO

--预付款
CREATE TABLE [dbo].[bankout2](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[company] [int] NULL,
	[bz] [int] NULL,
	[bank] [varchar](50) NULL,
	[money1] [decimal](25, 12) NULL,
	[title] [nvarchar](200) NULL, --供应商预付款主题
	[intro] [ntext] NULL,
	[date3] [datetime] NULL,
    [EntryDate] [datetime] NULL,
    [Creator] [int] NULL,
	[date7] [datetime] NULL,
	[cateid] [int] NULL,
	[del] [int] NULL,
	[delcate] [int] NULL,
	[deldate] [datetime] NULL,
	[sp] [int] NULL,
	[cateid_sp] [int] NULL,
	[status_sp] [int] NULL,
	[InvoiceMode] [int] NULL,
	[InvoiceType] [int] NULL,
	[planDate] [datetime] NULL,
	[money_left] [decimal](25, 12) NULL,
	[SureListId] [int] null,
	[payout] [int] NULL, 
	[payout3] [int] NULL, 
	[BankinStatus] [int] null	,
	[FromType] [int] null
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO

--收票计划
CREATE TABLE [dbo].[payoutInvoice] (
	[id] [int] IDENTITY (1,1) NOT NULL ,
    [BH] [nvarchar](200) null,
	[company] int NULL,
	[fromType] [nvarchar](50) NOT NULL,
	[fromId] [int] NOT NULL,
	[invoiceType] [int] NOT NULL,
    [taxRate] [decimal](25, 12) NULL,
	[taxValue] [decimal](25, 12) NULL,
	[TaxMoney] [decimal](25, 12) NULL,
	[MoneyBeforeTax] [decimal](25, 12) NULL,
	[invoiceMode] [int] NULL,
	[invoiceNum] [nvarchar](500) NULL,
	[invoicely] [int] NULL,
	[date1] [datetime] NULL,
	[date7] [datetime] NULL,
	[money1] [decimal](25, 12) NULL,
	[bz] [int] NULL,
	[money_left] [decimal](25, 12) NULL,
	[invoiceDate] [datetime] NULL,
	[invoiceCate] [int] NULL,
	[invoiceDatetime] [datetime] NULL,
	[cateid] [int]  NULL,
	[cateid2] [int]  NULL,
	[cateid3] [int]  NULL,
	[addcate] [int]  NULL,
	[addcate2] [int]  NULL,
	[addcate3] [int]  NULL,
	[title] [nvarchar](100)  NULL,
	[taxno] [nvarchar](100)  NULL,
	[addr] [nvarchar](100)  NULL,
	[phone] [nvarchar](100)  NULL,
	[bank] [nvarchar](100)  NULL,
	[account] [nvarchar](100)  NULL,
	[delcate] [int] NULL,
	[deldate] [datetime] NULL,
	[isInvoiced] int NOT NULL default(0), 
	[del] int NOT NULL,
	[intro] [nvarchar](500) null,
	[SureId] [int] null,
    [RedJoinId] [int] null,
	[KuinId] [int] null,
	[QcId] [int] null
)

--@##mode:index;clustered:false;fields:fromId,del,fromType,isInvoiced,money1
--@##mode:index;clustered:false;fields:fromId,del,fromType,date1 desc,id desc
--@##mode:statistics;fields:invoiceDate,isInvoiced
--@##mode:statistics;fields:fromType,isInvoiced
--@##mode:statistics;fields:del,invoicely
--@##mode:statistics;fields:company,del,invoiceType
--@##mode:statistics;fields:isInvoiced,fromId,del
--@##mode:statistics;fields:fromId,fromType,isInvoiced
--@##mode:statistics;fields:invoicely,invoiceDate,isInvoiced
--@##mode:statistics;fields:del,isInvoiced,invoiceDate
--@##mode:statistics;fields:del,fromType,isInvoiced
--@##mode:statistics;fields:isInvoiced,del,invoicely,invoiceDate
--@##mode:statistics;fields:date1,id,company,del
--@##mode:statistics;fields:date1,id,fromType,fromId,del
--@##mode:statistics;fields:invoiceType,fromId,del,fromType,date1,id
--@##mode:statistics;fields:invoiceType,invoiceCate,company,del,date1,id

GO

--收票明细表
create table [dbo].[payoutInvoice_list](
	id int identity(1,1) not null primary key,
	product int not null,--产品ord
    Unit int not null DEFAULT(0),
	caigoulist int NOT NULL DEFAULT(0),--采购明细id
	payoutInvoice int not null,--payoutInvoice.id
	money1 [decimal](25, 12) NOT NULL DEFAULT(0),--收票金额
	num1 [decimal](25, 12) NOT NULL DEFAULT(0),--产品数量
    HL [decimal](25, 12) null,
    Price1 [decimal](25, 12) null,
	TaxPrice [decimal](25, 12) null,
    MoneyBeforeTax [decimal](25, 12) null,
	taxRate [decimal](25, 12) null,
	taxValue [decimal](25, 12) null,
	TaxMoney [decimal](25, 12) null,
    KuinListId [int] NOT NULL DEFAULT(0),
    [RedJoinListId] [int] null,
    [CaigouthlistId] [int] NOT NULL DEFAULT(0),
    [M2_OutOrderlists] [int] null  DEFAULT(0),
	[M_OutOrderlists] [int] null  DEFAULT(0),
	[SureId] [int] null,
	[QCListId] int NOT NULL DEFAULT(0),
	[CostNum] [decimal](25, 12) null,
	[CostStatus] [int] null,
    del [int] NOT null
)

--@##mode:index;clustered:false;fields:payoutInvoice
GO

--收票抵扣明细表
create table [dbo].[payoutInvoice_dklist](
	id int identity(1,1) not null primary key,
	money1 [decimal](25, 12) NOT NULL DEFAULT(0),--抵扣金额
	payoutInvoice int not null,--payoutInvoice.id (所属单据)
	payoutinvoice_dkid int not null,--抵扣的是某次预付款收票
	del [int] NOT null
)

--@##mode:index;clustered:false;fields:payoutInvoice

GO

CREATE TABLE [dbo].[pay](
	[ord] [int] IDENTITY(1,1) NOT NULL,
	[money1] [decimal](25, 12) NOT NULL DEFAULT (0),
	[money2] [decimal](25, 12) NULL DEFAULT (0),
	[money3] [decimal](25, 12) NULL DEFAULT (0),
	[money4] [decimal](25, 12) NULL DEFAULT (0),
	[money5] [decimal](25, 12) NULL DEFAULT (0),
	[money6] [decimal](25, 12) NULL DEFAULT (0),
	[sort] [nvarchar](50) NULL,
	[intro] [ntext] NULL,
	[intro2] [nvarchar](100) NULL,
	[intro4] [nvarchar](100) NULL,
	[intro5] [nvarchar](100) NULL,
	[intro6] [nvarchar](100) NULL,
	[complete] [nvarchar](10) NULL,
	[plan1] [int] NULL,
	[lead] [int] NULL,
	[lead4] [int] NULL,
	[lead5] [int] NULL,
	[lead6] [int] NULL,
	[addcate] [int] NULL,
	[cateid] [int] NULL,
	[cateid2] [int] NULL,
	[cateid3] [int] NULL,
	[company] [int] NULL,
	[person] [int] NULL,
	[option1] [int] NULL,
	[event1] [int] NULL,
	[chance] [int] NULL,
	[contract] [int] NULL,
	[contractth] [int] NULL,
	[date1] [datetime] NULL,
	[date2] [datetime] NULL,
	[date4] [datetime] NULL,
	[date5] [datetime] NULL,
	[date6] [datetime] NULL,
	[del] [int] NULL,
	[delcate] [int] NULL,
	[deldate] [datetime] NULL,
	[cateid_sp] [int] NULL,
	[sp] [int] NULL,
	[del2] [int] NULL,
	[del3] [int] NULL,
	[alt] [int] NULL DEFAULT (0),
	[caigou] [nvarchar](50) NULL,
	[caigouth] [int] NULL,
	[payid] [nvarchar](50) NULL,
	[title] [nvarchar](200) NULL,
	[jkid] [int] NULL,
	[shouhou] [int] NULL,
	[richeng] [int] NULL,
	[fahuo] [int] NULL,
	[iwork] [int] NULL,
	[num] [int] NULL DEFAULT (0),
	[bx] [int] NULL DEFAULT (0),
	[fid] [int] NULL,
	[jid] [int] NOT NULL DEFAULT (0),
	[startime] [datetime] NULL,
	[staraddr] [nvarchar](200) NULL,
	[endtime] [datetime] NULL,
	[endaddr] [nvarchar](200) NULL,
	[lc] [varchar](20) NULL,
	[bus] [nvarchar](20) NULL,
	[retime] [datetime] NULL,
	[startime1] [datetime] NULL,
	[endtime1] [datetime] NULL,
	[city] [nvarchar](200) NULL,
	[hotel] [nvarchar](100) NULL,
	[ggtime] [datetime] NULL,
	[ggcate] [nvarchar](200) NULL,
	[ggintro] [nvarchar](300) NULL,
	[gglw] [nvarchar](200) NULL,
	[xytime] [nvarchar](200) NULL,
	[yt] [nvarchar](200) NULL,
	[bz] [int] NOT NULL DEFAULT (14),
	[ManuOrder] [int] NULL,
	[office] [int] NULL DEFAULT (0),
	[repair] [int] NULL DEFAULT (0),
	[insure] [int] NULL DEFAULT (0),
	[book] [int] NULL DEFAULT (0),
	[yord] [int] NULL,
	[scdd] [int] NULL,
	[zdww] [int] NULL,
	[gxww] [int] NULL,
	[scsb] [int] NULL,
    [Sccj] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [ord] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]
 TEXTIMAGE_ON [PRIMARY]

--@##mode:index;clustered:true;fields:ord
--@##mode:index;clustered:false;fields:contract
--@##mode:index;clustered:false;fields:del
--@##mode:index;clustered:false;fields:complete
--@##mode:index;clustered:false;fields:richeng
--@##mode:index;clustered:false;fields:del2
--@##mode:index;clustered:false;fields:del3
--@##mode:index;clustered:false;fields:cateid
--@##mode:index;clustered:false;fields:caigou
--@##mode:index;clustered:false;fields:sort
--@##mode:index;clustered:false;fields:jkid
--@##mode:statistics;fields:date6
--@##mode:statistics;fields:cateid,ord
--@##mode:statistics;fields:fid,sort
--@##mode:statistics;fields:sort,date6
--@##mode:statistics;fields:jid,ord,fid
--@##mode:statistics;fields:ord,fid,cateid,jid
--@##mode:statistics;fields:richeng,del,complete,date1
--@##mode:statistics;fields:date1,ord,contract,complete
--@##mode:statistics;fields:date1,ord,company,complete
--@##mode:statistics;fields:date1,ord,richeng,complete,del
--@##mode:statistics;fields:company,del,complete,date1,ord
--@##mode:statistics;fields:contract,del,complete,date1,ord

GO

CREATE TABLE [dbo].[kuhclist](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[kuinlist] [int] NOT NULL DEFAULT (0),
	[mxid] [int] NOT NULL,
	[ord] [int] NOT NULL,
	[kuid] [int] NOT NULL,
	[num1] [decimal](25, 12) NULL,
	[del] [int] NOT NULL,
	[cateid] [int] NOT NULL,
	[indate] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

--@##mode:index;clustered:false;fields:kuinlist
--@##mode:index;clustered:false;fields:id
--@##mode:index;clustered:false;fields:kuid
--@##mode:index;clustered:false;fields:cateid
--@##mode:index;clustered:false;fields:mxid
--@##mode:index;clustered:false;fields:indate

GO

CREATE TABLE [dbo].[kuhclist_V3199](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[kuinlist] [int] NOT NULL DEFAULT (0),
	[mxid] [int] NOT NULL,
	[ord] [int] NOT NULL,
	[kuid] [int] NOT NULL,
	[num1] [decimal](25, 12) NULL,
	[del] [int] NOT NULL,
	[cateid] [int] NOT NULL,
	[indate] [datetime] NOT NULL
)

GO

CREATE TABLE [dbo].[email_recv_Access](
	[ord] [int] IDENTITY(1,1) NOT NULL,
	[email_ord] [int] NULL,
	[Access_url] [nvarchar](100) NULL,
	[Access_size] [nvarchar](50) NULL,
	[mailType] [int] NULL,
	[del] [int] NULL,
	[oldname] [nvarchar](200) NULL,
	[fileDes] [nvarchar](500) NULL,
	[creator] [int] NULL,
	[indate] [datetime] NULL,
PRIMARY KEY CLUSTERED
(
	[ord] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[ERP_CustomOptions](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CFID] [int] NULL,
	[CValue] [nvarchar](500) NULL,
	[del] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[hr_expaper_list](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[expaperID] [int] NULL,
	[creator] [int] NULL,
	[indate] [datetime] NULL,
	[del] [int] NOT NULL,
	[point] [decimal](25, 12) NULL,
	[testID] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[payback](
	[ord] [int] IDENTITY(1,1) NOT NULL,
    [BH] [varchar](200) NULL,
    [bz] [int] NULL,
	[money1] [decimal](25, 12) NULL DEFAULT (0),
	[title] [nvarchar](50) NULL,
	[date1] [datetime] NULL,
	[date2] [datetime] NULL,
	[date5] [datetime] NULL,
	[pay] [nvarchar](50) NULL,
	[date3] [datetime] NULL,
	[tik] [nvarchar](20) NULL,
	[complete] [nvarchar](10) NULL,
	[CompleteType] [int] null,
	[complete2] [nvarchar](10) NULL,
	[area] [int] NULL,
	[trade] [int] NULL,
	[cateid] [int] NULL,
	[cateid2] [int] NULL,
	[cateid3] [int] NULL,
	[addcate] [int] NULL,
	[addcate2] [int] NULL,
	[addcate3] [int] NULL,
	[contract] [int] NULL,
	[date7] [datetime] NULL,
	[date4] [datetime] NULL,
	[del] [int] NULL,
	[delcate] [int] NULL,
	[deldate] [datetime] NULL,
	[tikname] [nvarchar](50) NULL,
	[tik_person] [int] NULL,
	[money_tc] [decimal](25, 12) NULL DEFAULT (0),
	[tc] [int] NULL DEFAULT (0),
	[tc_person] [int] NULL,
	[tc_date] [datetime] NULL,
	[bank] [int] NULL,
	[intro] [nvarchar](200) NULL,
	[yintro] [nvarchar](200) NULL,
	[company] [int] NULL,
	[planhkid] [int] NULL DEFAULT (0),
	[paybacktype] [int] NULL DEFAULT (0),
	[ModifyStamp] [varchar](30) NULL,
	[op] [int] NULL DEFAULT (0),
	[opdate] [datetime] NULL,
    [IsUsePJLY] [Int],
	[alt] [int] NULL,
	[qc_bz] [int] NULL,
	[paybackMode] [int] NULL,
    [weixinCallBackId] [int] NULL,
	[concessions] [decimal](25, 12) not null DEFAULT (0), --优惠金额
	[payback] [varchar](2000) NULL,
	[FromType] [int] not null DEFAULT (0), --默认0 来自合同
	[SureListId] [int] null,
	[KuoutId] [int] null	,
	[BCheckId] [int] null,
	[InvoiceSureId] [int] null,
	[SendId] [int] null,
	[OutSureListId] [int] null,
	[SureId] [int] null,
   [OutSureId] [int] null,
    PRIMARY KEY CLUSTERED
    (
        [ord] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


--@##mode:index;clustered:false;fields:del,bank,addcate,cateid,contract,company,pay,date1,date7,ord
--@##mode:index;clustered:false;fields:complete,cateid,del;include:ord
--@##mode:index;clustered:false;fields:contract,del
--@##mode:index;clustered:false;fields:planhkid,del
--@##mode:index;clustered:false;fields:contract,del,complete
--@##mode:index;clustered:false;fields:contract,del,date1,date7
--@##mode:statistics;fields:contract,complete
--@##mode:statistics;fields:del,ord
--@##mode:statistics;fields:del,complete
--@##mode:statistics;fields:ord,company
--@##mode:statistics;fields:del,contract,addcate
--@##mode:statistics;fields:date1,date7,contract
--@##mode:statistics;fields:del,contract,complete
--@##mode:statistics;fields:company,contract,ord
--@##mode:statistics;fields:contract,del,ord
--@##mode:statistics;fields:del,company,contract
--@##mode:statistics;fields:date1,date7,ord,del
--@##mode:statistics;fields:del,addcate,cateid,contract
--@##mode:statistics;fields:date1,del,company,contract
--@##mode:statistics;fields:date1,date7,company,del
--@##mode:statistics;fields:contract,del,date1,date7
--@##mode:statistics;fields:date1,ord,company,contract
--@##mode:statistics;fields:company,del,ord,contract,date1
--@##mode:statistics;fields:planhkid,company,del,date1,date7
--@##mode:statistics;fields:del,pay,addcate,cateid,contract,company
--@##mode:statistics;fields:addcate,cateid,contract,company,bank,pay
--@##mode:statistics;fields:del,company,addcate,cateid,contract,bank,pay,date1,date7,ord

GO

--收款明细表
create table [dbo].[paybackList](
	id int identity(1,1) not null primary key,
	product int not null,
	contractlist int not null, --合同明细id
	payback int not null,--payback.id
	num1 [decimal](25, 12) NOT null DEFAULT(0),--收款数量
	money1 [decimal](25, 12) NOT null DEFAULT(0),--回款金额
	del int not null,
)

--@##mode:index;clustered:false;fields:payback

GO
CREATE TABLE [dbo].[bankout3](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[title] [varchar](200) NULL,
	[money1] [decimal](25, 12) NULL,
	[intro] [varchar](500) NULL,
	[cateid] [int] NULL,
	[date3] [datetime] NULL,
	[date7] [datetime] NULL,
	[del] [int] NULL,
	[delcate] [int] NULL,
	[deldate] [datetime] NULL,
	[company] [int] NULL,
	[bank] [varchar](50) NULL,
	[intro2] [ntext] NULL,
	[bankout2] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[home_search_config_us](
	[ID] [int] NOT NULL,
	[stoped] [int] NOT NULL,
	[stopfields] [varchar](1000) NULL,
	[uid] [int] NOT NULL,
	[sort] [int] NOT NULL,
PRIMARY KEY CLUSTERED
(
	[ID] ASC,
	[uid] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[payout](
	[ord] [int] IDENTITY(1,1) NOT NULL,
	[BH] [varchar](200) NULL,
	[contract] [int] NULL, 
	[company] [int] NULL, 
	[money1] [decimal](25, 12) NULL DEFAULT (0),
	[date1] [datetime] NULL, 
	[date2] [datetime] NULL, 
	[pay] [decimal](25, 12) NULL,		
	[complete] [int] NULL,	 
	[CompleteType] [int] null,
	[complete2] [int] NULL, 
	[date3] [datetime] NULL,
	[tik] [int] NULL,
	[tikname] [nvarchar](50) NULL, 
	[addcate] [int] NULL,
	[addcate2] [int] NULL,
	[addcate3] [int] NULL,
	[cateid] [int] NULL,
	[cateid2] [int] NULL,
	[cateid3] [int] NULL,
	[date4] [datetime] NULL,
	[date7] [datetime] NULL,
	[plandate] [datetime] NULL,
	[del] [int] NULL,
	[del2] [int] NULL,
	[cateid_sp] [int] NULL,
	[sp] [int] NULL,
	[status_sp] [int] NULL,
	[alt] [int] NULL DEFAULT (0),
	[delcate] [int] NULL,
	[deldate] [datetime] NULL,
	[intro] [nvarchar](200) NULL,
	[yintro] [nvarchar](200) NULL,
	[bank] [int] NULL,
	[title] [varchar](50) NULL,
	[cls] [int] NULL DEFAULT (0),
	[ModifyStamp] [varchar](30) NULL,
	[op] [int] NULL DEFAULT (0),
	[opdate] [datetime] NULL,
    [IsUsePJLY] [Int],
	[oldid] [int],
	[glsp] [int],
	[dspdate] [datetime] null,
	[bank_gys] [varchar](20) NULL,
	[dspmoney] [decimal](25, 12) NULL DEFAULT (0),
	[planfkid] [int] NULL,
	[payouttype] [int] NULL,
	[payout] [varchar](2000) NULL,
	[SureId]  int null,
	[SureListId]  int null,
	[BackSureListId] [int] null,
	[PayBz] [int] null,
	[BackSureId] [int] null,
	[KuinId] [int] null,
	[SendId] [int] null,
	[QCId] [int] null,
	[PayoutInvoiceId] [int] null
PRIMARY KEY CLUSTERED
(
	[ord] ASC
) ON [PRIMARY]
) ON [PRIMARY]

--@##mode:index;clustered:true;fields:ord
--@##mode:index;clustered:false;fields:contract
--@##mode:index;clustered:false;fields:company
--@##mode:index;clustered:false;fields:del,cls
--@##mode:index;clustered:false;fields:date1,date2,date3,date7
--@##mode:index;clustered:false;fields:complete,complete2
--@##mode:index;clustered:false;fields:addcate,cateid
--@##mode:index;clustered:false;fields:bank

GO
--付款明细表
create table [dbo].[payoutList](
	id int identity(1,1) not null primary key,
	product int not null,
	caigoulist int not null, --合同明细id
	payout int not null,--payback.id
	num1 [decimal](25, 12) NOT null DEFAULT(0),--收款数量
	money1 [decimal](25, 12) NOT null DEFAULT(0),--回款金额
	del int not null,
	[del2] [int] NULL        --删除时记录del的值，恢复时使用
)

GO

CREATE TABLE [dbo].[ERP_CustomValues](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FieldsID] [int] NOT NULL,
	[OrderID] [int] NOT NULL,
	[FValue] [nvarchar](4000) NOT NULL,
	[caigouQClist] [int] NULL
PRIMARY KEY CLUSTERED
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO

--扩展自定义日志
CREATE TABLE [dbo].[ERP_CustomValues_log](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CVID] [int] NULL,
	[FieldsID] [int] NOT NULL,
	[OrderID] [int] NOT NULL,
	[FValue] [nvarchar](4000) NULL,
	[FValue_old] [nvarchar](4000) NULL,
	[xgTime] [datetime] NULL,
	[xgOrd] [int] null,
	[ex_pid] [int] null,
PRIMARY KEY CLUSTERED
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[sale_proposal](
	[id] [int] NOT NULL,
	[PrefixCode] [varchar](20) NULL,
	[title] [varchar](200) NULL,
	[bh] [varchar](200) NULL,
	[company] [int] NULL,
	[person] [int] NULL,
	[ServerTime] [datetime] NULL,
	[cateid] [int] NULL,
	[TypeID] [int] NULL,
	[sortID] [int] NULL,
	[content] [text] NULL,
	[remark] [text] NULL,
	[product] [int] NULL,
	[status] [int] NULL,
	[indate] [datetime] NULL,
	[creator] [int] NULL,
	[appointor] [int] NULL, --指派人员
	[appointime] [datetime] NULL, --指派时间
	[alt] [int] NULL,
	[del] [int] NULL,
	[wxUserID] [int] NULL
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[O_BookSet](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[set_name] [varchar](200) NULL,
	[set_sort] [int] NULL,
	[set_note] [varchar](2000) NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[payout2](
	[ord] [int] IDENTITY(1,1) NOT NULL,
    [BH] [varchar](200) NULL,
	[money1] [decimal](25, 12) NULL,
	[date1] [datetime] NULL,
	[date2] [datetime] NULL,
	[complete] [int] NULL,
    [CompleteType] [int] not NULL default(0),
	[area] [int] NULL,
	[trade] [int] NULL,
	[pay] [int] NULL,
	[contractth] [int] NULL,
	[cateid] [int] NULL,
	[cateid2] [int] NULL,
	[cateid3] [int] NULL,
	[addcate] [int] NULL,
	[addcate2] [int] NULL,
	[addcate3] [int] NULL,
	[del] [int] NULL,
	[delcate] [int] NULL,
	[deldate] [datetime] NULL,
	[date7] [datetime] NULL,
	[intro] [nvarchar](200) NULL,
	[bank] [int] NULL,
	[ModifyStamp] [varchar](30) NULL,
	[op] [int] NULL DEFAULT (0),
	[opdate] [datetime] NULL,
	[payout2] [varchar](2000) NULL,
	[SureListId] [int] null,
	[FromType] [int] null,
    [BCheckId] [int] null,
	[SureId] [int] null,
	[PayBz] [int] null,
    PRIMARY KEY CLUSTERED
    (
        [ord] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


--@##mode:index;clustered:false;fields:contractth,area,pay,complete,cateid,del

GO
CREATE TABLE [dbo].[tongxunlu](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](50) NULL,
	[sort] int NULL,
	[share] [nvarchar](1000) NULL DEFAULT ('1'),
	[imgurl] [nvarchar](50) NULL,
	[sex] [nvarchar](10) NULL,
	[phone1] [nvarchar](30) NULL,
	[phone2] [nvarchar](30) NULL,
	[fax] [nvarchar](30) NULL,
	[mobile1] [nvarchar](30) NULL,
	[mobile2] [nvarchar](30) NULL,
	[email] [nvarchar](50) NULL,
	[qq] [nvarchar](30) NULL,
	[msn] [nvarchar](50) NULL,
	[birthday] [datetime] NULL,
	[wran] [int] NULL,
	[age] [int] NULL,
	[familyadd] [nvarchar](200) NULL,
	[postcode] [nvarchar](20) NULL,
	[company] [nvarchar](200) NULL,
	[comtel] [nvarchar](60) NULL,
	[comfax] [nvarchar](30) NULL,
	[comadd] [nvarchar](200) NULL,
	[positions] [nvarchar](20) NULL,
	[comadd1] [nvarchar](200) NULL,
	[zip] [nvarchar](20) NULL,
	[xl] [nvarchar](1000) NULL,
	[xw] [nvarchar](200) NULL,
	[zy] [nvarchar](200) NULL,
	[shool] [nvarchar](200) NULL,
	[jg] [nvarchar](1000) NULL,
	[mz] [nvarchar](50) NULL,
	[high] [nvarchar](20) NULL,
	[weigh] [nvarchar](20) NULL,
	[tx] [nvarchar](30) NULL,
	[xm] [nvarchar](10) NULL,
	[smoke] [nvarchar](20) NULL,
	[smotype] [nvarchar](30) NULL,
	[wine] [nvarchar](20) NULL,
	[winetype] [nvarchar](30) NULL,
	[winesign] [nvarchar](30) NULL,
	[winel] [nvarchar](30) NULL,
	[tea] [nvarchar](20) NULL,
	[teatype] [nvarchar](30) NULL,
	[food] [nvarchar](50) NULL,
	[health] [nvarchar](50) NULL,
	[drive] [nvarchar](20) NULL,
	[car] [nvarchar](20) NULL,
	[cartype] [nvarchar](50) NULL,
	[carcolor] [nvarchar](30) NULL,
	[cardrive] [nvarchar](30) NULL,
	[tz] [nvarchar](300) NULL,
	[tc] [ntext] NULL,
	[note] [nvarchar](2000) NULL,
	[date7] [datetime] NULL,
	[del] [int] NULL,
	[addcateid] [int] NULL,
	[delcateid] [int] NULL,
	[deldate] [datetime] NULL,
	[zdy1] [nvarchar](50) NULL,
	[zdy2] [nvarchar](50) NULL,
	[zdy3] [nvarchar](50) NULL,
	[zdy4] [nvarchar](50) NULL,
	[zdy5] [nvarchar](50) NULL,
	[zdy6] [nvarchar](50) NULL,
	[zdy7] [nvarchar](50) NULL,
	[zdy8] [nvarchar](50) NULL,
	[zdy9] [datetime] NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[bankout4](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[title] [varchar](200) NULL,
	[ck] [int] NULL,
	[money1] [decimal](25, 12) NULL,
	[intro] [varchar](500) NULL,
	[cateid] [int] NULL,
	[date3] [datetime] NULL,
	[date7] [datetime] NULL,
	[del] [int] NULL,
	[delcate] [int] NULL,
	[deldate] [datetime] NULL,
	[contract] [int] NULL,
	[company] [int] NULL,
	[bz] [int] NULL,
	[bank] [varchar](50) NULL,
	[payout] [int] NULL,
	[SureListId] [int] null,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
--预付款支付明细
CREATE TABLE [dbo].[bankout4_list](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[company] [int] NULL,
	[bz] [int] NULL,
	[money1] [decimal](25, 12) NULL,
	[intro] [ntext] NULL,
	[creator] [int] NULL,
	[date3] [datetime] NULL,
	[date7] [datetime] NULL,
	[del] [int] NULL,
	[bankout2] [int] NULL,
	[bankout4] [int] NULL,
	[payout] [int] NULL,
	[PaySureListId] [int] null,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]
 TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[payreturn](
	[ord] [int] IDENTITY(1,1) NOT NULL,
	[money1] [decimal](25, 12) NULL,
	[pay] [int] NULL,
	[returned] [int] NULL,
	[date1] [datetime] NULL,
	[date2] [datetime] NULL,
	[date3] [datetime] NULL,
	[date4] [datetime] NULL,
	[date5] [datetime] NULL,
	[date7] [datetime] NULL,
	[cateid] [int] NULL,
	[cateid2] [int] NULL,
	[cateid3] [int] NULL,
	[addcate] [int] NULL,
	[addcate2] [int] NULL,
	[addcate3] [int] NULL,
	[del] [int] NULL,
	[delcate] [int] NULL,
	[deldate] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [ord] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[M_OutOrder](
	[ID] [int] NOT NULL,
	[sn] [nvarchar](50) NULL,
	[PrefixCode] [varchar](2) NOT NULL,
	[title] [nvarchar](100) NULL,
	[MOrder] [int] NULL,
	[creator] [int] NULL,
	[indate] [datetime] NOT NULL,
	[status] [int] NOT NULL,
	[id_sp] [int] NOT NULL,
	[cateid_sp] [int] NOT NULL,
	[del] [int] NOT NULL,
	[TempSave] [int] NOT NULL DEFAULT (0),
	[odate] [datetime] NOT NULL,
	[gys] [int] NOT NULL,
	[fzr] [int] NOT NULL,
	[remark] [ntext] NOT NULL,
PRIMARY KEY CLUSTERED
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]

--@##mode:index;clustered:false;fields:MOrder
--@##mode:index;clustered:false;fields:creator
--@##mode:index;clustered:false;fields:indate desc
--@##mode:index;clustered:false;fields:odate
--@##mode:index;clustered:false;fields:gys
--@##mode:index;clustered:false;fields:fzr
--@##mode:index;clustered:false;fields:TempSave

GO
CREATE TABLE [dbo].[ERP_CustomTables](
	[tbid] [int] IDENTITY(1,1) NOT NULL,
	[tbName] [varchar](50) NOT NULL,
	[showName] [varchar](50) NULL,
	[remark] [varchar](100) NOT NULL,
PRIMARY KEY CLUSTERED
(
	[tbid] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[O_RegBook](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[bk_name] [varchar](2000) NULL,
	[bk_type] [int] NULL,
	[bk_bh] [varchar](1000) NULL,
	[bk_auther] [varchar](1000) NULL,
	[bk_publishing] [varchar](1000) NULL,
	[bk_ISBN] [varchar](1000) NULL,
	[bk_pubtime] [datetime] NULL,
	[bk_pagesize] [int] NULL,
	[bk_pagenum] [int] NULL,
	[bk_pubnum] [varchar](1000) NULL,
	[bk_printtime] [datetime] NULL,
	[bk_returnnum] [int] NULL,
	[bk_paper] [varchar](50) NULL,
	[bk_printnum] [varchar](1000) NULL,
	[bk_binding] [varchar](2000) NULL,
	[bk_format] [varchar](1000) NULL,
	[bk_num] [int] NULL,
	[bk_price] [decimal](25, 12) NULL,
	[bk_allnum] [int] NULL,
	[bk_allmoney] [decimal](25, 12) NULL,
	[bk_postion] [varchar](2000) NULL,
	[bk_note] [ntext] NULL,
	[bk_addcateid] [int] NULL,
	[bk_addtime] [datetime] NULL,
	[bk_del] [int] NULL DEFAULT (1),
	[ModifyStamp] [varchar](200) NULL DEFAULT (1),
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[smsRecv](
	[ord] [int] IDENTITY(1,1) NOT NULL,
	[phone] [nvarchar](50) NULL,
	[recvtime] [datetime] NULL,
	[content] [nvarchar](1000) NULL,
	[str1] [nvarchar](50) NULL,
	[strCompany] [nvarchar](50) NULL,
	[strMo] [nvarchar](200) NULL,
	[del] [int] NULL,
	[addtime] [datetime] NULL,
	[logid] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [ord] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[hr_expaper_write](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[expaperID] [int] NULL,
	[title] [varchar](500) NULL,
	[sortid] [int] NULL,
	[testtype] [int] NULL,
	[content] [text] NULL,
	[creator] [int] NULL,
	[indate] [datetime] NULL,
	[del] [int] NOT NULL,
	[point] [decimal](25, 12) NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[person](
	[ord] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](50) NULL,
	[sex] [nvarchar](10) NULL,
	[age] [nvarchar](10) NULL,
	[jg] [nvarchar](50) NULL,
	[part1] [nvarchar](50) NULL,
	[job] [nvarchar](50) NULL,
	[phone] [nvarchar](50) NULL,
	[phone2] [nvarchar](50) NULL,
	[fax] [nvarchar](50) NULL,
	[mobile] [nvarchar](50) NULL,
	[email] [nvarchar](50) NULL,
	[msn] [nvarchar](50) NULL,
	[qq] [nvarchar](20) NULL,
	[zip] [nvarchar](10) NULL,
	[address] [nvarchar](500) NULL,
	[photos] [nvarchar](500) NULL,
	[gate] [nvarchar](10) NULL,
	[year1] [varchar](20) NULL,
	[joy] [ntext] NULL,
	[company] [int] NULL,
	[area] [int] NULL,
	[sort] [nvarchar](20) NULL,
	[sort1] [nvarchar](20) NULL,
	[trade] [nvarchar](20) NULL,
	[intro] [ntext] NULL,
	[event] [int] NULL,
	[chance] [int] NULL,
	[plan1] [int] NULL,
	[numc1] [int] NULL,
	[order1] [int] NULL,
	[xl] [nvarchar](50) NULL,
	[xw] [nvarchar](50) NULL,
	[zy] [nvarchar](50) NULL,
	[yx] [nvarchar](50) NULL,
	[mz] [nvarchar](50) NULL,
	[mobile2] [nvarchar](50) NULL,
	[sg] [nvarchar](50) NULL,
	[tz] [nvarchar](50) NULL,
	[tx] [nvarchar](50) NULL,
	[xm] [nvarchar](50) NULL,
	[xy] [nvarchar](10) NULL,
	[xyname] [nvarchar](50) NULL,
	[yj] [nvarchar](10) NULL,
	[yjsort] [nvarchar](50) NULL,
	[yjname] [nvarchar](50) NULL,
	[yjsize] [nvarchar](50) NULL,
	[hc] [nvarchar](10) NULL,
	[hcsort] [nvarchar](50) NULL,
	[jk] [nvarchar](50) NULL,
	[jb] [nvarchar](50) NULL,
	[jz] [nvarchar](10) NULL,
	[sc] [nvarchar](10) NULL,
	[scsort] [nvarchar](50) NULL,
	[scys] [nvarchar](50) NULL,
	[scpz] [nvarchar](50) NULL,
	[tezheng] [nvarchar](50) NULL,
	[person] [int] NULL,
	[gx] [nvarchar](50) NULL,
	[cateid] [int] NULL,
	[cateid2] [int] NULL,
	[cateid3] [int] NULL,
	[date7] [datetime] NULL,
	[date4] [datetime] NULL,
	[date5] [datetime] NULL,
	[del] [int] NULL,
	[delcate] [int] NULL,
	[deldate] [datetime] NULL,
	[date8] [datetime] NULL,
	[pym] [nvarchar](50) NULL,
	[sort3] [int] NULL DEFAULT (1),
	[tezhen] [nvarchar](50) NULL,
	[alt] [varchar](4) NOT NULL DEFAULT (0),
	[birthdayType] [int] NULL DEFAULT (0),
	[person_excel_drSign] [bigint] NULL,
	[person_excel_drUser] [int] NULL,
	[role] [int] NULL,
	[bDays] [int] NULL,--存放当年生日距离当年第1天（公历1月1号）之间距离的天数
	[bDaysYear] [int] NULL,--存放当年的年份，如2014
	[weixinAcc] [nvarchar](100),--微信,
    PRIMARY KEY CLUSTERED
    (
        [ord] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]
 TEXTIMAGE_ON [PRIMARY]

--@##mode:index;clustered:false;fields:company
--@##mode:index;clustered:true;fields:ord
--@##mode:index;clustered:false;fields:name
--@##mode:index;clustered:false;fields:date7
--@##mode:index;clustered:false;fields:sort
--@##mode:index;clustered:false;fields:cateid
--@##mode:index;clustered:false;fields:del
--@##mode:index;clustered:false;fields:sort3
--@##mode:statistics;fields:del,sort3,company
--@##mode:statistics;fields:ord,del,sort3
--@##mode:statistics;fields:date7,name,ord,sort3
--@##mode:statistics;fields:date7,name,sort3,del,ord
--@##mode:statistics;fields:company,ord,del,sort3,date7
--@##mode:statistics;fields:company,ord,date7,name,del,sort3

GO

CREATE TABLE [dbo].[bankin3](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[company] [int] NULL,
	[bank] [int] NULL,
	[money1] [decimal](25, 12) NULL,
	[intro] [ntext] NULL,
	[date3] [datetime] NULL,
	[date7] [datetime] NULL,
	[cateid] [int] NULL,
	[del] [int] NULL,
	[delcate] [int] NULL,
	[deldate] [datetime] NULL,
	[intro2] [ntext] NULL,
	[bankin2] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]
 TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[home_StimulusWords](
	[uid] [int] NOT NULL,
	[words] [nvarchar](100) NULL,
PRIMARY KEY CLUSTERED
(
	[uid] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[plan1](
	[ord] [int] IDENTITY(1,1) NOT NULL,
	[intro] [ntext] NULL,
	[gate] [int] NULL,
	[complete] [nvarchar](10) NULL,
	[sort1] [int] NULL,
	[date1] [datetime] NULL, --截至日期
	[time1] [nvarchar](50) NULL DEFAULT (0), --截至小时
	[time2] [nvarchar](50) NULL DEFAULT (0), --截至分钟
	[order1] [nvarchar](20) NULL,
	[intro2] [ntext] NULL,
	[sort98] [int] Null,   --存储编辑时改写关联洽谈进展
	[cateid] [int] NULL,
	[cateid2] [int] NULL DEFAULT (0),
	[cateid3] [int] NULL,
	[company] [int] NULL DEFAULT (0),
	[person] [int] NULL DEFAULT (0),
	[option1] [int] NULL DEFAULT (0),
	[chance] [int] NULL DEFAULT (0),
	[lcb] [int] NULL DEFAULT (0),
	[contract] [int] NULL DEFAULT (0),
	[pay] [nvarchar](50) NULL DEFAULT (0),
	[date7] [datetime] NULL,
	[date4] [datetime] NULL,
	[date8] [datetime] NULL,
	[startdate1] [datetime] NULL, --开始日期
	[starttime1] [nvarchar](50) NULL DEFAULT (0), --开始小时
	[starttime2] [nvarchar](50) NULL DEFAULT (0), --开始分钟
	[isXunhuan] [int] NULL,
	[alt] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [ord] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]
 TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[txltype](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [varchar](50) NULL,
	[gate1] [int] NULL,
	[name] [varchar](50) NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[sms_temp_sort](
	[ord] [int] NOT NULL,
	[title] [nvarchar](100) NULL,
	[isopen] [int] NULL,
	[addTime] [datetime] NULL,
	[addcate] [int] NULL,
	[del] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[ord] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[bankin4](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[company] [int] NULL,
	[bank] [int] NULL,
	[money1] [decimal](25, 12) NULL,
	[intro] [ntext] NULL,
	[date3] [datetime] NULL,
	[date7] [datetime] NULL,
	[cateid] [int] NULL,
	[del] [int] NULL,
	[delcate] [int] NULL,
	[deldate] [datetime] NULL,
	[contract] [int] NULL,
	[bz] [int] NULL,
	[payback] [int] NULL,
	[PaySureListId] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]
 TEXTIMAGE_ON [PRIMARY]

GO
--预收款消费明细
CREATE TABLE [dbo].[bankin4_list](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[company] [int] NULL,
	[bz] [int] NULL,
	[money1] [decimal](25, 12) NULL,
	[intro] [ntext] NULL,
	[date3] [datetime] NULL,
	[date7] [datetime] NULL,
	[del] [int] NULL,
	[bankin2] [int] NULL,
	[bankin4] [int] NULL,
	[payback] [int] NULL,
    [Contract] [int] null,
    [PaySureListId] [int] null,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]
 TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[set1](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NULL,
	[sort1] [int] NULL,
	[sort1c] [nvarchar](30) NULL,
	[sort2] [int] NULL,
	[sort2c] [nvarchar](30) NULL,
	[url] [nvarchar](50) NULL,
	[name] [nvarchar](30) NULL,
	[set2] [int] NULL,
	[gate] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[O_proReturn](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[get_id] [int] NULL,
	[ret_title] [varchar](500) NULL,
	[ret_time] [datetime] NULL,
	[ret_state] [int] NULL,
	[ret_cateid] [int] NULL,
	[ret_bcateid] [int] NULL,
	[ret_btime] [datetime] NULL,
	[ret_bnote] [text] NULL,
	[ret_note] [text] NULL,
	[ret_addcateid] [int] NULL,
	[ret_addtime] [datetime] NULL,
	[ret_del] [int] NULL DEFAULT (1),
	[ModifyStamp] [varchar](200) NULL DEFAULT (1),
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[setbz](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[bz] [int] NULL DEFAULT (0),
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[paybx](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[complete] [int] NULL,
	[title] [nvarchar](200) NULL,
	[intro] [ntext] NULL,
	[bh] [nvarchar](200) NULL,
	[bz] [int] NULL,
	[indate] [datetime] NULL,
	[bxdate] [datetime] NULL,
	[cateid] [int] NULL,  --使用人员
	[cateid2] [int] NULL,  --部门
	[cateid3] [int] NULL,  --小组
	[addcate] [int] NULL,
	[sp_id] [int] NULL,
	[cateid_sp] [int] NULL,
	[del] [int] NULL,
	[delcate] [int] NULL,
	[deldate] [datetime] NULL,
	[dk] [int] NOT NULL DEFAULT (0),
	[jkid] [varchar](2000) NULL,
	[dkmoney] [decimal](25, 12) NOT NULL DEFAULT (80),
	[ModifyStamp] [varchar](30) NULL,
	[bxType] [int] NULL,	--报销分类
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[O_MeetingSet](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[set_name] [varchar](400) NULL,
	[set_gate1] [int] NULL,
	[set_note] [varchar](2000) NULL,
	[set_type] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[hr_process_log](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[processID] [varchar](100) NULL,
	[indate] [datetime] NULL,
	[creator] [int] NULL,
	[del] [int] NULL,
	[orderID] [int] NULL,
	[content] [text] NULL,
	[billID] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[hr_positive](
	[id] [int] NOT NULL,
	[title] [varchar](200) NULL,
	[bh] [varchar](100) NULL,
	[about] [text] NULL,
	[perform] [text] NULL,
	[status] [int] NULL,
	[creator] [int] NULL,
	[indate] [datetime] NULL,
	[id_sp] [int] NULL,
	[cateid_sp] [int] NULL,
	[addcate] [int] NULL,
	[addtime] [datetime] NULL,
	[TempSave] [bit] NULL,
	[del] [int] NULL,
	[cateName] [varchar](100) NULL,
	[sorceName] [varchar](100) NULL,
	[sorce2Name] [varchar](100) NULL,
	[PostionName] [varchar](100) NULL,
	[cateid] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[setchance](
	[ord] [int] IDENTITY(1,1) NOT NULL,
	[intro] [nvarchar](2000) NULL,
	[datetop] [datetime] NULL,
    PRIMARY KEY CLUSTERED
    (
        [ord] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[paybxlist](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[bxid] [int] NULL,
	[payid] [int] NULL,
	[money1] [decimal](25, 12) NOT NULL DEFAULT(0),
	[moneytmp] [decimal](25, 12) NULL,
	[intro] [ntext] NULL,
	[sort] [int] NULL,
	[datepay] [datetime] NULL,
    [iscostcollect] [int] NOT NULL DEFAULT(0),
	[del] [int] NULL,
	[addcate] [int] NULL,
	[indate] [datetime] NULL,
	[delcate] [int] NULL,
	[deldate] [datetime] NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

--@##mode:statistics;fields:del,payid
--@##mode:statistics;fields:payid,bxid,del
--@##mode:statistics;fields:id,bxid,del
--@##mode:statistics;fields:payid,sort,del,bxid,id

GO
CREATE TABLE [dbo].[hf_list](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[company] [int] NULL,
	[hfTime] [datetime] NULL,
	[hasHfTime] [datetime] NULL,
	[configID] [int] NULL,
	[configlistID] [int] NULL,
	[SQlTemplateID] [int] NULL,
	[statusID] [int] NULL,
	[cateid] [int] NULL,
	[user_list] [varchar](4000) NULL,
	[creator] [int] NULL,
	[indate] [datetime] NULL,
	[del] [int] NULL,
	[Stage] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[M_MenuClass](
	[ID] [int] NOT NULL,
	[PID] [int] NOT NULL DEFAULT (0),
	[ClsName] [nvarchar](50) NOT NULL,
	[sort] [decimal](25, 12) NOT NULL DEFAULT (0),
	[remark] [nvarchar](100) NULL,
PRIMARY KEY CLUSTERED
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[O_assStatename](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NULL,
	[sort1] [nvarchar](50) NULL,
	[intro] [varchar](2000) NULL,
	[gate1] [int] NULL,
	[ls] [int] NULL DEFAULT (0),
	[sort] [int] NULL,
	[del] [int] NULL DEFAULT (1),
	[StoreCode] [varchar](50) NULL,
	[StoreComment] [varchar](500) NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[setjm](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NULL,
	[intro] [int] NULL,
	[num1] [int] NULL,
	[gate1] [int] NULL,
	[tq1] [int] NULL,
	[fw1] [int] NULL,
	[cateid] [int] NULL,
	[disMobile] [int] NULL,
	[subCfgId] [int] not null default(0),
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[O_Meeting](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[met_name] [varchar](400) NULL,
	[met_describe] [varchar](2000) NULL,
	[met_peoplenum] [int] NULL,
	[met_address] [varchar](2000) NULL,
	[met_device] [varchar](4000) NULL,
	[met_state] [int] NULL,
	[met_note] [varchar](4000) NULL,
	[ModifyStamp] [varchar](200) NULL DEFAULT (1),
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[setjm2](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NULL,
	[intro] [int] NULL,
	[num1] [int] NULL,
	[gate1] [int] NULL,
	[tq1] [int] NULL,
	[fw1] [int] NULL,
	[cateid] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[O_prosearch](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[content] [varchar](200) NULL DEFAULT ('1'),
	[px] [int] NULL DEFAULT (1),
	[search] [varchar](200) NULL DEFAULT ('1'),
	[ord] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[setjm3](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NULL,
	[num1] [int] NULL,
	[cateid] [int] NULL,
	[intro] [nvarchar](500) NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[sale_server](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[title] [varchar](200) NULL,
	[bh] [varchar](200) NULL,
	[company] [int] NULL,
	[person] [int] NULL,
	[contract] [int] NULL,
	[modeID] [int] NULL,
	[sortID] [int] NULL,
	[cateID] [int] NULL,
	[startTime] [datetime] NULL,
	[spendTime] [datetime] NULL,
	[isResolved] [int] NULL,
	[content] [text] NULL,
	[feedback] [text] NULL,
	[remark] [text] NULL,
	[status] [int] NULL,
	[id_sp] [int] NULL,
	[cateid_sp] [int] NULL,
	[indate] [datetime] NULL,
	[creator] [int] NULL,
	[del] [int] NULL,
	[TempSave] [bit] NULL,
	[EndTime] [datetime] NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[hr_pub_partner](
	[id] [int] NOT NULL,
	[title] [varchar](500) NULL,
	[person] [varchar](50) NULL,
	[tel] [varchar](50) NULL,
	[mobile] [varchar](50) NULL,
	[fax] [varchar](50) NULL,
	[email] [varchar](50) NULL,
	[QQ] [varchar](50) NULL,
	[msn] [varchar](50) NULL,
	[address] [varchar](500) NULL,
	[website] [varchar](100) NULL,
	[weburl] [varchar](500) NULL,
	[uid] [varchar](100) NULL,
	[pwd] [varchar](100) NULL,
	[content] [text] NULL,
	[creator] [int] NULL,
	[TempSave] [bit] NULL,
	[indate] [datetime] NULL,
	[del] [int] NOT NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[setkd](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NULL,
	[sort] [int] NULL,
	[cateid] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[hf_ywlmSetings](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[title] [varchar](100) NULL,
	[SqlWhere] [varchar](1000) NULL,
	[IsUserdef] [char](10) NULL,
	[Remark] [char](10) NULL,
	[Indate] [datetime] NULL,
	[Del] [int] NULL,
	[table] [varchar](800) NULL,
	[filed] [varchar](50) NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[O_MeetingManager](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[man_name] [varchar](400) NULL,
	[man_content] [ntext] NULL,
	[man_time] [datetime] NULL,
	[man_meeting] [varchar](2000) NULL,
	[man_cateid] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[O_assStateType](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[sort1] [nvarchar](50) NULL,
	[gate1] [int] NULL,
	[del] [int] NULL DEFAULT (1),
	[ParentID] [int] NOT NULL DEFAULT (0),
	[StoreCode] [varchar](50) NULL,
	[Depth] [int] NOT NULL DEFAULT (0),
	[isLeef] [bit] NOT NULL DEFAULT (1),
	[RootID] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[action_list](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[username] [int] NULL,
	[name] [nvarchar](50) NULL,
	[page1] [nvarchar](max) NULL,
	[time_login] [datetime] NULL,
	[action1] [varchar](500) NULL,
	[type_login] [int] NULL DEFAULT (1),
	[type_sys] [varchar](1000) NULL,
	[type_brower] [varchar](1000) NULL,
	[ip][varchar](30),
	[keyValue][varchar](2000),
	[wxUserId] int,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[GatherRegistration](
	[SettingIndex] [int] NOT NULL,
	[TitleName] [varchar](100) NULL,
	[Location] [varchar](100) NULL
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[setsort](
	[ord] [int] IDENTITY(1,1) NOT NULL,
	[intro] [nvarchar](2000) NULL,
	[datetop] [datetime] NULL,
	[cateid] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [ord] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[arealist](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[area] [int] NULL,
	[cateid] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[O_MettingDevice](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[dev_name] [varchar](400) NULL,
	[dev_bh] [varchar](400) NULL,
	[dev_xh] [varchar](400) NULL,
	[dev_state] [int] NULL,
	[dev_alike] [varchar](4000) NULL,
	[dev_partofmeeting] [int] NULL,
	[dev_note] [ntext] NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[share](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NULL,
	[name] [nvarchar](20) NULL,
	[member2] [ntext] NULL,
	[date7] [datetime] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]
 TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[dk](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[jkid] [int] NOT NULL DEFAULT (0),
	[bxid] [int] NOT NULL DEFAULT (0),
	[jkmoney] [decimal](25, 12) NULL DEFAULT (0),
	[bankmoney] [decimal](25, 12) NULL DEFAULT (0),
	[dkmoney] [decimal](25, 12) NULL DEFAULT (0),
	[fhid] [int] NOT NULL DEFAULT (0),
	[del] [int] NOT NULL DEFAULT (1),
	[dkdate] [datetime] NULL
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[bank](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[bank] [int] NULL DEFAULT (0),
	[money1] [decimal](25, 12) NOT NULL DEFAULT (0),
	[money2] [decimal](25, 12) NULL DEFAULT (0),
	[sort] [int] NULL,
	[intro] [nvarchar](50) NULL,
	[gl] [int] NULL,
	[gl2] [int] NULL,
	[cateid] [int] NULL,
	[date1] [datetime] NULL,
	[date7] [datetime] NULL,
	[del] [int] NULL DEFAULT (1),
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


--@##mode:statistics;fields:date1,date7,id,bank
--@##mode:statistics;fields:del,bank,date1,date7,id

GO
CREATE TABLE [dbo].[O_proRetList](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ret_fid] [int] NULL,
	[prod_id] [int] NULL,
	[prod_num] [decimal](25, 12) NULL,
	[ret_intro] [text] NULL,
	[sto_id] [int] NULL,
	[ret_prostate] [int] NULL,
	[ret_prointro] [varchar](5000) NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[hr_person_certificate](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[personID] [int] NULL,
	[title] [varchar](100) NULL,
	[hasDate] [datetime] NULL,
	[agency] [varchar](100) NULL,
	[remark] [text] NULL,
	[indate] [datetime] NULL,
	[creator] [int] NULL,
	[del] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[hr_pub_postion](
	[id] [int] NOT NULL,
	[title] [nvarchar](50) NULL,
	[sorce] [int] NULL,
	[sorce2] [int] NULL,
	[creator] [int] NULL,
	[TempSave] [bit] NULL,
	[indate] [datetime] NULL,
	[del] [int] NOT NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[smtp](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ip] [nvarchar](50) NULL,
	[username] [nvarchar](50) NULL,
	[pw] [nvarchar](50) NULL,
	[cateid] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[bankin](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[title] [nvarchar](50) NULL,
	[ck] [int] NULL,
	[money1] [decimal](25, 12) NULL,
	[intro] [ntext] NULL,
	[cateid] [int] NULL,
	[date3] [datetime] NULL,
	[date7] [datetime] NULL,
	[del] [int] NULL,
	[delcate] [int] NULL,
	[deldate] [datetime] NULL,
    [bz] nvarchar(10) null,
    [typeord] INT null,
    [company] int null,
    [status] int  null,
	[relatedCate] [INT] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]
 TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[O_MeetingUse](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[use_meeting] [int] NULL,
	[use_title] [varchar](400) NULL,
	[use_property] [int] NULL,
	[use_important] [int] NULL,
	[use_device] [varchar](4000) NULL,
	[use_zcr] [varchar](4000) NULL,
	[use_jyy] [int] NULL,
	[use_cxry] [varchar](4000) NULL,
	[use_cxry2] [varchar](4000) NULL,
	[use_meetingcycle] [int] NULL,
	[use_intro] [int] NULL,
	[use_sms] [int] NULL,
	[use_id_sp] [int] NULL,
	[use_cateid_sp] [int] NULL,
	[use_complete] [int] NULL,
	[use_content] [ntext] NULL,
	[use_cateid] [int] NULL,
	[use_time] [datetime] NULL,
	[use_addcateid] [int] NULL,
	[use_addtime] [datetime] NULL,
	[use_stardate] [datetime] NULL,
	[use_enddate] [datetime] NULL,
	[use_startime] [datetime] NULL,
	[use_endtime] [datetime] NULL,
	[use_del] [int] NOT NULL DEFAULT (1),
	[use_state] [int] NOT NULL DEFAULT (1),
	[ModifyStamp] [varchar](200) NOT NULL DEFAULT (1),
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[smtpall](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ip] [nvarchar](50) NULL,
	[username] [nvarchar](50) NULL,
	[pw] [nvarchar](50) NULL,
	[cateid] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[M_FcDate](
	[ID] [int] NOT NULL,
	[PrefixCode] [varchar](2) NULL,
	[sn] [nvarchar](50) NULL,
	[title] [nvarchar](200) NULL,
	[creator] [int] NOT NULL,
	[date1] [datetime] NULL,
	[date2] [datetime] NULL,
	[indate] [datetime] NULL,
	[wobjtype] [int] NOT NULL DEFAULT (1),
	[wobj] [int] NOT NULL DEFAULT (0),
	[status] [int] NOT NULL,
	[id_sp] [int] NOT NULL,
	[cateid_sp] [int] NOT NULL,
	[del] [int] NOT NULL,
	[TempSave] [int] NOT NULL,
	[remark] [varchar](8000) NOT NULL,
PRIMARY KEY CLUSTERED
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]

--@##mode:index;clustered:false;fields:creator
--@##mode:index;clustered:false;fields:date1
--@##mode:index;clustered:false;fields:date2
--@##mode:index;clustered:false;fields:indate desc
--@##mode:index;clustered:false;fields:wobj

GO
CREATE TABLE [dbo].[bankin2](
	[id] [int] IDENTITY(1,1) NOT NULL,
    [title] [nvarchar](100) NULL,
	[company] [int] NULL,
	[bz] [int] NULL,
	[bank] [int] NULL,
	[money1] [decimal](25, 12) NULL,
	[intro] [ntext] NULL,
	[date3] [datetime] NULL,
    [EntryDate] [datetime] NULL,
    [Creator] [int] NULL,
    [cateid] [int] NULL,
	[sp] [int] NULL,
	[cateid_sp] [int] NULL,
	[status_sp] [int] NULL,
	[InvoiceMode] [int] NULL,
	[InvoiceType] [int] NULL,
	[planDate] [datetime] NULL,
    [bankinType] [int] null,
	[BankinStatus] [int] null	,
	[money_left] [decimal](25, 12) NULL,
    [FromType] [int] null,
	[payout2] [int] NULL,
    [SureID] [int] NULL,
    [SureListID] [int] NULL,
    [AptLOGID] [int] NULL,
    [alt] [int] NULL,
    [date7] [datetime] NULL,
	[del] [int] NULL,
	[delcate] [int] NULL,
	[deldate] [datetime] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]
 TEXTIMAGE_ON [PRIMARY]

--@##mode:index;clustered:false;fields:company,cateid,del,id,date3,date7

GO
CREATE TABLE [dbo].[O_kuCheck](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[che_title] [varchar](500) NULL,
	[che_bh] [varchar](500) NULL,
	[che_cateid] [int] NULL,
	[che_time] [datetime] NULL,
	[che_note] [text] NULL,
	[che_addcateid] [int] NULL,
	[che_addtime] [datetime] NULL,
	[che_del] [int] NULL,
	[ModifyStamp] [varchar](200) NULL DEFAULT (1),
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[sort](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NULL,
	[sort1] [int] NULL,
	[sort2] [nvarchar](50) NULL,
	[gate2] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[bankmove](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[title] [nvarchar](50) NULL,
	[ck1] [int] NULL,
	[ck2] [int] NULL,
	[money1] [decimal](25, 12) NULL,
	[intro] [ntext] NULL,
	[cateid] [int] NULL,
	[date3] [datetime] NULL,
	[date7] [datetime] NULL,
	[del] [int] NULL DEFAULT (1),
	[delcate] [int] NULL,
	[deldate] [datetime] NULL,
	[bzmoney] [decimal](25, 12) NULL DEFAULT (0),
    [hl] [decimal](25, 12) NULL DEFAULT (0),
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]
 TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[M_MenuItem](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[clsID] [int] NOT NULL,
	[title] [nvarchar](50) NULL,
	[url] [nvarchar](100) NULL,
	[billId] [int] NULL,
	[remark] [nvarchar](50) NULL,
	[powerCls] [int] NOT NULL DEFAULT (0),
	[powerItem] [int] NOT NULL DEFAULT (0),
	[sort] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [ID] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


--@##mode:index;clustered:false;fields:billId
--@##mode:index;clustered:false;fields:clsID
--@##mode:index;clustered:false;fields:powerCls
--@##mode:index;clustered:false;fields:powerItem
--@##mode:index;clustered:false;fields:sort
--@##mode:index;clustered:false;fields:ID

GO
CREATE TABLE [dbo].[O_assAddressname](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NULL,
	[sort1] [nvarchar](50) NULL,
	[intro] [varchar](2000) NULL,
	[gate1] [int] NULL,
	[ls] [int] NULL DEFAULT (0),
	[sort] [int] NULL,
	[del] [int] NULL DEFAULT (1),
	[StoreCode] [varchar](50) NULL,
	[StoreComment] [varchar](500) NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[sort_dh](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[sort1] [nvarchar](100) NULL,
	[cateid] [int] NULL,
	[gate1] [int] NULL,
	[zt] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[bom](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[product] [int] NULL,
	[unit] [int] NULL,
	[num1] [decimal](25, 12) NULL,
	[bombh] [nvarchar](50) NULL,
	[date1] [datetime] NULL,
	[date4] [datetime] NULL,
	[intro] [ntext] NULL,
	[complete] [int] NULL,
	[cateid] [int] NULL,
	[catesp] [int] NULL,
	[date7] [datetime] NULL,
	[del] [int] NULL,
	[delcate] [int] NULL,
	[deldate] [datetime] NULL,
    [ProductAttr1] [int] NULL,
    [ProductAttr2] [int] NULL,
    [ProductAttrBatchId] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]
 TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[hr_regime](
	[id] [int] NOT NULL,
	[title] [varchar](500) NULL,
	[bh] [varchar](50) NULL,
	[sortID] [int] NULL,
	[lv] [int] NULL,
	[note] [text] NULL,
	[user_list] [text] NULL,
	[content] [text] NULL,
	[creator] [int] NULL,
	[id_sp] [int] NULL,
	[cateid_sp] [int] NULL,
	[TempSave] [bit] NULL,
	[indate] [datetime] NULL,
	[del] [int] NOT NULL,
	[status] [int] NULL,
	[statusID] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[sort2](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NULL,
	[sort1] [int] NULL,
	[sort2] [nvarchar](50) NULL,
	[gate2] [int] NULL,
	[cateid] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[bomlist](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[product] [int] NULL,
	[ord] [int] NULL,
	[unit] [int] NULL,
	[num1] [decimal](25, 12) NULL,
	[price1] [decimal](25, 12) NULL,
	[money1] [decimal](25, 12) NULL,
	[intro] [nvarchar](200) NULL,
	[bom] [int] NULL,
	[cateid] [int] NULL,
	[date7] [datetime] NULL,
	[del] [int] NULL,
	[mxid] [int] NULL DEFAULT (0),
    [ProductAttr1] [int] NULL,
    [ProductAttr2] [int] NULL,
    [ProductAttrBatchId] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[O_kuCheList](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[che_fid] [int] NULL,
	[prod_id] [int] NULL,
	[che_zmnum] [decimal](25, 12) NULL,
	[che_sjnum] [decimal](25, 12) NULL,
	[che_yknum] [decimal](25, 12) NULL,
	[che_intro] [text] NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[smsHttpControl](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[logmessage] [int] NULL,
	[clientxlh] [bigint] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[sort4](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NULL,
	[sort1] [nvarchar](50) NULL,
	[gate1] [int] NULL,
	[khfl] [int] NULL,
	[sortzt] [int] NULL,
	[ts_used] [int] NULL,		--按天数自动修改跟进程度是否启用
	[ts_count] [int] NULL,		--时间间隔（天）,系统自动修改此客户跟进程度的判断条件
	[ts_sort] [int] NULL	--触发条件后，系统自动修改为改跟进程度,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[caigou](
	[ord] [int] IDENTITY(1,1) NOT NULL,
	[fromtype] [int] NULL,
	[title] [nvarchar](100) NULL,
	[cgid] [nvarchar](50) NULL,
	[company] [int] NULL,
	[sort] [int] NULL,
	[bz] [int] NULL DEFAULT (0),
	[premoney] [decimal](25, 12) NULL,	
	[yhtype] [int] NULL,	
	[zk] [decimal](25, 12) NOT NULL DEFAULT(-1),			
	[Inverse] [int] NULL,				
	[yhmoney] [decimal](25, 12) NULL,				
	[MxYhMoney]  [decimal](25, 12) NULL,		
	[money1] [decimal](25, 12) NULL,
	[money2] [decimal](25, 12) NULL,
	[invoicePlan] int not null default 1, 
	[date3] [datetime] NULL,
	[area] [int] NULL,
	[trade] [int] NULL,
	[person1] [nvarchar](50) NULL,
	[person2] [nvarchar](50) NULL,
	[intro] [ntext] NULL,
	[cateid] [int] NULL,
	[cateid2] [int] NULL,
	[cateid3] [int] NULL,
	[date7] [datetime] NULL,
	[zt1] [int] NULL DEFAULT (0),
	[sh1] [int] NULL,
	[sh2] [int] NULL,
	[lead] [int] NULL,
	[lead2] [int] NULL,
	[intro1] [nvarchar](500) NULL,
	[intro2] [nvarchar](500) NULL,
	[intro3] [nvarchar](500) NULL,
	[cateid_sp] [int] NULL,
	[sp] [int] NULL,
	[status] [INT] NULL ,
	[LastApproveTime] [datetime] null,
	[LastApproveUser] [int] null,
	[complete1] [nvarchar](50) NULL,
	[date2] [datetime] NULL,
	[limit] [int] NULL,
	[limitmoney] [decimal](25, 12) NULL,
	[limitpercent] [int] NULL,
	[fyhk] [int] NULL, 
	[fqfkType] [int] NULL,	
	[NeedQC] [bit] NULL,
	[QCState] [int] NULL,
	[sqState] [int] NULL,
	[company2] [int] NULL,
	[chance] [int] NULL,
	[price] [int] NULL,
	[contract] [int] NULL,
	[yugou] [int] NULL,
	[xunjia] [int] NULL,
	[zdy1] [nvarchar](50) NULL,
	[zdy2] [nvarchar](50) NULL,
	[zdy3] [nvarchar](50) NULL,
	[zdy4] [nvarchar](50) NULL,
	[zdy5] [int] NULL,
	[zdy6] [int] NULL,
	[addcate] [int] NULL,
	[cateorder1] [int] NULL,
    [UpTime] [datetime] NULL,
    [UpUser] [int] NULL,
	[isstop] [int] NULL DEFAULT (0),
	[stopOp] [int] NULL,
    [stopdate] [datetime] NULL,
	[del] [int] NULL,
	[del2] [int] NULL,
	[delcate] [int] NULL,
	[deldate] [datetime] NULL,
	[alt] [int] NULL DEFAULT (0),
	[ModifyStamp] [varchar](30) NULL,
	[ModifyStamp_fqfk] [varchar](30) NULL,
	[DataVersion] int NULL,
    [import] [BIGINT] NULL,
	[importPayout] [INT] NULL,
	[importInvoice] [INT] NULL,
	[importKuin] [INT] NULL,
    PRIMARY KEY CLUSTERED
    (
        [ord] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]
 TEXTIMAGE_ON [PRIMARY]

--@##mode:index;clustered:false;fields:contract,chance,price,cateid_sp,company,del
--@##mode:index;clustered:false;fields:ord
--@##mode:statistics;fields:date7,sp
--@##mode:statistics;fields:company,del
--@##mode:statistics;fields:del,date7
--@##mode:statistics;fields:ord,company
--@##mode:statistics;fields:bz,ord
--@##mode:statistics;fields:ord,cateid
--@##mode:statistics;fields:date7,contract,sp
--@##mode:statistics;fields:del,sp,date7
--@##mode:statistics;fields:company,bz,del
--@##mode:statistics;fields:date7,ord,del
--@##mode:statistics;fields:del,ord,company
--@##mode:statistics;fields:company,bz,ord,del
--@##mode:statistics;fields:contract,del,sp,date7

GO

CREATE TABLE [dbo].[caigoulist](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[rowindex] [int] NULL,
	[ord] [int] NULL,
	[unit] [int] NOT NULL DEFAULT (0),	
	[commUnitAttr] [nvarchar](200) NULL,
	[fromUnit] [int] NULL,
	[fromNum] [decimal](25, 12) NULL,
	[num1] [decimal](25, 12) NOT NULL DEFAULT (0),
	[num2] [decimal](25, 12) NULL DEFAULT (0),
	[num3] [decimal](25, 12) NULL DEFAULT (0),
	[numQcth] [decimal](25, 12) NULL DEFAULT (0),
	[pricejy] [decimal](25, 12) NOT null default (0),   --建议进价
	[price1] [decimal](25, 12) NOT NULL DEFAULT(0),     --未税单价
	[taxRate] [decimal](25, 12) NULL default 0,         --税率，数值来自票据类型设置表
	[invoiceType] int NULL default 0,                   --票据类型
	[discount] [decimal](25, 12) NULL DEFAULT 1,        --折扣
	[priceAfterDiscount] [decimal](25, 12) NOT NULL default 0,      --未税折后单价
	[priceAfterTax] [decimal](25, 12) NOT NULL default(0),          --含税单价
	[PriceAfterDiscountTaxPre] [decimal](25,12)  null,              --含税折后单价
	[Concessions]  [decimal](25,12) null,                           --优惠金额
	[TaxDstMoney]  [decimal](25,12) null,                           --税后总价
	[priceAfterDiscountTax] [decimal](25, 12) NOT NULL default(0),  --优惠后单价
	[moneyAfterDiscount] [decimal](25, 12) NOT NULL default(0),     --金额
	[taxValue] [decimal](25, 12) NOT NULL DEFAULT(0),               --税额
	[money1] [decimal](25, 12) NOT NULL DEFAULT (0),                --优惠后总价
    [Y_AfterDiscountTaxPrice] [decimal](25, 12) NOT NULL DEFAULT (0),   --原_优惠后单价
    [Y_Money] [decimal](25, 12) NOT NULL DEFAULT (0),                   --原_优惠后总价
    [Y_Num1] [decimal](25, 12) NOT NULL DEFAULT (0),                   --原_数量列
	[date2] [datetime] NULL,
	[intro] [nvarchar](200) NULL,
	[zdy1] [nvarchar](200) NULL,
	[zdy2] [nvarchar](200) NULL,
	[zdy3] [nvarchar](200) NULL,
	[zdy4] [nvarchar](200) NULL,
	[zdy5] [int] NULL,
	[zdy6] [int] NULL,
	[bz] [int] NOT NULL DEFAULT (14),
	[area] [int] NULL,
	[trade] [int] NULL,
	[company] [int] NULL,
	[company2] [int] NULL,
	[caigou] [int] NULL,--采购单ID
	[caigoulist_yg] [int] NULL,--预购明细id
	[chancelist] [int] NULL,
	[contractlist] [int] NULL,
	[xunjialist] [int] NULL,
	[Morderlist] [int] NULL,
	[cateid] [int] NULL,
	[cateid2] [int] NULL,
	[cateid3] [int] NULL,
	[addcate] [int] NULL,
	[date7] [datetime] NULL,
	[dateadd] [datetime] NULL,
	[del] [int] NULL,
	[del2] [int] NULL,
	[alt] [int] NULL DEFAULT (0),
	[price] [int] NULL DEFAULT(0), --报价
	[contract] [int] NULL,--合同
	[ProductAttr1] int null,
	[ProductAttr2] int null,
	[ProductAttrBatchId] int null,
    [MobileFromId] int null,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


--@##mode:index;clustered:false;fields:caigou,del
--@##mode:index;clustered:false;fields:id
--@##mode:index;clustered:false;fields:rowindex
--@##mode:statistics;fields:caigou,date7
--@##mode:statistics;fields:caigou,del
--@##mode:statistics;fields:date7,id,caigou
--@##mode:statistics;fields:ord,unit,del
--@##mode:statistics;fields:ord,caigou,del
--@##mode:statistics;fields:date7,ord,unit,del
--@##mode:index;clustered:false;fields:ord;include:id,num1,money1,caigou

GO

CREATE TABLE [dbo].[caigoulist_mx](
	[id] [INT] IDENTITY(1,1) NOT NULL,
	[ord] [INT] NULL,
	[fromType] [INT] NULL,
	[fromBillId] [INT] NULL,
	[fromid] [INT] NULL,
	[caigou] [INT] NULL,
	[caigoulist] [INT] NULL,
	[unit] [INT] NULL,
	[num1] [decimal](25, 12) NULL,
    [bl] [decimal](25, 12) NULL,
	[fromUnit] [INT] NULL,
	[fromNum] [decimal](25, 12) NULL,
	[addcate] [INT] NULL,
	[date7] [DATETIME] NULL,
	[del] [INT] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]

--@##mode:statistics;fields:caigou,caigoulist
--@##mode:statistics;fields:caigoulist
--@##mode:index;clustered:false;fields:caigou,del;include:caigoulist,num1
--@##mode:index;clustered:false;fields:caigoulist

GO

CREATE TABLE [dbo].[mobile_caigoulist](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NULL,
	[unit] [int] NOT NULL DEFAULT (0),
	[commUnitAttr] [nvarchar](200) NULL,
	[num1] [decimal](25, 12) NOT NULL DEFAULT (0),
	[pricejy] [decimal](25, 12) NOT null default (0),
	[price1] [decimal](25, 12) NOT NULL DEFAULT(0),
	[taxRate] [decimal](25, 12) NULL default 0, --税率，数值来自票据类型设置表
	[invoiceType] int NULL default 0, --票据类型
	[discount] [decimal](25, 12) NULL DEFAULT 1, --折扣
	[priceAfterDiscount] [decimal](25, 12) NOT NULL default 0,--折后单价
	[priceAfterTax] [decimal](25, 12) NOT NULL default(0),--税后单价
    [priceAfterDiscountTaxPre] [decimal](25, 12) NOT NULL default(0),--含税折后单价
    [TaxDstMoney] [decimal](25, 12) NOT NULL default(0),--含税折后总价
    [Concessions] [decimal](25, 12) NOT NULL default(0),--明细优惠
	[priceAfterDiscountTax] [decimal](25, 12) NOT NULL default(0),--优惠后单价
	[moneyAfterDiscount] [decimal](25, 12) NOT NULL default(0),--金额
	[taxValue] [decimal](25, 12) NOT NULL DEFAULT(0),--税额
	[money1] [decimal](25, 12) NOT NULL DEFAULT (0),--税后总额 (总额)
	[date2] [datetime] NULL,
	[intro] [nvarchar](200) NULL,
	[zdy1] [nvarchar](200) NULL,
	[zdy2] [nvarchar](200) NULL,
	[zdy3] [nvarchar](200) NULL,
	[zdy4] [nvarchar](200) NULL,
	[zdy5] [int] NULL,
	[zdy6] [int] NULL,
	[caigou] [int] NULL,        --采购单ID
	[caigoulist_yg] [int] NULL, --预购明细id
	[chancelist] [int] NULL,
	[contractlist] [int] NULL,
	[xunjialist] [int] NULL,
	[Morderlist] [int] NULL,
	[price] [int] NULL DEFAULT(0), --报价
	[contract] [int] NULL,--合同
	[addcate] [int] NULL,
	[date7] [datetime] NULL,
    [ProductAttr1] int null,
	[ProductAttr2] int null,
	[ProductAttrBatchId] int null,
	[isNew] int null,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[caigou_his](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NULL,
	[fromtype] [int] NULL,
	[title] [nvarchar](100) NULL,
	[cgid] [nvarchar](50) NULL,
	[company] [int] NULL,
	[sort] [int] NULL,
	[bz] [int] NULL DEFAULT (0),
	[premoney] [decimal](25, 12) NULL,			--原采购总额
	[yhtype] [int] NULL,				--优惠方式
	[zk] [decimal](25, 12) NOT NULL DEFAULT(-1),			--折扣,默认是10折
	[Inverse] [int] NULL,				--反算标志 0/ 1 折扣是否被反算.
	[yhmoney] [decimal](25, 12) NULL,				--优惠金额
	[money1] [decimal](25, 12) NULL,
	[money2] [decimal](25, 12) NULL,
	[invoicePlan] int not null default 2, --开票计划方式,1自动，2手动
	[date3] [datetime] NULL,
	[area] [int] NULL,
	[trade] [int] NULL,
	[person1] [nvarchar](50) NULL,
	[person2] [nvarchar](50) NULL,
	[intro] [ntext] NULL,
	[cateid] [int] NULL,
	[cateid2] [int] NULL,
	[cateid3] [int] NULL,
	[date7] [datetime] NULL,
	[zt1] [int] NULL DEFAULT (0),
	[sh1] [int] NULL,
	[sh2] [int] NULL,
	[lead] [int] NULL,
	[lead2] [int] NULL,
	[intro1] [nvarchar](500) NULL,
	[intro2] [nvarchar](500) NULL,
	[intro3] [nvarchar](500) NULL,
	[cateid_sp] [int] NULL,
	[sp] [int] NULL,
	[complete1] [nvarchar](50) NULL,
	[date2] [datetime] NULL,
	[limit] [int] NULL,
	[limitmoney] [decimal](25, 12) NULL,
	[limitpercent] [int] NULL,
	[fyhk] [int] NULL,   --付款计划类型
	[NeedQC] [bit] NULL,
	[QCState] [int] NULL,
	[sqState] [int] NULL,
	[company2] [int] NULL,
	[chance] [int] NULL,
	[price] [int] NULL,
	[contract] [int] NULL,
	[yugou] [int] NULL,
	[xunjia] [int] NULL,
	[zdy1] [nvarchar](50) NULL,
	[zdy2] [nvarchar](50) NULL,
	[zdy3] [nvarchar](50) NULL,
	[zdy4] [nvarchar](50) NULL,
	[zdy5] [int] NULL,
	[zdy6] [int] NULL,
	[addcate] [int] NULL,
	[cateorder1] [int] NULL,
	[isstop] [int] NULL DEFAULT (0),
	[stopOp] [int] NULL,
    [stopdate] [datetime] NULL,
    [UpTime] [datetime] NULL,
    [UpUser] [int] NULL,
	[del] [int] NULL,
	[del2] [int] NULL,
	[delcate] [int] NULL,
	[deldate] [datetime] NULL,
	[alt] [int] NULL DEFAULT (0),
	[ModifyStamp] [varchar](30) NULL,
	[op] [varchar](20) NULL,
	[ip] [varchar](30) NULL,
	[opdate] [datetime] NULL,
	[ChangeLog] [int] NULL,
	[MxYhMoney] [decimal](25,12)  null,
	[status] [INT] NULL ,
	[LastApproveTime] [datetime] null,
	[LastApproveUser] [int] null,
	[FqfkType] [int] null,
	[ModifyStamp_fqfk] [nvarchar](100) null,
	[DataVersion] [int]  null,
    [import] [BIGINT] NULL,
	[importPayout] [INT] NULL,
	[importInvoice] [INT] NULL,
	[importKuin] [INT] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]
 TEXTIMAGE_ON [PRIMARY]

GO

CREATE TABLE [dbo].[caigoulist_his](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[his_id] [int] NULL,
	[listid] [int] NULL,
	[ord] [int] NULL,
	[unit] [int] NOT NULL DEFAULT (0),
	[commUnitAttr] [nvarchar](200) NULL,
	[fromUnit] [int] NULL,
	[fromNum] [decimal](25, 12) NULL,
	[num1] [decimal](25, 12) NOT NULL DEFAULT (0),
	[num2] [decimal](25, 12) NULL DEFAULT (0),
	[num3] [decimal](25, 12) NULL DEFAULT (0),
	[numQcth] [decimal](25, 12) NULL DEFAULT (0),
	[pricejy] [decimal](25, 12) NOT null default (0),
	[price1] [decimal](25, 12) NOT NULL DEFAULT(0),
	[taxRate] [decimal](25, 12) NULL default 0, --税率，数值来自票据类型设置表
	[invoiceType] int NULL default 0, --票据类型
	[discount] [decimal](25, 12) NULL DEFAULT 1, --折扣
	[priceAfterDiscount] [decimal](25, 12) NOT NULL default 0,--折后单价
	[priceAfterTax] [decimal](25, 12) NOT NULL default(0),--税后单价
	[priceAfterDiscountTax] [decimal](25, 12) NOT NULL default(0),--税后单价
	[moneyAfterDiscount] [decimal](25, 12) NOT NULL default(0),--税前总额 (金额)
	[taxValue] [decimal](25, 12) NOT NULL DEFAULT(0),--税额
	[money1] [decimal](25, 12) NOT NULL DEFAULT (0),--税后总额 (总额)
    [Y_AfterDiscountTaxPrice] [decimal](25, 12) NOT NULL DEFAULT (0),   --原_优惠后单价
    [Y_Money] [decimal](25, 12) NOT NULL DEFAULT (0),                   --原_优惠后总价
    [Y_Num1] [decimal](25, 12) NOT NULL DEFAULT (0),                   --原_数量列
	[date2] [datetime] NULL,
	[intro] [nvarchar](200) NULL,
	[zdy1] [nvarchar](200) NULL,
	[zdy2] [nvarchar](200) NULL,
	[zdy3] [nvarchar](200) NULL,
	[zdy4] [nvarchar](200) NULL,
	[zdy5] [int] NULL,
	[zdy6] [int] NULL,
	[bz] [int] NOT NULL DEFAULT (14),
	[area] [int] NULL,
	[trade] [int] NULL,
	[company] [int] NULL,
	[company2] [int] NULL,
	[caigou] [int] NULL,--采购单ID
	[caigoulist_yg] [int] NULL,--预购明细id
	[chancelist] [int] NULL,
	[contractlist] [int] NULL,
	[xunjialist] [int] NULL,
	[Morderlist] [int] NULL,
	[cateid] [int] NULL,
	[cateid2] [int] NULL,
	[cateid3] [int] NULL,
	[addcate] [int] NULL,
	[date7] [datetime] NULL,
	[dateadd] [datetime] NULL,
	[del] [int] NULL,
	[del2] [int] NULL,
	[alt] [int] NULL DEFAULT (0),
	[price] [int] NULL DEFAULT(0), --报价
	[contract] [int] NULL,--合同
	[ProductAttr1] int null,
	[ProductAttr2] int null,
	[ProductAttrBatchId] int null,
	[PriceAfterDiscountTaxPre] [decimal](25,12) null,
    [MobileFromId] [int] null,
	[Concessions] [decimal](25,12)  null,
	[TaxDstMoney] [decimal](25,12)  null,
	[RowIndex] [int]  null,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[O_MeetingSummary](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[sum_metId] [int] NULL,
	[sum_content] [ntext] NULL,
	[sum_sendcateid] [varchar](4000) NULL,
	[sum_email] [varchar](4000) NULL,
	[sum_isemail] [int] NULL,
	[sum_sms] [varchar](4000) NULL,
	[sum_issms] [int] NULL,
	[sum_index] [varchar](4000) NULL,
	[sum_isindex] [int] NULL,
	[sum_addcateid] [int] NULL,
	[sum_addtime] [datetime] NULL,
	[sum_del] [int] NULL DEFAULT (1),
	[ModifyStamp] [varchar](200) NULL DEFAULT (1),
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[home_topmenu_cls_def](
	[ID] [int] NOT NULL,
	[clsName] [varchar](100) NOT NULL,
	[sort] [int] NOT NULL,
	[PID] [int] NOT NULL,
	[usign] varchar(40) not NULL default(''),
PRIMARY KEY CLUSTERED
(
	[ID] ASC,
	[usign] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[sort4jj](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NULL,
	[sort1] [nvarchar](50) NULL,
	[gate1] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[caigou_yg](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[fromtype] [int] NULL,
	[title] [nvarchar](100) NULL,
	[ygid] [nvarchar](50) NULL,
	[date1] [datetime] NULL,
	[intro1] [ntext] NULL,
	[date7] [datetime] NULL,
	[cateid] [int] NULL,
	[cateid2] [int] NULL,
	[cateid3] [int] NULL,
	[cateorder1] [int] NULL, --指派人员
	[date2] [datetime] NULL, --指派时间
	[sort1] [int] NULL,
	[needxj] [int] NULL,
	[bz] [int] NULL,
	[money1] [decimal](25, 12) NULL DEFAULT(0),
	[zt1] [int] NULL DEFAULT(0),
	[del] [int] NULL,
	[alt] [nvarchar](4000) NULL,
	[share_op] [int] NULL, --共享操作人
	[share] [varchar](8000) , --共享人员
	[company] [int] NULL,
	[price] [int] NULL,
	[chance] [int] NULL,
	[contract] [int] NULL,
	[xunjia] [int] NULL,
	[MOrderID] [int] NULL,
	[cateid_sp] [int] NULL,
	[sp] [int] NULL,
	[status] [int] NULL,
	[addcate] [int] NULL, --单据原始添加人 指派时赋值
	[del_op] [int] NULL,
	[deltime] [datetime] NULL,
    [M2_AnalysisID] [int] NULL,
	[M2_OrderID] [int] NULL,
	[M2_AssignID] [int] NULL,
	[M2_OutID] [int] NULL,
    [IsStop] [int] NULL DEFAULT(0),
    [StopOp] [int] NULL,
    [StopDate] [datetime] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]
 TEXTIMAGE_ON [PRIMARY]

--@##mode:index;clustered:false;fields:contract,company,MOrderID,del
--@##mode:index;clustered:false;fields:id,del
--@##mode:index;clustered:false;fields:contract,del,date1 desc
--@##mode:index;clustered:false;fields:chance,xunjia,price,cateid

GO

CREATE TABLE [dbo].[caigoulist_yg](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NULL,
	[unit] [int] NOT NULL DEFAULT(0),
	[gys] [int] NOT NULL DEFAULT(0),
	[price1] [decimal](25, 12) NOT NULL DEFAULT(0),
	[num1] [decimal](25, 12) NOT NULL DEFAULT(0),
	[num2] [decimal](25, 12) NULL,
	[money1] [decimal](25, 12) NOT NULL DEFAULT(0),
	[intro1] [nvarchar](200) NULL,
	[date1] [datetime] NULL,
	[date2] [datetime] NULL,
	[date7] [datetime] NULL,
	[zdy1] [nvarchar](200) NULL,
	[zdy2] [nvarchar](200) NULL,
	[zdy3] [nvarchar](200) NULL,
	[zdy4] [nvarchar](200) NULL,
	[zdy5] [int] NULL,
	[zdy6] [int] NULL,
	[caigou] [int] NULL,
	[caigou2] [int] NULL,
	[cateid] [int] NULL,
	[cateid2] [int] NULL,
	[cateid3] [int] NULL,
	[zt1] [int] NULL DEFAULT (0),
	[del] [int] NULL,
	[company] [int] NULL,
	[price] [int] NULL,
	[chance] [int] NULL,
	[contract] [int] NULL,
	[xunjia] [int] NULL,
	[MOrderID] [int] NULL,
    [M2_AnalysisID] [int] NULL,
	[M2_OrderID] [int] NULL,
	[M2_AssignID] [int] NULL,
	[M2_OutID] [int] NULL,
	[chancelist] [int] NULL,
	[contractlist] [int] NULL,
    [xunjialist] [int] NULL,
	[Morderlist] [int] NULL,
    [M2_Analysislist] [int] NULL,
    [M2_Orderlist] [int] NULL,
    [M2_Assignlist] [int] NULL,
    [M2_Outlist] [int] NULL,
    [M2_BomListID] int NULL,
	[Kuoutlist] int NULL,
    [ProductAttr1] int null,
	[ProductAttr2] int null,
	[ProductAttrBatchId] int null,
    [CommUnitAttr] [nvarchar](200) NULL,
    [CgPerson] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]

--@##mode:index;clustered:true;fields:id
--@##mode:index;clustered:false;fields:ord,del
--@##mode:index;clustered:false;fields:caigou,caigou2
--@##mode:index;clustered:false;date1,date2

GO

CREATE TABLE [dbo].[O_kuCheck_his](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[che_id] [int] NULL,
	[che_title] [varchar](500) NULL,
	[che_bh] [varchar](500) NULL,
	[che_cateid] [int] NULL,
	[che_time] [datetime] NULL,
	[che_note] [text] NULL,
	[che_addcateid] [int] NULL,
	[che_addtime] [datetime] NULL,
	[che_del] [int] NULL,
	[del_time] [datetime] NULL,
	[del_cateid] [int] NULL,
	[del_IP] [varchar](200) NULL,
	[ModifyStamp] [varchar](200) NULL DEFAULT (1),
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]
 TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[O_assAddressType](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[sort1] [nvarchar](50) NULL,
	[gate1] [int] NULL,
	[del] [int] NULL DEFAULT (1),
	[ParentID] [int] NOT NULL DEFAULT (0),
	[StoreCode] [varchar](50) NULL,
	[Depth] [int] NOT NULL DEFAULT (0),
	[isLeef] [bit] NOT NULL DEFAULT (1),
	[RootID] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[MessageRecv](
	[ord] [int] IDENTITY(1,1) NOT NULL,
	[logmessage] [int] NULL,
	[phone] [varchar](20) NULL,
	[content] [varchar](2000) NULL,
	[rectime] [datetime] NULL,
    PRIMARY KEY CLUSTERED
    (
        [ord] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[sort5](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NULL,
	[sort1] [int] NULL,
	[sort2] [nvarchar](50) NULL,
	[gate2] [int] NULL,
	[time1] [int] NULL DEFAULT (0),
	[time2] [int] NULL DEFAULT (0),
	[num1] [int] NULL DEFAULT (0),
	[jf] [decimal](25, 12) NULL,
	[mustHas] [int] Null, 
	[AutoNext] [int] Null, 
	[mustContentType] [int] Null,
	[mustContent] [nvarchar](500) Null,
	[mustRole] [nvarchar](500) Null,
	[mustzdy] [nvarchar](500) Null, 
	[mustkz_zdy] [nvarchar](500) Null, 
	[perSuccess] [int] Null, 
	[unautoback] [int] Null, 
	[unback] [int] Null,
	[protect] [int] Null, 
	[isProtect] [int] Null, 
	[unreplyback1] [int] Null,
	[unreplyback2] [int] Null,
	[unsalesback] [int] Null,
	[stayback] [int] Null,
	[staydays] [int] Null,
	[maxback] [int] Null,
	[maxbackdays] [int] Null,
	[canRemind] [int] Null,
	[Reminddays] [int] Null,
	[cateid] [int] Null,
	[date7] [datetime] null,
	[del] [int] Null,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


--@##mode:index;clustered:false;fields:time1,ord

GO

--不同人员及客户跟进程度的收回期限
create table [dbo].[sort5_gate](
	[id] [int] IDENTITY (1, 1) NOT NULL ,
	[gateord] [int] null,  --gate.ord
	[sort5] [int] null, --sort5.ord
	[unback1day] [int] null,
	[unback2day] [int] Null,
	[salesbackday] [int] Null,
	[staydays] [int] null,  --个人本阶段最长停留时间
	[maxbackdays] [int] null	--个人本阶段最长跟进天数
)


GO
CREATE TABLE [dbo].[sort5list](
	[id] [int] identity(1,1) not Null,
	[sort5] [int] Null,  --sort5.id
	[gate2] [int] Null,  --阶段排序 0:首次联系,9998:以后每次联系,9999:自动暂停跟踪
	[days] [int] Null, --与上次联系间隔天数
	[del] [int] null  --是否删除
)

GO
CREATE TABLE [dbo].[paysq](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[title] [nvarchar](200) NULL,
	[cateid] [int] NOT NULL DEFAULT (0),
	[bz] [int] NOT NULL DEFAULT (14),
	[sqmoney] [decimal](25, 12) NOT NULL DEFAULT (0),
	[spmoney] [decimal](25, 12) NOT NULL DEFAULT (0),
	[days] [int] NOT NULL DEFAULT (0),
	[deptys] [decimal](25, 12) NOT NULL DEFAULT (0),
	[intro] [ntext] NULL,
	[sp_date] [datetime] NULL,
	[jk] [int] NOT NULL DEFAULT (0),
	[complete] [int] NOT NULL DEFAULT (0),
	[sp] [int] NOT NULL DEFAULT (0),
	[cateid_sp] [int] NOT NULL DEFAULT (0),
	[date_sp] [datetime] NULL,
	[addcateid] [int] NOT NULL DEFAULT (0),
	[adddate] [datetime] NULL,
	[delcateid] [int] NOT NULL DEFAULT (0),
	[deldate] [datetime] NULL,
	[del] [int] NOT NULL DEFAULT (0),
	[ModifyStamp] [varchar](30) NULL,
	[remark] [ntext] NULL
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

CREATE TABLE [dbo].[caigoubz](
    [id] [int] IDENTITY(1,1) NOT NULL,
	[intro1] [ntext] NULL,
	[intro2] [ntext] NULL,
	[intro3] [ntext] NULL,
	[intro4] [ntext] NULL,
	[intro5] [ntext] NULL,
	[intro6] [ntext] NULL,
	[caigou] [int] NULL,
	[date7] [datetime] NULL,
	[del] [int] NULL,
	[addcate] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]
 TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[home_topmenu_item_def](
	[ID] [int] NOT NULL,
	[title] [varchar](50) NULL,
	[sort] [int] NULL,
	[cls] [int] NULL,
	[remark] [varchar](100) NULL,
	[url] [varchar](200) NULL,
	[qxlb] [int] NULL,
	[qxlist] [int] NULL,
	[otype] [int] NULL,
	[usign] varchar(40) not NULL default(''),
	[ModelExpress] [VARCHAR](100) NOT NULL DEFAULT('')
PRIMARY KEY CLUSTERED
(
	[ID] ASC,
	[usign] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[sort8](
	[ord] [int] IDENTITY(1,1) NOT NULL,
	[sort1] [nvarchar](500) NULL,
    PRIMARY KEY CLUSTERED
    (
        [ord] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[M_MaterialMove](
	[ID] [int] NOT NULL,
	[sn] [nvarchar](50) NULL,
	[PrefixCode] [nvarchar](2) NOT NULL,
	[title] [nvarchar](200) NULL,
	[WAID] [int] NOT NULL,
	[DDNO] [int] NOT NULL,
	[newWAID] [int] NOT NULL,
	[newDDNO] [int] NOT NULL,
	[mvDate] [datetime] NOT NULL,
	[rMan] [int] NULL,
	[remark] [varchar](500) NULL,
	[id_sp] [int] NOT NULL,
	[cateid_sp] [int] NOT NULL,
	[TempSave] [bit] NOT NULL,
	[status] [int] NOT NULL,
	[del] [int] NOT NULL DEFAULT (0),
	[creator] [int] NOT NULL,
	[indate] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]

--@##mode:index;clustered:false;fields:creator
--@##mode:index;clustered:false;fields:indate desc
--@##mode:index;clustered:false;fields:mvDate
--@##mode:index;clustered:false;fields:newWAID
--@##mode:index;clustered:false;fields:newDDNO
--@##mode:index;clustered:false;fields:WAID
--@##mode:index;clustered:false;fields:DDNO
--@##mode:index;clustered:false;fields:rMan

GO
CREATE TABLE [dbo].[celue](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ts] [nvarchar](200) NULL DEFAULT (0),
	[jz] [nvarchar](200) NULL DEFAULT (0),
	[bt] [nvarchar](200) NULL DEFAULT (0),
	[sort1] [int] NULL,
	[sp_money0] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[M_VerDataUpdateInfo](
	[upTime] [datetime] NULL,
	[uid] [int] NULL,
	[ver] [decimal](25, 12) NULL
) ON [PRIMARY]

--@##mode:index;clustered:false;fields:uid
--@##mode:index;clustered:false;fields:upTime

GO
CREATE TABLE [dbo].[sortalt](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NULL,
	[sort1] [nvarchar](50) NULL,
	[may] [int] NULL,
	[gate1] [int] NULL,
	[intro] [nvarchar](2000) NULL,
	[txtj] [int] NULL DEFAULT (1),
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[sms_xlhlist](
	[xlh] [int] NOT NULL,
PRIMARY KEY CLUSTERED
(
	[xlh] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[hr_resume_Language](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Resume] [int] NULL,
	[typeID] [nvarchar](50) NULL,
	[Proficiency] [nvarchar](50) NULL,
	[Literacy] [nvarchar](50) NULL,
	[Lis_speak] [nvarchar](50) NULL,
	[content] [text] NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

CREATE TABLE [dbo].[sortbank](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[sort1] [nvarchar](50) NULL,
	[intro] [nvarchar](50) NULL,
	[bz] [int] NULL DEFAULT (0),
	[gate1] [int] NULL,
	[sorce] [int] NULL,
	[del] [int] NULL,
	[person] [ntext] NULL,
	[addcate] [int] NULL,
	[intro2] [nvarchar](50) NULL,
    [minusMoney] [decimal](25, 12) NULL,
	[minus] [int] NULL,
    [AccountType] [int] NOT NULL DEFAULT (0),
    [IsOpenCharge] [int] NOT NULL DEFAULT (0),
    [ChargeMin] [decimal](25,12) null,
    [ChargeMax] [decimal](25,12) null,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]
 TEXTIMAGE_ON [PRIMARY]

--@##mode:index;clustered:false;fields:id,del


GO

CREATE TABLE [dbo].[chance](
	[ord] [int] IDENTITY(1,1) NOT NULL,
	[title] [nvarchar](100) NULL,
	[xmid] [nvarchar](50) NULL,
	[area] [int] NULL,
	[trade] [int] NULL,
	[complete1] [int] NULL,
	[complete2] [int] NULL,
	[sorce] [int] NULL,
	[premoney] [decimal](25, 12) NULL,			--原项目总额
	[yhtype] [int] NULL,				--优惠方式
	[zk] [decimal](25, 12) NOT NULL DEFAULT(-1),			--折扣,默认是10折
	[Inverse] [int]  NULL,				--反算标志 0/ 1 折扣是否被反算.
	[yhmoney] [decimal](25, 12) NULL,				--优惠金额
	[money1] [decimal](25, 12) NULL DEFAULT (0),
	[money2] [decimal](25, 12) NULL,
	[money3] [decimal](25, 12) NULL,
	[bz] [int] NULL DEFAULT (0),
	[pay1] [decimal](25, 12) NULL DEFAULT (0),
	[intro] [ntext] NULL,
	[date1] [datetime] NULL,
	[date2] [datetime] NULL,
	[date3] [datetime] NULL,
	[cateid] [int] NULL,
	[cateid2] [int] NULL,
	[cateid3] [int] NULL,
	[company] [nvarchar](4000) NULL,
	[person] [int] NULL,
	[person_list] [nvarchar](4000) NULL,
	[contract] [int] NULL,
	[product] [int] NULL,
	[date7] [datetime] NULL,
	[del] [int] NULL,
	[delcate] [int] NULL,
	[deldate] [datetime] NULL,
	[order1] [int] NULL,
	[cateid4] [int] NULL,
	[cateorder1] [int] NULL,
	[date5] [datetime] NULL,
	[share] [nvarchar](1000) NULL,
	[zdy1] [nvarchar](50) NULL,
	[zdy2] [nvarchar](50) NULL,
	[zdy3] [nvarchar](50) NULL,
	[zdy4] [nvarchar](50) NULL,
	[zdy5] [int] NULL,
	[zdy6] [int] NULL,
	[bj] [int] NULL DEFAULT (0),
	[num1] [decimal](25, 12) NULL,
	[addcate] [int] NULL DEFAULT (0),
	[cateidfq] [int] NULL,
	[sortfq] [int] NULL,
	[datefq] [datetime] NULL,
	[cateid_sp] [int] NULL,
	[sp] [int] NULL,
	[alt] [nvarchar](4000) NULL,
	[alt2] [varchar](4000) NULL,
    [del2] [int] NULL,
	[chance] [int] NULL,
	[ProcId] [int] NULL,
	[ProcName] [nvarchar](50) NULL,
    PRIMARY KEY CLUSTERED
    (
        [ord] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]
 TEXTIMAGE_ON [PRIMARY]

--@##mode:index;clustered:false;fields:ord,del,date1 desc,company,person,contract,complete2

GO

CREATE TABLE [dbo].[chancelist](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NULL,
	[price1] [decimal](25, 12) NULL,
	[num1] [decimal](25, 12) NOT NULL DEFAULT(0),
	[money2] [decimal](25, 12) NOT NULL DEFAULT(0),
	[date1] [datetime] NULL,
	[chance] [int] NULL,
	[del] [int] NULL,
	[addcate] [int] NULL,
	[bz] [int] NOT NULL DEFAULT (14),
	[date2] [datetime] NULL,
	[date7] [datetime] NULL,
	[zdy1] [nvarchar](200) NULL,
	[zdy2] [nvarchar](200) NULL,
	[zdy3] [nvarchar](200) NULL,
	[zdy4] [nvarchar](200) NULL,
	[zdy5] [int] NULL,
	[zdy6] [int] NULL,
	[unit] [int] NOT NULL default (0),
	[intro] [nvarchar](200) NULL,
    [pricejy] [decimal](25, 12) NOT NULL default (0),
    [tpricejy] [decimal](25, 12) NOT NULL default (0),
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


--@##mode:index;clustered:false;fields:id,date7
--@##mode:index;clustered:false;fields:chance,del

GO

CREATE TABLE [dbo].[mobile_chancelist](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NULL,
	[price1] [decimal](25, 12) NULL,
	[num1] [decimal](25, 12) NOT NULL DEFAULT(0),
	[money2] [decimal](25, 12) NOT NULL DEFAULT(0),
	[date1] [datetime] NULL,
	[chance] [int] NULL,
	[del] [int] NULL,
	[addcate] [int] NULL,
	[bz] [int] NOT NULL DEFAULT (14),
	[date2] [datetime] NULL,
	[date7] [datetime] NULL,
	[zdy1] [nvarchar](200) NULL,
	[zdy2] [nvarchar](200) NULL,
	[zdy3] [nvarchar](200) NULL,
	[zdy4] [nvarchar](200) NULL,
	[zdy5] [int] NULL,
	[zdy6] [int] NULL,
	[unit] [int] NOT NULL default (0),
	[intro] [nvarchar](200) NULL,
    [pricejy] [decimal](25, 12) NOT NULL default (0),
    [tpricejy] [decimal](25, 12) NOT NULL default (0),
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


--@##mode:index;clustered:false;fields:id,date7
--@##mode:index;clustered:false;fields:chance,del

GO

CREATE TABLE [dbo].[chance_his](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] null,
	[title] [nvarchar](100) NULL,
	[xmid] [nvarchar](50) NULL,
	[area] [int] NULL,
	[trade] [int] NULL,
	[complete1] [int] NULL,
	[complete2] [int] NULL,
	[sorce] [int] NULL,
	[premoney] [decimal](25, 12) NULL,			--原项目总额
	[yhtype] [int] NULL,				--优惠方式
	[zk] [decimal](25, 12) NOT NULL DEFAULT(-1),			--折扣,默认是10折
	[Inverse] [int]  NULL,				--反算标志 0/ 1 折扣是否被反算.
	[yhmoney] [decimal](25, 12) NULL,				--优惠金额
	[money1] [decimal](25, 12) NULL DEFAULT (0),
	[money2] [decimal](25, 12) NULL,
	[money3] [decimal](25, 12) NULL,
	[bz] [int] NULL DEFAULT (0),
	[pay1] [decimal](25, 12) NULL DEFAULT (0),
	[intro] [ntext] NULL,
	[date1] [datetime] NULL,
	[date2] [datetime] NULL,
	[date3] [datetime] NULL,
	[cateid] [int] NULL,
	[cateid2] [int] NULL,
	[cateid3] [int] NULL,
	[company] [nvarchar](4000) NULL,
	[person] [int] NULL,
	[person_list] [nvarchar](4000) NULL,
	[contract] [int] NULL,
	[product] [int] NULL,
	[date7] [datetime] NULL,
	[del] [int] NULL,
	[delcate] [int] NULL,
	[deldate] [datetime] NULL,
	[order1] [int] NULL,
	[cateid4] [int] NULL,
	[cateorder1] [int] NULL,
	[date5] [datetime] NULL,
	[share] [nvarchar](1000) NULL,
	[zdy1] [nvarchar](50) NULL,
	[zdy2] [nvarchar](50) NULL,
	[zdy3] [nvarchar](50) NULL,
	[zdy4] [nvarchar](50) NULL,
	[zdy5] [int] NULL,
	[zdy6] [int] NULL,
	[bj] [int] NULL DEFAULT (0),
	[num1] [decimal](25, 12) NULL,
	[addcate] [int] NULL DEFAULT (0),
	[cateidfq] [int] NULL,
	[sortfq] [int] NULL,
	[datefq] [datetime] NULL,
	[cateid_sp] [int] NULL,
	[sp] [int] NULL,
	[alt] [nvarchar](4000) NULL,
	[alt2] [varchar](4000) NULL,
    [del2] [int] NULL,
	[chance] [int] NULL,
	[ProcId] [int] NULL,
	[ProcName] [nvarchar](50) NULL,
	[op] [varchar](20) NULL,
	[ip] [varchar](30) NULL,
	[opdate] [datetime] NULL,
	[ChangeLog] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]
 TEXTIMAGE_ON [PRIMARY]

GO

CREATE TABLE [dbo].[chancelist_his](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[his_id] [int] NULL,
	[listid] [int] NULL,
	[ord] [int] NULL,
	[price1] [decimal](25, 12) NULL,
	[num1] [decimal](25, 12) NOT NULL DEFAULT(0),
	[money2] [decimal](25, 12) NOT NULL DEFAULT(0),
	[date1] [datetime] NULL,
	[chance] [int] NULL,
	[del] [int] NULL,
	[addcate] [int] NULL,
	[bz] [int] NOT NULL DEFAULT (14),
	[date2] [datetime] NULL,
	[date7] [datetime] NULL,
	[zdy1] [nvarchar](200) NULL,
	[zdy2] [nvarchar](200) NULL,
	[zdy3] [nvarchar](200) NULL,
	[zdy4] [nvarchar](200) NULL,
	[zdy5] [int] NULL,
	[zdy6] [int] NULL,
	[unit] [int] NOT NULL default (0),
	[intro] [nvarchar](200) NULL,
    [pricejy] [decimal](25, 12) NOT NULL default (0),
    [tpricejy] [decimal](25, 12) NOT NULL default (0),
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[M_BOM](
	[ID] [int] NOT NULL,
	[PrefixCode] [nvarchar](2) NOT NULL,
	[title] [nvarchar](100) NULL,
	[BOMBH] [nvarchar](50) NULL,
	[Creator] [int] NOT NULL,
	[indate] [datetime] NOT NULL,
	[id_sp] [int] NULL,
	[cateid_sp] [int] NULL,
	[DateBegin] [datetime] NULL,
	[DateEnd] [datetime] NULL,
	[status] [int] NOT NULL,
	[TempSave] [bit] NOT NULL,
	[del] [int] NOT NULL,
	[intro] [ntext] NULL,
PRIMARY KEY CLUSTERED
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]

--@##mode:index;clustered:false;fields:Creator
--@##mode:index;clustered:false;fields:indate desc
--@##mode:index;clustered:false;fields:DateBegin
--@##mode:index;clustered:false;fields:DateEnd

GO
CREATE TABLE [dbo].[hr_AppHoliday](
	[id] [int] NOT NULL,
	[title] [nvarchar](50) NULL,
	[content] [text] NULL,
	[creator] [int] NULL,
	[PrefixCode] [nvarchar](50) NULL,
	[KQClass] [int] NULL,
	[KQClass1] [int] NULL,
	[startTime] [datetime] NULL,
	[endTime] [datetime] NULL,
	[inDate] [datetime] NULL,
	[id_sp] [int] NULL,
	[cateid_sp] [int] NULL,
	[status] [int] NULL,
	[del] [int] NULL,
	[appType] [int] NULL,
	[ModifyStamp] [int] NULL,
	[addcate] [int] NULL,
	[tempsave] int null,
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[O_asset](
	[ass_id] [int] IDENTITY(1,1) NOT NULL,
	[ass_name] [varchar](400) NULL,
	[ass_xh] [varchar](400) NULL,
	[ass_bh] [varchar](400) NULL,
	[ass_type] [int] NULL,
	[ass_cartype] [int] NULL,
	[ass_state] [int] NULL,
	[ass_jczl] [decimal](25, 12) NULL,
	[ass_jcz] [decimal](25, 12) NULL,
	[ass_jttime] [datetime] NULL,
	[ass_jttime_bak] [datetime] NULL,
	[ass_isjt] [int] NULL,
	[ass_cycle] [int] NULL,
	[ass_cycle1] [int] NULL,
	[ass_ycycle] [int] NULL,
	[ass_method] [int] NULL,
	[ass_pj] [varchar](4000) NULL,
	[ass_cateid] [int] NULL,
	[ass_time] [datetime] NULL,
	[ass_money] [decimal](25, 12) NULL,
	[ass_money2] [decimal](25, 12) NULL,
	[ass_using] [datetime] NULL,
	[ass_lycateid] [varchar](4000) NULL,
	[ass_lytime] [datetime] NULL,
	[ass_position] [varchar](400) NULL,
	[ass_note] [ntext] NULL,
	[ass_addcateid] [int] NULL,
	[ass_addtime] [datetime] NULL,
	[ass_del] [int] NULL DEFAULT (1),
	[ass_delcateid] [int] NULL,
	[ass_deltime] [datetime] NULL,
	[ModifyStamp] [varchar](4000) NULL DEFAULT ('1'),
PRIMARY KEY CLUSTERED
(
	[ass_id] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[sortbz](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[sort1] [nvarchar](50) NULL,
	[intro] [nvarchar](50) NULL,
	[gate1] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


--@##mode:index;clustered:false;fields:id,gate1

GO
CREATE TABLE [dbo].[check](
	[id] [int] NOT NULL,
	[ord] [int] NULL,
	[smile] [int] NULL,
	[confi] [int] NULL,
	[plan] [int] NULL,
	[phone1] [int] NULL,
	[visit] [int] NULL,
	[ship] [int] NULL,
	[hit] [int] NULL,
	[phone2] [int] NULL,
	[party] [int] NULL,
	[help] [int] NULL,
	[know] [int] NULL,
	[think] [int] NULL,
	[money1] [int] NULL,
	[money2] [int] NULL,
	[nu] [int] NULL,
	[feel] [ntext] NULL,
	[date1] [nvarchar](50) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[O_MeetingUseList](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[lst_fid] [int] NULL,
	[lst_starttime] [datetime] NULL,
	[lst_endtime] [datetime] NULL,
	[lst_met_id] [int] NULL,
	[lst_note] [varchar](500) NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[M_BOMList](
	[ID] [int] NOT NULL DEFAULT (0),
	[PrefixCode] [nvarchar](2) NOT NULL DEFAULT (0),
	[BOM] [int] NOT NULL DEFAULT (0),
	[ParentID] [int] NOT NULL DEFAULT (0),
	[ChildID] [int] NULL,
	[ProductID] [int] NOT NULL DEFAULT (0),
	[MRPID] [int] NULL DEFAULT (0),
	[RankCode] [int] NOT NULL DEFAULT (0),
	[unit] [int] NOT NULL DEFAULT (0),
	[Num] [decimal](25, 12) NOT NULL DEFAULT (0),
	[StoreID] [int] NOT NULL DEFAULT (0),
	[WCID] [int] NULL DEFAULT (0),
	[WPID] [int] NULL DEFAULT (0),
	[PCWastage] [decimal](25, 12) NOT NULL DEFAULT (0),
	[SaveNum] [decimal](25, 12) NULL,
	[MType] [int] NOT NULL DEFAULT (0),
	[ReplaceFlag] [int] NOT NULL DEFAULT (0),
	[ReplaceID] [int] NULL DEFAULT (0),
	[ReplaceRatio] [decimal](25, 12) NULL,
	[VirtualFlag] [bit] NOT NULL DEFAULT (0),
	[isEntity] [bit] NULL,
	[VirtualID] [int] NULL,
	[Impress] [int] NOT NULL DEFAULT (0),
	[single] [bit] NOT NULL DEFAULT (0),
	[del] [int] NOT NULL DEFAULT (0),
	[WProc] [int] NOT NULL DEFAULT (0),
	[Role] [smallint] NOT NULL DEFAULT (0),
PRIMARY KEY CLUSTERED
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]

--@##mode:index;clustered:false;fields:BOM
--@##mode:index;clustered:false;fields:ParentID
--@##mode:index;clustered:false;fields:ChildID
--@##mode:index;clustered:false;fields:ProductID
--@##mode:index;clustered:false;fields:MRPID
--@##mode:index;clustered:false;fields:RankCode
--@##mode:index;clustered:false;fields:unit
--@##mode:index;clustered:false;fields:StoreID
--@##mode:index;clustered:false;fields:WCID
--@##mode:index;clustered:false;fields:WPID
--@##mode:index;clustered:false;fields:WProc

GO
CREATE TABLE [dbo].[sortck](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NULL,
	[sort1] [nvarchar](50) NULL,
	[intro] [ntext] NULL,
	[gate1] [int] NULL,
	[ls] [int] NULL DEFAULT (0),
	[sort] [int] NULL,
	[del] [int] NULL DEFAULT (1),
	[StoreCode] [varchar](50) NULL,
	[StoreComment] [varchar](500) NULL,
	[FullPath] [nvarchar] (500) NULL,
	[RootPath] [nvarchar] (50) NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]
 TEXTIMAGE_ON [PRIMARY]

--@##mode:index;clustered:false;fields:sort,del,ord,id
--@##mode:index;clustered:false;fields:ord
--@##mode:index;clustered:false;fields:id

GO

CREATE TABLE [dbo].[contract](
	[ord] [int] IDENTITY(1,1) NOT NULL,
	[title] [nvarchar](100) NULL,
	[htid] [nvarchar](50) NULL,
	[sort] [int] NULL,
	[complete1] [int] NULL,
	[area] [int] NULL,
	[trade] [int] NULL,
	[premoney] [decimal](25, 12) NULL,			--原合同总额
	[yhtype] [int] NULL,				--优惠方式
	[zk] [decimal](25, 12) NOT NULL DEFAULT(-1),			--折扣,默认是10折
	[Inverse] [int] NULL,				--反算标志 0/ 1 折扣是否被反算.
	[yhmoney] [decimal](25, 12) NULL,				--优惠金额
	[money1] [decimal](25, 12) NOT NULL DEFAULT (0),
	[money2] [decimal](25, 12) NULL,
	[bz] [int] NOT NULL DEFAULT (14),
	[date3] [datetime] NULL,
	[date1] [datetime] NULL,
	[date2] [datetime] NULL,
	[person1] [nvarchar](50) NULL,
	[person2] [nvarchar](50) NULL,
	[pay] [nvarchar](100) NULL,
	[intro] [ntext] NULL,
	[addcate] [int] NULL,
	[addcate2] [char](10) NULL,
	[addcate3] [char](10) NULL,
	[cateid] [int] NULL,
	[cateid2] [int] NULL,
	[cateid3] [char](10) NULL,
	[company] [int] NULL,
	[person] [int] NULL,
	[event1] [int] NULL,
	[option1] [int] NULL,
	[chance] [int] NULL,
	[date7] [datetime] NULL,
	[del] [int] NULL,
	[delcate] [int] NULL,
	[deldate] [datetime] NULL,
	[zt1] [int] NULL DEFAULT (1),
	[zt2] [int] NULL DEFAULT (0),
	[contract] [int] NULL,
	[cateid_sp] [int] NULL,
	[sp] [int] NULL,
	[del2] [int] NULL,
	[alt] [int] NULL DEFAULT (0),
	[money_tc1] [decimal](25, 12) NULL DEFAULT (0),
	[money_tc2] [decimal](25, 12) NULL DEFAULT (0),
	[tc] [int] NULL DEFAULT (0),
	[price] [int] NULL,
	[zdy1] [nvarchar](200) NULL,
	[zdy2] [nvarchar](200) NULL,
	[zdy3] [nvarchar](200) NULL,
	[zdy4] [nvarchar](200) NULL,
	[zdy5] [int] NULL,
	[zdy6] [int] NULL,
	[alt2] [int] NULL,
	[person2id] [int] NULL,
	[fqhk] [int] NULL DEFAULT (0),
	[paybacktype] [int] NULL DEFAULT (0),
	[share] [nvarchar](1000) NULL,
	[addshare] [int] NULL DEFAULT (0),
	[ModifyStamp] [varchar](500) NULL,
	[kujh] [int] NULL,
	[sort1] [INT] NULL,
	[customerArr] VARCHAR(4000) NULL,
	[isTerminated] int null, 
    [stopOp] [int] NULL,
    [stopdate] [datetime] NULL,
	[paybackMode] int not null default 1, --收款类型，1汇总模式，2明细模式
	[invoiceMode] int not null default 1, --开票类型，0不开票，1汇总模式，2明细模式
	[repairOrderId] int null, --repairOrder.id 维修单id
	[extras] [decimal](25, 12), --运杂费
	[invoicePlan] int not null default 2, --开票计划方式,1自动，2手动
	[invoicePlanType] int not null default 0, --开票计划票据类型
    [taxRate] [decimal](25, 12) NULL default 0, --税率，数值来自票据类型设置表
	[cpCostChanged] bit not null default 0, --产品成本是否已变动（合同出库产品对应的采购单被修改价格时，此字段值为1）
	[taxValue] [decimal](25, 12),--税额，这个值仅在微信合同中用于显示税前和税后金额
	[payStatus] [int],--微信商城生成的合同的支付状态，非微信商城的合同这个字段应该为null值
	[payKind] [int],--微信商城生成的合同的支付方式，非微信商城的合同这个字段应该为null值，1为在线支付，2为货到付款
	[wxUserId] [int],--订单所属微信用户的id，记录这个是为了在微信用户被关联上别的客户时依旧能够看到自己的订单
	[receiver] nvarchar(50),--收货人
	[phone] nvarchar(50),--固话
	[mobile] nvarchar(50),--手机
	[address] nvarchar(500),--地址
	[zip] nvarchar(50),--邮编
	[areaId][int],--地址，关联manuarea.id
	[showOnWXShop] int,--是否在微信商城显示
	[isReceived] int,--是否已收货
	[receiveTime] datetime,--收货时间
	[import] [BIGINT] NULL,
	[importPayback] [INT] NULL,
	[importInvoice] [INT] NULL,
	[importKuout] [INT] NULL,
	[importSend] [INT] NULL,
    [uptime]  datetime  null,
    [upuser]   int   null,
    [AutoCreateType] [INT] NULL,--生产执行   空为=手动 1=自动生成预生产计划
	[CKAccModel]   int   null,
	[DataVersion] int null,
	[SortType] [INT] NULL,
    [status] [int]  NULL DEFAULT(-1),
    PRIMARY KEY CLUSTERED
    (
        [ord] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]
 TEXTIMAGE_ON [PRIMARY]

--@##mode:index;clustered:false;fields:company,date7 desc
--@##mode:index;clustered:false;fields:ord,del,bz,title,date3,cateid
--@##mode:index;clustered:false;fields:date3,del,date7 desc
--@##mode:index;clustered:false;fields:date2,del,date7 desc
--@##mode:index;clustered:false;fields:RepairOrderID,del,date7 desc
--@##mode:index;clustered:false;fields:del,sp desc
--@##mode:index;clustered:false;fields:del;include:date2,cateid,share
--@##mode:statistics;fields:bz,date3
--@##mode:statistics;fields:invoicePlan,ord
--@##mode:statistics;fields:del,date7
--@##mode:statistics;fields:bz,del
--@##mode:statistics;fields:cateid,ord
--@##mode:statistics;fields:del,date3
--@##mode:statistics;fields:date3,del,date7
--@##mode:statistics;fields:ord,del,date7
--@##mode:statistics;fields:company,ord,cateid
--@##mode:statistics;fields:ord,date3,del
--@##mode:statistics;fields:ord,bz,date3
--@##mode:statistics;fields:date7,ord,date3,del
--@##mode:statistics;fields:bz,ord,cateid,company,date7

GO

CREATE TABLE [dbo].[home_topmenu_cls_us](
	[ID] [int] NOT NULL,
	[clsName] [varchar](100) NOT NULL,
	[sort] [int] NOT NULL,
	[PID] [int] NOT NULL,
	[sysID] [int] NOT NULL DEFAULT (0),
	[uid] [int] NOT NULL,
	[stop] [int] NOT NULL DEFAULT (0),
PRIMARY KEY CLUSTERED
(
	[ID] ASC,
	[uid] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[M_CustomFields](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[OID] [int] NOT NULL,
	[IsMaster] [bit] NULL,
	[FOrder] [int] NOT NULL,
	[FName] [nvarchar](30) NOT NULL,
	[FType] [int] NOT NULL,
	[MustFillin] [bit] NOT NULL,
	[OptionID] [int] NULL,
	[FStyle] [nvarchar](500) NULL,
	[del] [int] NOT NULL,
	[IsUsing] [bit] NULL,
	[CanExport] [bit] NULL,
	[CanSearch] [bit] NULL,
	[CanStat] [bit] NULL,
	[LastModify] [datetime] NULL,
PRIMARY KEY CLUSTERED
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]

--@##mode:index;clustered:false;fields:OID
--@##mode:index;clustered:false;fields:FOrder
--@##mode:index;clustered:false;fields:OptionID

GO
CREATE TABLE [dbo].[hr_Fc_time](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[personClass] [int] NULL,
	[workClass] [int] NULL,
	[d1] [datetime] NULL,
	[d2] [datetime] NULL,
	[remark] [text] NULL,
	[del] [int] NULL,
	[indate] [datetime] NULL,
	[creator] [int] NULL,
	[hr_fc] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]
 TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[erp_sms_TimerTask](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[addTime] [datetime] NOT NULL,
	[fireTime] [datetime] NOT NULL,
	[url] [varchar](100) NOT NULL,
	[execTime] [datetime] NOT NULL,
	[execed] [int] NOT NULL,
	[uid] [int] NOT NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[sortck1](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[sort1] [nvarchar](50) NULL,
	[gate1] [int] NULL,
	[del] [int] NULL DEFAULT (1),
	[ParentID] [int] NOT NULL DEFAULT (0),
	[StoreCode] [varchar](50) NULL,
	[Depth] [int] NOT NULL DEFAULT (0),
	[RootID] [int] NULL,
	[isLeef] [bit] NOT NULL DEFAULT (1),
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


--@##mode:index;clustered:true;fields:id
--@##mode:index;clustered:false;fields:ParentID,del,gate1,id
--@##mode:index;clustered:false;fields:Depth
--@##mode:index;clustered:false;fields:RootID

GO
CREATE TABLE [dbo].[M_ManurInfo](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](80) NOT NULL,
	[oid] [int] NULL,
	[cls] [nvarchar](80) NULL,
	[smcls] [nvarchar](80) NULL,
	[v] [nvarchar](100) NULL,
	[remark] [nvarchar](200) NULL,
PRIMARY KEY CLUSTERED
(
	[name] ASC
) ON [PRIMARY]
) ON [PRIMARY]

--@##mode:index;clustered:false;fields:oid

GO
CREATE TABLE [dbo].[contract_out](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[title] [nvarchar](200) NULL,
	[main] [int] NULL,
	[sort] [int] NULL,
	[A1] [ntext] NULL,
	[A2] [nvarchar](100) NULL,
	[A3] [nvarchar](100) NULL,
	[B1_1] [nvarchar](100) NULL,
	[B1_2] [nvarchar](100) NULL,
	[B2_1] [nvarchar](100) NULL,
	[B2_2] [nvarchar](100) NULL,
	[B3_1] [nvarchar](100) NULL,
	[B3_2] [nvarchar](100) NULL,
	[B4_1] [nvarchar](100) NULL,
	[B4_2] [nvarchar](100) NULL,
	[B5_1] [nvarchar](100) NULL,
	[B5_2] [nvarchar](100) NULL,
	[B6_1] [nvarchar](100) NULL,
	[B6_2] [nvarchar](100) NULL,
	[C1] [nvarchar](100) NULL,
	[C2] [nvarchar](100) NULL,
	[C3] [nvarchar](100) NULL,
	[D1] [nvarchar](100) NULL,
	[D2] [nvarchar](100) NULL,
	[D3] [nvarchar](100) NULL,
	[D4] [nvarchar](100) NULL,
	[D5] [nvarchar](100) NULL,
	[D6] [nvarchar](100) NULL,
	[D7] [nvarchar](100) NULL,
	[D8] [nvarchar](100) NULL,
	[E1_1] [nvarchar](100) NULL,
	[E1_2] [nvarchar](100) NULL,
	[E2_1] [nvarchar](100) NULL,
	[E2_2] [nvarchar](100) NULL,
	[E3_1] [nvarchar](100) NULL,
	[E3_2] [nvarchar](100) NULL,
	[E4_1] [nvarchar](100) NULL,
	[E4_2] [nvarchar](100) NULL,
	[E5_1] [nvarchar](100) NULL,
	[E5_2] [nvarchar](100) NULL,
	[E6_1] [nvarchar](100) NULL,
	[E6_2] [nvarchar](100) NULL,
	[E7_1] [nvarchar](100) NULL,
	[E7_2] [nvarchar](100) NULL,
	[E8_1] [nvarchar](100) NULL,
	[E8_2] [nvarchar](100) NULL,
	[E9_1] [nvarchar](100) NULL,
	[E9_2] [nvarchar](100) NULL,
	[E10_1] [nvarchar](100) NULL,
	[E10_2] [nvarchar](100) NULL,
	[E11_1] [nvarchar](100) NULL,
	[E11_2] [nvarchar](100) NULL,
	[E12_1] [nvarchar](100) NULL,
	[E12_2] [nvarchar](100) NULL,
	[cateid] [int] NULL,
	[del] [int] NULL,
	[delcate] [int] NULL,
	[deldate] [datetime] NULL,
	[countnum] [int] NULL,
	[PrintID] [int] NULL,
	[LoopColumns] [ntext] NULL,
	[isStop] [int] null,
	[isSUNMI] [INT] NULL,
	[pageType] [nvarchar](20) NULL,
	[pageWidth] [money] NULL,
	[pageHeight] [money] NULL,
	[topMargin] [money] NULL,
	[bottomMargin] [money] NULL,
	[leftMargin] [money] NULL,
	[rightMargin] [money] NULL,
	[barcodetype] [int]  NOT NULL DEFAULT (0),
    [barcodewidth] [int] NULL,
    [barcodeheight] [int] NULL,
    [qrcodewidth] [int] NULL,
    [qrcodequality] [int] NOT NULL DEFAULT (3),
    [NumberBit] [int] NULL,
    [MoneyBit] [int] NULL,
    [CommonPriceBit] [int] NULL,
    [SalePriceBit] [int] NULL,
    [StorePriceBit] [int] NULL,
    [FinancePriceBit] [int] NULL,
    [printtype] [int]  NOT NULL DEFAULT (0),
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]
 TEXTIMAGE_ON [PRIMARY]

--@##mode:statistics;fields:sort,del
--@##mode:statistics;fields:main,sort,del

GO
CREATE TABLE [dbo].[M_CustomOptions](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CFID] [int] NULL,
	[CValue] [nvarchar](500) NULL,
	[del] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]

--@##mode:index;clustered:false;fields:CFID

GO
CREATE TABLE [dbo].[hr_resume_Train_exp](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Resume] [int] NULL,
	[startDate] [datetime] NULL,
	[endDate] [datetime] NULL,
	[institut] [nvarchar](100) NULL,
	[address] [nvarchar](500) NULL,
	[courses] [nvarchar](100) NULL,
	[certificate] [nvarchar](100) NULL,
	[detail] [text] NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[sortcp1](
	[id] [int] NOT NULL,
	[id1] [int] NULL,
	[menuname] [nvarchar](50) NULL,
	[url] [int] NULL,
	[gate1] [int] NULL
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[contractbz](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[intro1] [ntext] NULL,
	[intro2] [ntext] NULL,
	[intro3] [ntext] NULL,
	[intro4] [ntext] NULL,
	[intro5] [ntext] NULL,
	[intro6] [ntext] NULL,
	[contract] [int] NULL,
	[date7] [datetime] NULL,
	[del] [int] NULL,
	[addcate] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]
 TEXTIMAGE_ON [PRIMARY]

--@##mode:index;clustered:false;fields:contract

GO
CREATE TABLE [dbo].[M_CustomSQLStrings](
	[ID] [int] NOT NULL,
	[SQLString] [nvarchar](1000) NOT NULL,
	[sColumns] [nvarchar](100) NOT NULL DEFAULT ('0'),
	[hColumns] [nvarchar](100) NOT NULL DEFAULT (''),
	[SearchItems] [nvarchar](100) NOT NULL DEFAULT (''),
	[GroupString] [nvarchar](100) NULL,
	[CenterCols] [nvarchar](100) NULL,
	[LinkURL] [nvarchar](500) NULL,
	[Title] [nvarchar](100) NULL,
	[Description] [ntext] NULL,
PRIMARY KEY CLUSTERED
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[O_asset2](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ass_id] [int] NULL,
	[ass_name] [varchar](400) NULL,
	[ass_xh] [varchar](400) NULL,
	[ass_bh] [varchar](400) NULL,
	[ass_type] [int] NULL,
	[ass_cartype] [int] NULL,
	[ass_state] [int] NULL,
	[ass_jczl] [decimal](25, 12) NULL,
	[ass_jcz] [decimal](25, 12) NULL,
	[ass_jttime] [datetime] NULL,
	[ass_isjt] [int] NULL,
	[ass_cycle] [int] NULL,
	[ass_cycle1] [int] NULL,
	[ass_ycycle] [int] NULL,
	[ass_method] [int] NULL,
	[ass_pj] [varchar](4000) NULL,
	[ass_cateid] [int] NULL,
	[ass_time] [datetime] NULL,
	[ass_money] [decimal](25, 12) NULL,
	[ass_money2] [decimal](25, 12) NULL,
	[ass_using] [datetime] NULL,
	[ass_lycateid] [varchar](4000) NULL,
	[ass_lytime] [datetime] NULL,
	[ass_position] [varchar](400) NULL,
	[ass_note] [ntext] NULL,
	[ass_addcateid] [int] NULL,
	[ass_addtime] [datetime] NULL,
	[ass_del] [int] NULL DEFAULT (1),
	[ass_complete] [int] NULL DEFAULT (1),
	[ass_cateid_sp] [int] NULL,
	[ass_id_sp] [int] NULL,
	[ModifyStamp] [varchar](4000) NULL DEFAULT ('1'),
	[updatecateid] [int] NULL,
	[updatetime] [datetime] NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[email_status](
	[softTime] [datetime] NULL
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[sortcp2](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NULL,
	[sort1] [int] NULL,
	[sort2] [nvarchar](20) NULL,
	[gate2] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[M_FlowLogs](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[PrefixCode] [nvarchar](2) NOT NULL,
	[OrderID] [int] NOT NULL,
	[inDate] [datetime] NOT NULL,
	[cateid_sp] [int] NOT NULL,
	[Result_sp] [bit] NOT NULL,
	[intro] [varchar](1000) NULL,
	[sp_id] [int] NOT NULL,
	[BackRank] [int] NULL,
	[content] [varchar](3000) NULL,
	[backsign] [int] Null
PRIMARY KEY CLUSTERED
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]

--@##mode:index;clustered:false;fields:OrderID
--@##mode:index;clustered:false;fields:inDate desc
--@##mode:index;clustered:false;fields:BackRank

GO
CREATE TABLE [dbo].[contractlist](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NULL,
	[num1] [decimal](25, 12) NOT NULL DEFAULT (0),
    [num2] [decimal](25, 12) NULL DEFAULT (0),
	[num3] [decimal](25, 12) NULL DEFAULT (0),
	[num4] [decimal](25, 12) NULL DEFAULT (0),
	[numth] [decimal](25, 12) NULL DEFAULT (0),
    [Kuout_Numth] [decimal](25, 12) NULL DEFAULT (0),
    [Y_Num1] [decimal](25, 12) NOT NULL DEFAULT (0), --原_数量列
    [AssistUnit] [int] NULL,
    [AssistNum] [decimal](25, 12) NULL,
    [pricejy] [decimal](25, 12) NOT null default (0),
    [tpricejy] [decimal](25, 12) NOT null default (0),
    [price1] [decimal](25, 12) NOT NULL DEFAULT (0),
    [discount] [decimal](25, 12) NULL DEFAULT 1, --折扣
	[priceAfterDiscount] [decimal](25, 12) NOT NULL default 0,--折后单价
    [moneyBeforeTax] [decimal](25, 12) NOT NULL default(0),--税前总额
	[invoiceType] int NULL default 0, --票据类型
	[taxRate] [decimal](25, 12) NULL default 0, --税率，数值来自票据类型设置表
    [priceIncludeTax] [decimal](25, 12) NOT NULL DEFAULT (0),--含税单价
    [PriceAfterTaxPre] [decimal](25, 12) NOT NULL default(0),
    [moneyAfterTax] [decimal](25, 12) NOT NULL default(0),--税后总额
	[concessions] [decimal](25, 12) NOT NULL default 0, --优惠金额
	[priceAfterTax] [decimal](25, 12) NOT NULL default(0),--优惠后单价
    [moneyAfterConcessions] [decimal](25, 12) NULL default(0), --金额
    [taxValue] [decimal](25, 12) NOT NULL DEFAULT(0),--税额
	[money1] [decimal](25, 12) NOT NULL DEFAULT (0), --优惠后总价
    [extras] [decimal](25, 12) NULL default 0, 
	[area] [int] NULL,
	[trade] [int] NULL,
	[cateid] [int] NULL,
	[cateid2] [int] NULL,
	[cateid3] [int] NULL,
	[addcate] [int] NULL,
	[contract] [int] NULL,
	[date1] [datetime] NULL,
	[date7] [datetime] NULL,
	[del] [int] NULL,
	[delcate] [int] NULL,
	[deldate] [datetime] NULL,
	[company] [int] NULL,
	[intro] [nvarchar](200) NULL,
	[bz] [int] NOT NULL DEFAULT (14),
	[del2] [int] NULL,
	[unit] [int] NOT null default (0),
	[commUnitAttr] [nvarchar](200) NULL,
	[date2] [datetime] NULL,
	[zdy1] [nvarchar](200) NULL,
	[zdy2] [nvarchar](200) NULL,
	[zdy3] [nvarchar](200) NULL,
	[zdy4] [nvarchar](200) NULL,
	[zdy5] [int] NULL,
	[zdy6] [int] NULL,
	[jf] [decimal](18, 8) NULL,
	[alt] [int] NULL,
	[fqhk] [int] NULL DEFAULT (0),
	[paybacktype] [int] NULL DEFAULT (0),
	[kuoutlist2] [int] NULL DEFAULT (0),
	[ck] [int] NULL,
	[num_tmp] [decimal](25, 12) NULL DEFAULT (0),
	[mxid] [int] NULL,
	[kujhlist] [int] NULL,
	[repairNewPartsId] int null, 
    [Pricelist] int null,
	[wxNum] [decimal](25, 12) NULL,
	[goodsId] [int],
	[treeOrd] [int] NULL,
    [rowindex] [int] null,
    [htmxid] [int] null,
	[ProductAttr1] int null,
	[ProductAttr2] int null,
	[ProductAttrBatchId] int null,
    [CKAccStatus] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


--@##mode:index;clustered:false;fields:contract,ord,id
--@##mode:index;clustered:false;fields:contract,del,id,ord,unit
--@##mode:index;clustered:false;fields:id,unit
--@##mode:index;clustered:false;fields:addcate,del
--@##mode:index;clustered:false;fields:unit,ord,addcate,cateid,date7 desc
--@##mode:index;clustered:false;fields:unit,ord,date7 desc
--@##mode:index;clustered:false;fields:company,date7 desc
--@##mode:index;clustered:false;fields:del;include:contract,num1,money1,num2,num3,num4,concessions,moneyBeforeTax,moneyAfterTax,taxValue
--@##mode:statistics;fields:contract,date7
--@##mode:statistics;fields:del,ord
--@##mode:statistics;fields:contract,id
--@##mode:statistics;fields:id,del,contract
--@##mode:statistics;fields:id,unit,contract
--@##mode:statistics;fields:contract,invoiceType,id
--@##mode:statistics;fields:contract,ord,id,unit
--@##mode:statistics;fields:id,date7,contract,del
--@##mode:statistics;fields:contract,ord,del,id,unit
--@##mode:statistics;fields:del,contract,invoiceType,id,date7

GO

CREATE TABLE [dbo].[M_CustomValues](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FieldsID] [int] NOT NULL,
	[OrderID] [int] NOT NULL,
	[FValue] [nvarchar](2000) NOT NULL,
	[ListID] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]

--@##mode:index;clustered:false;fields:FieldsID
--@##mode:index;clustered:false;fields:OrderID
--@##mode:index;clustered:false;fields:ListID

GO
CREATE TABLE [dbo].[hr_KQ_config](
	[id] [int] NOT NULL,
	[login_M] [int] NULL,
	[leave_M] [int] NULL,
	[overtime_M] [int] NULL,
	[work_H] [int] NULL,
	[login_Pat] [int] NULL,
	[overtime_to_int] [int] NULL,
	[companyType] [int] NULL,
	[hoDay_Ref] [int] NULL,
	[publicTest] [int] NULL,
	[startTime] [datetime] NULL,
	[endTime] [datetime] NULL,
	[creator] [int] NULL,
	[indate] [datetime] NULL,
	[del] [int] NULL,
	[status] [int] NOT NULL,
	[workHour] [int] NULL
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[home_toolbar_comm](
	[id] [int] NOT NULL,
	[title] [varchar](50) NOT NULL,
	[url] [varchar](200) NOT NULL,
	[target] [varchar](50) NOT NULL,
	[img] [varchar](50) NOT NULL,
	[qxlb] [int] NOT NULL,
	[qxlblist] [int] NOT NULL,
	[sortnum] [int] NOT NULL,
	[msgNumUrl] [varchar](200) NULL,
    [models] [bigint] NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[sortgl](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NULL,
	[sort1] [nvarchar](50) NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[contractth](
	[ord] [int] IDENTITY(1,1) NOT NULL,
	[title] [nvarchar](100) NULL,
	[thid] [nvarchar](50) NULL,
	[money1] [decimal](25, 12) NULL,
	[money2] [decimal](25, 12) NULL,
	[bz] [int] NULL DEFAULT (0),
	[sort] [int] NULL,
	[complete1] [int] NULL,
	[date3] [datetime] NULL,
	[area] [int] NULL,
	[trade] [int] NULL,
	[intro] [ntext] NULL,
	[company] [int] NULL,
	[contract] [int] NULL,
	[cateid] [int] NULL,
	[cateid2] [int] NULL,
	[cateid3] [int] NULL,
	[addcate] [int] NULL,
	[addcate2] [int] NULL,
	[addcate3] [int] NULL,
	[date7] [datetime] NULL,
	[del] [int] NULL,
	[delcate] [int] NULL,
	[deldate] [datetime] NULL,
	[zt1] [int] NULL DEFAULT (0),
	[cateid_sp] [int] NULL,
	[sp] [int] NULL,
	[zdy1] [nvarchar](50) NULL,
	[zdy2] [nvarchar](50) NULL,
	[zdy3] [nvarchar](50) NULL,
	[zdy4] [nvarchar](50) NULL,
	[zdy5] [int] NULL,
	[zdy6] [int] NULL,
	[del2] [int] NULL,
	[thType] [varchar](20) NULL,
	[alt] [int] NULL,
	[BKPayModel] [int] null,
    PRIMARY KEY CLUSTERED
    (
        [ord] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]
 TEXTIMAGE_ON [PRIMARY]

--@##mode:index;clustered:false;fields:ord,del,sp
--@##mode:index;clustered:false;fields:del,sp

GO
CREATE TABLE [dbo].[M_FlowDefault](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[PrefixCode] [nvarchar](2) NOT NULL,
	[sp_id] [int] NOT NULL,
	[cateid] [int] NOT NULL,
	[DefaultID] [int] NOT NULL,
PRIMARY KEY CLUSTERED
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]

--@##mode:index;clustered:false;fields:cateid
--@##mode:index;clustered:false;fields:DefaultID

GO

CREATE TABLE [dbo].[bank_ysk_changelog] (
	[id] [int] IDENTITY (1, 1) NOT NULL ,
	[sort1] [int] NULL ,
	[sort1name] [nvarchar] (50) COLLATE Chinese_PRC_CI_AS NULL ,
	[money_last] [decimal](25, 12) NULL ,
	[money1] [decimal](25, 12) NULL ,
	[money_new] [decimal](25, 12) NULL ,
	[bz] [int] NULL ,
	[company] [int] NULL ,
	[yskid] [int] NULL ,
	[date7] [datetime] NULL ,
	[addcate] [int] NULL ,
	[addcatename] [nvarchar] (50) COLLATE Chinese_PRC_CI_AS NULL ,
	[ip] [nvarchar] (50) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]

GO

--新增供应商预付款日志记录
CREATE TABLE [dbo].[bank_yfk_changelog] (
	[id] [int] IDENTITY (1, 1) NOT NULL ,
	[sort1] [int] NULL ,
	[sort1name] [nvarchar] (50) COLLATE Chinese_PRC_CI_AS NULL ,
	[money_last] [decimal](25, 12) NULL ,
	[money1] [decimal](25, 12) NULL ,
	[money_new] [decimal](25, 12) NULL ,
	[bz] [int] NULL ,
	[company] [int] NULL ,
	[yskid] [int] NULL ,
	[date7] [datetime] NULL ,
	[addcate] [int] NULL ,
	[addcatename] [nvarchar] (50) COLLATE Chinese_PRC_CI_AS NULL ,
	[ip] [nvarchar] (50) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]

GO

--左侧导航子节点包含关系表
CREATE TABLE [dbo].[home_leftMenu_TmpNode](
	[ID] [int] NOT NULL,
	[ParentID] [int] NOT NULL,
	[itemName] [varchar](500) COLLATE Chinese_PRC_CI_AS NULL,
	[ItemSort] [int] NULL,
	[url] [varchar](1000) COLLATE Chinese_PRC_CI_AS NULL,
	[deep] [int] NULL,
	[imgurl] [varchar](100) COLLATE Chinese_PRC_CI_AS NULL,
	[ModelExpress] [varchar](500) COLLATE Chinese_PRC_CI_AS NULL,
	[tag1] [varchar](200) COLLATE Chinese_PRC_CI_AS NULL,
	[tag2] [varchar](1000) COLLATE Chinese_PRC_CI_AS NULL,
	[leef] [int] NOT NULL,
	[fw] [int] NOT NULL,
	[xlh] [int] NOT NULL,
	[uid] [int] NOT NULL,
	[code] [varchar](1000) COLLATE Chinese_PRC_CI_AS NOT NULL,
PRIMARY KEY CLUSTERED
(
	[ID] ASC,
	[ParentID] ASC,
	[leef] ASC,
	[fw] ASC,
	[xlh] ASC,
	[uid] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[home_leftMenu_TmpForUser](
	[ord] [int] NOT NULL,
	[menuCls] [int] NOT NULL,
	[html] [text] COLLATE Chinese_PRC_CI_AS NULL,
PRIMARY KEY CLUSTERED
(
	[ord] ASC,
	[menuCls] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

Create Table [dbo].[PJLY_InfoList](
[ID] [int] PRIMARY KEY identity(1,1),
[Sord] [int],
[Pord] [int],
[InsertTime] [Datetime] Default GetDate(),
[OriginalMoney] [decimal](25, 12),
[InsertMoney] [decimal](25, 12),
[OuntMoney] [decimal](25, 12),
[GateId] [int],
[InsertType] [Int],
[Del] [Int]
)

GO

Create Table [dbo].[PJLY_Log](
[ID] [int] PRIMARY KEY identity(1,1),
[Sord] [int],
[InsertTime] [Datetime] Default GetDate(),
[OriginalMoney] [decimal](25, 12),
[InsertMoney] [decimal](25, 12),
[GateId] [int],
[InsertType] [Int],
[IP] [varchar](145)
)

GO

CREATE TABLE [dbo].[sys_bill_TarSet](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[depid] [int] NULL,
	[groupid] [int] NULL,
	[preid] [int] NULL,
	[prename] [varchar](50) COLLATE Chinese_PRC_CI_AS NULL,
	[years] [int] NULL,
	[sellType] [int] NULL,
	[m1] [float] NULL,
	[m2] [float] NULL,
	[m3] [float] NULL,
	[m4] [float] NULL,
	[m5] [float] NULL,
	[m6] [float] NULL,
	[m7] [float] NULL,
	[m8] [float] NULL,
	[m9] [float] NULL,
	[m10] [float] NULL,
	[m11] [float] NULL,
	[m12] [float] NULL,
	[uid] [int] NULL,
	[uptime] [datetime] NULL,
	[indate] [datetime] NULL,
    PRIMARY KEY CLUSTERED
    (
        [ID] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

--高级检索字段配置表
CREATE TABLE [dbo].[home_report_searchField](
	[ID] [int] NOT NULL,
	[rptName] [varchar](50) COLLATE Chinese_PRC_CI_AS NULL,
	[fieldName] [varchar](50) COLLATE Chinese_PRC_CI_AS NULL,
	[ftype] [varchar](5) COLLATE Chinese_PRC_CI_AS NULL,
	[defvalue1] [varchar](50) COLLATE Chinese_PRC_CI_AS NULL,
	[defvalue2] [varchar](50) COLLATE Chinese_PRC_CI_AS NULL,
	[gate2] [int] NULL,
	[dbName1] [varchar](50) COLLATE Chinese_PRC_CI_AS NULL,
	[dbname2] [varchar](50) COLLATE Chinese_PRC_CI_AS NULL,
PRIMARY KEY CLUSTERED
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO

--文件数据表--
CREATE TABLE [dbo].[erp_filedatas](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[title] [nvarchar](50) COLLATE Chinese_PRC_CI_AS NULL,
	[data] [image] NULL,
	[type] [varchar](50) COLLATE Chinese_PRC_CI_AS NULL,
	[used] [bit] NOT NULL DEFAULT (0),
	[folder] [nvarchar](100) COLLATE Chinese_PRC_CI_AS NULL,
	[date] [datetime] NULL,
	[us] [int] NULL,
	[pw] [varchar](50) COLLATE Chinese_PRC_CI_AS NULL,
 PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

--Attrs:帐套下可用
CREATE TABLE [dbo].[erp_sys_LvwConfig](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[uid] [int] not NULL,
	[lvwid] [char](16) not NULL,
	[width] [int] null,
	[pagesize] [int] null,
	PRIMARY KEY CLUSTERED
	(
		[uid] ASC,
		[lvwid] asc
	) ON [PRIMARY]
) ON [PRIMARY]

GO

--Attrs:帐套下可用
CREATE TABLE [dbo].[erp_sys_LeftPageConfig](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[uid] [int] not NULL,
	[LeftBoxID] [char](16) not NULL,
	[LeftTabIndex] [int] not NULL,
	[defSearchDBNames] [varchar](50) null,
	PRIMARY KEY CLUSTERED
	(
		[uid] ASC,
		[LeftBoxID] asc
	) ON [PRIMARY]
) ON [PRIMARY]

GO

--Attrs:帐套下可用
CREATE TABLE [dbo].[erp_sys_LvwColConfig](
	[cfgid] [int] NOT NULL,
	[dbname] [varchar](60) not NULL,
	[dbindex]  [int] NULL,
	[newdbindex]  [int] NULL,
	[colindex] [int] NULL,
	[title] [nvarchar](100) NULL,
	[sort] [int] NULL,
	[width] [int] NULL,
	[visible] [bit] NULL,
	[formula] [varchar](100) NULL,
	[evalname] [varchar](100) NULL,
	 PRIMARY KEY CLUSTERED
	(
		[cfgid] asc,
		[dbname] asc
	) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[sys_billfieldconfig](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[OrderID] [int] NOT NULL,
	[OrderlistID] [int] NOT NULL,
	[fieldName] [varchar](200) NOT NULL,
	[fieldtype] [int] NULL,
	[fieldemun] [int] NULL,
	[IsDel] [int] NULL,
	[IsSearch] [int] NULL,
	[IsExport] [int] NULL,
	[IsRequired] [int] NULL,
	[sort1] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
--Attrs:帐套下可用
CREATE TABLE [dbo].[sys_billfieldsdata](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[fieldid] [int] NULL,
	[BillID] [int] NULL,
	[BillListID] [int] NULL,
	[value] [nvarchar](200) NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[zjds] (
	[id] [int] IDENTITY (1, 1) NOT NULL ,
	[itemId] [int] NULL ,
	[userId] [int] NULL ,
	[addTime] [datetime] NOT NULL ,
	[addUser] [int] NULL ,
	[dsMoney] [decimal](25, 12) NULL ,
	[dsYs] [text] COLLATE Chinese_PRC_CI_AS NULL ,
	[dsLs] [text] COLLATE Chinese_PRC_CI_AS NULL ,
	[intro] [text] COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

CREATE TABLE [dbo].[home_mainlink_config](
	[id] [int] NOT NULL,
	[role] [int] NOT NULL,
	[uid] [int] NOT NULL,
	[title] [nvarchar](100) NULL,
	[url] [varchar](500) NULL,
	[otype] [int] NULL,
	[icodata] [image] NULL,
	[icosize] [int] NULL,
	[icotype] [varchar](50) NULL,
	[icoId] [int] NULL,
	[icourl] [varchar](500) NULL,
	[sort] [int] NULL,
	[gpname] [nvarchar](20) NULL,
	[del] [int] NULL,
	[intro] [nvarchar](500) NULL,
	[powerCode] [varchar](500) NULL,
	 PRIMARY KEY CLUSTERED
	(
		[id] ASC,
		[role] ASC,
		[uid] ASC
	) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[home_mainlinkcls_config](
	[gpName] [nvarchar](20) NULL,
	[uid] [int] NULL,
	[del] [int] NULL,
	[sort] [int] NULL,
	[intro] [nvarchar](500) NULL,
	[agpname] [nvarchar](20) NULL
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[erp_sys_SqlLockLog](
	[i] [int] NOT NULL IDENTITY (1, 1),
	[signName] [nvarchar](50) NULL,
	[url] [varchar](300) NULL,
	[dbName] [varchar](50) NULL,
	[sql] [nvarchar](255) NULL,
	[itime] [datetime] NULL,
	[uid] [int] NULL
)  ON [PRIMARY]

GO
--付款收票表--
CREATE TABLE [dbo].[PayInvoice](
	ord int NOT NULL IDENTITY (1, 1),
	tik int null,			
	tikname nvarchar(100),	
	money1 [decimal](25, 12) null,		
	IsUsePJLY int null,	
	date3 datetime null,	
	date7 datetime NULL,	
	del int null,			
	addcate int,			
    instro text,             
	date1 datetime null,   
    zt int not null default(1)                
)

--@##mode:index;clustered:true;fields:ord
--@##mode:index;clustered:false;fields:date3

Go
--付款收票明细表--
CREATE TABLE [dbo].[PayInvoiceList](
	ord int NOT NULL IDENTITY (1, 1),
	PayInvoice int null,	--关联付款收票主表
	money1 [decimal](25, 12) null,		--关联付款的收票金额
	payout int null,		--关联付款单的ord
    del int null,			--删除状态 1=正常 2=删除
	cls int null,			--付款类型 0.采购付款 2.委外付款
    sourceID int null,     --付款来源单据  类似 payout.contract, 关联采购单或者委外单，根据cls的不同，关联的表不同
    dk int not null default(0),               --0非抵扣， 1=抵扣开票
    zt int not null default(1),               --1收票，0待收票状态
    date1 datetime null     --应收日期
)

--@##mode:index;clustered:false;fields:payout

GO

--加密狗序列号表--
CREATE TABLE [dbo].[jmgouList](
	id int NOT NULL IDENTITY (1, 1),
	jmgtitle nvarchar(100),	--加密狗名称
	jmgxlh nvarchar(50),	--加密狗序列号
	jmgpwd nvarchar(50),	--加密狗登陆密码
	isuse int null,			--加密狗是否使用(被分配)
	cateid int null,		--使用人
	addcate int null,		--分配人
	date7 datetime NULL		--分配时间
)

GO

--生产打印页面布局配置--
CREATE TABLE [dbo].[M_printerFx](
	[uid] [int] NULL,
	[oid] [int] NULL,
	[fx] [int] NULL
)

--@##mode:index;clustered:true;fields:uid,oid

GO

--农历公历对应表
CREATE TABLE [dbo].[nldata](
	[yl] [datetime] NOT NULL,
	[ny] [int] NULL,
	[nm] [int] NULL,
	[nd] [int] NULL,
	[AutoI] [int] NULL,
	[AutoT2] [dateTime] NULL
 PRIMARY KEY CLUSTERED
(
	[yl] ASC
 ) ON [PRIMARY]
) ON [PRIMARY]
--@##mode:index;clustered:false;fields:AutoI
--@##mode:index;clustered:false;fields:AutoT2
GO

--数据备份记录表
CREATE TABLE [dbo].[db_bak] (
	[id] [int] IDENTITY (1, 1) NOT NULL ,
	[dbname] [nvarchar] (500) COLLATE Chinese_PRC_CI_AS NULL ,
    [batchno]  [varchar](20) NULL,
	[bktype] [int] NULL ,
	[bkpath] [nvarchar] (2000) COLLATE Chinese_PRC_CI_AS NULL ,
    [bksize] [decimal](25, 12) null,	
    [bkdbtype] [int] NULL ,
    [BkSucess] [int] NULL ,
    [Backup_set_id] [int] NULL ,
	[date7] [datetime] NULL ,
	[cateid] [int] NULL ,
	[catename] [nvarchar] (50) COLLATE Chinese_PRC_CI_AS NULL ,
	[name] [nvarchar] (50) COLLATE Chinese_PRC_CI_AS NULL ,
	[ip] [nvarchar] (200) COLLATE Chinese_PRC_CI_AS NULL 
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[Mob_MacLoginState](
	[macsn] [varchar](50) NOT NULL default(''),
	[failcount] [int] NOT NULL default(0),
	[rndcode] [varchar](50) NOT NULL default(''),
	 PRIMARY KEY CLUSTERED
	(
		[macsn] ASC
	 ) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[Mob_UserMacMap](
	[macsn] [varchar](50) NOT NULL default(''),
	[phone] [varchar](50) NULL,
	[btype] [int] not null default(0),
	[userid] [int] NOT NULL default(0),
	[id] [int] IDENTITY(1,1) NOT NULL,
	[del] [int] NOT NULL default(0),
	[useBind] [bit] NULL,
	[addcate] [int] NULL,
	[date1] [datetime] NULL,
	[date7] [datetime] NULL,
	[MobileModel] [varchar](100),
	[AppVersion] [varchar](50),
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

--数据修复主表
CREATE TABLE [dbo].[repairs] (
	[id] [int] IDENTITY (1, 1) NOT NULL ,
	[tbname] [nvarchar] (200) COLLATE Chinese_PRC_CI_AS NULL ,
	[cateid] [int] NULL ,
	[catename] [nvarchar] (50) COLLATE Chinese_PRC_CI_AS NULL ,
	[name] [nvarchar] (50) COLLATE Chinese_PRC_CI_AS NULL ,
	[moduleid] [int] NULL ,
	[ckdatas] [int] NULL ,
	[errdatas] [int] NULL ,
	[bkfile] [nvarchar] (1000) COLLATE Chinese_PRC_CI_AS NULL ,
	[date7] [datetime] NULL ,
	[ip] [nvarchar] (200) COLLATE Chinese_PRC_CI_AS NULL ,
	[del] [int] NULL 
) ON [PRIMARY]

GO

--数据修复明细表
CREATE TABLE [dbo].[repairs_list] (
	[id] [int] IDENTITY (1, 1) NOT NULL ,
	[moduleid] [int] NULL ,
	[errtype] [nvarchar] (200) COLLATE Chinese_PRC_CI_AS NULL ,
	[repairs] [int] NULL ,
	[tbname] [nvarchar] (200) COLLATE Chinese_PRC_CI_AS NULL ,
	[tbord] [int] NULL ,
	[tbcolm] [nvarchar] (100) COLLATE Chinese_PRC_CI_AS NULL ,
	[tbcolm2] [nvarchar] (100) COLLATE Chinese_PRC_CI_AS NULL ,
	[beforevalue] [nvarchar] (2000) COLLATE Chinese_PRC_CI_AS NULL ,
	[aftervalue] [nvarchar] (2000) COLLATE Chinese_PRC_CI_AS NULL ,
	[del] [int] NULL 
) ON [PRIMARY]

GO

--客户字段自定义
CREATE TABLE [dbo].[setfields] (
	[id] [int] IDENTITY (1, 1) NOT NULL ,
	[oldName] [nvarchar] (50) NULL , 
	[Name] [nvarchar] (50) NULL ,
	[type] [int]  NULL ,
	[show] [int]  NULL ,
	[point] [int]  NULL ,
	[enter] [int]  NULL ,
	[Required] [int]  NULL ,
	[format] [nvarchar](100)  NULL ,
	[sort2] [int]  NULL ,
	[sort] [int]  NULL ,
	[fieldName] [nvarchar] (50) NULL ,
	[gate1] [int]  NULL ,
	[isget] [int]  NULL ,
	[extra] [nvarchar] (200),
	[del] [int] NULL,
	[order1] [int] NULL
) ON [PRIMARY]

GO

--客户审核策略
CREATE TABLE [dbo].[tel_review] (
	[id] [int] IDENTITY (1, 1) NOT NULL ,
	[sort] [int] NULL , 
	[title] [nvarchar] (100) NULL ,
	[condition] [int]  NULL ,
	[limitsort1] [varchar](300) null,  --limitsort1=1:客户分类，sort4.id（集合);
	[limitsort2] [varchar](300) null,  --limitsort1=2:客户跟进程度，sort5.id（集合);
	[limitsort3] [varchar](300) null,  --客户来源；sortonehy.id where gate2=13(集合);
	[limitsort4] [varchar](300) null,  --客户价值；sortonehy.id where gate2=14(集合);
	[limitsort5] [varchar](300) null,  --客户行业；sortonehy.id where gate2=11(集合);
	[limitsort6] [varchar](300) null,  --客户区域；menuarea.id(集合) ;
	[limitsort7] [varchar](300) null,  --客户自定义5  sortonehy.ord(集合)
	[limitsort8] [varchar](300) null,  --客户自定义6  sortonehy.ord(集合)
	[limitsort9] [varchar](300) null,  
	[del] [int] NULL 
) ON [PRIMARY]

GO

--客户区域各类
CREATE TABLE [dbo].[tel_area] (
	[id] [int] IDENTITY (1, 1) NOT NULL ,
	[sort] [int] NULL ,				--分类 (审核1,策略2...)
	[ord] [int] NULL ,				--根据分类单据ID
	[area] [int] NULL ,
	[intro] [nvarchar] NULL ,		--备用字段扩展用
	[del] [int] NULL 
) ON [PRIMARY]

GO

--联系人角色表
CREATE TABLE [dbo].[sort9](  --联系人角色
	[ord] [int] identity(1,1) not Null,
	[sort1] [nvarchar](500) null,  --角色名
	[intro] [nvarchar](500) null,  --备注
	[gate2] [int] null		--重要程度
)

GO

--客户领用范围设置表
create table [dbo].[tel_apply](
	[id] [int] identity(1,1) not null,
	[cateid] [int] null,  --0表示单一设置，其他为gate.cateid
	[condition] [int] default(0) null, --审核条件 0:或 1：并且
	[limitsort1] [varchar](300) null,  --limitsort1=1:客户分类，sort4.id（集合);
	[limitsort2] [varchar](2000) null,  --limitsort1=2:客户跟进程度，sort5.id（集合);
	[limitsort3] [varchar](300) null,  --客户来源；sortonehy.id where gate2=13(集合);
	[limitsort4] [varchar](300) null,  --客户价值；sortonehy.id where gate2=14(集合);
	[limitsort5] [varchar](300) null,  --客户行业；sortonehy.id where gate2=11(集合);
	[limitsort6] [varchar](300) null,  --客户区域；menuarea.id(集合) ;
	[limitsort7] [varchar](300) null,  --客户自定义5  sortonehy.ord(集合)
	[limitsort8] [varchar](300) null,  --客户自定义6  sortonehy.ord(集合)
	[limitsort9] [varchar](1000) null,  
	[del] [int] null,  --1表示正常策略，7表示模板策略
	PRIMARY KEY CLUSTERED
	(
		[id] ASC
	) ON [PRIMARY]
) ON [PRIMARY]

GO

---销售人员变更表
CREATE TABLE [dbo].[tel_sales_change_log](
  [id] [int] IDENTITY (1, 1) NOT NULL ,  --自增ID
  [tord] [int] Null,  --客户ord
  [sort3] [int] Null, --客户类别
  [sort] [int] Null, --客户分类
  [sort1] [int] Null, --客户跟进程度
  [precateid] [int] Null, --之前的销售人员
  [newcateid] [int] Null, --新销售人员
  [cateid] [int] Null, --操作人员
  [date2] [datetime] null, --客户领用开始时间
  [date7] [datetime] Null,   --变更时间点
  [reason] [int] Null,  --变更原因,1:添加; 2:导入 3:指派 4:收回 5:领用 6:放弃
  [reasonchildren] [int] Null, --变更原因子类别：
  [replynum] [int] Null, --跟进总次数
  [intro] [nvarchar](3000) Null  --备注
) ON [PRIMARY]
 
GO
 
--客户节点变更记录表
CREATE TABLE [dbo].[tel_sort_change_log](
  [id] [int] identity(1,1) not null,
  [tord] [int] Null,  --客户ord
  [sort3] [int] Null,  --客户类别
  [preSort] [int] Null,  --原类别
  [preSort1] [int] Null,  --原跟进程度
  [newSort] [int] Null,  --现类别
  [newSort1] [int] Null,  --现跟进程度
  [cateid] [int] Null,  --销售人员
  [cateid2] [int] Null, --部门
  [cateid3] [int] null, --小组
  [reason] [int] Null,  --状态,变更原因,0:系统变更; 1:客户修改; 2联系人修改; 3:洽谈进展;
  [reasonid] [int] Null, --关联状态类型ord,如洽谈进展reply.id
  [intro] [nvarchar](3000) Null, --备注说明
  [state] [int] null,  --1:前进，-1：后退,0:原地
  [perdays] [int] null, --阶段间隔天数（此为存方案，可不用，以上一节点时间段计算）
  [cateadd] [int] null, --操作人员
  [date2] [datetime] null, --本次客户领用开始时间
  [date7] [datetime] null  --本次新节点开始时间点
) ON [PRIMARY]

--@##mode:index;clustered:false;fields:tord desc
--@##mode:index;clustered:false;fields:id asc

GO
--客户视图设置表
create table [dbo].[tel_view](
	[id] [int] identity(1,1) not null,
	[title] [varchar](50) null,--视图名称
	[enable] [int] null,  --是否启用
	[isperson] [int] null, --是否检索人员
	[sort] [nvarchar](100) null,
	[sort1] [nvarchar](200) null,
	[ly] [nvarchar] (100) null,
	[jz] [nvarchar] (100) null,
	[area] [int] null ,
	[trade] [nvarchar](100) null,
	[nameType] [int] null,
	[name] [nvarchar](100) null,
	[pymType] [int] null,
	[pym] [nvarchar](100) null,
	[khidType] [int] null,
	[khid] [nvarchar](100) null,
	[phoneType] [int] null,
	[phone] [nvarchar](20) null,
	[faxType] [int] null,
	[fax] [nvarchar](20) null,
	[mobileType] [int] null,
	[mobile] [nvarchar](20) null,
	[qqType] [int] null,
	[qq] [nvarchar](20) null,
	[emailType] [int] null,
	[email] [nvarchar](20) null,
	[urlType] [int] null,
	[url] [nvarchar](100) null,
	[addressType] [int] null,
	[address] [nvarchar](500) null,
	[zipType] [int] null,
	[zip] [nvarchar](20) null,
	[introType] [int] null,
	[intro] [nvarchar](100) null,
	[time1] [datetime] null,
	[time2] [datetime] null,
	[zdy1Type] [int] null,
	[zdy1] [nvarchar](100) null,
	[zdy2Type] [int] null,
	[zdy2] [nvarchar](100) null,
	[zdy3Type] [int] null,
	[zdy3] [nvarchar](100) null,
	[zdy4Type] [int] null,
	[zdy4] [nvarchar](100) null,
	[zdy5] [nvarchar](100) null,
	[zdy6] [nvarchar](100) null,
	[kzzdy] [nvarchar](1000) null,
	[px] [int] null,  --排序
	[rows] [int] null, --默认行数
	[gate1] [int] null, --重要指数
	[cateid] [int] null,  --所属人员
	[date7] [datetime] null,--添加时间
	[del] [int] null,  --1表示正常
	PRIMARY KEY CLUSTERED
	(
		[id] ASC
	) ON [PRIMARY]
) ON [PRIMARY]

GO

create table [dbo].[tel_view_setfields](
	[id] [int] identity(1,1) not null,
	[ord] [varchar](50) null,--视图ord
	[intgate] [int] null,  --字段设置gate1
	[show] [int] null, --是否显示
	[intwidth] [int] null, --列宽px
	[gate1] [int] null,    --排序
	[block] [int] null, --是否锁定
	[sort] [int] null , --备用字段 视图1
	[del] [nvarchar] (100) null,
	PRIMARY KEY CLUSTERED
	(
		[id] ASC
	) ON [PRIMARY]
) ON [PRIMARY]

GO

create table [dbo].[tel_view_person](
[id] [int] identity(1,1) not null,
[ord] [varchar](50) null,--视图ord
[person_tpye] [int] null,  --人员类别
[w1] [nvarchar](200) null,
[w2] [nvarchar](500) null,
[w3] [nvarchar](2000) null,
[sort] [int] null , --备用字段 视图1
[del] [nvarchar] (100) null,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO

--客户竞争对手
CREATE TABLE [dbo].[tel_zjds] (
	[id] [int] IDENTITY (1, 1) NOT NULL ,
	[itemId] [int] NULL ,
	[userId] [int] NULL ,
	[addTime] [datetime] NOT NULL ,
	[addUser] [int] NULL ,
	[dsMoney] [decimal](25, 12) NULL ,
	[jzcp] [nvarchar] (500) NULL ,
	[dsYs] [text] COLLATE Chinese_PRC_CI_AS NULL ,
	[dsLs] [text] COLLATE Chinese_PRC_CI_AS NULL ,
	[intro] [text] COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

--跟进程度修改记录
CREATE TABLE [dbo].[sort5_his](
	[id] [int] NULL,
	[ord] [int] NULL,
	[sort1] [int] NULL,
	[sort2] [nvarchar](50) NULL,
	[gate2] [int] NULL,  --预先需针对相同的gate2进行重新排序
	[time1] [int] NULL DEFAULT (0),
	[time2] [int] NULL DEFAULT (0),
	[num1] [int] NULL DEFAULT (0),
	[jf] [decimal](25, 12) NULL,
	[mustHas] [int] Null, --是否必经，1：必经
	[AutoNext] [int] Null, --自动进入本阶段，1：是
	[mustContentType] [int] Null,  --必填内容范围,1:本阶段及以前(按gate2排)
	[mustContent] [nvarchar](500) Null, 
	[mustRole] [nvarchar](500) Null,  --角色
	[mustzdy] [nvarchar](500) Null,  --自定义1-6
	[mustkz_zdy] [nvarchar](500) Null,  --扩展自定义
	[perSuccess] [int] Null, --到本阶段时的成功概率(成功概率)
	[unautoback] [int] Null,  --回收例外开关 1:启用
	[unback] [int] Null, --禁止回收本类 1:是，默认否
	[protect] [int] Null, --保护本类客户 1：是，默认否
	[isProtect] [int] Null,
	[unreplyback1] [int] Null, --领用未联系收回 1:启用,2:单一期限，3：不同人员设置不同期限 --策略接收老数据处理
	[unreplyback2] [int] Null,  --间隔未联系收回,1:启用,2:单一期限，3:不同人员设置不同期限 --策略接收老数据处理
	[unsalesback] [int] Null,  --多久未成功则收回	1:启用,2:单一期限，3:不同人员设置不同期限 --策略接收老数据处理
	[stayback] [int] Null, --本阶段停留超长收回 1:启用
	[staydays] [int] Null, --本阶段最长停留时间
	[maxback] [int] Null,  --超最大跟进天数收回(限定最长跟进时间) 1:启用
	[maxbackdays] [int] Null, --最长跟进天数
	[canRemind] [int] Null,  --是否提醒
	[Reminddays] [int] Null,  --提前天数
	[cateid] [int] Null, --添加人
	[del7] [datetime] Null,
	[del] [int] Null,
	[op] [int] null,  --修改人
	[ip] [nvarchar](50) null, --修改人IP
	[opdate] [datetime] null  --修改时间
) ON [PRIMARY]

GO

--要事提醒表
CREATE TABLE [dbo].[importantMsg](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[title] [nvarchar](1000) null,
	[content] [nvarchar](2000) null, --要事内容
	[stime] [datetime] null,
	[etime] [datetime] null,
	[gate2] [int] null,  --重要级别
	[metype] [int] null,  --待邮，待联,待查等类别 sort10.ord
	[cateid] [int] null,  --指派人(添加人员)
	[ecateid] [int] null, --执行人
	[t_ord] [int] null, --客户ord
	[t_person] [int] null, --联系人ord
	[state] [int] null, --要事状态，是否完成
	[date7] [datetime] null,  --添加时间
	[del] [int] null
)

GO

--要事提醒分类
CREATE TABLE [dbo].[sort10](  --要事分类
	[id] [int] identity(1,1) not Null,
	[ord] [int] null,
	[sort1] [nvarchar](500) null,  --要事名
	[intro] [nvarchar](500) null,  --备注
	[gate2] [int] null,		--重要程度
	[del] [int] null --1:正常，2:删除，3:保留
)

GO

--洽谈进展附件存储表
create table [dbo].[reply_file_Access](
    [ord] [int] IDENTITY(1,1) NOT NULL,
    [t_ord] [int] null,
    [sort] [int] null,  --1:洽谈进展
    [sortid] [int] null, --sort=1 sortid=reply.id,暂不用，将reply_file_Access.ord存入reply.uploadfile
    [Access_url] [nvarchar](100) null,
    [Access_size] [nvarchar] (50) null,
    [del] [int] null,
    [oldname] [nvarchar](200) null,
    [fileDes] [nvarchar](500) null,
    [creator] [int] null,
    [date7] [datetime] null
PRIMARY KEY CLUSTERED
(
	[ord] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO

--销售工作台设置
create table [dbo].[salecenter](
	[id] [int] identity(1,1) not null,
	[ord] [int] null,
	[reportday] [int] null, 
	[reportweek] [int] null, 
	[reportmonth] [int] null,
	[report1] [varchar](100) null,
	[report2] [varchar](100) null,
	[report3] [varchar](100) null, --前3个用于销售工作台
	[report4] [varchar](100) null,
	[report5] [varchar](100) null,
	[report6] [varchar](100) null,
	[report7] [varchar](100) null,
	[report8] [varchar](100) null,
	[report9] [varchar](100) null,
	[report10] [varchar](100) null,
	[del] [int] null
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO

--用户自定义报表-----
CREATE TABLE [dbo].[erp_sales_ReportItems](
	[id] [int] NOT NULL,
	[title] [nvarchar](20) NOT NULL,
	[fromID] [int] NOT NULL,
	[basefromID] [int] NOT NULL,
	[MenuID] int NOT NULL,
	[PageRowCount] [int] NOT NULL,
	[canPrint] [bit] NOT NULL,
	[canExcel] [bit] NOT NULL,
	[ColKey] [varchar](500) NULL,
	[coltype] [varchar](50) NOT NULL,
	[colsort] [nvarchar](50) NOT NULL,
	[coldata] [ntext] NULL,
	[RowKey] [varchar](500) NULL,
	[rowtype] [varchar](50) NOT NULL,
	[rowsort] [nvarchar](50) NOT NULL,
	[rowdata] [ntext] NULL,
	[Sql] [ntext] NULL,
	[date7] [datetime] NULL,
	[del] [int]  NOT NULL,
	[addcate] [int]  NOT NULL,
	[gate1] [int] NOT NULL,	
	[cansearch] [varchar](500) NULL,
	[canadsearch] [varchar](500) NULL,
 PRIMARY KEY
 (
	[id] ASC
  )
) ON [PRIMARY]


GO

--报表的基本字段----
create table [dbo].[erp_sales_ReportFields](
	[ID] [int] NOT NULL,
	[ReportId] [int] NOT NULL,
	[ftype] [varchar](10) NOT NULL,
	[fname] [nvarchar](50) NOT NULL,
	[fkey] [varchar](50) NOT NULL,
	[canx] [bit] NOT NULL,
	[cany] [bit] NOT NULL,
	[cansearch] [bit] NOT NULL,
	[canadsearch] [bit] NOT NULL,
	[convertSql] [nvarchar](500) NOT NULL,
	[SortConfig] [varchar](500) NOT NULL,
	[datasSql] [nvarchar](500) NULL,
	[clsfkey] [varchar](50) NOT NULL,
	[SearchSort] [int] NULL,
	primary key clustered 
	(
		[ReportId] ASC,
		[fkey] ASC
	)
) on [primary]

GO

---系统自带报表---
CREATE TABLE [dbo].[erp_sales_ReportItems_def](
	[id] [int] NOT NULL,
	[title] [nvarchar](20) NOT NULL,
	[PageRowCount] [int] NOT NULL,
	[canPrint] [bit] NOT NULL,
	[canExcel] [bit] NOT NULL,
	[baseSql] [ntext] NULL,	
	[colkey] [varchar](500) NULL,
	[rowkey] [varchar](500) NULL,
	[Sql] [ntext] NULL,
	[gate1] [int] NOT NULL,	
	[cansearch] [varchar](500) NULL,
	[canadsearch] [varchar](500) NULL,
	[coldata] varchar(500) NULL,
	[coltype] varchar(50) NULL,
	[colsort] varchar(50) NULL,
	[rowdata] varchar(500) NULL,
	[rowtype] varchar(50) NULL,
	[rowsort] varchar(50) NULL
 PRIMARY KEY
 (
	[id] ASC
  )
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[sort11](
	[id] [int] identity(1,1) not Null,
	[sort1] [nvarchar](500) null,  --主题
	[intro] [nvarchar](500) null,  --备注
	[gate2] [int] null,		--天数
	[del] [int] null --1:正常，2:删除，3:保留
)

GO
--客户回收例外策略标记
CREATE TABLE [dbo].[ExcepStrategies](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[gdate] [datetime] NULL
 PRIMARY KEY
 (
	[id] ASC
  )
) ON [PRIMARY]
GO

---质检单主表
CREATE TABLE [dbo].[caigouQC] (
	[id] [int]  IDENTITY (1, 1) NOT NULL,
	[title] [nvarchar](100) NOT NULL,
	[qcid] [varchar](50) NULL,
	[company] [int] NOT NULL,
	[caigou] [int] NOT NULL,
	[caigoulist] [int] NOT NULL,
	[Complete] [int] Not NULL,
	[productid] [int] NOT NULL,	
	[unit] [int] NOT NULL,
	[cgnum] [decimal](25, 12) NULL,	
	[recnum] [decimal](25, 12) NULL,	
	[yjnum_tmp] [decimal](25, 12) NULL,
	[NumQc] [decimal](25, 12) NULL,
	[Oknum] [decimal](25, 12) NULL,	
	[failnum] [decimal](25, 12) NULL,
	[QCTime] [datetime] NULL,
	[Inspector] [int] NULL,	
	[addcate] [int] NULL,
	[date1] [datetime] NULL,
	[date7] [datetime] NULL,
	[cateid_sp] [int] NULL,
	[date2] [datetime] NULL,
	[del] [int] NULL,
	[delcate] [int] NULL,
	[deldate] [datetime] NULL,
	[intro] [ntext] NULL,
	[QCReport] [ntext] NULL,
	[ph] [nvarchar](50) NULL, 
	[xlh] [nvarchar](100) NULL, 
	[datesc] [datetime] NULL, 
	[dateyx] [datetime] NULL, 
	[datedh] [datetime] NULL, 
	[intro2] [nvarchar](500) NULL,
	[zdy1] [nvarchar](200) NULL,
	[zdy2] [nvarchar](200) NULL,
	[zdy3] [nvarchar](200) NULL,
	[zdy4] [nvarchar](200) NULL,
	[zdy5] [int] NULL,
	[zdy6] [int] NULL,
	[bz] [int] NULL, 
	[dateL] [datetime] NULL,
	[QC_id] [int] DEFAULT (0) NOT NULL,
	[QCType] [int] NULL,
	[QcResult] [int] NULL,
	[SpResult] [int] DEFAULT (0) NOT NULL,	
	[SpRemark] [nvarchar](500) NULL
) ON [PRIMARY]
--@##mode:index;clustered:true;fields:id
--@##mode:index;clustered:false;fields:del;include:id,SpResult


GO

---质检单明细表
CREATE TABLE [dbo].[caigouQClist] (
	[id] [int] IDENTITY (1, 1) NOT NULL,
	[caigouQC] [int] NOT NULL,
	[caigou] [int] NOT NULL,
	[caigouList] [int] NOT NULL,
	[Num1] [decimal](25, 12) NOT NULL,
	[NumQC] [decimal](25, 12) NOT NULL,
	[QCType] [int] NULL,
	[OKNum] [decimal](25, 12) NOT NULL,
	[FailNum] [decimal](25, 12) NOT NULL,
	[POP] [float] NULL,	
	[Result] [int] NOT NULL, 
	[QCRank] [int] NULL,
	[SpResult] [int] NOT NULL,	
	[SpRemark] [nvarchar](500) NULL,
	[del] [int] not null,
	[addcate] [int] NULL
) ON [PRIMARY]

GO
--费用预算
CREATE TABLE [dbo].[budget](
	[ord] [int] IDENTITY(1,1) NOT NULL,
	[title] [nvarchar](200) NULL,
	[bh] [nvarchar](100) NULL,
	[sort] [int] NULL,    --预算类型1.部门预算2. 小组3. 人员
	[Obj_ord] [int] NULL, --各类型ID
	[bz] [int] NULL,	  --币种
	[money1] [decimal](25, 12) NULL,--预算总额
	[mode] [int] NULL,    --预算模式1.汇总模式2. 明细模式
	[startDate] [datetime] NULL, --预算开始日期
	[endDate] [datetime] NULL,--预算截止日期
	[intro] [ntext] NULL, --预算概要
	[pID] [int] NULL,	  --预算父单据(预算拆分)后继承
	[isCut] [int] NULL,	  --记录是否被拆分
	[sp] [int] NULL,      --审批级别ID
	[cateid_sp] [int] NULL,     --当前级别审批人
	[status] [int] NULL,  --单据审批状态
	[indate] [datetime] NULL, --单据添加时间
	[creator] [int] NULL, --单据添加人
	[del] [int] NULL,      --单据正常与删除状态1 正常2 删除
	[delcate] [int] NULL,  --删除人员
	[deldate] [datetime] NULL --删除日期,
    PRIMARY KEY CLUSTERED
    (
        [ord] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]

GO
--费用预算明细
CREATE TABLE [dbo].[budgetList](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[sort] [int] NULL,    --费用分类
	[sortName] [varchar](200) NULL,  --费用分类名称
	[money1] [decimal](25, 12) NULL,--预算金额
	[intro] [nvarchar] (500) NULL, --明细备注
	[pID] [int] NULL	  --预算父单据[budget].ord,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]

GO
--策略表
CREATE TABLE [dbo].[strategy](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[sort] [int] NULL,  --策略1
	[sort2] [int] NULL, --策略2
	[intro] [ntext] NULL,--策略值
	[gate2] [int] NULL   --策略类型 1. 费用预算,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[document](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[title] [nvarchar](100) NULL,
	[wdid] [nvarchar](50) NOT NULL,	
	[sort] [int] NULL,
	[C_Level] [int] NULL,
	[share1] [text] NULL,
	[share2] [text] NULL,
	[validity] [int] NULL,
	[date3] [datetime] NULL,
	[date4] [datetime] NULL,
	[intro] [ntext] NULL,
	[addcate] [int] NOT NULL,
	[date7] [datetime] NOT NULL,
	[spFlag] [int] NULL,
	[sp] [int] NULL,
	[cateid_sp] [int] NULL,
	[cateid2] [int] NULL,
	[date2] [datetime] NULL,
	[del] [int] NOT NULL,
	[delcate] [int] NULL,
	[deldate] [datetime] NULL,
	[archive] [int] NULL,
	[archcate] [int] NULL,
	[archdate] [datetime] NULL,
	[postView] [varchar](4000) NULL,
	[postDown] [varchar](4000) NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

--文档明细文件列表
CREATE TABLE [dbo].[documentlist](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[document] [int] NOT NULL,
	[oldname] [nvarchar](200) NOT NULL,	
	[fileDes] [nvarchar](500) NULL,
	[WDUrl] [nvarchar](300) NOT NULL,
	[WDSize] [bigint] NOT NULL,
	[WDType] [varchar](20) NULL,
	[archive] [int] NOT NULL,
	[archcate] [int] NULL,
	[archdate] [datetime] NULL,
	[num1] [int] NOT NULL,
	[num2] [int] NOT NULL,
	[l_validity] [int] NULL,
	[l_date3] [datetime] NULL,
	[l_date4] [datetime] NULL,
	[addcate] [int] NOT NULL,
	[date7] [datetime] NOT NULL,
	[date2] [datetime] NULL,
	[cateid2] [int] NULL,
	[del] [int] NULL,
	[delcate] [int] NULL,
	[deldate] [datetime] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

--附件操作日志，一表多用
CREATE TABLE [dbo].[action_log](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NULL,
	[listid] [int] NULL,	
	[intro] [varchar](50) NOT NULL,
	[date7] [datetime] NOT NULL,
	[cateid] [int] NOT NULL,
	[sort1] [int] NOT NULL,
	[type1] [int] NULL,
	[ip] [varchar](30) NOT NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

--存放工序关联的设备清单
CREATE TABLE [dbo].[M_MachineList_WP] (
	[ID] [int] IDENTITY (1, 1) NOT NULL ,
	[MachineID] [int] NOT NULL ,
	[WPID] [int] NOT NULL ,
	[sn] [nvarchar] (50) COLLATE Chinese_PRC_CI_AS NULL ,
	[name] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL ,
	[cls] [nvarchar] (50) COLLATE Chinese_PRC_CI_AS NULL ,
	[type] [nvarchar] (50) COLLATE Chinese_PRC_CI_AS NULL ,
	[wTime] [decimal](25, 12) NULL ,
	[mec] [decimal](25, 12) NULL ,
	[Period] [decimal](25, 12) NULL ,
	[cnt] [int] NOT NULL ,
	[remark] [ntext] COLLATE Chinese_PRC_CI_AS NULL ,
	[del] [int] NOT NULL ,
	[Creator] [int] NOT NULL ,
	[indate] [datetime] NOT NULL 
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

--@##mode:index;clustered:true;fields:WPID
--@##mode:index;clustered:false;fields:ID
--@##mode:index;clustered:false;fields:MachineID
--@##mode:index;clustered:false;fields:Creator
--@##mode:index;clustered:false;fields:indate desc

GO

--存放在生产计划保存时各工序所需设备
CREATE TABLE [dbo].[M_MachineList_MP] (
	[ID] [int] IDENTITY (1, 1) NOT NULL ,
	[planlistID] [int] NOT NULL ,
	[MachineID] [int] NOT NULL ,
	[WPID] [int] NOT NULL ,
	[sn] [nvarchar] (50) COLLATE Chinese_PRC_CI_AS NULL ,
	[name] [nvarchar] (100) COLLATE Chinese_PRC_CI_AS NULL ,
	[cls] [varchar] (50) COLLATE Chinese_PRC_CI_AS NULL ,
	[type] [varchar] (50) COLLATE Chinese_PRC_CI_AS NULL ,
	[wTime] [decimal](25, 12) NULL ,
	[mec] [decimal](25, 12) NULL ,
	[Period] [decimal](25, 12) NULL ,
	[cnt] [int] NOT NULL ,
	[remark] [ntext] COLLATE Chinese_PRC_CI_AS NULL ,
	[del] [int] NOT NULL ,
	[Creator] [int] NOT NULL ,
	[indate] [datetime] NOT NULL 
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

--@##mode:index;clustered:true;fields:WPID
--@##mode:index;clustered:false;fields:ID
--@##mode:index;clustered:false;fields:planlistID
--@##mode:index;clustered:false;fields:MachineID
--@##mode:index;clustered:false;fields:Creator
--@##mode:index;clustered:false;fields:indate desc

GO

--存放派工时指定的设备信息
CREATE TABLE [dbo].[M_MachineList_WA] (
	[ID] [int] IDENTITY (1, 1) NOT NULL ,
	[MachineID] [int] NOT NULL ,
	[WPID] [int] NOT NULL ,
	[WAID] [int] NOT NULL ,
	[sn] [nvarchar] (50) COLLATE Chinese_PRC_CI_AS NULL ,
	[name] [nvarchar] (100) COLLATE Chinese_PRC_CI_AS NULL ,
	[cls] [varchar] (50) COLLATE Chinese_PRC_CI_AS NULL ,
	[type] [varchar] (50) COLLATE Chinese_PRC_CI_AS NULL ,
	[wTime] [decimal](25, 12) NULL ,
	[mec] [decimal](25, 12) NULL ,
	[Period] [decimal](25, 12) NULL ,
	[cnt] [int] NOT NULL ,
	[remark] [ntext] COLLATE Chinese_PRC_CI_AS NULL ,
	[useTime] [decimal](25, 12) NOT NULL ,
	[unitPrice] [decimal](25, 12) NOT NULL ,
	[del] [int] NOT NULL ,
	[Creator] [int] NOT NULL ,
	[indate] [datetime] NOT NULL 
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

--@##mode:index;clustered:true;fields:WPID
--@##mode:index;clustered:false;fields:ID
--@##mode:index;clustered:false;fields:MachineID
--@##mode:index;clustered:false;fields:WAID
--@##mode:index;clustered:false;fields:Creator
--@##mode:index;clustered:false;fields:indate desc

GO

--存放进度汇报单明细和工资单的关联关系
CREATE TABLE [dbo].[Wages_MaterialProgresDetail] (
	[ID] [int] NOT NULL primary key identity(1,1),
	[WageId] [int] NOT NULL ,
	[MPDID] [int] NOT NULL 
) ON [PRIMARY]

GO

--新增分类表
CREATE TABLE [dbo].[sortClass](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[id1] [int] NULL,--上级ID (关联单据ID)
	[title] [nvarchar](100) NULL,
	[intro] [ntext] NULL,--说明字段或者关联字串 (此处关联 多个资质类型)(text)
	[Ulimit] [decimal](25, 12) NULL,
	[Llimit] [decimal](25, 12) NULL,
	[isStop] [int] NULL DEFAULT (0),
	[sort1] [int] NULL,--所属分类(栏目)(sort1=1 资质分类 sort1=2 资质类型 )
	[gate1] [int] NULL,--重要指数
	[cateid] [int] NULL,--添加人
	[del] [int] NULL DEFAULT (1),
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

--新增字段表
CREATE TABLE [dbo].[sortFields](
	[id] [int] IDENTITY (1, 1) NOT NULL ,
	[ord] [int] NULL, --特殊字段指定标识 (不同类型sort值字段内不能重复,唯一指定取值或显示)
	[oldName] [nvarchar] (50) NULL , 
	[Name] [nvarchar] (50) NULL ,
	[type] [int]  NULL ,--(字段显示类型 文本 ,日期 下拉 等)
	[show] [int]  NULL ,    --是否显示
	[point] [int]  NULL ,   --重名提示
	[enter] [int]  NULL ,   --重名禁止录入
	[Required] [int]  NULL ,--是否必填
	[format] [nvarchar](100) NULL ,--录入格式要求
	[sort2] [int]  NULL , --(字段分组)
	[sort] [int]  NULL , --(关联sortClass.id)
	[fieldName] [nvarchar] (50) NULL ,--数据库字段名
	[gate1] [int]  NULL , --重要指数
	[extra] [nvarchar] (200),--其他说明
	[del] [int] NULL         --注 : 如果是下拉字段 增加字段到sortClass中 id1 = sortFields.id 其中 sortClass.sort1=3	
) ON [PRIMARY]

GO
--新增字段内容表
CREATE TABLE [dbo].[sortFieldsContent](
	[id] [int] IDENTITY (1, 1) NOT NULL ,
	[sortid] [int], --(资质类型ID)(关联sortClass.id)
	[bh] [nvarchar](100) NULL,  --编号
	[MechanismNo] [nvarchar](100) NULL,--机构代码
	[authority] [nvarchar](100) NULL,  --发证单位
	[date1]	[nvarchar](100) NULL, --发证日期
	[date2]	[nvarchar](100) NULL, --有效日期
	[share] [ntext]	NULL,    --提醒人
	[intro] [ntext] NULL,    --备注字段
	[zdy1] [nvarchar](500) NULL,
	[zdy2] [nvarchar](500) NULL,
	[zdy3] [nvarchar](500) NULL,
	[zdy4] [nvarchar](500) NULL,
	[zdy5] [int] NULL,
	[zdy6] [int] NULL,
	[sort] [int] NULL, --1 tel表(客户或供应商)
	[ord] [int] NULL,  --单据ID
	[alt] [ntext]	NULL, 
	[del] [int] NULL   --注 : 如果是下拉字段 增加字段到sortClass中 id1 = sortFields.id 其中 sortClass.sort1=3	
) ON [PRIMARY]

GO

--新增养护表
CREATE TABLE [dbo].[maintain](
	[ord] [int] IDENTITY (1, 1) NOT NULL ,
	[title] [nvarchar](100), --主题
	[bh] [nvarchar](100) NULL,  --编号
	[date1]	[datetime] NULL, --养护日期
	[reason] [nvarchar](500) NULL,--原因
	[intro] [ntext] NULL,    --备注
	[addcate] [int] NULL,    --添加人
	[addcate2] [int] NULL,   --
	[addcate3] [int] NULL,
	[date4] [datetime] NULL, --添加日期
	[date7] [datetime] NULL, --添加时间
	[zdy1] [nvarchar](200) NULL,
	[zdy2] [nvarchar](200) NULL,
	[zdy3] [nvarchar](200) NULL,
	[zdy4] [nvarchar](200) NULL,
	[zdy5] [int] NULL,
	[zdy6] [int] NULL,
	[sp] [int] NULL,      --审批级别ID
	[cateid_sp] [int] NULL,     --当前级别审批人
	[status] [int] NULL,  --单据审批状态
	[del] [int] NULL,      --单据正常与删除状态1 正常2 删除
	[delcate] [int] NULL,  --删除人员
	[deldate] [datetime] NULL --删除日期
) ON [PRIMARY]

GO

--新增养护明细表
CREATE TABLE [dbo].[maintainlist](
	[id] [int] IDENTITY (1, 1) NOT NULL ,
	[ord] [int] NULL,    --产品ord
	[maintain] [int] NULL,    --养护表ord
	[num1] [decimal](25, 12) NULL DEFAULT (0),--数量
	[share] [text] NULL,--养护人员
	[status] [int] NULL,  --质量状况
	[result] [nvarchar](200) NULL,--处理结果
	[intro] [ntext] NULL, --备注
	[ku] [int] NULL , --库存ku.id
    [SerialID] [int] NULL , --序列号.id
	[del] [int] NULL,      --单据正常与删除状态1 正常2 删除
	[alt2] [varchar](2000) NULL
) ON [PRIMARY]

GO

--票据类型配置表
create table [dbo].[invoiceConfig](
	id int identity(1,1) not null primary key,
	typeId int not null,
	taxRate [decimal](25, 12) not null default 0,
	adTax int not null default 0 ,
	maxAmount [decimal](25, 12) not null default 100000,
	maxCount int not null default 20,
	titleShowName varchar(200) not null default '发票抬头' ,
	taxNoShowName varchar(200) not null default '税号',
	taxNoOpenFlag int not null default 1 ,
	taxNoMustIn int not null default 0 ,
	addrShowName varchar(200) not null default '公司地址',
	addrOpenFlag int not null default 1 ,
	addrMustIn int not null default 0 ,
	phoneShowName varchar(200) not null default '公司电话' ,
	phoneOpenFlag int not null default 1,
	phoneMustIn int not null default 0 ,
	bankShowName varchar(200) not null default '开户行',
	bankOpenFlag int not null default 1 ,
	bankMustIn int not null default 0 ,
	accountShowName varchar(200) not null default '开户行账号',
	accountOpenFlag int not null default 1 ,
	accountMustIn int not null default 0 ,
	priceFormula varchar(200) not null default('{折后单价}*(1+{税率})'), --含税单价计算公式
	priceBeforeTaxFormula varchar(200) not null default('{含税折后单价}/(1+{税率})') --未税单价计算公式
)

GO

--开票计划
CREATE TABLE [dbo].[paybackInvoice] (
	[id] [int] IDENTITY (1, 1) NOT NULL ,
    [BH] [nvarchar](200) null,
	[company] int NULL,
	[fromType] [varchar](20) NOT NULL,
	[FromChildType] int  NULL,
	[fromId] [int] NOT NULL,
    [bz] [int] NULL,
    [money1] [decimal](25, 12) NULL,
	[invoiceType] [int] NOT NULL,
    [taxRate] [decimal](25, 12) NULL,
    [HL] [decimal](25,12) not null DEFAULT(1),
    [MoneyBeforeTax] [decimal](25,12) not null DEFAULT(0),
    [TaxValue] [decimal](25,12) not null DEFAULT(0),
	[TaxMoney] [decimal](25,12) not null DEFAULT(0),
	[invoiceMode] [int] NULL,
	[invoiceNum] [nvarchar](100) NULL,
	[invoicely] [int] NULL,
	[date1] [datetime] NULL,
	[date7] [datetime] NULL,
    [invoiceDate] [datetime] NULL,
	[invoiceCate] [int] NULL,
	[invoiceDatetime] [datetime] NULL,
	[cateid] [int]  NULL,
	[cateid2] [int]  NULL,
	[cateid3] [int]  NULL,
	[addcate] [int]  NULL,
	[addcate2] [int]  NULL,
	[addcate3] [int]  NULL,
	[title] [nvarchar](200)  NULL,--Task 2431 Sword 2015-1-29 直接出库合同保存 
	[taxno] [nvarchar](200)  NULL,
	[addr] [nvarchar](200)  NULL,
	[phone] [nvarchar](200)  NULL,
	[bank] [nvarchar](200)  NULL,
	[account] [nvarchar](200)  NULL,
	[delcate] [int] NULL,
	[deldate] [datetime] NULL,
	[isInvoiced] [int] NOT NULL DEFAULT(0), --0 未开票 ,1 已开票 ,2 预收款开票(状态)
	[del] int NOT NULL,
	[intro] [nvarchar](500) null,
	[InvoiceSureId] [int] null,
	[RedJoinId] [int] null,
	[KuoutId] [int] null,
	[SendId] [int] null,
    [TaxPreferenceType] [int] null,
    [CancelTime] [datetime] null,
    [CancelCate] [int] null
)

--@##mode:index;clustered:false;fields:fromId,del,fromType,isInvoiced,money1
--@##mode:index;clustered:false;fields:fromId,del,fromType,date1 desc,id desc
--@##mode:statistics;fields:invoiceDate,isInvoiced
--@##mode:statistics;fields:fromType,isInvoiced
--@##mode:statistics;fields:del,invoicely
--@##mode:statistics;fields:company,del,invoiceType
--@##mode:statistics;fields:isInvoiced,fromId,del
--@##mode:statistics;fields:fromId,fromType,isInvoiced
--@##mode:statistics;fields:invoicely,invoiceDate,isInvoiced
--@##mode:statistics;fields:del,isInvoiced,invoiceDate
--@##mode:statistics;fields:del,fromType,isInvoiced
--@##mode:statistics;fields:isInvoiced,del,invoicely,invoiceDate
--@##mode:statistics;fields:date1,id,company,del
--@##mode:statistics;fields:date1,id,fromType,fromId,del
--@##mode:statistics;fields:invoiceType,fromId,del,fromType,date1,id
--@##mode:statistics;fields:invoiceType,invoiceCate,company,del,date1,id

GO

--开票明细表
create table [dbo].[paybackInvoice_list](
	id int identity(1,1) not null primary key,
	product int not null,--产品ord
	Unit [int] NULL,
    num1 [decimal](25, 12) NOT NULL DEFAULT(0),--产品数量
	money1 [decimal](25, 12) NOT NULL DEFAULT(0),--开票金额
    HL [decimal](25, 12) NULL,
    Price1 [decimal](25, 12) NULL,
    MoneyBeforeTax [decimal](25, 12) NULL,
    TaxRate [decimal](25, 12) NULL,
    TaxValue [decimal](25, 12) NULL,
	TaxMoney [decimal](25, 12) NULL,   
    contractlist int not null,--合同明细id
	paybackInvoice int not null,--paybackInvoice.id
	[InvoiceSureId] [int] null,
	[RedJoinListId] [int] null,
	[KuoutListId] [int] null,
	[KuoutListId1] [int] null,
    [SendListId] [int] null,
	[ContractthlistId] [int] null,
    del [int] NOT null,
    [CKAccStatus] [int] NULL
)

--@##mode:index;clustered:false;fields:paybackInvoice

GO

--项目流程模板
CREATE TABLE [dbo].[ProcModels] (
	[id] [int] IDENTITY (1, 1) NOT NULL ,
	[name] [nvarchar] (50) NOT NULL ,
	[type] [int] NOT NULL ,
	[Flag] [int] NOT NULL ,
	[gate1] [int] NOT NULL ,
	[addcate] [int] NULL ,
	[date7] [datetime] NULL
)

GO
--项目流程阶段设置
CREATE TABLE [dbo].[ProcModelsNodes] (
	[id] [int] IDENTITY (1, 1) NOT NULL ,
	[name] [nvarchar] (50) NULL ,
	[chancePMid] [int] NULL ,
	[sortid] [int] NULL ,
	[sortid1] [int] NULL ,
	[addcate] [int] NULL ,
	[date7] [datetime] NULL,
	[jdtype] [int] NULL ,
	[execorder] [int] NULL ,
	[timeproject] [numeric](20, 6) ,
	[budgetmoney] [decimal](25, 12) NULL ,
	[executors] [text] NULL ,
	[actors] [text] NULL ,
	[intro] [ntext] NULL ,
	[mustat] [int] NULL ,
	[allOKModel] [int] NULL ,
	[commFields] [varchar] (100) NULL ,
	[linkFields] [varchar] (200) NULL ,
	[zdyFields] [ntext] NULL,
	[splinktype] [int] NULL
)

GO
--项目流程阶段设置
CREATE TABLE [dbo].[ProcNextNodes] (
	[nodeid] [int] NOT NULL ,
	[nextid] [int] NOT NULL 
) 

GO

--项目流程阶段备份表
CREATE TABLE [dbo].[chanceProcNodesBak](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[chance] [int] NOT NULL,
	[NodeId] [int] NOT NULL,
	[name] [nvarchar](50) NULL,
	[chancePMid] [int] NULL,
	[sortid] [int] NULL,
	[sortid1] [int] NULL,
	[addcate] [int] NULL,
	[date7] [datetime] NULL,
	[jdtype] [int] NULL,
	[execorder] [int] NULL,
	[timeproject] [int] NULL,
	[budgetmoney] [decimal](25, 12) NULL,
	[executors] [text] NULL,
	[actors] [text] NULL,
	[intro] [ntext] NULL,
	[mustat] [int] NULL,
	[allOKModel] [int] NULL,
	[commFields] [varchar](100) NULL,
	[linkFields] [varchar](200) NULL,
	[zdyFields] [ntext] NULL,
	[splinktype] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

--项目流程阶段实际执行数据 execStatus 执行状态, execValue 执行状态进度
CREATE TABLE [dbo].[ChanceProcRunLogs](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[chance] [int] NOT NULL,
	[ProcNodesBak] [int] NOT NULL,
	[BeginTimePlan] [datetime] NULL,
	[EndTimePlan] [datetime] NULL,
	[WorkTime] [numeric](20, 6) NULL,
	[MainExecutor] [int] NULL,
	[Executors] [varchar](6000) NULL,
	[Money1] [decimal](25, 12) NULL,
	[Intro]  [ntext] NULL,
	[Status] [int] NOT NULL,
	[NodeModel] [int] NOT NULL,
	[BeginTime] [datetime] NULL,
	[EndTime] [datetime] NULL,
	[date7] [datetime] NOT NULL,
	[fd_area] [int] NULL,
	[fd_trade] [int] NULL,
	[fd_sorce] [int] NULL,
	[fd_complete1] [int] NULL,
	[fd_money2] [decimal](25, 12) NULL,
	[fd_money3] [decimal](25, 12) NULL,
	[fd_date2] [datetime] NULL,
	[fd_zdydata] [ntext] NULL,
	[zdy1] [nvarchar](50) NULL,
	[zdy2] [nvarchar](50) NULL,
	[zdy3] [nvarchar](50) NULL,
	[zdy4] [nvarchar](50) NULL,
	[zdy5] [int] NULL,
	[zdy6] [int] NULL,
	[del] [int] NOT NULL,
	[execStatus] [int] NULL,
	[execValue] [decimal](25, 12) NULL,
	[execTime] [datetime] NULL,
	[execcate] [int] NULL,
	[ip] [varchar](100) NULL,
	[isupdate] [int] NULL,
	[realwork] [numeric](20, 6) NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[ChanceProcRunLogs_bak](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[logid] [int] NOT NULL,
	[chance] [int] NOT NULL,
	[ProcNodesBak] [int] NOT NULL,
	[BeginTimePlan] [datetime] NULL,
	[EndTimePlan] [datetime] NULL,
	[WorkTime] [numeric](20, 6) NULL,
	[MainExecutor] [int] NULL,
	[Executors] [varchar](6000) NULL,
	[Money1] [decimal](25, 12) NULL,
	[Intro]  [ntext] NULL,
	[Status] [int] NOT NULL,
	[NodeModel] [int] NOT NULL,
	[BeginTime] [datetime] NULL,
	[EndTime] [datetime] NULL,
	[date7] [datetime] NOT NULL,
	[fd_area] [int] NULL,
	[fd_trade] [int] NULL,
	[fd_sorce] [int] NULL,
	[fd_complete1] [int] NULL,
	[fd_money2] [decimal](25, 12) NULL,
	[fd_money3] [decimal](25, 12) NULL,
	[fd_date2] [datetime] NULL,
	[fd_zdydata] [ntext] NULL,
	[zdy1] [nvarchar](50) NULL,
	[zdy2] [nvarchar](50) NULL,
	[zdy3] [nvarchar](50) NULL,
	[zdy4] [nvarchar](50) NULL,
	[zdy5] [int] NULL,
	[zdy6] [int] NULL,
	[del] [int] NOT NULL,
	[execStatus] [int] NULL,
	[execValue] [decimal](25, 12) NULL,
	[execTime] [datetime] NULL,
	[execcate] [int] NULL,
	[ip] [varchar](100) NULL,
	[isupdate] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[ChanceNextNodes](
	[chance] [int] NOT NULL,
	[nodeid] [int] NOT NULL,
	[nextid] [int] NOT NULL
) ON [PRIMARY]

GO

--流程执行阶段关系表	
CREATE TABLE [dbo].[CommNextNodes] (
	[sort]		int NOT NULL,
	[nodeid]	int	NOT NULL,
	[nextid]	int	NOT NULL,
)

GO

CREATE TABLE [dbo].[repair_sl](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[slid] [nvarchar](50) NOT NULL,
	[title] [nvarchar](100) NULL,
	[company] [int] NULL,
	[person] [int] NULL,
	[address] [nvarchar](500) NULL,
	[phone] [nvarchar](50) NULL,
	[mobile] [nvarchar](50) NULL,
	[bz] [int] NULL,
	[jinji] [int] NULL,
	[jiedai] [int] NULL,
	[addcate] [int] NOT NULL,
	[cateid] [int] NULL,
	[date1] [datetime] NULL,
	[date7] [datetime] NULL,
	[complete1] [int] NULL,
	[complete2] [int] NULL,
	[del] [int] NOT NULL,
	[delcate] [int] NULL,
	[deldate] [datetime] NULL,
	[intro] [ntext] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]
 TEXTIMAGE_ON [PRIMARY]
GO

CREATE TABLE [dbo].[repair_sl_list](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NOT NULL,
	[repair_sl] [int] NOT NULL,
	[company] [int] NOT NULL,
	[sort1] [int] NOT NULL,
	[contract] [int] NULL,
	[contractlist] [int] NULL,
	[kuout] [int] NULL,
	[kuoutlist2] [int] NULL,
	[unit] [int] NULL,
	[num1] [decimal](25, 12) NULL,
	[num2] [decimal](25, 12) NULL,
	[num3] [decimal](25, 12) NULL,
	[money1] [decimal](25, 12) NULL,
	[baoxiu] [int] NULL,
	[guzhang] [nvarchar](500) NULL,
	[ruku] [bit] NULL,
	[intro] [nvarchar](500) NULL,
	[date1] [datetime] NULL,
	[date2] [datetime] NULL,
	[ph] [nvarchar](50) NULL,
	[xlh] [nvarchar](100) NULL,
	[datesc] [datetime] NULL,
	[dateyx] [datetime] NULL,
	[zdy1] [nvarchar](200) NULL,
	[zdy2] [nvarchar](200) NULL,
	[zdy3] [nvarchar](200) NULL,
	[zdy4] [nvarchar](200) NULL,
	[zdy5] [int] NULL,
	[zdy6] [int] NULL,
	[addcate] [int] NULL,
	[date7] [datetime] NULL,
	[del] [int] NULL,
	[del2] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[repair_sl_jian](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NOT NULL,
	[repair_sl] [int] NOT NULL,
	[repair_sl_list] [int] NOT NULL,
	[sortid1] [int] NOT NULL,
	[sortid2] [int] NOT NULL,
	[title1] [nvarchar](50) NULL,
	[title2] [nvarchar](50) NULL,
	[Ftype] [int] NULL,
	[intro] [ntext] NULL,
	[addcate] [int] NOT NULL,
	[date7] [datetime] NOT NULL,
	[del] [int] NOT NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]
 TEXTIMAGE_ON [PRIMARY]

GO

CREATE TABLE [dbo].[repair_kulist](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NOT NULL,
	[repair_sl] [int] NOT NULL,
	[repair_sl_list] [int] NOT NULL,
	[RepairOrder] [int] NULL,
	[sort1] [int] NOT NULL,
	[num1] [decimal](25, 12) NOT NULL,
	[date1] [datetime] NOT NULL,
	[addcate] [int] NOT NULL,
	[date7] [datetime] NOT NULL,
	[del] [int] NOT NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[RepairOrder](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Title] [nvarchar](100) ,
	[SerialNumber] [nvarchar](100) NULL,
	[ProcessID] [int] ,
	[DealPerson] [int] ,
	[Summary] [ntext] NULL,
	[Status] [int] ,
	[Contract] [int] NULL,
	[contractlist] [int] NULL,
	[repair_sl] [int] ,
	[repair_sl_list] [int] ,
	[ProID] [int] ,
	[NUM] [DECIMAL](25,12) NULL,
	[Cost] [decimal](25, 12) NULL,
	[DeliveryDate] [datetime] NULL,
	[DisposedTime] [datetime] NULL,
	[Del] [int] NULL,
	[DelUser] [int] NULL,
	[DelTime] [datetime] NULL,
	[AddUser] [int] NULL,
	[AddTime] [datetime] NULL DEFAULT(GETDATE()),
	[lastUpTime] [datetime] NULL DEFAULT(GETDATE())  --最后更新时间，防止并发,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]
 TEXTIMAGE_ON [PRIMARY]

--@##mode:index;clustered:false;fields:id,AddUser,AddTime,Del,contractlist
--@##mode:index;clustered:false;fields:Contract,del,addTime desc

GO

CREATE TABLE [dbo].[Comm_ProcessSet](
[Id] [int] IDENTITY(1,1) NOT NULL,
[Title] [NVARCHAR](50) NOT NULL,
[IsUse] [BIT] NOT NULL,
[Ranking] [int] NULL,
[Type] [int] NOT NULL,
[AddUser] [int] NOT NULL,
[AddTime] DATETIME DEFAULT(GETDATE()) NOT NULL,
) 
GO

CREATE TABLE [dbo].[Comm_ProcessNodeSet](
[Id] [int] IDENTITY(1,1) NOT NULL,
[Title] NVARCHAR(50) NOT NULL,
[NodeType] [int] NOT NULL,
[Duration] [float] NULL,
[Ranking] [int] NOT NULL,
[Relation] [int] NOT NULL,
[DealPerson] [NTEXT] NOT NULL,
[CurrentNodeType] [int] NOT NULL,
[BeforeNodeType] [int] NOT NULL,
[Remark] [NTEXT] NULL,
[RelatedBill] VARCHAR(100) NULL,
[ProcessSet] [int] NULL,
[Type] [int] NOT NULL,
[AddUser] [int] NOT NULL,
[AddTime] DATETIME DEFAULT(GETDATE()) NOT NULL,
)
GO

CREATE TABLE [dbo].[Comm_NodesMap](
[Id] [int] IDENTITY(1,1) NOT NULL,
[NodeID] [int] NOT NULL,
[NextNodeID] [int] NULL,
[IsSelected] [int] NULL DEFAULT(0),
[ProcessSet] [int] NULL,
[AddUser] [int] NOT NULL
)

GO
CREATE TABLE [dbo].[Copy_ProcessSet](
	[Id] [int] NOT NULL,	
	[Title] [nvarchar](50) NOT NULL,
	[IsUse] [bit] NOT NULL,
	[Ranking] [int] NULL,
	[Type] [int] NOT NULL,
	[RepairOrder] [int] NOT NULL,
	[del] [int] NOT NULL DEFAULT(1),
	[AddUser] [int] NOT NULL,
	[AddTime] [datetime] DEFAULT(GETDATE()) NOT NULL,
) 

GO
CREATE TABLE [dbo].[Copy_ProcessNodeSet](
	[Id] [int] NOT NULL,
	[Title] [nvarchar](50) NOT NULL,
	[NodeType] [int] NOT NULL,
	[Duration] [float] NULL,
	[Ranking] [int] NOT NULL,
	[Relation] [int] NOT NULL,
	[DealPerson] [ntext] NOT NULL,
	[CurrentNodeType] [int] NOT NULL,
	[BeforeNodeType] [int] NOT NULL,
	[Remark] [ntext] NULL,
	[RelatedBill] [varchar](100) NULL,
	[ProcessSet] [int] NULL,
	[Type] [int] NOT NULL,
	[RepairOrder] [int] NOT NULL,
	[del] [int] NOT NULL DEFAULT(1),
	[AddUser] [int] NOT NULL,
	[AddTime] [datetime] DEFAULT(GETDATE()) NOT NULL
) 

GO
CREATE TABLE [dbo].[Copy_NodesMap](
	[Id] [int] NOT NULL,
	[NodeID] [int] NOT NULL,
	[NextNodeID] [int] NULL,
	[IsSelected] [int] NULL,
	[ProcessSet] [int] NULL,
	[RepairOrder] [int] NOT NULL,
	[del] [int] NOT NULL DEFAULT(1),
	[AddUser] [int] NOT NULL,	
) 

GO

CREATE TABLE [dbo].[Copy_CustomFields](
	[ID] [int] NOT NULL,
	[TName] [int] NOT NULL,
	[IsMaster] [bit] NULL,
	[FOrder] [int] NOT NULL,
	[FName] [nvarchar](500) NOT NULL,
	[FType] [int] NOT NULL,
	[MustFillin] [bit] NOT NULL,
	[OptionID] [int] NULL,
	[FStyle] [nvarchar](500) NULL,
	[IsUsing] [bit] NULL,
	[CanExport] [bit] NULL,
	[CanInport] [bit] NULL,
	[CanSearch] [bit] NULL,
	[CanStat] [bit] NULL,
	[del] [int] NULL,
	[RepairOrder] [int] NOT NULL
)

GO
CREATE TABLE [dbo].[RepairDeal](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[CurrentStatus] [int] NOT NULL,
	[DealPerson] [int] NULL,
    [ActorsCateid] [nvarchar](max) NULL,
	[ActualBeginTime] [datetime] NULL,
	[ActualEndTime] [datetime] NULL,
	[Remark] [ntext] NULL,
	[approveStatus] [INT] NULL,
	[approveRemark] [NVARCHAR](500) NULL,
	[beforeNodeID] [INT] NULL,
	[NodeID] [int] NOT NULL,
	[ProcessID] [int] NOT NULL,
	[RepairOrder] [int] NOT NULL,
	[del] [int] NOT NULL DEFAULT(1),
	[AddUser] [int] NOT NULL,
	[AddTime] [datetime] DEFAULT(GETDATE()) NOT NULL
)

GO
CREATE TABLE [dbo].[RepairNewParts](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ProID] [int] NULL,
	[Num] [DECIMAL](25,12) NULL,
	[Unit] [int] NULL,
	[UseDate] [datetime] NULL,
	[Remark] [ntext] NULL,
	[zdy1] [nvarchar](200) NULL,
	[zdy2] [nvarchar](200) NULL,
	[zdy3] [nvarchar](200) NULL,
	[zdy4] [nvarchar](200) NULL,
	[zdy5] [nvarchar](50) NULL,
	[zdy6] [nvarchar](50) NULL,
	[NodeID] [int] NULL,
	[ProcessID] [int] NULL,
	[RepairOrder] [int] NULL,
	[Repair_sl_list] [int] NULL,
	[RepairDeal] [int] NULL,
	[Del] [int] NULL,
	[AddUser] [int] NOT NULL,
	[AddTime] [datetime] DEFAULT(GETDATE()) NOT NULL 
)

GO
CREATE TABLE [dbo].[RepairTriggerNode](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[NodeID] [int] NULL,
	[Duration] [float] NULL,
	[DealPerson] [int] NULL,
	[BeginTime] [datetime] NULL,
	[EndTime] [datetime] NULL,
	[ParentID] [int] NULL,
	[ProcessID] [int] NULL,
	[RepairOrder] [int] NULL,
	[DealStatus] [int] NULL,
	[del] [int] NOT NULL DEFAULT(1),
	[AddUser] [int] NULL,
	[AddTime] [datetime] DEFAULT(GETDATE()) NOT NULL
)

GO
CREATE TABLE [dbo].[RepairDealApprove](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Suggest] [nvarchar](500) NULL,
	[Status] [int] NULL,
	[BeforeNodeID] [int] NULL,
	[DealNodeID] [int] NULL,
	[ProcessID] [int] NULL,
	[RepairOrder] [int] NULL,
	[del] [int] NOT NULL DEFAULT(1),
	[AddUser] [int] NULL,
	[AddTime] [datetime] DEFAULT(GETDATE()) NOT NULL
) 

GO

--不实用 已放弃
CREATE TABLE [dbo].[contractlist_Log](
	[id] [int] IDENTITY(1,1) NOT NULL primary key,
	[contract] [int] not null,--合同id
	[opDate] [datetime] not null,--修改时间
	[operator] [int] not null --修改人
)

GO

--不实用 已放弃
CREATE TABLE [dbo].[contractlist_changes](
	[id] [int] IDENTITY(1,1) NOT NULL primary key,
	[his_id] [int] not null,--contractlist_his.id
	[fieldName] [varchar](50),--有变化的字段名
	[newValue] [varchar](200) --变化后的值
)

GO

CREATE TABLE [dbo].[contractlist_his](
	[id] [int] IDENTITY(1,1) NOT NULL primary key,
	[his_id] [int] null , --contract_his.id
	[log_id] [int] null,--contractlist_Log.id
	[listid] [int] not null,
	[op_type] [varchar](10),--APPEND,MODIFY,DELETE
    [ord] [int] null,--产品ID
	[unit] [int] null,--单位
	[commUnitAttr] [nvarchar](200) NULL,
	[num1] [decimal](25, 12) NULL,
	[pricejy] [decimal](25, 12) NOT null default (0),
    [tpricejy] [decimal](25, 12) NOT null default (0),
    [price1] [decimal](25, 12) NOT NULL DEFAULT (0),
    [discount] [decimal](25, 12) NULL DEFAULT 1, --折扣
	[priceAfterDiscount] [decimal](25, 12) NOT NULL default 0,--折后单价
    [moneyBeforeTax] [decimal](25, 12) NOT NULL default(0),--税前总额
	[invoiceType] int NULL default 0, --票据类型
	[taxRate] [decimal](25, 12) NULL default 0, --税率，数值来自票据类型设置表
    [priceIncludeTax] [decimal](25, 12) NOT NULL DEFAULT (0),--含税单价
    [PriceAfterTaxPre] [decimal](25, 12) NOT NULL default(0),
    [moneyAfterTax] [decimal](25, 12) NOT NULL default(0),--税后总额
	[concessions] [decimal](25, 12) NOT NULL default 0, --优惠金额
	[priceAfterTax] [decimal](25, 12) NOT NULL default(0),--优惠后单价
    [moneyAfterConcessions] [decimal](25, 12) NULL default(0), --金额
    [taxValue] [decimal](25, 12) NOT NULL DEFAULT(0),--税额
	[money1] [decimal](25, 12) NOT NULL DEFAULT (0), --优惠后总价
	[extras] [decimal](25, 12), --运杂费
	[intro] [nvarchar](200) NULL,
	[zdy1] [nvarchar](200) NULL,
	[zdy2] [nvarchar](200) NULL,
	[zdy3] [nvarchar](200) NULL,
	[zdy4] [nvarchar](200) NULL,
	[zdy5] [int] NULL,
	[zdy6] [int] NULL,
	[date1] datetime null,
	[date2] datetime null,
	[jf] [decimal](25, 12) NULL,
	[goodsId] [int],
    [treeOrd] [int] NULL, 
    [rowindex] [int] null,
    [htmxid] [int] null,
	[ProductAttr1] int null,
	[ProductAttr2] int null,
	[ProductAttrBatchId] int null
)

GO

CREATE TABLE [dbo].[PrintTemplate_Ctrls](
	[id] [int] NOT NULL,
	[title] [nvarchar](100) NULL,
	[CtrlIco] [nvarchar](500) NULL,
	[Remark] [nvarchar](500) NULL,
	[JS] [nvarchar](500) NULL,
	[CtrlType] [nvarchar](50) NULL,
	[ResolveType] [int] NULL,
	[isopen] [int] NULL,
	[paixu] [int] NULL,
	PRIMARY KEY NONCLUSTERED
	(
		[Id] ASC
	) ON [PRIMARY]
)

GO

CREATE TABLE [dbo].[PrintTemplate_Datas](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[title] [nvarchar](100) NULL,
	[ResolveType] [int] NULL,
	[TemplateType] [int] NULL,
	[Remark] [nvarchar](500) NULL,
	[DataSQL] [nvarchar](500) NULL,
	[RowsSQL] [nvarchar](500) NULL,
	[CustomType] [nvarchar](50) NULL,
	[Ex_CustomType] [nvarchar](50) NULL,
	[Relation] [nvarchar](50) NULL,
	[sort1] [int] NULL
)

GO

CREATE TABLE [dbo].[PrintTemplate_PageCtrls](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[CtrlID] [int] NULL,
	[JSON] [ntext] NULL,
	[DataMark] [nvarchar](500) NULL,
	[PageID] [int] NULL,
	[ParentID] [int] NULL,
	[del] [int] NULL default(1),
	[PacketID] [int] NULL,
	[TemplateID] [int] NULL,
	[CtrlJS] [nvarchar](150) NULL,
	[CtrlCoding] [nvarchar](500) NULL,
	[PageCoding] [nvarchar](500) NULL
)

GO

CREATE TABLE [dbo].[PrintTemplate_Pages](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[TemplateID] [int] NULL,
	[PageNum] [int] NULL,
	[PageTop] [nvarchar](500) NULL,
	[PageBottom] [nvarchar](500) NULL,
	[PagePadding] [nvarchar](500) NULL,
	[del] [int] NULL default(1),
	[delID] [int] NULL,
	[delDate] [datetime] NULL,
	[PageCoding] [nvarchar](100) NULL,
	[PageSize] [nvarchar](20) NULL,
	[PageHX] [int] NULL,
	[PageBFY] [int] NULL
)

GO

CREATE TABLE [dbo].[PrintTemplate_Type](
	[id] [int] NOT NULL,
	[ord] [int] NULL,
	[title] [nvarchar](100) NULL,
	[del] [int] NULL default(1),
	[delID] [int] NULL,
	[delDate] [datetime] NULL,
	[oldurl] [varchar](200) NULL,
	PRIMARY KEY NONCLUSTERED
	(
		[Id] ASC
	) ON [PRIMARY]
)

GO

CREATE TABLE [dbo].[PrintTemplates](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[title] [nvarchar](100) NULL,
	[isMain] [int] NULL,
	[TemplateType] [int] NULL,
	[addID] [int] NULL,
	[addDate] [datetime] NULL,
	[del] [int] NULL default(1),
	[delID] [int] NULL,
	[delDate] [datetime] NULL,
	[PrintType] [nvarchar](50) NULL,
	[remark] [nvarchar](500) NULL,
	[isDefault] [int] NULL,
	[isModel] [int] NULL,
	[gate1] [int] NULL,
	[stop] [int] NULL
)

GO

CREATE TABLE [dbo].[PrinterHistory](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NULL,
	[PrinterInfoID] [int] NULL,
	[PrintCate] [int] NULL,
	[PrintDate] [datetime] NULL,
	[PrinterSet] [ntext] NULL,
	[printerMessage] [ntext] NULL,
	[PageSet] [ntext] NULL,
	 PRIMARY KEY NONCLUSTERED
	(
		[Id] ASC
	) ON [PRIMARY]
) 

GO

--Attrs:帐套下可用
CREATE TABLE [dbo].[PrinterInfo](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NULL,
	[templateID] [int] NULL,
	[formID] [int] NULL,
	[sort] [int] NULL,
	[addCate] [int] NULL,
	[addDate] [datetime] NULL,
	[html] [ntext] NULL,
	[del] [int] NULL default(1),
	[delCate] [int] NULL,
	[delDate] [datetime] NULL,
	[PrinterSet] [ntext] NULL,
	[PageSet] [ntext] NULL,
	[IsSum] [int] NULL,
	[isOld] [int] NULL,
	[AccountSys] [int] NULL,
    [AccountYear] [int] NULL,
	[device] [int] NULL,
	PRIMARY KEY NONCLUSTERED
	(
		[Id] ASC
	) ON [PRIMARY]
) 

--@##mode:index;clustered:true;fields:formID,ord,sort

GO

CREATE TABLE [dbo].[PrintTimes](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[datatype] [int] null,
	[ord] [int] NULL,
	[times] [int] NULL,
	PRIMARY KEY NONCLUSTERED
	(
		[Id] ASC
	) ON [PRIMARY]
)

--@##mode:index;clustered:true;fields:datatype,ord

GO

--销售退货类型明细
CREATE TABLE [dbo].[contractthListDetail](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NULL, --产品
	[num1] [decimal](25, 12) NULL, --退货类型数量
	[money1] [decimal](25, 12) NULL, --退货币种金额
	[unit] [int] NOT NULL DEFAULT(0), --退货单位
	[bz] [int] NULL, --退货币种
	[money2] [decimal](25, 12) NULL, --折算合同币种金额
	[contractth] [int] NULL, --退货ORD
	[contractthlist] [int] NULL, --退货明细ID
	[contract] [int] NULL, --合同ORD
	[contractlist] [int] NULL , --合同明细ID
	[thtype] [varchar](50) NULL, --'GOODS' 'MONEY' 'GOODS_MONEY' 退货类型
	[addcate] [int] NULL,
	[del] [int] NULL, --状态
	PRIMARY KEY NONCLUSTERED
	(
		[Id] ASC
	) ON [PRIMARY]
) 

--@##mode:index;clustered:true;fields:contract,contractth,contractthlist
--@##mode:index;clustered:false;fields:contract,ord,unit,addcate,thtype
--@##mode:index;clustered:false;fields:contractthlist
--@##mode:index;clustered:false;fields:thtype,del

GO

--用户操作日志（只记录最后5次操作）
create table [dbo].[UserLastActions](
	id int identity(1,1) primary key,
	AppTime datetime not null,--iis服务启动的时间
	uid int not null,--用户id
	logIdx int not null,--用来记录上次存的是第几个，值为1，2，3循环
	reqUrl1 varchar(100),--访问页面的路径（不包括URL参数）
	reqTime1 datetime,--访问的时间
	reqPostArgs1 ntext,--访问时的post参数
	reqGetArgs1 ntext,--访问时的get参数
	reqUrl2 varchar(100),--访问页面的路径（不包括URL参数）
	reqTime2 datetime,--访问的时间
	reqPostArgs2 ntext,--访问时的post参数
	reqGetArgs2 ntext,--访问时的get参数
	reqUrl3 varchar(100),--访问页面的路径（不包括URL参数）
	reqTime3 datetime,--访问的时间
	reqPostArgs3 ntext,--访问时的post参数
	reqGetArgs3 ntext,--访问时的get参数
	reqUrl4 varchar(100),--访问页面的路径（不包括URL参数）
	reqTime4 datetime,--访问的时间
	reqPostArgs4 ntext,--访问时的post参数
	reqGetArgs4 ntext,--访问时的get参数
	reqUrl5 varchar(100),--访问页面的路径（不包括URL参数）
	reqTime5 datetime,--访问的时间
	reqPostArgs5 ntext,--访问时的post参数
	reqGetArgs5 ntext,--访问时的get参数
)

GO

CREATE TABLE [dbo].[person_age](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[cateid] [int] NULL,
	[date7] [datetime] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[sys_ZBsysLog](
	handleID char(14),
	url varchar(200),
	isupload int,
	formsize int,
	form ntext,
	querysize int,
	query ntext,
	cltsystem nvarchar(100),
	cltbrower nvarchar(200),
	[uid] int,
	sysinit datetime,
	date1 datetime
	PRIMARY KEY NONCLUSTERED
	(
		[handleID] ASC
	) ON [PRIMARY]
)

GO

CREATE TABLE [dbo].[AccountSys](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NOT NULL,
	[title] [nvarchar](200) not NULL, --账套名称
	[bh] [nvarchar](100) not NULL,-- 账套编号
	[sort1] [int] NULL,-- 账套分类（1 主帐套 2 其他帐套）
	[CompanyName] [nvarchar](200) null , --企业名称
	[share] [ntext] null,--调用范围
	[stop] [int] null ,--停用
	[show] [int] null , --显示
	[addcate] [int] null,
	[addtime] [datetime] null,
	[del] [int] null,
	[delcate] [int] null,
	[deltime] [datetime] null,
	[sign] [varchar](32) null,
	[AccountInitDate] [datetime] NULL,  --会计起始核算月份
	[AccountMaxDate] [datetime] NULL,   --会计结束核算月份
	[AccountCurrDate] [datetime] NULL,  --会计当前核算月份
	[AccountMonth1] [int] NULL,         --会计年度起始月
	[AccountMonth2] [int] NULL          --会计年度截止月,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[f_Account](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Accountdate1] [datetime] NULL, --账套启用日期
	[AccountMonth1] [int] NULL, --会计期间——月1
	[AccountMonth2] [int] NULL, --会计期间——月2
	[bz] [int] null,			--本位币
	[institution] [int] null,   --会计制度 企业,小企业
	[defAccountSubject] [int] null ,--是否生成预设会计科目
	[AssetsLiabilities] [int] null, --资产负债表
	[Profit] [int] null , --利润表
	[defFlowSubject] [int] null, --是否生成预设现金流量表项目
	[CashFlow] [int] null,--现金流量表
	--[entity] [nvarchar](100) NULL,--数据实体
	--[DataFile] [nvarchar] (200) NULL,--数据文件
	--[LogFile] [nvarchar](200) null ,--日志文件
	--[VoucherWord][int] NULL, --当前使用凭证字
	[max1] [int] null ,-- 第一级最大长度
	[max2] [int] null , 
	[max3] [int] null,  
	[max4] [int] null,
	[max5] [int] null,
	[max6] [int] null,
	[max7] [int] null,
	[max8] [int] null,
	[max9] [int] null,
	[bhShow] [int] null, --会计科目代码显示在会计科目名称前
	[vouchBhpx] [int] null, --凭证号按期间统一排序
	[fillNum] [int] null, --新增凭证自动填补断号
	[mustIntro] [int] null,--每条凭证分录前必有摘要
	[upHL] [int] null, --凭证中汇率允许手工修改
	[mustMnySub] int null,
	[prestatus] [int] null ,--初始化状态 (0 .未初始化 , 1 .初始化中(有初始化数据) 2. 已结束初始化)
    [preuser] [int] NULL,
	[predate] [datetime] NULL,
    [Income_Voucher_Constraint] [int] NULL,
    [Cost_Voucher_Constraint] [int] NULL,
    [Purchase_Voucher_Constraint] [int] NULL,
	[upcate] [int] null, --最后修改人员
	[update1][datetime] null, --最后修改时间
	[sign] [varchar] (32) null --该账套数据库的主数据库 null值 本身为主数据库,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[f_VoucherWord](
	[id] int IDENTITY(1,1) NOT NULL,
	[date1] [datetime] null, --会计核算月 默认1号 (2014-8-1)
	[sort1] int null,--1.记账凭证 2.收付转凭证 3.现金银行转账 4.现收现付银收银付转账凭证
	[status] int null , -- 0 未结账 1 已结账
	[checkoutpre] int null , --结账人员
	[addcate] int null , --添加人员
	[addtime] datetime null, --添加时间
	[intro] [nvarchar](200) null,--添加说明(凭证添加/设置)
	[title] [nvarchar](100) null,
	[gate1] int null,
	[del] int null,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[f_AccountSubject](
	[ord] [int] IDENTITY(1,1) NOT NULL,
	[parentID] [int] null ,--父级ID
	[bh][nvarchar](100) null,--会计科目编码
	[title] [nvarchar](200) null,--会计科目名称
	[code] [nvarchar](100) null, --助记码
	[sort] [int] null, --会计科目类别
	[amountDirection] [int] null ,-- 发生额方向
	[balanceDirection] [int] null ,-- 余额方向
	[exchangeLoss] [int] null ,-- 汇兑损益
	[thisYearProfit] [int] null ,-- 本年利润科目，0否，1是
	[SubjectAttr][int] null,--现金科目,银行科目 ,其他
	[Journal] [int] null,  --日记账
	[CashFlow] [int] null,--现金流
	[convertBz] [int] null ,--是否核算外币
	[bz][varchar](500)null,--外币币种
	[exchange][int]NULL, --期末调汇(非期末调汇科目:null/0;汇兑损益科目:1;汇兑损失科目:2;汇兑收益科目:3)
	[stop] [int]null , --停用
	[del] [int] NULL, --删除
	[fullids] varchar(200) NULL,
	[fullcode] varchar(200) NULL,
	[fullsort] int NULL,
	[deep]  int NULL,
	[RootID] int NULL,
	[realstoped] int Null,
	[addcate] int null , --添加人员
	[addtime] datetime null, --添加时间
	[isLeaf] int null, --是否叶子节点
	[updatesortcache] [bigint] NULL,
    [NumsCheck] int not null default(0),
	[NumsInitDate] datetime null,
    PRIMARY KEY CLUSTERED
    (
        [ord] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]

--@##mode:index;clustered:false;fields:ord,parentID
--@##mode:index;clustered:false;fields:title
--@##mode:index;clustered:false;fields:code
--@##mode:index;clustered:false;fields:balanceDirection
--@##mode:index;clustered:false;fields:fullcode
--@##mode:index;clustered:false;fields:bz
--@##mode:index;clustered:false;fields:parentID
--@##mode:index;clustered:false;fields:deep
--@##mode:index;clustered:false;fields:fullsort
--@##mode:index;clustered:false;fields:ord
--@##mode:index;clustered:false;fields:ord,bh,stop
--@##mode:index;clustered:false;fields:updatesortcache

GO

CREATE TABLE [dbo].[f_FlowSubject](
	[ord] [int] IDENTITY(1,1) NOT NULL,
	[parentID] [int] null ,--父级ID
	[bh][nvarchar](100) null,--现金流量项目编码
	[title] [nvarchar](200) null,-- 现金流量项目名称
	[Direction] [int] null ,--方向 1 流入 , 2 流出
	[stop] [int]null , --停用
	[del] [int] NULL --删除,
    PRIMARY KEY CLUSTERED
    (
        [ord] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[f_accumulSubject](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[sort1] [int] NULL,
	[date1] [datetime] NULL,
	[AccountSubject] [int] NULL,
	[balanceDirection] [int] NULL,
	[money1_b] [decimal](25, 12) NULL,
	[money1_y] [decimal](25, 12) NULL,
	[money2_b] [decimal](25, 12) NULL,
	[money2_y] [decimal](25, 12) NULL,
	[money3_b] [decimal](25, 12) NULL,
	[money3_y] [decimal](25, 12) NULL,
	[money4_b] [decimal](25, 12) NULL,
	[money4_y] [decimal](25, 12) NULL,
	[index] [int] NULL,
	[bz] [int] NULL,
	[hl] [decimal](25, 12) NULL,
    [Num1] [decimal](25, 12) NULL,
    [Num2] [decimal](25, 12) NULL,
    [Num3] [decimal](25, 12) NULL,
    [Num4] [decimal](25, 12) NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[f_temp_accumulSubject](
	id	[int] 	IDENTITY(1,1) NOT NULL,
	sort1	[int] null ,--	0 初始化 1 结账
	date1	[datetime] null ,--	会计月份
	AccountSubject	[int] null ,--	会计科目
	balanceDirection [int] null , -- 余额方向 继承科目余额方向
	money1_b [decimal](25, 12) null ,--年初/期初累计 本位币
	money1_y [decimal](25, 12) null ,--年初/期初累计 原本
	money2_b [decimal](25, 12) null ,--本期借方发生 本位币
	money2_y [decimal](25, 12) null ,--本期借方发生 原本
	money3_b [decimal](25, 12) null ,--本期贷方发生 本位币
	money3_y [decimal](25, 12) null ,--本期贷方发生 原本
	money4_b [decimal](25, 12) null ,--期末 本位币
	money4_y [decimal](25, 12) null , --期末 原本	
    [Num1] [decimal](25, 12) NULL,
    [Num2] [decimal](25, 12) NULL,
    [Num3] [decimal](25, 12) NULL,
    [Num4] [decimal](25, 12) NULL,
    PRIMARY KEY CLUSTERED
    (
        id ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[f_accumulFlow](
	id	[int] 	IDENTITY(1,1) NOT NULL,
	sort1	[int] null ,--	0 初始化 1 结账
	date1	[datetime] null ,--	会计月份
	FlowSubject	[int] null ,--	现金流量项目
	money1	[decimal](25, 12) null ,--	期初累计
	money2	[decimal](25, 12) null ,--	本期发生
	money3	[decimal](25, 12) null --	期末累计,
    PRIMARY KEY CLUSTERED
    (
        id ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[f_VoucherTemp](
	[ord] [int] IDENTITY(1,1) NOT NULL,
	[VoucherWord] [int] null,--凭证字
	[bh] [nvarchar](100) null,--凭证模板编号
	[title] [nvarchar](200) null,--凭证模板名称
	[sort] [int] null,			--模板类型 1 常规模板 3 对接模板 
	[module] [int] null,		--对接数据栏目
	[clstype] [int] null,       --对接数据类型(方式)
	[clsid] [int] null,		    --对接数据分类(费用分类 工资项目)
	[ExtraType] [int] null,     --扩展ID (人资工资账套ID)
    [rule] [int] null ,         --策略控制
	[addcate] [int] null ,      --添加人
	[addtime] [datetime] null,  --时间
	[stop] [int] null ,         --停用
	[uptime] [datetime] null,   --最后时间
	[upuser] [int] null ,       --最后人员
	[sorting] [int] null,
	[del] [int] NULL,            --删除
    [Currency] [int] NULL default(1),
    [OriginalID] [int] NULL default(0),
    [EntryEnhance] [int] NULL default(0),
    PRIMARY KEY CLUSTERED
    (
        [ord] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[f_VoucherTemp_Enhance](
	[ID] [INT] IDENTITY(1,1) NOT NULL,
	[VoucherTemp] [INT] NOT NULL,
	[Condition] [INT] NOT NULL,
	[ConditionID] [INT] NOT NULL default(0),
	[ConditionValue] [INT] NOT NULL,
    PRIMARY KEY CLUSTERED
    (
        [ID] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[f_VoucherListTemp](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[VoucherTemp] [int] null,   --模板主单据
	[intro] [nvarchar](4000)null,--摘要
	[AccountSubject] [int] null,--会计科目
	[direct] [int] NULL,        --科目方向 1 借 2 贷
	[bz][int] null,             --币种
	[hl][decimal](25, 12) null,   --汇率
	[moneytext] [nvarchar](200) null,--金额字段中文替代
	[money1] [decimal](25, 12) null,    --原币金额
	[money_J] [decimal](25, 12) null,  --借方金额
	[money_D] [decimal](25, 12) null,  --贷方金额
	[FlowSubject] [int] null ,       --现金流量项目
    [rule] [int] null ,       --策略控制选择
	[del] [int] NULL, --删除
	[rowindex] [int] null,
    [Nums] [decimal](25, 12) null,
	[Price] [decimal](25, 12) null,
    [NumsText] [varchar](50) null,
    [Currency] [int] NULL default(1),
    [OriginalMxID] [int] NULL default(0),
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[f_VoucherListTemp_Enhance](
	[ID] [INT] IDENTITY(1,1) NOT NULL,
	[VoucherList] [INT] NOT NULL,
	[Condition] [INT] NOT NULL,
	[ConditionValue] [INT] NOT NULL,
    PRIMARY KEY CLUSTERED
    (
        [ID] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[f_VoucherAssistListTemp](
	[id] [INT] IDENTITY(1,1) NOT NULL,
	[Voucher] [INT] NULL,
	[VoucherList] [INT] NULL,
	[AssistSubject] [INT] NULL,
	[AssistText] [nvarchar](200) null,--辅助核算字段中文替代
	[AssistID] [INT] NULL,
	[del] [INT] NULL,
    [Unit] [INT] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]



GO

CREATE TABLE [dbo].[f_Voucher](
	[ord] [int] IDENTITY(1,1) NOT NULL,
	[VoucherWord][int] null,--凭证字
	[bh][int] null,--凭证编号
	[title][nvarchar](100)null,--凭证名称
	[voucherHSmonth] [datetime] null,--凭证所在核算月
	[date1][datetime] null,--凭证日期
	[sort][int]null,--类型  1 正常添加的凭证 2 期末调整汇率凭证 3 期末结转损益凭证 4 
	[addcate] [int] null ,--添加人
	[addtime] [datetime] null,--时间
	[cateid_sp] [int] null ,--审核人
	[sptime] [datetime] null,-- 审核时间
	[cateid_keep] [int] null ,--记账人
	[keeptime] [datetime] null,-- 记账时间
	[status] [int] null , --状态 0 未审核 1 未记账 2 已记账 3 已冲销
	[charge] [int] null,  --冲销ORD
	[del] [int] NULL, --删除
	[delcate] [int] NULL,
	[deltime] [datetime] NULL,
	[del2] [int] NULL,
	[upVoucher] [int] NULL,  --自动凭证标记 存数过程[erp_autoAddVoucher]调用
	[attach] [int] NULL, --附单据
	[uptime] [datetime] NULL,
	[upuser] [int] NULL,
	[upVoucherMerger] [nvarchar](max) NULL,
    PRIMARY KEY CLUSTERED
    (
        [ord] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]

--@##mode:index;clustered:false;fields:VoucherWord,voucherHSmonth,del;include:bh

GO

CREATE TABLE [dbo].[f_VoucherList](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Voucher] [int] null,--主单据
	[intro] [nvarchar](400) null,--摘要
	[AccountSubject] [int] null,--会计科目
	[isBWB][int] not null default(1),--记录是否本位币
	[bz][int] not null default(0),--币种
	[hl][decimal](25, 12) null,--汇率
	[money1][decimal](25, 12) null,--原币金额
	[money_J] [decimal](25, 12) null,--借方金额
	[money_D] [decimal](25, 12) null,--贷方金额
	[FlowSubject] [int] null ,--现金流量项目
	[del] [int] NULL, --删除
	rowindex int null,
    [Nums] [decimal](25, 12) null,
	[Price] [decimal](25, 12) null,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[f_VoucherAssistList](
	[id] [INT] IDENTITY(1,1) NOT NULL,
	[Voucher] [INT] NULL,
	[VoucherList] [INT] NULL,
	[AssistSubject] [INT] NULL,
	[AssistID] [INT] NULL,
	[del] [INT] NULL,
    [Unit] [INT] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[f_ExchangeRate](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Accountdate1] [datetime] null ,--会计期间
	[bz] [int] null,--币种
	[Adjhl] [decimal](25, 12) null,--调整汇率
	[addcate][int]null,
	[addtime][datetime] null,
	[del] [int] null,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[f_Report](
	[ord] [int] IDENTITY(1,1) NOT NULL,
	[bh] [varchar] (100) null,
	[title] [nvarchar](200) null,
	[abbreviated] [nvarchar](200) null, --简称
	[sourceSort] [int] null, --数据来源 1 会计科目余额 ,2 会计科目发生额 , 3, 现金流量项目
	[qcbody] [nvarchar](500) null,
	[stop] [int] null,
	[addcate] [int] null,
	[addtime] [datetime] null,
	[del] [int] null,
    PRIMARY KEY CLUSTERED
    (
        [ord] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[f_ReportHeaders](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Report] [int] null,
	[Groups] [int] null,
	[headerName] [nvarchar](200) null,
	[attribute] [int] null, --0非计算项 ,1 计算项 
	[gate1] [int] null, --重要指数
	[del] [int] null,
	[tempid] [int] null,
    [rowindex] [int] null,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[f_ReportCells](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[header] [int] null,
    [rowindex] [int] null,
	[body] [nvarchar](500) null,
	[del] [int] null,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

create table [dbo].[reminderConfigs](
	[id] int primary key,
	[name] nvarchar(50),--提醒名称
	[setjmId] int,--setjm表中的设置项id
	[mCondition] varchar(2000),--模块号和权限表达式（用来控制是否开启）
	[remindMode] varchar(20),--提醒模式 
	[lastReloadDate] datetime not null default(getdate()),--上次更新提醒的时间
	[qxlb] int, --提醒所属权限
	[listqx] int not null default 1,--列表权限（sort2)
	[detailqx] int not null default 14,--详情权限（sort1)
	[moreLinkUrl] varchar(300) not null,--更多链接地址
	[detailLinkUrl] varchar(300) not null,--详情链接地址
	[canCancel] bit not null default(1),--是否允许取消提醒（如果允许，则界面上显示取消按钮，否则不显示取消按钮）
	[jointly] bit not null default(0),--是否多人共享取消状态（如果是，则一人取消就全部取消）
	[canTQ] bit not null default(0),--是否能提前
	[fwSetting] varchar(500),--范围设置配置
	[orderBy] int,--排序条件（设置界面上的）
	[titleMaxLength] int not null default(0),--主题显示时的最大长度（超长的截断），0为不截断
	[subSql] varchar(1000) not null default(''),--取子提醒类型的sql语句
	[rType] int not null default(0),--提醒分类
	[MOrderSetting] int not null default(0), --关联生产框架中的OrderID
	[MBusinessType] varchar(20) not null default(''), --提醒类型，如审批(CHECK)，最新单据(NEW)等），被动模式使用，主要用于在生产框架中使用被动模式处理提醒
	[cacheExpiredCondition] varchar(2000), --用于判断缓存是否过期的条件
	[remindsql] varchar(4000), --用于提醒查询数据sql
	[NoCancelSql] varchar(4000), --用于不允许取消提醒sql
	[isStop] [int] NULL,		--是否停用
	[moreLinkUrl_mobile] varchar(300), --更多链接地址(移动端)
	[detailLinkUrl_mobile] varchar(300), --详情链接地址(移动端)
	[colCount] int not null default 2,--每行显示的列数(移动端)
)
--@##mode:index;clustered:false;fields:setjmId
--@##mode:index;clustered:false;fields:orderBy

GO

create table [dbo].[reminderTypes](
	id int identity(1,1) primary key,
	name varchar(50) not null,
	orderBy int not null default(0)
)

GO

create table [dbo].[reminderQueue](
	id bigint identity(1,1),
	reminderConfig int not null,--所属提醒配置，reminderConfigs.id
	subCfgId int not null default(0),--所属子配置id
	orderId int not null,--提醒关联单据id
	reloadFlag int not null default(0),--重置标记，当业务标记和此字段不同时需要清除reminderPersons中对应的取消记录
	daysFromNow int not null default(0),--距离当前日期相隔多少天
	orderStat int not null default(0),--单据状态，用来区分同ID单据的不同状态（如审批通过、待审批、审批退回等）
	otherInfo varchar(8000) not null default(0),--提醒的其他信息
	inDate datetime not null default(getdate()),--加入队列时间
)

--@##mode:index;clustered:true;fields:reminderConfig,subCfgId,orderId,inDate desc
--@##mode:index;clustered:false;fields:id
--@##mode:index;clustered:false;fields:reminderConfig,subCfgId,orderId

GO

create table [dbo].[reminderPersons](
	reminderId bigint, --提醒队列id，reminderQueue.id
	cateid int --提醒人员id，gate.ord
		PRIMARY KEY CLUSTERED
		(
			[reminderId] ASC,
			[cateid] ASC
		) ON [PRIMARY]
) ON [PRIMARY]

GO

create table [dbo].[reminderPersonsForMobPush](
	reminderId bigint, --提醒队列id，reminderQueue.id
	cateid int --提醒人员id，gate.ord
		PRIMARY KEY CLUSTERED
		(
			[reminderId] ASC,
			[cateid] ASC
		) ON [PRIMARY]
) ON [PRIMARY]

GO
--Attrs:帐套下可用
create table [dbo].[sys_upload_res](
	id int IDENTITY(1,1) NOT NULL, 
	source varchar(50) not null,
	id1 int not null,
	id2 int,
	id3 int,
	ftype varchar(100),
	fname varchar(300),
	fpath varchar(500),
	fsize int,
	fremark nvarchar(200),
	addcate int,
	addtime datetime
)	

GO

create table [dbo].[BHConfigs](
	id int primary key,--标识，对应zdybh表的sort1字段
	title varchar(100) not null,--业务名称
	bhTableName varchar(100) not null,--业务表名
	bhFieldName varchar(100) not null,--自动编号字段名
	dtFieldName varchar(100) not null,--添加时间字段明
	useTempRec bit not null default(1),--是否使用了临时记录（占位模式）
	idFieldName varchar(100) not null default(''),--标识列名称，主要用于在判重时排除本条记录
	exCondition varchar(200) not null default(''),--扩展判断条件
)

GO

create table [dbo].[BHTempTable](
	[xid] [bigint] IDENTITY(1,1) NOT NULL,
	[configId] [int] NOT NULL,--自动编号配置id，对应zdybh表的sort1字段
	[addCate] [int] NOT NULL,--使用自动编号功能的当前用户id
	[inDate] [datetime] NOT NULL,
	[returnBH] [nvarchar](200) NULL,
    PRIMARY KEY CLUSTERED
    (
        [xid] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]

--@##mode:index;clustered:false;fields:configId,addCate
--@##mode:index;clustered:false;fields:returnBH
--@##mode:index;clustered:false;fields:inDate

GO

CREATE TABLE [dbo].[C2_CodeItems](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ctype] [int] NULL,
	[source] [int] NULL,
	[sourceID] [int] NULL,
	[logo] [varchar](100) NULL,
	[bgcolor] [varchar](20) NULL,
	[color] [varchar](20) NULL,
	[errhandle] [int] NULL,
	[width] [int] NULL,
	[height] [int] NULL,
	[addcate] [int] NULL,
	[addtime] [datetime] NULL,
	[intro] [nvarchar](200) NULL,
	[del] [int] NULL,
	[delcate] [int] NULL,
	[deltime] [datetime] NULL,
	[editCate] [int] NULL,
	[editTime] [datetime] NULL,
	[billType] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]

--@##mode:index;clustered:true;fields:id
--@##mode:index;clustered:false;fields:ctype
--@##mode:index;clustered:false;fields:source
--@##mode:index;clustered:false;fields:sourceid
--@##mode:index;clustered:false;fields:del
--@##mode:index;clustered:false;fields:ctype,source,del;include:id,sourceID

GO

CREATE TABLE [dbo].[C2_CodeItemsFields](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[codeId] [int] NULL,
	[ftypeID] [int] NULL,
	[uName] [nvarchar](20) NULL,
	[uValue] [nvarchar](2000) NULL,
	[gate1] [int] NULL,
	[utype] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]

--@##mode:index;clustered:false;fields:codeid
--@##mode:index;clustered:false;fields:ftypeid
--@##mode:index;clustered:false;fields:utype

GO

CREATE TABLE [dbo].[C2_CodeTypeFields](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[cTypeId] [int] NULL,
	[uName] [nvarchar](20) NULL,
	[uType] [int] NULL,
	[stop] [int] NULL,
	[gate1] [int] NULL,
	[zdys] [varchar](800) NULL,
	[fieldName] [nvarchar](50) NULL,
	[oldName] [nvarchar](20) NULL,
    [isShow] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]

--@##mode:index;clustered:true;fields:id
--@##mode:index;clustered:false;fields:ctypeid
--@##mode:index;clustered:false;fields:utype
--@##mode:index;clustered:false;fields:stop

GO

CREATE TABLE [dbo].[C2_CodeTypes](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[title] [nvarchar](20) NULL,
	[gate1] [int] NULL,
	[stop] [int] NULL,
	[fromSys] [int] NULL,
	[entype] [int] NULL,
	[addcate] [int] NULL,
	[addtime] [datetime] NULL,
	[del] [int] NULL,
	[delcate] [int] NULL,
	[deltime] [datetime] NULL,
	[isAuto] [int] NULL,
	[logo] [nvarchar](100) NULL,
	[errhandle] [int] NULL,
	[picsize] [int] NULL,
	[color] [varchar](20) NULL,
    [bgcolor] [varchar](20) NULL,
    [billType][int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]

--@##mode:index;clustered:true;fields:id
--@##mode:index;clustered:false;fields:stop
--@##mode:index;clustered:false;fields:fromsys
--@##mode:index;clustered:false;fields:del

GO

--财务对接配置
CREATE TABLE [dbo].[f_abutment](
	id	[int] 	IDENTITY(1,1) NOT NULL,
	module [int] null , --对接数据模块 1 现金银行 2 开票 3 工资 4 费用
	sort1  [int] null ,--	module = 1  1 按银行账号汇总模式 2 按业务类型模式  module = 4  1 一级分类 2 一、二级分类
	sumtype [int] null ,--1 汇总 2 明细				
	date1	[datetime] null ,-- 设置时间
	cateid [int] null  --设置人员,
    PRIMARY KEY CLUSTERED
    (
        id ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

--财务对接科目配置
CREATE TABLE [dbo].[f_collocation](
	id	[int] 	IDENTITY(1,1) NOT NULL,
	abutment [int] null, --对接设置ID
	sort1 [int] null ,-- 1 按银行账号汇总模式 2 按业务类型模式 3 业务类型 4 开票 5 财务工资 6 人资工资  7 费用一级分类 8 费用二级分类
	ctype [int] null , --sort1 = 6 工资账套
	clsOrd [int] null , --sort1 = 1 2 银行 sort1 = 3 业务类型 sort1=4 票据类型 sort1 = 5 6 工资项目 7 一级分类 8 二级分类
	subject [int] null , --对应科目
	subject_extra [int] null , --sort1=4 税金科目
	subject1 [int] null , --对方科目-收
	direct [int] null , --对方科目方向 1 借 2 贷 
	VoucherWord1 [int] null , --凭证字-收
	intro1 [nvarchar](200) null, --摘要-收
	flow1 [int] null , --现金流量项目-收   ---分-
	subject2 [int] null , --对方科目-支
	VoucherWord2 [int] null , --凭证字-支
	intro2 [nvarchar](200) null, --摘要-支
	flow2 [int] null  --现金流量项目-支,
    PRIMARY KEY CLUSTERED
    (
        id ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

--财务对接关系数据表
CREATE TABLE [dbo].[collocation](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[sort1] [int] null ,-- 1 现金银行 2 开票 3 工资 4 费用
	[clstype] [int] null,
	[clsid] [int] NULL,
	[money1] [decimal](25, 12) null, --金额
	[erpOrd] [int] null , --业务ord
	[erpOrd_extra] [int] null , --业务扩展ord
	[erpcateid] [int] null ,--业务权限人员
	[voucher] [int] null , --凭证ord
	[cateid] [int] null, --凭证添加人员(业务关联需要查看权限控制)
	[account] [int] null , --账套ord
    [accountYear] [int] null,--帐套年
	[complete] [int] null, --生成状态(0 失败 1 完成) 历史数据固定完成
	[VTID] [int] null, --凭证模板f_VoucherTemp.ID
	[date1]	[datetime] null,--会计期间
	[intro] [nvarchar](500) null, --提示信息
	[creator] [int] null, --生成人员
	[indate] [datetime] null, --生成时间
	[isNeedUp] [int] NUll, --是否需要修改模板(1 需要 0 不需要)
	[del] [int] null --状态,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

--暂存数据表 [f_handlelist_temp]
CREATE TABLE [dbo].[f_handlelist_temp](
	id	[int] 	IDENTITY(1,1) NOT NULL,
	sort1 [int] null ,-- 1 审核
	voucher [int] null , --凭证ord
	addcate [int] null --操作人员,
    PRIMARY KEY CLUSTERED
    (
        id ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

--表更新状态表
create table [dbo].[sys_Table_TriggerEvents](
	[tbname] varchar(40),--表名
	[typeid] int,--更新类型(0 insert,1 update,2 delete,3 all
	[typetxt] varchar(10),--说明
	[lasttime] datetime --最后更新时间
)

GO

CREATE TABLE [dbo].[setopen](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[intro] [int] NULL DEFAULT (0),
	[sort1] [int] NULL,
	[extra] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


--@##mode:index;clustered:false;fields:sort1

GO

--财务对接业务数据快照--现金银行
CREATE TABLE [dbo].[account_snapshot_bank](
	id	[int] 	IDENTITY(1,1) NOT NULL,
	sort1 [int] null ,-- 1 现金银行 
	erpOrd [int] null , --业务ord
	erpOrd_extra [int] null , --业务扩展ord
	voucher [int] null , --凭证ord
	account [int] null , --账套ord
	date1 [datetime] null ,--日期  
	bank [int] null , --账户名称ord
	[money1] [decimal](25, 12) NOT NULL DEFAULT (0),--收入  
	[money2] [decimal](25, 12) NULL DEFAULT (0),--支出
	[intro] [nvarchar](50) NULL,--业务类型  
	cateid [int] null , --经手人  
	[glname] [nvarchar](200) NULL,--关联操作
	[gl] [int] null , --关联单据
	[sort] [int] null , --业务类型
	del [int] null --状态,
    PRIMARY KEY CLUSTERED
    (
        id ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

--财务对接业务数据快照--费用
CREATE TABLE [dbo].[account_snapshot_charge](
	id	[int] 	IDENTITY(1,1) NOT NULL,
	sort1 [int] null ,-- 4 费用 
	erpOrd [int] null , --业务ord
	erpOrd_extra [int] null , --业务扩展ord
	voucher [int] null , --凭证ord
	account [int] null , --账套ord	
	[bxbh] [nvarchar](200) NULL,--关联报销编号	
	[bxTitle] [nvarchar](200) NULL,--关联报销主题	
	[spdate] [datetime] null ,--审批日期  
	[bxdate] [datetime] null ,--报销日期  
	[czdate] [datetime] null ,--出账日期  
	[money1] [decimal](25, 12) NULL DEFAULT (0),--报销金额  
	[money2] [decimal](25, 12) NULL DEFAULT (0),--审批金额
	sort2 [int] null , --费用大类
	[sortTitle] [nvarchar](50) NULL,--费用分类  
	bz [int] null , --币种
	cateid [int] null , --报销人员 
	[intro] [ntext] NULL,	 --报销概要
	del [int] null --状态,
    PRIMARY KEY CLUSTERED
    (
        id ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

--财务对接业务数据快照--工资
CREATE TABLE [dbo].[account_snapshot_wage](
	id	[int] 	IDENTITY(1,1) NOT NULL,
	sort1 [int] null ,-- 3 工资 
	erpOrd [int] null , --业务ord
	erpOrd_extra [int] null , --业务扩展ord
	voucher [int] null , --凭证ord
	account [int] null , --账套ord	
	[gzTitle] [nvarchar](200) NULL,--关联工资单主题	
	[date2] [datetime] null ,--工资日期  
	[spdate] [datetime] null ,--审批日期  
	[salaryClass] [int] null , --工资帐套
	[ztTitle] [nvarchar](50) NULL,--工资帐套名称  
	[sortTitle] [nvarchar](50) NULL,--工资项目  
	bz [int] null , --币种
	[money1] [decimal](25, 12) NULL DEFAULT (0),--工资总额  	
	cateid [int] null , --经手人  		
	del [int] null --状态,
    PRIMARY KEY CLUSTERED
    (
        id ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

--财务对接业务数据快照--开票
CREATE TABLE [dbo].[account_snapshot_invoice](
	id	[int] 	IDENTITY(1,1) NOT NULL,
	sort1 [int] null ,-- 2 开票 
	erpOrd [int] null , --业务ord
	erpOrd_extra [int] null , --业务扩展ord
	voucher [int] null , --凭证ord
	account [int] null , --账套ord	
	[khOrd] [int] NULL,--客户ord，tel.ord	
	[khName] [nvarchar](200) NULL,--客户名称	
	[khbh] [nvarchar](200) NULL,--客户编号
	[invoiceMode] [int] NULL,--1:合并开票，2:明细开票
	[fromType] [nvarchar](50) NULL,--来源类型，CONTRACT、PREBACK、BEGINVOICE	
	[fromid] [int] NULL,--来源ord
	[fromTitle] [nvarchar](200) NULL,--来源主题	
	[frombh] [nvarchar](200) NULL,--来源编号
	[addcate] [int] NULL,--申请人员，gate.ord
	[date1] [datetime] null ,--计划开票日期  
	[invoicedate] [datetime] null ,--开票日期  
	[bz] [int] null , --币种
	[money1] [decimal](25, 12) NULL DEFAULT (0),--开票金额 
	[cateid] [int] null , --销售人员，gate.ord
	[invoicecate] [int] null , --开票人员，gate.ord
	[khcateid] [int] null , --客户销售人员，gate.ord
	[htcateid] [int] null , --合同销售人员，gate.ord
	[yfkcateid] [int] null , --预付款经手人，gate.ord
	[invoiceType] [int] null , --票据类型，gate2=34 and id1<>-65535 
	[invoiceNum] [nvarchar](100) NULL,--票据单号  
	[invoicely] [int] null , --票据来源，sortonehy.ord
	taxRate [decimal](25, 12) not null default 0,
	[title] [nvarchar](50) NULL,--发票抬头	
	[taxno] [nvarchar](50) NULL,--税号
	[addr] [nvarchar](50) NULL,--公司地址
	[phone] [nvarchar](50) NULL,--公司电话
	[bank] [nvarchar](50) NULL,--开户行
	[bankAccount] [nvarchar](50) NULL,--开户行账号
	[intro] [nvarchar](500) null,	--开票备注
	del [int] null --状态,
    PRIMARY KEY CLUSTERED
    (
        id ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

--财务对接业务数据快照--开票明细
CREATE TABLE [dbo].[account_snapshot_invoice_list](
	id	[int] 	IDENTITY(1,1) NOT NULL,
	sort1 [int] null ,-- 2 开票 
	erpOrd [int] null , --业务ord
	erpOrd_extra [int] null , --业务扩展ord
	voucher [int] null , --凭证ord
	account [int] null , --账套ord	
	[product] [int] NULL,--产品ord，product.ord	
	[cpName] [nvarchar](200) NULL,--产品名称	
	[cpbh] [nvarchar](200) NULL,--产品编号
	[cptype] [nvarchar](200) NULL,--产品型号
	[unit] [int] NULL,--单位ord，sortonehy.ord
	contractlist int not null,--合同明细id
	money1 [decimal](25, 12) NOT NULL DEFAULT(0),--开票金额
	num1 [decimal](25, 12) NOT NULL DEFAULT(0),--产品数量	
	taxRate [decimal](25, 12) not null default 0,
	del [int] null --状态,
    PRIMARY KEY CLUSTERED
    (
        id ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[wageslist_bonus](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[cateid] [int] NULL,
	[money1] [decimal](25, 12) NULL,
	[addcate] [int] NULL,
	[addtime] [datetime] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[erp_home_scjlist](
	id int IDENTITY(1,1) NOT NULL,
	urlid int,
	title nvarchar(100),
	cateid int,
	gate1 int
)

GO

CREATE TABLE [dbo].[Browse_Records](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NULL,
	[sorceID] [int] NULL,
	[readDate] [datetime] NULL,
	[sort1] [char](30) NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[reminderInterface](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NULL,
	[cateid] [int] NULL,
	[stop] [int] NULL,
	[gate2] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]

--@##mode:index;clustered:false;fields:cateid
--@##mode:index;clustered:false;fields:gate2

GO

CREATE TABLE [dbo].[GPS_Lines](
	[ord] [int] IDENTITY(1,1) NOT NULL,
	[cateid] [int] NULL,
	[macsn] [varchar](50) NULL,
	[startDate] [datetime] NULL,
	[endDate] [datetime] NULL,
	[del] [int] NULL DEFAULT(1),
	[delcate] [int] NULL,
	[daldate] [datetime] NULL,
	[PrevData] [int] NULL DEFAULT(0),
	[StartAddr] [varchar](500) NULL,
	[endAddr] [varchar](500) NULL,
	[fileName] [nvarchar](50) NULL,
	[endImgPath] [nvarchar](500) NULL,
	PRIMARY KEY CLUSTERED
	(
		[ord] ASC
	) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[mobile_contractlist](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[checked] int not null default(1),
	[ord] [int] NULL,
	[contract] [int] NULL,
	[num1] [decimal](25, 12) NOT NULL DEFAULT (0),
    [pricejy] [decimal](25, 12) NOT null default (0),
    [tpricejy] [decimal](25, 12) NOT null default (0),
    [price1] [decimal](25, 12) NOT NULL DEFAULT (0),
    [discount] [decimal](25, 12) NULL DEFAULT 1, --折扣
	[priceAfterDiscount] [decimal](25, 12) NOT NULL default 0,--折后单价
    [moneyBeforeTax] [decimal](25, 12) NOT NULL default(0),--税前总额
	[invoiceType] int NULL default 0, --票据类型
	[taxRate] [decimal](25, 12) NULL default 0, --税率，数值来自票据类型设置表
    [priceIncludeTax] [decimal](25, 12) NOT NULL DEFAULT (0),--含税单价
    [PriceAfterTaxPre] [decimal](25, 12) NOT NULL default(0),
    [moneyAfterTax] [decimal](25, 12) NOT NULL default(0),--税后总额
	[concessions] [decimal](25, 12) NOT NULL default 0, --优惠金额
	[priceAfterTax] [decimal](25, 12) NOT NULL default(0),--优惠后单价
    [moneyAfterConcessions] [decimal](25, 12) NULL default(0), --金额
    [taxValue] [decimal](25, 12) NOT NULL DEFAULT(0),--税额
	[money1] [decimal](25, 12) NOT NULL DEFAULT (0), --优惠后总价
    [extras] [decimal](25, 12) NULL default 0, --运杂费
	[addcate] [int] NULL,
	[date7] [datetime] NULL,
	[intro] [nvarchar](200) NULL,
	[unit] [int] NOT null default (0),
    [commUnitAttr] [NVARCHAR](200) NULL,
	[date2] [datetime] NULL,
	[zdy1] [nvarchar](200) NULL,
	[zdy2] [nvarchar](200) NULL,
	[zdy3] [nvarchar](200) NULL,
	[zdy4] [nvarchar](200) NULL,
	[zdy5] [int] NULL,
	[zdy6] [int] NULL,
	[jf] [decimal](25, 12) NULL,
	[jf_per_num] [decimal](25, 12) NULL, --单个产品的积分（用于+-运算时计算使用）
	[repairNewPartsId] [int] NULL,
    [ProductAttr1] int null,
	[ProductAttr2] int null,
	[ProductAttrBatchId] int null,
    [TreeOrd] int null,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


--@##mode:index;clustered:false;fields:ord,id
--@##mode:index;clustered:false;fields:id,num1
--@##mode:index;clustered:false;fields:id,unit
--@##mode:index;clustered:false;fields:addcate
--@##mode:index;clustered:false;fields:unit,ord,addcate,date7 desc
--@##mode:index;clustered:false;fields:unit,ord,date7 desc

GO

create table [dbo].[__erp_tmp_ck1_sel2](
	i int, 
	id int ,
	sort1 varchar(500),
	parentid int , 
	leef int , 
	depth int,
	gate1 int, 
	uid int,
	del int
) ON [PRIMARY]

GO

create table [dbo].[__erp_tmp_ck_sel](
	i int,
	ord int, 
	sort1 varchar(500), 
	gate1 int, 
	sort int, 
	uid int
) ON [PRIMARY]

GO

create table [dbo].[__erp_tmp_ck1_sel](
	i int, 
	id int ,
	sort1 varchar(500),
	parentid int , 
	leef int , 
	depth int,
	gate1 int, 
	uid int
) ON [PRIMARY]

GO

----listview组件的用户配置----path[当前页网址]---lvwid[列表组件的id]---uid[用户id]---colname[列名称]---attrn[列属性]---attrv[列值]---fieldname[字段名称]
--Attrs:帐套下可用
CREATE TABLE [dbo].[erp_sys_listviewConfig](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[path] [varchar](100) COLLATE Chinese_PRC_CI_AS NULL,
	[lvwid] [varchar](300) COLLATE Chinese_PRC_CI_AS NULL,
	[uid] [int] NOT NULL,
	[colname] [nvarchar](50) COLLATE Chinese_PRC_CI_AS NULL,
	[attrn] [varchar](50) COLLATE Chinese_PRC_CI_AS NULL,
	[attrv] [varchar](50) COLLATE Chinese_PRC_CI_AS NULL,
	[fieldname] [varchar](50) COLLATE Chinese_PRC_CI_AS NULL,
 PRIMARY KEY CLUSTERED
(
	[id] ASC,
	[uid] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO

--微信帐号表
create table [dbo].[MMsg_User](
	id int identity(1,1) primary key,
	accId int,--公众号id，对应MMsg_Config.id
	openId varchar(100), --微信用户的openId
	nickName nvarchar(100),--微信用户昵称
	sex int,--性别
	country nvarchar(100),--国家
	province nvarchar(100),--省份
	city nvarchar(100),--城市
	language varchar(50),--语言
	headimgurl varchar(1000),--头像url
	headimgPath varchar(100),--头像图片存到本地的路径
	subscribe_time datetime,--关注时间
	unsubscribe_time datetime,--取消关注时间
	CreateTime datetime,--创建时间
	person int,--绑定的联系人id
	bindTime datetime,--绑定联系人的时间
	subscribe_stat int not null default(1),--关注状态（已关注，取消关注）
	stat int,--状态（正常、废止）
	reason nvarchar(500),--作废原因
	groupId int,--所属分组id
	cateid int,--微信帐号对应的处理人员
	leader int,--处理人对应的指派人员
	orderTime datetime,--指派时间
	allocTime datetime,--分配时间
	mobile varchar(50),--绑定手机号码
)

GO

--分组表
create table [dbo].[MMsg_Group](
	id int primary key,
	name varchar(100), --分组名称
)

GO

--配置表（记录公众号相关设置）
create table [dbo].[MMsg_Config](
	id int primary key,
	openId nvarchar(100), --公众号的openId
	openName nvarchar(100),--公众号名称
	accType int,--公众号的类型（2:订阅号、1:服务号等）
	Verify int,--认证状态（1:已认证、0:未认证）
	appId nvarchar(50),--高级接口 AppId
	Appsecret nvarchar(50), --高级接口 Appsecret
	token nvarchar(50),--用于接收微信通知消息的令牌，由用户填写，需将此令牌复制到微信平台上，才可接收到微信通知消息
	Access_token nvarchar(200),--用于调用微信接口的令牌，可从微信接口获取，有效时间为2小时
	token_time datetime,--上次获取Access_token的时间
	Expires_In int,--Access_token的过期时长，单位秒
	hostname nvarchar(100),--服务器域名
	VirFolder nvarchar(100),--虚拟目录名
	customMenu ntext,--保存自定义菜单设置的json串
)

GO

--微信消息表
create table [dbo].[MMsg_Message](
	id int identity(1,1) primary key,
	sendOrReceive int not null,--2:发送,1:接收
	accId int,--公众号id，对应MMsg_Config.id
	userId int,--微信用户id，MMsg_User.id
	CreateTime int,--消息创建时间
	MsgType varchar(50),--消息类型(text,image,voice,video,shortvideo,location,link)
	Content ntext,--消息内容
	PicUrl varchar(500),--图片消息时，图片的url
	MediaId varchar(100),--媒体资源id，可调用微信接口下载对应资源
	MediaPath varchar(200),--存到本地的多媒体资源路径
	Format varchar(50),--媒体资源格式
	Recognition nvarchar(200),--语音识别时，微信平台返回的识别结果
	ThumbMediaId varchar(100),--缩略图资源id，可调用微信接口下载对应资源，当MsgType是video或shortvideo时使用
	Location_X [decimal](25, 12), --地理位置纬度
	Location_Y [decimal](25, 12), --地理位置经度
	Scale [decimal](25, 12),--地图缩放大小
	Label nvarchar(200),--地理位置信息
	Title nvarchar(200),--消息标题
	Description nvarchar(1024),--消息描述
	Url varchar(500),--消息链接
	MsgId bigint,--消息id
	readed int not null default(0),--是否已读，默认是0，当打开微信用户详情时，如果当前用户是领用人，则更新为1
	cateid int null,--发送消息时，发消息的人员id
	timeFlag int not null default(0),	-- 标记时间节点 值为1则显示时间节点
)
--@##mode:index;clustered:true;fields:id
--@##mode:index;clustered:false;fields:sendOrReceive,userId
--@##mode:index;clustered:false;fields:sendOrReceive,readed;include:userId,CreateTime
--@##mode:index;clustered:false;fields:sendOrReceive;include:userId,CreateTime
--@##mode:index;clustered:false;fields:MsgId

GO

--微信自定义菜单表
create table [dbo].[MMsg_Menu](
	id int identity(1,1) primary key,
	name nvarchar(20),--菜单显示名称
	pid int not null default(0),--上级菜单id
	actType varchar(20),--命令类型（click,view)
	Keyword varchar(50),--菜单项对应的关键字（主要用于服务端处理自动回复）
	url varchar(300),--类型为view时，对应打开的网址
	sort int,--排序字段
)

GO

--分配策略表
create table [dbo].[MMsg_AllocTactics](
	id int primary key,
	name nvarchar(20),
	allocRule int not null,--分配规则（1：所有岗位人员按1:1比例分配，2：设置不同岗位的人员分配比例）
	cycleUnit int not null,--循环周期(1：日，2：周，3：月)
	canSetRule bit not null default(1),--是否显示分配规则
	curLoopNum int not null default(0),--当前分配轮次
	canSelectCate bit not null default(0),--是可选择处理人
	cateid int not null,--处理人
)

GO

--当前分配轮次表
create table [dbo].[MMsg_AllocLoops](
	id int identity(1,1) primary key,
	userid int not null,--参与分配的人员id
	tacticsId int not null,--策略表id，MMsg_AllocTactics.id
	loopNum int not null default(0),--当前分配的轮次
)

GO

--岗位比例设置表
create table [dbo].[MMsg_AllocRates](
	id int identity(1,1) primary key,
	tacticsId int not null,--岗位分配比例所属策略（1：微信用户，2：售后，3：建议，4：投诉）
	position int not null,--岗位id对应sortonehy.id
	rateValue int not null,--岗位比例
	isStop int not null default(0),--是否已停用
)

GO

CREATE TABLE [dbo].[M_ManuCostlist](
	[molistid] [int] NOT NULL,
	[BOMListID] [int] NULL,
	[srcID] [int] NOT NULL,
	[srcType] [varchar](4) NOT NULL,
	[srcTypeID] [int] NOT NULL,
	[billid] [int] NULL,
	[llmoney] [decimal](25, 12) NULL,
	[lljtmoney] [decimal](25, 12) NULL,
	[blmoney] [decimal](25, 12) NULL,
	[bljtmoney] [decimal](25, 12) NULL,
	[tlmoney] [decimal](25, 12) NULL,
	[tljtmoney] [decimal](25, 12) NULL,
	[drmoney] [decimal](25, 12) NULL,
	[dcmoney] [decimal](25, 12) NULL,
	[jjmoney] [decimal](25, 12) NULL,
	[wwmoney] [decimal](25, 12) NULL,
	[fymoney] [decimal](25, 12) NULL,
	[sbmoney] [decimal](25, 12) NULL,
	[allmoney] [decimal](25, 12) NULL,
	[allnum] [decimal](25, 12) NULL,
	[unitpric] [decimal](25, 12) NULL,
	[lvw_treenodedeep] [int] NULL,
	[indate] [datetime] NOT NULL,
	[autoindex] [int]  NOT NULL
) ON [PRIMARY]

GO

--商城首页分组配置表
CREATE TABLE [dbo].[Shop_HomeGroups](
	id int identity(1,1) primary key,
	[type] varchar(10) not null,--分组类型，取值范围：BANNER,OTHER
	name nvarchar(20),--分组名称
	sort int not null,--分组排序序号
)

GO

--商城首页分组内容配置表
CREATE TABLE [dbo].[Shop_HomeGroupItems]( --商城首页分组内容配置表
	id int identity(1,1) primary key,
	groupId int,--所属分组id
	source int,--内容来源id，可来自图片或商品，来自图片时关联Shop_Resources.id,来自商品时关联Shop_Goods.id
	link varchar(500),--链接地址
	sort int not null,--排序序号
)

GO

CREATE TABLE [dbo].[Shop_Goods]( --商品表
	id int identity(1,1) primary key,
	bh varchar(50),
	product int not null,--关联产品
	name nvarchar(100),--商品名称
	adWord nvarchar(100),--广告语
	sortonehy int not null,--所属分类,sortonehy.id
	sort int not null,--排序字段(重要指数),影响移动端显示顺序，不影响pc端列表的显示顺序
	unit int not null,--单位，来自product.unit中的某一个
	price1 [decimal](25, 12) not null,--商品售价
	bz int not null default(14),--币种，目前默认人民币
	intro3 ntext,--商品介绍,对应product.intro3 即：图片与附件
	intro2 ntext,--规格参数,对应product.intro2 即：产品参数
	intro1 ntext,--包装售后,对应product.intro1 即：产品说明
	onSale int not null default(0),--上架状态
	onSaleAfter datetime null,--定时上架时间，非空时，需通过该字段与当前时间的比较结果来确定商品是否上架 onSale=1 or datediff(s,isnull(onSaleAfter,'1970-01-01'),getdate())>=0
	del int not null default(1),--删除状态
	delcate int,
	deltime datetime,
	creator int,
	createtime datetime,
	clickTimes int not null default(0),
)

GO

--商品库存登记表（由商品添加和追加操作产生，负数也记，初次入库也要在这里登记）
create table [dbo].[Shop_StorageAppendLog](
	id int identity(1,1) primary key,
	goodsId int not null,--商品id
	num1 [decimal](25, 12),--追加数量
	contractlist int,--关联合同明细（如果是由商品销售导致的库存减少，此字段需要记录合同明细id）
	creator int not null,--操作人(如果是商品销售导致库存减少，此字段记录的是微信用户id）
	createtime datetime not null,--操作时间
)

GO

--购物车
create table [dbo].[Shop_Cars](
	id int identity(1,1) primary key,
	goodsId int not null,--商品id
	mUserId int not null,--微信用户id
	checked int not null,--是否选中（选中的在结算时会加入订单）
	num1 [decimal](25, 12),--购买数量
	createtime datetime not null,--加入购入车时间
)

GO

--商品属性表
CREATE TABLE [dbo].[Shop_GoodsAttr](
	id [INT] NOT NULL PRIMARY KEY IDENTITY(1,1),
	pid [INT] NOT NULL,
	proCategory [INT] NOT NULL,
	title [NVARCHAR] (50),
	sort [INT] DEFAULT(1),
	isStop [INT] DEFAULT(0),
    isTiled [int] NULL
)

GO

--商品属性值表
CREATE TABLE [dbo].[Shop_GoodsAttrValue](
	id [INT] NOT NULL PRIMARY KEY IDENTITY(1,1),
	attrID [INT] NOT NULL,
	degreeID [INT] NOT NULL,
	attrVal [NVARCHAR] (50),
	goodsID [INT] NOT NULL DEFAULT(0),
	proID [INT] NOT NULL DEFAULT(0)
)

GO

CREATE TABLE [dbo].[BOM_Structure_Info](			--组装清单（增强）基础信息表
	[ord] [int] IDENTITY(1,1) NOT NULL,
	[title] [nvarchar](100) NULL,					--标题
	[BBH] [nvarchar](25) NULL,						--版本号
	[BH] [nvarchar](50) NULL,						--编号
	[addDate] [datetime] NULL,						--添加日期
	[sxDate] [datetime] NULL,						--生效日期
	[zfDate] [datetime] NULL,						--作废日期
	[addCate] [int] NULL,							--添加人
	[date1] [datetime] NULL,						--单据添加时间
	[del] [int] NULL,								--是否删除
	[delDate] [datetime] NULL,						--删除时间
	[delCate] [int] NULL,							--删除人
	[sp] [int] NULL,								--审批阶段
	[cateid_sp] [int] NULL,							--当前审批人
	[status_sp] [int] NULL,							--审批状态
	[zdy1] [nvarchar](400) NULL,
	[zdy2] [nvarchar](400) NULL,
	[zdy3] [nvarchar](400) NULL,
	[zdy4] [nvarchar](400) NULL,
	[zdy5] [int] NULL,
	[zdy6] [int] NULL,
	[ismain] [int] NULL,							--是否是主BOM,1=是，2=否
	[ProOrd] [int] NULL,							--父件ord
	[pType] [int] NULL,								--父件类型，0 = 虚拟，1=实体产品
	[remark] [nvarchar](4000) NULL,					--备注
	PRIMARY KEY NONCLUSTERED
	(
		[ord] ASC
	) ON [PRIMARY]
) 

GO

CREATE TABLE [dbo].[BOM_Structure_List](		--组装清单（增强）明细信息表
	[ord] [int] IDENTITY(1,1) NOT NULL,
	[bomOrd] [int] NULL,						--组装清单ord
	[ProOrd] [int] NULL,						--产品ord
	[ProType] [int] NULL,						--产品类型，0 = 虚拟，1=实体产品
	[isMain] [int] NULL,						--是否是父件，1=是，0=否
	[unit] [int] NULL,							--单位
	[num] [decimal](25, 12) NULL,				--数量
	[sType] [int] NULL,							--产品结构类型
	[sCode] [int] NULL,							--产品结构编码
	[sProType] [int] NULL,						--子件类型，0=固定，1=单选，2=复选
	[notNull] [int] NULL,						--是否必选，1=是，0=否
	[canEdit] [int] NULL,						--是否可编辑，1=是，0=否
	[del] [int] NULL,							--是否删除
	[delCate] [int] NULL,						--删除人
	[delDate] [datetime] NULL,					--删除时间
	[addCate] [int] NULL,						--添加人
	[addDate] [datetime] NULL,					--添加时间
	includeTax	 int  NULL,
	PriceXS	[decimal](25, 12)  NULL,
	PriceBZ	[decimal](25, 12)  NULL,
	PriceJY	[decimal](25, 12)  NULL,
    [ProductAttr1] [int] NULL,
    [ProductAttr2] [int] NULL,
    [ProductAttrBatchId] [int] NULL,
	PRIMARY KEY NONCLUSTERED
	(
		[ord] ASC
	) ON [PRIMARY]
) 

GO

CREATE TABLE [dbo].[Bom_ProName](			--组装清单（增强）虚拟产品名称表
	[ord] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](25) NULL,				--名称
	[gate1] [int] NULL,						--重要程度
	[addCate] [int] NULL,					--添加人
	[addDate] [datetime] NULL,				--添加时间
	PRIMARY KEY NONCLUSTERED
	(
		[ord] ASC
	) ON [PRIMARY]
)

GO

CREATE TABLE [dbo].[Bom_Code](				--组装清单（增强）结构类型和结构编码表
	[ord] [int] IDENTITY(1,1) NOT NULL,
	[title] [nvarchar](50) NULL,			--标题
	[isMain] [int] NULL,					--是否是结构类型；1=结构类型，0=结构编码
	[gate1] [int] NULL,						--重要程度
	[p_Ord] [int] NULL,						--结构类型ord，仅ismain = 0 时有值
	[addCate] [int] NULL,					--添加人
	[addDate] [datetime] NULL,				--添加时间
	PRIMARY KEY NONCLUSTERED
	(
		[ord] ASC
	) ON [PRIMARY]
) 

GO

CREATE TABLE [dbo].[BOM_Packaging_Info](		--组装（增强）基础信息表
	[ord] [int] IDENTITY(1,1) NOT NULL,
	[title] [nvarchar](100) NULL,
	[BH] [nvarchar](50) NULL,
	[status] [int] NULL,
	[date1] [datetime] NULL,
	[addcate] [int] NULL,
	[addDate] [datetime] NULL,
	[remark] [nvarchar](500) NULL,
	[del] [int] NULL,
	[delDate] [datetime] NULL,
	[delCate] [int] NULL,
	PRIMARY KEY NONCLUSTERED
	(
		[ord] ASC
	) ON [PRIMARY]
) 

GO

CREATE TABLE [dbo].[BOM_Packaging_List](		--组装（增强）明细信息表
	[ord] [int] IDENTITY(1,1) NOT NULL,
	[pckOrd] [int] NULL,
	[proOrd] [int] NULL,
	[num1] [decimal](25, 12) NULL,
	[unit] [int] NULL,
	[price1] [decimal](25, 12) NULL,
	[money1] [decimal](25, 12) NULL,
	[ku] [int] NULL,
	[PH] [nvarchar](50) NULL,
	[XLH] [nvarchar](100) NULL,
	[scDate] [datetime] NULL,
	[yxDate] [datetime] NULL,
	[bz] [int] NULL,
	[addcate] [int] NULL,
	[addDate] [datetime] NULL,
	[del] [int] NULL,
	[delDate] [datetime] NULL,
	[delCate] [int] NULL,
	PRIMARY KEY NONCLUSTERED
	(
		[ord] ASC
	) ON [PRIMARY]
) 

GO

CREATE TABLE [dbo].[market_compare_area](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[uid] [int] NULL,
	[deep] [int] NULL,
	[isshow] [int] NULL,
	[name] [nvarchar](100) NULL,
	[date7] [datetime] NULL,
	PRIMARY KEY NONCLUSTERED
	(
		[id] ASC
	) ON [PRIMARY]
) 

GO

CREATE TABLE [dbo].[Bom_Trees](							--组装清单（增强）树形预览快照信息
	[ord] [int] IDENTITY(1,1) NOT NULL,
	[tType] [int] NULL,									--预览类型，0=预览，1=组装，2=合同,3=报价，4=出库
	[topid] [int] NULL,
	[mxid] [int] NULL,
	[listOrd] [int] NULL,								--明细ORD
	[bomOrd] [int] NULL,								--组装清单ord
	[proOrd] [int] NULL,								--产品ORD
	[unit] [int] NULL,
	[del] [int] NULL,									--是否删除
	[addCate] [int] NULL,								--添加人
	[addDate] [datetime] NULL,							--添加时间
	[remark] [nvarchar](200) NULL,						--备注
	[num1] [decimal](25, 12) NULL,						--对应明细数量，用于库存查看时，计算子件数量
	[mark] varchar(36) NULL
	PRIMARY KEY NONCLUSTERED
	(
		[ord] ASC
	) ON [PRIMARY]
)

GO

CREATE TABLE [dbo].[Bom_ShowStore](						--组装清单（增强）显示库存临时表
	[id] [int] IDENTITY(1,1) NOT NULL,
	[bom_snid] [int] NULL,								--关联BOM_Structure_List.ord
	[num1] [decimal](25, 12) NULL,						--节点实际数量
	[addCate] [int] NULL,								--添加人id
	[stype] [int] NULL,									--分类，默认1
	[treeord] [int] NULL,								--关联bom_trees.ord
	PRIMARY KEY NONCLUSTERED
	(
		[id] ASC
	) ON [PRIMARY]
)

GO

CREATE TABLE [dbo].[Bom_snapshot_List](					--组装清单（增强）明细信息快照
	[ord] [int] IDENTITY(1,1) NOT NULL,
	[treeOrd] [int] NULL,								--树ORD
	[bomOrd] [int] NULL,								--组装清单ORD
	[bl_ord] [int] NULL,								--组装清单明细ORD，关联BOM_Structure_List.ord
	[proOrd] [int] NULL,								--产品ORD
	[proType] [int] NULL,								--产品类型，0 = 虚拟，1=实体产品
	[isMain] [int] NULL,								--是否是主BOM
	[num] [decimal](25, 12) NULL,						--数量
	[num1] [decimal](25, 12) NULL,						--根据树生成的实际数量
	[unit] [int] NULL,									--单位
	[unitText] [nvarchar](100) NULL,					--单位文本
	[sType] [int] NULL,									--结构类型
	[sTypeText] [nvarchar](50) NULL,					--结构类型文本
	[sCode] [int] NULL,									--结构编码
	[sCodeText] [nvarchar](50) NULL,					--结构编码文本
	[sProType] [int] NULL,								--子件类型，0=固定，1=单选，2=复选
	[sProTypeText] [nvarchar](50) NULL,
	[notNull] [int] NULL,								--是否必选
	[canEdit] [int] NULL,								--是否可编辑
	[del] [int] NULL,									--删除
	[addCate] [int] NULL,								--添加人
	[addDate] [datetime] NULL,							--添加时间
	[treeCode] [varchar](4000) NULL,					--树结构编码
	[selected] [int] NULL,								--节点是否被选中，proType = 0 时，selected === 0；proType = 1 或 2，selected：1 = 选中
	[isfinal] [int] NULL,								--是否是最终产品
	[id] [int] NULL,
	[pid] [int] NULL,
	[isShowStore] [int] NULL,							--是否是库存查看项
	includeTax  int NULL,
	SL	[decimal](25, 12) NULL,
	PriceXS	[decimal](25, 12) NULL,
	PriceBZ	[decimal](25, 12) NULL,
	PriceJY	[decimal](25, 12) NULL,
	[ProductAttr1] [int] NULL,	                --产品属性1
	[ProductAttr2] [int] NULL,              	--产品属性2
	[ProductAttrBatchId] [int] NULL,	        --产品属性波次ID
	[mark] varchar(36) NULL
	PRIMARY KEY NONCLUSTERED
	(
		[ord] ASC
	) ON [PRIMARY]
)

GO

CREATE TABLE [dbo].[Bom_snapshot_Info](			--组装清单（增强）基础信息快照
	[ord] [int] IDENTITY(1,1) NOT NULL,
	[treeOrd] [int] NULL,						--树ord
	[bomOrd] [int] NULL,						--bomord
	[title] [nvarchar](100) NULL,				--标题
	[BBH] [nvarchar](25) NULL,					--版本号
	[BH] [nvarchar](50) NULL,					--编号
	[sxDate] [datetime] NULL,					--生效时间
	[zfDate] [datetime] NULL,					--作废时间
	[addCate] [int] NULL,						--添加人
	[addDate] [datetime] NULL,					--添加时间
	[del] [int] NULL,							--是否删除
	[zdy1] [nvarchar](400) NULL,
	[zdy2] [nvarchar](400) NULL,
	[zdy3] [nvarchar](400) NULL,
	[zdy4] [nvarchar](400) NULL,
	[zdy5] [nvarchar](400) NULL,
	[zdy6] [nvarchar](400) NULL,
	[treeCode] [varchar](4000) NULL,			--树结构编码
	[proOrd] [int] NULL,						--产品ord
	[proType] [int] NULL,						--产品类型
	[id] [int] NULL,
	[pid] [int] NULL,
	[ProductAttr1] [int] NULL,	                --产品属性1
	[ProductAttr2] [int] NULL,              	--产品属性2
	[ProductAttrBatchId] [int] NULL,	        --产品属性波次ID
	[mark] varchar(36) NULL
	PRIMARY KEY NONCLUSTERED
	(
		[ord] ASC
	) ON [PRIMARY]
)

GO

CREATE TABLE [dbo].[DeliveryAddress](
	id int identity(1,1) primary key,
	company int null,--关联客户 
	person int null,--关联联系人，person.ord
	wxUserId int not null,--关联微信用户
	receiver nvarchar(50),--收货人
	phone nvarchar(50),--固话
	mobile nvarchar(50),--手机
	address nvarchar(200),--地址
	zip nvarchar(50),--邮编
	fromWX int not null,--是否来自微信（由用户自己填写的）
	isDefault int not null default(0),--是否是默认收货地址
	createtime datetime not null,--创建时间
	isTelDefault int not null default(0),--是否是客户默认发货地址（PC端）
	isPersonDefault int not null default(0),--是否是联系人默认发货地址（PC端）
	showOnPc int not null default(1),--是否显示（PC端）
	[areaId][int],--地址，关联manuarea.id
)

GO

CREATE TABLE [dbo].[Shop_Payments](
	id int not null primary key,
	payKind int not null,--支付形式（2货到付款，1在线支付）
	name nvarchar(50), --支付方式名称
	merchant varchar(50),--商户号
	mKey varchar(500),--商户密钥
	bank int,--收款银行
	tag varchar(20),--支付方式标志
	state int,--是否启用
	gate1 int not null,--排序
)

GO

CREATE TABLE [dbo].[Shop_PayKinds](
	id int not null primary key,
	name nvarchar(50),--支付形式名称
	gate1 int not null,--排序
)

GO

CREATE TABLE [dbo].[bom_subProList](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[treeOrd] [int] NULL,
	[billOrd] [int] NULL,
	[sort1] [int] NULL,
	[listOrd] [int] NULL,
	[proOrd] [int] NULL,
	[unit] [int] NULL,
	[num1] [decimal](25, 12) NULL,
	[includeTax] [int] NULL,
	[price1] [decimal](25, 12) NULL,
	[money1] [decimal](25, 12) NULL,
	[ck] [int] NULL,
	[PH] [nvarchar](50) NULL,
	[xlh] [nvarchar](100) NULL,
	[dateSC] [datetime] NULL,
	[dateYX] [datetime] NULL,
	[bz] [int] NULL,
	[js] [nvarchar](50) NULL,
	[addDate] [datetime] NULL,
	[addCate] [int] NULL,
	[zdy1] [nvarchar](200) NULL,
	[zdy2] [nvarchar](200) NULL,
	[zdy3] [nvarchar](200) NULL,
	[zdy4] [nvarchar](200) NULL,
	[zdy5] [int] NULL,
	[zdy6] [int] NULL,
    [ProductAttr1] int null,
	[ProductAttr2] int null,
	PRIMARY KEY NONCLUSTERED
	(
		[id] ASC
	) ON [PRIMARY]
)

GO

CREATE TABLE [dbo].[Shop_VisitAnalyse](
	id int identity(1,1) not null primary key,
	goodsId int,--浏览的商品id
	wxUserId int,--当前微信用户id
	viewTime datetime,
	category int,--商品所属分类id
	ip varchar(20),
	browser varchar(1000),
)

GO

CREATE TABLE [dbo].[Design](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[PrefixCode] [nvarchar](50) NULL, --设计Code
	[title] [nvarchar](200) NULL, --设计主题
	[DesignBH] [nvarchar](100) NULL,--设计编号
	[designer] [int] NULL,--设计师
	[date3] [datetime] NULL,--领用日期
	[apply] [int] NULL , --申请人员 
	[applytime] [datetime] NULL , --申请时间
	[appoint] [int] NULL ,--指派人员
	[date4] [datetime] NULL ,--指派时间
	[abandon] [int] NULL , --放弃人员
	[abandontime] [datetime] NULL , --放弃时间
	[abandonintro] [varchar](4000) NULL , --放弃原因
	[sort1] [int] NULL,--设计分类
	[level] [int] NULL,--设计等级
	[plandate1] [datetime] NULL,--计划开始日期
	[plandate2] [datetime] NULL,--计划截止日期
	[startDate] [datetime] NULL,--设计启动时间
	[endDate] [datetime] NULL,	--设计结束时间
	[zdy1] [nvarchar](50) NULL,
	[zdy2] [nvarchar](50) NULL,
	[zdy3] [nvarchar](50) NULL,
	[zdy4] [nvarchar](50) NULL,
	[zdy5] [int] NULL,
	[zdy6] [int] NULL,	
	[intro] [nvarchar](max) NULL,
	[designtype] [int] NULL,--设计来源 手动添加=0 项目=1 合同=2 报价=3 预测单=4 生产计划=5
	[chance] [int] NULL,--关联项目
	[contract] [int] NULL,--关联合同
	[price] [int] NULL, --关联报价单
	[M_PredictOrders] [int] NULL,--关联预测单
	[M_ManuPlans] [int] NULL,--关联生产计划
	[M2_PrePlans] [int] NULL,--关联预计划
	[M2_ManuPlans] [int] NULL,--关联生产计划
	[M2_WorkAssign] [int] NULL,--关联派工单
	[designstatus] [int] NULL,--设计任务状态
	[oldstatus] [int] NULL,--设计任务历史状态
	[id_sp] [int] NULL,--审批阶段
	[cateid_sp] [int] NULL , --审批人员
	[status] [int] NULL , --审批状态
	[share_op] [int] NULL, --共享操作人
	[share] [varchar](8000) , --共享人员
	[Creator] [int] NULL, --添加人员
	[indate] [datetime] NULL,--添加时间
	[del] [int] NULL,--是否删除等状态 1 正常 2 删除
	[delcate] [int] NULL, --删除人员
	[deltime] [datetime] NULL, --删除时间
	[tempsave] [int] NOT NULL DEFAULT (0),
	PRIMARY KEY NONCLUSTERED
	(
		[id] ASC
	) ON [PRIMARY]
)

GO

CREATE TABLE [dbo].[DesignList](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[topid] [int] NULL DEFAULT (0),
	[PrefixCode] [nvarchar](50) NULL,
	[Design] [int] NOT NULL,	--关联设计单
	[ProductID] [int] NOT NULL, --产品ord
	[unit] [int] NOT NULL,	--产品单位
	[Date_DH] [datetime] NULL, --项目.到货日期/合同.交货日期/报价.交货日期
	[DateStrat] [datetime] NULL, --预测单.开始日期/生产计划.计划开工日期
	[DateEnd] [datetime] NULL, --预测单.结束日期/生产计划.计划完工日期
	[date1] [datetime] NULL, --实际开始日期
	[date2] [datetime] NULL, --实际完成日期
	[zdy1] [nvarchar](200) NULL,
	[zdy2] [nvarchar](200) NULL,
	[zdy3] [nvarchar](200) NULL,
	[zdy4] [nvarchar](200) NULL,
	[zdy5] [int] NULL,
	[zdy6] [int] NULL,
	[intro] [ntext] NULL,
	[listid] [int] NULL,
	[del] [int] NULL,
	PRIMARY KEY CLUSTERED
	(
		[ID] ASC
	) ON [PRIMARY]
)

GO

CREATE TABLE [dbo].[Design_his](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NULL,
	[PrefixCode] [nvarchar](50) NULL, --设计Code
	[title] [nvarchar](200) NULL, --设计主题
	[DesignBH] [nvarchar](100) NULL,--设计编号
	[designer] [int] NULL,--设计师
	[date3] [datetime] NULL,--领用日期
	[apply] [int] NULL , --申请人员 
	[applytime] [datetime] NULL , --申请时间
	[appoint] [int] NULL ,--指派人员
	[date4] [datetime] NULL ,--指派时间
	[abandon] [int] NULL , --放弃人员
	[abandontime] [datetime] NULL , --放弃时间
	[abandonintro] [varchar](4000) NULL , --放弃原因
	[sort1] [int] NULL,--设计分类
	[level] [int] NULL,--设计等级
	[plandate1] [datetime] NULL,--计划开始日期
	[plandate2] [datetime] NULL,--计划截止日期
	[startDate] [datetime] NULL,--设计启动时间
	[endDate] [datetime] NULL,	--设计结束时间
	[zdy1] [nvarchar](50) NULL,
	[zdy2] [nvarchar](50) NULL,
	[zdy3] [nvarchar](50) NULL,
	[zdy4] [nvarchar](50) NULL,
	[zdy5] [int] NULL,
	[zdy6] [int] NULL,	
	[intro] [nvarchar](max) NULL,
	[designtype] [int] NULL,--设计来源 手动添加=0 项目=1 合同=2 报价=3 预测单=4 生产计划=5
	[chance] [int] NULL,--关联项目
	[contract] [int] NULL,--关联合同
	[price] [int] NULL, --关联报价单
	[M_PredictOrders] [int] NULL,--关联预测单
	[M_ManuPlans] [int] NULL,--关联生产计划
	[designstatus] [int] NULL,--设计任务状态
	[id_sp] [int] NULL,--审批阶段
	[cateid_sp] [int] NULL , --审批人员
	[status] [int] NULL , --审批状态
	[share_op] [int] NULL, --共享操作人
	[share] [varchar](8000) , --共享人员
	[Creator] [int] NULL, --添加人员
	[indate] [datetime] NULL,--添加时间
	[del] [int] NULL,--是否删除等状态 1 正常 2 删除
	[tempsave] [int] NOT NULL DEFAULT (0),
	[op] [varchar](20) NULL,
	[ip] [varchar](30) NULL,
	[opdate] [datetime] NULL,
	[ChangeLog] [int] NULL,
	PRIMARY KEY NONCLUSTERED
	(
		[id] ASC
	) ON [PRIMARY]
)

GO

CREATE TABLE [dbo].[DesignList_his](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[his_id] [int] NULL,
	[Dlistid] [int] NULL,
	[topid] [int] NULL DEFAULT (0),
	[PrefixCode] [nvarchar](50) NULL,
	[Design] [int] NOT NULL,	--关联设计单
	[ProductID] [int] NOT NULL, --产品ord
	[unit] [int] NOT NULL,	--产品单位
	[Date_DH] [datetime] NULL, --项目.到货日期/合同.交货日期/报价.交货日期
	[DateStrat] [datetime] NULL, --预测单.开始日期/生产计划.计划开工日期
	[DateEnd] [datetime] NULL, --预测单.结束日期/生产计划.计划完工日期
	[date1] [datetime] NULL, --实际开始日期
	[date2] [datetime] NULL, --实际完成日期
	[zdy1] [nvarchar](200) NULL,
	[zdy2] [nvarchar](200) NULL,
	[zdy3] [nvarchar](200) NULL,
	[zdy4] [nvarchar](200) NULL,
	[zdy5] [int] NULL,
	[zdy6] [int] NULL,
	[intro] [ntext] NULL,
	[listid] [int] NULL,
	[del] [int] NULL,
	PRIMARY KEY CLUSTERED
	(
		[ID] ASC
	) ON [PRIMARY]
)


GO

CREATE TABLE [dbo].[temp_kuinlist](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NULL,
	[num1] [decimal](25, 12) NULL,
	[kuin] [int] NULL,
	[kuinlist] [int] NULL,
	[del] [int] NULL,
	[del2] [int] NULL,
	[bz] [int] NULL,
	[js] [nvarchar](50) NULL,
	[intro] [nvarchar](200) NULL,
	[ph] [nvarchar](50) NULL,
	[xlh] [ntext] NULL,
	[datesc] [datetime] NULL,
	[dateyx] [datetime] NULL,
	[zdy1] [nvarchar](200) NULL,
	[zdy2] [nvarchar](200) NULL,
	[zdy3] [nvarchar](200) NULL,
	[zdy4] [nvarchar](200) NULL,
	[zdy5] [int] NULL,
	[zdy6] [int] NULL,
	[date2] [datetime] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]
 TEXTIMAGE_ON [PRIMARY]

GO

CREATE TABLE [dbo].[notice](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[PrefixCode] [nvarchar](50) NULL, --NE 通知Code
	[title] [nvarchar](200) NULL, --通知主题
	[intro] [nvarchar](4000) NULL,
	[datatype] [int] NULL,--来源 手动添加=0 合同=-1
	[dataid] [int] NULL,--关联单据id
	[share] [varchar](max) , --提醒人员
	[NeedHandle] [int] NULL , --是否需要处理
	[Creator] [int] NULL, --添加人员
	[indate] [datetime] NULL,--添加时间
	[del] [int] NULL,--是否删除等状态 1 正常 2 删除
	[tempsave] [int] NOT NULL DEFAULT (0),
	PRIMARY KEY NONCLUSTERED
	(
		[id] ASC
	) ON [PRIMARY]
)

GO

CREATE TABLE [dbo].[noticelist](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[notice] [int] NULL, --通知id
	[oid] [int] NULL,--单据oid
	[bid] [int] NULL,--单据bid
	[cateid] [int] NULL, --单据负责人
	[del] [int] NULL,--是否删除等状态 1 正常 2 删除
	PRIMARY KEY NONCLUSTERED
	(
		[id] ASC
	) ON [PRIMARY]
)

GO

CREATE TABLE [dbo].[erp_contract_MnyGainOrLoss](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[contract] [int] NULL,
	[contractlist] [int] NULL,
	[smoney] [decimal](25, 12) NULL,
	[sprice] [decimal](25, 12) NULL,
	[stype] [char](2) NULL,
	[srcbillId] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
--变更日志
--Attrs:帐套下可用
CREATE TABLE [dbo].[erp_bill_ChangeLog](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[oid] [int] NULL,
	[bid] [int] NULL,
	[intro] [text] NULL,
	[remark] [nvarchar](1000) NULL,
	[Creator] [int] NULL,
	[indate] [datetime] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

--单据中关联其他单据
--Attrs:帐套下可用
CREATE TABLE [dbo].[erp_bill_extraBills](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[oid] [int] NULL,	--单据类型
	[bid] [int] NULL,	--单据Id
	[gl_id] [int] NULL,--关联单据id
	[gl_listid] [int] NULL, --关联单据明细id
	[gl_type] [int] NULL,	--关于单据关联类型
	[Creator] [int] NULL,
	[indate] [datetime] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

--单据中关联其他单据明细
--Attrs:帐套下可用
CREATE TABLE [dbo].[erp_bill_extraBillDetails](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[BillType] [int] NULL,	--单据类型
	[BillID] [int] NULL,	--单据Id
	[ListID] [int] NULL,	--单据明细Id
	[gl_id] [int] NULL,--关联单据id
	[gl_listid] [int] NULL, --关联单据明细id
	[Creator] [int] NULL,
	[indate] [datetime] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[temp_RepairNewParts](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ProID] [int] NULL,
	[checked] [int] NULL,
	[Num] [decimal](25, 12) NULL,
	[Unit] [int] NULL,
	[UseDate] [datetime] NULL,
	[Remark] [ntext] NULL,
	[zdy1] [nvarchar](200) NULL,
	[zdy2] [nvarchar](200) NULL,
	[zdy3] [nvarchar](200) NULL,
	[zdy4] [nvarchar](200) NULL,
	[zdy5] [nvarchar](50) NULL,
	[zdy6] [nvarchar](50) NULL,
	[NodeID] [int] NULL,
	[ProcessID] [int] NULL,
	[RepairOrder] [int] NULL,
	[Repair_sl_list] [int] NULL,
	[RepairDeal] [int] NULL,
	[Del] [int] NULL,
	[AddUser] [int] NOT NULL,
	[AddTime] [datetime] DEFAULT(GETDATE()) NOT NULL,
    PRIMARY KEY CLUSTERED
    (
        [Id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]
 TEXTIMAGE_ON [PRIMARY]

GO

CREATE TABLE [dbo].[Store_Logistics](
	[OrderCode] int not null,
	[EBusinessID] varchar(50) NULL,
	[ShipperCode] varchar(50) NULL,
	[LogisticCode] varchar(50) NULL,
	[CallBack] nvarchar(50) NULL,
	[State] int NULL,
	[AcceptTime] DATETIME NULL,
	[AcceptStation] nvarchar(200) NULL,
	[Remark] nvarchar(200) NULL
)

GO

CREATE TABLE [dbo].[gate_his](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NOT NULL,	--原ord
	[oldusername] [nvarchar](50) NULL,--原登陆名
	[newusername] [nvarchar](50) NULL,--新登陆名
	[name] [nvarchar](50) NULL,--原用户姓名
	[title] [nvarchar](50) NULL,--原职位职称
	[cateid] [int] NULL,	
	[sorce] [int] NULL,
	[sorce2] [int] NULL,
	[top1] [nvarchar](4) NULL, --原账号等级
	[workPosition] [int] NULL,	--关联岗位
	[addcate] [int] NULL,
	[date7] [datetime] NULL,
	[orgsid] [int] NULL,
	[partadmin] [int] NULL,
	[pricesorce] [int] NULL
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY] 

GO

CREATE TABLE [dbo].[mobile_home_item](
	[id] [int] NULL,
	[name] [varchar](20) NULL,
	[title] [nvarchar](20) NULL,
	[action] [varchar](20) NULL,
	[url] [varchar](200) NULL,
	[ico] [varchar](30) NULL,
	[sort] [int] NULL,
	[sort2] [int] NULL,
	[id1] [int] NULL,
	[isused] [int] NULL
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[mobile_home_item_us](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[cateid] [int] NULL,
	[itemid] [int] NULL,
	[sort2] [int] NULL,
	[isUsed] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]

--@##mode:index;clustered:false;fields:cateid

GO

CREATE TABLE [dbo].[mobile_stat_config](
	[id] [int] NULL,
	[title] [varchar](30) NULL,
	[color] [varchar](10) NULL,
	[ico] [varchar](20) NULL,
	[id1] [int] NULL,
	[action] [varchar](10) NULL,
	[url] [varchar](100) NULL,
	[powerPress] [varchar](200) NULL,
	[listUrl] [varchar](100) NULL,
	[qxlb] [int] NULL,
	[qxlblist] [int] NULL,
	[gate2] [int] NULL,
	[chartType] [int] NULL,
	[sort1] [int] NULL,
	[numType] [int] NULL
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[orgs_companyinfo](
	[ID] [int] NOT NULL,
	[name] [nvarchar](150) NOT NULL,
	[smpname] [nvarchar](50) NULL,
	[phone] [varchar](20) NULL,
	[fax] [varchar](20) NULL,
	[builddate] [datetime] NULL,
	[email] [varchar](50) NULL,
	[elperson] [nvarchar](50) NULL,
	[money1] [decimal](25, 12) NULL,
	[address] [nvarchar](500) NULL,
	[zip] [varchar](20) NULL,
	[url] [nvarchar](200) NULL,
	[intro] [ntext] NULL,
	[remark] [ntext] NULL,
	[adduser] [int] NULL,
	[addtime] [datetime] NULL,
PRIMARY KEY CLUSTERED
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY] 

GO

CREATE TABLE [dbo].[orgs_parts](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[PID] [int] NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
    [ShortName][nvarchar](50) NULL,
	[Sort] [int] NULL,
	[FunText] [nvarchar](500) NULL,
	[Intro] [ntext] NULL,
	[Stoped] [int] NOT NULL,
	[openprice] [int] NULL,
	[Old_Gate1ID] [int] NULL,
	[Old_Gate2ID] [int] NULL,
	[IsGroup] [bit] NULL,
	[IsPart] [bit] NULL,
	[deep] [int] NULL,
	[fullpath] [nvarchar](1000) NULL,
	[fullids] [varchar](500) NULL,
	[fullsort] [int] NULL,
	[addtime] [datetime] NULL,
	[adduser] [int] NULL,
   PRIMARY KEY CLUSTERED
	(
		[ID] ASC
	)ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[WF_ManyApproversRecord](
	[RecordID] [uniqueidentifier] NOT NULL,
	[InstanceID] [uniqueidentifier] NULL,
	[ApprovalProcessId] [uniqueidentifier] NULL,
	[ApprovalResult] [bit] NULL,
        PRIMARY KEY CLUSTERED 
	(
		[RecordID] ASC
	)ON [PRIMARY]
)

GO
CREATE TABLE [dbo].[WF_ApprovalRules](
	[ApprovalRulesId] [uniqueidentifier] NOT NULL,
	[ApprovalRulesName] [nvarchar](200) NULL,
	[BillType] [varchar](100) NULL,
	[BillCategory] [varchar](100) NULL,
	[BillPattern] [int] NULL,
	[PositionRange] [varchar](8000) NULL,
	[CreateTime] [datetime] NULL,
	[UserID] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
	(
           [ApprovalRulesId] ASC
	)ON [PRIMARY]
)

GO
CREATE TABLE [dbo].[WF_ApprovalProcess](
	[ApprovalProcessId] [uniqueidentifier] NOT NULL,
	[ApprovalRulesId] [uniqueidentifier] NULL,
	[ApprovalProcessName] [nvarchar](200) NULL,
	[ApprovalProcessLevel] [int] NULL,
	[IsNecessary] [bit] NULL,
	[ApprovalType] [int] NULL,
	[MoneyLimitUp] [decimal](25, 12) NULL,
	[MoneyLimitDown] [decimal](25, 12) NULL,
	[ApproverScope] [varchar](8000) NULL,
	[IsConnection] [int] NULL,
	[PassLimit] [int] NULL,
	[CreateTime] [datetime] NULL,
	[UserID] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
	(
           [ApprovalProcessId] ASC
	)ON [PRIMARY]
)

GO
CREATE TABLE [dbo].[WF_ApprovalLog](
	[ApprovalLogID] [uniqueidentifier] NOT NULL,
	[ApprovalProcessId] [uniqueidentifier] NULL,
	[InstanceID] [uniqueidentifier] NULL,
	[ApprovalProcessName] [nvarchar](200) NULL,
	[ApproverID] [varchar](50) NULL,
	[ApproverName] [nvarchar](200) NULL,
	[ApproverDept] [nvarchar](200) NULL,
	[Explain] [nvarchar](500) NULL,
	[ApprovalResult] [bit] NULL,
	[IsAutoPass] [bit] NULL,
	[ApprovalType] [nvarchar](50) NULL,
	[Operator] [nvarchar](200) NULL,
	[OperationType] [nvarchar](500) NULL,
	[ApprovalTime] [datetime] NULL,
	[CreateTime] [datetime] NULL,
	[OperationTime] [datetime] NULL,
PRIMARY KEY CLUSTERED 
	(
           [ApprovalLogID] ASC
	)ON [PRIMARY]
) 

GO
CREATE TABLE [dbo].[WF_ApprovalInstanceItems](
	[ApprovalProcessId] [uniqueidentifier] NOT NULL,
	[ParentApprovalProcessId] [uniqueidentifier] NULL,
	[InstanceID] [uniqueidentifier] NULL,
	[ApprovalProcessName] [nvarchar](200) NULL,
	[ApprovalProcessLevel] [int] NULL,
	[IsNecessary] [bit] NULL,
	[ApprovalType] [int] NULL,
	[MoneyLimitUp] [decimal](25, 12) NULL,
	[MoneyLimitDown] [decimal](25, 12) NULL,
	[EverApprovers] [varchar](2000) NULL,
	[ApproverScope] [varchar](8000) NULL,
	[IsConnection] [int] NULL,
	[PassLimit] [int] NULL,
	[CreateTime] [datetime] NULL,
	[UserID] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
	(
           [ApprovalProcessId] ASC
	)ON [PRIMARY]
)

GO
CREATE TABLE [dbo].[WF_ApprovalInstance](
	[InstanceID] [uniqueidentifier] NOT NULL,
	[ApprovalProcessId] [uniqueidentifier] NULL,
	[ApprovalRulesId] [uniqueidentifier] NULL,
	[BillType] [varchar](100) NULL,
	[BillCategory] [varchar](100) NULL,
	[BillPattern] [int] NULL,
	[PrimaryKeyID] [varchar](50) NULL,
	[BillRight] [varchar](50) NULL,
	[ApprovalFlowStatus] [int] NULL,
	[Approver] [varchar](8000) NULL,
	[CreateTime] [datetime] NULL,
	[UserID] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
	(
           [InstanceID] ASC
	)ON [PRIMARY]
)

GO
CREATE TABLE [dbo].[WF_ApprovalDelegateRecord](
	[DelegateID] [uniqueidentifier] NOT NULL,
	[Mandatary] [varchar](50) NULL,
	[Consigner] [varchar](50) NULL,
	[BeginTime] [datetime] NULL,
	[EndTime] [datetime] NULL,
	[Forever] [bit] NULL,
	[BillType] [varchar](100) NULL,
	[IsEffect] [bit] NULL,
	[CreateTime] [datetime] NULL,
	[UserID] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
	(
           [DelegateID] ASC
	)ON [PRIMARY]
)
GO

CREATE TABLE [dbo].[HrKQ_AttendanceAppeal](
      [ID] [INT] IDENTITY(1, 1)
                 NOT NULL ,
      [UserID] [INT] NULL ,
      [Day] [DATETIME] NULL ,
      [Week] [VARCHAR](50) NULL ,
      [ShouldTime] [VARCHAR](50) NULL ,
      [FirstTime] [DATETIME] NULL ,
      [Reason] [INT] NULL ,
      [Content] [VARCHAR](500) NULL ,
      [DisposeUser] [INT] NULL ,
      [isDefaultUser] [INT] NULL ,
      [Result] [INT] NULL ,
      [TreatmentStatus] [INT] NULL ,
      [Address] [VARCHAR](500) NULL ,
      [CreateID] [INT] NULL ,
      [CreateDate] [DATETIME] NULL ,
      [TimeArrangeID] [INT] NULL ,
      [ClockTimeID] [INT] NULL ,
      [LastTime] [DATETIME] NULL ,
      [DisposeRemark] [VARCHAR](500) NULL ,
	  [DisposeDate] [DATETIME] NULL ,
	  [AppealBeginDate] [DATETIME] NULL ,
	  [AppealEndDate] [DATETIME] NULL ,
      [UnusualWorkType] [INT] NULL ,
      PRIMARY KEY CLUSTERED ( [id] ASC ) ON [PRIMARY]
)

--@##mode:index;clustered:false;fields:UserID,Day

GO


CREATE TABLE [dbo].[HrKQ_AttendanceApply](
      [ID] [INT] IDENTITY(1, 1) NOT NULL ,
      [Title] [NVARCHAR](50) NULL ,
      [ApplyType] [INT] NULL ,
      [StartDate] [DATETIME] NULL ,
      [EndDate] [DATETIME] NULL ,
      [Whenlong] [decimal](25, 12) NULL ,
      [Remarks] [NTEXT] NULL ,
      [CreateID] [INT] NULL ,
      [CreateDate] [DATETIME] NULL ,
      [isDel] [INT] NULL ,
      [isFile] [INT] NULL ,
	  [OldApplyID] [INT] NULL ,
	  [Unit] [NVARCHAR](10) NULL ,
	  [HWhenlong] [decimal](25, 12) NULL ,
	  [status] [INT] NULL ,
	  [LastApproveTime] [datetime] null,
	  [LastApproveUser] [int] null,
      [creator] [INT] NULL ,
	  [indate] [DATETIME] NULL ,
	  [IsLoop] [INT] NULL ,
	  [LoopStartTime] [VARCHAR](8) NULL ,
	  [LoopEndTime] [VARCHAR](8) NULL ,
      [ExchangeBL] [decimal](25, 12) NULL ,
      PRIMARY KEY CLUSTERED ( [id] ASC ) ON [PRIMARY]
)

--@##mode:index;clustered:false;fields:isDel,StartDate,EndDate

GO

CREATE TABLE [dbo].[HrKQ_AttendanceApplyRange](
      [ApplyID] [INT] NULL ,
      [UserID] [INT] NULL
    )
ON  [PRIMARY]

--@##mode:index;clustered:false;fields:ApplyID,UserID

GO

CREATE TABLE [dbo].[HrKQ_AttendanceRecord](
      [ID] [BIGINT] IDENTITY(1, 1)   NOT NULL ,
      [UserID] [INT] NULL ,
      [Date] [DATETIME] NULL ,
      [ClockTime] [DATETIME] NULL ,
      [AddressOrIP] [VARCHAR](200) NULL ,
      [Device] [INT] NULL ,
      [isTrueDevice] [INT] NULL ,
      [Currcoords] [VARCHAR](50) NULL ,
	  [Explain] [NVARCHAR](200) NULL,
	  [SystemClock] [INT] NULL ,
	  [CLSMode] [NVARCHAR](50) NULL ,
	  [WIFIName] [NVARCHAR](100) NULL ,
	  [MachineId]  [INT] NULL ,
      PRIMARY KEY CLUSTERED ( [id] ASC ) ON [PRIMARY]
)

--@##mode:index;clustered:false;fields:UserID,Date,ClockTime

GO

CREATE TABLE [dbo].[HrKQ_AttendanceType](
      [ID] [BIGINT] IDENTITY(1, 1) NOT NULL ,
      [OnlyID] [INT] NOT NULL,
      [Title] [NVARCHAR](50) NULL ,
      [Unit] [INT] NULL ,
      [isContainHoliday] [INT] NULL ,
      [isRelatedWage] [INT] NULL ,
      [isAlloweRest] [INT] NULL ,
      [isAllowApply] [INT] NULL ,
      [TermofValidity] [INT] NULL ,
      [Status] [INT] NULL ,
      [isUpdate] [INT] NULL ,
      [CreateId] [BIGINT] NULL ,
      [CreateDate] [DATETIME] NULL ,
      [isClock] [INT] NULL ,
	  [AttTypeCls] [int] NULL,
	  [Personalization] [NVARCHAR](2000) NULL ,
      [MonthWarning] [decimal](25, 12) NULL ,
      [WeekWarning] [decimal](25, 12) NULL ,
      [DayWarning] [decimal](25, 12) NULL ,
	  [showindex]  int NULL,
      PRIMARY KEY CLUSTERED ( [OnlyID] ASC ) ON [PRIMARY]
)

--@##mode:index;clustered:false;fields:OnlyID

GO

CREATE TABLE [dbo].[HrKQ_CalendarTable](
      [ID] [BIGINT] IDENTITY(1, 1)
                    NOT NULL ,
      [Year] [INT] NULL ,
      [Month] [INT] NULL ,
      [Week] [INT] NULL ,
      [Date] [DATETIME] NULL ,
      PRIMARY KEY CLUSTERED ( [id] ASC ) ON [PRIMARY]
)

--@##mode:index;clustered:false;fields:Date

GO

CREATE TABLE [dbo].[HrKQ_CardSetting](
      [RangeID] [INT] IDENTITY(1, 1)
                      NOT NULL ,
      [Title] [NVARCHAR](50) NULL ,
      [Device] [NVARCHAR](50) NULL ,
      [RangeType] [INT] NULL ,
      [CreateID] [INT] NULL ,
      [CreateDate] [DATETIME] NULL ,
	  [GroupID] [INT] NULL ,
	  [ModeType] [NVARCHAR](50) NULL ,
	  [RangeM] [INT] NULL ,
      PRIMARY KEY CLUSTERED ( [RangeID] ASC ) ON [PRIMARY]
)

GO

CREATE TABLE [dbo].[HrKQ_CardSettingRange](
      [RangeID] [INT] NULL ,
      [UserID] [INT] NULL
)
ON  [PRIMARY]

--@##mode:index;clustered:false;fields:RangeID

GO

CREATE TABLE [dbo].[HrKQ_ClockDetailList](
      [ID] [INT] IDENTITY(1, 1)
                 NOT NULL ,
      [SignTime] [NVARCHAR](50) NULL ,
      [SignOutTime] [NVARCHAR](50) NULL ,
      [StartInterDay] [INT] NULL ,
      [EndInterDay] [INT] NULL ,
      [DetailID] [INT] NULL ,
      [SettingID] [INT] NULL ,
      [Whenlong] [decimal](25, 12) NULL ,
      [EffectiveTime] [INT] NULL ,
	  [StartEffectiveTime] [INT] NULL ,
	  [Sort] [INT] NULL ,
      [StartNeedClock] [INT] NULL ,
      [EndNeedClock] [INT] NULL ,
      PRIMARY KEY CLUSTERED ( [id] ASC ) ON [PRIMARY]
)

--@##mode:index;clustered:false;fields:DetailID,SettingID

GO

CREATE TABLE [dbo].[HrKQ_PersonGroup](
      [ID] [INT] IDENTITY(1, 1)
                 NOT NULL ,
      [GroupName] [NVARCHAR](50) NULL ,
      [RangeType] [INT] NULL ,
      [Range] [NTEXT] NULL ,
      [CreateID] [INT] NULL ,
      [CreateDate] [DATETIME] NULL ,
	  [Disable] [INT] NULL,
	  [DisableTime] [DATETIME] NULL,
	  [DisablePerson] [INT] NULL,
      PRIMARY KEY CLUSTERED ( [id] ASC ) ON [PRIMARY]
)

GO

CREATE TABLE [dbo].[HrKQ_Scheduling](
      [ID] [INT] IDENTITY(1, 1)
                 NOT NULL ,
      [StartDate] [DATETIME] NULL ,
      [EndDate] [DATETIME] NULL ,
      [TitleID] [INT] NULL ,
      [PersonGroupIDs] [NTEXT] NULL ,
      [CycleDays] [INT] NULL ,
      [CreateID] [INT] NULL ,
      [CreateDate] [DATETIME] NULL ,
	  [IsContainHoliday] [INT] NULL ,
      PRIMARY KEY CLUSTERED ( [id] ASC ) ON [PRIMARY]
)

--@##mode:index;clustered:false;fields:TitleID

GO


CREATE TABLE [dbo].[HrKQ_SchedulingDetail](
      [ParentID] [BIGINT] NULL ,
      [PersonGroupID] [INT] NULL ,
      [Date] [DATETIME] NULL ,
      [TimeArrangeID] [INT] NULL
)
ON  [PRIMARY]

--@##mode:index;clustered:false;fields:ParentID,PersonGroupID,Date,TimeArrangeID

GO


CREATE TABLE [dbo].[HrKQ_TimeArrangeDetail](
      [ID] [INT] IDENTITY(1, 1)
                 NOT NULL ,
      [Title] [NVARCHAR](50) NULL ,
      [Color] [NVARCHAR](50) NULL ,
      [RuleLateMinute] [INT] NULL ,
      [RuleLeaveEarlyMinute] [INT] NULL ,
      [RuleOvertimeMinute] [INT] NULL ,
      [RuleMinerMinute] [INT] NULL ,
      [ElasticTimeMinute] [INT] NULL ,
      [SettingID] [INT] NULL ,
	  [NoClock] [INT] NULL ,
      [RestBegin] [VARCHAR](8) NULL ,
      [RestEnd] [VARCHAR](8) NULL ,  
      [ReckonByTime] [INT] NULL ,
	  [ScheduleRules] [NVARCHAR](4000) NULL ,
      PRIMARY KEY CLUSTERED ( [id] ASC ) ON [PRIMARY]
)

--@##mode:index;clustered:false;fields:SettingID

GO

CREATE TABLE [dbo].[HrKQ_TimeArrangeSetting](
      [ID] [INT] IDENTITY(1, 1)
                 NOT NULL ,
      [Title] [NVARCHAR](50) NULL ,
      [CreateID] [INT] NULL ,
      [CreateDate] [DATETIME] NULL ,
      PRIMARY KEY CLUSTERED ( [id] ASC ) ON [PRIMARY]
)

GO

CREATE TABLE [dbo].[HrKQ_AdjustmentRest](
	[ID] [INT] IDENTITY(1,1) NOT NULL,
	[RestID] [INT] NOT NULL,
	[OverTimeID] [INT] NOT NULL,
	[Whenlong] [decimal](25, 12) NOT NULL,
	[CreateDate] [DATETIME] NULL,
	[UserID] [INT] NULL,
	[isCalcul] [INT] NULL,
	[JoinAddWorkLogDate] [DATETIME] NULL,
	PRIMARY KEY CLUSTERED ([ID] ASC) ON [PRIMARY]
)

--@##mode:index;clustered:false;fields:RestID,JoinAddWorkLogDate,UserID

GO

CREATE TABLE [dbo].[sp_ApprovalInstance](
	[InstanceID] [int] IDENTITY(1,1) NOT NULL,
	[ApprovalRulesId] [int] NOT NULL,
	[ApprovalProcessId] [int] NULL,
	[ApprovalType] [int] NULL,
	[ApprovalRelation]	[int] NULL,
	[gate1]	[int] NULL,
	[gate2] [int] NULL,
	[sptype] [int] NULL,
	[PrimaryKeyID] [int] NULL,
	[BillRight] [varchar](50) NULL,
	[ApprovalFlowStatus] [int] NULL,
	[Approver] [varchar](max) NULL,
	[SurplusApprover] [varchar](max) NULL,
	[BillPattern] [int] NULL,
	[CreateTime] [datetime] NULL,
	[UserID] [int] NULL,
	[RemindConfigId] [int] NULL,
	[ListPageUrl] [varchar](1000) NULL,
	[Bounds] [decimal](25, 12) NULL,
	[BillSubmitType] [int] NULL,
	[BillOwner] [int] NULL,
	[del] [int] NULL DEFAULT (1),
	PRIMARY KEY CLUSTERED ([InstanceID] ASC) ON [PRIMARY]
)

GO

CREATE TABLE [dbo].[sp_ApprovalInstanceItems](
	[ApprovalProcessId] [int] IDENTITY(1,1) NOT NULL,
	[ParentApprovalProcessId] [int] NULL,
	[InstanceID] [int] NULL,
	[sort1] [nvarchar](200) NULL,
	[gate1] [int] NULL,
	[bt] [int] NULL,
	[ApprovalType] [int] NULL,
	[money1] [decimal](25, 12) NULL,
	[money2] [decimal](25, 12) NULL,
	[intro] [varchar](max) NULL,
	[EverApprovers] [varchar](max) NULL,
	[gate3] [int] NULL,
	[PassLimit] [int] NULL,
	[CreateTime] [datetime] NULL,
	[UserID] [int] NULL,
        PRIMARY KEY CLUSTERED ([ApprovalProcessId] ASC) ON [PRIMARY]
)
GO
CREATE TABLE [dbo].[sp_ApprovalRules](
	[ApprovalRulesId] [int] IDENTITY(1,1) NOT NULL,
	[ApprovalRulesName] [nvarchar](200) NOT NULL, 
	[gate2] [int] NOT NULL,
	[sptype] [int] NULL,
	[PositionRange] [varchar](max) NULL,
	[BillPattern] [int] NULL,
	[CreateTime] [datetime] NULL,
	[UserID] [int] NULL,
        PRIMARY KEY CLUSTERED ([ApprovalRulesId] ASC) ON [PRIMARY]
)

GO

CREATE TABLE [dbo].[sp_ManyApproversRecord](
	[RecordID] [int] IDENTITY(1,1) NOT NULL,
	[InstanceID] [int] NOT NULL,
	[ApprovalProcessId] [int] NOT NULL,
	[ApprovalResult] [bit] NOT NULL,
	[UserID] [int] NULL,
    PRIMARY KEY CLUSTERED ([RecordID] ASC) ON [PRIMARY]
)
GO
--Attrs:帐套下可用
CREATE TABLE [dbo].[erp_bill_LockLog](
	[billsign] [nchar](16) NULL,
	[billid] [int] NULL,
	[lockuserid] [int] NULL,
	[lockname] [nvarchar](50) NULL,
	[locktime] [datetime] NULL,
	[keeptime] [datetime] NULL
) ON [PRIMARY]

--@##mode:index;clustered:false;fields:billsign,billid,lockuserid

GO

CREATE TABLE [dbo].[Report_ManageViews](
	[ID] [BIGINT] IDENTITY(1,1) NOT NULL,
	[OnlyName] [VARCHAR](100) NULL,
	[ViewName] [VARCHAR](200) NULL,
	[isEnable] [INT] NULL,
	[ColumnsTxt] [NTEXT] NULL,
	[ConditionTxt] [NTEXT] NULL,
	[SortRule] [VARCHAR](50) NULL,
	[ShowNumber] [INT] NULL,
	[SortIndex] [INT] NULL,
	[CreateID] [INT] NULL,
	[CreateDate] [DATETIME] NULL,
	PRIMARY KEY CLUSTERED ( [ID] ASC ) ON [PRIMARY]
)

GO

CREATE TABLE [dbo].[HrKQ_AttendanceImage](
	[RecordID] [BIGINT] NOT NULL,
	[ImagePath] [VARCHAR](500) NULL
) ON [PRIMARY]
Go

CREATE TABLE [dbo].[M2_WorkingProcedures](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[WPName] [nvarchar](100) NULL,
	[WPBH] [nvarchar](50) NULL,
	[Status] [int] NULL,
	[Description] [ntext] NULL,
	[mainCapacity] [int] NULL,
	[Wclass] [int] NULL,
	[Wheelman] [VARCHAR](8000) NULL,
	[Creator] [int] NULL,
	[indate] [datetime] NULL,
	[del] [int] NULL,
	[upuser] [int] NULL,	--最近操作人员
	[uptime] [datetime] NULL, --最近操作时间
	[oldverId] [int] NULL,
    [rowindex] [int] NULL,
    [import] int,
	PRIMARY KEY CLUSTERED ([ID] ASC) ON [PRIMARY]
) 
GO

CREATE TABLE [dbo].[M2_WorkingPD](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[PID] [int] NULL,
	[WCenter] [int] NULL,
	[title] [nvarchar](100) NULL,
	[sort] [int] NULL,
	[dataType] [int] NULL,
	[isStop] [int] NULL,
	[del] [int] NULL,
	[indate] [datetime] NULL,
	[Creator] [int] NULL,
	[intro] [ntext] NULL,
	[upuser] [int] NULL,	--最近操作人员
	[uptime] [datetime] NULL, --最近操作时间
	[rowindex] [INT] NULL,
	PRIMARY KEY CLUSTERED ([ID] ASC) ON [PRIMARY]
) 

GO

CREATE TABLE [dbo].[M2_WorkingFlows](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[WFName] [nvarchar](100) NULL,
	[WFBH] [nvarchar](50) NULL,
	[Creator] [int] NULL,
	[id_sp] [int] NULL,
	[cateid_sp] [int] NULL,
	[status] [int] NULL,
	[LastApproveTime] [datetime] null,
	[LastApproveUser] [int] null,
	[del] [int] NULL,
	[Description] [ntext] NULL,
	[unit] [int] NULL,
	[intro] [ntext] NULL,
	[indate] [datetime] NULL,
	[tempsave] [int] NULL,
	[isStop] [int] NULL,
	[WFclass] [int] NULL,
    [SuitproType] [int] NULL,
	[delcate] [INT] NULL,
	[deltime] [DATETIME] NULL,
	[upuser] [int] NULL,	--最近操作人员
	[uptime] [datetime] NULL, --最近操作时间
	[oldverid] INT NULL,
    [Import] [varchar](20) NULL,
	PRIMARY KEY CLUSTERED ([ID] ASC) ON [PRIMARY]
)
GO

CREATE TABLE [dbo].[M2_WorkingCenters](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[WCName] [nvarchar](100) NULL,
	[WCBH] [nvarchar](50) NULL,
	[Department] [int] NULL,
	[Cateid] [int] NULL,
	[gate1] [int] NULL,
	[intro] [ntext] NULL,
	[del] [int] NULL,
	[TempSave] [int] NULL,
	[Creator] [int] NULL,
	[inDate] [datetime] NULL,
	[isStop] [int] NULL,
	[delcate] [INT] NULL,
	[deltime] [DATETIME] NULL,
	[upuser] [int] NULL,	--最近操作人员
	[uptime] [datetime] NULL, --最近操作时间
	[oldverId] [int] NULL,
	PRIMARY KEY CLUSTERED ([ID] ASC) ON [PRIMARY]
)
GO

CREATE TABLE [dbo].[M2_WFP](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[WFID] [int] NULL,
	[WPID] [int] NULL,
	[ord] [int] NULL,
	[isOut] [int] NULL,
	[result] [int] NULL,
	[remark] [ntext] NULL,
	[rptime] [decimal](25, 12) NULL,
	[wtime] [decimal](25, 12) NULL,
	[wNum] [decimal](25, 12) NULL,
	[mtime] [decimal](25, 12) NULL,
	[mNum] [decimal](25, 12) NULL,
	[del] [int] NULL,
	[ReportingExceptionStrategy] [int] NULL DEFAULT (0),
	[ReportingUnit] [nvarchar](2000) NULL,
	[BatchNumberStart] [int] NULL DEFAULT (0),
	[SerialNumberStart] [int] NULL DEFAULT (0),
	[IntermediateProduct] [nvarchar](500) NULL,
	[ConversionBL] [decimal](25, 12) NULL DEFAULT (1),
	[ReportingRounding] [int] NULL DEFAULT (0),
    [ExecTask] [int] NULL DEFAULT (0),
    [ExecCheck] [int] NULL DEFAULT (0),
	PRIMARY KEY CLUSTERED ([ID] ASC) ON [PRIMARY]
)
GO

CREATE TABLE [dbo].[M2_Procedures_PN](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[WPID] [int] NULL,
	[workPosition] [int] NULL,
	[OPNumber] [int] NULL,
	[del] [int] NULL,
	PRIMARY KEY CLUSTERED ([ID] ASC) ON [PRIMARY]
)
GO

CREATE TABLE [dbo].[M2_Procedures_MH](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[WPID] [int] NULL,
	[MachileID] [int] NULL,
	[MachileNumber] [int] NULL,
	[del] [int] NULL,
	PRIMARY KEY CLUSTERED ([ID] ASC) ON [PRIMARY]
)
GO

CREATE TABLE [dbo].[M2_MenuDepartment](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[PID] [int] NULL,
	[Name] [nvarchar](100) NULL,
	[BH] [nvarchar](50) NULL,
	[Cateid] [int] NULL,
	[FunText]  [ntext] NULL,
	[Sort] [int] NULL,
	[deep] [int] NULL,
	[fullpath] [nvarchar](1000) NULL,
	[fullids] [varchar](500) NULL,
	[fullsort] [int] NULL,
	[inDate] [datetime] NULL,
	[Creator] [int] NULL,
	[isStop] [int] NULL,
	[delcate] [INT] NULL,
	[deltime] [DATETIME] NULL,
	[del] [int] NULL,
	[upuser] [int] NULL,	--最近操作人员
	[uptime] [datetime] NULL, --最近操作时间
	[UseRange] [varchar](max),
    [Orgsid] [int] NULL,
	PRIMARY KEY CLUSTERED ([ID] ASC) ON [PRIMARY]
)
GO

CREATE TABLE [dbo].[M2_ManuPlansPre](
	[ID] [INT] IDENTITY(1,1) NOT NULL,
	[title] [NVARCHAR](100) NULL,
	[MPSBH] [NVARCHAR](50) NULL,
	[status] [INT] NULL,
	[LastApproveTime] [datetime] null,
	[LastApproveUser] [int] null,
	[CreateFrom] [INT] NULL,
	[FromID] [INT] NULL,
	[intro] [NTEXT] NULL,
	[Creator] [INT] NULL,
	[inDate] [DATETIME] NULL,
	[del] [INT] NULL,
	[TempSave] [INT] NULL,
	[delcate] [INT] NULL,
	[deltime] [DATETIME] NULL,
	[upuser] [int] NULL,	--最近操作人员
	[uptime] [datetime] NULL, --最近操作时间
    [AutoCreate] [INT] NOT NULL DEFAULT (0),--1:自动生成 0:手动
	PRIMARY KEY CLUSTERED ([ID] ASC) ON [PRIMARY]
) 

GO

CREATE TABLE [dbo].[M2_ManuPlanListsPre](
	[ID] [INT] IDENTITY(1,1) NOT NULL,
	[MPSID] [INT] NULL,
	[ProductID] [INT] NULL,
	[unit] [INT] NULL,
	[NumPlan] [decimal](25, 12) NULL,
	[DateDelivery] [DATETIME] NULL,
	[intro] [NTEXT] NULL,
	[del] [INT] NULL,
	[CreateFrom] [INT] NULL,
	[FromID] [INT] NULL,
	[commUnitAttr] [NVARCHAR](200) NULL,
	[rowindex] [INT] NULL,
    [ManuPlanStatus] [int] NOT NULL DEFAULT ((0))
 PRIMARY KEY CLUSTERED ([ID] ASC) ON [PRIMARY]
)

--@##mode:index;clustered:false;fields:MPSID
GO

--Attrs:帐套下可用
CREATE TABLE [dbo].[sys_sdk_BillFieldInfo](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ModuleType] [int] NULL,
	[BillType] [int] not NULL default(0),
	[ListType] [int] not NULL default(0),
	[InheritId] [int] NULL,
	[StrongInheritId] [int] not null default(0),
	[InheritParentId] [int] not null default(0),
	[CanReName] [int]  not null default(1),
	[Title] [nvarchar](50) NULL,
	[DBName] [nvarchar](50) not NULL default(''),
	[UiType] [int] NULL,
	[DbType] [int] NULL,
    [DefWidth] [int] NULL,
	[Unit] [nvarchar](20) NULL,
	[Remark] [nvarchar](150) NULL,
	[ShowIndex] [int] NULL,
	[UIOrderIndex] [int] NULL,
	[Colspan] [int] NULL,
	[Rowspan] [int] NULL,
	[Display] [int] NULL,
	[IsUsed] [int] NULL,
	[SourceTag] [varchar](50) NULL,
	[cansearch]  [int] NULL,
	[candc]  [int] NULL,
	[candr]  [int] NULL,
	[mustfillin]  [int] NULL,
	[cantj]  [int] NULL,
	[RootDataType] [int] not null default(0),
	[InheritParentBillType] [int] not null default(0),
	[InheritParentBillListType] [int] not null default(0),
	[InheritRootBillType] [int] not null default(0),
	[InheritRootBillListType] [int] not null default(0),
	[InheritModel] [int]  not null default(0),
	[ToNextOpened] [int]  not null default(0),
	[ToNextRange] [nvarchar](4000) NULL,
	[ShowInOneCell] [int]  not null default(0),
	[TextLen] [int] not null default(0),
	[FormulaCode]  [nvarchar](200) NULL,
	[CanBatchInput]  [int]  not null default(0),
	[CanSum]  [int] not null default(0),
	[ProductZdyGroupId]  [int] not null default(0),
	[IsParentInheritMX] [bit] not null default(0),
	[IsParentInheritMain] [bit] not null default(0),
	PRIMARY KEY CLUSTERED (
		[BillType] ASC,
		[ListType] ASC,
		[InheritParentBillType] ASC,
		[InheritParentBillListType] ASC,
		[DBName] ASC,
		[IsParentInheritMain] desc
	) ON [PRIMARY]
) ON [PRIMARY]

GO

--Attrs:帐套下可用
CREATE TABLE [dbo].[Sys_Sdk_BillFieldInfo_log](
	[LogId] [int] IDENTITY(1,1) NOT NULL,
	[id] [int]  NULL,
	[ModuleType] [int] NULL,
	[BillType] [int] not NULL default(0),
	[ListType] [int] not NULL default(0),
	[InheritId] [int] NULL,
	[StrongInheritId] [int] not null default(0),
	[InheritParentId] [int] not null default(0),
	[CanReName] [int]  not null default(1),
	[Title] [nvarchar](50) NULL,
	[DBName] [nvarchar](50) not NULL default(''),
	[UiType] [int] NULL,
	[DbType] [int] NULL,
    [DefWidth] [int] NULL,
	[Unit] [nvarchar](20) NULL,
	[Remark] [nvarchar](150) NULL,
	[ShowIndex] [int] NULL,
	[UIOrderIndex] [int] NULL,
	[Colspan] [int] NULL,
	[Rowspan] [int] NULL,
	[Display] [int] NULL,
	[IsUsed] [int] NULL,
	[SourceTag] [varchar](50) NULL,
	[cansearch]  [int] NULL,
	[candc]  [int] NULL,
	[candr]  [int] NULL,
	[mustfillin]  [int] NULL,
	[cantj]  [int] NULL,
	[RootDataType] [int] not null default(0),
	[InheritParentBillType] [int] not null default(0),
	[InheritParentBillListType] [int] not null default(0),
	[InheritRootBillType] [int] not null default(0),
	[InheritRootBillListType] [int] not null default(0),
	[InheritModel] [int]  not null default(0),
	[ToNextOpened] [int]  not null default(0),
	[ToNextRange] [nvarchar](4000) NULL,
	[ShowInOneCell] [int]  not null default(0),
	[TextLen] [int] not null default(0),
	[FormulaCode]  [nvarchar](200) NULL,
	[CanBatchInput]  [int]  not null default(0),
	[CanSum]  [int] not null default(0),
	[ProductZdyGroupId]  [int] not null default(0),
	[IsParentInheritMX] [bit] not null default(0),
	[IsParentInheritMain] [bit] not null default(0),
	[UpdateType] [nvarchar](10) NULL,
	[UpdateUserId] [int] NULL,
	[UpdateTime] [datetime] NULL,
    PRIMARY KEY CLUSTERED
    (
        [LogId] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

--Attrs:帐套下可用
CREATE TABLE [dbo].[sys_sdk_BillFieldOptionsSource](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[FieldId] [int] NULL,
	[Text] [nvarchar](100) NULL,
	[ShowIndex] [int] NULL,
	[Deep] [int]  not null default(0),
	[Stoped] [bit]  not null default(0),
	[ParentId] [int]  not null default(0),
    PRIMARY KEY CLUSTERED
    (
        [Id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

--Attrs:帐套下可用
CREATE TABLE [dbo].[sys_sdk_BillFieldValue](
    [iord] [int] IDENTITY(1,1) NOT NULL,
	[BillType] [int] NOT NULL DEFAULT (0),
	[BillListType] [int] NOT NULL DEFAULT (0),
	[BillId] [int] NOT NULL,
	[ListID] [int] NOT NULL,
	[FieldId] [int] NOT NULL,
	[InheritId] [int] not NULL DEFAULT (0),
	[Value] [nvarchar](2000) NULL,
	[BigValue] [ntext] NULL,
	PRIMARY KEY CLUSTERED (
		[BillType] ASC,
		[BillListType] ASC,
		[BillId] ASC,
		[ListID] ASC,
		[InheritId] ASC
	) ON [PRIMARY]
) ON [PRIMARY]
--@##mode:index;clustered:false;fields:iord
--@##mode:index;clustered:false;fields:InheritId

GO

CREATE TABLE [dbo].[M2_MachineInfo](
	[ID] [INT] IDENTITY(1,1) NOT NULL,
	[name] [NVARCHAR](200) NULL,
	[type] [NVARCHAR](50) NULL,
	[spec] [NVARCHAR](100) NULL,
	[remark] [NTEXT] NULL,
	[Creator] [INT] NULL,
	[indate] [DATETIME] NULL,
	[del] [INT] NULL,
	[delcate] [INT] NULL,
	[deltime] [DATETIME] NULL,
	[Import] [INT] NULL,
	[upuser] [int] NULL,	--最近操作人员
	[uptime] [datetime] NULL, --最近操作时间
	[oldverId] [int] NULL
 PRIMARY KEY CLUSTERED ([ID] ASC) ON [PRIMARY]
)

GO

CREATE TABLE [dbo].[M2_MachineList](
	[ID] [INT] IDENTITY(1,1) NOT NULL,
	[MFID] [INT] NULL,
	[xlh] [NVARCHAR](100) NULL,
	[company] [INT] NULL,
	[buydate] [DATETIME] NULL,
	[timeNumber] [decimal](25, 12) NULL,
	[RatedCapacity] [decimal](25, 12) NULL,
	[LoadCapacity] [decimal](25, 12) NULL,
	[del] [INT] NULL,
	[isCrash] [INT] NULL,
    [rowindex] [INT] NULL,
  PRIMARY KEY CLUSTERED ([ID] ASC) ON [PRIMARY]
)

GO

CREATE TABLE [dbo].[M2_MachineCrashInfo](
	[id] [INT] IDENTITY(1,1) NOT NULL,
	[MHLID] [INT] NULL,
	[mtype] [INT] NULL,
	[reason] [NVARCHAR](500) NULL,
	[date1] [DATETIME] NULL,
	[Creator] [INT] NULL,
	[indate] [DATETIME] NULL,
 PRIMARY KEY CLUSTERED ([id] ASC) ON [PRIMARY]
)

GO

CREATE TABLE [dbo].[M2_maintain](
	[id] [INT] IDENTITY(1,1) NOT NULL,
	[MHLID] [INT] NULL,
	[pType] [INT] NULL,
	[title] [NVARCHAR](100) NULL,
	[date1] [DATETIME] NULL,
	[num1] [decimal](25, 12) NULL,
	[TimeUnit] [INT] NULL,
	[num2] [decimal](25, 12) NULL,
	[Unit2] [INT] NULL,
	[reason] [NVARCHAR](500) NULL,
	[intro] [NTEXT] NULL,
	[cateid] [VARCHAR](8000) NULL,
	[del] [INT] NULL,
	[Creator] [INT] NULL,
	[indate] [DATETIME] NULL,
	[upuser] [int] NULL,	--最近操作人员
	[uptime] [datetime] NULL, --最近操作时间
  PRIMARY KEY CLUSTERED ([id] ASC) ON [PRIMARY]
)

GO

CREATE TABLE [dbo].[M2_MachineComponent](
	[ID] [INT] IDENTITY(1,1) NOT NULL,
	[MachineID] [INT] NULL,
	[title] [NVARCHAR](100) NULL,
	[begindate] [DATETIME] NULL,
	[locking] [INT] NULL,
	[remindcyc] [decimal](25, 12) NULL,
	[remindunit] [INT] NULL,
	[remindPerson] [VARCHAR](8000) NULL,
	[intro] [NTEXT] NULL,
	[Creator] [INT] NULL,
	[indate] [DATETIME] NULL,
	[upuser] [int] NULL,	--最近操作人员
	[uptime] [datetime] NULL, --最近操作时间
	PRIMARY KEY CLUSTERED ([ID] ASC) ON [PRIMARY]
)

GO

CREATE TABLE [dbo].[M2_MachineCalendar](
	[ID] [INT] IDENTITY(1,1) NOT NULL,
	[title] [NVARCHAR](100) NULL,
	[begindate] [DATETIME] NULL,
	[enddate] [DATETIME] NULL,
	[loopday] [INT] NULL,
	[Creator] [INT] NULL,
	[indate] [DATETIME] NULL,
	PRIMARY KEY CLUSTERED ([ID] ASC) ON [PRIMARY]
)

GO

CREATE TABLE [dbo].[M2_MachineClist](
	[ID] [INT] IDENTITY(1,1) NOT NULL,
	[MCID] [INT] NULL,
	[MachineID] [INT] NULL,
 PRIMARY KEY CLUSTERED ([ID] ASC) ON [PRIMARY]
)

GO

CREATE TABLE [dbo].[M2_MachineCdate](
	[ID] [INT] IDENTITY(1,1) NOT NULL,
	[MCID] [INT] NULL,
	[mDay] [DATETIME] NULL,
	[mStatus] [INT] NULL,
  PRIMARY KEY CLUSTERED ([ID] ASC) ON [PRIMARY]
)

GO

CREATE TABLE [dbo].[M2_ManuPlans](
	[ID] [INT] IDENTITY(1,1) NOT NULL,
	[title] [NVARCHAR](100) NULL,
	[MPSBH] [NVARCHAR](50) NULL,
	[Route] [INT] NULL,
	[PRI] [INT] NULL,
	[status] [INT] NULL,
	[LastApproveTime] [datetime] null,
	[LastApproveUser] [int] null,
	[intro] [NTEXT] NULL,
	[Creator] [INT] NULL,
	[inDate] [DATETIME] NULL,
	[del] [INT] NULL,
	[delcate] [INT] NULL,
	[deltime] [DATETIME] NULL,
	[cateidWA] [VARCHAR](8000) NULL,
	[upuser] [int] NULL,	--最近操作人员
	[uptime] [datetime] NULL, --最近操作时间
    [ExecQcCheck] [INT] NULL,
  PRIMARY KEY CLUSTERED ([ID] ASC) ON [PRIMARY]
)

GO

CREATE TABLE [dbo].[M2_ManuPlanLists](
	[ID] [INT] IDENTITY(1,1) NOT NULL,
	[PID] [INT] NULL,
	[MPSID] [INT] NULL,
	[ProductID] [INT] NULL,
	[unit] [INT] NULL,
	[commUnitAttr] [nvarchar](200) NULL,
	[NumPlan] [decimal](25, 12) NULL,
	[BOMID] [INT] NULL,
	[DateBegin] [DATETIME] NULL,
	[DateEnd] [DATETIME] NULL,
	[DateDelivery] [DATETIME] NULL,
	[del] [INT] NULL,
	[intro] [NTEXT] NULL,
	[PreID] [INT] NULL,
	[ZdyHashKey] [INT] NULL,
 PRIMARY KEY CLUSTERED ([ID] ASC) ON [PRIMARY]
)

--@##mode:index;clustered:false;fields:MPSID
--@##mode:index;clustered:false;fields:PreID

GO

CREATE TABLE [dbo].[M2_BOM](
	[ID] [INT] IDENTITY(1,1) NOT NULL,
	[BOMBH] [NVARCHAR](50) NULL,
	[title] [NVARCHAR](100) NULL,
	[billType] [INT] NULL,
	[isMain] [INT] NULL,
	[fromType] [INT] NULL,
	[fromID] [INT] NULL,
	[intro] [NTEXT] NULL,
	[Creator] [INT] NULL,
	[indate] [DATETIME] NULL,
	[status] [INT] NULL,
	[LastApproveTime] [datetime] null,
	[LastApproveUser] [int] null,
	[del] [INT] NULL,
	[TempSave] [INT] NULL,
	[delcate] [INT] NULL,
	[deltime] [DATETIME] NULL,
	[Import] [INT] NULL,
	[upuser] [int] NULL,	--最近操作人员
	[uptime] [datetime] NULL, --最近操作时间
	[oldverid] [int] NULL,
	[OtherUnit] [NVARCHAR](200) NULL,
	[isStop] [INT] NULL DEFAULT (0)
 PRIMARY KEY CLUSTERED ([ID] ASC) ON [PRIMARY]
)

--@##mode:index;clustered:false;fields:billType
--@##mode:index;clustered:false;fields:del,status;include:Creator
GO

CREATE TABLE [dbo].[M2_BOMList](
	[ID] [INT] IDENTITY(1,1) NOT NULL,
	[ParentID] [INT] NULL,
	[BOM] [INT] NULL,
	[ProductID] [INT] NULL,
	[RankCode] [INT] NULL,
	[WPROC] [INT] NULL,
	[Role] [INT] NULL,
	[PCWastage] [decimal](25, 12) NULL,
	[Mtype] [INT] NULL,
	[unit] [INT] NULL,
	[bl] [decimal](25, 12) NULL,
	[Num] [decimal](25, 12) NULL,
	[ChildID] [INT] NULL,
	[del] [INT] NULL,
	[rowindex] [INT] NULL,
	[oldverid] [INT] NULL,
	[oldbomid] [INT] NULL,
 PRIMARY KEY CLUSTERED ([ID] ASC) ON [PRIMARY]
)
--@##mode:index;clustered:false;fields:BOM;include:ProductID
--@##mode:index;clustered:false;fields:ProductID;include:BOM
GO

CREATE TABLE [dbo].[M2_OutOrderlists_wl](
	[ID] [INT] IDENTITY(1,1) NOT NULL,
	[outID] [INT] NULL,
	[molist] [INT] NULL,
	[pmolist] [INT] NULL,
	[WFPAID] [INT] NULL,
	[WalID] [INT] NULL,
	[BomListID] [INT] NULL,
	[productID] [INT] NULL,
	[unit] [INT] NULL,
	[num] [decimal](25, 12) NULL,
	[remark] [NTEXT] NULL,
	[del] [INT] NULL,
	[Mergeinx] [INT] NULL,
	[MType] [INT] NULL,
	[analysislistid] [int] NULL,
	[RegedNum] [decimal](25, 12) NULL,
    [llstatus] int,
	[ZdyHashKey] [INT] NULL,
 PRIMARY KEY CLUSTERED ([ID] ASC) ON [PRIMARY]
)
--@##mode:index;clustered:false;fields:outID
--@##mode:index;clustered:false;fields:llstatus;include:outID
--@##mode:index;clustered:false;fields:WalID
GO

CREATE TABLE [dbo].[M2_OutOrderlists](
	[ID] [INT] IDENTITY(1,1) NOT NULL,
	[BomListID] [INT] NULL,
	[outID] [INT] NULL,
	[molist] [INT] NULL,
    [WAID] [INT] NULL,
	[WFPAID] [INT] NULL,
	[productid] [INT] NULL,
	[dataType] [INT] NOT NULL DEFAULT ((0)),
	[unit1] [INT] NULL,
	[num1] [decimal](25, 12) NULL,
	[price1] [decimal](25, 12) NULL,
	[priceAfterTax] [decimal](25, 12) NULL,
	[invoiceType] [INT] NULL,
	[taxRate] [decimal](25, 12) NULL,
	[taxValue] [decimal](25, 12) NULL,
	[money1] [decimal](25, 12) NULL,
	[moneyAfterTax] [decimal](25, 12) NULL,
	[money1_rmb] [decimal](25, 12) NULL,
	[DateDelivery] [DATETIME] NULL,
	[remark] [NTEXT] NULL,
	[del] [INT] NULL,
	[Mergeinx] [INT] NULL,
    [ReceivingNum] [decimal](25, 12),--收货数量
	[ReworkNum] [decimal](25, 12),--返工数量
	[InspectionNum] [decimal](25, 12),--送检数量
    [rowindex] [INT] NULL,
	[Concessions] [decimal](25, 12) NULL default(0),
	[TaxDstYhPrice]  decimal(25, 12) not null default(0),
	[TaxDstYhMoney]  decimal(25, 12)  not null default(0),
    [Y_TaxDstYhPrice]  decimal(25, 12) not null default(0),
	[Y_TaxDstYhMoney]  decimal(25, 12)  not null default(0),
    [CostDifference]  decimal(25, 12)  not null default(0),
	[ZdyHashKey] [INT] NULL,
 PRIMARY KEY CLUSTERED(	[ID] ASC ) ON [PRIMARY]
) 
--@##mode:index;clustered:false;fields:outID
--@##mode:index;clustered:false;fields:del,molist;include:ID
--@##mode:index;clustered:false;fields:WFPAID
GO

CREATE TABLE [dbo].[M2_OutOrder](
	[ID] [INT] IDENTITY(1,1) NOT NULL,
	[sn] [NVARCHAR](50) NULL,
	[title] [NVARCHAR](100) NULL,
	[gys] [INT] NULL,
	[person] [INT] NULL,
	[phone] [NVARCHAR](100) NULL,
	[mobile] [NVARCHAR](100) NULL,
	[ourperson] [INT] NULL,
	[isNeedWL] [INT] NULL,
	[premoney] [decimal](25, 12) NULL,
	[bz] [INT] NULL,
	[hl] [decimal](25, 12) NULL,
	[yhtype] [INT] NULL,
	[yhmoney] [decimal](25, 12) NULL,
	[discount] [decimal](25, 12) NULL,
	[mxyhmoney] [decimal](25, 12) NULL,
	[money1] [decimal](25, 12) NULL,
	[money1_rmb] [decimal](25, 12) NULL,
	[odate] [DATETIME] NULL,
	[payPlan] [INT] NULL,
	[invoicePlan] [INT] NULL,
	[remark] [NTEXT] NULL,
	[creator] [INT] NULL,
	[indate] [DATETIME] NULL,
	[status] [INT] NULL,
	[LastApproveTime] [datetime] null,
	[LastApproveUser] [int] null,
	[TempSave] [INT] NULL,
	[dataType] [INT] NULL,
	[wwType] [INT] NULL,
	[del] [INT] NULL,
	[delcate] [INT] NULL,
	[deltime] [DATETIME] NULL,
	[upuser] [INT] NULL,
	[uptime] [DATETIME] NULL,
	[Stopstatus] [int] NULL,
	[ManuCostStatus] int NULL,
    [InvoicePlanInStockType] int default 0,--收票计划入库类型0：代表无设置，1：按实际合格入库数量生成=1;按实际合格、报废入库数量生成=2;
	[PayPlanInStockType] int default 0,--付款计划入库类型0：代表无设置，1：按实际合格入库数量生成=1;按实际合格、报废入库数量生成=2;
    [ReceivingStatus] [int] default 1,--收货状态 0=老数据/1未收货/2部分收货/3收货完毕/4手动收货完毕
	[InspectionStatus] [int] default 1, --1未送检/2部分送检/3送检完毕/4超量送检
    [llstatus] int,
    [djstatus] int,
    [rkstatus] int,
    [Terminator] [INT] NULL,
    [TerminationTime] [datetime] NULL,
 PRIMARY KEY CLUSTERED ([ID] ASC) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

--@##mode:index;clustered:false;fields:isNeedWL,wwType,del
--@##mode:index;clustered:false;fields:wwType,del,status;include:ID
GO

CREATE TABLE [dbo].[M2_ManuOrders](
	[ID] [INT] IDENTITY(1,1) NOT NULL,
	[MAID] [INT] NULL,
	[AASID] [INT] NULL,
	[MPSID] [INT] NULL,
	[Route] [INT] NULL,
	[MOBH] [NVARCHAR](50) NULL,
	[title] [NVARCHAR](200) NULL,
	[Creator] [INT] NULL,
	[indate] [DATETIME] NULL,
	[status] [INT] NULL,
	[LastApproveTime] [datetime] null,
	[LastApproveUser] [int] null,
	[intro] [NTEXT] NULL,
	[Complete] [INT] NULL,
	[TempSave] [INT] NULL,
	[del] [INT] NULL,
	[delcate] [INT] NULL,
	[deltime] [DATETIME] NULL,
	[upuser] [INT] NULL,
	[uptime] [DATETIME] NULL,
	[Stopstatus] [INT] NULL,
	[HisID] [int] NULL,
	[HisCostStatus] [int] NULL,
	PRIMARY KEY CLUSTERED(	[ID] ASC ) ON [PRIMARY]
)
--@##mode:index;clustered:false;fields:del
GO

CREATE TABLE [dbo].[M2_ManuOrderLists](
	[ID] [INT] IDENTITY(1,1) NOT NULL,
	[PID] [INT] NULL,
	[MOrderID] [INT] NULL,
	[BomListID] [INT] NULL,
	[RankCode] [INT] NULL,
	[WProc] [INT] NULL,
	[MASLID] [INT] NULL,
	[AASLID] [INT] NULL,
	[MPSLID] [INT] NULL,
	[ProductID] [INT] NULL,
	[unit] [INT] NULL,
	[Num] [decimal](25, 12) NULL,
	[DateBegin] [DATETIME] NULL,
	[DateEnd] [DATETIME] NULL,
	[DateDelivery] [DATETIME] NULL,
	[remark] [NTEXT] NULL,
	[dataType] [INT] NULL,
	[role] [INT] NULL,
	[del] [INT] NULL,
	[IsMerge] [INT] NOT NULL DEFAULT ((0)),
	[MergeListIDs] [VARCHAR](4000) NULL,
    [ExecStatus] [int] NOT NULL DEFAULT ((0)),
	PRIMARY KEY CLUSTERED(	[ID] ASC ) ON [PRIMARY]
)

--@##mode:index;clustered:false;fields:MOrderID
--@##mode:index;clustered:false;fields:MPSLID
--@##mode:index;clustered:false;fields:role;include:[ID],[MOrderID],[ProductID],[DateBegin],[DateEnd]
--@##mode:index;clustered:false;fields:del,ExecStatus
--@##mode:index;clustered:false;fields:MASLID

GO

CREATE TABLE [dbo].[M2_ManuOrderAuto](
	[ID] [INT] IDENTITY(1,1) NOT NULL,
	[MOrderID] [INT] NULL,
	[yg] [INT] NULL,
	[ygcategory] [INT] NULL,
	[pg] [INT] NULL,
	[pgcateid] [NVARCHAR](4000) NULL,
	[ww] [INT] NULL,
	[wwsupplier] [INT] NULL,
	[del] [INT] NULL,
    [ExecQcCheck] [INT] NULL DEFAULT ((0)),
	PRIMARY KEY CLUSTERED(	[ID] ASC ) ON [PRIMARY]
)

GO

CREATE TABLE [dbo].[M2_MaterialOrders](
	[ID] [INT] IDENTITY(1,1) NOT NULL,
	[title] [NVARCHAR](200) NULL,
	[MOBH] [NVARCHAR](50) NULL,
	[date1] [DATETIME] NULL,
	[status] [INT] NULL,
	[LastApproveTime] [datetime] null,
	[LastApproveUser] [int] null,
	[intro] [NTEXT] NULL,
	[Creator] [INT] NULL,
	[indate] [DATETIME] NULL,
	[tempsave] [INT] NULL,
	[del] [INT] NULL,
	[delcate] [INT] NULL,
	[deltime] [DATETIME] NULL,
	[upuser] [int] NULL,	--最近操作人员
	[uptime] [datetime] NULL, --最近操作时间
	[Import] [INT] NULL,
    [MaterialType] [INT],
    [ckstatus] [INT],
    [cknum] [decimal](25, 12) default 0,
    [cknum2] [decimal](25, 12) default 0,
	PRIMARY KEY CLUSTERED(	[ID] ASC ) ON [PRIMARY]
)
--@##mode:index;clustered:false;fields:MaterialType
GO

CREATE TABLE [dbo].[M2_MaterialOrderLists](
	[ID] [INT] IDENTITY(1,1) NOT NULL,
	[MOID] [INT] NULL,
	[BomList] [INT] NULL,
	[poType] [INT] NULL,
	[ListID] [INT] NULL,
	[ProductID] [INT] NULL,
	[unit] [INT] NULL,
	[num1] [decimal](25, 12) NULL,
	[MType] [INT] NULL,
	[intro] [NTEXT] NULL,
	[DateDelivery] [DATETIME] NULL,
	[del] [INT] NULL,
	[Mergeinx] [INT] NULL,
    [rowindex] [INT] NULL,
    [OutkuPerson] [INT] NULL,
    [cknum] [decimal](25, 12) default 0,
    [cknum2] [decimal](25, 12) default 0,
    [WFPAID] [INT] NULL,
	[ZdyHashKey] [INT] NULL,
	PRIMARY KEY CLUSTERED(	[ID] ASC ) ON [PRIMARY]
)
--@##mode:index;clustered:false;fields:poType,ListID,del
--@##mode:index;clustered:false;fields:del,poType;include:ID,MOID,ListID,num1,cknum,cknum2
--@##mode:index;clustered:false;fields:MOID
--@##mode:index;clustered:false;fields:Mergeinx
--@##mode:index;clustered:false;fields:poType;include:MOID,ListID
--@##mode:index;clustered:false;fields:ProductID;include:MOID,poType,ListID
GO

CREATE TABLE [dbo].[M2_WorkAssigns](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[WABH] [nvarchar](50) NULL,
	[title] [nvarchar](100) NULL,
	[DateWA] [datetime] NULL,
	[intro] [NTEXT] NULL,
	[remark] [nvarchar](500) NULL,
	[ptype] [int] NULL,
	[WAID] [int] NULL,	--作为返工单必有原始派工单
	[ddlistid] [int] NULL,
	[MOrderID] [int] NULL,
	[WProID] [int] NULL,
    [wfScheme] [int] NULL,
	[BomList] [int] NULL,
    [BOM] [int] NULL,
	[BomTxt] [nvarchar](200) NULL,
    [QTListID] [int] NULL,
	[ProductID] [int] NULL,
	[unit] [int] NULL,
	[NumMake] [decimal](25, 12) NULL,
	[Cateid_WA] [varchar](8000) NULL,
	[DateStart] [datetime] NULL,
	[DateEnd] [datetime] NULL,
    [DateDelivery] [datetime] NULL,
	[zdy1] [nvarchar](200) NULL,
	[zdy2] [nvarchar](200) NULL,
	[zdy3] [nvarchar](200) NULL,
	[zdy4] [nvarchar](200) NULL,
	[zdy5] [int] NULL,
	[zdy6] [int] NULL,
	[dataType] [int] NULL,
    [fromtype] int,   --来源类型：1：手动添加，2：订单生成
    [WFName] nvarchar(100),    --派工单为手动添加时有此值
	[WFBH] nvarchar(50),--派工单为手动添加时有此值  
	[Creator] [int] NULL,
	[inDate] [datetime] NULL,
	[del] [int] NULL,
	[Status] [int] NULL,
	[LastApproveTime] [datetime] null,
	[LastApproveUser] [int] null,
	[delcate] [int] NULL,
	[deltime] [datetime] NULL,
	[upuser] [int] NULL,	--最近操作人员
	[uptime] [datetime] NULL, --最近操作时间
	[tempsave] [INT] NULL,
	[Urgent] [DATETIME] NULL,
	[SPStatus] [INT] NULL,
    [isHasXLH] [int] NOT NULL DEFAULT ((0)),
	[isHasPH] [int] NOT NULL DEFAULT ((0)),
	[ManuCostStatus] int NULL,
    [llstatus] int,
    [zjstatus] int,
    [rkstatus] int,
    [djstatus] int,
    [ExecQcCheck] [INT] NULL,
    [Sjstatus] [INT] NULL DEFAULT ((0)),
    [ProduceStatus] [INT] NULL DEFAULT ((0)),
    [ReturnProcess] [INT] NULL DEFAULT ((0)),
    [ReworkFromID] [INT] NULL DEFAULT ((0)),
    [ScrapFromID] [INT] NULL DEFAULT ((0)),
    [Terminator] [INT] NULL,
    [TerminationTime] [datetime] NULL,
    [isOpenWastAge] [INT] NOT NULL DEFAULT ((1)),
	PRIMARY KEY CLUSTERED(	[ID] ASC ) ON [PRIMARY]
) 
--@##mode:index;clustered:false;fields:productid
--@##mode:index;clustered:false;fields:QTListID
--@##mode:index;clustered:false;fields:ddlistid,del;include:ID
--@##mode:index;clustered:false;fields:ptype,del,Status;include:ID
--@##mode:index;clustered:false;fields:ptype,del,tempsave,NumMake;include:ID
--@##mode:index;clustered:false;fields:fromtype,del;include:inDate,ScrapFromID
--@##mode:index;clustered:false;fields:WABH
--@##mode:index;clustered:false;fields:djstatus;include:WAID
--@##mode:index;clustered:false;fields:wfScheme

GO

CREATE TABLE [dbo].[M2_WorkAssignLists](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[WAID] [int] NULL,
	[BomList] [int] NULL,
	[ProductID] [int] NULL,
	[unit] [int] NULL,
	[bl] [decimal](25, 12) NULL,
    [WastAge] [decimal](25, 12) NOT NULL DEFAULT ((0)),
	[num1] [decimal](25, 12) NULL,
	[DateDelivery] [datetime] NULL,
	[zdy1] [nvarchar](200) NULL,
	[zdy2] [nvarchar](200) NULL,
	[zdy3] [nvarchar](200) NULL,
	[zdy4] [nvarchar](200) NULL,
	[zdy5] [int] NULL,
	[zdy6] [int] NULL,
	[intro] [NTEXT] NULL,
	[mtype] [int] NULL,
	[del] [int] NULL,
	[oldID] [int] NULL, --替代料的原始对应物料明细ID
	[Mtype2] [int] NULL,
    [rowindex] [int] NULL,
	[analysislistid] [int] NULL,
	[RegedNum] [decimal](25, 12) NULL,
    [llstatus] int,
    [WFPAID] [int] NULL DEFAULT ((0)),
	PRIMARY KEY CLUSTERED(	[ID] ASC ) ON [PRIMARY]
)
--@##mode:index;clustered:false;fields:WAID
--@##mode:index;clustered:false;fields:llstatus;include:WAID
--@##mode:index;clustered:false;fields:del,analysislistid;include:ID

GO

CREATE TABLE [dbo].[M2_WFP_plan](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[MASID] [int] NULL,
	[WFID] [int] NULL,
	[WPID] [int] NULL,
	[ord] [int] NULL,
	[isOut] [int] NULL,
	[result] [bit] NULL,
	[remark] [ntext] NULL,
	[rptime] [decimal](25, 12) NULL,
	[wtime] [decimal](25, 12) NULL,
	[wNum] [decimal](25, 12) NULL,
	[mtime] [decimal](25, 12) NULL,
	[mNum] [decimal](25, 12) NULL,
	[oldWFID] [int] NULL,
	[oldWFPID] [int] NULL,
	[ReportingExceptionStrategy] [int] NULL DEFAULT (0),
	[ReportingUnit] [nvarchar](2000) NULL,
	[BatchNumberStart] [int] NULL DEFAULT (0),
	[SerialNumberStart] [int] NULL DEFAULT (0),
	[IntermediateProduct] [nvarchar](500) NULL,
	[ConversionBL] [decimal](25, 12) NULL DEFAULT (1),
	[ReportingRounding] [int] NULL DEFAULT (0),
    [ExecTask] [int] NULL DEFAULT (0),
    [ExecCheck] [int] NULL DEFAULT (0),
	PRIMARY KEY CLUSTERED(	[ID] ASC ) ON [PRIMARY]
)
--@##mode:index;clustered:false;fields:WFID
GO

CREATE TABLE [dbo].[M2_WFP_Assigns](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[WFID] [int] NULL,
	[WFPID] [int] NULL,
	[WAID] [int] NULL,
	[ord] [int] NULL,
	[WCenter] [int] NULL,
	[WPID] [int] NULL,
    [MachineID] [int] NULL,
	[NumMake] [decimal](25, 12) NULL,
	[isOut] [int] NULL,
    [unit] [int] NULL,
	[wtime] [decimal](25, 12) NULL,
	[DateStart] [datetime] NULL,
	[DateEnd] [datetime] NULL,
	[result] [bit] NULL,
	[remark] [ntext] NULL,
	[del] [int] NULL,
	[cateid] [varchar](5000) NULL,
	[ph] [varchar](1000) NULL,
	[oldID] [int] NULL,
    [Finished] [int] NOT NULL default 0,
    [oldNumMake] [decimal](25, 12) NULL,
   	[WF_QCSchemeList] [int] NOT NULL DEFAULT ((0)),
	[ReportingExceptionStrategy] [int] NULL DEFAULT (0),
	[ReportingUnit] [int] NULL,
	[BatchNumberStart] [int] NULL DEFAULT (0),
	[SerialNumberStart] [int] NULL DEFAULT (0),
	[IntermediateProduct] [nvarchar](500) NULL,
	[ConversionBL] [decimal](25, 12) NULL DEFAULT (1),
	[ReportingRounding] [int] NULL DEFAULT (0),
	[PreIndex] [int] NULL,
    [ExecTask] [int] NULL DEFAULT ((0)),
    [ExecCheck] [int] NULL DEFAULT ((0)),
    [TaskStatus] [int] NULL DEFAULT ((0)),
    [TaskStop] [int] NULL DEFAULT ((0)),
    [ExecStatus] [int] NULL DEFAULT ((0)),
    [CanExec] [int] NULL DEFAULT ((0)),
    [Terminator] [INT] NULL,
    [TerminationTime] [datetime] NULL,
	PRIMARY KEY CLUSTERED(	[ID] ASC ) ON [PRIMARY]
)
--@##mode:index;clustered:false;fields:WAID
--@##mode:index;clustered:false;fields:del;include:ID,WAID
--@##mode:index;clustered:false;fields:[del];include:[ID],[WPID],[Finished]

GO

CREATE TABLE [dbo].[M2_QualityTestings](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[title] [nvarchar](100) NULL,
	[QTBH] [nvarchar](50) NULL,
	[QTDate] [datetime] NULL,
	[Inspector] [int] NULL,
	[Creator] [int] NULL,
	[indate] [datetime] NULL,
	[QTMode] [int] NULL,
	[QTType] [int] NULL,
	[del] [int] NULL,
	[intro] [NTEXT] NULL,
	[ddno] [int] NULL,
	[poType] [int] NULL,
	[upuser] [int] NULL,
	[uptime] [datetime] NULL,
	[delcate] [int] NULL,
	[deltime] [datetime] NULL,
	[CkStatus] [int] NULL,
	[CkOpinion] [nvarchar](4000) NULL,
	[CKUser] [int] NULL,
	[batchRowIndex] [int] NULL,
    [QTResultAll] [int] NULL,
    [TaskId] int,--质检任务单ID	M2_OutsourceInspection表qctype=1或3 时的ID
    [RKStatus] [INT] NOT NULL DEFAULT (0),
    [BFRKStatus] [INT] NOT NULL DEFAULT (0),
    [FGStatus] [INT] NOT NULL DEFAULT (0),
	PRIMARY KEY CLUSTERED(	[ID] ASC ) ON [PRIMARY]
)
--@##mode:index;clustered:false;fields:del,poType;include:ID,QTMode,CkStatus
--@##mode:index;clustered:false;fields:del,ddno,poType
--@##mode:index;clustered:false;fields:del;include:[ID],[poType],[CkStatus],[QTResultAll]

GO

CREATE TABLE [dbo].[M2_QualityTestingLists](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[dataType] [int] NULL,
	[QTID] [int] NULL,
	[bid] [int] NULL,
	[SerialNumber] [decimal](25, 12) NULL,
	[NumTesting] [decimal](25, 12) NULL,
	[OkNum] [decimal](25, 12) NULL,
	[FailNum] [decimal](25, 12) NULL,
	[NumBF] [decimal](25, 12) NULL,
	[NumSPOK] [decimal](25, 12) NULL,
	[NumScrap] [decimal](25, 12) NULL,
	[NumBFKuin] [decimal](25, 12) NULL,
	[NumOKKuin] [decimal](25, 12) NULL,
	[NumFGOut] [decimal](25, 12) NULL,
	[QualityLevel] [int] NULL,
	[codeBatch] [INT] NOT NULL DEFAULT ((0)),
	[ph] [nvarchar](2000) NULL,
	[xlh] [nvarchar](2000) NULL,
	[remark] [NTEXT] NULL,
	[datesc] [datetime] NULL,
	[dateyx] [datetime] NULL,
	[del] [int] NULL,
	[QTResult] [int] NULL,
	[bhgOpinion] [int] NULL,
	[BFOpinion] [int] NULL,
	[oriSeralNumber] [int] NULL,
    [TaskMXId] [int],--质检任务单明细ID	M2_OutsourceInspection表qctype=1或3 时的M2_OutsourceInspectionList表ID
	PRIMARY KEY CLUSTERED(	[ID] ASC ) ON [PRIMARY]
)

--@##mode:index;clustered:false;fields:QTID,del;include:dataType,bid,SerialNumber,NumBF,QTResult
--@##mode:index;clustered:false;fields:bid,del
--@##mode:index;clustered:false;fields:WAID,WFPAID,codeProduct,codeBatch
--@##mode:index;clustered:false;fields:del;include:dataType,QTID,bid,SerialNumber,NumTesting,NumBF,NumScrap,QTResult

GO

CREATE TABLE [dbo].[M2_PlanBomList](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[PID] [int] NULL,
	[title] [nvarchar](100) NULL,
	[MBOMID] [int] NULL,
	[BomID] [int] NULL,
	[parentBomID] [int] NULL,
	[productID] [int] NULL,
	[RankCode] [varchar](5) NULL,
	[unit] [int] NULL,
	[num] [decimal](25, 12) NULL,
	[bl] [decimal](25, 12) NULL,
	[ChildID] [int] NULL,
	[WProc] [int] NULL,
	[PCWastage] [decimal](25, 12) NULL,
	[Role] [int] NULL,
	[SaveNum] [decimal](25, 12) NULL,
	[Mtype] [int] NULL,
	[MPLID] [int] NULL,	--生产计划明细ID
	[fullsort] [nvarchar](500) NULL,
	PRIMARY KEY CLUSTERED(	[ID] ASC ) ON [PRIMARY]
)
--@##mode:index;clustered:false;fields:PID
--@##mode:index;clustered:false;fields:MPLID

GO

CREATE TABLE [dbo].[M2_WorkPosition_WP](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[WCenter] [int] NULL,
	[StationID] [int] NULL,
	[workPosition] [int] NULL,
	[OPNumber] [int] NULL,
	PRIMARY KEY CLUSTERED ([ID] ASC) ON [PRIMARY]
)
GO

CREATE TABLE [dbo].[M2_WFProduct](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[WFID] [int] NULL,
	[POrd] [int] NULL,
	[unit] [int] NULL,
	[remark] [nvarchar](500) NULL,
	[del] [int] NULL,
    [rowindex] [int] NULL,
	PRIMARY KEY CLUSTERED ([ID] ASC) ON [PRIMARY]
)
GO

CREATE TABLE [dbo].[M2_PriceRateList](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[WFID] [int] NULL,
	[WFPID] [int] NULL,
	[WPID] [int] NULL,
	[sn] [nvarchar](50) NULL,
	[productID] [int] NULL,
	[unit] [int] NULL,
	[price] [decimal](25, 12) NULL,
	[remark] [ntext] NULL,
	[del] [int] NULL,
	[PRID] [int] NULL,
	[date1] [datetime] NULL,
	[rowindex] [int] null,
	PRIMARY KEY CLUSTERED ([ID] ASC) ON [PRIMARY]
)
--@##mode:index;clustered:false;fields:productid
--@##mode:index;clustered:false;fields:wpid


GO

CREATE TABLE [dbo].[M2_PriceRate](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[title] [nvarchar](200) NULL,
	[id_sp] [int] NULL,
	[cateid_sp] [int] NULL,
	[status] [int] NULL,
    [intro] [nvarchar](4000) NULL,
	[Creator] [int] NULL,
	[indate] [datetime] NULL,
	[del] [int] NULL,
	[tempsave] [int] NULL,
	[isobselete] [int] NULL,
	[PR_excel_drsign] [int] NULL,
    [uptime] [datetime] NULL,
	[Import] [varchar](4000) NULL,
	[upuser] [varchar](4000) NULL,
	[oldverid] [int] NULL,
	PRIMARY KEY CLUSTERED ([ID] ASC) ON [PRIMARY]
)
GO

CREATE TABLE [dbo].[M2_PersonList_WP](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[WCenter] [int] NULL,
	[StationID] [int] NULL,
	[Capacity]	[decimal](25, 12) NULL,
	[ProducePerson] [int] NULL,
	[update] [datetime] NULL,
	PRIMARY KEY CLUSTERED ([ID] ASC) ON [PRIMARY]
)
GO

CREATE TABLE [dbo].[M2_MachineList_WP](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[WCenter] [int] NULL,
	[StationID] [int] NULL,
	[MachineLID] [int] NULL,
	PRIMARY KEY CLUSTERED ([ID] ASC) ON [PRIMARY]
)
GO

CREATE TABLE [dbo].[M2_MaterialRegisterLists](
	[ID] [INT] IDENTITY(1,1) NOT NULL,
	[MRID] [INT] NULL,
	[BomList] [INT] NULL,
	[MOLID] [INT] NULL,
	[kuoutlist2] [INT] NULL,
    [kuoutlist] [INT] NULL,
	[ListID] [INT] NULL,
	[ProductID] [INT] NULL,
	[unit] [INT] NULL,
	[num1] [decimal](25, 12) NULL,
	[oldnum1] [decimal](25, 12) NULL,
	[reason] [INT] NULL,
	[intro] [NTEXT] NULL,
	[del] [INT] NULL,
	[Mergeinx] [INT] NULL,
	[zy] [INT] NULL,
    [PoTypeV] [INT] NULL,
	[mapping] [varchar](8000) NULL,
    [RowIndex] [INT] NULL,
	[ZdyHashKey] [INT] NULL,
 PRIMARY KEY CLUSTERED ([ID] ASC) ON [PRIMARY]
)
--@##mode:index;clustered:false;fields:ListID,del;include:MRID
--@##mode:index;clustered:false;fields:MOLID,del;include:MRID,num1
--@##mode:index;clustered:false;fields:MRID;include:ListID,num1
--@##mode:index;clustered:false;fields:del;include:MRID,MOLID,num1
--@##mode:index;clustered:false;fields:kuoutlist2;include:MRID
GO

CREATE TABLE [dbo].[M2_MaterialRegisters](
	[ID] [INT] IDENTITY(1,1) NOT NULL,
	[title] [NVARCHAR](200) NULL,
	[MOBH] [NVARCHAR](50) NULL,
	[date1] [DATETIME] NULL,
	[canRk] [INT] NULL,
	[totalnum] [decimal](25, 12) NULL,
	[intro] [NTEXT] NULL,
	[status] [INT] NULL,
	[LastApproveTime] [datetime] null,
	[LastApproveUser] [int] null,
	[Creator] [INT] NULL,
	[indate] [DATETIME] NULL,
	[tempsave] [INT] NULL,
	[OrderType] [INT] NULL,
	[poType] [INT] NULL,
	[bid] [INT] NULL,
	[del] [INT] NULL,
	[delcate] [INT] NULL,
	[deltime] [DATETIME] NULL,
	[upuser] [INT] NULL,
	[uptime] [DATETIME] NULL,
    [ForKuinID] [INT] NULL,
    [Accountable] [INT] NULL,
    [PersonLiable] [INT] NULL,
    [iscostcollect] [INT] NOT NULL DEFAULT (0),
    [ShareRatio] [decimal](25, 12) NULL,
	[CollectDate] [datetime] null,
  PRIMARY KEY CLUSTERED ([ID] ASC) ON [PRIMARY]
)
--@##mode:index;clustered:false;fields:poType,del;include:ID,status,bid
--@##mode:index;clustered:false;fields:poType,bid,del;include:ID,status
--@##mode:index;clustered:false;fields:OrderType,del;include:ID,date1,indate
--@##mode:index;clustered:false;fields:ForKuinID
--@##mode:index;clustered:false;fields:status

GO

CREATE TABLE [dbo].[M2_RegisterOccupy](
    [Id] [INT] IDENTITY(1,1) NOT NULL,
    [MRID] [INT],
	[MRLID] [INT] NULL,
	[kuoutlist2] [INT] NULL,
	[unit] [INT] NULL,
	[num] [decimal](25, 12) NULL,
	[unit1] [INT] NULL,
	[num1] [decimal](25, 12) NULL,
	[isOld] [INT] NULL,
    [cbprice] [decimal](25, 12) NOT NULL DEFAULT (0),
    [cbmoney] [decimal](25, 12) NOT NULL DEFAULT (0),
    [SerialID] [INT] NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC) ON [PRIMARY]
)
--@##mode:index;clustered:false;fields:isOld;include:MRLID,kuoutlist2,num1
--@##mode:index;clustered:false;fields:kuoutlist2,isOld;include:MRLID,num1
--@##mode:index;clustered:false;fields:MRLID,isOld
GO

--Attrs:帐套下可用
CREATE TABLE [dbo].[sys_sdk_BillTempSaveDatas](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[BillType] [int] NULL,
    [ClassIden] [int] NOT NULL DEFAULT (0),
	[Title] [nvarchar](200) NULL,
	[Creator] [int] NULL,
	[AddTime] [datetime] NULL,
	[BillData] [ntext] NULL,
	[QueryString] [nvarchar](1000) NULL,
    PRIMARY KEY CLUSTERED
    (
        [Id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[M2_Procedures_Replace](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[WPID] [int] NULL,
	[ReplaceWPID] [int] NULL,
	[Replacesort] [int] NULL,
	[ReplaceNum] [int] NULL,
	[del] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [Id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[M2_ProcedureProgres](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[WAID] [int] NULL,
	[WFPAID] [int] NULL,
	[Procedure] [int] NULL,
	[bh] [nvarchar](200) NULL,
	[title] [nvarchar](200) NULL,
	[machineID] [int] NULL,
	[MLWPID] [int] NULL,
	[codeProduct] [nvarchar](200) NOT NULL DEFAULT (('')),
	[codeBatch] [INT] NOT NULL DEFAULT ((0)),
	[cateid] [varchar](8000) NULL,
	[num1] [decimal](25, 12) NULL,
	[result] [int] NULL,
	[reason] [varchar](100) NULL,
	[creator] [int] NULL,
	[inDate] [datetime] NULL,
	[intro] [ntext] NULL,
	[del] [int] NULL,
	[ph] [varchar](100) NULL,
	[upuser] [int] NULL,	--最近操作人员
	[uptime] [datetime] NULL, --最近操作时间
    [unitTime] [int] NULL,--加工工时单位
    [wtime] [decimal](25, 12) NULL,--加工工时
	[reworkType] [int] NULL, --返工工序类型-0自制来源1委外来源2工序质检来源
	[reworkFromID] [int] NULL, --返工来源单ID
	[oriSeralNumber] [int] NULL, --序列号ID
    [execDate] [datetime] NULL, --实际加工日期
    [NeedCheck] [int] NULL,
    [CheckPerson] [int] NULL,
    [CheckResult] [int] NULL,
    [CheckIdea] [nvarchar](2000) NULL,
    [ReworkMode] [int] NULL,
    [execDateBegin] [datetime] NULL,
    [BatchID] [int] NULL DEFAULT (0),
    [TaskID] [int] NULL DEFAULT (0),
    [BatchMxid] [int] NULL DEFAULT (0),
	PRIMARY KEY CLUSTERED ( [id] ASC ) ON [PRIMARY]
)

--@##mode:index;clustered:false;fields:WAID,WFPAID,oriSeralNumber,codeBatch
--@##mode:index;clustered:false;fields:WFPAID,del
--@##mode:index;clustered:false;fields:[creator],[del];include:[ID],[WAID],[WFPAID],[cateid],[num1],[result],[inDate],[unitTime],[wtime],[reworkType],[oriSeralNumber],[NeedCheck],[CheckPerson],[CheckResult],[BatchID],[BatchMxid]

GO

CREATE TABLE [dbo].[M2_CelueSet_Analysis](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[title] [nvarchar](200) NULL,
	[Gate1] [int] NULL,
	[Wastage] [int] NULL,
	[SafeStock] [int] NULL,
	[cks] [nvarchar](max) NULL,
	[intro] [ntext] NULL,
	[isStop] [int] NULL,
	[MaCeil] [int] not null default 0, --向上取整字段
    [EnableStockModel] [int] default 0,  --可用库存计算类型  0 无  1 库存数量+车间剩余数量 2 库存数量+车间剩余数量+在制/在途数量-预定数量
    [IsParentException] [int]  default 0, --父件例外策略 0 否  1 是
    [JoinMuilsUnit] [int] default 0, --是否考虑其他单位库存 0 否  1 是
    [ReplaceModel] [int] default 0,-- 物料替代方式 0 无 1 独立替代  2 混合替代  3 混合替代 
	[creator] [int] NULL,
	[inDate] [datetime] NULL,
	[del] [int] NULL,
	[delcate] [int] NULL,
	[deltime] [datetime] NULL,
	PRIMARY KEY CLUSTERED ( [id] ASC ) ON [PRIMARY]
)

GO

CREATE TABLE [dbo].[M2_MaterialAnalysis](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[title] [nvarchar](100) NULL,
	[MABH] [nvarchar](100) NULL,
	[Route] [int] NULL,			--生产路线 0 简易 1 LRP 2 MRP
	[CelueID] [int] NULL,		--选择的策略(M2_CelueSet_Analysis.id)
	[CelueName] [nvarchar](200) NULL,
	[Wastage] [int] NULL,		--考虑损耗率 0 否 1 是
	[SafeStock] [int] NULL,		--考虑安全库存 0 否 1 是
	[cks] [nvarchar](max) NULL, --库存参与仓库范围
	[Calculation] [int] NULL,	--计算方式 0 毛需求 1 净需求
	[status] [int] null DEFAULT (1),		--分析结果状态 1 .正常 2 .作废
	[creator] [int] NULL,
	[inDate] [datetime] NULL,
	[CompleteStatus] int NULL,
	[EnableStockModel] int NULL,
	[ReplaceModel] int NULL,
	[JoinMuilsUnit] int NULL,
	[IsParentException] int NULL,
	[del] [int] NULL,
	[delcate] [int] NULL,
	[deltime] [datetime] NULL,
	[upuser] [int] NULL,	--最近操作人员
	[uptime] [datetime] NULL, --最近操作时间
    [EnableStockInfoCacheTime] [datetime] NULL,
	[DataVersion] int NULL,
    [MaCeil] int NULL,
	PRIMARY KEY CLUSTERED ( [id] ASC ) ON [PRIMARY]
)

GO

CREATE TABLE [dbo].[M2_MaterialAnalysisList](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[PID] [int] NULL,			
	[RankCode] [varchar](5) NULL,		
	[bl] [decimal](25, 12) NULL,			
	[MASID] [int] NULL,			
	[BomListID] [int] NULL,		
	[WPROC] [int] NULL,			
	[dataType] [int] NULL,			
	[role] [int] NULL,			
	[ProductID] [int] NULL,		
	[Unit] [int] NULL,	
	[HD_CurrNum] [decimal](25, 12) NULL, --核定数量	
	[NeedNum] [decimal](25, 12) NULL,	
	[WastAge] [decimal](25, 12) NULL,	
	[GrossNum] [decimal](25, 12) NULL,	
	[SafeNum] [decimal](25, 12) NULL,		
	[CGNum] [decimal](25, 12) NULL,	
	[SCNum] [decimal](25, 12) NULL,	
	[CKNum] [decimal](25, 12) NULL,
	[HTNum] [decimal](25, 12) NULL,	
	[AssignNum] [decimal](25, 12) NULL,
	[DemandNum] [decimal](25, 12) NULL,	
	[RKNum] [decimal](25, 12) NULL,		
	[SYNum] [decimal](25, 12) NULL,		
	[CurrAssignNum] [decimal](25, 12) NULL,
	[CurrNum] [decimal](25, 12) NULL,		
	[CurrEnableKuNum] [decimal](25, 12) NULL,	
	[StopNum] [decimal](25, 12) NULL,	
	[ChildStopNum] [decimal](25, 12) NULL,	 	
	[Mo_UsedNum] [decimal](25, 12) NULL,   --领料出库确认释放	
	[MUsedNum] [decimal](25, 12) NULL,	
	[MOKNum] [decimal](25, 12) NULL,	
	[NodeDataType] int NULL,
    [AppendUser] int null,
    [AppendForBillID] int null,
    [AppendTime] datetime null,
    [AppendForBillType] int null,
	[AppendForSubstitution] int null,
	[MakePreDay] int null,	
	[CagouPreDay] int null,	
	[ChangePreBatch] [decimal](25, 12) NULL,	
	[ChangePreDay] int null,	
	[BatchNum] [decimal](25, 12) NULL,	
	[DateStart] [datetime] NULL,	
	[DateEnd] [datetime] NULL,	
	[DateDelivery] [datetime] NULL,	
	[intro] [NTEXT] NULL,	
	[listID] [int] NULL,
	[creator] [int] NULL,
	[inDate] [datetime] NULL,
	[del] [int] NULL,
	[oldID] [int] NULL, 
	[MergeId] int not null default((0)),
	[zdyHashKey] int NULL,
    [HD_NeedNum] [decimal](25, 12) NULL,
    [WorkAssignAndOutStopNum] [decimal](25, 12) NULL,
    [ChildWorkAssignAndOutStopNum] [decimal](25, 12) NULL,
    [YGStopNum] [decimal](25, 12) NULL,
	PRIMARY KEY CLUSTERED ( [id] ASC ) ON [PRIMARY]
)
--@##mode:index;clustered:true;fields:ID
--@##mode:index;clustered:false;fields:MASID
--@##mode:index;clustered:false;fields:role;include:ID,MASID,CurrNum,MOKNum
--@##mode:index;clustered:false;fields:ID,MASID;include:NeedNum,MUsedNum
--@##mode:index;clustered:false;fields:BomListID
--@##mode:index;clustered:false;fields:dataType,AppendUser
--@##mode:index;clustered:false;fields:del,dataType,NodeDataType,rankcode;include:CurrNum
--@##mode:index;clustered:false;fields:ProductID;include:ID,RankCode,MASID,Unit,GrossNum,StopNum,ChildStopNum,MUsedNum

GO

CREATE TABLE [dbo].[M2_MaterialAnalysisEnableStockCache](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[MaterialID] [int] NULL,
	[ProductID] [int] NULL,
	[NodeType] [int] NULL,	
	[BillNature] [int] NULL,
	[ParentID]  [int] NULL,	
	[EnableKuNum] [decimal](25, 12) NULL,	
	[BillType]  [int] NULL,	
	[BillID]  [int] NULL,	
	[BillListId]  [int] NULL,	
	[BillUinit]   [int] NULL,	
	[BillNum] [decimal](25, 12) NULL,	
    [BillTitle] [nvarchar](200) NULL,
	[BillBH] [nvarchar](200) NULL,
    [BillCreator] [int] NULL,
	[BillInDate] [datetime] NULL,
	PRIMARY KEY CLUSTERED ( [id] ASC ) ON [PRIMARY]
)
--@##mode:index;clustered:false;fields:MaterialID

GO

CREATE TABLE [dbo].[M2_MaterialAnalysisUnitsCache](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[AnalysisListID] [int] NULL,
	[UnitID] [int] NULL,	
	[bl] [decimal](25, 12) NULL
)

GO

CREATE TABLE [dbo].[M2_Relations](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[sort1] [int] NULL, --sort1=2 主计划 物料分析之间关系
	[NID] [int] NULL,	--sort1=2 : 物料分析明细ID
	[PID] [int] NULL,	--sort1=2 : 主生产计划明细ID
	[num1] [decimal](25, 12) NULL, --sort1=2 : 生产计划明细数量
	[creator] [int] NULL,
	[del] [int] NULL,	--1 正常 2 删除  (3,4,5,6)  7 临时
	PRIMARY KEY CLUSTERED ( [id] ASC ) ON [PRIMARY]
)
GO

CREATE TABLE [dbo].[M2_WageList_JJ](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[WJID] [int] NULL,
	[dataType] [int] NULL,
	[bid] [int] NULL,
	[productID] [int] NULL,
	[unit] [int] NULL,--生产单位
	[WFPAID] [int] NULL,
	[PRLID] [int] NULL,
	[Cateid] [int] NULL,
	[produceNum] [decimal](25, 12) NULL,--生产过程数量
	[NumTesting] [decimal](25, 12) NULL,--单价数量
	[price1] [decimal](25, 12) NULL,--单价
	[PriceUnit] [int] NULL,--单价单位
	[money1] [decimal](25, 12) NULL,
	[bonus] [decimal](25, 12) NULL,
	[remark] [nvarchar](500) NULL,
	[xlh] [nvarchar](100) NULL,
	[datesc] [datetime] NULL,
	[dateyx] [datetime] NULL,
	[datelr] [datetime] NULL,
	[unitconvert] [decimal](25, 12) NULL,--单位转换率
	[del] [int] NULL,
	[ReportMonth] [varchar](10) NULL,
    [IsCostCollect] [int] NOT NULL DEFAULT ((0)),
	[Countdate] [datetime] NULL
	PRIMARY KEY CLUSTERED ( [id] ASC ) ON [PRIMARY]
)

--@##mode:index;clustered:false;fields:bid,WFPAID;include:ID

GO

CREATE TABLE [dbo].[M2_AbilityAnalysis](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Title] [nvarchar](200) NULL,
	[ASBH] [nvarchar](50) NULL,
	[sortType] [int] NULL,
	[linePart] [int] NULL,
	[Crash] [int] NULL,
	[whole] [int] NULL,
	[lines] [varchar](8000) NULL,
	[strength] [int] NULL,
	[maxfree] [int] NULL,
	[status] [int] NULL,
	[Creator] [int] NULL,
	[inDate] [datetime] NULL,
	[del] [int] NULL,
	[delcate] [int] NULL,
	[deltime] [datetime] NULL,
	[upuser] [int] NULL,	--最近操作人员
	[uptime] [datetime] NULL, --最近操作时间
	PRIMARY KEY CLUSTERED ( [id] ASC ) ON [PRIMARY]
)

GO

CREATE TABLE [dbo].[M2_AbilityAnalysisList](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[AASID] [int] NULL,
	[dataType] [int] NULL,
	[ProductID] [int] NULL,
	[Unit] [int] NULL,
	[num1] [decimal](25, 12) NULL,
	[WPROC] [int] NULL,
	[WCenter] [int] NULL,
	[WFPID] [int] NULL,
	[Date1] [datetime] NULL,
	[timeNum] [decimal](25, 12) NULL,
	[BomListID] [int] NULL,
	[listID] [int] NULL,
	[tempuid] [int] NULL,
	[istemp] [bit] NULL,
	[FPID] [int] NULL,
	[FPIndex] [int] NULL,
	[PFID] [int] NULL,
	[pcNeedTime] [decimal](25, 12) NULL,
	[pcSumTime] [decimal](25, 12) NULL,
	[status] [int] NULL,
	[pcFirstID] [int] NULL,
	[pcIndex] [int] NULL,
	[pcNewNum] [decimal](25, 12) NULL,
	[pcNum] [decimal](25, 12) NULL,
	[del] [int] NULL,
	[role] [int] NULL,
	PRIMARY KEY CLUSTERED ( [id] ASC ) ON [PRIMARY]
)

GO

CREATE TABLE [dbo].[M2_BOMRelation](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[productID] [int] NULL,
	[unit] [int] NULL,
	[startDate] [datetime] NULL,
	[endDate] [datetime] NULL,
	[isOpen] [int] NULL,
	[mixedUse] [int] NULL,
	[intro] [ntext] NULL,
	[Creator] [int] NULL,
	[indate] [datetime] NULL,
	[del] [int] NULL,
	[delcate] [int] NULL,
	[deltime] [datetime] NULL,
	[status] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [ID] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]
 TEXTIMAGE_ON [PRIMARY]

GO

CREATE TABLE [dbo].[M2_BOMRelationList](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[MRID] [int] NULL,
	[level] [int] NULL,
	[BOMID] [int] NULL,
	[productID] [int] NULL,
	[unit] [int] NULL,
	[num1] [decimal](25, 12) NULL,
	[bl] [decimal](25, 12) NULL,
	[num2] [decimal](25, 12) NULL,
	[del] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [ID] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[M2_WorkingFlows_plan](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[MPBLID] [int] NULL,
	[oldID] [int] NULL,
	[WFName] [nvarchar](100) NULL,
	[WFBH] [nvarchar](50) NULL,
	[unit] [int] NULL,
	[Creator] [int] NULL,
	[Description] [ntext] NULL,
	[intro] [ntext] NULL,
	[indate] [datetime] NULL,
    PRIMARY KEY CLUSTERED
    (
        [ID] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


--@##mode:index;clustered:false;fields:oldID;include:ID,MPBLID
--@##mode:index;clustered:true;fields:ID

GO

CREATE TABLE [dbo].[M2_RewardPunish](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[title] [nvarchar](100) NULL,
	[RPClass] [int] NULL,
	[Cateid] [int] NULL,
	[RPDate] [datetime] NULL,
	[RPType] [int] NULL,
	[Money1] [decimal](25, 12) null,
	[BillType] [int] NULL,
	[BillID] [int] NULL,
	[intro] [ntext] NULL,
	[Status]  [int] NULL,
	[Creator] [int] NULL,
	[indate] [datetime] NULL,
	[Del] [int] NULL,
	[delcate]  [int] NULL,
	[deltime] [datetime] NULL,
	[upuser] [int] NULL,	--最近操作人员
	[uptime] [datetime] NULL, --最近操作时间,
    PRIMARY KEY CLUSTERED
    (
        [ID] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[erp_sys_UrlBigParamCaches](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	userid int Not NULL,
	SrcSign nvarchar(200) NULL,
	ParamsData ntext NULL,
	indate datetime NULL
)
GO

CREATE TABLE [dbo].[erp_comm_UnitGroup](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](200) NOT NULL,
	[formual] [nvarchar](200) NULL,
	[stoped] [int] NOT NULL,
	[stype] [int] NOT NULL,
	[sort1] [int] NOT NULL,
	[SysBind] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[erp_comm_UnitGroupAttr] (
	[id] [int] IDENTITY(1,1) NOT NULL, 
	[unitgp] int Not NULL, 
	[name] nvarchar(20) Not NULL,
	[formula] nvarchar(100) NULL,
	[stoped] [int] NOT NULL,
	[gate1] [int] NULL
)

GO

CREATE TABLE [dbo].[erp_comm_UnitGroupFormulaAttr] (
	[id] [int] IDENTITY(1,1) NOT NULL, 
	[GroupAttrID] int Not NULL, 
	[name] nvarchar(20) Not NULL,
	[formulaAttr] nvarchar(100) NULL,
	[defvalue] [decimal](25, 12) NULL,
	[hided] [int] Not NULL
)

GO

CREATE TABLE [dbo].[erp_comm_unitInfo](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[unitid] [int] NOT NULL,
	[unitgp] [int] NOT NULL,
	[main] [int] NULL,
	[bl] [decimal](25, 12) NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
--产品单位组属性值
CREATE TABLE [dbo].[erp_comm_unitAttrValue](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] Not NUll, --产品ID
	[unitgp] [int] NOT NULL,--单位分组
	[GroupAttr] [int] NOT NULL,--单位组属性
	[unitid] [int] NOT NULL,--单位
	[parameter] [varchar](20) NOT NULL,
	[v] [decimal](25, 12) NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[M2_QualityTestingsConfig](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[isMaxNum] [int] NULL,
	[firstReport] [int] NULL,
	[autoKuin] [int] NULL,
	[autoBlankChuin] [int] NULL,
	[proType] [int] NULL,
	[isRegist] [int] NULL,
	PRIMARY KEY CLUSTERED(	[ID] ASC ) ON [PRIMARY]
)


GO

CREATE TABLE [dbo].[M2_ManuOrderMaterial](
	[ID] [INT] IDENTITY(1,1) NOT NULL,
	[MOID] [INT] NULL,
	[MOLID] [INT] NULL,
	[MALID] [INT] NULL,
	[BomListID] [INT] NULL,
    [bl] [decimal](25, 12) NULL,
	[ProductID] [INT] NULL,
	[Unit] [INT] NULL,
	[NeedNum] [decimal](25, 12) NULL,
	[WastAge] [decimal](25, 12) NULL,
	[CrossNum] [decimal](25, 12) NULL,
	[SafeNum] [decimal](25, 12) NULL,
	[AvailableNum] [decimal](25, 12) NULL,
	[CKNum] [decimal](25, 12) NULL,
	[ZTNum] [decimal](25, 12) NULL,
	[YDNum] [decimal](25, 12) NULL,
	[CurrAssignNum] [decimal](25, 12) NULL,
	[CurrNum] [decimal](25, 12) NULL,
	[DateStart] [DATETIME] NULL,
	[DateEnd] [DATETIME] NULL,
	[del] [INT] NULL,
	[oldID] [INT] NULL,
	[MType] [INT] NULL,
	[Mergeinx] [INT] NULL,
	[ZdyHashKey] [INT] NULL,
	PRIMARY KEY CLUSTERED(	[ID] ASC ) ON [PRIMARY]
)

--@##mode:index;clustered:false;fields:MOID
GO

CREATE TABLE [dbo].[M2_Wage_JJ](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Creator] [int] NULL,
	[sn] [nvarchar](50) NULL,
	[status] [int] NULL,
	[LastApproveTime] [datetime] null,
	[LastApproveUser] [int] null,
	[title] [nvarchar](200) NULL,
	[indate] [DATETIME] NULL,
	[Countdate] [DATETIME] NULL,
	[del] [int] NULL,
	[delcate] [int] NULL,
	[deltime] [DATETIME] NULL,
	[intro] [nvarchar](4000) NULL,
	[tempsave] [int] NULL,
	[isobselete] [int] NULL,
	[PR_excel_drsign] [int] NULL,
    [uptime] [datetime] NULL,
	[Import] [varchar](4000) NULL,
	[upuser] [varchar](4000) NULL,
	PRIMARY KEY CLUSTERED(	[ID] ASC ) ON [PRIMARY]
)

GO

--计件工资明细、奖罚 和工资单的关联关系
CREATE TABLE [dbo].[Wages_Relation] (
	[ID] [int] NOT NULL primary key identity(1,1),
	[WageID] [int] NOT NULL ,
	[BillType] [int] NOT NULL ,
	[BillID] [int] NOT NULL ,
	[ListID] [int] NOT NULL ,
	[del] [int] null,
	[idel] [int] null,
) ON [PRIMARY]

GO

--Attrs:帐套下可用
CREATE TABLE [dbo].[sys_sdk_BillChangeDatas](
	[ID] [INT] IDENTITY(1,1) NOT NULL,
	[BillType] [INT] NULL,
	[BillId] [INT] NULL,
	[Edition] [INT] NULL,
	[Creator] [INT] NULL,
	[AddTime] [DATETIME] NULL,
	[BillData] [NTEXT] NULL,
	[Reason] [NTEXT] NULL,
	PRIMARY KEY CLUSTERED(	[ID] ASC ) ON [PRIMARY]
)

GO

--Attrs:帐套下可用
CREATE TABLE [dbo].[erp_sys_RadioNavigation](
	[sign] [char](16) NOT NULL,
	[uid] [int] NOT NULL,
	[defualtUrl] [nchar](200) NULL,
	[indate] [datetime] NULL
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[Mob_UserLoginLog](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NULL,
	[MobileModel] [nvarchar](100) NULL,
	[AppVersion] [varchar](50) NULL,
	[date7] [datetime] NULL,
	[macsn] [nvarchar](50) NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[M2_WAProcedureProgresSubstitution](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[WAID] [int] NULL,
    [WAWLID] [int] NULL,
	[WFPAID] [int] NULL,
	[fromID] [int] NULL,
	[fromtype] [int] NULL,
	[ztdnum] [decimal](25, 12) NULL,
	[syjgnum] [decimal](25, 12) NULL,
    PRIMARY KEY CLUSTERED
    (
        [ID] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[M2_WAProcedureProgresSubstitutionList](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[WAID] [int] NULL,
    [WAWLID] [int] NULL,
	[WFPAID] [int] NULL,
    [fromID] [int] NULL,
	[fromtype] [int] NULL,
	[SubstitutionWPID] [int] NULL,
    [WCID] [int] NULL,
	[sl] [decimal](25, 12) NULL,
	[ord] [int] NULL,
	[tdbl] [decimal](25, 12) NULL,
	[tdsl] [decimal](25, 12) NULL,
    PRIMARY KEY CLUSTERED
    (
        [ID] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[M2_ChargeShare](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[date1] [datetime] NULL,
	[Money1] [decimal](25, 12) NULL,
	[shareType] [int] NULL,
	[complete1] [int] NULL,
	[shareParts] [varchar](200) NULL,
	[ShareCateid] [int] NULL,
	[ShareTime] [datetime] NULL,
	[Creator] [int] NULL, 
	[indate] [datetime] NULL,
	[del] [int] null,
    PRIMARY KEY CLUSTERED
    (
        [ID] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[M2_ChargeNotionalPooling](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CSID] [int] NULL,
	[PayID] [int] NULL,
	[Money1] [decimal](25, 12) NULL,
	[datesy] [datetime] NULL,
	[cateid] [int] NULL,
	[del] [int] null,
    PRIMARY KEY CLUSTERED
    (
        [ID] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[M2_ChargeShareList](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CSID] [int] NULL,
	[PartID] [int] NULL,
	[Num1] [decimal](25, 12) NULL,
	[money1] [decimal](25, 12) NULL,
    [ShareType] [int] NOT NULL DEFAULT ((1)),
	[del] [int] null,
    PRIMARY KEY CLUSTERED
    (
        [ID] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[M2_CostSet](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Date1] [datetime] NULL,
	[CostType] [int] NULL,
    [CostShareType] [varchar](20) NULL,
	[Creator] [int] NULL, 
	[indate] [datetime] NULL,
	[lastupuser] [int] NULL,
	[lastuptime] [datetime] NULL,
    PRIMARY KEY CLUSTERED
    (
        [ID] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[M2_CostComputation](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[date1] [datetime] NOT NULL,
	[costType] [int] NULL,
	[complete1] [int] NULL,
    [stepindex] [int] NOT NULL DEFAULT ((0)),
	[Creator] [int] NULL, 
	[indate] [datetime] NULL,
	[DataVersion] [int] NULL,
	PRIMARY KEY CLUSTERED(
		[date1] ASC 
	) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[M2_CostComputationList](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CCID] [int] NULL,
	[PartID] [int] NULL,
	[MOID] [int] NULL,
	[MOLID] [int] NULL,
	[BillID] [int] NULL,
	[dataType] [int] NULL,
	[ProductID] [int] NULL,
	[unit] [int] NULL,	
	[P_MaterialMoney] [decimal](25, 12) NULL,
	[P_OutMoney] [decimal](25, 12) NULL,
	[P_OutPayMoney] [decimal](25, 12) NULL,
	[P_LaborMoney] [decimal](25, 12) NULL,
    [P_HourlyMoney] [decimal](25, 12) NULL,
	[P_InPartMoney] [decimal](25, 12) NULL,
	[P_OutPartMoney] [decimal](25, 12) NULL,
	[P_CashNum] [decimal](25, 12) NULL,
	[P_CostMoney] [decimal](25, 12) NULL,
	[P_CostPrice] [decimal](25, 12) NULL,
	[C_MaterialMoney] [decimal](25, 12) NULL,
	[C_OutMoney] [decimal](25, 12) NULL,
	[C_OutPayMoney] [decimal](25, 12) NULL,
	[C_LaborMoney] [decimal](25, 12) NULL,
    [C_HourlyMoney] [decimal](25, 12) NULL,
	[C_InPartMoney] [decimal](25, 12) NULL,
	[C_OutPartMoney] [decimal](25, 12) NULL,
	[C_CashNum] [decimal](25, 12) NULL,
	[C_CostMoney] [decimal](25, 12) NULL,
	[C_CostPrice] [decimal](25, 12) NULL,
	[MaterialMoney] [decimal](25, 12) NULL,
	[OutMoney] [decimal](25, 12) NULL,
	[OutPayMoney] [decimal](25, 12) NULL,
	[LaborMoney] [decimal](25, 12) NULL,
    [HourlyMoney] [decimal](25, 12) NULL,
	[InPartMoney] [decimal](25, 12) NULL,
	[OutPartMoney] [decimal](25, 12) NULL,
	[CashNum] [decimal](25, 12) NULL,
	[CostMoney] [decimal](25, 12) NULL,
	[CostPrice] [decimal](25, 12) NULL,
	[F_MaterialMoney] [decimal](25, 12) NULL,
	[F_OutMoney] [decimal](25, 12) NULL,
	[F_OutPayMoney] [decimal](25, 12) NULL,
	[F_LaborMoney] [decimal](25, 12) NULL,
    [f_HourlyMoney] [decimal](25, 12) NULL,
	[F_InPartMoney] [decimal](25, 12) NULL,
	[F_OutPartMoney] [decimal](25, 12) NULL,
	[F_CashNum] [decimal](25, 12) NULL,
	[F_CostMoney] [decimal](25, 12) NULL,
	[F_CostPrice] [decimal](25, 12) NULL,
	[del] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [ID] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[M2_CostComputationList_ManuOrders](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[MOID] [int] NULL,
	[MOLID] [int] NULL,
	[BillID] [int] NULL,
	[dataType] [int] NULL,
	[ProductID] [int] NULL,
	[unit] [int] NULL,	
	[MaterialMoney] [decimal](25, 12) NULL,
	[OutMoney] [decimal](25, 12) NULL,
	[OutPayMoney] [decimal](25, 12) NULL,
	[LaborMoney] [decimal](25, 12) NULL,
    [HourlyMoney] [decimal](25, 12) NULL,
	[InPartMoney] [decimal](25, 12) NULL,
	[OutPartMoney] [decimal](25, 12) NULL,
	[CashNum] [decimal](25, 12) NULL,
	[CostMoney] [decimal](25, 12) NULL,
	[CostPrice] [decimal](25, 12) NULL,
	[del] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [ID] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[M2_LeftMaterial](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[date1] [datetime] NULL,--月份
	[ProductID] [int] NULL,
	[unit] [int] NULL,
	[P_num1] [decimal](25, 12) NULL,
	[P_price1] [decimal](25, 12) NULL,
	[P_money1] [decimal](25, 12) NULL,
	[C_num1] [decimal](25, 12) NULL,
	[C_price1] [decimal](25, 12) NULL,
	[C_money1] [decimal](25, 12) NULL,
	[num1] [decimal](25, 12) NULL,
	[price1] [decimal](25, 12) NULL,
	[money1] [decimal](25, 12) NULL,
	[F_num1] [decimal](25, 12) NULL,
	[F_price1] [decimal](25, 12) NULL,
	[F_money1] [decimal](25, 12) NULL,
	[KuOutList] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [ID] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[M2_CostReturnMessage](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[BillID] [int] NULL,
	[ProductID] [int] NULL,
	[unit] [int] NULL,
	[Wl_productid] [int] NULL,
	[Wl_unit] [int] NULL,
	[ErrType] [varchar](20) NULL,
	[Remark] [nvarchar](200) NULL,
	[costor] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [ID] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

--序列号列表
CREATE TABLE [dbo].[M2_SerialNumberList](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[MainID]  [int] NULL,                          --外键，主表（SerialNumberMain.ID）
	[BusinessID] [int] NULL,                       --订单明细id
	[ToMake] [int] NULL,                           --派工id
	[BussinessType] [int] NULL,                    --业务类型(1：订单，2：派工)
	[BussinessTable] [nvarchar](100) NULL,         --业务id来源表
	[SeriNum] [nvarchar](400) NULL,                --序列号
	[MaxNum]  [int]  NULL,                         --最大位数顺序号(用于判定是否连续)
    [CenterDate] [datetime] NULL,                  --核心日期，
	[Creator] [int] NULL,                          --添加人id，关联gate.ord
	[indate]  [datetime] NULL,                     --添加时间，
    [status]  [int] NULL,                          --序列号状态（0：未用，1：已用）
    [isStop]  [int] NULL,                          --序列号停用（0：未停用，1：已停用）
	[UpUser]  [int] NULL,                          --修改人员id，关联gate.ord
	[uptime]  [datetime] NULL,                     --修改时间，
	[DelCate] [int] NULL,                          --删除人员id，关联gate.ord
	[deldate] [datetime] NULL,                     --删除时间，
    [remark]  [ntext] NULL ,                       --备注
	[del] [int] NULL                               --删除状态（1.正常，2.删除） ,
    PRIMARY KEY CLUSTERED
    (
        [ID] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]

--@##mode:index;clustered:false;fields:ID,MainID,BusinessID
--@##mode:index;clustered:false;fields:SeriNum

GO
--序列号生成规则表
CREATE TABLE [dbo].[M2_SerialNumberConfig](
	[ID]       [int] IDENTITY(1,1) NOT NULL,
	[MainID]   [int]  NULL,                         --外键，主表（SerialNumberMain.ID） 
	[NO]       [int]  NULL,                         --列表序号
    [KeyMean]  [int] NULL,                          --字段涵义（1：输入区，2：输入区可变动，3：日期，4：顺序号可变动）
    [KeyName]  [nvarchar](100) NULL,                --编码名称
	[KeyCode]  [nvarchar](100) NULL,                --编码
    [KeyLen]   [int] NULL,                          --编码长度
    [Sort]     [int] NULL,                          --编码排序
    [isUsing]  [int] NULL,                          --编码是否启用（0：未用，1：已用）
    [remark]   [text] NULL ,                        --备注（备用字段）
	[del]      [int] NULL                           --删除状态（1.正常，2.删除） ,
    PRIMARY KEY CLUSTERED
    (
        [ID] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
--主表
CREATE TABLE [dbo].[M2_SerialNumberMain](
	[ID] [int] IDENTITY(1,1) NOT NULL,
    [title] [nvarchar](200) NULL,
	[ProductID] [int] NULL,                       --产品id
    [Unit] [int] NULL,                            --产品单位
    [RuleType] [int] NULL,                        --生成方式（0.快速配置，1.手填录入，2.规则自动） 
    [RuleID] [int] NULL,                          --规则ID
	[CreateSeriNum]  [int] NULL,                  --序列号生成数量
	[UseNum]  [int] NULL,                         --对应数
	[Creator] [int] NULL,                         --添加人id，关联gate.ord
	[indate]  [datetime] NULL,                    --添加时间，
	[UpUser]  [int] NULL,                         --修改人员id，关联gate.ord
	[uptime]  [datetime] NULL,                    --修改时间，
	[DelCate] [int] NULL,                         --删除人员id，关联gate.ord
	[deldate] [datetime] NULL,                    --删除时间，
    [remark]  [ntext] NULL,                       --备注（备用字段）
	[del] [int] NULL                              --删除状态（1.正常，2.删除） ,
    PRIMARY KEY CLUSTERED
    (
        [ID] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[M2_BomProParents](
	[ProID] [INT] NULL,
	[ProParentID] [INT] NULL,
	[BomID] [INT] NULL,
	[del] [INT] NULL
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[f_AssistSubject](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[title] [nvarchar](200) NULL,
	[isDef] [int] NULL,
	[del] [int] NULL,
	[stop] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[f_AssistList](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[PID] [int] NULL,
	[AssistSubject] [int] NULL,
	[title] [nvarchar](200) NULL,
	[deep] [int] NULL,
	[gate1] [bigint] NULL,
	[stop] [int] NULL,
	[fullids] varchar(200) NULL,
	[fullsort] int NULL,
	[del] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[f_AccountAssistSubject](
	[ID]  int  IDENTITY(1,1) NOT NULL,
	[AccountSubject] int NULL,
	[AssistSubject] int NULL,
	[isMust]  int NULL,
	[rowindex] int NULL,
    PRIMARY KEY CLUSTERED
    (
        [ID] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[f_accumuAssistList](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[sort1] [int] NULL,
	[PID] [int] NULL,
	[AssistSubject] [varchar](50) NULL,
	[AssistID] [varchar](50) NULL,
	[money1_b] [decimal](25, 12) NULL,
	[money1_y] [decimal](25, 12) NULL,
	[money2_b] [decimal](25, 12) NULL,
	[money2_y] [decimal](25, 12) NULL,
	[money3_b] [decimal](25, 12) NULL,
	[money3_y] [decimal](25, 12) NULL,
	[money4_b] [decimal](25, 12) NULL,
	[money4_y] [decimal](25, 12) NULL,
	[index] [int] NULL,
	[pindex] [int] NULL,
	[bz] [int] NULL,
	[hl] [decimal](25, 12) NULL,
    [Unit] [int] NULL,
    [Num1] [decimal](25, 12) NULL,
    [Num2] [decimal](25, 12) NULL,
    [Num3] [decimal](25, 12) NULL,
    [Num4] [decimal](25, 12) NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[Tb_RowSetting](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[url] [varchar](500) NULL,
	[userid] [int] NULL,
	[IsZero] [int] NULL,--余额为0
	[IsNegative] [int] NULL,--余额为负数
	[HaveHistory] [int] NULL--历史发生额,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[erp_store_rkCodes](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[productID] [int] NULL,
	[unit] [int] NULL,
	[companyID] [int] NOT NULL,
	[storeID] [int] NULL,
	[price1] [decimal](25, 12) NULL,
	[ph] [nvarchar](50) NULL,
	[addtime] [datetime] NOT NULL,
	[creator] [int] NOT NULL,
	[zdy1] [nvarchar](200) NULL,
	[zdy2] [nvarchar](200) NULL,
	[zdy3] [nvarchar](200) NULL,
	[zdy4] [nvarchar](200) NULL,
	[zdy5] [int] NULL,
	[zdy6] [int] NULL,
	[bz] [int] NULL,
	[js] [nvarchar](50) NULL,
    PRIMARY KEY CLUSTERED
    (
        [ID] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[sortonehyfiles](
	[ord] [int] IDENTITY(1,1) NOT NULL,
	[sortonehy] [int] NULL,
	[name] [varchar](200) NOT NULL,
	[url] [varchar](4000) NOT NULL,
	[creator] [int] NOT NULL,
	[date1] [datetime] NULL,
    PRIMARY KEY CLUSTERED
    (
        [ord] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[M2_MaterialConfig](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[isExcess] [int] NULL,
	[NoBillPaking] [int] NULL,
    [BL] [decimal](25, 12) NULL,
    [IsMaterialForAdd] [int] NULL,
    [IsMaterialAutoOutKuApply] [int] NULL,
	PRIMARY KEY CLUSTERED(	[ID] ASC ) ON [PRIMARY]
)

GO

CREATE TABLE [dbo].[M2_BOMControl](
	[ID] [INT] IDENTITY(1,1) NOT NULL,
	[isCreateProduct] [INT] NOT NULL,
	[upuser] [INT] NULL,
	[uptime] [DATETIME] NULL,
    PRIMARY KEY CLUSTERED
    (
        [ID] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[caigou_CostSharing](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[caigou] [int] NOT NULL,
	[title] [nvarchar](100) NOT NULL,
	[code] [nvarchar](100) NOT NULL,
	[costtype] [int] NOT NULL,
	[remark] [text] NULL,
	[date1] [datetime] NOT NULL,
	[indate] [datetime] NOT NULL,
	[creator] [int] NOT NULL,
	[del] [int] NOT NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[caigou_CostSharing_FYList](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[csid] [int] NOT NULL,
	[payid] [int] NOT NULL,
	[money] [decimal](25, 12) NOT NULL,
	[del] [int] NOT NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[caigou_CostSharing_RKList](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[csid] [int] NOT NULL,
	[kuinlist] [int] NOT NULL,
	[product] [int] NOT NULL,
	[unit] [int] NOT NULL,
	[count] [decimal](25, 12) NOT NULL,
	[price] [decimal](25, 12) NOT NULL,
	[total] [decimal](25, 12) NOT NULL,
	[money] [decimal](25, 12) NOT NULL,
	[del] [int] NOT NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[M2_TimeWagesList](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[TWID] [int] NULL,
	[WFID] [int] NULL,
	[TWType] [int] NULL,
	[Gwid] [int] NULL,
	[price1] [decimal](25, 12) NULL,
	[PTCode] [nvarchar](100) NULL,
	[remark1] [nvarchar](500) NULL,
	[del] [int] NULL,
	PRIMARY KEY CLUSTERED(	[ID] ASC ) ON [PRIMARY]
	)
GO
CREATE TABLE [dbo].[M2_TimeWages](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[title] [nvarchar](200) NULL,
	[isCancel] [int] NULL,
	[remark] [nvarchar](max) NULL,
	[Creator] [int] NULL,
	[indate] [datetime] NULL,
	[del] [int] NULL,
	[delcate] [int] NULL,
	[deltime] [datetime] NULL,
	[status] [int] NULL,
	[LastApproveTime] [datetime] null,
	[LastApproveUser] [int] null,
	[PR_excel_drsign] [nvarchar](100) NULL,
	[uptime] [datetime] NULL,
	[upuser] [int] NULL,
	[import] [nvarchar](50) NULL,
  PRIMARY KEY CLUSTERED(	[ID] ASC ) ON [PRIMARY] 
) 

GO

CREATE TABLE [dbo].[externalArgs](
	[id] [INT] IDENTITY(1,1) NOT NULL,
	[title] [NVARCHAR](50) NULL,
	[name] [VARCHAR](50) NULL,
	[fval] [VARCHAR](50) NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[externalUrls](
	[id] [INT] IDENTITY(1,1) NOT NULL,
	[title] [NVARCHAR](50) NULL,
	[url] [NVARCHAR](200) NULL,
	[method] [VARCHAR](30) NULL,
	[args] [VARCHAR](1000) NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[externalLog](
	[id] [INT] IDENTITY(1,1) NOT NULL,
	[uid] [INT] NULL,
	[date7] [DATETIME] NULL,
	[ip] [VARCHAR](50) NULL,
	[url] [NVARCHAR](MAX) NULL,
	[intro] [NVARCHAR](MAX) NULL,
	[status] [INT] NULL,
	[del] [INT] NULL DEFAULT (1),
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]
 TEXTIMAGE_ON [PRIMARY]

GO

CREATE TABLE [dbo].[M2_BOMBatchChange](
	[ID] [INT] IDENTITY(1,1) NOT NULL,
	[proid1] [INT] NULL,
	[unit1] [INT] NULL,
	[proid2] [INT] NULL,
	[unit2] [INT] NULL,
	[Role] [INT] NULL,
	[PCWastage] [decimal](25, 12) NULL,
	[num] [decimal](25, 12) NULL,
	[bl] [decimal](25, 12) NULL,
	[wlnum] [decimal](25, 12) NULL,
	[WPROC] [INT] NULL,
	[ChildID] [INT] NULL,
	[BomIDs] [NVARCHAR](2000) NULL,
	[Creator] [INT] NULL,
	[indate] [DATETIME] NULL,
    PRIMARY KEY CLUSTERED
    (
        [ID] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[M2_Wage_JS](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Creator] [int] NULL,
	[indate] [datetime] NULL,
	[del] [int] NULL,
	[delcate] [int] NULL,
	[deltime] [datetime] NULL,
	[sn] [nvarchar](100) NULL,
	[status] [int] NULL,
	[title] [nvarchar](100) NULL,
	[Jsdate] [datetime] NULL,
	[remark] [nvarchar](500) NULL,
	[money1] [decimal](25, 12) NULL,
	[PR_excel_drsign] [nvarchar](200) NULL,
	[import] [nchar](50) NULL,
	[uptime] [datetime] NULL,
	[upuser] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [ID] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[M2_WageList_JS](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Billid] [int] NULL,
	[WFPAID] [int] NULL,
	[JSID] [int] NULL,
	[Twid] [int] NULL,
	[Gwid] [int] NULL,
	[Wfid] [int] NULL,
	[bidTP] [int] NULL,
	[MID] [int] NULL,
	[Tlong] [decimal](25, 12) NULL,
	[Tlunit] [int] NULL,
	[price1] [decimal](25, 12) NULL,
	[money1] [decimal](25, 12) NULL,
	[RaPmoney] [decimal](25, 12) NULL,
	[remark1] [nvarchar](500) NULL,
	[del] [int] NULL,
	[WFPid] [int] NULL,
	[ReportMonth] [varchar](10) NULL,
    [IsCostCollect] [int] NOT NULL DEFAULT ((0)),
	[Jsdate] [datetime] NULL,
    PRIMARY KEY CLUSTERED
    (
        [ID] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[M2_ActualBoardSetting](
	[Line] [INT] NULL,
	[Interval] [INT] NULL,
	[UpUser] [INT] NULL,
	[UpTime] [DATETIME] NULL
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[HrKQ_CardSettingMode](
	[RangeID] [INT] NOT NULL,
	[ModeType] [INT] NULL,
	[Name] [NVARCHAR](200) NULL,
	[TextContent] [NVARCHAR](500) NULL,
	[Coordinate] [NVARCHAR](200) NULL,
    [MachineID] [INT] NULL
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[sys_sdk_subsystems](
	[companyId] [int] NOT NULL,
	[companyName] [nvarchar](50) NULL,
	[SitePath] [nvarchar](200) NULL,
	[SiteName] [nvarchar](50) NULL,
	[SiteDataBaseName] [nvarchar](50) NULL,
	[HostBind] [varchar](1000) NULL,
	[creator] [int] NOT NULL,
	[indate] [datetime] NOT NULL,
	[status] [int] NULL,
	[dbuser] [varchar](40) NULL,
	[dbword] [varchar](32) NULL,
	[defaultUrl] [varchar](200) NULL,
	[qxintro] [varchar](8000) NULL,
	[visitkey] [varchar](32) NULL
	PRIMARY KEY CLUSTERED(	[companyId] ASC ) ON [PRIMARY] 
) 

GO

CREATE TABLE [dbo].[sys_subsys_userbinds](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[companyId] [int] NOT NULL,
	[centerUserId] [int] NOT NULL,
	[subUserId] [int] NOT NULL,
	[subUserName] [nvarchar](50)  NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[finance_AgingOfAccountTimeDefine](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[title] [nvarchar](10) NULL,
	[day1] [int] NULL,
	[day2] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[M2_QCProject](
	[ID] [INT] IDENTITY(1,1) NOT NULL,
	[GroupID] [INT] NULL,
	[PName] [NVARCHAR](200) NULL,
	[PJName] [NVARCHAR](200) NULL,
	[Unit] [INT] NULL,
	[StandardType] [INT] NULL,
	[Decision] [INT] NULL,
	[StandardVal] [NVARCHAR](2000) NULL,
	[StopStatus] [INT] NULL,
	[Important] [INT] NULL,
	[Creator] [INT] NULL,
	[indate] [DATETIME] NULL,
	[upuser] [INT] NULL,
	[uptime] [DATETIME] NULL,
	PRIMARY KEY CLUSTERED([ID] ASC) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[M2_QCProjectAuxiliary](
	[ID] [INT] IDENTITY(1,1) NOT NULL,
	[PID] [INT] NULL,
	[AuxiliaryVal_1] [NVARCHAR](200) NULL,
	[AuxiliaryVal_2] [NVARCHAR](200) NULL,
	PRIMARY KEY CLUSTERED([ID] ASC) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[M2_QCScheme](
	[ID] [INT] IDENTITY(1,1) NOT NULL,
	[SName] [NVARCHAR](500) NULL,
	[SBH] [NVARCHAR](200) NULL,
	[QCType] [INT] NULL,
	[QCPerson] [NTEXT] NULL,
	[StopStatus] [INT] NULL,
	[remark] [NVARCHAR](2000) NULL,
	[Creator] [INT] NULL,
	[indate] [DATETIME] NULL,
	[upuser] [INT] NULL,
	[uptime] [DATETIME] NULL,
	PRIMARY KEY CLUSTERED([ID] ASC) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[M2_QCSchemeList](
	[ID] [INT] IDENTITY(1,1) NOT NULL,
	[PID] [INT] NULL,
	[ProjectID] [INT] NULL,
	[MustCheck] [INT] NULL,
	[rowindex] [INT] NULL,
	PRIMARY KEY CLUSTERED([ID] ASC) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[M2_WF_QCScheme](
	[ID] [INT] IDENTITY(1,1) NOT NULL,
	[SName] [NVARCHAR](500) NULL,
	[SBH] [NVARCHAR](200) NULL,
	[WPROC] [INT] NULL,
	[StopStatus] [INT] NULL,
	[isDefault] [INT] NOT NULL DEFAULT ((0)),
	[Remark] [NVARCHAR](2000) NULL,
	[Creator] [INT] NULL,
	[indate] [DATETIME] NULL,
	[upuser] [INT] NULL,
	[uptime] [DATETIME] NULL,
	PRIMARY KEY CLUSTERED([ID] ASC) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[M2_WF_QCSchemeList](
	[ID] [INT] IDENTITY(1,1) NOT NULL,
	[PID] [INT] NULL,
	[Sort] [INT] NULL,
	[GXID] [NVARCHAR](200) NULL,
	[isOut] [INT] NULL,
	[WPName] [NVARCHAR](500) NULL,
	[SchemeID] [INT] NULL,
	[isQC] [INT] NULL,
	PRIMARY KEY CLUSTERED([ID] ASC) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[M2_QCDictionary](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[waid] [int] NOT NULL DEFAULT ((0)),
	[type] [int] NOT NULL DEFAULT ((0)),
	[relatedFields] [int] NOT NULL DEFAULT ((0)),
	[key] [int] NOT NULL DEFAULT ((0)),
	[value] [nvarchar](2000) NULL,
	[isOk] [int] NULL DEFAULT (NULL),
    PRIMARY KEY CLUSTERED([ID] ASC) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[C2_RecognitionRule](
	[ID] [INT] IDENTITY(1,1) NOT NULL,
	[title] [nvarchar](200) NULL,
	[billtype] [int] NULL,
	[QRCode] [nvarchar](500) NULL,
	[KeyInterval] [nvarchar](100) NULL,
	[KeyValueInterval] [nvarchar](100) NULL,
	[intro] [nvarchar](500) NULL,
	[Creator] [int] NULL,
	[indate] [datetime] NULL,
	[del] [int] NULL,
	[UpUser] [INT] NULL,
	[UpTime] [DATETIME] NULL,
	[delcate] [int] NULL,
	[deltime] [datetime] NULL,
	[UploadPicUrl] [int] NULL,
	[TextRecognition] [nvarchar](500) NULL,
	PRIMARY KEY CLUSTERED([ID] ASC) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[C2_RecognitionRuleList](
	[ID] [INT] IDENTITY(1,1) NOT NULL,
	[RRID] [INT]  NOT NULL,
	[DBName] [varchar](100) NULL,
	[QRKeyName] [nvarchar](200) NULL,
	[IsRuleKey] [INT] NULL,
	[IsSearchKey] [INT] NULL,
    [Rowindex] [int] NULL,
	[Del] [int] NULL,
	[FixedLength] [int] NULL,
	[QRValue] [int] NULL,
	PRIMARY KEY CLUSTERED([ID] ASC) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[M2_GXQualityTesting](
	[ID] [INT] IDENTITY(1,1) NOT NULL,
	[title] [NVARCHAR](200) NULL,
	[qtbh] [NVARCHAR](200) NULL,
	[qtdate] [DATETIME] NULL,
	[qcperson] [VARCHAR](8000) NULL,
    [QTType] [INT] NOT NULL DEFAULT (0),
	[zjid] [INT] NULL,
	[wfpaids] [VARCHAR](8000) NULL,
	[waid] [INT] NULL,
    [TaskID] [INT] NULL,
	[del] [INT] NULL,
	[Creator] [INT] NULL,
	[indate] [DATETIME] NULL,
	[upuser] [INT] NULL,
	[uptime] [DATETIME] NULL,
	[delcate] [INT] NULL,
	[deltime] [DATETIME] NULL,
	PRIMARY KEY CLUSTERED([ID] ASC) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[M2_GXQualityTestingResult](
	[ID] [INT] IDENTITY(1,1) NOT NULL,
	[QTID] [INT] NULL,
	[QTMode] [INT] NULL,
	[NumTesting] [decimal](25, 12) NULL,
	[SerialNumber] [decimal](25, 12) NULL,
	[QTConform] [decimal](25, 12) NULL,
	[NumScrap] [decimal](25, 12) NULL,
	[NumBF] [decimal](25, 12) NULL,
	[wgNum] [decimal](25, 12) NULL,
	[xlh] [NVARCHAR](500) NULL,
	[ph] [INT] NOT NULL DEFAULT ((0)),
	[QualityLevel] [INT] NULL,
	[QTResult] [INT] NULL,
	[bhgOpinion] [INT] NULL,
	[BFOpinion] [INT] NULL,
	[SPresult] [INT] NULL,
	[spuser] [INT] NULL,
	[reworkGX] [INT] NULL,
	[SPremark] [NVARCHAR](2000) NULL,
	[oriSeralNumber] [INT] NULL,
    [ReworkMode] [INT] NULL,
    [TaskMxID] [INT] NULL,
    [rowindex] [INT] NULL,
    [SpotCheckFlag] [INT] NULL,
	PRIMARY KEY CLUSTERED([ID] ASC) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[M2_BatchNumberList](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[BussinessType] [int] NOT NULL DEFAULT ((0)),
	[BussinessID] [int] NOT NULL DEFAULT ((0)),
	[BatchNumber] [nvarchar](400) NOT NULL DEFAULT (''),
    [Count] [decimal](25, 12) NOT NULL DEFAULT ((0)),
	[Creator] [int] NOT NULL DEFAULT ((0)),
	[Indate] [datetime] NOT NULL DEFAULT (getdate()),
    [OriginalID] [INT] NULL,
    PRIMARY KEY CLUSTERED([ID] ASC) ON [PRIMARY]
) ON [PRIMARY]
GO
--收货表
Create table [dbo].[M2_ReceivingGoods](
  Id int primary key identity(1,1), --自增主键
  Title nvarchar(200),--收货主题
  BH nvarchar(200),--收货编号
  SDate DateTime,--收货日期
  GYS int,--加工厂商
  Person int,--对方代表
  OurPerson	INT,--我方代表
  FromType int,--收货类型  1=委外 2=？
  SJStatus int,--送检状态  未送检1/部分送检2/送检完毕3/手动结束=4 （只有单位跟委外单明细相同的情况下，送检保存时自动算状态，否则需要手动设置状态）
  AutoCreate int,--0否，1是。 默认值否
  Intro	NTEXT,--概要
  Del INT not null default 1, --删除状态 1 正常，2，删除
  Creator INT,--添加人
  Indate DATETIME,--添加时间
  UpUser INT,	--修改人
  UpTime DATETIME,	--修改时间
  DelCate INT,		--删除人
  DelTime DATETIME  --删除时间
)
GO
--收货明细表
Create table [dbo].[M2_ReceivingGoodList](
	Id int primary key identity(1,1), --自增主键
	RGId INT,--收货单ID
	ProductId INT,--收货产品 dbo.Product
	Unit INT,--单位
	Num	[decimal](25, 12),--数量
	WaitingArea	INT,--待检区
	SJStatus int,--送检状态 未送检1/部分送检2/送检完毕3/手动结束=4 （只有单位跟委外单明细相同的情况下，送检保存时自动算状态，否则需要手动设置状态）
	Remark	NVARCHAR(500),--备注
	FromType INT not null default 0,--收货类型 1=整单委外2=工序委外 0=人工填写
	FromId INT,--来源单据 
	Del	INT not null default 1, --删除状态 1 正常，2，删除
	RowIndex INT--顺序
)
GO
--委外送检
Create table [dbo].[M2_OutsourceInspection](
  Id int primary key identity(1,1), --自增主键
  Title nvarchar(200),--主题
  BH nvarchar(200),--编号
  GYS int,--加工厂商
  SDate DateTime,--送检日期
  Inspector VARCHAR(500),--质检人员
  RGId INT,--收货主单ID
  Intro NTEXT,--概要
  AutoCreate INT,--自动生成 0否，1是。 默认值否
  FromType INT,--来源类型 1=收货单
  QcType INT,--质检单性质 1=送检+质检任务 2=送检 3=质检任务
  Del INT,	--删除状态
  Creator INT,--添加人
  Indate DATETIME,--添加时间
  UpUser INT,	--修改人
  UpTime DATETIME,	--修改时间
  DelCate INT,		--删除人
  DelTime DATETIME,  
  QCStatus  [int] NOT NULL DEFAULT ((0))
)
GO

Create table [dbo].[M2_OutsourceInspectionList](
	Id int primary key identity(1,1), 
	OiId INT,
	ProductId INT,
	SJNum [decimal](25, 12),
	SJUnit	INT,
	SHNum	[decimal](25, 12),
	SHUnit	INT,
	WaitingArea	INT,
	FromType	INT,
	FromId	INT,
	FromId2	INT,
	Remark	NVARCHAR(500),
	Del	INT,
	RowIndex INT, 
	QCStatus  [int] NOT NULL DEFAULT ((0)),
	HasQCNumber  [decimal](25, 12),
	defInspector  INT
)
GO

Create table [dbo].[M2_OutsourcingRework](
	Id int primary key identity(1,1), 
	Title NVARCHAR(200),
	BH NVARCHAR(200),
	FDate DATETIME,
	GYS	INT,
	Person	INT,
	OurPerson	INT,
	Intro	NTEXT,
	Del	INT,
	Creator	INT,
	InDate	DATETIME,
	UpUser	INT,
	UpTime	DATETIME,
	DelCate	INT,
	DelTime	DATETIME
)
GO

Create table [dbo].[M2_OutsourcingReworkList](
	Id int primary key identity(1,1), 
	ORId INT,
	QTLId INT,
	Productid INT,
	Unit INT,
	Num	[decimal](25, 12),
    CodeBatch int,
	XLH nvarchar(500),
	DateDelivery DATETIME,
	Remark	NVARCHAR(500),
	BHGOpinion	INT,
	Del	INT,
	RowIndex INT
)
GO
--APP扫码直接出库临时表
CREATE TABLE [dbo].[mobile_kuoutlist2](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NULL,
	[num1] [decimal](25, 12) NOT NULL,
	[num2] [decimal](25, 12) NULL,
	[num3] [decimal](25, 12) NULL,
	[price1] [decimal](25, 12) NOT NULL,
	[pricemonth] [decimal](25, 12) NULL,
	[money1] [decimal](25, 12) NOT NULL,
    [AssistUnit] [int] NULL,
    [AssistNum] [decimal](25, 12) NULL,
	[company] [int] NULL,
	[contract] [int] NULL,
	[contractlist] [int] NULL,
	[kuout] [int] NULL,
	[kuoutlist] [int] NULL,
	[area] [int] NULL,
	[trade] [int] NULL,
	[unit] [int] NOT NULL,
	[ck] [int] NULL,
	[ph] [nvarchar](50) NULL,
	[xlh] [nvarchar](100) NULL,
	[datesc] [datetime] NULL,
	[dateyx] [datetime] NULL,
	[bz] [int] NULL,
	[js] [decimal](25, 12) NULL,
	[intro] [nvarchar](200) NULL,
	[caigoulist] [int] NULL,
	[kuinlist] [int] NULL,
	[ku] [int] NULL,
	[gys] [int] NULL,
	[date1] [datetime] NULL,
	[date7] [datetime] NULL,
	[del] [int] NULL,
	[cateid] [int] NULL,
	[cateid2] [int] NULL,
	[cateid3] [int] NULL,
	[addcate] [int] NULL,
	[mxid] [int] NULL,
	[sort1] [int] NULL,
	[HCStatus] [int] NULL,
	[zdy1] [nvarchar](200) NULL,
	[zdy2] [nvarchar](200) NULL,
	[zdy3] [nvarchar](200) NULL,
	[zdy4] [nvarchar](200) NULL,
	[zdy5] [int] NULL,
	[zdy6] [int] NULL,
	[MOrderID] [int] NULL,
	[M2_OrderID] [int] NULL,
	[date2] [datetime] NULL,
	[price2] [decimal](25, 12) NULL,
	[money2] [decimal](25, 12) NULL,
	[JoinDBListID] [int] NULL,
	[StoreCode] [varchar](200) NULL,
	[zzyckData] [varchar](500) NULL,
	[numleft] [decimal](25, 12) NULL,
	[kuid] [int] NULL,
    [commUnitAttr] [nvarchar](200) NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]

GO
--APP扫码直接出库序列号表
CREATE TABLE [dbo].[kuout2xlhlist](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[kuid] [int] NULL,
	[CK] [int] NULL,
	[num1] [decimal](25, 12) NULL,
	[kuoutlist] [int] NULL,
	[kuout] [int] NULL,
    [SerialID] [int] NULL,
	[creator] [int] NULL,
	[indate] [datetime] NULL,
	[del] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]

GO
--APP出库确认编辑表
CREATE TABLE [dbo].[kuoutlist2Edit](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[kuid] [int] NULL,
	[ord] [int] NULL,
	[CK] [int] NULL,
	[num1] [decimal](25, 12) NULL,
	[kuoutlist] [int] NULL,
	[kuout] [int] NULL,
	[CkPageType] [int] NULL,
	[creator] [int] NULL,
	[indate] [datetime] NULL,
	[del] [int] NULL,
	[intro] [nvarchar](200) NULL,
	[xlh] [nvarchar](100) NULL,
	[BZ] [int] NULL,
	[JS] [decimal](25, 12) NULL,
	[date2] [datetime] NULL,
	[commUnitAttr] [nvarchar](200) NULL,
	[zdy1] [nvarchar](200) NULL,
	[zdy2] [nvarchar](200) NULL,
	[zdy3] [nvarchar](200) NULL,
	[zdy4] [nvarchar](200) NULL,
	[zdy5] [int] NULL,
	[zdy6] [int] NULL,
	[date7] [datetime] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]

GO
--扫描入库存储数据临时表
CREATE TABLE [dbo].[Scankuinlist](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NULL,
	[price1] [decimal](25, 12) NOT NULL,
	[price2] [decimal](25, 12) NULL,
	[num1] [decimal](25, 12) NOT NULL,
	[num2] [decimal](25, 12) NOT NULL,
	[money1] [decimal](25, 12) NOT NULL,
	[money2] [decimal](25, 12) NULL,
	[priceMonth] [decimal](25, 12) NULL,
	[basePrice] [decimal](25, 12) NULL,
	[baseMoney] [decimal](25, 12) NULL,
	[kuin] [int] NULL,
	[ku] [int] NULL,
	[caigou] [int] NULL,
	[sort] [int] NULL,
	[dateadd] [datetime] NULL,
	[date7] [datetime] NULL,
	[del] [int] NULL,
	[addcate] [int] NULL,
	[bz] [int] NULL,
	[js] [nvarchar](50) NULL,
	[unit] [int] NOT NULL,
	[commUnitAttr] [nvarchar](200) NULL,
	[intro] [nvarchar](500) NULL,
	[ph] [nvarchar](50) NULL,
	[xlh] [ntext] NULL,
	[datesc] [datetime] NULL,
	[dateyx] [datetime] NULL,
	[company] [int] NULL,
	[caigoulist] [int] NULL,
	[sort1] [int] NULL,
	[mxpx] [int] NULL,
	[zdy1] [nvarchar](200) NULL,
	[zdy2] [nvarchar](200) NULL,
	[zdy3] [nvarchar](200) NULL,
	[zdy4] [nvarchar](200) NULL,
	[zdy5] [int] NULL,
	[zdy6] [int] NULL,
	[date2] [datetime] NULL,
	[QTLID] [int] NULL,
	[BFID] [int] NULL,
	[MOrderID] [int] NULL,
	[M2_QTLID] [int] NULL,
	[M2_BFID] [int] NULL,
	[M2_OrderID] [int] NULL,
	[JoinDBListID] [int] NULL,
	[kuoutlist2] [int] NULL,
	[caigoulist2] [int] NULL,
	[StoreCode] [varchar](200) NULL,
	[CaigouQCList] [int] NULL,
	[CaigouQC] [int] NULL,
	[kuinlist] [int] NULL,
    [ScanType] [int] NULL,
	[AssistNum] [decimal](25, 12) NULL,
    [AssistUnit] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
--APP扫描直接入库存储数据临时表
CREATE TABLE [dbo].[mobile_kuinlist](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NULL,
	[price1] [decimal](25, 12) NOT NULL,
	[price2] [decimal](25, 12) NULL,
	[num1] [decimal](25, 12) NOT NULL,
	[num2] [decimal](25, 12) NOT NULL,
	[money1] [decimal](25, 12) NOT NULL,
	[money2] [decimal](25, 12) NULL,
	[priceMonth] [decimal](25, 12) NULL,
	[basePrice] [decimal](25, 12) NULL,
	[baseMoney] [decimal](25, 12) NULL,
	[kuin] [int] NULL,
	[ku] [int] NULL,
	[caigou] [int] NULL,
	[sort] [int] NULL,
	[dateadd] [datetime] NULL,
	[date7] [datetime] NULL,
	[del] [int] NULL,
	[addcate] [int] NULL,
	[bz] [int] NULL,
	[js] [nvarchar](50) NULL,
	[unit] [int] NOT NULL,
	[commUnitAttr] [nvarchar](200) NULL,
	[intro] [nvarchar](500) NULL,
	[ph] [nvarchar](50) NULL,
	[xlh] [ntext] NULL,
	[datesc] [datetime] NULL,
	[dateyx] [datetime] NULL,
	[company] [int] NULL,
	[caigoulist] [int] NULL,
	[sort1] [int] NULL,
	[mxpx] [int] NULL,
	[zdy1] [nvarchar](200) NULL,
	[zdy2] [nvarchar](200) NULL,
	[zdy3] [nvarchar](200) NULL,
	[zdy4] [nvarchar](200) NULL,
	[zdy5] [int] NULL,
	[zdy6] [int] NULL,
	[date2] [datetime] NULL,
	[QTLID] [int] NULL,
	[BFID] [int] NULL,
	[MOrderID] [int] NULL,
	[M2_QTLID] [int] NULL,
	[M2_BFID] [int] NULL,
	[M2_OrderID] [int] NULL,
	[JoinDBListID] [int] NULL,
	[kuoutlist2] [int] NULL,
	[caigoulist2] [int] NULL,
	[StoreCode] [varchar](200) NULL,
	[CaigouQCList] [int] NULL,
	[CaigouQC] [int] NULL,
	[kuinlist] [int] NULL,
	[AssistUnit] [int] NULL,
	[AssistNum] [decimal](25, 12) NULL   ,
    [ProductAttr1] int null,
	[ProductAttr2] int null,
	[ProductAttrBatchId] int null,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
--序列号规则表
CREATE TABLE [dbo].[S2_SerialNumberRule](
	[id] [int] IDENTITY(1,1) NOT NULL,
    [Title] [nvarchar](200) NULL,
    [SortType] [int] NULL,
    [SortID] [int] NULL,
    [Unit] [int] NULL,
    [IsMain] [int] NULL,
    [IsTemplete] [int] NULL,
    [YearType] [int] NULL,
    [YearInx] [int] NULL,
    [YearOpen] [int] NULL,
    [MonthInx] [int] NULL,
    [MonthOpen] [int] NULL,
    [DayInx] [int] NULL,
    [DayOpen] [int] NULL,
    [Creator] [int] NULL,
    [InDate] [datetime] NULL,
    [UpUser] [int] NULL,
    [UpTime] [datetime] NULL,
    [DelCate] [int] NULL,
    [DelTime] [datetime] NULL,
    [Del] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
--序列号规则明细部分表
CREATE TABLE [dbo].[S2_SerialNumberRuleList](
	[id] [int] IDENTITY(1,1) NOT NULL,
    [RuleID] [int] NULL,
    [PartType] [int] NULL,
    [SType] [int] NULL,
    [NValue] [nvarchar](50) NULL,
    [UNumber] [int] NULL,
    [UType] [int] NULL,
    [BType] [int] NULL,
    [BValue] [nvarchar](50) NULL,
    [SortInx] [int] NULL,
    [Del] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

--序列号关联关系表
CREATE TABLE [dbo].[S2_SerialNumberRelation](
	[id] [int] IDENTITY(1,1) NOT NULL,
    [SerialID] [int] NULL,
    [BillType] [int] NULL,
    [BillID] [int] NULL,
    [BillListType] [int] NULL,
    [ListID] [int] NULL,
    [Del] [int] NULL,
    [HandleStatus] [int] NULL DEFAULT(0),
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]

--@##mode:index;clustered:false;fields:SerialID,BillType
--@##mode:index;clustered:false;fields:BillType,BillID

GO
--序列号规则表
CREATE TABLE [dbo].[S2_SerialNumberRule_His](
	[id] [int] IDENTITY(1,1) NOT NULL,
    [MainID] [int] NULL,
    [RuleID] [int] NULL,
    [Title] [nvarchar](200) NULL,
    [SortType] [int] NULL,
    [SortID] [int] NULL,
    [Unit] [int] NULL,
    [YearType] [int] NULL,
    [YearInx] [int] NULL,
    [YearOpen] [int] NULL,
    [MonthInx] [int] NULL,
    [MonthOpen] [int] NULL,
    [DayInx] [int] NULL,
    [DayOpen] [int] NULL,
    [Creator] [int] NULL,
    [InDate] [datetime] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
--序列号规则明细部分表
CREATE TABLE [dbo].[S2_SerialNumberRuleList_His](
	[id] [int] IDENTITY(1,1) NOT NULL,
    [RuleID] [int] NULL,
    [RuleListID] [int] NULL,
    [PartType] [int] NULL,
    [SType] [int] NULL,
    [NValue] [nvarchar](50) NULL,
    [UNumber] [int] NULL,
    [UType] [int] NULL,
    [BType] [int] NULL,
    [BValue] [nvarchar](50) NULL,
    [SortInx] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

--库龄分析表自定义天数表
CREATE TABLE [dbo].[ku_kuAgeDateSet](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[title] [nvarchar](50) NOT NULL,
	[startDay] [int] NULL,
	[endDay] [int] NOT NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

--罚款逾期设置表
CREATE TABLE [dbo].[sort12](
	[id] [int] identity(1,1) not Null,
	[sort1] [nvarchar](500) null,  --主题
	[intro] [nvarchar](500) null,  --备注
	[gate2] [int] null,		--天数
	[gate3] [decimal](25, 12),		--扣除比例
	[del] [int] null --1:正常，2:删除，3:保留
)

GO

CREATE TABLE [dbo].[Scankuoutlist2](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ord] [int] NULL,
	[num1] [decimal](25, 12) NOT NULL,
	[num2] [decimal](25, 12) NULL,
	[num3] [decimal](25, 12) NULL,
	[price1] [decimal](25, 12) NOT NULL,
	[pricemonth] [decimal](25, 12) NULL,
	[money1] [decimal](25, 12) NOT NULL,
	[company] [int] NULL,
	[contract] [int] NULL,
	[contractlist] [int] NULL,
	[kuout] [int] NULL,
	[kuoutlist] [int] NULL,
	[area] [int] NULL,
	[trade] [int] NULL,
	[unit] [int] NOT NULL,
	[ck] [int] NULL,
	[ph] [nvarchar](50) NULL,
	[xlh] [nvarchar](100) NULL,
	[datesc] [datetime] NULL,
	[dateyx] [datetime] NULL,
	[bz] [int] NULL,
	[js] [decimal](25, 12) NULL,
	[intro] [nvarchar](200) NULL,
	[caigoulist] [int] NULL,
	[kuinlist] [int] NULL,
	[ku] [int] NULL,
	[gys] [int] NULL,
	[date1] [datetime] NULL,
	[date7] [datetime] NULL,
	[del] [int] NULL,
	[cateid] [int] NULL,
	[cateid2] [int] NULL,
	[cateid3] [int] NULL,
	[addcate] [int] NULL,
	[mxid] [int] NULL,
	[sort1] [int] NULL,
	[HCStatus] [int] NULL,
	[zdy1] [nvarchar](200) NULL,
	[zdy2] [nvarchar](200) NULL,
	[zdy3] [nvarchar](200) NULL,
	[zdy4] [nvarchar](200) NULL,
	[zdy5] [int] NULL,
	[zdy6] [int] NULL,
	[MOrderID] [int] NULL,
	[M2_OrderID] [int] NULL,
	[date2] [datetime] NULL,
	[price2] [decimal](25, 12) NULL,
	[money2] [decimal](25, 12) NULL,
	[JoinDBListID] [int] NULL,
	[StoreCode] [varchar](200) NULL,
	[zzyckData] [varchar](500) NULL,
	[numleft] [decimal](25, 12) NULL,
	[kuid] [int] NULL,
	[ScanType] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[plan_fk](
	[ord] [int] IDENTITY(1,1) NOT NULL,
	[money1] [decimal](25, 12) NULL,
	[money2] [decimal](25, 12) NULL,
	[date1] [datetime] NULL,
	[pay] [int] NULL,
	[caigou] [int] NULL,
	[addcate] [int] NULL,
	[intro] [nvarchar](200) NULL,
	[del] [int] NULL,
	[del2] [int] NULL,
	[delcate] [int] NULL,
	[deldate] [datetime] NULL,
	[date7] [datetime] NULL,
PRIMARY KEY CLUSTERED
(
	[ord] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[erp_m2wfpa_Nodes_log_tb](
	[WAID] [int] NOT NULL,
    [WFPAID] [int] NULL,
    [ProcIndex] [int] NULL,
    [BaseWFPAID] [int] NULL,
    [nodeType] [int] NULL,
    [pgsl] [decimal](25, 12) NULL,
    [sjsl] [decimal](25, 12) NULL,
    [hgsl] [decimal](25, 12) NULL,
    [fgsl] [decimal](25, 12) NULL,
    [bfsl] [decimal](25, 12) NULL,
    [codeBatch] [int] NULL,
    [codeProduct] [nvarchar](200) NULL,
    [codeProductID] [int] NULL,
    [SPresult] [int] NULL,
    [lastExecDate] [datetime] NULL
) ON [PRIMARY]

--@##mode:index;clustered:false;fields:WAID

GO

CREATE TABLE [dbo].[erp_m2wfpa_Nodes_Plan_tb](
	[WAID] [int] NOT NULL,
    [ID] [int] NULL,
    [BaseID] [int] NULL,
    [NodeType] [int] NULL,
    [ProcIndex] [int] NULL,
    [Finished] [int] NULL,
    [basePlanNum] [decimal](25, 12) NULL,
    [PID] [int] NULL,
    [ReportingExceptionStrategy] [int] NULL,
    [BatchNumberStart] [int] NULL,
    [SerialNumberStart] [int] NULL,
    [ConversionBL] [decimal](25, 12) NULL,
    [ReportingRounding] [int] NULL,
    [PreIndex] [int] NULL
) ON [PRIMARY]

--@##mode:index;clustered:false;fields:WAID

GO

CREATE TABLE [dbo].[sys_sale_ProductAttrGroup](
    [ID] [int] IDENTITY(1,1) NOT NULL,
	[BillType] [int] NOT NULL DEFAULT (0),
	[BillListType] [int] NOT NULL DEFAULT (0),
	[BillId] [int] NOT NULL,
	[ListID] [int] NOT NULL,
    [ProductID] [int] NOT NULL,
	[Num1] [decimal](25,12) NOT NULL,
	[Attrs] [varchar](20) NOT NULL,
    [Del] [int] NULL,
	PRIMARY KEY CLUSTERED (
		[BillType] ASC,
		[BillListType] ASC,
		[BillId] ASC,
		[ListID] ASC,
        [Attrs] ASC
	) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[sys_sale_ProductAttrValue](
    [ID] [int] IDENTITY(1,1) NOT NULL,
	[GroupID] [int] NOT NULL DEFAULT (0),
	[AttrID] [int] NOT NULL,
	[AttrValue] [int] NOT NULL,
    [Inx] [int] NULL,
    [Del] [int] NULL,
	PRIMARY KEY CLUSTERED (
		[GroupID] ASC,
		[AttrID] ASC,
        [AttrValue] ASC
	) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[f_VoucherMergerRules](
	[ID] [INT] IDENTITY(1,1) NOT NULL,
	[AbutmentMode] [INT] NULL,
	[AbutmentClass] [INT] NULL,
	[MergerRuleID] [INT] NULL,
	[MergerRuleName] [VARCHAR](50) NULL,
	[MergerDBName] [VARCHAR](50) NULL,
	[Grade] [INT] NULL,
	[IsOpen] [INT] NULL,
	[UpUser] [INT] NULL,
	[UpTime] [DATETIME] NULL,
    PRIMARY KEY CLUSTERED
    (
        [ID] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[ContractRoyalty](
	[ID] [INT] IDENTITY(1,1) NOT NULL,
    [Contract] [int] NOT NULL,
	[RoyaltyCateID] [INT] NOT NULL,
	[RoyaltyBL] decimal(25,12) NOT NULL,
	[RoyaltyMoney] decimal(25,12) NOT NULL,
    [Intro] [nvarchar](200) NULL,
	[del] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [ID] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


--@##mode:index;clustered:false;fields:Contract,del

GO

CREATE TABLE [dbo].[M2_ActualBoardScheme](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Title] [nvarchar](200) NOT NULL DEFAULT(''),
	[Sort] [int] NOT NULL DEFAULT(1),
	[Multiple] [decimal](20, 12) NOT NULL DEFAULT(1),
	[Skins] [int] NOT NULL DEFAULT(1),
	[ShowType] [int] NOT NULL DEFAULT(0),
	[PageSize] [int] NOT NULL DEFAULT(5),
	[TimeOut] [decimal](20, 12) NOT NULL DEFAULT(30),
	[TimeOutUnit] [int] NOT NULL DEFAULT(0),
	[RollSpeed] [int] NOT NULL DEFAULT(80),
	[Dimension] [int] NOT NULL DEFAULT(0),
	[IsDefault] [bit] NOT NULL DEFAULT(0),
    [IsStop] [bit] NOT NULL DEFAULT(0),
	[InDate] [datetime] NOT NULL DEFAULT(getdate()),
	[Creator] [int] NOT NULL DEFAULT(0),
	[UpDateTime] [datetime] NOT NULL DEFAULT(getdate()),
	[UpUser] [int] NOT NULL DEFAULT(0),
	[Del] [int] NOT NULL DEFAULT(1),
    PRIMARY KEY CLUSTERED
    (
        [Id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[M2_ActualBoardCustomFields](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Title] [nvarchar](200) NOT NULL DEFAULT(''),
	[Sort] [int] NOT NULL DEFAULT(1),
	[SortMin] [int] NOT NULL DEFAULT(1),
	[SortMax] [int] NOT NULL DEFAULT(4),
	[MustShow] [bit] NOT NULL DEFAULT(0),
	[IsShow] [bit] NOT NULL DEFAULT(1),
	[AutoWidth] [decimal](20, 12) NOT NULL DEFAULT(8),
    PRIMARY KEY CLUSTERED
    (
        [Id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[M2_ActualBoardCustomList](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ActualBoardSchemeId] [int] NOT NULL DEFAULT(0),
	[FieldId] [int] NOT NULL DEFAULT(0),
	[Sort] [int] NOT NULL DEFAULT(0),
	[IsShow] [bit] NOT NULL DEFAULT(1),
	[AutoWidth] [decimal](20, 12) NOT NULL DEFAULT(8),
    PRIMARY KEY CLUSTERED
    (
        [Id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[M2_OrderCostsShare](
	[Id] [int] IDENTITY(1,1) NOT NULL, 
    [SourceId] [int] NOT NULL DEFAULT ((0)),
    [ShareMode] [int] NULL,
    [FeeType] [int]  NULL,
    [DeptType] [int] NULL,
    [DeptId] [int] NULL,
    [MId] [int] NULL,
	[ShareDate] [date] NULL,
	[ShareMoney] [decimal](25, 12) NOT NULL DEFAULT ((0)),
	[ShareType] [int] NOT NULL DEFAULT ((0)),
	[Complete] [bit] NOT NULL DEFAULT ((0)),
	[ShareUser] [int] NOT NULL DEFAULT ((0)),
	[ShareTime] [datetime] NULL,
	[Creator] [int] NOT NULL DEFAULT ((0)),
	[InDate] [datetime] NOT NULL DEFAULT (getdate()),
    [IsOld] [int] NULL,
	[Del] [int] NOT NULL DEFAULT ((1)),
	[IsAutoCollect] [int] NOT NULL DEFAULT ((0)),
    PRIMARY KEY CLUSTERED
    (
        [Id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[M2_OrderCostsShareList](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[OcsId] [int] NOT NULL DEFAULT ((0)),
    [DeptType] [int] NULL,
    [DeptId] [int] NULL,
	[OrderListId] [int] NOT NULL DEFAULT ((0)),
    [WaId] [int] NOT NULL DEFAULT((0)),
	[ProductId] [int] NOT NULL DEFAULT ((0)),
	[Unit] [int] NOT NULL DEFAULT ((0)),
	[OrderNum] [decimal](25, 12) NOT NULL DEFAULT ((0)),
	[KuInNum] [decimal](25, 12) NOT NULL DEFAULT ((0)),
    [FinishNum] [decimal](25, 12) NOT NULL DEFAULT ((0)),
	[WorkingHours] [decimal](25, 12) NOT NULL DEFAULT ((0)),
	[HoursUnit] [int] NOT NULL DEFAULT ((2)),
    [LabourWage] [decimal](25, 12) NOT NULL DEFAULT ((0)),
	[DirectMaterial] [decimal](25, 12) NOT NULL DEFAULT ((0)),
	[DirectCost] [decimal](25, 12) NOT NULL DEFAULT ((0)),
    [ShareMoney] [decimal](25, 12) NOT NULL DEFAULT((0)),
    [Remark] [varchar](8000) NOT NULL DEFAULT(''),
    [IsOld] [int] NULL,
	[Del] [int] NOT NULL DEFAULT ((1)),
    PRIMARY KEY CLUSTERED
    (
        [Id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[M2_OrderCostsNotionalPoolingList](
	[Id] [int] IDENTITY(1,1) NOT NULL,
    [NotionalPoolingMode] [int]  NULL,
    [FeeType] [int]  NULL,
    [FromType] [int]  NULL,
    [DeptId] [int]  NULL,
    [MId] [int]  NULL,
	[OcsId] [int] NOT NULL,
	[PaybxlId] [int] NOT NULL,
	[Money1] [decimal](25, 12) NOT NULL,
	[Del] [int] NOT NULL,
    PRIMARY KEY CLUSTERED
    (
        [Id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO
CREATE TABLE [dbo].[HrKQ_AttendanceApplyChangeLog](
	[ID] [INT] IDENTITY(1,1) NOT NULL,
	[ApplyID] [INT] NOT NULL,
	[Reason] [NTEXT] NOT NULL,
	[Creator] [INT] NOT NULL,
	[Indate] [DATETIME] NOT NULL,
	PRIMARY KEY CLUSTERED ( [ID] ASC ) ON [PRIMARY]
)

GO

CREATE TABLE [dbo].[HrKQ_AttendanceApplyZdyValue](
	[ApplyID] [INT] NOT NULL,
	[FieldID] [INT] NOT NULL,
	[Value] [NVARCHAR](2000) NULL,
	[BigValue] [NTEXT] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

CREATE TABLE [dbo].[HrKQ_AttendanceLog](
	[ID] [BIGINT] IDENTITY(1,1) NOT NULL,
	[UserId] [INT] NULL,
	[LogDate] [DATETIME] NOT NULL,
	[TimeArrangeID] [INT] NULL,
    [ClockListID] [int]  NULL,
	[StartTime] [DATETIME] NULL,
	[EndTime] [DATETIME] NULL,
	[TS] [DATETIME] NULL,
	[TE] [DATETIME] NULL,
	[StatusType] [VARCHAR](200) NULL,
	[WorkLong] [DECIMAL](25, 12) NULL,
	[NoWorkLong] [DECIMAL](25, 12) NULL,
	[AbsenteeismLong] [DECIMAL](25, 12) NULL,
	[LateLong] [DECIMAL](25, 12) NULL,
	[EarlyLong] [DECIMAL](25, 12) NULL,
	[DataFrom] [INT] NULL,
	[DataFromID] [INT] NULL,
	[DataType] [INT] NULL,
	[Creator] [INT] NOT NULL,
	[InDate] [DATETIME] NOT NULL,
	[UpUser] [INT] NULL,
	[UpTime] [DATETIME] NULL,
	[CurrAttdType] [INT] NULL,
	[DayHourBL] [DECIMAL](25, 12) NULL,
	[GroupId] [int]  NULL,
	[ClockT1] [DATETIME] NULL,
	[ClockT2] [DATETIME] NULL,
	[DataVersion] [int]  NULL,
	[AnalysisRemark] [nvarchar](500)  NULL,
	[DayBatchIndex] int NULL,
	[IsHideData] [int]  NOT NULL DEFAULT(0),
	[IsNoComplete] [int]  NULL,
	[UnusualWorkType] [int]  NULL,
	[Clock1Type] [int] NULL,
	[Clock2Type] [int] NULL,
	[ExchangeRestBL] [DECIMAL](25, 12) NULL,
	[ExchangeRestLimitDate] DATETIME NULL,
	PRIMARY KEY CLUSTERED ( [ID] ASC ) ON [PRIMARY]
)

--@##mode:index;clustered:false;fields:IsNoComplete
--@##mode:index;clustered:false;fields:UserId;include:LogDate

GO

CREATE TABLE [dbo].[HrKQ_OverTimeUsedList](
	[ID] [BIGINT] IDENTITY(1,1) NOT NULL,
	[KqLogDate] [DATETIME] NOT NULL,
	[KqUserId] [int] NOT NULL,
    [KqLogType] [int],
	[UsedType] [int] NOT NULL,
	[UsedNum] [DECIMAL](25, 12) NOT NULL,
	[RestID] [int] NOT NULL,
	[WageslistID] [int] NOT NULL,
	[InDate] [DATETIME] NOT NULL,
	PRIMARY KEY CLUSTERED ( [ID] ASC ) ON [PRIMARY]
)

GO

CREATE TABLE [dbo].[HrKQ_AttendanceMachine](
	[ID] [INT] IDENTITY(1,1) NOT NULL,
	[Title] [NVARCHAR](50) NULL,
	[BH] [NVARCHAR](50) NULL,
	[Location] [NVARCHAR](200) NULL,
	[Intro] [NTEXT] NULL,
	[UserSync] [INT] NULL,
	[UserSyncProcess] [INT] NULL,
	[Creator] [INT] NULL,
	[InDate] [DATETIME] NULL,
	[UpUser] [INT] NULL,
	[UpTime] [DATETIME] NULL,
	PRIMARY KEY CLUSTERED ( [ID] ASC ) ON [PRIMARY]
)

GO

CREATE TABLE [dbo].[HrKQ_AttendanceTypeZdy](
	[ID] [INT] IDENTITY(1,1) NOT NULL,
	[TypeID] [INT] NOT NULL,
	[Title] [NVARCHAR](50) NULL,
	[UiType] [INT] NULL,
	[IsUsed] [INT] NULL,
	[ShowIndex] [INT] NULL,
	[MustFillIn] [INT] NULL,
	PRIMARY KEY CLUSTERED ( [ID] ASC ) ON [PRIMARY]
)

GO

CREATE TABLE [dbo].[HrKQ_HolidayCalendar](
	[ID] [INT] IDENTITY(1,1) NOT NULL,
	[DateYear] [INT] NOT NULL,
	[Title] [NVARCHAR](50) NOT NULL,
	[RestDate] [DATETIME] NOT NULL,
	[WorkDate] [DATETIME] NULL,
	[DataSourcesType] [INT] NOT NULL,
	[Creator] [INT] NOT NULL,
	[InDate] [DATETIME] NOT NULL,
	[UpUser] [INT] NULL,
	[UpTime] [DATETIME] NULL,
	PRIMARY KEY CLUSTERED ( [ID] ASC ) ON [PRIMARY]
)

GO

CREATE TABLE [dbo].[HrKQ_PersonGroupDate](
	[ID] [BIGINT] IDENTITY(1,1) NOT NULL,
	[GroupID] [INT] NOT NULL,
	[UserID] [INT] NOT NULL,
	[BeginDate] [DATETIME] NULL,
	[EndDate] [DATETIME] NULL,
    PRIMARY KEY CLUSTERED
    (
        [ID] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[HrKQ_TimeArrangeAdjustment](
	[ID] [INT] IDENTITY(1,1) NOT NULL,
	[Title] [NVARCHAR](100) NOT NULL,
    [ApplyType] [INT] NOT NULL,
	[Intro] [NTEXT] NULL,
	[Status] [INT] NULL,
	[LastApproveTime] [datetime] null,
	[LastApproveUser] [int] null,
	[Creator] [INT] NOT NULL,
	[Indate] [DATETIME] NOT NULL,
	[UpUser] [INT] NULL,
	[UpTime] [DATETIME] NULL,
    PRIMARY KEY CLUSTERED ( [ID] ASC ) ON [PRIMARY]
)

GO

CREATE TABLE [dbo].[HrKQ_TimeArrangeAdjustmentList](
	[ID] [INT] IDENTITY(1,1) NOT NULL,
	[TAID] [INT] NOT NULL,
	[UserID] [INT] NOT NULL,
	[AttendanceDate] [DATETIME] NOT NULL,
	[BeforeTimeArrange] [INT] NOT NULL,
	[AfterTimeArrange] [INT] NOT NULL,
	[Remark] [NVARCHAR](500) NULL,
    PRIMARY KEY CLUSTERED ( [ID] ASC ) ON [PRIMARY]
)
GO
CREATE TABLE [dbo].[HrKQ_AttendanceTypeZdyFieldOptions](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[FieldId] [int] NULL,
	[Text] [nvarchar](100) NULL,
	[ShowIndex] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [Id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[HrKQ_AnnualLeaveUseLog](
	[ID] [BIGINT] IDENTITY(1,1) NOT NULL,
	[ApplyID] [INT] NOT NULL DEFAULT (0),
    [UserId] [INT] NOT NULL DEFAULT (0),
	[UseYear] [INT] NOT NULL DEFAULT (0),
	[UseDayNum] [DECIMAL](25, 12) NOT NULL DEFAULT (0),
    [UseYearGrantDate] [DATETIME] NOT NULL,
    PRIMARY KEY CLUSTERED
    (
        [ID] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[HrKQ_AnnualLeavePlan](
	[ID] [INT] IDENTITY(1,1) NOT NULL,
	[UserId] [INT] NOT NULL,
	[SendYear] [INT] NOT NULL,
	[DayNum] [DECIMAL](25, 12) NOT NULL DEFAULT (0),
    [StartDate] [DATETIME] NOT NULL,
    [EndDate] [DATETIME] NOT NULL,
    [EffectiveDate] [DATETIME] NOT NULL,
    [CreateDate] [DATETIME] NOT NULL,
    [UpdateDate] [DATETIME] NOT NULL,
    PRIMARY KEY CLUSTERED
    (
        [ID] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[PayBackSure](
	[ID] [INT] IDENTITY(1,1) NOT NULL,
    [Title] [nvarchar](100) null,
	[BH] [nvarchar](100) null,
    [ResFileID][int] null,
	[Intro] [nvarchar](200) null,
	[Company]  int null,
    [Money1] [decimal](25,12) not null DEFAULT (0),
	[Money2] [decimal](25,12) not null DEFAULT (0),
	[WipeMoney] [decimal](25,12) null,
	[Bz]  int null,
	[PayUser]  int null,
	[PayDate] [datetime] null,
	[Status] [int] null,
	[LastApproveTime] [datetime] null,
	[LastApproveUser] [int] null,
    [DataVersion]  int not null,
	[Creator] [int] not null,
	[InDate] [datetime] not null,
	[UpUser] [int] null,
	[UpTime] [datetime] null,
	[Del] [int] not null,
	[DelCate] [int] null,
	[DelTime] [datetime] null,
    PRIMARY KEY CLUSTERED
    (
        [ID] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[PayBackSureList](
	[ID] [BIGINT] IDENTITY(1,1) NOT NULL,
	[SureID] [int] null,
	[BackType] [int] null,
	[Bz] [int] null,
	[Money1] [decimal](25,12) not null,
    [MoneyforPay]  [decimal](25,12)  not null default(0),
	[MoneyforOuter]  [decimal](25,12)  not null default(0),
	[Date1] [datetime] not null,
	[Dealer] [int] null,
	[ReceiptDate] [datetime] null,
	[Pay] [int] not null,
	[Bank] [int] null,
	[YPayId] [int] null,
	[Bankin4ListId] [int] null,
	[AptDraftId] [int] null,
	[AptActionId] [int] null,
	[Intro] [nvarchar](100) null,
	[ParentListId] [int] null,
	[DataVersion] [int] not null,
    [RowIndex] [int] not null,
    PRIMARY KEY CLUSTERED
    (
        [ID] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[AcceptanceActionLog](
	[ID] [INT] IDENTITY(1,1) NOT NULL,
    [AcceptanceID] [int] null,
	[ActionType] [int] null,
	[JoinBillType] [int] null,
	[JoinBillID] [int] null,
	[BatchID] [int] null,
	[Money1] [decimal](25,12) not null,
    [OperationDate] [datetime] not null,
	[BankAccount] [int] null,
    [ServiceCharge] [decimal](25,12) null,
	[DiscountBank] [nvarchar](100) null,
	[Endorser] [nvarchar](100) null,
    [Endorsee] [nvarchar](100) null,
	[Creator] [int] not null,
	[InDate] [datetime] not null,
	[UpUser] [int] not null,
	[UpTime] [datetime] not null,
	[Del] [int] not null,
	[DelCate] [int] null,
	[DelTime] [datetime] null,
    PRIMARY KEY CLUSTERED
    (
        [ID] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[AcceptanceDraft](
	[ID] [INT] IDENTITY(1,1) NOT NULL,
	[SN] [nvarchar](100) null,
	[xySN] [nvarchar](100) null,
	[Money1] [decimal](25,12) not null,
	[clsType] [int] null,
	[CurrDirection] [int] null,
	[CanTransfer] [int] not null,
	[UseStatus] [int] null,
	[BankInStatus] [int] null,
	[BankOutStatus] [int] null,
    [ShowUseStatus] [int] null,
    [ShowBankInOrOutStatus] [int] null,
	[Lssuer] [nvarchar](100) null,
	[LssuerBankNo] [nvarchar](100) null,
	[LssuerBankName] [nvarchar](100) null,
	[Endorser] [nvarchar](100) null,
	[EndorseDate] [nvarchar](100) null,
	[Drawee] [nvarchar](100) null,
	[DraweerBankNo] [nvarchar](100) null,
	[DraweeBankName] [nvarchar](100) null,
	[Acceptor] [nvarchar](100) null,
	[AcceptorBankNo] [nvarchar](100) null,
	[AcceptorBankName] [nvarchar](100) null,
	[IssueDate] [datetime] not null,
	[AcceptDate] [datetime] not null,
	[LimitEndDate] [datetime] not null,
    [Intro] ntext null,
	[Creator] [int] not null,
	[InDate] [datetime] not null,
	[UpUser] [int] not null,
	[UpTime] [datetime] not null,
	[Del] [int] not null,
	[DelCate] [int] null,
	[DelTime] [datetime] null,
    PRIMARY KEY CLUSTERED
    (
        [ID] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[PrintTemplateReserve](
	[ID] [BIGINT] IDENTITY(1,1) NOT NULL,
	[Ord] [INT] NOT NULL,
	[Title] [nvarchar](100) NULL,
	[VersionStr] [nvarchar](50) NULL,
	[ReData] [ntext] NULL,
	[UserId] [INT] NULL,
	[UpDateTime] [DATETIME] NULL,
    PRIMARY KEY CLUSTERED
    (
        [ID] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]



GO

CREATE TABLE [dbo].[PaybackInvoiceSure](
	[ID] [INT] IDENTITY(1,1) NOT NULL,
	[SN] [nvarchar](100) null,
    [company] int NULL,
	[Date1] [datetime] null,
	[Date2] [datetime] null,
    [Bz] [int] not null,
	[Money1] [decimal](25,12) not null,
	[HL] [decimal](25,12) not null,
    [MoneyBeforeTax] [decimal](25,12) not null,
    [TaxRate] [decimal](25,12) null,
    [TaxValue] [decimal](25,12) not null,
	[TaxMoney] [decimal](25,12) not null,
    [InvoiceCode] [varchar](50) null,
    [InvoiceSN] [nvarchar](100) null,
	[InvoiceVector] [int] null,
	[InvoiceType] [int] null,
	[InvoiceTitle] [nvarchar](200) not null,
	[InvoiceTaxno] [nvarchar](200) null,
	[InvoiceAddr] [nvarchar](200) null,
	[InvoicePhone] [nvarchar](200) null,
	[InvoiceBank] [nvarchar](200) null,
	[InvoiceBankAcc] [nvarchar](200) null,
	[RedJoinSureId] [int] null,
	[Intro] [nvarchar](500) null,
	[Status] [int] null,
	[LastApproveTime] [datetime] null,
	[LastApproveUser] [int] null,
    [Invoicely] [int] null,
    [isInvoiced] [int] NOT NULL DEFAULT(0), --0 未开票 ,1 已开票 ,3 已废止,4 开票失败
	[invoiceCate] [int] NULL,
	[invoiceDatetime] [datetime] NULL,
	[Creator] [int] not null,
	[Title] [nvarchar](200) not null,
	[InDate] [datetime] not null,
	[UpUser] [int] not null,
	[UpTime] [datetime] not null,
	[Del] [int] not null,
	[DelCate] [int] null,
	[DelTime] [datetime] null,
    [receiver] [nvarchar](50) NULL,
	[mobile] [nvarchar](50) NULL,
	[phone] [nvarchar](50) NULL,
	[areaId] [int] NULL,
	[ADDRESS] [nvarchar](200) NULL,
	[zip] [nvarchar](50) NULL,
    [BillingEquipment] [int] NULL,
    [BillingType] [int] NULL,
    [TaxPreferenceType] [int] NULL,
    [ExportTaxRebate] [int] NULL,
    [InfoNotes] [nvarchar](300) NULL,
    [NoticeID] [int] NULL,
    [FailureReason] [varchar](500) NULL,
    [InvoiceAddress] [nvarchar](200) NULL,
    [ElectronicSignature] [int] NULL,
    [InvoicingMode] [int] NOT NULL DEFAULT(0),
    [Cipher] [nvarchar](200) NULL,
    [CheckCode] [nvarchar](50) NULL,
    [GoodsListFlag] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [ID] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[BusinessCheck](
	[ID] [INT] IDENTITY(1,1) NOT NULL,
	[CoreType] [int] null,
	[FromType] [int] null,
    [BZ] [int] not null,
	[BussCompany] [int] null,
    [InvoiceStatus] [int] null,
	[BussPerson] [int] null,
	[MyPerson] [int] null,
	[Date1] [datetime] not null,
	[CKDate1] [datetime] not null,
	[CKDate2] [datetime] not null,
	[Intro] [nvarchar](200) null,
	[CompleteStatus] [int] null,
	[Creator] [int] not null,
	[Title] [nvarchar](100) not null,
	[InDate] [datetime] not null,
	[UpUser] [int] not null,
	[UpTime] [datetime] not null,
	[Del] [int] not null,
	[DelCate] [int] null,
	[DelTime] [datetime] null,
    PRIMARY KEY CLUSTERED
    (
        [ID] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[BusinessCheckLists](
	[ID] [INT] IDENTITY(1,1) NOT NULL,
	[CheckId] [int] null,
	[FromType] [int] null,
	[FromId] [int] not null,
	[FromListId] [int] not null,
	[RootListId] [int] not null,
	[RootBackListId] [int] not null,
	[ProductID] [int] null,
	[Unit] [int] not null,
	[commUnitAttr] [nvarchar](100) null,
	[ProductAttr1] [int] null,
	[ProductAttr2] [int] null,
	[ProductAttrBatchId] [int] not null,
	[Price1] [decimal](25,12) not null,
	[Num1] [decimal](25,12) not null,
	[Money1] [decimal](25,12) not null,
	[InvoiceType] [int] not null,
	[TaxRate] [decimal](25,12) not null,
	[TaxValue] [decimal](25,12) not null,
	[Del] [int] not null,
	[Intro] [nvarchar](200) null,
    [RowIndex] [int] not null,
    PRIMARY KEY CLUSTERED
    (
        [ID] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[PayoutInvoiceSure](
	[ID] [INT] IDENTITY(1,1) NOT NULL,
	[SN] [nvarchar](100) null,
	[Date1] [datetime] null,
	[Date2] [datetime] null,
    [Bz] [int] not null,
	[Money1] [decimal](25,12) not null,
	[HL] [decimal](25,12) not null,
    [MoneyBeforeTax] [decimal](25,12) not null,
    [TaxRate] [decimal](25,12) null,
    [TaxValue] [decimal](25,12) not null,
	[TaxMoney] [decimal](25,12) not null,
    [InvoiceSN] [nvarchar](100) null,
	[InvoiceVector] [int] null,
	[InvoiceType] [int] null,
	[RedJoinSureId] [int] null,
	[Intro] [nvarchar](200) null,
	[Status] [int] null,
	[LastApproveTime] [datetime] null,
	[LastApproveUser] [int] null,
	[CostStatus] [int] null,
    [Invoicely] [int] null,
	[Creator] [int] not null,
	[Title] [nvarchar](100) not null,
	[InDate] [datetime] not null,
	[UpUser] [int] not null,
	[UpTime] [datetime] not null,
	[Del] [int] not null,
	[DelCate] [int] null,
	[DelTime] [datetime] null,
    PRIMARY KEY CLUSTERED
    (
        [ID] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[PayOutSure](
	[ID]  int IDENTITY(1,1) not null,
	[Title]  nvarchar(100) not null,
	[SN]  nvarchar(100) null,
	[Status]  int null,
	[LastApproveTime] [datetime] null,
	[LastApproveUser] [int] null,
	[Intro]  ntext null,
	[Company]  int null,
	[DataVersion]  int not null,
	[Creator]  int not null,
	[InDate]  datetime not null,
	[UpUser]  int not null,
	[UpTime]  datetime not null,
	[Del]  int not null default(1),
	[DelCate]  int null,
	[DelTime]  datetime null,
	[Cls] int null,
	[gysBank] nvarchar(200)  null,
	[Money1] [decimal](25,12) null,
	[WipeMoney] [decimal](25,12) not null  default(0),
	[dkMoney] [decimal](25,12) not null default(0),
	[Complete]  int not null default(0),
	[ApplyDate]  datetime null,
	[bz]  int null,
	[PayUser]  int null,
	[PayDate]  datetime null,
	[SplitRootId] int null,
	[ResFileID] int null,
	[OldVerId] [int] null,
	[Intro2] ntext null,
    PRIMARY KEY CLUSTERED
    (
        [ID] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[PayOutSureList](
	[ID]  int IDENTITY(1,1) not null,
	[SureID]  int null,
	[PayType]  int null,
	[Bz]  int null,
	[Money1]  [decimal](25,12)  not null default(0),
	[MoneyforPay]  [decimal](25,12)  not null default(0),
	[MoneyforOuter]  [decimal](25,12)  not null default(0),
	[Date1]  datetime not null,
	[Dealer]  int null,
	[ReceiptDate]  datetime not null,
	[Bank]  int null,
	[SvrCharge] [decimal](25,12) not null,
	[YPayId]  int null,
	[Bankout4ListId] [int] null,	
	[AptDraftId]  int null,
	[AptActionId]  int null,
	[Intro]  ntext null,
	[ParentListId] [int] null,
	[DataVersion]  int not null,
	 [RowIndex] [int] not null,
    PRIMARY KEY CLUSTERED
    (
        [ID] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[InvoiceTitleInfo](
	[ID] int IDENTITY(1,1) not null,
    [Company] int not null,
	[Creator] int not null,
	[InDate] datetime not null,
	[InvoiceTitle] nvarchar(200) null,
	[InvoiceTaxno] nvarchar(200) null,
	[InvoiceAddr] nvarchar(200) null,
	[InvoicePhone] nvarchar(200) null,
	[InvoiceBank] nvarchar(200) null,
	[InvoiceBankAcc] nvarchar(200) null,
	[Del] [int] not null,
	[DelCate] [int] null,
	[DelTime] [datetime] null,
    PRIMARY KEY CLUSTERED
    (
        [ID] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[PayoutTypeMap](
	[ID]  int IDENTITY(1,1) not null,
	[PaySortOrd]  int not null,
	[BusinessType]  int null,
	[BusinessSort]  int not null,
    PRIMARY KEY CLUSTERED
    (
        [ID] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[spUpdateLog](
	[ID] [INT] IDENTITY(1,1) NOT NULL,
	[date7] [DATETIME] ,
	[spVer] [VARCHAR](30),
    PRIMARY KEY CLUSTERED
    (
        [ID] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[M2_WFPTask_Assigns](
	[ID] [INT] IDENTITY(1,1) NOT NULL,
	[WAID] [INT] NOT NULL,
	[WFPAID] [INT] NOT NULL,
	[Cateid] [VARCHAR](8000) NULL,
	[MachineID] [INT] NULL,
	[Num] [DECIMAL](25, 12) NOT NULL,
	[DateStart] [DATETIME] NULL,
	[DateEnd] [DATETIME] NULL,
	[Remark] [NVARCHAR](2000) NULL,
	[BeginStatus] [INT] NULL,
	[BeginDate] [DATETIME] NULL,
	[CompleteStatus] [INT] NULL,
    [Creator] [INT] NOT NULL,
	[InDate] [DATETIME] NOT NULL,
    PRIMARY KEY CLUSTERED
    (
        [ID] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[M2_ProcessExecution_Plan](
	[ID] [INT] IDENTITY(1,1) NOT NULL,
	[WAID] [INT] NOT NULL,
    [ProcIndex] [INT] NOT NULL,
    [PreIndex] [INT] NOT NULL,
	[NodeID] [INT] NOT NULL,
	[BaseNodeID] [INT] NOT NULL DEFAULT (0),
    [WPID] [INT] NULL DEFAULT (0),
	[NodeType] [INT] NOT NULL,
	[TaskID] [INT] NULL DEFAULT (0),
	[PlanNum] [DECIMAL](25, 12) NOT NULL,
	[ReportingExceptionStrategy] [INT] NULL,
	[BatchNumberStart] [INT] NULL,
	[SerialNumberStart] [INT] NULL,
	[ConversionBL] [DECIMAL](25, 12) NULL,
	[ReportingRounding] [INT] NULL,
    [ExecTask] [INT] NULL DEFAULT (0),
	[ExecCheck] [INT] NULL DEFAULT (0),
    [Finished] [INT] NOT NULL DEFAULT (0),
    [TerminationTime] [datetime] NULL,
    [NeedSelfTest] [INT] NOT NULL DEFAULT (0),
    PRIMARY KEY CLUSTERED
    (
        [ID] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]

--@##mode:index;clustered:true;fields:ID
--@##mode:index;clustered:false;fields:WAID
GO

CREATE TABLE [dbo].[M2_ProcessExecution_Result](
    [ID] [BIGINT] IDENTITY(1,1) NOT NULL,
	[PlanID] [INT] NOT NULL,
	[WAID] [INT] NOT NULL,
    [ProcIndex] [INT] NOT NULL,
	[NodeID] [INT] NOT NULL,
	[BaseNodeID] [INT] NULL,
	[NodeType] [INT] NOT NULL,
	[TaskID] [INT] NULL DEFAULT (0),
	[codeBatch] [INT] NULL DEFAULT (0),
	[codeProductID] [INT] NULL DEFAULT (0),
    [HgNum] [DECIMAL](25, 12) NOT NULL,
    [HgNumByCheck] [DECIMAL](25, 12) NOT NULL,
    [HgNumByRework] [DECIMAL](25, 12) NOT NULL DEFAULT (0),
    [FgNum] [DECIMAL](25, 12) NOT NULL,
    [FgNumByCheck] [DECIMAL](25, 12) NOT NULL,
    [BfNum] [DECIMAL](25, 12) NOT NULL,
    [BfNumByCheck] [DECIMAL](25, 12) NOT NULL,
	[PreHgNumByCheck] [DECIMAL](25, 12) NOT NULL,
	[ExecedNum] [DECIMAL](25, 12) NOT NULL,
	[CanExecNum] [DECIMAL](25, 12) NOT NULL,
    [LastExecTime] [DATETIME] NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]
--@##mode:index;clustered:false;fields:WAID
--@##mode:index;clustered:false;fields:NodeID,NodeType
--@##mode:index;clustered:false;fields:BaseNodeID;include:HgNum,HgNumByRework,FgNum,BfNum
GO

CREATE TABLE [dbo].[M2_WorkAssignScanCode](
	[WAID] [INT] NOT NULL,
    [Ptype] [INT] NULL,
    [WABH] [NVARCHAR](50) NULL,
    [Num] [DECIMAL](25, 12) NULL,
    [SeriNum] [NVARCHAR](400) NULL,
    [ScanBH] [VARCHAR](10) NULL,
	[CodeText] [NVARCHAR](500) NOT NULL,
	[Creator] [INT] NOT NULL,
	[InDate] [DATETIME] NOT NULL
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[MCostInfo](
	[Id]  int IDENTITY(1,1) not null,
	[ProductId]  int not null,
	[Unit]  int not null,
	[ProductAttr1]  int not null,
	[ProductAttr2]  int not null,
	[CommUnitAttr]  nvarchar(100)  null,
	[CKID]  int not null,
	[KuinListId]  int not null,
    [KuId]  int not null,
	[CostType]  int null,
	[Date1]  datetime not null,
	[Date2]  datetime not null,
	[IsLocked]  bit not null,
	[CurrPrice]  decimal(25,12) not null,
	[StockNum] [decimal](25,12) not null,
	[OnWayNum] [decimal](25,12) not null,
	[CurrNum]  decimal(25,12) not null,
	[CurrMoney]  decimal(25,12) not null,
	[Curr_Material_M]  decimal(25,12) not null  default(0),
	[Curr_Material_W]  decimal(25,12) not null  default(0),
	[Curr_Labor_C]  decimal(25,12) not null  default(0),
	[Curr_Labor_H]  decimal(25,12) not null  default(0),
	[Curr_Outlay_W]  decimal(25,12) not null  default(0),
	[Curr_Outlay_D]  decimal(25,12) not null  default(0),
	[Curr_Outlay_O]  decimal(25,12) not null  default(0),
	[LogCount] int not null DEFAULT (0),
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]
--@##mode:index;clustered:false;fields:CostType,ProductId,ProductAttr1,ProductAttr2
--@##mode:index;clustered:false;fields:ProductId
--@##mode:index;clustered:false;fields:ProductId,Unit
--@##mode:index;clustered:false;fields:Date1,Date2
--@##mode:index;clustered:false;fields:IsLocked

GO

CREATE TABLE [dbo].[MCostLog](
	[Id]  int IDENTITY(1,1) not null,
	[CostId]  int not null DEFAULT (0),
	[LogType]  smallint not null DEFAULT (0),
	[JoinBillListId] [int] not null DEFAULT (0),
	[JoinBillId]  int not null DEFAULT (0),
	[RootBillListid] [int] not null DEFAULT (0),
	[RootBillid] [int] not null DEFAULT (0),
	[RootKuinListId] [int] not null DEFAULT (0),
	[RootChgListId] [int] not null DEFAULT (0),
	[RootChgType] [smallint] not null DEFAULT (0),
	[PDLogId] [int] not null DEFAULT (0),
	[DeleteToId] [int] not null DEFAULT (0),
	[IsHidden] [smallint] not null DEFAULT (0),
	[BindLogId] [int] not null DEFAULT (0),
	[DeductLogId]  int not null DEFAULT (0),
	[DeductDeepIndex]  int not null DEFAULT (0),
	[VoucherVirBillId] int not null  DEFAULT (0),
	[RowIndex]  int not null DEFAULT (0),
	[ProductId]  int not null  DEFAULT (0),
	[kuinType]  smallint not null  DEFAULT (0),
	[kuoutType]  smallint not null  DEFAULT (0),
	[kuid]  int not null  DEFAULT (0),
	[Date1]  datetime not null,
	[Date7]  datetime not null,
	[LogPrice]  decimal(25,12) not null,
	[LogNum]  decimal(25,12) not null,
	[LogMoney]  decimal(25,12) not null,
	[FinaMoney]  decimal(25,12) not null  DEFAULT (0),
	[MthFinaMoney]  decimal(25,12) not null  DEFAULT (0),
	[LogUnit]  int not null DEFAULT (0),
	[LogUnitBL]  decimal(25,12) not null DEFAULT (1),
	[Direction] smallint not null DEFAULT (0),
	[CkId] int not null DEFAULT (0),
	[OldPrice]  decimal(25,12) not null DEFAULT (0),
	[OldStockNum] [decimal](25,12) not null DEFAULT (0),
	[OldOnWayNum] [decimal](25,12) not null DEFAULT (0),
	[OldNum]  decimal(25,12) not null DEFAULT (0),
	[OldMoney]  decimal(25,12) not null DEFAULT (0),
	[NewPrice]  decimal(25,12) not null,
	[NewStockNum] [decimal](25,12) not null,
	[NewOnWayNum] [decimal](25,12) not null,
	[NewNum]  decimal(25,12) not null,
	[NewMoney]  decimal(25,12) not null,
	[Remark] nvarchar(160) NULL,
	[Islocked]  bit Not null DEFAULT (0),
	[LogAssistUnit] int not null DEFAULT (0),
	[LogAssistUnitNum]  decimal(25,12) not null DEFAULT(0),
	[LogAssistUnitBl]  decimal(25,12) not null  DEFAULT(0),
	PRIMARY KEY CLUSTERED 
	(		
		[LogType] ASC,
		[JoinBillListId] ASC,
		[kuid] ASC,
		[JoinBillId] ASC,
		[ProductId] ASC,
		[RootChgType] ASC,
		[RootBillId] ASC, 
		[RootBillListid]  ASC,
		[RootChgListId] ASC
	) ON [PRIMARY]
) ON [PRIMARY]
--@##mode:index;clustered:false;fields:ID
--@##mode:index;clustered:false;fields:CostId
--@##mode:index;clustered:false;fields:ProductId;include:RootKuinListId,Date1,LogUnit
--@##mode:index;clustered:false;fields:LogType;include:CostId,JoinBillListId,RootBillListid,RootChgType,LogNum,LogMoney
--@##mode:index;clustered:false;fields:Date1
--@##mode:index;clustered:false;fields:Islocked
--@##mode:index;clustered:false;fields:RootChgType
--@##mode:index;clustered:false;fields:JoinBillListId,RootChgType,LogType

GO

CREATE TABLE [dbo].[MCostLogPDItem](
	[Id]  int IDENTITY(1,1) not null,
	[CostInfoId] int not null,
	[CostLogId] int not null,
	[Log_Material_M]  decimal(25,12) not null DEFAULT (0),
	[Log_Material_W]  decimal(25,12) not null DEFAULT (0),
	[Log_Labor_H]  decimal(25,12) not null DEFAULT (0),
	[Log_Labor_C]  decimal(25,12) not null DEFAULT (0),
	[Log_Outlay_W]  decimal(25,12) not null DEFAULT (0),
	[Log_Outlay_D]  decimal(25,12) not null DEFAULT (0),
	[Log_Outlay_O]  decimal(25,12) not null DEFAULT (0),
	[Old_Material_M]  decimal(25,12) not null DEFAULT (0),
	[Old_Material_W]  decimal(25,12) not null DEFAULT (0),
	[Old_Labor_H]  decimal(25,12) not null DEFAULT (0),
	[Old_Labor_C]  decimal(25,12) not null DEFAULT (0),
	[Old_Outlay_W]  decimal(25,12) not null DEFAULT (0),
	[Old_Outlay_D]  decimal(25,12) not null DEFAULT (0),
	[Old_Outlay_O]  decimal(25,12) not null DEFAULT (0),
	[New_Material_M]  decimal(25,12) not null DEFAULT (0),
	[New_Material_W]  decimal(25,12) not null DEFAULT (0),
	[New_Labor_H]  decimal(25,12) not null DEFAULT (0),
	[New_Labor_C]  decimal(25,12) not null DEFAULT (0),
	[New_Outlay_W]  decimal(25,12) not null DEFAULT (0),
	[New_Outlay_D]  decimal(25,12) not null DEFAULT (0),
	[New_Outlay_O]  decimal(25,12) not null DEFAULT (0),
	PRIMARY KEY CLUSTERED 
	(
		[CostLogId] ASC
	) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[MCostChgForKuin](
	[ID]  int IDENTITY(1,1) not null,
	[Title]  nvarchar(200) not null,
	[SN]  nvarchar(100) null,
	[ChgType]  int null,
	[sumMoney]  decimal(25,12) not null,
	[CaigouId]  int not null,
	[PayoutInvSureId]  int not null,
	[SupplierId]  int not null,
	[Intro]  [nvarchar](max) null,
	[CostOutStatus]  int null,
    [IsBatchEstimate] int null,
    [RealChangeDate] datetime null, 
	[Creator]  int not null,
	[InDate]  datetime not null,
	[UpUser]  int not null,
	[UpTime]  datetime not null,
	[Del]  int not null default(1),
	[DelCate]  int null,
	[DelTime]  datetime null,
    [Date1]  datetime null,
    [Date2]  datetime null,
    [ShareStatus]  int null,
    PRIMARY KEY CLUSTERED
    (
        [ID] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[MCostChgForKuinlist](
	[ID]  int IDENTITY(1,1) not null,
    [MCID]  int null,
    [KuinType]  int null,
    [KuinId]  int not null,
	[KuinListId]  int not null,
	[KuinCostlogId]  int null,
	[PayoutInvListid]  int not null,
	[InvoiceVector] int not null default(0),
	[DeductChgListId] int not null default(0),
	[chgNum]  decimal(25,12) not null,
	[oldPrice]  decimal(25,12) not null,
	[oldMoney]  decimal(25,12) not null,
	[newPrice]  decimal(25,12) not null,
	[newMoney]  decimal(25,12) not null,
	[CostOutStatus]  int null,
	[intro] [nvarchar](500) NULL,
    [ShareStatus] int null,
    [ShareNum]  decimal(25,12)  null,
    [ShareMoney]  decimal(25,12)  null,
    PRIMARY KEY CLUSTERED
    (
        [ID] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[MCostChgForException](
	[ID]  int IDENTITY(1,1) not null,
	[Title]  nvarchar(100) not null,
	[SN]  nvarchar(100) null,
	[HandleType]  int null,
	[JoinProductId]  int not null DEFAULT (0),
	[JoinKuinList] [int] not null DEFAULT (0),
	[SumCostMoney]  decimal(25,12) not null,
	[Creator]  int not null,
	[InDate]  datetime not null,
	[RealChangeDate]  datetime not null DEFAULT ('1900-1-1'),
	[UpUser]  int not null,
	[UpTime]  datetime not null,
	[Del]  int not null default(1),
	[DelCate]  int null,
	[DelTime]  datetime null,
    [IsCostCollect]  int not null DEFAULT (0),
    [FromType] int null,
	[Intro] [NTEXT] NULL,
    PRIMARY KEY CLUSTERED
    (
        [ID] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[MCostChgForExceptionList](
	[ID]  int IDENTITY(1,1) not null,
	[ChgForErrId]  int null,
	[ChgKuinlistid] [int] null,
	[DtPrice] [decimal](25,12) not null,
	[DtNum]  decimal(25,12) not null,
	[DtCostMoney]  decimal(25,12) not null,
    [Remark] [nvarchar](500) NULL,
    [CostInfoId] int null,
	[ProductId] INT NOT NULL DEFAULT (0),
	[Unit] INT NOT NULL DEFAULT (0),
	[ProductAttr1] INT NOT NULL DEFAULT (0),
	[ProductAttr2] INT NOT NULL DEFAULT (0),
	[KuinlistId] INT NOT NULL DEFAULT (0),
    PRIMARY KEY CLUSTERED
    (
        [ID] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[M2_OneSelfQualityTestingTask](
	[ID] [INT] IDENTITY(1,1) NOT NULL,
	[Title] [NVARCHAR](200) NOT NULL,
	[TaskBh] [NVARCHAR](100) NOT NULL,
	[QcCateid] [INT] NOT NULL,
	[TaskDate] [DATETIME] NOT NULL,
	[PoType] [INT] NOT NULL,
	[WAID] [INT] NOT NULL,
	[QCStatus] [INT] NOT NULL,
	[Creator] [INT] NOT NULL,
	[Indate] [DATETIME] NOT NULL,
    PRIMARY KEY CLUSTERED
    (
        [ID] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[M2_OneSelfQualityTestingTaskList](
	[ID] [INT] IDENTITY(1,1) NOT NULL,
	[TaskID] [INT] NOT NULL,
	[Num] [DECIMAL](25, 12) NOT NULL,
	[codeBatch] [INT] NULL,
	[codeProductID] [INT] NULL,
    [QcCateid] [INT] NOT NULL DEFAULT (0),
	[QCStatus] [INT] NOT NULL,
    [RowIndex] [INT] NOT NULL DEFAULT (0),
    PRIMARY KEY CLUSTERED
    (
        [ID] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[M2_GXQualityTestingTask](
	[ID] [INT] IDENTITY(1,1) NOT NULL,
	[Title] [NVARCHAR](200) NOT NULL,
	[TaskBh] [NVARCHAR](100) NOT NULL,
	[QcCateid] [INT] NOT NULL,
	[TaskDate] [DATETIME] NOT NULL,
    [Zjid] [INT] NOT NULL,
	[Waid] [INT] NOT NULL,
	[QCStatus] [INT] NOT NULL,
	[Creator] [INT] NOT NULL,
	[Indate] [DATETIME] NOT NULL,
    PRIMARY KEY CLUSTERED
    (
        [ID] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[M2_GXQualityTestingTaskList](
	[ID] [INT] IDENTITY(1,1) NOT NULL,
	[TaskID] [INT] NOT NULL,
	[Num] [DECIMAL](25, 12) NOT NULL,
	[codeBatch] [INT] NULL,
	[codeProductID] [INT] NULL,
    [QcCateid] [INT] NOT NULL DEFAULT (0),
	[QCStatus] [INT] NOT NULL,
    [RowIndex] [INT] NOT NULL DEFAULT (0),
    PRIMARY KEY CLUSTERED
    (
        [ID] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[M2_ProcessConfiguration](
	[ID] [INT] IDENTITY(1,1) NOT NULL,
	[GroupFlag] [INT] NOT NULL,
    [GroupIndex] [INT] NOT NULL DEFAULT (0),
	[TemplateType] [INT] NOT NULL,
	[BillType] [INT] NOT NULL,
	[Module] [INT] NOT NULL,
	[OpenState] [INT] NOT NULL,
	[Must] [INT] NOT NULL,
	[ExistsData] [INT] NOT NULL,
	[ParentBillTypes] [VARCHAR](2000) NOT NULL,
    PRIMARY KEY CLUSTERED
    (
        [ID] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[M2_ProcessConfiguration_Logs](
	[ID] [INT] IDENTITY(1,1) NOT NULL,
	[PageData] [NTEXT] NOT NULL,
	[Operator] [INT] NOT NULL,
	[OperationTime] [DATETIME] NOT NULL,
    PRIMARY KEY CLUSTERED
    (
        [ID] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[PrintPages](
	[ID] [INT] IDENTITY(1,1) NOT NULL,
	[Name] [NVARCHAR](200) NOT NULL,
	[Width] [DECIMAL](25, 12) NOT NULL,
	[Height] [DECIMAL](25, 12) NOT NULL,
    PRIMARY KEY CLUSTERED
    (
        [ID] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[M2_CostWorkInProgress](
	[ID] [INT] IDENTITY(1,1) NOT NULL,
	[CostMonth] [DATETIME] NOT NULL,
	[CostType] [INT] NOT NULL,
	[InputStatus] [INT] NOT NULL,
	[Creator] [INT] NOT NULL,
	[InDate] [DATETIME] NOT NULL,
	[UpUser] [INT] NULL,
	[UpTime] [DATETIME] NULL,
    PRIMARY KEY CLUSTERED
    (
        [ID] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[M2_CostWorkInProgressList](
	[ID] [INT] IDENTITY(1,1) NOT NULL,
	[WIPID] [INT] NOT NULL,
	[OrderID] [INT] NULL,
	[WAID] [INT] NULL,
	[WorkShop] [INT] NULL,
	[ProductID] [INT] NOT NULL,
    [Unit] [INT] NOT NULL,
	[FinishedProgress] [DECIMAL](25, 12) NOT NULL,
	[Remark] [NVARCHAR](200) NULL,
    PRIMARY KEY CLUSTERED
    (
        [ID] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[M2_CostAnalysisSumResult](
	[ID]  int IDENTITY(1,1) not null,
	[CCID]  int not null default('0'),
	[MOID]  int not null default('0'),
	[MOLID]  int not null default('0'),
	[BillType]   int not null default('0'),
	[BillID]  int not null default('0'),
	[BindBillId] [int] not null	 default('0'),
	[BindFromMxId] [int] not null default('0'),
	[CostTargetId]  int not null default('0'),
	[DataType]  int not null default('0'),
	[ProductID]  int not null default('0'),
	[UnitID]  int not null default('0'),
	[RealInitNum]  decimal(25,12) not null default('0'),
	[InitNum]  decimal(25,12) not null default('0'),
	[CurrPlanNum]  decimal(25,12) not null default('0'),
	[CurrOKNum]  decimal(25,12) not null default('0'),
	[CurrOKNumByQC]  decimal(25,12) not null default('0'),
	[CurrKuinNum]  decimal(25,12) not null default('0'),
	[CurrScrapNum]  decimal(25,12) not null default('0'),
	[CurrQCScrapNum]  decimal(25,12) not null default('0'),
	[CurrStopNum]  decimal(25,12) not null default('0'),
	[CurrBillBackNum] [decimal](25,12) not null default('0'),
	[OnMakeCompleteRate] [decimal](25,12) not null default('0'),
	[OnMakeCompleteNum] [decimal](25,12) not null default('0'),
	[FinishNum]  decimal(25,12) not null default('0'),
	[RealFinishNum]  decimal(25,12) not null default('0'),
    [Money_ForMaterial]  decimal(25,12) not null default('0'),
	[Money_ForLabor]  decimal(25,12) not null default('0'),
	[Money_ForOutlay]  decimal(25,12) not null default('0'),
	[AllCostMoney]  decimal(25,12) not null default('0'),
	[AllCostPrice]  decimal(25,12) not null default('0'),
	[CurrWorkHourNum] [decimal](25,12) not null default('0'),
	[OnMakeNum] [decimal](25,12) not null default('0'),
	[NextOnMakeNum] [decimal](25,12) not null  default('0'),
    PRIMARY KEY CLUSTERED
    (
        [ID] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[M2_CostAnalysisWWSubCostList](
	[ID]  int IDENTITY(1,1) not null,
	[CurrMonth]  datetime not null,
	[CCID]  int not null  default(0),
	[WFPAID]  int not null  default(0),
	[WOutId]  int not null  default(0),
	[WOutListid]  int not null  default(0),
	[HasBFCost]  int not null  default(0),
	[InitMoney]  decimal(25,12) not null  default(0),
	[InitNum]  decimal(25,12) not null  default(0),
	[InitTotalWWMoney]  decimal(25,12) not null  default(0),
	[CurrOKNum]  decimal(25,12) not null  default(0),
	[CurrBFNum]  decimal(25,12) not null  default(0),
	[CurrMoney]  decimal(25,12) not null  default(0),
	[OutMoney]  decimal(25,12) not null  default(0),
	[CurrPrice]  decimal(25,12) not null  default(0),
	[CurrKuinNum]  decimal(25,12) not null  default(0),
	[PayShareMoney]  decimal(25,12) not null  default(0),
	[FinshMoney]  decimal(25,12) not null  default(0),
	[FinshNum]  decimal(25,12) not null  default(0),
	[BaseMoney]  decimal(25,12) not null  default(0),
	[BasePrice]  decimal(25,12) not null  default(0),
	[FinshTotalWWMoney]  decimal(25,12) not null  default(0),
	PRIMARY KEY CLUSTERED 
	(
		[WOutListid] desc,
		[CurrMonth] desc
	) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[M2_CostAnalysisSubResult](
	[ID]  int IDENTITY(1,1) not null,
	[CCID]   int not null default('0'),
	[SumResultId]  int null,
	[SubResultType]  int null,
	[DepartType]  int not null default('0'),
	[DepartID]  int not null default('0'),
	[SubMny_ForMaterial_M]  decimal(25,12) not null default('0'),
	[SubMny_ForMaterial_W]  decimal(25,12) not null default('0'),
	[SubMny_ForLabor_H]  decimal(25,12) not null default('0'),
	[SubMny_ForLabor_C]  decimal(25,12) not null default('0'),
	[SubMny_ForOutlay_W]  decimal(25,12) not null default('0'),
	[SubMny_ForOutlay_D]  decimal(25,12) not null default('0'),
	[SubMny_ForOutlay_O]  decimal(25,12) not null default('0'),
	[SubMny_AllSum]  decimal(25,12) not null default('0'),
    [UnitMny_ForMaterial]  decimal(25,12) not null default('0'),
	[UnitMny_ForLabor]  decimal(25,12) not null default('0'),
	[UnitMny_ForOutlay]  decimal(25,12) not null default('0'),
    [UnitMny_AllPrice]  decimal(25,12) not null default('0'),
    PRIMARY KEY CLUSTERED
    (
        [ID] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[M2_CostAnalysisCapacityResult](
	[ID]  int IDENTITY(1,1) not null,
	[CCID] int not null default('0'),
	[SumResultId]   int not null default('0'),
	[RangeType]   int not null default('0'),
	[DepartType]  int not null default('0'),
	[DepartID]  int not null default('0'),
	[InitNum]  decimal(25,12) not null default('0'),
	[RealInitNum]  decimal(25,12) not null default('0'),
	[CurrPlanNum]  decimal(25,12) not null default('0'),
	[CurrBillBackNum]  decimal(25,12) not null default('0'),
	[CurrOKNum]  decimal(25,12) not null default('0'),
	[CurrStopNum]  decimal(25,12) not null default('0'),
	[CurrScrapNum]  decimal(25,12) not null default('0'),
	[CurrOKNumByQC] [decimal](25,12) not null default('0'),
	[CurrCutToNum] [decimal](25,12) not null default('0'),
	[CurrQCScrapNum]  decimal(25,12) not null default('0'),
    [CurrKuinNum]  decimal(25,12) not null default('0'),
	[OnMakeCompleteRate]  decimal(25,12) not null default('0'),
	[OnMakeCompleteNum]  decimal(25,12) not null default('0'),
	[OnMakeNum]  decimal(25,12) not null default('0'),
	[NextOnMakeNum]  decimal(25,12) not null default('0'),
	[NextScrapNum] [decimal](25,12) not null  default('0'),
	[NextStopNum] [decimal](25,12) not null  default('0'),
	[NextBillBackNum] [decimal](25,12) not null  default('0'),
	[FinishNum]  decimal(25,12) not null default('0'),
	[RealFinishNum]  decimal(25,12) not null default('0'),
	[CurrWorkHourNum] [decimal](25,12) not null default('0'),
    PRIMARY KEY CLUSTERED
    (
        [ID] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[M2_CostAnalysisSurplusMaterial](
	[ID]  int IDENTITY(1,1) not null,
	[CCID]  int not null default('0'),
	[ProductID]  int not null default('0'),
	[UnitID]  int not null default('0'),
	[InitPrice]  decimal(25,12) not null default('0'),
	[InitNum]  decimal(25,12) not null default('0'),
	[InitMoney]  decimal(25,12) not null default('0'),
	[LlNum]  decimal(25,12) not null default('0'),
	[LlMoney]  decimal(25,12) not null default('0'),
	[BlNum]  decimal(25,12) not null default('0'),
	[BlMoney]  decimal(25,12) not null default('0'),
	[TlNum]  decimal(25,12) not null default('0'),
	[TlMoney]  decimal(25,12) not null default('0'),
	[FlNum]  decimal(25,12) not null default('0'),
	[FlMoney]  decimal(25,12) not null default('0'),
	[RegNum]  decimal(25,12) not null default('0'),
	[RegMoney]  decimal(25,12) not null default('0'),
	[RegNum_HC]  decimal(25,12) not null default('0'),
	[RegMoney_HC]  decimal(25,12) not null default('0'),
	[VncNum]  decimal(25,12) not null default('0'),
	[VncMoney]  decimal(25,12) not null default('0'),
	[FinishPrice]  decimal(25,12) not null default('0'),
	[FinishNum]  decimal(25,12) not null default('0'),
	[FinishMoney]  decimal(25,12) not null default('0'),
    PRIMARY KEY CLUSTERED
    (
        [ID] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[M2_CostAnalysisKuinResult](
	[ID]  int IDENTITY(1,1) not null,
	[CCID]  int null,
	[SumResultId]  int null,
	[KuinListId]  int not null default('0'),
	[BillId] [int] not null	 default('0'),
	[CostTargetId] [int] not null default('0'),
	[BillType] [int] null default('0'),
	[BindBillId] [int] not null	 default('0'),
	[AllKuinNum] [decimal](25,12) not null	default('0'),
	[Num]  decimal(25,12) not null default('0'),
	[CostMoney]  decimal(25,12) not null default('0'),
	[Kuin_Material_M] [decimal](25,12) not null default('0'),
	[Kuin_Material_W] [decimal](25,12) not null default('0'),
	[Kuin_Labor_H] [decimal](25,12) not null default('0'),
	[Kuin_Labor_C] [decimal](25,12) not null default('0'),
	[Kuin_Outlay_W] [decimal](25,12) not null default('0'),
	[Kuin_Outlay_D] [decimal](25,12) not null	default('0'),
	[Kuin_Outlay_O] [decimal](25,12) not null	default('0'),
    PRIMARY KEY CLUSTERED
    (
        [ID] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[M2_CostAnalysisRecoveryRelation](
	[ID]  int IDENTITY(1,1) not null,
	[CCID]  int null,
	[BillId] [int] not null  default('0'),
	[BillType] [int] not null  default('0'),
	[CostTargetId] [int] not null  default('0'),
	[SumResultId]  int null  default('0'),
	[ProductID]  int not null default('0'),
	[UnitID]  int not null default('0'),
	[KuinResultId]  int not null default('0'),
	[KuinNum]  decimal(25,12) not null default('0'),
	[CurrNum]  decimal(25,12) not null default('0'),
	[KuoutListID]  int not null default('0'),
	[KuoutNum]  decimal(25,12) not null default('0'),
	[CostLogId]  int null,
	[KuoutCostLogItemID]  int null,
	[KuinListID]  int not null default('0'),
	[FromResultId]  int null,
	[KuinListIDLog] [int]  null	,
	[KuoutJoinRootKuinListId] [int]  null,
    PRIMARY KEY CLUSTERED
    (
        [ID] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[M2_CostAnalysisBusinessResult](
	[ID]  int IDENTITY(1,1) not null,
	[CCID]  int null,
	[SumResultId]  int null,
	[BillId]  int null,
    [BillType]   int not null default('0'),
	[CostTargetId]  int not null default('0'),
    [DepartType]  int not null default('0'),
	[DepartID]  int not null default('0'),
    [EntityRoomType]  int not null default('0'),
	[EntityRoomID]  int not null default('0'),
	[ProductID]  int not null default('0'),
	[UnitID]  int not null default('0'),
	[MOID] [int] not null default('0'),
	[MOLID] [int] not null default('0'),
	[DataType] [int] not null default('0'),
	[BomListId] [int] not null default('0'),
	[BindBillId] [int] not null default('0'),
	[BindFromMxId] [int] not null default('0'),
	[ProcIndex] [int] not null default('0'),
	[WpfNodeType] [int] null default('0'),
	[WpfNodeId] [int] not null default('0'),
	[WpfBaseNodeId] [int] not null default('0'),
	[IsNoLimit] [bit] not null default(0),
	[ConversionBL]  decimal(25,12) not null  default(1),
	[FinshNewPlanNum]  decimal(25,12) not null  default(0),
	[FinshNewBillBackNum]  decimal(25,12) not null  default(0),
	[FinshNewOKNum]  decimal(25,12) not null  default(0),
	[FinshNewScrapNum]  decimal(25,12) not null  default(0),
	[FinshNewStopNum]  decimal(25,12) not null  default(0),
	[FinshNewRoundingStopNum]  decimal(25,12) not null  default(0),
	[FinshNewSyNum]  decimal(25,12) not null  default(0),
	[FinshNewKuinNum]  decimal(25,12) not null  default(0),
	[FinshNewScrapKuinNum] decimal(25,12) not null  default(0),
	[wfpqc_FinshNewBillBackNum]  decimal(25,12) not null  default(0),
	[wfpqc_FinshNewOKNum]  decimal(25,12) not null  default(0),
	[wfpqc_FinshNewScrapNum]  decimal(25,12) not null  default(0),
	[wfpqc_FinshNewStopNum]  decimal(25,12) not null  default(0),
	[backadd_FinshNewScrapNum]  decimal(25,12) not null  default(0),
	[backadd_FinshNewStopNum]  decimal(25,12) not null  default(0),
	[OnMakeNum] [decimal](25,12) not null default(0),
	[RealInitNum]  decimal(25,12) not null default('0'),
    [InitNum]  decimal(25,12) not null default('0'),
    [InitMoney]  decimal(25,12) not null default('0'),
	[CurrPlanNum]  decimal(25,12) not null default('0'),
	[CurrBillBackNum]  decimal(25,12) not null default('0'),
	[OnMakeCompleteRate]  decimal(25,12) not null default('0'),
	[OnMakeCompleteNum]  decimal(25,12) not null default('0'),
	[NextOnMakeNum]  decimal(25,12) not null default('0'),
	[NextScrapNum] [decimal](25,12) not null  default('0'),
	[NextStopNum] [decimal](25,12) not null  default('0'),
	[NextBillBackNum] [decimal](25,12) not null  default('0'),
	[CurrOKNum]  decimal(25,12) not null default('0'),
	[CurrStopNum]  decimal(25,12) not null default('0'),
	[CurrScrapNum]  decimal(25,12) not null default('0'),
	[CurrQCScrapNum]  decimal(25,12) not null default('0'),
    [CurrKuinNum]  decimal(25,12) not null default('0'),
	[FinishNum]  decimal(25,12) not null default('0'),
	[RealFinishNum]  decimal(25,12) not null default('0'),
	[FinishMoney]  decimal(25,12) not null default('0'),
	[CurrWorkHourNum] [decimal](25,12) not null default('0'),
	[InputCost_Material_M] [decimal](25,12) not null default('0'),
	[InputCost_Material_W] [decimal](25,12) not null default('0'),
	[InputCost_Labor_C] [decimal](25,12) not null default('0'),
	[InputCost_Labor_H] [decimal](25,12) not null default('0'),
	[InputCost_Outlay_W] [decimal](25,12) not null default('0'),
	[InputCost_Outlay_D] [decimal](25,12) not null default('0'),
	[InputCost_Outlay_O] [decimal](25,12) not null default('0'),
	[OutCost_Material_M] [decimal](25,12) not null default('0'),
	[OutCost_Material_W] [decimal](25,12) not null default('0'),
	[OutCost_Labor_C] [decimal](25,12) not null default('0'),
	[OutCost_Labor_H] [decimal](25,12) not null default('0'),
	[OutCost_Outlay_W] [decimal](25,12) not null default('0'),
	[OutCost_Outlay_D] [decimal](25,12) not null default('0'),
	[OutCost_Outlay_O] [decimal](25,12) not null default('0'),
	[FinishCost_Material_M] [decimal](25,12) not null default('0'),
	[FinishCost_Material_W] [decimal](25,12) not null default('0'),
	[FinishCost_Labor_C] [decimal](25,12) not null default('0'),
	[FinishCost_Labor_H] [decimal](25,12) not null default('0'),
	[FinishCost_Outlay_W] [decimal](25,12) not null default('0'),
	[FinishCost_Outlay_D] [decimal](25,12) not null default('0'),
	[FinishCost_Outlay_O] [decimal](25,12) not null default('0'),
	[M_llCostNum] [decimal](25,12) not null default('0'),
	[M_BlCostNum] [decimal](25,12) not null default('0'),
	[M_TlCostNum] [decimal](25,12) not null default('0'),
	[M_FlCostNum] [decimal](25,12) not null default('0'),
	[M_VncCostNum] [decimal](25,12) not null default('0'),
    PRIMARY KEY CLUSTERED
    (
        [ID] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[ProvisionalStruct](
    [ID]  int IDENTITY(1,1) not null,
	[ord]  	int null,
	[kuinlistID]  int null,
	[KuinId]  int null,
	[Num1] decimal(25,12) null,
	[Money1] decimal(25,12) null,
	[chgNum] decimal(25,12) null,
	[oldPrice] decimal(25,12) null,
	[oldMoney] 	decimal(25,12) null,
	[newPrice] 	decimal(25,12) null,
	[newMoney] 	decimal(25,12) null,
    [CostMoney]	 decimal(25,12) null,
	[MCID] int null,
	[PayoutInvListid]  int null,
	[Caigoulist]   int null,
	[inx] 	 int null,
	[type]  	 int null,
	[InvoiceVector] Int null,
	[DeductChgListId]  int null, 
	[KuinType]   int null,
	[Intro]  	 [nvarchar](500) NULL,
	[ShareStatus] int null,
    [creator] [int] NULL,
	[indate] [datetime] NULL,
    PRIMARY KEY CLUSTERED
    (
        [ID] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[ProductPriceMode_Log](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[productid] [int] NOT NULL,
	[oldpricemode] [int] NOT NULL,
	[newpricemode] [int] NOT NULL,
	[modifytime] [datetime] NULL,
	[modifyuser] [int] NOT NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[home_leftmenu_user_hobby](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[userid] [int] NOT NULL,
	[menuid] [int] NOT NULL,
	[number] [int] NOT NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[DocSortsAndSharingRelation](
	[id] [int] IDENTITY(1,1) NOT NULL,
    [sortonehyId] [int] NULL,
	[share1] [text] NULL,
	[share2] [text] NULL,
	[updatetime] [datetime] NULL,
    [postView] [varchar](4000) NULL,
	[postDown] [varchar](4000) NULL,
    PRIMARY KEY CLUSTERED
    (
        [id] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

--Attrs:帐套下可用
CREATE TABLE [dbo].[erp_sys_updatesign](
	[SignName] [varchar](100) NOT NULL,
	[SignValue] [nvarchar](100) NULL,
	[SignTime] [datetime] NULL,
	PRIMARY KEY CLUSTERED
	(
		[SignName] ASC
	)
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[Mobile_ManuPlanListsPre](
	[ID] [INT] IDENTITY(1,1) NOT NULL,
	[MPSID] [INT] NULL,
	[ProductID] [INT] NULL,
	[unit] [INT] NULL,
	[NumPlan] [decimal](25, 12) NULL,
	[DateDelivery] [DATETIME] NULL,
	[intro] [NTEXT] NULL,
    [Addcate] [INT] NULL,
	[del] [INT] NULL,
	[CreateFrom] [INT] NULL,
	[FromID] [INT] NULL,
	[commUnitAttr] [NVARCHAR](200) NULL,
	[rowindex] [INT] NULL,
    [ManuPlanStatus] [int] NOT NULL DEFAULT ((0)),
    [ManuPlanListsPreID] [INT] NULL
 PRIMARY KEY CLUSTERED ([ID] ASC) ON [PRIMARY]
)

GO

CREATE TABLE [dbo].[qxtemplatepower](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[qx_open] [int] NULL,
	[qx_intro] [ntext] NOT NULL DEFAULT(''),
	[TemplateId] [int] NULL,
	[sort1] [int] NULL,
	[sort2] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE TABLE [dbo].[QxTemplate](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](200) NULL,
	[gate1] [int] NULL,
	[addcate] [int] NULL,
    [adddate] [datetime] NULL,
    [modifycate] [int] NULL,
    [modifydate] [datetime] NULL,
	[del] [int] NULL,
	[delcate] [int] NULL,
	[deldate] [datetime] NULL
PRIMARY KEY CLUSTERED ([ID] ASC) ON [PRIMARY]
) 

GO
CREATE TABLE [dbo].[QxTemplateApplyRecord](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TemplateId] [int] NULL,
	[Bindcate] [int] NULL,
	[addcate] [int] NULL,
    [adddate] [datetime] NULL
   
PRIMARY KEY CLUSTERED ([ID] ASC) ON [PRIMARY]
) 

GO
CREATE TABLE [dbo].[Orgs_Post](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[OrgID] [int] NULL,
	[PostID] [int] NULL

PRIMARY KEY CLUSTERED ([ID] ASC) ON [PRIMARY]
) 
GO

CREATE TABLE [dbo].[f_VoucherSearchList](
	[Id] [INT] IDENTITY(1,1) NOT NULL,
	[CateId] [INT] NULL,
	[Ord] [INT] NULL,
	[InDate] [DATETIME] NULL,
    PRIMARY KEY CLUSTERED
	(
		[Id] ASC
	) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[f_AssistCount](
    [ID] [INT] IDENTITY(1,1) NOT NULL,
	[SetCount] [INT] NOT NULL,
	[UpUser] [INT] NULL,
	[UpTime] [DATETIME] NULL,
    PRIMARY KEY CLUSTERED
    (
        [ID] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[f_accumuInitNums](
	[ID] [INT] IDENTITY(1,1) NOT NULL,
	[date1] [DATETIME] NOT NULL,
	[AccountSubject] [INT] NOT NULL,
	[balanceDirection] [INT] NOT NULL,
	[AssistSubject] [INT] NULL,
	[AssistID] [INT] NULL,
    [Unit] [INT] NULL,
	[Nums] [DECIMAL](25, 12) NOT NULL,
	[bz] [INT] NOT NULL,
    [GroupID] [INT] NOT NULL default(0),
	[UpUser] [INT] NULL,
	[UpTime] [DATETIME] NULL,
    PRIMARY KEY CLUSTERED
    (
        [ID] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[MCostLogForKuBalance](
	[Id]  int IDENTITY(1,1) not null,
	[Costid]  int not null  default(0),
	[Date1]  datetime not null,
	[Kuid]  int not null  default(0),
	[ProductId]  int not null  default(0),
	[Unit]  int not null  default(0),
	[StoreId]  int not null  default(0),
	[InitNum]  decimal(25,12) not null  default(0),
	[InitWayNum]  decimal(25,12) not null  default(0),
	[InitMoney]  decimal(25,12) not null  default(0),
	[InitWayMoney]  decimal(25,12) not null  default(0),
	[KuinNum]  decimal(25,12) not null  default(0),
	[KuinMoney]  decimal(25,12) not null  default(0),
	[KuoutNum]  decimal(25,12) not null  default(0),
	[KuoutMoney]  decimal(25,12) not null  default(0),
	[WayInNum]  decimal(25,12) not null  default(0),
	[WayInMoney]  decimal(25,12) not null  default(0),
	[WayOutNum]  decimal(25,12) not null  default(0),
	[WayOutMoney]  decimal(25,12) not null  default(0),
	[FinshNum]  decimal(25,12) not null  default(0),
	[FinshMoney]  decimal(25,12) not null  default(0),
	[FinshWayNum]  decimal(25,12) not null  default(0),
	[FinshWayMoney]  decimal(25,12) not null  default(0),
	[CostType]  int not null  default(0),
	[IsLocked]  bit not null  default(0),
	[IsRevised]  bit not null  default(0),
	[RevisedRemark]  [NVARCHAR](500) NULL,
    PRIMARY KEY CLUSTERED
	(
		[Date1] desc,
		[Kuid] desc
	) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[f_accumuAssistListRelation](
	[ID] [INT] IDENTITY(1,1) NOT NULL,
	[PID] [INT] NOT NULL,
	[relationID] [INT] NOT NULL,
	[AssistSubject] [INT] NOT NULL,
	[AssistID] [INT] NOT NULL,
    [nums] [DECIMAL](25, 12) NOT NULL default(0),
	[Money_y] [DECIMAL](25, 12) NOT NULL,
	[Money_b] [DECIMAL](25, 12) NOT NULL,
	[index1] [INT] NOT NULL,
	[Unit] [INT] NULL,
    PRIMARY KEY CLUSTERED
    (
        [ID] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[TaxClassifyCodes](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[P] [int] NOT NULL,
	[L] [int] NOT NULL,
	[Z] [int] NOT NULL,
	[J] [int] NOT NULL,
	[T] [int] NOT NULL,
	[K] [int] NOT NULL,
	[X] [int] NOT NULL,
	[M] [int] NOT NULL,
	[ZM] [int] NOT NULL,
	[XM] [int] NOT NULL,
	[MergeCoding] [nvarchar](20) NOT NULL,
	[GoodsName] [nvarchar](200) NOT NULL,
	[ClassifyShorterForm] [nvarchar](50) NOT NULL,
	[Explain] [nvarchar](max) NULL,
	[TaxRate] [nvarchar](20) NULL,
	[SpecialManagement] [nvarchar](200) NULL,
	[PolicyBasis] [nvarchar](500) NULL,
	[SpecialContentCode] [nvarchar](100) NULL,
	[ExciseTax] [nvarchar](50) NULL,
	[ExciseTaxPolicyBasis] [nvarchar](200) NULL,
	[ExciseTaxCode] [nvarchar](200) NULL,
	[KeyWord] [nvarchar](max) NULL,
	[SummaryItem] [nvarchar](10) NULL,
	[BureauOfStatisticsCode] [nvarchar](800) NULL,
	[ImportAndExportItems] [nvarchar](max) NULL,
	[EnableTime] [datetime] NULL,
	[DeadlineOfTransitionPeriod] [datetime] NULL,
	[Version] [varchar](20) NOT NULL,
	[UpTime] [datetime] NULL,
    PRIMARY KEY CLUSTERED
    (
        [ID] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[InvoiceConfigInfo](
	[ID] [INT] IDENTITY(1,1) NOT NULL,
	[DeviceName] [NVARCHAR](100) NOT NULL,
	[DeviceNumber] [NVARCHAR](100) NOT NULL,
	[EnterpriseName] [NVARCHAR](100) NOT NULL,
	[EnterpriseTaxNumber] [VARCHAR](50) NOT NULL,
	[BankAndAccount] [NVARCHAR](100) NULL,
	[AddressAndPhone] [NVARCHAR](100) NULL,
	[InfoInvoicer] [NVARCHAR](50) NULL,
	[InfoCashier] [NVARCHAR](50) NULL,
	[InfoChecker] [NVARCHAR](50) NULL,
	[InvoicedType] [VARCHAR](50) NULL,
	[CanExportTaxRebate] [INT] NOT NULL,
	[EquipmentType] [INT] NULL,
	[EquipmentNumber] [VARCHAR](50) NULL,
	[MachineNumber] [INT] NULL,
	[EnableStatus] [INT] NOT NULL,
	[Creator] [INT] NOT NULL,
	[Indate] [DATETIME] NOT NULL,
	[UpUser] [INT] NULL,
	[UpTime] [DATETIME] NULL,
    PRIMARY KEY CLUSTERED
    (
        [ID] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[PaybackInvoiceDeliver](
	[ID] [INT] IDENTITY(1,1) NOT NULL,
	[InvoiceSureId] [INT] NOT NULL,
	[Email] [VARCHAR](50) NULL,
	[EmailStatus] [INT] NULL,
	[MobilePhone] [VARCHAR](20) NULL,
	[MobilePhoneStatus] [INT] NULL,
	[Operator] [INT] NOT NULL,
	[OperationTime] [DATETIME] NOT NULL,
    PRIMARY KEY CLUSTERED
    (
        [ID] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[RedInvoiceInformation](
	[ID] [INT] IDENTITY(1,1) NOT NULL,
	[InvoiceSureId] [INT] NOT NULL,
	[Title] [NVARCHAR](100) NOT NULL,
	[BH] [VARCHAR](50) NOT NULL,
	[NoticeBH] [VARCHAR](50) NULL,
	[SubmissionStatus] [INT] NULL,
	[UpUser] [INT] NOT NULL,
	[UpTime] [DATETIME] NOT NULL,
    PRIMARY KEY CLUSTERED
    (
        [ID] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[InvoiceInformation](
	[ID] [INT] IDENTITY(1,1) NOT NULL,
	[InfoKind] [INT] NOT NULL,
	[MajorInvoiceType] [INT] NULL,
	[InfoTypeCode] [VARCHAR](12) NOT NULL,
	[InfoNumber] [INT] NOT NULL,
	[LZFPDM] [VARCHAR](12) NULL,
	[LZFPHM] [INT] NULL,
	[HZXXBBH] [VARCHAR](20) NULL,
	[InfoDate] [DATETIME] NOT NULL,
	[MachineNumber] [VARCHAR](5) NOT NULL,
	[CancelDate] [DATETIME] NOT NULL,
	[RestoreFlag] [INT] NOT NULL,
	[SalesTaxFlag] [VARCHAR](50) NOT NULL,
	[InfoBillNumber] [VARCHAR](20) NULL,
	[InfoAmount] [DECIMAL](25, 12) NOT NULL,
	[InfoTaxAmount] [DECIMAL](25, 12) NOT NULL,
	[InfoTaxRate] [DECIMAL](25, 12) NOT NULL,
	[InfoPrintFlag] [INT] NOT NULL,
	[UploadFlag] [INT] NOT NULL,
	[CancelFlag] [INT] NOT NULL,
	[InfoClientName] [NVARCHAR](100) NOT NULL,
	[InfoClientTaxCode] [NVARCHAR](20) NULL,
	[InfoClientAddressPhone] [NVARCHAR](100) NULL,
	[InfoClientBankAccoun] [NVARCHAR](100) NULL,
	[SellerName] [NVARCHAR](100) NOT NULL,
	[SellerTaxCode] [VARCHAR](20) NOT NULL,
	[SellerAddressPhone] [NVARCHAR](100) NULL,
	[SellerBankAccount] [NVARCHAR](100) NULL,
	[InvoiceMemo] [NVARCHAR](300) NULL,
	[InfoInvoicer] [NVARCHAR](10) NOT NULL,
	[InfoCashier] [NVARCHAR](10) NULL,
	[InfoChecker] [NVARCHAR](10) NULL,
	[InvoiceOrderNumber] [VARCHAR](10) NOT NULL,
	[AddressIndexNumber] [VARCHAR](10) NULL,
	[GoodsListFlag] [INT] NOT NULL,
	[GoodsNoVer] [NVARCHAR](20) NOT NULL,
	[UpUser] [INT] NOT NULL,
	[UpTime] [DATETIME] NOT NULL,
    PRIMARY KEY CLUSTERED
    (
        [ID] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[InvoiceInformationDetail](
	[ID] [INT] IDENTITY(1,1) NOT NULL,
	[InfoID] [INT] NOT NULL,
	[CommodityCode] [VARCHAR](50) NOT NULL,
	[InvoiceDetailNumber] [VARCHAR](10) NOT NULL,
	[ListGoodsName] [NVARCHAR](100) NOT NULL,
	[ListStandard] [NVARCHAR](30) NULL,
	[ListUnit] [NVARCHAR](16) NULL,
	[ListNumber] [DECIMAL](25, 12) NOT NULL,
	[ListPrice] [DECIMAL](25, 12) NOT NULL,
	[ListPriceKind] [INT] NOT NULL,
	[LineType] [INT] NOT NULL,
	[ListAmount] [DECIMAL](25, 12) NOT NULL,
	[ListTaxRate] [DECIMAL](25, 12) NOT NULL,
	[ListTaxAmount] [DECIMAL](25, 12) NOT NULL,
	[GoodsTaxNo] [NVARCHAR](20) NOT NULL,
	[ZeroTax] [VARCHAR](10) NULL,
	[TaxPre] [VARCHAR](10) NOT NULL,
	[TaxPreCon] [NVARCHAR](MAX) NULL,
    PRIMARY KEY CLUSTERED
    (
        [ID] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[M2_Material_CStockNum](
	[ID] [int] IDENTITY(1,1) NOT NULL,  --标识列
	[ProductID] [INT] NULL,  --产品列
	[Num1] [decimal](25, 12) NULL,	 --增加可用库存列
    [Unit] [INT] NULL,  --单位
	[creator] [int] NULL  --当前人员列
)

GO

CREATE TABLE [dbo].[InvoiceInterfaceLog](
	[ID] [INT] IDENTITY(1,1) NOT NULL,
	[BillID] [VARCHAR](500) NOT NULL,
	[InterfaceCode] [NVARCHAR](50) NOT NULL,
	[InputData] [NTEXT] NOT NULL,
	[OutputData] [NTEXT] NOT NULL,
	[Creater] [INT] NOT NULL,
	[Indate] [DATETIME] NOT NULL,
    PRIMARY KEY CLUSTERED
    (
        [ID] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]
 

GO

CREATE TABLE [dbo].[AlarmSetting](
	[ID] [INT] IDENTITY(1,1) NOT NULL,
    [Uid] [int] Not NULL default(0),
	[ord] [int] Not NULL,
	[TargetName] [nvarchar](50) NULL,
    [TargetValue] [decimal](25, 12) NULL,
	[UnitBase] [int] NULL,
	[UnitName] [nvarchar](20) NULL,
    [LongUnitName] [nvarchar](20) NULL,
    [UpperValue] [decimal](25, 12) NULL,
	[UpperTip] [nvarchar](40) NULL,
	[LowerValue] [decimal](25, 12) NULL,
	[LowerTip] [nvarchar](40) NULL,
	[Gate] [int] NULL,
    PRIMARY KEY CLUSTERED
    (
        [ID] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]
 

GO

CREATE TABLE [dbo].[Wageslist_Importdata](
	[ID] [INT] IDENTITY(1,1) NOT NULL,
	[PostData] [NTEXT] NOT NULL,
	[Addcate] [INT] NOT NULL,
	[Addtime] [DATETIME] NOT NULL,
    PRIMARY KEY CLUSTERED
    (
        [ID] ASC   --by tam
    ) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[O_AssetHistory](
 [id] [int] IDENTITY(1,1) NOT NULL,
 [ass_id] [int] NULL,
 [ass_name] [varchar](400) NULL,
 [ass_xh] [varchar](400) NULL,
 [ass_bh] [varchar](400) NULL,
 [ass_type] [int] NULL,
 [ass_cartype] [int] NULL,
 [ass_state] [int] NULL,
 [ass_jczl] [decimal](25, 12) NULL,
 [ass_jcz] [decimal](25, 12) NULL,
 [ass_jttime] [datetime] NULL,
 [ass_isjt] [int] NULL,
 [ass_cycle] [int] NULL,
 [ass_cycle1] [int] NULL,
 [ass_ycycle] [int] NULL,
 [ass_method] [int] NULL,
 [ass_pj] [varchar](4000) NULL,
 [ass_cateid] [int] NULL,
 [ass_time] [datetime] NULL,
 [ass_money] [decimal](25, 12) NULL,
 [ass_money2] [decimal](25, 12) NULL,
 [ass_using] [datetime] NULL,
 [ass_lycateid] [varchar](4000) NULL,
 [ass_lytime] [datetime] NULL,
 [ass_position] [varchar](400) NULL,
 [ass_note] [ntext] NULL,
 [ModifyStamp] [varchar](4000) NULL DEFAULT ('1'),
 [updatecateid] [int] NULL,
 [updatetime] [datetime] NULL,
PRIMARY KEY CLUSTERED
(
 [id] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

CREATE TABLE [dbo].[M2_CostAnalysisCostMovedLog](
	[ID]  int IDENTITY(1,1) not null,
	[FromBillType]  int null,
	[FromTargetId]  int not null  default(0),
	[FromWpfNodeType]  int null,
	[FromWpfNodeId]  int not null  default(0),
	[ToBillType]  int null,
	[ToTargetId]  int not null  default(0),
	[ToWpfNodeType]  int null,
	[ToWpfNodeId]  int not null  default(0),
	[MoveType]  int null,
	[CostMoney]  decimal(25,12) not null  default(0),
	[SyMoney]  decimal(25,12) not null  default(0),
	[Completed]  int not null  default(0),
	[CCID]  int not null  default(0),
	[CurrMonth]  datetime not null,
	[PreMonthId] int not null  default(0),
	[JoinCostLogId] int not null  default(0),
	PRIMARY KEY CLUSTERED
	(
		[id] ASC
	) ON [PRIMARY]
) ON [PRIMARY]
--@##mode:index;clustered:false;fields:Completed,CurrMonth