const https = require('https');

exports.handler = async (event) => {

    const webhookUrl = process.env.GCHAT_WEBHOOK_URL;
    const imgAlertUrl = process.env.GCHAT_CARD_IMG_ALERT_URL;
    const imgOkUrl = process.env.GCHAT_CARD_IMG_OK_URL;
    const timeZone = process.env.TIMEZONE;

    const alarm = JSON.parse(event['Records'][0]['Sns']['Message']);
    const region = alarm['AlarmArn'].split(':')[3];
    const alarmName = alarm['AlarmName'];
    const metricUrl = `https://${region}.console.aws.amazon.com/cloudwatch/home?region=${region}#alarmsV2:alarm/${alarmName}?`;
    
    let desc = [
                {
                  "keyValue": {
                    "topLabel": `Description`,
                    "content": alarm['AlarmDescription'] || '-'
                  }
                }
              ];
    try {
      const descObj = JSON.parse(alarm['AlarmDescription']);
      desc = [];
      for (var prop in descObj) {
        if (Object.prototype.hasOwnProperty.call(descObj, prop)) {
          desc.push({
                  "keyValue": {
                    "topLabel": `Description :: ${prop}`,
                    "content": descObj[prop]
                  }
                });
        }
      }
    } catch {}
          
    const data = JSON.stringify({
      "cards": [
        {
          "header": {
            "title": alarmName,
            "subtitle": `${alarm['OldStateValue']} -> ${alarm['NewStateValue']}`,
            "imageUrl": alarm['NewStateValue'] == 'OK' ? imgOkUrl : imgAlertUrl,
            "imageStyle": 'IMAGE'
          },
          "sections": [
            {
              "widgets": [
                {
                  "textParagraph": {
                    "text": alarm['NewStateReason'] || null
                  }
                }
              ]
            },
            {
              "widgets": [
                {
                  "keyValue": {
                    "topLabel": "StateChangeTime",
                    "content": alarm['StateChangeTime'] ? `${new Date(alarm['StateChangeTime']).toLocaleString('en-US',{ timeZone })} (${timeZone})` : null
                  }
                },
                {
                  "keyValue": {
                    "topLabel": "AccountID",
                    "content": alarm['AWSAccountId'] || null
                  }
                },
                {
                  "keyValue": {
                    "topLabel": "Region",
                    "content": alarm['Region'] || null
                  }
                }
              ]
            },
            {
              "widgets": [
                {
                  "keyValue": {
                    "topLabel": "Trigger :: Namespace.MetricName",
                    "content": `${alarm['Trigger']['Namespace']}.${alarm['Trigger']['MetricName']}`
                  }
                },
                {
                  "keyValue": {
                    "topLabel": "Trigger :: Statistic",
                    "content": alarm['Trigger']['Statistic'] || null
                  }
                },
                {
                  "keyValue": {
                    "topLabel": "Trigger :: Period",
                    "content": `${alarm['Trigger']['Period']} seconds`
                  }
                },
              ]
            },
            {
              "widgets": desc
            },
            {
              "widgets": alarm['Trigger']['Dimensions'].map((d) => {
                return { 
                  "keyValue": {
                    "topLabel": `Dimensions :: ${d['name']}`,
                    "content": d['value'] || null
                  }
                };
              })
            },
            {
              "widgets": [
                {
                  "buttons": [
                    {
                      "textButton": {
                        "text": "OPEN IN CloudWatch Alarms",
                        "onClick": {
                          "openLink": {
                            "url": metricUrl
                          }
                        }
                      }
                    }
                  ]
                }
              ]
            }
          ]
        },
      ]
    });

    const options = {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': data.length
      }
    }
    
    console.log(data);

    const response = await new Promise((resolve, reject) => {
        const req = https.request(webhookUrl, options, (res) => {
          if (res.statusCode < 200 || res.statusCode > 299) {
            return reject(new Error(`HTTP status code ${res.statusCode}`))
          }
    
          const body = []
          res.on('data', (chunk) => body.push(chunk))
          res.on('end', () => {
            const resString = Buffer.concat(body).toString();
            resolve({
                statusCode: 200,
                body: JSON.stringify(JSON.parse(resString))
            });
          });
        });
        
        req.on('error', (e) => {
          reject({
              statusCode: 500,
              body: 'Something went wrong!'
          });
        });
        
        req.write(data);
        req.end();
    });
    
    return response;
};

