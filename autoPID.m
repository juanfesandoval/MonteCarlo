%automatic PID controller - Johnphillip Sandoval

%we will have an automatic PID controller that sweeps through a range of
%gains for each type of control and picks the one that results in the best
%control model 

%we are assuming a simple mass-spring-damper system 
m = 1; 
b = 1; 
k = 1; 
G = tf(1,[m b k]); % we have defined our transfer function for our system

%we are assuming a unit step input because it allows us to test our
%controller simply. 

%range of gain values for each type of control that we will try, basically
%brute force searching
Kp_vals = linspace(0,50,15);
Ki_vals = linspace(0,20,10);
Kd_vals = linspace(0,5,5);

t_final = 10;                    % simulation time for each trial
t = linspace(0, t_final, 1000);  %  time vector

bestJ  = inf;
bestKp = NaN;
bestKi = NaN;
bestKd = NaN;
best_y = [];
best_t = [];



for Kp = Kp_vals 
    for Ki = Ki_vals
        for Kd = Kd_vals 
        C = pid(Kp,Ki,Kd); %this matlab command creates your PID controller
        T_cl = feedback(C*G,1); %this creates your unity closed loop feedback. 

        %create a step response
        [y, t_out] = step(T_cl,t); %simulates response for time step

        %our performance metric will be the integral of error, adds up
        %acculumated abs val error between system value and target

        r = ones(size(t_out));  %unit step input
        e = r - y; %Computes error
        J = trapz(t_out, abs(e)); %computes trapezoidal numerical integration of the absolute value of the error over the time 

        if J < bestJ %if our error is less than the best one so far
            bestJ = J;
            bestKp = Kp;
            bestKi = Ki;
            bestKd = Kd;
            best_y = y;
            best_t = t_out;
        end 
        end 
    end 
end 
fprintf('Best gains found:\n');
fprintf('  Kp = %.3f, Ki = %.3f, Kd = %.3f\n', bestKp, bestKi, bestKd);
fprintf('  Best IAE = %.4f\n', bestJ);


%we can also compare our best controller to a deliberately bad controller
%literally a bad P controller no I or D
% Define a deliberately poor set of gains for comparison
Kp_bad = 2;
Ki_bad = 0;
Kd_bad = 0;

C_bad = pid(Kp_bad, Ki_bad, Kd_bad);
T_bad = feedback(C_bad*G, 1);

[y_bad, t_bad] = step(T_bad, t);

% we can now plot results for comparison 

figure;
plot(best_t, best_y, 'LineWidth', 2); hold on;
plot(t_bad, y_bad, '--', 'LineWidth', 1.5);
yline(1, ':');  % reference
grid on;
xlabel('Time (s)');
ylabel('Output');
title('Closed-Loop Step Response: Auto-Tuned PID vs. Bad PID');
legend('Auto-Tuned PID', 'Bad PID', 'Reference (1)', 'Location', 'Best');