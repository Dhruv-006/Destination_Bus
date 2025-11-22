// ============================================
// MODERN SMART BUS ADMIN - ENHANCED JAVASCRIPT
// ============================================

// Real-time update flag
let realTimeListenersActive = false;

// ============================================
// FIREBASE REAL-TIME LISTENERS
// ============================================

function setupRealTimeListeners() {
  if (!window.firebaseDb || realTimeListenersActive || !window.firebaseReady) {
    if (!window.firebaseReady) {
      console.warn('Firebase not initialized. Real-time updates disabled. Please configure Firebase in dashboard.html');
    }
    return;
  }
  
  try {
    const db = window.firebaseDb;
    
    // Listen to buses collection
    db.collection('buses').onSnapshot((snapshot) => {
      const buses = snapshot.docs.map(doc => {
        const data = doc.data();
        return { bus_id: doc.id, id: doc.id, ...data };
      });
      updateBusesTable(buses);
      updateDashboardSummary(); // Update summary cards
    });
    
    // Listen to drivers collection
    db.collection('drivers').onSnapshot((snapshot) => {
      const drivers = snapshot.docs.map(doc => {
        const data = doc.data();
        return { driver_id: doc.id, id: doc.id, ...data };
      });
      updateDriversTable(drivers);
      updateDashboardSummary(); // Update summary cards
    });
    
    // Listen to routes collection
    db.collection('routes').onSnapshot((snapshot) => {
      const routes = snapshot.docs.map(doc => {
        const data = doc.data();
        return { route_id: doc.id, id: doc.id, ...data };
      });
      updateRoutesTable(routes);
      updateDashboardSummary(); // Update summary cards
    });
    
    // Listen to maintenance collection (ordered by reported_at desc)
    db.collection('maintenance_logs')
      .orderBy('reported_at', 'desc')
      .onSnapshot((snapshot) => {
        const maintenance = snapshot.docs.map(doc => {
          const data = doc.data();
          const reportedAt = data.reported_at;
          return {
            id: doc.id,
            ...data,
            reported_on: reportedAt ? 
              (reportedAt.toDate ? reportedAt.toDate().toLocaleString() : 
               (typeof reportedAt === 'string' ? reportedAt : new Date(reportedAt).toLocaleString())) :
              'N/A'
          };
        });
        updateMaintenanceTable(maintenance);
        updateDashboardSummary(); // Update summary cards
      });
    
    realTimeListenersActive = true;
    console.log('✅ Real-time listeners activated');
  } catch (error) {
    console.warn('Real-time listeners not available:', error);
    console.log('Make sure Firebase is properly configured in dashboard.html');
  }
}

// Update dashboard summary cards in real-time
function updateDashboardSummary() {
  // This will be called when data changes to update the summary cards
  // For now, we'll reload the summary data from the server
  // In a full implementation, you could calculate this from the real-time data
  if (document.getElementById('overview')?.classList.contains('active')) {
    // Refresh summary by fetching from server or recalculating from current data
    fetch('/dashboard')
      .then(response => response.text())
      .then(html => {
        // Parse and update summary cards
        // This is a simplified approach - in production, you'd want an API endpoint
      })
      .catch(err => console.log('Summary update skipped:', err));
  }
}

// Update functions for real-time data
function updateBusesTable(buses) {
  const tbody = document.querySelector('#buses tbody');
  if (!tbody) return;
  
  tbody.innerHTML = buses.map(bus => `
    <tr data-bus-id="${bus.id || bus.bus_id}">
      <td>${bus.id || bus.bus_id}</td>
      <td>${bus.number || ''}</td>
      <td>${bus.route_id || 'N/A'}</td>
      <td><span class="status-badge ${(bus.status || '').toLowerCase().replace(' ', '-')}">${bus.status || 'Active'}</span></td>
      <td>
        <button class="btn-small btn-edit" onclick="editBus('${bus.id || bus.bus_id}', '${bus.number || ''}', ${bus.route_id || 'null'}, '${bus.status || 'Active'}')">✏️ Edit</button>
        <button class="btn-small btn-delete" onclick="deleteBus('${bus.id || bus.bus_id}', '${bus.number || ''}')">🗑️ Delete</button>
      </td>
    </tr>
  `).join('');
}

