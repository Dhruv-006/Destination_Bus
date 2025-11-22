# create_db.py - Firebase initialization
# This script initializes Firebase and creates default admin user
import firebase_service as fb

if __name__ == "__main__":
    try:
        # Create default admin user
        fb.create_default_admin()
        print("✅ Firebase initialized and default admin user created/verified.")
        print("📝 Default credentials:")
        print("   Username: admin")
        print("   Password: admin123")
    except Exception as e:
        print(f"❌ Error initializing Firebase: {e}")
        print("\n⚠️  Make sure you have:")
        print("   1. Created a Firebase project at https://console.firebase.google.com")
        print("   2. Downloaded firebase-service-account.json file")
        print("   3. Placed it in the project root directory")
