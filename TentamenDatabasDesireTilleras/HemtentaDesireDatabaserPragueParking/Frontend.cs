using System;
using System.Collections.Generic;
using System.Text;
using System.Text.RegularExpressions;
using System.Data;
using System.Data.SqlClient;
using Xunit;

namespace HemtentaDesireDatabaserPragueParking
{
    class Frontend
    {
        private ADOBackend backEndIO;

        Menu function = new Menu();

        public Frontend(string connectionString)
        {
            backEndIO = new ADOBackend(connectionString);
        }
        /// <summary>
        /// Chooses the closest parkingspot. Asks if it is a Car or Motorcycle. 
        /// </summary>
        public void CheckIn()
        {
            Console.Clear();
            try
            {
                Console.Write("\n\nEnter license plate and press \"Enter\": ");
                string regnr = Console.ReadLine().ToUpper();
                regnr = StringWash(regnr);
                Console.WriteLine("\n");

                foreach (var choice in backEndIO.BackEndChoiceVehicle())
                {
                    Console.WriteLine(choice);
                }
                Console.Write("\nMake a choice regarding vehicletype : ");
                int vehicleType = function.ReadInt();
                if (vehicleType > 2 || vehicleType < 0)
                {
                    Console.WriteLine("You can only choose between type 1 or 2" +
                        " press ENTER to try again");
                    Console.ReadLine();
                    CheckIn();
                }
                Vehicle vehicle = new Vehicle(regnr);
                vehicle = backEndIO.BackEndCheckIn(regnr, vehicleType);
                string vehicleTypes = "";
                if (vehicle.VehicleType == 1)
                {
                    vehicleTypes = "MC";
                }
                else
                {
                    vehicleTypes = "CAR";
                }
                Console.WriteLine($"\nYour {vehicleTypes} with regnr {vehicle.Regnr} is parked at spot {vehicle.ParkingSpotNum}");
                Console.WriteLine("\n\n Press enter for main menu");
                Console.ReadLine();
            }
            catch (Exception)
            {

                Console.WriteLine("Invalid input, the license plate must be between 3-10 characters long" +
                    " \n and cannot be the same as a vehicle already parked here" +
                    " \n\n Press ENTER to start over");
                Console.ReadLine();
                CheckIn();
            }
        }
        /// <summary>
        /// When you check out vehicle, it will add a row in ParkingHistory in database.It will calculate total price. 
        /// You can choose if you want to charge the cost or not.
        /// </summary>
        public void CheckOut()
        {
            Console.Clear();
            Console.Write("Please enter regnumber for the vehicle you want to check out from the parkinglot :  ");
            string regNr = Console.ReadLine().ToUpper();
            regNr = StringWash(regNr);
            Console.Write("Do you want to check out the vehicle with, or without charge?\n" +
                "\n 1. for No charge \n" +
                "\n 2. for charge standard price : ");
            int answer = function.ReadInt();
            try
            {
                if (answer == 1)
                {
                    if (backEndIO.BackEndCheckOutNoCost(regNr))
                    {

                        Vehicle checkedOutVehicle = new Vehicle(regNr);
                        checkedOutVehicle = backEndIO.CheckOutInfo(regNr);
                        DateTime UpdatedTime = checkedOutVehicle.ArrivalTime ?? DateTime.Now;
                        TimeSpan span = DateTime.Now - UpdatedTime;
                        Console.WriteLine($"Vehicle {regNr} is now checked out from the parking ");
                        Console.WriteLine($"Arrived at {checkedOutVehicle.ArrivalTime}\n" +
                            $"Checked out at {checkedOutVehicle.DepartureTime} \n" +
                            $"Parked for {span.Days} days ,{span.Hours} hours and {span.Minutes} minutes \n" +
                            $"Total cost {checkedOutVehicle.PricePaid} CZK" +
                            $"\n\nPress enter for main menu");
                        Console.ReadLine();
                    }
                }
                if (answer == 2)
                {
                    if (backEndIO.BackEndCheckOut(regNr))
                    {
                        Vehicle checkedOutVehicle = new Vehicle(regNr);
                        checkedOutVehicle = backEndIO.CheckOutInfo(regNr);
                        DateTime UpdatedTime = checkedOutVehicle.ArrivalTime ?? DateTime.Now;
                        TimeSpan span = DateTime.Now - UpdatedTime;
                        Console.WriteLine($"Vehicle {regNr} is now checked out from the parking ");
                        Console.WriteLine($"Arrived at {checkedOutVehicle.ArrivalTime}\n" +
                            $"Checked out at {checkedOutVehicle.DepartureTime} \n" +
                            $"Parked for {span.Days} days ,{span.Hours} hours and {span.Minutes} minutes \n" +
                            $"Total cost {checkedOutVehicle.PricePaid} CZK" +
                            $"\n\nPress enter for main menu");
                        Console.ReadLine();
                    }
                }
                if (answer < 0 || answer > 2)
                {
                    Console.WriteLine("You can only choose between choice 1 or 2" +
                        "\nPress enter to try again!");
                    Console.ReadLine();
                    CheckOut();
                }
            }
            catch (Exception)
            {
                Console.WriteLine("This regnumber is not present at this parking" +
                     "\n Press enter to try again");
                Console.ReadLine();
                CheckOut();
            }
        }
        /// <summary>
        /// Will print the info on the vehicle you want to switch parking on.
        /// It will show a list of available spots for MC or a list for available spots for car
        /// </summary>
        public void SwitchSpot()
        {
            Console.Clear();
            Console.WriteLine("Please enter regnr of the vehicle you want to move :");

            string regNum = Console.ReadLine().ToUpper();
            regNum = StringWash(regNum);
            Vehicle vehicle = new Vehicle(regNum);
            try
            {
                vehicle = backEndIO.VehicleInfo(regNum);                               
                Console.WriteLine($"Vehicle with {regNum} is now on spot {vehicle.ParkingSpotNum} " +
                     $"and arrived at {vehicle.ArrivalTime}");
                Console.Write("To which spot do you want to move the vehicle?");
                ListFreeSpots(vehicle.VehicleType);
                Console.SetCursorPosition(2, 5);
                int newSpot = function.ReadInt();                
                if (backEndIO.BackEndMoveVehicle(regNum, newSpot))
                {
                    Console.Clear();
                    Console.WriteLine($"Vehicle with {regNum} is now on new spot {newSpot}");
                    Console.WriteLine("Press enter for main menu");
                    Console.ReadLine();
                }
                else
                {
                    Console.Clear();
                    Console.WriteLine("This spot is not available!\n\n Press enter to try again");
                    Console.ReadLine();
                    SwitchSpot();
                }
            }
            catch (Exception)
            {
                Console.WriteLine("The vehicle is not present at this parking" +
                    " press enter for menu");
                Console.ReadLine();
            }

        }
        /// <summary>
        /// Use this function in SwitchSpot() method. For listing the available spots depending on
        /// which vehicletype
        /// </summary>
        /// <param name="vehicleType"></param>
        public void ListFreeSpots(int? vehicleType)
        {
            try
            {
                int x = 2;
                int y = 7;

                if (vehicleType == 1)
                {
                    Console.WriteLine("\nFree spots for motorcycles :");

                    for (int i = 0; i < backEndIO.ListAllFreeSpotsMC().Count; i++)
                    {
                        Console.SetCursorPosition(x, y);
                        Console.WriteLine(backEndIO.ListAllFreeSpotsMC()[i]);

                        if (i == 20)
                        {
                            x = 15;
                            y = 7;
                        }
                        if (i==40)
                        {
                            x = 30;
                            y = 7;
                        }
                        if (i==60)
                        {
                            x = 45;
                            y = 7;
                        }
                        if (i==80)
                        {
                            x = 60;
                            y = 7;
                        }
                        y++;
                    }
                }
                else
                {
                    Console.WriteLine("\nFree spots for cars:");
                    int w = 2;
                    int h = 7;
                    for (int i = 0; i < backEndIO.ListAllFreeSpotsCars().Count; i++)
                    {
                        Console.SetCursorPosition(w, h);
                        Console.WriteLine(backEndIO.ListAllFreeSpotsCars()[i]);

                        if (i == 20)
                        {
                            w = 15;
                            h = 7;
                        }
                        if (i == 40)
                        {
                            w = 30;
                            h = 7;
                        }
                        if (i == 60)
                        {
                            w = 45;
                            h = 7;
                        }
                        if (i == 80)
                        {
                            w = 60;
                            h = 7;
                        }
                        h++;
                    }

                }
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
                Console.ReadLine();
            }
        }
        /// <summary>
        /// Use this to wash regnr string from forbidden characters, such as %&#!"
        /// There are constraints in the database that will capture most errors
        /// </summary>
        /// <param name="regnr"></param>
        /// <returns></returns>
        static string StringWash(string regnr)
        {

            Regex washIt = new Regex(@"^[\p{L}\p{M}0-9\s]{1,10}$");// p{L}any kind of letter from any language.p{m} = a character intended to be combined with another character (e.g. accents, umlauts, enclosing boxes, etc.).
            regnr = Regex.Replace(regnr, "\\s+", string.Empty).Trim();
            while (!washIt.IsMatch(regnr))
            {
                Console.Clear();
                Console.SetCursorPosition(36, 10);
                Console.WriteLine("Invalid Input. Forbidden characters used.");
                Console.SetCursorPosition(40, 12);
                Console.WriteLine("Please try again");
                Console.SetCursorPosition(40, 14);
                Console.Write("License Plate: ");
                regnr = Console.ReadLine();
                regnr = Regex.Replace(regnr, "\\s+", string.Empty).Trim();
                Console.Clear();
            }
            string washed = regnr.ToUpper();
            return washed;
        }
        /// <summary>
        /// This will list all spots and vehicles currently parked
        /// </summary>
        public void ListAllSpots()
        {
            try
            {
                Console.ForegroundColor = ConsoleColor.Gray;
                Console.SetCursorPosition(35, 3);
                Console.WriteLine("|Listing all parking spots|\n\n");
                Console.ResetColor();
                int x = 0;
                int y = 7;
                int? spot1;
                string spot2;
                DateTime? spot3;
                string spot4;
                Console.WriteLine($" ParkingSpot\t RegNumber \t\t Arrival time \t\t\tVehicleType");

                for (int j = 0; j < backEndIO.BEListAllSpots().Count; j++)
                {
                    if (backEndIO.BEListAllSpots()[j].VehicleType == 2)
                    {
                        Console.SetCursorPosition(x, y);
                        Console.ForegroundColor = ConsoleColor.Blue;
                        spot1 = backEndIO.BEListAllSpots()[j].ParkingSpotNum;
                        spot2 = backEndIO.BEListAllSpots()[j].Regnr;
                        spot3 = backEndIO.BEListAllSpots()[j].ArrivalTime;
                        spot4 = "CAR";
                        Console.WriteLine($"{spot1}                 {spot2}             {spot3}                {spot4}");
                        Console.ResetColor();
                        y++;
                    }
                    else if (backEndIO.BEListAllSpots()[j].VehicleType == 1)
                    {
                        Console.SetCursorPosition(x, y);
                        Console.ForegroundColor = ConsoleColor.Magenta;
                        spot1 = backEndIO.BEListAllSpots()[j].ParkingSpotNum;
                        spot2 = backEndIO.BEListAllSpots()[j].Regnr;
                        spot3 = backEndIO.BEListAllSpots()[j].ArrivalTime;
                        spot4 = "MOTORCYCLE";
                        Console.WriteLine($"{spot1}                 {spot2}             {spot3}                {spot4}");
                        Console.ResetColor();
                        y++;
                    }
                    else
                    {
                        Console.SetCursorPosition(x, y);
                        Console.ForegroundColor = ConsoleColor.Gray;
                        spot1 = backEndIO.BEListAllSpots()[j].ParkingSpotNum;
                        spot2 = backEndIO.BEListAllSpots()[j].Regnr;
                        spot3 = backEndIO.BEListAllSpots()[j].ArrivalTime;
                        spot4 = "";
                        Console.WriteLine($"{spot1}                 {spot2}             {spot3}                {spot4}");
                        Console.ResetColor();
                        y++;
                    }
                }
                x = x + 25;
                y = 7;
                Console.WriteLine("Press enter for main menu");
                Console.ReadLine();
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
                Console.ReadLine();
            }
        }
        /// <summary>
        /// Visualizes the parking to get a better overview. 
        /// </summary>
        public void Visualize()
        {
            try
            {
                Console.ForegroundColor = ConsoleColor.Gray;                
                Console.WriteLine("|Listing all parking spots|");                
                Console.ForegroundColor = ConsoleColor.Blue;
                Console.Write("\n||");
                Console.ResetColor();
                Console.Write(" = CAR  ");
                Console.ForegroundColor = ConsoleColor.Magenta;
                Console.Write("||");
                Console.ResetColor();
                Console.Write(" = MOTORCYCLE\n\n");
                int x = 2;
                int y = 7;

                for (int j = 0; j < backEndIO.BEListAllSpots().Count+1; j++)
                {

                    if (backEndIO.BEListAllSpots()[j].ParkingSpotNum == 21)
                    {
                        x = 15;
                        y = 7;
                    }
                    if (backEndIO.BEListAllSpots()[j].ParkingSpotNum == 41)
                    {
                        x = 30;
                        y = 7;
                    }
                    if (backEndIO.BEListAllSpots()[j].ParkingSpotNum == 61)
                    {
                        x = 45;
                        y = 7;
                    }
                    if (backEndIO.BEListAllSpots()[j].ParkingSpotNum == 81)
                    {
                        x = 60;
                        y = 7;
                    }
                    if (backEndIO.BEListAllSpots()[j].ParkingSpotNum == 101)
                    {
                        x = 75;
                        y = 7;
                    }
                    if (backEndIO.BEListAllSpots()[j].VehicleType == 2)
                    {
                        Console.ForegroundColor = ConsoleColor.Blue;
                        Console.SetCursorPosition(x, y);
                        Console.WriteLine($"{backEndIO.BEListAllSpots()[j].ParkingSpotNum} ||");
                        Console.ResetColor();
                        y++;
                    }
                    if (backEndIO.BEListAllSpots()[j].VehicleType == 1 && 
                        j == 0 && 
                        backEndIO.BEListAllSpots()[j + 1].ParkingSpotNum != backEndIO.BEListAllSpots()[j].ParkingSpotNum)
                    {
                        Console.ForegroundColor = ConsoleColor.Magenta;
                        Console.SetCursorPosition(x, y);
                        Console.WriteLine($"{backEndIO.BEListAllSpots()[j].ParkingSpotNum} ||");
                        Console.ResetColor();
                        y++;
                        
                    }
                    if (j == 0)
                    {
                        continue;
                    }
                    if (backEndIO.BEListAllSpots()[j -1].ParkingSpotNum == backEndIO.BEListAllSpots()[j].ParkingSpotNum
                        && backEndIO.BEListAllSpots()[j - 1].VehicleType == 1)
                    {
                        Console.ForegroundColor = ConsoleColor.Magenta;
                        Console.SetCursorPosition(x, y);
                        Console.WriteLine($"{backEndIO.BEListAllSpots()[j].ParkingSpotNum} || ||");
                        Console.ResetColor();
                        y++;

                    }

                    if (backEndIO.BEListAllSpots()[j].VehicleType == 1 &&
                        backEndIO.BEListAllSpots()[j - 1].ParkingSpotNum != backEndIO.BEListAllSpots()[j].ParkingSpotNum &&
                        backEndIO.BEListAllSpots()[j + 1].ParkingSpotNum != backEndIO.BEListAllSpots()[j].ParkingSpotNum)
                    {
                        Console.ForegroundColor = ConsoleColor.Magenta;
                        Console.SetCursorPosition(x, y);
                        Console.WriteLine($"{backEndIO.BEListAllSpots()[j].ParkingSpotNum} ||");
                        Console.ResetColor();
                        y++;

                    }
                    if (backEndIO.BEListAllSpots()[j].VehicleType == 0)
                    {
                        Console.ForegroundColor = ConsoleColor.Gray;
                        Console.SetCursorPosition(x, y);
                        Console.WriteLine($"{backEndIO.BEListAllSpots()[j].ParkingSpotNum} ||");
                        Console.ResetColor();
                        y++;
                    }
                }

                Console.ReadLine();
            }
            catch (Exception )
            {
               
                Console.ReadLine();
            }
        }
        /// <summary>
        /// Method for searching for a specific vehicle and what the cost
        /// would be if it checks out
        /// </summary>
        public void FindVehicleOnRegNr()
        {
            Console.Clear();
            Console.Write("\n\nPlease enter regnr of the vehicle you want information about :");
            string regNum = Console.ReadLine().ToUpper();
            regNum = StringWash(regNum);
            Vehicle vehicle = new Vehicle(regNum);
            try
            {
                vehicle = backEndIO.VehicleInfo(regNum);
                DateTime UpdatedTime = vehicle.ArrivalTime ?? DateTime.Now;
                TimeSpan span = DateTime.Now - UpdatedTime;
                Console.WriteLine($"\n\nVehicle with {regNum} is now on spot {vehicle.ParkingSpotNum} " +
                     $"and arrived at {vehicle.ArrivalTime}\n\n" +
                     $"It has been parked for {span.Days} days ,{span.Hours} hours and {span.Minutes} minutes ");
                Console.WriteLine(backEndIO.PrintMoney(regNum));
                Console.WriteLine("\n\nPress enter for main menu");
                Console.ReadLine();
            }
            catch (Exception)
            {
                Console.WriteLine("The vehicle is not present at this parking" +
                    " press enter for menu");
                Console.ReadLine();
            }
        }
        /// <summary>
        /// Will display the income for a specific date or bwetween dates.
        /// It also calcultaes the average between dates
        /// If you want average and total between 2021-02-02 and 2021-02-03, set = 2021-02-01 and 2021-02-04
        /// </summary>
        public void Economy()
        {
            Console.Clear();
            Console.WriteLine("Do you want to see the total income for a " +
                " specific day, or do you want to see the income" +
                " in bwetween two dates?" +
                "\n\n\n Press 1 for a specific day" +
                "\n Press 2 for bwetween two dates" +
                "\n Press 3 for list of total income per day" +
                "\n\nIf you choose a date before the parking was in use," +
                "\nor a date after the last vehicle left the parking," +
                "\nthe system will show you the earliest or latest dates available");
            int answer = function.ReadInt();
            try
            {
                if (answer == 1)
                {
                    Console.WriteLine("Enter a date in format \"2021-02-02\"");
                    DateTime date = DateTime.Parse(Console.ReadLine());
                    Console.WriteLine($"{backEndIO.MoneySpecDay(date)}");
                    Console.WriteLine("\nPress enter for main menu");
                    Console.ReadLine();
                }
                if (answer == 2)
                {
                    Console.WriteLine("Please enter two dates in format \"2021-02-01\"");
                    Console.WriteLine("First date:");
                    DateTime fromDate = DateTime.Parse(Console.ReadLine());
                    Console.WriteLine("Second date:");
                    DateTime toDate = DateTime.Parse(Console.ReadLine());
                    Console.WriteLine("\n\n");
                    Console.WriteLine($" {backEndIO.AverageMoneyPerDay(fromDate, toDate)}");
                    Console.WriteLine($"\n The total income is : {backEndIO.MoneyBetwDates(fromDate, toDate)} CZK");
                    Console.WriteLine("\nPress enter for main menu");
                    Console.ReadLine();
                }
                if (answer == 3)
                {
                    Console.WriteLine("\n\n Day      Month      Year      Total income in CZK");

                    foreach (var day in backEndIO.MoneyPerDay())
                    {
                        Console.WriteLine(day);
                    }
                    Console.WriteLine("\n\n Press enter for main menu");
                    Console.ReadLine();
                }
                if (answer > 3 || answer < 0)
                {
                    Console.WriteLine("You can only answer 1 or 2, please try again. Press enter!");
                    Console.ReadLine();
                    Economy();
                }
            }
            catch (Exception)
            {
                Console.WriteLine("Please try again in correct format ex = \"2021-02-02\"" +
                    "\nEarliest date is 2021-02-02" +
                    " \nPress enter to start again!\n");
                Console.ReadLine();
                Economy();
            }
        }
        /// <summary>
        /// A list of the vehicles parked more than 48 h
        /// </summary>
        public void Parking48h()
        {
            try
            {
                Console.WriteLine("List of vehicles parked more than 48 hours\n");
                foreach (var vehicle in backEndIO.Vehicle48h())
                {
                    Console.WriteLine(vehicle);
                }
                Console.WriteLine("\n\nPress enter for main menu");
                Console.ReadLine();
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
                Console.ReadLine();
            }
        }
        /// <summary>
        /// Optimizes the garage, so that the motorcycles are gathered closest and together 2 and 2. 
        /// </summary>
        public void OptimizeMC()
        {
            try
            {
                foreach (var vehicle in backEndIO.BEOptimizeMC())
                {
                    Console.WriteLine(vehicle);

                }
                if (backEndIO.BEOptimizeMC().Count == 0)
                {
                    Console.WriteLine("The parking is optimized!" +
                        "\n\nPress enter for main menu ");
                }
                Console.ReadLine();
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
            }
        }
        /// <summary>
        /// List of all parking history
        /// </summary>
        public void ListAllHistory()
        {
            try
            {
                Console.WriteLine("Listing the parking history\n\n\n");
                Console.WriteLine("Reg number       " +
                    "Check In Time            " +
                    "Check Out Time       " +
                    "Income        " +
                    "Vehicle type    " +
                    "Time parked \n\n");
                for (int i = 0; i < backEndIO.BEListAllHistory().Count; i++)
                {
                    DateTime UpdatedCheckIn = backEndIO.BEListAllHistory()[i].ArrivalTime ?? DateTime.Now;
                    DateTime UpdatedCheckOut = backEndIO.BEListAllHistory()[i].DepartureTime ?? DateTime.Now;
                    TimeSpan span = UpdatedCheckOut - UpdatedCheckIn;

                    if (backEndIO.BEListAllHistory()[i].VehicleType == 1)
                    {
                        Console.ForegroundColor = ConsoleColor.Magenta;
                        Console.WriteLine($"{backEndIO.BEListAllHistory()[i].Regnr}    " +
                                          $"       {backEndIO.BEListAllHistory()[i].ArrivalTime} " +
                                          $"    {backEndIO.BEListAllHistory()[i].DepartureTime}  " +
                                          $"    {backEndIO.BEListAllHistory()[i].PricePaid}" +
                                          $"               MOTORCYCLE" +
                                          $"      {span.Days} days {span.Hours} hours {span.Minutes} minutes");
                        Console.ResetColor();

                    }
                    else
                    {
                        Console.ForegroundColor = ConsoleColor.Blue;
                        Console.WriteLine($"{backEndIO.BEListAllHistory()[i].Regnr}        " +
                                          $"       {backEndIO.BEListAllHistory()[i].ArrivalTime} " +
                                          $"    {backEndIO.BEListAllHistory()[i].DepartureTime}  " +
                                          $"    {backEndIO.BEListAllHistory()[i].PricePaid}" +
                                          $"               CAR      " +
                                          $"     {span.Days} days {span.Hours} hours {span.Minutes} minutes");
                        Console.ResetColor();
                    }
                }
                Console.WriteLine("\n\nPress enter for main menu");
                Console.ReadLine();
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
                Console.ReadLine();
            }

        }

    }
}
