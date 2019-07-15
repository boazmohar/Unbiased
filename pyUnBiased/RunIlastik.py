import argparse
import glob
import multiprocessing
import os
import psutil
import subprocess
from itertools import repeat
from multiprocessing import Pool
from natsort import natsorted


def run_one_object(all_args):
    """

    :param all_args: tuple [0]: raw data, [1]: segmentation, [2] project name, [3] env_object
    :return: status, command, stdout.decode(), stderr.decode()
    """
    raw_data = all_args[0]
    segmentation_image = all_args[1]
    project_object = all_args[2]
    env_object = all_args[3]
    command = ['/groups/svoboda/home/moharb/ilastik-1.3.2post1-Linux/run_ilastik.sh',
               '--headless',
               '--project=/groups/svoboda/svobodalab/users/moharb/%s' % project_object,
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


def run_ilastik(directory, project_pixel=None, project_object=None, matlab=None):
    """

    :param directory: raw files directory
    :param project_pixel: .ilp file for pixel classification
    :param project_object: .ilp file for object classification
    :param matlab: flag for matlab mask extraction parallelization: 'files' or 'labels'
    :return: 1 if successful
    """
    # input checks
    if project_pixel is None and project_object is None and matlab is None:
        raise ValueError('Need at least one of project_pixel/project_object/matlab to be not None')
    directory_tiffs = os.path.join(directory, '*.tiff')
    directory_tiffs = glob.glob(directory_tiffs)
    directory_tiffs = [x for x in directory_tiffs if 'Cy5' not in x and 'FITC' not in x and 'Texas' not in x]
    if len(directory_tiffs) == 0:
        raise ValueError('found 0 *.tiff files in %s' % directory)
    # get system information
    cpu_count = multiprocessing.cpu_count()
    memory_mb = psutil.virtual_memory()[0] / 1000000

    if project_pixel is not None:
        # environment for pixel
        env_pixel = os.environ.copy()
        env_pixel["LAZYFLOW_THREADS"] = '%d' % cpu_count
        mem_pixel = int(memory_mb * 0.8)
        env_pixel["LAZYFLOW_TOTAL_RAM_MB"] = '%d' % mem_pixel
        print('Pixel env: giving %d cpu_count, giving %dMB memory' % (cpu_count, mem_pixel))
        directory_tiffs = os.path.join(directory, '*.tiff')
        env_string = 'LAZYFLOW_THREADS=%d LAZYFLOW_TOTAL_RAM_MB=%d' % (cpu_count, mem_pixel)
        program_string = '/groups/svoboda/home/moharb/ilastik-1.3.2post1-Linux/run_ilastik.sh --headless'
        project_string = '--project=/groups/svoboda/svobodalab/users/moharb/%s' % project_pixel
        os.system('{} {} {} {}'.format(env_string, program_string, project_string, directory_tiffs))
        print('~~~~~~~~Done with pixel~~~~~~~~~~~~~~')

    if project_object is not None:
        # environment for object
        env_object = os.environ.copy()
        env_object["LAZYFLOW_THREADS"] = '1'
        mem_object = int(memory_mb / (cpu_count + 2))
        env_object["LAZYFLOW_TOTAL_RAM_MB"] = '%d' % mem_object
        print('Object env: Found %d cpu_count giving 1, giving %dMB memory' % (cpu_count, mem_object))

        # prepare arguments
        directory_tiffs = os.path.join(directory, '*.tiff')
        directory_tiffs = glob.glob(directory_tiffs)
        directory_tiffs = [x for x in directory_tiffs if 'Cy5' not in x and 'FITC' not in x and 'Texas' not in x]
        raw_files = natsorted(directory_tiffs)
        prob_files = natsorted(glob.glob(os.path.join(directory, '*.h5')))
        print('Found %d raw and %d prob files' % (len(raw_files), len(prob_files)))
        if not len(raw_files) == len(prob_files):
            raise ValueError('Number of files not the same %d != %d' % (len(raw_files), len(prob_files)))
        all_input_args = zip(raw_files, prob_files, repeat(project_object, len(raw_files)),
                             repeat(env_object, len(raw_files)))


        # run object

        p = Pool(cpu_count)
        object_results = p.map(run_one_object, all_input_args)
        all_status = sum([x[0] for x in object_results])
        if not len(raw_files) == all_status:
            raise ValueError('Some files failed object: %d != %d' % (len(raw_files), all_status))
        print('~~~~~~~~Done with object~~~~~~~~~~~~~~')

    if matlab:
        os.chdir(directory)
        os.system("/usr/local/matlab-2018b/bin/matlab -r 'try GetMasks_par_files_v2({});" 
                  " catch; end; quit'".format(cpu_count))
        print('~~~~~~~~Done with matlab~~~~~~~~~~~~~~')
    return 1


if __name__ == "__main__":
    # Get the arguments list
    parser = argparse.ArgumentParser()
    parser.add_argument("directory", help="raw data directory")
    parser.add_argument("-p", "--project_pixel", help=".ilp file for pixel classification")
    parser.add_argument("-o", "--project_object", help=".ilp file for object classification")
    parser.add_argument("-m", "--matlab", help="flag for matlab empty=don't run")
    args = parser.parse_args()
    if not (args.project_pixel or args.project_object or args.matlab):
        parser.error('No action requested, add project_pixel, project_object or matlab')
    run_ilastik(directory=args.directory, project_pixel=args.project_pixel,
                project_object=args.project_object, matlab=args.matlab)
