# 🚌 Smart Bus Management System

A complete bus management system with an Admin Panel (Flask web app) and User Application (Flutter mobile app), both connected to a shared SQLite database.

## 📁 Project Structure

```
smart_bus_admin/
├── Admin Panel - Website/     # Flask admin panel
│   ├── app.py                 # Main Flask application
│   ├── models.py              # SQLAlchemy models
│   ├── create_db.py           # Database initialization
│   ├── requirements.txt       # Python dependencies
│   ├── templates/             # HTML templates
│   └── static/                # CSS, JS, images
│
└── User Screen - Application/  # Flutter user app
    ├── lib/                   # Dart source files
    │   ├── main.dart         # App entry point
    │   ├── api_service.dart  # API connection service
    │   ├── dashboard_page.dart
    │   ├── buses_page.dart
    │   └── routes_page.dart
    └── pubspec.yaml          # Flutter dependencies
```

## 🚀 Quick Start

### Admin Panel Setup

1. **Navigate to admin panel:**
   ```bash
   cd "Admin Panel - Website"
   ```

2. **Install Python dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

3. **Initialize database:**
   ```bash
   python create_db.py
   ```
   This creates the database and default admin user:
   - Username: `admin`
   - Password: `admin123`

4. **Run the Flask server:**
   ```bash
   python app.py
   ```
   The server will run on `http://localhost:5000`

5. **Access admin panel:**
   - Open browser: `http://localhost:5000`
   - Login with: `admin` / `admin123`

### Flutter App Setup

1. **Navigate to Flutter app:**
   ```bash
   cd "User Screen - Application"
   ```

2. **Install Flutter dependencies:**
   ```bash
   flutter pub get
   ```

3. **Update API URL (if needed):**
   - Open `lib/api_service.dart`
   - Update `baseUrl` based on your setup:
     - Android Emulator: `http://10.0.2.2:5000/api/public`
     - iOS Simulator: `http://localhost:5000/api/public`
     - Physical Device: `http://YOUR_COMPUTER_IP:5000/api/public`

4. **Run Flutter app:**
   ```bash
   flutter run
   ```

## 🔌 API Endpoints

### Public Endpoints (No Authentication - For Flutter App)

- `GET /api/public/buses` - Get all buses
- `GET /api/public/routes` - Get all routes
- `GET /api/public/drivers` - Get all drivers
- `POST /api/public/location-update` - Update bus location

### Admin Endpoints (Require Login)

- `POST /api/buses` - Add bus
- `PUT /api/buses/<id>` - Update bus
- `DELETE /api/buses/<id>` - Delete bus
- Similar endpoints for drivers, routes, and maintenance

## 📱 Flutter App Features

- View all buses with real-time data from admin panel
- View all routes with schedules
- Pull-to-refresh to get latest data
- Search and filter buses
- Beautiful dark theme UI

## 🖥️ Admin Panel Features

- Modern dashboard with statistics
- Bus management (Add/Edit/Delete)
- Driver management with attendance tracking
- Route management
- Maintenance tracking
- Interactive charts and graphs
- Responsive design

## 🔧 Configuration

### Finding Your Computer's IP Address

For Flutter app on physical device:

**Windows:**
```bash
ipconfig
```
Look for IPv4 Address (e.g., 192.168.1.100)

**Mac/Linux:**
```bash
ifconfig
```
or
```bash
ip addr show
```

Then update `api_service.dart`:
```dart
static const String baseUrl = 'http://192.168.1.100:5000/api/public';
```

### CORS Configuration

The Flask app has CORS enabled for `/api/*` endpoints to allow Flutter app connections.

## 🗄️ Database

- **Type:** SQLite
- **Location:** `Admin Panel - Website/smart_bus.db`
- **Tables:**
  - `admin` - Admin users
  - `bus` - Bus fleet
  - `driver` - Drivers
  - `route` - Routes
  - `maintenance_log` - Maintenance records

## 🐛 Troubleshooting

### Flutter App Can't Connect

1. **Check Flask server is running:**
   ```bash
   # In Admin Panel - Website directory
   python app.py
   ```

2. **Check IP address:**
   - Make sure you're using the correct IP for your device
   - Ensure both devices are on the same network

3. **Check firewall:**
   - Allow port 5000 through Windows Firewall
   - Or temporarily disable firewall for testing

4. **Test API manually:**
   ```bash
   curl http://localhost:5000/api/public/buses
   ```

### Database Errors

If you get database errors:
```bash
cd "Admin Panel - Website"
python create_db.py
```

This will recreate the database.

## 📝 Default Credentials

- **Admin Username:** `admin`
- **Admin Password:** `admin123`

## 🎯 Usage Flow

1. **Admin adds data** via web panel → Saved to SQLite
2. **User app fetches data** via API → Displays in Flutter app
3. **User app can send location updates** → Stored via API
4. **Admin sees updates** in dashboard

## 🔄 Data Flow

```
Admin Panel (Flask) ←→ SQLite Database ←→ API Endpoints ←→ Flutter App
```

## 📚 Technology Stack

**Admin Panel:**
- Flask (Python)
- SQLAlchemy (ORM)
- SQLite (Database)
- Chart.js (Charts)
- HTML/CSS/JavaScript

**Flutter App:**
- Flutter/Dart
- HTTP package (API calls)
- Material Design

## ✅ Features Completed

- ✅ Local SQLite database (no Firebase)
- ✅ Admin panel with full CRUD operations
- ✅ Flutter app connected to admin API
- ✅ CORS enabled for cross-origin requests
- ✅ Public API endpoints for Flutter app
- ✅ Real-time data sync (via API calls)
- ✅ Beautiful UI for both apps
- ✅ Error handling and loading states

## 🚀 Next Steps

1. Run admin panel: `cd "Admin Panel - Website" && python app.py`
2. Run Flutter app: `cd "User Screen - Application" && flutter run`
3. Add data via admin panel
4. View data in Flutter app

---

**Enjoy managing your bus fleet! 🚌✨**

