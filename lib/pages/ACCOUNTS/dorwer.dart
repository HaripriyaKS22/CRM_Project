import 'package:beposoft/pages/ACCOUNTS/add_Expenses.dart';
import 'package:beposoft/pages/ACCOUNTS/add_Recipt.dart';
import 'package:beposoft/pages/ACCOUNTS/add_bank.dart';
import 'package:beposoft/pages/ACCOUNTS/add_credit_note.dart';
import 'package:beposoft/pages/ACCOUNTS/add_new_customer.dart';
import 'package:beposoft/pages/ACCOUNTS/add_new_stock.dart';
import 'package:beposoft/pages/ACCOUNTS/add_staff.dart';
import 'package:beposoft/pages/ACCOUNTS/add_warehouse.dart';
import 'package:beposoft/pages/ACCOUNTS/bank_list.dart';
import 'package:beposoft/pages/ACCOUNTS/codsales_report.dart';
import 'package:beposoft/pages/ACCOUNTS/credit_note_list.dart';
import 'package:beposoft/pages/ACCOUNTS/creditsale_report.dart';
import 'package:beposoft/pages/ACCOUNTS/customer.dart';
import 'package:beposoft/pages/ACCOUNTS/daily_goods_movement.dart';
import 'package:beposoft/pages/ACCOUNTS/damaged_stock_report.dart';
import 'package:beposoft/pages/ACCOUNTS/delivery_report.dart';
import 'package:beposoft/pages/ACCOUNTS/expence_reeport.dart';
import 'package:beposoft/pages/ACCOUNTS/expense_list.dart';
import 'package:beposoft/pages/ACCOUNTS/finance_report.dart';
import 'package:beposoft/pages/ACCOUNTS/grv_list.dart';
import 'package:beposoft/pages/ACCOUNTS/new_grv.dart';
import 'package:beposoft/pages/ACCOUNTS/new_performa_products.dart';
import 'package:beposoft/pages/ACCOUNTS/new_product.dart';
import 'package:beposoft/pages/ACCOUNTS/order_list.dart';
import 'package:beposoft/pages/ACCOUNTS/order_products.dart';
import 'package:beposoft/pages/ACCOUNTS/performa_invoice_list.dart';
import 'package:beposoft/pages/ACCOUNTS/post_office_report.dart';
import 'package:beposoft/pages/ACCOUNTS/product_list.dart';
import 'package:beposoft/pages/ACCOUNTS/purchase_list.dart';
import 'package:beposoft/pages/ACCOUNTS/purchases_request.dart';
import 'package:beposoft/pages/ACCOUNTS/recipt.report.dart';
import 'package:beposoft/pages/ACCOUNTS/recipts_list.dart';
import 'package:beposoft/pages/ACCOUNTS/sales_report.dart';
import 'package:beposoft/pages/ACCOUNTS/sold_product_report.dart';
import 'package:beposoft/pages/ACCOUNTS/statewise_report.dart';
import 'package:beposoft/pages/ACCOUNTS/stock_report.dart';
import 'package:beposoft/pages/ACCOUNTS/view_staff.dart';
import 'package:beposoft/pages/BDM/bdm_customer_list.dart';
import 'package:beposoft/pages/BDO/bdo_add_customer.dart';
import 'package:beposoft/pages/BDO/bdo_customer_list.dart';
import 'package:beposoft/pages/BDO/bdo_order_list.dart';
import 'package:beposoft/pages/WAREHOUSE/warehouse_order_view.dart';
import 'package:beposoft/pages/BDM/bdm_order_list.dart';

import 'package:flutter/material.dart';

class drower{


