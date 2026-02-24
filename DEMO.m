clear all; clc; close all; warning off;

Pathr = '.\data';
Pathw = '.\result';

Files = dir(fullfile(Pathr, '*.png')); 
LengthFiles = length(Files);
factor = 4;  % Scaling factor

% Start the total timer.
total_tic = tic;

for ii = 1:LengthFiles
    fprintf('Now is processing the image named: %s\n', Files(ii).name);
    
    % Timing for processing a single image
    single_tic = tic;

    % Read the original image
    image = double(imread(fullfile(Pathr, Files(ii).name)));
    [h, w, c] = size(image);
    
    % Separation channel
    outimg1 = image(:, :, 1);
    outimg2 = image(:, :, 2);
    outimg3 = image(:, :, 3);

    % Obtain high-frequency residuals
    H1_outimg1 = TGIDE(outimg1); 
    H1_outimg2 = TGIDE(outimg2); 
    H1_outimg3 = TGIDE(outimg3);

    % Resize the residuals back to the original image size.
    Details = zeros(h, w, 3);
    Details(:, :, 1) = imresize(H1_outimg1, [h, w], 'bilinear');
    Details(:, :, 2) = imresize(H1_outimg2, [h, w], 'bilinear');
    Details(:, :, 3) = imresize(H1_outimg3, [h, w], 'bilinear');

    % Fusion detail enhanced image
    enhanced1 = outimg1 + Details(:, :, 1) * factor;
    enhanced2 = outimg2 + Details(:, :, 2) * factor;
    enhanced3 = outimg3 + Details(:, :, 3) * factor;

    % Merge channels and save the image
    outimg = cat(3, enhanced1, enhanced2, enhanced3);
    outimg = uint8(outimg);  % Convert to 8-bit image
    imwrite(outimg, fullfile(Pathw, [Files(ii).name(1:end-4), '_TGIDE_', num2str(factor), '.png']));

    % Time taken to display the current image
    fprintf('Image %d processed in %.2f seconds\n', ii, toc(single_tic));
    disp('...........................');
end

% Display total elapsed time
fprintf('Total processing time for all %d images: %.2f seconds\n', LengthFiles, toc(total_tic));
