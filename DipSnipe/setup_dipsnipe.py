#!/usr/bin/env python3
"""Quick setup script for DipSnipe - Works with any folder structure"""
import os
import sys
import subprocess
from pathlib import Path
from datetime import date, timedelta
import sqlite3

def find_file(filename):
    """Find a file in current directory or subdirectories"""
    # Check current directory
    if os.path.exists(filename):
        return filename
    
    # Check common subdirectories
    for subdir in ['src', 'scripts', 'python', '.']:
        path = os.path.join(subdir, filename)
        if os.path.exists(path):
            return path
    
    return None

def run_command(cmd, description):
    """Run a command and handle errors"""
    print(f"⏳ {description}...")
    result = subprocess.run(cmd, shell=True)
    if result.returncode != 0:
        print(f"❌ Failed: {description}")
        return False
    print(f"✓ {description} complete")
    return True

def check_database():
    """Check if database exists and has data"""
    db_path = "diphunter.db"
    if not os.path.exists(db_path):
        return False, 0, 0
    
    try:
        conn = sqlite3.connect(db_path)
        cur = conn.cursor()
        
        cur.execute("SELECT COUNT(*) FROM tickers")
        ticker_count = cur.fetchone()[0]
        
        cur.execute("SELECT COUNT(*) FROM intraday_metrics")
        metrics_count = cur.fetchone()[0]
        
        conn.close()
        return True, ticker_count, metrics_count
    except Exception as e:
        print(f"⚠️  Database exists but error reading it: {e}")
        return True, 0, 0

def main():
    print("=== DipSnipe Quick Setup ===")
    print()
    print(f"Current directory: {os.getcwd()}")
    print()
    
    # Find the required Python files
    print("🔍 Looking for Python files...")
    populate_script = find_file("populate_fundamentals.py")
    compute_script = find_file("compute_metrics.py")
    api_script = find_file("api_server.py")
    
    if not populate_script:
        print("❌ Cannot find populate_fundamentals.py")
        print("   Please run this script from your DipSnipe project folder")
        sys.exit(1)
    
    if not compute_script:
        print("❌ Cannot find compute_metrics.py")
        print("   Please run this script from your DipSnipe project folder")
        sys.exit(1)
    
    print(f"✓ Found populate_fundamentals.py at: {populate_script}")
    print(f"✓ Found compute_metrics.py at: {compute_script}")
    if api_script:
        print(f"✓ Found api_server.py at: {api_script}")
    
    # Check database
    print()
    db_exists, ticker_count, metrics_count = check_database()
    
    if not db_exists:
        print("❌ Database not found. Creating and populating...")
        if not run_command(f"python3 {populate_script}", 
                          "Populating tickers (5-10 min)"):
            print("⚠️  Note: This may take several minutes. Please wait...")
            sys.exit(1)
    else:
        print(f"✓ Database exists")
        print(f"  - Tickers: {ticker_count}")
        print(f"  - Metrics: {metrics_count}")
    
    # If no tickers, we need to populate
    if ticker_count == 0:
        print("❌ No tickers in database. Populating...")
        print("⚠️  This will take 5-10 minutes. Yahoo Finance rate limits apply.")
        response = input("Continue? (y/n): ")
        if response.lower() != 'y':
            print("Skipping ticker population. You can run it later with:")
            print(f"   python3 {populate_script}")
        else:
            if not run_command(f"python3 {populate_script}",
                              "Populating tickers (5-10 min)"):
                sys.exit(1)
    
    # Compute metrics for yesterday
    yesterday = (date.today() - timedelta(days=1)).isoformat()
    
    print()
    print(f"⏳ Computing metrics for {yesterday}")
    print("   Using sample: AAPL, MSFT, GOOGL, TSLA, NVDA")
    print()
    
    cmd = f"python3 {compute_script} {yesterday} AAPL MSFT GOOGL TSLA NVDA"
    if not run_command(cmd, f"Computing metrics for {yesterday}"):
        print("⚠️  Warning: Metrics computation failed")
        print("   This might be due to Yahoo Finance rate limits")
        print("   The app will use synthetic data for demonstration")
    
    print()
    print("=" * 60)
    print("✓ Setup complete!")
    print("=" * 60)
    print()
    print("=== Next Steps ===")
    print()
    print("1. Start API server (Terminal 1):")
    if api_script:
        script_dir = os.path.dirname(api_script) or "."
        print(f"   cd {script_dir} && python3 {os.path.basename(api_script)}")
    else:
        print("   python3 api_server.py")
    print()
    print("2. Start Shiny app (Terminal 2):")
    if os.path.exists("dashboard"):
        print('   cd dashboard && Rscript -e "shiny::runApp(\'app.R\')"')
    elif os.path.exists("app.R"):
        print('   Rscript -e "shiny::runApp(\'app.R\')"')
    else:
        print('   cd <dashboard_folder> && Rscript -e "shiny::runApp(\'app.R\')"')
    print()
    print("3. Open browser to: http://127.0.0.1:7667")
    print()
    print("=" * 60)
    print("=== To compute more data ===")
    print()
    print(f"Full S&P 500 for {yesterday} (slow, ~30 min):")
    print(f"   python3 {compute_script} {yesterday}")
    print()
    print("Quick test with 10 tickers:")
    print(f"   python3 {compute_script} {yesterday} AAPL MSFT GOOGL TSLA NVDA META AMZN")
