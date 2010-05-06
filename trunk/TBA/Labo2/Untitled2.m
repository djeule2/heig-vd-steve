clear all;

%Déclaration de la matrice génératrice
G=[1 0 0 1 0 1 1;0 1 0 1 1 1 0; 0 0 1 0 1 1 1];
H=[1 0 1 1;1 1 1 0;0 1 1 1;1 0 0 0;0 1 0 0;0 0 1 0;0 0 0 1];

%Récupération des la taille de la matrice
[k,n] = size(G)

%création d'une matrice de 1
test=(ones(1,n))'

for i=1:2^k
    %ensemble des mots info
    mot_info(i,1:k)=dec2bin(i-1,k);
    %ensemble des mots-code
    mot_code(i,1:n)=mod(mot_info(i,1:k)*G,2);
    
    %Distance de Hamming de chaque code (nb de 1)
    nombre_1(i) = mot_code(i,1:n)*test;
end

mot_info
mot_code
%distance de Hamming minimum
d_min = min(nombre_1(2:2^k))

cap_detection = d_min - 1

sequence=[0 0 0 1 0 0 1 1 1 ]
longueur=length(sequence)

%récupération du nombre de mots info dans la sequence
nombre_mot_info=longueur/k

for i=1:nombre_mot_info
    mot_info2(i,1:k)= sequence([(i-1)*k+1:i*k]);
end
mot_info2(i,1:k)= sequence([(i-1)*k+1:i*k])

%codage des mots infos récupérés
mod(mot_info2*G,2)




%Partie Correction
sequence_error=[0 0 1 1 1 1 1 1 0 1 1 1 1 1 0 1 1 1 1 1 1 0 0 1 1 1 1 0]
longueur=length(sequence_error)

[k,n]=size(H);

%récupération du nombre de mots info dans la sequence
nombre_mot_info=longueur/k

for i=1:nombre_mot_info
    mot_info_error(i,1:k)= sequence_error([(i-1)*k+1:i*k]);
end
mot_info_error(i,1:k)= sequence_error([(i-1)*k+1:i*k])

mot_error = mod(mot_info_error*H,2)

%correction des erreurs
for i=0:n
   for j=0:k
        if mot_error(i,:) = H()
        
            
%end

