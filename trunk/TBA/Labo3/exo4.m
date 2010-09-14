%-------------------------------
%Auteurs: Burkhalter / Lienhard
%-------------------------------

clear all;

X = [0,0,0,0,0,0,0,0,0,0,0,1]
G = [1,0,1,0,1,1,1,0,0,0,1,1]

S0(1)=0;
S1(1)=0;
S2(1)=0;
S3(1)=0;
S4(1)=0;
S5(1)=0;
S6(1)=0;
S7(1)=0;
S8(1)=0;
S9(1)=0;
S10(1)=0;
S11(1)=0;

for k=1:12
    if(k<2)
        S0(k)=0;
    else
        S0(k)=S11(k-1)+X(k-1);
    end;
    
    if(k<3)
        S1(k)=0;
    else
        S1(k)=S11(k-2)+X(k-2);
    end;
    
    if(k<2)
        S2(k)=0;
    else
        S2(k)=S1(k-1) + S11(k-1) + X(k-1);
    end;
    
    if(k<2)
        S3(k)=0;
    else
        S3(k)=S2(k-1);
    end;
    
    if(k<2)
        S4(k)=0;
    else
        S4(k)=S3(k-1)+S11(k-1) + X(k-1);
    end;
    
    if(k<2)
        S5(k)=0;
    else
        S5(k)=S4(k-1)+S11(k-1) + X(k-1);
    end;
    
    if(k<2)
        S6(k)=0;
    else
        S6(k)=S5(k-1)+S11(k-1) + X(k-1);
    end;
    
    if(k<2)
        S7(k)=0;
    else
        S7(k)=S6(k-1);
    end;
    
    if(k<2)
        S8(k)=0;
    else
        S8(k)=S7(k-1);
    end;
    
    if(k<2)
        S9(k)=0;
    else
        S9(k)=S8(k-1);
    end;
    
    if(k<2)
        S10(k)=0;
    else
        S10(k)=S9(k-1)+S11(k-1) + X(k-1);
    end;
    
    if(k<2)
        S11(k)=0;
    else
        S11(k)=S10(k-1)+S11(k-1) + X(k-1);
    end;
end;
     
%R�cup�ration du reste
for k=13:13
    if(k<2)
        S0(k)=0;
    else
        S0(k)=S11(k-1)+X(k-1);
    end;
    
    if(k<3)
        S1(k)=0;
    else
        S1(k)=S11(k-2)+X(k-2);
    end;
    
    if(k<2)
        S2(k)=0;
    else
        S2(k)=S1(k-1) + S11(k-1) + X(k-1);
    end;
    
    if(k<2)
        S3(k)=0;
    else
        S3(k)=S2(k-1);
    end;
    
    if(k<2)
        S4(k)=0;
    else
        S4(k)=S3(k-1)+S11(k-1) + X(k-1);
    end;
    
    if(k<2)
        S5(k)=0;
    else
        S5(k)=S4(k-1)+S11(k-1) + X(k-1);
    end;
    
    if(k<2)
        S6(k)=0;
    else
        S6(k)=S5(k-1)+S11(k-1) + X(k-1);
    end;
    
    if(k<2)
        S7(k)=0;
    else
        S7(k)=S6(k-1);
    end;
    
    if(k<2)
        S8(k)=0;
    else
        S8(k)=S7(k-1);
    end;
    
    if(k<2)
        S9(k)=0;
    else
        S9(k)=S8(k-1);
    end;
    
    if(k<2)
        S10(k)=0;
    else
        S10(k)=S9(k-1)+S11(k-1) + X(k-1);
    end;
    
    if(k<2)
        S11(k)=0;
    else
        S11(k)=S10(k-1)+S11(k-1) + X(k-1);
    end;
end;

%V�rification
Xswap = X(12:-1:1)
Yswap = gfconv(Xswap,[0,0,0,0,0,0,0,0,0,0,0,1])
[quotient,resteSwap]=gfdeconv(Yswap,G)

reste = resteSwap(11:-1:1)
 
for i = 1:23
    if(i<13)
        code(i)=X(i);
    else
        code(i)=reste(i-12);
    end
end

    
    
    