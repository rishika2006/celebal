import pandas as pd
import os
import re

RAW_PATH = "data/raw/"
CLEAN_PATH = "data/cleaned/"

os.makedirs(CLEAN_PATH, exist_ok=True)


issues_report = []

# Clean Orders

def clean_orders():


    orders_df = pd.read_csv(RAW_PATH + "orders.csv")

    wrong_date_count = 0
    null_customer_count = 0

    cleaned_dates = []

    for date in orders_df["order_date"]:

        parsed_date = None

        # Try YYYY-MM-DD
        try:
            parsed_date = pd.to_datetime(
                date,
                format="%Y-%m-%d %H:%M:%S"
            )
        except:
            pass

        # Try DD-MM-YYYY
        if parsed_date is None:
            try:
                parsed_date = pd.to_datetime(
                    date,
                    format="%d-%m-%Y %H:%M:%S"
                )
                wrong_date_count += 1
            except:
                parsed_date = pd.NaT

        cleaned_dates.append(parsed_date)

    orders_df["order_date"] = cleaned_dates

    # Convert back to standard format
    orders_df["order_date"] = (
        orders_df["order_date"]
        .dt.strftime("%Y-%m-%d %H:%M:%S")
    )

    # Handle Missing Customer IDs

    null_customer_count = (
        orders_df["customer_id"]
        .isna()
        .sum()
    )

    empty_customer_count = (
        orders_df["customer_id"]
        .astype(str)
        .str.strip()
        .eq("")
        .sum()
    )

    orders_df["customer_id"] = (
        orders_df["customer_id"]
        .fillna("UNKNOWN")
    )

    orders_df.loc[
        orders_df["customer_id"].astype(str).str.strip() == "",
        "customer_id"
    ] = "UNKNOWN"

    # Save Clean File

    orders_df.to_csv(
        CLEAN_PATH + "orders.csv",
        index=False
    )

    # Update Report

    issues_report.append(
        f"Wrong Date Formats Fixed : {wrong_date_count}"
    )

    issues_report.append(
        f"Missing Customer IDs : {null_customer_count + empty_customer_count}"
    )

# Clean Products

def clean_products():


    products_df = pd.read_csv(RAW_PATH + "products.csv")

    normalized_count = 0

    cleaned_names = []

    for name in products_df["product_name"]:

        original = name

        # Remove leading/trailing spaces
        name = str(name).strip()

        # Convert to Title Case
        name = name.title()

        if original != name:
            normalized_count += 1

        cleaned_names.append(name)

    products_df["product_name"] = cleaned_names

    # Save cleaned file
    products_df.to_csv(
        CLEAN_PATH + "products.csv",
        index=False
    )

    issues_report.append(
        f"Product Names Normalized : {normalized_count}"
    )

# Validate Customer Emails

def validate_emails():

    customers_df = pd.read_csv(RAW_PATH + "customers.csv")
    unknown_customer = {
    "customer_id": "UNKNOWN",
    "customer_name": "Unknown Customer",
    "email": "unknown@example.com",
    "registration_date": "2024-01-01",
    "customer_type": "Unknown"
}

    if "UNKNOWN" not in customers_df["customer_id"].values:
        customers_df = pd.concat(
        [customers_df, pd.DataFrame([unknown_customer])],
        ignore_index=True
        )

    # Basic email regex
    email_pattern = r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'

    invalid_customers = []

    for _, row in customers_df.iterrows():

        email = str(row["email"]).strip()

        if not re.match(email_pattern, email):

            invalid_customers.append(row["customer_id"])

    issues_report.append(
    f"Invalid Emails Found : {len(invalid_customers)}"
)

# Save validated customers
    customers_df.to_csv(
    CLEAN_PATH + "customers.csv",
    index=False
    )

    return invalid_customers

# Check Referential Integrity

def check_referential_integrity():


    orders_df = pd.read_csv(CLEAN_PATH + "orders.csv")
    products_df = pd.read_csv(CLEAN_PATH + "products.csv")
    order_items_df = pd.read_csv(RAW_PATH + "order_items.csv")

    valid_orders = set(orders_df["order_id"])

    valid_products = set(products_df["product_id"])

    invalid_orders = []

    invalid_products = []

    for _, row in order_items_df.iterrows():

        if row["order_id"] not in valid_orders:

            invalid_orders.append(row["item_id"])

        if row["product_id"] not in valid_products:

            invalid_products.append(row["item_id"])

    issues_report.append(
        f"Invalid Order References : {len(invalid_orders)}"
    )

    issues_report.append(
    f"Invalid Product References : {len(invalid_products)}"
    )

    # Save validated order items
    order_items_df.to_csv(
    CLEAN_PATH + "order_items.csv",
    index=False
    )

    return invalid_orders, invalid_products

# Save Issues Report

def save_report():

    os.makedirs("reports", exist_ok=True)

    with open("reports/issues_report.txt", "w") as report:

        report.write("=" * 50 + "\n")
        report.write("DATA CLEANING REPORT\n")
        report.write("=" * 50 + "\n\n")

        for issue in issues_report:

            report.write(issue + "\n")


def main():

    clean_orders()

    clean_products()

    invalid_emails = validate_emails()

    invalid_orders, invalid_products = check_referential_integrity()

    save_report()

   

if __name__ == "__main__":
    main()