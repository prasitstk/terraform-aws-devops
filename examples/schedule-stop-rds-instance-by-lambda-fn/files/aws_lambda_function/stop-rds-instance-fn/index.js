const AWS = require('aws-sdk');
AWS.config.update({region: 'ap-southeast-1'});
const rds = new AWS.RDS({apiVersion: '2014-10-31'});

exports.handler = async (event) => {
    
    let dbIdentifier = event['DBIdentifier']
    let dryRun = event['DryRun'] || process.env.DEFAULT_DRY_RUN;
    dryRun = dryRun.toLowerCase() === 'true';
    
    console.log(`dbIdentifier = ${dbIdentifier}`);
    console.log(`dryRun = ${dryRun}`);
    
    if(!dryRun) {
        try {
            var params = {
              DBInstanceIdentifier: dbIdentifier
            };
            await rds.stopDBInstance(params).promise();
        } catch(err) {
            console.error(err);
            return {
                statusCode: 500,
                body: {
                    message: err.message
                }
            };   
        }   
    }
    
    return {
        statusCode: 200,
        body: {
            dbIdentifier,
        }
    };
};
