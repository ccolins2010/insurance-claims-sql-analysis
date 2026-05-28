/* ================================================================================================
   PROJET: Insurance Claims sql Analysis
   FILE: 01_data_exploration.sql
   AUTHOR: Colins
   DATABASE: insurance_claims_db

   OBJECTIVE: 
   Explore the customers and claims tables before perfoming business analysis and KPI calculations.
   ================================================================================================ */

/* ===============================================================================
   1. PREVIEW TABLES
   =============================================================================== */

-- 1.1 Preview customers table
-- Affichons les 10 premieres lignes de la tables customers.
SELECT *
FROM customers
LIMIT 10;

-- 1.2 Preview claims table
-- Affichons les 10 premières lignes de la table claims.
select *
from claims 
limit 10;

/* ===============================================================================
   2. COUNT ROWS
   =============================================================================== */

-- 2.1 Count total customers
-- Comptons le nombre total de clients dans la table customers
SELECT 
COUNT(*) AS total_customers
FROM customers;

-- 2.2 Count total claims
-- Comptons le nombre total de sinistres dans la table claims.
SELECT 
COUNT(*) AS total_claims
FROM claims;
   
/* ===============================================================================
   3. CHECK DISTINCT VALUES
   =============================================================================== */

-- 3.1 Check distinct customer genders
-- Vérifions les differents valeurs présentes dans la colonne gender.
SELECT DISTINCT 
gender 
FROM customers 
ORDER BY gender;

-- 3.2 Checks distinct customer states
-- Vérifions les differents Etats présents dans la table customers.
SELECT DISTINCT 
"State" 
FROM customers 
ORDER BY "State" ;

-- 3.3 Check distinct incident causes
-- Vérifions les differentes causes de sinistres
SELECT DISTINCT 
incident_cause
FROM claims 
ORDER BY incident_cause;

-- 3.4 Check distinct claims aeras
-- Vérifions des differents zones de sinistres.
SELECT DISTINCT 
claim_area
FROM claims 
ORDER BY claim_area;

-- 3.5 Check distinct claim types
-- Vérifions les differents types de sinistres
SELECT DISTINCT 
claim_type
FROM claims 
ORDER BY claim_type;

/* ===============================================================================
   4. CHECK DUPLICATES
   =============================================================================== */

-- 4.1 Check duplicate customers by customer ID
-- Vérifions si un même client apparaît plusieurs fois dans la tables customers
SELECT 
"CUST_ID",
COUNT(*) AS number_of_rows
FROM customers 
GROUP BY "CUST_ID" 
HAVING COUNT(*) > 1;

-- 4.2 Check duplicate claims by claim ID
-- Vérifions si un même sinistre apparaît plusieurs fois dans la table claims
SELECT 
claim_id,
COUNT(*) AS number_of_rows
FROM claims 
GROUP BY claim_id 
HAVING COUNT(*) > 1;

/* ===============================================================================
   5. CHECK MISSING VALUES
   =============================================================================== */

-- 5.1 Check missing values in key customers columns
-- Vérifions les valeurs non nulles dans les colonnes importantes de customers.
SELECT 
COUNT(*) AS total_rows,
COUNT("CUST_ID") AS non_null_customer_ids,
COUNT(gender) AS non_null_gender,
COUNT("DateOfBirth") AS non_null_date_of_birth,
COUNT("State") AS non_null_state,
COUNT("Contact") AS non_null_contact,
COUNT("Segment") AS non_null_segment
FROM customers ;

-- Résultat:
-- Aucune valeur NULL détectée dans les colonnes clés testées.


-- 5.2 Check missing valuers in key claims columns
-- Vérifions les valeurs non nulles dans les colonnes importantes de claims.
SELECT 
COUNT(*) AS total_rows,
COUNT(claim_id) AS non_null_claim_ids,
COUNT(customer_id) AS non_null_customer_ids,
COUNT(incident_cause) AS non_null_incident_cause,
COUNT(claim_date) AS non_null_claim_date,
COUNT(claim_area) AS non_null_claim_aera,
COUNT(claim_type) AS non_null_claim_type,
COUNT(claim_amount) AS non_null_claim_amount
FROM claims;

-- Résultat:
-- Aucune valeur NULL détectée dans les colonnes clés testées.

-- 5.3 Check missing values in all claims columns
-- Vérifions les valeurs non nulles dans toutes les colonnes de claims.
SELECT
    COUNT(*) AS total_rows,
    COUNT(claim_id) AS non_null_claim_ids,
    COUNT(customer_id) AS non_null_customer_ids,
    COUNT(incident_cause) AS non_null_incident_cause,
    COUNT(claim_date) AS non_null_claim_date,
    COUNT(claim_area) AS non_null_claim_area,
    COUNT(police_report) AS non_null_police_report,
    COUNT(claim_type) AS non_null_claim_type,
    COUNT(claim_amount) AS non_null_claim_amount,
    COUNT(total_policy_claims) AS non_null_total_policy_claims,
    COUNT(fraudulent) AS non_null_fraudulent
FROM claims;

-- Résultat:
-- Aucune valeur NULL détectée dans les toutes colonnes testées.


/* ===============================================================================
   6. CHECK RELATIONSHIP BETWEEN TABLES
   =============================================================================== */


-- 6.1 Check claims linked to customers
-- Vérifions combien de sinistres sont reliés à un client existant.
SELECT 
COUNT(*) AS total_claims,
COUNT(c."CUST_ID") AS claims_with_matching_customer
FROM claims cl
LEFT JOIN customers c 
ON cl.customer_id = c."CUST_ID";


