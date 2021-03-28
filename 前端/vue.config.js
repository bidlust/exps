const path = require("path");

module.exports = {
  publicPath: "./",
  // 输出文件目录,默认就是dist
  outputDir: process.env.NODE_ENV === "test" ? "distTest" : "dist",
  // 放置生成的静态资源 (js、css、img、fonts) 的 (相对于 outputDir 的) 目录。
  assetsDir: "static",
  // 生产环境是否生成 sourceMap 文件
  productionSourceMap: false,
  // 配置es-link true,'error'
  lintOnSave: true,
  css: {
    // 一次配置，全局使用，这个scss 因为每个文件都要引入
    loaderOptions: {
      sass: {
        prependData: `@import "./src/assets/css/index.scss";`
      }
    }
  },
  // webpack-dev-server 相关配置
  devServer: {
    // 可以通过设置让浏览器 overlay 同时显示警告和错误：
    overlay: {
      warnings: true,
      errors: true
    },
    open: true,
    host: "localhost",
    port: 8899,
    https: false,
    // 热更新
    // hotOnly: false,
    proxy: {
      "/mgr": {
        // 目标代理接口地址
        target: "https://api.douban.com",
        // 是否启用websockets
        ws: true,
        // 开启代理，在本地创建一个虚拟服务端
        changeOrigin: true,
        pathRewrite: {
          "^/mgr": ""
        }
      }
    }
  },
  configureWebpack: {
    // 覆盖webpack默认配置的都在这里
    resolve: {
      // 配置解析别名
      alias: {
        "@": path.resolve(__dirname, "./src")
      }
    }
  }
};
