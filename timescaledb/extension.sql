-- ===========================================
-- Extensions catalog (uncomment to activate)
-- ===========================================

-- TimescaleDB ecosystem
CREATE EXTENSION IF NOT EXISTS timescaledb;                  -- hypertables, continuous aggregates, compression, retention
-- CREATE EXTENSION IF NOT EXISTS timescaledb_toolkit;       -- percentile approximations, time-weighted averages, LTTB downsampling

-- Data types
CREATE EXTENSION IF NOT EXISTS citext;                       -- case-insensitive text data type
CREATE EXTENSION IF NOT EXISTS hstore;                       -- key-value store data type
CREATE EXTENSION IF NOT EXISTS ltree;                        -- hierarchical label tree data type
-- CREATE EXTENSION IF NOT EXISTS intarray;                  -- integer array functions and operators
-- CREATE EXTENSION IF NOT EXISTS cube;                      -- multi-dimensional cube data type
-- CREATE EXTENSION IF NOT EXISTS seg;                       -- line segment / floating-point interval data type
-- CREATE EXTENSION IF NOT EXISTS isn;                       -- international standard numbers (ISBN, ISSN, etc.)

-- UUID
CREATE EXTENSION IF NOT EXISTS pg_uuidv7;                    -- UUID v7 generation (time-sortable, recommended for PKs)
-- CREATE EXTENSION IF NOT EXISTS "uuid-ossp";               -- UUID v1/v3/v5 generation (legacy, v4 already in PG core)

-- Crypto
CREATE EXTENSION IF NOT EXISTS pgcrypto;                     -- hashing, encryption, random bytes

-- Text search & fuzzy matching
CREATE EXTENSION IF NOT EXISTS pg_trgm;                      -- trigram-based fuzzy text matching, LIKE/ILIKE acceleration
CREATE EXTENSION IF NOT EXISTS unaccent;                     -- accent-insensitive search
CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;                -- Soundex, Levenshtein, Double Metaphone
-- CREATE EXTENSION IF NOT EXISTS dict_int;                  -- integer dictionary for text search
-- CREATE EXTENSION IF NOT EXISTS dict_xsyn;                 -- extended synonym dictionary for text search

-- Vector / AI
CREATE EXTENSION IF NOT EXISTS vector;                       -- vector similarity search (embeddings, HNSW, IVFFlat)
-- CREATE EXTENSION IF NOT EXISTS pgvectorscale;             -- improved pgvector performance

-- Geospatial
CREATE EXTENSION IF NOT EXISTS postgis;                      -- geometry/geography types, spatial indexes, ST_* functions
-- CREATE EXTENSION IF NOT EXISTS postgis_topology;          -- topological data models
-- CREATE EXTENSION IF NOT EXISTS postgis_raster;            -- raster/gridded data
-- CREATE EXTENSION IF NOT EXISTS postgis_sfcgal;            -- advanced 3D geometry functions
-- CREATE EXTENSION IF NOT EXISTS address_standardizer;      -- address parsing/normalization
-- CREATE EXTENSION IF NOT EXISTS address_standardizer_data_us; -- US address data
-- CREATE EXTENSION IF NOT EXISTS earthdistance;             -- great-circle distance (requires cube, redundant with PostGIS)

-- Indexing
-- CREATE EXTENSION IF NOT EXISTS btree_gist;                -- GiST index operator classes (exclusion constraints)
-- CREATE EXTENSION IF NOT EXISTS btree_gin;                 -- GIN index operator classes (composite indexes)
-- CREATE EXTENSION IF NOT EXISTS bloom;                     -- bloom filter index access method

-- Partitioning
-- CREATE EXTENSION IF NOT EXISTS pg_partman;                -- automated partition management (NOT on hypertables)

