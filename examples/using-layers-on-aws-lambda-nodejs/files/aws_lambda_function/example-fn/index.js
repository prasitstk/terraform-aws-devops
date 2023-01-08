const { getGreetingMsgWithName, getGreetingMsgWithUUIDv4 } = require('/opt/nodejs/example-util.js');
const { v4: uuidv4 } = require('uuid');

exports.handler = async (event) => {
  
  const fnMsgName = process.env.FN_MSG_NAME || 'My name';
  
  const response = {
      statusCode: 200,
      body: JSON.stringify({
        getGreetingMsgWithNameFromUtil: getGreetingMsgWithName(fnMsgName),
        getGreetingMsgWithUUIDv4FromUtil: getGreetingMsgWithUUIDv4(),
        greetingMsgWithUUIDv4: `Hi! ${uuidv4()}`,
      }),
  };
  return response;
};
