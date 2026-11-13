# VESPERA v2 — Daily Quest System

A responsive Arabic RTL RPG-style task planner with a full Liquid Glass interface, preset study/home tasks, XP, weekly ranks, player accounts, and an admin dashboard.

## Included files
- `index.html` — player dashboard and daily task system.
- `admin.html` — protected admin console (Supabase authentication + admin role).
- `config.example.js` — configuration template. Copy to `config.js`.
- `supabase-schema.sql` — database tables, trigger, and Row Level Security policies.
- `.gitignore` — excludes your private `config.js` from Git.

## Preset daily tasks
Room/study desk organization, Biology, Chemistry, Physics, English, French, German, Mathematics, Arabic, Religious Education, and Housework. You can also add custom tasks.

## Set up secure accounts and admin
1. Create a Supabase project.
2. In Supabase SQL Editor, run the complete contents of `supabase-schema.sql`.
3. Copy `config.example.js` to a new file named `config.js`.
4. In `config.js`, add your Supabase Project URL and the `anon` / publishable public key. Never use the `service_role` secret in browser files.
5. Upload `index.html`, `admin.html`, `config.js`, and the other project files to the root of your GitHub repository. Keep `config.js` private if you prefer; it is ignored by Git by default, so upload it manually only if you accept that the public anon key is visible. Supabase anon keys are designed for client use; security comes from RLS policies.
6. Open the deployed site, create your player account, and verify the profile was created.
7. In Supabase SQL Editor, grant your account admin access by running (replace the email):
   `update public.profiles set role = 'admin' where email = 'YOUR-EMAIL@example.com';`
8. Open `https://USERNAME.github.io/REPOSITORY/admin.html` and sign in with that account.

## GitHub Pages
In repository Settings → Pages, choose Deploy from a branch, branch `main`, folder `/(root)`.

## Important
- This project is a static frontend plus Supabase as the backend. Admin access is checked against the database role and protected by Row Level Security.
- Do not publish a Supabase service-role key or database password.
- User task data is cloud-synced after sign-in. Without `config.js` / Supabase setup, the player page works in local browser-only mode and admin login is unavailable.
- If Supabase email confirmation is enabled, confirm the account email before signing in.
