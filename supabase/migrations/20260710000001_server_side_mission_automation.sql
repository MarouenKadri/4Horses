-- Automatisations serveur : le cycle de vie ne dépend plus de l'ouverture de l'app.
-- Appliquée sur le projet le 2026-07-10.
create extension if not exists pg_cron;

-- 1) Expiration : mission dont la date est passée sans prestataire confirmé
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
    insert into notifications (user_id, type, title, body, is_read)
    values (
      m.client_id, 'mission', 'Mission expirée',
      'La mission "' || m.title || '" a expiré sans prestataire confirmé. Vous pouvez la republier.',
      false
    );
  end loop;
end;
$$;

-- 2) Clôture automatique : fin signalée restée sans réponse client pendant 24h
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
    insert into notifications (user_id, type, title, body, is_read)
    values (
      m.client_id, 'mission', 'Mission clôturée automatiquement',
      'Sans action de votre part sous 24h, la mission "' || m.title || '" a été clôturée.',
      false
    );
    if m.assigned_presta_id is not null then
      insert into notifications (user_id, type, title, body, is_read)
      values (
        m.assigned_presta_id, 'payment', 'Mission clôturée',
        'La mission "' || m.title || '" a été clôturée automatiquement 24h après votre signalement de fin.',
        false
      );
    end if;
  end loop;
end;
$$;

-- Planification (toutes les 30 min) — idempotente
do $$
begin
  perform cron.unschedule(jobid) from cron.job where jobname = 'expire-stale-missions';
  perform cron.unschedule(jobid) from cron.job where jobname = 'auto-close-completed-missions';
exception when others then null;
end $$;

select cron.schedule('expire-stale-missions', '*/30 * * * *',
  $$select public.expire_stale_missions()$$);
select cron.schedule('auto-close-completed-missions', '*/30 * * * *',
  $$select public.auto_close_completed_missions()$$);
