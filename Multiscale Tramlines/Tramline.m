% Tramline - high level routine to perform tramline detection of blood vessels,
% returning a tram-line image.

function [TLO1, meanthreshold, stdthreshold] = Tramline( image, TramThresh, outerW, innerW, outerL, innerL, Threshold, Dataset)

    global outerMask;
     
    %normal 
%     TramThresh = 0.035;%0.01;%0.05;%stare %0.015 0.0075
%     %just for testing
%     outerW = 13;
%     innerW = 0;
%     outerL = 7; %7
%     innerL = 7; %7
%     normal=[0.0195, 13, 0, 7, 7, 0]
%     STARE=[0.0195, 11, 0, 7, 7, 0]
%     DRIVE=[0.0195, 11, 0, 7, 7, 0]
%     MultiResolution=[0.0195, 19, 0, 7, 7, 0]

    % Tramline filter with given widths and length
    TLOResponse = TramlineSingle( image, outerW, outerL, innerW, innerL );
    %figure; imshow(TLOResponse);
    %Bashir 4/4/2012
    if Dataset == 22 % Authentication
         TLO1 = (TLOResponse > TramThresh) & outerMask;
   
    elseif  Dataset == 20 %Tortousity
         TLO1 = (TLOResponse > TramThresh) & outerMask;
    
    elseif 0
        %f=mmnorm(TLOResponse); f1=f>0.72 & outerMask; figure; imshow(f1);
        %n=TLOResponse; n(find(n<0))=0; nn=mmnorm(n); n1=nn>0.0725 & outerMask; figure; imshow(n1);
        %TLOResponse(find(TLOResponse<0))=0;
        TLOResponse = mmnorm(TLOResponse) .* outerMask;
        LOW_HIGH = stretchlim(TLOResponse(find(TLOResponse>0.1)));
        J = imadjust(TLOResponse,LOW_HIGH,[0; 1]); figure; imshow(J);
        mid=(LOW_HIGH(2)+LOW_HIGH(1))/2;
        dis=(LOW_HIGH(2)-LOW_HIGH(1))/2;
        TramThresh= mid -TramThresh*dis;
        %TLOResponse = TLOResponse .* outerMask;
        %in normal distribution, segma = 34.1%
        %TramThresh = mean2(TLOResponse(find(outerMask)))+TramThresh*std2(TLOResponse(find(outerMask))); %I might use 4/10 TramThresh=35/100
        %TramThresh = mean2(TLOResponse(find(TLOResponse>0)))-TramThresh*std2(TLOResponse(find(TLOResponse>0))); %I might use 4/10 TramThresh=35/100
        TLO1 = (TLOResponse > TramThresh);
        
    else %when the whole image is available
        %this approch give the best results when the threshold equal 0.0045
        %Kappa equals 71.54
        TLO1 = (TLOResponse > TramThresh) & outerMask;
        TL = bwmorph( TLO1, 'thin', Inf ); % thin, to clean up odd pixels after spur removal
        [s1,s2]=size(TL);
        ratio=(sum(sum(TL)))/(s1*s2);
        clear TL;
        
        %golden value for ratio is 0.03
        global vesselbackground;
        
        factor = ratio/vesselbackground;
        
        TramThresh= TramThresh * factor^2;
        TLO1 = (TLOResponse > TramThresh) & outerMask;
       
    end
    
    meanthreshold = 0;%mean2(TLOResponse(find(TLOResponse>0)));
    stdthreshold = 0;%std2(TLOResponse(find(TLOResponse>0))); %I might use 4/10 TramThresh=35/100

    %Threshold the tramline response, and remove outside retina and boundary of retina
    %TL = ( TLResponse > Thresh ) & imerode(Image > GetOutsideThreshold(Image), strel('disk',6) );
%     if isempty(outerMask)
%         %Andrew code
%         outerMask = imerode(image > Threshold, strel('disk',3) );
%     end
    %TLO1 = ( TLOResponse > TramThresh ) & imerode(outerMask, strel('diamond',12)); %figure; imshow(TLO1);
    %MTLO1 = mmnorm(TLOResponse);
    %MTLO1 = (MTLO1 > 0.595); figure; imshow(T1);
   

    %%%%%%%%%%%%%%%%%%%%%%%
    if 0
        %This is just a new Idea to enhance the main image by adding the result of the filter (Tramline) 
        %to the main image then normali it, I need to test this and to comopare with the previouis results
        %Nimage=mmnorm(image-TLOResponse);
        %figure; imshow(image);
        global GBImg;
        TLOResponse(find(TLOResponse<0))=0;
        TLOResponse = mmnorm(TLOResponse) ;
        %LOW_HIGH = stretchlim(TLOResponse(find(TLOResponse>0.1)));
        %TLOResponse = imadjust(TLOResponse,LOW_HIGH,[0; 1]);
        GBImg =(mmnorm((1-TLOResponse) + GBImg)); figure; imshow(GBImg);
    end
    %%%%%%%%%%%%%%%%%%%%%%%
    %figure; imshow(TLO1);
    clear TLOResponse
    %close        

    return