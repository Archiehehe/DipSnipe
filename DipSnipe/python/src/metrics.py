"""
Metrics calculation module - Simple day return focus
Tracks which stocks closed negative for the day
"""
import pandas as pd
import numpy as np
from typing import List, Dict, Optional

def compute_drawdown_metrics(bars: List[Dict]) -> Optional[Dict]:
    """
    Compute end-of-day performance metrics.
    
    Focus: Which stocks closed DOWN for the day?
    - Day Return %: (Close - Open) / Open * 100
    - Negative = Stock dropped (DIP)
    - Positive = Stock gained
    """
    if not bars:
        return None
        
    # Convert to DataFrame
    df = pd.DataFrame(bars)
    df = df.sort_values('timestamp')
    
    # Get opening price (first bar's open)
    open_price = df.iloc[0]['open']
    
    # Get closing price (last bar's close)
    close_price = df.iloc[-1]['close']
    
    # Calculate day return: (close - open) / open * 100
    day_return_pct = ((close_price - open_price) / open_price) * 100
    
    # Get intraday high and low for context
    intraday_high = df['high'].max()
    intraday_low = df['low'].min()
    
    # Calculate intraday range
    intraday_range_pct = ((intraday_high - intraday_low) / open_price) * 100
    
    # Find when the low occurred
    low_idx = df['low'].idxmin()
    low_time = df.loc[low_idx, 'timestamp']
    
    return {
        'max_drawdown_pct': float(day_return_pct),  # Reusing this field for day return
        'drawdown_time': low_time,  # When intraday low occurred
        'recovery_pct': float(intraday_range_pct),  # Intraday volatility
        'day_return_pct': float(day_return_pct),
        'open_price': float(open_price),
        'close_price': float(close_price),
        'intraday_low': float(intraday_low),
        'intraday_high': float(intraday_high)
    }
