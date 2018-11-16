const AWS = require('aws-sdk');

const ses = new AWS.SES({
    region: "eu-west-1"
});

const ec2 = new AWS.EC2();

function getEc2Instances(stateNames, tagKey, tagValue) {
    const filters = [];
    if (stateNames && stateNames.length) {
        filters.push({
            Name: 'instance-state-name',
            Values:
                stateNames
        });
    }
    if (tagKey) {
        const tagFilter = {
            Name: 'tag:' + tagKey
        }
        if (tagValue) {
            tagFilter.Values = [tagValue];
        }
        filters.push(tagFilter);
    }

    return ec2.describeInstances({
        Filters: filters
    }).promise();
}

function prepareHtml(table, headers) {
    let htmlBody = ``
    headers.forEach((header) => {
        htmlBody = header ? htmlBody + `<th>${header}</th>` : htmlBody;
    })
    htmlBody = "<tr>" + htmlBody + "</tr>"
    return `<!DOCTYPE html><html><style>
    #customers {
        font-family: "Trebuchet MS", Arial, Helvetica, sans-serif;
        border-collapse: collapse;
        width: 100%;
    }
    
    #customers td, #customers th {
        border: 1px solid #ddd;
        padding: 8px;
    }
    
    #customers tr:nth-child(even){background-color: #f2f2f2;}
    
    #customers tr:hover {background-color: #ddd;}
    
    #customers th {
        padding-top: 12px;
        padding-bottom: 12px;
        text-align: left;
        background-color: #4CAF50;
        color: white;
    }
    </style>
    <body><table id="customers"> ${htmlBody}${table}</table> </body></html>`
}

function prepareMailBody(instances) {
    let htmlTable = ``;
    let headers = Object.keys(instances[0]);
    instances.forEach((instance) => {
        const instanceElements = Object.keys(instance);
        instanceElements.forEach((element) => {
            htmlTable = instance[element] ? htmlTable + `<td>${instance[element]}</td>` : htmlTable + `<td>Not Mentioned</td>`;
        })
        htmlTable = '<tr>' + htmlTable + '</tr>';
    });
    return prepareHtml(htmlTable, headers);
}

function getOwnerWiseInstances(instances) {
    return instances.reduce((owner, instance) => {
        if (instance.primaryOwner) {
            owner[instance.primaryOwner] = owner[instance.primaryOwner] || [];
            owner[instance.primaryOwner].push({
                instanceId: instance.instanceId,
                expiryDate: instance.expiryDate,
                name: instance.name,
                hostName: instance.hostName,
                changeNo: instance.changeNo,
                ipAddress: instance.ipAddress,
                projectCode: instance.projectCode
            })
        }
        if (instance.secondaryOwner) {
            owner[instance.secondaryOwner] = owner[instance.secondaryOwner] || [];
            owner[instance.secondaryOwner].push({
                instanceId: instance.instanceId,
                expiryDate: instance.expiryDate,
                name: instance.name,
                hostName: instance.hostName,
                changeNo: instance.changeNo,
                ipAddress: instance.ipAddress,
                projectCode: instance.projectCode
            })
        }
        return owner;
    }, {});
}

function convertToLowerCase(str) {
    return str.toLowerCase()
}

function getMainFields(instance) {
    let mainFields = {
        instanceId: undefined,
        name: undefined,
        primaryOwner: undefined,
        secondaryOwner: undefined,
        expiryDate: undefined,
        hostName: undefined,
        changeNo: undefined,
        projectCode: undefined,
        ipAddress: undefined
    }
    instance.Tags.forEach((tag) => {
        if (instance.InstanceId) {
            mainFields.instanceId = instance.InstanceId
        }
        if (convertToLowerCase(tag.Key) === "name" && tag.Value) {
            mainFields.name = tag.Value
        }
        if (convertToLowerCase(tag.Key) === "primary_owner" && tag.Value) {
            mainFields.primaryOwner = tag.Value
        }
        if (convertToLowerCase(tag.Key) === "secondary_owner" && tag.Value) {
            mainFields.secondaryOwner = tag.Value
        }
        if (convertToLowerCase(tag.Key) === "expiry_date" && tag.Value) {
            mainFields.expiryDate = tag.Value
        }
        if (convertToLowerCase(tag.Key) === "hostname" && tag.Value) {
            mainFields.hostName = tag.Value
        }
        if (convertToLowerCase(tag.Key) === "change_no" && tag.Value) {
            mainFields.changeNo = tag.Value
        }
        if (convertToLowerCase(tag.Key) === "project_code" && tag.Value) {
            mainFields.projectCode = tag.Value
        }
        if (instance.PrivateIpAddress) {
            mainFields.ipAddress = instance.PrivateIpAddress
        }
    })
    return mainFields;
}

