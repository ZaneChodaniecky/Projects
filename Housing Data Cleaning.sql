SELECT * 
FROM NashvilleHousing;

-- Standardize Date format

Select SaleDate, Convert(Date,SaleDate)
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD SaleDateConverted date;

UPDATE NashvilleHousing
Set SaleDateConverted = Convert(date,SaleDate);


-- Populate property addresss data
Select *
FROM NashvilleHousing
ORDER BY ParcelID
--WHERE PropertyAddress is null


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing AS a
JOIN NashvilleHousing AS b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


UPDATE a
Set a.PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing AS a
JOIN NashvilleHousing AS b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


--Break out PropertyAddress by city and address
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress,1)-1) as Address
FROM NashvilleHousing
ORDER BY ParcelID;

--Break out City Name
SELECT
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress,1)+2, len(PropertyAddress)) as City
FROM NashvilleHousing
ORDER BY ParcelID;

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255), PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress,1)+2, len(PropertyAddress));

UPDATE NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress,1)-1);


--Break out OwnerAddress by city, state, and address
Select 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255), OwnerSplitCity Nvarchar(255), OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3);

UPDATE NashvilleHousing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2);

UPDATE NashvilleHousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1);


--Change Y and N to Yes and No in SoldAsVacant
Select SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'NO'
	 ELSE SoldAsVacant
	 END
FROM NashvilleHousing

UPDATE NashvilleHousing
Set SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'NO'
	 ELSE SoldAsVacant
	 END

-- Remove Duplicates
WITH RowNum_CTE AS(
SELECT *, 
	ROW_NUMBER() OVER(
	Partition By ParcelID,  
	SalePrice, 
	SaleDate, 
	LegalReference 
	ORDER BY UniqueID) AS row_num
FROM NashvilleHousing
)
DELETE
FROM RowNum_CTE
WHERE row_num >1

--Removed Unused Columns

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
