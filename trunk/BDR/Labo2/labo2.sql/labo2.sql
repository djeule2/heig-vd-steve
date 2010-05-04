-- phpMyAdmin SQL Dump
-- version 3.2.0.1
-- http://www.phpmyadmin.net
--
-- Serveur: localhost
-- Généré le : Dim 14 Mars 2010 à 13:31
-- Version du serveur: 5.1.36
-- Version de PHP: 5.3.0

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Base de données: `labo2`
--

-- --------------------------------------------------------

--
-- Structure de la table `client`
--

CREATE TABLE IF NOT EXISTS `client` (
  `NUMERO_CLI` int(11) NOT NULL DEFAULT '0' COMMENT 'Numéro d''identification du client',
  `NOM_CLI` varchar(20) DEFAULT NULL COMMENT 'Nom du client',
  `ADRESSE_CLI` varchar(75) DEFAULT NULL COMMENT 'Adresse du client(rue,NPA,ville)',
  `TELEPHONE_CLI` varchar(20) NOT NULL COMMENT 'Numéro de télephone du client',
  `PAYS_CLI` varchar(20) DEFAULT NULL COMMENT 'Pays du client',
  PRIMARY KEY (`NUMERO_CLI`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Contenu de la table `client`
--

INSERT INTO `client` (`NUMERO_CLI`, `NOM_CLI`, `ADRESSE_CLI`, `TELEPHONE_CLI`, `PAYS_CLI`) VALUES
(1, 'Maria Anders', 'Obere Str. 57', '1851', 'Suisse'),
(3, 'Christina Berglund', 'Rambla de Catalu?a', '2658', 'Belgique'),
(4, 'Patricio Simpson', 'rue des Bouchers', '2895', 'Finlande'),
(5, 'Janine Labrun', 'Berliner Platz 43', '2635', 'Belgique'),
(6, 'Fr?d?rique Citeaux', 'Walserweg 21', '2569', 'Irlande'),
(7, 'Hanna Moos', 'Via Monte Bianco 34', '21235', 'Italie'),
(8, 'Yang Wang', 'City Center Plaza 516', '28759', 'Gr?ce'),
(9, 'Aria Cruz', 'Moralzarzal 67', '5461', 'Norv?ge'),
(10, 'homas Hardy', 'rue St. Laurent 2', '72561', 'Pays-bas');

-- --------------------------------------------------------

--
-- Structure de la table `commande`
--

CREATE TABLE IF NOT EXISTS `commande` (
  `NUMERO_COM` int(11) NOT NULL DEFAULT '0' COMMENT 'Numéro de la commande',
  `DATE_COM` date DEFAULT NULL COMMENT 'Date de la commande',
  `ETAT_COM` varchar(1) NOT NULL COMMENT 'Etat de la commande',
  `NUMERO_CLI` int(11) DEFAULT NULL COMMENT 'Numéro du client qui commande',
  PRIMARY KEY (`NUMERO_COM`),
  KEY `NUMERO_CLI` (`NUMERO_CLI`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Contenu de la table `commande`
--

INSERT INTO `commande` (`NUMERO_COM`, `DATE_COM`, `ETAT_COM`, `NUMERO_CLI`) VALUES
(2, '2008-03-13', 'P', 3),
(3, '2008-03-14', 'P', 5),
(4, '2008-03-14', 'P', 6),
(6, '2008-03-16', 'C', 8),
(7, '2008-03-17', 'C', 9),
(9, '2008-03-20', 'C', 3),
(10, '2008-03-21', 'C', 10);

-- --------------------------------------------------------

--
-- Structure de la table `ligne_commande`
--

CREATE TABLE IF NOT EXISTS `ligne_commande` (
  `NUMERO_LIG` int(11) NOT NULL DEFAULT '0' COMMENT 'Numéro de la ligne de commande',
  `QUANTITE_LIG` int(11) DEFAULT NULL COMMENT 'Quantité du produit commandé',
  `NUMERO_COM` int(11) NOT NULL DEFAULT '0' COMMENT 'Numéro de la commande',
  `NUMERO_PRO` int(11) DEFAULT NULL COMMENT 'Numéro du produit commandé',
  PRIMARY KEY (`NUMERO_LIG`),
  KEY `NUMERO_COM` (`NUMERO_COM`),
  KEY `NUMERO_PRO` (`NUMERO_PRO`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Contenu de la table `ligne_commande`
--

INSERT INTO `ligne_commande` (`NUMERO_LIG`, `QUANTITE_LIG`, `NUMERO_COM`, `NUMERO_PRO`) VALUES
(3, 3, 2, 5),
(4, 7, 3, 3),
(5, 5, 3, 8),
(6, 8, 3, 4),
(7, 1, 4, 1),
(9, 15, 6, 9),
(10, 13, 6, 2),
(11, 4, 7, 2),
(12, 12, 7, 3),
(13, 10, 7, 4),
(14, 9, 7, 5),
(16, 6, 9, 7),
(17, 1, 9, 8),
(18, 2, 9, 1),
(21, 6, 10, 3),
(22, 3, 10, 5),
(23, 12, 10, 2),
(24, 2, 10, 4);

-- --------------------------------------------------------

--
-- Structure de la table `produit`
--

CREATE TABLE IF NOT EXISTS `produit` (
  `NUMERO_PRO` int(11) NOT NULL DEFAULT '0' COMMENT 'Numéro du produit',
  `NOM_PRO` varchar(75) DEFAULT NULL COMMENT 'Nom du produit',
  `PRIX_PRO` float DEFAULT NULL COMMENT 'Prix du produit',
  PRIMARY KEY (`NUMERO_PRO`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Contenu de la table `produit`
--

INSERT INTO `produit` (`NUMERO_PRO`, `NOM_PRO`, `PRIX_PRO`) VALUES
(1, 'Refroidisseur CPU pour Pent./K6 -266', 14.5),
(2, 'Mainboard MSI Pentium II, AGP', 187.3),
(3, 'Carte graphique Apollo 3DFX, 6MB, Box', 168.9),
(4, 'Disque dur Ultra-WIDE-SCSI 9 GB, IBM, 10000RPM', 1550.5),
(5, 'Superdisk Medium 120MB, 5 pcs.', 103.6),
(6, 'Souris, 3 boutons, compatible MS, s?rie. PS2', 9.2),
(7, 'CD-ROM 24x IDE', 20.3),
(8, 'Switch Ethernet, 2 ports, 100-Base-TX + 10-Base-T', 470.7),
(9, 'C?ble imprimante, 3 m?tres', 14.6),
(10, 'DIMM 32 MB SDRAM', 93.8);

--
-- Contraintes pour les tables exportées
--

--
-- Contraintes pour la table `commande`
--
ALTER TABLE `commande`
  ADD CONSTRAINT `commande_ibfk_1` FOREIGN KEY (`NUMERO_CLI`) REFERENCES `client` (`NUMERO_CLI`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Contraintes pour la table `ligne_commande`
--
ALTER TABLE `ligne_commande`
  ADD CONSTRAINT `ligne_commande_ibfk_3` FOREIGN KEY (`NUMERO_COM`) REFERENCES `commande` (`NUMERO_COM`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `ligne_commande_ibfk_4` FOREIGN KEY (`NUMERO_PRO`) REFERENCES `produit` (`NUMERO_PRO`) ON DELETE CASCADE ON UPDATE CASCADE;
