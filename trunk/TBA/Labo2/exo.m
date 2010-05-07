clear all;

G = [1 0 0 1 0 1 1; 0 1 0 1 1 1 0; 0 0 1 0 1 1 1]

[k,n] = size(G)

infWordsDec = (0:(2^k-1));


%2.1.1 est stoqué dans infWords
infWords = dec2bin(infWordsDec, k)

%2.1.2

codeWords =mod(infWords*G,2)



%2.1.3
nombre_1=codeWords*ones(1,n)';
dmin=min(nombre_1(2:end)); % on ne doit pas prendre le mot code constitué que de 0.
capDet = dmin -1

capCorr = floor(capDet/2)

%2.1.4
seq = [0 0 0 1 0 0 1 1 1];

for i = 0:((length(seq)/k)-1)
    code(1,i*n + 1: (i+1)*n) = mod(seq(i*k + 1:(i+1)*k) * G,2);
end

code

%4.1
P = G(1:k, k+1:n)

I = eye(n-k)

Ht = [P ; I]

mod(G * Ht, 2)

%4.2
mod(codeWords * Ht, 2)

%4.5
seq = [1 1 1 1 0 1 0];

syndrome = mod(seq * Ht, 2) % correspond à la 4e ligne de Ht il faut donc changer le 4e bit de seq pour qu'il soit bon

%4.6
seq = [0 0 1 1 1 1 1 1 0 1 1 1 1 1 0 1 1 1 1 1 1 0 0 1 1 1 1 0];
res = [];

for i = 0:(size(seq,2) / n)-1
    syndrome = mod(seq(i*n+1:(i+1)*n) * Ht, 2);
    err = 0;
    lol = true;
    if(syndrome == zeros(1,n-k))
        
    else
        for j = 1:n
            err = 1;
            if (mod(syndrome + Ht(j, :),2) ~= zeros(1,n-k))
                seq(1, i*n+j) = seq(1, i*n+j) + 1;
                err = 0;
                break
            end
        end
    end
    if err == 1
        disp('Trop d erreur dans la séquence, on ne peut pas retrouver le mot info. Toutes les réponses suivantes sont fausses')
        break
    end
    res = [res, mod(seq(i*n+1:i*n+k), 2)];
end

res