function updateDriversTable(drivers) {
  const tbody = document.getElementById('driversTable');
  if (!tbody) return;
  
  tbody.innerHTML = drivers.map(driver => `
    <tr data-driver-id="${driver.id || driver.driver_id}">
      <td>${driver.id || driver.driver_id}</td>
      <td>${driver.name || ''}</td>
      <td>${driver.phone || ''}</td>
      <td class="attendance"><span class="status-badge ${(driver.attendance || 'Absent').toLowerCase()}">${driver.attendance || 'Absent'}</span></td>
      <td>
        <button class="btn-small mark-present">✓ Present</button>
        <button class="btn-small mark-absent">✗ Absent</button>
        <button class="btn-small btn-edit" onclick="editDriver('${driver.id || driver.driver_id}', '${driver.name || ''}', '${driver.phone || ''}')">✏️ Edit</button>
        <button class="btn-small btn-delete" onclick="deleteDriver('${driver.id || driver.driver_id}', '${driver.name || ''}')">🗑️ Delete</button>
      </td>
    </tr>
  `).join('');
  
  // Re-attach event listeners
  attachDriverAttendanceListeners();
}

function updateRoutesTable(routes) {
  const tbody = document.querySelector('#routes tbody');
  if (!tbody) return;
  
  tbody.innerHTML = routes.map(route => `
    <tr data-route-id="${route.id || route.route_id}">
      <td>${route.id || route.route_id}</td>
      <td>${route.name || ''}</td>
      <td>${route.start_stop || ''}</td>
      <td>${route.end_stop || ''}</td>
      <td>${route.first_bus || 'N/A'}</td>
      <td>${route.last_bus || 'N/A'}</td>
      <td>${route.frequency_min || 'N/A'}</td>
      <td>
        <button class="btn-small btn-edit" onclick="editRoute('${route.id || route.route_id}', '${route.name || ''}', '${route.start_stop || ''}', '${route.end_stop || ''}', '${route.first_bus || ''}', '${route.last_bus || ''}', ${route.frequency_min || 'null'})">✏️ Edit</button>
        <button class="btn-small btn-delete" onclick="deleteRoute('${route.id || route.route_id}', '${route.name || ''}')">🗑️ Delete</button>
      </td>
    </tr>
  `).join('');
}

function updateMaintenanceTable(maintenance) {
  const tbody = document.querySelector('#maintenance tbody');
  if (!tbody) return;
  
  tbody.innerHTML = maintenance.map(m => `
    <tr data-maintenance-id="${m.id}">
      <td>${m.id}</td>
      <td>${m.bus_id || ''}</td>
      <td>${m.issue || ''}</td>
      <td><span class="status-badge ${(m.status || 'Pending').toLowerCase().replace(' ', '-')}">${m.status || 'Pending'}</span></td>
      <td>${m.reported_on || (m.reported_at ? new Date(m.reported_at.seconds * 1000).toLocaleString() : 'N/A')}</td>
      <td>
        <button class="btn-small btn-edit" onclick="editMaintenance('${m.id}', ${m.bus_id || 'null'}, '${(m.issue || '').replace(/'/g, "\\'")}', '${m.status || 'Pending'}')">✏️ Edit</button>
        <button class="btn-small btn-delete" onclick="deleteMaintenance('${m.id}')">🗑️ Delete</button>
      </td>
    </tr>
  `).join('');
}

// Helper to re-attach driver attendance listeners
function attachDriverAttendanceListeners() {
  const driversTable = document.getElementById("driversTable");
  if (driversTable) {
    driversTable.addEventListener("click", async (e) => {
      const btn = e.target;
      if (!btn.classList.contains("mark-present") && !btn.classList.contains("mark-absent"))
        return;

      const row = btn.closest("tr");
      const driverId = row.dataset.driverId;
      const status = btn.classList.contains("mark-present") ? "Present" : "Absent";
      const driverName = row.querySelector('td:nth-child(2)').textContent;

      try {
        setButtonLoading(btn, true);
        await postJSON(`/api/drivers/${driverId}/attendance`, { status });
        
        const attendanceCell = row.querySelector(".attendance");
        attendanceCell.innerHTML = `<span class="status-badge ${status.toLowerCase()}">${status}</span>`;
        attendanceCell.style.animation = 'none';
        setTimeout(() => {
          attendanceCell.style.animation = 'fadeIn 0.5s ease-in';
        }, 10);
        
        row.style.background = status === 'Present' ? 'rgba(16, 185, 129, 0.1)' : 'rgba(239, 68, 68, 0.1)';
        setTimeout(() => {
          row.style.background = '';
        }, 2000);
        
        showSuccess(`Attendance marked as ${status} for ${driverName}`);
      } catch (error) {
        showError("Failed to update attendance. Please try again.");
        console.error(error);
      } finally {
        setButtonLoading(btn, false);
      }
    });
  }
}

