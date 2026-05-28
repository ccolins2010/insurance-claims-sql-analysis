/* ============================================================
   PROJECT: Insurance Claims SQL Analysis
   FILE: 04_business_insights.sql
   AUTHOR: Colins
   DATABASE: insurance_claims_db

   OBJECTIVE:
   Transform KPI results into business insights.
   This file identifies key risk patterns, costly segments,
   fraud-related observations, and business recommendations.
   ============================================================ */

/* ============================================================
   1. PORTFOLIO OVERVIEW INSIGHTS
   ============================================================ */

-- 1.1 Portfolio overview
-- Résumons les indicateurs globaux du portefeuille de sinistres.

SELECT 

COUNT(*) AS total_claims,
COUNT(claim_amount) AS claims_with_amount,
COUNT(*) - COUNT(claim_amount) AS claims_without_amount,

SUM(claim_amount) AS total_claim_amount,
ROUND(AVG(claim_amount),2) AS average_claim_amount,
MIN(claim_amount) AS minimum_claim_amount,
MAX(claim_amount) AS maximum_claim_amount,

SUM(
CASE
	WHEN is_fraudulent = TRUE THEN 1
	ELSE 0
END) AS fraudulent_claims,

ROUND(
SUM(
CASE
	WHEN is_fraudulent = TRUE THEN 1
	ELSE 0
END) * 100.0 / COUNT(*), 2) AS fraud_rate_percent



FROM vw_claims_clean;

-- Insight:
-- Le portefeuille contient 1100 sinistres au total.
-- Parmi ces sinistres, 1035 ont un montant exploitable et 65 n'ont pas de montant exploitable.
-- Cela signifie que la majorité des sinistres peut être utilisée pour les analyses financières,
-- mais qu'il existe une limite de qualité des données liée aux montants manquants.
--
-- Le montant total des sinistres exploitables est de 12 877 599,5.
-- Le montant moyen d'un sinistre est de 12 442,13.
-- Le montant minimum est de 1 000 et le montant maximum est de 48 150,5.
--
-- 254 sinistres sont identifiés comme frauduleux.
-- Le taux global de fraude est de 23,09 %, soit environ 1 sinistre sur 4.
--
-- Business interpretation:
-- Le portefeuille présente un volume de sinistres important, un coût total élevé
-- et un taux de fraude significatif.
-- Les 65 sinistres sans montant exploitable doivent être signalés comme une limite
-- de qualité des données.
-- Le taux de fraude de 23,09 % justifie une analyse plus approfondie des profils,
-- types de sinistres et périodes les plus exposés à la fraude.


/* ============================================================
   2. COST DRIVERS INSIGHTS
   ============================================================ */

-- 2.1 Cost by claim area
-- Identifions la zone de sinistre qui génère le plus de coût.

SELECT 

claim_area,

COUNT(*) AS total_claims,
COUNT(claim_amount) AS claims_with_amount,

SUM(claim_amount) AS total_claim_amount,
ROUND(AVG(claim_amount),2) AS average_claim_amount,
MIN(claim_amount) AS minimum_claim_amount,
MAX(claim_amount) AS maximum_claim_amount

FROM vw_claims_clean
GROUP BY claim_area
ORDER BY total_claim_amount DESC;

-- Insight:
-- La catégorie Auto représente la majorité des sinistres du portefeuille.
-- Elle compte 985 sinistres sur 1100, soit une très grande partie du volume total.
--
-- Auto est aussi la catégorie qui génère le coût total le plus élevé,
-- avec un montant total de 11 711 096,5.
--
-- La catégorie Home est beaucoup moins représentée,
-- avec 115 sinistres et un montant total de 1 166 503.
--
-- Business interpretation:
-- Les sinistres Auto sont le principal moteur de coût du portefeuille.
-- Ils concentrent à la fois le plus grand volume de sinistres
-- et la plus grande part du montant total.
-- Cette catégorie doit donc être analysée en priorité dans une logique de gestion du risque.


-- 2.2 Cost by claim type
-- Vérifions les types de sinistres qui génèrent le plus de coût.

SELECT 

claim_type,
COUNT(*) AS total_claims,
COUNT(claim_amount) AS claims_with_amount,

SUM(claim_amount) AS total_claim_amount,
ROUND(AVG(claim_amount),2) AS average_claim_amount,
MIN(claim_amount) AS minimum_claim_amount,
MAX(claim_amount) AS maximum_claim_amount

FROM vw_claims_clean
GROUP BY claim_type
ORDER BY total_claim_amount DESC;

-- Insight:
-- Les sinistres "Material only" sont les plus nombreux avec 663 dossiers,
-- mais ils génèrent le coût total le plus faible : 1 280 187.
-- Leur montant moyen est aussi faible : 2 064,82.
--
-- Les sinistres "Material and injury" sont moins nombreux avec 241 dossiers,
-- mais ils génèrent le coût total le plus élevé : 6 643 464,5.
-- Leur montant moyen est très élevé : 28 884,63.
--
-- Les sinistres "Injury only" représentent 196 dossiers,
-- avec un coût total de 4 953 948 et un montant moyen de 26 778,10.
--
-- Business interpretation:
-- Les sinistres impliquant des blessures sont beaucoup plus coûteux
-- que les sinistres matériels seuls.
-- Même s'ils sont moins nombreux, les sinistres "Material and injury"
-- et "Injury only" tirent fortement le coût total du portefeuille vers le haut.
-- Ces types de sinistres doivent donc être surveillés en priorité.


-- 2.3 Cost by incident cause 
-- Identifions les causes d'incident qui génèrent le plus de coût.

SELECT
incident_cause,
COUNT(*) AS total_claims,
COUNT(claim_amount) AS claims_with_amount,

SUM(claim_amount) AS total_claim_amount,
ROUND(AVG(claim_amount),2) AS average_claim_amount,
MIN(claim_amount) AS minimum_claim_amount,
MAX(claim_amount) AS maximum_claim_amount

FROM vw_claims_clean
GROUP BY incident_cause
ORDER BY total_claim_amount DESC;

-- Insight:
-- Les sinistres liés à "Other causes" sont les plus coûteux.
-- Ils représentent 290 sinistres, dont 270 avec un montant exploitable,
-- pour un coût total de 4 030 745.
--
-- Les causes liées à la conduite représentent aussi une part importante du coût.
-- "Other driver error" représente 249 sinistres pour un coût total de 3 450 451,5.
-- "Driver error" représente 262 sinistres pour un coût total de 3 427 430.
--
-- Les sinistres liés aux "Natural causes" et au "Crime" sont moins coûteux au total.
-- "Natural causes" représente 189 sinistres pour un coût total de 1 266 921.
-- "Crime" représente 110 sinistres pour un coût total de 702 052.
--
-- Business interpretation:
-- Les causes liées à la conduite et les autres causes représentent les principaux moteurs de coût.
-- Les sinistres liés au crime sont moins nombreux et génèrent un coût total plus faible.
-- Les catégories "Other causes" et "driver error" doivent être analysées plus en détail,
-- car elles concentrent la majorité du coût total des sinistres.


-- 2.4 Cost by police report status
-- Identifions le cout des sinistres selon la présence ou non d'un rapport de police.

SELECT
police_report,
COUNT(*) AS total_claims,
COUNT(claim_amount) AS claims_with_amount,

SUM(claim_amount) AS total_claim_amount,
ROUND(AVG(claim_amount),2) AS average_claim_amount,
MIN(claim_amount) AS minimum_claim_amount,
MAX(claim_amount) AS maximum_claim_amount

FROM vw_claims_clean
GROUP BY police_report
ORDER BY total_claim_amount DESC;

-- Insight:
-- Les sinistres sans rapport de police ("No") sont les plus nombreux.
-- Ils représentent 630 sinistres, dont 587 avec un montant exploitable,
-- pour un coût total de 4 853 930.
--
-- Les sinistres avec statut de rapport de police inconnu ("Unknown")
-- représentent 300 sinistres, dont 284 avec un montant exploitable,
-- pour un coût total de 4 134 087.
--
-- Les sinistres avec rapport de police ("Yes") sont moins nombreux,
-- avec 170 sinistres, dont 164 avec un montant exploitable.
-- Cependant, ils ont le montant moyen le plus élevé : 23 716,97.
--
-- Business interpretation:
-- Les sinistres avec rapport de police sont moins fréquents,
-- mais ils semblent plus graves ou plus coûteux en moyenne.
-- Le statut "Unknown" représente aussi un volume important,
-- ce qui peut indiquer une limite de qualité des données ou un manque d'information.
-- Les sinistres sans rapport de police génèrent le coût total le plus élevé,
-- principalement parce qu'ils sont beaucoup plus nombreux.


