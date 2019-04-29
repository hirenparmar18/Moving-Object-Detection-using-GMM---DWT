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
f=getdata(vid,1); 

% Get the size of frame
[nr, nc, m] = size(f);

% Threshold for correlation binarisation
Tb = 0.25;

% Block size
BS = 10;

  hfg = vision.ForegroundDetector(...
       'NumTrainingFrames', 5, ... % 5 because of short video
       'InitialVariance', 30*30); % initial standard deviation of 3
   
for ii = 1:500
    
    
    
    trigger(vid);

    % Get current frame
    fc=getdata(vid,1); 


    subplot(131)
    imshow(fc)
   title(['Frame no = ' num2str(ii)])
    
    % Foreground mask detection using gmm
    bw = step(hfg, fc);
    
    % Show the mask
    subplot(132)
    imshow(bw)
    title('Foreground mask')

    % Initialise image
    MovingIm = zeros(nr,nc,m);
    
    % Get bounding box of the object
    P = regionprops(bw,'BoundingBox');
    
    % Concatinate 
    P = cat(1,P.BoundingBox);
    P = ceil(P);
    % Concatinate in one dimension
    for n = 1:size(P,1)
        
        try
            % Get the values
            MovingIm(P(n,2):P(n,4)+P(n,2),P(n,1):P(n,3)+P(n,1),:) = imcrop(fc,P(n,:));
        end
    end
    
    subplot(133)
    imshow(uint8(MovingIm))
    title('Moving object')
    pause(0.01)
end