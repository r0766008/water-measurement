
#TODO init toevoegen pubnnub
#TODO  lower aanpassen van percentage -> cm

import RPi.GPIO as GPIO
import time
import sys 
import mysql.connector
from pubnub.pnconfiguration import PNConfiguration 
from pubnub.pubnub import PubNub 
from pubnub.callbacks import SubscribeCallback 
from datetime import datetime

start = datetime.now()
lower = 30
higher = 0
ultrasonic1 = 20
ultrasonic2 = 21
delay = 26

GPIO.setmode(GPIO.BCM)
GPIO.setup(ultrasonic2, GPIO.IN)
GPIO.setup(ultrasonic1, GPIO.OUT)
GPIO.setup(delay, GPIO.OUT)

pnconfig = PNConfiguration()
pnconfig.subscribe_key = 'sub-c-91c29a42-7e21-11ec-8e41-c2c95df3c49a'
pnconfig.publish_key = 'pub-c-d79f4642-99a1-44fa-9ece-708cde163413'
pnconfig.uuid = 'p9Mn66G4D5cOmBlSJSFCmSV8uQn2'
pubnub = PubNub(pnconfig)

mydb = mysql.connector.connect(
  host="localhost",
  user="pi",
  password="raspberry",
  database="waterput"
)
mycursor = mydb.cursor()
sql = "INSERT INTO data (PubNub_ID, Distance) VALUES (%s, %s)"

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

def my_publish_callback(envelope, status):

    # Check whether request successfully completed or not

    if not status.is_error():

        pass  # Message successfully published to specified channel.

    else:

        pass

class MySubscribeCallback(SubscribeCallback):
    

    def message(self, pubnub, message):
        #TODO split innit && message
        user_data = message.message.split("|", 1)
        lower = user_data[1]
        print(message.message)
        print(lower)

pubnub.add_listener(MySubscribeCallback())
pubnub.subscribe().channels('settings-p9Mn66G4D5cOmBlSJSFCmSV8uQn2').execute()

breedte = 0
hoogte = 0
volume = 0
tijd = 0
print("Breedte:",breedte,"cm")
print("Hoogte:",hoogte,"cm")
print("Volume:",volume,"m³")
print("Tijd:",tijd, "s")
print("--------------------")

try:
    while True:
        current_time = datetime.now()
        distance = ultrasonic()
        
        if distance <= lower:
            print(round(distance,2), "cm")
            GPIO.output(delay, 1)

        if distance >= (lower - 5):
            GPIO.output(delay, 0)
            print(round(distance, 2), "cm")
    
        if (( current_time - start).total_seconds()/60) >= 1 :
            val = (pnconfig.uuid, distance)
            mycursor.execute(sql, val)
            mydb.commit()
            print(mycursor.rowcount, "record inserted.")
        

        pubnub.publish().channel('p9Mn66G4D5cOmBlSJSFCmSV8uQn2').message(str(distance)).pn_async(my_publish_callback)

        time.sleep(3)
finally:
    GPIO.cleanup()