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

       (S, DecTime, DecLine)=Declination(DaysDeclination,RateDeclination)



        @series begin
            seriestype := :path
            linewidth := 5
            seriescolor := :red
            lab := "Di = $(round(S.Di*365/12,digits=2)) Monthly // $(round(S.Di*365,digits=2)) Yearly"
        DecTime, DecLine
        end

        if Forecast!=false
            ForecastTime=DaysDeclination[end]:Dates.Month(1):DaysDeclination[end]+Dates.Month(Mforecast)
            ForecastLine=DeclinationForecast(S,ForecastTime)
            Np=(ForecastLine[1]-ForecastLine[end])/(-S.Di*1000)

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

end
