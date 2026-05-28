/* ============================================================
   PROJECT: Insurance Claims SQL Analysis
   FILE: 03_kpi_analysis.sql
   AUTHOR: Colins
   DATABASE: insurance_claims_db

   OBJECTIVE:
   Calculate key insurance KPIs from the cleaned views.
   This file analyzes claims volume, claim costs, fraud,
   and key business indicators.
   ============================================================ */


/* ============================================================
   1. BASIC VOLUME KPIs
   ============================================================ */

-- 1.1 Total number of claims
-- Calculons le nombre total de sinistres.

SELECT
    COUNT(*) AS total_claims
FROM vw_claims_clean;

-- Résultat:
-- La vue vw_claims_clean contient 1100 sinistres.


-- 1.2 Total number of customers
-- Calculons le nombre total de clients.

SELECT
    COUNT(*) AS total_customers
FROM vw_customers_clean;

-- Résultat:
-- La vue vw_customers_clean contient 1085 clients.


-- 1.3 Distinct customer IDs in claims
-- Calculons le nombre d'identifiants clients différents présents dans les sinistres.

SELECT 
    COUNT(DISTINCT customer_id) AS distinct_customer_ids_in_claims
FROM vw_claims_clean;

-- Résultat:
-- 1093 identifiants clients différents apparaissent dans les sinistres.


-- 1.4 Existing customers with at least one claim
-- Calculons le nombre de clients existants ayant au moins un sinistre.

SELECT 
    COUNT(DISTINCT c.customer_id) AS customers_with_claims
FROM vw_customers_clean c
INNER JOIN vw_claims_clean cl
    ON c.customer_id = cl.customer_id;

-- Résultat:
-- 1078 clients existants ont au moins un sinistre.
-- La différence avec les 1093 customer_id distincts dans les sinistres indique
-- que 15 identifiants clients présents dans claims n'existent pas dans customers.


-- 1.5 Claims without matching customer
-- Calculons le nombre de sinistres dont le client n'existe pas encore dans la table clients

SELECT 

COUNT(*) AS claims_without_customer
FROM vw_claims_clean cl
LEFT JOIN vw_customers_clean c
ON cl.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- Résultat:
-- 15 sinistres n'ont pas de client correspondant dans vw_customers_clean.
-- Cela indique un problème de qualité de données ou une table clients incomplète.


/* ============================================================
   2. FINANCIAL KPIs
   ============================================================ */

-- 2.1 Total claim amount
-- Calculonsle montant total des sinistres

SELECT 
SUM(claim_amount) AS total_claim_amount
FROM vw_claims_clean; 

-- 2.2 Average claim_amount
-- Calculons le montant moyen des sinistres.

SELECT 
AVG(claim_amount) AS avg_claim_amount
FROM vw_claims_clean;

-- Ou si on veut afficher avec 2 décimales
SELECT 
ROUND(AVG(claim_amount), 2) AS average_claim_amount
FROM vw_claims_clean;

-- Résultat:
-- Le montant moyen des sinistres exploitables est d'environ 12 442,13.
-- Les valeurs NULL de claim_amount ne sont pas prises en compte dans AVG().


-- 2.3 Minimum and maximum claim amount
-- Calculons le montant minimum et le montant maximum des sinistres

SELECT 
MIN(claim_amount) AS minimum_claim_amount,
MAX(claim_amount) AS maximum_claim_amount
FROM vw_claims_clean;

-- Résultat:
-- Le montant minimum d'un sinistre est de 1 000.
-- Le montant maximum d'un sinistre est de 48 150,5.
-- Les valeurs NULL de claim_amount ne sont pas prises en compte dans MIN() et MAX().


-- 2.4 Claims with valid and missing claim amount
-- Calculons le nombre de sinistres avec montant exploitable et montant manquant

SELECT 
COUNT(*) AS total_claims,
COUNT(claim_amount) AS claims_with_amount,
COUNT(*) - COUNT(claim_amount) AS claims_without_amount
FROM vw_claims_clean;

-- Résultat:
-- Sur 1100 sinistres, 1035 ont un montant exploitable.
-- 65 sinistres ont un montant manquant, car leur claim_amount brut était égal à NA.


