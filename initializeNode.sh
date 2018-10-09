#!/usr/bin/env bash

# get a project name
read -p 'Project name: ' projectName
echo 'Project name is "'$projectName'"'

# if there is no such directory named $projectName
if [ -d ${projectName} ]; then
  echo Directory already exists...
else
  # make a project directory
  echo Making a new directory named $projectName...
  mkdir $projectName
fi

# go to the project directory
cd $projectName

# make README.md file and git initialization
echo Initializing git...
git init

echo Making README file...
touch README.md

touch .gitignore
cat >.gitignore <<EOL
node_modules/

.DS_Store

dist/

package-lock.json
EOL

# initialize package.json
echo Initializing package.json
touch package.json
cat >package.json <<EOL
{
  "name": "${projectName}",
  "version": "1.0.0",
  "description": "",
  "main": "index.js",
  "scripts": {
    "build": "webpack --mode development",
    "start": "npm run build && webpack-dev-server --open --mode development",
    "lint": "eslint src/*.js",
    "test": "karma start karma.conf.js"
  },
  "keywords": [],
  "author": "",
  "license": "ISC"
}
EOL

echo Installing webpack and webpack cli...

# install webpack
npm install webpack@4.0.1 --save-dev
npm install webpack-cli@2.0.9 --save-dev

# configure webpack
echo Configuring webpack...
touch webpack.config.js
cat >webpack.config.js <<EOL
const path = require('path');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const CleanWebpackPlugin = require('clean-webpack-plugin');
const UglifyJsPlugin = require('uglifyjs-webpack-plugin');

module.exports = {
  entry: './src/main.js',
  output: {
    filename: 'bundle.js',
    path: path.resolve(__dirname, 'dist')
  },
  devtool: 'eval-source-map',
  devServer: {
    contentBase: './dist'
  },
  plugins: [
    new UglifyJsPlugin({ sourceMap: true }),
    new CleanWebpackPlugin(['dist']),
    new HtmlWebpackPlugin({
      title: '${projectName}',
      template: './src/index.html',
      inject: 'body'
    })
  ],
  module: {
    rules: [
      {
        test: /\.css$/,
        use: [
          'style-loader',
          'css-loader'
        ]
      },
      {
        test: /\.js$/,
        exclude: /node_modules/,
        loader: "eslint-loader"
      }
    ]
  }
};
EOL

# make src directory and basic files
echo Making the src folder, index.html, main.js, and styles.css files... 
mkdir src
touch src/index.html
cat >src/index.html <<EOL
<!DOCTYPE html>
<html>
  <head>
    <script type="text/javascript" src="bundle.js"></script>
    <title>${projectName}</title>
  </head>
  <body>
    <p>${projectName}</p>
  </body>
</html>
EOL

touch src/main.js
cat >src/main.js <<EOL
import $ from 'jquery';
import 'bootstrap';
import 'bootstrap/dist/css/bootstrap.min.css';
import './styles.css';

\$(document).ready(function() {

});
EOL

# generate stylesheet
touch src/styles.css

echo Installing webpack plugins...

# install style-loader and css-loader
npm install style-loader@0.20.2 css-loader@0.28.10 --save-dev

# install html webpack plugin
npm install html-webpack-plugin@3.0.6 --save-dev

# install clean webpack plugin
npm install clean-webpack-plugin@0.1.18 --save-dev

# install uglify webpack plugin
npm install uglifyjs-webpack-plugin@1.2.2 --save-dev

# install dev server webpack plugin
npm install webpack-dev-server@3.1.0 --save-dev

echo Installing eslint...

# install eslint
npm install eslint@4.18.2 --save-dev
npm install eslint-loader@2.0.0 --save-dev

echo Configuring eslint...

# configure .eslintrc
touch .eslintrc
cat >.eslintrc <<EOL
{
  "parserOptions": {
    "ecmaVersion": 6,
    "sourceType": "module"
  },
  "extends": "eslint:recommended",
  "env": {
    "browser": true,
    "jquery": true,
    "node": true,
    "jasmine": true
  },
  "rules": {
    "semi": 1,
    "indent": ["warn", 2],
    "no-console": "warn",
    "no-debugger": "warn"
  }
}
EOL

echo Installing jquery and bootstrap...

# install jquery
npm install jquery@3.3.1 --save

# install popper.js and bootstrap
npm install popper.js@1.14.0 --save
npm install bootstrap@4.0.0 --save

echo Installing jasmine...

# install jasmine
npm install jasmine-core@2.99.0 --save-dev
npm install jasmine@3.1.0 --save-dev
./node_modules/.bin/jasmine init

echo Installing karma and karma plugins...

# install karma
npm install karma@2.0.0 --save-dev
npm install karma-jasmine@1.1.1 --save-dev
npm install karma-chrome-launcher@2.2.0 --save-dev
npm install -g karma-cli
npm install karma-cli@1.0.1 --save-dev
npm install karma-webpack@2.0.13 --save-dev
npm install karma-jquery@0.2.2 --save-dev
npm install karma-jasmine-html-reporter@0.2.2 --save-dev
npm install karma-sourcemap-loader@0.3.7 --save-dev

echo Configuring Karma...

# configure karma
touch karma.conf.js
cat >karma.conf.js <<EOL
const webpackConfig = require('./webpack.config.js');

module.exports = function(config) {
  config.set({
    basePath: '',
    frameworks: ['jasmine'],
    files: [
      'src/*.js',
      'spec/*spec.js'
    ],
    webpack: webpackConfig,
    exclude: [
    ],
    preprocessors: {
      'src/*.js': ['webpack', 'sourcemap'],
      'spec/*spec.js': ['webpack', 'sourcemap']
    },
    plugins: [
      'karma-jquery',
      'karma-webpack',
      'karma-jasmine',
      'karma-chrome-launcher',
      'karma-jasmine-html-reporter',
      'karma-sourcemap-loader'
    ],
    reporters: ['progress', 'kjhtml'],
    port: 9876,
    colors: true,
    logLevel: config.LOG_INFO,
    autoWatch: true,
    browsers: ['Chrome'],
    singleRun: false,
    concurrency: Infinity
  })
}
EOL

# build this project
npm run build