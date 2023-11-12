clc;
clear all;
close all;

lambda = 150 / 60; % Poisson arrival rate req/min -> req/s
D = 350 / 1000; % avg service time ms -> s
K = 32; % max number of requests

u = 1/D;
rho = lambda / u;
Pk = (rho^K - rho^(K+1)) / (1-rho^(K+1));

%. The utilization of the system
U = (rho-rho^(K+1))/(1-rho^(K+1));

% The loss probability
P_loss = (rho^K - rho^(K+1)) / (1 - rho^(K+1));

% The average number of jobs in the system
N = rho/(1-rho) - ((K+1)*rho^(K+1)) / (1-rho^(K+1));

% The drop rate
Dr = lambda * Pk;

% The average response time
R = N / (lambda * (1-Pk));

% The average time spent in the queue (waiting for service)
Tqueue = R - D;

fprintf(1, "================== SCENARIO 1 ==================\n");
fprintf(1, "Utilization: %g\n", U);
fprintf(1, "Loss Probability: %g\n", P_loss);
fprintf(1, "Average Number of Jobs in the system: %g\n", N);
fprintf(1, "Drop Rate: %g\n", Dr);
fprintf(1, "Average Response Time: %g\n", R);
fprintf(1, "Average Time Spent in the queue: %g\n", Tqueue);

% After 1 year the lambda becomes 250 req/min, c = 2
c = 2;
lambda = 250 / 60;

rho = lambda / (c * u);

% The utilization of the system
U = sum(arrayfun(@(x) (x * pn(rho, x, c, K)), 1:c));
U = U + sum(arrayfun(@(x) (c * pn(rho, x, c, K)), 3:K));

avg_U = U / c;

% The loss probability
P_loss = pn(rho, K, c, K);

% The average number of jobs in the system
N = sum(arrayfun(@(x) (x * pn(rho, x, c, K)), 1:K));

% The drop rate
Dr = lambda * pn(rho, K, c, K);

% The average response time
R = N / (lambda * (1 - pn(rho, K, c, K)));

% The average time spent in the queue (waiting for service)
Tqueue = R - D;

fprintf(1, "================== SCENARIO 2 ==================\n");
fprintf(1, "Total Utilization: %g\n", U);
fprintf(1, "Average Utilization: %g\n", avg_U);
fprintf(1, "Loss Probability: %f\n", P_loss);
fprintf(1, "Average Number of Jobs in the system: %g\n", N);
fprintf(1, "Drop Rate: %f\n", Dr);
fprintf(1, "Average Response Time: %g\n", R);
fprintf(1, "Average Time Spent in the queue: %g\n", Tqueue);

function F = pn(rho, n, c, K)
    p0 = ((((c*rho)^c * (1 - rho^(K-c+1))) / (factorial(c) * (1 - rho))) + sum(((c*rho).^(0:(c-1))) ./ factorial(0:(c-1)))).^(-1);
    if(n<c)
        F = (p0 / factorial(n)) * (c*rho)^n;
    elseif(c<=n && n<=K)
        F = (p0*c^c*rho^n) / factorial(c);
    else
        fprintf(1, "SHOULD NOT BE HERE!!\n");
        F = 0;
    end
end