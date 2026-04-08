SELECT * FROM global_lay.globalay;

-- Create table copy to avoid any mess in the origial one
CREATE table layoffs_staging
LIKE globalay;

SELECT * FROM global_lay.layoffs_staging;

INSERT layoffs_staging
SELECT * FROM global_lay.globalay; 

SELECT * FROM global_lay.layoffs_staging;

-- 1 Remove Duplicates
with duplicate_cte AS
(
select * ,
row_number() over(
PARTITION BY company ,location , industry , total_laid_off , percentage_laid_off , `date`, stage , country , funds_raised_millions) AS row_num
FROM global_lay.layoffs_staging
)

select *  from duplicate_cte
where row_num > 1;

SELECT * 
FROM global_lay.layoffs_staging
where company = 'Cazoo';


CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


select * from layoffs_staging2;

INSERT INTO layoffs_staging2
select * ,
row_number() over(
PARTITION BY company ,location , industry , total_laid_off , percentage_laid_off , `date`, stage , country , funds_raised_millions) AS row_num
FROM global_lay.layoffs_staging;



SET SQL_SAFE_UPDATES = 0;
DELETE 
from layoffs_staging2
WHERE row_num > 1;

select * 
from layoffs_staging2
WHERE row_num > 1;

select * from layoffs_staging2;


-- 2 Standardize the Data ( finding issue in data and fix it )
-- we fix company
SELECT company, trim(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = trim(company);

-- we fix industry 
SELECT distinct industry
FROM layoffs_staging2
WHERE industry LIKE 'crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
where industry LIKE 'Crypto%';

SELECT distinct industry
FROM layoffs_staging2
order by 1;

-- we fix date from text to type date
select `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2;


UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

select `date`
FROM layoffs_staging2;

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- 3 Null Values or blank values 
-- we have some null in industry first of all we see for example if columns have same company and same location i believe they are in same industry 
-- like airbnb it's traveling do we gonna make a query to make sure that they are in the same industry 
UPDATE layoffs_staging2
set industry = NULL
where industry = ''; 

select t1.industry, t2.industry
from layoffs_staging2 t1
JOIN layoffs_staging2 t2
     ON t1.company = t2.company
Where (t1.industry IS NULL OR t1.industry= '')
AND t2.industry IS NOT NULL;


UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
     ON t1.company = t2.company
SET t1.industry = t2.industry
Where (t1.industry IS NULL OR t1.industry= '')
AND t2.industry IS NOT NULL;

select industry
from layoffs_staging2;

-- from this we can that it's no meaning to keep this because since we don't have total_laid_off and percentage_laid_off 
-- so we gonna delete it 
SELECT * 
from layoffs_staging2
where total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE
from layoffs_staging2
where total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- 4 Remove Any Columns

ALTER TABLE layoffs_staging2
DROP column row_num;

SELECT * 
from layoffs_staging2