// Tab switch with animation
const tabs = document.querySelectorAll(".sidebar li");
const tabContent = document.querySelectorAll(".tab");

tabs.forEach((tab) => {
  tab.addEventListener("click", () => {
    // Remove active class from all tabs
    tabs.forEach((t) => t.classList.remove("active"));
    tab.classList.add("active");

    // Hide all tab content
    const target = tab.getAttribute("data-tab");
    tabContent.forEach((c) => {
      c.classList.remove("active");
      if (c.id === target) {
        setTimeout(() => {
          c.classList.add("active");
        }, 100);
      }
    });
  });
});

// ============================================
// MODAL/POPUP SYSTEM
// ============================================

function showModal(title, message, type = 'info') {
  const overlay = document.createElement('div');
  overlay.className = 'modal-overlay active';
  overlay.innerHTML = `
    <div class="modal">
      <div class="modal-header">
        <h3>${title}</h3>
        <button class="modal-close" onclick="this.closest('.modal-overlay').remove()">&times;</button>
      </div>
      <div class="modal-body">
        <p>${message}</p>
      </div>
      <div class="modal-footer">
        <button class="btn-small" onclick="this.closest('.modal-overlay').remove()" style="background: var(--primary-blue); color: white; padding: 10px 20px;">OK</button>
      </div>
    </div>
  `;
  
  document.body.appendChild(overlay);
  
  // Close on overlay click
  overlay.addEventListener('click', (e) => {
    if (e.target === overlay) {
      overlay.remove();
    }
  });
  
  // Close on Escape key
  const escapeHandler = (e) => {
    if (e.key === 'Escape') {
      overlay.remove();
      document.removeEventListener('keydown', escapeHandler);
    }
  };
  document.addEventListener('keydown', escapeHandler);
}

function showSuccess(message) {
  showModal('✅ Success', message, 'success');
}

function showError(message) {
  showModal('❌ Error', message, 'error');
}

function showInfo(message) {
  showModal('ℹ️ Information', message, 'info');
}

// ============================================
// HELPER FUNCTIONS
// ============================================

async function postJSON(url, data) {
  try {
    const res = await fetch(url, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(data),
    });
    
    if (!res.ok) {
      throw new Error(`HTTP error! status: ${res.status}`);
    }
    
    return await res.json();
  } catch (error) {
    console.error('Error:', error);
    throw error;
  }
}

function setButtonLoading(button, isLoading) {
  if (isLoading) {
    button.disabled = true;
    button.dataset.originalText = button.textContent;
    button.innerHTML = '<span class="loading"></span> Processing...';
  } else {
    button.disabled = false;
    button.textContent = button.dataset.originalText || button.textContent;
  }
}

// ============================================
// ADD BUS FORM
// ============================================

const addBusForm = document.getElementById("addBusForm");
if (addBusForm) {
  addBusForm.addEventListener("submit", async (e) => {
    e.preventDefault();
    const submitBtn = addBusForm.querySelector('button[type="submit"]');
    
    try {
      setButtonLoading(submitBtn, true);
      const formData = new FormData(addBusForm);
      const payload = Object.fromEntries(formData.entries());
      
      await postJSON("/api/buses", payload);
      
      showSuccess("Bus added successfully! Real-time update in progress...");
      addBusForm.reset();
      // Real-time update will handle the refresh automatically
      
      // Animate the form
      addBusForm.style.animation = 'none';
      setTimeout(() => {
        addBusForm.style.animation = 'fadeIn 0.5s ease-in';
      }, 10);
    } catch (error) {
      showError("Failed to add bus. Please try again.");
      console.error(error);
    } finally {
      setButtonLoading(submitBtn, false);
    }
  });
}

