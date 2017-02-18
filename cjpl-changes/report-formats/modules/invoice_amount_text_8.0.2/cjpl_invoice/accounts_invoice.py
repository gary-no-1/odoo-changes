# -*- coding: utf-8 -*-
##############################################################################
# For copyright and license notices, see __openerp__.py file in root directory
##############################################################################

#try:
#    import num2words
#except ImportError:
#    raise ImportError('This module needs num2words  to work. Please install num2words on your system. (sudo pip install num2words)')

from num2words import num2words

from openerp import models, fields, api, _
from openerp.tools import amount_to_text

class account_invoice(models.Model):
    _inherit = "account.invoice"

    sale_order = self.pool.get('sale.order')
    order_id = sale_order.search(cr,uid,[('name','=',o.orgin)])
    if order_id:
       sale_obj = sale_order.browse(cr,uid,order_id[0])

    @api.multi
    def amount_to_text(self, amount, currency='Euro'):
        return num2words(amount, lang='en_IN')

#   return amount_to_text(amount, currency)

#   return num2words(amount, lang='en_IN')

