clear all;
close all;
clc;

s = [csvread("Trace1.csv"), csvread("Trace2.csv")];

for i=1:2
    ServiceTime = s(:,i);
    Num = length(ServiceTime);
    SortedServiceTime = sort(ServiceTime);
    Time = 0:100;
    

    fprintf(1, "=============== TRACE %d ===============\n", i);
    M = zeros(3, 1);
    for j=1:3
        M(j) = sum(ServiceTime .^ j) / Num;
        fprintf(1, "Moment %d of Trace %d: %g\n", j, i, M(j));
    end

    cv = sqrt(M(2)-M(1)^2)/M(1);
    fprintf(1, "Coefficient Of Variation Trace %d: %g\n", i, cv);

    figure('Name', sprintf('Trace %d\n', i), 'NumberTitle','off');
    xlabel('X');
    xlim([0 75]);
    ylabel('CDF(X)');
    hold on;
    
    % EMPIRICAL CDF
    plot(SortedServiceTime, (1:Num)/Num, 'DisplayName','Empirical');

    % DIRECT EXPRESSIONS

    % Uniform Distribution
    a = M(1) - sqrt(12*(M(2)-M(1)^2))/2;
    b = M(1) + sqrt(12*(M(2)-M(1)^2))/2;
    fprintf(1, "Uniform a of Trace %d: %g\n", i, a);
    fprintf(1, "Uniform b of Trace %d: %g\n", i, b);

    plot(Time, Unif_cdf(Time, a, b), 'DisplayName','Uniform');

    % Exponential Distribution
    lambda = 1/M(1);
    fprintf(1, "Exponential Lambda of Trace %d: %g\n", i, lambda);

    plot(Time, Exp_cdf(Time, lambda), 'DisplayName','Exponential');

    % Erlang Distribution
    k = round(M(1)^2 / (M(2)-M(1)^2));
    lambda = k/M(1);
    fprintf(1, "Erlang k of Trace %d: %g\n", i, k);
    fprintf(1, "Erlang Lambda of Trace %d: %g\n", i, lambda);
    if(cv <= 1)
        plot(Time, Erlang_cdf(Time, lambda, k), 'DisplayName','Erlang');
    else
        fprintf(1, "[!!!]: Trace %d cannot fit an Erlang Distribution \n", i);
    end
    
    % METHOD OF MOMENTS
    
    % Weibull Distribution
    options = optimset('Display','off');
    weibull_fun = @(x) [x(1)*gamma(1+1/x(2)) - M(1), x(1)^2*gamma(1+2/x(2)) - M(2)];
    [x, ~, ~] = fsolve(weibull_fun, [1,1], options);
    lambda = x(1);
    k = x(2);
    fprintf(1, "Weibull lambda of Trace %d: %g\n", i, lambda);
    fprintf(1, "Weibull k of Trace %d: %g\n", i, k);
    
    plot(Time, Weibull_cdf(Time, lambda, k), 'DisplayName','Weibull');

    % Pareto Distribution
    options = optimset('Display','off');
    pareto_fun = @(x) [x(1)*x(2)/(x(1)-1) - M(1), x(1)*(x(2)^2)/(x(1)-2) - M(2)];
    [x, ~, ~] = fsolve(pareto_fun, [3,1], options);
    alpha = x(1);
    m = x(2);
    fprintf(1, "Pareto alpha of Trace %d: %g\n", i, alpha);
    fprintf(1, "Pareto m of Trace %d: %g\n", i, m);

    plot(Time, Pareto_cdf(Time, m, alpha), 'DisplayName', 'Pareto');
    
    % MAXIMUM LIKELIHOOD METHOD

    % Hyper-Exponential
    HyperE_values = mle(ServiceTime, 'pdf', @HyperExp_pdf, 'start', [0.8 / M(1), 1.2 / M(1), 0.4], 'LowerBound', [0, 0, 0], 'UpperBound', [Inf, Inf, 1]);
    fprintf(1, "Hyper-Exp Lambda1 of Trace %d: %g\n", i, HyperE_values(1));
    fprintf(1, "Hyper-Exp Lambda2 of Trace %d: %g\n", i, HyperE_values(2));
    fprintf(1, "Hyper-Exp p1 of Trace %d: %g\n", i, HyperE_values(3));
    if(cv >= 1)
        plot(Time, HyperExp_cdf(Time, HyperE_values), 'DisplayName', 'Hyper-Exp');
    else
        fprintf(1, "[!!!]: Trace %d cannot fit an Hyper-Exp Distribution \n", i);
    end

    % Hypo-Exponential
    HypoE_values = mle(ServiceTime, 'pdf', @HypoExp_pdf, 'start', [1 / (0.3*M(1)), 1 / (0.7*M(1))], 'LowerBound', [0, 0], 'UpperBound', [Inf, Inf]);
    fprintf(1, "Hypo-Exp Lambda1 of Trace %d: %g\n", i, HypoE_values(1));
    fprintf(1, "Hypo-Exp Lambda2 of Trace %d: %g\n", i, HypoE_values(2));
    if(cv < 1)
        plot(Time, HypoExp_cdf(Time, HypoE_values), 'DisplayName', 'Hypo-Exp');
    else
        fprintf(1, "[!!!]: Trace %d cannot fit an Hypo-Exp Distribution \n", i);
    end
    legend;
    title('CDF');
    hold off;
end

function F = HypoExp_pdf(x, l1, l2)
	F = (x>0) .* (l1*l2/(l1-l2) * (exp(-l2*x) - exp(-l1*x)));
end

function F = HypoExp_cdf(x, p)
	l1 = p(1);
	l2 = p(2);
	
	F = (x>0) .* min(1,max(0,1 - l2/(l2-l1) * exp(-l1*x) + l1/(l2-l1) * exp(-l2*x)));
end

function F = HyperExp_pdf(x, l1, l2, p1)
	F = (x > 0) .* (p1 * l1 * exp(-l1*x) + (1-p1) * l2 * exp(-l2*x));
end

function F = HyperExp_cdf(x, p)
	l1 = p(1);
	l2 = p(2);
	p1 = p(3);
	
	F = max(0,1 - p1 * exp(-l1*x) - (1-p1) * exp(-l2*x));
end

function F = Unif_cdf(x, a, b)
	F = max(0, min(1, (x>a) .* (x<b) .* (x - a) / (b - a) + (x >= b)));
end

function F = Exp_cdf(x, l)
	F = max(0,1 - exp(-l*x));
end

function F = Erlang_cdf(x, l, k)
    CDF_erlang = zeros(length(x), 1);
    for j=1:length(x)
            CDF_erlang(j) = 0;
            for h=0:k-1
                CDF_erlang(j) = CDF_erlang(j) + exp(-l*x(j))*(l*x(j))^h / factorial(h);
            end
            CDF_erlang(j) = 1 - CDF_erlang(j);
    end
    F = CDF_erlang;
end

function F = Weibull_cdf(x, lambda, k)
    F = (1-exp(-(x/lambda) .^ k)) .* (x >=0);
end

function F = Pareto_cdf(x, m, alpha)
    F = (1 - (m ./ x) .^alpha) .* (x >= m);
end
