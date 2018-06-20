'use strict';
require('dotenv').config()

const koa = require('koa')
const logger = require('koa-logger')
var dbconfig = require('../knexfile.js')['development'];
const knex = require('knex')(dbconfig);

knex.table('posts').first().then(function(row) { console.log(row); });

const serve = require('koa-static-server')
const apiRoutes = require('./routes/api');

const PORT = process.env.PORT || 1337;
const app = new koa()

app.use(logger())

app.use(apiRoutes.routes());
app.use(serve({rootDir: 'src/public'}))




app.listen(PORT, () => console.log('running on port ' + PORT))