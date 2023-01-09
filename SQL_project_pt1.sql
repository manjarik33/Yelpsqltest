--The first step was to import the JSON files into MS SQL. Some files had more than one layer1 nested elements.
--I used Notepad++ edit the JSON file before running it in JSON viewer. I had to download the JSON Viewer Plugin.
--Using the "replace" option in Notepad++, I added commas after each object (The original file had missing commas,
--which were consequently giving me a JSON parse error). Additionally, I put a square bracket at the start and end of each JSON file.
--I used the following SQL query to import the "business data" JSON file into MS SQL:

SELECT * FROM OPENROWSET (BULK 'C:\Manjari December Project SQL\yelp_dataset_Database\yelp_academic_dataset_review_transferred.json', Single_CLOB)
AS import;

Declare @JSON varchar(max)
SELECT @JSON=BulkColumn
FROM OPENROWSET(BULK 'C:\Manjari December Project SQL\yelp_dataset_Database\yelp_academic_dataset_business.json', SINGLE_CLOB) import
SELECT TableA.*
FROM OPENJSON (@JSON)
WITH  (
   [business_id] VARCHAR(200),
   [name] VARCHAR(100),
   [address] NVARCHAR(300),
   [city] NVARCHAR(100),
   [state] NVARCHAR(50),
   [postal_code] NVARCHAR(100),
   [latitude] FLOAT(53),
   [longitude] FLOAT(53),
   [stars] FLOAT(53),
   [review_count] NVARCHAR(50),
   [is_open] NVARCHAR(50),
   [RestaurantsReservations] VARCHAR(100) '$.attributes.RestaurantsReservations',
   [RestaurantsGoodForGroups] NVARCHAR(50) '$.attributes.RestaurantsGoodForGroups',
   [RestaurantsAttire] NVARCHAR(50) '$.attributes.RestaurantsAttire',
   [BusinessAcceptsCreditCards] NVARCHAR(50) '$.attributes.BusinessAcceptsCreditCards',
   [WiFi] NVARCHAR(50) '$.attributes.WiFi',
   [HasTv] NVARCHAR(50) '$.attributes.HasTv',
   [RestaurantsTakeOut] NVARCHAR(50) '$.attributes.RestaurantsTakeOut',
   [Ambience] NVARCHAR(200) '$.attributes.Ambience',
   [GoodForKids] NVARCHAR(50) '$.attributes.GoodForKids',
   [GoodForMeal] NVARCHAR(500)'$.attributes.GoodForMeal',
   [NoiseLevel] NVARCHAR(100) '$.attributes.NoiseLevel',
   [RestaurantsPriceRange2] NVARCHAR(50) '$.attributes.RestaurantsPriceRange2',
   [Alcohol] NVARCHAR(100) '$.attributes.Alcohol',
   [DogsAllowed] NVARCHAR(50) '$.attributes.DogsAllowed',
   [HappyHour] NVARCHAR(50) '$.attributes.HappyHour',
   [RestaurantsDelivery] NVARCHAR(50) '$.attributes.RestaurantsDelivery',
   [WheelchairAccessible] NVARCHAR(50) '$.attributes.WheelchairAccessible',
   [OutdoorSeating] NVARCHAR(50) '$.attributes.OutdoorSeating',
   [RestaurantsTableService] NVARCHAR(50) '$.attributes.RestaurantsTableService',
   [BusinessParking] NVARCHAR (200) '$.attributes.BusinessParking',
   [categories] NVARCHAR (100),
   [Tuesday] NVARCHAR (100) '$.hours.Tuesday',
   [Wednesday] NVARCHAR (100) '$.hours.Wednesday',
   [Thursday] NVARCHAR (100) '$.hours.Thursday',
   [Friday] NVARCHAR (100) '$.hours.Friday',
   [Saturday] NVARCHAR (100) '$.hours.Saturday',
   [Sunday] NVARCHAR (100) '$.hours.Sunday',
   [hours] nvarchar(max) AS JSON
    ) as TableA

--JSON file (reviews table) with no nesting was imported with the following query:
SELECT * FROM OPENROWSET (BULK 'C:\Manjari December Project SQL\yelp_dataset_Database\yelp_academic_dataset_review_transferred.json', Single_CLOB)
AS import;
Declare @JSON varchar(max)
SELECT @JSON=BulkColumn
FROM OPENROWSET(BULK 'C:\Manjari December Project SQL\yelp_dataset_Database\yelp_academic_dataset_review_transferred.json', SINGLE_CLOB) import
SELECT TableC.* INTO dbo.RAWDATA_yelp_academic_dataset_review
FROM OPENJSON (@JSON)
WITH  (
[review_id] VARCHAR(100),
[user_id] VARCHAR(100),
[business_id] VARCHAR(100),
[stars] VARCHAR(100),
[useful] VARCHAR(50),
[funny] VARCHAR(50),
[cool] VARCHAR(50),
[text] VARCHAR(MAX)
) AS TableC

--All in all, 5 JSON files were imported onto MS SQL
--Since, the business data JSON file had level 2 nesting, I took the columns with key-value pairs to excel. Each column with key-value pairs such as Ambience, GoodForMeal and Parking was exported
--to excel along with the unique business id values. Some business id records began with a hyphen.When these records were transferred into MS Excel, those particular cells yielded an error of "#NAME?"
--In order to solve this problem, I used the find and replace tool on excel and replaced each record's hyphen or =- with an '-. I then opened the file on notepad wherein I used the find and replace function again
--extensively to separate each key and value pair into two comma separated values. I then transported
--the file into excel as a Comma Separated Value/Delimited (.csv) file after which I imported the
--excel file into SSMS.This allowed me to break the second layer nesting for the purpose of analysis.I used the following query to find the number of distinct categories:

SELECT DISTINCT category1 FROM [BusinessData].[dbo].[BusinessCategoriesFinal]
UNION
SELECT DISTINCT category2 FROM [BusinessData].[dbo].[BusinessCategoriesFinal]
UNION
SELECT DISTINCT category3 FROM [BusinessData].[dbo].[BusinessCategoriesFinal]
UNION
SELECT DISTINCT category4 FROM [BusinessData].[dbo].[BusinessCategoriesFinal]
UNION
SELECT DISTINCT category5 FROM [BusinessData].[dbo].[BusinessCategoriesFinal]
UNION
SELECT DISTINCT category6 FROM [BusinessData].[dbo].[BusinessCategoriesFinal]
UNION
SELECT DISTINCT category7 FROM [BusinessData].[dbo].[BusinessCategoriesFinal]


