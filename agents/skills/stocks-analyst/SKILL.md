---
name: stocks-analyst
description: DCF-based equity analysis across US, EU, and Asian markets with entry point recommendations
always: false
---

# Stocks Analyst Skill

## Purpose
Perform a rapid DCF-based screening across major equity markets, identify stocks near attractive entry points, and post a formatted report to the Discord #stocks channel.

## Execution Steps

### 1. Universe Selection
Cover representative indices across three regions:
- **US**: S&P 500 large caps — focus on FAANG+, Energy, Financials (AAPL, MSFT, NVDA, GOOGL, META, JPM, XOM, CVX, BRK-B, JNJ)
- **EU**: STOXX 600 names — (ASML, SAP, NESN, NOVO-B, MC, SIE, AZN, HSBA, BP, TTE)
- **Asia**: Nikkei 225 + Hang Seng + ASX 200 representatives — (7203.T, 9984.T, 005930.KS, 700.HK, BABA, 000660.KS, BHP, RIO, 2330.TW, 9988.HK)

### 2. Data Fetching
Use `web_search` and `web_fetch` to retrieve for each stock:
- Current price and 52-week range
- Forward P/E and trailing P/E
- EPS (TTM) and 5-year EPS growth rate
- Free Cash Flow yield (P/FCF)
- Revenue growth (YoY)
- Analyst consensus price target

Reliable free sources:
- Yahoo Finance: `https://finance.yahoo.com/quote/{TICKER}`
- Macrotrends: `https://www.macrotrends.net/stocks/charts/{TICKER}/{NAME}/free-cash-flow`
- Simply Wall St public pages, Finviz (for US tickers)

### 3. Simplified DCF Scoring
For each stock calculate a **DCF Score (0-10)**:

```
growth_score    = min(eps_growth_5y / 15, 1.0) * 3   # normalise vs 15% benchmark
value_score     = min(10 / forward_pe, 1.0) * 3       # lower P/E = better
fcf_score       = min(fcf_yield / 0.05, 1.0) * 2      # normalise vs 5% FCF yield
upside_score    = max(0, (analyst_target - price) / price) / 0.2 * 2  # vs 20% upside
dcf_score       = growth_score + value_score + fcf_score + upside_score
```

**Entry signal thresholds:**
- Score ≥ 8.0 → 🟢 **Strong Buy** — near attractive entry
- Score 6.0–7.9 → 🟡 **Accumulate** — reasonable valuation
- Score < 6.0 → 🔴 **Avoid / Wait** — overvalued or weak fundamentals

### 4. Output Format

Post the following structured report to Discord. Keep it under 1800 characters per message; split if needed.

```
📊 **Blitz Market Scan — {DATE} {TIME} UTC**

🇺🇸 **US Markets**
| Ticker | Price | Score | Signal |
|--------|-------|-------|--------|
| NVDA   | $XXX  | 8.4   | 🟢 Strong Buy |
...

🇪🇺 **EU Markets**
...

🌏 **Asia Markets**
...

💡 **Top 3 Entry Points This Cycle**
1. **{TICKER}** — {reason in one sentence}
2. ...
3. ...

⚠️ *Automated DCF screen — not financial advice. Always DYOR.*
```

### 5. Delivery
Use the `message` tool to post to `channel=discord` with `to={STOCKS_CHANNEL_ID}`.

## Notes
- If a ticker returns no data, skip it and log it as "data unavailable".
- Limit total web fetches to 15 to stay within tool iteration limits.
- Run the full analysis even if some tickers fail — partial results are better than none.
