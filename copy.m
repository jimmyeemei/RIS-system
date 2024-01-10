% 输入参数：sitex_wrap 小区中心坐标x
%         sitey_wrap 小区中心坐标y
%         userlistcoorx 用户坐标x
%         userlistcoory 用户坐标y
%         compthreshold 在门限范围内的小区组成comp，单位db,路损公式：30.18+26.0lg(d)
% 输出参数：userservice 用户端记录的服务小区结构体，包括协作小区数量，主小区ID，协作小区ID
%           cellservice 基站端记录的服务用户结构体，包括主小区用户数量，主小区用户列表，协作小区用户数量，协作用户列表
global sim;
%compthreshold=3;
% compthreshold=0;
% w_offx=sim_consts.wrap_offsetx;
% w_offy=sim_consts.wrap_offsety;
r=sim.intersitedistance;
cellnum=length(sitex_wrap)*3/7;%小区数量57
usernum=length(ux);%用户数量
time=0;
%hd=zeros(usernum,cellnum*7);%路损矩阵
% pathloss_wrap=zeros(usernum,cellnum);%路损矩阵
% sitex_wrap=[sx57 sx57+r*w_offx(1,2) sx57+r*w_offx(1,3) sx57+r*w_offx(1,4) sx57+r*w_offx(1,5) sx57+r*w_offx(1,6) sx57+r*w_offx(1,7)];
% sitey_wrap=[sy57 sy57+r*w_offy(1,2) sy57+r*w_offy(1,3) sy57+r*w_offy(1,4) sy57+r*w_offy(1,5) sy57+r*w_offy(1,6) sy57+r*w_offy(1,7)];
%
%load('hdCopy.mat',hdCopy);
hd=hdCopy;
% for i=1:usernum
%     for l=1:cellnum*7
%         j=ceil(l/3); %j代表小区对应地site ID
%         Txlocation=[sitex_wrap(j),sitey_wrap(j),sim.hbs];%133个值
%         Rxlocation=[ux(i),uy(i),UE{i}.hut];
%         [h,~,~]=Tx_Rx(Txlocation,Rxlocation);
%         hd(i,l)=10^((49 - 30)/10).*norm(h,2)^2;
%         delta_x=ux(i)-sitex_wrap(j);
%         delta_y=uy(i)-sitey_wrap(j);
%         if delta_x==0
%             if delta_y>=0
%                 angle_user_site=90;
%             else
%                 angle_user_site=270;
%             end
%         elseif delta_x>0
%             if delta_y>=0
%                 angle_user_site=atan(delta_y/delta_x)*180/pi;
%             else
%                 angle_user_site=atan(delta_y/delta_x)*180/pi+360;
%             end
%         else
%             angle_user_site=atan(delta_y/delta_x)*180/pi+180;
%         end
% 
%         %%写成[0,360)角度形式
%         %%写成[0,360)角度形式
%         angle_user_cell=angle_user_site-(mod(l,3)-1)*120;%%三个扇区主瓣的角度分别为0,120,240
%         %%%使angle_user_cell取值在-180到180之间%%%
%         if angle_user_cell>180
%             angle_user_cell=angle_user_cell-360;
%         else if angle_user_cell<-180
%                 angle_user_cell=angle_user_cell+360;
%         end
%         end
%         BSantenna_gain=-min(12*(angle_user_cell/65)^2,30)+17;%计算三扇区天线增益
%         BSantenna_gain=db2pow(BSantenna_gain);
%         hd(i,l)=hd(i,l)*BSantenna_gain;%应该是减，pathloss是损耗，gain是增益
%         time=time+1;
%         time
%     end
% end

for i=1:usernum
    a(i)=userservice(i).anchorcellid;
end
 hd2=zeros(usernum,cellnum);
for cc=1:cellnum
    site_id=ceil(cc/3);
    %     sector_id=mod(cc-1,3)+1;
    site_coor=[sitex_wrap(site_id),sitey_wrap(site_id)];
    %%查找引起干扰的站点
    site_dis=((sitex_wrap-site_coor(1,1)).^2+(sitey_wrap-site_coor(1,2)).^2).^(1/2);
    inter_id_list=find( site_dis>0.1*r & site_dis<2.1*r );%输出离目标site两层内的site的ID

    inter_map_id_list=mod(inter_id_list-1,19)+1; %映射到中间的19个site

    user_list=find(a==cc);%在小区cc中的用户列表
    hd2(user_list,site_id*3-2:site_id*3)=hd(user_list,site_id*3-2:site_id*3);
    for cc_around=1:18
        hd2(user_list,inter_map_id_list(1,cc_around)*3-2:inter_map_id_list(1,cc_around)*3)=hd(user_list,inter_id_list(1,cc_around)*3-2:inter_id_list(1,cc_around)*3);
    end
end
end