from flask import Flask, render_template, redirect, url_for, request, session, flash, jsonify
from flask_cors import CORS
from functools import wraps
from datetime import datetime
from models import db, Admin, Bus, Driver, Route, MaintenanceLog

app = Flask(__name__)
app.config["SQLALCHEMY_DATABASE_URI"] = "sqlite:///smart_bus.db"
app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False
app.secret_key = "change_this_secret"

# Enable CORS for Flutter app
CORS(app, resources={r"/api/*": {"origins": "*"}})

db.init_app(app)


# -------------- LOGIN REQUIRED DECORATOR -------------- 
def login_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if "admin_id" not in session:
            flash("Please login first.", "warning")
            return redirect(url_for("login"))
        return f(*args, **kwargs)
    return decorated_function


# -------------- LOGIN / LOGOUT -------------- 
@app.route("/", methods=["GET", "POST"])
def login():
    if request.method == "POST":
        username = request.form.get("username")
        password = request.form.get("password")

        admin = Admin.query.filter_by(username=username, password=password).first()

        if admin:
            session["admin_id"] = admin.id
            flash("Login successful!", "success")
            return redirect(url_for("dashboard"))
        else:
            flash("Invalid credentials", "danger")

    return render_template("login.html")


@app.route("/logout")
def logout():
    session.clear()
    flash("Logged out.", "info")
    return redirect(url_for("login"))


# -------------- DASHBOARD PAGE (SINGLE PAGE UI) -------------- 
@app.route("/dashboard")
@login_required
def dashboard():
    buses = Bus.query.all()
    drivers = Driver.query.all()
    routes = Route.query.all()
    maintenance = MaintenanceLog.query.order_by(MaintenanceLog.reported_at.desc()).all() \
        if hasattr(MaintenanceLog, "reported_at") else MaintenanceLog.query.all()

    # Calculate statistics
    active_buses = len([b for b in buses if getattr(b, "status", "") == "Active"])
    inactive_buses = len([b for b in buses if getattr(b, "status", "") == "In Depot"])
    breakdown_buses = len([b for b in buses if getattr(b, "status", "") == "Breakdown"])
    present_drivers = len([d for d in drivers if getattr(d, "attendance", "") == "Present"])
    absent_drivers = len([d for d in drivers if getattr(d, "attendance", "") == "Absent"])
    pending_maintenance = len([m for m in maintenance if getattr(m, "status", "") == "Pending"])
    resolved_maintenance = len([m for m in maintenance if getattr(m, "status", "") == "Resolved"])
    
    summary = {
        "total_buses": len(buses),
        "active_buses": active_buses,
        "inactive_buses": inactive_buses,
        "breakdown_buses": breakdown_buses,
        "total_drivers": len(drivers),
        "present_drivers": present_drivers,
        "absent_drivers": absent_drivers,
        "total_routes": len(routes),
        "total_maintenance": len(maintenance),
        "pending_maintenance": pending_maintenance,
        "resolved_maintenance": resolved_maintenance,
    }

    live_locations = {}

    return render_template(
        "dashboard.html",
        summary=summary,
        buses=buses,
        drivers=drivers,
        routes=routes,
        maintenance=maintenance,
        live_locations=live_locations,
    )


# -------------- PUBLIC API ROUTES FOR FLUTTER APP (NO AUTH REQUIRED) -------------- 

@app.route("/api/public/buses", methods=["GET"])
def api_public_buses():
    """Get all buses - Public API for Flutter app"""
    buses = Bus.query.all()
    return jsonify([{
        "bus_id": b.bus_id,
        "number": b.number,
        "route_id": b.route_id,
        "status": b.status
    } for b in buses])


@app.route("/api/public/routes", methods=["GET"])
def api_public_routes():
    """Get all routes - Public API for Flutter app"""
    routes = Route.query.all()
    return jsonify([{
        "route_id": r.route_id,
        "name": r.name,
        "start_stop": r.start_stop,
        "end_stop": r.end_stop,
        "first_bus": r.first_bus,
        "last_bus": r.last_bus,
        "frequency_min": r.frequency_min
    } for r in routes])


