package main

import (
	"fmt"
	"strings"

	"github.com/argoproj/argo-rollouts/pkg/apis/rollouts/v1alpha1"
	jsoniter "github.com/json-iterator/go"
	"github.com/tidwall/gjson"
	"github.com/tidwall/sjson"
	"github.com/yuin/gluamapper"
	lua "github.com/yuin/gopher-lua"
	"k8s.io/apimachinery/pkg/apis/meta/v1/unstructured"
	"k8s.io/apimachinery/pkg/runtime"
	"k8s.io/klog/v2"
	luajson "layeh.com/gopher-json"
)

func test6() {
	v := &lua.LTable{}

	innerV1 := lua.LTable{}
	innerV1.RawSetString("key1", lua.LString("1"))
	v.Append(&innerV1)
	innerV2 := lua.LTable{}
	innerV2.RawSetString("key2", lua.LString("2"))
	v.Append(&innerV2)

	obj := &[]map[string]string{}
	err := gluamapper.Map(v, obj)
	fmt.Println(err)

	err = gluamapperToSlice(v, obj)
	fmt.Println(err)
	fmt.Println(obj)
}

type outter struct {
	Value interface{} `json:"value"`
}

func gluamapperToSlice(tbl *lua.LTable, st interface{}) error {
	outterTbl := lua.LTable{}
	outterTbl.RawSetString("value", tbl)
	outterObj := &outter{Value: st}
	err := gluamapper.Map(&outterTbl, outterObj)
	return err
}

