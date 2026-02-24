# AutoFinance Guardian

AI-powered Car Lease / Loan Contract Review & Negotiation App.

## Getting Started

This project is a Flutter application. To run this project, you will need to have Flutter installed on your machine.

### Installation

1. Clone the repo
   ```sh
   git clone https://github.com/your_username_/AutoFinance-Guardian.git
   ```
2. Install packages
   ```sh
   cd frontend/guardian_app
   flutter pub get
   ```

### Running the app

```sh
flutter run
```

## Responsive Architecture

This project has been refactored into a scalable, production-ready responsive architecture.

- **Responsive Scaffolding**: Uses `ResponsiveLayout` and `ResponsiveScaffold` to adapt between Mobile, Tablet, and Desktop views.
- **Components**:
  - `AppSidebar`: Collapsible sidebar for desktop.
  - `MobileNav`: Drawer and Bottom Navigation for mobile.
  - `AppCard` & `ResponsiveGrid`: Reusable UI components.
- **State Management**: Uses Riverpod for dependency injection and state management (`AppStateProvider` handles UI state like theme and sidebar).
- **Theming**: comprehensive `AppTheme` with light and dark mode support.

## Project Structure

- `lib/core`: Constants, Theme, and Utilities.
- `lib/screens`: Screen implementations (responsive wrappers).
- `lib/widgets`:
  - `responsive`: Layout widgets (`ResponsiveLayout`, `ResponsiveScaffold`).
  - `navigation`: Sidebar, Mobile Nav.
  - `common`: Reusable widgets (Cards, Grids).
  - `dashboard`, `market`, `vin_validation`: Feature-specific widgets.
- `lib/providers`: Riverpod providers.
- `lib/models`: Data models.
- `lib/services`: API and business logic services.

## Built With

- [Flutter](https://flutter.dev/)
- [Riverpod](https://riverpod.dev/)
- [GoRouter](https://pub.dev/packages/go_router)
- [Dio](https://pub.dev/packages/dio)
- [FLChart](https://pub.dev/packages/fl_chart)
