using System;
using System.Collections.Generic;
using System.Text;
using System.Data;
using System.Data.SqlClient;

namespace HemtentaDesireDatabaserPragueParking
{
    class ADOBackend
    {
        private readonly string connectionString;
        public ADOBackend(string connectionString)
        {
            this.connectionString = connectionString;
        }
        /// <summary>
        /// Returns an int of the parkingspot closest when checking in a vehicle.
        /// </summary>
        /// <param name="regNr"></param>
        /// <param name="vehicleType"></param>
        /// <returns></returns>
        public Vehicle BackEndCheckIn(string regNr, int vehicleType)
        {
           
            int parkingSpot = 0;
            string sqlQuery = "EXECUTE [InsertVehicle] @regNum = @RegNumber, @vehicleTypeID = @VehicleTypeID;";
            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                SqlCommand command = new SqlCommand(sqlQuery, connection);
                command.Parameters.AddWithValue("@RegNumber", regNr);
                command.Parameters.AddWithValue("@vehicleTypeID", vehicleType);
                try
                {
                    connection.Open();
                    SqlDataReader reader = command.ExecuteReader();
                    reader.Read();
                    parkingSpot = (int)reader["SpotID"];
                    Vehicle newVehicle = new Vehicle(regNr, null, null, null, vehicleType, parkingSpot);
                    return newVehicle;
                }
                catch (InvalidOperationException)
                {
                    throw;
                }
                catch (Exception)
                {
                    throw;
                }
            }
            
        }
        /// <summary>
       /// Function that will return true if the stored procedure is able to
       /// check out the vehicle from the parking.
       /// </summary>
       /// <param name="regNr"></param>
       /// <returns></returns>
        public bool BackEndCheckOut(string regNr)
        {
            int result;
            string sqlQuery = "EXECUTE [CheckOutVehicle] @regNum = @RegNumber ";
            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                SqlCommand command = new SqlCommand(sqlQuery, connection);
                command.Parameters.AddWithValue("@RegNumber", regNr);
                try
                {
                    connection.Open();
                    result = command.ExecuteNonQuery();
                }
                catch (InvalidOperationException)
                {                    
                    throw;
                }
                catch (Exception)
                {                 
                    throw;
                }
            }
            return result > 0;
        }
        /// <summary>
        /// If the user wants to check out a vehicle without charge.
        /// </summary>
        /// <param name="regNr"></param>
        /// <returns></returns>
        public bool BackEndCheckOutNoCost(string regNr)
        {
            int result;
            string sqlQuery = "EXECUTE [CheckOutVehicleNoCost] @regNum = @RegNumber ";
            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                SqlCommand command = new SqlCommand(sqlQuery, connection);
                command.Parameters.AddWithValue("@RegNumber", regNr);
                try
                {
                    connection.Open();
                    result = command.ExecuteNonQuery();
                }
                catch (InvalidOperationException)
                {                    
                    throw;                    
                }
                catch (Exception)
                {                    
                    throw;
                }
            }
            return result > 0;
        }
        /// <summary>
        /// This function displays the first row of check-out info for a specific vehicle. 
        /// I did not put this SQL code in a procedure or function, since
        /// it is short and do not make any changes in the database.
        /// </summary>
        /// <param name="regNum"></param>
        /// <returns></returns>
        public Vehicle CheckOutInfo(string regNum)
        {
            Vehicle infoVehicle = new Vehicle(regNum);
            string sqlQuery = "SELECT TOP 1 CheckInTime, CheckOutTime, TotalCost FROM ParkingHistory "
                            + "WHERE RegNumber = @regNum "
                            + "ORDER BY CheckOutTime DESC;";
            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                SqlCommand command = new SqlCommand(sqlQuery, connection);
                command.Parameters.AddWithValue("@regNum", regNum);
                try
                {
                    connection.Open();
                    SqlDataReader reader = command.ExecuteReader();
                    reader.Read();

                    infoVehicle.ArrivalTime = DateTime.Parse(reader[0].ToString());
                    infoVehicle.DepartureTime = DateTime.Parse(reader[1].ToString());
                    infoVehicle.PricePaid = decimal.Parse(reader[2].ToString());
                }
                catch (Exception)
                {
                    throw;
                }
            }
            return infoVehicle;
        }
        /// <summary>
        /// This function will display the data for a specific vehicle
        /// I chose not to set this SQL code in a procedure or function, since it was short and
        /// does not make any changes in the database.
        /// </summary>
        /// <param name="regNum"></param>
        /// <returns></returns>
        public Vehicle VehicleInfo(string regNum)
        {
            Vehicle infoVehicle = new Vehicle(regNum);
            string sqlQuery = "SELECT RegNumber, VehicleTypeID, SpotID, CheckInTime FROM ParkedVehicles "
                            + "WHERE RegNumber = @regNum ";

            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                SqlCommand command = new SqlCommand(sqlQuery, connection);
                command.Parameters.AddWithValue("@regNum", regNum);
                try
                {
                    connection.Open();
                    SqlDataReader reader = command.ExecuteReader();
                    reader.Read();
                    infoVehicle.VehicleType = (int)(reader[1]);
                    infoVehicle.ParkingSpotNum = (int)(reader[2]);
                    infoVehicle.ArrivalTime = DateTime.Parse(reader[3].ToString());
                }
                catch (Exception)
                {
                    throw;
                }
            }
            return infoVehicle;
        }
        /// <summary>
        /// Executes the procedure in database for moving a vehicle. 
        /// If the move is successful, it will return true to its calling functions.
        /// </summary>
        /// <param name="regNum"></param>
        /// <param name="newSpot"></param>
        /// <returns></returns>
        public bool BackEndMoveVehicle(string regNum, int newSpot)
        {
            int result;
            string sqlQuery = "EXECUTE [MoveVehicle] @regNum = @regNum, @newSpot = @newSpot ";
            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                SqlCommand command = new SqlCommand(sqlQuery, connection);
                command.Parameters.AddWithValue("@regNum", regNum);
                command.Parameters.AddWithValue("@newSpot", newSpot);
                try
                {
                    connection.Open();
                    result = command.ExecuteNonQuery();

                }
                catch (InvalidOperationException )
                {
                    throw;
                }
                catch (Exception)
                {
                    throw; 
                }
            }
            return result > 1;
            
        }
        /// <summary>
        /// Puts all the free parkingspots for Cars in a list. Returns the list 
        /// to its calling functions. 
        /// </summary>
        /// <returns></returns>
        public List<int> ListAllFreeSpotsCars()
        {
            List<int> listOfFreeSpots = new List<int>();
            string sqlQuery = "SELECT * FROM [FreeSpotsCars]";
            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                SqlCommand command = new SqlCommand(sqlQuery, connection);
                try
                {
                    connection.Open();
                    SqlDataReader reader = command.ExecuteReader();
                    while (reader.Read())
                    {
                        int spotNumber = int.Parse(reader[0].ToString());
                        listOfFreeSpots.Add(spotNumber);
                    }
                }
                catch (Exception)
                {
                    throw;
                }
            }
            return listOfFreeSpots;
        }
        /// <summary>
       /// Puts all the free spots for Motorcycles in a list,
       /// returns the list to the calling functions.
       /// </summary>
       /// <returns></returns>
        public List<int> ListAllFreeSpotsMC()
        {
            List<int> listOfFreeSpots = new List<int>();
            string sqlQuery = "SELECT * FROM [FreeSpotsMC]";
            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                SqlCommand command = new SqlCommand(sqlQuery, connection);
                try
                {
                    connection.Open();
                    SqlDataReader reader = command.ExecuteReader();
                    while (reader.Read())
                    {
                        int spotNumber = int.Parse(reader[0].ToString());
                        listOfFreeSpots.Add(spotNumber);
                    }
                }
                catch (Exception)
                {
                    throw;
                }
            }
            return listOfFreeSpots;
        }
        /// <summary>
        /// Will call on the view in the database for listing all spots.
        /// Puts all the vehicles in a list.
        /// </summary>
        /// <returns></returns>
        public List<Vehicle> BEListAllSpots()
        {
            List<Vehicle> returnList = new List<Vehicle>();
            string sqlQuery = "SELECT * FROM [ListAllSpots] ";
            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                SqlCommand command = new SqlCommand(sqlQuery, connection);
                try
                {
                    connection.Open();
                    SqlDataReader reader = command.ExecuteReader();
                    while (reader.Read())
                    {                        
                        int spotNumber = int.Parse(reader[0].ToString());
                        string regNumber = reader[1].ToString();
                        int vehicleType = int.Parse(reader[2].ToString());
                        DateTime checkInTime = DateTime.Parse(reader[3].ToString());
                        Vehicle toBeAdded = new Vehicle(regNumber, checkInTime, null, null, vehicleType, spotNumber);
                        returnList.Add(toBeAdded);
                    }
                }
                catch (Exception)
                {
                    throw;
                }
            }
            return returnList;
        }
        /// <summary>
        /// This function gets a string from the database. It only returns the info on 
        /// how much money the parking cost IF the vehicle is checked out now. 
        /// This could be done much easier with a function in the database.
        /// This was only a test to see if it worked. 
        /// </summary>
        /// <param name="regNum"></param>
        /// <returns></returns>
        public string PrintMoney(string regNum)
        {
            string printMessage = "";
            StringBuilder _Messages = new StringBuilder("");

            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.InfoMessage += delegate (object sender, SqlInfoMessageEventArgs args)
                {
                    SqlConnection _Connection = (SqlConnection)sender;
                    _Messages.Append(args.Message);

                    return;
                };
                conn.Open();
                using (SqlCommand c = new SqlCommand("EXECUTE [PrintMoney] @regNum = @regNum ", conn))
                {
                    c.Parameters.AddWithValue("@regNum", regNum);
                    c.ExecuteNonQuery();
                }
                printMessage = _Messages.ToString();
                return printMessage;
            }
        }
        /// <summary>
       /// This function returns the average sum per day in between two dates.
       /// </summary>
       /// <param name="fromDate"></param>
       /// <param name="toDate"></param>
       /// <returns></returns>
        public string AverageMoneyPerDay(DateTime fromDate, DateTime toDate)
        {
            string sentence = "";           
            string sqlQuery = "EXECUTE [proc_AvgPerDay] @fromDate = @fromDate, @toDate = @toDate";
            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                SqlCommand command = new SqlCommand(sqlQuery, connection);
                try
                {
                    connection.Open();
                    command.Parameters.AddWithValue("@fromDate", fromDate);
                    command.Parameters.AddWithValue("@toDate", toDate);
                    SqlDataReader reader = command.ExecuteReader();
                    reader.Read();
                    DateTime earliest = DateTime.Parse(reader[0].ToString());
                    DateTime latest = DateTime.Parse(reader[1].ToString());
                    int money = (int)reader[2];
                    sentence = ($"The average between {earliest} and {latest} is {money} CZK");
                }
                catch (InvalidOperationException)
                {
                    throw;
                }
                catch (Exception)
                {
                    throw;
                }
            }
            return sentence;
        }
        /// <summary>
       /// This function returns the total sum of income between two dates
       /// </summary>
       /// <param name="fromDate"></param>
       /// <param name="toDate"></param>
       /// <returns></returns>
        public int MoneyBetwDates(DateTime fromDate, DateTime toDate)
        {
            int money;
            string sqlQuery = "SELECT dbo.fk_TotalBetwDates(@fromDate, @toDate)";
            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                SqlCommand command = new SqlCommand(sqlQuery, connection);
                try
                {
                    connection.Open();
                    command.Parameters.AddWithValue("@fromDate", fromDate);
                    command.Parameters.AddWithValue("@toDate", toDate);
                    SqlDataReader reader = command.ExecuteReader();
                    reader.Read();
                    money = (int)reader[0];
                }
                catch (InvalidOperationException)
                {
                    throw;
                }
                catch (Exception)
                {
                    throw;
                }
            }
            return money;

        }
        /// <summary>
        /// Will execute the stored procedure in the database for showing the total income
        /// for a specific day. Returns a int from the database.
        /// </summary>
        /// <param name="date"></param>
        /// <returns></returns>
        public string MoneySpecDay(DateTime date)
        {
            string sentence="";
            string sqlQuery = "EXECUTE [proc_IncomeCertDay] @date = @date";
            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                SqlCommand command = new SqlCommand(sqlQuery, connection);
                try
                {
                    connection.Open();
                    command.Parameters.AddWithValue("@date", date);
                    SqlDataReader reader = command.ExecuteReader();                   
                    reader.Read();
                    DateTime newDate = DateTime.Parse(reader[0].ToString());
                    int money = int.Parse(reader[1].ToString());
                    sentence = $"The total income for {newDate} is {money} CZK";
                }
                catch (InvalidOperationException)
                {
                    throw;
                }
                catch (Exception)
                {
                    throw;
                }
            }
            return sentence;
        }
        /// <summary>
        /// Calls for a view in the database that puts the info on
        /// vehicles parked more than 48 h in a list of strings
        /// returns the list to the calling functions.
        /// Since I wanted the information on "Hours parked" I couldn't use
        /// a list of vehicles. If I had better planning, I would've created another property
        /// "hoursparked" in the Vehicle class.
        /// </summary>
        /// <returns></returns>
        public List<string> Vehicle48h()
        {
            List<string> listOfRegNr48h = new List<string>();

            string sqlQuery = "SELECT * FROM [Vehicles48h] ";

            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                SqlCommand command = new SqlCommand(sqlQuery, connection);

                try
                {
                    connection.Open();
                    SqlDataReader reader = command.ExecuteReader();
                    while (reader.Read())
                    {
                        string spot = (string)(reader[0]);
                        string regNr = (string)(reader[1]);
                        string arrivalTime = (string)(reader[2]);
                        int hoursParked = int.Parse(reader[3].ToString());
                        listOfRegNr48h.Add($"Spot: {spot} | Regnr :{regNr} | Arrival Time : {arrivalTime}  | Hours parked : {hoursParked}\n");
                    }
                }
                catch (Exception)
                {
                    throw;
                }
            }
            return listOfRegNr48h;
        }
        /// <summary>
        /// Will execute stored procedure in the database, to move the motorcycles together 2 and 2.
        /// </summary>
        /// <returns></returns>
        public List<string> BEOptimizeMC()
        {
            List<string> returnList = new List<string>();

            string sqlQuery = "EXECUTE proc_OptimizeMC";
            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                SqlCommand command = new SqlCommand(sqlQuery, connection);
                try
                {
                    connection.Open();
                    SqlDataReader reader = command.ExecuteReader();
                    while (reader.Read())
                    {                        
                        string regNumber = (string)reader[0].ToString();
                        int oldSpot = int.Parse(reader[1].ToString());
                        int newSpot = int.Parse(reader[2].ToString());                        
                        returnList.Add($"{regNumber} has been moved from spot: {oldSpot} to spot: {newSpot}");
                    }
                }
                catch (Exception)
                {
                    throw;
                }
            }
            return returnList;
        }
        /// <summary>
        /// Will list all the vehicle types that are available in the database
        /// </summary>
        /// <returns></returns>
        public List<string> BackEndChoiceVehicle()
        {
            List<string> listOfChoice = new List<string>();

            string sqlQuery = "SELECT CAST(VehicleTypeID AS NVARCHAR(10)) as 'Choice', TypeName as 'Vehicle type' FROM VehicleTypes";
            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                SqlCommand command = new SqlCommand(sqlQuery, connection);
                try
                {
                    connection.Open();
                    SqlDataReader reader = command.ExecuteReader();
                    while (reader.Read())
                    {
                        string choice = (string)reader[0];
                        string vehicleType = (string)reader[1];
                        listOfChoice.Add($"{choice}.  {vehicleType}");
                    }
                }
                catch (InvalidOperationException)
                {
                    throw;
                }
                catch (Exception)
                {
                    throw;
                }
            }
            return listOfChoice;
        }
        /// <summary>
        /// Executing view in database for showing the parking history
        /// </summary>
        /// <returns></returns>
        public List<Vehicle> BEListAllHistory()
        {
            List<Vehicle> returnList = new List<Vehicle>();
            string sqlQuery = "SELECT* FROM [DisplayHistory]";
            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                SqlCommand command = new SqlCommand(sqlQuery, connection);
                try
                {
                    connection.Open();
                    SqlDataReader reader = command.ExecuteReader();
                    while (reader.Read())
                    {                        
                        string regNumber = reader[0].ToString();                        
                        DateTime checkInTime = DateTime.Parse(reader[1].ToString());
                        DateTime checkOutTime = DateTime.Parse(reader[2].ToString());
                        int totalPrice = int.Parse(reader[3].ToString());
                        int vehcileType = int.Parse(reader[4].ToString());
                        Vehicle toBeAdded = new Vehicle(regNumber, checkInTime, checkOutTime, totalPrice, vehcileType, null);
                        returnList.Add(toBeAdded);
                    }
                }
                catch (Exception)
                {
                    throw;
                }
            }
            return returnList;
        }
        /// <summary>
        /// Generates a list of total income sorted per each day. 
        /// Executes a view in the database.
        /// </summary>
        /// <returns></returns>
        public List<string> MoneyPerDay()
        {
            List<string> listOfDays = new List<string>();            
            string sqlQuery = "SELECT * FROM [v_IncomePerDay] ";
            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                SqlCommand command = new SqlCommand(sqlQuery, connection);
                try
                {
                    connection.Open();                   
                    SqlDataReader reader = command.ExecuteReader();
                    while (reader.Read())
                    {
                        int money = int.Parse(reader[0].ToString());
                        int day = int.Parse(reader[1].ToString());
                        int month = int.Parse(reader[2].ToString());
                        int year = int.Parse(reader[3].ToString());
                        listOfDays.Add($"{day}            {month}        {year}             {money} ");
                    }                     

                }
                catch (InvalidOperationException)
                {
                    throw;
                }
                catch (Exception)
                {
                    throw;
                }
            }
            return listOfDays;
        }
    }
}



