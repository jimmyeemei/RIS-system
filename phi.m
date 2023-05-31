function [phi_AOA,phi_AOD,theta_ZOA,theta_ZOD,phi_nm_AOA,phi_nm_AOD,...
    theta_nm_ZOA,theta_nm_ZOD] = phi(fc,N,M,d2,h_UT,h_BS,LOS,O2I,LSP,Pn,...
    LOS_AOA,LOS_AOD,LOS_ZOA,LOS_ZOD)
%% %%%%%%%%%% 簇内子径角度生成(生成簇n中每个子径m对应的4个角度) %%%%%%%%%%
% 注fc的单位为GHz
fc = fc/10^9;
if(O2I == 1)
    if(LOS == 1)
        O2I_LOS = 1;
    else
        O2I_LOS = 0;
    end
else
    O2I_LOS = NaN;
end

% 簇数
clusnum = N;
% 子径数
raynum = M;
% 缩放因子查表
[C_phi_NLOS,C_theta_NLOS,alpha_m] = Init_number;
% 参数数值查表
[c_ASA,c_ASD,c_ZSA,mu_lgZSD,~,~] = Init_parameter_phi(h_UT,h_BS,d2,LOS,O2I_LOS,flag);
% 莱斯因子dB值
sigma_K = LSP(4);

% 初始化
phi_AOA = zeros(1,N); phi_AOD = zeros(1,N);
theta_ZOA = zeros(1,N); theta_ZOD = zeros(1,N);
phi_nm_AOA = zeros(N,raynum); phi_nm_AOD = zeros(N,raynum);
theta_nm_ZOA = zeros(N,raynum); theta_nm_ZOD = zeros(N,raynum);

%% C_phi和C_theta的计算
if(LOS==1)
    C_ALOS = C_phi_NLOS(N)*(1.1035 - 0.028*sigma_K - 0.002*sigma_K^2 + 0.0001*sigma_K^3);      % 式(7.5-10)
    C_ZLOS = C_theta_NLOS(N)*(1.3086 + 0.0339*sigma_K - 0.0077*sigma_K^2 + 0.0002*sigma_K^3);  % 式(7.5-15)
    C_phi = C_ALOS;
    C_theta = C_ZLOS;
else
    C_phi = C_phi_NLOS(N);
    C_theta = C_theta_NLOS(N);
end
max_Pn = max(Pn); % 功率的最大值

%% 式(7.5-9)
p_AOA1 = (2*(LSP(3)/1.4)*sqrt(-log(Pn/max_Pn)))/C_theta; %生成每个簇的AOA
p_AOD1 = (2*(LSP(2)/1.4)*sqrt(-log(Pn/max_Pn)))/C_theta; %生成每个簇的AOD

%% 式(7.5-14)
theta_ZOA1 = -(LSP(7)*log(Pn/max_Pn))/C_phi; %生成每个簇的ZOA
theta_ZOD1 = -(LSP(6)*log(Pn/max_Pn))/C_phi; %生成每个簇的ZOD

%% %%%%%%%%%% 随机化每个簇的AOA 式(7.5-11) %%%%%%%%%%
%% NLOS情形
for n = 1:clusnum
    X = randsrc();
    sigma = LSP(3)/7;
    Y = normrnd(0,sigma);
    phi_AOA(n) = X*p_AOA1(n) + Y + LOS_AOA;
end
%% LOS情形
if(LOS == 1)
    phi_AOA = phi_AOA - (phi_AOA(1) - LOS_AOA);
end

%% %%%%%%%%%% 随机化每个簇的AOD(生成过程同AOA) %%%%%%%%%%
%% NLOS情形
for n = 1:clusnum
    X = randsrc();
    sigma = LSP(2)/7;
    Y = normrnd(0,sigma);
    phi_AOD(n) = X*p_AOD1(n) + Y + LOS_AOD;
end
%% LOS情形
if(LOS == 1)
    %% LOS情形
    phi_AOD = phi_AOD - (phi_AOD(1) - LOS_AOD);
end