-- The query result yielded 5472 unique business categories, which was hard to perform analysis on. Hence, I created a new column called "Broad Categories" and manually assiend a broad category for all distinct 5472 records.
--To further simplify the binning of the 5000+ records, I only looked at Category1 (in the Business Categories Final Table) and noticed that it was populated for all records, unlike the other categories. To back this up, I did the following TSQL query:
--Category1 had a total of 1160 distinct values
SELECT *
FROM [BusinessData].[dbo].[BusinessCategoriesFinal]
WHERE category2 = ''

--I got 484 rows with empty values under category2 (the second column for categories)
--This backed up my rationale behind choosing category1 as the baseline category distinction column.

-- Hence, I had to export the category1 column associated with the unique business_id values to excel and manually bin them into broader categories.
--I then,added a null-valued column called broad categories to the original business dataset table which I updated for all 5000+ distinct
-- Before I altered the table, I created a backup table for all 5 tables using the following query:

SELECT *
INTO New_table_Name
FROM old_Table_name

--All the records in the original table were first altered with the new broad categories using an update statement in the following form:

UPDATE [BusinessData].[dbo].[BusinessCategoriesFinal] SET BroadCategory = 'Local Services' WHERE category1 = '3D Printing'
UPDATE [BusinessData].[dbo].[BusinessCategoriesFinal] SET BroadCategory = 'Food/Ethnic Restaurant' WHERE category1 = 'Acai Bowls'
UPDATE [BusinessData].[dbo].[BusinessCategoriesFinal] SET BroadCategory = 'Accessories' WHERE category1 = 'Accessories'
UPDATE [BusinessData].[dbo].[BusinessCategoriesFinal] SET BroadCategory = 'Professional Services' WHERE category1 = 'Accountants'
UPDATE [BusinessData].[dbo].[BusinessCategoriesFinal] SET BroadCategory = 'Beauty & Spas' WHERE category1 = 'Acne Treatment'
UPDATE [BusinessData].[dbo].[BusinessCategoriesFinal] SET BroadCategory = 'Outdoor Recreational/Sports/Fitness ' WHERE category1 = 'Active Life'
UPDATE [BusinessData].[dbo].[BusinessCategoriesFinal] SET BroadCategory = 'Health & Medical ' WHERE category1 = 'Acupuncture'

--Note, the update statement for 1160 distinct category1 values was formatted on Excel, and copy-pasted into the SSMS Query editor.
--And the null category1 columns were labeled as unclassified using the following update :

  UPDATE [dbo].[BusinessCategoriesFinal]
  SET BroadCategory = 'Uncategorized'
  WHERE BroadCategory IS NULL

--Before I did any analysis, I used the following codes to analyze the grain for each table:

--For the table RAWDATA_yelp_academic_dataset_business, the primary key was the business_id
--I noticed that some records in the business table had multiple businesses within the same postal code
--Thus, I created an aggregate table to sum the review count, average out the average stars, and the RestaurantsPriceRange2 column for these businesses.
--I then created an aggregate table with the averaged out values for the few records with identical postal codes
--Through this I was able to practice table creation with the TSQL script:
DROP TABLE Aggregatebusinesstable
CREATE TABLE Aggregatebusinesstable
(SeqID INT IDENTITY(1,1) NOT NULL,
name NVARCHAR(100) null,
address NVARCHAR(200) null,
city NVARCHAR(100) null,
state NVARCHAR(20) null,
postal_code NVARCHAR(50) null,
FinalCategory NVARCHAR(100) null,
reviewcount NVARCHAR(50) null,
avg_stars NVARCHAR(50) null,
nosofBusinessesinPostalCode NVARCHAR(50) null,
Avg_Price_Range NVARCHAR(40) null,
CONSTRAINT [dbo.pk_SeqID] PRIMARY KEY NONCLUSTERED
 (
 [SeqID] ASC
 ) WITH (PAD_INDEX=OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS =ON,
 ALLOW_PAGE_LOCKS=ON, FILLFACTOR=65) ON [PRIMARY],
 CONSTRAINT [dbo.uc_Master_ID] UNIQUE CLUSTERED
 (
	[name] ASC,
	[address] ASC,
	[city] ASC,
	[state] ASC,
	[postal_code] ASC,
	[FinalCategory] ASC
	) WITH (PAD_INDEX=OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON,
	ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]) ON [PRIMARY]
	GO
-------------------------------------------------------------------------------------------------------------
 INSERT INTO dbo.Aggregatebusinesstable(name,address,city,state, postal_code, Final_Category, reviewcount,
 avg_stars,nosofBusinessesinPostalCode,Avg_Price_Range)
 SELECT name,address,city,state, postal_code, FinalCategory, AVG(CAST(review_count AS INT)) as reviewcount ,
  AVG(CAST(stars AS FLOAT)) as avg_stars, count(*) as nosofBusinessesinPostalCode
 ,AVG(CAST(IIF((RestaurantsPriceRange2 = 'NONE' or RestaurantsPriceRange2 IS NULL), 0, RestaurantsPriceRange2) AS FLOAT))
 as Avg_Price_Range
  FROM [BusinessData].[dbo].[RAWDATA_yelp_academic_dataset_business_operating]
where is_open = '1'
  group by name,address,city,state, postal_code, FinalCategory
   	order by nosofBusinessesinPostalCode desc

--After the creation of the aggregate table, I found the business key or the set of columns that uniquely identified each row in an entity
--The following columns formed the business key for the aggregate business table : address,city,name, postal code and Final Category
--This business key could be verified with the code below:
SELECT Businessname,address,city,postal_code,FinalCategory, COUNT(*)
FROM [dbo].[Aggregatebusinesstable]
GROUP BY Businessname,address,city,postal_code, FinalCategory
HAVING COUNT(*)>1
--The above query yields an empty result indicating that there are no duplicate records for the combination of columns listed in the business key

