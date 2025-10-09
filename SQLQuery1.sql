-- Ustvari tabelo za podatke o stresu
CREATE TABLE stress_data (
    Gender INT,
    Age INT,
    RecentStress INT,
    RapidHeartbeat INT,
    AnxietyTension INT,
    SleepProblems INT,
    AnxietyTensionRecent INT,
    Headaches INT,
    Irritated INT,
    TroubleConcentrating INT,
    SadnessLowMood INT,
    HealthIssues INT,
    LonelyIsolated INT,
    OverwhelmedAcademic INT,
    CompetitionAffects INT,
    RelationshipStress INT,
    DifficultiesWithProfessors INT,
    UnpleasantWorkEnv INT,
    NoRelaxationTime INT,
    HostelHomeEnvDifficulties INT,
    LackConfidenceAcademic INT,
    LackConfidenceSubjects INT,
    ActivitiesConflict INT,
    AttendClassesRegularly INT,
    WeightChange INT,
    StressType VARCHAR(100)
); --problematika bila v temu, da so podatki loèeni s podpièjem (;), ne z vejico, in ker niso bili pravilno naloženi, zato:

-- Èe so podatki že v tabeli, jih izbrišemo
TRUNCATE TABLE stress_data;

-- Uvoz podatkov z BULK INSERT (prilagojeno za podpièje kot loèilo)
BULK INSERT stress_data
FROM 'C:\Users\Tjasa\Downloads\Stress_Dataset.csv'  -- Prilagodi pot do datoteke
WITH (
    FIELDTERMINATOR = ';',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2  -- Èe prva vrstica vsebuje glavo
);
-- Preverjanje prvih nekaj vrstic
SELECT TOP 5 * FROM stress_data;
-- Osnovna statistika za kljuène stolpce
SELECT 
    AVG(RecentStress) AS avg_recent_stress,--AVG(): Je SQL funkcija, ki izraèuna povpreèno vrednost (aritmetièno sredino) vseh števil v stolpcu, 
    --Kljuèna beseda AS se uporablja za poimenovanje izhodnega stolpca. Namesto da bi se stolpec imenoval AVG(RecentStress), ga preimenujemo v bolj berljivo avg_recent_stress.
    AVG(SleepProblems) AS avg_sleep_problems,
    AVG(AnxietyTension) AS avg_anxiety,
    STDEV(RecentStress) AS stdev_stress,--STDEV(): Je SQL funkcija, ki izraèuna standardni odklon vseh vrednosti v stolpcu.
--Standardni odklon je statistièni pokazatelj, ki meri, kako zelo so podatki razpršeni okoli povpreèja.
--Nizka vrednost: Podatki so zgošèeni blizu povpreèja (posamezniki so bolj podobni).
--Visoka vrednost: Podatki so zelo razpršeni (velika raznolikost med posamezniki).
    COUNT(*) AS total_records--COUNT(*): Je SQL funkcija, ki prešteje skupno število vrstic (zapisov) v tabeli,kar pomeni "vse stolpce". Funkcija prešteje vsako vrstico, ne glede na vsebino.
--Skupni pomen vrstice: "Preštej vse zapise v tabeli stress_data in rezultat poimenuj total_records."
FROM stress_data;--FROM: Doloèa iz kater tabele naj poizvedba èrpa podatke.
-- Korelacija med stresom, težavami s spanjem in anksioznostjo
SELECT 
    (AVG(RecentStress * SleepProblems) - AVG(RecentStress) * AVG(SleepProblems)) / 
    (STDEV(RecentStress) * STDEV(SleepProblems)) AS correlation_stress_sleep,   
    (AVG(RecentStress * AnxietyTension) - AVG(RecentStress) * AVG(AnxietyTension)) / 
    (STDEV(RecentStress) * STDEV(AnxietyTension)) AS correlation_stress_anxiety,   
    (AVG(SleepProblems * AnxietyTension) - AVG(SleepProblems) * AVG(AnxietyTension)) / 
    (STDEV(SleepProblems) * STDEV(AnxietyTension)) AS correlation_sleep_anxiety
