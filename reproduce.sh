#!/bin/bash -e

export LANG=en_US.utf8

cat <<EOF
This script reproduces the results.
EOF

echo
set -x

make clean
make data

mv -fv data/edges.txt data/edges.count.txt
ln -sfTv edges.count.txt data/edges.txt
make impl
mkdir -p eval/count
mv -fv impl/*-pairs.txt impl/*-synsets.tsv eval/count

make -C impl clean
sed -re 's/[[:digit:]]+$/1/g' data/edges.count.txt > data/edges.ones.txt
ln -sfTv edges.ones.txt data/edges.txt
make impl
mkdir -p eval/ones
mv -fv impl/*-pairs.txt impl/*-synsets.tsv eval/ones

make -C impl clean
./similarities.py ../projlearn/all.norm-sz500-w10-cb0-it3-min5.w2v <data/edges.count.txt >data/edges.w2v.txt
ln -sfTv edges.w2v.txt data/edges.txt
make impl
mkdir -p eval/w2v
mv -fv impl/*-pairs.txt impl/*-synsets.tsv eval/w2v

eval/pairwise.py --gold=data/ruthes-pairs.txt data/yarn-pairs.txt eval/**/*-pairs.txt | tee pairwise-ruthes.tsv | column -t
eval/pairwise.py --gold=data/yarn-pairs.txt data/ruthes-pairs.txt eval/**/*-pairs.txt | tee pairwise-yarn.tsv | column -t

eval/cluster.sh data/ruthes-synsets.tsv data/yarn-synsets.tsv eval/**/*-synsets.tsv | tee cluster-ruthes.tsv | column -t
eval/cluster.sh data/yarn-synsets.tsv data/ruthes-synsets.tsv eval/**/*-synsets.tsv | tee cluster-yarn.tsv | column -t

join --header -j 1 -t $'\t' >results-ruthes.tsv \
  <(sed -re 's/-pairs.txt\t/\t/g' pairwise-ruthes.tsv) \
  <(sed -re 's/-synsets.tsv\t/\t/g' cluster-ruthes.tsv)

join --header -j 1 -t $'\t' >results-yarn.tsv \
  <(sed -re 's/-pairs.txt\t/\t/g' pairwise-yarn.tsv) \
  <(sed -re 's/-synsets.tsv\t/\t/g' cluster-yarn.tsv)
