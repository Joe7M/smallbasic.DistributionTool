option predef grmode 800x640

import nuklear as nk

const OS_IS_LINUX       = 0
const OS_IS_WIN_64      = 1
const SIZE_LEFT_COLUMN  = 130
const SIZE_RIGHT_COLUMN = 640
const OS                = OS_IS_LINUX
const DistToolPath      = ENV("OWD") + "/" ' When inside Appimage, OWD gives the directory of the AppImage
'const DistToolPath      = "./"
const WindowName        = "Android Distribution Tool for SmallBASIC 12.25pre"

SourceDirectory         = {value: ""}
DestinationDirectory    = {value: ""}
IconResDirectory        = {value: ""}
NameBasicFile           = {value: ""}
AppName                 = {value: ""}
TransferADB             = {value: 1}
KeyStore                = {value: ""}
KeyStorePassword        = {value: ""}
KeyAlias                = {value: ""}
KeyPassword             = {value: ""}

Message                 = "For help, check: https://smallbasic.github.io/pages/distributiontool.html"
StartPackaging          = 0



CheckAndroidSDK()



while(1)
    
    if nk.windowBegin(WindowName, 1, 1, "100%", "100%", "border", "not_movable", "title", "scrollbar") then

        nk.layoutRow("dynamic", 25, 1)
        nk.label("Files","left", "#ffffff")
        
        nk.layoutRowBegin("static", 25, 2)  
            nk.LayoutRowPush(SIZE_LEFT_COLUMN)            
            nk.label("Application name:")
            nk.LayoutRowPush(SIZE_RIGHT_COLUMN)           
            nk.edit("field", AppName)
            
            nk.LayoutRowPush(SIZE_LEFT_COLUMN)    
            nk.label("Basic file:")
            nk.LayoutRowPush(SIZE_RIGHT_COLUMN)  
            nk.edit("field", NameBasicFile)                 
        nk.layoutRowEnd()

        nk.Spacing(1)
         
        nk.layoutRow("dynamic", 25, 1)
        nk.label("Directories","left", "#ffffff")
        
        nk.layoutRowBegin("static", 25, 2) 
            nk.LayoutRowPush(SIZE_LEFT_COLUMN)      
            nk.label("Source:")
            nk.LayoutRowPush(SIZE_RIGHT_COLUMN)  
            nk.edit("field", SourceDirectory)
        
            nk.LayoutRowPush(SIZE_LEFT_COLUMN)            
            nk.label("Destination:")
            nk.LayoutRowPush(SIZE_RIGHT_COLUMN)           
            nk.edit("field", DestinationDirectory)
            
            nk.LayoutRowPush(SIZE_LEFT_COLUMN)    
            nk.label("Icon res:")
            nk.LayoutRowPush(SIZE_RIGHT_COLUMN)  
            nk.edit("field", IconResDirectory)                 
        nk.layoutRowEnd()
        
        nk.Spacing(1)
   
        nk.layoutRow("dynamic", 25, 1)
        nk.label("Key for signing the app", "left", "#ffffff")
        
        nk.layoutRowBegin("static", 25, 2) 
            nk.LayoutRowPush(SIZE_LEFT_COLUMN)      
            nk.label("Keystore file:")
            nk.LayoutRowPush(SIZE_RIGHT_COLUMN)  
            nk.edit("field", KeyStore)
        
            nk.LayoutRowPush(SIZE_LEFT_COLUMN)            
            nk.label("Keystore password:")
            nk.LayoutRowPush(SIZE_RIGHT_COLUMN)           
            nk.edit("field", KeyStorePassword)
            
            nk.LayoutRowPush(SIZE_LEFT_COLUMN)    
            nk.label("Key alias:")
            nk.LayoutRowPush(SIZE_RIGHT_COLUMN)  
            nk.edit("field", KeyAlias)
            
            nk.LayoutRowPush(SIZE_LEFT_COLUMN)    
            nk.label("Key password:")
            nk.LayoutRowPush(SIZE_RIGHT_COLUMN)  
            nk.edit("field", KeyPassword)
                 
        nk.layoutRowEnd()
        
        nk.Spacing(1)
        
        nk.layoutRow("dynamic", 25, 1)  
        nk.checkbox("Transfer to device with adb after packaging", TransferADB)

        nk.Spacing(0)
        
        nk.layoutRow("dynamic", 30, 1)
        if nk.button("Package my Program") then
           StartPackaging = 1
        endif
        
        nk.layoutRow("dynamic", 25, 1)
        nk.Spacing(1)
        nk.label(Message)

    endif
    nk.windowEnd()

    if(StartPackaging) then
        PackageProgram()
        StartPackaging = 0
    endif

    nk.waitEvents()  
    delay(50)  'Otherwise ctrl+v (paste) will repeat to fast and paste many times