-- 2.5 Financial KPI summary
-- Résumons les principaux KPI financiers des sinistres.

-- On regroupe dans une seule requête les volumes liés aux montants
-- et les principaux calculs financiers.

SELECT 
COUNT(*) AS total_claims,
COUNT(claim_amount) AS claims_with_amount,
COUNT(*) - COUNT(claim_amount) AS claims_without_amount,
SUM(claim_amount) AS total_claim_amount,
ROUND(AVG(claim_amount), 2) AS average_claim_amount,
MIN(claim_amount) AS minimum_claim_amount,
MAX(claim_amount) AS maximum_claim_amount
FROM vw_claims_clean; 

-- Résultat:
-- La vue contient 1100 sinistres.
-- 1035 sinistres ont un montant exploitable.
-- 65 sinistres ont un montant manquant.
-- Le montant total des sinistres exploitables est de 12 877 599,5.
-- Le montant moyen d'un sinistre est de 12 442,13.
-- Le montant minimum d'un sinistre est de 1 000.
-- Le montant maximum d'un sinistre est de 48 150,5.


/* ============================================================
   3. FRAUD KPIs
   ============================================================ */

-- 3.1 Number of claims by fraud status
-- Calculons le nombre de sinistres frauduleux et non frauduleux.

SELECT 
is_fraudulent,
COUNT(*) AS total_claims
FROM vw_claims_clean
GROUP BY is_fraudulent
ORDER BY is_fraudulent;

-- Résultat:
-- 846 sinistres sont non frauduleux.
-- 254 sinistres sont frauduleux.


-- 3.2 Fraud rate
-- Calculons le taux de sinistres frauduleux 

SELECT 

COUNT(*) AS total_claims,

SUM(
CASE 
	WHEN is_fraudulent = TRUE THEN 1
	ELSE 0
END
) AS fraudulent_claims,

ROUND(
SUM(CASE
	WHEN is_fraudulent = TRUE THEN 1
	ELSE 0
END
) * 100.0 / COUNT(*), 2) AS fraud_rate_percent

FROM vw_claims_clean;

-- Résultat:
-- Sur 1100 sinistres, 254 sont frauduleux.
-- Le taux de fraude est de 23,09 %.


-- 3.3 Claim amount by fraud status
-- Comparons les montants des sinistres frauduleux et non frauduleux

SELECT 
is_fraudulent,

COUNT(*) AS total_claims,
COUNT(claim_amount) AS claims_with_amount,

SUM(claim_amount) AS total_claim_amount,

ROUND(AVG(claim_amount), 2) AS average_claim_amount,
MIN(claim_amount) AS minimum_claim_amount,
MAX(claim_amount) AS maximum_claim_amount

FROM vw_claims_clean
GROUP BY is_fraudulent
ORDER BY is_fraudulent;

-- Résultat:
-- Les sinistres non frauduleux représentent 846 dossiers, dont 798 avec un montant exploitable.
-- Leur montant total est de 9 798 670 et leur montant moyen est de 12 279,04.
--
-- Les sinistres frauduleux représentent 254 dossiers, dont 237 avec un montant exploitable.
-- Leur montant total est de 3 078 929,5 et leur montant moyen est de 12 991,26.
--
-- Les sinistres frauduleux ont un montant moyen légèrement plus élevé
-- que les sinistres non frauduleux.


/* ============================================================
   4. CLAIM CATEGORY KPIs
   ============================================================ */

-- 4.1 Claims by claim_aera
-- Comparons les sinistres par zone de sinistres

SELECT 

claim_area,

COUNT(*) AS total_claims,
COUNT(claim_amount) AS claims_with_amount,

SUM(claim_amount) AS total_claim_amount,
ROUND(AVG(claim_amount), 2) AS average_claim_amount,
MIN(claim_amount) AS minimum_claim_amount,
MAX(claim_amount) AS maximum_claim_amount

FROM vw_claims_clean

GROUP BY claim_area
ORDER BY total_claim_amount DESC;

