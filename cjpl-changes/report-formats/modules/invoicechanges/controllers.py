# -*- coding: utf-8 -*-
from openerp import http

# class Invoicechanges(http.Controller):
#     @http.route('/invoicechanges/invoicechanges/', auth='public')
#     def index(self, **kw):
#         return "Hello, world"

#     @http.route('/invoicechanges/invoicechanges/objects/', auth='public')
#     def list(self, **kw):
#         return http.request.render('invoicechanges.listing', {
#             'root': '/invoicechanges/invoicechanges',
#             'objects': http.request.env['invoicechanges.invoicechanges'].search([]),
#         })

#     @http.route('/invoicechanges/invoicechanges/objects/<model("invoicechanges.invoicechanges"):obj>/', auth='public')
#     def object(self, obj, **kw):
#         return http.request.render('invoicechanges.object', {
#             'object': obj
#         })