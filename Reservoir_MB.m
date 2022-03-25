% This script performs a mass balance over three reservoirs (Lakes Houston,
% Livingston, and Conroe), to model the weekly change in reservoir storage
% over the course of a year. The model also serves to adjust raw
% inflow/outflow data using historical reservoir storage data in order to
% provide more accurate inflows and outflows for further modeling uses.
% This script is currently set to calculate the mass balance for the year
% 2011; however, input data can be exchanged for any preferred year.
%
% The function EvapREAD.m is called.
%
% Author: Alyssa Graham
% Organization: Civil and Environmental Engineering Dept, Rice University
%

% All values currently from 2011 drought data:
weeks = 52;
% read historical reservoir storage volume for every 7 days
n = 7;
% Unit Conversions
acreft_m3 = 1233.48; %acreft to m3
in_m = 0.0254; %inches to meters
ft3_acreft = 2.296E-5; %ft3 to acreft
m_ft = 3.28084; %m to ft

hou_init_stor = 162213.62;%acre-ft
hou_stor = readmatrix('Hou_Rel_Inf_2011.csv','Range','N3:N367');
hou_actual_stor = arrayfun(@(i) hou_stor(i:n:i+n-1),1:n:length(hou_stor)-n+1);
hou_actual_stor = hou_actual_stor';

liv_init_stor = 1754570;%acre-ft
liv_stor = readmatrix('Liv_Rel_Inf_2011.csv','Range','G3:G367');
liv_actual_stor = arrayfun(@(i) liv_stor(i:n:i+n-1),1:n:length(liv_stor)-n+1);
liv_actual_stor = liv_actual_stor';

con_init_stor = 395091;%acre-ft
con_stor = readmatrix('Con_Rel_Inf_2011.csv','Range','E3:E367');
con_actual_stor = arrayfun(@(i) con_stor(i:n:i+n-1),1:n:length(con_stor)-n+1);
con_actual_stor = con_actual_stor';

% NET EVAPORATION
% read historical evaporation depths for reservoirs (m/d)
hou_evap_depth_mpd = (readmatrix('2011DailyEvapData.csv','Range','F4:F368')*in_m);
liv_con_evap_depth_mpd = (readmatrix('2011DailyEvapData.csv','Range','D4:D368')*in_m);
% convert to weekly evaporation depths (m/wk)
hou_evap_depth = arrayfun(@(i) sum(hou_evap_depth_mpd(i:i+n-1)),1:n:length(hou_evap_depth_mpd)-n+1);
hou_evap_depth = hou_evap_depth';
liv_con_evap_depth = arrayfun(@(i) sum(liv_con_evap_depth_mpd(i:i+n-1)),1:n:length(liv_con_evap_depth_mpd)-n+1);
liv_con_evap_depth = liv_con_evap_depth';

% convert Houston to ft since area used in this case is in acres
hou_evap_depth = hou_evap_depth*m_ft;
hou_area = readmatrix('Hou_Rel_Inf_2011.csv','Range','M3:M367');
hou_area = arrayfun(@(i) hou_area(i:n:i+n-1),1:n:length(hou_area)-n+1);
hou_area = hou_area';

% MUNICIPAL, AGRICULTURAL, AND INDUSTRIAL DEMAND
% acre-ft/day then convert to acre-ft/week by summing every 7 values and
% storing
hou_mun_demand = readmatrix('Hou_Div_2011.csv','Range','J3:J367');
hou_mun_demand = arrayfun(@(i) sum(hou_mun_demand(i:i+n-1)),1:n:length(hou_mun_demand)-n+1);
hou_mun_demand = hou_mun_demand';
hou_ag_demand = 0;
hou_ind_demand = readmatrix('Hou_Div_2011.csv','Range','H3:H367');
hou_ind_demand = arrayfun(@(i) sum(hou_ind_demand(i:i+n-1)),1:n:length(hou_ind_demand)-n+1);
hou_ind_demand = hou_ind_demand';
hou_SJRA_demand = readmatrix('Hou_Div_2011.csv','Range','F3:F367');
hou_SJRA_demand = arrayfun(@(i) sum(hou_SJRA_demand(i:i+n-1)),1:n:length(hou_SJRA_demand)-n+1);
hou_SJRA_demand = hou_SJRA_demand';
hou_total_demand = hou_mun_demand + hou_ag_demand + hou_ind_demand + hou_SJRA_demand;

