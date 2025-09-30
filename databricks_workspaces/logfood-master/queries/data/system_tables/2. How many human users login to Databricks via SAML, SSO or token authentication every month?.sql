%sql
SELECT
  COUNT(*) as num_of_logins,
  DATE_FORMAT(event_date, 'yyyy-MM') AS year_month
FROM
  system.access.audit
WHERE
  action_name IN (
    'samlLogin',
    'oidcBrowserLogin',
    'tokenLogin'
  ) AND
  REGEXP_LIKE(user_identity.email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
--   -- AND user_type = 'human'
GROUP BY
  year_month
ORDER BY
  year_month DESC
LIMIT 20
