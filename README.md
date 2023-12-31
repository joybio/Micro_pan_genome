# pan_roary

## Birefing introduction

roary is a Rapid large-scale prokaryote pan genome analysis program. roary_split run roary for MAGs within the identical species.

##  Installation

#Prerequisites
Before using this script, ensure that you have the following dependencies installed:

python >=3.9
pandas
prokka
roary

Example: 
Basic usage:
  ```bash
  python pan_roary.py -i species.txt --tax tax.bac120.summary.tsv -t 10 -p roary/prokka/ -o number.xls
  ```

#Output

The script will produce a collection of directories, each named after a species. Within each directory, a symbolic link will be established for the Prokka GFF file, and a text file will be created to document the MAGs present in that particular species. Additionally, an output file will be generated to log the count of each species.


The input files consist of two documents: species.txt and tax.bac120.summary.tsv (EasyMetagenome).
In species.txt, the quantity of each assembled MAG is documented. Meanwhile, tax.bac120.summary.tsv provides information on the species to which each MAG belongs.

# Options
  ```bash
  python pan_roary.py --help
  ```
  ```bash
usage: pan_roary.py [-h] -i <file> --tax <file> -t <file> --thread <file>
                      --donotalign <file> -p <file> -o <file> [--version]

pan_roary results

optional arguments:
  -h, --help            show this help message and exit
  -i <file>, --input <file>
                        Species file: species.txt.
  --tax <file>          Tax file: tax.bac120.summary.tsv.
  -t <file>, --threshold <file>
                        Number of genome, Default: 10.
  --thread <file>       Number of threads, Default: 10.
  --donotalign <file>   Do-not-align genes (roary), Default: T.
  -p <file>, --prokka <file>
                        Prokka directory [ABS]. this directory is usde to link
                        gff file into sub-directory and process roary.
  -o <file>, --out <file>
                        Output file.
  --version             Display version
  ```

# Contributing
If you'd like to contribute to this project, feel free to fork the repository and submit a pull request with your changes. We welcome any improvements or bug fixes.

# License
This project is licensed under the MIT License - see the LICENSE file for details.

# Contact
If you have any questions or encounter issues with the script, please contact joybio at [1806389316@pku.edu.cn].
