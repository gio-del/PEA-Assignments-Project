clear all;
close all;
clc;

l_to_m = 0.33;
m_to_l = 0.6;
m_to_h = 0.4;
h_to_m = 1;
all_to_down = 0.05;

d_to_l = 0.6 * 6;
d_to_m = 0.3 * 6;
d_to_h = 0.1 * 6;

Q = [-l_to_m-all_to_down,  l_to_m  ,  0  ,  all_to_down;
        m_to_l ,-m_to_l-m_to_h-all_to_down,   m_to_h , all_to_down;
        0 ,   h_to_m  ,-h_to_m-all_to_down, all_to_down;
         d_to_l , d_to_m  , d_to_h  ,-d_to_l-d_to_m-d_to_h];

% Start from Medium State
p0 = [0, 1, 0, 0];

[t, Sol] = ode45(@(t,x) Q'*x, [0 8], p0');

figure('Name', 'Evolution from Medium State', 'NumberTitle', 'off');
plot(t, Sol, "-");
title('Evolution from Medium State')
xlabel('Time [h]');
ylabel('Probability')
legend("Low","Medium","High","Down")

% Start from Down State
p0 = [0, 0, 0, 1];

[t, Sol] = ode45(@(t,x) Q'*x, [0 8], p0');

figure('Name', 'Evolution from Down State', 'NumberTitle', 'off');
plot(t, Sol, "-");
title('Evolution from Down State')
xlabel('Time [h]');
ylabel('Probability')
legend("Low","Medium","High","Down")