@app.route("/api/public/drivers", methods=["GET"])
def api_public_drivers():
    """Get all drivers - Public API for Flutter app"""
    drivers = Driver.query.all()
    return jsonify([{
        "driver_id": d.driver_id,
        "name": d.name,
        "phone": d.phone,
        "attendance": d.attendance
    } for d in drivers])


@app.route("/api/public/location-update", methods=["POST"])
def api_location_update():
    """Update bus location - Public API for Flutter app"""
    data = request.get_json() or {}
    bus_id = data.get("bus_id")
    lat = data.get("lat")
    lng = data.get("lng")
    speed = data.get("speed", 0)
    occupancy = data.get("occupancy", 0)
    
    if not bus_id or not lat or not lng:
        return jsonify({"error": "bus_id, lat, and lng are required"}), 400
    
    # Store location update (you can create a LiveLocation model if needed)
    # For now, we'll just return success
    return jsonify({
        "ok": True,
        "message": "Location updated",
        "bus_id": bus_id,
        "timestamp": datetime.now().isoformat()
    })


# -------------- ADMIN API ROUTES (REQUIRE LOGIN) -------------- 

# Add Bus
@app.route("/api/buses", methods=["POST"])
@login_required
def api_add_bus():
    data = request.get_json() or {}

    bus = Bus(
        number=data.get("number"),
        route_id=data.get("route_id"),
        status=data.get("status") or "Active",
    )
    db.session.add(bus)
    db.session.commit()
    return jsonify({"ok": True, "bus_id": bus.bus_id})

# Update Bus
@app.route("/api/buses/<int:bus_id>", methods=["PUT"])
@login_required
def api_update_bus(bus_id):
    data = request.get_json() or {}
    bus = Bus.query.get(bus_id)
    if not bus:
        return jsonify({"error": "Bus not found"}), 404
    
    if "number" in data:
        bus.number = data.get("number")
    if "route_id" in data:
        bus.route_id = data.get("route_id")
    if "status" in data:
        bus.status = data.get("status")
    
    db.session.commit()
    return jsonify({"ok": True})

# Delete Bus
@app.route("/api/buses/<int:bus_id>", methods=["DELETE"])
@login_required
def api_delete_bus(bus_id):
    bus = Bus.query.get(bus_id)
    if not bus:
        return jsonify({"error": "Bus not found"}), 404
    
    db.session.delete(bus)
    db.session.commit()
    return jsonify({"ok": True})


# Add Driver
@app.route("/api/drivers", methods=["POST"])
@login_required
def api_add_driver():
    data = request.get_json() or {}

    driver = Driver(
        name=data.get("name"),
        phone=data.get("phone"),
        attendance="Absent",
    )
    db.session.add(driver)
    db.session.commit()
    return jsonify({"ok": True, "driver_id": driver.driver_id})

# Update Driver
@app.route("/api/drivers/<int:driver_id>", methods=["PUT"])
@login_required
def api_update_driver(driver_id):
    data = request.get_json() or {}
    driver = Driver.query.get(driver_id)
    if not driver:
        return jsonify({"error": "Driver not found"}), 404
    
    if "name" in data:
        driver.name = data.get("name")
    if "phone" in data:
        driver.phone = data.get("phone")
    if "attendance" in data:
        driver.attendance = data.get("attendance")
    
    db.session.commit()
    return jsonify({"ok": True})

# Delete Driver
@app.route("/api/drivers/<int:driver_id>", methods=["DELETE"])
@login_required
def api_delete_driver(driver_id):
    driver = Driver.query.get(driver_id)
    if not driver:
        return jsonify({"error": "Driver not found"}), 404
    
    db.session.delete(driver)
    db.session.commit()
    return jsonify({"ok": True})


# Update Attendance
@app.route("/api/drivers/<int:driver_id>/attendance", methods=["POST"])
@login_required
def api_driver_attendance(driver_id):
    data = request.get_json() or {}
    status = data.get("status")

    driver = Driver.query.get(driver_id)
    if not driver:
        return jsonify({"error": "Driver not found"}), 404

    driver.attendance = status
    db.session.commit()
    return jsonify({"ok": True})


