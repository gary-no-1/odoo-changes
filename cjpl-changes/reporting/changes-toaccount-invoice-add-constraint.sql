alter table account_invoice add CONSTRAINT chk_bill_from_to_dates check (
(x_bill_period_from is null and x_bill_period_to is null)
or
( DATE_PART('day', x_bill_period_to - x_bill_period_from) >= 0)
);