/* ============================================================
   3. FRAUD INSIGHTS
   ============================================================ */

-- 3.1 Fraud overview 
-- Résumons le niveau global de fraude dans le portefeuille.

SELECT 

COUNT(*) AS total_claims,

SUM(
CASE
	WHEN is_fraudulent = TRUE THEN 1 ELSE 0
END) AS fraudulent_claims,

SUM(
CASE WHEN is_fraudulent = FALSE THEN 1 ELSE 0 
END) AS non_fraudulent_claims,

ROUND(
SUM(
CASE
	WHEN is_fraudulent = TRUE THEN 1 ELSE 0
END) * 100.0 / COUNT(*), 2) AS fraud_rate_percent

FROM vw_claims_clean;

-- Insight:
-- Le portefeuille contient 1100 sinistres au total.
-- Parmi eux, 254 sont frauduleux et 846 sont non frauduleux.
--
-- Les sinistres non frauduleux sont donc majoritaires.
-- Cependant, les sinistres frauduleux représentent 23,09 % du portefeuille,
-- soit environ 1 sinistre sur 4.
--
-- Business interpretation:
-- Le taux de fraude est significatif.
-- Même si la majorité des sinistres n’est pas frauduleuse,
-- une fraude présente dans près d’un quart des dossiers représente un risque important.
-- Cela justifie une analyse plus détaillée de la fraude par type de sinistre,
-- par profil client et par période.

-- 3.2 Claim amount by fraud status
-- Comparons les montants des sinistres frauduleux et non frauduleux.

SELECT

is_fraudulent,
COUNT(*) AS total_claims,
COUNT(claim_amount) AS claims_with_amount,

SUM(claim_amount) AS total_claim_amount,
ROUND(AVG(claim_amount),2) AS average_claim_amount,
MIN(claim_amount) AS minimum_claim_amount,
MAX(claim_amount) AS maximum_claim_amount


FROM vw_claims_clean
GROUP BY is_fraudulent
ORDER BY is_fraudulent DESC;

-- Insight:
-- Les sinistres frauduleux sont moins nombreux que les sinistres non frauduleux.
-- Ils représentent 254 sinistres, dont 237 avec un montant exploitable.
-- Leur coût total est de 3 078 929,5.
--
-- Les sinistres non frauduleux représentent 846 sinistres,
-- dont 798 avec un montant exploitable.
-- Leur coût total est de 9 798 670.
--
-- Le montant moyen des sinistres frauduleux est de 12 991,26,
-- contre 12 279,04 pour les sinistres non frauduleux.
--
-- Business interpretation:
-- Les sinistres frauduleux sont moins nombreux,
-- mais leur montant moyen est légèrement plus élevé que celui des sinistres non frauduleux.
-- La fraude représente donc un risque important,
-- non seulement par son volume, mais aussi par son coût moyen.


-- 3.3 Fraud by claim type
-- Comparons la fraude par type de sinistre.

SELECT 

claim_type,
COUNT(*) AS total_claims,

SUM(
CASE 
WHEN is_fraudulent = TRUE THEN 1 ELSE 0
END) AS fraudulent_claims,

SUM(
CASE
	WHEN is_fraudulent = FALSE THEN 1 ELSE 0
END ) AS non_fraudulent_claims,

ROUND(
SUM(
CASE
	WHEN is_fraudulent = TRUE THEN 1 ELSE 0
END) * 100.0 / COUNT(*), 2) AS fraud_rate_percent


FROM vw_claims_clean
GROUP BY claim_type
ORDER BY fraud_rate_percent DESC;

-- Insight:
-- Le type "Material and injury" présente le taux de fraude le plus élevé.
-- Sur 241 sinistres de ce type, 62 sont frauduleux,
-- soit un taux de fraude de 25,73 %.
--
-- Le type "Material only" arrive ensuite.
-- Sur 663 sinistres, 164 sont frauduleux,
-- soit un taux de fraude de 24,74 %.
--
-- Le type "Injury only" présente le taux de fraude le plus faible.
-- Sur 196 sinistres, 28 sont frauduleux,
-- soit un taux de fraude de 14,29 %.
--
-- Business interpretation:
-- La fraude semble davantage présente dans les sinistres "Material and injury"
-- et "Material only" que dans les sinistres "Injury only".
-- Les sinistres combinant dommages matériels et blessures doivent donc être surveillés,
-- car ils présentent à la fois un coût élevé et le taux de fraude le plus important.


-- 3.4 Fraud by month
-- Identifions les mois avec le taux de fraude le plus élévé.

SELECT

DATE_TRUNC('month', claim_date) AS claim_month,
TO_CHAR(DATE_TRUNC('month', claim_date), 'YYYY-MM') AS claim_month_label,

COUNT(*) AS total_claims,

SUM(
CASE 
	WHEN is_fraudulent = TRUE THEN 1 ELSE 0
END) AS fraudulent_claims,

SUM(
CASE 
	WHEN is_fraudulent = FALSE THEN 1 ELSE 0
END) AS non_fraudulent_claims,

ROUND(
SUM(
CASE 
	WHEN is_fraudulent = TRUE THEN 1 ELSE 0
END) * 100.0 / COUNT(*), 2) AS fraud_rate_percent

FROM vw_claims_clean
GROUP BY DATE_TRUNC('month', claim_date)
ORDER BY fraud_rate_percent DESC;

-- Insight:
-- Le mois avec le taux de fraude le plus élevé est 2017-10.
-- En octobre 2017, on compte 62 sinistres au total,
-- dont 19 sinistres frauduleux et 43 non frauduleux.
-- Le taux de fraude atteint 30,65 %.
--
-- Business interpretation:
-- Octobre 2017 ressort comme le mois le plus exposé à la fraude en proportion.
-- Cela signifie qu’environ 3 sinistres sur 10 déclarés ce mois-là sont frauduleux.
-- Ce mois mérite donc une analyse plus détaillée pour comprendre
-- les types de sinistres, profils clients ou causes d’incident associés à cette fraude.


-- 3.5 Fraud by customer segment
-- Comparons le taux de fraude par segment client.

SELECT 

c.segment,
COUNT(cl.claim_id) AS total_claims,

SUM(
CASE 
	WHEN cl.is_fraudulent = TRUE THEN 1 ELSE 0
END) AS fraudulent_claims,

SUM(
CASE 
	WHEN cl.is_fraudulent = FALSE THEN 1 ELSE 0
END) AS non_fraudulent_claims,

ROUND(
SUM(
CASE 
	WHEN cl.is_fraudulent = TRUE THEN 1 ELSE 0
END) * 100.0 / COUNT(cl.claim_id), 2) AS fraud_rate_percent

FROM vw_claims_clean cl 
INNER JOIN vw_customers_clean c
ON cl.customer_id = c.customer_id 

GROUP BY c.segment
ORDER BY fraud_rate_percent DESC;

-- Insight:
-- Le segment Platinum présente le taux de fraude le plus élevé.
-- Sur 362 sinistres, 85 sont frauduleux,
-- soit un taux de fraude de 23,48 %.
--
-- Le segment Silver arrive juste derrière.
-- Sur 348 sinistres, 81 sont frauduleux,
-- soit un taux de fraude de 23,28 %.
--
-- Le segment Gold présente le taux de fraude le plus faible des trois segments.
-- Sur 375 sinistres, 81 sont frauduleux,
-- soit un taux de fraude de 21,60 %.
--
-- Business interpretation:
-- Les taux de fraude sont assez proches entre les segments.
-- Platinum et Silver sont légèrement plus exposés à la fraude,
-- mais l’écart avec Gold reste limité.
-- Il faut donc éviter de conclure trop fortement que le segment seul explique la fraude.


