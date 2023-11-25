option predef grmode 800x660

import nuklear as nk

SourceDirectory = {value: ""}
DestinationDirectory = {value: ""}
NameBasicFile= {value: ""}
NameExeFile= {value: ""}
PackageVersion_WindowsDirectory = {value: 1}
PackageVersion_WindowsSelfExtracting = {value: 0}
PackageVersion_LinuxAppImage = {value: 0}
BasicVersion = {value: "SDL2 (sbasicg)"}
CategoryCombo = {value: 1, items: ["AudioVideo", "Audio", "Video", "Development", "Education", "Game", "Graphics", "Network", "Office", "Science", "Settings", "System", "Utility"]}
Message = ""
StartPackaging = 0

const OS_IS_LINUX = 0
const OS_IS_WIN_64 = 1

OS = OS_IS_WIN_64


while(1)
    
    if nk.windowBegin("Distribution Tool for SmallBASIC 12.26", 1, 1, "100%", "100%", "border", "not_movable", "title", "scrollbar") then

        nk.layoutRow("dynamic", 290, 1)

        nk.groupBegin("Files", "border")
            nk.layoutRow("dynamic", 25, 1)
                nk.label("Files","left", "#ffffff")
                
                nk.label("Source Directory:")
                nk.edit("field", SourceDirectory)
                
                nk.label("Destination Directory:")
                nk.edit("field", DestinationDirectory)
                
                nk.Spacing(0)
                
                nk.layoutRowBegin("static", 25, 2)
                    nk.LayoutRowPush(220)
                    nk.label("Name of Basic File:")
                    nk.LayoutRowPush(200)
                    nk.edit("field", NameBasicFile)
                    
                    nk.LayoutRowPush(220)
                    nk.label("Name of Program (without .exe):")
                    nk.LayoutRowPush(200)
                    nk.edit("field", NameExeFile)
                    
                   
                    if(OS == OS_IS_LINUX)
                        nk.LayoutRowPush(220)
                        nk.label("Category (for Linux):")
                        nk.LayoutRowPush(200)
                        nk.combobox(CategoryCombo)
                    endif
                    
                nk.layoutRowEnd()
        nk.groupEnd()

        nk.layoutRow("dynamic", 135, 1)
        nk.groupBegin("Packages", "border")
            nk.layoutRow("dynamic", 25, 1)
            nk.label("Package Version", "left", "#ffffff")
            nk.checkbox("Windows - Package Directory", PackageVersion_WindowsDirectory)
            nk.checkbox("Windows - Self Extracting Archive", PackageVersion_WindowsSelfExtracting)
            if(OS == OS_IS_LINUX)
                nk.checkbox("Linux - AppImage", PackageVersion_LinuxAppImage)
            endif
        nk.groupEnd()

        nk.layoutRow("dynamic", 110, 1)
        nk.groupBegin("Packages", "border")
            nk.layoutRow("dynamic", 25, 1)
            nk.label("SmallBASIC Version", "left", "#ffffff")
            nk.radio("SDL2 (sbasicg)", BasicVersion)
            nk.radio("Console (sbasic)", BasicVersion)        
        nk.groupEnd()

        nk.layoutRow("dynamic", 30, 1)
        if nk.button("Package my Program") then
           StartPackaging = 1
        endif
        
        nk.layoutRow("dynamic", 25, 1)
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

    if nk.windowBegin("Distribution Tool for SmallBASIC 12.26", 1, 1, "100%", "100%", "border", "not_movable", "title", "scrollbar") then
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
    if(NameExeFile.value == "") then
        Message = "Select a executable-file name"
        exit sub
    endif
    select case OS
		case OS_IS_WIN_64
			if(!exist(SourceDirectory.value + "\\" + NameBasicFile.value)) then
				Message = "Basic file doesn't exist"
				exit sub
			endif
		case OS_IS_LINUX
			if(!exist(SourceDirectory.value + "/" + NameBasicFile.value)) then
				Message = "Basic file doesn't exist"
				exit sub
			endif
	end select
    if(exist(DestinationDirectory.value)) then
        Message = "Destination directory already exist."
        exit sub
    endif
    
    
    'Remove spaces in the beginning and at the end
    SourceDirectory.value = trim(SourceDirectory.value)
    DestinationDirectory.value = trim(DestinationDirectory.value)
    NameBasicFile.value = trim(NameBasicFile.value)
    NameExeFile.value = trim(NameExeFile.value)
    
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
    
    mkdir(DestinationDirectory.value)
    
    'SmallBasic runs in windows
    if(OS == OS_IS_WIN_64) then
		if(PackageVersion_WindowsDirectory.value) then
			WIN_PackageVersion_WindowsPackageDirectory()
		endif
		
		if(PackageVersion_WindowsSelfExtracting.value) then
			WIN_PackageVersion_WindowsSelfExtracting()
		endif 
	endif
	'SmallBasic runs in Linux
	if(OS == OS_IS_LINUX) then
		if(PackageVersion_WindowsDirectory.value) then
			LINUX_PackageVersion_WindowsPackageDirectory()
		endif
		
		if(PackageVersion_WindowsSelfExtracting.value) then
			LINUX_PackageVersion_WindowsSelfExtracting()
		endif
		
		if(PackageVersion_LinuxAppImage.value) then
			LINUX_PackageVersion_LinuxAppImage()
		endif
		
	endif

	Message = "Packaging successfull"

