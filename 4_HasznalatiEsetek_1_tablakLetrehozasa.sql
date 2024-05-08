USE Jatek;

-- 1. Válasszuk ki az összes kasztot és azok sebzés módosítóját.
SELECT nev, sebzesModosito FROM Kaszt;

-- 2. Frissítsük a Karakter tábla egy rekordját: MarciKarakter1 szintjét állítsuk 2-re.
UPDATE Karakter SET szint = 2 WHERE nev = 'MarciKarakter1';

-- 3. Töröljük az 'A kinemmondom bolt' nevű boltot a Bolt táblából.
DELETE FROM Bolt WHERE nev = 'A kinemmondom bolt';

-- 4. Töröljük az összes olyan csoportot, amelynek nincs legalább két tagja.
DELETE FROM Csoport WHERE id NOT IN (SELECT csoportId FROM Karakter GROUP BY csoportId HAVING COUNT(*) >= 2);

-- 5. Válasszuk ki az összes helyszínt, ahol a minimum szint 5 vagy annál kevesebb.
SELECT nev FROM Helyszin WHERE minimumSzint <= 5;

-- 6. Frissítsük a Szorny táblában a 'Ragadozó növények' nevű szörnyet úgy, hogy az aranyatDobhat értéke 60 legyen.
UPDATE Szorny SET aranyatDobhat = 60 WHERE nev = 'Ragadozó növények';

-- 7. Válasszuk ki az összes játékost, akik online vannak.
SELECT nev FROM Karakter WHERE onlineVan = TRUE;

-- 8. Töröljük az összes olyan felszerelést, amelynek minimumSzint értéke nagyobb, mint 5.
DELETE FROM Felszereles WHERE minimumSzint > 5;

-- 9. Válasszuk ki az összes olyan szörnyet, amelynek sebzése több mint 200.
SELECT nev FROM Szorny WHERE sebzes > 200;

-- 10. Frissítsük a KarakterFelszereles táblában az összes rekordot úgy, hogy a felveve értéke legyen TRUE.
UPDATE KarakterFelszereles SET felveve = TRUE WHERE felveve = FALSE;

-- 11. Válasszuk ki azokat a helyszíneket, ahol az átlagos szörnyek szintje meghaladja a 10-et.
SELECT h.nev
FROM Helyszin h
JOIN Szorny s ON h.id = s.helyszinId
GROUP BY h.nev
HAVING AVG(s.szint) > 10;

-- 12. Frissítsük a Szorny táblában az összes rekordot úgy, hogy az eletero értéke legyen 2000, ha a sebzes értéke legalább 300.
UPDATE Szorny SET eletero = 2000 WHERE sebzes >= 300;

-- 13. Válasszuk ki az összes játékost, akiknek a szintje legalább 5.
SELECT nev FROM Karakter WHERE szint >= 5;

-- 14. Frissítsük a Szorny táblában az összes rekordot úgy, hogy az aranyatDobhat értéke legyen 0, ha az eletero értéke kisebb mint 1000.
UPDATE Szorny SET aranyatDobhat = 0 WHERE eletero < 1000;

-- 15. Válasszuk ki az összes olyan helyszínt, amelyhez legalább 3 szörny tartozik.
SELECT nev FROM Helyszin WHERE id IN (SELECT helyszinId FROM Szorny GROUP BY helyszinId HAVING COUNT(*) >= 3);

-- 16. Válasszuk ki azokat a szervereket, amelyeken nincsenek olyan játékosok, akik online vannak.
SELECT s.nev
FROM Szerver s
LEFT JOIN Karakter k ON s.id = k.szerverId AND k.onlineVan = TRUE
WHERE k.id IS NULL;

-- 17. Válasszuk ki az összes játékost, akik legalább 1000 tapasztalati ponttal rendelkeznek.
SELECT nev FROM Karakter WHERE tapasztalatPont >= 1000;

-- 18. Válasszuk ki azokat a boltokat, ahol legalább egy olyan felszerelés van, amit egyetlen játékos sem vásárolt meg.
SELECT b.nev
FROM Bolt b
JOIN BoltFelszereles bf ON b.id = bf.boltId
LEFT JOIN KarakterFelszereles kf ON bf.felszerelesId = kf.felszerelesId
WHERE kf.felszerelesId IS NULL;

-- 19. Válasszuk ki az összes olyan szörnyet, amely legalább 100 tapasztalati pontot ad.
SELECT nev FROM Szorny WHERE tapasztalatPontotAd >= 100;

-- 20. Töröljük az összes olyan felszerelést, amelyet egyetlen játékos sem használ.
DELETE FROM Felszereles WHERE id NOT IN (SELECT DISTINCT felszerelesId FROM KarakterFelszereles);

