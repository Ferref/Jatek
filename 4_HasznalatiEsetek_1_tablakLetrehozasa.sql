-- Adatbázis létrehozása ha nem létezik
CREATE DATABASE IF NOT EXISTS Jatek;
USE Jatek;

-- TRIGGER: Csoportagok száma nem lehet több mint 4
DROP TRIGGER IF EXISTS check_csoport_tagok_szama;

-- TRIGGER: Kaszt életerő, sebzés módosítója
DROP TRIGGER IF EXISTS kaszt_modositok;

-- TRIGGER: Be tud a lépni a játékos a helyszínre
DROP TRIGGER IF EXISTS check_helyszin_minimum_szint;

-- TRIGGER: Párbaj
DROP TRIGGER IF EXISTS check_parbaj_kovetelmenyek_and_gyozelem_tapasztalatpont_noveles;

-- TRIGGER: Harc szörny ellen
DROP TRIGGER IF EXISTS check_harc_kovetelmeny_and_szorny_legyozese;

-- TRIGGER: Jatekos szintje nem lehet nagyobb mint 100
DROP TRIGGER IF EXISTS check_jatekos_szint;

-- TRIGGER: Jatekos szintje legyen a jatekos tapasztalatPontja / 1000
DROP TRIGGER IF EXISTS update_jatekos_szint;

-- TRIGGER: Jatekos felveszi a felszerelést
DROP TRIGGER IF EXISTS felszereles_felvesz;

-- TRIGGER: Jatekos leveszi a felszerelést
DROP TRIGGER IF EXISTS felszereles_levesz;

-- TRIGGER: Játekos kilép a csoportjából
DROP TRIGGER IF EXISTS csoportbol_kilep;

-- TRIGGER: Játekos belép egy csoportba
DROP TRIGGER IF EXISTS csoportba_belep;

-- TRIGGER: Játekos helyszint akar változtatni
DROP TRIGGER IF EXISTS helyszin_valtoztatas;

-- TRIGGER: Játekos felszerelést elad
DROP TRIGGER IF EXISTS felszereles_elad;

-- TRIGGER: Játekos felszerelést vásárol
DROP TRIGGER IF EXISTS felszereles_vasarol;


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
    nev VARCHAR(100) NOT NULL
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
    szint INT DEFAULT 1 CHECK (szint <= 100),
    eletero INT DEFAULT 100,
    sebzes INT DEFAULT 10,
    parbajraHivhato BOOLEAN DEFAULT FALSE,
    csoportId INT DEFAULT NULL,
    arany INT DEFAULT 0,
    online BOOLEAN DEFAULT TRUE,
    helyszinId INT,
    csapatBonusz FLOAT DEFAULT 1.0,
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
    kategoriaId INT NOT NULL CHECK (kategoriaId BETWEEN 1 AND 9),
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

-- FelszerelesKatMegn tábla létrehozása
CREATE TABLE IF NOT EXISTS FelszerelesKatMegn (
    katId INT AUTO_INCREMENT PRIMARY KEY,
    katNev VARCHAR(100) NOT NULL
);

-- SzornyFelszDobhat tábla létrehozása
CREATE TABLE IF NOT EXISTS SzornyFelszDobhat (
    szornyId INT,
    felszId INT,
    FOREIGN KEY (szornyId) REFERENCES Szorny(id) ON DELETE CASCADE,
    FOREIGN KEY (felszId) REFERENCES Felszereles(id) ON DELETE CASCADE,
    PRIMARY KEY (szornyId, felszId)
);



-- TRIGGER létrehozása a Kaszt táblához
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

-- TRIGGER létrehozása a Harcol táblához
DELIMITER //

