# 🚌 Smart Bus Admin Dashboard - Firebase Edition

A modern, professional bus management system with Firebase Firestore integration, real-time updates, and seamless Flutter app connectivity.

## ✨ Features

- 🔥 **Firebase Firestore** - Cloud database with real-time synchronization
- ⚡ **Real-Time Updates** - No page refresh needed, changes appear instantly
- 📱 **Flutter App Ready** - Connect your Flutter app to the same database
- 🎨 Modern UI with blue/white/black theme
- 🎭 Smooth animations and transitions
- 📱 Fully responsive design (mobile, tablet, desktop)
- 🔔 Popup notifications for user actions
- 📊 Real-time dashboard with statistics and charts
- 🚌 Bus management with CRUD operations
- 👨‍✈️ Driver management with attendance tracking
- 🗺️ Route management
- 🔧 Maintenance tracking
- 🤖 AI-powered insights and predictions
- 📍 Live bus tracking (ready for Flutter app integration)

## 🚀 Quick Start

### Prerequisites

- Python 3.7 or higher
- pip (Python package installer)
- Firebase account (free tier available)

### Step 1: Firebase Setup

**Follow the detailed setup guide:** See [FIREBASE_SETUP.md](FIREBASE_SETUP.md) for complete instructions.

Quick steps:
1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Enable Firestore Database
3. Download `firebase-service-account.json` and place it in the project root
4. Get your Firebase web config and update `templates/dashboard.html`

### Step 2: Install Dependencies

```bash
pip install -r requirements.txt
```

### Step 3: Initialize Database

```bash
python create_db.py
```

This creates the default admin user in Firestore:
- **Username:** `admin`
- **Password:** `admin123`

### Step 4: Run the Application

```bash
python app.py
```

### Step 5: Open Browser

Navigate to: `http://localhost:5000`

## 📝 Default Login Credentials

- **Username:** `admin`
- **Password:** `admin123`

## 🔄 Real-Time Features

### No Refresh Needed!

- ✅ Add/edit/delete operations update instantly
- ✅ Changes from Flutter app appear automatically
- ✅ Multiple admin users see updates in real-time
- ✅ All data syncs across devices

### How It Works

The application uses Firebase Firestore real-time listeners:
- Frontend listens to Firestore collections
- Any change (from web or Flutter app) triggers an update
- UI updates automatically without page refresh

## 📱 Flutter App Integration

Your Flutter app can connect to the same Firestore database:

### Flutter Setup

1. Add Firebase to your Flutter project:
```yaml
dependencies:
  firebase_core: ^2.24.0
  cloud_firestore: ^4.13.0
```

2. Initialize Firebase in your Flutter app
3. Use the same Firebase project

### Example Flutter Code

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
      snapshot.docChanges.forEach((change) {
        if (change.type == DocumentChangeType.added) {
          print('New bus added: ${change.doc.data()}');
        }
      });
    });
```

## 🗂️ Firestore Collections

The application uses these collections:

- **`admins`** - Admin users
- **`buses`** - Bus fleet information
- **`drivers`** - Driver information
- **`routes`** - Bus routes
- **`maintenance_logs`** - Maintenance records
- **`live_locations`** - Real-time bus locations (for Flutter app)

## 🛠️ Technology Stack

- **Backend:** Flask (Python)
- **Database:** Firebase Firestore
- **Frontend:** HTML5, CSS3, JavaScript
- **Real-Time:** Firebase Firestore listeners
- **Charts:** Chart.js
- **Styling:** Custom CSS with modern design patterns
- **Fonts:** Inter (Google Fonts)

## 📱 Responsive Design

The application is fully responsive and works on:
- 📱 Mobile devices (320px and up)
- 📱 Tablets (768px and up)
- 💻 Desktops (1024px and up)
- 🖥️ Large screens (1920px and up)

## 🔧 API Endpoints

All endpoints require authentication (login required):

### Buses
- `POST /api/buses` - Add bus
- `PUT /api/buses/<bus_id>` - Update bus
- `DELETE /api/buses/<bus_id>` - Delete bus

### Drivers
- `POST /api/drivers` - Add driver
- `PUT /api/drivers/<driver_id>` - Update driver
- `DELETE /api/drivers/<driver_id>` - Delete driver
- `POST /api/drivers/<driver_id>/attendance` - Update attendance

### Routes
- `POST /api/routes` - Add route
- `PUT /api/routes/<route_id>` - Update route
- `DELETE /api/routes/<route_id>` - Delete route

### Maintenance
- `POST /api/maintenance` - Add maintenance record
- `PUT /api/maintenance/<maintenance_id>` - Update maintenance
- `DELETE /api/maintenance/<maintenance_id>` - Delete maintenance

## 🔒 Security

- ⚠️ **Never commit `firebase-service-account.json`** to version control
- Set up proper Firestore security rules for production
- Use Firebase Authentication for production deployments
- Enable Firebase App Check for additional security

## 🐛 Troubleshooting

### Firebase Not Initialized
- Check that `firebase-service-account.json` exists in project root
- Verify the JSON file is valid
- Check Firebase Console for project status

### Real-Time Updates Not Working
- Verify Firebase config in `templates/dashboard.html`
- Check browser console for errors
- Ensure Firestore is enabled in Firebase Console
- Verify security rules allow read access

### Permission Denied
- Check Firestore security rules
- Verify service account permissions
- Ensure collections exist in Firestore

## 📄 License

This project is for educational/demonstration purposes.

## 👨‍💻 Development

### Project Structure

```
smart_bus_admin/
├── app.py                 # Flask application
├── firebase_service.py    # Firebase Firestore operations
├── models.py              # (Legacy - not used with Firebase)
├── create_db.py           # Initialize Firebase with default admin
├── requirements.txt       # Python dependencies
├── templates/             # HTML templates
│   ├── dashboard.html     # Main dashboard
│   └── login.html         # Login page
├── static/                # Static files
│   ├── style.css          # Styles
│   ├── main.js            # JavaScript with real-time listeners
│   └── 1000053770.png     # Logo
└── FIREBASE_SETUP.md      # Firebase setup guide
```

## 🆕 Migration from SQLite

If you're migrating from the SQLite version:

1. Export your SQLite data (if needed)
2. Set up Firebase (see FIREBASE_SETUP.md)
3. Run `python create_db.py` to initialize
4. Import data to Firestore (manual or script)
5. Update frontend Firebase config

## 📚 Additional Resources

- [Firebase Documentation](https://firebase.google.com/docs)
- [Firestore Documentation](https://firebase.google.com/docs/firestore)
- [Flutter Firestore Guide](https://firebase.flutter.dev/docs/firestore/usage)

---

**Enjoy managing your bus fleet with real-time updates! 🚌✨**
