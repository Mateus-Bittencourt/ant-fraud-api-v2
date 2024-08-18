 Anti-Fraud API

## 🚀 Overview
This Anti-Fraud API is designed to evaluate financial transactions and determine if they are fraudulent or not based on a set of rules and historical analysis. The API utilizes Ruby on Rails, Redis, and Sidekiq to provide an efficient and scalable solution.

* **Ruby version**: 3.1.2
* **Rails version**: 7.1.3
* **SQLite version**: 1.4
* **Redis version**: 6.0.16
* **Sidekiq version**: 6.5.0

## 💻 Installation

### Dependencies
- **Redis**: Install Redis with the following command:
  ```bash
  sudo apt-get install redis-server
  ```

### Setup
Clone this repository and install the dependencies with the following commands:
  ```bash
  bundle install
  yarn install
  ```

### Database Creation and Initialization
Run the following commands:
  ```bash
  rails db:create db:migrate
  ```

### Seed Data
To populate the database with initial data (I created a single user to implement simple JWT authentication), run:
  ```bash
  rails db:seed
  ```

### 🚀 Running the Application
Run the following commands:
  ```bash
  rails s -p 3001
  ```
  ```bash
  redis-server
  ```
  ```bash
  bundle exec sidekiq
  ```

### 📚 Using the API
Send a POST request with a payload like this:
  ```json
  {
    "transaction_id": 2342357,
    "merchant_id": 29744,
    "user_id": 97051,
    "card_number": "434505******9116",
    "transaction_date": "2019-11-31T23:16:32.812632",
    "transaction_amount": 373,
    "device_id": 285475
  }
  ```
To the endpoint:
  ```bash
  POST http://localhost:3001/transactions
  ```

Response:
  ```json
  {
    "transaction_id": 2342357,
    "recommendation": "approve"
  }
  ```

### 📚 Register a Chargeback
Send a PATCH request with the transaction_id to the endpoint:
  ```bash
  PATCH http://localhost:3001/transactions/register_chargeback
  ```
Example payload:
  ```json
  {
    "transaction_id": 2342357
  }
  ```
## 📚 Authentication
The API uses JWT (JSON Web Tokens) for authentication. When a user logs in, they receive a token that must be included in the Authorization header for subsequent requests.

### Login
To log in and receive a JWT token, send a POST request with the following payload:
  ```json
{
  "email": "mateusmbittencourt@gmail.com",
  "password": "1234"
}
  ```
Send the request to:
  ```bash
  POST http://localhost:3001/auth/login
  ```

Response:
  ```json
  {
    "token": "your_jwt_token_here"
  }
  ```

Include the received token in the Authorization header for protected endpoints:
Authorization: Bearer your_jwt_token_here


ENJOY =]