end sub

sub LINUX_PackageVersion_LinuxAppImage()
	local f
    
    PrintStatus("AppImage: Copy data.", 0)
    
	mkdir(DestinationDirectory.value + "/Linux_AppImage")
    
    run("cp -R " + enclose("./data/linux/appimage/MyApp.AppDir") + " " + enclose(DestinationDirectory.value + "/Linux_AppImage"))
    run("cp -R " + enclose(SourceDirectory.value) + "/* " + enclose(DestinationDirectory.value + "/Linux_AppImage/MyApp.AppDir/usr/bin"))
    
    if(BasicVersion.value == "SDL2 (sbasicg)") then
        copy "./data/linux/appimage/sbasicg", DestinationDirectory.value + "/Linux_AppImage/MyApp.AppDir/usr/bin/sbasicg"
        copy "./data/linux/appimage/main_sbasicg.sh", DestinationDirectory.value + "/Linux_AppImage/MyApp.AppDir/AppRun"
        chmod DestinationDirectory.value + "/Linux_AppImage/MyApp.AppDir/usr/bin/sbasicg", 0o755
    else
        copy "./data/linux/appimage/sbasic", DestinationDirectory.value + "/Linux_AppImage/MyApp.AppDir/usr/bin/sbasic"
        copy "./data/linux/appimage/main_sbasic.sh", DestinationDirectory.value + "/Linux_AppImage/MyApp.AppDir/AppRun"
        chmod DestinationDirectory.value + "/Linux_AppImage/MyApp.AppDir/usr/bin/sbasic", 0o755
    endif
    
    chmod DestinationDirectory.value + "/Linux_AppImage/MyApp.AppDir/AppRun", 0o755 'rwx-rx-rx
      
    
    if(NameBasicFile.value != "main.bas") then
        rename DestinationDirectory.value + "/Linux_AppImage/MyApp.AppDir/usr/bin/" + NameBasicFile.value, DestinationDirectory.value + "/Linux_AppImage/MyApp.AppDir/usr/bin/main.bas"
		chmod DestinationDirectory.value + "/Linux_AppImage/MyApp.AppDir/usr/bin/main.bas", 0o644 'rw-r-r
    endif
    
    

    'Create xxx.desktop file
    PrintStatus("AppImage: Create desktop file.", 25)
    f = freefile()
    open DestinationDirectory.value + "/Linux_AppImage/MyApp.AppDir/" + NameExeFile.value + ".desktop" for output as #f
    print #f, "[Desktop Entry]"
    print #f, "Name=" + NameExeFile.value
    if(BasicVersion.value == "SDL2 (sbasicg)")
        print #f, "Exec=sbasicg -m./ main.bas"
    else
        print #f, "Exec=sbasic -m ./ main.bas"
    endif
    print #f, "Icon=sb-desktop-128x128"
    print #f, "Terminal=false"
    print #f, "Type=Application"
    if(CategoryCombo.items[CategoryCombo.value] == "Audio" OR CategoryCombo.items[CategoryCombo.value] == "Video") then
        print #f, "Categories=AudioVideo;" + CategoryCombo.items[CategoryCombo.value] + ";"
    else
        print #f, "Categories=" + CategoryCombo.items[CategoryCombo.value] + ";"
    endif
    print #f, "NoDisplay=false"
    print #f, "X-AppImage-Version=1.0"
    close #f
        
    PrintStatus("AppImage: Create AppImage", 50)
    ''for testing:
    'tempstr = enclose("./data/linux/appimage/appimagetool-x86_64.AppImage") + " "
    'for final distribution:
    tempstr = enclose("./appimagetool") + " "
    tempstr = tempstr + enclose(DestinationDirectory.value + "/Linux_AppImage/MyApp.AppDir") + " "
    tempstr = tempstr + enclose(DestinationDirectory.value + "/Linux_AppImage/" + NameExeFile.value + "-x86_64.AppImage")
    run(tempstr)
    
    PrintStatus("AppImage: Clean up", 75)
    run("rm -R " + DestinationDirectory.value + "/Linux_AppImage/MyApp.AppDir")
    
    PrintStatus("AppImage created successfully", 100)
    delay(2)
    
