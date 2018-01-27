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
var spdBottomRows = 4;   //Number of Bottom Rows
var spdTbl = {
  vehSpeed:   [0, 0, 0], //Vehicle Speed
  topSpeed:   [0, 1, 1], //Top Speed
  avgSpeed:   [0, 1, 2], //Average Speed
  gpsSpeed:   [0, 1, 3], //GPS Speed
  engSpeed:   [0, 1, 4], //Engine Speed
  trpTime:    [1, 1, 1], //Trip Time
  trpIdle:    [1, 1, 2], //Idle Time
  trpDist:    [1, 1, 3], //Trip Distance
  fuelLvl:    [1, 1, 4], //Fuel Gauge Level
  outTemp:    [1, 1, 5], //Outside Temperature
  gpsHead:    [1, 2, 1], //GPS Heading
  gpsAlt:     [1, 2, 2], //Altitude
  gpsAltMM:   [1, 2, 3], //Altitude Min/Max
  trpFuel:    [1, 2, 4], //Trip Fuel Economy
  inTemp:     [1, 2, 5], //Intake Temperature
  gearPos:    [1, 3, 1], //Gear Position
  gearLvr:    [1, 3, 2], //Transmission Lever Position
  engTop:     [1, 3, 3], //Engine Top Speed
  avgFuel:    [1, 3, 4], //Average Fuel Economy
  coolTemp:   [1, 3, 5], //Coolant Temperature
  engLoad:    [1, 4, 1], //Engine Load
  gpsLat:     [1, 4, 2], //GPS Latitude
  gpsLon:     [1, 4, 3], //GPS Longitude
  totFuel:    [1, 4, 4], //Total Fuel Economy
  trpEngIdle: [1, 4, 5], //Engine Idle Time
  batSOC:     [1, 1, 0], //Battery Charge State (i-stop)
};