--For the checkin table : RAWDATA_yelp_academic_dataset_checkin, there were only two columns : business_id and the checkin column
--Thus, it was concluded that the primary key here was the unique ID or the BUSINESS_ID
--For the tips table : RAWDATA_yelp_academic_dataset_tips, the primary key was the business_id
--In order to delete the duplicates, the following query was used:
SELECT user_id,business_id,date,compliment_count,text,COUNT(*)
FROM [dbo].[RAWDATA_yelp_academic_dataset_tips_table]
GROUP BY  user_id,business_id,date,compliment_count,text
HAVING COUNT(*)>1
ORDER BY COUNT(*) Desc
--59 rows of duplicates detected
--The tip with the maximum number of duplicates (6) was extracted using the following code:
SELECT *
FROM [dbo].[RAWDATA_yelp_academic_dataset_tips_table_BKP]
where text = 'We ordered a pizza on New Year''s Day, it never came. We called a few times and was told it was on the way. After 2.5 hours we told them to forget it! I don''t want a anything that''s been driving around for an hour and a half!!
Thought tonight we would try again! The pizza did show up RAW!! It''s baking in MY oven now!! Very frustrating!!'
and date = '2014-02-20 04:09:37'

--Since the tips table had no unique identifier column for the records, I had to generate one:
-- Adding a unique_id column in sql:

alter table [dbo].[RAWDATA_yelp_academic_dataset_tips_table]
add Unique_ID int identity(1,1)

DELETE FROM dbo.RAWDATA_yelp_academic_dataset_tips_table
WHERE Unique_ID NOT IN (
   SELECT MAX(Unique_ID) AS new_user_id
   FROM [dbo].[RAWDATA_yelp_academic_dataset_tips_table]
   GROUP BY user_id,business_id,date,compliment_count,text
  ); --67 rows were affected

--Now re-run the duplicates detection query:

SELECT user_id,business_id,date,compliment_count,text,COUNT(*)
FROM [dbo].[RAWDATA_yelp_academic_dataset_tips_table]
GROUP BY  user_id,business_id,date,compliment_count,text
HAVING COUNT(*)>1
ORDER BY COUNT(*) Desc

--You get a blank space in the result
--Re-running the grain analysis query using columns text and date
SELECT text,date, COUNT(*)
FROM [dbo].[RAWDATA_yelp_academic_dataset_tips_table]
GROUP BY text,date
HAVING COUNT(*)>1
--You get a blank result indicating that there are no duplicate values for each text and date combination
--Hence, after deleting the duplicates, the business key was the following combination of columns: text,date
--The primary key(surrogate key) for the tips table was the Unique_ID generated

--For the review table : RAWDATA_yelp_academic_dataset_review_BKP
--SELECT  text,useful,funny,cool,COUNT (*) AS count
FROM [dbo].[RAWDATA_yelp_academic_dataset_review]
GROUP BY text,useful,funny,cool
HAVING COUNT(*) > 1
ORDER BY COUNT(*) desc
--the same user could have posted the same review twice, and thus the review got two unique review id's
SELECT *
FROM [dbo].[RAWDATA_yelp_academic_dataset_review]
WHERE
text = 'I have eaten at just about every decent Indian restaurant in Philly and was not sure what to expect from sher-e-Punjab in media.  To my pleasant surprise the food is outstanding.  The samosas are on point as well as the nan bread.   The soups are tasty as well.  Absolutely love their Marsala dishes and what really make them are the quality of meat they use.  The chicken and lamb are high quality not that fatty stuff....which cannot be said at many Indian restaurants.   The tandoor is nicely spiced and really I haven''t had a dish I didn''t like there.  Have dined in and take out...both are great but obviously Indian is best served piping hot so sit in if you can.  Not to mention its byob so what more do you want?  Highly recommended.'
AND useful='0' AND funny ='0' AND cool ='0'
--although all review_id's are unique, the same review could have 5 unique review_id's like what's shown above
SELECT *
FROM [dbo].[RAWDATA_yelp_academic_dataset_review]
WHERE text= 'At the height of the Omicron surge, Wendy''s DOES NOT REQUIRE THEIR FOOD HANDLER EMPLOYEES TO WEAR MASKS! This is the height of corporate irresponsibility and lack of caring for their customers as well as their employees. Not going there any time soon and suggest you consider this wreckless no-health policy before you take a bite. If they can''t be bothered, then neither can I.'
AND useful='0' AND funny ='0' AND cool ='0'
--not all are duplicates, some users have written the same review for all branches of the same restaurant chain
SELECT user_id,business_id,stars,useful,funny,cool,text, COUNT(*)
FROM [dbo].[RAWDATA_yelp_academic_dataset_review]
GROUP BY user_id,business_id,stars,useful,funny,cool,text
HAVING COUNT(*)>1
ORDER BY COUNT(*) desc
--1038 duplicate records
--The review table has no business key, the review_id is the primary key

--Cities with most reviews:

select city,count(review_count) as total_review
from [dbo].[RAWDATA_yelp_academic_dataset_business_operating]
group by city
order by total_review desc;

--Philadelphia happened to be the city with the most reviews (14,577 reviews), followed by Tuscon(9262 reviews) and Tampa (9069 reviews)

--Which business_id has the maximum number of checkins?
--In order to answer this, I had to calculate the number of comma separated checkins for each record. This was calculated using the code below:

SELECT business_id,date, LEN(date) - LEN(REPLACE(date, ',', '')) + 1 AS NumberofCheckins
FROM [dbo].[RAWDATA_yelp_academic_dataset_checkin]

-- I then Inserted the results from the comma separated check-in count for each record into
--another table with the business_id listed
DROP TABLE NumberofCheckinstbl
SELECT business_id, date, LEN(date) - LEN(REPLACE(date, ',', '')) + 1 AS NumberofCheckins
INTO NumberofCheckinstbl
FROM [dbo].[RAWDATA_yelp_academic_dataset_checkin]

--Updated the original check-ins table with the net check-in count
--pertaining to each business
UPDATE [dbo].[RAWDATA_yelp_academic_dataset_checkin]
SET netcheckin = (
SELECT NumberofCheckins
FROM [dbo].[NumberofCheckinstbl]
WHERE RAWDATA_yelp_academic_dataset_checkin.business_id = NumberofCheckinstbl.business_id)

