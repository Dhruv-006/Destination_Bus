"""
Firebase Firestore Service
Replaces SQLAlchemy with Firebase Firestore for real-time database operations
"""
import firebase_admin
from firebase_admin import credentials, firestore
from datetime import datetime
import os

# Initialize Firebase Admin SDK
def init_firebase():
    """Initialize Firebase Admin SDK"""
    if not firebase_admin._apps:
        # Check if running with service account key file
        if os.path.exists('firebase-service-account.json'):
            cred = credentials.Certificate('firebase-service-account.json')
            firebase_admin.initialize_app(cred)
        else:
            # For development, you can use application default credentials
            # Or set GOOGLE_APPLICATION_CREDENTIALS environment variable
            try:
                firebase_admin.initialize_app()
            except Exception as e:
                print(f"⚠️  Firebase initialization error: {e}")
                print("Please set up firebase-service-account.json or GOOGLE_APPLICATION_CREDENTIALS")
                raise
    
    return firestore.client()

# Initialize Firestore client
db = init_firebase()

# Collection names
COLLECTIONS = {
    'admins': 'admins',
    'buses': 'buses',
    'drivers': 'drivers',
    'routes': 'routes',
    'maintenance': 'maintenance_logs',
    'live_locations': 'live_locations'
}


# ============================================
# ADMIN OPERATIONS
# ============================================

def get_admin_by_username(username):
    """Get admin by username"""
    admins_ref = db.collection(COLLECTIONS['admins'])
    query = admins_ref.where('username', '==', username).limit(1).stream()
    for doc in query:
        data = doc.to_dict()
        data['id'] = doc.id
        return data
    return None


def create_default_admin():
    """Create default admin user if not exists"""
    admin = get_admin_by_username('admin')
    if not admin:
        admin_data = {
            'username': 'admin',
            'password': 'admin123',
            'created_at': datetime.now()
        }
        db.collection(COLLECTIONS['admins']).add(admin_data)
        print("✅ Default admin user created")
    else:
        print("ℹ️  Admin user already exists")


# ============================================
# BUS OPERATIONS
# ============================================

def get_all_buses():
    """Get all buses"""
    buses_ref = db.collection(COLLECTIONS['buses'])
    buses = []
    for doc in buses_ref.stream():
        data = doc.to_dict()
        data['bus_id'] = doc.id
        buses.append(data)
    return buses


def get_bus_by_id(bus_id):
    """Get bus by ID"""
    doc = db.collection(COLLECTIONS['buses']).document(str(bus_id)).get()
    if doc.exists:
        data = doc.to_dict()
        data['bus_id'] = doc.id
        return data
    return None


def add_bus(bus_data):
    """Add a new bus"""
    bus_data['created_at'] = datetime.now()
    doc_ref = db.collection(COLLECTIONS['buses']).add(bus_data)
    return doc_ref[1].id  # Return document ID


def update_bus(bus_id, bus_data):
    """Update a bus"""
    bus_data['updated_at'] = datetime.now()
    db.collection(COLLECTIONS['buses']).document(str(bus_id)).update(bus_data)
    return True


def delete_bus(bus_id):
    """Delete a bus"""
    db.collection(COLLECTIONS['buses']).document(str(bus_id)).delete()
    return True


# ============================================
# DRIVER OPERATIONS
# ============================================

def get_all_drivers():
    """Get all drivers"""
    drivers_ref = db.collection(COLLECTIONS['drivers'])
    drivers = []
    for doc in drivers_ref.stream():
        data = doc.to_dict()
        data['driver_id'] = doc.id
        drivers.append(data)
    return drivers


def get_driver_by_id(driver_id):
    """Get driver by ID"""
    doc = db.collection(COLLECTIONS['drivers']).document(str(driver_id)).get()
    if doc.exists:
        data = doc.to_dict()
        data['driver_id'] = doc.id
        return data
    return None


def add_driver(driver_data):
    """Add a new driver"""
    driver_data['attendance'] = driver_data.get('attendance', 'Absent')
    driver_data['created_at'] = datetime.now()
    doc_ref = db.collection(COLLECTIONS['drivers']).add(driver_data)
    return doc_ref[1].id


def update_driver(driver_id, driver_data):
    """Update a driver"""
    driver_data['updated_at'] = datetime.now()
    db.collection(COLLECTIONS['drivers']).document(str(driver_id)).update(driver_data)
    return True


def delete_driver(driver_id):
    """Delete a driver"""
    db.collection(COLLECTIONS['drivers']).document(str(driver_id)).delete()
    return True