// ============================================
// ADD DRIVER FORM
// ============================================

const addDriverForm = document.getElementById("addDriverForm");
if (addDriverForm) {
  addDriverForm.addEventListener("submit", async (e) => {
    e.preventDefault();
    const submitBtn = addDriverForm.querySelector('button[type="submit"]');
    
    try {
      setButtonLoading(submitBtn, true);
      const formData = new FormData(addDriverForm);
      const payload = Object.fromEntries(formData.entries());
      
      await postJSON("/api/drivers", payload);
      
      showSuccess("Driver added successfully! Real-time update in progress...");
      addDriverForm.reset();
      // Real-time update will handle the refresh automatically
    } catch (error) {
      showError("Failed to add driver. Please try again.");
      console.error(error);
    } finally {
      setButtonLoading(submitBtn, false);
    }
  });
}

// ============================================
// MARK ATTENDANCE
// ============================================

const driversTable = document.getElementById("driversTable");
if (driversTable) {
  driversTable.addEventListener("click", async (e) => {
    const btn = e.target;
    if (!btn.classList.contains("mark-present") && !btn.classList.contains("mark-absent"))
      return;

    const row = btn.closest("tr");
    const driverId = row.dataset.driverId;
    const status = btn.classList.contains("mark-present") ? "Present" : "Absent";
    const driverName = row.querySelector('td:nth-child(2)').textContent;

    try {
      setButtonLoading(btn, true);
      await postJSON(`/api/drivers/${driverId}/attendance`, { status });
      
      const attendanceCell = row.querySelector(".attendance");
      attendanceCell.textContent = status;
      attendanceCell.style.animation = 'none';
      setTimeout(() => {
        attendanceCell.style.animation = 'fadeIn 0.5s ease-in';
      }, 10);
      
      // Visual feedback
      row.style.background = status === 'Present' ? 'rgba(16, 185, 129, 0.1)' : 'rgba(239, 68, 68, 0.1)';
      setTimeout(() => {
        row.style.background = '';
      }, 2000);
      
      showSuccess(`Attendance marked as ${status} for ${driverName}`);
    } catch (error) {
      showError("Failed to update attendance. Please try again.");
      console.error(error);
    } finally {
      setButtonLoading(btn, false);
    }
  });
}

// ============================================
// ADD ROUTE FORM
// ============================================

const addRouteForm = document.getElementById("addRouteForm");
if (addRouteForm) {
  addRouteForm.addEventListener("submit", async (e) => {
    e.preventDefault();
    const submitBtn = addRouteForm.querySelector('button[type="submit"]');
    
    try {
      setButtonLoading(submitBtn, true);
      const formData = new FormData(addRouteForm);
      const payload = Object.fromEntries(formData.entries());
      
      await postJSON("/api/routes", payload);
      
      showSuccess("Route added successfully! Real-time update in progress...");
      addRouteForm.reset();
      // Real-time update will handle the refresh automatically
    } catch (error) {
      showError("Failed to add route. Please try again.");
      console.error(error);
    } finally {
      setButtonLoading(submitBtn, false);
    }
  });
}

// ============================================
// ADD MAINTENANCE FORM
// ============================================

const addMaintenanceForm = document.getElementById("addMaintenanceForm");
if (addMaintenanceForm) {
  addMaintenanceForm.addEventListener("submit", async (e) => {
    e.preventDefault();
    const submitBtn = addMaintenanceForm.querySelector('button[type="submit"]');
    
    try {
      setButtonLoading(submitBtn, true);
      const formData = new FormData(addMaintenanceForm);
      const payload = Object.fromEntries(formData.entries());
      
      await postJSON("/api/maintenance", payload);
      
      showSuccess("Maintenance record added successfully! Real-time update in progress...");
      addMaintenanceForm.reset();
      // Real-time update will handle the refresh automatically
    } catch (error) {
      showError("Failed to add maintenance record. Please try again.");
      console.error(error);
    } finally {
      setButtonLoading(submitBtn, false);
    }
  });
}

// ============================================
// AI PREDICTION
// ============================================

