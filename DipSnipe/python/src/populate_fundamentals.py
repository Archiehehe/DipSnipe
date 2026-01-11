"""Script to populate ticker fundamentals table"""
import logging
import sys
from pathlib import Path
import yfinance as yf
import time
import requests
import pandas as pd
from io import StringIO

sys.path.insert(0, str(Path(__file__).parent))

from config_loader import load_config
from database import Database

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def get_sp500_tickers():
    """Get S&P 500 ticker list with browser headers"""
    try:
        url = "https://en.wikipedia.org/wiki/List_of_S%26P_500_companies"
        # Pretend to be a browser to avoid 403 Forbidden
        headers = {
            "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
        }
        response = requests.get(url, headers=headers)
        response.raise_for_status() # Check if the request actually worked
        
        # Wrap in StringIO to fix the FutureWarning
        tables = pd.read_html(StringIO(response.text))
        sp500_table = tables[0]
        return sp500_table['Symbol'].tolist()
    except Exception as e:
        logger.error(f"Error fetching S&P 500 list: {e}")
        return []

def fetch_ticker_fundamentals(ticker: str) -> dict:
    try:
        stock = yf.Ticker(ticker)
        info = stock.info
        
        market_cap = info.get('marketCap', 0)
        if not market_cap:
            market_cap = info.get('enterpriseValue', 0)
            
        return {
            'ticker': ticker,
            'sector': info.get('sector', 'Unknown'),
            'industry': info.get('industry', 'Unknown'),
            'market_cap': market_cap
        }
    except Exception as e:
        return None

def populate_fundamentals(db: Database, tickers: list = None):
    if tickers is None:
        logger.info("Fetching S&P 500 list...")
        tickers = get_sp500_tickers()
    
    if not tickers:
        logger.error("No tickers found. Aborting.")
        return

    logger.info(f"Processing {len(tickers)} tickers...")
    
    successful = 0
    
    for i, ticker in enumerate(tickers):
        yf_ticker = ticker.replace('.', '-')
        fundamentals = fetch_ticker_fundamentals(yf_ticker)
        
        if fundamentals:
            fundamentals['ticker'] = ticker
            try:
                # SQLite syntax: INSERT OR REPLACE
                cur = db.conn.cursor()
                cur.execute(
                    """INSERT OR REPLACE INTO tickers (ticker, sector, industry, market_cap, last_updated)
                       VALUES (?, ?, ?, ?, datetime('now'))""",
                    (
                        fundamentals['ticker'],
                        fundamentals['sector'],
                        fundamentals['industry'],
                        fundamentals['market_cap']
                    )
                )
                db.conn.commit()
                successful += 1
            except Exception as e:
                logger.error(f"DB Error saving {ticker}: {e}")
        
        if i % 10 == 0:
            print(f"Progress: {i}/{len(tickers)}")
        time.sleep(0.1) # Be nice to Yahoo
    
    logger.info(f"Completed: {successful} successful")

def main():
    config = load_config()
    db = Database(config['database'])
    try:
        db.connect()
        populate_fundamentals(db)
    finally:
        db.close()

if __name__ == "__main__":
    main()
