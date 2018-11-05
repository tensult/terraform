const AWS = require('aws-sdk');

const ses = new AWS.SES({
    region: "eu-west-1"
});

const ec2 = new AWS.EC2();

function getEc2Instances(stateName, tagKey, tagValue) {
    const filters = [];
    if (stateName) {
        filters.push({
            Name: 'instance-state-name',
            Values: [
                stateName
            ]
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

function filterStoppableEc2InstanceIds(ec2Reservations) {
    return ec2Reservations.map((reservation) => {
        return reservation.Instances;
    }).reduce((allInstances, instancesInReservation) => {
        if (instancesInReservation) {
            allInstances = allInstances.concat(instancesInReservation);
        }
        return allInstances;
    }, []).filter((instance) => {
        return instance.Tags && instance.Tags.some((tag) => {
            if (tag.Key === "Expiry Date") {
                return new Date(tag.Value).getTime() < Date.now();
            }
            return false;
        });
    }).map((instance) => {
        return instance.InstanceId;
    })
}

function collectIdsOfEc2InstanceInstancesToBeExpired(ec2Reservations) {
    return ec2Reservations.map((reservation) => {
        return reservation.Instances;
    }).reduce((allInstances, instancesInReservation) => {
        if (instancesInReservation) {
            allInstances = allInstances.concat(instancesInReservation);
        }
        return allInstances;
    }, []).filter((instance) => {
        return instance.Tags && instance.Tags.some((tag) => {
            if (tag.Key === "Expiry Date") {
                return new Date(tag.Value).getTime() < Date.now() + 604800000;
            }
            return false;
        });
    }).map((instance) => {
        return instance.InstanceId;
    })
}

function stopRunningEc2Instances(instanceIds) {
    return ec2.stopInstances({
        InstanceIds: instanceIds
    }).promise();
}

function sendNotificationToUsers(emailBody, emailSubject) {
    let params = {
        Destination: { /* required */
            ToAddresses: [`${process.env.sesEmail}`],
            CcAddresses: process.env.notificationEmails.split(/[, ]+/)
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
        let ec2Instances = await getEc2Instances('running');

        if (!ec2Instances.Reservations || ec2Instances.Reservations === 0) {
            return;
        }

        let collectedRunningEc2InstanceIds = collectIdsOfEc2InstanceInstancesToBeExpired(ec2Instances.Reservations);
        console.log(collectedRunningEc2InstanceIds);
        if (collectedRunningEc2InstanceIds && collectedRunningEc2InstanceIds.length) {
            const alertMailBody = `Ec2 instanceIds of instaces are going to expire in a week. 
                                   Account Name : ${process.env.accountName}
                                   Id's : ${ JSON.stringify(collectedRunningEc2InstanceIds)}`;
            const alertMailSubject = "Ec2 instaces expire in a week";
            await sendNotificationToUsers(alertMailBody, alertMailSubject);
        }

        let filteredRunningEc2InstanceIds = filterStoppableEc2InstanceIds(ec2Instances.Reservations);
        console.log(filteredRunningEc2InstanceIds)
        if (filteredRunningEc2InstanceIds && filteredRunningEc2InstanceIds.length) {
            let doStopRunningEc2Instances = await stopRunningEc2Instances(filteredRunningEc2InstanceIds, ec2Regions.Regions[i].RegionName);
            console.log(doStopRunningEc2Instances);
            const notificationMailBody = `Ec2 instanceIds of terminated instances which are crossed the expired date. 
                Account Name : ${process.env.accountName}
                Id's : ${ JSON.stringify(collectedRunningEc2InstanceIds)}`;
            const notificationMailSubject = "Ec2 instances are terminated";
            await sendNotificationToUsers(notificationMailBody, notificationMailSubject);
        }
        return;
    } catch (err) {
        throw err;
    }
};