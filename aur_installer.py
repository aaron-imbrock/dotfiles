#!/usr/bin/env python3

# For those of us who must look it up every single time...
# This is a simple program meant to automate the installation of AUR packages.

# The gist of argparse came from reading https://pymotw.com/3/argparse/

import argparse
import subprocess
import sys

# TODO: Would the code be cleaner if 
# parser.add_argument('-a', action='append',
#                     dest='collection',
#                     default=[],
#                     help='Add repeated values to a list')
parser = argparse.ArgumentParser(
    add_help=True,
    formatter_class=argparse.RawTextHelpFormatter,
    description="""Automate the installation of AUR packages.

    ./aur_install.py https://aur.archlinux.org/eagle.git
    """)
parser.add_argument('url', action='append')
parser.add_argument('--version', action='version', version='%(prog)s 1.0')

parsed_input = parser.parse_args()
url = parsed_input.url
url_components = url.split('/')[2:]
repo_folder = url_components[-1].split('.')[0]

def main():
    if url_components[0] != 'aur.archlinux.org':
        print("%s is not an ArchLinux Repo. Exiting..." % url)
        sys.exit(1)
    else:
        # TODO: Git uses exit code of 128 if folder exists and is not empty
        #       Create exception handling this.
        #       Maybe:
        #       git pull ...
        #       "Repo exists. Upgrading..."        
        # TODO: cwd should be taken from an argparse default value instead
        subprocess.run(["git", "clone", url], check=True, cwd="/tmp")
        subprocess.run(["makepkg", "-s","-i"], check=True, cwd=f"/tmp/{repo_folder}")
        sys.exit(0)

if __name__ == "__main__":
    main()