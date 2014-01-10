on run (dn)
    delay 1
    tell application "Finder"
        tell disk (dn as string)
            open
            set dsStore to "\"" & "/Volumes" & dn & "/" & ".DS_STORE\""
            tell container window
                set current view to icon view
                set toolbar visible to false
                set statusbar visible to false
                set the bounds to {200, 200, 200+512, 200+320}
                set statusbar visible to false
            end tell
            set opts to the icon view options of container window
            tell opts
                set icon size to 120
                set arrangement to not arranged
            end tell
            set background picture of opts to file ".bg:bg.png"
            set the extension hidden of item "Mesh" to true
            set position of item (dn as string) to {134, 174}
            set position of item " " to {378, 168}
            close
            open
            update without registering applications
            delay 1
            tell container window
                set statusbar visible to false
                set the bounds to {200, 200, 200+512-6, 200+320-6}
            end tell
            update without registering applications
        end tell
    end tell
end run
