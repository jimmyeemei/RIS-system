function [Pr_LOS] = Pr_LOS(BS_x,BS_y,UE_x,UE_y,h_UT,flag)
%% %%%%%%%%%% LOS概率计算 %%%%%%%%%%
% LOS = 1代表存在LOS径，LOS = 0代表不存在LOS径
% flag = 0表示UMa,flag = 1表示UMi

%% 2D距离计算
d_2D = sqrt((BS_x - UE_x)^2 + (BS_y - UE_y)^2);

%% 场景判断
if(flag == 0)
    % 计算C
    C = 1;
    if(h_UT > 13 && h_UT <= 23)
        C = ((h_UT - 13)/10)^1.5;
    elseif(h_UT <= 13)
        C = 0;
    end
    %% 计算UMa场景下LOS概率
    if(d_2D > 18)
        Pr_LOS = (18/d_2D + exp(-d_2D/63)*(1 - 18/d_2D))*(1 + C*5/4*(d_2D/100)^3*...
            exp(-d_2D/150));
    else
        Pr_LOS = 1;
    end
elseif(flag == 1)
    %% 计算UMi场景下LOS概率
    if(d_2D > 18)
        Pr_LOS = 18/d_2D + exp(-d_2D/36)*(1 - 18/d_2D);
    else
        Pr_LOS = 1;
    end
end



