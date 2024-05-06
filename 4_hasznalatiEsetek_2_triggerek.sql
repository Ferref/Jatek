USE Jatek;

-- TRIGGER: Karakterek száma nem lehet több mint 4 egy szerveren / felhasználó
DROP TRIGGER IF EXISTS ellenoriz_szerver_karakterek;

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

-- TRIGGER: Karakter szintje nem lehet nagyobb mint 100
DROP TRIGGER IF EXISTS check_Karakter_szint;

-- TRIGGER: Karakter szintje legyen a Karakter tapasztalatPontja / 1000
DROP TRIGGER IF EXISTS update_Karakter_szint;

-- TRIGGER: Karakter felveszi a felszerelést
DROP TRIGGER IF EXISTS felszereles_felvesz;

-- TRIGGER: Karakter leveszi a felszerelést
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






-- Triger létrehozása a FelhasznaloSzerver táblához
DELIMITER //
CREATE TRIGGER ellenoriz_szerver_karakterek
BEFORE INSERT ON FelhasznaloSzerver
FOR EACH ROW
BEGIN
    DECLARE karakterek_szama INT;
    -- Megszámoljuk, hogy a felhasználó hány karakterrel rendelkezik már ezen a szerveren
    SELECT COUNT(*)
    INTO karakterek_szama
    FROM FelhasznaloSzerver
    WHERE szerverId = NEW.szerverId AND felhasznaloId = NEW.felhasznaloId;
    
    -- Ha a karakterek száma meghaladja a 4-et, akkor hibaüzenetet dobunk
    IF karakterek_szama >= 4 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Egy felhasználó maximum 4 karakterrel lehet jelen egy szerveren!';
    END IF;
END//
DELIMITER ;


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

CREATE TRIGGER check_harc_kovetelmeny_and_szorny_legyozese
BEFORE INSERT ON Harcol
FOR EACH ROW
BEGIN
    DECLARE Karakter_potencial FLOAT;
    DECLARE szorny_potencial FLOAT;
    DECLARE Karakter_tamadas FLOAT;
    DECLARE szorny_tamadas FLOAT;
    DECLARE Karakter_kritikus_tamadas FLOAT;
    DECLARE szorny_kritikus_tamadas FLOAT;
    DECLARE gyoztesId INT;
    DECLARE szorny_felsz_id INT;
    DECLARE felszereles_id INT;
    DECLARE tapasztalatPontAd INT;
    DECLARE aranyAd INT;
    DECLARE csoportTagokSzama INT; -- új változó a csoporttagok számához

    -- Kérjük le a játékos harci potenciálját
    SELECT (szint * (eletero + sebzes) * (1 + RAND() * 0.4 - 0.2)) INTO Karakter_potencial
    FROM Karakter
    WHERE id = NEW.Karakter1Id;

    -- Kérjük le a szörny harci potenciálját
    SELECT (szint * (eletero + sebzes) * (1 + RAND() * 0.4 - 0.2)) INTO szorny_potencial
    FROM Szorny
    WHERE id = NEW.szornyId;

    -- Kiszámoljuk a támadásokat
    SET Karakter_tamadas = Karakter_potencial * (1 + RAND() * 0.4 - 0.2);
    SET szorny_tamadas = szorny_potencial * (1 + RAND() * 0.4 - 0.2);

    -- Kiszámoljuk a kritikus támadásokat
    SET Karakter_kritikus_tamadas = Karakter_tamadas * (1 + RAND() * 0.4 - 0.2);
    SET szorny_kritikus_tamadas = szorny_tamadas * (1 + RAND() * 0.4 - 0.2);

    -- Kiválasztjuk a győztest
    IF Karakter_kritikus_tamadas > szorny_kritikus_tamadas THEN
        SET gyoztesId = NEW.Karakter1Id;
    ELSE
        SET gyoztesId = NEW.szornyId;
    END IF;

    -- Ha a győztes a játékos, akkor növeljük a szörny tapasztalati pontjait, egyébként a játékosét
    IF gyoztesId = NEW.Karakter1Id THEN
        SET tapasztalatPontAd = NEW.tapasztalatPont * 0.8;
        SET aranyAd = NEW.arany * 0.8;
    ELSE
        SET tapasztalatPontAd = NEW.tapasztalatPont * 1.2;
        SET aranyAd = NEW.arany * 1.2;
    END IF;

    -- Beállítjuk a győztes játékost vagy a szörnyet
    SET szorny_felsz_id = NULL;
    SET felszereles_id = NULL;

    IF gyoztesId = NEW.Karakter1Id THEN
        SET szorny_felsz_id = NEW.szorny_felsz_id;
    ELSE
        SET felszereles_id = NEW.felszerelesId;
    END IF;

    -- Ellenőrizzük, hogy a játékos csoportja csak 4 tagból álljon
    SELECT COUNT(*) INTO csoportTagokSzama
    FROM Karakter
    WHERE csoportId = NEW.Karakter1Id;

    IF csoportTagokSzama > 4 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Egy csoportban nem lehet több mint 4 játékos.';
    END IF;

    -- Beillesztjük az új győzelmet a harci naplóba
    INSERT INTO Harci_Naplo (Karakter1Id, szornyId, gyoztesId, tapasztalatPont, arany, szorny_felsz_id, felszerelesId)
    VALUES (NEW.Karakter1Id, NEW.szornyId, gyoztesId, tapasztalatPontAd, aranyAd, szorny_felsz_id, felszereles_id);
