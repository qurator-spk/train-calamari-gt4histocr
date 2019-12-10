#!/bin/bash
# Train a GT4HistOCR Calamari model
# (or rather 5 for voted prediction)

set -e

self=`realpath $0`
self_dir=`dirname "$self"`




cd $self_dir
DATA_SUBDIR=data
get_from_annex() {
  annex_get 'GT4HistOCR/corpus/*.tar.bz2'
}
get_from_web() {
  download_to 'https://zenodo.org/record/1344132/files/GT4HistOCR.tar?download=1' 'GT4HistOCR'
}
. $self_dir/qurator_data_lib.sh
handle_data





rm -rf /tmp/train-calamari-gt4histocr.*
TMPDIR=`mktemp -d /tmp/train-calamari-gt4histocr.XXXXX`

echo "Unpacking dataset tar files to $TMPDIR"
for tar in $DATA_SUBDIR/GT4HistOCR/corpus/*.tar.bz2; do
  tar xf $tar -C $TMPDIR
done
echo "Removing dta19/1882-keller_sinngedicht/04970.nrm.png (Broken PNG)"
rm -f $TMPDIR/dta19/1882-keller_sinngedicht/04970.*


# If we're just testing, keep just some files
if [ "$TEST" = 1 ]; then
  num_pngs_wanted=2000
  num_pngs=`find "$TMPDIR" -path "$TMPDIR/*/*/*.png" | wc -l`
  num_pngs_to_delete=$(($num_pngs-$num_pngs_wanted))
  echo "TEST = 1, Reducing dataset from $num_pngs to $num_pngs_wanted PNG files"
  find "$TMPDIR" -path "$TMPDIR/*/*/*.png" | shuf -n $num_pngs_to_delete | xargs rm
fi


export PYTHONUNBUFFERED=1  # For python + tee

outdir=$DATA_SUBDIR/calamari-models/GT4HistOCR
mkdir -p $outdir

export TF_FORCE_GPU_ALLOW_GROWTH=true  # To prevent TF from taking all GPU memory

calamari-cross-fold-train \
  --files \
  "$TMPDIR/*/*/*.png" \
  --best_models_dir $outdir \
  --early_stopping_frequency=0.25 \
  --early_stopping_nbest=5 \
  --batch_size=128 \
  --n_folds=5 \
  --max_parallel_models=3 \
  --display=0.01 \
  2>&1 | tee $outdir/train.`date -Iminutes`.log
