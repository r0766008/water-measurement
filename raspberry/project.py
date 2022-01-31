#login database:
#https://www.phpmyadmin.co/index.php
# Server: sql11.freemysqlhosting.net
# Name: sql11468395
# Username: sql11468395
# Password: llhnxj541p
# Port number: 3306

import RPi.GPIO as GPIO
import time
import sys 
import mysql.connector
import requests
from pubnub.pnconfiguration import PNConfiguration 
from pubnub.pubnub import PubNub 
from pubnub.callbacks import SubscribeCallback 
from datetime import datetime

GPIO.setwarnings(False)


#*----------------
insert_time = 1 
delay_time = 3
#*----------------

ultrasonic1 = 20
ultrasonic2 = 21
relais = 26
user_data= 0
width = 11.5
length = 11.5
depth = 21
bufferLow = ((20/100) * depth)
bufferHigh = ((90/100) * depth)
pumpstate = "false"
pumpAutomatic = "false"
#!FOUT BIJ PERCENTAGE
percentage = 55
#!-------------------
bufferLow_percentage = 10
bufferHigh_percentage = 80
notification_status = True

start = datetime.now()

server_key = "key=AAAATrsNAhg:APA91bHeunhvFCCg41p35WZT8Ca-dJL7ParL1RzYevo1i06GX1FYg7EXfM2Tc8TMpg23a5cGRfpJadwgnd9K39FA8ZcbiLLwtAwoeUPHVzcb6xDHCadhT8fFCodfOlNNZW8Csfy_GGaq"
url = "https://fcm.googleapis.com/fcm/send?"
registration_tokens = ["cN88_scDQ8KGsBxdCd3G4r:APA91bESvwjqlcO1oeOHXRc63LbOYYlpxsQHGi3v8ZFqKwAdY4TCIZ21cVvfpRQP-V7e1v5sEYOhYd1lUTnXOW7kq2itKBODj8VceWljwgghKB7RfRU6exIDQid_n-lfu7pBYXYPQTJR",
"dMnP4d7qRL6Ve8bwrxSyqk:APA91bGl36yRL1Sn6IiwqvWVuvMlCh1StQLcYVLITeyH6GDJ3OG7uu2YxNxyj6YMOMTxkGNFXR-NeiuVvtu7m0BkhUaxGIaknoLs-z3pjsnzK0vJQZWY5kvpFf5agYUhpRCgkkCdpYap"]

GPIO.setmode(GPIO.BCM)
GPIO.setup(ultrasonic2, GPIO.IN)
GPIO.setup(ultrasonic1, GPIO.OUT)
GPIO.setup(relais, GPIO.OUT)

pnconfig = PNConfiguration()
pnconfig.subscribe_key = 'sub-c-91c29a42-7e21-11ec-8e41-c2c95df3c49a'
pnconfig.publish_key = 'pub-c-d79f4642-99a1-44fa-9ece-708cde163413'
pnconfig.uuid = 'p9Mn66G4D5cOmBlSJSFCmSV8uQn2'
pubnub = PubNub(pnconfig)

# mydb2 = mysql.connector.connect(
#   host="localhost",
#   database="waterput",
#   user="pi",
#   password="raspberry"
# )

mydb = mysql.connector.connect(
  host="sql11.freemysqlhosting.net",
  database="sql11468395",
  user="sql11468395",
  password="llhnxj541p"
) 

mycursor = mydb.cursor()
sql = "INSERT INTO measurements (pubnub_id, distance) VALUES (%s, %s)"

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

def notification():
    level = 'onder'
    levelPercentage = bufferLow_percentage
    if percentage > float(bufferHigh_percentage):
        level = 'boven'
        levelPercentage = bufferHigh_percentage

    if percentage < float(bufferLow_percentage):
        level = 'onder'
        levelPercentage = bufferLow_percentage

    title = "Waterniveau"
    body = "Het waterniveau is " + level + " " + str(levelPercentage) + "%"
    
    for token in registration_tokens:
        
        payload='{"to": "' + token + '", "notification": {"title": "' + title + '", "body": "' + body + '", "mutable_content": true, "sound": "Tri-tone" },}'
        headers = {
            'Content-Type': 'application/json',
            'Authorization': server_key
        }

        response = requests.request("POST", url, headers=headers, data=payload)
        print(response.text)


