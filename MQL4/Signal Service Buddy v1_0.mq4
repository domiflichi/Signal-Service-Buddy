//+------------------------------------------------------------------+
//|                                         Signal Service Buddy.mq4 |
//|                                                    Jamie Navarro |
//|                                             www.jamienavarro.com |
//+------------------------------------------------------------------+


// SETUP SECTION 1
//
// This EA uses the following wrapper/library:
// https://github.com/Shmuma/sqlite3-mt4-wrapper
// So you must have this installed before using this EA!
// After you get this installed, then move on to 'SETUP SECTION 2' below:
// 

// SETUP SECTION 2
//
// 1. Create a SQLite database file named 'ssb_trades.db'
//    Note - the file must be placed in the '<MT4 Installation folder>\MQL4\Files\' folder of your MT4 installation folder!
// 2. Create a table named 'tradestbl', and structure it like this:
//    ID                   Integer (Primary Key)
//    TicketNumber         Integer
//    Pair                 Text
//    EntryPrice           Real
//    LongOrShort          Text
//    TargetPrice          Real
//    StopLossPrice        Real
//    SentSignalOrNotYet   Text
//
// Or, you can just use the database provided
//






#property copyright "Jamie Navarro"
#property link      "www.jamienavarro.com"
#property version   "1.0"
#property strict


#include <sqlite.mqh>


// !!! For some reason I can not get this to work. It seems if you try to use a global variable like this, you get an 'Access Violation Read' error in MT4 :(
//       Sooo, we have to just declare the database filename locally in each function that it's needed in
// The path and filename of the SQLite database file to use
// Not recommended to change this
//extern string db = "ssb_trades.db";            // Filename of your SQLite database 








int OnInit()
{
    if (!sqlite_init()) {
        return INIT_FAILED;
    }
    

   string db = "ssb_trades.db";  // The filename of our SQLite database
   
   // Let's check to make sure that the database file exists before we let our code go any further
   if (FileIsExist(db)) // if it does, continue
      Print("Database file exists, continuing to load this EA");
   else { // if it does NOT, let the user know, then unload the EA because we can't really do anything else
      Alert("***Database file does not exist! Please check that the database file exists, then try agin. This EA will now unload.***");
      Print("***Database file does not exist! Please check that the database file exists, then try agin. This EA will now unload.***");
      ExpertRemove();
   }

   

    return INIT_SUCCEEDED;
}




void OnDeinit(const int reason)
{
    sqlite_finalize();
}










// This function is probably self-explanatory by it's name, but...
   // It loops through all open orders and...
      // It calls the LookUpOrderTicket() function which checks if the order is entered into our SQLite database already or not
      
void LoopThroughOpenOrders()
{

   int TicketNumber;
   double EntryPrice;
   double StopLossPrice;
   double TargetPrice;
   string BuyOrSell;
   
   
   for (int i=OrdersTotal()-1; i>= 0; i--)
   {
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      
      if (OrderType()==OP_BUY || OrderType()==OP_SELL)
         {
         
         // Found an open order! Let's do some stuff!
         
         TicketNumber = OrderTicket();
         EntryPrice = OrderOpenPrice();
         StopLossPrice = OrderStopLoss();
         TargetPrice = OrderTakeProfit();
         
         if (OrderType() == OP_BUY) {
            BuyOrSell = "L"; // 'L' for Long
         } else {
            BuyOrSell = "S"; // 'S' for Short
         }
         
         //Print (TicketNumber);
         
         LookUpOrderTicket(TicketNumber, OrderSymbol(), EntryPrice, StopLossPrice, TargetPrice, BuyOrSell);
         
         }
   }
 
}










// If this function finds that the order that it is looking up is already in the database, it ignores it, and moves on to the next order
      // If it is NOT in the database already, then it calls our insertTradeIntoDB() function to insert the order into the database
void LookUpOrderTicket(int OrderTicketNumberToLookup, string CurrencyPair, double EntryPrice, double StopLossPrice, double TakeProfitPrice, string LongOrShort)
{
   string db = "ssb_trades.db";  // The filename of our SQLite database

   int cols[1];
   int handle = sqlite_query (db, "select * from tradestbl where TicketNumber = " + OrderTicketNumberToLookup, cols);

   if (sqlite_next_row (handle) != 1)
   {
      Print ("Order Ticket#" + OrderTicketNumberToLookup + " not found in database (A new trade found)!"); // Order is NOT yet in the database...we need to enter it!
      
      Print ("Pair: " + CurrencyPair + ", EntryPrice = " + EntryPrice + ", StopLossPrice = " + StopLossPrice + ", TakeProfitPrice = " + TakeProfitPrice + ", LongOrShort = " + LongOrShort);
      
      // For some reason the actual insert doesn't want to work here...must be in a separate function! Hence the call to the below function
      //    Otherwise, I would just perform the 'insert' right here
      insertTradeIntoDB(OrderTicketNumberToLookup, CurrencyPair, EntryPrice, LongOrShort, TakeProfitPrice, StopLossPrice);
      
   } else {
      //Print ("Order " + OrderTicketNumberToLookup + " found in database already!"); // Order is already in the database...no need to do anything else here...
   }
   
   sqlite_free_query (handle); 

}





void OnTick()
{
   // Call our main function to loop through all open positions every tick!
   LoopThroughOpenOrders();
}










// This function will enter the trade details of any open positions found that are not already in our SQLite database
void insertTradeIntoDB (int TicketNum, string CurrencyPair, double EntryPrice, string LongOrShort, double TakeProfitPrice, double StopLossPrice)
{

   string db = "ssb_trades.db";  // The filename of our SQLite database

   string query = "insert into tradestbl (TicketNumber, Pair, EntryPrice, LongOrShort, TargetPrice, StopLossPrice, SentSignalOrNotYet) values (" + TicketNum + ", '" + CurrencyPair + "', " + EntryPrice + ", '" + LongOrShort + "', " + TakeProfitPrice + ", " + StopLossPrice + ", 'N');"; // ------------------- ****************************** FINISH ME!!!!!!!!!!!!!!!!!! ***************-------------------
    
   sqlite_exec (db, query);
     
   Print("Trade entered into DB!");
        
}
