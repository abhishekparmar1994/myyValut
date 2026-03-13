-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Mar 13, 2026 at 01:54 PM
-- Server version: 5.7.36
-- PHP Version: 8.3.23

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `user_db`
--

-- --------------------------------------------------------

--
-- Table structure for table `bills`
--

CREATE TABLE `bills` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `category` enum('electricity','water','gas','internet','phone','credit_card','insurance','emi','other') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'other',
  `amount` decimal(10,2) DEFAULT NULL,
  `due_day` tinyint(4) NOT NULL,
  `auto_renews` tinyint(1) NOT NULL DEFAULT '1',
  `last_paid_at` date DEFAULT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `cache`
--

CREATE TABLE `cache` (
  `key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `value` mediumtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiration` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `cache_locks`
--

CREATE TABLE `cache_locks` (
  `key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `owner` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiration` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `documents`
--

CREATE TABLE `documents` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `category` enum('identity','property','general','bills') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'general',
  `document_type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_path` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `mime_type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_size` bigint(20) UNSIGNED NOT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `failed_jobs`
--

CREATE TABLE `failed_jobs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `uuid` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `connection` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `queue` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `exception` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `jobs`
--

CREATE TABLE `jobs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `queue` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `attempts` tinyint(3) UNSIGNED NOT NULL,
  `reserved_at` int(10) UNSIGNED DEFAULT NULL,
  `available_at` int(10) UNSIGNED NOT NULL,
  `created_at` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `jobs`
--

INSERT INTO `jobs` (`id`, `queue`, `payload`, `attempts`, `reserved_at`, `available_at`, `created_at`) VALUES
(1, 'default', '{\"uuid\":\"da00267b-ec78-4b62-848f-5d372fb32de0\",\"displayName\":\"App\\\\Events\\\\UserBlockToggled\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"Illuminate\\\\Broadcasting\\\\BroadcastEvent\",\"command\":\"O:38:\\\"Illuminate\\\\Broadcasting\\\\BroadcastEvent\\\":17:{s:5:\\\"event\\\";O:27:\\\"App\\\\Events\\\\UserBlockToggled\\\":3:{s:9:\\\"blockerId\\\";i:6;s:9:\\\"blockedId\\\";i:1;s:6:\\\"status\\\";s:7:\\\"blocked\\\";}s:5:\\\"tries\\\";N;s:7:\\\"timeout\\\";N;s:7:\\\"backoff\\\";N;s:13:\\\"maxExceptions\\\";N;s:23:\\\"deleteWhenMissingModels\\\";b:1;s:10:\\\"connection\\\";N;s:5:\\\"queue\\\";N;s:12:\\\"messageGroup\\\";N;s:12:\\\"deduplicator\\\";N;s:5:\\\"delay\\\";N;s:11:\\\"afterCommit\\\";N;s:10:\\\"middleware\\\";a:0:{}s:7:\\\"chained\\\";a:0:{}s:15:\\\"chainConnection\\\";N;s:10:\\\"chainQueue\\\";N;s:19:\\\"chainCatchCallbacks\\\";N;}\",\"batchId\":null},\"createdAt\":1773396807,\"delay\":null}', 0, NULL, 1773396807, 1773396807),
(2, 'default', '{\"uuid\":\"38d0d4a2-abb0-4829-b6be-7b0f3a5ae9d5\",\"displayName\":\"App\\\\Events\\\\UserBlockToggled\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"Illuminate\\\\Broadcasting\\\\BroadcastEvent\",\"command\":\"O:38:\\\"Illuminate\\\\Broadcasting\\\\BroadcastEvent\\\":17:{s:5:\\\"event\\\";O:27:\\\"App\\\\Events\\\\UserBlockToggled\\\":3:{s:9:\\\"blockerId\\\";i:6;s:9:\\\"blockedId\\\";i:1;s:6:\\\"status\\\";s:9:\\\"unblocked\\\";}s:5:\\\"tries\\\";N;s:7:\\\"timeout\\\";N;s:7:\\\"backoff\\\";N;s:13:\\\"maxExceptions\\\";N;s:23:\\\"deleteWhenMissingModels\\\";b:1;s:10:\\\"connection\\\";N;s:5:\\\"queue\\\";N;s:12:\\\"messageGroup\\\";N;s:12:\\\"deduplicator\\\";N;s:5:\\\"delay\\\";N;s:11:\\\"afterCommit\\\";N;s:10:\\\"middleware\\\";a:0:{}s:7:\\\"chained\\\";a:0:{}s:15:\\\"chainConnection\\\";N;s:10:\\\"chainQueue\\\";N;s:19:\\\"chainCatchCallbacks\\\";N;}\",\"batchId\":null},\"createdAt\":1773396852,\"delay\":null}', 0, NULL, 1773396852, 1773396852),
(3, 'default', '{\"uuid\":\"75791ac4-77a9-4391-a594-3a3543784ebf\",\"displayName\":\"App\\\\Events\\\\UserBlockToggled\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"Illuminate\\\\Broadcasting\\\\BroadcastEvent\",\"command\":\"O:38:\\\"Illuminate\\\\Broadcasting\\\\BroadcastEvent\\\":17:{s:5:\\\"event\\\";O:27:\\\"App\\\\Events\\\\UserBlockToggled\\\":3:{s:9:\\\"blockerId\\\";i:6;s:9:\\\"blockedId\\\";i:1;s:6:\\\"status\\\";s:7:\\\"blocked\\\";}s:5:\\\"tries\\\";N;s:7:\\\"timeout\\\";N;s:7:\\\"backoff\\\";N;s:13:\\\"maxExceptions\\\";N;s:23:\\\"deleteWhenMissingModels\\\";b:1;s:10:\\\"connection\\\";N;s:5:\\\"queue\\\";N;s:12:\\\"messageGroup\\\";N;s:12:\\\"deduplicator\\\";N;s:5:\\\"delay\\\";N;s:11:\\\"afterCommit\\\";N;s:10:\\\"middleware\\\";a:0:{}s:7:\\\"chained\\\";a:0:{}s:15:\\\"chainConnection\\\";N;s:10:\\\"chainQueue\\\";N;s:19:\\\"chainCatchCallbacks\\\";N;}\",\"batchId\":null},\"createdAt\":1773397075,\"delay\":null}', 0, NULL, 1773397075, 1773397075),
(4, 'default', '{\"uuid\":\"522564dc-be8b-472b-a346-f9de6c9fc2eb\",\"displayName\":\"App\\\\Events\\\\UserBlockToggled\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"Illuminate\\\\Broadcasting\\\\BroadcastEvent\",\"command\":\"O:38:\\\"Illuminate\\\\Broadcasting\\\\BroadcastEvent\\\":17:{s:5:\\\"event\\\";O:27:\\\"App\\\\Events\\\\UserBlockToggled\\\":3:{s:9:\\\"blockerId\\\";i:6;s:9:\\\"blockedId\\\";i:1;s:6:\\\"status\\\";s:9:\\\"unblocked\\\";}s:5:\\\"tries\\\";N;s:7:\\\"timeout\\\";N;s:7:\\\"backoff\\\";N;s:13:\\\"maxExceptions\\\";N;s:23:\\\"deleteWhenMissingModels\\\";b:1;s:10:\\\"connection\\\";N;s:5:\\\"queue\\\";N;s:12:\\\"messageGroup\\\";N;s:12:\\\"deduplicator\\\";N;s:5:\\\"delay\\\";N;s:11:\\\"afterCommit\\\";N;s:10:\\\"middleware\\\";a:0:{}s:7:\\\"chained\\\";a:0:{}s:15:\\\"chainConnection\\\";N;s:10:\\\"chainQueue\\\";N;s:19:\\\"chainCatchCallbacks\\\";N;}\",\"batchId\":null},\"createdAt\":1773397110,\"delay\":null}', 0, NULL, 1773397110, 1773397110),
(5, 'default', '{\"uuid\":\"7bf911b7-b121-4f27-b653-0bef925bd1b9\",\"displayName\":\"App\\\\Events\\\\SystemNotification\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"Illuminate\\\\Broadcasting\\\\BroadcastEvent\",\"command\":\"O:38:\\\"Illuminate\\\\Broadcasting\\\\BroadcastEvent\\\":17:{s:5:\\\"event\\\";O:29:\\\"App\\\\Events\\\\SystemNotification\\\":2:{s:4:\\\"data\\\";a:4:{s:4:\\\"type\\\";s:16:\\\"reaction_updated\\\";s:9:\\\"messageId\\\";s:2:\\\"72\\\";s:9:\\\"reactions\\\";O:39:\\\"Illuminate\\\\Database\\\\Eloquent\\\\Collection\\\":2:{s:8:\\\"\\u0000*\\u0000items\\\";a:1:{i:0;O:26:\\\"App\\\\Models\\\\MessageReaction\\\":33:{s:13:\\\"\\u0000*\\u0000connection\\\";s:5:\\\"mysql\\\";s:8:\\\"\\u0000*\\u0000table\\\";s:17:\\\"message_reactions\\\";s:13:\\\"\\u0000*\\u0000primaryKey\\\";s:2:\\\"id\\\";s:10:\\\"\\u0000*\\u0000keyType\\\";s:3:\\\"int\\\";s:12:\\\"incrementing\\\";b:1;s:7:\\\"\\u0000*\\u0000with\\\";a:0:{}s:12:\\\"\\u0000*\\u0000withCount\\\";a:0:{}s:19:\\\"preventsLazyLoading\\\";b:0;s:10:\\\"\\u0000*\\u0000perPage\\\";i:15;s:6:\\\"exists\\\";b:1;s:18:\\\"wasRecentlyCreated\\\";b:0;s:28:\\\"\\u0000*\\u0000escapeWhenCastingToString\\\";b:0;s:13:\\\"\\u0000*\\u0000attributes\\\";a:6:{s:2:\\\"id\\\";i:1;s:10:\\\"message_id\\\";i:72;s:7:\\\"user_id\\\";i:6;s:5:\\\"emoji\\\";s:4:\\\"😂\\\";s:10:\\\"created_at\\\";s:19:\\\"2026-03-13 10:45:29\\\";s:10:\\\"updated_at\\\";s:19:\\\"2026-03-13 10:45:29\\\";}s:11:\\\"\\u0000*\\u0000original\\\";a:6:{s:2:\\\"id\\\";i:1;s:10:\\\"message_id\\\";i:72;s:7:\\\"user_id\\\";i:6;s:5:\\\"emoji\\\";s:4:\\\"😂\\\";s:10:\\\"created_at\\\";s:19:\\\"2026-03-13 10:45:29\\\";s:10:\\\"updated_at\\\";s:19:\\\"2026-03-13 10:45:29\\\";}s:10:\\\"\\u0000*\\u0000changes\\\";a:0:{}s:11:\\\"\\u0000*\\u0000previous\\\";a:0:{}s:8:\\\"\\u0000*\\u0000casts\\\";a:0:{}s:17:\\\"\\u0000*\\u0000classCastCache\\\";a:0:{}s:21:\\\"\\u0000*\\u0000attributeCastCache\\\";a:0:{}s:13:\\\"\\u0000*\\u0000dateFormat\\\";N;s:10:\\\"\\u0000*\\u0000appends\\\";a:0:{}s:19:\\\"\\u0000*\\u0000dispatchesEvents\\\";a:0:{}s:14:\\\"\\u0000*\\u0000observables\\\";a:0:{}s:12:\\\"\\u0000*\\u0000relations\\\";a:0:{}s:10:\\\"\\u0000*\\u0000touches\\\";a:0:{}s:27:\\\"\\u0000*\\u0000relationAutoloadCallback\\\";N;s:26:\\\"\\u0000*\\u0000relationAutoloadContext\\\";N;s:10:\\\"timestamps\\\";b:1;s:13:\\\"usesUniqueIds\\\";b:0;s:9:\\\"\\u0000*\\u0000hidden\\\";a:0:{}s:10:\\\"\\u0000*\\u0000visible\\\";a:0:{}s:11:\\\"\\u0000*\\u0000fillable\\\";a:3:{i:0;s:10:\\\"message_id\\\";i:1;s:7:\\\"user_id\\\";i:2;s:5:\\\"emoji\\\";}s:10:\\\"\\u0000*\\u0000guarded\\\";a:1:{i:0;s:1:\\\"*\\\";}}}s:28:\\\"\\u0000*\\u0000escapeWhenCastingToString\\\";b:0;}s:6:\\\"status\\\";s:5:\\\"added\\\";}s:10:\\\"receiverId\\\";i:1;}s:5:\\\"tries\\\";N;s:7:\\\"timeout\\\";N;s:7:\\\"backoff\\\";N;s:13:\\\"maxExceptions\\\";N;s:23:\\\"deleteWhenMissingModels\\\";b:1;s:10:\\\"connection\\\";N;s:5:\\\"queue\\\";N;s:12:\\\"messageGroup\\\";N;s:12:\\\"deduplicator\\\";N;s:5:\\\"delay\\\";N;s:11:\\\"afterCommit\\\";N;s:10:\\\"middleware\\\";a:0:{}s:7:\\\"chained\\\";a:0:{}s:15:\\\"chainConnection\\\";N;s:10:\\\"chainQueue\\\";N;s:19:\\\"chainCatchCallbacks\\\";N;}\",\"batchId\":null},\"createdAt\":1773398729,\"delay\":null}', 0, NULL, 1773398729, 1773398729),
(6, 'default', '{\"uuid\":\"e49af49b-5ed1-4854-8bf3-290076ae91a3\",\"displayName\":\"App\\\\Events\\\\SystemNotification\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"Illuminate\\\\Broadcasting\\\\BroadcastEvent\",\"command\":\"O:38:\\\"Illuminate\\\\Broadcasting\\\\BroadcastEvent\\\":17:{s:5:\\\"event\\\";O:29:\\\"App\\\\Events\\\\SystemNotification\\\":2:{s:4:\\\"data\\\";a:4:{s:4:\\\"type\\\";s:16:\\\"reaction_updated\\\";s:9:\\\"messageId\\\";s:2:\\\"72\\\";s:9:\\\"reactions\\\";O:39:\\\"Illuminate\\\\Database\\\\Eloquent\\\\Collection\\\":2:{s:8:\\\"\\u0000*\\u0000items\\\";a:2:{i:0;O:26:\\\"App\\\\Models\\\\MessageReaction\\\":33:{s:13:\\\"\\u0000*\\u0000connection\\\";s:5:\\\"mysql\\\";s:8:\\\"\\u0000*\\u0000table\\\";s:17:\\\"message_reactions\\\";s:13:\\\"\\u0000*\\u0000primaryKey\\\";s:2:\\\"id\\\";s:10:\\\"\\u0000*\\u0000keyType\\\";s:3:\\\"int\\\";s:12:\\\"incrementing\\\";b:1;s:7:\\\"\\u0000*\\u0000with\\\";a:0:{}s:12:\\\"\\u0000*\\u0000withCount\\\";a:0:{}s:19:\\\"preventsLazyLoading\\\";b:0;s:10:\\\"\\u0000*\\u0000perPage\\\";i:15;s:6:\\\"exists\\\";b:1;s:18:\\\"wasRecentlyCreated\\\";b:0;s:28:\\\"\\u0000*\\u0000escapeWhenCastingToString\\\";b:0;s:13:\\\"\\u0000*\\u0000attributes\\\";a:6:{s:2:\\\"id\\\";i:2;s:10:\\\"message_id\\\";i:72;s:7:\\\"user_id\\\";i:1;s:5:\\\"emoji\\\";s:4:\\\"😂\\\";s:10:\\\"created_at\\\";s:19:\\\"2026-03-13 10:45:41\\\";s:10:\\\"updated_at\\\";s:19:\\\"2026-03-13 10:45:41\\\";}s:11:\\\"\\u0000*\\u0000original\\\";a:6:{s:2:\\\"id\\\";i:2;s:10:\\\"message_id\\\";i:72;s:7:\\\"user_id\\\";i:1;s:5:\\\"emoji\\\";s:4:\\\"😂\\\";s:10:\\\"created_at\\\";s:19:\\\"2026-03-13 10:45:41\\\";s:10:\\\"updated_at\\\";s:19:\\\"2026-03-13 10:45:41\\\";}s:10:\\\"\\u0000*\\u0000changes\\\";a:0:{}s:11:\\\"\\u0000*\\u0000previous\\\";a:0:{}s:8:\\\"\\u0000*\\u0000casts\\\";a:0:{}s:17:\\\"\\u0000*\\u0000classCastCache\\\";a:0:{}s:21:\\\"\\u0000*\\u0000attributeCastCache\\\";a:0:{}s:13:\\\"\\u0000*\\u0000dateFormat\\\";N;s:10:\\\"\\u0000*\\u0000appends\\\";a:0:{}s:19:\\\"\\u0000*\\u0000dispatchesEvents\\\";a:0:{}s:14:\\\"\\u0000*\\u0000observables\\\";a:0:{}s:12:\\\"\\u0000*\\u0000relations\\\";a:0:{}s:10:\\\"\\u0000*\\u0000touches\\\";a:0:{}s:27:\\\"\\u0000*\\u0000relationAutoloadCallback\\\";N;s:26:\\\"\\u0000*\\u0000relationAutoloadContext\\\";N;s:10:\\\"timestamps\\\";b:1;s:13:\\\"usesUniqueIds\\\";b:0;s:9:\\\"\\u0000*\\u0000hidden\\\";a:0:{}s:10:\\\"\\u0000*\\u0000visible\\\";a:0:{}s:11:\\\"\\u0000*\\u0000fillable\\\";a:3:{i:0;s:10:\\\"message_id\\\";i:1;s:7:\\\"user_id\\\";i:2;s:5:\\\"emoji\\\";}s:10:\\\"\\u0000*\\u0000guarded\\\";a:1:{i:0;s:1:\\\"*\\\";}}i:1;O:26:\\\"App\\\\Models\\\\MessageReaction\\\":33:{s:13:\\\"\\u0000*\\u0000connection\\\";s:5:\\\"mysql\\\";s:8:\\\"\\u0000*\\u0000table\\\";s:17:\\\"message_reactions\\\";s:13:\\\"\\u0000*\\u0000primaryKey\\\";s:2:\\\"id\\\";s:10:\\\"\\u0000*\\u0000keyType\\\";s:3:\\\"int\\\";s:12:\\\"incrementing\\\";b:1;s:7:\\\"\\u0000*\\u0000with\\\";a:0:{}s:12:\\\"\\u0000*\\u0000withCount\\\";a:0:{}s:19:\\\"preventsLazyLoading\\\";b:0;s:10:\\\"\\u0000*\\u0000perPage\\\";i:15;s:6:\\\"exists\\\";b:1;s:18:\\\"wasRecentlyCreated\\\";b:0;s:28:\\\"\\u0000*\\u0000escapeWhenCastingToString\\\";b:0;s:13:\\\"\\u0000*\\u0000attributes\\\";a:6:{s:2:\\\"id\\\";i:1;s:10:\\\"message_id\\\";i:72;s:7:\\\"user_id\\\";i:6;s:5:\\\"emoji\\\";s:4:\\\"😂\\\";s:10:\\\"created_at\\\";s:19:\\\"2026-03-13 10:45:29\\\";s:10:\\\"updated_at\\\";s:19:\\\"2026-03-13 10:45:29\\\";}s:11:\\\"\\u0000*\\u0000original\\\";a:6:{s:2:\\\"id\\\";i:1;s:10:\\\"message_id\\\";i:72;s:7:\\\"user_id\\\";i:6;s:5:\\\"emoji\\\";s:4:\\\"😂\\\";s:10:\\\"created_at\\\";s:19:\\\"2026-03-13 10:45:29\\\";s:10:\\\"updated_at\\\";s:19:\\\"2026-03-13 10:45:29\\\";}s:10:\\\"\\u0000*\\u0000changes\\\";a:0:{}s:11:\\\"\\u0000*\\u0000previous\\\";a:0:{}s:8:\\\"\\u0000*\\u0000casts\\\";a:0:{}s:17:\\\"\\u0000*\\u0000classCastCache\\\";a:0:{}s:21:\\\"\\u0000*\\u0000attributeCastCache\\\";a:0:{}s:13:\\\"\\u0000*\\u0000dateFormat\\\";N;s:10:\\\"\\u0000*\\u0000appends\\\";a:0:{}s:19:\\\"\\u0000*\\u0000dispatchesEvents\\\";a:0:{}s:14:\\\"\\u0000*\\u0000observables\\\";a:0:{}s:12:\\\"\\u0000*\\u0000relations\\\";a:0:{}s:10:\\\"\\u0000*\\u0000touches\\\";a:0:{}s:27:\\\"\\u0000*\\u0000relationAutoloadCallback\\\";N;s:26:\\\"\\u0000*\\u0000relationAutoloadContext\\\";N;s:10:\\\"timestamps\\\";b:1;s:13:\\\"usesUniqueIds\\\";b:0;s:9:\\\"\\u0000*\\u0000hidden\\\";a:0:{}s:10:\\\"\\u0000*\\u0000visible\\\";a:0:{}s:11:\\\"\\u0000*\\u0000fillable\\\";a:3:{i:0;s:10:\\\"message_id\\\";i:1;s:7:\\\"user_id\\\";i:2;s:5:\\\"emoji\\\";}s:10:\\\"\\u0000*\\u0000guarded\\\";a:1:{i:0;s:1:\\\"*\\\";}}}s:28:\\\"\\u0000*\\u0000escapeWhenCastingToString\\\";b:0;}s:6:\\\"status\\\";s:5:\\\"added\\\";}s:10:\\\"receiverId\\\";i:6;}s:5:\\\"tries\\\";N;s:7:\\\"timeout\\\";N;s:7:\\\"backoff\\\";N;s:13:\\\"maxExceptions\\\";N;s:23:\\\"deleteWhenMissingModels\\\";b:1;s:10:\\\"connection\\\";N;s:5:\\\"queue\\\";N;s:12:\\\"messageGroup\\\";N;s:12:\\\"deduplicator\\\";N;s:5:\\\"delay\\\";N;s:11:\\\"afterCommit\\\";N;s:10:\\\"middleware\\\";a:0:{}s:7:\\\"chained\\\";a:0:{}s:15:\\\"chainConnection\\\";N;s:10:\\\"chainQueue\\\";N;s:19:\\\"chainCatchCallbacks\\\";N;}\",\"batchId\":null},\"createdAt\":1773398741,\"delay\":null}', 0, NULL, 1773398741, 1773398741),
(7, 'default', '{\"uuid\":\"5c50acf7-ad63-453f-85b7-2080e8eb401b\",\"displayName\":\"App\\\\Events\\\\SystemNotification\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"Illuminate\\\\Broadcasting\\\\BroadcastEvent\",\"command\":\"O:38:\\\"Illuminate\\\\Broadcasting\\\\BroadcastEvent\\\":17:{s:5:\\\"event\\\";O:29:\\\"App\\\\Events\\\\SystemNotification\\\":2:{s:4:\\\"data\\\";a:4:{s:4:\\\"type\\\";s:16:\\\"reaction_updated\\\";s:9:\\\"messageId\\\";s:2:\\\"72\\\";s:9:\\\"reactions\\\";O:39:\\\"Illuminate\\\\Database\\\\Eloquent\\\\Collection\\\":2:{s:8:\\\"\\u0000*\\u0000items\\\";a:1:{i:0;O:26:\\\"App\\\\Models\\\\MessageReaction\\\":33:{s:13:\\\"\\u0000*\\u0000connection\\\";s:5:\\\"mysql\\\";s:8:\\\"\\u0000*\\u0000table\\\";s:17:\\\"message_reactions\\\";s:13:\\\"\\u0000*\\u0000primaryKey\\\";s:2:\\\"id\\\";s:10:\\\"\\u0000*\\u0000keyType\\\";s:3:\\\"int\\\";s:12:\\\"incrementing\\\";b:1;s:7:\\\"\\u0000*\\u0000with\\\";a:0:{}s:12:\\\"\\u0000*\\u0000withCount\\\";a:0:{}s:19:\\\"preventsLazyLoading\\\";b:0;s:10:\\\"\\u0000*\\u0000perPage\\\";i:15;s:6:\\\"exists\\\";b:1;s:18:\\\"wasRecentlyCreated\\\";b:0;s:28:\\\"\\u0000*\\u0000escapeWhenCastingToString\\\";b:0;s:13:\\\"\\u0000*\\u0000attributes\\\";a:6:{s:2:\\\"id\\\";i:1;s:10:\\\"message_id\\\";i:72;s:7:\\\"user_id\\\";i:6;s:5:\\\"emoji\\\";s:4:\\\"😂\\\";s:10:\\\"created_at\\\";s:19:\\\"2026-03-13 10:45:29\\\";s:10:\\\"updated_at\\\";s:19:\\\"2026-03-13 10:45:29\\\";}s:11:\\\"\\u0000*\\u0000original\\\";a:6:{s:2:\\\"id\\\";i:1;s:10:\\\"message_id\\\";i:72;s:7:\\\"user_id\\\";i:6;s:5:\\\"emoji\\\";s:4:\\\"😂\\\";s:10:\\\"created_at\\\";s:19:\\\"2026-03-13 10:45:29\\\";s:10:\\\"updated_at\\\";s:19:\\\"2026-03-13 10:45:29\\\";}s:10:\\\"\\u0000*\\u0000changes\\\";a:0:{}s:11:\\\"\\u0000*\\u0000previous\\\";a:0:{}s:8:\\\"\\u0000*\\u0000casts\\\";a:0:{}s:17:\\\"\\u0000*\\u0000classCastCache\\\";a:0:{}s:21:\\\"\\u0000*\\u0000attributeCastCache\\\";a:0:{}s:13:\\\"\\u0000*\\u0000dateFormat\\\";N;s:10:\\\"\\u0000*\\u0000appends\\\";a:0:{}s:19:\\\"\\u0000*\\u0000dispatchesEvents\\\";a:0:{}s:14:\\\"\\u0000*\\u0000observables\\\";a:0:{}s:12:\\\"\\u0000*\\u0000relations\\\";a:0:{}s:10:\\\"\\u0000*\\u0000touches\\\";a:0:{}s:27:\\\"\\u0000*\\u0000relationAutoloadCallback\\\";N;s:26:\\\"\\u0000*\\u0000relationAutoloadContext\\\";N;s:10:\\\"timestamps\\\";b:1;s:13:\\\"usesUniqueIds\\\";b:0;s:9:\\\"\\u0000*\\u0000hidden\\\";a:0:{}s:10:\\\"\\u0000*\\u0000visible\\\";a:0:{}s:11:\\\"\\u0000*\\u0000fillable\\\";a:3:{i:0;s:10:\\\"message_id\\\";i:1;s:7:\\\"user_id\\\";i:2;s:5:\\\"emoji\\\";}s:10:\\\"\\u0000*\\u0000guarded\\\";a:1:{i:0;s:1:\\\"*\\\";}}}s:28:\\\"\\u0000*\\u0000escapeWhenCastingToString\\\";b:0;}s:6:\\\"status\\\";s:7:\\\"removed\\\";}s:10:\\\"receiverId\\\";i:6;}s:5:\\\"tries\\\";N;s:7:\\\"timeout\\\";N;s:7:\\\"backoff\\\";N;s:13:\\\"maxExceptions\\\";N;s:23:\\\"deleteWhenMissingModels\\\";b:1;s:10:\\\"connection\\\";N;s:5:\\\"queue\\\";N;s:12:\\\"messageGroup\\\";N;s:12:\\\"deduplicator\\\";N;s:5:\\\"delay\\\";N;s:11:\\\"afterCommit\\\";N;s:10:\\\"middleware\\\";a:0:{}s:7:\\\"chained\\\";a:0:{}s:15:\\\"chainConnection\\\";N;s:10:\\\"chainQueue\\\";N;s:19:\\\"chainCatchCallbacks\\\";N;}\",\"batchId\":null},\"createdAt\":1773398742,\"delay\":null}', 0, NULL, 1773398742, 1773398742),
(8, 'default', '{\"uuid\":\"e71a1c77-c465-438c-8c4c-904cb28a281b\",\"displayName\":\"App\\\\Events\\\\SystemNotification\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"Illuminate\\\\Broadcasting\\\\BroadcastEvent\",\"command\":\"O:38:\\\"Illuminate\\\\Broadcasting\\\\BroadcastEvent\\\":17:{s:5:\\\"event\\\";O:29:\\\"App\\\\Events\\\\SystemNotification\\\":2:{s:4:\\\"data\\\";a:4:{s:4:\\\"type\\\";s:16:\\\"reaction_updated\\\";s:9:\\\"messageId\\\";s:2:\\\"72\\\";s:9:\\\"reactions\\\";O:39:\\\"Illuminate\\\\Database\\\\Eloquent\\\\Collection\\\":2:{s:8:\\\"\\u0000*\\u0000items\\\";a:2:{i:0;O:26:\\\"App\\\\Models\\\\MessageReaction\\\":33:{s:13:\\\"\\u0000*\\u0000connection\\\";s:5:\\\"mysql\\\";s:8:\\\"\\u0000*\\u0000table\\\";s:17:\\\"message_reactions\\\";s:13:\\\"\\u0000*\\u0000primaryKey\\\";s:2:\\\"id\\\";s:10:\\\"\\u0000*\\u0000keyType\\\";s:3:\\\"int\\\";s:12:\\\"incrementing\\\";b:1;s:7:\\\"\\u0000*\\u0000with\\\";a:0:{}s:12:\\\"\\u0000*\\u0000withCount\\\";a:0:{}s:19:\\\"preventsLazyLoading\\\";b:0;s:10:\\\"\\u0000*\\u0000perPage\\\";i:15;s:6:\\\"exists\\\";b:1;s:18:\\\"wasRecentlyCreated\\\";b:0;s:28:\\\"\\u0000*\\u0000escapeWhenCastingToString\\\";b:0;s:13:\\\"\\u0000*\\u0000attributes\\\";a:6:{s:2:\\\"id\\\";i:3;s:10:\\\"message_id\\\";i:72;s:7:\\\"user_id\\\";i:1;s:5:\\\"emoji\\\";s:6:\\\"❤️\\\";s:10:\\\"created_at\\\";s:19:\\\"2026-03-13 10:45:48\\\";s:10:\\\"updated_at\\\";s:19:\\\"2026-03-13 10:45:48\\\";}s:11:\\\"\\u0000*\\u0000original\\\";a:6:{s:2:\\\"id\\\";i:3;s:10:\\\"message_id\\\";i:72;s:7:\\\"user_id\\\";i:1;s:5:\\\"emoji\\\";s:6:\\\"❤️\\\";s:10:\\\"created_at\\\";s:19:\\\"2026-03-13 10:45:48\\\";s:10:\\\"updated_at\\\";s:19:\\\"2026-03-13 10:45:48\\\";}s:10:\\\"\\u0000*\\u0000changes\\\";a:0:{}s:11:\\\"\\u0000*\\u0000previous\\\";a:0:{}s:8:\\\"\\u0000*\\u0000casts\\\";a:0:{}s:17:\\\"\\u0000*\\u0000classCastCache\\\";a:0:{}s:21:\\\"\\u0000*\\u0000attributeCastCache\\\";a:0:{}s:13:\\\"\\u0000*\\u0000dateFormat\\\";N;s:10:\\\"\\u0000*\\u0000appends\\\";a:0:{}s:19:\\\"\\u0000*\\u0000dispatchesEvents\\\";a:0:{}s:14:\\\"\\u0000*\\u0000observables\\\";a:0:{}s:12:\\\"\\u0000*\\u0000relations\\\";a:0:{}s:10:\\\"\\u0000*\\u0000touches\\\";a:0:{}s:27:\\\"\\u0000*\\u0000relationAutoloadCallback\\\";N;s:26:\\\"\\u0000*\\u0000relationAutoloadContext\\\";N;s:10:\\\"timestamps\\\";b:1;s:13:\\\"usesUniqueIds\\\";b:0;s:9:\\\"\\u0000*\\u0000hidden\\\";a:0:{}s:10:\\\"\\u0000*\\u0000visible\\\";a:0:{}s:11:\\\"\\u0000*\\u0000fillable\\\";a:3:{i:0;s:10:\\\"message_id\\\";i:1;s:7:\\\"user_id\\\";i:2;s:5:\\\"emoji\\\";}s:10:\\\"\\u0000*\\u0000guarded\\\";a:1:{i:0;s:1:\\\"*\\\";}}i:1;O:26:\\\"App\\\\Models\\\\MessageReaction\\\":33:{s:13:\\\"\\u0000*\\u0000connection\\\";s:5:\\\"mysql\\\";s:8:\\\"\\u0000*\\u0000table\\\";s:17:\\\"message_reactions\\\";s:13:\\\"\\u0000*\\u0000primaryKey\\\";s:2:\\\"id\\\";s:10:\\\"\\u0000*\\u0000keyType\\\";s:3:\\\"int\\\";s:12:\\\"incrementing\\\";b:1;s:7:\\\"\\u0000*\\u0000with\\\";a:0:{}s:12:\\\"\\u0000*\\u0000withCount\\\";a:0:{}s:19:\\\"preventsLazyLoading\\\";b:0;s:10:\\\"\\u0000*\\u0000perPage\\\";i:15;s:6:\\\"exists\\\";b:1;s:18:\\\"wasRecentlyCreated\\\";b:0;s:28:\\\"\\u0000*\\u0000escapeWhenCastingToString\\\";b:0;s:13:\\\"\\u0000*\\u0000attributes\\\";a:6:{s:2:\\\"id\\\";i:1;s:10:\\\"message_id\\\";i:72;s:7:\\\"user_id\\\";i:6;s:5:\\\"emoji\\\";s:4:\\\"😂\\\";s:10:\\\"created_at\\\";s:19:\\\"2026-03-13 10:45:29\\\";s:10:\\\"updated_at\\\";s:19:\\\"2026-03-13 10:45:29\\\";}s:11:\\\"\\u0000*\\u0000original\\\";a:6:{s:2:\\\"id\\\";i:1;s:10:\\\"message_id\\\";i:72;s:7:\\\"user_id\\\";i:6;s:5:\\\"emoji\\\";s:4:\\\"😂\\\";s:10:\\\"created_at\\\";s:19:\\\"2026-03-13 10:45:29\\\";s:10:\\\"updated_at\\\";s:19:\\\"2026-03-13 10:45:29\\\";}s:10:\\\"\\u0000*\\u0000changes\\\";a:0:{}s:11:\\\"\\u0000*\\u0000previous\\\";a:0:{}s:8:\\\"\\u0000*\\u0000casts\\\";a:0:{}s:17:\\\"\\u0000*\\u0000classCastCache\\\";a:0:{}s:21:\\\"\\u0000*\\u0000attributeCastCache\\\";a:0:{}s:13:\\\"\\u0000*\\u0000dateFormat\\\";N;s:10:\\\"\\u0000*\\u0000appends\\\";a:0:{}s:19:\\\"\\u0000*\\u0000dispatchesEvents\\\";a:0:{}s:14:\\\"\\u0000*\\u0000observables\\\";a:0:{}s:12:\\\"\\u0000*\\u0000relations\\\";a:0:{}s:10:\\\"\\u0000*\\u0000touches\\\";a:0:{}s:27:\\\"\\u0000*\\u0000relationAutoloadCallback\\\";N;s:26:\\\"\\u0000*\\u0000relationAutoloadContext\\\";N;s:10:\\\"timestamps\\\";b:1;s:13:\\\"usesUniqueIds\\\";b:0;s:9:\\\"\\u0000*\\u0000hidden\\\";a:0:{}s:10:\\\"\\u0000*\\u0000visible\\\";a:0:{}s:11:\\\"\\u0000*\\u0000fillable\\\";a:3:{i:0;s:10:\\\"message_id\\\";i:1;s:7:\\\"user_id\\\";i:2;s:5:\\\"emoji\\\";}s:10:\\\"\\u0000*\\u0000guarded\\\";a:1:{i:0;s:1:\\\"*\\\";}}}s:28:\\\"\\u0000*\\u0000escapeWhenCastingToString\\\";b:0;}s:6:\\\"status\\\";s:5:\\\"added\\\";}s:10:\\\"receiverId\\\";i:6;}s:5:\\\"tries\\\";N;s:7:\\\"timeout\\\";N;s:7:\\\"backoff\\\";N;s:13:\\\"maxExceptions\\\";N;s:23:\\\"deleteWhenMissingModels\\\";b:1;s:10:\\\"connection\\\";N;s:5:\\\"queue\\\";N;s:12:\\\"messageGroup\\\";N;s:12:\\\"deduplicator\\\";N;s:5:\\\"delay\\\";N;s:11:\\\"afterCommit\\\";N;s:10:\\\"middleware\\\";a:0:{}s:7:\\\"chained\\\";a:0:{}s:15:\\\"chainConnection\\\";N;s:10:\\\"chainQueue\\\";N;s:19:\\\"chainCatchCallbacks\\\";N;}\",\"batchId\":null},\"createdAt\":1773398748,\"delay\":null}', 0, NULL, 1773398748, 1773398748),
(9, 'default', '{\"uuid\":\"84206af5-2902-4ca4-bb4d-d27b9e17dc80\",\"displayName\":\"App\\\\Events\\\\SystemNotification\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"Illuminate\\\\Broadcasting\\\\BroadcastEvent\",\"command\":\"O:38:\\\"Illuminate\\\\Broadcasting\\\\BroadcastEvent\\\":17:{s:5:\\\"event\\\";O:29:\\\"App\\\\Events\\\\SystemNotification\\\":2:{s:4:\\\"data\\\";a:4:{s:4:\\\"type\\\";s:16:\\\"reaction_updated\\\";s:9:\\\"messageId\\\";s:2:\\\"72\\\";s:9:\\\"reactions\\\";O:39:\\\"Illuminate\\\\Database\\\\Eloquent\\\\Collection\\\":2:{s:8:\\\"\\u0000*\\u0000items\\\";a:1:{i:0;O:26:\\\"App\\\\Models\\\\MessageReaction\\\":33:{s:13:\\\"\\u0000*\\u0000connection\\\";s:5:\\\"mysql\\\";s:8:\\\"\\u0000*\\u0000table\\\";s:17:\\\"message_reactions\\\";s:13:\\\"\\u0000*\\u0000primaryKey\\\";s:2:\\\"id\\\";s:10:\\\"\\u0000*\\u0000keyType\\\";s:3:\\\"int\\\";s:12:\\\"incrementing\\\";b:1;s:7:\\\"\\u0000*\\u0000with\\\";a:0:{}s:12:\\\"\\u0000*\\u0000withCount\\\";a:0:{}s:19:\\\"preventsLazyLoading\\\";b:0;s:10:\\\"\\u0000*\\u0000perPage\\\";i:15;s:6:\\\"exists\\\";b:1;s:18:\\\"wasRecentlyCreated\\\";b:0;s:28:\\\"\\u0000*\\u0000escapeWhenCastingToString\\\";b:0;s:13:\\\"\\u0000*\\u0000attributes\\\";a:6:{s:2:\\\"id\\\";i:3;s:10:\\\"message_id\\\";i:72;s:7:\\\"user_id\\\";i:1;s:5:\\\"emoji\\\";s:6:\\\"❤️\\\";s:10:\\\"created_at\\\";s:19:\\\"2026-03-13 10:45:48\\\";s:10:\\\"updated_at\\\";s:19:\\\"2026-03-13 10:45:48\\\";}s:11:\\\"\\u0000*\\u0000original\\\";a:6:{s:2:\\\"id\\\";i:3;s:10:\\\"message_id\\\";i:72;s:7:\\\"user_id\\\";i:1;s:5:\\\"emoji\\\";s:6:\\\"❤️\\\";s:10:\\\"created_at\\\";s:19:\\\"2026-03-13 10:45:48\\\";s:10:\\\"updated_at\\\";s:19:\\\"2026-03-13 10:45:48\\\";}s:10:\\\"\\u0000*\\u0000changes\\\";a:0:{}s:11:\\\"\\u0000*\\u0000previous\\\";a:0:{}s:8:\\\"\\u0000*\\u0000casts\\\";a:0:{}s:17:\\\"\\u0000*\\u0000classCastCache\\\";a:0:{}s:21:\\\"\\u0000*\\u0000attributeCastCache\\\";a:0:{}s:13:\\\"\\u0000*\\u0000dateFormat\\\";N;s:10:\\\"\\u0000*\\u0000appends\\\";a:0:{}s:19:\\\"\\u0000*\\u0000dispatchesEvents\\\";a:0:{}s:14:\\\"\\u0000*\\u0000observables\\\";a:0:{}s:12:\\\"\\u0000*\\u0000relations\\\";a:0:{}s:10:\\\"\\u0000*\\u0000touches\\\";a:0:{}s:27:\\\"\\u0000*\\u0000relationAutoloadCallback\\\";N;s:26:\\\"\\u0000*\\u0000relationAutoloadContext\\\";N;s:10:\\\"timestamps\\\";b:1;s:13:\\\"usesUniqueIds\\\";b:0;s:9:\\\"\\u0000*\\u0000hidden\\\";a:0:{}s:10:\\\"\\u0000*\\u0000visible\\\";a:0:{}s:11:\\\"\\u0000*\\u0000fillable\\\";a:3:{i:0;s:10:\\\"message_id\\\";i:1;s:7:\\\"user_id\\\";i:2;s:5:\\\"emoji\\\";}s:10:\\\"\\u0000*\\u0000guarded\\\";a:1:{i:0;s:1:\\\"*\\\";}}}s:28:\\\"\\u0000*\\u0000escapeWhenCastingToString\\\";b:0;}s:6:\\\"status\\\";s:7:\\\"removed\\\";}s:10:\\\"receiverId\\\";i:1;}s:5:\\\"tries\\\";N;s:7:\\\"timeout\\\";N;s:7:\\\"backoff\\\";N;s:13:\\\"maxExceptions\\\";N;s:23:\\\"deleteWhenMissingModels\\\";b:1;s:10:\\\"connection\\\";N;s:5:\\\"queue\\\";N;s:12:\\\"messageGroup\\\";N;s:12:\\\"deduplicator\\\";N;s:5:\\\"delay\\\";N;s:11:\\\"afterCommit\\\";N;s:10:\\\"middleware\\\";a:0:{}s:7:\\\"chained\\\";a:0:{}s:15:\\\"chainConnection\\\";N;s:10:\\\"chainQueue\\\";N;s:19:\\\"chainCatchCallbacks\\\";N;}\",\"batchId\":null},\"createdAt\":1773398755,\"delay\":null}', 0, NULL, 1773398755, 1773398755),
(10, 'default', '{\"uuid\":\"b7c93947-8ebd-405b-9697-ae9df08dd42b\",\"displayName\":\"App\\\\Events\\\\SystemNotification\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"Illuminate\\\\Broadcasting\\\\BroadcastEvent\",\"command\":\"O:38:\\\"Illuminate\\\\Broadcasting\\\\BroadcastEvent\\\":17:{s:5:\\\"event\\\";O:29:\\\"App\\\\Events\\\\SystemNotification\\\":2:{s:4:\\\"data\\\";a:4:{s:4:\\\"type\\\";s:16:\\\"reaction_updated\\\";s:9:\\\"messageId\\\";s:2:\\\"72\\\";s:9:\\\"reactions\\\";O:39:\\\"Illuminate\\\\Database\\\\Eloquent\\\\Collection\\\":2:{s:8:\\\"\\u0000*\\u0000items\\\";a:2:{i:0;O:26:\\\"App\\\\Models\\\\MessageReaction\\\":33:{s:13:\\\"\\u0000*\\u0000connection\\\";s:5:\\\"mysql\\\";s:8:\\\"\\u0000*\\u0000table\\\";s:17:\\\"message_reactions\\\";s:13:\\\"\\u0000*\\u0000primaryKey\\\";s:2:\\\"id\\\";s:10:\\\"\\u0000*\\u0000keyType\\\";s:3:\\\"int\\\";s:12:\\\"incrementing\\\";b:1;s:7:\\\"\\u0000*\\u0000with\\\";a:0:{}s:12:\\\"\\u0000*\\u0000withCount\\\";a:0:{}s:19:\\\"preventsLazyLoading\\\";b:0;s:10:\\\"\\u0000*\\u0000perPage\\\";i:15;s:6:\\\"exists\\\";b:1;s:18:\\\"wasRecentlyCreated\\\";b:0;s:28:\\\"\\u0000*\\u0000escapeWhenCastingToString\\\";b:0;s:13:\\\"\\u0000*\\u0000attributes\\\";a:6:{s:2:\\\"id\\\";i:3;s:10:\\\"message_id\\\";i:72;s:7:\\\"user_id\\\";i:1;s:5:\\\"emoji\\\";s:6:\\\"❤️\\\";s:10:\\\"created_at\\\";s:19:\\\"2026-03-13 10:45:48\\\";s:10:\\\"updated_at\\\";s:19:\\\"2026-03-13 10:45:48\\\";}s:11:\\\"\\u0000*\\u0000original\\\";a:6:{s:2:\\\"id\\\";i:3;s:10:\\\"message_id\\\";i:72;s:7:\\\"user_id\\\";i:1;s:5:\\\"emoji\\\";s:6:\\\"❤️\\\";s:10:\\\"created_at\\\";s:19:\\\"2026-03-13 10:45:48\\\";s:10:\\\"updated_at\\\";s:19:\\\"2026-03-13 10:45:48\\\";}s:10:\\\"\\u0000*\\u0000changes\\\";a:0:{}s:11:\\\"\\u0000*\\u0000previous\\\";a:0:{}s:8:\\\"\\u0000*\\u0000casts\\\";a:0:{}s:17:\\\"\\u0000*\\u0000classCastCache\\\";a:0:{}s:21:\\\"\\u0000*\\u0000attributeCastCache\\\";a:0:{}s:13:\\\"\\u0000*\\u0000dateFormat\\\";N;s:10:\\\"\\u0000*\\u0000appends\\\";a:0:{}s:19:\\\"\\u0000*\\u0000dispatchesEvents\\\";a:0:{}s:14:\\\"\\u0000*\\u0000observables\\\";a:0:{}s:12:\\\"\\u0000*\\u0000relations\\\";a:0:{}s:10:\\\"\\u0000*\\u0000touches\\\";a:0:{}s:27:\\\"\\u0000*\\u0000relationAutoloadCallback\\\";N;s:26:\\\"\\u0000*\\u0000relationAutoloadContext\\\";N;s:10:\\\"timestamps\\\";b:1;s:13:\\\"usesUniqueIds\\\";b:0;s:9:\\\"\\u0000*\\u0000hidden\\\";a:0:{}s:10:\\\"\\u0000*\\u0000visible\\\";a:0:{}s:11:\\\"\\u0000*\\u0000fillable\\\";a:3:{i:0;s:10:\\\"message_id\\\";i:1;s:7:\\\"user_id\\\";i:2;s:5:\\\"emoji\\\";}s:10:\\\"\\u0000*\\u0000guarded\\\";a:1:{i:0;s:1:\\\"*\\\";}}i:1;O:26:\\\"App\\\\Models\\\\MessageReaction\\\":33:{s:13:\\\"\\u0000*\\u0000connection\\\";s:5:\\\"mysql\\\";s:8:\\\"\\u0000*\\u0000table\\\";s:17:\\\"message_reactions\\\";s:13:\\\"\\u0000*\\u0000primaryKey\\\";s:2:\\\"id\\\";s:10:\\\"\\u0000*\\u0000keyType\\\";s:3:\\\"int\\\";s:12:\\\"incrementing\\\";b:1;s:7:\\\"\\u0000*\\u0000with\\\";a:0:{}s:12:\\\"\\u0000*\\u0000withCount\\\";a:0:{}s:19:\\\"preventsLazyLoading\\\";b:0;s:10:\\\"\\u0000*\\u0000perPage\\\";i:15;s:6:\\\"exists\\\";b:1;s:18:\\\"wasRecentlyCreated\\\";b:0;s:28:\\\"\\u0000*\\u0000escapeWhenCastingToString\\\";b:0;s:13:\\\"\\u0000*\\u0000attributes\\\";a:6:{s:2:\\\"id\\\";i:4;s:10:\\\"message_id\\\";i:72;s:7:\\\"user_id\\\";i:6;s:5:\\\"emoji\\\";s:6:\\\"❤️\\\";s:10:\\\"created_at\\\";s:19:\\\"2026-03-13 10:45:57\\\";s:10:\\\"updated_at\\\";s:19:\\\"2026-03-13 10:45:57\\\";}s:11:\\\"\\u0000*\\u0000original\\\";a:6:{s:2:\\\"id\\\";i:4;s:10:\\\"message_id\\\";i:72;s:7:\\\"user_id\\\";i:6;s:5:\\\"emoji\\\";s:6:\\\"❤️\\\";s:10:\\\"created_at\\\";s:19:\\\"2026-03-13 10:45:57\\\";s:10:\\\"updated_at\\\";s:19:\\\"2026-03-13 10:45:57\\\";}s:10:\\\"\\u0000*\\u0000changes\\\";a:0:{}s:11:\\\"\\u0000*\\u0000previous\\\";a:0:{}s:8:\\\"\\u0000*\\u0000casts\\\";a:0:{}s:17:\\\"\\u0000*\\u0000classCastCache\\\";a:0:{}s:21:\\\"\\u0000*\\u0000attributeCastCache\\\";a:0:{}s:13:\\\"\\u0000*\\u0000dateFormat\\\";N;s:10:\\\"\\u0000*\\u0000appends\\\";a:0:{}s:19:\\\"\\u0000*\\u0000dispatchesEvents\\\";a:0:{}s:14:\\\"\\u0000*\\u0000observables\\\";a:0:{}s:12:\\\"\\u0000*\\u0000relations\\\";a:0:{}s:10:\\\"\\u0000*\\u0000touches\\\";a:0:{}s:27:\\\"\\u0000*\\u0000relationAutoloadCallback\\\";N;s:26:\\\"\\u0000*\\u0000relationAutoloadContext\\\";N;s:10:\\\"timestamps\\\";b:1;s:13:\\\"usesUniqueIds\\\";b:0;s:9:\\\"\\u0000*\\u0000hidden\\\";a:0:{}s:10:\\\"\\u0000*\\u0000visible\\\";a:0:{}s:11:\\\"\\u0000*\\u0000fillable\\\";a:3:{i:0;s:10:\\\"message_id\\\";i:1;s:7:\\\"user_id\\\";i:2;s:5:\\\"emoji\\\";}s:10:\\\"\\u0000*\\u0000guarded\\\";a:1:{i:0;s:1:\\\"*\\\";}}}s:28:\\\"\\u0000*\\u0000escapeWhenCastingToString\\\";b:0;}s:6:\\\"status\\\";s:5:\\\"added\\\";}s:10:\\\"receiverId\\\";i:1;}s:5:\\\"tries\\\";N;s:7:\\\"timeout\\\";N;s:7:\\\"backoff\\\";N;s:13:\\\"maxExceptions\\\";N;s:23:\\\"deleteWhenMissingModels\\\";b:1;s:10:\\\"connection\\\";N;s:5:\\\"queue\\\";N;s:12:\\\"messageGroup\\\";N;s:12:\\\"deduplicator\\\";N;s:5:\\\"delay\\\";N;s:11:\\\"afterCommit\\\";N;s:10:\\\"middleware\\\";a:0:{}s:7:\\\"chained\\\";a:0:{}s:15:\\\"chainConnection\\\";N;s:10:\\\"chainQueue\\\";N;s:19:\\\"chainCatchCallbacks\\\";N;}\",\"batchId\":null},\"createdAt\":1773398757,\"delay\":null}', 0, NULL, 1773398757, 1773398757),
(11, 'default', '{\"uuid\":\"a6f5c9b2-9829-4790-a4ac-54d18a8dd391\",\"displayName\":\"App\\\\Events\\\\SystemNotification\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"Illuminate\\\\Broadcasting\\\\BroadcastEvent\",\"command\":\"O:38:\\\"Illuminate\\\\Broadcasting\\\\BroadcastEvent\\\":17:{s:5:\\\"event\\\";O:29:\\\"App\\\\Events\\\\SystemNotification\\\":2:{s:4:\\\"data\\\";a:4:{s:4:\\\"type\\\";s:16:\\\"reaction_updated\\\";s:9:\\\"messageId\\\";s:2:\\\"70\\\";s:9:\\\"reactions\\\";O:39:\\\"Illuminate\\\\Database\\\\Eloquent\\\\Collection\\\":2:{s:8:\\\"\\u0000*\\u0000items\\\";a:1:{i:0;O:26:\\\"App\\\\Models\\\\MessageReaction\\\":33:{s:13:\\\"\\u0000*\\u0000connection\\\";s:5:\\\"mysql\\\";s:8:\\\"\\u0000*\\u0000table\\\";s:17:\\\"message_reactions\\\";s:13:\\\"\\u0000*\\u0000primaryKey\\\";s:2:\\\"id\\\";s:10:\\\"\\u0000*\\u0000keyType\\\";s:3:\\\"int\\\";s:12:\\\"incrementing\\\";b:1;s:7:\\\"\\u0000*\\u0000with\\\";a:0:{}s:12:\\\"\\u0000*\\u0000withCount\\\";a:0:{}s:19:\\\"preventsLazyLoading\\\";b:0;s:10:\\\"\\u0000*\\u0000perPage\\\";i:15;s:6:\\\"exists\\\";b:1;s:18:\\\"wasRecentlyCreated\\\";b:0;s:28:\\\"\\u0000*\\u0000escapeWhenCastingToString\\\";b:0;s:13:\\\"\\u0000*\\u0000attributes\\\";a:6:{s:2:\\\"id\\\";i:5;s:10:\\\"message_id\\\";i:70;s:7:\\\"user_id\\\";i:6;s:5:\\\"emoji\\\";s:4:\\\"🔥\\\";s:10:\\\"created_at\\\";s:19:\\\"2026-03-13 10:46:27\\\";s:10:\\\"updated_at\\\";s:19:\\\"2026-03-13 10:46:27\\\";}s:11:\\\"\\u0000*\\u0000original\\\";a:6:{s:2:\\\"id\\\";i:5;s:10:\\\"message_id\\\";i:70;s:7:\\\"user_id\\\";i:6;s:5:\\\"emoji\\\";s:4:\\\"🔥\\\";s:10:\\\"created_at\\\";s:19:\\\"2026-03-13 10:46:27\\\";s:10:\\\"updated_at\\\";s:19:\\\"2026-03-13 10:46:27\\\";}s:10:\\\"\\u0000*\\u0000changes\\\";a:0:{}s:11:\\\"\\u0000*\\u0000previous\\\";a:0:{}s:8:\\\"\\u0000*\\u0000casts\\\";a:0:{}s:17:\\\"\\u0000*\\u0000classCastCache\\\";a:0:{}s:21:\\\"\\u0000*\\u0000attributeCastCache\\\";a:0:{}s:13:\\\"\\u0000*\\u0000dateFormat\\\";N;s:10:\\\"\\u0000*\\u0000appends\\\";a:0:{}s:19:\\\"\\u0000*\\u0000dispatchesEvents\\\";a:0:{}s:14:\\\"\\u0000*\\u0000observables\\\";a:0:{}s:12:\\\"\\u0000*\\u0000relations\\\";a:0:{}s:10:\\\"\\u0000*\\u0000touches\\\";a:0:{}s:27:\\\"\\u0000*\\u0000relationAutoloadCallback\\\";N;s:26:\\\"\\u0000*\\u0000relationAutoloadContext\\\";N;s:10:\\\"timestamps\\\";b:1;s:13:\\\"usesUniqueIds\\\";b:0;s:9:\\\"\\u0000*\\u0000hidden\\\";a:0:{}s:10:\\\"\\u0000*\\u0000visible\\\";a:0:{}s:11:\\\"\\u0000*\\u0000fillable\\\";a:3:{i:0;s:10:\\\"message_id\\\";i:1;s:7:\\\"user_id\\\";i:2;s:5:\\\"emoji\\\";}s:10:\\\"\\u0000*\\u0000guarded\\\";a:1:{i:0;s:1:\\\"*\\\";}}}s:28:\\\"\\u0000*\\u0000escapeWhenCastingToString\\\";b:0;}s:6:\\\"status\\\";s:5:\\\"added\\\";}s:10:\\\"receiverId\\\";i:1;}s:5:\\\"tries\\\";N;s:7:\\\"timeout\\\";N;s:7:\\\"backoff\\\";N;s:13:\\\"maxExceptions\\\";N;s:23:\\\"deleteWhenMissingModels\\\";b:1;s:10:\\\"connection\\\";N;s:5:\\\"queue\\\";N;s:12:\\\"messageGroup\\\";N;s:12:\\\"deduplicator\\\";N;s:5:\\\"delay\\\";N;s:11:\\\"afterCommit\\\";N;s:10:\\\"middleware\\\";a:0:{}s:7:\\\"chained\\\";a:0:{}s:15:\\\"chainConnection\\\";N;s:10:\\\"chainQueue\\\";N;s:19:\\\"chainCatchCallbacks\\\";N;}\",\"batchId\":null},\"createdAt\":1773398787,\"delay\":null}', 0, NULL, 1773398787, 1773398787),
(12, 'default', '{\"uuid\":\"b00d4812-15cf-404b-80f8-eb2d82501fde\",\"displayName\":\"App\\\\Events\\\\SystemNotification\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"Illuminate\\\\Broadcasting\\\\BroadcastEvent\",\"command\":\"O:38:\\\"Illuminate\\\\Broadcasting\\\\BroadcastEvent\\\":17:{s:5:\\\"event\\\";O:29:\\\"App\\\\Events\\\\SystemNotification\\\":2:{s:4:\\\"data\\\";a:4:{s:4:\\\"type\\\";s:11:\\\"pin_updated\\\";s:6:\\\"pinned\\\";O:18:\\\"App\\\\Models\\\\Message\\\":33:{s:13:\\\"\\u0000*\\u0000connection\\\";s:5:\\\"mysql\\\";s:8:\\\"\\u0000*\\u0000table\\\";s:8:\\\"messages\\\";s:13:\\\"\\u0000*\\u0000primaryKey\\\";s:2:\\\"id\\\";s:10:\\\"\\u0000*\\u0000keyType\\\";s:3:\\\"int\\\";s:12:\\\"incrementing\\\";b:1;s:7:\\\"\\u0000*\\u0000with\\\";a:0:{}s:12:\\\"\\u0000*\\u0000withCount\\\";a:0:{}s:19:\\\"preventsLazyLoading\\\";b:0;s:10:\\\"\\u0000*\\u0000perPage\\\";i:15;s:6:\\\"exists\\\";b:1;s:18:\\\"wasRecentlyCreated\\\";b:0;s:28:\\\"\\u0000*\\u0000escapeWhenCastingToString\\\";b:0;s:13:\\\"\\u0000*\\u0000attributes\\\";a:10:{s:2:\\\"id\\\";i:73;s:9:\\\"sender_id\\\";i:6;s:11:\\\"receiver_id\\\";i:1;s:7:\\\"content\\\";s:9:\\\"kjghhjghj\\\";s:9:\\\"file_name\\\";N;s:4:\\\"type\\\";s:4:\\\"text\\\";s:7:\\\"is_read\\\";i:1;s:10:\\\"created_at\\\";s:19:\\\"2026-03-13 10:31:40\\\";s:10:\\\"updated_at\\\";s:19:\\\"2026-03-13 10:31:41\\\";s:11:\\\"reply_to_id\\\";N;}s:11:\\\"\\u0000*\\u0000original\\\";a:10:{s:2:\\\"id\\\";i:73;s:9:\\\"sender_id\\\";i:6;s:11:\\\"receiver_id\\\";i:1;s:7:\\\"content\\\";s:9:\\\"kjghhjghj\\\";s:9:\\\"file_name\\\";N;s:4:\\\"type\\\";s:4:\\\"text\\\";s:7:\\\"is_read\\\";i:1;s:10:\\\"created_at\\\";s:19:\\\"2026-03-13 10:31:40\\\";s:10:\\\"updated_at\\\";s:19:\\\"2026-03-13 10:31:41\\\";s:11:\\\"reply_to_id\\\";N;}s:10:\\\"\\u0000*\\u0000changes\\\";a:0:{}s:11:\\\"\\u0000*\\u0000previous\\\";a:0:{}s:8:\\\"\\u0000*\\u0000casts\\\";a:0:{}s:17:\\\"\\u0000*\\u0000classCastCache\\\";a:0:{}s:21:\\\"\\u0000*\\u0000attributeCastCache\\\";a:0:{}s:13:\\\"\\u0000*\\u0000dateFormat\\\";N;s:10:\\\"\\u0000*\\u0000appends\\\";a:0:{}s:19:\\\"\\u0000*\\u0000dispatchesEvents\\\";a:0:{}s:14:\\\"\\u0000*\\u0000observables\\\";a:0:{}s:12:\\\"\\u0000*\\u0000relations\\\";a:1:{s:9:\\\"reactions\\\";O:39:\\\"Illuminate\\\\Database\\\\Eloquent\\\\Collection\\\":2:{s:8:\\\"\\u0000*\\u0000items\\\";a:0:{}s:28:\\\"\\u0000*\\u0000escapeWhenCastingToString\\\";b:0;}}s:10:\\\"\\u0000*\\u0000touches\\\";a:0:{}s:27:\\\"\\u0000*\\u0000relationAutoloadCallback\\\";N;s:26:\\\"\\u0000*\\u0000relationAutoloadContext\\\";N;s:10:\\\"timestamps\\\";b:1;s:13:\\\"usesUniqueIds\\\";b:0;s:9:\\\"\\u0000*\\u0000hidden\\\";a:0:{}s:10:\\\"\\u0000*\\u0000visible\\\";a:0:{}s:11:\\\"\\u0000*\\u0000fillable\\\";a:7:{i:0;s:9:\\\"sender_id\\\";i:1;s:11:\\\"receiver_id\\\";i:2;s:7:\\\"content\\\";i:3;s:4:\\\"type\\\";i:4;s:9:\\\"file_name\\\";i:5;s:7:\\\"is_read\\\";i:6;s:11:\\\"reply_to_id\\\";}s:10:\\\"\\u0000*\\u0000guarded\\\";a:1:{i:0;s:1:\\\"*\\\";}}s:6:\\\"status\\\";s:6:\\\"pinned\\\";s:9:\\\"partnerId\\\";i:6;}s:10:\\\"receiverId\\\";i:1;}s:5:\\\"tries\\\";N;s:7:\\\"timeout\\\";N;s:7:\\\"backoff\\\";N;s:13:\\\"maxExceptions\\\";N;s:23:\\\"deleteWhenMissingModels\\\";b:1;s:10:\\\"connection\\\";N;s:5:\\\"queue\\\";N;s:12:\\\"messageGroup\\\";N;s:12:\\\"deduplicator\\\";N;s:5:\\\"delay\\\";N;s:11:\\\"afterCommit\\\";N;s:10:\\\"middleware\\\";a:0:{}s:7:\\\"chained\\\";a:0:{}s:15:\\\"chainConnection\\\";N;s:10:\\\"chainQueue\\\";N;s:19:\\\"chainCatchCallbacks\\\";N;}\",\"batchId\":null},\"createdAt\":1773398817,\"delay\":null}', 0, NULL, 1773398817, 1773398817),
(13, 'default', '{\"uuid\":\"47b5be4c-c20f-41e6-8d73-93b3e9c15361\",\"displayName\":\"App\\\\Events\\\\SystemNotification\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"Illuminate\\\\Broadcasting\\\\BroadcastEvent\",\"command\":\"O:38:\\\"Illuminate\\\\Broadcasting\\\\BroadcastEvent\\\":17:{s:5:\\\"event\\\";O:29:\\\"App\\\\Events\\\\SystemNotification\\\":2:{s:4:\\\"data\\\";a:4:{s:4:\\\"type\\\";s:11:\\\"pin_updated\\\";s:6:\\\"pinned\\\";N;s:6:\\\"status\\\";s:8:\\\"unpinned\\\";s:9:\\\"partnerId\\\";i:6;}s:10:\\\"receiverId\\\";i:1;}s:5:\\\"tries\\\";N;s:7:\\\"timeout\\\";N;s:7:\\\"backoff\\\";N;s:13:\\\"maxExceptions\\\";N;s:23:\\\"deleteWhenMissingModels\\\";b:1;s:10:\\\"connection\\\";N;s:5:\\\"queue\\\";N;s:12:\\\"messageGroup\\\";N;s:12:\\\"deduplicator\\\";N;s:5:\\\"delay\\\";N;s:11:\\\"afterCommit\\\";N;s:10:\\\"middleware\\\";a:0:{}s:7:\\\"chained\\\";a:0:{}s:15:\\\"chainConnection\\\";N;s:10:\\\"chainQueue\\\";N;s:19:\\\"chainCatchCallbacks\\\";N;}\",\"batchId\":null},\"createdAt\":1773399453,\"delay\":null}', 0, NULL, 1773399453, 1773399453),
(14, 'default', '{\"uuid\":\"e1d06ef8-b1ea-4003-bdb8-4587d2bbdf22\",\"displayName\":\"App\\\\Events\\\\SystemNotification\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"Illuminate\\\\Broadcasting\\\\BroadcastEvent\",\"command\":\"O:38:\\\"Illuminate\\\\Broadcasting\\\\BroadcastEvent\\\":17:{s:5:\\\"event\\\";O:29:\\\"App\\\\Events\\\\SystemNotification\\\":2:{s:4:\\\"data\\\";a:4:{s:4:\\\"type\\\";s:11:\\\"pin_updated\\\";s:6:\\\"pinned\\\";O:18:\\\"App\\\\Models\\\\Message\\\":33:{s:13:\\\"\\u0000*\\u0000connection\\\";s:5:\\\"mysql\\\";s:8:\\\"\\u0000*\\u0000table\\\";s:8:\\\"messages\\\";s:13:\\\"\\u0000*\\u0000primaryKey\\\";s:2:\\\"id\\\";s:10:\\\"\\u0000*\\u0000keyType\\\";s:3:\\\"int\\\";s:12:\\\"incrementing\\\";b:1;s:7:\\\"\\u0000*\\u0000with\\\";a:0:{}s:12:\\\"\\u0000*\\u0000withCount\\\";a:0:{}s:19:\\\"preventsLazyLoading\\\";b:0;s:10:\\\"\\u0000*\\u0000perPage\\\";i:15;s:6:\\\"exists\\\";b:1;s:18:\\\"wasRecentlyCreated\\\";b:0;s:28:\\\"\\u0000*\\u0000escapeWhenCastingToString\\\";b:0;s:13:\\\"\\u0000*\\u0000attributes\\\";a:10:{s:2:\\\"id\\\";i:76;s:9:\\\"sender_id\\\";i:1;s:11:\\\"receiver_id\\\";i:6;s:7:\\\"content\\\";s:5:\\\"Step1\\\";s:9:\\\"file_name\\\";N;s:4:\\\"type\\\";s:4:\\\"text\\\";s:7:\\\"is_read\\\";i:1;s:10:\\\"created_at\\\";s:19:\\\"2026-03-13 10:57:01\\\";s:10:\\\"updated_at\\\";s:19:\\\"2026-03-13 10:57:02\\\";s:11:\\\"reply_to_id\\\";N;}s:11:\\\"\\u0000*\\u0000original\\\";a:10:{s:2:\\\"id\\\";i:76;s:9:\\\"sender_id\\\";i:1;s:11:\\\"receiver_id\\\";i:6;s:7:\\\"content\\\";s:5:\\\"Step1\\\";s:9:\\\"file_name\\\";N;s:4:\\\"type\\\";s:4:\\\"text\\\";s:7:\\\"is_read\\\";i:1;s:10:\\\"created_at\\\";s:19:\\\"2026-03-13 10:57:01\\\";s:10:\\\"updated_at\\\";s:19:\\\"2026-03-13 10:57:02\\\";s:11:\\\"reply_to_id\\\";N;}s:10:\\\"\\u0000*\\u0000changes\\\";a:0:{}s:11:\\\"\\u0000*\\u0000previous\\\";a:0:{}s:8:\\\"\\u0000*\\u0000casts\\\";a:0:{}s:17:\\\"\\u0000*\\u0000classCastCache\\\";a:0:{}s:21:\\\"\\u0000*\\u0000attributeCastCache\\\";a:0:{}s:13:\\\"\\u0000*\\u0000dateFormat\\\";N;s:10:\\\"\\u0000*\\u0000appends\\\";a:0:{}s:19:\\\"\\u0000*\\u0000dispatchesEvents\\\";a:0:{}s:14:\\\"\\u0000*\\u0000observables\\\";a:0:{}s:12:\\\"\\u0000*\\u0000relations\\\";a:1:{s:9:\\\"reactions\\\";O:39:\\\"Illuminate\\\\Database\\\\Eloquent\\\\Collection\\\":2:{s:8:\\\"\\u0000*\\u0000items\\\";a:0:{}s:28:\\\"\\u0000*\\u0000escapeWhenCastingToString\\\";b:0;}}s:10:\\\"\\u0000*\\u0000touches\\\";a:0:{}s:27:\\\"\\u0000*\\u0000relationAutoloadCallback\\\";N;s:26:\\\"\\u0000*\\u0000relationAutoloadContext\\\";N;s:10:\\\"timestamps\\\";b:1;s:13:\\\"usesUniqueIds\\\";b:0;s:9:\\\"\\u0000*\\u0000hidden\\\";a:0:{}s:10:\\\"\\u0000*\\u0000visible\\\";a:0:{}s:11:\\\"\\u0000*\\u0000fillable\\\";a:7:{i:0;s:9:\\\"sender_id\\\";i:1;s:11:\\\"receiver_id\\\";i:2;s:7:\\\"content\\\";i:3;s:4:\\\"type\\\";i:4;s:9:\\\"file_name\\\";i:5;s:7:\\\"is_read\\\";i:6;s:11:\\\"reply_to_id\\\";}s:10:\\\"\\u0000*\\u0000guarded\\\";a:1:{i:0;s:1:\\\"*\\\";}}s:6:\\\"status\\\";s:6:\\\"pinned\\\";s:9:\\\"partnerId\\\";i:6;}s:10:\\\"receiverId\\\";i:1;}s:5:\\\"tries\\\";N;s:7:\\\"timeout\\\";N;s:7:\\\"backoff\\\";N;s:13:\\\"maxExceptions\\\";N;s:23:\\\"deleteWhenMissingModels\\\";b:1;s:10:\\\"connection\\\";N;s:5:\\\"queue\\\";N;s:12:\\\"messageGroup\\\";N;s:12:\\\"deduplicator\\\";N;s:5:\\\"delay\\\";N;s:11:\\\"afterCommit\\\";N;s:10:\\\"middleware\\\";a:0:{}s:7:\\\"chained\\\";a:0:{}s:15:\\\"chainConnection\\\";N;s:10:\\\"chainQueue\\\";N;s:19:\\\"chainCatchCallbacks\\\";N;}\",\"batchId\":null},\"createdAt\":1773399479,\"delay\":null}', 0, NULL, 1773399479, 1773399479),
(15, 'default', '{\"uuid\":\"5afb7b75-41f1-40ad-b866-2e1b64b46ead\",\"displayName\":\"App\\\\Events\\\\SystemNotification\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"Illuminate\\\\Broadcasting\\\\BroadcastEvent\",\"command\":\"O:38:\\\"Illuminate\\\\Broadcasting\\\\BroadcastEvent\\\":17:{s:5:\\\"event\\\";O:29:\\\"App\\\\Events\\\\SystemNotification\\\":2:{s:4:\\\"data\\\";a:4:{s:4:\\\"type\\\";s:11:\\\"pin_updated\\\";s:6:\\\"pinned\\\";N;s:6:\\\"status\\\";s:8:\\\"unpinned\\\";s:9:\\\"partnerId\\\";i:1;}s:10:\\\"receiverId\\\";i:6;}s:5:\\\"tries\\\";N;s:7:\\\"timeout\\\";N;s:7:\\\"backoff\\\";N;s:13:\\\"maxExceptions\\\";N;s:23:\\\"deleteWhenMissingModels\\\";b:1;s:10:\\\"connection\\\";N;s:5:\\\"queue\\\";N;s:12:\\\"messageGroup\\\";N;s:12:\\\"deduplicator\\\";N;s:5:\\\"delay\\\";N;s:11:\\\"afterCommit\\\";N;s:10:\\\"middleware\\\";a:0:{}s:7:\\\"chained\\\";a:0:{}s:15:\\\"chainConnection\\\";N;s:10:\\\"chainQueue\\\";N;s:19:\\\"chainCatchCallbacks\\\";N;}\",\"batchId\":null},\"createdAt\":1773399495,\"delay\":null}', 0, NULL, 1773399495, 1773399495),
(16, 'default', '{\"uuid\":\"7a340095-54b7-459d-8a29-071f1aaf1748\",\"displayName\":\"App\\\\Events\\\\SystemNotification\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"Illuminate\\\\Broadcasting\\\\BroadcastEvent\",\"command\":\"O:38:\\\"Illuminate\\\\Broadcasting\\\\BroadcastEvent\\\":17:{s:5:\\\"event\\\";O:29:\\\"App\\\\Events\\\\SystemNotification\\\":2:{s:4:\\\"data\\\";a:4:{s:4:\\\"type\\\";s:11:\\\"pin_updated\\\";s:6:\\\"pinned\\\";O:18:\\\"App\\\\Models\\\\Message\\\":33:{s:13:\\\"\\u0000*\\u0000connection\\\";s:5:\\\"mysql\\\";s:8:\\\"\\u0000*\\u0000table\\\";s:8:\\\"messages\\\";s:13:\\\"\\u0000*\\u0000primaryKey\\\";s:2:\\\"id\\\";s:10:\\\"\\u0000*\\u0000keyType\\\";s:3:\\\"int\\\";s:12:\\\"incrementing\\\";b:1;s:7:\\\"\\u0000*\\u0000with\\\";a:0:{}s:12:\\\"\\u0000*\\u0000withCount\\\";a:0:{}s:19:\\\"preventsLazyLoading\\\";b:0;s:10:\\\"\\u0000*\\u0000perPage\\\";i:15;s:6:\\\"exists\\\";b:1;s:18:\\\"wasRecentlyCreated\\\";b:0;s:28:\\\"\\u0000*\\u0000escapeWhenCastingToString\\\";b:0;s:13:\\\"\\u0000*\\u0000attributes\\\";a:10:{s:2:\\\"id\\\";i:75;s:9:\\\"sender_id\\\";i:6;s:11:\\\"receiver_id\\\";i:1;s:7:\\\"content\\\";s:5:\\\"65456\\\";s:9:\\\"file_name\\\";N;s:4:\\\"type\\\";s:4:\\\"text\\\";s:7:\\\"is_read\\\";i:1;s:10:\\\"created_at\\\";s:19:\\\"2026-03-13 10:49:51\\\";s:10:\\\"updated_at\\\";s:19:\\\"2026-03-13 10:49:52\\\";s:11:\\\"reply_to_id\\\";N;}s:11:\\\"\\u0000*\\u0000original\\\";a:10:{s:2:\\\"id\\\";i:75;s:9:\\\"sender_id\\\";i:6;s:11:\\\"receiver_id\\\";i:1;s:7:\\\"content\\\";s:5:\\\"65456\\\";s:9:\\\"file_name\\\";N;s:4:\\\"type\\\";s:4:\\\"text\\\";s:7:\\\"is_read\\\";i:1;s:10:\\\"created_at\\\";s:19:\\\"2026-03-13 10:49:51\\\";s:10:\\\"updated_at\\\";s:19:\\\"2026-03-13 10:49:52\\\";s:11:\\\"reply_to_id\\\";N;}s:10:\\\"\\u0000*\\u0000changes\\\";a:0:{}s:11:\\\"\\u0000*\\u0000previous\\\";a:0:{}s:8:\\\"\\u0000*\\u0000casts\\\";a:0:{}s:17:\\\"\\u0000*\\u0000classCastCache\\\";a:0:{}s:21:\\\"\\u0000*\\u0000attributeCastCache\\\";a:0:{}s:13:\\\"\\u0000*\\u0000dateFormat\\\";N;s:10:\\\"\\u0000*\\u0000appends\\\";a:0:{}s:19:\\\"\\u0000*\\u0000dispatchesEvents\\\";a:0:{}s:14:\\\"\\u0000*\\u0000observables\\\";a:0:{}s:12:\\\"\\u0000*\\u0000relations\\\";a:1:{s:9:\\\"reactions\\\";O:39:\\\"Illuminate\\\\Database\\\\Eloquent\\\\Collection\\\":2:{s:8:\\\"\\u0000*\\u0000items\\\";a:0:{}s:28:\\\"\\u0000*\\u0000escapeWhenCastingToString\\\";b:0;}}s:10:\\\"\\u0000*\\u0000touches\\\";a:0:{}s:27:\\\"\\u0000*\\u0000relationAutoloadCallback\\\";N;s:26:\\\"\\u0000*\\u0000relationAutoloadContext\\\";N;s:10:\\\"timestamps\\\";b:1;s:13:\\\"usesUniqueIds\\\";b:0;s:9:\\\"\\u0000*\\u0000hidden\\\";a:0:{}s:10:\\\"\\u0000*\\u0000visible\\\";a:0:{}s:11:\\\"\\u0000*\\u0000fillable\\\";a:7:{i:0;s:9:\\\"sender_id\\\";i:1;s:11:\\\"receiver_id\\\";i:2;s:7:\\\"content\\\";i:3;s:4:\\\"type\\\";i:4;s:9:\\\"file_name\\\";i:5;s:7:\\\"is_read\\\";i:6;s:11:\\\"reply_to_id\\\";}s:10:\\\"\\u0000*\\u0000guarded\\\";a:1:{i:0;s:1:\\\"*\\\";}}s:6:\\\"status\\\";s:6:\\\"pinned\\\";s:9:\\\"partnerId\\\";i:1;}s:10:\\\"receiverId\\\";i:6;}s:5:\\\"tries\\\";N;s:7:\\\"timeout\\\";N;s:7:\\\"backoff\\\";N;s:13:\\\"maxExceptions\\\";N;s:23:\\\"deleteWhenMissingModels\\\";b:1;s:10:\\\"connection\\\";N;s:5:\\\"queue\\\";N;s:12:\\\"messageGroup\\\";N;s:12:\\\"deduplicator\\\";N;s:5:\\\"delay\\\";N;s:11:\\\"afterCommit\\\";N;s:10:\\\"middleware\\\";a:0:{}s:7:\\\"chained\\\";a:0:{}s:15:\\\"chainConnection\\\";N;s:10:\\\"chainQueue\\\";N;s:19:\\\"chainCatchCallbacks\\\";N;}\",\"batchId\":null},\"createdAt\":1773399497,\"delay\":null}', 0, NULL, 1773399497, 1773399497);
INSERT INTO `jobs` (`id`, `queue`, `payload`, `attempts`, `reserved_at`, `available_at`, `created_at`) VALUES
(17, 'default', '{\"uuid\":\"4c93ad9b-0224-408f-abc0-1d8b6a276db1\",\"displayName\":\"App\\\\Events\\\\SystemNotification\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"Illuminate\\\\Broadcasting\\\\BroadcastEvent\",\"command\":\"O:38:\\\"Illuminate\\\\Broadcasting\\\\BroadcastEvent\\\":17:{s:5:\\\"event\\\";O:29:\\\"App\\\\Events\\\\SystemNotification\\\":2:{s:4:\\\"data\\\";a:4:{s:4:\\\"type\\\";s:11:\\\"pin_updated\\\";s:6:\\\"pinned\\\";O:18:\\\"App\\\\Models\\\\Message\\\":33:{s:13:\\\"\\u0000*\\u0000connection\\\";s:5:\\\"mysql\\\";s:8:\\\"\\u0000*\\u0000table\\\";s:8:\\\"messages\\\";s:13:\\\"\\u0000*\\u0000primaryKey\\\";s:2:\\\"id\\\";s:10:\\\"\\u0000*\\u0000keyType\\\";s:3:\\\"int\\\";s:12:\\\"incrementing\\\";b:1;s:7:\\\"\\u0000*\\u0000with\\\";a:0:{}s:12:\\\"\\u0000*\\u0000withCount\\\";a:0:{}s:19:\\\"preventsLazyLoading\\\";b:0;s:10:\\\"\\u0000*\\u0000perPage\\\";i:15;s:6:\\\"exists\\\";b:1;s:18:\\\"wasRecentlyCreated\\\";b:0;s:28:\\\"\\u0000*\\u0000escapeWhenCastingToString\\\";b:0;s:13:\\\"\\u0000*\\u0000attributes\\\";a:10:{s:2:\\\"id\\\";i:77;s:9:\\\"sender_id\\\";i:6;s:11:\\\"receiver_id\\\";i:1;s:7:\\\"content\\\";s:5:\\\"Step2\\\";s:9:\\\"file_name\\\";N;s:4:\\\"type\\\";s:4:\\\"text\\\";s:7:\\\"is_read\\\";i:1;s:10:\\\"created_at\\\";s:19:\\\"2026-03-13 10:57:05\\\";s:10:\\\"updated_at\\\";s:19:\\\"2026-03-13 10:57:06\\\";s:11:\\\"reply_to_id\\\";N;}s:11:\\\"\\u0000*\\u0000original\\\";a:10:{s:2:\\\"id\\\";i:77;s:9:\\\"sender_id\\\";i:6;s:11:\\\"receiver_id\\\";i:1;s:7:\\\"content\\\";s:5:\\\"Step2\\\";s:9:\\\"file_name\\\";N;s:4:\\\"type\\\";s:4:\\\"text\\\";s:7:\\\"is_read\\\";i:1;s:10:\\\"created_at\\\";s:19:\\\"2026-03-13 10:57:05\\\";s:10:\\\"updated_at\\\";s:19:\\\"2026-03-13 10:57:06\\\";s:11:\\\"reply_to_id\\\";N;}s:10:\\\"\\u0000*\\u0000changes\\\";a:0:{}s:11:\\\"\\u0000*\\u0000previous\\\";a:0:{}s:8:\\\"\\u0000*\\u0000casts\\\";a:0:{}s:17:\\\"\\u0000*\\u0000classCastCache\\\";a:0:{}s:21:\\\"\\u0000*\\u0000attributeCastCache\\\";a:0:{}s:13:\\\"\\u0000*\\u0000dateFormat\\\";N;s:10:\\\"\\u0000*\\u0000appends\\\";a:0:{}s:19:\\\"\\u0000*\\u0000dispatchesEvents\\\";a:0:{}s:14:\\\"\\u0000*\\u0000observables\\\";a:0:{}s:12:\\\"\\u0000*\\u0000relations\\\";a:1:{s:9:\\\"reactions\\\";O:39:\\\"Illuminate\\\\Database\\\\Eloquent\\\\Collection\\\":2:{s:8:\\\"\\u0000*\\u0000items\\\";a:0:{}s:28:\\\"\\u0000*\\u0000escapeWhenCastingToString\\\";b:0;}}s:10:\\\"\\u0000*\\u0000touches\\\";a:0:{}s:27:\\\"\\u0000*\\u0000relationAutoloadCallback\\\";N;s:26:\\\"\\u0000*\\u0000relationAutoloadContext\\\";N;s:10:\\\"timestamps\\\";b:1;s:13:\\\"usesUniqueIds\\\";b:0;s:9:\\\"\\u0000*\\u0000hidden\\\";a:0:{}s:10:\\\"\\u0000*\\u0000visible\\\";a:0:{}s:11:\\\"\\u0000*\\u0000fillable\\\";a:7:{i:0;s:9:\\\"sender_id\\\";i:1;s:11:\\\"receiver_id\\\";i:2;s:7:\\\"content\\\";i:3;s:4:\\\"type\\\";i:4;s:9:\\\"file_name\\\";i:5;s:7:\\\"is_read\\\";i:6;s:11:\\\"reply_to_id\\\";}s:10:\\\"\\u0000*\\u0000guarded\\\";a:1:{i:0;s:1:\\\"*\\\";}}s:6:\\\"status\\\";s:6:\\\"pinned\\\";s:9:\\\"partnerId\\\";i:1;}s:10:\\\"receiverId\\\";i:6;}s:5:\\\"tries\\\";N;s:7:\\\"timeout\\\";N;s:7:\\\"backoff\\\";N;s:13:\\\"maxExceptions\\\";N;s:23:\\\"deleteWhenMissingModels\\\";b:1;s:10:\\\"connection\\\";N;s:5:\\\"queue\\\";N;s:12:\\\"messageGroup\\\";N;s:12:\\\"deduplicator\\\";N;s:5:\\\"delay\\\";N;s:11:\\\"afterCommit\\\";N;s:10:\\\"middleware\\\";a:0:{}s:7:\\\"chained\\\";a:0:{}s:15:\\\"chainConnection\\\";N;s:10:\\\"chainQueue\\\";N;s:19:\\\"chainCatchCallbacks\\\";N;}\",\"batchId\":null},\"createdAt\":1773399518,\"delay\":null}', 0, NULL, 1773399518, 1773399518),
(18, 'default', '{\"uuid\":\"cac156b9-c78c-4e7a-9faf-59b82fe1e1c4\",\"displayName\":\"App\\\\Events\\\\SystemNotification\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"Illuminate\\\\Broadcasting\\\\BroadcastEvent\",\"command\":\"O:38:\\\"Illuminate\\\\Broadcasting\\\\BroadcastEvent\\\":17:{s:5:\\\"event\\\";O:29:\\\"App\\\\Events\\\\SystemNotification\\\":2:{s:4:\\\"data\\\";a:4:{s:4:\\\"type\\\";s:11:\\\"pin_updated\\\";s:6:\\\"pinned\\\";O:18:\\\"App\\\\Models\\\\Message\\\":33:{s:13:\\\"\\u0000*\\u0000connection\\\";s:5:\\\"mysql\\\";s:8:\\\"\\u0000*\\u0000table\\\";s:8:\\\"messages\\\";s:13:\\\"\\u0000*\\u0000primaryKey\\\";s:2:\\\"id\\\";s:10:\\\"\\u0000*\\u0000keyType\\\";s:3:\\\"int\\\";s:12:\\\"incrementing\\\";b:1;s:7:\\\"\\u0000*\\u0000with\\\";a:0:{}s:12:\\\"\\u0000*\\u0000withCount\\\";a:0:{}s:19:\\\"preventsLazyLoading\\\";b:0;s:10:\\\"\\u0000*\\u0000perPage\\\";i:15;s:6:\\\"exists\\\";b:1;s:18:\\\"wasRecentlyCreated\\\";b:0;s:28:\\\"\\u0000*\\u0000escapeWhenCastingToString\\\";b:0;s:13:\\\"\\u0000*\\u0000attributes\\\";a:10:{s:2:\\\"id\\\";i:76;s:9:\\\"sender_id\\\";i:1;s:11:\\\"receiver_id\\\";i:6;s:7:\\\"content\\\";s:5:\\\"Step1\\\";s:9:\\\"file_name\\\";N;s:4:\\\"type\\\";s:4:\\\"text\\\";s:7:\\\"is_read\\\";i:1;s:10:\\\"created_at\\\";s:19:\\\"2026-03-13 10:57:01\\\";s:10:\\\"updated_at\\\";s:19:\\\"2026-03-13 10:57:02\\\";s:11:\\\"reply_to_id\\\";N;}s:11:\\\"\\u0000*\\u0000original\\\";a:10:{s:2:\\\"id\\\";i:76;s:9:\\\"sender_id\\\";i:1;s:11:\\\"receiver_id\\\";i:6;s:7:\\\"content\\\";s:5:\\\"Step1\\\";s:9:\\\"file_name\\\";N;s:4:\\\"type\\\";s:4:\\\"text\\\";s:7:\\\"is_read\\\";i:1;s:10:\\\"created_at\\\";s:19:\\\"2026-03-13 10:57:01\\\";s:10:\\\"updated_at\\\";s:19:\\\"2026-03-13 10:57:02\\\";s:11:\\\"reply_to_id\\\";N;}s:10:\\\"\\u0000*\\u0000changes\\\";a:0:{}s:11:\\\"\\u0000*\\u0000previous\\\";a:0:{}s:8:\\\"\\u0000*\\u0000casts\\\";a:0:{}s:17:\\\"\\u0000*\\u0000classCastCache\\\";a:0:{}s:21:\\\"\\u0000*\\u0000attributeCastCache\\\";a:0:{}s:13:\\\"\\u0000*\\u0000dateFormat\\\";N;s:10:\\\"\\u0000*\\u0000appends\\\";a:0:{}s:19:\\\"\\u0000*\\u0000dispatchesEvents\\\";a:0:{}s:14:\\\"\\u0000*\\u0000observables\\\";a:0:{}s:12:\\\"\\u0000*\\u0000relations\\\";a:1:{s:9:\\\"reactions\\\";O:39:\\\"Illuminate\\\\Database\\\\Eloquent\\\\Collection\\\":2:{s:8:\\\"\\u0000*\\u0000items\\\";a:0:{}s:28:\\\"\\u0000*\\u0000escapeWhenCastingToString\\\";b:0;}}s:10:\\\"\\u0000*\\u0000touches\\\";a:0:{}s:27:\\\"\\u0000*\\u0000relationAutoloadCallback\\\";N;s:26:\\\"\\u0000*\\u0000relationAutoloadContext\\\";N;s:10:\\\"timestamps\\\";b:1;s:13:\\\"usesUniqueIds\\\";b:0;s:9:\\\"\\u0000*\\u0000hidden\\\";a:0:{}s:10:\\\"\\u0000*\\u0000visible\\\";a:0:{}s:11:\\\"\\u0000*\\u0000fillable\\\";a:7:{i:0;s:9:\\\"sender_id\\\";i:1;s:11:\\\"receiver_id\\\";i:2;s:7:\\\"content\\\";i:3;s:4:\\\"type\\\";i:4;s:9:\\\"file_name\\\";i:5;s:7:\\\"is_read\\\";i:6;s:11:\\\"reply_to_id\\\";}s:10:\\\"\\u0000*\\u0000guarded\\\";a:1:{i:0;s:1:\\\"*\\\";}}s:6:\\\"status\\\";s:6:\\\"pinned\\\";s:9:\\\"partnerId\\\";i:1;}s:10:\\\"receiverId\\\";i:6;}s:5:\\\"tries\\\";N;s:7:\\\"timeout\\\";N;s:7:\\\"backoff\\\";N;s:13:\\\"maxExceptions\\\";N;s:23:\\\"deleteWhenMissingModels\\\";b:1;s:10:\\\"connection\\\";N;s:5:\\\"queue\\\";N;s:12:\\\"messageGroup\\\";N;s:12:\\\"deduplicator\\\";N;s:5:\\\"delay\\\";N;s:11:\\\"afterCommit\\\";N;s:10:\\\"middleware\\\";a:0:{}s:7:\\\"chained\\\";a:0:{}s:15:\\\"chainConnection\\\";N;s:10:\\\"chainQueue\\\";N;s:19:\\\"chainCatchCallbacks\\\";N;}\",\"batchId\":null},\"createdAt\":1773399537,\"delay\":null}', 0, NULL, 1773399537, 1773399537);

-- --------------------------------------------------------

--
-- Table structure for table `job_batches`
--

CREATE TABLE `job_batches` (
  `id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `total_jobs` int(11) NOT NULL,
  `pending_jobs` int(11) NOT NULL,
  `failed_jobs` int(11) NOT NULL,
  `failed_job_ids` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `options` mediumtext COLLATE utf8mb4_unicode_ci,
  `cancelled_at` int(11) DEFAULT NULL,
  `created_at` int(11) NOT NULL,
  `finished_at` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `medicines`
--

CREATE TABLE `medicines` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `dosage` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `times` json NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `notes` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `messages`
--

CREATE TABLE `messages` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `sender_id` bigint(20) UNSIGNED NOT NULL,
  `receiver_id` bigint(20) UNSIGNED NOT NULL,
  `content` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'text',
  `is_read` tinyint(1) NOT NULL DEFAULT '0',
  `is_deleted_everyone` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `reply_to_id` bigint(20) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `messages`
--

INSERT INTO `messages` (`id`, `sender_id`, `receiver_id`, `content`, `file_name`, `type`, `is_read`, `is_deleted_everyone`, `created_at`, `updated_at`, `reply_to_id`) VALUES
(99, 8, 7, 'hey abhishek', NULL, 'text', 1, 0, '2026-03-13 07:42:34', '2026-03-13 07:42:36', NULL),
(100, 7, 8, 'hello su k maro bhai', NULL, 'text', 1, 0, '2026-03-13 07:42:41', '2026-03-13 07:42:43', NULL),
(101, 8, 7, 'bas moje dariya', NULL, 'text', 1, 0, '2026-03-13 07:42:50', '2026-03-13 07:42:51', NULL),
(102, 8, 7, 'wah', NULL, 'text', 1, 0, '2026-03-13 07:43:18', '2026-03-13 07:43:19', 99),
(103, 8, 7, '😏😏', NULL, 'text', 1, 0, '2026-03-13 07:43:55', '2026-03-13 07:43:56', NULL),
(104, 9, 6, 'hello', NULL, 'text', 0, 0, '2026-03-13 07:56:52', '2026-03-13 07:56:52', NULL),
(105, 7, 9, 'hi', NULL, 'text', 1, 0, '2026-03-13 07:56:56', '2026-03-13 07:56:57', NULL),
(106, 9, 7, 'hi', NULL, 'text', 1, 0, '2026-03-13 07:57:00', '2026-03-13 07:57:01', NULL),
(107, 7, 9, 'su chale', NULL, 'text', 1, 0, '2026-03-13 07:57:05', '2026-03-13 07:57:06', NULL),
(108, 9, 7, 'jordar ho baki', NULL, 'text', 1, 0, '2026-03-13 07:57:09', '2026-03-13 07:57:10', NULL),
(109, 9, 7, 'laya', NULL, 'text', 1, 0, '2026-03-13 07:57:10', '2026-03-13 07:57:11', NULL),
(110, 9, 7, 'have ame bandh kari daiye dukam', NULL, 'text', 1, 0, '2026-03-13 07:57:22', '2026-03-13 07:57:23', NULL),
(111, 9, 7, 'dukan', NULL, 'text', 1, 0, '2026-03-13 07:57:25', '2026-03-13 07:57:26', NULL),
(112, 7, 9, 'to pachi em kai ghate', NULL, 'text', 1, 0, '2026-03-13 07:57:27', '2026-03-13 07:57:28', 108),
(113, 9, 7, 'sir ne kav', NULL, 'text', 1, 0, '2026-03-13 07:57:40', '2026-03-13 07:57:40', NULL),
(114, 7, 9, 'na have', NULL, 'text', 1, 0, '2026-03-13 07:57:44', '2026-03-13 07:57:45', NULL),
(115, 7, 9, 'L lagi jase', NULL, 'text', 1, 0, '2026-03-13 07:57:46', '2026-03-13 07:57:47', NULL),
(116, 9, 7, 'amara lagi gaya che', NULL, 'text', 1, 0, '2026-03-13 07:57:54', '2026-03-13 07:57:55', NULL),
(117, 7, 9, 'haji audio player muku chu', NULL, 'text', 1, 0, '2026-03-13 07:58:10', '2026-03-13 07:58:11', NULL),
(118, 7, 9, 'ama', NULL, 'text', 1, 0, '2026-03-13 07:58:11', '2026-03-13 07:58:13', NULL),
(119, 9, 7, '😂😂', NULL, 'text', 1, 0, '2026-03-13 07:58:11', '2026-03-13 07:58:12', NULL),
(120, 7, 9, 'd vid player', NULL, 'text', 1, 0, '2026-03-13 07:58:15', '2026-03-13 07:58:16', NULL),
(121, 9, 7, 'bas ne have. taunt na maro', NULL, 'text', 1, 0, '2026-03-13 07:58:28', '2026-03-13 07:58:29', NULL),
(122, 7, 9, 'bv vagyo nahi ne', NULL, 'text', 1, 0, '2026-03-13 07:58:51', '2026-03-13 07:58:52', NULL),
(123, 9, 7, 'ame 6 month kadya. kaik to ghate k nai yr.. saav am', NULL, 'text', 1, 0, '2026-03-13 07:58:54', '2026-03-13 07:58:55', NULL),
(124, 9, 7, '2 divas ma patheri fervo', NULL, 'text', 1, 0, '2026-03-13 07:58:59', '2026-03-13 07:59:00', NULL),
(125, 7, 9, 'me kai nai karyu', NULL, 'text', 1, 0, '2026-03-13 07:59:10', '2026-03-13 07:59:11', NULL),
(126, 7, 9, 'ai a karyu che', NULL, 'text', 1, 0, '2026-03-13 07:59:13', '2026-03-13 07:59:14', NULL),
(127, 9, 8, 'taro bhai🤣', NULL, 'text', 0, 0, '2026-03-13 08:16:03', '2026-03-13 08:16:03', NULL),
(128, 7, 9, 'hello', NULL, 'text', 0, 0, '2026-03-13 08:21:22', '2026-03-13 08:21:22', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `message_deletions`
--

CREATE TABLE `message_deletions` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `message_id` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `message_reactions`
--

CREATE TABLE `message_reactions` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `message_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `emoji` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `message_reactions`
--

INSERT INTO `message_reactions` (`id`, `message_id`, `user_id`, `emoji`, `created_at`, `updated_at`) VALUES
(31, 100, 8, '😂', '2026-03-13 07:43:04', '2026-03-13 07:43:04'),
(32, 119, 7, '❤️', '2026-03-13 07:58:25', '2026-03-13 07:58:25'),
(33, 126, 9, '😂', '2026-03-13 07:59:24', '2026-03-13 07:59:24'),
(34, 103, 7, '❤️', '2026-03-13 08:14:19', '2026-03-13 08:14:19');

-- --------------------------------------------------------

--
-- Table structure for table `migrations`
--

CREATE TABLE `migrations` (
  `id` int(10) UNSIGNED NOT NULL,
  `migration` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `batch` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `migrations`
--

INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES
(1, '0001_01_01_000000_create_users_table', 1),
(2, '0001_01_01_000001_create_cache_table', 1),
(3, '0001_01_01_000002_create_jobs_table', 1),
(4, '2026_03_12_000000_create_personal_access_tokens_table', 2),
(6, '2026_03_12_000001_create_reminders_table', 3),
(7, '2026_03_12_000002_create_user_activities_table', 4),
(8, '2026_03_12_000003_create_documents_table', 5),
(9, '2026_03_12_000004_create_medicines_table', 6),
(10, '2026_03_12_000005_create_bills_table', 6),
(11, '2026_03_12_000006_create_notes_table', 6),
(12, '2026_03_12_000007_create_vehicles_table', 6),
(13, '2026_03_12_000008_create_transactions_table', 6),
(14, '2026_03_12_000009_add_profile_fields_to_users_table', 7),
(15, '2026_03_13_000000_create_messages_table', 8),
(16, '2026_03_13_090039_add_file_name_to_messages_table', 9),
(17, '2026_03_13_153300_create_user_blocks_table', 10),
(18, '2026_03_13_160500_add_advanced_chat_features', 11),
(19, '2026_03_13_181500_add_deletion_to_messages_table', 12);

-- --------------------------------------------------------

--
-- Table structure for table `notes`
--

CREATE TABLE `notes` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `content` text COLLATE utf8mb4_unicode_ci,
  `type` enum('note','todo') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'note',
  `is_done` tinyint(1) NOT NULL DEFAULT '0',
  `is_pinned` tinyint(1) NOT NULL DEFAULT '0',
  `color` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `password_reset_tokens`
--

CREATE TABLE `password_reset_tokens` (
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `personal_access_tokens`
--

CREATE TABLE `personal_access_tokens` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `tokenable_type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tokenable_id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `abilities` text COLLATE utf8mb4_unicode_ci,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `personal_access_tokens`
--

INSERT INTO `personal_access_tokens` (`id`, `tokenable_type`, `tokenable_id`, `name`, `token`, `abilities`, `last_used_at`, `expires_at`, `created_at`, `updated_at`) VALUES
(4, 'App\\Models\\User', 2, 'auth_token', '9e405283c264d8ae4d9a67e8067d651e34982b2c37de3e69b508e189f5224935', '[\"*\"]', '2026-03-12 07:19:15', NULL, '2026-03-12 06:32:10', '2026-03-12 07:19:15'),
(5, 'App\\Models\\User', 1, 'auth_token', '56b776afb5467c747f2bdcaee2106349d97967cf52edffdb9fc7116584b9a95d', '[\"*\"]', '2026-03-12 07:08:43', NULL, '2026-03-12 06:59:42', '2026-03-12 07:08:43'),
(7, 'App\\Models\\User', 1, 'auth_token', '805545ccbdeff3507d5f2dad9ed562db5bbd5a12c83ee4ebefa4c9d40b1d0226', '[\"*\"]', '2026-03-12 08:24:32', NULL, '2026-03-12 07:57:21', '2026-03-12 08:24:32'),
(11, 'App\\Models\\User', 5, 'auth_token', 'a437ea98957e9107c461f700d915cbd6e2183bf33f416d3bf8ace308ffb2ca48', '[\"*\"]', '2026-03-13 01:06:30', NULL, '2026-03-13 01:00:47', '2026-03-13 01:06:30'),
(12, 'App\\Models\\User', 6, 'auth_token', '6b062f64a7b46644744fe4a92e25d2f7a0482bd8b9c77e7427236af6f1b1d3f6', '[\"*\"]', '2026-03-13 01:47:11', NULL, '2026-03-13 01:18:02', '2026-03-13 01:47:11'),
(14, 'App\\Models\\User', 6, 'auth_token', '287cdd4e67d19b55cfa3fa04156fe1c704eec1b800345a82bbb0bb5426dcdc01', '[\"*\"]', '2026-03-13 07:29:46', NULL, '2026-03-13 01:51:13', '2026-03-13 07:29:46'),
(15, 'App\\Models\\User', 1, 'auth_token', '479d907864afab952d7dca4f53fae06e6d24d4e507160ff3cc752878490bee8a', '[\"*\"]', '2026-03-13 07:29:47', NULL, '2026-03-13 01:55:42', '2026-03-13 07:29:47'),
(16, 'App\\Models\\User', 7, 'auth_token', 'd56da29d87e59524ea4b2418c4bedcd7076e487e539bbf6c2aa70bbeafb1a146', '[\"*\"]', '2026-03-13 08:06:43', NULL, '2026-03-13 07:38:44', '2026-03-13 08:06:43'),
(17, 'App\\Models\\User', 8, 'auth_token', '7e622e13955936c50afe48e01b281e00430469c662c099f3a7f9187d95e61bcd', '[\"*\"]', '2026-03-13 08:06:41', NULL, '2026-03-13 07:41:14', '2026-03-13 08:06:41'),
(18, 'App\\Models\\User', 9, 'auth_token', '08bf57bc8486f25e4dfed39562585f928d58ad5286fb9b4960257387be95cbab', '[\"*\"]', '2026-03-13 08:23:35', NULL, '2026-03-13 07:55:35', '2026-03-13 08:23:35'),
(19, 'App\\Models\\User', 7, 'auth_token', '9d024452314ccec69dfa136a27bf7b6b5c50719ecd09a23e2a8c1c2e769d9155', '[\"*\"]', '2026-03-13 08:23:38', NULL, '2026-03-13 08:12:35', '2026-03-13 08:23:38'),
(20, 'App\\Models\\User', 8, 'auth_token', '1593ee2399d5c87933008e8d1ecc394d7a8d6f0b0d35cfdf54e70c4bc90a3a64', '[\"*\"]', '2026-03-13 08:23:33', NULL, '2026-03-13 08:13:42', '2026-03-13 08:23:33');

-- --------------------------------------------------------

--
-- Table structure for table `pinned_messages`
--

CREATE TABLE `pinned_messages` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user1_id` bigint(20) UNSIGNED NOT NULL,
  `user2_id` bigint(20) UNSIGNED NOT NULL,
  `message_id` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `pinned_messages`
--

INSERT INTO `pinned_messages` (`id`, `user1_id`, `user2_id`, `message_id`, `created_at`, `updated_at`) VALUES
(9, 7, 9, 108, '2026-03-13 07:57:14', '2026-03-13 07:57:14');

-- --------------------------------------------------------

--
-- Table structure for table `reminders`
--

CREATE TABLE `reminders` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` enum('birthday','anniversary','recharge','custom') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'custom',
  `reminder_date` date NOT NULL,
  `repeat_type` enum('none','monthly','yearly') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'yearly',
  `mobile_number` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `sessions`
--

CREATE TABLE `sessions` (
  `id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_agent` text COLLATE utf8mb4_unicode_ci,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_activity` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `sessions`
--

INSERT INTO `sessions` (`id`, `user_id`, `ip_address`, `user_agent`, `payload`, `last_activity`) VALUES
('hMA9F3HESxOjNnBWH86eUGS4jybDXooczInYadID', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiRUZPOUY5VzBkQzczNVRYekE3SjdiUWhtM0xjUWIwOUVQMGZjN1dtTSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjE6Imh0dHA6Ly8xMjcuMC4wLjE6ODAwMCI7czo1OiJyb3V0ZSI7Tjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1773307474),
('J8rorL3PblaAEWC5ZeBe97TJcKKPw0Maw0W7nCVs', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiUmE5NXJ1c3VsUjZQdm1ieVNjZUZRcEJ1ckZGdXZjREEyd3RvSFp6TiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjE6Imh0dHA6Ly8xMjcuMC4wLjE6ODAwMCI7czo1OiJyb3V0ZSI7Tjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1773312491),
('pQSYqs0wpvWyrGJgZLik562a4o5Bt4njOr1Mxnb8', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiUjJSTDBTR2Q0WGNJcjI2ZTlpMm45M3JqakFMTUxkaHZUWUMyUlU4ciI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjE6Imh0dHA6Ly9sb2NhbGhvc3Q6ODAwMCI7czo1OiJyb3V0ZSI7Tjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1773383256);

-- --------------------------------------------------------

--
-- Table structure for table `transactions`
--

CREATE TABLE `transactions` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `type` enum('income','expense') COLLATE utf8mb4_unicode_ci NOT NULL,
  `category` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `amount` decimal(12,2) NOT NULL,
  `description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `date` date NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone` varchar(15) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `date_of_birth` date DEFAULT NULL,
  `address` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `city` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `profile_image` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `remember_token` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `name`, `email`, `phone`, `date_of_birth`, `address`, `city`, `profile_image`, `email_verified_at`, `password`, `remember_token`, `created_at`, `updated_at`) VALUES
(2, 'Final Handover User', 'handover_1741780751@example.com', NULL, NULL, NULL, NULL, NULL, NULL, '$2y$12$61SOuuDWf93OH5Kges3ANu16frECT5fYWvbmsP3mF7e.UdP00BUH.', NULL, '2026-03-12 06:30:59', '2026-03-12 06:30:59'),
(6, 'alice', 'alice@yopmail.com', NULL, NULL, NULL, NULL, 'avatars/6_ec4a7456-521a-4ede-ac61-7ed72ce7a327.jpg', NULL, '$2y$12$WeQJbmfgugjKVd6KIZS0DuQgkFQPkp6JV4uzaYbrj9V/dyDO1dLgO', NULL, '2026-03-13 01:18:02', '2026-03-13 03:26:54'),
(7, 'abhishek parmar', 'abhishek.webmyne@gmail.com', NULL, NULL, NULL, NULL, NULL, NULL, '$2y$12$rXbjG/obTxkBwkD3ht5ApuJL1BMNeVrOpDFYR0RNJyQYatpQwhP16', NULL, '2026-03-13 07:38:44', '2026-03-13 07:38:44'),
(8, 'taro bhai', 'tarobhai@gmail.com', NULL, NULL, NULL, NULL, NULL, NULL, '$2y$12$HJwN5QO3EtTPFqMY0ils9OHZKpJyYOLSNH1zbE/zv1JouWNgcyNRq', NULL, '2026-03-13 07:41:14', '2026-03-13 07:41:14'),
(9, 'rohan', 'rohan@yopmail.com', NULL, NULL, NULL, NULL, NULL, NULL, '$2y$12$RGNK3v7OYC8ofDMhK3ke0ezaCranRLU30dYYUaZkFby0kX4IWiYTK', NULL, '2026-03-13 07:55:35', '2026-03-13 07:55:35');

-- --------------------------------------------------------

--
-- Table structure for table `user_activities`
--

CREATE TABLE `user_activities` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `action` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `icon` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '?',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `user_activities`
--

INSERT INTO `user_activities` (`id`, `user_id`, `action`, `description`, `icon`, `created_at`, `updated_at`) VALUES
(46, 6, 'registered', 'Account created successfully', '🎉', '2026-03-13 01:18:02', '2026-03-13 01:18:02'),
(49, 6, 'logged_in', 'Signed in to your account', '🔐', '2026-03-13 01:51:13', '2026-03-13 01:51:13'),
(52, 6, 'profile_image_updated', 'Updated profile photo', '📷', '2026-03-13 03:25:05', '2026-03-13 03:25:05'),
(54, 6, 'profile_image_updated', 'Updated profile photo', '📷', '2026-03-13 03:26:54', '2026-03-13 03:26:54'),
(55, 7, 'registered', 'Account created successfully', '🎉', '2026-03-13 07:38:44', '2026-03-13 07:38:44'),
(56, 8, 'registered', 'Account created successfully', '🎉', '2026-03-13 07:41:14', '2026-03-13 07:41:14'),
(57, 9, 'registered', 'Account created successfully', '🎉', '2026-03-13 07:55:35', '2026-03-13 07:55:35'),
(58, 7, 'logged_in', 'Signed in to your account', '🔐', '2026-03-13 08:12:35', '2026-03-13 08:12:35'),
(59, 8, 'logged_in', 'Signed in to your account', '🔐', '2026-03-13 08:13:42', '2026-03-13 08:13:42');

-- --------------------------------------------------------

--
-- Table structure for table `user_blocks`
--

CREATE TABLE `user_blocks` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `blocker_id` bigint(20) UNSIGNED NOT NULL,
  `blocked_id` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `vehicles`
--

CREATE TABLE `vehicles` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` enum('car','bike','scooter','truck','auto','other') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'car',
  `registration_number` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `insurance_expiry` date DEFAULT NULL,
  `puc_expiry` date DEFAULT NULL,
  `last_service_date` date DEFAULT NULL,
  `next_service_date` date DEFAULT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `bills`
--
ALTER TABLE `bills`
  ADD PRIMARY KEY (`id`),
  ADD KEY `bills_user_id_foreign` (`user_id`);

--
-- Indexes for table `cache`
--
ALTER TABLE `cache`
  ADD PRIMARY KEY (`key`),
  ADD KEY `cache_expiration_index` (`expiration`);

--
-- Indexes for table `cache_locks`
--
ALTER TABLE `cache_locks`
  ADD PRIMARY KEY (`key`),
  ADD KEY `cache_locks_expiration_index` (`expiration`);

--
-- Indexes for table `documents`
--
ALTER TABLE `documents`
  ADD PRIMARY KEY (`id`),
  ADD KEY `documents_user_id_foreign` (`user_id`);

--
-- Indexes for table `failed_jobs`
--
ALTER TABLE `failed_jobs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`);

--
-- Indexes for table `jobs`
--
ALTER TABLE `jobs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `jobs_queue_reserved_at_available_at_index` (`queue`,`reserved_at`,`available_at`);

--
-- Indexes for table `job_batches`
--
ALTER TABLE `job_batches`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `medicines`
--
ALTER TABLE `medicines`
  ADD PRIMARY KEY (`id`),
  ADD KEY `medicines_user_id_foreign` (`user_id`);

--
-- Indexes for table `messages`
--
ALTER TABLE `messages`
  ADD PRIMARY KEY (`id`),
  ADD KEY `messages_sender_id_foreign` (`sender_id`),
  ADD KEY `messages_receiver_id_foreign` (`receiver_id`),
  ADD KEY `messages_reply_to_id_foreign` (`reply_to_id`);

--
-- Indexes for table `message_deletions`
--
ALTER TABLE `message_deletions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `message_deletions_user_id_message_id_unique` (`user_id`,`message_id`),
  ADD KEY `message_deletions_message_id_foreign` (`message_id`);

--
-- Indexes for table `message_reactions`
--
ALTER TABLE `message_reactions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `message_reactions_message_id_user_id_emoji_unique` (`message_id`,`user_id`,`emoji`),
  ADD KEY `message_reactions_user_id_foreign` (`user_id`);

--
-- Indexes for table `migrations`
--
ALTER TABLE `migrations`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `notes`
--
ALTER TABLE `notes`
  ADD PRIMARY KEY (`id`),
  ADD KEY `notes_user_id_foreign` (`user_id`);

--
-- Indexes for table `password_reset_tokens`
--
ALTER TABLE `password_reset_tokens`
  ADD PRIMARY KEY (`email`);

--
-- Indexes for table `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `personal_access_tokens_token_unique` (`token`),
  ADD KEY `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`,`tokenable_id`);

--
-- Indexes for table `pinned_messages`
--
ALTER TABLE `pinned_messages`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `pinned_messages_user1_id_user2_id_unique` (`user1_id`,`user2_id`),
  ADD KEY `pinned_messages_user2_id_foreign` (`user2_id`),
  ADD KEY `pinned_messages_message_id_foreign` (`message_id`);

--
-- Indexes for table `reminders`
--
ALTER TABLE `reminders`
  ADD PRIMARY KEY (`id`),
  ADD KEY `reminders_user_id_foreign` (`user_id`);

--
-- Indexes for table `sessions`
--
ALTER TABLE `sessions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `sessions_user_id_index` (`user_id`),
  ADD KEY `sessions_last_activity_index` (`last_activity`);

--
-- Indexes for table `transactions`
--
ALTER TABLE `transactions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `transactions_user_id_foreign` (`user_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `users_email_unique` (`email`);

--
-- Indexes for table `user_activities`
--
ALTER TABLE `user_activities`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_activities_user_id_foreign` (`user_id`);

--
-- Indexes for table `user_blocks`
--
ALTER TABLE `user_blocks`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `user_blocks_blocker_id_blocked_id_unique` (`blocker_id`,`blocked_id`),
  ADD KEY `user_blocks_blocked_id_foreign` (`blocked_id`);

--
-- Indexes for table `vehicles`
--
ALTER TABLE `vehicles`
  ADD PRIMARY KEY (`id`),
  ADD KEY `vehicles_user_id_foreign` (`user_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `bills`
--
ALTER TABLE `bills`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `documents`
--
ALTER TABLE `documents`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `failed_jobs`
--
ALTER TABLE `failed_jobs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `jobs`
--
ALTER TABLE `jobs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT for table `medicines`
--
ALTER TABLE `medicines`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `messages`
--
ALTER TABLE `messages`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=129;

--
-- AUTO_INCREMENT for table `message_deletions`
--
ALTER TABLE `message_deletions`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `message_reactions`
--
ALTER TABLE `message_reactions`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=35;

--
-- AUTO_INCREMENT for table `migrations`
--
ALTER TABLE `migrations`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- AUTO_INCREMENT for table `notes`
--
ALTER TABLE `notes`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT for table `pinned_messages`
--
ALTER TABLE `pinned_messages`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `reminders`
--
ALTER TABLE `reminders`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `transactions`
--
ALTER TABLE `transactions`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `user_activities`
--
ALTER TABLE `user_activities`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=60;

--
-- AUTO_INCREMENT for table `user_blocks`
--
ALTER TABLE `user_blocks`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `vehicles`
--
ALTER TABLE `vehicles`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `bills`
--
ALTER TABLE `bills`
  ADD CONSTRAINT `bills_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `documents`
--
ALTER TABLE `documents`
  ADD CONSTRAINT `documents_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `medicines`
--
ALTER TABLE `medicines`
  ADD CONSTRAINT `medicines_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `messages`
--
ALTER TABLE `messages`
  ADD CONSTRAINT `messages_receiver_id_foreign` FOREIGN KEY (`receiver_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `messages_reply_to_id_foreign` FOREIGN KEY (`reply_to_id`) REFERENCES `messages` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `messages_sender_id_foreign` FOREIGN KEY (`sender_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `message_deletions`
--
ALTER TABLE `message_deletions`
  ADD CONSTRAINT `message_deletions_message_id_foreign` FOREIGN KEY (`message_id`) REFERENCES `messages` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `message_deletions_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `message_reactions`
--
ALTER TABLE `message_reactions`
  ADD CONSTRAINT `message_reactions_message_id_foreign` FOREIGN KEY (`message_id`) REFERENCES `messages` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `message_reactions_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `notes`
--
ALTER TABLE `notes`
  ADD CONSTRAINT `notes_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `pinned_messages`
--
ALTER TABLE `pinned_messages`
  ADD CONSTRAINT `pinned_messages_message_id_foreign` FOREIGN KEY (`message_id`) REFERENCES `messages` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `pinned_messages_user1_id_foreign` FOREIGN KEY (`user1_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `pinned_messages_user2_id_foreign` FOREIGN KEY (`user2_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `reminders`
--
ALTER TABLE `reminders`
  ADD CONSTRAINT `reminders_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `transactions`
--
ALTER TABLE `transactions`
  ADD CONSTRAINT `transactions_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `user_activities`
--
ALTER TABLE `user_activities`
  ADD CONSTRAINT `user_activities_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `user_blocks`
--
ALTER TABLE `user_blocks`
  ADD CONSTRAINT `user_blocks_blocked_id_foreign` FOREIGN KEY (`blocked_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `user_blocks_blocker_id_foreign` FOREIGN KEY (`blocker_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `vehicles`
--
ALTER TABLE `vehicles`
  ADD CONSTRAINT `vehicles_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
