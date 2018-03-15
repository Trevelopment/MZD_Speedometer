/*
 Copyright 2016 Herko ter Horst
 __________________________________________________________________________

 Filename: SpeedoMeterTmplt.js
 __________________________________________________________________________
 */

log.addSrcFile("SpeedoMeterTmplt.js", "speedometer");


/*
 * =========================
 * Constructor
 * =========================
 */
function SpeedoMeterTmplt(uiaId, parentDiv, templateID, controlProperties) {
  this.longholdTimeout = null;
  this.divElt = null;
  this.templateName = "SpeedoMeterTmplt";

  this.onScreenClass = "SpeedoMeterTmplt";

  log.debug("  templateID in SpeedoMeterTmplt constructor: " + templateID);

  //@formatter:off
  //set the template properties
  this.properties = {
    "statusBarVisible": true,
    "leftButtonVisible": false,
    "rightChromeVisible": false,
    "hasActivePanel": false,
    "isDialog": false
  };
  //@formatter:on

  // create the div for template
  this.divElt = document.createElement('div');
  this.divElt.id = templateID;
  this.divElt.className = "TemplateWithStatus SpeedoMeterTmplt";

  parentDiv.appendChild(this.divElt);

  // do whatever you want here
  this.divElt.innerHTML = '<!-- MZD Speedometer v5 - Variant Mod  -->' +
    '<div id="speedometerContainer">' +
    '<div id="hideIdleBtn"></div>' +
    ' <div class="spdBtn' + spdBtn.classic.select + ' spdBtnSelect"></div>' +
    ' <div class="spdBtn' + spdBtn.classic.up + ' spdBtnUp"></div>' +
    ' <div class="spdBtn' + spdBtn.classic.down + ' spdBtnDown"></div>' +
    ' <div class="spdBtn' + spdBtn.classic.right + ' spdBtnRight"></div>' +
    ' <div class="spdBtn' + spdBtn.classic.left + ' spdBtnLeft"></div>' +
    ' <div class="spdBtn' + spdBtn.classic.hold.select + ' spdBtnSelecth"></div>' +
    ' <div class="spdBtn' + spdBtn.classic.hold.up + ' spdBtnUph"></div>' +
    ' <div class="spdBtn' + spdBtn.classic.hold.down + ' spdBtnDownh"></div>' +
    ' <div class="spdBtn' + spdBtn.classic.hold.right + ' spdBtnRighth"></div>' +
    ' <div class="spdBtn' + spdBtn.classic.hold.left + ' spdBtnLefth"></div>' +
    '<div id="table_bg">' +
    '<div id="valuetable">' +
    '<fieldset id="tripDistFieldSet">' +
    '<legend>Trip Dist. <span class="spunit">(<span class="distUnit">km</span>)<span></legend>' +
    '<div class="tripDistance">0.00</div>' +
    '</fieldset>' +
    '<fieldset id="speedTopFieldSet">' +
    '<legend>Top Speed</legend>' +
    '<div class="speedTopValue">0</div>' +
    '</fieldset>' +
    '<fieldset id="speedAvgFieldSet">' +
    '<legend>Avg. Speed</legend>' +
    '<div class="speedAvgValue">0</div>' +
    '</fieldset>' +
    '<fieldset id="gpsAltitudeFieldSet">' +
    '<legend>Altitude <span class="spunit">(<span class="altUnit">m</span>)<span></legend></legend>' +
    '<div class="gpsAltitudeValue">-</div>' +
    '</fieldset>' +
    // '<fieldset id="gpsAltitudeMinFieldSet">'+
    //     '<legend>Altitude <span>min</span></legend>'+
    //     '<div class="gpsAltitudeMin">-</div>'+
    // '</fieldset>'+
    // '<fieldset id="gpsAltitudeMaxFieldSet">'+
    //     '<legend>Altitude <span>max</span></legend>'+
    //     '<div class="gpsAltitudeMax">-</div>'+
    // '</fieldset>'+
    '<fieldset id="gpsAltitudeMinMaxFieldSet">' +
    '<legend><span>min/max</span></legend>' +
    '<div class="gpsAltitudeMinMax">---/---</div>' +
    '</fieldset>' +
    '<fieldset id="gpsLatitudeFieldSet">' +
    '<legend>Lat.</legend>' +
    '<div class="gpsLatitudeValue">---</div>' +
    '</fieldset>' +
    '<fieldset id="gpsLongitudeFieldSet">' +
    '<legend>Lon.</legend>' +
    '<div class="gpsLongitudeValue">---</div>' +
    '</fieldset>' +
    '<fieldset id="tripTimeFieldSet">' +
    '<legend>Total Time</legend>' +
    '<div class="tripTimeValue">0:00</div>' +
    '</fieldset>' +
    '<fieldset id="idleTimeFieldSet">' +
    '<legend>Idle Time</legend>' +
    '<div class="idleTimeValue">0:00</div>' +
    '</fieldset>' +
    '<fieldset id="engIdleTimeFieldSet">' +
    '<legend>Engine Idle</legend>' +
    '<div class="engineIdleTimeValue">0:00</div>' +
    '</fieldset>' +
    '<fieldset id="Drv1AvlFuelEFieldSet">' +
    '<legend><span class="fuelEffUnit"></span></legend>' +
    '<div class="Drv1AvlFuelEValue"><span>(0)</span>0</div>' +
    '</fieldset>' +
    '<fieldset id="outsideTempFieldSet">' +
    '<legend>Outside <span class="spunit">(&deg;<span class="tempUnit"></span>)</span></legend>' +
    '<div class="outsideTempValue">0</div>' +
    '</fieldset>' +
    '<fieldset id="intakeTempFieldSet">' +
    '<legend>Intake <span class="spunit">(&deg;<span class="tempUnit"></span>)</span></legend>' +
    '<div class="intakeTempValue">0</div>' +
    '</fieldset>' +
    '<fieldset id="coolantTempFieldSet">' +
    '<legend>Coolant <span class="spunit">(&deg;<span class="tempUnit"></span>)</span></legend>' +
    '<div class="coolantTempValue">0</div>' +
    '</fieldset>' +
    '<fieldset id="gearPositionFieldSet">' +
    '<legend>Gear Position</legend>' +
    '<div class="gearPositionValue">0</div>' +
    '</fieldset>' +
    '</div>' +
    '</div>' +
    '<div id="analog">' +
    '<div id="speedometerBG"></div>' +
    '<div id="speedometerDial"></div>' +
    '<div id="textSpeed0">0</div>' +
    '<div id="textSpeed20">20</div>' +
    '<div id="textSpeed40">40</div>' +
    '<div id="textSpeed60">60</div>' +
    '<div id="textSpeed80">80</div>' +
    '<div id="textSpeed100">100</div>' +
    '<div id="textSpeed120">120</div>' +
    '<div id="textSpeed140">140</div>' +
    '<div id="textSpeed160">160</div>' +
    '<div id="textSpeed180">180</div>' +
    '<div id="textSpeed200">200</div>' +
    '<div id="textSpeed220">220</div>' +
    '<div id="textSpeed240">240</div>' +
    '<div class="topSpeedIndicator"></div>' +
    '<div class="speedIndicator"></div>' +
    '<div class="gpsCompassBG">' +
    '<div id="gpsCompass">' +
    '<div class="North">N</div>' +
    '<div class="NorthEast small">NE</div>' +
    '<div class="East">E</div>' +
    '<div class="SouthEast small">SE</div>' +
    '<div class="South">S</div>' +
    '<div class="SouthWest small">SW</div>' +
    '<div class="West">W</div>' +
    '<div class="NorthWest small">NW</div>' +
    '</div>' +
    '</div>' +
    '<div class="vehicleSpeed">0</div>' +
    '<div class="speedUnit">---</div>' +
    '<div class="topRPMIndicator"></div>' +
    '<div class="RPMIndicator"></div>' +
    '<div id="rpmDial">' +
    '<div class="step s0">0</div>' +
    '<div class="step s1">1</div>' +
    '<div class="step s2">2</div>' +
    '<div class="step s3">3</div>' +
    '<div class="step s4">4</div>' +
    '<div class="step s5">5</div>' +
    '<div class="step s6">6</div>' +
    '<div class="step s7">7</div>' +
    '<div class="unit">r/min</div>' +
    '<div class="scale">x1000</div>' +
    '</div>' +
    '</div>' +
    '</div>' +
    '<div id="digital">' +
    '<fieldset id="speedCurrentFieldSet" class="pos0">' +
    '<legend class="vehDataLegends">Veh Speed <span class="spunit">(<span class="speedUnit">---</span>)<span></legend>' +
    '<div class="vehicleSpeed">0</div>' +
    '</fieldset>' +
    //'<div class="vehicleSpeed pos0">0</div>' +
    //'<div class="speedUnit">---</div>' +
    '</div>';
  //$.getScript('apps/_speedometer/js/speedometerUpdate.js',
  setTimeout(function() {
    updateSpeedoApp();
  }, 700); //);
}

