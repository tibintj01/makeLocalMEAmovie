function [] = makeLocalMEAmovieForCh(ptDir,sessionNum,ch) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Description: makeMEAmovie.m
%
%
%Preconditions:
%
%
%Effects:
%
%
%Author: Tibin John, tibintj@umich.edu
%Project directory name: /nfs/turbo/lsa-ojahmed/tibin/processedHumanData/MG49/sessionID-3 
%Created on 2018-06-24
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Fs=2000;
sampPeriod=1/Fs;	
chStr=getChStr(ch);
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Task #1
%Description:
%  collect files corresponding to surrounding channels
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[lfpFileNames,cellPropFileNames]=getFileNamesAroundCh(ptDir,sessionNum,ch);
%[chMap, chRowCols]=getChMap(ptDir);
%chRowCols(closeChannels)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Task #1
%Description:
% get spectrograms for this cluster of channels
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
lfp=load(lfpFileNames{1});
[tSgram fSgram Sgram] = getSpectrogram(lfp,Fs);
specgramMatrix=NaN(length(fSgram),length(tSgram),length(lfpFileNames));
lfpTimeAxis=sampPeriod:sampPeriod:(sampPeriod*length(lfp));

specDataFileName=sprintf('%s_%s_%s_LocalSpectrogramsMatrix.mat',ptDir,sessionNum,chStr);

if(~exist(specDataFileName))
    for chIdx=1:length(lfpFileNames)
        currLFPFileName=lfpFileNames{chIdx};
        lfp=load(currLFPFileName);
        [tSgram fSgram Sgram] = getSpectrogram(lfp,Fs);
        specgramMatrix(:,:,chIdx)=Sgram;
        save(specDataFileName,'specgramMatrix')
    end
else
    specgramMatrixData=load(specDataFileName);
    specgramMatrix=specgramMatrixData.specgramMatrix;
end
%figure
%omarPcolor(tSgram,fSgram,log(specgramMatrix(:,:,1)))
%shading flat


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Task #2
%Description:
%plot power spectra of closest channels as a function of time
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%disp('computing output.........')

figure
subplot(121)


subplot(122)

halfSmoothWind=1
sSampPeriod=tSgram(2)-tSgram(1);
numSmoothWindHalf=round(halfSmoothWind/sSampPeriod);

numCells=length(cellPropFileNames);
for i=1:numCells
    cellPropsData=load(cellPropFileNames{i});
    cellProps{i}=cellPropsData;
end

rasterWindTimeHalf=10;

frameCount=0;
for tIdx=(numSmoothWindHalf+1):(length(tSgram)-numSmoothWindHalf-1)
    currTimeMin=tSgram(tIdx)-sSampPeriod/2;
    currTimeMax=tSgram(tIdx)+sSampPeriod/2;
    
    subplot(121)
    for chIdx=1:length(lfpFileNames)
        localPowerSpec=nanmean(specgramMatrix(:,(tIdx-numSmoothWindHalf):(tIdx+numSmoothWindHalf),chIdx),2);
        plot(fSgram,log(localPowerSpec))
        hold on
        ylim([0 10])
    end
    title(sprintf('Time=%.2f sec',tSgram(tIdx)))
    xlabel('Freq (Hz)')
    ylabel('log(Power)')
       hold off
    subplot(122)
    for cellIdx=1:numCells
        spikeTimes=cellProps{cellIdx}.spikeTimes;
        spikeTimesInWind=spikeTimes(spikeTimes>=currTimeMin & spikeTimes<= currTimeMax);
        if(length(spikeTimesInWind)>0)
            if(cellProps{cellIdx}.isInterneuronCell==1)
                %plot([spikeTimesInWind spikeTimesInWind], [cellIdx-1 cellIdx],'r')
                plot(spikeTimesInWind,cellIdx,'ro','MarkerSize',3)
            elseif(cellProps{cellIdx}.isInterneuronCell==0)
                %plot([spikeTimesInWind spikeTimesInWind], [cellIdx-1 cellIdx],'b')
                 plot(spikeTimesInWind,cellIdx,'bo','MarkerSize',3)
            else
                %plot([spikeTimesInWind spikeTimesInWind], [cellIdx-1 cellIdx],'k')
                 plot(spikeTimesInWind,cellIdx,'ko','MarkerSize',3)
            end
        end
        hold on
    end
    xlabel('Time (sec)')
    ylabel('Cell No.')

    hold off
    ylim([0 numCells])
    xlim([currTimeMin-rasterWindTimeHalf currTimeMax+rasterWindTimeHalf])

    drawnow
    %pause(1)
    frameCount=frameCount+1;
    localMEAmovie(frameCount) = getframe(gcf);
    %pause(0.1)
    %if(mod(tSgram(tIdx),rasterWindTimeHalf*2)<sSampPeriod)
    %    cla
    %end
    if(frameCount>200)
        fds
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Task #3
%Description:
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('computing output.........')


