create or replace function public.upsert_live_fx_rates(
  p_source text,
  p_as_of timestamptz,
  p_rates jsonb
)
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  source_name text := nullif(trim(p_source), '');
  as_of_at timestamptz := coalesce(p_as_of, timezone('utc', now()));
  pair jsonb;
  base_code text;
  quote_code text;
  pair_rate numeric;
  upserted integer := 0;
begin
  if source_name is null then
    raise exception 'Missing FX source';
  end if;

  if p_rates is null or jsonb_typeof(p_rates) <> 'array' then
    raise exception 'Invalid FX payload';
  end if;

  for pair in
    select value
    from jsonb_array_elements(p_rates)
  loop
    base_code := upper(trim(pair ->> 'base_currency'));
    quote_code := upper(trim(pair ->> 'quote_currency'));
    pair_rate := (pair ->> 'rate')::numeric;

    if base_code not in ('USD', 'GHS', 'NGN')
      or quote_code not in ('USD', 'GHS', 'NGN')
      or base_code = quote_code then
      raise exception 'Unsupported FX pair';
    end if;

    if pair_rate is null or pair_rate <= 0 then
      raise exception 'Invalid FX rate';
    end if;

    insert into public.fx_rates (
      base_currency,
      quote_currency,
      rate,
      source,
      is_test,
      as_of
    )
    values (
      base_code,
      quote_code,
      pair_rate,
      source_name,
      false,
      as_of_at
    )
    on conflict (base_currency, quote_currency) do update
    set
      rate = excluded.rate,
      source = excluded.source,
      is_test = false,
      as_of = excluded.as_of;

    upserted := upserted + 1;
  end loop;

  if upserted <> 6 then
    raise exception 'Expected six FX pairs';
  end if;

  return upserted;
end;
$$;

revoke all on function public.upsert_live_fx_rates(text, timestamptz, jsonb) from public;
revoke all on function public.upsert_live_fx_rates(text, timestamptz, jsonb) from anon;
revoke all on function public.upsert_live_fx_rates(text, timestamptz, jsonb) from authenticated;
grant execute on function public.upsert_live_fx_rates(text, timestamptz, jsonb)
to service_role;

select public.upsert_live_fx_rates(
  'exchangerate-api.com',
  timestamptz '2026-08-16 00:02:31+00',
  '[
    {"base_currency":"USD","quote_currency":"GHS","rate":11.186249},
    {"base_currency":"GHS","quote_currency":"USD","rate":0.08939513},
    {"base_currency":"USD","quote_currency":"NGN","rate":1358.704328},
    {"base_currency":"NGN","quote_currency":"USD","rate":0.00073600},
    {"base_currency":"GHS","quote_currency":"NGN","rate":121.462137},
    {"base_currency":"NGN","quote_currency":"GHS","rate":0.00823300}
  ]'::jsonb
);
