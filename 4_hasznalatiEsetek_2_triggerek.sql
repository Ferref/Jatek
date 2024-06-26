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
DROP TRIGGER IF EXISTS elad_felszerelest;

-- TRIGGER: Játekos felszerelést vásárol
DROP TRIGGER IF EXISTS vasarol_felszerelest;


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

-- TRIGGER létrehozása a Szörnyekkel való harchoz (Harcol tábla)
DELIMITER //

CREATE TRIGGER check_harc_kovetelmeny_and_szorny_legyozese
BEFORE INSERT ON Harcol
FOR EACH ROW
BEGIN
    DECLARE karakter_szint INT;
    DECLARE karakter_sebzes INT;
    DECLARE szorny_szint INT;
    DECLARE szorny_sebzes INT;
    DECLARE tapasztalatPontotAd INT;
    
    -- Kivonjuk a karakter és a szörny tulajdonságait
    SELECT k.szint, k.sebzes, s.szint, s.sebzes, s.tapasztalatPontotAd INTO karakter_szint, karakter_sebzes, szorny_szint, szorny_sebzes, tapasztalatPontotAd
    FROM Karakter k
    JOIN Szorny s ON NEW.karakter1Id = k.id AND NEW.szornyId = s.id;
    
    -- Ellenőrizzük a harc követelményeit
    IF karakter_szint >= szorny_szint AND karakter_sebzes >= szorny_sebzes THEN
        -- Meghatározzuk a győztest
        IF karakter_szint + karakter_sebzes >= szorny_szint + szorny_sebzes THEN
            SET NEW.gyoztesId = NEW.karakter1Id;
        ELSE
            SET NEW.gyoztesId = NEW.szornyId;
        END IF;
        
        -- Ha a karakter a győztes
        IF NEW.gyoztesId = NEW.karakter1Id THEN
            -- Számítjuk a kapott tapasztalatpontot
            SET @tapasztalatPont := tapasztalatPontotAd;
            
            -- Ha a karakter csoportban van
            IF EXISTS (SELECT 1 FROM Karakter WHERE id = NEW.karakter1Id AND csoportId IS NOT NULL) THEN
                -- Számítjuk a csoporttagok számát
                SET @csoport_tagok_szama := (SELECT COUNT(*) FROM Karakter WHERE csoportId = (SELECT csoportId FROM Karakter WHERE id = NEW.karakter1Id));
                
                -- Számítjuk a kapott tapasztalatpontot csoporttagok száma alapján
                SET @tapasztalatPont := @tapasztalatPont + (tapasztalatPontotAd * @csoport_tagok_szama / 10);
            END IF;
            
            -- Frissítjük a győztes karakter tapasztalatpontjait
            UPDATE Karakter
            SET tapasztalatPont = tapasztalatPont + @tapasztalatPont
            WHERE id = NEW.karakter1Id;
        END IF;
    END IF;
END//

DELIMITER ;

DELIMITER //
-- TRIGGER létrehozása csoportból való kilépéshez
CREATE TRIGGER csoportbol_kilep
AFTER DELETE ON Csoport
FOR EACH ROW
BEGIN
    UPDATE Karakter
    SET csoportId = NULL
    WHERE csoportId = OLD.id;
END//

DELIMITER ;

-- TRIGGER létrehozása csoportba való belépéshez, ha a játékos még nem tagja egy csoportnak sem
DELIMITER //

CREATE TRIGGER csoportba_belep
AFTER INSERT ON Karakter
FOR EACH ROW
BEGIN
    IF NEW.csoportId IS NOT NULL THEN
        UPDATE Karakter
        SET csoportId = NEW.csoportId
        WHERE id = NEW.id;
    END IF;
END//

DELIMITER ;

DELIMITER //

-- TRIGGER létrehozása a felszerelés vásárlásához
CREATE TRIGGER vasarol_felszerelest
AFTER INSERT ON KarakterFelszereles
FOR EACH ROW
BEGIN
    DECLARE felszereles_ar INT;
    
    -- Kivesszük a felszerelés árát
    SELECT arany INTO @felszereles_ar
    FROM Felszereles
    WHERE id = NEW.felszerelesId;
    
    -- Levonjuk a játékos aranyából a felszerelés árát
    UPDATE Karakter
    SET arany = arany - felszereles_ar
    WHERE id = NEW.karakterId;
END//

DELIMITER ;

-- TRIGGER létrehozása a felszerelés eladásához
DELIMITER //

CREATE TRIGGER elad_felszerelest
AFTER INSERT ON BoltFelszereles
FOR EACH ROW
BEGIN
    DECLARE felszereles_ar INT;
    
    -- Kivesszük a felszerelés árát
    SELECT arany INTO felszereles_ar
    FROM Felszereles
    WHERE id = NEW.felszerelesId;
    
    -- Hozzáadjuk a játékos aranyához a felszerelés árát
    UPDATE Karakter
    SET arany = arany + felszereles_ar
    WHERE id = NEW.boltId;
END//

DELIMITER ;






