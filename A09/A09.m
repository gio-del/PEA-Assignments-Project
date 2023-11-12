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

rate_scan = 1 / avg_scan;
rate_night_sleep = 1 / avg_night_sleep;
rate_sunny_sleep = 1 / avg_sunny_sleep;
rate_cloudy_sleep = 1 / avg_cloudy_sleep;
rate_cloudy = 1/avg_cloudy;
rate_sunny = 1/avg_sunny;
rate_day = 1/avg_day;

% Correct Utilization
% Probabilities

P_day = avg_day / (avg_day + avg_night);

P_sunny = avg_sunny / (avg_sunny + avg_cloudy);
P_sunny_scan = avg_scan / (avg_scan + avg_sunny_sleep);
P_sunny_sleep = 1 - P_sunny_scan;

P_cloudy = avg_cloudy / (avg_sunny + avg_cloudy);
P_cloudy_scan = avg_scan / (avg_scan + avg_cloudy_sleep);
P_cloudy_sleep = 1 - P_cloudy_scan;

P_night = avg_night / (avg_night + avg_day);
P_night_scan = avg_scan / (avg_scan + avg_night_sleep);
P_night_sleep = 1 - P_night_scan;

fprintf("======== Correct Results Not Using ode45 ========\n");
U = P_day * (P_sunny * P_sunny_scan + P_cloudy * P_cloudy_scan) + P_night * P_night_scan;
Consumption = U * 12 + (1-U) * 0.1;
fprintf(1, "Utilization: %g\n", U);
fprintf(1, "Consumption: %g [W]\n", Consumption);

% Solution using CTMC and ode45
fprintf("================= Solution using CTMC and ode45 ================\n");

p0 = [1 0 0 0 0 0]; % Sunny Scan, Sunny Sleep, Cloudy Scan, Cloudy Sleep, Night Scan, Night Sleep

Q = [-1/2-2/720-2/360, 1/2, 1/360, 1/360, 1/720, 1/720;
    1/3, -1/3-2/360-2/720, 1/360, 1/360, 1/720, 1/720;
    1/180, 1/180, -1/2-2/720-2/180, 1/2, 1/720, 1/720;
    1/180, 1/180, 1/8, -2/180-1/8-2/720, 1/720, 1/720;
    1/720, 0, 1/720, 0, -2/720-1/2, 1/2;
    0, 1/720, 0, 1/720, 1/18, -2/720-1/18;
    ];

tspan = [0 1440]; % Time span in minutes (24 hours)
[t, Sol] = ode45(@(t, x) Q'*x, tspan, p0);

figure('Name','Wildlife Monitoring', 'NumberTitle', 'off');
plot(t, Sol);
xlim([0 360]);
title('Wildlife Monitoring State Probability');
xlabel('Time (minutes)');
ylabel('Probability');
legend('Sunny Scan', 'Sunny Sleep', 'Cloudy Scan', 'Cloudy Sleep', 'Night Scan', 'Night Sleep');

% Utilization
alpha_utilization = [1 0 1 0 1 0];
utilization_scan = Sol(end, :) * alpha_utilization';
U1 = Sol(:,:) * alpha_utilization';

figure('Name','Wildlife Monitoring', 'NumberTitle', 'off');
plot(t, U1);
hold on;

% Power Consumption
alpha_consumption = [12 0.1 12 0.1 12 0.1];
power_consumption = Sol(end, :) * alpha_consumption';
PC1 = Sol(:,:) * alpha_consumption';

plot(t, PC1);
hold on;

% Throughput
X = [0 1 1 1 1 1;
     0 0 0 0 0 0;
     1 1 0 1 1 1;
     0 0 0 0 0 0;
     1 1 1 1 0 1;
     0 0 0 0 0 0];

throughput = sum((Q .* X)') * Sol(end,:)';
X1 = sum((Q .* X)') * Sol(:,:)';

plot(t, X1);
legend("Utilization", "Consumption [W]", "Throughput [Scan/min]");
xlim([0 60]);
xlabel('Time (minutes)');
title('Wildlife Monitoring Metrics');
hold on;

fprintf(1, "Utilization: %g\n", utilization_scan);
fprintf(1, "Average Power Consumption: %g [W]\n", power_consumption);
fprintf(1, "Throughput: %g [Scans/day]\n", throughput * 24 * 60); % convert from Scan/min to Scan/day
fprintf(1, "P_day: %g\n", Sol(end,1)+Sol(end,2)+Sol(end,3)+Sol(end,4))
fprintf(1, "P_night: %g\n", Sol(end,5)+Sol(end,6))