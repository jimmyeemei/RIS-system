function [RISlistcoorx,RISlistcoory] = RISinstall( pedge,theatedge)
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
%usernumpercell=sim_consts.usernumpercell;
RISnumpercell=sim.RISnumpercell;
sitenum=sim.sitenum;
RISnum=sitenum*RISnumpercell*3;

RISlistcoorx=zeros(1,RISnum);
RISlistcoory=zeros(1,RISnum);

maxp=max(pedge);%最大极坐标范围

angle(RISnum)=struct('a',0,...
    'b',0,...
    'c',0); 

for i=1:RISnum %开始用户撒点循环
    loop=0; %控制条件，loop=1则找到在小区内的用户
    while loop==0       %通过转化到极坐标来判断是否位于小区内
        x=2*(rand-0.5)*maxp; 
        y=2*(rand-0.5)*maxp; %产生正方形坐标随机数。范围是最大长度范围
        ptemp=sqrt(x^2+y^2); %撒入点的长度坐标
        if x==0  %撒入点的角度坐标
            if y>=0
                theat=pi/2;
            else
                theat=pi*3/2;
            end
        elseif x>0
            if y>=0
                theat=atan(y/x);
            else
                theat=atan(y/x)+2*pi;
            end
        else
            theat=atan(y/x)+pi;
        end
        indextemp=0; %开始判断撒入点落入边缘坐标的那个角度范围之内
        for j=1:length(theatedge) %寻找撒入点角度打与边缘坐标角度的最后一个边缘坐标序号
            if theat>theatedge(j)
                indextemp=j;
            end
        end
        if indextemp==0 || indextemp==length(theatedge) %如果在第一个和最后一个之间，特殊处理
            alpha=theat+2*pi-theatedge(length(theatedge));
            belt=theatedge(1)-theat;
            a=pedge(length(theatedge));
            b=pedge(1);
        else  %否则，通过编号处理
            alpha=theat-theatedge(indextemp);
            belt=theatedge(indextemp+1)-theat;
            a=pedge(indextemp);
            b=pedge(indextemp+1);
        end
        pedgetemp=b*a*sin(alpha+belt)/(a*sin(alpha)+b*sin(belt)); %通过角分定理计算的处于边缘时候的极坐标长度
        if ptemp<=pedgetemp  %判断长度是否小于边缘，即是否在小区范围内
            RISlistcoorx(i)=x; %返回x，y坐标
            RISlistcoory(i)=y;
          

            loop=1; %设置循环条件，结束循环  %%yangshan:表示这个用户产生成功
%             disp(['ptemp=',int2str(ptemp),'pedgetemp=',int2str(pedgetemp)])
        else
%             disp('out range');
        end
    end
end


hold on;
plot(RISlistcoorx,RISlistcoory,'.r');
hold off;
