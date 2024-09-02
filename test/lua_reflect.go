package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"reflect"
	"strings"
)

type Axx struct {
	Spec    Spec  `json:"spec"`
	SpecPtr *Spec `json:"specPtr"`
}

type inner struct {
	I map[string]string `json:"a"` // intentionally tag as a
	J []string          `json:"j"`
}

type Spec struct {
	A          []string            `json:"a"`
	B          []string            `json:"b,omitempty"`
	C          *[]string           `json:"c"`
	D          *[]string           `json:"d,omitempty"`
	E          interface{}         `json:"e"`
	F          interface{}         `json:"f"`
	G          map[string][]string `json:"g"`
	H          [][]string          `json:"h"`
	Inner      inner               `json:"inner"`
	InnerSlice []inner             `json:"innerSlice"`
}

//func main() {
//	roll := v1alpha1.Rollout{
//		Spec: v1alpha1.RolloutSpec{
//			Strategy: v1alpha1.RolloutStrategy{
//				Canary: &v1alpha1.CanaryStrategy{
//					Steps: []v1alpha1.CanaryStep{
//						{
//							Experiment: &v1alpha1.RolloutExperimentStep{
//								Templates: []v1alpha1.RolloutExperimentTemplate{},
//							},
//						},
//					},
//				},
//			},
//		},
//	}
//	buf, err := json.Marshal(roll)
//	fmt.Printf("\n%s, %+v\n\n", buf, err)
//
//	convert(roll)
//}

// Now:
// Field({}) -> LuaTable -> json ([]) -> json (delete []) -> unmarshal -> Field(nil)
// Field([]) -> LuaTable -> json ([]) -> json (delete []) -> unmarshal -> Field(nil)
//
// Expected:
// Field({}) -> LuaTable -> json ([]) -> json (convert [] to {}) -> Field({})
// Field([]) -> LuaTable -> json ([]) -> json (keep []) -> Field([])
func main2() {
	spec := Spec{
		A: []string{},
		B: []string{},
		C: &[]string{},
		D: &[]string{},
		E: []string{},
		F: map[string]string{},
		G: map[string][]string{"gg": {}},
		H: [][]string{{}},
		Inner: inner{
			I: map[string]string{},
			J: []string{},
		},
		InnerSlice: []inner{
			{
				I: map[string]string{},
				J: []string{},
			},
		},
	}

	axx := Axx{Spec: spec, SpecPtr: &spec}

	buf, err := json.Marshal(axx)
	fmt.Printf("expected jsonBytes: %s, %+v\n\n", buf, err)

	buf = bytes.ReplaceAll(buf, []byte(`{}`), []byte(`[]`))
	fmt.Printf("lua encoded jsonBytes: %s\n\n", buf)

	emptySliceField := make([][]string, 0)
	parseRecursive(reflect.ValueOf(axx), emptySliceField)
	for _, v := range emptySliceField {
		fmt.Printf("%s\n", strings.Join(v, "->"))
	}

}

// Internal recursive parsing function
func parseRecursive(val reflect.Value, st [][]string) (reflect.Value, bool) {
	//switch val.Kind() {
	//case reflect.Slice:
	//	for i := 0; i < val.Len(); i++ {
	//		res, _ := parseRecursive(val.Index(i))
	//		if res != reflect.ValueOf(nil) {
	//			if val.Index(i).CanSet() {
	//				val.Index(i).Set(res)
	//			}
	//		}
	//	}
	//	fmt.Printf("Slice: %+v\n", val)
	//	return val, true
	//case reflect.Ptr:
	//	o := val.Elem()
	//	if o.IsValid() {
	//		res, isEmptySlice := parseRecursive(o)
	//		if res != reflect.ValueOf(nil) {
	//			fmt.Printf("Ptr: %+v\n", res.Addr())
	//			return res.Addr(), isEmptySlice
	//		}
	//	}
	//case reflect.Interface:
	//	res, isEmptySlice := parseRecursive(val.Elem())
	//	if res != reflect.ValueOf(nil) {
	//		fmt.Printf("Interface: %+v\n", res)
	//		return res, isEmptySlice
	//	}
	//case reflect.Struct:
	//	dst := val
	//	if !val.CanSet() {
	//		// this case is typically for a struct in map
	//		dst = reflect.New(val.Type()).Elem()
	//	}
	//
	//	for i := 0; i < val.NumField(); i++ {
	//		if !dst.Field(i).CanSet() {
	//			// this case is typically for unexported field, ignore it
	//			continue
	//		}
	//		res, isEmptySlice := parseRecursive(val.Field(i))
	//		if isEmptySlice {
	//			tag := val.Type().Field(i).Tag.Get("json")
	//			jsonName := strings.Split(tag, ",")[0] // use split to ignore tag "options" like omitempty, etc.
	//			fmt.Printf("jsonName: %s\n", jsonName)
	//		}
	//		if res != reflect.ValueOf(nil) {
	//			dst.Field(i).Set(res)
	//		}
	//	}
	//	return dst, false
	//case reflect.Map:
	//	for _, k := range val.MapKeys() {
	//		mapVal := val.MapIndex(k)
	//		res, isSlice := parseRecursive(mapVal)
	//		if isSlice {
	//			fmt.Printf("k: %s\n", k)
	//		}
	//		if res != reflect.ValueOf(nil) {
	//			val.SetMapIndex(k, res)
	//		}
	//	}
	//	fmt.Printf("Map: %+v\n", val)
	//	return val, false
	//default:
	//	return val, false
	//}

	return reflect.ValueOf(nil), false
}
