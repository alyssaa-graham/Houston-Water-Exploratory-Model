% This script runs +8,000 scenarios with random combos of parameters:
% population growth, industrial increased or decreased water demand,
% irrigation increased or decreased water demand, and increased drought 
% conditions from 2011 (baseline is 2011 conditions). The graph produced
% shows all scenarios over the course of a year for the combined volume of
% the three reservoirs.
%
% Currently commented code near bottom can be uncommented to graph 
% one specific scenario if desired.
%
% Author: Alyssa Graham
% Organization: Civil and Environmental Engineering Dept, Rice University
%

% Baseline scenario:
% 2011 inflows, releases, and net evaporation
% 2021 diversions (municipal, agricultural, and industrial
%
% Population growth scenarios
% - municipal diversion is increased for all three reservoirs by 30%, 70%,
%   130%
%
% Industrial demand scenarios
% - industrial diversion for all three reservoirs is varied: decreased by
%   70%; increased by 50% and 120%
% 
% Irrigation demand scenarios
% - agricultural diversion for all three reservoirs is varied: decreased by
%   50%; increased by 60% and 130%
%
% Worse drought scenarios
% - inflows decreased for all three reservoirs by 30%, 60%,
%   and 80%
% - evaporation increased for all three reservoirs by 30%, 60%,
%   and 80%
%
% Groundwater reduction scenarios
% - 2021 volume of groundwater use is subtracted as additional demand
%
% Proposed strategies scenarios
% - additional volume added based on numbers provided by Houston for 2030,
% 2050, and 2070

% One year timeseries with weekly timestep:
weeks = 52;
% Unit Conversions
acreft_m3 = 1233.48; %acreft to m3
in_m = 0.0254; %inches to meters
ft3_acreft = 2.296E-5; %ft3 to acreft

max_capacity = 2296322;%acre-ft
groundwater = 3974.2;%acre-ft/week
Allens_stor_2040 = 1954.88;%acre-ft/week
Reuse_2030 = 21.0;%acre-ft/week
Reuse_2050 = 3571.8;%acre-ft/week
Reuse_2070 = 3758.7;%acre-ft/week
Demand_reduce_2030 = 604.7;%acre-ft/week
Demand_reduce_2050 = 1095.4;%acre-ft/week
Demand_reduce_2070 = 1603.4;%acre-ft/week
Surface_2030 = 399.9;%acre-ft/week
Surface_2050 = 5878.4;%acre-ft/week
Surface_2070 = 6549.1;%acre-ft/week

Tot_2030 = Reuse_2030 + Demand_reduce_2030 + Surface_2030;
Tot_2050 = Reuse_2050 + Demand_reduce_2050 + Surface_2050;
Tot_2070 = Reuse_2070 + Demand_reduce_2070 + Surface_2070;

Pop_param = [1 1.3 1.7 2.3];
Ind_param = [1 0.3 1.5 2.2];
Ag_param = [1 0.5 1.6 2.3];
Inflow_param = [1 0.7 0.4 0.2];
Evap_param = [1 1.3 1.6 1.8];
GW_param = [0 1];
Add_Water_param = [0 Tot_2030 Tot_2050 Tot_2070];


pop_length = length(Pop_param);
ind_length = length(Ind_param);
ag_length = length(Ag_param);
flo_length = length(Inflow_param);
evp_length = length(Evap_param);
gw_length = length(GW_param);
add_length = length(Add_Water_param);


Min_Vol = 0;
Scenario = 0;
for r = 1:gw_length
    for i = 1:add_length
       for q = 1:evp_length
           for j =  1:pop_length
               for p = 1:flo_length
                   for m = 1:ag_length
                       for k = 1:ind_length

                           hou_evap = readmatrix('ResData_MonteCarlo.csv','Range','B12:B62');
                           liv_evap = readmatrix('ResData_MonteCarlo.csv','Range','L12:L62');
                           con_evap = readmatrix('ResData_MonteCarlo.csv','Range','T12:T62');

                           % SJRA pumps water from Lake Houston that is a
                           % combination of municipal, industrial, and
                           % irrigation. Assume SJRA diversion is split eveny
                           % between mun, ind, and ag.
                           hou_SJRA_demand = (readmatrix('ResData_MonteCarlo.csv','Range','F12:F62'))/3;
                           hou_mun_demand = readmatrix('ResData_MonteCarlo.csv','Range','D12:D62');
                           hou_mun_demand = (hou_mun_demand+hou_SJRA_demand)*Pop_param(j);
                           hou_ind_demand = readmatrix('ResData_MonteCarlo.csv','Range','E12:E62');
                           hou_ind_demand = (hou_ind_demand+hou_SJRA_demand)*Ind_param(k);
                           hou_ag_demand = readmatrix('ResData_MonteCarlo.csv','Range','G12:G62');
                           hou_ag_demand = (hou_ag_demand+hou_SJRA_demand)*Ag_param(m);
                           hou_total_demand = hou_mun_demand+hou_ind_demand+hou_ag_demand;

                           liv_mun_demand = readmatrix('ResData_MonteCarlo.csv','Range','N12:N62');
                           liv_mun_demand = liv_mun_demand*Pop_param(j);
                           liv_ind_demand = readmatrix('ResData_MonteCarlo.csv','Range','O12:O62');
                           liv_ind_demand = liv_ind_demand*Ind_param(k);
                           liv_ag_demand = readmatrix('ResData_MonteCarlo.csv','Range','P12:P62');
                           liv_ag_demand = liv_ag_demand*Ag_param(m);
                           liv_total_demand = liv_mun_demand+liv_ind_demand+liv_ag_demand;

                           con_mun_demand = readmatrix('ResData_MonteCarlo.csv','Range','W12:W62');
                           con_mun_demand = con_mun_demand*Pop_param(j);
                           con_ind_demand = readmatrix('ResData_MonteCarlo.csv','Range','X12:X62');
                           con_ind_demand = con_ind_demand*Ind_param(k);
                           con_ag_demand = readmatrix('ResData_MonteCarlo.csv','Range','Y12:Y62');
                           con_ag_demand = con_ag_demand*Ag_param(m);
                           con_total_demand = con_mun_demand+con_ind_demand+con_ag_demand;

                           Houston_inflows = readmatrix('ResData_MonteCarlo.csv','Range','A12:A62');
                           Houston_inflows = Houston_inflows*Inflow_param(p);
                           Liv_inflow = readmatrix('ResData_MonteCarlo.csv','Range','I12:I62');
                           Liv_add_inflow = readmatrix('ResData_MonteCarlo.csv','Range','J12:J62');
                           % inflows in data already have the total 2011
                           % diversions subtracted, so need to add them back in
                           Liv_total_div = readmatrix('ResData_MonteCarlo.csv','Range','K12:K62');
                           Livingston_inflows = (Liv_inflow+Liv_add_inflow+Liv_total_div)*Inflow_param(p);
                           Conroe_inflows = readmatrix('ResData_MonteCarlo.csv','Range','S12:S62');
                           Conroe_inflows = Conroe_inflows*Inflow_param(p);

                           Hou_rel = readmatrix('ResData_MonteCarlo.csv','Range','C12:C62');
                           Liv_rel = readmatrix('ResData_MonteCarlo.csv','Range','M12:M62');
                           Liv_rel_add = readmatrix('ResData_MonteCarlo.csv','Range','M12:M62');
                           Con_rel = readmatrix('ResData_MonteCarlo.csv','Range','U12:U62');
                           Con_rel_add = readmatrix('ResData_MonteCarlo.csv','Range','V12:V62');

                           hou_init_stor = 162213.62;%acre-ft
                           liv_init_stor = 1754570;%acre-ft
                           con_init_stor = 395091;%acre-ft
                           total_init_stor = hou_init_stor + liv_init_stor + con_init_stor;

                           Hou_Data(1,1) = hou_init_stor;
                           Liv_Data(1,1) = liv_init_stor;
                           Con_Data(1,1) = con_init_stor;
                           Tot_Data(1,1) = total_init_stor;
                           Demand_Met(1,1) = 1;

                           for n = 1:weeks-1

                               Hou_evap = hou_evap(n);
                               if Hou_evap < 0
                                   Hou_evap = Hou_evap*Evap_param(q);
                               else
                                   Hou_evap = Hou_evap*(1-(Evap_param(q)-1));
                               end
                               Liv_evap = liv_evap(n);
                               if Liv_evap < 0
                                   Liv_evap = Liv_evap*Evap_param(q);
                               else
                                   Liv_evap = Liv_evap*(1-(Evap_param(q)-1));
                               end
                               Con_evap = con_evap(n);
                               if Con_evap < 0
                                   Con_evap = Con_evap*Evap_param(q);
                               else
                                   Con_evap = Con_evap*(1-(Evap_param(q)-1));
                               end

                               Hou_inflow = Houston_inflows(n);
                               Liv_inflow = Livingston_inflows(n);
                               Con_inflow = Conroe_inflows(n);

                               Hou_total_demand = hou_total_demand(n);
                               Liv_total_demand = liv_total_demand(n);
                               Con_total_demand = con_total_demand(n);

                               Hou_release = Hou_rel(n);
                               Liv_release = Liv_rel(n)+Liv_rel_add(n);
                               Con_release = Con_rel(n)+Con_rel_add(n);

                               GW = groundwater*GW_param(r);

                               hou_new_stor = hou_init_stor + Hou_inflow + Hou_evap - Hou_total_demand - Hou_release - GW/3;
                               hou_init_stor = hou_new_stor;

                               liv_new_stor = liv_init_stor + Liv_inflow + Liv_evap - Liv_total_demand - Liv_release - GW/3;
                               liv_init_stor = liv_new_stor;

                               con_new_stor = con_init_stor + Con_inflow + Con_evap  - Con_total_demand - Con_release - GW/3;
                               con_init_stor = con_new_stor;

                               add_supply = Add_Water_param(i);

                               total_stor = hou_new_stor + liv_new_stor + con_new_stor + add_supply;
                               demand_thru_plant = hou_mun_demand(n) + liv_mun_demand(n) + con_mun_demand(n);
                               

                               sz = size(Hou_Data,1)+1;
                               Hou_Data(sz,1) = hou_new_stor;

                               sz = size(Liv_Data,1)+1;
                               Liv_Data(sz,1) = liv_new_stor;

                               sz = size(Con_Data,1)+1;
                               Con_Data(sz,1) = con_new_stor;

                               sz = size(Tot_Data,1)+1;
                               Tot_Data(sz,1) = total_stor;
                           end

                           figure(1)
                           Total_Stor = timeseries(Tot_Data(:,1),1:52);
                           Total_Stor.TimeInfo.Units = 'weeks';
                           Total_Stor.TimeInfo.StartDate = 'Jan';
                           Total_Stor.TimeInfo.Format = 'mmm';
                           Total_Stor.Time = Total_Stor.Time - Total_Stor.Time(1);
%                            if Pop_param(j)==1 && Ind_param(k)==1 && Ag_param(m)==1 && Inflow_param(p)==1 && Evap_param(q)==1 && GW_param(r)==0 && Add_Water_param(i)==0
%                                plot(Total_Stor,'k','linewidth',4)
%                            if Pop_param(j)==1.7 && Ind_param(k)==2.2 && Ag_param(m)==1.6 && Inflow_param(p)==0.7 && Evap_param(q)==1.6 && GW_param(r)==1 && Add_Water_param(i)==Tot_2050
%                                plot(Total_Stor,'Color',[0 0.4470 0.7410],'linewidth',4)
%                            elseif Pop_param(j)==1.7 && Ind_param(k)==1.5 && Ag_param(m)==1 && Inflow_param(p)==0.4 && Evap_param(q)==1.6 && GW_param(r)==1 && Add_Water_param(i)==Tot_2050
%                                plot(Total_Stor,'Color',[0.8500 0.3250 0.0980],'linewidth',4)
%                            elseif Pop_param(j)==1.7 && Ind_param(k)==1 && Ag_param(m)==1 && Inflow_param(p)==0.4 && Evap_param(q)==1.6 && GW_param(r)==1 && Add_Water_param(i)==Tot_2070
%                                plot(Total_Stor,'Color',[0.9290 0.6940 0.1250],'linewidth',4)
    %                        elseif Pop_param(j)==1.3 && Ind_param(k)==1.5 && Ag_param(m)==1.3 && Inflow_param(p)==0.4 && Evap_param(q)==1.2
    %                            plot(Total_Stor,'Color',[0.4940 0.1840 0.5560],'linewidth',3)
    %                        elseif Pop_param(j)==2 && Ind_param(k)==1.5 && Ag_param(m)==2 && Inflow_param(p)==1 && Evap_param(q)==1
    %                            plot(Total_Stor,'Color',[0.4660 0.6740 0.1880],'linewidth',3)
%                            elseif Pop_param(j)==1.3 && Ind_param(k)==0 && Ag_param(m)==0.5 && Inflow_param(p)==0.2 && Evap_param(q)==1.6
%                                plot(Total_Stor,'Color',[0.6350 0.0780 0.1840],'linewidth',3)
%                            elseif Pop_param(j)==1 && Ind_param(k)==1 && Ag_param(m)==1 && Inflow_param(p)==1 && Evap_param(q)==1
%                                plot(Total_Stor,'Color',[0 0.4470 0.7410],'linewidth',3)
%                            else
%                                plot(Total_Stor,'Color',[.9 .9 .9])
%                            end
                           plot(Total_Stor)
                           title('Deterministic Monte Carlo with 32,768 scenarios of Houston WUG reservoirs')
                           ylabel('Total Reservoir Storage Volume (acre-ft)')
                           grid on
                           hold on

    %                        figure(2)
    %                        Hou_Stor = timeseries(Hou_Data(:,1),1:52);
    %                        Hou_Stor.TimeInfo.Units = 'weeks';
    %                        Hou_Stor.TimeInfo.StartDate = 'Jan';
    %                        Hou_Stor.TimeInfo.Format = 'mmm';
    %                        Hou_Stor.Time = Hou_Stor.Time - Hou_Stor.Time(1);
    %                        if j==1.6 && k==0.5 && m==1.5 && p==0.4 && q==1.6
    %                            plot(Hou_Stor,'color','#0072BD','Linewidth','4')
    %                        elseif j==1 && k==1.5 && m==1.3 && p==0.4 && q==1
    %                            plot(Hou_Stor,'color','#D95319','Linewidth','4')
    %                        elseif j==1 && k==1.5 && m==1 && p==0.2 && q==1.2
    %                            plot(Hou_Stor,'color','#EDB120','Linewidth','4')
    %                        elseif j==1 && k==1 && m==1 && p==0.2 && q==1.4
    %                            plot(Hou_Stor,'color','#7E2F8E','Linewidth','4')
    %                        elseif j==1.3 && k==1.5 && m==1.3 && p==0.4 && q==1.2
    %                            plot(Hou_Stor,'color','#77AC30','Linewidth','4')
    %                        elseif j==2 && k==1.5 && m==2 && p==1 && q==1
    %                            plot(Hou_Stor,'color','#4DBEEE','Linewidth','4')
    %                        elseif j==1.3 && k==0 && m==0.5 && p==0.2 && q==1.6
    %                            plot(Hou_Stor,'color','#A2142F','Linewidth','4')
    %                        else
    %                            plot(Hou_Stor,':k')
    %                        end
    %                        title('Lake Houston Storage Monte Carlo Simulation')
    %                        ylabel('Storage Volume (acre-ft)')
    %                        grid on
    %                        hold on
    %                        
    %                        figure(3)
    %                        Liv_Stor = timeseries(Liv_Data(:,1),1:52);
    %                        Liv_Stor.TimeInfo.Units = 'weeks';
    %                        Liv_Stor.TimeInfo.StartDate = 'Jan';
    %                        Liv_Stor.TimeInfo.Format = 'mmm';
    %                        Liv_Stor.Time = Liv_Stor.Time - Liv_Stor.Time(1);
    %                        if j==1.6 && k==0.5 && m==1.5 && p==0.4 && q==1.6
    %                            plot(Liv_Stor,'color','#0072BD','Linewidth','4')
    %                        elseif j==1 && k==1.5 && m==1.3 && p==0.4 && q==1
    %                            plot(Liv_Stor,'color','#D95319','Linewidth','4')
    %                        elseif j==1 && k==1.5 && m==1 && p==0.2 && q==1.2
    %                            plot(Liv_Stor,'color','#EDB120','Linewidth','4')
    %                        elseif j==1 && k==1 && m==1 && p==0.2 && q==1.4
    %                            plot(Liv_Stor,'color','#7E2F8E','Linewidth','4')
    %                        elseif j==1.3 && k==1.5 && m==1.3 && p==0.4 && q==1.2
    %                            plot(Liv_Stor,'color','#77AC30','Linewidth','4')
    %                        elseif j==2 && k==1.5 && m==2 && p==1 && q==1
    %                            plot(Liv_Stor,'color','#4DBEEE','Linewidth','4')
    %                        elseif j==1.3 && k==0 && m==0.5 && p==0.2 && q==1.6
    %                            plot(Liv_Stor,'color','#A2142F','Linewidth','4')
    %                        else
    %                            plot(Liv_Stor,':k')
    %                        end
    %                        title('Lake Livingston Storage Monte Carlo Simulation')
    %                        ylabel('Storage Volume (acre-ft)')
    %                        grid on
    %                        hold on
    %                        
    %                        figure(4)
    %                        Con_Stor = timeseries(Con_Data(:,1),1:52);
    %                        Con_Stor.TimeInfo.Units = 'weeks';
    %                        Con_Stor.TimeInfo.StartDate = 'Jan';
    %                        Con_Stor.TimeInfo.Format = 'mmm';
    %                        Con_Stor.Time = Con_Stor.Time - Con_Stor.Time(1);
    %                        if j==1.6 && k==0.5 && m==1.5 && p==0.4 && q==1.6
    %                            plot(Con_Stor,'color','#0072BD','Linewidth','4')
    %                        elseif j==1 && k==1.5 && m==1.3 && p==0.4 && q==1
    %                            plot(Con_Stor,'color','#D95319','Linewidth','4')
    %                        elseif j==1 && k==1.5 && m==1 && p==0.2 && q==1.2
    %                            plot(Con_Stor,'color','#EDB120','Linewidth','4')
    %                        elseif j==1 && k==1 && m==1 && p==0.2 && q==1.4
    %                            plot(Con_Stor,'color','#7E2F8E','Linewidth','4')
    %                        elseif j==1.3 && k==1.5 && m==1.3 && p==0.4 && q==1.2
    %                            plot(Con_Stor,'color','#77AC30','Linewidth','4')
    %                        elseif j==2 && k==1.5 && m==2 && p==1 && q==1
    %                            plot(Con_Stor,'color','#4DBEEE','Linewidth','4')
    %                        elseif j==1.3 && k==0 && m==0.5 && p==0.2 && q==1.6
    %                            plot(Con_Stor,'color','#A2142F','Linewidth','4')
    %                        else
    %                            plot(Con_Stor,':k')
    %                        end
    %                        title('Lake Conroe Storage Monte Carlo Simulation')
    %                        ylabel('Storage Volume (acre-ft)')
    %                        grid on
    %                        hold on

                           s = sign(Hou_Data);
                           Neg_Hou=sum(s(:)==-1);

                           s = sign(Liv_Data);
                           Neg_Liv=sum(s(:)==-1);

                           s = sign(Con_Data);
                           Neg_Con=sum(s(:)==-1);

                           s = sign(Tot_Data);
                           Neg_Tot=sum(s(:)==-1);

                           Min_hou_vol = min(Hou_Data);
                           Min_hou_week = find(Hou_Data==Min_hou_vol);
                           Min_liv_vol = min(Liv_Data);
                           Min_liv_week = find(Liv_Data==Min_liv_vol);
                           Min_con_vol = min(Con_Data);
                           Min_con_week = find(Con_Data==Min_con_vol);
                           Min_tot_vol = min(Tot_Data);
                           Min_tot_week = find(Tot_Data==Min_tot_vol);

                           sz = size(Min_Vol,1)+1;
                           Min_Vol(sz,1) = Min_hou_week;
                           Min_Vol(sz,2) = Min_hou_vol;
                           Min_Vol(sz,3) = Min_liv_week;
                           Min_Vol(sz,4) = Min_liv_vol;
                           Min_Vol(sz,5) = Min_con_week;
                           Min_Vol(sz,6) = Min_con_vol;
                           Min_Vol(sz,7) = Min_tot_week;
                           Min_Vol(sz,8) = Min_tot_vol;
                           Min_Vol(sz,9) = Neg_Hou;
                           Min_Vol(sz,10) = Neg_Liv;
                           Min_Vol(sz,11) = Neg_Con;
                           Min_Vol(sz,12) = Neg_Tot;
                           
                           s = sign(Tot_Data - 0.2*(max_capacity));
                           Near_fail = sum(s(:)==-1);
                           s = sign(Tot_Data - 0.5*(max_capacity));
                           Half_out = sum(s(:)==-1);

                           sz = size(Scenario,1)+1;
                           Scenario(sz,1) = Pop_param(j);
                           Scenario(sz,2) = Ind_param(k);
                           Scenario(sz,3) = Ag_param(m);
                           Scenario(sz,4) = Inflow_param(p);
                           Scenario(sz,5) = Evap_param(q);
                           Scenario(sz,6) = GW_param(r);
                           Scenario(sz,7) = Add_Water_param(i);
                           Scenario(sz,8) = Min_tot_week;
                           Scenario(sz,9) = Min_tot_vol;
                           % number of weeks storage goes below zero
                           Scenario(sz,10) = Neg_Tot;
                           % number of weeks storage goes below 20%
                           % total res capacity
                           Scenario(sz,11) = Near_fail;
                           % number of weeks storage goes below 50%
                           % total res capacity
                           Scenario(sz,12) = Half_out;

                           Hou_Data = 0;
                           Liv_Data = 0;
                           Con_Data = 0;
                           Tot_Data = 0;

                       end

                   end

               end

           end

       end
    end
end

% % Add specific case
% Pop_param=1.7;
% Ind_param=2.2;
% Ag_param=1.6;
% Inflow_param=0.7;
% Evap_param=1.3;
% GW_param=1;
% Add_Water_param=Tot_2050;
% Hou_Data = 0;
% Liv_Data = 0;
% Con_Data = 0;
% Tot_Data = 0;
% 
% hou_evap = readmatrix('ResData_MonteCarlo.csv','Range','B12:B62');
% liv_evap = readmatrix('ResData_MonteCarlo.csv','Range','L12:L62');
% con_evap = readmatrix('ResData_MonteCarlo.csv','Range','T12:T62');
% 
% % SJRA pumps water from Lake Houston that is a
% % combination of municipal, industrial, and
% % irrigation. Assume SJRA diversion is split eveny
% % between mun, ind, and ag.
% hou_SJRA_demand = (readmatrix('ResData_MonteCarlo.csv','Range','F12:F62'))/3;
% hou_mun_demand = readmatrix('ResData_MonteCarlo.csv','Range','D12:D62');
% hou_mun_demand = (hou_mun_demand+hou_SJRA_demand)*Pop_param;
% hou_ind_demand = readmatrix('ResData_MonteCarlo.csv','Range','E12:E62');
% hou_ind_demand = (hou_ind_demand+hou_SJRA_demand)*Ind_param;
% hou_ag_demand = readmatrix('ResData_MonteCarlo.csv','Range','G12:G62');
% hou_ag_demand = (hou_ag_demand+hou_SJRA_demand)*Ag_param;
% hou_total_demand = hou_mun_demand+hou_ind_demand+hou_ag_demand;
% 
% liv_mun_demand = readmatrix('ResData_MonteCarlo.csv','Range','N12:N62');
% liv_mun_demand = liv_mun_demand*Pop_param;
% liv_ind_demand = readmatrix('ResData_MonteCarlo.csv','Range','O12:O62');
% liv_ind_demand = liv_ind_demand*Ind_param;
% liv_ag_demand = readmatrix('ResData_MonteCarlo.csv','Range','P12:P62');
% liv_ag_demand = liv_ag_demand*Ag_param;
% liv_total_demand = liv_mun_demand+liv_ind_demand+liv_ag_demand;
% 
% con_mun_demand = readmatrix('ResData_MonteCarlo.csv','Range','W12:W62');
% con_mun_demand = con_mun_demand*Pop_param;
% con_ind_demand = readmatrix('ResData_MonteCarlo.csv','Range','X12:X62');
% con_ind_demand = con_ind_demand*Ind_param;
% con_ag_demand = readmatrix('ResData_MonteCarlo.csv','Range','Y12:Y62');
% con_ag_demand = con_ag_demand*Ag_param;
% con_total_demand = con_mun_demand+con_ind_demand+con_ag_demand;
% 
% Houston_inflows = readmatrix('ResData_MonteCarlo.csv','Range','A12:A62');
% Houston_inflows = Houston_inflows*Inflow_param;
% Liv_inflow = readmatrix('ResData_MonteCarlo.csv','Range','I12:I62');
% Liv_add_inflow = readmatrix('ResData_MonteCarlo.csv','Range','J12:J62');
% % inflows in data already have the total 2011
% % diversions subtracted, so need to add them back in
% Liv_total_div = readmatrix('ResData_MonteCarlo.csv','Range','K12:K62');
% Livingston_inflows = (Liv_inflow+Liv_add_inflow+Liv_total_div)*Inflow_param;
% Conroe_inflows = readmatrix('ResData_MonteCarlo.csv','Range','S12:S62');
% Conroe_inflows = Conroe_inflows*Inflow_param;
% 
% Hou_rel = readmatrix('ResData_MonteCarlo.csv','Range','C12:C62');
% Liv_rel = readmatrix('ResData_MonteCarlo.csv','Range','M12:M62');
% Liv_rel_add = readmatrix('ResData_MonteCarlo.csv','Range','M12:M62');
% Con_rel = readmatrix('ResData_MonteCarlo.csv','Range','U12:U62');
% Con_rel_add = readmatrix('ResData_MonteCarlo.csv','Range','V12:V62');
% 
% hou_init_stor = 162213.62;%acre-ft
% liv_init_stor = 1754570;%acre-ft
% con_init_stor = 395091;%acre-ft
% total_init_stor = hou_init_stor + liv_init_stor + con_init_stor;
% 
% Hou_Data(1,1) = hou_init_stor;
% Liv_Data(1,1) = liv_init_stor;
% Con_Data(1,1) = con_init_stor;
% Tot_Data(1,1) = total_init_stor;
% 
% for n = 1:weeks-1
% 
%    Hou_evap = hou_evap(n);
%    if Hou_evap < 0
%        Hou_evap = Hou_evap*Evap_param;
%    else
%        Hou_evap = Hou_evap*(1-(Evap_param-1));
%    end
%    Liv_evap = liv_evap(n);
%    if Liv_evap < 0
%        Liv_evap = Liv_evap*Evap_param;
%    else
%        Liv_evap = Liv_evap*(1-(Evap_param-1));
%    end
%    Con_evap = con_evap(n);
%    if Con_evap < 0
%        Con_evap = Con_evap*Evap_param;
%    else
%        Con_evap = Con_evap*(1-(Evap_param-1));
%    end
% 
%    Hou_inflow = Houston_inflows(n);
%    Liv_inflow = Livingston_inflows(n);
%    Con_inflow = Conroe_inflows(n);
% 
%    Hou_total_demand = hou_total_demand(n);
%    Liv_total_demand = liv_total_demand(n);
%    Con_total_demand = con_total_demand(n);
% 
%    Hou_release = Hou_rel(n);
%    Liv_release = Liv_rel(n)+Liv_rel_add(n);
%    Con_release = Con_rel(n)+Con_rel_add(n);
% 
%    GW = groundwater*GW_param;
% 
%    hou_new_stor = hou_init_stor + Hou_inflow + Hou_evap - Hou_total_demand - Hou_release;
%    hou_init_stor = hou_new_stor;
% 
%    liv_new_stor = liv_init_stor + Liv_inflow + Liv_evap - Liv_total_demand - Liv_release;
%    liv_init_stor = liv_new_stor;
% 
%    con_new_stor = con_init_stor + Con_inflow + Con_evap  - Con_total_demand - Con_release;
%    con_init_stor = con_new_stor;
% 
%    add_supply = Add_Water_param;
% 
%    total_stor = hou_new_stor + liv_new_stor + con_new_stor + add_supply - GW;
% 
% 
%    sz = size(Hou_Data,1)+1;
%    Hou_Data(sz,1) = hou_new_stor;
% 
%    sz = size(Liv_Data,1)+1;
%    Liv_Data(sz,1) = liv_new_stor;
% 
%    sz = size(Con_Data,1)+1;
%    Con_Data(sz,1) = con_new_stor;
% 
%    sz = size(Tot_Data,1)+1;
%    Tot_Data(sz,1) = total_stor;
% end
% hold on
% Total_Stor = timeseries(Tot_Data(:,1),1:52);
% Total_Stor.TimeInfo.Units = 'weeks';
% Total_Stor.TimeInfo.StartDate = 'Jan';
% Total_Stor.TimeInfo.Format = 'mmm';
% Total_Stor.Time = Total_Stor.Time - Total_Stor.Time(1);
% plot(Total_Stor,'Color',[0 0.4470 0.7410],'linewidth',4)
% title('Scenario: 2050 possible scenario')
% ylabel('Storage Volume (acre-ft)')
% grid on

                           
hold off
%    figure(2)
%    histogram(Min_Vol(:,2))
%    title('Lake Houston Lowest Annual Volume in +8,000 Scenarios')
%    xlabel('Volume (acre-ft)')
%    hold off
%    figure(3)
%    histogram(Min_Vol(:,4))
%    title('Lake Livingston Lowest Annual Volume in +8,000 Scenarios')
%    xlabel('Volume (acre-ft)')
%    hold off
%    figure(4)
%    histogram(Min_Vol(:,6))
%    title('Lake Conroe Lowest Annual Volume in +8,000 Scenarios')
%    xlabel('Volume (acre-ft)')
%    hold off
%    figure(5)
%    histogram(Min_Vol(:,8))
%    title('Total Lowest Annual Volume for All Reservoirs in +8,000 Scenarios')
%    xlabel('Volume (acre-ft)')
%    hold off
% 
