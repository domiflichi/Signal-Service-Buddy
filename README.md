# Signal-Service-Buddy
A software package for Forex signal service providers. It utilizes MetaTrader 4, Python, a SQLite database, and Telegram to send out trading signals
to your Telegram channel.

Note that this is a very basic, and simple system at the moment that only supports a single take profit. To put it another way - multiple take profits are not supported.


## Quick Overview
This package contains 3 main elements:
1. The MQL4 EA that attaches to your MT4 (MetaTrader 4) chart
2. A Python script
3. A SQLite database

The way it works is there is an EA on your MT4 terminal that monitors your trading account. When it detects a new open trade, it will insert it into the SQLite database.
The Python script is constantly monitoring this database for 'new' trades. When it finds one, it will push out the trade details to your Telegram channel
to your subscribers so that they can take the same trade.


## Pre-requisites
There are some things you'll need before this software package will work:
- This should be obvious, but you'll need a working copy of MT4. If you need to ask what this is, you should stop here and not go any further
- The MQL4 SQlite3 MT4 Wrapper by 'Shmuma', which can be found here: https://github.com/Shmuma/sqlite3-mt4-wrapper
Please follow the instructions found on the project's main page (which is their README) to download and install the wrapper
- A working copy of Python, which can be found at: https://www.python.org/downloads/ (Download and install it)
- After getting Python installed, you'll need the Python Telethon library by 'LonanmiWebs', which can be found here: https://github.com/LonamiWebs/Telethon
Just enter the command that is provided under the 'Installing' section and you'll be good to go for that. You can ignore everything else on that page.
- A Telegram account
- A Telegram api_id and api_hash
- A Telegram channel that you own (and the **ID** of that channel!)

You can obatin your Telegram api_id and api_hash here: https://core.telegram.org/api/obtaining_api_id

There are mutliple ways to obtain the ID of your Telegram channel that you created and want to use, but I used one of the methods found here: 
https://stackoverflow.com/questions/33858927/how-to-obtain-the-chat-id-of-a-private-telegram-channel
Specifically, I used the method that can be found on the post that starts with the text, 'Update #2'.


