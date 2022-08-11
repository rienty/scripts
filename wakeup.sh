#!/bin/sh
for device in XHC1 LID0; do
    grep $device /proc/acpi/wakeup | grep enabled > /dev/null && {
        echo Disabling wakeup on $device
        echo $device > /proc/acpi/wakeup
    }
done
