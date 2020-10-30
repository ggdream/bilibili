package core

import (
	"fmt"
	"github.com/panjf2000/ants/v2"
	"os/exec"
	"path"
	"runtime"
	"sync"
	"time"
)

type merge struct {
	Path		string
	Details		[]*detail

	pool		*ants.Pool
	wg			sync.WaitGroup
}

func (m *merge) g(i int) {
	defer m.wg.Done()
	cmd := exec.Command(
		"ffmpeg",
		"-i", path.Join(m.Path, "src", fmt.Sprintf("%d.mp4", m.Details[i].Rank)),
		"-i", path.Join(m.Path, "src", fmt.Sprintf("%d.mp3", m.Details[i].Rank)),
		"-c:v", "copy", "-c:a", "copy", "-loglevel", "quiet",
		path.Join(m.Path, "dst", fmt.Sprintf("%s.mp4", m.Details[i].Title)))

	fmt.Printf("%s	- Merge %3d >>\n",
		time.Now().Format("2006-01-02 15:04:05"),
		m.Details[i].Rank,
	)
	if err := cmd.Run(); err != nil && err.Error() != "exit status 1" {
		fmt.Println("ffmpeg", err)
	}
	fmt.Printf("%s	- Merge %3d <<🎉\n",
		time.Now().Format("2006-01-02 15:04:05"),
		m.Details[i].Rank,
	)
}

func (m *merge) Do() error {
	defer m.pool.Release()

	for j := 0; j < len(m.Details); j++ {
		if m.Details[j] == nil {
			continue
		}

		m.wg.Add(1)

		func(i int) {
			_ = m.pool.Submit(func() {
				m.g(i)
			})
		}(j)
		}
	m.wg.Wait()
	return nil
}


func Merger(details []*detail, path string) *merge {
	pool, _ := ants.NewPool(runtime.NumCPU())
	return &merge{
		Path:    path,
		Details: details,
		pool:    pool,
		wg:      sync.WaitGroup{},
	}
}
