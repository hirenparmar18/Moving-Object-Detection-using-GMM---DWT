% This m-file implements the approximate median algorithm for background
% subtraction. 

clear all;
close all;
clc;
%% Display options
originalvideo=1;  % on/off(0)
morphologicalvideo=0;% on/off
detectedobjects=1;%on/off
totalplot=originalvideo+morphologicalvideo+detectedobjects;
%%

source = mmreader('video4.mpg');
% source = aviread('C:\Video\Source\traffic\san_fran_traffic_30sec_QVGA');
 frame=read(source);
 nf=size(frame,4);

thresh = 25;           

bg = read(source,1);           % read in 1st frame as background frame
bg_bw = double(rgb2gray(bg));     % convert background to greyscale

% ----------------------- set frame size variables -----------------------
fr_size = size(bg);             
width = fr_size(2);
height = fr_size(1);
fg = zeros(height, width);

% --------------------- process frames -----------------------------------

for i = 2:nf

    fr = read(source,i); 
    fr_bw = rgb2gray(fr);       % convert frame to grayscale
    
    fr_diff = abs(double(fr_bw) - double(bg_bw));  % cast operands as double to avoid negative overflow

    for j=1:width                 % if fr_diff > thresh pixel in foreground
         for k=1:height

             if ((fr_diff(k,j) > thresh))
                 fg(k,j) = fr_bw(k,j);
             else
                 fg(k,j) = 0;
             end

             if (fr_bw(k,j) > bg_bw(k,j))          
                 bg_bw(k,j) = bg_bw(k,j) + 1;           
             elseif (fr_bw(k,j) < bg_bw(k,j))
                 bg_bw(k,j) = bg_bw(k,j) - 1;     
             end

         end    
    end

%     figure(1),subplot(3,1,1),imshow(fr)     
%     subplot(3,1,2),imshow(uint8(bg_bw))
%     subplot(3,1,3),
%     imshow(uint8(fg))   
    fg1=im2bw(fg);
     fg1=bwmorph(fg1,'bridge');
     fg1=bwareaopen(fg1,200);
     fg1=bwmorph(fg1,'dilate');
     objects=double(fr).*(cat(3,fg1,fg1,fg1));
     [L, num] = bwlabel(fg1);
    pid=1;
    if originalvideo==1;
        subplot(1,totalplot,pid);
        imshow(fr);
%         text(10,10,num2str(num),'color','r');
        pid=pid+1;
    end
    if morphologicalvideo==1;
        subplot(1,totalplot,pid);
        imshow(fg1)
        text(10,10,num2str(num),'color','r');
        pid=pid+1;
    end
        if detectedobjects==1;
        subplot(1,totalplot,pid);
        imshow(uint8(objects));
        text(10,10,num2str(num),'color','r');
    end
    
    pause(0.01)
    
%     M(i-1)  = im2frame(uint8(fg),gray);             % save output as movie
%     M(i-1)  = im2frame(uint8(bg_bw),gray);             % save output as movie
end

% movie2avi(M,'approximate_median_background','fps',30);           % save movie as avi    

    