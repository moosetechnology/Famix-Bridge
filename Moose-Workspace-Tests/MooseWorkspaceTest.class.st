Class {
	#name : 'MooseWorkspaceTest',
	#superclass : 'TestCase',
	#instVars : [
		'workspace',
		'modelResources'
	],
	#category : 'Moose-Workspace-Tests',
	#package : 'Moose-Workspace-Tests'
}

{ #category : 'initialization' }
MooseWorkspaceTest >> initialize [

	super initialize.
	
	"setting it in initialize method to only generate the model once if you run several tests"
	modelResources := TestJavaModelBuilder new 
]

{ #category : 'running' }
MooseWorkspaceTest >> setUp [
	super setUp.

	"Put here a common initialization logic for tests"
	workspace := MooseWorkspace new.
	workspace mainModel: modelResources mainModel.
	workspace addLibraryModel: modelResources libraryModel.
	
	workspace createFullMMECache
]

{ #category : 'tests' }
MooseWorkspaceTest >> testHierarchyAlwaysReturnsDefinedVersion [

	| mainModelClass libraryModelClass scMain scLibrary |
	mainModelClass := (workspace mainModel entityNamed: 'some.thing.whatever.MainClass').
	libraryModelClass := (workspace librariesModels anyOne entityNamed: 'library.blabla.LibraryClass').
	
	workspace clearCache.
	workspace createFullMMECache.
	
	scMain := workspace interModelModeDuring: [ mainModelClass superclass ].
	scLibrary := workspace interModelModeDuring: [ libraryModelClass superclass ].
	
	self assert: scMain equals: scLibrary
]

{ #category : 'tests' }
MooseWorkspaceTest >> testHierarchyQuery [

	| queryResults |
	queryResults := workspace interModelModeDuring: [
		                modelResources mainClassInMainProject superclass ].

	self
		assert: queryResults
		equals: modelResources superclassInLibraryProject
]

{ #category : 'tests' }
MooseWorkspaceTest >> testInterfaceImplementingClassesQuery [

	| queryResults expectedResults |
	queryResults := workspace interModelModeDuring: [
		           modelResources interfaceInLibraryProject
			           implementations collect: [ :imp | imp implementingClass ] ].

	expectedResults := {
			modelResources interfaceImplementorInMainProject.
			modelResources interfaceImplementorInLibraryProject }.

	self assert: queryResults size equals: expectedResults size.
	self assertCollection: queryResults includesAll: expectedResults
]

{ #category : 'tests' }
MooseWorkspaceTest >> testInvocationAlwaysReturnsDefinedVersion [

	| mainModelMethod libraryModelMethod invMain invLibrary |
	mainModelMethod := workspace mainModel entityNamed:
		                   'some.thing.whatever.MainClass.doSomething()'.
	libraryModelMethod := workspace librariesModels anyOne entityNamed:
		                      'library.blabla.LibraryClassUser.doStuff()'.

	workspace clearCache.
	workspace createFullMMECache.

	invMain := workspace interModelModeDuring: [
			           mainModelMethod invokedMethods detect: [ :m |
				           m name = 'doSomethingElse' ] ].
	invLibrary := workspace interModelModeDuring: [
			              mainModelMethod invokedMethods detect: [ :m |
				              m name = 'doSomethingElse' ] ].

	self assert: invMain equals: invLibrary
]

{ #category : 'tests' }
MooseWorkspaceTest >> testSuperclassMethods [

	| queryResults expectedResults |
	queryResults := workspace interModelModeDuring: [
		           modelResources mainClassInMainProject 
			           superclass methods ].
		
	expectedResults := OrderedCollection new.
	expectedResults addAll: modelResources stubSuperclassInMainProject methods.
	expectedResults addAll: modelResources superclassInLibraryProject methods.

	self assert: queryResults size equals: expectedResults size.
	self assertCollection: queryResults includesAll: expectedResults
]
