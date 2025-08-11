/*M!999999\- enable the sandbox mode */ 
-- MariaDB dump 10.19-11.8.1-MariaDB, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: suomisf
-- ------------------------------------------------------
-- Server version	11.8.1-MariaDB-4

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*M!100616 SET @OLD_NOTE_VERBOSITY=@@NOTE_VERBOSITY, NOTE_VERBOSITY=0 */;

--
-- Table structure for table `Log`
--

DROP TABLE IF EXISTS `Log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `Log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `table_name` varchar(30) DEFAULT NULL,
  `field_name` varchar(30) DEFAULT NULL,
  `table_id` int(11) DEFAULT NULL,
  `object_name` varchar(200) DEFAULT NULL,
  `action` varchar(30) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `old_value` varchar(500) DEFAULT NULL,
  `date` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `ix_Log_table_name` (`table_name`),
  CONSTRAINT `Log_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=120551 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `alias`
--

DROP TABLE IF EXISTS `alias`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `alias` (
  `alias` int(11) NOT NULL,
  `realname` int(11) NOT NULL,
  PRIMARY KEY (`alias`,`realname`),
  KEY `realname` (`realname`),
  CONSTRAINT `alias_ibfk_1` FOREIGN KEY (`alias`) REFERENCES `person` (`id`),
  CONSTRAINT `alias_ibfk_2` FOREIGN KEY (`realname`) REFERENCES `person` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `article`
--

DROP TABLE IF EXISTS `article`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `article` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(200) NOT NULL,
  `person` varchar(200) DEFAULT NULL,
  `excerpt` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_article_title` (`title`)
) ENGINE=InnoDB AUTO_INCREMENT=3252 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `articleauthor`
--

DROP TABLE IF EXISTS `articleauthor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `articleauthor` (
  `article_id` int(11) NOT NULL,
  `person_id` int(11) NOT NULL,
  PRIMARY KEY (`article_id`,`person_id`),
  KEY `person_id` (`person_id`),
  CONSTRAINT `articleauthor_ibfk_1` FOREIGN KEY (`article_id`) REFERENCES `article` (`id`),
  CONSTRAINT `articleauthor_ibfk_2` FOREIGN KEY (`person_id`) REFERENCES `person` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `articlelink`
--

DROP TABLE IF EXISTS `articlelink`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `articlelink` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `article_id` int(11) DEFAULT NULL,
  `link` varchar(250) NOT NULL,
  `description` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `article_id` (`article_id`),
  CONSTRAINT `articlelink_ibfk_1` FOREIGN KEY (`article_id`) REFERENCES `article` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `articleperson`
--

DROP TABLE IF EXISTS `articleperson`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `articleperson` (
  `article_id` int(11) NOT NULL,
  `person_id` int(11) NOT NULL,
  PRIMARY KEY (`article_id`,`person_id`),
  KEY `person_id` (`person_id`),
  CONSTRAINT `articleperson_ibfk_1` FOREIGN KEY (`article_id`) REFERENCES `article` (`id`),
  CONSTRAINT `articleperson_ibfk_2` FOREIGN KEY (`person_id`) REFERENCES `person` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `articletag`
--

DROP TABLE IF EXISTS `articletag`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `articletag` (
  `article_id` int(11) NOT NULL,
  `tag_id` int(11) NOT NULL,
  PRIMARY KEY (`article_id`,`tag_id`),
  KEY `tag_id` (`tag_id`),
  CONSTRAINT `articletag_ibfk_1` FOREIGN KEY (`article_id`) REFERENCES `article` (`id`),
  CONSTRAINT `articletag_ibfk_2` FOREIGN KEY (`tag_id`) REFERENCES `tag` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `award`
--

DROP TABLE IF EXISTS `award`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `award` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `domestic` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `CONSTRAINT_1` CHECK (`domestic` in (0,1))
) ENGINE=InnoDB AUTO_INCREMENT=35 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `awardcategories`
--

DROP TABLE IF EXISTS `awardcategories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `awardcategories` (
  `award_id` int(11) NOT NULL,
  `category_id` int(11) NOT NULL,
  PRIMARY KEY (`award_id`,`category_id`),
  KEY `category_id` (`category_id`),
  CONSTRAINT `awardcategories_ibfk_1` FOREIGN KEY (`award_id`) REFERENCES `award` (`id`),
  CONSTRAINT `awardcategories_ibfk_2` FOREIGN KEY (`category_id`) REFERENCES `awardcategory` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `awardcategory`
--

DROP TABLE IF EXISTS `awardcategory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `awardcategory` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `type` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=30 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `awarded`
--

DROP TABLE IF EXISTS `awarded`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `awarded` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `year` int(11) DEFAULT NULL,
  `award_id` int(11) DEFAULT NULL,
  `category_id` int(11) DEFAULT NULL,
  `person_id` int(11) DEFAULT NULL,
  `work_id` int(11) DEFAULT NULL,
  `story_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `award_id` (`award_id`),
  KEY `category_id` (`category_id`),
  KEY `person_id` (`person_id`),
  KEY `work_id` (`work_id`),
  KEY `story_id` (`story_id`),
  CONSTRAINT `awarded_ibfk_1` FOREIGN KEY (`award_id`) REFERENCES `award` (`id`),
  CONSTRAINT `awarded_ibfk_2` FOREIGN KEY (`category_id`) REFERENCES `awardcategory` (`id`),
  CONSTRAINT `awarded_ibfk_3` FOREIGN KEY (`person_id`) REFERENCES `person` (`id`),
  CONSTRAINT `awarded_ibfk_4` FOREIGN KEY (`work_id`) REFERENCES `work` (`id`),
  CONSTRAINT `awarded_ibfk_5` FOREIGN KEY (`story_id`) REFERENCES `shortstory` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=882 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `bindingtype`
--

DROP TABLE IF EXISTS `bindingtype`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `bindingtype` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `bookcondition`
--

DROP TABLE IF EXISTS `bookcondition`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `bookcondition` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(20) NOT NULL,
  `value` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `bookseries`
--

DROP TABLE IF EXISTS `bookseries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `bookseries` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(250) NOT NULL,
  `orig_name` varchar(250) DEFAULT NULL,
  `important` tinyint(1) DEFAULT NULL,
  `image_src` varchar(100) DEFAULT NULL,
  `image_attr` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_bookseries_name` (`name`),
  CONSTRAINT `CONSTRAINT_1` CHECK (`important` in (0,1))
) ENGINE=InnoDB AUTO_INCREMENT=778 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `bookserieslink`
--

