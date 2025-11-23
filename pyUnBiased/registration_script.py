import ants
import argparse
import numpy as np
import os

# Parse command-line arguments
parser = argparse.ArgumentParser(description="Register two images using ANTsPy.")
parser.add_argument('--fixed_image', type=str, required=True, help="Path to the fixed image")
parser.add_argument('--moving_image', type=str, required=True, help="Path to the moving image")
parser.add_argument('--atlas_image', type=str, required=True, help="Path to the atlas image for affine registration")
parser.add_argument('--output_prefix', type=str, required=True, help="Prefix for the output files")
parser.add_argument('--num_cores', type=int, default=1, help="Number of CPU cores to use for registration")
args = parser.parse_args()

# Set the number of cores to use
os.environ["ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS"] = str(args.num_cores)

# Load the atlas image
atlas_image = ants.image_read(args.atlas_image)

# Load the fixed and moving images
fixed_image = ants.image_read(args.fixed_image)
moving_image = ants.image_read(args.moving_image)

# Load masks for the fixed and moving images
fixed_mask_path = args.fixed_image.replace('.tif', '_Probabilities.tiff')
moving_mask_path = args.moving_image.replace('.tif', '_Probabilities.tiff')

# Ensure masks exist before proceeding
if not os.path.exists(fixed_mask_path) or not os.path.exists(moving_mask_path):
    raise FileNotFoundError("One or both of the required masks are missing.")

# Load and binarize the masks
fixed_mask = ants.image_read(fixed_mask_path)
fixed_mask = fixed_mask > 0.5  # Binarize the fixed mask

moving_mask = ants.image_read(moving_mask_path)
moving_mask = moving_mask > 0.5  # Binarize the moving mask

# Perform affine registration of the fixed image to the atlas with masks
affine_fixed = ants.registration(
    fixed=atlas_image, 
    moving=fixed_image, 
    type_of_transform="QuickRigid", 
    aff_metric = 'GC',
    aff_sampling = 3,
    verbose=True, 
    mask=fixed_mask
)
affine_fixed_image = affine_fixed['warpedmovout']

# Perform affine registration of the moving image to the atlas with masks
affine_moving = ants.registration(
    fixed=atlas_image, 
    moving=moving_image, 
    type_of_transform="QuickRigid", 
    aff_metric = 'GC',
    aff_sampling = 3,
    verbose=True, 
    mask=moving_mask
)
affine_moving_image = affine_moving['warpedmovout']

# Apply affine transformations to the masks
affine_fixed_mask = ants.apply_transforms(
    fixed=atlas_image, 
    moving=fixed_mask, 
    transformlist=affine_fixed['fwdtransforms'], 
    interpolator='nearestNeighbor'
)
affine_moving_mask = ants.apply_transforms(
    fixed=atlas_image, 
    moving=moving_mask, 
    transformlist=affine_moving['fwdtransforms'], 
    interpolator='nearestNeighbor'
)

# Perform SyN registration using the affine-aligned images and masks
reg_syn = ants.registration(
    fixed=affine_fixed_image, 
    moving=affine_moving_image, 
    type_of_transform="SyNOnly",
    syn_metric='CC', 
    verbose=True, 
    grad_step=0.20, 
    syn_sampling=4, 
    reg_iterations=[300, 30, 0],
    mask=affine_fixed_mask,  # Apply affine-transformed fixed image mask
    moving_mask=affine_moving_mask  # Apply affine-transformed moving image mask
)

# Save the resulting deformation field
deformation_field = ants.image_read(reg_syn['fwdtransforms'][0])

# Scale the deformation field by 0.25
scaled_deformation_field = deformation_field * 0.25

# Save the scaled deformation field to disk
scaled_deformation_field_path = f"{args.output_prefix}_scaled_deformation.nii.gz"
ants.image_write(scaled_deformation_field, scaled_deformation_field_path)

# Save the warped output image as .tif
warped_image_path = f"{args.output_prefix}_warped.tif"
ants.image_write(reg_syn['warpedmovout'], warped_image_path)

# Deform and save the moving mask as _Probabilities.tiff
warped_mask_path = warped_image_path.replace('.tif', '_Probabilities.tiff')

# Apply the scaled deformation field to the moving mask
warped_mask = ants.apply_transforms(fixed=affine_fixed_image, moving=affine_moving_mask, transformlist=[scaled_deformation_field_path], interpolator='linear')
ants.image_write(warped_mask, warped_mask_path)

# Calculate the total deformation field strength, normalized by the number of pixels
deformation_magnitude = np.sqrt(np.sum(np.square(scaled_deformation_field.numpy()), axis=-1))
total_deformation_strength = np.sum(deformation_magnitude) / deformation_magnitude.size

# Save the deformation strength to a file
with open(f"{args.output_prefix}_deformation_strength.txt", "w") as f:
    f.write(str(total_deformation_strength))

print(f"Registration complete. Warped image saved to {warped_image_path}. Warped mask saved to {warped_mask_path}.")
