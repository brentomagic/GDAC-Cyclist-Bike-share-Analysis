        /*********I'M STARTING OFF BY MAKING SURE I'M CONNECTED TO THE RIGHT DATABASE***********/
  USE TestDatabase

         /********FOLLOWING THAT, I'M CREATING A TABLE AND COMBINING ALL THE DATA TOGETHER********/

  CREATE TABLE dbo.CombinedTripdata (
  ride_id nvarchar(255) null,
  rideable_type nvarchar(255) null,
  started_at datetime null,
  ended_at datetime null,
  start_station_name nvarchar(255) null,
  start_station_id nvarchar(255) null,
  end_station_name nvarchar(255) null,
  end_station_id nvarchar(255) null,
  start_lat float null,
  start_lng float null,
  end_lat float null, 
  end_lng float null,
  member_casual nvarchar(255) null)

  WAITFOR DELAY '00:00:02'

  INSERT INTO dbo.CombinedTripdata
  select * from dbo.[JanTripdata]
  union all
  select * from dbo.[FebTripdata]
  union all
  select * from dbo.[MarTripdata]
  union all
  select * from dbo.[AprTripdata]
  union all
  select * from dbo.[MayTripdata]
  union all
  select * from dbo.[JuneTripdata]

  SELECT top 10 * FROM [TestDatabase].[dbo].[CombinedTripdata]
  
       /***********STARTING OFF WITH CREATING NEW COLUMNS AND INSERTING DATA INTO IT**********/

--CREATE A NEW COLUMN TO (ride_duration_minutes) TO CALCULATE INDIVIDUAL RIDE LENGTH IN MINUTE
ALTER TABLE dbo.CombinedTripdata
ADD ride_duration_minutes INT

UPDATE dbo.CombinedTripdata
SET ride_duration_minutes = DATEDIFF(MINUTE, started_at, ended_at)

--CREATE A NEW (day_of_the_week) COLUMN TO FIGURE OUT THE EXACT RIDE DAY (1 = SUNDAY, 7 = SATURDAY)
ALTER TABLE dbo.CombinedTripdata
ADD day_of_the_week INT

UPDATE dbo.CombinedTripdata
SET day_of_the_week = DATEPART(weekday, started_at)

--CREATE A NEW (month) COLUMN TO FIGURE OUT THE EXACT MONTH OF EACH RIDE (1 = JANUARY, 6 = JUNE)
ALTER TABLE dbo.CombinedTripdata
ADD month INT

UPDATE dbo.CombinedTripdata
SET month = MONTH(started_at)
 
--TOTAL RIDES COUNT BY MEMBER AND CASUAL RIDERS
SELECT member_casual,
	COUNT(*) AS ride_count
FROM dbo.CombinedTripdata
WHERE ride_duration_minutes > 0
        AND ride_duration_minutes <1440
GROUP BY member_casual
ORDER BY ride_count DESC

--COUNTS MOST POPULAR BIKE TYPES AMONG RIDERS
SELECT member_casual, rideable_type, 
       COUNT (*) as ride_count
FROM dbo.CombinedTripdata
WHERE ride_duration_minutes > 0
       AND ride_duration_minutes < 1440
GROUP BY rideable_type, member_casual
ORDER BY ride_count DESC


        /********************************RIDEABLE TYPE ANALYSIS*************************************/
--TOTAL RIDE COUNT BY BICYCLE TYPE
SELECT rideable_type,
	   COUNT(*) AS total_ride_count
FROM dbo.CombinedTripdata
WHERE rideable_type IN ('electric_bike' , 'classic_bike', 'docked_bike')
      AND ride_duration_minutes > 0
      AND ride_duration_minutes < 1440
GROUP BY rideable_type
ORDER BY total_ride_count DESC

--TOTAL MEMBER RIDE COUNT BY BICYCLE TYPE

SELECT rideable_type,
       COUNT(*) AS member_total_ride_count
FROM dbo.CombinedTripdata
WHERE ride_duration_minutes > 0
      AND ride_duration_minutes < 1440
	  AND member_casual = 'member'
GROUP BY rideable_type

--TOTAL CASUAL RIDE COUNT BY BICYCLE TYPE

SELECT rideable_type,
       COUNT(*) AS casual_total_ride_count
FROM dbo.CombinedTripdata
WHERE ride_duration_minutes > 0
      AND ride_duration_minutes < 1440
	  AND member_casual = 'casual'
GROUP BY rideable_type


  /***********************************RIDE LENGTH ANALYSIS****************************************/

--AVERAGE, MINIMUM AND MAXIMUM RIDE LENGTHS

SELECT AVG (ride_duration_minutes) AS avg_ride_length,
       MIN (ride_duration_minutes) AS min_ride_length,
	   MAX (ride_duration_minutes) AS max_ride_length
FROM dbo.CombinedTripdata
WHERE ride_duration_minutes > 0
       AND ride_duration_minutes < 1440

SELECT AVG (ride_duration_minutes) AS member_avg_ride_length,
       MIN (ride_duration_minutes) AS member_min_ride_length,
	   MAX (ride_duration_minutes) AS member_max_ride_length
FROM dbo.CombinedTripdata
WHERE ride_duration_minutes > 0
      AND ride_duration_minutes < 1440
	  AND member_casual = 'member'

SELECT AVG (ride_duration_minutes) AS casual_avg_ride_length,
       MIN (ride_duration_minutes) AS casual_min_ride_length,
	   MAX (ride_duration_minutes) AS casual_max_ride_length
FROM dbo.CombinedTripdata
WHERE ride_duration_minutes > 0
      AND ride_duration_minutes < 1440
	  AND member_casual = 'casual'

