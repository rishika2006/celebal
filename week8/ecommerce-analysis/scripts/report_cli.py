import sqlite3
from datetime import datetime, timedelta
from pathlib import Path
BASE_DIR = Path(__file__).resolve().parent.parent

DATABASE_PATH = BASE_DIR / "database" / "ecommerce.db"


def create_connection():
    return sqlite3.connect(DATABASE_PATH)

def get_user_input():

    print("\n===== Ecommerce Analytics Report =====")

    report_type = input(
        "Enter Report Type (daily/weekly/monthly): "
    ).strip().lower()

    start_date = input(
        "Enter Start Date (YYYY-MM-DD): "
    )

    end_date = input(
        "Enter End Date (YYYY-MM-DD): "
    )

    return report_type, start_date, end_date

def validate_dates(start_date, end_date):

    formats = ["%Y-%m-%d", "%d-%m-%Y"]

    start = None
    end = None

    for fmt in formats:
        try:
            start = datetime.strptime(start_date, fmt)
            break
        except ValueError:
            continue

    for fmt in formats:
        try:
            end = datetime.strptime(end_date, fmt)
            break
        except ValueError:
            continue

    if start is None or end is None:
        raise ValueError(
            "Invalid date format. Use YYYY-MM-DD or DD-MM-YYYY."
        )

    if start > end:
        raise ValueError(
            "Start Date cannot be after End Date."
        )

    return start, end

def previous_period(start, end):

    days = (end - start).days + 1

    previous_end = start - timedelta(days=1)

    previous_start = previous_end - timedelta(days=days - 1)

    return previous_start, previous_end

def total_orders(cursor, start, end):

    cursor.execute("""

        SELECT COUNT(*)

        FROM orders

        WHERE DATE(order_date)

        BETWEEN ? AND ?

    """,

    (start, end))

    return cursor.fetchone()[0]

def total_revenue(cursor, start, end):

    cursor.execute("""

        SELECT

        ROUND(

            SUM(

                oi.quantity *

                oi.unit_price *

                (1 - oi.discount_percent/100.0)

            ),

            2

        )

        FROM orders o

        JOIN order_items oi

        ON o.order_id = oi.order_id

        WHERE DATE(o.order_date)

        BETWEEN ? AND ?

    """,

    (start, end))

    result = cursor.fetchone()[0]

    return result if result else 0

def unique_customers(cursor, start, end):

    cursor.execute("""

        SELECT

        COUNT(DISTINCT customer_id)

        FROM orders

        WHERE DATE(order_date)

        BETWEEN ? AND ?

    """,

    (start, end))

    return cursor.fetchone()[0]

def top_products(cursor, start, end):

    cursor.execute("""

        SELECT

            p.product_name,

            SUM(oi.quantity) AS total_quantity

        FROM products p

        JOIN order_items oi

            ON p.product_id = oi.product_id

        JOIN orders o

            ON oi.order_id = o.order_id

        WHERE DATE(o.order_date)

        BETWEEN ? AND ?

        GROUP BY

            p.product_name

        ORDER BY

            total_quantity DESC

        LIMIT 3

    """,

    (start, end))

    return cursor.fetchall()

def revenue_change(current, previous):

    if previous == 0:

        return None

    return round(

        ((current - previous) / previous) * 100,

        2

    )

def print_report(

    report_type,

    start,

    end,

    orders,

    revenue,

    customers,

    products,

    change

):

    print("\n")

    print("=" * 45)

    print("        ECOMMERCE REPORT")

    print("=" * 45)

    print(f"Report Type       : {report_type.title()}")

    print(f"Period            : {start} to {end}")

    print(f"Total Orders      : {orders}")

    print(f"Total Revenue     : {revenue}")

    print(f"Unique Customers  : {customers}")

    print()

    print("Top 3 Products")

    print("-" * 30)

    for name, qty in products:

        print(f"{name:<25}{qty}")

    print()

    if change is None:

        print("Revenue Change    : N/A")

    else:

        print(f"Revenue Change    : {change}%")

    print("=" * 45)

def main():

    report_type, start_date, end_date = get_user_input()

    start, end = validate_dates(
        start_date,
        end_date
    )

    previous_start, previous_end = previous_period(
        start,
        end
    )

    connection = create_connection()

    cursor = connection.cursor()

    current_orders = total_orders(
        cursor,
        start_date,
        end_date
    )

    current_revenue = total_revenue(
        cursor,
        start_date,
        end_date
    )

    current_customers = unique_customers(
        cursor,
        start_date,
        end_date
    )

    products = top_products(
        cursor,
        start_date,
        end_date
    )

    previous_revenue = total_revenue(

        cursor,

        previous_start.strftime("%Y-%m-%d"),

        previous_end.strftime("%Y-%m-%d")

    )

    change = revenue_change(

        current_revenue,

        previous_revenue

    )

    print_report(

        report_type,

        start_date,

        end_date,

        current_orders,

        current_revenue,

        current_customers,

        products,

        change

    )

    connection.close()


if __name__ == "__main__":

    main()
