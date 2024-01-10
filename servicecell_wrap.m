function [ userservice,cellservice,pathloss2,pathloss_min ] = servicecell_wrap(sitex_wrap,sitey_wrap,ux,uy,UE)
%UNTITLED1 Summary of this function goes here
%   Detailed explanation goes here

% 输入参数：sitex_wrap 小区中心坐标x
%         sitey_wrap 小区中心坐标y
%         userlistcoorx 用户坐标x
%         userlistcoory 用户坐标y
%         compthreshold 在门限范围内的小区组成comp，单位db,路损公式：30.18+26.0lg(d)
% 输出参数：userservice 用户端记录的服务小区结构体，包括协作小区数量，主小区ID，协作小区ID
%           cellservice 基站端记录的服务用户结构体，包括主小区用户数量，主小区用户列表，协作小区用户数量，协作用户列表
global sim;
compthreshold=3;
% compthreshold=0;
% w_offx=sim_consts.wrap_offsetx;
% w_offy=sim_consts.wrap_offsety;
r=sim.intersitedistance;
cellnum=length(sitex_wrap)*3/7;%小区数量
usernum=length(ux);%用户数量

userservice(usernum)=struct( 'anchorcellid',0);
for i=1:usernum               %初始化，所有元素置
    userservice(i).anchorcellid=0;
end
cellservice(cellnum)=struct('anchorusernum',0,...%主小区用户数量
    'anchoruserlist',zeros(1,usernum) );%主小区用户列表


for i=1:cellnum        %初始化，所有元素置0
    cellservice(i).anchorusernum=0;
    cellservice(i).anchoruserlist=zeros(1,usernum);
   
end

pathloss=zeros(usernum,cellnum*7);%路损矩阵
% pathloss_wrap=zeros(usernum,cellnum);%路损矩阵
% sitex_wrap=[sx57 sx57+r*w_offx(1,2) sx57+r*w_offx(1,3) sx57+r*w_offx(1,4) sx57+r*w_offx(1,5) sx57+r*w_offx(1,6) sx57+r*w_offx(1,7)];
% sitey_wrap=[sy57 sy57+r*w_offy(1,2) sy57+r*w_offy(1,3) sy57+r*w_offy(1,4) sy57+r*w_offy(1,5) sy57+r*w_offy(1,6) sy57+r*w_offy(1,7)];
for i=1:usernum
    for l=1:cellnum*7
        %%%%%%此处的路损是路径损耗及天线增益两部分的叠加%%%%%
        hut=UE{i}.hut;
        hbs=sim.hbs;
        j=ceil(l/3); %j代表小区对应地site ID
        d2d=sqrt((sitex_wrap(j)-ux(i))^2+(sitey_wrap(j)-uy(i))^2);%距离计算
        d3d=sqrt(d2d^2+(hbs-hut)^2);
        dp=4*sim.hbs*hut*sim.fc/3e8;
       if  d2d<dp
           los=28+22*log10(d3d)+20*log10(sim.fc);%3gpp路损计算模型
           sigma_SF_los=4;%阴影衰落标准差
        else
           los=28+40*log10(d3d)+20*log10(sim.fc)-9*log10(dp^2+(hbs-hut)^2);
           sigma_SF_los=4;%阴影衰落标准差
        end
        %到小区的nlos
        nlos=13.54 + 39.08*log10(d3d)+ 20*log10(sim.fc) - 0.6*(hut-1.5);
        nlos=max(los,nlos);
        sigma_SF_nlos=6;%阴影衰落标准差
        %得到los概率
        if d2d<=18
            los_probability=1;
        else
            if hut<=13
                c_hut=0;
            elseif (hut>13)&&(hut<=23)
                c_hut=((hut-13)/10)^1.5;
            else
            end
            
            los_probability=(18/d2d+exp(-d2d/63)*(1-18/d2d))*(1+c_hut*5/4*(d2d/100)^3*exp(-d2d/150));
        end
        %判定是否为los；
        islos=rand<=los_probability;
        islos=1;
        %得到路损
        if  islos
            pathloss(i,l)=los;
            pathloss0=pathloss(i,l)+normrnd(0,sigma_SF_los);
        else
            pathloss(i,l)=nlos;
            pathloss0=pathloss(i,l)+normrnd(0,sigma_SF_nlos);
        end
        %%%计算天线增益%%%%
        delta_x=ux(i)-sitex_wrap(j);
        delta_y=uy(i)-sitey_wrap(j);
        if delta_x==0
            if delta_y>=0
                angle_user_site=90;
            else
                angle_user_site=270;
            end
        elseif delta_x>0
            if delta_y>=0
                angle_user_site=atan(delta_y/delta_x)*180/pi;
            else
                angle_user_site=atan(delta_y/delta_x)*180/pi+360;
            end
        else
            angle_user_site=atan(delta_y/delta_x)*180/pi+180;
        end

        %%写成[0,360)角度形式
        angle_user_cell=angle_user_site-(mod(l,3)-1)*120;%%三个扇区主瓣的角度分别为0,120,240
        %%%使angle_user_cell取值在-180到180之间%%%
        if angle_user_cell>180
            angle_user_cell=angle_user_cell-360;
        else if angle_user_cell<-180
                angle_user_cell=angle_user_cell+360;
            end
        end
        BSantenna_gain=-min(12*(angle_user_cell/65)^2,30)+17;%计算三扇区天线增益        
        pathloss(i,l)=pathloss0-BSantenna_gain;%应该是减，pathloss是损耗，gain是增益

    end
end

%%搜索每个user的主小区
user_anchorcell=zeros(usernum,1);
for i=1:usernum
    [minloss,minlossid]=min(pathloss(i,1:57));%寻找最小路损
    user_anchorcell(i,1)=minlossid;
end

%计算wrap之后的路损
pathloss2=zeros(usernum,cellnum);
for cc=1:cellnum
    site_id=ceil(cc/3);
%     sector_id=mod(cc-1,3)+1;
    site_coor=[sitex_wrap(site_id),sitey_wrap(site_id)];
    %%查找引起干扰的站点
    site_dis=((sitex_wrap-site_coor(1,1)).^2+(sitey_wrap-site_coor(1,2)).^2).^(1/2);
    inter_id_list=find( site_dis>0.1*r & site_dis<2.1*r );%输出离目标site两层内的site的ID

    inter_map_id_list=mod(inter_id_list-1,19)+1; %映射到中间的19个site
    
    user_list=find(user_anchorcell==cc);%在小区cc中的用户列表
    pathloss2(user_list,site_id*3-2:site_id*3)=pathloss(user_list,site_id*3-2:site_id*3);
    for cc_around=1:18
        pathloss2(user_list,inter_map_id_list(1,cc_around)*3-2:inter_map_id_list(1,cc_around)*3)=pathloss(user_list,inter_id_list(1,cc_around)*3-2:inter_id_list(1,cc_around)*3);
    end
end
pathloss2;
pathloss_min=zeros(usernum,3);
for i=1:usernum
    [minloss,minlossid]=min(pathloss2(i,:));%寻找最小路损
    pathloss_min(i,1)=minloss;
    maxloss=max(pathloss2(i,:));%最大路损值
    userservice(i).anchorcellid=minlossid;%用户i的主小区为路损最小的小区
    cellservice(minlossid).anchorusernum=cellservice(minlossid).anchorusernum+1;%主小区的用户数+1
    cellservice(minlossid).anchoruserlist(cellservice(minlossid).anchorusernum)=i;%主小区的用户列表增加用户i
end
