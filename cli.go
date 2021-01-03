package main

import (
	"fmt"
	"github.com/ggdream/bilibili/core"
	"github.com/urfave/cli/v2"
	"os"
)

var (
	name    = "bilibili"
	version = "1.1.7"
	usage   = "$ bilibili [-a, [-c, [-d]]] <bv>"

	all  bool
	path string
	save bool
	cNum = 1 << 2

	aFlag = &cli.BoolFlag{
		Name:        "all",
		Aliases:     []string{"a"},
		Usage:       "Download all the diversity of this video.",
		Value:       all,
		Destination: &all,
	}
	cFlag = &cli.IntFlag{
		Name:        "cnum",
		Aliases:     []string{"c"},
		Usage:       "The amount of concurrency.",
		Value:       cNum,
		Destination: &cNum,
	}
	sFlag = &cli.BoolFlag{
		Name:		"save",
		Aliases: 	[]string{"s"},
		Usage: 		"Save src media",
		Value: 		save,
		Destination: &save,
	}
	pFlag = &cli.StringFlag{
		Name:        "path",
		Aliases:     []string{"p"},
		Usage:       "Storage path.",
		Value:       path,
		Destination: &path,
	}
)

func tApp() error {
	app := cli.NewApp()

	app.Name = name
	app.Version = version
	app.Usage = usage

	setSettings(app)

	return app.Run(os.Args)
}

func setSettings(app *cli.App) {
	app.Flags = []cli.Flag{aFlag, cFlag, sFlag, pFlag}
	app.Action = func(c *cli.Context) error {
		var id string
		if c.NArg() == 0 {
			fmt.Print("Please entry a bv number: ")
			if _, err := fmt.Scan(&id); err != nil {
				return err
			}
		} else {
			id = c.Args().Get(0)
		}
		g, err := core.New(id, path, save, cNum, all)
		if err != nil {
			return err
		}

		return g.Run()
	}
}
