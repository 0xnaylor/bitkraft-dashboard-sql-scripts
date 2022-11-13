SELECT `gamefi_protocol_daily_stats`.`chain` AS `chain`
    , date(`gamefi_protocol_daily_stats`.`on_date`) AS `date`
    , sum(`gamefi_protocol_daily_stats`.`number_of_active_users`) AS `active users`
FROM (
    SELECT `gamefi_protocol_daily_stats`.`chain` AS `chain`
        , sum(`gamefi_protocol_daily_stats`.`number_of_active_users`) AS `sum` 
    FROM `gamefi_protocol_daily_stats`
    WHERE (`gamefi_protocol_daily_stats`.`on_date` >= convert_tz('2022-07-31 00:00:00.000', 'GMT', @@session.time_zone)
        AND `gamefi_protocol_daily_stats`.`on_date` < convert_tz('2022-08-01 00:00:00.000', 'GMT', @@session.time_zone)
        )
    GROUP BY `chain`
    ORDER BY `sum` DESC, `chain` ASC
    LIMIT 7
    ) `source` 
INNER JOIN `gamefi_protocol_daily_stats` `gamefi_protocol_daily_stats` ON `source`.`chain` = `gamefi_protocol_daily_stats`.`chain` 
WHERE (`gamefi_protocol_daily_stats`.`on_date` >= convert_tz('2022-01-01 00:00:00.000', 'GMT', @@session.time_zone) 
    AND `gamefi_protocol_daily_stats`.`on_date` < convert_tz('2022-08-01 00:00:00.000', 'GMT', @@session.time_zone)) 
GROUP BY `gamefi_protocol_daily_stats`.`chain`, date(`gamefi_protocol_daily_stats`.`on_date`) 
ORDER BY 
    `active users` DESC
    , `chain` ASC
    , date(`date`) ASC