clear all;
clc;
close all;

s = 0;
t = 0;

win = 0;
run = 0;
Rmax = 100000;

trace = [t, s];

rng(0);
while run < Rmax

    dt = 0;

    if(s==0) % Entrance
        if(rand() < 0.7)
            if(rand() < 0.8)
            ns = 1;
            dt = erlang_time(1.5/60, 4);
            else 
            ns = 3;
            dt = exp_time(0.5/60);
            end
        else 
            if(rand() < 0.7)
            ns = 3;
            dt = exp_time(0.25/60);
            else 
            ns = 2;
            dt = uniform_time(3*60, 6*60);
            end
        end
    end

    if(s==1) % C1
        if(rand() < 0.5)
            if(rand() < 0.75)
            ns = 3;
            dt = exp_time(0.4/60);
            else 
            ns = 2;
            dt = erlang_time(2/60, 3);
            end
        else 
            if(rand() < 0.4)
            ns = 3;
            dt = exp_time(0.2/60);
            else 
            ns = 2;
            dt = exp_time(0.15/60);
            end
        end
        
    end

    if(s==2) % C2
        dt = erlang_time(4/60, 5);
        if(rand() < 0.6)
            ns = 4;
        else 
            ns = 3;
        end
    end

    if(s==3) % LAVA
        ns = 0;
        dt = 5*60;
        run = run + 1;
    end

    if(s==4) % EXIT
        ns = 0;
        dt = 5*60;
        win = win + 1;
        run = run + 1;
    end

    t = t + dt;
    s = ns;
end

P_win = win / run;
inter_game_time = t/run;
average_run_time = inter_game_time - 5*60;
throughput = 1/inter_game_time * 3600;

fprintf(1, "#Run: %g\n", run);
fprintf(1, "Winning Probability: %g\n", P_win);
fprintf(1, "Average Game Time: %g min\n", average_run_time / 60);
fprintf(1, "Average Inter Game Time: %g min\n", inter_game_time / 60);
fprintf(1, "Throughput of the system: %g game/hour\n", throughput);

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