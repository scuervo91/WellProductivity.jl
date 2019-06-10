@userplot ipr

@recipe function f(h::ipr;
                    Pb=0,N=15)

    Pr, J=h.args

    p, q=OilInflow(Pr,J,pb=Pb,n=N)

    xlabel := "Rate [bbl/d]"
    ylabel := "Pwf [psi]"
    legend --> false

    @series begin
        seriestype := :path
        line_z := Pr'
        linecolor --> :grays
        xformatter := :plain
        q, p
    end

end