var sliceStr = `{"kind":"Rollout","metadata":{"resourceVersion":"197933","annotations":{"resourcetemplate.karmada.io/uid":"24bd0e23-2b10-4d1e-94a2-9b99141f6d52","resourcetemplate.karmada.io/managed-annotations":"kubectl.kubernetes.io/last-applied-configuration,propagationpolicy.karmada.io/name,propagationpolicy.karmada.io/namespace,resourcebinding.karmada.io/name,resourcebinding.karmada.io/namespace,resourcetemplate.karmada.io/managed-annotations,resourcetemplate.karmada.io/managed-labels,resourcetemplate.karmada.io/uid,work.karmada.io/conflict-resolution,work.karmada.io/name,work.karmada.io/namespace","kubectl.kubernetes.io/last-applied-configuration":"{\"apiVersion\":\"argoproj.io/v1alpha1\",\"kind\":\"Rollout\",\"metadata\":{\"annotations\":{},\"labels\":{\"app\":\"nginx\"},\"name\":\"nginx-rollout\",\"namespace\":\"default\"},\"spec\":{\"progressDeadlineSeconds\":600,\"replicas\":2,\"revisionHistoryLimit\":10,\"selector\":{\"matchLabels\":{\"app\":\"nginx\"}},\"strategy\":{\"canary\":{\"maxSurge\":\"100%\",\"maxUnavailable\":0,\"steps\":[{\"setWeight\":40},{\"pause\":{}},{\"experiment\":{\"templates\":{}}}]}},\"template\":{\"metadata\":{\"labels\":{\"app\":\"nginx\"}},\"spec\":{\"containers\":[{\"image\":\"nginx\",\"imagePullPolicy\":\"Always\",\"name\":\"nginx\",\"resources\":{},\"terminationMessagePath\":\"/dev/termination-log\",\"terminationMessagePolicy\":\"File\"}],\"dnsPolicy\":\"ClusterFirst\",\"restartPolicy\":\"Always\",\"schedulerName\":\"default-scheduler\",\"securityContext\":{},\"terminationGracePeriodSeconds\":30}}}}\n","resourcebinding.karmada.io/namespace":"default","work.karmada.io/conflict-resolution":"abort","work.karmada.io/name":"nginx-rollout-6fc47b96ff","propagationpolicy.karmada.io/namespace":"default","resourcebinding.karmada.io/name":"nginx-rollout-rollout","propagationpolicy.karmada.io/name":"nginx-propagation","work.karmada.io/namespace":"karmada-es-member1","rollout.argoproj.io/revision":"1"},"labels":{"propagationpolicy.karmada.io/namespace":"default","propagationpolicy.karmada.io/name":"nginx-propagation","karmada.io/managed":"true","app":"nginx","work.karmada.io/name":"nginx-rollout-6fc47b96ff","work.karmada.io/permanent-id":"1c8b9c5e-c043-452f-8d95-e771a7ef0f95","resourcebinding.karmada.io/permanent-id":"fd68732f-6ff3-4f8c-b5e6-9e9f8af55617","resourcebinding.karmada.io/key":"8b774b865","propagationpolicy.karmada.io/permanent-id":"c93a4b68-1dc0-4fd7-b808-af079b6db3a7","work.karmada.io/namespace":"karmada-es-member1"},"name":"nginx-rollout","namespace":"default"},"spec":{"replicas":2,"revisionHistoryLimit":10,"selector":{"matchLabels":{"app":"nginx"}},"strategy":{"canary":{"maxSurge":"100%","maxUnavailable":0,"steps":[{"setWeight":40},{"pause":{}},{"experiment":{"templates":[]}}]}},"template":{"metadata":{"labels":{"app":"nginx"}},"spec":{"securityContext":{},"terminationGracePeriodSeconds":30,"containers":[{"resources":{},"terminationMessagePath":"/dev/termination-log","terminationMessagePolicy":"File","image":"nginx","imagePullPolicy":"Always","name":"nginx"}],"dnsPolicy":"ClusterFirst","restartPolicy":"Always","schedulerName":"default-scheduler"}},"progressDeadlineSeconds":600},"apiVersion":"argoproj.io/v1alpha1"}`
var mapStr = `{"kind":"Rollout","metadata":{"resourceVersion":"197933","annotations":{"resourcetemplate.karmada.io/uid":"24bd0e23-2b10-4d1e-94a2-9b99141f6d52","resourcetemplate.karmada.io/managed-annotations":"kubectl.kubernetes.io/last-applied-configuration,propagationpolicy.karmada.io/name,propagationpolicy.karmada.io/namespace,resourcebinding.karmada.io/name,resourcebinding.karmada.io/namespace,resourcetemplate.karmada.io/managed-annotations,resourcetemplate.karmada.io/managed-labels,resourcetemplate.karmada.io/uid,work.karmada.io/conflict-resolution,work.karmada.io/name,work.karmada.io/namespace","kubectl.kubernetes.io/last-applied-configuration":"{\"apiVersion\":\"argoproj.io/v1alpha1\",\"kind\":\"Rollout\",\"metadata\":{\"annotations\":{},\"labels\":{\"app\":\"nginx\"},\"name\":\"nginx-rollout\",\"namespace\":\"default\"},\"spec\":{\"progressDeadlineSeconds\":600,\"replicas\":2,\"revisionHistoryLimit\":10,\"selector\":{\"matchLabels\":{\"app\":\"nginx\"}},\"strategy\":{\"canary\":{\"maxSurge\":\"100%\",\"maxUnavailable\":0,\"steps\":[{\"setWeight\":40},{\"pause\":{}},{\"experiment\":{\"templates\":{}}}]}},\"template\":{\"metadata\":{\"labels\":{\"app\":\"nginx\"}},\"spec\":{\"containers\":[{\"image\":\"nginx\",\"imagePullPolicy\":\"Always\",\"name\":\"nginx\",\"resources\":{},\"terminationMessagePath\":\"/dev/termination-log\",\"terminationMessagePolicy\":\"File\"}],\"dnsPolicy\":\"ClusterFirst\",\"restartPolicy\":\"Always\",\"schedulerName\":\"default-scheduler\",\"securityContext\":{},\"terminationGracePeriodSeconds\":30}}}}\n","resourcebinding.karmada.io/namespace":"default","work.karmada.io/conflict-resolution":"abort","work.karmada.io/name":"nginx-rollout-6fc47b96ff","propagationpolicy.karmada.io/namespace":"default","resourcebinding.karmada.io/name":"nginx-rollout-rollout","propagationpolicy.karmada.io/name":"nginx-propagation","work.karmada.io/namespace":"karmada-es-member1","rollout.argoproj.io/revision":"1"},"labels":{"propagationpolicy.karmada.io/namespace":"default","propagationpolicy.karmada.io/name":"nginx-propagation","karmada.io/managed":"true","app":"nginx","work.karmada.io/name":"nginx-rollout-6fc47b96ff","work.karmada.io/permanent-id":"1c8b9c5e-c043-452f-8d95-e771a7ef0f95","resourcebinding.karmada.io/permanent-id":"fd68732f-6ff3-4f8c-b5e6-9e9f8af55617","resourcebinding.karmada.io/key":"8b774b865","propagationpolicy.karmada.io/permanent-id":"c93a4b68-1dc0-4fd7-b808-af079b6db3a7","work.karmada.io/namespace":"karmada-es-member1"},"name":"nginx-rollout","namespace":"default"},"spec":{"replicas":2,"revisionHistoryLimit":10,"selector":{"matchLabels":{"app":"nginx"}},"strategy":{"canary":{"maxSurge":"100%","maxUnavailable":0,"steps":[{"setWeight":40},{"pause":{}},{"experiment":{"templates":{}}}]}},"template":{"metadata":{"labels":{"app":"nginx"}},"spec":{"securityContext":{},"terminationGracePeriodSeconds":30,"containers":[{"resources":{},"terminationMessagePath":"/dev/termination-log","terminationMessagePolicy":"File","image":"nginx","imagePullPolicy":"Always","name":"nginx"}],"dnsPolicy":"ClusterFirst","restartPolicy":"Always","schedulerName":"default-scheduler"}},"progressDeadlineSeconds":600},"apiVersion":"argoproj.io/v1alpha1", "add": {}}`

