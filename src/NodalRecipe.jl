@userplot gasnodal

@recipe function f(h::gasnodal;
                        ns=10,              #IprOptions
                        dis=2.99, Tss=80, ∇Ts=1, ϵs=0.0006, Dns=50, tols=0.05, sgs=0.6, Incs=0)

    pr,J, Depth,Thp,GasPVT=h.args

    pres, Qrate, legI=GasInflow(pr,J,GasPVT,n=ns)

    DepthRange, Qrange, Pwf, legO, P=GasOutflow(Depth,Thp,GasPVT, Qrate; di=dis, Ts=Tss, ∇T=∇Ts, ϵ=ϵs, Dn=Dns, tol=tols, sg=sgs, Inc=Incs)

    difabs=abs.(pres.-Pwf')
    dif=pres.-Pwf'
    j=argmin(difabs)
    i=j[1]
    v=pres[i]-Pwf[1]

    op_l=0.0
    op_p=0.0


    if v>0
        op_l=((Qrate[i]-Qrate[i-1])/(dif[i]-dif[i-1]))*(-dif[i-1])+Qrate[i-1]
        op_p=((pres[i]-pres[i-1])/(dif[i]-dif[i-1]))*(-dif[i-1])+pres[i-1]
    elseif v<0
        op_l=((Qrate[i+1]-Qrate[i])/(dif[i+1]-dif[i]))*(-dif[i])+Qrate[i]
        op_p=((pres[i+1,1]-pres[i,1])/(dif[i+1,1]-dif[i,1]))*(-dif[i,1])+pres[i,1]
    end
    println("Pressure $op_p , rate $op_l")
    le=vcat(legI,legO,"Operatiion Point")
    legend := :bottomleft
    label := le

    @series begin
        seriestype := :path

        Qrate, pres
    end

    @series begin
        seriestype := :path

        Qrange, Pwf'
    end

    @series begin
        seriestype := :scatter
        series_annotations := map(x->Plots.text(x ,:left,:top,8),[" "," Pressure = $(round(op_p,digits=1)) psi \n Rate = $(round(op_l,digits=1)) Mscfd \n DrawDown = $(round(pr-op_p,digits=1)) psi"])
        [0, op_l], [0,op_p]
    end
end


@userplot oilnodal

@recipe function f(h::oilnodal;
                        ns=10, Pbs=0,              #IprOptions
                        ϵs=0.0006, Tss=80, ∇Ts=1, GORs=false, dis=2.99, Dns=50, tols=0.05, sgs=0.6)   #Vfp Options

    pr,J, Depth,Thp,Bsw,OilPVT,GasPVT,WaterPVT=h.args

    pres, Qrate, legI=OilInflow(pr,J,pb=Pbs,n=ns)

    DepthRange, Qrange, Pwf, legO, P=OilOutflowSen(Depth,Thp,Bsw,OilPVT,GasPVT,WaterPVT, Qrate;ϵ=ϵs, Ts=Tss, ∇T=∇Ts, GOR=GORs, di=dis,  Dn=Dns, tol=tols, sg=sgs)

    difabs=abs.(pres.-Pwf')
    dif=pres.-Pwf'
    j=argmin(difabs)
    i=j[1]
    v=pres[i]-Pwf[1]

    op_l=0.0
    op_p=0.0


    if v>0
        op_l=((Qrate[i]-Qrate[i-1])/(dif[i]-dif[i-1]))*(-dif[i-1])+Qrate[i-1]
        op_p=((pres[i]-pres[i-1])/(dif[i]-dif[i-1]))*(-dif[i-1])+pres[i-1]
    elseif v<0
        op_l=((Qrate[i+1]-Qrate[i])/(dif[i+1]-dif[i]))*(-dif[i])+Qrate[i]
        op_p=((pres[i+1,1]-pres[i,1])/(dif[i+1,1]-dif[i,1]))*(-dif[i,1])+pres[i,1]
    end
    println("Pressure $op_p , rate $op_l")
    le=vcat(legI,legO,"Operation Point")
    legend := :bottomleft
    label := le
    xformatter := :plain
    @series begin
        seriestype := :path

        Qrate, pres
    end

    @series begin
        seriestype := :path

        Qrange, Pwf'
    end

    @series begin
        seriestype := :scatter
        series_annotations := map(x->Plots.text(x ,:left,:top,8),[" "," Pressure = $(round(op_p,digits=1)) psi \n Rate = $(round(op_l,digits=1)) bbl/d \n DrawDown = $(round(pr-op_p,digits=1)) psi"])
        [0, op_l], [0,op_p]
    end
end
