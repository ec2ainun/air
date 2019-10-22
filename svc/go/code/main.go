package main

import (
    "fmt"
    "log"
    "net/http"
    "encoding/json"
    "time"
    "code/config"
    "io/ioutil"
    "strconv"
    "math/rand"
)
type RespondHello struct {
    Hello string `json:"hello"`
}

var conf = config.New()

func headerCustom(request *http.Request) map[string]string{
    incoming_headers := []string{  
        "x-request-id",
		"x-b3-traceid",
		"x-b3-spanid",
		"x-b3-parentspanid",
		"x-b3-sampled",
		"x-b3-flags",
		"x-ot-span-contex",
		"x-dev-user",
		"fail",
    }
    headers := make(map[string]string)
    for _, header := range incoming_headers {     
        val :=request.Header.Get(header)
        if val != ""{
            headers[header] = val
        }
    }
    return headers
}

func openIssues(request *http.Request) string{
    failKey := request.Header.Get("fail")
    if failKey !="" {
        failPercent, err := strconv.ParseFloat(failKey, 64)
        if err != nil {
            log.Fatalln(err)
        }
        if (rand.Float64() < failPercent) {
            return "fail"
        }
    }
    return ""
}

func handler(w http.ResponseWriter, r *http.Request) {
    waktuInit :=time.Now()
    if openIssues(r)=="fail"{
        w.WriteHeader(http.StatusInternalServerError)
    }else{
        headers := headerCustom(r)
        client := &http.Client{}
        request, err := http.NewRequest("GET", conf.UPSTREAM_URI, nil)
        for key, header := range headers{
            request.Header.Set(key,header)
        }
        if err != nil {
            log.Fatalln(err)
        }
        resp, err := client.Do(request)
        
        body, err := ioutil.ReadAll(resp.Body)
        if err != nil {
            log.Fatalln(err)
        }
        kirim := string(body)
        lama :=time.Now().Sub(waktuInit).Seconds() * 1000
        for key, header := range headers{
            w.Header().Set(key,header)
        }
        w.WriteHeader(http.StatusOK)
        fmt.Fprintf(w,"tooks (%v ms) %v --getRespondFrom--> %v\n%v", int(lama), conf.SERVICE_NAME, conf.UPSTREAM_URI, kirim)
    }
}

func hai(w http.ResponseWriter, r *http.Request) {
    resp := RespondHello{"world!"}
    w.Header().Set("Content-Type", "application/json")
    err := json.NewEncoder(w).Encode(resp)
    if err != nil {
        http.Error(w, err.Error(), http.StatusInternalServerError)
        return
    }
}

func main() {
    http.HandleFunc("/hello", hai)
    http.HandleFunc("/", handler)
    
    address := ":"+conf.PORT
    fmt.Printf("server started at %s\n", address)
    
    server := new(http.Server)
    server.Addr = address
    err := server.ListenAndServe()
    if err != nil {
        fmt.Println(err.Error())
        log.Fatalln("Error initializing Server", err)
    }
}