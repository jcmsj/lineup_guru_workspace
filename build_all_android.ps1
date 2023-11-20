function build_android($proj) {
    echo "Building $proj"
    cd $proj
    flutter build apk --no-tree-shake-icons
    # remove $proj.apk if it exists
    $apk = "..\bin\all-$proj.apk"
    if (Test-Path $apk) {
        Remove-Item $apk
    }
    Move-Item -Path ".\build\app\outputs\flutter-apk\app-release.apk" -Destination $apk
    cd ..
}

build_android "client"
build_android "admin"