func test5() {
	res := gjson.Parse(sliceStr)
	keyPathOfEmptySlice := make(map[string]string)
	keyPathOfEmptyObject := make(map[string]string)
	traverse(res, nil, keyPathOfEmptySlice, keyPathOfEmptyObject)
	fmt.Println(keyPathOfEmptySlice)
	fmt.Println(keyPathOfEmptyObject)

	res = gjson.Parse(mapStr)
	emptyMapToSlice := make(map[string]string)
	emptyMapToDelete := make(map[string]string)
	traverse2(res, nil, nil, keyPathOfEmptySlice, keyPathOfEmptyObject, emptyMapToSlice, emptyMapToDelete)
	fmt.Println(emptyMapToSlice)
	fmt.Println(emptyMapToDelete)

	var err error
	for keyPath := range emptyMapToSlice {
		mapStr, err = sjson.Set(mapStr, keyPath, []string{})
		if err != nil {
			panic(err)
		}
	}

	for keyPath := range emptyMapToDelete {
		mapStr, err = sjson.Delete(mapStr, keyPath)
		if err != nil {
			panic(err)
		}
	}

	fmt.Println(mapStr)
}

func traverse(father gjson.Result, fatherKeyPath []string, keyPathOfEmptySlice, keyPathOfEmptyObject map[string]string) {
	fatherIsNotArray := !father.IsArray()
	father.ForEach(func(key, value gjson.Result) bool {
		curKeyPath := fatherKeyPath
		if fatherIsNotArray {
			curKeyPath = append(fatherKeyPath, key.String())
		}
		if value.IsArray() && len(value.Array()) == 0 {
			keyPathOfEmptySlice[strings.Join(curKeyPath, ".")] = "[]"
		} else if value.IsObject() && len(value.Map()) == 0 {
			keyPathOfEmptyObject[strings.Join(curKeyPath, ".")] = "{}"
		} else if value.IsArray() || value.IsObject() {
			traverse(value, curKeyPath, keyPathOfEmptySlice, keyPathOfEmptyObject)
		}
		return true // keep iterating
	})
}

func traverse2(father gjson.Result, keyPath, keyPathWithIndex []string, keyPathOfEmptySlice, keyPathOfEmptyMap, emptyMapToSlice, emptyMapToDelete map[string]string) {
	fatherIsNotArray := !father.IsArray()
	father.ForEach(func(key, value gjson.Result) bool {
		curKeyPath := keyPath
		if fatherIsNotArray {
			curKeyPath = append(keyPath, key.String())
		}
		curKeyPathWithIndex := append(keyPathWithIndex, key.String())
		if value.IsObject() && len(value.Map()) == 0 {
			curKeyPathStr := strings.Join(curKeyPath, ".")
			curKeyPathWithIndexStr := strings.Join(curKeyPathWithIndex, ".")

			if _, ok := keyPathOfEmptySlice[curKeyPathStr]; ok {
				emptyMapToSlice[curKeyPathWithIndexStr] = "{}->[]"
			} else if _, ok := keyPathOfEmptyMap[curKeyPathStr]; !ok {
				emptyMapToDelete[curKeyPathWithIndexStr] = "{}"
			}
		} else if value.IsArray() || value.IsObject() {
			traverse2(value, curKeyPath, curKeyPathWithIndex, keyPathOfEmptySlice, keyPathOfEmptyMap, emptyMapToSlice, emptyMapToDelete)
		}
		return true // keep iterating
	})
}

