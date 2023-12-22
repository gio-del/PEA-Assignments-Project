clc;
clear all;
close all;

m = 2^32;
a = 1664525;
c = 1013904223;
seed = 521191478;
N = 10000;

% Linear Congruent Generator

for i=1:N
    if (i==1)
       x(i) = seed;
    else
        x(i) = mod(a*x(i-1) + c, m);
    end
end

u = x / m;

x = 0:25;
% Exponential Distribution

lambda_exp = 0.1;

x_exp = -log(u) / lambda_exp;

CDF_exp_empirical = empirical_cdf(x_exp);

figure('Name','Exponential Distribution','NumberTitle','off');
plot(CDF_exp_empirical(:,1), CDF_exp_empirical(:,2), ':', 'DisplayName', 'Empirical', 'LineWidth', 2);
hold on;
plot(x, Exp_cdf(x, lambda_exp), '--', 'DisplayName', 'Exact', 'LineWidth', 2);
legend;
xlim([0 25]);
title('Exponential')
hold off;



% Pareto Distribution

alpha = 1.5;
m = 5;

x_pareto = m ./ (u) .^ (1/alpha);

CDF_pareto_empirical = empirical_cdf(x_pareto);

figure('Name','Pareto Distribution','NumberTitle','off');
plot(CDF_pareto_empirical(:,1), CDF_pareto_empirical(:,2), ':', 'DisplayName', 'Empirical', 'LineWidth', 2);
hold on;
plot(x, Pareto_cdf(x, alpha, m), '--', 'DisplayName', 'Exact', 'LineWidth', 2);
legend;
xlim([0 25]);
title('Pareto');
hold off;

% Erlang Distribution

lambda_erlang = 0.4;
k = 4;

for i=1:N/k
    x_erlang(i) = 0;
    for j=1:k
        x_erlang(i) = x_erlang(i) + log(u((i-1)*k + j));
    end
    x_erlang(i) = -x_erlang(i) / lambda_erlang;
end

CDF_erlang_empirical = empirical_cdf(x_erlang);

figure('Name','Erlang Distribution','NumberTitle','off');
plot(CDF_erlang_empirical(:,1), CDF_erlang_empirical(:,2), ':', 'DisplayName', 'Empirical', 'LineWidth', 2);
hold on;
plot(x, Erlang_cdf(x, lambda_erlang, k), '--', 'DisplayName', 'Exact', 'LineWidth', 2)
legend;
xlim([0 25]);
title('Erlang');
hold off;

% Hypo-Exponential Distribution
hypo_lambda = [0.5, 0.125];

for i=1:N/length(hypo_lambda)
    x_hypoexp(i) = 0;
    for j=1:length(hypo_lambda)
        x_hypoexp(i) = x_hypoexp(i) - log(u((i-1)*length(hypo_lambda) + j)) / hypo_lambda(j);
    end
end

CDF_hypoexp_empirical = empirical_cdf(x_hypoexp);

figure('Name','Hypo-Exponential Distribution','NumberTitle','off');
plot(CDF_hypoexp_empirical(:,1), CDF_hypoexp_empirical(:,2), ':', 'DisplayName', 'Empirical', 'LineWidth', 2);
hold on;
plot(x, HypoExp_cdf(x, hypo_lambda(1), hypo_lambda(2)), '--', 'DisplayName', 'Exact', 'LineWidth', 2);
hold off;
legend;
xlim([0 25]);
title('Hypo-Exponential');
hold off;

% Hyper-Exponential Distribution
hyper_lambda = [0.5, 0.05];
hyper_p = 0.55;

for i=1:N/length(hyper_lambda)
    if(u((i-1)*length(hyper_lambda) + 1) <= hyper_p)
        x_hyperexp(i) = -log(u((i-1)*length(hyper_lambda) + 2)) / hyper_lambda(1);
    else
        x_hyperexp(i) = -log(u((i-1)*length(hyper_lambda) + 2)) / hyper_lambda(2);
    end
end

CDF_hyperexp_empirical = empirical_cdf(x_hyperexp);

figure('Name','Hyper-Exponential Distribution','NumberTitle','off');
plot(CDF_hyperexp_empirical(:,1), CDF_hyperexp_empirical(:,2), ':', 'DisplayName', 'Empirical', 'LineWidth', 2);
hold on;
plot(x, HyperExp_cdf(x, hyper_lambda(1), hyper_lambda(2), hyper_p), '--', 'DisplayName', 'Exact', 'LineWidth', 2);
legend;
xlim([0 25]);
title('Hyper-Exponential');
hold off;

% Total Costs Computation

tc_exp = total_cost(x_exp);
tc_pareto = total_cost(x_pareto);
tc_erlang = total_cost(x_erlang);
tc_hypoexp = total_cost(x_hypoexp);
tc_hyperexp = total_cost(x_hyperexp);

fprintf(1, 'Total Cost Exponential Distribution: %g\n', tc_exp);
fprintf(1, 'Total Cost Pareto Distribution: %g\n', tc_pareto);
fprintf(1, 'Total Cost Erlang Distribution: %g\n', tc_erlang);
fprintf(1, 'Total Cost Hypo-Exponential Distribution: %g\n', tc_hypoexp);
fprintf(1, 'Total Cost Hyper-Exponential Distribution: %g\n', tc_hyperexp);

function F = total_cost(x)
    F = sum([x(x>10) .* 0.02, x(x<=10) .*0.01]);
end

function F = empirical_cdf(x)
    F = [sort(x); (1:length(x))/length(x)]';
end

function F = Exp_cdf(x, l)
	F = max(0,1 - exp(-l*x));
end

function F = Pareto_cdf(x, alpha, m)
    F = (1 - (m ./ x) .^ alpha) .* (x >= m);
end

function F = Erlang_cdf(x, lambda, k)
    for i=1:length(x)
        CDF_erlang(i) = 0;
        for h=0:k-1
            CDF_erlang(i) = CDF_erlang(i) + exp(-lambda*x(i))*(lambda*x(i))^h / factorial(h);
        end
        CDF_erlang(i) = 1 - CDF_erlang(i);
    end

    F = CDF_erlang;
end

function F = HyperExp_cdf(x, l1, l2, p1)
	F = max(0,1 - p1 * exp(-l1*x) - (1-p1) * exp(-l2*x));
end

function F = HypoExp_cdf(x, l1, l2)
	F = (x>0) .* min(1,max(0,1 - l2/(l2-l1) * exp(-l1*x) + l1/(l2-l1) * exp(-l2*x)));
end