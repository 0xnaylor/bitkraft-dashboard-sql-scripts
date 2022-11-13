WITH all_time AS (
    SELECT 
          "nft_transactions"."block_date" AS "date"
        ,  CASE WHEN "footprint"."nft_transactions"."value" >= 0 THEN "footprint"."nft_transactions"."value" ELSE 0 END AS "txn-value"
        , "footprint"."nft_transactions"."platform_fees_value" AS "platform_fees_value"
        , "footprint"."nft_transactions"."marketplace_slug" AS "marketplace_slug"
        , "footprint"."nft_transactions"."chain" AS "chain"
    FROM 
        "footprint"."nft_transactions"
),
ytd_volume AS (
    SELECT 
          sum("all_time"."txn-value") AS "ytd-vol"
        , "all_time"."marketplace_slug" AS "marketplace"
        , "all_time"."chain"
    FROM all_time
    WHERE "all_time"."date" >= date_add('day', - day_of_year(now()), now())
    GROUP BY 
          "all_time"."marketplace_slug"
        , "all_time"."chain"
),
weekly_txns AS (
    SELECT 
          at."marketplace_slug" AS "marketplace_slug"
        , at."chain" AS "chain"
        , count(*) FILTER (WHERE at."date" >= date_add('day', -8, now())) AS "weekly_txn_count"
        , count(*) FILTER (WHERE at."date" < date_add('day', -8, now()) AND at."date" >= date_add('day', -15, now())) AS "prior_week_txn_count"
        , sum(at."txn-value") FILTER (WHERE at."date" >= date_add('day', -8, now())) AS "weekly_txn_vol"
        , sum(at."txn-value") FILTER (WHERE at."date" < date_add('day', -8, now()) AND at."date" >= date_add('day', -15, now())) AS "prior_weekly_txn_vol"
        , avg(at."txn-value") FILTER (WHERE at."date" >= date_add('day', -8, now())) AS "weekly_avg_value"
        , avg(at."txn-value") FILTER (WHERE at."date" < date_add('day', -8, now()) AND at."date" >= date_add('day', -15, now())) AS "prior_week_avg_val"
    FROM all_time at
    GROUP BY 
          at."marketplace_slug"
        , at."chain"
    ORDER BY 
          at."marketplace_slug" ASC
        , at."chain" ASC
)

SELECT 
      at."marketplace_slug" AS "marketplace_slug"
    , at."chain" AS "chain"
    , cast(ytdv."ytd-vol" AS bigint) AS "ytd_vol"
    , cast(sum(at."txn-value") AS bigint) AS "all-time-vol"
    , cast(wt.weekly_txn_vol AS bigint) AS "weekly_txn_vol"
    , ((cast(wt.weekly_txn_vol AS double) - cast(wt.prior_weekly_txn_vol AS double)) / cast(wt.weekly_txn_vol AS double)) * 100 AS "txn_vol_wow_change"
    , wt.weekly_txn_count AS "weekly_txn_count"
    , ((cast(wt.weekly_txn_count AS double) - cast(wt.prior_week_txn_count AS double)) / cast(wt.weekly_txn_count AS double)) * 100 AS "txn_cont_wow_change"
    , wt.weekly_avg_value AS "weekly_avg_value"
    , ((cast(wt.weekly_avg_value AS double) - cast(wt.prior_week_avg_val AS double)) / cast(wt.weekly_avg_value AS double)) * 100 AS "txn_avg_wow_change"
    , cast(sum(at."platform_fees_value") AS bigint) AS "platform_fees"
FROM all_time at
JOIN weekly_txns wt ON wt.marketplace_slug = at.marketplace_slug AND wt.chain = at.chain
JOIN ytd_volume ytdv ON ytdv.marketplace = at.marketplace_slug AND ytdv.chain = at.chain
GROUP BY 
      at."marketplace_slug"
    , at."chain"
    , wt.weekly_txn_count
    , wt.prior_week_txn_count
    , ytdv."ytd-vol"
    , wt.weekly_txn_vol
    , wt.prior_weekly_txn_vol
    , wt.weekly_avg_value
    , wt.prior_week_avg_val
ORDER BY 
     "all-time-vol" DESC
    , at."marketplace_slug" ASC
    , at."chain" ASC