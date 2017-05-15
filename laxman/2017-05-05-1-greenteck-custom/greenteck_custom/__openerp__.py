{
    "name": "Greenteck Custom",
    "version": "1.0",
    'website': 'http://www.diracerp.in',
    'images': [ ],
    "depends": ['sale' ],
    "author": "Dirac ERP",
    "category": "Sample",
    'sequence': 16,
    "description": """
    This module will provide the detail of sample and convert it into a product and some report regarding sample  
    """,
    'data': [
        'view/sale_view.xml',
        'view/stock_view.xml',
        'wizard/stock_transfer_details.xml',
        'view/account_invoice_view.xml',
          'wizard/stock1_view.xml',
          'wizard/stock_return_picking_view.xml',
                    ],
    'demo_xml': [],
     'js': [
           'static/src/js/view_list.js'
#     'static/src/js/subst.js'
    ],
    'css': ['static/src/css/sample_kanban.css'],
    'installable': True,
    'active': False,
    'auto_install': False,
#    'certificate': 'certificate',
}