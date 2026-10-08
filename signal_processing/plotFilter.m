function [arvSignal,medSignal] = plotFilter(signal, samplesIndex)
    arvSignal = zeros(1,480);
    medSignal = zeros(1,480);
    for j=1:480
        medSignal(1,j) =  median(signal(j,samplesIndex));
    end
    for j=1:size(samplesIndex,2)
        index = samplesIndex(j);
        arvSignal = arvSignal + transpose(signal(:,index));
    end
    arvSignal = arvSignal / size(samplesIndex,2);
end