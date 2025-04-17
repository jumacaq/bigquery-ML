--New model using logistic regression 
CREATE MODEL `bqml_ga_sessions1.improve_model2`
OPTIONS(
  model_type='logistic_reg',
  learn_rate_strategy= 'line_search',
  ls_init_learn_rate= 0.01,
  l2_reg=0.1,
  l1_reg=0.05,
  max_iterations=50,
  data_split_method='RANDOM',
  data_split_eval_fraction=0.2
) AS
SELECT
  IF(totals.transactions IS NULL, 0, 1) AS label,
  IFNULL(device.operatingSystem, "") AS op_syst,
  device.isMobile AS is_mobile,
  IFNULL(geoNetwork.country, "") AS country,
  IFNULL(geoNetwork.region, "") AS region,
  IFNULL(device.deviceCategory, "") AS dev_category,
  IFNULL(device.browser, "") AS browser,
  IFNULL(totals.pageviews, 0) AS pageviews,
  IFNULL(totals.hits, 0) AS hits,
  IFNULL(totals.timeOnSite, 0) AS time_on_site,
  IFNULL(trafficSource.medium, "") AS traffic_medium,
  IFNULL(trafficSource.source, "") AS traffic_source,
  IFNULL(trafficSource.campaign, "") AS campaign,
  EXTRACT(HOUR FROM TIMESTAMP_SECONDS(visitStartTime)) AS visit_hour,
  IF(trafficSource.medium='organic',1,0) AS is_organic,
  IF(EXTRACT(HOUR FROM TIMESTAMP_SECONDS(visitStartTime))>=18 AND EXTRACT(HOUR FROM TIMESTAMP_SECONDS(visitStartTime)) <= 23,1,0 ) AS evening_visit,
  ROUND(IFNULL(totals.timeOnSite,0)/ GREATEST(IFNULL(totals.pageviews,0),1),2) AS avg_time_pageview
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`    
WHERE _TABLE_SUFFIX BETWEEN '20160801' AND '20170531'
AND(totals.transactions IS NOT NULL OR RAND() <0.1);

--Metrics and assessment with test data
WITH TEST_DATA AS (
  SELECT
  IF(totals.transactions IS NULL, 0, 1) AS label,
  IFNULL(device.operatingSystem, "") AS op_syst,
  device.isMobile AS is_mobile,
  IFNULL(geoNetwork.country, "") AS country,
  IFNULL(geoNetwork.region, "") AS region,
  IFNULL(device.deviceCategory, "") AS dev_category,
  IFNULL(device.browser, "") AS browser,
  IFNULL(totals.pageviews, 0) AS pageviews,
  IFNULL(totals.hits, 0) AS hits,
  IFNULL(totals.timeOnSite, 0) AS time_on_site,
  IFNULL(trafficSource.medium, "") AS traffic_medium,
  IFNULL(trafficSource.source, "") AS traffic_source,
  IFNULL(trafficSource.campaign, "") AS campaign,
  EXTRACT(HOUR FROM TIMESTAMP_SECONDS(visitStartTime)) AS visit_hour,
  IF(trafficSource.medium='organic',1,0) AS is_organic,
  IF(EXTRACT(HOUR FROM TIMESTAMP_SECONDS(visitStartTime))>=18 AND EXTRACT(HOUR FROM TIMESTAMP_SECONDS(visitStartTime)) <= 23,1,0 ) AS evening_visit,
  ROUND(IFNULL(totals.timeOnSite,0)/ GREATEST(IFNULL(totals.pageviews,0),1),2) AS avg_time_pageview
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`    
  WHERE _TABLE_SUFFIX BETWEEN '20170601' AND '20170801'
  AND(totals.transactions IS NOT NULL OR RAND() <0.1)
)

--Confusion matrix
SELECT *
FROM ML.CONFUSION_MATRIX(MODEL `bqml_ga_sessions1.improve_model2`, (SELECT * FROM TEST_DATA));


--Model evaluation
SELECT   *
FROM   ml.EVALUATE(MODEL `bqml_ga_sessions1.improve_model2`, (SELECT * FROM TEST_DATA));
