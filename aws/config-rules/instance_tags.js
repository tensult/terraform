'use strict';

const AWS = require('aws-sdk');

const config = new AWS.ConfigService();
const ses = new AWS.SES({
    region: "eu-west-1"
});

const defaultTags = {
    'Name': 'string',
    'HostName': 'string',
    'OS Type': 'string',
    'Application': 'string',
    'Project Name': 'string',
    'Project Code': 'string',
    'Change No': 'string',
    'Primary owner': 'email',
    'Secondary owner': 'email',
    'Provision Type': 'string',
    'Provision Date': 'date',
    'Expiry Date': 'date',
    'Server Role': 'string',
    'Business Unit': 'string'
}

//regular expression
const emailRegExp = new RegExp(/^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/);


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
    })
}

function putEvaluations(configurationItem, compliance, resultToken) {
    // Initializes the request that contains the evaluation results.
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

// Check whether the resource has been deleted. If the resource was deleted, then the evaluation returns not applicable.
function isApplicable(configurationItem, event) {
    checkDefined(configurationItem, 'configurationItem');
    checkDefined(event, 'event');
    const status = configurationItem.configurationItemStatus;
    const eventLeftScope = event.eventLeftScope;
    return (status === 'OK' || status === 'ResourceDiscovered') && eventLeftScope === false;
}


function checkTags(tags) {
    return Object.keys(defaultTags).every((tagName) => {
        if (tags[tagName] && defaultTags[tagName] === "email") {
            return emailRegExp.test(tags[tagName])
        }
        if (tags[tagName] && defaultTags[tagName] === "date") {
            return !isNaN(new Date(tags[tagName]))
        }
        return tags[tagName];
    });
}

// In this example, the resource is compliant if it is an instance and its type matches the type specified as the desired type.
// If the resource is not an instance, then this resource is not applicable.
function evaluateChangeNotificationCompliance(configurationItem) {
    checkDefined(configurationItem, 'configurationItem');
    checkDefined(configurationItem.configuration, 'configurationItem.configuration');

    if (configurationItem.resourceType !== 'AWS::EC2::Instance') {
        return 'NOT_APPLICABLE';
    } else if (checkTags(configurationItem.tags)) {
        return 'COMPLIANT';
    }
    return 'NON_COMPLIANT';
}

function sendNotificationToUsers(body, emails) {    
    let params = {
        Destination: { /* required */
            ToAddresses: [`${process.env.sesEmail}`],
        },
        Message: { /* required */
            Body: { /* required */
                Html: {
                    Data: `Ec2 instances which are missing tags : ${ JSON.stringify(body)}`, /* required */
                    Charset: 'utf-8'
                }
            },
            Subject: { /* required */
                Data: "Add tags",
                Charset: 'utf-8'
            }
        },
        Source: `${process.env.sesEmail}`, /* required */
    }
    if(emails && emails.length) {
        params.Destination.CcAddresses = emails;
    }

    return ses.sendEmail(params).promise();
}

function prepareEmailBody(configurationItem) {
    const body = {
        "accountId": configurationItem.accountId,
        "accountName": `${process.env.accountName}`,
        "resourceType": configurationItem.resourceType,
        "resourceId": configurationItem.resourceId,
        "resourceName": configurationItem.resourceName,
        "tags": configurationItem.tags
    }
    return body;
}

function fetchEmails(configurationItem) {
    let emails = []
    if (configurationItem.tags) {
        if (configurationItem.tags["Primary owner"]) {
            emails.push(configurationItem.tags["Primary owner"]);
        }
        if (configurationItem.tags["Secondary owner"]) {
            emails.push(configurationItem.tags["Secondary owner"]);
        }
    }
    return emails;
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
        console.log(putEvaluationsResponse);
        if (compliance === "NON_COMPLIANT") {
            const emailBody = prepareEmailBody(configurationItem);
            const emails = fetchEmails(configurationItem);
            await sendNotificationToUsers(emailBody, emails);
        }
    } catch (err) {
        throw err;
    }
}
