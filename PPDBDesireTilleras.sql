

USE [PPDBDesireTilleras]
GO
/****** Object:  UserDefinedFunction [dbo].[fk_AveragePerDay]    Script Date: 2021-02-05 17:33:01 ******/
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
/****** Object:  UserDefinedFunction [dbo].[fk_SpecDate]    Script Date: 2021-02-05 17:33:01 ******/
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
/****** Object:  UserDefinedFunction [dbo].[fk_TotalBetwDates]    Script Date: 2021-02-05 17:33:01 ******/
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
/****** Object:  Table [dbo].[ParkingSpots]    Script Date: 2021-02-05 17:33:01 ******/
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
/****** Object:  View [dbo].[FreeSpotsCars]    Script Date: 2021-02-05 17:33:01 ******/
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
/****** Object:  View [dbo].[FreeSpotsMC]    Script Date: 2021-02-05 17:33:01 ******/
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
/****** Object:  Table [dbo].[ParkedVehicles]    Script Date: 2021-02-05 17:33:01 ******/
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
/****** Object:  View [dbo].[ListAllSpots]    Script Date: 2021-02-05 17:33:01 ******/
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
/****** Object:  Table [dbo].[ParkingHistory]    Script Date: 2021-02-05 17:33:01 ******/
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
	[VehicleTypeID] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ParkingHistoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[DisplayHistory]    Script Date: 2021-02-05 17:33:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[DisplayHistory]
AS
SELECT RegNumber, CheckInTime, CheckOutTime, CAST(TotalCost AS INT) as TotalCost, VehicleTypeID
FROM ParkingHistory
GO
/****** Object:  View [dbo].[Vehicles48h]    Script Date: 2021-02-05 17:33:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[Vehicles48h]
AS

SELECT CAST(SpotID AS NVARCHAR(20)) AS SpotID, RegNumber, CAST(CheckInTime AS NVARCHAR(30)) AS CheckInTime,DATEDIFF(HOUR, CheckInTime, GETDATE()) AS HoursParked 
FROM ParkedVehicles
WHERE DATEDIFF(HOUR, CheckInTime, GETDATE())>48
GO
/****** Object:  View [dbo].[v_IncomePerDay]    Script Date: 2021-02-05 17:33:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[v_IncomePerDay]
AS
SELECT CAST(SUM(TotalCost) as INT) as Income, 
CAST(DATEPART(day,CheckOutTime)as INT) as 'Day', 
CAST(DATEPART(month, CheckOutTime) as INT) as 'Month', 
CAST(DATEPART(year, CheckOutTime)as INT) as 'Year'
FROM ParkingHistory
GROUP BY DATEPART(day,CheckOutTime), DATEPART(month, CheckOutTime), DATEPART(year, CheckOutTime)
GO
/****** Object:  Table [dbo].[VehicleTypes]    Script Date: 2021-02-05 17:33:01 ******/
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

