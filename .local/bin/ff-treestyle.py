#!/usr/bin/env python3

import sys, os
from configparser import ConfigParser

HOME = os.environ['HOME']

def linux_assert():
    assert ('linux' in sys.platform), "This program only runs on Linux systems."

def ff_home_exists(home_dir):
    assert (os.path.exists(f"{home_dir}/.mozilla")), f"""
    .mozilla folder not found in {home_dir}. Is Firefox installed?
    """

def get_ff_profiles(home_dir):
    try:
        with open(f"{home_dir}/.mozilla/firefox/profiles.ini") as file:
            read_data = file.read()
            print(read_data)
    except FileNotFoundError as error:
        print(f"File not found. Error was: {error}")

if __name__ == '__main__':
    try:
        linux_assert()
        ff_home_exists(HOME)
        # get_ff_profiles(HOME)
    except AssertionError as error:
        print(error)
        
