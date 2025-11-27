-- Fix students status check constraint
-- This migration ensures the constraint allows all required status values

-- First, drop the constraint if it exists
ALTER TABLE public.students DROP CONSTRAINT IF EXISTS students_status_check;

-- Re-create the constraint with all allowed values
ALTER TABLE public.students 
  ADD CONSTRAINT students_status_check 
  CHECK (status IN ('active', 'absent', 'hide', 'inactive', 'محجوب', 'غائب'));

-- Note: 'inactive' is kept for backward compatibility if any data exists, 
-- but the UI will only use active, absent, hide.
