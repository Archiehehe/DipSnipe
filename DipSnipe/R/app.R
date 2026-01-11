# DipSnipe - Daily Losers Dashboard
# Original red shinydashboard theme with all S&P 500 + International ADRs

library(shiny)
library(shinydashboard)
library(DT)
library(plotly)
library(dplyr)
library(tidyquant)
library(lubridate)

# ============================================================================
# COMPLETE S&P 500 + INTERNATIONAL ADRs ($20B+)
# ============================================================================
SP500_TICKERS <- c(
  # S&P 500 - Complete List (503 tickers)
  "A", "AAL", "AAPL", "ABBV", "ABNB", "ABT", "ACGL", "ACN", "ADBE", "ADI",
  "ADM", "ADP", "ADSK", "AEE", "AEP", "AES", "AFL", "AIG", "AIZ", "AJG",
  "AKAM", "ALB", "ALGN", "ALL", "ALLE", "AMAT", "AMCR", "AMD", "AME", "AMGN",
  "AMP", "AMT", "AMZN", "ANET", "ANSS", "AON", "AOS", "APA", "APD", "APH",
  "APTV", "ARE", "ATO", "AVB", "AVGO", "AVY", "AWK", "AXON", "AXP", "AZO",
  "BA", "BAC", "BALL", "BAX", "BBWI", "BBY", "BDX", "BEN", "BF.B", "BG",
  "BIIB", "BIO", "BK", "BKNG", "BKR", "BLDR", "BLK", "BMY", "BR", "BRK.B",
  "BRO", "BSX", "BWA", "BX", "BXP", "C", "CAG", "CAH", "CARR", "CAT",
  "CB", "CBOE", "CBRE", "CCI", "CCL", "CDNS", "CDW", "CE", "CEG", "CF",
  "CFG", "CHD", "CHRW", "CHTR", "CI", "CINF", "CL", "CLX", "CMCSA", "CME",
  "CMG", "CMI", "CMS", "CNC", "CNP", "COF", "COO", "COP", "COR", "COST",
  "CPAY", "CPB", "CPRT", "CPT", "CRL", "CRM", "CSCO", "CSGP", "CSX", "CTAS",
  "CTLT", "CTRA", "CTSH", "CTVA", "CVS", "CVX", "CZR", "D", "DAL", "DD",
  "DE", "DECK", "DFS", "DG", "DGX", "DHI", "DHR", "DIS", "DLR", "DLTR",
  "DOC", "DOV", "DOW", "DPZ", "DRI", "DTE", "DUK", "DVA", "DVN", "DXCM",
  "EA", "EBAY", "ECL", "ED", "EFX", "EG", "EIX", "EL", "ELV", "EMN",
  "EMR", "ENPH", "EOG", "EPAM", "EQIX", "EQR", "EQT", "ES", "ESS", "ETN",
  "ETR", "ETSY", "EVRG", "EW", "EXC", "EXPD", "EXPE", "EXR", "F", "FANG",
  "FAST", "FCNCA", "FCX", "FDS", "FDX", "FE", "FFIV", "FI", "FICO", "FIS",
  "FITB", "FLT", "FMC", "FOX", "FOXA", "FRT", "FSLR", "FTNT", "FTV", "GD",
  "GDDY", "GE", "GEHC", "GEN", "GEV", "GILD", "GIS", "GL", "GLW", "GM",
  "GNRC", "GOOG", "GOOGL", "GPC", "GPN", "GRMN", "GS", "GWW", "HAL", "HAS",
  "HBAN", "HCA", "HD", "HES", "HIG", "HII", "HLT", "HOLX", "HON", "HPE",
  "HPQ", "HRL", "HSIC", "HST", "HSY", "HUBB", "HUM", "HWM", "IBM", "ICE",
  "IDXX", "IEX", "IFF", "ILMN", "INCY", "INTC", "INTU", "INVH", "IP", "IPG",
  "IQV", "IR", "IRM", "ISRG", "IT", "ITW", "IVZ", "J", "JBHT", "JBL",
  "JCI", "JKHY", "JNJ", "JNPR", "JPM", "K", "KDP", "KEY", "KEYS", "KHC",
  "KIM", "KKR", "KLAC", "KMB", "KMI", "KMX", "KO", "KR", "KVUE", "L",
  "LDOS", "LEN", "LH", "LHX", "LIN", "LKQ", "LLY", "LMT", "LNT", "LOW",
  "LRCX", "LULU", "LUV", "LVS", "LW", "LYB", "LYV", "MA", "MAA", "MAR",
  "MAS", "MCD", "MCHP", "MCK", "MCO", "MDLZ", "MDT", "MET", "META", "MGM",
  "MHK", "MKC", "MKTX", "MLM", "MMC", "MMM", "MNST", "MO", "MOH", "MOS",
  "MPC", "MPWR", "MRK", "MRNA", "MRO", "MS", "MSCI", "MSFT", "MSI", "MTB",
  "MTCH", "MTD", "MU", "NCLH", "NDAQ", "NDSN", "NEE", "NEM", "NFLX", "NI",
  "NKE", "NOC", "NOW", "NRG", "NSC", "NTAP", "NTRS", "NUE", "NVDA", "NVR",
  "NWS", "NWSA", "NXPI", "O", "ODFL", "OKE", "OMC", "ON", "ORCL", "ORLY",
  "OTIS", "OXY", "PANW", "PARA", "PAYC", "PAYX", "PCAR", "PCG", "PEG", "PEP",
  "PFE", "PFG", "PG", "PGR", "PH", "PHM", "PKG", "PLD", "PM", "PNC",
  "PNR", "PNW", "PODD", "POOL", "PPG", "PPL", "PRU", "PSA", "PSX", "PTC",
  "PWR", "PXD", "PYPL", "QCOM", "QRVO", "RCL", "REG", "REGN", "RF", "RJF",
  "RL", "RMD", "ROK", "ROL", "ROP", "ROST", "RSG", "RTX", "RVTY", "SBAC",
  "SBUX", "SCHW", "SHW", "SJM", "SLB", "SMCI", "SNA", "SNPS", "SO", "SOLV",
  "SPG", "SPGI", "SRE", "STE", "STLD", "STT", "STX", "STZ", "SWK", "SWKS",
  "SYF", "SYK", "SYY", "T", "TAP", "TDG", "TDY", "TECH", "TEL", "TER",
  "TFC", "TFX", "TGT", "TJX", "TMO", "TMUS", "TPR", "TRGP", "TRMB", "TROW",
  "TRV", "TSCO", "TSLA", "TSN", "TT", "TTWO", "TXN", "TXT", "TYL", "UAL",
  "UBER", "UDR", "UHS", "ULTA", "UNH", "UNP", "UPS", "URI", "USB", "V",
  "VFC", "VICI", "VLO", "VLTO", "VMC", "VRSK", "VRSN", "VRTX", "VST", "VTR",
  "VTRS", "VZ", "WAB", "WAT", "WBA", "WBD", "WDC", "WEC", "WELL", "WFC",
  "WM", "WMB", "WMT", "WRB", "WST", "WTW", "WY", "WYNN", "XEL", "XOM",
  "XYL", "YUM", "ZBH", "ZBRA", "ZTS"
)

