const https = require('https');

exports.handler = async (event) => {
    console.log(event);
    
    const webhookUrl = process.env.MSTEAMS_WEBHOOK_URL;
    const timeZone = process.env.TIMEZONE;
    const themeColorInfo = '0072C6';
    const themeColorAlert = 'D01536';
    
    const alarm = JSON.parse(event['Records'][0]['Sns']['Message']);
    const region = alarm['AlarmArn'].split(':')[3];
    const alarmName = alarm['AlarmName'];
    const metricUrl = encodeURI(`https://${region}.console.aws.amazon.com/cloudwatch/home?region=${region}#alarmsV2:alarm/${alarmName}?`);
    
    const title = alarmName;
    const themeColor = alarm['NewStateValue'] == 'OK' ? themeColorInfo : themeColorAlert;

    let text = '';
    text += `- **State change**: ${alarm['OldStateValue']} -> ${alarm['NewStateValue']}\n`;
    text += `- **State change reason**: ${alarm['NewStateReason'] || '-'}\n`;
    const stateChangeTime = alarm['StateChangeTime'] ? `${new Date(alarm['StateChangeTime']).toLocaleString('en-US',{ timeZone })} (${timeZone})` : '-';
    text += `- **State change time**: ${stateChangeTime}\n`;
    
    text += '- -----------------------------------------------\n';
    
    text += `- **Account ID**: ${alarm['AWSAccountId'] || '-'}\n`;
    text += `- **Region**: ${alarm['Region'] || '-'}\n`;
    
    text += '- -----------------------------------------------\n';
    
    text += '- **Trigger :: Namespace.MetricName**: ' + `${alarm['Trigger']['Namespace']}.${alarm['Trigger']['MetricName']}` + '\n';
    text += `- **Trigger :: Statistic**: ${alarm['Trigger']['Statistic'] || '-'}\n`;
    text += `- **Trigger :: Period**: ${alarm['Trigger']['Period']} seconds\n`;
    
    text += '- -----------------------------------------------\n';
    
    let desc = `- **Description**: ${alarm['AlarmDescription'] || '-'}\n`;
    
    try {
      const descObj = JSON.parse(alarm['AlarmDescription']);
      desc = '';
      for (var prop in descObj) {
        if (Object.prototype.hasOwnProperty.call(descObj, prop)) {
            desc += `- **Description :: ${prop}**: ${descObj[prop]}\n`;
        }
      }
    } catch {}
    
    text += desc;
    
    text += '- -----------------------------------------------\n';
    
    let dim = ''
    alarm['Trigger']['Dimensions'].forEach((d) => {
        dim += `- **Dimensions :: ${d['name']}**: ${d['value'] || '-'}\n`;
    });
    
    text += dim;
    
    text += '- -----------------------------------------------\n\n';
    
    text += `[OPEN IN CloudWatch Alarms](${metricUrl})`;
    
    const data = JSON.stringify({
        '@context': 'http://schema.org/extensions',
        '@type': 'MessageCard',
        'themeColor': themeColor,
        'title': title,
        'text': text,
        'potentialAction': [
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
