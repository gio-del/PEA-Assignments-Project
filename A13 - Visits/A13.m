close all;
clear all;
clc;

% Closed
l = [1 0 0 0]; % Terminals, CPU, Disk, RAM. Terminals are the REF
P_0 = [0, 1, 0, 0;
       0, 0, 0.3, 0.6;
       0, 0.85, 0, 0.15;
       0, 0.75, 0.25, 0
      ];
S = [20 10 3] / 1000;
Z = 10;
v = l / (eye(4) - P_0);
D = [v(1)*Z, v(2:4) .* S];

fprintf(1, "============ Closed System ============\n");
fprintf(1, "Terminals\n");
fprintf(1, "Visit: %g\n", v(1));
fprintf(1, "Demand: %g\n", D(1));
fprintf(1, "CPU\n");
fprintf(1, "Visit: %g\n", v(2));
fprintf(1, "Demand: %g\n", D(2));
fprintf(1, "Disk\n");
fprintf(1, "Visit: %g\n", v(3));
fprintf(1, "Demand: %g\n", D(3));
fprintf(1, "RAM\n");
fprintf(1, "Visit: %g\n", v(4));
fprintf(1, "Demand: %g\n", D(4));

% Open
l_IN = [0.3 0 0];
P = [0, 0.3, 0.6;
     0.8, 0, 0.15;
     0.75, 0.25, 0];
S2 = [20 10 3] / 1000;

X = sum(l_IN);

l_norm = l_IN / X;

vk = l_norm / (eye(3) - P);
Dk = S2 .* vk;
Xk = X .* vk;

fprintf(1, "============ Open System ============\n");
fprintf(1, "CPU\n");
fprintf(1, "Visit: %g\n", vk(1));
fprintf(1, "Demand: %g\n", Dk(1));
fprintf(1, "Throughput: %g\n", Xk(1));
fprintf(1, "Disk\n");
fprintf(1, "Visit: %g\n", vk(2));
fprintf(1, "Demand: %g\n", Dk(2));
fprintf(1, "Throughput: %g\n", Xk(2));
fprintf(1, "RAM\n");
fprintf(1, "Visit: %g\n", vk(3));
fprintf(1, "Demand: %g\n", Dk(3));
fprintf(1, "Throughput: %g\n", Xk(3));