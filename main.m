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

for ii = 2:300

    % Read previous frame
    fp = read(vid,ii-1);
    
    % Read current frame
    fc = read(vid,ii);
    
    % Read next frame
    fn = read(vid,ii+1);
    
    % Convert images to gray scale
    fpg = double(rgb2gray(fp));
    fcg = double(rgb2gray(fc));
    fng = double(rgb2gray(fn));
        
    % Divide image into 5x5 blocks and calculate correlation coefficient
    Bp = im2col(fpg,[BS BS],'distinct');
    Bc = im2col(fcg,[BS BS],'distinct');
    Bn = im2col(fng,[BS BS],'distinct');
    
    % Initiliase empty correlation matrix
    C1 = zeros(size(Bp));
    C2 = zeros(size(Bp));
    
    % Calculate correlation of each column
    for n = 1:size(Bp,2)
        
        c1t = corr2(Bp(:,n),Bc(:,n));
        c2t = corr2(Bc(:,n),Bn(:,n));
        
        if isnan(c1t) % If both are same
            c1t = 1;
        end
        
        if isnan(c2t)
            c2t = 1;
        end
        % Store the value
        C1(:,n) = repmat(c1t,[BS*BS 1]);
        C2(:,n) = repmat(c2t,[BS*BS 1]);
        
    end
    
    % Convert back to image
    im1 = col2im(C1,[BS BS],[nr nc],'distinct');
    im2 = col2im(C2,[BS BS],[nr nc],'distinct');
    
    % Compare with treshold and create binary image
    bw1 = im1 < Tb;
    bw2 = im2 < Tb;
    
    % And operation
    bw = bw1&bw2;
    
    % Noise filtering
    bw = bwmorph(bw,'dilate',3);
    
    % Remove smaller area
    bw = bwareaopen(bw,BS*BS*5);
    
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
    
    
    subplot(331)
    imshow(fp)
    title('Previous frame');
    
    subplot(332)
    imshow(fc)
    title(['Current frame : ' num2str(ii)])
    
    subplot(333)
    imshow(fn)
    title('Next frame')
    
    subplot(334)
    imshow(im1,[0 1])
    title('CCprev-curr')
    
    subplot(335)
    imshow(im2,[0 1])
    title('CCcurr-next')
    
    subplot(336)
    imshow(bw1)
    title('Binary 1')
    
    subplot(337)
    imshow(bw2)
    title('Binary 2')
    
    subplot(338)
    imshow(bw)
    title('and operation');
    
    subplot(339)
    imshow(uint8(MovingIm))
    title('Cropped motion region')
    
   
end