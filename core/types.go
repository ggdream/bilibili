package core

import "fmt"


var (
	url1		= "https://www.bilibili.com/video/%s"
	url2		= "https://www.bilibili.com/video/%s?p=%d"
	userAgent	= "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.111 Safari/537.36"
)

var headers = func(id string) map[string]interface{} {
	return map[string]interface{}{
		"referer": fmt.Sprintf(url1, id),
		"user-agent": userAgent,
	}
}


