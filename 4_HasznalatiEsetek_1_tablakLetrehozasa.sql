-- Adatbázis létrehozása, ha még nem létezik
CREATE DATABASE IF NOT EXISTS Jatek;
USE Jatek;

-- Helyszin tábla létrehozása
CREATE TABLE IF NOT EXISTS Helyszin (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nev VARCHAR(100) NOT NULL UNIQUE,
    minimumSzint INT DEFAULT 1
);

-- Felhasznalo tábla létrehozása
CREATE TABLE IF NOT EXISTS Felhasznalo (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(25) NOT NULL UNIQUE,
    nev VARCHAR(100) NOT NULL,
    jelszo VARCHAR(100) NOT NULL
);

-- Szerver tábla létrehozása
CREATE TABLE IF NOT EXISTS Szerver (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nev VARCHAR(100) NOT NULL
);

-- FelhasznaloSzerver tábla létrehozása
CREATE TABLE IF NOT EXISTS FelhasznaloSzerver (
    szerverId INT NOT NULL,
    felhasznaloId INT NOT NULL,
    regDatum DATETIME DEFAULT NOW(),
    FOREIGN KEY (szerverId) REFERENCES Szerver(id) ON DELETE CASCADE,
    FOREIGN KEY (felhasznaloId) REFERENCES Felhasznalo(id) ON DELETE CASCADE,
    PRIMARY KEY (szerverId, felhasznaloId)
);

-- Kaszt tábla létrehozása
CREATE TABLE IF NOT EXISTS Kaszt (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nev VARCHAR(100) NOT NULL UNIQUE,
    eleteroModosito INT NOT NULL,
    sebzesModosito INT NOT NULL
);

-- Kepesseg tábla létrehozása
CREATE TABLE IF NOT EXISTS Kepesseg (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nev VARCHAR(100) NOT NULL UNIQUE,
    sebzes INT NOT NULL,
    kasztId INT NOT NULL,
    minimumSzint INT DEFAULT 1,
    FOREIGN KEY (kasztId) REFERENCES Kaszt(id) ON DELETE CASCADE
);


-- Csoport tábla létrehozása
CREATE TABLE IF NOT EXISTS Csoport (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nev VARCHAR(100) NOT NULL UNIQUE
);

-- Bolt tábla létrehozása
CREATE TABLE IF NOT EXISTS Bolt (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nev VARCHAR(100) NOT NULL UNIQUE
);

-- Karakter tábla létrehozása
CREATE TABLE IF NOT EXISTS Karakter (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nev VARCHAR(50) NOT NULL UNIQUE,
    szerverId INT NOT NULL,
    felhasznaloId INT NOT NULL,
    nem CHAR(1) NOT NULL,
    kasztId INT NOT NULL,
    tapasztalatPont INT DEFAULT 0,
    szint INT DEFAULT 1 CHECK (szint <= 100),
    eletero INT DEFAULT 100,
    sebzes INT DEFAULT 100,
    parbajraHivhato BOOLEAN DEFAULT FALSE,
    csoportId INT DEFAULT NULL,
    arany INT DEFAULT 0,
    onlineVan BOOLEAN DEFAULT TRUE,
    helyszinId INT DEFAULT 1,
    csapatBonusz FLOAT DEFAULT 1.0,
    FOREIGN KEY (szerverId) REFERENCES Szerver(id) ON DELETE CASCADE,
    FOREIGN KEY (felhasznaloId) REFERENCES Felhasznalo(id) ON DELETE CASCADE,
    FOREIGN KEY (kasztId) REFERENCES Kaszt(id) ON DELETE CASCADE,
    FOREIGN KEY (csoportId) REFERENCES Csoport(id) ON DELETE CASCADE,
    FOREIGN KEY (helyszinId) REFERENCES Helyszin(id) ON DELETE CASCADE
);


