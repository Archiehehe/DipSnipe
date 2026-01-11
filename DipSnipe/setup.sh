#!/bin/bash
# DipHunter Setup Script

set -e

echo "DipHunter Setup"
echo "==============="

# Check PostgreSQL
if ! command -v psql &> /dev/null; then
    echo "Error: PostgreSQL not found. Please install PostgreSQL first."
    exit 1
fi

# Check Python
if ! command -v python3 &> /dev/null; then
    echo "Error: Python 3 not found. Please install Python 3.8+ first."
    exit 1
fi

# Check R
if ! command -v Rscript &> /dev/null; then
    echo "Error: R not found. Please install R 4.0+ first."
    exit 1
fi

echo ""
echo "1. Setting up Python environment..."
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

echo ""
echo "2. Creating logs directory..."
mkdir -p logs

echo ""
echo "3. Database setup..."
echo "Please ensure PostgreSQL is running and create a database:"
echo "  createdb diphunter"
echo "  psql diphunter < database/schema.sql"
echo ""
read -p "Have you created the database? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Please create the database and run this script again."
    exit 1
fi

echo ""
echo "4. Configuration..."
if [ ! -f config/config.yaml ]; then
    cp config/config.example.yaml config/config.yaml
    echo "Created config/config.yaml - please edit with your credentials"
else
    echo "config/config.yaml already exists"
fi

echo ""
echo "5. Installing R packages..."
Rscript -e "if (!require('shiny')) install.packages('shiny', repos='https://cran.rstudio.com/')"
Rscript -e "if (!require('shinydashboard')) install.packages('shinydashboard', repos='https://cran.rstudio.com/')"
Rscript -e "if (!require('DT')) install.packages('DT', repos='https://cran.rstudio.com/')"
Rscript -e "if (!require('plotly')) install.packages('plotly', repos='https://cran.rstudio.com/')"
Rscript -e "if (!require('httr')) install.packages('httr', repos='https://cran.rstudio.com/')"
Rscript -e "if (!require('jsonlite')) install.packages('jsonlite', repos='https://cran.rstudio.com/')"
Rscript -e "if (!require('dplyr')) install.packages('dplyr', repos='https://cran.rstudio.com/')"
Rscript -e "if (!require('lubridate')) install.packages('lubridate', repos='https://cran.rstudio.com/')"

echo ""
echo "Setup complete!"
echo ""
echo "Next steps:"
echo "1. Edit config/config.yaml with your database credentials and API keys"
echo "2. Run: python python/src/populate_fundamentals.py"
echo "3. Run: python python/src/compute_metrics.py YYYY-MM-DD"
echo "4. Start API server: python python/src/api_server.py"
echo "5. Start Shiny app: cd R && Rscript -e \"shiny::runApp('app.R', port=3838)\""
