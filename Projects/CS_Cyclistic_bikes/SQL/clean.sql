#Check for duplicate ride_id
SELECT ride_id, count(*) as cnt
FROM `data-analyst-501608.cyclistic_analysis.trips_combined`
GROUP BY ride_id
HAVING cnt > 1

#Check for unusual trip duration
SELECT
  countif(timestamp_diff(ended_at, started_at,SECOND)<=0) AS less_than_0,
  countif(timestamp_diff(ended_at, started_at,SECOND)<60) AS too_short,
  countif(timestamp_diff(ended_at, started_at,SECOND)>86400) AS too_long
FROM `data-analyst-501608.cyclistic_analysis.trips_combined` 

#Check if the rideable_type,member_casual is abnormal
SELECT rideable_type,member_casual 
FROM `data-analyst-501608.cyclistic_analysis.trips_combined`
GROUP BY rideable_type,member_casual

#Check the number of station names associated with more than one ID and the number of IDs associated with more than one name.
WITH all_stations AS (
  SELECT start_station_name AS station_name, start_station_id AS station_id
  FROM `data-analyst-501608.cyclistic_analysis.trips_combined`
  WHERE start_station_name IS NOT NULL AND start_station_id IS NOT NULL
  UNION ALL
  SELECT end_station_name AS station_name, end_station_id AS station_id
  FROM `data-analyst-501608.cyclistic_analysis.trips_combined`
  WHERE end_station_name IS NOT NULL AND end_station_id IS NOT NULL
)
SELECT
  (SELECT COUNT(*) 
  FROM 
    (SELECT station_name 
    FROM all_stations 
    GROUP BY station_name 
    HAVING COUNT(DISTINCT station_id) > 1)) AS names_with_multiple_ids,
    (SELECT COUNT(*) 
    FROM 
    (SELECT station_id 
    FROM all_stations 
    GROUP BY station_id 
    HAVING COUNT(DISTINCT station_name) > 1)) AS ids_with_multiple_names

#Check what % of total trips are touched by these ambiguous stations
WITH all_stations AS (
  SELECT start_station_name AS station_name, start_station_id AS station_id
  FROM `data-analyst-501608.cyclistic_analysis.trips_combined`
  WHERE start_station_name IS NOT NULL AND start_station_id IS NOT NULL
  UNION ALL
  SELECT end_station_name, end_station_id
  FROM `data-analyst-501608.cyclistic_analysis.trips_combined`
  WHERE end_station_name IS NOT NULL AND end_station_id IS NOT NULL
),
ambiguous_names AS (
  SELECT station_name FROM all_stations GROUP BY station_name HAVING COUNT(DISTINCT station_id) > 1
),
ambiguous_ids AS (
  SELECT station_id FROM all_stations GROUP BY station_id HAVING COUNT(DISTINCT station_name) > 1
)
SELECT
  COUNT(*) AS total_rows,
  COUNTIF(start_station_name IN (SELECT station_name FROM ambiguous_names)
       OR end_station_name IN (SELECT station_name FROM ambiguous_names)) AS rows_affected_by_ambiguous_name,
  COUNTIF(start_station_id IN (SELECT station_id FROM ambiguous_ids)
       OR end_station_id IN (SELECT station_id FROM ambiguous_ids)) AS rows_affected_by_ambiguous_id
FROM `data-analyst-501608.cyclistic_analysis.trips_combined`

#The number of row have station NULL record
SELECT Count(*)
FROM `data-analyst-501608.cyclistic_analysis.trips_combined`
WHERE start_station_name IS NULL OR start_station_id IS NULL OR end_station_name IS NULL OR end_station_id IS NULL

#Create cleaned table that removed irrecoverable errors
CREATE OR REPLACE TABLE `data-analyst-501608.cyclistic_analysis.trips_cleaned` AS
WITH deduplicated AS (
  SELECT *
  FROM (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY ride_id ORDER BY started_at) AS rn
    FROM `data-analyst-501608.cyclistic_analysis.trips_combined`
  )
  WHERE rn = 1
)
SELECT *
FROM deduplicated
WHERE timestamp_diff(ended_at, started_at, SECOND) > 60              -- remove trips shorter than 60 seconds
  AND timestamp_diff(ended_at, started_at, SECOND) < 86400           -- remove trips longer than 24 hours (24*3600)

