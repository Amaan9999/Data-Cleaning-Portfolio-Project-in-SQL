/*

Cleaning Data in SQL Queries

*/
select * from ProjectResume.dbo.NashvilleHousing

-- Standardize Date Format
Select saleDate, CONVERT(Date,SaleDate)
From ProjectResume.dbo.NashvilleHousing 

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

-- If it doesn't Update properly

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


-- Populate Property Address data

Select * from	ProjectResume.dbo.NashvilleHousing order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From ProjectResume.dbo.NashvilleHousing a
JOIN ProjectResume.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From ProjectResume.dbo.NashvilleHousing a
JOIN ProjectResume.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


-- Breaking out Address into Individual Columns (Address, City, State)
Select PropertyAddress
From ProjectResume.dbo.NashvilleHousing

Select SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as
Address  ,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
From ProjectResume.dbo.NashvilleHousing

Alter table NashvilleHousing 
Add PropertySplitAddress nvarchar(255)

Update NashvilleHousing Set PropertySplitAddress= SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) 

Alter Table NashvilleHousing Add PropertySplitCity Nvarchar(255)

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

Select *
From ProjectResume.dbo.NashvilleHousing

Select OwnerAddress
From ProjectResume.dbo.NashvilleHousing

Select Parsename(Replace(OwnerAddress,',','.'),3),PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1) from ProjectResume.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

Alter Table NashvilleHousing Add OwnerSplitCity nvarchar(255)
Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

Alter Table NashvilleHousing Add OwnerSplitState nvarchar(255)
Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

Select * from ProjectResume.dbo.NashvilleHousing

-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From ProjectResume.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2


Select SoldAsVacant,
Case
	When SoldAsVacant='Y' Then 'Yes'
	When SoldAsVacant='N' Then 'No'
	Else SoldAsVacant
End
from ProjectResume.dbo.NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

-- Remove Duplicates

select * from ProjectResume.dbo.NashvilleHousing

WITH RowNumCTE AS (
  SELECT *,
         ROW_NUMBER() OVER (
           PARTITION BY ParcelID,
                        PropertyAddress,
                        SalePrice,
                        SaleDate,
                        LegalReference
           ORDER BY UniqueID
         ) AS row_num
  FROM ProjectResume.dbo.NashvilleHousing
)DELETE FROM ProjectResume.dbo.NashvilleHousing
WHERE UniqueID IN (
  SELECT UniqueID
  FROM RowNumCTE
  WHERE row_num > 1
);

Select *
From ProjectResume.dbo.NashvilleHousing

-- Delete Unused Columns

Select *
From ProjectResume.dbo.NashvilleHousing


ALTER TABLE ProjectResume.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate


 
