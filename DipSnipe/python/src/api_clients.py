"""API clients for fetching market data with Simulation Fallback"""
import logging
import random
import time
from datetime import date, datetime, timedelta
from typing import List, Dict
import yfinance as yf
import pandas as pd
import numpy as np

logger = logging.getLogger(__name__)

class YahooFinanceClient:
    """Client for Yahoo Finance with Synthetic Fallback"""
    
    def __init__(self, rate_limit: int = 60):
        self.rate_limit = rate_limit
    
    def get_intraday_bars(self, ticker: str, target_date: date) -> List[Dict]:
        """
        Attempts to fetch real data. If blocked/empty, generates synthetic data
        so the dashboard can still be demonstrated.
        """
        bars = self._fetch_real_data(ticker, target_date)
        
        if not bars:
            logger.warning(f"Yahoo API failed for {ticker}. Switching to SIMULATION MODE.")
            return self._generate_synthetic_data(ticker, target_date)
        
        return bars

    def _fetch_real_data(self, ticker: str, target_date: date) -> List[Dict]:
        """Try to fetch real 1-hour bars from Yahoo."""
        try:
            # Sleep to be nice to API
            time.sleep(1.0)
            
            # Define window: Start of target date to End of target date
            start = datetime.combine(target_date, datetime.min.time())
            end = start + timedelta(days=1)
            
            stock = yf.Ticker(ticker)
            
            # Attempt 1h fetch
            df = stock.history(start=start, end=end, interval="1h", auto_adjust=True)
            
            if df.empty:
                return []
            
            bars = []
            for idx, row in df.iterrows():
                bar_date = idx.to_pydatetime()
                if bar_date.date() == target_date:
                    bars.append({
                        'timestamp': bar_date,
                        'open': float(row['Open']),
                        'high': float(row['High']),
                        'low': float(row['Low']),
                        'close': float(row['Close'])
                    })
            return bars
            
        except Exception as e:
            logger.error(f"Real data fetch failed: {e}")
            return []

    def _generate_synthetic_data(self, ticker: str, target_date: date) -> List[Dict]:
        """Generates realistic-looking intraday price action."""
        logger.info(f"Generating synthetic data for {ticker} on {target_date}")
        
        # Seed random for consistent "fake" charts per ticker
        random.seed(ticker)
        
        # Base price roughly based on ticker length to vary it (Arbitrary)
        price = 100.0 + (len(ticker) * 20) + random.randint(-10, 10)
        
        bars = []
        # Create 7 hourly bars (9:30 AM to 3:30 PM)
        start_time = datetime.combine(target_date, datetime.strptime("09:30", "%H:%M").time())
        
        for i in range(7):
            timestamp = start_time + timedelta(hours=i)
            
            # Random walk
            change = random.uniform(-0.02, 0.02) # +/- 2% moves
            open_p = price
            close_p = price * (1 + change)
            high_p = max(open_p, close_p) * (1 + random.uniform(0, 0.005))
            low_p = min(open_p, close_p) * (1 - random.uniform(0, 0.005))
            
            bars.append({
                'timestamp': timestamp,
                'open': round(open_p, 2),
                'high': round(high_p, 2),
                'low': round(low_p, 2),
                'close': round(close_p, 2)
            })
            
            # Update price for next bar
            price = close_p
            
        return bars
