function EspPerformance(EspPump; ns=15, stgs=false, fqs=false, VisCors=false, μs=1)

    stgs==false ? Stages=EspPump.RefStg : Stages=stgs
    fqs==false ? Freq=EspPump.RefFreq : Freq=fqs

    # ESP Head Polynomial Construction
    HeadCoef=convert(Vector,EspPump[[:H0,:H1,:H2,:H3,:H4,:H5,:H6]]).*1   # Extract Polynomial Head Coefficient
    HeadEq=Poly(HeadCoef)                                                  # Make the Polynomial equation

    # ESP Power Polynomial Construction
    PowCoef=convert(Vector,EspPump[[:P0,:P1,:P2,:P3,:P4,:P5,:P6]]).*1  #Extract Polynomial Head Coefficient
    PowEq=Poly(PowCoef)                                                  # Make the Polynomial equation

    # ESP Head Calculations
    CapRange=range(0,stop=EspPump.AOF,length=ns).*(Freq/EspPump.RefFreq)  # Capacity Range in bbl/d
    CapRangeRef=range(0,stop=EspPump.AOF,length=ns)
    Head=HeadEq(CapRangeRef).*Stages.*(Freq/EspPump.RefFreq).^2             # Pump Head  stg at Reference Frequency
    HeadRef=HeadEq(CapRangeRef)

    CapMin=EspPump.Min.*(Freq/EspPump.RefFreq)
    CapMax=EspPump.Max.*(Freq/EspPump.RefFreq)

    HeadMin=HeadEq(EspPump.Min).*Stages.*(Freq/EspPump.RefFreq).^2
    HeadMax=HeadEq(EspPump.Max).*Stages.*(Freq/EspPump.RefFreq).^2

    #ESP Power Calculations
    EspPower=PowEq(CapRange).*Stages.*(Freq/EspPump.RefFreq).^3
    EspPowerRef=PowEq(CapRangeRef)
    HydroPower=CapRangeRef.*HeadRef.*62.4.*1.1816e-7
    η=100 .*HydroPower./EspPowerRef

    Cone=DataFrame(heads=[HeadMin,HeadMax], caps=[CapMin,CapMax])

    #Viscosity Corrections
    if VisCors==true
    Hbep=LinearInterpolation(CapRange, Head)
    EffInter=LinearInterpolation(CapRange, η)
    PowInt=LinearInterpolation(CapRange, EspPower)

    Qb=EspPump[:BEP]
    Hb=Hbep(Qb)
    y=-112.1374+6.6504*log(Hb)+12.8429*log(Qb)
    qp=exp((39.5276+26.5605*log(μs)-y)/(51.6565))
    Cq=1-4.0327e-3*qp-1.72401e-4*qp^2            #Rate correction factor
    Ceff=1-3.3075e-2*qp-2.887510e-4*qp^2           #Efficiency Corrections factor

    #Head correction factor
    Qc=[0,0.6,0.8,1,1.2,EspPump.AOF/Qb]
    Qi=Qb .* Qc

    CapCorrected=Qi.*Cq
    ηCorrected=map(x->EffInter(x).*Ceff,Qi)

    H1=[0,-3.68e-3,-4.4723e-3,-7.0076e-3,-9.01e-3,0]
    H2=[0,-4.36001e-5,-4.18e-5001,-1.41001e-5,1.31001e-5,0]
    HeadCorrected=map((x,h1,h2)->Hbep(x)*(1+h1*qp+h2*qp^2),Qi,H1,H2)
    PowerCorrected=map((x,h1,h2)->PowInt(x)*(1+h1*qp+h2*qp^2)*Cq/Ceff,Qi,H1,H2)
else
    CapCorrected=HeadCorrected=ηCorrected=PowerCorrected=zeros(6)

    end

    return CapRange, Head, EspPower, η, Cone, Stages, Freq, CapCorrected, HeadCorrected, ηCorrected, PowerCorrected

end
