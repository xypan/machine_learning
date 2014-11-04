cache_sizes = [4096,8192,16384,32768]%,65536];%td:change back
associativities = [2,4,8,16]; %td: change back

t = readtable('LRU_c_4096_a_4_result.txt',...
'Delimiter',' ','ReadVariableNames',false)
[m,n] = size(t); %m is the number of benchmarks
n_training_bench = 20;
max_rd = 300;

benches = table2array(t(:,1))
n_c = length(cache_sizes); %number of cache sizes
n_a = length(associativities); %number of associativities
rdd_mean_std = zeros(m,2); %reuse distance distribution's mean and standard deviation
rdd = zeros(m,max_rd+2)
%get the rdd
for i = 1:m
    filename = strcat(benches(i),'_full_rdd.txt');
    tmp = importdata(char(filename), ':');
    probs = tmp(:,2); 
    rdd(i,:) = probs;
    rdd_mean_std(i,1) = mean(probs);
    rdd_mean_std(i,2) = std (probs);
end;

training_data = [];
test_data = [];
for c = cache_sizes
    for a = associativities %for all the associativity
        filename = strcat('LRU_c_',num2str(c),'_a_',num2str(a),'_result.txt');
        t = readtable(strcat(filename),'Delimiter',' ','ReadVariableNames',false)
        miss_ratios = table2array(t(:,2)) %the second column of the table are the miss ratios
        for i = 1:n_training_bench,
            params = horzcat(c,a,rdd(i,:))
            %training_data = [training_data;c,a,rdd_mean_std(i,1),rdd_mean_std(i,2),miss_ratios(i)];
            training_data = [training_data; params, miss_ratios(i)];
        end;
        for j= n_training_bench+1:m, %the test data
            params = horzcat(c,a,rdd(j,:))
            test_data = [test_data; params, miss_ratios(j)]
             %test_data = [test_data; c,a,rdd_mean_std(j,1),rdd_mean_std(j,2),miss_ratios(j)]
        end;
    end;
end;
y = training_data(:,max_rd+5); %the miss ratios
X = training_data(:,1:max_rd+4);
b = regress(y,X)

test_X = test_data(:,1:max_rd+4)
test_y = test_data(:,max_rd+5)

%plot(abs(test_X*b - test_y)/test_y)
abs_error_training_data = mean(abs(X*b - y))
plot(abs(test_X*b - test_y))
abs_error = mean(abs(test_X*b - test_y))

