require('dotenv').config({path: ''})


module.exports = {
  development: {
    client: 'pg',
    connection: 'find some way of adding the postgres string here....',
    migrations: {
        tableName: 'knex_migrations'
    },
  }

};