-- 3.6 Fraud by customer gender
-- Comparons le taux de fraude par genre client.

SELECT 

c.gender,
COUNT(cl.claim_id) AS total_claims,

SUM(
CASE 
	WHEN cl.is_fraudulent = TRUE THEN 1 ELSE 0
END) AS fraudulent_claims,

SUM(
CASE 
	WHEN cl.is_fraudulent = FALSE THEN 1 ELSE 0
END) AS non_fraudulent_claims,

ROUND(
SUM(
CASE 
	WHEN cl.is_fraudulent = TRUE THEN 1 ELSE 0
END) * 100.0 / COUNT(cl.claim_id), 2) AS fraud_rate_percent

FROM vw_claims_clean cl 
INNER JOIN vw_customers_clean c
ON cl.customer_id = c.customer_id 

GROUP BY c.gender
ORDER BY fraud_rate_percent DESC;

-- Insight:
-- Le taux de fraude est plus élevé chez les clientes Female que chez les clients Male.
--
-- Les clientes Female représentent 529 sinistres,
-- dont 126 sinistres frauduleux et 403 non frauduleux.
-- Leur taux de fraude est de 23,82 %.
--
-- Les clients Male représentent 556 sinistres,
-- dont 121 sinistres frauduleux et 435 non frauduleux.
-- Leur taux de fraude est de 21,76 %.
--
-- Business interpretation:
-- Le taux de fraude est légèrement plus élevé chez les clientes Female.
-- Cependant, l’écart entre Female et Male reste limité.
-- Le genre client seul ne suffit donc probablement pas à expliquer la fraude,
-- mais il peut être utilisé comme une variable d’analyse complémentaire.


-- 3.7 Fraud by customer state
-- Comparons le taux de fraude par Etat de client.

SELECT 

c.state, 
COUNT(cl.claim_id) AS total_claims,

SUM(
CASE 
	WHEN cl.is_fraudulent = TRUE THEN 1 ELSE 0
END) AS fraudulent_claims,

SUM(
CASE 
	WHEN cl.is_fraudulent = FALSE THEN 1 ELSE 0
END) AS non_fraudulent_claims,

ROUND(
SUM(
CASE 
	WHEN cl.is_fraudulent = TRUE THEN 1 ELSE 0
END) * 100.0 / COUNT(cl.claim_id), 2) AS fraud_rate_percent

FROM vw_claims_clean cl 
INNER JOIN vw_customers_clean c
ON cl.customer_id = c.customer_id 

GROUP BY c.state
ORDER BY fraud_rate_percent DESC;

-- Insight:
-- L'État TN présente le taux de fraude le plus élevé.
-- Sur 27 sinistres déclarés dans cet État, 15 sont frauduleux
-- et 12 sont non frauduleux.
-- Le taux de fraude est donc de 55,56 %.
--
-- Business interpretation:
-- TN ressort comme l'État le plus exposé à la fraude en proportion.
-- Cependant, le volume total reste faible avec seulement 27 sinistres.
-- Ce résultat doit donc être interprété avec prudence.
-- Il peut indiquer un signal de risque, mais il faudrait davantage de données
-- pour confirmer que cet État est réellement plus risqué.


-- 3.8 Fraud by customer age group
-- Comparons le taux de fraude par tranche d-âge client

SELECT

CASE 
	WHEN DATE_PART('year', AGE(c.date_of_birth)) < 30 THEN 'under 30'
	WHEN DATE_PART('year', AGE(c.date_of_birth)) BETWEEN 30 AND 39 THEN '30 - 39'
	WHEN DATE_PART('year', AGE(c.date_of_birth)) BETWEEN 40 AND 49 THEN '40 - 49'
	WHEN DATE_PART('year', AGE(c.date_of_birth)) BETWEEN 50 AND 59 THEN '50 - 59'
	ELSE '60+'
END AS customer_age_group,

COUNT(cl.claim_id) AS total_claims,

SUM(
CASE 
	WHEN cl.is_fraudulent = TRUE THEN 1 ELSE 0
END) AS fraudulent_claims,

SUM(
CASE 
	WHEN cl.is_fraudulent = FALSE THEN 1 ELSE 0
END) AS non_fraudulent_claims,

ROUND(
SUM(
CASE 
	WHEN cl.is_fraudulent = TRUE THEN 1 ELSE 0
END) * 100.0 / COUNT(cl.claim_id), 2) AS fraud_rate_percent

FROM vw_claims_clean cl 
INNER JOIN vw_customers_clean c
ON cl.customer_id = c.customer_id 

GROUP BY customer_age_group
ORDER BY fraud_rate_percent DESC;

-- Insight:
-- La tranche d'âge 50 - 59 présente le taux de fraude le plus élevé.
-- Sur 162 sinistres déclarés dans cette tranche, 40 sont frauduleux
-- et 122 sont non frauduleux.
-- Le taux de fraude est donc de 24,69 %.
--
-- La tranche Under 30 arrive ensuite avec 381 sinistres,
-- dont 86 frauduleux, soit un taux de fraude de 22,57 %.
--
-- Les tranches 30 - 39 et 40 - 49 présentent des taux proches,
-- autour de 22 %.
--
-- Business interpretation:
-- La tranche 50 - 59 ressort comme la plus exposée à la fraude en proportion.
-- Cependant, son volume total de sinistres est plus faible que celui des Under 30.
-- Il faut donc surveiller cette tranche, tout en restant prudent dans l’interprétation.
-- La différence entre les tranches d’âge existe, mais elle reste modérée.


/* ============================================================
   4. CUSTOMER PROFILE INSIGHTS
   ============================================================ */

-- 4.1 Cost by customer segment
-- Identifions les segments clients qui generent le plus de coût.

SELECT 

c.segment,
COUNT(cl.claim_id) AS total_claims,
COUNT(cl.claim_amount) AS claims_with_amount,
COUNT(cl.claim_id) - COUNT(cl.claim_amount) AS claims_without_amount,

SUM(cl.claim_amount) AS total_claim_amount,
ROUND(AVG(cl.claim_amount), 2) AS average_claim_amount,
MIN(cl.claim_amount) AS minimum_claim_amount,
MAX(cl.claim_amount) AS maximum_claim_amount

FROM vw_customers_clean c 
INNER JOIN vw_claims_clean cl 
ON c.customer_id = cl.customer_id 

GROUP BY c.segment
ORDER BY total_claim_amount DESC;

-- Insight:
-- Le segment Gold génère le coût total de sinistres le plus élevé.
-- Il représente 375 sinistres, dont 353 avec un montant exploitable
-- et 22 sans montant exploitable.
-- Le montant total des sinistres du segment Gold est de 4 536 823.
-- Le montant moyen est de 12 852,19.
--
-- Le segment Platinum arrive ensuite avec 362 sinistres
-- et un coût total de 4 280 771,5.
--
-- Le segment Silver représente 348 sinistres
-- et un coût total de 3 899 440,5.
--
-- Business interpretation:
-- Le segment Gold est le segment qui pèse le plus financièrement
-- dans le portefeuille.
-- Cela peut être lié à un volume de sinistres légèrement plus élevé
-- et à un montant moyen supérieur aux autres segments.
-- Ce segment doit donc être suivi en priorité dans l’analyse du coût client.


-- 4.2 Cost by customer gender
-- Identifions le coût des sinistres par genre client 

SELECT 

c.gender,
COUNT(cl.claim_id) AS total_claims,
COUNT(cl.claim_amount) AS claims_with_amount,
COUNT(cl.claim_id) - COUNT(cl.claim_amount) AS claims_without_amount,

SUM(cl.claim_amount) AS total_claim_amount,
ROUND(AVG(cl.claim_amount), 2) AS average_claim_amount,
MIN(cl.claim_amount) AS minimum_claim_amount,
MAX(cl.claim_amount) AS maximum_claim_amount

FROM vw_customers_clean c 
INNER JOIN vw_claims_clean cl 
ON c.customer_id = cl.customer_id 

GROUP BY c.gender
ORDER BY total_claim_amount DESC;

