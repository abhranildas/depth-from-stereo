% Load and show the stereo images:
left=imread('motorcycle_left.png'); right=imread('motorcycle_right.png');
figure(1);
subplot(1,2,1); image(right); axis image; axis off
subplot(1,2,2); image(left); axis image; axis off

% Convert them to grayscale:
left_grey=mean(left,3); right_grey=mean(right,3);

% Initiate disparity map:
disp_subpixel=zeros(size(left_grey),'single');

% The disparity range defines up to how many pixels away from the block's 
% location in the first image to search for a matching block in the second.
disparity_range=50;

% Define the size of the blocks for block matching:
half_block_size=3; block_size=2*half_block_size+1;

% Get image dimensions:
[img_height,img_width]=size(left_grey);

% Show progress bar:
h=waitbar(0,'Computing disparity map...');

% For each row of pixels in the image...
for m=1:img_height
    % Set min/max row bounds for the template and blocks.
    % e.g., for the first row, minr = 1 and maxr = 4
    min_r=max(1,m-half_block_size);
    max_r=min(img_height,m+half_block_size);
    % For each column of pixels in the image...
    for n=1:img_width
        
        % Set the min/max column bounds for the template.
        % e.g., for the first column, minc = 1 and maxc = 4
        min_c=max(1,n-half_block_size);
        max_c=min(img_width,n+half_block_size);
        
        % Define the search boundaries as offsets from the template 
        % location. For properly rectified images we only need to search to
        % the right, so min_d is 0. For images that require searching in 
        % both directions, set min_d to:
        % min_d=max(-disparity_range,1-min_c);
        min_d=0;
        max_d=min(disparity_range,img_width-max_c);
        
        % Select the block from the right image to use as the template:
        template=right_grey(min_r:max_r,min_c:max_c);
        
        % Number of blocks in this search:
        n_blocks=max_d-min_d+1;
        
        % Create a vector to hold the block index differences:
        block_diffs=zeros(n_blocks,1);
        
        % Calculate the difference between the template and each block:
        for i=min_d:max_d
            
            % Select the block from the left image at the distance i:
            block=left_grey(min_r:max_r,(min_c+i):(max_c+i));
            
            % Put the index of this block into the 'block_diffs' vector:
            block_index=i-min_d+1;
            
            % Store the L1 difference between the template and the block:
            block_diffs(block_index,1)=sum(abs(template(:)-block(:)));
        end
        
        % Convert the index of the smallest L1 difference to disparity value:
        [~,best_match_index]=min(block_diffs);
        d=best_match_index+min_d-1;
        
        % Calculate a sub-pixel estimate of the disparity by interpolating.
        % This requires a block to the left and right, so we skip it if the
        % best matching block is at either edge of the search window.
        if ((best_match_index==1)||(best_match_index==n_blocks))
            
            % Skip sub-pixel estimation and store the initial disparity:
            disp_subpixel(m,n)=d;
        else
            
            % Grab the L1 differences at the closest matching block (C2) 
            % and its immediate neighbours (C1 and C3).
            C1=block_diffs(best_match_index - 1);
            C2=block_diffs(best_match_index);
            C3=block_diffs(best_match_index + 1);
            
            % Calculate the subpixel disparity:
            disp_subpixel(m,n)=d-(0.5*(C3-C1)/(C1-(2*C2)+C3));
        end
    end
    
    % Show progress bar:
    waitbar(m/img_height,h)
end
close(h)

% Show disparity map:
figure; imagesc(disp_subpixel); axis image; axis off; colormap jet