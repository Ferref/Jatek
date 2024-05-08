-- Példa adatok beillesztése a Felhasznalo táblába
INSERT INTO Felhasznalo (email, nev, jelszo) VALUES
('petimail@email.com', 'petiAFelhasznalo', 'jelszo1'),
('robimail@email.com', 'robiAFelhasznalo', 'jelszo2'),
('belamail@email.com', 'belaAFelhasznalo', 'jelszo3'),
('annamail@email.com', 'annaAFelhasznalo', 'jelszo4'),
('lacimail@email.com', 'laciAFelhasznalo', 'jelszo5');

-- Példa adatok beillesztése a Kaszt táblába
INSERT INTO Kaszt (nev, eleteroModosito, sebzesModosito) VALUES
('Harcos', 150, 50),
('Ijjász', 100, 100),
('Mágus', 50, 150);

-- Példa adatok beillesztése a Szerver táblába
INSERT INTO Szerver (nev) VALUES
('Valuri'),
('Behemot'),
('Elvendur');

-- Példa adatok beillesztése a Helyszin táblába
INSERT INTO Helyszin (nev, minimumSzint) VALUES
('Erdei tisztás', 1),
('Mágikus torony', 3),
('Sötét barlang', 5),
('Bűvös mocsár', 1),
('Rettegés hídja', 3),
('Méregkeverúk Laktanyája', 5);

-- Példa adatok beillesztése a Karakter táblába
INSERT INTO Karakter (nev, szerverId, felhasznaloId, nem, kasztId, helyszinId) VALUES
('PetiKarakter1', 1, 1, 'F', 1, 1),
('RobiKarakter1', 1, 2, 'F', 2, 1),
('BelaKarakter1', 2, 3, 'F', 1, 2),
('AnnaKarakter1', 2, 4, 'N', 3, 1),
('LaciKarakter1', 3, 5, 'F', 2, 1),
('PetiKarakter2', 1, 1, 'F', 1, 1),
('RobiKarakter2', 3, 2, 'F', 2, 1),
('BelaKarakter2', 3, 3, 'F', 3, 1);

-- Példa adatok beillesztése a Kepesseg táblába
INSERT INTO Kepesseg (nev, sebzes, kasztId, minimumSzint) VALUES
('Tűzgömb', 150, 3, 1),
('Kardcsapás', 120, 1, 1),
('Nyílvessző', 100, 2, 1),
('Varázslat', 180, 3, 1),
('Tűzlövés', 140, 3, 1),
('Védelmi varázslat', 0, 3, 1),
('Tolvajlás', 0, 2, 1),
('Pörölycsapás', 200, 1, 1);


-- Példa adatok beillesztése a Felszereles táblába
INSERT INTO Felszereles (nev, kasztId, sebzes, eletero, minimumSzint) VALUES
('Védelem pajzs', 1, 50, 200, 1),
('Varázskönyv', 3, 30, 80, 1),
('Íj', 2, 40, 90, 1),
('Lopakodó köpeny', 3, 20, 70, 1);

-- Példa adatok beillesztése a Szorny táblába
INSERT INTO Szorny (nev, tapasztalatPontotAd, eletero, sebzes, aranyatDobhat, helyszinId) VALUES
('Goblin', 50, 500, 100, 20, 1),
('Sárkány', 200, 1500, 300, 100, 2),
('Harcos troll', 100, 800, 200, 50, 3),
('Vad ork', 80, 600, 150, 30, 1),
('Varázsló kobold', 120, 700, 180, 40, 2);

-- Példa adatok beillesztése a Csoport táblába
INSERT INTO Csoport (nev) VALUES
('Kalandorok'),
('Csavargók'),
('IngyomBingyomCrew'),
('Bátorságosok'),
('Védelmezők'),
('Ködös brigád');

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

-- Példa adatok beillesztése a Szorny táblába
INSERT INTO Szorny (nev, tapasztalatPontotAd, eletero, sebzes, aranyatDobhat, helyszinId) VALUES
('Farkas', 70, 600, 150, 40, 1),
('Szellemlovag', 250, 2000, 350, 150, 2),
('Ragadozó növény', 90, 700, 180, 45, 1),
('Hatalmas Rák', 90, 800, 140, 45, 3),
('Hatalmas Rák', 90, 500, 180, 45, 1);

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
INSERT INTO Harcol (karakter1Id, szornyId, helyszinId, gyoztesId)
VALUES
(1, 1, 1, 1),
(2, 3, 2, 2),
(3, 2, 3, 3),
(4, 4, 1, 4),
(5, 5, 2, 5);

-- Példa adatok beillesztése a Parbaj táblába
INSERT INTO Parbaj (karakter1Id, karakter2Id, helyszinId, gyoztesId)
VALUES
(1, 2, 1, 1),
(3, 4, 2, 3),
(2, 5, 3, 5),
(4, 1, 1, 4),
(5, 3, 2, 5);
