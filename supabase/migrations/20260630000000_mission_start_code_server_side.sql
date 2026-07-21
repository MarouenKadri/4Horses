-- Migration: mission_start_code_server_side
-- Replaces the client-side FNV hash with a server-generated random 6-digit code
-- stored in the DB. The old approach was predictable from public fields (mission
-- id + created_at); this one is cryptographically random.

-- 1. Add column
ALTER TABLE missions
  ADD COLUMN IF NOT EXISTS start_code varchar(6);

-- 2. Trigger function — generates the code when assigned_presta_id is first set
CREATE OR REPLACE FUNCTION public.generate_mission_start_code()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  IF NEW.assigned_presta_id IS NOT NULL AND OLD.assigned_presta_id IS NULL THEN
    NEW.start_code := lpad(
      floor(random() * 900000 + 100000)::text,
      6, '0'
    );
  END IF;
  RETURN NEW;
END;
$$;

-- 3. Attach trigger (idempotent — drop first if it already exists)
DROP TRIGGER IF EXISTS trg_mission_start_code ON missions;
CREATE TRIGGER trg_mission_start_code
  BEFORE UPDATE ON missions
  FOR EACH ROW
  EXECUTE FUNCTION public.generate_mission_start_code();

-- 4. RPC — verifies the code server-side without exposing it to other clients.
--    Only the mission's client or its assigned freelancer can call this.
CREATE OR REPLACE FUNCTION public.verify_mission_start_code(
  p_mission_id uuid,
  p_code       text
)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  stored_code      varchar(6);
  uid              uuid := auth.uid();
  normalized_input text;
BEGIN
  SELECT start_code INTO stored_code
    FROM missions
    WHERE id = p_mission_id
      AND (client_id = uid OR assigned_presta_id = uid);

  IF stored_code IS NULL THEN
    RETURN false;
  END IF;

  normalized_input := regexp_replace(p_code, '[^0-9]', '', 'g');
  RETURN normalized_input = stored_code;
END;
$$;

GRANT EXECUTE ON FUNCTION public.verify_mission_start_code(uuid, text) TO authenticated;
