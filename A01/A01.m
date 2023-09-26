clear all;

% ===================== File Parsing and Creation of AC Table =====================

file = readlines("barrier.log");
input = cell(2000,2);
first_string = string(strsplit(file{1},"][")).replace("[", "");
first_datetime =  datetime(first_string{1}, "InputFormat", 'uuuu:DDD:HH:mm:ss:S');

for i=1:numel(file)
    splitStr = strsplit(file{i}, "][");
    input{i, 1} = milliseconds(datetime(string(splitStr{1}).replace("[", ""), 'InputFormat', 'uuuu:DDD:HH:mm:ss:S') - first_datetime);
    input{i, 2} = string(splitStr{2}).replace("]", "");
end

AC = zeros(1000, 2);
j = 1;
k = 1;

for i=1:numel(file)
    if(string(input(i,2)) == "_IN_")
        AC(j,1) = input{i,1};
        j = j + 1;
    else
        AC(k,2) = input{i,1};
        k = k + 1;
    end
end

% ============================== Metrics Evaluation ==============================

nA = length(AC(:,1));
nC = length(AC(:,2));

T = (AC(nC, 2) - AC(1,1)) / 1000;

lambda = nA / T; % Arrival Rate
X = nC / T; % Throughput

Rt = (AC(:, 2) - AC(:, 1)) / 1000;
W = sum(Rt);

R = W / nC; % Average Response Time
N = W / T; % Number Of Jobs

a_i = [AC(2:end,1) - AC(1:end-1,1); AC(end,2) - AC(end,1)]; % Inter-arrival times
ait = mean(a_i) / 1000; % Average inter-arrival Time

PA_less_1_min = sum(a_i < 60 * 1000) / length(a_i);

evs = [AC(:,1), ones(nA, 1), zeros(nA, 4); AC(:,2), -ones(nC,1), zeros(nC, 4)];
evs = sortrows(evs, 1);
evs(:,3) = cumsum(evs(:,2));
evs(1:end-1, 4) = evs(2:end,1) - evs(1:end-1,1);
evs(:,5) = (evs(:,3) > 0) .* evs(:,4);
evs(:,6) = evs(:,3) .* evs(:,4);

B = sum(evs(:,5)) / 1000; % Busy Time

U = B/T; % Utilization
S = B/nC; % Average Service Time

P_0 = sum((evs(:,3) == 0) .* evs(:,4)) / (T * 1000); % 0 jobs in queue
P_1 = sum((evs(:,3) == 1) .* evs(:,4)) / (T * 1000); % 1 job in queue
P_2 = sum((evs(:,3) == 2) .* evs(:,4)) / (T * 1000); % 2 jobs in queue

PR_less_30_sec = sum(Rt < 30) / nC;
PR_less_3_min = sum(Rt < 180) / nC;
PR_more_1_min = sum(Rt > 60) / nC;

s_i = [AC(1,2); AC(2:end,2) - max(AC(2:end,1), AC(1:end-1,2))];
PS_more_1_min = sum(s_i > 60 * 1000) / nC;

fprintf("Arrival Rate: %f, Throughput: %f\n", lambda, X);
fprintf("Average inter-arrival Time: %f\n", ait);
fprintf("Utilization: %f\n", U);
fprintf("Average Service Time: %f\n", S);
fprintf("Average Number of Jobs: %f\n", N);
fprintf("Average Response Time: %f\n", R);
fprintf("P(0 Jobs in Queue): %f\n", P_0);
fprintf("P(1 Jobs in Queue): %f\n", P_1);
fprintf("P(2 Jobs in Queue): %f\n", P_2);
fprintf("P(R < 30s): %f\n", PR_less_30_sec);
fprintf("P(R < 3min): %f\n", PR_less_3_min);
fprintf("P(S > 1min): %f\n", PS_more_1_min);
fprintf("P(inter-arrival time < 1min): %f\n", PA_less_1_min);