# move.id - Outlier Detection in Human Activity Data

## Introduction
Final project of Informatics and Multimedia Engineering BSc.

The project titled "move.id - Outlier Detection in Human Activity Data" aims to leverage data from bands (in our case we used a phone) that are in patients at risk of falling.

By acquiring this data from these sensors, the project seeks to build representative datasets of both standard and non-standard movements. Utilizing these datasets, the project will create classifiers capable of detecting outlier movements. When such out-of-the-ordinary movements are identified by these classifiers, notifications will be sent to predefined users such as healthcare teams, via a phone application, to alert them of anomalies in the patients' movement.

This system intends to enhance patient monitoring and provide timely alerts for potential issues detected through the analysis of sensor data.

## Table of Contents 
- [Installation](#installation)
- [Usage](#usage)
- [Features](#features)
- [Project Structure](#project-structure)
- [About](#about)
- [Contacts](#contacts)

## Installation

To set up the project locally, follow these steps:

1. **Clone the repository**:
    ```sh
    git clone https://github.com/Hugana/move.id-
    ```

2. **Navigate to the project directory**:
    ```sh
    cd move.id
    ```

3. **Activate the existing virtual environment in the Django directory**:
    ```sh
    cd Django
    ```
    - On Windows:
        ```sh
        .\virtual\Scripts\activate
        ```
4. **Install the required dependencies within the virtual environment**:
    - Using the `requirements.txt` file:
        ```sh
        pip install -r requirements.txt
        ```
    - Or install the following packages individually:
        ```sh
        pip install django djangorestframework paho-mqtt psycopg2 pandas adtk
        ```

Now everything in the Django back office is configured. Let's proceed to the Flutter installation.


