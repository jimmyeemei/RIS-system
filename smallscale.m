function [Pn,N,tau] = smallscale(LSP,LOS,O2I,flag,N_input)
%% %%%%%%%%%% 小尺度参数的生成(包括簇时延/簇功率) %%%%%%%%%%
%{ 
   大尺度参数(LSP)模块参数传递:
   LSP(1)代表DS
   LSP(2)代表ASD
   LSP(3)代表ASA
   LSP(4)代表K
   LSP(5)代表SF
   LSP(6)代表ZSD
   LSP(7)代表ZSA
%}

%% 传递参数
sigma_DS = LSP(1);
sigma_K = LSP(4);
K_R = db2pow(LSP(4)); 

%% %%%%%%%%%% 参数赋值 %%%%%%%%%%
if (flag == 0)
    if (LOS == 1)
        N = 12;
        Delay_scaling_factor = 2.5;
        Shadow_fade_std = 3;  %dB
    elseif (LOS == 0)
        N = 20;
        Delay_scaling_factor = 2.3;
        Shadow_fade_std = 3;  %dB
    end
    if(O2I == 1)
        N = 12;
        Delay_scaling_factor = 2.2;
        Shadow_fade_std = 4;  %dB
    end
end

if (flag == 1)
    if (LOS == 1)
            N = 12;
            Delay_scaling_factor = 3;
            Shadow_fade_std = 3;  %dB
    elseif (LOS == 0)
            N = 19;
            Delay_scaling_factor = 2.1;
            Shadow_fade_std = 3;  %dB
    end
    if(O2I == 1)
        N = 12;
        Delay_scaling_factor = 2.2;
        Shadow_fade_std = 4;  %dB
    end
end
% 接受自定义簇数
if(N_input ~= 0)
    N = N_input;
end

%% %%%%%%%%%% 生成每个簇的随机时延 %%%%%%%%%%
% 初始化
tau1 = zeros(1,N);
for i = 1:N
    X = rand();                                      % (0,1)均匀分布的随机数
    tau1(i) = -Delay_scaling_factor*sigma_DS*log(X); % 计算每个簇的随机时延
end
min_tau_n1 = min(tau1,[],'all');
tau = sort(tau1 - min_tau_n1);                       % 升序排序

%% %%%%%%%%%% 生成每个簇的功率 %%%%%%%%%%
% 初始化
P1 = zeros(1,N);
Pn = zeros(1,N);
for i = 1:N
    Z = normrnd(0,Shadow_fade_std);
    P1(i) = exp(-tau(i)*(Delay_scaling_factor - 1)/(Delay_scaling_factor*sigma_DS))*...
        10^(-Z/10);
end
% 归一化簇功率
sum_Pn = sum(P1);
for i = 1:N
    Pn(i) = P1(i)/(sum_Pn);
end
% 如果包含LOS路径
if(LOS == 1)
    P_1LOS = K_R/(K_R + 1);
    for i = 1:N
        Pn(i) = 1/(K_R + 1)*Pn(i);
    end
    Pn(1) = Pn(1) + P_1LOS;
end
% 添加补偿系数
D = 0.7705 - 0.0433*sigma_K + 0.0002*sigma_K^2 + 0.000017*sigma_K^3;
if(LOS == 1)
    for i = 1:N
        tau(i) = tau(i)/D;
    end
end

