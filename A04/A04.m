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
    for j=1:3
        M(j) = sum(ServiceTime .^ j) / Num;
        fprintf(1, "Moment %d of Trace %d: %g\n", j, i, M(j));
    end

    cv = sqrt(M(2)-M(1)^2)/M(1);
    fprintf(1, "Coefficient Of Variation Trace %d: %g\n", i, cv);

    figure('Name', sprintf('Trace %d\n', i), 'NumberTitle','off');
    xlabel('X');
    xlim([0 100]);
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

    for j=1:Num
        if(SortedServiceTime(j) <= a)
            CDF_uniform(j) = 0;
        elseif(SortedServiceTime(j) > b)
            CDF_uniform(j) = 1;
        else CDF_uniform(j) = (SortedServiceTime(j)-a)/(b-a);
        end
    end
    plot(SortedServiceTime, CDF_uniform, 'DisplayName','Uniform');

    % Exponential Distribution
    lambda = 1/M(1);
    fprintf(1, "Exponential Lambda of Trace %d: %g\n", i, lambda);
    CDF_exponential = 1 - exp(-lambda .* Time);
    plot(Time, CDF_exponential, 'DisplayName','Exponential');

    % Erlang Distribution
    if(cv <= 1)
        k = round(M(1)^2 / (M(2)-M(1)^2));
        lambda = k/M(1);
        fprintf(1, "Erlang k of Trace %d: %g\n", i, k);
        fprintf(1, "Erlang Lambda of Trace %d: %g\n", i, lambda);
        for j=1:Num
            CDF_erlang(j) = 0;
            for h=0:k-1
                CDF_erlang(j) = CDF_erlang(j) + exp(-lambda*SortedServiceTime(j))*(lambda*SortedServiceTime(j))^h / factorial(h);
            end
            CDF_erlang(j) = 1 - CDF_erlang(j);
        end
        plot(SortedServiceTime, CDF_erlang, 'DisplayName','Erlang');
    else
        fprintf(1, "Trace %d cannot fit an Erlang Distribution \n", i);
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
    CDF_weibull = 1-exp(-(Time/lambda).^k);
    plot(Time, CDF_weibull, 'DisplayName','Weibull');

    % Pareto Distribution
    options = optimset('Display','off');
    pareto_fun = @(x) [x(1)*x(2)/(x(1)-1) - M(1), x(1)*(x(2)^2)/(x(1)-2) - M(2)];
    [x, ~, ~] = fsolve(pareto_fun, [3,1], options);
    alpha = x(1);
    m = x(2);
    fprintf(1, "Pareto alpha of Trace %d: %g\n", i, alpha);
    fprintf(1, "Pareto m of Trace %d: %g\n", i, m);
    CDF_pareto = (1 - (m ./ Time) .^alpha) .* (Time >= m);
    plot(Time, CDF_pareto, 'DisplayName', 'Pareto');
    
    legend;
    title('CDF')
    
    % MAXIMUM LIKELIHOOD METHOD

    % Hyper-Exponential
    if(cv >= 1)
        HyperE_values = mle(ServiceTime, 'pdf', @HyperExp_pdf, 'start', [0.5, 0.5, 0.5], 'LowerBound', [0, 0, 0], 'UpperBound', [Inf, Inf, 1]);
        fprintf(1, "Hyper-Exp Lambda1 of Trace %d: %g\n", i, HyperE_values(1));
        fprintf(1, "Hyper-Exp Lambda2 of Trace %d: %g\n", i, HyperE_values(2));
        fprintf(1, "Hyper-Exp p1 of Trace %d: %g\n", i, HyperE_values(3));
        plot(Time, HyperExp_cdf(Time, HyperE_values), 'DisplayName', 'Hyper-Exp');
    else
        fprintf(1, "Trace %d cannot fit an Hyper-Exp Distribution \n", i);
    end
    % Hypo-Exponential
    if(cv < 1)
        HypoE_values = mle(ServiceTime, 'pdf', @HypoExp_pdf, 'start', [0.5, 1], 'LowerBound', [0, 0], 'UpperBound', [Inf, Inf]);
        fprintf(1, "Hypo-Exp Lambda1 of Trace %d: %g\n", i, HypoE_values(1));
        fprintf(1, "Hypo-Exp Lambda2 of Trace %d: %g\n", i, HypoE_values(2));
        plot(Time, HypoExp_cdf(Time, HypoE_values), 'DisplayName', 'Hypo-Exp');
    else
        fprintf(1, "Trace %d cannot fit an Hypo-Exp Distribution \n", i);
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


