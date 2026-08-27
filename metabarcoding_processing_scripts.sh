####metabarcoding pipeline

###needed: pear, usearch, blastn (with local database), blast2taxonomy (see GitHub repository for installation)

####Merge Forward und Reverse Sequences

ls *fastq.gz | awk '{print "pear -v 50 -q 20 -j 15 -f "$0" -r "$0" -o "$0}' | grep _R2_ | sed 's/_R2_/_R1_/1' | sed -r 's/_S[0-9]{1,3}_L001_R2_001.fastq.gz//2' > pear.sh  

chmod u+x pear.sh  # make script executable

./pear.sh # run script

####Merge Forward und Reverse Sequences

ls *assembled.fastq | awk '{print "usearch -fastq_filter "$0" -fastaout "$0" -relabel OTU -fastq_maxee 1"}' | sed 's/assembled.fastq/fasta/2' > fastq.sh

chmod u+x fastq.sh	# make script executable (see above)

./fastq.sh		# run script

###Trimming Primers and Length Filtering

###Remove Newlines

for file in *fasta; do awk '/^>/ { print (NR==1 ? "" : RS) $0; next } { printf "%s", $0 } END { printf RS }' $file > $(basename $file .fasta)"_nonl.fasta" ; done 

###Get your sequences' lengths

grep -E ^.GC.TT.CC.CG.ATAAA.AA.ATAAG.*GG.AC.GG.TGAAC.GT.TA.CC.C$ *_nonl.fasta | sed -r 's/:[A-Z]{27}/\t/' | sed -r 's/[A-Z]{25}$//' | awk '{print length($2)}' | sort | uniq -c

###Trim off primers

grep -E ^.GC.TT.CC.CG.ATAAA.AA.ATAAG.*GG.AC.GG.TGAAC.GT.TA.CC.C$ *_nonl.fasta | sed -r 's/:[A-Z]{27}/\t/' | sed -r 's/[A-Z]{25}$//' | awk 'length($2)==64{print ">"$1"\n"$2}' > Algen.fas

###Dereplicating

usearch -fastx_uniques Algen.fas -fastaout Algen.derep -sizeout

###clustering

usearch -cluster_otus Algen.derep -otus Algen.OTU.fas -relabel OTU -minsize 8	

###editing files for avoiding issues with Bash and USEARCH

sed -i 's/Zotu/OTU/g' Algen.zOTU.fas	

sed -i '/^>/s/-/_/g' Algen.fas	

###OTU mapping

usearch -otutab Algen.fas -otus Algen.OTU.fas -otutabout Algen.Tab.txt

###BLAST: here we used the nt downloaded locally on a HPC

blastn -db nt -query Algen.zOTU.fas  -num_threads 32 -max_target_seqs 10 -word_size 19  -out Algen.out  -outfmt '6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore staxids'

###blast2taxonomy for annotated table

blast2taxonomy_v1.4.2.py -i Algen.out -o Algen.taxids -s -t 32

