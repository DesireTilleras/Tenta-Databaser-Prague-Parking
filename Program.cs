using System;
using System.Data;
using System.Data.SqlClient;

namespace HemtentaDesireDatabaserPragueParking
{
    class Program
    {
        static void Main(string[] args)
        {
            Menu menu = new Menu();
            menu.MainMenu();
        }
    }
}
