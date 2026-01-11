import yfinance as yf

print("--- DIAGNOSTIC START ---")
# Fetch last 5 days of hourly data to see what dates come back
df = yf.Ticker("AAPL").history(period="5d", interval="1h")

if df.empty:
    print("ERROR: No data returned. Possible connection or API issue.")
else:
    print("SUCCESS! Found data for these dates:")
    print(df.index)
print("--- DIAGNOSTIC END ---")
