import os
import sqlite3
import pandas as pd

DATABASE_PATH = "database/ecommerce.db"
SCHEMA_PATH = "sql/schema.sql"
CLEAN_DATA_PATH = "data/cleaned"


def create_connection():
    os.makedirs("database", exist_ok=True)

    connection = sqlite3.connect(DATABASE_PATH)
    connection.execute("PRAGMA foreign_keys = ON")

    return connection


def execute_schema(connection):

    with open(SCHEMA_PATH, "r") as file:
        schema = file.read()

    connection.executescript(schema)
    connection.commit()


def load_data(connection):

    customers = pd.read_csv(f"{CLEAN_DATA_PATH}/customers.csv")
    products = pd.read_csv(f"{CLEAN_DATA_PATH}/products.csv")
    orders = pd.read_csv(f"{CLEAN_DATA_PATH}/orders.csv")
    order_items = pd.read_csv(f"{CLEAN_DATA_PATH}/order_items.csv")

    customers.to_sql(
        "customers",
        connection,
        if_exists="append",
        index=False
    )

    products.to_sql(
        "products",
        connection,
        if_exists="append",
        index=False
    )

    orders.to_sql(
        "orders",
        connection,
        if_exists="append",
        index=False
    )

    order_items.to_sql(
        "order_items",
        connection,
        if_exists="append",
        index=False
    )

    connection.commit()


def verify_data(connection):

    cursor = connection.cursor()

    tables = [
        "customers",
        "products",
        "orders",
        "order_items"
    ]

    print("\nRow Count Verification")
    print("-" * 30)

    for table in tables:

        cursor.execute(f"SELECT COUNT(*) FROM {table}")

        count = cursor.fetchone()[0]

        print(f"{table:<15}{count}")


def main():

    connection = create_connection()

    execute_schema(connection)

    load_data(connection)

    verify_data(connection)

    connection.close()


if __name__ == "__main__":
    main()