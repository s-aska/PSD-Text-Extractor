package main

import (
	"fmt"
	"os"

	"github.com/oov/psd"
)

func main() {
	inputPath := os.Args[1]
	outputPath := inputPath + ".txt"
	file, err := os.Open(inputPath)
	if err != nil {
		panic(err)
	}
	img, _, err := psd.Decode(file, &psd.DecodeOptions{SkipMergedImage: true})
	if err != nil {
		panic(err)
	}

	outputFile, err := os.Create(outputPath)
	if err != nil {
		panic(err)
	}

	for _, layer := range img.Layer {
		parseLayer(outputFile, layer)
	}
}

func parseLayer(outputFile *os.File, l psd.Layer) {
	if isText(l.AdditionalLayerInfo) {
		fmt.Fprintf(outputFile, "------------------------------\n\n%s\n\n", l.Name)
	}
	for _, child := range l.Layer {
		parseLayer(outputFile, child)
	}
}

func isText(info map[psd.AdditionalInfoKey][]byte) bool {
	for k := range info {
		if k == "tySh" || k == "TySh" {
			return true
		}
	}
	return false
}
