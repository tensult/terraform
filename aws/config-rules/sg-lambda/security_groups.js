'use strict';

const AWS = require('aws-sdk');
const utils = require('./utills');

const config = new AWS.ConfigService();
const ses = new AWS.SES({
    region: "eu-west-1"
});

const defaultRules = {
    22: 'restricted',
    80: 'public',
    443: 'public',
    1433: 'restricted',
    3306: 'restricted',
    3389: 'restricted'
}

// Helper function used to validate input
function checkDefined(reference, referenceName) {
    if (!reference) {
        throw new Error(`Error: ${referenceName} is not defined`);
    }
    return reference;
}

// Check whether the message type is OversizedConfigurationItemChangeNotification,
function isOverSizedChangeNotification(messageType) {
    checkDefined(messageType, 'messageType');
    return messageType === 'OversizedConfigurationItemChangeNotification';
}

// Get the configurationItem for the resource using the getResourceConfigHistory API.
function getConfiguration(resourceType, resourceId, configurationCaptureTime) {
    return config.getResourceConfigHistory({
        resourceType,
        resourceId,
        laterTime: new Date(configurationCaptureTime),
        limit: 1
    }).promise().then((data) => {
        return data.configurationItems[0];
    });
}
function putEvaluations(configurationItem, compliance, resultToken) {
    const putEvaluationsRequest = {};
    putEvaluationsRequest.Evaluations = [{
        ComplianceResourceType: configurationItem.resourceType,
        ComplianceResourceId: configurationItem.resourceId,
        ComplianceType: compliance,
        OrderingTimestamp: configurationItem.configurationItemCaptureTime,
    },];
    putEvaluationsRequest.ResultToken = resultToken;
    return config.putEvaluations(putEvaluationsRequest).promise();
}

// Based on the message type, get the configuration item either from the configurationItem object in the invoking event or with the getResourceConfigHistory API in the getConfiguration function.
async function getConfigurationItem(invokingEvent) {
    try {
        checkDefined(invokingEvent, 'invokingEvent');
        if (isOverSizedChangeNotification(invokingEvent.messageType)) {
            const configurationItemSummary = checkDefined(invokingEvent.configurationItemSummary, 'configurationItemSummary');
            const apiConfigurationItem = await getConfiguration(configurationItemSummary.resourceType, configurationItemSummary.resourceId, configurationItemSummary.configurationItemCaptureTime);
            const configurationItem = convertApiConfiguration(apiConfigurationItem);
            return configurationItem;
        } else {
            checkDefined(invokingEvent.configurationItem, 'configurationItem');
            return invokingEvent.configurationItem;
        }
    } catch (err) {
        throw err;
    }
}


// Convert the oversized configuration item from the API model to the original invocation model.
function convertApiConfiguration(apiConfiguration) {
    apiConfiguration.AWSAccountId = apiConfiguration.accountId;
    apiConfiguration.ARN = apiConfiguration.arn;
    apiConfiguration.configurationStateMd5Hash = apiConfiguration.configurationItemMD5Hash;
    apiConfiguration.configurationItemVersion = apiConfiguration.version;
    apiConfiguration.configuration = JSON.parse(apiConfiguration.configuration);
    if ({}.hasOwnProperty.call(apiConfiguration, 'relationships')) {
        for (let i = 0; i < apiConfiguration.relationships.length; i++) {
            apiConfiguration.relationships[i].name = apiConfiguration.relationships[i].relationshipName;
        }
    }
    return apiConfiguration;
}

// Check whether the resource has been deleted. If the resource was deleted, then the evaluation returns not applicable.
function isApplicable(configurationItem, event) {
    checkDefined(configurationItem, 'configurationItem');
    checkDefined(event, 'event');
    const status = configurationItem.configurationItemStatus;
    const eventLeftScope = event.eventLeftScope;
    return (status === 'OK' || status === 'ResourceDiscovered') && eventLeftScope === false;
}

function checkPortPermission(port, ipRanges) {
    if (!defaultRules[port]) {
        return false;
    } else if (defaultRules[port] === 'restricted') {
        return !ipRanges.some((ipRange) => {
            return ipRange === '0.0.0.0/0';
        });
    }
    return true;
}

function checkIpPermission(ipPermission) {
    for (let i = ipPermission.fromPort; i <= ipPermission.toPort; i++) {
        if (!checkPortPermission(i, ipPermission.ipRanges)) {
            return false;
        }
    }
    return true;
}

function checkIpPermissions(ipPermissions) {
    return ipPermissions.every(checkIpPermission);
}

// In this example, the resource is compliant if it is an instance and its type matches the type specified as the desired type.
// If the resource is not an instance, then this resource is not applicable.
function evaluateChangeNotificationCompliance(configurationItem) {
    checkDefined(configurationItem, 'configurationItem');
    checkDefined(configurationItem.configuration, 'configurationItem.configuration');

    if (configurationItem.resourceType !== 'AWS::EC2::SecurityGroup') {
        return 'NOT_APPLICABLE';
    } else if (checkIpPermissions(configurationItem.configuration.ipPermissions)) {
        return 'COMPLIANT';
    }
    return 'NON_COMPLIANT';
}

//send email using aws ses service 
function sendNotificationToUsers(body, subject) {
    let params = {
        Destination: { /* required */
            ToAddresses: [`${process.env.adminEmail}`],
        },
        Message: { /* required */
            Body: { /* required */
                Html: {
                    Data: body, /* required */
                    Charset: 'utf-8'
                }
            },
            Subject: { /* required */
                Data: subject,
                Charset: 'utf-8'
            }
        },
        Source: `${process.env.sesEmail}`, /* required */
    }
    return ses.sendEmail(params).promise();
}

function getEmailBody(configurationItem) {
    const resourceObject = {
        "accountName": `${process.env.accountName}`,
        "instanceType": configurationItem.resourceType,
        "securityGroupId": configurationItem.resourceId,
        "securityName": configurationItem.resourceName
    }
    return utils.securityGroupMailBody([resourceObject]);
}



// Receives the event and context from AWS Lambda.
exports.handler = async (event) => {
    try {
        checkDefined(event, 'event');
        const invokingEvent = JSON.parse(event.invokingEvent);
        const configurationItem = await getConfigurationItem(invokingEvent);
        let compliance = 'NOT_APPLICABLE';
        if (isApplicable(configurationItem, event)) {
            // Invoke the compliance checking function.
            compliance = evaluateChangeNotificationCompliance(configurationItem);
        }
        // Sends the evaluation results to AWS Config.
        const putEvaluationsResponse = await putEvaluations(configurationItem, compliance, event.resultToken);
        console.log(JSON.stringify(putEvaluationsResponse,null,2));
        if (compliance === "NON_COMPLIANT") {
            const alertMailBody = getEmailBody(configurationItem);
            const alertMailSubject = "Alert: Security Group Ports";
            await sendNotificationToUsers(alertMailBody,alertMailSubject);
        }
    } catch (err) {
        throw err;
    }
}