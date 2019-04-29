clc;
clear all;
close all;
%%
delete(imaqfind)
% This program starts the laptop integrated webcam and preview it for 10
% seconds. We can use similar lines, where we want to start the webcam.

opfile = 'op3.avi';
vid = videoinput('winvideo',1);

%  View the default color space used for the data — The value of the ReturnedColorSpace property indicates the color space of the image data.
color_spec=vid.ReturnedColorSpace;

% Modify the color space used for the data — To change the color space of the returned image data, set the value of the ReturnedColorSpace property.
if  ~strcmp(color_spec,'rgb')
    set(vid,'ReturnedColorSpace','rgb');
end

triggerconfig(vid,'manual');
set(vid,'FramesPerTrigger',1 );
set(vid,'TriggerRepeat', Inf);
% 
start(vid)

trigger(vid);

% Get current frame
I1=getdata(vid,1); 


I1=rgb2gray(I1);
[C1 S1]=wavedec2(I1,2,'haar');
LL2=appcoef2(C1,S1,'haar',2);

% Caclulate number of pixels
totalpixels = numel(LL2);
thA=round(totalpixels/100); % Threshold for the noise removal


% Calculate size of video
[nr nc m]=size(I1);
% preview(vid)
for k=1:500
  
    trigger(vid);
    
    % Get current frame
    I=getdata(vid,1);

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
    
    subplot(131)
    imshow(I);
    title(['Frame no = ' num2str(i)])

    subplot(132)
    imshow(bw)
    title('Moving mask')

    % Initialise image
    MovingIm = zeros(nr,nc,3);
    
    % Get bounding box of the object
    P = regionprops(bw,'BoundingBox');
    
    % Concatinate 
    P = cat(1,P.BoundingBox);
    P = ceil(P);
    % Concatinate in one dimension
    for n = 1:size(P,1)
        
        try
            % Get the values
            MovingIm(P(n,2):P(n,4)+P(n,2),P(n,1):P(n,3)+P(n,1),:) = imcrop(I,P(n,:));
        end
    end
    
    subplot(133)
    imshow(uint8(MovingIm))
    title('Moving object')
    pause(0.01)
    
    pause(0.001)
end
