{
    "name": "Greenteck Stock Custom",
    "version": "1.0",
    'website': 'http://www.diracerp.in',
    'images': [ ],
    "depends": ['sale' ],
    "author": "Dirac ERP",
    "category": "Stock",
    'sequence': 16,
    "description": """
    This module will provide the detail of group transfer  
    """,
    'data': [
        
        'view/bulk_stock_view.xml',
    
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