# Java2Smali
Simple yet advanced java to smali compiling script ( for Android )

## Usage
```
java2smali -s 7.1.jar -o out MyImageView.java
```
The above compile the source file using android 7.1 sources and copy the smali to the out directory<br>
<br>Available Options :
```
Java2Smali : Simple yet advanced java to smali compiling script ( for Android )

Usage : java2smali [options] <source-file>

Options:

        -h, --help               Prints out this help menu
        -v, --verbose            Verbose output ( for javac )
        -s, --sdk <file>         Name of the sdk jar file ( $J2S_SDKS directory can be configured via config.sh )
        -o, --out <dir>          Compiles output into the given direcotry
```

## Configuration
The script can be configured through `config.sh` which will be sourced upon running.
| Variable | Usage | Downloads/Source |
| -------- | -------| ---------| 
| **J2S_SDKS** | _Path to a directory to look for android sdks ( used by -s and **$J2S_DEFAULT_SDK** )_ | <a href="https://github.com/Sable/android-platforms/" target="_blank">Unoffical Github Repo</a> or <a href="https://androidsdkmanager.azurewebsites.net/SDKPlatform/" target="_blank">Online Android SDK Manager</a>
| **J2S_DEFAULT_SDK** | _Default sdk jar name ( looks for file in **$J2S_SDKS** )_ | N/A
| **J2S_FRAMEWORK** | _Path to any android framework jar ( leave the value empty if you don't have any )_ | found in `/system/framework/` of android ( use adb pull to retrieve )
| **J2S_DX** | _Path to dx script ( found in android build-tools )_ | <a href="https://developer.android.com/studio/" target="_blank" >Offical (Command line tools)<a/> or <a href="https://androidsdkmanager.azurewebsites.net/Buildtools/" target="_blank" >Online Android SDK Manage</a>
| **J2S_BAKSMALI** | _Path to baksmali.jar_ | <a href="https://github.com/JesusFreke/smali" target="_blank" >Offical Github Repo</a>

## Note
I wrote this script since I was reverse engineering a systemui and was working with some custom layouts where I had to use gradle/andoid studio to compile the apk and get the smali code by apktool. Even tho, I couldn't compile some classes which had restricted apis like 'SurfaceControl'. So, I decided to write this script to do the task much faster. Feel free to open an Issue if you find any and you can contribute to this to repo by forking it.