INSERT [dbo].[ParkedVehicles] ([ParkedVehiclesID], [RegNumber], [VehicleTypeID], [SpotID], [CheckInTime]) VALUES (107, N'ENTIMGHT10', 2, 6, CAST(N'2021-02-03T19:50:19.443' AS DateTime))
INSERT [dbo].[ParkedVehicles] ([ParkedVehiclesID], [RegNumber], [VehicleTypeID], [SpotID], [CheckInTime]) VALUES (188, N'EYU125', 1, 1, CAST(N'2021-02-04T19:26:12.720' AS DateTime))
INSERT [dbo].[ParkedVehicles] ([ParkedVehiclesID], [RegNumber], [VehicleTypeID], [SpotID], [CheckInTime]) VALUES (191, N'YER665', 1, 2, CAST(N'2021-02-04T19:29:33.530' AS DateTime))
INSERT [dbo].[ParkedVehicles] ([ParkedVehiclesID], [RegNumber], [VehicleTypeID], [SpotID], [CheckInTime]) VALUES (193, N'TYR448', 2, 10, CAST(N'2021-02-04T19:32:43.610' AS DateTime))
INSERT [dbo].[ParkedVehicles] ([ParkedVehiclesID], [RegNumber], [VehicleTypeID], [SpotID], [CheckInTime]) VALUES (213, N'ERT124', 1, 4, CAST(N'2021-02-05T08:46:18.617' AS DateTime))
INSERT [dbo].[ParkedVehicles] ([ParkedVehiclesID], [RegNumber], [VehicleTypeID], [SpotID], [CheckInTime]) VALUES (222, N'SES007', 2, 13, CAST(N'2021-02-05T16:48:21.627' AS DateTime))
INSERT [dbo].[ParkedVehicles] ([ParkedVehiclesID], [RegNumber], [VehicleTypeID], [SpotID], [CheckInTime]) VALUES (224, N'TYU789', 2, 15, CAST(N'2021-02-05T16:49:02.993' AS DateTime))
INSERT [dbo].[ParkedVehicles] ([ParkedVehiclesID], [RegNumber], [VehicleTypeID], [SpotID], [CheckInTime]) VALUES (228, N'WER123', 1, 3, CAST(N'2021-02-05T08:45:37.257' AS DateTime))
INSERT [dbo].[ParkedVehicles] ([ParkedVehiclesID], [RegNumber], [VehicleTypeID], [SpotID], [CheckInTime]) VALUES (229, N'QWER145', 1, 4, CAST(N'2021-02-05T09:01:13.443' AS DateTime))
INSERT [dbo].[ParkedVehicles] ([ParkedVehiclesID], [RegNumber], [VehicleTypeID], [SpotID], [CheckInTime]) VALUES (230, N'YXZ123', 1, 5, CAST(N'2021-02-04T18:07:58.453' AS DateTime))
INSERT [dbo].[ParkedVehicles] ([ParkedVehiclesID], [RegNumber], [VehicleTypeID], [SpotID], [CheckInTime]) VALUES (231, N'TRE333', 1, 5, CAST(N'2021-02-05T14:23:06.343' AS DateTime))
INSERT [dbo].[ParkedVehicles] ([ParkedVehiclesID], [RegNumber], [VehicleTypeID], [SpotID], [CheckInTime]) VALUES (232, N'GULAN55', 1, 7, CAST(N'2021-02-05T16:05:55.577' AS DateTime))
INSERT [dbo].[ParkedVehicles] ([ParkedVehiclesID], [RegNumber], [VehicleTypeID], [SpotID], [CheckInTime]) VALUES (233, N'RTY445', 1, 7, CAST(N'2021-02-05T16:48:53.500' AS DateTime))
INSERT [dbo].[ParkedVehicles] ([ParkedVehiclesID], [RegNumber], [VehicleTypeID], [SpotID], [CheckInTime]) VALUES (234, N'QQQ557', 1, 8, CAST(N'2021-02-05T12:25:54.283' AS DateTime))
INSERT [dbo].[ParkedVehicles] ([ParkedVehiclesID], [RegNumber], [VehicleTypeID], [SpotID], [CheckInTime]) VALUES (235, N'MC2', 1, 8, CAST(N'2021-02-04T12:02:22.733' AS DateTime))
INSERT [dbo].[ParkedVehicles] ([ParkedVehiclesID], [RegNumber], [VehicleTypeID], [SpotID], [CheckInTime]) VALUES (236, N'ABC127', 2, 90, CAST(N'2021-02-02T10:06:08.760' AS DateTime))
INSERT [dbo].[ParkedVehicles] ([ParkedVehiclesID], [RegNumber], [VehicleTypeID], [SpotID], [CheckInTime]) VALUES (237, N'ABC2000', 1, 73, CAST(N'2021-02-04T08:43:42.683' AS DateTime))
INSERT [dbo].[ParkedVehicles] ([ParkedVehiclesID], [RegNumber], [VehicleTypeID], [SpotID], [CheckInTime]) VALUES (238, N'EDH669', 1, 96, CAST(N'2021-02-04T19:34:09.807' AS DateTime))
INSERT [dbo].[ParkedVehicles] ([ParkedVehiclesID], [RegNumber], [VehicleTypeID], [SpotID], [CheckInTime]) VALUES (239, N'KULBIL125', 2, 71, CAST(N'2021-02-05T16:05:04.587' AS DateTime))
INSERT [dbo].[ParkedVehicles] ([ParkedVehiclesID], [RegNumber], [VehicleTypeID], [SpotID], [CheckInTime]) VALUES (240, N'OPP225', 2, 46, CAST(N'2021-02-04T19:28:59.057' AS DateTime))
INSERT [dbo].[ParkedVehicles] ([ParkedVehiclesID], [RegNumber], [VehicleTypeID], [SpotID], [CheckInTime]) VALUES (243, N'FAST2W', 1, 52, CAST(N'2021-02-05T16:47:58.460' AS DateTime))
INSERT [dbo].[ParkedVehicles] ([ParkedVehiclesID], [RegNumber], [VehicleTypeID], [SpotID], [CheckInTime]) VALUES (244, N'RTY997', 2, 57, CAST(N'2021-02-05T09:09:22.853' AS DateTime))
INSERT [dbo].[ParkedVehicles] ([ParkedVehiclesID], [RegNumber], [VehicleTypeID], [SpotID], [CheckInTime]) VALUES (245, N'DOO072', 2, 79, CAST(N'2021-02-02T20:25:07.080' AS DateTime))
SET IDENTITY_INSERT [dbo].[ParkedVehicles] OFF
GO
SET IDENTITY_INSERT [dbo].[ParkingHistory] ON 

