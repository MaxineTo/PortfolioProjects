--//* CLEANING DATA

SELECT *
FROM ProjectPortfolio.dbo.NashvilleHousing


 -- Standardize Date Format

SELECT SaleDateConverted, CONVERT(Date,SaleDate)
FROM ProjectPortfolio.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

-------------------------------------------------------------

--Populate Property Adress

SELECT *
FROM ProjectPortfolio..NashvilleHousing
WHERE OwnerAddress IS NULL
ORDER BY PropertyAddress

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(A.PropertyAddress, b.PropertyAddress)
FROM ProjectPortfolio..NashvilleHousing a
JOIN ProjectPortfolio..NashvilleHousing b
    ON a.ParcelID = b.ParcelID
    AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(A.PropertyAddress, b.PropertyAddress)
FROM ProjectPortfolio..NashvilleHousing a
JOIN ProjectPortfolio..NashvilleHousing b
    ON a.ParcelID = b.ParcelID
    AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
FROM ProjectPortfolio.dbo.NashvilleHousing


ALTER TABLE ProjectPortfolio..NashvilleHousing
ADD PropertySplitAddress nvarchar(255);

UPDATE ProjectPortfolio..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE ProjectPortfolio..NashvilleHousing
ADD PropertySplitCiy nvarchar(255);

UPDATE ProjectPortfolio..NashvilleHousing
SET PropertySplitCiy = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

-- Doing the same but using PARSENAME (a lot faster)

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
FROM ProjectPortfolio..NashvilleHousing

ALTER TABLE ProjectPortfolio..NashvilleHousing
ADD OwnerSplitAddress1 nvarchar(255);

UPDATE ProjectPortfolio..NashvilleHousing
SET OwnerSplitAddress1 = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE ProjectPortfolio..NashvilleHousing
ADD OwnerCity nvarchar(255);

UPDATE ProjectPortfolio..NashvilleHousing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE ProjectPortfolio..NashvilleHousing
ADD OwnerState nvarchar(255);

UPDATE ProjectPortfolio..NashvilleHousing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

-- Change N and Y values to No and Yes in SoldAsVacant column

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM ProjectPortfolio..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'No'
       ELSE SoldAsVacant
       END
FROM ProjectPortfolio..NashvilleHousing

UPDATE ProjectPortfolio..NashvilleHousing
SET SoldAsVacant =
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
     ELSE SoldAsVacant
     END

-- Removing duplicates
-- NOTE: It's not a standard practive to delete data, I'll do it here only for showcase purposes.

WITH RowNumCTE AS(
SELECT *,
       ROW_NUMBER() OVER (
       PARTITION BY ParcelID,
                    PropertyAddress,
                    SalePrice,
                    SaleDate,
                    LegalReference
                    ORDER BY
                        UniqueID
                        ) row_num                      
FROM ProjectPortfolio..NashvilleHousing
)

DELETE
FROM RowNumCTE
WHERE row_num > 1

-- Delete unused columns
-- Again, delete data from the root dataset is not a standard practice, it's much more used for views for example.

SELECT *
FROM ProjectPortfolio..NashvilleHousing

ALTER TABLE ProjectPortfolio..NashvilleHousing
      DROP COLUMN PropertyAddress, OwnerAddreSs, TaxDistrict, SaleDate



