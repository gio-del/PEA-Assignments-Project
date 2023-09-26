t = [csvread("Trace1.csv"), csvread("Trace2.csv"), csvread("Trace3.csv")];

for i=1:3
    interArrival = t(:,2*i-1);
    
    Num = size(interArrival,1);
    %average inter arrival time [s] and the arrival rate [1/s]
    AverageInterArrival = sum(interArrival)/Num;    
    ArrivalRate = 1/AverageInterArrival;
    fprintf(1,"Average Inter Arrival of Trace %d: %g\n", i, AverageInterArrival);
    fprintf(1,"Arrival Rate of Trace %d: %g\n", i, ArrivalRate);

    A(:,1)=0;
    for j=2:Num
        A(j)=A(j-1)+interArrival(j-1);
    end
    if(size(A,1) == 1)
        A = A';
    end
    
    %CompleteTime Comutation
    S = t(:, 2*i); %Service Time
    C(:,1) = 0;
    C(1)= A(1) + S(1);
    for j=2:Num
        C(j) = max(A(j),C(j-1))+ S(j);
    end
    if(size(C,1) == 1)
        C = C';
    end
    
    %Compute Average Reponse Time [s]
    W = C - A;   
    AverageResposeTime = sum(W)/Num;

    %Utilization
    U = ArrivalRate * mean(S);
    fprintf(1,"Utilization of Trace %d: %g\n", i, U);

    %AC matrix
    AC = [A, C];
    nA = size(AC, 1);
    nC = size(AC, 1);
    T = sum(interArrival);

    evs = [AC(:,1), ones(nA, 1), zeros(nA, 4); AC(:,2), -ones(nC,1), zeros(nC, 4)];
    evs = sortrows(evs, 1);
    evs(:,3) = cumsum(evs(:,2));
    evs(1:end-1, 4) = evs(2:end,1) - evs(1:end-1,1);
    evs(:,5) = (evs(:,3) > 0) .* evs(:,4);
    evs(:,6) = evs(:,3) .* evs(:,4);
    
    B = sum(evs(:,5)); % Busy Time

    fprintf(1,"Busy Time of Trace %d: %g\n", i, B);
    fprintf(1, "Total Time of Trace %d: %g\n",i, T);

    frequency_idle = sum(evs(:,3) == 0) / T;
    average_idle_time = (T-B) / sum(evs(:, 3) == 0);

    fprintf(1, "Frequency Idle of Trace %d: %g\n", i, frequency_idle);
    fprintf(1, "Average Idle Time of Trace %d: %g\n", i, average_idle_time);

    fprintf(1,"Average Response Time of Trace %d: %g\n", i, AverageResposeTime);
    fprintf(1,"=================\n");
end