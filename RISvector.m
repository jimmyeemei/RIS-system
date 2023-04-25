function [unit_vector_ris] = RISvector(RISservice, RIS ,BS)
global sim;
RISnumpersite=sim.RISnumpersite;
sitenum=sim.sitenum;
RISnum=sitenum*RISnumpersite*3;
 unit_vector_ris=cell(RISnum,1);
for i=1:RISnum
    BSid=RISservice(i).anchorcellid;
 
    BSid=ceil(BSid/3);
 
    longth=sqrt((BS{BSid}.site(1)- RIS{i}.site(1))^2+(BS{BSid}.site(2)-RIS{i}.site(2))^2+(BS{BSid}.site(3)- RIS{i}.site(3))^2);
    unit_vector_ris{i}=[(BS{BSid}.site(1)- RIS{i}.site(1))/longth (BS{BSid}.site(2)- RIS{i}.site(2))/longth ,...
        (BS{BSid}.site(3)- RIS{i}.site(3))/longth ];
   
    
end