/*

Cleaning Data in SQL Queries

*/

Select * 
From PortfolioProject..NashvilleHousing
--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

	-- CONVERT 
Select SaleDate, CONVERT(date, SaleDate) as a
From PortfolioProject..NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

	-- CAST
Select SaleDate, CAST(SaleDate as Date)
From NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

	-- ALTER TABLE
ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date 

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

--------------------------------------------------------------------------------------------------------------------------
-- Populate Property Address Data


Select *
From PortfolioProject..NashvilleHousing
--Where PropertyAddress is null
Order by ParcelID 


-- Join the table to itself to look if both columns are equal

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
Where a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID

--------------------------------------------------------------------------------------------------------------------------
-- Breaking out Address Into Invdividual Columns (Address, City, State)

	-- SUBSTRING, CHARINDEX, LEN	


Select PropertyAddress, SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+2, LEN(PropertyAddress))
From PortfolioProject..NashvilleHousing


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)


ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+2, LEN(PropertyAddress))

--Select PropertySplitAddress, SUBSTRING(PropertySplitAddress, CHARINDEX(' ', PropertySplitAddress), LEN(PropertySplitAddress)) 
--From PortfolioProject..NashvilleHousing

	-- PARSENAME

Select *
From PortfolioProject..NashvilleHousing

Select OwnerAddress, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3), PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2), PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)



ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


--------------------------------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" field

Select DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group by SoldAsVacant
Order by 2 

Select SoldAsVacant
, CASE WHEN SoldAsVacant = 'N' THEN 'No'
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		ELSE SoldAsVacant
		END 
From PortfolioProject..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'N' THEN 'No'
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		ELSE SoldAsVacant
		END 


--------------------------------------------------------------------------------------------------------------------------
-- Remove Duplicates (RANK, ORDERRANK, ROWNUMBER

WITH row_numCTE AS(
Select * , 
	ROW_NUMBER() OVER (
		PARTITION BY ParcelID,
					 PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
					 ORDER BY 
						UniqueID
						) row_num
From PortfolioProject..NashvilleHousing
)
--ORDER BY ParcelID 

--DELETE
--From row_numCTE
--Where row_num > 1

Select *
From row_numCTE
Where row_num > 1
Order by ParcelID


--------------------------------------------------------------------------------------------------------------------------
--  DELETE UNUSED COLUMNS

Select *
From PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN TaxDistrict