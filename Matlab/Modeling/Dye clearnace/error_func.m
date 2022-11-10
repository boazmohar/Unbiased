
function error_val = error_func(x_1)
global time_h
global conc
syms y(t) x(t) a b c
eqn = [diff(y) == -(1/a)*y+b*x, diff(x) == -(1/c)*x];
V = odeToVectorField(eqn);
M = matlabFunction(V,'vars',{'t','Y','X','a','b', 'c'});
interval = [0 100];
yInit = [1 1];
disp(x_1)
A  = x_1(1);
B = x_1(2);
C = x_1(3);
ySol = ode45(@(t, y) M(t,y,x,A,B,C),interval,yInit);
yValues = deval(ySol,time_h,2);
% figure(1);clf;plot(time_h,yValues, 'r-*')
error_val = sum((( yValues - conc').^2).*time_h*100);
end