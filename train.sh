#!/bin/sh

rm -rf /tmp/train-calamari-gt4histocr.*
TMPDIR=`mktemp -d /tmp/train-calamari-gt4histocr.XXXXX`

echo "Unpacking dataset tar files to $TMPDIR"
(cd data; git annex get GT4HistOCR/corpus/*.tar.bz2)
for tar in data/GT4HistOCR/corpus/*.tar.bz2; do
  tar xf $tar -C $TMPDIR
done
echo "Removing dta19/1882-keller_sinngedicht/04970.nrm.png (Broken PNG)"
rm -f $TMPDIR/dta19/1882-keller_sinngedicht/04970.*

export PYTHONUNBUFFERED=1  # For python + tee

outdir=data/calamari-models/GT4HistOCR
mkdir -p $outdir

calamari-cross-fold-train \
  --files \
  "$TMPDIR/*/*/*.png" \
  --best_models_dir $outdir \
  --early_stopping_frequency=0.25 \
  --early_stopping_nbest=5 \
  --batch_size=128 \
  --n_folds=5 \
  --max_parallel_models=1 \
  --display=0.01 \
  2>&1 | tee $outdir/train.`date -Iminutes`.log
