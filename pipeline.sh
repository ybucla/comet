# parse in fastq files, format: rep1_1.fa,rep2_1.fa rep1_2.fa,rep2_2.fa
alias STAR='/u/home/f/frankwoe/nobackup/programs/STAR/STAR-STAR_2.4.2a/bin/Linux_x86_64/STAR'
fastq_files=$@
# run STAR ( -l h_data=16G -pe shared 4 )
#./star --genomeDir /u/home/f/frankwoe/nobackup/hg19/star_idx --sjdbGTFfile /u/home/f/frankwoe/nobackup/hg19/hg19_refseq.gtf  --readFilesIn $fastq_files --runThreadN 8 --outFileNamePrefix ./star_output/
# translated novel junctions into proteins
python /u/home/f/frankwoe/scratch/Proteotranscriptomics/LM_Smith_RNA/translateJunc-star.py -o Junctions_RefSeq_prot.fa -l 66 --min-junc-reads=6 ./star_output
