--DROP table Intern

--EXEC sp_rename  'InternSrc','Intern';
use CognifyIntern
Select top 20 *   from Intern

-------------------------------------------------------------------
-- Determine the top three most common cuisines in the dataset
SELECT TOP 3 
		cuisines ,
		COUNT(*) as CuisineCount
FROM 
	Intern
GROUP BY  
	cuisines 
ORDER BY
	CuisineCount DESC
-------------------------------------------------------------------
---- Calculate the percentage of restaurants that serve each of the top  cuisines
WITH Cuisine_Count AS (
    SELECT  Cuisines, 
			COUNT(DISTINCT Restaurant_ID) AS CC
    FROM 
			Intern
    GROUP BY 
			Cuisines
),
TotalResCount AS (
    SELECT 
			COUNT(DISTINCT Restaurant_ID) AS Total_Count
    FROM 
			Intern
)
	SELECT top 5
			cc.Cuisines,
			cc.CC AS Cuisine_Restaurant_Count,
			ROUND(100.0 * cc.CC / tr.Total_Count, 2)  AS Percentage_Restaurant
	FROM 
			Cuisine_Count cc, 
			TotalResCount tr
	ORDER BY 
			Percentage_Restaurant DESC;
-------------------------------------------------------------------
--Identify the city with the highest number  of restaurants in the dataset.

SELECT TOP 10
		City_c AS City,
		Count(DISTINCT Restaurant_ID) AS No_of_Restaurant
FROM 
	Intern
GROUP BY 
	City_c
ORDER BY	
	No_of_Restaurant DESC
-------------------------------------------------------------------
--Calculate the average rating for restaurants in each city

SELECT
	City_c AS City,
	ROUND(AVG(Aggregate_rating),2) AS AvgRatCity
FROM
	Intern
GROUP BY 
	City_c
ORDER BY 
	AvgRatCity DESC
-------------------------------------------------------------------
--  Determine the city with the highest average rating

SELECT top 1
	City_c AS City,
	ROUND(AVG(Aggregate_rating),2) AS AvgRatCity
FROM
	Intern
GROUP BY 
	City_c
ORDER BY 
	AvgRatCity DESC
-------------------------------------------------------------------
--Calculate the percentage of restaurants in each price range category

WITH Total_Res AS (
	SELECT COUNT(Restaurant_ID) AS TotalResCou 
	FROM Intern
)
SELECT
	I.Price_range,
	COUNT(I.Restaurant_ID) AS ResCount,
	T.TotalResCou,
	ROUND(100.0 * COUNT(I.Restaurant_ID) / T.TotalResCou, 2) AS Percentage
FROM 
	Intern I,
	Total_Res T
GROUP BY 
	I.Price_range, T.TotalResCou
ORDER BY 
	Percentage DESC; 
-------------------------------------------------------------------
--Determine the percentage of restaurants that offer online delivery
WITH OnlineDelivery as(
	SELECT count(*) as OnlineDelRes FROM Intern where Has_Online_delivery='yes'
),
TotalRestaurant as (
		SELECT COUNT(*) as TotalRes FROM Intern )
SELECT 
    100.0 * OnlineDelivery.OnlineDelRes / TotalRestaurant.TotalRes AS OnlineDeliveryPercentage
FROM 
    OnlineDelivery, TotalRestaurant;
-------------------------------------------------------------------
--Compare the average ratings of restaurants  with and without online delivery.

SELECT 'Aggregrate Rating With Online Delivery' ,AVG(Aggregate_rating) as AverageRating FROM Intern Where Has_Online_delivery='Yes'
UNION ALL
SELECT 'Aggregrate Rating Without Online Delivery', AVG(Aggregate_rating) as AverageRating  FROM Intern Where Has_Online_delivery='No'
-------------------------------------------------------------------
--Calculate the average number of votes  received by restaurants.
SELECT 
		DISTINCT Restaurant_ID,
		sum(votes) as AverageVotes
FROM Intern
GROUP BY Restaurant_ID
ORDER BY AverageVotes DESC
-------------------------------------------------------------------
-- Identify the most common combinations of  cuisines in the dataset.
SELECT 
		Cuisines,
		COUNT(cuisines) as CuisineCount
FROM Intern
group by Cuisines
order by CuisineCount desc
-------------------------------------------------------------------
--Determine if certain cuisine combinations tend to have higher ratings.
SELECT 
    Cuisines,
    AVG(Aggregate_rating) AS AverageRating