const aiBtn = document.getElementById("aiPredictBtn");
if (aiBtn) {
  aiBtn.addEventListener("click", async () => {
    const busId = document.getElementById("aiBusId").value;
    const out = document.getElementById("aiResult");
    
    if (!busId) {
      showError("Please select a bus ID");
      return;
    }
    
    try {
      setButtonLoading(aiBtn, true);
      out.textContent = "Loading prediction...";
      out.style.opacity = '0.7';
      
      const res = await fetch(`/api/predictions?bus_id=${encodeURIComponent(busId)}`);
      const data = await res.json();

      if (data.error) {
        out.textContent = "Error: " + data.error;
        out.style.opacity = '1';
        showError(data.error);
        return;
      }

      out.textContent =
        `🚌 Bus ID: ${data.bus_id}\n\n` +
        `⏱️  Predicted ETA: ${data.predicted_eta_min} minutes\n` +
        `👥 Crowd Level: ${data.crowd_level}\n` +
        `📊 Peak Hour: ${data.is_peak_hour ? "Yes" : "No"}\n\n` +
        `📝 Analysis:\n${data.analysis}`;
      
      out.style.opacity = '1';
      out.style.animation = 'fadeIn 0.5s ease-in';
      
      showInfo("AI prediction generated successfully!");
    } catch (error) {
      out.textContent = "Error: Failed to fetch prediction";
      out.style.opacity = '1';
      showError("Failed to get AI prediction. Please try again.");
      console.error(error);
    } finally {
      setButtonLoading(aiBtn, false);
    }
  });
}

// ============================================
// ENHANCED TABLE INTERACTIONS
// ============================================

// Add hover effects to table rows
document.querySelectorAll('tbody tr').forEach(row => {
  row.addEventListener('mouseenter', function() {
    this.style.transition = 'all 0.2s ease';
  });
});

// ============================================
// SMOOTH SCROLLING
// ============================================

document.querySelectorAll('a[href^="#"]').forEach(anchor => {
  anchor.addEventListener('click', function (e) {
    e.preventDefault();
    const target = document.querySelector(this.getAttribute('href'));
    if (target) {
      target.scrollIntoView({
        behavior: 'smooth',
        block: 'start'
      });
    }
  });
});

// ============================================
// AUTO-REFRESH FOR LIVE DATA (Optional)
// ============================================

// Uncomment to enable auto-refresh every 30 seconds
// setInterval(() => {
//   if (document.getElementById('live').classList.contains('active')) {
//     location.reload();
//   }
// }, 30000);

// ============================================
// EDIT/DELETE FUNCTIONS
// ============================================

async function putJSON(url, data) {
  try {
    const res = await fetch(url, {
      method: "PUT",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(data),
    });
    
    if (!res.ok) {
      throw new Error(`HTTP error! status: ${res.status}`);
    }
    
    return await res.json();
  } catch (error) {
    console.error('Error:', error);
    throw error;
  }
}

async function deleteJSON(url) {
  try {
    const res = await fetch(url, {
      method: "DELETE",
      headers: { "Content-Type": "application/json" },
    });
    
    if (!res.ok) {
      throw new Error(`HTTP error! status: ${res.status}`);
    }
    
    return await res.json();
  } catch (error) {
    console.error('Error:', error);
    throw error;
  }
}

// Edit Bus
function editBus(busId, number, routeId, status) {
  const overlay = document.createElement('div');
  overlay.className = 'modal-overlay active';
  overlay.innerHTML = `
    <div class="modal">
      <div class="modal-header">
        <h3>✏️ Edit Bus</h3>
        <button class="modal-close" onclick="this.closest('.modal-overlay').remove()">&times;</button>
      </div>
      <div class="modal-body">
        <form id="editBusForm">
          <label>Bus Number</label>
          <input type="text" name="number" value="${number}" required>
          <label>Route ID</label>
          <input type="number" name="route_id" value="${routeId || ''}" placeholder="Route ID">
          <label>Status</label>
          <select name="status">
            <option value="Active" ${status === 'Active' ? 'selected' : ''}>Active</option>
            <option value="In Depot" ${status === 'In Depot' ? 'selected' : ''}>In Depot</option>
            <option value="Breakdown" ${status === 'Breakdown' ? 'selected' : ''}>Breakdown</option>
          </select>
        </form>
      </div>
      <div class="modal-footer">
        <button class="btn-small" onclick="this.closest('.modal-overlay').remove()" style="background: var(--text-secondary);">Cancel</button>
        <button class="btn-small" onclick="saveBusEdit(${busId})" style="background: var(--primary-blue);">Save Changes</button>
      </div>
    </div>
  `;
  document.body.appendChild(overlay);
}

