/* ============================================================
   PROJECT: Insurance Claims SQL Analysis
   FILE: 02_data_cleaning_preparation.sql
   AUTHOR: Colins
   DATABASE: insurance_claims_db

   OBJECTIVE:
   Prepare clean SQL views from the raw imported tables.
   This file standardizes column names, converts data types,
   and prepares the dataset for KPI and business analysis.
   ============================================================ */


/* ============================================================
   1. CREATE CLEAN CUSTOMERS VIEW
   ============================================================ */

-- 1.1 Create a clean customers view
-- Créons une vue propre de la table customers avec des noms de colonnes standardisés
-- et une conversion de DateOfBirth en vraie date.

DROP VIEW IF EXISTS vw_customers_clean;

CREATE VIEW vw_customers_clean AS
SELECT
    "CUST_ID" AS customer_id,
    gender,
    "DateOfBirth" AS date_of_birth_raw,
    TO_DATE("DateOfBirth", 'DD-Mon-YY') AS date_of_birth,
    "State" AS state,
    "Contact" AS contact,
    "Segment" AS segment
FROM customers;

-- 1.2 Preview clean customers view
-- Vérifions que la vue vw_customers_clean fonctionne correctement.

SELECT *
FROM vw_customers_clean
LIMIT 10;


/* ============================================================
   2. CREATE CLEAN CLAIMS VIEW
   ============================================================ */

-- 2.1 Create a clean claims view
-- Créons une vue propre de la table claims avec des noms de colonnes standardisés,
-- en conservant les valeurs brutes et en ajoutant des colonnes converties.

DROP VIEW IF EXISTS vw_claims_clean;

CREATE VIEW vw_claims_clean AS 
SELECT 
    claim_id,
    customer_id,
    incident_cause,

    claim_date AS claim_date_raw,
    TO_DATE(claim_date, 'MM/DD/YYYY') AS claim_date,

    claim_area,
    police_report,
    claim_type,

    claim_amount AS claim_amount_raw,
    CASE
        WHEN claim_amount = 'NA' THEN NULL 
        ELSE REPLACE(claim_amount, '$', '')::numeric
    END AS claim_amount,

    total_policy_claims AS total_policy_claims_raw,
    CASE
        WHEN total_policy_claims = 'NA' THEN NULL
        ELSE total_policy_claims::integer
    END AS total_policy_claims,

    fraudulent AS fraudulent_raw,
    CASE 
        WHEN fraudulent = 'Yes' THEN TRUE 
        WHEN fraudulent = 'No' THEN FALSE 
        ELSE NULL 
    END AS is_fraudulent

FROM claims;

-- 2.2 Preview clean claims view
-- Vérifions que la vue vw_claims_clean fonctionne correctement.

SELECT *
FROM vw_claims_clean
LIMIT 10;


/* ============================================================
   3. VALIDATE CLEAN VIEWS
   ============================================================ */

-- 3.1 Preview clean customers view
-- Vérifions que la vue vw_customers_clean fonctionne correctement.

SELECT *
FROM vw_customers_clean
LIMIT 10;

-- 3.2 Preview clean claims view
-- Vérifions que la vue vw_claims_clean fonctionne correctement.

SELECT *
FROM vw_claims_clean
LIMIT 10;

-- 3.3 Check converted customers columns
-- Vérifions la conversion de DateOfBirth en date_of_birth.

SELECT
    date_of_birth_raw,
    date_of_birth
FROM vw_customers_clean
LIMIT 10;

-- 3.4 Check converted claims columns
-- Vérifions les conversions principales dans vw_claims_clean.

SELECT 
    claim_date_raw,
    claim_date,
    claim_amount_raw,
    claim_amount,
    total_policy_claims_raw,
    total_policy_claims,
    fraudulent_raw,
    is_fraudulent
FROM vw_claims_clean
LIMIT 10;

-- 3.5 Check clean views column types
-- Vérifions les types de données des colonnes dans les vues propres.

SELECT 
    table_name,
    column_name,
    data_type
FROM information_schema.columns
WHERE table_name IN ('vw_customers_clean', 'vw_claims_clean')
ORDER BY table_name, ordinal_position;

-- 3.6 Check NULL values after cleaning
-- Vérifions les valeurs NULL après conversion des colonnes principales.

SELECT 
    COUNT(*) AS total_claims,

    COUNT(claim_date) AS non_null_claim_date,
    COUNT(*) - COUNT(claim_date) AS null_claim_date,

    COUNT(claim_amount) AS non_null_claim_amount,
    COUNT(*) - COUNT(claim_amount) AS null_claim_amount,

    COUNT(total_policy_claims) AS non_null_total_policy_claims,
    COUNT(*) - COUNT(total_policy_claims) AS null_total_policy_claims,

    COUNT(is_fraudulent) AS non_null_is_fraudulent,
    COUNT(*) - COUNT(is_fraudulent) AS null_is_fraudulent

FROM vw_claims_clean;

-- Résultat:
-- La vue vw_claims_clean contient 1100 sinistres.
-- claim_date ne contient aucune valeur NULL après conversion.
-- claim_amount contient 65 valeurs NULL, correspondant aux montants non exploitables comme NA.
-- total_policy_claims contient 10 valeurs NULL, correspondant aux valeurs non exploitables comme NA.
-- is_fraudulent ne contient aucune valeur NULL après recodage.

-- 3.7 Data cleaning summary
-- Résumons les principales transformations effectuées dans les vues propres.

-- Résultat:
-- La vue vw_customers_clean a été créée à partir de la table customers.
-- Les noms de colonnes ont été standardisés.
-- DateOfBirth a été conservée en date_of_birth_raw et convertie en date_of_birth.
--
-- La vue vw_claims_clean a été créée à partir de la table claims.
-- claim_date a été conservée en claim_date_raw et convertie en DATE.
-- claim_amount a été conservée en claim_amount_raw, nettoyée puis convertie en NUMERIC.
-- Les valeurs claim_amount égales à 'NA' ont été converties en NULL.
-- total_policy_claims a été conservée en total_policy_claims_raw puis convertie en INTEGER.
-- Les valeurs total_policy_claims égales à 'NA' ont été converties en NULL.
-- fraudulent a été conservée en fraudulent_raw puis recodée en BOOLEAN avec is_fraudulent.
--
-- Contrôle qualité après nettoyage:
-- vw_claims_clean contient 1100 sinistres.
-- claim_date ne contient aucune valeur NULL.
-- claim_amount contient 65 valeurs NULL.
-- total_policy_claims contient 10 valeurs NULL.
-- is_fraudulent ne contient aucune valeur NULL.
--
-- Conclusion:
-- Les vues propres sont prêtes pour les analyses KPI.
-- Les prochaines analyses utiliseront les colonnes converties:
-- date_of_birth, claim_date, claim_amount, total_policy_claims et is_fraudulent.