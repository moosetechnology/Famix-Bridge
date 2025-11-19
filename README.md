# Famix-Bridge
Tooling solution for inter-model analysis

## Load the project

To load the project, open a Playground in a Moose image and execute the following command :

```St
Metacello new
  baseline: 'FamixBridge';
  repository: 'github://moosetechnology/Famix-Bridge:main/src';
  load
```
## How to use Famix-Bridge

To use Famix-Bridge and make inter-model queries or analysises, you must first create a `MooseWorkspace`.  
A `MooseWorkspace` is a set of Moose models forming a full software configuration, including a main project and the libraries it depends on.  

```Smalltalk
workspace := MooseWorkspace new.
workspace
  mainModel: aMooseModel;
  addLibraryModel: anotherMooseModel.
```

Once your workspace is created, you must use it with the message `interModelModeDuring: aBlock` in order to use Famix-Bridge. Simply add your query or analysis code in a block like so :

```Smalltalk
workspace interModelModeDuring: [ "any query or analysis class or tool you want to use goes here" ]
```

For more concrete examples, check the test classes in the `Moose-Workspace-Tests` package.
