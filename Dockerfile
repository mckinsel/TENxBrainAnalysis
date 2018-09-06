FROM bioconductor/devel_core2:20180828

RUN apt-get update -y \
 && apt-get install -y -qq libpcre3-dev libbz2-dev liblzma-dev

COPY . TENxBrainAnalysis
WORKDIR TENxBrainAnalysis

RUN echo "source(\"https://bioconductor.org/biocLite.R\"); BiocManager::install(ask=FALSE)" | \
  R --no-save

# Just grep for dependencies in the Rmd files, they aren't listed anywhere
# else.
# This is not a best practice...
RUN find . -name "*.Rmd" | \
  xargs grep -Pho "(?<=library\()[\w\.]+(?=\))" | \
  sort -u | \
  xargs -I {} echo "BiocManager::install(\"{}\", ask=FALSE)" | \
  R --no-save

# The README lists the order in which the Rmd are supposed to be run
RUN grep -Po "(?<=\`)\w+\.Rmd(?=\`)" README.md | \
  xargs -I {} echo "rmarkdown::render('{}')" >> cmds.R

CMD ["R", "-f", "cmds.R"]