end sub



sub LINUX_PackageVersion_WindowsPackageDirectory()

    PrintStatus("Windows Package: Copy data.", 0)
    
    mkdir(DestinationDirectory.value + "/Win_PackageDirectory")
    mkdir(DestinationDirectory.value + "/Win_PackageDirectory/data")
    run("cp -R " + enclose(SourceDirectory.value) + "/* " + enclose(DestinationDirectory.value + "/Win_PackageDirectory/data"))
    copy "./data/win64/libgcc_s_seh-1.dll", DestinationDirectory.value + "/Win_PackageDirectory/data/libgcc_s_seh-1.dll"
    copy "./data/win64/libstdc++-6.dll", DestinationDirectory.value + "/Win_PackageDirectory/data/libstdc++-6.dll"
    copy "./data/win64/libwinpthread-1.dll", DestinationDirectory.value + "/Win_PackageDirectory/data/libwinpthread-1.dll"
    copy "./data/win64/libclipboard.dll", DestinationDirectory.value + "/Win_PackageDirectory/data/libclipboard.dll"
    copy "./data/win64/libdebug.dll", DestinationDirectory.value + "/Win_PackageDirectory/data/libdebug.dll"
    copy "./data/win64/libglfw.dll", DestinationDirectory.value + "/Win_PackageDirectory/data/libglfw.dll"
    copy "./data/win64/libnuklear.dll", DestinationDirectory.value + "/Win_PackageDirectory/data/libnuklear.dll"
    copy "./data/win64/libraylib.dll", DestinationDirectory.value + "/Win_PackageDirectory/data/libraylib.dll"
    copy "./data/win64/libwebsocket.dll", DestinationDirectory.value + "/Win_PackageDirectory/data/libwebsocket.dll"
    
    PrintStatus("Windows Package: Copy data.", 50)
    
    if(BasicVersion.value == "SDL2 (sbasicg)") then
        copy "./data/win64/sbasicg.exe", DestinationDirectory.value + "/Win_PackageDirectory/data/sbasicg.exe"
        copy "./data/win64/run_sbasicg.exe", DestinationDirectory.value + "/Win_PackageDirectory/"  + NameExeFile.value + ".exe"
    else
        copy "./data/win64/sbasic.exe", DestinationDirectory.value + "/Win_PackageDirectory/data/sbasic.exe"
        copy "./data/win64/run_sbasic.exe", DestinationDirectory.value + "/Win_PackageDirectory/" + NameExeFile.value + ".exe"
    endif

    if(NameBasicFile.value != "main.bas") then
        rename DestinationDirectory.value + "/Win_PackageDirectory/data/" + NameBasicFile.value, DestinationDirectory.value + "/Win_PackageDirectory/data/main.bas"
    endif
    
    PrintStatus("Windows Package created sucessfully", 100)
    pause(2)
     
end sub   



