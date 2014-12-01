-- phpMyAdmin SQL Dump
-- version 3.2.4
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: Nov 19, 2014 at 03:27 PM
-- Server version: 5.1.44
-- PHP Version: 5.3.1

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Database: `ccp`
--

-- --------------------------------------------------------

--
-- Table structure for table `tickets`
--

CREATE TABLE IF NOT EXISTS `tickets` (
  `subject` varchar(255) NOT NULL,
  `details` text NOT NULL,
  `priority` varchar(20) NOT NULL,
  `user` varchar(255) NOT NULL,
  `created_on` datetime NOT NULL,
  `status` varchar(255) NOT NULL,
  `last_update` datetime NOT NULL,
  `id` int(255) NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`id`),
  KEY `user` (`user`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=14 ;

--
-- Dumping data for table `tickets`
--


-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE IF NOT EXISTS `users` (
  `username` varchar(255) NOT NULL,
  `firstname` varchar(255) NOT NULL,
  `lastname` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `institute` varchar(255) NOT NULL,
  `group` varchar(255) NOT NULL,
  `working_group` varchar(255) NOT NULL,
  `picture` blob NOT NULL,
  `password` varchar(255) NOT NULL,
  `salt` varchar(255) NOT NULL,
  `created_on` datetime NOT NULL,
  `last_edit_on` datetime NOT NULL,
  `id` int(255) NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=11 ;

--
-- Dumping data for table `users`
--


-- --------------------------------------------------------

--
-- Table structure for table `user_profile_sections`
--

CREATE TABLE IF NOT EXISTS `user_profile_sections` (
  `username` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `section` varchar(255) NOT NULL,
  `section_details` text NOT NULL,
  `created_on` datetime NOT NULL,
  `last_updated` datetime NOT NULL,
  `id` int(255) NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`id`),
  KEY `username` (`username`,`email`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=8 ;

--
-- Dumping data for table `user_profile_sections`
--


-- --------------------------------------------------------

--
-- Table structure for table `user_uploaded_files`
--

CREATE TABLE IF NOT EXISTS `user_uploaded_files` (
  `username` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `type` varchar(255) NOT NULL,
  `cancer_type` varchar(255) NOT NULL,
  `subtype` varchar(255) NOT NULL,
  `filename` varchar(1024) NOT NULL,
  `comments` text NOT NULL,
  `created_on` datetime NOT NULL,
  `id` bigint(255) NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`id`),
  KEY `username` (`username`,`email`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=10 ;

--
-- Dumping data for table `user_uploaded_files`
--


-- --------------------------------------------------------

--
-- Table structure for table `valid_emails`
--

CREATE TABLE IF NOT EXISTS `valid_emails` (
  `email_address` varchar(255) NOT NULL,
  `created_on` datetime NOT NULL,
  `id` int(255) NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`id`),
  UNIQUE KEY `emial_address` (`email_address`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=3 ;

--
-- Dumping data for table `valid_emails`
--

INSERT INTO `valid_emails` (`email_address`, `created_on`, `id`) VALUES
('r.rahman@nki.nl', NOW(), 1),
('rubayte.iut@gmail.com', NOW(), 2),
('da1@sanger.ac.uk ',NOW(),3),
('dp8@sanger.ac.uk',NOW(),4),
('ca6@sanger.ac.uk ',NOW(),5),
('mr10@sanger.ac.uk',NOW(),6),
('jvf21@cam.ac.uk',NOW(),7),
('ar12@sanger.ac.uk',NOW(),8),
('mg12@sanger.ac.uk',NOW(),9),
('um1@sanger.ac.uk',NOW(),10),
('ca4@sanger.ac.uk',NOW(),11),
('iorio@ebi.ac.uk',NOW(),12),
('a.berns@nki.nl',NOW(),13),
('j.badhai@nki.nl',NOW(),14),
('l.bombardelli@nki.nl',NOW(),15),
('g.ferone@nki.nl',NOW(),16),
('i.huijbers@nki.nl',NOW(),17),
('p.krimpenfort@nki.nl',NOW(),18),
('m.c.kwon@nki.nl',NOW(),19),
('r.nagel@nki.nl',NOW(),20),
('h.d.vries@nki.nl',NOW(),21),
('j.jonkers@nki.nl',NOW(),22),
('s.annunziato@nki.nl',NOW(),23),
('s.kas@nki.nl',NOW(),24),
('j.d.ruiter@nki.nl',NOW(),25),
('d.peeper@nki.nl',NOW(),26),
('x.huang@nki.nl',NOW(),27),
('j.kaplon@nki.nl',NOW(),28),
('k.kemper@nki.nl',NOW(),29),
('x.kong@nki.nl',NOW(),30),
('o.krijgsman@nki.nl',NOW(),31),
('p.possik@nki.nl',NOW(),32),
('j.mueller@nki.nl',NOW(),33),
('a.shahrabi@nki.nl',NOW(),34),
('t.kuilman@nki.nl',NOW(),35),
('l.wessels@nki.nl',NOW(),36),
('n.aben@nki.nl',NOW(),37),
('m.michaut@nki.nl',NOW(),38),
('d.vis@nki.nl',NOW(),39),
('t.d.knegt@nki.nl',NOW(),40),
('m.degen@nki.nl',NOW(),41),
('m.v.diermen@nki.nl',NOW(),42),
('p.lagerweij@nki.nl',NOW(),43),
('wch@sanger.ac.uk',NOW(),44),
('am18@sanger.ac.uk',NOW(),45),
('jb34@sanger.ac.uk',NOW(),46),
('sp7@sanger.ac.uk',NOW(),47),
('sw17@sanger.ac.uk',NOW(),48),
('e.semenova@nki.nl',NOW(),49);

-- --------------------------------------------------------

--
-- Table structure for table `valid_groups`
--

CREATE TABLE IF NOT EXISTS `valid_groups` (
  `group` varchar(255) NOT NULL,
  `id` int(255) NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=9 ;

--
-- Dumping data for table `valid_groups`
--

INSERT INTO `valid_groups` (`group`, `id`) VALUES
('Adams', 1),
('Garnet', 2),
('McDermott', 3),
('Berns', 4),
('Jonkers', 5),
('Wessels', 6),
('Peeper', 7),
('Others', 8);

-- --------------------------------------------------------

--
-- Table structure for table `valid_institutes`
--

CREATE TABLE IF NOT EXISTS `valid_institutes` (
  `institute` varchar(255) NOT NULL,
  `full_name` int(255) NOT NULL,
  `id` int(255) NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=3 ;

--
-- Dumping data for table `valid_institutes`
--

INSERT INTO `valid_institutes` (`institute`, `full_name`, `id`) VALUES
('NKI', 0, 1),
('WTSI', 0, 2);

-- --------------------------------------------------------

--
-- Table structure for table `valid_working_groups`
--

CREATE TABLE IF NOT EXISTS `valid_working_groups` (
  `group` varchar(255) NOT NULL,
  `id` int(255) NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=8 ;

--
-- Dumping data for table `valid_working_groups`
--

INSERT INTO `valid_working_groups` (`group`, `id`) VALUES
('Chemical Screens', 1),
('Genetic Screens', 2),
('Lung', 3),
('Breast', 4),
('Melanoma', 5),
('Colorectal', 6),
('Others', 7);
