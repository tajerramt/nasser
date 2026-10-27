-- À exécuter UNE fois : Supabase > SQL Editor > New query > Run
create table if not exists docs(
  id text primary key,
  kind text not null,
  data jsonb not null default '{}',
  del boolean not null default false,
  updated_at timestamptz not null default clock_timestamp()
);
create index if not exists docs_updated on docs(updated_at);

-- l'horodatage est fixé par le serveur (pas par l'horloge du téléphone)
create or replace function touch() returns trigger language plpgsql as $$
begin new.updated_at := clock_timestamp(); return new; end $$;
create trigger docs_touch before insert or update on docs
  for each row execute function touch();

-- sécurité : seul l'utilisateur naser@nasser.app peut lire ou écrire
alter table docs enable row level security;
create policy "seul naser" on docs for all to authenticated
  using ((auth.jwt()->>'email') = 'naser@nasser.app')
  with check ((auth.jwt()->>'email') = 'naser@nasser.app');
