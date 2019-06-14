function OilInflow(pr,J;pb=0,n=10)

    pres=zeros(n,size(pr,1))
    Qrate=zeros(n,size(pr,1)*size(J,1))
    Sat=pr.<=pb

    leg=Array{String,1}(undef,size(pr,1)*size(J,1))
    count=0
    for p=1:size(pr,1)

        pres[:,p]=range(0,stop=pr[p]-50,length=n)


        for j=1:size(J,1)
             count=count+1
             leg[count]="Res. Pressure=$(pr[p]) psi; J=$(J[j]) bbl/d*psi"
            if Sat[p]==1
               Qrate[:,count]=map(pwf->(pr[p]*J[j]/1.8).*(1-0.2*(pwf./pr[p])-0.8*(pwf./pr[p]).^2),pres[:,p])
            else
                Qrate[pres[:,p].>=pb,count]=map(pwf->J[j]*(pr[p]-pwf),pres[:,p][pres[:,p].>=pb])
                Qrate[pres[:,p].<pb,count]=map(pwf->(J[j]*(pr[p]-pb))+(J[j]*pb/1.8)*(1-0.2*(pwf./pb)-0.8*(pwf./pb).^2),pres[:,p][pres[:,p].<pb])

            end

        end


    end
    return pres, Qrate, leg
end
