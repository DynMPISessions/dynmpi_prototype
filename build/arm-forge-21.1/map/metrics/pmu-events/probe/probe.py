#!/usr/bin/env python
"""
Script for gathering information about the current node. Run

    ./script --help

for help with running the script.
"""
from datetime import datetime
from socket import getfqdn  # get fully quantified domain name
from socket import gethostname
from subprocess import check_output

import argparse
import json
import os
import re
import sys


DIR_PATH = os.path.realpath(os.path.dirname(__file__))
CHECK_PERF_METRICS_PATH = (
    '{}/../../../../libexec/check-perf-metrics'.format(DIR_PATH)
)

def get_kernel_provided_perf_events():
    """
    Returns a list of dicts describing metrics provided by the linux kernel.
    Each dict is of the form

        {type: <Type>, event: <Event>, description: <Description>}

    where each value is a string. All the types and events are described in
    better detail in the perf_event_open manual.
    """
    events_json_file = "{}/kernel_provided_events.json".format(DIR_PATH)
    with open(events_json_file, "r") as file_handle:
        return json.load(file_handle)


def get_names_of_valid_kernel_provided_perf_events():
    """
    Returns a string containing the names (as used in the perf_event_open
    man page) of all the generalized perf metrics that are supported on
    this machine.
    """
    return agnostic_check_output(
        [CHECK_PERF_METRICS_PATH,
         '--all',
         '--no-headers']
        ).strip()


def get_valid_kernel_provided_perf_events():
    """
    Returns a list of dicts describing metrics provided by the linux kernel
    *and* that are supported on the current machine. Each dict is of the form

        {type: <Type>, event: <Event>, description: <Description>}

    where each value is a string. All the types and events are described in
    better detail in the perf_event_open manual.
    """
    valid_events = get_names_of_valid_kernel_provided_perf_events()
    filtered_events = []
    for event in get_kernel_provided_perf_events():
        # Only keep events that are supported on this machine
        if event['PerfEventName'] in valid_events:
            filtered_events.append(event)
    return filtered_events


def agnostic_check_output(command):
    """
    Ensure check_output returns a string rather than a byte array in python2
    and python3.
    """
    output = check_output(command)
    if isinstance(output, str):
        return output

    return output.decode()


def collect_lscpu_dict():

    """
    Runs lscpu and converts the output to a dict. The dict on an aarch64 will
    look similar to

        {
            "Architecture": "aarch64",
            "BogoMIPS": "200.00",
            "Byte Order": "Little Endian",
            "CPU(s)": "96",
            "Core(s) per socket": "48",
            "Flags": "fp asimd evtstrm aes pmull sha1 sha2 crc32 cpuid",
            "L1d cache": "unknown size",
            "L1i cache": "unknown size",
            "L2 cache": "unknown size",
            "Model": "0",
            "NUMA node(s)": "2",
            "NUMA node0 CPU(s)": "0-47",
            "NUMA node1 CPU(s)": "48-95",
            "On-line CPU(s) list": "0-95",
            "Socket(s)": "2",
            "Thread(s) per core": "1"
        }
    """
    output_array = agnostic_check_output('lscpu').splitlines()

    return {
        key: value.lstrip()
        for (key, value) in [output.split(':', 1) for output in output_array]
    }


def get_linux_version():
    """
    Infers the linux version from uname as a series of 3 integers

        <major>.<minor>.<patch>
    """
    long_version = os.uname()[2]
    match = re.match(r'^\d+\.\d+\.\d+', long_version)
    return match.group()


def get_cpuid():
    """
    Gets the cpuid expected by the perf pmu-events csv files.

    Calls out to get_cpu_family_model
    """
    return agnostic_check_output(
        '{}/../../../../libexec/get_cpu_family_model'.format(DIR_PATH)
    ).strip()


def get_node_info():
    """
    Creates and returns a dictionary with information describing the system on
    which this script was run on.
    """
    uname = os.uname()

    return {
        'Cpu ID': get_cpuid(),
        'Date & Time': str(datetime.now()),
        'PerfEvents': get_valid_kernel_provided_perf_events(),
        'Hostname': getfqdn(),
        'Linux Version': get_linux_version(),
        'Lscpu': collect_lscpu_dict(),
        'Uname': {
            'sysname': uname[0],
            'nodename': uname[1],
            'release': uname[2],
            'version': uname[3],
            'machine': uname[4]
            }
    }

