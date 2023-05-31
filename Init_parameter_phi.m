function [c_ASA,c_ASD,c_ZSA,mu_lgZSD,mu_XPR,sigma_XPR] =...
    Init_parameter_phi(h_UT,h_BS,d_2D,LOS,O2I_LOS,flag)
%% %%%%%%%%%% 参数数值查表 %%%%%%%%%%

%% 查表函数
if(flag == 0)
    if(LOS == 1)
        %% UMa LOS
        c_ASA = 11;   % 角度值
        c_ASD = 5;
        c_ZSA = 7;
        mu_lgZSD = max(-0.5, -2.1*(d_2D/1000) - 0.01*(h_UT - 1.5) + 0.75);
        mu_XPR = 8;   % dB值
        sigma_XPR = 4;
    elseif(LOS == 0)
        %% UMa NLOS
        c_ASA = 15;
        c_ASD = 2;
        c_ZSA = 7;
        mu_lgZSD = max(-0.5, -2.1*(d_2D/1000) - 0.01*(h_UT - 1.5) + 0.9);
        mu_XPR = 7;
        sigma_XPR = 3;
    end
    if(O2I_LOS == 1)
        c_ASD = 5;
        c_ASA = 8;
        mu_lgZSD = max(-0.5, -2.1*(d_2D/1000) - 0.01*(h_UT - 1.5) + 0.75);
        c_ZSA = 3;
        mu_XPR = 9;
        sigma_XPR = 5;
    elseif(O2I_LOS == 0)
        mu_lgZSD = max(-0.5, -2.1*(d_2D/1000) - 0.01*(h_UT - 1.5) + 0.9);
        c_ASA = 8;
        c_ASD = 5;
        c_ZSA = 3;
        mu_XPR = 9;
        sigma_XPR = 5;
    end
else
    if(LOS == 1)
        %% UMi LOS
        c_ASA = 17;
        c_ASD = 3;
        c_ZSA = 7;
        mu_lgZSD = max(-0.21, -14.8*(d_2D/1000) + 0.01*abs(h_UT - h_BS) + 0.83);
        mu_XPR = 9;
        sigma_XPR = 3;
    elseif(LOS == 0)
        %% UMi NLOS
        c_ASA = 22;
        c_ASD = 10;
        c_ZSA = 7;
        mu_lgZSD = max(-0.5, -3.1*(d_2D/1000) + 0.01*max((h_UT - h_BS),0) + 0.2);
        mu_XPR = 8;
        sigma_XPR = 3;
    end
    if(O2I_LOS == 1)
        c_ASD = 5;
        c_ASA = 8;
        mu_lgZSD = max(-0.21,(-14.8*(d_2D/1000) + 0.01*abs(h_UT - h_BS) + 0.83));
        c_ZSA = 3;
        mu_XPR = 9;
        sigma_XPR = 5;
    elseif(O2I_LOS == 0)
        mu_lgZSD = max(-0.5,-3.1*(d_2D/1000) + 0.01*max((h_UT - h_BS),0) + 0.2);
        c_ASA = 8;
        c_ASD = 5;
        c_ZSA = 3;
        mu_XPR = 9;
        sigma_XPR = 5;
    end
end