# International ADRs & Large Foreign Stocks ($20B+ Market Cap)
INTL_ADRS <- c(
  # Asia - Mega Caps
  "TSM", "BABA", "PDD", "JD", "BIDU", "NIO", "LI", "XPEV", "BILI", "TME",
  "NTES", "TCOM", "ZTO", "YUMC", "BGNE", "TAL", "EDU", "WB",
  "TM", "SONY", "HMC", "MUFG", "SMFG", "MFG", "NMR",
  "HDB", "IBN", "INFY", "WIT", "TTM", "RDY",
  "KB", "SHG", "PKX", "LPL",
  "SE", "GRAB",
  # Europe - Mega Caps
  "ASML", "NVO", "SAP", "TTE", "SHEL", "BP", "UL", "GSK", "AZN", "BTI",
  "DEO", "RIO", "BHP", "HSBC", "LYG", "BCS", "ING", "DB", "UBS",
  "SHOP", "TD", "RY", "BNS", "BMO", "CM", "ENB", "CNQ", "SU", "TRP",
  "CP", "CNI", "BCE", "NTR", "MFC", "SLF", "WCN",
  "SPOT", "RELX", "RACE", "LOGI", "STM",
  # Latin America
  "MELI", "NU", "VALE", "PBR", "ITUB", "BBD", "ABEV", "ERJ", "BSBR",
  "AMX", "FMX", "KOF", "CIB", "EC", "GLOB", "PAC"
)

