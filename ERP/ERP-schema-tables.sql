
-- SQL for ERP tables

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = '[ERP]')
BEGIN
    EXEC('CREATE SCHEMA [ERP]')
END


use [DigitalOrders];

DROP TABLE IF EXISTS [ERP].[SourceSystems];
DROP TABLE IF EXISTS [ERP].[BcCustomers];
DROP TABLE IF EXISTS [ERP].[BcLocations];
DROP TABLE IF EXISTS [ERP].[BcTenants];
DROP TABLE IF EXISTS [ERP].[BcProducts];
DROP TABLE IF EXISTS [ERP].[LinkedChildItems];
DROP TABLE IF EXISTS [ERP].[MessageQueue];
GO


-- Source system names
CREATE TABLE [ERP].[SourceSystems] (Id INT IDENTITY(1,1) PRIMARY KEY, Name VARCHAR(32) NOT NULL);

-- For mapping: SourceSystem + Customer -> BC.Customerid
CREATE TABLE [ERP].[BcCustomers] (SourceSystemId INT NOT NULL, BrandCode VARCHAR(3) NOT NULL, BcCustomerId VARCHAR(20) NOT NULL)

-- For mapping: SourceSystem + SiteId / FacilityID -> BC LocationId
CREATE TABLE [ERP].[BcLocations] (SourceSystemId INT NOT NULL, SiteId VARCHAR(32) NOT NULL, BcLocationId UNIQUEIDENTIFIER NOT NULL);

-- For mapping: SourceSystem + SiteId -> BCTenant table
CREATE TABLE [ERP].[BcTenants] (SourceSystemId INT NOT NULL, SiteId VARCHAR(32) NOT NULL, BcTenantId UNIQUEIDENTIFIER NOT NULL);

-- For mapping: SourceSystem + ProductId -> Business Central ItemId + VariantId combination (either may be NULL)
CREATE TABLE [ERP].[BcProducts] (SourceSystemId INT NOT NULL, ProductCode VARCHAR(20) NOT NULL, BcItemId UNIQUEIDENTIFIER DEFAULT NULL, BcVariantId UNIQUEIDENTIFIER DEFAULT NULL);

-- Message queue
-- TODO: index on ID + TYPE ?
CREATE TABLE [ERP].[MessageQueue] (Id UNIQUEIDENTIFIER DEFAULT NEWSEQUENTIALID() NOT NULL, Date DATETIME NOT NULL, Type VARCHAR(MAX) NOT NULL, Data VARCHAR(MAX) NOT NULL);

-- Linked child items
CREATE TABLE [ERP].LinkedChildItems (
	[ParentItemCode] [varchar](20) NOT NULL,
	[BaseQty] [int] NOT NULL,
	[ChildItemCode] [varchar](20) NOT NULL,
	[SidesPerImage] [int] NOT NULL,
	[Multiplicity] [char](1) NOT NULL,
 CONSTRAINT [PK_ERP_LinkedChildItems] PRIMARY KEY CLUSTERED 
(
	[ParentItemCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

--ALTER TABLE [ERP].LinkedChildItems ADD  CONSTRAINT [DF_LinkedChildItems_Multiplicity]  DEFAULT ('S') FOR [Multiplicity] GO



-- Add sample data
DECLARE @PrimarySourceSystem VARCHAR(32) = 'HarrierOMS';
INSERT INTO [ERP].[SourceSystems] (Name) VALUES (@PrimarySourceSystem); 
DECLARE @SourceSystemIdForOms INT = scope_identity();

INSERT INTO [ERP].[BcCustomers] (SourceSystemId, BrandCode, BcCustomerId) VALUES (@SourceSystemIdForOms, 'ABC', 'Customer1');
INSERT INTO [ERP].[BcCustomers] (SourceSystemId, BrandCode, BcCustomerId) VALUES (@SourceSystemIdForOms, 'EFG', 'Customer2');
INSERT INTO [ERP].[BcCustomers] (SourceSystemId, BrandCode, BcCustomerId) VALUES (@SourceSystemIdForOms, 'XYZ', 'Customer3');

INSERT INTO [ERP].[BcLocations] (SourceSystemId, SiteId, BcLocationId) VALUES (@SourceSystemIdForOms, 'SITE1', NEWID());
INSERT INTO [ERP].[BcLocations] (SourceSystemId, SiteId, BcLocationId) VALUES (@SourceSystemIdForOms, 'SITE2', NEWID());
INSERT INTO [ERP].[BcLocations] (SourceSystemId, SiteId, BcLocationId) VALUES (@SourceSystemIdForOms, 'SITE3', NEWID());

INSERT INTO [ERP].[BcTenants] (SourceSystemId, SiteId, BcTenantId) VALUES (@SourceSystemIdForOms, 'SITE1', NEWID());
INSERT INTO [ERP].[BcTenants] (SourceSystemId, SiteId, BcTenantId) VALUES (@SourceSystemIdForOms, 'SITE2', NEWID());
INSERT INTO [ERP].[BcTenants] (SourceSystemId, SiteId, BcTenantId) VALUES (@SourceSystemIdForOms, 'SITE3', NEWID());

INSERT INTO [ERP].[BcProducts] (SourceSystemId, ProductCode, BcItemId, BcVariantId) VALUES (@SourceSystemIdForOms, 'A1234', NEWID(), NEWID());
INSERT INTO [ERP].[BcProducts] (SourceSystemId, ProductCode, BcItemId, BcVariantId) VALUES (@SourceSystemIdForOms, 'A5678', NEWID(), NEWID());
INSERT INTO [ERP].[BcProducts] (SourceSystemId, ProductCode, BcItemId, BcVariantId) VALUES (@SourceSystemIdForOms, 'A9999', NEWID(), NEWID());



-- Sample lookups
SELECT sys.Name, cus.BrandCode, cus.BcCustomerId FROM [ERP].[BcCustomers] cus
INNER JOIN [ERP].[SourceSystems] sys ON sys.Id = cus.SourceSystemId
WHERE sys.Name = @PrimarySourceSystem;

-- TODO: Primary key lookup based on common SELECTs

-- CONSTRAINT PK_RestrictedItems PRIMARY KEY (ProductCode, RestrictionType),
-- CONSTRAINT FK_RestrictionTypes FOREIGN KEY (RestrictionType) REFERENCES [Mail].[RestrictedItemTypes] (ID) ON DELETE CASCADE

