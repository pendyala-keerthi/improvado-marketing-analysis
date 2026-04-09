# Multi-Channel Marketing Analytics

## Overview
Unified advertising data from Facebook, Google Ads and TikTok 
into a single PostgreSQL table for cross-channel analysis.

## Database
- Platform: PostgreSQL (Supabase)
- Tables: facebook_ads, google_ads, tiktok_ads, unified_ads
- Total rows: 330 (110 per platform)

## unified_ads table
Created using UNION ALL across all three source tables.
Standardizes column names and computes CPA, CTR and CPC 
at the row level.

## Dashboard
Built in Looker Studio connected live to the PostgreSQL database.
[https://lookerstudio.google.com/reporting/a6934d98-fda4-4b1e-94d0-a6a1fc9fa8f9]

## Video
[https://www.loom.com/share/72c22fa81cfe4a958e6b064d6b602a33]
