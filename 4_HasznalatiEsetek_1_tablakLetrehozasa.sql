-- Adatbázis létrehozása ha nem létezik
CREATE DATABASE IF NOT EXISTS Jatek;
USE Jatek;

-- kaszt_modosító trigger eldobása ha már létezik
DROP TRIGGER IF EXISTS kaszt_modositok;

-- Csoport tagokSzama trigger eldobása ha már létezik
DROP TIGGER IF EXISTS noveles_tagokSzama;

-- Parbaj ellenörző-trigger eldobása ha már létezik (javitani kell hogy azaonos helyen is legyenek)
DROP TIGGER IF EXISTS ellenoriz_parbaj_kovetelmenyek;

-- Kellenek meg
-- Helyszin Trigger hogy be tud e lepni
-- Parbaj tigger 2 amivel tp-t, aranyat kapunk
-- Harc trigger (ha azonos helyen vannak)
-- szintNoveloTrigger
-- vasarlas trigger
-- felszereles trigger
-- bolt elad, vasarol trigger

-- 
DROP TRIGGER IF EXISTS check_parbaj_requirements

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
    IF NEW.csoportId IS NOT NULL THEN
        UPDATE Csoport
        SET tagokSzama = tagokSzama + 1
        WHERE id = NEW.csoportId;
    END IF;
END;
//
DELIMITER ;

-- Trigger létrehozása a Péárbaj táblához
-- Create trigger if not exists
DROP TRIGGER IF EXISTS check_parbaj_requirements;

DELIMITER //

CREATE TRIGGER ellenoriz_parbaj_kovetelmenyek
BEFORE INSERT ON Parbaj
FOR EACH ROW
BEGIN
    DECLARE jatekos1_level INT;
    DECLARE jatekos2_level INT;
    DECLARE parbajraHivhato_jatekos1 BOOLEAN;
    DECLARE parbajraHivhato_jatekos2 BOOLEAN;

    -- Kérjük le a két játékos szintjét
    SELECT szint, parbajraHivhato INTO jatekos1_level, parbajraHivhato_jatekos1
    FROM Jatekos
    WHERE id = NEW.jatekos1Id;

    SELECT szint, parbajraHivhato INTO jatekos2_level, parbajraHivhato_jatekos2
    FROM Jatekos
    WHERE id = NEW.jatekos2Id;

    -- Nézzük meg hogy mindkét játékos párbajrahívható -e
    IF parbajraHivhato_jatekos1 = TRUE AND parbajraHivhato_jatekos2 = TRUE THEN
        -- Nézzük meg hogy a szintjük különbsége nem nagyobb -e 5-nél
        IF ABS(jatekos1_level - jatekos2_level) > 5 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'A Párbaj nem jöhet létre.';
        END IF;
    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Mindkét játékos alkalmas a Párbajra';
    END IF;
END;
//
DELIMITER ;


