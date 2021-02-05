using System;
using System.Collections.Generic;
using System.Text;
using System.Data;
using System.Data.SqlClient;

namespace HemtentaDesireDatabaserPragueParking
{
    public class Menu
    {
        public string ConnectionString()
        {
            string connectionString = @"Data Source=DESKTOP-4MA071C\SQLEXPRESS;Initial Catalog=PPDBDesireTilleras;Integrated Security=True";
            return connectionString;
        }
        public void MainMenu()
        {
            
            Frontend frontEnd = new Frontend(ConnectionString());
            
            Console.Clear();
            
            int userInput = 0;

            do
            {
                userInput = DisplayMenu();  
                Console.Clear();
                switch (userInput)
                {
                    case 1:                        
                        Console.ForegroundColor = ConsoleColor.Gray;
                        frontEnd.CheckIn();
                        break;
                    case 2:                        
                        Console.ForegroundColor = ConsoleColor.Gray;
                        frontEnd.CheckOut();
                        break;
                    case 3:
                        Console.ForegroundColor = ConsoleColor.Gray;
                        frontEnd.SwitchSpot();                        
                        break;
                    case 4:                        
                        Console.ForegroundColor = ConsoleColor.Gray;
                        frontEnd.FindVehicleOnRegNr();
                        break;
                    case 5:
                        Console.ForegroundColor = ConsoleColor.Gray;
                        frontEnd.ListAllSpots();
                        break;
                    case 6:
                        frontEnd.OptimizeMC();
                        break;
                    case 7:
                        frontEnd.ListAllHistory();
                        break;
                    case 8:
                        frontEnd.Economy();
                        break;
                    case 9:
                        frontEnd.Parking48h();
                        break;
                    case 10:
                        frontEnd.Visualize();
                        break;
                    case 11:
                        Console.SetCursorPosition(26, 10);
                        Console.ForegroundColor = ConsoleColor.Gray;
                        Console.WriteLine("Thank you for using | OLD TIMES SQUARE PARKING GARAGE system|");
                        Console.SetCursorPosition(34, 12);
                        Console.ForegroundColor = ConsoleColor.Gray;
                        Console.WriteLine("We hope you had a nice day at work!");
                        Console.SetCursorPosition(40, 20);
                        Console.Write("Press");
                        Console.ForegroundColor = ConsoleColor.Magenta;
                        Console.Write(" \"ENTER\" ");
                        Console.ForegroundColor = ConsoleColor.Gray;
                        Console.Write(" to exit ");
                        Console.ReadLine();
                        break;
                    default:
                        Console.SetCursorPosition(40, 15);
                        Console.ForegroundColor = ConsoleColor.Red;
                        Console.Write("Invalid input");
                        break;
                }

            } while (userInput != 11); //The menu will keep showing if the user makes a choice that is not between numbers 1-9.
        }
        /// <summary>
        /// Main menu that contains all the functions below and switch case.
        /// </summary>
        /// <returns></returns>
        public int DisplayMenu()
        {
            Console.Clear();
            Console.ForegroundColor = ConsoleColor.White;
            Console.SetCursorPosition(32, 5);
            Console.ForegroundColor = ConsoleColor.White;
            Console.WriteLine(" OLD TIMES SQUARE PARKING GARAGE SYSTEM ");
            Console.SetCursorPosition(30, 6);
            Console.WriteLine("----------------------------------------------");
            Console.SetCursorPosition(55, 25);
            Console.WriteLine("System administrator:");
            Console.SetCursorPosition(55, 26);
            Console.WriteLine("Desiré Tillerås");
            Console.SetCursorPosition(55, 27);
            Console.WriteLine("Tel: 070 000 69 00");
            Console.SetCursorPosition(30, 25);
            Console.WriteLine("Address:");
            Console.SetCursorPosition(30, 26);
            Console.WriteLine("Staroměstské nám.");
            Console.SetCursorPosition(30, 27);
            Console.WriteLine("110 00 Staré Město");
            Console.SetCursorPosition(40, 9);
            Console.ForegroundColor = ConsoleColor.Blue;
            Console.WriteLine("1. New Parking");
            Console.SetCursorPosition(40, 10);
            Console.ForegroundColor = ConsoleColor.Magenta;
            Console.WriteLine("2. End Parking");
            Console.SetCursorPosition(40, 11);
            Console.ForegroundColor = ConsoleColor.Gray;
            Console.WriteLine("3. Move vehicle to new parking spot");
            Console.SetCursorPosition(40, 12);
            Console.ForegroundColor = ConsoleColor.Gray;
            Console.WriteLine("4. Find vehicle");
            Console.SetCursorPosition(40, 13);
            Console.ForegroundColor = ConsoleColor.Gray;
            Console.WriteLine("5. List all parking spots");
            Console.SetCursorPosition(40, 14);
            Console.ForegroundColor = ConsoleColor.Gray;
            Console.WriteLine("6. Optimize Motorcycle Parking"); 
            Console.SetCursorPosition(40, 15);
            Console.ForegroundColor = ConsoleColor.Gray;
            Console.WriteLine("7. Parking history");
            Console.SetCursorPosition(40, 16);
            Console.ForegroundColor = ConsoleColor.Gray;
            Console.WriteLine("8. Economy");
            Console.SetCursorPosition(40, 17);
            Console.ForegroundColor = ConsoleColor.Gray;
            Console.WriteLine("9. List of vehicles parked more than 48 h");
            Console.SetCursorPosition(40, 18);
            Console.ForegroundColor = ConsoleColor.Gray;
            Console.WriteLine("10. Visualize");
            Console.SetCursorPosition(40, 19);
            Console.ForegroundColor = ConsoleColor.Magenta;
            Console.WriteLine("11. Exit");
            Console.SetCursorPosition(60, 21);
            Console.ForegroundColor = ConsoleColor.White;
            Console.Write("|");
            Console.SetCursorPosition(40, 21);
            Console.ForegroundColor = ConsoleColor.White;
            Console.Write("|   Enter choice: ");

            Console.ForegroundColor = ConsoleColor.White;

            var result = ReadInt();
            return result;
        }
        public int ReadInt()
        {
            int integer;
            while (!int.TryParse(Console.ReadLine(), out integer))
            {
                Console.SetCursorPosition(25, 22);
                Console.Write("Invalid input. You have to use a number. Try again: ");
            }
            return integer;
        }
    }
}
