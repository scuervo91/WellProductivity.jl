```
gascum(args...)  -->Plot

Plot the Gas Cum of a well in a single Plot

The next table show the list of variables allowed:

|PropertyName|Args|Default|Input|Description
|---|---|---|---|---|
|Date|Mandatory|--|Array{Date,1}| Array of dates|
|bsw|Mandatory|--|Array{Number,1}| Array of Gascum|
|Dlim|Optional|Drange=false|Dlim=[Date(y,m,d) Date(y,m,d)]|xlim Dates range|
|mrange|Optional|mrange=false|mrange=number| Time interval in months to set xticks|
|dtf|Optional|dft="u yy"|dtf=DateFormat|Date format of xticks|
```
@userplot GasCum

@recipe function f(h::GasCum; Dlim=false, mrange=6, dft="u yy")
                  legend --> false
                  x, y = h.args

    if Dlim==false
        r = x[1]:Dates.Month(mrange):x[end]
        d = Dates.format.(r,dft)
    else
        r = Dlim[1]:Dates.Month(mrange):Dlim[2]
        d = Dates.format.(r,dft)
    end

        @series begin
        seriestype := :path
        linestyle := :dash
        linewidth := 1
        seriescolor := RGB(0.6, 0.0, 0.0)
        ylabel := "Gas Cum [MMscf]"
        xticks := (r,d)

        if Dlim!=false
        xlim := (Dates.value(Dlim[1]),Dates.value(Dlim[2]))
        end
        x, y
        end
end
