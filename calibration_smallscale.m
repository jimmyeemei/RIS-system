function [AS] = calibration_smallscale(theta_nm,N,P_n)
%% %%%%%%%%% 日志:本代码最后修改于20221114 16:03 %%%%%%%%%
%% 循环角度扩展校准计算(3GPP TR 25.996)
temp1 = 0; temp2 = 0;
sum_power = sum(P_n);
delta = linspace(0,360,3600);                       % 角度偏移量(遍历0,2*pi)
theta_nm_mu = zeros(N,20);
sigma_AS = zeros(1,length(delta));

for i = 1:length(delta)

    theta_nm_delta = mod(theta_nm + delta(i) + 180,360) - 180;

    for n = 1:N
        for m = 1:20
            temp1 = temp1 + theta_nm_delta(n,m)*P_n(n)/20;
        end
    end
    %% 式(A-6)
    mu_theta_delta = temp1/sum_power;

    for n = 1:N
        for m = 1:20
            %% 式(A-5)
            theta_nm_mu(n,m) = mod(theta_nm_delta(n,m) - mu_theta_delta + 180,360) - 180;
            temp2 = temp2 + theta_nm_mu(n,m)^2*P_n(n)/20;
        end
    end
    %% 式(A-4)
    sigma_AS(i) = sqrt(temp2/sum_power);
end
AS = min(sigma_AS);
end
