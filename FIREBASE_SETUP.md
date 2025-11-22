# 🔥 Firebase Setup Guide

This guide will help you set up Firebase Firestore for the Smart Bus Admin application.

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **"Add project"** or select an existing project
3. Follow the setup wizard:
   - Enter project name (e.g., "smart-bus-admin")
   - Enable Google Analytics (optional)
   - Click **"Create project"**

## Step 2: Enable Firestore Database

1. In your Firebase project, go to **"Firestore Database"** in the left sidebar
2. Click **"Create database"**
3. Choose **"Start in test mode"** (for development) or **"Start in production mode"** (for production)
4. Select a location for your database
5. Click **"Enable"**

## Step 3: Get Service Account Key (Backend)

1. In Firebase Console, click the **⚙️ Settings** icon → **"Project settings"**
2. Go to the **"Service accounts"** tab
3. Click **"Generate new private key"**
4. Save the downloaded JSON file as `firebase-service-account.json` in your project root directory
5. **⚠️ IMPORTANT:** Never commit this file to version control! Add it to `.gitignore`

## Step 4: Get Web App Configuration (Frontend)

1. In Firebase Console, click the **⚙️ Settings** icon → **"Project settings"**
2. Scroll down to **"Your apps"** section
3. Click the **Web icon** (`</>`) to add a web app
4. Register your app with a nickname (e.g., "Smart Bus Admin Web")
5. Copy the `firebaseConfig` object

## Step 5: Update Frontend Configuration

1. Open `templates/dashboard.html`
2. Find the Firebase configuration section (around line 12-20)
3. Replace the placeholder values with your actual Firebase config:

```javascript
const firebaseConfig = {
  apiKey: "YOUR_ACTUAL_API_KEY",
  authDomain: "your-project-id.firebaseapp.com",
  projectId: "your-project-id",
  storageBucket: "your-project-id.appspot.com",
  messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
  appId: "YOUR_APP_ID"
};
```

## Step 6: Set Up Firestore Security Rules

1. In Firebase Console, go to **"Firestore Database"** → **"Rules"** tab
2. Update the rules to allow read/write for authenticated users:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow read/write for all authenticated users
    // For production, you should add more specific rules
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
    
    // Or for development/testing, allow all (NOT RECOMMENDED FOR PRODUCTION):
    // match /{document=**} {
    //   allow read, write: if true;
    // }
  }
}
```

3. Click **"Publish"**

## Step 7: Install Dependencies

```bash
pip install -r requirements.txt
```

## Step 8: Initialize Database

```bash
python create_db.py
```

This will create the default admin user in Firestore.

## Step 9: Run the Application

```bash
python app.py
```

## 📋 Firestore Collections Structure

The application uses the following collections:

- **`admins`** - Admin users
- **`buses`** - Bus fleet information
- **`drivers`** - Driver information
- **`routes`** - Bus routes
- **`maintenance_logs`** - Maintenance records
- **`live_locations`** - Real-time bus locations (for Flutter app integration)

## 🔒 Security Best Practices

1. **Never commit `firebase-service-account.json`** to version control
2. Use environment variables for sensitive data in production
3. Set up proper Firestore security rules
4. Enable Firebase Authentication for production use
5. Use Firebase App Check to protect your backend

## 🔄 Real-Time Updates

The application uses Firebase real-time listeners to automatically update the UI when data changes. This means:
- ✅ No page refresh needed
- ✅ Changes from Flutter app appear instantly
- ✅ Multiple admin users see updates in real-time
- ✅ Changes sync across all connected devices

## 🐛 Troubleshooting

### Error: "Firebase initialization error"
- Make sure `firebase-service-account.json` exists in the project root
- Verify the JSON file is valid and not corrupted
- Check that you have the correct permissions in Firebase Console

### Error: "Permission denied" in Firestore
- Check your Firestore security rules
- Make sure you're authenticated (for production rules)
- Verify the service account has proper permissions

### Real-time updates not working
- Check browser console for Firebase errors
- Verify Firebase config in `dashboard.html` is correct
- Make sure Firestore is enabled in Firebase Console
- Check that security rules allow read access

## 📱 Flutter App Integration

Your Flutter app can now connect to the same Firestore database:

1. Add Firebase to your Flutter app using `firebase_core` and `cloud_firestore` packages
2. Use the same Firebase project
3. Read/write to the same collections
4. Changes will sync in real-time between Flutter app and web admin panel

Example Flutter code:
```dart
import 'package:cloud_firestore/cloud_firestore.dart';

// Add a bus
await FirebaseFirestore.instance
    .collection('buses')
    .add({
      'number': '101',
      'status': 'Active',
      'route_id': 'R1',
    });

// Listen to real-time updates
FirebaseFirestore.instance
    .collection('buses')
    .snapshots()
    .listen((snapshot) {
      // Handle updates
    });
```

## ✅ Verification

After setup, verify everything works:

1. ✅ Backend can read/write to Firestore
2. ✅ Frontend shows real-time updates
3. ✅ Default admin user can login
4. ✅ Data persists after server restart
5. ✅ Changes appear without page refresh

---

**Need help?** Check the [Firebase Documentation](https://firebase.google.com/docs) or create an issue in the project repository.

