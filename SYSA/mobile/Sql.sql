
CREATE TABLE [dbo].[Mob_MacLoginState](
	[macsn] [varchar](50) NOT NULL,
	[failcount] [int] NOT NULL,
	[rndcode] [varchar](50) NOT NULL,
 CONSTRAINT [PK_Mob_MacLoginState] PRIMARY KEY CLUSTERED 
(
	[macsn] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[Mob_UserMacMap](
	[macsn] [varchar](50) NOT NULL,
	[phone] [varchar](50) NOT NULL,
	[btype] [int] not null,
	[userid] [int] NOT NULL,
	[id] [int] IDENTITY(1,1) NOT NULL,
	[del] [int] NOT NULL
) ON [PRIMARY]