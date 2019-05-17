@userplot OilRate

@recipe function f(h::OilRate; Dlim=false, mrange=6, dft="u yy", WellName=" ", Liquid=false)
                  legend --> false
                  title := "$WellName"
                  ylabel := "Rate [bbl/d]"


    if length(h.args)==2
        x, y = h.args
    elseif length(h.args)==3
        x, y, z = h.args
    end

    if Dlim==false
        r = x[1]:Dates.Month(mrange):x[end]
        d = Dates.format.(r,dft)
    else
        r = Dlim[1]:Dates.Month(mrange):Dlim[2]
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

end
