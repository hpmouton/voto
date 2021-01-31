import ballerina/io;
import ballerinax/kafka;
import ballerina/graphql;

//local store
type Voter record {
    string name;
    int id;
};

type Candidate record {
    string name;
    int id;
};


map<Voter> voters = {};
map<Candidate> candidates = {};



//Producer 
kafka:ProducerConfiguration producerConfiguration = {
    bootstrapServers: "localhost:9092",
    clientId: "registration",
    acks: "all",
    retryCount: 3
};


kafka:Producer kafkaProducer = checkpanic new (producerConfiguration);


service graphql:Service /graphql on new graphql:Listener(9090) {

    resource function get registerVoter(string name, int id) returns string {
        voters[id.toString()] = { name: name, id : id};

        io:println(voters);
        return "Hello, " + name;
    }


    resource function get registerCandidate(string name, int id) returns string {
        candidates[id.toString()] = { name: name, id : id};

        io:println(candidates);
        return "Hello, " + name;
    }

    resource function get castBallot(int id, int candidateID) returns string {

        var message = { voterID: id, candidateID: candidateID };
        byte[] serialisedMsg = message.toJsonString().toBytes();
        checkpanic kafkaProducer->sendProducerRecord({
                                topic: "voting",
                                value: serialisedMsg });

        checkpanic kafkaProducer->flushRecords();

        return "Hello, ";
    }
}