sub LINUX_PackageVersion_WindowsSelfExtracting()
    
    PrintStatus("Self Extracting Archive: Copy data.", 0)
    
    mkdir(DestinationDirectory.value + "/Win_SelfExtracting")
    mkdir(DestinationDirectory.value + "/Win_SelfExtracting/data")
    run("cp -R " + enclose(SourceDirectory.value) + "/* " + enclose(DestinationDirectory.value + "/Win_SelfExtracting/data"))
    copy "./data/win64/libgcc_s_seh-1.dll", DestinationDirectory.value + "/Win_SelfExtracting/data/libgcc_s_seh-1.dll"
    copy "./data/win64/libstdc++-6.dll", DestinationDirectory.value + "/Win_SelfExtracting/data/libstdc++-6.dll"
    copy "./data/win64/libwinpthread-1.dll", DestinationDirectory.value + "/Win_SelfExtracting/data/libwinpthread-1.dll"
    copy "./data/win64/libclipboard.dll", DestinationDirectory.value + "/Win_SelfExtracting/data/libclipboard.dll"
    copy "./data/win64/libdebug.dll", DestinationDirectory.value + "/Win_SelfExtracting/data/libdebug.dll"
    copy "./data/win64/libglfw.dll", DestinationDirectory.value + "/Win_SelfExtracting/data/libglfw.dll"
    copy "./data/win64/libnuklear.dll", DestinationDirectory.value + "/Win_SelfExtracting/data/libnuklear.dll"
    copy "./data/win64/libraylib.dll", DestinationDirectory.value + "/Win_SelfExtracting/data/libraylib.dll"
    copy "./data/win64/libwebsocket.dll", DestinationDirectory.value + "/Win_SelfExtracting/data/libwebsocket.dll"
    
    if(BasicVersion.value == "SDL2 (sbasicg)") then
        copy "./data/win64/sbasicg.exe", DestinationDirectory.value + "/Win_SelfExtracting/data/sbasicg.exe"
        copy "./data/win64/run_sbasicg.exe", DestinationDirectory.value + "/Win_SelfExtracting/"  + NameExeFile.value + ".exe"
    else
        copy "./data/win64/sbasic.exe", DestinationDirectory.value + "/Win_SelfExtracting/data/sbasic.exe"
        copy "./data/win64/run_sbasic.exe", DestinationDirectory.value + "/Win_SelfExtracting/" + NameExeFile.value + ".exe"
    endif

    if(NameBasicFile.value != "main.bas") then
        rename DestinationDirectory.value + "/Win_SelfExtracting/data/" + NameBasicFile.value, DestinationDirectory.value + "/Win_SelfExtracting/data/main.bas"
    endif
    
    source = enclose(DestinationDirectory.value + "/Win_SelfExtracting/*.*")
    dest = enclose(DestinationDirectory.value + "/Win_SelfExtracting/Setup.exe")
    
    PrintStatus("Self Extracting Archive: Compress data", 25)
                    
    s = "7z a -r -mx7 -sdel -sfx\"./data/win64/7z.sfx\" " + dest + " " + source
  
    v = run(s)

    
    'Clean up
    PrintStatus("Self Extracting Archive: Clean up", 75)
    s = "rm -R " + enclose(DestinationDirectory.value + "/Win_SelfExtracting/data")
    v = run(s)

    PrintStatus("Self extracing archive successfully created", 100)
    pause(2)    
    
end sub


sub WIN_PackageVersion_WindowsSelfExtracting()
    
    PrintStatus("Self Extracting Archive: Copy data.", 0)

    mkdir(DestinationDirectory.value + "\\Win_SelfExtracting")
    mkdir(DestinationDirectory.value + "\\Win_SelfExtracting\\data")
    run("xcopy /E /i " + enclose(SourceDirectory.value) + " " + enclose(DestinationDirectory.value + "\\Win_SelfExtracting\\data"))
    copy "data\\win64\\libgcc_s_seh-1.dll", DestinationDirectory.value + "\\Win_SelfExtracting\\data\\libgcc_s_seh-1.dll"
    copy "data\\win64\\libstdc++-6.dll", DestinationDirectory.value + "\\Win_SelfExtracting\\data\\libstdc++-6.dll"
    copy "data\\win64\\libwinpthread-1.dll", DestinationDirectory.value + "\\Win_SelfExtracting\\data\\libwinpthread-1.dll"
    copy "data\\win64\\libclipboard.dll", DestinationDirectory.value + "\\Win_SelfExtracting\\data\\libclipboard.dll"
    copy "data\\win64\\libdebug.dll", DestinationDirectory.value + "\\Win_SelfExtracting\\data\\libdebug.dll"
    copy "data\\win64\\libglfw.dll", DestinationDirectory.value + "\\Win_SelfExtracting\\data\\libglfw.dll"
    copy "data\\win64\\libnuklear.dll", DestinationDirectory.value + "\\Win_SelfExtracting\\data\\libnuklear.dll"
    copy "data\\win64\\libraylib.dll", DestinationDirectory.value + "\\Win_SelfExtracting\\data\\libraylib.dll"
    copy "data\\win64\\libwebsocket.dll", DestinationDirectory.value + "\\Win_SelfExtracting\\data\\libwebsocket.dll"

    if(BasicVersion.value == "SDL2 (sbasicg)") then
        copy "data\\win64\\sbasicg.exe ", DestinationDirectory.value + "\\Win_SelfExtracting\\data\\sbasicg.exe"
        copy "data\\win64\\run_sbasicg.exe ", DestinationDirectory.value + "\\Win_SelfExtracting\\"  + NameExeFile.value + ".exe"
    else
        copy "data\\win64\\sbasic.exe ", DestinationDirectory.value + "\\Win_SelfExtracting\\data\\sbasic.exe"
        copy "data\\win64\\run_sbasic.exe ", DestinationDirectory.value + "\\Win_SelfExtracting\\" + NameExeFile.value + ".exe"
    endif

    if(NameBasicFile.value != "main.bas") then
        rename DestinationDirectory.value + "\\Win_SelfExtracting\\data\\" + NameBasicFile.value, DestinationDirectory.value + "\\Win_SelfExtracting\\data\\main.bas"
    endif

    source = enclose(DestinationDirectory.value + "\\Win_SelfExtracting\\*.*")
    dest = enclose(DestinationDirectory.value + "\\Win_SelfExtracting\\Setup.exe")

    PrintStatus("Self Extracting Archive: Compress data", 25)


    s = "data\\win64\\7z.exe a -r -mx7 -sdel -sfx\"./data/win64/7z.sfx\" " + dest + " " + source
    v = run(s)
    'Message = v


    'Clean up
    PrintStatus("Self Extracting Archive: Clean up", 75)
    's = "rd /q /s " + enclose(DestinationDirectory.value + "\\Win_SelfExtracting\\data")
    'v = run(s)
    kill(DestinationDirectory.value + "\\Win_SelfExtracting\\PackagingTemp.7z")

    PrintStatus("Self extracing archive successfully created", 100)
    pause(2)