class MySubscribeCallback(SubscribeCallback):
    def message(self, pubnub, message):
        if message.message:
            user_data = message.message.split("|")
            global bufferLow, width, length, depth, bufferHigh,pumpstate, pumpAutomatic, bufferLow_percentage, bufferHigh_percentage
            if user_data[0] == "init":                
                length = user_data[4]
                width = user_data[2]
                depth = user_data[6]
                bufferLow = ((user_data[8]/100)*depth)
                bufferLow_percentage = user_data[8]
                bufferHigh = ((user_data[10])/100)*depth
                bufferHigh_percentage = user_data[10]
                pumpAutomatic = user_data[12]
                pumpstate = user_data[14]
                print(width,"cm")
                print(length,"cm")
                print(depth)
                print("----------")
                print(bufferLow)
                print(bufferHigh)
                print("----------")
                print(pumpAutomatic)
                print(pumpstate)

            else:
                if user_data[0] == "length":
                    length = user_data[1]
                    print(user_data[1])                
                elif user_data[0] == "depth":                    
                    depth = user_data[1]
                    print(user_data[1])
                elif user_data[0] == "bufferLow":
                    bufferLow = ((float(user_data[1])/100)*float(depth))
                    bufferLow_percentage = user_data[1]
                    print(user_data[1])                    
                elif user_data[0] == "bufferHigh":                    
                    bufferHigh = ((float(user_data[1])/100)*float(depth))
                    bufferHigh_percentage = user_data[1]
                    print(user_data[1])
                elif user_data[0] == "width":                    
                    width = user_data[1]
                    print(user_data[1])
                elif user_data[0] == "pumpstate":
                    pumpstate = user_data[1]
                    print(pumpstate)
                elif user_data[0] == "pumpAutomatic":
                    pumpAutomatic = user_data[1]

pubnub.add_listener(MySubscribeCallback())
pubnub.subscribe().channels(['settings-p9Mn66G4D5cOmBlSJSFCmSV8uQn2', 'pump-p9Mn66G4D5cOmBlSJSFCmSV8uQn2']).execute()


try:
    while True:
        current_time = datetime.now()
        distance = ultrasonic()
        percentage = ((float(depth)-distance)/float(depth)) * 100

        print("notification:", str(notification_status))
        print("distance:", round(float(distance), 3), "cm")
        print("buffer low:", round(float(bufferLow),3),"cm")
        print("buffer low percentage:", bufferLow_percentage,"%")
        print("buffer high:", round(float(bufferHigh), 3), "cm")
        print("buffer high percentage", bufferHigh_percentage, "%")
        print('------------------------')

        if pumpAutomatic == "true":
            if distance <= (float(depth) - float(bufferLow)) + 0.5:
                GPIO.output(relais, 1)
                

            elif distance >= float(depth) - float(bufferLow):
                GPIO.output(relais, 0)

        if (distance) <= float(bufferHigh) and distance >= float(bufferLow):
            notification_status = True
        
        elif pumpAutomatic == "false":
            if pumpstate == "true":
                GPIO.output(relais, 0)
                
            elif pumpstate == "false":
                GPIO.output(relais, 1)
        
        #! afstand >= 19 - 1
        if (distance >= (float(depth) - float(bufferLow))) and notification_status == True:
            notification()
            notification_status = False

        if (distance <= (float(depth)-float(bufferHigh))) and notification_status == True:
            notification()
            notification_status = False

        if ((current_time - start).total_seconds()/60) >= insert_time :
            val = (pnconfig.uuid, distance)
            mycursor.execute(sql, val)
            mydb.commit()
            print(mycursor.rowcount, "record inserted.")
            start = datetime.now()
        
        pubnub.publish().channel('p9Mn66G4D5cOmBlSJSFCmSV8uQn2').message(str(distance)).pn_async(my_publish_callback)
        time.sleep(delay_time)
        

except KeyboardInterrupt:
    pass
finally:
    GPIO.cleanup()