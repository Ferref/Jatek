-- Adatbázis létrehozása ha nem létezik
CREATE DATABASE IF NOT EXISTS Jatek;
USE Jatek;

-- Trigger: Kaszt életerő, sebzés módosítója
DROP TRIGGER IF EXISTS kaszt_modositok;

-- Trigger: Csoport tagokSzama növelése
DROP TRIGGER IF EXISTS noveles_tagokSzama;

-- Trigger: Parbaj létrejöhet -e
DROP TRIGGER IF EXISTS check_parbaj_kovetelmenyek;

-- Trigger: Be tud a lépni a játékos a helyszínre
DROP TRIGGER IF EXISTS check_helyszin_minimum_szint;

-- TRIGGER: Párbaj követelmény, tapasztalatpont és arany növelése ha létrejön a párbaj
DROP TRIGGER IF EXISTS check_parbaj_kovetelmenyek_and_gyozelem_tapasztalatpont_noveles

-- TRIGGER: Harc utáni tapasztalatpont, arany
DROP TRIGGER IF EXISTS check_harc_kovetelmeny_and_harc_szorny_legyozese

-- TRIGGER: Jatekos szintje nem lehet nagyobb mint 100
DROP TRIGGER IF EXISTS check_jatekos_szint

-- TRIGGER: Jatekos szintje legyen a jatekos tapasztalatPontja / 1000
DROP TRIGGER IF EXISTS update_jatekos_szint

-- nincs meg kesz
    -- vasarlas trigger
    -- felszereles trigger
    -- bolt elad, vasarol trigger


-- Kaszt tábla létrehozása
CREATE TABLE IF NOT EXISTS Kaszt (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nev VARCHAR(100) NOT NULL,
    eleteroModosito INT,
    sebzesModosito INT
);

-- Kepesseg tábla létrehozása
CREATE TABLE IF NOT EXISTS Kepesseg (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nev VARCHAR(100) NOT NULL,
    sebzes INT NOT NULL,
    kasztId INT,
    minimumSzint INT DEFAULT 1,
    FOREIGN KEY (kasztId) REFERENCES Kaszt(id) ON DELETE CASCADE
);

-- Helyszin tábla létrehozása
CREATE TABLE IF NOT EXISTS Helyszin (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nev VARCHAR(100) NOT NULL,
    minimumSzint INT DEFAULT 1
);

-- Felhasznalo tábla létrehozása
CREATE TABLE IF NOT EXISTS Felhasznalo (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nev VARCHAR(100) NOT NULL,
    jelszo VARCHAR(100) NOT NULL
);

-- Szerver tábla létrehozása
CREATE TABLE IF NOT EXISTS Szerver (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nev VARCHAR(100) NOT NULL
);

-- Csoport tábla létrehozása
CREATE TABLE IF NOT EXISTS Csoport (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nev VARCHAR(100) NOT NULL,
    tagokSzama INT DEFAULT 0,
    CONSTRAINT check_tagokSzama CHECK (tagokSzama <= 4)
);

-- Bolt tábla létrehozása
CREATE TABLE IF NOT EXISTS Bolt (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nev VARCHAR(100) NOT NULL
);

-- FelhasznaloSzerver tábla létrehozása
CREATE TABLE IF NOT EXISTS FelhasznaloSzerver (
    szerverId INT,
    felhasznaloId INT,
    redDate DATETIME DEFAULT NOW(),
    FOREIGN KEY (szerverId) REFERENCES Szerver(id) ON DELETE CASCADE,
    FOREIGN KEY (felhasznaloId) REFERENCES Felhasznalo(id) ON DELETE CASCADE,
    PRIMARY KEY (szerverId, felhasznaloId)
);

-- Jatekos tábla létrehozása
CREATE TABLE IF NOT EXISTS Jatekos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nev VARCHAR(50) NOT NULL UNIQUE,
    szerverId INT,
    felhasznaloId INT,
    nem CHAR(1) NOT NULL,
    kasztId INT,
    tapasztalatPont INT DEFAULT 0,
    szint INT DEFAULT 1,
    eletero INT DEFAULT 1000,
    sebzes INT DEFAULT 1000,
    parbajraHivhato BOOLEAN DEFAULT FALSE,
    csoportId INT,
    arany INT DEFAULT 0,
    online BOOLEAN DEFAULT TRUE,
    helyszinId INT,
    csapatBonusz FLOAT DEFAULT 1.0, -- Hozzáadott oszlop
    FOREIGN KEY (szerverId) REFERENCES Szerver(id) ON DELETE CASCADE,
    FOREIGN KEY (felhasznaloId) REFERENCES Felhasznalo(id) ON DELETE CASCADE,
    FOREIGN KEY (kasztId) REFERENCES Kaszt(id) ON DELETE CASCADE,
    FOREIGN KEY (csoportId) REFERENCES Csoport(id) ON DELETE CASCADE,
    FOREIGN KEY (helyszinId) REFERENCES Helyszin(id) ON DELETE CASCADE
);

