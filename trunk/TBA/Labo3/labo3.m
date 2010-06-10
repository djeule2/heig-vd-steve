%-------------------------------
%Auteurs: Burkhalter / Lienhard
%-------------------------------

clear all;

%Déclaration de la polynome générateur
G = [1,1,0,1];
k=4; %taille des mots info
n=7; %taille des mots code

for i=1:2^k
   mot_info = de2bi(i-1,k);
   mot_code = gfconv(G,mot_info)
   mot_code_dec = bi2de(mot_code);
   mot_code_Nbits = de2bi(mot_code_dec,n)
   tab_mot_code_Nbits(i,1:n) = mot_code_Nbits;
end

tab_mot_code_Nbits

for i=1:2^k
   mot_info = de2bi(i-1,k);
   mot_info_new = mot_info(k:-1:1)
   
   for j=1:n
       if(j<=k)
          mot_code_decal(j)=mot_info_new(j); 
       else
          mot_code_decal(j)=0;
       end
   end
   mot_decal_swap = mot_code_decal(n:-1:1)
   [quotient,reste]=gfdeconv(mot_decal_swap,G)
   reste_new = reste(length(reste):-1:1)
  
   
   reste_decimal = bi2de(reste_new);
   reste_bi = de2bi(reste_decimal,n-k)
   reste_decal = gfconv([0,0,0,0,1],reste_bi)
   reste_decal_dec = bi2de(reste_decal);
   reste_decal_Nbits = de2bi(reste_decal_dec,n)
   
   mot_code_syst = gfadd(mot_code_decal,reste_decal_Nbits)
end