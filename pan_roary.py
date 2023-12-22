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
                        help="Species file: species.txt.", metavar="<file>")
    parser.add_argument("--tax", type=str, required=True,
                        help="Tax file: tax.bac120.summary.tsv.", metavar="<file>")
    parser.add_argument("-c","--cd", type=int, default=99,
                        help="percentage of isolates a gene must be in to be core [99]. "
                             "Note, if you change this param, please rewrite the Rscript to visualisation",
                        metavar="<file>")
    parser.add_argument("-t", "--threshold", type=int, required=True, default=10,
                        help="Number of genome, Default: 10.", metavar="<file>")
    parser.add_argument("--thread", type=int, required=True, default=10,
                        help="Number of threads, Default: 10.", metavar="<file>")
    parser.add_argument("--donotalign", type=str, required=True, default="T",
                        help="Do-not-align genes, Default: T.", metavar="<file>")
    parser.add_argument("-p", "--prokka", type=str, required=True,
                        help="Prokka directory [ABS]. "
                             "this directory is usde to link gff file into sub-directory and process roary.",
                        metavar="<file>")
    parser.add_argument("-o", "--out", type=str, required=True,
                        help="Output file.", metavar="<file>")
    parser.add_argument("--version", action="version", version=get_version(),
                        help='Display version')
    return parser.parse_args()


def get_version():
    return "0.0.1"


def species_filter(Input, threshold):
    # species.txt
    # threshold: cutoff of number
    species_number_dict = {}
    species_set = set()
    with open(Input, "r") as f:
        for i in f:
            # line = i
            i = i.strip().split(" ")
            # print(i)
            number = int(i[0])
            if number >= threshold:
                species_number_dict[i[1] + "_" + i[2]] = i[0]
                species_set.add(i[1] + "_" + i[2])
    return species_number_dict, species_set


def tax(Input, species_set):
    species_dict = defaultdict(list)
    with open(Input, 'r') as f:
        for i in f:
            i = i.split("\t")
            key = i[1].replace(" ", "_").replace("\t", "_")
            if key in species_set:
                species_dict[key].append(i[0])
    return species_dict


def gff_linkage(species_number, species_dict, cd, thread, prokka_dir, align, out):
    number = {}
    gene_df = []
    for i in species_number.keys():
        i_id = i.split("s__")
        number[i] = species_number[i]
        # print(i_id[1])
        species_dir = i_id[1].replace("\t", "_").replace(" ", "_")
        os.system("mkdir {}".format(species_dir))
        txt = species_dir + '/' + species_dir + ".txt"
        with open(txt, "w") as f:
            f.write("\n".join(species_dict[i]) + "\n")
        for j in species_dict[i]:
            os.system("ln -s {}/{}/{}.gff {}/{}.gff".format(prokka_dir, j, j, species_dir, j))
        out_dir = species_dir + "_roary"
        if align == "T":
            os.system("roary -s -p {} -r -f {} -v {}/*.gff".format(thread, out_dir, species_dir))
        else:
            os.system("roary -s -p {} -i 95 -cd {} -r -f {} -e -n -v {}/*.gff".format(thread, cd, out_dir, species_dir))
        summary = out_dir + "/" + "summary_statistics.txt"
        with open(summary, "r") as f:
            number_list = []
            for pan in f:
                pan = pan.strip().split("\t")
                number_list.append(pan[2])
            seq_array = pd.DataFrame(number_list,
                                     index=["Core_genes", "Soft_core_genes", "Shell_genes", "Cloud_genes", "Total_genes"],
                                     columns=[species_dir])
        gene_df.append(seq_array)
    #print(gene_df)
    merge = pd.concat(gene_df, axis=1)
    merge.to_csv('pan.summary.csv')

    with open(out, 'w') as o:
        o.write("Species\tNumber\n")
        for k in number.keys():
            o.write(k.replace("\t", "_") + "\t" + str(number[k]) + "\n")

def main():
    args = parseArg()
    species_number, species_set = species_filter(Input=args.input, threshold=args.threshold)
    species_dict = tax(Input=args.tax, species_set=species_set)
    gff_linkage(species_number=species_number, species_dict=species_dict,cd=args.cd, thread=args.thread,
                prokka_dir=args.prokka, align=args.donotalign, out=args.out)


if __name__ == "__main__":
    e1 = time.time()
    main()
    e2 = time.time()
    print("INFO {} Total times: {}".format(time.strftime("%Y-%m-%d %H:%M:%S", time.localtime(time.time())),
                                           round(float(e2 - e1), 2)))