end sub    


sub WIN_PackageVersion_WindowsPackageDirectory()
    
    PrintStatus("Windows Package: Copy data", 0)    
    mkdir(DestinationDirectory.value + "\\Win_PackageDirectory")
    mkdir(DestinationDirectory.value + "\\Win_PackageDirectory\\data")
    run("xcopy /E /i " + enclose(SourceDirectory.value) + " " + enclose(DestinationDirectory.value + "\\Win_PackageDirectory\\data"))
    copy "data\\win64\\libgcc_s_seh-1.dll", DestinationDirectory.value + "\\Win_PackageDirectory\\data\\libgcc_s_seh-1.dll"
    copy "data\\win64\\libstdc++-6.dll", DestinationDirectory.value + "\\Win_PackageDirectory\\data\\libstdc++-6.dll"
    copy "data\\win64\\libwinpthread-1.dll", DestinationDirectory.value + "\\Win_PackageDirectory\\data\\libwinpthread-1.dll"
    copy "data\\win64\\libclipboard.dll", DestinationDirectory.value + "\\Win_PackageDirectory\\data\\libclipboard.dll"
    copy "data\\win64\\libdebug.dll", DestinationDirectory.value + "\\Win_PackageDirectory\\data\\libdebug.dll"
    copy "data\\win64\\libglfw.dll", DestinationDirectory.value + "\\Win_PackageDirectory\\data\\libglfw.dll"
    copy "data\\win64\\libnuklear.dll", DestinationDirectory.value + "\\Win_PackageDirectory\\data\\libnuklear.dll"
    copy "data\\win64\\libraylib.dll", DestinationDirectory.value + "\\Win_PackageDirectory\\data\\libraylib.dll"
    copy "data\\win64\\libwebsocket.dll", DestinationDirectory.value + "\\Win_PackageDirectory\\data\\libwebsocket.dll"
    
    PrintStatus("Windows Package: Copy data.", 50)
    
    if(BasicVersion.value == "SDL2 (sbasicg)") then
        copy "data\\win64\\sbasicg.exe ", DestinationDirectory.value + "\\Win_PackageDirectory\\data\\sbasicg.exe"
        copy "data\\win64\\run_sbasicg.exe ", DestinationDirectory.value + "\\Win_PackageDirectory\\"  + NameExeFile.value + ".exe"
    else
        copy "data\\win64\\sbasic.exe ", DestinationDirectory.value + "\\Win_PackageDirectory\\data\\sbasic.exe"
        copy "data\\win64\\run_sbasic.exe ", DestinationDirectory.value + "\\Win_PackageDirectory\\" + NameExeFile.value + ".exe"
    endif

    if(NameBasicFile.value != "main.bas") then
        rename DestinationDirectory.value + "\\Win_PackageDirectory\\data\\" + NameBasicFile.value, DestinationDirectory.value + "\\Win_PackageDirectory\\data\\main.bas"
    endif
    
    PrintStatus("Package Directory created sucessfully", 100)
    pause(2)
     
end sub
