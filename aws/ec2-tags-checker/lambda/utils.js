const expiringSoonTime = 7 * 24 * 60 * 60 * 1000;
const defaultTags = {
    'name': 'string',
    'hostname': 'string',
    'os_type': 'string',
    'application': 'string',
    'project_name': 'string',
    'project_code': 'string',
    'change_no': 'string',
    'primary_owner': 'email',
    'secondary_owner': 'email',
    'provision_type': 'string',
    'provision_date': 'date',
    'expiry_date': 'date',
    'server_role': 'string',
    'business_unit': 'string',
    'snapshot': "boolean"
}

const missingTagsMailBody = (instancesOfMissingTags) => {
    return `<!DOCTYPE html>
    <html>
    <body>
    <p><font size="+2"></font>Dear User,</font></p>
    <font size="+3" color="red">Attention:</font> This is to inform you that the resource you have created does not meet the tagging - policies as per the standard followed by ${process.env.company_name}. Below are the mandatory tags that needs to be added during a fresh deployment.
    <p><font size="+1">Non-compliant servers:</font></p>
    ${prepareMailBody(instancesOfMissingTags)} 
    <p><font size="+1">Mandatory Tags List:</font></p>
    ${prepareMailBody([defaultTags])}
    <p><font size="+1">Note:</font></p>  
    1. Please make sure to add all the tags mentioned above for future deployments.<br>
    2. Please do not delete any existing tags from the machines you have access.<br>
    3. Please mention date format as "yyyy-mm-dd" to the expiray_date and provision_date tags.
    <p><font size="+1">Have a great day!</font></p>
    </body></html>`
}

const expiryInstancesMailBody = (groupedInstancesByOwner) => {
    return `<!DOCTYPE html>
    <html>
    <body>
    <p><font size="+2"></font>Dear User,</font></p>
    <font size="+3" color="red">Attention:</font> This is to inform you that the EC2 resources you have created is expiring with in 15 days. If you want to continue using the instance please make sure to change the value in “expiry_date” tag. Instance details are attached below.
    <p><font size="+1">Server Details:</font></p>
    ${prepareMailBody(groupedInstancesByOwner)} 
    <p><font size="+1">Note:</font></p>  
    1. Expired instances will be automatically stopped.<br>
    2. Please make sure to plan your activities accordingly.<br>
    3. Please reach out to CIO Team to make changes to the tag.
    <p><font size="+1">Have a great day!</font></p>
    </body></html>`
}

const expiredInstancesMailBody = (groupedInstancesByOwner) => {
    return `<!DOCTYPE html>
    <html>
    <body>
    <p><font size="+2"></font>Dear User,</font></p>
    <font size="+3" color="red">Attention:</font> This is to inform you that the resource you have created has expired. As a best practice instance is stopped to save the cost. The resource details is attached below.
    <p><font size="+1">Server Details:</font></p>
    ${prepareMailBody(groupedInstancesByOwner)} 
    <p><font size="+1">Note:</font></p>  
    1. The instance is in stopped state which will still incur the cost of storage.<br>
    2. Please reach out to CIO Team to extend the expiry date or to terminate the instance(s) if you don’t need them anymore.
    <p><font size="+1">Have a great day!</font></p>
    </body></html>`
}




//regular expression
const emailRegExp = new RegExp(/^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/);



function prepareHtml(tableBody, headers) {
    const headerElements = headers.map((header) => {
        return `<th>${header}</th>`
    })
    const tableHeader = "<tr>" + headerElements.join("\n") + "</tr>"
    return `<!DOCTYPE html>
    <html>
        <style>
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
                padding-top: 8px;
                padding-bottom: 8px;
                text-align: left;
                background-color: #4CAF50;
                color: white;
            }
            .red {
                color: red;
            }
        </style>
        <body>
            <table id="customers"> 
                ${tableHeader} 
                ${tableBody}
            </table> 
        </body>
    </html>`
}

function prepareMailBody(instances) {
    let headers = Object.keys(instances[0]);
    const rowElements = instances.map((instance) => {
        const columnElements = Object.keys(instance).map((elementKey) => {
            const elementOutput = instance[elementKey] ? instance[elementKey] : 'Not Mentioned';
            return `<td>${elementOutput}</td>`;
        });
        let fontClass = "normal";
        if (new Date(instance.expiry_date).getTime() < Date.now() + expiringSoonTime) {
            fontClass = "red";
        }
        return `<tr class="${fontClass}">` + columnElements.join('\n') + '</tr>';
    });
    return prepareHtml(rowElements.join("\n"), headers);
}

function groupInstancesByOwners(instances) {
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

function convertKeysToLowercase(tags) {
    return tags.reduce((newTags, tag) => {
        newTags[tag.Key.toLocaleLowerCase()] = tag.Value;
        return newTags;
    }, {})
}

function convertToLoweCase(string) {
    return string.toLocaleLowerCase()
}

function getRequiredInstanceInfo(instance) {
    const instanceObject = {
        account_name: undefined,
        instance_id: undefined,
        name: undefined,
        primary_owner: undefined,
        secondary_owner: undefined,
        expiry_date: undefined,
        hostname: undefined,
        change_no: undefined,
        project_code: undefined,
        ip_address: undefined
    }
    if (process.env.accountName) {
        instanceObject.account_name = process.env.accountName;
    }

    if (instance.InstanceId) {
        instanceObject.instance_id = instance.InstanceId;
    }

    if (instance.PrivateIpAddress) {
        instanceObject.ip_address = instance.PrivateIpAddress;
    }

    instance.Tags.forEach((tag) => {
        const lowerCaseTagKey = convertToLoweCase(tag.Key);
        if (tag.Value && instanceObject.hasOwnProperty(lowerCaseTagKey)) {
            instanceObject[lowerCaseTagKey] = tag.Value;
        }
    });
    return instanceObject;
}

function checkTags(tags) {
    const newTags = convertKeysToLowercase(tags);
    return Object.keys(defaultTags).every((tagName) => {
        if (newTags[tagName] && defaultTags[tagName] === "email") {
            return emailRegExp.test(newTags[tagName])
        }
        if (newTags[tagName] && defaultTags[tagName] === "date") {
            return !isNaN(new Date(newTags[tagName]))
        }
        return newTags[tagName];
    });
}

exports.checkTags = checkTags;
exports.getRequiredInstanceInfo = getRequiredInstanceInfo;
exports.groupInstancesByOwners = groupInstancesByOwners;
exports.prepareMailBody = prepareMailBody;
exports.convertKeysToLowercase = convertKeysToLowercase;
exports.convertToLoweCase = convertToLoweCase;
exports.missingTagsMailBody = missingTagsMailBody;
exports.expiryInstancesMailBody = expiryInstancesMailBody;
exports.expiredInstancesMailBody = expiredInstancesMailBody;