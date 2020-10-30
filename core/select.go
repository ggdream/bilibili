package core

import "github.com/AlecAivazis/survey/v2"


func selectNo(array []string) ([]int, error) {
	days := make([]string, 0)
	prompt := &survey.MultiSelect{
		Message: "Select video:",
		Options: array,
	}
	if err := survey.AskOne(prompt, &days); err != nil {
		return nil, err
	}

	n := 0
	a := make([]int, 0)
	for _, v := range days {
		for ;n<len(array);n++ {
			if v == array[n] {
				a = append(a, n)
				break
			}
		}
	}

	return a, nil
}
