/
---Cleaning data in SQL queries
/

----looking at the whole dataset
select *
from [Portfolio Project]..NashvilleHousing

----Standardize the date format
select saledate
from [Portfolio Project]..NashvilleHousing

--update NashvilleHousing
--set SaleDate = convert(date,saledate)  ////It doesn't work

alter table nashvillehousing
add SaleDateConverted date;

update NashvilleHousing
set  SaleDateConverted = convert(date,saledate)

select saledateConverted
from [Portfolio Project]..NashvilleHousing
---------populate property adress
---Figuring out the issue
select *
from [Portfolio Project]..NashvilleHousing
where PropertyAddress is null
order by ParcelID --different uniqueid, same parcelid

----join this table by itself
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress)
from [Portfolio Project]..NashvilleHousing as a
join  [Portfolio Project]..NashvilleHousing as b
	on	a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set propertyaddress = isnull(a.PropertyAddress,b.PropertyAddress)
from [Portfolio Project]..NashvilleHousing as a
join  [Portfolio Project]..NashvilleHousing as b
	on	a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


---- Breaking out Address into Individual Columns (Address, City, State)
---looking at the propertyaddress column
select PropertyAddress
from [Portfolio Project]..NashvilleHousing
----
select
SUBSTRING(propertyaddress,1,charindex(',',propertyaddress)-1) as Adress
,SUBSTRING(propertyaddress,charindex(',',propertyaddress)+1 , LEN(propertyaddress)) as City
from [Portfolio Project]..NashvilleHousing
----Adding this 2 columns to the table----
alter table nashvillehousing
add Adress nvarchar(255);

update NashvilleHousing
set  Adress = SUBSTRING(propertyaddress,1,charindex(',',propertyaddress)-1) 

alter table nashvillehousing
add City nvarchar(255);

update NashvilleHousing
set  City = SUBSTRING(propertyaddress,charindex(',',propertyaddress)+1 , LEN(propertyaddress))
----------------split oweneradress------
select OwnerAddress
from [Portfolio Project]..NashvilleHousing
order by OwnerAddress desc


select
PARSENAME(replace(OwnerAddress,',','.'),3)
,PARSENAME(replace(OwnerAddress,',','.'),2)
,PARSENAME(replace(OwnerAddress,',','.'),1)
from [Portfolio Project].dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select *
From [Portfolio Project]..NashvilleHousing
where [UniqueID ]= 2045
----------convert Y and N to Yes and No in SoldasVacant column
select Distinct(SoldasVacant), count(soldasvacant)
from [Portfolio Project]..NashvilleHousing
group by SoldAsVacant   ----counting the distinct value in this column


select soldasvacant
,case when SoldAsVacant= 'Y' then 'Yes'
	  when SoldAsVacant= 'N' then 'NO'
	  else SoldAsVacant
	  end
from [Portfolio Project]..NashvilleHousing

Update NashvilleHousing
set SoldAsVacant= case when SoldAsVacant= 'Y' then 'Yes'
	  when SoldAsVacant= 'N' then 'NO'
	  else SoldAsVacant
	  end
---------------------------remove duplicate----
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

From [Portfolio Project]..NashvilleHousing
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



--------------Delete unusefull column----
Select *
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