--Then, I wrote a query for the businesses with the maximum checkins that were also not closed.
SELECT b.Businessname, c.check_in_count, b.FinalCategory, b.categories
FROM [dbo].[RAWDATA_yelp_academic_dataset_checkin] c
INNER JOIN [dbo].[RAWDATA_yelp_academic_dataset_business_operating] b
ON b.business_id = c.business_id
WHERE is_open = '1'
ORDER BY Check_in_count desc

--I noticed there were some wrongly classified arts and entertianment final categories
--So I had to change all the wrongly classified arts and entertainment categories to adult Recreation
--Every business that had the word "bar" in it was switched over to adult recreation after adding some constraints:

UPDATE [dbo].[RAWDATA_yelp_academic_dataset_business_operating]
SET FinalCategory = 'Adult Recreation'
WHERE (NAME LIKE '%Bar'
OR   NAME LIKE '%Bar%')
AND   (NAME NOT LIKE '%Barber' AND NAME NOT LIKE '%Barber%')
AND    (NAME NOT LIKE 'Barnes%')
AND (NAME NOT LIKE '%Barbara%' AND NAME NOT LIKE '%Barbara' AND NAME NOT LIKE 'Barbara%')
AND (NAME NOT LIKE '%Bark%' AND NAME NOT LIKE '%Bark' AND NAME NOT LIKE 'Bark%')
AND (NAME NOT LIKE '%Barn%' AND NAME NOT LIKE '%Barn' AND NAME NOT LIKE 'Barn%')
AND (NAME NOT LIKE '%Bargain%' AND NAME NOT LIKE '%Bargain' AND NAME NOT LIKE 'Bargain%')
AND (NAME NOT LIKE '%Barry%' AND NAME NOT LIKE '%Barry' AND NAME NOT LIKE 'Barry%')
AND (NAME NOT LIKE '%Barbecue%' AND NAME NOT LIKE '%Barbecue' AND NAME NOT LIKE 'Barbecue%')
AND (NAME NOT LIKE '%Barbecue%' AND NAME NOT LIKE '%Barbecue' AND NAME NOT LIKE 'Barbecue%')
AND (NAME NOT LIKE '%Bare%' AND NAME NOT LIKE '%Bare' AND NAME NOT LIKE 'Bare%')
AND (NAME NOT LIKE '%Baron%' AND NAME NOT LIKE '%Baron' AND NAME NOT LIKE 'Baron%')
AND (NAME NOT LIKE '%Bards%' AND NAME NOT LIKE '%Bards' AND NAME NOT LIKE 'Bards%')
AND (NAME NOT LIKE '%Cabaray%' AND NAME NOT LIKE '%Cabaray' AND NAME NOT LIKE 'Cabaray%')
AND (NAME NOT LIKE '%Barclay%' AND NAME NOT LIKE '%Barclay' AND NAME NOT LIKE 'Barclay%')
AND (NAME NOT LIKE '%Bardmoor%' AND NAME NOT LIKE '%Bardmoor' AND NAME NOT LIKE 'Bardmoor%')
AND (NAME NOT LIKE '%Barua%' AND NAME NOT LIKE '%Barua' AND NAME NOT LIKE 'Barua%')
AND (NAME NOT LIKE '%Subaru%' AND NAME NOT LIKE '%Subaru' AND NAME NOT LIKE 'Subaru%')
AND (NAME NOT LIKE '%Fubar%' AND NAME NOT LIKE '%Fubar' AND NAME NOT LIKE 'Fubar%')
AND (NAME NOT LIKE '%Barca%' AND NAME NOT LIKE '%Barca' AND NAME NOT LIKE 'Barca%')
AND (FinalCategory NOT LIKE 'Adult Recreation')
AND (FinalCategory LIKE 'Arts & Entertainment')

--In order to further perform analysis on the nested elements that I did not extract while importing the JSON file,
--I manually exported the each column (Ambience, GoodForMeal, and Parking) along with the respective business_id's into notepad
--In notepad, I used the find and replace tool to separate each key value pair into comma separated values. For instance,
-- given a record from the "Ambience" column imported into notepad with its respective business_id : RRZ7p4EwjiWSKVQmOQRA3Q	{'touristy': False, 'hipster': False, 'romantic': False, 'divey': False, 'intimate': False, 'trendy': False, 'upscale': False, 'classy': True, 'casual': True},
--I separated all the values by commas using the find and replace tool like so : RRZ7p4EwjiWSKVQmOQRA3Q,touristy,False,hipster,False,romantic,False,divey,False,intimate,False,trendy,False,upscale,False,classy,True,casual,True
--This way, when I saved the notepad as a csv file and then exported it to excel, I would get all these values in distinct columns or in a CSV format, which I then imported into SSMS
--As a result, there were 18 columns imported into SQL (9 ambience categories, and their respective True/False/None values )
--However, in order to perform any analysis of these imported values, I had to use the trim function on SQL to trim out any empty spaces.
--For instance, if I performed the following query:
--Note: Ambcat1 is Ambience Category 1, Ambcat1val is Ambience Category 1 Value
SELECT *
	  FROM [BusinessData].[dbo].[RAWDATA_yelp_academic_dataset_Ambience_and_BusinessID]
	  where (Ambcat1) = 'touristy' and (Ambcat1val) = 'true'
--I would get an empty result
--To rectify this, I used the following query instead:
SELECT *
	  FROM [BusinessData].[dbo].[RAWDATA_yelp_academic_dataset_Ambience_and_BusinessID]
	  where trim(Ambcat1) = 'touristy' and trim(Ambcat1val) = 'true'
--The above query gave me all the business_id's pertaining to the ambience category of "touristy"
--The GoodForMeal and Parking column was extracted with the same method mentioned above
--Then, an inner join was performed to relate attributes in the Busines Table to the created Ambience Table

