using System;
using System.Collections.Generic;
using System.Text;
using System.Text.RegularExpressions;
using System.Data;
using System.Data.SqlClient;

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
                Console.Write("Enter license plate and press \"Enter\": ");
                string regnr = Console.ReadLine().ToUpper();
                Console.WriteLine("\n");
                regnr = StringWash(regnr);
                
                foreach (var choice in backEndIO.BackEndChoiceVehicle())
                {
                    Console.WriteLine(choice);
                }
                Console.WriteLine("\nMake a choice regarding vehicletype : ");
                int vehicleType = function.ReadInt();
                if (vehicleType > 2 || vehicleType < 0)
                {
                    Console.WriteLine("You can only choose between type 1 or 2" +
                        " press ENTER to try again");
                    Console.ReadLine();
                    CheckIn();
                }

                int parkingSpot = backEndIO.BackEndCheckIn(regnr, vehicleType);
                Console.WriteLine($"Your vehicle with regnr {regnr} is parked at spot {parkingSpot}");
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
                        Console.WriteLine($"Vehicle {regNr} is now checked out from the parking ");
                        Console.WriteLine($"Arrived at {checkedOutVehicle.ArrivalTime}\n" +
                            $"Checked out at {checkedOutVehicle.DepartureTime} \n" +
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
                        Console.WriteLine($"Vehicle {regNr} is now checked out from the parking ");
                        Console.WriteLine($"Arrived at {checkedOutVehicle.ArrivalTime}\n" +
                            $" Checked out at {checkedOutVehicle.DepartureTime} \n" +
                            $" Total cost {checkedOutVehicle.PricePaid} CZK" +
                            $"\n\nPress enter for main menu");
                        Console.ReadLine();
                    }
                }
                if (answer<0 || answer>2)
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
                ListFreeSpots(vehicle.VehicleType);
                Console.WriteLine($"Vehicle with {regNum} is now on spot {vehicle.ParkingSpotNum} " +
                     $"and arrived at {vehicle.ArrivalTime}");
                Console.WriteLine("To which spot do you want to move the vehicle?");
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
                if (vehicleType == 1)
                {
                    Console.WriteLine("Free spots for motorcycles :");

                    foreach (var spot in backEndIO.ListAllFreeSpotsMC())
                    {
                        Console.WriteLine(spot);
                    }
                }
                else
                {
                    Console.WriteLine("Free spots for cars:");
                    foreach (var spot in backEndIO.ListAllFreeSpotsCars())
                    {
                        Console.WriteLine(spot);
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

                for (int j = 0; j < backEndIO.ListAllSpots().Count; j++)
                {
                    if (backEndIO.ListAllSpots()[j].VehicleType == 2)
                    {
                        Console.SetCursorPosition(x, y);
                        Console.ForegroundColor = ConsoleColor.Blue;
                        spot1 = backEndIO.ListAllSpots()[j].ParkingSpotNum;
                        spot2 = backEndIO.ListAllSpots()[j].Regnr;
                        spot3 = backEndIO.ListAllSpots()[j].ArrivalTime;
                        spot4 = "CAR";
                        Console.WriteLine($"{spot1}          |      {spot2}       |     {spot3}      |         {spot4}");
                        Console.ResetColor();
                        y++;
                    }
                    else if (backEndIO.ListAllSpots()[j].VehicleType == 1)
                    {
                        Console.SetCursorPosition(x, y);
                        Console.ForegroundColor = ConsoleColor.Magenta;
                        spot1 = backEndIO.ListAllSpots()[j].ParkingSpotNum;
                        spot2 = backEndIO.ListAllSpots()[j].Regnr;
                        spot3 = backEndIO.ListAllSpots()[j].ArrivalTime;
                        spot4 = "MOTORCYCLE";
                        Console.WriteLine($"{spot1}          |      {spot2}       |     {spot3}      |         {spot4}");
                        Console.ResetColor();
                        y++;
                    }
                    else
                    {
                        Console.SetCursorPosition(x, y);
                        Console.ForegroundColor = ConsoleColor.Gray;
                        spot1 = backEndIO.ListAllSpots()[j].ParkingSpotNum;
                        spot2 = backEndIO.ListAllSpots()[j].Regnr;
                        spot3 = backEndIO.ListAllSpots()[j].ArrivalTime;
                        spot4 = "";
                        Console.WriteLine($"{spot1}          |      {spot2}       |     {spot3}      |         {spot4}");
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
        /// Method for searching for a specific vehicle and what the cost
        /// would be if it checks out
        /// </summary>
        public void FindVehicleOnRegNr()
        {
            Console.Clear();
            Console.WriteLine("Please enter regnr of the vehicle you want information about :");

            string regNum = Console.ReadLine().ToUpper();
            Vehicle vehicle = new Vehicle(regNum);
            try
            {
                vehicle = backEndIO.VehicleInfo(regNum);
                Console.WriteLine($"\n\nVehicle with {regNum} is now on spot {vehicle.ParkingSpotNum} " +
                     $"and arrived at {vehicle.ArrivalTime}\n\n");
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
                "\n Press 1 for a specific day" +
                "\n Press 2 for bwetween two dates");
            int answer = function.ReadInt();
            try
            {
                if (answer == 1)
                {
                    Console.WriteLine("Enter a date in format \"2021-02-02\"");
                    DateTime date = DateTime.Parse(Console.ReadLine());
                    Console.WriteLine($"The total income for this day is: {backEndIO.MoneySpecDay(date)} CZK");
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
                    Console.WriteLine($"Average income between {fromDate} and {toDate} is : {backEndIO.AverageMoneyPerDay(fromDate, toDate)} CZK");
                    Console.WriteLine($"\n The total income is : {backEndIO.MoneyBetwDates(fromDate, toDate)} CZK");
                    Console.WriteLine("\nPress enter for main menu");
                    Console.ReadLine();
                }
                if (answer > 2 || answer < 0)
                {
                    Console.WriteLine("You can only answer 1 or 2, please try again. Press enter!");
                    Console.ReadLine();
                    Economy();
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
                Console.WriteLine("Please try again in correct format \"2021-02-02\"" +
                    " \nPress enter to start again!");
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
                Console.WriteLine("Reg number       Check In Time            Check Out Time       Total Income\n\n");
                for (int i = 0; i < backEndIO.ListAllHistory().Count; i++)
                {
                    Console.WriteLine($"{backEndIO.ListAllHistory()[i].Regnr}  " +
                        $"       {backEndIO.ListAllHistory()[i].ArrivalTime} " +
                        $"    {backEndIO.ListAllHistory()[i].DepartureTime}  " +
                        $"    {backEndIO.ListAllHistory()[i].PricePaid}");

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
