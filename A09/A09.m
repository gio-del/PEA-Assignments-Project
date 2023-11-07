clc;
close all;
clear all;

% Note: Consider all times in minutes
avg_scan = 2;
avg_night_sleep = 18;
avg_sunny_sleep = 3;
avg_cloudy_sleep = 8;
avg_day = 12 * 60;
avg_night = 12 * 60;
avg_cloudy = 3 * 60;
avg_sunny = 6 * 60;

% Parameters
l_scan = 1 / avg_scan;
P_sunny = avg_sunny / (avg_cloudy + avg_sunny); % Probability of being sunny
P_cloudy = avg_cloudy / (avg_cloudy + avg_sunny); % Probability of being cloudy
P_day = avg_day / (avg_day + avg_night); % = 1/2 = Probability_night
P_night = avg_night / (avg_day + avg_night); % = 1/2 = Probability_day

% One of the possible versions: 1 Scan 3 Sleep (Night, Cloudy, Sunny)
avg_night_scan = avg_scan / P_night;
avg_sunny_scan = avg_scan / (P_day * P_sunny);
avg_cloudy_scan = avg_scan / (P_day * P_cloudy);

rate_night_sleep = 1 / avg_night_sleep;
rate_sunny_sleep = 1 / avg_sunny_sleep;
rate_cloudy_sleep = 1 / avg_cloudy_sleep;
rate_night_scan = 1 / avg_night_scan;
rate_sunny_scan = 1 / avg_sunny_scan;
rate_cloudy_scan = 1 / avg_cloudy_scan;
    
p0 = [1 0 0 0]; % Scan, Sleep Night, Sleep Sunny, Sleep Cloudy

Q = [-rate_night_scan-rate_sunny_scan-rate_cloudy_scan, rate_night_scan, rate_sunny_scan, rate_cloudy_scan;
     rate_night_sleep, -rate_night_sleep, 0, 0;
     rate_sunny_sleep, 0, -rate_sunny_sleep, 0;
     rate_cloudy_sleep, 0, 0, -rate_cloudy_sleep
    ];

tspan = [0 1440]; % Time span in minutes (24 hours)
[t, Sol] = ode45(@(t, x) Q'*x, tspan, p0);

figure('Name','Wildlife Monitoring', 'NumberTitle', 'off');
plot(t, Sol);
xlim([0 60]);
title('Wildlife Monitoring State Probability');
xlabel('Time (minutes)');
ylabel('Probability');
legend('Scan', 'Sleep Night', 'Sleep Sunny', 'Sleep Cloudy');

% Utilization
alpha_utilization = [1 0 0 0];
utilization_scan = Sol(end, :) * alpha_utilization';
U1 = Sol(:,:) * alpha_utilization';

figure('Name','Wildlife Monitoring', 'NumberTitle', 'off');
plot(t, U1);
hold on;

% Average Power Consumption
alpha_consumption = [12 0.1 0.1 0.1];
consumption = Sol(end, :) * alpha_consumption';
PC1 = Sol(:,:) * alpha_consumption';

plot(t, PC1);
hold on;

% Throughput
X = [0 0 0 0;
     1 0 0 0;
     1 0 0 0;
     1 0 0 0;];

throughput = sum((Q .* X)') * Sol(end,:)';
X1 = sum((Q .* X)') * Sol(:,:)';

plot(t, X1);
legend("Utilization", "Consumption [W]", "Throughput [Scan/min]");
xlim([0 60]);
title('Wildlife Monitoring Metrics');
hold on;

fprintf(1, "Utilization: %g\n", utilization_scan);
fprintf(1, "Average Power Consumption: %g\n", consumption);
fprintf(1, "Throughput: %g\n", throughput * 1440); % convert from Scan/min to Scan/day