from flask_sqlalchemy import SQLAlchemy

db = SQLAlchemy()


class Admin(db.Model):
    __tablename__ = 'admin'
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    password = db.Column(db.String(120), nullable=False)


class Bus(db.Model):
    __tablename__ = 'bus'
    bus_id = db.Column(db.Integer, primary_key=True)
    number = db.Column(db.String(50), nullable=False)
    route_id = db.Column(db.Integer, db.ForeignKey('route.route_id'), nullable=True)
    status = db.Column(db.String(20), default='Active')  # Active / In Depot / Breakdown


class Driver(db.Model):
    __tablename__ = 'driver'
    driver_id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    phone = db.Column(db.String(20), nullable=False)
    attendance = db.Column(db.String(20), default='Absent')  # Present / Absent


class Route(db.Model):
    __tablename__ = 'route'
    route_id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    start_stop = db.Column(db.String(100), nullable=False)
    end_stop = db.Column(db.String(100), nullable=False)
    first_bus = db.Column(db.String(10), nullable=True)
    last_bus = db.Column(db.String(10), nullable=True)
    frequency_min = db.Column(db.Integer, nullable=True)


class MaintenanceLog(db.Model):
    __tablename__ = 'maintenance_log'
    id = db.Column(db.Integer, primary_key=True)
    bus_id = db.Column(db.Integer, db.ForeignKey('bus.bus_id'), nullable=False)
    issue = db.Column(db.String(255), nullable=False)
    status = db.Column(db.String(20), default='Pending')  # Pending / In Progress / Resolved
    reported_at = db.Column(db.DateTime, default=db.func.current_timestamp())
    reported_on = db.Column(db.String(50), nullable=True)  # For display purposes

    bus = db.relationship('Bus', backref='maintenance_logs')
