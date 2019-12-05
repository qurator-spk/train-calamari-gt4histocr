#!/bin/sh
# Upload GT4HistOCR Calamari model

set -e

self=`realpath $0`
self_dir=`dirname "$self"`




cd $self_dir
DATA_SUBDIR=data
get_from_annex() {
  annex_get 'calamari-models/GT4HistOCR*'
}
. $self_dir/qurator_data_lib.sh
handle_data --no-download





# Pack it up
(
  cd $DATA_SUBDIR/calamari-models/GT4HistOCR

  if [ `ls train*log* | wc -l` != '1' ]; then
    echo "More than one training log, clean up?"; exit 1
  fi
  LOG_SRC=`ls train*log*`
  LOG="$self_dir/$LOG_SRC.xz"
  xz --verbose --compress --stdout "$LOG_SRC" >"$LOG"

  TAR="$self_dir/model.tar.xz"
  tar --dereference --exclude='train*log*' -cav -f "$TAR" ./
)
