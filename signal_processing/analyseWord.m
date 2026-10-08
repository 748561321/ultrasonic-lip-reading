function dSignal = analyseWord(channelIndex, filePath,savePath, format, backgroundPath)
%{
    超声波处理，距离测量
%}
sampleRate = 48000; % 设置采样率为 48000 HZ
startFreq = 14000;  % 起始的超声波频率是 14000 HZ
endFreq = 23000; % 终止的超声波频率是 23000 HZ
frameDuration = 0.005; % 每一帧的时长为 0.005 s
threshold = 0.5; % 阈值
vSound = 346; % 声音速度
frameSize = sampleRate * frameDuration; % 每帧采样点个数
%% ---------------- 生成原信号 ----------------

% 生成一帧内采样点的时间序列,ts[i] 表示第i个采样点的时间序列

ts = 1/sampleRate:1/sampleRate:0.005;
chirpSignal = chirp(ts,startFreq,frameDuration,endFreq,"linear");


%% ---------------- 读取音频信号 ---------------- 
    % recvChirpSignal 是接收信号数据, recvSampleRate 是接收信号采样率
    % recvChirpSignals 是m * n矩阵,其中m是读取的音频样本数,n是文件中的音频通道数.
    
    %disp(filePath);
    [yOut, recvSampleRate] = audioread(filePath);
    recvChirpSignals = yOut;
    assert(recvSampleRate == sampleRate);

%% ---------------- 音频信号预处理 ---------------- 
    % recvChirpSignal 是接收信号的第二个声道,当做接收信号处理

    
   [background, ~] = audioread(backgroundPath);

   
   % figure('name',"原信号");
   % 
   % plot(chirpSignal);
   % xlabel('samplint point');
   % ylabel('amplitude');
%{

   figure('name',"背景信号");
   plot(background(middlepoint: middlepoint + len, channelIndex));
   xlabel('samplint point');
   ylabel('amplitude');
   %}
   recvChirpSignal = recvChirpSignals(:, channelIndex)- background(1: size(recvChirpSignals, 1), channelIndex);
   %{
   figure('name',"与背景信号进行差分");
   plot(recvChirpSignal(middlepoint: middlepoint + len));
   xlabel('samplint point');
   ylabel('amplitude');
   %}
    % 对信号进行通带滤波
    recvChirpSignal = bandpass(recvChirpSignal, [startFreq, endFreq], sampleRate);
   %{
   figure('name',"带通滤波后的信号");
   plot(recvChirpSignal(middlepoint: middlepoint + len));
   xlabel('samplint point');
   ylabel('amplitude');
   %}
    % 对信号进行缩放, 区间为 [-1,1]
    recvChirpSignal = rescale(recvChirpSignal,-1,1);
    
   

%% ---------------- 信号互相关 ---------------- 
    % 原信号和接收信号进行互相关,按照峰值点把各帧切分对齐然后拼起来
    [corrs,~] = xcorr(recvChirpSignal, chirpSignal); % 互相关
%     midpoint = round(size(corrs,1)/2);
%     len = 1000;
   % figure('name',"互相关");
   % xlabel('samplint point');
   % ylabel('corr ');
   % plot(corrs(midpoint: midpoint + len));

