#!/bin/sh
for device in XHC1 RP01 RP02 RP03 RP05 RP06; do
    grep $device /proc/acpi/wakeup | grep enabled > /dev/null && {
        echo Disabling wakeup on $device
        echo $device > /proc/acpi/wakeup
    }
done
