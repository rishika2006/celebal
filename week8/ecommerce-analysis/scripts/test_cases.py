import sqlite3
from pathlib import Path
from datetime import datetime


BASE_DIR = Path(__file__).resolve().parent.parent
DATABASE_PATH = BASE_DIR / "database" / "ecommerce.db"


def create_connection():
    return sqlite3.connect(DATABASE_PATH)


# ============================================================
# Test 1
# Invalid Order Reference
# ============================================================

def test_invalid_order_reference():

    connection = create_connection()
    cursor = connection.cursor()

    cursor.execute("""

        SELECT COUNT(*)

        FROM order_items oi

        LEFT JOIN orders o

        ON oi.order_id = o.order_id

        WHERE o.order_id IS NULL

    """)

    count = cursor.fetchone()[0]

    if count == 0:

        print("PASS : No invalid order references found.")

    else:

        print(f"FAIL : {count} invalid order reference(s) found.")

    connection.close()


# ============================================================
# Test 2
# Discount > 100%
# ============================================================

def test_discount_greater_than_100():

    connection = create_connection()
    cursor = connection.cursor()

    cursor.execute("""

        SELECT COUNT(*)

        FROM order_items

        WHERE discount_percent > 100

    """)

    count = cursor.fetchone()[0]

    if count == 0:

        print("PASS : All discounts are valid.")

    else:

        print(f"FAIL : {count} invalid discount(s) found.")

    connection.close()


# ============================================================
# Test 3
# Quantity = 0
# ============================================================

def test_zero_quantity():

    connection = create_connection()
    cursor = connection.cursor()

    cursor.execute("""

        SELECT COUNT(*)

        FROM order_items

        WHERE quantity = 0

    """)

    count = cursor.fetchone()[0]

    if count == 0:

        print("PASS : No zero quantity records.")

    else:

        print(f"FAIL : {count} zero quantity record(s) found.")

    connection.close()


# ============================================================
# Test 4
# Future Order Date
# ============================================================

def test_future_order_date():

    connection = create_connection()
    cursor = connection.cursor()

    today = datetime.today().strftime("%Y-%m-%d")

    cursor.execute("""

        SELECT COUNT(*)

        FROM orders

        WHERE DATE(order_date) > DATE(?)

    """, (today,))

    count = cursor.fetchone()[0]

    if count == 0:

        print("PASS : No future order dates.")

    else:

        print(f"FAIL : {count} future order(s) found.")

    connection.close()


# ============================================================
# Run All Tests
# ============================================================

def run_all_tests():

    print("\n======================================")
    print("Running Data Validation Test Cases")
    print("======================================\n")

    test_invalid_order_reference()

    test_discount_greater_than_100()

    test_zero_quantity()

    test_future_order_date()

    print("\n======================================")
    print("Testing Completed")
    print("======================================\n")


if __name__ == "__main__":
    run_all_tests()