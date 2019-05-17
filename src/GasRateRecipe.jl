@userplot GasRate

@recipe function f(h::GasRate; Dlim=false, mrange=6, dft="u yy", WellName=" ")
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
        linestyle := :solid
        linewidth := 2
        seriescolor := RGB(0.6, 0.0, 0.0)
        ylabel := "Gas Rate [Mscfd]"
        xticks := (r,d)

        if Dlim!=false
        xlim := (Dates.value(Dlim[1]),Dates.value(Dlim[2]))
        end
        x, y
        end
end