liv_mun_demand = readmatrix('Liv_Div_2011.csv','Range','H2:H366');
liv_mun_demand = arrayfun(@(i) sum(liv_mun_demand(i:i+n-1)),1:n:length(liv_mun_demand)-n+1);
liv_mun_demand = liv_mun_demand';
liv_ag_demand = readmatrix('Liv_Div_2011.csv','Range','I2:I366');
liv_ag_demand = arrayfun(@(i) sum(liv_ag_demand(i:i+n-1)),1:n:length(liv_ag_demand)-n+1);
liv_ag_demand = liv_ag_demand';
liv_ind_demand = readmatrix('Liv_Div_2011.csv','Range','J2:J366');
liv_ind_demand = arrayfun(@(i) sum(liv_ind_demand(i:i+n-1)),1:n:length(liv_ind_demand)-n+1);
liv_ind_demand = liv_ind_demand';
liv_total_demand = liv_mun_demand + liv_ag_demand + liv_ind_demand;

con_mun_demand = readmatrix('Con_Div_2011.csv','Range','H2:H366');
con_mun_demand = arrayfun(@(i) sum(con_mun_demand(i:i+n-1)),1:n:length(con_mun_demand)-n+1);
con_mun_demand = con_mun_demand';
con_ag_demand = readmatrix('Con_Div_2011.csv','Range','I2:I366');
con_ag_demand = arrayfun(@(i) sum(con_ag_demand(i:i+n-1)),1:n:length(con_ag_demand)-n+1);
con_ag_demand = con_ag_demand';
con_ind_demand = readmatrix('Con_Div_2011.csv','Range','J2:J366');
con_ind_demand = arrayfun(@(i) sum(con_ind_demand(i:i+n-1)),1:n:length(con_ind_demand)-n+1);
con_ind_demand = con_ind_demand';
con_total_demand = con_mun_demand + con_ag_demand + con_ind_demand;

% groundwater is available as well
groundwater = 0;

Hou_Data = [];
Liv_Data = [];
Con_Data = [];

% INFLOWS
% average daily inflows in cfs
Hou_inflow_cfs = readmatrix('Hou_Rel_Inf_2011.csv','Range','I3:I367');
Liv_inflow_cfs = readmatrix('Liv_Rel_Inf_2011.csv','Range','D3:D367');
Con_inflow_cfs = readmatrix('W San Jacinto.csv','Range','D510:D874');
% convert to acre-ft per day based average daily cfs
Hou_inflow_afpd = Hou_inflow_cfs*3600*24*ft3_acreft;
Liv_inflow_afpd = Liv_inflow_cfs*3600*24*ft3_acreft;
Con_inflow_afpd = Con_inflow_cfs*3600*24*ft3_acreft;
% sum days in each week for total weekly inflow in acre-ft
Houston_inflows = arrayfun(@(i) sum(Hou_inflow_afpd(i:i+n-1)),1:n:length(Hou_inflow_afpd)-n+1);
Houston_inflows = Houston_inflows';
Livingston_inflows = arrayfun(@(i) sum(Liv_inflow_afpd(i:i+n-1)),1:n:length(Liv_inflow_afpd)-n+1);
Livingston_inflows = Livingston_inflows';
Conroe_inflows = arrayfun(@(i) sum(Con_inflow_afpd(i:i+n-1)),1:n:length(Con_inflow_afpd)-n+1);
Conroe_inflows = Conroe_inflows';

