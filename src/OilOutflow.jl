function OilOutflow(Depth,Thp,Bsw,OilPVT,GasPVT,WaterPVT, Qmax;ϵ=0.0006, Ts=80, ∇T=1, GOR=false, di=2.99, Qn=10, Dn=50, tol=0.05, sg=0.6)

    # Create the range of Depth and Rates
    DepthRange=range(0, stop=Depth, length=Dn)
    Qrange=range(100, stop=Qmax, length=Qn)


    #Create the interpolations function for PVT
    ## Oil
    Rs=LinearInterpolation(OilPVT.P, OilPVT.Rs)
    ρo=LinearInterpolation(OilPVT.P, OilPVT.Rho)
    βo=LinearInterpolation(OilPVT.P, OilPVT.Bo)
    μo=LinearInterpolation(OilPVT.P, OilPVT.Muo)
    Co=LinearInterpolation(OilPVT.P, OilPVT.Co)
    σo=LinearInterpolation(OilPVT.P, OilPVT.Ten)

    ## Gas
    Z=LinearInterpolation(GasPVT.P, GasPVT.Z)
    ρg=LinearInterpolation(GasPVT.P, GasPVT.Rho)
    βg=LinearInterpolation(GasPVT.P, GasPVT.Bg)
    μg=LinearInterpolation(GasPVT.P, GasPVT.Mug)
    Cg=LinearInterpolation(GasPVT.P, GasPVT.Cg)

    ## Water
    ρw=LinearInterpolation(WaterPVT.P, WaterPVT.Rho)
    βw=LinearInterpolation(WaterPVT.P, WaterPVT.Bw)
    μw=LinearInterpolation(WaterPVT.P, WaterPVT.Muw)
    Cw=LinearInterpolation(WaterPVT.P, WaterPVT.Cw)
    σw=LinearInterpolation(WaterPVT.P, WaterPVT.Ten)

    #Temperature
    T=LinearInterpolation([0, Depth], [Ts, Ts+Depth*(∇T/100)])

    #Calculate variables
    TransArea=π*(di/(12*2))^2  #Transversal Area [Ft2]
    GOR==false ? Rsi=maximum(OilPVT.Rs) : Rsi=GOR

    #Create Variables
    ql=zeros(Qn)     #Vector of Liquid rate
    qo=zeros(Qn)     #Vector of Oil Rate
    usl=zeros(Qn)    #Vector of liquid Velocities
    um=zeros(Dn)    #Vector of liquid Velocities
    P=zeros(Dn,Qn)   #Matrix of Pressures
    ∇P=zeros(Dn,Qn)  #Matriz of perssure gradient
    P[1,:].=Thp       #Initial pressure is Thp
    ∇P[1,:].=(ρo(Thp)*(1-Bsw)+ρw(Thp)*Bsw)*(0.433/62.4)         #Initial PRessure gradient is the average density
    e=tol+0.01
    ∇Pnew=0.0

    #General Loop for each Rate
    for j=1:Qn
        #Calculate Liquid Velocities
        ql[j]=Qrange[j]*(5.615/86400)           #Liquid Rate [ft3/s]
        qo[j]=(Qrange[j]*(1-Bsw))*(5.615/86400) #Oil Rate [ft3/s]
        usl[j]=ql[j]/TransArea                  #Liquid Velocity [ft/s]

        #General Loop for each depth
        for i=2:Dn

         ∇Pguess=∇P[i-1,j]
          e=tol+0.01

          #While Iteration
           while e>=tol

             Pguess=∇Pguess*(DepthRange[i]-DepthRange[i-1])+P[i-1,j]                             #Estimate Pressure Guess [psi]
             FreeGas=(Rsi-Rs[Pguess])*qo[j]                                            #Estimate FreeGas Rate [scf/d]
             usg= (4*FreeGas*Z(Pguess)*(460+T(DepthRange[i]))*14.7)/(86400*Pguess*520*π*(di/12)^2)  #Estimate Gas Velocity
             um[j]=usg+usl[j]  #Total Velocity
             σl= (σo(Pguess)*(1-Bsw)+σw(Pguess)*Bsw)
             ρl= (ρo(Pguess)*(1-Bsw)+ρw(Pguess)*Bsw)                                   #Liquid Density Lbm/ft3
             μl= (μo(Pguess)*(1-Bsw)+μw(Pguess)*Bsw)                                   #Liquid Viscosity [Cp]
             λg=usg/um[j]
             LBi=1.071-0.2218*(um[j]^2 /(di/12))
             LBi>=0.13 ? LB=LBi : LB=0.13

                #Evaluate if Bubble flow Exist
                if LB>λg

                  yl=1-0.5*(1+(um[j]/0.8)-sqrt((1+(um[j]/0.8))^2-4*(usg/0.8)))

                else

                 Nvl= 1.938*usl[j]*(ρl/σl)^0.25                                    #Liquid Velocity Number
                 Nvg=1.938*usg*(ρl/σl)^0.25                                        #Gas Velocity Number
                 Nd=120.872*(di/12)*(ρl/σl)^0.5                                    #Pipe Diameter Number
                 Nl=0.15726*μl*(1/(ρl*σl^3))^0.25                                  #Liquid Viscosity Number
                 #CNl=(0.0019+0.0322*Nl-0.6642*Nl^2+4.9951*Nl^3)/(1+10.0147*Nl-33.8696*Nl^2+277.2817*Nl^3) # original
                 CNl=(0.0019+0.0505*Nl-0.0929*Nl^2+0.061*Nl^3)   #pengtools
                 H=(CNl*Nvl*Pguess^0.1)/(Nvg^0.575 * 14.7^0.1 * Nd)
                 ψy=((0.0047+1123.32*H-729489.64*H^2)/(1+1097.1566*H-722153.97*H^2))^0.5
                 B=(Nvg*Nl^0.38)/(Nd^2.14)
                # ψ=(1.0886+69.9473*B-2334.3497*B^2+12896.683*B^3)/(1+53.4401*B-1517.9369*B^2+8419.8115*B^3)

                     if B>0.055
                         ψ=2.5714*B+1.5962
                    elseif B>0.025
                         ψ=-533.33*B^2+58.524*B+0.1171
                    else
                         ψ=27170*B^3-317.52*B^2+0.5472*B+0.9999
                    end

                     yl=ψy*ψ                                                                   #Liquid HoldUp
                end

                 ρg=(28.97*Pguess*sg)/(Z(Pguess)*10.73*T(DepthRange[i]))
                 ma= TransArea*(usl[j]*ρl+usg*ρg)*86400
                 Nre=(0.022*ma)/((di/12)*μl^yl*μg(Pguess)^(1-yl))
                 f=(1/(-4*log((ϵ/3.7065)-(5.0452/Nre)*log((ϵ^1.1098/2.8257)+(7.149/Nre)^0.8981))))^2   #Friction factor
                 ρa=yl*ρl+(1-yl)*ρg
                 ∇Pnew=(1/144)*(ρa+((f*ma^2)/(7.413e10*(di/12)^5*ρa))+((ρa*(um[i]-um[i-1]))/(32.2*2*(DepthRange[i]-DepthRange[i-1]))))
                  e=  abs(∇Pguess-∇Pnew)/∇Pnew
                  ∇Pguess=∇Pnew

            end #End While

            ∇P[i,j]=∇Pnew
            P[i,j]=∇P[i,j]*(DepthRange[i]-DepthRange[i-1])+P[i-1,j]

        end #End for Dn

    end #End for Qn

    #Pwf=P[end,:]
    return DepthRange, Qrange, P, ∇P, e

    end #End Function
