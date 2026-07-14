import random
import pandas as pd
from faker import Faker


fake = Faker()

random.seed(42)
Faker.seed(42)

# Generate Customers

def generate_customers():

    customers = []

    customer_types = ["REGULAR", "PREMIUM", "VIP"]

    for i in range(1, 501):

        # Customer Name
        name = fake.name()

        # Introduce inconsistent casing in ~3%
        if random.random() < 0.03:

            if random.choice([True, False]):
                name = name.upper()
            else:
                name = name.lower()

        # Email
        email = fake.email()

        # Introduce invalid emails in ~2%
        if random.random() < 0.02:

            issue = random.choice([1, 2, 3])

            if issue == 1:
                email = email.replace("@", "")

            elif issue == 2:
                email = email.split("@")[0] + "@"

            else:
                email = email.replace(".com", "")

        customer = {

            "customer_id": f"CUST{i:04d}",

            "customer_name": name,

            "email": email,

            "registration_date": fake.date_between(
                start_date="-3y",
                end_date="today"
            ),

            "customer_type": random.choices(
                customer_types,
                weights=[70, 20, 10],
                k=1
            )[0]

        }

        customers.append(customer)

    customers_df = pd.DataFrame(customers)

    customers_df.to_csv(
        "data/raw/customers.csv",
        index=False
    )


# Generate Products

def generate_products():

    products = []

    categories = {

        "Electronics": [
            "Laptop",
            "Mobile Phone",
            "Keyboard",
            "Mouse",
            "Monitor",
            "Speaker",
            "Headphones"
        ],

        "Clothing": [
            "T-Shirt",
            "Jeans",
            "Jacket",
            "Dress",
            "Hoodie",
            "Shoes"
        ],

        "Home": [
            "Chair",
            "Table",
            "Sofa",
            "Lamp",
            "Curtains",
            "Bed"
        ],

        "Books": [
            "Novel",
            "Biography",
            "Cookbook",
            "Science Book",
            "History Book"
        ],

        "Sports": [
            "Football",
            "Cricket Bat",
            "Tennis Racket",
            "Yoga Mat",
            "Dumbbell"
        ],

        "Beauty": [
            "Face Wash",
            "Lipstick",
            "Perfume",
            "Shampoo",
            "Moisturizer"
        ]

    }

    for i in range(1, 501):

        category = random.choice(list(categories.keys()))

        subcategory = random.choice(categories[category])

        product_name = subcategory

        # Introduce formatting issues

        chance = random.random()

        if chance < 0.03:

            product_name = "  " + product_name + "  "

        elif chance < 0.06:

            product_name = product_name.swapcase()

        elif chance < 0.09:

            product_name = product_name.lower()

        cost_price = random.randint(100, 5000)

        product = {

            "product_id": f"PROD{i:04d}",

            "product_name": product_name,

            "category": category,

            "subcategory": subcategory,

            "cost_price": cost_price

        }

        products.append(product)

    products_df = pd.DataFrame(products)

    products_df.to_csv(
        "data/raw/products.csv",
        index=False
    )


# Generate Orders

def generate_orders():

    # Read customers.csv
    customers_df = pd.read_csv("data/raw/customers.csv")

    customer_ids = customers_df["customer_id"].tolist()

    statuses = [
        "PLACED",
        "SHIPPED",
        "DELIVERED",
        "CANCELLED",
        "RETURNED"
    ]

    regions = [
        "NORTH",
        "SOUTH",
        "EAST",
        "WEST"
    ]

    orders = []

    for i in range(1, 501):

        customer_id = random.choice(customer_ids)

        # 5% Missing Customer IDs
        if random.random() < 0.05:

            customer_id = random.choice([None, ""])

        order_date = fake.date_time_between(
            start_date="-2y",
            end_date="now"
        )

        # Some wrong date formats
        if random.random() < 0.05:

            order_date = order_date.strftime("%d-%m-%Y %H:%M:%S")

        else:

            order_date = order_date.strftime("%Y-%m-%d %H:%M:%S")

        order = {

            "order_id": f"ORD{i:05d}",

            "customer_id": customer_id,

            "order_date": order_date,

            "status": random.choice(statuses),

            "region_code": random.choice(regions)

        }

        orders.append(order)

    orders_df = pd.DataFrame(orders)

    orders_df.to_csv(
        "data/raw/orders.csv",
        index=False
    )

# Order items
# -----------------------------
# Generate Order Items
# -----------------------------
def generate_order_items():

    # Read Orders and Products
    orders_df = pd.read_csv("data/raw/orders.csv")
    products_df = pd.read_csv("data/raw/products.csv")

    order_ids = orders_df["order_id"].tolist()

    products = products_df.to_dict("records")

    order_items = []

    NUM_ORDER_ITEMS = 800

    for i in range(1, NUM_ORDER_ITEMS + 1):

        # Select random order
        order_id = random.choice(order_ids)

        # Select random product
        product = random.choice(products)

        product_id = product["product_id"]

        cost_price = product["cost_price"]

        # Selling price (20% - 80% markup)
        unit_price = round(
            cost_price * random.uniform(1.2, 1.8),
            2
        )

        # Quantity
        quantity = random.randint(1, 5)

        # 3% Negative Quantity (Returns)
        if random.random() < 0.03:
            quantity = -quantity

        # Discount
        discount = random.randint(0, 50)

        # Few invalid discounts (>100)
        if random.random() < 0.02:
            discount = random.randint(101, 130)

        item = {

            "item_id": f"ITEM{i:05d}",

            "order_id": order_id,

            "product_id": product_id,

            "quantity": quantity,

            "unit_price": unit_price,

            "discount_percent": discount

        }

        order_items.append(item)

    order_items_df = pd.DataFrame(order_items)

    order_items_df.to_csv(
        "data/raw/order_items.csv",
        index=False
    )


def main():

    generate_customers()

    generate_products()

    generate_orders()
    
    generate_order_items()




if __name__ == "__main__":
    main()