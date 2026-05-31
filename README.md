# 📰 data-engineering-environment-news

> A modular, fully local data-engineering workspace for experimenting with news ingestion, processing, enrichment, and analytics.

This repository provides a reproducible environment for building and testing ETL/ELT pipelines, running scrapers, orchestrating workflows, and performing exploratory analysis on news datasets — all without any cloud dependency.

---

## Overview

The project is designed around a **local-first** philosophy: every component runs on your machine, data is stored in DuckDB, and notebooks serve as the primary interface for exploration and analysis. It is intentionally kept lightweight so you can clone it, run the setup script, and start experimenting within minutes.

Key use cases:

- Ingesting news articles from external APIs with incremental loading via `dlt`
- Storing and querying structured news data in DuckDB
- Exploring and enriching datasets interactively in Jupyter notebooks
- Prototyping ETL/ELT pipelines before porting them to production environments

---

## Project Structure

```
data-engineering-environment-news/
├── notebooks/          # Jupyter notebooks for exploration and pipeline prototyping
├── output/             # Pipeline outputs and query results
├── requirements.txt    # Python dependencies
├── setup.sh            # One-command environment bootstrap
├── .env                # Environment variables (auto-generated on first setup)
└── .gitignore
```

---

## Tech Stack

| Tool | Role |
|------|------|
| [`dlt`](https://dlthub.com/) | Incremental data ingestion & pipeline framework |
| [`DuckDB`](https://duckdb.org/) | Local analytical database (storage & query layer) |
| `Jupyter` | Interactive exploration & notebook-based workflows |
| `pandas` / `numpy`/ `polars`  | Data manipulation and transformation |
| `python-dotenv` | Environment variable management |

---

## Getting Started

### Prerequisites

- Python 3.9 or higher
- `git`

### Setup

Clone the repository and run the setup script:

```bash
git clone https://github.com/marcogaudio/data-engineering-environment-news.git
cd data-engineering-environment-news
chmod +x setup.sh
./setup.sh
```

The script will:
1. Verify your Python version (≥ 3.9 required)
2. Create and activate a virtual environment (`env/`)
3. Install all dependencies from `requirements.txt`
4. Create the `output/` directory
5. Generate a `.env` file with default configuration

### Activate the environment (subsequent runs)

```bash
source env/bin/activate
```

### Launch Jupyter

```bash
jupyter lab
```

---

## Configuration

The `.env` file is auto-generated during setup and controls the main runtime parameters:

```env
PIPELINE_NAME=local_data
DATASET_NAME=my_data
DATA_DIR=./data
OUTPUT_DIR=./output

# Jupyter
JUPYTER_ENABLE_LAB=yes
JUPYTER_TOKEN=your_token_here
```

If you are connecting to a news API, add your API key here:

```env
NEWS_API_KEY=your_api_key_here
```

---

## Incremental Loading with dlt

The pipeline uses `dlt`'s built-in incremental loading to avoid re-fetching already-ingested articles. State is persisted locally between runs.

```python
import dlt
from dlt.sources.incremental import Incremental

@dlt.resource(name="articles", write_disposition="append", primary_key="id")
def fetch_news(
    published_at: Incremental[str] = dlt.sources.incremental(
        "published_at",
        initial_value="2024-01-01T00:00:00Z"
    )
):
    # On each run, only articles newer than the last seen `published_at` are fetched
    ...

pipeline = dlt.pipeline(
    pipeline_name="news_pipeline",
    destination="duckdb",
    dataset_name="raw_news"
)
pipeline.run(fetch_news())
```

On the first run, it performs a full bootstrap from `initial_value`. All subsequent runs only pull new records, using the cursor stored in `~/.dlt/pipelines/<pipeline_name>/state/`.

---

## Querying the Data

Once the pipeline has run, you can query the DuckDB database directly from a notebook or Python script:

```python
import duckdb

conn = duckdb.connect("news_pipeline.duckdb")
df = conn.execute("SELECT * FROM raw_news.articles ORDER BY published_at DESC LIMIT 20").df()
print(df)
```

---

## Roadmap

- [ ] Add scraper module for RSS feeds
- [ ] NLP enrichment layer (sentiment analysis, NER)
- [ ] Scheduled pipeline execution (cron / Prefect)
- [ ] Support for additional destinations (PostgreSQL, Parquet)
- [ ] Dashboard notebook with aggregated news analytics

---

## License

This project is licensed under the [MIT License](LICENSE).

---

## Author

**Marco Gaudio** — [github.com/marcogaudio](https://github.com/marcogaudio)