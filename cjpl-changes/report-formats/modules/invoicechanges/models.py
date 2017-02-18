# -*- coding: utf-8 -*-

# from openerp.osv import fields, orm
from openerp import models, fields, api, exceptions
# from datetime import datetime

class account_invoice(models.Model):
    _inherit = "account.invoice"

    _sql_constraints = [
        ('chk_bill_from_to', 'check((x_bill_period_from is null \
        and x_bill_period_to is null) or ( DATE_PART("day", \
        x_bill_period_to - x_bill_period_from ) >= 0))', \
        'Bill Period Dates are in error')
        ]
