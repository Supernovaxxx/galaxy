import path from 'path'
import { Configuration } from 'webpack'

import CopyPlugin from 'copy-webpack-plugin'


const webpackConfig: Configuration = {
  mode: 'production',
  entry: './content/index.js',
  plugins: [
    new CopyPlugin({
      // Copies individual files or entire directories, which already exist, to the build directory.
      // See https://webpack.js.org/plugins/copy-webpack-plugin
      patterns: [
        {
          from: "content/**/*.md",
          to: "",
          globOptions: {
            ignore: [
              // Match dundle filenames (e.g. __template__)
              '**/__*__(.*)'
            ],
          },
          transform(content, path) {
            return content
              .toString()
              .replace(/\[raindrop:(\d+)\]/, '<Raindrop id="$1"/>')
          }, 
        },
      ],
    }),
  ],
  output: {
    path: path.resolve('dist'),
    filename: 'bundle.js',
    clean: true,
  },
}

export default webpackConfig