CREATE TABLE dbo.Ambienceforbusinesses
(business_id NVARCHAR(100) null,
BusinessName NVARCHAR(100) null,
address NVARCHAR(200) null,
city NVARCHAR(50) null,
state NVARCHAR(50) null,
postal_code NVARCHAR(100) null,
Ambcat1 NVARCHAR(50) null,
Ambcat1val NVARCHAR(50) null,
Ambcat2 NVARCHAR(50) null,
Ambcat2val NVARCHAR(50) null,
Ambcat3 NVARCHAR(50) null,
Ambcat3val NVARCHAR(50) null,
Ambcat4 NVARCHAR(50) null,
Ambcat4val NVARCHAR(50) null,
Ambcat5 NVARCHAR(50) null,
Ambcat5val NVARCHAR(50) null,
Ambcat6 NVARCHAR(50) null,
Ambcat6val NVARCHAR(50) null,
Ambcat7 NVARCHAR(50) null,
Ambcat7val NVARCHAR(50) null,
Ambcat8 NVARCHAR(50) null,
Ambcat8val NVARCHAR(50) null,
Ambcat9 NVARCHAR(50) null,
Ambcat9val NVARCHAR(50) null)

--Insert the results to create a table for ambience and businesses
INSERT INTO dbo.Ambienceforbusinesses(business_id,BusinessName,address,city,state, postal_code,
Ambcat1,Ambcat1val,Ambcat2,Ambcat2val,Ambcat3,Ambcat3val,Ambcat4,Ambcat4val,Ambcat5,Ambcat5val,Ambcat6,
Ambcat6val,Ambcat7,Ambcat7val,Ambcat8,Ambcat8val,Ambcat9,Ambcat9val)
SELECT business.business_id, business.BusinessName, business.address, business.city, business.state,
business.postal_code, ambience.Ambcat1,ambience.Ambcat1val,ambience.Ambcat2,ambience.Ambcat2val,ambience.Ambcat3,ambience.Ambcat3val,ambience.Ambcat4,ambience.Ambcat4val,ambience.Ambcat5,ambience.Ambcat5val,
ambience.Ambcat6,ambience.Ambcat6val,ambience.Ambcat7,ambience.Ambcat7val,ambience.Ambcat8,ambience.Ambcat8val,ambience.Ambcat9,ambience.Ambcat9val
FROM [dbo].[RAWDATA_yelp_academic_dataset_business_operating] business
INNER JOIN [dbo].[Ambience] Ambience
ON business.business_id = Ambience.business_id
WHERE
(trim(Ambcat1) <> '{}"'
  OR trim(Ambcat2) <> '{}"'
  OR trim(Ambcat3) <> '{}"'
  OR trim(Ambcat4) <> '{}"'
  OR trim(Ambcat5) <> '{}"'
  OR trim(Ambcat6) <> '{}"'
  OR trim(Ambcat7) <> '{}"'
  OR trim(Ambcat8) <> '{}"'
  OR trim(Ambcat9) <> '{}"')
  AND
(trim(Ambcat1) = 'None"'
  OR trim(Ambcat2) <> 'None"'
  OR trim(Ambcat3) <> 'None"'
  OR trim(Ambcat4) <> 'None"'
  OR trim(Ambcat5) <> 'None"'
  OR trim(Ambcat6) <> 'None"'
  OR trim(Ambcat7) <> 'None"'
  OR trim(Ambcat8) <> 'None"'
  OR trim(Ambcat9) <> 'None"')
AND (Ambcat1 <> 'NULL')

--Which restaurants have the highest star rating, and for what GoodForMeal(breakfast,dinner,lunch,dessert,latenight,brunch) Categories:
--SQL Query:
SELECT a.BusinessName,a.address,a.city,a.state,a.postal_code,a.latitude,a.longitude,a.stars,a.review_count,a.Meal,
a.MealValue from
(
SELECT b.BusinessName,address,city,state,postal_code,latitude,longitude,stars,review_count,GFM_tblcat1 as
Meal, GFM_tblcat1val as MealValue
  FROM [BusinessData].[dbo].[RAWDATA_yelp_academic_dataset_business_operating] b
  JOIN [dbo].[GoodForMealTable] g
  ON b.business_id = g.business_id
  WHERE
  trim(GFM_tblcat1) IN (SELECT DISTINCT GFM_tblcat1 FROM DBO.GoodForMealTable WHERE
  GFM_tblcat1 <> 'None' and GFM_tblcat1 is not null and GFM_tblcat1 <> 'NULL') and trim(GFM_tblcat1val) = 'True'
AND (is_open = '1')
AND (FinalCategory = 'Food/Ethnic Restaurants' OR FinalCategory = 'Adult Recreation')
  ) a

  union

SELECT c.BusinessName,c.address,c.city,c.state,c.postal_code,c.latitude,c.longitude,c.stars,c.review_count,c.Meal,
c.MealValue FROM
(
SELECT b.BusinessName,address,city,state,postal_code,latitude,longitude,stars,review_count,GFM_tblcat2 as
Meal, GFM_tblcat2val as MealValue
  FROM [BusinessData].[dbo].[RAWDATA_yelp_academic_dataset_business_operating] b
  JOIN [dbo].[GoodForMealTable] g
  ON b.business_id = g.business_id
  WHERE
  trim(GFM_tblcat2) IN (SELECT DISTINCT GFM_tblcat2 FROM DBO.GoodForMealTable WHERE
  GFM_tblcat2 <> 'None' and GFM_tblcat2 is not null and GFM_tblcat2 <> 'NULL') and trim(GFM_tblcat2val) = 'True'
AND (is_open = '1')
AND (FinalCategory = 'Food/Ethnic Restaurants' OR FinalCategory = 'Adult Recreation')
  ) as c

  union

SELECT d.BusinessName,d.address,d.city,d.state,d.postal_code,d.latitude,d.longitude,d.stars,d.review_count,d.Meal,
d.MealValue FROM
(
SELECT b.BusinessName,address,city,state,postal_code,latitude,longitude,stars,review_count,GFM_tblcat3 as
Meal, GFM_tblcat3val as MealValue
  FROM [BusinessData].[dbo].[RAWDATA_yelp_academic_dataset_business_operating] b
  JOIN [dbo].[GoodForMealTable] g
  ON b.business_id = g.business_id
  WHERE
   trim(GFM_tblcat3) IN (SELECT DISTINCT GFM_tblcat3 FROM DBO.GoodForMealTable WHERE
  GFM_tblcat3 <> 'None' and GFM_tblcat3 is not null and GFM_tblcat3 <> 'NULL') and trim(GFM_tblcat3val) = 'True'
AND (is_open = '1')
AND (FinalCategory = 'Food/Ethnic Restaurants' OR FinalCategory = 'Adult Recreation')
  ) d

 union

