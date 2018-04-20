# Changelog
## **Disclamier:** Have to mostly use asciinema due to my laptop take foerever to do gifs

## 2018-04-20
- Added Evaluation of Interpolation
[![asciicast](https://asciinema.org/a/177322.png)](https://asciinema.org/a/177322)

## 2018-02-23
- Added Resource/Data interpolation from other files

[![asciicast](https://asciinema.org/a/S6x9eVEht2ppT5fMcS9IvLJiz.png)](https://asciinema.org/a/S6x9eVEht2ppT5fMcS9IvLJiz)

## 2018-01-18
- Added version based completion
- Added Bots for auto update for provider(daily check)
- Fix several bugs relating to attribute subcompletion

## 2017-12-06
- Nested Block Completion

[![asciicast](https://asciinema.org/a/151238.png)](https://asciinema.org/a/151238)

## 2017-11-23 
- Terraform Module Registry Name Completion

[![asciicast](https://asciinema.org/a/azFU126p6SCkrOtuNWnSynyR0.png)](https://asciinema.org/a/azFU126p6SCkrOtuNWnSynyR0)

## 2017-11-22 
- Terraform Module Registry support

[![asciicast](https://asciinema.org/a/UMLMCyYmd3sY4uwEhzTKG2L1m.png)](https://asciinema.org/a/UMLMCyYmd3sY4uwEhzTKG2L1m)

## 2017-05-22 
### New Feature
- Deoplete Support

[![asciicast](https://asciinema.org/a/121802.png)](https://asciinema.org/a/121802)

- Open Doc in a browser(need to make sure windows and mac work), key is `<leader>o`

## 2017-05-20
### New Feature
- Lookup Attribute Data
- If you have terraform.tfstate in your folder, then using `<leader>a` can show the data of the attribute

[![asciicast](https://asciinema.org/a/121638.png)](https://asciinema.org/a/121638)

## 2017-05-20
### Improvement
- Plan have color now

![color_plan](./pics/color_plan.png)

## 2017-05-18
### New Feature
- Run(`<leader>rr`) and Fold Output

[![asciicast](https://asciinema.org/a/121068.png)](https://asciinema.org/a/121068)

- Run as Async Job

[![asciicast](https://asciinema.org/a/121097.png)](https://asciinema.org/a/121097)

### Improvement
- Module completion for subpath of github/bitbucket

## 2017-05-15
### Remove
- Version based completion is remove due to load time, storage, and the docs are inconsistent
### Improvement
- All data and resources arguments have type with it now
- Block completion is complete , thanks to data from [VladRassokhin](https://github.com/VladRassokhin/)

## 2017-05-14
### New Features
- Basic Block Completion
- Functions Completion
- Added Basic Resource Arguments
### Improvement
- Much better attribute completion

[![asciicast](https://asciinema.org/a/120505.png)](https://asciinema.org/a/120505)

## 2017-05-09(5 am)
### New Feature
- Support for Neomake
## 2017-05-09(3 am)

[![asciicast](https://asciinema.org/a/119739.png)](https://asciinema.org/a/119739)

### New Feature
- Show docs for data/resource attribute
## 2017-05-08(10 pm)
### New Feature
- Module Attribute completion(Github online, and offline
### Improvement
- Fix data interpolation from ${[name]} to ${data.[name]}
- Fix module relative lookup(now it will look in the same folder as the editing tf file)
- Fine tune some provider scrapping, where name include in the resource link(like opc)

## 2017-05-08(6 am)
### New Feature
- Moudle GitHub Argument Completion(Working on offline and attribute completion
    for module)

[![asciicast](https://asciinema.org/a/119591.png)](https://asciinema.org/a/119591)

## 2017-05-08(4 am)
### New Feature
- Show Docs

[![asciicast](https://asciinema.org/a/119587.png)](https://asciinema.org/a/119587)

## 2017-05-06(3 pm)
### New Feature
- Version based Completion

## 2017-05-06(5 am)
### New Feature
- Jump Reference for Resource/Data

[![asciicast](https://asciinema.org/a/119371.png)](https://asciinema.org/a/119371)

## 2017-05-06(2 am)
### New Feature
- Data Completion

[![asciicast](https://asciinema.org/a/119362.png)](https://asciinema.org/a/119362)

## 2017-05-04(3 am)
### Improvement
- Added Tagbar config for Terraform
## 2017-05-03(Night)
### Improvement for Repo
- Added Travis and added basic test using vader.vim

## 2017-05-03(Afternoon)
### Improvement
- Now resource completion have provider as well

[![asciicast](https://asciinema.org/a/cavvbxhzvtbvqnofskolgugkr.png)](https://asciinema.org/a/cavvbxhzvtbvqnofskolgugkr)

### New Feature
- New custom linter to filter `terraform validate` and `terraform plan` using to provide line number and error message for syntastic
    - introduce `g:syntastic_terraform_tf_filter` variable in vimrc for enabling terraform plan , default is 0

[![asciicast](https://asciinema.org/a/118915.png)](https://asciinema.org/a/118915)

## 2017-05-03(Morning 2-4 AM)
### Improvement
- Interpolation of parameter completion is much better now

    [![asciicast](https://asciinema.org/a/aezk645gig5i9fw8z4ampaybq.png)](https://asciinema.org/a/aezk645gig5i9fw8z4ampaybq)
### New Feature
- There is variable completion now, it will get the root folder level variables.tf
- NOTE: There is still to be fix dealing with function like ${file()} etc

    [![asciicast](https://asciinema.org/a/dm4h6mwiv6n83pcebd15tvljl.png)](https://asciinema.org/a/dm4h6mwiv6n83pcebd15tvljl)
