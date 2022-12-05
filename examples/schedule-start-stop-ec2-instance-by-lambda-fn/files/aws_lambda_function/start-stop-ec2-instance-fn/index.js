const AWS = require('aws-sdk');
AWS.config.update({region: 'ap-southeast-1'});
const ec2 = new AWS.EC2({ apiVersion: '2016-11-15' });

exports.handler = async (event) => {
    
    let dryRun = event['DryRun'] || process.env.DEFAULT_DRY_RUN;
    dryRun = dryRun.toLowerCase() === 'true';
    
    console.log(`dryRun = ${dryRun}`);
    
    const currDate = new Date();
    let hh = currDate.getHours();
    let mm = currDate.getMinutes();
    
    hh = (hh < 10 ? '0' : '') + hh;
    mm = (mm < 10 ? '0' : '') + mm;
    const hhmm = hh + mm;
    
    console.log(`currDate (HHMM) = ${hhmm}`);
    
    const schedules = event['Schedules'];
        
    const promises = schedules.map(async sched => {
        console.log('========================');
        const instanceId = sched['InstanceID'];
        const action = sched['Action'];
        const scheduledTimes = sched['ScheduledTimes'];
        
        console.log(`instanceId = ${instanceId}`);
        console.log(`action = ${action}`);
        console.log(`scheduledTimes = [${scheduledTimes}]`);
        
        if(scheduledTimes.includes(hhmm)) {
            if(dryRun) {
                console.log(`Dry run the action '${action}' to the instance '${instanceId}' at '${hhmm}'.`);
            } else {
                try {
                    if (action.toLowerCase() == 'start') {
                        await ec2.startInstances({ InstanceIds: [instanceId] }).promise();
                        console.log(`Successfully start the instance '${instanceId}' at '${hhmm}'`);
                    } else if (action.toLowerCase() == 'stop') {
                        await ec2.stopInstances({ InstanceIds: [instanceId] }).promise();
                        console.log(`Successfully stop the instance '${instanceId}' at '${hhmm}'`);
                    } else {
                        console.log(`This function does not support the action '${action}' to the instance '${instanceId}' at '${hhmm}', so skip it.`);
                    } 
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
        } else {
            console.log(`Do nothing because the current hhmm ${hhmm} does not exist in scheduledTimes.`);
        }
        
        console.log('========================');
    });
    
    await Promise.all(promises);
    console.log(`Finish running all actions on EC2 instances at '${hhmm}'`);
    
    return {
        statusCode: 200,
        body: event
    };

};