-- Felszereles tábla létrehozása
CREATE TABLE IF NOT EXISTS Felszereles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nev VARCHAR(100) NOT NULL,
    kasztId INT,
    sebzes INT NOT NULL,
    eletero INT NOT NULL,
    minimumSzint INT DEFAULT 1,
    kategoria INT NOT NULL,
    FOREIGN KEY (kasztId) REFERENCES Kaszt(id) ON DELETE CASCADE
);

-- JatekosFelszereles tábla létrehozása
CREATE TABLE IF NOT EXISTS JatekosFelszereles (
    jatekosId INT,
    felszerelesId INT,
    felveve BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (jatekosId) REFERENCES Jatekos(id) ON DELETE CASCADE,
    FOREIGN KEY (felszerelesId) REFERENCES Felszereles(id) ON DELETE CASCADE,
    PRIMARY KEY (jatekosId, felszerelesId)
);

-- Szorny tábla létrehozása
CREATE TABLE IF NOT EXISTS Szorny (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nev VARCHAR(100) NOT NULL,
    tapasztalatPontotAd INT NOT NULL,
    szint INT DEFAULT 1,
    eletero INT NOT NULL,
    sebzes INT NOT NULL,
    aranyatDobhat INT NOT NULL,
    helyszinId INT,
    FOREIGN KEY (helyszinId) REFERENCES Helyszin(id) ON DELETE CASCADE
);

-- SzornyFelszerelestDobhat tábla létrehozása
CREATE TABLE IF NOT EXISTS SzornyFelszerelestDobhat (
    szornyId INT,
    felszerelesId INT,
    FOREIGN KEY (szornyId) REFERENCES Szorny(id) ON DELETE CASCADE,
    FOREIGN KEY (felszerelesId) REFERENCES Felszereles(id) ON DELETE CASCADE,
    PRIMARY KEY (szornyId, felszerelesId)
);

-- BoltFelszereles tábla létrehozása
CREATE TABLE IF NOT EXISTS BoltFelszereles (
    boltId INT,
    felszerelesId INT,
    FOREIGN KEY (boltId) REFERENCES Bolt(id) ON DELETE CASCADE,
    FOREIGN KEY (felszerelesId) REFERENCES Felszereles(id) ON DELETE CASCADE,
    PRIMARY KEY (boltId, felszerelesId)
);

-- Harcol tábla létrehozása
CREATE TABLE IF NOT EXISTS Harcol (
    harcId INT AUTO_INCREMENT PRIMARY KEY,
    jatekos1Id INT,
    szornyId INT,
    helyszinId INT,
    gyoztesId INT,
    harcIdeje DATETIME NOT NULL,
    FOREIGN KEY (jatekos1Id) REFERENCES Jatekos(id) ON DELETE CASCADE,
    FOREIGN KEY (szornyId) REFERENCES Szorny(id) ON DELETE CASCADE,
    FOREIGN KEY (helyszinId) REFERENCES Helyszin(id) ON DELETE CASCADE,
    FOREIGN KEY (gyoztesId) REFERENCES Jatekos(id) ON DELETE SET NULL
);

-- Párbaj tábla létrehozása
CREATE TABLE IF NOT EXISTS Parbaj (
    parbajId INT AUTO_INCREMENT PRIMARY KEY,
    jatekos1Id INT,
    jatekos2Id INT,
    helyszinId INT,
    gyoztesId INT,
    parbajIdeje DATETIME NOT NULL,
    FOREIGN KEY (jatekos1Id) REFERENCES Jatekos(id) ON DELETE CASCADE,
    FOREIGN KEY (jatekos2Id) REFERENCES Jatekos(id) ON DELETE CASCADE,
    FOREIGN KEY (helyszinId) REFERENCES Helyszin(id) ON DELETE CASCADE,
    FOREIGN KEY (gyoztesId) REFERENCES Jatekos(id) ON DELETE SET NULL
);


-- Trigger létrehozása a Kaszt táblához
DELIMITER //

