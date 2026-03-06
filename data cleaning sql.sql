--Cleaning data : 
select * 
from PortfolioProject.dbo.NshvilleHousing

----------------------------------------------------
----Standardize date format
select SaleDate, CONVERT(Date,saleDate) as saleDConvert, SaleDateConverted
from PortfolioProject.dbo.NshvilleHousing

Update NshvilleHousing
SET saleDate = CONVERT(Date,SaleDate) 

Alter Table NshvilleHousing
Add SaleDateConverted Date;

Update NshvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate) 

-----------------------------------------------------------

-- Populate Property Address data 
--if we have some null columns all we need id make sure to join it with proper one like here PropertyAddress
--from here we made everything : ISNULL(a.PropertyAddress , b.PropertyAddress )

select *
from PortfolioProject.dbo.NshvilleHousing
order by ParcelID


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,  ISNULL(a.PropertyAddress , b.PropertyAddress )
from PortfolioProject.dbo.NshvilleHousing a
join PortfolioProject.dbo.NshvilleHousing b
    on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null 


Update a
SET propertyAddress = ISNULL(a.PropertyAddress , b.PropertyAddress )
from PortfolioProject.dbo.NshvilleHousing a
join PortfolioProject.dbo.NshvilleHousing b
    on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

-------------------------------------------------------------------

select PropertyAddress
from PortfolioProject.dbo.NshvilleHousing
--order by ParcelID

SELECT PropertyAddress,
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as  Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) as  adressco

from PortfolioProject.dbo.NshvilleHousing

Alter Table [PortfolioProject].[dbo].[NshvilleHousing]
Add PropertySpitAddress Nvarchar(255);

Update [PortfolioProject].[dbo].[NshvilleHousing]
SET PropertySpitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

Alter Table [PortfolioProject].[dbo].[NshvilleHousing]
Add PropertySplitCity Nvarchar(255);

Update [PortfolioProject].[dbo].[NshvilleHousing]
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))


select *
from PortfolioProject.dbo.NshvilleHousing



select OwnerAddress
from PortfolioProject.dbo.NshvilleHousing


select OwnerAddress,
PARSENAME(REPLACE(OwnerAddress, ',' , '.'),1),
PARSENAME(REPLACE(OwnerAddress, ',' , '.'),2),
PARSENAME(REPLACE(OwnerAddress, ',' , '.'),3)
from PortfolioProject.dbo.NshvilleHousing


Alter Table [PortfolioProject].[dbo].[NshvilleHousing]
Add OwnerSplitAbv Nvarchar(255);

Update [PortfolioProject].[dbo].[NshvilleHousing]
SET OwnerSplitAbv = PARSENAME(REPLACE(OwnerAddress, ',' , '.'),1)

Alter Table [PortfolioProject].[dbo].[NshvilleHousing]
Add OwnerSplitCity Nvarchar(255);

Update [PortfolioProject].[dbo].[NshvilleHousing]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',' , '.'),2)

Alter Table [PortfolioProject].[dbo].[NshvilleHousing]
Add OwnerSplitAddress Nvarchar(255);

Update [PortfolioProject].[dbo].[NshvilleHousing]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',' , '.'),3)


--------------------------------------------------------------------------------
--Change Y and N to Yes and No in "Sold as Vacant" field

select Distinct(SoldAsVacant), count(SoldAsVacant) 
from PortfolioProject.dbo.NshvilleHousing
group by SoldAsVacant
order by 2



select soldAsVacant
, CASE when SoldAsVacant = 'Y' THEN 'Yes'
       when SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
from PortfolioProject.dbo.NshvilleHousing



Update [PortfolioProject].[dbo].[NshvilleHousing]
SET soldAsVacant = CASE when SoldAsVacant = 'Y' THEN 'Yes'
       when SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


-----------------------------------------------------------------------------------------
--Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

from PortfolioProject.dbo.NshvilleHousing
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



Select *
from PortfolioProject.dbo.NshvilleHousing

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns



Select *
from PortfolioProject.dbo.NshvilleHousing


ALTER TABLE PortfolioProject.dbo.NshvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject.dbo.NshvilleHousing
DROP COLUMN SaleDate