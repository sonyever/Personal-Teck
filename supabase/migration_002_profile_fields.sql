-- Cole no SQL Editor do Supabase e clique em Run
alter table profiles add column if not exists phone      text;
alter table profiles add column if not exists cpf        text;
alter table profiles add column if not exists birth_date text;
alter table profiles add column if not exists cref       text;
alter table profiles add column if not exists crn        text;
alter table profiles add column if not exists specialty  text;
alter table profiles add column if not exists academy    text;
alter table profiles add column if not exists clinic     text;
