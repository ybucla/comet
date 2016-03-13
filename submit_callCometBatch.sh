#!/bin/bash
# getfasta
echo $SGE_TASK_ID
#./run $SGE_TASK_ID GM18486.rna
./callCometBatch.pl $SGE_TASK_ID
