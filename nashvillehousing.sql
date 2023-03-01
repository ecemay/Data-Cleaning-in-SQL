Select * 
From NashvilleHousing
-----------------------------------------------------------------------------------------------------------------------------------------------------
-- Standardization Date Format

ALTER table [dbo].[NashvilleHousing]
Add SaleDateConvert date;  

Update NashvilleHousing
Set SaleDateConvert = Convert(Date, SaleDate)
-----------------------------------------------------------------------------------------------------------------------------------------------------
-- Filling null values in Property Address Column with the value that has same ParceID
-- We can do this using join

Select n.ParcelID , n.PropertyAddress, m.ParcelID, n.PropertyAddress, ISNULL(n.PropertyAddress, m.PropertyAddress)
From NashvilleHousing n
Join NashvilleHousing m
	on n.ParcelID = m.ParcelID
	AND n.[UniqueID ] <> m.[UniqueID ]
where n.PropertyAddress is null

Update n
SET PropertyAddress =  ISNULL(n.PropertyAddress, m.PropertyAddress)
From NashvilleHousing n
Join NashvilleHousing m
	on n.ParcelID = m.ParcelID
	AND n.[UniqueID ] <> m.[UniqueID ]
where n.PropertyAddress is null
-----------------------------------------------------------------------------------------------------------------------------------------------------
-- Formatting Adress Column

Select PropertyAddress
From NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )  as Address,--The SUBSTRING() function extracts some 
--characters from a string. Syntax -> SUBSTRING(string, start, length)
-- we add -1 to get rid of comma

SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))  as Address
From NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAdress Nvarchar(255) 

Update NashvilleHousing
SET PropertySplitAdress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE NashvilleHousing
Add PropertyCity Nvarchar(255) 

Update NashvilleHousing
SET PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))





SELECT *
FROM NashvilleHousing

-- Now We can drop old adress column

Alter table NashvilleHousing
Drop Column PropertyAddress

-----------------------------------------------------------------------------------------------------------------------------------------------------
--- We will do same for owneradress but using different method

Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) -- Returns the specified part of an object name.
--The parts of an object that can be retrieved are the object name, schema name, database name, and server name.
--PARSENAME ('object_name' , object_piece )
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From NashvilleHousing


ALTER TABLE NashvilleHousing
Add OwnerAdress Nvarchar(255) 

Update NashvilleHousing
SET OwnerAdress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
Add OwnerCity Nvarchar(255) 

Update NashvilleHousing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


ALTER TABLE NashvilleHousing
Add OwnerState Nvarchar(255) 

Update NashvilleHousing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

Select *
From NashvilleHousing

-----------------------------------------------------------------------------------------------------------------------------------------------------

-- We have something more to fix. 

Select Distinct(SoldAsVacant)
From NashvilleHousing

-- as we can see we have two different indexing for same variable.N and No for not soldasvacant and y and Yes for sold as vacant.
--We can convert all this binary form to format this column



SELECT SoldAsVacant
, CASE When SoldAsVacant = 'Y' Then '1'
       When SoldAsVacant = 'Yes' THEN '1'
	   When SoldAsVacant = 'N' Then '0'
	   When SoldAsVacant = 'No' THEN  '0'
       ELSE SoldAsVacant
       END 
FROM NashvilleHousing

UPDATE NashvilleHousing
Set SoldAsVacant = CASE When SoldAsVacant = 'Y' Then '1'
       When SoldAsVacant = 'Yes' THEN '1'
	   When SoldAsVacant = 'N' Then '0'
	   When SoldAsVacant = 'No' THEN  '0'
       ELSE SoldAsVacant
       END  
UPDATE NashvilleHousing
Set SoldAsVacant = convert(int, SoldAsVacant)

Select *
From NashvilleHousing
-----------------------------------------------------------------------------------------------------------------------------------------------------

-- Getting rid of Dubplicates
WITH DublicatedrowsCTE AS(
SELECT * ,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 OwnerAddress,
				 PropertyCity,
				 SalePrice
				 Order By UniqueID) number_row

From [dbo].[NashvilleHousing] 
)
DELETE
from DublicatedrowsCTE
where number_row > 1