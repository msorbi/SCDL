#!/bin/bash
if [ $# -ne 1 ] || ([ "$1" != "supervised" ] && [ "$1" != "distant" ])
then
    echo "usage: $0 (supervised|distant)"
    exit 1
fi
setting="$1"

source="hdsner-utils/data/${setting}/ner_medieval_multilingual/FR/"
output_dir="dataset"
dataset_prefix="hdsner-"
dataset_suffix="-${setting}"

# copy and format datasets
python3 scripts/format_hdsner_datasets.py \
    --input-dir "${source}" \
    --output-dir "${output_dir}" \
    "--output-prefix=${dataset_prefix}" \
    "--output-suffix=${dataset_suffix}"

# execute on all datasets
for dataset in `find ${output_dir} -name "${dataset_prefix}*${dataset_suffix}*" | cut -d '_' -f 1 | sort | uniq`
do
    dataset_name="`basename ${dataset}`"
    time \
    sh run_script.sh 0 "${dataset_name}" \
    > "${dataset}_stdout.txt" 2> "${dataset}_stderr.txt"
done
