function [PL_b,PL_tw,PL_in,d_2D] = calculation_pathloss(BS_x,BS_y,UE_x,UE_y,...
    h_BS,h_UT,LOS,fc,flag,d_2D_in,O2I)
%% %%%%%%%%%% 直连路径损耗计算 %%%%%%%%%%
% 路径损耗包括室外路损PL_b、穿透损耗PL_tw以及室内损耗PL_in
%% Tx-Rx逻辑链路路径损耗计算(单位:dB值)
% 光速(m/s)
c = 3*10^8;
% 载波频率(单位:GHz)
fc = fc/10^9;
% 材料穿透损耗(单位:dB值)
L_glass = 2 + 0.2*fc;
L_concrete = 5 + 4*fc;
% 2D距离
d_2D = sqrt((BS_x-UE_x)^2 + (BS_y-UE_y)^2);
% 3D距离
d_3D = sqrt((d_2D)^2 + (h_BS - h_UT)^2);
% 室内损耗
PL_in = 0.5*d_2D_in;

%% h_E概率计算
if(d_2D <= 18)
    g = 0;
else
    g = 5/4*(d_2D/100)^3*exp(-d_2D/150);
end
if(h_UT < 13)
    C = 0;
else
    C = ((h_UT - 13)/10)^1.5*g;
end
p_h_E = 1/(1 + C);

if(flag == 0)
    % UMa随机数
    temp = rand();
    if(temp <= p_h_E)
        h_E = 1;
    else
        length = ceil((h_UT - 1.5 - 12)/3) + 1;
        number = unidrnd(length);
        vector = zeros(1,length);
        for i = 1:length - 1
            vector = 12 + i*3;
        end
        vector(length) = h_UT -  1.5;
        h_E = vector(number);
    end
    h_BS_e = h_BS - h_E; h_UT_e = h_UT - h_E;
    d_BP = 4*h_BS_e*h_UT_e*(fc*10^9)/c;
    
    %% UMa场景
    if(d_2D >= 10 && d_2D <= d_BP)
        pathloss_UMa_LOS = 28 + 22.0*log10(d_3D) + 20*log10(fc);
    elseif(d_BP <= d_2D && d_2D<= 5000)
        pathloss_UMa_LOS = 28 + 40*log10(d_3D) + 20*log10(fc) -...
            9*log10(d_BP^2 + (h_BS - h_UT)^2);
    end
    pathloss_UMa_NLOS = 13.54 + 39.08*log10(d_3D) + 20*log10(fc) -...
        0.6*(h_UT - 1.5);
    %% LOS/NLOS
    if(LOS == 1)
        PL_b = pathloss_UMa_LOS;
    elseif(LOS == 0)
        PL_b = max(pathloss_UMa_LOS, pathloss_UMa_NLOS);
    end

elseif(flag == 1)
    h_E = 1; h_BS_e = h_BS - h_E; h_UT_e = h_UT - h_E;
    d_BP = 4*h_BS_e*h_UT_e*(fc*10^9)/c;
    %% UMi场景
    if(d_2D >= 10 && d_2D <= d_BP)
        pathloss_UMi_LOS = 32.4 + 21*log10(d_3D) + 20*log10(fc);
    elseif(d_BP <= d_2D && d_2D<= 5000)
        pathloss_UMi_LOS = 32.4 + 40*log10(d_3D) + 20*log10(fc) -...
            9.5*log10(d_BP^2 + (h_BS - h_UT)^2);
    end
    pathloss_UMi_NLOS = 35.3*log10(d_3D) + 22.4 + 21.3*log10(fc) -...
        0.3*(h_UT - 1.5);
    %% LOS/NLOS
    if(LOS == 1)
        PL_b = pathloss_UMi_LOS;
    elseif(LOS == 0)
        PL_b = max(pathloss_UMi_LOS,pathloss_UMi_NLOS);
    end
end

if(O2I == 1)
    PL_tw = 5 - 10*log10(0.3*10^(-L_glass/10) + 0.7*10^(-L_concrete/10));
else
    PL_tw = 0;
end

end
