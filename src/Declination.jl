function Declination(time,rate; AD=true)

        #Anomally Detection
if AD==true
    epsilon=0.05339
    mu=mean(rate)
    sigma=std(rate)
    NormRate=map(x->(x-mu)/sigma,rate)
    pval=map(x->pdf(Normal(),x),NormRate)
    ev=pval.>epsilon
    Time=time[ev]
    Rate=rate[ev]
else
    Time=time
    Rate=rate
end

        #
        Ti=Dates.days.(Time[1])
        Cum=accumulate(+,Rate)


        D=Reg(Dates.days.(Time).-Ti,Rate, TypeReg="Exponential")
        Q=Reg(Cum,Rate, TypeReg="Linear")

        S=ExponentialDec(D[1],Q[2],Ti)
        DecLine=map(X->S.Qi.*exp(S.Di.*X),Dates.days.(Time).-S.Ti)




            return S, Time, DecLine


end #End Function


function DeclinationForecast(S,DateRange)

    ForecastLine=map(X->S.Qi.*exp(S.Di.*X),Dates.days.(DateRange).-S.Ti)


end # End function
