create index month_dim_month_of_year_idx on month_dim(month_of_year);
create index month_dim_year_idx on month_dim(year);
create unique index month_dim_period_id_ui on month_dim(period_id);