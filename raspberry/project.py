
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

#GPIO.cleanup()


start = datetime.now()

ultrasonic1 = 20
ultrasonic2 = 21
delay = 26
user_data= 0

width = 20
length = 30
depth = 40
bufferLow = 10
bufferHigh = 80
pumpstate = "false"

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
  database="waterput",
  user="pi",
  password="raspberry"
)

mydb2 = mysql.connector.connect(
  host="sql11.freemysqlhosting.net",
  database="sql11468395",
  user="sql11468395",
  password="llhnxj541p"
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
        #! split innit && message
        if message.message:
            user_data = message.message.split("|")
            if user_data[0] == "init":
                length = user_data[4]
                width = user_data[2]
                depth = user_data[6]
                bufferLow = user_data[8]
                bufferHigh = user_data[10]
                print(width,"cm")
                print(length,"cm")
                print(depth)
                print(bufferLow)
                print(bufferHigh)

 
            else:
                if user_data[0] == "length":
                    length = user_data[1]
                    print(user_data[1])
                elif user_data[0] == "depth":
                    depth = user_data[1]
                    print(user_data[1])
                elif user_data[0] == "bufferLow":
                    bufferLow = user_data[1]
                    print(user_data[1])
                elif user_data[0] == "bufferHigh":
                    bufferHigh = user_data[1]
                    print(user_data[1])
                elif user_data[0] == "width":
                    width = user_data[1]
                    print(user_data[1])
                elif user_data[0] == "pumpstate":
                    pumpstate = str(user_data[1])
                    
                    
            


            
pubnub.add_listener(MySubscribeCallback())
pubnub.subscribe().channels(['settings-p9Mn66G4D5cOmBlSJSFCmSV8uQn2', 'pump-p9Mn66G4D5cOmBlSJSFCmSV8uQn2']).execute()


try:
    while True:
        current_time = datetime.now()
        distance = ultrasonic()
        
        if pumpstate == "false":
        #if distance <= bufferLow - 5: #and pumpstate == '1':
            print(pumpstate)
            print(round(distance,2), "cm")
            print("pump is off")
            GPIO.output(delay, 1)

        if pumpstate == "true":
        #if distance >= (bufferLow):# or pumpstate == '0':
            print(pumpstate)
            GPIO.output(delay, 0)
            print("pump is on")
            print(round(distance, 2), "cm")
    
        
        #! after 1min, insert record to DB
        if (( current_time - start).total_seconds()/60) >= 1 :
            val = (pnconfig.uuid, distance)
            mycursor.execute(sql, val)
            mydb.commit()
            print(mycursor.rowcount, "record inserted.")
            start = datetime.now()
        

        #!send distance to App
        pubnub.publish().channel('p9Mn66G4D5cOmBlSJSFCmSV8uQn2').message(str(distance)).pn_async(my_publish_callback)



        time.sleep(3)

except KeyboardInterrupt:
    pass
finally:
    GPIO.cleanup()