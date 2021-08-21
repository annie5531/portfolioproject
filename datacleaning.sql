--cleaning data in sql query
select*
from portfolioproject.dbo.nashvillehousing

--standardize date  format
select saledateconverted,CONVERT(date,saledate)
from portfolioproject..nashvillehousing

ALTER TABLE nashvillehousing
add saledateconverted Date;

UPDATE nashvillehousing
set saledateconverted=convert(date,saledate)

--populate property address data
select *
from portfolioproject..nashvillehousing
order by Parcelid


select a.parcelid,a.propertyaddress,b.parcelid,b.propertyaddress,ISNULL(a.propertyaddress,b.propertyaddress)
from portfolioproject..nashvillehousing a
JOIN portfolioproject..nashvillehousing b
ON a.ParcelID=b.ParcelID
AND a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

UPDATE a
SET propertyaddress=ISNULL(a.propertyaddress,b.propertyaddress)
from portfolioproject..nashvillehousing a
JOIN portfolioproject..nashvillehousing b
ON a.ParcelID=b.ParcelID
AND a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

--Breaking out address into individual columns(Address,city,state)
select propertyaddress
from portfolioproject..nashvillehousing

select
substring(propertyaddress,1,CHARINDEX(',',propertyaddress)-1) as address
,substring(propertyaddress,CHARINDEX(',',propertyaddress)+1,LEN(PropertyAddress)) as address
from portfolioproject..nashvillehousing

ALTER TABLE nashvillehousing
Add propertysplitaddress Nvarchar(255);

UPDATE nashvillehousing
SET propertysplitaddress=SUBSTRING(propertyaddress,1,CHARINDEX(',',propertyaddress)-1)

ALTER TABLE nashvillehousing
add propertysplitcity Nvarchar(255);

UPDATE nashvillehousing
SET propertysplitcity=SUBSTRING(propertyaddress,CHARINDEX(',',propertyaddress)+1,LEN(PropertyAddress))

select *
from portfolioproject..nashvillehousing

select
PARSENAME(REPLACE(OwnerAddress,',','.'),3)
,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
,PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from portfolioproject..nashvillehousing


ALTER TABLE nashvillehousing
Add ownersplitaddress Nvarchar(255);

UPDATE nashvillehousing
SET ownersplitaddress=PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE nashvillehousing
add ownersplitcity Nvarchar(255);

UPDATE nashvillehousing
SET ownersplitcity=PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE nashvillehousing
add ownersplitstate Nvarchar(255);

UPDATE nashvillehousing
SET ownersplitstate=PARSENAME(REPLACE(OwnerAddress,',','.'),1)

--change Y and N to Yes and No in 'sold as vacant' field
select distinct(soldasvacant),count(soldasvacant)
from portfolioproject..nashvillehousing
group by soldasvacant
order by 2

select soldasvacant
,case when soldasvacant = 'Y' then 'Yes'
      when soldasvacant = 'N' then 'NO'
	  else soldasvacant
	  end
	  from portfolioproject..nashvillehousing

update nashvillehousing 
set soldasvacant=case when soldasvacant = 'Y' then 'Yes'
      when soldasvacant = 'N' then 'NO'
	  else soldasvacant
	  end

	  --Remove duplicates
WITH RowNumCTE AS(
select *,
    ROW_NUMBER() OVER(
	PARTITION BY parcelid,
	             propertyaddress,
				 saleprice,
				 saledate,
				 legalreference
				 ORDER BY
				    uniqueid
					)row_num
from portfolioproject..nashvillehousing
)
DELETE
from RowNumCTE
where row_num>1

--Delete unused columns
select *
from portfolioproject..nashvillehousing

ALTER TABLE portfolioproject..nashvillehousing
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress















