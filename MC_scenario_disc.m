% This script can be used to parse through and print scenarios in a large
% ensemble that meet certain criterion. The criterion can be specified in
% the if statement within the for loop. In this case, the ensemble of
% scenarios was generated with monte_carlo_explore.m and transferred to a
% CSV file called 'Results_MC.csv'.
%
% Author: Alyssa Graham
% Organization: Civil and Environmental Engineering Dept, Rice University
%
Pop_scenario = readmatrix('Results_MC.csv','Range','A5:A8196');
Ind_scenario = readmatrix('Results_MC.csv','Range','B5:B8196');
Ag_scenario = readmatrix('Results_MC.csv','Range','C5:C8196');
Inflow_scenario = readmatrix('Results_MC.csv','Range','D5:D8196');
Evap_scenario = readmatrix('Results_MC.csv','Range','E5:E8196');
GW_scenario = readmatrix('Results_MC.csv','Range','F5:F8196');
Add_water_scenario = readmatrix('Results_MC.csv','Range','G5:G8196');

% number of weeks with storage below zero
Fail_weeks = readmatrix('Results_MC.csv','Range','S5:S8196');
% number of weeks with storage below 20% capacity
NearFail_weeks = readmatrix('Results_MC.csv','Range','T5:T8196');
% number of weeks with storage below 50% capacity
HalfFail_weeks = readmatrix('Results_MC.csv','Range','U5:U8196');

% scenairo data stored in matrix
Scenario = 0;

% change if statement to desired criterion
for i = 1:length(Fail_weeks)
    if HalfFail_weeks(i)>23 && NearFail_weeks(i)<4 && Inflow_scenario(i)>0.4 && Evap_scenario(i)<1.6 %&& Pop_scenario(i)<2.3 && Ag_scenario(i)<2.3 && Ind_scenario(i)<2.2
        sz = size(Scenario,1)+1;
        Scenario(sz,1) = Pop_scenario(i);
        Scenario(sz,2) = Inflow_scenario(i);
        Scenario(sz,3) = Ind_scenario(i);
        Scenario(sz,4) = Ag_scenario(i);
        Scenario(sz,5) = Evap_scenario(i);
        Scenario(sz,6) = GW_scenario(i);
        Scenario(sz,7) = Add_water_scenario(i);
        Scenario(sz,8) = Fail_weeks(i);
        Scenario(sz,9) = NearFail_weeks(i);
        Scenario(sz,10) = HalfFail_weeks(i);
    end
end
        