-- Szorny tábla létrehozása
CREATE TABLE IF NOT EXISTS Szorny (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nev VARCHAR(100) NOT NULL UNIQUE,
    tapasztalatPontotAd INT NOT NULL,
    szint INT DEFAULT 1,
    eletero INT NOT NULL,
    sebzes INT NOT NULL,
    aranyatDobhat INT NOT NULL,
    helyszinId INT,
    FOREIGN KEY (helyszinId) REFERENCES Helyszin(id) ON DELETE CASCADE
);

-- Harcol tábla létrehozása
CREATE TABLE IF NOT EXISTS Harcol (
    harcId INT AUTO_INCREMENT PRIMARY KEY,
    karakter1Id INT,
    szornyId INT,
    helyszinId INT,
    gyoztesId INT,
    harcIdeje DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (karakter1Id) REFERENCES Karakter(id) ON DELETE CASCADE,
    FOREIGN KEY (szornyId) REFERENCES Szorny(id) ON DELETE CASCADE,
    FOREIGN KEY (helyszinId) REFERENCES Helyszin(id) ON DELETE CASCADE,
    FOREIGN KEY (gyoztesId) REFERENCES Karakter(id) ON DELETE SET NULL
);

-- Parbaj tábla létrehozása
CREATE TABLE IF NOT EXISTS Parbaj (
    parbajId INT AUTO_INCREMENT PRIMARY KEY,
    karakter1Id INT,
    karakter2Id INT,
    helyszinId INT,
    gyoztesId INT,
    parbajIdeje DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (karakter1Id) REFERENCES Karakter(id) ON DELETE CASCADE,
    FOREIGN KEY (karakter2Id) REFERENCES Karakter(id) ON DELETE CASCADE,
    FOREIGN KEY (helyszinId) REFERENCES Helyszin(id) ON DELETE CASCADE,
    FOREIGN KEY (gyoztesId) REFERENCES Karakter(id) ON DELETE SET NULL
);

-- FelszerelesKatMegn tábla létrehozása
CREATE TABLE IF NOT EXISTS FelszerelesKatMegn (
    katId INT AUTO_INCREMENT PRIMARY KEY,
    katNev VARCHAR(100) NOT NULL UNIQUE
);

-- Felszereles tábla létrehozása
CREATE TABLE IF NOT EXISTS Felszereles (
    id INT PRIMARY KEY,
    nev VARCHAR(100) NOT NULL UNIQUE,
    kasztId INT,
    sebzes INT NOT NULL,
    eletero INT NOT NULL,
    minimumSzint INT DEFAULT 1,
    kategoria INT NOT NULL CHECK (kategoria BETWEEN 1 AND 9),
    FOREIGN KEY (kasztId) REFERENCES Kaszt(id) ON DELETE CASCADE,
    FOREIGN KEY (kategoria) REFERENCES FelszerelesKatMegn(katId) ON DELETE CASCADE
);

-- KarakterFelszereles tábla létrehozása
CREATE TABLE IF NOT EXISTS KarakterFelszereles (
    karakterId INT,
    felszerelesId INT,
    felveve BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (karakterId) REFERENCES Karakter(id) ON DELETE CASCADE,
    FOREIGN KEY (felszerelesId) REFERENCES Felszereles(id) ON DELETE CASCADE,
    PRIMARY KEY (karakterId, felszerelesId)
);


-- BoltFelszereles tábla létrehozása
CREATE TABLE IF NOT EXISTS BoltFelszereles (
    boltId INT,
    felszerelesId INT,
    FOREIGN KEY (boltId) REFERENCES Bolt(id) ON DELETE CASCADE,
    FOREIGN KEY (felszerelesId) REFERENCES Felszereles(id) ON DELETE CASCADE,
    PRIMARY KEY (boltId, felszerelesId)
);

--  tábla létrehozása
CREATE TABLE IF NOT EXISTS SzornyFelszDobhat (
    szornyId INT NOT NULL,
    felszId INT NOT NULL,
    FOREIGN KEY (szornyId) REFERENCES Szorny(id) ON DELETE CASCADE,
    FOREIGN KEY (felszId) REFERENCES Felszereles(id) ON DELETE CASCADE,
    PRIMARY KEY (szornyId, felszId)
);

