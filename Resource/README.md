## Introduction

The document contains all useful resources for lab.  YW also uploaded one copy to dropbox, with more details. Link: https://www.dropbox.com/sh/zcw8mscivj49rdd/AACBhLymPG5CWmUKlX3fh4DKa?dl=0

## Computational Resource

Three major clusters: 

- Armis2: HIPPA-aligned servers, up to 80,000 CPU hours each year under the research computing package provided by UM. See more details: https://hits.medicine.umich.edu/research-education/research-computing-data-storage/research-computing-package

- CSG cluster: host by CSG. Free resources for us. 

- Greatlake: Not HIPPA-aligned servers. You can split the 80,000 CPU hours quota to Armis2 and Greatlake. Right now, it's 80000 in Armis2 and 0 in Greatlake.

Please find more in the figures.

## Storage Resource

Four major storages:

- Turbo (HIPPA): 10 TB of replicated, high performance storage (will be empty after backup),Up to 10TB ARC Turbo high performance storage, replicated at two University of Michigan data centers 

- Temporary folder (HIPPA): 20 TB temporary storage, Three months, for any short-term intermedia files

- Dataden (HIPPA): 100 TB of archive storage (currently used 30T),  Replicated, tape-based archive storage in Data Den

- CSG : currently used 10T, not sure about the limitation of resource.

## How to Usage

- Armis2: apply acount with the link in excel file. Submit the job with qsub command and the queue name is sganesh0.

- Greatlake: same with Armis2

- CSG: apply account with the link in excel files. Submit the job with qsub command.

- Turbo: access with account Armis2, or use Globus, serach endpoint "UMich Arc Sensitive Turbo Volumn Collection", go to directory "/umms-sganesh-secure/"

- Temporary folder: access with acount Armis2 only

- Dataden: Access with Globus only, search endpoint: "umich#flux", go to directory "/nfs/dataden/umms-sganesh/"

- CSG: ssh/scp files