import os
import subprocess
import time
import random
import re
import numpy as np

# Paths to the images
affine_transformed_images = [
    "affine_ANM540255_crop.tif",
    "affine_ANM544449_crop.tif",
    "affine_ANM545113_crop.tif",
    "affine_ANM545115_crop.tif",
    "affine_ANM546176_crop.tif",
    "affine_ANM546178_crop.tif"
]

# Parameters
max_iterations = 5  # Set the maximum number of iterations
output_dir = "/groups/spruston/home/moharb/Unbiased/pyUnBiased/OUTPUT"
python_script_path = "/groups/spruston/home/moharb/Unbiased/pyUnBiased/registration_script.py"
python_env_activate = "/groups/spruston/home/moharb/mambaforge/envs/pyants/lib/python3.11/venv/scripts/common/activate"
atlas_image = "/groups/spruston/home/moharb/Unbiased/pyUnBiased/atlasVolume.tif"  # Path to the atlas image
num_cores = 64  # Number of cores to use for registration
poll_interval = 20  # Time in seconds to wait before checking job completion

# Track total deformation strength for each iteration
total_deformation_strengths = []

def check_for_errors(error_files):
    """Check for any errors in the .err files."""
    for err_file in error_files:
        if os.path.exists(err_file):
            with open(err_file, 'r') as f:
                content = f.read()
                if content.strip():  # If there's any content in the .err file
                    print(f"Error detected in {err_file}:")
                    print(content)
                    return True
    return False

def generate_output_prefix(output_dir, iteration, moving_image_name):
    """Generate a clean output prefix based on the ANM pattern."""
    # Extract the base name using the regexp for 'ANM' followed by numbers
    match = re.search(r'ANM\d+', moving_image_name)
    base_name = match.group(0) if match else moving_image_name
    return os.path.join(output_dir, f"iter_{iteration:03d}_{base_name}")

# Iterate through the registration process
for iteration in range(1, max_iterations + 1):
    print(f"Starting iteration {iteration}...")
    
    job_ids = []
    iteration_strength = 0

    # Controlled pair selection: each image is the moving image only once
    remaining_images = list(range(len(affine_transformed_images)))
    random.shuffle(remaining_images)
    pairs = []

    for moving_index in remaining_images:
        possible_fixed_indices = [idx for idx in range(len(affine_transformed_images)) if idx != moving_index]
        fixed_index = random.choice(possible_fixed_indices)
        pairs.append((fixed_index, moving_index))

    # Submit jobs for each pair in this iteration
    error_files = []
    deformation_strength_files = []
    for fixed_index, moving_index in pairs:
        fixed_image = affine_transformed_images[fixed_index]
        moving_image = affine_transformed_images[moving_index]
        moving_image_name = os.path.basename(moving_image).replace('.tif', '')  # Extract moving image name without extension
        output_prefix = generate_output_prefix(output_dir, iteration, moving_image_name)  # Generate clean output prefix

        # Prepare the bsub command with all necessary directives
        bsub_command = (
            f"bsub "
            f"-J reg_iter_{iteration}_pair_{fixed_index}_{moving_index} "  # Job name
            f"-o {output_prefix}.%J.out "                                      # Output file
            f"-e {output_prefix}.%J.err "                                      # Error file
            f"-n {num_cores} "                                                 # Number of cores
            f"bash -c 'source {python_env_activate} && python {python_script_path} "
            f"--fixed_image {fixed_image} --moving_image {moving_image} --atlas_image {atlas_image} --output_prefix {output_prefix} --num_cores {num_cores}'"
        )

        # Submit the job using subprocess and capture the job ID
        result = subprocess.run(bsub_command, shell=True, capture_output=True, text=True)
        job_id = result.stdout.strip().split('<')[1].split('>')[0]
        job_ids.append(job_id)

        # Replace %J with the actual job ID in the error file path
        error_file = f"{output_prefix}.{job_id}.err"
        error_files.append(error_file)

        # Track the deformation strength files for deletion later
        deformation_strength_files.append(f"{output_prefix}_deformation_strength.txt")

    # Polling: Wait until all jobs have generated the expected output files or an error is detected
    all_files_exist = False
    while not all_files_exist:
        all_files_exist = True
        if check_for_errors(error_files):
            print("Aborting script due to detected errors.")
            exit(1)
        
        for deformation_strength_file in deformation_strength_files:
            if not os.path.exists(deformation_strength_file):
                all_files_exist = False
                break
        if not all_files_exist:
            print(f"Waiting for jobs to finish... Checking again in {poll_interval} seconds.")
            time.sleep(poll_interval)

    # After all jobs are completed, average the iteration strength, update images, and delete the strength files
    for fixed_index, moving_index in pairs:
        output_prefix = generate_output_prefix(output_dir, iteration, moving_image_name)
        
        # Read the deformation strength after the job finishes
        deformation_strength_file = f"{output_prefix}_deformation_strength.txt"
        with open(deformation_strength_file, "r") as f:
            iteration_strength += float(f.read())
        
        # Load the warped image and update the corresponding moving image in the list
        warped_image_path = f"{output_prefix}_warped.tif"
        affine_transformed_images[moving_index] = warped_image_path

    # Average deformation strength for the iteration
    average_iteration_strength = iteration_strength / len(pairs)
    total_deformation_strengths.append(average_iteration_strength)
    print(f"Average Deformation Strength for Iteration {iteration}: {average_iteration_strength}")

    # Optionally, check if deformation strength is below a threshold to stop early
    # if average_iteration_strength < some_threshold:
    #     print(f"Stopping early at iteration {iteration} due to low deformation strength.")
    #     break

print("All iterations completed.")
np.savetxt(os.path.join(output_dir, "total_deformation_strengths.txt"), total_deformation_strengths)
