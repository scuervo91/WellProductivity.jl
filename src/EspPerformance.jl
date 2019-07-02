function EspPerformance(EspPump; ns=15, stgs=false, fqs=false)

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

    return CapRange, Head, EspPower, η, Cone, Stages, Freq

end
