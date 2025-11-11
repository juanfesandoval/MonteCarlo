%monte carlo integrator, generates random points on a grid, calculates
%points under curve over total points in grid to estimate closed form
%integral. 


% --- User inputs ---
x_min = input('Enter x_min: ');
x_max = input('Enter x_max: ');
n     = input('Enter number of random samples n (e.g., 10000): ');

f_str = input('Enter f(x), e.g., sin(x)+exp(-x/2) or x.^2+1: ','s');

% vectorize operators if user typed ^,*,/ without dots
f_str_vec = regexprep(f_str, '(\^)', '.^');
f_str_vec = regexprep(f_str_vec, '([^\.])\*', '$1.*');
f_str_vec = regexprep(f_str_vec, '([^\.])/',  '$1./');

f = str2func(['@(x) ', f_str_vec]);
%generates random number vectors 
%the rand command gives us a vector consisting of n random numbers between
%0 and 1 (double value type). so for us to get a random value between a
%lower bound and an upper bound, we must multiply the random number between
%0 and 1 by the range and then correct by adding the min value to get a
%value actually in the acceptable range. 
x = x_min+ (x_max-x_min)*rand(n,1);

f_values = f(x); %generate y values 
% so like if x min is 1 and x max is 10, the multiplication gives a random
% number between 0 and 9 and then we correct by adding xmin to get random
% Find approximate min/max over the interval
x_test = linspace(x_min, x_max, 10000);
f_test = f(x_test);
y_min = min(0,min(f_test));
y_max = max(0,max(f_test));
y = y_min+(y_max-y_min)*rand(n,1);

%create your grid of ordered pairs as a matrix
points = [x y];

%now to integrate we will select our function 



in_counter = 0; 

for i = 1:n
    if(f_values(i)>=y(i)&&y(i)>=0&&f_values(i)>=0)
    in_counter = in_counter +1;

    elseif (f_values(i)<=y(i)&&y(i)<=0&&f_values(i)<=0)

    in_counter = in_counter -1 ; 
    end 
end 


integration = (x_max-x_min)*(y_max-y_min)*(in_counter/n); 
fprintf('your approximate closed integral is %.2f\n ',integration);
accurate = integral(@(x) f(x),x_min,x_max);

fprintf('The accurate integral value is %.2f\n', accurate);

% --- Visualization of Monte Carlo sampling ---

% logical arrays for points above/below curve
under = ( (f_values >= y) & (y >= 0) & (f_values >= 0) ) | ...
        ( (f_values <= y) & (y <= 0) & (f_values <= 0) );

% plot the function curve
figure;
hold on;
plot(x_test, f_test, 'k', 'LineWidth', 2);          % function in black
yline(0, '--', 'Color', [0.4 0.4 0.4]);             % x-axis

% plot a small subset of the points so it's visible (10k is too dense)
idx = randperm(n, min(1000, n));                    % pick up to 1000 random points
scatter(x(idx(under(idx))),  y(idx(under(idx))), 8, 'g', 'filled'); % under curve
scatter(x(idx(~under(idx))), y(idx(~under(idx))), 8, 'r', 'filled'); % above curve

xlabel('x');
ylabel('y');
title('Monte Carlo Integration Visualization');
legend('f(x)', 'x-axis', 'Points under curve', 'Points above curve');
axis([x_min x_max y_min y_max]);
grid on;