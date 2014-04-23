function Result = EvaluateAlongSegmentsGroundTruth( SM, GTL, Mask)
% Evaluate along segment map performance against a ground-truth image
%for tramline and similar algorithms
% TP : True Positive; Correct Foreground
% VNL : Vascular Network "by length" Located
% FPM : False Positive Measurmed by "excess vessel length"
%*********************************************************

% Produce a skeletonized ground truth
GTs = bwmorph( GTL, 'thin', Inf );
%figure; imshow(GTs);

% Count number of pixels from the vessel map that are in the ground truth.
GTD = imdilate(GTL,strel('disk',3));
%figure; imshow(GTD);

% Count pixels in the ground truth
noPxlGT = sum( GTs(:) ); % = TP + FN

% Produce a skeletonized ground truth
SMs = bwmorph( SM, 'thin', Inf );
%figure; imshow(SMs);

% Count pixels in the Segment map
noPxlSM = sum( SMs(:) ); % = TP + FP

if ~isempty(Mask)
    TP = Mask & SMs & GTD;
else
    TP = SMs & GTD;
end
noTP = sum(TP(:));
noFN = noPxlGT - noTP;
noFP = noPxlSM - noTP;
s=size(SM);
noTN = s(1)*s(2)-noTP-noFP-noFN;

TPFP = noTP+noFP; %positiveResponse (TP+FP)
TPFN = noTP+noFN; %positiveReference (TP+FN)
FPTN = noFP+noTN; %negativeReference (FP+TN)
TPTN = noTP+noTN; %Correct (TP+TN)
Total = noTP+noTN+noFP+noFN;


Sensitivity = noTP/TPFN;
Specificity = noTN/FPTN;
Precision = noTP/TPFP;
Accuracy = TPTN/Total;

referenceLikelihood = TPFN/Total;
responseLikelihood =  TPFP/Total;
randomAccuracy = referenceLikelihood * responseLikelihood + (1 - referenceLikelihood) * (1 - responseLikelihood);
kappa = (Accuracy-randomAccuracy)/(1-randomAccuracy); %(p - e) / (1 - e)

Result = [Sensitivity Specificity Accuracy Precision kappa];
return