wend

'########################################################################
sub PrintStatus(StatusMessage, Progress)

    local P
    dim P
    P.value = Progress

    if nk.windowBegin(WindowName, 1, 1, "100%", "100%", "border", "not_movable", "title", "scrollbar") then
        nk.layoutRow("dynamic", 25, 1)
        nk.Spacing(4)
        nk.progress(P, 100, false)
        nk.label(StatusMessage, "centered")
        pause(1)    
    endif
    nk.windowEnd()

end sub


sub PackageProgram()
    Message = "Error during packaging."
    
    'Check input
    if(SourceDirectory.value == "") then
        Message = "Select a source directory"
        exit sub
    endif
    if(!exist(SourceDirectory.value)) then
        Message = "Source directory doesn't exist"
        exit sub
    endif
    if(DestinationDirectory.value == "") then
        Message = "Select a destination directory"
        exit sub
    endif
    if(NameBasicFile.value == "") then
        Message = "Select a basic-file name"
        exit sub
    endif
    if(AppName.value == "") then
        Message = "Select an application name"
        exit sub
    endif
    if(!exist(SourceDirectory.value + "/" + NameBasicFile.value)) then
        Message = "Basic file doesn't exist"
        exit sub
    endif
    if(exist(DestinationDirectory.value)) then
        Message = "Destination directory already exist."
        exit sub
    endif
    if(!exist(IconResDirectory.value)) then
        Message = "Icon res directory doesn't exist."
        exit sub
    endif
    
    'Remove spaces in the beginning and at the end
    SourceDirectory.value = trim(SourceDirectory.value)
    DestinationDirectory.value = trim(DestinationDirectory.value)
    NameBasicFile.value = trim(NameBasicFile.value)
    AppName.value = trim(AppName.value)
    
    'if last characer of the path is a backslash, remove it
    if(right(SourceDirectory.value, 1) == "\\") then
        SourceDirectory.value = left(SourceDirectory.value, len(SourceDirectory.value) - 1)
    endif
    if(right(DestinationDirectory.value, 1) == "\\") then
        DestinationDirectory.value = left(DestinationDirectory.value, len(DestinationDirectory.value) - 1)
    endif
    'if last characer of the path is a slash, remove it
    if(right(SourceDirectory.value, 1) == "/") then
        SourceDirectory.value = left(SourceDirectory.value, len(SourceDirectory.value) - 1)
    endif
    if(right(DestinationDirectory.value, 1) == "/") then
        DestinationDirectory.value = left(DestinationDirectory.value, len(DestinationDirectory.value) - 1)
    endif
       
    select case OS
        case OS_IS_WIN_64
            'WINDOWS_Package()
            print "Windows not supported yet"
            Message = "Windows not supported yet"
            exit sub
        case OS_IS_LINUX
            LINUX_Package()
    end select
    
	

end sub


