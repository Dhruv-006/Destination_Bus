from flask import Flask, render_template, redirect, url_for, request, session, flash, jsonify
from functools import wraps
from datetime import datetime
import firebase_service as fb

app = Flask(__name__)
app.secret_key = "change_this_secret"


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

        admin = fb.get_admin_by_username(username)

        if admin and admin.get("password") == password:
            session["admin_id"] = admin.get("id")
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
    buses = fb.get_all_buses()
    drivers = fb.get_all_drivers()
    routes = fb.get_all_routes()
    maintenance = fb.get_all_maintenance()
    live_locations = fb.get_live_locations()

    # Calculate statistics
    active_buses = len([b for b in buses if b.get("status", "") == "Active"])
    inactive_buses = len([b for b in buses if b.get("status", "") == "In Depot"])
    breakdown_buses = len([b for b in buses if b.get("status", "") == "Breakdown"])
    present_drivers = len([d for d in drivers if d.get("attendance", "") == "Present"])
    absent_drivers = len([d for d in drivers if d.get("attendance", "") == "Absent"])
    pending_maintenance = len([m for m in maintenance if m.get("status", "") == "Pending"])
    resolved_maintenance = len([m for m in maintenance if m.get("status", "") == "Resolved"])
    
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

    return render_template(
        "dashboard.html",
        summary=summary,
        buses=buses,
        drivers=drivers,
        routes=routes,
        maintenance=maintenance,
        live_locations=live_locations,
    )


# -------------- BASIC LIST PAGES (OPTIONAL, OLD NAV) -------------- 
@app.route("/buses")
@login_required
def list_buses():
    buses = fb.get_all_buses()
    return render_template("buses.html", buses=buses)


@app.route("/drivers")
@login_required
def list_drivers():
    drivers = fb.get_all_drivers()
    return render_template("drivers.html", drivers=drivers)


@app.route("/routes")
@login_required
def list_routes():
    routes = fb.get_all_routes()
    return render_template("routes.html", routes=routes)


@app.route("/maintenance")
@login_required
def maintenance_page():
    logs = fb.get_all_maintenance()
    return render_template("maintenance.html", logs=logs)


# -------------- API ROUTES FOR main.js --------------

# Add Bus
@app.route("/api/buses", methods=["POST"])
@login_required
def api_add_bus():
    data = request.get_json() or {}

    bus_data = {
        "number": data.get("number"),
        "route_id": data.get("route_id"),
        "status": data.get("status") or "Active",
    }
    bus_id = fb.add_bus(bus_data)
    return jsonify({"ok": True, "bus_id": bus_id})

# Update Bus
@app.route("/api/buses/<bus_id>", methods=["PUT"])
@login_required
def api_update_bus(bus_id):
    data = request.get_json() or {}
    bus = fb.get_bus_by_id(bus_id)
    if not bus:
        return jsonify({"error": "Bus not found"}), 404
    
    update_data = {}
    if "number" in data:
        update_data["number"] = data.get("number")
    if "route_id" in data:
        update_data["route_id"] = data.get("route_id")
    if "status" in data:
        update_data["status"] = data.get("status")
    
    fb.update_bus(bus_id, update_data)
    return jsonify({"ok": True})

# Delete Bus
@app.route("/api/buses/<bus_id>", methods=["DELETE"])
@login_required
def api_delete_bus(bus_id):
    bus = fb.get_bus_by_id(bus_id)
    if not bus:
        return jsonify({"error": "Bus not found"}), 404
    
    fb.delete_bus(bus_id)
    return jsonify({"ok": True})


# Add Driver
@app.route("/api/drivers", methods=["POST"])
@login_required
def api_add_driver():
    data = request.get_json() or {}

    driver_data = {
        "name": data.get("name"),
        "phone": data.get("phone"),
        "attendance": "Absent",
    }
    driver_id = fb.add_driver(driver_data)
    return jsonify({"ok": True, "driver_id": driver_id})

# Update Driver
@app.route("/api/drivers/<driver_id>", methods=["PUT"])
@login_required
def api_update_driver(driver_id):
    data = request.get_json() or {}
    driver = fb.get_driver_by_id(driver_id)
    if not driver:
        return jsonify({"error": "Driver not found"}), 404
    
    update_data = {}
    if "name" in data:
        update_data["name"] = data.get("name")
    if "phone" in data:
        update_data["phone"] = data.get("phone")
    if "attendance" in data:
        update_data["attendance"] = data.get("attendance")
    
    fb.update_driver(driver_id, update_data)
    return jsonify({"ok": True})