-- Résultat:
-- La zone Auto représente 985 sinistres, dont 927 avec un montant exploitable.
-- Le montant total des sinistres Auto est de 11 711 096,5.
-- Le montant moyen d'un sinistre Auto est de 12 633,33.
--
-- La zone Home représente 115 sinistres, dont 108 avec un montant exploitable.
-- Le montant total des sinistres Home est de 1 166 503.
-- Le montant moyen d'un sinistre Home est de 10 800,95.
--
-- Conclusion:
-- Les sinistres Auto sont beaucoup plus nombreux et représentent la plus grande part du coût total.


-- 4.2 Claims by claim type
-- Comparons les sinistres par type de sinistre.

SELECT 

claim_type,
COUNT(*) AS total_claims,
COUNT(claim_amount) AS claims_with_amount,


SUM(claim_amount) AS total_claim_amount,
ROUND(AVG(claim_amount), 2) AS average_claim_amount,
MIN(claim_amount) AS minimum_claim_amount,
MAX(claim_amount) AS maximum_claim_amount

FROM vw_claims_clean
GROUP BY claim_type
ORDER BY total_claim_amount DESC;

-- Résultat:
-- Les sinistres "Material only" sont les plus nombreux avec 663 dossiers,
-- mais leur coût moyen est beaucoup plus faible : 2 064,82.
--
-- Les sinistres "Material and injury" sont moins nombreux avec 241 dossiers,
-- mais ils représentent le coût total le plus élevé : 6 643 464,5.
--
-- Les sinistres "Injury only" représentent 196 dossiers,
-- avec un coût moyen élevé de 26 778,10.
--
-- Conclusion:
-- Les sinistres impliquant des blessures sont beaucoup plus coûteux que les sinistres matériels seuls.


-- 4.3 Claims by incident cause
-- Comparons les sinistres par cause d incident

SELECT 

incident_cause,

COUNT(*) AS total_claims,
COUNT(claim_amount) AS claims_with_amount,

SUM(claim_amount) AS total_claim_amount,
ROUND(AVG(claim_amount), 2) AS average_claim_amount,
MIN(claim_amount) AS minimum_claim_amount,
MAX(claim_amount) AS maximum_claim_amount

FROM vw_claims_clean

GROUP BY incident_cause
ORDER BY total_claim_amount DESC; 

-- Résultat:
-- "Other causes" est la cause qui génère le coût total le plus élevé : 4 030 745.
-- "Other driver error" arrive ensuite avec 3 450 451,5.
-- "Driver error" représente 262 sinistres et un coût total de 3 427 430.
-- "Natural causes" et "Crime" ont des coûts totaux plus faibles.
--
-- Conclusion:
-- Les causes liées aux erreurs de conduite et aux autres causes représentent la plus grande part du coût total des sinistres.


-- 4.4 Claims by police report status
-- Comparons les sinistres selon la presence ou non d'un rapport de police 

SELECT 
police_report,

COUNT(*) AS total_claims,
COUNT(claim_amount) AS claims_with_amount,

SUM(claim_amount) AS total_claim_amount,
ROUND(AVG(claim_amount), 2) AS average_claim_amount,
MIN(claim_amount) AS minimum_claim_amount,
MAX(claim_amount) AS maximum_claim_amount

FROM vw_claims_clean

GROUP BY police_report
ORDER BY total_claim_amount DESC;

-- Résultat:
-- Les sinistres sans rapport de police représentent 630 dossiers,
-- avec un coût total de 4 853 930 et un coût moyen de 8 269,05.
--
-- Les sinistres avec rapport de police inconnu représentent 300 dossiers,
-- avec un coût total de 4 134 087 et un coût moyen de 14 556,64.
--
-- Les sinistres avec rapport de police représentent 170 dossiers,
-- avec un coût total de 3 889 582,5 et un coût moyen de 23 716,97.
--
-- Conclusion:
-- Les sinistres avec rapport de police sont moins nombreux,
-- mais leur montant moyen est beaucoup plus élevé.


/* ============================================================
   5. CUSTOMER PROFILE KPIs
   ============================================================ */

