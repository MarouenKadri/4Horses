-- Réduit le code de démarrage mission de 6 à 4 chiffres — plus rapide à
-- communiquer oralement entre client et freelancer, sans perte de sécurité
-- significative pour ce cas d'usage (échange en personne, tentative limitée
-- par la RLS qui ne laisse voir le code qu'au client/freelancer concernés).

-- 1. Régénère d'abord tout code existant en 4 chiffres, avant de réduire le
--    type de colonne (sinon l'ALTER TYPE échoue en tentant de tronquer des
--    valeurs à 6 chiffres).
update public.missions
set start_code = lpad(floor(random() * 9000 + 1000)::text, 4, '0')
where start_code is not null;

-- 2. Réduit la colonne
alter table public.missions
  alter column start_code type varchar(4);

-- 3. Trigger de génération — 4 chiffres au lieu de 6.
create or replace function public.generate_mission_start_code()
returns trigger
language plpgsql
security definer
as $$
begin
  if NEW.assigned_presta_id is not null and OLD.assigned_presta_id is null then
    NEW.start_code := lpad(
      floor(random() * 9000 + 1000)::text,
      4, '0'
    );
  end if;
  return NEW;
end;
$$;
