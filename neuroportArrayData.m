function [arrayMap electrodeXY electrodeImp] = neuroportArrayData(subjectName)
% [arrayMap electrodeXY electrodeImp] = neuroportArrayData(subjectName)
%
% Omar Ahmed, 2012
% 
% This function loads in the original impendence values
% It searches for an excel spreadsheet named [subject].xls in the neuroport_mapping folder.
% See Omar's notes for details about spreadsheet formatting
% Data in the excel file must be rearranged so that it is in order based on 
% bank and pin number A1-A32, B1-B32, C1-32. If the file is name with a
% deidentified subject number (i.e. MG49, etc.) than all formatting is
% accurate. The impedance values can also be used as a predictor of what
% the really bad electrodes are (would have insanely high or extremely low
% impedances) - although I would not recommend this as a primary way of
% including or excluding electrodes.

%fname = 'SN 4382-0376 1687-6_extracted.xls'; % filenames look something like this before I rename them to MG49.xls or BW9.xls, etc.

%[num, txt]= xlsread(['../data/neuroport_mapping/' subjectName '.xls']);
%[num, txt]= xlsread(['/Users/tibinjohn/humanarraychannelmap/neuroport_mapping/' subjectName '.xls']);
%[num, txt]= xlsread(['/nfs/turbo/lsa-ojahmed/ANALYSIS_CODE/humanArrayChannelMap/neuroport_mapping/' subjectName '.xls']);
%[num, txt]= xlsread(['/nfs/turbo/lsa-ojahmed/ANALYSIS_CODE/humanArrayChannelMap/neuroport_mapping/' subjectName '.xls']);
[num, txt]= xlsread(['/Users/tibinjohn/humanarraychannelmap/neuroport_mapping/' subjectName '.xls']);
electrodeXY = NaN(96,2); % 96 rows, each row corresponds to a channel as seen on the blackrock recording system... the first column is the x-index into the array, second column is y-index when plotting
electrodeImp = NaN(96,1);
arrayMap = NaN(10,10); % the actual map with the channel numbers plotted on it
for x = 1:96;
    electrodeXY(x,:) = num(x,1:2)+1; % column 1 is the x-index, column 2 is the y-index - as used when plotting. note the +1
    electrodeImp(x,1:2) = num(x,7);
    arrayMap(num(x,1)+1,num(x,2)+1) = x;
end
