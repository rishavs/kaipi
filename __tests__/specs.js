const frisby = require('frisby');

it ('should return a status of 200', function () {
  return frisby
    .get('http://localhost:1337/')
    .expect('status', 200);
});