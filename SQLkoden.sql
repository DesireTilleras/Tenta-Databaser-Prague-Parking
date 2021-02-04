
DROP VIEW DisplayHistory

CREATE VIEW DisplayHistory
AS
SELECT RegNumber, CheckInTime, CheckOutTime, CAST(TotalCost AS INT) as TotalCost
FROM ParkingHistory

ALTER TABLE VehicleTypes
DROP COLUMN Size;