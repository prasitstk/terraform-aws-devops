const { v4: uuidv4 } = require('uuid');

function getGreetingMsgWithName(name) {
  return `Hello! ${name}`;
}

function getGreetingMsgWithUUIDv4() {
  return getGreetingMsgWithName(uuidv4());
}

module.exports = {
  getGreetingMsgWithName,
  getGreetingMsgWithUUIDv4,
};