async function saveBusEdit(busId) {
  const form = document.getElementById('editBusForm');
  const formData = new FormData(form);
  const payload = Object.fromEntries(formData.entries());
  if (payload.route_id === '') delete payload.route_id;
  
  try {
    await putJSON(`/api/buses/${busId}`, payload);
    showSuccess("Bus updated successfully! Real-time update in progress...");
    document.querySelector('.modal-overlay.active')?.remove();
    // Real-time update will handle the refresh automatically
  } catch (error) {
    showError("Failed to update bus.");
  }
}

// Delete Bus
function deleteBus(busId, number) {
  if (!confirm(`Are you sure you want to delete bus ${number}? This action cannot be undone.`)) return;
  
  deleteJSON(`/api/buses/${busId}`)
    .then(() => {
      showSuccess("Bus deleted successfully! Real-time update in progress...");
      // Real-time update will handle the refresh automatically
    })
    .catch(() => showError("Failed to delete bus."));
}

// Edit Driver
function editDriver(driverId, name, phone) {
  const overlay = document.createElement('div');
  overlay.className = 'modal-overlay active';
  overlay.innerHTML = `
    <div class="modal">
      <div class="modal-header">
        <h3>✏️ Edit Driver</h3>
        <button class="modal-close" onclick="this.closest('.modal-overlay').remove()">&times;</button>
      </div>
      <div class="modal-body">
        <form id="editDriverForm">
          <label>Name</label>
          <input type="text" name="name" value="${name}" required>
          <label>Phone</label>
          <input type="text" name="phone" value="${phone}" required>
        </form>
      </div>
      <div class="modal-footer">
        <button class="btn-small" onclick="this.closest('.modal-overlay').remove()" style="background: var(--text-secondary);">Cancel</button>
        <button class="btn-small" onclick="saveDriverEdit(${driverId})" style="background: var(--primary-blue);">Save Changes</button>
      </div>
    </div>
  `;
  document.body.appendChild(overlay);
}

async function saveDriverEdit(driverId) {
  const form = document.getElementById('editDriverForm');
  const formData = new FormData(form);
  const payload = Object.fromEntries(formData.entries());
  
  try {
    await putJSON(`/api/drivers/${driverId}`, payload);
    showSuccess("Driver updated successfully! Real-time update in progress...");
    document.querySelector('.modal-overlay.active')?.remove();
    // Real-time update will handle the refresh automatically
  } catch (error) {
    showError("Failed to update driver.");
  }
}

// Delete Driver
function deleteDriver(driverId, name) {
  if (!confirm(`Are you sure you want to delete driver ${name}? This action cannot be undone.`)) return;
  
  deleteJSON(`/api/drivers/${driverId}`)
    .then(() => {
      showSuccess("Driver deleted successfully! Real-time update in progress...");
      // Real-time update will handle the refresh automatically
    })
    .catch(() => showError("Failed to delete driver."));
}

// Edit Route
function editRoute(routeId, name, startStop, endStop, firstBus, lastBus, frequencyMin) {
  const overlay = document.createElement('div');
  overlay.className = 'modal-overlay active';
  overlay.innerHTML = `
    <div class="modal">
      <div class="modal-header">
        <h3>✏️ Edit Route</h3>
        <button class="modal-close" onclick="this.closest('.modal-overlay').remove()">&times;</button>
      </div>
      <div class="modal-body">
        <form id="editRouteForm">
          <label>Route Name</label>
          <input type="text" name="name" value="${name}" required>
          <label>Start Stop</label>
          <input type="text" name="start_stop" value="${startStop}" required>
          <label>End Stop</label>
          <input type="text" name="end_stop" value="${endStop}" required>
          <label>First Bus</label>
          <input type="time" name="first_bus" value="${firstBus || '06:00'}">
          <label>Last Bus</label>
          <input type="time" name="last_bus" value="${lastBus || '22:00'}">
          <label>Frequency (minutes)</label>
          <input type="number" name="frequency_min" value="${frequencyMin || ''}" placeholder="15">
        </form>
      </div>
      <div class="modal-footer">
        <button class="btn-small" onclick="this.closest('.modal-overlay').remove()" style="background: var(--text-secondary);">Cancel</button>
        <button class="btn-small" onclick="saveRouteEdit(${routeId})" style="background: var(--primary-blue);">Save Changes</button>
      </div>
    </div>
  `;
  document.body.appendChild(overlay);
}

