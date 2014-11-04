load carsmall
x1 = Weight;
x2 = Horsepower;    % Contains NaN data
y = MPG;

X = [ones(size(x1)) x1 x2 x1.*x2];
b = regress(y,X)    % Removes NaN data