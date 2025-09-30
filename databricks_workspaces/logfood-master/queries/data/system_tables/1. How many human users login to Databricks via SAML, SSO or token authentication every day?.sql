%sql
SELECT
  COUNT(event_date) as num_of_logins,
  event_date
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
  event_date
ORDER BY
  event_date DESC
LIMIT 20