# PlombiPro

A comprehensive business management application for plumbing professionals, built with Flutter and Supabase.

## Features

- **Client Management**: Track individual and business clients with complete contact information
- **Quote & Invoice Generation**: Create professional quotes and invoices with PDF export
- **Job Site Management**: Track work progress, time logs, photos, and notes
- **Product Catalog**: Manage products with OCR invoice scanning and supplier catalog integration
- **Payment Tracking**: Monitor payments with Stripe integration
- **Analytics Dashboard**: Visualize business metrics and performance
- **Document Templates**: Pre-configured templates for various plumbing services
- **Cloud Functions**: Automated PDF generation, payment reminders, and invoice processing

## Quick Start

**⚠️ IMPORTANT**: Before building or running the app, please read the complete setup instructions:

📖 **[BUILD_INSTRUCTIONS.md](BUILD_INSTRUCTIONS.md)** - Complete build and setup guide

### Prerequisites

- Flutter SDK (3.9.2 or higher)
- Supabase account with configured database
- Stripe account (for payment processing)
- Google Cloud Platform account (for cloud functions)

### Setup in 3 Steps

1. **Configure environment**:
   ```bash
   cp lib/.env.example lib/.env
   # Edit lib/.env with your credentials
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

3. **Run the app**:
   ```bash
   flutter run
   ```

## Documentation

- 📋 [BUILD_INSTRUCTIONS.md](BUILD_INSTRUCTIONS.md) - Complete build and troubleshooting guide
- 🔐 [CREDENTIALS_SETUP_GUIDE.md](CREDENTIALS_SETUP_GUIDE.md) - Detailed credential setup
- 📊 [IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md) - Current implementation status
- 🗄️ [supabase_schema.sql](supabase_schema.sql) - Database schema
- ☁️ [cloud_functions/](cloud_functions/) - Cloud function implementations

## Technology Stack

- **Frontend**: Flutter 3.9.2+ (Dart)
- **Backend**: Supabase (PostgreSQL, Auth, Storage)
- **Payments**: Stripe
- **PDF Generation**: pdf package
- **Cloud Functions**: Google Cloud Functions (Python)
- **Routing**: go_router
- **State Management**: Built-in Flutter state management

## Project Structure

```
plombipro-app/
├── lib/
│   ├── config/          # App configuration
│   ├── models/          # Data models
│   ├── screens/         # UI screens
│   ├── services/        # Business logic
│   └── widgets/         # Reusable components
├── cloud_functions/     # Cloud functions
├── assets/templates/    # Document templates
└── BUILD_INSTRUCTIONS.md
```

## Development

### Code Generation

After modifying model classes with `@JsonSerializable()`:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Code Quality

```bash
flutter analyze      # Static analysis
flutter test         # Run tests
flutter format lib/  # Format code
```

## Support

For detailed setup instructions, troubleshooting, and build information, see [BUILD_INSTRUCTIONS.md](BUILD_INSTRUCTIONS.md).
