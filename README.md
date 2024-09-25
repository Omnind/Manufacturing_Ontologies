# Manufacturing Ontologies

## Content
- [Note](https://github.com/Omnind/Manufacturing_Ontologies/blob/main/README.md#note)
- [Introduction](https://github.com/Omnind/Manufacturing_Ontologies?tab=readme-ov-file#introduction)
- [ADT Generation tool for ISA95](https://github.com/Omnind/Manufacturing_Ontologies?tab=readme-ov-file#adt-generation-tool-for-isa95)
- [License](https://github.com/Omnind/Manufacturing_Ontologies?tab=readme-ov-file#license)

## Note

The reference solution previously in this repository is now hosted on the Microsoft Learn platform, and you can access it [here](https://learn.microsoft.com/en-us/azure/iot/concepts-iot-industrial-solution-architecture) for streamlined guidance on Azure-based business implementations.


## Introduction

An ontology provides a standardized framework for describing systems within the manufacturing sector. These systems may include individual factories, enterprise applications, or entire supply chains. The manufacturing industry has developed several well-established ontologies, most of which have been widely standardized to ensure consistency and interoperability across different applications. In this repository, we have focused on ISA95 to describe a factory ontology. The ontologies are available [here](https://github.com/Omnind/Manufacturing_Ontologies/tree/main/Ontologies).

### Digital Twin Definition Language

The ontologies in this repository utilize the Digital Twin Definition Language (DTDL), providing a standardized framework for digital twin descriptions. You can find the DTDL specification [here](https://github.com/Azure/opendigitaltwins-dtdl/blob/master/DTDL/v2/DTDL.v2.md).

### W3C Web of Things

The ontologies also integrate the W3C Web of Things (WoT) standards, enhancing interoperability across IoT devices and platforms. The WoT specification is available [here](https://www.w3.org/TR/wot-thing-description/), and the ontologies were generated using an open-source DTDL-WoT conversion tool, which you can access [here](https://github.com/web-of-things-open-source/wot-dtdl-converter). A comparison of DTDL and WoT and their interoperability is discussed [here](https://github.com/Omnind/Manufacturing_Ontologies/blob/main/comparison.md).

### International Society of Automation 95 (ISA95/IEC 62264)

This solution also incorporates ISA95 / IEC 62264 standards, which are widely recognized in the manufacturing industry for integrating enterprise and control systems. For more details, refer to the descriptions [here](https://en.wikipedia.org/wiki/ANSI/ISA-95) and [here](https://en.wikipedia.org/wiki/IEC_62264).


## ADT Generation tool for ISA95

<img src="Docs/generator.png" width="900" />

### Overview

We provided a tool that can load an Excel file to simplify the creation of a digital twin graph in Azure Digital Twins service leveraging the ISA95 ontology. The source code of the app can be easily integrated into a console app, should you want to make this tool part of an end-to-end DevOps pipeline.

### UA Cloud Twin

The tool makes use of the UA Cloud Twin also available from the Digital Twin Consortium [here](https://github.com/digitaltwinconsortium/UA-CloudTwin). It uploads the ISA95 ontology models to Azure Digital Twins service. This step is required before the tool works. Simply follow the installation steps as described [here](https://github.com/digitaltwinconsortium/UA-CloudTwin?tab=readme-ov-file#installation) to upload the models.

### The main components of the tool

- MainForm contains the UI and main logic of the application
- ADTHelper centralizes API calls to ADT
- JSONHelper parses the configuration file
- Isa95-test.xlsx is the Excel file to start with a first ISA95 digital twin graph

### Getting started

1. Navigate to the `./Tools/ADTGenerator/binaries` directory of the extracted repository and run 'ADTGenerator`.

1. Provide the URL of your ADT instance, then select `Test`, to validate the URL.

<img src="Docs/Picture1.png" width="900" />

Note: Select `Save Config` to persist the URL of your ADT instance.

1. Load the Excel file (use the isa95-test.xlsx provided with the tool to get started).

<img src="Docs/Picture2.png" width="900" />

1. Before starting the graph generation, you must select the Excel worksheets you are going to use for ADT digital twins and relationships generation. In our case we will select `Physical Asset & Equipment` and `Relationships`.
1. Select `Generate Graph` to process your Excel document. This will generate the digital twins and relationships in your ADT instance.

<img src="Docs/Picture3.png" width="900" />

1. Open ADT Explorer for your ADT instance, you should see a digital twin graph similar to this:

<img src="Docs/Picture4.png" width="900" />

### Adding digital twins

You can add columns to the Excel file to add additional digital twins.

We recommend creating different worksheets (one for assets, one for process definition, etc.) to reduce the combination of columns to fill in. 

Select one worksheet at the time to generate the graph as explained in the Getting started section.

Check the `Show advanced properties and action` box to display indicies used by the tool:

- `First Metadata column` is the index of the first column used in the digital twins worksheet to generate twins. You can create as many columns as you need. It's important that the `First Metadata column` and the following column the following is keept in place:
  - TwinID
  - ModelID
    
- `First Property column` is the index of the first column used in the digital twins worksheet to set all the properties relevant for your digital twins. The tool expects to find, for each property, the property name in row 2, the property type in row 3 and the value of the property in each row.

There are different technical sheets to simplify data preparation:

`Components & Properties` is a direct projection of the ISA95 ontology, containing, for each model:

- The category (PhysicalAssetAndEquipment, Material, OperationsDefinition, etc.)
- The Short model name (Equipment, JobOrder, etc.)
- The model ID (dtmi:digitaltwins:isa95:Equipment;1)
- The components included in the model (mandatory information to create twins)
- 'x' value in columns associated with properties declared in the model

`UI` is the sheet used for data validation in the rest of the document.

`Physical Asset & Equipment` is a good starting point to extend what you already generated in the Getting started section:

- Columns A to F are used to simplify the hierarchy of twins related to the model structure (Equipment). You can modify these columns to fit your needs.
- Column G is for the TwinID
- In column H specifies the twin model (from the UI sheet)
- The tool uses the 'x' information set in the `Components & Properties` sheet to apply conditional formatting from columns I to the end (depending on properties relevant for the models). If the cell is greyed-out, don't enter a value.

<img src="Docs/Picture5.png" width="900" />


## License

This project uses materials from the **Manufacturing Ontologies repository** by the Digital Twin Consortium, available under the [CC BY 4.0 license](http://creativecommons.org/licenses/by/4.0/). The original project can be found [here](https://github.com/digitaltwinconsortium/ManufacturingOntologies). Changes have been made to adapt the materials for our specific use case.

<a rel="license" href="http://creativecommons.org/licenses/by/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by/4.0/88x31.png" /></a>

This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by/4.0/">Creative Commons Attribution 4.0 International License</a>.



