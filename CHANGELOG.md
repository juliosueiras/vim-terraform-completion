# Changelog
## **Disclamier:** Have to mostly use asciinema due to my laptop take foerever to do gifs
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
