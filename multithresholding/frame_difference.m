% This m-file implements the frame difference algorithm for background
% subtraction.  

clear all;
clc;
close all;
%% Display options
originalvideo=1;  % on/off(0)
morphologicalvideo=0;% on/off
detectedobjects=1;%on/off
totalplot=originalvideo+morphologicalvideo+detectedobjects;
%%
% source = aviread('C:\Video\Source\traffic\san_fran_traffic_30sec_QVGA');
%source = aviread('..\test_video\san_fran_traffic_30sec_QVGA_Cinepak');
 source = mmreader('video4.mpg');
 frame=read(source);
 nf=size(frame,4);
 clear frame

thresh = 25;           

bg = read(source,1);           % read in 1st frame as background frame
bg_bw = rgb2gray(bg);           % convert background to greyscale


% ----------------------- set frame size variables -----------------------
fr_size = size(bg);             
width = fr_size(2);
height = fr_size(1);
fg = zeros(height, width);

% --------------------- process frames -----------------------------------

for i = 2:nf
    
    fr = read(source,i);       % read in frame
    fr_bw = rgb2gray(fr);       % convert frame to grayscale
    
    fr_diff = abs(double(fr_bw) - double(bg_bw));  % cast operands as double to avoid negative overflow
    
    for j=1:width                 % if fr_diff > thresh pixel in foreground
        for k=1:height
            if ((fr_diff(k,j) > thresh))
                fg(k,j) = fr_bw(k,j);
            else
                fg(k,j) = 0;
            end
        end
    end
    
    bg_bw = fr_bw;
    
%     figure(1),subplot(3,1,1),imshow(fr)
%     subplot(3,1,2),imshow(fr_bw)
%     subplot(3,1,3),imshow(uint8(fg))
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
%     
%     M(i-1)  = im2frame(uint8(fg),gray);           % put frames into movie

end

% movie2avi(M,'frame_difference_output', 'fps', 30);           % save movie as avi 
 
    