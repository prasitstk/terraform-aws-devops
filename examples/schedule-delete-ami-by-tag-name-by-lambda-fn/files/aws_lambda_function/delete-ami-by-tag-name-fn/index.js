const AWS = require('aws-sdk');
AWS.config.update({region: process.env.AWS_REGION});
const ec2 = new AWS.EC2({apiVersion: '2016-11-15'});

exports.handler = async (event) => {
    
    let tagName = event['TagName'] || process.env.DEFAULT_TAG_NAME;
    let retentionDays = event['RetentionDays'] || process.env.DEFAULT_RETENTION_DAYS;
    let minRetention = event['MinRetention'] || process.env.DEFAULT_MIN_RETENTION;
    let dryRun = event['DryRun'] || process.env.DEFAULT_DRY_RUN;
    retentionDays = parseInt(retentionDays, 10);
    minRetention = parseInt(minRetention, 10);
    dryRun = dryRun.toLowerCase() === 'true';
    
    console.log(`tagName = ${tagName}`);
    console.log(`retentionDays = ${retentionDays}`);
    console.log(`minRetention = ${minRetention}`);
    console.log(`dryRun = ${dryRun}`);
    
    let imagesInfo;
    try {
        const params = {
            Filters: [
                {
                    Name: 'tag:Name',
                    Values: [
                        tagName
                    ]
                }
            ]
        };
        imagesInfo = await ec2.describeImages(params).promise();
        
    } catch(err) {
        console.error(err);
        return {
            statusCode: 500,
            body: {
                message: err.message
            }
        };
    }
    console.log(imagesInfo);
    
    const lastDate = new Date();
    lastDate.setDate(lastDate.getDate() - retentionDays);
    let delImagesInfo = imagesInfo.Images.filter((obj) => obj.CreationDate < lastDate.toISOString());
    delImagesInfo.sort((a,b) => new Date(a.CreationDate).getTime() - new Date(b.CreationDate).getTime());
    
    const remainingImgs = imagesInfo.Images.length - delImagesInfo.length;
    const keepImgs = minRetention - remainingImgs;
    console.log(`imagesInfo.Images.length = ${imagesInfo.Images.length}`)
    console.log(`delImagesInfo.length = ${delImagesInfo.length}`)
    console.log(`keepImgs = ${keepImgs}`)
    if(keepImgs > 0) {
        delImagesInfo = delImagesInfo.slice(0, delImagesInfo.length - keepImgs);
    }
    
    console.log(delImagesInfo);
    
    const delImageIds = delImagesInfo.map((obj) => obj.ImageId);
    const delSnapshotIds = delImagesInfo.flatMap((obj) => obj.BlockDeviceMappings.map((obj2) => obj2.Ebs ? obj2.Ebs.SnapshotId : null)).filter((obj3) => obj3);

    if(!dryRun) {
        try {
            for (let i = 0; i < delImageIds.length; i++) {
                const params = {
                    ImageId: delImageIds[i],
                };
                await ec2.deregisterImage(params).promise();
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
        
        try {
            for (let i = 0; i < delSnapshotIds.length; i++) {
                const params = {
                    SnapshotId: delSnapshotIds[i],
                };
                await ec2.deleteSnapshot(params).promise();
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

    return {
        statusCode: 200,
        body: {
            delImageIds,
            delSnapshotIds,
        }
    };   
};

