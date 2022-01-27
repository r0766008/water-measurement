import mysql.connector

mydb = mysql.connector.connect(
  host="localhost",
  user="pi",
  password="raspberry",
  database="waterput"
)

mycursor = mydb.cursor()

sql = "INSERT INTO data (PubNub_ID, Distance) VALUES (%s, %s)"
val = ("viktor", "22.50")
mycursor.execute(sql, val)

mydb.commit()

print(mycursor.rowcount, "record inserted.")