%% Initialization

winopen('C:/Program Files (x86)/Google/Google Earth/client/googleearth.exe');


redThresh = 0.15; % Threshold for red detection
greenThresh = 0.090; % Threshold for green detection
blueThresh = 0.20; % Threshold for blue detection

yellowThresh = 0.8;

vidDevice = imaq.VideoDevice('winvideo', 2);
%{
,'YUY2_640x480', ... % Acquire input video stream
'ROI', [1 1 640 480], ...
'ReturnedColorSpace', 'rgb');
%}

vidInfo = imaqhwinfo(vidDevice); % Acquire input video property
hblob = vision.BlobAnalysis('AreaOutputPort', false, ... % Set blob analysis handling
'CentroidOutputPort', true, ...
'BoundingBoxOutputPort', true', ...
'MinimumBlobArea', 500, ...
'MaximumBlobArea', 3500, ...
'MaximumCount', 3);
hshapeinsRedBox = vision.ShapeInserter('BorderColor', 'Custom', ... % Set Red box handling
'CustomBorderColor', [1 0 0], ...
'Fill', true, ...
'CustomFillColor', [1 0 0], ...
'Opacity', 0.4);

hshapeinsGreenBox = vision.ShapeInserter('BorderColor', 'Custom', ... % Set Green box handling
'CustomBorderColor', [0 1 0], ...
'Fill', true, ...
'FillColor', 'Custom', ...
'CustomFillColor', [0 1 0], ...
'Opacity', 0.4);
hshapeinsBlueBox = vision.ShapeInserter('BorderColor', 'Custom', ... % Set Blue box handling
'CustomBorderColor', [0 0 1], ...
'Fill', true, ...
'FillColor', 'Custom', ...
'CustomFillColor', [0 0 1], ...
'Opacity', 0.4);


hshapeinsYellowBox = vision.ShapeInserter('BorderColor', 'Custom', ... % Set Yellow box handling
'CustomBorderColor', [1 1 0], ...
'Fill', true, ...
'CustomFillColor', [1 1 0], ...
'Opacity', 0.4);

htextinsRed = vision.TextInserter('Text', 'Red : %2d', ... % Set text for number of blobs
'Location', [5 2], ...
'Color', [1 0 0], ... // red color
'Font', 'Courier New', ...
'FontSize', 14);
htextinsGreen = vision.TextInserter('Text', 'Green : %2d', ... % Set text for number of blobs
'Location', [5 18], ...
'Color', [0 1 0], ... // green color
'Font', 'Courier New', ...
'FontSize', 14);
htextinsBlue = vision.TextInserter('Text', 'Blue : %2d', ... % Set text for number of blobs
'Location', [5 34], ...
'Color', [0 0 1], ... // blue color
'Font', 'Courier New', ...
'FontSize', 14);

htextinsYellow = vision.TextInserter('Text', 'Yellow : %2d', ... % Set text for number of blobs
'Location', [5 50], ...
'Color', [1 1 0], ... // yellow color
'Font', 'Courier New', ...
'FontSize', 14);



htextinsCent = vision.TextInserter('Text', '+ X:%4d, Y:%4d', ... % set text for centroid
'LocationSource', 'Input port', ...
'Color', [1 1 1], ... // white color
'Font', 'Courier New', ...
'FontSize', 14);
hVideoIn = vision.VideoPlayer('Name', 'Final Video', ... % Output video player
'Position', [100 100 vidInfo.MaxWidth+20 vidInfo.MaxHeight+30]);
nFrame = 0; % Frame number initialization


import java.awt.Robot;
import java.awt.event.*;
my=Robot();

centXBlue=0;
centYBlue=0;
centXRed=0;
centYRed=0;
centXGreen=0;
centYGreen=0;


centXBlue1=0;
centYBlue1=0;
centXRed1=0;
centYRed1=0;
centXGreen1=0;
centYGreen1=0;


xp=0;
yp=0;

del=5;

pressl=1;
pressr=1;

binFrameRed=ones(480,640);
%binFrameRed(0,0,:)=22;