[~, lk] = findpeaks(corrs,'MinPeakDistance',0.8*sampleRate*frameDuration,'MinPeakHeight',0.8); % 寻找峰值
asc = sort(lk);
index_differ = asc(2:end) - asc(1:end-1);
indices = strfind([index_differ'], [ frameSize, frameSize, frameSize,frameSize]);
start_index = asc(indices); % 找到开始的
directSignalPeakIdx = start_index(1);

%     seqs = 1 : length(corrs);
%     corrs = corrs / max(abs(corrs)); % 归一化处理
%     allPeakIdx = seqs(corrs > threshold);  % 提取出所有有效的峰值点
% 
%     % 找出第一个峰值点,直射信号峰值点,对应直射信号传播距离
%     directSignalPeakIdx = allPeakIdx(1);

    % periods 为反射信号的周期数
    periods = floor((length(corrs) - directSignalPeakIdx + 1) / frameSize);

    % 接收信号所有周期的互相关系数
    % allPeriodsCorrs(n,m) : 采样的第m个周期的第n个采样点的互相关系数
    allPeriodsCorrs = zeros(frameSize, periods);

    for n = 1:periods % 遍历所有周期,整理每个周期对应采样点的相关系数
        % 这个周期的起始索引
        startIndex =  directSignalPeakIdx + (n - 1) * frameSize - 1;

        % 这个周期的索引范围
        periodRange = startIndex:(startIndex + frameSize - 1);

        % 对这个周期内的互相关系数进行归一化处理
        corrSeqPeriod = corrs(periodRange) / max(abs(corrs(periodRange)));

        % 存储到矩阵中
        allPeriodsCorrs(:,n) = corrSeqPeriod;
    end

    eUpper = envelope(allPeriodsCorrs);
    for p = 1:periods
        % 对每一周期的包笼曲线进行归一化处理
        eUpper(:,p) = eUpper(:,p)/max(abs(eUpper(:,p)));
    end
%     figure;
%     plot(eUpper(:,100),'LineWidth', 2);
%     figure;
%     plot(eUpper(:,101),'LineWidth', 2);
%     figure;
%     plot(eUpper(:,101) - eUpper(:,100),'LineWidth',2);
%     figure;
%     plot(eUpper);

%     pageCnt = min(size(eUpper,2), 5);
%     disSeq = (1:frameSize)/sampleRate*vSound*100/2;
%     samplesIndex = 1:pageCnt;
    % plotFilter(eUpper, samplesIndex);
    %figure;
    %hold on;
%      for c = 1:pageCnt
         %plot(disSeq, eUpper(:,c), ':');
         
%      end
     %{
     yticks(0:0.2:0.8);
     xlim([-5,60]);
     [arvSiganal,medSignal] = plotFilter(eUpper, samplesIndex);
     plot(disSeq,arvSiganal,'-','LineWidth',2);
     plot(disSeq,medSignal,'-','LineWidth',2);
     ylabel("Normalized corr");xlabel('Distance(cm)');
     legend("frame1","frame2","frame3","frame4","frame5","Mean filter","Median filter");

     %}

   % 提取速度特征的思路: 帧间差分,对差分后的波检测峰值
   % 检测峰值的算法, 设定窗口, 比较此窗口的方差与均值 和 整个波的方差与均值
   % eUpper(n,m): 480 * 帧数量

   % dSignal(n, m) : 第n个采样点 第m+1个时间点 - 第m个时间点 240*time
    dSignal = eUpper(:,2:size(eUpper, 2)) - eUpper(:,1:(size(eUpper, 2)-1));
%     lowerV = 0.005; upperV = 0.05;
%     dSignal(dSignal < lowerV) = lowerV;
%     dSignal(dSignal > upperV) = upperV;
    
    % for c = 1:pageCnt
    %     figure;
    %     plot(disSeq, eUpper(:, c * 50) - eUpper(:,c),'-','LineWidth',5);
    %     ylabel("corr diff");xlabel('Distance(cm)');
    %     xlim([-5,60]);
    %  end
%{
    figure;
    X = 1:size(dSignal,1);
    Y = 1:size(dSignal,2); 
    colormap('jet');
    
    surf(dSignal(1:30, 1:round((size(dSignal,2)/16))));
    middlepoint = round(size(dSignal,2)/2);
    
    %mesh(dSignal * 100);
    %fzsurf(dSignal);
    
   
    ylabel('Sampling points');%x轴坐标
    xlabel('frame ');%y轴坐标
    zlabel('Difference');%z轴坐标
   %}

    %periods = size(dSignal, 2);
    if ~exist(savePath, 'dir')
            mkdir(savePath);  % 如果文件夹不存在，则创建它
    end
    [~,col] = size(dSignal);
    lowerV = 0.005; upperV = 0.05;
    dSignal(dSignal < lowerV) = lowerV;
    dSignal(dSignal > upperV) = upperV;
    fprintf("%d\n",col);
    interval = 200;
    windis = 100;
%      考虑滑动窗口 滑动距离 = ? 窗口大小 =  ？
    
    zerosToAdd = 0.005 * ones(240, interval);
    dSignal = [dSignal zerosToAdd]; 

    for i = 1:col/windis + 1
        temp = strcat(savePath ,'\part',num2str(i));
        starti = (i-1) * windis + 1;
        endi = starti + interval;
%         figure;
        figure('visible','off');
        colormap('jet');
        set(gca,'XTick',[]) 
        set(gca,'YTick',[])
        set(gca,'Position',[0 0 1 1]) 
        imagesc(dSignal(:,starti:endi));
        saveas(gcf,temp,format);
        if starti + interval >= col-1
            break;
        end
    end


    %figure;
    % figure('visible','off');
    %colormap('jet');
    %set(gca,'XTick',[]) 
    %set(gca,'YTick',[])
    %set(gca,'Position',[0 0 1 1]) 
    
    %imagesc(dSignal(1:120, 1:round((size(dSignal,2)/4))));
    %saveas(gcf,savePath,format)
%{
    colorbar;
    halfDMGridSize = ceil(0.1/vSound*sampleRate);
    ylim([0 halfDMGridSize *11]);

    yticks(0:halfDMGridSize:frameSize);  % 设置y轴的值在哪些值显示刻度线
        % 坐标轴的显示标签
    yticklabels({'0','5','10','15','20','25','30','35','40','45','50','55'}); 
    xticks(0:floor(sampleRate/frameSize):frameSize*size(dSignal,1));
    xticklabels({'0','1','2','3','4','5','6','7'});

%}
end