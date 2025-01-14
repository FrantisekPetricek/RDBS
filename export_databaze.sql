-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Počítač: mariadb-container
-- Vytvořeno: Úte 14. led 2025, 18:55
-- Verze serveru: 11.6.2-MariaDB-ubu2404
-- Verze PHP: 8.2.8

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Databáze: `pc_sestavy`
--
CREATE DATABASE IF NOT EXISTS `pc_sestavy` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `pc_sestavy`;

DELIMITER $$
--
-- Procedury
--
DROP PROCEDURE IF EXISTS `GetSestavaById`$$
CREATE DEFINER=`root`@`%` PROCEDURE `GetSestavaById` (IN `id_ses` INT)   BEGIN
    SELECT * FROM pc_sestavy WHERE pc_sestavy.id_ses = id_ses;
END$$

DROP PROCEDURE IF EXISTS `SlevaRandom`$$
CREATE DEFINER=`root`@`%` PROCEDURE `SlevaRandom` ()   BEGIN
    DECLARE procento_sleva TINYINT;
    DECLARE id INT;
    DECLARE nazev VARCHAR(50);
    DECLARE cena DECIMAL(10,2);
    DECLARE sleva DECIMAL(10,2);
    DECLARE konec BOOLEAN DEFAULT FALSE;
    DECLARE chybicka INT DEFAULT ROUND(RAND());

 
    DECLARE cur_sleva CURSOR FOR SELECT pc.id_ses, pc.nazev, pc.cena FROM pc_sestavy AS pc;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION 
    BEGIN
        ROLLBACK;
        
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'chybicka se bloudila';
    END;
    
    DECLARE EXIT HANDLER FOR NOT FOUND 
        SET konec = TRUE;

    START TRANSACTION;

    DROP TABLE IF EXISTS SlevaRnd;
    CREATE TABLE IF NOT EXISTS SlevaRnd (
        id_ses INT PRIMARY KEY,
        nazev VARCHAR(50),
        cena DECIMAL(10,2),
        procento_sleva TINYINT,
        sleva DECIMAL(10,2),
        cena_sleva DECIMAL(10,2)
    );

    OPEN cur_sleva;

    WHILE NOT konec DO
        FETCH cur_sleva INTO id, nazev, cena;
        
            SET procento_sleva = FLOOR(RAND() * 5 + 1) * 5;
            SET sleva = ROUND(cena / 100 * procento_sleva, 2);
            INSERT INTO SlevaRnd 
            VALUES (id, nazev, cena, procento_sleva, sleva, cena - sleva);

           	IF chybicka = 1 THEN 
          	SIGNAL SQLSTATE '45000';
     		END IF;
    END WHILE;
	
    -- Uzavření kurzoru po dokončení
    CLOSE cur_sleva;

 	
    -- Dokončení transakce
    COMMIT;
END$$

DROP PROCEDURE IF EXISTS `TestSignal`$$
CREATE DEFINER=`root`@`%` PROCEDURE `TestSignal` ()   BEGIN
    DECLARE var_condition INT DEFAULT 1;

    IF var_condition = 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Podmínka byla splněna, vyvolává se chyba',
            MYSQL_ERRNO = 1002;
    END IF;
END$$

--
-- Funkce
--
DROP FUNCTION IF EXISTS `calculate_average_price`$$
CREATE DEFINER=`root`@`%` FUNCTION `calculate_average_price` () RETURNS DECIMAL(10,2) DETERMINISTIC BEGIN
    DECLARE avg_price DECIMAL(10,2);
    
    SELECT AVG(cena) INTO avg_price FROM pc_sestavy;

    RETURN avg_price;
END$$

DROP FUNCTION IF EXISTS `PrumerCenaPcGPU`$$
CREATE DEFINER=`root`@`%` FUNCTION `PrumerCenaPcGPU` (`id_graficke_karty` INT) RETURNS FLOAT  BEGIN
        DECLARE vysledek float;
    
        SELECT AVG(pc_sestavy.cena) INTO vysledek FROM pc_sestavy 
        INNER JOIN ses_gpu ON pc_sestavy.id_ses = ses_gpu.id_ses 
        INNER JOIN graficke_karty ON ses_gpu.id_gpu = graficke_karty.id_gpu WHERE graficke_karty.id_gpu = id_graficke_karty;
    
        IF vysledek IS NULL THEN 
    	    RETURN -1;
        ELSE
    	    RETURN vysledek;
        END IF;
    END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Struktura tabulky `cipove_sady`
--

