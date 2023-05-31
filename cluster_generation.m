% function [tau_BIU,Pn_BIU] = cluster_generation(Pn_BR,N_BR,tau_BR,Pn_RU,N_RU,tau_RU,M,F_RIS_BR,F_RIS_RU)
% N_BIU = N_BR*N_RU;
% tau_BIU = zeros(1,N_BIU);
% Pnm_BIU = zeros(N_BIU,M);
% for i=1:N_BR
%     for j=1:N_RU
%         tau_BIU(1,(i - 1)*N_BR + j) = tau_BR(i)+tau_RU(j);
%         for m = 1:M
%             Pnm_BIU((i - 1)*N_BR + j,m) = F_RIS_BR(i,m)*F_RIS_RU(j,m)'*sqrt(Pn_BR(i)*Pn_RU(j))/20;
%         end
%     end
% end
% % 归一化
% min_tau_BIU = min(tau_BIU,[],'all');
% tau_BIU = sort(tau_BIU - min_tau_BIU);
% 
% 
% % % 簇功率归一化(20221208)
% % Pn_BIU = sum(Pnm_BIU,3);
% % Pn_BIU = Pn_BIU/max(Pn_BIU);
% % sum_Pn = sum(Pn_BIU,'all');
% 
% % sum_Pn = sum(Pnm_BIU,'all');
% % %% 归一化簇功率
% % for i = 1:N_BR
% %     for j = 1:N_RU
% %         for m = 1:M
% %             Pnm_BIU((i - 1)*N_BR + j,m) = Pnm_BIU((i - 1)*N_BR + j,m)/(sum_Pn);
% %         end
% %     end
% % end
% Pn_BIU = sum(Pnm_BIU,2)';
function [tau_BIU,Pn_BIU] = cluster_generation(Pn_BR,N_BR,tau_BR,Pn_RU,N_RU,tau_RU,M,F_RIS_BR,F_RIS_RU)
N_BIU = N_BR*N_RU;
tau_BIU = zeros(1,N_BIU);
Pnm_BIU = zeros(1,N_BIU,M);
for i=1:N_BR
    for j=1:N_RU
        tau_BIU(1,(i - 1)*N_BR + j) = tau_BR(i)+tau_RU(j);
        for m = 1:M
            Pnm_BIU(1,(i - 1)*N_BR + j,m) = F_RIS_BR(i,m)*F_RIS_RU(j,m)'*sqrt(Pn_BR(i)*Pn_RU(j))/20;
        end
    end
end
% 归一化
min_tau_BIU = min(tau_BIU,[],'all');
tau_BIU = sort(tau_BIU - min_tau_BIU);
% sum_Pn = sum(Pnm_BIU,'all');
% %% 归一化簇功率
% Pnm_BIU = Pnm_BIU/sum_Pn;
% for i = 1:N_BR
%     for j = 1:N_RU
%         for m = 1:M
%             Pnm_BIU(1,(i - 1)*N_BR + j,m) = Pnm_BIU(1,(i - 1)*N_BR + j,m)/(sum_Pn);
%         end
%     end
% end
Pn_BIU = sum(Pnm_BIU,3);