FROM 
    Intern
GROUP BY 
    Cuisines
HAVING 
    AVG(Aggregate_rating) > (
        SELECT AVG(Aggregate_rating) FROM Intern
    )
-------------------------------------------------------------------
-- Identify any patterns or clusters of  restaurants in specific areas
SELECT 
City_c,
COUNT(*) AS RestaurantCount,
avg(Aggregate_rating) as AverageRating
FROM Intern
group by City_c
ORDER BY RestaurantCount DESC

SELECT 
    City_c, 
    Cuisines, 
    COUNT(*) AS CuisinesCount,
    AVG(Aggregate_rating) AS AvgRating
FROM 
    Intern
GROUP BY 
    City_c, Cuisines
ORDER BY 
    CuisinesCount DESC;
-------------------------------------------------------------------
--Identify if there are any restaurant chains  present in the dataset
SELECT 
 Restaurant_Names,
 Count(*) as ResChain
FROM 
	Intern
GROUP BY Restaurant_Names
HAVING  Count(*) > 1
ORDER BY ResChain DESC
-------------------------------------------------------------------
--Analyze the ratings and popularity of different restaurant chains.
SELECT 
    Restaurant_Names,
    COUNT(*) AS OutletCount,                    
    AVG(Aggregate_rating) AS AverageRating       
FROM 
    Intern
GROUP BY 
    Restaurant_Names
HAVING 
    COUNT(*) > 1                                  
ORDER BY 
    OutletCount DESC;
-------------------------------------------------------------------
--Analyze the text reviews to identify the most common positive and negative keywords.
SELECT 
    Restaurant_Names,
    CASE 
        WHEN Rating_text IN ('Excellent', 'Very Good', 'Good', 'Average') 
            THEN 'Positive Keyword'
        ELSE 'Negative Keyword'
    END AS RatingStatus,
    COUNT(*) AS Count
FROM 
    Intern
GROUP BY 
    Restaurant_Names,
    CASE 
        WHEN Rating_text IN ('Excellent', 'Very Good', 'Good', 'Average') 
            THEN 'Positive Keyword'
        ELSE 'Negative Keyword'
    END
ORDER BY 
    Restaurant_Names, RatingStatus;
-------------------------------------------------------------------
--Calculate the average length of reviews and explore if there is a relationship between  review length and rating
SELECT 
    Rating_text,
    AVG(LEN(Rating_text)) AS AvgReviewLength,
    COUNT(*) AS ReviewCount
FROM 
    Intern
WHERE 
    Rating_text IS NOT NULL
GROUP BY 
    Rating_text
ORDER BY 
    ReviewCount DESC ,AvgReviewLength ASC;
-------------------------------------------------------------------
-- Identify the restaurants with the highest and  lowest number of votes.
--HIGHEST VOTE--
SELECT top 1
Restaurant_Names,
SUM(Votes) AS HighestVote
FROM Intern
GROUP BY Restaurant_Names
ORDER BY HighestVote DESC 
--LOWEST VOTE--
SELECT TOP 1
    Restaurant_Names,
    SUM(Votes) AS LowestVote
FROM 
    Intern
GROUP BY 
    Restaurant_Names
HAVING 
    SUM(Votes) <> 0  
ORDER BY 
    LowestVote ASC;  
-------------------------------------------------------------------
--Analyze if there is a correlation between the  number of votes and the rating of a  restaurant
SELECT 
    CASE 
        WHEN Votes BETWEEN 1 AND 50 THEN 'Low Votes'
        WHEN Votes BETWEEN 51 AND 200 THEN 'Medium Votes'
        WHEN Votes > 200 THEN 'High Votes'
        ELSE 'No Votes'
    END AS VoteBucket,
    AVG(Aggregate_rating) AS AvgRating,
    COUNT(*) AS RestaurantCount
FROM 
    Intern
GROUP BY 
    CASE 
        WHEN Votes BETWEEN 1 AND 50 THEN 'Low Votes'
        WHEN Votes BETWEEN 51 AND 200 THEN 'Medium Votes'
        WHEN Votes > 200 THEN 'High Votes'
        ELSE 'No Votes'
    END;
-------------------------------------------------------------------
--Determine if higher-priced restaurants are  more likely to offer these services
SELECT 
	Restaurant_Names,
	Price_range,
	Has_Online_delivery AS OnlineDelivey,
	Has_Table_booking AS TableBooking 
FROM 
	Intern
ORDER BY 
	Price_range DESC





	


