SELECT e.BusinessName,e.address,e.city,e.state,e.postal_code,e.latitude,e.longitude,e.stars,e.review_count,e.Meal,
e.MealValue FROM
(
SELECT b.BusinessName,address,city,state,postal_code,latitude,longitude,stars,review_count,GFM_tblcat4 as
Meal, GFM_tblcat4val as MealValue
  FROM [BusinessData].[dbo].[RAWDATA_yelp_academic_dataset_business_operating] b
  JOIN [dbo].[GoodForMealTable] g
  ON b.business_id = g.business_id
  WHERE
 trim(GFM_tblcat4) IN (SELECT DISTINCT GFM_tblcat4 FROM DBO.GoodForMealTable WHERE
  GFM_tblcat4 <> 'None' and GFM_tblcat4 is not null and GFM_tblcat4 <> 'NULL') and trim(GFM_tblcat4val) = 'True'
AND (is_open = '1')
AND (FinalCategory = 'Food/Ethnic Restaurants' OR FinalCategory = 'Adult Recreation')
  ) e

union

SELECT f.BusinessName,f.address,f.city,f.state,f.postal_code,f.latitude,f.longitude,f.stars,f.review_count,f.Meal,
f.MealValue FROM
(
SELECT b.BusinessName,address,city,state,postal_code,latitude,longitude,stars,review_count,GFM_tblcat5 as
Meal, GFM_tblcat5val as MealValue
  FROM [BusinessData].[dbo].[RAWDATA_yelp_academic_dataset_business_operating] b
  JOIN [dbo].[GoodForMealTable] g
  ON b.business_id = g.business_id
  WHERE
trim(GFM_tblcat5) IN (SELECT DISTINCT GFM_tblcat5 FROM DBO.GoodForMealTable WHERE
  GFM_tblcat5 <> 'None' and GFM_tblcat5 is not null and GFM_tblcat5 <> 'NULL') and trim(GFM_tblcat5val) = 'True'
AND (is_open = '1')
AND (FinalCategory = 'Food/Ethnic Restaurants' OR FinalCategory = 'Adult Recreation')
  ) f

union

SELECT h.BusinessName, h.address, h.city, h.state, h.postal_code, h.latitude, h.longitude, h.stars, h.review_count,h.Meal,
h.MealValue FROM
(
SELECT b.BusinessName,address,city,state,postal_code,latitude,longitude,stars,review_count,GFM_tblcat6 as
Meal, GFM_tblcat6val as MealValue
  FROM [BusinessData].[dbo].[RAWDATA_yelp_academic_dataset_business_operating] b
  JOIN [dbo].[GoodForMealTable] g
  ON b.business_id = g.business_id
  WHERE
trim(GFM_tblcat6) IN (SELECT DISTINCT GFM_tblcat6 FROM DBO.GoodForMealTable WHERE
  GFM_tblcat6 <> 'None' and GFM_tblcat6 is not null and GFM_tblcat6 <> 'NULL') and trim(GFM_tblcat6val) = 'True'
AND (is_open = '1')
AND (FinalCategory = 'Food/Ethnic Restaurants' OR FinalCategory = 'Adult Recreation')
  )  h
  ORDER BY Meal,stars DESC
--All the 5 star ratings were only givne to the restaurants that were good for Breakfast
--Note, some businesses did not have data for the Good For Meal column

--Additionally, before carrying out any analysis on Tableau, I had to clean the Noise Level column with the following query:
UPDATE [dbo].[RAWDATA_yelp_academic_dataset_business_operating] SET NoiseLevel = 'loud' WHERE NoiseLevel = 'u''loud'''
UPDATE [dbo].[RAWDATA_yelp_academic_dataset_business_operating] SET NoiseLevel = 'quiet' WHERE NoiseLevel = '''quiet'''
UPDATE [dbo].[RAWDATA_yelp_academic_dataset_business_operating] SET NoiseLevel = 'very loud' WHERE NoiseLevel = '''very_loud'''
UPDATE [dbo].[RAWDATA_yelp_academic_dataset_business_operating] SET NoiseLevel = 'average' WHERE NoiseLevel = 'u''average'''
UPDATE [dbo].[RAWDATA_yelp_academic_dataset_business_operating] SET NoiseLevel = 'quiet' WHERE NoiseLevel = 'u''quiet'''
UPDATE [dbo].[RAWDATA_yelp_academic_dataset_business_operating] SET NoiseLevel = 'very loud' WHERE NoiseLevel = 'u''very_loud'''
UPDATE [dbo].[RAWDATA_yelp_academic_dataset_business_operating] SET NoiseLevel = 'average' WHERE NoiseLevel = '''average'''
UPDATE [dbo].[RAWDATA_yelp_academic_dataset_business_operating] SET NoiseLevel = 'loud' WHERE NoiseLevel = '''loud'''

--I also joined all the Ambience Table with Business Data to perform an analysis over Tableau regarding the ambience category and the star ratings or the review counts for different restaurants:
Deriving all the Ambience Categories and joining with business operating data :


SELECT a.BusinessName,a.address,a.city,a.state,a.postal_code,a.latitude,a.longitude,a.stars,a.review_count,a.AmbienceCategory,
a.AmbienceCategoryValue,a.FinalCategory, a.RestaurantsPriceRange2 from
(
SELECT b.BusinessName,b.address,b.city,b.state,b.postal_code,b.latitude,b.longitude,b.stars,b.review_count,Ambcat1 as
AmbienceCategory, Ambcat1val as AmbienceCategoryValue, b.FinalCategory, b.RestaurantsPriceRange2
  FROM [BusinessData].[dbo].[RAWDATA_yelp_academic_dataset_business_operating] b
  JOIN [dbo].[Ambienceforbusinesses] g
  ON b.business_id = g.business_id
  WHERE
  trim(Ambcat1) IN (SELECT DISTINCT trim(Ambcat1) FROM [dbo].[Ambienceforbusinesses] WHERE
  trim(Ambcat1) <> '') and trim(Ambcat1val) = 'True'
AND (is_open = '1')
AND (FinalCategory = 'Food/Ethnic Restaurants' OR FinalCategory = 'Adult Recreation')
  ) a
  union

