https://gist.github.com/Pulimet/5013acf2cd5b28e55036c82c91bd56d8
quoting https://www.automatetheplanet.com/adb-cheat-sheet/ as one of the sources.

```
== Home button
adb shell am start -W -c android.intent.category.HOME -a android.intent.action.MAIN

== Activity Manager
adb shell am start -a android.intent.action.VIEW
adb shell am broadcast -a 'my_action'
```

```
# Add a value to default shared preferences.
adb shell 'am broadcast -a org.example.app.sp.PUT --es key key_name --es value "hello world!"'

# Remove a value to default shared preferences.
adb shell 'am broadcast -a org.example.app.sp.REMOVE --es key key_name'

# Clear all default shared preferences.
adb shell 'am broadcast -a org.example.app.sp.CLEAR --es key key_name'

# It's also possible to specify shared preferences file.
adb shell 'am broadcast -a org.example.app.sp.PUT --es name Game --es key level --ei value 10'

# Data types
adb shell 'am broadcast -a org.example.app.sp.PUT --es key string --es value "hello world!"'
adb shell 'am broadcast -a org.example.app.sp.PUT --es key boolean --ez value true'
adb shell 'am broadcast -a org.example.app.sp.PUT --es key float --ef value 3.14159'
adb shell 'am broadcast -a org.example.app.sp.PUT --es key int --ei value 2015'
adb shell 'am broadcast -a org.example.app.sp.PUT --es key long --el value 9223372036854775807'

# Restart application process after making changes
adb shell 'am broadcast -a org.example.app.sp.CLEAR --ez restart true'
```

```
== Device onformation
...
adb get-statе (print device state)
...
adb shell netstat (list TCP connectivity)
...
adb shell pm list features (list phone features)
adb shell service list (list all services)
adb shell dumpsys activity <package>/<activity> (activity info)
adb shell ps (print process status)
adb shell wm size (displays the current screen resolution)
dumpsys window windows | grep -E 'mCurrentFocus|mFocusedApp' (print current app's opened activity)
```

```
== Package info
...
adb shell dump <name> (list info on one package)
```

```
== Device Related Commands
...
adb shell am start|startservice|broadcast <INTENT>[<COMPONENT>]
-a <ACTION> e.g. android.intent.action.VIEW
-c <CATEGORY> e.g. android.intent.category.LAUNCHER (start activity intent)

adb shell am start -a android.intent.action.VIEW -d URL (open URL)
adb shell am start -t image/* -a android.intent.action.VIEW (opens gallery)
```
