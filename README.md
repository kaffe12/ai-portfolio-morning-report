# Morgenrapport

A Claude Code agent that writes a short daily report on my investment portfolio. Every weekday morning it fetches prices and exchange rates, finds the news that matters for each holding, scores the headlines with TextBlob, and then judges each piece of news against the investment thesis I wrote down when I bought the position. The result is a report I can read in about two minutes, saved as `rapporter/YYYY-MM-DD.md`.

The reports and the project instructions are in Norwegian. The point is not to react to price movements but to ask one question every day: does today's news strengthen or weaken the reason I own this?

## Architecture

| Piece | Role |
|---|---|
| `CLAUDE.md` | Context. Tells the agent who it works for, which files exist, which data sources to use, and the ground rules (judge the thesis, not the price; say so when data is missing instead of guessing). |
| `.claude/skills/morgenrapport/SKILL.md` | The recipe. The `/morgenrapport` skill lists the steps, the report format and the word limit. |
| `portfolio.json` | The holdings: purchase price, investment thesis, known risks, and the conditions under which the thesis breaks (`tesen_brytes_hvis`). Not committed; see `portfolio.example.json`. |
| Alpha Vantage MCP | Closing prices and the USD/NOK rate. |
| Web search | News about each holding since the previous report. |
| TextBlob | A naive sentiment polarity score (-1 to +1) for every headline, used as a baseline. |
| `funn.md` | A log of headlines where the agent disagrees with TextBlob, with a one-line reason. |
| `run.sh` + launchd | Runs `claude -p "/morgenrapport"` headless every weekday at 07:30 and appends output to `logs/`. |

The flow for one run:

1. Read `portfolio.json` and the previous report.
2. Fetch prices and USD/NOK from Alpha Vantage. Index funds without a ticker use `proxy_ticker`, an ETF tracking a similar index.
3. Compute value in NOK, daily change and total gain or loss.
4. Search the web for news since the last report.
5. Run TextBlob on each headline, then evaluate the news in a financial context against the thesis, the known risks and the break conditions.
6. Write the report. Anything that hits a `tesen_brytes_hvis` condition is flagged at the very top.
7. Log any disagreement with TextBlob in `funn.md`.

## Setup

### Requirements

- macOS (launchd is used for scheduling)
- [Claude Code](https://docs.claude.com/en/docs/claude-code)
- [uv](https://docs.astral.sh/uv/) (for `uvx`)
- Python with TextBlob: `pip install textblob && python -m textblob.download_corpora`
- A free [Alpha Vantage API key](https://www.alphavantage.co/support/#api-key)

### 1. Portfolio

```sh
cp portfolio.example.json portfolio.json
```

Fill in your own positions. The most important fields are `investeringstese`, `kjente_risikoer` and `tesen_brytes_hvis`: the agent's analysis is only as good as the thesis you write. `portfolio.json` is in `.gitignore`.

### 2. Alpha Vantage MCP

Add the server to Claude Code, scoped to this project:

```sh
claude mcp add alphavantage -- uvx --from marketdata-mcp-server --with "mcp<2" marketdata-mcp YOUR_API_KEY
```

This differs from the command in Alpha Vantage's documentation, which fails in two ways:

1. **Renamed executable.** The documented `uvx marketdata-mcp-server` fails because the package's executable has been renamed to `marketdata-mcp`. Since the package name and the executable name no longer match, uvx needs `--from marketdata-mcp-server` to know which package to install, followed by `marketdata-mcp` as the command to run.
2. **Incompatible MCP library.** With the right name, the server starts and then crashes with `AttributeError: 'Server' object has no attribute 'list_tools'`. The package is written for an older version of the `mcp` Python library, and that API is not available in the version uvx installs by default. Pinning the library below version 2 with `--with "mcp<2"` solved it.

Check that it is connected with `claude mcp list`, or `/mcp` inside a session.

### 3. Try it manually

```sh
claude
> /morgenrapport
```

The report is saved to `rapporter/` and the agent answers with a one-line summary.

### 4. Daily run with launchd

`run.sh` sets `PATH` (launchd starts with a minimal environment, so `claude`, `uvx` and `python` must be findable), changes to the project directory and runs the skill headless with an explicit tool allowlist:

```sh
claude -p "/morgenrapport" \
  --allowedTools "mcp__alphavantage" "WebSearch" "WebFetch" "Bash" "Read" "Write" "Edit"
```

Edit the path in `run.sh` to match where you cloned the project, make it executable, and create a LaunchAgent at `~/Library/LaunchAgents/<your.label>.morgenrapport.plist` with `ProgramArguments` pointing at `run.sh` and a `StartCalendarInterval` entry per weekday (`Weekday` 1 to 5, `Hour` 7, `Minute` 30). Then load it:

```sh
launchctl load ~/Library/LaunchAgents/<your.label>.morgenrapport.plist
```

If the Mac is asleep at 07:30, launchd runs the job when it wakes. Output goes to `logs/morgenrapport.log`.

## Lessons learned

### Alpha Vantage's news endpoint requires premium

The plan was to use Alpha Vantage for both prices and news, since it has a `NEWS_SENTIMENT` endpoint that even returns its own sentiment scores. On a free key that endpoint is premium only. Prices and exchange rates work fine, so the agent uses Alpha Vantage for market data and web search for news, and `CLAUDE.md` explicitly tells it not to call the news endpoint.

### Why the agent replaces TextBlob as the sentiment judgement

TextBlob is a general purpose, lexicon based sentiment tool. It scores words in isolation and knows nothing about finance. It is kept in the pipeline as a baseline, but the agent makes the actual call, and every disagreement is logged in `funn.md`. The first day produced four:

| Headline | TextBlob | Agent | Why |
|---|---|---|---|
| Oracle stock falls on more debt to fund AI chip buying, OpenAI revenue disclosure | **+0.50** | negative | TextBlob reads "more" as positive and ignores both "falls" and the fact that more debt is bad news. |
| Oracle and Tesla Stocks Are Rising Today. What's Driving the Rally (Oct. 9)? | 0.00 | positive | Financial words like "rising" and "rally" are not in TextBlob's lexicon. |
| Oracle (NYSE:ORCL) Shares Up 1.6% | 0.00 | positive | "Up" about a share price is not read as positive. |
| Stock Market Outlook: OpenAI Relief Meets a Split Rally | 0.00 | slightly positive | "Relief" and "rally" register nothing, even though they signal improving sentiment. |

The Oracle debt headline is the clearest case: a story about a falling stock and rising leverage gets one of the most positive scores of the day. The other three show the opposite failure, where clearly positive market language scores a flat zero. A sentiment score that is wrong in both directions is not something to act on, so the report shows TextBlob's number for transparency and relies on the agent's reading of the news against the thesis.

## Privacy

`portfolio.json`, `rapporter/`, `logs/` and `.env` are git-ignored. No amounts, holdings or API keys are committed; the API key lives only in the local Claude Code MCP configuration.
