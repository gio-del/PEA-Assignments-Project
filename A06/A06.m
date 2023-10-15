clear all;
clc;
close all;

K0 = 100;
maxK = 10000;
M = 1000;
DK = 20;
MaxRelErr = 0.04;

gam = 0.95;

for scenario=1:2
    fprintf(1, "============ SCENARIO %d ============\n", scenario);
    if(scenario==1)
        arrivalRnd = @() initInterArrival(scenario, [0.02 0.2 0.1]);
        serviceRnd = @() initService(scenario, [10 1.5]);
    else
        arrivalRnd = @() initInterArrival(scenario, 0.1);
        serviceRnd = @() initService(scenario, [5 10]);
    end

    d_gamma = norminv((1+gam)/2);
    
    K = K0;
    
    tA = 0;
    tC = 0;
    
    U = 0;
    U2 = 0;
    R = 0;
    R2 = 0;
    N = 0;
    N2 = 0;
    X = 0;
    X2 = 0;

    newIters = K;
    
    while K < maxK
	    for i = 1:newIters
		    Bi = 0;
		    Wi = 0;
		    tA0 = tA;
	    
		    for j = 1:M
			    a_ji = arrivalRnd();
			    s_ji = serviceRnd();
			    
			    tC = max(tA, tC) + s_ji;
			    ri = tC - tA;
			    Rd((i-1)*M+j,1) = ri;
	    
			    tA = tA + a_ji;
			    
			    Bi = Bi + s_ji;
			    
			    Wi = Wi + ri;
		    end
		    
		    Ri = Wi / M;
		    R = R + Ri;
		    R2 = R2 + Ri^2;
		    
		    Ti = tC - tA0;
            
		    Ui = Bi / Ti;
		    U = U + Ui;
		    U2 = U2 + Ui^2;

            Ni = Wi / Ti;
            N = N + Ni;
            N2 = N2 + Ni^2;

            Xi = M / Ti;
            X = X + Xi;
            X2 = X2 + Xi^2;
	    end
	    
	    Rm = R / K; %average response time
	    Rs = sqrt((R2 - R^2/K)/(K-1));
	    CiR = [Rm - d_gamma * Rs / sqrt(K), Rm + d_gamma * Rs / sqrt(K)];
	    errR = 2 * d_gamma * Rs / sqrt(K) / Rm;

        Rv = R2 / K - Rm^2;
        Rsv = sqrt((R2 - R^2/K)/(K-1));
        CiRv = [Rv - d_gamma * Rsv / sqrt(K), Rv + d_gamma * Rsv / sqrt(K)];
        errRv = 2 * d_gamma * Rsv / sqrt(K) / Rv;   
	    
	    Um = U / K; %utilization
	    Us = sqrt((U2 - U^2/K)/(K-1));
	    CiU = [Um - d_gamma * Us / sqrt(K), Um + d_gamma * Us / sqrt(K)];
	    errU = 2 * d_gamma * Us / sqrt(K) / Um;

        Nm = N / K; %average number of jobs
        Ns = sqrt((N2 - N^2/K)/(K-1));
        CiN = [Nm - d_gamma * Ns / sqrt(K), Nm + d_gamma * Ns / sqrt(K)];
        errN = 2 * d_gamma * Ns / sqrt(K) / Nm;

        Xm = X / K; %average throughput
        Xs = sqrt((X2 - X^2/K)/(K-1));
        CiX = [Xm - d_gamma * Xs / sqrt(K), Xm + d_gamma * Xs / sqrt(K)];
        errX = 2 * d_gamma * Xs / sqrt(K) / Xm;
	    
	    if errR < MaxRelErr && errU < MaxRelErr && errN < MaxRelErr && errX < MaxRelErr && errRv < MaxRelErr
		    break;
	    else
		    K = K + DK;
		    newIters = DK;
	    end
    end
    
    if errR < MaxRelErr && errU < MaxRelErr && errN < MaxRelErr && errX < MaxRelErr && errRv < MaxRelErr
	    fprintf(1, "Maximum Relative Error reached in %d Iterations\n", K);
    else
	    fprintf(1, "Maximum Relative Error NOT REACHED in %d Iterations\n", K);
    end	
    
    fprintf(1, "Utilization in [%g, %g], with %g confidence. Relative Error: %g\n", CiU(1,1), CiU(1,2), gam, errU);
    fprintf(1, "Throughput in [%g, %g], with %g confidence. Relative Error: %g\n", CiX(1,1), CiX(1,2), gam, errR);
    fprintf(1, "Average #jobs in [%g, %g], with %g confidence. Relative Error: %g\n", CiN(1,1), CiN(1,2), gam, errR);
    fprintf(1, "Average Resp. Time in [%g, %g], with %g confidence. Relative Error: %g\n", CiR(1,1), CiR(1,2), gam, errR);
    fprintf(1, "Variance of Resp. Time in [%g, %g], with %g confidence. Relative Error: %g\n", CiRv(1,1), CiRv(1,2), gam, errRv);
end

function F = initInterArrival(i, p)
    if (i==1)
        % Two stages hyper-exponential distribution with: l1 = 0.02, l2 = 0.2, p1 = 0.1
        l1 = p(1);
        l2 = p(2);
        p1 = p(3);
        if(rand > p1)
            inter_arrivals = -log(rand()) / l2;
        else 
            inter_arrivals = -log(rand()) / l1;
        end
    else
        % Exponential with: l = 0.1
        l = p(1);
        inter_arrivals = -log(rand()) / l;
    end
    F = inter_arrivals;
end

function F = initService(i, p)
    if (i==1)
        % Erlang with: k = 10, l = 1.5
        k = p(1);
        l = p(2);
        service_time = 0;
        for h=1:k
            service_time = service_time - log(rand());
        end
        service_time = service_time / l;
        
    else
        % Uniform with: a = 5, b = 10
        a = p(1);
        b = p(2);
        service_time = a + (b-a) .* rand();
    end
    F = service_time;
end
