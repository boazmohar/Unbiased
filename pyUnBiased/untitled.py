import itk
import os
from collections import defaultdict
import h5py
import numpy as np
import pandas as pd
from skimage import io
from skimage.measure import regionprops_table


def read_h5_image(file_path, dataset_name, th=100):
    with h5py.File(file_path, 'r') as h5_file:
        # Replace 'dataset_name' with the actual dataset name in your .h5 file
        data = h5_file[dataset_name][:]
        data[data<100] = 100
        return itk.image_view_from_array(data)

def match_h5_files_by_channels(base_dir):
    file_groups = defaultdict(lambda: {"ch0": None, "ch1": None, "ch2": None})
    
    # Walk through all directories and files in base_dir
    for dirpath, dirnames, filenames in os.walk(base_dir):
        for filename in filenames:
            if filename.endswith('.h5'):
                # Extract the directory name
                dir_name = os.path.basename(dirpath)
                full_path = os.path.join(dirpath, filename)
                
                # Match channel files and exclude "main" files
                if "uni_tp-0_ch-0" in filename:
                    file_groups[dir_name]["ch0"] = full_path
                elif "uni_tp-0_ch-1" in filename:
                    file_groups[dir_name]["ch1"] = full_path
                elif "uni_tp-0_ch-2" in filename:
                    file_groups[dir_name]["ch2"] = full_path
    
    # Filter out groups that don't have all 3 channels (ch0, ch1, ch2)
    valid_file_sets = {key: value for key, value in file_groups.items() if all(value.values())}
    
    return valid_file_sets

base_dir = '/nrs/spruston/Boaz/I2/2024-09-19_iDISCO_CalibrationBrains'
animals = match_h5_files_by_channels(base_dir)
for animal, files in animals.items():
    print(f"animal: {animal}")
    print(f"  Channel 0 file: {files['ch0']}")
    print(f"  Channel 1 file: {files['ch1']}")
    print(f"  Channel 2 file: {files['ch2']}")
    
fx = itk.imread('/nrs/spruston/Boaz/I2/atlas10_hemi.tif',pixel_type=itk.US)
parameter_object = itk.ParameterObject.New()
parameter_object.AddParameterFile('/nrs/spruston/Boaz/I2/itk/Order1_Par0000affine.txt')
parameter_object.AddParameterFile('/nrs/spruston/Boaz/I2/itk/Order3_Par0000bspline.txt')
parameter_object.AddParameterFile('/nrs/spruston/Boaz/I2/itk/Order4_Par0000bspline.txt')
parameter_object.AddParameterFile('/nrs/spruston/Boaz/I2/itk/Order5_Par0000bspline.txt')

for animal, files in animals.items():
    if animal == 'ANM549057_left_JF522':
        continue
    print(animal)
    mv = read_h5_image(files['ch0'], 'Data')
    output_dir= os.path.join(base_dir,animal , 'itk')
    if not os.path.isdir(output_dir):
        os.mkdir(output_dir)
    res, params = itk.elastix_registration_method(fx,
                                              mv,
                                              parameter_object,
                                              log_to_file=True,
                                              output_directory=output_dir)
    
param_files = [f'TransformParameters.{i}.txt' for i in range(4)]

for animal, files in animals.items():
    print(animal)
    output_dir = os.path.join(base_dir,animal , 'itk')

    print(output_dir)

    parameter_object = itk.ParameterObject.New()
    for p in param_files:
        parameter_object.AddParameterFile(os.path.join(output_dir, p))

    for name, path in files.items():
        print(f'Reading {path}')
        moving_image = read_h5_image(path, 'Data')
        print('Reading done')
        transformix_filter = itk.TransformixFilter.New(Input=moving_image, TransformParameterObject=parameter_object)
        transformix_filter.SetComputeSpatialJacobian(False)
        transformix_filter.SetComputeDeterminantOfSpatialJacobian(False)
        transformix_filter.SetComputeDeformationField(False)
        transformix_filter.Update()


        # Get the transformed image
        transformed_image = transformix_filter.GetOutput()
        print('Transfom done')
        # Save the transformed image
        output_image_path = os.path.join(output_dir,name+ '.tif')

        itk.imwrite(transformed_image, output_image_path)
        print(f"Transformed image saved to {output_image_path}")

annotation_np = np.int64(io.imread('/nrs/spruston/Boaz/I2/annotatin10_hemi.tif'))
for animal, files in animals.items():
    print(animal)
    if animal == 'ANM549057_left_JF522':
        continue
    output_dir = os.path.join(base_dir,animal , 'itk')
    print(output_dir)
    image_list = []
  
    for name, path in files.items():
        image_path = os.path.join(output_dir,name+ '.tif')
        print(f'reading {image_path}')
        image_list.append(io.imread(image_path))
    multichannel_image = np.stack(image_list, axis=-1)
    print('finished stacking')
    props = regionprops_table(annotation_np, intensity_image=multichannel_image, 
                          properties=['label', 'mean_intensity', 'area'])
    
    print('finished region props')
    df_stats = pd.DataFrame(props)
    df_stats.rename(columns={
        'mean_intensity-0': 'Mean_ch0',
        'mean_intensity-1': 'Mean_ch1',
        'mean_intensity-2': 'Mean_ch2',
        'area': 'N',  # N represents the area (number of pixels in the region)
        'label': 'Region'
    }, inplace=True)
    csv_path = os.path.join(output_dir,'region_stats.csv')
    print(f'saving csv to {csv_path}')
    df_stats.to_csv(csv_path, index=False)
