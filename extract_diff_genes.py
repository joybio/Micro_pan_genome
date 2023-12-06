#!/bin/python
__date__ = "2023-11-30"
__author__ = "Junbo Yang"
__email__ = "yang_junbo_hi@126.com"
__license__ = "MIT"

"""
The MIT License (MIT)

Copyright (c) 2022 Junbo Yang <yang_junbo_hi@126.com> <1806389316@pku.edu.cn>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
"""

import argparse
import sys
import os
import time
from collections import defaultdict
import pandas as pd

def parseArg():
    parser = argparse.ArgumentParser(description="Roary results")
    parser.add_argument("-i", "--input", type=str, required=True,
                        help="Input file: gene_presence_absence.Rtab.", metavar="<file>")
    parser.add_argument("-f", "--fa", type=str, required=True,
                        help="Input file2: pan_genome_reference.fa.", metavar="<file>")
    parser.add_argument("-o", "--out", type=str, required=True,
                        help="Output file1: diff_gene_presence_absence.Rtab.", metavar="<file>")
    parser.add_argument("--out2", type=str, required=True,
                        help="Output file1: diff_pan_genome_reference.fa", metavar="<file>")
    parser.add_argument("--version", action="version", version=get_version(),
                        help='Display version')
    return parser.parse_args()


def get_version():
    return "0.0.1"


def filter(Input, Out):
    diff_gene_set = set()
    with open(Input,"r") as f:
        with open(Out, "w") as o:
            for i in f:
                if i.startswith("Gene\t"):
                    o.write(i)
                else:
                    line = i
                    presence = i.strip().split("\t")
                    if "0" in presence:
                        o.write(line)
                        diff_gene_set.add(presence[0])
    return diff_gene_set

def sequence_extract(Input, diff_gene_set, Out):
    with open(Input, "r") as f:
        seq_dict = defaultdict(str)
        for i in f:
            if i.startswith(">"):
                Id = i.strip().split(" ")
                # print(Id[1])
                seq_dict[Id[1]] += i.replace(" ","_")
            else:
                seq_dict[Id[1]] += i.strip()
    # print(seq_dict)
    with open(Out, "w") as o:
        for gene in diff_gene_set:
            o.write(seq_dict[gene] + "\n")




def main():
    args = parseArg()
    diff_gene_set = filter(args.input, args.out)
    sequence_extract(args.fa, diff_gene_set, args.out2)

if __name__ == "__main__":
    e1 = time.time()
    main()
    e2 = time.time()
    print("INFO {} Total times: {}".format(time.strftime("%Y-%m-%d %H:%M:%S", time.localtime(time.time())),
                                           round(float(e2 - e1), 2)))
