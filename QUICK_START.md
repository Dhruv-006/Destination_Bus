# 🚀 Quick Start Guide

## ✅ Everything is Ready!

Your Smart Bus Management System is now:
- ✅ Using local SQLite database (no Firebase needed)
- ✅ Admin panel connected to database
- ✅ Flutter app connected to admin API
- ✅ All dependencies installed
- ✅ Database initialized

## 🎯 How to Run

### 1. Start Admin Panel (Terminal 1)

```bash
cd "Admin Panel - Website"
python app.py
```

**Server will run on:** `http://localhost:5000`

**Login:**
- Username: `admin`
- Password: `admin123`

### 2. Start Flutter App (Terminal 2)

```bash
cd "User Screen - Application"
flutter pub get
flutter run
```

**Important:** Before running Flutter app, update the API URL in `lib/api_service.dart`:
- For Android Emulator: `http://10.0.2.2:5000/api/public`
- For Physical Device: `http://YOUR_COMPUTER_IP:5000/api/public`

## 📱 Testing the Connection

1. **Add data via admin panel:**
   - Login to admin panel
   - Go to "Buses" tab
   - Add a new bus (e.g., Number: "101", Status: "Active")
   - Add a route (e.g., Name: "Route 1", Start: "A", End: "B")

2. **View in Flutter app:**
   - Open Flutter app
   - Go to "Buses" tab
   - You should see the bus you added!
   - Go to "Routes" tab
   - You should see the route you added!
   - Pull down to refresh for latest data

## 🔧 If Something Doesn't Work

### Flutter can't connect:
1. Check Flask server is running
2. Check API URL in `api_service.dart`
3. For physical device, ensure same WiFi network
4. Check Windows Firewall allows port 5000

### Database errors:
```bash
cd "Admin Panel - Website"
python create_db.py
```

### Module errors:
```bash
pip install Flask Flask-SQLAlchemy Flask-CORS
```

## 📊 What You Can Do

**Admin Panel:**
- Add/Edit/Delete buses, drivers, routes, maintenance
- View statistics and charts
- Mark driver attendance
- Track maintenance

**Flutter App:**
- View all buses
- View all routes
- Search and filter
- Pull to refresh
- Send location updates (ready for implementation)

## 🎉 You're All Set!

Both applications are connected and ready to use. The Flutter app will automatically fetch data from the admin panel's database via the API.

---

**Need help?** Check `SETUP_INSTRUCTIONS.md` for detailed troubleshooting.

