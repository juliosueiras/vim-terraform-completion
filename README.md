# Vim Terraform Completion - [Demos](./DEMO.md)

[![Join the chat at https://gitter.im/juliosueiras/vim-terraform-completion](https://badges.gitter.im/juliosueiras/vim-terraform-completion.svg)](https://gitter.im/juliosueiras/vim-terraform-completion?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)


**A very early prototype**

## Installation

**Require `+ruby` or `+ruby/dyn` for vim**

### NeoBundle
`NeoBundle 'juliosueiras/vim-terraform-completion'`

### Vim-Plug
`Plug 'juliosueiras/vim-terraform-completion'`



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
