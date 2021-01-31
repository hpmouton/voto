import ballerina/io;
import ballerina/http;

http:Client clientEndpoint = check new ("http://localhost:9090");

public function main() {
    io:println("What would you like to do?");

    io:println("1. Register a voter \n " 
    + "2. Register a candidate \n"
    + "3. Vote \n"
    + "4. Get results");

    // var  response = clientEndpoint->post("/graphql",{ query: " { registerVoter(name: \"jim\", id: 11122) }" });
    // if (response is  http:Response) {
    //     var jsonResponse = response.getJsonPayload();

    //     if (jsonResponse is json) {
            
    //         io:println(jsonResponse.data.greet);
    //     } else {
    //         io:println("Invalid payload received:", jsonResponse.message());
    //     }

    // }

     var  response = clientEndpoint->post("/graphql",{ query: " { castBallot(id: 6, candidateID: 11122) }" });
    if (response is  http:Response) {
        var jsonResponse = response.getJsonPayload();

        if (jsonResponse is json) {
            
            io:println(jsonResponse.data);
        } else {
            io:println("Invalid payload received:", jsonResponse.message());
        }

    }
    


}