-- Insight:
-- Les clients Male génèrent le coût total de sinistres le plus élevé.
-- Ils représentent 556 sinistres, dont 520 avec un montant exploitable
-- et 36 sans montant exploitable.
-- Le coût total des sinistres pour les clients Male est de 6 697 464.
-- Le montant moyen est de 12 879,74.
--
-- Les clientes Female représentent 529 sinistres, dont 500 avec un montant exploitable
-- et 29 sans montant exploitable.
-- Leur coût total est de 6 019 571.
-- Le montant moyen est de 12 039,14.
--
-- Business interpretation:
-- Les clients Male génèrent un coût total légèrement plus élevé que les clientes Female.
-- Cela s’explique par un volume de sinistres un peu plus important
-- et un montant moyen légèrement supérieur.
-- Cependant, l’écart reste modéré, donc le genre seul ne suffit pas à expliquer
-- les différences de coût dans le portefeuille.


-- 4.3 Cost by customer state
-- Identifions le coût des sinistres par Etat client

SELECT 

c.state, 
COUNT(cl.claim_id) AS total_claims,
COUNT(cl.claim_amount) AS claims_with_amount,
COUNT(cl.claim_id) - COUNT(cl.claim_amount) AS claims_without_amount,

SUM(cl.claim_amount) AS total_claim_amount,
ROUND(AVG(cl.claim_amount), 2) AS average_claim_amount,
MIN(cl.claim_amount) AS minimum_claim_amount,
MAX(cl.claim_amount) AS maximum_claim_amount

FROM vw_customers_clean c 
INNER JOIN vw_claims_clean cl 
ON c.customer_id = cl.customer_id 

GROUP BY c.state
ORDER BY total_claim_amount DESC;

-- Insight:
-- L'État ME génère le coût total de sinistres le plus élevé.
-- Il représente 28 sinistres, dont 27 avec un montant exploitable
-- et 1 sans montant exploitable.
-- Le coût total des sinistres pour ME est de 459 506,5.
-- Le montant moyen est de 17 018,76.
--
-- Les États NV, ID, NC et MT suivent ensuite dans le classement
-- des coûts totaux les plus élevés.
--
-- Business interpretation:
-- L'État ME est celui qui pèse le plus financièrement dans cette analyse par État.
-- Cependant, le volume reste relativement faible avec seulement 28 sinistres.
-- Il faut donc interpréter ce résultat avec prudence :
-- ME ressort comme un signal intéressant, mais il faudrait davantage de données
-- pour confirmer qu’il s’agit réellement d’un État plus risqué.


-- 4.4 Cost by customer age group
-- Identifions le coût des sinistres par tranche d'âge client.

SELECT 
 CASE 
 	WHEN DATE_PART('year', AGE(c.date_of_birth)) < 30 THEN 'under 30'
 	WHEN DATE_PART('year', AGE(c.date_of_birth)) BETWEEN 30 AND 39 THEN '30 - 39'
 	WHEN DATE_PART('year', AGE(c.date_of_birth)) BETWEEN 40 AND 49 THEN '40 - 49'
 	WHEN DATE_PART('year', AGE(c.date_of_birth)) BETWEEN 50 AND 59 THEN '50 - 59'
 	ELSE '60+'
 END AS age_group,
  COUNT(cl.claim_id) AS total_claims,
  COUNT(cl.claim_amount) AS claims_with_amount,
  COUNT(cl.claim_id) - COUNT(cl.claim_amount) AS claims_without_amount,
  
  SUM(cl.claim_amount) AS total_claim_amount,
  ROUND(AVG(cl.claim_amount), 2) AS average_claim_amount,
  MIN(cl.claim_amount) AS minimum_claim_amount,
  MAX(cl.claim_amount) AS maximum_claim_amount
  
  FROM vw_customers_clean c
  INNER JOIN vw_claims_clean cl
  ON c.customer_id = cl.customer_id 
  
  GROUP BY age_group
  ORDER BY total_claim_amount DESC;
  
-- Insight:
-- La tranche d'âge Under 30 génère le coût total de sinistres le plus élevé.
-- Elle représente 380 sinistres, dont 357 avec un montant exploitable
-- et 23 sans montant exploitable.
-- Le coût total des sinistres pour cette tranche est de 4 132 028,5.
-- Le montant moyen est de 11 574,31.
--
-- La tranche 40 - 49 arrive ensuite avec 266 sinistres
-- et un coût total de 3 409 617.
--
-- La tranche 30 - 39 représente 277 sinistres
-- et un coût total de 3 054 019,5.
--
-- La tranche 50 - 59 est moins nombreuse avec 162 sinistres
-- et un coût total de 2 121 370.
--
-- Business interpretation:
-- Les clients de moins de 30 ans génèrent le coût total le plus élevé.
-- Cela s’explique surtout par leur volume de sinistres plus important.
-- En revanche, les tranches 40 - 49 et 50 - 59 ont des montants moyens plus élevés,
-- ce qui montre qu’il faut analyser à la fois le volume et le coût moyen.
  

-- 4.5  Customers with multiple claims
-- Identifions les clients ayant déclaré plusieurs sinistres.

SELECT 

c.customer_id,

COUNT(cl.claim_id) AS total_claims,
COUNT(cl.claim_amount) AS claims_with_amount,
COUNT (cl.claim_id) - COUNT(cl.claim_amount) AS claims_without_amount,

SUM(cl.claim_amount) AS total_claim_amount,
ROUND(AVG(cl.claim_amount), 2) AS average_claim_amount,
MIN(cl.claim_amount) AS minimum_claim_amount,
MAX(cl.claim_amount) AS maximum_claim_amount

FROM vw_customers_clean c
INNER JOIN vw_claims_clean cl 
ON c.customer_id = cl.customer_id

GROUP BY c.customer_id
HAVING COUNT(cl.claim_id) > 1
ORDER BY total_claims DESC, total_claim_amount DESC;
  
-- Insight:
-- Cette requête identifie les clients ayant déclaré plusieurs sinistres.
-- Les clients affichés ont au moins 2 sinistres déclarés.
--
-- Le client 21831191 apparaît en premier avec 2 sinistres,
-- tous avec un montant exploitable,
-- pour un coût total de 75 116,5.
-- Son montant moyen de sinistre est de 37 558,25.
--
-- Business interpretation:
-- Les clients ayant plusieurs sinistres peuvent représenter des profils récurrents.
-- Ils doivent être surveillés en priorité lorsqu’ils cumulent plusieurs dossiers
-- et un coût total élevé.
-- Dans cette analyse, le client 21831191 ressort comme le client récurrent
-- le plus coûteux.


-- 4.6 Top customers by total claim amount
-- Identifions les clients les plus coûteux en montant total de sinistres.

SELECT 

c.customer_id,

COUNT(cl.claim_id) AS total_claims,
COUNT(cl.claim_amount) AS claims_with_amount,
COUNT(cl.claim_id) - COUNT(cl.claim_amount) AS claims_without_amount,

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

-- Insight:
-- Cette requête identifie les clients les plus coûteux en montant total de sinistres.
-- Le client 21831191 est le plus coûteux.
-- Il a déclaré 2 sinistres, tous avec un montant exploitable,
-- pour un coût total de 75 116,5.
-- Son montant moyen de sinistre est de 37 558,25.
--
-- Les autres clients du top ont souvent un seul sinistre,
-- mais avec un montant très élevé.
--
-- Business interpretation:
-- Un client peut représenter un risque financier important même avec un seul sinistre,
-- si le montant du sinistre est élevé.
-- Cette analyse permet d’identifier les clients à fort impact financier,
-- à surveiller en priorité dans une logique de gestion du risque.


/* ============================================================
   5. TIME-BASED INSIGHTS
   ============================================================ */

-- 5.1 Claims cost by year
-- Identifions l'évolution annuelle du volume et du coût des sinistres.

SELECT 

EXTRACT(YEAR FROM claim_date) AS claim_year,
COUNT(*) AS total_claims,
COUNT(claim_amount) AS claims_with_amount,
COUNT(*) - COUNT(claim_amount) AS claims_without_amount,

SUM(claim_amount) AS total_claim_amount,
ROUND(AVG(claim_amount), 2) AS average_claim_amount,
MIN(claim_amount) AS minimum_claim_amount,
MAX(claim_amount) AS maximum_claim_amount

