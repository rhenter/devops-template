# WebApps Devops

WebApps Devops orchestration and Deployment System. 
 
Usage
=====

Activate Virtualenv
-------------------

*This command assumes that the virtualenv name is devops and the
 requirements are already installed*

- Using Pyenv

```bash
    $ pyenv activate devops
```

or

- Using Virtualenvwrapper

```bash
    $ workon devops
```

**All installation procedure is included in the project documentation**

First Install
-------------

```bash
    $ ansible-playbook deploy.yml --tags permissions,common,nginx
```

Deploy
------

```bash
    $ ansible-playbook deploy.yml --tags APP_NAME
```

Add or remove a user
--------------------

Add or remove the user from operation_team list in inventory/group_vars/all.yml and execute the following command

```bash
    $ ansible-playbook deploy.yml --tags permissions
```


Finish
------

Check the Application URL if everything is right!
