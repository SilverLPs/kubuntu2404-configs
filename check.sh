#!/bin/bash

# Check if user script is run as non-root user and exit if not
if [ "$(id -u)" -eq 0 ]; then
    echo "ERROR: This script is not supposed to be run as root but as a normal user"
    exit 1
fi

# sudo to cache the sudo password, as it isn't requested in if Conditions somehow
sudo echo "Starting check script:"
echo

if [ "$(sudo cat /sys/kernel/debug/sched/preempt)" == "none voluntary (full) " ]; then
    echo "✅ Kernel preempt mode is full"
else
    echo "❌ Kernel preempt mode is not full"
fi

if grep -qw "threadirqs" /proc/cmdline; then
    echo "✅ threadirqs is active"
else
    echo "❌ threadirqs is not active"
fi

if id -nG "$USER" | grep -qw "pipewire"; then
    echo "✅ Current user is a member of the pipewire group"
else
    echo "⚠️ Current user is not a member of the pipewire group"
fi

if [ "$(grep "Max realtime priority" /proc/self/limits | awk '{print $(NF-1)}')" -ge 95 ]; then
    echo "✅ Realtime priority value of active user is 95 or higher"
else
    echo "⚠️ Realtime priority value of active user is below 95"
fi

if [ "$(grep "Max locked memory" /proc/self/limits | awk '{print $(NF-1)}')" -ge 4294967296 ]; then
    echo "✅ Locked memory value of active user is 4294967296 or higher"
else
    echo "⚠️ Locked memory value of active user is below 4294967296"
fi

if [ "$(grep "Max nice priority" /proc/self/limits | awk '{print $(NF-1)}')" -ge 39 ]; then
    echo "✅ Nice priority value of active user is 39 or higher"
else
    echo "⚠️ Nice priority value of active user is below 39"
fi

if [ "$(sysctl vm.swappiness)" == "vm.swappiness = 10" ]; then
    echo "✅ Swappiness value is 10"
else
    echo "❌ Swappiness value is not 10"
fi

if [ "$(ldconfig -p | grep 'libjack.so.0' | awk '{print $NF}' | head -n1)" == "/usr/lib/x86_64-linux-gnu/pipewire-0.3/jack/libjack.so.0" ]; then
    echo "✅ JACK-API is redirected to Pipewire-JACK"
else
    echo "❌ JACK-API is not redirected to Pipewire-JACK"
fi

if [ "$(cat /etc/whoopsie | grep report_metrics)" == "report_metrics=false" ]; then
    echo "✅ Telemetry setting for reporting metrics is disabled"
else
    echo "❌ Telemetry setting for reporting metrics is still enabled"
fi

if [ "$(systemctl is-active whoopsie.path)" == "inactive" ]; then
    echo "✅ Telemetry is inactive"
else
    echo "❌ Telemetry is not inactive"
fi

if [ "$(systemctl is-enabled whoopsie.path 2>/dev/null)" == "disabled" ]; then
    echo "✅ Telemetry is disabled"
else
    echo "❌ Telemetry is not disabled"
fi
