SELECT * FROM portfolio.dbo.NashvilleHousing;

----------------------------------------------------------------------------
-- Standardize date format

SELECT SaleDate, CONVERT(Date, SaleDate) FROM  portfolio.dbo.NashvilleHousing;

UPDATE portfolio.dbo.NashvilleHousing 
SET SaleDate = CONVERT(Date, SaleDate);

SELECT SaleDate FROM  portfolio.dbo.NashvilleHousing; 
-- it is not updating we will create new column

ALTER TABLE portfolio.dbo.NashvilleHousing
ADD SaleDateConverted Date;

UPDATE portfolio.dbo.NashvilleHousing 
SET SaleDateConverted = CONVERT(Date, SaleDate);





-------------------------------------------------------------------
/* Fill null values in property address
 As we have same ParcellID and then address should be same of the property.
 */

-- check null values
SELECT ParcelID , PropertyAddress from portfolio.dbo.NashvilleHousing
where PropertyAddress IS NULL;

-- check address with same parcelID
SELECT a.ParcelID ,a.PropertyAddress, b.ParcelID ,b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from portfolio.dbo.NashvilleHousing a
join portfolio.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress IS NULL;


-- Update null vaulues 
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from portfolio.dbo.NashvilleHousing a
join portfolio.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress IS NULL;






--------------------------------------------------------
-- Breaking address into Address, City

SELECT PropertyAddress from NashvilleHousing;

-- split address
SELECT 
	SUBSTRING(PropertyAddress, 1 , CHARINDEX(',', PropertyAddress) -1) AS Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS City
from portfolio.dbo.NashvilleHousing;

-- Update address and City
ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1 , CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

select * from portfolio.dbo.NashvilleHousing;


-- split owner address
SELECT OwnerAddress
FROM portfolio.dbo.NashvilleHousing;

SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM portfolio.dbo.NashvilleHousing;

ALTER TABLE portfolio.dbo.NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);
ALTER TABLE portfolio.dbo.NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);
ALTER TABLE portfolio.dbo.NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE portfolio.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3);

UPDATE portfolio.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2);

UPDATE portfolio.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1);


SELECT *
FROM portfolio.dbo.NashvilleHousing;






------------------------------------------------------------------------
-- Change Y to Yes and N to No in SoldAsVacant
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM portfolio.dbo.NashvilleHousing
GROUP BY SoldAsVacant
Order By 2;

SELECT SoldAsVacant,
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM portfolio.dbo.NashvilleHousing;


UPDATE portfolio.dbo.NashvilleHousing
SET SoldAsVacant = 
	CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM portfolio.dbo.NashvilleHousing








-----------------------------------------------------------------------
-- Remove Duplicates

-- Mark for duplicates
SELECT *, 
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
FROM portfolio.dbo.NashvilleHousing
ORDER BY ParcelID


--Check duplicates
WITH RowNumCTE AS (
	SELECT *, 
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice, 
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
FROM portfolio.dbo.NashvilleHousing
)
SELECT * FROM RowNumCTE
WHERE row_num > 1

--Delete

WITH RowNumCTE AS (
	SELECT *, 
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice, 
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
FROM portfolio.dbo.NashvilleHousing
)
DELETE FROM RowNumCTE
WHERE row_num > 1


----------------------------------------------------------------------
--Remove unused columns
SELECT * FROM portfolio.dbo.NashvilleHousing;

ALTER TABLE portfolio.dbo.NashvilleHousing
DROP COLUMN PropertyAddress, TaxDistrict, OwnerAddress;
ALTER TABLE portfolio.dbo.NashvilleHousing
DROP COLUMN SaleDate;
