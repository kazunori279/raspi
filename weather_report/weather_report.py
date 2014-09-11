#!/usr/bin/python
#
# Weather report: periodically reads temp, humidity and air pressure
# from DHT22 and LPS331AP sensors connected to raspberry pi. Requires
# Adafruite_DHT driver and i2ctools installed.
#
# Usage: sudo python weather_report.py
# 

import subprocess
import Adafruit_DHT

DHT22_GPIO = 4
LPS331_ADRS = "0x5d"

def cmd_exec(cmd):
    p = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    stdout, stderr = p.communicate()
    return stdout, stderr

def i2cget(reg):
    return cmd_exec("sudo i2cget -y 1 " + LPS331_ADRS + " " + reg)
    
def init_lps():

    # WHO_AM_I
    stdout, stderr = cmd_exec("sudo i2cget -y 1 " + LPS331_ADRS + " 0x0f")
    if stderr != None:
        return stdout, stderr
    if stdout != "0xbb":
        return stdout, "WHO_AM_I result mismatch."

    # activate device
    return cmd_exec("sudo i2cset -y 1 " + LPS331_ADRS + " 0x20 0x90")

def read_lps():

    # reading from LPS
    out0, err0 = i2cget("0x28")
    out1, err1 = i2cget("0x29")
    out2, err2 = i2cget("0x2a")

    # decoding the value
    val = ((int(out0, 16) + int(out1, 16) * 0x100) + (int(out2, 16) * 0x10000)) / 4096
    err = err0 + " " + err1 + " " + err2 
    return val, err 
    
# init LPS     
stdout, stderr = init_lps()
if stderr != None and len(stderr.strip()) > 0:
    print "LPS init error: " + stderr
    exit() 

# read air pressure from LPS
air_pressure, err = read_lps()
print air_pressure 

# read humidity and temp from DHT 
humidity, temp = Adafruit_DHT.read_retry(Adafruit_DHT.DHT22, DHT22_GPIO)
print humidity
print temp 

