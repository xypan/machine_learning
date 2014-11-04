load('flu');
Y = double(flu(:,2:end-1));
[n,d] = size(Y);
x = flu.WtdILI;

%plot the data
figure;
regions = flu.Properties.VarNames(2:end-1);
plot(x,Y,'x')
legend(regions,'Location','NorthWest')

X = cell(n,1);
for i=1:n
		X{i} = [eye(d) repmat(x(i),d,1)];
end
[beta,Sigma] = mvregress(X,Y);

%plot the regression models
B = [beta(1:d)';repmat(beta(end),1,d)];
xx = linspace(.5,3.5)';
fits = [ones(size(xx)),xx]*B;

figure;
h = plot(x,Y,'x',xx,fits,'-');
for i = 1:d
	set(h(d+i),'color',get(h(i),'color'));
end
legend(regions,'Location','NorthWest');