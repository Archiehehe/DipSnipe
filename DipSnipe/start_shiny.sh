#!/bin/bash
# Start DipHunter Shiny App

cd "$(dirname "$0")"
cd R
Rscript -e "shiny::runApp('app.R', port=3838, host='0.0.0.0')"