-- 5.1 Claims by customer segment
-- Comparons les sinistres par segement client

SELECT 

c.segment,

COUNT(cl.claim_id) AS total_claims,
COUNT(cl.claim_amount) AS claims_with_amount,

SUM(cl.claim_amount) AS total_claim_amount,
ROUND(AVG(cl.claim_amount),2) AS average_claim_amount,
MIN(cl.claim_amount) AS minimum_claim_amount,
MAX(cl.claim_amount) AS maximum_claim_amount

FROM vw_claims_clean cl
INNER JOIN vw_customers_clean c
ON cl.customer_id = c.customer_id 

GROUP BY c.segment
ORDER BY total_claim_amount DESC;

-- Résultat:
-- Gold représente 375 sinistres, dont 353 avec un montant exploitable.
-- Le coût total du segment Gold est de 4 536 823.
--
-- Platinum représente 362 sinistres, dont 347 avec un montant exploitable.
-- Le coût total du segment Platinum est de 4 280 771,5.
--
-- Silver représente 348 sinistres, dont 320 avec un montant exploitable.
-- Le coût total du segment Silver est de 3 899 440,5.
--
-- Conclusion:
-- Le segment Gold concentre le coût total le plus élevé, suivi de Platinum puis Silver.


-- 5.2 Claims by customer gender
-- Comparons les sinistres par gendre client.

SELECT 

c.gender,

COUNT(cl.claim_id) AS total_claims,
COUNT(cl.claim_amount) AS claims_with_amount,

SUM(cl.claim_amount) AS total_claim_amount,
ROUND(AVG(cl.claim_amount), 2) AS average_claim_amount,
MIN(cl.claim_amount) AS minimum_claim_amount,
MAX(cl.claim_amount) AS maximum_claim_amount

FROM vw_claims_clean cl
INNER  JOIN vw_customers_clean c
ON cl.customer_id = c.customer_id 

GROUP BY c.gender
ORDER BY total_claim_amount DESC;

-- Résultat:
-- Les clients Male représentent 556 sinistres, dont 520 avec un montant exploitable.
-- Leur coût total est de 6 697 464 et leur coût moyen est de 12 879,74.
--
-- Les clients Female représentent 529 sinistres, dont 500 avec un montant exploitable.
-- Leur coût total est de 6 019 571 et leur coût moyen est de 12 039,14.
--
-- Conclusion:
-- Les sinistres sont relativement équilibrés entre les deux genres.
-- Les clients Male présentent un volume et un coût total légèrement supérieurs.


-- 5.3 Claims by customer state
-- Comparons les sinistres par Etat client.

SELECT 

c.state,

COUNT(cl.claim_id) AS total_claims,
COUNT(cl.claim_amount) AS claims_with_amount,

SUM(cl.claim_amount) AS total_claim_amount,
ROUND(AVG(cl.claim_amount), 2) AS average_claim_amount,
MIN(cl.claim_amount) AS minimum_claim_amount,
MAX(cl.claim_amount) AS maximum_claim_amount

FROM vw_claims_clean cl
INNER JOIN vw_customers_clean c
ON cl.customer_id = c.customer_id 

GROUP BY c.state
ORDER BY total_claim_amount DESC;

-- Résultat:
-- Les États avec le coût total le plus élevé dans les premières lignes sont ME, NV, ID, NC et MT.
-- ME représente le coût total le plus élevé avec 459 506,5.
-- NV arrive ensuite avec 400 554,5.
-- Cette analyse permet d’identifier les zones géographiques où les sinistres coûtent le plus cher.


-- 5.4 Claims by customer age group
-- Comparons les sinistres par tranche d'âge client.

SELECT 

CASE 
	WHEN DATE_PART('year', AGE(c.date_of_birth)) < 30 THEN 'Under 30'
	WHEN DATE_PART('year', AGE(c.date_of_birth)) BETWEEN 30 AND 39 THEN '30 - 39'
	WHEN DATE_PART('year', AGE(c.date_of_birth)) BETWEEN 40 AND 49 THEN '40 - 49'
	WHEN DATE_PART('year', AGE(c.date_of_birth)) BETWEEN 50 AND 59 THEN '50 - 59'
	ELSE '60+'
