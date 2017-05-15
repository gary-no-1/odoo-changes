from openerp.osv import fields, osv
from datetime import datetime, timedelta
import base64, urllib
import os
import re
from PIL import Image
from openerp.tools import amount_to_text
from openerp.tools.translate import _
from lxml  import etree
from openerp.tools import DEFAULT_SERVER_DATE_FORMAT, DEFAULT_SERVER_DATETIME_FORMAT, DATETIME_FORMATS_MAP, float_compare
from openerp.osv.orm import setup_modifiers
from openerp.tools.translate import _
import time
import xlwt
from openerp import SUPERUSER_ID
import xlsxwriter
from xlsxwriter.workbook import Workbook
from xlwt import Workbook, XFStyle, Borders, Pattern, Font, Alignment,  easyxf
import openerp.addons.decimal_precision as dp
import math
from openerp.tools import amount_to_text_en


class sale_order(osv.osv):
    _inherit = "sale.order"

    def onchange_product_product(self,cr,uid,ids,product_ids= False,context=None):
        result={}
        order_list = []
        product_list = []
        if product_ids[0][2]:
            for val in product_ids[0][2]:
                product_list.append(self.pool.get('product.product').browse(cr,uid,val))
        
        if product_list:
            for val in product_list:
                order_list.append((0,False,{'product_id':val.id,'price_unit':val.list_price,'state':'draft',
                                            'product_uom_qty':1.0,'delay':7.0,'name':val.name}))
        result['value'] = {'order_line':order_list}
        return result
                
                
    _columns={
              'ship_date':fields.date('Ship Date',track_visibility='onchange'),
              'product_ids':fields.many2many('product.product','sale_tab','current_id','sale_id','Product'),
              
              }
   
