```
Reg(args...)  -->Plot

Estimate Linear, Exponential and Power regression type
``Linear\quad \Rightarrow y=mx+b\\ Exponential\quad \Rightarrow y=b{ e }^{ mx }\\ Power\quad \Rightarrow y=b{ x }^{ m }``

The next table show the list of variables allowed:

|PropertyName|Args|Default|Input|Description
|---|---|---|---|---|
|x|Mandatory|--|Array{Number,1}| x Data|
|y|Mandatory|--|Array{Number,1}| y Data|
|TypeReg|Optional|TypeReg="Linear"|TypeReg= "linear" or "Exponential"  or "Power"|Type of regression|
|pr|Optional|pr=false|pr=Bool|Print the results of regression|
```
function Reg(x,y; TypeReg="Linear", pr=false)

    if TypeReg=="Linear"
        m=(mean(x)*mean(y)-mean(x.*y))/(mean(x)^2-mean(x.^2))
        b=mean(y)-m*mean(x)
        SELine=sum(map((X,Y)->((X*m+b)-Y)^2,x,y))
        SEYmean=sum(map(Y->(Y-mean(y))^2,y))
        R2=1-(SELine/SEYmean)

        pr ? println(" **Linear Regression \n form y = mx+b \n m=$m \n b=$b \n r2=$R2") : :none
        return m,b,R2
    elseif TypeReg=="Exponential"
        m=(mean(x)*mean(log.(y))-mean(x.*log.(y) ) )/(mean(x)^2-mean(x.^2))
        Logb=mean(log.(y))-m*mean(x)
        b=exp(Logb)
        SELine=sum(map((X,Y)->((X*m+Logb)-Y)^2,x,log.(y)))
        SEYmean=sum(map(Y->(Y-mean(log.(y)))^2,log.(y)))
        R2=1-(SELine/SEYmean)

        pr ? println(" **Exponential Regression \n form y = b*exp(mx) \n m=$m \n b=$b \n r2=$R2") : :none
        return m, b,R2
    elseif TypeReg=="Power"
        m=(mean(log.(x))*mean(log.(y))-mean(log.(x).*log.(y) ) )/(mean(log.(x))^2-mean(log.(x).^2))
        Logb=mean(log.(y))-m*mean(log.(x))
        b=exp(Logb)
        SELine=sum(map((X,Y)->((X*m+Logb)-Y)^2,log.(x),log.(y)))
        SEYmean=sum(map(Y->(Y-mean(log.(y)))^2,log.(y)))
        R2=1-(SELine/SEYmean)

        pr ? println(" **Power Regression \n form y = b x^(m) \n m=$m \n b=$b \n r2=$R2") : :none
        return m, b,R2
    end

end