% MANDATED AND STORM-RELATED RELEASES
% average daily releases in cfs
hou_trel_cfs = readmatrix('Hou_Rel_Inf_2011.csv','Range','O3:O367');
liv_trel_cfs = readmatrix('Liv_Rel_Inf_2011.csv','Range','C3:C367');
% average daily releases in acre-ft/day
hou_trel_afpd = hou_trel_cfs*3600*24*ft3_acreft;
liv_trel_afpd = liv_trel_cfs*3600*24*ft3_acreft;
con_trel_afpd = readmatrix('Con_Rel_Inf_2011.csv','Range','F3:F367');
% sum days in each week for total weekly releases in acre-ft
Hou_total_release = arrayfun(@(i) sum(hou_trel_afpd(i:i+n-1)),1:n:length(hou_trel_afpd)-n+1);
Hou_total_release = Hou_total_release';
Liv_total_release = arrayfun(@(i) sum(liv_trel_afpd(i:i+n-1)),1:n:length(liv_trel_afpd)-n+1);
Liv_total_release = Liv_total_release';
Con_total_release = arrayfun(@(i) sum(con_trel_afpd(i:i+n-1)),1:n:length(con_trel_afpd)-n+1);
Con_total_release = Con_total_release';

Hou_Data(1,1) = 0;
Hou_Data(1,2) = 0;
Hou_Data(1,3) = hou_init_stor;
Hou_Data(1,4) = 0;
Hou_Data(1,5) = 0;
Hou_Data(1,6) = 0;
Hou_Data(1,7) = 0;
Hou_Data(1,8) = 0;
Hou_Data(1,9) = 0;
Hou_Data(1,10) = 0;
Hou_Data(1,11) = 0;

Liv_Data(1,1) = 0;
Liv_Data(1,2) = 0;
Liv_Data(1,3) = liv_init_stor;
Liv_Data(1,4) = 0;
Liv_Data(1,5) = 0;
Liv_Data(1,6) = 0;
Liv_Data(1,7) = 0;
Liv_Data(1,8) = 0;
Liv_Data(1,9) = 0;
Liv_Data(1,10) = 0;
Liv_Data(1,11) = 0;

Con_Data(1,1) = 0;
Con_Data(1,2) = 0;
Con_Data(1,3) = con_init_stor;
Con_Data(1,4) = 0;
Con_Data(1,5) = 0;
Con_Data(1,6) = 0;
Con_Data(1,7) = 0;
Con_Data(1,8) = 0;
Con_Data(1,9) = 0;
Con_Data(1,10) = 0;
Con_Data(1,11) = 0;
Con_Data(1,12) = 0;

hou_actual_init = hou_init_stor;
liv_actual_init = liv_init_stor;
con_actual_init = con_init_stor;

for i = 1:weeks-1

    [hou_evap_area,liv_evap_area,con_evap_area] = EvapREAD(hou_init_stor,liv_init_stor,con_init_stor);
    % Calculate net evap volume by multiplying depth by reservoir area
    
    Hou_evap = hou_area(i)*hou_evap_depth(i);%acre-ft/week
    Liv_evap = liv_evap_area*liv_con_evap_depth(i);%m3/week
    Con_evap = con_evap_area*liv_con_evap_depth(i);%m3/week
    
    % acre-ft/week
    Hou_inflow = Houston_inflows(i);
    Liv_inflow = Livingston_inflows(i);
    Con_inflow = Conroe_inflows(i);
    
    
    % acre-ft/week
    Hou_release = Hou_total_release(i);
    Liv_release = Liv_total_release(i);
    Con_release = Con_total_release(i);
    
    Hou_mun_demand = hou_mun_demand(i);
    Hou_ind_demand = hou_ind_demand(i);
