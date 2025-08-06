#!/bin/bash
output_dir="dataset"
dataset_prefix="hdsner-"
for setting in `ls hdsner-utils/data`
do
    source="hdsner-utils/data/${setting}/ner_medieval_multilingual/FR/"
    if [ ! -d "${source}" ] || [ "${setting}" = "data_raw" ]
    then
        continue
    fi
    if [ "${setting}" = "supervised" ]
    then
        dataset_suffix="-Fully"
    else
        p=`echo "${setting}" | cut -d '-' -f 2`
        dataset_suffix="-Dict${p}"
    fi

    # copy and format datasets
    python3 scripts/format_hdsner_datasets.py \
        --input-dir "${source}" \
        --output-dir "${output_dir}" \
        "--output-prefix=${dataset_prefix}" \
        "--output-suffix=${dataset_suffix}"
done

# execute on all datasets
for dataset in `find ${output_dir} -name "${dataset_prefix}*" | cut -d '_' -f 1 | sort | uniq`
do
    dataset_name="`basename ${dataset}`"
    time \
    sh run_script.sh 0 "${dataset_name}" \
    > "${dataset}_stdout.txt" 2> "${dataset}_stderr.txt"
done
