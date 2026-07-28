#Feature Engineering: Create Analysis-Ready Columns
CREATE OR REPLACE TABLE `data-analyst-501608.cyclistic_analysis.trips_final` AS
SELECT 
  ride_id,
  rideable_type,started_at, ended_at, start_lat, start_lng, end_lat, end_lng, member_casual, start_station_name, start_station_id, end_station_name, end_station_id,
  TIMESTAMP_DIFF(ended_at,started_at,SECOND) as ride_length,
  EXTRACT(DAYOFWEEK FROM started_at) AS day_of_week,
  FORMAT_TIMESTAMP('%A', started_at) AS day_of_week_name,
  6371 * 2 * ASIN(
    SQRT(
      POWER(SIN(((end_lat - start_lat) * ACOS(-1) / 180) / 2), 2) +
      COS(start_lat * ACOS(-1) / 180) * COS(end_lat * ACOS(-1) / 180) *
      POWER(SIN(((end_lng - start_lng) * ACOS(-1) / 180) / 2), 2)
    )
  ) AS distance_km
FROM `data-analyst-501608.cyclistic_analysis.trips_final`

#Verify Formatting Before Trusting Any Result
SELECT
  MIN(ride_length) AS min_duration,
  MAX(ride_length) AS max_duration,
  MIN(distance_km) AS min_distance,
  MAX(distance_km) AS max_distance,
  COUNTIF(distance_km IS NULL) AS null_distance_rows FROM `data-analyst-501608.cyclistic_analysis.trips_final`

#Set to NULL the distance_km which had end coordinates recorded as (0, 0)
CREATE OR REPLACE TABLE `data-analyst-501608.cyclistic_analysis.trips_final` AS
SELECT
  * EXCEPT(distance_km),
  CASE
    WHEN (start_lat = 0 AND start_lng = 0) OR (end_lat = 0 AND end_lng = 0) THEN NULL
    ELSE distance_km
  END AS distance_km
FROM `data-analyst-501608.cyclistic_analysis.trips_final`

#Aggregate Into Summary Tables
#Overall summary
SELECT
  member_casual,
  COUNT(*) AS total_rides,
  ROUND(AVG(ride_length)/60, 1) AS avg_ride_minutes,
  ROUND(APPROX_QUANTILES(ride_length, 2)[OFFSET(1)]/60, 1) AS median_ride_minutes,
  COUNTIF(distance_km IS NOT NULL) AS rides_with_valid_distance,
  ROUND(AVG(distance_km), 2) AS avg_distance_km,
  ROUND(APPROX_QUANTILES(distance_km, 2)[OFFSET(1)], 2) AS median_distance_km,
  COUNTIF(distance_km = 0) AS loop_rides,
  ROUND(COUNTIF(distance_km = 0) * 100.0 / COUNT(*), 2) AS pct_loop_rides
FROM `data-analyst-501608.cyclistic_analysis.trips_final`
GROUP BY member_casual

# Ride patterns by day of week
CREATE OR REPLACE TABLE `data-analyst-501608.cyclistic_analysis.summary_by_weekday` AS
SELECT
  member_casual,
  day_of_week,
  CASE WHEN EXTRACT(DAYOFWEEK FROM started_at) IN (1,7) THEN 'Weekend' ELSE 'Weekday' END AS day_type,
  COUNT(*) AS total_rides,
  ROUND(AVG(ride_length)/60, 1) AS avg_ride_minutes
FROM `data-analyst-501608.cyclistic_analysis.trips_final`
GROUP BY member_casual, day_of_week, day_type
ORDER BY member_casual, day_of_week, day_type

#Ride patterns by hour of day (commute vs. leisure signal)
CREATE OR REPLACE TABLE `data-analyst-501608.cyclistic_analysis.summary_by_hour` AS
SELECT
  member_casual,
  EXTRACT(HOUR FROM started_at) AS start_hour,
  COUNT(*) AS total_rides
FROM `data-analyst-501608.cyclistic_analysis.trips_final`
GROUP BY member_casual, start_hour
ORDER BY member_casual, start_hour

#Bike type preference
SELECT
  member_casual,
  rideable_type,
  COUNT(*) AS total_rides,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY member_casual), 1) AS pct_within_group
FROM `data-analyst-501608.cyclistic_analysis.trips_final`
GROUP BY member_casual, rideable_type

#Seasonality (month-by-month)
CREATE OR REPLACE TABLE `data-analyst-501608.cyclistic_analysis.summary_by_month` AS
SELECT
  member_casual,
  EXTRACT(MONTH FROM started_at) AS month,
  COUNT(*) AS total_rides
FROM `data-analyst-501608.cyclistic_analysis.trips_final`
GROUP BY member_casual, month

#Top 10 start stations per rider type — where casual riders concentrate
CREATE OR REPLACE TABLE `data-analyst-501608.cyclistic_analysis.summary_top_stations` AS
SELECT * FROM (
  SELECT
    member_casual,
    start_station_name,
    COUNT(*) AS total_rides,
    ROW_NUMBER() OVER (PARTITION BY member_casual ORDER BY COUNT(*) DESC) AS rank
  FROM `data-analyst-501608.cyclistic_analysis.trips_final`
  WHERE start_station_name IS NOT NULL
  GROUP BY member_casual, start_station_name
)
WHERE rank <= 10
