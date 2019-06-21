# WellProductivity

## Introduction

This package is being designed among others to provide Petroleum Engineering tools in a modern programming language. This package is part of the project 7G which  proposes to make basic but powerful engineering software packages that cover the main topics of the Oil and Gas development phases which could be applied to any case study by suitable engineers.

There are five topics in which the project is going to be focused on:

<br>-Geoscience* (Current Package)
<br>-Reservoir
<br>-Production
<br>-Economics
<br>-Integration

<br> The package will always be in permanent development and open to suggestions to enhance the program. As the code has been written so far by a code enthusiastic Petroleum Engineer I hope to learn as much as possible to get better and usefull programs.

## WellProductivity.jl Description  
WellProductivity.jl is a package to perform well productivity analysis (Oil and Gas) such as Decline curve analysis,  
artificial lift system design and performance.

Given some timeseries data of well production you can estimate the decline rate as well as the forecast to either a given time or economic limit. The Recipe Function include an Anomally Detection Algorithm to detect those points which are not represetative for the Decline Analysis, such as production stops etc...

You can visualize inflow and outflow curves, operation points and some sensibitities that affect the performance of the curves.   

### Tutorial  

Load Packages requiered
```julia
using SQLite
using CSV
using Plots
using Dates
using Interact
using DataFrames
using RecipesBase
using Statistics
using Distributions
using WellProductivity
```  
Load a production database to the Workspace, in this case a SQLite Database is used.

```julia
db=SQLite.DB("ProdDataBase.db")
```

Query the desired data. By using SQL language for Database, liquid production and Oil production of a well is extracted and the last 10 rows are displayed.

```julia  
p=DataFrame(SQLite.Query(db,"SELECT date(Date) as Date, LiquidRate, OilRate
                    FROM production
                    WHERE WellId=7"))
p.Datee=Date.(p.Date, Dates.DateFormat("yyyy-mm-dd"))

first(p,10)
```
<img src="WellProductivity_EX1.PNG"><br>

You can use the ```oilrate``` recipe to plot the production Oil production data and optionally the liquid.

```julia
l=[Date(2019,1,1), Date(2019,5,27)]

p1=oilrate(p.Datee, p.OilRate, Dlim=l, legend=true)
p2=oilrate(p.Datee, p.OilRate,p.LiquidRate, Dlim=l, mrange=2, Liquid=true,legend=true, ylimit=(0,500))
plot(p1,p2, layout=(2,1))
```
<img src="WellProductivity_EX2.PNG"><br>

You can perform a decline analysis in the same recipe by adding the required keywords.  
In the example is plotted the same data comparing the the Anomaly Detection algorthm feature in which filters the data that is most likely not to be representative.  

```julia
l=[Date(2019,1,1), Date(2019,5,27)]
r=[Date(2019,2,1), Date(2019,5,27)]
p1=oilrate(p.Datee, p.OilRate, Dlim=l, ylim=(0,250), mrange=1, Dec=true, Drange=r, Ad=true)
p2=oilrate(p.Datee, p.OilRate, Dlim=l, ylim=(0,250), mrange=1, Dec=true, Drange=r, Ad=false )
plot(p1,p2, layout=(2,1), size=(800,600), title=["Anomaly Detection Declination" "Conventional Declination"])
```
<img src="WellProductivity_EX3.PNG"><br>

You can add a forecast by setting ```forecast=true``` for a given months.

```julia
l=[Date(2019,1,1), Date(2019,12,31)]
r=[Date(2019,2,1), Date(2019,5,27)]
p1=oilrate(p.Datee, p.OilRate, Dlim=l, ylim=(0,250), mrange=2, Dec=true, Drange=r,Forecast=true, Ad=true, Mforecast=5, legend=true)
p2=oilrate(p.Datee, p.OilRate, Dlim=l, ylim=(0,250), mrange=2, Dec=true, Drange=r,Forecast=true, Ad=false, legend=true,Mforecast=5)
plot(p1,p2, layout=(2,1), size=(800,600), title=["Forecast Anomaly Detection Declination" "Forecast Conventional Declination"])
```
<img src="WellProductivity_EX4.PNG"><br>

You can also stop the forecast by the Economic Limit