FROM vw_claims_clean
GROUP BY EXTRACT(YEAR FROM claim_date) 
ORDER BY claim_year;


-- Version avec LAG()
-- 5.1 bis Year-over-year claims evolution
-- Calculons l'évolution annuelle du volume et du coût par rapport à l'année précédente.

WITH yearly_kpis AS (
SELECT 
EXTRACT(YEAR FROM claim_date) AS claim_year,
COUNT(*) AS total_claims,
COUNT(claim_amount) AS claims_with_amount,
COUNT(*) - COUNT(claim_amount) AS claims_without_amount,

SUM(claim_amount) AS total_claim_amount,
ROUND(AVG(claim_amount), 2) AS average_claim_amount,
MIN(claim_amount) AS minimum_claim_amount,
MAX(claim_amount) AS maximum_claim_amount

FROM vw_claims_clean
GROUP BY EXTRACT(YEAR FROM claim_date) 

)

SELECT 
claim_year,

total_claims,
LAG(total_claims) OVER (ORDER BY claim_year) AS previous_year_claims,
total_claims - LAG(total_claims) OVER (ORDER BY claim_year) AS claims_change,

total_claim_amount,
LAG(total_claim_amount) OVER (ORDER BY claim_year) AS previous_year_claim_amount,
total_claim_amount - LAG(total_claim_amount) OVER (ORDER BY claim_year) AS claim_amount_change,

average_claim_amount

FROM yearly_kpis
ORDER BY claim_year;

-- Insight:
-- En 2017, le portefeuille compte 606 sinistres,
-- dont 575 avec un montant exploitable et 31 sans montant exploitable.
-- Le coût total des sinistres en 2017 est de 7 057 456.
-- Le montant moyen d’un sinistre est de 12 273,84.
--
-- En 2018, le portefeuille compte 494 sinistres,
-- dont 460 avec un montant exploitable et 34 sans montant exploitable.
-- Le coût total des sinistres en 2018 est de 5 820 143,5.
-- Le montant moyen d’un sinistre est de 12 652,49.
--
-- Evolution:
-- Entre 2017 et 2018, le volume total de sinistres baisse de 112 dossiers.
-- Le coût total des sinistres baisse également de 1 237 312,5.
-- En revanche, le montant moyen augmente légèrement,
-- passant de 12 273,84 à 12 652,49.
--
-- Business interpretation:
-- Le portefeuille présente une baisse du volume de sinistres entre 2017 et 2018,
-- ainsi qu’une baisse du coût total.
-- Cependant, le montant moyen par sinistre augmente légèrement.
-- Cela signifie que même si moins de sinistres ont été déclarés en 2018,
-- les sinistres restants sont en moyenne un peu plus coûteux.
--
-- Note:
-- Dans la requête avec LAG(), les valeurs NULL sur l’année 2017 sont normales,
-- car 2017 est la première année disponible dans les données.
-- Il n’existe donc pas d’année précédente pour calculer une évolution.


-- 5.2 Claims cost by month
-- Identifions l'évolution mensuelle du volume et du coût des sinistres.

SELECT

DATE_TRUNC('month', claim_date) AS claim_month,
TO_CHAR(DATE_TRUNC('month', claim_date), 'YYYY-MM') AS claim_month_label,

COUNT(*) AS total_claims,
COUNT(claim_amount) AS claims_with_amount,
COUNT(*) - COUNT(claim_amount) AS claims_without_amount,

SUM(claim_amount) AS total_claim_amount,
ROUND(AVG(claim_amount), 2) AS average_claim_amount,
MIN(claim_amount) AS minimum_claim_amount,
MAX(claim_amount) AS maximum_claim_amount

FROM vw_claims_clean
GROUP BY DATE_TRUNC('month', claim_date)
ORDER BY claim_month;


-- Version avec le LAG()
-- 5.2 bis month-over-month claim evolution
-- Calculons l'évolution mensuelle du coût et du volume par rapport au mois précédent.

WITH monthly_kpis AS (

SELECT 

DATE_TRUNC('month', claim_date) AS claim_month,
TO_CHAR(DATE_TRUNC('month', claim_date), 'YYYY-MM') AS claim_month_label,

COUNT(*) AS total_claims,
COUNT(claim_amount) AS claims_with_amount,
COUNT(*) - COUNT(claim_amount) AS claims_without_amount,

SUM(claim_amount) AS total_claim_amount,
ROUND(AVG(claim_amount), 2) AS average_claim_amount,
MIN(claim_amount) AS minimum_claim_amount,
MAX(claim_amount) AS maximum_claim_amount

FROM vw_claims_clean
GROUP BY DATE_TRUNC('month', claim_date)
)
 SELECT 
 claim_month,
 claim_month_label,
 
 total_claims,
 LAG(total_claims) OVER (ORDER BY claim_month) AS previous_month_claims,
 total_claims - LAG(total_claims) OVER (ORDER BY claim_month) AS claims_change,
 
 total_claim_amount,
 LAG(total_claim_amount) OVER (ORDER BY claim_month) AS previous_month_claim_amount,
 total_claim_amount - LAG(total_claim_amount) OVER (ORDER BY claim_month) AS claim_amount_change,
 
 average_claim_amount
 
 FROM monthly_kpis
 ORDER BY claim_month;
 
 -- Insight:
-- Cette requête analyse l'évolution mensuelle du volume et du coût des sinistres.
-- Elle compare chaque mois avec le mois précédent grâce à LAG().
--
-- En janvier 2017, il y a 58 sinistres pour un coût total de 572 891.
-- Les colonnes previous_month_claims et previous_month_claim_amount sont NULL,
-- car janvier 2017 est le premier mois disponible dans les données.
--
-- En février 2017, il y a 51 sinistres contre 58 le mois précédent.
-- Le volume baisse donc de 7 sinistres.
-- En revanche, le coût total augmente de 35 692,
-- passant de 572 891 à 608 583.
--
-- En mars 2017, il y a 57 sinistres contre 51 le mois précédent.
-- Le volume augmente donc de 6 sinistres.
-- Le coût total baisse légèrement de 16 300.
--
-- En avril 2017, il y a 52 sinistres contre 57 le mois précédent.
-- Le volume baisse de 5 sinistres,
-- mais le coût total augmente fortement de 144 631.
--
-- Business interpretation:
-- L'évolution mensuelle montre que le volume de sinistres et le coût total
-- ne progressent pas toujours dans le même sens.
-- Un mois peut avoir moins de sinistres mais un coût total plus élevé,
-- ce qui signifie que certains sinistres sont plus coûteux en moyenne.
--
-- Cette analyse permet donc de repérer les mois où le coût augmente,
-- même lorsque le nombre de sinistres diminue.
-- Elle aide à identifier des périodes de risque financier plus élevé.
 
-- 5.3 Most expensive months
-- identifions les mois les plus coûteux en montant total de sinistres.

SELECT 

DATE_TRUNC('month', claim_date) AS claim_month,
TO_CHAR(DATE_TRUNC('month', claim_date), 'YYYY-MM') AS claim_month_label,

COUNT(*) AS total_claims,
COUNT(claim_amount) AS claims_with_amount,
COUNT(*) - COUNT(claim_amount) AS claims_without_amount,

SUM(claim_amount) AS total_claim_amount,
ROUND(AVG(claim_amount), 2) AS average_claim_amount,
MIN(claim_amount) AS minimum_claim_amount,
MAX(claim_amount) AS maximum_claim_amount

FROM vw_claims_clean
GROUP BY DATE_TRUNC('month', claim_date)
HAVING COUNT(claim_amount) > 0
ORDER BY total_claim_amount DESC
LIMIT 10;


-- 5.3 bis Most expensive months with previous month comparison
-- Comparons les mois les plus coûteux avec le mois précédent.

WITH monthly_cost_kpis AS (
SELECT 

DATE_TRUNC('month', claim_date) AS claim_month,
TO_CHAR(DATE_TRUNC('month', claim_date), 'YYYY-MM') AS claim_month_label,

COUNT(*) AS total_claims,
COUNT(claim_amount) AS claims_with_amount,
COUNT(*) - COUNT(claim_amount) AS claims_without_amount,

SUM(claim_amount) AS total_claim_amount,
ROUND(AVG(claim_amount), 2) AS average_claim_amount,
MIN(claim_amount) AS minimum_claim_amount,
MAX(claim_amount) AS maximum_claim_amount

FROM vw_claims_clean
GROUP BY DATE_TRUNC('month', claim_date)
HAVING COUNT(claim_amount) > 0

)

