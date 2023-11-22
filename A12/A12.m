close all;
clc;
clear all;

% First Scenario
lambda = 10;

mu1 = 50;
mu2 = 5;
p = 0.8;

D = p / mu1 + (1-p) / mu2;
m2 = 2 * p / (mu1 ^ 2) + 2 * (1-p) / (mu2 ^ 2); 

rho = lambda * D;
U = rho;

R = D + (lambda * m2) / (2 * (1-rho));
N = rho + (lambda^2 * m2) / ((2 * (1-rho)));

fprintf(1, "============ SCENARIO 1: M/G/1 ============\n");
fprintf(1, "Total Utilization: %g\n", U);
fprintf(1, "The (exact) average response time: %g\n", R);
fprintf(1, "The (exact) average number of jobs in the system: %g\n", N);

% Second Scenario: Erlang Distribution
lambda = 240;
k = 5;

c = 3;

U2 = (lambda/k * D)/c;
rho2 = U2;

ca = 1/sqrt(k);
cv = sqrt(m2 - D^2)/D;

theta = ((D / (c * ( 1-rho2))) / (1 + ((1-rho2)*(factorial(c) / (c*rho2)^c)) * sum(((c*rho2).^(0:(c-1))) ./ factorial(0:(c-1)))));

R2 = D + ((ca^2 + cv^2)/2) * theta;
N2 = (lambda/k) * R2;

fprintf(1, "============ SCENARIO 2: G/G/3 ============\n");
fprintf(1, "Average Utilization: %g\n", U2);
fprintf(1, "The (approximate) average response time: %g\n", R2);
fprintf(1, "The (approximate) average number of jobs in the system: %g\n", N2);
