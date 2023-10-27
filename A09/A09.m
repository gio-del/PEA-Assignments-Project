clear all;
close all;
clc;

l_scan = 1 / (2 / 60);
l_n_sleep = 1 / (18 / 60);
l_s_sleep = 1 / (3 / 60);
l_c_sleep = 1 / (8 / 60);
l_night_day = 1 / 12;
l_c_to_s = 1 / 3;
l_s_to_c = 1 / 6;

Q = [-l_c_to_s-l_scan-l_night_day, l_c_to_s, l_scan, l_night_day; % CLOUDY SCAN
     l_s_to_c, -l_s_to_c-l_scan-l_night_day, l_scan, l_night_day; % SUNNY SCAN
     l_c_sleep, l_s_sleep, -l_c_sleep-l_s_sleep-l_n_sleep, l_n_sleep; % SLEEP
     l_night_day, l_night_day, l_scan, -l_night_day-l_night_day-l_scan]; % NIGHT SCAN

p0 = [0.5, 0.5, 0, 0];


[t, Sol] = ode45(@(t,x) Q'*x, [0 1], p0');

plot(t, Sol, "-");
legend("Cloudy Scan", "Sunny Scan", "Sleep", "Night Scan");

% Utilization
alpha_utilization = [1,1,0,1];
utilization = Sol(end,:) * alpha_utilization';
U1 = Sol(:,:) * alpha_utilization';

figure;
plot(t, U1);
hold on;

% Power Consumption
alpha_consumption = [12, 12, 0.1, 12];
consumption = Sol(end, :) * alpha_consumption';
PC1 = Sol(:,:) * alpha_consumption';

plot(t, PC1);
hold on;

% Throughput
X = [0, 0, 1, 0;
    0, 0, 1, 0;
    0, 0, 1, 0;
    0, 0, 1, 0;];

throughput = sum((Q .* X)') * Sol(end,:)';
X1 = sum((Q .* X)') * Sol(:,:)';

plot(t, X1);
legend("Utilization", "Consumption", "Throughput");
hold on;
