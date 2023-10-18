clear all;
clc;
close all;

s = 1;
t = 0;

win = 0;
run = 0;
Tmax = 1000000;

trace = [t, s];

while t < Tmax

    dt = 0;

    if(s==1) % Entrance
        if(rand() < 0.7)
            ns = 2;
        else 
            ns = 3;
        end

    end

    if(s==2) % Going to C1
        if(rand() < 0.8)
            ns = 4;
            dt = erlang_time(1.5/60, 4);
        else 
            ns = 9;
            dt = exp_time(0.5/60);
        end
    end

    if(s==3) % Going to C2
        if(rand() < 0.7)
            ns = 9;
            dt = exp_time(0.25/60);
        else 
            ns = 5;
            dt = uniform_time(3*60, 6*60);
        end
    end

    if(s==4) % C1
        if(rand() < 0.5)
            ns = 6;
        else 
            ns = 7;
        end
        
    end

    if(s==5) % C2
        dt = erlang_time(4/60, 5);
        if(rand() < 0.6)
            ns = 8;
        else 
            ns = 9;
        end
    end

    if(s==6) % C1 Going to C2
        if(rand() < 0.75)
            ns = 9;
            dt = exp_time(0.4/60);
        else 
            ns = 5;
            dt = erlang_time(2/60, 3);
        end
    end  

    if(s==7) % C1 Going to C2
        if(rand() < 0.4)
            ns = 9;
            dt = exp_time(0.2/60);
        else 
            ns = 5;
            dt = exp_time(0.15/60);
        end
    end    

    if(s==8) % WIN
        ns = 1;
        dt = 5*60;
        win = win + 1;
        run = run + 1;
    end

    if(s==9) % LAVA
        ns = 1;
        dt = 5*60;
        run = run + 1;
    end

    t = t + dt;
    s = ns;
end

P_win = win / run;
inter_game_time = Tmax/run;
average_run_time = inter_game_time - 5*60;
throughput = 1/inter_game_time * 3600;

fprintf(1, "#Run: %g\n", run);
fprintf(1, "Probability of Winning: %g\n", P_win);
fprintf(1, "Average Run Time: %g\n", average_run_time);
fprintf(1, "Average Inter Game Time: %g\n", inter_game_time);
fprintf(1, "Throughput of the system: %g\n", throughput);

function F = exp_time(l)
    F = -log(rand())/l;
end

function F = erlang_time(l, k)
        x = 0;
    for j=1:k
        x = x + log(rand());
    end
    F = -x / l;
end

function F = uniform_time(a, b)
    F = a + (b-a) * rand();
end



