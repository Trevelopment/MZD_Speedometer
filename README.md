LongLong# MZD_Speedometer v5
###  A Versatile Speedometer App For The MZD Infotainment System
> **2 Speedometers in 1 With Multiple Variants:**
> - Classic MZD Speedometer (By Diginix)
>   - Basic Analog Speedometer With Rotating Compass
>   - Modded Digital & Analog Speedometer With Toggle Controls
> - Digital Bar Speedometers
>   - Value Positions Fully Customizable

## How To Install:
- Download a release zip from [releases](https://github.com/Trevelopment/MZD_Speedometer/releases) page
- Unzip onto blank FAT32 formatted USB drive
- Connect to car USB port and wait for installation to begin (2 - 20 minutes)
- Choose options when prompted by installer
- For more info visit [MazdaTweaks.com](https://mazdatweaks.com)

![MZD Speedometers](MZD_Speedo.gif)
## How To Customize
 > To customize edit the configuration file `/config/speedometer-config.js`
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
|* ******* DELETE THIS CONFIG FILE TO REUSE YOUR CURRENT CONFIG-SPEEDOMETER.JS ********* *|
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
### Controls
> (Long Hold Is 1.5 Seconds)

- (Long) Up: Change from Classic To Bar Spedometers (Both)
- (Short) Left: Toggle Speedometer Background (Both)
- Digital Bar
  - (Short) Select: Toggle Next Bottom Row
  - (Short) Up: Toggle mph - km/h
  - (Short) Down: Toggle Speed Bar: Vehicle Speed - RPM
  - (Short) Right: In mph Toggle Temp (C - F) and km/h Toggle Fuel Efficiency (L/100km - km/L)
  - (Long) Down: Hide / Show Speed Bar
  - (Long) Left: TBD (Same as Short Click)
  - (Long) Right: TBD (Same as Short Click)
  - (Long) Select: TBD (Same as Short Click)
- Classic (Modded)
  - (Short) Select: Change between Analog w/ Compass & Digital
  - (Short) Up: Toggle Alternate Values (Temperatures and Gear Position)
  - (Short) Down: Increase Value Table Font Size
  - (Short) Right: Toggle mph - km/h
  - (Long) Down: Toggle Modded - Basic Speedometers (Basic mode has no toggles)
  - (Long) Left: TBD (Same as Short Click)
  - (Long) Right: TBD (Same as Short Click)
  - (Long) Select: TBD (Same as Short Click)
