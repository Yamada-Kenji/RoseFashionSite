USE [master]
GO
/****** Object:  Database [RoseFashionDB]    Script Date: 4/22/2020 9:24:36 PM ******/
CREATE DATABASE [RoseFashionDB]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'RoseFashionDB', FILENAME = N'D:\TLCN\RoseFashionDB.mdf' , SIZE = 73728KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'RoseFashionDB_log', FILENAME = N'D:\TLCN\RoseFashionDB_log.ldf' , SIZE = 73728KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
GO
ALTER DATABASE [RoseFashionDB] SET COMPATIBILITY_LEVEL = 130
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [RoseFashionDB].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [RoseFashionDB] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [RoseFashionDB] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [RoseFashionDB] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [RoseFashionDB] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [RoseFashionDB] SET ARITHABORT OFF 
GO
ALTER DATABASE [RoseFashionDB] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [RoseFashionDB] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [RoseFashionDB] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [RoseFashionDB] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [RoseFashionDB] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [RoseFashionDB] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [RoseFashionDB] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [RoseFashionDB] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [RoseFashionDB] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [RoseFashionDB] SET  DISABLE_BROKER 
GO
ALTER DATABASE [RoseFashionDB] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [RoseFashionDB] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [RoseFashionDB] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [RoseFashionDB] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [RoseFashionDB] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [RoseFashionDB] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [RoseFashionDB] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [RoseFashionDB] SET RECOVERY FULL 
GO
ALTER DATABASE [RoseFashionDB] SET  MULTI_USER 
GO
ALTER DATABASE [RoseFashionDB] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [RoseFashionDB] SET DB_CHAINING OFF 
GO
ALTER DATABASE [RoseFashionDB] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [RoseFashionDB] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [RoseFashionDB] SET DELAYED_DURABILITY = DISABLED 
GO
EXEC sys.sp_db_vardecimal_storage_format N'RoseFashionDB', N'ON'
GO
ALTER DATABASE [RoseFashionDB] SET QUERY_STORE = OFF
GO
USE [RoseFashionDB]
GO
ALTER DATABASE SCOPED CONFIGURATION SET MAXDOP = 0;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET MAXDOP = PRIMARY;
GO
ALTER DATABASE SCOPED CONFIGURATION SET LEGACY_CARDINALITY_ESTIMATION = OFF;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET LEGACY_CARDINALITY_ESTIMATION = PRIMARY;
GO
ALTER DATABASE SCOPED CONFIGURATION SET PARAMETER_SNIFFING = ON;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET PARAMETER_SNIFFING = PRIMARY;
GO
ALTER DATABASE SCOPED CONFIGURATION SET QUERY_OPTIMIZER_HOTFIXES = OFF;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET QUERY_OPTIMIZER_HOTFIXES = PRIMARY;
GO
USE [RoseFashionDB]
GO
/****** Object:  UserDefinedTableType [dbo].[ProductIDs]    Script Date: 4/22/2020 9:24:36 PM ******/
CREATE TYPE [dbo].[ProductIDs] AS TABLE(
	[ProductID] [varchar](50) NULL
)
GO
/****** Object:  UserDefinedFunction [dbo].[fn_CheckingIfProductWasPurchasedByUser]    Script Date: 4/22/2020 9:24:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[fn_CheckingIfProductWasPurchasedByUser](@userid varchar(50), @productid varchar(50)) returns @result table(Purchased varchar(50)) as
begin
	insert into @result
		select distinct ProductID
		from Cart_Product
		inner join Cart 
		on Cart.CartID = Cart_Product.CartID
		where UserID = @userid and ProductID = @productid
	return
end
GO
/****** Object:  UserDefinedFunction [dbo].[FN_GET1PAGE]    Script Date: 4/22/2020 9:24:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create FUNCTION [dbo].[FN_GET1PAGE](@IDList dbo.ProductIDs readonly) RETURNS @result table(pname nvarchar(MAX)) AS
BEGIN
	insert into @result 
		select Product.Name as pname 
		from Product
		inner join @IDList as idls on Product.ProductID = idls.ProductID;
	return
END 
GO
/****** Object:  UserDefinedFunction [dbo].[fn_GetProductRatingFromTopSimilarUser]    Script Date: 4/22/2020 9:24:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[fn_GetProductRatingFromTopSimilarUser](@userid varchar(50), @productid varchar(50)) 
returns @result table(SimilarityRate float, UserID varchar(50), Star float) as
begin
	insert into @result
	select TOP 10 SimilarityRate, UserID, Star
	from Similarity sub1
	inner join(
		select UserID, Star
		from Rating
		where ProductID = @productid) sub2
	on sub1.UserID1 = sub2.UserID or sub1.UserID2 = sub2.UserID
	where sub1.UserID1 = @userid or sub1.UserID2 = @userid
	order by SimilarityRate desc
return
end
GO
/****** Object:  UserDefinedFunction [dbo].[fn_GetRecommendedProduct]    Script Date: 4/22/2020 9:24:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[fn_GetRecommendedProduct](@userid varchar(50)) returns
@result table(ProductID varchar(50)) as
begin
	insert into @result
	select Top 10 ProductID
	from
	(select *
	from Recommendation
	where UserID = @userid) as temp
	order by PredictedStar desc
return
end
GO
/****** Object:  UserDefinedFunction [dbo].[fn_GetTwoVetor]    Script Date: 4/22/2020 9:24:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[fn_GetTwoVetor](@userid1 varchar(50), @userid2 varchar(50)) returns @result Table(User1Rating float, User2Rating float) as
begin
insert into @result
	select sub1.Star as User1Rating, sub2.Star as User2Rating from (select * from Rating where UserID = @userid1) sub1
	inner join (
	select * from Rating where UserID = @userid2) sub2 on sub1.ProductID = sub2.ProductID
return
end
GO
/****** Object:  UserDefinedFunction [dbo].[fn_GetUnRatedProduct]    Script Date: 4/22/2020 9:24:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[fn_GetUnRatedProduct](@userid varchar(50)) returns @result Table(ProductID varchar(50)) as
begin
insert into @result
	select ProductID
	from Product
	where ProductID not in 
		(select ProductID
		from Rating
		where Rating.UserID = @userid)
return
end
GO
/****** Object:  UserDefinedFunction [dbo].[FN_TOPSALE]    Script Date: 4/22/2020 9:24:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FN_TOPSALE]() RETURNS @RESULT TABLE (PID VARCHAR(50), TOTAL INT) AS
BEGIN
	DECLARE @TEMP TABLE(PID VARCHAR(50), AMT INT)
	INSERT INTO @TEMP SELECT ProductID, SUM(Amount) FROM dbo.Cart_Product GROUP BY ProductID;
	INSERT INTO @RESULT SELECT TOP 10 PID, MAX(AMT) AS TOTAL FROM @TEMP GROUP BY PID ORDER BY TOTAL DESC;
	RETURN
END
GO
/****** Object:  Table [dbo].[Bill]    Script Date: 4/22/2020 9:24:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Bill](
	[BillID] [varchar](50) NOT NULL,
	[CartID] [varchar](50) NOT NULL,
	[ReceiverName] [nvarchar](50) NOT NULL,
	[ReceiverPhone] [nchar](10) NOT NULL,
	[DeliveryAddress] [nvarchar](max) NOT NULL,
	[ProvinceName] [nvarchar](50) NOT NULL,
	[DistrictName] [nvarchar](50) NOT NULL,
	[OrderDate] [date] NOT NULL,
	[DeliveryDate] [date] NOT NULL,
	[DiscountCode] [varchar](50) NULL,
	[TotalPrice] [bigint] NOT NULL,
	[DeliveryFee] [bigint] NOT NULL,
	[Status] [nvarchar](50) NOT NULL,
	[IsDeleted] [bit] NOT NULL,
 CONSTRAINT [PK_Bill] PRIMARY KEY CLUSTERED 
(
	[BillID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Cart]    Script Date: 4/22/2020 9:24:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Cart](
	[CartID] [varchar](50) NOT NULL,
	[UserID] [varchar](50) NOT NULL,
	[IsUsing] [bit] NULL,
 CONSTRAINT [PK_Cart] PRIMARY KEY CLUSTERED 
(
	[CartID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Cart_Product]    Script Date: 4/22/2020 9:24:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Cart_Product](
	[CartID] [varchar](50) NOT NULL,
	[ProductID] [varchar](50) NOT NULL,
	[Size] [varchar](50) NOT NULL,
	[Amount] [int] NOT NULL,
	[SalePrice] [bigint] NOT NULL,
	[OriginalPrice] [bigint] NOT NULL,
 CONSTRAINT [PK_Cart_Product] PRIMARY KEY CLUSTERED 
(
	[CartID] ASC,
	[ProductID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Category]    Script Date: 4/22/2020 9:24:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Category](
	[CategoryID] [varchar](50) NOT NULL,
	[Name] [nvarchar](max) NOT NULL,
	[MainCategory] [varchar](50) NULL,
 CONSTRAINT [PK_Category] PRIMARY KEY CLUSTERED 
(
	[CategoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Discount]    Script Date: 4/22/2020 9:24:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Discount](
	[DiscountCode] [varchar](50) NOT NULL,
	[StartDate] [date] NOT NULL,
	[EndDate] [date] NOT NULL,
	[Value] [float] NOT NULL,
	[Title] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](max) NULL,
 CONSTRAINT [PK_Discount] PRIMARY KEY CLUSTERED 
(
	[DiscountCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[District]    Script Date: 4/22/2020 9:24:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[District](
	[DistrictID] [varchar](50) NOT NULL,
	[ProvinceID] [varchar](50) NOT NULL,
	[DistrictName] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_District] PRIMARY KEY CLUSTERED 
(
	[DistrictID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Product]    Script Date: 4/22/2020 9:24:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Product](
	[ProductID] [varchar](50) NOT NULL,
	[Name] [nvarchar](max) NOT NULL,
	[Color] [varchar](50) NULL,
	[CategoryID] [varchar](50) NOT NULL,
	[Description] [nvarchar](max) NULL,
	[Image] [varchar](max) NULL,
	[Price] [bigint] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[DiscountPercent] [int] NOT NULL,
	[ImportDate] [date] NOT NULL,
 CONSTRAINT [PK_Product] PRIMARY KEY CLUSTERED 
(
	[ProductID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Product_Size_Quantity]    Script Date: 4/22/2020 9:24:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Product_Size_Quantity](
	[ProductID] [varchar](50) NOT NULL,
	[Size] [varchar](50) NOT NULL,
	[Quantity] [int] NOT NULL,
 CONSTRAINT [PK_Product_Size_Quantity] PRIMARY KEY CLUSTERED 
(
	[ProductID] ASC,
	[Size] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Province]    Script Date: 4/22/2020 9:24:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Province](
	[ProvinceID] [varchar](50) NOT NULL,
	[ProvinceName] [nvarchar](50) NOT NULL,
	[DeliveryFee] [bigint] NOT NULL,
 CONSTRAINT [PK_Province] PRIMARY KEY CLUSTERED 
(
	[ProvinceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Rating]    Script Date: 4/22/2020 9:24:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Rating](
	[UserID] [varchar](50) NOT NULL,
	[ProductID] [varchar](50) NOT NULL,
	[Star] [float] NOT NULL,
	[Comment] [nvarchar](max) NULL,
	[Title] [nvarchar](50) NULL,
	[RatingDate] [date] NOT NULL,
 CONSTRAINT [PK_Rating] PRIMARY KEY CLUSTERED 
(
	[UserID] ASC,
	[ProductID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Recommendation]    Script Date: 4/22/2020 9:24:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Recommendation](
	[UserID] [varchar](50) NOT NULL,
	[ProductID] [varchar](50) NOT NULL,
	[PredictedStar] [float] NOT NULL,
 CONSTRAINT [PK_Recommendation] PRIMARY KEY CLUSTERED 
(
	[UserID] ASC,
	[ProductID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Similarity]    Script Date: 4/22/2020 9:24:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Similarity](
	[UserID1] [varchar](50) NOT NULL,
	[UserID2] [varchar](50) NOT NULL,
	[SimilarityRate] [float] NOT NULL,
 CONSTRAINT [PK_Similarity] PRIMARY KEY CLUSTERED 
(
	[UserID1] ASC,
	[UserID2] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[User]    Script Date: 4/22/2020 9:24:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[User](
	[UserID] [varchar](50) NOT NULL,
	[Password] [varchar](max) NOT NULL,
	[FullName] [nvarchar](100) NOT NULL,
	[Gender] [varchar](5) NULL,
	[DOB] [date] NULL,
	[Email] [varchar](50) NULL,
	[Address] [nvarchar](max) NULL,
	[Phone] [varchar](10) NULL,
	[Role] [varchar](50) NOT NULL,
 CONSTRAINT [PK_User] PRIMARY KEY CLUSTERED 
(
	[UserID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
INSERT [dbo].[Bill] ([BillID], [CartID], [ReceiverName], [ReceiverPhone], [DeliveryAddress], [ProvinceName], [DistrictName], [OrderDate], [DeliveryDate], [DiscountCode], [TotalPrice], [DeliveryFee], [Status], [IsDeleted]) VALUES (N'BL-1', N'CR-1', N'Lê Văn Tèo', N'0953751426', N'số 198 Nguyễn Thị Minh Khai, Phường 6, Quận 3, TP. Hồ Chí Minh', N'An Giang', N'Tri Tôn', CAST(N'2020-04-09' AS Date), CAST(N'2020-04-21' AS Date), NULL, 1519000, 10000, N'Đã thanh toán', 0)
INSERT [dbo].[Bill] ([BillID], [CartID], [ReceiverName], [ReceiverPhone], [DeliveryAddress], [ProvinceName], [DistrictName], [OrderDate], [DeliveryDate], [DiscountCode], [TotalPrice], [DeliveryFee], [Status], [IsDeleted]) VALUES (N'BL-2', N'CR-2', N'Lê Văn Tèo', N'0953751426', N'số 198, đường 75, xã Càng Cua', N'An Giang', N'Tri Tôn', CAST(N'2020-04-12' AS Date), CAST(N'2020-04-12' AS Date), NULL, 1357500, 10000, N'Đang chờ xác nhận', 0)
INSERT [dbo].[Bill] ([BillID], [CartID], [ReceiverName], [ReceiverPhone], [DeliveryAddress], [ProvinceName], [DistrictName], [OrderDate], [DeliveryDate], [DiscountCode], [TotalPrice], [DeliveryFee], [Status], [IsDeleted]) VALUES (N'BL-3', N'CR-5', N'Lê Văn Tèo', N'0953751426', N'số 198 Nguyễn Thị Minh Khai, Phường 6, Quận 3, TP. Hồ Chí Min', N'TP Hồ Chí Minh', N'Quận 3', CAST(N'2020-04-12' AS Date), CAST(N'2020-04-12' AS Date), NULL, 178500, 0, N'Đang chờ xác nhận', 0)
INSERT [dbo].[Bill] ([BillID], [CartID], [ReceiverName], [ReceiverPhone], [DeliveryAddress], [ProvinceName], [DistrictName], [OrderDate], [DeliveryDate], [DiscountCode], [TotalPrice], [DeliveryFee], [Status], [IsDeleted]) VALUES (N'BL-4', N'CR-6', N'Lê Văn Tèo', N'0953751426', N'số 198 Nguyễn Thị Minh Khai, Phường 6, Quận 3, TP. Hồ Chí Minh', N'Hà Nội', N'Mê Linh', CAST(N'2020-04-12' AS Date), CAST(N'2020-04-12' AS Date), NULL, 190000, 0, N'Đang chờ xác nhận', 0)
INSERT [dbo].[Bill] ([BillID], [CartID], [ReceiverName], [ReceiverPhone], [DeliveryAddress], [ProvinceName], [DistrictName], [OrderDate], [DeliveryDate], [DiscountCode], [TotalPrice], [DeliveryFee], [Status], [IsDeleted]) VALUES (N'BL-5', N'CR-7', N'Lê Văn Tèo', N'0953751426', N'số 198 Nguyễn Thị Minh Khai, Phường 6, Quận 3, TP. Hồ Chí Minh', N'Hà Giang', N'Quang Bình', CAST(N'2020-04-12' AS Date), CAST(N'2020-04-12' AS Date), NULL, 0, 0, N'Đang chờ xác nhận', 0)
INSERT [dbo].[Cart] ([CartID], [UserID], [IsUsing]) VALUES (N'CR-1', N'9011576b-720b-4d64-a01c-87479922a5da', 0)
INSERT [dbo].[Cart] ([CartID], [UserID], [IsUsing]) VALUES (N'CR-2', N'9011576b-720b-4d64-a01c-87479922a5da', 0)
INSERT [dbo].[Cart] ([CartID], [UserID], [IsUsing]) VALUES (N'CR-3', N'e58f964e-75ab-471f-917b-a689a0fe78cf', 1)
INSERT [dbo].[Cart] ([CartID], [UserID], [IsUsing]) VALUES (N'CR-4', N'7ecb877b-a135-42c4-b30f-e24c318d278c', 1)
INSERT [dbo].[Cart] ([CartID], [UserID], [IsUsing]) VALUES (N'CR-5', N'9011576b-720b-4d64-a01c-87479922a5da', 0)
INSERT [dbo].[Cart] ([CartID], [UserID], [IsUsing]) VALUES (N'CR-6', N'9011576b-720b-4d64-a01c-87479922a5da', 0)
INSERT [dbo].[Cart] ([CartID], [UserID], [IsUsing]) VALUES (N'CR-7', N'9011576b-720b-4d64-a01c-87479922a5da', 0)
INSERT [dbo].[Cart] ([CartID], [UserID], [IsUsing]) VALUES (N'CR-8', N'9011576b-720b-4d64-a01c-87479922a5da', 1)
INSERT [dbo].[Cart_Product] ([CartID], [ProductID], [Size], [Amount], [SalePrice], [OriginalPrice]) VALUES (N'CR-1', N'PR-1', N'S', 1, 699000, 699000)
INSERT [dbo].[Cart_Product] ([CartID], [ProductID], [Size], [Amount], [SalePrice], [OriginalPrice]) VALUES (N'CR-1', N'PR-10', N'M', 1, 700000, 700000)
INSERT [dbo].[Cart_Product] ([CartID], [ProductID], [Size], [Amount], [SalePrice], [OriginalPrice]) VALUES (N'CR-1', N'PR-12', N'S', 1, 120000, 120000)
INSERT [dbo].[Cart_Product] ([CartID], [ProductID], [Size], [Amount], [SalePrice], [OriginalPrice]) VALUES (N'CR-2', N'PR-1', N'S', 1, 699000, 699000)
INSERT [dbo].[Cart_Product] ([CartID], [ProductID], [Size], [Amount], [SalePrice], [OriginalPrice]) VALUES (N'CR-2', N'PR-12', N'M', 1, 120000, 120000)
INSERT [dbo].[Cart_Product] ([CartID], [ProductID], [Size], [Amount], [SalePrice], [OriginalPrice]) VALUES (N'CR-2', N'PR-14', N'M', 1, 178500, 210000)
INSERT [dbo].[Cart_Product] ([CartID], [ProductID], [Size], [Amount], [SalePrice], [OriginalPrice]) VALUES (N'CR-2', N'PR-15', N'M', 1, 360000, 400000)
INSERT [dbo].[Cart_Product] ([CartID], [ProductID], [Size], [Amount], [SalePrice], [OriginalPrice]) VALUES (N'CR-5', N'PR-14', N'M', 1, 178500, 210000)
INSERT [dbo].[Cart_Product] ([CartID], [ProductID], [Size], [Amount], [SalePrice], [OriginalPrice]) VALUES (N'CR-6', N'PR-17', N'S', 1, 190000, 190000)
INSERT [dbo].[Category] ([CategoryID], [Name], [MainCategory]) VALUES (N'CT1', N'Nam', NULL)
INSERT [dbo].[Category] ([CategoryID], [Name], [MainCategory]) VALUES (N'CT10', N'Quần jean', N'CT1')
INSERT [dbo].[Category] ([CategoryID], [Name], [MainCategory]) VALUES (N'CT11', N'Áo polo', N'CT1')
INSERT [dbo].[Category] ([CategoryID], [Name], [MainCategory]) VALUES (N'CT12', N'Quần short', N'CT1')
INSERT [dbo].[Category] ([CategoryID], [Name], [MainCategory]) VALUES (N'CT13', N'Quần khaki', N'CT1')
INSERT [dbo].[Category] ([CategoryID], [Name], [MainCategory]) VALUES (N'CT14', N'Áo phông', N'CT2')
INSERT [dbo].[Category] ([CategoryID], [Name], [MainCategory]) VALUES (N'CT15', N'Áo polo', N'CT2')
INSERT [dbo].[Category] ([CategoryID], [Name], [MainCategory]) VALUES (N'CT16', N'Chân váy', N'CT2')
INSERT [dbo].[Category] ([CategoryID], [Name], [MainCategory]) VALUES (N'CT17', N'Đầm', N'CT2')
INSERT [dbo].[Category] ([CategoryID], [Name], [MainCategory]) VALUES (N'CT18', N'Quần jean', N'CT2')
INSERT [dbo].[Category] ([CategoryID], [Name], [MainCategory]) VALUES (N'CT19', N'Quần short', N'CT2')
INSERT [dbo].[Category] ([CategoryID], [Name], [MainCategory]) VALUES (N'CT2', N'Nữ', NULL)
INSERT [dbo].[Category] ([CategoryID], [Name], [MainCategory]) VALUES (N'CT20', N'Khác', NULL)
INSERT [dbo].[Category] ([CategoryID], [Name], [MainCategory]) VALUES (N'CT3', N'Áo phông', N'CT1')
INSERT [dbo].[Category] ([CategoryID], [Name], [MainCategory]) VALUES (N'CT4', N'Áo sơ mi', N'CT1')
INSERT [dbo].[Category] ([CategoryID], [Name], [MainCategory]) VALUES (N'CT5', N'Áo khoác', N'CT1')
INSERT [dbo].[Category] ([CategoryID], [Name], [MainCategory]) VALUES (N'CT6', N'Áo len', N'CT2')
INSERT [dbo].[Category] ([CategoryID], [Name], [MainCategory]) VALUES (N'CT7', N'Áo khoác', N'CT2')
INSERT [dbo].[Category] ([CategoryID], [Name], [MainCategory]) VALUES (N'CT8', N'Áo sơ mi', N'CT2')
INSERT [dbo].[Category] ([CategoryID], [Name], [MainCategory]) VALUES (N'CT9', N'Quần vải', N'CT1')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-1', N'PV-1', N'An Phú')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-10', N'PV-1', N'Tịnh Biên')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-100', N'PV-11', N'Phú Quý')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-101', N'PV-11', N'Tánh Linh')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-102', N'PV-11', N'Tuy Phong')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-103', N'PV-12', N'Cà Mau')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-104', N'PV-12', N'Cái Nước')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-105', N'PV-12', N'Đầm Dơi')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-106', N'PV-12', N'Năm Căn')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-107', N'PV-12', N'Ngọc Hiển')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-108', N'PV-12', N'Phú Tân')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-109', N'PV-12', N'Thới Bình')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-11', N'PV-1', N'Tri Tôn')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-110', N'PV-12', N'Trần Văn Thời')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-111', N'PV-12', N'U Minh')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-112', N'PV-13', N'Bảo Lạc')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-113', N'PV-13', N'Bảo Lâm')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-114', N'PV-13', N'Cao Bằng')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-115', N'PV-13', N'Hà Quảng')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-116', N'PV-13', N'Hạ Lang')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-117', N'PV-13', N'Hòa An')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-118', N'PV-13', N'Nguyên Bình')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-119', N'PV-13', N'Quảng Hòa')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-12', N'PV-2', N'Bà Rịa')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-120', N'PV-13', N'Thạch An')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-121', N'PV-13', N'Trùng Khánh')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-122', N'PV-14', N'Bình Thủy')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-123', N'PV-14', N'Cái Răng')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-124', N'PV-14', N'Cờ Đỏ')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-125', N'PV-14', N'Ninh Kiều')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-126', N'PV-14', N'Ô Môn')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-127', N'PV-14', N'Phong Điền')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-128', N'PV-14', N'Thốt Nốt')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-129', N'PV-14', N'Thới Lai')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-13', N'PV-2', N'Châu Đức')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-130', N'PV-14', N'Vĩnh Thạnh')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-131', N'PV-15', N'Cẩm Lệ')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-132', N'PV-15', N'Hải Châu')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-133', N'PV-15', N'Hòa Vang')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-134', N'PV-15', N'Hoàng Sa')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-135', N'PV-15', N'Liên Chiểu')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-136', N'PV-15', N'Ngũ Hành Sơn')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-137', N'PV-15', N'Sơn Trà')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-138', N'PV-15', N'Thanh Khê')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-139', N'PV-16', N'Buôn Đôn')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-14', N'PV-2', N'Côn Đảo')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-140', N'PV-16', N'Buôn Hồ')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-141', N'PV-16', N'Buôn Ma Thuột')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-142', N'PV-16', N'Cư Kuin')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-143', N'PV-16', N'Cư M''gar')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-144', N'PV-16', N'Ea H''leo')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-145', N'PV-16', N'Ea Kar')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-146', N'PV-16', N'Ea Súp')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-147', N'PV-16', N'Krông Ana')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-148', N'PV-16', N'Krông Bông')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-149', N'PV-16', N'Krông Búk')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-15', N'PV-2', N'Đất Đỏ')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-150', N'PV-16', N'Krông Năng')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-151', N'PV-16', N'Krông Pắk')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-152', N'PV-16', N'Lắk Đắk Lắk')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-153', N'PV-16', N'M''Đrăk')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-154', N'PV-17', N'Cư Jút')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-155', N'PV-17', N'Đắk Glong')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-156', N'PV-17', N'Đắk Mil')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-157', N'PV-17', N'Đắk R''lấp')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-158', N'PV-17', N'Đắk Song')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-159', N'PV-17', N'Gia Nghĩa')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-16', N'PV-2', N'Long Điền')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-160', N'PV-17', N'Krông Nô')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-161', N'PV-17', N'Tuy Đức')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-162', N'PV-18', N'Điện Biên')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-163', N'PV-18', N'Điện Biên Đông')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-164', N'PV-18', N'Điện Biên Phủ')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-165', N'PV-18', N'Mường Ảng')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-166', N'PV-18', N'Mường Chà')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-167', N'PV-18', N'Mường Lay')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-168', N'PV-18', N'Mường Nhé')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-169', N'PV-18', N'Nậm Pồ')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-17', N'PV-2', N'Phú Mỹ')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-170', N'PV-18', N'Tủa Chùa')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-171', N'PV-18', N'Tuần Giáo')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-172', N'PV-19', N'Biên Hòa')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-173', N'PV-19', N'Cẩm Mỹ')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-174', N'PV-19', N'Định Quán')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-175', N'PV-19', N'Long Khánh')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-176', N'PV-19', N'Long Thành')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-177', N'PV-19', N'Nhơn Trạch')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-178', N'PV-19', N'Tân Phú')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-179', N'PV-19', N'Thống Nhất')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-18', N'PV-2', N'Vũng Tàu')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-180', N'PV-19', N'Trảng Bom')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-181', N'PV-19', N'Vĩnh Cửu')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-182', N'PV-19', N'Xuân Lộc')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-183', N'PV-20', N'Cao Lãnh')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-184', N'PV-20', N'Cao Lãnh')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-185', N'PV-20', N'Châu Thành')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-186', N'PV-20', N'Hồng Ngự')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-187', N'PV-20', N'Hồng Ngự')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-188', N'PV-20', N'Lai Vung')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-189', N'PV-20', N'Lấp Vò')
GO
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-19', N'PV-2', N'Xuyên Mộc')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-190', N'PV-20', N'Sa Đéc')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-191', N'PV-20', N'Tam Nông')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-192', N'PV-20', N'Tân Hồng')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-193', N'PV-20', N'Thanh Bình')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-194', N'PV-20', N'Tháp Mười')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-195', N'PV-21', N'An Khê')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-196', N'PV-21', N'Ayun Pa')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-197', N'PV-21', N'Chư Păh')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-198', N'PV-21', N'Chư Prông')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-199', N'PV-21', N'Chư Pưh')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-2', N'PV-1', N'Châu Đốc')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-20', N'PV-3', N'Bạc Liêu')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-200', N'PV-21', N'Chư Sê')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-201', N'PV-21', N'Đắk Đoa')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-202', N'PV-21', N'Đak Pơ')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-203', N'PV-21', N'Đức Cơ')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-204', N'PV-21', N'Ia Grai')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-205', N'PV-21', N'Ia Pa')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-206', N'PV-21', N'K''Bang')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-207', N'PV-21', N'Kông Chro')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-208', N'PV-21', N'Krông Pa')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-209', N'PV-21', N'Mang Yang')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-21', N'PV-3', N'Đông Hải')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-210', N'PV-21', N'Phú Thiện')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-211', N'PV-21', N'Pleiku')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-212', N'PV-22', N'Bắc Mê')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-213', N'PV-22', N'Bắc Quang')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-214', N'PV-22', N'Đồng Văn')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-215', N'PV-22', N'Hà Giang')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-216', N'PV-22', N'Hoàng Su Phì')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-217', N'PV-22', N'Mèo Vạc')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-218', N'PV-22', N'Quản Bạ')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-219', N'PV-22', N'Quang Bình')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-22', N'PV-3', N'Giá Rai')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-220', N'PV-22', N'Vị Xuyên')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-221', N'PV-22', N'Xín Mần')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-222', N'PV-22', N'Yên Minh')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-223', N'PV-23', N'Bình Lục')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-224', N'PV-23', N'Duy Tiên')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-225', N'PV-23', N'Kim Bảng')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-226', N'PV-23', N'Lý Nhân')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-227', N'PV-23', N'Phủ Lý')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-228', N'PV-23', N'Thanh Liêm')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-229', N'PV-24', N'Ba Đình')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-23', N'PV-3', N'Hoà Bình')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-230', N'PV-24', N'Ba Vì')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-231', N'PV-24', N'Bắc Từ Liêm')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-232', N'PV-24', N'Cầu Giấy')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-233', N'PV-24', N'Chương Mỹ')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-234', N'PV-24', N'Đan Phượng')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-235', N'PV-24', N'Đông Anh')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-236', N'PV-24', N'Đống Đa')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-237', N'PV-24', N'Gia Lâm')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-238', N'PV-24', N'Hà Đông')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-239', N'PV-24', N'Hai Bà Trưng')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-24', N'PV-3', N'Hồng Dân')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-240', N'PV-24', N'Hoài Đức')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-241', N'PV-24', N'Hoàn Kiếm')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-242', N'PV-24', N'Hoàng Mai')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-243', N'PV-24', N'Long Biên')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-244', N'PV-24', N'Mê Linh')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-245', N'PV-24', N'Mỹ Đức')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-246', N'PV-24', N'Nam Từ Liêm')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-247', N'PV-24', N'Phú Xuyên')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-248', N'PV-24', N'Phúc Thọ')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-249', N'PV-24', N'Quốc Oai')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-25', N'PV-3', N'Phước Long')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-250', N'PV-24', N'Sóc Sơn')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-251', N'PV-24', N'Sơn Tây')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-252', N'PV-24', N'Tây Hồ')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-253', N'PV-24', N'Thạch Thất')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-254', N'PV-24', N'Thanh Oai')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-255', N'PV-24', N'Thanh Trì')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-256', N'PV-24', N'Thanh Xuân')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-257', N'PV-24', N'Thường Tín')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-258', N'PV-24', N'Ứng Hòa')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-259', N'PV-25', N'Can Lộc')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-26', N'PV-3', N'Vĩnh Lợi')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-260', N'PV-25', N'Cẩm Xuyên')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-261', N'PV-25', N'Đức Thọ')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-262', N'PV-25', N'Hà Tĩnh')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-263', N'PV-25', N'Hồng Lĩnh')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-264', N'PV-25', N'Hương Khê')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-265', N'PV-25', N'Hương Sơn')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-266', N'PV-25', N'Kỳ Anh')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-267', N'PV-25', N'Kỳ Anh')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-268', N'PV-25', N'Lộc Hà')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-269', N'PV-25', N'Nghi Xuân')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-27', N'PV-4', N'Bắc Giang')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-270', N'PV-25', N'Thạch Hà')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-271', N'PV-25', N'Vũ Quang')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-272', N'PV-26', N'Bình Giang')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-273', N'PV-26', N'Cẩm Giàng')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-274', N'PV-26', N'Chí Linh')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-275', N'PV-26', N'Gia Lộc')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-276', N'PV-26', N'Hải Dương')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-277', N'PV-26', N'Kim Thành')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-278', N'PV-26', N'Kinh Môn')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-279', N'PV-26', N'Nam Sách')
GO
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-28', N'PV-4', N'Hiệp Hòa')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-280', N'PV-26', N'Ninh Giang')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-281', N'PV-26', N'Thanh Hà')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-282', N'PV-26', N'Thanh Miện')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-283', N'PV-26', N'Tứ Kỳ')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-284', N'PV-27', N'An Dương')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-285', N'PV-27', N'An Lão')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-286', N'PV-27', N'Bạch Long Vĩ')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-287', N'PV-27', N'Cát Hải')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-288', N'PV-27', N'Dương Kinh')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-289', N'PV-27', N'Đồ Sơn')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-29', N'PV-4', N'Lạng Giang')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-290', N'PV-27', N'Hải An')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-291', N'PV-27', N'Hồng Bàng')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-292', N'PV-27', N'Kiến An')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-293', N'PV-27', N'Kiến Thụy')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-294', N'PV-27', N'Lê Chân')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-295', N'PV-27', N'Ngô Quyền')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-296', N'PV-27', N'Thủy Nguyên')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-297', N'PV-27', N'Tiên Lãng')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-298', N'PV-27', N'Vĩnh Bảo')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-299', N'PV-28', N'Châu Thành')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-3', N'PV-1', N'Châu Phú')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-30', N'PV-4', N'Lục Nam')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-300', N'PV-28', N'Châu Thành A')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-301', N'PV-28', N'Long Mỹ')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-302', N'PV-28', N'Long Mỹ')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-303', N'PV-28', N'Ngã Bảy')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-304', N'PV-28', N'Phụng Hiệp')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-305', N'PV-28', N'Vị Thanh')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-306', N'PV-28', N'Vị Thủy')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-307', N'PV-29', N'Cao Phong')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-308', N'PV-29', N'Đà Bắc')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-309', N'PV-29', N'Hoà Bình')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-31', N'PV-4', N'Lục Ngạn')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-310', N'PV-29', N'Kim Bôi')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-311', N'PV-29', N'Lạc Sơn')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-312', N'PV-29', N'Lạc Thủy')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-313', N'PV-29', N'Lương Sơn')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-314', N'PV-29', N'Mai Châu')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-315', N'PV-29', N'Tân Lạc')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-316', N'PV-29', N'Yên Thủy')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-317', N'PV-30', N'Ân Thi')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-318', N'PV-30', N'Hưng Yên')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-319', N'PV-30', N'Khoái Châu')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-32', N'PV-4', N'Sơn Động')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-320', N'PV-30', N'Kim Động')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-321', N'PV-30', N'Mỹ Hào')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-322', N'PV-30', N'Phù Cừ')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-323', N'PV-30', N'Tiên Lữ')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-324', N'PV-30', N'Văn Giang')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-325', N'PV-30', N'Văn Lâm')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-326', N'PV-30', N'Yên Mỹ')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-327', N'PV-31', N'Cam Lâm')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-328', N'PV-31', N'Cam Ranh')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-329', N'PV-31', N'Diên Khánh')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-33', N'PV-4', N'Tân Yên')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-330', N'PV-31', N'Khánh Sơn')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-331', N'PV-31', N'Khánh Vĩnh')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-332', N'PV-31', N'Nha Trang')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-333', N'PV-31', N'Ninh Hòa')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-334', N'PV-31', N'Trường Sa')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-335', N'PV-31', N'Vạn Ninh')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-336', N'PV-32', N'An Biên')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-337', N'PV-32', N'An Minh')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-338', N'PV-32', N'Châu Thành')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-339', N'PV-32', N'Giang Thành')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-34', N'PV-4', N'Việt Yên')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-340', N'PV-32', N'Giồng Riềng')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-341', N'PV-32', N'Gò Quao')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-342', N'PV-32', N'Hà Tiên')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-343', N'PV-32', N'Hòn Đất')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-344', N'PV-32', N'Kiên Hải')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-345', N'PV-32', N'Kiên Lương')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-346', N'PV-32', N'Phú Quốc')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-347', N'PV-32', N'Rạch Giá')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-348', N'PV-32', N'Tân Hiệp')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-349', N'PV-32', N'U Minh Thượng')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-35', N'PV-4', N'Yên Dũng')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-350', N'PV-32', N'Vĩnh Thuận')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-351', N'PV-33', N'Đắk Glei')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-352', N'PV-33', N'Đắk Hà')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-353', N'PV-33', N'Đắk Tô')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-354', N'PV-33', N'Ia H''Drai')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-355', N'PV-33', N'Kon Plông')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-356', N'PV-33', N'Kon Rẫy')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-357', N'PV-33', N'Kon Tum')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-358', N'PV-33', N'Ngọc Hồi')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-359', N'PV-33', N'Sa Thầy')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-36', N'PV-4', N'Yên Thế')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-360', N'PV-33', N'Tu Mơ Rông')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-361', N'PV-34', N'Lai Châu')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-362', N'PV-34', N'Mường Tè')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-363', N'PV-34', N'Nậm Nhùn')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-364', N'PV-34', N'Phong Thổ')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-365', N'PV-34', N'Sìn Hồ')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-366', N'PV-34', N'Tam Đường')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-367', N'PV-34', N'Tân Uyên')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-368', N'PV-34', N'Than Uyên')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-369', N'PV-35', N'Bắc Sơn')
GO
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-37', N'PV-5', N'Ba Bể')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-370', N'PV-35', N'Bình Gia')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-371', N'PV-35', N'Cao Lộc')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-372', N'PV-35', N'Chi Lăng')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-373', N'PV-35', N'Đình Lập')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-374', N'PV-35', N'Hữu Lũng')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-375', N'PV-35', N'Lạng Sơn')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-376', N'PV-35', N'Lộc Bình')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-377', N'PV-35', N'Tràng Định')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-378', N'PV-35', N'Văn Lãng')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-379', N'PV-35', N'Văn Quan')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-38', N'PV-5', N'Bạch Thông')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-380', N'PV-36', N'Bảo Thắng')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-381', N'PV-36', N'Bảo Yên')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-382', N'PV-36', N'Bát Xát')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-383', N'PV-36', N'Bắc Hà')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-384', N'PV-36', N'Lào Cai')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-385', N'PV-36', N'Mường Khương')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-386', N'PV-36', N'Sa Pa')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-387', N'PV-36', N'Si Ma Cai')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-388', N'PV-36', N'Văn Bàn')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-389', N'PV-37', N'Bảo Lâm')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-39', N'PV-5', N'Bắc Kạn')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-390', N'PV-37', N'Bảo Lộc')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-391', N'PV-37', N'Cát Tiên')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-392', N'PV-37', N'Di Linh')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-393', N'PV-37', N'Đà Lạt')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-394', N'PV-37', N'Đạ Huoai')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-395', N'PV-37', N'Đạ Tẻh')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-396', N'PV-37', N'Đam Rông')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-397', N'PV-37', N'Đơn Dương')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-398', N'PV-37', N'Đức Trọng')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-399', N'PV-37', N'Lạc Dương')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-4', N'PV-1', N'Châu Thành')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-40', N'PV-5', N'Chợ Đồn')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-400', N'PV-37', N'Lâm Hà')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-401', N'PV-38', N'Bến Lức')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-402', N'PV-38', N'Cần Đước')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-403', N'PV-38', N'Cần Giuộc')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-404', N'PV-38', N'Châu Thành')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-405', N'PV-38', N'Đức Hòa')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-406', N'PV-38', N'Đức Huệ')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-407', N'PV-38', N'Kiến Tường')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-408', N'PV-38', N'Mộc Hóa')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-409', N'PV-38', N'Tân An')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-41', N'PV-5', N'Chợ Mới')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-410', N'PV-38', N'Tân Hưng')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-411', N'PV-38', N'Tân Thạnh')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-412', N'PV-38', N'Tân Trụ')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-413', N'PV-38', N'Thạnh Hóa')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-414', N'PV-38', N'Thủ Thừa')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-415', N'PV-38', N'Vĩnh Hưng')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-416', N'PV-39', N'Giao Thủy')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-417', N'PV-39', N'Hải Hậu')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-418', N'PV-39', N'Mỹ Lộc')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-419', N'PV-39', N'Nam Định')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-42', N'PV-5', N'Na Rì')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-420', N'PV-39', N'Nam Trực')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-421', N'PV-39', N'Nghĩa Hưng')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-422', N'PV-39', N'Trực Ninh')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-423', N'PV-39', N'Vụ Bản')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-424', N'PV-39', N'Xuân Trường')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-425', N'PV-39', N'Ý Yên')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-426', N'PV-40', N'Anh Sơn')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-427', N'PV-40', N'Con Cuông')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-428', N'PV-40', N'Cửa Lò')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-429', N'PV-40', N'Diễn Châu')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-43', N'PV-5', N'Ngân Sơn')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-430', N'PV-40', N'Đô Lương')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-431', N'PV-40', N'Hoàng Mai')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-432', N'PV-40', N'Hưng Nguyên')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-433', N'PV-40', N'Kỳ Sơn')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-434', N'PV-40', N'Nam Đàn')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-435', N'PV-40', N'Nghi Lộc')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-436', N'PV-40', N'Nghĩa Đàn')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-437', N'PV-40', N'Quế Phong')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-438', N'PV-40', N'Quỳ Châu')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-439', N'PV-40', N'Quỳ Hợp')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-44', N'PV-5', N'Pác Nặm')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-440', N'PV-40', N'Quỳnh Lưu')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-441', N'PV-40', N'Tân Kỳ')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-442', N'PV-40', N'Thái Hòa')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-443', N'PV-40', N'Thanh Chương')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-444', N'PV-40', N'Tương Dương')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-445', N'PV-40', N'Vinh')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-446', N'PV-40', N'Yên Thành')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-447', N'PV-41', N'Gia Viễn')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-448', N'PV-41', N'Hoa Lư')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-449', N'PV-41', N'Kim Sơn')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-45', N'PV-6', N'Bắc Ninh')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-450', N'PV-41', N'Nho Quan')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-451', N'PV-41', N'Ninh Bình')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-452', N'PV-41', N'Tam Điệp')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-453', N'PV-41', N'Yên Khánh')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-454', N'PV-41', N'Yên Mô')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-455', N'PV-42', N'Bác Ái')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-456', N'PV-42', N'Ninh Hải')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-457', N'PV-42', N'Ninh Phước')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-458', N'PV-42', N'Ninh Sơn')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-459', N'PV-42', N'Phan Rang-Tháp Chàm')
GO
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-46', N'PV-6', N'Gia Bình')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-460', N'PV-42', N'Thuận Bắc')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-461', N'PV-42', N'Thuận Nam')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-462', N'PV-43', N'Cẩm Khê')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-463', N'PV-43', N'Đoan Hùng')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-464', N'PV-43', N'Hạ Hòa')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-465', N'PV-43', N'Lâm Thao')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-466', N'PV-43', N'Phú Thọ')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-467', N'PV-43', N'Phù Ninh')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-468', N'PV-43', N'Tam Nông')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-469', N'PV-43', N'Tân Sơn')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-47', N'PV-6', N'Lương Tài')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-470', N'PV-43', N'Thanh Ba')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-471', N'PV-43', N'Thanh Sơn')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-472', N'PV-43', N'Thanh Thủy')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-473', N'PV-43', N'Việt Trì')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-474', N'PV-43', N'Yên Lập')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-475', N'PV-44', N'Đông Hòa')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-476', N'PV-44', N'Đồng Xuân')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-477', N'PV-44', N'Phú Hòa')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-478', N'PV-44', N'Sông Cầu')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-479', N'PV-44', N'Sông Hinh')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-48', N'PV-6', N'Quế Võ')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-480', N'PV-44', N'Sơn Hòa')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-481', N'PV-44', N'Tây Hòa')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-482', N'PV-44', N'Tuy An')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-483', N'PV-44', N'Tuy Hòa')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-484', N'PV-45', N'Ba Đồn')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-485', N'PV-45', N'Bố Trạch')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-486', N'PV-45', N'Đồng Hới')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-487', N'PV-45', N'Lệ Thủy')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-488', N'PV-45', N'Minh Hóa')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-489', N'PV-45', N'Quảng Ninh')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-49', N'PV-6', N'Thuận Thành')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-490', N'PV-45', N'Quảng Trạch')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-491', N'PV-45', N'Tuyên Hóa')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-492', N'PV-46', N'Bắc Trà My')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-493', N'PV-46', N'Duy Xuyên')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-494', N'PV-46', N'Đại Lộc')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-495', N'PV-46', N'Điện Bàn')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-496', N'PV-46', N'Đông Giang')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-497', N'PV-46', N'Hiệp Đức')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-498', N'PV-46', N'Hội An')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-499', N'PV-46', N'Nam Giang')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-5', N'PV-1', N'Chợ Mới')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-50', N'PV-6', N'Tiên Du')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-500', N'PV-46', N'Nam Trà My')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-501', N'PV-46', N'Nông Sơn')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-502', N'PV-46', N'Núi Thành')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-503', N'PV-46', N'Phú Ninh')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-504', N'PV-46', N'Phước Sơn')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-505', N'PV-46', N'Quế Sơn')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-506', N'PV-46', N'Tam Kỳ')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-507', N'PV-46', N'Tây Giang')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-508', N'PV-46', N'Thăng Bình')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-509', N'PV-46', N'Tiên Phước')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-51', N'PV-6', N'Từ Sơn')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-510', N'PV-47', N'Ba Tơ')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-511', N'PV-47', N'Bình Sơn')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-512', N'PV-47', N'Đức Phổ')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-513', N'PV-47', N'Lý Sơn')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-514', N'PV-47', N'Minh Long')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-515', N'PV-47', N'Mộ Đức')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-516', N'PV-47', N'Nghĩa Hành')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-517', N'PV-47', N'Quảng Ngãi')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-518', N'PV-47', N'Sơn Hà')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-519', N'PV-47', N'Sơn Tây')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-52', N'PV-6', N'Yên Phong')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-520', N'PV-47', N'Sơn Tịnh')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-521', N'PV-47', N'Trà Bồng')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-522', N'PV-47', N'Tư Nghĩa')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-523', N'PV-48', N'Ba Chẽ')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-524', N'PV-48', N'Bình Liêu')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-525', N'PV-48', N'Cẩm Phả')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-526', N'PV-48', N'Cô Tô')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-527', N'PV-48', N'Đầm Hà')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-528', N'PV-48', N'Đông Triều')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-529', N'PV-48', N'Hạ Long')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-53', N'PV-7', N'Ba Tri')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-530', N'PV-48', N'Hải Hà')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-531', N'PV-48', N'Móng Cái')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-532', N'PV-48', N'Quảng Yên')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-533', N'PV-48', N'Tiên Yên')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-534', N'PV-48', N'Uông Bí')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-535', N'PV-48', N'Vân Đồn')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-536', N'PV-49', N'Cam Lộ')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-537', N'PV-49', N'Cồn Cỏ')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-538', N'PV-49', N'Đa Krông')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-539', N'PV-49', N'Đông Hà')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-54', N'PV-7', N'Bến Tre')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-540', N'PV-49', N'Gio Linh')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-541', N'PV-49', N'Hải Lăng')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-542', N'PV-49', N'Hướng Hóa')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-543', N'PV-49', N'Quảng Trị')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-544', N'PV-49', N'Triệu Phong')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-545', N'PV-49', N'Vĩnh Linh')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-546', N'PV-50', N'Châu Thành')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-547', N'PV-50', N'Cù Lao Dung')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-548', N'PV-50', N'Kế Sách')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-549', N'PV-50', N'Long Phú')
GO
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-55', N'PV-7', N'Bình Đại')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-550', N'PV-50', N'Mỹ Tú')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-551', N'PV-50', N'Mỹ Xuyên')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-552', N'PV-50', N'Ngã Năm')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-553', N'PV-50', N'Sóc Trăng')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-554', N'PV-50', N'Thạnh Trị')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-555', N'PV-50', N'Trần Đề')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-556', N'PV-50', N'Vĩnh Châu')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-557', N'PV-51', N'Bắc Yên')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-558', N'PV-51', N'Mai Sơn')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-559', N'PV-51', N'Mộc Châu')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-56', N'PV-7', N'Châu Thành')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-560', N'PV-51', N'Mường La')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-561', N'PV-51', N'Phù Yên')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-562', N'PV-51', N'Quỳnh Nhai')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-563', N'PV-51', N'Sông Mã')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-564', N'PV-51', N'Sốp Cộp')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-565', N'PV-51', N'Sơn La')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-566', N'PV-51', N'Thuận Châu')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-567', N'PV-51', N'Vân Hồ')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-568', N'PV-51', N'Yên Châu')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-569', N'PV-52', N'Bến Cầu')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-57', N'PV-7', N'Chợ Lách')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-570', N'PV-52', N'Châu Thành')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-571', N'PV-52', N'Dương Minh Châu')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-572', N'PV-52', N'Gò Dầu')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-573', N'PV-52', N'Hòa Thành')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-574', N'PV-52', N'Tân Biên')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-575', N'PV-52', N'Tân Châu')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-576', N'PV-52', N'Tây Ninh')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-577', N'PV-52', N'Trảng Bàng')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-578', N'PV-53', N'Đông Hưng')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-579', N'PV-53', N'Hưng Hà')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-58', N'PV-7', N'Giồng Trôm')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-580', N'PV-53', N'Kiến Xương')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-581', N'PV-53', N'Quỳnh Phụ')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-582', N'PV-53', N'Thái Bình')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-583', N'PV-53', N'Thái Thụy')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-584', N'PV-53', N'Tiền Hải')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-585', N'PV-53', N'Vũ Thư')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-586', N'PV-54', N'Đại Từ')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-587', N'PV-54', N'Định Hóa')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-588', N'PV-54', N'Đồng Hỷ')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-589', N'PV-54', N'Phổ Yên')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-59', N'PV-7', N'Mỏ Cày Bắc')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-590', N'PV-54', N'Phú Bình')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-591', N'PV-54', N'Phú Lương')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-592', N'PV-54', N'Sông Công')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-593', N'PV-54', N'Thái Nguyên')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-594', N'PV-54', N'Võ Nhai')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-595', N'PV-55', N'Bá Thước')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-596', N'PV-55', N'Bỉm Sơn')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-597', N'PV-55', N'Cẩm Thủy')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-598', N'PV-55', N'Đông Sơn')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-599', N'PV-55', N'Hà Trung')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-6', N'PV-1', N'Long Xuyên')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-60', N'PV-7', N'Mỏ Cày Nam')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-600', N'PV-55', N'Hậu Lộc')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-601', N'PV-55', N'Hoằng Hóa')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-602', N'PV-55', N'Lang Chánh')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-603', N'PV-55', N'Mường Lát')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-604', N'PV-55', N'Nga Sơn')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-605', N'PV-55', N'Ngọc Lặc')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-606', N'PV-55', N'Như Thanh')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-607', N'PV-55', N'Như Xuân')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-608', N'PV-55', N'Nông Cống')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-609', N'PV-55', N'Quan Hóa')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-61', N'PV-7', N'Thạnh Phú')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-610', N'PV-55', N'Quan Sơn')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-611', N'PV-55', N'Quảng Xương')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-612', N'PV-55', N'Sầm Sơn')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-613', N'PV-55', N'Thạch Thành')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-614', N'PV-55', N'Thanh Hóa')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-615', N'PV-55', N'Thiệu Hóa')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-616', N'PV-55', N'Thọ Xuân')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-617', N'PV-55', N'Thường Xuân')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-618', N'PV-55', N'Tĩnh Gia')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-619', N'PV-55', N'Triệu Sơn')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-62', N'PV-8', N'Bàu Bàng')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-620', N'PV-55', N'Vĩnh Lộc')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-621', N'PV-55', N'Yên Định')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-622', N'PV-56', N'A Lưới')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-623', N'PV-56', N'Huế')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-624', N'PV-56', N'Hương Thủy')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-625', N'PV-56', N'Hương Trà')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-626', N'PV-56', N'Nam Đông')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-627', N'PV-56', N'Phong Điền')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-628', N'PV-56', N'Phú Lộc')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-629', N'PV-56', N'Phú Vang')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-63', N'PV-8', N'Bắc Tân Uyên')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-630', N'PV-56', N'Quảng Điền')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-631', N'PV-57', N'Cai Lậy')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-632', N'PV-57', N'Cai Lậy')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-633', N'PV-57', N'Cái Bè')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-634', N'PV-57', N'Châu Thành')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-635', N'PV-57', N'Chợ Gạo')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-636', N'PV-57', N'Gò Công')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-637', N'PV-57', N'Gò Công Đông')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-638', N'PV-57', N'Gò Công Tây')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-639', N'PV-57', N'Mỹ Tho')
GO
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-64', N'PV-8', N'Bến Cát')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-640', N'PV-57', N'Tân Phú Đông')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-641', N'PV-57', N'Tân Phước')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-642', N'PV-58', N'Bình Chánh')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-643', N'PV-58', N'Bình Tân')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-644', N'PV-58', N'Bình Thạnh')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-645', N'PV-58', N'Cần Giờ')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-646', N'PV-58', N'Củ Chi')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-647', N'PV-58', N'Gò Vấp')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-648', N'PV-58', N'Hóc Môn')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-649', N'PV-58', N'Nhà Bè')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-65', N'PV-8', N'Dầu Tiếng')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-650', N'PV-58', N'Phú Nhuận')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-651', N'PV-58', N'Quận 1')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-652', N'PV-58', N'Quận 2')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-653', N'PV-58', N'Quận 3')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-654', N'PV-58', N'Quận 4')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-655', N'PV-58', N'Quận 5')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-656', N'PV-58', N'Quận 6')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-657', N'PV-58', N'Quận 7')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-658', N'PV-58', N'Quận 8')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-659', N'PV-58', N'Quận 9')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-66', N'PV-8', N'Dĩ An')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-660', N'PV-58', N'Quận 10')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-661', N'PV-58', N'Quận 11')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-662', N'PV-58', N'Quận 12')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-663', N'PV-58', N'Tân Bình')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-664', N'PV-58', N'Tân Phú')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-665', N'PV-58', N'Thủ Đức')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-666', N'PV-59', N'Càng Long')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-667', N'PV-59', N'Cầu Kè')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-668', N'PV-59', N'Cầu Ngang')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-669', N'PV-59', N'Châu Thành')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-67', N'PV-8', N'Phú Giáo')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-670', N'PV-59', N'Duyên Hải')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-671', N'PV-59', N'Duyên Hải')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-672', N'PV-59', N'Tiểu Cần')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-673', N'PV-59', N'Trà Cú')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-674', N'PV-59', N'Trà Vinh')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-675', N'PV-60', N'Chiêm Hóa')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-676', N'PV-60', N'Hàm Yên')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-677', N'PV-60', N'Lâm Bình')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-678', N'PV-60', N'Na Hang')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-679', N'PV-60', N'Sơn Dương')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-68', N'PV-8', N'Tân Uyên')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-680', N'PV-60', N'Tuyên Quang')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-681', N'PV-60', N'Yên Sơn')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-682', N'PV-61', N'Bình Minh')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-683', N'PV-61', N'Bình Tân')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-684', N'PV-61', N'Long Hồ')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-685', N'PV-61', N'Mang Thít')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-686', N'PV-61', N'Tam Bình')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-687', N'PV-61', N'Trà Ôn')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-688', N'PV-61', N'Vĩnh Long')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-689', N'PV-61', N'Vũng Liêm')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-69', N'PV-8', N'Thủ Dầu Một')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-690', N'PV-62', N'Bình Xuyên')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-691', N'PV-62', N'Lập Thạch')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-692', N'PV-62', N'Phúc Yên')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-693', N'PV-62', N'Sông Lô')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-694', N'PV-62', N'Tam Dương')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-695', N'PV-62', N'Tam Đảo')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-696', N'PV-62', N'Vĩnh Tường')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-697', N'PV-62', N'Vĩnh Yên')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-698', N'PV-62', N'Yên Lạc')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-699', N'PV-63', N'Lục Yên')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-7', N'PV-1', N'Phú Tân')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-70', N'PV-8', N'Thuận An')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-700', N'PV-63', N'Mù Cang Chải')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-701', N'PV-63', N'Nghĩa Lộ')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-702', N'PV-63', N'Trạm Tấu')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-703', N'PV-63', N'Trấn Yên')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-704', N'PV-63', N'Văn Chấn')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-705', N'PV-63', N'Văn Yên')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-706', N'PV-63', N'Yên Bái')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-707', N'PV-63', N'Yên Bình')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-71', N'PV-9', N'An Lão')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-72', N'PV-9', N'An Nhơn')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-73', N'PV-9', N'Hoài Ân')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-74', N'PV-9', N'Hoài Nhơn')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-75', N'PV-9', N'Phù Cát')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-76', N'PV-9', N'Phù Mỹ')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-77', N'PV-9', N'Quy Nhơn')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-78', N'PV-9', N'Tây Sơn')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-79', N'PV-9', N'Tuy Phước')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-8', N'PV-1', N'Tân Châu')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-80', N'PV-9', N'Vân Canh')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-81', N'PV-9', N'Vĩnh Thạnh')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-82', N'PV-10', N'Bình Long')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-83', N'PV-10', N'Bù Đăng')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-84', N'PV-10', N'Bù Đốp')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-85', N'PV-10', N'Bù Gia Mập')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-86', N'PV-10', N'Chơn Thành')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-87', N'PV-10', N'Đồng Phú')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-88', N'PV-10', N'Đồng Xoài')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-89', N'PV-10', N'Hớn Quản')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-9', N'PV-1', N'Thoại Sơn')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-90', N'PV-10', N'Lộc Ninh')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-91', N'PV-10', N'Phú Riềng')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-92', N'PV-10', N'Phước Long')
GO
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-93', N'PV-11', N'Bắc Bình')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-94', N'PV-11', N'Đức Linh')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-95', N'PV-11', N'Hàm Tân')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-96', N'PV-11', N'Hàm Thuận Bắc')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-97', N'PV-11', N'Hàm Thuận Nam')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-98', N'PV-11', N'La Gi')
INSERT [dbo].[District] ([DistrictID], [ProvinceID], [DistrictName]) VALUES (N'DT-99', N'PV-11', N'Phan Thiết')
INSERT [dbo].[Product] ([ProductID], [Name], [Color], [CategoryID], [Description], [Image], [Price], [IsDeleted], [DiscountPercent], [ImportDate]) VALUES (N'PR-1', N'Áo khoác nam A1', N'#000000', N'CT5', N'100%cotton
Giặt máy ở chế độ nhẹ nhàng, nhiệt độ thông thường
Sử dụng hóa chất tẩy không có chất Clo
Sấy khô ở nhiệt độ thấp 110°, là ở nhiệt độ trung bình 150°
Giặt với sản phẩm cùng màu
Nên phơi vắt ngang', N'http://localhost:62098/images/PR-1.png', 699000, 0, 0, CAST(N'2020-04-09' AS Date))
INSERT [dbo].[Product] ([ProductID], [Name], [Color], [CategoryID], [Description], [Image], [Price], [IsDeleted], [DiscountPercent], [ImportDate]) VALUES (N'PR-10', N'Áo sơ mi trơn xám', N'#000000', N'CT4', NULL, N'http://localhost:62098/images/PR-10.png', 700000, 0, 0, CAST(N'2020-04-09' AS Date))
INSERT [dbo].[Product] ([ProductID], [Name], [Color], [CategoryID], [Description], [Image], [Price], [IsDeleted], [DiscountPercent], [ImportDate]) VALUES (N'PR-11', N'Quần jean xanh đậm nhạt', N'#000000', N'CT10', NULL, N'http://localhost:62098/images/PR-11.png', 100000, 0, 10, CAST(N'2020-04-09' AS Date))
INSERT [dbo].[Product] ([ProductID], [Name], [Color], [CategoryID], [Description], [Image], [Price], [IsDeleted], [DiscountPercent], [ImportDate]) VALUES (N'PR-12', N'Quần jean lam xé nhẹ', N'#000000', N'CT10', NULL, N'http://localhost:62098/images/PR-12.png', 120000, 0, 0, CAST(N'2020-04-09' AS Date))
INSERT [dbo].[Product] ([ProductID], [Name], [Color], [CategoryID], [Description], [Image], [Price], [IsDeleted], [DiscountPercent], [ImportDate]) VALUES (N'PR-13', N'Quần jean xanh nhạt', N'#000000', N'CT10', NULL, N'http://localhost:62098/images/PR-13.png', 170000, 0, 0, CAST(N'2020-04-09' AS Date))
INSERT [dbo].[Product] ([ProductID], [Name], [Color], [CategoryID], [Description], [Image], [Price], [IsDeleted], [DiscountPercent], [ImportDate]) VALUES (N'PR-14', N'Áo sơ mi caro xanh đen', N'#000000', N'CT4', NULL, N'http://localhost:62098/images/PR-14.png', 210000, 0, 15, CAST(N'2020-04-09' AS Date))
INSERT [dbo].[Product] ([ProductID], [Name], [Color], [CategoryID], [Description], [Image], [Price], [IsDeleted], [DiscountPercent], [ImportDate]) VALUES (N'PR-15', N'Áo khoác Nian Jeep - Màu Kaki', N'#000000', N'CT5', NULL, N'http://localhost:62098/images/PR-15.png', 400000, 0, 10, CAST(N'2020-04-09' AS Date))
INSERT [dbo].[Product] ([ProductID], [Name], [Color], [CategoryID], [Description], [Image], [Price], [IsDeleted], [DiscountPercent], [ImportDate]) VALUES (N'PR-16', N'Áo thun âm nhạc', N'#000000', N'CT3', NULL, N'http://localhost:62098/images/PR-16.png', 500000, 0, 0, CAST(N'2020-04-09' AS Date))
INSERT [dbo].[Product] ([ProductID], [Name], [Color], [CategoryID], [Description], [Image], [Price], [IsDeleted], [DiscountPercent], [ImportDate]) VALUES (N'PR-17', N'Áo phông "NO PAIN NO GAIN"', N'#000000', N'CT3', NULL, N'http://localhost:62098/images/PR-17.png', 190000, 0, 0, CAST(N'2020-04-09' AS Date))
INSERT [dbo].[Product] ([ProductID], [Name], [Color], [CategoryID], [Description], [Image], [Price], [IsDeleted], [DiscountPercent], [ImportDate]) VALUES (N'PR-18', N'', N'#000000', N'CT1', NULL, N'http://localhost:62098/images/PR-18.png', 0, 1, 20, CAST(N'2020-04-09' AS Date))
INSERT [dbo].[Product] ([ProductID], [Name], [Color], [CategoryID], [Description], [Image], [Price], [IsDeleted], [DiscountPercent], [ImportDate]) VALUES (N'PR-19', N'Áo khoác Captain Marvel', N'#000000', N'CT7', NULL, N'http://localhost:62098/images/PR-19.png', 500000, 0, 0, CAST(N'2020-04-09' AS Date))
INSERT [dbo].[Product] ([ProductID], [Name], [Color], [CategoryID], [Description], [Image], [Price], [IsDeleted], [DiscountPercent], [ImportDate]) VALUES (N'PR-2', N'Áo sơ mi caro trắng - xanh đậm', N'#ff0000', N'CT4', N'Đây là áo của team SKT', N'http://localhost:62098/images/PR-2.png', 600000, 0, 0, CAST(N'2020-04-09' AS Date))
INSERT [dbo].[Product] ([ProductID], [Name], [Color], [CategoryID], [Description], [Image], [Price], [IsDeleted], [DiscountPercent], [ImportDate]) VALUES (N'PR-20', N'Áo phông nữ sọc ngang', NULL, N'CT14', NULL, N'http://localhost:62098/images/PR-20.png', 400000, 0, 0, CAST(N'2020-04-09' AS Date))
INSERT [dbo].[Product] ([ProductID], [Name], [Color], [CategoryID], [Description], [Image], [Price], [IsDeleted], [DiscountPercent], [ImportDate]) VALUES (N'PR-21', N'Áo thun UFC', NULL, N'CT3', NULL, N'http://localhost:62098/images/PR-21.png', 150000, 0, 0, CAST(N'2020-04-09' AS Date))
INSERT [dbo].[Product] ([ProductID], [Name], [Color], [CategoryID], [Description], [Image], [Price], [IsDeleted], [DiscountPercent], [ImportDate]) VALUES (N'PR-22', N'Áo phông nữ trắng', NULL, N'CT14', NULL, N'http://localhost:62098/images/PR-22.png', 175000, 0, 0, CAST(N'2020-04-09' AS Date))
INSERT [dbo].[Product] ([ProductID], [Name], [Color], [CategoryID], [Description], [Image], [Price], [IsDeleted], [DiscountPercent], [ImportDate]) VALUES (N'PR-23', N'Áo khoác len', NULL, N'CT5', NULL, N'http://localhost:62098/images/PR-23.png', 500000, 0, 0, CAST(N'2020-04-09' AS Date))
INSERT [dbo].[Product] ([ProductID], [Name], [Color], [CategoryID], [Description], [Image], [Price], [IsDeleted], [DiscountPercent], [ImportDate]) VALUES (N'PR-24', N'Áo phông batch 2003', NULL, N'CT3', NULL, N'http://localhost:62098/images/PR-24.png', 200000, 0, 0, CAST(N'2020-04-09' AS Date))
INSERT [dbo].[Product] ([ProductID], [Name], [Color], [CategoryID], [Description], [Image], [Price], [IsDeleted], [DiscountPercent], [ImportDate]) VALUES (N'PR-25', N'Áo freepik đen', NULL, N'CT3', NULL, N'http://localhost:62098/images/PR-25.png', 150000, 0, 0, CAST(N'2020-04-09' AS Date))
INSERT [dbo].[Product] ([ProductID], [Name], [Color], [CategoryID], [Description], [Image], [Price], [IsDeleted], [DiscountPercent], [ImportDate]) VALUES (N'PR-26', N'Áo khoác da trơn đen', NULL, N'CT5', NULL, N'http://localhost:62098/images/PR-26.png', 250000, 0, 0, CAST(N'2020-04-09' AS Date))
INSERT [dbo].[Product] ([ProductID], [Name], [Color], [CategoryID], [Description], [Image], [Price], [IsDeleted], [DiscountPercent], [ImportDate]) VALUES (N'PR-27', N'Áo khoác len xám có họa tiết', NULL, N'CT5', NULL, N'http://localhost:62098/images/PR-27.png', 165000, 0, 0, CAST(N'2020-04-09' AS Date))
INSERT [dbo].[Product] ([ProductID], [Name], [Color], [CategoryID], [Description], [Image], [Price], [IsDeleted], [DiscountPercent], [ImportDate]) VALUES (N'PR-28', N'Đầm hoa vải trơn', NULL, N'CT17', NULL, N'http://localhost:62098/images/PR-28.png', 235000, 0, 0, CAST(N'2020-04-09' AS Date))
INSERT [dbo].[Product] ([ProductID], [Name], [Color], [CategoryID], [Description], [Image], [Price], [IsDeleted], [DiscountPercent], [ImportDate]) VALUES (N'PR-29', N'Đầm len xám', NULL, N'CT17', NULL, N'http://localhost:62098/images/PR-29.png', 315000, 0, 0, CAST(N'2020-04-09' AS Date))
INSERT [dbo].[Product] ([ProductID], [Name], [Color], [CategoryID], [Description], [Image], [Price], [IsDeleted], [DiscountPercent], [ImportDate]) VALUES (N'PR-3', N'Áo phông nữ "ADVENTURE"', N'#000000', N'CT14', N'', N'http://localhost:62098/images/PR-3.png', 600000, 0, 30, CAST(N'2020-04-09' AS Date))
INSERT [dbo].[Product] ([ProductID], [Name], [Color], [CategoryID], [Description], [Image], [Price], [IsDeleted], [DiscountPercent], [ImportDate]) VALUES (N'PR-30', N'Đầm đỏ vải trơn', NULL, N'CT17', NULL, N'http://localhost:62098/images/PR-30.png', 245000, 0, 10, CAST(N'2020-04-09' AS Date))
INSERT [dbo].[Product] ([ProductID], [Name], [Color], [CategoryID], [Description], [Image], [Price], [IsDeleted], [DiscountPercent], [ImportDate]) VALUES (N'PR-31', N'Áo polo cốm xanh cam', NULL, N'CT11', NULL, N'http://localhost:62098/images/PR-31.png', 175000, 0, 0, CAST(N'2020-04-09' AS Date))
INSERT [dbo].[Product] ([ProductID], [Name], [Color], [CategoryID], [Description], [Image], [Price], [IsDeleted], [DiscountPercent], [ImportDate]) VALUES (N'PR-32', N'Áo polo xám', NULL, N'CT11', NULL, N'http://localhost:62098/images/PR-32.png', 130000, 0, 0, CAST(N'2020-04-09' AS Date))
INSERT [dbo].[Product] ([ProductID], [Name], [Color], [CategoryID], [Description], [Image], [Price], [IsDeleted], [DiscountPercent], [ImportDate]) VALUES (N'PR-33', N'Áo polo xanh viền trắng', NULL, N'CT11', NULL, N'http://localhost:62098/images/PR-33.png', 750000, 0, 0, CAST(N'2020-04-09' AS Date))
INSERT [dbo].[Product] ([ProductID], [Name], [Color], [CategoryID], [Description], [Image], [Price], [IsDeleted], [DiscountPercent], [ImportDate]) VALUES (N'PR-34', N'Áo nháp', NULL, N'CT13', NULL, N'http://localhost:62098/images/PR-34.png', 1111111, 0, 0, CAST(N'2020-04-09' AS Date))
INSERT [dbo].[Product] ([ProductID], [Name], [Color], [CategoryID], [Description], [Image], [Price], [IsDeleted], [DiscountPercent], [ImportDate]) VALUES (N'PR-35', N'Quần short đại bàng', NULL, N'CT12', NULL, N'http://localhost:62098/images/PR-35.png', 190000, 0, 0, CAST(N'2020-04-09' AS Date))
INSERT [dbo].[Product] ([ProductID], [Name], [Color], [CategoryID], [Description], [Image], [Price], [IsDeleted], [DiscountPercent], [ImportDate]) VALUES (N'PR-36', N'Quần short đen gấp ống', NULL, N'CT12', NULL, N'http://localhost:62098/images/PR-36.png', 450000, 0, 20, CAST(N'2020-04-09' AS Date))
INSERT [dbo].[Product] ([ProductID], [Name], [Color], [CategoryID], [Description], [Image], [Price], [IsDeleted], [DiscountPercent], [ImportDate]) VALUES (N'PR-37', N'Quần chạy bộ kalenji', NULL, N'CT12', NULL, N'http://localhost:62098/images/PR-37.png', 80000, 0, 0, CAST(N'2020-04-09' AS Date))
INSERT [dbo].[Product] ([ProductID], [Name], [Color], [CategoryID], [Description], [Image], [Price], [IsDeleted], [DiscountPercent], [ImportDate]) VALUES (N'PR-38', N'Áo khoác nữ kaki trắng', NULL, N'CT7', NULL, N'http://localhost:62098/images/PR-38.png', 600000, 0, 0, CAST(N'2020-04-09' AS Date))
INSERT [dbo].[Product] ([ProductID], [Name], [Color], [CategoryID], [Description], [Image], [Price], [IsDeleted], [DiscountPercent], [ImportDate]) VALUES (N'PR-39', N'Áo khoác À', NULL, N'CT5', NULL, N'http://localhost:62098/images/PR-39.png', 100000, 0, 0, CAST(N'2020-04-09' AS Date))
INSERT [dbo].[Product] ([ProductID], [Name], [Color], [CategoryID], [Description], [Image], [Price], [IsDeleted], [DiscountPercent], [ImportDate]) VALUES (N'PR-4', N'Áo khoác nữ kaki xanh nhạt', N'#0080ff', N'CT7', NULL, N'http://localhost:62098/images/PR-4.png', 900000, 0, 10, CAST(N'2020-04-09' AS Date))
INSERT [dbo].[Product] ([ProductID], [Name], [Color], [CategoryID], [Description], [Image], [Price], [IsDeleted], [DiscountPercent], [ImportDate]) VALUES (N'PR-40', N'Áo gì đó', NULL, N'CT5', NULL, N'http://localhost:62098/images/PR-40.png', 60000, 0, 0, CAST(N'2020-04-09' AS Date))
INSERT [dbo].[Product] ([ProductID], [Name], [Color], [CategoryID], [Description], [Image], [Price], [IsDeleted], [DiscountPercent], [ImportDate]) VALUES (N'PR-41', N'Áo con vịt', NULL, N'CT3', NULL, N'http://localhost:62098/images/PR-41.png', 10000, 0, 0, CAST(N'2020-04-09' AS Date))
INSERT [dbo].[Product] ([ProductID], [Name], [Color], [CategoryID], [Description], [Image], [Price], [IsDeleted], [DiscountPercent], [ImportDate]) VALUES (N'PR-42', N'Áo đỏ', NULL, N'CT11', NULL, N'http://localhost:62098/images/PR-42.png', 10000, 1, 5, CAST(N'2020-04-09' AS Date))
INSERT [dbo].[Product] ([ProductID], [Name], [Color], [CategoryID], [Description], [Image], [Price], [IsDeleted], [DiscountPercent], [ImportDate]) VALUES (N'PR-43', N'Áo khoác đỏ', NULL, N'CT5', NULL, N'http://localhost:62098/images/PR-43.png', 56000, 0, 0, CAST(N'2020-04-09' AS Date))
INSERT [dbo].[Product] ([ProductID], [Name], [Color], [CategoryID], [Description], [Image], [Price], [IsDeleted], [DiscountPercent], [ImportDate]) VALUES (N'PR-44', N'Áo phông pique 02', NULL, N'CT3', NULL, N'http://localhost:62098/images/PR-44.png', 450000, 0, 0, CAST(N'2020-04-09' AS Date))
INSERT [dbo].[Product] ([ProductID], [Name], [Color], [CategoryID], [Description], [Image], [Price], [IsDeleted], [DiscountPercent], [ImportDate]) VALUES (N'PR-45', N'Áo siêu ngầu', NULL, N'CT4', NULL, N'http://localhost:62098/images/PR-45.png', 700000, 0, 15, CAST(N'2020-04-09' AS Date))
INSERT [dbo].[Product] ([ProductID], [Name], [Color], [CategoryID], [Description], [Image], [Price], [IsDeleted], [DiscountPercent], [ImportDate]) VALUES (N'PR-46', N'Áo phông nam họa tiết lá phong', NULL, N'CT3', NULL, N'http://localhost:62098/images/PR-46.png', 399000, 0, 0, CAST(N'0001-01-01' AS Date))
INSERT [dbo].[Product] ([ProductID], [Name], [Color], [CategoryID], [Description], [Image], [Price], [IsDeleted], [DiscountPercent], [ImportDate]) VALUES (N'PR-5', N'Chân váy jean xanh nhạt', N'#000000', N'CT16', NULL, N'http://localhost:62098/images/PR-5.png', 300000, 0, 0, CAST(N'2020-04-09' AS Date))
INSERT [dbo].[Product] ([ProductID], [Name], [Color], [CategoryID], [Description], [Image], [Price], [IsDeleted], [DiscountPercent], [ImportDate]) VALUES (N'PR-6', N'Chân váy trơn đen', N'#ff80ff', N'CT16', NULL, N'http://localhost:62098/images/PR-6.png', 700000, 0, 0, CAST(N'2020-04-09' AS Date))
INSERT [dbo].[Product] ([ProductID], [Name], [Color], [CategoryID], [Description], [Image], [Price], [IsDeleted], [DiscountPercent], [ImportDate]) VALUES (N'PR-7', N'Chân váy xẻ 1 bên', N'#000000', N'CT16', NULL, N'http://localhost:62098/images/PR-7.png', 500000, 0, 0, CAST(N'2020-04-09' AS Date))
INSERT [dbo].[Product] ([ProductID], [Name], [Color], [CategoryID], [Description], [Image], [Price], [IsDeleted], [DiscountPercent], [ImportDate]) VALUES (N'PR-8', N'Áo thun nam đen có chữ', N'#000000', N'CT3', NULL, N'http://localhost:62098/images/PR-8.png', 250000, 0, 0, CAST(N'2020-04-09' AS Date))
INSERT [dbo].[Product] ([ProductID], [Name], [Color], [CategoryID], [Description], [Image], [Price], [IsDeleted], [DiscountPercent], [ImportDate]) VALUES (N'PR-9', N'Áo thun nam xanh biển', N'#000000', N'CT3', NULL, N'http://localhost:62098/images/PR-9.png', 300000, 0, 10, CAST(N'2020-04-09' AS Date))
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-1', N'L', 14)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-1', N'M', 0)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-1', N'S', 7)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-1', N'XL', 18)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-1', N'XXL', 9)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-10', N'L', 0)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-10', N'M', 5)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-10', N'S', 4)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-10', N'XL', 2)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-10', N'XXL', 0)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-11', N'L', 5)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-11', N'M', 3)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-11', N'S', 1)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-11', N'XL', 7)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-11', N'XXL', 6)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-12', N'L', 11)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-12', N'M', 8)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-12', N'S', 12)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-12', N'XL', 9)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-12', N'XXL', 7)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-13', N'L', 4)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-13', N'M', 3)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-13', N'S', 5)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-13', N'XL', 8)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-13', N'XXL', 2)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-14', N'L', 17)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-14', N'M', 20)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-14', N'S', 30)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-14', N'XL', 17)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-14', N'XXL', 15)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-15', N'L', 15)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-15', N'M', 7)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-15', N'S', 10)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-15', N'XL', 7)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-15', N'XXL', 4)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-16', N'L', 0)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-16', N'M', 5)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-16', N'S', 14)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-16', N'XL', 4)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-16', N'XXL', 8)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-17', N'L', 3)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-17', N'M', 3)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-17', N'S', 9)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-17', N'XL', 0)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-17', N'XXL', 7)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-18', N'L', 0)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-18', N'M', 0)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-18', N'S', 0)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-18', N'XL', 0)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-18', N'XXL', 0)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-19', N'L', 0)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-19', N'M', 0)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-19', N'S', 0)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-19', N'XL', 0)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-19', N'XXL', 0)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-2', N'L', 6)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-2', N'M', 6)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-2', N'S', 10)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-2', N'XL', 1)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-2', N'XXL', 3)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-20', N'L', 0)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-20', N'M', 3)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-20', N'S', 3)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-20', N'XL', 6)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-20', N'XXL', 4)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-21', N'L', 0)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-21', N'M', 0)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-21', N'S', 0)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-21', N'XL', 0)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-21', N'XXL', 0)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-22', N'L', 20)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-22', N'M', 20)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-22', N'S', 20)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-22', N'XL', 20)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-22', N'XXL', 20)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-23', N'L', 7)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-23', N'M', 5)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-23', N'S', 18)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-23', N'XL', 9)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-23', N'XXL', 5)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-24', N'L', 10)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-24', N'M', 15)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-24', N'S', 10)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-24', N'XL', 5)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-24', N'XXL', 3)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-25', N'L', 15)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-25', N'M', 10)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-25', N'S', 5)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-25', N'XL', 0)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-25', N'XXL', 0)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-26', N'L', 0)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-26', N'M', 0)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-26', N'S', 0)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-26', N'XL', 0)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-26', N'XXL', 0)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-27', N'L', 13)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-27', N'M', 14)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-27', N'S', 15)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-27', N'XL', 12)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-27', N'XXL', 0)
GO
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-28', N'L', 13)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-28', N'M', 16)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-28', N'S', 9)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-28', N'XL', 18)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-28', N'XXL', 2)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-29', N'L', 22)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-29', N'M', 30)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-29', N'S', 21)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-29', N'XL', 12)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-29', N'XXL', 5)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-3', N'L', 200)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-3', N'M', 79)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-3', N'S', 100)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-3', N'XL', 15)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-3', N'XXL', 900)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-30', N'L', 11)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-30', N'M', 13)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-30', N'S', 14)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-30', N'XL', 6)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-30', N'XXL', 7)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-31', N'L', 4)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-31', N'M', 14)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-31', N'S', 16)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-31', N'XL', 3)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-31', N'XXL', 5)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-32', N'L', 0)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-32', N'M', 0)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-32', N'S', 0)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-32', N'XL', 0)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-32', N'XXL', 0)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-33', N'L', 0)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-33', N'M', 0)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-33', N'S', 0)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-33', N'XL', 0)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-33', N'XXL', 0)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-34', N'L', 0)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-34', N'M', 0)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-34', N'S', 0)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-34', N'XL', 0)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-34', N'XXL', 0)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-35', N'L', 25)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-35', N'M', 30)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-35', N'S', 15)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-35', N'XL', 16)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-35', N'XXL', 24)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-36', N'L', 18)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-36', N'M', 16)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-36', N'S', 15)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-36', N'XL', 20)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-36', N'XXL', 12)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-37', N'L', 24)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-37', N'M', 23)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-37', N'S', 22)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-37', N'XL', 25)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-37', N'XXL', 26)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-38', N'L', 0)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-38', N'M', 0)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-38', N'S', 0)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-38', N'XL', 0)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-38', N'XXL', 0)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-39', N'L', 0)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-39', N'M', 34)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-39', N'S', 12)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-39', N'XL', 0)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-39', N'XXL', 0)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-4', N'L', 16)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-4', N'M', 13)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-4', N'S', 10)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-4', N'XL', 17)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-4', N'XXL', 18)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-40', N'L', 3)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-40', N'M', 2)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-40', N'S', 1)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-40', N'XL', 4)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-40', N'XXL', 5)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-41', N'L', 0)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-41', N'M', 0)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-41', N'S', 4)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-41', N'XL', 0)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-41', N'XXL', 0)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-42', N'L', 0)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-42', N'M', 2)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-42', N'S', 1)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-42', N'XL', 0)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-42', N'XXL', 0)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-43', N'L', 0)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-43', N'M', 5)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-43', N'S', 0)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-43', N'XL', 0)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-43', N'XXL', 0)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-44', N'L', 8)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-44', N'M', 5)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-44', N'S', 8)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-44', N'XL', 8)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-44', N'XXL', 0)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-45', N'L', 0)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-45', N'M', 5)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-45', N'S', 0)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-45', N'XL', 0)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-45', N'XXL', 0)
GO
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-46', N'L', 16)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-46', N'M', 14)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-46', N'S', 12)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-46', N'XL', 17)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-46', N'XXL', 0)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-5', N'L', 12)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-5', N'M', 11)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-5', N'S', 10)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-5', N'XL', 9)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-5', N'XXL', 8)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-6', N'L', 18)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-6', N'M', 15)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-6', N'S', 20)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-6', N'XL', 26)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-6', N'XXL', 0)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-7', N'L', 5)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-7', N'M', 3)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-7', N'S', 1)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-7', N'XL', 7)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-7', N'XXL', 9)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-8', N'L', 10)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-8', N'M', 30)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-8', N'S', 12)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-8', N'XL', 20)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-8', N'XXL', 5)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-9', N'L', 5)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-9', N'M', 10)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-9', N'S', 5)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-9', N'XL', 2)
INSERT [dbo].[Product_Size_Quantity] ([ProductID], [Size], [Quantity]) VALUES (N'PR-9', N'XXL', 3)
INSERT [dbo].[Province] ([ProvinceID], [ProvinceName], [DeliveryFee]) VALUES (N'PV-1', N'An Giang', 10000)
INSERT [dbo].[Province] ([ProvinceID], [ProvinceName], [DeliveryFee]) VALUES (N'PV-10', N'Bình Phước', 0)
INSERT [dbo].[Province] ([ProvinceID], [ProvinceName], [DeliveryFee]) VALUES (N'PV-11', N'Bình Thuận', 0)
INSERT [dbo].[Province] ([ProvinceID], [ProvinceName], [DeliveryFee]) VALUES (N'PV-12', N'Cà Mau', 0)
INSERT [dbo].[Province] ([ProvinceID], [ProvinceName], [DeliveryFee]) VALUES (N'PV-13', N'Cao Bằng', 0)
INSERT [dbo].[Province] ([ProvinceID], [ProvinceName], [DeliveryFee]) VALUES (N'PV-14', N'Cần Thơ', 0)
INSERT [dbo].[Province] ([ProvinceID], [ProvinceName], [DeliveryFee]) VALUES (N'PV-15', N'Đà Nẵng', 0)
INSERT [dbo].[Province] ([ProvinceID], [ProvinceName], [DeliveryFee]) VALUES (N'PV-16', N'Đắk Lắk', 0)
INSERT [dbo].[Province] ([ProvinceID], [ProvinceName], [DeliveryFee]) VALUES (N'PV-17', N'Đăk Nông', 0)
INSERT [dbo].[Province] ([ProvinceID], [ProvinceName], [DeliveryFee]) VALUES (N'PV-18', N'Điện Biên	', 0)
INSERT [dbo].[Province] ([ProvinceID], [ProvinceName], [DeliveryFee]) VALUES (N'PV-19', N'Đồng Nai', 0)
INSERT [dbo].[Province] ([ProvinceID], [ProvinceName], [DeliveryFee]) VALUES (N'PV-2', N'Bà Rịa-Vũng Tàu', 10000)
INSERT [dbo].[Province] ([ProvinceID], [ProvinceName], [DeliveryFee]) VALUES (N'PV-20', N'Đồng Tháp', 0)
INSERT [dbo].[Province] ([ProvinceID], [ProvinceName], [DeliveryFee]) VALUES (N'PV-21', N'Gia Lai', 0)
INSERT [dbo].[Province] ([ProvinceID], [ProvinceName], [DeliveryFee]) VALUES (N'PV-22', N'Hà Giang', 0)
INSERT [dbo].[Province] ([ProvinceID], [ProvinceName], [DeliveryFee]) VALUES (N'PV-23', N'Hà Nam', 0)
INSERT [dbo].[Province] ([ProvinceID], [ProvinceName], [DeliveryFee]) VALUES (N'PV-24', N'Hà Nội', 0)
INSERT [dbo].[Province] ([ProvinceID], [ProvinceName], [DeliveryFee]) VALUES (N'PV-25', N'Hà Tĩnh', 0)
INSERT [dbo].[Province] ([ProvinceID], [ProvinceName], [DeliveryFee]) VALUES (N'PV-26', N'Hải Dương', 0)
INSERT [dbo].[Province] ([ProvinceID], [ProvinceName], [DeliveryFee]) VALUES (N'PV-27', N'Hải Phòng', 0)
INSERT [dbo].[Province] ([ProvinceID], [ProvinceName], [DeliveryFee]) VALUES (N'PV-28', N'Hậu Giang', 0)
INSERT [dbo].[Province] ([ProvinceID], [ProvinceName], [DeliveryFee]) VALUES (N'PV-29', N'Hòa Bình', 0)
INSERT [dbo].[Province] ([ProvinceID], [ProvinceName], [DeliveryFee]) VALUES (N'PV-3', N'Bạc Liêu', 15000)
INSERT [dbo].[Province] ([ProvinceID], [ProvinceName], [DeliveryFee]) VALUES (N'PV-30', N'Hưng Yên', 0)
INSERT [dbo].[Province] ([ProvinceID], [ProvinceName], [DeliveryFee]) VALUES (N'PV-31', N'Khánh Hòa', 0)
INSERT [dbo].[Province] ([ProvinceID], [ProvinceName], [DeliveryFee]) VALUES (N'PV-32', N'Kiên Giang', 0)
INSERT [dbo].[Province] ([ProvinceID], [ProvinceName], [DeliveryFee]) VALUES (N'PV-33', N'Kon Tum', 0)
INSERT [dbo].[Province] ([ProvinceID], [ProvinceName], [DeliveryFee]) VALUES (N'PV-34', N'Lai Châu', 0)
INSERT [dbo].[Province] ([ProvinceID], [ProvinceName], [DeliveryFee]) VALUES (N'PV-35', N'Lạng Sơn', 0)
INSERT [dbo].[Province] ([ProvinceID], [ProvinceName], [DeliveryFee]) VALUES (N'PV-36', N'Lào Cai', 0)
INSERT [dbo].[Province] ([ProvinceID], [ProvinceName], [DeliveryFee]) VALUES (N'PV-37', N'Lâm Đồng', 0)
INSERT [dbo].[Province] ([ProvinceID], [ProvinceName], [DeliveryFee]) VALUES (N'PV-38', N'Long An', 0)
INSERT [dbo].[Province] ([ProvinceID], [ProvinceName], [DeliveryFee]) VALUES (N'PV-39', N'Nam Định', 0)
INSERT [dbo].[Province] ([ProvinceID], [ProvinceName], [DeliveryFee]) VALUES (N'PV-4', N'Bắc Giang', 15000)
INSERT [dbo].[Province] ([ProvinceID], [ProvinceName], [DeliveryFee]) VALUES (N'PV-40', N'Nghệ An', 0)
INSERT [dbo].[Province] ([ProvinceID], [ProvinceName], [DeliveryFee]) VALUES (N'PV-41', N'Ninh Bình', 0)
INSERT [dbo].[Province] ([ProvinceID], [ProvinceName], [DeliveryFee]) VALUES (N'PV-42', N'Ninh Thuận', 0)
INSERT [dbo].[Province] ([ProvinceID], [ProvinceName], [DeliveryFee]) VALUES (N'PV-43', N'Phú Thọ', 0)
INSERT [dbo].[Province] ([ProvinceID], [ProvinceName], [DeliveryFee]) VALUES (N'PV-44', N'Phú Yên', 0)
INSERT [dbo].[Province] ([ProvinceID], [ProvinceName], [DeliveryFee]) VALUES (N'PV-45', N'Quảng Bình', 0)
INSERT [dbo].[Province] ([ProvinceID], [ProvinceName], [DeliveryFee]) VALUES (N'PV-46', N'Quảng Nam', 0)
INSERT [dbo].[Province] ([ProvinceID], [ProvinceName], [DeliveryFee]) VALUES (N'PV-47', N'Quảng Ngãi', 0)
INSERT [dbo].[Province] ([ProvinceID], [ProvinceName], [DeliveryFee]) VALUES (N'PV-48', N'Quảng Ninh', 0)
INSERT [dbo].[Province] ([ProvinceID], [ProvinceName], [DeliveryFee]) VALUES (N'PV-49', N'Quảng Trị', 0)
INSERT [dbo].[Province] ([ProvinceID], [ProvinceName], [DeliveryFee]) VALUES (N'PV-5', N'Bắc Kạn', 15000)
INSERT [dbo].[Province] ([ProvinceID], [ProvinceName], [DeliveryFee]) VALUES (N'PV-50', N'Sóc Trăng', 0)
INSERT [dbo].[Province] ([ProvinceID], [ProvinceName], [DeliveryFee]) VALUES (N'PV-51', N'Sơn La', 0)
INSERT [dbo].[Province] ([ProvinceID], [ProvinceName], [DeliveryFee]) VALUES (N'PV-52', N'Tây Ninh', 0)
INSERT [dbo].[Province] ([ProvinceID], [ProvinceName], [DeliveryFee]) VALUES (N'PV-53', N'Thái Bình', 0)
INSERT [dbo].[Province] ([ProvinceID], [ProvinceName], [DeliveryFee]) VALUES (N'PV-54', N'Thái Nguyên', 0)
INSERT [dbo].[Province] ([ProvinceID], [ProvinceName], [DeliveryFee]) VALUES (N'PV-55', N'Thanh Hóa', 0)
INSERT [dbo].[Province] ([ProvinceID], [ProvinceName], [DeliveryFee]) VALUES (N'PV-56', N'Thừa Thiên-Huế', 0)
INSERT [dbo].[Province] ([ProvinceID], [ProvinceName], [DeliveryFee]) VALUES (N'PV-57', N'Tiền Giang', 0)
INSERT [dbo].[Province] ([ProvinceID], [ProvinceName], [DeliveryFee]) VALUES (N'PV-58', N'TP Hồ Chí Minh', 0)
INSERT [dbo].[Province] ([ProvinceID], [ProvinceName], [DeliveryFee]) VALUES (N'PV-59', N'Trà Vinh', 0)
INSERT [dbo].[Province] ([ProvinceID], [ProvinceName], [DeliveryFee]) VALUES (N'PV-6', N'Bắc Ninh', 15000)
INSERT [dbo].[Province] ([ProvinceID], [ProvinceName], [DeliveryFee]) VALUES (N'PV-60', N'Tuyên Quang', 0)
INSERT [dbo].[Province] ([ProvinceID], [ProvinceName], [DeliveryFee]) VALUES (N'PV-61', N'Vĩnh Long', 0)
INSERT [dbo].[Province] ([ProvinceID], [ProvinceName], [DeliveryFee]) VALUES (N'PV-62', N'Vĩnh Phúc', 0)
INSERT [dbo].[Province] ([ProvinceID], [ProvinceName], [DeliveryFee]) VALUES (N'PV-63', N'Yên Bái', 0)
INSERT [dbo].[Province] ([ProvinceID], [ProvinceName], [DeliveryFee]) VALUES (N'PV-7', N'Bến Tre', 0)
INSERT [dbo].[Province] ([ProvinceID], [ProvinceName], [DeliveryFee]) VALUES (N'PV-8', N'Bình Dương', 0)
INSERT [dbo].[Province] ([ProvinceID], [ProvinceName], [DeliveryFee]) VALUES (N'PV-9', N'Bình Định', 0)
INSERT [dbo].[Rating] ([UserID], [ProductID], [Star], [Comment], [Title], [RatingDate]) VALUES (N'9011576b-720b-4d64-a01c-87479922a5da', N'PR-1', 3, NULL, NULL, CAST(N'0001-01-01' AS Date))
INSERT [dbo].[Rating] ([UserID], [ProductID], [Star], [Comment], [Title], [RatingDate]) VALUES (N'9011576b-720b-4d64-a01c-87479922a5da', N'PR-10', 3, NULL, NULL, CAST(N'0001-01-01' AS Date))
INSERT [dbo].[Rating] ([UserID], [ProductID], [Star], [Comment], [Title], [RatingDate]) VALUES (N'9011576b-720b-4d64-a01c-87479922a5da', N'PR-12', 3, NULL, NULL, CAST(N'0001-01-01' AS Date))
INSERT [dbo].[User] ([UserID], [Password], [FullName], [Gender], [DOB], [Email], [Address], [Phone], [Role]) VALUES (N'1271830f-45f0-43db-a48b-34e02d1b7183', N'236c5d9920a97f42a105716432e2bd7c', N'Trần Kiều Ân', NULL, NULL, N'trankieuan123@gmail.com', NULL, NULL, N'user')
INSERT [dbo].[User] ([UserID], [Password], [FullName], [Gender], [DOB], [Email], [Address], [Phone], [Role]) VALUES (N'25a7f9a6-42a9-4cca-84d1-176e038cdc17', N'9e4ed1ebb2917ebe66cfe5e3ccdcc3ed', N'GUEST', NULL, NULL, NULL, NULL, NULL, N'guest')
INSERT [dbo].[User] ([UserID], [Password], [FullName], [Gender], [DOB], [Email], [Address], [Phone], [Role]) VALUES (N'2e761ee0-536d-48e2-9b0e-9cd09fb46791', N'0a147bdc64382070c2c80d2583c95f53', N'GUEST', NULL, NULL, NULL, NULL, NULL, N'guest')
INSERT [dbo].[User] ([UserID], [Password], [FullName], [Gender], [DOB], [Email], [Address], [Phone], [Role]) VALUES (N'2e89b21e-cb30-42cd-b665-1dea46fd3ced', N'bfd59291e825b5f2bbf1eb76569f8fe7', N'asd', NULL, NULL, N'asd123@gmail.com', NULL, NULL, N'user')
INSERT [dbo].[User] ([UserID], [Password], [FullName], [Gender], [DOB], [Email], [Address], [Phone], [Role]) VALUES (N'4a273f5d-7975-4c30-99c0-36201b677128', N'ed31608593d79645a08326b3495301c3', N'Tôn Ngộ Không', NULL, NULL, N'tonngokhong123@gmail.com', NULL, NULL, N'user')
INSERT [dbo].[User] ([UserID], [Password], [FullName], [Gender], [DOB], [Email], [Address], [Phone], [Role]) VALUES (N'73a1abbb-d31e-46d0-a349-4ec5d3df565f', N'9c4a72b9fcd4ba9e11b96f83c5f912d3', N'Hoàng Phi Long', NULL, NULL, N'philong123@gmail.com', NULL, NULL, N'user')
INSERT [dbo].[User] ([UserID], [Password], [FullName], [Gender], [DOB], [Email], [Address], [Phone], [Role]) VALUES (N'756398ff-c4df-4f8f-9f2e-170716cb0b70', N'7fa1639a2091b53ade60d07d8202eada', N'GUEST', NULL, NULL, NULL, NULL, NULL, N'guest')
INSERT [dbo].[User] ([UserID], [Password], [FullName], [Gender], [DOB], [Email], [Address], [Phone], [Role]) VALUES (N'78a3db24-ce1a-476f-bc33-b6986cb9a254', N'715cde3e6997e39f5c829217cda6ba83', N'Na Tra', NULL, NULL, N'natra123@gmail.com', NULL, NULL, N'user')
INSERT [dbo].[User] ([UserID], [Password], [FullName], [Gender], [DOB], [Email], [Address], [Phone], [Role]) VALUES (N'7aab8d40-8374-429a-8950-a935c12a5f43', N'52d410835dccc1183dbb33a49805b2bd', N'Đường Bá Hổ', NULL, NULL, N'duongbaho123@gmail.com', NULL, NULL, N'user')
INSERT [dbo].[User] ([UserID], [Password], [FullName], [Gender], [DOB], [Email], [Address], [Phone], [Role]) VALUES (N'7ecb877b-a135-42c4-b30f-e24c318d278c', N'e00cf25ad42683b3df678c61f42c6bda', N'Admin 1', NULL, NULL, N'admin1@gmail.com', NULL, NULL, N'admin')
INSERT [dbo].[User] ([UserID], [Password], [FullName], [Gender], [DOB], [Email], [Address], [Phone], [Role]) VALUES (N'898f6d21-1728-4874-be81-466090d6a1cb', N'ac851ed86b5f55eda6daf977344b8e84', N'Nguyễn Văn Bảo', NULL, NULL, N'nguyenvanbao123@gmail.com', NULL, NULL, N'user')
INSERT [dbo].[User] ([UserID], [Password], [FullName], [Gender], [DOB], [Email], [Address], [Phone], [Role]) VALUES (N'9011576b-720b-4d64-a01c-87479922a5da', N'3c64b806539b66e3f47de4c93320277b', N'Lê Văn Tèo', NULL, NULL, N'levanteo123@gmail.com', N'số 198 Nguyễn Thị Minh Khai, Phường 6, Quận 3, TP. Hồ Chí Minh', N'0953751426', N'user')
INSERT [dbo].[User] ([UserID], [Password], [FullName], [Gender], [DOB], [Email], [Address], [Phone], [Role]) VALUES (N'9b640ff7-ea1f-4de6-93fa-98fba7cf83db', N'd71dd4c38657126b52d8a64998fb696f', N'Trương Vô Kỵ', NULL, NULL, N'truongvoky123@gmail.com', NULL, NULL, N'user')
INSERT [dbo].[User] ([UserID], [Password], [FullName], [Gender], [DOB], [Email], [Address], [Phone], [Role]) VALUES (N'a16119a2-c3c0-4935-9cc9-51aa775d8ddf', N'ba361c95cebbff753a69678d938b14c7', N'GUEST', NULL, NULL, NULL, NULL, NULL, N'guest')
INSERT [dbo].[User] ([UserID], [Password], [FullName], [Gender], [DOB], [Email], [Address], [Phone], [Role]) VALUES (N'a7e6e9f4-dbc8-43ec-b04c-05173fe7e41e', N'e9d2d1aad8122e361ab24147d60e47b2', N'Trư Bát Giới', NULL, NULL, N'trubatgioi123@gmail.com', NULL, NULL, N'user')
INSERT [dbo].[User] ([UserID], [Password], [FullName], [Gender], [DOB], [Email], [Address], [Phone], [Role]) VALUES (N'be55ad02-e3e2-419a-b742-65262d4cab9b', N'06b900d156cbd02d4005596999665f8a', N'GUEST', NULL, NULL, NULL, NULL, NULL, N'guest')
INSERT [dbo].[User] ([UserID], [Password], [FullName], [Gender], [DOB], [Email], [Address], [Phone], [Role]) VALUES (N'd5679b36-df36-470e-805b-59f95fc20c28', N'8bdf6b25811524781a621bbbca5a100f', N'Trương Vệ Kiện', NULL, NULL, N'truongvekien123@gmail.com', NULL, NULL, N'user')
INSERT [dbo].[User] ([UserID], [Password], [FullName], [Gender], [DOB], [Email], [Address], [Phone], [Role]) VALUES (N'df2d9c62-9c0a-419e-8b32-1f40d3462a8e', N'f3153a27f43c404b4de46d05c323618e', N'Nguyễn Văn An', NULL, NULL, N'nguyenvanan123@gmail.com', NULL, NULL, N'user')
INSERT [dbo].[User] ([UserID], [Password], [FullName], [Gender], [DOB], [Email], [Address], [Phone], [Role]) VALUES (N'e58f964e-75ab-471f-917b-a689a0fe78cf', N'5ec50b105bf2a54e25c0f9962a44b94f', N'GUEST', NULL, NULL, NULL, NULL, NULL, N'guest')
INSERT [dbo].[User] ([UserID], [Password], [FullName], [Gender], [DOB], [Email], [Address], [Phone], [Role]) VALUES (N'ee1419b3-b63b-4082-94d2-2a344593791a', N'84fd3263b83145a63cb14145357874aa', N'Triệu Mẫn', NULL, NULL, N'trieuman123@gmail.com', NULL, NULL, N'user')
INSERT [dbo].[User] ([UserID], [Password], [FullName], [Gender], [DOB], [Email], [Address], [Phone], [Role]) VALUES (N'f8fc4a16-d2c1-445e-b611-7c1b31c754a1', N'd624ce167e9043967fa5b75d599a42df', N'Chu Chỉ Nhược', NULL, NULL, N'chuchinhuoc123@gmail.com', NULL, NULL, N'user')
ALTER TABLE [dbo].[Bill]  WITH CHECK ADD  CONSTRAINT [FK_Bill_Cart] FOREIGN KEY([CartID])
REFERENCES [dbo].[Cart] ([CartID])
GO
ALTER TABLE [dbo].[Bill] CHECK CONSTRAINT [FK_Bill_Cart]
GO
ALTER TABLE [dbo].[Bill]  WITH CHECK ADD  CONSTRAINT [FK_Bill_Discount] FOREIGN KEY([DiscountCode])
REFERENCES [dbo].[Discount] ([DiscountCode])
GO
ALTER TABLE [dbo].[Bill] CHECK CONSTRAINT [FK_Bill_Discount]
GO
ALTER TABLE [dbo].[Cart]  WITH CHECK ADD  CONSTRAINT [FK_Cart_User] FOREIGN KEY([UserID])
REFERENCES [dbo].[User] ([UserID])
GO
ALTER TABLE [dbo].[Cart] CHECK CONSTRAINT [FK_Cart_User]
GO
ALTER TABLE [dbo].[Cart_Product]  WITH CHECK ADD  CONSTRAINT [FK_Cart_Product_Cart] FOREIGN KEY([CartID])
REFERENCES [dbo].[Cart] ([CartID])
GO
ALTER TABLE [dbo].[Cart_Product] CHECK CONSTRAINT [FK_Cart_Product_Cart]
GO
ALTER TABLE [dbo].[Cart_Product]  WITH CHECK ADD  CONSTRAINT [FK_Cart_Product_Product] FOREIGN KEY([ProductID])
REFERENCES [dbo].[Product] ([ProductID])
GO
ALTER TABLE [dbo].[Cart_Product] CHECK CONSTRAINT [FK_Cart_Product_Product]
GO
ALTER TABLE [dbo].[District]  WITH CHECK ADD  CONSTRAINT [FK_District_Province] FOREIGN KEY([ProvinceID])
REFERENCES [dbo].[Province] ([ProvinceID])
GO
ALTER TABLE [dbo].[District] CHECK CONSTRAINT [FK_District_Province]
GO
ALTER TABLE [dbo].[Product]  WITH CHECK ADD  CONSTRAINT [FK_Product_Category] FOREIGN KEY([CategoryID])
REFERENCES [dbo].[Category] ([CategoryID])
GO
ALTER TABLE [dbo].[Product] CHECK CONSTRAINT [FK_Product_Category]
GO
ALTER TABLE [dbo].[Product_Size_Quantity]  WITH CHECK ADD  CONSTRAINT [FK_Product_Size_Quantity_Product] FOREIGN KEY([ProductID])
REFERENCES [dbo].[Product] ([ProductID])
GO
ALTER TABLE [dbo].[Product_Size_Quantity] CHECK CONSTRAINT [FK_Product_Size_Quantity_Product]
GO
ALTER TABLE [dbo].[Rating]  WITH CHECK ADD  CONSTRAINT [FK_Rating_Product] FOREIGN KEY([ProductID])
REFERENCES [dbo].[Product] ([ProductID])
GO
ALTER TABLE [dbo].[Rating] CHECK CONSTRAINT [FK_Rating_Product]
GO
ALTER TABLE [dbo].[Rating]  WITH CHECK ADD  CONSTRAINT [FK_Rating_User] FOREIGN KEY([UserID])
REFERENCES [dbo].[User] ([UserID])
GO
ALTER TABLE [dbo].[Rating] CHECK CONSTRAINT [FK_Rating_User]
GO
USE [master]
GO
ALTER DATABASE [RoseFashionDB] SET  READ_WRITE 
GO
