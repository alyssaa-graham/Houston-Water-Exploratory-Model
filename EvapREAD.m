% This function finds the area of three reservoirs (Lakes Houston,
%  Livingston, and Conroe) given the reservoirs' volume and area-volume
%  rating curves.
%
% Author: Alyssa Graham
% Organization: Civil and Environmental Engineering Dept, Rice University
%

function [hou_evap_area,liv_evap_area,con_evap_area] = EvapREAD(hou_init_stor,liv_init_stor,con_init_stor)
% Houston area-volume curve data
Houston_vol = readmatrix('Houston Rating Curve.csv','Range','C5:C2743');
Houston_area = readmatrix('Houston Rating Curve.csv','Range','B5:B2743');

% Livingston area-volume curve data
Livingston_vol = readmatrix('Livingston Rating Curve.csv','Range','C5:C2743');
Livingston_area = readmatrix('Livingston Rating Curve.csv','Range','B5:B2743');

% Conroe area-volume curve data
Conroe_vol = readmatrix('Conroe Rating Curve.csv','Range','C16:C2743');
Conroe_area = readmatrix('Conroe Rating Curve.csv','Range','B16:B2743');

% interpolate to find area (m2) from area-volume curve data given 
% initial/previous reservoir storage
acre_m2 = 4046.86;
hou_evap_area = (interp1(Houston_vol,Houston_area,hou_init_stor)*acre_m2);
liv_evap_area = (interp1(Livingston_vol,Livingston_area,liv_init_stor)*acre_m2);
con_evap_area = (interp1(Conroe_vol,Conroe_area,con_init_stor)*acre_m2);