/*
CREATE TRIGGER check_harc_kovetelmeny_and_szorny_legyozese
BEFORE INSERT ON Harcol
FOR EACH ROW
BEGIN
    DECLARE jatekos_potencial FLOAT;
    DECLARE szorny_potencial FLOAT;
    DECLARE jatekos_tamadas FLOAT;
    DECLARE szorny_tamadas FLOAT;
    DECLARE jatekos_kritikus_tamadas FLOAT;
    DECLARE szorny_kritikus_tamadas FLOAT;
    DECLARE gyoztesId INT;
    DECLARE szorny_felsz_id INT;
    DECLARE felszereles_id INT;
    DECLARE tapasztalatPontAd INT;
    DECLARE aranyAd INT;
    DECLARE csoportTagokSzama INT; -- új változó a csoporttagok számához

    -- Kérjük le a játékos harci potenciálját
    SELECT (szint * (eletero + sebzes) * (1 + RAND() * 0.4 - 0.2)) INTO jatekos_potencial
    FROM Jatekos
    WHERE id = NEW.jatekos1Id;

    -- Kérjük le a szörny harci potenciálját
    SELECT (szint * (eletero + sebzes) * (1 + RAND() * 0.4 - 0.2)) INTO szorny_potencial
    FROM Szorny
    WHERE id = NEW.szornyId;

    -- Kiszámoljuk a támadásokat
    SET jatekos_tamadas = jatekos_potencial * (1 + RAND() * 0.4 - 0.2);
    SET szorny_tamadas = szorny_potencial * (1 + RAND() * 0.4 - 0.2);

    -- Kiszámoljuk a kritikus támadásokat
    SET jatekos_kritikus_tamadas = jatekos_tamadas * (1 + RAND() * 0.4 - 0.2);
    SET szorny_kritikus_tamadas = szorny_tamadas * (1 + RAND() * 0.4 - 0.2);

    -- Kiválasztjuk a győztest
    IF jatekos_kritikus_tamadas > szorny_kritikus_tamadas THEN
        SET gyoztesId = NEW.jatekos1Id;
    ELSE
        SET gyoztesId = NEW.szornyId;
    END IF;

    -- Ha a győztes a játékos, akkor növeljük a szörny tapasztalati pontjait, egyébként a játékosét
    IF gyoztesId = NEW.jatekos1Id THEN
        SET tapasztalatPontAd = NEW.tapasztalatPont * 0.8;
        SET aranyAd = NEW.arany * 0.8;
    ELSE
        SET tapasztalatPontAd = NEW.tapasztalatPont * 1.2;
        SET aranyAd = NEW.arany * 1.2;
    END IF;

    -- Beállítjuk a győztes játékost vagy a szörnyet
    SET szorny_felsz_id = NULL;
    SET felszereles_id = NULL;

    IF gyoztesId = NEW.jatekos1Id THEN
        SET szorny_felsz_id = NEW.szorny_felsz_id;
    ELSE
        SET felszereles_id = NEW.felszerelesId;
    END IF;

    -- Ellenőrizzük, hogy a játékos csoportja csak 4 tagból álljon
    SELECT COUNT(*) INTO csoportTagokSzama
    FROM Jatekos
    WHERE csoportId = NEW.jatekos1Id;

    IF csoportTagokSzama > 4 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Egy csoportban nem lehet több mint 4 játékos.';
    END IF;

    -- Beillesztjük az új győzelmet a harci naplóba
    INSERT INTO Harci_Naplo (jatekos1Id, szornyId, gyoztesId, tapasztalatPont, arany, szorny_felsz_id, felszerelesId)
    VALUES (NEW.jatekos1Id, NEW.szornyId, gyoztesId, tapasztalatPontAd, aranyAd, szorny_felsz_id, felszereles_id);
END;
//
DELIMITER ;

*/


-- TRIGGER létrehozása a Jatekos táblához
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

-- TRIGGER létrehozása a Jatekos táblához, Jatekos szintje ne legyen nagyobb mint 100
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


-- TRIGGER létrehozása a Jatekos táblához
DELIMITER //

CREATE TRIGGER update_jatekos_szint
BEFORE INSERT ON Jatekos
FOR EACH ROW
BEGIN
    DECLARE uj_szint INT;
    
    SET uj_szint = FLOOR(1 + LOG2(NEW.tapasztalatPont));
    
    IF NEW.szint < uj_szint THEN
        SET NEW.szint = uj_szint;
    END IF;
END;
//
DELIMITER ;

-- Felszereles felvesz TRIGGER
DELIMITER //

CREATE TRIGGER felszereles_felvesz
BEFORE INSERT ON JatekosFelszereles
FOR EACH ROW
BEGIN
    -- Ellenőrizzük, hogy a felszerelés felvételekor a játékos eleterőjére és sebzésére hat-e
    DECLARE eletero_modosito INT;
    DECLARE sebzes_modosito INT;
    
    -- Kérjük le a felszerelés tulajdonságait
    SELECT eletero, sebzes INTO eletero_modosito, sebzes_modosito
    FROM Felszereles
    WHERE id = NEW.felszerelesId;
    
    -- Frissítjük a játékos eleterőjét és sebzését a felszerelés tulajdonságai alapján
    UPDATE Jatekos
    SET eletero = eletero + eletero_modosito,
        sebzes = sebzes + sebzes_modosito
    WHERE id = NEW.jatekosId;
END;
//
DELIMITER ;

-- TRIGGER létrehozása a Csoport táblához
DELIMITER //

CREATE TRIGGER check_csoport_tagok_szama
BEFORE INSERT ON Jatekos
FOR EACH ROW
BEGIN
    DECLARE tagokSzama INT;

    -- Kérjük le a csoport aktuális tagjainak számát
    SELECT COUNT(*) INTO tagokSzama
    FROM Jatekos
    WHERE csoportId = NEW.csoportId;

    -- Ellenőrizzük, hogy a csoportba beszúrandó új játékos után a csoportban maradó játékosok száma ne lépje túl a 4-et
    IF tagokSzama >= 4 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Egy csoportban nem lehet több mint 4 játékos.';
    END IF;
END;
//
DELIMITER ;


-- Felszereles levesz TRIGGER
DELIMITER //

