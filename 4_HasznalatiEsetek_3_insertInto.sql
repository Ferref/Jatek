USE Jatek;

-- Példa adatok beillesztése a Felhasznalo táblába
INSERT INTO Felhasznalo (nev, jelszo) VALUES
('petiAFelhasznalo', 'jelszo1'),
('robiAFelhasznalo', 'jelszo2'),
('belaAFelhasznalo', 'jelszo3'),
('annaAFelhasznalo', 'jelszo4'),
('laciAFelhasznalo', 'jelszo5');

-- Példa adatok beillesztése a Szerver táblába
INSERT INTO Szerver (nev) VALUES
('Valuri'),
('Behemot'),
('Elvendur');

-- Példa adatok beillesztése a Kaszt táblába
INSERT INTO Kaszt (nev, eleteroModosito, sebzesModosito) VALUES
('Harcos', 100, 100),
('Ijjász', 100, 100),
('Mágus', 50, 150);

-- Példa adatok beillesztése a Helyszin táblába
INSERT INTO Helyszin (nev, minimumSzint) VALUES
('Erdei tisztás', 1),
('Mágikus torony', 3),
('Sötét barlang', 5);

-- Példa adatok beillesztése a Jatekos táblába
INSERT INTO Jatekos (nev, szerverId, felhasznaloId, nem, kasztId, helyszinId) VALUES
('PetiJatekos1', 1, 1, 'F', 1, 1),
('RobiJatekos1', 1, 2, 'N', 2, 1),
('BelaJatekos1', 2, 3, 'F', 1, 2),
('AnnaJatekos1', 2, 4, 'N', 3, 2),
('LaciJatekos1', 3, 5, 'F', 2, 3);

-- Példa adatok beillesztése a Kepesseg táblába
INSERT INTO Kepesseg (nev, sebzes, kasztId) VALUES
('Tűzgömb', 150, 2),
('Kardcsapás', 120, 1),
('Nyílvessző', 100, 3),
('Varázslat', 180, 3);

-- Példa adatok beillesztése a Felszereles táblába
INSERT INTO Felszereles (nev, kasztId, sebzes, eletero, minimumSzint) VALUES
('Védelem pajzs', 1, 50, 200, 1, 1),
('Varázskönyv', 2, 30, 80, 1, 1),
('Íj', 2, 40, 90, 1, 2),
('Lopakodó köpeny', 3, 20, 70, 1, 3);

-- Példa adatok beillesztése a Szorny táblába
INSERT INTO Szorny (nev, tapasztalatPontotAd, eletero, sebzes, aranyatDobhat, helyszinId) VALUES
('Goblin', 50, 500, 100, 20, 1),
('Sárkány', 200, 1500, 300, 100, 2),
('Harcos troll', 100, 800, 200, 50, 3),
('Vad orkok', 80, 600, 150, 30, 1),
('Varázsló kobold', 120, 700, 180, 40, 2);

-- Példa adatok beillesztése a Csoport táblába
INSERT INTO Csoport (nev) VALUES
('Kalandorok'),
('Csavargók'),
('IngyomBingyomCrew');

-- Példa adatok beillesztése a Bolt táblába
INSERT INTO Bolt (nev) VALUES
('Erdei kisbolt'),
('A mocsárosi bolt'),
('A kinemmondom bolt');

-- Példa adatok beillesztése a BoltFelszereles táblába
INSERT INTO BoltFelszereles (boltId, felszerelesId) VALUES
(1, 1),
(2, 2),
(3, 3),
(1, 4),
(2, 1);

-- Példa adatok beillesztése a Kepesseg táblába
INSERT INTO Kepesseg (nev, sebzes, kasztId) VALUES
('Tűzlövés', 140, 2),
('Védelmi varázslat', 0, 3),
('Tolvajlás', 0, 2);

-- Példa adatok beillesztése a Helyszin táblába
INSERT INTO Helyszin (nev, minimumSzint) VALUES
('Szellemes sír', 7),
('Tűzfaló barlang', 9);

-- Példa adatok beillesztése a Jatekos táblába
INSERT INTO Jatekos (nev, szerverId, felhasznaloId, nem, kasztId, helyszinId) VALUES
('MarciJatekos1', 1, 1, 'F', 1, 2),
('ViviJatekos1', 3, 2, 'N', 2, 1),
('BenceJatekos1', 3, 5, 'F', 3, 3);

-- Példa adatok beillesztése a Szorny táblába
INSERT INTO Szorny (nev, tapasztalatPontotAd, eletero, sebzes, aranyatDobhat, helyszinId) VALUES
('Farkas', 70, 600, 150, 40, 1),
('Szellemlovag', 250, 2000, 350, 150, 2),
('Ragadozó növény', 90, 700, 180, 45, 1);

-- Példa adatok beillesztése a Csoport táblába
INSERT INTO Csoport (nev) VALUES
('Bátorságosok'),
('Védelmezők'),
('Ködös brigád');

-- Példa adatok beillesztése a Bolt táblába
INSERT INTO Bolt (nev) VALUES
('A hősebbik bolt'),
('Aranyhomok boltja');

-- Példa adatok beillesztése a BoltFelszereles táblába
INSERT INTO BoltFelszereles (boltId, felszerelesId) VALUES
(1, 2),
(2, 4),
(1, 3);

-- Példa adatok beillesztése a Harcol táblába
INSERT INTO Harcol (jatekos1Id, szornyId, helyszinId, gyoztesId, harcIdeje)
VALUES
(1, 1, 1, 1, '2015-06-15 09:30:00'),
(2, 3, 2, 2, '2020-04-20 14:45:00'),
(3, 2, 3, 3, '2015-09-02 11:20:00'),
(4, 4, 1, 4, '2016-11-10 13:10:00'),
(5, 5, 2, 5, '2017-08-25 10:00:00');

-- Példa adatok beillesztése a Parbaj táblába
INSERT INTO Parbaj (jatekos1Id, jatekos2Id, helyszinId, gyoztesId, parbajIdeje)
VALUES
(1, 2, 1, 1, '2015-06-16 10:00:00'),
(3, 4, 2, 3, '2020-04-21 15:00:00'),
(2, 5, 3, 5, '2013-09-03 12:00:00'),
(4, 1, 1, 4, '2010-11-11 14:00:00'),
(5, 3, 2, 5, '2011-08-26 11:00:00');