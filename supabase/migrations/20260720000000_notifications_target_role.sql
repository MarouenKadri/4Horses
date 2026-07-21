-- Sépare les notifications par rôle (client / freelancer) : un utilisateur
-- qui a les deux rôles ne doit voir en mode freelancer que les notifs qui le
-- concernent en tant que freelancer, et inversement en mode client.
create type public.notification_target_role as enum ('client', 'freelancer');

alter table public.notifications
  add column if not exists target_role public.notification_target_role;

-- Backfill best-effort : missions/candidatures envoyées au client de la
-- mission = 'client' ; le reste ('candidature' acceptée, 'payment' presta,
-- messages, avis) = 'freelancer'. Les lignes non déterminables restent
-- 'client' par défaut (comportement historique : la plupart des notifs
-- automatisées existantes ciblaient déjà le client).
update public.notifications n
set target_role = 'client'
where target_role is null
  and exists (
    select 1 from public.missions m
    where m.client_id = n.user_id
  );

update public.notifications
set target_role = 'freelancer'
where target_role is null
  and type in ('candidature', 'payment', 'review');

update public.notifications
set target_role = 'client'
where target_role is null;

alter table public.notifications
  alter column target_role set default 'client',
  alter column target_role set not null;

-- Notifications serveur (pg_cron) : préciser le rôle cible explicitement.
create or replace function public.expire_stale_missions()
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  m record;
begin
  for m in
    update missions
    set status = 'expired', updated_at = now()
    where status in ('waiting_candidates', 'candidate_received', 'pending_acceptance')
      and scheduled_at is not null
      and scheduled_at < now()
    returning id, client_id, title
  loop
    insert into notifications (user_id, type, title, body, is_read, target_role)
    values (
      m.client_id, 'mission', 'Mission expirée',
      'La mission "' || m.title || '" a expiré sans prestataire confirmé. Vous pouvez la republier.',
      false, 'client'
    );
  end loop;
end;
$$;

create or replace function public.auto_close_completed_missions()
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  m record;
begin
  for m in
    update missions
    set status = 'closed', updated_at = now()
    where status = 'completion_requested'
      and updated_at < now() - interval '24 hours'
    returning id, client_id, assigned_presta_id, title
  loop
    insert into notifications (user_id, type, title, body, is_read, target_role)
    values (
      m.client_id, 'mission', 'Mission clôturée automatiquement',
      'Sans action de votre part sous 24h, la mission "' || m.title || '" a été clôturée.',
      false, 'client'
    );
    if m.assigned_presta_id is not null then
      insert into notifications (user_id, type, title, body, is_read, target_role)
      values (
        m.assigned_presta_id, 'payment', 'Mission clôturée',
        'La mission "' || m.title || '" a été clôturée automatiquement 24h après votre signalement de fin.',
        false, 'freelancer'
      );
    end if;
  end loop;
end;
$$;