# Delete Driver
@app.route("/api/drivers/<driver_id>", methods=["DELETE"])
@login_required
def api_delete_driver(driver_id):
    driver = fb.get_driver_by_id(driver_id)
    if not driver:
        return jsonify({"error": "Driver not found"}), 404
    
    fb.delete_driver(driver_id)
    return jsonify({"ok": True})


# Update Attendance
@app.route("/api/drivers/<driver_id>/attendance", methods=["POST"])
@login_required
def api_driver_attendance(driver_id):
    data = request.get_json() or {}
    status = data.get("status")

    driver = fb.get_driver_by_id(driver_id)
    if not driver:
        return jsonify({"error": "Driver not found"}), 404

    fb.update_driver_attendance(driver_id, status)
    return jsonify({"ok": True})


# Add Route
@app.route("/api/routes", methods=["POST"])
@login_required
def api_add_route():
    data = request.get_json() or {}

    route_data = {
        "name": data.get("name"),
        "start_stop": data.get("start_stop"),
        "end_stop": data.get("end_stop"),
        "first_bus": data.get("first_bus"),
        "last_bus": data.get("last_bus"),
        "frequency_min": int(data.get("frequency_min")) if data.get("frequency_min") else None,
    }
    route_id = fb.add_route(route_data)
    return jsonify({"ok": True, "route_id": route_id})

# Update Route
@app.route("/api/routes/<route_id>", methods=["PUT"])
@login_required
def api_update_route(route_id):
    data = request.get_json() or {}
    route = fb.get_route_by_id(route_id)
    if not route:
        return jsonify({"error": "Route not found"}), 404
    
    update_data = {}
    if "name" in data:
        update_data["name"] = data.get("name")
    if "start_stop" in data:
        update_data["start_stop"] = data.get("start_stop")
    if "end_stop" in data:
        update_data["end_stop"] = data.get("end_stop")
    if "first_bus" in data:
        update_data["first_bus"] = data.get("first_bus")
    if "last_bus" in data:
        update_data["last_bus"] = data.get("last_bus")
    if "frequency_min" in data:
        update_data["frequency_min"] = int(data.get("frequency_min")) if data.get("frequency_min") else None
    
    fb.update_route(route_id, update_data)
    return jsonify({"ok": True})

# Delete Route
@app.route("/api/routes/<route_id>", methods=["DELETE"])
@login_required
def api_delete_route(route_id):
    route = fb.get_route_by_id(route_id)
    if not route:
        return jsonify({"error": "Route not found"}), 404
    
    fb.delete_route(route_id)
    return jsonify({"ok": True})


# Add Maintenance
@app.route("/api/maintenance", methods=["POST"])
@login_required
def api_add_maintenance():
    data = request.get_json() or {}

    maintenance_data = {
        "bus_id": int(data.get("bus_id")) if data.get("bus_id") else None,
        "issue": data.get("issue"),
        "status": data.get("status") or "Pending",
    }
    maintenance_id = fb.add_maintenance(maintenance_data)
    return jsonify({"ok": True, "id": maintenance_id})

# Update Maintenance
@app.route("/api/maintenance/<maintenance_id>", methods=["PUT"])
@login_required
def api_update_maintenance(maintenance_id):
    data = request.get_json() or {}
    log = fb.get_maintenance_by_id(maintenance_id)
    if not log:
        return jsonify({"error": "Maintenance record not found"}), 404
    
    update_data = {}
    if "bus_id" in data:
        update_data["bus_id"] = int(data.get("bus_id")) if data.get("bus_id") else None
    if "issue" in data:
        update_data["issue"] = data.get("issue")
    if "status" in data:
        update_data["status"] = data.get("status")
    
    fb.update_maintenance(maintenance_id, update_data)
    return jsonify({"ok": True})

# Delete Maintenance
@app.route("/api/maintenance/<maintenance_id>", methods=["DELETE"])
@login_required
def api_delete_maintenance(maintenance_id):
    log = fb.get_maintenance_by_id(maintenance_id)
    if not log:
        return jsonify({"error": "Maintenance record not found"}), 404
    
    fb.delete_maintenance(maintenance_id)
    return jsonify({"ok": True})


# AI Prediction (dummy logic)
@app.route("/api/predictions")
@login_required
def api_predictions():
    bus_id = request.args.get("bus_id")
    if not bus_id:
        return jsonify({"error": "bus_id required"}), 400

    # Dummy prediction – hackathon demo ke liye
    return jsonify({
        "bus_id": bus_id,
        "predicted_eta_min": 7,
        "crowd_level": "Medium",
        "is_peak_hour": False,
        "analysis": "Based on current demo data, crowd medium and ETA around 7 minutes."
    })


if __name__ == "__main__":
    app.run(debug=True)
