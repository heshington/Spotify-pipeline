# spotify_pipeline

A data engineering project that ingests Spotify listening history into Postgres
and transforms it with dbt for personal listening analysis.

## Project structure

```
spotify_pipeline/
├── data/
│   └── raw/                  # Drop your Spotify JSON files here
├── ingestion/
│   ├── load_streams.py       # Loads JSON → raw.streams
│   └── requirements.txt
└── dbt/
    └── models/
        ├── staging/          # stg_plays, stg_artists
        └── marts/            # mart_daily_listens, mart_top_artists, etc.
```

## Setup

### 1. Create a Postgres database

```sql
CREATE DATABASE spotify;
```

### 2. Install Python dependencies

```bash
cd ingestion
pip install -r requirements.txt
```

### 3. Set environment variables

```bash
export DB_HOST=localhost
export DB_PORT=5432
export DB_NAME=spotify
export DB_USER=postgres
export DB_PASSWORD=yourpassword
```

### 4. Drop your Spotify JSON files into data/raw/

Files should be named `Streaming_History_Audio_0.json`, `_1.json`, etc.
These come from your Spotify data download (account privacy settings).

### 5. Run the ingestion script

```bash
python ingestion/load_streams.py
```

### 6. Run dbt models (once dbt is set up)

```bash
cd dbt
dbt run
```

## What the ingestion script does

- Reads all `Streaming_History_Audio_*.json` files from `data/raw/`
- Creates the `raw` schema and `raw.streams` table if they don't exist
- Inserts records, skipping duplicates (idempotent — safe to re-run)
- Logs how many records were parsed and inserted per file
