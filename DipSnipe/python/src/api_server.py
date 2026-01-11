"""Flask API server for DipHunter - Improved Version"""
from flask import Flask, jsonify, request
from flask_cors import CORS
import logging
import sys
from pathlib import Path
from datetime import date, datetime

sys.path.insert(0, str(Path(__file__).parent))

from config_loader import load_config
from database import Database

app = Flask(__name__)
CORS(app)

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

db = None

def get_db():
    global db
    if db is None:
        try:
            config = load_config()
            db = Database(config['database'])
            db.connect()
            logger.info("Database connected successfully")
        except Exception as e:
            logger.error(f"Failed to connect to database: {e}")
            raise
    return db

@app.route('/api/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    try:
        get_db()
        return jsonify({
            'status': 'ok',
            'message': 'API server is running',
            'database': 'connected'
        })
    except Exception as e:
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500

@app.route('/api/sectors', methods=['GET'])
def get_sectors():
    """Get list of all sectors"""
    try:
        sectors = get_db().get_sectors()
        logger.info(f"Returning {len(sectors)} sectors")
        return jsonify({'sectors': sectors})
    except Exception as e:
        logger.error(f"Error fetching sectors: {e}")
        return jsonify({'error': str(e)}), 500

@app.route('/api/industries', methods=['GET'])
def get_industries():
    """Get list of industries, optionally filtered by sector"""
    try:
        sector = request.args.get('sector', '')
        industries = get_db().get_industries(sector if sector else None)
        logger.info(f"Returning {len(industries)} industries")
        return jsonify({'industries': industries})
    except Exception as e:
        logger.error(f"Error fetching industries: {e}")
        return jsonify({'error': str(e)}), 500

@app.route('/api/metrics', methods=['GET'])
def get_metrics():
    """Get drawdown metrics with filtering"""
    try:
        # Parse parameters
        date_str = request.args.get('date')
        if not date_str:
            return jsonify({'error': 'Date parameter required'}), 400
            
        target_date = date.fromisoformat(date_str)
        
        # Filters
        min_cap = int(request.args.get('min_market_cap', 0))
        max_cap = int(request.args.get('max_market_cap', 1e15))
        min_vol = int(request.args.get('min_volume', 0))
        sector = request.args.get('sector', '')
        industry = request.args.get('industry', '')
        
        logger.info(f"Fetching metrics for {target_date} with filters: "
                   f"cap={min_cap}-{max_cap}, vol={min_vol}, "
                   f"sector={sector}, industry={industry}")
        
        # Query database
        raw_metrics = get_db().get_metrics(
            target_date=target_date,
            min_market_cap=min_cap,
            max_market_cap=max_cap,
            min_volume=min_vol,
            sector=sector if sector else None,
            industry=industry if industry else None
        )
        
        results = []
        for m in raw_metrics:
            results.append({
                'ticker': m['ticker'],
                'sector': m['sector'],
                'industry': m['industry'],
                'market_cap': m['market_cap'],
                'max_drawdown_pct': float(m['max_drawdown_pct']),
                'drawdown_time': m['drawdown_time'],
                'recovery_pct': float(m['recovery_pct']),
                'data_source': m['data_source']
            })
        
        logger.info(f"Returning {len(results)} metrics")
        return jsonify({'metrics': results})
        
    except ValueError as e:
        logger.error(f"Invalid parameter: {e}")
        return jsonify({'error': f'Invalid parameter: {str(e)}'}), 400
    except Exception as e:
        logger.error(f"API Error in get_metrics: {e}", exc_info=True)
        return jsonify({'error': str(e)}), 500

@app.route('/api/intraday_bars', methods=['GET'])
def get_bars():
    """Get intraday bars for a specific ticker and date"""
    try:
        ticker = request.args.get('ticker')
        date_str = request.args.get('date')
        
        if not ticker or not date_str:
            return jsonify({'error': 'Ticker and date required'}), 400
        
        target_date = date.fromisoformat(date_str)
        bars = get_db().get_intraday_bars(ticker, target_date)
        
        results = []
        for bar in bars:
            results.append({
                'timestamp': bar['timestamp'].isoformat(),
                'open': float(bar['open']),
                'high': float(bar['high']),
                'low': float(bar['low']),
                'close': float(bar['close'])
            })
        
        logger.info(f"Returning {len(results)} bars for {ticker}")
        return jsonify({'bars': results})
        
    except Exception as e:
        logger.error(f"Error fetching bars: {e}")
        return jsonify({'error': str(e)}), 500

@app.route('/api/stats', methods=['GET'])
def get_stats():
    """Get database statistics"""
    try:
        stats = get_db().get_stats()
        return jsonify(stats)
    except Exception as e:
        logger.error(f"Error fetching stats: {e}")
        return jsonify({'error': str(e)}), 500

@app.errorhandler(404)
def not_found(error):
    return jsonify({'error': 'Endpoint not found'}), 404

@app.errorhandler(500)
def internal_error(error):
    return jsonify({'error': 'Internal server error'}), 500

if __name__ == '__main__':
    logger.info("Starting DipHunter API Server...")
    logger.info("Endpoints available:")
    logger.info("  GET /api/health")
    logger.info("  GET /api/sectors")
    logger.info("  GET /api/industries")
    logger.info("  GET /api/metrics")
    logger.info("  GET /api/intraday_bars")
    logger.info("  GET /api/stats")
    
    app.run(host='0.0.0.0', port=8080, debug=True)
