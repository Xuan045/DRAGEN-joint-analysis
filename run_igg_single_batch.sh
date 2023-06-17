#!/bin/bash

num_shards=102
set -euo pipefail

for shard in $(seq 1 102); do
	sbatch ./igg_single_batch.sh $shard
done