SELECT c.BusinessName,c.address,c.city,c.state,c.postal_code,c.latitude,c.longitude,c.stars,c.review_count,c.AmbienceCategory,
c.AmbienceCategoryValue,c.FinalCategory, c.RestaurantsPriceRange2 from
(
SELECT b.BusinessName,b.address,b.city,b.state,b.postal_code,b.latitude,b.longitude,b.stars,b.review_count,Ambcat2 as
AmbienceCategory, Ambcat2val as AmbienceCategoryValue, b.FinalCategory, b.RestaurantsPriceRange2
  FROM [BusinessData].[dbo].[RAWDATA_yelp_academic_dataset_business_operating] b
  JOIN [dbo].[Ambienceforbusinesses] g
  ON b.business_id = g.business_id
  WHERE
  trim(Ambcat2) IN (SELECT DISTINCT trim(Ambcat2) FROM [dbo].[Ambienceforbusinesses] WHERE
  trim(Ambcat2) <> '') and trim(Ambcat2val) = 'True'
AND (is_open = '1')
AND (FinalCategory = 'Food/Ethnic Restaurants' OR FinalCategory = 'Adult Recreation')
  ) c

  union

SELECT d.BusinessName,d.address,d.city,d.state,d.postal_code,d.latitude,d.longitude,d.stars,d.review_count,d.AmbienceCategory,
d.AmbienceCategoryValue,d.FinalCategory, d.RestaurantsPriceRange2 from

(
SELECT b.BusinessName,b.address,b.city,b.state,b.postal_code,b.latitude,b.longitude,b.stars,b.review_count,Ambcat3 as
AmbienceCategory, Ambcat3val as AmbienceCategoryValue, b.FinalCategory, b.RestaurantsPriceRange2
  FROM [BusinessData].[dbo].[RAWDATA_yelp_academic_dataset_business_operating] b
  JOIN [dbo].[Ambienceforbusinesses] g
  ON b.business_id = g.business_id
  WHERE
  trim(Ambcat3) IN (SELECT DISTINCT trim(Ambcat3) FROM [dbo].[Ambienceforbusinesses] WHERE
  trim(Ambcat3) <> '') and trim(Ambcat3val) = 'True'
AND (is_open = '1')
AND (FinalCategory = 'Food/Ethnic Restaurants' OR FinalCategory = 'Adult Recreation')
  ) d

  union

  SELECT e.BusinessName,e.address,e.city,e.state,e.postal_code,e.latitude,e.longitude,e.stars,e.review_count,e.AmbienceCategory,
e.AmbienceCategoryValue,e.FinalCategory, e.RestaurantsPriceRange2 from

(
SELECT b.BusinessName,b.address,b.city,b.state,b.postal_code,b.latitude,b.longitude,b.stars,b.review_count,Ambcat4 as
AmbienceCategory, Ambcat4val as AmbienceCategoryValue, b.FinalCategory,b.RestaurantsPriceRange2
  FROM [BusinessData].[dbo].[RAWDATA_yelp_academic_dataset_business_operating] b
  JOIN [dbo].[Ambienceforbusinesses] g
  ON b.business_id = g.business_id
  WHERE
  trim(Ambcat4) IN (SELECT DISTINCT trim(Ambcat4) FROM [dbo].[Ambienceforbusinesses] WHERE
  trim(Ambcat4) <> '') and trim(Ambcat4val) = 'True'
AND (is_open = '1')
AND (FinalCategory = 'Food/Ethnic Restaurants' OR FinalCategory = 'Adult Recreation')
  ) e

  union

  SELECT f.BusinessName,f.address,f.city,f.state,f.postal_code,f.latitude,f.longitude,f.stars,f.review_count,f.AmbienceCategory,
f.AmbienceCategoryValue,f.FinalCategory,f.RestaurantsPriceRange2 from

(
SELECT b.BusinessName,b.address,b.city,b.state,b.postal_code,b.latitude,b.longitude,b.stars,b.review_count,Ambcat5 as
AmbienceCategory, Ambcat5val as AmbienceCategoryValue, b.FinalCategory,b.RestaurantsPriceRange2
  FROM [BusinessData].[dbo].[RAWDATA_yelp_academic_dataset_business_operating] b
  JOIN [dbo].[Ambienceforbusinesses] g
  ON b.business_id = g.business_id
  WHERE
  trim(Ambcat5) IN (SELECT DISTINCT trim(Ambcat5) FROM [dbo].[Ambienceforbusinesses] WHERE
  trim(Ambcat5) <> '') and trim(Ambcat5val) = 'True'
AND (is_open = '1')
AND (FinalCategory = 'Food/Ethnic Restaurants' OR FinalCategory = 'Adult Recreation')
  ) f

  union

   SELECT h.BusinessName,h.address,h.city,h.state,h.postal_code,h.latitude,h.longitude,h.stars,h.review_count,h.AmbienceCategory,
h.AmbienceCategoryValue,h.FinalCategory, h.RestaurantsPriceRange2 from

(
SELECT b.BusinessName,b.address,b.city,b.state,b.postal_code,b.latitude,b.longitude,b.stars,b.review_count,Ambcat6 as
AmbienceCategory, Ambcat6val as AmbienceCategoryValue, b.FinalCategory, b.RestaurantsPriceRange2
  FROM [BusinessData].[dbo].[RAWDATA_yelp_academic_dataset_business_operating] b
  JOIN [dbo].[Ambienceforbusinesses] g
  ON b.business_id = g.business_id
  WHERE
  trim(Ambcat6) IN (SELECT DISTINCT trim(Ambcat6) FROM [dbo].[Ambienceforbusinesses] WHERE
  trim(Ambcat6) <> '') and trim(Ambcat6val) = 'True'
AND (is_open = '1')
AND (FinalCategory = 'Food/Ethnic Restaurants' OR FinalCategory = 'Adult Recreation')
  ) h

  union

  SELECT i.BusinessName,i.address,i.city,i.state,i.postal_code,i.latitude,i.longitude,i.stars,i.review_count,i.AmbienceCategory,
