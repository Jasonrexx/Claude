# Research system — niche scan, topic pick, story notes

Used at Stage 1b (niche scan), Stage 2 (topic pick) and Stage 3 (script
research). All of it is silent work: the user sees only the results
tables, never the process.

## Tools and honesty

**Method order (use the first that works, combine where useful):**

1. **Web first (default).** WebSearch and WebFetch across: Google Trends
   (rising queries), Reddit and niche forums (what people ask for, argue
   about, share), articles and roundups on growing YouTube channels and
   niches, "most viewed this week/month" lists, news coverage, and
   channel-stats sites. Cross-check across several sources; one forum
   post is a signal, not proof.
2. **YouTube Data API (when `YOUTUBE_API_KEY` is in `.env`).** Exact
   views, upload dates, channel sizes via `scripts/youtube_scan.py`. Not
   set up yet. Skip silently until the key exists.
3. **Chrome on youtube.com: fallback only,** and only to confirm exact
   numbers on the final few candidates, or when the web gives too little.
   It runs in the user's signed-in browser, so results can be personalized;
   say so if used. Never the primary method.

- **No YouTube API access by default.** Numbers come from public pages and
  are snapshots, shown as taken ("views", "age", "~views/day"). **Never
  invent or round up a metric.** If a number isn't available, write `n/a`.
  Call anything inferred an estimate.
- Don't sign in to anything, don't post, don't touch the user's accounts.
- Load deferred tools (WebSearch, WebFetch) via ToolSearch if needed.

## Metrics to pull for every YouTube example

| Field | How |
|---|---|
| Title, channel | from the result |
| Views and age | from the result; compute **views per day** = views ÷ days live |
| Channel size | subscribers if visible; a **small channel with big views is the strongest signal** (the idea works, not the brand) |
| Length | to match long-form vs short |
| Format | documentary, explainer, animated, shorts… |

## Stage 1b — Niche scan

Goal: find what niches are doing well right now, from documentary-style
(crime, finance, politics, history, tech, business, science, true
stories, geopolitics, health, mysteries…) to any other niche the data
surfaces. Don't limit to a fixed list.

1. Using the method order above, find current top performers across
   at least 8 niches: "this week" / "this month" sorting, plus articles on
   YouTube trends and faceless/animated-explainer channels that are growing.
2. For each niche collect 2–3 recent examples with the metrics above.
3. Score each niche on: **demand** (views/day of recent videos), **opportunity**
   (small channels breaking through, not only giants), **visual fit** (does
   it translate to paper-diorama cutouts, stat numbers, maps), **evergreen
   vs fading**.
4. Show the **8 best** in one table, then ask the user to pick one or type
   their own niche.

Table shape:

| # | Niche | Evidence (example, views, age) | Why it's working | Opportunity | Fits our style |
|---|---|---|---|---|---|

Keep each cell short. End with the question, nothing else.

## Stage 2 — Topic pick

If the user types their own topic: lock a one-line angle (a question with
a turn) and move on.

If the user says `pick for me` (or `find one`):

1. **Pull data inside the chosen niche** using the method order above:
   Google Trends rising queries, Reddit and forum chatter, recent
   high-view-velocity videos, news and articles from the last 1–2 weeks
   (2–3 reputable sources per candidate).
2. Build a longlist of ~10 candidates, drop tragedies/gossip and anything
   unverifiable, then show the **5 strongest** in a table:

| # | Topic (question with a turn) | Data that backs it | Key stat for a giant on-screen number | Sources |
|---|---|---|---|---|

3. Below the table, show **the best 2** with a short data-backed reason
   each: views/day of comparable videos, search or news momentum, how
   unsaturated it is, how well it visualizes. Name which one you'd pick
   first and why in one line.
4. STOP. The user picks any of the 5. Never build before they pick.

## Stage 3 — Script research (after the topic is locked)

- At least 2–3 reputable **current** sources; check every number, date
  and name against two; prefer stats that become giant on-screen numbers.
- Save `projects/<slug>/story-notes.md`: the angle, key facts with
  figures, source URLs, and (when relevant) the niche and trend evidence.
- Never invent a number or a quote. A vague true line beats a specific
  false one.
- **Crime and any real-person stories:** treat unproven allegations as
  allegations ("accused of", "alleged"), don't state guilt that a court
  hasn't established, don't name or show private individuals or victims,
  keep imagery non-graphic.
