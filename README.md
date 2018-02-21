# wes_1958_explore_v2
A shiny app that opens filtered 1958 birth cohort data on a web browser for exploring

Can be accessed with the following link:
(https://medgen.shinyapps.io/wes_1958_explore_v2/)

Provides access to a filtered 1958 birth cohort dataset containing only Loss of function, inframe indels, and predicted deleterious and damaging missense variants (by SIFT and PolyPhen respectively).

# Additional filters
Allows for additional filtering on predicted variant consequence:
## Variant impact:
### Protein affecting (default)
- Loss of function
- Inframe indels
- predicted deleterious and damaging missense variants (by SIFT and PolyPhen respectively)

### Loss of function
- Stop gained
- Stop lost
- Start lost
- Frameshift variant
- Splice donor and splice acceptor variants

## Variant allele frequency
Allows for additional filtering on variant rarity:
### All (default)
### < 0.05
Includes all variants with an allele frequency of < 0.05 within the entire ExAC non-TCGA set based on the AF column
### < 0.01
Includes all variants with an allele frequency of < 0.01 within the entire ExAC non-TCGA set based on the AF column

## Gene
Allows the input of incomplete strings and will return all genes within the data that contain that string.

# Data output
Large table by default contains all protein affecting variants and is updated with filters. Hitting the download button downloads all data that match filters.

# Summary Metrics
Summary metrics are generated after a gene name is input into the set. Counts of occurences (sum of ACs) are summarised for different impact and AF variants. If searched gene matches several genes then all genes will be summarised.
