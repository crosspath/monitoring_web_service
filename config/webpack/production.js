process.env.NODE_ENV = process.env.NODE_ENV || 'production'

const environment = require('./environment')

// Run `NODE_ENV=production DIAGRAM=1 bin/webpack` when you want to see volumes of JS packs.
if (process.env.DIAGRAM) {
  const { BundleAnalyzerPlugin } = require('webpack-bundle-analyzer');
  environment.plugins.append('BundleAnalyzer', new BundleAnalyzerPlugin());
}

module.exports = environment.toWebpackConfig()
