#!/usr/bin/env python3
"""
Upload a file to the DPT-RP1
"""
import re
import os
import unicodedata
from dptrp1.dptrp1 import DigitalPaper

# IP_ADDR = '[fe80::44f:46ff:fe5d:3769%enp2s0u2]'
IP_ADDR = "192.168.8.197"
IP_ADDR = "digitalpaper.local"


def connect(address):
    """
    Loads the key and client ID to authenticate with the DPT-RP1
    """
    with open(os.environ("HOME") + "/.dpapp/deviceid.dat", "r") as f:
        client_id = f.readline().strip()

    with open(os.environ("HOME") + "/.dpapp/privatekey.dat", "r") as f:
        key = f.read()

    dpt = DigitalPaper(address)
    dpt.authenticate(client_id, key)

    return dpt


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser()
    parser.add_argument("--path", help="File to be uploaded")
    args = parser.parse_args()

    file_path = args.path
    # Get only the file name
    file_name = os.path.basename(file_path)
    remote_path = "Document/Printed"
    remote_file = remote_path + "/" + file_name
    print(remote_file)

    #
    try:
        dpt = connect(IP_ADDR)
        #  dpt.new_folder(remote_path)
        #  print(dpt.list_documents())
        with open(file_path, "rb") as fh:
            dpt.upload(fh, remote_file)

    except OSError:
        print(
            "Unable to reach device, verify it is connected to the same network segment."
        )
        exit(1)
