# House of Wisdom Bookshop Management System

## Table of Contents

1. [Introduction](#introduction)
2. [Features](#features)
3. [Prerequisites](#prerequisites)
4. [Installation](#installation)
5. [Configuration](#configuration)
6. [Usage](#usage)
7. [API Endpoints](#api-endpoints)
8. [Contributing](#contributing)
9. [License](#license)
10. [About the Author](#about-the-author)

## Introduction

The House of Wisdom Bookshop Management System is a comprehensive solution designed to help bookshop owners manage their inventory, orders, and sales efficiently. This system consists of two main components: a Flutter-based web application for the frontend and a Flask-based API for the backend. This README provides a detailed guide on how to set up, configure, and use the system effectively.

## Features

### Dashboard

- View detailed summaries, graphical representations, and analytics of your bookshop's performance.

### Book List

- Browse and manage the list of books in a visually appealing card grid format.
- Filter books by genre, search by title or author.
- Create new books or update existing book information.
- View detailed book information, including title, author, genre, price, quantity, and cover image.

### Orders

- Keep track of customer orders efficiently.
- View a list of orders placed by customers.
- Create new orders on behalf of customers.

## Prerequisites

Before you begin, make sure you have the following prerequisites in place:

- Flutter Web Development Environment
- Python and Flask for the API
- Nginx or another web server for hosting the frontend
- MongoDB Atlas account (for hosting data)

## Installation

### Frontend (Flutter Web Application)

1. Install Flutter dependencies:

   ```shell
   flutter pub get
   ```
4. Build and deploy the Flutter web app to your hosting server.

### Backend (Flask API)

1. Install the required Python packages:

   ```shell
   pip install Flask pymongo bson
   ```
2. Configure the MongoDB connection:

   - Replace `<username>` and `<password>` in the `mongodb_url` variable with your MongoDB Atlas credentials.
3. Start the Flask API:

   ```shell
   python api.py
   ```

## Configuration

Configure the system to match your specific environment and requirements:

- [Explain how to configure the Flask API, database, environment variables, etc.]

## Usage

To start using the House of Wisdom Bookshop Management System:

1. Access the Flutter web application hosted on your server through your web browser.
2. Use the dashboard, book list, and order features to manage your bookshop efficiently.

## API Endpoints

### Get All Books

- **Endpoint**: `/get_books`
- **Method**: GET
- **Description**: Retrieves a list of all books in the bookshop.

### Create New Order

- **Endpoint**: `/create_order`
- **Method**: POST
- **Description**: Creates a new order in the bookshop system.
- **Request Body**: JSON data containing order details.

### Get All Orders

- **Endpoint**: `/get_orders`
- **Method**: GET
- **Description**: Retrieves a list of all orders placed by customers.

### Create New Book

- **Endpoint**: `/create_book`
- **Method**: POST
- **Description**: Creates a new book entry in the bookshop's inventory.
- **Request Body**: JSON data containing book details.

### Modify Book

- **Endpoint**: `/modify_book`
- **Method**: POST
- **Description**: Modifies an existing book's details.
- **Request Body**: JSON data containing modified book details.

## Contributing

If you would like to contribute to this project, follow these steps:

1. Fork the repository.
2. Create a new branch for your feature or bugfix.
3. Make your changes and test thoroughly.
4. Create a pull request with a clear description of your changes.

## License

This project is not licensed, meaning there are no specific usage restrictions or obligations. However, it's encouraged to follow best practices and give credit where appropriate when using or modifying this code.

## About the Author

**Asad Al Badi**

- GitHub: [GitHub Profile](https://github.com/asad-albadi)
- LinkedIn: [LinkedIn Profile](https://www.linkedin.com/in/asadalbadi/)
- Email: [asad.albadi0@gmail.com]