## Installation Instructions
### The SQLite database (file)
This software package will not work without a SQLite database. You have 2 options here: 1. The easy way, or 2. The not-so-easy-but-not-difficult-way
#### The easy way (download and use the empty database I provided)
1. Download the `ssb_trades.db` file from this repository located in the `SQLite` folder
2. Place the file in the `MQL4\Files\SQLite\` subfolder of your MT4 installation folder (if you do not have the `SQLite` subfolder, create it, and make sure to use 
the exact 'casing' as I have shown here - it is case-sensitive!)
3. Done! See how easy that was?

Or...
#### The not-so-easy-but-not-difficult-way (create your own database from scratch)
1. Download SQLiteStudio from here: https://sqlitestudio.pl/
2. Unzip the contents to a folder on your computer
3. Run SQLiteStudio
4. Create a new database called `ssb_trades.db` in the `MQL4\Files\SQLite` subfolder of your MT4 installation folder (if you do not have the `SQLite` subfolder, create it, and make sure to use 
the exact 'casing' as I have shown here - it is case-sensitive!)
5. In the database, create a new table called `tradestbl`
6. Create the following columns:

Column Name | Data Type
------------ | ------------
ID (Check the Primary Key box on this one) | Integer
TicketNumber | Integer
Pair | Text
EntryPrice | Real
LongOrShort | Text
TargetPrice | Real
StopLossPrice | Real
SentSignalOrNotYet | Text
7. Done, see how not-so-easy-but-not-difficult that was?

There are actually a number of ways to create this SQLite database. For example, you could download SQLite3 and create it from the command line. 
Or you could create it from Python. SQLiteStudio just happens to be how I did it.

### The MetaTrader 4 EA
1. Download the `Signal Service Buddy v1_0.ex4` file located in the `MQL4` folder in this repository
2. Place the file in the `MQL4\Experts\` subfolder of your MT4 installation folder
3. Close your MT4 terminal (if it's currently open)
4. Re-open your MT4 terminal
5. Open up a (preferably the EUR/USD pair, but any will do; any time frame will do) chart window if none are open
6. Drag your new EA from the 'Navigator' window onto the chart
7. In the window that pops up, under the 'Common' tab, make sure that 'Allow DLL imports' is checked
8. Click OK

Note that you do NOT need to have the 'AutoTrading' button activated in your MT4 terminal because remember, this EA does not actually place any trades - it only monitors them

### The Python script
1. Download the `signalservicebuddy.py` file located in the `Python` folder in this repository. Place it into a folder of your choosing on your computer's hard drive.
2. Download the `signalservicebuddysqlitedbpath.txt` file located in the `Python` folder in this repository. Place it into the same folder as you placed the `signalservicebuddy.py` file from #1.
3. Edit the `signalservicebuddysqlitedbpath.txt` file and replace the path that is currently there with the path to the location of where your SQLite database is.
4. Open the `signalservicebuddy.py` file in a text (i.e. Notepad) or code (i.e. Sublime) editor 
5. Look for the following 2 lines of code:
   - `api_id = 1234567`
   - `api_hash = '162f10eca6b20b6d31ab2b3ff149c184'`
6. Change the values of the `api_id` and `api_hash` to the values of *your* Telegram API account.
7. Look for the following line of code:
   - `client.send_message(entity=-2180736183102,message=TelegramSignalBroadcastText)`
7. Change the value of the 'entity' to the ID value of *your* Telegram channel.
8. Save the file, close the editor
9. Run the Python script

That's it! Just one quick thing though - the 1st time you launch your Python script, you'll be prompted to enter your phone number. 
Go ahead and do so (don't forget to include your country code - ie +1 for United States). You'll get a Telegram text/message from Telegram with a one time code after you do this.
Just enter this code and you'll be all set. The reason you need to do this is because you need to give authorization of the 
Python code to your Telegram account. After that, you're good to go!

## Frequently Asked Questions
Q. How much does this awesome software cost?

A. $0

## To Dos

* Add support for multiple take profits

## Troubleshooting
Problem - You receive an error in the Python script (`signalservicebuddy.py`) about not being able to find the file, 
`signalservicebuddysqlitedbpath.txt`. I didn't have this problem on my own PC, but I had this issue when running it on my VPS (FXVM).

Solution - Try providing the full path (currently it's set to the relative path)

Problem - You receive a message in MetaTrader that says 'Database file does not exist!...' when placing the Signal Service Buddy EA
on your chart

Solution #1 - double check that you placed the `ssb_trades.db` file in the correct location for your MetaTrader installation folder. 
See the SQLite database file section of the installation instructions above for more info.

Solution #2 - if you still get the same error and you're sure that you have the path/filename correct (including proper casing) and the
file is there, then try going with option #2 of the SQLite database file (named 'The not-so-easy-but-not-difficult-way (create your own database 
from scratch)') section of the installation instructions

Problem - The Signal Service Buddy EA is not picking up your trades and sending them to your Telegram channel

Solution - There could be many reasons, but one thing to check is to make sure that you still have a connection to your broker in MetaTrader. If 
MetaTrader is not receiving 'ticks'/data from your broker, the EA will not check for new trades. The way the EA works is that it checks 
for new trades every time a new tick comes in - it runs on 'OnTick()'. Therefore, no ticky, no checky.

Problem - The Python script is pegging your CPU at 99%-100%. 

Solution - Don't run it on a single core PC. I had this issue when running it on a VPS that had only 1 CPU core and 1.5GB RAM. I upgraded to 
2 CPUs and 2GB RAM, and it only pegs the CPU to 50% now. Not great, but much better obviously.