%     Hou_ag_demand = hou_ag_demand(i);
    Hou_SJRA_demand = hou_SJRA_demand(i);
    Hou_total_demand = hou_total_demand(i);
    Liv_mun_demand = liv_mun_demand(i);
    Liv_ind_demand = liv_ind_demand(i);
    Liv_ag_demand = liv_ag_demand(i);
    Liv_total_demand = liv_total_demand(i);
    Con_mun_demand = con_mun_demand(i);
    Con_ind_demand = con_ind_demand(i);
    Con_ag_demand = con_ag_demand(i);
    Con_total_demand = con_total_demand(i);
    
    % calculate new storage after each week and weekly net change in
    % storage volume (acre-ft/week)
    
    % HOUSTON WEEKLY STORAGE CALC
    hou_new_stor = hou_init_stor + Hou_inflow + Hou_evap - Hou_total_demand;% - Hou_release;
    
    % account for when more water is in system than should be
    if hou_new_stor > hou_actual_stor(i+1)
        hou_add_release = hou_new_stor - hou_actual_stor(i+1);
        hou_new_stor = hou_actual_stor(i+1);
    else
        hou_add_release = 0;
    end
    
    hou_timestep_diff = hou_new_stor - hou_init_stor; 
    hou_actual_diff = hou_actual_stor(i+1) - hou_actual_init;
    
     % store data in matrix
    sz = size(Hou_Data,1)+1;
    Hou_Data(sz,1) = Hou_inflow;
    Hou_Data(sz,2) = Hou_evap;
    Hou_Data(sz,3) = hou_new_stor;
    Hou_Data(sz,4) = Hou_release;
    Hou_Data(sz,5) = Hou_total_demand;
    Hou_Data(sz,6) = hou_add_release;
    Hou_Data(sz,7) = hou_timestep_diff;
    Hou_Data(sz,8) = hou_actual_diff;
    Hou_Data(sz,9) = Hou_mun_demand;
    Hou_Data(sz,10) = Hou_ind_demand;
    Hou_Data(sz,11) = Hou_SJRA_demand;
    
    hou_init_stor = hou_new_stor;
    hou_actual_init = hou_actual_stor(i+1);
    
    % LIVINGSTON WEEKLY STORAGE CALC
    liv_new_stor = liv_init_stor + Liv_inflow +(Liv_evap/acreft_m3) - Liv_release;%  - Liv_total_demand ;
    
    % adjust for bias
    if liv_new_stor < liv_actual_stor(i+1)
        liv_add_inflow = liv_actual_stor(i+1) - liv_new_stor;
        liv_new_stor = liv_actual_stor(i+1);
    else
        liv_add_inflow = 0;
    end
    if liv_new_stor > liv_actual_stor(i+1)
        liv_add_release = liv_new_stor - liv_actual_stor(i+1);
        liv_new_stor = liv_actual_stor(i+1);
    else
        liv_add_release = 0;
    end
    
    liv_timestep_diff = liv_new_stor - liv_init_stor;
    liv_actual_diff = liv_actual_stor(i+1) - liv_actual_init;
    
    % store data in matrix
    sz = size(Liv_Data,1)+1;
    Liv_Data(sz,1) = Liv_inflow;
    Liv_Data(sz,2) = Liv_evap/acreft_m3;
    Liv_Data(sz,3) = liv_new_stor;
    Liv_Data(sz,4) = Liv_release;
    Liv_Data(sz,5) = Liv_total_demand;
    Liv_Data(sz,6) = liv_add_inflow;
    Liv_Data(sz,7) = liv_timestep_diff;
    Liv_Data(sz,8) = liv_actual_diff;
    Liv_Data(sz,9) = Liv_mun_demand;
    Liv_Data(sz,10) = Liv_ind_demand;
    Liv_Data(sz,11) = Liv_ag_demand;
    Liv_Data(sz,12) = liv_add_release;
    

    liv_init_stor = liv_new_stor;
    liv_actual_init = liv_actual_stor(i+1);
    
    % CONROE WEEKLY STORAGE CALC
    con_new_stor = con_init_stor + Con_inflow + Con_evap/acreft_m3 - Con_release - Con_total_demand;
    
    % adjust for bias in inflow and releases
    if con_new_stor < con_actual_stor(i)
        con_add_inflow = con_actual_stor(i) - con_new_stor;
        con_new_stor = con_new_stor + con_add_inflow;
    else
        con_add_inflow = 0;
    end
    
    Con_adj_inflow = Con_inflow + con_add_inflow;
    
    if con_new_stor > con_actual_stor(i)
        con_add_release = con_new_stor - con_actual_stor(i);
        con_new_stor = con_new_stor - con_add_release;
    else
        con_add_release = 0;
    end
    
    con_timestep_diff = con_new_stor - con_init_stor;
    con_actual_diff = con_actual_stor(i) - con_actual_init;
    
    % store data in matrix
    sz = size(Con_Data,1)+1;
    Con_Data(sz,1) = Con_inflow;
    Con_Data(sz,2) = Con_evap/acreft_m3;
    Con_Data(sz,3) = con_new_stor;
    Con_Data(sz,4) = Con_release;
    Con_Data(sz,5) = Con_total_demand;
    Con_Data(sz,6) = Con_adj_inflow;
    Con_Data(sz,7) = con_add_release;
    Con_Data(sz,8) = con_timestep_diff;
    Con_Data(sz,9) = con_actual_diff;
    Con_Data(sz,10) = Con_mun_demand;
    Con_Data(sz,11) = Con_ind_demand;
    Con_Data(sz,12) = Con_ag_demand;

    
    con_init_stor = con_new_stor;
    con_actual_init = con_actual_stor(i);
    
