https://github.com/catapult-project/catapult/commit/9b8584120201e28d95740d0777e4f657b2139ff8#diff-d9ce77e42c4ea2456c42295b16aaa1d6

https://github.com/khlam/debloat-samsung-android/blob/7482d4107473956d225a7071d691694c816b1df7/commands.txt

## Privileged apps

https://www.thecustomdroid.com/uninstall-samsung-galaxy-s10-bloatware-guide/
pm uninstall -k --user 0 <app-package-name>

https://forum.xda-developers.com/showpost.php?p=79462709&postcount=23
adb shell cmd package install-existing com.google.android.apps.photos

https://forum.xda-developers.com/showpost.php?p=80265765&postcount=33
Here is a batch file for MIUI devices. You can update package names and test it.
https://gist.github.com/asif-mistry/edc780c8d2def41b846069b40cd38172
adb shell pm uninstall %%X
adb shell pm uninstall --user 0 %%X

https://android.stackexchange.com/questions/179575/how-to-uninstall-a-system-app-using-adb-uninstall-command-not-remove-via-rm-or/186586#186586
pm uninstall -k --user 0 com.android.service
adb uninstall --user 0 com.android.service
