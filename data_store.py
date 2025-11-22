from datetime import datetime, time


class DataStore:
    def __init__(self):
        # dummy seed data (Bhavnagar flavour)
        self.buses = [
            {
                "bus_id": "BHN-101",
                "route_id": "R1",
                "number": "101",
                "status": "Active",  # Active / In Depot / Breakdown
            },
            {
                "bus_id": "BHN-102",
                "route_id": "R2",
                "number": "102",
                "status": "In Depot",
            },
        ]

        self.drivers = [
            {"driver_id": "D1", "name": "Ramesh", "phone": "9876543210", "attendance": "Present"},
            {"driver_id": "D2", "name": "Suresh", "phone": "9876501234", "attendance": "Absent"},
        ]

        self.routes = [
            {
                "route_id": "R1",
                "name": "Takhteshwar - Ghogha Circle",
                "start_stop": "Takhteshwar",
                "end_stop": "Ghogha Circle",
                "first_bus": "06:00",
                "last_bus": "22:00",
                "frequency_min": 15,
            },
            {
                "route_id": "R2",
                "name": "Bus Stand - Alang Road",
                "start_stop": "Bhavnagar Bus Stand",
                "end_stop": "Alang Road",
                "first_bus": "06:30",
                "last_bus": "21:30",
                "frequency_min": 20,
            },
        ]

        self.maintenance = [
            {
                "id": 1,
                "bus_id": "BHN-102",
                "issue": "Engine check",
                "status": "Pending",
                "reported_on": "2025-11-20",
            }
        ]

        # bus_id -> live info
        self.live_locations = {
            "BHN-101": {
                "lat": 21.7643,
                "lng": 72.1511,
                "speed": 30,
                "occupancy": 25,
                "last_update": datetime.now().isoformat(timespec="seconds"),
            }
        }

    # ---------- BASIC GETTERS ----------
    def get_buses(self):
        return self.buses

    def get_drivers(self):
        return self.drivers

    def get_routes(self):
        return self.routes

    def get_maintenance(self):
        return self.maintenance

    def get_live_locations(self):
        return self.live_locations

    # ---------- SUMMARY ----------
    def get_summary(self):
        total_buses = len(self.buses)
        active_buses = len([b for b in self.buses if b["status"] == "Active"])
        total_drivers = len(self.drivers)
        present_drivers = len([d for d in self.drivers if d["attendance"] == "Present"])

        return {
            "total_buses": total_buses,
            "active_buses": active_buses,
            "total_drivers": total_drivers,
            "present_drivers": present_drivers,
            "total_routes": len(self.routes),
        }

    # ---------- MUTATORS ----------
    def add_bus(self, data):
        bus = {
            "bus_id": data.get("bus_id", f"BHN-{100 + len(self.buses) + 1}"),
            "route_id": data.get("route_id", ""),
            "number": data.get("number", ""),
            "status": data.get("status", "Active"),
        }
        self.buses.append(bus)

    def add_driver(self, data):
        driver = {
            "driver_id": data.get("driver_id", f"D{len(self.drivers) + 1}"),
            "name": data.get("name", ""),
            "phone": data.get("phone", ""),
            "attendance": data.get("attendance", "Present"),
        }
        self.drivers.append(driver)

    def mark_attendance(self, driver_id, status):
        for d in self.drivers:
            if d["driver_id"] == driver_id:
                d["attendance"] = status
                break

    def add_route(self, data):
        route = {
            "route_id": data.get("route_id", f"R{len(self.routes) + 1}"),
            "name": data.get("name", ""),
            "start_stop": data.get("start_stop", ""),
            "end_stop": data.get("end_stop", ""),
            "first_bus": data.get("first_bus", "06:00"),
            "last_bus": data.get("last_bus", "22:00"),
            "frequency_min": int(data.get("frequency_min", 15)),
        }
        self.routes.append(route)

    def add_maintenance(self, data):
        mid = len(self.maintenance) + 1
        m = {
            "id": mid,
            "bus_id": data.get("bus_id", ""),
            "issue": data.get("issue", ""),
            "status": data.get("status", "Pending"),
            "reported_on": data.get("reported_on", datetime.now().date().isoformat()),
        }
        self.maintenance.append(m)

    def update_live_location(self, bus_id, lat, lng, speed=0, occupancy=0):
        self.live_locations[bus_id] = {
            "lat": lat,
            "lng": lng,
            "speed": speed,
            "occupancy": occupancy,
            "last_update": datetime.now().isoformat(timespec="seconds"),
        }

    # ---------- "AI" PREDICTION ----------
    def predict_bus_status(self, bus_id):
        if bus_id not in self.live_locations:
            return None

        live = self.live_locations[bus_id]

        # simple heuristic "AI":
        # peak hours: 8–11 AM and 5–8 PM in Bhavnagar
        now = datetime.now().time()
        peak = (
            time(8, 0) <= now <= time(11, 0)
            or time(17, 0) <= now <= time(20, 0)
        )

        occupancy = live.get("occupancy", 0)
        speed = live.get("speed", 0)

        if occupancy < 20:
            crowd_level = "LOW"
        elif occupancy < 40:
            crowd_level = "MEDIUM"
        else:
            crowd_level = "HIGH"

        # pseudo ETA: assume fixed remaining distance ~ 8 km
        remaining_km = 8
        if speed <= 5:
            eta_min = 25 if peak else 20
        else:
            eta_min = int(remaining_km / max(speed, 10) * 60)
            if peak:
                eta_min += 5  # delay in peak

        return {
            "bus_id": bus_id,
            "predicted_eta_min": eta_min,
            "crowd_level": crowd_level,
            "is_peak_hour": peak,
            "analysis": f"Bus {bus_id} is expected to reach next major stop in ~{eta_min} minutes with {crowd_level} crowd.",
        }