%% %%%%%%%%%% 随机化每个簇的ZOA 式(7.5-16) %%%%%%%%%%
%% NLOS情形
for n = 1:clusnum
    X = randsrc();
    sigma = LSP(7)/7;
    Y = normrnd(0,sigma);
    if(O2I == 1)
        theta_ZOA(n)= X*theta_ZOA1(n) + Y + 90;
    else
        theta_ZOA(n) = X*theta_ZOA1(n) + Y + LOS_ZOA; % 属于otherwise情形
    end
end
%% LOS情形
if(LOS == 1)
    theta_ZOA = theta_ZOA - (theta_ZOA(1) - LOS_ZOA);
end

%% %%%%%%%%%% 随机化每个簇的ZOD(生成过程同ZOA) %%%%%%%%%%
afc = 0.208*log10(fc) - 0.782;
bfc = 25;
cfc = -0.13*log10(fc) + 2.03;
efc = 7.66*log10(fc) - 5.96;
temp = max(bfc,d2);
u_ZOD = efc - 10^(afc*log10(temp) + cfc - 0.07*(h_UT - 1.5));
%% NLOS情形 式(7.5-19)
for n = 1:clusnum
    X = randsrc();
    sigma = LSP(6)/7;
    Y = normrnd(0,sigma);
    theta_ZOD(n) = X*theta_ZOD1(n) + Y + LOS_ZOD + u_ZOD;
end
%% LOS情形 式(7.5-20)
if(LOS == 1)
    theta_ZOD = theta_ZOD - (theta_ZOD(1) - LOS_ZOD);
end

%% %%%%%%%%%% 添加角度偏移量生成每个子径的角度 %%%%%%%%%%
for n = 1:clusnum
    for m = 1:raynum
        a = alpha_m(m);
        phi_nm_AOA(n,m) = phi_AOA(n) + c_ASA*a;
        phi_nm_AOD(n,m) = phi_AOD(n) + c_ASD*a;
        theta_nm_ZOA(n,m) = theta_ZOA(n) + c_ZSA*a;
        theta_nm_ZOD(n,m) = theta_ZOD(n) + (3/8)*(10^mu_lgZSD)*a;
    end
end

%% %%%%%%%%%% 角度映射 %%%%%%%%%%
%% 首先将ZOA/ZOD映射到[0,360]区间内,将AOA/AOD映射到[-360,360]区间内
for n = 1:clusnum
    for m = 1:raynum
        if(phi_nm_AOA(n,m) > 0)
            phi_nm_AOA(n,m) = mod(phi_nm_AOA(n,m),360);
        else
            phi_nm_AOA(n,m) = -mod(phi_nm_AOA(n,m),360);
        end
        if(phi_nm_AOD(n,m) > 0)
            phi_nm_AOD(n,m) = mod(phi_nm_AOD(n,m),360);
        else
            phi_nm_AOD(n,m) = -mod(phi_nm_AOD(n,m),360);
        end
%         phi_nm_AOA(n,m) = mod(phi_nm_AOA(n,m),360);
%         phi_nm_AOD(n,m) = mod(phi_nm_AOD(n,m),360);
        theta_nm_ZOA(n,m) = mod(theta_nm_ZOA(n,m),360);
        theta_nm_ZOD(n,m) = mod(theta_nm_ZOD(n,m),360);
    end
end
%% 接着将ZOA/ZOD映射到[0,180]区间内，将AOA/AOD映射到[-180,180]区间内
for n = 1:clusnum
    for m = 1:raynum
        if(phi_nm_AOA(n,m) > 180)
            phi_nm_AOA(n,m) = 360 - phi_nm_AOA(n,m);
        elseif(phi_nm_AOA(n,m) < -180)
            phi_nm_AOA(n,m) = -360 - phi_nm_AOA(n,m);
        end
        if(phi_nm_AOD(n,m) > 180)
            phi_nm_AOD(n,m) = 360 - phi_nm_AOD(n,m);
        elseif(phi_nm_AOD(n,m) < -180)
            phi_nm_AOD(n,m) = -360 - phi_nm_AOD(n,m);
        end
        if(theta_nm_ZOA(n,m) > 180)
            theta_nm_ZOA(n,m) = 360 - theta_nm_ZOA(n,m);
        end
        if(theta_nm_ZOD(n,m) > 180)
            theta_nm_ZOD(n,m) = 360 - theta_nm_ZOD(n,m);
        end
    end
end

