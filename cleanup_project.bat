@echo off
echo Starting comprehensive Flutter project cleanup...

echo.
echo Step 1: Flutter clean
flutter clean

echo.
echo Step 2: Removing build directories
if exist build rmdir /s /q build
if exist .dart_tool rmdir /s /q .dart_tool
if exist android\build rmdir /s /q android\build
if exist android\app\build rmdir /s /q android\app\build
if exist ios\build rmdir /s /q ios\build

echo.
echo Step 3: Removing pub cache lock
if exist pubspec.lock del pubspec.lock

echo.
echo Step 4: Getting dependencies
flutter pub get

echo.
echo Step 5: Generating code (if needed)
flutter packages pub run build_runner build --delete-conflicting-outputs

echo.
echo Step 6: Cleaning Android project
cd android
if exist .gradle rmdir /s /q .gradle
call gradlew clean
cd ..

echo.
echo Cleanup completed! Now you can rebuild your app.
echo.
echo To rebuild and install on device, run:
echo flutter run --debug
echo.
pause
