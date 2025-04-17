--deploy
-- Creando una tabla para guardar los datos
CREATE OR REPLACE TABLE `bootcampxperience.bqml_gaSessions.daily_predictions` (
  label INT64,
  operatingSystem STRING,
  isMobile BOOLEAN,
  country STRING,
  region STRING,
  deviceCategory STRING,
  browser STRING,
  pageViews INT64,
  hits INT64,
  timeOnSite INT64,
  trafficMedium STRING,
  trafficSource STRING,
  campaign STRING,
  visitHour INT64,
  isOrganic INT64,
  eveningVisit INT64,
  avgTimePerPageView FLOAT64,
  predictedLabel INT64,
  predictedProbability FLOAT64,
  predictionDate DATE
)
PARTITION BY predictionDate;

-- Insertando los resultados de la predicción en la tabla de resultados
INSERT INTO `bootcampxperience.bqml_gaSessions.daily_predictions`
WITH 
predictions AS (
  SELECT 
    predicted_label,
    predicted_label_probs[OFFSET(0)].prob AS predicted_probability,
    label,
    os,
    is_mobile,
    country,
    region,
    device_category,
    browser,
    pageviews,
    hits,
    time_on_site,
    traffic_medium,
    traffic_source,
    campaign,
    visit_hour,
    is_organic,
    evening_visit,
    avg_time_per_pageview
  FROM
    ML.PREDICT(MODEL `bootcampxperience.bqml_gaSessions.improved_model`,
    (
      SELECT
        IF(totals.transactions IS NULL, 0, 1) AS label,
        IFNULL(device.operatingSystem, "") AS os,
        device.isMobile AS is_mobile,
        IFNULL(geoNetwork.country, "") AS country,
        IFNULL(geoNetwork.region, "") AS region,
        device.deviceCategory AS device_category,
        device.browser AS browser,
        IFNULL(totals.pageviews, 0) AS pageviews,
        IFNULL(totals.hits, 0) AS hits,
        IFNULL(totals.timeOnSite, 0) AS time_on_site,
        IFNULL(trafficSource.medium, "") AS traffic_medium,
        IFNULL(trafficSource.source, "") AS traffic_source,
        IFNULL(trafficSource.campaign, "") AS campaign,
        EXTRACT(HOUR FROM TIMESTAMP_SECONDS(visitStartTime)) AS visit_hour,
        IF(trafficSource.medium = 'organic', 1, 0) AS is_organic,
        IF(EXTRACT(HOUR FROM TIMESTAMP_SECONDS(visitStartTime)) >= 18 AND 
           EXTRACT(HOUR FROM TIMESTAMP_SECONDS(visitStartTime)) <= 23, 1, 0) AS evening_visit,
        ROUND(IFNULL(totals.timeOnSite, 0) / GREATEST(IFNULL(totals.pageviews, 0), 1), 2) AS avg_time_per_pageview
      FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
      WHERE _TABLE_SUFFIX BETWEEN '20170601' AND '20170801')
    ) ORDER BY predicted_probability DESC
)
SELECT
  label,
  os AS operatingSystem,
  is_mobile AS isMobile,
  country,
  region,
  device_category AS deviceCategory,
  browser,
  pageviews AS pageViews,
  hits,
  time_on_site AS timeOnSite,
  traffic_medium AS trafficMedium,
  traffic_source AS trafficSource,
  campaign,
  visit_hour AS visitHour,
  is_organic AS isOrganic,
  evening_visit AS eveningVisit,
  avg_time_per_pageview AS avgTimePerPageView,
  predicted_label AS predictedLabel,
  predicted_probability AS predictedProbability,
  CURRENT_DATE() AS predictionDate
FROM predictions;
