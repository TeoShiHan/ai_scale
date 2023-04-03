import mysql.connector
import sys


db = mysql.connector.connect(
    host="smart-scale.mysql.database.azure.com",
    user="hanhan",
    password="&K&K_Y*Y*k",
    database="smartscale"
)
print("successfully connected", file=sys.stdout)

cursor = db.cursor()
cursor.execute("show databases")

for dbb in cursor:
    print(dbb, file=sys.stdout)