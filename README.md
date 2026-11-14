BTL Digital

Mobile banking app built with Flutter during a software engineering internship at Banque Tuniso-Libyenne (BTL), Tunis (July – August 2026).

The app covers the main customer journeys of a retail bank: sign-up with OTP verification, account and card overview, beneficiary management, transfers, and currency exchange.

<!-- TODO: add 3 to 5 screenshots here, for example: <p align="center"> <img src="docs/screenshots/login.png" width="200" /> <img src="docs/screenshots/dashboard.png" width="200" /> <img src="docs/screenshots/transfer.png" width="200" /> </p> -->
Features
Feature	Description
Registration	Create a customer account
OTP authentication	One-time codes sent by SMS and email
Dashboard	Overview of the customer's situation
Accounts & cards	List and details of accounts and cards
Beneficiaries	Add and manage beneficiaries
Transfers	Send money to a beneficiary
Currency exchange	Convert between currencies
Architecture

The code follows Clean Architecture, which keeps business logic independent from the UI and from the data sources:

Presentation: screens and reusable widgets, built from the Figma designs provided by the bank.
Domain: entities and use cases, with no dependency on Flutter or on the network.
Data: repositories and API clients that talk to the backend.
Backend integration

The app consumes the bank's REST APIs, documented with Swagger. It integrates six modules:

accounts · authentication · beneficiaries · subscriptions · currencies · transfers

The authentication module exposes five documented endpoints for the SMS and email OTP flows.

Quality
Figma designs translated into reusable Flutter components.
End-to-end flows validated on 2 Android environments, fixing API, navigation, runtime and UI issues.
Tech stack
Flutter / Dart
REST APIs (Swagger)
Clean Architecture
Getting started

Prerequisites: Flutter SDK and an Android emulator or a physical device.

bash
git clone https://github.com/rayengabsi/btl_digital.git
cd btl_digital
flutter pub get
flutter run

The backend URL is not included in this repository. Configure your own API base URL before running the app against a real server.

Documentation

The internship report is available in this repository: Rapport_de_Stage_BTL.pdf.
