clear all; clc; close all;                                                

vid=videoinput('winvideo',1);                                             
%figure(3);preview(vid);                                                  
figure(1);
set(vid,'ReturnedColorspace','rgb')
pause(2);                                                                 
IM1=getsnapshot(vid);                                                     
figure(1);subplot(3,3,1);imshow(IM1);title('Background');                 

pause(2);                                                                 
IM2=getsnapshot(vid);                                                     
figure(1);subplot(3,3,2);imshow(IM2);title('Gesture');                    


IM3 = IM1 - IM2;                                                            
figure(1);subplot(3,3,3);imshow(IM3);title('Subtracted');                   
IM3 = rgb2gray(IM3);                                                        
figure(1);subplot(3,3,4);imshow(IM3);title('Grayscale');                    
lvl = graythresh(IM3);                                                      

IM3 = im2bw(IM3, lvl);                                                      
figure(1);subplot(3,3,5);imshow(IM3);title('Black&White');                  
IM3 = bwareaopen(IM3, 10000);
IM3 = imfill(IM3,'holes');
figure(1);subplot(3,3,6);imshow(IM3);title('Small Areas removed & Holes Filled');  
IM3 = imerode(IM3,strel('disk',10));                                        
IM3 = imdilate(IM3,strel('disk',15));                                       
IM3 = medfilt2(IM3, [5 5]);                                                 
figure(1);subplot(3,3,7);imshow(IM3);title('Eroded,Dilated & Median Filtered');  
IM3 = bwareaopen(IM3, 10000);                                               
figure(1);subplot(3,3,8);imshow(IM3);title('Processed');                    
IM3 = flipdim(IM3,1);                                                       
figure(1);subplot(3,3,9);imshow(IM3);title('Flip Image');   


REG=regionprops(IM3,'all');                                                  
CEN = cat(1, REG.Centroid);                                                 
[B] = bwboundaries(IM3,'noholes');                                 

RND = 0;                                                                   


%calculate the properties of regions for objects found
    for k =1:length(B)                                                      
            PER = REG(k).Perimeter;                                          
            ARE = REG(k).Area;                                              
            RND = (4*pi*ARE)/(PER^2);                                       
            
            BND = B{k};                                                     
            BNDx = BND(:,2);                                                
            BNDy = BND(:,1);                                                
            
            pkoffset = 1.5*(CEN(:,2));                             
            [pks,locs] = findpeaks(BNDy,'minpeakheight',pkoffset);         
            pkNo = size(pks,1);                                            
            pkNo_STR = sprintf('%2.0f',pkNo);                              
            
            figure(2);imshow(IM3);
            hold on
            plot(BNDx, BNDy, 'b', 'LineWidth', 2);                          
            plot(CEN(:,1),CEN(:,2), '*');                                   
            plot(BNDx(locs),pks,'rv','MarkerFaceColor','r','lineWidth',2);  
            hold off
    
    end
                                                                            
                                                                            
                                                                            
                                                                           
                                                                            
    % Identification Codes, You might need to change these
    
    CHAR_STR = 'not identified';                                            
    if RND >0.19 && RND < 0.38 && pkNo ==3
        CHAR_STR = 'W';
    elseif RND >0.44 && RND < 0.9  && pkNo ==1
        CHAR_STR = 'O';
    elseif RND >0.37 && RND < 0.55 && pkNo ==2
        CHAR_STR = 'R';
    elseif RND >0.40 && RND < 0.47 && pkNo == 3
        CHAR_STR = 'D';
    else
        CHAR_STR = 'not identified';
    end
    text(20,20,CHAR_STR,'color','r','Fontsize',18);                         
    text(20,100,['RND: ' sprintf('%f',RND)],'color','r','Fontsize',18);
    text(20,180,['PKS: ' pkNo_STR],'color','r','Fontsize',18);