-- DipHunter Database Schema
-- PostgreSQL database for storing ticker fundamentals and intraday metrics

-- Tickers table: stores fundamental data for universe filtering
CREATE TABLE IF NOT EXISTS tickers (
    ticker VARCHAR(10) PRIMARY KEY,
    sector VARCHAR(100),
    industry VARCHAR(100),
    market_cap BIGINT,  -- Market cap in dollars
    avg_volume BIGINT,  -- Average daily volume
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Index for efficient filtering
CREATE INDEX IF NOT EXISTS idx_tickers_market_cap ON tickers(market_cap);
CREATE INDEX IF NOT EXISTS idx_tickers_sector ON tickers(sector);
CREATE INDEX IF NOT EXISTS idx_tickers_avg_volume ON tickers(avg_volume);

-- Intraday metrics table: stores computed drawdown metrics per ticker per date
CREATE TABLE IF NOT EXISTS intraday_metrics (
    ticker VARCHAR(10) NOT NULL,
    date DATE NOT NULL,
    max_drawdown_pct DECIMAL(10, 4),  -- Maximum drawdown percentage
    drawdown_time TIMESTAMP,  -- Timestamp when max drawdown occurred
    recovery_pct DECIMAL(10, 4),  -- Recovery percentage from low to close
    data_source VARCHAR(50),  -- 'polygon', 'yahoo', etc.
    computed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (ticker, date),
    FOREIGN KEY (ticker) REFERENCES tickers(ticker) ON DELETE CASCADE
);

-- Index for efficient date-based queries
CREATE INDEX IF NOT EXISTS idx_intraday_metrics_date ON intraday_metrics(date);
CREATE INDEX IF NOT EXISTS idx_intraday_metrics_drawdown ON intraday_metrics(max_drawdown_pct);

-- Raw intraday bars table (optional, for visualization and debugging)
CREATE TABLE IF NOT EXISTS intraday_bars (
    ticker VARCHAR(10) NOT NULL,
    timestamp TIMESTAMP NOT NULL,
    open DECIMAL(12, 4),
    high DECIMAL(12, 4),
    low DECIMAL(12, 4),
    close DECIMAL(12, 4),
    volume BIGINT,
    PRIMARY KEY (ticker, timestamp),
    FOREIGN KEY (ticker) REFERENCES tickers(ticker) ON DELETE CASCADE
);

-- Index for efficient time-series queries
CREATE INDEX IF NOT EXISTS idx_intraday_bars_ticker_date ON intraday_bars(ticker, timestamp);
