"""Main script for computing intraday metrics"""
import logging
import sys
from pathlib import Path
from datetime import date
import time

# Add src to path
sys.path.insert(0, str(Path(__file__).parent))

from config_loader import load_config
from database import Database
from api_clients import YahooFinanceClient
from metrics import compute_drawdown_metrics

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def process_universe(db, yahoo_client, tickers, target_date, config):
    logger.info(f"Processing {len(tickers)} tickers for {target_date}")
    
    stats = {'processed': 0, 'skipped': 0, 'failed': 0}
    
    for t_obj in tickers:
        ticker = t_obj['ticker']
        
        # 1. Check if we already have metrics
        if db.check_metrics_exist(ticker, target_date):
            stats['skipped'] += 1
            continue
            
        # 2. Check if we have raw bars in DB cache
        bars = db.get_intraday_bars(ticker, target_date)
        source = 'cache'
        
        # 3. If no cache, fetch from Yahoo
        if not bars:
            bars = yahoo_client.get_intraday_bars(ticker, target_date)
            source = 'yahoo'
            
        # 4. Compute and Save
        if bars:
            metrics = compute_drawdown_metrics(bars)
            if metrics:
                db.save_metrics(ticker, target_date, metrics, source)
                # Cache the bars to save time later
                db.save_intraday_bars(ticker, bars)
                stats['processed'] += 1
                logger.info(f"Computed {ticker}: {metrics['max_drawdown_pct']}% DD")
            else:
                stats['failed'] += 1
        else:
            stats['failed'] += 1
            logger.warning(f"No data for {ticker}")
            
    logger.info(f"Run Stats: {stats}")

def main():
    if len(sys.argv) < 2:
        print("Usage: python compute_metrics.py YYYY-MM-DD [TICKER ...]")
        sys.exit(1)
    
    try:
        target_date = date.fromisoformat(sys.argv[1])
    except ValueError:
        print("Error: Date must be in YYYY-MM-DD format")
        sys.exit(1)

    # Optional: specific tickers from command line
    specific_tickers = sys.argv[2:] if len(sys.argv) > 2 else None

    config = load_config()
    db = Database(config['database'])
    
    # Init Client (Only Yahoo now)
    yahoo_client = YahooFinanceClient()
    
    try:
        db.connect()
        
        if specific_tickers:
            tickers = [{'ticker': t} for t in specific_tickers]
        else:
            tickers = db.get_filtered_tickers(
                min_market_cap=config['universe']['min_market_cap']
            )
        
        process_universe(db, yahoo_client, tickers, target_date, config)
        
    finally:
        db.close()

if __name__ == "__main__":
    main()
