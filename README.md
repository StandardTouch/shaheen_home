# Shaheen Home

A Flutter application that provides a secure web browsing experience through a curated list of websites.

## Features

- Grid view display of approved websites with icons and names
- Secure web browsing using InAppWebView
- Domain blacklisting functionality
- Firebase backend integration for:
  - Website URL management
  - Domain blacklisting
  - User authentication

## Data Structure

### URLs Collection
Each document contains:
```json
{
  "url": "string",
  "icon": "string (URL to icon image)",
  "name": "string"
}
```

### Blacklist Collection
Each document contains:
```json
{
  "domain": "string"
}
```

## Security Features

- Domain verification before opening URLs
- Custom blocking screen for blacklisted domains
- Secure web browsing environment

## Technical Stack

- **Frontend**: Flutter
- **Backend**: Firebase
  - Firestore for data storage
  - Authentication for user management
- **Web View**: InAppWebView package

## Getting Started

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Configure Firebase:
   - Add your Firebase configuration files
   - Set up Firestore collections
4. Run the app:
   ```bash
   flutter run
   ```

## Configuration

1. Set up Firebase project
2. Create Firestore collections:
   - `urls` - For storing website information
   - `blacklist` - For storing blocked domains
3. Configure security rules in Firestore

## Dependencies

- flutter_inappwebview: ^6.0.0
- firebase_core: ^latest
- cloud_firestore: ^latest
- firebase_auth: ^latest

## License

This project is licensed under the MIT License - see the LICENSE file for details.
