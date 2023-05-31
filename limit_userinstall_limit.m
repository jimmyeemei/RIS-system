function [userlistcoorx,userlistcoory]=limit_userinstall_limit(BS,limit_min_distance,limit_max_distance)
%用户撒点在所有小区的六边形范围内，总共usernum个用户
%输入参数：usernum 用户数量
%          userscalex 用户分布边范围x坐标
%          userscaley 用户分布边范围y坐标
%输出参数：userlistcoorx 用户位置列表x轴坐标
%          userlistcoory 用户位置列表y轴坐标
%          hut 终端天线高度
%          out区分室内室外用户   out=1为室外用户
%          d2_in室内用户的室内距离
global sim;
usernumpercell=sim.usernumpercell;
sitenum=sim.sitenum;
usernum=sitenum*usernumpercell*3;
userlistcoorx=zeros(1,usernum);
userlistcoory=zeros(1,usernum);
hut=zeros(1,usernum);
BSnum=sim.cellnum/3;
angle(usernum)=struct('a',0,...
    'b',0,...
    'c',0); 
for i=1:usernum
     j=floor(rand*BSnum)+1;
     x_center=BS{j}.site(1);
     y_center=BS{j}.site(2);
     delta_distance=limit_max_distance-limit_min_distance;
     delta_angel=round(rand*360);
     distance_user=limit_min_distance+delta_distance/2+(rand-0.5)*delta_distance;
     userlistcoorx(i)=distance_user*cosd(delta_angel)+x_center;
     userlistcoory(i)=distance_user*sind(delta_angel)+y_center;
end


%%，设置用户初始高度和角度


for i=1:usernum 
  Nf1=unifrnd(4,8);
  nf1=unifrnd(1,Nf1);
  hut(i)=3*(nf1-1)+1.5;
  angle(i).a=unifrnd(0,360);
  angle(i).b=90;
  angle(i).c=0; 
end


sim.hut = hut;
sim.userlistcoorx = userlistcoorx;
sim.userlistcoory = userlistcoory;
sim.Qx = angle(i).a;
sim.Qy = angle(i).b;
sim.Qz = angle(i).c;
%%R_zyx=rotz(Qz)*roty(Qy)*rotx(Qz)
hold on;
plot(userlistcoorx,userlistcoory,'.k');
hold off;