DROP TABLE IF EXISTS `bookserieslink`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `bookserieslink` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `bookseries_id` int(11) NOT NULL,
  `link` varchar(200) NOT NULL,
  `description` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `bookseries_id` (`bookseries_id`),
  CONSTRAINT `bookserieslink_ibfk_1` FOREIGN KEY (`bookseries_id`) REFERENCES `bookseries` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `contributor`
--

DROP TABLE IF EXISTS `contributor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `contributor` (
  `part_id` int(11) NOT NULL,
  `person_id` int(11) NOT NULL,
  `role_id` int(11) NOT NULL,
  `real_person_id` int(11) DEFAULT NULL,
  `description` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`part_id`,`person_id`,`role_id`),
  KEY `person_id` (`person_id`),
  KEY `role_id` (`role_id`),
  KEY `real_person_id` (`real_person_id`),
  KEY `part_id` (`part_id`),
  CONSTRAINT `contributor_ibfk_1` FOREIGN KEY (`part_id`) REFERENCES `part` (`id`),
  CONSTRAINT `contributor_ibfk_2` FOREIGN KEY (`person_id`) REFERENCES `person` (`id`),
  CONSTRAINT `contributor_ibfk_3` FOREIGN KEY (`role_id`) REFERENCES `contributorrole` (`id`),
  CONSTRAINT `contributor_ibfk_4` FOREIGN KEY (`real_person_id`) REFERENCES `person` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `contributorrole`
--

DROP TABLE IF EXISTS `contributorrole`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `contributorrole` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `country`
--

DROP TABLE IF EXISTS `country`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `country` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_country_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=67 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `edition`
--

DROP TABLE IF EXISTS `edition`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `edition` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(500) NOT NULL,
  `subtitle` varchar(500) DEFAULT NULL,
  `pubyear` int(11) NOT NULL,
  `publisher_id` int(11) DEFAULT NULL,
  `editionnum` int(11) DEFAULT NULL,
  `version` int(11) DEFAULT NULL,
  `isbn` varchar(20) DEFAULT NULL,
  `printedin` varchar(50) DEFAULT NULL,
  `pubseries_id` int(11) DEFAULT NULL,
  `pubseriesnum` int(11) DEFAULT NULL,
  `coll_info` varchar(200) DEFAULT NULL,
  `pages` int(11) DEFAULT NULL,
  `binding_id` int(11) DEFAULT NULL,
  `format_id` int(11) DEFAULT NULL,
  `size` int(11) DEFAULT NULL,
  `dustcover` int(11) DEFAULT NULL,
  `coverimage` int(11) DEFAULT NULL,
  `misc` varchar(500) DEFAULT NULL,
  `imported_string` varchar(500) DEFAULT NULL,
  `verified` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `pubseries_id` (`pubseries_id`),
  KEY `binding_id` (`binding_id`),
  KEY `format_id` (`format_id`),
  KEY `ix_edition_title` (`title`),
  KEY `ix_edition_publisher_id` (`publisher_id`),
  KEY `ix_edition_pubyear` (`pubyear`),
  CONSTRAINT `edition_ibfk_1` FOREIGN KEY (`publisher_id`) REFERENCES `publisher` (`id`),
  CONSTRAINT `edition_ibfk_2` FOREIGN KEY (`pubseries_id`) REFERENCES `pubseries` (`id`),
  CONSTRAINT `edition_ibfk_3` FOREIGN KEY (`binding_id`) REFERENCES `bindingtype` (`id`),
  CONSTRAINT `edition_ibfk_4` FOREIGN KEY (`format_id`) REFERENCES `format` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9093 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `editionimage`
--

DROP TABLE IF EXISTS `editionimage`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `editionimage` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `edition_id` int(11) NOT NULL,
  `image_src` varchar(200) NOT NULL,
  `image_attr` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `edition_id` (`edition_id`),
  CONSTRAINT `editionimage_ibfk_1` FOREIGN KEY (`edition_id`) REFERENCES `edition` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8444 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `editionlink`
--

DROP TABLE IF EXISTS `editionlink`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `editionlink` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `edition_id` int(11) NOT NULL,
  `link` varchar(200) NOT NULL,
  `description` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `edition_id` (`edition_id`),
  CONSTRAINT `editionlink_ibfk_1` FOREIGN KEY (`edition_id`) REFERENCES `edition` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `editionprice`
--

DROP TABLE IF EXISTS `editionprice`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `editionprice` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `edition_id` int(11) NOT NULL,
  `date` date NOT NULL,
  `condition_id` int(11) DEFAULT NULL,
  `price` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `edition_id` (`edition_id`),
  KEY `condition_id` (`condition_id`),
  CONSTRAINT `editionprice_ibfk_1` FOREIGN KEY (`edition_id`) REFERENCES `edition` (`id`),
  CONSTRAINT `editionprice_ibfk_2` FOREIGN KEY (`condition_id`) REFERENCES `bookcondition` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `format`
--

DROP TABLE IF EXISTS `format`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `format` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `genre`
--

DROP TABLE IF EXISTS `genre`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `genre` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) DEFAULT NULL,
  `abbr` varchar(20) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_genre_abbr` (`abbr`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `issue`
--

DROP TABLE IF EXISTS `issue`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `issue` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `magazine_id` int(11) NOT NULL,
  `number` int(11) DEFAULT NULL,
  `number_extra` varchar(20) DEFAULT NULL,
  `count` int(11) DEFAULT NULL,
  `year` int(11) DEFAULT NULL,
  `cover_number` varchar(100) DEFAULT NULL,
  `image_src` varchar(200) DEFAULT NULL,
  `image_attr` varchar(100) DEFAULT NULL,
  `pages` int(11) DEFAULT NULL,
  `size_id` int(11) DEFAULT NULL,
  `link` varchar(200) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `title` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `magazine_id` (`magazine_id`),
  KEY `size_id` (`size_id`),
  KEY `ix_issue_year` (`year`),
  KEY `ix_issue_number` (`number`),
  CONSTRAINT `issue_ibfk_1` FOREIGN KEY (`magazine_id`) REFERENCES `magazine` (`id`),
  CONSTRAINT `issue_ibfk_2` FOREIGN KEY (`size_id`) REFERENCES `publicationsize` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=909 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `issuecontent`
--

DROP TABLE IF EXISTS `issuecontent`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `issuecontent` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `issue_id` int(11) NOT NULL,
  `article_id` int(11) DEFAULT NULL,
  `shortstory_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `issue_id` (`issue_id`),
  KEY `article_id` (`article_id`),
  KEY `shortstory_id` (`shortstory_id`),
  CONSTRAINT `issuecontent_ibfk_1` FOREIGN KEY (`issue_id`) REFERENCES `issue` (`id`),
  CONSTRAINT `issuecontent_ibfk_2` FOREIGN KEY (`article_id`) REFERENCES `article` (`id`),
  CONSTRAINT `issuecontent_ibfk_3` FOREIGN KEY (`shortstory_id`) REFERENCES `shortstory` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6289 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `issueeditor`
--

DROP TABLE IF EXISTS `issueeditor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `issueeditor` (
  `issue_id` int(11) NOT NULL,
  `person_id` int(11) NOT NULL,
  PRIMARY KEY (`issue_id`,`person_id`),
  KEY `person_id` (`person_id`),
  CONSTRAINT `issueeditor_ibfk_1` FOREIGN KEY (`issue_id`) REFERENCES `issue` (`id`),
  CONSTRAINT `issueeditor_ibfk_2` FOREIGN KEY (`person_id`) REFERENCES `person` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `issuetag`
--

DROP TABLE IF EXISTS `issuetag`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `issuetag` (
  `issue_id` int(11) NOT NULL,
  `tag_id` int(11) NOT NULL,
  PRIMARY KEY (`issue_id`,`tag_id`),
  KEY `tag_id` (`tag_id`),
  CONSTRAINT `issuetag_ibfk_1` FOREIGN KEY (`issue_id`) REFERENCES `issue` (`id`),
  CONSTRAINT `issuetag_ibfk_2` FOREIGN KEY (`tag_id`) REFERENCES `tag` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `language`
--

DROP TABLE IF EXISTS `language`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `language` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_language_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=52 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `magazine`
--

DROP TABLE IF EXISTS `magazine`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `magazine` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(200) NOT NULL,
  `publisher_id` int(11) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `link` varchar(200) DEFAULT NULL,
  `issn` varchar(30) DEFAULT NULL,
  `type_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `publisher_id` (`publisher_id`),
  KEY `ix_magazine_name` (`name`),
  KEY `type_id` (`type_id`),
  CONSTRAINT `magazine_ibfk_1` FOREIGN KEY (`publisher_id`) REFERENCES `publisher` (`id`),
  CONSTRAINT `magazine_ibfk_2` FOREIGN KEY (`type_id`) REFERENCES `magazinetype` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=55 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `magazinetag`
--

DROP TABLE IF EXISTS `magazinetag`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `magazinetag` (
  `magazine_id` int(11) NOT NULL,
  `tag_id` int(11) NOT NULL,
  PRIMARY KEY (`magazine_id`,`tag_id`),
  KEY `tag_id` (`tag_id`),
  CONSTRAINT `magazinetag_ibfk_1` FOREIGN KEY (`magazine_id`) REFERENCES `magazine` (`id`),
  CONSTRAINT `magazinetag_ibfk_2` FOREIGN KEY (`tag_id`) REFERENCES `tag` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `magazinetype`
--

DROP TABLE IF EXISTS `magazinetype`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `magazinetype` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `part`
--

DROP TABLE IF EXISTS `part`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `part` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `edition_id` int(11) DEFAULT NULL,
  `work_id` int(11) DEFAULT NULL,
  `shortstory_id` int(11) DEFAULT NULL,
  `order_num` int(11) DEFAULT NULL,
  `title` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_part_work_id` (`work_id`),
  KEY `ix_part_edition_id` (`edition_id`),
  KEY `ix_part_shortstory_id` (`shortstory_id`),
  CONSTRAINT `part_ibfk_1` FOREIGN KEY (`edition_id`) REFERENCES `edition` (`id`),
  CONSTRAINT `part_ibfk_2` FOREIGN KEY (`work_id`) REFERENCES `work` (`id`),
  CONSTRAINT `part_ibfk_3` FOREIGN KEY (`shortstory_id`) REFERENCES `shortstory` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=25043 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `person`
--

DROP TABLE IF EXISTS `person`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `person` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(250) NOT NULL,
  `alt_name` varchar(250) DEFAULT NULL,
  `fullname` varchar(250) DEFAULT NULL,
  `other_names` text DEFAULT NULL,
  `first_name` varchar(100) DEFAULT NULL,
  `last_name` varchar(150) DEFAULT NULL,
  `image_src` varchar(100) DEFAULT NULL,
  `image_attr` varchar(100) DEFAULT NULL,
  `dob` int(11) DEFAULT NULL,
  `dod` int(11) DEFAULT NULL,
  `bio` text DEFAULT NULL,
  `bio_src` varchar(100) DEFAULT NULL,
  `nationality_id` int(11) DEFAULT NULL,
  `imported_string` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_person_name` (`name`),
  KEY `ix_person_nationality_id` (`nationality_id`),
  KEY `ix_person_alt_name` (`alt_name`),
  CONSTRAINT `person_ibfk_1` FOREIGN KEY (`nationality_id`) REFERENCES `country` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6865 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `personlanguage`
--

DROP TABLE IF EXISTS `personlanguage`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `personlanguage` (
  `person_id` int(11) NOT NULL,
  `language_id` int(11) NOT NULL,
  PRIMARY KEY (`person_id`,`language_id`),
  KEY `language_id` (`language_id`),
  CONSTRAINT `personlanguage_ibfk_1` FOREIGN KEY (`person_id`) REFERENCES `person` (`id`),
  CONSTRAINT `personlanguage_ibfk_2` FOREIGN KEY (`language_id`) REFERENCES `language` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `personlink`
--

DROP TABLE IF EXISTS `personlink`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `personlink` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `person_id` int(11) NOT NULL,
  `link` varchar(200) NOT NULL,
  `description` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `person_id` (`person_id`),
  CONSTRAINT `personlink_ibfk_1` FOREIGN KEY (`person_id`) REFERENCES `person` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=21115 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `persontag`
--

DROP TABLE IF EXISTS `persontag`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `persontag` (
  `person_id` int(11) NOT NULL,
  `tag_id` int(11) NOT NULL,
  PRIMARY KEY (`person_id`,`tag_id`),
  KEY `tag_id` (`tag_id`),
  CONSTRAINT `persontag_ibfk_1` FOREIGN KEY (`person_id`) REFERENCES `person` (`id`),
  CONSTRAINT `persontag_ibfk_2` FOREIGN KEY (`tag_id`) REFERENCES `tag` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `personworks`
--

DROP TABLE IF EXISTS `personworks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `personworks` (
  `person_id` int(11) NOT NULL,
  `work.id` int(11) NOT NULL,
  PRIMARY KEY (`person_id`,`work.id`),
  KEY `work.id` (`work.id`),
  CONSTRAINT `personworks_ibfk_1` FOREIGN KEY (`person_id`) REFERENCES `person` (`id`),
  CONSTRAINT `personworks_ibfk_2` FOREIGN KEY (`work.id`) REFERENCES `work` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `problems`
--

DROP TABLE IF EXISTS `problems`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `problems` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `status` varchar(20) DEFAULT NULL,
  `comment` text DEFAULT NULL,
  `table_name` varchar(50) DEFAULT NULL,
  `table_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `publicationsize`
--

DROP TABLE IF EXISTS `publicationsize`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `publicationsize` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `mm_width` int(11) DEFAULT NULL,
  `mm_height` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=40 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `publisher`
--

DROP TABLE IF EXISTS `publisher`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `publisher` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(500) NOT NULL,
  `fullname` varchar(500) NOT NULL,
  `description` text DEFAULT NULL,
  `image_src` varchar(100) DEFAULT NULL,
  `image_attr` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `fullname` (`fullname`),
  UNIQUE KEY `ix_publisher_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=483 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `publisherlink`
--

DROP TABLE IF EXISTS `publisherlink`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `publisherlink` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `publisher_id` int(11) NOT NULL,
  `link` varchar(200) NOT NULL,
  `description` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `publisher_id` (`publisher_id`),
  CONSTRAINT `publisherlink_ibfk_1` FOREIGN KEY (`publisher_id`) REFERENCES `publisher` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=76 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pubseries`
--

DROP TABLE IF EXISTS `pubseries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `pubseries` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(250) NOT NULL,
  `publisher_id` int(11) NOT NULL,
  `important` tinyint(1) DEFAULT NULL,
  `image_src` varchar(100) DEFAULT NULL,
  `image_attr` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `publisher_id` (`publisher_id`),
  CONSTRAINT `pubseries_ibfk_1` FOREIGN KEY (`publisher_id`) REFERENCES `publisher` (`id`),
  CONSTRAINT `CONSTRAINT_1` CHECK (`important` in (0,1))
) ENGINE=InnoDB AUTO_INCREMENT=294 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pubserieslink`
--

DROP TABLE IF EXISTS `pubserieslink`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `pubserieslink` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `pubseries_id` int(11) NOT NULL,
  `link` varchar(200) NOT NULL,
  `description` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `pubseries_id` (`pubseries_id`),
  CONSTRAINT `pubserieslink_ibfk_1` FOREIGN KEY (`pubseries_id`) REFERENCES `pubseries` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `shortstory`
--

DROP TABLE IF EXISTS `shortstory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `shortstory` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(700) NOT NULL,
  `orig_title` varchar(700) DEFAULT NULL,
  `language` int(11) DEFAULT NULL,
  `pubyear` int(11) DEFAULT NULL,
  `story_type` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `language` (`language`),
  KEY `story_type` (`story_type`),
  KEY `ix_shortstory_pubyear` (`pubyear`),
  KEY `ix_shortstory_title` (`title`),
  CONSTRAINT `shortstory_ibfk_1` FOREIGN KEY (`language`) REFERENCES `language` (`id`),
  CONSTRAINT `shortstory_ibfk_2` FOREIGN KEY (`story_type`) REFERENCES `storytype` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=12493 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `storygenre`
--

DROP TABLE IF EXISTS `storygenre`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `storygenre` (
  `shortstory_id` int(11) NOT NULL,
  `genre_id` int(11) NOT NULL,
  PRIMARY KEY (`shortstory_id`,`genre_id`),
  KEY `genre_id` (`genre_id`),
  CONSTRAINT `storygenre_ibfk_1` FOREIGN KEY (`shortstory_id`) REFERENCES `shortstory` (`id`),
  CONSTRAINT `storygenre_ibfk_2` FOREIGN KEY (`genre_id`) REFERENCES `genre` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `storytag`
--

DROP TABLE IF EXISTS `storytag`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `storytag` (
  `shortstory_id` int(11) NOT NULL,
  `tag_id` int(11) NOT NULL,
  PRIMARY KEY (`shortstory_id`,`tag_id`),
  KEY `tag_id` (`tag_id`),
  CONSTRAINT `storytag_ibfk_1` FOREIGN KEY (`shortstory_id`) REFERENCES `shortstory` (`id`),
  CONSTRAINT `storytag_ibfk_2` FOREIGN KEY (`tag_id`) REFERENCES `tag` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `storytype`
--

DROP TABLE IF EXISTS `storytype`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `storytype` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(30) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tag`
--

DROP TABLE IF EXISTS `tag`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tag` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `type` varchar(100) DEFAULT NULL,
  `type_id` int(11) NOT NULL DEFAULT 1,
  `description` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_tag_name` (`name`),
  KEY `fk_type_id` (`type_id`),
  CONSTRAINT `fk_type_id` FOREIGN KEY (`type_id`) REFERENCES `tagtype` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2725 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tagtype`
--

DROP TABLE IF EXISTS `tagtype`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tagtype` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user`
--

DROP TABLE IF EXISTS `user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `user` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(64) DEFAULT NULL,
  `password_hash` varchar(256) DEFAULT NULL,
  `is_admin` tinyint(1) DEFAULT NULL,
  `language` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_user_name` (`name`),
  KEY `language` (`language`),
  CONSTRAINT `user_ibfk_1` FOREIGN KEY (`language`) REFERENCES `language` (`id`),
  CONSTRAINT `CONSTRAINT_1` CHECK (`is_admin` in (0,1))
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `userbook`
--

DROP TABLE IF EXISTS `userbook`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `userbook` (
  `edition_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `condition_id` int(11) DEFAULT NULL,
  `description` varchar(100) DEFAULT NULL,
  `price` int(11) DEFAULT NULL,
  `added` datetime DEFAULT NULL,
  PRIMARY KEY (`edition_id`,`user_id`),
  KEY `user_id` (`user_id`),
  KEY `condition_id` (`condition_id`),
  CONSTRAINT `userbook_ibfk_1` FOREIGN KEY (`edition_id`) REFERENCES `edition` (`id`),
  CONSTRAINT `userbook_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`),
  CONSTRAINT `userbook_ibfk_3` FOREIGN KEY (`condition_id`) REFERENCES `bookcondition` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `userbookseries`
--

DROP TABLE IF EXISTS `userbookseries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `userbookseries` (
  `user_id` int(11) NOT NULL,
  `series_id` int(11) NOT NULL,
  PRIMARY KEY (`user_id`,`series_id`),
  KEY `series_id` (`series_id`),
  CONSTRAINT `userbookseries_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`),
  CONSTRAINT `userbookseries_ibfk_2` FOREIGN KEY (`series_id`) REFERENCES `bookseries` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `userpubseries`
--

DROP TABLE IF EXISTS `userpubseries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `userpubseries` (
  `user_id` int(11) NOT NULL,
  `series_id` int(11) NOT NULL,
  PRIMARY KEY (`user_id`,`series_id`),
  KEY `series_id` (`series_id`),
  CONSTRAINT `userpubseries_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`),
  CONSTRAINT `userpubseries_ibfk_2` FOREIGN KEY (`series_id`) REFERENCES `pubseries` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `work`
--

DROP TABLE IF EXISTS `work`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `work` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(500) NOT NULL,
  `subtitle` varchar(500) DEFAULT NULL,
  `orig_title` varchar(500) DEFAULT NULL,
  `pubyear` int(11) DEFAULT NULL,
  `language` int(11) DEFAULT NULL,
  `bookseries_id` int(11) DEFAULT NULL,
  `bookseriesnum` varchar(20) DEFAULT NULL,
  `bookseriesorder` int(11) DEFAULT NULL,
  `type` int(11) DEFAULT NULL,
  `misc` varchar(500) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `descr_attr` varchar(200) DEFAULT NULL,
  `imported_string` varchar(500) DEFAULT NULL,
  `author_str` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `bookseries_id` (`bookseries_id`),
  KEY `ix_work_pubyear` (`pubyear`),
  KEY `ix_work_language` (`language`),
  KEY `ix_work_orig_title` (`orig_title`),
  KEY `ix_work_title` (`title`),
  KEY `ix_work_type` (`type`),
  CONSTRAINT `work_ibfk_1` FOREIGN KEY (`language`) REFERENCES `language` (`id`),
  CONSTRAINT `work_ibfk_2` FOREIGN KEY (`bookseries_id`) REFERENCES `bookseries` (`id`),
  CONSTRAINT `work_ibfk_3` FOREIGN KEY (`type`) REFERENCES `worktype` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6545 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `workgenre`
--

DROP TABLE IF EXISTS `workgenre`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `workgenre` (
  `work_id` int(11) NOT NULL,
  `genre_id` int(11) NOT NULL,
  PRIMARY KEY (`work_id`,`genre_id`),
  KEY `genre_id` (`genre_id`),
  CONSTRAINT `workgenre_ibfk_1` FOREIGN KEY (`work_id`) REFERENCES `work` (`id`),
  CONSTRAINT `workgenre_ibfk_2` FOREIGN KEY (`genre_id`) REFERENCES `genre` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `worklink`
--

DROP TABLE IF EXISTS `worklink`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `worklink` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `work_id` int(11) NOT NULL,
  `link` varchar(200) NOT NULL,
  `description` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `work_id` (`work_id`),
  CONSTRAINT `worklink_ibfk_1` FOREIGN KEY (`work_id`) REFERENCES `work` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5508 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `workreview`
--

DROP TABLE IF EXISTS `workreview`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `workreview` (
  `work_id` int(11) NOT NULL,
  `article_id` int(11) NOT NULL,
  PRIMARY KEY (`work_id`,`article_id`),
  KEY `article_id` (`article_id`),
  CONSTRAINT `workreview_ibfk_1` FOREIGN KEY (`work_id`) REFERENCES `work` (`id`),
  CONSTRAINT `workreview_ibfk_2` FOREIGN KEY (`article_id`) REFERENCES `article` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `worktag`
--

DROP TABLE IF EXISTS `worktag`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `worktag` (
  `work_id` int(11) NOT NULL,
  `tag_id` int(11) NOT NULL,
  PRIMARY KEY (`work_id`,`tag_id`),
  KEY `tag_id` (`tag_id`),
  CONSTRAINT `worktag_ibfk_1` FOREIGN KEY (`work_id`) REFERENCES `work` (`id`),
  CONSTRAINT `worktag_ibfk_2` FOREIGN KEY (`tag_id`) REFERENCES `tag` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `worktype`
--

DROP TABLE IF EXISTS `worktype`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `worktype` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_worktype_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*M!100616 SET NOTE_VERBOSITY=@OLD_NOTE_VERBOSITY */;

-- Dump completed on 2025-07-05 16:55:39
