/** speedometer-controls.js ************************************************************** *\
|* =========================
|* Speedometer Controls - Used to map multicontroller "clicks" to toggle actions/events
|* =========================
|* Numbers may be used multiple times.  Ex: set all directions under bar to 4
|* and all multicontroller directions will toggle the background
|* KEY:
|* Both Speedometers: (Same by default but can be set independently)
|* 1: (Default: up) - Toggle Speed Unit (mph-km/h)
|* 3: (Default: right) - Toggle Temp in mph mode (C-F) Fuel Eff in km/h mode (L/km-km/100L)
|* 4: (Default: left) - Toggle Background
|* 8: (Default: hold.right) - Reset Trip Time, Distance, Top/Ave Speed
|* 9: (Default: hold.left) - Change Color Theme
|* Bar (Colored Speed Bar w/ Bottom Rows):
|* 0: (Default: select) - Show Next Bottom Row
|* 2: (Default: down) - Toggle Speed Bar (VehSpeed-RPM)
|* 5: (Default: hold.select) - Reset Layout
|* 6: (Default: hold.up) - Switch To Classic Speedometer
|* 7: (Default: hold.down) - Hide/Show Speed Bar
|* Classic (Analog w/ Compass):
|* 0: (Default: select) - Toggle Speed (Analog-Digital)
|* 2: (Default: down) - Toggle Larger Text
|* 5: (Default: hold.select) - Toggle Alternate Values (Time-Temp)
|* 6: (Default: hold.up) - Switch To Bar Speedometer
|* 7: (Default: hold.down) - Basic Speedo - Analog & Disables Toggles Except Itself To Toggle Back
|* ************************************************************************************* *|
|* null: To Disable Multicontroller Key (do not leave any blank!!!)
\* ************************************************************************************* */
var spdBtn = {
  bar: { // Controls for the Bar Speedometer context
    select: 0,
    up: 1,
    down: 2,
    right: 3,
    left: 4,
    hold: { // Used when the click is held for 2 seconds
      select: 5,
      up: 6,
      down: 7,
      right: 8,
      left: 9,
    }
  },
  classic: { // Controls for the Classic (Analog) Speedometer context
    select: 0,
    up: 1,
    down: 2,
    right: 3,
    left: 4,
    hold: { // Used when the click is held for 2 seconds
      select: 5,
      up: 6,
      down: 7,
      right: 8,
      left: 9,
    }
  }
};
