TRI-JOSKERS online starter (GitHub Pages + Supabase)

This project hosts the web interface on GitHub Pages and stores shared records in Supabase. GitHub Pages alone cannot provide shared database/auth. Internet is required. All members sign in to the same Supabase project; realtime subscriptions refresh data on other devices.

SETUP
1. Create a Supabase project.
2. Open SQL Editor, run schema.sql.
3. In Authentication settings, configure email sign-up/confirmation as you prefer.
4. Create an account from the app after deployment. In Supabase > Authentication > Users, copy its UUID. Run in SQL Editor: insert into public.members(user_id,role) values ('UUID','admin');
5. Repeat signup for the other three members and add each user's UUID into public.members with role 'cashier'. Only listed active users can read/write school records.
6. In Project Settings > API, copy Project URL and anon/public key. Put both into config.js. Never use the service_role/secret key in browser files.
7. Create a GitHub repository. Upload index.html, config.js, and schema.sql (README optional). On GitHub, Settings > Pages > deploy from branch, select main and /(root). Open the resulting Pages URL.
8. Use HTTPS. Test with two separate devices and users before relying on records. Take regular JSON backups through Setup / export.

NOTES / MVP
- Database rows and live sync are online; users need internet.
- The first account has no access until you add it to public.members. This is intentional, so the public website cannot expose school records.
- Both roles currently can edit finance records. Role-specific read-only restrictions are not yet enforced in UI/SQL; only trusted people should be authorized. Do not store especially sensitive student information until access policies are reviewed.
- This starter offers transaction entry, dashboard totals, transaction history/search/month filter, CSV export, outstanding dues, opening balance, print, JSON backup and restore (restore adds records).
- GitHub Pages publishes static files and does not hide config.js; Supabase anon key is designed for browser use and security depends on RLS. Never publish a service role secret.
