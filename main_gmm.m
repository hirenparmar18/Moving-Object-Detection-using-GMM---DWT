clc;
clear all;
close all;
%%

% Construct video object
vid = VideoReader('hall_monitor.mpg');

% Read single frame
f = read(vid,1);

% Get the size of frame
[nr, nc, m] = size(f);

% Threshold for correlation binarisation
Tb = 0.25;

% Block size
BS = 10;

  hfg = vision.ForegroundDetector(...
       'NumTrainingFrames', 5, ... % 5 because of short video
       'InitialVariance', 30*30); % initial standard deviation of 3
   
for ii = 2:300

    % Read previous frame
    fp = read(vid,ii-1);
    
    % Read current frame
    fc = read(vid,ii);
    
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