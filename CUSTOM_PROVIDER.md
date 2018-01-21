# Completion for Custom Provider

Due to unstable and unpredicted nature of unofficial providers, the result can be vary

1. clone the desired provider repo to GOPATH
2. copy generate-schema folder(can be located at the plugin's repo) with the template generate-schema.go(credit goes to [intellij-hcl](https://github.com/VladRassokhin/intellij-hcl) )
3. replace `<url-to-provider>` with go path to the provider, check main.go of the provider, if you are unsure, replace `<provider>` with provider name, `<version>` with the version that the provider currently on, and lastly `<plugin-path>` is the full path to plugin
4. go to vim-terraform-completion and run `ruby version_dissect.rb` , check `provider_json/<provider>` to ensure the completion is generated
5. add `<provider>=<version>` to the repo's .tfcompleterc or project's .tfcompleterc

## Video Instruction:

[![asciicast](https://asciinema.org/a/WlAz2luy76HLNrtVKHki6XCd8.png)](https://asciinema.org/a/WlAz2luy76HLNrtVKHki6XCd8)
