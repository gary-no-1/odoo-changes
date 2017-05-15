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

    _columns={
              'ship_date':fields.date('Ship Date',track_visibility='onchange'),
              
              }
   
