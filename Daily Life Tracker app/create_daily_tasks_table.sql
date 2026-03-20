create table public.daily_tasks (
  id uuid not null default gen_random_uuid (),
  user_id uuid null,
  title text not null,
  icon text null,
  is_completed boolean null default false,
  category text null,
  reminder_time text null,
  is_repeating boolean null default false,
  priority text null,
  created_at timestamp with time zone null default timezone ('utc'::text, now()),
  updated_at timestamp with time zone null default timezone ('utc'::text, now()),
  constraint daily_tasks_pkey primary key (id),
  constraint daily_tasks_user_id_fkey foreign KEY (user_id) references auth.users (id) on delete CASCADE
) TABLESPACE pg_default;

create index IF not exists idx_daily_tasks_user_created on public.daily_tasks using btree (user_id, created_at desc) TABLESPACE pg_default;

create trigger update_daily_tasks_updated_at BEFORE
update on daily_tasks for EACH row
execute FUNCTION update_updated_at_column ();
