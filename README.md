# Final Year Project Finder

A comprehensive Flutter application that helps computer science students discover unique and industry-relevant final year project ideas. The app features Firebase authentication, AI-powered recommendations, and a modern, responsive UI.

## Features

### 🔐 Authentication
- **Firebase Authentication** with Google Sign-In and Email/Password
- **Session Management** with automatic login state persistence
- **Password Recovery** functionality

### 🎯 Project Discovery
- **Search & Filter** projects by domain, difficulty, and career goals
- **Project Details** with comprehensive information including:
  - Problem statements and descriptions
  - Required tech stack
  - Industry relevance scores (1-5 stars)
  - Real-world applications
  - Possible extensions
- **Save Projects** to your personal collection

### 🤖 AI-Powered Recommendations
- **OpenRouter API Integration** using `openai/gpt-oss-20b:free` model
- **Personalized Suggestions** based on your skills and career goals
- **Smart Matching** algorithm for relevant project recommendations

### 📱 Modern UI/UX
- **Material Design 3** with custom theming
- **Dark/Light Mode** support
- **Responsive Design** for various screen sizes
- **Smooth Animations** and transitions
- **Onboarding Flow** for new users

### 🏗️ Technical Architecture
- **Provider State Management** for efficient state handling
- **Go Router** for declarative navigation
- **Firestore Database** for scalable data storage
- **Modular Code Structure** for maintainability

## Tech Stack

### Frontend
- **Flutter** - Cross-platform mobile framework
- **Dart** - Programming language
- **Material Design 3** - UI components

### Backend & Services
- **Firebase Core** - Backend infrastructure
- **Firebase Auth** - Authentication service
- **Cloud Firestore** - NoSQL database
- **Google Sign-In** - OAuth authentication

### State Management & Navigation
- **Provider** - State management solution
- **Go Router** - Declarative routing

### External APIs
- **OpenRouter API** - AI-powered recommendations
- **Dio** - HTTP client for API calls

### UI & Utilities
- **Google Fonts** - Typography
- **Flutter SVG** - Vector graphics
- **Cached Network Image** - Image caching
- **Shimmer** - Loading animations
- **Flutter Staggered Grid View** - Advanced layouts

## Project Structure

```
lib/
├── core/
│   ├── data/
│   │   └── sample_projects.dart      # Sample project data
│   ├── models/
│   │   ├── project_model.dart        # Project data model
│   │   └── user_model.dart           # User data model
│   ├── providers/
│   │   ├── auth_provider.dart        # Authentication logic
│   │   ├── project_provider.dart     # Project management
│   │   └── user_provider.dart        # User preferences
│   ├── router/
│   │   └── app_router.dart           # Navigation configuration
│   ├── services/
│   │   └── firestore_service.dart    # Database operations
│   └── theme/
│       └── app_theme.dart            # App theming
├── features/
│   ├── ai_recommendations/
│   │   └── ai_recommendations_screen.dart
│   ├── auth/
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   └── forgot_password_screen.dart
│   ├── dashboard/
│   │   ├── dashboard_screen.dart
│   │   └── widgets/
│   │       ├── dashboard_app_bar.dart
│   │       ├── filter_chips.dart
│   │       ├── project_card.dart
│   │       └── search_bar_widget.dart
│   ├── onboarding/
│   │   └── onboarding_screen.dart
│   ├── profile/
│   │   └── profile_screen.dart
│   ├── project_details/
│   │   └── project_details_screen.dart
│   ├── saved_projects/
│   │   └── saved_projects_screen.dart
│   └── splash/
│       └── splash_screen.dart
├── firebase_options.dart             # Firebase configuration
└── main.dart                         # App entry point
```

## Getting Started

### Prerequisites
- Flutter SDK (3.8.1 or higher)
- Dart SDK
- Android Studio / VS Code
- Firebase project setup

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd final_year_project_finder
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a new Firebase project at [Firebase Console](https://console.firebase.google.com)
   - Enable Authentication (Email/Password and Google Sign-In)
   - Enable Cloud Firestore
   - Download and place `google-services.json` in `android/app/`
   - Download and place `GoogleService-Info.plist` in `ios/Runner/`

4. **Configure Firebase**
   ```bash
   flutter pub global activate flutterfire_cli
   flutterfire configure
   ```

5. **OpenRouter API Setup**
   - The app uses the provided API key: `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`
   - This is configured in `lib/core/providers/project_provider.dart`

### Running the App

1. **Start an emulator or connect a device**

2. **Run the application**
   ```bash
   flutter run
   ```

3. **For web deployment**
   ```bash
   flutter run -d chrome
   ```

## Configuration

### Firebase Rules
Set up Firestore security rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Projects are readable by all authenticated users
    match /projects/{projectId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null; // Adjust based on your needs
    }
  }
}
```

### Environment Variables
The app uses the following configuration:
- **OpenRouter API Key**: Embedded in the code (for demo purposes)
- **Firebase Config**: Auto-generated via FlutterFire CLI

## Features in Detail

### Authentication Flow
1. **Splash Screen** - Initial loading and route determination
2. **Login/Register** - Firebase Auth with Google Sign-In option
3. **Onboarding** - Skill and career goal setup for new users
4. **Dashboard** - Main app interface

### Project Discovery
- **Search**: Real-time search across project titles, descriptions, and tech stacks
- **Filters**: Domain (AI, Web, Mobile, etc.), Difficulty (Beginner to Expert), Career Paths
- **Sorting**: By relevance, date, popularity

### AI Recommendations
- **Input**: User skills and career goals
- **Processing**: OpenRouter API with GPT model
- **Output**: Personalized project suggestions with detailed information

## Deployment

### Android
1. **Build APK**
   ```bash
   flutter build apk --release
   ```

2. **Build App Bundle**
   ```bash
   flutter build appbundle --release
   ```

### iOS
1. **Build iOS**
   ```bash
   flutter build ios --release
   ```

### Web
1. **Build Web**
   ```bash
   flutter build web --release
   ```

## Performance Optimization

- **Lazy Loading**: Projects loaded on-demand
- **Image Caching**: Cached network images for better performance
- **State Management**: Efficient Provider implementation
- **Database Optimization**: Indexed Firestore queries

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Troubleshooting

### Common Issues

1. **Firebase Configuration**
   - Ensure `google-services.json` and `GoogleService-Info.plist` are properly placed
   - Run `flutterfire configure` to regenerate configuration

2. **Dependencies**
   - Run `flutter clean` and `flutter pub get` to refresh dependencies
   - Check Flutter and Dart SDK versions

3. **API Issues**
   - Verify OpenRouter API key is valid
   - Check network connectivity for API calls

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions:
- Create an issue in the repository
- Check the Flutter documentation
- Review Firebase documentation

## Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- OpenRouter for AI API services
- Material Design team for UI guidelines