FROM stress_data;
-- Povpreèje po spolu (èe obstaja stolpec Gender)
SELECT 
    Gender,
    AVG(RecentStress) AS avg_stress,
    AVG(SleepProblems) AS avg_sleep,
    AVG(AnxietyTension) AS avg_anxiety,
    COUNT(*) AS count_per_group
FROM stress_data
WHERE Gender IS NOT NULL--WHERE Gender IS NOT NULL - izkljuèi zapise, kjer spol ni definiran
GROUP BY Gender
ORDER BY avg_stress DESC;
-- Analiza po starostnih skupinah
SELECT 
    CASE 
        WHEN Age < 25 THEN 'Under 25'
        WHEN Age BETWEEN 25 AND 35 THEN '25-35'
        WHEN Age BETWEEN 36 AND 50 THEN '36-50'
        ELSE 'Over 50'
    END AS age_group,--CASE stavek ustvari nove kategorije iz številskih starosti. BETWEEN vkljuèuje obe meji.

    AVG(RecentStress) AS avg_stress,
    AVG(SleepProblems) AS avg_sleep,
    AVG(AnxietyTension) AS avg_anxiety,
    COUNT(*) AS count_per_group
FROM stress_data
WHERE Age IS NOT NULL
GROUP BY CASE 
        WHEN Age < 25 THEN 'Under 25'
        WHEN Age BETWEEN 25 AND 35 THEN '25-35'
        WHEN Age BETWEEN 36 AND 50 THEN '36-50'
        ELSE 'Over 50'
    END
ORDER BY avg_stress DESC;
-- Najdemo osebe z najvišjim stresom
SELECT TOP 10 *
FROM stress_data
ORDER BY RecentStress DESC;--ORDER BY RecentStress DESC jih uredi od najvišjega do najnižjega stresa.

-- Osebe z visokim stresom IN težavami s spanjem
SELECT *
FROM stress_data
WHERE RecentStress >= 8 AND SleepProblems >= 8
ORDER BY RecentStress DESC, SleepProblems DESC;

-- Frekvenèna distribucija stopenj stresa
SELECT 
    RecentStress AS stress_level,
    COUNT(*) AS frequency,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM stress_data), 2) AS percentage 
    --(SELECT COUNT(*) FROM stress_data) - skupno število vseh ljudi
    --* 100.0 - pretvorba v odstotke (.0 zagotovi decimalno deljenje), ROUND(..., 2) - zaokroži na 2 decimalki
FROM stress_data
GROUP BY RecentStress
ORDER BY RecentStress;

-- Histogram za težave s spanjem (združimo v razrede)
SELECT 
    CASE 
        WHEN SleepProblems BETWEEN 0 AND 3 THEN 'Low (0-3)'
        WHEN SleepProblems BETWEEN 4 AND 6 THEN 'Medium (4-6)'
        WHEN SleepProblems BETWEEN 7 AND 10 THEN 'High (7-10)'
        ELSE 'Other'
    END AS sleep_category,
    COUNT(*) AS count,
    AVG(RecentStress) AS avg_stress_in_category
FROM stress_data
GROUP BY CASE 
        WHEN SleepProblems BETWEEN 0 AND 3 THEN 'Low (0-3)'
        WHEN SleepProblems BETWEEN 4 AND 6 THEN 'Medium (4-6)'
        WHEN SleepProblems BETWEEN 7 AND 10 THEN 'High (7-10)'
        ELSE 'Other'
    END
ORDER BY sleep_category;
-- Identifikacija visoko-tveganih posameznikov
SELECT 
    COUNT(*) AS high_risk_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM stress_data), 2) AS high_risk_percentage
FROM stress_data
WHERE RecentStress >= 8 AND SleepProblems >= 7 AND AnxietyTension >= 8;--Iskanje ljudi z visokimi vrednostmi v vseh treh kategorijah hkrati. To so potencialno najbolj ogroženi.