CREATE TRIGGER kaszt_modositok
BEFORE INSERT ON Kaszt
FOR EACH ROW
BEGIN
    IF NEW.id = 1 THEN
        SET NEW.sebzesModosito = 50;
        SET NEW.eleteroModosito = 100;
    ELSEIF NEW.id = 2 THEN
        SET NEW.sebzesModosito = 75;
        SET NEW.eleteroModosito = 75;
    ELSEIF NEW.id = 3 THEN
        SET NEW.sebzesModosito = 50;
        SET NEW.eleteroModosito = 100;
    END IF;
END;
//
DELIMITER ;

-- Trigger létrehozása a Csoport táblához
DELIMITER //

CREATE TRIGGER noveles_tagokSzama
AFTER INSERT ON Jatekos
FOR EACH ROW
BEGIN
    DECLARE csapat_bonusz FLOAT;

    -- Ha az új játékos hozzá van rendelve egy csapathoz
    IF NEW.csoportId IS NOT NULL THEN
        -- Növeljük a csapat taglétszámát
        UPDATE Csoport
        SET tagokSzama = tagokSzama + 1
        WHERE id = NEW.csoportId;

        -- Kérjük le a csapat új taglétszámát
        SELECT tagokSzama INTO csapat_bonusz
        FROM Csoport
        WHERE id = NEW.csoportId;

        -- Frissítsük minden olyan játékos csapatbónuszát, aki ugyanahhoz a csoporthoz tartozik
        UPDATE Jatekos
        SET csapatBonusz = 1.0 + (csapat_bonusz - 1) * 0.1
        WHERE csoportId = NEW.csoportId;
    END IF;
END;
//
DELIMITER ;

-- Párbaj követelmények tigger: szint, parbajraHivhato, helyszin 
-- Párbaj követelmények és győzelem utáni tapasztalatpont trigger
DELIMITER //

CREATE TRIGGER check_parbaj_kovetelmenyek_and_gyozelem_tapasztalatpont_noveles
BEFORE INSERT ON Parbaj
FOR EACH ROW
BEGIN
    DECLARE jatekos1_level INT;
    DECLARE jatekos2_level INT;
    DECLARE parbajraHivhato_jatekos1 BOOLEAN;
    DECLARE parbajraHivhato_jatekos2 BOOLEAN;
    DECLARE helyszin1 INT;
    DECLARE helyszin2 INT;

    -- Kérjük le a két játékos szintjét és helyszínét
    SELECT szint, parbajraHivhato, helyszinId INTO jatekos1_level, parbajraHivhato_jatekos1, helyszin1
    FROM Jatekos
    WHERE id = NEW.jatekos1Id;

    SELECT szint, parbajraHivhato, helyszinId INTO jatekos2_level, parbajraHivhato_jatekos2, helyszin2
    FROM Jatekos
    WHERE id = NEW.jatekos2Id;

    -- Nézzük meg hogy mindkét játékos párbajrahívható -e
    IF parbajraHivhato_jatekos1 = TRUE AND parbajraHivhato_jatekos2 = TRUE THEN
        -- Nézzük meg hogy a szintjük különbsége nem nagyobb -e 5-nél és hogy azonos helyszínről jönnek-e
        IF ABS(jatekos1_level - jatekos2_level) > 5 OR helyszin1 != helyszin2 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'A Párbaj nem jöhet létre.';
        ELSE
            -- Győztes tapasztalatpont és arany növelése
            DECLARE vesztes_jatekos_szint INT;
            DECLARE gyoztes_jatekos_tapasztalatpont_noveles INT;
            DECLARE gyoztes_jatekos_arany_noveles INT;
            
            -- Kérjük le a vesztes játékos szintjét
            SELECT szint INTO vesztes_jatekos_szint
            FROM Jatekos
            WHERE id = NEW.gyoztesId;

            -- Számítsuk ki a győztes játékos tapasztalatpontjainak növelését
            SET gyoztes_jatekos_tapasztalatpont_noveles = vesztes_jatekos_szint * 100;

            -- Számítsuk ki a győztes játékos aranyának növelését
            SET gyoztes_jatekos_arany_noveles = vesztes_jatekos_szint * 10;

            -- Frissítsük a győztes játékos tapasztalatpontjait és aranyát
            UPDATE Jatekos
            SET tapasztalatPont = tapasztalatPont + gyoztes_jatekos_tapasztalatpont_noveles,
                arany = arany + gyoztes_jatekos_arany_noveles
            WHERE id = NEW.gyoztesId;
        END IF;
    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Mindkét játékos alkalmas a Párbajra';
    END IF;