%% Processing Loop
while(nFrame < 2000)
rgbFrame = step(vidDevice); % Acquire single frame
rgbFrame = flipdim(rgbFrame,2); % obtain the mirror image for displaying
diffFrameRed = imsubtract(rgbFrame(:,:,1), rgb2gray(rgbFrame)); % Get red component of the image
diffFrameRed = medfilt2(diffFrameRed, [3 3]); % Filter out the noise by using median filter
binFrameRed = im2bw(diffFrameRed, redThresh); % Convert the image into binary image with the red objects as white
diffFrameGreen = imsubtract(rgbFrame(:,:,2), rgb2gray(rgbFrame)); % Get green component of the image
diffFrameGreen = medfilt2(diffFrameGreen, [3 3]); % Filter out the noise by using median filter
binFrameGreen = im2bw(diffFrameGreen, greenThresh); % Convert the image into binary image with the green objects as white
diffFrameBlue = imsubtract(rgbFrame(:,:,3), rgb2gray(rgbFrame)); % Get blue component of the image
diffFrameBlue = medfilt2(diffFrameBlue, [3 3]); % Filter out the noise by using median filter
binFrameBlue = im2bw(diffFrameBlue, blueThresh); % Convert the image into binary image with the blue objects as white

ir=rgbFrame(:,:,1);
ig=rgbFrame(:,:,2);
ib=rgbFrame(:,:,3);

x=0;
y=0;

yellowFrame = imadd(rgbFrame(:,:,1)./2,rgbFrame(:,:,2)./2);
diffFrameYellow = imsubtract(yellowFrame, rgb2gray(rgbFrame)); % Get red component of the image
diffFrameYellow = medfilt2(diffFrameYellow, [3 3]); % Filter out the noise by using median filter
binFrameYellow = im2bw(diffFrameYellow, yellowThresh); % Convert the image into binary image with the red objects as white

%{

subplot(2,2,1);imshow(ir);
subplot(2,2,2);imshow(binFrameBlue);
subplot(2,2,3);imshow(ig);
subplot(2,2,4);imshow(ib);

%}

[centroidRed, bboxRed] = step(hblob, binFrameRed); % Get the centroids and bounding boxes of the red blobs
centroidRed = uint16(centroidRed); % Convert the centroids into Integer for further steps
[centroidGreen, bboxGreen] = step(hblob, binFrameGreen); % Get the centroids and bounding boxes of the green blobs
centroidGreen = uint16(centroidGreen); % Convert the centroids into Integer for further steps
[centroidBlue, bboxBlue] = step(hblob, binFrameBlue); % Get the centroids and bounding boxes of the blue blobs
centroidBlue = uint16(centroidBlue); % Convert the centroids into Integer for further steps

[centroidYellow, bboxYellow] = step(hblob, binFrameYellow); % Get the centroids and bounding boxes of the red blobs
centroidYellow = uint16(centroidYellow); % Convert the centroids into Integer for further steps


rgbFrame(1:67,1:95,:) = 0; % put a black region on the output stream
vidIn = step(hshapeinsRedBox, rgbFrame, bboxRed); % Instert the red box
vidIn = step(hshapeinsGreenBox, vidIn, bboxGreen); % Instert the green box
vidIn = step(hshapeinsBlueBox, vidIn, bboxBlue); % Instert the blue box
vidIn = step(hshapeinsYellowBox, vidIn, bboxYellow);


for object = 1:1:length(bboxRed(:,1)) % Write the corresponding centroids for red
centXRed = centroidRed(object,1); centYRed = centroidRed(object,2);
vidIn = step(htextinsCent, vidIn, [centXRed centYRed], [centXRed-6 centYRed-9]);
end
for object = 1:1:length(bboxGreen(:,1)) % Write the corresponding centroids for green
centXGreen = centroidGreen(object,1); centYGreen = centroidGreen(object,2);
vidIn = step(htextinsCent, vidIn, [centXGreen centYGreen], [centXGreen-6 centYGreen-9]);
end
for object = 1:1:length(bboxBlue(:,1)) % Write the corresponding centroids for blue
centXBlue = centroidBlue(object,1); centYBlue = centroidBlue(object,2);
vidIn = step(htextinsCent, vidIn, [centXBlue centYBlue], [centXBlue-6 centYBlue-9]);
end

for object = 1:1:length(bboxYellow(:,1)) % Write the corresponding centroids for yellow
centXYellow = centroidYellow(object,1); centYYellow = centroidYellow(object,2);
vidIn = step(htextinsCent, vidIn, [centXYellow centYYellow], [centXYellow-6 centYYellow-9]);
end
if(uint8(length(bboxRed(:,1)))>0)
centXRed1 = centroidRed(1,1);
centYRed1 = centroidRed(1,2);
end

