function build_android($proj) {
    echo "Building $proj"
    cd $proj
    flutter build apk --no-tree-shake-icons
    Move-Item -Path ".\build\app\outputs\flutter-apk\app-release.apk" -Destination "..\bin\$proj.apk"
    cd ..
}

build_android "client"
build_android "client_admin"
