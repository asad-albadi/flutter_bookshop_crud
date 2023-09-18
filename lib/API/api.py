from flask import Flask, jsonify,request
from flask_cors import CORS
import json
from pymongo import MongoClient
from bson import ObjectId
from datetime import datetime

mongodb_url = 'mongodb+srv://<username>:<password>@cluster0.icamb.mongodb.net/'

app = Flask(__name__)
cors = CORS(app)


def get_mongodb_data_as_json(database_name, collection_name):
    # Connect to the MongoDB server
    client = MongoClient(mongodb_url)  # Update the connection string as needed

    # Select the database
    db = client[database_name]

    # Select the collection
    collection = db[collection_name]

    # Retrieve data from the collection (you can add query conditions if needed)
    data = list(collection.find())

    # Close the MongoDB connection
    client.close()

    # Convert the data to JSON
    json_data = json.dumps(data, default=str, ensure_ascii=False).encode('utf-8')

    return json_data

def create_new_order(database_name, collection_name, order_json):
    # Parse the JSON string into a Python dictionary
    order_data = json.loads(order_json)

    # Connect to the MongoDB server
    client = MongoClient(mongodb_url)  # Update the connection string as needed

    # Select the database
    db = client[database_name]

    # Select the collection for orders
    orders_collection = db[collection_name]

    discount = order_data.get('discount', 0)
    name = order_data.get('name', 0)
    address = order_data.get('address', 0)
    phone = order_data.get('phone', 0)
    delivery_fee = order_data.get('delivery_fee', 0)
    # Create a new order document
    order_document = {
        'name': name,
        'address': address,
        'phone': phone,
        'items': order_data['items'],
        'delivery_fee': float(delivery_fee),
        'discount': float(discount),
    }

    # Insert the order document into the orders collection
    result = orders_collection.insert_one(order_document)

    # Close the MongoDB connection
    client.close()

    if result.inserted_id:
        return json.dumps({'order_id':str(result.inserted_id)} , default=str, ensure_ascii=False).encode('utf-8') 
    else:
        return json.dumps({'error':'no order_id found'} , default=str, ensure_ascii=False).encode('utf-8')  # Failed to create the order

def create_new_book(database_name, collection_name, book_json):
    # Parse the JSON string into a Python dictionary
    book_data = json.loads(book_json)

    # Connect to the MongoDB server
    client = MongoClient(mongodb_url)  # Update the connection string as needed

    # Select the database
    db = client[database_name]

    # Select the collection for orders
    books_collection = db[collection_name]

    title = book_data.get('title', 0)
    author = book_data.get('author', 0)
    genre = book_data.get('genre', [])
    cover = book_data.get('cover', 0)
    price = book_data.get('price', 0)
    count = book_data.get('count', 0)
    # Get the current timestamp
    current_time = datetime.utcnow()
    # Format the timestamp in the desired format
    formatted_time = current_time.strftime('%Y-%m-%dT%H:%M:%S.%f+00:00')
    # Create a new order document
    book_document = {
        'title': title,
        'author': author,
        'genre': genre,
        'cover': cover,
        'price': float(price),
        'count': int(count),
        'timestamp':formatted_time,
    }

    # Insert the order document into the orders collection
    result = books_collection.insert_one(book_document)

    # Close the MongoDB connection
    client.close()

    if result.inserted_id:
        return json.dumps({'book_id':str(result.inserted_id)} , default=str, ensure_ascii=False).encode('utf-8') 
    else:
        return json.dumps({'error':'no book_id found'} , default=str, ensure_ascii=False).encode('utf-8')  # Failed to create the order

def update_book(database_name, collection_name, modified_order):
    # Initialize a connection to the MongoDB server (you need to specify the connection details)
    client = MongoClient(mongodb_url) 

    modified_order = json.loads(modified_order) 
    
    # Access the database and collection
    db = client[database_name]
    collection = db[collection_name]
    
    try:
        # Extract the "_id" from the modifiedOrder and convert it to ObjectId if needed
        record_id = modified_order.get('_id')
        if isinstance(record_id, str):
            record_id = ObjectId(record_id)
        
        # Remove the _id field from the modifiedOrder before updating
        del modified_order['_id']
        
        # Update the record with the specified _id with the entire modifiedOrder
        result = collection.replace_one({"_id": record_id}, modified_order)
        print("Record updated successfully")
        return json.dumps({'updated_result':str(result)} , default=str, ensure_ascii=False).encode('utf-8') 
    except Exception as e:
        print(f"Error updating record: {str(e)}")
        return json.dumps({'error':str(e)} , default=str, ensure_ascii=False).encode('utf-8')  
    finally:
        client.close()

