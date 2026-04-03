# AI in Marketing: 5 Bullet Friday — Generation Prompt

Generate this week's issue of AI in Marketing: 5 Bullet Friday and deploy it.

## STEP 1: Setup

Read these repo files:
- `config/topics.md` (research topics + editor profile + tone guidance)
- `config/audience.md` (audience context)
- `assets/style.css` (CSS class reference — DO NOT modify)

Run: `date '+%Y-%m-%d'` to get today's date. Save as $TODAY.
Calculate the cutoff date (14 days ago): `date -d '14 days ago' '+%Y-%m-%d'`. Save as $CUTOFF.

## STEP 2: Research (3 parallel sub-agents)

Spawn 3 agents **in parallel in a single message** (all foreground). Each uses WebSearch for news, articles, videos, and posts. Each must return AT LEAST 5 items. **CRITICAL:** Each item MUST include the publication date.

Each item includes: headline, publication date (YYYY-MM-DD), 2-3 sentence summary, source name, source URL, content type (article/video/post), and a relevance note for B2B marketing leaders.

Tell each agent: "Only include items published after $CUTOFF. If you cannot determine the publication date, note it as 'date unknown' — do NOT guess. **Use 6-8 WebSearch calls max. Do NOT use WebFetch to verify dates — just report what search results show. For your top 3 items, confirm the source URL is a real page via WebFetch and note the publication date shown on the page.**"

**Agent 1 — Market Moves:** AI product launches, acquisitions, partnerships, funding signaling where marketing platforms are heading. Covers: Adobe, Salesforce, Google, Meta, HubSpot, plus emerging players. Also: WPP, Omnicom, Publicis, Dentsu — agency holdco AI strategies. Search: "AI marketing platform launch [year]", "martech acquisition [year]", "agency holding company AI strategy [year]", "Salesforce Adobe marketing AI [year]"

**Agent 2 — Strategy & Practice:** CMO interviews, B2B case studies, marketing org restructuring around AI, new GTM models, ROI data, analyst takes (Forrester, Gartner, McKinsey). Also: regulatory/privacy moves affecting targeting or personalization. Search: "CMO AI strategy interview [year]", "B2B marketing AI case study [year]", "marketing org AI restructure [year]", "Forrester Gartner marketing AI [year]"

**Agent 3 — Edge & Contrarian:** The thing nobody's talking about yet. Experimental use cases, academic research hitting practice, open-source tools disrupting paid stacks, non-obvious second-order effects. Search: "AI marketing experiment results [year]", "open source marketing AI tool [year]", "AI second-order effects marketing [year]", "marketing AI research paper [year]"

## STEP 3: Curate & Write

From the combined sub-agent results (15+ items), select the top 5 using these filters:

- **Freshness gate:** DISCARD any item with a publication date before $CUTOFF or marked 'date unknown.' This is a hard filter — no exceptions.
- **Monday regret test:** Would a CMO regret not knowing this by Monday?
- **Decision impact:** Does this move the needle on budget allocation, vendor selection, org design, or channel strategy in the next 6-12 months?
- **Non-obvious implication:** The headline is table stakes. The "so what" is the value.

Write the newsletter content following the editor profile in `config/topics.md`. Key rules:

- You are a peer marketing leader, not a technologist. Think campaigns, pipeline, brand equity, team capacity, budget — not architectures or model benchmarks.
- Use "we" and "our" naturally.
- Each bullet item has: **bold headline (8 words or fewer) LINKED to the source article**, then NO MORE THAN 3 very succinct sub-bullets underneath. Each sub-bullet is one short sentence — punchy, direct, no filler. Think tweet-length per sub-bullet. The last sub-bullet MUST be the strategic "so what" — what this means for how you plan, staff, budget, or buy.
- Write a one-line theme intro framing the week.
- No hype words. No vendor cheerleading. No hedging. Take a position.
- When a technical concept matters, explain it like you'd explain it to your CMO in a hallway conversation.
- Source name as small attribution below the sub-bullets.
- **Tone:** Write like you're explaining this to a smart colleague who isn't in marketing. Use "you" and "your" — talk to the reader, not about abstract "organizations." Prefer concrete examples over category labels ("did it help close deals?" not "pipeline influence"). If a sentence sounds weird said out loud to a coworker, rewrite it. No consultant-speak, no abstract nouns doing the work of verbs.

## STEP 4: Editorial Review

Before generating HTML, review all 5 bullets:

1. **Date verification:** For EACH selected item, use WebFetch on the source URL and look for the publication date in the page content. If the article is older than 14 days from today, REPLACE it with the next best item. This is the most important check.
2. **Source verification:** Confirm each source URL is real via WebFetch. Drop any item where the source 404s or content doesn't match the headline.
3. **Claim accuracy:** Cross-reference key claims (funding amounts, product details, statistics) against the source.
4. **Tone calibration:** Re-read all 5 as a set. Read each sub-bullet out loud. If any sounds like a consulting deck or a press release — or uses words like "leverage," "utilize," "optimize for," "organizations," "scoring mechanism," or "CFO-ready narratives" — rewrite it in plain English. The Dir of Internal Comms is in the audience.
5. **Diversity check:** Ensure 5 bullets aren't all from the same category. If 3+ are about the same topic, replace the weakest.
6. **"So what" strength:** Each item's final sub-bullet must contain a specific strategic implication.
7. **Brevity check:** If any sub-bullet is longer than ~20 words, tighten it.

Run all 5 WebFetch calls in parallel.

## STEP 5: Generate HTML

Write a single file `content.html` — an HTML fragment (no `<html>`/`<head>`/`<body>` tags). Use CSS classes from `style.css`:

```html
<!-- Header -->
<div class="newsletter-header">
  <div class="newsletter-header-inner">
    <div>
      <div class="newsletter-title">AI in Marketing</div>
      <div class="newsletter-subtitle">5 Bullet Friday</div>
    </div>
    <div class="newsletter-date">DATE_DISPLAY</div>
  </div>
</div>

<!-- Theme -->
<div class="newsletter-theme"><p>THEME_LINE</p></div>

<!-- Bullets 1-5 -->
<div class="bullet-card">
  <div class="bullet-inner">
    <div class="bullet-number">1</div>
    <div class="bullet-content">
      <div class="bullet-headline"><a href="SOURCE_URL">HEADLINE</a></div>
      <ul class="bullet-analysis">
        <li>First point — what happened</li>
        <li>Second point — key detail or context</li>
        <li>Third point — the strategic so-what</li>
      </ul>
      <div class="bullet-source">
        <img src="https://www.google.com/s2/favicons?domain=DOMAIN&sz=32" alt="">
        SOURCE_NAME
      </div>
    </div>
  </div>
</div>
<!-- repeat for bullets 2-5 -->
```

`content.html` MUST be under 8KB.

## STEP 6: Build & Deploy

```bash
export GITHUB_PAT="<pat>"
DATE=$(date '+%Y-%m-%d')
bash build.sh "$DATE"
bash deploy.sh "$DATE"
```

Do NOT use `git push`. `deploy.sh` uses the GitHub Contents API with the PAT.

## STEP 7: Notify

Both notifications are non-blocking — if either fails, continue.

**Pushcut:**
```bash
DATE=$(date '+%Y-%m-%d')
curl -s -X POST "https://api.pushcut.io/<key>/notifications/Daily%20Brief" \
  -H "Content-Type: application/json" \
  -d "{\"title\":\"5 Bullet Friday\",\"text\":\"AI in Marketing — $(date '+%B %e, %Y')\",\"url\":\"https://derekpetrie.github.io/friday-five/$DATE.html\"}" || true
```

**Email via Resend (full newsletter inline):**
```bash
DATE=$(date '+%Y-%m-%d')
DATE_DISPLAY=$(date '+%B %e, %Y')
BRIEF_URL="https://derekpetrie.github.io/friday-five/$DATE.html"

EMAIL_HTML=$(python3 email-template.py "$DATE.html" "$BRIEF_URL")

curl -s -X POST "https://api.resend.com/emails" \
  -H "Authorization: Bearer <resend-key>" \
  -H "Content-Type: application/json" \
  -d "{\"from\":\"AI in Marketing <onboarding@resend.dev>\",\"to\":[\"dkpetrie@gmail.com\"],\"subject\":\"AI in Marketing: 5 Bullet Friday — $DATE_DISPLAY\",\"html\":$EMAIL_HTML}" || true
```

## RULES

- `content.html` MUST be under 8KB
- NEVER use `git push` — `deploy.sh` uses the GitHub API
- If a sub-agent fails, proceed with available results
- MAX 3 sub-bullets per item, each ~20 words or fewer
- Minimum 15 items researched, exactly 5 published
- HARD RULE: No articles older than 14 days. Verify dates via WebFetch.
- Every item's final sub-bullet must land on a practical implication for marketing practitioners
- Headlines are clickable links to the source article