i.AmbienceCategoryValue,i.FinalCategory, i.RestaurantsPriceRange2 from

(
SELECT b.BusinessName,b.address,b.city,b.state,b.postal_code,b.latitude,b.longitude,b.stars,b.review_count,Ambcat7 as
AmbienceCategory, Ambcat7val as AmbienceCategoryValue, b.FinalCategory,b.RestaurantsPriceRange2
  FROM [BusinessData].[dbo].[RAWDATA_yelp_academic_dataset_business_operating] b
  JOIN [dbo].[Ambienceforbusinesses] g
  ON b.business_id = g.business_id
  WHERE
  trim(Ambcat7) IN (SELECT DISTINCT TRIM(Ambcat7) FROM [dbo].[Ambienceforbusinesses] WHERE
  TRIM(Ambcat7) <> '') and trim(Ambcat7val) = 'True'
AND (is_open = '1')
AND (FinalCategory = 'Food/Ethnic Restaurants' OR FinalCategory = 'Adult Recreation')
  ) i

  union

  SELECT j.BusinessName,j.address,j.city,j.state,j.postal_code,j.latitude,j.longitude,j.stars,j.review_count,j.AmbienceCategory,
j.AmbienceCategoryValue,j.FinalCategory, j.RestaurantsPriceRange2 from

(
SELECT b.BusinessName,b.address,b.city,b.state,b.postal_code,b.latitude,b.longitude,b.stars,b.review_count,Ambcat8 as
AmbienceCategory, Ambcat8val as AmbienceCategoryValue, b.FinalCategory, b.RestaurantsPriceRange2
  FROM [BusinessData].[dbo].[RAWDATA_yelp_academic_dataset_business_operating] b
  JOIN [dbo].[Ambienceforbusinesses] g
  ON b.business_id = g.business_id
  WHERE
  trim(Ambcat8) IN (SELECT DISTINCT TRIM(Ambcat8) FROM [dbo].[Ambienceforbusinesses] WHERE
  TRIM(Ambcat8) <> '') and trim(Ambcat8val) = 'True'
AND (is_open = '1')
AND (FinalCategory = 'Food/Ethnic Restaurants' OR FinalCategory = 'Adult Recreation')
  ) j

union


SELECT k.BusinessName,k.address,k.city,k.state,k.postal_code,k.latitude,k.longitude,k.stars,k.review_count,k.AmbienceCategory,
k.AmbienceCategoryValue,k.FinalCategory,k.RestaurantsPriceRange2 from

(
SELECT b.BusinessName,b.address,b.city,b.state,b.postal_code,b.latitude,b.longitude,b.stars,b.review_count,b.RestaurantsPriceRange2,Ambcat9 as
AmbienceCategory, Ambcat9val as AmbienceCategoryValue, b.FinalCategory
  FROM [BusinessData].[dbo].[RAWDATA_yelp_academic_dataset_business_operating] b
  JOIN [dbo].[Ambienceforbusinesses] g
  ON b.business_id = g.business_id
  WHERE
  trim(Ambcat9) IN (SELECT DISTINCT TRIM(Ambcat9) FROM [dbo].[Ambienceforbusinesses] WHERE
  TRIM(Ambcat9) <> '') and trim(Ambcat9val) = 'True'
AND (is_open = '1')
AND (FinalCategory = 'Food/Ethnic Restaurants' OR FinalCategory = 'Adult Recreation')
) k

--The following code was used to analyze the top 100 ethnic restaurants, average stars, and price ranges based on the total review count

SELECT TOP (20) b.BusinessName,b.address,b.city,b.state,b.postal_code, b.stars, b.review_count, b.RestaurantsPriceRange2, b.categories, b.FinalCategory, b.Category1,
GFM_tblcat1,GFM_tblcat1val,GFM_tblcat2,GFM_tblcat2val,GFM_tblcat3,GFM_tblcat3val,GFM_tblcat4,GFM_tblcat4val,GFM_tblcat5,GFM_tblcat5val,GFM_tblcat6,GFM_tblcat6val,
Ambcat1,Ambcat1val,Ambcat2,Ambcat2val,Ambcat3,Ambcat3val,Ambcat4,Ambcat4val,Ambcat5,Ambcat5val,Ambcat6,Ambcat6val,Ambcat7,Ambcat7val,Ambcat8,Ambcat8val,Ambcat9,Ambcat9val
  FROM [dbo].[RAWDATA_yelp_academic_dataset_business_operating] b
  JOIN [dbo].[GoodForMealTable] a
  on b.business_id = a.business_id
  JOIN [dbo].[Ambience] ab
  on a.business_id = ab.business_id
  WHERE
  Category1  IN ('Bangladeshi','Chinese','Greek','Haitian','Japanese',
  'Malaysian','Mongolian','Syrian','Venezuelan','Argentine','British','Cambodian',
  'Eastern European','Lebanese','Middle Eastern','Puerto Rican','Somali','Thai',
  'Ukrainian','Egyptian','Georgian','Iberian','Korean','Mediterranean','New Mexican Cuisine',
  'Nicaraguan','Persian/Iranian','Scandinavian','Singaporean','Southern','Burmese',
  'Cuban','Dominican','Himalayan/Nepalese','Indian','Laotian','Portuguese',
  'Russian','Vietnamese','Afghan','Arabic','Brazilian','Colombian','Ethiopian',
  'Irish','Pakistani','Shanghainese','Belgian','Canadian (New)','Caribbean',
  'Honduran','Hungarian','Moroccan','Peruvian','Sardinian','Sicilian','Taiwanese',
  'Uzbek','Filipino','French','German','Latin American','Mexican','Spanish','Tuscan',
  'Cantonese','Hainan','Hawaiian','Indonesian','Italian','Pan Asian','Polish',
  'Salvadoran','Senegalese','Sri Lankan','Turkish')
  AND FinalCategory = 'Food/Ethnic Restaurants'
  AND is_open = '1'
  AND RestaurantsPriceRange2 IS NOT NULL
  ORDER BY cast(review_count AS INT) desc
