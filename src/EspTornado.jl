function EspTornado(EspPump; ns=15, rfqs=30:5:60, stgs=false, fqs=false)
    stgs==false ? Stages=EspPump.RefStg : Stages=stgs
    fqs==false ? Freq=EspPump.RefFreq : Freq=fqs

    # ESP Head Polynomial Construction
    HeadCoef=convert(Vector,EspPump[[:H0,:H1,:H2,:H3,:H4,:H5,:H6]]).*1   # Extract Polynomial Head Coefficient
    HeadEq=Poly(HeadCoef)                                                  # Make the Polynomial equation

    # ESP Power Polynomial Construction
    PowCoef=convert(Vector,EspPump[[:P0,:P1,:P2,:P3,:P4,:P5,:P6]]).*1  #Extract Polynomial Head Coefficient
    PowEq=Poly(PowCoef)                                                  # Make the Polynomial equation


    CapRangeRef=range(0,stop=EspPump.AOF,length=ns)
    HeadRef=HeadEq(CapRangeRef)

    CapRange=zeros(ns,size(rfqs,1))
    Head=zeros(ns,size(rfqs,1))
    CapMin=zeros(size(rfqs,1))
    CapMax=zeros(size(rfqs,1))
    HeadMin=zeros(size(rfqs,1))
    HeadMax=zeros(size(rfqs,1))
    for i=1:size(rfqs,1)
        CapRange[:,i]=range(50,stop=EspPump.AOF,length=ns).*(rfqs[i]/EspPump.RefFreq)  # Capacity Range in bbl/d
        Head[:,i]=HeadEq(CapRangeRef).*Stages.*(rfqs[i]/EspPump.RefFreq).^2             # Pump Head  stg at Reference Frequency
        CapMin[i]=EspPump.Min.*(rfqs[i]/EspPump.RefFreq)
        CapMax[i]=EspPump.Max.*(rfqs[i]/EspPump.RefFreq)
        HeadMin[i]=HeadEq(EspPump.Min).*Stages.*(rfqs[i]/EspPump.RefFreq).^2
        HeadMax[i]=HeadEq(EspPump.Max).*Stages.*(rfqs[i]/EspPump.RefFreq).^2
    end

    #custom frecuency
    CapCustom=range(50,stop=EspPump.AOF,length=ns).*(fqs/EspPump.RefFreq)  # Capacity Range in bbl/d
    HeadCustom=HeadEq(CapRangeRef).*Stages.*(fqs/EspPump.RefFreq).^2             # Pump Head  stg at custom Frequency


    return CapRange,Head,CapMin,CapMax,HeadMin,HeadMax, CapCustom, HeadCustom

end
