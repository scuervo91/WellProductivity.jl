@userplot OilRate

@recipe function f(h::OilRate; Dlim=false, mrange=6, dft="u yy",
                                WellName=" ", Liquid=false,
                                Dec=false, Drange=false,
                                Forecast=false, Mforecast=12)
                  legend --> false
                  title := "$WellName"
                  ylabel := "Rate [bbl/d]"


    if length(h.args)==2
        x, y = h.args
    elseif length(h.args)==3
        x, y, z = h.args
    end

    Forecast!=false ? f=Dates.Month(Mforecast) : f=Dates.Month(1)

    if Dlim==false
        r = x[1]:Dates.Month(mrange):x[end]+f
        d = Dates.format.(r,dft)
    else
        r = Dlim[1]:Dates.Month(mrange):Dlim[2]+f
        d = Dates.format.(r,dft)
        xlim := (Dates.value(Dlim[1]),Dates.value(Dlim[2]))
    end
        xticks := (r,d)

    #Oil rate Series
    @series begin
        seriestype := :path
        linewidth := 3
        seriescolor := :green
        label := "Oil Rate [bbl/d]"
        x, y
        end

    if Liquid==true
    #Liquid rate Series
    @series begin
        seriestype := :path
        linewidth := 1
        seriescolor := RGB(0.5, 0.5, 0.5)
        subplot := 1
        label := "Liquid Rate [bbl/d]"
        x, z
        end
    end
    
        if Dec==true
        if Drange==false
            DaysDeclination=x
            RateDeclination=y
        else
            DaysDeclination=x[(x.>=Drange[1]) .& (x.<=Drange[2])]
            RateDeclination=y[(x.>=Drange[1]) .& (x.<=Drange[2])]
        end

       (S, DecLine)=Declination(DaysDeclination,RateDeclination)


        @series begin
            seriestype := :path
            linewidth := 5
            seriescolor := :red
        DaysDeclination, DecLine
        end

        if Forecast!=false
            ForecastTime=DaysDeclination[end]:Dates.Month(1):DaysDeclination[end]+Dates.Month(Mforecast)
            ForecastLine=DeclinationForecast(S,ForecastTime)

        @series begin
            seriestype := :path
            linestyle := :dash
            linewidth := 1
            seriescolor := :red
        ForecastTime, ForecastLine
        end

        end


    end

end