END AS age_group,

COUNT(cl.claim_id) AS total_claims,
COUNT(cl.claim_amount) AS claims_with_amount,

SUM(cl.claim_amount) AS total_claim_amount,
ROUND(AVG(cl.claim_amount), 2) AS average_claim_amount,
MIN(cl.claim_amount) AS minimum_claim_amount,
MAX(cl.claim_amount) AS maximum_claim_amount

FROM vw_claims_clean cl
INNER JOIN vw_customers_clean c
ON cl.customer_id = c.customer_id 

GROUP BY age_group
ORDER BY total_claim_amount DESC;

-- Résultat:
-- La tranche Under 30 représente le plus grand nombre de sinistres avec 381 dossiers.
-- Elle représente aussi le coût total le plus élevé : 4 134 213,5.
--
-- Les tranches 40-49 et 50-59 ont un montant moyen plus élevé,
-- mais un volume de sinistres plus faible.
--
-- Conclusion:
-- Les clients de moins de 30 ans concentrent le plus grand volume de sinistres
-- et le coût total le plus élevé, tandis que certaines tranches plus âgées
-- présentent un coût moyen plus élevé.


-- 5.5 Customers with multiple claims
-- Identifions les clients ayant déclaré plusieurs sinistres.

SELECT 

c.customer_id,


COUNT(cl.claim_id) AS total_claims,
COUNT(cl.claim_amount) AS claims_with_amount,

SUM(cl.claim_amount) AS total_claim_amount,
ROUND(AVG(cl.claim_amount), 2) AS average_claim_amount,
MIN(cl.claim_amount) AS minimum_claim_amount,
MAX(cl.claim_amount) AS maximum_claim_amount

FROM vw_customers_clean c
INNER JOIN vw_claims_clean cl
ON c.customer_id = cl.customer_id 

GROUP BY c.customer_id
HAVING COUNT(cl.claim_id) > 1
ORDER BY total_claim_amount DESC;

-- Résultat:
-- Cette requête identifie les clients ayant déclaré plusieurs sinistres.
-- Les résultats sont triés par coût total décroissant.
-- Le client 21831191 apparaît en premier avec 2 sinistres et un coût total de 75 116,5.
--
-- Conclusion:
-- Cette analyse permet d’identifier les clients récurrents et les plus coûteux.


-- 5.6 Top customers by total claim amount
-- Identifions les clients les plus couteux en montant total de sinistres.

SELECT 

c.customer_id,

COUNT(cl.claim_id) AS total_claims,
COUNT(cl.claim_amount) AS claims_with_amount,

SUM(cl.claim_amount) AS total_claim_amount,
ROUND(AVG(cl.claim_amount), 2) AS average_claim_amount,
MIN(cl.claim_amount) AS minimum_claim_amount,
MAX(cl.claim_amount) AS maximum_claim_amount

FROM vw_customers_clean c
INNER JOIN vw_claims_clean cl
ON c.customer_id = cl.customer_id 

GROUP BY c.customer_id
HAVING COUNT(cl.claim_amount) > 0
ORDER BY total_claim_amount DESC 
LIMIT 10;

-- Résultat:
-- Le client 21831191 est le client le plus coûteux,
-- avec 2 sinistres et un montant total de 75 116,5.
--
-- Les autres clients du top peuvent avoir un seul sinistre,
-- mais avec un montant très élevé.
--
-- Conclusion:
-- Cette requête permet d’identifier les clients qui génèrent le coût total
-- le plus important pour l’assureur, qu’ils aient un ou plusieurs sinistres.


/* ============================================================
   6. TIME-BASED KPIs
   ============================================================ */

-- 6.1 Claims by year
-- Comparons les sinistres par année.

SELECT 

EXTRACT(YEAR FROM claim_date) AS claim_year,

COUNT(*) AS total_claims,
COUNT(claim_amount) AS claims_with_amount,

SUM(claim_amount) AS total_claim_amount,
ROUND(AVG(claim_amount), 2) AS average_claim_amount,
MIN(claim_amount) AS minimum_claim_amount,
MAX(claim_amount) AS maximum_claim_amount

