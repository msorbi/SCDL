#!/bin/bash

(
# set attributes
dataset_prefix="hdsner-"

datasets="`find dataset -name "${dataset_prefix}*" | cut -d '_' -f 1 | sort | uniq`"

# move to directory and activate evaluation environment
cd hdsner-utils/
conda activate hdsner

# execute on all datasets
for split in dev test
do
    for dataset in ${datasets}
    do
        # if [ -d "../${dataset}" ]
        # then
            dataset_name="`basename "${dataset}"`"
            pred_file="../ptms/${dataset_name}/${split}_predictions.txt"
            output_file="../${dataset}_pred_${split}.json"
            buf="`mktemp`"
            python3 ../scripts/pred2iob.py --input "${pred_file}" --output "${buf}"
            python3 src/eval.py \
                --true <( cut "${buf}" -d ' ' -f 1,2 ) \
                --pred <( cut "${buf}" -d ' ' -f 1,3 ) \
                --output "$output_file" \
                --n 1 \
                --field-delimiter ' ' \
            > /dev/null
            rm "${buf}"
            echo "$output_file" # this is going to python below
        # fi
    done | python3 src/eval_summary.py --output "../dataset/hdsner_report_${split}.json" --dataset-pos=-1
done

# deactivate environment and return to project directory
conda deactivate
cd ..

)