/*
 *  @param clickTarget (jQuery Object) The jQuery Object to click on a single click action
 *  clickTarget can also be a function or a string of the DOM node to make the jQuery Object
 */
SpeedoMeterTmplt.prototype.singleClick = function(clickTarget) {
  if (typeof clickTarget === "string") { clickTarget = $(clickTarget) }
  (speedometerLonghold) ? speedometerLonghold = false: (typeof clickTarget === "function") ? clickTarget() : clickTarget.click();
  clearTimeout(this.longholdTimeout);
  this.longholdTimeout = null;
}
/*
 *  @param clickFunction (function) Function to run on a long click
 *  clickFunction can also be a a string of the DOM node or jQuery Object to click
 */
SpeedoMeterTmplt.prototype.longClick = function(clickFunction) {
  if (typeof clickFunction === "string") { clickFunction = $(clickFunction) }
  this.longholdTimeout = setTimeout(function() {
    speedometerLonghold = true;
    (typeof clickFunction === "function") ? clickFunction(): clickFunction.click();
  }, 1200);
}
/*
 * =========================
 * Standard Template API functions
 * =========================
 */

/* (internal - called by the framework)
 * Handles multicontroller events.
 * @param   eventID (string) any of the “Internal event name” values in IHU_GUI_MulticontrollerSimulation.docx (e.g. 'cw',
 * 'ccw', 'select')
 * Controller functions are defined in speedometerUpdate.js
 */
