clear all;
close all;
clc;

inter_arrivals = [csvread("Trace1.csv"), csvread("Trace2.csv"), csvread("Trace3.csv")];

CDF_plot = [];
pearson_coeff_plot = [];

for i=1:3
    a_i = inter_arrivals(:, i);
    Num = size(a_i,1);

    % Moments: MEAN[dataset ^ k]
    for j=1:4
        moments(j) = sum(a_i.^j)/Num;
        fprintf(1, "%d° moment of Trace %d: %g\n", j, i, moments(j));
    end
    
    % Centered Moments: MEAN[(dataset - mean) ^ k] === starts from the 2nd
    mean = moments(1);
    centered_ia = a_i - mean;
    for j=2:4
        centered_moments(j-1) = sum(centered_ia.^j)/(Num-1);
        if(j==2)
            fprintf(1, "%d° centered moment (Variance) of Trace %d: %g\n", j, i, centered_moments(j-1));
        else
            fprintf(1, "%d° centered moment of Trace %d: %g\n", j, i, centered_moments(j-1));
        end
    end

    %Standardized Moments: MEAN[((dataset - mean)/sigma)^k] === starts from 3rd
    std_deviation = sqrt(centered_moments(1));
    standardized_ia = centered_ia / std_deviation;
    for j=3:4
        standardized_moments(j-2) = sum(standardized_ia.^j)/(Num-1);
        if(j==3)
            fprintf(1, "%d° standardized moment (Skewness) of Trace %d: %g\n", j, i, standardized_moments(j-2));
        else
            fprintf(1, "%d° standardized moment of Trace %d: %g\n", j, i, standardized_moments(j-2));  
        end
    end

    % Standard Deviation, Coefficient of Variation, and Excess Kurtosis
    coeff_variation = std_deviation / mean;
    excess_kurtosis = standardized_moments(2) - 3;
    fprintf(1, "Standard Deviation of Trace %d: %g\n", i, std_deviation);
    fprintf(1, "Coefficient of Variation of Trace %d: %g\n", i, coeff_variation);
    fprintf(1, "Excess Kurtosis of Trace %d: %g\n", i, excess_kurtosis);

    % The median (second), the first and the third quartile. k° Quartile = F^-1(k/100)
    sorted_ia = sortrows(inter_arrivals(:,i));
    for j=1:Num
        P(j) = sum(sorted_ia <= inter_arrivals(j,i)) / Num;
    end
    if(size(P,1) == 1)
        P = P';
    end

    CDF = sortrows([inter_arrivals(:,i), P]);
    CDF_plot = [CDF_plot, CDF];

    first_quartile = max(CDF(CDF(:,2) <= 0.25));
    second_quartile = max(CDF(CDF(:,2) <= 0.50));
    third_quartile = max(CDF(CDF(:,2) <= 0.75));
    fprintf(1, "First Quartile of Trace %d: %g\n", i, first_quartile);
    fprintf(1, "Second Quartile (Median) of Trace %d: %g\n", i, second_quartile);
    fprintf(1, "Third Quartile of Trace %d: %g\n", i, third_quartile);


    % Draw figure with the Pearson Correlation Coefficient for lags m=1 to m=100
    crossCovariance = zeros(100,1);
    for m=1:100
        arg = (inter_arrivals(1:Num-m,i)-mean).*(inter_arrivals(m+1:Num,i)-mean); % NOT ordered column
        crossCovariance(m) = sum(arg)/(Num-m);
    end

    PearsonCorrelationCoefficient = crossCovariance/centered_moments(1);
    pearson_coeff_plot = [pearson_coeff_plot, PearsonCorrelationCoefficient];

    fprintf(1, "===============================\n");
end

% CDFs Plot
x = CDF_plot(:, 1:2:end);
y = CDF_plot(:, 2:2:end);

figure;

hold on;
plot(x(:,1), y(:, 1), 'b', 'LineWidth', 2, 'DisplayName', 'CDF 1');
plot(x(:,2), y(:, 2), 'r', 'LineWidth', 2, 'DisplayName', 'CDF 2');
plot(x(:,3), y(:, 3), 'g', 'LineWidth', 2, 'DisplayName', 'CDF 3');
hold off;

xlabel('x');
ylabel('F(x)');
title('CDF Functions of the datasets');
legend('show');

% Pearson Coefficient Plot
figure;

hold on;
plot(1:100, pearson_coeff_plot(:,1), 'b', 'LineWidth', 2, 'DisplayName', 'Dataset 1');
plot(1:100, pearson_coeff_plot(:,2), 'r', 'LineWidth', 2, 'DisplayName', 'Dataset 2');
plot(1:100, pearson_coeff_plot(:,3), 'g', 'LineWidth', 2, 'DisplayName', 'Dataset 3');
hold off;

xlabel('Lag');
ylabel('Pearson Coefficient');
title('Pearson Coefficients');
legend('show');