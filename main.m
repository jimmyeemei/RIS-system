clear;
%% 参数初始化
Init_sim;
global sim;
Number_of_drops=1;
for idrop=Number_of_drops
    tic
    nUsergroups=57;
    way_of_userinstall='限定撒点';
    limit_min_distance=150;
    limit_max_distance=160;
    Bandwidth_MHz=400;%载波带宽
    Subcarrier_Spacing_kHz=120;%子载波间隔
    frame=10e-3;%无线帧10ms
    half_of_frame=frame/2;
    subframe=1e-3;%子帧1ms，一个tti
    subcarrierSpacingHz =Subcarrier_Spacing_kHz*10^3;%FR2频段支持的子载波间隔为60 kHz（数据信道，如PDSCH、PUSCH）、120 kHz及240 kHz（仅应用于同步信道如PSS、SSS、PBCH)。
    slotDuration = 15e3/subcarrierSpacingHz*1e-3;%时隙15-1ms,60-0.25
    symbolDurationS= slotDuration/14;%符号周期=时隙/14
    Number_of_slots_per_simulation=frame/slotDuration;%半个个无线帧中的时隙数
    bandwidthHz=Bandwidth_MHz*10^6;%毫米波最高支持400MHz带宽
    %先只考虑下行
    % Frame_Structure='DDDSU';
    %segment=[0 0 0 2 1];
    Frame_Structure='DDDDD';
    segment=[0 0 0 0 0];
    Uplink_control_overhead=0.3;
    Downlink_control_overhead=0.2;
    %dl 0 ul1 sl2
    nsegment=floor(Number_of_slots_per_simulation/length(segment));
    nsegment=2;
    nremainslots=mod(Number_of_slots_per_simulation,length(segment));
    segment_total=[];
    for islot=1:nsegment
        segment_total=[segment_total segment];
    end
    segment_total=[segment_total segment(1:nremainslots)];
    length_segment_UL=length(find(segment_total==1));
    length_segment_DL=length(find(segment_total==0));
    length_segment_SL=length(find(segment_total==2));
    Special_Slot_Configuration='10:2:2';
    switch Special_Slot_Configuration
        case '10:2:2'
            Special_Slot_UL=2;
            Special_Slot_DL=10;
        case '3:10:1'
            Special_Slot_UL=1;
            Special_Slot_DL=3;
    end
    %% 资源块设计
    resourceGrid.nSubcarrierRb = 12;%一个RB块里有12个子载波
    resourceGrid.nRBTime =1;%假设为固定参数，
    resourceGrid.sizeRbTimeS =slotDuration/resourceGrid.nRBTime;%一个RB块时间
    resourceGrid.sizeRbFreqHz = resourceGrid.nSubcarrierRb .* subcarrierSpacingHz;%一个RB块带宽=每个RB块子载波个数*子载波间隔
    resourceGrid.nSymbolRb = 14;%每个RB块14个符号周期
    resourceGrid.nSymbolSlot = 14;%每个时隙14个符号周
    usableBandwidth=1;%5G中为0.98，LTE中为0.8
    resourceGrid.nRBFreq = floor(bandwidthHz .* usableBandwidth ./resourceGrid.sizeRbFreqHz);
    resourceGrid.nRBTot = resourceGrid.nRBFreq *resourceGrid.nRBTime;
    resourceGrid.nCRCBits = 24;
    nSubcarrierSlot = resourceGrid.nRBFreq .*resourceGrid. nSubcarrierRb;%每个时隙中子载波数
    nSymbolSlot = resourceGrid.nRBTime .* floor(resourceGrid.sizeRbTimeS ./symbolDurationS);%每个时隙符号数
    %每个时隙符号数

    %% 初始化
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %小区初始化，输入小区站间距intercelldistance和需要构建的小区数目cellnum，输出小区中心坐标x，y
    %以及拓扑图边缘点的极坐标
    % cellinstall：输入小区数量和间隔
    %输出参数：sitex 小区中心x轴坐标
    %           sitey 小区中心y轴坐标
    %           pedge  小区分布地区边缘点的极坐标长度pou
    %           theatedge 小区分布地区边缘点的极坐标角度theat
    %wrap_around,平移到周边6个区域
    [sitecoorx,sitecoory,pedge,theatedge]=cellinstall;
    [sitex_wrap,sitey_wrap]=wraparound(sitecoorx,sitecoory);
    %wrap-around采取平移的方式消除边缘效应
    BSnum=sim.cellnum;
    BS=cell(BSnum,1);
    for i=1:BSnum
        BS{i}.hbs=sim.hbs;%基站统一高度hbs25m
        BS{i}.site=[sitex_wrap(i),sitey_wrap(i) sim.hbs];%记录每个基站的坐标
    end


    %%循环控制参数
    cyclenum=1;
    for cyclei=1:cyclenum
        if way_of_userinstall=='限定撒点'
            [userlistcoorx,userlistcoory]=limit_userinstall_limit(BS,limit_min_distance,limit_max_distance);

        elseif way_of_userinstall=='随机撒点'
            [userlistcoorx,userlistcoory]=userinstall(pedge,theatedge); %参考comp的用户撒点方式，19个小区内随机撒点
        end
        %输入参数：usernum 用户数量
        %         userscalex 用户分布边范围x坐标
        %         userscaley 用户分布边范围y坐标
        %输出参数：userlistcoorx 用户位置列表x轴坐标
        %         userlistcoory 用户位置列表y轴坐标
        usernum=sim.usernumpercell*sim.cellnum;
        UE=cell(usernum,1);
        for i=1:usernum
            UE{i}.site=[userlistcoorx(i), userlistcoory(i)];%记录每个用户的坐标
            Nf1=unifrnd(1,4,1);
            nf1=unifrnd(1,Nf1,1);
            hut=3*(nf1-1)+1.5;
            UE{i}.hut=hut;
        end
        %%RIS随机撒点，输出RIS位置坐标RISlistcoorx,RISlistcoory
        [RISlistcoorx,RISlistcoory] = RISinstall( pedge,theatedge);
        RISnum=sim.RISnumpercell*sim.cellnum;
        RIS=cell(RISnum,1);
        for i=1:RISnum
            RIS{i}.hut=sim.RIShut;%ris统一高度rishut25m
            RIS{i}.site=[RISlistcoorx(i),RISlistcoory(i) sim.RIShut];%记录每个用户的坐标
            RIS{i}.unit_vector=[];
        end
        %%  %%%%% 服务小区确定，输出用户、小区结构体，记录用户所属小区情况和小区内服务用户情况 %%%%%
        [userservice,cellservice_UE,~,~]=servicecell_wrap(sitex_wrap,sitey_wrap,userlistcoorx,userlistcoory,UE);
        %UE和BS进行配对
        %userservice用户所属小区： struct; cellservice（小区服务用户数以及编号）: struct
        %pathloss:570*57，the pathloss between each user and each cell
        %pathloss_min:570*3，每个UE与服务小区之间的pathloss
       
        [RISservice,cellservice_RIS,~,~]=servicecell_wrap(sitex_wrap,sitey_wrap,RISlistcoorx,RISlistcoory,RIS);
        [h_d_UE]=hd_everyBS(sitex_wrap,sitey_wrap,userlistcoorx,userlistcoory,UE,userservice);%jisuan每个基站到每个用户的直连信道
        %RIS和BS进行配对
        [unit_vector_RIS]=RISvector(RISservice,RIS,BS);
        for i=1:RISnum
            RIS{i}.unit_vector=unit_vector_RIS{i};%每个RIS的朝向单位向量
        end
        %BS-RIS-UE进行配对


        [RISlink]= linkmatch(sitex_wrap,sitey_wrap,userlistcoorx,userlistcoory,UE,RIS,BS,cellservice_UE,cellservice_RIS);
        %% 轮询调度
        %空分复用可以每个扇区调度PRB
        schedulelist=cell(Number_of_drops,1);
        schedulelist{idrop}.DL=cell(57,1);
        schedulelist{idrop}.UL=cell(57,1);
        schedulelist{idrop}.SL=cell(57,1);
        %调度每个slot
        [UL_PRB,DL_PRB]=cost_PRB(resourceGrid,Uplink_control_overhead,Downlink_control_overhead);%这个函数考过来
        for ig=1:57%每个扇区%改参数名字
            iue=1;
            for islot=1:length(segment_total)
                switch  segment_total(islot)
                    case 1
                        UsersToBeScheduled_UL= UL_PRB;
                        [ind_RB,ind_slot]=find(UsersToBeScheduled_UL);%频域×时间
                        attachedUser=cell(cellservice_UE(ig).anchorusernum,1);
                        for a=1:(cellservice_UE(ig).anchorusernum)
                            attachedUser{a}.ID=a-1;
                        end
                        %attachedUser=cellservice_UE(ig).anchoruserlist; %改参数名字
                        if ~isempty(attachedUser)
                            for is=1:length(ind_RB)
                                if (iue<=cellservice_UE(ig).anchorusernum)
                                    UsersToBeScheduled_UL(ind_RB(is),ind_slot(is))=attachedUser{iue}.ID+1;%id从0开始的
                                    iue=iue+1;
                                else
                                    iue=1;
                                    UsersToBeScheduled_UL(ind_RB(is),ind_slot(is))=attachedUser{iue}.ID+1;
                                    iue=iue+1;
                                end
                            end
                        else
                        end
                        iulslot=find(find(segment_total==1)==islot);
                        schedulelist{idrop}.UL{ig}.UsersToBeScheduled(:,iulslot)=UsersToBeScheduled_UL;

                    case 0
                        UsersToBeScheduled_DL= DL_PRB;
                        [ind_RB,ind_slot]=find(UsersToBeScheduled_DL);%频域×时间
                        attachedUser=cell(1,cellservice_UE(ig).anchorusernum);
                        for a=1:(cellservice_UE(ig).anchorusernum)
                            attachedUser{a}.ID=a-1;
                        end
                        if ~isempty(attachedUser)
                            for is=1:length(ind_RB)
                                if (iue<=cellservice_UE(ig).anchorusernum)
                                    UsersToBeScheduled_DL(ind_RB(is),ind_slot(is))=attachedUser{iue}.ID+1;%id从0开始的
                                    iue=iue+1;
                                else
                                    iue=1;
                                    UsersToBeScheduled_DL(ind_RB(is),ind_slot(is))=attachedUser{iue}.ID+1;
                                    iue=iue+1;
                                end
                            end
                        else
                        end
                        idlslot=find(find(segment_total==0)==islot);
                        schedulelist{idrop}.DL{ig}.UsersToBeScheduled(:,idlslot)=UsersToBeScheduled_DL;

                    case 2
                        UsersToBeScheduled_SL= DL_PRB;
                        [ind_RB,ind_slot]=find(UsersToBeScheduled_SL);%频域×时间
                        attachedUser=cell(cellservice_UE(ig).anchorusernum,1);
                        for a=1:(cellservice_UE(ig).anchorusernum)
                            attachedUser{a}.ID=a-1;
                        end
                        if ~isempty(attachedUser)
                            for is=1:length(ind_RB)
                                if (iue<=cellservice_UE(ig).anchorusernum)
                                    UsersToBeScheduled_SL(ind_RB(is),ind_slot(is))=attachedUser{iue}.ID+1;%id从0开始的
                                    iue=iue+1;
                                else
                                    iue=1;
                                    UsersToBeScheduled_SL(ind_RB(is),ind_slot(is))=attachedUser{iue}.ID+1;
                                    iue=iue+1;
                                end
                            end
                        else
                        end
                        islslot=find(find(segment_total==2)==islot);
                        schedulelist{idrop}.SL{ig}.UsersToBeScheduled(:,islslot)=UsersToBeScheduled_SL;

                end
            end
        end


        toc
        %% sinr计算
        for ig=1:nUsergroups
            for iu=1:cellservice_UE(ig).anchorusernum
                for islot=1:length(segment_total)
                    switch  segment_total(islot)
                        case 0%下行sinr计算
                            %prb长度
                            idlslot=find(find(segment_total==0)==islot);
                            pos_PRB_DL(ig,iu,idrop).prb=find(schedulelist{idrop}.DL{ig}.UsersToBeScheduled(:,idlslot)==iu);
                            length_PRB_DL=length(pos_PRB_DL(ig ...
                                ,iu,idrop).prb);
                            length_RE_DL=length(pos_PRB_DL(ig,iu,idrop).prb)*12;
                            %开始计算sinr
                            if ~isempty( pos_PRB_DL(ig,iu,idrop).prb)%此用户prb占用非空
                                signal_DL=RISlink{cellservice_UE(ig).anchoruserlist(iu)}.BIUpower;%本小区增益
                                signal_other=sum(abs(h_d_UE).^2,2);
                                aa=max(h_d_UE(cellservice_UE(ig).anchoruserlist(iu)));
                                other_DL=signal_other(cellservice_UE(ig).anchoruserlist(iu),1)-abs(aa)^2;
                                B = resourceGrid.sizeRbFreqHz;%一个资源块的带宽
                                N0 = -174; % 噪声功率密度谱dBm/Hz
                                sigma2 = B*10^((N0 - 30)/10);
                                sinr_BIU(cellservice_UE(ig).anchoruserlist(iu),islot) = abs(RISlink{cellservice_UE(ig).anchoruserlist(iu)}.BIUpower)^2/(sigma2+other_DL/12);
                            end
                    end
                end
            end
        end


        hut=25;
        angle.a=unifrnd(0,360);
        angle.b=90;
        angle.c=0;
    end
end