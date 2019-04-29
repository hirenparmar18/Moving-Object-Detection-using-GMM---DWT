clc;
clear all;
close all;
%%
% vid=mmreader('sequence.mpg');
% 
% frames=read(vid);
%------------------------------------------
x=mmreader('video4.mpg');
% Read the frames
frames = read(x); 
%-----------------------------------------------
% x=mmreader('video1.wmv');
% frames=read(x,[660 790]);
%----------------------------------------------
% x=mmreader('video3.mpg');
% frames=read(x,[300 500]);
%-----------------------------------------------

[m n c Totalframes]=size(frames);

Im_Array=zeros(m,n,Totalframes);

for k=1:Totalframes
    F=frames(:,:,:,k);
    Im_Array(:,:,k)=double(rgb2gray(F));
    imshow(F)
    pause(0.01)
end

%% Background registration

% Any pre defined value
p=1; 
k=5;

% Finding the frame differences

for m=1:Totalframes-k
    FD(:,:,p)=abs(Im_Array(:,:,m+k)-Im_Array(:,:,m));
    p=p+1;
end
p=1;
q=2;%
BG=zeros(size(FD,1),size(FD,2));
for i=1:size(FD,3)-1
    p=i;q=i+1;
    BE=(FD(:,:,p)==FD(:,:,q));
    frame=Im_Array(:,:,p);
    idx=find(BE);
    BG(idx)=frame(idx);
    imshow(BG,[])
    pause(0.01)
end
BG=uint8(BG);
BG=medfilt2(BG);
BG=double(BG);
% BG=imfill(BG,'holes');

% BG=Im_Array(:,:,1);
% imshow(BG);
% BG=double(BG);
% figure;

% load BG
for i=1:Totalframes
    Currentframe=Im_Array(:,:,i);
    subplot(1,3,1)
    imshow(uint8(Currentframe))
    title('Original image');
    
    DiffObject=abs(BG-Currentframe);
    % Apply first the high threshold to detect real moving object.
    Oidx=DiffObject>50;
    
    % Perform morphological operation    
    Oidx=bwareaopen(Oidx,100);
    se= strel('square',10); 
    Oidx = imdilate(Oidx,se); 
    
    % Apply low threshold to obtain the information of moving object
    Oidx1=(DiffObject.*Oidx)>15;
    Oidx1=imfill(Oidx1,'holes');
    Oidx1=bwareaopen(Oidx1,50);
    
    % Label the areas to count total objects in video    
    L=bwlabel(Oidx1);
    count=max(max(L));
    
    % Plot
    subplot(1,3,2)
    imshow(Oidx1,[]); 
    title('Morphological operation');
    subplot(1,3,3)
    objects=Currentframe.*Oidx1;
    imshow(objects,[])
    text(15,15,num2str(count),'color','r')
    title('Identified project');
    pause(0.1)
    
end







