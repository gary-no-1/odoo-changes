from openerp.tools.translate import _
from openerp.tools import DEFAULT_SERVER_DATE_FORMAT, DEFAULT_SERVER_DATETIME_FORMAT, DATETIME_FORMATS_MAP, float_compare
import openerp
from openerp import tools
from openerp.tools.translate import _
from openerp.exceptions import AccessError
from openerp.osv import fields,osv
from openerp import SUPERUSER_ID
import time
import os,re
from openerp.tools import amount_to_text_en
import base64, urllib
from PIL import Image

class bulk(osv.osv):
    _name="bulk"
    def create_stock_move(self,cr,uid,ids,context=None):
        picking_obj = self.pool.get('stock.picking')
        stock_obj = self.pool.get('stock.move')
        stock1_obj = self.pool.get('bulk').browse(cr,uid,ids)
        if context is None:
            context={}
        res={}
        location_list = []
        location_list1 = []
        s = ''
        for list_obj in self.browse(cr, uid, ids, context=None):
            
            if list_obj.bulk_lines:
                for val in list_obj.bulk_lines:
                    if val.qty > 0:
                        location_list.append(val.dest_loc.id)
                        s = val
                    else:
                        location_list = [ ]
                        s = ' '
                        break;
                if s != ' ':
                    location_list1 = list(set(location_list))
            if s != ' ':
                for val2 in location_list1:
            
                    pick_id = picking_obj.create(cr,uid,{'picking_type_id':list_obj.picking_type_id.id,
                                                         'source_loc':list_obj.source_location.id})
                    for val in list_obj.bulk_lines:
                      
                        if val.dest_loc.id == val2 :
                            ss = stock_obj.create(cr,uid,{'picking_id':pick_id,'product_id':val.product_id.id,'product_uom_qty':val.qty,
                                                 'location_id':list_obj.source_location.id,'location_dest_id':val.dest_loc.id,
                                                 'picking_type_id':list_obj.picking_type_id.id,'product_uom':val.uom_id.id,
                                                 'name':val.product_id.name})
                         
        self.write(cr, uid, ids, {'code':True}, context)
#             picking_obj.create(cr,uid,{'move_lines':ss,'picking_type_id':list_obj.picking_type_id.id})
        return res
    _columns={
              'picking_type_id':fields.many2one('stock.picking.type','Picking Type'),
              'date':fields.date('Date'),
              'source_location':fields.many2one('stock.location','Source Location'),
            'bulk_lines':fields.one2many('bulk.line','bulk_id','Stock Lines'),
        'code':fields.boolean('Code'),
              }
class bulk_line(osv.osv):
    _name="bulk.line"
    _columns={
              'product_id':fields.many2one('product.product','Product'),
              'qty':fields.integer('Qty'),
              'uom_id':fields.many2one('product.uom','Uom'),
              'dest_loc':fields.many2one('stock.location','Destination Location'),
              'bulk_id':fields.many2one('bulk','Bulk Lines'),
          'code':fields.boolean('Code'),
              }
    _defaults={
               'uom_id':1,
               }
