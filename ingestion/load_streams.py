import json
import os
import glob
import psycopg2
from psycopg2.extras import execute_values

DB_CONFIG = {
    "host": os.getenv("DB_HOST", "localhost"),
    "port": os.getenv("DB_PORT", 5432),
    "dbname": os.getenv("DB_NAME", "spotify"),
    "user": os.getenv("DB_USER", "postgres"),
    "password": os.getenv("DB_PASSWORD", ""),
}

DATA_DIR = os.path.join(os.path.dirname(__file__), "../data/raw")


def get_connection():
    return psycopg2.connect(**DB_CONFIG)


def create_raw_table(conn):
    with conn.cursor() as cur:
        cur.execute("""
            CREATE SCHEMA IF NOT EXISTS raw;

            CREATE TABLE IF NOT EXISTS raw.streams (
                id          SERIAL PRIMARY KEY,
                end_time    TIMESTAMP NOT NULL,
                artist_name TEXT,
                track_name  TEXT,
                ms_played   INTEGER NOT NULL,
                loaded_at   TIMESTAMPTZ DEFAULT NOW()
            );

            CREATE UNIQUE INDEX IF NOT EXISTS streams_dedup
                ON raw.streams (end_time, artist_name, track_name);
        """)
    conn.commit()
    print("raw.streams table ready.")


def parse_record(entry):
    """Map a raw JSON entry to a tuple matching the table columns."""
    return (
        entry.get("endTime"),
        entry.get("artistName"),
        entry.get("trackName"),
        entry.get("msPlayed", 0),
    )


def load_file(conn, filepath):
    with open(filepath, "r", encoding="utf-8") as f:
        entries = json.load(f)

    records = [parse_record(e) for e in entries]

    with conn.cursor() as cur:
        execute_values(
            cur,
            """
            INSERT INTO raw.streams (end_time, artist_name, track_name, ms_played)
            VALUES %s
            ON CONFLICT (end_time, artist_name, track_name) DO NOTHING
            """,
            records,
        )
        inserted = cur.rowcount

    conn.commit()
    print(f"  {os.path.basename(filepath)}: {len(records)} records parsed, {inserted} inserted.")
    return len(records)


def main():
    pattern = os.path.join(DATA_DIR, "StreamingHistory_music_*.json")
    files = sorted(glob.glob(pattern))

    if not files:
        print(f"No streaming history files found in {DATA_DIR}")
        return

    print(f"Found {len(files)} file(s) to load.")

    conn = get_connection()
    try:
        create_raw_table(conn)
        total = 0
        for filepath in files:
            total += load_file(conn, filepath)
        print(f"\nDone. {total} total records processed.")
    finally:
        conn.close()


if __name__ == "__main__":
    main()