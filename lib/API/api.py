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

cors = CORS(app, origins=["http://192.168.100.64:34173/"],
            methods=["GET", "POST"]) 
app.run(host='192.168.100.64')