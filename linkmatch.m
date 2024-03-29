function [RISlink]= linkmatch(sitex_wrap,sitey_wrap,userlistcoorx,userlistcoory,UE,RIS,BS,cellservice_UE,cellservice_RIS)
%LINKMATCH 此处显示有关此函数的摘要
%   此处显示详细说明
usernum=length(userlistcoorx);%用户数量
Init_sim;
global sim;
for i=1:usernum
    for j=1:57
        for k=1:usernum
            if cellservice_UE(j).anchoruserlist(k)==i
                BS1=j;
                BS2=k;
            end
        end
    end
    if cellservice_RIS(BS1).anchorusernum==0%此UE没有RIS辅助
        parament;
        TX.location=[BS{BS1}.site];
        RX.location=[UE{i}.site];
        TXlocation=TX.location;
        RXlocation=RX.location;
        %% %%%%%%%%%% 直连链路Tx-Rx信道系数生成 %%%%%%%%%%
        [h_d, ~, ~] = Tx_Rx(TXlocation,RXlocation);
        B=sim.Bandwidth_MHz*10e6;
        N0 = -174; % 噪声功率密度谱dBm/Hz
        sigma2 = B*10^((N0 - 30)/10);
        signalpower_BIU(i) = 10^((49 - 30)/10).*norm(h_d,2)^2;
        RISlink{i}.UEnum=i;
        RISlink{i}.BSnum=BS1;
        RISlink{i}.RISnum=0;
        RISlink{i}.BIUpower=signalpower_BIU(i);
    else%小区内同时有RIS和UE
        RIS_of_this_BS=zeros(1,cellservice_RIS(BS1).anchorusernum);
        %     for icell=1:57
        %     parament;
        %     TX.location=[BS{BS1}.site];
        %     TXlocation=TX.location;
        %     RISnodelocation=RISnode.location;
        %     RXlocation=Rx.location;
        %     end
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
            [h_d, mu_XPR, sigma_XPR] = Tx_Rx(TXlocation,RXlocation);
           
            %% %%%%%%%%%% 级联链路Tx-RIS-Rx信道系数生成 %%%%%%%%%%
            [h_BIU] = BIU(mu_XPR, sigma_XPR,TXlocation,RISnodelocation,RXlocation);
            %% 噪声功率
            %B = 20*10^6;
            B=sim.Bandwidth_MHz*10e6;
            N0 = -174; % 噪声功率密度谱dBm/Hz
            sigma2 = B*10^((N0 - 30)/10);
            signalpower_BIU(l) = 10^((49 - 30)/10).*norm(h_BIU,2)^2+ 10^((49-30)/10).*norm(h_d,2)^2;
        end
       % [minpower,minpowerid]=min(signalpower_BIU(1:cellservice_RIS(BS1).anchorusernum));
        minpower=min(signalpower_BIU(signalpower_BIU~=0));
        minpowerid=find(signalpower_BIU==minpower);
        RISlink{i}.UEnum=i;
        RISlink{i}.BSnum=BS1;
        RISlink{i}.RISnum=minpowerid;
        RISlink{i}.BIUpower=minpower;
    end
end