INSERT [dbo].[ParkingHistory] ([ParkingHistoryID], [RegNumber], [CheckInTime], [CheckOutTime], [TotalCost], [VehicleTypeID]) VALUES (1, N'ABC123', CAST(N'2021-02-02T09:54:51.760' AS DateTime), CAST(N'2021-02-02T12:39:25.840' AS DateTime), 30.0000, 1)
INSERT [dbo].[ParkingHistory] ([ParkingHistoryID], [RegNumber], [CheckInTime], [CheckOutTime], [TotalCost], [VehicleTypeID]) VALUES (2, N'ABC200', CAST(N'2021-02-02T10:34:18.027' AS DateTime), CAST(N'2021-02-02T12:50:26.760' AS DateTime), 0.0000, 1)
INSERT [dbo].[ParkingHistory] ([ParkingHistoryID], [RegNumber], [CheckInTime], [CheckOutTime], [TotalCost], [VehicleTypeID]) VALUES (3, N'ABC124', CAST(N'2021-02-02T09:55:37.770' AS DateTime), CAST(N'2021-02-02T12:54:46.950' AS DateTime), 20.0000, 1)
INSERT [dbo].[ParkingHistory] ([ParkingHistoryID], [RegNumber], [CheckInTime], [CheckOutTime], [TotalCost], [VehicleTypeID]) VALUES (4, N'abc190', CAST(N'2021-02-02T10:33:46.700' AS DateTime), CAST(N'2021-02-02T12:57:53.380' AS DateTime), 60.0000, 2)
INSERT [dbo].[ParkingHistory] ([ParkingHistoryID], [RegNumber], [CheckInTime], [CheckOutTime], [TotalCost], [VehicleTypeID]) VALUES (5, N'ABC180', CAST(N'2021-02-02T10:32:14.263' AS DateTime), CAST(N'2021-02-02T13:03:22.043' AS DateTime), 40.0000, 2)
INSERT [dbo].[ParkingHistory] ([ParkingHistoryID], [RegNumber], [CheckInTime], [CheckOutTime], [TotalCost], [VehicleTypeID]) VALUES (11, N'ABC150', CAST(N'2021-02-02T10:21:17.327' AS DateTime), CAST(N'2021-02-03T12:32:33.523' AS DateTime), 260.0000, 2)
INSERT [dbo].[ParkingHistory] ([ParkingHistoryID], [RegNumber], [CheckInTime], [CheckOutTime], [TotalCost], [VehicleTypeID]) VALUES (12, N'HEJ', CAST(N'2021-02-03T10:11:03.107' AS DateTime), CAST(N'2021-02-03T15:23:43.343' AS DateTime), 60.0000, 1)
INSERT [dbo].[ParkingHistory] ([ParkingHistoryID], [RegNumber], [CheckInTime], [CheckOutTime], [TotalCost], [VehicleTypeID]) VALUES (13, N'ABC170', CAST(N'2021-02-02T10:30:03.217' AS DateTime), CAST(N'2021-02-03T16:28:53.740' AS DateTime), 290.0000, 2)
INSERT [dbo].[ParkingHistory] ([ParkingHistoryID], [RegNumber], [CheckInTime], [CheckOutTime], [TotalCost], [VehicleTypeID]) VALUES (14, N'GGG111', CAST(N'2021-02-03T15:52:12.907' AS DateTime), CAST(N'2021-02-03T16:29:19.320' AS DateTime), 20.0000, 1)
INSERT [dbo].[ParkingHistory] ([ParkingHistoryID], [RegNumber], [CheckInTime], [CheckOutTime], [TotalCost], [VehicleTypeID]) VALUES (16, N'HEJ125', CAST(N'2021-02-02T21:15:19.837' AS DateTime), CAST(N'2021-02-03T21:36:22.780' AS DateTime), 480.0000, 2)
INSERT [dbo].[ParkingHistory] ([ParkingHistoryID], [RegNumber], [CheckInTime], [CheckOutTime], [TotalCost], [VehicleTypeID]) VALUES (23, N'ABC135', CAST(N'2021-02-02T10:11:41.283' AS DateTime), CAST(N'2021-02-04T07:15:23.057' AS DateTime), 440.0000, 2)
INSERT [dbo].[ParkingHistory] ([ParkingHistoryID], [RegNumber], [CheckInTime], [CheckOutTime], [TotalCost], [VehicleTypeID]) VALUES (24, N'DESSISBIL', CAST(N'2021-02-03T21:20:24.797' AS DateTime), CAST(N'2021-02-04T07:19:19.480' AS DateTime), 180.0000, 2)
INSERT [dbo].[ParkingHistory] ([ParkingHistoryID], [RegNumber], [CheckInTime], [CheckOutTime], [TotalCost], [VehicleTypeID]) VALUES (25, N'ABC125', CAST(N'2021-02-02T09:55:46.270' AS DateTime), CAST(N'2021-02-04T15:46:08.253' AS DateTime), 530.0000, 1)
INSERT [dbo].[ParkingHistory] ([ParkingHistoryID], [RegNumber], [CheckInTime], [CheckOutTime], [TotalCost], [VehicleTypeID]) VALUES (27, N'ENMC1', CAST(N'2021-02-04T07:12:40.573' AS DateTime), CAST(N'2021-02-04T16:23:40.903' AS DateTime), 0.0000, 1)
INSERT [dbo].[ParkingHistory] ([ParkingHistoryID], [RegNumber], [CheckInTime], [CheckOutTime], [TotalCost], [VehicleTypeID]) VALUES (32, N'FFF111', CAST(N'2021-02-03T15:51:54.230' AS DateTime), CAST(N'2021-02-04T16:32:54.007' AS DateTime), 0.0000, 2)
INSERT [dbo].[ParkingHistory] ([ParkingHistoryID], [RegNumber], [CheckInTime], [CheckOutTime], [TotalCost], [VehicleTypeID]) VALUES (33, N'BBB111', CAST(N'2021-02-03T15:50:20.503' AS DateTime), CAST(N'2021-02-04T16:35:26.247' AS DateTime), 0.0000, 2)
INSERT [dbo].[ParkingHistory] ([ParkingHistoryID], [RegNumber], [CheckInTime], [CheckOutTime], [TotalCost], [VehicleTypeID]) VALUES (34, N'HHH111', CAST(N'2021-02-03T15:53:32.463' AS DateTime), CAST(N'2021-02-04T16:48:35.377' AS DateTime), 0.0000, 2)
INSERT [dbo].[ParkingHistory] ([ParkingHistoryID], [RegNumber], [CheckInTime], [CheckOutTime], [TotalCost], [VehicleTypeID]) VALUES (35, N'EEE111', CAST(N'2021-02-03T15:50:48.903' AS DateTime), CAST(N'2021-02-04T16:50:35.893' AS DateTime), 240.0000, 2)
INSERT [dbo].[ParkingHistory] ([ParkingHistoryID], [RegNumber], [CheckInTime], [CheckOutTime], [TotalCost], [VehicleTypeID]) VALUES (36, N'CCC111', CAST(N'2021-02-03T15:50:30.947' AS DateTime), CAST(N'2021-02-04T16:52:03.413' AS DateTime), 240.0000, 2)
INSERT [dbo].[ParkingHistory] ([ParkingHistoryID], [RegNumber], [CheckInTime], [CheckOutTime], [TotalCost], [VehicleTypeID]) VALUES (37, N'ABC1000', CAST(N'2021-02-04T08:41:53.293' AS DateTime), CAST(N'2021-02-04T16:54:19.377' AS DateTime), 0.0000, 1)
INSERT [dbo].[ParkingHistory] ([ParkingHistoryID], [RegNumber], [CheckInTime], [CheckOutTime], [TotalCost], [VehicleTypeID]) VALUES (38, N'HJUL3', CAST(N'2021-02-03T21:30:13.397' AS DateTime), CAST(N'2021-02-04T16:56:19.690' AS DateTime), 0.0000, 1)
INSERT [dbo].[ParkingHistory] ([ParkingHistoryID], [RegNumber], [CheckInTime], [CheckOutTime], [TotalCost], [VehicleTypeID]) VALUES (40, N'HJUL2', CAST(N'2021-02-03T21:24:35.457' AS DateTime), CAST(N'2021-02-05T07:07:01.693' AS DateTime), 330.0000, 1)
INSERT [dbo].[ParkingHistory] ([ParkingHistoryID], [RegNumber], [CheckInTime], [CheckOutTime], [TotalCost], [VehicleTypeID]) VALUES (41, N'EVASBIL1', CAST(N'2021-02-04T19:25:51.137' AS DateTime), CAST(N'2021-02-05T07:38:49.750' AS DateTime), 0.0000, 2)
INSERT [dbo].[ParkingHistory] ([ParkingHistoryID], [RegNumber], [CheckInTime], [CheckOutTime], [TotalCost], [VehicleTypeID]) VALUES (42, N'BIL1', CAST(N'2021-02-04T07:14:07.890' AS DateTime), CAST(N'2021-02-05T08:00:59.377' AS DateTime), 0.0000, 2)
INSERT [dbo].[ParkingHistory] ([ParkingHistoryID], [RegNumber], [CheckInTime], [CheckOutTime], [TotalCost], [VehicleTypeID]) VALUES (43, N'IOP889', CAST(N'2021-02-05T09:08:43.933' AS DateTime), CAST(N'2021-02-05T09:09:45.830' AS DateTime), 0.0000, 2)
INSERT [dbo].[ParkingHistory] ([ParkingHistoryID], [RegNumber], [CheckInTime], [CheckOutTime], [TotalCost], [VehicleTypeID]) VALUES (44, N'SDF569', CAST(N'2021-02-05T09:10:08.673' AS DateTime), CAST(N'2021-02-05T09:17:28.413' AS DateTime), 40.0000, 2)
INSERT [dbo].[ParkingHistory] ([ParkingHistoryID], [RegNumber], [CheckInTime], [CheckOutTime], [TotalCost], [VehicleTypeID]) VALUES (45, N'PPO447', CAST(N'2021-02-05T09:18:14.630' AS DateTime), CAST(N'2021-02-05T09:18:26.550' AS DateTime), 0.0000, 2)
INSERT [dbo].[ParkingHistory] ([ParkingHistoryID], [RegNumber], [CheckInTime], [CheckOutTime], [TotalCost], [VehicleTypeID]) VALUES (46, N'ABC130', CAST(N'2021-02-02T10:09:27.140' AS DateTime), CAST(N'2021-02-05T09:25:22.940' AS DateTime), 710.0000, 1)
INSERT [dbo].[ParkingHistory] ([ParkingHistoryID], [RegNumber], [CheckInTime], [CheckOutTime], [TotalCost], [VehicleTypeID]) VALUES (48, N'DTT899', CAST(N'2021-02-05T09:25:50.710' AS DateTime), CAST(N'2021-02-05T11:25:36.573' AS DateTime), 20.0000, 1)
INSERT [dbo].[ParkingHistory] ([ParkingHistoryID], [RegNumber], [CheckInTime], [CheckOutTime], [TotalCost], [VehicleTypeID]) VALUES (49, N'YUU889', CAST(N'2021-02-05T09:18:58.430' AS DateTime), CAST(N'2021-02-05T11:26:55.777' AS DateTime), 60.0000, 2)
INSERT [dbo].[ParkingHistory] ([ParkingHistoryID], [RegNumber], [CheckInTime], [CheckOutTime], [TotalCost], [VehicleTypeID]) VALUES (52, N'IOK556', CAST(N'2021-02-04T19:26:29.443' AS DateTime), CAST(N'2021-02-05T12:05:55.160' AS DateTime), 340.0000, 2)
INSERT [dbo].[ParkingHistory] ([ParkingHistoryID], [RegNumber], [CheckInTime], [CheckOutTime], [TotalCost], [VehicleTypeID]) VALUES (53, N'OOP778', CAST(N'2021-02-05T11:24:59.550' AS DateTime), CAST(N'2021-02-05T12:10:37.793' AS DateTime), 20.0000, 1)
INSERT [dbo].[ParkingHistory] ([ParkingHistoryID], [RegNumber], [CheckInTime], [CheckOutTime], [TotalCost], [VehicleTypeID]) VALUES (54, N'HJUL2', CAST(N'2021-02-05T11:26:16.523' AS DateTime), CAST(N'2021-02-05T16:46:47.487' AS DateTime), 60.0000, 1)
SET IDENTITY_INSERT [dbo].[ParkingHistory] OFF
GO
SET IDENTITY_INSERT [dbo].[ParkingSpots] ON 

INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (1, 1, 1)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (2, 2, 1)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (3, 3, 1)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (4, 4, 2)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (5, 5, 2)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (6, 6, 2)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (7, 7, 2)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (8, 8, 2)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (9, 9, 0)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (10, 10, 2)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (11, 11, 0)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (12, 12, 0)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (13, 13, 2)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (14, 14, 0)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (15, 15, 2)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (16, 16, 0)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (17, 17, 0)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (18, 18, 0)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (19, 19, 0)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (20, 20, 0)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (21, 21, 0)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (22, 22, 0)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (23, 23, 0)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (24, 24, 0)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (25, 25, 0)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (26, 26, 0)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (27, 27, 0)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (28, 28, 0)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (29, 29, 0)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (30, 30, 0)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (31, 31, 0)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (32, 32, 0)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (33, 33, 0)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (34, 34, 0)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (35, 35, 0)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (36, 36, 0)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (37, 37, 0)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (38, 38, 0)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (39, 39, 0)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (40, 40, 0)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (41, 41, 0)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (42, 42, 0)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (43, 43, 0)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (44, 44, 0)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (45, 45, 0)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (46, 46, 2)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (47, 47, 0)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (48, 48, 0)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (49, 49, 0)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (50, 50, 0)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (51, 51, 0)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (52, 52, 1)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (53, 53, 0)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (54, 54, 0)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (55, 55, 0)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (56, 56, 0)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (57, 57, 2)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (58, 58, 0)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (59, 59, 0)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (60, 60, 0)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (61, 61, 0)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (62, 62, 0)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (63, 63, 0)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (64, 64, 0)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (65, 65, 0)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (66, 66, 0)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (67, 67, 0)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (68, 68, 0)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (69, 69, 0)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (70, 70, 0)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (71, 71, 2)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (72, 72, 0)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (73, 73, 1)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (74, 74, 0)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (75, 75, 0)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (76, 76, 0)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (77, 77, 0)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (78, 78, 0)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (79, 79, 2)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (80, 80, 0)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (81, 81, 0)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (82, 82, 0)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (83, 83, 0)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (84, 84, 0)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (85, 85, 0)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (86, 86, 0)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (87, 87, 0)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (88, 88, 0)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (89, 89, 0)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (90, 90, 2)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (91, 91, 0)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (92, 92, 0)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (93, 93, 0)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (94, 94, 0)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (95, 95, 0)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (96, 96, 1)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (97, 97, 0)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (98, 98, 0)
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (99, 99, 0)
GO
INSERT [dbo].[ParkingSpots] ([ParkingSpotID], [SpotNumber], [CurrentOccupation]) VALUES (100, 100, 0)
SET IDENTITY_INSERT [dbo].[ParkingSpots] OFF
GO
SET IDENTITY_INSERT [dbo].[VehicleTypes] ON 

