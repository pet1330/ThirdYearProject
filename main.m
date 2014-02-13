function main
%% Experiment Directories

if ispc
    currDir = 'C:\Users\pete\Dropbox\Lincoln\Year 3\Final Year Project\Project\ThirdYearProject\Experiment';
else
    currDir= '/home/peter/Dropbox/Lincoln/Year 3/Final Year Project/Project/Experiment';
end

ResultFolder = 'Results';
Imagfolder ='Dataset';
toPrint = 'Starting Experiment';
EnhancementEvaluation_original_second(currDir,ResultFolder,Imagfolder);    

%% Adaptive_Single_Scale_Retinex
try
clc; toPrint = sprintf('%s\nStarting Adaptive_Single_Scale_Retinex',toPrint); disp(toPrint);
EnhancementEvaluation_Adaptive_Single_Scale_Retinex(currDir,ResultFolder,Imagfolder);    
catch
   clc; toPrint = sprintf('%s\nAdaptive_Single_Scale_Retinex FAILED',toPrint); disp(toPrint);
end
%% Anisotropic_Smoothing
try
clc; toPrint = sprintf('%s\nStarting Anisotropic_Smoothing',toPrint); disp(toPrint);
EnhancementEvaluation_Anisotropic_Smoothing(currDir,ResultFolder,Imagfolder);
catch
    clc; toPrint = sprintf('%s\nAnisotropic_Smoothing FAILED',toPrint); disp(toPrint);
end
%% contourlet_transform
try
clc; toPrint = sprintf('%s\nStarting contourlet_transform',toPrint); disp(toPrint);
EnhancementEvaluation_contourlet_transform(currDir,ResultFolder,Imagfolder);
catch
    clc; toPrint = sprintf('%s\nContourlet_transform FAILED',toPrint); disp(toPrint);
end
%% Contrast_Limited_AdaptHistEq
try
clc; toPrint = sprintf('%s\nStarting Contrast_Limited_AdaptHistEq',toPrint); disp(toPrint);
EnhancementEvaluation_Contrast_Limited_AdaptHistEq(currDir,ResultFolder,Imagfolder);
catch
    clc; toPrint = sprintf('%s\nContrast_Limited_AdaptHistEq FAILED',toPrint); disp(toPrint);
end
%% Double_Density_Dual_Tree_Complex
try
clc; toPrint = sprintf('%s\nStarting Double_Density_Dual_Tree_Complex',toPrint); disp(toPrint);
EnhancementEvaluation_Double_Density_Dual_Tree_Complex(currDir,ResultFolder,Imagfolder);
catch
    clc; toPrint = sprintf('%s\nDouble_Density_Dual_Tree_Complex FAILED',toPrint); disp(toPrint);
end
%% Double_Density_Dual_Tree
try
clc; toPrint = sprintf('%s\nStarting Double_Density_Dual_Tree',toPrint); disp(toPrint);
EnhancementEvaluation_Double_Density_Dual_Tree(currDir,ResultFolder,Imagfolder);
catch
    clc; toPrint = sprintf('%s\nDouble_Density_Dual_Tree FAILED',toPrint); disp(toPrint);
end
%% Double_Density_Dual_Tree_Real
try
clc; toPrint = sprintf('%s\nStarting Double_Density_Dual_Tree_Real',toPrint); disp(toPrint);
EnhancementEvaluation_Double_Density_Dual_Tree_Real(currDir,ResultFolder,Imagfolder);
catch
    clc; toPrint = sprintf('%s\nDouble_Density_Dual_Tree_Real FAILED',toPrint); disp(toPrint);
end
%% Gray_world
try
clc; toPrint = sprintf('%s\nStarting Gray_world',toPrint); disp(toPrint);
EnhancementEvaluation_Gray_world(currDir,ResultFolder,Imagfolder);
catch
    clc; toPrint = sprintf('%s\nGray_world FAILED',toPrint); disp(toPrint);
end
%% Histogram_Equalization
try
clc; toPrint = sprintf('%s\nStarting Histogram_Equalization',toPrint); disp(toPrint);
EnhancementEvaluation_Histogram_Equalization(currDir,ResultFolder,Imagfolder);
catch
    clc; toPrint = sprintf('%s\nHistogram_Equalization FAILED',toPrint); disp(toPrint);
end
%% Median_Filter
try
clc; toPrint = sprintf('%s\nStarting Median_Filter',toPrint); disp(toPrint);
EnhancementEvaluation_Median_Filter(currDir,ResultFolder,Imagfolder);
catch
    clc; toPrint = sprintf('%s\nMedian_Filter FAILED',toPrint); disp(toPrint);
end
%% Multi_Scale_Retinex
try
clc; toPrint = sprintf('%s\nStarting Multi_Scale_Retinex',toPrint); disp(toPrint);
EnhancementEvaluation_Multi_Scale_Retinex(currDir,ResultFolder,Imagfolder);
catch
    clc; toPrint = sprintf('%s\nMulti_Scale_Retinex FAILED',toPrint); disp(toPrint);
end
%% original
try
clc; toPrint = sprintf('%s\nStarting original',toPrint); disp(toPrint);
EnhancementEvaluation_original(currDir,ResultFolder,Imagfolder);
catch
    clc; toPrint = sprintf('%s\noriginal FAILED',toPrint); disp(toPrint);
end
%% Single_Scale_Retinex
try
clc; toPrint = sprintf('%s\nStarting Single_Scale_Retinex',toPrint); disp(toPrint);
EnhancementEvaluation_Single_Scale_Retinex(currDir,ResultFolder,Imagfolder);
catch
    clc; toPrint = sprintf('%s\nSingle_Scale_Retinex FAILED',toPrint); disp(toPrint);
end
%% wavelet_transform
try
clc; toPrint = sprintf('%s\nStarting wavelet_transform',toPrint); disp(toPrint);
EnhancementEvaluation_wavelet_transform(currDir,ResultFolder,Imagfolder);
catch
    clc; toPrint = sprintf('%s\nwavelet_transform FAILED',toPrint); disp(toPrint);
end
%% Finishing Feedback
clc; toPrint = sprintf('%s\nAll Tests Completed Successfully',toPrint); disp(toPrint);

end