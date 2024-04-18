clearvars

phase_folder_3d = 'H:\Lauren\Github upload\M1\Tomogram';
mask_folder = 'H:\Lauren\Github upload\M1\MIP mask';
saving_folder = 'H:\Lauren\Github upload\M1\Segment cells';


threshold_ri = 1.34;
base_ri = 1.337;

phasemap_file_list = dir(fullfile(phase_folder_3d, '*.tiff'));
mask_folder1_list = dir(fullfile(mask_folder, '*.tiff'));

wavelength=532e-9;      % wavelength (m)
alpha=0.2;           % refractive index increment (um^3/pg)
pixel_x = 0.095;  % actual pixel size (um)
pixel_y = 0.095;
pixel_z = 0.19;

% h = 208;

index = 1;

for ii = 1:size(mask_folder1_list,1)
    disp(ii)
    mask_filename_list{ii} = convertCharsToStrings(mask_folder1_list(ii).name);
    mask_file1 = mask_folder1_list(ii).name;
    mask_file2 = mask_file1(1:20); 
    
    for ij = 1:size(phasemap_file_list,1)
        phasemap_file1 = phasemap_file_list(ij).name;
        phasemap_file2 = phasemap_file1(1:20); 
        
        tf = strcmp(mask_file2,phasemap_file2);
        compare_matrix(ij) = tf;        
    end
    
    mask_image1 = imread(fullfile(mask_folder, mask_file1));
    mask_image2 = im2double(mask_image1);
    
    unique_vals = unique(mask_image2);
    
   for ik = 2:size(unique_vals,1)
        mask_image3 = mask_image2;
        mask_image3(mask_image3 ~= unique_vals(ik,1)) = 0;
        mask_image3(mask_image3 > 0) = 1;
        
        [~,col] = find(compare_matrix == 1);
        phasemap_file3 = phasemap_file_list(col).name;
        tiff_stack = loadtiff(fullfile(phase_folder_3d, phasemap_file3));
        
        h = size(tiff_stack,3);
        
        for im = 1:h 
            mask_stack_3d(:,:,im) = mask_image3;
        end
        

        
        tiff_stack = double(tiff_stack);
        yourImage = mask_stack_3d.*tiff_stack;
        
        yourImage1 = yourImage./1e4;
        yourImage1 (yourImage1 < threshold_ri) = 0;
        
        
        BW_segment = clear_extra_noise_v2(yourImage1,h);

        
         % dry mass
        image_mass = BW_segment.*yourImage1;
        data1 = image_mass - base_ri;
        data1 = data1/alpha;
        data1 = data1.*pixel_x.*pixel_y.*pixel_z;
        data1(data1 < 0) = 0;
        drymass_cp(index) = sum(data1, 'all');

        % volume calculation
        
        volume_segment(index) = nnz(BW_segment).*pixel_x.*pixel_y.*pixel_z;

        index = index + 1;

       
        
%         file_save in mat format
%         filename = sprintf('%s%d.mat', mask_file1, ik);
%         save(fullfile(saving_folder, filename), 'yourImage1');
%         index = index + 1;
   
  
   clearvars  phasemap_file1 phasemap_file2 phasemap_file3 tf...
        mask_stack_3d tiff_stack yourImage mask_image3  data1 ...
         non_zero norm_nz smooth_nz diff_snz idx idx2 idx3 ...
         idx4_all idx4 idx3_all idx3 ...
         yourImage1 data1
      

   
 
         
   end
%    
   clearvars mask_file1 mask_file2 mask_image1 compare_matrix 
end
        
    
result = table(mask_filename_list', drymass_cp', volume_segment');
    