-- Monitoring / Administration
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;           -- query performance statistics
CREATE EXTENSION IF NOT EXISTS pg_cron;                      -- in-database cron-based job scheduler
-- CREATE EXTENSION IF NOT EXISTS auto_explain;              -- automatic EXPLAIN logging for slow queries
-- CREATE EXTENSION IF NOT EXISTS pgstattuple;               -- tuple-level statistics
-- CREATE EXTENSION IF NOT EXISTS pg_buffercache;            -- buffer cache inspection
-- CREATE EXTENSION IF NOT EXISTS pg_prewarm;                -- buffer cache prewarming
-- CREATE EXTENSION IF NOT EXISTS pg_visibility;             -- visibility map examination
-- CREATE EXTENSION IF NOT EXISTS pg_freespacemap;           -- free-space map examination
-- CREATE EXTENSION IF NOT EXISTS pg_walinspect;             -- WAL inspection functions
-- CREATE EXTENSION IF NOT EXISTS pg_surgery;                -- low-level tuple surgery (recovery use)
-- CREATE EXTENSION IF NOT EXISTS pgaudit;                   -- audit logging
-- CREATE EXTENSION IF NOT EXISTS pg_qualstats;              -- query predicate statistics
-- CREATE EXTENSION IF NOT EXISTS pg_stat_kcache;            -- kernel cache statistics
-- CREATE EXTENSION IF NOT EXISTS pg_stat_monitor;           -- enhanced query monitoring

-- Foreign data wrappers
-- CREATE EXTENSION IF NOT EXISTS postgres_fdw;              -- query remote PostgreSQL servers
-- CREATE EXTENSION IF NOT EXISTS file_fdw;                  -- query flat files (CSV/TSV) as tables
-- CREATE EXTENSION IF NOT EXISTS dblink;                    -- connect to other PostgreSQL databases

-- Replication / Logical
-- CREATE EXTENSION IF NOT EXISTS pglogical;                 -- logical replication
-- CREATE EXTENSION IF NOT EXISTS wal2json;                  -- WAL to JSON output plugin

-- Other data structures
-- CREATE EXTENSION IF NOT EXISTS hll;                       -- HyperLogLog (approximate distinct counts)
-- CREATE EXTENSION IF NOT EXISTS rum;                       -- RUM index (enhanced GIN for full-text search + ranking)
-- CREATE EXTENSION IF NOT EXISTS ip4r;                      -- IP address range data type
-- CREATE EXTENSION IF NOT EXISTS semver;                    -- semantic versioning data type
-- CREATE EXTENSION IF NOT EXISTS tablefunc;                 -- crosstab / pivot table functions

-- Table maintenance
-- CREATE EXTENSION IF NOT EXISTS pg_repack;                 -- online table compaction (no locks)
-- CREATE EXTENSION IF NOT EXISTS pg_squeeze;                -- online table compaction (alternative)

-- Procedural languages
-- CREATE EXTENSION IF NOT EXISTS plpython3u;                -- PL/Python (untrusted, Python 3)
-- CREATE EXTENSION IF NOT EXISTS plperl;                    -- PL/Perl

-- Encoding / Large objects
-- CREATE EXTENSION IF NOT EXISTS lo;                        -- large object maintenance
-- CREATE EXTENSION IF NOT EXISTS xml2;                      -- XPath and XSLT functions

-- Sampling
-- CREATE EXTENSION IF NOT EXISTS tsm_system_rows;           -- TABLESAMPLE method by row count
-- CREATE EXTENSION IF NOT EXISTS tsm_system_time;           -- TABLESAMPLE method by time

-- Integrity checking
-- CREATE EXTENSION IF NOT EXISTS amcheck;                   -- B-tree and heap integrity checking
-- CREATE EXTENSION IF NOT EXISTS pageinspect;               -- low-level page inspection

-- Connection / Security
-- CREATE EXTENSION IF NOT EXISTS sslinfo;                   -- SSL connection information
-- CREATE EXTENSION IF NOT EXISTS orafce;                    -- Oracle compatibility functions
-- CREATE EXTENSION IF NOT EXISTS hypopg;                    -- hypothetical indexes (what-if analysis)
-- CREATE EXTENSION IF NOT EXISTS pgtap;                     -- unit testing framework for PostgreSQL