-- 21. Válasszuk ki az összes olyan helyszínt, amelyhez tartozik legalább egy szörny.
SELECT nev FROM Helyszin WHERE id IN (SELECT helyszinId FROM Szorny);

-- 22. Frissítsük a Karakter táblában az összes rekordot úgy, hogy a tapasztalatPont értéke legyen 5000, ha a felhasználója 'petiAFelhasznalo'.
UPDATE Karakter SET tapasztalatPont = 5000 WHERE felhasznaloId = (SELECT id FROM Felhasznalo WHERE nev = 'petiAFelhasznalo');

-- 23. Válasszuk ki az összes olyan felszerelést, amelynek sebzése legalább 50, és eletere legalább 100.
SELECT nev FROM Felszereles WHERE sebzes >= 50 AND eletero >= 100;

-- 24. Töröljük az összes olyan játékost, akiknek a szintje kisebb vagy egyenlő 2-vel.
DELETE FROM Karakter WHERE szint <= 2;

-- 25. Válasszuk ki az összes olyan csoportot, amelynek tagjai között van legalább egy nő.
SELECT nev FROM Csoport WHERE id IN (SELECT DISTINCT csoportId FROM Karakter WHERE nem = 'N');

-- 26. Frissítsük a Karakter táblában az összes rekordot úgy, hogy az online értékük FALSE legyen.
UPDATE Karakter SET onlineVan = FALSE WHERE Karakter.id = 1;

-- 27. Válasszuk ki az összes olyan felszerelést, amelynek neve 'Varázskönyv' vagy 'Védelem pajzs'.
SELECT nev FROM Felszereles WHERE nev IN ('Varázskönyv', 'Védelem pajzs');

-- 28. Töröljük az összes olyan képességet, amelynek sebzése 100 vagy több.
DELETE FROM Kepesseg WHERE sebzes >= 100;

-- 29. Válasszuk ki az összes olyan játékost, akik legalább egyszer párbajra hívhatóak.
SELECT nev FROM Karakter WHERE parbajraHivhato = TRUE;

-- 30. Frissítsük a Szorny táblában az összes rekordot úgy, hogy az aranyatDobhat értéke legyen 0, ha az eletero értéke kisebb vagy egyenlő mint 500.
UPDATE Szorny SET aranyatDobhat = 50 WHERE eletero <= 500;

-- 31. Töröljük az összes olyan játékost, aki nem rendelkezik felszereléssel.
DELETE FROM Karakter WHERE id NOT IN (SELECT karakterId FROM KarakterFelszereles);

-- 32. Töröljük az összes olyan csapatot, amelynek nevében szerepel a 'Botrány'.
DELETE FROM Csoport WHERE nev LIKE '%Botrány%';

-- 33. Töröljük azokat a helyszíneket, amelyekhez egyetlen szörny sem tartozik, és azokhoz sem tartozik játékos.
DELETE FROM Helyszin
WHERE id NOT IN (SELECT helyszinId FROM Szorny)
AND id NOT IN (SELECT helyszinId FROM Karakter);

-- 34. Válasszuk ki azokat a csoportokat, amelynek legalább 3 tagja online van, és a csoport nevében szerepel a 'Kalandorok' szó.
SELECT c.nev 
FROM Csoport c
JOIN Karakter j ON c.id = j.csoportId
WHERE c.nev LIKE '%Kalandorok%'
GROUP BY c.id
HAVING COUNT(j.id) >= 3 AND SUM(j.onlineVan) >= 3;

-- 36. Frissítsük a Szorny táblában azokat a szörnyeket, amelyeknek a tapasztalatPontotAd értéke legalább 100, úgy hogy a sebzésüket növeljük 20%-kal.
UPDATE Szorny
SET sebzes = sebzes * 1.2
WHERE tapasztalatPontotAd >= 100;

-- 37. Frissítsük a Karakter táblában azokat a játékosokat, akiknek a felhasználója 'admin', úgy hogy a szintjüket növeljük 1-gyel.
UPDATE Karakter
SET szint = szint + 1
WHERE felhasznaloId = (SELECT id FROM Felhasznalo WHERE nev = 'MarciKarakter1');

-- 38. Válasszuk ki azokat a felszereléseket, amelyeket legalább egy játékos használ, és a felszerelés neve tartalmazza a 'Magic' szót.
SELECT nev
FROM Felszereles
WHERE id IN (SELECT DISTINCT felszerelesId FROM KarakterFelszereles)
AND nev LIKE '%Varázs%';

