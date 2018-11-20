const AWS = require('aws-sdk');
const utils = require('./utils')

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


function collectEc2InstancesWereMissingTags(ec2Reservations) {
    return ec2Reservations.map((reservation) => {
        return reservation.Instances;
    }).reduce((allInstances, instancesInReservation) => {
        if (instancesInReservation) {
            allInstances = allInstances.concat(instancesInReservation);
        }
        return allInstances;
    }, []).filter((instance) => {
        return !utils.checkTags(instance.Tags);
    }).map((instance) => {
        return utils.getRequiredInstanceInfo(instance);
    });
}


function filterStoppableEc2Instances(ec2Reservations) {
    return ec2Reservations.map((reservation) => {
        return reservation.Instances;
    }).reduce((allInstances, instancesInReservation) => {
        if (instancesInReservation) {
            allInstances = allInstances.concat(instancesInReservation);
        }
        return allInstances;
    }, []).filter((instance) => {
        return instance.Tags && instance.Tags.some((tag) => {
            if (utils.convertToLoweCase(tag.Key) === "expiry_date" && instance.State.Name === "running") {
                return new Date(tag.Value).getTime() < Date.now();
            }
            return false;
        });
    }).map((instance) => {
        return utils.getRequiredInstanceInfo(instance);
    });
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
            if (utils.convertToLoweCase(tag.Key) === "expiry_date") {
                return new Date(tag.Value).getTime() < Date.now() + 604800000;
            }
            return false;
        });
    }).map((instance) => {
        return utils.getRequiredInstanceInfo(instance);
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


async function sendNotificationsForMissingTags(ec2Instances) {
    try {
        // sending notification to admin user to know that tags were missed to the instances.
        let instancesOfMissingTags = collectEc2InstancesWereMissingTags(ec2Instances.Reservations);
        if (instancesOfMissingTags && instancesOfMissingTags.length) {
            const alertMailBody = `Summary of instances were missing tags. 
                                   Account Name : ${process.env.accountName}
                                   ${utils.prepareMailBody(instancesOfMissingTags)}`;
            const alertMailSubject = "Tags were missed to the instances";
            await sendNotificationToUsers(alertMailBody, alertMailSubject, [process.env.adminEmail]);
        }

        // sending notification to primary/secondary owner to know that tags were missed to the instances.
        let groupedInstancesByOwners = utils.groupInstancesByOwners(instancesOfMissingTags);
        const ownerEmails = Object.keys(groupedInstancesByOwners);
        if (ownerEmails && ownerEmails.length) {
            const promises = ownerEmails.map((email) => {
                const alertMailBody = `Tags were missed to the instances.. 
                                      Account Name : ${process.env.accountName}
                                      ${utils.prepareMailBody(groupedInstancesByOwners[email])}`;
                const alertMailSubject = "Tags were missed to the instances";
                return sendNotificationToUsers(alertMailBody, alertMailSubject, [email]);
            })
            await Promise.all(promises);
        }
    } catch (error) {
        throw error
    }
}

async function sendNotificationsForExpiryDate(ec2Instances) {
    try {
        // sending notification to admin user to know that instances are going to expire in a week
        let expiringInstances = collectEc2InstancesToBeExpired(ec2Instances.Reservations);
        if (expiringInstances && expiringInstances.length) {
            const alertMailBody = `Summary mail for instances are going to expire in a week. 
                                Account Name : ${process.env.accountName}
                                ${utils.prepareMailBody(expiringInstances)}`;
            const alertMailSubject = "Ec2 instances are expiring";
            await sendNotificationToUsers(alertMailBody, alertMailSubject, [process.env.adminEmail]);
        }

        // sending notification to primary/secondary owner to know that instances are going to expire in a week
        let groupedInstancesByOwners = utils.groupInstancesByOwners(expiringInstances);
        const ownerEmails = Object.keys(groupedInstancesByOwners);
        if (ownerEmails && ownerEmails.length) {
            const promises = ownerEmails.map((email) => {
                const alertMailBody = `Instances are going to expire in a week. 
                                    Account Name : ${process.env.accountName}
                                    ${utils.prepareMailBody(groupedInstancesByOwners[email])}`;
                const alertMailSubject = "Ec2 instances are expiring";
                return sendNotificationToUsers(alertMailBody, alertMailSubject, [email]);
            })
            await Promise.all(promises);
        }
    } catch (error) {
        throw error;
    }
}

async function stopInstancesByExpiryDate(ec2Instances) {
    try {
        let filteredRunningEc2Instances = filterStoppableEc2Instances(ec2Instances.Reservations);
        if (filteredRunningEc2Instances && filteredRunningEc2Instances.length) {
            const filteredRunningEc2InstanceIds = filteredRunningEc2Instances.map((instance) => {
                if (instance) {
                    return instance.instanceId;
                }
            })
            let doStopRunningEc2Instances = await stopRunningEc2Instances(filteredRunningEc2InstanceIds);
            console.log("Instances were stopped", doStopRunningEc2Instances);
            const notificationMailBody = `Ec2 instanceIds of stopped instances which are crossed the expired date. 
                    Account Name : ${process.env.accountName}
                    ${utils.prepareMailBody(filteredRunningEc2Instances)}`;
            const notificationMailSubject = "Ec2 instances are stopped";
            await sendNotificationToUsers(notificationMailBody, notificationMailSubject,[process.env.adminEmail]);
        }
    } catch (error) {
        throw error;
    }
}

exports.handler = async (event) => {
    // console.log(JSON.stringify(AWS.config));
    try {
        let ec2Instances = await getEc2Instances(['running', 'stopped']);

        if (!ec2Instances.Reservations || ec2Instances.Reservations === 0) {
            return;
        }
        await sendNotificationsForMissingTags(ec2Instances);
        await sendNotificationsForExpiryDate(ec2Instances);
        await stopInstancesByExpiryDate(ec2Instances);
        return;
    } catch (err) {
        throw err;
    }
};