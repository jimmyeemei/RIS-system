function [Pn,N,tau] = smallscale(LSP,LOS,O2I,flag,N_input)
%% %%%%%%%%%% С�߶Ȳ���������(������ʱ��/�ع���) %%%%%%%%%%
%{ 
   ��߶Ȳ���(LSP)ģ���������:
   LSP(1)����DS
   LSP(2)����ASD
   LSP(3)����ASA
   LSP(4)����K
   LSP(5)����SF
   LSP(6)����ZSD
   LSP(7)����ZSA
%}

%% ���ݲ���
sigma_DS = LSP(1);
sigma_K = LSP(4);
K_R = db2pow(LSP(4)); 

%% %%%%%%%%%% ������ֵ %%%%%%%%%%
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
% �����Զ������
if(N_input ~= 0)
    N = N_input;
end

%% %%%%%%%%%% ����ÿ���ص����ʱ�� %%%%%%%%%%
% ��ʼ��
tau1 = zeros(1,N);
for i = 1:N
    X = rand();                                      % (0,1)���ȷֲ��������
    tau1(i) = -Delay_scaling_factor*sigma_DS*log(X); % ����ÿ���ص����ʱ��
end
min_tau_n1 = min(tau1,[],'all');
tau = sort(tau1 - min_tau_n1);                       % ��������

%% %%%%%%%%%% ����ÿ���صĹ��� %%%%%%%%%%
% ��ʼ��
P1 = zeros(1,N);
Pn = zeros(1,N);
for i = 1:N
    Z = normrnd(0,Shadow_fade_std);
    P1(i) = exp(-tau(i)*(Delay_scaling_factor - 1)/(Delay_scaling_factor*sigma_DS))*...
        10^(-Z/10);
end
% ��һ���ع���
sum_Pn = sum(P1);
for i = 1:N
    Pn(i) = P1(i)/(sum_Pn);
end
% �������LOS·��
if(LOS == 1)
    P_1LOS = K_R/(K_R + 1);
    for i = 1:N
        Pn(i) = 1/(K_R + 1)*Pn(i);
    end
    Pn(1) = Pn(1) + P_1LOS;
end
% ��Ӳ���ϵ��
D = 0.7705 - 0.0433*sigma_K + 0.0002*sigma_K^2 + 0.000017*sigma_K^3;
if(LOS == 1)
    for i = 1:N
        tau(i) = tau(i)/D;
    end
end

