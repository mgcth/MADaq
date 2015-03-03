function impact_hammer_plot(frdsys_impact)



nCh = size(frdsys_impact{1}.REF{1}.CH,2);
nRef=size(frdsys_impact{1}.REF,2);
sumFRF=zeros(size(frdsys_impact{2}.FREQ,1),nCh);
% hannWindow = hann(size(Data{2},1));
i=1;
for iCh = 2 : nCh
    for iRef = 1 : nRef
        figure(11);title1String = sprintf('Reference #%u, Channel %u',iRef,iCh-1);
        subplot(nCh,nRef,i);
        plot(frdsys_impact{2}.FREQ,log10(abs(frdsys_impact{1}.REF{iRef}.CH{iCh}))); hold on;
        title(title1String);
        
        meanFRF{iRef}{iCh} = mean(frdsys_impact{1}.REF{iRef}.CH{iCh},2);
        sumFRF(:,iCh) = sumFRF(:,iCh) + meanFRF{iRef}{iCh};
        i = i + 1;
    end
    figure(22);title2String = sprintf('Channel %u',iCh-1);
    subplot(nCh,1,iCh-1);
    plot(frdsys_impact{2}.FREQ,log10(abs(sumFRF(:,iCh))),'k');
    title(title2String);
end
