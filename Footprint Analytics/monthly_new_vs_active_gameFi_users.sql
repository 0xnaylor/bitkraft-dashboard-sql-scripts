WITH new_users AS (
    SELECT str_to_date(concat(date_format(`protocol_active_address`.`on_date`, '%Y-%m'), '-01'), '%Y-%m-%d') AS month
        , COUNT(DISTINCT `protocol_active_address`.`wallet_address`) AS new_monthly_users
    FROM `protocol_active_address`
    WHERE `protocol_active_address`.`is_new_address`=true
        AND str_to_date(concat(date_format(`protocol_active_address`.`on_date`, '%Y-%m'), '-01'), '%Y-%m-%d') > '2021-12-31'
        AND str_to_date(concat(date_format(`protocol_active_address`.`on_date`, '%Y-%m'), '-01'), '%Y-%m-%d') < CONCAT(YEAR(now()), '-', MONTH(now()), '-1')
    GROUP BY 1
    ORDER BY 1 DESC
),

active_users AS (
    SELECT str_to_date(concat(date_format(`protocol_active_address`.`on_date`, '%Y-%m'), '-01'), '%Y-%m-%d') AS month
    , COUNT(DISTINCT `protocol_active_address`.`wallet_address`) AS unique_active_users
    FROM `protocol_active_address`
    WHERE str_to_date(concat(date_format(`protocol_active_address`.`on_date`, '%Y-%m'), '-01'), '%Y-%m-%d') > '2021-12-31'
        AND str_to_date(concat(date_format(`protocol_active_address`.`on_date`, '%Y-%m'), '-01'), '%Y-%m-%d') < CONCAT(YEAR(now()), '-', MONTH(now()), '-1')
    GROUP BY 1
    ORDER BY 1 DESC
)

SELECT new_users.month
    , new_users.new_monthly_users 
    , active_users.unique_active_users
    , ROUND((new_users.new_monthly_users / active_users.unique_active_users) * 100, 0) AS new_user_percentage
FROM new_users
JOIN active_users ON active_users.month = new_users.month
WHERE new_users.month = active_users.month
ORDER BY 1





