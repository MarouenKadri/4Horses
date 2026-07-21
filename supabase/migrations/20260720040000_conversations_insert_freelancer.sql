-- Le freelancer doit pouvoir initier une conversation avec son client une
-- fois la mission confirmée (contact direct dans les deux sens), pas
-- seulement répondre à une conversation déjà créée par le client.
create policy "conversations_insert_freelancer"
on public.conversations for insert
with check (auth.uid() = freelancer_id);
