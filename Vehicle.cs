using System;
using System.Collections.Generic;
using System.Text;

namespace HemtentaDesireDatabaserPragueParking
{
    public class Vehicle
    {
        private string regnr;
        private DateTime? arrivalTime;
        private DateTime? departureTime;
        private decimal? pricePaid;
        private int? vehicleType;
        private int? parkingSpotNum;        

        public string Regnr { get => regnr; }
        public DateTime? ArrivalTime { get => arrivalTime; set => arrivalTime = value; }
        public DateTime? DepartureTime { get => departureTime; set => departureTime = value; }
        public decimal? PricePaid { get => pricePaid; set => pricePaid = value; }
        public int? VehicleType { get => vehicleType; set => vehicleType = value; }
        public int? ParkingSpotNum { get => parkingSpotNum; set => parkingSpotNum = value; }        

        public Vehicle(string regnr, DateTime? arrivalTime = null, DateTime? departureTime = null,
                       decimal? pricePaid = null, int? vehicleType = null, int? parkingSpotNum = null)
        {
            this.regnr = regnr;
            this.arrivalTime = arrivalTime;
            this.departureTime = departureTime;
            this.pricePaid = pricePaid;
            this.vehicleType = vehicleType;
            this.parkingSpotNum = parkingSpotNum;
        }
    }
}
