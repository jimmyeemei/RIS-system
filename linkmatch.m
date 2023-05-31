function [RISlink]= linkmatch(sitex_wrap,sitey_wrap,userlistcoorx,userlistcoory,UE,RIS,BS,cellservice_UE,cellservice_RIS)
%LINKMATCH 此处显示有关此函数的摘要
%   此处显示详细说明
usernum=length(userlistcoorx);%用户数量

for i=1:usernum
    for j=1:57
        for k=1:285
            if cellservice_UE(j).anchoruserlist(k)==usernum
                BS1=j;
                BS2=k;
            end
        end
    end
    RIS_of_this_BS=zeros(1,cellservice_RIS(BS1).anchorusernum);
    for l=1:cellservice_RIS(BS1).anchorusernum
        RIS_of_this_BS(l)=cellservice_RIS(BS1).anchoruserlist(l);%找到UE匹配基站的对应RIS
        parament;
        TX.location=[BS{BS1}.site];
        RISnode.location=[RIS{cellservice_RIS(BS1).anchoruserlist(l)}.site];
        RX.location=[UE{i}.site];
        TXlocation=TX.location;
        RISnodelocation=RISnode.location;
        RXlocation=RX.location;
        %% %%%%%%%%%% 直连链路Tx-Rx信道系数生成 %%%%%%%%%%
        [h_d, mu_XPR, sigma_XPR] = Tx_Rx(TXlocation,RISnodelocation,RXlocation);

        %% %%%%%%%%%% 级联链路Tx-RIS-Rx信道系数生成 %%%%%%%%%%
        [h_BIU] = BIU(mu_XPR, sigma_XPR,TXlocation,RISnodelocation,RXlocation);
        %% 噪声功率
        B = 20*10^6;
        N0 = -174; % 噪声功率密度谱dBm/Hz
        sigma2 = B*10^((N0 - 30)/10);
        SNR_BIU(cellservice_RIS(BS1).anchorusernum) = 10^((49 - 30)/10).*norm(h_BIU,2)^2/sigma2;

    end
    [minloss,minlossid]=min(SNR_BIU(1:cellservice_RIS(BS1).anchorusernum));
RISlink.UEnum=i;
RISlink.BSnum=BS1;
RISlink.RISnum=minlossid;
RISlink.BIUloss=minloss;
end