ALL_TICKERS <- unique(c(SP500_TICKERS, INTL_ADRS))

# Sector mapping
SECTOR_MAP <- list(
  "Technology" = c("AAPL", "MSFT", "NVDA", "AVGO", "ORCL", "CRM", "ADBE", "AMD", "CSCO", "ACN",
                   "IBM", "INTC", "QCOM", "TXN", "NOW", "INTU", "AMAT", "ADI", "LRCX", "MU",
                   "KLAC", "SNPS", "CDNS", "MCHP", "NXPI", "FTNT", "PANW", "ANSS",
                   "KEYS", "FSLR", "IT", "MPWR", "GEN", "ZBRA", "FFIV", "JNPR", "AKAM", "EPAM",
                   "PTC", "TYL", "SWKS", "QRVO", "TER", "SMCI", "HPE", "HPQ", "NTAP", "WDC",
                   "STX", "TSM", "ASML", "SAP"),
  "Finance" = c("JPM", "V", "MA", "BAC", "WFC", "GS", "MS", "SPGI", "BLK", "SCHW", "AXP",
                "C", "USB", "PNC", "TFC", "BK", "COF", "CME", "ICE", "MCO", "CB", "MMC",
                "AON", "MET", "PRU", "AIG", "AFL", "ALL", "TRV", "PGR", "AJG", "MSCI",
                "NDAQ", "MKTX", "FITB", "MTB", "HBAN", "CFG", "RF", "KEY", "NTRS", "STT",
                "DFS", "SYF", "CINF", "L", "BRO", "WRB", "ACGL", "GL", "AIZ", "RJF",
                "HIG", "TROW", "BEN", "IVZ", "FDS", "FCNCA", "FI", "FLT",
                "CPAY", "GPN", "JKHY", "PYPL", "FIS", "KKR", "BX", "MELI", "NU"),
  "Healthcare" = c("UNH", "JNJ", "LLY", "MRK", "ABBV", "PFE", "TMO", "ABT", "DHR", "AMGN",
                   "MDT", "ELV", "CI", "BMY", "ISRG", "VRTX", "GILD", "SYK", "REGN", "BSX",
                   "BDX", "ZTS", "HCA", "MCK", "CVS", "COR", "HUM", "IDXX", "DXCM", "IQV",
                   "A", "MTD", "EW", "RMD", "PODD", "ALGN", "WST", "HOLX", "COO", "TFX",
                   "TECH", "RVTY", "CRL", "DGX", "ILMN", "MOH", "CNC", "DVA", "LH", "BAX",
                   "BIIB", "MRNA", "INCY", "VTRS", "CTLT", "HSIC", "CAH", "NVO", "AZN", "GSK"),
  "Consumer Discretionary" = c("AMZN", "TSLA", "HD", "MCD", "NKE", "LOW", "BKNG", "SBUX", "TJX",
                               "CMG", "ORLY", "MAR", "AZO", "ROST", "YUM", "DHI", "RCL", "GM",
                               "F", "LEN", "PHM", "DRI", "HLT", "CCL", "NCLH", "WYNN", "LVS",
                               "DECK", "LULU", "GRMN", "BBY", "EBAY", "ETSY", "POOL", "DPZ",
                               "APTV", "BWA", "MGM", "CZR", "GPC", "KMX", "ULTA", "TSCO", "TPR",
                               "VFC", "HAS", "NVR", "LKQ", "RL", "MHK", "NWSA", "NWS",
                               "FOXA", "FOX", "LYV", "PARA", "WBD", "DIS", "ABNB", "EXPE"),
  "Consumer Staples" = c("PG", "COST", "WMT", "KO", "PEP", "PM", "MDLZ", "MO", "CL", "EL",
                         "KMB", "GIS", "KHC", "SYY", "HSY", "KDP", "KR", "STZ", "ADM", "CAG",
                         "CLX", "MKC", "CHD", "K", "HRL", "TSN", "SJM", "CPB", "TAP", "BG",
                         "LW", "BF.B", "MNST", "KVUE", "WBA", "TGT", "DG", "DLTR"),
  "Industrials" = c("CAT", "GE", "HON", "UNP", "UPS", "DE", "RTX", "BA", "LMT", "ETN",
                    "ITW", "EMR", "PH", "NOC", "GD", "WM", "CSX", "NSC", "MMM", "FDX",
                    "TT", "CTAS", "JCI", "CARR", "PCAR", "CMI", "ROK", "FAST", "AME", "OTIS",
                    "RSG", "CPRT", "ODFL", "URI", "VRSK", "PWR", "GWW", "HWM", "IR", "DOV",
                    "LDOS", "J", "SNA", "TDG", "HII", "LHX", "TXT", "WAB", "GNRC", "XYL",
                    "DAL", "UAL", "LUV", "AAL", "JBHT", "EXPD", "CHRW", "EFX", "BR", "PAYX",
                    "ADP", "PAYC", "NDSN", "SWK", "IEX", "PNR", "ALLE", "MAS", "AOS"),
  "Energy" = c("XOM", "CVX", "COP", "SLB", "EOG", "MPC", "PXD", "PSX", "VLO", "OXY",
               "HES", "WMB", "KMI", "OKE", "HAL", "DVN", "FANG", "BKR", "TRGP", "EQT",
               "MRO", "CTRA", "APA", "TTE", "SHEL", "BP", "PBR", "VALE"),
  "Materials" = c("LIN", "APD", "SHW", "ECL", "FCX", "NUE", "NEM", "DOW", "DD", "CTVA",
                  "VMC", "MLM", "PPG", "CE", "IFF", "ALB", "BALL", "IP", "PKG", "EMN",
                  "FMC", "MOS", "CF", "AVY", "AMCR", "LYB", "BHP", "RIO"),
  "Utilities" = c("NEE", "DUK", "SO", "D", "SRE", "AEP", "EXC", "XEL", "PEG", "ED",
                  "WEC", "ES", "EIX", "AWK", "DTE", "AEE", "ETR", "FE", "PPL", "CMS",
                  "CNP", "EVRG", "NI", "ATO", "LNT", "PNW", "NRG", "CEG", "VST", "PCG"),
  "Real Estate" = c("PLD", "AMT", "EQIX", "CCI", "PSA", "O", "WELL", "DLR", "SPG", "VICI",
                    "SBAC", "AVB", "EQR", "VTR", "EXR", "ARE", "MAA", "ESS", "UDR", "INVH",
                    "KIM", "REG", "CPT", "BXP", "FRT", "HST", "IRM", "DOC"),
  "Communication" = c("META", "GOOGL", "GOOG", "NFLX", "DIS", "CMCSA", "VZ", "T", "TMUS", "CHTR",
                      "EA", "TTWO", "OMC", "IPG", "WBD", "MTCH", "LYV", "PARA", "NWSA", "NWS",
                      "FOXA", "FOX"),
  "International ADRs" = INTL_ADRS
)