if (uint8(length(bboxGreen(:,1)))>0)
centXGreen1 = centroidGreen(1,1);
centYGreen1 = centroidGreen(1,2);
end

if(uint8(length(bboxBlue(:,1)))>0)
centXBlue1 = centroidBlue(1,1);
centYBlue1 = centroidBlue(1,2);
end




vidIn = step(htextinsRed, vidIn, uint8(length(bboxRed(:,1)))); % Count the number of red blobs
vidIn = step(htextinsGreen, vidIn, uint8(length(bboxGreen(:,1)))); % Count the number of green blobs
vidIn = step(htextinsBlue, vidIn, uint8(length(bboxBlue(:,1)))); % Count the number of blue blobs

vidIn = step(htextinsYellow, vidIn, uint8(length(bboxYellow(:,1)))); % Count the number of yellow blobs


step(hVideoIn, vidIn); % Output video stream


xn=(3.1*centXRed)-70;
yn=(2.4*centYRed)-180;

%my.mouseMove(xn,yn);

%{
if(uint8(length(bboxBlue(:,1)))<2)

if(double(xn)-double(xp)>19)
    my.mouseMove(xp+20,yp);
    xp=xp+20;
else if(double(xp)-double(xn)>19)
    my.mouseMove(xp-20,yp);
    xp=xp-20;
    end
end

if(double(yn)-double(yp)>19)
    my.mouseMove(xp,yp+20);
    yp=yp+20;
else if(double(yp)-double(yn)>19)
    my.mouseMove(xp,yp-20);
    yp=yp-20;
    end
end

end

%}
disXRB=abs(double(centXBlue)-double(centXRed));
disYRB=abs(double(centYBlue)-double(centYRed));

disXRG=abs(double(centXRed)-double(centXGreen));
disYRG=abs(double(centYRed)-double(centYGreen));

disXBG=abs(double(centXBlue)-double(centXGreen));
disYBG=abs(double(centYBlue)-double(centYGreen));





disXR = abs(double(centXRed1)-double(centXRed));
disYR = abs(double(centYRed1)-double(centYRed));

disXG = abs(double(centXGreen1)- double(centXGreen));
disYG = abs(double(centXGreen1)- double(centYGreen));

disXB = abs(double(centXBlue1)-double(centXBlue));
disYB = abs(double(centYBlue1)-double(centYBlue));


if( disXRB<70 && disYRB<80 && (pressl==0) )
            if( uint8(length(bboxRed(:,1)))>0 && uint8(length(bboxBlue(:,1)))==1  )
                my.keyPress(KeyEvent.VK_N);
                pause(.01);
                my.keyRelease(KeyEvent.VK_N);
            end         
end

if( disXRG<70 && disYRG<80 && (pressl==0) )
            if( uint8(length(bboxRed(:,1)))>0 && uint8(length(bboxBlue(:,1)))==1  )
                my.keyPress(KeyEvent.VK_P);
                pause(.01);
                my.keyRelease(KeyEvent.VK_P);
            end

end

if(uint8(length(bboxBlue(:,1))) > 1 && uint8(length(bboxGreen(:,1))) < 2)
    
    if(yn < 450)
        my.mouseWheel(-1);
    end
    
    if(yn > 550)
        
        my.mouseWheel(1);
    end
    
    if(xn<400)
       my.keyPress(KeyEvent.VK_CONTROL);
       pause(.001);
       my.keyPress(KeyEvent.VK_LEFT);
       pause(.001);
       my.keyRelease(KeyEvent.VK_LEFT);
       pause(.001);
       my.keyRelease(KeyEvent.VK_CONTROL);
    end
    
    if(xn>600)
       my.keyPress(KeyEvent.VK_CONTROL);
       pause(.001);
       my.keyPress(KeyEvent.VK_RIGHT);
       pause(.001);
       my.keyRelease(KeyEvent.VK_RIGHT);
       pause(.001);
       my.keyRelease(KeyEvent.VK_CONTROL);
        
    end
    
    
end



%out

if(uint8(length(bboxGreen(:,1))) > 1 && uint8(length(bboxBlue(:,1)))>1 && (disXG>65 || disYG>65 ) && (disXB>65 || disYB>65 ) )
    nFrame=2100;
end


nFrame=nFrame+1;
end
%% Clearing Memory
release(hVideoIn); % Release all memory and buffer used
release(vidDevice);
%clear all;
%clc;