sub LINUX_Package()
    local BuildToolsPath, PlatformPath, PlatformToolsPath, CurrentDirectory
    local STORE_FILE, KEY_ALIAS, STORE_PASSWORD, KEY_PASSWORD, s    
    
    PrintStatus("Copy data.", 0)    
    
    BuildToolsPath      = DistToolPath + "android-sdk/build-tools/33.0.0/"
    PlatformPath        = DistToolPath + "android-sdk/platforms/android-33/"
    PlatformToolsPath   = DistToolPath + "android-sdk/platform-tools/"
    STORE_FILE          = KeyStore.value
    KEY_ALIAS           = KeyAlias.value
    STORE_PASSWORD      = enclose(KeyStorePassword.value)
    KEY_PASSWORD        = enclose(KeyPassword.value)

    mkdir(DestinationDirectory.value)
    mkdir(DestinationDirectory.value + "/temp")
    mkdir(DestinationDirectory.value + "/temp/build")
    mkdir(DestinationDirectory.value + "/temp/res")
    mkdir(DestinationDirectory.value + "/temp/res/values")
    
    if(!exist(DestinationDirectory.value + "/temp/res/values"))
        Message = "Error: Directories not created"
        print(Message)
        exit sub
    endif
    
    run("cp -R ./SB_AndroidKit/assets " + enclose(DestinationDirectory.value + "/temp/"))
    if(!exist(DestinationDirectory.value + "/temp/assets"))
        Message = "Error: assets not copied"
        print(Message)
        exit sub
    endif
    
    run("cp -R ./SB_AndroidKit/dist " + enclose(DestinationDirectory.value + "/temp/"))
    if(!exist(DestinationDirectory.value + "/temp/dist"))
        Message = "Error: dist not copied"
        print(Message)
        exit sub
    endif
    
    run("cp -R " + enclose(SourceDirectory.value) + "/* " + enclose(DestinationDirectory.value + "/temp/assets"))
    run("cp -R " + enclose(IconResDirectory.value) + "/* " + enclose(DestinationDirectory.value + "/temp/res"))
    
    if(NameBasicFile.value != "main.bas") then
        rename DestinationDirectory.value + "/temp/assets/" + NameBasicFile.value, DestinationDirectory.value + "/temp/assets/main.bas"
		chmod DestinationDirectory.value + "/temp/assets/main.bas", 0o644 'rw-r-r
        if(!exist(DestinationDirectory.value + "/temp/assets/main.bas"))
            Message = "Error: main.bas does not exist"
            print(Message)
            exit sub
        endif
    endif
    
    CurrentDirectory = cwd()
    chdir(DestinationDirectory.value + "/temp")
    
    PrintStatus("Create xml files.", 25)
    
    CreateManifestXML()
    CreateStringsXML()
    
    PrintStatus("Build package.", 50)
    
    run(BuildToolsPath + "aapt2 compile --dir res -o build/resources.zip")
    if(!exist(DestinationDirectory.value + "/temp/build/resources.zip"))
        Message = "Error: resource.zip not created"
        print(Message)
        exit sub
    endif
    
    s = run(BuildToolsPath + "aapt2 link build/resources.zip -I " + PlatformPath + "android.jar --auto-add-overlay --manifest AndroidManifest.xml --java build/gen -o build/res.apk")
    if(!exist(DestinationDirectory.value + "/temp/build/res.apk"))
        Message = "Error: resource.apk not created"
        print(Message)
        exit sub
    endif
   
   
    chdir("dist")
    run("zip -u ../build/res.apk classes.dex")
    run("zip -ur ../build/res.apk lib/*")
    chdir("..")
    run("zip -u build/res.apk assets/**")
    
    s = run(BuildToolsPath + "zipalign -f 4 build/res.apk build/app_unsigned.apk")
    if(!exist(DestinationDirectory.value + "/temp/build/app_unsigned.apk"))
        Message = "Error: app_unsigned.apk not created"
        print(Message)
        exit sub
    endif
    
    s = run(BuildToolsPath + "apksigner sign --ks " + STORE_FILE + " --ks-key-alias " + KEY_ALIAS + " --ks-pass pass:" + STORE_PASSWORD + " --key-pass pass:" + KEY_PASSWORD + " --out build/app_signed.apk build/app_unsigned.apk")
    if(!exist(DestinationDirectory.value + "/temp/build/app_signed.apk"))
        Message = "Error: app_unsigned.apk not created"
        print(Message)
        exit sub
    endif
    
    copy(DestinationDirectory.value + "/temp/build/app_unsigned.apk", DestinationDirectory.value + "/app_unsigned.apk")
    copy(DestinationDirectory.value + "/temp/build/app_signed.apk", DestinationDirectory.value + "/app_signed.apk")
    
    chdir(DestinationDirectory.value)
    
    PrintStatus("Clean up", 75)

    s = run("rm -R " + enclose(DestinationDirectory.value + "/temp"))    
    
    if(TransferADB.value) then
        PrintStatus("Transfer to device.", 95)
        s = run(PlatformToolsPath + "adb install -r ./app_signed.apk")
        'a = run(PlatformToolsPath + "adb -a logcat -c && " + PlatformToolsPath + "adb -a logcat DEBUG:I smallbasic:I AndroidRuntime:E *:S")
    endif
    
    
    chdir(CurrentDirectory)
     
    PrintStatus("Android package successfully created", 100)
    Message = "Android package successfully created"
    
