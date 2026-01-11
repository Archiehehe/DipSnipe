# DipSnipe V2 - Complete Upgrade
# Date Range, Metadata DB, Auto-load, Caching, Dynamic Filters

library(shiny)
library(shinydashboard)
library(DT)
library(plotly)
library(dplyr)
library(tidyquant)
library(lubridate)
library(stringr)

# ============================================================================
# STATIC METADATA DATABASE - Instant loading, no API calls for metadata
# Company names, sectors (ADRs fixed), industries, market caps
# ============================================================================
STOCKS_DB <- tibble::tribble(
  ~symbol, ~company, ~sector, ~industry, ~market_cap_b,
  # ===== TECHNOLOGY =====
  "AAPL", "Apple Inc.", "Technology", "Consumer Electronics", 3400,
  "MSFT", "Microsoft Corp.", "Technology", "Software", 3100,
  "NVDA", "NVIDIA Corp.", "Technology", "Semiconductors", 2800,
  "GOOGL", "Alphabet Inc.", "Technology", "Internet Services", 2100,
  "GOOG", "Alphabet Inc. (C)", "Technology", "Internet Services", 2100,
  "META", "Meta Platforms", "Technology", "Internet Services", 1400,
  "AVGO", "Broadcom Inc.", "Technology", "Semiconductors", 800,
  "ORCL", "Oracle Corp.", "Technology", "Software", 450,
  "CRM", "Salesforce Inc.", "Technology", "Software", 300,
  "ADBE", "Adobe Inc.", "Technology", "Software", 240,
  "AMD", "Advanced Micro Devices", "Technology", "Semiconductors", 220,
  "CSCO", "Cisco Systems", "Technology", "Networking", 210,
  "ACN", "Accenture plc", "Technology", "IT Services", 200,
  "IBM", "IBM Corp.", "Technology", "IT Services", 190,
  "INTC", "Intel Corp.", "Technology", "Semiconductors", 180,
  "QCOM", "Qualcomm Inc.", "Technology", "Semiconductors", 170,
  "TXN", "Texas Instruments", "Technology", "Semiconductors", 165,
  "NOW", "ServiceNow Inc.", "Technology", "Software", 160,
  "INTU", "Intuit Inc.", "Technology", "Software", 155,
  "AMAT", "Applied Materials", "Technology", "Semiconductors", 140,
  "ADI", "Analog Devices", "Technology", "Semiconductors", 100,
  "LRCX", "Lam Research", "Technology", "Semiconductors", 95,
  "MU", "Micron Technology", "Technology", "Semiconductors", 90,
  "KLAC", "KLA Corp.", "Technology", "Semiconductors", 85,
  "SNPS", "Synopsys Inc.", "Technology", "Software", 80,
  "CDNS", "Cadence Design", "Technology", "Software", 75,
  "MCHP", "Microchip Technology", "Technology", "Semiconductors", 40,
  "NXPI", "NXP Semiconductors", "Technology", "Semiconductors", 55,
  "FTNT", "Fortinet Inc.", "Technology", "Cybersecurity", 50,
  "PANW", "Palo Alto Networks", "Technology", "Cybersecurity", 110,
  "CRWD", "CrowdStrike Holdings", "Technology", "Cybersecurity", 75,
  "ANSS", "ANSYS Inc.", "Technology", "Software", 28,
  "KEYS", "Keysight Technologies", "Technology", "Electronics", 25,
  "IT", "Gartner Inc.", "Technology", "IT Services", 35,
  "MPWR", "Monolithic Power", "Technology", "Semiconductors", 30,
  "ZBRA", "Zebra Technologies", "Technology", "Electronics", 15,
  "FFIV", "F5 Inc.", "Technology", "Networking", 10,
  "JNPR", "Juniper Networks", "Technology", "Networking", 12,
  "AKAM", "Akamai Technologies", "Technology", "Cloud/CDN", 14,
  "EPAM", "EPAM Systems", "Technology", "IT Services", 12,
  "PTC", "PTC Inc.", "Technology", "Software", 20,
  "TYL", "Tyler Technologies", "Technology", "Software", 22,
  "SWKS", "Skyworks Solutions", "Technology", "Semiconductors", 15,
  "QRVO", "Qorvo Inc.", "Technology", "Semiconductors", 8,
  "TER", "Teradyne Inc.", "Technology", "Semiconductors", 18,
  "SMCI", "Super Micro Computer", "Technology", "Hardware", 25,
  "HPE", "HP Enterprise", "Technology", "Hardware", 25,
  "HPQ", "HP Inc.", "Technology", "Hardware", 30,
  "NTAP", "NetApp Inc.", "Technology", "Storage", 22,
  "WDC", "Western Digital", "Technology", "Storage", 18,
  "STX", "Seagate Technology", "Technology", "Storage", 17,
  "GEN", "Gen Digital", "Technology", "Software", 15,
  "FSLR", "First Solar", "Technology", "Solar", 20,
  # International Tech ADRs (with PROPER sectors)
  "TSM", "Taiwan Semiconductor (ADR)", "Technology", "Semiconductors", 850,
  "ASML", "ASML Holding (ADR)", "Technology", "Semiconductors", 350,
  "SAP", "SAP SE (ADR)", "Technology", "Software", 250,
  "SONY", "Sony Group (ADR)", "Technology", "Consumer Electronics", 110,
  "SHOP", "Shopify Inc.", "Technology", "E-Commerce Software", 120,
  
  # ===== FINANCE =====
  "JPM", "JPMorgan Chase", "Finance", "Banks", 600,
  "V", "Visa Inc.", "Finance", "Payments", 550,
  "MA", "Mastercard Inc.", "Finance", "Payments", 420,
  "BAC", "Bank of America", "Finance", "Banks", 320,
  "WFC", "Wells Fargo", "Finance", "Banks", 210,
  "GS", "Goldman Sachs", "Finance", "Investment Banks", 170,
  "MS", "Morgan Stanley", "Finance", "Investment Banks", 160,
  "SPGI", "S&P Global", "Finance", "Financial Data", 145,
  "BLK", "BlackRock Inc.", "Finance", "Asset Management", 140,
  "SCHW", "Charles Schwab", "Finance", "Brokerage", 130,
  "AXP", "American Express", "Finance", "Payments", 180,
  "C", "Citigroup Inc.", "Finance", "Banks", 120,
  "USB", "U.S. Bancorp", "Finance", "Banks", 70,
  "PNC", "PNC Financial", "Finance", "Banks", 75,
  "TFC", "Truist Financial", "Finance", "Banks", 55,
  "BK", "Bank of New York", "Finance", "Custody Banks", 50,
  "COF", "Capital One", "Finance", "Consumer Finance", 55,
  "CME", "CME Group", "Finance", "Exchanges", 80,
  "ICE", "Intercontinental Exchange", "Finance", "Exchanges", 85,
  "MCO", "Moody's Corp.", "Finance", "Ratings", 75,
  "CB", "Chubb Ltd.", "Finance", "Insurance", 110,
  "MMC", "Marsh McLennan", "Finance", "Insurance", 105,
  "AON", "Aon plc", "Finance", "Insurance", 75,
  "MET", "MetLife Inc.", "Finance", "Insurance", 55,
  "PRU", "Prudential Financial", "Finance", "Insurance", 45,
  "AIG", "American International", "Finance", "Insurance", 50,
  "AFL", "Aflac Inc.", "Finance", "Insurance", 55,
  "ALL", "Allstate Corp.", "Finance", "Insurance", 45,
  "TRV", "Travelers Cos.", "Finance", "Insurance", 55,
  "PGR", "Progressive Corp.", "Finance", "Insurance", 130,
  "AJG", "Arthur J. Gallagher", "Finance", "Insurance", 60,
  "MSCI", "MSCI Inc.", "Finance", "Financial Data", 45,
  "NDAQ", "Nasdaq Inc.", "Finance", "Exchanges", 40,
  "FITB", "Fifth Third Bank", "Finance", "Banks", 28,
  "MTB", "M&T Bank", "Finance", "Banks", 30,
  "HBAN", "Huntington Bancshares", "Finance", "Banks", 22,
  "CFG", "Citizens Financial", "Finance", "Banks", 18,
  "RF", "Regions Financial", "Finance", "Banks", 20,
  "KEY", "KeyCorp", "Finance", "Banks", 15,
  "NTRS", "Northern Trust", "Finance", "Custody Banks", 20,
  "STT", "State Street", "Finance", "Custody Banks", 25,
  "DFS", "Discover Financial", "Finance", "Consumer Finance", 40,
  "SYF", "Synchrony Financial", "Finance", "Consumer Finance", 20,
  "CINF", "Cincinnati Financial", "Finance", "Insurance", 20,
  "L", "Loews Corp.", "Finance", "Diversified", 18,
  "BRO", "Brown & Brown", "Finance", "Insurance", 28,
  "WRB", "W.R. Berkley", "Finance", "Insurance", 22,
  "ACGL", "Arch Capital", "Finance", "Insurance", 35,
  "GL", "Globe Life", "Finance", "Insurance", 10,
  "AIZ", "Assurant Inc.", "Finance", "Insurance", 10,
  "RJF", "Raymond James", "Finance", "Brokerage", 28,
  "HIG", "Hartford Financial", "Finance", "Insurance", 30,
  "TROW", "T. Rowe Price", "Finance", "Asset Management", 25,
  "BEN", "Franklin Resources", "Finance", "Asset Management", 12,
  "IVZ", "Invesco Ltd.", "Finance", "Asset Management", 8,
  "FDS", "FactSet Research", "Finance", "Financial Data", 18,
  "FCNCA", "First Citizens Bank", "Finance", "Banks", 25,
  "FI", "Fiserv Inc.", "Finance", "Fintech", 90,
  "FLT", "Fleetcor Technologies", "Finance", "Payments", 20,
  "CPAY", "Corpay Inc.", "Finance", "Payments", 22,
  "GPN", "Global Payments", "Finance", "Payments", 25,
  "JKHY", "Jack Henry", "Finance", "Fintech", 12,
  "PYPL", "PayPal Holdings", "Finance", "Payments", 70,
  "FIS", "Fidelity National", "Finance", "Fintech", 45,
  "KKR", "KKR & Co.", "Finance", "Private Equity", 110,
  "BX", "Blackstone Inc.", "Finance", "Private Equity", 180,
  "BRK.B", "Berkshire Hathaway", "Finance", "Diversified", 900,
  # International Finance ADRs
  "MELI", "MercadoLibre (ADR)", "Finance", "Fintech", 85,
  "NU", "Nu Holdings (ADR)", "Finance", "Fintech", 55,
  "HSBC", "HSBC Holdings (ADR)", "Finance", "Banks", 160,
  "UBS", "UBS Group (ADR)", "Finance", "Banks", 100,
  "DB", "Deutsche Bank (ADR)", "Finance", "Banks", 35,
  "ING", "ING Group (ADR)", "Finance", "Banks", 55,
  "BCS", "Barclays (ADR)", "Finance", "Banks", 45,
  "LYG", "Lloyds Banking (ADR)", "Finance", "Banks", 45,
  "TD", "Toronto-Dominion (ADR)", "Finance", "Banks", 110,
  "RY", "Royal Bank Canada (ADR)", "Finance", "Banks", 150,
  "BNS", "Bank of Nova Scotia (ADR)", "Finance", "Banks", 60,
  "BMO", "Bank of Montreal (ADR)", "Finance", "Banks", 65,
  "CM", "CIBC (ADR)", "Finance", "Banks", 45,
  "MFC", "Manulife Financial (ADR)", "Finance", "Insurance", 45,
  "SLF", "Sun Life Financial (ADR)", "Finance", "Insurance", 35,
  "ITUB", "Itau Unibanco (ADR)", "Finance", "Banks", 55,
  "BBD", "Banco Bradesco (ADR)", "Finance", "Banks", 25,
  
  # ===== HEALTHCARE =====
  "UNH", "UnitedHealth Group", "Healthcare", "Insurance", 480,
  "JNJ", "Johnson & Johnson", "Healthcare", "Pharma", 380,
  "LLY", "Eli Lilly", "Healthcare", "Pharma", 750,
  "MRK", "Merck & Co.", "Healthcare", "Pharma", 260,
  "ABBV", "AbbVie Inc.", "Healthcare", "Pharma", 310,
  "PFE", "Pfizer Inc.", "Healthcare", "Pharma", 150,
  "TMO", "Thermo Fisher", "Healthcare", "Life Sciences", 200,
  "ABT", "Abbott Laboratories", "Healthcare", "Medical Devices", 190,
  "DHR", "Danaher Corp.", "Healthcare", "Life Sciences", 170,
  "AMGN", "Amgen Inc.", "Healthcare", "Biotech", 150,
  "MDT", "Medtronic plc", "Healthcare", "Medical Devices", 110,
  "ELV", "Elevance Health", "Healthcare", "Insurance", 100,
  "CI", "Cigna Group", "Healthcare", "Insurance", 95,
  "BMY", "Bristol-Myers Squibb", "Healthcare", "Pharma", 100,
  "ISRG", "Intuitive Surgical", "Healthcare", "Medical Devices", 160,
  "VRTX", "Vertex Pharmaceuticals", "Healthcare", "Biotech", 120,
  "GILD", "Gilead Sciences", "Healthcare", "Biotech", 110,
  "SYK", "Stryker Corp.", "Healthcare", "Medical Devices", 130,
  "REGN", "Regeneron Pharma", "Healthcare", "Biotech", 90,
  "BSX", "Boston Scientific", "Healthcare", "Medical Devices", 115,
  "BDX", "Becton Dickinson", "Healthcare", "Medical Devices", 65,
  "ZTS", "Zoetis Inc.", "Healthcare", "Animal Health", 75,
  "HCA", "HCA Healthcare", "Healthcare", "Hospitals", 85,
  "MCK", "McKesson Corp.", "Healthcare", "Distribution", 75,
  "CVS", "CVS Health", "Healthcare", "Pharmacy", 80,
  "COR", "Cencora Inc.", "Healthcare", "Distribution", 45,
  "HUM", "Humana Inc.", "Healthcare", "Insurance", 35,
  "IDXX", "IDEXX Laboratories", "Healthcare", "Diagnostics", 40,
  "DXCM", "DexCom Inc.", "Healthcare", "Medical Devices", 30,
  "IQV", "IQVIA Holdings", "Healthcare", "Life Sciences", 45,
  "A", "Agilent Technologies", "Healthcare", "Life Sciences", 40,
  "MTD", "Mettler-Toledo", "Healthcare", "Life Sciences", 28,
  "EW", "Edwards Lifesciences", "Healthcare", "Medical Devices", 45,
  "RMD", "ResMed Inc.", "Healthcare", "Medical Devices", 30,
  "PODD", "Insulet Corp.", "Healthcare", "Medical Devices", 15,
  "ALGN", "Align Technology", "Healthcare", "Medical Devices", 15,
  "WST", "West Pharmaceutical", "Healthcare", "Life Sciences", 22,
  "HOLX", "Hologic Inc.", "Healthcare", "Medical Devices", 18,
  "COO", "Cooper Companies", "Healthcare", "Medical Devices", 18,
  "TFX", "Teleflex Inc.", "Healthcare", "Medical Devices", 8,
  "TECH", "Bio-Techne Corp.", "Healthcare", "Life Sciences", 10,
  "RVTY", "Revvity Inc.", "Healthcare", "Life Sciences", 12,
  "CRL", "Charles River Labs", "Healthcare", "Life Sciences", 10,
  "DGX", "Quest Diagnostics", "Healthcare", "Diagnostics", 16,
  "ILMN", "Illumina Inc.", "Healthcare", "Life Sciences", 18,
  "MOH", "Molina Healthcare", "Healthcare", "Insurance", 20,
  "CNC", "Centene Corp.", "Healthcare", "Insurance", 35,
  "DVA", "DaVita Inc.", "Healthcare", "Dialysis", 10,
  "LH", "Labcorp Holdings", "Healthcare", "Diagnostics", 18,
  "BAX", "Baxter International", "Healthcare", "Medical Devices", 18,
  "BIIB", "Biogen Inc.", "Healthcare", "Biotech", 25,
  "MRNA", "Moderna Inc.", "Healthcare", "Biotech", 15,
  "INCY", "Incyte Corp.", "Healthcare", "Biotech", 12,
  "VTRS", "Viatris Inc.", "Healthcare", "Pharma", 12,
  "HSIC", "Henry Schein", "Healthcare", "Distribution", 9,
  "CAH", "Cardinal Health", "Healthcare", "Distribution", 28,
  # International Healthcare ADRs
  "NVO", "Novo Nordisk (ADR)", "Healthcare", "Pharma", 450,
  "AZN", "AstraZeneca (ADR)", "Healthcare", "Pharma", 220,
  "GSK", "GSK plc (ADR)", "Healthcare", "Pharma", 80,
  "SNY", "Sanofi (ADR)", "Healthcare", "Pharma", 130,
  "NVS", "Novartis (ADR)", "Healthcare", "Pharma", 200,
  "TAK", "Takeda Pharma (ADR)", "Healthcare", "Pharma", 45,
  
  # ===== CONSUMER DISCRETIONARY =====
  "AMZN", "Amazon.com", "Consumer", "E-Commerce", 2000,
  "TSLA", "Tesla Inc.", "Consumer", "Automotive", 800,
  "HD", "Home Depot", "Consumer", "Retail", 380,
  "MCD", "McDonald's Corp.", "Consumer", "Restaurants", 210,
  "NKE", "Nike Inc.", "Consumer", "Apparel", 115,
  "LOW", "Lowe's Cos.", "Consumer", "Retail", 140,
  "BKNG", "Booking Holdings", "Consumer", "Travel", 155,
  "SBUX", "Starbucks Corp.", "Consumer", "Restaurants", 105,
  "TJX", "TJX Companies", "Consumer", "Retail", 125,
  "CMG", "Chipotle Mexican Grill", "Consumer", "Restaurants", 75,
  "ORLY", "O'Reilly Automotive", "Consumer", "Auto Parts", 65,
  "MAR", "Marriott International", "Consumer", "Hotels", 75,
  "AZO", "AutoZone Inc.", "Consumer", "Auto Parts", 55,
  "ROST", "Ross Stores", "Consumer", "Retail", 50,
  "YUM", "Yum! Brands", "Consumer", "Restaurants", 40,
  "DHI", "D.R. Horton", "Consumer", "Homebuilders", 50,
  "RCL", "Royal Caribbean", "Consumer", "Cruises", 55,
  "GM", "General Motors", "Consumer", "Automotive", 50,
  "F", "Ford Motor", "Consumer", "Automotive", 42,
  "LEN", "Lennar Corp.", "Consumer", "Homebuilders", 40,
  "PHM", "PulteGroup Inc.", "Consumer", "Homebuilders", 25,
  "DRI", "Darden Restaurants", "Consumer", "Restaurants", 20,
  "HLT", "Hilton Worldwide", "Consumer", "Hotels", 55,
  "CCL", "Carnival Corp.", "Consumer", "Cruises", 25,
  "NCLH", "Norwegian Cruise", "Consumer", "Cruises", 12,
  "WYNN", "Wynn Resorts", "Consumer", "Casinos", 10,
  "LVS", "Las Vegas Sands", "Consumer", "Casinos", 35,
  "DECK", "Deckers Outdoor", "Consumer", "Apparel", 25,
  "LULU", "Lululemon Athletica", "Consumer", "Apparel", 40,
  "GRMN", "Garmin Ltd.", "Consumer", "Electronics", 30,
  "BBY", "Best Buy Co.", "Consumer", "Retail", 18,
  "EBAY", "eBay Inc.", "Consumer", "E-Commerce", 28,
  "ETSY", "Etsy Inc.", "Consumer", "E-Commerce", 8,
  "POOL", "Pool Corp.", "Consumer", "Specialty Retail", 14,
  "DPZ", "Domino's Pizza", "Consumer", "Restaurants", 15,
  "APTV", "Aptiv plc", "Consumer", "Auto Parts", 15,
  "BWA", "BorgWarner Inc.", "Consumer", "Auto Parts", 8,
  "MGM", "MGM Resorts", "Consumer", "Casinos", 12,
  "CZR", "Caesars Entertainment", "Consumer", "Casinos", 9,
  "GPC", "Genuine Parts", "Consumer", "Auto Parts", 20,
  "KMX", "CarMax Inc.", "Consumer", "Auto Retail", 12,
  "ULTA", "Ulta Beauty", "Consumer", "Retail", 20,
  "TSCO", "Tractor Supply", "Consumer", "Retail", 28,
  "TPR", "Tapestry Inc.", "Consumer", "Apparel", 12,
  "VFC", "VF Corp.", "Consumer", "Apparel", 6,
  "HAS", "Hasbro Inc.", "Consumer", "Toys", 8,
  "NVR", "NVR Inc.", "Consumer", "Homebuilders", 28,
  "LKQ", "LKQ Corp.", "Consumer", "Auto Parts", 10,
  "RL", "Ralph Lauren", "Consumer", "Apparel", 10,
  "ABNB", "Airbnb Inc.", "Consumer", "Travel", 85,
  "EXPE", "Expedia Group", "Consumer", "Travel", 20,
  "LYV", "Live Nation", "Consumer", "Entertainment", 25,
  "DIS", "Walt Disney", "Consumer", "Entertainment", 180,
  # International Consumer ADRs
  "TM", "Toyota Motor (ADR)", "Consumer", "Automotive", 250,
  "HMC", "Honda Motor (ADR)", "Consumer", "Automotive", 50,
  "RACE", "Ferrari (ADR)", "Consumer", "Automotive", 80,
  
  # ===== CONSUMER STAPLES =====
  "PG", "Procter & Gamble", "Consumer Staples", "Household Products", 380,
  "COST", "Costco Wholesale", "Consumer Staples", "Retail", 380,
  "WMT", "Walmart Inc.", "Consumer Staples", "Retail", 600,
  "KO", "Coca-Cola Co.", "Consumer Staples", "Beverages", 265,
  "PEP", "PepsiCo Inc.", "Consumer Staples", "Beverages", 220,
  "PM", "Philip Morris", "Consumer Staples", "Tobacco", 180,
  "MDLZ", "Mondelez International", "Consumer Staples", "Food", 85,
  "MO", "Altria Group", "Consumer Staples", "Tobacco", 90,
  "CL", "Colgate-Palmolive", "Consumer Staples", "Household Products", 75,
  "EL", "Estee Lauder", "Consumer Staples", "Personal Care", 25,
  "KMB", "Kimberly-Clark", "Consumer Staples", "Household Products", 45,
  "GIS", "General Mills", "Consumer Staples", "Food", 40,
  "KHC", "Kraft Heinz", "Consumer Staples", "Food", 40,
  "SYY", "Sysco Corp.", "Consumer Staples", "Food Distribution", 40,
  "HSY", "Hershey Co.", "Consumer Staples", "Food", 35,
  "KDP", "Keurig Dr Pepper", "Consumer Staples", "Beverages", 45,
  "KR", "Kroger Co.", "Consumer Staples", "Retail", 40,
  "STZ", "Constellation Brands", "Consumer Staples", "Beverages", 40,
  "ADM", "Archer-Daniels-Midland", "Consumer Staples", "Food", 25,
  "CAG", "Conagra Brands", "Consumer Staples", "Food", 14,
  "CLX", "Clorox Co.", "Consumer Staples", "Household Products", 18,
  "MKC", "McCormick & Co.", "Consumer Staples", "Food", 20,
  "CHD", "Church & Dwight", "Consumer Staples", "Household Products", 25,
  "K", "Kellanova", "Consumer Staples", "Food", 25,
  "HRL", "Hormel Foods", "Consumer Staples", "Food", 18,
  "TSN", "Tyson Foods", "Consumer Staples", "Food", 20,
  "SJM", "J.M. Smucker", "Consumer Staples", "Food", 14,
  "CPB", "Campbell Soup", "Consumer Staples", "Food", 12,
  "TAP", "Molson Coors", "Consumer Staples", "Beverages", 12,
  "BG", "Bunge Ltd.", "Consumer Staples", "Food", 14,
  "LW", "Lamb Weston", "Consumer Staples", "Food", 10,
  "BF.B", "Brown-Forman", "Consumer Staples", "Beverages", 20,
  "MNST", "Monster Beverage", "Consumer Staples", "Beverages", 50,
  "KVUE", "Kenvue Inc.", "Consumer Staples", "Personal Care", 40,
  "WBA", "Walgreens Boots", "Consumer Staples", "Pharmacy", 8,
  "TGT", "Target Corp.", "Consumer Staples", "Retail", 55,
  "DG", "Dollar General", "Consumer Staples", "Retail", 18,
  "DLTR", "Dollar Tree", "Consumer Staples", "Retail", 15,
  # International Staples ADRs
  "UL", "Unilever (ADR)", "Consumer Staples", "Household Products", 140,
  "DEO", "Diageo (ADR)", "Consumer Staples", "Beverages", 75,
  "BTI", "British American Tobacco (ADR)", "Consumer Staples", "Tobacco", 80,
  "ABEV", "Ambev (ADR)", "Consumer Staples", "Beverages", 35,
  
  # ===== INDUSTRIALS =====
  "CAT", "Caterpillar Inc.", "Industrials", "Machinery", 180,
  "GE", "GE Aerospace", "Industrials", "Aerospace", 200,
  "HON", "Honeywell International", "Industrials", "Conglomerate", 140,
  "UNP", "Union Pacific", "Industrials", "Railroads", 145,
  "UPS", "United Parcel Service", "Industrials", "Logistics", 100,
  "DE", "Deere & Co.", "Industrials", "Machinery", 110,
  "RTX", "RTX Corp.", "Industrials", "Aerospace", 150,
  "BA", "Boeing Co.", "Industrials", "Aerospace", 130,
  "LMT", "Lockheed Martin", "Industrials", "Aerospace", 130,
  "ETN", "Eaton Corp.", "Industrials", "Electrical Equipment", 125,
  "ITW", "Illinois Tool Works", "Industrials", "Machinery", 75,
  "EMR", "Emerson Electric", "Industrials", "Electrical Equipment", 65,
  "PH", "Parker-Hannifin", "Industrials", "Machinery", 80,
  "NOC", "Northrop Grumman", "Industrials", "Aerospace", 70,
  "GD", "General Dynamics", "Industrials", "Aerospace", 80,
  "WM", "Waste Management", "Industrials", "Waste Management", 85,
  "CSX", "CSX Corp.", "Industrials", "Railroads", 65,
  "NSC", "Norfolk Southern", "Industrials", "Railroads", 55,
  "MMM", "3M Company", "Industrials", "Conglomerate", 70,
  "FDX", "FedEx Corp.", "Industrials", "Logistics", 70,
  "TT", "Trane Technologies", "Industrials", "HVAC", 80,
  "CTAS", "Cintas Corp.", "Industrials", "Business Services", 75,
  "JCI", "Johnson Controls", "Industrials", "Building Products", 55,
  "CARR", "Carrier Global", "Industrials", "HVAC", 55,
  "PCAR", "PACCAR Inc.", "Industrials", "Trucks", 55,
  "CMI", "Cummins Inc.", "Industrials", "Machinery", 45,
  "ROK", "Rockwell Automation", "Industrials", "Automation", 30,
  "FAST", "Fastenal Co.", "Industrials", "Distribution", 45,
  "AME", "AMETEK Inc.", "Industrials", "Electronics", 42,
  "OTIS", "Otis Worldwide", "Industrials", "Elevators", 40,
  "RSG", "Republic Services", "Industrials", "Waste Management", 60,
  "CPRT", "Copart Inc.", "Industrials", "Auto Auctions", 55,
  "ODFL", "Old Dominion Freight", "Industrials", "Trucking", 40,
  "URI", "United Rentals", "Industrials", "Equipment Rental", 45,
  "VRSK", "Verisk Analytics", "Industrials", "Data Analytics", 38,
  "PWR", "Quanta Services", "Industrials", "Construction", 45,
  "GWW", "W.W. Grainger", "Industrials", "Distribution", 50,
  "HWM", "Howmet Aerospace", "Industrials", "Aerospace", 40,
  "IR", "Ingersoll Rand", "Industrials", "Machinery", 35,
  "DOV", "Dover Corp.", "Industrials", "Machinery", 25,
  "LDOS", "Leidos Holdings", "Industrials", "Defense IT", 20,
  "J", "Jacobs Solutions", "Industrials", "Engineering", 18,
  "SNA", "Snap-on Inc.", "Industrials", "Tools", 16,
  "TDG", "TransDigm Group", "Industrials", "Aerospace", 70,
  "HII", "Huntington Ingalls", "Industrials", "Shipbuilding", 12,
  "LHX", "L3Harris Technologies", "Industrials", "Aerospace", 40,
  "TXT", "Textron Inc.", "Industrials", "Aerospace", 15,
  "WAB", "Westinghouse Air Brake", "Industrials", "Rail Equipment", 30,
  "GNRC", "Generac Holdings", "Industrials", "Electrical Equipment", 10,
  "XYL", "Xylem Inc.", "Industrials", "Water Equipment", 30,
  "DAL", "Delta Air Lines", "Industrials", "Airlines", 35,
  "UAL", "United Airlines", "Industrials", "Airlines", 25,
  "LUV", "Southwest Airlines", "Industrials", "Airlines", 18,
  "AAL", "American Airlines", "Industrials", "Airlines", 10,
  "JBHT", "J.B. Hunt Transport", "Industrials", "Trucking", 18,
  "EXPD", "Expeditors International", "Industrials", "Logistics", 17,
  "CHRW", "C.H. Robinson", "Industrials", "Logistics", 12,
  "EFX", "Equifax Inc.", "Industrials", "Data Services", 32,
  "BR", "Broadridge Financial", "Industrials", "Business Services", 25,
  "PAYX", "Paychex Inc.", "Industrials", "Payroll Services", 50,
  "ADP", "Automatic Data Processing", "Industrials", "Payroll Services", 115,
  "PAYC", "Paycom Software", "Industrials", "Payroll Services", 12,
  "NDSN", "Nordson Corp.", "Industrials", "Machinery", 14,
  "SWK", "Stanley Black & Decker", "Industrials", "Tools", 14,
  "IEX", "IDEX Corp.", "Industrials", "Machinery", 15,
  "PNR", "Pentair plc", "Industrials", "Water Equipment", 15,
  "ALLE", "Allegion plc", "Industrials", "Security", 12,
  "MAS", "Masco Corp.", "Industrials", "Building Products", 16,
  "AOS", "A.O. Smith", "Industrials", "Water Heaters", 12,
  "GEHC", "GE HealthCare", "Industrials", "Medical Equipment", 40,
  "GEV", "GE Vernova", "Industrials", "Power Equipment", 75,
  # International Industrial ADRs
  "CNI", "Canadian National Railway (ADR)", "Industrials", "Railroads", 70,
  "CP", "Canadian Pacific (ADR)", "Industrials", "Railroads", 65,
  "WCN", "Waste Connections (ADR)", "Industrials", "Waste Management", 45,
  
  # ===== ENERGY =====
  "XOM", "Exxon Mobil", "Energy", "Oil & Gas", 450,
  "CVX", "Chevron Corp.", "Energy", "Oil & Gas", 270,
  "COP", "ConocoPhillips", "Energy", "Oil & Gas", 120,
  "SLB", "Schlumberger", "Energy", "Oil Services", 60,
  "EOG", "EOG Resources", "Energy", "Oil & Gas", 70,
  "MPC", "Marathon Petroleum", "Energy", "Refining", 55,
  "PXD", "Pioneer Natural Resources", "Energy", "Oil & Gas", 50,
  "PSX", "Phillips 66", "Energy", "Refining", 50,
  "VLO", "Valero Energy", "Energy", "Refining", 45,
  "OXY", "Occidental Petroleum", "Energy", "Oil & Gas", 45,
  "HES", "Hess Corp.", "Energy", "Oil & Gas", 45,
  "WMB", "Williams Cos.", "Energy", "Pipelines", 55,
  "KMI", "Kinder Morgan", "Energy", "Pipelines", 45,
  "OKE", "ONEOK Inc.", "Energy", "Pipelines", 55,
  "HAL", "Halliburton Co.", "Energy", "Oil Services", 25,
  "DVN", "Devon Energy", "Energy", "Oil & Gas", 25,
  "FANG", "Diamondback Energy", "Energy", "Oil & Gas", 35,
  "BKR", "Baker Hughes", "Energy", "Oil Services", 35,
  "TRGP", "Targa Resources", "Energy", "Pipelines", 35,
  "EQT", "EQT Corp.", "Energy", "Natural Gas", 22,
  "MRO", "Marathon Oil", "Energy", "Oil & Gas", 15,
  "CTRA", "Coterra Energy", "Energy", "Oil & Gas", 20,
  "APA", "APA Corp.", "Energy", "Oil & Gas", 10,
  # International Energy ADRs
  "TTE", "TotalEnergies (ADR)", "Energy", "Oil & Gas", 150,
  "SHEL", "Shell plc (ADR)", "Energy", "Oil & Gas", 210,
  "BP", "BP plc (ADR)", "Energy", "Oil & Gas", 90,
  "PBR", "Petrobras (ADR)", "Energy", "Oil & Gas", 85,
  "ENB", "Enbridge (ADR)", "Energy", "Pipelines", 80,
  "CNQ", "Canadian Natural (ADR)", "Energy", "Oil & Gas", 70,
  "SU", "Suncor Energy (ADR)", "Energy", "Oil & Gas", 45,
  "TRP", "TC Energy (ADR)", "Energy", "Pipelines", 40,
  "VALE", "Vale S.A. (ADR)", "Energy", "Mining", 45,
  
  # ===== MATERIALS =====
  "LIN", "Linde plc", "Materials", "Chemicals", 210,
  "APD", "Air Products", "Materials", "Chemicals", 65,
  "SHW", "Sherwin-Williams", "Materials", "Chemicals", 90,
  "ECL", "Ecolab Inc.", "Materials", "Chemicals", 60,
  "FCX", "Freeport-McMoRan", "Materials", "Mining", 60,
  "NUE", "Nucor Corp.", "Materials", "Steel", 35,
  "NEM", "Newmont Corp.", "Materials", "Gold Mining", 50,
  "DOW", "Dow Inc.", "Materials", "Chemicals", 35,
  "DD", "DuPont de Nemours", "Materials", "Chemicals", 32,
  "CTVA", "Corteva Inc.", "Materials", "Agriculture", 40,
  "VMC", "Vulcan Materials", "Materials", "Construction Materials", 35,
  "MLM", "Martin Marietta", "Materials", "Construction Materials", 35,
  "PPG", "PPG Industries", "Materials", "Chemicals", 28,
  "CE", "Celanese Corp.", "Materials", "Chemicals", 12,
  "IFF", "International Flavors", "Materials", "Chemicals", 22,
  "ALB", "Albemarle Corp.", "Materials", "Chemicals", 12,
  "BALL", "Ball Corp.", "Materials", "Packaging", 18,
  "IP", "International Paper", "Materials", "Paper", 18,
  "PKG", "Packaging Corp.", "Materials", "Packaging", 18,
  "EMN", "Eastman Chemical", "Materials", "Chemicals", 10,
  "FMC", "FMC Corp.", "Materials", "Chemicals", 6,
  "MOS", "Mosaic Co.", "Materials", "Fertilizers", 10,
  "CF", "CF Industries", "Materials", "Fertilizers", 15,
  "AVY", "Avery Dennison", "Materials", "Packaging", 18,
  "AMCR", "Amcor plc", "Materials", "Packaging", 14,
  "LYB", "LyondellBasell", "Materials", "Chemicals", 25,
  # International Materials ADRs
  "BHP", "BHP Group (ADR)", "Materials", "Mining", 140,
  "RIO", "Rio Tinto (ADR)", "Materials", "Mining", 100,
  
  # ===== UTILITIES =====
  "NEE", "NextEra Energy", "Utilities", "Electric", 155,
  "DUK", "Duke Energy", "Utilities", "Electric", 85,
  "SO", "Southern Co.", "Utilities", "Electric", 90,
  "D", "Dominion Energy", "Utilities", "Electric", 45,
  "SRE", "Sempra", "Utilities", "Electric", 50,
  "AEP", "American Electric Power", "Utilities", "Electric", 55,
  "EXC", "Exelon Corp.", "Utilities", "Electric", 45,
  "XEL", "Xcel Energy", "Utilities", "Electric", 35,
  "PEG", "Public Service Enterprise", "Utilities", "Electric", 35,
  "ED", "Consolidated Edison", "Utilities", "Electric", 35,
  "WEC", "WEC Energy", "Utilities", "Electric", 28,
  "ES", "Eversource Energy", "Utilities", "Electric", 22,
  "EIX", "Edison International", "Utilities", "Electric", 28,
  "AWK", "American Water Works", "Utilities", "Water", 28,
  "DTE", "DTE Energy", "Utilities", "Electric", 25,
  "AEE", "Ameren Corp.", "Utilities", "Electric", 25,
  "ETR", "Entergy Corp.", "Utilities", "Electric", 25,
  "FE", "FirstEnergy Corp.", "Utilities", "Electric", 25,
  "PPL", "PPL Corp.", "Utilities", "Electric", 22,
  "CMS", "CMS Energy", "Utilities", "Electric", 20,
  "CNP", "CenterPoint Energy", "Utilities", "Electric", 22,
  "EVRG", "Evergy Inc.", "Utilities", "Electric", 15,
  "NI", "NiSource Inc.", "Utilities", "Gas", 15,
  "ATO", "Atmos Energy", "Utilities", "Gas", 20,
  "LNT", "Alliant Energy", "Utilities", "Electric", 15,
  "PNW", "Pinnacle West", "Utilities", "Electric", 10,
  "NRG", "NRG Energy", "Utilities", "Electric", 18,
  "CEG", "Constellation Energy", "Utilities", "Nuclear", 75,
  "VST", "Vistra Corp.", "Utilities", "Electric", 40,
  "PCG", "PG&E Corp.", "Utilities", "Electric", 45,
  
  # ===== REAL ESTATE =====
  "PLD", "Prologis Inc.", "Real Estate", "Industrial REITs", 110,
  "AMT", "American Tower", "Real Estate", "Tower REITs", 95,
  "EQIX", "Equinix Inc.", "Real Estate", "Data Center REITs", 85,
  "CCI", "Crown Castle", "Real Estate", "Tower REITs", 45,
  "PSA", "Public Storage", "Real Estate", "Storage REITs", 55,
  "O", "Realty Income", "Real Estate", "Retail REITs", 50,
  "WELL", "Welltower Inc.", "Real Estate", "Healthcare REITs", 65,
  "DLR", "Digital Realty", "Real Estate", "Data Center REITs", 55,
  "SPG", "Simon Property", "Real Estate", "Retail REITs", 60,
  "VICI", "VICI Properties", "Real Estate", "Gaming REITs", 35,
  "SBAC", "SBA Communications", "Real Estate", "Tower REITs", 22,
  "AVB", "AvalonBay Communities", "Real Estate", "Residential REITs", 30,
  "EQR", "Equity Residential", "Real Estate", "Residential REITs", 28,
  "VTR", "Ventas Inc.", "Real Estate", "Healthcare REITs", 22,
  "EXR", "Extra Space Storage", "Real Estate", "Storage REITs", 35,
  "ARE", "Alexandria Real Estate", "Real Estate", "Office REITs", 18,
  "MAA", "Mid-America Apartment", "Real Estate", "Residential REITs", 18,
  "ESS", "Essex Property", "Real Estate", "Residential REITs", 18,
  "UDR", "UDR Inc.", "Real Estate", "Residential REITs", 14,
  "INVH", "Invitation Homes", "Real Estate", "Residential REITs", 22,
  "KIM", "Kimco Realty", "Real Estate", "Retail REITs", 15,
  "REG", "Regency Centers", "Real Estate", "Retail REITs", 13,
  "CPT", "Camden Property", "Real Estate", "Residential REITs", 12,
  "BXP", "Boston Properties", "Real Estate", "Office REITs", 12,
  "FRT", "Federal Realty", "Real Estate", "Retail REITs", 10,
  "HST", "Host Hotels", "Real Estate", "Hotel REITs", 12,
  "IRM", "Iron Mountain", "Real Estate", "Storage REITs", 28,
  "DOC", "Healthpeak Properties", "Real Estate", "Healthcare REITs", 14,
  
  # ===== COMMUNICATION =====
  "NFLX", "Netflix Inc.", "Communication", "Streaming", 380,
  "CMCSA", "Comcast Corp.", "Communication", "Cable", 160,
  "VZ", "Verizon Communications", "Communication", "Telecom", 170,
  "T", "AT&T Inc.", "Communication", "Telecom", 155,
  "TMUS", "T-Mobile US", "Communication", "Wireless", 250,
  "CHTR", "Charter Communications", "Communication", "Cable", 50,
  "EA", "Electronic Arts", "Communication", "Gaming", 38,
  "TTWO", "Take-Two Interactive", "Communication", "Gaming", 30,
  "OMC", "Omnicom Group", "Communication", "Advertising", 20,
  "IPG", "Interpublic Group", "Communication", "Advertising", 12,
  "WBD", "Warner Bros. Discovery", "Communication", "Media", 25,
  "MTCH", "Match Group", "Communication", "Internet", 8,
  "PARA", "Paramount Global", "Communication", "Media", 8,
  "NWSA", "News Corp.", "Communication", "Media", 16,
  "NWS", "News Corp. (B)", "Communication", "Media", 16,
  "FOXA", "Fox Corp.", "Communication", "Media", 20,
  "FOX", "Fox Corp. (B)", "Communication", "Media", 20,
  # International Comm ADRs
  "SPOT", "Spotify (ADR)", "Communication", "Streaming", 85,
  "SE", "Sea Limited (ADR)", "Communication", "Gaming/E-Commerce", 45,
  "GRAB", "Grab Holdings (ADR)", "Communication", "Ride-Hailing", 15,
  "TME", "Tencent Music (ADR)", "Communication", "Streaming", 10,
  
  # ===== CHINA/ASIA ADRs =====
  "BABA", "Alibaba Group (ADR)", "Technology", "E-Commerce", 200,
  "PDD", "PDD Holdings (ADR)", "Technology", "E-Commerce", 150,
  "JD", "JD.com (ADR)", "Technology", "E-Commerce", 45,
  "BIDU", "Baidu Inc. (ADR)", "Technology", "Internet Services", 30,
  "NIO", "NIO Inc. (ADR)", "Consumer", "Electric Vehicles", 10,
  "LI", "Li Auto (ADR)", "Consumer", "Electric Vehicles", 20,
  "XPEV", "XPeng Inc. (ADR)", "Consumer", "Electric Vehicles", 10,
  "BILI", "Bilibili (ADR)", "Communication", "Streaming", 6,
  "NTES", "NetEase (ADR)", "Communication", "Gaming", 55,
  "TCOM", "Trip.com (ADR)", "Consumer", "Travel", 30,
  "ZTO", "ZTO Express (ADR)", "Industrials", "Logistics", 15,
  "YUMC", "Yum China (ADR)", "Consumer", "Restaurants", 18,
  "BGNE", "BeiGene (ADR)", "Healthcare", "Biotech", 18,
  "WB", "Weibo (ADR)", "Communication", "Social Media", 2,
  # India ADRs
  "HDB", "HDFC Bank (ADR)", "Finance", "Banks", 140,
  "IBN", "ICICI Bank (ADR)", "Finance", "Banks", 100,
  "INFY", "Infosys (ADR)", "Technology", "IT Services", 75,
  "WIT", "Wipro (ADR)", "Technology", "IT Services", 25,
  "RDY", "Dr. Reddy's (ADR)", "Healthcare", "Pharma", 12,
  # Korea ADRs
  "KB", "KB Financial (ADR)", "Finance", "Banks", 25,
  "SHG", "Shinhan Financial (ADR)", "Finance", "Banks", 18,
  "PKX", "POSCO (ADR)", "Materials", "Steel", 18,
  "LPL", "LG Display (ADR)", "Technology", "Displays", 5,
  # Japan ADRs
  "MUFG", "Mitsubishi UFJ (ADR)", "Finance", "Banks", 120,
  "SMFG", "Sumitomo Mitsui (ADR)", "Finance", "Banks", 80,
  "MFG", "Mizuho Financial (ADR)", "Finance", "Banks", 50,
  "NMR", "Nomura Holdings (ADR)", "Finance", "Investment Banks", 15,
  # Mexico/LatAm ADRs
  "AMX", "America Movil (ADR)", "Communication", "Telecom", 45,
  "FMX", "Fomento Economico (ADR)", "Consumer Staples", "Beverages", 35,
  "KOF", "Coca-Cola FEMSA (ADR)", "Consumer Staples", "Beverages", 15,
  "CIB", "Bancolombia (ADR)", "Finance", "Banks", 10,
  "EC", "Ecopetrol (ADR)", "Energy", "Oil & Gas", 20,
  "GLOB", "Globant (ADR)", "Technology", "IT Services", 10,
  "PAC", "Grupo Aeroportuario (ADR)", "Industrials", "Airports", 12,
  "ERJ", "Embraer (ADR)", "Industrials", "Aerospace", 8,
  # Europe misc ADRs
  "RELX", "RELX plc (ADR)", "Industrials", "Data Services", 80,
  "LOGI", "Logitech (ADR)", "Technology", "Peripherals", 12,
  "STM", "STMicroelectronics (ADR)", "Technology", "Semiconductors", 25,
  "BCE", "BCE Inc. (ADR)", "Communication", "Telecom", 30,
  "NTR", "Nutrien Ltd. (ADR)", "Materials", "Fertilizers", 25
)

