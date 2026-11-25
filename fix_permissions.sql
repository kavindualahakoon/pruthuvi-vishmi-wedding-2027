-- Grant permissions to Supabase standard roles (anon, authenticated, service_role)
GRANT USAGE ON SCHEMA public TO anon, authenticated, service_role;
GRANT ALL ON ALL TABLES IN SCHEMA public TO anon, authenticated, service_role;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated, service_role;
GRANT ALL ON ALL ROUTINES IN SCHEMA public TO anon, authenticated, service_role;

-- Ensure future tables also inherit these permissions automatically
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO anon, authenticated, service_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO anon, authenticated, service_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON ROUTINES TO anon, authenticated, service_role;

-- Enable Row Level Security (RLS) on public.photo
ALTER TABLE public.photo ENABLE ROW LEVEL SECURITY;

-- Clean existing policies on photo to prevent duplicates
DROP POLICY IF EXISTS "Public read approved photos" ON public.photo;
DROP POLICY IF EXISTS "Public insert photos" ON public.photo;
DROP POLICY IF EXISTS "Admin full access photo" ON public.photo;
DROP POLICY IF EXISTS "Allow all for service_role" ON public.photo;
DROP POLICY IF EXISTS "Allow all for anon" ON public.photo;

-- Policies:
-- 1. Anyone (including wedding guests) can view approved photos
CREATE POLICY "Public read approved photos" ON public.photo
    FOR SELECT USING (approved = true);

-- 2. Anyone (including wedding guests) can upload / insert photos
CREATE POLICY "Public insert photos" ON public.photo
    FOR INSERT WITH CHECK (true);

-- 3. Service Role & Authenticated Admins have full access (approve, delete, edit)
CREATE POLICY "Admin full access photo" ON public.photo
    FOR ALL USING (auth.role() = 'service_role' OR auth.role() = 'authenticated');
