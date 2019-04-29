clc;
clear all;
close all;
%%
infilename = 'hall_monitor.mpg';
% Read video file
vid=VideoReader(infilename);

% Determine number of frames
nf = vid.NumberOfFrames;
% nf=3;

%% Perform DWT on first frame

if strcmpi(infilename,'hall_monitor.mpg');
    frame_range = 1:10;

else
    if ~isempty(nf)
        frame_range = 1:20:nf;
    else
        frame_range = 1:20:300;
    end
end

idx = 1;
h1 = waitbar(0,'Please wait while registering background');
for ii = frame_range
    frame1 = read(vid,ii);
    
%     imshow(frame1)
%     title(num2str(ii))
%     pause(0.01)   
%     % Background registration
    frames(:,:,:,idx) = double(read(vid,ii));
    waitbar(ii/nf)
end

I1 = median(frames,4);
close(h1)
% I1=read(vid,1); % First frame
I1= uint8(I1);

figure;
imshow(I1)
title('Background')

I1=rgb2gray(I1);
[C1 S1]=wavedec2(I1,2,'haar');
LL2=appcoef2(C1,S1,'haar',2);

% Caclulate number of pixels
totalpixels = numel(LL2);
thA=round(totalpixels/100); % Threshold for the noise removal

figure;
% Calculate size of video
[nr nc m]=size(I1);
for i=1:500
    I=read(vid,i);
    I1=rgb2gray(I);

    [C1 S1]=wavedec2(I1,2,'haar');

    LL1=appcoef2(C1,S1,'haar',2);

    % Frame differencing at 2 level apporx coefficient
    D=abs(LL1-LL2);

    % Compare with threshold
    bw = D>60;

    % Image restoration
    D1=bwmorph(bw,'bridge');

    % Remove small areas
    D1=bwareaopen(D1,thA);
     
    % Fill the holes
    D1=imfill(D1,'holes');

    % Increase the size of mask as per original image size
    bw=imresize(D1,4);
    
    % Erosion
    bw = bwmorph(bw,'erode');
    
    
    imshow(I);
    title(['Frame no = ' num2str(i)])

%     subplot(132)
%     imshow(bw)
%     title('Moving mask')


    % Initialise image
    MovingIm = zeros(nr,nc,3);
    
    % Get bounding box of the object
    P = regionprops(bw,'BoundingBox');
    
    % Concatinate 
    P = cat(1,P.BoundingBox);
    P = ceil(P);
    % Concatinate in one dimension
    for n = 1:size(P,1)
%         
        rectangle('Position',P(n,:),'edgecolor','r')
%         try
%             % Get the values
%             MovingIm(P(n,2):P(n,4)+P(n,2),P(n,1):P(n,3)+P(n,1),:) = imcrop(I,P(n,:));
%         end
    end
    
%     subplot(133)
%     imshow(uint8(MovingIm))
%     title('Moving object')
    pause(0.01)
    
%     pause
end
