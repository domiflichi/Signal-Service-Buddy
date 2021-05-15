import sqlite3
from telethon import TelegramClient, events, sync
from pathlib import Path
from datetime import datetime
import os
import time



# 
# Note - this script relies on the awesome 'Telethon' library. More can be found out about it here:
# https://github.com/LonamiWebs/Telethon
# However, all you need to do to install it is run the following command:
# pip3 install telethon
# 
# Because this script needs Telegram, you will need your own Telegram account and developer api_id and api_hash (all can be had for free)
#

# To end the script, just hit <ctrl> + C on the keyboard



# Read the file that contains the path to our MT4 folder we want to use
f = open("signalservicebuddysqlitedbpath.txt", "r") # This .txt file acts sort of like a 'configuration' file.

# Read the 1st line only of the above file, and put it into a variable
myPath = Path(f.readline().rstrip()) # The 'rstrip() method strips the pesky special 'newline' at the end of the line...required!

f.close() # Close the file since we're done with it

fullPathToDBFile = myPath / "ssb_trades.db" # Combine the path of 'myPath' and the actual db file name, and we've got our full path to the db file we're going to be working with


# Let's double-check that the path/file exists.
if os.path.isfile(fullPathToDBFile): # If it does exist, great
    print("SQLite database file, " + str(fullPathToDBFile) + " found!")
    print("")
else: # If it does not exist, notify user, exit the script
    print("SQLite database file, " + str(fullPathToDBFile) + " NOT found!")
    print("Please double-check the spelling of the path and database file name, make your correction, and run this program again.")
    print("Exiting script now.")
    exit()



# Telegram stuff
api_id = 1234567
api_hash = '162f10eca6b20b6d31ab2b3ff149c184'

client = TelegramClient('session_name', api_id, api_hash)
client.start()
# End Telegram stuff



# Create a couple connections to our database
conn = sqlite3.connect(fullPathToDBFile) # Connection for retrieving data
conn2 = sqlite3.connect(fullPathToDBFile) # Connection for updating data

c = conn.cursor()
c2 = conn2.cursor()


myInfiniteLoop = True # For our infinite loop...next:

while myInfiniteLoop:

    # Set up our SQL statement to retrieve all records that are considered 'new' (the ones that we haven't sent any signals yet for)
    c.execute("SELECT * FROM tradestbl WHERE SentSignalOrNotYet = 'N'")

    items = c.fetchall()

    for item in items:

        dt = datetime.now()
        t = datetime.now()
        
        theTicketNumberConvertedToText = str(item[1])
        thePair = item[2]
        theEntryPrice = str(item[3])
        theDirection = item[4]

        if theDirection == 'L':
            theDirection = 'Buy'
        elif theDirection == 'S':
            theDirection = 'Sell'

        theTakeProfitPrice = str(item[5])
        theStopLossPrice = str(item[6])

        # Set up a variable and populate with the trade details
        terminalLog = 'New signal found on: ' + dt.strftime('%m/%d/%Y') + ' @ ' + t.strftime('%X') + ' (Ticket Number = ' + theTicketNumberConvertedToText + ') - \n'
        terminalLog = terminalLog + '   ' + theDirection + ' Pair: ' + thePair + ', Entry: ' + theEntryPrice + ', Stop Loss: ' + theStopLossPrice + ', Take Profit: ' + theTakeProfitPrice

        print(terminalLog) # Print out the trade details to the terminal

        TicketNumber = item[1]

        TelegramSignalBroadcastText = theDirection + ' ' + item[2] + ': ' + theEntryPrice + '\n\n'
        TelegramSignalBroadcastText = TelegramSignalBroadcastText + 'Stop Loss: ' + theStopLossPrice + '\n'
        TelegramSignalBroadcastText = TelegramSignalBroadcastText + 'Take Profit: ' + theTakeProfitPrice
        

        c2.execute("UPDATE tradestbl SET SentSignalOrNotYet = 'Y' WHERE TicketNumber = ?", (TicketNumber,))

        conn2.commit()


        # Send Telegram signal!
        client.send_message(entity=-2180736183102,message=TelegramSignalBroadcastText)



# Clean up
conn.close()
conn2.close()