package main

import (
	"fmt"
	"reflect"
)

type Axx struct {
	Spec  Spec  `json:"spec"`
	Spec2 *Spec `json:"spec2"`
	//Xx    map[string]Spec `json:"xx"`
}

type Spec struct {
	A []string    `json:"a,omitempty"`
	B []string    `json:"b"`
	C *[]string   `json:"c,omitempty"`
	D *[]string   `json:"d,omitempty"`
	E interface{} `json:"e"`
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

func main() {
	spec := Spec{
		A: []string{"1", "11"},
		B: []string{"2", "22"},
		C: &[]string{"3", "33"},
		D: &[]string{"4", "44"},
		E: []string{"5"},
	}

	axx := Axx{
		Spec:  spec,
		Spec2: &spec,
	}

	convert(axx)
}

func convert(obj interface{}) {
	val := reflect.ValueOf(obj)
	parseRecursive(val)
}

// Internal recursive parsing function
func parseRecursive(val reflect.Value) reflect.Value {
	switch val.Kind() {
	case reflect.Ptr:
		o := val.Elem()
		if o.IsValid() {
			res := parseRecursive(o)
			if res != reflect.ValueOf(nil) {
				fmt.Printf("Ptr: %+v\n", res.Addr())
				return res.Addr()
			}
		}
	case reflect.Interface:
		res := parseRecursive(val.Elem())
		if res != reflect.ValueOf(nil) {
			fmt.Printf("Interface: %+v\n", res)
			return res
		}
	case reflect.Struct:
		dst := val
		if !val.CanSet() {
			// this case is typically for a struct in map
			dst = reflect.New(val.Type()).Elem()
		}

		for i := 0; i < val.NumField(); i++ {
			if !dst.Field(i).CanSet() {
				// this case is typically for unexported field, ignore it
				continue
			}
			res := parseRecursive(val.Field(i))
			if res != reflect.ValueOf(nil) {
				dst.Field(i).Set(res)
			}
		}
		return dst
	case reflect.Slice:
		for i := 0; i < val.Len(); i++ {
			res := parseRecursive(val.Index(i))
			if res != reflect.ValueOf(nil) {
				if val.Index(i).CanSet() {
					val.Index(i).Set(res)
				}
			}
		}
		fmt.Printf("Slice: %+v\n", val)
		return val
	case reflect.Map:
		for _, k := range val.MapKeys() {
			mapVal := val.MapIndex(k)
			res := parseRecursive(mapVal)
			if res != reflect.ValueOf(nil) {
				val.SetMapIndex(k, res)
			}
		}
		fmt.Printf("Map: %+v\n", val)
		return val
	default:
		return val
	}

	return reflect.ValueOf(nil)
}
