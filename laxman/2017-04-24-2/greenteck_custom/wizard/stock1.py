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

class stock1(osv.osv):
    _name="stock1"
    def create_stock_move(self,cr,uid,ids,context=None):
        picking_obj = self.pool.get('stock.picking')
        stock_obj = self.pool.get('stock.move')
        stock1_obj = self.pool.get('stock1').browse(cr,uid,ids)
        if context is None:
            context={}
        res={}
        location_list = []
        location_list1 = []
        s = ''
        for list_obj in self.browse(cr, uid, ids, context=None):
            print"vnvjdbvjbd",list_obj.picking_type_id
            print"vnvjdbvjbd111111111111",list_obj.picking_type_id.id
#             pick_id = picking_obj.create(cr,uid,{'picking_type_id':list_obj.picking_type_id.id})
#             print"pick_idddd",pick_id
            if list_obj.stock1_lines:
                for val in list_obj.stock1_lines:
                    print"$$$$$",val.uom_id.id
                    if val.qty > 0:
                        location_list.append(val.dest_loc.id)
                        print"loaction_listttt",location_list
                        s = val
                    else:
                        location_list = [ ]
                        s = ' '
                        break;
                if s != ' ':
                    location_list1 = list(set(location_list))
                    print"TTTTTTTTTTTTTt",location_list1
            if s != ' ':
                for val2 in location_list1:
                    print"valllll"
            
                    pick_id = picking_obj.create(cr,uid,{'picking_type_id':list_obj.picking_type_id.id,
                                                         'source_loc':list_obj.source_location.id})
                    print"pick_idddd",pick_id
                    for val in list_obj.stock1_lines:
                      
                        if val.dest_loc.id == val2 :
                            ss = stock_obj.create(cr,uid,{'picking_id':pick_id,'product_id':val.product_id.id,'product_uom_qty':val.qty,
                                                 'location_id':list_obj.source_location.id,'location_dest_id':val.dest_loc.id,
                                                 'picking_type_id':list_obj.picking_type_id.id,'product_uom':val.uom_id.id,
                                                 'name':val.product_id.name})
                            print"######"
	      self.write(cr, uid, ids, {'code':True}, context)
#             picking_obj.create(cr,uid,{'move_lines':ss,'picking_type_id':list_obj.picking_type_id.id})
        return res
    _columns={
              'picking_type_id':fields.many2one('stock.picking.type','Picking Type'),
              'date':fields.date('Date'),
              'source_location':fields.many2one('stock.location','Source Location'),
            'stock1_lines':fields.one2many('stock1.line','stock12_id','Stock Lines'),
	    'code':fields.boolean('Code'),
              }
class stock1_line(osv.osv):
    _name="stock1.line"
    _columns={
              'product_id':fields.many2one('product.product','Product'),
              'qty':fields.integer('Qty'),
              'uom_id':fields.many2one('product.uom','Uom'),
              'dest_loc':fields.many2one('stock.location','Destination Location'),
              'stock12_id':fields.many2one('stock1','Stock Lines')
              }
    _defaults={
               'uom_id':1,
               }
