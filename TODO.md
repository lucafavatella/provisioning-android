https://gist.github.com/Pulimet/5013acf2cd5b28e55036c82c91bd56d8
quoting https://www.automatetheplanet.com/adb-cheat-sheet/ as one of the sources.

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
