using Toybox.Application;
using Toybox.Application.Properties;
using Toybox.Background;
using Toybox.Math;
using Toybox.System;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.UserProfile;
using Toybox.WatchUi as Ui;

(:background)
class ProtomoleculeFaceApp extends Application.AppBase {

  function initialize() {
    AppBase.initialize();
  }

  function determineSleepTime() {
    var profile = UserProfile.getProfile();
    var current = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
    current = new Time.Duration(current.hour * 3600 + current.min * 60);

    if (profile.wakeTime.lessThan(profile.sleepTime)) {
      Settings.isSleepTime = (Settings.get("sleepLayoutActive") && (current.greaterThan(profile.sleepTime) || current.lessThan(profile.wakeTime)));
    } else if (profile.wakeTime.greaterThan(profile.sleepTime)) {
      Settings.isSleepTime = Settings.get("sleepLayoutActive") && current.greaterThan(profile.sleepTime) && current.lessThan(profile.wakeTime);
    } else {
      Settings.isSleepTime = false;
    }
  }

  function initBackground() {
    if (System has :ServiceDelegate) {     
      Background.registerForSleepEvent();
      Background.registerForWakeEvent();
    }
  }

  // onStart() is called on application start up
  function onStart(state) {
  }

  // onStop() is called when your application is exiting
  function onStop(state) {
  }

  // Return the initial view of your application here
  function getInitialView() {
    Settings.initSettings();
    initBackground();
    return [ new ProtomoleculeFaceView() ];
  }

  function getServiceDelegate() {
    return [ new SleepModeServiceDelegate() ];
  }

  function getSettingsView() {
    return [ new ProtomoleculeSettingsMenu(), new ProtomoleculeSettingsDelegate() ];
  }

  // New app settings have been received so trigger a UI update
  function onSettingsChanged() {
    Settings.loadProperties();
    Settings.determineSleepTime();
    WatchUi.requestUpdate();
  }

  function onBackgroundData(data) {
    Settings.isSleepTime = Settings.get("sleepLayoutActive") && data;
    WatchUi.requestUpdate();
  }

}