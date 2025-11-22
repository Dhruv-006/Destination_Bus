# 🚀 Setup Instructions - Smart Bus Management System

## ✅ What's Been Done

1. ✅ **Removed Firebase** - Converted back to local SQLite database
2. ✅ **Connected Flutter App** - Created API service and connected to Flask backend
3. ✅ **Added CORS Support** - Flutter app can now make API calls
4. ✅ **Created Public API Endpoints** - For Flutter app to access data
5. ✅ **Updated Flutter Pages** - Buses and Routes pages now fetch real data

## 📋 Step-by-Step Setup

### Step 1: Setup Admin Panel

1. **Open terminal and navigate to admin panel:**
   ```bash
   cd "Admin Panel - Website"
   ```

2. **Install Python dependencies:**
   ```bash
   pip install -r requirements.txt
   ```
   
   This installs:
   - Flask
   - Flask-SQLAlchemy
   - Flask-CORS

3. **Initialize the database:**
   ```bash
   python create_db.py
   ```
   
   This creates:
   - SQLite database (`smart_bus.db`)
   - Default admin user (admin/admin123)

4. **Start the Flask server:**
   ```bash
   python app.py
   ```
   
   Server runs on: `http://localhost:5000` or `http://0.0.0.0:5000`

5. **Test admin panel:**
   - Open browser: `http://localhost:5000`
   - Login: `admin` / `admin123`

### Step 2: Setup Flutter App

1. **Open terminal and navigate to Flutter app:**
   ```bash
   cd "User Screen - Application"
   ```

2. **Install Flutter dependencies:**
   ```bash
   flutter pub get
   ```
   
   This installs the `http` package for API calls.

3. **Configure API URL:**
   
   Open `lib/api_service.dart` and update the `baseUrl`:
   
   **For Android Emulator:**
   ```dart
   static const String baseUrl = 'http://10.0.2.2:5000/api/public';
   ```
   
   **For iOS Simulator:**
   ```dart
   static const String baseUrl = 'http://localhost:5000/api/public';
   ```
   
   **For Physical Device:**
   - Find your computer's IP address:
     - Windows: `ipconfig` (look for IPv4 Address)
     - Mac/Linux: `ifconfig` or `ip addr show`
   - Update the URL:
     ```dart
     static const String baseUrl = 'http://YOUR_IP:5000/api/public';
     ```
     Example: `http://192.168.1.100:5000/api/public`

4. **Run Flutter app:**
   ```bash
   flutter run
   ```

### Step 3: Test Connection

1. **Add some data via admin panel:**
   - Login to admin panel
   - Add a few buses
   - Add some routes
   - Add drivers

2. **Check Flutter app:**
   - Open the Flutter app
   - Navigate to "Buses" tab
   - You should see the buses you added
   - Navigate to "Routes" tab
   - You should see the routes you added
   - Pull down to refresh and get latest data

## 🔧 Troubleshooting

### Issue: Flutter app shows "Failed to load buses"

**Solution:**
1. Make sure Flask server is running
2. Check the API URL in `api_service.dart`
3. For physical device, ensure both devices are on same WiFi network
4. Check Windows Firewall - allow port 5000

**Test API manually:**
```bash
curl http://localhost:5000/api/public/buses
```

### Issue: CORS errors in browser console

**Solution:**
- Flask-CORS is already installed and configured
- If still getting errors, check that Flask server is running with CORS enabled

### Issue: Database errors

**Solution:**
```bash
cd "Admin Panel - Website"
python create_db.py
```

This will recreate the database.

### Issue: Module not found errors

**Solution:**
```bash
pip install Flask Flask-SQLAlchemy Flask-CORS
```

## 📱 API Endpoints Reference

### Public Endpoints (No Auth - For Flutter)

- `GET /api/public/buses` - Get all buses
- `GET /api/public/routes` - Get all routes  
- `GET /api/public/drivers` - Get all drivers
- `POST /api/public/location-update` - Update bus location
  ```json
  {
    "bus_id": 1,
    "lat": 21.7643,
    "lng": 72.1511,
    "speed": 30,
    "occupancy": 25
  }
  ```

### Admin Endpoints (Require Login)

- `POST /api/buses` - Add bus
- `PUT /api/buses/<id>` - Update bus
- `DELETE /api/buses/<id>` - Delete bus
- Similar for drivers, routes, maintenance

## 🎯 How It Works

1. **Admin Panel** (Flask):
   - Manages data via web interface
   - Stores data in SQLite database
   - Provides API endpoints

2. **Flutter App**:
   - Fetches data from Flask API
   - Displays data to users
   - Can send location updates

3. **Database**:
   - Shared SQLite database
   - Both apps read/write to same database via API

## ✅ Verification Checklist

- [ ] Flask server runs without errors
- [ ] Can login to admin panel
- [ ] Can add/edit/delete buses, drivers, routes
- [ ] Flutter app connects to API
- [ ] Flutter app displays buses from database
- [ ] Flutter app displays routes from database
- [ ] Pull-to-refresh works in Flutter app

## 🚀 Quick Test

1. Start Flask server: `cd "Admin Panel - Website" && python app.py`
2. Add a bus via admin panel
3. Run Flutter app: `cd "User Screen - Application" && flutter run`
4. Check "Buses" tab - you should see the bus you added!

---

**Everything is now connected and ready to use! 🎉**