#Create a station lookup table based on coordinates.
CREATE OR REPLACE TABLE `data-analyst-501608.cyclistic_analysis.station_lookup` AS
WITH combined AS (
  SELECT TRIM(start_station_name) AS station_name, start_station_id AS station_id,
         FORMAT('%.3f', start_lat) AS lat_key, FORMAT('%.3f', start_lng) AS lng_key
  FROM `data-analyst-501608.cyclistic_analysis.trips_cleaned`
  WHERE start_station_name IS NOT NULL AND start_lat IS NOT NULL
  UNION ALL
  SELECT TRIM(end_station_name), end_station_id,
         FORMAT('%.3f', end_lat), FORMAT('%.3f', end_lng)
  FROM `data-analyst-501608.cyclistic_analysis.trips_cleaned`
  WHERE end_station_name IS NOT NULL AND end_lat IS NOT NULL
),
best_name AS (
  SELECT lat_key, lng_key, station_name
  FROM combined
  GROUP BY lat_key, lng_key, station_name
  QUALIFY ROW_NUMBER() OVER (PARTITION BY lat_key, lng_key ORDER BY COUNT(*) DESC, station_name ASC) = 1
),
best_id AS (
  SELECT lat_key, lng_key, station_id
  FROM combined
  GROUP BY lat_key, lng_key, station_id
  QUALIFY ROW_NUMBER() OVER (PARTITION BY lat_key, lng_key ORDER BY COUNT(*) DESC, station_id ASC) = 1
)
SELECT
  bn.lat_key, bn.lng_key,
  bn.station_name AS canonical_station_name,
  bi.station_id AS canonical_station_id
FROM best_name bn
JOIN best_id bi USING (lat_key, lng_key);

CREATE OR REPLACE TABLE `data-analyst-501608.cyclistic_analysis.trips_final` AS
WITH flagged AS (
  SELECT
    t.*,
    (
      (t.start_station_name IS NOT NULL AND t.start_station_name IN (
        SELECT station_name FROM `data-analyst-501608.cyclistic_analysis.station_name_with_multiple_id`
      ))
      OR
      (t.start_station_id IS NOT NULL AND t.start_station_id IN (
        SELECT station_id FROM `data-analyst-501608.cyclistic_analysis.station_id_with_multiple_name`
      ))
    ) AS start_is_ambiguous,
    (
      (t.end_station_name IS NOT NULL AND t.end_station_name IN (
        SELECT station_name FROM `data-analyst-501608.cyclistic_analysis.station_name_with_multiple_id`
      ))
      OR
      (t.end_station_id IS NOT NULL AND t.end_station_id IN (
        SELECT station_id FROM `data-analyst-501608.cyclistic_analysis.station_id_with_multiple_name`
      ))
    ) AS end_is_ambiguous
  FROM `data-analyst-501608.cyclistic_analysis.trips_cleaned` t
)
SELECT
  f.* EXCEPT(start_station_name, start_station_id, end_station_name, end_station_id, start_is_ambiguous, end_is_ambiguous),

  CASE WHEN f.start_is_ambiguous THEN sl_start.canonical_station_name ELSE f.start_station_name END AS start_station_name,
  CASE WHEN f.start_is_ambiguous THEN sl_start.canonical_station_id   ELSE f.start_station_id   END AS start_station_id,
  CASE WHEN f.end_is_ambiguous   THEN sl_end.canonical_station_name   ELSE f.end_station_name     END AS end_station_name,
  CASE WHEN f.end_is_ambiguous   THEN sl_end.canonical_station_id     ELSE f.end_station_id       END AS end_station_id

FROM flagged f
LEFT JOIN `data-analyst-501608.cyclistic_analysis.station_lookup` sl_start
  ON f.start_is_ambiguous
 AND FORMAT('%.3f', f.start_lat) = sl_start.lat_key
 AND FORMAT('%.3f', f.start_lng) = sl_start.lng_key
LEFT JOIN `data-analyst-501608.cyclistic_analysis.station_lookup` sl_end
  ON f.end_is_ambiguous
 AND FORMAT('%.3f', f.end_lat) = sl_end.lat_key
 AND FORMAT('%.3f', f.end_lng) = sl_end.lng_key

# Check after creating the final table¶
#Count exactly how many rows were actually changed.
SELECT
  COUNTIF(c.start_station_name IS DISTINCT FROM f.start_station_name) AS start_name_changed,
  COUNTIF(c.start_station_id   IS DISTINCT FROM f.start_station_id)   AS start_id_changed,
  COUNTIF(c.end_station_name   IS DISTINCT FROM f.end_station_name)   AS end_name_changed,
  COUNTIF(c.end_station_id     IS DISTINCT FROM f.end_station_id)     AS end_id_changed
FROM `data-analyst-501608.cyclistic_analysis.trips_cleaned` c
JOIN `data-analyst-501608.cyclistic_analysis.trips_final` f USING (ride_id)

#Confirm that no null rows were accessed.
SELECT
  (SELECT COUNTIF(start_station_name IS NULL) FROM `data-analyst-501608.cyclistic_analysis.trips_cleaned`) AS null_before,
  (SELECT COUNTIF(start_station_name IS NULL) FROM `data-analyst-501608.cyclistic_analysis.trips_final`) AS null_after

#Confirm total number of lines remains unchanged
SELECT
  (SELECT COUNT(*) FROM `data-analyst-501608.cyclistic_analysis.trips_cleaned`) AS rows_before,
  (SELECT COUNT(*) FROM `data-analyst-501608.cyclistic_analysis.trips_final`) AS rows_after