# Get unique sectors and industries
ALL_SECTORS <- sort(unique(STOCKS_DB$sector))
ALL_INDUSTRIES <- sort(unique(STOCKS_DB$industry))

# Default sector and its industries
DEFAULT_SECTOR <- "Technology"
DEFAULT_INDUSTRIES <- STOCKS_DB %>%
  filter(sector == DEFAULT_SECTOR) %>%
  pull(industry) %>%
  unique() %>%
  sort()

# Cache file path
CACHE_FILE <- "dipsnipe_cache.rds"

# ============================================================================
# UI
# ============================================================================
ui <- dashboardPage(
  skin = "red",
  
  dashboardHeader(title = "DipSnipe - Daily Losers"),
  
  dashboardSidebar(
    width = 260,
    
    # Date Range (Airline Style)
    tags$div(style = "padding: 10px 15px 5px 15px;",
             tags$label("Date Range:", style = "font-weight: bold;")
    ),
    tags$div(style = "padding: 0 15px 10px 15px;",
             dateRangeInput("date_range",
                            label = NULL,
                            start = Sys.Date() - 7,
                            end = Sys.Date(),
                            min = Sys.Date() - 365,  # Max 1 year back
                            max = Sys.Date(),
                            width = "100%")
    ),
    
    # Market Cap Range
    tags$div(style = "padding: 0 15px 10px 15px;",
             tags$label("Market Cap Range (B):", style = "font-weight: bold;"),
             sliderInput("market_cap_range", 
                         label = NULL,
                         min = 0, max = 3500, 
                         value = c(0, 3500),
                         step = 10,
                         width = "100%")
    ),
    
    # Sector
    tags$div(style = "padding: 0 15px 5px 15px;",
             tags$label("Sector:", style = "font-weight: bold;")
    ),
    tags$div(style = "padding: 0 15px 10px 15px;",
             selectInput("sector_sel", 
                         label = NULL,
                         choices = c("All", ALL_SECTORS),
                         selected = "Technology",
                         width = "100%")
    ),
    
    # Industry (Dynamic)
    tags$div(style = "padding: 0 15px 5px 15px;",
             tags$label("Industry:", style = "font-weight: bold;")
    ),
    tags$div(style = "padding: 0 15px 10px 15px;",
             selectInput("industry_sel", 
                         label = NULL,
                         choices = c("All", DEFAULT_INDUSTRIES),
                         selected = "All",
                         width = "100%")
    ),
    
    # Show Only Losers (default TRUE)
    tags$div(style = "padding: 5px 15px 15px 15px;",
             checkboxInput("only_negative", "Show Only Losers", value = TRUE)
    ),
    
    tags$hr(style = "margin: 5px 15px;"),
    
    # Load Data button
    tags$div(style = "padding: 10px 15px;",
             actionButton("refresh", 
                          label = tagList(icon("sync"), " Refresh Data"),
                          class = "btn-danger btn-block",
                          style = "width: 100%;")
    ),
    
    tags$br(),
    
    # Status / Data Source
    tags$div(style = "padding: 5px 15px;",
             htmlOutput("status_text")
    ),
    
    tags$div(style = "padding: 5px 15px;",
             textOutput("data_source")
    )
  ),
  
  dashboardBody(
    tags$head(
      tags$style(HTML("
        .content-wrapper { background-color: #ecf0f1; }
        .box { border-top: 3px solid #dd4b39; }
        .small-box .icon { font-size: 70px; }
        .btn-danger { background-color: #dd4b39; border-color: #d73925; }
        .btn-danger:hover { background-color: #d73925; }
        a { color: #3c8dbc; }
        a:hover { color: #72afd2; text-decoration: underline; }
      "))
    ),
    
    # Value boxes (3 boxes - removed Avg Return, added Breadth)
    fluidRow(
      valueBoxOutput("total_tickers", width = 4),
      valueBoxOutput("breadth_pct", width = 4),
      valueBoxOutput("worst_return", width = 4)
    ),
    
    # Data table
    fluidRow(
      box(
        title = "Day Performance Leaderboard (Worst to Best)", 
        width = 12,
        status = "danger",
        solidHeader = TRUE,
        DTOutput("metrics_table")
      )
    ),
    
    # Chart
    fluidRow(
      box(
        title = "Price History", 
        width = 12,
        status = "danger",
        solidHeader = TRUE,
        plotlyOutput("price_chart", height = "400px")
      )
    )
  )
)

# ============================================================================
# SERVER
# ============================================================================
server <- function(input, output, session) {
  
  status <- reactiveVal("Loading...")
  data_source <- reactiveVal("")
  
  # ---- DYNAMIC INDUSTRY FILTER ----
  # Updates industry dropdown when sector changes
  observeEvent(input$sector_sel, {
    req(input$sector_sel)
    
    if (input$sector_sel == "All") {
      new_choices <- c("All", ALL_INDUSTRIES)
    } else {
      # Get only industries that exist in selected sector
      filtered_industries <- STOCKS_DB %>%
        filter(sector == input$sector_sel) %>%
        pull(industry) %>%
        unique() %>%
        sort()
      new_choices <- c("All", filtered_industries)
    }
    
    # Update the dropdown
    updateSelectInput(session, "industry_sel", 
                      choices = new_choices, 
                      selected = "All")
  }, ignoreInit = TRUE)  # Don't fire on app load since we set defaults in UI
  
  # ---- FETCH DATA (with caching) ----
  market_data <- eventReactive(input$refresh, {
    
    start_date <- input$date_range[1]
    end_date <- input$date_range[2]
    
    # Filter DB by sector, industry, market cap
    filtered_db <- STOCKS_DB
    
    if (input$sector_sel != "All") {
      filtered_db <- filtered_db %>% filter(sector == input$sector_sel)
    }
    if (input$industry_sel != "All") {
      filtered_db <- filtered_db %>% filter(industry == input$industry_sel)
    }
    filtered_db <- filtered_db %>%
      filter(market_cap_b >= input$market_cap_range[1],
             market_cap_b <= input$market_cap_range[2])
    
    tickers_to_fetch <- filtered_db$symbol
    
    if (length(tickers_to_fetch) == 0) {
      status("No tickers match filters")
      return(NULL)
    }
    
    status(paste("Fetching", length(tickers_to_fetch), "stocks..."))
    
    result <- tryCatch({
      withProgress(message = 'Loading data...', value = 0, {
        
        # Check cache
        cache_valid <- FALSE
        if (file.exists(CACHE_FILE)) {
          info <- file.info(CACHE_FILE)
          age_hours <- difftime(Sys.time(), info$mtime, units = "hours")
          if (age_hours < 12) {
            cache_valid <- TRUE
          }
        }
        
        prices <- NULL
        
        if (cache_valid) {
          incProgress(0.2, detail = "Checking cache...")
          cached_data <- readRDS(CACHE_FILE)
          
          # Check if cache has our date range
          if (!is.null(cached_data) && nrow(cached_data) > 0) {
            cached_dates <- unique(cached_data$date)
            cache_min <- min(cached_dates, na.rm = TRUE)
            
            # Use cache if it has data around our start date
            if (!is.na(cache_min) && cache_min <= start_date + 7) {
              prices <- cached_data %>% filter(symbol %in% tickers_to_fetch)
              if (nrow(prices) > 0) {
                data_source("Source: Yahoo & NASDAQ")
              } else {
                prices <- NULL
              }
            }
          }
        }
        
        # If no valid cache, fetch fresh
        if (is.null(prices) || nrow(prices) == 0) {
          incProgress(0.3, detail = "Downloading from Yahoo...")
          data_source("Source: Live Download")
          
          # Limit fetch to reasonable window (max 365 days back from end date)
          max_lookback <- 365
          fetch_start <- max(start_date - 30, end_date - max_lookback)
          
          prices <- tq_get(tickers_to_fetch,
                           get = "stock.prices",
                           from = fetch_start,
                           to = end_date + 1,
                           complete_cases = FALSE)
          
          # Save to cache
          if (!is.null(prices) && nrow(prices) > 0) {
            tryCatch({
              saveRDS(prices, CACHE_FILE)
            }, error = function(e) {
              message("Cache save error: ", e$message)
            })
          }
        }
        
        incProgress(0.4, detail = "Processing...")
        
        if (is.null(prices) || nrow(prices) == 0) {
          status("Error: No data returned")
          return(NULL)
        }
        
        # Smart weekend fallback: use available dates
        available_dates <- unique(prices$date)
        
        # Safely find actual start/end dates
        dates_after_start <- available_dates[available_dates >= start_date]
        dates_before_end <- available_dates[available_dates <= end_date]
        
        # Handle edge cases where no dates match
        if (length(dates_after_start) == 0) {
          actual_start <- min(available_dates, na.rm = TRUE)
        } else {
          actual_start <- min(dates_after_start, na.rm = TRUE)
        }
        
        if (length(dates_before_end) == 0) {
          actual_end <- max(available_dates, na.rm = TRUE)
        } else {
          actual_end <- max(dates_before_end, na.rm = TRUE)
        }
        
        # Final safety check
        if (is.na(actual_start) || is.infinite(actual_start)) {
          actual_start <- min(available_dates, na.rm = TRUE)
        }
        if (is.na(actual_end) || is.infinite(actual_end)) {
          actual_end <- max(available_dates, na.rm = TRUE)
        }
        
        # Calculate cumulative returns
        filtered_prices <- prices %>%
          filter(date >= actual_start, date <= actual_end)
        
        if (nrow(filtered_prices) == 0) {
          status("No price data in selected date range")
          return(NULL)
        }
        
        results <- filtered_prices %>%
          group_by(symbol) %>%
          filter(n() >= 1) %>%  # Must have at least 1 data point
          summarize(
            start_price = first(close[order(date)]),
            end_price = last(close[order(date)]),
            start_date = min(date, na.rm = TRUE),
            end_date = max(date, na.rm = TRUE),
            .groups = "drop"
          ) %>%
          filter(!is.na(start_price) & !is.na(end_price) & start_price > 0) %>%
          mutate(
            cum_return_pct = round(((end_price - start_price) / start_price) * 100, 2)
          )
        
        # Join with metadata
        results <- results %>%
          left_join(filtered_db, by = "symbol") %>%
          arrange(cum_return_pct)
        
        incProgress(0.3, detail = "Done!")
        
        status(paste("✓", nrow(results), "stocks loaded (",
                     format(actual_start, "%m/%d"), "-",
                     format(actual_end, "%m/%d"), ")"))
        
        return(results)
      })
      
    }, error = function(e) {
      status(paste("Error:", e$message))
      return(NULL)
    })
    
    result
  }, ignoreNULL = FALSE)  # AUTO-LOAD on startup!
  
  # ---- FILTERED DATA ----
  display_data <- reactive({
    req(market_data())
    df <- market_data()
    
    if (input$only_negative) {
      df <- df %>% filter(cum_return_pct < 0)
    }
    
    df
  })
  
  # ---- STATUS ----
  output$status_text <- renderUI({
    HTML(paste0(
      "<div style='padding: 10px; background: #2c3e50; color: white; border-radius: 4px; font-size: 12px;'>",
      status(),
      "</div>"
    ))
  })
  
  output$data_source <- renderText({
    data_source()
  })
  
  # ---- VALUE BOXES ----
  output$total_tickers <- renderValueBox({
    df <- display_data()
    count <- if (!is.null(df)) nrow(df) else 0
    valueBox(count, "Stocks Matching", icon = icon("list"), color = "blue")
  })
  
  output$breadth_pct <- renderValueBox({
    df <- market_data()
    if (!is.null(df) && nrow(df) > 0) {
      losers <- sum(df$cum_return_pct < 0, na.rm = TRUE)
      total <- nrow(df)
      pct <- round((losers / total) * 100, 1)
    } else {
      pct <- 0
    }
    color <- if (pct > 50) "red" else "green"
    valueBox(paste0(pct, "%"), "Stocks Down (Breadth)", icon = icon("chart-pie"), color = color)
  })
  
  output$worst_return <- renderValueBox({
    df <- display_data()
    if (!is.null(df) && nrow(df) > 0) {
      worst_row <- df %>% slice_min(cum_return_pct, n = 1)
      worst_val <- worst_row$cum_return_pct[1]
      worst_ticker <- worst_row$symbol[1]
    } else {
      worst_val <- 0
      worst_ticker <- "N/A"
    }
    valueBox(
      paste0(worst_val, "% (", worst_ticker, ")"), 
      "Worst Performer", 
      icon = icon("arrow-down"), 
      color = "red"
    )
  })
  
  # ---- DATA TABLE ----
  output$metrics_table <- renderDT({
    df <- display_data()
    
    if (is.null(df) || nrow(df) == 0) {
      return(datatable(
        data.frame(Message = "No data - adjust filters or click Refresh"),
        options = list(dom = 't'),
        rownames = FALSE
      ))
    }
    
    # Create display dataframe with hyperlinks
    df_display <- df %>%
      mutate(
        Company = paste0("<a href='https://finance.yahoo.com/quote/", symbol,
                         "' target='_blank'>", company, "</a>"),
        Ticker = symbol,
        Sector = sector,
        Industry = industry,
        `Mkt Cap` = paste0("$", market_cap_b, "B"),
        `Cum. Return` = cum_return_pct
      ) %>%
      select(Ticker, Company, Sector, Industry, `Mkt Cap`, `Cum. Return`)
    
    datatable(
      df_display,
      selection = 'single',
      rownames = FALSE,
      escape = FALSE,  # CRITICAL: render HTML links
      options = list(
        pageLength = 25, 
        scrollX = TRUE, 
        dom = 'frtip',
        order = list(list(5, 'asc'))
      )
    ) %>%
      formatStyle(
        'Cum. Return',
        color = styleInterval(0, c('#d73925', '#00a65a')),
        fontWeight = 'bold'
      )
  })
  
  # ---- CHART ----
  output$price_chart <- renderPlotly({
    idx <- input$metrics_table_rows_selected
    df <- display_data()
    
    if (is.null(idx) || is.null(df) || nrow(df) == 0) {
      return(
        plot_ly() %>%
          layout(
            title = list(text = "Select a ticker from the table", font = list(size = 16)),
            xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
            yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE)
          )
      )
    }
    
    ticker <- df$symbol[idx]
    cum_return <- df$cum_return_pct[idx]
    company_name <- df$company[idx]
    
    # Fetch chart data with buffer
    chart_start <- input$date_range[1] - 30
    chart_end <- input$date_range[2] + 1
    
    chart_data <- tryCatch({
      tq_get(ticker, 
             get = "stock.prices", 
             from = chart_start,
             to = chart_end)
    }, error = function(e) {
      message("Chart fetch error: ", e$message)
      NULL
    })
    
    if (is.null(chart_data) || nrow(chart_data) == 0) {
      return(plot_ly() %>% layout(title = paste("No data for", ticker)))
    }
    
    line_color <- if (cum_return < 0) '#e74c3c' else '#27ae60'
    
    plot_ly(data = chart_data, x = ~date, y = ~close,
            type = 'scatter', mode = 'lines',
            line = list(color = line_color, width = 2.5),
            hovertemplate = "<b>%{x}</b><br>Close: $%{y:.2f}<extra></extra>") %>%
      layout(
        title = list(
          text = paste0(ticker, " - ", company_name, " | Cum. Return: ", cum_return, "%"),
          font = list(size = 14)
        ),
        xaxis = list(title = "", gridcolor = '#ecf0f1'),
        yaxis = list(title = "Price ($)", gridcolor = '#ecf0f1', tickprefix = "$"),
        hovermode = "x unified"
      )
  })
}

# ============================================================================
# RUN
# ============================================================================
shinyApp(ui, server)
