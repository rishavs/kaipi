'use strict';
const koa = require('koa')
const logger = require('koa-logger')
const serve = require('koa-static-server')
const apiRoutes = require('./routes/api');

const PORT = process.env.PORT || 1337;
const app = new koa()

app.use(logger())

app.use(apiRoutes.routes());
app.use(serve({rootDir: 'src/public'}))




app.listen(PORT, () => console.log('running on port ' + PORT))