package main

import (
	"github.com/ggdream/down/core"
	"github.com/urfave/cli/v2"
	"os"
)



var (
	name		= "down"
	version		= "1.0.0"
	usage		= "$ down [-a, [-c, [-d]]] <bv>"

	all			bool
	path		string
	cNum		= 1 << 3

	aFlag		= &cli.BoolFlag{
		Name: "all",
		Aliases: []string{"a"},
		Usage: "Download all the diversity of this video.",
		Value: all,
		Destination: &all,
	}
	cFlag		= &cli.IntFlag{
		Name: "cnum",
		Aliases: []string{"c"},
		Usage: "The amount of concurrency.",
		Value: cNum,
		Destination: &cNum,
	}
	pFlag		= &cli.StringFlag{
		Name: "path",
		Aliases: []string{"p"},
		Usage: "Storage path.",
		Value: path,
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
	app.Flags = []cli.Flag{ aFlag, cFlag, pFlag }
	app.Action = func(c *cli.Context) error {
		g, err := core.New(c.Args().Get(0), path, cNum, all)
		if err != nil {
			return err
		}

		return g.Run()
	}
}