def dump_to_json_file(data, filepath):
    "Print data to filepath as human-readable json"

    directory = os.path.dirname(filepath)
    if not os.path.exists(directory):
        os.makedirs(directory)

    with open(filepath, 'w') as file_handle:
        json.dump(data, file_handle, indent=4, sort_keys=True)


def get_allinea_config_dir():
    "Either return the value of ALLINEA_CONFIG_DIR or $HOME/.allinea"
    return os.getenv('ALLINEA_CONFIG_DIR',
                     '{}/.allinea'.format(os.getenv('HOME')))

def get_config_dir_probe_location():
    """
    Returns the user-specific directory in which to place probe files.
    This will be a subdirectory of get_allinea_config_dir().
    """
    return '{}/map/metrics/pmu-events/known-hosts'.format(get_allinea_config_dir())

def get_filepath_for_option(option):
    """
    Option is one of the following strings

        * cwd: current directory
        * global: In the forge installation diectory
        * user: .allinea or ALLINEA_CONFIG_HOME
    """
    allinea_config_dir = get_config_dir_probe_location()
    filename = '{}_probe.json'.format(gethostname())
    realpath = os.path.realpath
    dirname = os.path.dirname

    return {
        'cwd': './{}'.format(filename),
        'global': realpath('{0}/../known-hosts/{1}'.format(dirname(realpath(__file__)), filename)),
        'user': '{0}/{1}'.format(allinea_config_dir, filename)
    }[option]


def dump_to_json_for_option(data, option):
    """
    Dumps data as a json object to a file specified by option. See
    get_filepath_for_option for the list of accepted options.
    """
    filepath = get_filepath_for_option(option)
    dump_to_json_file(data, filepath)


def get_output_for_option(option):
    """
    Return a report string that reports the location of where the file was
    installed and further installation instructions if install=cwd was
    selected
    """
    filepath = get_filepath_for_option(option)
    config_dir = get_config_dir_probe_location()
    installation_output = (
        'Output file can be found at {0}. To install, please run\n'
        '\n'
        '    mkdir -p {1}\n'
        '    cp {0} {1}/\n'
        ''.format(filepath, config_dir)
    )
    non_installation_output = (
        'Output file can be found at {}'.format(filepath)
    )

    return {
        'cwd': installation_output,
        'global': non_installation_output,
        'user': non_installation_output
    }[option]


def print_installation_instructions(option):
    """
    Return a report string that reports the location of where the file was
    installed and further installation instructions if install=cwd was
    selected
    """
    print(get_output_for_option(option))


def parse_arguments(argv):
    "Parse command line arguments"
    parser = argparse.ArgumentParser(
        description=("Probes the current node and dumps information about the "
                     "hardware and software to a json file.")
    )

    parser.add_argument('--quiet', action='store_true',
                        help="Do not print installation instructions.")
    parser.add_argument('--install',
                        choices=['cwd', 'global', 'user'],
                        default='cwd',
                        help=("The location which the probed information is "
                              "written to file. cwd is the current "
                              "directory, global is relative to this scripts "
                              "location, user is relative to "
                              "ALLINEA_CONFIG_DIR, or ~/.allinea if not set.")
                        )

    return parser.parse_args(argv)


def verify_install():
    "Some basic sanity checks on the environment"
    if not os.path.exists(CHECK_PERF_METRICS_PATH):
        print("check_parf_metrics not found, this platform is not supported")
        sys.exit(1)

    if sys.version_info < (2, 7):
        print("This script requires at least python2.7")
        sys.exit(1)

def verify_perf_event_paranoid():
    "Check that /proc/sys/kernel/perf_event_paranoid will allow collecting Perf metrics"
    with open('/proc/sys/kernel/perf_event_paranoid', 'r') as file:
        paranoid_value = file.readline().rstrip('\n')
        if paranoid_value == "3":
            print("The value of /proc/sys/kernel/perf_event_paranoid must be "
                  "2 or lower to collect Perf metrics. To set this until the "
                  "next reboot run the following command:\n"
                  "\n"
                  "    sudo sysctl -w kernel.perf_event_paranoid=2\n"
                  "\n"
                  "To permanently set the paranoid level, add the following "
                  "line to /etc/sysctl.conf:\n"
                  "\n"
                  "    kernel.perf_event_paranoid=2\n")
            sys.exit(1)

def main(argv=None):
    "Entry point to probe"
    verify_install()
    verify_perf_event_paranoid()
    args = parse_arguments(argv)
    node_info = get_node_info()
    dump_to_json_for_option(node_info, args.install)

    if not args.quiet:
        print_installation_instructions(args.install)
