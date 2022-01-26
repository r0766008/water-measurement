#ultra sonic sensor
import RPi.GPIO as GPIO
import time

ultrasonic1 = 20
ultrasonic2 = 21
delay = 26

GPIO.setmode(GPIO.BCM)
GPIO.setup(ultrasonic2, GPIO.IN)
GPIO.setup(ultrasonic1, GPIO.OUT)
GPIO.setup(delay, GPIO.OUT)

def ultrasonic():
    GPIO.output(ultrasonic1,1)
    time.sleep(0.00001)
    GPIO.output(ultrasonic1,0)
    
    while(GPIO.input(ultrasonic2)==0):
        pass
    signaalhigh = time.time()

    while(GPIO.input(ultrasonic2)==1):
        pass

    signaallow = time.time()
    timepassed = signaallow - signaalhigh
    distance = timepassed * 17000
    return distance

try:
    while True:
        distance = ultrasonic()
        #!change to buffer
        if distance >= 30:
            print(distance)
            GPIO.output(delay, 1)
        else:
            GPIO.output(delay, 0)
 
        time.sleep(1)
finally:
    GPIO.cleanup()