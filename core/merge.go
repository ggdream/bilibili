package core

import (
	"fmt"
	"os/exec"
	"path"
	"runtime"
	"sync"
	"time"

	"github.com/panjf2000/ants/v2"
)

type merge struct {
	Path		string
	Save		bool
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
		fmt.Println("ffmpeg:", err)
		return
	}
 
	if !m.Save {
		// if err := os.Remove(path.Join(m.Path, "src", fmt.Sprintf("%d.mp4", m.Details[i].Rank))); err != nil {
		// 	fmt.Println(err)
		// }
		// if err := os.Remove(path.Join(m.Path, "src", fmt.Sprintf("%d.mp3", m.Details[i].Rank))); err != nil {
		// 	fmt.Println(err)
		// }
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

func Merger(details []*detail, path string, save bool) *merge {
	pool, _ := ants.NewPool(runtime.NumCPU())
	return &merge{
		Path:    path,
		Save:	 save,
		Details: details,
		pool:    pool,
		wg:      sync.WaitGroup{},
	}
}
