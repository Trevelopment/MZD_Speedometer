# MZD_Speedometer v5

[Changelog](https://github.com/Trevelopment/MZD_Speedometer/changelog.md "changelog")

### A Versatile Speedometer App For The MZD Infotainment System

> **2 Speedometers in 1 With Multiple Variants:**
>
> -   Classic MZD Speedometer
>     -   Basic Analog Speedometer With Rotating Compass
>     -   Modded Digital & Analog Speedometer With Toggle Controls
>     -   Change Colors, Text Size, Table Values
> -   Digital Bar Speedometers
>     -   Value Positions [Fully Customizable](config/speedometer-config.js)
>     -   [Customizable Themes](config/barThemes.css)
> -   [Remap Multicontroller Functions](config/speedometer-controls.js) For Both Speedometers

## How To Install:

-   Download a release zip from [releases](https://github.com/Trevelopment/MZD_Speedometer/releases) page or <http://speedo.mazdatweaks.win>
-   Unzip onto blank FAT32 formatted USB drive
-   Connect to car USB port and wait for installation to begin (2 - 20 minutes)
-   Choose options when prompted by installer
-   For more info visit [MazdaTweaks.com](https://mazdatweaks.com)

![MZD Speedometers](MZD_Speedo.gif)

## How To Customize

 To customize edit the configuration file [speedometer-config.js](/config/speedometer-config.js)

##### Example Configuration:

```js
/** speedometer-config.js ************************************************************** *\
|* =========================                                                             *|
|* Speedometer Configuration - Used to configure position of Speedometer values.         *|
|* =========================                                                             *|
|* Main Speedometer Value: [0, 0, 0] - Large, Front, & Center.                           *|
|* Other Values: [ 0/1:(0 For Main Column OR 1 For Bottom Rows), Row Number, Position ]  *|
|* Main Column Positions: 4 Values (1-4 From Top to Bottom)                              *|
|* Bottom Rows Positions: 5 Values Per Row (1-5 From Left to Right)                      *|
|* Examples:                                                                             *|
|* [0, 1, 4] = [Main, Column, 4th position (Bottom of the Column)]                       *|
|* [1, 3, 1] = [Bottom, 3rd Row, First Position (Left Side)]                             *|
|* [1, 1, 5] = [Bottom, 1st Row, Last Position (Right Side)]                             *|
|* To Hide a Value = [1, 1, 0] (Any bottom row position 0 will hide the value)           *|
|* To Change Bottom Row Push Command Knob ("Select")                                     *|
|* Note: Only numbers inside [] brackets determine position, order in this list DOES NOT *|
\* ************************************************************************************* */
var spdBottomRows = 3;   //Number of Bottom Rows
var spdTbl = { // Example Layout:
  vehSpeed:   [0, 0, 0], //Vehicle Speed (Main Position)
  topSpeed:   [0, 1, 1], //Top Speed (Right Column, Top Value)
  avgSpeed:   [0, 1, 2], //Average Speed
  gpsSpeed:   [0, 1, 3], //GPS Speed
  engSpeed:   [0, 1, 4], //Engine Speed (Right Column, Bottom Value)
  trpTime:    [1, 1, 1], //Trip Time (1st Bottom Row, Far Left)
  trpDist:    [1, 1, 2], //Trip Distance
  outTemp:    [1, 1, 3], //Outside Temperature
  inTemp:     [1, 1, 4], //Intake Temperature
  coolTemp:   [1, 1, 5], //Coolant Temperature
  gearPos:    [1, 2, 1], //Gear Position
  gearLvr:    [1, 1, 0], //Transmission Lever Position (hidden)
  fuelLvl:    [1, 2, 2], //Fuel Gauge Level
  trpFuel:    [1, 2, 3], //Trip Fuel Economy (2nd Bottom Row, Center)
  totFuel:    [1, 2, 4], //Total Fuel Economy
  avgFuel:    [1, 2, 5], //Average Fuel Economy
  gpsAlt:     [1, 3, 2], //Altitude
  gpsAltMM:   [1, 3, 3], //Altitude Min/Max
  gpsHead:    [1, 3, 1], //GPS Heading
  gpsLat:     [1, 3, 4], //GPS Latitude
  gpsLon:     [1, 3, 5], //GPS Longitude  (3rd Bottom Row, Far Right)
  trpIdle:    [1, 1, 0], //Idle Time (hidden)
  trpEngIdle: [1, 1, 0], //Engine Idle Time (hidden)
  engTop:     [1, 1, 0], //Engine Top Speed (hidden)
  engLoad:    [1, 1, 0], //Engine Load (hidden)
  batSOC:     [1, 1, 0], //Battery Charge State (i-stop) (hidden)
};
```

```JS
// OverRide Values
/* ************************************************** */
/* Set overRideSpeed to true to use your values below */
/* If this is false the following values are not used */
var overRideSpeed=false;
/* ************************************************** */
/* * Start OverRide Variables *********************** */
var SORV = {
  // Set the language for the speedometer
  // Available EN, ES, DE, PL, SK, TR, FR, IT
  language: "EN",

  // Used for metric/US english conversion flag (C/F, KPH/MPH, Meter/Feet, L per 100km/MPG)
  // Set isMPH: true for MPH, Feet, MPG
  // Set isMPH: false for KPH, Meter
  isMPH: false,

  // Set This to true to start with the Bar Speedometer Mod
  // False to use the analog speedometer
  barSpeedometerMod: true,

  // Set true to enable multicontroller and other mod features in classic mode
  // If false then use classic speedometer without Mods
  speedMod: true,

  // Set to true to start the classic speedometer in analog mode
  // False to start in digital mode
  startAnalog: true,

  // Set it true for the StatusBar Speedometer
  // False if you don't want the small speedometer in statusbar
  StatusBarSpeedometer: true,

  // Set to true for Outside Temperature & Fuel Efficiency in the statusbar
  // False for Compass & Altitude
  sbTemp: false,

  // Set true if you want the original speedometer background image as in version 4.2 or below
  // False for no background
  // If "true" the opacity above will be ignored
  original_background_image: false,

  // Set the opacity of black background color for speedometer, to reduce the visibility of custom MZD background images
  // Possible values 0.0 (full transparent) until 1.0 (complete black background)
  black_background_opacity: 0.0,

  // Set unit for fuel efficiency to km/L
  // False for L/100km
  fuelEffunit_kml: false,

  // Set this to true for Fahrenheit
  // False for Celsius
  tempIsF: false,

  // For the Speed Bar false for Current Vehicle Speed
  // Set This to true if you want the Colored Bar to measure engine speed
  engineSpeedBar: false,

  // Set This to true to hide the Speed Bar
  // False shows he bar
  hideSpeedBar: false,

  // Set this to true to enable counter animation on the speed number
  // False to disable speed counter animation
  // The animation causes the digital number to lag by 1 second
  speedAnimation: false,
};
```

### Controls - [speedometer-controls.js](/config/speedometer-controls.js)

> (Long Hold Is 1.5 Seconds)

```js
/** speedometer-controls.js ************************************************************** *\
|* =========================
|* Speedometer Controls - Used to map multicontroller "clicks" to toggle actions/events
|* =========================
|* Numbers may be used multiple times.  Ex: set all directions under bar to 4
|* and all multicontroller directions will toggle the background
|* KEY:
|* Both Speedometers: (Same by default but can be set independently)
|* 1: (Default: up) - Toggle Speed Unit (mph-km/h)
|* 3: (Default: right) - Toggle Temp C-F (mph mode) Fuel Eff L/km-km/100L (km/h mode)
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
```

### Custom Themes For Bar Speedometer - [barThemes.css](/config/barThemes.css)

```css
/* barThemes.css - Customize Bar Speedometer Color Themes
* Any Valid CSS Colors Can Be Used Examples:
* Names -    Ex: blue;
* Hex -      Ex: #00ff66;
* RGB -      Ex: rgb(100, 255, 0);
* HSL -      Ex: hsl(248, 53%, 58%);
* For More Info On CSS Colors Visit https://www.w3schools.com/colors/colors_names.asp
* Each Theme Has 3 Colors In This Order:
* Primary - Color of Values
* Secondary - Color of Labels/Units
* Border-Color - Color of the Box Borders
* If you know CSS then have fun with it
* CSS is a very forgiving language any errors in this file will be ignored
*/

/* Theme #1 */

#speedBarContainer.theme1 #vehdataMainDiv fieldset div, #speedBarContainer.theme1 #vehdataMainDiv [class*="vehDataMain"].pos0 div {
  /* Primary */
  color: aquamarine;
}

#speedBarContainer.theme1 #vehdataMainDiv [class*="vehDataMain"].pos0 legend .spunit span, #speedBarContainer.theme1 #vehdataMainDiv fieldset {
  /* Secondary */
  color: #64bfff;
  /* Border-Color */
  border-color: blue;
}

/* Theme #2 */

#speedBarContainer.theme2 #vehdataMainDiv fieldset div, #speedBarContainer.theme2 #vehdataMainDiv [class*="vehDataMain"].pos0 div {
  color: #3fff17;
}

#speedBarContainer.theme2 #vehdataMainDiv [class*="vehDataMain"].pos0 legend .spunit span, #speedBarContainer.theme2 #vehdataMainDiv fieldset {
  color: hsl(248, 53%, 58%);
  border-color: rgb(100, 0, 12);
}

/* Theme #3 */
...
...
...
```