-- Demografska analiza tveganih skupin
SELECT 
    Gender,
    AVG(Age) AS avg_age,
    COUNT(*) AS high_risk_count
FROM stress_data
WHERE RecentStress >= 8 AND SleepProblems >= 7
    AND Gender IS NOT NULL
GROUP BY Gender;

-- Èe uporabljate SQL Server 2012 ali novejši
SELECT 
    'RecentStress' AS variable,
    MIN(RecentStress) AS minimum,
    MAX(RecentStress) AS maximum,
    AVG(RecentStress) AS average,
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY RecentStress) OVER () AS q1,--PERCENTILE_CONT(0.25) - izraèuna 25 percentil (spodnji kvartil)
    PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY RecentStress) OVER () AS median,--WITHIN GROUP (ORDER BY RecentStress) - podatke uredi po stresu
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY RecentStress) OVER () AS q3--OVER () - uporabi celoten dataset (brez razdeljevanja na skupine)
FROM stress_data
GROUP BY RecentStress;

-- Preverimo razpon vrednosti za vsako spremenljivko
SELECT 
    MIN(SleepProblems) as min_sleep,
    MAX(SleepProblems) as max_sleep,
    AVG(SleepProblems) as avg_sleep,
    MIN(AnxietyTension) as min_anxiety,
    MAX(AnxietyTension) as max_anxiety,
    AVG(AnxietyTension) as avg_anxiety--MIN() - najmanjša vrednost,MAX() - najveèja vrednost, AVG() - povpreèna vrednost
FROM stress_data;
-- Ker imate omejen razpon, analizirajmo kar direktno
SELECT 
    SleepProblems,
    COUNT(*) AS number_of_people,
    AVG(RecentStress) AS average_stress,
    AVG(AnxietyTension) AS average_anxiety
FROM stress_data
GROUP BY SleepProblems
ORDER BY SleepProblems;
--GROUP BY + agregate (AVG, COUNT, etc.) = analiza po skupinah
--WHERE + pogoji = filtriranje podatkov
--CASE + WHEN = ustvarjanje novih kategorij
--ORDER BY + DESC = urejanje rezultatov

--  Ustvari tabelo participants
IF OBJECT_ID('dbo.participants') IS NOT NULL DROP TABLE dbo.participants;

CREATE TABLE participants (
  participant_id INT PRIMARY KEY,
  gender INT,
  age INT,
  stress_type VARCHAR(100)
);

INSERT INTO participants (participant_id, gender, age, stress_type)
SELECT participant_id, Gender, Age, StressType
FROM stress_data_with_id;

-- Po želji: odstranitev teh stolpcev iz working tabele (komentirano, uporabno kadar si preprièana)
-- ALTER TABLE stress_data_with_id DROP COLUMN Gender, Age, StressType;

-- Ustvari tabelo za podatke o spanju in življenjskem slogu
CREATE TABLE sleep_health_data (
    PersonID INT,
    Gender VARCHAR(10),
    Age INT,
    Occupation VARCHAR(100),--VARCHAR(n) - Spremenljiv besedilni niz z maksimalno dolžino n znakov
    SleepDuration DECIMAL(4,2),--Zakaj je parameter decimal? Ker trajanje spanja je lahko npr. 7.5 ur ali 8.25 ur
    QualityOfSleep INT,--INT-Celo število (npr. 1, 25, 100)
    PhysicalActivityLevel INT,
    StressLevel INT,
    BMICategory VARCHAR(50),
    BloodPressure VARCHAR(20),--Varchar-> ker imamo razliène dolžine besed (poklici, kategorije)
    HeartRate INT,
    DailySteps INT,
    SleepDisorder VARCHAR(50)
);

-- Uvoz podatkov
BULK INSERT sleep_health_data
FROM 'C:\Users\Tjasa\Downloads\Sleep_health_and_lifestyle_dataset.csv'
WITH (
    FIELDTERMINATOR = ',',--FIELDTERMINATOR = ',' - Loèilo med polji je vejica (CSV format)
    ROWTERMINATOR = '\n',--ROWTERMINATOR = '\n' - Loèilo med vrsticami je nova vrstica
    FIRSTROW = 2
);

