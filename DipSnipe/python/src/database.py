"""SQLite Database operations for DipHunter - Enhanced Version"""
import sqlite3
import logging
from typing import List, Dict, Optional
from datetime import date, datetime

logger = logging.getLogger(__name__)

class Database:
    """SQLite database connection and operations"""
    
    def __init__(self, config: dict):
        self.db_file = config['file']
        self.conn = None
    
    def connect(self):
        """Establish database connection"""
        try:
            self.conn = sqlite3.connect(self.db_file, check_same_thread=False)
            self.conn.row_factory = sqlite3.Row
            self.conn.execute("PRAGMA journal_mode=WAL;")
            logger.info(f"Connected to SQLite: {self.db_file}")
            self._create_tables()
        except Exception as e:
            logger.error(f"Failed to connect to database: {e}")
            raise

    def _create_tables(self):
        """Initialize schema automatically"""
        schema = """
        CREATE TABLE IF NOT EXISTS tickers (
            ticker TEXT PRIMARY KEY,
            sector TEXT,
            industry TEXT,
            market_cap INTEGER,
            avg_volume INTEGER,
            last_updated TEXT
        );
        
        CREATE INDEX IF NOT EXISTS idx_tickers_cap ON tickers(market_cap);
        CREATE INDEX IF NOT EXISTS idx_tickers_sector ON tickers(sector);
        CREATE INDEX IF NOT EXISTS idx_tickers_industry ON tickers(industry);

        CREATE TABLE IF NOT EXISTS intraday_metrics (
            ticker TEXT NOT NULL,
            date TEXT NOT NULL,
            max_drawdown_pct REAL,
            drawdown_time TEXT,
            recovery_pct REAL,
            data_source TEXT,
            computed_at TEXT,
            PRIMARY KEY (ticker, date),
            FOREIGN KEY (ticker) REFERENCES tickers(ticker) ON DELETE CASCADE
        );

        CREATE TABLE IF NOT EXISTS intraday_bars (
            ticker TEXT NOT NULL,
            timestamp TEXT NOT NULL,
            open REAL,
            high REAL,
            low REAL,
            close REAL,
            PRIMARY KEY (ticker, timestamp),
            FOREIGN KEY (ticker) REFERENCES tickers(ticker) ON DELETE CASCADE
        );
        """
        self.conn.executescript(schema)
        self.conn.commit()
        logger.info("Database schema verified")
    
    def close(self):
        if self.conn:
            self.conn.close()
            logger.info("Database connection closed")
    
    def __enter__(self):
        self.connect()
        return self
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        self.close()

    def get_filtered_tickers(
        self, 
        min_market_cap: int = 0,
        max_market_cap: int = None,
        min_volume: int = 0,
        sector: str = None,
        industry: str = None
    ) -> List[Dict]:
        """Get tickers with comprehensive filters"""
        query = """
            SELECT ticker, sector, industry, market_cap, avg_volume 
            FROM tickers 
            WHERE market_cap >= ?
        """
        params = [min_market_cap]
        
        if max_market_cap:
            query += " AND market_cap <= ?"
            params.append(max_market_cap)
            
        if min_volume > 0:
            query += " AND COALESCE(avg_volume, 0) >= ?"
            params.append(min_volume)
            
        if sector:
            query += " AND sector = ?"
            params.append(sector)
            
        if industry:
            query += " AND industry = ?"
            params.append(industry)
            
        query += " ORDER BY market_cap DESC"
        
        cur = self.conn.cursor()
        cur.execute(query, params)
        return [dict(row) for row in cur.fetchall()]

    def get_sectors(self) -> List[str]:
        """Get list of unique sectors"""
        cur = self.conn.cursor()
        cur.execute("""
            SELECT DISTINCT sector 
            FROM tickers 
            WHERE sector IS NOT NULL AND sector != '' 
            ORDER BY sector
        """)
        sectors = [row['sector'] for row in cur.fetchall()]
        logger.debug(f"Found {len(sectors)} unique sectors")
        return sectors

    def get_industries(self, sector: str = None) -> List[str]:
        """Get list of industries, optionally filtered by sector"""
        query = """
            SELECT DISTINCT industry 
            FROM tickers 
            WHERE industry IS NOT NULL AND industry != ''
        """
        params = []
        
        if sector:
            query += " AND sector = ?"
            params.append(sector)
            
        query += " ORDER BY industry"
        
        cur = self.conn.cursor()
        cur.execute(query, params)
        industries = [row['industry'] for row in cur.fetchall()]
        logger.debug(f"Found {len(industries)} unique industries")
        return industries

    def check_metrics_exist(self, ticker: str, target_date: date) -> bool:
        """Check if metrics already computed for ticker/date"""
        cur = self.conn.cursor()
        date_str = target_date.isoformat()
        cur.execute(
            "SELECT 1 FROM intraday_metrics WHERE ticker = ? AND date = ?",
            (ticker, date_str)
        )
        return cur.fetchone() is not None

    def save_metrics(self, ticker: str, target_date: date, metrics: Dict, source: str):
        """Save computed metrics to database"""
        date_str = target_date.isoformat()
        dd_time_str = metrics['drawdown_time'].isoformat() if metrics['drawdown_time'] else None
        
        cur = self.conn.cursor()
        cur.execute(
            """INSERT OR REPLACE INTO intraday_metrics 
               (ticker, date, max_drawdown_pct, drawdown_time, recovery_pct, data_source, computed_at)
               VALUES (?, ?, ?, ?, ?, ?, datetime('now'))""",
            (
                ticker, 
                date_str, 
                metrics['max_drawdown_pct'],
                dd_time_str,
                metrics['recovery_pct'],
                source
            )
        )
        self.conn.commit()
        logger.debug(f"Saved metrics for {ticker} on {date_str}")

    def get_metrics(
        self, 
        target_date: date,
        min_market_cap: int = 0,
        max_market_cap: int = None,
        min_volume: int = 0,
        sector: str = None,
        industry: str = None
    ) -> List[Dict]:
        """Get metrics with comprehensive filtering"""
        date_str = target_date.isoformat()
        
        query = """
            SELECT 
                m.ticker,
                m.max_drawdown_pct,
                m.drawdown_time,
                m.recovery_pct,
                m.data_source,
                t.sector,
                t.industry,
                t.market_cap,
                t.avg_volume
            FROM intraday_metrics m
            JOIN tickers t ON m.ticker = t.ticker
            WHERE m.date = ?
            AND t.market_cap >= ?
        """
        params = [date_str, min_market_cap]
        
        if max_market_cap:
            query += " AND t.market_cap <= ?"
            params.append(max_market_cap)
            
        if min_volume > 0:
            query += " AND COALESCE(t.avg_volume, 0) >= ?"
            params.append(min_volume)
        
        if sector:
            query += " AND t.sector = ?"
            params.append(sector)
            
        if industry:
            query += " AND t.industry = ?"
            params.append(industry)
            
        query += " ORDER BY m.max_drawdown_pct ASC"
        
        cur = self.conn.cursor()
        cur.execute(query, params)
        results = [dict(row) for row in cur.fetchall()]
        logger.debug(f"Retrieved {len(results)} metrics for {date_str}")
        return results

    def get_intraday_bars(self, ticker: str, target_date: date) -> List[Dict]:
        """Get intraday bars for ticker on specific date"""
        date_str_start = f"{target_date.isoformat()}T00:00:00"
        date_str_end = f"{target_date.isoformat()}T23:59:59"
        
        cur = self.conn.cursor()
        cur.execute(
            """SELECT timestamp, open, high, low, close
               FROM intraday_bars
               WHERE ticker = ? AND timestamp >= ? AND timestamp <= ?
               ORDER BY timestamp""",
            (ticker, date_str_start, date_str_end)
        )
        
        rows = []
        for row in cur.fetchall():
            d = dict(row)
            d['timestamp'] = datetime.fromisoformat(d['timestamp'])
            rows.append(d)
        
        logger.debug(f"Retrieved {len(rows)} bars for {ticker}")
        return rows
    
    def save_intraday_bars(self, ticker: str, bars: List[Dict]):
        """Save intraday bars to database"""
        if not bars:
            return
        
        data = []
        for bar in bars:
            data.append((
                ticker,
                bar['timestamp'].isoformat(),
                bar['open'],
                bar['high'],
                bar['low'],
                bar['close']
            ))
            
        cur = self.conn.cursor()
        cur.executemany(
            """INSERT OR IGNORE INTO intraday_bars 
               (ticker, timestamp, open, high, low, close)
               VALUES (?, ?, ?, ?, ?, ?)""",
            data
        )
        self.conn.commit()
        logger.debug(f"Saved {len(data)} bars for {ticker}")

    def get_stats(self) -> Dict:
        """Get database statistics"""
        cur = self.conn.cursor()
        
        # Count tickers
        cur.execute("SELECT COUNT(*) as count FROM tickers")
        ticker_count = cur.fetchone()['count']
        
        # Count metrics
        cur.execute("SELECT COUNT(*) as count FROM intraday_metrics")
        metrics_count = cur.fetchone()['count']
        
        # Count unique dates with metrics
        cur.execute("SELECT COUNT(DISTINCT date) as count FROM intraday_metrics")
        dates_count = cur.fetchone()['count']
        
        # Get date range
        cur.execute("SELECT MIN(date) as min_date, MAX(date) as max_date FROM intraday_metrics")
        date_range = cur.fetchone()
        
        return {
            'total_tickers': ticker_count,
            'total_metrics': metrics_count,
            'unique_dates': dates_count,
            'date_range': {
                'min': date_range['min_date'],
                'max': date_range['max_date']
            }
        }