END;
//
DELIMITER ;


DELIMITER //

CREATE TRIGGER check_helyszin_minimum_szint
BEFORE INSERT ON Jatekos
FOR EACH ROW
BEGIN
    DECLARE helyszin_min_szint INT;

    -- Kérjük le a helyszín minimális szintjét
    SELECT minimumSzint INTO helyszin_min_szint
    FROM Helyszin
    WHERE id = NEW.helyszinId;

    -- Ellenőrizzük, hogy a helyszín minimális szintje kisebb vagy egyenlő-e a játékos szintjével
    IF helyszin_min_szint > NEW.szint THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'A helyszín minimális szintje magasabb, mint a játékos szintje.';
    END IF;
END;
//
DELIMITER ;

-- Parbaj utáni tapasztalatpontkapás trigger
DELIMITER //


-- Harc trigger (szörny legyőzésekor)
DELIMITER //

CREATE TRIGGER check_harc_kovetelmeny_and_harc_szorny_legyozese
AFTER INSERT ON Harcol
FOR EACH ROW
BEGIN
    DECLARE tapasztalat_noveles INT;
    DECLARE arany_noveles INT;
    DECLARE jatekos_helyszin INT;
    DECLARE szorny_helyszin INT;
    
    -- Kérjük le a játékos és a szörny helyszínét
    SELECT helyszinId INTO jatekos_helyszin
    FROM Jatekos
    WHERE id = NEW.jatekos1Id;
    
    SELECT helyszinId INTO szorny_helyszin
    FROM Szorny
    WHERE id = NEW.szornyId;
    
    -- Ellenőrizzük, hogy a játékos és a szörny ugyanazon a helyen tartózkodik-e
    IF jatekos_helyszin = szorny_helyszin THEN
        -- Kérjük le a szörny adatait
        DECLARE szorny_adatok CURSOR FOR
        SELECT szint
        FROM Szorny
        WHERE id = NEW.szornyId;
        
        -- Számoljuk ki a tapasztalatpont és arany növelését
        OPEN szorny_adatok;
        FETCH szorny_adatok INTO tapasztalat_noveles;
        SET arany_noveles = tapasztalat_noveles * 5;
        CLOSE szorny_adatok;
        
        -- Frissítsük a játékos tapasztalatpontjait és aranyát
        UPDATE Jatekos
        SET tapasztalatPont = tapasztalatPont + (tapasztalat_noveles * 25),
            arany = arany + arany_noveles
        WHERE id = NEW.jatekos1Id;
    END IF;
END;
//
DELIMITER ;


-- Trigger létrehozása a Jatekos táblához, Jatekos szintje ne legyen nagyobb mint 100
DELIMITER //

CREATE TRIGGER check_jatekos_szint
BEFORE INSERT ON Jatekos
FOR EACH ROW
BEGIN
    IF NEW.szint > 100 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'A játékos szintje nem lehet nagyobb, mint 100.';
    END IF;
END;
//
DELIMITER ;

-- Trigger létrehozása a Jatekos táblához
DELIMITER //

CREATE TRIGGER update_jatekos_szint
AFTER INSERT ON Jatekos
FOR EACH ROW
BEGIN
    -- Számítsuk ki az új szintet a tapasztalatpont alapján
    DECLARE uj_szint INT;
    SET uj_szint = NEW.tapasztalatPont / 1000;

    -- Ellenőrizzük, hogy ne legyen nagyobb, mint 100
    IF uj_szint <= 100 THEN
        -- Frissítsük a játékos szintjét
        UPDATE Jatekos
        SET szint = uj_szint
        WHERE id = NEW.id;
    END IF;
END;
//
DELIMITER ;

-- Trigger létrehozása az új tapasztalatpont alapján
DELIMITER //

CREATE TRIGGER update_jatekos_szint_after_update
AFTER UPDATE ON Jatekos
FOR EACH ROW
BEGIN
    -- Számítsuk ki az új szintet a tapasztalatpont alapján
    DECLARE uj_szint INT;
    SET uj_szint = NEW.tapasztalatPont / 1000;

    -- Ellenőrizzük, hogy ne legyen nagyobb, mint 100
    IF uj_szint <= 100 THEN
        -- Frissítsük a játékos szintjét
        UPDATE Jatekos
        SET szint = uj_szint
        WHERE id = NEW.id;
    END IF;
END;
//
DELIMITER ;