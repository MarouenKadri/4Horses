-- Push : chaque insert dans notifications appelle l'Edge Function send-push.
-- Appliquée sur le projet le 2026-07-10.
-- NB : le secret webhook vit dans Vault (push_webhook_secret) et comme
-- secret PUSH_WEBHOOK_SECRET de l'Edge Function — jamais versionné ici.
create extension if not exists pg_net with schema extensions;

create or replace function public.trigger_send_push()
returns trigger
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
  secret text;
begin
  select decrypted_secret into secret
  from vault.decrypted_secrets
  where name = 'push_webhook_secret'
  limit 1;
  if secret is null then
    return NEW;
  end if;
  perform net.http_post(
    url := 'https://fjafqmklzaiokyrhfvyl.supabase.co/functions/v1/send-push',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'x-webhook-secret', secret
    ),
    body := jsonb_build_object('record', to_jsonb(NEW))
  );
  return NEW;
end;
$$;

drop trigger if exists notifications_send_push on public.notifications;
create trigger notifications_send_push
  after insert on public.notifications
  for each row execute function public.trigger_send_push();