DROP TABLE IF EXISTS `cipove_sady`;
CREATE TABLE `cipove_sady` (
  `id_cip` int(11) NOT NULL,
  `oznaceni` varchar(10) NOT NULL,
  `id_vyr` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Vypisuji data pro tabulku `cipove_sady`
--

INSERT INTO `cipove_sady` (`id_cip`, `oznaceni`, `id_vyr`) VALUES
(1, 'B760', 2),
(2, 'Z690', 2),
(3, 'Z790', 2),
(4, 'B650', 1),
(5, 'X670E	', 1),
(6, 'B550', 1);

-- --------------------------------------------------------

--
-- Struktura tabulky `formaty_zakladni_desky`
--

DROP TABLE IF EXISTS `formaty_zakladni_desky`;
CREATE TABLE `formaty_zakladni_desky` (
  `id_for` int(11) NOT NULL,
  `oznaceni` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Vypisuji data pro tabulku `formaty_zakladni_desky`
--

INSERT INTO `formaty_zakladni_desky` (`id_for`, `oznaceni`) VALUES
(1, 'ATX'),
(3, 'E-ATX'),
(2, 'M-ATX');

-- --------------------------------------------------------

--
-- Struktura tabulky `graficke_karty`
--

DROP TABLE IF EXISTS `graficke_karty`;
CREATE TABLE `graficke_karty` (
  `id_gpu` int(11) NOT NULL,
  `nazev` varchar(50) NOT NULL,
  `id_vyr` int(11) NOT NULL,
  `id_mod` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Vypisuji data pro tabulku `graficke_karty`
--

INSERT INTO `graficke_karty` (`id_gpu`, `nazev`, `id_vyr`, `id_mod`) VALUES
(1, 'ASUS GeForce RTX 4060', 4, 11),
(2, 'ASUS GeForce RTX 4060 Ti', 4, 12),
(3, 'MSI GeForce RTX 4070', 3, 13),
(4, 'MSI GeForce RTX 4090', 3, 14),
(5, 'GIGABYTE GeForce RTX 3060', 5, 8),
(6, 'GIGABYTE GeForce RTX 3050', 5, 7),
(7, 'Inno3D GeForce RTX 3060 Ti', 6, 9),
(8, 'Inno3D GeForce RTX 4070', 6, 13),
(9, 'ASUS GeForce RTX 4070', 4, 13),
(10, 'MSI GeForce RTX 4060 Ti', 3, 12),
(11, 'Inno3D GeForce RTX 3060', 6, 8),
(12, 'ASUS GeForce RTX 4090', 4, 14),
(13, 'GIGABYTE GeForce RTX 3070', 5, 10);

-- --------------------------------------------------------

--
-- Struktura tabulky `management`
--

DROP TABLE IF EXISTS `management`;
CREATE TABLE `management` (
  `id` int(11) NOT NULL,
  `jmeno` varchar(50) NOT NULL,
  `id_nadrizeneho` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Vypisuji data pro tabulku `management`
--

INSERT INTO `management` (`id`, `jmeno`, `id_nadrizeneho`) VALUES
(1, 'Adam', NULL),
(2, 'Honza', 5),
(3, 'Monika', 1),
(4, 'Jirka', 1),
(5, 'Karel', 2),
(6, 'Ondra', 4);

-- --------------------------------------------------------

--
-- Struktura tabulky `modely`
--

DROP TABLE IF EXISTS `modely`;
CREATE TABLE `modely` (
  `id_mod` int(11) NOT NULL,
  `oznaceni` varchar(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Vypisuji data pro tabulku `modely`
--

INSERT INTO `modely` (`id_mod`, `oznaceni`) VALUES
(4, 'Core i5'),
(5, 'Core i7'),
(6, 'Core i9'),
(7, 'RTX 3050'),
(8, 'RTX 3060'),
(9, 'RTX 3060 Ti'),
(10, 'RTX 3070'),
(11, 'RTX 4060'),
(12, 'RTX 4060 Ti'),
(13, 'RTX 4070'),
(14, 'RTX 4090'),
(1, 'Ryzen 5'),
(2, 'Ryzen 7'),
(3, 'Ryzen 9');

-- --------------------------------------------------------

--
-- Struktura tabulky `patice`
--

DROP TABLE IF EXISTS `patice`;
CREATE TABLE `patice` (
  `id_pat` int(11) NOT NULL,
  `nazev` varchar(10) NOT NULL,
  `id_vyr` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Vypisuji data pro tabulku `patice`
--

INSERT INTO `patice` (`id_pat`, `nazev`, `id_vyr`) VALUES
(1, 'LGA1700', 2),
(2, 'LGA1200', 2),
(3, 'AM4', 1),
(4, 'AM5', 1);

-- --------------------------------------------------------

--
-- Struktura tabulky `pc_sestavy`
--

DROP TABLE IF EXISTS `pc_sestavy`;
CREATE TABLE `pc_sestavy` (
  `id_ses` int(11) NOT NULL,
  `nazev` varchar(50) NOT NULL,
  `id_cpu` int(11) NOT NULL,
  `id_zak` int(11) NOT NULL,
  `id_skr` int(11) NOT NULL,
  `cena` mediumint(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Vypisuji data pro tabulku `pc_sestavy`
--

INSERT INTO `pc_sestavy` (`id_ses`, `nazev`, `id_cpu`, `id_zak`, `id_skr`, `cena`) VALUES
(1, 'R5_76_NC_F', 1, 2, 1, 35300),
(2, 'i9_119_NC_Z', 8, 10, 1, 28427),
(3, 'i7_147_MMB_A', 3, 8, 7, 28572),
(4, 'R9_59X_D7_V', 6, 6, 3, 38142),
(5, 'i7_147_ICUE5D_I', 5, 8, 4, 37640),
(6, 'i5_136_MMC_Z', 5, 11, 7, 22906),
(7, 'i5_136_D7_I', 5, 7, 3, 23732),
(8, 'i7_147_ICUE5D_D', 3, 8, 4, 23710),
(9, 'R9_79X_D7_Z', 4, 3, 3, 27727),
(10, 'R7_78X_65X_Y', 2, 4, 6, 36524),
(11, 'R9_59X_MMC_Q', 6, 5, 7, 40653),
(12, 'i9_119_MMB_T', 8, 10, 8, 40516),
(13, 'i7_127_MMB_F', 10, 1, 8, 32927),
(14, 'i9_119_MMC_C', 8, 10, 7, 23656),
(15, 'i5_136_MMB_L', 5, 8, 8, 35118),
(16, 'i7_127_65X_A', 10, 1, 6, 29690),
(17, 'R9_79X_20D_R', 4, 4, 5, 38763),
(18, 'R9_59X_MMB_X', 6, 6, 8, 31738),
(19, 'R7_58X_D7_W', 11, 4, 3, 37274),
(20, 'i7_147_ICUE5D_W', 3, 8, 4, 22836),
(21, 'i7_127_MMB_L', 10, 7, 8, 27655),
(22, 'i9_119_MMC_J', 8, 10, 7, 36702),
(23, 'i5_136_MMC_N', 5, 12, 7, 41222),
(24, 'R7_58X_D7_Z', 11, 2, 3, 26223),
(25, 'R9_59X_65X_B', 6, 6, 6, 41165),
(26, 'i7_147_MMC_T', 3, 11, 7, 24215),
(27, 'R7_58X_NC_G', 11, 3, 1, 24701),
(28, 'i5_114_MMC_C', 9, 10, 7, 38065),
(29, 'R9_79X_MMC_Z', 4, 3, 7, 28758),
(30, 'i5_136_MMB_R', 5, 11, 8, 34699),
(31, 'R7_58X_MMB_C', 11, 2, 8, 31304),
(32, 'i7_127_ICUE5D_Y', 10, 12, 4, 24174),
(33, 'R7_78X_65X_O', 2, 3, 6, 36240),
(34, 'R9_59X_D7_A', 6, 5, 3, 38561),
(35, 'i5_136_65X_D', 5, 1, 6, 39066),
(36, 'i5_114_65X_X', 9, 9, 6, 29140),
(37, 'R9_79X_65X_Y', 4, 2, 6, 38696),
(38, 'i7_127_D7_O', 10, 1, 3, 40815),
(39, 'R7_77X_D7_H', 12, 3, 3, 33393),
(40, 'i5_136_MMC_E', 5, 12, 7, 31845),
(41, 'i5_136_MMC_V', 5, 8, 7, 26597),
(42, 'i5_114_NC_H', 9, 9, 1, 29940),
(43, 'i5_136_ICUE5D_T', 5, 8, 4, 25167),
(44, 'R9_59X_MMB_N', 6, 5, 8, 22642),
(45, 'i5_136_NC_N', 5, 1, 1, 23515),
(46, 'i7_147_MMC_D', 3, 1, 7, 29812),
(47, 'R9_59X_D7_F', 6, 5, 3, 38557),
(48, 'R9_59X_MMC_X', 6, 5, 7, 40434),
(49, 'i7_127_MMB_A', 10, 11, 8, 29594),
(50, 'R9_79X_CORE_A', 4, 4, 2, 25961),
(51, 'R9_59X_MMC_R', 6, 5, 7, 27303),
(52, 'R9_59X_MMC_V', 6, 6, 7, 25327),
(53, 'i7_147_D7_W', 3, 11, 3, 35857),
(54, 'i7_127_MMB_M', 10, 12, 8, 22592),
(55, 'R9_79X_MMB_L', 4, 2, 8, 37974),
(56, 'i5_114_20D_Y', 9, 10, 5, 24904),
(57, 'i7_127_NC_T', 10, 11, 1, 37123),
(58, 'R7_58X_NC_R', 11, 2, 1, 26454),
(59, 'i5_136_MMC_C', 5, 11, 7, 36606),
(60, 'R7_77X_20D_Y', 12, 4, 5, 33556),
(61, 'i5_106_MMC_S', 7, 10, 7, 35767),
(62, 'R7_58X_CORE_G', 11, 4, 2, 26321);

--
-- Triggery `pc_sestavy`
--
DROP TRIGGER IF EXISTS `tri_pc_sestavy_after_update`;
DELIMITER $$
CREATE TRIGGER `tri_pc_sestavy_after_update` AFTER UPDATE ON `pc_sestavy` FOR EACH ROW BEGIN
            IF(OLD.id_ses != NEW.id_ses) THEN
                INSERT INTO pc_sestavy_zmeny VALUES(id_zme, OLD.id_ses, OLD.id_ses, NEW.id_ses , 'ID sestavy', NOW(), USER());
            END IF;
                 IF(OLD.nazev != NEW.nazev) THEN
                INSERT INTO pc_sestavy_zmeny VALUES(id_zme, OLD.id_ses, OLD.nazev, NEW.nazev , 'Název', NOW(), USER());
            END IF;
                 IF(OLD.cena != NEW.cena) THEN
                INSERT INTO pc_sestavy_zmeny VALUES(id_zme, OLD.id_ses, OLD.cena, NEW.cena , 'Cena', NOW(), USER());
            END IF;
                 IF(OLD.id_cpu != NEW.id_cpu) THEN
                INSERT INTO pc_sestavy_zmeny VALUES(id_zme, OLD.id_ses, OLD.id_cpu, NEW.id_cpu, 'ID Procesoru', NOW(), USER());  
            END IF;
                 IF(OLD.id_zak != NEW.id_zak) THEN
                INSERT INTO pc_sestavy_zmeny VALUES(id_zme, OLD.id_ses, OLD.id_zak, NEW.id_zak , 'ID Základní desky', NOW(), USER());
            END IF;
                 IF(OLD.id_skr != NEW.id_skr) THEN
                INSERT INTO pc_sestavy_zmeny VALUES(id_zme, OLD.id_ses, OLD.id_skr, NEW.id_skr , 'ID Skříně', NOW(), USER());
            END IF;
	END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struktura tabulky `pc_sestavy_zmeny`
--

DROP TABLE IF EXISTS `pc_sestavy_zmeny`;
CREATE TABLE `pc_sestavy_zmeny` (
  `id_zme` int(11) NOT NULL,
  `id_ses` int(11) DEFAULT NULL,
  `puvodni_hod` varchar(50) DEFAULT NULL,
  `nova_hod` varchar(50) DEFAULT NULL,
  `zmena` char(20) DEFAULT NULL,
  `datum_cas_zmeny` datetime DEFAULT NULL,
  `autor_zmeny` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Vypisuji data pro tabulku `pc_sestavy_zmeny`
--

INSERT INTO `pc_sestavy_zmeny` (`id_zme`, `id_ses`, `puvodni_hod`, `nova_hod`, `zmena`, `datum_cas_zmeny`, `autor_zmeny`) VALUES
(1, 1, '35321', '36300', 'Cena', '2024-12-22 15:39:46', 'root@172.19.0.3'),
(2, 3, '8', '7', 'ID Skříně', '2024-12-22 15:41:36', 'visitor@172.19.0.3'),
(3, 1, '36300', '35300', 'Cena', '2024-12-28 15:22:50', 'root@172.19.0.3'),
(4, 5, '3', '5', 'ID Procesoru', '2025-01-07 12:57:31', 'root@172.19.0.3');

-- --------------------------------------------------------

--
-- Struktura tabulky `pc_skrin`
--

DROP TABLE IF EXISTS `pc_skrin`;
CREATE TABLE `pc_skrin` (
  `id_skr` int(11) NOT NULL,
  `nazev` varchar(30) NOT NULL,
  `id_vyr` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Vypisuji data pro tabulku `pc_skrin`
--

INSERT INTO `pc_skrin` (`id_skr`, `nazev`, `id_vyr`) VALUES
(1, 'Fractal Design North Chalk', 7),
(2, 'Fractal Design CORE', 7),
(3, 'Fractal Design Define 7', 7),
(4, 'Corsair iCUE 5000D', 8),
(5, 'Corsair 2000D', 8),
(6, 'Corsair 6500X', 8),
(7, 'Cooler Master MasterCase', 9),
(8, 'Cooler Master MASTERBOX', 9);

-- --------------------------------------------------------

--
-- Zástupná struktura pro pohled `prehled_vyuzitych_zakladnich_desek`
-- (Vlastní pohled viz níže)
--
DROP VIEW IF EXISTS `prehled_vyuzitych_zakladnich_desek`;
CREATE TABLE `prehled_vyuzitych_zakladnich_desek` (
`Název zakladní desky` varchar(20)
,`Čipset` varchar(10)
,`Název výrobce` varchar(50)
,`Počet využích desek` bigint(21)
);

-- --------------------------------------------------------

--
-- Struktura tabulky `procesory`
--

DROP TABLE IF EXISTS `procesory`;
CREATE TABLE `procesory` (
  `id_cpu` int(11) NOT NULL,
  `nazev` varchar(50) NOT NULL,
  `id_vyr` int(11) NOT NULL,
  `id_pat` int(11) NOT NULL,
  `id_mod` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Vypisuji data pro tabulku `procesory`
--

INSERT INTO `procesory` (`id_cpu`, `nazev`, `id_vyr`, `id_pat`, `id_mod`) VALUES
(1, 'AMD Ryzen 5 7600', 1, 4, 1),
(2, 'AMD Ryzen 7 7800X3D', 1, 4, 2),
(3, 'Intel Core i7-14700KF', 2, 1, 5),
(4, 'AMD Ryzen 9 7950X3D', 1, 4, 3),
(5, 'Intel Core i5-13600KF', 2, 1, 4),
(6, 'AMD Ryzen 9 5900X', 1, 3, 3),
(7, 'Intel Core i5-10600KF', 2, 2, 4),
(8, 'Intel Core i9-11900', 2, 2, 6),
(9, 'Intel Core i5-11400F', 2, 2, 4),
(10, 'Intel Core i7-12700KF', 2, 1, 5),
(11, 'AMD Ryzen 7 5800X', 1, 4, 2),
(12, 'AMD Ryzen 7 7700X', 1, 4, 2);

-- --------------------------------------------------------

--
-- Struktura tabulky `ses_gpu`
--

DROP TABLE IF EXISTS `ses_gpu`;
CREATE TABLE `ses_gpu` (
  `id_ses` int(11) NOT NULL,
  `id_gpu` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Vypisuji data pro tabulku `ses_gpu`
--

INSERT INTO `ses_gpu` (`id_ses`, `id_gpu`) VALUES
(30, 10),
(27, 10),
(13, 2),
(6, 9),
(6, 1),
(11, 6),
(29, 12),
(29, 11),
(1, 9),
(15, 1),
(41, 7),
(20, 3),
(19, 10),
(33, 6),
(33, 1),
(32, 11),
(32, 13),
(35, 8),
(43, 3),
(43, 12),
(38, 2),
(38, 3),
(23, 4),
(23, 12),
(18, 4),
(18, 2),
(31, 1),
(12, 9),
(17, 9),
(26, 6),
(34, 5),
(22, 12),
(14, 3),
(10, 10),
(5, 9),
(5, 6),
(25, 5),
(25, 11),
(2, 13),
(40, 5),
(39, 9),
(8, 7),
(8, 8),
(21, 9),
(7, 10),
(24, 10),
(24, 6),
(36, 13),
(36, 8),
(3, 5),
(9, 3),
(9, 4),
(37, 4),
(28, 5),
(28, 4),
(42, 7),
(4, 9),
(16, 10),
(16, 10),
(46, 2),
(50, 7),
(50, 11),
(51, 12),
(52, 9),
(52, 3),
(47, 12),
(44, 7),
(53, 7),
(53, 7),
(45, 12),
(48, 11),
(48, 12),
(49, 7),
(57, 9),
(57, 9),
(59, 12),
(59, 5),
(58, 11),
(54, 5),
(54, 1),
(55, 12),
(56, 4),
(60, 10),
(61, 10);

-- --------------------------------------------------------

--
-- Struktura tabulky `skr_for`
--

DROP TABLE IF EXISTS `skr_for`;
CREATE TABLE `skr_for` (
  `id_skr` int(11) NOT NULL,
  `id_for` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Vypisuji data pro tabulku `skr_for`
--

INSERT INTO `skr_for` (`id_skr`, `id_for`) VALUES
(8, 1),
(8, 2),
(8, 3),
(7, 1),
(7, 2),
(7, 3),
(6, 1),
(6, 2),
(5, 2),
(4, 1),
(4, 3),
(3, 1),
(3, 2),
(2, 2),
(1, 1),
(1, 2);

-- --------------------------------------------------------

--
-- Struktura tabulky `SlevaRnd`
--

DROP TABLE IF EXISTS `SlevaRnd`;
CREATE TABLE `SlevaRnd` (
  `id_ses` int(11) NOT NULL,
  `nazev` varchar(50) DEFAULT NULL,
  `cena` decimal(10,2) DEFAULT NULL,
  `procento_sleva` tinyint(4) DEFAULT NULL,
  `sleva` decimal(10,2) DEFAULT NULL,
  `cena_sleva` decimal(10,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Vypisuji data pro tabulku `SlevaRnd`
--

INSERT INTO `SlevaRnd` (`id_ses`, `nazev`, `cena`, `procento_sleva`, `sleva`, `cena_sleva`) VALUES
(1, 'R5_76_NC_F', 35300.00, 20, 7060.00, 28240.00);

-- --------------------------------------------------------

--
-- Struktura tabulky `vyrobci`
--

DROP TABLE IF EXISTS `vyrobci`;
CREATE TABLE `vyrobci` (
  `id_vyr` int(11) NOT NULL,
  `nazev` varchar(50) NOT NULL,
  `zkratka` varchar(15) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Vypisuji data pro tabulku `vyrobci`
--

INSERT INTO `vyrobci` (`id_vyr`, `nazev`, `zkratka`) VALUES
(1, 'Advanced Micro Devices', 'AMD'),
(2, 'Intel Corporation', 'Intel'),
(3, 'Micro-Star International', 'MSI'),
(4, 'ASUSTek Computer', 'ASUS'),
(5, 'Gigabyte Technology', 'GIGABYTE'),
(6, 'InnoVISION Multimedia Limited', 'Inno3D'),
(7, 'Fractal Design', 'Fractal'),
(8, 'Corsair Gaming', 'Corsair'),
(9, 'Cooler Master Technology', 'Cooler Master');

-- --------------------------------------------------------

--
-- Struktura tabulky `zakladni_desky`
--

DROP TABLE IF EXISTS `zakladni_desky`;
CREATE TABLE `zakladni_desky` (
  `id_zak` int(11) NOT NULL,
  `nazev` varchar(20) NOT NULL,
  `id_vyr` int(11) NOT NULL,
  `id_pat` int(11) NOT NULL,
  `id_cip` int(11) NOT NULL,
  `id_for` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Vypisuji data pro tabulku `zakladni_desky`
--

INSERT INTO `zakladni_desky` (`id_zak`, `nazev`, `id_vyr`, `id_pat`, `id_cip`, `id_for`) VALUES
(1, 'ASUS B760M', 1, 1, 1, 2),
(2, 'MSI  X670E', 3, 4, 5, 1),
(3, 'GIGABYTE B650', 5, 4, 4, 1),
(4, 'ASUS B650M', 4, 4, 4, 2),
(5, 'ASUS B550', 4, 3, 6, 1),
(6, 'GIGABYTE B550M', 5, 3, 6, 2),
(7, 'ASUS Z690', 4, 1, 2, 1),
(8, 'MSI Z790', 3, 1, 3, 3),
(9, 'ASUS X670E', 4, 2, 5, 2),
(10, 'GIGABYTE B550', 5, 2, 6, 2),
(11, 'GIGABYTE Z790', 5, 1, 3, 1),
(12, 'MSI Z690', 3, 1, 2, 1);

-- --------------------------------------------------------

--
-- Struktura pro pohled `prehled_vyuzitych_zakladnich_desek`
--
DROP TABLE IF EXISTS `prehled_vyuzitych_zakladnich_desek`;

DROP VIEW IF EXISTS `prehled_vyuzitych_zakladnich_desek`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`%` SQL SECURITY DEFINER VIEW `prehled_vyuzitych_zakladnich_desek`  AS SELECT `zakladni_desky`.`nazev` AS `Název zakladní desky`, `cipove_sady`.`oznaceni` AS `Čipset`, `vyrobci`.`nazev` AS `Název výrobce`, count(0) AS `Počet využích desek` FROM ((`cipove_sady` left join (`zakladni_desky` left join `pc_sestavy` on(`zakladni_desky`.`id_zak` = `id_zak`)) on(`zakladni_desky`.`id_cip` = `cipove_sady`.`id_cip`)) join `vyrobci` on(`zakladni_desky`.`id_vyr` = `vyrobci`.`id_vyr`)) GROUP BY `zakladni_desky`.`nazev` ;

--
-- Indexy pro exportované tabulky
--

--
-- Indexy pro tabulku `cipove_sady`
--
ALTER TABLE `cipove_sady`
  ADD PRIMARY KEY (`id_cip`),
  ADD UNIQUE KEY `oznaceni` (`oznaceni`),
  ADD KEY `id_vyr` (`id_vyr`) USING BTREE;

--
-- Indexy pro tabulku `formaty_zakladni_desky`
--
ALTER TABLE `formaty_zakladni_desky`
  ADD PRIMARY KEY (`id_for`),
  ADD UNIQUE KEY `oznaceni` (`oznaceni`);

--
-- Indexy pro tabulku `graficke_karty`
--
ALTER TABLE `graficke_karty`
  ADD PRIMARY KEY (`id_gpu`),
  ADD UNIQUE KEY `nazev` (`nazev`),
  ADD KEY `id_vyr` (`id_vyr`) USING BTREE,
  ADD KEY `id_mod` (`id_mod`) USING BTREE;

--
-- Indexy pro tabulku `management`
--
ALTER TABLE `management`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `jmeno` (`jmeno`),
  ADD KEY `id_nadrizeneho` (`id_nadrizeneho`);

--
-- Indexy pro tabulku `modely`
--
ALTER TABLE `modely`
  ADD PRIMARY KEY (`id_mod`),
  ADD UNIQUE KEY `oznaceni` (`oznaceni`);

--
-- Indexy pro tabulku `patice`
--
ALTER TABLE `patice`
  ADD PRIMARY KEY (`id_pat`),
  ADD UNIQUE KEY `nazev` (`nazev`),
  ADD KEY `id_vyr` (`id_vyr`);

--
-- Indexy pro tabulku `pc_sestavy`
--
ALTER TABLE `pc_sestavy`
  ADD PRIMARY KEY (`id_ses`),
  ADD UNIQUE KEY `unique_nazev` (`nazev`),
  ADD KEY `id_cpu` (`id_cpu`) USING BTREE,
  ADD KEY `id_skr` (`id_skr`) USING BTREE,
  ADD KEY `id_zak` (`id_zak`) USING BTREE;

--
-- Indexy pro tabulku `pc_sestavy_zmeny`
--
ALTER TABLE `pc_sestavy_zmeny`
  ADD PRIMARY KEY (`id_zme`);

--
-- Indexy pro tabulku `pc_skrin`
--
ALTER TABLE `pc_skrin`
  ADD PRIMARY KEY (`id_skr`),
  ADD UNIQUE KEY `nazev` (`nazev`),
  ADD KEY `id_vyr` (`id_vyr`) USING BTREE;

--
-- Indexy pro tabulku `procesory`
--
ALTER TABLE `procesory`
  ADD PRIMARY KEY (`id_cpu`),
  ADD UNIQUE KEY `nazev` (`nazev`),
  ADD KEY `id_mod` (`id_mod`) USING BTREE,
  ADD KEY `id_pat` (`id_pat`) USING BTREE,
  ADD KEY `id_vyr` (`id_vyr`) USING BTREE;

--
-- Indexy pro tabulku `ses_gpu`
--
ALTER TABLE `ses_gpu`
  ADD KEY `id_gpu` (`id_gpu`) USING BTREE,
  ADD KEY `id_ses` (`id_ses`) USING BTREE;

--
-- Indexy pro tabulku `skr_for`
--
ALTER TABLE `skr_for`
  ADD KEY `id_skr` (`id_skr`),
  ADD KEY `id_for` (`id_for`);

--
-- Indexy pro tabulku `SlevaRnd`
--
ALTER TABLE `SlevaRnd`
  ADD PRIMARY KEY (`id_ses`);

--
-- Indexy pro tabulku `vyrobci`
--
ALTER TABLE `vyrobci`
  ADD PRIMARY KEY (`id_vyr`),
  ADD UNIQUE KEY `nazev` (`nazev`),
  ADD UNIQUE KEY `zkratka` (`zkratka`);
ALTER TABLE `vyrobci` ADD FULLTEXT KEY `fulltext_nazev` (`nazev`,`zkratka`);

--
-- Indexy pro tabulku `zakladni_desky`
--
ALTER TABLE `zakladni_desky`
  ADD PRIMARY KEY (`id_zak`),
  ADD UNIQUE KEY `nazev` (`nazev`),
  ADD KEY `id_for` (`id_for`) USING BTREE,
  ADD KEY `id_cip` (`id_cip`) USING BTREE,
  ADD KEY `id_pat` (`id_pat`) USING BTREE,
  ADD KEY `id_vyr` (`id_vyr`) USING BTREE;

--
-- AUTO_INCREMENT pro tabulky
--

--
-- AUTO_INCREMENT pro tabulku `cipove_sady`
--
ALTER TABLE `cipove_sady`
  MODIFY `id_cip` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT pro tabulku `formaty_zakladni_desky`
--
ALTER TABLE `formaty_zakladni_desky`
  MODIFY `id_for` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT pro tabulku `graficke_karty`
--
ALTER TABLE `graficke_karty`
  MODIFY `id_gpu` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT pro tabulku `management`
--
ALTER TABLE `management`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT pro tabulku `modely`
--
ALTER TABLE `modely`
  MODIFY `id_mod` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT pro tabulku `patice`
--
ALTER TABLE `patice`
  MODIFY `id_pat` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT pro tabulku `pc_sestavy`
--
ALTER TABLE `pc_sestavy`
  MODIFY `id_ses` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=65;

--
-- AUTO_INCREMENT pro tabulku `pc_sestavy_zmeny`
--
ALTER TABLE `pc_sestavy_zmeny`
  MODIFY `id_zme` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT pro tabulku `pc_skrin`
--
ALTER TABLE `pc_skrin`
  MODIFY `id_skr` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT pro tabulku `procesory`
--
ALTER TABLE `procesory`
  MODIFY `id_cpu` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT pro tabulku `vyrobci`
--
ALTER TABLE `vyrobci`
  MODIFY `id_vyr` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT pro tabulku `zakladni_desky`
--
ALTER TABLE `zakladni_desky`
  MODIFY `id_zak` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- Omezení pro exportované tabulky
--

--
-- Omezení pro tabulku `cipove_sady`
--
ALTER TABLE `cipove_sady`
  ADD CONSTRAINT `cipove_sady_ibfk_1` FOREIGN KEY (`id_vyr`) REFERENCES `vyrobci` (`id_vyr`);

--
-- Omezení pro tabulku `graficke_karty`
--
ALTER TABLE `graficke_karty`
  ADD CONSTRAINT `graficke_karty_ibfk_1` FOREIGN KEY (`id_vyr`) REFERENCES `vyrobci` (`id_vyr`),
  ADD CONSTRAINT `graficke_karty_ibfk_2` FOREIGN KEY (`id_mod`) REFERENCES `modely` (`id_mod`);

--
-- Omezení pro tabulku `management`
--
ALTER TABLE `management`
  ADD CONSTRAINT `management_ibfk_1` FOREIGN KEY (`id_nadrizeneho`) REFERENCES `management` (`id`);

--
-- Omezení pro tabulku `patice`
--
ALTER TABLE `patice`
  ADD CONSTRAINT `patice_ibfk_1` FOREIGN KEY (`id_vyr`) REFERENCES `vyrobci` (`id_vyr`);

--
-- Omezení pro tabulku `pc_sestavy`
--
ALTER TABLE `pc_sestavy`
  ADD CONSTRAINT `pc_sestavy_ibfk_2` FOREIGN KEY (`id_skr`) REFERENCES `pc_skrin` (`id_skr`),
  ADD CONSTRAINT `pc_sestavy_ibfk_4` FOREIGN KEY (`id_cpu`) REFERENCES `procesory` (`id_cpu`),
  ADD CONSTRAINT `pc_sestavy_ibfk_5` FOREIGN KEY (`id_zak`) REFERENCES `zakladni_desky` (`id_zak`);

--
-- Omezení pro tabulku `pc_skrin`
--
ALTER TABLE `pc_skrin`
  ADD CONSTRAINT `pc_skrin_ibfk_1` FOREIGN KEY (`id_vyr`) REFERENCES `vyrobci` (`id_vyr`);

--
-- Omezení pro tabulku `procesory`
--
ALTER TABLE `procesory`
  ADD CONSTRAINT `procesory_ibfk_1` FOREIGN KEY (`id_vyr`) REFERENCES `vyrobci` (`id_vyr`),
  ADD CONSTRAINT `procesory_ibfk_2` FOREIGN KEY (`id_pat`) REFERENCES `patice` (`id_pat`),
  ADD CONSTRAINT `procesory_ibfk_3` FOREIGN KEY (`id_mod`) REFERENCES `modely` (`id_mod`);

--
-- Omezení pro tabulku `ses_gpu`
--
ALTER TABLE `ses_gpu`
  ADD CONSTRAINT `ses_gpu_ibfk_4` FOREIGN KEY (`id_gpu`) REFERENCES `graficke_karty` (`id_gpu`),
  ADD CONSTRAINT `ses_gpu_ibfk_5` FOREIGN KEY (`id_ses`) REFERENCES `pc_sestavy` (`id_ses`);

--
-- Omezení pro tabulku `skr_for`
--
ALTER TABLE `skr_for`
  ADD CONSTRAINT `skr_for_ibfk_1` FOREIGN KEY (`id_for`) REFERENCES `formaty_zakladni_desky` (`id_for`),
  ADD CONSTRAINT `skr_for_ibfk_2` FOREIGN KEY (`id_skr`) REFERENCES `pc_skrin` (`id_skr`);

--
-- Omezení pro tabulku `zakladni_desky`
--
ALTER TABLE `zakladni_desky`
  ADD CONSTRAINT `zakladni_desky_ibfk_1` FOREIGN KEY (`id_vyr`) REFERENCES `vyrobci` (`id_vyr`),
  ADD CONSTRAINT `zakladni_desky_ibfk_2` FOREIGN KEY (`id_for`) REFERENCES `formaty_zakladni_desky` (`id_for`),
  ADD CONSTRAINT `zakladni_desky_ibfk_3` FOREIGN KEY (`id_cip`) REFERENCES `cipove_sady` (`id_cip`),
  ADD CONSTRAINT `zakladni_desky_ibfk_4` FOREIGN KEY (`id_pat`) REFERENCES `patice` (`id_pat`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
