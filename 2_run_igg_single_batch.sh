#!/bin/bash

num_shards=102
set -euo pipefail

for shard in $(seq 52 102); do
	sbatch ./igg_single_batch.sh $shard
	sleep 1s
done