END;
//
DELIMITER ;


-- TRIGGER létrehozása a Karakter táblához
DELIMITER //

CREATE TRIGGER check_helyszin_minimum_szint
BEFORE INSERT ON Karakter
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

-- TRIGGER létrehozása a Karakter táblához, Karakter szintje ne legyen nagyobb mint 100
DELIMITER //

CREATE TRIGGER check_Karakter_szint
BEFORE INSERT ON Karakter
FOR EACH ROW
BEGIN
    IF NEW.szint > 100 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'A játékos szintje nem lehet nagyobb, mint 100.';
    END IF;
END;
//
DELIMITER ;


-- TRIGGER létrehozása a Karakter táblához
DELIMITER //

CREATE TRIGGER update_Karakter_szint
BEFORE INSERT ON Karakter
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
BEFORE INSERT ON KarakterFelszereles
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
    UPDATE Karakter
    SET eletero = eletero + eletero_modosito,
        sebzes = sebzes + sebzes_modosito
    WHERE id = NEW.KarakterId;
END;
//
DELIMITER ;

-- TRIGGER létrehozása a Csoport táblához
DELIMITER //

CREATE TRIGGER check_csoport_tagok_szama
BEFORE INSERT ON Csoport
FOR EACH ROW
BEGIN
    DECLARE tagokSzama INT;

    -- Kérjük le a csoport aktuális tagjainak számát
    SELECT COUNT(*) INTO tagokSzama
    FROM Csoport_Tag
    WHERE csoportId = NEW.id;

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
BEFORE DELETE ON KarakterFelszereles
FOR EACH ROW
BEGIN
    -- Kivonjuk a karakter sebzését a fegyver sebzéséből
    DECLARE fegyver_kod INT;
    
    -- Kérjük le a felszereléshez tartozó fegyver kódját
    SELECT fegyverId INTO fegyver_kod
    FROM Felszereles
    WHERE id = OLD.felszerelesId;

    -- Frissítjük a játékos sebzését a felszerelés eltávolításával
    UPDATE Karakter
    SET sebzes = sebzes - (SELECT sebzes FROM Fegyver WHERE kod = fegyver_kod)
    WHERE id = OLD.KarakterId;
END;
//
DELIMITER ;

-- TRIGGER létrehozása a Karakter táblához
DELIMITER //

CREATE TRIGGER csoportbol_kilep
BEFORE DELETE ON Csoport
FOR EACH ROW
BEGIN
    DELETE FROM Csoport
    WHERE KarakterId = OLD.KarakterId AND csoportId = OLD.csoportId;
END;
//
DELIMITER ;

-- TRIGGER létrehozása a Karakter táblához
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


-- TRIGGER létrehozása a Karakter táblához
DELIMITER //

CREATE TRIGGER csoportba_belep
BEFORE INSERT ON Karakter
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

-- TRIGGER létrehozása a Karakter táblához
DELIMITER //

CREATE TRIGGER helyszin_valtoztatas
BEFORE UPDATE ON Karakter
FOR EACH ROW
BEGIN
    DECLARE Karakter_szint INT;
    DECLARE helyszin_min_szint INT;

    -- Kérjük le a játékos aktuális szintjét és a helyszín minimális szintjét
    SELECT NEW.szint INTO Karakter_szint;
    SELECT minimumSzint INTO helyszin_min_szint
    FROM Helyszin
    WHERE id = NEW.helyszinId;

    -- Ellenőrizzük, hogy a játékosnak megfelel-e a szintje a helyszínváltáshoz
    IF Karakter_szint < helyszin_min_szint THEN
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
    IF (SELECT felszerelesFelveve FROM KarakterFelszereles WHERE KarakterId = NEW.KarakterId AND felszerelesId = NEW.felszerelesId) = FALSE THEN
        -- Beszúrjuk az eladott felszerelést a BoltFelszereles táblába
        INSERT INTO BoltFelszereles (boltId, felszerelesId)
        VALUES (NEW.boltId, NEW.felszerelesId);
        
        -- A felszerelés árát a játékos kapja meg
        UPDATE Karakter
        SET arany = arany + (SELECT ar FROM Felszereles WHERE id = NEW.felszerelesId)
        WHERE id = NEW.KarakterId;
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
    DECLARE Karakter_szint INT;
    DECLARE felszereles_min_szint INT;
    DECLARE felsz_id INT;

    -- Kérjük le a játékos aktuális szintjét és a felszerelés minimális szintjét
    SELECT NEW.KarakterId INTO Karakter_szint;
    SELECT minimumSzint INTO felszereles_min_szint
    FROM Felszereles
    WHERE id = NEW.felszerelesId;

    -- Ellenőrizzük, hogy a játékos szintje megfelel-e a felszerelés vásárlásához
    IF Karakter_szint < felszereles_min_szint THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'A játékos szintje nem megfelelő a felszerelés vásárlásához.';
    END IF;
END;
//
DELIMITER ;