def update_driver_attendance(driver_id, status):
    """Update driver attendance"""
    db.collection(COLLECTIONS['drivers']).document(str(driver_id)).update({
        'attendance': status,
        'updated_at': datetime.now()
    })
    return True


# ============================================
# ROUTE OPERATIONS
# ============================================

def get_all_routes():
    """Get all routes"""
    routes_ref = db.collection(COLLECTIONS['routes'])
    routes = []
    for doc in routes_ref.stream():
        data = doc.to_dict()
        data['route_id'] = doc.id
        routes.append(data)
    return routes


def get_route_by_id(route_id):
    """Get route by ID"""
    doc = db.collection(COLLECTIONS['routes']).document(str(route_id)).get()
    if doc.exists:
        data = doc.to_dict()
        data['route_id'] = doc.id
        return data
    return None


def add_route(route_data):
    """Add a new route"""
    route_data['created_at'] = datetime.now()
    doc_ref = db.collection(COLLECTIONS['routes']).add(route_data)
    return doc_ref[1].id


def update_route(route_id, route_data):
    """Update a route"""
    route_data['updated_at'] = datetime.now()
    db.collection(COLLECTIONS['routes']).document(str(route_id)).update(route_data)
    return True


def delete_route(route_id):
    """Delete a route"""
    db.collection(COLLECTIONS['routes']).document(str(route_id)).delete()
    return True


# ============================================
# MAINTENANCE OPERATIONS
# ============================================

def get_all_maintenance():
    """Get all maintenance logs, ordered by reported_at desc"""
    maintenance_ref = db.collection(COLLECTIONS['maintenance'])
    maintenance = []
    try:
        # Try to order by reported_at
        query = maintenance_ref.order_by('reported_at', direction=firestore.Query.DESCENDING)
        for doc in query.stream():
            data = doc.to_dict()
            data['id'] = doc.id
            # Convert Firestore timestamp to string if needed
            if 'reported_at' in data:
                if hasattr(data['reported_at'], 'strftime'):
                    data['reported_on'] = data['reported_at'].strftime('%Y-%m-%d %H:%M')
                elif hasattr(data['reported_at'], 'timestamp'):
                    # Firestore Timestamp
                    data['reported_on'] = datetime.fromtimestamp(data['reported_at'].timestamp()).strftime('%Y-%m-%d %H:%M')
                else:
                    data['reported_on'] = str(data['reported_at'])
            elif 'reported_on' not in data:
                data['reported_on'] = datetime.now().strftime('%Y-%m-%d %H:%M')
            maintenance.append(data)
    except Exception as e:
        # Fallback: get all without ordering
        print(f"Warning: Could not order maintenance by reported_at: {e}")
        for doc in maintenance_ref.stream():
            data = doc.to_dict()
            data['id'] = doc.id
            if 'reported_on' not in data:
                data['reported_on'] = datetime.now().strftime('%Y-%m-%d %H:%M')
            maintenance.append(data)
    return maintenance


def get_maintenance_by_id(maintenance_id):
    """Get maintenance log by ID"""
    doc = db.collection(COLLECTIONS['maintenance']).document(str(maintenance_id)).get()
    if doc.exists:
        data = doc.to_dict()
        data['id'] = doc.id
        return data
    return None


def add_maintenance(maintenance_data):
    """Add a new maintenance log"""
    maintenance_data['status'] = maintenance_data.get('status', 'Pending')
    maintenance_data['reported_at'] = datetime.now()
    maintenance_data['reported_on'] = datetime.now().strftime('%Y-%m-%d %H:%M')
    doc_ref = db.collection(COLLECTIONS['maintenance']).add(maintenance_data)
    return doc_ref[1].id


def update_maintenance(maintenance_id, maintenance_data):
    """Update a maintenance log"""
    maintenance_data['updated_at'] = datetime.now()
    db.collection(COLLECTIONS['maintenance']).document(str(maintenance_id)).update(maintenance_data)
    return True


def delete_maintenance(maintenance_id):
    """Delete a maintenance log"""
    db.collection(COLLECTIONS['maintenance']).document(str(maintenance_id)).delete()
    return True


# ============================================
# LIVE LOCATIONS OPERATIONS
# ============================================

def get_live_locations():
    """Get all live bus locations"""
    locations_ref = db.collection(COLLECTIONS['live_locations'])
    locations = {}
    for doc in locations_ref.stream():
        data = doc.to_dict()
        locations[doc.id] = data
    return locations


def update_live_location(bus_id, location_data):
    """Update live location for a bus"""
    location_data['last_update'] = datetime.now().isoformat()
    db.collection(COLLECTIONS['live_locations']).document(str(bus_id)).set(location_data, merge=True)
    return True