CREATE TRIGGER felszereles_levesz
BEFORE DELETE ON JatekosFelszereles
FOR EACH ROW
BEGIN
    -- Kivonjuk a karakter sebzését a fegyver sebzéséből
    DECLARE fegyver_kod INT;
    
    -- Kérjük le a felszereléshez tartozó fegyver kódját
    SELECT fegyverId INTO fegyver_kod
    FROM Felszereles
    WHERE id = OLD.felszerelesId;

    -- Frissítjük a játékos sebzését a felszerelés eltávolításával
    UPDATE Jatekos
    SET sebzes = sebzes - (SELECT sebzes FROM Fegyver WHERE kod = fegyver_kod)
    WHERE id = OLD.jatekosId;
END;
//
DELIMITER ;

-- TRIGGER létrehozása a Jatekos táblához
DELIMITER //

CREATE TRIGGER csoportbol_kilep
BEFORE DELETE ON Csoport
FOR EACH ROW
BEGIN
    DELETE FROM Csoport
    WHERE jatekosId = OLD.jatekosId AND csoportId = OLD.csoportId;
END;
//
DELIMITER ;

-- TRIGGER létrehozása a Jatekos táblához
CREATE TRIGGER csoportba_belep
BEFORE INSERT ON Csoport_Tag
FOR EACH ROW
BEGIN
    DECLARE tagokSzama INT;
    
    -- Növeljük a csoport tagjainak számát
    SELECT COUNT(*) INTO tagokSzama
    FROM Csoport_Tag
    WHERE csoportId = NEW.csoportId;

    UPDATE Csoport
    SET tagokSzama = tagokSzama
    WHERE id = NEW.csoportId;
END;
//
DELIMITER ;


-- TRIGGER létrehozása a Jatekos táblához
DELIMITER //

CREATE TRIGGER csoportba_belep
BEFORE INSERT ON Jatekos
FOR EACH ROW
BEGIN
    -- Ellenőrizzük, hogy az újonnan beszúrt játékosnak van-e csoportja
    IF NEW.csoportId IS NOT NULL THEN
        -- Frissítjük a csoport tagjainak számát
        UPDATE Csoport
        SET tagokSzama = tagokSzama + 1
        WHERE id = NEW.csoportId;
    END IF;
END;
//
DELIMITER ;

-- TRIGGER létrehozása a Jatekos táblához
DELIMITER //

CREATE TRIGGER helyszin_valtoztatas
BEFORE UPDATE ON Jatekos
FOR EACH ROW
BEGIN
    DECLARE jatekos_szint INT;
    DECLARE helyszin_min_szint INT;

    -- Kérjük le a játékos aktuális szintjét és a helyszín minimális szintjét
    SELECT NEW.szint INTO jatekos_szint;
    SELECT minimumSzint INTO helyszin_min_szint
    FROM Helyszin
    WHERE id = NEW.helyszinId;

    -- Ellenőrizzük, hogy a játékosnak megfelel-e a szintje a helyszínváltáshoz
    IF jatekos_szint < helyszin_min_szint THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Nincs meg a megfelelő szint a helyszínváltáshoz.';
    END IF;
END;
//
DELIMITER ;


-- TRIGGER létrehozása a BoltFelszereles táblához
DELIMITER //

CREATE TRIGGER felszereles_elad
BEFORE INSERT ON BoltFelszereles
FOR EACH ROW
BEGIN
    -- Ellenőrizzük, hogy a felszerelés eladható-e
    IF (SELECT felszerelesFelveve FROM JatekosFelszereles WHERE jatekosId = NEW.jatekosId AND felszerelesId = NEW.felszerelesId) = FALSE THEN
        -- Beszúrjuk az eladott felszerelést a BoltFelszereles táblába
        INSERT INTO BoltFelszereles (boltId, felszerelesId)
        VALUES (NEW.boltId, NEW.felszerelesId);
        
        -- A felszerelés árát a játékos kapja meg
        UPDATE Jatekos
        SET arany = arany + (SELECT ar FROM Felszereles WHERE id = NEW.felszerelesId)
        WHERE id = NEW.jatekosId;
    END IF;
END;
//
DELIMITER ;

-- TRIGGER létrehozása a BoltFelszereles táblához
DELIMITER //

CREATE TRIGGER felszereles_vasarol
BEFORE INSERT ON BoltFelszereles
FOR EACH ROW
BEGIN
    -- Ellenőrizzük, hogy a játékosnak megfelelő-e a szintje a felszerelés vásárlásához
    DECLARE jatekos_szint INT;
    DECLARE felszereles_min_szint INT;
    DECLARE felsz_id INT;

    -- Kérjük le a játékos aktuális szintjét és a felszerelés minimális szintjét
    SELECT NEW.jatekosId INTO jatekos_szint;
    SELECT minimumSzint INTO felszereles_min_szint
    FROM Felszereles
    WHERE id = NEW.felszerelesId;

    -- Ellenőrizzük, hogy a játékos szintje megfelel-e a felszerelés vásárlásához
    IF jatekos_szint < felszereles_min_szint THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'A játékos szintje nem megfelelő a felszerelés vásárlásához.';
    END IF;
END;
//
DELIMITER ;







