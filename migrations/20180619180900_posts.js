exports.up = (knex, Promise) => {
    return knex.schema.createTable('posts', (table) => {
        table.increments();
        table.string('title').notNullable().unique();
        table.string('content').notNullable();
        table.string('link').notNullable();
        table.string('author').notNullable();

        table.timestamp('created_at', true).notNullable().defaultTo(knex.fn.now());
        table.timestamp('updated_at', true).notNullable().defaultTo(knex.fn.now());
    });
  };
  
exports.down = (knex, Promise) => {
    return knex.schema.dropTable('posts');
};