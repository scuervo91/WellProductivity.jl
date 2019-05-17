@userplot OilCum

@recipe function f(h::OilCum; Dlim=false, mrange=6, dft="u yy", WellName=" ")
                  legend --> false
                  x, y = h.args

    if Dlim==false
        r = x[1]:Dates.Month(mrange):x[end]
        d = Dates.format.(r,dft)
    else
        r = Dlim[1]:Dates.Month(mrange):Dlim[2]
        d = Dates.format.(r,dft)
    end

        @series begin
        seriestype := :path
        linestyle := :dash
        linewidth := 1
        seriescolor := RGB(0.1, 0.4, 0.2)
        ylabel := "Oil Cum [Mbbl]"
        xticks := (r,d)

        if Dlim!=false
        xlim := (Dates.value(Dlim[1]),Dates.value(Dlim[2]))
        end
        x, y
        end
end
