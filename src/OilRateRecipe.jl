```
oilrate(args...)  -->Plot

Recipe to Plot the Oil, Liquid Production.
Optionally you can make decline curve analysis, estimate a Forecast to either specific time or economic limit

Exponential Decline curve equation, Np estimation, Time to Economic Limit
`` { Q }_{ t }={ Q }_{ i }{ e }^{ -{ D }_{ i }t }``
``Np=\int _{ { t }_{ i } }^{ { t }_{ f } }{ { Q }_{ i }{ e }^{ -{ D }_{ i }t }dt }``
``Np=\frac { { -Q }_{ i } }{ { { D }_{ i } } } \left[ { e }^{ { -D }_{ i }{ t }_{ f } }-{ e }^{ { -D }_{ i }{ t }_{ i } } \right] ``
``{ t }_{ L }=\frac { -Ln\left( \frac { { Q }_{ L } }{ { Q }_{ i } }  \right)  }{ D } ``

The next table show the list of variables allowed:

|PropertyName|Args|Default|Input|Description
|---|---|---|---|---|
|Date|Mandatory|--|Array{Date,1}| Array of dates|
|OilRate|Mandatory|--|Array{Number,1}| Array of Rates|
|LiquidRate|Optional|--|Array{Number,1}| Array of Rates|
|Dlim|Optional|Dlim=false|Dlim=[Date(y,m,d)]|Initial Date to plot|
|mrange|Optional|mrange=false|mrange=number| Time interval in months to set xticks|
|dtf|Optional|dft="u yy"|dtf=DateFormat|Date format of xticks
|Liquid|Optional|Liquid=false|Liquid=Bool|If liquid array provided, choose if plot Liquid Rate|
|Dec|Optional|Dec=false|Dec=Bool|Set decline curve analysis to desired interval |
|Drange|Optional|Drange=false|Drange=[Date(y,m,d) Date(y,m,d)]|Decline curve range to fit|
|Forecast|Optional|Forecast=false|Forecast=Bool|Set to plot forecast estimation|
|Mforecast|Optional|Mforecast=12|Mforcast=Number|Set number of months to forecast <br> from last date of Declination range|
|EconLimit|Optional|EconLimit=false|EconLimit=Number|Set the Economic Limit to estimate time to forecast
|Ad|Optional|Ad=true|Ad=Bool|Set if apply Anormaly detection to decline curve|
```
@userplot OilRate

@recipe function f(h::OilRate; Dlim=false, mrange=6, dft="u yy",
                                Liquid=false,
                                Dec=false, Drange=false,
                                Forecast=false, Mforecast=12,
                                Ad=true, EconLimit=false)
                  legend --> false
                  ylabel := "Rate [bbl/d]"
                  

    if length(h.args)==2
        x, y = h.args
    elseif length(h.args)==3
        x, y, z = h.args
    end

    if Dec==true
        if Drange==false
            DaysDeclination=x
            RateDeclination=y
        else
            DaysDeclination=x[(x.>=Drange[1]) .& (x.<=Drange[2])]
            RateDeclination=y[(x.>=Drange[1]) .& (x.<=Drange[2])]
        end

        (S, DecTime, DecLine)=Declination(DaysDeclination,RateDeclination, AD=Ad)

        if Forecast==true
            if EconLimit!=false
                MforecastEL=round(Int,((log(EconLimit/S.Qi)/S.Di)/30.42))
                ForecastTime=DaysDeclination[end]:Dates.Month(1):DaysDeclination[1]+Dates.Month(MforecastEL)

            else
                ForecastTime=DaysDeclination[end]:Dates.Month(1):DaysDeclination[end]+Dates.Month(Mforecast)
            end
            ForecastLine=DeclinationForecast(S,ForecastTime)
            Np=(ForecastLine[1]-ForecastLine[end])/(-S.Di*1000)
            f=ForecastTime[end]+Dates.Month(1)
        else
            f=x[end]+Dates.Month(1)
        end
    end



    if Dlim==false
        r = x[1]:Dates.Month(mrange):f
        d = Dates.format.(r,dft)
    else
        r = Dlim[1]:Dates.Month(mrange):f
        d = Dates.format.(r,dft)
        xlim := (Dates.value(Dlim[1]),Dates.value(f))
    end
        xticks := (r,d)

    #Oil rate Series
    @series begin
        seriestype := :path
        linewidth := 3
        seriescolor --> :green

        label := " $WellName Oil Rate [bbl/d]"
        x, y
        end

    if Liquid==true
    #Liquid rate Series
    @series begin
        seriestype := :path
        linewidth := 1
        seriescolor := RGB(0.5, 0.5, 0.5)
        subplot := 1
        label := " $WellName Liquid Rate [bbl/d]"
        x, z
        end
    end

    if Dec==true
        @series begin
            seriestype := :path
            linewidth := 3
            seriescolor := :red
            lab := "Di = $(round(S.Di*365/12,digits=2)) Monthly // $(round(S.Di*365,digits=2)) Annually"
            DecTime, DecLine
        end
    end

        if Forecast==true

        @series begin
            seriestype := :path
            linestyle := :dash
            linewidth := 1
            seriescolor := :red
                lab := "$(Dates.format(ForecastTime[1],dft))--> $(Dates.format(ForecastTime[end],dft))// Np= $(round(Np,digits=1)) Mbbl))"
                ForecastTime, ForecastLine
        end

        end
end
