function [Pr_LOS] = Pr_LOS(BS_x,BS_y,UE_x,UE_y,h_UT,flag)
%% %%%%%%%%%% LOS���ʼ��� %%%%%%%%%%
% LOS = 1�������LOS����LOS = 0��������LOS��
% flag = 0��ʾUMa,flag = 1��ʾUMi

%% 2D�������
d_2D = sqrt((BS_x - UE_x)^2 + (BS_y - UE_y)^2);

%% �����ж�
if(flag == 0)
    % ����C
    C = 1;
    if(h_UT > 13 && h_UT <= 23)
        C = ((h_UT - 13)/10)^1.5;
    elseif(h_UT <= 13)
        C = 0;
    end
    %% ����UMa������LOS����
    if(d_2D > 18)
        Pr_LOS = (18/d_2D + exp(-d_2D/63)*(1 - 18/d_2D))*(1 + C*5/4*(d_2D/100)^3*...
            exp(-d_2D/150));
    else
        Pr_LOS = 1;
    end
elseif(flag == 1)
    %% ����UMi������LOS����
    if(d_2D > 18)
        Pr_LOS = 18/d_2D + exp(-d_2D/36)*(1 - 18/d_2D);
    else
        Pr_LOS = 1;
    end
end



