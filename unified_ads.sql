-- =============================================================
-- Multi-Channel Advertising Data — Unified Table
-- Author: [Your Name]
-- Date: January 2024
-- Description: Unifies Facebook, Google Ads and TikTok data
--              into a single table for cross-channel analysis.
--              Standardizes column names and computes CPA, CTR,
--              and CPC at the row level.
-- =============================================================


-- Step 1: Create source tables
-- (Run after uploading CSVs to Supabase)

-- facebook_ads source table
CREATE TABLE IF NOT EXISTS facebook_ads (
    date                    date,
    campaign_id             text,
    campaign_name           text,
    ad_set_id               text,
    ad_set_name             text,
    impressions             bigint,
    clicks                  bigint,
    spend                   numeric,
    conversions             bigint,
    video_views             bigint,
    engagement_rate         numeric,
    reach                   bigint,
    frequency               numeric
);

-- google_ads source table
CREATE TABLE IF NOT EXISTS google_ads (
    date                    date,
    campaign_id             text,
    campaign_name           text,
    ad_group_id             text,
    ad_group_name           text,
    impressions             bigint,
    clicks                  bigint,
    cost                    numeric,
    conversions             bigint,
    conversion_value        numeric,
    ctr                     numeric,
    avg_cpc                 numeric,
    quality_score           integer,
    search_impression_share numeric
);

-- tiktok_ads source table
CREATE TABLE IF NOT EXISTS tiktok_ads (
    date                    date,
    campaign_id             text,
    campaign_name           text,
    adgroup_id              text,
    adgroup_name            text,
    impressions             bigint,
    clicks                  bigint,
    cost                    numeric,
    conversions             bigint,
    video_views             bigint,
    video_watch_25          bigint,
    video_watch_50          bigint,
    video_watch_75          bigint,
    video_watch_100         bigint,
    likes                   bigint,
    shares                  bigint,
    comments                bigint
);


-- =============================================================
-- Step 2: Create unified table
-- Combines all three platforms into one standardized schema
-- =============================================================

CREATE TABLE unified_ads AS

SELECT
    date                                                          AS date,
    'Facebook'                                                    AS platform,
    campaign_id,
    campaign_name,
    ad_set_id                                                     AS ad_group_id,
    ad_set_name                                                   AS ad_group_name,
    impressions,
    clicks,
    spend                                                         AS spend_usd,
    conversions,
    video_views,
    ROUND(clicks::numeric / NULLIF(impressions, 0), 4)           AS ctr,
    ROUND(spend::numeric  / NULLIF(clicks, 0), 4)                AS cpc,
    ROUND(spend::numeric  / NULLIF(conversions, 0), 2)           AS cpa,
    NULL::numeric                                                 AS conversion_value,
    NULL::numeric                                                 AS quality_score,
    engagement_rate,
    reach,
    frequency,
    NULL::bigint                                                  AS likes,
    NULL::bigint                                                  AS shares,
    NULL::bigint                                                  AS comments,
    NULL::bigint                                                  AS video_watch_100
FROM facebook_ads

UNION ALL

SELECT
    date,
    'Google'                                                      AS platform,
    campaign_id,
    campaign_name,
    ad_group_id,
    ad_group_name,
    impressions,
    clicks,
    cost                                                          AS spend_usd,
    conversions,
    0                                                             AS video_views,
    ROUND(ctr::numeric, 4)                                        AS ctr,
    ROUND(avg_cpc::numeric, 4)                                    AS cpc,
    ROUND(cost::numeric / NULLIF(conversions, 0), 2)             AS cpa,
    conversion_value,
    quality_score,
    NULL::numeric                                                 AS engagement_rate,
    NULL::bigint                                                  AS reach,
    NULL::numeric                                                 AS frequency,
    NULL::bigint                                                  AS likes,
    NULL::bigint                                                  AS shares,
    NULL::bigint                                                  AS comments,
    NULL::bigint                                                  AS video_watch_100
FROM google_ads

UNION ALL

SELECT
    date,
    'TikTok'                                                      AS platform,
    campaign_id,
    campaign_name,
    adgroup_id                                                    AS ad_group_id,
    adgroup_name                                                  AS ad_group_name,
    impressions,
    clicks,
    cost                                                          AS spend_usd,
    conversions,
    video_views,
    ROUND(clicks::numeric / NULLIF(impressions, 0), 4)           AS ctr,
    ROUND(cost::numeric   / NULLIF(clicks, 0), 4)                AS cpc,
    ROUND(cost::numeric   / NULLIF(conversions, 0), 2)           AS cpa,
    NULL::numeric                                                 AS conversion_value,
    NULL::numeric                                                 AS quality_score,
    NULL::numeric                                                 AS engagement_rate,
    NULL::bigint                                                  AS reach,
    NULL::numeric                                                 AS frequency,
    likes,
    shares,
    comments,
    video_watch_100
FROM tiktok_ads;


-- =============================================================
-- Step 3: Verify the unified table
-- Expected: 110 rows per platform, 330 total
-- =============================================================

SELECT
    platform,
    COUNT(*)                                    AS total_rows,
    ROUND(SUM(spend_usd)::numeric, 2)           AS total_spend,
    SUM(conversions)                            AS total_conversions,
    ROUND(AVG(cpa)::numeric, 2)                 AS avg_cpa,
    ROUND(AVG(ctr)::numeric, 4)                 AS avg_ctr
FROM unified_ads
GROUP BY platform
ORDER BY total_spend DESC;