end

figure(1)
Hou_Weekly_Change = timeseries(Hou_Data(:,7),1:52);
Hou_Weekly_Change.TimeInfo.Units = 'weeks';
Hou_Weekly_Change.TimeInfo.StartDate = '01-Jan-2011';
Hou_Weekly_Change.TimeInfo.Format = 'mmm dd, yy';
Hou_Weekly_Change.Time = Hou_Weekly_Change.Time - Hou_Weekly_Change.Time(1);
plot(Hou_Weekly_Change, '-r')
grid on
Hou_Actual_Change = timeseries(Hou_Data(:,8),1:52);
Hou_Actual_Change.TimeInfo.Units = 'weeks';
Hou_Actual_Change.TimeInfo.StartDate = '01-Jan-2011';
Hou_Actual_Change.TimeInfo.Format = 'mmm dd, yy';
Hou_Actual_Change.Time = Hou_Actual_Change.Time - Hou_Actual_Change.Time(1);
hold on
plot(Hou_Actual_Change, '.b')
title('Houston Timestep Reservoir Volume Change 2011')
xlabel('Week')
ylabel('Storage Volume Change (acre-ft/week)')
legend('Houston Model','Houston Data','Location','best')
hold off
figure(2)
Liv_Weekly_Change = timeseries(Liv_Data(:,7),1:52);
Liv_Weekly_Change.TimeInfo.Units = 'weeks';
Liv_Weekly_Change.TimeInfo.StartDate = '01-Jan-2011';
Liv_Weekly_Change.TimeInfo.Format = 'mmm dd, yy';
Liv_Weekly_Change.Time = Liv_Weekly_Change.Time - Liv_Weekly_Change.Time(1);
plot(Liv_Weekly_Change, '-r')
grid on
Liv_Actual_Change = timeseries(Liv_Data(:,8),1:52);
Liv_Actual_Change.TimeInfo.Units = 'weeks';
Liv_Actual_Change.TimeInfo.StartDate = '01-Jan-2011';
Liv_Actual_Change.TimeInfo.Format = 'mmm dd, yy';
Liv_Actual_Change.Time = Liv_Actual_Change.Time - Liv_Actual_Change.Time(1);
hold on
plot(Liv_Actual_Change, '.b')
title('Livingston Timestep Reservoir Volume Change 2011')
xlabel('Week')
ylabel('Storage Volume Change (acre-ft/week)')
legend('Livingston Model','Livingston Data','Location','best')
hold off
figure(3)
Con_Weekly_Change = timeseries(Con_Data(:,8),1:52);
Con_Weekly_Change.TimeInfo.Units = 'weeks';
Con_Weekly_Change.TimeInfo.StartDate = '01-Jan-2011';
Con_Weekly_Change.TimeInfo.Format = 'mmm dd, yy';
Con_Weekly_Change.Time = Con_Weekly_Change.Time - Con_Weekly_Change.Time(1);
plot(Con_Weekly_Change, '-r')
grid on
Con_Actual_Change = timeseries(Con_Data(:,9),1:52);
Con_Actual_Change.TimeInfo.Units = 'weeks';
Con_Actual_Change.TimeInfo.StartDate = '01-Jan-2011';
Con_Actual_Change.TimeInfo.Format = 'mmm dd, yy';
Con_Actual_Change.Time = Con_Actual_Change.Time - Con_Actual_Change.Time(1);
hold on
plot(Con_Actual_Change, '.b')
title('Conroe Timestep Reservoir Volume Change 2011')
xlabel('Week')
ylabel('Storage Volume Change (acre-ft/week)')
legend('Conroe Model','Conroe Data','Location','best')
hold off
figure(4)
Hou_Model = timeseries(Hou_Data(:,3),1:52);
Hou_Model.TimeInfo.Units = 'weeks';
Hou_Model.TimeInfo.StartDate = '01-Jan-2011';
Hou_Model.TimeInfo.Format = 'mmm dd, yy';
Hou_Model.Time = Hou_Model.Time - Hou_Model.Time(1);
plot(Hou_Model,'-b')
grid on
Hou_Actual = timeseries(hou_actual_stor(:,1),1:52);
Hou_Actual.TimeInfo.Units = 'weeks';
Hou_Actual.TimeInfo.StartDate = '01-Jan-2011';
Hou_Actual.TimeInfo.Format = 'mmm dd, yy';
hold on
plot(Hou_Actual,'.k','MarkerSize',4)
title('Houston Model Validation 2011')
ylabel('Storage Volume (acre-ft/week)')
legend('Model Calculated','Historical Data','Location','best')
hold off
figure(5)
Liv_Model = timeseries(Liv_Data(:,3),1:52);
Liv_Model.TimeInfo.Units = 'weeks';
Liv_Model.TimeInfo.StartDate = '01-Jan-2011';
Liv_Model.TimeInfo.Format = 'mmm dd, yy';
plot(Liv_Model,'-m')
grid on
Liv_Actual = timeseries(liv_actual_stor(:,1),1:52);
Liv_Actual.TimeInfo.Units = 'weeks';
Liv_Actual.TimeInfo.StartDate = '01-Jan-2011';
Liv_Actual.TimeInfo.Format = 'mmm dd, yy';
hold on
plot(Liv_Actual,'.k','MarkerSize',4)
title('Livingston Model Validation 2011')
ylabel('Storage Volume (acre-ft/week)')
legend('Model Calculated','Historical Data','Location','best')
hold off
figure(6)
Con_Model = timeseries(Con_Data(:,3),1:52);
Con_Model.TimeInfo.Units = 'weeks';
Con_Model.TimeInfo.StartDate = '01-Jan-2011';
Con_Model.TimeInfo.Format = 'mmm dd, yy';
plot(Con_Model,'-g')
grid on
Con_Actual = timeseries(con_actual_stor(:,1),1:52);
Con_Actual.TimeInfo.Units = 'weeks';
Con_Actual.TimeInfo.StartDate = '01-Jan-2011';
Con_Actual.TimeInfo.Format = 'mmm dd, yy';
hold on
plot(Con_Actual,'.k','MarkerSize',4)
title('Conroe Model Validation 2011')
ylabel('Storage Volume (acre-ft/week)')
legend('Model Calculated','Historical Data','Location','best')