func main3() {
	//L := lua.NewState()
	//defer L.Close()
	//luaResult, err := luajson.Decode(L, []byte(mapStr))
	//if err != nil {
	//	panic(err)
	//}
	//fmt.Println(luaResult)

	//test1(luaResult)

	//test2(luaResult)

	//test3()
	//test5()

	//test6()
	//test7(luaResult)

	//a := []string{"1", "3"}
	//test8(a)
	//test9(a)
	//test10(a.([]interface{}))
}

func test8[T any](param []T) {
	fmt.Println(param)
}

func test10(param []any) {
	fmt.Println(param)
}

func test9(param []interface{}) {
	fmt.Println(param)
}

func test1(luaResult lua.LValue) {
	d := &v1alpha1.Rollout{}
	convertLuaToStruct(luaResult, d)
}

func convertLuaToStruct(luaResult lua.LValue, obj interface{}) {
	err := gluamapper.Map(luaResult.(*lua.LTable), obj)
	klog.Infof("gluamapper Map: %+v, %+v\n\n", obj, err)
}

func test2(luaResult lua.LValue) {
	in := gluamapper.ToGoValue(luaResult, gluamapper.Option{NameFunc: gluamapper.Id})
	klog.Infof("gluamapper.ToGoValue: %+v\n\n", in)

	buf, err := jsoniter.Marshal(in)
	klog.Infof("marshal: %s, %+v\n\n", buf, err)

	d := &v1alpha1.Rollout{}
	err = jsoniter.Unmarshal(buf, d)
	klog.Infof("unmarshal: %+v, err: %+v\n\n", d, err)
}

func test7(luaResult lua.LValue) {
	jsonBytes, err := luajson.Encode(luaResult)
	klog.Infof("marshal: %s, %+v\n\n", jsonBytes, err)
}

func test3() {
	d := &v1alpha1.Rollout{}
	err := jsoniter.Unmarshal([]byte(mapStr), d)
	klog.Infof("unmarshal: %+v, err: %+v\n\n", d, err)
}

// ToUnstructured converts a typed object to an unstructured object.
func ToUnstructured(obj interface{}) (*unstructured.Unstructured, error) {
	uncastObj, err := runtime.DefaultUnstructuredConverter.ToUnstructured(obj)
	if err != nil {
		return nil, err
	}
	return &unstructured.Unstructured{Object: uncastObj}, nil
}

//func main() {
//	type specStruct struct {
//		Label      map[string]string
//		LifeCycle  map[string]string
//		OtherField string
//		Affinity   []string
//	}
//
//	type foolStruct struct {
//		Spec specStruct
//	}
//
//	label := &lua.LTable{}
//	label.RawSetString("one-label", lua.LString(`\"hello\":[]`))
//
//	spec := &lua.LTable{}
//	spec.RawSetH(lua.LString("Label"), label)
//	spec.RawSetH(lua.LString("LifeCycle"), &lua.LTable{})
//	spec.RawSetString("OtherField", lua.LString("test"))
//	spec.RawSetH(lua.LString("Affinity"), &lua.LTable{})
//
//	v := &lua.LTable{}
//	v.RawSetString("Spec", spec)
//
//	//var fool foolStruct
//	//fool := &unstructured.Unstructured{}
//	//if err := gluamapper.Map(v, &fool); err != nil {
//	//	panic(err)
//	//}
//	in := gluamapper.ToGoValue(v, gluamapper.Option{NameFunc: gluamapper.Id, TagName: "gluamapper"})
//	fmt.Printf("%+v\n\n", in)
//
//	buf, err := json.Marshal(in)
//	fmt.Printf("%s, %+v\n\n", buf, err)
//}
