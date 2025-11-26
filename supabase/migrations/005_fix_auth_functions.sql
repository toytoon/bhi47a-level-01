-- 1. Create extensions schema if it doesn't exist
CREATE SCHEMA IF NOT EXISTS extensions;

-- 2. Enable pgcrypto extension in extensions schema
-- If it's already in public, this is fine, we handle it in step 3
CREATE EXTENSION IF NOT EXISTS pgcrypto SCHEMA extensions;

-- 3. Re-create verify_password function with CORRECT search_path
-- This ensures it looks in both 'public' and 'extensions' for the crypt function
CREATE OR REPLACE FUNCTION public.verify_password(password TEXT, hash TEXT)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN hash = crypt(password, hash);
END;
$$ LANGUAGE plpgsql IMMUTABLE STRICT SECURITY DEFINER SET search_path = public, extensions;

-- 4. Grant permissions
GRANT EXECUTE ON FUNCTION public.verify_password(TEXT, TEXT) TO anon, authenticated, service_role;

-- 5. Re-insert admins to ensure passwords are valid
INSERT INTO public.admins (admin_code, admin_name, password_hash)
VALUES 
  ('ADMIN001', 'مدير المستوي الاول', crypt('admin123', gen_salt('bf', 4)))
ON CONFLICT (admin_code) 
DO UPDATE SET 
  admin_name = EXCLUDED.admin_name,
  password_hash = EXCLUDED.password_hash;