close all;
clear all;
clc;

% Open
l_IN = [3 2 0 0]; % SelfCheck AppServer WebServer DBMS
P = [0 0.8 0 0;
    0 0 0.3 0.5;
    0 1 0 0;
    0 1 0 0
    ];
S = [2000 30 100 80] / 1000;

X = sum(l_IN);

l_norm = l_IN / X;

vk = l_norm / (eye(4) - P);
Dk = S .* vk;
Xk = X .* vk;
Uk = S .* Xk;
Nk = (Uk) ./ (1 - Uk);
N = sum(Nk); 
R = N/X; % Little Law

fprintf(1, "============ Open System ============\n");
fprintf(1, "Throughput Of The System: %g j/s\n", sum(l_IN));
fprintf(1, "Average System Response Time: %g s\n", R);
fprintf(1, "Average Number Of Jobs In the System: %g jobs\n", N)