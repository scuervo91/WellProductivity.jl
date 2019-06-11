@userplot vfpoil

@recipe function f(h::vfpoil;ϵs=0.0006, Tss=80, ∇Ts=1, GORs=false, dis=2.99, Qns=10, Dns=50, tols=0.05, sgs=0.6)

        Depth,Thp,Bsw,OilPVT,GasPVT,WaterPVT, Qmax=h.args

DepthRange, Qrange, Pwf, l=OilOutflowSen(Depth,Thp,Bsw,OilPVT,GasPVT,WaterPVT, Qmax;ϵ=ϵs, Ts=Tss, ∇T=∇Ts, GOR=GORs, di=dis, Qn=Qns, Dn=Dns, tol=tols, sg=sgs)


    xlabel --> "Rate [bbl/d]"
    ylabel --> "Pwf [psi]"
    xformatter --> :plain
    label --> l
    @series begin
        seriestype := :path
        Qrange, Pwf'
    end
    end