-- AVERAGE MEMBER AND CASUAL RIDE LENGTH BY DAY OF THE WEEK
SELECT day_of_the_week,
       AVG (ride_duration_minutes) AS
member_avg_ride_length
FROM dbo.CombinedTripdata
WHERE member_casual = 'member'
      AND ride_duration_minutes > 0
      AND ride_duration_minutes < 1440
GROUP BY day_of_the_week
ORDER BY day_of_the_week

SELECT day_of_the_week,
       AVG (ride_duration_minutes) AS
casual_avg_ride_length
FROM dbo.CombinedTripdata
WHERE member_casual = 'casual'
      AND ride_duration_minutes > 0
      AND ride_duration_minutes < 1440
GROUP BY day_of_the_week
ORDER BY day_of_the_week

-- AVERAGE MONTHLY MEMBER AND CASUAL RIDE LENGTH
SELECT Month,
       AVG(ride_duration_minutes) AS member_avg_ride_length
FROM dbo.CombinedTripdata
WHERE member_casual = 'member'
      AND ride_duration_minutes > 0
      AND ride_duration_minutes < 1440
GROUP BY Month
ORDER BY Month

SELECT Month,
       AVG(ride_duration_minutes) AS casual_avg_ride_length
FROM dbo.CombinedTripdata
WHERE member_casual = 'casual'
      AND ride_duration_minutes > 0
      AND ride_duration_minutes < 1440
GROUP BY Month
ORDER BY Month

-- TOTAL MEMBER AND CASUAL DAILY RIDE COUNT

SELECT day_of_the_week,
       COUNT (*) AS riders_daily_ride_count
FROM dbo.CombinedTripdata
WHERE ride_duration_minutes >0
      AND ride_duration_minutes <1440
	  AND member_casual  IN ('member', 'casual')
GROUP BY day_of_the_week
ORDER BY riders_daily_ride_count desc

--COUNT OF DAILY RIDES BY MEMBER USERS
SELECT day_of_the_week,
       COUNT (*) AS member_daily_ride_count
FROM dbo.CombinedTripdata
WHERE ride_duration_minutes >0
      AND ride_duration_minutes <1440
	  AND member_casual  = 'member'
GROUP BY day_of_the_week
ORDER BY day_of_the_week

--COUNT OF DAILY RIDES BY CASUAL USERS

SELECT day_of_the_week,
       COUNT (*) AS casual_daily_ride_count
FROM dbo.CombinedTripdata
WHERE ride_duration_minutes >0
      AND ride_duration_minutes <1440
	  AND member_casual  = 'casual'
GROUP BY day_of_the_week
ORDER BY day_of_the_week

--MONTHLY RIDES COUNT BY MEMBER AND CASUAL USERS
SELECT month,
      COUNT (*) AS monthly_member_ride_count
FROM dbo.CombinedTripdata
WHERE ride_duration_minutes >0
      AND ride_duration_minutes <1440
	  AND member_casual  = 'member'
GROUP BY month
ORDER BY month

SELECT month,
      COUNT (*) AS monthly_casual_ride_count
FROM dbo.CombinedTripdata
WHERE ride_duration_minutes >0
      AND ride_duration_minutes <1440
	  AND member_casual  = 'casual'
GROUP BY month
ORDER BY month


/***********************************STATION LOCATION ANALYSIS****************************************/
--TOP 10 POPULAR START STATIONS

SELECT TOP (10) start_station_name,
      COUNT (*) AS popular_start_stations
FROM  dbo.CombinedTripdata
WHERE ride_duration_minutes > 0
      AND ride_duration_minutes < 1440
	  AND start_station_name != 'null'
GROUP BY start_station_name
ORDER BY popular_start_stations DESC

--TOP 10 POPULAR END STATIONS

SELECT TOP (10) end_station_name,
      COUNT (*) AS popular_end_stations
FROM  dbo.CombinedTripdata
WHERE ride_duration_minutes > 0
      AND ride_duration_minutes < 1440
	  AND end_station_name != 'null'
GROUP BY end_station_name
ORDER BY popular_end_stations DESC

--MEMBER RIDERS TOP 10 START STATIONS

SELECT TOP (10) start_station_name,
      COUNT (*) AS member_popular_start_stations
FROM  dbo.CombinedTripdata
WHERE ride_duration_minutes > 0
      AND ride_duration_minutes < 1440
	  AND member_casual = 'member'
	  AND start_station_name != 'null'
GROUP BY start_station_name
ORDER BY member_popular_start_stations DESC

--MEMBER RIDERS TOP 10 END STATIONS

SELECT TOP (10) end_station_name,
      COUNT (*) AS member_popular_end_stations
FROM  dbo.CombinedTripdata
WHERE ride_duration_minutes > 0
      AND ride_duration_minutes < 1440
	  AND member_casual = 'member'
	  AND end_station_name != 'null'
GROUP BY end_station_name
ORDER BY member_popular_end_stations DESC

--CASUAL RIDERS TOP 10 START STATIONS

SELECT TOP (10) start_station_name,
      COUNT (*) AS casual_popular_start_stations
FROM  dbo.CombinedTripdata
WHERE ride_duration_minutes > 0
      AND ride_duration_minutes < 1440
	  AND member_casual = 'casual'
	  AND start_station_name != 'null'
GROUP BY start_station_name
ORDER BY casual_popular_start_stations DESC

--CASUAL RIDERS TOP 10 END STATIONS

SELECT TOP (10) end_station_name,
      COUNT (*) AS casual_popular_end_stations
FROM  dbo.CombinedTripdata
WHERE ride_duration_minutes > 0
      AND ride_duration_minutes < 1440
	  AND member_casual = 'casual'
	  AND end_station_name != 'null'
GROUP BY end_station_name
ORDER BY casual_popular_end_stations DESC

 