async function saveRouteEdit(routeId) {
  const form = document.getElementById('editRouteForm');
  const formData = new FormData(form);
  const payload = Object.fromEntries(formData.entries());
  
  try {
    await putJSON(`/api/routes/${routeId}`, payload);
    showSuccess("Route updated successfully! Real-time update in progress...");
    document.querySelector('.modal-overlay.active')?.remove();
    // Real-time update will handle the refresh automatically
  } catch (error) {
    showError("Failed to update route.");
  }
}

// Delete Route
function deleteRoute(routeId, name) {
  if (!confirm(`Are you sure you want to delete route "${name}"? This action cannot be undone.`)) return;
  
  deleteJSON(`/api/routes/${routeId}`)
    .then(() => {
      showSuccess("Route deleted successfully! Real-time update in progress...");
      // Real-time update will handle the refresh automatically
    })
    .catch(() => showError("Failed to delete route."));
}

// Edit Maintenance
function editMaintenance(maintenanceId, busId, issue, status) {
  const overlay = document.createElement('div');
  overlay.className = 'modal-overlay active';
  overlay.innerHTML = `
    <div class="modal">
      <div class="modal-header">
        <h3>✏️ Edit Maintenance Record</h3>
        <button class="modal-close" onclick="this.closest('.modal-overlay').remove()">&times;</button>
      </div>
      <div class="modal-body">
        <form id="editMaintenanceForm">
          <label>Bus ID</label>
          <input type="number" name="bus_id" value="${busId}" required>
          <label>Issue</label>
          <input type="text" name="issue" value="${issue}" required>
          <label>Status</label>
          <select name="status">
            <option value="Pending" ${status === 'Pending' ? 'selected' : ''}>Pending</option>
            <option value="In Progress" ${status === 'In Progress' ? 'selected' : ''}>In Progress</option>
            <option value="Resolved" ${status === 'Resolved' ? 'selected' : ''}>Resolved</option>
          </select>
        </form>
      </div>
      <div class="modal-footer">
        <button class="btn-small" onclick="this.closest('.modal-overlay').remove()" style="background: var(--text-secondary);">Cancel</button>
        <button class="btn-small" onclick="saveMaintenanceEdit(${maintenanceId})" style="background: var(--primary-blue);">Save Changes</button>
      </div>
    </div>
  `;
  document.body.appendChild(overlay);
}

async function saveMaintenanceEdit(maintenanceId) {
  const form = document.getElementById('editMaintenanceForm');
  const formData = new FormData(form);
  const payload = Object.fromEntries(formData.entries());
  
  try {
    await putJSON(`/api/maintenance/${maintenanceId}`, payload);
    showSuccess("Maintenance record updated successfully! Real-time update in progress...");
    document.querySelector('.modal-overlay.active')?.remove();
    // Real-time update will handle the refresh automatically
  } catch (error) {
    showError("Failed to update maintenance record.");
  }
}

// Delete Maintenance
function deleteMaintenance(maintenanceId) {
  if (!confirm('Are you sure you want to delete this maintenance record? This action cannot be undone.')) return;
  
  deleteJSON(`/api/maintenance/${maintenanceId}`)
    .then(() => {
      showSuccess("Maintenance record deleted successfully! Real-time update in progress...");
      // Real-time update will handle the refresh automatically
    })
    .catch(() => showError("Failed to delete maintenance record."));
}

// ============================================
// CHARTS INITIALIZATION
// ============================================