    void navigateToSelectedPage(BuildContext context, String option) {
    // Navigate to the selected page based on the option
    switch (option) {
      case 'Add Customer':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>add_new_customer()),
        );
        break;
      case 'Customers':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => customer_list()),
        );
        break;
      case 'Add Warehouse':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => add_warehouse()),
        );
        break;
      case 'Add Staff':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>add_staff()),
        );
        break;
      case 'Staff':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => staff_list()),
        );
        break;
      case 'Add Credit Note':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>add_credit_note()),
        );
        break;
      case 'Credit Note List':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => credit_note_list()),
        );
        break;

      
      case 'Add Recipt':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => add_receipt()),
        );
        break;
      case 'Recipts List':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => recipt_Report()),
        );
        break;
      case 'New Proforma Invoice':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CreatePerformaProduct_List()),
        );
        break;
      case 'Proforma Invoice List':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProformaInvoiceList()),
        );
        break;

         case 'Delivery Note List':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>WarehouseOrderView(status: null,)),
        );
        break;
      case 'Daily Goods Movement':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => daily_goods_movement()),
        );
        break;
      case 'New Orders':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => order_products()),
        );
        break;
      case 'Orders List':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => OrderList(status: null,)),
        );
        break;
      case 'Product List':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Product_List()),
        );
        break;
          case 'Product Add':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => new_product()),
        );
        break;
      case 'Stock':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => add_new_stock()),
        );
        break;

        case 'New Purchase':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>Purchases_request()),
        );
        break;
      case 'Purchase List':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => purchase_list()),
        );
        break;
      case 'Add Expence':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => add_expence()),
        );
        break;
      case 'Expence List':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => expence_list()),
        );
        break;
      case 'Sales Report':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Sales_Report()),
        );
        break;

        case 'Recipt Report':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => recipt_Report()),
        );
        break;
      case 'Credit Sales Report':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Creditsalereport2()),
        );
        break;


        
        case 'COD Sales Report':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>CodSales2()),
        );
        break;
      case 'Statewise Sales Report':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => StateWiseReport2()),
        );
        break;
      case 'Expence Report':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Expence_Report()),
        );
        break;
      case 'Delivery Report':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Delivery_Report()),
        );
        break;
      case 'Product Sale Report':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Sold_pro_report()),
        );
        break;
      case 'Stock Report':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Stock_Report()),
        );
        break;
         
      case 'Damaged Stock':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>DamagedStockReport()),
        );
        break;

      case 'Finance Report':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>FinancialReport()),
        );
        break;
      case 'Actual Delivery Report':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>PostofficeReport()),
        );
        break;
      case 'Create New GRV':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NewGrv()),
        );
        break;
      case 'GRVs List':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GrvList(status: null,)),
        );
        break;
      case 'Add Bank':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => add_bank()),
        );
        break;
      case 'List':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => bank_list()),
        );
        break;
      // case 'Other Transfer':
      //   Navigator.push(
      //     context,
      //     MaterialPageRoute(builder: (context) => transfer()),
      //   );
      //   break;
      default:
        break;
    }
  }
  

      void navigateToSelectedPage2(BuildContext context, String option) {
    // Navigate to the selected page based on the option
    switch (option) {
     
      case 'New Proforma Invoice':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CreatePerformaProduct_List()),
        );
        break;
      case 'Proforma Invoice List':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProformaInvoiceList()),
        );
        break;
      case 'Customers':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => bdo_customer_list()),
        );
        break;
      case 'Add Customer':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => bdo_add_new_customer()),
        );
        break;

       
      case 'New Orders':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => order_products()),
        );
        break;
      case 'Orders List':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => bod_oredr_list(status: null,)),
        );
        break;
      case 'Product List':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => new_product()),
        );
        break;
      case 'Stock':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => add_new_stock()),
        );
        break;

        case 'New Purchase':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>Purchases_request()),
        );
        break;
      case 'Purchase List':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => purchase_list()),
        );
        break;
      case 'Add Expence':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => add_expence()),
        );
        break;
      case 'Expence List':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => expence_list()),
        );
        break;
      case 'Sales Report':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => new_product()),
        );
        break;
      case 'Credit Sales Report':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => add_new_stock()),
        );
        break;


        
        case 'COD Sales Report':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>Purchases_request()),
        );
        break;
      case 'Statewise Sales Report':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => purchase_list()),
        );
        break;
      case 'Expence Report':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => add_expence()),
        );
        break;
      case 'Delivery Report':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Delivery_Report()),
        );
        break;
      case 'Product Sale Report':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => new_product()),
        );
        break;
      case 'Stock Report':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => add_new_stock()),
        );
        break;
         
        case 'Damaged Stock':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>DamagedStockReport()),
        );
        break;
      case 'Create New GRV':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NewGrv()),
        );
        break;
      case 'GRVs List':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GrvList(status: null,)),
        );
        break;
      case 'Add Bank':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => add_bank()),
        );
        break;
      case 'List':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => bank_list()),
        );
        break;
      // case 'Other Transfer':
      //   Navigator.push(
      //     context,
      //     MaterialPageRoute(builder: (context) => transfer()),
      //   );
      //   break;
      default:
        break;
    }
  }




   void navigateToSelectedPage3(BuildContext context, String option) {
    // Navigate to the selected page based on the option
    switch (option) {
     
      case 'New Proforma Invoice':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CreatePerformaProduct_List()),
        );
        break;
      case 'Proforma Invoice List':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProformaInvoiceList()),
        );
        break;
      case 'Customers':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => bdm_customer_list()),
        );
        break;
      case 'Add Customer':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => add_new_customer()),
        );
        break;

       
      case 'New Orders':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => order_products()),
        );
        break;
      case 'Orders List':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => bdm_OrderList(status: null,)),
        );
        break;
      case 'Product List':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => new_product()),
        );
        break;
      case 'Stock':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => add_new_stock()),
        );
        break;

        case 'New Purchase':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>Purchases_request()),
        );
        break;
      case 'Purchase List':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => purchase_list()),
        );
        break;
      case 'Add Expence':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => add_expence()),
        );
        break;
      case 'Expence List':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => expence_list()),
        );
        break;
      case 'Sales Report':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => new_product()),
        );
        break;
      case 'Credit Sales Report':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => add_new_stock()),
        );
        break;


        
        case 'COD Sales Report':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>Purchases_request()),
        );
        break;
      case 'Statewise Sales Report':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => purchase_list()),
        );
        break;
      case 'Expence Report':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => add_expence()),
        );
        break;
      case 'Delivery Report':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Delivery_Report()),
        );
        break;
      case 'Product Sale Report':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => new_product()),
        );
        break;
      case 'Stock Report':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => add_new_stock()),
        );
        break;
         
        case 'Damaged Stock':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>DamagedStockReport()),
        );
        break;
      case 'Create New GRV':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NewGrv()),
        );
        break;
      case 'GRVs List':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GrvList(status: null,)),
        );
        break;
      case 'Add Bank':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => add_bank()),
        );
        break;
      case 'List':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => bank_list()),
        );
        break;
      // case 'Other Transfer':
      //   Navigator.push(
      //     context,
      //     MaterialPageRoute(builder: (context) => transfer()),
      //   );
      case 'Add Staff':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>add_staff()),
        );
        break;
      case 'Staff':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => staff_list()),
        );
        break;
      case 'Add Credit Note':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>add_credit_note()),
        );
        break;
      default:
        break;
    }
  }
}

