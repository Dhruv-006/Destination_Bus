# create_db.py
from app import app, db
from models import Admin, Bus, Driver, Route, MaintenanceLog

with app.app_context():
    # Drop all tables and recreate
    db.drop_all()
    db.create_all()

    # default admin user
    admin = Admin(username='admin', password='admin123')
    db.session.add(admin)
    db.session.commit()

    print("Database & tables created, default admin user added.")
    print("Default credentials:")
    print("   Username: admin")
    print("   Password: admin123")
