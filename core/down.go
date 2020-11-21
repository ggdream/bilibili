package core

import (
	"fmt"
	"github.com/AlecAivazis/survey/v2/terminal"
	"github.com/panjf2000/ants/v2"
	"github.com/tidwall/gjson"
	"io/ioutil"
	"net/http"
	"os"
	"path"
	"sync"
	"time"
)


type Dash struct {
	ID			string
	Path		string
	Save		bool
	All			bool
	Details		[]*detail

	wg			sync.WaitGroup
	lock		sync.Mutex
	pool		*ants.Pool

	Parser		*Parser
}

type detail struct {
	Rank			int
	Time			int64
	Title			string
	VLink			string
	ALink			string
}

//TODO
func New(id, _path string, save bool, goNum int, all bool) (*Dash, error) {
	pool, _ := ants.NewPool(goNum)
	dash := &Dash{
		ID:     id,
		All: 	all,
		Path: 	_path,
		Save: 	save,
		wg:		sync.WaitGroup{},
		lock:	sync.Mutex{},
		pool:	pool,
		Parser: &Parser{
			ID: id,
		},
	}

	if err := dash.Parser.request(); err != nil {
		return nil, err
	}

	fmt.Printf("🎉🎉 |%3d|%10s|%s|\n\n\n",
		dash.Parser.GetNumber(), dash.Parser.GetAuthor(), dash.Parser.GetTitle())

	dash.Details = make([]*detail, int(dash.Parser.GetNumber()))
	if dash.All {
		dash.parseLinks()
	} else {
		noArray, err := selectNo(dash.Parser.GetSubTitlesArray())
		if err != nil && err != terminal.InterruptErr {
			return nil, err
		}
		dash.parseSelectLinks(noArray)
	}

	record, err := os.Create(path.Join(_path, "src", "media.txt"))
	if err != nil {
		return nil, err
	}
	defer record.Close()
	if _, err := record.WriteString(id); err != nil {
		println(err.Error())
		return nil, err
	}

	return dash, nil
}


func (d *Dash) parseLink(no int) (*detail, error) {
	client := &http.Client{Timeout: 3 * time.Second}
	req := genRequest(fmt.Sprintf(url2, d.ID, no + 1), headers(d.ID))

	res, err := client.Do(req)
	if err != nil {
		return nil, err
	}
	defer res.Body.Close()
	data, err := ioutil.ReadAll(res.Body)
	if err != nil {
		return nil, err
	}

	info := d.Parser.rePlay(string(data))

	return &detail{
		Rank:  no + 1,
		Time:  gjson.Get(info, `data.dash.duration`).Int(),
		Title: d.Parser.GetSubTitlesArray()[no],
		VLink: gjson.Get(info, `data.dash.video.0.baseUrl`).String(),
		ALink: gjson.Get(info, `data.dash.audio.0.baseUrl`).String(),
	}, nil
}


func (d *Dash) parseSelectLinks(noArray []int) {
	for i:=0;i< len(noArray);i++ {
		d.wg.Add(1)
		go func(i int) {
			defer d.wg.Done()

			de, err := d.parseLink(i)
			if err != nil {
				return
			}
			d.lock.Lock()
			d.Details[i] = de
			d.lock.Unlock()
		}(noArray[i])
	}
	d.wg.Wait()
}

func (d *Dash) parseLinks() {
	for i := 0; i < int(d.Parser.GetNumber()); i++ {
		d.wg.Add(1)
		go func(i int) {
			defer d.wg.Done()
			de, err := d.parseLink(i)
			if err != nil {
				return
			}

			d.lock.Lock()
			d.Details[i] = de
			d.lock.Unlock()
		}(i)
	}
	d.wg.Wait()
}

func (d *Dash) GetPlayInfo(no int) *detail {
	for _, v := range d.Details {
		if v.Rank == no {
			return v
		}
	}
	return nil
}

func (d *Dash) Run() error {
	fmt.Println("🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈")
	d.down()
	fmt.Println("🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈")
	merger := Merger(d.Details, d.Path, d.Save)
	if err := merger.Do(); err != nil {
		return err
	}
	fmt.Println("🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈🎈")
	fmt.Println("🎉🎉 \033[1;31;40mfinished!\033[0m")
	return nil
}

func (d *Dash) mkdir(name string) {
	if _, err := os.Stat(name); os.IsNotExist(err) {
		if err := os.MkdirAll(path.Join(d.Path, name), os.ModePerm); err != nil {
			panic(err)
		}
	}
}

func (d *Dash) down() {
	defer d.pool.Release()

	d.mkdir("src")
	d.mkdir("dst")

	for j := 0; j < len(d.Details); j++ {
		tmp := j
		if d.Details[tmp] == nil {
			continue
		}
		d.wg.Add(1)

		if err := d.pool.Submit(func() {
			func(i int) {
				defer d.wg.Done()

				fmt.Printf("%s	- video %3d >>\n",
					time.Now().Format("2006-01-02 15:04:05"),
					d.Details[i].Rank,
				)
				if err := d.Parser.Down(d.ID, d.Details[i].VLink, path.Join(d.Path, "src", fmt.Sprintf("%d.mp4", d.Details[i].Rank))); err != nil {
					fmt.Println(1, err)
				}
				fmt.Printf("%s	- video %3d <<\n",
					time.Now().Format("2006-01-02 15:04:05"),
					d.Details[i].Rank,
				)

				fmt.Printf("%s	- audio %3d >>\n",
					time.Now().Format("2006-01-02 15:04:05"),
					d.Details[i].Rank,
				)
				if err := d.Parser.Down(d.ID, d.Details[i].ALink, path.Join(d.Path, "src", fmt.Sprintf("%d.mp3", d.Details[i].Rank))); err != nil {
					fmt.Println(2, err)
				}
				fmt.Printf("%s	- audio %3d <<\n",
					time.Now().Format("2006-01-02 15:04:05"),
					d.Details[i].Rank,
				)
			}(tmp)
			}); err != nil {
			return
		}
	}
	d.wg.Wait()
}
