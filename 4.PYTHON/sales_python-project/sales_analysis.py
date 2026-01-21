import mysql.connector
import pandas as pd

# MySQL connection
conn = mysql.connector.connect(
    host="localhost",
    user="powerbi_user",
    password="PowerBI@123",
    database="sales"
)

print("MySQL connected successfully")

# Load tables
orders_df = pd.read_sql("SELECT * FROM orders", conn)
customers_df = pd.read_sql("SELECT * FROM customers", conn)
products_df = pd.read_sql("SELECT * FROM products", conn)

print("\nOrders table preview:")
print(orders_df.head())

print("\nCustomers table preview:")
print(customers_df.head())

print("\nProducts table preview:")
print(products_df.head())


# Merge orders with customers
sales_df = pd.merge(
    orders_df,
    customers_df,
    on="customer_id",
    how="left"
)

# Merge with products
sales_df = pd.merge(
    sales_df,
    products_df,
    on="product_id",
    how="left"
)

print("\nMerged Sales Data:")
print(sales_df.head())


# ---------------- KPI CALCULATIONS ----------------

# Total Sales
total_sales = sales_df["sales"].sum()
print("\nTotal Sales:", total_sales)

# Total Orders
total_orders = sales_df["order_id"].nunique()
print("Total Orders:", total_orders)

# Total Customers
total_customers = sales_df["customer_id"].nunique()
print("Total Customers:", total_customers)

# ---------------- TOP 5 CUSTOMERS ----------------

top_customers = (
    sales_df
    .groupby("customer_name")["sales"]
    .sum()
    .sort_values(ascending=False)
    .head(5)
)

print("\nTop 5 Customers by Sales:")
print(top_customers)


# ---------------- SALES BY PRODUCT ----------------

product_sales = (
    sales_df
    .groupby("product_name")["sales"]
    .sum()
    .sort_values(ascending=False)
)

print("\nSales by Product:")
print(product_sales)

import matplotlib.pyplot as plt

# ---------------- BAR CHART: TOP 5 CUSTOMERS ----------------

top_customers.plot(kind="bar")
plt.title("Top 5 Customers by Sales")
plt.xlabel("Customer Name")
plt.ylabel("Total Sales")
plt.tight_layout()
plt.show()


# ---------------- LINE CHART: SALES TREND ----------------

sales_by_date = (
    sales_df
    .groupby("order_date")["sales"]
    .sum()
    .sort_index()
)

sales_by_date.plot()
plt.title("Sales Trend Over Time")
plt.xlabel("Order Date")
plt.ylabel("Total Sales")
plt.tight_layout()
plt.show()


