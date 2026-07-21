-- Supprime complètement le code de démarrage — le flux ne demande plus
-- d'échange de code en personne, le freelancer démarre directement la
-- mission une fois sur place.
drop trigger if exists trg_mission_start_code on public.missions;
drop function if exists public.generate_mission_start_code();
drop function if exists public.verify_mission_start_code(uuid, text);

alter table public.missions
  drop column if exists start_code;