```julia
l=[Date(2019,1,1), Date(2019,12,31)]
r=[Date(2019,2,1), Date(2019,5,27)]
p2=oilrate(p.Datee, p.OilRate, p.LiquidRate, Dlim=l, ylim=(0,300), mrange=3, Dec=true, Drange=r,Forecast=true, Ad=true, legend=true, EconLimit=20)
p1=oilrate(p.Datee, p.OilRate, p.LiquidRate, Dlim=l, ylim=(0,300), mrange=3, Dec=true, Drange=r,Forecast=true, Ad=true, legend=true, Mforecast=12)
plot(p1,p2, layout=(2,1), title=["Economic Limit Forecast" "Fixed Time Forecast"])
```
<img src="WellProductivity_EX5.PNG"><br>

## Well Productivity Analysis - Inflow & Outflow curves

Oil and gas wells productivity index and vertical flow performance curves can be calculated to establish operation points. sensibitities can be applied in order to visualize the impact on production under risk operations.

### IPR

Oil IPR can be plotted with the ```iproil``` recipe by giving Reservoir Pressure and PI. Optionally the bubble point can be set in order to apply the Vogel Correlation.

For Pwf>Pb
`` Q=J\quad \Delta P ``

for Pwf<= Pb

`` Q={ Q }_{ max }\left[ 1-0.2\left( \frac { Pwf }{ Pb }  \right) -0.8{ \left( \frac { Pwf }{ Pb }  \right)  }^{ 2 } \right]  ``

```julia
l=@layout[a b ; c]
p1=iproil(1300,2.5,Pb=600, title="Vogel Correlation Pwf<Pb")
p2=iproil(1300,2.5, title="Linear Productivity Index")
p3=iproil([3400, 3600],[10, 15],Pb=1000, title="Sensibilities on Pressure and PI")
plot(p1,p2,p3, layout=l, size=(800,600), legendfontsize=6)
```
<img src="WellProductivity_EX6.PNG"><br>

Gas IPR can be plotted with the ```iprgas``` recipe by giving Reservoir Pressure, Pi and a tabulated Gas PVT. The recipe does not approximate the solution according with the pressure regions, instead it calculates the Real-Gas Pseudopressure in the range of the iprgas

`` { Q }_{ g }=J\quad \left( { \psi  }_{ r }-{ \psi  }_{ w } \right)  ``

Where  

`` \psi =m(p)=\int _{ 0 }^{ p }{ \frac { 2p }{ { \mu  }_{ g }\quad Z }  } dp ``

```julia
GasPVT=CSV.read("GasPVT.csv")
first(GasPVT,10)
```
<img src="WellProductivity_EX7.PNG"><br>


You also can apply some sensibilities to the reservoir pressure and Pi of the gas.
```julia
iprgas([1100,1200],[0.9e-4, 1.4e-4],GasPVT, legendfontsize=6)
```
<img src="WellProductivity_EX8.PNG"><br>

### VFP

The Oil vertical Flow Performance curve is calculated through The Modified Hagedorn and Brown Method.

```julia
p1=vfpoil(5500,[50,70],0.5,OilPVT,GasPVT,WaterPVT, 1500, dis=2.99, title="Thp Sensibility")
p2=vfpoil(5500,50,[0.5,0.7],OilPVT,GasPVT,WaterPVT, 1500, dis=2.99,title="Bsw Sensibility")
p3=vfpoil(5500,50,0.7,OilPVT,GasPVT,WaterPVT, 1500, dis=[2.99,3.5],title="Tubing Diameter Sensibility")
p4=vfpoil(5500,50,0.7,OilPVT,GasPVT,WaterPVT, 1500, dis=2.99,GORs=[300,600],title="GOR sensibility")

plot(p1,p2,p3,p4, layout=4, legendfontsize=6, size=(800,600))
```

<img src="WellProductivity_EX9.PNG"><br>

You could plot the IPR and VFP in a single plotted

```julia
iproil([1000, 1200],[1.5,2],Pb=2100)
vfpoil!(5500,[50,70],0.5,OilPVT,GasPVT,WaterPVT, 1500, legend=false)
```
<img src="WellProductivity_EX10.PNG"><br>