function initializeCharts() {
  // Get data from summary (passed from backend via window.dashboardSummary)
  const summary = window.dashboardSummary || {
    total_buses: 0,
    active_buses: 0,
    inactive_buses: 0,
    breakdown_buses: 0,
    total_drivers: 0,
    present_drivers: 0,
    absent_drivers: 0,
    total_routes: 0,
    total_maintenance: 0,
    pending_maintenance: 0,
    resolved_maintenance: 0
  };

  // Bus Status Chart
  const busStatusCtx = document.getElementById('busStatusChart');
  if (busStatusCtx) {
    new Chart(busStatusCtx, {
      type: 'doughnut',
      data: {
        labels: ['Active', 'In Depot', 'Breakdown'],
        datasets: [{
          data: [summary.active_buses, summary.inactive_buses, summary.breakdown_buses],
          backgroundColor: ['#059669', '#d97706', '#dc2626'],
          borderWidth: 3,
          borderColor: '#ffffff'
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            position: 'bottom',
            labels: {
              padding: 15,
              font: { size: 12, weight: '600' }
            }
          }
        }
      }
    });
  }

  // Driver Attendance Chart
  const driverAttendanceCtx = document.getElementById('driverAttendanceChart');
  if (driverAttendanceCtx) {
    new Chart(driverAttendanceCtx, {
      type: 'bar',
      data: {
        labels: ['Present', 'Absent'],
        datasets: [{
          label: 'Drivers',
          data: [summary.present_drivers, summary.absent_drivers],
          backgroundColor: ['#059669', '#dc2626'],
          borderRadius: 8
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: { display: false }
        },
        scales: {
          y: {
            beginAtZero: true,
            ticks: { stepSize: 1 }
          }
        }
      }
    });
  }

  // Maintenance Chart
  const maintenanceCtx = document.getElementById('maintenanceChart');
  if (maintenanceCtx) {
    new Chart(maintenanceCtx, {
      type: 'pie',
      data: {
        labels: ['Pending', 'Resolved'],
        datasets: [{
          data: [summary.pending_maintenance, summary.resolved_maintenance],
          backgroundColor: ['#d97706', '#059669'],
          borderWidth: 3,
          borderColor: '#ffffff'
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            position: 'bottom',
            labels: {
              padding: 15,
              font: { size: 12, weight: '600' }
            }
          }
        }
      }
    });
  }

  // Operations Overview Chart
  const operationsCtx = document.getElementById('operationsChart');
  if (operationsCtx) {
    new Chart(operationsCtx, {
      type: 'line',
      data: {
        labels: ['Buses', 'Drivers', 'Routes', 'Maintenance'],
        datasets: [{
          label: 'Total Count',
          data: [
            summary.total_buses,
            summary.total_drivers,
            summary.total_routes,
            summary.total_maintenance
          ],
          borderColor: '#1e40af',
          backgroundColor: 'rgba(30, 64, 175, 0.1)',
          borderWidth: 3,
          fill: true,
          tension: 0.4,
          pointRadius: 6,
          pointBackgroundColor: '#1e40af'
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: { display: false }
        },
        scales: {
          y: {
            beginAtZero: true,
            ticks: { stepSize: 1 }
          }
        }
      }
    });
  }
}

// ============================================
// INITIALIZATION
// ============================================

// Add fade-in animation to page load
document.addEventListener('DOMContentLoaded', () => {
  document.body.style.opacity = '0';
  setTimeout(() => {
    document.body.style.transition = 'opacity 0.5s ease-in';
    document.body.style.opacity = '1';
  }, 100);
  
  // Add animation to cards
  const cards = document.querySelectorAll('.card');
  cards.forEach((card, index) => {
    card.style.animationDelay = `${index * 0.1}s`;
  });
  
  // Initialize charts when overview tab is active
  if (document.getElementById('overview')?.classList.contains('active')) {
    setTimeout(initializeCharts, 500);
  }
  
  // Re-initialize charts when switching to overview tab
  const overviewTab = document.querySelector('[data-tab="overview"]');
  if (overviewTab) {
    overviewTab.addEventListener('click', () => {
      setTimeout(initializeCharts, 300);
    });
  }
  
  // Setup real-time listeners after a short delay to ensure Firebase is loaded
  // Check every 500ms if Firebase is ready
  const checkFirebase = setInterval(() => {
    if (window.firebaseReady && window.firebaseDb) {
      clearInterval(checkFirebase);
      setupRealTimeListeners();
    }
  }, 500);
  
  // Stop checking after 10 seconds
  setTimeout(() => {
    clearInterval(checkFirebase);
    if (!realTimeListenersActive) {
      console.warn('⚠️  Firebase real-time listeners not activated. Check Firebase configuration.');
    }
  }, 10000);
});
