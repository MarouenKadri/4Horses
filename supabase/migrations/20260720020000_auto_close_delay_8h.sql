-- Réduit le délai de clôture auto de 24h à 8h — moins de friction pour le
-- freelancer (paiement libéré plus vite en cas de silence du client), tout
-- en laissant un temps raisonnable au client pour réagir.
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
      and updated_at < now() - interval '8 hours'
    returning id, client_id, assigned_presta_id, title
  loop
    insert into notifications (user_id, type, title, body, is_read, target_role)
    values (
      m.client_id, 'mission', 'Mission clôturée automatiquement',
      'Sans action de votre part sous 8h, la mission "' || m.title || '" a été clôturée.',
      false, 'client'
    );
    if m.assigned_presta_id is not null then
      insert into notifications (user_id, type, title, body, is_read, target_role)
      values (
        m.assigned_presta_id, 'payment', 'Mission clôturée',
        'La mission "' || m.title || '" a été clôturée automatiquement 8h après votre signalement de fin.',
        false, 'freelancer'
      );
    end if;
  end loop;
end;
$$;
