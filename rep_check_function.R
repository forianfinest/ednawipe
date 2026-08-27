###this works with an OTU table

###x: first replicate (in our case we had a big OTU table with all the replicates as columns, e.g. otu_arthropod_noannotation$sample1rep1)

###y: second replicate (e.g., otutab$sample1rep2)

####it works like: rep_check(sample1rep1, sample1rep2)

###used libraries: tidyverse, ggpmisc, ggpubr  uploaded them like: library(tidyverse), library(ggpmisc) and library(ggpubr). Of course install them first

function (x, y)  {
    otu_arthropod_noannotation %>% ###this was the name of our OTU table
        ggplot(aes({{x}}, {{y}}))+
        geom_point() +
        geom_smooth(method = "lm", se = FALSE) +
        stat_cor(method = "pearson", label.x = 0, label.y = 0) +
        theme_bw()
}