SELECT 
claim_month,
claim_month_label,

total_claims,
LAG(total_claims) OVER (ORDER BY claim_month) AS previous_month_claims,
total_claims - LAG(total_claims) OVER (ORDER BY claim_month) AS claims_change,

total_claim_amount,
LAG(total_claim_amount) OVER (ORDER BY claim_month) AS previous_month_claim_amount,
total_claim_amount - LAG(total_claim_amount) OVER (ORDER BY claim_month) AS claim_amount_change,

average_claim_amount

FROM monthly_cost_kpis
ORDER BY total_claim_amount DESC
LIMIT 10;

-- Insight:
-- Le mois le plus coûteux est 2018-10.
-- Il compte 62 sinistres, contre 43 le mois précédent,
-- soit une hausse de 19 sinistres.
--
-- Le coût total atteint 741 016,
-- contre 486 226 le mois précédent,
-- soit une hausse de 254 790.
--
-- Le montant moyen d’un sinistre en 2018-10 est de 13 000,28.
--
-- Business interpretation:
-- Octobre 2018 ressort comme le mois le plus coûteux du portefeuille.
-- Cette hausse est liée à la fois à une augmentation du volume de sinistres
-- et à une forte augmentation du coût total par rapport au mois précédent.
-- Ce mois doit donc être analysé plus en détail pour comprendre
-- les types de sinistres, causes ou profils clients responsables de ce pic.


-- 5.4 Monthly fraud rate trend
-- Identifions l'évolution mensuelle du taux de fraude.

SELECT 

DATE_TRUNC('month', claim_date) AS claim_month,
TO_CHAR(DATE_TRUNC('month', claim_date), 'YYYY-MM') AS claim_month_label,

COUNT(*) AS total_claims,
COUNT(claim_amount) AS claims_with_amount,
COUNT(*) - COUNT(claim_amount) AS claims_without_amount,

SUM(claim_amount) AS total_claim_amount,
ROUND(AVG(claim_amount), 2) AS average_claim_amount,
SUM(
CASE 
	WHEN is_fraudulent = TRUE THEN 1 ELSE 0
END) AS fraudulent_claims,

SUM(
CASE 
	WHEN is_fraudulent = FALSE THEN 1 ELSE 0
END) AS non_fraudulent_claims,
ROUND(
SUM(
CASE 
	WHEN is_fraudulent = TRUE THEN 1 ELSE 0
END 
) * 100.0 / COUNT(*), 2) AS fraud_rate_percent

FROM vw_claims_clean
GROUP BY DATE_TRUNC('month', claim_date)
ORDER BY claim_month;

-- Insight:
-- Cette requête affiche le taux de fraude mois par mois.
-- Elle permet de suivre l'évolution mensuelle de la fraude dans le portefeuille.
--
-- En janvier 2017, il y a 58 sinistres au total.
-- 14 sont frauduleux et 44 sont non frauduleux.
-- Le taux de fraude est de 24,14 %.
--
-- En février 2017, il y a 51 sinistres.
-- 11 sont frauduleux et 40 sont non frauduleux.
-- Le taux de fraude est de 21,57 %.
--
-- En mars 2017, il y a 57 sinistres.
-- 15 sont frauduleux et 42 sont non frauduleux.
-- Le taux de fraude est de 26,32 %.
--
-- Business interpretation:
-- Le taux de fraude varie selon les mois.
-- Certains mois présentent une part plus importante de sinistres frauduleux.
-- Cette analyse permet d’identifier les périodes où la fraude est plus présente
-- et peut justifier une surveillance renforcée sur certains mois.

  
-- 5.4 bis Monthly fraud rate evolution with previous month comparison
-- Comparons l'évolution mensuelle du taux de fraude avec le mois précédent.

WITH monthly_fraud_kpis AS (
SELECT 
DATE_TRUNC('month', claim_date) AS claim_month,
TO_CHAR(DATE_TRUNC('month', claim_date), 'YYYY-MM') AS claim_month_label,

COUNT(*) AS total_claims,
COUNT(claim_amount) AS claims_with_amount,
COUNT(*) - COUNT(claim_amount) AS claims_without_amount,

SUM(claim_amount) AS total_claim_amount,
ROUND(AVG(claim_amount), 2) AS average_claim_amount,
SUM(
CASE 
	WHEN is_fraudulent = TRUE THEN 1 ELSE 0
END) AS fraudulent_claims,

SUM(
CASE 
	WHEN is_fraudulent = FALSE THEN 1 ELSE 0
END) AS non_fraudulent_claims,
ROUND(
SUM(
CASE 
	WHEN is_fraudulent = TRUE THEN 1 ELSE 0
END 
) * 100.0 / COUNT(*), 2) AS fraud_rate_percent

FROM vw_claims_clean
GROUP BY DATE_TRUNC('month', claim_date)

)
SELECT 
claim_month,
claim_month_label,

total_claims,
LAG(total_claims) OVER (ORDER BY claim_month) AS previous_month_claims,
total_claims - LAG(total_claims) OVER (ORDER BY claim_month) AS claims_change,

total_claim_amount,
LAG(total_claim_amount) OVER (ORDER BY claim_month) AS previous_month_claim_amount,
total_claim_amount - LAG(total_claim_amount) OVER (ORDER BY claim_month) AS claim_amount_change,

fraud_rate_percent,
LAG(fraud_rate_percent) OVER (ORDER BY claim_month) AS previous_month_fraud_rate_percent,
fraud_rate_percent - LAG(fraud_rate_percent) OVER (ORDER BY claim_month) AS fraud_rate_change

FROM monthly_fraud_kpis
ORDER BY claim_month;

-- Insight:
-- Cette requête compare chaque mois avec le mois précédent.
-- Elle permet de suivre l’évolution du volume de sinistres,
-- du coût total et du taux de fraude.
--
-- En janvier 2017, les colonnes de comparaison sont NULL,
-- car il s’agit du premier mois disponible dans les données.
--
-- En février 2017, le volume baisse de 7 sinistres
-- par rapport à janvier 2017.
-- Le coût total augmente cependant de 35 692.
-- Le taux de fraude baisse de 2,57 points,
-- passant de 24,14 % à 21,57 %.
--
-- En mars 2017, le volume augmente de 6 sinistres
-- par rapport à février 2017.
-- Le coût total baisse de 16 300.
-- Le taux de fraude augmente de 4,75 points,
-- passant de 21,57 % à 26,32 %.
--
-- En avril 2017, le volume baisse de 5 sinistres,
-- mais le coût total augmente de 144 631.
-- Le taux de fraude baisse fortement de 10,94 points.
--
-- Business interpretation:
-- L’évolution mensuelle montre que le volume, le coût total
-- et le taux de fraude ne varient pas toujours dans le même sens.
-- Un mois peut avoir moins de sinistres mais un coût total plus élevé,
-- ce qui peut indiquer des sinistres plus graves ou plus coûteux.
-- Le taux de fraude peut également évoluer indépendamment du coût total.
-- Cette analyse permet donc d’identifier les mois où le risque financier
-- ou le risque de fraude augmente par rapport au mois précédent.


-- 5.5 Months with highest fraud rate
-- Identifions les mois avec le taux de fraude le plus élevé.

SELECT 
DATE_TRUNC('month', claim_date) AS claim_month,
TO_CHAR(DATE_TRUNC('month', claim_date), 'YYYY-MM') AS claim_month_label,

COUNT(*) AS total_claims,
COUNT(claim_amount) AS claims_with_amount,
COUNT(*) - COUNT(claim_amount) AS claims_without_amount,

SUM(claim_amount) AS total_claim_amount,
ROUND(AVG(claim_amount), 2) AS average_claim_amount,
MIN(claim_amount) AS minimum_claim_amount,
MAX(claim_amount) AS maximum_claim_amount,

