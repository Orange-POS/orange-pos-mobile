# OrangePOS Mobile Inventory Tracker – MVP

## Overview

OrangePOS Mobile Inventory Tracker is a Flutter-based mobile application designed for shop owners and POS users to quickly manage products directly from mobile devices.

The application connects securely with the Odoo POS system using QR-code-based authentication and temporary JWT access tokens. Users can scan products from shelves using their mobile camera and perform product-related operations without directly accessing the POS terminal.

The goal of this MVP is to provide a simple, secure, and fast mobile workflow for inventory and price updates.

---

## Finished Setup

* Created real Flutter project inside `flutter_app`
* Built UI based on uploaded PDF design
* Created clean folder structure:

```text
lib/
  app/
  config/
  models/
  screens/
  services/
  widgets/
```

* Split large `main.dart` into separate files
* Added `Product` model
* Added `QrLoginData` model

### Added Packages

```text
mobile_scanner
http
flutter_secure_storage
```

### Platform Configuration

* Added Android internet permission
* Enabled cleartext HTTP for local Odoo development

---

## Completed App Features

### Authentication

* Login screen based on PDF design
* Real QR camera scanner for Odoo POS login QR
* QR JSON parsing
* QR expiry validation
* Invalid QR handling
* Expired QR handling
* Successful QR login flow
* Fake JWT token generation through `AuthService`
* Secure token saving using `TokenStorage`
* Splash screen session check
* Logout flow from profile icon

### Product Management

* Scanner screen based on PDF design
* Real barcode scanner screen
* Barcode scan result passed back to scanner screen
* Product search flow using fake `ProductService`
* Empty product result UI
* Product detail screen
* Change product name dialog
* Change product price dialog
* Product update through service layer
* Updated product is passed back to scanner screen

### Application Behavior

* Loading states
* Error message handling

---

## Current App Status

The application is currently a working Flutter prototype with real QR scanning, barcode scanning, secure token storage, and a clean architecture.

### Current Flow

```text
Splash Screen
-> Login Screen
-> Scan Odoo QR
-> Validate QR format and expiry
-> Save fake JWT token securely
-> Scanner Screen
-> Scan product barcode
-> Show fake product result
-> Open product
-> Change name or price
-> Return updated product to scanner
-> Logout
```

At the moment, backend APIs are not connected. Service layers are prepared and currently use mock data to simulate the final integration.

---

## Pending Work

### Authentication Integration

* Get real Odoo endpoint URLs
* Enable real QR login API in `AuthService`
* Parse real JWT response from Odoo
* Handle token expiry properly

### Product API Integration

* Enable real product barcode search API in `ProductService`
* Enable real product name update API
* Enable real product price update API
* Confirm final backend request and response JSON formats

### UI Improvements

* Improve UI styling closer to final PDF design
* Add app icon and branding
* Remove temporary token display from scanner screen

### Production Readiness

* Add production HTTPS configuration
* Remove fake service delays and mock data
* Test on real Android device with real Odoo POS QR
* Test invalid token and expired token backend responses

### Release Build

```powershell
flutter build apk
```

---

## Backend Integration Status

### Completed

* QR scanning and parsing
* QR expiry validation
* Session persistence
* Secure token storage
* Product workflow architecture
* Service layer abstraction

### In Progress

* Odoo API integration
* JWT authentication integration
* Product management API integration

### Planned

* Production deployment support
* HTTPS communication
* Full backend validation
* End-to-end testing with OrangePOS

---

## Project Structure

```text
flutter_app/
└── lib/
    ├── app/
    ├── config/
    ├── models/
    │   ├── product.dart
    │   └── qr_login_data.dart
    ├── screens/
    ├── services/
    │   ├── auth_service.dart
    │   ├── product_service.dart
    │   └── token_storage.dart
    └── widgets/
```
