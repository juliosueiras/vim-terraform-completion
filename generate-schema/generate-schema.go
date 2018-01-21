// Code from https://github.com/VladRassokhin/intellij-hcl/blob/master/schemas-extractor/template/generate-schema.go

package main

import (
	"github.com/hashicorp/terraform/helper/schema"
	tf "github.com/hashicorp/terraform/terraform"
	"<url-to-provider>"

	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"reflect"
)

// ExportSchema should be called to export the structure
// of the provider.
func Export(p *schema.Provider) *ResourceProviderSchema {
	result := new(ResourceProviderSchema)

	result.Name = "<provider>"
	result.Type = "provider"
	result.Version = "<version>"
	result.Provider = schemaMap(p.Schema).Export()
	result.Resources = make(map[string]SchemaInfo)
	result.DataSources = make(map[string]SchemaInfo)

	for k, r := range p.ResourcesMap {
		result.Resources[k] = ExportResource(r)
	}
	for k, ds := range p.DataSourcesMap {
		result.DataSources[k] = ExportResource(ds)
	}

	return result
}

func ExportResource(r *schema.Resource) SchemaInfo {
	return schemaMap(r.Schema).Export()
}

// schemaMap is a wrapper that adds nice functions on top of schemas.
type schemaMap map[string]*schema.Schema

// Export exports the format of this schema.
func (m schemaMap) Export() SchemaInfo {
	result := make(SchemaInfo)
	for k, v := range m {
		item := export(v)
		result[k] = item
	}
	return result
}

func export(v *schema.Schema) SchemaDefinition {
	item := SchemaDefinition{}

	item.Type = fmt.Sprintf("%s", v.Type)
	item.Optional = v.Optional
	item.Required = v.Required
	item.Description = v.Description
	item.InputDefault = v.InputDefault
	item.Computed = v.Computed
	item.MaxItems = v.MaxItems
	item.MinItems = v.MinItems
	item.PromoteSingle = v.PromoteSingle
	item.ComputedWhen = v.ComputedWhen
	item.ConflictsWith = v.ConflictsWith
	item.Deprecated = v.Deprecated
	item.Removed = v.Removed

	if v.Elem != nil {
		item.Elem = exportValue(v.Elem, fmt.Sprintf("%T", v.Elem))
	}

	// TODO: Find better solution
	if defValue, err := v.DefaultValue(); err == nil && defValue != nil && !reflect.DeepEqual(defValue, v.Default) {
		item.Default = exportValue(defValue, fmt.Sprintf("%T", defValue))
	}
	return item
}

func exportValue(value interface{}, t string) SchemaElement {
	s2, ok := value.(*schema.Schema)
	if ok {
		return SchemaElement{Type: "SchemaElements", ElementsType: fmt.Sprintf("%s", s2.Type)}
	}
	r2, ok := value.(*schema.Resource)
	if ok {
		return SchemaElement{Type: "SchemaInfo", Info: ExportResource(r2)}
	}
	return SchemaElement{Type: t, Value: fmt.Sprintf("%v", value)}
}

func Generate(provider *schema.Provider, name string, outputPath string) {
	outputFilePath := filepath.Join(outputPath, fmt.Sprintf("%s.json", name))

	if err := DoGenerate(provider, name, outputFilePath); err != nil {
		fmt.Fprintln(os.Stderr, "Error: ", err.Error())
		os.Exit(255)
	}
}

func DoGenerate(provider *schema.Provider, providerName string, outputFilePath string) error {
	providerJson, err := json.MarshalIndent(Export(provider), "", "  ")

	if err != nil {
		return err
	}

	file, err := os.Create(outputFilePath)
	if err != nil {
		return err
	}

	defer file.Close()

	_, err = file.Write(providerJson)
	if err != nil {
		return err
	}

	return file.Sync()
}

type SchemaElement struct {
	// One of ValueType or "SchemaElements" or "SchemaInfo"
	Type string `json:",omitempty"`
	// Set for simple types (from ValueType)
	Value string `json:",omitempty"`
	// Set if Type == "SchemaElements"
	ElementsType string `json:",omitempty"`
	// Set if Type == "SchemaInfo"
	Info SchemaInfo `json:",omitempty"`
}

type SchemaDefinition struct {
	Type          string `json:",omitempty"`
	Optional      bool   `json:",omitempty"`
	Required      bool   `json:",omitempty"`
	Description   string `json:",omitempty"`
	InputDefault  string `json:",omitempty"`
	Computed      bool   `json:",omitempty"`
	MaxItems      int    `json:",omitempty"`
	MinItems      int    `json:",omitempty"`
	PromoteSingle bool   `json:",omitempty"`

	ComputedWhen  []string `json:",omitempty"`
	ConflictsWith []string `json:",omitempty"`

	Deprecated string `json:",omitempty"`
	Removed    string `json:",omitempty"`

	Default SchemaElement `json:",omitempty"`
	Elem    SchemaElement `json:",omitempty"`
}

type SchemaInfo map[string]SchemaDefinition

// ResourceProviderSchema
type ResourceProviderSchema struct {
	Name        string                `json:"name"`
	Type        string                `json:"type"`
	Version     string                `json:"version"`
	Provider    SchemaInfo            `json:"provider"`
	Resources   map[string]SchemaInfo `json:"resources"`
	DataSources map[string]SchemaInfo `json:"data-sources"`
}

func main() {
	var provider tf.ResourceProvider
	provider = <provider>.Provider()
	Generate(provider.(*schema.Provider), "<provider>-<version>", "<plugin-path>/vim-terraform-completion/schemas-extractor/schemas")
}