def analyze_database():
    # Connect to the MongoDB server
    client = MongoClient(mongodb_url)  # Update the connection string as needed

    # Select the database
    db = client['shop']

    # Select the collection
    ordersCollection = db['orders']
    booksCollection = db['books']

    # Get total orders count
    total_orders = ordersCollection.count_documents({})
    # Purpose: Calculate the total number of orders.
    # Benefits: Provides an overview of order volume.
    # Results: An integer representing the total number of orders.

    # Calculate the total revenue from orders
    cursor = ordersCollection.find({})
    total_revenue = sum(order["items"][0]["price"] * order["items"][0]["quantity"] for order in cursor)
    # Purpose: Calculate the total revenue generated from orders.
    # Benefits: Helps assess the financial performance of the business.
    # Results: A floating-point number representing the total revenue.

    # Calculate how many books were sold
    cursor = ordersCollection.find({}, projection=["items"])
    sold_books = sum(item["quantity"] for order in cursor for item in order["items"])
    # Purpose: Calculate the total quantity of books sold.
    # Benefits: Provides insights into product sales performance.
    # Results: An integer representing the total quantity of books sold.

    # Calculate the Average Order Value (AOV)
    if total_orders > 0:
        aov = total_revenue / total_orders
    else:
        aov = 0
    # Purpose: Calculate the average value of each order.
    # Benefits: Helps understand the typical order size and customer spending.
    # Results: A floating-point number representing the average order value.

    # Calculate the Top Selling Books
    cursor = ordersCollection.find({}, projection=["items"])
    book_sales = {}
    for order in cursor:
        items = order["items"]
        for item in items:
            book_id = item["item_id"]
            quantity = item["quantity"]
            if book_id in book_sales:
                book_sales[book_id] += quantity
            else:
                book_sales[book_id] = quantity
    # Purpose: Identify and count the top-selling books.
    # Benefits: Helps focus on popular products and optimize inventory.
    # Results: A dictionary with book IDs as keys and total quantities sold as values.

    # Calculate Most Frequent Customers
    cursor = ordersCollection.find({}, projection=["phone"])
    customer_orders = {}
    for order in cursor:
        customer_name = order["phone"]
        if customer_name in customer_orders:
            customer_orders[customer_name] += 1
        else:
            customer_orders[customer_name] = 1
    # Purpose: Identify and count the most frequent customers.
    # Benefits: Targeted marketing and customer retention efforts.
    # Results: A dictionary with customer names (phone numbers) as keys and order counts as values.

    # Calculate Order Frequency
    cursor = ordersCollection.find({}, projection=["phone", "_id"])
    customer_orders_timestamps = {}
    for order in cursor:
        customer_name = order["phone"]
        order_id = order["_id"]
        if customer_name in customer_orders_timestamps:
            customer_orders_timestamps[customer_name].append(order_id.generation_time.timestamp())
        else:
            customer_orders_timestamps[customer_name] = [order_id.generation_time.timestamp()]

    order_frequencies = {}
    for customer, timestamps in customer_orders_timestamps.items():
        if len(timestamps) >= 2:
            time_diffs = [timestamps[i] - timestamps[i - 1] for i in range(1, len(timestamps))]
            avg_time_diff = sum(time_diffs) / len(time_diffs)
            order_frequencies[customer] = 1 / avg_time_diff
        else:
            order_frequencies[customer] = 0
    # Purpose: Calculate the order frequency of customers.
    # Benefits: Identifying customer engagement and loyalty.
    # Results: A dictionary with customer names (phone numbers) as keys and order frequencies as values.

    # Calculate Customer Retention Rate
    retained_customers = {}
    for customer, orders in customer_orders.items():
        if orders > 1:
            retained_customers[customer] = orders
    customer_retention_rate = len(retained_customers) / len(customer_orders) if len(customer_orders) > 0 else 0
    # Purpose: Determine the percentage of retained customers.
    # Benefits: Measure customer loyalty and business sustainability.
    # Results: A floating-point number representing the customer retention rate.

    # Sales by Genre from the 'books' collection
    sales_by_genre = {}
    cursor = ordersCollection.find({}, projection=["items"])
    for order in cursor:
        items = order["items"]
        for item in items:
            item_id_str = item["item_id"]  # Assuming item_id in orders is a string
            quantity = item["quantity"]
            # Convert item_id_str to ObjectId
            item_id_obj = ObjectId(item_id_str)
            # Fetch genre information from the 'books' collection using item_id as ObjectId
            book_info = booksCollection.find_one({"_id": item_id_obj}, projection=["genre"])
            if book_info:
                genres = str(book_info.get("genre", [])).split('،')
                for genre in genres:
                    # Ensure genre is properly decoded to Unicode
                    decoded_genre = genre.decode('utf-8') if isinstance(genre, bytes) else genre
                    if decoded_genre in sales_by_genre:
                        sales_by_genre[decoded_genre] += quantity
                    else:
                        sales_by_genre[decoded_genre] = quantity
    # Purpose: Analyze sales performance by book genre.
    # Benefits: Identify popular genres and adjust product offerings.
    # Results: A dictionary with genre names as keys and total quantities sold as values.

    # Geographic Analysis (Assuming customer locations are available)
    cursor = ordersCollection.find({}, projection=["address"])
    customer_locations = {}
    for order in cursor:
        address = order.get("address")
        if address:
            if address in customer_locations:
                customer_locations[address] += 1
            else:
                customer_locations[address] = 1
    # Purpose: Analyze customer distribution by geographic location.
    # Benefits: Target marketing campaigns and optimize shipping.
    # Results: A dictionary with addresses as keys and customer counts as values.

    # Time-Based Trends
    cursor = ordersCollection.find({}, projection=["_id"])
    order_timestamps = []
    for order in cursor:
        order_id = order["_id"]
        order_timestamps.append(order_id.generation_time.timestamp())

    time_based_trends = {
        "oldest_order": datetime.utcfromtimestamp(min(order_timestamps)).strftime("%Y-%m-%d %H:%M:%S"),
        "newest_order": datetime.utcfromtimestamp(max(order_timestamps)).strftime("%Y-%m-%d %H:%M:%S"),
    }
    # Purpose: Identify the oldest and newest orders.
    # Benefits: Monitor trends in order placement over time.
    # Results: A dictionary with timestamps of the oldest and newest orders.

    # Inventory Management (Assuming inventory data is available in the 'books' collection)
    inventory_management = {}
    for item in booksCollection.find({}, projection=["_id", "count"]):
        item_id = str(item["_id"])
        current_stock = item.get("count", 0)
        inventory_management[item_id] = current_stock
    # Purpose: Manage and monitor inventory levels for each book.
    # Benefits: Avoid stockouts and overstock situations.
    # Results: A dictionary with book IDs as keys and current stock counts as values.

    # Customer Segmentation (Assuming you have segmentation data)
    # Example: Categorize customers into segments based on their order history or demographics

    # Customer Lifetime Value (CLV) Calculation (Assuming you have customer lifetime data)
    # Example: Calculate the CLV for each customer based on their historical purchase behavior

    # Create a dictionary to store statistics
    statistics = {
        "total_orders": total_orders,
        "total_revenue": total_revenue,
        "sold_books": sold_books,
        "average_order_value": aov,
        "top_selling_books": book_sales,
        "most_frequent_customers": customer_orders,
        "order_frequencies": order_frequencies,
        "customer_retention_rate": customer_retention_rate,
        "sales_by_genre": sales_by_genre,
        "customer_locations": customer_locations,
        "time_based_trends": time_based_trends,
        "inventory_management": inventory_management,
        # Add Customer Segmentation and CLV here
    }

    # Create dictionaries to store monthly sales data
    monthly_orders = {}
    monthly_sold_books = {}

    cursor = ordersCollection.find({}, projection=["_id", "items"])
    for order in cursor:
        order_id = order["_id"]
        items = order["items"]
        order_month = datetime.utcfromtimestamp(order_id.generation_time.timestamp()).strftime("%Y-%m")

        # Count the order in the respective month
        if order_month in monthly_orders:
            monthly_orders[order_month] += 1
        else:
            monthly_orders[order_month] = 1

        # Count the sold books in the respective month
        if order_month in monthly_sold_books:
            monthly_sold_books[order_month] += sum(item["quantity"] for item in items)
        else:
            monthly_sold_books[order_month] = sum(item["quantity"] for item in items)

    statistics["monthly_orders"] = monthly_orders
    statistics["monthly_sold_books"] = monthly_sold_books

    # Close the MongoDB connection
    client.close()

    # Return the statistics as JSON
    return json.dumps(statistics, default=str, ensure_ascii=False)

@app.route('/get_data', methods=['GET'])
def get_data():
    return get_mongodb_data_as_json('shop', 'books')

@app.route('/create_order', methods=['POST'])
def create_order():
    order_data = request.form.get('order_data')
    print(order_data)
    return create_new_order('shop', 'orders',str(order_data))

@app.route('/get_orders', methods=['GET'])
def get_orders():
    return get_mongodb_data_as_json('shop', 'orders')

@app.route('/create_book', methods=['POST'])
def create_book():
    book_data = request.form.get('book_data')
    print(book_data)
    return create_new_book('shop', 'books',str(book_data))

@app.route('/modify_book', methods=['POST'])
def modify_book():
    book_data = request.form.get('book_data')
    print(book_data)
    return update_book('shop', 'books',str(book_data))

@app.route('/get_summary', methods=['GET'])
def get_summary():
    return analyze_database()

cors = CORS(app, origins=["http://192.168.100.64:34173/"],
            methods=["GET", "POST"]) 
app.run(host='192.168.100.64')