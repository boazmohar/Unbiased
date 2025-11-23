import ants
import argparse
import numpy as np

# Parse command-line arguments
parser = argparse.ArgumentParser(description="Register two images using ANTsPy.")
parser.add_argument('--fixed_image', type=str, required=True, help="Path to the fixed image")
parser.add_argument('--moving_image', type=str, required=True, help="Path to the moving image")
parser.add_argument('--output_prefix', type=str, required=True, help="Prefix for the output files")
args = parser.parse_args()

# Load images
fixed_image = ants.image_read(args.fixed_image)
moving_image = ants.image_read(args.moving_image)

# Perform registration
reg_syn = ants.registration(
    fixed=fixed_image, 
    moving=moving_image, 
    type_of_transform="SyNOnly",
    syn_metric='CC', 
    verbose=True, 
    grad_step=0.20, 
    syn_sampling=4, 
    reg_iterations=[30, 0, 0]
)

# Save the resulting deformation field
deformation_field_path = f"{args.output_prefix}_deformation.nii.gz"
ants.image_write(ants.image_read(reg_syn['fwdtransforms'][0]), deformation_field_path)

# Save the warped output image
warped_image_path = f"{args.output_prefix}_warped.nii.gz"
ants.image_write(reg_syn['warpedmovout'], warped_image_path)

# Calculate the total deformation field strength
deformation_field = ants.image_read(deformation_field_path)
deformation_magnitude = np.sqrt(np.sum(np.square(deformation_field.numpy()), axis=-1))
total_deformation_strength = np.sum(deformation_magnitude)

# Save the deformation strength to a file
with open(f"{args.output_prefix}_deformation_strength.txt", "w") as f:
    f.write(str(total_deformation_strength))
