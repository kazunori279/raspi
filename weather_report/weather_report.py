#!/usr/bin/python
#
# Weather report: periodically reads temp, humidity and air pressure
# from DHT22 and LPS331AP sensors connected to raspberry pi. Requires
# Adafruit_DHT driver and i2ctools installed.
#
# Usage: sudo python weather_report.py
# 

import time
import subprocess
import Adafruit_DHT
from fluent import sender
from fluent import event

# consts
DHT22_GPIO = 4
LPS331_ADRS = "0x5d"
FL_TAG = "weather" # fluentd event tag
SEND_INTERVAL = 10 # sec

def cmd_exec(cmd):
    p = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    stdout, stderr = p.communicate()
    if stderr != None and len(stderr.strip()) > 0:
        raise IOError("Error on executing cmd: " + stderr)
    return stdout.strip()

def i2cget(reg):
    return cmd_exec("i2cget -y 1 " + LPS331_ADRS + " " + reg)
    
def init_lps():

    # WHO_AM_I
    stdout = cmd_exec("i2cget -y 1 " + LPS331_ADRS + " 0x0f")
    if stdout != "0xbb":
        raise IOError("WHO_AM_I result mismatch.")

    # activate device
    cmd_exec("i2cset -y 1 " + LPS331_ADRS + " 0x20 0x90")

def read_lps():

    # reading from LPS
    out0 = i2cget("0x28")
    out1 = i2cget("0x29")
    out2 = i2cget("0x2a")

    # decoding the value
    return (int(out0, 16) + (int(out1, 16) * 0x100) + (int(out2, 16) * 0x10000)) / 4096.0

def send_metrics():

    # read atmospheric pressure from LPS
    atmos = read_lps()

    # read humidity and temp from DHT 
    humidity, temp = Adafruit_DHT.read_retry(Adafruit_DHT.DHT22, DHT22_GPIO)

    # write metrics to local fluentd
    event.Event("metrics", {
        "atmos": atmos,
        "hum": humidity,
        "temp": temp
    })
    
# init LPS     
init_lps()

# init fluentd
sender.setup(FL_TAG)

# measure and send the metrics periodically 
last_checked = 0
while True:
    if time.time() - last_checked > SEND_INTERVAL:
        last_checked = time.time()
        send_metrics()
    time.sleep(0.5)
