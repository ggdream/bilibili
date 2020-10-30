package core

import (
	"fmt"
	"github.com/tidwall/gjson"
	"io"
	"io/ioutil"
	"net/http"
	"os"
	"regexp"
	"time"
)

type Parser struct {
	ID				string
	BaseInfo		string
}


func NewParse(id string) (*Parser, error) {
	parser := &Parser{
		ID: id,
	}
	if err := parser.request(); err != nil {
		return nil, err
	}
	return parser, nil
}




func (p *Parser) reBase(data string) string {
	reg := regexp.MustCompile(`window.__INITIAL_STATE__=(.*?);\(function`)
	return reg.FindStringSubmatch(data)[1]
}
func (p *Parser) rePlay(data string) string {
	reg := regexp.MustCompile(`window.__playinfo__=(.*?)</script>`)
	return reg.FindStringSubmatch(data)[1]
}



func (p *Parser) request() error {
	client := &http.Client{Timeout: 3 * time.Second}
	req := genRequest(fmt.Sprintf("https://www.bilibili.com/video/%s", p.ID), headers(p.ID))

	res, err := client.Do(req)
	if err != nil {
		return err
	}
	defer res.Body.Close()

	data, err := ioutil.ReadAll(res.Body)
	if err != nil {
		return err
	}

	p.BaseInfo = p.reBase(string(data))
	return nil
}

func (p *Parser) GetBaseInfo() string { return p.BaseInfo }

func (p *Parser) GetNumber() int64 { return gjson.Get(p.BaseInfo, `videoData.videos`).Int() }
func (p *Parser) GetTotalTime() int64 { return gjson.Get(p.BaseInfo, `videoData.duration`).Int() }
func (p *Parser) GetAuthor() string { return gjson.Get(p.BaseInfo, `videoData.owner.name`).String() }
func (p *Parser) GetTitle() string { return gjson.Get(p.BaseInfo, `videoData.title`).String() }
func (p *Parser) GetDesc() string { return gjson.Get(p.BaseInfo, `videoData.desc`).String() }
func (p *Parser) GetPubDate() string {
	timeStamp := gjson.Get(p.BaseInfo, `videoData.pubdate`).Int()
	return time.Unix(timeStamp, 0).Format("2006-01-02 15:04:05")
}


func (p *Parser) GetAvID() string { return gjson.Get(p.BaseInfo, `aid`).String() }
func (p *Parser) GetBvID() string { return gjson.Get(p.BaseInfo, `bvid`).String() }

func (p *Parser) GetSubTitlesArray() []string {
	data := make([]string, 0)
	json:= gjson.Get(p.BaseInfo, `videoData.pages.#.part`).Array()
	for _, v := range json {
		data = append(data, v.String())
	}
	return data
}

func (p *Parser) Show() {
	fmt.Printf("| No | Title      (%d - %s)\n", p.GetNumber(), p.GetTitle())

	titles := gjson.Get(p.BaseInfo, `videoData.pages.#.part`).Array()
	for i, v := range titles {
		fmt.Printf("|%4d| %s\n", i + 1, v.String())
	}
}

func (p *Parser) Down(id, url, dst string) error {
	client := &http.Client{}
	header := headers(id)
	header["range"] = "bytes=0-"
	req := genRequest(url, header)

	res, err := client.Do(req)
	if err != nil {
		return err
	}
	defer res.Body.Close()

	f, err := os.Create(dst)
	if err != nil {
		return err
	}
	if _, err := io.Copy(f, res.Body); err != nil {
		return err
	}
	return nil
}
