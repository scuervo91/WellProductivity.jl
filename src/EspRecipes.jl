@userplot espplott

@recipe function f(h::espplott;
        n=15, stg=false, fq=false, VisCor=false,μ=1)
     Esp, x = h.args

   CapRange, Head, EspPower, η, Cone, Stages, Freq, CapCorrected, HeadCorrected, ηCorrected, PowerCorrected = EspPerformance(Esp,ns=n,stgs=stg, fqs=fq, VisCors=VisCor, μs=μ)


    xformatter := :plain
    legend := :topright
    layout := (3,1)
    link := :x
    size := (800,600)
    legendfontsize := 6
    xlim:=(0,Esp.AOF)
    if VisCor==true
        @series begin
            seriestype := :path
            linestyle := :dash
            linewidth := 1
            linecolor := :darkblue
            marker := :hexagon
            markercolor := :blue
            subplot :=1
            label := "Head Corrected"
            CapCorrected, HeadCorrected
        end

        @series begin
            seriestype := :path
            linestyle := :dash
            linewidth := 1
            linecolor := :darkblue
            marker := :hexagon
            markercolor := :black
            subplot :=2
            label := "Eff Corrected"
            CapCorrected, ηCorrected
        end
        @series begin
            seriestype := :path
            linestyle := :dash
            linewidth := 1
            linecolor := :darkgreen
            marker := :hexagon
            markercolor := :green
            subplot :=3
            label := "Power Corrected"
            CapCorrected, PowerCorrected
        end

    end
    @series begin
        seriestype := :path
        linewidth := 2
        linecolor := :blue
        subplot :=1
        label := "Head"
        CapRange, Head
    end

    @series begin
        seriestype := :scatter
        subplot :=1
        label :="Min/Max"
        Cone.caps, Cone.heads
    end

         @series begin
        seriestype := :vline
        linewidth := 1
        linestyle := :dash
        linecolor := :red
        subplot :=1
        label := "Efficiency Range"
        ylabel := "Head [ft]"
        title := " ESP Performance Curve \n $(Esp.Manufacter) Series $(Esp.Series) Model $(Esp.Model) \n at $(Freq) Hz and $(Stages) Stages"
        titlefontsize := 8
        Cone.caps
    end


    @series begin
        seriestype := :path
        linewidth := 1
        linecolor := :black
        subplot :=2
        label := "Efficiency"
         ylabel := "Efficiency [%]"
        CapRange, η
    end


 #
      @series begin
        seriestype := :path
        link := :x
        linewidth := 2
        linecolor := :darkgreen
        label:= "Horse Power"
        subplot :=3
        xlabel := "Liquid Rate [bbl/d]"
         ylabel := "Horse Power [hp]"
        CapRange,EspPower
    end

end

@userplot espmatch

@recipe function f(h::espmatch;
                            pip=false, n=15, rfq=30:5:60, stg=false, fq=false,
                            pbs=0,
                            ϵs=0.0006, Tss=80, ∇Ts=1, GORs=false, dis=2.99, Dns=50, tols=0.05, sgs=0.6)

        Esp, Pr, J, OilPVT, GasPVT, WaterPVT, Thp, PumpDepth, PerfDepth, Ql, Bsw=h.args

    CapRange,Head,CapMin,CapMax,HeadMin,HeadMax, CapCustom, HeadCustom=EspTornado(Esp; ns=n, rfqs=rfq, stgs=stg, fqs=fq)

        ΔD=PerfDepth-PumpDepth

        ρo=LinearInterpolation(OilPVT.P.*1, OilPVT.Rho.*1)
        ρw=LinearInterpolation(WaterPVT.P.*1, WaterPVT.Rho.*1)
        ρl= (ρo(Pr)*(1-Bsw)+ρw(Pr)*Bsw)
        ∇P=ρl*(0.433/62.4)
        if pip == false
          Pipr, Qipr, leg=OilInflow(Pr,J,pb=pbs,n=20)
          Pinter=LinearInterpolation(reverse(vec(Qipr)),reverse(vec(Pipr)))      # Interpolation accepts increasing order and vectors only
          pwf=Pinter(Ql)
          pip=pwf-∇P*ΔD
        end


        println("Pump Intake Pressure $(round(pip, digits=1)) psi")
        DepthRange, Qrange, Pd, legO, P=OilOutflowSen(PumpDepth,Thp,Bsw,OilPVT,GasPVT,WaterPVT, CapCustom;ϵ=ϵs, Ts=Tss, ∇T=∇Ts, GOR=GORs, di=dis,  Dn=Dns, tol=tols, sg=sgs)

        HeadMatch=(Pd'.-pip)./∇P

       xlabel := "Liquid Rate [bbl/d]"
       ylabel := "Head [ft]"
       xformatter := :plain

        @series begin
            seriestype := :path
            linecolor := :black
            linewidth := 1
            label := map(x->"$x Hz",rfq)
            CapRange,Head
        end

        @series begin
            seriestype := :path
            linecolor := :darkgreen
            linestyle := :dash
            linewidth := 3
            label := "At $fq Hz"
            CapCustom, HeadCustom
        end

        @series begin
            seriestype := :path
            linecolor := :red
            linewidth := 2
            linestyle := :dash
            label := "Min/Max"
            [CapMin, CapMax],[HeadMin, HeadMax]
        end

        @series begin
                seriestype := :path
                linecolor := :green
                linewidth := 2
                label := "ESP Match"
                CapCustom, HeadMatch
        end

    end
