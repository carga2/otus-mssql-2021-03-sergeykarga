/*База данных*/
CREATE DATABASE [Purposes]
go

/*Таблица Целей*/
CREATE TABLE [SqlGraph].[Purposes](
	[PurposeID] [bigint] IDENTITY(1,1) NOT NULL,
	[UserID] [bigint] NOT NULL,
	[Priority] [tinyint] NOT NULL,
	[MasterObjectID] [int] NOT NULL,
	[ActionID] [int] NOT NULL,
	[SlaveObjectID] [int] NOT NULL,
	[StatusID] [tinyint] NOT NULL,
 CONSTRAINT [PK_Purposes] PRIMARY KEY CLUSTERED 
(
	[PurposeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
)
AS NODE ON [PRIMARY]
GO

ALTER TABLE [SqlGraph].[Purposes]  WITH CHECK ADD  CONSTRAINT [FK_Purposes_actions] FOREIGN KEY([ActionID])
REFERENCES [SqlGraph].[actions] ([ActionID])
GO

ALTER TABLE [SqlGraph].[Purposes] CHECK CONSTRAINT [FK_Purposes_actions]
GO

ALTER TABLE [SqlGraph].[Purposes]  WITH CHECK ADD  CONSTRAINT [FK_Purposes_PurposesObjects_M] FOREIGN KEY([MasterObjectID])
REFERENCES [SqlGraph].[PurposesObjects] ([ObjectID])
GO

ALTER TABLE [SqlGraph].[Purposes] CHECK CONSTRAINT [FK_Purposes_PurposesObjects_M]
GO

ALTER TABLE [SqlGraph].[Purposes]  WITH CHECK ADD  CONSTRAINT [FK_Purposes_PurposesObjects_S] FOREIGN KEY([SlaveObjectID])
REFERENCES [SqlGraph].[PurposesObjects] ([ObjectID])
GO

ALTER TABLE [SqlGraph].[Purposes] CHECK CONSTRAINT [FK_Purposes_PurposesObjects_S]
GO

ALTER TABLE [SqlGraph].[Purposes]  WITH CHECK ADD  CONSTRAINT [FK_Purposes_PurposeStatuses] FOREIGN KEY([StatusID])
REFERENCES [dbo].[PurposeStatuses] ([StatusID])
GO

ALTER TABLE [SqlGraph].[Purposes] CHECK CONSTRAINT [FK_Purposes_PurposeStatuses]
GO

ALTER TABLE [SqlGraph].[Purposes]  WITH CHECK ADD  CONSTRAINT [FK_Purposes_UsersLogins] FOREIGN KEY([UserID])
REFERENCES [dbo].[UsersLogins] ([UserID])
GO

ALTER TABLE [SqlGraph].[Purposes] CHECK CONSTRAINT [FK_Purposes_UsersLogins]
GO

/*Таблица связей Цель - Решение*/
CREATE TABLE [SqlGraph].[purposes_solutions](
	[CreationDate] [datetime2](7) NOT NULL,
	[Strength] [tinyint] NOT NULL
)
AS EDGE ON [PRIMARY]
GO

ALTER TABLE [SqlGraph].[purposes_solutions] ADD  DEFAULT (sysdatetime()) FOR [CreationDate]
GO

ALTER TABLE [SqlGraph].[purposes_solutions] ADD  DEFAULT ((100)) FOR [Strength]
GO

ALTER TABLE [SqlGraph].[purposes_solutions]  WITH CHECK ADD CHECK  (([Strength]<(100)))
GO

/*Таблица Решений*/
CREATE TABLE [SqlGraph].[Solutions](
	[SolutionID] [bigint] IDENTITY(1,1) NOT NULL,
	[CreatedBy] [bigint] NOT NULL,
	[Rating] [int] NOT NULL,
 CONSTRAINT [PK_Solutions] PRIMARY KEY CLUSTERED 
(
	[SolutionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
)
AS NODE ON [PRIMARY]
GO

ALTER TABLE [SqlGraph].[Solutions]  WITH CHECK ADD  CONSTRAINT [FK_Solutions_UsersLogins] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[UsersLogins] ([UserID])
GO

ALTER TABLE [SqlGraph].[Solutions] CHECK CONSTRAINT [FK_Solutions_UsersLogins]
GO

/*Таблица Пользователей*/
CREATE TABLE [dbo].[UsersLogins](
	[UserID] [bigint] IDENTITY(1,1) NOT NULL,
	[FullName] [nvarchar](100) NOT NULL,
	[LogonName] [nvarchar](100) NOT NULL,
	[HashedPassword] [varbinary](max) NOT NULL,
	[LastLogon] [datetime2](7) NOT NULL,
	[CreationDate] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_UsersLogins] PRIMARY KEY CLUSTERED 
(
	[UserID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IX_UsersLogins_FullName] ON [dbo].[UsersLogins]
(
	[FullName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
