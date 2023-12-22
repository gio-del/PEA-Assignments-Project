clear variables;
clc;

%%% M/M/1 queue
fprintf(1, "======================= M/M/1 =======================\n")

% Poisson process arrival rate [job/s]
lambda = 40;
% Avg Service time, (ms -> seconds)
D = 16/1000;

% Service rate
u = 1/D;

% Utilization
U = lambda*D;
p = lambda*D; % Traffic Intensity
fprintf("Utilization: %f\n", U);

% Probability of having exactly one job in the system
fprintf("P(J=1): %f\n", (1-p)*(p)^1);

% Probability of having less than 10 jobs in the system
fprintf("P(J<10): %f\n", 1 - p^(9+1));
 
% Average queue length (job not in service)
fprintf("Average queue length: %f\n", (U^2)/(1-U)); % also (R-D)*lambda

% Average response time
R = D/(1-p);
fprintf("Average response time: %f sec\n", R);

% Response Time ~ X_exp<u-lambda>
% Probability that the response time is greater than 0.5 s.
fprintf("P(R>0.5): %f\n", exp(-(0.5/R))); % also exp(-(0.5*(u-lambda)))

% 90 percentile of the response time distribution
fprintf("90 percentile of the response time: %f\n", -log(1-90/100)*R);

%%% M/M/2 queue
fprintf(1, "======================= M/M/2 =======================\n")

% Poisson process arrival rate [job/s]
lambda = 90;

% Utilization
U = lambda*D;
fprintf("Utilization: %f\n", U);
avg_U = U / 2;
fprintf("Average Utilization: %f\n", avg_U);

p = avg_U;

% Probability of having exactly one job in the system
fprintf("P(J=1) = %g\n", 2*(1-p)/(1+p)*p);

% Probability of having less than 10 jobs in the system
p0 = (1-p)/(1+p);
p_less_10 = p0;

for i=1:9
    p_less_10 = p_less_10 + 2 * p0 * p^i;
end

fprintf("P(J<10) = %g\n", p_less_10); % 2*p0*sum_i p^n from i=1 to 9 = 2*p0 * p*(p^9-1)/(p-1) + p0

% Average response time
R = D/(1-p^2);
fprintf("Average response time: %f sec\n", R);

% Average queue length (job not in service)
fprintf("Average queue length: %f\n", (R-D) * lambda);