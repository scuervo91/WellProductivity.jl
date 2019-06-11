function GasInflow(pr,J,GasPVT;n=10)

    #Calculate PseudoPressure
    GasPVT.Ps=map((x,y,z)->2*x/(y*z),GasPVT.P,GasPVT.Mug,GasPVT.Z)

    #Integral Matrix
    Integral = DataFrame()

    #Traslate Pressure to Integrate Matrix
    Integral.P= GasPVT.P[2:end]

    #Pressure Differences
    Integral.DiffP=diff(GasPVT.P)

    #PseudoPressure Average
    Integral.AvgPs=0.0
    for i=1:size(GasPVT,1)-1
        Integral.AvgPs[i]=(GasPVT.PseudoP[i+1]+GasPVT.PseudoP[i])/2
    end
    Integral.Cum=accumulate(+, Integral.DiffP.*Integral.AvgPs)

    #Interpolation Integral
    mp=LinearInterpolation(Integral.P.*1, Integral.Cum.*1)

    #IPR Estimation

    pres=zeros(n,size(pr,1))
    Qg=zeros(n,size(pr,1)*size(J,1))

    count=0
    for p=1:size(pr,1)

        pres[:,p]=range(14.7,stop=pr[p],length=n)

        for j=1:size(J,1)
    count=count+1
      Qg[:,count]=map(pwf->J[j]*(mp(pr[p])-mp(pwf)),pres[:,p])

        end
    end

    return pres, Qg

end #End Function