# Add Route
@app.route("/api/routes", methods=["POST"])
@login_required
def api_add_route():
    data = request.get_json() or {}

    route = Route(
        name=data.get("name"),
        start_stop=data.get("start_stop"),
        end_stop=data.get("end_stop"),
        first_bus=data.get("first_bus"),
        last_bus=data.get("last_bus"),
        frequency_min=data.get("frequency_min"),
    )
    db.session.add(route)
    db.session.commit()
    return jsonify({"ok": True, "route_id": route.route_id})

# Update Route
@app.route("/api/routes/<int:route_id>", methods=["PUT"])
@login_required
def api_update_route(route_id):
    data = request.get_json() or {}
    route = Route.query.get(route_id)
    if not route:
        return jsonify({"error": "Route not found"}), 404
    
    if "name" in data:
        route.name = data.get("name")
    if "start_stop" in data:
        route.start_stop = data.get("start_stop")
    if "end_stop" in data:
        route.end_stop = data.get("end_stop")
    if "first_bus" in data:
        route.first_bus = data.get("first_bus")
    if "last_bus" in data:
        route.last_bus = data.get("last_bus")
    if "frequency_min" in data:
        route.frequency_min = data.get("frequency_min")
    
    db.session.commit()
    return jsonify({"ok": True})

# Delete Route
@app.route("/api/routes/<int:route_id>", methods=["DELETE"])
@login_required
def api_delete_route(route_id):
    route = Route.query.get(route_id)
    if not route:
        return jsonify({"error": "Route not found"}), 404
    
    db.session.delete(route)
    db.session.commit()
    return jsonify({"ok": True})


# Add Maintenance
@app.route("/api/maintenance", methods=["POST"])
@login_required
def api_add_maintenance():
    data = request.get_json() or {}

    log = MaintenanceLog(
        bus_id=data.get("bus_id"),
        issue=data.get("issue"),
        status=data.get("status") or "Pending",
        reported_on=datetime.now().strftime("%Y-%m-%d %H:%M")
    )
    db.session.add(log)
    db.session.commit()
    return jsonify({"ok": True, "id": log.id})

# Update Maintenance
@app.route("/api/maintenance/<int:maintenance_id>", methods=["PUT"])
@login_required
def api_update_maintenance(maintenance_id):
    data = request.get_json() or {}
    log = MaintenanceLog.query.get(maintenance_id)
    if not log:
        return jsonify({"error": "Maintenance record not found"}), 404
    
    if "bus_id" in data:
        log.bus_id = data.get("bus_id")
    if "issue" in data:
        log.issue = data.get("issue")
    if "status" in data:
        log.status = data.get("status")
    
    db.session.commit()
    return jsonify({"ok": True})

# Delete Maintenance
@app.route("/api/maintenance/<int:maintenance_id>", methods=["DELETE"])
@login_required
def api_delete_maintenance(maintenance_id):
    log = MaintenanceLog.query.get(maintenance_id)
    if not log:
        return jsonify({"error": "Maintenance record not found"}), 404
    
    db.session.delete(log)
    db.session.commit()
    return jsonify({"ok": True})


# AI Prediction (dummy logic)
@app.route("/api/predictions")
@login_required
def api_predictions():
    bus_id = request.args.get("bus_id")
    if not bus_id:
        return jsonify({"error": "bus_id required"}), 400

    return jsonify({
        "bus_id": bus_id,
        "predicted_eta_min": 7,
        "crowd_level": "Medium",
        "is_peak_hour": False,
        "analysis": "Based on current demo data, crowd medium and ETA around 7 minutes."
    })


# -------------- BASIC LIST PAGES (OPTIONAL, OLD NAV) -------------- 
@app.route("/buses")
@login_required
def list_buses():
    buses = Bus.query.all()
    return render_template("buses.html", buses=buses)


@app.route("/drivers")
@login_required
def list_drivers():
    drivers = Driver.query.all()
    return render_template("drivers.html", drivers=drivers)


@app.route("/routes")
@login_required
def list_routes():
    routes = Route.query.all()
    return render_template("routes.html", routes=routes)


@app.route("/maintenance")
@login_required
def maintenance_page():
    logs = MaintenanceLog.query.all()
    return render_template("maintenance.html", logs=logs)


if __name__ == "__main__":
    app.run(debug=True, host='0.0.0.0', port=5000)
