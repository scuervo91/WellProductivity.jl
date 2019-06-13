@userplot iproil

@recipe function f(h::iproil;
                    Pb=0,N=15)

    Pr, J=h.args

    p, q, l=OilInflow(Pr,J,pb=Pb,n=N)

    xlabel --> "Rate [bbl/d]"
    ylabel --> "Pwf [psi]"
    label --> l

    @series begin
        seriestype := :path
        linecolor -> :black
        linewidth -> 3
        xformatter := :plain
        q, p
    end

end
@userplot iprgas

@recipe function f(h::iprgas;
                    N=15)

    Pr, J, PVT=h.args

    p, q, l=GasInflow(Pr,J,PVT,n=N)

    xlabel --> "Gas rate [Mscf/d]"
    ylabel := "Pwf [psi]"
    label --> l
    linecolor --> :red
    xformatter := :plain
    @series begin
        seriestype := :path
        q, p
    end

end
