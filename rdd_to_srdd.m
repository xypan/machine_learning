cache_sizes = [4096,8192,16384,32768]%,65536];%td:change back
associativities = [2,4,8,16]; %td: change back

t = readtable('LRU_c_4096_a_4_result.txt',...
'Delimiter',' ','ReadVariableNames',false)
[m,n] = size(t); %m is the number of benchmarks
n_training_bench= 20;

benches = table2array(t(:,1))
n_c = length(cache_sizes); %number of cache sizes
n_a = length(associativities); %number of associativities
training_data = []
test_data=[]

%get the rdd
for i = 1:m %td:change back
    filename = strcat(benches(i),'_full_rdd.txt');
    tmp = importdata(char(filename), ':');
    rdd_probs = tmp(:,2); 
    for c = cache_sizes
        for a = associativities %for all the associativity
            srdd = strcat(benches(i),'_srdd_modeled_c_',num2str(c),'_a',num2str(a),'.txt');
            table_srdd = readtable(char(srdd),'Delimiter',' ','ReadVariableNames',false)
            srdd_probs = table2array(table_srdd(:,2))             
            params = horzcat(c,a,transpose(rdd_probs),transpose(srdd_probs));
            if i <= n_training_bench
                training_data = [training_data;params];
            else
                test_data = [test_data; params]     
            end;
         end;
     end;
end;
[n_srd,tmp] = size(srdd_probs)
[tmp,n_params] = size(params)
for i = 1:n_srd %model each of the set reuse distance probability with linear regression
    curr_srd_index = n_params - n_srd+i;
    n_input = n_params - n_srd;
    y = training_data(:,curr_srd_index:curr_srd_index); %the miss ratios
    X = training_data(:,1:n_input);
    b = regress(y,X);
    
    test_X = test_data(:,1:n_input);
    test_y = test_data(:,curr_srd_index);

    abs_error_training_data = mean(abs(X*b - y));
    abs_error_test_data = mean(abs(test_X*b - test_y));
    plot(abs(test_X*b - test_y));
end;