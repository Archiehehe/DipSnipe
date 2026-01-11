# DipSnipe
DipSnipe is an interactive Shiny dashboard designed to identify and analyze daily stock market losers. It helps investors quickly spot short-term dips across sectors, industries, and market-cap ranges. For dip-buying, mean-reversion, and risk-monitoring strategies.

🔗 Live App: https://archiehehe.shinyapps.io/DipSnipe/

🎯 What DipSnipe Does

DipSnipe answers one practical question:
“Which stocks sold off the most today, where did that weakness occur, and are there any mean-reversion opportunities?”

For a selected trading date, the app:
Loads a defined universe of equities
Applies market cap, sector, and industry filters
Ranks stocks from worst to best by daily return
Highlights stocks that closed down on the day
The focus is end-of-day screening, not prediction or automation.

✨ Core Features
📊 Daily Snapshot
At a glance, DipSnipe shows:
Total tickers analyzed
Average daily return
Worst performing stock
Number of losers
A fast read on overall market tone.

🎛️ Interactive Filters
Refine the universe with:
Trading date selector
Market capitalization range (in billions)
Sector filter
Industry filter
Losers-only toggle
All filters update instantly.

📉 Performance Leaderboard
The main table ranks stocks by daily performance and includes:
Ticker
Company Name (hyperlinked to Yahoo Finance)
Sector
Open & close prices
Daily return (%)
Direction (UP / DOWN)
Trading volume
Losses are visually emphasized, making real downside easy to spot.

🔍 Search & Sorting
Search for specific tickers
Sort by return, volume, or price
Scan large universes efficiently
Built for speed and clarity.

🧠 Intended Use
DipSnipe is designed for:
Daily dip-buying research
Identifying short-term market weakness
Sector and industry selloff analysis
Generating candidates for deeper manual research
Mean-Reversion opportunities
It is not a trading system or signal engine.

🧩 Design Philosophy
Straightforward EOD metrics that are easy to understand and verify.
Exploration First
Built for human judgment, not automated decisions.
Low Friction
Fast filtering, clean tables, zero distractions.

🛠️ Tech Stack
R
Shiny
tidyverse
DT
Financial market data APIs
Deployed via shinyapps.io

⚠️ Disclaimer
DipSnipe is provided for educational and informational purposes only.
It does not constitute financial or investment advice.
Always do your own research.

Not for commercial use. Read the License for more details.
DipSnipe is provided for educational and informational purposes only.
It does not constitute financial or investment advice.
Always do your own research.
