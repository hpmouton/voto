import ballerina/io;
import ballerinax/kafka;
import ballerina/log;

type Vote record {
    int voterID;
    int candidateID;
};

map<Vote> votes = {};


kafka:ConsumerConfiguration consumerConfigs = {
    bootstrapServers: "localhost:9092",

    groupId: "group-id",
    topics: ["voting"],

    pollingIntervalInMillis: 1000,
    autoCommit: false
};

listener kafka:Listener kafkaListener = new (consumerConfigs);
service kafka:Service on kafkaListener {
    remote function onConsumerRecord(kafka:Caller caller,
                                kafka:ConsumerRecord[] records) {
        
        foreach var kafkaRecord in records {
            processKafkaRecord(kafkaRecord);
        }

        var commitResult = caller->commit();

        if (commitResult is error) {
            log:printError("Error occurred while committing the " +
                "offsets for the consumer ", err = commitResult);
        }
    }
}


function processKafkaRecord(kafka:ConsumerRecord kafkaRecord) {
    byte[] value = kafkaRecord.value;
    string|error messageContent = string:fromBytes(value);
    if (messageContent is string) {
       json|error jsonContent = messageContent.fromJsonString();

       if(jsonContent is json){
            json|error vIDJson = jsonContent.voterID;
            json|error cIDJson = jsonContent.candidateID;

            if(vIDJson is json && cIDJson is json){
                int|error vIDInt = int:fromString(vIDJson.toString());
                int|error cIDInt = int:fromString(cIDJson.toString());

                if(vIDInt is int && cIDInt is int){

                    votes[vIDInt.toString()] = {voterID: vIDInt, candidateID:cIDInt};

                    io:println(votes);
                }
            }


       }else{
           
       }
        
    } else {
        log:printError("Invalid value type received");
    }
}