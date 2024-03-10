using Microsoft.Data.SqlClient;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;

namespace StoreDbMaster
{
    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        private SqlConnection? globalConnection;
        public MainWindow()
        {
            InitializeComponent();
        }

      
        private string formatProcedureArguments(params string[] args)
        {
            string res = "";
            foreach (string arg in args)
            {
                if((int.TryParse(arg, out _) || arg=="null") && !arg.Contains('+'))
                {
                    
                    res +=arg + ",";
                }
                else res += ("[" + arg + "],");
            }
            return res.Remove(res.Length-1);
        }

        private void addRecord(string table, string argList)
        {
            globalConnection.Open();
            string query = $"EXEC Add{table} {argList}";
            SqlCommand insert = new SqlCommand(query, globalConnection);
            insert.ExecuteNonQuery();
            globalConnection.Close();
            
        }

        private void refreshQuery(string queryTitle)
        {
            globalConnection.Open();
            DataTable dt = new DataTable();
            string query = $"EXEC {queryTitle}";
            SqlCommand command = new SqlCommand(query, globalConnection);
            SqlDataAdapter adapter = new SqlDataAdapter();
            adapter.SelectCommand = command;
            adapter.Fill(dt);
            dataGridQuery.ItemsSource = dt.DefaultView;
            globalConnection.Close();
        }

        private void refreshAll()
        {
            refreshContent(dataGridCategories, "Categories");
            refreshContent(dataGridProducts, "Products");
            refreshCatalog(categoryCatalog, "Categories");
            refreshContent(dataGridProducts, "Products");
            refreshContent(dataGridAccounts, "CustomerAccounts");
            refreshContent(dataGridPaymentInformation, "PaymentInformation");
            refreshCatalog(accountIdCatalog, "CustomerAccounts");
            refreshContent(dataGridDiscounts, "Discounts");
            refreshCatalog(productCatalog, "Products");
            refreshCatalog(TransactionProductCatalog, "Products");
            refreshCatalog(TransactionDiscountCatalog, "Discounts");
            refreshContent(dataGridTransactions, "Transactions");
        }

        private void Button_Click(object sender, RoutedEventArgs e)
        {
            refreshContent(dataGridCategories, "Categories");
        }

        private void refreshContent(DataGrid grid, string table)
        {
            globalConnection.Open();
            DataTable dt = new DataTable();
            string query = $"SELECT * FROM {table}";
            SqlCommand command = new SqlCommand(query, globalConnection);
            SqlDataAdapter adapter = new SqlDataAdapter();
            adapter.SelectCommand = command;
            adapter.Fill(dt);
            grid.ItemsSource = dt.DefaultView;

            globalConnection.Close();
        }

        private void refreshCatalog(ComboBox catalog,string table)
        {
            globalConnection.Open();
            string query = $"EXEC SelectCatalog {table}";
            SqlCommand command = new SqlCommand(query, globalConnection);
            SqlDataReader res = command.ExecuteReader();
            List<string> list = new List<string>();

            while (res.Read())
            {
                try
                {
                    list.Add(res.GetString(0));
                }
                catch (Exception ex)
                {
                    list.Add(res.GetInt32(0).ToString());
                }
            }


            //catalog.ItemsSource = list;
            res.Close();
            globalConnection.Close();
            catalog.ItemsSource = list;
        }

        private void deleteContent(int id,string table)
        {

            globalConnection.Open();
            
            string query = $"EXEC DeleteUniversal {id},{table}";
            SqlCommand command = new SqlCommand(query, globalConnection);
            command.ExecuteNonQuery();
            globalConnection.Close();
            refreshContent(dataGridCategories,"Categories");
        }

        private void connectButton_Click(object sender, RoutedEventArgs e)
        {
           
            try
            {
                string sqlConnString = connectionStringTextBox.Text;
                //if (sqlConnString.Length == 0) { return; }
                if (sqlConnString == "") sqlConnString = "Data Source=localhost;Initial Catalog=MusicStore;Integrated Security=True";
                globalConnection = new SqlConnection(sqlConnString + ";Trust Server Certificate=true");
                globalConnection.Open();
                
                globalConnection.Close();
                refreshAll();
                richTextBox.AppendText("\n" + "Connection Successful");
                tabCategories.Focusable = true;

                refreshContent(dataGridCategories, "Categories");

            }
            catch (Exception ex)
            {
                globalConnection.Close();
                richTextBox.AppendText("\n" + ex.Message);
            }
        }

        private void addCategoryButton_Click(object sender, RoutedEventArgs e)
        {
           
            addRecord("Category", formatProcedureArguments(categoryName.Text));
            
        }

        private void refreshProductsButton(object sender, RoutedEventArgs e)
        {
            refreshContent(dataGridProducts, "Products");
            refreshCatalog(categoryCatalog, "Categories");
            refreshCatalog(productCatalog, "Products");
        }
        private void deleteCategoryButton_Click(object sender, RoutedEventArgs e)
        {
            string id = deleteCategory.Text;
            int idint = int.Parse(id);
            deleteContent(idint,"Categories");
        }

