package main

import (
	"fmt"
	"io/ioutil"
	"net/http"
	"os"
	"strconv"
)

func main() {
	statusCode := 200

	http.HandleFunc("/code", func(w http.ResponseWriter, r *http.Request) {
		data, err := ioutil.ReadAll(r.Body)
		if err != nil {
			fmt.Println("read body failed", err)
			w.WriteHeader(http.StatusInternalServerError)
			return
		}

		code, err := strconv.Atoi(string(data))
		if err != nil {
			fmt.Println("invalid status code", string(data))
			w.WriteHeader(http.StatusBadRequest)
			return
		}

		if code > 600 || code < 0 {
			w.WriteHeader(http.StatusBadRequest)
			return
		}

		w.WriteHeader(http.StatusOK)
	})

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(statusCode)
	})

	addr := ":" + os.Args[1]
	fmt.Println("start http server, listen " + addr)
	err := http.ListenAndServe(addr, nil)
	if err != nil {
		fmt.Println("start http server failed,", err)
		os.Exit(1)
	}
}
