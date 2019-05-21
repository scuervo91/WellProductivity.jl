function Declination(Time,Rate)

        Ti=Dates.days.(Time[1])
        Cum=accumulate(+,Rate)


        D=Reg(Dates.days.(Time).-Ti,Rate, TypeReg="Exponential")
        Q=Reg(Cum,Rate, TypeReg="Linear")

        S=ExponentialDec(D[1],Q[2],Ti)
        DecLine=map(X->S.Qi.*exp(S.Di.*X),Dates.days.(Time).-S.Ti)




            return S, DecLine


end #End Function


function DeclinationForecast(S,DateRange)

    ForecastLine=map(X->S.Qi.*exp(S.Di.*X),Dates.days.(DateRange).-S.Ti)


end # End function
