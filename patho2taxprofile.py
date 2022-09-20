import argparse
import pandas as pd
import os
from os import listdir
from os.path import isfile, join

# Definimos variables para las tres entradas
def bacterial_list(gtdbtk_organism):

    gtdbtk_annotation = {}
    with open(gtdbtk_organism, "r") as fh:
        for line in fh:
            # Columns: user_genome(bin_name), classification(tax_name)
            columns = line.strip().split("\t")
            tax_name = columns[1]
            bin_name = columns[0]
            gtdbtk_annotation[bin_name] = tax_name

    return gtdbtk_annotation


def contigs_to_mags(contigs_table):
    contigs = {}
    with open(contigs_table, "r") as fh:
        for line in fh:
            line_list = line.strip().split(",")
            mag_id = line_list[0]
            contig_id = line_list[1]

            contigs[contig_id] = mag_id

    return contigs


def abundance_list(patho_file, contigs, gtdbtk_annotation):

    df = pd.read_table(patho_file, sep="\t", skiprows=1)
    print("reemplazando contigs con map")
    df['Genome'] = df['Genome'].map(contigs).fillna(df['Genome'])
    df['MAGs_id'] = df['Genome'].map(contigs).fillna(df['Genome'])
    print("reemplazando con gtdbk")
    df['Genome'] = df['Genome'].map(gtdbtk_annotation).fillna(df['Genome'])

    file = patho_file.split("/")[-1] + ".txt"

# Guardamos el datafeame como csv.txt
    df.to_csv(file, index=False)


# Definimos argumentos
def main():
    parser = argparse.ArgumentParser(
        description="")

    parser.add_argument("-g",
                        "--gtdbtk_table",
                        required=True,
                        help=" MAGs annotations from GTDB-tk ")

    parser.add_argument("-c",
                        "--contigs_table",
                        required=True,
                        help=" MAGs and contigs table en each column ")

    parser.add_argument("-p",
                        "--pathoscope_path",
                        required=True,
                        help=" Path with outputh from Pathoscope. Includes contigs and abundances for each sample ")

    #  args
    args = parser.parse_args()
    gtdbtk_table = args.gtdbtk_table
    contigs_table = args.contigs_table
    pathoscope_path = args.pathoscope_path

    # function called
    gtdbtk_annotation = bacterial_list(gtdbtk_table)  # convert mags to tax
    print("entrando a contig")
    contigs = contigs_to_mags(contigs_table)  # convert contig id to mag id
    print("saliendo a contig")
    # we list all files in pathoscope folder
    patho_files = [
        f for f in listdir(pathoscope_path) if isfile(join(pathoscope_path, f))
    ]

    for file in patho_files:
        if file.endswith("tsv"):
            # add tax to patho table
            print(file)
            abundance_list(os.path.join(pathoscope_path, file),
                           contigs,
                           gtdbtk_annotation)


if __name__ == '__main__':
    main()
