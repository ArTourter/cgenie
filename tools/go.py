#!/usr/bin/env python2

from __future__ import print_function
import os, os.path, sys, shutil, argparse, glob
import subprocess as sp

import utils as U


# GENIE configuration.

if not U.read_cgenie_config():
    sys.exit('GENIE not set up: run the setup-cgenie script!')
scons = os.path.join(U.cgenie_root, 'tools', 'scons', 'scons.py')


# Command line arguments.

def usage():
    print("""
Usage: go <command>

Commands:
  clean                                 Clean results
  cleaner                               Clean results and model build
  build [<build-type>] [--no-progress]  Build model
  run [<build-type>] [--no-progress]    Build and run model
  set-platform <platform>               Set explicit build platform
  clear-platform                        Clear explicit build platform
""")
    sys.exit()

build_type = 'ship'
progress = True
if len(sys.argv) < 2: usage()
action = sys.argv[1]
if action in ['clean', 'cleaner', 'clear-platform']:
    if len(sys.argv) != 2: usage()
elif action == 'set-platform':
    if len(sys.argv) != 3: usage()
    platform = sys.argv[2]
elif action in ['build', 'run']:
    if len(sys.argv) == 3:
        if sys.argv[2] == '--no-progress': progress = False
        else:                              build_type = sys.argv[2]
    elif len(sys.argv) == 4:
        build_type = sys.argv[2]
        if sys.argv[3] == '--no-progress': progress = False
        else:                              usage()
    elif len(sys.argv) != 2: usage()
    if build_type and build_type not in U.build_types:
        sys.exit('Unrecognised build type: "', build_type, '"')
else: usage()


def message(s):
    print(79 * '*')
    print('')
    print('    ' + s)
    print('')
    print(79 * '*')
    print('')


# Model configuration for job.

model_config = U.ModelConfig(build_type)
model_dir = model_config.directory()
exe_name = 'genie-' + build_type + '.exe' if build_type else 'genie.exe'


# Clean up output directories for this job and (optionally) build
# directories for model setup for this job.

def clean(clean_model):
    message('CLEANING...')
    if clean_model:
        model_config.clean()
        for exe in glob.iglob('genie-*.exe'): os.remove(exe)
        if os.path.exists('build.log'): os.remove('build.log')
    if os.path.exists('run.log'): os.remove('run.log')
    for d, ds, fs in os.walk('output'):
        for f in fs: os.remove(os.path.join(d, f))


# Build model.

def build():
    model_config.setup()
    model_dir = model_config.directory()
    with open(os.devnull, 'w') as sink:
        need_build = sp.call([scons, '-q', '-C', model_dir],
                             stdout=sink, stderr=sink)
    if not need_build:
        message('Build is up to date')
        shutil.copy(os.path.join(model_dir, 'genie.exe'),
                    os.path.join(os.curdir, exe_name))
        return True
    message('BUILDING: ' + model_config.display_model_version)
    with open(os.path.join(model_dir, 'build.log'), 'w') as logfp:
        rev = 'rev=' + model_config.display_model_version
        cmd = [scons, '-C', model_dir, rev]
        cmd.append('progress=' + ('1' if progress else '0'))
        result = sp.call(cmd, stdout=logfp, stderr=sp.STDOUT)
    shutil.copy(os.path.join(model_dir, 'build.log'), os.curdir)
    if result == 0:
        message('Build OK')
        shutil.copy(os.path.join(model_dir, 'genie.exe'),
                    os.path.join(os.curdir, exe_name))
        return True
    else:
        message('BUILD FAILED: see build.log for details')
        return False


# Run model.

def run():
    message('RUNNING: ' + model_config.display_model_version)
    with open('run.log', 'w') as logfp:
        genie = sp.Popen(os.path.join('.', exe_name),
                         stdout=sp.PIPE, stderr=sp.STDOUT)
        while True:
            line = genie.stdout.readline()
            if not line: break
            logfp.write(line)
            print(line, end='')
        result = genie.wait()
        if result == 0:
            message('Run OK!')
        else:
            message('RUN FAILED: see run.log for details')


# Actions: platform management, clean, build or run.

pfile = os.path.join('config', 'platform-name')
if   action == 'clear-platform':
    if os.path.exists(pfile): os.remove(pfile)
elif action == 'set-platform':
    with open(pfile, 'w') as ofp: print(platform, file=ofp)
elif action == 'clean':
    clean(False)
elif action == 'cleaner':
    clean(True)
elif action == 'build':
    build()
elif action == 'run':
    if build(): run()
    else:       message('RUN CANCELLED')
else:
    usage()