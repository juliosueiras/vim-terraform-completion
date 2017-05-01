# Vim Terraform Completion with Linter - [Demos](./DEMO.md)

[![Join the chat at https://gitter.im/juliosueiras/vim-terraform-completion](https://badges.gitter.im/juliosueiras/vim-terraform-completion.svg)](https://gitter.im/juliosueiras/vim-terraform-completion?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)


**A very early prototype**

## Dependencies

- [vim-terraform](https://github.com/hashivim/vim-terraform)
- [vim-syntastic](https://github.com/vim-syntastic/syntastic)

## Installation

**Require `+ruby` or `+ruby/dyn` for vim**

### NeoBundle
```vim
NeoBundle 'hashivim/vim-terraform'
NeoBundle 'vim-syntastic/syntastic'
NeoBundle 'juliosueiras/vim-terraform-completion'
```

### Vim-Plug
```vim
Plug 'hashivim/vim-terraform'
Plug 'vim-syntastic/syntastic'
Plug 'juliosueiras/vim-terraform-completion'
```

## General Todo
- [ ] Test from zero to useful setup using Docker
- [ ] Provide config and example
- [x] Integrate Basic `terraform validate` and `tflint` into Synstatic
**NOTE:** enabling deep check for tflint can be a bit slow

[Demo of the linter](https://asciinema.org/a/118441)

## Todo for Terraform completion
- [ ] Provider
- [x] Resource
- [x] Parameter
- [x] Adding Info to Argument and Attribute(Type not including ,since Info
    already indicate it)
- [ ] Variable
- [ ] Cleaner code
- [x] local/offline
- [ ] Add completion tags, ingress, and other subblock
- [ ] Further seperate data source from resource

## Todo for HCL
- [ ] Add Completion for hcl
- [ ] Completion for Sublock
## Todo for Improvement
- [ ] Add Travis-CI for testing, and ensuring the completion is outputing the right completion
