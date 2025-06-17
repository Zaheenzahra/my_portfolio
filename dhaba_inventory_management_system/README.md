# Dhaba Inventory Management System

A lightweight and offline-first inventory and billing solution tailored for local food stalls and small restaurants (dhabas), built using **Flutter**. This system helps digitize stock tracking, sales recording, and billing operations — making day-to-day management easier, faster, and more accurate.


## Features

✅ **Inventory Management**  
- Add, edit, and delete food items like *shami*, *burgers*, *dahi bhale*, etc.  
- Track available stock with automatic low-stock alerts.  

✅ **Billing System**  
- Select items and generate bills instantly.  
- Each bill updates inventory and logs the sale offline.  

✅ **Sales Tracking**  
- Automatically store and track all sales using Hive.  
- View daily and weekly sales insights.

✅ **Dashboard with Charts**  
- Visual representation of stock and sales.  
- Identify best-selling items and low stock at a glance.

✅ **Offline Support with Hive**  
- All data is saved locally — no internet required.  
- Fast, secure, and suitable for remote or low-connectivity environments.

✅ **State Management with Provider**  
- Smooth and reactive UI updates using Provider for state control.


## Tech Stack

| Layer         | Technology        |
|---------------|-------------------|
| Frontend      | Flutter (Web + Windows Desktop) |
| Local Storage | Hive              |
| State Mgmt.   | Provider          |
| UI Components | DataTable, Charts, Drawer Navigation |


## 📸 Screenshots



## 📁 Project Structure

lib/
├── models/        # Product, Inventory, Bill, Activity, and Sale models

├── providers/     # Inventory, Billing, and Sales providers

├── routes/        # App routes

├── screens/       # Inventory, Billing, Dashboard, Sales screens

├── widgets/       # Reusable components

└── main.dart      # Entry point

## About

This project was built to help digitize and simplify the daily operations of my father's local **dhaba**. From real-time stock tracking to offline billing, it empowers small business owners with a practical and easy-to-use digital system.


##  How to Run

1. Clone the repository:
   
   git clone https://github.com/yourusername/dhaba_inventory_management_system.git
   
   cd dhaba_inventory_management_system
   
Get dependencies:

flutter pub get

Run on Web or Windows:

flutter run -d chrome   # for web 

flutter build windows   # for Windows (enable developer mode)

Contributions

Pull requests are welcome. Feel free to fork the project and suggest improvements.

Built with in Flutter by Zaheen Zahra
