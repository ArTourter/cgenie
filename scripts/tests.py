#!/usr/bin/env python2

from __future__ import print_function
import os, os.path, sys, errno, shutil
import optparse
import subprocess as sp
import datetime as dt

import utils as U
import config_utils as C


# GENIE configuration

if not U.read_cgenie_config():
    sys.exit("GENIE not set up: run the setup.py script!")
testbase = os.path.join(U.cgenie_test, 'tests')
scons = os.path.join(U.cgenie_root, 'scripts', 'scons', 'scons.py')
nccompare = os.path.join(U.cgenie_root, 'build', 'nccompare.exe')


# List all existing tests.

def list():
    for d, ds, fs in os.walk(testbase):
        if os.path.exists(os.path.join(d, 'test_info')):
            print(os.path.relpath(d, testbase))


# Add a test.

def add_test(test_job, test_name):
    def has_job_output(jdir):
        for d, ds, fs in os.walk(os.path.join(jdir, 'output')):
            if fs != []: return True
        return False
    job_dir = os.path.join(U.cgenie_jobs, test_job)
    if not has_job_output(job_dir):
        sys.exit('Need to run job "' + test_job +
                 '" before adding it as a test')
    test_dir = os.path.join(U.cgenie_test, 'tests', test_name)
    if not os.path.exists(job_dir):
        sys.exit('Job "' + test_job + '" does not exist')
    print('job_dir: ', job_dir)
    print('test_dir: ', test_dir)
    if os.path.exists(test_dir): sys.exit('Test already exists!')
    os.makedirs(test_dir)
    shutil.copy(os.path.join(job_dir, 'config', 'config'),
                os.path.join(test_dir, 'test_info'))
    for c in ['full_config', 'base_config', 'user_config']:
        if os.path.exists(os.path.join(job_dir, 'config', c)):
            shutil.copy(os.path.join(job_dir, 'config', c), test_dir)
    shutil.copytree(os.path.join(job_dir, 'output'),
                    os.path.join(test_dir, 'knowngood'))


# Run tests.

def ensure_nccompare():
    if os.path.exists(nccompare): return
    cmd = [scons, '-C', U.cgenie_root, os.path.join('build', 'nccompare.exe')]
    with open(os.devnull, 'w') as sink:
        status = sp.call(cmd, stdout=sink, stderr=sink)
    if status != 0:
        sys.exit('Couldn not build nccompare.exe program')

def run_tests(tests):
    ensure_nccompare()
    label = dt.datetime.today().strftime('%Y%m%d-%H%M%S')
    dir_name = os.path.join(U.cgenie_jobs, 'test-' + label)
    print('Test output in ' + dir_name + '\n')
    os.makedirs(dir_name)
    summary = { }
    with open(os.path.join(dir_name, 'test.log'), 'w') as logfp:
        for t in tests:
            os.chdir(U.cgenie_root)
            print('Running test "' + t + '"')
            print('Running test "' + t + '"', file=logfp)

            test_dir = os.path.join(U.cgenie_test, 'tests', t)
            cmd = [os.path.join(os.curdir, 'new-job')]

            config = { }
            with open(os.path.join(test_dir, 'test_info')) as fp:
                for line in fp:
                    k, v = line.strip().split(':')
                    config[k.strip()] = v.strip()
            have_full = os.path.exists(os.path.join(test_dir, 'full_config'))
            have_base = os.path.exists(os.path.join(test_dir, 'base_config'))
            have_user = os.path.exists(os.path.join(test_dir, 'user_config'))

            if have_full:
                cmd.append('-c')
                cmd.append(os.path.join(test_dir, 'full_config'))
            elif have_base and have_user:
                cmd.append('-b')
                cmd.append(os.path.join(test_dir, 'base_config'))
                cmd.append('-u')
                cmd.append(os.path.join(test_dir, 'user_config'))
            else:
                sys.exit('Test "' + t + '" configured incorrectly!')
            cmd.append('-j')
            cmd.append(dir_name)
            if 't100' in config and config['t100'] == 'True':
                cmd.append('--t100')
            cmd.append(t)
            cmd.append(config['run_length'])

            print('  Configuring job...')
            print('  Configuring job...', file=logfp)
            logfp.flush()
            if sp.check_call(cmd, stdout=logfp, stderr=logfp) != 0:
                sys.exit('Failed to configure test job')

            os.chdir(os.path.join(dir_name, t))
            print('  Running job...')
            print('  Running job...', file=logfp)
            logfp.flush()
            cmd = [os.path.join(os.curdir, 'go'), 'run', '--no-progress']
            if sp.check_call(cmd, stdout=logfp, stderr=logfp) != 0:
                sys.exit('Failed to run test job')

            print('  Checking results...')
            print('  Checking results...', file=logfp)
            logfp.flush()
            kg = os.path.join(test_dir, 'knowngood')
            passed = True
            for d, ds, fs in os.walk(kg):
                for f in fs:
                    fullf = os.path.join(d, f)
                    relname = os.path.relpath(fullf, kg)
                    print('    ' + relname)
                    print('    ' + relname, file=logfp)
                    testf = os.path.join(dir_name, t, 'output', relname)
                    cmd = [nccompare, '-v', '-a', '6.0E-15', '-r', '35']
                    cmd.append(fullf)
                    cmd.append(testf)
                    if sp.check_call(cmd, stdout=logfp, stderr=logfp):
                        passed = False
            summary[t] = passed
    fmtlen = max(map(len, summary.keys())) + 3
    print('\nSUMMARY:\n')
    with open(os.path.join(dir_name, 'summary.txt'), 'w') as sumfp:
        for t, r in summary.iteritems():
            print(t.ljust(fmtlen) + 'OK' if r else 'FAILED')
            print(t.ljust(fmtlen) + 'OK' if r else 'FAILED', file=sumfp)


# Command line arguments.

def usage():
    print("""
Usage: tests <command>

Commands:
  list                List available tests
  run <test-name>...  Build test or group of tests
  add <job>           Add pre-existing job as test
""")
    sys.exit()

if len(sys.argv) < 2: usage()
action = sys.argv[1]
if action == 'list':
    if len(sys.argv) != 2: usage()
    list()
elif action == 'add':
    if len(sys.argv) == 3:
        add_test(sys.argv[2], sys.argv[2])
    elif len(sys.argv) == 4:
        add_test(sys.argv[2], sys.argv[3])
    else: usage()
elif action == 'run':
    if len(sys.argv) < 3: usage()
    run_tests(sys.argv[2:])
else: usage()