function collectEc2InstancesToBeExpired(ec2Reservations) {
    return ec2Reservations.map((reservation) => {
        return reservation.Instances;
    }).reduce((allInstances, instancesInReservation) => {
        if (instancesInReservation) {
            allInstances = allInstances.concat(instancesInReservation);
        }
        return allInstances;
    }, []).filter((instance) => {
        return instance.Tags && instance.Tags.some((tag) => {
            if (convertToLowerCase(tag.Key) === "expiry_date") {
                return new Date(tag.Value).getTime() < Date.now() + 604800000;
            }
            return false;
        });
    }).map((instance) => {
        return getMainFields(instance);
    });
}

function stopRunningEc2Instances(instanceIds) {
    return ec2.stopInstances({
        InstanceIds: instanceIds
    }).promise();
}

function sendNotificationToUsers(emailBody, emailSubject, emails) {
    let params = {
        Destination: { /* required */
            ToAddresses: emails || ["agnel@tensult.com", "anirudh@tensult.com"],
        },
        Message: { /* required */
            Body: { /* required */
                Html: {
                    Data: emailBody, /* required */
                    Charset: 'utf-8'
                }
            },
            Subject: { /* required */
                Data: emailSubject,
                Charset: 'utf-8'
            }
        },
        Source: `${process.env.sesEmail}`, /* required */
    }
    return ses.sendEmail(params).promise();
}


exports.handler = async (event) => {
    // console.log(JSON.stringify(AWS.config));
    try {
        let ec2Instances = await getEc2Instances(['running', 'stopped']);

        if (!ec2Instances.Reservations || ec2Instances.Reservations === 0) {
            return;
        }

        let expiringInstances = collectEc2InstancesToBeExpired(ec2Instances.Reservations);

        // sending notification to admin user to know that instances are going to expire in a week
        if (expiringInstances && expiringInstances.length) {
            const alertMailBody = `Summary mail for instaces are going to expire in a week. 
                                   Account Name : ${process.env.accountName}
                                   ${prepareMailBody(expiringInstances)}`;
            const alertMailSubject = "Ec2 instances are expiring";
            await sendNotificationToUsers(alertMailBody, alertMailSubject, [process.env.adminEmail]);
        }

        // sending notification to primary/secondary owner to know that instances are going to expire in a week
        let ownerWiseInstancesObject = getOwnerWiseInstances(expiringInstances);
        const ownerEmails = Object.keys(ownerWiseInstancesObject);
        if (ownerEmails && ownerEmails.length) {
            const promises = ownerEmails.map((email) => {
                const alertMailBody = `Instaces are going to expire in a week. 
                                       Account Name : ${process.env.accountName}
                                       ${prepareMailBody(ownerWiseInstancesObject[email])}`;
                const alertMailSubject = "Ec2 instances are expiring";
                return sendNotificationToUsers(alertMailBody, alertMailSubject, [email]);
            })
            await Promise.all(promises);
        }

        
        let filteredRunningEc2InstanceIds = filterStoppableEc2InstanceIds(ec2Instances.Reservations);
        console.log(filteredRunningEc2InstanceIds)
        if (filteredRunningEc2InstanceIds && filteredRunningEc2InstanceIds.length) {
            let doStopRunningEc2Instances = await stopRunningEc2Instances(filteredRunningEc2InstanceIds);
            console.log(doStopRunningEc2Instances);
            const notificationMailBody = `Ec2 instanceIds of terminated instances which are crossed the expired date. 
                Account Name : ${process.env.accountName}
                Id's : ${ JSON.stringify(filteredRunningEc2InstanceIds)}`;
            const notificationMailSubject = "Ec2 instances are terminated";
            await sendNotificationToUsers(notificationMailBody, notificationMailSubject);
        }
    
        return;
    } catch (err) {
        throw err;
    }
};