-- 6.2 Find claims without matching customer
-- Identifions les sinistres dont le client n'existe pas dans la table customers.
SELECT 
cl.customer_id,
COUNT(*) AS number_of_claims
FROM claims cl
LEFT JOIN customers c
ON cl.customer_id  = c."CUST_ID"
WHERE c."CUST_ID" IS NULL 
GROUP BY cl.customer_id 
ORDER BY number_of_claims DESC;


/* ===============================================================================
   7. CHECK DATA TYPES
   =============================================================================== */

-- 7.1 Check customers table column types
-- Vérifions les types de données des colonnes de la table customers.
SELECT 
column_name,
data_type
FROM information_schema.columns
WHERE table_name = 'customers'
ORDER BY ordinal_position;


-- 7.2 Check claims table columns types
-- Vérifions les types de données de colonnes de la table claims.
SELECT 
column_name,
data_type
FROM information_schema.COLUMNS 
WHERE table_name = 'claims'
ORDER BY ordinal_position;


/* ===============================================================================
   8. CHECK INCONSISTENT VALUES
   =============================================================================== */

-- À cette étape, nous vérifions en priorité les colonnes dont le type actuel
-- ne correspond pas forcément au sens métier attendu.
--
-- Par exemple :
-- - DateOfBirth devrait idéalement être une date, et non du texte.
-- - claim_date devrait idéalement être une date, et non du texte.
-- - claim_amount devrait idéalement être une valeur numérique, et non du texte.
-- - total_policy_claims devrait idéalement être une valeur numérique.
-- - fraudulent pourrait idéalement être une valeur booléenne.
--
-- L’objectif est d’inspecter ces colonnes avant de les convertir
-- ou de les utiliser dans des analyses métier et des KPI.

-- 8.1 Preview claim_amount values
-- Vérifions le format des montants de sinistres.
SELECT 
claim_amount
FROM claims 
LIMIT 20;

-- Résultat:
-- claim_amount est stocké en texte et contient un symbole dollar.
-- Certaines valeurs contiennent des décimales.
-- Cette colonne devra être nettoyée puis convertie en numérique avant les calculs de KPI.


-- 8.2 Preview claim_date values
-- Vérifions le format des dates de sinistres.

SELECT
claim_date
FROM claims
LIMIT 20;

-- Résultat:
-- claim_date est stockée en texte.
-- Le format observé est MM/DD/YYYY.
-- Cette colonne devra être convertie en DATE avant les analyses temporelles.


-- 8.3 Preview DateOfBirth values
-- Vérifions le format des dates de naissances des clients

SELECT
"DateOfBirth"
FROM customers 
LIMIT  20;

-- Résultat:
-- DateOfBirth est stockée en texte.
-- Le format observé est DD-Mon-YY, par exemple 12-Jan-79.
-- Cette colonne devra être convertie en DATE avant de calculer l'âge des clients.


-- 8.4 Preview total_policy_claims values
-- Vérifions le format du nombre total de sinistres liés à la police de la table claims.

SELECT total_policy_claims
FROM claims 
LIMIT 20;

-- Résultat:
-- total_policy_claims est stockée en texte.
-- Les valeurs observées ressemblent à des nombres entiers.
-- Cette colonne pourra être convertie en INTEGER avant les analyses quantitatives.


-- 8.5 Check distinct fraudulent values
-- Vérifions les différentes valeurs présentes dans la colonne fraudulent.
SELECT DISTINCT 
fraudulent
FROM claims 
ORDER BY  fraudulent;

-- Résultat:
-- fraudulent contient uniquement deux valeurs : No et Yes.
-- La colonne est stockée en texte, mais elle représente une information booléenne.
-- Elle pourra être convertie ou recodée plus tard en TRUE/FALSE si nécessaire.


-- 8.6 Check distinct police_report values
-- Vérifions les différentes valeurs présentes dans la colonne police_report.
SELECT DISTINCT
police_report
FROM claims 
ORDER BY police_report;

-- Résultat:
-- police_report contient trois valeurs : No, Unknown et Yes.
-- Unknown indique que l'information sur le rapport de police est manquante ou non renseignée.
-- Cette valeur devra être prise en compte dans les analyses liées à la fraude ou au risque.


/* ============================================================
   9. DATA EXPLORATION SUMMARY
   ============================================================ */

-- Résumé:
-- La table customers contient 1085 lignes.
-- La table claims contient 1100 lignes.
--
-- Aucun doublon n'a été détecté sur les identifiants clients.
-- Aucun doublon n'a été détecté sur les identifiants de sinistres.
--
-- Aucune valeur NULL n'a été détectée dans les colonnes clés testées.
--
-- La vérification de relation entre les tables montre que:
-- - 1100 sinistres sont présents au total.
-- - 1085 sinistres sont reliés à un client existant.
-- - 15 sinistres ont un customer_id absent de la table customers.
--
-- Plusieurs colonnes ont été importées comme texte et devront être converties:
-- - customers.DateOfBirth devrait être convertie en DATE.
-- - claims.claim_date devrait être convertie en DATE.
-- - claims.claim_amount devrait être nettoyée puis convertie en NUMERIC.
-- - claims.total_policy_claims devrait être convertie en INTEGER.
-- - claims.fraudulent pourrait être convertie ou recodée en BOOLEAN.
--
-- Valeurs catégorielles observées:
-- - gender: Female, Male
-- - claim_area: Auto, Home
-- - claim_type: Injury only, Material and injury, Material only
-- - fraudulent: No, Yes
-- - police_report: No, Unknown, Yes
--
-- Conclusion:
-- Le dataset est exploitable pour l'analyse, mais certaines colonnes
-- nécessitent un nettoyage et une conversion de type avant de construire
-- des KPI fiables.


