
--------------- DATA CLEANING PROJECT using SQL Queries ----------------------------------------------------------
/*
Skills used are: 
				Alter & Update Table, Join & Self Join, Date Formatting, Replacing Null Values, 
				Breaking a column into 3 different columns, Data Validation, Case Statement, 
				Remove Duplicates, Delete unused columns, CTEs
*/
-------------------------------------------------------------------------------------------------------------------

-- 1. Overview of Data
SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

-------------------------------------------------------------------------------------------------------------------

-- 2. Standardize Date Format

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM PortfolioProject.dbo.NashvilleHousing

UPDATE PortfolioProject.dbo.NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD SaleDateConverted Date;

UPDATE PortfolioProject.dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

SELECT SaleDateConverted
FROM PortfolioProject.dbo.NashvilleHousing



-------------------------------------------------------------------------------------------------------------------

-- 3. Populate Property Address Data 

---- Checking Null Values
SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
WHERE PropertyAddress IS NULL
---- Some research like why so same Parcelid have same property address
SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
ORDER BY ParcelID


-- Self Join (with and without Null)
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
   ON a.ParcelID = b.ParcelID
   AND a.[UniqueID ] <> b.[UniqueID ]

-- Self Join (With Null)
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
   ON a.ParcelID = b.ParcelID
   AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


------ Query to replacing NULL ---- IF THERE IS NILL IN a.PROPERTYADDRESS with Address IN b.PROPERTYADDRESS

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
   ON a.ParcelID = b.ParcelID
   AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


-- Updating Null Property Address

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
   ON a.ParcelID = b.ParcelID
   AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL



--------------------------------------------------------------------------------------------------------------------------


---- 4. Breaking out Adress into Individual columns (Address, City, State)
----    2 Methods For Breaking the Address


-- 4.1. Property Address

SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing


SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) AS Address
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address
FROM PortfolioProject.dbo.NashvilleHousing

-- Alter & Update Changes

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))



SELECT *
FROM PortfolioProject.dbo.NashvilleHousing


-- 4.2. Owner Address

SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing


SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)
FROM PortfolioProject.dbo.NashvilleHousing

-- Alter & Update Changes

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)



SELECT *
FROM PortfolioProject.dbo.NashvilleHousing




--------------------------------------------------------------------------------------------------------------------------------

---- 5. Change Y and N to Yes and No in "Sold As Vacant" field.


SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

-- Changing by using CASE Statement

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM PortfolioProject.dbo.NashvilleHousing

-- Update Changes

UPDATE PortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
						END



-----------------------------------------------------------------------------------------------------------------------------

---- 6. Removing Duplicates

-- Using CTE Statement to find duplicate and use temp table.

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
	             PropertyAddress,
				 SaleDate,
				 SalePrice,
				 LegalReference
			  ORDER BY
			          UniqueID
					  ) ROW_NUM
FROM PortfolioProject.dbo.NashvilleHousing
)
SELECT * -- Overview
FROM RowNumCTE
WHERE ROW_NUM > 1
ORDER BY PropertyAddress



WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
	             PropertyAddress,
				 SaleDate,
				 SalePrice,
				 LegalReference
			  ORDER BY
			          UniqueID
					  ) ROW_NUM
FROM PortfolioProject.dbo.NashvilleHousing
)
DELETE -- Removing Duplicate
FROM RowNumCTE
WHERE ROW_NUM > 1



SELECT *
FROM PortfolioProject.dbo.NashvilleHousing



------------------------------------------------------------------------------------------------------------------------------------


---- 7. DELETE unused columns

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict 

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate


-- Recheck the drop status
SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------