package core

import (
	"net/http"
)


func genRequest(url string, headers map[string]interface{}) *http.Request {
	request, err := http.NewRequest("GET", url, nil)
	if err != nil {
		panic(err)
	}
	for k, v := range headers {
		request.Header.Add(k, v.(string))
	}
	return request
}
