function [samples] = getOrigin(recvSignal)

    startF = 14000;  % 起始的超声波频率是 14000 HZ
    endF = 23000; % 终止的超声波频率是 23000 HZ

    sampleIndex = size(recvSignal,1); % 取样点的个数
    frameSize = 240; % 帧大小
    times = floor(sampleIndex/frameSize); % 帧个数
    windowSize = 240;
    samples = zeros(size(recvSignal,1),1);
    fact = zeros(frameSize);
    for i=1:frameSize
        fact(i)= 0.5 * (1 - cos((2 * pi * (i-1)) / (windowSize-1)));
    end

    for t=1:times
        for j=1:frameSize
            numerator=(j-1)/frameSize;
            instfreq = startF+(0.5*numerator*(endF-startF));
            samples(j + (t-1) * frameSize) = fact(j)*cos(2.0 * pi *(j-1)/(96000/instfreq));
            endIndex = j+(t-1)*frameSize;
        end
    end

    for j=endIndex+1:sampleIndex
        numerator=(j-endIndex-1)/frameSize;
        instfreq = startF+(0.5*numerator*(endF-startF));
        samples(j) = fact(j-endIndex-1)*cos(2.0 * pi *(j-1-endIndex)/(96000/instfreq));
    end
end