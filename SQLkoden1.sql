USE [master]
GO
/****** Object:  Database [PPDBDesireTilleras]    Script Date: 2021-02-04 18:20:42 ******/
CREATE DATABASE [PPDBDesireTilleras]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'PPDBDesireTilleras', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\PPDBDesireTilleras.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'PPDBDesireTilleras_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\PPDBDesireTilleras_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT
GO
ALTER DATABASE [PPDBDesireTilleras] SET COMPATIBILITY_LEVEL = 150
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [PPDBDesireTilleras].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [PPDBDesireTilleras] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [PPDBDesireTilleras] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [PPDBDesireTilleras] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [PPDBDesireTilleras] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [PPDBDesireTilleras] SET ARITHABORT OFF 
GO
ALTER DATABASE [PPDBDesireTilleras] SET AUTO_CLOSE ON 
GO
ALTER DATABASE [PPDBDesireTilleras] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [PPDBDesireTilleras] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [PPDBDesireTilleras] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [PPDBDesireTilleras] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [PPDBDesireTilleras] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [PPDBDesireTilleras] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [PPDBDesireTilleras] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [PPDBDesireTilleras] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [PPDBDesireTilleras] SET  ENABLE_BROKER 
GO
ALTER DATABASE [PPDBDesireTilleras] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [PPDBDesireTilleras] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [PPDBDesireTilleras] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [PPDBDesireTilleras] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [PPDBDesireTilleras] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [PPDBDesireTilleras] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [PPDBDesireTilleras] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [PPDBDesireTilleras] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [PPDBDesireTilleras] SET  MULTI_USER 
GO
ALTER DATABASE [PPDBDesireTilleras] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [PPDBDesireTilleras] SET DB_CHAINING OFF 
GO
ALTER DATABASE [PPDBDesireTilleras] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [PPDBDesireTilleras] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [PPDBDesireTilleras] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [PPDBDesireTilleras] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
ALTER DATABASE [PPDBDesireTilleras] SET QUERY_STORE = OFF
GO
USE [PPDBDesireTilleras]
GO
/****** Object:  UserDefinedFunction [dbo].[fk_AveragePerDay]    Script Date: 2021-02-04 18:20:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fk_AveragePerDay](@fromDate DATE, @toDate DATE)
RETURNS INT
AS
BEGIN
DECLARE
@averageCost MONEY
SET @averageCost=(
SELECT TOP 1 AVG(TotalCost) as avgCost
FROM ParkingHistory
WHERE @fromDate <= CheckInTime AND @toDate >=CheckOutTime
GROUP BY CAST(CheckInTime as DATE)
ORDER BY CAST(CheckInTime as DATE)ASC)
RETURN CAST(@averageCost AS INT)

END
GO
/****** Object:  UserDefinedFunction [dbo].[fk_SpecDate]    Script Date: 2021-02-04 18:20:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fk_SpecDate](@date DATE)
RETURNS INT
AS
BEGIN
DECLARE
@totalIncome MONEY

SELECT @totalIncome = SUM(TotalCost)
FROM ParkingHistory
WHERE CAST(CheckOutTime AS DATE) = @date
RETURN CAST(@totalIncome AS INT)
END
GO
/****** Object:  UserDefinedFunction [dbo].[fk_TotalBetwDates]    Script Date: 2021-02-04 18:20:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fk_TotalBetwDates](@fromDate DATE, @toDate DATE)
RETURNS INT
AS
BEGIN
DECLARE
@totalIncome MONEY
SET @totalIncome=(
SELECT SUM(TotalCost)
FROM ParkingHistory
WHERE @fromDate <= CheckInTime AND @toDate >=CheckOutTime)
RETURN CAST(@totalIncome AS INT)

END
GO
/****** Object:  Table [dbo].[ParkingSpots]    Script Date: 2021-02-04 18:20:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ParkingSpots](
	[ParkingSpotID] [int] IDENTITY(1,1) NOT NULL,
	[SpotNumber] [int] NOT NULL,
	[CurrentOccupation] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[ParkingSpotID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[FreeSpotsCars]    Script Date: 2021-02-04 18:20:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[FreeSpotsCars]
AS
SELECT SpotNumber AS 'Parking Spot Number', CurrentOccupation AS 'Free spot for car'
FROM ParkingSpots
WHERE CurrentOccupation IS NULL OR CurrentOccupation = 0;
GO
/****** Object:  View [dbo].[FreeSpotsMC]    Script Date: 2021-02-04 18:20:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[FreeSpotsMC]
AS
SELECT SpotNumber AS 'Parking Spot Number', CurrentOccupation AS 'Free spot for MC'
FROM ParkingSpots
WHERE CurrentOccupation IS NULL OR CurrentOccupation = 0 OR CurrentOccupation = 1;
GO
/****** Object:  Table [dbo].[ParkedVehicles]    Script Date: 2021-02-04 18:20:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ParkedVehicles](
	[ParkedVehiclesID] [int] IDENTITY(1,1) NOT NULL,
	[RegNumber] [nvarchar](10) NOT NULL,
	[VehicleTypeID] [int] NOT NULL,
	[SpotID] [int] NOT NULL,
	[CheckInTime] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ParkedVehiclesID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[ListAllSpots]    Script Date: 2021-02-04 18:20:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[ListAllSpots]
AS
SELECT SpotNumber,
COALESCE(RegNumber, 'EMPTY') AS RegNumber,
COALESCE(VehicleTypeID, 0) AS VehicleTypeID,
COALESCE(CheckInTime, 0) AS CheckInTime
FROM ParkingSpots ps
FULL OUTER JOIN ParkedVehicles pv
ON ps.ParkingSpotID = pv.SpotID
GO
/****** Object:  View [dbo].[Vehicles48h]    Script Date: 2021-02-04 18:20:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[Vehicles48h]
AS

SELECT CAST(SpotID AS NVARCHAR(20)) AS SpotID, RegNumber, CAST(CheckInTime AS NVARCHAR(30)) AS CheckInTime 
FROM ParkedVehicles
WHERE DATEDIFF(HOUR, CheckInTime, GETDATE())>48

GO
/****** Object:  Table [dbo].[ParkingHistory]    Script Date: 2021-02-04 18:20:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ParkingHistory](
	[ParkingHistoryID] [int] IDENTITY(1,1) NOT NULL,
	[RegNumber] [nvarchar](10) NOT NULL,
	[CheckInTime] [datetime] NOT NULL,
	[CheckOutTime] [datetime] NOT NULL,
	[TotalCost] [money] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ParkingHistoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[DisplayHistory]    Script Date: 2021-02-04 18:20:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[DisplayHistory]
AS
SELECT RegNumber, CheckInTime, CheckOutTime, CAST(TotalCost AS INT) as TotalCost
FROM ParkingHistory
GO
/****** Object:  Table [dbo].[VehicleTypes]    Script Date: 2021-02-04 18:20:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[VehicleTypes](
	[VehicleTypeID] [int] IDENTITY(1,1) NOT NULL,
	[TypeName] [nvarchar](20) NOT NULL,
	[PricePerHour] [money] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[VehicleTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET IDENTITY_INSERT [dbo].[ParkedVehicles] ON 
GO
INSERT [dbo].[ParkedVehicles] ([ParkedVehiclesID], [RegNumber], [VehicleTypeID], [SpotID], [CheckInTime]) VALUES (68, N'ABC130', 1, 2, CAST(N'2021-02-02T10:09:27.140' AS DateTime))
GO
INSERT [dbo].[ParkedVehicles] ([ParkedVehiclesID], [RegNumber], [VehicleTypeID], [SpotID], [CheckInTime]) VALUES (107, N'ENTIMGHT10', 2, 6, CAST(N'2021-02-03T19:50:19.443' AS DateTime))
GO
INSERT [dbo].[ParkedVehicles] ([ParkedVehiclesID], [RegNumber], [VehicleTypeID], [SpotID], [CheckInTime]) VALUES (119, N'BIL1', 2, 9, CAST(N'2021-02-04T07:14:07.890' AS DateTime))
GO
INSERT [dbo].[ParkedVehicles] ([ParkedVehiclesID], [RegNumber], [VehicleTypeID], [SpotID], [CheckInTime]) VALUES (125, N'ABC127', 2, 31, CAST(N'2021-02-02T10:06:08.760' AS DateTime))
GO
INSERT [dbo].[ParkedVehicles] ([ParkedVehiclesID], [RegNumber], [VehicleTypeID], [SpotID], [CheckInTime]) VALUES (137, N'ABC2000', 1, 7, CAST(N'2021-02-04T08:43:42.683' AS DateTime))
GO
INSERT [dbo].[ParkedVehicles] ([ParkedVehiclesID], [RegNumber], [VehicleTypeID], [SpotID], [CheckInTime]) VALUES (164, N'HJUL2', 1, 4, CAST(N'2021-02-03T21:24:35.457' AS DateTime))
GO
INSERT [dbo].[ParkedVehicles] ([ParkedVehiclesID], [RegNumber], [VehicleTypeID], [SpotID], [CheckInTime]) VALUES (183, N'DOO072', 2, 8, CAST(N'2021-02-02T20:25:07.080' AS DateTime))
GO
INSERT [dbo].[ParkedVehicles] ([ParkedVehiclesID], [RegNumber], [VehicleTypeID], [SpotID], [CheckInTime]) VALUES (185, N'MC2', 1, 10, CAST(N'2021-02-04T12:02:22.733' AS DateTime))
GO
INSERT [dbo].[ParkedVehicles] ([ParkedVehiclesID], [RegNumber], [VehicleTypeID], [SpotID], [CheckInTime]) VALUES (186, N'YXZ123', 1, 1, CAST(N'2021-02-04T18:07:58.453' AS DateTime))
GO
SET IDENTITY_INSERT [dbo].[ParkedVehicles] OFF
GO
SET IDENTITY_INSERT [dbo].[ParkingHistory] ON 
GO
INSERT [dbo].[ParkingHistory] ([ParkingHistoryID], [RegNumber], [CheckInTime], [CheckOutTime], [TotalCost]) VALUES (1, N'ABC123', CAST(N'2021-02-02T09:54:51.760' AS DateTime), CAST(N'2021-02-02T12:39:25.840' AS DateTime), 20.0000)
GO
INSERT [dbo].[ParkingHistory] ([ParkingHistoryID], [RegNumber], [CheckInTime], [CheckOutTime], [TotalCost]) VALUES (2, N'ABC200', CAST(N'2021-02-02T10:34:18.027' AS DateTime), CAST(N'2021-02-02T12:50:26.760' AS DateTime), 0.0000)
GO
INSERT [dbo].[ParkingHistory] ([ParkingHistoryID], [RegNumber], [CheckInTime], [CheckOutTime], [TotalCost]) VALUES (3, N'ABC124', CAST(N'2021-02-02T09:55:37.770' AS DateTime), CAST(N'2021-02-02T12:54:46.950' AS DateTime), 20.0000)
GO
INSERT [dbo].[ParkingHistory] ([ParkingHistoryID], [RegNumber], [CheckInTime], [CheckOutTime], [TotalCost]) VALUES (4, N'abc190', CAST(N'2021-02-02T10:33:46.700' AS DateTime), CAST(N'2021-02-02T12:57:53.380' AS DateTime), 20.0000)
GO
INSERT [dbo].[ParkingHistory] ([ParkingHistoryID], [RegNumber], [CheckInTime], [CheckOutTime], [TotalCost]) VALUES (5, N'ABC180', CAST(N'2021-02-02T10:32:14.263' AS DateTime), CAST(N'2021-02-02T13:03:22.043' AS DateTime), 40.0000)
GO
INSERT [dbo].[ParkingHistory] ([ParkingHistoryID], [RegNumber], [CheckInTime], [CheckOutTime], [TotalCost]) VALUES (11, N'ABC150', CAST(N'2021-02-02T10:21:17.327' AS DateTime), CAST(N'2021-02-03T12:32:33.523' AS DateTime), 260.0000)
GO
INSERT [dbo].[ParkingHistory] ([ParkingHistoryID], [RegNumber], [CheckInTime], [CheckOutTime], [TotalCost]) VALUES (12, N'HEJ', CAST(N'2021-02-03T10:11:03.107' AS DateTime), CAST(N'2021-02-03T15:23:43.343' AS DateTime), 50.0000)
GO
INSERT [dbo].[ParkingHistory] ([ParkingHistoryID], [RegNumber], [CheckInTime], [CheckOutTime], [TotalCost]) VALUES (13, N'ABC170', CAST(N'2021-02-02T10:30:03.217' AS DateTime), CAST(N'2021-02-03T16:28:53.740' AS DateTime), 290.0000)
GO
INSERT [dbo].[ParkingHistory] ([ParkingHistoryID], [RegNumber], [CheckInTime], [CheckOutTime], [TotalCost]) VALUES (14, N'GGG111', CAST(N'2021-02-03T15:52:12.907' AS DateTime), CAST(N'2021-02-03T16:29:19.320' AS DateTime), 20.0000)
GO
INSERT [dbo].[ParkingHistory] ([ParkingHistoryID], [RegNumber], [CheckInTime], [CheckOutTime], [TotalCost]) VALUES (16, N'HEJ125', CAST(N'2021-02-02T21:15:19.837' AS DateTime), CAST(N'2021-02-03T21:36:22.780' AS DateTime), 480.0000)
GO
INSERT [dbo].[ParkingHistory] ([ParkingHistoryID], [RegNumber], [CheckInTime], [CheckOutTime], [TotalCost]) VALUES (23, N'ABC135', CAST(N'2021-02-02T10:11:41.283' AS DateTime), CAST(N'2021-02-04T07:15:23.057' AS DateTime), 440.0000)
GO
INSERT [dbo].[ParkingHistory] ([ParkingHistoryID], [RegNumber], [CheckInTime], [CheckOutTime], [TotalCost]) VALUES (24, N'DESSISBIL', CAST(N'2021-02-03T21:20:24.797' AS DateTime), CAST(N'2021-02-04T07:19:19.480' AS DateTime), 180.0000)
GO
INSERT [dbo].[ParkingHistory] ([ParkingHistoryID], [RegNumber], [CheckInTime], [CheckOutTime], [TotalCost]) VALUES (25, N'ABC125', CAST(N'2021-02-02T09:55:46.270' AS DateTime), CAST(N'2021-02-04T15:46:08.253' AS DateTime), 530.0000)
GO
INSERT [dbo].[ParkingHistory] ([ParkingHistoryID], [RegNumber], [CheckInTime], [CheckOutTime], [TotalCost]) VALUES (27, N'ENMC1', CAST(N'2021-02-04T07:12:40.573' AS DateTime), CAST(N'2021-02-04T16:23:40.903' AS DateTime), 0.0000)
GO
INSERT [dbo].[ParkingHistory] ([ParkingHistoryID], [RegNumber], [CheckInTime], [CheckOutTime], [TotalCost]) VALUES (32, N'FFF111', CAST(N'2021-02-03T15:51:54.230' AS DateTime), CAST(N'2021-02-04T16:32:54.007' AS DateTime), 0.0000)
GO
INSERT [dbo].[ParkingHistory] ([ParkingHistoryID], [RegNumber], [CheckInTime], [CheckOutTime], [TotalCost]) VALUES (33, N'BBB111', CAST(N'2021-02-03T15:50:20.503' AS DateTime), CAST(N'2021-02-04T16:35:26.247' AS DateTime), 0.0000)
GO
INSERT [dbo].[ParkingHistory] ([ParkingHistoryID], [RegNumber], [CheckInTime], [CheckOutTime], [TotalCost]) VALUES (34, N'HHH111', CAST(N'2021-02-03T15:53:32.463' AS DateTime), CAST(N'2021-02-04T16:48:35.377' AS DateTime), 0.0000)
GO
INSERT [dbo].[ParkingHistory] ([ParkingHistoryID], [RegNumber], [CheckInTime], [CheckOutTime], [TotalCost]) VALUES (35, N'EEE111', CAST(N'2021-02-03T15:50:48.903' AS DateTime), CAST(N'2021-02-04T16:50:35.893' AS DateTime), 240.0000)
GO
INSERT [dbo].[ParkingHistory] ([ParkingHistoryID], [RegNumber], [CheckInTime], [CheckOutTime], [TotalCost]) VALUES (36, N'CCC111', CAST(N'2021-02-03T15:50:30.947' AS DateTime), CAST(N'2021-02-04T16:52:03.413' AS DateTime), 240.0000)
GO
INSERT [dbo].[ParkingHistory] ([ParkingHistoryID], [RegNumber], [CheckInTime], [CheckOutTime], [TotalCost]) VALUES (37, N'ABC1000', CAST(N'2021-02-04T08:41:53.293' AS DateTime), CAST(N'2021-02-04T16:54:19.377' AS DateTime), 0.0000)
GO
INSERT [dbo].[ParkingHistory] ([ParkingHistoryID], [RegNumber], [CheckInTime], [CheckOutTime], [TotalCost]) VALUES (38, N'HJUL3', CAST(N'2021-02-03T21:30:13.397' AS DateTime), CAST(N'2021-02-04T16:56:19.690' AS DateTime), 0.0000)
GO
SET IDENTITY_INSERT [dbo].[ParkingHistory] OFF
GO
SET IDENTITY_INSERT [dbo].[ParkingSpots] ON 
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (1, 1, 1)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (2, 2, 1)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (3, 3, 0)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (4, 4, 1)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (5, 5, 0)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (6, 6, 2)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (7, 7, 1)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (8, 8, 2)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (9, 9, 2)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (10, 10, 1)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (11, 11, 0)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (12, 12, 0)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (13, 13, 0)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (14, 14, 0)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (15, 15, 0)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (16, 16, 0)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (17, 17, 0)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (18, 18, 0)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (19, 19, 0)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (20, 20, 0)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (21, 21, 0)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (22, 22, 0)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (23, 23, 0)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (24, 24, 0)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (25, 25, 0)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (26, 26, 0)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (27, 27, 0)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (28, 28, 0)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (29, 29, 0)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (30, 30, 0)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (31, 31, 2)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (32, 32, 0)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (33, 33, 0)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (34, 34, 0)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (35, 35, 0)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (36, 36, 0)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (37, 37, 0)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (38, 38, 0)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (39, 39, 0)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (40, 40, 0)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (41, 41, 0)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (42, 42, 0)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (43, 43, 0)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (44, 44, 0)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (45, 45, 0)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (46, 46, 0)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (47, 47, 0)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (48, 48, 0)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (49, 49, 0)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (50, 50, 0)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (51, 51, 0)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (52, 52, 0)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (53, 53, 0)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (54, 54, 0)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (55, 55, 0)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (56, 56, 0)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (57, 57, 0)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (58, 58, 0)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (59, 59, 0)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (60, 60, 0)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (61, 61, 0)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (62, 62, 0)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (63, 63, 0)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (64, 64, 0)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (65, 65, 0)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (66, 66, 0)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (67, 67, 0)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (68, 68, 0)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (69, 69, 0)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (70, 70, 0)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (71, 71, 0)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (72, 72, 0)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (73, 73, 0)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (74, 74, 0)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (75, 75, 0)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (76, 76, 0)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (77, 77, 0)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (78, 78, 0)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (79, 79, 0)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (80, 80, 0)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (81, 81, 0)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (82, 82, 0)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (83, 83, 0)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (84, 84, 0)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (85, 85, 0)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (86, 86, 0)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (87, 87, 0)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (88, 88, 0)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (89, 89, 0)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (90, 90, 0)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (91, 91, 0)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (92, 92, 0)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (93, 93, 0)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (94, 94, 0)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (95, 95, 0)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (96, 96, 0)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (97, 97, 0)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (98, 98, 0)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (99, 99, 0)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (100, 100, 0)
GO
SET IDENTITY_INSERT [dbo].[ParkingSpots] OFF
GO
SET IDENTITY_INSERT [dbo].[VehicleTypes] ON 
GO
INSERT [dbo].[VehicleTypes] ([VehicleTypeID], [TypeName], [PricePerHour]) VALUES (1, N'Motorcycle', 10.0000)
GO
INSERT [dbo].[VehicleTypes] ([VehicleTypeID], [TypeName], [PricePerHour]) VALUES (2, N'Car', 20.0000)
GO
SET IDENTITY_INSERT [dbo].[VehicleTypes] OFF
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ__ParkedVe__5D9A6740990FD528]    Script Date: 2021-02-04 18:20:42 ******/
ALTER TABLE [dbo].[ParkedVehicles] ADD UNIQUE NONCLUSTERED 
(
	[RegNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ParkedVehicles]  WITH CHECK ADD FOREIGN KEY([SpotID])
REFERENCES [dbo].[ParkingSpots] ([ParkingSpotID])
GO
ALTER TABLE [dbo].[ParkedVehicles]  WITH CHECK ADD FOREIGN KEY([VehicleTypeID])
REFERENCES [dbo].[VehicleTypes] ([VehicleTypeID])
GO
ALTER TABLE [dbo].[ParkedVehicles]  WITH CHECK ADD CHECK  ((len([RegNumber])>(2) AND len([RegNumber])<(11)))
GO
ALTER TABLE [dbo].[ParkingHistory]  WITH CHECK ADD CHECK  ((len([RegNumber])>(2) AND len([RegNumber])<(11)))
GO
ALTER TABLE [dbo].[ParkingSpots]  WITH CHECK ADD CHECK  (([CurrentOccupation]<(3)))
GO
ALTER TABLE [dbo].[ParkingSpots]  WITH CHECK ADD CHECK  (([CurrentOccupation]>=(0)))
GO
ALTER TABLE [dbo].[ParkingSpots]  WITH CHECK ADD CHECK  (([ParkingspotID]<=(100)))
GO
/****** Object:  StoredProcedure [dbo].[CheckOutVehicle]    Script Date: 2021-02-04 18:20:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CheckOutVehicle]
@regNUm NVARCHAR(10)
AS
DECLARE @vehicleType INT, 
@parkingSpot INT, 
@checkInTime DATETIME, 
@money MONEY

SET @vehicleType = (SELECT VehicleTypeID
FROM ParkedVehicles
WHERE RegNumber = @regNUm)

SET @parkingSpot = (SELECT SpotID
FROM ParkedVehicles
WHERE RegNumber = @regNUm)

SET @checkInTime =(SELECT CheckInTime
FROM ParkedVehicles
WHERE RegNumber = @regNUm)

EXECUTE FindVehicle @regNum

EXECUTE TotalCost @regNum, @money OUTPUT

BEGIN TRANSACTION
BEGIN TRY

INSERT INTO ParkingHistory (RegNumber,CheckInTime,CheckOutTime,TotalCost)
VALUES (@regNUm,@checkInTime, GETDATE(), @money)

DELETE
FROM ParkedVehicles
WHERE RegNumber = @regNum

COMMIT TRANSACTION
END TRY
BEGIN CATCH
ROLLBACK TRANSACTION
END CATCH

BEGIN TRANSACTION
BEGIN TRY

IF @vehicleType = 1
BEGIN
UPDATE ParkingSpots SET CurrentOccupation = ISNULL(CurrentOccupation,0) -1 WHERE SpotNumber = @ParkingSpot
END
IF @vehicleType = 2
BEGIN
UPDATE ParkingSpots SET CurrentOccupation = ISNULL(CurrentOccupation,0) -2 WHERE SpotNumber = @ParkingSpot
END

COMMIT TRANSACTION
END TRY
BEGIN CATCH
ROLLBACK TRANSACTION
END CATCH
GO
/****** Object:  StoredProcedure [dbo].[CheckOutVehicleNoCost]    Script Date: 2021-02-04 18:20:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CheckOutVehicleNoCost]
@regNUm NVARCHAR(10)
AS
DECLARE @vehicleType INT, 
@parkingSpot INT, 
@checkInTime DATETIME, 
@money MONEY = 0

SET @vehicleType = (SELECT VehicleTypeID
FROM ParkedVehicles
WHERE RegNumber = @regNUm)

SET @parkingSpot = (SELECT SpotID
FROM ParkedVehicles
WHERE RegNumber = @regNUm)

SET @checkInTime =(SELECT CheckInTime
FROM ParkedVehicles
WHERE RegNumber = @regNUm)

EXECUTE FindVehicle @regNum

BEGIN TRANSACTION
BEGIN TRY

INSERT INTO ParkingHistory (RegNumber,CheckInTime,CheckOutTime,TotalCost)
VALUES (@regNUm,@checkInTime, GETDATE(), @money)

DELETE
FROM ParkedVehicles
WHERE RegNumber = @regNum

COMMIT TRANSACTION
END TRY
BEGIN CATCH
ROLLBACK TRANSACTION
END CATCH

BEGIN TRANSACTION
BEGIN TRY

IF @vehicleType = 1
BEGIN
UPDATE ParkingSpots SET CurrentOccupation = ISNULL(CurrentOccupation,0) -1 WHERE SpotNumber = @ParkingSpot
END
IF @vehicleType = 2
BEGIN
UPDATE ParkingSpots SET CurrentOccupation = -2 WHERE SpotNumber = @ParkingSpot
END

COMMIT TRANSACTION
END TRY
BEGIN CATCH
ROLLBACK TRANSACTION
END CATCH
GO
/****** Object:  StoredProcedure [dbo].[FindFreeSpot]    Script Date: 2021-02-04 18:20:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[FindFreeSpot]
@vehicleType INT,
@freeSpot INT OUTPUT
AS
IF @vehicleType=1
BEGIN
SET @freeSpot = (SELECT TOP 1 SpotNumber
FROM ParkingSpots
WHERE CurrentOccupation IS NULL OR CurrentOccupation = 1 OR CurrentOccupation = 0
ORDER BY ParkingSpotID)
END
IF @vehicleType = 2
BEGIN
SET @freeSpot = (SELECT TOP 1 SpotNumber
FROM ParkingSpots
WHERE CurrentOccupation IS NULL OR CurrentOccupation = 0
ORDER BY ParkingSpotID)
END

RETURN
GO
/****** Object:  StoredProcedure [dbo].[FindVehicle]    Script Date: 2021-02-04 18:20:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[FindVehicle](@regNum NVARCHAR(10))  
AS 
   
BEGIN 
   
DECLARE @Exist INT 
   
IF EXISTS(SELECT RegNumber FROM ParkedVehicles WHERE RegNumber=@regNum)  
   
BEGIN 
       SET @Exist = 1   
END 
   
ELSE  
   
BEGIN  
       SET @Exist=0  
	   RAISERROR('The vehicle was not found.', 17, 1)
END  
   
RETURN @Exist  
   
END
GO
/****** Object:  StoredProcedure [dbo].[InsertVehicle]    Script Date: 2021-02-04 18:20:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[InsertVehicle] 
@regNum NVARCHAR(10), @vehicleTypeID INT
AS
DECLARE @ParkingSpot INT


EXECUTE FindFreeSpot @vehicleTypeID, @parkingSpot OUTPUT

BEGIN TRANSACTION
BEGIN TRY

INSERT INTO ParkedVehicles(RegNumber, VehicleTypeID, SpotID, CheckInTime)
VALUES(@regNum, @vehicleTypeID, @parkingSpot, GETDATE())

COMMIT TRANSACTION
END TRY
BEGIN CATCH
ROLLBACK TRANSACTION
END CATCH


BEGIN TRANSACTION
BEGIN TRY
IF @vehicleTypeID = 1
BEGIN
UPDATE ParkingSpots SET CurrentOccupation = ISNULL(CurrentOccupation,0)+ 1 WHERE SpotNumber = @ParkingSpot
END
IF @vehicleTypeID = 2
BEGIN
UPDATE ParkingSpots SET CurrentOccupation = 2 WHERE SpotNumber = @ParkingSpot
END

SELECT SpotID
FROM ParkedVehicles
WHERE SpotID = @ParkingSpot

COMMIT TRANSACTION
END TRY
BEGIN CATCH
ROLLBACK TRANSACTION
END CATCH
GO
/****** Object:  StoredProcedure [dbo].[MoveVehicle]    Script Date: 2021-02-04 18:20:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[MoveVehicle]
@regNum NVARCHAR(10), 
@newSpot INT 
AS
DECLARE
@vehicleType INT,
@oldSpot INT,
@checkInTime DATETIME,
@spot INT

SET @oldSpot = (SELECT SpotID
FROM ParkedVehicles
WHERE RegNumber = @regNum)

SET @checkInTime = (SELECT CheckInTime
FROM ParkedVehicles
WHERE RegNumber = @regNum)

SET @vehicleType = (SELECT VehicleTypeID
FROM ParkedVehicles
WHERE RegNumber = @regNum)

BEGIN TRANSACTION
BEGIN TRY
EXECUTE FindVehicle @regNum

IF @vehicleType = 1
BEGIN
SET @spot = (SELECT SpotNumber
FROM ParkingSpots
WHERE @newSpot = SpotNumber AND (CurrentOccupation IS NULL OR CurrentOccupation = 1 OR CurrentOccupation = 0))
END
IF @vehicleType = 2
BEGIN
SET @spot =(SELECT SpotNumber
FROM ParkingSpots
WHERE @newSpot = SpotNumber AND (CurrentOccupation IS NULL OR CurrentOccupation = 0))
END
COMMIT TRANSACTION
END TRY
BEGIN CATCH
ROLLBACK TRANSACTION
END CATCH

BEGIN TRANSACTION
BEGIN TRY
DELETE
FROM ParkedVehicles
WHERE RegNumber = @regNum

INSERT INTO ParkedVehicles(RegNumber, VehicleTypeID, SpotID, CheckInTime)
VALUES (@regNUm, @vehicleType, @spot, @checkInTime)

IF @vehicleType = 1
BEGIN
UPDATE ParkingSpots SET CurrentOccupation = ISNULL(CurrentOccupation,0) -1 WHERE SpotNumber = @oldSpot
UPDATE ParkingSpots SET CurrentOccupation = ISNULL(CurrentOccupation,0) +1 WHERE SpotNumber = @spot
END
IF @vehicleType = 2
BEGIN
UPDATE ParkingSpots SET CurrentOccupation = ISNULL(CurrentOccupation,0) -2 WHERE SpotNumber = @oldSpot
UPDATE ParkingSpots SET CurrentOccupation = ISNULL(CurrentOccupation,0) +2 WHERE SpotNumber = @spot
END

COMMIT TRANSACTION
END TRY
BEGIN CATCH
ROLLBACK TRANSACTION
END CATCH
GO
/****** Object:  StoredProcedure [dbo].[PrintMoney]    Script Date: 2021-02-04 18:20:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PrintMoney]
@regNum NVARCHAR(10) 
AS
DECLARE
@money MONEY,
@sentence NVARCHAR(100)

EXECUTE TotalCost @regNum, @money OUTPUT

SET @sentence = 'If the vehicle is checked out now, the cost is: ' + CAST(ISNULL(@money,0)AS VARCHAR(10)) + ' CZK'

PRINT @sentence

GO
/****** Object:  StoredProcedure [dbo].[proc_OptimizeMC]    Script Date: 2021-02-04 18:20:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[proc_OptimizeMC]
AS

DECLARE @listOfMC table (regnr NVARCHAR(10), vehicleType INT, spotID INT)

DECLARE @list table (regnr NVARCHAR(10), oldSpot INT, newSpot INT)

INSERT INTO @listOfMC
SELECT RegNumber, VehicleTypeID, SpotID
FROM ParkedVehicles
WHERE VehicleTypeID = 1  


DECLARE @regNum NVARCHAR(10),
@vehicleTypeID INT,
@newSpot INT,
@oldSpot INT


WHILE exists (SELECT 1 FROM @listOfMC)
BEGIN   	 
	 SET @regNum =(SELECT TOP 1 regnr FROM @listOfMC)
	 SET @oldSpot = (SELECT SpotID FROM @listOfMC WHERE regnr = @regNum)
	 SET @vehicleTypeID =(SELECT vehicleType FROM @listOfMC WHERE regnr = @regNum)    

	
	SET @newSpot = (SELECT TOP 1 SpotNumber as spot
	FROM ParkingSpots
	WHERE CurrentOccupation IS NULL OR CurrentOccupation = 1 OR CurrentOccupation = 0)	  

	 IF @newSpot < @oldSpot
	 BEGIN
	 EXECUTE [dbo].[MoveVehicle] @regNum, @newSpot
	 INSERT INTO @list(regnr, oldSpot, newSpot) VALUES(@regNum, @oldSpot, @newSpot)
	 END   

DELETE FROM @listOfMC WHERE regnr = @regNum
END

SELECT regnr, oldSpot, newSpot
FROM @list
GO
/****** Object:  StoredProcedure [dbo].[TotalCost]    Script Date: 2021-02-04 18:20:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[TotalCost]
@regnum NVARCHAR(10), 
@amount MONEY OUTPUT
AS
DECLARE @minutes INT = DATEDIFF(MINUTE, (SELECT CheckInTime FROM ParkedVehicles WHERE RegNumber=@regnum), GETDATE())

IF @minutes < 5
	SET @amount = 0
ELSE
BEGIN
	DECLARE @hours INT = (SELECT vt.PricePerHour FROM VehicleTypes vt
					       JOIN ParkedVehicles pv ON vt.VehicleTypeID = pv.VehicleTypeID
						   WHERE pv.RegNumber = @regnum)
	
	IF @minutes - 5 < 120
		SET @amount = @hours * 2
	ELSE
		SET @amount = (CEILING((@minutes - 5)/60)) * @hours
END
RETURN
GO
USE [master]
GO
ALTER DATABASE [PPDBDesireTilleras] SET  READ_WRITE 
GO