SUM(

CASE
	WHEN is_fraudulent = TRUE THEN 1 ELSE 0
END
	) AS fraudulent_claims,
SUM(

CASE
	WHEN is_fraudulent = FALSE THEN 1 ELSE 0
END
	) AS non_fraudulent_claims,
	
ROUND(
SUM(
CASE 
	WHEN is_fraudulent = TRUE THEN 1 ELSE 0
END

) * 100.0 / COUNT(*), 2) AS fraud_rate_percent

FROM vw_claims_clean
GROUP BY DATE_TRUNC('month', claim_date)
ORDER BY fraud_rate_percent DESC
LIMIT 10;

-- Insight:
-- Cette requête identifie les mois avec le taux de fraude le plus élevé.
-- Contrairement à une analyse chronologique, ici les mois sont classés
-- du taux de fraude le plus élevé au plus faible.
--
-- Parmi les mois visibles dans le top 10, 2018-06 présente un taux de fraude de 25,93 %.
-- Sur 54 sinistres déclarés ce mois-là, 14 sont frauduleux
-- et 40 sont non frauduleux.
--
-- 2017-01 présente un taux de fraude de 24,14 %.
-- Sur 58 sinistres, 14 sont frauduleux et 44 sont non frauduleux.
--
-- 2017-05 présente un taux de fraude de 23,91 %.
-- Sur 46 sinistres, 11 sont frauduleux et 35 sont non frauduleux.
--
-- Business interpretation:
-- Certains mois présentent une proportion de fraude plus élevée que la moyenne globale.
-- Ces périodes peuvent nécessiter une surveillance renforcée,
-- surtout lorsqu’un taux de fraude élevé est associé à un volume de sinistres important.


/* ============================================================
   6. DATA QUALITY INSIGHTS
   ============================================================ */

-- 6.1 Claims without exploitable amount
-- Identifions les sinistres sans montant exploitable.

SELECT

COUNT(*) AS total_claims,
COUNT(claim_amount) AS claims_with_amount,
COUNT(*) - COUNT(claim_amount) AS claims_without_amount,

ROUND(
(COUNT(*) - COUNT(claim_amount)) * 100.0 / COUNT(*),2) AS rate_claims_without_amount_percent

FROM vw_claims_clean;

-- Insight:
-- Le portefeuille contient 1100 sinistres au total.
-- Parmi eux, 1035 ont un montant exploitable.
-- 65 sinistres n’ont pas de montant exploitable.
--
-- Le taux de sinistres sans montant exploitable est de 5,91 %.
--
-- Business interpretation:
-- La majorité des sinistres possède un montant exploitable,
-- ce qui permet de réaliser les analyses financières.
-- Cependant, 5,91 % des sinistres ne peuvent pas être utilisés
-- dans les calculs de coût, de moyenne ou de montant total.
-- Cette limite doit être signalée dans l’analyse finale.


-- 6.2 Claims without matching customer
-- Identifions les sinistres qui ne sont pas reliés à un client connu.

SELECT 

cl.claim_id,
cl.customer_id AS customer_id_in_claims,
c.customer_id AS customer_found_in_customers_table,
cl.claim_amount

FROM vw_claims_clean cl
LEFT JOIN vw_customers_clean c
ON cl.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- Insight:
-- Cette requête liste les sinistres qui ne sont pas reliés à un client connu.
-- Chaque ligne correspond à un sinistre dont le customer_id existe dans la table des sinistres,
-- mais n’existe pas dans la table des clients.
--
-- customer_id_in_claims indique le client renseigné dans le sinistre.
-- customer_found_in_customers_table est NULL, ce qui signifie qu’aucun client correspondant
-- n’a été retrouvé dans la table clients.
--
-- Business interpretation:
-- Ces sinistres ne peuvent pas être utilisés dans les analyses par profil client,
-- comme le segment, le genre, l’État ou la tranche d’âge.
-- Ils représentent donc une limite de qualité des données à signaler.


-- 6.2 bis claims without matching customer - summary
-- Résumons le nombre et le taux de sinistres sans client correspondant.

SELECT 

COUNT(cl.claim_id) AS total_claims,
COUNT(c.customer_id) AS claims_with_matching_customer,
COUNT(cl.claim_id) - COUNT(c.customer_id) AS claims_without_matching_customer,

ROUND(
(COUNT(cl.claim_id) -COUNT(c.customer_id)) * 100.0 /COUNT(cl.claim_id),2) AS rate_claims_without_matching_customer_percent

FROM vw_claims_clean cl
LEFT JOIN vw_customers_clean c
ON cl.customer_id = c.customer_id;

-- Insight:
-- Le portefeuille contient 1100 sinistres au total.
-- Parmi eux, 1085 sont reliés à un client existant dans la table clients.
-- 15 sinistres ne sont pas reliés à un client connu.
--
-- Le taux de sinistres sans client correspondant est de 1,36 %.
--
-- Business interpretation:
-- La grande majorité des sinistres est correctement reliée à un client.
-- Cependant, 15 sinistres ne peuvent pas être rattachés à un profil client.
-- Ces sinistres ne pourront donc pas être utilisés dans les analyses par segment,
-- genre, État ou tranche d’âge.
-- Ce point doit être signalé comme une limite de qualité des données.


-- 6.3 Unknown values in key categorical columns
-- Mesurons la part de valeurs Unknown dans les colonnes catégorielles importantes.

SELECT 

COUNT(*) AS total_claims,

SUM(
CASE
	WHEN incident_cause = 'Unknown' THEN 1 ELSE 0
END

) AS unknown_incident_cause_count,

ROUND(
SUM(
CASE
	WHEN incident_cause = 'Unknown' THEN 1 ELSE 0
END
) * 100.0 / COUNT(*),2) AS unknown_incident_cause_rate_percent,

SUM(
CASE 
	WHEN police_report = 'Unknown' THEN 1 ELSE 0
END
) AS unknown_police_report_count,

ROUND(
SUM(
CASE 
	WHEN police_report = 'Unknown' THEN 1 ELSE 0
END
) * 100.0 / COUNT(*), 2) AS unknown_police_report_rate_percent,

SUM(
CASE 
	WHEN claim_type = 'Unknown' THEN 1 ELSE 0
END
) AS unknown_claim_type_count,

ROUND(
SUM(
CASE 
	WHEN claim_type = 'Unknown' THEN 1 ELSE 0
END
) * 100.0 / COUNT(*), 2) AS unknown_claim_type_rate_percent

FROM vw_claims_clean;

-- Insight:
-- Sur 1100 sinistres, seule la colonne police_report contient des valeurs Unknown.
-- incident_cause ne contient aucune valeur Unknown.
-- claim_type ne contient aucune valeur Unknown.
--
-- La colonne police_report contient 300 valeurs Unknown,
-- soit 27,27 % des sinistres.
--
-- Business interpretation:
-- La qualité des données est globalement bonne pour incident_cause et claim_type,
-- car aucune valeur Unknown n’est présente dans ces colonnes.
--
-- En revanche, police_report présente une limite importante de qualité des données.
-- Environ 1 sinistre sur 4 a un statut de rapport de police inconnu.
-- Cette information manquante peut limiter l’analyse des sinistres selon la présence
-- ou non d’un rapport de police.


-- 6.3 bis police report value distribution 
-- Analysons la repartition des valeurs dans la colonne police_report.

SELECT 
police_report,
COUNT(*) AS total_claims,

