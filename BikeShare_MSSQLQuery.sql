--Create a new table and combine all 12 tables into a single table

create table bike_trip2021
(ride_id nvarchar(50),
rideable_type nvarchar(50),
started_at datetime,
ended_at datetime,
start_station_name nvarchar(225),
start_station_id nvarchar(50),
end_station_name nvarchar(225),
end_station_id nvarchar(50),
start_lat nvarchar(50),
start_lng nvarchar(50),
end_lat nvarchar(50),
end_lng nvarchar(50),
member_casual nvarchar(50))

Insert into bike_trip2021
select *
from dbo.[202103-divvy-tripdata]
union
select *
from dbo.[202104-divvy-tripdata]
union 
select *
from dbo.[202105-divvy-tripdata]
union 
select *
from dbo.[202106-divvy-tripdata]
union 
select *
from dbo.[202107-divvy-tripdata]
union 
select *
from dbo.[202108-divvy-tripdata]
union 
select *
from dbo.[202109-divvy-tripdata]
union 
select *
from dbo.[202110-divvy-tripdata]
union 
select *
from dbo.[202111-divvy-tripdata]
union
select *
from dbo.[202112-divvy-tripdata]
union 
select *
from dbo.[202201-divvy-tripdata]
union 
select *
from dbo.[202202-divvy-tripdata]

--Check if there is any duplicate ride_id

select count (distinct ride_id), count (ride_id)
from dbo.bike_trip2021

--Add a ride_length column to a new table

alter table dbo.bike_trip2021
add ride_length time

--Add values into ride_length column

update dbo.bike_trip2021
set ride_length = (ended_at-started_at)

--Add 'day_of_week' column to a new table

alter table dbo.bike_trip2021
add day_of_week nvarchar(1)

--Add values into 'day_of_week' column
update dbo.bike_trip2021
set day_of_week = datepart(WEEKDAY,started_at)

--Check to make sure there is no other member_casual type other than  'member' and 'casual'
select member_casual
from dbo.bike_trip2021
where member_casual not in ('member','casual')

--Caculate number of ride by each day of week
select member_casual, day_of_week,count(day_of_week) As number_of_ride
from dbo.bike_trip2021
where ended_at>started_at
group by day_of_week, member_casual
order by member_casual,day_of_week 

--Calculate the ride length in Second and add it into the table

select datediff(second,started_at,ended_at) as RideLenghtInSecond
from dbo.bike_trip2021
where ended_at > started_at

alter table dbo.bike_trip2021
add RideLenghtInSecond numeric

update dbo.bike_trip2021
set RideLenghtInSecond  = datediff(second,started_at,ended_at) 
where ended_at > started_at

--Convert day_of_week in number to text

alter table dbo.bike_trip2021
add day_of_week2 nvarchar (50)

update dbo.bike_trip2021
set day_of_week2 = 
case
when day_of_week = 1 then 'Sunday'
when day_of_week = 2 then 'Monday'
when day_of_week = 3 then 'Tuesday'
when day_of_week = 4 then 'Wednesday'
when day_of_week = 5 then 'Thursday'
when day_of_week = 6 then 'Friday'
when day_of_week = 7 then 'Saturday'
else 'Null'
end 
from dbo.bike_trip2021

--Calculate total, Mean, Min and Max of ride length for each Rider type by each day of week
--Copy this data and paste into Excel for Data visualization

select member_casual,day_of_week2, day_of_week, count (*) as #ofRide,sum(RideLenghtInSecond) As TotalRideLengthInSecond, avg(RideLenghtInSecond) As meanOfRideLength, min(RideLenghtInSecond) As minOfRideLength, max(RideLenghtInSecond) As maxOfRideLength
from dbo.bike_trip2021
where RideLenghtInSecond > 0
group by member_casual, day_of_week, day_of_week2
order by member_casual, day_of_week

--Add month_of_ride into the table
alter table dbo.bike_trip2021
add month_of_ride nvarchar(2)

update dbo.bike_trip2021
set month_of_ride = month(started_at)

--Calculate total, Mean, Min and Max of ride length for each Rider type by each month of year
--Copy this data and paste into Excel for Data visualization

select member_casual, month_of_ride,sum(RideLenghtInSecond) As TotalRideLengthInSecond,count (*) as #ofRide, avg(RideLenghtInSecond) As meanOfRideLength
from dbo.bike_trip2021
group by member_casual, month_of_ride
order by member_casual,month_of_ride

--Creat a view and extract time from the 'started_at' column
create view RideTime As
select member_casual as RiderType,day_of_week2 as day_of_week,CONVERT(VARCHAR(20),CAST(started_at AS TIME), 108) as RideTime
from dbo.bike_trip2021

select *
from RideTime

--Break Ride Time into Time of day and creat a view to hold it
Create View RideTimeOfDay As
select RiderType,day_of_week,RideTime,
case 
when RideTime between '05:00:00' and '11:59:00'  Then 'morning'
when RideTime between '12:00:00' and '15:59:00'  Then 'afternoon'
when RideTime between '16:00:00' and '18:59:00'  Then 'evening'
else 'night' end As TimeOfDay
from RideTime

select*
from RideTimeOfDay

--Copy this view to excel for visualiztion
select RiderType, day_of_week,TimeOfDay, count(TimeOfday) as numberOfRide
from RideTimeOfDay
group by RiderType,TimeOfDay,day_of_week
order by day_of_week, Ridertype,TimeOfDay