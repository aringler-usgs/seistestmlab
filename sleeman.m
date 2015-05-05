function [pspec1, stahand1, tseries1, ttime1, mabsvolt1, ...
    pspec2, stahand2, tseries2, ttime2, mabsvolt2, ...
    pspec3, stahand3, tseries3, ttime3, mabsvolt3, per, np1, np2, np3 ...
    ] = sleeman(noisedata1, sensor1,digitizer1, ...
    noisedata2, sensor2, digitizer2, ...
    noisedata3,sensor3, digitizer3, stimestr,etimestr,lowpass)
    %Compute spectra and correct for response
    %Read in data
    try
        [noisedata1,~]=rdmseed(noisedata1);
    catch ME
        display('Error reading in data 1');
    end
    try
        [noisedata2,~]=rdmseed(noisedata2);
    catch ME
        display('Error reading in data 2');
    end
    try
        [noisedata3,~]=rdmseed(noisedata3);
    catch ME
        display('Error reading in data 3');
    end
    %Pull out information about the time series for plotting
    net1=deblank(noisedata1(1,1).NetworkCode);
    net2=deblank(noisedata2(1,1).NetworkCode);
    net3=deblank(noisedata3(1,1).NetworkCode);
    sta1=deblank(noisedata1(1,1).StationIdentifierCode);
    sta2=deblank(noisedata2(1,1).StationIdentifierCode);
    sta3=deblank(noisedata3(1,1).StationIdentifierCode);
    loc1=deblank(noisedata1(1,1).LocationIdentifier);
    loc2=deblank(noisedata2(1,1).LocationIdentifier);
    loc3=deblank(noisedata3(1,1).LocationIdentifier);
    chan1=deblank(noisedata1(1,1).ChannelIdentifier);
    chan2=deblank(noisedata2(1,1).ChannelIdentifier);
    chan3=deblank(noisedata3(1,1).ChannelIdentifier);
    if(noisedata1(1,1).SampleRate ~= noisedata2(1,1).SampleRate || ...
        noisedata2(1,1).SampleRate ~= noisedata3(1,1).SampleRate)
        display('Sample Rates are not equal');
    end
    sps1=noisedata1(1,1).SampleRate;
    sps2=noisedata2(1,1).SampleRate;
    sps3=noisedata3(1,1).SampleRate;
    year1=noisedata1(1,1).RecordStartTimeISO;
    year2=noisedata2(1,1).RecordStartTimeISO;
    year3=noisedata3(1,1).RecordStartTimeISO;
    year1=year1(1:8);
    day1=year1(6:8);
    year1=year1(1:4);
    year2=year2(1:8);
    day2=year2(6:8);
    year2=year2(1:4);
    year3=year3(1:8);
    day3=year3(6:8);
    year3=year3(1:4);
    noisetime1=cat(1,noisedata1.t);
    noisedata1=cat(1,noisedata1.d);
    noisetime2=cat(1,noisedata2.t);
    noisedata2=cat(1,noisedata2.d);
    noisetime3=cat(1,noisedata3.t);
    noisedata3=cat(1,noisedata3.d);
    if(~isempty(stimestr))
        stimeind=strfind(stimestr,':');
        stimehour = str2double(stimestr(1:stimeind-1));
        stimemin = str2double(stimestr(stimeind+1:length(stimestr)));
        stime = datenum(str2double(year1),01,str2double(day1), ...
            stimehour,stimemin,0);
        noisedata1=noisedata1(find(noisetime1>= stime));
        noisetime1=noisetime1(find(noisetime1>= stime));
        noisedata2=noisedata2(find(noisetime2>= stime));
        noisetime2=noisetime2(find(noisetime2>= stime));
        noisedata3=noisedata3(find(noisetime3>= stime));
        noisetime3=noisetime3(find(noisetime3>= stime));
    end
    if(~isempty(etimestr))
        etimeind=strfind(etimestr,':');
        etimehour = str2double(etimestr(1:etimeind-1));
        etimemin = str2double(etimestr(etimeind+1:length(etimestr)));
        etime = datenum(str2double(year1),01,str2double(day1), ...
            etimehour,etimemin,0);
        noisedata=noisedata(find(noisetime<= etime));
        noisetime=noisetime(find(noisetime<= etime));
    end
    %Here is logic to deal with different sample rates
    if(sps1 ~= sps2 || sps2 ~= sps3 || sps1 ~= sps3)
        [sps,idx] = min([sps1 sps2 sps3]);
        noisedata1=decimate(noisedata1,sps1/sps);
        noisedata2=decimate(noisedata2,sps2/sps);
        noisedata3=decimate(noisedata3,sps3/sps);
        noisetime1=decimate(noisetime1,sps1/sps);
        noisetime2=decimate(noisetime2,sps2/sps);
        noisetime3=decimate(noisetime3,sps3/sps);
        if idx ==1
            noisetime = noisetime1;
        elseif idx ==2
            noisetime = noisetime2;
        else
            noisetime = noisetime3;
        end
        
    else
        sps = sps1;
        noisetime = noisetime1;
    end
    
    if((length(noisedata1) ~= length(noisedata2)) || ...
            (length(noisedata1) ~= length(noisedata3)) || ...
            (length(noisedata2) ~= length(noisedata3)))
        minlen = min(min(length(noisedata1),length(noisedata2)), ...
            length(noisedata3));
        noisedata1=noisedata1(1:minlen);
        noisedata2=noisedata2(1:minlen);
        noisedata3=noisedata3(1:minlen);
        noisetime1=noisetime1(1:minlen);
        noisetime2=noisetime2(1:minlen);
        noisetime3=noisetime3(1:minlen);
    end
    


    
    overlap = floor(.66*length(noisedata1)/10);
    win = floor(length(noisedata1)/10);

    %Compute the spectra
	[pspec1,fre]=cpsd(noisedata1,noisedata1,win,overlap, win , sps);
    %pspec1 = pspec1/sps;
    [pspec2,fre]=cpsd(noisedata2,noisedata2,win,overlap, win , sps);
    %pspec2 = pspec2/sps;
    [pspec3,fre]=cpsd(noisedata3,noisedata3,win,overlap, win , sps);
    %pspec3 = pspec3/sps;
    %Lets compute the cross-power
    [pspec21, fre]=cpsd(noisedata2,noisedata1,win,overlap, win , sps);
    %pspec21 = pspec21/sps;
    [pspec13, fre]=cpsd(noisedata1,noisedata3,win,overlap, win , sps);
    %pspec13 = pspec13/sps;
    [pspec23, fre]=cpsd(noisedata2,noisedata3,win,overlap, win , sps);
    %pspec23 = pspec23/sps;
    
    
    
    
    %Get the response and correct
    [zer,pol,gai1]=getrespmodel(sensor1);
    resp1=1;
    for ind=1:length(pol)
        resp1=resp1./(2*pi*1i*fre-pol(ind));
    end
    for ind=1:length(zer)
        resp1=resp1.*(2*pi*1i*fre-zer(ind));
    end
    [zer,pol,gai2]=getrespmodel(sensor2);
    resp2=1;
    for ind=1:length(pol)
        resp2=resp2./(2*pi*1i*fre-pol(ind));
    end
    for ind=1:length(zer)
        resp2=resp2.*(2*pi*1i*fre-zer(ind));
    end
    [zer,pol,gai3]=getrespmodel(sensor3);
    resp3=1;
    for ind=1:length(pol)
        resp3=resp3./(2*pi*1i*fre-pol(ind));
    end
    for ind=1:length(zer)
        resp3=resp3.*(2*pi*1i*fre-zer(ind));
    end
    

    digsen1=getdigitmodel(digitizer1);

    resp1=resp1/abs(resp1(find(fre<.1  ,1,'last')));
    resp2=resp2/abs(resp2(find(fre<.1  ,1,'last')));
    resp3=resp3/abs(resp3(find(fre<.1  ,1,'last')));
    if(~strcmp(sensor1,'Epi-EST') && ~strcmp(sensor1,'Titan') && ...
            ~strcmp(sensor1,'CMG-5T') && ~strcmp(sensor1,'147-01/3') && ...
            ~strcmp(sensor1,'PA-23'))
        resp1=((2*pi*1i*fre).^-1).*resp1*gai1*digsen1;
    else
        resp1=resp1*gai1*digsen1;
    end
    
    digsen2=getdigitmodel(digitizer2);
    if(~strcmp(sensor2,'Epi-EST') && ~strcmp(sensor2,'Titan') && ...
            ~strcmp(sensor2,'CMG-5T') && ~strcmp(sensor2,'147-01/3') && ...
            ~strcmp(sensor2,'PA-23'))
        resp2=((2*pi*1i*fre).^-1).*resp2*gai2*digsen2;
    else
        resp2=resp2*gai2*digsen2;
    end
    
    digsen3=getdigitmodel(digitizer3);
    if(~strcmp(sensor3,'Epi-EST') && ~strcmp(sensor3,'Titan') && ...
            ~strcmp(sensor3,'CMG-5T') && ~strcmp(sensor3,'147-01/3') && ...
            ~strcmp(sensor3,'PA-23'))
        resp3=((2*pi*1i*fre).^-1).*resp3*gai3*digsen3;
    else
        resp3=resp3*gai3*digsen3;
    end

    
    np1=real(10*log10((pspec1 - pspec21.*pspec13./pspec23)./(abs(resp1).^2)));
    np2=real(10*log10((pspec2 - conj(pspec23).*pspec21./conj(pspec13))./(abs(resp2).^2)));
    np3=real(10*log10((pspec3 - pspec23.*conj(pspec13)./pspec21)./(abs(resp3).^2)));
    
    
    pspec1=real(10*log10(pspec1./(abs(resp1).^2)));
    pspec2=real(10*log10(pspec2./(abs(resp2).^2)));
    pspec3=real(10*log10(pspec3./(abs(resp3).^2)));
    per = 1./fre;
    stahand1 = [ net1 ' ' sta1 ' ' loc1 ' ' chan1 ' ' year1 ' ' day1];
    stahand2 = [ net2 ' ' sta2 ' ' loc2 ' ' chan2 ' ' year2 ' ' day2];
    stahand3 = [ net3 ' ' sta3 ' ' loc3 ' ' chan3 ' ' year3 ' ' day3];
    tseries1 = detrend(noisedata1/digsen1);
    tseries2 = detrend(noisedata2/digsen2);
    tseries3 = detrend(noisedata3/digsen3);
    if(lowpass)
        h=fdesign.lowpass('N,F3db',8,0.1,sps);  
        d=design(h,'FIR');
        tseries1 = filtfilt(d.Numerator,1,tseries1);
        tseries2 = filtfilt(d.Numerator,1,tseries2);
        tseries3 = filtfilt(d.Numerator,1,tseries3);
    end
    ttime1 = noisetime;
    mabsvolt1 = mean(abs(tseries1));
    ttime2 = noisetime;
    mabsvolt2 = mean(abs(tseries2));
    ttime3 = noisetime;
    mabsvolt3 = mean(abs(tseries3));
end



