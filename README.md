# FIWARE Usage Control


[![FIWARE Security](https://nexus.lab.fiware.org/repository/raw/public/badges/chapters/security.svg)](https://www.fiware.org/developers/catalogue/)
![License](https://img.shields.io/github/license/ging/fiware-usage-control.svg)
[![](https://img.shields.io/badge/tag-fiware-orange.svg?logo=stackoverflow)](http://stackoverflow.com/questions/tagged/fiware)
<br/>
<!--[![Known Vulnerabilities](https://snyk.io/test/github/ging/fiware-usage-control/badge.svg?targetFile=pom.xml)](https://snyk.io/test/github/ging/fiware-usage-control?targetFile=pom.xml)-->

Usage control is a promising approach for access control in open, distributed, heterogeneous and network-connected computer environments. 
It encompasses and enhances traditional access control models, Trust Management (TM) and Digital Rights Management (DRM), and its main novelties are mutability of attributes and continuity of access decision evaluation.

Usage control encompasses Data Access control and Data Usage Control. A good representation of this concepts is shown in the next figure:

![usage-control-concept](docs/images/usage-concept.png)

**Data Access Control:**
 * Specifies who can access what resource
 * Also the rights to access it (actions)

**Data Usage Control:**
 * Ensures data sovereignty
 * Regulates what is allowed to happen with data (future use).
 * Related with data ingestion and processing
 * Context of intellectual property protection, privacy protection, compliance with regulations and digital rights management

This repository includes a set of components and operations for providing usage control capabilities over data coming from the Orion Context Broker, processed by a data streaming processing engine (Apache Flink) through the [FIWARE Cosmos Orion Flink Connector](https://github.com/ging/fiware-cosmos-orion-flink-connector). 
First, the architecture and scenario are presented, followed by the instructions and resources of how you can replicate the use case presented.


## Architecture

The next figure presents an abstract representation of the proposed architecture for usage control .
A general overview of the architecture is presented in the next figure. 
This scheme is derived from a hybrid model based on the *[Data Privacy Directive 95/46/EC](https://eur-lex.europa.eu/legal-content/en/TXT/?uri=CELEX%3A31995L0046)* and the *[IDS reference architecture](https://www.fraunhofer.de/content/dam/zv/de/Forschungsfelder/industrial-data-space/IDS_Referenz_Architecture.pdf)* 
and it is divided in three essential parts: Data Provider, Data Consumer and Data Controller.

### Three stakeholders
![usage-architecture-1](docs/images/usage-architecture-1.png)

### Two stakeholders 
In some cases, the Data Provider and Data Controller can be integrated in a single stakeholder inside the architecture. This is represented in the next figure:

![usage-architecture-2](docs/images/usage-architecture-2.png)

The different components that make up this architecture are described in detail below:

**Data Consumer:**

 * **Apache Flink Cluster**: Big Data Processing Engine in which client jobs are run. The data consumer may write real-time data processing jobs using Flink for Scala and the [FIWARE Cosmos Orion Flink Connector](https://github.com/ging/fiware-cosmos-orion-flink-connector) in order to have a direct ingestion of data from Orion in the processing engine. 

**Data Provider/Controller:**

 * **Orion Context Broker**: Component that allows to manage the entire lifecycle of context information
 * **IdM Keyrock**: Component for defining Access and Usage Control Policies
 * **PEP (Policy Enforcement Point) proxy**: Component for enforcing Access Control Policies
 * **PTP (Policy Translation Point)**: Component for translating the FI-ODRL Policies into a program that checks compliance in real time
 * **PXP/PDP (Policy Execution/Decision Point)**: Component with complex event processing capabilities (CEP) for analyzing the logs in order to verify the compliance of the obligations defined in the IDM and enforce the punishments
 
 
## Example use case: WiFi Sensors CEI Moncloa

A fully working scenario is provided in this repository, which can be easily modified in order to fit a different use case.

### Use case description

The use case proposed is based on a CEI Moncloa (Campus of International Excellence). It consists on a series of WiFi sensors that post data from each device that is near to that sensor and send different metrics  to Orion. The data provider would like to make these data available to the public. In this case the intention is to nos only consume data in local but also publish the resulting data in an Open Data portal but, only if their use of these data complies with a series of policies that both parties have agreed upon.

#### Data definition
The data involved in this scenario is represented by a wifi Entity available in Orion. This entity contains data about the WiFi sensor that is connected according to the information described in the following table:

| Header | Description                                                                 | Value (example)   |
| ------ | --------------------------------------------------------------------------- | ----------------- |
| userid | MAC address of the device sensed                                            | 60:1A:8B:92:FF:FF |
| minact | Minute when the sensor detects the presence  of the device in binary format | 101001011100011   |
| tseen  | Time in seconds that the device keeps connected                             | 900               |
| tacum  | The sum of the time that the device is connected                            | 47700             |
| visits | The number of visits that the device was connected to that sensor           | 1                 |
| act24h | The number of visits in a 24 hour period                                    | 96                |
| pwr    | The signal power of the device connected                                    | \-87              |
| oui    | Fabricant of the device connected                                           | canon             |
| ap     | MAC address of the access point in where the device is connected            | EF:94:F6:3D:DD:A2 |
| essid  | SSID if the connection point of the detected device                         | TP-LINK\_3DD0A2   |
| apwr   | The signal power of the access point                                        | \-79              |
A sample entity is presented below:

```json
{
  "id":"wifi001",
  "type":"wifi",

  "timestamp":{
    "value":"20220828132150",
    "type":"Property"
  },
  "minact":{
    "value":"101001011100011",
    "type":"Property"
  },
  "tseen":{
    "value":900,
    "type":"Property"
  },
  "tacum":{
    "value":47700,
    "type":"Property"
  },
  "visits":{
    "value":1,
    "type":"Property"
  },
  "act24h":{
    "value":96,
    "type":"Property"
  },
  "pwr":{
    "value":-87,
    "type":"Property"
  },
  "oui":{
    "value":"canon",
    "type":"Property"
  },
  "ap":{
    "value":"EF:94:F6:3D:DD:A2",
    "type":"Property"
  },
  "essid":{
    "value":"TP-LINK_3DD0A2",
    "type":"Property"
  },
  "apwr":{
    "value":-9,
    "type":"Property"
  }
}
```
The flow defined for this is case is represented by the following figure. However, for the sake of simplicity, the mqtt ingestion of the data and the publication of the data to the open data portal is suppressed.
If you want to know more about these two parts of the flow please check the [DATA AND METADATA PUBLICATION INTO CKAN](https://fiware-draco.readthedocs.io/en/latest/use_cases/ckan_publication/index.html)

![cei-moncloa-data-flow](docs/images/cei-moncloa-data-flow.png)


#### Defining policies

The policies that the data provider wants to enforce on the data are the following:

 * The user shall **NOT** save the data without anonymize the data first or else the processing job will be terminated.

 * The user shall **NOT** save the data without removing the sensitive data or else the processing job will be terminated.
 
 
The data provider has to define these policies using the web interface that KeyRock provides. 

![Keyrock creating policies](docs/images/usage-idm.png)


When the data provider creates these policies in KeyRock and applies them to a certain user, KeyRock translates them into the ODRL language.
 ```json
{
  "@context": [
    "http://www.w3.org/ns/odrl.jsonld",
    "http://keyrock.fiware.org/FIDusageML/profile/FIDusageML.jsonld"
  ],
  "@type": "Set",
  "uid": " http://keyrock.fiware.org/FIDusageML/policy:1020",
  "profile": "http://keyrock.fiware.org/FIDusageML/profile",
  "permission": [{
    "target": "http://orion.fiware.org/NGSIkilljob", "action": "ReadNGSIWindow",
    "constraint": [
      {
        "leftOperand":"Anonimyze",
        "operator": "gt",
        "rightOperand": {
          "@value": "Sink",
          "@type": "xsd:String"
        }
      },
      {
        "leftOperand": "RemoveSensitive",
        "operator": "gt",
        "rightOperand": {
          "@value": "userId",
          "@type": "xsd:integer" }
      }]
  }],
  "prohibition": [
    {
      "target":  "http://orion.fiware.org/NGSIkilljob",
      "action": "DataProtection"  }]
}
 ```
 
KeyRock notifies the PTP that a new policy has to be enforced. A CEP program is generated from the FI-ODRL policy definition through an extended automata.
The policies defined in this example would turn into the following CEP code excerpt:

```scala
 // First pattern: At least N events in T. Any other time
val anonymizePattern = Pattern.begin[ExecutionGraph]
("start", AfterMatchSkipStrategy.skipPastLastEvent())
  .where(Policies.executionGraphChecker(_, "source"))
  .notFollowedBy("middle")
  .where(Policies.executionGraphChecker(_,"anonymize",Policies.aggregateTime))
  .followedBy("end")
  .where(Policies.executionGraphChecker(_, "sink"))
  .timesOrMore(1)
CEP.pattern(operationStream, anonymizePattern).select(events =>
  Signals.createAlert(Policy.AGGREGATION_POLICY, events, Punishment.KILL_JOB))

// Second pattern: Source -> Sink. Aggregation TimeWindow
val removeSensitivePattern = Pattern.begin[ExecutionGraph]
("start", AfterMatchSkipStrategy.skipPastLastEvent())
  .where(Policies.executionGraphChecker(_, "source"))
  .notFollowedBy("remove")
  .where(Policies.executionGraphChecker(_,"removeSensitive",Policies.aggregateTime))
  .followedBy("end")
  .where(Policies.executionGraphChecker(_, "sink"))
  .timesOrMore(1)
CEP.pattern(operationStream, removeSensitivePattern).select(events =>
  Signals.createAlert(Policy.AGGREGATION_POLICY, events, Punishment.KILL_JOB))

```

The generated CEP program is deployed and receives the logs from the user processing engine:
 * **Execution Graph Logs**: Chain of operations performed by the data user
 * **Event Logs**: NGSI Events received by the data user coming from Orion
 
#### The data user program

The data user wants to extract value in real-time from the data received. Specifically, he/she is interested in knowing what the average of visits of some device that is conected to the WiFi sensor  every hour. 
In order to achieve this, he/she may write a job like such:

```scala
val env = StreamExecutionEnvironment.getExecutionEnvironment

// Create Orion Source. Receive notifications on port 9001
val eventStream = env.addSource(new OrionSource(9001))

// Process event stream
val processedDataStream = eventStream
  .flatMap(event => event.entities)
  .map(entity => {
    val id = entity.attrs("_id").value.toString
    val items =   entity.attrs("visits").asInstanceOf[Number].floatValue()
    WifiSensor(id, visits)
  })

  .map(_.map(_.visits).sum)
  .timeWindowAll(Time.minutes(60))
  .aggregate(new AverageAggregate)
// Print the results with a single thread, rather than in parallel
processedDataStream.print().setParallelism(1)
env.execute("WiFi Job")

```

The Flink job must be compiled into a JAR file. Maven will download all the necessary dependencies to build the JAR, except for the Cosmos connector. You need to [download](https://github.com/ging/fiware-cosmos-orion-flink-connector/releases/latest) it and install it manually:

```
mvn install:install-file -Dfile=$(PATH_DOWNLOAD)/orion.flink.connector-1.2.2.jar -DgroupId=org.fiware.cosmos -DartifactId=orion.flink.connector -Dversion=1.2.2 -Dpackaging=jar
```
Once compiled, the job can be deployed on the Flink Client Cluster using the provided web UI. As soon as the job is deployed, the Execution Graph logs and the NGSI Event logs start to be sent to the PDP/PXP, who verifies that policies are being complied with an enforces punishments if they are not.
  

#### Monitoring policy enforcement

The data provider has to be aware of when data consumers are not complying with the established policies. 
For this task, a control panel is provided in which all the events regarding policies can be checked in real-time, as well as a series of statistics on data usage.

![FIWARE Data Usage Control Panel](docs/images/usage-panel.png)

### Deployment
#### Agents involved
The scenario presented in this repository is composed by a series of building blocks which can be easily replicated using the provided docker-compose file. It consists of the following containers:

**Data Provider/Data Consumer:**

 * An **Apache Flink** Cluster (1 Job Manager and 1 Task Manager) 
 * A **Streaming Job** for making the aggregations and operations of some values of a notified Entity created in the Orion Context Broker

**Data Controller:**
 
 * One **Orion** (with MongoDB) instance 
 * One **IdM Keyrock** instance
 * One **PEP proxy** instance 
 * One **PTP (Policy Translation Point)** instance
 * One **Data Usage Control Panel** web application instance for monitoring the usage control rules and punishments in real-time
 * One **PXP/PDP (Policy Execution/Decision Point)** instance based on Apache Flink 
 * One container with a **supermarket tickets database** posting data to the Orion Context Broker

![usage-scenario](docs/images/usage-scenario.png) 


For deploying and running this scenario you need to have docker and docker-compose

1. Clone the repository
```bash
git clone https://github.com/YourOpenDAta/duc-cei-moncloa.git
```
2. Access the root directory
```bash
cd duc-cei-moncloa
```

#### Data Controller
For deploying the Data Usage Control components of the Data Provider-Controller side run containers 
defined in the `docker-compose.yml` file with their respective ENV variables

3. Run containers
```bash
sudo docker-compose up -d
```
4. Check if all the containers are running
```bash
sudo docker ps
```

5. Grant the execution rights to the script files:
```bash
chmod a+x entityWifi.sh subscriptionWifi.sh updateEntity.sh
```
5. Create the orion Entity
```bash
./entityWifi.sh
```
6. Check the orion entities
```bash
curl localhost:1026/v2/entities -s -S --header 'Accept: application/json' | python -mjson.tool
```
7. Create the Subcriotionn to the orion WiFi Entity
```bash
./subscriptionWifi.sh
```
7. Run the update entity script to emulate the WiFi sensor readings.
```bash
./updateEntity.sh
```
#### Data Provider/ Consumer

Now, for deploying the component on the Data Consumer side, follow the next steps:

1. Go to the `flink` folder
```bash
cd flink
```
2. Deploy the Flink Cluster
```bash
sudo docker-compose up -d
```
3. Check if all the containers are running
```bash
sudo docker ps
```


Once you have everything up and running, you can go on to follow the demo video for the next steps.

**[Demo Video](#) (TODO)**
