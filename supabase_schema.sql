-- ==============================================================================
-- Migration SQL for Supabase (PostgreSQL)
-- Project: pruthuvi-vishmi-wedding (sjstytlplzkqitxivhfk)
-- Run this in Supabase SQL Editor:
-- https://supabase.com/dashboard/project/sjstytlplzkqitxivhfk/sql/new
-- ==============================================================================

-- 1. Create 'content' table (website editable text & sections)
CREATE TABLE IF NOT EXISTS public.content (
    id TEXT PRIMARY KEY,
    data TEXT NOT NULL,
    "updatedAt" TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 2. Create 'photo' table (photo gallery & moments uploads)
CREATE TABLE IF NOT EXISTS public.photo (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
    url TEXT NOT NULL,
    "originalName" TEXT NOT NULL,
    "uploaderName" TEXT NOT NULL,
    approved BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 3. Create 'rsvp' table (guest RSVP submissions)
CREATE TABLE IF NOT EXISTS public.rsvp (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
    name TEXT NOT NULL,
    email TEXT NOT NULL,
    phone TEXT NOT NULL DEFAULT '',
    attending BOOLEAN NOT NULL,
    guests INTEGER NOT NULL DEFAULT 1,
    dietary TEXT,
    message TEXT,
    approved BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_photo_approved_created_at ON public.photo (approved, "createdAt" DESC);
CREATE INDEX IF NOT EXISTS idx_rsvp_email ON public.rsvp (email);
CREATE INDEX IF NOT EXISTS idx_rsvp_created_at ON public.rsvp ("createdAt" DESC);

-- Enable Row Level Security (RLS)
ALTER TABLE public.content ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.photo ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.rsvp ENABLE ROW LEVEL SECURITY;

-- RLS Policies:
-- Allow anyone to read content
CREATE POLICY "Public read content" ON public.content
    FOR SELECT USING (true);

-- Allow anyone to read approved photos
CREATE POLICY "Public read approved photos" ON public.photo
    FOR SELECT USING (approved = true);

-- Allow anyone to upload/insert photos
CREATE POLICY "Public insert photos" ON public.photo
    FOR INSERT WITH CHECK (true);

-- Allow anyone to submit an RSVP
CREATE POLICY "Public insert rsvps" ON public.rsvp
    FOR INSERT WITH CHECK (true);

-- Service role / Admin has full access to everything
-- (Handled automatically by service_role key, but policies explicitly allow all for authenticated/service role)
CREATE POLICY "Admin full access content" ON public.content
    FOR ALL USING (auth.role() = 'service_role' OR auth.role() = 'authenticated');

CREATE POLICY "Admin full access photo" ON public.photo
    FOR ALL USING (auth.role() = 'service_role' OR auth.role() = 'authenticated');

CREATE POLICY "Admin full access rsvp" ON public.rsvp
    FOR ALL USING (auth.role() = 'service_role' OR auth.role() = 'authenticated');
