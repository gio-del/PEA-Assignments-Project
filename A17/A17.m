close all;
clear all;
clc;

% Service Times (min)
Sa = [10 12];
Sb = [4 3];
Sc = [6 6];

% Lambdas (parts / min)
lka = [2 0] / 60;
lkb = [3 0] / 60;
lkc = [2.5 0] / 60;

la = sum(lka);
lb = sum(lkb);
lc = sum(lkc);

P = [0 1; % Production Packaging
     0 0
    ];

Xa = la;
Xb = lb;
Xc = lc;

X = Xa + Xb + Xc; % Throughput

vka = (lka / la) / (eye(2) - P); 
vkb = (lkb / lb) / (eye(2) - P); 
vkc = (lkc / lc) / (eye(2) - P); 

Dka = vka .* Sa;
Dkb = vkb .* Sb;
Dkc = vkc .* Sc;

%1. The utilization of the two stations
Uka = la .* Dka;  
Ukb = lb .* Dkb;
Ukc = lc .* Dkc;

Uk = [Uka(:, 1) + Ukb(:, 1) + Ukc(:, 1), Uka(:, 2) + Ukb(:, 2) + Ukc(:, 2)];

Nka = Uka ./ (1 - Uk);
Nkb = Ukb ./ (1 - Uk);
Nkc = Ukc ./ (1 - Uk);

%2. The average number of jobs in the system for each type of product (class c - Nc).
Na = sum(Nka);
Nb = sum(Nkb);
Nc = sum(Nkc);

%3. The average system response time per product type (class c - Rc)
Ra = Na / la;
Rb = Nb / lb;
Rc = Nc / lc;

%4. The class-independent average system response time (R)
l_tot = la + lb + lc;
weights = [la lb lc] / l_tot;
R_classes = [Ra Rb Rc];

R = sum(R_classes .* weights);

fprintf(1, "Utilization Production %g\n", Uk(1));
fprintf(1, "Utilization Packaging %g\n", Uk(2));
fprintf(1, "Average Number of Class A in the system: %g\n", Na);
fprintf(1, "Average Number of Class B in the system: %g\n", Nb);
fprintf(1, "Average Number of Class C in the system: %g\n", Nc);
fprintf(1, "Average System Response Time Class A: %g\n", Ra);
fprintf(1, "Average System Response Time Class B: %g\n", Rb);
fprintf(1, "Average System Response Time Class C: %g\n", Rc);
fprintf(1, "The class-independent average system response time: %g\n", R);