# Get all sectors
ALL_SECTORS <- names(SECTOR_MAP)

# Reverse lookup
get_sector <- function(ticker) {
  for (sector in names(SECTOR_MAP)) {
    if (ticker %in% SECTOR_MAP[[sector]]) return(sector)
  }
  return("Other")
}

# Industries
ALL_INDUSTRIES <- c("All", "Semiconductors", "Software", "Banks", "Insurance", "Pharma", 
                    "Biotech", "Retail", "Auto", "Aerospace", "Oil & Gas", "Utilities",
                    "REITs", "Media", "Telecom", "Food & Beverage", "Healthcare Services")

# ============================================================================
# UI - Original shinydashboard red theme
# ============================================================================
ui <- dashboardPage(
  skin = "red",
  
  dashboardHeader(title = "DipSnipe - Daily Losers"),
  
  dashboardSidebar(
    width = 250,
    
    # Trading Date RANGE (Replacing single Date)
    tags$div(style = "padding: 10px 15px 5px 15px;",
             tags$label("Trading Date Range:", style = "font-weight: bold;")
    ),
    tags$div(style = "padding: 0 15px 10px 15px;",
             dateRangeInput("date_range_sel", 
                            label = NULL,
                            start = Sys.Date() - 1,
                            end = Sys.Date() - 1,
                            max = Sys.Date(),
                            width = "100%")
    ),
    
    # Market Cap Range
    tags$div(style = "padding: 0 15px 10px 15px;",
             tags$label("Market Cap Range (B):", style = "font-weight: bold;"),
             sliderInput("market_cap_range", 
                         label = NULL,
                         min = 0, max = 3000, 
                         value = c(0, 3000),
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
                         selected = "All",
                         width = "100%")
    ),
    
    # Industry
    tags$div(style = "padding: 0 15px 5px 15px;",
             tags$label("Industry:", style = "font-weight: bold;")
    ),
    tags$div(style = "padding: 0 15px 10px 15px;",
             selectInput("industry_sel", 
                         label = NULL,
                         choices = ALL_INDUSTRIES,
                         selected = "All",
                         width = "100%")
    ),
    
    # Show Only Losers
    tags$div(style = "padding: 5px 15px 15px 15px;",
             checkboxInput("only_negative", "Show Only Losers", value = FALSE)
    ),
    
    tags$hr(style = "margin: 5px 15px;"),
    
    # Load Data button
    tags$div(style = "padding: 10px 15px;",
             actionButton("refresh", 
                          label = tagList(icon("sync"), " Load Data"),
                          class = "btn-danger btn-block",
                          style = "width: 100%;")
    ),
    
    tags$br(),
    
    # Status
    tags$div(style = "padding: 5px 15px;",
             htmlOutput("status_text")
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
      "))
    ),
    
    # Value boxes
    fluidRow(
      valueBoxOutput("total_tickers", width = 3),
      valueBoxOutput("avg_return", width = 3),
      valueBoxOutput("worst_return", width = 3),
      valueBoxOutput("losers_count", width = 3)
    ),
    
    # Data table
    fluidRow(
      box(
        title = "Performance Leaderboard (Worst to Best)", 
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
  
  status <- reactiveVal("Ready")
  
  # ---- FETCH DATA ----
  stock_data <- eventReactive(input$refresh, {
    
    # Determine tickers based on sector
    tickers_to_fetch <- if (input$sector_sel == "All") {
      ALL_TICKERS
    } else {
      SECTOR_MAP[[input$sector_sel]]
    }
    
    status(paste("Fetching", length(tickers_to_fetch), "stocks..."))
    
    result <- tryCatch({
      withProgress(message = 'Downloading from Yahoo Finance...', value = 0, {
        
        incProgress(0.1, detail = "Connecting...")
        
        # Get selected dates
        d_start <- input$date_range_sel[1]
        d_end   <- input$date_range_sel[2]
        
        # We need data from a few days before start to ensure we get open/close properly
        # For single day: same as before. For range: we need the full range.
        fetch_start <- d_start - 7 
        fetch_end   <- d_end + 1
        
        incProgress(0.2, detail = paste("Fetching", length(tickers_to_fetch), "tickers..."))
        
        data <- tq_get(tickers_to_fetch,
                       get = "stock.prices",
                       from = fetch_start,
                       to = fetch_end,
                       complete_cases = FALSE)
        
        incProgress(0.5, detail = "Processing...")
        
        if (is.null(data) || nrow(data) == 0) {
          status("Error: No data returned")
          return(NULL)
        }
        
        # --- LOGIC BRANCHING ---
        
        # CASE 1: Single Day Selected (Start == End) -> Original Logic (Intraday Open vs Close)
        if (d_start == d_end) {
          
          target_date <- d_start
          available_dates <- unique(data$date)
          
          # Fallback if specific date missing
          if (!(target_date %in% available_dates)) {
            target_date <- max(available_dates[available_dates <= d_start])
            if (is.na(target_date) || length(target_date) == 0) target_date <- max(available_dates)
          }
          
          df <- data %>%
            filter(date == target_date) %>%
            mutate(
              day_return_pct = round(((close - open) / open) * 100, 2),
              day_range_pct = round(((high - low) / open) * 100, 2),
              sector = sapply(symbol, get_sector)
            ) %>%
            arrange(day_return_pct)
          
          # Store metadata
          attr(df, "mode") <- "single"
          attr(df, "date_label") <- as.character(target_date)
          
        } else {
          
          # CASE 2: Date Range Selected -> (Close on End Date) vs (Close on Start Date)
          # Logic: "How did this stock perform over this trip?"
          
          df_start <- data %>% filter(date >= d_start) %>% group_by(symbol) %>% slice(1) %>% select(symbol, start_price = close, start_date = date)
          df_end   <- data %>% filter(date <= d_end)   %>% group_by(symbol) %>% slice(n()) %>% select(symbol, end_price = close, end_date = date)
          
          df <- inner_join(df_start, df_end, by = "symbol") %>%
            mutate(
              day_return_pct = round(((end_price - start_price) / start_price) * 100, 2),
              open = start_price, # Re-using column names for table compatibility
              close = end_price,
              sector = sapply(symbol, get_sector)
            ) %>%
            arrange(day_return_pct)
          
          attr(df, "mode") <- "range"
          attr(df, "date_label") <- paste(d_start, "to", d_end)
        }
        
        incProgress(0.2, detail = "Done!")
        
        if (nrow(df) == 0) {
          status(paste("No data for selected period"))
          return(NULL)
        }
        
        status(paste("✓", nrow(df), "stocks loaded"))
        return(df)
      })
      
    }, error = function(e) {
      status(paste("Error:", e$message))
      return(NULL)
    })
    
    result
  })
  
  # ---- FILTERED DATA ----
  display_data <- reactive({
    req(stock_data())
    df <- stock_data()
    
    if (input$only_negative) {
      df <- df %>% filter(day_return_pct < 0)
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
  
  # ---- VALUE BOXES ----
  output$total_tickers <- renderValueBox({
    df <- display_data()
    count <- if (!is.null(df)) nrow(df) else 0
    valueBox(count, "Tickers", icon = icon("list"), color = "blue")
  })
  
  output$avg_return <- renderValueBox({
    df <- display_data()
    avg <- if (!is.null(df) && nrow(df) > 0) round(mean(df$day_return_pct, na.rm = TRUE), 2) else 0
    color <- if (avg < 0) "red" else "green"
    
    # Dynamic Label
    lbl <- "Avg Return"
    if (!is.null(df) && !is.null(attr(df, "mode")) && attr(df, "mode") == "range") {
      lbl <- "Avg Period Return"
    }
    
    valueBox(paste0(avg, "%"), lbl, icon = icon("chart-line"), color = color)
  })
  
  output$worst_return <- renderValueBox({
    df <- display_data()
    worst <- if (!is.null(df) && nrow(df) > 0) round(min(df$day_return_pct, na.rm = TRUE), 2) else 0
    valueBox(paste0(worst, "%"), "Worst Perf", icon = icon("arrow-down"), color = "red")
  })
  
  output$losers_count <- renderValueBox({
    df <- stock_data()
    losers <- if (!is.null(df)) sum(df$day_return_pct < 0, na.rm = TRUE) else 0
    valueBox(losers, "Losers", icon = icon("thumbs-down"), color = "orange")
  })
  
  # ---- DATA TABLE ----
  output$metrics_table <- renderDT({
    df <- display_data()
    
    if (is.null(df) || nrow(df) == 0) {
      return(datatable(
        data.frame(Message = "No data loaded. Click 'Load Data'."),
        options = list(dom = 't'),
        rownames = FALSE
      ))
    }
    
    # Adjust column headers based on mode
    is_range <- (!is.null(attr(df, "mode")) && attr(df, "mode") == "range")
    col_open <- if (is_range) "Start Price" else "Open"
    col_close <- if (is_range) "End Price" else "Close"
    col_return <- if (is_range) "Period Return %" else "Day Return %"
    
    df_display <- df %>%
      mutate(
        day_return = day_return_pct,
        open = round(open, 2),
        close = round(close, 2),
        status = ifelse(day_return_pct < 0, "📉 DOWN", "📈 UP")
      ) %>%
      select(symbol, sector, open, close, day_return, status) # Removed volume for simplicity in range mode
    
    datatable(
      df_display,
      selection = 'single',
      rownames = FALSE,
      options = list(
        pageLength = 25, 
        scrollX = TRUE, 
        dom = 'frtip',
        order = list(list(4, 'asc'))
      ),
      colnames = c("Ticker", "Sector", col_open, col_close, col_return, "Status")
    ) %>%
      formatStyle(
        'day_return',
        backgroundColor = styleInterval(
          c(-5, -2, 0, 2, 5),
          c('#b71c1c', '#e53935', '#ffcdd2', '#c8e6c9', '#43a047', '#1b5e20')
        ),
        color = styleInterval(c(-1, 1), c('white', 'black', 'white')),
        fontWeight = 'bold'
      ) %>%
      formatCurrency('open', currency = "$", digits = 2) %>%
      formatCurrency('close', currency = "$", digits = 2)
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
    pct_return <- df$day_return_pct[idx]
    
    # Fetch wider context for chart
    d_start <- input$date_range_sel[1]
    d_end   <- input$date_range_sel[2]
    
    # If single day, show 30 day context. If range, show that range + buffer
    chart_start <- if (d_start == d_end) d_start - 30 else d_start - 5
    chart_end   <- d_end + 1
    
    chart_data <- tryCatch({
      tq_get(ticker, get = "stock.prices", from = chart_start, to = chart_end)
    }, error = function(e) NULL)
    
    if (is.null(chart_data) || nrow(chart_data) == 0) {
      return(plot_ly() %>% layout(title = paste("No data for", ticker)))
    }
    
    line_color <- if (pct_return < 0) '#e74c3c' else '#27ae60'
    
    plot_ly(data = chart_data, x = ~date, y = ~close,
            type = 'scatter', mode = 'lines',
            line = list(color = line_color, width = 2.5),
            hovertemplate = "<b>%{x}</b><br>Close: $%{y:.2f}<extra></extra>") %>%
      layout(
        title = list(text = paste0(ticker, " - Return: ", pct_return, "%"), font = list(size = 16)),
        xaxis = list(title = "Date", gridcolor = '#ecf0f1'),
        yaxis = list(title = "Price ($)", gridcolor = '#ecf0f1', tickprefix = "$"),
        hovermode = "x unified",
        shapes = if (d_start != d_end) list(
          # Highlight the selected range
          list(type = "rect",
               fillcolor = "blue", line = list(color = "blue"), opacity = 0.1,
               x0 = d_start, x1 = d_end, xref = "x",
               y0 = min(chart_data$low), y1 = max(chart_data$high), yref = "y")
        ) else list()
      )
  })
}

# ============================================================================
# RUN
# ============================================================================
shinyApp(ui, server)