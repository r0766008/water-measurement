#code for the delay
import RPi.GPIO as GPIO
import time

delay = 26

GPIO.setmode(GPIO.BCM)
GPIO.setup(delay, GPIO.OUT)


while True:
    GPIO.output(delay, 1)
    time.sleep(3)
    GPIO.output(delay, 0)
    time.sleep(3)
    print("test")