FROM vw_claims_clean

GROUP BY EXTRACT(YEAR FROM claim_date)
ORDER BY claim_year;

-- Résultat:
-- En 2017, il y a 606 sinistres, dont 575 avec un montant exploitable.
-- Le montant total des sinistres en 2017 est de 7 057 456.
--
-- En 2018, il y a 494 sinistres, dont 460 avec un montant exploitable.
-- Le montant total des sinistres en 2018 est de 5 820 143,5.
--
-- Conclusion:
-- Le volume et le coût total des sinistres sont plus élevés en 2017 qu'en 2018.
-- En revanche, le montant moyen d'un sinistre est légèrement plus élevé en 2018.


-- 6.2 Claims by month
-- Comparons les sinistres par mois

SELECT

DATE_TRUNC('month', claim_date) AS claim_month,
TO_CHAR(DATE_TRUNC('month', claim_date), 'YYYY-MM') AS claim_month_label,

COUNT(*) AS total_claims,
COUNT(claim_amount) AS claims_with_amount,

SUM(claim_amount) AS total_claim_amount,
ROUND(AVG(claim_amount), 2) AS average_claim_amount,
MIN(claim_amount) AS minimum_claim_amount,
MAX(claim_amount) AS maximum_claim_amount

FROM vw_claims_clean

GROUP BY DATE_TRUNC('month', claim_date)
ORDER BY claim_month;

-- Résultat:
-- Les sinistres sont maintenant regroupés par mois.
-- claim_month contient la date technique du mois.
-- claim_month_label affiche le mois dans un format lisible YYYY-MM.
-- Cette requête permet d’analyser l’évolution mensuelle du volume et du coût des sinistres.


-- 6.3 Claims by month and fraud status
-- Comparons l'évolution mensuelle des sinistres frauduleux et non frauduleux 

SELECT
is_fraudulent,
DATE_TRUNC('month', claim_date) AS claim_month,
TO_CHAR(DATE_TRUNC('month', claim_date), 'YYYY-MM') AS claim_month_label,

COUNT(*) AS total_claims,
COUNT(claim_amount) AS claims_with_amount,

SUM(claim_amount) AS total_claim_amount,
ROUND(AVG(claim_amount), 2) AS average_claim_amount,
MIN(claim_amount) AS minimum_claim_amount,
MAX(claim_amount) AS maximum_claim_amount

FROM vw_claims_clean

GROUP BY DATE_TRUNC('month', claim_date), is_fraudulent
ORDER BY claim_month, is_fraudulent;

-- Résultat:
-- Les sinistres sont regroupés par mois et par statut de fraude.
-- Pour chaque mois, on obtient une ligne pour les sinistres non frauduleux
-- et une ligne pour les sinistres frauduleux.
-- Cette requête permet de suivre l’évolution mensuelle du volume et du coût
-- des sinistres selon leur statut de fraude.


-- 6.4 Monthly fraud rate
-- Calculons le taux de fraude par mois.

SELECT 

DATE_TRUNC('month', claim_date) AS claim_month,
TO_CHAR(DATE_TRUNC('month', claim_date), 'YYYY-MM') AS claim_month_label,

COUNT(*) AS total_claims,
COUNT(claim_amount) AS claims_with_amount,

SUM(claim_amount) AS total_claim_amount,
SUM(
CASE
	WHEN is_fraudulent = TRUE THEN 1
	ELSE 0
END

) AS fraudulent_claims,
ROUND(SUM(
CASE
	WHEN is_fraudulent = TRUE THEN 1
	ELSE 0
END) * 100.0 / COUNT(*), 2

) AS fraud_rate_percent,

ROUND(AVG(claim_amount), 2) AS average_claim_amount,
MIN(claim_amount) AS minimum_claim_amount,
MAX(claim_amount) AS maximum_claim_amount

FROM vw_claims_clean

GROUP BY DATE_TRUNC('month', claim_date)
ORDER BY claim_month;

