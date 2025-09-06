# Tools used in the project
The following lists the tools and frameworks, that are used in the project. 
- [Docker](https://docs.docker.com/get-started/overview/)    
   Docker is an open platform for developing, shipping, and running applications. Docker enables you to separate your applications from your infrastructure so you can deliver software quickly. With Docker, you can manage your infrastructure in the same ways you manage your applications. By taking advantage of Docker's methodologies for shipping, testing, and deploying code, you can significantly reduce the delay between writing code and running it in production.
- [Kubernetes](https://kubernetes.io/docs/concepts/overview/)
	- Automation of Software and managing containers for server clusters
- [FastAPI](https://fastapi.tiangolo.com/tutorial/)
	- Framework for HTPP-API usage
- [SQLAlchemy](https://docs.sqlalchemy.org/en/20/orm/quickstart.html)
	- Library for accessing Databases and using SQL in Python
- [FastAPI with SQLAlchemy](https://fastapi.tiangolo.com/tutorial/sql-databases/)
	- Compatibility between FastAPI and SQLAlchemy
- [Alembic](https://alembic.sqlalchemy.org/en/latest/tutorial.html)
	- "**Alembic** **is** a tool for creating, managing, and invoking change scripts for a relational database using SQLAlchemy as the engine"
- [Swagger UI](https://swagger.io/tools/swagger-ui/)
	- Generates the Interactive UI for our API *(localhost:8000/docs)*

# GitLab CI/CD

The following is a collection of short hints on how to do the most essential things in a GitLab CI/CD pipeline:
- How to delay a job until another job is done:\
  need
- How to change the image used in a task:\
	image:	    
- How do you start a task manually:\
	when: manual
- The Script part of the config file - what is it good for?\
	to say what it should execute in the Containers
- If I want a task to run for every branch I put it into the stage ??\
	kein only
- If I want a task to run for every merge request I put it into the stage ??\
	only: merge
- If I want a task to run for every commit to the main branch I put it into the stage ??\
	only: main
# flake8 / flakeheaven

- What is the purpose of flake8?\
	to check for a correct non critical syntax
- What types of problems does it detect\
    non critical syntax errors
- Why should you use a tool like flake8 in a serious project?\
	to keep the code always the same

## Run flake8 on your local Computer

  It is very annoying (and takes a lot of time) to wait for the pipeline to check the syntax 
  of your code. To speed it up, you may run it locally like this:

### Configure PyCharm (only once)
- find out the name of your docker container containing flake8. Open the tab *services* in PyCharm and look at the container in the service called *web*. The name should contain the string *1337_pizza_web_dev*.  
- select _Settings->Tools->External Tools_ 
- select the +-sign (new Tool)
- enter Name: *Dockerflake8*
- enter Program: *docker*
- enter Arguments (replace the first parameter with the name of your container): 
    *exec -i NAMEOFYOURCONTAINER flakeheaven lint /opt/project/app/api/ /opt/project/tests/*
- enter Working Directory: *\$ProjectFileDir\$*

If you like it convenient: Add a button for flake8 to your toolbar!
- right click into the taskbar (e.g. on one of the git icons) and select *Customize ToolBar*
- select the +-sign and Add Action
- select External Tools->Dockerflake8

### Run flake8 on your project
  - Remember! You will always need to run the docker container called *1337_pizza_web_dev* of your project, to do this! 
    So start the docker container(s) locally by running your project
  - Now you may run flake8 
      - by clicking on the new icon in your toolbar or 
      - by selecting from the menu: Tools->External Tools->Dockerflake8 

# GrayLog

- What is the purpose of GrayLog?
  - It serves the purpose of having a centralized Platform for containg logs. These can be collected, analysed and visualized.
- What logging levels are available?
  - DEBUG (Verbose): Detailed info for debugging.
  - INFO: General information.
  - WARNING: Indicates a potential issue.
  - ERROR: A serious issue preventing a task.
  - FATAL: A fatal error which stop the program unexpected.
- What is the default logging level?
  - INFo
- Give 3-4 examples for logging commands in Python:
  ```python  
  import logging
  
  logging.info("Info message")
  logging.warning("Warning message")
  logging.error("Error message")
  ```

# SonarQube

## What is the purpose of SonarQube?

SonarQube is a platform consisting of a set of tools designed to help developers build quality software. 
This includes 
- catching issues in development early
- enforcing coding style and conventions
- measuring technical debt
- monitoring of overall project quality and development over time

## What is the purpose of the quality rules of SonarQube?

The quality rules are a set of quality standards on which the warnings raised by SonarQube are based.
They are grouped into bugs, maintainability and security issues.
The rules follow industry standards and are designed to show as little false positives as possible, giving developers a 
reliable way to identify and understand the severity of an issue.

## What is the purpose of the quality gates of SonarQube?

Quality gates let you configure how strict rules should be enforced.
You can set up a quality gate for each rule and compare the code to be deployed with them. 
This ensures that code being deployed meets your preferred threshold of quality across each metric.

## Run SonarLint on your local Computer

It is very annoying (and takes a lot of time) to wait for the pipeline to run SonarQube. 
To speed it up, you may first run the linting part of SonarQube (SonarLint) locally like this:

### Configure PyCharm for SonarLint (only once)

- Open *Settings->Plugins*
- Choose *MarketPlace*
- Search for *SonarLint* and install the PlugIn

### Run SonarLint

- In the project view (usually to the left) you can run the SonarLint analysis by a right click on a file or a folder. 
  You will find the entry at the very bottom of the menu.
- To run it on all source code of your project select the folder called *app*

# VPN

The servers providing Graylog, SonarQube and your APIs are hidden behind the firewall of Hochschule Darmstadt.
From outside the university it can only be accessed when using a VPN.
https://its.h-da.io/stvpn-docs/de/ 