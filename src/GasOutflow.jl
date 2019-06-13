function OutflowGas(Depth,Thp,GasPVT, Qmax; di=2.99, Ts=80, ∇T=1, ϵ=0.0006, Qn=10, Dn=50, tol=0.05, sg=0.6, Inc=0)

    # Create the range of Depth and Rates
    DepthRange=range(0, stop=Depth, length=Dn)
    if size(Qmax,1)==1
        Qrange=range(100, stop=Qmax, length=Qn)
    else
        Qrange=Qmax
        Qn=size(Qmax,1)
    end

    #Size of sensibilities
    Thpn=size(Thp,1)
    din=size(di,1)

        ## Gas
    Z=LinearInterpolation(GasPVT.P.*1, GasPVT.Z.*1)
    ρg=LinearInterpolation(GasPVT.P.*1, GasPVT.Rho.*1)
    βg=LinearInterpolation(GasPVT.P.*1, GasPVT.Bg.*1)
    μg=LinearInterpolation(GasPVT.P.*1, GasPVT.Mug.*1)
    Cg=LinearInterpolation(GasPVT.P.*1, GasPVT.Cg.*1)

    Ma=GasPVT.Rho[1]*10.73*(GasPVT.T[1]+460)/GasPVT.P[1]
    sg=Ma/28.96


        #Temperature
    T=LinearInterpolation([0, Depth], [Ts+460, 460+Ts+Depth*(∇T/100)])

    #create variables
    Pwf=zeros(Thpn*din,Qn)
    angle=90 .- fill(Inc,Dn)
    leg=Array{String,1}(undef,Thpn*din)
       count=0
    for k=1:Thpn  #Loop for Thp
        for n=1:din #Loop for Diameter

            count=count+1
             P=zeros(Dn,Qn)      #Matrix of Pressures
            ∇P=zeros(Dn,Qn)      #Matriz of perssure gradient
            ∇Pnew=0.0
            P[1,:].=Thp[k]       #Initial pressure is Thp
            ∇P[1,:].=0.012       #Initial PRessure gradient

                #General Loop for each Rate
                for j=1:Qn

                    #General Loop for each depth
                    for i=2:Dn
                        e=tol+0.01
                        ∇Pguess=∇P[i-1,j]

                        while e>=tol

                            Pguess=∇Pguess*(DepthRange[i]-DepthRange[i-1])+P[i-1,j]
                            Nre=(4*28.97*sg*Qrange[j]*14.7)/(π*di[n]*μg(Pguess)*10.73*520)
                            f=(1/(-4*log((ϵ/3.7065)-(5.0452/Nre)*log((ϵ^1.1098/2.8257)+(7.149/Nre)^0.8981))))^2   #Friction factor
                            s=(-0.0375*sg*sin(angle[i]*π/180)*(DepthRange[i]-DepthRange[i-1]))/(Z(Pguess)*T[DepthRange[i]])
                            Pnew=sqrt(exp(-s)*P[i-1,j]^2-2.685e-3*((f*(Z(Pguess)*T[DepthRange[i]]*Qrange[j])^2 * (1-exp(-s)))/(sin(angle[i]*π/180)*di[n]^5)))
                            ∇Pnew=(Pnew-P[i-1,j])/(DepthRange[i]-DepthRange[i-1])
                            e=  abs(∇Pguess-∇Pnew)/∇Pnew
                            ∇Pguess=∇Pnew

                        end #end While
                    ∇P[i,j]=∇Pnew
                    P[i,j]=∇P[i,j]*(DepthRange[i]-DepthRange[i-1])+P[i-1,j]
                    end #End Loop Depth


                end #End Loop Rate
             Pwf[count,:].=P[end,:]
             leg[count]="Thp=$(Thp[k]); di=$(di[n])"
         end #End Loop Diameter

    end #End Loop Thp
    return DepthRange, Qrange, Pwf, leg
      end #End Function
