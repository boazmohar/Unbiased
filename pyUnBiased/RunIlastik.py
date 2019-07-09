import glob
import multiprocessing
import os
import psutil
import subprocess
from itertools import repeat
from multiprocessing import Pool
from natsort import natsorted


def run_one_object(all_args2):
    """

    :param all_args2: tuple [0]: raw data, [1]: segmentation, [2] project name
    :return: status, command, stdout.decode(), stderr.decode()
    """
    raw_data = all_args2[0]
    segmentation_image = all_args2[1]
    project = all_args2[2]
    command = ['/groups/svoboda/home/moharb/ilastik-1.3.2post1-Linux/run_ilastik.sh',
               '--headless',
               '--project=/groups/svoboda/svobodalab/users/moharb/%s' % project,
               '--readonly=1',
               '--raw_data=%s' % raw_data,
               '--prediction_maps=%s/exported_data' % segmentation_image,
               '--export_source=object predictions',
               '--output_format=tif']

    result = subprocess.Popen(command,
                              env=env_object,
                              stdout=subprocess.PIPE,
                              stderr=subprocess.PIPE)

    stdout, stderr = result.communicate()
    status = 'Completed Batch Processing' in stdout.decode()
    return status, command, stdout.decode(), stderr.decode()


def run_ilastik(project_object, project_pixel, directory):
    """

    :param project_object:
    :param project_pixel:
    :param directory:
    :return:
    """
    cpu_count = multiprocessing.cpu_count()
    memory_mb = psutil.virtual_memory()[0] / 1000000

    # environment for object
    env_object = os.environ.copy()
    env_object["LAZYFLOW_THREADS"] = '1'
    mem_object = int(memory_mb / (cpu_count + 2))
    env_object["LAZYFLOW_TOTAL_RAM_MB"] = '%d' % mem_object
    print('Object: Found %d cpu_count giving 1, giving %dMB memory' % (cpu_count, mem_object))

    # environment for pixel
    env_pixel = os.environ.copy()
    env_pixel["LAZYFLOW_THREADS"] = '%d' % cpu_count
    mem_pixel = int(memory_mb * 0.8)
    env_pixel["LAZYFLOW_TOTAL_RAM_MB"] = '%d' % mem_pixel
    print('Pixel: giving %d cpu_count, giving %dMB memory' % (cpu_count, mem_pixel))

    # prepare arguments
    directory_pixel = os.path.join(directory, '*.tiff')
    raw_files = natsorted(glob.glob(directory_pixel))
    prob_files = natsorted(glob.glob(os.path.join(directory, '*.h5')))
    print('Found %d raw and %d prob files' % (len(raw_files), len(prob_files)))
    assert len(raw_files) == len(prob_files)
    all_args = zip(raw_files, prob_files, repeat(project_object, len(raw_files)))

    # run pixel
    env_string = 'LAZYFLOW_THREADS=%d LAZYFLOW_TOTAL_RAM_MB=%d' % (cpu_count, mem_pixel)
    program_string = '/groups/svoboda/home/moharb/ilastik-1.3.2post1-Linux/run_ilastik.sh --headless'
    project_string = '--project=/groups/svoboda/svobodalab/users/moharb/%s' % project_pixel
    os.system('{} {} {} {}'.format(env_string, program_string, project_string, directory_pixel))

    # run object
    p = Pool(cpu_count)
    object_results = p.map(run_one_object, all_args)
    all_status = sum([x[0] for x in object_results])
    assert len(raw_files) == all_status
