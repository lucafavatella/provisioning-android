from com.android.monkeyrunner import MonkeyRunner, MonkeyDevice
device = MonkeyRunner.waitForConnection()
package = 'com.android.settings'
activity = '.Settings$AppAndNotificationDashboardActivity'
runComponent = package + '/' + activity
device.startActivity(component=runComponent)
result = device.takeSnapshot()
result.writeToFile('shot1.png','png')

