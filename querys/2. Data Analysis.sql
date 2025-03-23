--Cual es el número total de transacciones generadas por navegador y tipo de dispositivo?
SELECT device.deviceCategory,
       device.browser,
       SUM(totals.transactions) AS total_transactions
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
WHERE _TABLE_SUFFIX BETWEEN '20161101' AND '20161130'
GROUP BY 1,2
HAVING SUM(totals.transactions) IS NOT NULL
ORDER BY 1, 3 DESC;

--Cual es el porcentaje de rechazo por origen de tráfico?
SELECT source,
        total_visits,
        total_bounces,
        ((total_bounces / total_visits ) * 100 ) AS bounce_rate
FROM (SELECT trafficSource.source AS source,
             COUNT ( trafficSource.source ) AS total_visits,
             SUM ( totals.bounces ) AS total_bounces
      FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
      WHERE _TABLE_SUFFIX BETWEEN '20170701' AND '20170731'
      GROUP BY 1
      )
ORDER BY 1 DESC;

--Cual es el porcentaje de conversión por operating_system,device_category y browser?
--Es vuestro turno, ¿seran capaces de responder esta pregunta usando BigQuery? 

--Cual es el porcentaje de visitantes que hizo una compra en el sitio web?
--Es vuestro turno, ¿seran capaces de responder esta pregunta usando BigQuery?