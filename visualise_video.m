clc;
clear all;
close all;
%%
infilename = 'LeftBag.mpg';
% Read video file
vid=VideoReader(infilename);

% Determine number of frames
nf = vid.NumberOfFrames;

%% Perform DWT on first frame

for i=1:10:2000
    I = read(vid,i);
    imshow(I);
    title(['Frame : ' num2str(i)])
    pause(0.00001)
end