package main

import (
	"bufio"
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"strings"
)

func readFiles() []string {
	files, err := ioutil.ReadDir("./14.0")
	if err != nil {
		panic(err)
	}
	var fileNames []string
	for _, f := range files {
		if !strings.Contains(f.Name(), ".txt") || strings.Contains(f.Name(), "swp") {
			continue
		}
		if f.IsDir() {
			continue
		}
		fileNames = append(fileNames, f.Name())
	}
	return fileNames
}

func readLines(path string) ([]string, error) {
	file, err := os.Open(fmt.Sprintf("./14.0/%s", path))
	if err != nil {
		panic(err)
	}
	defer file.Close()

	var lines []string
	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		line := scanner.Text()
		line = strings.Replace(line, "\t", "", 1)
		lines = append(lines, line)
	}
	return lines, scanner.Err()
}

func main() {
	log.SetFlags(log.LstdFlags | log.Lshortfile)
	files := readFiles()
	for _, file := range files {
		log.Println(file)
		outFile, err := os.OpenFile(fmt.Sprintf("/home/rohit/vreplication-docs/flags/14.0/%s.out", file), os.O_CREATE|os.O_TRUNC|os.O_RDWR, os.ModePerm)
		if err != nil {
			panic(err)
		}
		lines, err := readLines(file)
		if err != nil {
			panic(err)
		}
		isFlag := false
		flagLine := ""
		for _, line := range lines {
			if strings.HasPrefix(line, "Usage") {
				if _, err := outFile.WriteString(line + "\n"); err != nil {
					panic(err)
				}
				continue
			}
			if strings.HasPrefix(strings.TrimSpace(line), "-") {
				if isFlag { // e.g. vtctldclient.txt where flag and help are already on same line
					if _, err := outFile.WriteString(line + "\n"); err != nil {
						panic(err)
					}
					isFlag = false
					flagLine = ""
					continue
				}
				isFlag = true
				flagLine = line
			} else {
				if isFlag {
					s := fmt.Sprintf("    %-69s%s", flagLine, line)
					if _, err := outFile.WriteString(s + "\n"); err != nil {
						panic(err)
					}
					flagLine = ""
					isFlag = false
				} else {
					if _, err := outFile.WriteString(line + "\n"); err != nil {
						panic(err)
					}
				}
			}
		}
		outFile.Sync()
		if err := outFile.Close(); err != nil {
			panic(err)
		}
	}

}
