function pathloss = cascade_pl(K1,K2,dx,dy,lambda,d_BR,d_RU,theta_t1,theta_r1)
%% %%%%%%%%%% BS-RIS-UE级联路径损耗计算 %%%%%%%%%%
%% 基本参数
% 天线增益
[Gt, Gr, G] = deal(db2pow(14.5), db2pow(14.5), 8);
% RIS反射单元行/列数
[M, N] = deal(K1, K2);
% 反射系数
A = 0.9;

%% 路径损耗表达式
pathloss = (64*pi^3*(d_BR*d_RU)^2)/(Gt*Gr*G*M^2*N^2*dx*dy*lambda^2*...
    F(theta_t1)*F(theta_r1)*A^2);

%% 辐射方向图函数
    function F = F(theta)
        if (0 <= theta) && (theta <= 90)
            F = cosd(theta)^3;
        else
            F = 0;
        end
    end
end


