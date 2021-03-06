USE [master]
GO
/****** Object:  Database [IdentifyCategory]    Script Date: 25/01/2021 09:22:09 ******/
CREATE DATABASE [IdentifyCategory]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'IdentifyCategory', FILENAME = N'D:\SQL2019\MSSQL15.MSSQLSERVER\MSSQL\DATA\IdentifyCategory.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'IdentifyCategory_log', FILENAME = N'D:\SQL2019\MSSQL15.MSSQLSERVER\MSSQL\DATA\IdentifyCategory_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT
GO
ALTER DATABASE [IdentifyCategory] SET COMPATIBILITY_LEVEL = 150
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [IdentifyCategory].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [IdentifyCategory] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [IdentifyCategory] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [IdentifyCategory] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [IdentifyCategory] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [IdentifyCategory] SET ARITHABORT OFF 
GO
ALTER DATABASE [IdentifyCategory] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [IdentifyCategory] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [IdentifyCategory] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [IdentifyCategory] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [IdentifyCategory] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [IdentifyCategory] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [IdentifyCategory] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [IdentifyCategory] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [IdentifyCategory] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [IdentifyCategory] SET  DISABLE_BROKER 
GO
ALTER DATABASE [IdentifyCategory] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [IdentifyCategory] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [IdentifyCategory] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [IdentifyCategory] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [IdentifyCategory] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [IdentifyCategory] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [IdentifyCategory] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [IdentifyCategory] SET RECOVERY FULL 
GO
ALTER DATABASE [IdentifyCategory] SET  MULTI_USER 
GO
ALTER DATABASE [IdentifyCategory] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [IdentifyCategory] SET DB_CHAINING OFF 
GO
ALTER DATABASE [IdentifyCategory] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [IdentifyCategory] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [IdentifyCategory] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [IdentifyCategory] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
EXEC sys.sp_db_vardecimal_storage_format N'IdentifyCategory', N'ON'
GO
ALTER DATABASE [IdentifyCategory] SET QUERY_STORE = OFF
GO
USE [IdentifyCategory]
GO
/****** Object:  Table [dbo].[CategoryRules]    Script Date: 25/01/2021 09:22:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CategoryRules](
	[IdRule] [int] IDENTITY(1,1) NOT NULL,
	[CategoryName] [nchar](100) NOT NULL,
	[Client] [nchar](40) NOT NULL,
	[Value] [float] NOT NULL,
	[Conditional] [bit] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Trade]    Script Date: 25/01/2021 09:22:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Trade](
	[IdTrade] [int] IDENTITY(1,1) NOT NULL,
	[Value] [float] NOT NULL,
	[ClientSector] [nchar](40) NOT NULL,
	[Risk] [nchar](40) NULL
) ON [PRIMARY]
GO
SET IDENTITY_INSERT [dbo].[CategoryRules] ON 

INSERT [dbo].[CategoryRules] ([IdRule], [CategoryName], [Client], [Value], [Conditional]) VALUES (1, N'HIGHRISK                                                                                            ', N'Private                                 ', 1000000, 1)
INSERT [dbo].[CategoryRules] ([IdRule], [CategoryName], [Client], [Value], [Conditional]) VALUES (2, N'MEDIUMRISK                                                                                          ', N'Public                                  ', 1000000, 1)
INSERT [dbo].[CategoryRules] ([IdRule], [CategoryName], [Client], [Value], [Conditional]) VALUES (3, N'LOWRISK                                                                                             ', N'Public                                  ', 1000000, 0)
SET IDENTITY_INSERT [dbo].[CategoryRules] OFF
GO
SET IDENTITY_INSERT [dbo].[Trade] ON 

INSERT [dbo].[Trade] ([IdTrade], [Value], [ClientSector], [Risk]) VALUES (1, 2000000, N'Private                                 ', NULL)
INSERT [dbo].[Trade] ([IdTrade], [Value], [ClientSector], [Risk]) VALUES (2, 400000, N'Public                                  ', NULL)
INSERT [dbo].[Trade] ([IdTrade], [Value], [ClientSector], [Risk]) VALUES (3, 500000, N'Public                                  ', NULL)
INSERT [dbo].[Trade] ([IdTrade], [Value], [ClientSector], [Risk]) VALUES (4, 3000000, N'Public                                  ', NULL)
SET IDENTITY_INSERT [dbo].[Trade] OFF
GO
/****** Object:  StoredProcedure [dbo].[CheckRules]    Script Date: 25/01/2021 09:22:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CheckRules]
AS

DECLARE @Value FLOAT
	,@ClientSector VARCHAR(40)
	,@CategoryName VARCHAR(100)
	,@Client VARCHAR(40)
	,@ValueRule FLOAT
	,@Conditional BIT
-- Cursor para percorrer os registros
DECLARE cursor1 CURSOR
FOR
SELECT t.Value
	,t.ClientSector
FROM Trade t

--Abrindo Cursor
OPEN cursor1

-- Lendo a próxima linha
FETCH NEXT
FROM cursor1
INTO @Value
	,@ClientSector

-- Percorrendo linhas do cursor (enquanto houverem)
WHILE @@FETCH_STATUS = 0
BEGIN
	-- Executando as rotinas desejadas manipulando o registro
	--PRINT CONCAT (
	--		@Value
	--		,' '
	--		,@ClientSector
	--		)
			DECLARE cursorRule CURSOR
			FOR
			SELECT r.Value
				,r.Client
				,r.CategoryName
				,r.Conditional
			FROM CategoryRules r

			--Abrindo Cursor
			OPEN cursorRule

			-- Lendo a próxima linha
			FETCH NEXT
			FROM cursorRule
			INTO @ValueRule
				,@Client
				,@CategoryName
				,@Conditional

			-- Percorrendo linhas do cursor (enquanto houverem)
			WHILE @@FETCH_STATUS = 0
			BEGIN


			if (@ClientSector = @Client)
            BEGIN

				if(@Conditional = 0)
				BEGIN
					IF(@Value < @ValueRule)
					begin
					print @CategoryName
					end
				END

				if(@Conditional = 1)
				BEGIN
					IF(@Value > @ValueRule)
					begin
					print @CategoryName
					end
				END
            END

				-- Executando as rotinas desejadas manipulando o registro
				--PRINT CONCAT (
				--		@ValueRule
				--		,' '
				--		,@Client
				--		,' '
				--		,@CategoryName
				--		,' '
				--		,@Conditional
				--		)



				-- Lendo a próxima linha
				FETCH NEXT
				FROM cursorRule
				INTO @ValueRule
					,@Client
					,@CategoryName
					,@Conditional
			END

			-- Fechando Cursor para leitura
			CLOSE cursorRule

			-- Finalizado o cursor
			DEALLOCATE cursorRule
	



	-- Lendo a próxima linha
	FETCH NEXT
	FROM cursor1
	INTO @Value
		,@ClientSector
END

-- Fechando Cursor para leitura
CLOSE cursor1

-- Finalizado o cursor
DEALLOCATE cursor1
GO
USE [master]
GO
ALTER DATABASE [IdentifyCategory] SET  READ_WRITE 
GO
