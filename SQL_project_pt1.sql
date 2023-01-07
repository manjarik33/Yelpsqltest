The first step was to import the JSON files into MS SQL. Some files had more than one layer1 nested elements.
I used Notepad++ edit the JSON file before running it in JSON viewer. I had to download the JSON Viewer Plugin.
Using the "replace" option in Notepad++, I added commas after each object (The original file had missing commas,
which were consequently giving me a JSON parse error). Additionally, I put a square bracket at the start and end of each JSON file.
I used the following SQL query to import the "business data" JSON file into MS SQL:

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
--Since, the business data JSON file had level 2 nesting, I took the columns with key-value pairs
--to excel. Each column with key-value pairs such as Ambience, GoodForMeal and Parking was exported
--to excel along with the unique business id values. Some business id records began with a hyphen.
--When these records were transferred into MS Excel, those particular cells yielded an error of "#NAME?"
--In order to solve this problem, I used the find and replace tool on excel and replaced each record's
--hyphen or =- with an '-. I then opened the file on notepad wherein I used the find and replace function again
--extensively to separate each key and value pair into two comma separated values. I then transported
--the file into excel as a Comma Separated Value/Delimited (.csv) file after which I imported the
--excel file into SSMS.This allowed me to break the second layer nesting for the purpose of analysis.
-- I used the following query to find the number of distinct categories:
