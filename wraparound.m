function [sitex_wrap,sitey_wrap] = wraparound(sitex,sitey)

global sim;
r=sim.intersitedistance; %%r «ISD

site_num=length(sitex);
sitex_wrap=[sitex sitex+4*r sitex+7*r/2 sitex-1/2*r sitex-4*r sitex-7/2*r sitex+r/2];
sitey_wrap=[sitey sitey+sqrt(3)*r sitey-3*sqrt(3)/2*r sitey-5*sqrt(3)/2*r  sitey-sqrt(3)*r sitey+3*sqrt(3)/2*r sitey+5*sqrt(3)/2*r];

