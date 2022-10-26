select *
from dailyActivity

select*
from sleepDay

--Looking at average distance
select AVG(VeryActiveDistance) as avgVeryActiveDistance,Avg(ModeratelyActiveDistance) as avgModeratelyActiveDistance, AVG(LightActiveDistance) as avgLightActiveDistance
from dailyActivity

--Looking at average minutes
select AVG(VeryActiveMinutes) as avgVeryActiveMinutes,Avg(FairlyActiveMinutes) as avgModeratelyActiveMinutes, AVG(LightlyActiveMinutes) as avgLightActiveMinutes, avg(sedentaryMinutes) as avgSedentaryMinutes
from dailyActivity

--Add day_of_week column to a table
alter table dailyActivity
add day_of_week nvarchar(20)

update dailyActivity
set day_of_week = datepart(WEEKDAY,ActivityDate)

update dailyActivity
set day_of_week = 
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
from dailyActivity

--Looking at average distance, avg step, avg calories by day of week
select day_of_week, avg(TotalDistance) as avgDistance, avg(TotalSteps) as avgStep, avg(Calories) as avgCalories,
avg(SedentaryMinutes) as avgSentaryMinutes
from dailyActivity
group by day_of_week

--Outer Join dailyActivity table with SleepDay table and copy this to a spreadsheet for visualization in Tableau

SELECT        dailyActivity.Id, dailyActivity.ActivityDate, sleepDay.SleepDay,dailyActivity.day_of_week,dailyActivity.TotalSteps, dailyActivity.TotalDistance, dailyActivity.VeryActiveDistance, dailyActivity.ModeratelyActiveDistance, 
                         dailyActivity.LightActiveDistance, dailyActivity.VeryActiveMinutes, dailyActivity.FairlyActiveMinutes, dailyActivity.LightlyActiveMinutes,dailyActivity.SedentaryMinutes, dailyActivity.Calories, 
                         sleepDay.TotalMinutesAsleep, sleepDay.TotalTimeInBed
FROM            dailyActivity LEFT JOIN
                         sleepDay ON dailyActivity.Id = sleepDay.Id AND dailyActivity.ActivityDate = sleepDay.SleepDay

--Join hourlyCalories with hourlyIntensities 

select hourlyCalories.Id, hourlyCalories.ActivityHour , calories,TotalIntensity,AverageIntensity
from   hourlyCalories INNER JOIN
      hourlyIntensities on hourlyCalories.Id = hourlyIntensities.Id AND hourlyCalories.ActivityHour = hourlyIntensities.ActivityHour

 --create a table for HourlyCalories and HourlyIntensity inner join

Create table HourlyCaloriesIntensity
(Id nvarchar(50),
ActivityHour datetime,
calories numeric(18,0),
TotalIntensity numeric (18,0),
AverageIntensity decimal(4,3))

Insert into HourlyCaloriesIntensity 
select hourlyCalories.Id, hourlyCalories.ActivityHour , calories,TotalIntensity,AverageIntensity
from   hourlyCalories INNER JOIN
       hourlyIntensities on hourlyCalories.Id = hourlyIntensities.Id AND hourlyCalories.ActivityHour = hourlyIntensities.ActivityHour

select *
from HourlyCaloriesIntensity

--extract time from ActivityHour column and create a new column 

alter table HourlyCaloriesIntensity 
add time time

update HourlyCaloriesIntensity
set time= convert (varchar(20), cast (ActivityHour as time), 108)

--copy the following table and paste into a spreadsheet for further visualization
select time,avg(calories) as avgCalories, sum(TotalIntensity) as TotalIntensity, avg(averageIntensity) as avgIntensity
from HourlyCaloriesIntensity
Group by time
order by time