INSERT [dbo].[VehicleTypes] ([VehicleTypeID], [TypeName], [PricePerHour]) VALUES (1, N'Motorcycle', 10.0000)
INSERT [dbo].[VehicleTypes] ([VehicleTypeID], [TypeName], [PricePerHour]) VALUES (2, N'Car', 20.0000)
SET IDENTITY_INSERT [dbo].[VehicleTypes] OFF
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ__ParkedVe__5D9A6740990FD528]    Script Date: 2021-02-05 17:33:01 ******/
ALTER TABLE [dbo].[ParkedVehicles] ADD UNIQUE NONCLUSTERED 
(
	[RegNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ParkedVehicles]  WITH CHECK ADD FOREIGN KEY([SpotID])
REFERENCES [dbo].[ParkingSpots] ([ParkingSpotID])
GO
ALTER TABLE [dbo].[ParkedVehicles]  WITH CHECK ADD FOREIGN KEY([SpotID])
REFERENCES [dbo].[ParkingSpots] ([ParkingSpotID])
GO
ALTER TABLE [dbo].[ParkedVehicles]  WITH CHECK ADD FOREIGN KEY([VehicleTypeID])
REFERENCES [dbo].[VehicleTypes] ([VehicleTypeID])
GO
ALTER TABLE [dbo].[ParkedVehicles]  WITH CHECK ADD FOREIGN KEY([VehicleTypeID])
REFERENCES [dbo].[VehicleTypes] ([VehicleTypeID])
GO
ALTER TABLE [dbo].[ParkingHistory]  WITH CHECK ADD FOREIGN KEY([VehicleTypeID])
REFERENCES [dbo].[VehicleTypes] ([VehicleTypeID])
GO
ALTER TABLE [dbo].[ParkingHistory]  WITH CHECK ADD FOREIGN KEY([VehicleTypeID])
REFERENCES [dbo].[VehicleTypes] ([VehicleTypeID])
GO
ALTER TABLE [dbo].[ParkedVehicles]  WITH CHECK ADD CHECK  ((len([RegNumber])>(2) AND len([RegNumber])<(11)))
GO
ALTER TABLE [dbo].[ParkedVehicles]  WITH CHECK ADD CHECK  ((len([RegNumber])>(2) AND len([RegNumber])<(11)))
GO
ALTER TABLE [dbo].[ParkingHistory]  WITH CHECK ADD CHECK  ((len([RegNumber])>(2) AND len([RegNumber])<(11)))
GO
ALTER TABLE [dbo].[ParkingHistory]  WITH CHECK ADD CHECK  ((len([RegNumber])>(2) AND len([RegNumber])<(11)))
GO
ALTER TABLE [dbo].[ParkingSpots]  WITH CHECK ADD CHECK  (([CurrentOccupation]>=(0)))
GO
ALTER TABLE [dbo].[ParkingSpots]  WITH CHECK ADD CHECK  (([CurrentOccupation]<(3)))
GO
ALTER TABLE [dbo].[ParkingSpots]  WITH CHECK ADD CHECK  (([CurrentOccupation]>=(0)))
GO
ALTER TABLE [dbo].[ParkingSpots]  WITH CHECK ADD CHECK  (([CurrentOccupation]<(3)))
GO
ALTER TABLE [dbo].[ParkingSpots]  WITH CHECK ADD CHECK  (([ParkingspotID]<=(100)))
GO
ALTER TABLE [dbo].[ParkingSpots]  WITH CHECK ADD CHECK  (([ParkingspotID]<=(100)))
GO
/****** Object:  StoredProcedure [dbo].[CheckOutVehicle]    Script Date: 2021-02-05 17:33:01 ******/
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

INSERT INTO ParkingHistory (RegNumber,CheckInTime,CheckOutTime,TotalCost, VehicleTypeID)
VALUES (@regNUm,@checkInTime, GETDATE(), @money, @vehicleType)

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
UPDATE ParkingSpots SET CurrentOccupation = 0 WHERE SpotNumber = @ParkingSpot
END

COMMIT TRANSACTION
END TRY
BEGIN CATCH
ROLLBACK TRANSACTION
END CATCH
GO
/****** Object:  StoredProcedure [dbo].[CheckOutVehicleNoCost]    Script Date: 2021-02-05 17:33:01 ******/
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

INSERT INTO ParkingHistory (RegNumber,CheckInTime,CheckOutTime,TotalCost, VehicleTypeID)
VALUES (@regNUm,@checkInTime, GETDATE(), @money, @vehicleType)

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
UPDATE ParkingSpots SET CurrentOccupation = 0 WHERE SpotNumber = @ParkingSpot
END

COMMIT TRANSACTION
END TRY
BEGIN CATCH
ROLLBACK TRANSACTION
END CATCH
GO
/****** Object:  StoredProcedure [dbo].[FindFreeSpot]    Script Date: 2021-02-05 17:33:01 ******/
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
/****** Object:  StoredProcedure [dbo].[FindVehicle]    Script Date: 2021-02-05 17:33:01 ******/
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
/****** Object:  StoredProcedure [dbo].[InsertVehicle]    Script Date: 2021-02-05 17:33:01 ******/
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
/****** Object:  StoredProcedure [dbo].[MoveVehicle]    Script Date: 2021-02-05 17:33:01 ******/
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
UPDATE ParkingSpots SET CurrentOccupation = 0 WHERE SpotNumber = @oldSpot
UPDATE ParkingSpots SET CurrentOccupation = 2 WHERE SpotNumber = @spot
END

COMMIT TRANSACTION
END TRY
BEGIN CATCH
ROLLBACK TRANSACTION
END CATCH
GO
/****** Object:  StoredProcedure [dbo].[PrintMoney]    Script Date: 2021-02-05 17:33:01 ******/
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
/****** Object:  StoredProcedure [dbo].[proc_AvgPerDay]    Script Date: 2021-02-05 17:33:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[proc_AvgPerDay]
@fromDate DATE, @toDate DATE
AS

DECLARE @tempTable TABLE (checkInTime DATE, checkOutTime DATE, avgIncome INT)

DECLARE
@checkIntime DATE,
@checkOutTime DATE,
@avgIncome INT


SET @avgIncome = (SELECT dbo.fk_AveragePerDay(@fromDate, @toDate))

SET @checkIntime =(SELECT TOP 1 checkInTime FROM ParkingHistory WHERE CheckInTime >= @fromDate)

SET @checkOutTime =(SELECT MAX(CheckOutTime) FROM ParkingHistory WHERE CheckOutTime <= @toDate)

INSERT INTO @tempTable(checkInTime, checkOutTime, avgIncome) VALUES (@checkIntime, @checkOutTime, @avgIncome)

SELECT CAST(@checkIntime AS DATE), CAST(@checkOutTime AS DATE), @avgIncome
FROM @tempTable
GO
/****** Object:  StoredProcedure [dbo].[proc_IncomeCertDay]    Script Date: 2021-02-05 17:33:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[proc_IncomeCertDay]
@date DATE
AS

DECLARE @tempTable TABLE (checkOutTime DATE, totalIncome INT)

DECLARE
@firstCheckOut DATE,
@lastCheckOut DATE,
@totalIncome INT,
@newDate DATE

SET @firstCheckOut =(SELECT TOP 1(CheckOutTime) FROM ParkingHistory)
SET @lastCheckOut =(SELECT MAX(CheckOutTime) FROM ParkingHistory)

IF @date <= @firstCheckOut
BEGIN
SET @newDate = @firstCheckOut
END
IF @date >= @lastCheckOut
BEGIN
SET @newDate = @lastCheckOut
END
IF @date >= @firstCheckOut AND @date<=@lastCheckOut
BEGIN
SET @newDate = @date
END

SET @totalIncome = (SELECT dbo.fk_SpecDate(@newDate))

INSERT INTO @tempTable(checkOutTime, totalIncome) VALUES (@newDate, @totalIncome)

SELECT CAST(@newDate AS DATE), @totalIncome
FROM @tempTable
GO
/****** Object:  StoredProcedure [dbo].[proc_OptimizeMC]    Script Date: 2021-02-05 17:33:01 ******/
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
/****** Object:  StoredProcedure [dbo].[TotalCost]    Script Date: 2021-02-05 17:33:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[TotalCost]
@regnum NVARCHAR(10), 
@amount MONEY OUTPUT
AS
DECLARE @minutes DECIMAL = DATEDIFF(MINUTE, (SELECT CheckInTime FROM ParkedVehicles WHERE RegNumber=@regnum), GETDATE())

IF @minutes < 5
	SET @amount = 0
ELSE
BEGIN
	DECLARE @hours INT = (SELECT vt.PricePerHour FROM VehicleTypes vt
					       JOIN ParkedVehicles pv ON vt.VehicleTypeID = pv.VehicleTypeID
						   WHERE pv.RegNumber = @regnum)
	
	IF @minutes < 125
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