-- Preverimo podatke
SELECT TOP 5 * FROM sleep_health_data;-- * -> Izbere VSE stolpce iz tabele

-- Primerjava povpreènega stresa med obema tabelama
SELECT 
    'Stress Dataset' AS source,
    AVG(RecentStress) AS avg_stress,
    COUNT(*) AS sample_size
FROM stress_data
UNION ALL--združi rezultate dveh poizvedb v eno rezultanto tabelo. 
--To nam omogoèa neposredno primerjavo povpreènih stresnih ravni med obema podatkovnima nizoma.
SELECT 
    'Sleep Health Dataset' AS source,
    AVG(StressLevel) AS avg_stress,
    COUNT(*) AS sample_size
FROM sleep_health_data;

-- Stres in težave s spanjem po spolu (združena analiza)
SELECT 
    'Stress Dataset' AS dataset,
    CASE WHEN Gender = 1 THEN 'Male' WHEN Gender = 2 THEN 'Female' ELSE 'Other' END AS gender,-- Pretvorba številk v besedilo
    AVG(RecentStress) AS avg_stress,
    AVG(SleepProblems) AS avg_sleep_problems,
    COUNT(*) AS count-- Število ljudi v skupini
FROM stress_data
WHERE Gender IN (1, 2)-- Filtriranje samo moških in žensk
GROUP BY Gender

UNION ALL

SELECT 
    'Sleep Health Dataset' AS dataset,
    Gender,
    AVG(StressLevel) AS avg_stress,
    AVG(QualityOfSleep) AS avg_sleep_quality,
    COUNT(*) AS count
FROM sleep_health_data
WHERE Gender IN ('Male', 'Female')
GROUP BY Gender 
ORDER BY dataset, gender;

-- Korelacija starosti in stresa v obeh datasetih
WITH stress_corr AS (
    SELECT 
        (AVG(Age * RecentStress) - AVG(Age) * AVG(RecentStress)) / 
        (STDEV(Age) * STDEV(RecentStress)) AS correlation_coefficient,
        'Stress Dataset' AS dataset
    FROM stress_data
    WHERE Age IS NOT NULL
),
sleep_corr AS (
    SELECT 
        (AVG(Age * StressLevel) - AVG(Age) * AVG(StressLevel)) / 
        (STDEV(Age) * STDEV(StressLevel)) AS correlation_coefficient,
        'Sleep Health Dataset' AS dataset
    FROM sleep_health_data
    WHERE Age IS NOT NULL
)
SELECT * FROM stress_corr
UNION ALL
SELECT * FROM sleep_corr;

-- Korelacija starosti in stresa v obeh datasetih
WITH stress_corr AS (-- Zaèetek prve CTE (Common Table Expression) za stress dataset
    SELECT 
        (AVG(Age * RecentStress) - AVG(Age) * AVG(RecentStress)) / -- Formula za Pearsonovo korelacijsko koeficient:
        (STDEV(Age) * STDEV(RecentStress)) AS correlation_coefficient,-- (povpreèje(produktov) - produkt(povpreèij)) / (produkt(standardnih odklonov))
        'Stress Dataset' AS dataset-- Konstanta za identifikacijo dataseta
    FROM stress_data
    WHERE Age IS NOT NULL-- Filtrira vrstice kjer starost ni NULL
),
sleep_corr AS (-- Druga CTE za sleep health dataset
    SELECT 
        (AVG(Age * StressLevel) - AVG(Age) * AVG(StressLevel)) / 
        (STDEV(Age) * STDEV(StressLevel)) AS correlation_coefficient,
        'Sleep Health Dataset' AS dataset
    FROM sleep_health_data
    WHERE Age IS NOT NULL
)
-- Glavni SELECT ki združi rezultate iz obeh CTE
SELECT * FROM stress_corr
UNION ALL -- Združi rezultate iz obeh CTE (ohrani vse vrstice)
SELECT * FROM sleep_corr;