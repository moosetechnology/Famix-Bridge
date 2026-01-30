"
A FamixBridgeToolTest is a test class for testing the behavior of FamixBridgeTool
"
Class {
	#name : 'FamixBridgeToolTest',
	#superclass : 'TestCase',
	#instVars : [
		'testResources',
		'tool',
		'mustRestartCache'
	],
	#category : 'Famix-Bridge-Tests',
	#package : 'Famix-Bridge-Tests'
}

{ #category : 'running' }
FamixBridgeToolTest >> setUp [

	super setUp.

	"Put here a common initialization logic for tests"
	testResources := TestJavaModelBuilder new.
	tool := FamixBridgeTool instance.
	mustRestartCache := tool isCacheEnabled.

	mustRestartCache ifTrue: [ tool disableCache ]
]

{ #category : 'running' }
FamixBridgeToolTest >> tearDown [ 

	super tearDown.

	mustRestartCache ifTrue: [ tool enableCache ]
]

{ #category : 'tests' }
FamixBridgeToolTest >> testAllWorkspaceModelsButSourceModel [

	| workspace result |
	workspace := MooseWorkspace new.
	workspace mainModel: testResources mainModel.
	workspace
		addLibraryModel: testResources libraryModel;
		addLibraryModel: testResources libraryModelClone.

	tool sourceModel: workspace mainModel.

	ActiveMooseWorkspace value class = NullMooseWorkspace ifFalse: [
		self fail:
			'There is currently an active moose workspace. Restart the test when it is not the case.' ].
	result := ActiveMooseWorkspace
		          value: workspace
		          during: [ tool allWorkspaceModelsButSourceModel ].

	self assert: result size equals: workspace librariesModels size.
	self assertCollection: result includesAll: workspace librariesModels.

	tool sourceModel: testResources libraryModelClone.

	ActiveMooseWorkspace value class = NullMooseWorkspace ifFalse: [
		self fail:
			'There is currently an active moose workspace. Restart the test when it is not the case.' ].
	result := ActiveMooseWorkspace
		          value: workspace
		          during: [ tool allWorkspaceModelsButSourceModel ].

	self assert: result size equals: workspace librariesModels size. "this or a magic number... which is best?"
	self assertCollection: result includesAll: {
			testResources mainModel.
			testResources libraryModel }
]

{ #category : 'tests' }
FamixBridgeToolTest >> testSearchResourceInModel [

	self
		assert: nil
		equals: (tool
				 searchResource: testResources stubMethodInMainProject
				 inModel: testResources mainModel).

	self
		assert: testResources resourceMethodInLibraryCloneProject
		equals: (tool
				 searchResource: testResources stubMethodInMainProject
				 inModel: testResources libraryModelClone).

	self
		assert: testResources resourceMethodInLibraryProject
		equals: (tool
				 searchResource: testResources stubMethodInMainProject
				 inModel: testResources libraryModel)
]

{ #category : 'tests' }
FamixBridgeToolTest >> testSearchStubInModel [

	self
		assert: testResources stubMethodInMainProject
		equals: (tool
				 searchStub: testResources resourceMethodInLibraryCloneProject
				 inModel: testResources mainModel).

	self
		assert: testResources stubMethodInMainProject
		equals: (tool
				 searchStub: testResources resourceMethodInLibraryProject
				 inModel: testResources mainModel).

	self
		assert: nil
		equals: (tool
				 searchStub: testResources resourceMethodInLibraryProject
				 inModel: testResources libraryModelClone).
				
	self
		assert: nil
		equals: (tool
				 searchStub: testResources resourceMethodInLibraryCloneProject
				 inModel: testResources libraryModel)
]