end sub


sub CreateManifestXML()
    local PackageName
    
    PackageName = translate(AppName.value, " ", "")
    PackageName = enclose("net.smallbasic." + PackageName)

    open "AndroidManifest.xml" for output as #1
    
    print #1, "<?xml version=\"1.0\" encoding=\"utf-8\"?>"
    print #1, "<manifest xmlns:android=\"http://schemas.android.com/apk/res/android\""
    print #1, "          package=" + PackageName + ">"
    print #1, "  <supports-screens android:largeScreens=\"true\" />"
    print #1, "  <supports-screens android:xlargeScreens=\"true\" />"
    print #1, "  <uses-sdk android:minSdkVersion=\"16\""
    print #1, "            android:targetSdkVersion=\"30\" />"
    print #1, "  <application android:label=\"@string/app_name\""
    print #1, "               android:hasCode=\"true\""
    print #1, "               android:hardwareAccelerated=\"true\""
    print #1, "               android:usesCleartextTraffic=\"true\""
    print #1, "               android:hasFragileUserData=\"true\""
    print #1, "               android:versionCode=\"1\""
    print #1, "               android:versionName=\"1.0\""
    print #1, "               android:icon=\"@mipmap/ic_launcher\">"
    print #1, "    <activity android:name=\"net.sourceforge.smallbasic.MainActivity\""
    print #1, "              android:label=\"@string/app_name\""
    print #1, "              android:theme=\"@style/SBTheme\""
    print #1, "              android:configChanges=\"orientation|keyboardHidden|screenSize\">"
    print #1, "      <meta-data android:name=\"android.app.lib_name\""
    print #1, "                 android:value=\"smallbasic\" />"
    print #1, "      <intent-filter>"
    print #1, "        <action android:name=\"android.intent.action.MAIN\" />"
    print #1, "        <category android:name=\"android.intent.category.LAUNCHER\" />"
    print #1, "      </intent-filter>"
    print #1, "      <intent-filter>"
    print #1, "        <action android:name=\"android.intent.action.VIEW\" />"
    print #1, "        <category android:name=\"android.intent.category.DEFAULT\" />"
    print #1, "        <category android:name=\"android.intent.category.BROWSABLE\" />"
    print #1, "        <data android:scheme=\"smallbasic\" />"
    print #1, "      </intent-filter>"
    print #1, "    </activity>"
    print #1, "  </application>"
    print #1, "  <uses-permission android:name=\"android.permission.INTERNET\" />"
    print #1, "  <uses-permission android:name=\"android.permission.ACCESS_NETWORK_STATE\" />"
    print #1, "  <uses-permission android:name=\"android.permission.READ_EXTERNAL_STORAGE\" />"
    print #1, "  <uses-permission android:name=\"android.permission.WRITE_EXTERNAL_STORAGE\" />"
    print #1, "  <uses-permission android:name=\"android.permission.ACCESS_COURSE_LOCATION\" />"
    print #1, "</manifest>"
    
    close #1