SpeedoMeterTmplt.prototype.handleControllerEvent = function(eventID) {
  log.debug("handleController() called, eventID: " + eventID);

  var retValue = 'giveFocusLeft';

  switch (eventID) {
    case "upStart":
      this.longClick('.spdBtnUph');
      retValue = "consumed";
      break;
    case "up":
      this.singleClick('.spdBtnUp');
      retValue = "consumed";
      break;
    case "downStart":
      this.longClick('.spdBtnDownh');
      retValue = "consumed";
      break;
    case "down":
      this.singleClick('.spdBtnDown');
      retValue = "consumed";
      break;
    case "selectStart":
      this.longClick('.spdBtnSelecth');
      retValue = "consumed";
      break;
    case "select":
      this.singleClick('.spdBtnSelect');
      retValue = "consumed";
      break;
    case "rightStart":
      this.longClick('.spdBtnRighth');
      retValue = "consumed";
      break;
    case "right":
      this.singleClick('.spdBtnRight');
      retValue = "consumed";
      break;
    case "leftStart":
      this.longClick('.spdBtnLefth');
      retValue = "consumed";
      break;
    case "left":
      this.singleClick('.spdBtnLeft');
      retValue = "consumed";
      break;
      //  case "cw":
      //  case "ccw":
    default:
      retValue = "ignored";
  }

  return retValue;
};
/*
 * Called by the app during templateNoLongerDisplayed. Used to perform garbage collection procedures on the template and
 * its controls.
 */
SpeedoMeterTmplt.prototype.cleanUp = function() {

};

framework.registerTmpltLoaded("SpeedoMeterTmplt");
