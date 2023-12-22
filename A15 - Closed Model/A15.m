clc;
close all;
clear all;

N = 80;

Sk = [40*1000 50 2 80 80 120] / 1000; % Terminals, AppServer, StorageCtrl, DBMS, Disk1, Disk2

l = [1 0 0 0 0 0];
P_0 = [ 0 1 0 0 0 0;
        0 0 0.4 0.5 0 0;
        0 0 0 0 0.6 0.4;
        0 1 0 0 0 0;
        0 1 0 0 0 0;
        0 1 0 0 0 0
     ];

Vk = l / (eye(6) - P_0);
Dk = Vk .* Sk;

Nk = [0 0 0 0 0];
Rk = [0 0 0 0 0];
for i=1:N
    Rk = Dk(2:end) .* (1+Nk); % Queueing Centers

    X = i / (Sk(1) + sum(Rk));

    Nk = X .* Rk;
end

fprintf(1, "Throughput of the system: %g\n", X);
fprintf(1, "Average Response Time of the System: %g\n", sum(Rk));
Uk = Dk .* X;
fprintf(1, "Utilization AppServer: %g\n", Uk(2));
fprintf(1, "Utilization StorageCtrl: %g\n", Uk(3));
fprintf(1, "Utilization DBMS: %g\n", Uk(4));
fprintf(1, "Utilization Disk 1: %g\n", Uk(5));
fprintf(1, "Utilization Disk 2: %g\n", Uk(6));

