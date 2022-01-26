#ultra sonic sensor
import RPi.GPIO as GPIO
import time
import sys 
from pubnub.pnconfiguration import PNConfiguration 
from pubnub.pubnub import PubNub 
from pubnub.callbacks import SubscribeCallback 

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

pnconfig = PNConfiguration()
pnconfig.subscribe_key = 'sub-c-91c29a42-7e21-11ec-8e41-c2c95df3c49a'
pnconfig.publish_key = 'pub-c-d79f4642-99a1-44fa-9ece-708cde163413'
pnconfig.uuid = 'p9Mn66G4D5cOmBlSJSFCmSV8uQn2'
pubnub = PubNub(pnconfig)



def my_publish_callback(envelope, status):

    # Check whether request successfully completed or not

    if not status.is_error():

        pass  # Message successfully published to specified channel.

    else:

        pass
try:
    while True:
        distance = ultrasonic()
        #!change to buffer
        if distance >= 30:
            print(distance)
            GPIO.output(delay, 1)
        if distance <= 25:
            GPIO.output(delay, 0)
            print(distance)
        
        pubnub.publish().channel('p9Mn66G4D5cOmBlSJSFCmSV8uQn2').message(str(distance)).pn_async(my_publish_callback)
 
        time.sleep(5)
finally:
    GPIO.cleanup()