-- Résultat:
-- Cette requête calcule le taux de fraude pour chaque mois.
-- fraud_rate_percent indique la part de sinistres frauduleux dans le total des sinistres du mois.
-- Par exemple, en 2017-01, 14 sinistres sur 58 sont frauduleux,
-- soit un taux de fraude de 24,14 %.


-- 6.5 Most expensive months
-- Identifions les mois les plus couteux en montant total de sinistres.

SELECT

DATE_TRUNC('month', claim_date) AS claim_month,
TO_CHAR(DATE_TRUNC('month', claim_date), 'YYYY-MM') AS claim_month_label,

COUNT(*) AS total_claims,
COUNT(claim_amount) AS claims_with_amount,

SUM(claim_amount) AS total_claim_amount,
ROUND(AVG(claim_amount), 2) AS average_claim_amount,
MIN(claim_amount) AS minimum_claim_amount,
MAX(claim_amount) AS maximum_claim_amount

FROM vw_claims_clean

GROUP BY DATE_TRUNC('month', claim_date)
HAVING COUNT(claim_amount) > 0
ORDER BY total_claim_amount DESC
LIMIT 10;

-- Résultat:
-- Le mois le plus coûteux est 2018-10 avec un montant total de 741 016.
-- 2017-07 arrive juste après avec un montant total de 740 862.
-- 2017-04 arrive en troisième position avec un montant total de 736 914.
--
-- Conclusion:
-- Cette requête permet d’identifier les mois qui concentrent les coûts de sinistres les plus élevés.
-- Elle peut aider à repérer des périodes plus coûteuses ou des pics de sinistralité.


/* ============================================================
   7. FINAL KPI SUMMARY
   ============================================================ */

-- 7.1 Final KPI summary
-- Résumons les principaux indicateurs du portefeuille de sinistres.

SELECT 

COUNT(*) AS total_claims,
COUNT(claim_amount) AS claims_with_amount,
COUNT(*) - COUNT(claim_amount) AS claims_without_amount,


SUM(claim_amount) AS total_claim_amount,
ROUND(AVG(claim_amount), 2) AS average_claim_amount,
MIN(claim_amount) AS minimum_claim_amount,
MAX(claim_amount) AS maximum_claim_amount,

SUM(
CASE
	WHEN is_fraudulent = TRUE THEN 1
	ELSE 0
END

) AS fraudulent_claims,

ROUND(SUM(
CASE 
	WHEN is_fraudulent = TRUE THEN 1
	ELSE 0
END

) * 100.0 / COUNT(*), 2) AS fraud_rate_percent


FROM vw_claims_clean;

-- Résultat:
-- Le portefeuille contient 1100 sinistres.
-- 1035 sinistres ont un montant exploitable.
-- 65 sinistres ont un montant manquant.
--
-- Le montant total des sinistres exploitables est de 12 877 599,5.
-- Le montant moyen d'un sinistre est de 12 442,13.
-- Le montant minimum est de 1 000.
-- Le montant maximum est de 48 150,5.
--
-- 254 sinistres sont frauduleux.
-- Le taux global de fraude est de 23,09 %.

/* ============================================================
   8. KPI ANALYSIS CONCLUSION
   ============================================================ */

-- Conclusion:
-- This KPI analysis provides a global view of the insurance claims portfolio.
--
-- The dataset contains 1100 claims.
-- 1035 claims have an exploitable claim amount.
-- 65 claims have a missing claim amount.
--
-- The total exploitable claim amount is 12 877 599.5.
-- The average claim amount is 12 442.13.
-- The minimum claim amount is 1 000.
-- The maximum claim amount is 48 150.5.
--
-- 254 claims are fraudulent.
-- The global fraud rate is 23.09%.
--
-- Auto claims represent the largest share of claim volume and total cost.
-- Claims involving injury are much more expensive on average than material-only claims.
-- Claims with a police report have a higher average amount.
-- The Gold customer segment represents the highest total claim cost.
-- The Under 30 age group has the highest claim volume and total cost.
--
-- These KPI results will be used in the next analysis step to draw business insights
-- and identify risk patterns by customer profile, claim type, fraud status and time period.
