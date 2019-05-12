#!/bin/bash

# launch the emulator
exec /opt/adk/tools/emulator -avd Android -no-audio -no-window &

# exec adb
exec adb devices &

# exec appium
exec appium
