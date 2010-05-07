%-------------------------------
%Auteurs: Burkhalter / Lienhard
%-------------------------------

clear all;

%D�claration de la matrice g�n�ratrice
G=[1 0 0 1 0 1 1;0 1 0 1 1 1 0; 0 0 1 0 1 1 1];
H=[1 0 1 1;1 1 1 0;0 1 1 1;1 0 0 0;0 1 0 0;0 0 1 0;0 0 0 1];

%R�cup�ration des la taille de la matrice
[k,n] = size(G)

%cr�ation d'une matrice de 1
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

%r�cup�ration du nombre de mots info dans la sequence
nombre_mot_info=longueur/k

for i=1:nombre_mot_info
    mot_info2(i,1:k)= sequence([(i-1)*k+1:i*k]);
end
mot_info2(i,1:k)= sequence([(i-1)*k+1:i*k])

%codage des mots infos r�cup�r�s
mod(mot_info2*G,2)



%---------------------------------
%Partie Correction
%---------------------------------
sequence_error=[0 0 1 1 1 1 1 1 0 1 1 1 1 1 0 1 1 1 1 1 1 0 0 1 1 1 1 0]
longueur=length(sequence_error)

[k,n]=size(H);

%r�cup�ration du nombre de mots info dans la sequence
nombre_mot_info=longueur/k

for i=1:nombre_mot_info
    mot_info_error(i,1:k)= sequence_error([(i-1)*k+1:i*k]);
end
mot_info_error(i,1:k)= sequence_error([(i-1)*k+1:i*k])

mot_error = mod(mot_info_error*H,2)

%--------------------------------
%correction des erreurs
%--------------------------------
seq = [1 1 1 1 0 1 0];

%R�cup�ration des la taille de la matrice g�n�ratrice
[k,n] = size(G)

%tableau de resultat
res = []
for i = 0:(size(sequence_error,2) / n)-1
    seq
    syndrome = mod(sequence_error(i*n+1:(i+1)*n) * H, 2)
    
    erreur = 0;
    
    %si il n'y a pas d'erreur
    if(syndrome == zeros(1,n-k))
    
    %si il y a une erreur
    else
        for j = 1:n
            erreur = 1;
            if (mod(syndrome + H(j, :),2) ~= zeros(1,n-k))
                sequence_error(1, i*n+j) = sequence_error(1, i*n+j) + 1;
                erreur = 0;
                break
            end
        end
    end
    if erreur == 1
        disp('Nombre trop grand d erreur,le mot info est introuvable.')
        break
    end
    res = [res, mod(sequence_error(i*n+1:i*n+k), 2)]
end
%on affiche le resultat
res