{{ config(
    materialized='table'
)}}

SELECT
  a.id AS account_id,
  a.created_at AS account_created_at,
  COUNT(DISTINCT
    CASE
      WHEN TIMESTAMP_DIFF(s.created_at, a.created_at, DAY) BETWEEN 0 AND 6 THEN s.id
  END
    ) AS week_1_status_count,
  COUNT(DISTINCT
    CASE
      WHEN TIMESTAMP_DIFF(fa.created_at, a.created_at, DAY) BETWEEN 0 AND 6 THEN fa.id
  END
    ) AS week_1_favorite_count,
  COUNT(DISTINCT
    CASE
      WHEN TIMESTAMP_DIFF(fo.created_at, a.created_at, DAY) BETWEEN 0 AND 6 THEN fo.id
  END
    ) AS week_1_follow_count,
  COUNT(DISTINCT
    CASE
      WHEN TIMESTAMP_DIFF(s.created_at, a.created_at, DAY) BETWEEN 7 AND 13 THEN s.id
  END
    ) AS week_2_status_count,
  COUNT(DISTINCT
    CASE
      WHEN TIMESTAMP_DIFF(fa.created_at, a.created_at, DAY) BETWEEN 7 AND 13 THEN fa.id
  END
    ) AS week_2_favorite_count,
  COUNT(DISTINCT
    CASE
      WHEN TIMESTAMP_DIFF(fo.created_at, a.created_at, DAY) BETWEEN 7 AND 13 THEN fo.id
  END
    ) AS week_2_follow_count
  --start with accounts
FROM
  `moz-fx-moztodon-prod.public.accounts` AS a
  --join against statuses (posts)
LEFT JOIN
  `moz-fx-moztodon-prod.public.statuses` AS s
ON
  a.id = s.account_id
  --first two weeks since account creation
  AND TIMESTAMP_DIFF(s.created_at, a.created_at, DAY) BETWEEN 0
  AND 13
  --join against favoriting (liking) a post
LEFT JOIN
  `moz-fx-moztodon-prod.public.favourites` AS fa
ON
  a.id = fa.account_id
  --first two weeks since account creation
  AND TIMESTAMP_DIFF(fa.created_at, a.created_at, DAY) BETWEEN 0
  AND 13
  --join against following an account
LEFT JOIN
  `moz-fx-moztodon-prod.public.follows` AS fo
ON
  a.id = fo.account_id
  --first two weeks since account creation
  AND TIMESTAMP_DIFF(fo.created_at, a.created_at, DAY) BETWEEN 0
  AND 13
  --null domain corresponds to mozilla.social accounts
WHERE
  a.domain IS NULL
  --there are also NULL and Application values for the actor_type field
  --excluding them for now
  AND (a.actor_type = 'Person' OR a.actor_type IS NULL)
GROUP BY
  1,
  2;