end

sub CreateStringsXML()
    
    open "./res/values/strings.xml" for output as #1
    
    print #1, "<?xml version=\"1.0\" encoding=\"utf-8\"?>"
    print #1, "<resources>"
    print #1, "  <string name=\"app_name\">" + AppName.value + "</string>"
    print #1, "  <style name=\"SBTheme\" parent=\"android:Theme.Holo.Light\">"
    print #1, "    <item name=\"android:windowActionBar\">false</item>"
    print #1, "    <item name=\"android:windowNoTitle\">true</item>"
    print #1, "    <item name=\"android:windowFullscreen\">true</item>"
    print #1, "    <item name=\"android:windowDisablePreview\">true</item>"
    print #1, "  </style>"
    print #1, "</resources>"

    close #1
    
end

sub CheckAndroidSDK()

    local running, Desktop, ToolsNotInstalled, ToolsNotConfigured
    
    ToolsNotInstalled.value = "Android command-line tools are not installed.\nPlease download the tools, see:\n\nhttps://developer.android.com/studio/index.html#command-tools\n\nand unzip to the distribution-tool folder.\nClick on continue, when finished."
    ToolsNotConfigured.value = "Android command-line tools are installed but not configured.\nDuring the following setup several Android SDK packages will be downloaded.\nYou have to agree to the licenses terms and conditions\n"
    
    if(exist(DistToolPath + "android-sdk"))
        'SDK is installed
        exit
    endif
        
    while(!exist(DistToolPath + "cmdline-tools"))    
        running = true
        while(running)
            if nk.windowBegin(WindowName, 1, 1, "100%", "100%", "border", "not_movable", "title", "scrollbar") then
                nk.layoutRow("dynamic", 530, 1)
                nk.edit("editor", ToolsNotInstalled)   
                nk.layoutRow("dynamic", 30, 1)
                if nk.button("Continue") then
                    running = false
                endif
            endif
            nk.windowEnd()
            nk.waitEvents()  
            delay(50)  'Otherwise ctrl+v (paste) will repeat to fast and paste many times
        wend        
    wend
    
    running = true
    while(running)
        if nk.windowBegin(WindowName, 1, 1, "100%", "100%", "border", "not_movable", "title", "scrollbar") then
            nk.layoutRow("dynamic", 530, 1)
            nk.edit("editor", ToolsNotConfigured)
            nk.layoutRow("dynamic", 30, 1)
            if nk.button("Setup Android SDK") then
                ' We need to open a terminal for downloading some stuff and agree with the licenses.
                ' Depending on the desktop enviroment, different terminals are used.
                ' With $XDG_CURRENT_DESKTOP the current desktop can be querried
                
                Desktop = env("XDG_CURRENT_DESKTOP")
                
                select case Desktop
                    case "KDE"
                        v = run("konsole -e ./install.sh")
                    case "GNOME"
                        v = run("gnome-terminal -- ./install.sh")
                    case "XFCE"
                        v = run("xfce4-terminal --command ./install.sh")
                    case else ' hope it is installed
                        v = run("xterm -e ./install.sh")
                end select
                
                running = 0                
   
            endif
        endif
        nk.windowEnd()
        nk.waitEvents()  
        delay(50)  'Otherwise ctrl+v (paste) will repeat to fast and paste many times
    wend
end
