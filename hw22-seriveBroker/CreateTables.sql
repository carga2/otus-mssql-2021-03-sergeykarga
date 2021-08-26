USE [Purposes]
GO
/****** Object:  Table [dbo].[Processes]    Script Date: 26.08.2021 18:01:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Processes](
	[id] [int] NOT NULL,
	[Object] [int] NULL,
	[Rating] [int] NOT NULL,
	[Process] [nvarchar](20) NULL,
	[DateTime] [datetime] NULL,
 CONSTRAINT [PK_Processes] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TargetProcesses]    Script Date: 26.08.2021 18:01:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TargetProcesses](
	[id] [int] NOT NULL,
	[Object] [int] NULL,
 CONSTRAINT [PK_TargetProcesses] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
INSERT [dbo].[Processes] ([id], [Object], [Rating], [Process], [DateTime]) VALUES (1, 1, 1, NULL, NULL)
GO
INSERT [dbo].[Processes] ([id], [Object], [Rating], [Process], [DateTime]) VALUES (2, 3, 2, NULL, NULL)
GO
INSERT [dbo].[Processes] ([id], [Object], [Rating], [Process], [DateTime]) VALUES (3, NULL, 3, NULL, NULL)
GO
INSERT [dbo].[Processes] ([id], [Object], [Rating], [Process], [DateTime]) VALUES (4, 4, 4, NULL, NULL)
GO
INSERT [dbo].[Processes] ([id], [Object], [Rating], [Process], [DateTime]) VALUES (5, 2, 5, NULL, NULL)
GO
INSERT [dbo].[TargetProcesses] ([id], [Object]) VALUES (1, NULL)
GO
INSERT [dbo].[TargetProcesses] ([id], [Object]) VALUES (2, 2)
GO
INSERT [dbo].[TargetProcesses] ([id], [Object]) VALUES (3, 3)
GO
INSERT [dbo].[TargetProcesses] ([id], [Object]) VALUES (4, 5)
GO
INSERT [dbo].[TargetProcesses] ([id], [Object]) VALUES (5, 2)
GO