ROUND (
COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS part_percent


FROM vw_claims_clean
GROUP BY police_report
ORDER BY total_claims DESC;

-- Insight:
-- La majorité des sinistres n’a pas de rapport de police renseigné comme présent.
-- La valeur "No" représente 630 sinistres, soit 57,27 % du portefeuille.
--
-- La valeur "Unknown" représente 300 sinistres, soit 27,27 %.
-- Cela signifie qu’environ 1 sinistre sur 4 a un statut de rapport de police inconnu.
--
-- La valeur "Yes" représente 170 sinistres, soit 15,45 %.
--
-- Business interpretation:
-- La colonne police_report présente une limite importante de qualité des données.
-- La part de valeurs Unknown est élevée et peut limiter l’analyse
-- entre les sinistres avec ou sans rapport de police.
-- Cette variable doit donc être interprétée avec prudence.


-- 6.4 Null values in key columns
-- Vérifions les valeurs NULL dans les colonnes importantes.

SELECT 

COUNT(*) AS total_customers,

SUM(
CASE
	WHEN gender IS NULL THEN 1 ELSE 0
END) AS null_gender_count,

ROUND(
SUM(
CASE
	WHEN gender IS NULL THEN 1 ELSE 0
END) * 100.0 / COUNT(*), 2) AS null_gender_rate_percent,

SUM(
CASE
	WHEN state IS NULL THEN 1 ELSE 0
END) AS null_state_count,

ROUND(
SUM(
CASE
	WHEN state IS NULL THEN 1 ELSE 0
END) * 100.0 / COUNT(*), 2) AS null_state_rate_percent,

SUM(
CASE
	WHEN contact IS NULL THEN 1 ELSE 0
END) AS null_contact_count,

ROUND(
SUM(
CASE
	WHEN contact IS NULL THEN 1 ELSE 0
END) * 100.0 / COUNT(*), 2) AS null_contact_rate_percent,

SUM(
CASE
	WHEN segment IS NULL THEN 1 ELSE 0
END) AS null_segment_count,

ROUND(
SUM(
CASE
	WHEN segment IS NULL THEN 1 ELSE 0
END) * 100.0 / COUNT(*), 2) AS null_segment_rate_percent

FROM vw_customers_clean;

-- Insight:
-- La vue vw_customers_clean contient 1085 clients.
-- Aucune valeur NULL n’est détectée dans les colonnes analysées :
-- gender, state, contact et segment.
--
-- Business interpretation:
-- Les colonnes principales du profil client sont complètes.
-- Cela permet d’utiliser ces variables dans les analyses par profil client
-- sans perte liée à des valeurs manquantes NULL.


-- 6.5 Customer gender distribution 
-- Vérifions la répartition des valeurs dans la colonne gender

SELECT
gender,

COUNT(*) AS total_customers,

ROUND(
COUNT(*) * 100.0 /SUM(COUNT(*)) OVER (), 2) AS part_gender_percent

FROM vw_customers_clean
GROUP BY gender
ORDER BY total_customers DESC;

-- Insight:
-- La répartition par genre est équilibrée.
-- Les clients Male représentent 553 clients, soit 50,97 %.
-- Les clientes Female représentent 532 clientes, soit 49,03 %.
--
-- La colonne gender semble propre et bien répartie.
-- Elle peut être utilisée dans les analyses par profil client.


-- 6.6 Customer segment distribution
-- Vérifions la repartition des valeurs dans la colonne segment

SELECT
segment,

COUNT(*) AS total_customers,

ROUND(
COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS part_segment_percent

FROM vw_customers_clean
GROUP BY segment
ORDER BY total_customers DESC;

-- Insight:
-- La répartition par segment est également équilibrée.
-- Le segment Gold représente 372 clients, soit 34,29 %.
-- Le segment Platinum représente 364 clients, soit 33,55 %.
-- Le segment Silver représente 349 clients, soit 32,17 %.
--
-- Aucun segment ne domine fortement le portefeuille.
-- La colonne segment semble propre et exploitable pour les analyses métier.


-- 6.7 Customer state distribution 
-- Vérifions la répartition des valeurs dans la colonne state.

SELECT 
state,

COUNT(*) AS total_customers,

ROUND(
COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),2) AS part_state_percent

FROM vw_customers_clean
GROUP BY state
ORDER BY total_customers DESC;

-- Insight:
-- La colonne state contient plusieurs États clients.
-- Les États les plus représentés visibles sont NY avec 31 clients,
-- AR avec 29 clients et DE avec 29 clients.
--
-- Business interpretation:
-- La répartition par État semble plus dispersée que le genre ou le segment.
-- Certains États ont peu de clients, donc les analyses par État doivent être interprétées avec prudence.
-- Un taux élevé sur un État avec peu de clients peut être moins fiable qu’un résultat sur un volume important.


-- 6.8 Data quality summary
-- Résumons les principales limites de qualité des données.

-- Data quality summary:
-- Les données sont globalement exploitables pour l’analyse.
--
-- Points positifs:
-- - 1035 sinistres sur 1100 ont un montant exploitable.
-- - Les colonnes clients gender, state, contact et segment ne contiennent pas de valeurs NULL.
-- - Les colonnes incident_cause et claim_type ne contiennent pas de valeurs Unknown.
-- - Les colonnes gender et segment sont bien réparties.
--
-- Limites identifiées:
-- - 65 sinistres n’ont pas de montant exploitable, soit 5,91 % du portefeuille.
-- - 15 sinistres ne sont pas reliés à un client connu, soit 1,36 % du portefeuille.
-- - La colonne police_report contient 300 valeurs Unknown, soit 27,27 % des sinistres.
--
-- Business interpretation:
-- Les analyses financières sont globalement fiables, car la majorité des sinistres
-- possède un montant exploitable.
-- Les analyses par profil client sont aussi exploitables, mais 15 sinistres
-- ne pourront pas être reliés à un client.
-- La principale limite concerne police_report, car environ 1 sinistre sur 4
-- a un statut de rapport de police inconnu.
-- Cette variable doit donc être interprétée avec prudence.

/* ============================================================
   7. GLOBAL BUSINESS SUMMARY
   ============================================================ */

-- 7. GLOBAL BUSINESS SUMMARY
-- Résumons les principaux enseignements métier du portefeuille de sinistres.

-- Global business summary:
--
-- Le portefeuille contient 1100 sinistres au total.
-- Parmi eux, 1035 ont un montant exploitable et 65 n’ont pas de montant exploitable.
-- Le taux de sinistres sans montant exploitable est de 5,91 %.
--
-- Le montant total des sinistres exploitables est de 12 877 599,5.
-- Le montant moyen d’un sinistre est de 12 442,13.
--
-- Les sinistres Auto représentent la majorité du portefeuille
-- et génèrent la plus grande partie du coût total.
--
-- Les sinistres de type "Material and injury" génèrent le coût total le plus élevé,
-- malgré un volume moins important que les sinistres "Material only".
-- Cela montre que les sinistres avec blessure ont un impact financier plus élevé.
--
-- Le portefeuille contient 254 sinistres frauduleux,
-- soit un taux global de fraude de 23,09 %.
-- Cela représente environ 1 sinistre sur 4.
--
-- Les sinistres frauduleux sont moins nombreux que les sinistres non frauduleux,
-- mais leur montant moyen est légèrement plus élevé.
-- La fraude représente donc un risque important à surveiller.
--
-- Les segments Platinum et Silver présentent les taux de fraude les plus élevés,
-- mais les écarts entre segments restent faibles.
--
-- Les clients Male génèrent le coût total de sinistres le plus élevé,
-- tandis que les clientes Female présentent un taux de fraude légèrement plus élevé.
--
-- La tranche d’âge Under 30 génère le coût total le plus élevé,
-- principalement à cause d’un volume de sinistres plus important.
--
-- Certains États présentent des taux ou coûts élevés,
-- mais les volumes sont parfois faibles.
-- Les résultats par État doivent donc être interprétés avec prudence.
--
-- Sur le plan temporel, le volume et le coût total des sinistres baissent entre 2017 et 2018.
-- Cependant, le montant moyen par sinistre augmente légèrement.
--
-- Certains mois ressortent comme plus coûteux ou plus frauduleux.
-- Ces périodes doivent être analysées plus en détail pour comprendre
-- les causes, types de sinistres ou profils clients associés.
--
-- Data quality:
-- Les données sont globalement exploitables.
-- Cependant, certaines limites doivent être signalées :
-- - 65 sinistres sans montant exploitable ;
-- - 15 sinistres sans client correspondant ;
-- - 300 valeurs Unknown dans police_report, soit 27,27 % des sinistres.
--
-- Conclusion:
-- Le portefeuille présente trois axes de surveillance prioritaires :
-- 1. les sinistres Auto et les sinistres avec blessure ;
-- 2. les sinistres frauduleux, qui représentent près d’un quart du portefeuille ;
-- 3. les périodes et profils générant des coûts ou taux de fraude élevés.



