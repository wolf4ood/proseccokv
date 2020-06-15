#!/usr/bin/env node
const elmxParser = require('elmx');
const fs = require('fs');
const SVGO = require('svgo')

const path = 'src/_static/pyxis'
const skeleton = `module View.Pyxis exposing (..)

import Svg exposing (node)
import Html.Attributes exposing (attribute)
import Html exposing (text)

`

const svgoOptimize = new SVGO({
  multipass: true,
  pretty: true,
  plugins: [
    {cleanupAttrs: true},
    {cleanupEnableBackground: true},
    {cleanupIDs: true},
    {cleanupListOfValues: true},
    {cleanupNumericValues: true},
    {collapseGroups: true},
    {convertColors: true},
    {convertPathData: true},
    {convertShapeToPath: true},
    {convertStyleToAttrs: true},
    {convertTransform: true},
    {mergePaths: true},
    {moveElemsAttrsToGroup: true},
    {moveGroupAttrsToElems: true},
    {removeAttrs: {attrs: '(fill|stroke)'}}, // if you don't want any color from the original SVG - see also the removeStyleElement option
    {removeComments: true},
    {removeDesc: true}, // for usability reasons
    {removeDimensions: true},
    {removeDoctype: true},
    {removeEditorsNSData: true},
    {removeEmptyAttrs: true},
    {removeEmptyContainers: true},
    {removeEmptyText: true},
    {removeHiddenElems: true},
    {removeMetadata: true},
    {removeNonInheritableGroupAttrs: true},
    {removeRasterImages: true}, // bitmap! you shall not pass!
    {removeScriptElement: true}, // shoo, javascript!
    {removeStyleElement: true}, // if you really really want to remove ANY <style> tag from the original SVG, watch out as it could be too much disruptive - see also the removeAttrs option
    {removeTitle: false}, // for usability reasons
    {removeUnknownsAndDefaults: true},
    {removeUnusedNS: true},
    {removeUselessDefs: true},
    {removeUselessStrokeAndFill: true},
    {removeViewBox: false},
    {removeXMLProcInst: true},
    {sortAttrs: true}
  ]
})

async function optimize (filepath) {
  fs.readFile(filepath, 'utf8', function(err, data) {
    if (err) {
      console.debug(err, 'Failed optimize SVG')
      console.error(err)
      throw err;
    }
    svgoOptimize.optimize(data, {path: filepath}).then((result) => {
      fs.writeFile(filepath, result.data, () => console.debug(filepath, 'written'))
    })
  })
}

const pascalize = (text) => {
  text = text.replace(/[-_\s.]+(.)?/g, (match, c) => c ? c.toUpperCase() : '');
  return text.substr(0, 1).toUpperCase() + text.substr(1);
}

async function run () {
  const body = convert().join('\n')
  const content = skeleton + body
  const target = `src/View/Pyxis.elm`
  fs.writeFile(target, content, () => console.debug(target, 'written'))
}

const convert = () =>
  fs.readdirSync(path)
    .map(file => {
      // read file as string and convert to elm
      const sourceFile = `${path}/${file}`
      try {
        optimize(sourceFile)
        const iconName = file.split('.')[0]
        const source = (fs.readFileSync(sourceFile)).toString()
        const generated = elmxParser(source)
          .replace(/viewbox/g, 'viewBox')
          .replace(/Html/g, 'Svg')
          .replace(/Svg\.Attributes\./g, '')
          .replace(/Svg\.node/g, 'node')
          .replace(/\, attribute \"width\" \"1024\"\, attribute \"height\" \"1024\"/g, '')
          .replace(/\, node \"g\" \[attribute \"id\" \"icomoon-ignore\"\] \[\n\]/g, '')
          .replace(/"svg" \[/g, '"svg" [attribute "role" "icon",')
          .replace(/node \"title\" \[\] \[/g, 'node "title" [] [text "'+iconName.toLowerCase()+'"], ')
          .replace(/\] \[\]\]\]/g, "] [] ]");

        const targetName = pascalize(file.split('.')[0])
        const elmSource = `${targetName[0].toLowerCase() + targetName.slice(1)} = ${generated}`
        return elmSource
      } catch (e) {
        console.debug(sourceFile, 'failed')
        console.error(e)
        return ''
      }
  })

run()