        private void addProductButton(object sender, RoutedEventArgs e)
        {
            
            
            string t = productWarranty.Text;
            if (t == "") t = "null";
            
            addRecord("Product",formatProcedureArguments(
                categoryCatalog.Text, productName.Text,productPrice.Text, productStoredQuantity.Text, t));

            refreshContent(dataGridProducts, "Products");
        }

        private void accountRefreshButton(object sender, RoutedEventArgs e)
        {
            refreshContent(dataGridAccounts, "CustomerAccounts");
        }

        private void deleteAccount(object sender, RoutedEventArgs e)
        {
            deleteContent(int.Parse(AccountDeletionID.Text),"CustomerAccounts");
            refreshContent(dataGridAccounts, "CustomerAccounts");
        }

        private void registerUser(object sender, RoutedEventArgs e)
        {
           
            addRecord("Customer", formatProcedureArguments( AccountName.Text,AccountSurname.Text, AccountEmail.Text,
               Newsletter.IsChecked.ToString(), AccountPassword.Password, AccountPhone.Text, AccountShippingAddress.Text));
            refreshContent(dataGridAccounts, "CustomerAccounts");
        }

        private void paymentRefreshButton(object sender, RoutedEventArgs e)
        {
            refreshContent(dataGridPaymentInformation, "PaymentInformation");
            refreshCatalog(accountIdCatalog, "CustomerAccounts");
        }

        private void addPaymentMethod(object sender, RoutedEventArgs e)
        {
      
            addRecord("Payment", formatProcedureArguments(PaymentID.Text, CardNumbet.Text, CVC.Text,CardholderName.Text,
                CardholderSurname.Text, BillingAddress.Text, accountIdCatalog.Text));
            refreshContent(dataGridPaymentInformation, "PaymentInformation");
        }

        private void deletePayment(object sender, RoutedEventArgs e)
        {
            deleteContent(int.Parse(PaymentDeletionID.Text),"PaymentInformation");
            refreshContent(dataGridPaymentInformation, "PaymentInformation");
        }

        private void discountRefresh(object sender, RoutedEventArgs e)
        {
            refreshContent(dataGridDiscounts, "Discounts");
            refreshCatalog(TransactionDiscountCatalog, "Discounts");
        }

        private void addDiscount(object sender, RoutedEventArgs e)
        {
            addRecord("Discount", formatProcedureArguments(DiscountName.Text, DiscountPercentage.Text));
            refreshContent(dataGridDiscounts, "Discounts");
            refreshCatalog(TransactionDiscountCatalog, "Discounts");
        }

        private void deleteDiscount(object sender, RoutedEventArgs e)
        {
            deleteContent(int.Parse(DiscountDeletionID.Text), "Discounts");
            refreshContent(dataGridDiscounts, "Discounts");
            refreshCatalog(TransactionDiscountCatalog, "Discounts");
        }

        private void productDelete(object sender, RoutedEventArgs e)
        {
            deleteContent(int.Parse(ProductDeletionID.Text),"Products");
            refreshCatalog(productCatalog, "Products");
            refreshContent(dataGridProducts, "Products");
            refreshCatalog(TransactionProductCatalog, "Products");
        }

        private void LoadNewProducts(object sender, RoutedEventArgs e)
        {
            globalConnection.Open();
            string query = $"EXEC LoadProducts [{productCatalog.Text}],{int.Parse(ProductCountToLoad.Text)}";
            SqlCommand insert = new SqlCommand(query, globalConnection);
            insert.ExecuteNonQuery();
            globalConnection.Close();
            refreshCatalog(productCatalog, "Products");
            refreshCatalog(TransactionProductCatalog, "Products");
            refreshContent(dataGridProducts, "Products");
        }

        private void buyItem(object sender, RoutedEventArgs e)
        {
            globalConnection.Open();
            DataTable dt = new DataTable();

            string? t = TransactionDiscountCatalog.Text;
            if (t == "") t = null;

            string query = $"EXEC ExecuteTransaction [{TransactionProductCatalog.Text}], {TransactionProductCount.Text}, " +
                $"{TransactionMoney.Text}, [{TransactionEmail.Text}], [{TransactionPassword.Password}], [{TransactionDiscountCatalog.Text}]";

            SqlCommand command = new SqlCommand(query, globalConnection);
            SqlDataAdapter adapter = new SqlDataAdapter();
            adapter.SelectCommand = command;
            adapter.Fill(dt);
            dataGridTransactions.ItemsSource = dt.DefaultView;



            globalConnection.Close();



            refreshContent(dataGridProducts, "Products");
            refreshCatalog(TransactionProductCatalog, "Products");
        }

        private void buttonQuery(object sender, RoutedEventArgs e)
        {
            Button? p = sender as Button;
            refreshQuery(p.Content.ToString());
        }

        ///////////////////////////////////////////
        ///


    }
}
