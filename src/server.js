'use strict';
const koa = require('koa')
const logger = require('koa-logger')

const indexRoutes = require('./routes/index');

const PORT = process.env.PORT || 1337;
const app = new koa()

app.use(logger())
app.use(indexRoutes.routes());



app.listen(PORT, () => console.log('running on port ' + PORT))